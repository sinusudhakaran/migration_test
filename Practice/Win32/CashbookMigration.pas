unit CashbookMigration;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  uLkJSON,
  CashbookMigrationRestData,
  ZlibExGZ,
  IdCoder,
  IdCoderMIME,
  StDate,
  clObj32,
  ChartExportToMYOBCashbook,
  ipshttps;

const
  PUBLIC_KEY_FILE_CASHBOOK_TOKEN = 'PublicKeyMyobMigration.pke';

type
  //----------------------------------------------------------------------------
  TProgressEvent = procedure (aCurrentFile : integer;
                              aTotalFiles : integer;
                              aPercentOfCurrentFile : integer) of object;

  TMigrationStatus = (mgsSuccess,
                      mgsPartial,
                      mgsFailure);

  //----------------------------------------------------------------------------
  THttpHeaders = record
    ContentType: string;
    Accept: string;
    Authorization: string;
    MyobApiAccessToken: string;
  end;

  //----------------------------------------------------------------------------
  TCashbookMigration = class
  private
    fToken: string;
    fCashBookUserid : string;
    fUnEncryptedToken : string;
    fTokenStartDate : TDateTime;
    FHttpRequester : TipsHTTPS;
    fProgressEvent : TProgressEvent;

    fClientCount : integer;
    fCurrentClient : integer;
    fClientDataSize : integer;
    fNumCodeReplaced : integer;

  protected
    procedure LogHttpDebugSend(aCall : string;
                               aHeaders: THttpHeaders;
                               aPostData: TStringList); overload;
    procedure LogHttpDebugSend(aCall : string); overload;
    procedure LogHttpDebugUploadSend(aCall : string); overload;

    procedure LogHttpDebugReponce(aCall : string;
                                  aResponse : string);

    procedure DoHttpConnected(Sender     : TObject;
                              StatusCode : Integer;
                              const Description : String); Virtual;
    procedure DoHttpDisconnected(Sender     : TObject;
                                 StatusCode : Integer;
                                 const Description : String); Virtual;
    procedure DoHttpConnectionStatus(ASender : TObject;
                                     const AConnectionEvent : String;
                                     AStatusCode : Integer;
                                     const ADescription : String); Virtual;
    procedure DoHttpSSLServerAuthentication(ASender      : TObject;
                                            ACertEncoded : String;
                                            const ACertSubject : String;
                                            const ACertIssuer  : String;
                                            const AStatus      : String;
                                            var   AAccept      : Boolean); Virtual;
    procedure DoHttpStartTransfer(ASender    : TObject;
                                  ADirection : Integer); Virtual;
    procedure DoHttpTransfer(ASender           : TObject;
                             ADirection        : Integer;
                             ABytesTransferred : LongInt;
                             AText             : String); Virtual;
    procedure DoHttpEndTransfer(ASender    : TObject;
                                ADirection : Integer); Virtual;
    procedure DoHttpHeader(ASender : TObject;
                           const AField : String;
                           const AValue : String); Virtual;

    procedure HttpSetup;
    procedure EncryptToken(aToken : string);

    function DoHttpSecure(const aVerb: string; const aURL: string;
                          const aHeaders: THttpHeaders; const aRequest: string;
                          var aResponse: string; var aError: string): boolean;

    function DoHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                              var aResponse: TlkJSONbase; var aRespStr : string;
                              var aError: string; aEncryptToken : boolean = false): boolean;

    function DoUploadHttpSecure(const aVerb: string; const aURL: string;
                                const aHeaders: THttpHeaders; const aRequest: string;
                                var aResponse: string; var aError: string): boolean;

    function DoUploadHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                                    var aResponse: TlkJSONbase; var aRespStr : string;
                                    var aError: string; aEncryptToken : boolean = false): boolean;

    procedure AddCommentToClient(aClientLRN : integer; aNote : string);
    function ValidateIRDGST(aValue : string; var aModifiedIRD : string) : boolean;
    function FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aError : string) : boolean;

    function FillBusinessData(aClient : TClientObj; aBusinessData : TBusinessData; aFirmId : string; aClosingBalanceDate: TStDate; var aError : string) : boolean;
    function FillBankFeedData(aClient : TClientObj; aBankFeedApplicationsData : TBankFeedApplicationsData; var aError : string) : boolean;
    function FillDivisionData(aClient : TClientObj; aDivisionsData : TDivisionsData; var aUsedDivisions : TStringList; var aError : string) : boolean;
    function FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aDoChartOfAccountBalances : boolean; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; var aError : string) : boolean;
    function FillTransactionData(aClient : TClientObj; aTransactionsData : TTransactionsData; var aError : string) : boolean;
    function FillJournalData(aClient : TClientObj; aJournalsData : TJournalsData; var aError : string) : boolean;

    function UploadClient(aClientBase : TClientBase; aSelectedData: TSelectedData; var aError: string): boolean;

    function MigrateClient(aClient : TClientObj; aSelectedData: TSelectedData; var aError: string): boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Login(const aEmail: string; const aPassword: string; var aError : string): boolean;

    function GetFirms(var aFirms: TFirms; var aError: string): boolean;

    function MigrateClients(aSelectClients : TStringList; aSelectedData : TSelectedData;
                            var aClientErrors : TStringList) : TMigrationStatus;

    property OnProgressEvent : TProgressEvent read fProgressEvent write fProgressEvent;
  end;

  //----------------------------------------------------------------------------
  function  MigrateCashbook(): TCashbookMigration;

