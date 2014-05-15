unit ChartExportToMYOBCashbook;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  Forms,
  FrmChartExportToMYOBCashBook;

type
  TCashBookChartClasses = (ccNone,
                           ccIncome,
                           ccExpense,
                           ccOtherIncome,
                           ccOtherExpense,
                           ccAsset,
                           ccLiabilities,
                           ccEquity);

  TCashBookGSTClasses = (cgNone,
                         cgGoodsandServices,
                         cgCapitalAcquisitions,
                         cgExportSales,
                         cgGSTFree,
                         cgInputTaxedSales,
                         cgPurchaseForInput,
                         cgNotReportable,
                         cgGSTNotRegistered,
                         cgExempt,
                         cgZeroRated,
                         cgCustoms);

  PNodeData = ^TNodeData;
  TNodeData = record
    Source: Integer;
  end;

  //----------------------------------------------------------------------------
  TChartExportItem = class(TCollectionItem)
  private
    fIsBasicChartItem : boolean;
    fAccountCode : string;
    fAccountDescription : string;
    fReportGroupId : byte;
    fGSTClassId : byte;
    fOpeningBalance : string;
    fOpeningBalanceDate : string;
  public
    property IsBasicChartItem : boolean read fIsBasicChartItem write fIsBasicChartItem;
    property AccountCode : string read fAccountCode write fAccountCode;
    property AccountDescription : string read fAccountDescription write fAccountDescription;
    property ReportGroupId : byte read fReportGroupId write fReportGroupId;
    property GSTClassId : byte read fGSTClassId write fGSTClassId;
    property OpeningBalance : string read fOpeningBalance write fOpeningBalance;
    property OpeningBalanceDate : string read fOpeningBalanceDate write fOpeningBalanceDate;
  end;

  //----------------------------------------------------------------------------
  TChartExportCol = class(TCollection)
  private
  protected
    procedure AddChartExportItem(aIsBasicChartItem : boolean;
                                 aAccountCode : string;
                                 aAccountDescription : string;
                                 aReportGroupId : byte;
                                 aGSTClassId : byte );
  public
    destructor Destroy; override;

    procedure FillChartExportCol();
    function CheckAccountCodesLength(aErrors : TStringList) : Boolean;
    function ItemAtColIndex(aClientChartIndex: integer; out aChartExportItem : TChartExportItem) : boolean;
  end;

  //----------------------------------------------------------------------------
  TGSTMapItem = class(TCollectionItem)
  private
    fGstIndex : integer;
    fPracticeGstCode : string;
    fPracticeGstDesc : string;
    fCashbookGstClass : TCashBookGSTClasses;
  public
    property GstIndex : integer read fGstIndex write fGstIndex;
    property PracticeGstCode : string read fPracticeGstCode write fPracticeGstCode;
    property PracticeGstDesc : string read fPracticeGstDesc write fPracticeGstDesc;
    property CashbookGstClass : TCashBookGSTClasses read fCashbookGstClass write fCashbookGstClass;
  end;

  //----------------------------------------------------------------------------
  TGSTMapClassInfo = class
  private
    fCashbookGstClass : TCashBookGSTClasses;
    fCashbookGstClassDesc : string;
    procedure GetCashbookGstSeparateClassDesc(var aCashBookGstClassCode,
      aCashBookGstClassDesc: string);

  protected
    procedure GetMYOBCashbookGSTDetails(aCashBookGstClass : TCashBookGSTClasses;
                                        var aCashBookGstClassCode : string;
                                        var aCashBookGstClassDesc : string);

    function GetCashbookGstClassDesc() : string;
  public
    function GetCashBookCode() : string;
    function GetCashBookDesc() : string;

    property CashbookGstClass : TCashBookGSTClasses read fCashbookGstClass write fCashbookGstClass;
    property CashbookGstClassDesc : string read GetCashbookGstClassDesc;
  end;

  //----------------------------------------------------------------------------
  TGSTMapClassInfoArr = Array of TGSTMapClassInfo;

  //----------------------------------------------------------------------------
  TGSTMapCol = class(TCollection)
  private
    fGSTMapClassInfoArr : TGSTMapClassInfoArr;
    fPrevGSTFileLocation : string;
  protected
    procedure AddGSTMapItem(aGstIndex : integer;
                            aPracticeGstCode : string;
                            aPracticeGstDesc : string;
                            aCashbookGstClass : TCashBookGSTClasses);

    function GetMappedAUGSTTypeCode(aGSTClassDescription : string): TCashBookGSTClasses;
  public
    destructor Destroy; override;

    procedure FillGstMapCol();
    procedure FillGstClassMapArr();
    function ItemAtGstIndex(aGstIndex: integer; out aGSTMapItem : TGSTMapItem) : boolean;
    function ItemAtColIndex(aColIndex: integer; out aGSTMapItem : TGSTMapItem) : boolean;
    function FindItemUsingPracCode(aPracticeGstCode : string;
                                   var aGSTMapItem : TGSTMapItem) : boolean;

    function GetGSTClassCode(aCashbookGstClass : TCashBookGSTClasses) : string;
    function GetGSTClassDesc(aCashbookGstClass : TCashBookGSTClasses) : string;
    function GetGSTClassDescUsingClass(aCashbookGstClass : TCashBookGSTClasses) : string;
    function GetGSTClassUsingClassDesc(aCashbookGstClassDesc : string) : TCashBookGSTClasses;
    function GetGSTClassMapArr() : TGSTMapClassInfoArr;

    function LoadGSTFile(var aFileLines : TStringList; var aFileName : string; var aError : string) : Boolean; overload;
    function LoadGSTFile(var aFilename : string; var aError : string) : boolean; overload;
    function SaveGSTFile(aFilename: string; aError : string): Boolean;

    property PrevGSTFileLocation : string read fPrevGSTFileLocation write fPrevGSTFileLocation;
  end;

  //----------------------------------------------------------------------------
  TChartExportToMYOBCashbook = class
  private
    fCountry : Byte;
    fChartExportCol : TChartExportCol;
    fGSTMapCol : TGSTMapCol;
    fExportChartFrmProperties : TExportChartFrmProperties;
  protected
    function GetMappedReportGroupId(aReportGroup : byte) : TCashBookChartClasses;
    function GetMappedReportGroupCode(aReportGroup : byte) : string;
    function GetCrDrSignFromReportGroup(aReportGroup : byte) : integer;

    function GetGSTClassTypeIndicatorFromGSTClass(aGST_Class : byte) : byte;
    function GetMappedNZGSTTypeCode(aGSTClassTypeIndicator : byte) : TCashBookGSTClasses;
    procedure GetMYOBCashbookGSTDetails(aCashBookGstClass : TCashBookGSTClasses;
                                        var aCashBookGstClassCode : string;
                                        var aCashBookGstClassDesc : string);
    function RunExportChartToFile(aErrorStr : string) : boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure DoChartExport(aPopupParent: TForm);

    property Country : Byte read fCountry write fCountry;
    property ChartExportCol : TChartExportCol read fChartExportCol write fChartExportCol;
    property GSTMapCol : TGSTMapCol read fGSTMapCol write fGSTMapCol;
    property ExportChartFrmProperties : TExportChartFrmProperties read fExportChartFrmProperties write fExportChartFrmProperties;
  end;

