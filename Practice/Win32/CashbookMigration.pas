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
  BKWebBrowser,
  ipshttps;

const
  PUBLIC_KEY_FILE_CASHBOOK_TOKEN = 'PublicKeyMyobMigration.pke';

type
  //----------------------------------------------------------------------------
  TProgressEvent = procedure (aCurrentFile : integer;
                              aTotalFiles : integer;
                              aPercentOfCurrentFile : integer) of object;

  TClientMigrationState = (cmsAccessSysDB,
                           cmsAccessCltDB,
                           cmsTransformData,
                           cmsConnectToAPI,
                           cmsUploadError);

  TMigrationStatus = (mgsSuccess,
                      mgsPartial,
                      mgsFailure);

  THtmlPageToNavigate = (hpnCashBookStartCache,
                         hpnCashBookDetailCache);

  //----------------------------------------------------------------------------
  THttpHeaders = record
    ContentType: string;
    Accept: string;
    Authorization: string;
    MyobApiAccessToken: string;
  end;

  //----------------------------------------------------------------------------
  TMappingData = class(TCollectionItem)
  private
    fOrigCode : string;
    fNewCode : string;
    fAccountIndex : integer;
  public
    property OrigCode : string read fOrigCode write fOrigCode;
    property NewCode : string read fNewCode write fNewCode;
    property AccountIndex : integer read fAccountIndex write fAccountIndex;
  end;

  //----------------------------------------------------------------------------
  TMappingsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TMappingData;

    procedure GetMappingFromClient(aClient : TClientObj);
    function UpdateSysCode(aOrigCode : string) : string;
    function UpdateContraCode(aOrigCode : string; aAccountIndex : integer) : string;
    procedure AddDuplicateReplacementChartCodes(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData);
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
    fCurrentMyDotUser : string;

    fClientTimeFrameStart : TStDate;
    fMappingsData : TMappingsData;
    fClientMigrationState : TClientMigrationState;
    fCurrentCBClientCode : string;

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

    function LoadBrowserCashFile(aFileName : string) : boolean;
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

    function GetCashBookGSTType(aGSTMapCol : TGSTMapCol; aGSTClassId : byte) : string;

    function GetTimeFrameStart(aFinancialYearStart : TStDate) : TStDate;
    procedure AddCommentToClient(aClientLRN : integer; aNote : string);
    function ValidateIRDGST(aValue : string; var aModifiedIRD : string) : boolean;
    function FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aError : string) : boolean;

    function FillBusinessData(aClient : TClientObj; aBusinessData : TBusinessData; aFirmId : string; aClosingBalanceDate: TStDate; aDoChartOfAccountBalances : boolean; var aError : string) : boolean;
    function FillBankFeedData(aClient : TClientObj; aBankFeedApplicationsData : TBankFeedApplicationsData; aDoMoveRatherThanCopy : boolean; var aError : string) : boolean;
    function FillDivisionData(aClient : TClientObj; aDivisionsData : TDivisionsData; var aUsedDivisions : TStringList; var aError : string) : boolean;
    function FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aSelectedData: TSelectedData; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; aNoTransactions : boolean; var aError : string) : boolean;
    function FillTransactionData(aClient : TClientObj; aBankAccountsData : TBankAccountsData; aChartOfAccountsData : TChartOfAccountsData; aGSTMapCol : TGSTMapCol; var aNoTransactions : boolean; var aError : string) : boolean;
    function FillJournalData(aClient : TClientObj; aJournalsData : TJournalsData; var aError : string) : boolean;

    // this is to fix the wierd Allocation rule where the sum of all allocation ammounts must be positive
    procedure FixAllocationValues(aAllocationsData : TAllocationsData);
    function CalculateClosingBalanceDate(aClient : TClientObj) : TStDate;

    function UploadClient(aClientBase : TClientBase; aSelectedData: TSelectedData; var aError: string): boolean;

    function MigrateClient(aClient : TClientObj; aSelectedData: TSelectedData; var aError: string): boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure MarkSelectedClients(aFileStatus: Byte; aSelectClients : TStringList);
    procedure MarkSelectClient(aFileStatus: Byte; aClientCode : string);

    function Login(const aEmail: string; const aPassword: string; var aError : string; var aInvalidPass : boolean): boolean;

    function GetFirms(var aFirms: TFirms; var aError: string): boolean;

    function MigrateClients(aSelectClients : TStringList;
                            aSelectedData : TSelectedData;
                            var aClientErrors : TStringList;
                            var aNumErrorClients : integer) : TMigrationStatus;

    property OnProgressEvent : TProgressEvent read fProgressEvent write fProgressEvent;
    property MappingsData : TMappingsData read fMappingsData write fMappingsData;
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
  LockUtils,
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
  baObj32,
  CalculateAccountTotals,
  iniSettings,
  Bk5Except,
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

  CASHBOOK_SYSTEM_ACCOUNTS : Array[0..6] of string =
    ('2-2200','2-2400','3-1600','3-1800','3-8000','3-8001','3-9999');

var
  fCashbookMigration: TCashbookMigration;
  DebugMe : boolean = false;

{ TMappingsData }
//------------------------------------------------------------------------------
function TMappingsData.ItemAs(aIndex: integer): TMappingData;
begin
  Result := TMappingData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TMappingsData.AddDuplicateReplacementChartCodes(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData);