//------------------------------------------------------------------------------
implementation

uses
  EncryptOpenSSL,
  Globals,
  bkConst,
  Files,
  GenUtils,
  LogUtil,
  strUtils,
  BKDEFS,
  baUtils,
  glConst,
  ChartUtils,
  stDatest,
  bkDateUtils,
  AdminNotesForClient,
  Admin32,
  ClientHomePagefrm,
  forms,
  controls,
  SYDEFS;

const
  UnitName = 'CashbookMigration';
  INIT_VECTOR = '@AT^NK(@YUVK)$#Y';
  CASBOOK_BASE = 'https://burwood.cashbook.us/';
  CASBOOK_API_BASE = CASBOOK_BASE + 'api/';
  CASBOOK_ADCOMMON_BASE = CASBOOK_BASE + 'ADCommon/';
  OAUTH2_BASE = 'https://test.secure.myob.com/oauth2/v1/';

  CASBOOK_UPLOAD_BASE = 'http://10.72.20.125/ADCommon/';

  MY_DOT_CONTENT_TYPE = 'application/x-www-form-urlencoded';
  MY_DOT_GRANT_PASSWORD = 'password';
  MY_DOT_GRANT_REFRESH_TOKEN = 'refresh_token';

  CASHBOOK_CONTENT_TYPE = 'application/json; charset=utf-8';
  CASHBOOK_ACCEPT = 'application/vnd.cashbook-v1+json';
  CASHBOOK_AUTH_PREFIX = 'Bearer ';

var
  fCashbookMigration: TCashbookMigration;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function MigrateCashbook: TCashbookMigration;
begin
  if not assigned(fCashbookMigration) then
  begin
    fCashbookMigration := TCashbookMigration.Create;
  end;

  result := fCashbookMigration;
end;

//------------------------------------------------------------------------------
{ TCashbookMigration }
procedure TCashbookMigration.LogHttpDebugSend(aCall : string; aHeaders: THttpHeaders; aPostData: TStringList);
var
  PostIndex : integer;
begin
  LogUtil.LogMsg(lmDebug, UnitName, 'Client Send : ' + aCall);

  if (aHeaders.ContentType <> '') then
    LogUtil.LogMsg(lmDebug, UnitName, 'Headers - ContentType : ' + aHeaders.ContentType +
                                      ', Accept : ' + aHeaders.Accept +
                                      ', Authorization : ' + aHeaders.Authorization +
                                      ', MyobApiAccessToken : ' + aHeaders.MyobApiAccessToken);

  if Assigned(aPostData) then
    for PostIndex := 0 to aPostData.Count-1 do
      LogUtil.LogMsg(lmDebug, UnitName, 'PostData ' + inttostr(PostIndex) + ' - ' + aPostData.Strings[PostIndex] );
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.LogHttpDebugSend(aCall: string);
var
  Headers: THttpHeaders;
begin
  Headers.ContentType := '';
  LogHttpDebugSend(aCall, Headers, nil);
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.LogHttpDebugUploadSend(aCall: string);
var
  Headers: THttpHeaders;