//------------------------------------------------------------------------------
function ChartExportToMYOBEssentialsCashbook() : TChartExportToMYOBCashbook;

//------------------------------------------------------------------------------
implementation

uses
  ErrorMoreFrm,
  FrmChartExportMapGSTClass,
  CountryUtils,
  BKConst,
  Globals,
  BKDEFS,
  glConst,
  LogUtil;

Const
  UnitName = 'ChartExportToMYOBCashbook';
  PRAC_GST_CODE = 0;
  PRAC_GST_DESC = 1;
  CASHBOOK_GST_CODE = 2;
  CASHBOOK_GST_DESC = 3;

var
  fChartExportToMYOBCashbook : TChartExportToMYOBCashbook;

//------------------------------------------------------------------------------
function ChartExportToMYOBEssentialsCashbook() : TChartExportToMYOBCashbook;
begin
  if not Assigned(fChartExportToMYOBCashbook) then
    fChartExportToMYOBCashbook := TChartExportToMYOBCashbook.Create;

  Result := fChartExportToMYOBCashbook;
end;

{ TChartExportCol }
//------------------------------------------------------------------------------
procedure TChartExportCol.AddChartExportItem(aIsBasicChartItem : boolean;
                                             aAccountCode : string;
                                             aAccountDescription : string;
                                             aReportGroupId : byte;
                                             aGSTClassId : byte);
var
  NewChartExportItem : TChartExportItem;
begin
  NewChartExportItem := TChartExportItem.Create(Self);

  NewChartExportItem.IsBasicChartItem   := aIsBasicChartItem;
  NewChartExportItem.AccountCode        := aAccountCode;
  NewChartExportItem.AccountDescription := aAccountDescription;
  NewChartExportItem.ReportGroupId      := aReportGroupId;
  NewChartExportItem.GSTClassId         := aGSTClassId;
end;

//------------------------------------------------------------------------------
destructor TChartExportCol.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.FillChartExportCol;
var
  ChartIndex : integer;
  AccountRec : pAccount_Rec;
begin
  Self.Clear;
  for ChartIndex := 0 to MyClient.clChart.ItemCount-1 do
  begin
    AccountRec := MyClient.clChart.Account_At(ChartIndex);

    AddChartExportItem(not AccountRec.chHide_In_Basic_Chart,
                       AccountRec.chAccount_Code,
                       AccountRec.chAccount_Description,
                       AccountRec.chAccount_Type,
                       AccountRec.chGST_Class);
  end;
end;

//------------------------------------------------------------------------------
function TChartExportCol.CheckAccountCodesLength(aErrors : TStringList) : Boolean;
var
  ChartIndex : integer;
  AccountRec : pAccount_Rec;
begin
  for ChartIndex := 0 to MyClient.clChart.ItemCount-1 do
  begin
    AccountRec := MyClient.clChart.Account_At(ChartIndex);

    if length(AccountRec.chAccount_Code) > 10 then
      aErrors.Add(AccountRec.chAccount_Code + ' - ' + AccountRec.chAccount_Description);
  end;

  Result := (aErrors.Count = 0);
end;

//------------------------------------------------------------------------------
function TChartExportCol.ItemAtColIndex(aClientChartIndex: integer; out aChartExportItem: TChartExportItem): boolean;
begin
  aChartExportItem := nil;
  result := false;

  if (aClientChartIndex >= 0) and (aClientChartIndex < Self.Count) then
  begin
    aChartExportItem := TChartExportItem(self.Items[aClientChartIndex]);
    Result := true;
  end;
