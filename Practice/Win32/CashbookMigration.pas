unit CashbookMigration;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  uLkJSON,
  HttpsProgressFrm,
  CryptUtils,
  ZlibExGZ,
  IdCoder,
  IdCoderMIME;

type
  //----------------------------------------------------------------------------
  TListDestroy = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

  end;

  //----------------------------------------------------------------------------
  TFirm = class
  private
    fID: string;
    fName: string;

  public
    procedure Read(const aJson: TlkJSONobject);

    property  ID: string read fID write fID;
    property  Name: string read fName write fName;

  end;

  //----------------------------------------------------------------------------
  TFirms = class(TListDestroy)
  public
    function  GetItem(const aIndex: integer): TFirm;
    property  Items[const aIndex: integer]: TFirm read GetItem; default;

    procedure Read(const aJson: TlkJSONlist);

  end;

  //----------------------------------------------------------------------------
  TBusinessData = class
  private
    fABN: string;
    fBusinessName: string;
    fBusinessType: string;
    fClientCode: string;
    fFirmId: string;
    fFinancialYearStartMonth: integer;

  public
    procedure Write(const aJson: TlkJSONobject);

    property  ABN: string read fABN write fABN;
    property  BusinessName: string read fBusinessName write fBusinessName;
    property  BusinessType: string read fBusinessType write fBusinessType;
    property  ClientCode: string read fClientCode write fClientCode;
    property  FirmId: string read fFirmId write fFirmId;
    property  FinancialYearStartMonth: integer read fFinancialYearStartMonth
                write fFinancialYearStartMonth;

  end;

  //----------------------------------------------------------------------------
  TClientData = class
  private
    fBusinessData: TBusinessData;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    function  GetData: string;

    property  BusinessData: TBusinessData read fBusinessData;

  end;

  //----------------------------------------------------------------------------
  TFile = class
  private
    fID: string;
    fFileName: string;
    fDataLength: integer;
    fData: string;

    function  GetFileHash: string;
    function  GetDataAsZipBase64: string;

  public
    constructor Create;

    procedure Write(const aJson: TlkJSONobject);

    property  ID: string read fID write fID;
    property  FileName: string read fFileName write fFileName;
    property  DataLength: integer read fDataLength write fDataLength;
    property  Data: string read fData write fData;

  end;

  //----------------------------------------------------------------------------
  TParameters = class(TListDestroy)
  private
    fDataStore: string;
    fQueue: string;

  public
    procedure Write(const aJson: TlkJSONlist);

    property  DataStore: string read fDataStore write fDataStore;
    property  Queue: string read fQueue write fQueue;

  end;

  //----------------------------------------------------------------------------
  TFileUpload = class
  private
    fID: string;
    fUploadType: integer;
    fFile: TFile;
    fParameters: TParameters;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property  ID: string read fID;
    property  UploadType: integer read fUploadType write fUploadType;
    property  Files: TFile read fFile;
    property  Parameters: TParameters read fParameters;

  end;

  //----------------------------------------------------------------------------
  TUrlsMap = class
  private
    fName: string;
    fValue: string;

  public
    procedure Read(const aJson: TlkJSONobject);

    property  Name: string read fName write fName;
    property  Value: string read fValue write fValue;

  end;

  //----------------------------------------------------------------------------
  TFileUploadResult = class
  private
    fUploadID: string;
    fResponseCode: integer;
    fUrlsMap: TUrlsMap;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Read(const aJson: TlkJSONobject);

    property  UploadID: string read fUploadID write fUploadID;
    property  RespondeCode: integer read fResponseCode write fResponseCode;
    property  UrlsMap: TUrlsMap read fUrlsMap;

  end;

  //----------------------------------------------------------------------------
  TCashbookMigration = class
  private
    fToken: string;

    function  DoHttpSecureJson(const aURL: string; const aRequest: TlkJSONbase;
                var aResponse: TlkJSONbase; var aError: string): boolean;

  public
    function  Login(const aUserName: string; const aPassword: string): boolean;

    function  GetFirms(var aFirms: TFirms; var aError: string): boolean;

    function  FileUpload(const aUpload: TFileUpload; aResult: TFileUploadResult;
                var aError: string): boolean;

  end;

  //----------------------------------------------------------------------------
  function  MigrateCashbook: TCashbookMigration;

//------------------------------------------------------------------------------
implementation

uses
  Globals;

const
  //URL_BASE = 'https://burwood.cashbook.us/';
  URL_BASE = 'http://10.72.20.37/';

var
  fCashbookMigration: TCashbookMigration;

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
{ TListDestroy }
procedure TListDestroy.Notify(Ptr: Pointer; Action: TListNotification);
var
  Item: TObject;
begin
  inherited;

  if (Action = lnDeleted) then
  begin
    Item := TObject(Ptr);
    FreeAndNil(Item);
  end;
end;