begin
  Headers.ContentType := '';
  LogHttpDebugSend(aCall, Headers, nil);
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.LogHttpDebugReponce(aCall : string; aresponse: string);
begin
  LogUtil.LogMsg(lmDebug, UnitName, 'Server Respond : ' + aCall);
  LogUtil.LogMsg(lmDebug, UnitName, 'response - ' + aresponse);
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpConnected(Sender     : TObject;
                                             StatusCode : Integer;
                                             const Description : String);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpDisconnected(Sender     : TObject;
                                                StatusCode : Integer;
                                                const Description : String);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpConnectionStatus(ASender: TObject;
                                                    const AConnectionEvent: String;
                                                    AStatusCode: Integer;
                                                    const ADescription: String);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpSSLServerAuthentication(ASender      : TObject;
                                                           ACertEncoded : String;
                                                           const ACertSubject : String;
                                                           const ACertIssuer  : String;
                                                           const AStatus      : String;
                                                           var   AAccept      : Boolean);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpStartTransfer(ASender    : TObject;
                                                 ADirection : Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpTransfer(ASender           : TObject;
                                            ADirection        : Integer;
                                            ABytesTransferred : LongInt;
                                            AText             : String);
var
  Percent : integer;
begin
  if ABytesTransferred > fClientDataSize then
    Percent := 100
  else
    Percent := trunc(ABytesTransferred / fClientDataSize);

  if Assigned(fProgressEvent) then
  begin
    fProgressEvent(fCurrentClient, fClientCount, Percent);
  end;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpEndTransfer(ASender    : TObject;
                                               ADirection : Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpHeader(ASender : TObject;
                                          const AField : String;
                                          const AValue : String);
begin

end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.HttpSetup;
begin
  FHttpRequester.OnConnected               := DoHttpConnected;
  FHttpRequester.OnDisconnected            := DoHttpDisconnected;
  FHttpRequester.OnConnectionStatus        := DoHttpConnectionStatus;
  FHttpRequester.OnSSLServerAuthentication := DoHttpSSLServerAuthentication;
  FHttpRequester.OnStartTransfer           := DoHttpStartTransfer;
  FHttpRequester.OnTransfer                := DoHttpTransfer;
  FHttpRequester.OnEndTransfer             := DoHttpEndTransfer;
  FHttpRequester.OnHeader                  := DoHttpHeader;

  FHttpRequester.AuthScheme   := authBasic;

  FHttpRequester.Config ('SSLSecurityFlags=0x80000000');
  FHttpRequester.Config ('SSLEnabledProtocols=140');
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.EncryptToken(aToken: string);
const
  KEY_DELIMMITER = '|KEY|';
var
  KeyString : string;
  EncryptedToken : string;
  EncryptedKey : string;
begin
  fUnEncryptedToken := aToken;

  KeyString := OpenSSLEncription.GetRandomKey;
  if OpenSSLEncription.AESEncrypt(KeyString, aToken, EncryptedToken, INIT_VECTOR) then
  begin
    EncryptedKey := OpenSSLEncription.SimpleRSAEncrypt(KeyString, GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN);
    fToken := EncryptedToken + KEY_DELIMMITER + EncryptedKey;
    fTokenStartDate := Now();
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecure(const aVerb, aURL: string; const aHeaders: THttpHeaders;
                                          const aRequest: string; var aResponse, aError: string): boolean;
const
  CRLF = #13#10;
var
  LoggedRequest : string;

  function RemovePassword(aValue : string) : string;
  var
    StartPos : integer;
    EndPos : integer;
    LenStr : integer;
  begin
    StartPos := Pos('password=',aValue) + 8;
    Result := LeftStr(aValue, StartPos);
    LenStr := length(aValue);
    EndPos := Pos('&',RightStr(aValue, (LenStr-StartPos)));
    Result := Result + RightStr(aValue, ((LenStr-StartPos)-EndPos)+1);
  end;

begin
  Result := false;

  { WORKAROUND:
    Setting specific headers (Authorization/Accept/Content-Type) doesn't work,
    so we must use OtherHeaders instead.
  }
  FHttpRequester.OtherHeaders :=
    'Content-Type: ' + aHeaders.ContentType + CRLF +
    'Accept: ' + aHeaders.Accept + CRLF +
    'Authorization: ' + aHeaders.Authorization + CRLF +
    'x-myobapi-accesstoken: ' + aHeaders.MyobApiAccessToken;

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, aVerb + ' : ' + aURL);
    LogUtil.LogMsg(lmDebug, UnitName, 'Headers : ' + FHttpRequester.OtherHeaders);

    if (aVerb <> 'GET')  and
       (aRequest <> '') then
    begin
      LoggedRequest := RemovePassword(aRequest);
      LogUtil.LogMsg(lmDebug, UnitName, 'Request : ' + LoggedRequest);
    end;
  end;

  if (aVerb = 'GET') then
  begin
    FHttpRequester.Get(aURL);
  end
  else
  begin
    FHttpRequester.PostData := aRequest;
    FHttpRequester.Post(aURL);
  end;

  aResponse := FHttpRequester.TransferredData;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Response : ' + aResponse);

  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoUploadHttpSecure(const aVerb, aURL: string; const aHeaders: THttpHeaders;
                                               const aRequest: string; var aResponse, aError: string): boolean;
const
  CRLF = #13#10;
begin
  Result := false;

  { WORKAROUND:
    Setting specific headers (Authorization/Accept/Content-Type) doesn't work,
    so we must use OtherHeaders instead.
  }
  FHttpRequester.OtherHeaders :=
    'Content-Type: ' + aHeaders.ContentType + CRLF +
    'x-myobapi-accesstoken: ' + aHeaders.MyobApiAccessToken;

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, aVerb + ' : ' + aURL);
    LogUtil.LogMsg(lmDebug, UnitName, 'Headers : ' + FHttpRequester.OtherHeaders);

    if (aVerb <> 'GET')  and
       (aRequest <> '') then
      LogUtil.LogMsg(lmDebug, UnitName, 'Request : ' + aRequest);
  end;

  if (aVerb = 'GET') then
  begin
    FHttpRequester.Get(aURL);
  end
  else
  begin
    FHttpRequester.PostData := aRequest;
    FHttpRequester.Post(aURL);
  end;

  aResponse := FHttpRequester.TransferredData;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Response : ' + aResponse);

  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                                             var aResponse: TlkJSONbase; var aRespStr : string;
                                             var aError: string; aEncryptToken : boolean): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
