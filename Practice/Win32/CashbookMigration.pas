unit CashbookMigration;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes;

type
  { 
  "business": { 
    "abn": "53004085616”, 
    "name": “Business Name”, 
    "business_type": "Products”, 
    "client_code": “BIZ1”, 
    "firm_id": "1-14TBO0P”,
    “financial_year_start_month”: 9 
  }



  //----------------------------------------------------------------------------
  TBusinessData = class
  private
    fABN : string;
    fBusinessName : string;
    fBusinessType : string;
    fClientCode : string;
    fFirmId : string;
    fFinancialYearStartMonth : integer;
  protected
  public
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
  protected
  public


    property BusinessData : TBusinessData read fBusinessData write fBusinessData;
  end;

  //----------------------------------------------------------------------------
  TCashbookMigration = class
  private
  protected


  public
    function PostDataToCashBook() : boolean;
  end;

  //----------------------------------------------------------------------------
  function MigrateCashbook : TCashbookMigration;

//------------------------------------------------------------------------------
implementation

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
{ TCashbookMigration }
function TCashbookMigration.PostDataToCashBook: boolean;
begin

end;

//------------------------------------------------------------------------------
initialization
  fCashbookMigration := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fCashbookMigration);

end.
