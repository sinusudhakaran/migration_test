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
  ipshttps,
  bkContactInformation;

const
  PUBLIC_KEY_FILE_CASHBOOK_TOKEN = 'PublicKeyMyobMigration.pke';
type

  TDataRequestType = (drtSignIn, drtFirm, drtBusiness, drtCOA, drtTransactions,
                      drtJournals,drtRollback, drtMigrateClient);
  //----------------------------------------------------------------------------
  TClientMigrationState = (cmsAccessSysDB,
                           cmsAccessCltDB,
                           cmsClientPassword,
                           cmsTransformData,
                           cmsConnectToAPI,
                           cmsUploadError);

  //----------------------------------------------------------------------------
  TMigrationStatus = (mgsSuccess,
                      mgsPartial,
                      mgsFailure);

  //----------------------------------------------------------------------------
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
  TProgressEvent = procedure (aCurrentFile : integer;
                              aTotalFiles : integer;
                              aPercentOfCurrentFile : integer) of object;

  //----------------------------------------------------------------------------
  TURLThread = class(TThread)
  private
    procedure TryDownloadURLToFile(aHttpGetURL : TipsHTTPS; aExpectedTitle, aURL , aFile : string);
  public
    procedure Execute; override;
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
    fURLsArePreload : boolean;
    fToken: string;
    fUnEncryptedToken : string;
    FRefreshToken: string;
    fTokenStartDate : TDateTime;
    FHttpRequester : TipsHTTPS;
    fProgressEvent : TProgressEvent;
    FTokenExpiresAt : TDateTime;

    fClientCount : integer;
    fCurrentClient : integer;
    fClientDataSize : integer;
    fNumCodeReplaced : integer;
    fCurrentMyDotUser : string;

    fClientTimeFrameStart : TStDate;
    fClientMigrationState : TClientMigrationState;
    fCurrentCBClientCode : string;
    fHasProvisionalAccountsAndMoved : boolean;
    fProvisionalAccounts  : TStringList;
    fURLThread : TURLThread;
    FRandomKey : string;

    procedure ProcessLargeReceivedData;
    function ValidateJSONData:Boolean;
  protected
    FLicenseType : TLicenceType;
    FLargeJsonData : string;
    FDataRequestType : TDataRequestType;
    FDataTransferStarted : Boolean;
    FDataError : string;
    FDataResponse : TlkJSONbase;
    FMappingsData : TMappingsData;
    FSupportNumber : string;

//    fIPWorksErrorCode: Integer;
//    fIPWorksErrorDescription: String;

//    procedure OnIPWorksError( Sender: TObject; ErrorCode: Integer; const Description: String );

    function ProcessErrorMessage(aErrorMessage: TlkJSONbase): string;

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

    {below 2 functions are using for cashbook migration. The Transferreddata
    wont work for large response. So the below 2 functions are rewritten to
    get businesses. Below functions are stil using to get firms}

    function DoHttpSecure(const aVerb: string; const aURL: string;
                          const aHeaders: THttpHeaders; const aRequest: string;
                          var aResponse: string; var aErrorCode : integer;
                          var aErrorDescription: string): boolean;

    function DoHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                              var aRespStr : string; var aErrorCode : integer;
                              var aErrorDescription: string; aEncryptToken : boolean = false): boolean;
    function DoDeleteSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                              var aRespStr : string; var aErrorCode : integer;
                              var aErrorDescription: string; aEncryptToken : boolean = false): boolean;
    function DoUploadHttpSecure(const aVerb: string; const aURL: string;
                                const aHeaders: THttpHeaders; const aRequest: string;
                                var aResponse: string; var aErrorCode : integer;
                                var aErrorDescription: string): boolean;

    function DoUploadHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                                    var aResponse: TlkJSONbase; var aRespStr : string;
                                    var aErrorCode : integer; var aErrorDescription: string;
                                    aEncryptToken : boolean = false): boolean;


    function GetCashBookGSTType(aGSTMapCol : TGSTMapCol; aGSTClassId : byte) : string;

    function GetTimeFrameStart(aFinancialYearStart : TStDate) : TStDate;
    procedure AddCommentToClient(aClientLRN : integer; aNote : string);
    function ValidateIRDGST(aValue : string; var aModifiedIRD : string) : boolean;
    function FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aErrorDescription : string) : boolean;
    procedure MarkAccountsForDelete(aClient: TClientObj);

    function FillBusinessData(aClient : TClientObj; aBusinessData : TBusinessData; aFirmId : string; aOpeningBalanceDate: TStDate; aDoChartOfAccountBalances : boolean; var aErrorDescription : string) : boolean;
    function FillBankFeedData(aClient : TClientObj; aBankFeedApplicationsData : TBankFeedApplicationsData; aDoMoveRatherThanCopy : boolean; var aErrorDescription : string) : boolean;
    function FillDivisionData(aClient : TClientObj; aDivisionsData : TDivisionsData; var aUsedDivisions : TStringList; var aErrorDescription : string) : boolean;
    function FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aSelectedData: TSelectedData; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; aHasTransactions, aHasPayees : boolean; var aErrorDescription : string) : boolean;
    function FillTransactionData(aClient : TClientObj; aBankAccountsData : TBankAccountsData; aChartOfAccountsData : TChartOfAccountsData; aGSTMapCol : TGSTMapCol; var aHasTransactions : boolean; var aErrorDescription : string) : boolean;
    function FillJournalData(aClient : TClientObj; aJournalsData : TJournalsData; aOpeningBalanceDate: TStDate; aGSTMapCol : TGSTMapCol; var aErrorDescription : string) : boolean;

    function  FillPayeeData(aClient: TClientObj; const aHasTransactions: boolean;
                const aBankAccountsData: TBankAccountsData;
                const aGSTMapCol : TGSTMapCol; const aPayeesData: TPayeesData;
                var aHasPayees : boolean; var aErrorDescription: string): boolean;
    function  FillJobData(aClient: TClientObj; const aHasTransactions: boolean;
                const aBankAccountsData: TBankAccountsData; const aJobsData: TJobsData;
                var aErrorDescription: string): boolean;

    // this is to fix the wierd Allocation rule where the sum of all allocation ammounts must be positive
    procedure FixAllocationValues(aAllocationsData : TAllocationsData);
    function CalculateOpeningBalanceDate(aClient : TClientObj) : TStDate;

    function UploadClient(aClientBase : TClientBase; aSelectedData: TSelectedData;
               var aUploadID : string; var aErrorCode : integer;
               var aErrorDescription: string): boolean;

    function MigrateClient(aClient : TClientObj; aSelectedData: TSelectedData;
               var aUploadID : string; var aErrorCode : integer;
               var aErrorDescription: string): boolean;
    function GetSupportNumber : string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function StartedDataTransfer:Boolean;
    procedure EncryptToken(aToken : string);

    function ReturnGenericErrorMessage( aErrorCode : integer ) : string;

    procedure PreloadURLs();
    procedure MarkSelectedClients(aFileStatus: Integer; aSelectClients : TStringList);
    procedure MarkSelectClient(aFileStatus: Integer; aClientCode : string);

    function Login(const aEmail: string; const aPassword: string;
               var aErrorCode : integer; var aErrorDescription : string;
               var aInvalidPass : boolean): boolean;
    function RefreshTheToken(var aErrorCode : integer; var aErrorDescription : string; var aInvalidPass : boolean):Boolean;
    function GetFirms( var aFirms: TFirms; var aErrorCode : integer;
               var aErrorDescription: string ): boolean;
    function GetBusinesses( aFirmID: string; LicenseType:TLicenceType;
               var aBusinesses: TBusinesses; var aErrorCode : integer;
               var aErrorDescription: string):Boolean;
    function GetChartOfAccounts( aBusinessID:string;var aChartOfAccounts: TChartOfAccountsData;
               var aErrorCode : integer; var aErrorDescription:string):Boolean;

    function MigrateClients(aSelectClients : TStringList;
                            aSelectedData : TSelectedData;
                            var aClientErrors : TStringList;
                            var aNumErrorClients : integer) : TMigrationStatus;

    function CheckForValidTokens:Boolean;
    procedure SetDefaultTransferMethod;
    function GetAPIName:string;

    property OnProgressEvent : TProgressEvent read fProgressEvent write fProgressEvent;
    property MappingsData : TMappingsData read fMappingsData write fMappingsData;
    property HasProvisionalAccountsAndMoved : boolean read fHasProvisionalAccountsAndMoved;
    property ProvisionalAccounts : TStringList read fProvisionalAccounts write fProvisionalAccounts;

    property UnEncryptedToken : string read FUnEncryptedToken write FUnEncryptedToken;
    property RandomKey : string read FRandomKey write FRandomKey;
    property EncryptedToken : string read FToken write FToken;
    property RefreshToken : string read FRefreshToken write FRefreshToken;
    property TokenExpiresAt : TDateTime read FTokenExpiresAt write FTokenExpiresAt;
    property DataRequestType : TDataRequestType read FDataRequestType write FDataRequestType;
    property SupportNumber : string read GetSupportNumber; // write FSupportNumber;
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
  Merge32,
  SYDEFS,
  PayeeObj,
  JobObj,
  CountryUtils,
  dateUtils,
  Variants,
  WarningMoreFrm;