begin
  result := false;

  aResponse := nil;

  try
    // Verb
    if not assigned(aRequest) then
      sVerb := 'GET'
    else
      sVerb := 'POST';

    // Headers
    Headers.ContentType := CASHBOOK_CONTENT_TYPE;
    Headers.Accept := CASHBOOK_ACCEPT;

    if aEncryptToken then
    begin
      Headers.Authorization := CASHBOOK_AUTH_PREFIX + fToken;
      Headers.MyobApiAccessToken := fToken;
    end
    else
    begin
      Headers.Authorization := CASHBOOK_AUTH_PREFIX + fUnEncryptedToken;
      Headers.MyobApiAccessToken := fUnEncryptedToken;
    end;

    // Body
    if assigned(aRequest) then
    begin
      sRequest := TlkJSON.GenerateText(aRequest);
      fClientDataSize := length(sRequest);
    end;

    // Http
    if not DoHttpSecure(sVerb, aURL, Headers, sRequest, aRespStr, aError) then
      exit;

    // Response
    aResponse := TlkJSON.ParseText(aRespStr);
    if not assigned(aResponse) then
      exit;
  except
    on E: Exception do
    begin
      FreeAndNil(aResponse);

      aError := E.Message;
      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoUploadHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                                                   var aResponse: TlkJSONbase; var aRespStr : string;
                                                   var aError: string; aEncryptToken : boolean): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
begin
  result := false;

  aResponse := nil;

  try
    // Verb
    if not assigned(aRequest) then
      sVerb := 'GET'
    else
      sVerb := 'POST';

    // Headers
    Headers.ContentType := CASHBOOK_CONTENT_TYPE;
    Headers.Accept := CASHBOOK_ACCEPT;

    if aEncryptToken then
    begin
      Headers.Authorization := CASHBOOK_AUTH_PREFIX + fToken;
      Headers.MyobApiAccessToken := fToken;
    end
    else
    begin
      Headers.Authorization := CASHBOOK_AUTH_PREFIX + fUnEncryptedToken;
      Headers.MyobApiAccessToken := fUnEncryptedToken;
    end;

    // Body
    if assigned(aRequest) then
    begin
      sRequest := TlkJSON.GenerateText(aRequest);
      sRequest := FixJsonString(sRequest);
    end;

    // Http
    if not DoUploadHttpSecure(sVerb, aURL, Headers, sRequest, aRespStr, aError) then
      exit;

    // Response
    aResponse := TlkJSON.ParseText(aRespStr);
    if not assigned(aResponse) then
      exit;
  except
    on E: Exception do
    begin
      FreeAndNil(aResponse);

      aError := E.Message;
      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.ValidateIRDGST(aValue: string; var aModifiedIRD : string): boolean;
var
  LenStr : integer;
  Index : integer;
  OnlyNumbers : string;
begin
  Result := false;

  OnlyNumbers := '';
  for Index := 1 to Length(aValue) do
  begin
    if aValue[Index] in ['0'..'9'] then
      OnlyNumbers := OnlyNumbers + aValue[Index];
  end;

  aModifiedIRD := OnlyNumbers;

  LenStr := Length(OnlyNumbers);
  if LenStr in [8,9,13] then
  begin
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aError : string) : boolean;
var
  ClientCode : string;
  TestCode : string;
  Index : integer;
  NumReplStr : string;
begin
  Result := false;
  aOutClientCode := '';
  TestCode := '';
  for Index := 0 to length(aInClientCode) do
  begin
    if (aInClientCode[Index] in ['0'..'9']) or
       (aInClientCode[Index] in ['a'..'z']) or
       (aInClientCode[Index] in ['A'..'Z']) then
      TestCode := TestCode + aInClientCode[Index];
  end;

  if TestCode <> aInClientCode then
  begin
    try
      inc(fNumCodeReplaced);
      if fNumCodeReplaced > 999 then
      begin
        aError := 'Error converting Client Code into ' + BRAND_CASHBOOK_NAME + ' format.';
        exit;
      end;

      NumReplStr := inttoStr(fNumCodeReplaced);

      while (length(NumReplStr) < 3) do
        NumReplStr := '0' + NumReplStr;

      while (length(TestCode) < 7) do
        TestCode := TestCode + '0';

      TestCode := TestCode + NumReplStr;
    except
      on E : Exception do
      begin
        aError := 'Exception converting Practice Client Code into valid ' + BRAND_CASHBOOK_NAME + ' Client code, Error : ' + E.Message;
        exit;
      end;
    end;

    ClientCode := TestCode;
  end
  else
    ClientCode := aInClientCode;

  aOutClientCode := ClientCode;
  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillBusinessData(aClient: TClientObj; aBusinessData: TBusinessData; aFirmId : string; aClosingBalanceDate: TStDate; var aError: string): boolean;
var
  ClientCode : string;
  FYSday, FYSmonth, FYSyear : integer;
  ABN : string;
  Branch : string;
  IRD : string;
  BalDate : TStDate;
  OpenBalDate : TStDate;
  ModifiedIRD : string;