end;

{ TGSTMapClassInfo }
//------------------------------------------------------------------------------
procedure TGSTMapClassInfo.GetMYOBCashbookGSTDetails(aCashBookGstClass: TCashBookGSTClasses;
                                                     var aCashBookGstClassCode,
                                                         aCashBookGstClassDesc: string);
begin
  aCashBookGstClassCode := '';
  aCashBookGstClassDesc := '';

  case aCashBookGstClass of
    cgGoodsandServices : begin
      aCashBookGstClassCode := 'GST';
      aCashBookGstClassDesc := 'Goods & Services Tax';
    end;
    cgCapitalAcquisitions : begin
      aCashBookGstClassCode := 'CAP';
      aCashBookGstClassDesc := 'Capital Acquisitions';
    end;
    cgExportSales : begin
      aCashBookGstClassCode := 'EXP';
      aCashBookGstClassDesc := 'Export Sales';
    end;
    cgGSTFree : begin
      aCashBookGstClassCode := 'FRE';
      aCashBookGstClassDesc := 'GST Free';
    end;
    cgInputTaxedSales : begin
      aCashBookGstClassCode := 'ITS';
      aCashBookGstClassDesc := 'Input Taxed Sales';
    end;
    cgPurchaseForInput : begin
      aCashBookGstClassCode := 'INP';
      aCashBookGstClassDesc := 'Purchases for Input Tax Sales';
    end;
    cgNotReportable : begin
      aCashBookGstClassCode := 'NTR';
      aCashBookGstClassDesc := 'Not Reportable';
    end;
    cgGSTNotRegistered : begin
      aCashBookGstClassCode := 'GNR';
      aCashBookGstClassDesc := 'GST Not Registered';
    end;
    cgExempt : begin
      aCashBookGstClassCode := 'E';
      aCashBookGstClassDesc := 'Exempt';
    end;
    cgZeroRated : begin
      aCashBookGstClassCode := 'Z';
      aCashBookGstClassDesc := 'Zero-Rated';
    end;
    cgCustoms : begin
      aCashBookGstClassCode := 'I';
      aCashBookGstClassDesc := 'GST on Customs Invoice';
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapClassInfo.GetCashbookGstClassDesc: string;
var
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
begin
  Result := '';

  GetMYOBCashbookGSTDetails(fCashbookGstClass, CashBookGstClassCode, CashBookGstClassDesc);
  if (CashBookGstClassCode > '') and (CashBookGstClassDesc > '') then
    Result := CashBookGstClassCode + ' - ' + CashBookGstClassDesc;
end;

//------------------------------------------------------------------------------
function TGSTMapClassInfo.GetCashBookCode: string;
var
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
begin
  GetMYOBCashbookGSTDetails(fCashbookGstClass, CashBookGstClassCode, CashBookGstClassDesc);
  Result := CashBookGstClassCode;
end;

//------------------------------------------------------------------------------
function TGSTMapClassInfo.GetCashBookDesc: string;
var
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
begin
  GetMYOBCashbookGSTDetails(fCashbookGstClass, CashBookGstClassCode, CashBookGstClassDesc);
  Result := CashBookGstClassDesc;
end;

//------------------------------------------------------------------------------
procedure TGSTMapClassInfo.GetCashbookGstSeparateClassDesc(var aCashBookGstClassCode : string;
                                                           var aCashBookGstClassDesc : string);
begin
  GetMYOBCashbookGSTDetails(fCashbookGstClass, aCashBookGstClassCode, aCashBookGstClassDesc);
end;

{ TGSTMapCol }
//------------------------------------------------------------------------------
procedure TGSTMapCol.AddGSTMapItem(aGstIndex : integer;
                                   aPracticeGstCode : string;
                                   aPracticeGstDesc : string;
                                   aCashbookGstClass : TCashBookGSTClasses);
var
  NewGSTMapItem : TGSTMapItem;
begin
  NewGSTMapItem := TGSTMapItem.Create(Self);

  NewGSTMapItem.GstIndex         := aGstIndex;
  NewGSTMapItem.PracticeGstCode  := aPracticeGstCode;
  NewGSTMapItem.PracticeGstDesc  := aPracticeGstDesc;
  NewGSTMapItem.CashbookGstClass := aCashbookGstClass;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetMappedAUGSTTypeCode(aGSTClassDescription : string): TCashBookGSTClasses;
var
  UpperCaseInput : string;