const
  UnitName = 'CashbookMigration';
  INIT_VECTOR = '@AT^NK(@YUVK)$#Y';

  MY_DOT_CONTENT_TYPE = 'application/x-www-form-urlencoded';
  MY_DOT_GRANT_PASSWORD = 'password';
  MY_DOT_GRANT_REFRESH_TOKEN = 'refresh_token';

  CASHBOOK_CONTENT_TYPE = 'application/json; charset=utf-8';
  CASHBOOK_ACCEPT = 'application/vnd.cashbook-v1+json';
  CASHBOOK_AUTH_PREFIX = 'Bearer ';

  CASHBOOK_SYSTEM_ACCOUNTS : Array[0..8] of string =
    ('2-2000','2-2200','2-2400','2-2800','3-1600','3-1800','3-8000','3-8001','3-9999');

var
  fCashbookMigration: TCashbookMigration;
  DebugMe : boolean = false;

{ TURLThread }
//------------------------------------------------------------------------------
procedure TURLThread.TryDownloadURLToFile(aHttpGetURL : TipsHTTPS; aExpectedTitle, aURL, aFile: string);
var
  Response : string;
  StringStream : TStringStream;
  FileStream : TFileStream;
begin
  try
    aHttpGetURL.Get(aURL);

    if aHttpGetURL.ContentType = '' then
    begin
      Response := aHttpGetURL.TransferredData;
      if (Pos('404',Response) = 0) and
         (Pos('<title>' + aExpectedTitle + '</title>',Response) > 0) then
      begin
        StringStream := TStringStream.Create(Response);
        try
          FileStream := TFileStream.Create(aFile, fmCreate);
          Try
            FileStream.CopyFrom(StringStream, StringStream.Size);

            if DebugMe then
              LogUtil.LogMsg(lmDebug, UnitName, 'Successful Get of ' + aURL);
          Finally
            FreeAndNil(FileStream);
          End;
        finally
          FreeAndNil(StringStream);
        end;
      end
      else
        LogUtil.LogMsg(lmError, UnitName, 'Failed to Get ' + aURL + ', Not expected page.');
    end;
  except
    on E: Exception do
    begin
      LogUtil.LogMsg(lmError, UnitName, 'Failed to Get ' + aURL + ', ' + E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TURLThread.Execute;
var
  HttpGetURL : TipsHTTPS;
  URL : string;
begin
  HttpGetURL := TIpsHTTPS.Create(nil);
  try
    if not DirectoryExists(Globals.HtmlCache) then
      CreateDir(RemoveSlash(Globals.HtmlCache));

    case AdminSystem.fdFields.fdCountry of
      whNewZealand: URL := Globals.PRACINI_NZCashMigrationURLOverview1;
      whAustralia : URL := Globals.PRACINI_AUCashMigrationURLOverview1;
    end;

    TryDownloadURLToFile(HttpGetURL, 'Before you start', URL, Globals.HtmlCache + CashBookStartCacheFileName);

    case AdminSystem.fdFields.fdCountry of
      whNewZealand: URL := Globals.PRACINI_NZCashMigrationURLOverview2;
      whAustralia : URL := Globals.PRACINI_AUCashMigrationURLOverview2;
    end;

    TryDownloadURLToFile(HttpGetURL, 'Migration details', URL, Globals.HtmlCache + CashBookDetailCacheFileName);
  finally
    FreeAndNil(HttpGetURL);
  end;
end;

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

      if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) then
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

{ TCashbookMigration }
//------------------------------------------------------------------------------
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
function TCashbookMigration.DoDeleteSecureJson(const aURL: string;
           const aRequest: TlkJSONbase; var aRespStr : string;
           var aErrorCode : integer; var aErrorDescription: string;
           aEncryptToken: boolean): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
begin
  Result := false;

  try
    // Verb
    sVerb := 'DELETE';

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
    if Assigned(aRequest) then
    begin
      sRequest := TlkJSON.GenerateText(aRequest);
      fClientDataSize := length(sRequest);
    end;

    // Http
    if not DoHttpSecure(sVerb, aURL, Headers, sRequest, aRespStr, aErrorCode, aErrorDescription) then
      Exit;

  except
    on E: EipsHTTPS do  // ipsHttps Exception
    begin
      aErrorCode        := E.Code;
      aErrorDescription := E.Message;
    end;
    on E: Exception do
    begin
      aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
      aErrorDescription := E.Message;
      Exit;
    end;
  end;

  Result := True;
end;

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
  FLargeJsonData := '';
  FDataTransferStarted := True;
  FDataError := '';
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpTransfer(ASender           : TObject;
                                            ADirection        : Integer;
                                            ABytesTransferred : LongInt;
                                            AText             : String);
begin
  FLargeJsonData := FLargeJsonData + AText;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.DoHttpEndTransfer(ASender    : TObject;
                                               ADirection : Integer);
begin
  ProcessLargeReceivedData;
  FDataTransferStarted := False;
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

///  FHttpRequester.OnError                   := OnIPWorksError;

  FHttpRequester.AuthScheme   := authBasic;

  FHttpRequester.Config ('SSLSecurityFlags=0x80000000');
  FHttpRequester.Config ('SSLEnabledProtocols=140');
end;

//------------------------------------------------------------------------------
function TCashbookMigration.GetAPIName: string;
begin
  Result := '';

  case FLicenseType of
    ltCashbook : Result := 'CashbookMigration'; // This need to change at some point and use BRAND_CASHBOOK_NAME
    ltPracticeLedger : Result := BRAND_MYOB_LEDGER_NAME;
  end;
end;

function TCashbookMigration.GetBusinesses(aFirmID: string; LicenseType:TLicenceType;
  var aBusinesses: TBusinesses; var aErrorCode : integer; var aErrorDescription: string): Boolean;
var
  sURL: string;
  JsonObject: TlkJSONObject;
  RespStr : string;
begin
  Result := False;
  JsonObject := nil;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    try
      sURL := PRACINI_CashbookAPIBusinessesURL;
      FDataRequestType := drtBusiness;

      if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
      begin
        HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
        Exit;
      end;

      if not DoHttpSecureJson(sURL, nil, RespStr, aErrorCode, aErrorDescription) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      if Assigned(FDataResponse) then
      begin
        JsonObject := (FDataResponse as TlkJSONObject);
        RespStr := TlkJSON.GenerateText(JsonObject);
      end;

      if DebugMe then
        LogUtil.LogMsg(lmInfo, UnitName, RespStr);

      if Assigned(aBusinesses) and Assigned(JsonObject) then
        aBusinesses.Read(aFirmID,LicenseType,JsonObject);

    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := E.Message;
      end;
      on E: Exception do
      begin
        aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
        aErrorDescription := Format('Exception running %s.GetBusinesses, Error Message : ' + E.Message,[GetAPIName]);
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;

  Result := True;