begin
  Result := false;

  if not FixClientCodeForCashbook(aClient.clFields.clCode, ClientCode, aError) then
    Exit;

  try
    StDateToDMY( aClient.clFields.clFinancial_Year_Starts, FYSday, FYSmonth, FYSyear);

    if AdminSystem.fdFields.fdCountry = whAustralia then
      SplitABNandBranchFromGSTNumber(aClient.clFields.clGST_Number, ABN, Branch)
    else
      ABN := '';

    if (AdminSystem.fdFields.fdCountry = whNewZealand) and
       (ValidateIRDGST(trim(aClient.clFields.clGST_Number), ModifiedIRD)) then
      IRD := ModifiedIRD
    else
      IRD := '';

    aBusinessData.FirmId := aFirmId;
    aBusinessData.ClientCode := ClientCode;
    aBusinessData.OrigClientCode := aClient.clFields.clCode;
    aBusinessData.Name := aClient.clFields.clName;
    aBusinessData.FinancialYearStartMonth := FYSmonth;
    aBusinessData.ABN := ABN;
    aBusinessData.IRD := IRD;

    OpenBalDate := IncDate(aClosingBalanceDate, 1, 0, 0);
    if OpenBalDate = BadDate then
      aBusinessData.OpeningBalanceDate := ''
    else
      aBusinessData.OpeningBalanceDate := StDateToDateString('yyyy-mm-dd', OpenBalDate, true);

    Result := true;
  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Client data : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillBankFeedData(aClient: TClientObj; aBankFeedApplicationsData: TBankFeedApplicationsData; var aError: string): boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  BankFeedApplicationData : TBankFeedApplicationData;
begin
  Result := false;
  try
    for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
    begin
      AccRec := aClient.clChart.Account_At(ChartIndex)^;
      if AccRec.chAccount_Type = atBankAccount then
      begin
        BankFeedApplicationData := TBankFeedApplicationData.Create(aBankFeedApplicationsData);

        if AdminSystem.fdFields.fdCountry = whAustralia then
          BankFeedApplicationData.CountryCode := 'OZ'
        else
          BankFeedApplicationData.CountryCode := 'NZ';
        BankFeedApplicationData.CoreClientCode := aClient.clFields.clCode;
        BankFeedApplicationData.BankAccountNumber := AccRec.chAccount_Code;

        aClient.clBank_Account_List.Bank_Account_At(1)
      end;
    end;
    Result := true;
  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Bank Feeds : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillDivisionData(aClient: TClientObj; aDivisionsData: TDivisionsData; var aUsedDivisions : TStringList; var aError: string): boolean;
var
  DivisionIndex : integer;
  DivName    : string;
  DivisionItem : TDivisionData;
begin
  Result := false;
  try
    for DivisionIndex := 1 to Max_Divisions do
    begin
      DivName := aClient.clCustom_Headings_List.Get_Division_Heading(DivisionIndex);

      if length(trim(DivName)) > 0 then
      begin
        DivisionItem := TDivisionData.Create(aDivisionsData);
        DivisionItem.Id := DivisionIndex;
        DivisionItem.Name := DivName;

        aUsedDivisions.Add(inttostr(DivisionIndex));
      end;
    end;
    Result := true;

  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Divisions : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aDoChartOfAccountBalances : boolean; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; var aError : string) : boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  NewChartItem : TChartOfAccountData;
  GSTClassTypeIndicator : byte;
  ChartExportItem : TChartExportItem;
  MappedGroupId : TCashBookChartClasses;
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
  GSTMapItem : TGSTMapItem;
  GSTClass : TCashBookGSTClasses;

  Function GetValidDivisions() : string;
  var
    DivIndex : integer;
    Divisions : TStringList;
    PrintIndex : integer;
  begin
    Divisions := TStringList.Create();
    try
      Divisions.Delimiter := ',';
      Divisions.StrictDelimiter := true;

      for DivIndex := 0 to aUsedDivisions.Count-1 do
      begin
        PrintIndex := Strtoint(aUsedDivisions.Strings[DivIndex]);
        if AccRec.chPrint_in_Division[PrintIndex] then
          Divisions.Add(inttostr(PrintIndex));
      end;

      Result := Divisions.DelimitedText;
    finally
      FreeAndNil(Divisions);
    end;
  end;