//------------------------------------------------------------------------------
{ TFirm }
procedure TFirm.Read(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  ID := aJson.getString('id');
  Name := aJson.getString('name');
end;

//------------------------------------------------------------------------------
{ TFirms }
function TFirms.GetItem(const aIndex: integer): TFirm;
begin
  result := TFirm(Get(aIndex));
end;

//------------------------------------------------------------------------------
procedure TFirms.Read(const aJson: TlkJSONlist);
var
  i: integer;
  Child: TlkJSONobject;
  Firm: TFirm;
begin
  ASSERT(assigned(aJson));

  for i := 0 to aJson.Count-1 do
  begin
    Child := aJson.Child[i] as TlkJSONobject;

    // New firm
    Firm := TFirm.Create;
    Add(Firm);

    // Read firm
    Firm.Read(Child);
  end;
end;

//------------------------------------------------------------------------------
{ TBusinessData }
procedure TBusinessData.Write(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  aJson.Add('abn', ABN);
  aJson.Add('name', BusinessName);
  aJson.Add('business_type', BusinessType);
  aJson.Add('client_code', ClientCode);
  aJson.Add('firm_id', FirmId);
  aJson.Add('financial_year_start_month', FinancialYearStartMonth);
end;

//------------------------------------------------------------------------------
{ TClientData }
constructor TClientData.Create;
begin
  fBusinessData := TBusinessData.Create;
end;

//------------------------------------------------------------------------------
destructor TClientData.Destroy;
begin
  FreeAndNil(fBusinessData);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TClientData.Write(const aJson: TlkJSONobject);
var
  JsonBusiness: TlkJSONobject;
begin
  // Business data
  JsonBusiness := TlkJSONobject.Create;
  aJson.Add('Business', JsonBusiness);
  BusinessData.Write(JsonBusiness);
end;

//------------------------------------------------------------------------------
function TClientData.GetData: string;
var
  Json: TlkJSONobject;
begin
  result := '';

  Json := nil;
  try
    // Write Json
    Json := TlkJSONobject.Create;
    Write(Json);

    // Jason to text
    result := TlkJSON.GenerateText(Json);
  finally
    FreeAndNil(Json);
  end;
end;

//------------------------------------------------------------------------------
{ TFile }
constructor TFile.Create;
var
  NewID: TGUID;
begin
  CreateGUID(NewID);
  fID := GUIDToString(NewID);
end;

//------------------------------------------------------------------------------
function TFile.GetFileHash: string;
begin
  result := HashStr(fData);
end;

//------------------------------------------------------------------------------
function TFile.GetDataAsZipBase64: string;
begin
  result := ZCompressStrG(fData);

  result := EncodeString(TidEncoderMIME, result);
end;

//------------------------------------------------------------------------------
procedure TFile.Write(const aJson: TlkJSONobject);
var
  iDataLength: integer;
  sData: string;
begin
  aJson.Add('Id', fId);

  aJson.Add('FileName', fFileName);

  aJson.Add('FileHash', GetFileHash);

  sData := GetDataAsZipBase64;

  iDataLength := Length(sData);
  aJson.Add('DataLength', iDataLength);

  aJson.Add('Data', sData);
end;

//------------------------------------------------------------------------------
{ TParameters }
procedure TParameters.Write(const aJson: TlkJSONlist);
var
  Parameter: TlkJSONobject;
begin
  // DataStore
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'DataStore');
  Parameter.Add('Value', fDataStore);

  // Queue
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'Queue');
  Parameter.Add('Value', fQueue);
end;

//------------------------------------------------------------------------------
{ TFileUpload }
constructor TFileUpload.Create;
var
  NewID: TGUID;
begin
  CreateGUID(NewID);
  fID := GUIDtoString(NewID);

  fUploadType := 3;

  fFile := TFile.Create;

  fParameters := TParameters.Create;
end;

//------------------------------------------------------------------------------
destructor TFileUpload.Destroy;
begin
  FreeAndNil(fFile);
  FreeAndNil(fParameters);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TFileUpload.Write(const aJson: TlkJSONobject);
var
  Files: TlkJSONlist;
  NewFile: TlkJSONobject;
  Parameters: TlkJSONlist;
begin
  aJson.Add('Id', fID);

  aJson.Add('UploadType', fUploadType);

  // File
  Files := TlkJSONlist.Create;
  aJson.Add('Files', Files);
  NewFile := TlkJSONobject.Create;
  Files.Add(NewFile);
  fFile.Write(NewFile);

  // Parameters
  Parameters := TlkJSONlist.Create;
  aJson.Add('Parameters', Parameters);
  fParameters.Write(Parameters);
end;

//------------------------------------------------------------------------------
{ TUrlsMap }
procedure TUrlsMap.Read(const aJson: TlkJSONobject);
begin
  fName := aJson.NameOf[0];

  fValue := aJson.getString(0);
end;

//------------------------------------------------------------------------------
{ TFileUploadResult }
constructor TFileUploadResult.Create;
begin
  fUrlsMap := TUrlsMap.Create;
end;