end;

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

function TCashbookMigration.GetChartOfAccounts(aBusinessID: string; var aChartOfAccounts: TChartOfAccountsData;
           var aErrorCode : integer; var aErrorDescription: string): Boolean;
var
  sURL: string;
  JsonObject: TlkJSONObject;
  RespStr : string;
begin
  Result := False;
  JsonObject := nil;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    try
      sURL := Format(PRACINI_CashbookAPICOAURL,[aBusinessID]);
      FDataRequestType := drtCOA;
      if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
      begin
        HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
        Exit;
      end;

      if not DoHttpSecureJson(sURL, nil, RespStr, aErrorCode, aErrorDescription) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      if Assigned(FDataResponse) then
      begin
        JsonObject := (FDataResponse as TlkJSONObject);
        RespStr := TlkJSON.GenerateText(FDataResponse);
      end;
      if Assigned(aChartOfAccounts) and Assigned(JsonObject) then
      begin
        aChartOfAccounts.Read(aBusinessID,JsonObject);
      end;

    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorDescription := format ( 'Exception running %s.GetCOA, Error Code : %d, ' +
          'Error Message : ', [ GetAPIName, E.Code, E.Message ] );
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
      on E: Exception do
      begin
        aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
        aErrorDescription := 'Exception running ' + GetAPIName + '.GetCOA, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;
  Result := True;
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
  FUnEncryptedToken := aToken;

  case FLicenseType of
    ltCashbook : FRandomKey := '';
    ltPracticeLedger : ;
  end;

  if Trim(FRandomKey) = '' then
    KeyString := OpenSSLEncription.GetRandomKey
  else
    KeyString := FRandomKey;

  if OpenSSLEncription.AESEncrypt(KeyString, aToken, EncryptedToken, INIT_VECTOR) then
  begin
    EncryptedKey := OpenSSLEncription.SimpleRSAEncrypt(KeyString, GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN);
    FToken := EncryptedToken + KEY_DELIMMITER + EncryptedKey;
    FRandomKey := KeyString;
    FTokenStartDate := Now();
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecure(const aVerb, aURL: string;
           const aHeaders: THttpHeaders; const aRequest: string;
           var aResponse: string; var aErrorCode : integer;
           var aErrorDescription: string): boolean;
const
  CRLF = #13#10;
var
  LoggedRequest : string;
  ErroMessage: TlkJSONbase;

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
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable

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

    FHttpRequester.HTTPMethod := aVerb;
    if (aVerb = 'GET') then
    begin
      FHttpRequester.Get(aURL);
    end
    else if (aVerb = 'POST') then
    begin
      FHttpRequester.PostData := aRequest;
      FHttpRequester.Post(aURL);

      aResponse := FHttpRequester.TransferredData;
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Response : ' + aResponse);
    end
    else if (aVerb = 'DELETE') then//delete
    begin
      FHttpRequester.PostData := aRequest;
      FHttpRequester.Put(aURL);

      aResponse := FHttpRequester.TransferredData;
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Response : ' + aResponse);
    end;

    Result := true;
  except
    on E: EipsHTTPS do  // ipsHttps Exception
    begin
      aResponse := FHttpRequester.TransferredData;
      ErroMessage:= TlkJSON.ParseText(aResponse);
      try
        aErrorCode := E.Code;
        aErrorDescription := aErrorDescription + ProcessErrorMessage(ErroMessage);
      finally
        FreeAndNil(ErroMessage);
      end;
    end;
    on E: Exception do // Any other exception
    begin
      aResponse := FHttpRequester.TransferredData;
      ErroMessage:= TlkJSON.ParseText(aResponse);
      try
        aErrorDescription := aErrorDescription + ProcessErrorMessage(ErroMessage);
      finally
        FreeAndNil(ErroMessage);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoUploadHttpSecure(const aVerb, aURL: string; const aHeaders: THttpHeaders;
           const aRequest: string; var aResponse : string;
           var aErrorCode : integer; var aErrorDescription: string): boolean;
const
  CRLF = #13#10;
begin
  Result := false;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    { WORKAROUND:
      Setting specific headers (Authorization/Accept/Content-Type) doesn't work,
      so we must use OtherHeaders instead.}
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

    FHttpRequester.HTTPMethod := aVerb;

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
    on E: EipsHTTPS do  // ipsHttps Exception
    begin
      aErrorCode := E.Code;
      aErrorDescription     := E.Message;
    end;
    on E: Exception do
    begin
      aErrorDescription := E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecureJson(const aURL: string;
           const aRequest: TlkJSONbase; var aRespStr : string;
           var aErrorCode : integer; var aErrorDescription: string;
           aEncryptToken : boolean): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
begin
  Result := false;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';

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
    if Assigned(aRequest) then
    begin
      sRequest := TlkJSON.GenerateText(aRequest);
      fClientDataSize := length(sRequest);
    end;

    // Http
    if not DoHttpSecure(sVerb, aURL, Headers, sRequest, aRespStr, aErrorCode, aErrorDescription) then
      Exit;

  except
    on E: EipsHTTPS do  // ipsHttps Exception
    begin
      aErrorCode := E.Code;
      aErrorDescription := E.Message;
    end;
    on E: Exception do
    begin
      aErrorDescription := E.Message;
      Exit;
    end;
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoUploadHttpSecureJson(const aURL: string;
           const aRequest: TlkJSONbase; var aResponse: TlkJSONbase;
           var aRespStr : string; var aErrorCode : integer;
           var aErrorDescription: string; aEncryptToken : boolean): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
begin
  result := false;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';

  aResponse := nil;

  try
    // Verb
    if not assigned(aRequest) then
      sVerb := 'GET'
    else
      sVerb := 'POST';

    FDataRequestType := drtMigrateClient;
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
    if not DoUploadHttpSecure(sVerb, aURL, Headers, sRequest, aRespStr, aErrorCode, aErrorDescription) then
      exit;

    // Response
    aResponse := TlkJSON.ParseText(aRespStr);

    if not assigned(aResponse) then
      exit;
  except
    on E: EipsHTTPS do  // ipsHttps Exception
    begin
      aErrorCode := E.Code;
      aErrorDescription     := E.Message;
    end;
    on E: Exception do
    begin
      FreeAndNil(aResponse);

      aErrorDescription := E.Message;
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

function TCashbookMigration.ValidateJSONData: Boolean;
begin
  {This function validates JSON data before proceed}

  try
    FDataResponse := TlkJSON.ParseText(FLargeJsonData);
  except
    FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
    LogUtil.LogMsg(lmError, UnitName, FDataError);
    Exit;
  end;

  if not Assigned(FDataResponse) then
  begin
    FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
    LogUtil.LogMsg(lmError, UnitName, FDataError);
    Exit;
  end;

  case FDataRequestType of
    drtFirm :
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONlist) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtBusiness :
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtCOA:
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtTransactions:
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtJournals:
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtRollback:
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
    drtMigrateClient:
    begin
      if not (Assigned(FDataResponse)) or
         not (FDataResponse is TlkJSONObject) then
      begin
        FDataError := 'We had trouble getting the right data from ' + GetAPIName + '. Please try again later, if problem persists contact support.';
        LogUtil.LogMsg(lmError, UnitName, FDataError);
        Exit;
      end;
    end;
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
function TCashbookMigration.FixClientCodeForCashbook(aInClientCode : string; var aOutClientCode, aErrorDescription : string) : boolean;
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
        aErrorDescription := 'Exception converting Practice Client Code into valid ' + BRAND_CASHBOOK_NAME + ' Client code, Error : ' + E.Message;
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
procedure TCashbookMigration.MarkAccountsForDelete(aClient: TClientObj);
var
  AccountIndex : integer;
  BankAccount : TBank_Account;
  SystemBankAccount : pSystem_Bank_Account_Rec;