var
  NewChartItem : TChartOfAccountData;
  MapIndex : integer;
  BankAccount : TBank_Account;
begin
  for MapIndex := 0 to Count - 1 do
  begin
    if ItemAs(MapIndex).AccountIndex > -1 then
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(ItemAs(MapIndex).AccountIndex);

      NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
      NewChartItem.Code := ItemAs(MapIndex).NewCode;
      NewChartItem.Name := 'Duplicate contra code from migration ' +
                            BankAccount.baFields.baBank_Account_Number + ' ' +
                            BankAccount.baFields.baBank_Account_Name;
      NewChartItem.InActive := true;
      NewChartItem.PostingAllowed := true;
      NewChartItem.Divisions := '';
      NewChartItem.AccountType := GetMigrationMappedReportGroupCode(ccAsset);
      NewChartItem.GstType := 'NA';
      NewChartItem.OrigAccountType := '';
      NewChartItem.OrigGstType := '';
      NewChartItem.OpeningBalance := 0;
      NewChartItem.BankOrCreditFlag := true;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TMappingsData.GetMappingFromClient(aClient: TClientObj);
var
  SysIndex : integer;
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  MappingItem : TMappingData;
  Duplicates : TStringList;
  AccountIndex : integer;
  BankAccount : TBank_Account;
  FoundIndex : integer;
  Value : integer;

  //----------------------------------------------------------------------------
  function GetNewCode(aOldCode : string) : string;
  var
    FoundAccRec : tAccount_Rec;
    Suffix : integer;
  begin
    Suffix := 1;

    while (aClient.clChart.FindCode(aOldCode + '-' + inttostr(Suffix)) <> nil) do
      inc(Suffix);

    Result := aOldCode + '-' + inttostr(Suffix);
  end;
begin
  Clear;

  Duplicates := TStringList.Create();
  try
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);

      if trim(BankAccount.baFields.baContra_Account_Code ) = '' then
        Continue;

      if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
         not (BankAccount.baFields.baIs_A_Manual_Account) then
      begin
        if Duplicates.find(BankAccount.baFields.baContra_Account_Code, FoundIndex) then
        begin
          Value := Integer(Duplicates.Objects[FoundIndex]);
          inc(Value);
          Duplicates.Objects[FoundIndex] := TObject(Value);

          MappingItem := TMappingData.Create(self);
          MappingItem.OrigCode := BankAccount.baFields.baContra_Account_Code;
          MappingItem.NewCode  := BankAccount.baFields.baContra_Account_Code + '.' + inttostr(Value);
          MappingItem.AccountIndex := AccountIndex;
        end
        else
          Duplicates.AddObject(BankAccount.baFields.baContra_Account_Code , TObject(1));
      end;
    end;
  finally
    FreeAndNil(Duplicates);
  end;

  for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
  begin
    AccRec := aClient.clChart.Account_At(ChartIndex)^;
    for SysIndex := Low(CASHBOOK_SYSTEM_ACCOUNTS) to High(CASHBOOK_SYSTEM_ACCOUNTS) do
    begin
      if trim(AccRec.chAccount_Code) = CASHBOOK_SYSTEM_ACCOUNTS[SysIndex] then
      begin
        MappingItem := TMappingData.Create(self);
        MappingItem.OrigCode := AccRec.chAccount_Code;
        MappingItem.NewCode  := GetNewCode(AccRec.chAccount_Code);
        MappingItem.AccountIndex := -1;
        break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMappingsData.UpdateSysCode(aOrigCode: string): string;
var
  MapIndex : integer;
begin
  Result := aOrigCode;

  for MapIndex := 0 to Count-1 do
  begin
    if (ItemAs(MapIndex).OrigCode = aOrigCode) and
       (ItemAs(MapIndex).AccountIndex = -1) then
    begin
      Result := ItemAs(MapIndex).NewCode;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMappingsData.UpdateContraCode(aOrigCode: string; aAccountIndex: integer): string;
var
  MapIndex : integer;
begin
  Result := aOrigCode;

  for MapIndex := 0 to Count-1 do
  begin
    if (ItemAs(MapIndex).OrigCode = aOrigCode) and
       (ItemAs(MapIndex).AccountIndex = aAccountIndex) then
    begin
      Result := ItemAs(MapIndex).NewCode;
      Exit;
    end;
  end;
end;

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
function TCashbookMigration.LoadBrowserCashFile(aFileName: string): boolean;
begin
  {FileLocking.ObtainLock( ltPracIni, TimeToWaitForPracINI );
  try
    WritePracticeINI;
  finally
    FileLocking.ReleaseLock( ltPracIni );
  end;

  AdminIsLocked := FileLocking.ObtainLock( ltAdminSystem, PRACINI_TicksToWaitForAdmin div 1000 );

  Globals.HtmlCashe + aFileName}
end;

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
  {if ABytesTransferred > fClientDataSize then
    Percent := 100
  else
    Percent := trunc(ABytesTransferred / fClientDataSize);

  if Assigned(fProgressEvent) then
  begin
    fProgressEvent(fCurrentClient-1, fClientCount, Percent);
  end;   }
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
function TCashbookMigration.GetCashBookGSTType(aGSTMapCol : TGSTMapCol; aGSTClassId : byte): string;
var
  GSTClassTypeIndicator : byte;
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
  GSTMapItem : TGSTMapItem;
  GSTClass : TCashBookGSTClasses;