begin
  UpperCaseInput := uppercase(aGSTClassDescription);

  if (UpperCaseInput = uppercase('10% GST (Sales)')) or
     (UpperCaseInput = uppercase('Acquisitions subject to GST (other)')) or
     (UpperCaseInput = uppercase('Expenses')) or
     (UpperCaseInput = uppercase('Goods and services tax')) or
     (UpperCaseInput = uppercase('GST')) or
     (UpperCaseInput = uppercase('GST Payable (Output Tax)')) or
     (UpperCaseInput = uppercase('Income')) or
     (UpperCaseInput = uppercase('Income subject to GST')) or
     (UpperCaseInput = uppercase('Non-Cap. Acq. - Inc GST')) or
     (UpperCaseInput = uppercase('Non-Cap. Aqn. - Inc. GST')) or
     (UpperCaseInput = uppercase('Non-capital Purchases')) or
     (UpperCaseInput = uppercase('Other Acquisitions')) or
     (UpperCaseInput = uppercase('Purchases (other)')) or
     (UpperCaseInput = uppercase('Purchases subject to GST')) or
     (UpperCaseInput = uppercase('Sales subject to GST')) or
     (UpperCaseInput = uppercase('Supplies subject to GST (normal)')) or
     (UpperCaseInput = uppercase('Taxable acquisitions - other (purchases)')) or
     (UpperCaseInput = uppercase('Taxable purchases (non-capital)')) or
     (UpperCaseInput = uppercase('Taxable sales')) or
     (UpperCaseInput = uppercase('Taxable supplies')) or
     (UpperCaseInput = uppercase('Taxable supplies (sales)')) then
  begin
    Result := cgGoodsandServices;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Acquisitions subject to GST (capital)')) or
     (UpperCaseInput = uppercase('Cap. Aqn. - Inc GST')) or
     (UpperCaseInput = uppercase('Capital Acquisitions')) or
     (UpperCaseInput = uppercase('Capital Purchases')) or
     (UpperCaseInput = uppercase('Purchases (capital)')) or
     (UpperCaseInput = uppercase('Taxable acquisitions - capital (purchases)')) or
     (UpperCaseInput = uppercase('Taxable purchases (capital)')) then
  begin
    Result := cgCapitalAcquisitions;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Export sales')) or
     (UpperCaseInput = uppercase('Export sales and income')) or
     (UpperCaseInput = uppercase('Export Supplies')) or
     (UpperCaseInput = uppercase('Exports')) or
     (UpperCaseInput = uppercase('Exports (GST Free)')) or
     (UpperCaseInput = uppercase('Exports (not subject to GST)')) or
     (UpperCaseInput = uppercase('Exports (sales)')) or
     (UpperCaseInput = uppercase('GST Free Exports')) then
  begin
    Result := cgExportSales;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Acquisition with no GST')) or
     (UpperCaseInput = uppercase('Acquisition with no GST (capital)')) or
     (UpperCaseInput = uppercase('Acquisitions used for private use/non deductible  (capital)')) or
     (UpperCaseInput = uppercase('Acquisitions used for private use/non deductible  (other)')) or
     (UpperCaseInput = uppercase('Acquisitions with no GST in the price (capital)')) or
     (UpperCaseInput = uppercase('Acquisitions with no GST in the price (other)')) or
     (UpperCaseInput = uppercase('Cap. Acq. - GST Free')) or
     (UpperCaseInput = uppercase('Capital GST free supplies')) or
     (UpperCaseInput = uppercase('Capital purchases with no GST')) or
     (UpperCaseInput = uppercase('Estimated purchases for private use/non-deductible')) or
     (UpperCaseInput = uppercase('Estimated purchases for private use/non-deductible (capital)')) or
     (UpperCaseInput = uppercase('GST Free')) or
     (UpperCaseInput = uppercase('GST free capital acquisitions')) or
     (UpperCaseInput = uppercase('GST free other acquisitions')) or
     (UpperCaseInput = uppercase('GST free purchases')) or
     (UpperCaseInput = uppercase('GST free sales')) or
     (UpperCaseInput = uppercase('GST Free Supplies')) or
     (UpperCaseInput = uppercase('GST free supplies (sales')) or
     (UpperCaseInput = uppercase('GST free supplies (sales)')) or
     (UpperCaseInput = uppercase('GST-free purchases')) or
     (UpperCaseInput = uppercase('GST-free purchases (capital)')) or
     (UpperCaseInput = uppercase('No GST applicable')) or
     (UpperCaseInput = uppercase('Non-Cap. Acq. - GST Free')) or
     (UpperCaseInput = uppercase('Non-capital purchases with no GST')) or
     (UpperCaseInput = uppercase('Non-income tax deductible acquisition')) or
     (UpperCaseInput = uppercase('Non-taxable purchases')) or
     (UpperCaseInput = uppercase('Other GST free supplies')) or
     (UpperCaseInput = uppercase('Other GST-free sales')) or
     (UpperCaseInput = uppercase('Private Purchases')) or
     (UpperCaseInput = uppercase('Private use capital acquisitions')) or
     (UpperCaseInput = uppercase('Private use of non-deductible purchases')) or
     (UpperCaseInput = uppercase('Private use other acquisitions')) or
     (UpperCaseInput = uppercase('Private use/non deductible - capital (purchases)')) or
     (UpperCaseInput = uppercase('Private use/non deductible - other (purchases)')) or
     (UpperCaseInput = uppercase('Sales not subject to GST')) then
  begin
    Result := cgGSTFree;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Input taxed sales')) or
     (UpperCaseInput = uppercase('Input taxed sales & supplies')) or
     (UpperCaseInput = uppercase('Input taxed sales and income')) or
     (UpperCaseInput = uppercase('Input Taxed Supplies')) or
     (UpperCaseInput = uppercase('Input taxed supplies (sales)')) or
     (UpperCaseInput = uppercase('Input taxed supplies (sales)')) or
     (UpperCaseInput = uppercase('Input-taxed Sales & Income & other Supplies')) then
  begin
    Result := cgInputTaxedSales;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Acquisition for input taxed sales')) or
     (UpperCaseInput = uppercase('Acquisition for input taxed sales (capital)')) or
     (UpperCaseInput = uppercase('Acquisition with no GST (input taxed)')) or
     (UpperCaseInput = uppercase('Acquisition with no GST (input taxed) (capital)')) or
     (UpperCaseInput = uppercase('Acquisitions used to make input taxed income (capital)')) or
     (UpperCaseInput = uppercase('Acquisitions used to make input taxed income (other)')) or
     (UpperCaseInput = uppercase('Cap. Acq. - for making Input Taxed Sales')) or
     (UpperCaseInput = uppercase('Capital purchases for input taxed supplies')) or
     (UpperCaseInput = uppercase('Capital Purchases for producing input taxed supplies')) or
     (UpperCaseInput = uppercase('Input taxed capital acquisitions')) or
     (UpperCaseInput = uppercase('Input taxed other acquisitions')) or
     (UpperCaseInput = uppercase('Input Taxed Purchases')) or
     (UpperCaseInput = uppercase('Non-Cap. Aqn. - For Making Input Taxes Supplies')) or
     (UpperCaseInput = uppercase('Non-Cap.Acq. - for making Input Taxed Sales')) or
     (UpperCaseInput = uppercase('Other purchases for input taxed supplies')) or
     (UpperCaseInput = uppercase('Purchases for input taxed sales')) or
     (UpperCaseInput = uppercase('Purchases for making input-taxed sales')) or
     (UpperCaseInput = uppercase('Purchases for making input-taxed sales (capital)')) or
     (UpperCaseInput = uppercase('Purchases for producing input taxed supplies')) or
     (UpperCaseInput = uppercase('Reduced input tax credit - capital (purchases)')) or
     (UpperCaseInput = uppercase('Reduced input tax credit - other (purchases)')) then
  begin
    Result := cgPurchaseForInput;
    Exit;
  end;

  if (UpperCaseInput = uppercase('Items not reported')) then
  begin
    Result := cgNotReportable;
    Exit;
  end;

  if (UpperCaseInput = uppercase('No GST/unregistered supplier - capital (purchases)')) or
     (UpperCaseInput = uppercase('No GST/unregistered supplier - other (purchases)')) then
  begin
    Result := cgGSTNotRegistered;
    Exit;
  end;

  Result := cgNone;