begin
  if not Assigned(AdminSystem) then
    Exit;

  if LoadAdminSystem(True, 'MarkAccountsForDelete') then
  begin
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);

      if not BankAccount.baFields.baIs_A_Provisional_Account then
      begin
        SystemBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(BankAccount.baFields.baBank_Account_Number);
        if Assigned(SystemBankAccount) then
          SystemBankAccount^.sbMark_As_Deleted := True;
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, UnitName, 'Cannot move Bank Feed for Provisional Account, Client Code : ' + aClient.clFields.clCode +
                                 ', Bank Account : ' + BankAccount.baFields.baBank_Account_Number +
                                 '.');
      end;
    end;
    SaveAdminSystem;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillBusinessData(aClient: TClientObj; aBusinessData: TBusinessData; aFirmId : string; aOpeningBalanceDate: TStDate; aDoChartOfAccountBalances : boolean; var aErrorDescription: string): boolean;
var
  ClientCode : string;
  FYSday, FYSmonth, FYSyear : integer;
  ABN : string;
  Branch : string;
  IRD : string;
  ModifiedIRD : string;
begin
  Result := false;

  if not FixClientCodeForCashbook(aClient.clFields.clCode, ClientCode, aErrorDescription) then
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

    if (aOpeningBalanceDate = BadDate) or
       (not aDoChartOfAccountBalances) then
      aBusinessData.OpeningBalanceDate := ''
    else
      aBusinessData.OpeningBalanceDate := StDateToDateString('yyyy-mm-dd', aOpeningBalanceDate, true);

    Result := true;
  except
    on E: Exception do
    begin
      aErrorDescription := 'Exception retrieving Client data : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillBankFeedData(aClient: TClientObj; aBankFeedApplicationsData: TBankFeedApplicationsData; aDoMoveRatherThanCopy : boolean; var aErrorDescription: string): boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  BankFeedApplicationData : TBankFeedApplicationData;
  AccountIndex : integer;
  BankAccount : TBank_Account;

  //----------------------------------------------------------------------------
  function IsAccountMarkedForDelete(aBankAccount : string) : boolean;
  var
    SysAccount : pSystem_Bank_Account_Rec;
  begin
    Result := false;
    SysAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(aBankAccount);

    if Assigned(SysAccount) then
      Result := SysAccount.sbMark_As_Deleted;
  end;

begin
  Result := false;
  try
    for AccountIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(AccountIndex);
      if not (BankAccount.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
         not (BankAccount.baFields.baIs_A_Manual_Account) then
      begin
      
        if BankAccount.baFields.baIs_A_Provisional_Account then
        begin
          if aDoMoveRatherThanCopy then
          begin
            fProvisionalAccounts.Add(aClient.clFields.clCode + ', ' +
                                     BankAccount.baFields.baBank_Account_Name + ', ' +
                                     BankAccount.baFields.baBank_Account_Number);
            fHasProvisionalAccountsAndMoved := true;
          end;

          Continue;
        end;

        for ChartIndex := 0 to aClient.clChart.ItemCount-1 do
        begin
          AccRec := aClient.clChart.Account_At(ChartIndex)^;

          if BankAccount.baFields.baContra_Account_Code = AccRec.chAccount_Code then
          begin
            if IsAccountMarkedForDelete(BankAccount.baFields.baBank_Account_Number) then
            begin
              LogUtil.LogMsg(lmInfo, UnitName, 'Bank Account has been marked as deleted for Client Code : ' + aClient.clFields.clCode +
                                               ', Bank Account : ' + BankAccount.baFields.baBank_Account_Number +
                                               '. Not sending bank feed.');
              Continue;
            end;

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
      aErrorDescription := 'Exception retrieving Bank Feeds : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillDivisionData(aClient: TClientObj; aDivisionsData: TDivisionsData; var aUsedDivisions : TStringList; var aErrorDescription: string): boolean;
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
      aErrorDescription := 'Exception retrieving Divisions : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillChartOfAccountData(aClient : TClientObj; aChartOfAccountsData : TChartOfAccountsData; aSelectedData: TSelectedData; aChartExportCol : TChartExportCol; aGSTMapCol : TGSTMapCol; aUsedDivisions : TStringList; aHasTransactions, aHasPayees : boolean; var aErrorDescription : string) : boolean;
var
  ChartIndex : integer;
  AccRec : tAccount_Rec;
  NewChartItem : TChartOfAccountData;
  ChartExportItem : TChartExportItem;
  MappedGroupId : TCashBookChartClasses;
  ChartExportFound : boolean;
  MigrationOpeningBalance : integer;
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

      if ((Trim(AccRec.chAccount_Code) = '') or (Trim(MappingsData.UpdateSysCode(AccRec.chAccount_Code)) = '')) then
        Continue;

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
          MigrationOpeningBalance := GetMigrationOpeningBalance(ChartExportItem.DisplayOpeningBalance)
        else
          MigrationOpeningBalance := 0;
      end
      else
        MigrationOpeningBalance := 0;

      if (AccRec.chTemp_Tag = TEMP_TAG_MANUAL_ADDED_GST) and
        (MigrationOpeningBalance = 0) then
        Continue;

      NewChartItem := TChartOfAccountData.Create(aChartOfAccountsData);
      NewChartItem.Code := MappingsData.UpdateSysCode(AccRec.chAccount_Code);
      NewChartItem.Name := AccRec.chAccount_Description;

      if length(trim(NewChartItem.Name)) = 0 then
        NewChartItem.Name := NewChartItem.Code;

      NewChartItem.InActive       := AccRec.chInactive;
      NewChartItem.PostingAllowed := AccRec.chPosting_Allowed;
      NewChartItem.Divisions      := GetValidDivisions();

      if ChartExportFound then
      begin
        MappedGroupId := aChartExportCol.GetMappedReportGroupId(ChartExportItem.ReportGroupId);

        NewChartItem.OrigAccountType := atNames[ChartExportItem.ReportGroupId];
        NewChartItem.OrigGstType := trim(aClient.clFields.clGST_Class_Codes[ AccRec.chGST_Class ] + ' ' +
                                         aClient.clFields.clGST_Class_Names[ AccRec.chGST_Class]);
        NewChartItem.AccountType := GetMigrationMappedReportGroupCode(MappedGroupId);

        NewChartItem.GstType := GetCashBookGSTType(aGSTMapCol, ChartExportItem.GSTClassId);

        // Opening Balance
        if SendZeroOpeningBalance(MappedGroupId, ChartExportItem.OpeningBalanceDate, aClient.clFields.clFinancial_Year_Starts) then
          NewChartItem.OpeningBalance := 0
        else
          NewChartItem.OpeningBalance := MigrationOpeningBalance;


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
            if not ((NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccAsset)) or
                    (NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccLiabilities))) then
              NewChartItem.AccountType := GetMigrationMappedReportGroupCode(ccAsset);
          end;
        end;
      end;

      if NewChartItem.BankOrCreditFlag then
      begin
        if not ((NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccAsset)) or
                (NewChartItem.AccountType = GetMigrationMappedReportGroupCode(ccLiabilities))) then
          NewChartItem.AccountType := GetMigrationMappedReportGroupCode(ccAsset);
      end;
    end;

    // Add Uncoded Chart
    if (aHasTransactions) or
       (aHasPayees) then
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
      aErrorDescription := 'Exception retrieving Chart : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillTransactionData(aClient: TClientObj; aBankAccountsData: TBankAccountsData; aChartOfAccountsData : TChartOfAccountsData; aGSTMapCol : TGSTMapCol; var aHasTransactions : boolean; var aErrorDescription: string): boolean;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  TransactionItem : TTransactionData;
  BankAccountItem : TBankAccountData;
  AllocationItem : TAllocationData;
  BankAccount : TBank_Account;
  TransactionRec : tTransaction_Rec;
  AccRec : pAccount_Rec;
  DissRec: pDissection_Rec;