//------------------------------------------------------------------------------
destructor TFileUploadResult.Destroy;
begin
  FreeAndNil(fUrlsMap);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TFileUploadResult.Read(const aJson: TlkJSONobject);
var
  UrlsMap: TlkJSONobject;
begin
  fUploadId := aJson.getString('UploadId');

  fResponseCode := aJson.getInt('ResponseCode');

  UrlsMap := (aJson.Field['UrlsMap'] as TlkJSONobject);
  fUrlsMap.Read(UrlsMap);
end;

//------------------------------------------------------------------------------
function TCashbookMigration.Login(const aUserName: string;
  const aPassword: string): boolean;
var
  Headers: THttpHeaders;
  PostData: TStringList;
  js: TlkJSONobject;
  sResponse: string;
  sError: string;
begin
  result := false;

  // Setup REST request
  PostData := nil;
  js := nil;
  try
    try
      Headers.ContentType := 'application/x-www-form-urlencoded';

      PostData := TStringList.Create;
      PostData.Delimiter := '&';
      PostData.StrictDelimiter := true;

      PostData.Values['client_id'] := 'bankLink-practice5';
      PostData.Values['client_secret'] := 'z1sb6ggkfhlOXip';
      PostData.Values['username'] := aUserName;
      PostData.Values['password'] := aPassword;
      PostData.Values['grant_type'] := 'password';
      PostData.Values['scope'] := 'AccountantsFramework mydot.contacts.read mydot.assets.read Assets la.global';

      // Cancelled?
      if not DoHttpSecure(
        'POST',
        'https://test.secure.myob.com/oauth2/v1/Authorize',
        Headers,
        PostData.DelimitedText,
        sResponse,
        sError) then
      begin
        exit;
      end;

      // Parse JSON result
      js := TlkJSON.ParseText(sResponse) as TlkJSONobject;
      if not assigned(js) then
        exit;

      // Get token
      fToken := js.GetString('access_token');
      if (fToken = '') then
        exit;

      result := true;

    except
      // Ignore specifics
      exit;
    end;

  finally
    FreeAndNil(PostData);
    FreeAndNil(js);
  end;
end;

//------------------------------------------------------------------------------
{ TCashbookMigration }
function TCashbookMigration.DoHttpSecureJson(const aURL: string;
  const aRequest: TlkJSONbase; var aResponse: TlkJSONbase; var aError: string
  ): boolean;
var
  sVerb: string;
  Headers: THttpHeaders;
  sRequest: string;
  sResponse: string;
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
    Headers.ContentType := 'application/json; charset=utf-8';
    Headers.Accept := 'application/vnd.cashbook-v1+json';
    Headers.Authorization := 'Bearer ' + fToken;
    Headers.MyobApiAccessToken := fToken;

    // Body
    if assigned(aRequest) then
      sRequest := TlkJSON.GenerateText(aRequest);

    // Http
    if not DoHttpSecure(sVerb, aURL, Headers, sRequest, sResponse, aError) then
      exit;

    // Response
    aResponse := TlkJSON.ParseText(sResponse);
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
function TCashbookMigration.GetFirms(var aFirms: TFirms; var aError: string
  ): boolean;
var
  sURL: string;
  Response: TlkJSONbase;
  List: TlkJSONlist;
begin
  result := false;

  aFirms := nil;

  Response := nil;
  try
    try
      sURL := URL_BASE + 'api/firms';

      if not DoHttpSecureJson(sURL, nil, Response, aError) then
        exit;

      List := (Response as TlkJSONlist);

      aFirms := TFirms.Create;

      aFirms.Read(List);
    except
      on E: Exception do
      begin
        FreeAndNil(aFirms);

        exit;
      end;
    end;
  finally
    FreeAndNil(Response);
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.FileUpload(const aUpload: TFileUpload;
  aResult: TFileUploadResult; var aError: string): boolean;
var
  Request: TlkJSONobject;
  sURL: string;
  ResponseBase: TlkJSONbase;
  Response: TlkJSONobject;
begin
  ASSERT(assigned(aUpload));

  result := false;

  aResult := nil;

  Request := nil;
  ResponseBase := nil;
  Response := nil;

  try
    try
      // Request
      Request := TlkJSONobject.Create;
      aUpload.Write(Request);

      // HTTP
      sURL := URL_BASE + 'ADCommon/Upload';
      if not DoHttpSecureJson(sURL, Request, ResponseBase, aError) then
        exit;
      ASSERT(assigned(ResponseBase));

      // Response
      Response := (ResponseBase as TlkJSONobject);

      // Result
      aResult := TFileUploadResult.Create;
      aResult.Read(Response);
    except
      on E: Exception do
      begin
        FreeAndNil(aResult);

        aError := E.Message;
        exit;
      end;
    end;
  finally
    FreeAndNil(Response);
    FreeAndNil(ResponseBase);
    FreeAndNil(Response);
  end;

  result := true;
end;

//------------------------------------------------------------------------------
initialization
begin
  fCashbookMigration := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fCashbookMigration);
end;

end.