begin
  Result := false;

  try
    for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
    begin
      AccRec := aClient.clChart.Account_At(ChartIndex)^;

      NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
      NewChartItem.Code := AccRec.chAccount_Code;
      NewChartItem.Name := StripInvalidCharacters(AccRec.chAccount_Description);
      NewChartItem.InActive := AccRec.chInactive;
      NewChartItem.PostingAllowed := AccRec.chPosting_Allowed;
      NewChartItem.Divisions := GetValidDivisions();

      if aChartExportCol.ItemAtCode(AccRec.chAccount_Code, ChartExportItem) then
      begin
        MappedGroupId := aChartExportCol.GetMappedReportGroupId(ChartExportItem.ReportGroupId);

        NewChartItem.OrigAccountType := atNames[AccRec.chAccount_Type];
        NewChartItem.OrigGstType := aClient.clFields.clGST_Class_Codes[ AccRec.chGST_Class ] + ' ' +
                                    aClient.clFields.clGST_Class_Names[ AccRec.chGST_Class];
        NewChartItem.AccountType := GetMigrationMappedReportGroupCode(MappedGroupId);

        if (AdminSystem.fdFields.fdCountry = whAustralia) then
        begin
          if aGSTMapCol.ItemAtGstIndex(ChartExportItem.GSTClassId, GSTMapItem) then
            CashBookGstClassCode := aGSTMapCol.GetGSTClassCode(GSTMapItem.CashbookGstClass)
          else
            CashBookGstClassCode := aGSTMapCol.GetGSTClassCode(cgNone);
        end
        else if (AdminSystem.fdFields.fdCountry = whNewZealand) then
        begin
          GSTClassTypeIndicator := GetGSTClassTypeIndicatorFromGSTClass(ChartExportItem.GSTClassId);
          GSTClass := GetMappedNZGSTTypeCode(GSTClassTypeIndicator);
          GetMYOBCashbookGSTDetails(GSTClass, CashBookGstClassCode, CashBookGstClassDesc);
        end;
        NewChartItem.GstType := CashBookGstClassCode;

        if aDoChartOfAccountBalances then
          NewChartItem.OpeningBalance := GetMigrationClosingBalance(ChartExportItem.ClosingBalance)
        else
          NewChartItem.OpeningBalance := 0;

        NewChartItem.BankOrCreditFlag := ChartExportItem.IsContra;
      end
      else
      begin
        NewChartItem.AccountType := 'uncategorised';
        NewChartItem.GstType := 'NA';
        NewChartItem.OrigAccountType := '';
        NewChartItem.OrigGstType := '';
        NewChartItem.OpeningBalance := 0;
        NewChartItem.BankOrCreditFlag := false;
      end;
    end;
    Result := true;
  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Chart : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillTransactionData(aClient: TClientObj; aTransactionsData: TTransactionsData; var aError: string): boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillJournalData(aClient: TClientObj; aJournalsData: TJournalsData; var aError: string): boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.UploadClient(aClientBase : TClientBase; aSelectedData: TSelectedData; var aError: string): boolean;
var
  Request: TlkJSONobject;
  sURL: string;
  ResponseBase: TlkJSONbase;
  Response: TlkJSONobject;
  RespStr : string;
  UploadDone : boolean;
  Data : string;

  MigUpload : TMigrationUpload;
  MigUploadResponse : TMigrationUploadResponse;
begin
  Result := false;
  // FileUpload
  MigUpload := TMigrationUpload.Create;
  try
    Data := aClientBase.GetData(aSelectedData);

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Business Json : ' + Data);

    MigUpload.Files.Data := Data;
    MigUpload.Files.FileName := 'Test.json';
    MigUpload.Parameters.DataStore := PRACINI_CashbookAPIUploadDataStore;
    MigUpload.Parameters.Queue := PRACINI_CashbookAPIUploadQueue;

    MigUpload.Parameters.Region := inttostr(ord(AdminSystem.fdFields.fdCountry));
    try
      // Request
      Request := TlkJSONobject.Create;
      try
        MigUpload.Write(Request);

        // HTTP
        sURL := PRACINI_CashbookAPIUploadURL;

        UploadDone := DoUploadHttpSecureJson(sURL, Request, ResponseBase, RespStr, aError, false);

        if not UploadDone then
        begin
          LogUtil.LogMsg(lmError, UnitName, aError);
          exit;
        end;

        if not (Assigned(Response)) or
           not (Response is TlkJSONobject) then
        begin
          aError := 'Error uploading client data : No response from server.';
          exit;
        end;

        try
          // Response
          Response := (ResponseBase as TlkJSONobject);

          MigUploadResponse := TMigrationUploadResponse.Create;
          try
            MigUploadResponse.Read(Response);

            if MigUploadResponse.RespondeCode <> UPLOAD_RESP_SUCESS then
            begin
              case MigUploadResponse.RespondeCode of
                UPLOAD_RESP_ERROR     : aError := 'Error uploading client data : Error response from server.';
                UPLOAD_RESP_UKNOWN    : aError := 'Error uploading client data : Unknown response from server.';
                UPLOAD_RESP_DUPLICATE : aError := 'Error uploading client data : Duplicate Upload.';
                UPLOAD_RESP_CORUPT    : aError := 'Error uploading client data : Corrupt Upload.';
              end;
              Exit;
            end;
            Result := true;

          finally
            FreeAndNil(MigUploadResponse)
          end;

        finally
          FreeAndNil(Response);
        end;

      finally
        FreeAndNil(Request);
      end;

    except
      on E: Exception do
      begin
        aError := 'Exception uploading client data : ' + E.Message;
        exit;
      end;
    end;
  finally
    FreeAndNil(MigUpload);
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.MigrateClient(aClient : TClientObj; aSelectedData: TSelectedData; var aError: string): boolean;
var
  ClientBase : TClientBase;
  ChartExportCol : TChartExportCol;
  GSTMapCol : TGSTMapCol;
  BalDate : TStDate;
  ClosingBalanceDate : TStDate;
  UsedDivisions : TStringList;