begin
  Result := false;
  aHasTransactions := false;
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

          aHasTransactions := true;

          TransactionItem := TTransactionData.Create(BankAccountItem.Transactions);
          TransactionItem.Date        := StDateToDateString('yyyy-mm-dd', TransactionRec.txDate_Effective, true);
          TransactionItem.Description := TransactionRec.txStatement_Details;
          TransactionItem.Amount      := trunc(TransactionRec.txAmount);
          TransactionItem.Reference   := TrimLeadZ(TransactionRec.txReference);

          if BankAccount.baTransaction_List.GetTransCoreID_At(TransactionIndex) > 0 then
            TransactionItem.CoreTransactionId := InsFillerZeros(inttostr(BankAccount.baTransaction_List.GetTransCoreID_At(TransactionIndex)),15)
          else
            TransactionItem.CoreTransactionId := '';

          TransactionItem.Quantity := TransactionRec.txQuantity;
          TransactionItem.PayeeNumber := TransactionRec.txPayee_Number;
          TransactionItem.JobCode := TransactionRec.txJob_Code;

          // Dissection
          DissRec := TransactionRec.txFirst_Dissection;
          if DissRec <> nil then
          begin
            While (DissRec <> nil ) do
            begin
              AllocationItem := TAllocationData.Create(TransactionItem.Allocations);

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

              AllocationItem.Description := DissRec^.dsGL_Narration;
              AllocationItem.Amount := trunc(DissRec^.dsAmount);
              AllocationItem.TaxAmount := trunc(DissRec^.dsGST_Amount);
              AllocationItem.TaxRate := GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);

             { if ((AllocationItem.TaxAmount <> 0) and (AllocationItem.TaxRate ='NA')) then
                AllocationItem.TaxRate := 'GST';}

              AllocationItem.Quantity := DissRec^.dsQuantity;
              AllocationItem.PayeeNumber := DissRec^.dsPayee_Number;
              AllocationItem.JobCode := DissRec^.dsJob_Code;

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

            {if ((AllocationItem.TaxAmount <> 0) and (AllocationItem.TaxRate ='NA')) then
              AllocationItem.TaxRate := 'GST';}

            AllocationItem.Quantity := TransactionRec.txQuantity;
            AllocationItem.PayeeNumber := TransactionRec.txPayee_Number;
            AllocationItem.JobCode := TransactionRec.txJob_Code;
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
      aErrorDescription := 'Exception retrieving Transactions : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillJournalData(aClient: TClientObj; aJournalsData: TJournalsData; aOpeningBalanceDate: TStDate; aGSTMapCol : TGSTMapCol; var aErrorDescription: string): boolean;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  JournalItem : TJournalData;
  LineItem : TLineData;
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
          if TransactionRec.txDate_Effective < aOpeningBalanceDate then
            break;

          // Check if Transaction is not finalized and not presented
          if (TransactionRec.txDate_Transferred > 0) then
            break;

          JournalItem := TJournalData.Create();
          JournalItem.Date        := StDateToDateString('yyyy-mm-dd', TransactionRec.txDate_Effective, true);
          JournalItem.Description := TransactionRec.txGL_Narration;
          JournalItem.Reference   := TrimLeadZ(TransactionRec.txReference);

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

            LineItem.Description := DissRec^.dsGL_Narration;
            LineItem.Reference   := TrimLeadZ(DissRec^.dsReference);
            LineItem.TaxAmount   := trunc(DissRec^.dsGST_Amount);
            LineItem.TaxRate     := GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);

            {if ((LineItem.TaxAmount <> 0) and (LineItem.TaxRate = 'NA')) then
              LineItem.TaxRate := 'GST';}

            LineItem.Amount := abs(trunc(DissRec^.dsAmount));
            if trunc(DissRec^.dsAmount) < 0 then
              LineItem.IsCredit := true
            else
              LineItem.IsCredit := false;

            LineItem.Quantity := DissRec^.dsQuantity;
            LineItem.PayeeNumber := DissRec^.dsPayee_Number;
            LineItem.JobCode := DissRec^.dsJob_Code;

            DissRec := DissRec^.dsNext;
          end;

          aJournalsData.Insert(JournalItem);
        end;
      end;
    end;

    if aJournalsData.ItemCount > 1 then
      aJournalsData.Sort();

    Result := true;

  except
    on E: Exception do
    begin
      aErrorDescription := 'Exception retrieving Journals : ' + E.Message;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillPayeeData(aClient: TClientObj;
  const aHasTransactions: boolean; const aBankAccountsData: TBankAccountsData;
  const aGSTMapCol : TGSTMapCol; const aPayeesData: TPayeesData;
  var aHasPayees : boolean; var aErrorDescription: string): boolean;
var
  iPayee: integer;
  Payees: TPayee_List;
  Payee: TPayee;
  PayeeData: TPayeeData;
  sStateCode: string;
  sStateDesc: string;

  Lines: TPayeeLinesList;
  iLine: integer;
  pLine: pPayee_Line_Rec;
  LineData: TPayeeLineData;
begin
  try
    aHasPayees := false;

    Payees := aClient.clPayee_List;

    for iPayee := 0 to Payees.ItemCount-1 do
    begin
      Payee := Payees.Payee_At(iPayee);

      if aHasTransactions then
      begin
        if Payee.pdFields.pdInactive then
        begin
          if not aBankAccountsData.PayeeExists(Payee.pdFields.pdNumber) then
            continue;
        end;
      end
      else
      begin
        if Payee.pdFields.pdInactive then
          continue;
      end;

      aHasPayees := true;
      PayeeData := TPayeeData.Create(aPayeesData);

      // Payee
      PayeeData.PayeeNumber := Payee.pdFields.pdNumber;
      PayeeData.Inactive := Payee.pdFields.pdInactive;
      PayeeData.ContractorPayee := Payee.pdFields.pdContractor;
      PayeeData.PayeeName := Payee.pdFields.pdName;
      PayeeData.PayeeSurname := Payee.pdFields.pdSurname;
      PayeeData.PayeeGivenName := Payee.pdFields.pdGiven_Name;
      PayeeData.OtherName := Payee.pdFields.pdOther_Name;
      PayeeData.Address := Payee.pdFields.pdAddress;
      PayeeData.Town := Payee.pdFields.pdTown;

      if Payee.pdFields.pdContractor then
      begin
        GetAustraliaStateFromIndex(Payee.pdFields.pdStateId, sStateCode, sStateDesc);
        PayeeData.State := sStateCode;
      end;

      PayeeData.Postcode := Payee.pdFields.pdPost_Code;
      PayeeData.PhoneNumber := Payee.pdFields.pdPhone_Number;
      PayeeData.ABN := Payee.pdFields.pdABN;
      PayeeData.BusinessName := Payee.pdFields.pdBusinessName;
      PayeeData.TradingName := Payee.pdFields.pdTradingName;
      PayeeData.Address2 := Payee.pdFields.pdAddressLine2;
      PayeeData.Country := Payee.pdFields.pdCountry;
      PayeeData.BankAccountNumber := Payee.pdFields.pdInstitutionBSB +
        Payee.pdFields.pdInstitutionAccountNumber;

      // Lines
      Lines := Payee.pdLines;
      for iLine := 0 to Lines.ItemCount-1 do
      begin
        pLine := Lines[iLine];

        LineData := TPayeeLineData.Create(PayeeData.Lines);

        // Line
        if aClient.clChart.CodeIsThere(pLine.plAccount) then
          LineData.AccountNumber := pLine.plAccount
        else
          LineData.AccountNumber := 'UNCODED';

        // Percentage or dollar amount (same field depending on line type)
        if (pLine.plLine_Type = pltPercentage) then
          LineData.Percentage := pLine.plPercentage
        else
          LineData.Amount := pLine.plPercentage;

        LineData.TaxRate := GetCashBookGSTType(aGSTMapCol, pLine.plGST_Class);
        LineData.Narration := pLine.plGL_Narration;
      end;

    end;

  except
    on E: Exception do
    begin
      aErrorDescription := 'Exception retrieving Payees : ' + E.Message;

      result := false;

      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FillJobData(aClient: TClientObj;
  const aHasTransactions: boolean; const aBankAccountsData: TBankAccountsData;
  const aJobsData: TJobsData; var aErrorDescription: string): boolean;