begin
  CashBookGstClassCode := '';
  if (AdminSystem.fdFields.fdCountry = whAustralia) then
  begin
    if aGSTMapCol.ItemAtGstIndex(aGSTClassId, GSTMapItem) then
      CashBookGstClassCode := aGSTMapCol.GetGSTClassCode(GSTMapItem.CashbookGstClass)
    else
      CashBookGstClassCode := aGSTMapCol.GetGSTClassCode(cgNone);
  end
  else if (AdminSystem.fdFields.fdCountry = whNewZealand) then
  begin
    GSTClassTypeIndicator := GetGSTClassTypeIndicatorFromGSTClass(aGSTClassId);
    GSTClass := GetMappedNZGSTTypeCode(GSTClassTypeIndicator);
    GetMYOBCashbookGSTDetails(GSTClass, CashBookGstClassCode, CashBookGstClassDesc);
  end;
  Result := CashBookGstClassCode;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.GetTimeFrameStart(aFinancialYearStart: TStDate): TStDate;
var
  FinDay, FinMonth, FinYear : Integer;
  CurrDay, CurrMonth, CurrYear : Integer;
  CurrYearFinDate : TStDate;
  StartYear : integer;
begin
  StDateToDMY(aFinancialYearStart, FinDay, FinMonth, FinYear);
  StDateToDMY(CurrentDate, CurrDay, CurrMonth, CurrYear);

  CurrYearFinDate := DMYToSTDate( FinDay, FinMonth, CurrYear, BKDATEEPOCH);
  if CurrentDate > CurrYearFinDate then
    StartYear := CurrYear - 1
  else
    StartYear := CurrYear - 2;

  Result := DMYToSTDate( FinDay, FinMonth, StartYear, BKDATEEPOCH);
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

  try
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
  except
    on E: Exception do
    begin
      aError := E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoUploadHttpSecure(const aVerb, aURL: string; const aHeaders: THttpHeaders;
                                               const aRequest: string; var aResponse, aError: string): boolean;
const
  CRLF = #13#10;
begin
  Result := false;

  try
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
  except
    on E: Exception do
    begin
      aError := E.Message;
      exit;
    end;
  end;
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
procedure TCashbookMigration.FixAllocationValues(aAllocationsData : TAllocationsData);
var
  AllocationIndex : integer;
  SumValue : integer;
begin
  SumValue := 0;
  for AllocationIndex := 0 to aAllocationsData.Count - 1 do
  begin
    SumValue := SumValue + (aAllocationsData.ItemAs(AllocationIndex).Amount -
                            aAllocationsData.ItemAs(AllocationIndex).TaxAmount);
    SumValue := SumValue + aAllocationsData.ItemAs(AllocationIndex).TaxAmount;
  end;

  if SumValue < 0 then
  begin
    for AllocationIndex := 0 to aAllocationsData.Count - 1 do
    begin
      aAllocationsData.ItemAs(AllocationIndex).Amount := -aAllocationsData.ItemAs(AllocationIndex).Amount;
      aAllocationsData.ItemAs(AllocationIndex).TaxAmount := -aAllocationsData.ItemAs(AllocationIndex).TaxAmount;
    end;
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
        fNumCodeReplaced := 0;

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
function TCashbookMigration.FillBusinessData(aClient: TClientObj; aBusinessData: TBusinessData; aFirmId : string; aClosingBalanceDate: TStDate; aDoChartOfAccountBalances : boolean; var aError: string): boolean;
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
    fCurrentCBClientCode := ClientCode;
    aBusinessData.OrigClientCode := aClient.clFields.clCode;
    aBusinessData.Name := aClient.clFields.clName;
    aBusinessData.FinancialYearStartMonth := FYSmonth;
    aBusinessData.ABN := ABN;
    aBusinessData.IRD := IRD;

    OpenBalDate := IncDate(aClosingBalanceDate, 1, 0, 0);
    if (OpenBalDate = BadDate) or
       (not aDoChartOfAccountBalances) then
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
function TCashbookMigration.FillBankFeedData(aClient: TClientObj; aBankFeedApplicationsData: TBankFeedApplicationsData; aDoMoveRatherThanCopy : boolean; var aError: string): boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  BankFeedApplicationData : TBankFeedApplicationData;
  AccountIndex : integer;
  BankAccount : TBank_Account;