end;

//------------------------------------------------------------------------------
destructor TGSTMapCol.Destroy;
var
  index : integer;
begin
  for index := 0 to length(fGSTMapClassInfoArr)-1 do
    FreeAndNil(fGSTMapClassInfoArr[index]);

  SetLength(fGSTMapClassInfoArr, 0);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TGSTMapCol.FillGstMapCol;
var
  GstIndex : integer;
begin
  Self.Clear;
  for GstIndex := 0 to high(MyClient.clfields.clGST_Class_Names) do
  begin
    if MyClient.clfields.clGST_Class_Names[GstIndex] > '' then
    begin
      AddGSTMapItem(GstIndex,
                    MyClient.clfields.clGST_Class_Codes[GstIndex],
                    MyClient.clfields.clGST_Class_Names[GstIndex],
                    GetMappedAUGSTTypeCode(MyClient.clfields.clGST_Class_Names[GstIndex]));
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TGSTMapCol.FillGstClassMapArr;
begin
  SetLength(fGSTMapClassInfoArr, 8);
  fGSTMapClassInfoArr[0] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[0].CashbookGstClass := cgGoodsandServices;
  fGSTMapClassInfoArr[1] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[1].CashbookGstClass := cgCapitalAcquisitions;
  fGSTMapClassInfoArr[2] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[2].CashbookGstClass := cgExportSales;
  fGSTMapClassInfoArr[3] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[3].CashbookGstClass := cgGSTFree;
  fGSTMapClassInfoArr[4] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[4].CashbookGstClass := cgInputTaxedSales;
  fGSTMapClassInfoArr[5] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[5].CashbookGstClass := cgPurchaseForInput;
  fGSTMapClassInfoArr[6] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[6].CashbookGstClass := cgNotReportable;
  fGSTMapClassInfoArr[7] := TGSTMapClassInfo.Create;
  fGSTMapClassInfoArr[7].CashbookGstClass := cgGSTNotRegistered;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.ItemAtGstIndex(aGstIndex: integer; out aGSTMapItem: TGSTMapItem): boolean;
var
  Index : integer;
begin
  aGSTMapItem := nil;
  result := false;

  for Index := 0 to Self.Count - 1 do
  begin
    if TGSTMapItem(self.Items[Index]).GstIndex = aGstIndex then
    begin
      aGSTMapItem := TGSTMapItem(self.Items[Index]);
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.ItemAtColIndex(aColIndex: integer; out aGSTMapItem: TGSTMapItem): boolean;
begin
  aGSTMapItem := nil;
  result := false;

  if (aColIndex >= 0) and (aColIndex < Self.Count) then
  begin
    aGSTMapItem := TGSTMapItem(self.Items[aColIndex]);
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.FindItemUsingPracCode(aPracticeGstCode: string;
                                          var aGSTMapItem: TGSTMapItem): boolean;
var
  Index : integer;
begin
  aGSTMapItem := nil;
  result := false;

  for Index := 0 to Self.Count - 1 do
  begin
    if (TGSTMapItem(self.Items[Index]).PracticeGstCode = aPracticeGstCode) then
    begin
      aGSTMapItem := TGSTMapItem(self.Items[Index]);
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassCode(aCashbookGstClass: TCashBookGSTClasses): string;
var
  GstClassIndex : integer;
