unit CashbookMigration;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  uLkJSON,
  HttpsProgressFrm;

type
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
    constructor Create;
    destructor  Destroy; override;

    procedure Read(const aJson: TlkJSONobject);
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
  TCashbookClientData = class
  private
    fBusinessData: TBusinessData;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Read(const aJson: TlkJSONobject);
    procedure Write(const aJson: TlkJSONobject);

    property  BusinessData: TBusinessData read fBusinessData write fBusinessData;
  end;

  //----------------------------------------------------------------------------
  TFirm = class(TCollectionItem)
  private
  public
  end;

  //----------------------------------------------------------------------------
  TFirms = class(TCollection)
  private
  public
  end;

  //----------------------------------------------------------------------------
  TCashbookMigration = class
  private
    fCashbookClientData: TCashbookClientData;
    fToken: string;

    function  DoHttpSecureJson(const aVerb: string; const aURL: string;
                const aRequest: TlkJSONobject; var aResponse: TlkJSONobject;
                var aError: string): boolean;

  public
    constructor Create;
    destructor  Destroy; override;

    function  Login(const aUserName: string; const aPassword: string): boolean;

    function  GetFirms(const aFirms: TFirms): boolean;

    property  CashbookClientData: TCashbookClientData read fCashbookClientData
                write fCashbookClientData;
  end;

  //----------------------------------------------------------------------------
  function MigrateCashbook : TCashbookMigration;

//------------------------------------------------------------------------------
implementation

uses
  Globals;

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
{ TBusinessData }
constructor TBusinessData.Create;
begin
end;

//------------------------------------------------------------------------------
destructor TBusinessData.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------
procedure TBusinessData.Read(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  // TODO
end;

//------------------------------------------------------------------------------
procedure TBusinessData.Write(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  aJson.Add('abn', fABN);
  aJson.Add('name', fBusinessName);
  aJson.Add('business_type', fBusinessType);
  aJson.Add('client_code', fClientCode);
  aJson.Add('firm_id', fFirmId);
  aJson.Add('financial_year_start_month', fFinancialYearStartMonth);
end;

//------------------------------------------------------------------------------
{ TCashbookClientData }
constructor TCashbookClientData.Create;
begin
  fBusinessData := TBusinessData.Create;
end;

//------------------------------------------------------------------------------
destructor TCashbookClientData.Destroy;
begin
  FreeAndNil(fBusinessData);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TCashbookClientData.Read(const aJson: TlkJSONobject);
begin
  // TODO
end;

//------------------------------------------------------------------------------
procedure TCashbookClientData.Write(const aJson: TlkJSONobject);
var
  JsonBusiness: TlkJSONobject;
begin
  // Business
  JsonBusiness := TlkJSONobject.Create;
  aJson.Add('Business', JsonBusiness);
  fBusinessData.Write(JsonBusiness);
end;

//------------------------------------------------------------------------------
{ TCashbookMigration }
constructor TCashbookMigration.Create;
begin
end;

//------------------------------------------------------------------------------
destructor TCashbookMigration.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.DoHttpSecureJson(const aVerb: string;
  const aURL: string; const aRequest: TlkJSONobject;
  var aResponse: TlkJSONobject; var aError: string): boolean;
var
  Headers: THttpHeaders;
  sRequest: string;
  sResponse: string;
begin
  result := false;

  aResponse := nil;

  try
    Headers.ContentType := 'application/json';
    Headers.Accept := 'application/vnd.cashbook-v1+json';
    Headers.Authorization := 'Bearer ' + fToken;

    sRequest := TlkJSON.GenerateText(aRequest);

    if not DoHttpSecure(aVerb, aURL, Headers, sRequest, sResponse, aError) then
      exit;

    aResponse := TlkJSON.ParseText(sResponse) as TlkJSONobject;
    if not assigned(aResponse) then
      exit;
  except
    on E: Exception do
    begin
      exit;
    end;
  end;

  result := true;
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

      PostData.Values['client_id'] := 'ge64vzfgx2c93msbhu84vb53';
      PostData.Values['client_secret'] := '4wUpbF9m49wCMMepb5mZhMDG';
      PostData.Values['username'] := aUserName;
      PostData.Values['password'] := aPassword;
      PostData.Values['grant_type'] := 'password';
      PostData.Values['scope'] := 'CompanyFile AccountantsFramework';

      // Cancelled?
      if not DoHttpSecure(
        'POST',
        'https://secure.myob.com/oauth2/v1/authorize',
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
function TCashbookMigration.GetFirms(const aFirms: TFirms): boolean;
begin
  // TODO
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