var
  i: integer;
  Jobs: TClient_Job_List;
  Job: pJob_Heading_Rec;
  JobData: TJobData;
begin
  try
    Jobs := aClient.clJobs;

    for i := 0 to Jobs.ItemCount-1 do
    begin
      Job := Jobs.Job_At(i);

      if aHasTransactions then
      begin
        if (Job.jhDate_Completed <> 0) then
        begin
          if not aBankAccountsData.JobExists(Job.jhCode) then
            continue;
        end;
      end
      else
      begin
        if (Job.jhDate_Completed <> 0) then
          continue;
      end;

      JobData := TJobData.Create(aJobsData);

      JobData.Code := Job.jhCode;
      JobData.Name := Job.jhHeading;
      JobData.Completed := Job.jhDate_Completed;
    end;

  except
    on E: Exception do
    begin
      aErrorDescription := 'Exception retrieving Jobs : ' + E.Message;

      result := false;

      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.UploadClient(aClientBase : TClientBase; aSelectedData: TSelectedData; var aUploadID : string; var aErrorCode : integer; var  aErrorDescription: string): boolean;
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
  aUploadID := '';
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
        UploadDone := DoUploadHttpSecureJson(sURL, Request, ResponseBase, RespStr, aErrorCode, aErrorDescription, false);

        if not UploadDone then
        begin
          LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
          exit;
        end;

        if not (Assigned(Response)) or
           not (Response is TlkJSONobject) then
        begin
          aErrorDescription := 'Error uploading client data : No response from server.';
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
                UPLOAD_RESP_ERROR     : aErrorDescription := 'Error uploading client data : Error response from server.';
                UPLOAD_RESP_UKNOWN    : aErrorDescription := 'Error uploading client data : Unknown response from server.';
                UPLOAD_RESP_DUPLICATE : aErrorDescription := 'Error uploading client data : Duplicate Upload.';
                UPLOAD_RESP_CORUPT    : aErrorDescription := 'Error uploading client data : Corrupt Upload.';
              end;
              Exit;
            end;

            aUploadID := MigUploadResponse.UploadID;
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
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := 'Exception uploading client data : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
      on E: Exception do
      begin
        aErrorDescription := 'Exception uploading client data : ' + E.Message;
        exit;
      end;
    end;
  finally
    FreeAndNil(MigUpload);
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.PreloadURLs;
begin
  if fURLsArePreload then
    Exit;

  fURLThread := TURLThread.Create(false);

  fURLsArePreload := true;
end;

function TCashbookMigration.ProcessErrorMessage(
  aErrorMessage: TlkJSONbase): string;
var
  sErrors : string;
begin
  Result := '';
  if not Assigned(aErrorMessage) then
    Exit;
    
  if Assigned(aErrorMessage.Field['error']) then
    Result := '[' + VarToStr(aErrorMessage.Field['error'].Value) + ']';
  if Assigned(aErrorMessage.Field['error_description']) then
    Result := Result +  #13#10 + VarToStr(aErrorMessage.Field['error_description'].Value);
  if Assigned(aErrorMessage.Field['message']) then
    Result := Result + '[' + VarToStr(aErrorMessage.Field['message'].Value) + ']';

  if Assigned(aErrorMessage.Field['errors']) then
  begin
    sErrors := StringReplace(TlkJSON.GenerateText(aErrorMessage.Field['errors']), '{','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '}','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '[','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, ']','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '"','', [rfReplaceAll, rfIgnoreCase]);
    Result := Result + #13#10 + sErrors;
  end;
end;

procedure TCashbookMigration.ProcessLargeReceivedData;
var
  JSONData : TStringList;
begin
  if DebugMe then
  begin
    JSONData := TStringList.Create;
    try
      JSONData.Add(FLargeJsonData);
      try
        JSONData.SaveToFile('PL_BusinessJSON.txt');
      except
        // No need to do anything here
      end;
    finally
      FreeAndNil(JSONData);
    end;
  end;

  if Trim(FLargeJsonData) = '' then
    Exit;

  if not ValidateJSONData then
    Exit;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Response : ' + FLargeJsonData);
end;

function TCashbookMigration.RefreshTheToken(var aErrorCode : integer; var aErrorDescription: string;
  var aInvalidPass: boolean): Boolean;
var
  Headers: THttpHeaders;
  PostData: TStringList;
  js: TlkJSONobject;
  sResponse: string;
//  sError: string;
  Token : string;
  NoOfSecondsToExpire : Integer;
begin
  Result := False;
  aInvalidPass := False;

  //Initialize token just before a login
  Token := '';
  NoOfSecondsToExpire := 0;
  FTokenExpiresAt := IncSecond(Now,NoOfSecondsToExpire);
  aErrorCode        := low( integer ); // Ensure that ErrorCode reports no error
  aErrorDescription := '';
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
      PostData.Values['grant_type']    := MY_DOT_GRANT_REFRESH_TOKEN;
      PostData.Values['refresh_token']    := RefreshToken;
      FDataRequestType := drtSignIn;

      // Cancelled?
      if not DoHttpSecure(
        'POST',
        PRACINI_CashbookAPILoginURL,
        Headers,
        PostData.DelimitedText,
        sResponse,
        aErrorCode,
        aErrorDescription) then
      begin
        if Pos('151: Bad Request', aErrorDescription) > 0 then
        begin
          aInvalidPass := true;
          aErrorDescription:= 'Invalid Refresh Token.' + #13#10 + 'Please try again.';
          LogUtil.LogMsg(lmInfo, UnitName, aErrorDescription);
        end
        else
          LogUtil.LogMsg(lmError, UnitName, 'Error running ' + GetAPIName +'.RefreshToken, Error Message : ' + aErrorDescription);

//        aErrorDescription := sError;
        Exit;
      end;

      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      // Parse JSON result
      if Assigned(FDataResponse) then
        js := FDataResponse as TlkJSONobject;

      if not assigned(js) then
      begin
        aErrorDescription := 'Error running ' + GetAPIName + '.Login, Error Message : No response from Server.';
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;

      // Get token
      Token := js.GetString('access_token');
      FRefreshToken := js.GetString('refresh_token');
      NoOfSecondsToExpire := StrToIntDef(js.GetString('expires_in'),0);
      FTokenExpiresAt := IncSecond(Now,NoOfSecondsToExpire);

      if (Trim(Token) <> '') and
        (Trim(FRefreshToken) <> '') and
        (NoOfSecondsToExpire > 0) then
        EncryptToken(Token)
      else
      begin
        aErrorDescription := 'Error running ' + GetAPIName + '.RefreshToken, Error Message : Can not find Access Token in response.';
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;

      Result := True;
    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := 'Exception running ' + GetAPIName + '.RefreshToken, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
      on E : Exception do
      begin
        aErrorDescription := 'Exception running ' + GetAPIName + '.RefreshToken, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    FreeAndNil(PostData);
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;
end;

function TCashbookMigration.ReturnGenericErrorMessage(
  aErrorCode: integer): string;
begin
  case aErrorCode of
    // HTTP Errors
    118, 143, 151..153, 155, 156, 301, 302, // and
    // IPPort Errors
    100..102, 104, 106, 107, 112, 116, 117, 135, 211..213,
    1105, 1117, 1119, 1120 : begin
      result := format( 'Could not connect to the service, ' +
                  'please try again later, if problem persists ' +
                  'contact support (%s)', [ fSupportNumber ] );
    end;

    // SSL Errors
    271..276, 280..284, //and
    // Http Access Denied error
    10013 : begin
      result := format( 'Could not authenticate with the server, ' +
                  'please contact support (%s)', [ fSupportNumber ] );
    end;
    // TCP/IP Errors
    10004, 10009, 1014, 1022, 1024, 1035..1071, 10091..10093, 11001..11004 : begin
      result := format( 'We had trouble connecting you, ' +
                  'please try again later, if problem persists ' +
                  'contact support (%s)', [ fSupportNumber ] );
    end;
  end;