begin
  Result := false;
  try
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);
      if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
         not (BankAccount.baFields.baIs_A_Manual_Account) then
      begin
        for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
        begin
          AccRec := aClient.clChart.Account_At(ChartIndex)^;

          if BankAccount.baFields.baContra_Account_Code = AccRec.chAccount_Code then
          begin
            if BankAccount.baFields.baCore_Account_ID = 0 then
            begin
              LogUtil.LogMsg(lmInfo, UnitName, 'No CoreAccountId for Client Code : ' + aClient.clFields.clCode +
                                               ', Bank Account : ' + BankAccount.baFields.baBank_Account_Number +
                                               '. Not sending bank feed.');
              Continue;
            end;

            BankFeedApplicationData := TBankFeedApplicationData.Create(aBankFeedApplicationsData);
            if AdminSystem.fdFields.fdCountry = whAustralia then
              BankFeedApplicationData.CountryCode := 'OZ'
            else
              BankFeedApplicationData.CountryCode := 'NZ';

            BankFeedApplicationData.CoreClientCode := AdminSystem.fdFields.fdBankLink_Code;

            BankFeedApplicationData.BankAccountNumber :=  MappingsData.UpdateContraCode(AccRec.chAccount_Code, AccountIndex);
            BankFeedApplicationData.BankAccountNumber := MappingsData.UpdateSysCode(BankFeedApplicationData.BankAccountNumber);

            BankFeedApplicationData.CoreAccountId := inttostr(BankAccount.baFields.baCore_Account_ID);

            if aDoMoveRatherThanCopy then
              BankFeedApplicationData.Operation := 'MOVE'
            else
              BankFeedApplicationData.Operation := 'COPY';
          end;
        end;
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
function TCashbookMigration.FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aSelectedData: TSelectedData; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; aNoTransactions : boolean; var aError : string) : boolean;
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
  ChartExportFound : boolean;
  MigrationClosingBalance : integer;
  AccountIndex : integer;
  BankAccount : TBank_Account;
  SendChart : boolean;

  //----------------------------------------------------------------------------
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

      SendChart := true;
      if not aSelectedData.ChartOfAccount then
      begin
        SendChart := false;
        for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
        begin
          BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);
          if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
             not (BankAccount.baFields.baIs_A_Manual_Account) then
          begin
            if BankAccount.baFields.baContra_Account_Code =  AccRec.chAccount_Code then
            begin
              SendChart := true;
              Break;
            end;
          end;
        end;
      end;

      if not SendChart then
        Continue;

      ChartExportFound := aChartExportCol.ItemAtCode(AccRec.chAccount_Code, ChartExportItem);
      if ChartExportFound then
      begin
        if aSelectedData.ChartOfAccountBalances then
          MigrationClosingBalance := GetMigrationClosingBalance(ChartExportItem.ClosingBalance)
        else
          MigrationClosingBalance := 0;
      end
      else
        MigrationClosingBalance := 0;

      if (AccRec.chTemp_Tag = TEMP_TAG_MANUAL_ADDED_GST) and
        (MigrationClosingBalance = 0) then
        Continue;

      NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
      NewChartItem.Code := MappingsData.UpdateSysCode(AccRec.chAccount_Code);
      NewChartItem.Name := AccRec.chAccount_Description;

      if length(trim(NewChartItem.Name)) = 0 then
        NewChartItem.Name := NewChartItem.Code;

      NewChartItem.InActive := AccRec.chInactive;
      NewChartItem.PostingAllowed := AccRec.chPosting_Allowed;
      NewChartItem.Divisions := GetValidDivisions();

      if ChartExportFound then
      begin
        MappedGroupId := aChartExportCol.GetMappedReportGroupId(ChartExportItem.ReportGroupId);

        NewChartItem.OrigAccountType := atNames[AccRec.chAccount_Type];
        NewChartItem.OrigGstType := trim(aClient.clFields.clGST_Class_Codes[ AccRec.chGST_Class ] + ' ' +
                                         aClient.clFields.clGST_Class_Names[ AccRec.chGST_Class]);
        NewChartItem.AccountType := GetMigrationMappedReportGroupCode(MappedGroupId);

        NewChartItem.GstType := GetCashBookGSTType(aGSTMapCol, ChartExportItem.GSTClassId);
        NewChartItem.OpeningBalance := MigrationClosingBalance;
        NewChartItem.BankOrCreditFlag := IsChartCodeABankContra(AccRec.chAccount_Code);
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

      for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
      begin
        BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);
        if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
           not (BankAccount.baFields.baIs_A_Manual_Account) then
        begin
          if BankAccount.baFields.baContra_Account_Code = AccRec.chAccount_Code then
          begin
            if not (NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccAsset)) or
                   (NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccLiabilities)) then
              NewChartItem.AccountType := GetMigrationMappedReportGroupCode(ccAsset);
          end;
        end;
      end;
    end;

    // Add Uncoded Chart
    if not aNoTransactions then
    begin
      NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
      NewChartItem.Code := 'UNCODED';
      NewChartItem.Name := 'Invalid code from migration';
      NewChartItem.InActive := true;
      NewChartItem.PostingAllowed := true;
      NewChartItem.Divisions := '';
      NewChartItem.AccountType := 'uncategorised';
      NewChartItem.GstType := 'NA';
      NewChartItem.OrigAccountType := '';
      NewChartItem.OrigGstType := '';
      NewChartItem.OpeningBalance := 0;
      NewChartItem.BankOrCreditFlag := false;
    end;

    MappingsData.AddDuplicateReplacementChartCodes(aClient, aChartOfAccountsData);

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
function TCashbookMigration.FillTransactionData(aClient: TClientObj; aBankAccountsData: TBankAccountsData; aChartOfAccountsData : TChartOfAccountsData; aGSTMapCol : TGSTMapCol; var aNoTransactions : boolean; var aError: string): boolean;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  TransactionItem : TTransactionData;
  BankAccountItem : TBankAccountData;
  AllocationItem : TAllocationData;
  ChartOfAccountItem : TChartOfAccountData;
  BankAccount : TBank_Account;
  TransactionRec : tTransaction_Rec;
  AccRec : pAccount_Rec;
  DissRec: pDissection_Rec;
  AccountCode : string;
