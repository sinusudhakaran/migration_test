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
  clObj32,
  ipshttps;

const
  PUBLIC_KEY_FILE_CASHBOOK_TOKEN = 'PublicKeyBLO.pke';

type
  //----------------------------------------------------------------------------
  TProgressEvent = procedure (aCurrentFile : integer;
                              aTotalFiles : integer) of object;

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
  TSelectedData = record
    FirmId : string;
    Bankfeeds : boolean;
    ChartOfAccount : boolean;
    ChartOfAccountBalances : boolean;
    NonTransferedTransactions : boolean;
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

  protected
    procedure LogHttpDebugSend(aCall : string;
                               aHeaders: THttpHeaders;
                               aPostData: TStringList); overload;
    procedure LogHttpDebugSend(aCall : string); overload;
    procedure LogHttpDebugUploadSend(aCall : string); overload;

    procedure LogHttpDebugReponce(aCall : string;
                                  aResponce : string);

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
                              var aError: string): boolean;

    function FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aError : string) : boolean;

    function FillBusinessData(aClient : TClientObj; aBusinessData : TBusinessData; aFirmId : string; var aError : string) : boolean;
    function FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; var aError : string) : boolean;
    function FillTransactionData(aClient : TClientObj; aTransactionsData : TTransactionsData; var aError : string) : boolean;
    function FillJournalData(aClient : TClientObj; aJournalsData : TJournalsData; var aError : string) : boolean;

    function UploadClient(aClientData : TClientData; var aError: string): boolean;

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
  LogUtil,
  StDate,
  strUtils,
  BKDEFS,
  SYDEFS;

const
  UnitName = 'CashbookMigration';
  INIT_VECTOR = '@AT^NK(@YUVK)$#Y';
  CASBOOK_BASE = 'https://burwood.cashbook.us/';
  CASBOOK_API_BASE = CASBOOK_BASE + 'api/';
  CASBOOK_ADCOMMON_BASE = CASBOOK_BASE + 'ADCommon/';
  OAUTH2_BASE = 'https://test.secure.myob.com/oauth2/v1/';
  //URL_BASE = 'http://10.72.20.37/';

  MY_DOT_CONTENT_TYPE = 'application/x-www-form-urlencoded';
  MY_DOT_CLIENT_ID = 'bankLink-practice5';
  MY_DOT_CLEINT_SECRET = 'z1sb6ggkfhlOXip';
  MY_DOT_GRANT_PASSWORD = 'password';
  MY_DOT_GRANT_REFRESH_TOKEN = 'refresh_token';
  MY_DOT_SCOPE = 'AccountantsFramework mydot.contacts.read mydot.assets.read Assets la.global';

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
procedure TCashbookMigration.LogHttpDebugReponce(aCall : string; aResponce: string);
begin
  LogUtil.LogMsg(lmDebug, UnitName, 'Server Respond : ' + aCall);
  LogUtil.LogMsg(lmDebug, UnitName, 'Responce - ' + aResponce);
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
begin

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
  FHttpRequester.Firewallport := 80;
  FHttpRequester.localhost    := 'NZAKL009099V';
  FHttpRequester.proxyport    := 8888;
  FHttpRequester.SSLCertStore := 'MY';
  FHttpRequester.SSLCertStore := 'sstUser';

  FHttpRequester.Config ('SSLSecurityFlags=0x80000000');
  FHttpRequester.Config ('SSLEnabledProtocols=140');
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.EncryptToken(aToken: string);
const
  KEY_DELIMMITER = 'KEY';
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
  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                                             var aResponse: TlkJSONbase; var aRespStr : string;
                                             var aError: string): boolean;
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
    Headers.Authorization := CASHBOOK_AUTH_PREFIX + fUnEncryptedToken;
    Headers.MyobApiAccessToken := fUnEncryptedToken;

    // Body
    if assigned(aRequest) then
      sRequest := TlkJSON.GenerateText(aRequest);

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
function TCashbookMigration.FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aError : string) : boolean;
var
  ClientCode : string;
  TestCode : string;