begin
  Result := '';
  for GstClassIndex := 0 to length(GetGSTClassMapArr)-1  do
  begin
    if aCashbookGstClass = GetGSTClassMapArr[GstClassIndex].CashbookGstClass then
    begin
      Result := GetGSTClassMapArr[GstClassIndex].GetCashBookCode;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassDesc(aCashbookGstClass: TCashBookGSTClasses): string;
var
  GstClassIndex : integer;
begin
  Result := '';
  for GstClassIndex := 0 to length(GetGSTClassMapArr)-1  do
  begin
    if aCashbookGstClass = GetGSTClassMapArr[GstClassIndex].CashbookGstClass then
    begin
      Result := GetGSTClassMapArr[GstClassIndex].GetCashBookDesc;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassDescUsingClass(aCashbookGstClass: TCashBookGSTClasses): string;
var
  GstClassIndex : integer;
begin
  Result := '';
  for GstClassIndex := 0 to length(GetGSTClassMapArr)-1  do
  begin
    if aCashbookGstClass = GetGSTClassMapArr[GstClassIndex].CashbookGstClass then
    begin
      Result := GetGSTClassMapArr[GstClassIndex].CashbookGstClassDesc;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassUsingClassDesc(aCashbookGstClassDesc: string): TCashBookGSTClasses;
var
  GstClassIndex : integer;
begin
  Result := cgNone;
  for GstClassIndex := 0 to length(GetGSTClassMapArr)-1  do
  begin
    if aCashbookGstClassDesc = GetGSTClassMapArr[GstClassIndex].CashbookGstClassDesc then
    begin
      Result := GetGSTClassMapArr[GstClassIndex].CashbookGstClass;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassMapArr: TGSTMapClassInfoArr;
begin
  if Length(fGSTMapClassInfoArr) = 0 then
    FillGstClassMapArr();

  Result := fGSTMapClassInfoArr;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.LoadGSTFile(var aFileLines : TStringList; var aFileName : string; var aError : string) : Boolean;
var
  LineColumns : TStringList;
  LineIndex , RowIndex: Integer;
begin
  Result := true;
  LineColumns := TStringList.Create;
  try
    LineColumns.Delimiter := ',';
    LineColumns.StrictDelimiter := True;
    try
      aFileLines.LoadFromFile(aFileName);
    except
      on e : exception do
      begin
        aError := Format( 'Cannot open file %s: %s',[aFileName, e.Message]);
        Result := false;
        Exit;
      end;
    end;

    if aFileLines.Count = 0 then
    begin
      aError := Format( 'Nothing found in file %s',[aFileName]);
      Result := false;
      Exit;
    end;

    RowIndex := 0;
    // Parser the file...
    for LineIndex := 0 to aFileLines.Count - 1 do
    begin
      LineColumns.DelimitedText := aFileLines[LineIndex];
      if LineColumns.Count < 3 then
        Continue;
      if Length(LineColumns[PRAC_GST_CODE]) < 1 then
        Continue;

      if Length(LineColumns[PRAC_GST_CODE]) > 20 then
      begin
        aError := Format('Practice GST code too long in line %d ',[LineIndex]);
        Result := false;
        Exit;
      end;

      if Length(LineColumns[PRAC_GST_DESC]) > 60 then
      begin
        aError := Format('Practice GST description too long in line %d ',[LineIndex]);
        Result := false;
        Exit;
      end;

      if Length(LineColumns[CASHBOOK_GST_CODE]) > 10 then
      begin
        aError := Format('MYOB Cashbook code too long in line %d ',[LineIndex]);
        Result := false;
        Exit;
      end;

      if (LineColumns.Count > CASHBOOK_GST_DESC) and
         (Length(LineColumns[CASHBOOK_GST_DESC]) > 60) then
      begin
        aError := Format('MYOB Cashbook Description too long in line %d ',[LineIndex]);
        Result := false;
        Exit;
      end;
      inc(RowIndex);
    end;

    if RowIndex = 0 then
    begin
      aError := Format( 'Nothing found in file %s',[aFileName]);
      Result := false;
      Exit;
    end;
  finally
    FreeAndNil(LineColumns);
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.LoadGSTFile(var aFilename: string; var aError : string): boolean;
var
  FileLines   : TStringList;
  LineColumns : TStringList;
  LineIndex   : integer;
  GSTMapItem  : TGSTMapItem;
  GSTClass    : TCashBookGSTClasses;
begin
  FileLines := TStringList.Create;
  try
    Result := LoadGSTFile(FileLines, aFilename, aError);
    if Result then
    begin
      LineColumns := TStringList.Create;
      try
        LineColumns.Delimiter := ',';
        LineColumns.StrictDelimiter := True;

        // Finds existing GST Items updates any that are found
        for LineIndex := 0 to FileLines.Count-1 do
        begin
          LineColumns.DelimitedText := FileLines[LineIndex];

          if FindItemUsingPracCode(LineColumns[PRAC_GST_CODE],
                                   GSTMapItem) then
          begin
            GSTClass := GetGSTClassUsingClassDesc(LineColumns[CASHBOOK_GST_CODE] + ' - ' + LineColumns[CASHBOOK_GST_DESC]);
            if GSTClass <> cgNone then
              GSTMapItem.CashbookGstClass := GSTClass;
          end;
        end;

      finally
        FreeAndNil(LineColumns);
      end;
    end;
  finally
    FreeAndNil(FileLines);
  end;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.SaveGSTFile(aFilename: string; aError : string): Boolean;