begin
  Result := false;
  aNoTransactions := true;
  try
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);

      // Don't send Journals as Transactions
      if (not BankAccount.IsAJournalAccount ) then
      begin
        BankAccountItem := TBankAccountData.Create(aBankAccountsData);

        AccRec := aClient.clChart.FindCode(BankAccount.baFields.baContra_Account_Code);
        if Assigned(AccRec) then
        begin
          BankAccountItem.BankAccountNumber :=
            MappingsData.UpdateContraCode(BankAccount.baFields.baContra_Account_Code, AccountIndex);
          BankAccountItem.BankAccountNumber :=
            MappingsData.UpdateSysCode(BankAccountItem.BankAccountNumber);
        end
        else
          BankAccountItem.BankAccountNumber := '';

        for TransactionIndex := BankAccount.baTransaction_List.ItemCount-1 downto 0 do
        begin
          TransactionRec := BankAccount.baTransaction_List.Transaction_At(TransactionIndex)^;

          // if Transaction is older than Time Frame ignore the rest since we are going back in time.
          if TransactionRec.txDate_Effective < fClientTimeFrameStart then
            break;

          // Check if Transaction is not finalized and not presented
          if (TransactionRec.txDate_Transferred > 0) then
            break;

          aNoTransactions := false;

          TransactionItem := TTransactionData.Create(BankAccountItem.Transactions);
          TransactionItem.Date        := StDateToDateString('yyyy-mm-dd', TransactionRec.txDate_Effective, true);
          TransactionItem.Description := TransactionRec.txStatement_Details;
          TransactionItem.Amount      := trunc(TransactionRec.txAmount);
          TransactionItem.Reference   := TransactionRec.txReference;

          if BankAccount.baTransaction_List.GetTransCoreID_At(TransactionIndex) > 0 then
            TransactionItem.CoreTransactionId := inttostr(BankAccount.baTransaction_List.GetTransCoreID_At(TransactionIndex))
          else
            TransactionItem.CoreTransactionId := '';

          // Dissection
          DissRec := TransactionRec.txFirst_Dissection;
          if DissRec <> nil then
          begin
            While (DissRec <> nil ) do
            begin
              AllocationItem := TAllocationData.Create(TransactionItem.Allocations);

              {if (trim(DissRec^.dsAccount) = '') then
              begin
                if (trim(TransactionRec.txAccount) = '') then
                  AllocationItem.AccountNumber := ''
                else
                begin
                  AccRec := MyClient.clChart.FindCode( TransactionRec.txAccount );
                  if not Assigned(AccRec) then
                    AllocationItem.AccountNumber := ''
                  else
                    AllocationItem.AccountNumber := MappingsData.UpdateCode(TransactionRec.txAccount);
                end;
              end
              else
              begin
                AccRec := MyClient.clChart.FindCode( DissRec^.dsAccount );
                if not Assigned(AccRec) then
                  AllocationItem.AccountNumber := ''
                else
                  AllocationItem.AccountNumber := MappingsData.UpdateCode(DissRec^.dsAccount);
              end; }

              if (trim(TransactionRec.txAccount) = '') then
                AllocationItem.AccountNumber := ''
              else
              begin
                AccRec := MyClient.clChart.FindCode( DissRec^.dsAccount );
                if not Assigned(AccRec) then
                  AllocationItem.AccountNumber := ''
                else
                  AllocationItem.AccountNumber := MappingsData.UpdateSysCode(DissRec^.dsAccount);
              end;

              {if trim(DissRec^.dsGL_Narration) = '' then
                AllocationItem.Description := TransactionRec.txGL_Narration
              else
                AllocationItem.Description := DissRec^.dsGL_Narration;

              if trim(DissRec^.dsReference) = '' then
                AllocationItem.Reference := TransactionRec.txReference
              else
                AllocationItem.Reference := DissRec^.dsReference;}

              AllocationItem.Description := DissRec^.dsGL_Narration;
              AllocationItem.Amount := trunc(DissRec^.dsAmount);
              AllocationItem.TaxAmount := trunc(DissRec^.dsGST_Amount);

              AllocationItem.TaxRate := GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);

              DissRec := DissRec^.dsNext;
            end;
          end
          else
          begin
            if (trim(TransactionRec.txAccount) = '') and
               (TransactionRec.txHas_Been_Edited = false) then
              Continue;

            AllocationItem := TAllocationData.Create(TransactionItem.Allocations);

            if (trim(TransactionRec.txAccount) = '') then
              AllocationItem.AccountNumber := ''
            else
            begin
              AccRec := MyClient.clChart.FindCode( TransactionRec.txAccount );
              if not Assigned(AccRec) then
                AllocationItem.AccountNumber := ''
              else
                AllocationItem.AccountNumber := MappingsData.UpdateSysCode(TransactionRec.txAccount);
            end;

            AllocationItem.Description := TransactionRec.txGL_Narration;
            AllocationItem.Amount := trunc(TransactionRec.txAmount);
            AllocationItem.TaxAmount := trunc(TransactionRec.txGST_Amount);
            AllocationItem.TaxRate := GetCashBookGSTType(aGSTMapCol, TransactionRec.txGST_Class);
          end;

          if TransactionItem.Allocations.Count > 0 then
            FixAllocationValues(TransactionItem.Allocations);
        end;
      end;
    end;
    Result := true;

  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Transactions : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillJournalData(aClient: TClientObj; aJournalsData: TJournalsData; var aError: string): boolean;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  JournalItem : TJournalData;
  LineItem : TLineData;
  ChartOfAccountItem : TChartOfAccountData;
  BankAccount : TBank_Account;
  TransactionRec : tTransaction_Rec;
  AccRec : pAccount_Rec;
  DissRec: pDissection_Rec;