begin
  result := false;

  // Phase 1 force all options to no, just send client create data
  aSelectedData.Bankfeeds := false;
  aSelectedData.NonTransferedTransactions := false;

  ClientBase := TClientBase.Create;
  try
    ClientBase.Token := fToken;

    if GetLastFullyCodedMonth(BalDate) then
      ClosingBalanceDate := BalDate
    else
      ClosingBalanceDate := BkNull2St(MyClient.clFields.clPeriod_End_Date);

    if not FillBusinessData(aClient, ClientBase.ClientData.BusinessData, aSelectedData.FirmId, ClosingBalanceDate, aError) then
      Exit;

    if aSelectedData.ChartOfAccount then
    begin
      ChartExportCol := TChartExportCol.Create(TChartExportItem);
      try
        ChartExportCol.FillChartExportCol(true);
        ChartExportCol.UpdateClosingBalances(ClosingBalanceDate);
        GSTMapCol := TGSTMapCol.Create(TGSTMapItem);
        try
          GSTMapCol.FillGstClassMapArr;

          UsedDivisions := TStringList.Create();
          UsedDivisions.Delimiter := ',';
          UsedDivisions.StrictDelimiter := true;
          try
            if not FillDivisionData(aClient, ClientBase.ClientData.DivisionsData, UsedDivisions, aError) then
              Exit;

            if not FillChartOfAccountData(aClient, ClientBase.ClientData.ChartOfAccountsData, aSelectedData.ChartOfAccountBalances, ChartExportCol, GSTMapCol, UsedDivisions, aError) then
              Exit;
          finally
            FreeAndNil(UsedDivisions);
          end;

          if aSelectedData.NonTransferedTransactions then
          begin
            if not FillTransactionData(aClient, ClientBase.ClientData.TransactionsData, aError) then
              Exit;

            if not FillJournalData(aClient, ClientBase.ClientData.JournalsData, aError) then
              Exit;
          end;
        finally
          FreeAndNil(GSTMapCol);
        end;
      finally
        FreeAndNil(ChartExportCol);
      end;
    end;

    if not UploadClient(ClientBase, aSelectedData, aError) then
      Exit;

    result := true;
  finally
    FreeAndNil(ClientBase);
  end;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.AddcOMMENTToClient(aClientLRN : integer; aNote: string);
var
  NoteIndex : integer;
  CurrComment : string;
  aError : string;
begin
  try
    CurrComment := GetNotesForClient( aClientLRN);

    CurrComment := aNote + #13#10 + #13#10 + CurrComment;

    UpdateNotesForClient( aClientLRN, CurrComment);
  except
    on E : Exception do
      begin
        aError := 'Error adding comment to Client : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aError);
      end;
  end;
end;

constructor TCashbookMigration.Create;
begin
  // Http
  FHttpRequester  := TIpsHTTPS.Create(nil);
  HttpSetup;
end;

//------------------------------------------------------------------------------
destructor TCashbookMigration.Destroy;
begin
  // Http
  FreeAndNil(FHttpRequester);

  inherited;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.Login(const aEmail: string; const aPassword: string; var aError : string): boolean;
var
  Headers: THttpHeaders;
  PostData: TStringList;
  js: TlkJSONobject;
  sResponse: string;
  sError: string;
  Token : string;
begin
  result := false;

  // Setup REST request
  PostData := nil;
  js := nil;
  try
    try
      Headers.ContentType := MY_DOT_CONTENT_TYPE;

      PostData := TStringList.Create;
      PostData.Delimiter := '&';
      PostData.StrictDelimiter := true;

      PostData.Values['client_id']     := PRACINI_CashbookAPILoginID;
      PostData.Values['client_secret'] := PRACINI_CashbookAPILoginSecret;
      PostData.Values['username']      := aEmail;
      PostData.Values['password']      := aPassword;
      PostData.Values['grant_type']    := MY_DOT_GRANT_PASSWORD;
      PostData.Values['scope']         := PRACINI_CashbookAPILoginScope;

      // Cancelled?
      if not DoHttpSecure(
        'POST',
        PRACINI_CashbookAPILoginURL,
        Headers,
        PostData.DelimitedText,
        sResponse,
        sError) then
      begin
        LogUtil.LogMsg(lmError, UnitName, 'Error running CashbookMigration.Login, Error Message : ' + sError);
        aError := sError;
        exit;
      end;

      // Parse JSON result
      js := TlkJSON.ParseText(sResponse) as TlkJSONobject;

      if not assigned(js) then
      begin
        aError := 'Error running CashbookMigration.Login, Error Message : No response from Server.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      // Get token
      Token := js.GetString('access_token');
      if (Token <> '') then
        EncryptToken(Token)
      else
      begin
        aError := 'Error running CashbookMigration.Login, Error Message : Can not find Access Token in response.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      result := true;

    except
      on E : Exception do
      begin
        aError := 'Exception running CashbookMigration.Login, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;
    end;

  finally
    FreeAndNil(PostData);
    FreeAndNil(js);
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.GetFirms(var aFirms: TFirms; var aError: string): boolean;
var
  sURL: string;
  Response: TlkJSONbase;
  List: TlkJSONlist;
  RespStr : string;