var
  FileLines   : TStringList;
  LineColumns : TStringList;
  LineIndex   : integer;
  GSTMapItem  : TGSTMapItem;
  GSTClass    : TCashBookGSTClasses;
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
begin
  Result := False;

  FileLines := TStringList.Create;
  FileLines.Clear;
  try
    LineColumns := TStringList.Create;
    try
      LineColumns.Delimiter := ',';
      LineColumns.StrictDelimiter := True;

      for LineIndex := 0 to Self.Count - 1 do
      begin
        if TGSTMapItem(self.Items[LineIndex]).PracticeGstCode = '' then
          Continue;

        LineColumns.Clear;

        LineColumns.Add(TGSTMapItem(self.Items[LineIndex]).PracticeGstCode);
        LineColumns.Add(TGSTMapItem(self.Items[LineIndex]).PracticeGstDesc);
        LineColumns.Add(GetGSTClassCode(TGSTMapItem(self.Items[LineIndex]).CashbookGstClass));
        LineColumns.Add(GetGSTClassDesc(TGSTMapItem(self.Items[LineIndex]).CashbookGstClass));

        // Add line to the 'File'
        FileLines.Add(LineColumns.DelimitedText);
      end;

      if FileLines.Count > 0 then
      begin
        try
          FileLines.SaveToFile(aFilename);
          Result := True;
        except
          on e: exception do
          begin
            aError := Format( 'Cannot save to file %s: '#13'%s',[aFilename, e.Message]);
          end;
        end;
      end;

    finally
      FreeAndNil(LineColumns);
    end;
  finally
    FreeAndNil(FileLines);
  end;
end;

{ TChartExportToMYOBCashbook }
//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.GetMappedReportGroupId(aReportGroup : byte) : TCashBookChartClasses;
begin
  case aReportGroup of
    atNone                 : Result := ccNone;
    atIncome               : Result := ccIncome;
    atDirectExpense        : Result := ccExpense;
    atExpense              : Result := ccExpense;
    atOtherExpense         : Result := ccOtherExpense;
    atOtherIncome          : Result := ccOtherIncome;
    atEquity               : Result := ccEquity;
    atDebtors              : Result := ccAsset;
    atCreditors            : Result := ccLiabilities;
    atOpeningStock         : Result := ccAsset;
    atPurchases            : Result := ccExpense;
    atClosingStock         : Result := ccAsset;
    atFixedAssets          : Result := ccAsset;
    atStockOnHand          : Result := ccAsset;
    atBankAccount          : Result := ccAsset; // Cash on hand
    atRetainedPorL         : Result := ccNone; // ?
    atGSTPayable           : Result := ccLiabilities;
    atUnknownDR            : Result := ccNone;
    atUnknownCR            : Result := ccNone;
    atCurrentAsset         : Result := ccAsset;
    atCurrentLiability     : Result := ccLiabilities;
    atLongTermLiability    : Result := ccLiabilities;
    atUncodedCR            : Result := ccNone; // ?
    atUncodedDR            : Result := ccNone; // ?
    atCurrentYearsEarnings : Result := ccNone; // ?
    atGSTReceivable        : Result := ccLiabilities;
  else
    Result := ccNone;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.GetMappedReportGroupCode(aReportGroup : byte): string;
var
  MappedGroupId : TCashBookChartClasses;
begin
  MappedGroupId := GetMappedReportGroupId(aReportGroup);

  case MappedGroupId of
    ccNone         : Result := 'Error';
    ccIncome       : Result := 'Income';
    ccExpense      : Result := 'Expense';
    ccOtherIncome  : Result := 'OtherIncome';
    ccOtherExpense : Result := 'OtherExpense';
    ccAsset        : Result := 'Asset';
    ccLiabilities  : Result := 'Liabilities';
    ccEquity       : Result := 'Equity';
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.GetCrDrSignFromReportGroup(aReportGroup: byte): integer;
var
  MappedGroupId : TCashBookChartClasses;
begin
  MappedGroupId := GetMappedReportGroupId(aReportGroup);

  case MappedGroupId of
    ccNone         : Result := 0;  // Error
    ccIncome       : Result := -1; // CR
    ccExpense      : Result := 1;  // DR
    ccOtherIncome  : Result := -1; // CR
    ccOtherExpense : Result := 1;  // DR
    ccAsset        : Result := 1;  // DR
    ccLiabilities  : Result := -1; // CR
    ccEquity       : Result := -1; // CR
  else
    Result := 0; // Error
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.GetGSTClassTypeIndicatorFromGSTClass(aGST_Class : byte) : byte;
begin
  If ( aGST_Class in GST_CLASS_RANGE ) then
    Result := MyClient.clFields.clGST_Class_Types[aGST_Class]
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.GetMappedNZGSTTypeCode(aGSTClassTypeIndicator : byte): TCashBookGSTClasses;
begin
  case aGSTClassTypeIndicator of
    gtUndefined      : Result := cgNotReportable;
    gtIncomeGST      : Result := cgGoodsandServices;
    gtExpenditureGST : Result := cgGoodsandServices;
    gtExempt         : Result := cgExempt;
    gtZeroRated      : Result := cgZeroRated;
    gtCustoms        : Result := cgCustoms
  else
    Result := cgNone;
  end;
end;

//------------------------------------------------------------------------------
procedure TChartExportToMYOBCashbook.GetMYOBCashbookGSTDetails(aCashBookGstClass : TCashBookGSTClasses;
                                                               var aCashBookGstClassCode : string;
                                                               var aCashBookGstClassDesc : string);
begin
  case aCashBookGstClass of
    cgGoodsandServices : begin
      aCashBookGstClassCode := 'GST';
      aCashBookGstClassDesc := 'Goods & Services Tax';
    end;
    cgCapitalAcquisitions : begin
      aCashBookGstClassCode := 'CAP';
      aCashBookGstClassDesc := 'Capital Acquisitions';
    end;
    cgExportSales : begin
      aCashBookGstClassCode := 'EXP';
      aCashBookGstClassDesc := 'Export Sales';
    end;
    cgGSTFree : begin
      aCashBookGstClassCode := 'FRE';
      aCashBookGstClassDesc := 'GST Free';
    end;
    cgInputTaxedSales : begin
      aCashBookGstClassCode := 'ITS';
      aCashBookGstClassDesc := 'Input Taxed Sales';
    end;
    cgPurchaseForInput : begin
      aCashBookGstClassCode := 'INP';
      aCashBookGstClassDesc := 'Purchases for Input Tax Sales';
    end;
    cgNotReportable : begin
      aCashBookGstClassCode := 'NTR';
      aCashBookGstClassDesc := 'Not Reportable';
    end;
    cgGSTNotRegistered : begin
      aCashBookGstClassCode := 'GNR';
      aCashBookGstClassDesc := 'GST Not Registered';
    end;
    cgExempt : begin
      aCashBookGstClassCode := 'E';
      aCashBookGstClassDesc := 'Exempt';
    end;
    cgZeroRated : begin
      aCashBookGstClassCode := 'Z';
      aCashBookGstClassDesc := 'Zero-Rated';
    end;
    cgCustoms : begin
      aCashBookGstClassCode := 'I';
      aCashBookGstClassDesc := 'GST on Customs Invoice';
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.RunExportChartToFile(aErrorStr : string): boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
constructor TChartExportToMYOBCashbook.Create;
begin
  fCountry := GetCountry();

  fChartExportCol := TChartExportCol.Create(TChartExportItem);
  fGSTMapCol := TGSTMapCol.Create(TGSTMapItem);

  fExportChartFrmProperties := TExportChartFrmProperties.Create;
  ExportChartFrmProperties.ExportBasicChart := false;
  ExportChartFrmProperties.IncludeClosingBalances := false;
  ExportChartFrmProperties.ClosingBalanceDate := now();
  ExportChartFrmProperties.ExportFileLocation := '';
  ExportChartFrmProperties.ClientCode := '';
end;

//------------------------------------------------------------------------------
destructor TChartExportToMYOBCashbook.Destroy;
begin
  FreeAndNil(fExportChartFrmProperties);
  FreeAndNil(fGSTMapCol);
  FreeAndNil(fChartExportCol);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TChartExportToMYOBCashbook.DoChartExport(aPopupParent: TForm);
const
  ThisMethodName = 'DoChartExport';
var
  Res : Boolean;
  ErrorStr : string;
  Filename : string;
begin
  Res := true;

  if not assigned(MyClient) then
  begin
    Res := false;
    Exit;
  end;

  ExportChartFrmProperties.ClientCode := MyClient.clFields.clCode;
  ChartExportCol.FillChartExportCol();

  if (Country = whAustralia) then
  begin
    GSTMapCol.PrevGSTFileLocation := MyClient.clExtra.ceCashbook_GST_Map_File_Location;
    GSTMapCol.FillGstMapCol();

    if GSTMapCol.PrevGSTFileLocation <> '' then
    begin
      if FileExists(GSTMapCol.PrevGSTFileLocation) then
      begin
        Filename := GSTMapCol.PrevGSTFileLocation;
        if not GSTMapCol.LoadGSTFile(Filename, ErrorStr) then
        begin
          HelpfulErrorMsg(ErrorStr,0);
          LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
        end;
      end;
    end;

    Res := ShowMapGSTClass(aPopupParent, fGSTMapCol);

    if Res then
    begin
      Res := GSTMapCol.SaveGSTFile(Filename, ErrorStr);

      if Res then
      begin
        if (GSTMapCol.PrevGSTFileLocation <> MyClient.clExtra.ceCashbook_GST_Map_File_Location) then
          MyClient.clExtra.ceCashbook_GST_Map_File_Location := GSTMapCol.PrevGSTFileLocation;
      end
      else
      begin
        HelpfulErrorMsg(ErrorStr,0);
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
      end;
    end;
  end;

  if Res then
  begin
    if (MyClient.clExtra.ceCashbook_Export_File_Location = '') then
      ExportChartFrmProperties.ExportFileLocation := UserDir + MyClient.clFields.clCode +
                                                     '_MYOB_CashBook_Chart.csv'
    else
      ExportChartFrmProperties.ExportFileLocation := MyClient.clExtra.ceCashbook_Export_File_Location;

    Res := ShowChartExport(aPopupParent, ExportChartFrmProperties);

    if Res then
    begin
      Res := RunExportChartToFile(ErrorStr);

      if Res then
      begin
        if (ExportChartFrmProperties.ExportFileLocation <> MyClient.clExtra.ceCashbook_Export_File_Location) then
          MyClient.clExtra.ceCashbook_Export_File_Location := ExportChartFrmProperties.ExportFileLocation;
      end
      else
      begin
        HelpfulErrorMsg(ErrorStr,0);
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
initialization
  fChartExportToMYOBCashbook := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil( fChartExportToMYOBCashbook );

end.