begin
  Result := false;
  try
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);

      // Don't send Journals as Transactions
      if (BankAccount.baFields.baAccount_Type in [btCashJournals, btAccrualJournals]) then
      begin
        for TransactionIndex := BankAccount.baTransaction_List.ItemCount-1 downto 0 do
        begin
          TransactionRec := BankAccount.baTransaction_List.Transaction_At(TransactionIndex)^;

          // if Transaction is older than Time Frame ignore the rest since we are going back in time.
          if TransactionRec.txDate_Effective < fClientTimeFrameStart then
            break;

          // Check if Transaction is not finalized and not presented
          if (TransactionRec.txDate_Transferred > 0) then
            break;

          JournalItem := TJournalData.Create(aJournalsData);
          JournalItem.Date := StDateToDateString('yyyy-mm-dd', TransactionRec.txDate_Effective, true);
          JournalItem.Description := TransactionRec.txStatement_Details;

          {LineItem := TLineData.Create(JournalItem.Lines);

          AccRec := MyClient.clChart.FindCode( TransactionRec.txAccount );
          if Assigned(AccRec) then
            LineItem.AccountNumber := MappingsData.UpdateCode(TransactionRec.txAccount)
          else
            LineItem.AccountNumber := '';

          LineItem.Amount := trunc(TransactionRec.txAmount);
          if trunc(TransactionRec.txAmount) < 0 then
            LineItem.IsCredit := false
          else
            LineItem.IsCredit := true;}

          DissRec := TransactionRec.txFirst_Dissection;
          While (DissRec <> nil ) do
          begin
            LineItem := TLineData.Create(JournalItem.Lines);

            if trim(DissRec^.dsAccount) = '' then
              LineItem.AccountNumber := TransactionRec.txAccount
            else
              LineItem.AccountNumber := DissRec^.dsAccount;
            AccRec := MyClient.clChart.FindCode( LineItem.AccountNumber );
            if not Assigned(AccRec) then
              LineItem.AccountNumber := '';

            LineItem.Amount := abs(trunc(DissRec^.dsAmount));
            if trunc(DissRec^.dsAmount) < 0 then
              LineItem.IsCredit := false
            else
              LineItem.IsCredit := true;

            DissRec := DissRec^.dsNext;
          end;
        end;
      end;
    end;
    Result := true;

  except
    on E: Exception do
    begin
      aError := 'Exception retrieving Journals : ' + E.Message;
      exit;
    end;
  end;
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

  fClientMigrationState := cmsTransformData;
  MigUpload := TMigrationUpload.Create;
  try
    Data := aClientBase.GetData(aSelectedData);

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Business Json : ' + Data);

    MigUpload.Files.Data := Data;
    MigUpload.Files.FileName := 'Test.json';
    MigUpload.Parameters.DataStore := PRACINI_CashbookAPIUploadDataStore;
    MigUpload.Parameters.Queue := PRACINI_CashbookAPIUploadQueue;
    MigUpload.Parameters.BLIdentity := CurrUser.Code + '/' + fCurrentMyDotUser;

    MigUpload.Parameters.Region := inttostr(ord(AdminSystem.fdFields.fdCountry));
    try
      // Request
      Request := TlkJSONobject.Create;
      try
        MigUpload.Write(Request);

        // HTTP
        sURL := PRACINI_CashbookAPIUploadURL;

        fClientMigrationState := cmsConnectToAPI;
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
          fClientMigrationState := cmsUploadError;
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
      fClientMigrationState := cmsAccessCltDB;

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
procedure TCashbookMigration.MarkSelectedClients(aFileStatus: Byte; aSelectClients : TStringList);
const
  ThisMethodName = 'TCashbookMigration.MarkSelectedClients';
var
  SelIndex : integer;
  Code : string;
  CFRec : pClient_File_Rec;
begin
  LoadAdminSystem( true, ThisMethodName);
  for SelIndex := 0 to aSelectClients.Count - 1 do
  begin
    Code := aSelectClients.Strings[SelIndex];
    CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code);

    if not Assigned( CFRec) then
      Raise EAdminSystem.Create( 'Could not find CFRec for ' + Code + ' [' + ThisMethodName + ']');

    if aFileStatus = ord(fsNormal) then
      CFRec.cfCurrent_User := 0
    else
      CFRec.cfCurrent_User := CurrUser.LRN;

    CFRec.cfFile_Status := aFileStatus;
  end;
  SaveAdminSystem;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.MarkSelectClient(aFileStatus: Byte; aClientCode : string);
const
  ThisMethodName = 'TCashbookMigration.MarkSelectClient';
var
  SelIndex : integer;
  CFRec : pClient_File_Rec;