begin
  Result := false;

  ClientCode := trim(aInClientCode);
  if pos(' ', ClientCode ) > -1 then
  begin
    try
      // Replace spaces with nothing and try find duplicate code in practice
      TestCode := StringReplace(ClientCode, ' ', '', [rfReplaceAll]);
      if Assigned(AdminSystem.fdSystem_Client_File_List.FindCode(TestCode)) then
      begin
        // Replace spaces with underscore and try find duplicate code in practice
        TestCode := StringReplace(ClientCode, ' ', '_', [rfReplaceAll]);
        if Assigned(AdminSystem.fdSystem_Client_File_List.FindCode(TestCode)) then
        begin
          // Replace spaces with dash and try find duplicate code in practice
          TestCode := StringReplace(ClientCode, ' ', '-', [rfReplaceAll]);
          if Assigned(AdminSystem.fdSystem_Client_File_List.FindCode(TestCode)) then
          begin
            //if still found the then error
            aError := 'Error converting Practice Client Code into valid Cashbook Client code';
            Exit;
          end;
        end;
      end;
    except
      on E : Exception do
      begin
        aError := 'Exception converting Practice Client Code into valid Cashbook Client code, Error : ' + E.Message;
        exit;
      end;
    end;

    ClientCode := TestCode;
  end;

  aOutClientCode := ClientCode;
  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillBusinessData(aClient: TClientObj; aBusinessData: TBusinessData; aFirmId : string; var aError: string): boolean;
var
  ClientCode : string;
  FYSday, FYSmonth, FYSyear : integer;
  ABN : string;
  IRD : string;
begin
  Result := false;

  if not FixClientCodeForCashbook(aClient.clFields.clCode, ClientCode, aError) then
    Exit;

  StDateToDMY( aClient.clFields.clFinancial_Year_Starts, FYSday, FYSmonth, FYSyear);

  if AdminSystem.fdFields.fdCountry = whAustralia then
    ABN := LeftStr(aClient.clFields.clGST_Number, 11)
  else
    ABN := '';

  if AdminSystem.fdFields.fdCountry = whNewZealand then
    IRD := aClient.clFields.clGST_Number
  else
    IRD := '';

  aBusinessData.FirmId := aFirmId;
  aBusinessData.ClientCode := ClientCode;
  aBusinessData.Name := aClient.clFields.clName;
  aBusinessData.FinancialYearStartMonth := FYSmonth;
  aBusinessData.ABN := ABN;
  aBusinessData.IRD := IRD;
  aBusinessData.OpeningBalanceDate := '';
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillChartOfAccountData(aClient: TClientObj; aChartOfAccountsData : TChartOfAccountsData; var aError: string): boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  NewChartItem : TChartOfAccountData;
begin
  for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
  begin
    AccRec := aClient.clChart.Account_At(ChartIndex)^;

    NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
    NewChartItem.Number      := AccRec.chAccount_Code;
    NewChartItem.Name        := AccRec.chAccount_Description;
    //NewChartItem.AccountType := AccRec.chAccount_Type;
    //NewChartItem.TaxRate     := AccRec.chGST_Class;
    NewChartItem.OpeningBalance := 0;
    NewChartItem.AccountTypeGroup := '';
    NewChartItem.BankOrCreditFlag := '';
  end;

  Result := true;
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
function TCashbookMigration.UploadClient(aClientData: TClientData; var aError: string): boolean;
var
  Request: TlkJSONobject;
  sURL: string;
  ResponseBase: TlkJSONbase;
  Response: TlkJSONobject;
  RespStr : string;
  UploadDone : boolean;

  MigUpload : TMigrationUpload;
  MigUploadResponce : TMigrationUploadResponce;
begin
  Result := false;
  // FileUpload
  MigUpload := TMigrationUpload.Create;
  MigUpload.Files.Data := aClientData.GetData;

  try
    try
      // Request
      Request := TlkJSONobject.Create;
      MigUpload.Write(Request);

      // HTTP
      sURL := CASBOOK_ADCOMMON_BASE + 'Upload';

      if DebugMe then
        LogHttpDebugSend(sURL);

      UploadDone := DoHttpSecureJson(sURL, Request, ResponseBase, RespStr, aError);

      if DebugMe then
        LogHttpDebugReponce(sURL, RespStr);

      if not UploadDone then
      begin
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      if not (Assigned(Response)) or
         not (Response is TlkJSONobject) then
      begin
        aError := 'Error running CashbookMigration.GetFirms, Error Message : No Responce from Server.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      try
        // Response
        Response := (ResponseBase as TlkJSONobject);

        // Result
        if Assigned(MigUploadResponce) then
        begin
          MigUploadResponce.Read(Response);
          Result := true;
        end;
      finally
        FreeAndNil(Response);
      end;

    except
      on E: Exception do
      begin
        aError := 'Exception running CashbookMigration.GetFirms, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aError);
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
  ClientData : TClientData;