end;

procedure TCashbookMigration.SetDefaultTransferMethod;
begin
  FHttpRequester.HTTPMethod := 'GET';
end;

function TCashbookMigration.StartedDataTransfer: Boolean;
begin
  Result := FDataTransferStarted;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.MarkSelectedClients(aFileStatus: Integer; aSelectClients : TStringList);
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

    CFRec.cfFile_Status := byte(aFileStatus);
  end;
  SaveAdminSystem;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.MarkSelectClient(aFileStatus: Integer; aClientCode : string);
const
  ThisMethodName = 'TCashbookMigration.MarkSelectClient';
var
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

  CFRec.cfFile_Status := byte(aFileStatus);

  SaveAdminSystem;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.MigrateClient(aClient : TClientObj; aSelectedData: TSelectedData;
           var aUploadID : string; var aErrorCode : integer;
           var aErrorDescription: string ): boolean;
var
  ClientBase : TClientBase;
  ChartExportCol : TChartExportCol;
  GSTMapCol : TGSTMapCol;
  BalDate : TStDate;
  OpeningBalanceDate : TStDate;
  UsedDivisions : TStringList;
  HasTransactions, HasPayees : boolean;
  CurrDay, CurrMonth, CurrYear : integer;
  DayFinStart, MonthFinStart, YearFinStart: Integer;
begin
  result := false;
  HasTransactions := false;
  fHasProvisionalAccountsAndMoved := false;

  // pre calculate Time frame start used later in Transactions and Journals
  fClientTimeFrameStart := GetTimeFrameStart(aClient.clFields.clFinancial_Year_Starts);
  MappingsData.GetMappingFromClient(aClient);
  CalculateAccountTotals.AddAutoContraCodes( aClient, false, true);
  try
    ClientBase := TClientBase.Create;
    try
      ClientBase.Token := fToken;

      if aSelectedData.NonTransferedTransactions then
        OpeningBalanceDate := CalculateOpeningBalanceDate(aClient)
      else
      begin
        if GetLastFullyCodedMonth(BalDate) then
          OpeningBalanceDate := incDate(BalDate, 1, 0, 0)
        else
        begin
          // Convert Financial Year Start from Client Details
          StDatetoDMY(MyClient.clFields.clFinancial_Year_Starts, DayFinStart, MonthFinStart, YearFinStart);
          StDateToDMY(CurrentDate, CurrDay, CurrMonth, CurrYear);
          OpeningBalanceDate := DMYtoStDate(DayFinStart, MonthFinStart, CurrYear, Epoch);

          if OpeningBalanceDate > CurrentDate then
            OpeningBalanceDate := incDate(OpeningBalanceDate, 0, 0, -1);
        end;
      end;

      // If Date in the future set to 1st day of current year and month
      if OpeningBalanceDate > CurrentDate then
      begin
        StDateToDMY(CurrentDate, CurrDay, CurrMonth, CurrYear);
        OpeningBalanceDate := DMYtoStDate(1, CurrMonth, CurrYear, BKDATEEPOCH);
      end;

      fClientMigrationState := cmsTransformData;
      if not FillBusinessData(aClient, ClientBase.ClientData.BusinessData, aSelectedData.FirmId, OpeningBalanceDate, aSelectedData.ChartOfAccountBalances, aErrorDescription) then
        Exit;

      if not FillBankFeedData(aClient, ClientBase.ClientData.BankFeedApplicationsData, aSelectedData.DoMoveRatherThanCopy, aErrorDescription) then
        Exit;

      fClientMigrationState := cmsAccessCltDB;

      ChartExportCol := TChartExportCol.Create(TChartExportItem);
      try
        ChartExportCol.FillChartExportCol(true);
        ChartExportCol.UpdateOpeningBalances(OpeningBalanceDate);
        GSTMapCol := TGSTMapCol.Create(TGSTMapItem);
        try
          GSTMapCol.FillGstClassMapArr;
          FillGstMapCol(ChartExportCol, GSTMapCol, false);

          if aSelectedData.NonTransferedTransactions then
          begin
            fClientMigrationState := cmsTransformData;
            if not FillTransactionData(aClient, ClientBase.ClientData.BankAccountsData, ClientBase.ClientData.ChartOfAccountsData, GSTMapCol, HasTransactions, aErrorDescription) then
              Exit;

            if not FillJournalData(aClient, ClientBase.ClientData.JournalsData, OpeningBalanceDate, GSTMapCol, aErrorDescription) then
              Exit;

            fClientMigrationState := cmsAccessCltDB;
          end;

          fClientMigrationState := cmsTransformData;
          UsedDivisions := TStringList.Create();
          UsedDivisions.Delimiter := ',';
          UsedDivisions.StrictDelimiter := true;
          try
            HasPayees := false;
            if aSelectedData.ChartOfAccount then
            begin
              if not FillPayeeData(aClient, aSelectedData.NonTransferedTransactions,
                                   ClientBase.ClientData.BankAccountsData, GSTMapCol,
                                   ClientBase.ClientData.PayeesData, HasPayees, aErrorDescription) then
                Exit;

              if not FillJobData(aClient, aSelectedData.NonTransferedTransactions,
                                 ClientBase.ClientData.BankAccountsData,
                                 ClientBase.ClientData.JobsData, aErrorDescription) then
                Exit;

              if not FillDivisionData(aClient, ClientBase.ClientData.DivisionsData, UsedDivisions, aErrorDescription) then
                Exit;
            end;

            if not FillChartOfAccountData(aClient, ClientBase.ClientData.ChartOfAccountsData, aSelectedData, ChartExportCol, GSTMapCol, UsedDivisions, HasTransactions, HasPayees, aErrorDescription) then
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

      if not UploadClient(ClientBase, aSelectedData, aUploadID, aErrorCode, aErrorDescription) then
        Exit;

      if aSelectedData.DoMoveRatherThanCopy then
        MarkAccountsForDelete(aClient);

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
function TCashbookMigration.CalculateOpeningBalanceDate(aClient : TClientObj) : TStDate;
var
  AccountIndex : integer;
  TransactionIndex : integer;
  BankAccount : TBank_Account;
  TransactionRec : tTransaction_Rec;
  MostRecentDate : TStDate;
  Day, Month, Year : Integer;
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

  Result := IncDate(Result, 1, 0, 0);

  StDateToDMY(Result, Day, Month, Year);
  if Day > 1 then
  begin
    Day := 1;
    inc(Month);
    if Month = 13 then
    begin
      Month := 1;
      inc(Year);
    end;

    Result := DMYtoStDate(Day, Month, Year, BKDATEEPOCH);
  end;
end;

function TCashbookMigration.CheckForValidTokens: Boolean;
begin
  Result := False;
  if ((Trim(FUnEncryptedToken) <> '') and
      (Trim(FRandomKey) <> ''))  then
    Result := True;
end;

//------------------------------------------------------------------------------
constructor TCashbookMigration.Create;
begin
  // Http
  fURLsArePreload := false;
  FHttpRequester := TIpsHTTPS.Create(nil);
  fMappingsData := TMappingsData.Create(TMappingData);
  HttpSetup;

  fCurrentMyDotUser := '';
  fHasProvisionalAccountsAndMoved := false;

  fProvisionalAccounts := TStringlist.Create;
  FLicenseType := ltCashbook;
  
  FSupportNumber := '';
  if Assigned(AdminSystem) then
    FSupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ]
end;

//------------------------------------------------------------------------------
destructor TCashbookMigration.Destroy;
begin
  // Http
  FreeAndNil(FHttpRequester);
  FreeAndNil(FMappingsData);
  FreeAndNil(fProvisionalAccounts);
  FreeAndNil(fURLThread);
  inherited;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.Login(const aEmail: string; const aPassword: string; 
           var aErrorCode : integer; var aErrorDescription : string;
           var aInvalidPass : boolean): boolean;