begin
  LoadAdminSystem( true, ThisMethodName);

  CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( aClientCode);

  if not Assigned( CFRec) then
    Raise EAdminSystem.Create( 'Could not find CFRec for ' + aClientCode + ' [' + ThisMethodName + ']');

  if aFileStatus = ord(fsNormal) then
    CFRec.cfCurrent_User := 0
  else
    CFRec.cfCurrent_User := CurrUser.LRN;

  CFRec.cfFile_Status := aFileStatus;

  SaveAdminSystem;
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
  NoTransactions : boolean;
begin
  result := false;
  NoTransactions := true;

  // pre calculate Time frame start used later in Transactions and Journals
  fClientTimeFrameStart := GetTimeFrameStart(aClient.clFields.clFinancial_Year_Starts);
  MappingsData.GetMappingFromClient(aClient);
  CalculateAccountTotals.AddAutoContraCodes( aClient, false, true);
  try
    ClientBase := TClientBase.Create;
    try
      ClientBase.Token := fToken;

      {if GetLastFullyCodedMonth(BalDate) then
        ClosingBalanceDate := BalDate
      else
        ClosingBalanceDate := BkNull2St(MyClient.clFields.clPeriod_End_Date);}

      ClosingBalanceDate := CalculateClosingBalanceDate(aClient);

      fClientMigrationState := cmsTransformData;
      if not FillBusinessData(aClient, ClientBase.ClientData.BusinessData, aSelectedData.FirmId, ClosingBalanceDate, aSelectedData.ChartOfAccountBalances, aError) then
        Exit;

      if not FillBankFeedData(aClient, ClientBase.ClientData.BankFeedApplicationsData, aSelectedData.DoMoveRatherThanCopy, aError) then
        Exit;
      fClientMigrationState := cmsAccessCltDB;

      ChartExportCol := TChartExportCol.Create(TChartExportItem);
      try
        ChartExportCol.FillChartExportCol(true);
        ChartExportCol.UpdateClosingBalances(ClosingBalanceDate);
        GSTMapCol := TGSTMapCol.Create(TGSTMapItem);
        try
          GSTMapCol.FillGstClassMapArr;
          FillGstMapCol(ChartExportCol, GSTMapCol);

          if aSelectedData.NonTransferedTransactions then
          begin
            fClientMigrationState := cmsTransformData;
            if not FillTransactionData(aClient, ClientBase.ClientData.BankAccountsData, ClientBase.ClientData.ChartOfAccountsData, GSTMapCol, NoTransactions, aError) then
              Exit;

            if not FillJournalData(aClient, ClientBase.ClientData.JournalsData, aError) then
              Exit;
            fClientMigrationState := cmsAccessCltDB;
          end;

          fClientMigrationState := cmsTransformData;
          UsedDivisions := TStringList.Create();
          UsedDivisions.Delimiter := ',';
          UsedDivisions.StrictDelimiter := true;
          try
            if aSelectedData.ChartOfAccount then
              if not FillDivisionData(aClient, ClientBase.ClientData.DivisionsData, UsedDivisions, aError) then
                Exit;

            if not FillChartOfAccountData(aClient, ClientBase.ClientData.ChartOfAccountsData, aSelectedData, ChartExportCol, GSTMapCol, UsedDivisions, NoTransactions, aError) then
              Exit;
          finally
            FreeAndNil(UsedDivisions);
          end;
          fClientMigrationState := cmsAccessCltDB;

        finally
          FreeAndNil(GSTMapCol);
        end;
      finally
        FreeAndNil(ChartExportCol);
      end;

      if not UploadClient(ClientBase, aSelectedData, aError) then
        Exit;

      result := true;
    finally
      FreeAndNil(ClientBase);
    end;
  finally
    CalculateAccountTotals.RemoveAutoContraCodes( aClient);
  end;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.AddCommentToClient(aClientLRN : integer; aNote: string);
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

//------------------------------------------------------------------------------
function TCashbookMigration.CalculateClosingBalanceDate(aClient : TClientObj) : TStDate;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  BankAccount : TBank_Account;
  TransactionRec : tTransaction_Rec;
  MostRecentDate : TStDate;
begin
  Result := IncDate(fClientTimeFrameStart, -1, 0, 0);
  MostRecentDate := Result;

  for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);

    // Don't send Journals as Transactions
    if (not BankAccount.IsAJournalAccount ) then
    begin
      for TransactionIndex := BankAccount.baTransaction_List.ItemCount-1 downto 0 do
      begin
        TransactionRec := BankAccount.baTransaction_List.Transaction_At(TransactionIndex)^;

        // if Transaction is older than Time Frame ignore the rest since we are going back in time.
        if TransactionRec.txDate_Effective < fClientTimeFrameStart then
          break;

        if (TransactionRec.txDate_Transferred > 0) then
        begin
          if TransactionRec.txDate_Effective > MostRecentDate then
          begin
            MostRecentDate := TransactionRec.txDate_Effective;
            break;
          end;
        end;
      end;
    end;

    if MostRecentDate > Result then
      Result := MostRecentDate;
  end;
end;

//------------------------------------------------------------------------------
constructor TCashbookMigration.Create;
begin
  // Http
  FHttpRequester := TIpsHTTPS.Create(nil);
  fMappingsData := TMappingsData.Create(TMappingData);
  HttpSetup;

  fCurrentMyDotUser := '';
end;