begin
  result := false;

  ClientData := TClientData.Create;
  try
    if not FillBusinessData(aClient, ClientData.BusinessData, aSelectedData.FirmId, aError) then
      Exit;

    if not FillChartOfAccountData(aClient, ClientData.ChartOfAccountsData, aError) then
      Exit;

    if not FillTransactionData(aClient, ClientData.TransactionsData, aError) then
      Exit;

    if not FillJournalData(aClient, ClientData.JournalsData, aError) then
      Exit;

    if not UploadClient(ClientData, aError) then
      Exit;

  finally
    FreeAndNil(ClientData);
  end;

  result := true;
end;

//------------------------------------------------------------------------------
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

      PostData.Values['client_id']     := MY_DOT_CLIENT_ID;
      PostData.Values['client_secret'] := MY_DOT_CLEINT_SECRET;
      PostData.Values['username']      := aEmail;
      PostData.Values['password']      := aPassword;
      PostData.Values['grant_type']    := MY_DOT_GRANT_PASSWORD;
      PostData.Values['scope']         := MY_DOT_SCOPE;

      if DebugMe then
        LogHttpDebugSend('POST (' + OAUTH2_BASE + 'Authorize)',
                         Headers, PostData);
      // Cancelled?
      if not DoHttpSecure(
        'POST',
        OAUTH2_BASE + 'Authorize',
        Headers,
        PostData.DelimitedText,
        sResponse,
        sError) then
      begin
        LogUtil.LogMsg(lmError, UnitName, 'Error running CashbookMigration.Login, Error Message : ' + sError);
        aError := sError;
        exit;
      end;

      if DebugMe then
        LogHttpDebugReponce('POST (' + OAUTH2_BASE + 'Authorize)',
                            sResponse);

      // Parse JSON result
      js := TlkJSON.ParseText(sResponse) as TlkJSONobject;

      if not assigned(js) then
      begin
        aError := 'Error running CashbookMigration.Login, Error Message : No Responce from Server.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      // Get token
      Token := js.GetString('access_token');
      if (Token <> '') then
        EncryptToken(Token)
      else
      begin
        aError := 'Error running CashbookMigration.Login, Error Message : Can not find Access Token in Responce.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      fCashBookUserid := js.GetString('user');
      if (fCashBookUserid = '') then
      begin
        aError := 'Error running CashbookMigration.Login, Error Message : Can not find UserId in Responce.';
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
      sURL := CASBOOK_API_BASE + 'firms';

      if DebugMe then
        LogHttpDebugSend(sURL);

      if not DoHttpSecureJson(sURL, nil, Response, RespStr, aError) then
        exit;

      if DebugMe then
        LogHttpDebugReponce(sURL, RespStr);

      if not (Assigned(Response)) or
         not (Response is TlkJSONlist) then
      begin
        aError := 'Error running CashbookMigration.GetFirms, Error Message : No Responce from Server.';
        LogUtil.LogMsg(lmError, UnitName, aError);
        exit;
      end;

      List := (Response as TlkJSONlist);

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
  SysClient : pClient_File_Rec;
  CltClient : TClientObj;
  ErrorStr : string;
begin
  aClientErrors.clear;

  aClientErrors.Add('error');

  if Assigned(fProgressEvent) then
    fProgressEvent(0, aSelectClients.Count);

  for ClientIndex := 0 to aSelectClients.Count-1 do
  begin
    CurrentClientCode := aSelectClients.Strings[ClientIndex];
    try
      SysClient := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode);

      if not Assigned(SysClient) then
      begin
        ErrorStr := CurrentClientCode + ' ' + 'Error Migrating Client, Error finding Client in System File.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      if not AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status = bkConst.fsNormal then
      begin
        ErrorStr := CurrentClientCode + ' Error Migrating Client, Error with Client, it is not in the correct status. ' +
                    'Current Status : ' + fsNames[AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status] +
                    ' needs to be in normal status.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Code, CltClient);

      if not Assigned(CltClient) then
      begin
        ErrorStr := CurrentClientCode + ' ' + 'Error Migrating Client, Error opening Client file.';
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

      if not MigrateClient(CltClient, aSelectedData, ErrorStr) then
      begin
        ErrorStr := 'Error Migrating Client, ' + ErrorStr;
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;

    except
      on E: Exception do
      begin
        ErrorStr := CurrentClientCode + ' ' + 'Error Migrating Client, Exception opening Client : ' + E.Message;
        aClientErrors.Add(ErrorStr);
        LogUtil.LogMsg(lmError, UnitName, ErrorStr);
        Continue;
      end;
    end;

    if Assigned(fProgressEvent) then
      fProgressEvent(ClientIndex+1, aSelectClients.Count);
  end;

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