var
  Headers: THttpHeaders;
  PostData: TStringList;
  js: TlkJSONobject;
  sResponse: string;
//  sError: string;
  Token : string;
  NoOfSecondsToExpire : Integer;
begin
  Result := false;
  aInvalidPass := false;

  //Initialize token just before a login
  Token := '';
  FRefreshToken := '';
  NoOfSecondsToExpire := 0;
  FTokenExpiresAt := IncSecond(Now,NoOfSecondsToExpire);

  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';

  if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
  begin
    HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
    Exit;
  end;

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
      FDataRequestType := drtSignIn;

      // Cancelled?
      if not DoHttpSecure(
        'POST',
        PRACINI_CashbookAPILoginURL,
        Headers,
        PostData.DelimitedText,
        sResponse,
        aErrorCode,
        aErrorDescription) then
      begin
        if Pos('151: Bad Request', aErrorDescription) > 0 then
        begin
          aInvalidPass := true;
          aErrorDescription := 'Email address and/or password is invalid.' + #13#10 + 'Please try again.';
          LogUtil.LogMsg(lmInfo, UnitName, aErrorDescription);
        end
        else
          LogUtil.LogMsg(lmError, UnitName, 'Error running ' + GetAPIName + '.Login, Error Message : ' + aErrorDescription);

        exit;
      end;

      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;
      if Trim(FDataError) <> '' then
        Exit;

      // Parse JSON result
      if Assigned(FDataResponse) then
        js := FDataResponse as TlkJSONobject;

      if not assigned(js) then
      begin
        aErrorDescription := 'Error running ' + GetAPIName + '.Login, Error Message : No response from Server.';
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;

      // Get token
      Token := js.GetString('access_token');
      FRefreshToken := js.GetString('refresh_token');
      NoOfSecondsToExpire := StrToIntDef(js.GetString('expires_in'),0);
      FTokenExpiresAt := IncSecond(Now,NoOfSecondsToExpire);

      if (Trim(Token) <> '') and
        (Trim(FRefreshToken) <> '') and
        (NoOfSecondsToExpire > 0)then
        EncryptToken(Token)
      else
      begin
        aErrorDescription := 'Error running ' + GetAPIName + '.Login, Error Message : Can not find Access Token in response.';
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;

      fCurrentMyDotUser := aEmail;
      Result := true;

    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := 'Exception running ' + GetAPIName + ' .Login, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
      on E : Exception do
      begin
        aErrorDescription := 'Exception running ' + GetAPIName + ' .Login, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
    end;

  finally
    FreeAndNil(PostData);
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.GetFirms( var aFirms: TFirms;
           var aErrorCode : integer; var aErrorDescription: string): boolean;
var
  sURL: string;
  List: TlkJSONlist;
  RespStr : string;
begin
  Result := false;
  List := nil;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    try
      sURL := PRACINI_CashbookAPIFirmsURL;
      FDataRequestType := drtFirm;

      if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
      begin
        HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
        Exit;
      end;

      if not DoHttpSecureJson(sURL, nil, RespStr, aErrorCode, aErrorDescription) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      if Assigned(FDataResponse) then
      begin
        List := (FDataResponse as TlkJSONlist);
        RespStr := TlkJSON.GenerateText(List);
      end;
      if DebugMe then
        LogUtil.LogMsg(lmInfo, UnitName, RespStr);

      if Assigned(aFirms)  and Assigned(List) then
      begin
        aFirms.Clear;
        aFirms.Read(List);
      end;
    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := Format('Exception running %s.GetFirms, Error Message : ' + E.Message, [GetAPIName]);
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
      on E: Exception do
      begin
        aErrorDescription := Format('Exception running %s.GetFirms, Error Message : ' + E.Message, [GetAPIName]);
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then    
      FreeAndNil(FDataResponse);
  end;

  Result := true;
end;

function TCashbookMigration.GetSupportNumber: string;
begin
  FSupportNumber := '';
  try
    if Assigned(AdminSystem) then
      FSupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ]
    else
      if assigned( myClient ) then
        FSupportNumber := TContactInformation.SupportPhoneNo[ myClient.clFields.clCountry ];
  finally
    result := FSupportNumber;
  end;
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
  lsErrorCode : integer;
  lsErrorDescription  : string;
  ErrorIndex : integer;
  LastClientIndex : integer;
  DiffDispString : string;
  ClientErrorCode : TOpenClientError;
  UploadId : string;

  procedure AddVisualError();
  begin
    case fClientMigrationState of
      cmsAccessSysDB    : lsErrorDescription := Format('%s could not be accessed.', [CurrentClientCode]);
      cmsAccessCltDB    : lsErrorDescription := Format('%s could not be opened.', [CurrentClientCode]);
      cmsClientPassword : lsErrorDescription := Format('%s is password protected and could not be migrated.', [CurrentClientCode]);
      cmsTransformData  : lsErrorDescription := Format('%s data could not be migrated, please contact Support.', [CurrentClientCode]);
      cmsConnectToAPI   : lsErrorDescription := Format('%s was interrupted during upload, please try again.', [CurrentClientCode]);
      cmsUploadError    : lsErrorDescription := Format('%s could not be uploaded to Cashbook.', [CurrentClientCode]);
    end;
    aClientErrors.AddObject(lsErrorDescription, TObject(ClientIndex));
  end;
begin
  // Initialize ErrorList and progress event
  fClientMigrationState := cmsAccessSysDB;
  aClientErrors.clear;
  fProvisionalAccounts.Clear;

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
        lsErrorDescription := CurrentClientCode + ' Error finding Client in System File.';
        LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
        AddVisualError();
        Continue;
      end;

      if not AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status = bkConst.fsNormal then
      begin
        lsErrorDescription := CurrentClientCode + ' Error with Client, it is not in the correct status. ' +
                    'Current Status : ' + fsNames[AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status] +
                    ' needs to be in normal status.';
        LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
        AddVisualError();
        Continue;
      end;

      ClientFileCode := AdminSystem.fdSystem_Client_File_List.FindCode(CurrentClientCode).cfFile_Code;

      fClientMigrationState := cmsAccessCltDB;
      CltClient := nil;

      MarkSelectClient(ord(fsNormal), ClientFileCode);

      OpenAClientReturnErrors(ClientFileCode, CltClient, true, ClientErrorCode);

      if ClientErrorCode = oceClientSlientWithPassword then
        fClientMigrationState := cmsClientPassword;

      if not Assigned(CltClient) then
      begin
        lsErrorDescription := CurrentClientCode + ' Error opening Client file.';
        LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
        AddVisualError();
        Continue;
      end;
      fClientMigrationState := cmsAccessCltDB;

      MyClient := CltClient;
      try
        Screen.Cursor := crHourglass;
        SyncClientToAdmin(MyClient, True, True, False, False, True, True, False);

        if not MigrateClient(CltClient, aSelectedData, UploadId, lsErrorCode, lsErrorDescription) then
        begin
          lsErrorDescription := CurrentClientCode + ' ' + lsErrorDescription;
          LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
          AddVisualError();
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

          LogUtil.LogMsg(lmInfo, UnitName, CurrentClientCode + ' Successfully uploaded client to ' + BRAND_CASHBOOK_NAME + '. UploadId - ' + UploadId);
        end;
      finally
        MyClient := nil;
        AbandonAClient(CltClient);
      end;

    except
      on E: Exception do
      begin
        lsErrorDescription := CurrentClientCode + ' Exception opening Client, Error : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
        AddVisualError();
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

(*
procedure TCashbookMigration.OnIPWorksError(Sender: TObject; ErrorCode: Integer;
  const Description: String);
begin
  fIPWorksErrorCode        := ErrorCode;
  fIPWorksErrorDescription := Description;
end;
*)

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