begin
  result := false;

  Response := nil;
  try
    try
      sURL := PRACINI_CashbookAPIFirmsURL;

      if not DoHttpSecureJson(sURL, nil, Response, RespStr, aError) then
        exit;

      if not (Assigned(Response)) or
         not (Response is TlkJSONlist) then
      begin
        aError := 'Error running CashbookMigration.GetFirms, Error Message : No response from Server.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      List := (Response as TlkJSONlist);

      aFirms.clear;
      if Assigned(aFirms) then
        aFirms.Read(List);
    except
      on E: Exception do
      begin
        aError := 'Exception running CashbookMigration.GetFirms, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;
    end;
  finally
    FreeAndNil(Response);
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.MigrateClients(aSelectClients: TStringList;
                                           aSelectedData: TSelectedData;
                                           var aClientErrors : TStringList) : TMigrationStatus;
var
  ClientIndex : integer;
  CurrentClientCode : string;
  ClientFileCode : string;
  SysClient : pClient_File_Rec;
  CltClient : TClientObj;
  ClientLRN : integer;
  ErrorStr  : string;
begin
  // Initialize ErrorList and progress event
  aClientErrors.clear;

  fClientCount := aSelectClients.Count;
  fCurrentClient := 1;
  fClientDataSize := 0;
  fNumCodeReplaced := 0;

  // Loop through selected Client Codes
  for ClientIndex := 0 to aSelectClients.Count-1 do
  begin
    if Assigned(fProgressEvent) then
      fProgressEvent(ClientIndex, aSelectClients.Count, 0);

    fCurrentClient := ClientIndex + 1;
    CurrentClientCode := aSelectClients.Strings[ClientIndex];
    try
      SysClient := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode);
      ClientLRN := SysClient.cfLRN;

      if not Assigned(SysClient) then
      begin
        ErrorStr := CurrentClientCode + ' Error finding Client in System File.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      if not AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status = bkConst.fsNormal then
      begin
        ErrorStr := CurrentClientCode + ' Error with Client, it is not in the correct status. ' +
                    'Current Status : ' + fsNames[AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status] +
                    ' needs to be in normal status.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      ClientFileCode := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode).cfFile_Code;

      CltClient := nil;
      OpenAClient(ClientFileCode, CltClient, true);

      if not Assigned(CltClient) then
      begin
        ErrorStr := CurrentClientCode + ' Error opening Client file.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      MyClient := CltClient;
      try
        Screen.Cursor := crHourglass;

        if not MigrateClient(CltClient, aSelectedData, ErrorStr) then
        begin
          ErrorStr := CurrentClientCode + ' ' + ErrorStr;
          aClientErrors.Add(ErrorStr);
          LogUtil.LogMsg(lmError, UnitName, ErrorStr);
          Continue;
        end
        else
        begin
          AddCommentToClient(ClientLRN, StDateToDateString('dd/mm/yyyy', CurrentDate(), true) +
                                        ' Migrated to ' + BRAND_CASHBOOK_NAME);
          CltClient.clMoreFields.mcArchived := true;
          CltClient.clFields.clFile_Save_Required := true;
          SaveAClient(CltClient);

          if LoadAdminSystem(True, 'CashbookMigration') then
          begin
            try
              SysClient := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode);
              SysClient.cfHas_Client_Notes := true;
              SaveAdminSystem;
            except
              if AdminIsLocked then
                UnLockAdmin;

              raise;
            end;
          end;

          LogUtil.LogMsg(lmInfo, UnitName, CurrentClientCode + ' Successfully uploaded client to ' + BRAND_CASHBOOK_NAME + '.');
        end;
      finally
        MyClient := nil;
        AbandonAClient(CltClient);
      end;

    except
      on E: Exception do
      begin
        ErrorStr := CurrentClientCode + ' Exception opening Client, Error : ' + E.Message;
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;
    end;

    if Assigned(fProgressEvent) then
      fProgressEvent(ClientIndex+1, aSelectClients.Count, 100);
  end;

  RefreshHomepage([HPR_Tasks]);

  // Set Result according to amount of errors, used in UI
  if aClientErrors.Count = 0 then
    Result := mgsSuccess
  else if aClientErrors.count = aSelectClients.count then
    Result := mgsFailure
  else
    Result := mgsPartial;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  fCashbookMigration := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fCashbookMigration);
end;

end.
