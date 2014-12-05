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
    fJson : TlkJSONobject;

    fABN : string;
    fBusinessName : string;
    fBusinessType : string;
    fClientCode : string;
    fFirmId : string;
    fFinancialYearStartMonth : integer;
  protected
  public
    constructor Create(aJson : TlkJSONobject);

    procedure CreateData();

    property ABN : string read fABN write fABN;
    property BusinessName : string read fBusinessName write fBusinessName;
    property BusinessType : string read fBusinessType write fBusinessType;
    property ClientCode : string read fClientCode write fClientCode;
    property FirmId : string read fFirmId write fFirmId;
    property FinancialYearStartMonth : integer read fFinancialYearStartMonth write fFinancialYearStartMonth;
  end;

  //----------------------------------------------------------------------------
  TCashbookClientData = class
  private
    fBusinessData : TBusinessData;
    fJson : TlkJSONobject;
  protected
  public
    constructor Create(aJson : TlkJSONobject);
    destructor Destroy; override;

    procedure CreateData();

    property BusinessData : TBusinessData read fBusinessData write fBusinessData;
  end;

  //----------------------------------------------------------------------------
  TFirm = class(TCollectionItem)
  private
  protected
  public
  end;

  //----------------------------------------------------------------------------
  TFirms = class(TCollection)
  private
  protected
  public
  end;

  //----------------------------------------------------------------------------
  TCashbookMigration = class
  private
    fCashbookClientData : TCashbookClientData;
    fJson : TlkJSONobject;

  protected
    procedure ClearJson();
  public
    constructor Create;
    destructor Destroy; override;

    function  Login(const aUserName: string; const aPassword: string;
                var aToken: string): boolean;

    function PostDataToCashBook() : boolean;
    function GetCashbookFirmIDs() : TFirms;

    property CashbookClientData : TCashbookClientData read fCashbookClientData write fCashbookClientData;
  end;

  //----------------------------------------------------------------------------
  function MigrateCashbook : TCashbookMigration;

//------------------------------------------------------------------------------
implementation

uses
  Globals;

var
  fCashbookMigration : TCashbookMigration;

//------------------------------------------------------------------------------
function MigrateCashbook : TCashbookMigration;
begin
  if Not Assigned(fCashbookMigration) then
  begin
    fCashbookMigration := TCashbookMigration.Create();
  end;

  Result := fCashbookMigration;
end;

//------------------------------------------------------------------------------
{ TBusinessData }
constructor TBusinessData.Create(aJson: TlkJSONobject);
begin
  fJson := aJson;
end;

//------------------------------------------------------------------------------
procedure TBusinessData.CreateData();
var
  Id : integer;
  JSONobject : TlkJSONobject;
begin
  JSONobject := TlkJSONobject.Create();
  JSONobject.Add('abn', fABN);
  JSONobject.Add('name', fBusinessName);
  JSONobject.Add('business_type', fBusinessType);
  JSONobject.Add('client_code', fClientCode);
  JSONobject.Add('firm_id', fFirmId);
  JSONobject.Add('financial_year_start_month', fFinancialYearStartMonth);

  fJson.Add('Business',JSONobject);
end;

//------------------------------------------------------------------------------
{ TCashbookClientData }
constructor TCashbookClientData.Create(aJson : TlkJSONobject);
begin
  fJson := aJson;
  fBusinessData := TBusinessData.create(fJson);
end;

//------------------------------------------------------------------------------
destructor TCashbookClientData.Destroy;
begin
  FreeAndNil(fBusinessData);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TCashbookClientData.CreateData;
begin
  BusinessData.CreateData();
end;

//------------------------------------------------------------------------------
{ TCashbookMigration }
constructor TCashbookMigration.Create;
begin
  fJson := TlkJSONobject.Create;
  fCashbookClientData := TCashbookClientData.create(fJson);
end;

//------------------------------------------------------------------------------
destructor TCashbookMigration.Destroy;
begin
  FreeAndNil(fCashbookClientData);
  FreeAndNil(fJson);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TCashbookMigration.ClearJson();
begin

end;

//------------------------------------------------------------------------------
function TCashbookMigration.Login(const aUserName: string;
  const aPassword: string; var aToken: string): boolean;
var
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
        'https://secure.myob.com/oauth2/v1/authorize',
        PostData.DelimitedText,
        sResponse,
        sError) then
      begin
        exit;
      end;

      // Parse JSON result
      js := TlkJSON.ParseText(sResponse) as TlkJSONobject;

      // Get token
      aToken := js.GetString('access_token');

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
function TCashbookMigration.PostDataToCashBook: boolean;
var
  Level : integer;
  JsonFile : TextFile;
  OutString : string;
begin
  Result := false;

  ClearJson();

  CashbookClientData.BusinessData.ABN := '53004085616';
  CashbookClientData.BusinessData.BusinessName := 'Business Name';
  CashbookClientData.BusinessData.BusinessType := 'Products';
  CashbookClientData.BusinessData.ClientCode := 'BIZ1';
  CashbookClientData.BusinessData.FirmId := '1-14TBO0P';
  CashbookClientData.BusinessData.FinancialYearStartMonth := 9;
  CashbookClientData.CreateData;

  AssignFile(JsonFile, DATADIR + 'CashbookData.json');
  try
    Rewrite(JsonFile);

    Level := 0;
    OutString := GenerateReadableText(fJson,Level);
    writeln(JsonFile, OutString);
  finally
    Closefile(JsonFile);
  end;

  Result := true;
end;

//------------------------------------------------------------------------------
function TCashbookMigration.GetCashbookFirmIDs: TFirms;
var
  DummyData : string;
  JsonString : TlkJSONstring;
  Max : integer;
begin
  Result := nil;
  DummyData := '[' +
               '{' +
               '''id'':''1-14TBO0P'',' +
               '''name'':''CashBook Accountant Firm AU''' +
               '},' +
               '{' +
               '''id'':''3-48272'',' +
               '''name'':''CashBook Accountant Firm NZ''' +
               '}'+
               ']';

  DummyData := '[{''id'': "1-14TBO0P'',''name'': ''CashBook Accountant Firm AU''},{''id'': ''3-48272'',''name'': ''CashBook Accountant Firm NZ''}]';

  ClearJson();
  FreeAndNil(fJson);
  fJson := TlkJSON.ParseText(DummyData) as TlkJSONobject;

  if Assigned(fJson) then
    Max := fJson.Count;
end;

//------------------------------------------------------------------------------
initialization
  fCashbookMigration := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fCashbookMigration);

end.