//------------------------------------------------------------------------------
destructor TCashbookMigration.Destroy;
begin
  // Http
  freeAndNil(fMappingsData);
  FreeAndNil(FHttpRequester);

  inherited;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.Login(const aEmail: string; const aPassword: string; var aError : string; var aInvalidPass : boolean): boolean;
var
  Headers: THttpHeaders;
  PostData: TStringList;
  js: TlkJSONobject;
  sResponse: string;
  sError: string;
  Token : string;
begin
  result := false;
  aInvalidPass := false;

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
        if sError = '151: Bad Request' then
        begin
          aInvalidPass := true;
          sError := 'Email address and/or password is invalid.' + #13#10 + 'Please try again.';
          LogUtil.LogMsg(lmInfo, UnitName, sError);
        end
        else
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

      fCurrentMyDotUser := aEmail;
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
                                           var aClientErrors : TStringList;
                                           var aNumErrorClients : integer) : TMigrationStatus;
var
  ClientIndex : integer;
  CurrentClientCode : string;
  ClientFileCode : string;
  SysClient : pClient_File_Rec;
  CltClient : TClientObj;
  ClientLRN : integer;
  ErrorStr  : string;
  ErrorIndex : integer;
  NumErrorClients : integer;
  LastClientIndex : integer;
  DiffDispString : string;
begin
  // Initialize ErrorList and progress event
  fClientMigrationState := cmsAccessSysDB;
  aClientErrors.clear;

  fClientCount := aSelectClients.Count;
  fCurrentClient := 1;
  fClientDataSize := 0;
  fNumCodeReplaced := PRACINI_CashbookModifiedCodeCount;

  // Loop through selected Client Codes
  for ClientIndex := 0 to aSelectClients.Count-1 do
  begin
    fClientMigrationState := cmsAccessSysDB;

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
        aClientErrors.AddObject(ErrorStr, TObject(ClientIndex));
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      if not AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status = bkConst.fsNormal then
      begin
        ErrorStr := CurrentClientCode + ' Error with Client, it is not in the correct status. ' +
                    'Current Status : ' + fsNames[AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status] +
                    ' needs to be in normal status.';
        aClientErrors.AddObject(ErrorStr, TObject(ClientIndex));
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      ClientFileCode := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode).cfFile_Code;

      fClientMigrationState := cmsAccessCltDB;
      CltClient := nil;

      MarkSelectClient(ord(fsNormal), ClientFileCode);

      OpenAClient(ClientFileCode, CltClient, true, true);

      if not Assigned(CltClient) then
      begin
        ErrorStr := CurrentClientCode + ' Error opening Client file.';
        aClientErrors.AddObject(ErrorStr, TObject(ClientIndex));
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      MyClient := CltClient;
      try
        Screen.Cursor := crHourglass;

        if not MigrateClient(CltClient, aSelectedData, ErrorStr) then
        begin
          ErrorStr := CurrentClientCode + ' ' + ErrorStr;
          aClientErrors.AddObject(ErrorStr, TObject(ClientIndex));
          LogUtil.LogMsg(lmError, UnitName, ErrorStr);
          Continue;
        end
        else
        begin
          fClientMigrationState := cmsAccessCltDB;
          DiffDispString := '';
          if fCurrentCBClientCode <> CltClient.clFields.clCode then
            DiffDispString := ' as ' +  fCurrentCBClientCode;

          AddCommentToClient(ClientLRN, StDateToDateString('dd/mm/yyyy', CurrentDate(), true) +
                                        ' Migrated to ' + BRAND_CASHBOOK_NAME + DiffDispString);

          CltClient.clMoreFields.mcArchived := true;
          CltClient.clFields.clFile_Save_Required := true;
          SaveAClient(CltClient);

          fClientMigrationState := cmsAccessSysDB;
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
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);

        case fClientMigrationState of
          cmsAccessSysDB   : ErrorStr := Format('Error Accessing System Database %s could not be accessed.', [CurrentClientCode]);
          cmsAccessCltDB   : ErrorStr := Format('Error Accessing Current Client %s could not be opened.', [CurrentClientCode]);
          cmsTransformData : ErrorStr := Format('%s data could not be migrated, please contact Support.', [CurrentClientCode]);
          cmsConnectToAPI  : ErrorStr := Format('Process was interrupted %s was interrupted during upload, please try again.', [CurrentClientCode]);
          cmsUploadError   : ErrorStr := Format('Error Uploading Data %s could not be uploaded to Cashbook.', [CurrentClientCode]);
        end;
        aClientErrors.AddObject(ErrorStr, TObject(ClientIndex));

        Continue;
      end;
    end;

    if Assigned(fProgressEvent) then
      fProgressEvent(ClientIndex+1, aSelectClients.Count, 100);
  end;

  RefreshHomepage([HPR_Tasks]);

  LastClientIndex := -1;
  aNumErrorClients := 0;
  for ErrorIndex := 0 to aClientErrors.Count-1 do
  begin
    if LastClientIndex <> Integer(aClientErrors.Objects[ErrorIndex]) then
    begin
      LastClientIndex := Integer(aClientErrors.Objects[ErrorIndex]);
      inc(aNumErrorClients);
    end;
  end;

  if PRACINI_CashbookModifiedCodeCount <> fNumCodeReplaced then
  begin
    PRACINI_CashbookModifiedCodeCount := fNumCodeReplaced;
    WritePracticeINI_WithLock;
  end;

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
