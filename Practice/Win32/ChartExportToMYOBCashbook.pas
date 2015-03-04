unit ChartExportToMYOBCashbook;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  Forms,
  FrmChartExportToMYOBCashBook,
  clObj32,
  MONEYDEF,
  stDate,
  TravList,
  BKDEFS,
  chartutils,
  chList32;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    Source: Integer;
  end;

  //----------------------------------------------------------------------------
  TTravManagerCashBookExport = class(TTravManager)
  private
    fAccountTotalNet : Money;
    fAccountHasActivity : Boolean;
    fContraCodePrinted : string;
    fLastCodePrinted : string;
    fPrintEmptyCodes : boolean;
    fDoneSubTotal : boolean;
    fLastValidCode : string;
    fSplitCode : string;
    fBankContraType : byte;
    fGSTContraType : byte;
    fBankContra: Byte;
    fGSTContra: Byte;
  public
    property AccountTotalNet : Money read fAccountTotalNet write fAccountTotalNet;
    property AccountHasActivity : Boolean read fAccountHasActivity write fAccountHasActivity;
    property ContraCodePrinted : string read fContraCodePrinted write fContraCodePrinted;
    property LastCodePrinted : string read fLastCodePrinted write fLastCodePrinted;
    property PrintEmptyCodes : boolean read fPrintEmptyCodes write fPrintEmptyCodes;
    property DoneSubTotal : boolean read fDoneSubTotal write fDoneSubTotal;
    property LastValidCode : string read fLastValidCode write fLastValidCode;
    property SplitCode : string read fSplitCode write fSplitCode;
    property BankContraType : byte read fBankContraType write fBankContraType;
    property GSTContraType : byte read fGSTContraType write fGSTContraType;
    property BankContra : byte read fBankContra write fBankContra;
    property GSTContra : byte read fGSTContra write fGSTContra;
  end;

  //----------------------------------------------------------------------------
  TChartExportItem = class(TCollectionItem)
  private
    fIsBasicChartItem : boolean;
    fAccountCode : string;
    fAccountDescription : string;
    fReportGroupId : byte;
    fGSTClassId : byte;
    fClosingBalance : string;
    fClosingBalanceDate : string;
    fPostingAllowed : boolean;
    fHasOpeningBalance : boolean;
    fIsContra : boolean;
  public
    property IsBasicChartItem : boolean read fIsBasicChartItem write fIsBasicChartItem;
    property AccountCode : string read fAccountCode write fAccountCode;
    property AccountDescription : string read fAccountDescription write fAccountDescription;
    property ReportGroupId : byte read fReportGroupId write fReportGroupId;
    property GSTClassId : byte read fGSTClassId write fGSTClassId;
    property ClosingBalance : string read fClosingBalance write fClosingBalance;
    property ClosingBalanceDate : string read fClosingBalanceDate write fClosingBalanceDate;
    property PostingAllowed : boolean read fPostingAllowed write fPostingAllowed;
    property HasOpeningBalance : boolean read fHasOpeningBalance write fHasOpeningBalance;
    property IsContra : boolean read fIsContra write fIsContra;
  end;

  //----------------------------------------------------------------------------
  TChartExportCol = class(TCollection)
  private
    fChart : TCustomSortChart;
    fFromDate : TStDate;
    fTodate   : TStDate;
    fIsTransactionsUncodedorInvalidlyCoded : boolean;

    procedure LGR_Contra_PrintEntry(Sender:TObject);
    procedure LGR_Contra_PrintDissect(Sender:Tobject);
    function DoContras(aTravMgr : TTravManagerCashBookExport; aCode: string) : boolean;
    procedure CalculateEntry( Sender : TObject);
    procedure CalculateDisection( Sender : TObject);
  protected
    procedure AddChartExportItem(aIsBasicChartItem : boolean;
                                 aAccountCode : string;
                                 aAccountDescription : string;
                                 aReportGroupId : byte;
                                 aGSTClassId : byte;
                                 aPostingAllowed : boolean);

    function GetCurrencyFormat(aRoundValues : Boolean) : string;
    function GetStringFromAmount(aAmount : Money) : string;
    function GetOpeningBalanceAmount(Client : tClientObj; Code: string): Money;
    function GetOpeningBalanceForInvalidCode(Client : TClientObj; Code: string; D1: Integer): Money;

    function GetCrDrSignFromReportGroup(aReportGroup : byte) : integer;

    function DoesTxUseGSTClass(aClient : TClientObj; aClassId: string; aTrans : pTransaction_Rec): Boolean;
    function IsABankContra(aCode: string; aStart: Integer): Integer;
    function IsAGSTContra(aCode: string; aStart: Integer): Integer;
  public
    destructor Destroy; override;

    function IsThisAContraCode(aCode: string): Boolean;
    function GetMappedReportGroupId(aReportGroup : byte) : TCashBookChartClasses;
    procedure FillChartExportCol(aAllowIactive : Boolean);
    procedure UpdateClosingBalancesForCode(aCode : String; aClosingBalance : Money; aIsContra : Boolean);
    procedure UpdateClosingBalances(aClosingBalanceDate : TstDate);
    procedure CheckIfNonBasicCodesHaveBalances(aClosingBalanceDate : TstDate;
                                               var aNonBasicCodesHaveBalances : boolean;
                                               var aNonBasicCodes : TStringList);

    procedure CalculateTransactionTotals();
    function CheckAccountCodesLength(aErrors : TStringList) : Boolean;
    function ItemAtColIndex(aClientChartIndex: integer; out aChartExportItem : TChartExportItem) : boolean;
    function ItemAtCode(aCode: string; out aChartExportItem : TChartExportItem) : boolean;

    property Chart    : TCustomSortChart read fChart    write fChart;
    property FromDate : TStDate          read fFromDate write fFromDate;
    property Todate   : TStDate          read fTodate   write fTodate;
    property IsTransactionsUncodedorInvalidlyCoded : boolean read  fIsTransactionsUncodedorInvalidlyCoded
                                                             write fIsTransactionsUncodedorInvalidlyCoded;
  end;

  //----------------------------------------------------------------------------
  TGSTMapItem = class(TCollectionItem)
  private
    fGstIndex : integer;
    fPracticeGstCode : string;
    fPracticeGstDesc : string;
    fCashbookGstClass : TCashBookGSTClasses;
  public
    DispPracCode : ShortString;
    DispPracDesc : ShortString;
    DispMYOBIndex : integer;

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
    procedure GetCashbookGstSeparateClassDesc(var aCashBookGstClassCode, aCashBookGstClassDesc: string);
  protected
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
  public
    destructor Destroy; override;

    function FixCharactersInString(aInstring : string) : string;

    function GetMappedAUGSTTypeCode(aGSTClassDescription : string): TCashBookGSTClasses;
    procedure AddGSTMapItem(aGstIndex : integer;
                            aPracticeGstCode : string;
                            aPracticeGstDesc : string;
                            aCashbookGstClass : TCashBookGSTClasses);

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

    Function CheckIfAllGstCodesAreMapped() : boolean;

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
    function CheckNZGStTypes() : boolean;
    function CheckReportGroups() : boolean;
    function CheckGSTControlAccAndRates() : boolean;
    function RunExportChartToFile(aFilename : string;
                                  var aErrorStr : string;
                                  aShowUI : boolean) : boolean;
    function DoNonBasicCodesHaveBalances(var aNonBasicCodes : TStringList) : boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure DoChartExport(aPopupParent: TForm; aOverrideFilename : string = ''; aOverrideIncludeBalances : boolean = false);

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
  WarningMoreFrm,
  InfoMoreFrm,
  FrmChartExportMapGSTClass,
  FrmChartExportAccountCodeErrors,
  CountryUtils,
  BKConst,
  Globals,
  glConst,
  LogUtil,
  AccountInfoObj,
  ovcdate,
  baObj32,
  ISO_4217,
  CalculateAccountTotals,
  bkdateutils,
  stDateSt,
  JNLUTILS32,
  GenUtils,
  PeriodUtils,
  DateUtils;

Const
  UnitName = 'ChartExportToMYOBCashbook';
  PRAC_GST_CODE = 0;
  PRAC_GST_DESC = 1;
  CASHBOOK_GST_CODE = 2;
  CASHBOOK_GST_DESC = 3;
  NullCode = '<NULLCODE>';

var
  fChartExportToMYOBCashbook : TChartExportToMYOBCashbook;

//------------------------------------------------------------------------------
function ChartExportToMYOBEssentialsCashbook() : TChartExportToMYOBCashbook;
begin
  if not Assigned(fChartExportToMYOBCashbook) then
    fChartExportToMYOBCashbook := TChartExportToMYOBCashbook.Create;

  Result := fChartExportToMYOBCashbook;
end;

//------------------------------------------------------------------------------
function GetIOErrorDescription(ErrorCode: integer; ErrorMsg: string): string;
begin
  case ErrorCode of
    2  : Result := 'No such file or directory';
    3  : Result := 'Path not found';
    5  : Result := 'I/O Error';
    13 : Result := 'Permission denied';
    20 : Result := 'Not a directory';
    21 : Result := 'Is a directory';
    32 : Result := 'Check that the file is not already open and try again.';
  else
    Result := ErrorMsg;
  end;
end;

{ TChartExportCol }
//------------------------------------------------------------------------------
procedure TChartExportCol.AddChartExportItem(aIsBasicChartItem : boolean;
                                             aAccountCode : string;
                                             aAccountDescription : string;
                                             aReportGroupId : byte;
                                             aGSTClassId : byte;
                                             aPostingAllowed : boolean);
var
  NewChartExportItem : TChartExportItem;
begin
  NewChartExportItem := TChartExportItem.Create(Self);

  NewChartExportItem.IsBasicChartItem   := aIsBasicChartItem;
  NewChartExportItem.AccountCode        := aAccountCode;
  NewChartExportItem.AccountDescription := aAccountDescription;
  NewChartExportItem.ReportGroupId      := aReportGroupId;
  NewChartExportItem.GSTClassId         := aGSTClassId;
  NewChartExportItem.PostingAllowed     := aPostingAllowed;
  NewChartExportItem.ClosingBalance     := '';
  NewChartExportItem.ClosingBalanceDate := '';
  NewChartExportItem.HasOpeningBalance  := false;
end;

//------------------------------------------------------------------------------
function TChartExportCol.GetCurrencyFormat(aRoundValues : Boolean): string;
begin
  Result := '0.00;-0.00;-';
end;

//------------------------------------------------------------------------------
function TChartExportCol.GetStringFromAmount(aAmount: Money): string;
var
  currAmount : currency;
begin
  currAmount := aAmount/100;

  Result := FormatFloat(GetCurrencyFormat(false), currAmount);

  if Result = '-' then
    Result := '';
end;

//------------------------------------------------------------------------------
function TChartExportCol.GetOpeningBalanceAmount(Client : tClientObj; Code: string): Money;
var
  AccountInfo: TAccountInformation;
  Balance : Money;
  DayFinStart, MonthFinStart, YearFinStart: Integer;
  DayStart, MonthStart, YearStart: Integer;
begin
  AccountInfo := TAccountInformation.Create( Client);
  try
    StDatetoDMY(Client.clFields.clFinancial_Year_Starts, DayFinStart, MonthFinStart, YearFinStart);

    AccountInfo.UseBudgetIfNoActualData     := False;
    AccountInfo.LastPeriodOfActualDataToUse := Client.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode := Code;
    AccountInfo.UseBaseAmounts := false;
    StDatetoDMY(Client.clFields.clFinancial_Year_Starts, DayFinStart, MonthFinStart, YearFinStart);
    StDatetoDMY(Client.clFields.clTemp_FRS_To_Date, DayStart, MonthStart, YearStart);

    // If start date = financial year start then just get opening bal
    if (DayFinStart = DayStart) and (MonthFinStart = MonthStart) then
      Balance := AccountInfo.OpeningBalanceActualOrBudget(1)
    else // else opening bal at last financial year start + movement up to previous day
      Balance := AccountInfo.ClosingBalanceActualOrBudget(1);
  finally
    FreeAndNil(AccountInfo);
  end;
  Result := Balance;
end;

// To get an opening balance for an invalid code there are no actual op bals -
// we just calculate movement from the financial year start
//------------------------------------------------------------------------------
function TChartExportCol.GetOpeningBalanceForInvalidCode(Client : TClientObj; Code: string; D1: Integer): Money;
//Must be net amount !!!
var
  BnkAccIndex, TransIndex, DateFrom, DateTo: Integer;
  Bank_Account : TBank_Account;
  Transaction_Rec : tTransaction_Rec;

  Curr_Dissect : pDissection_Rec;
  DayFinStart, MonthFinStart, YearFinStart: Integer;
  DayStart, MonthStart, YearStart: Integer;
begin
  Result := 0;

  // Add all movement between financial year start and day prior to report start
  DateFrom := Client.clFields.clTemp_FRS_From_Date;
  DateTo := Client.clFields.clTemp_FRS_To_Date;

  //handle special case where report is being run from fin year start date
  StDatetoDMY(Client.clFields.clFinancial_Year_Starts, DayFinStart, MonthFinStart, YearFinStart);
  StDatetoDMY(D1, DayStart, MonthStart, YearStart);
  if (DayFinStart = DayStart) and (MonthFinStart = MonthStart) then
  begin
    result := 0;
    exit;
  end;

  // Loop each bank account
  for BnkAccIndex := 0 to Pred(Client.clBank_Account_List.ItemCount) do
  begin
    Bank_Account := Client.clBank_Account_List.Bank_Account_At(BnkAccIndex);
    for TransIndex := 0 to Pred(Bank_Account.baTransaction_List.ItemCount) do
    begin
      Transaction_Rec := Bank_Account.baTransaction_List.Transaction_At(TransIndex)^;

      if (Transaction_Rec.txDate_Effective >= DateFrom) and
         (Transaction_Rec.txDate_Effective <= DateTo) then
      begin
        if (Transaction_Rec.txAccount = Code) then
        begin
          Result := Result + ( Transaction_Rec.txTemp_Base_Amount - Transaction_Rec.txGST_Amount)
        end
        else
        if (Transaction_Rec.txFirst_Dissection <> nil) then
        begin
          Curr_Dissect := Transaction_Rec.txFirst_Dissection;
          while Curr_Dissect <> nil do
          begin
            if Curr_Dissect.dsAccount = Code then
              Result := Result + ( Curr_Dissect.dsTemp_Base_Amount - Curr_Dissect.dsGST_Amount);
            Curr_Dissect := Curr_Dissect.dsNext;
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportCol.GetMappedReportGroupId(aReportGroup : byte) : TCashBookChartClasses;
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
    atOpeningStock         : Result := ccCostOfSales;
    atPurchases            : Result := ccCostOfSales;
    atClosingStock         : Result := ccCostOfSales;
    atFixedAssets          : Result := ccAsset;
    atStockOnHand          : Result := ccAsset;
    atBankAccount          : Result := ccAsset; // Cash on hand
    atRetainedPorL         : Result := ccNone;  // ?
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
function TChartExportCol.GetCrDrSignFromReportGroup(aReportGroup: byte): integer;
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
    ccCostOfSales  : Result := 1;  // DR
  else
    Result := 0; // Error
  end;
end;

//------------------------------------------------------------------------------
destructor TChartExportCol.Destroy;
begin
  if Assigned(FChart) then
    FreeAndNil(FChart);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.FillChartExportCol(aAllowIactive : Boolean);
var
  ChartIndex : integer;
  AccountRec : pAccount_Rec;
begin
  Self.Clear;
  for ChartIndex := 0 to MyClient.clChart.ItemCount-1 do
  begin
    AccountRec := MyClient.clChart.Account_At(ChartIndex);

    if (not aAllowIactive) and (AccountRec.chInactive) then
      continue;

    AddChartExportItem(not AccountRec.chHide_In_Basic_Chart,
                       AccountRec.chAccount_Code,
                       AccountRec.chAccount_Description,
                       AccountRec.chAccount_Type,
                       AccountRec.chGST_Class,
                       AccountRec.chPosting_Allowed);
  end;

  //Use a copy of the client chart that can be sorted
  if Assigned(FChart) then
    FreeAndNil(FChart);

  FChart := TCustomSortChart.Create(MyClient.ClientAuditMgr);
  FChart.CopyChart(MyClient.clChart);
  if UseXlonSort then
    FChart.Sort(XlonCompare);
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.UpdateClosingBalancesForCode(aCode : String; aClosingBalance : Money; aIsContra : Boolean);
var
  ChartExportItem : TChartExportItem;
  ClosingBalance : Money;
  DisplayClosingBalanceDate : string;
  DisplayClosingBalance : string;
  CrDrSignFromReportGroup : integer;
begin
  if ItemAtCode(aCode, ChartExportItem) then
  begin
    DisplayClosingBalanceDate := StDateToDateString('dd/mm/yyyy', IncDate(ToDate, 1, 0, 0), true);
    ClosingBalance            := aClosingBalance;
    CrDrSignFromReportGroup   := GetCrDrSignFromReportGroup(ChartExportItem.ReportGroupId);
    ClosingBalance            := CrDrSignFromReportGroup * ClosingBalance;
    DisplayClosingBalance     := GetStringFromAmount(ClosingBalance);

    ChartExportItem.ClosingBalanceDate := DisplayClosingBalanceDate;
    ChartExportItem.ClosingBalance     := DisplayClosingBalance;
    ChartExportItem.IsContra           := aIsContra;

    if DisplayClosingBalance > '' then
      ChartExportItem.HasOpeningBalance := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.UpdateClosingBalances(aClosingBalanceDate : TstDate);
var
  BalanceStartDte, BalanceEndDte : TstDate;
  TransStartDte, TransEndDte : TstDate;
  DayFinStart, MonthFinStart, YearFinStart: Integer;
  DayStart, MonthStart, YearStart: Integer;
  AccountIndex : integer;
  BankAcc : TBank_Account;
begin
  // Convert Passed User Date
  StDatetoDMY(aClosingBalanceDate, DayStart, MonthStart, YearStart);

  // Set Trans Start Date to 1st of month of current passed date
  DayStart := 1;
  TransStartDte := DMYtoStDate(DayStart, MonthStart, YearStart, Epoch);
  TransEndDte   := aClosingBalanceDate;

  // Convert Financial Year Start from Client Details
  StDatetoDMY(MyClient.clFields.clFinancial_Year_Starts, DayFinStart, MonthFinStart, YearFinStart);

  // special case start date = financial year start
  if (DayFinStart = DayStart) and (MonthFinStart = MonthStart) then
    BalanceEndDte := DMYtoStDate(DayStart, MonthStart, YearStart, Epoch) //selected date
  else // otherwise we go up to the previous day
    BalanceEndDte := IncDate(TransStartDte, -1, 0, 0);

  //go back to last financial year if report month less than year start month
  //ie. if report date is 1/2/2005 then fin start is 1/4/2004 (NZ example)
  if MonthStart < MonthFinStart then
    YearStart := YearStart - 1;
  BalanceStartDte := DMYtoStDate(DayFinStart, MonthFinStart, YearStart, Epoch);

  MyClient.clFields.cltemp_FRS_from_Date := BalanceStartDte;
  MyClient.clFields.clTemp_FRS_To_Date   := BalanceEndDte;
  FromDate := TransStartDte;
  ToDate   := TransEndDte;

  {HelpfulErrorMsg('Bal From Date : ' +
                  StDateToDateString('dd/mm/yyyy', MyClient.clFields.cltemp_FRS_from_Date, true) +
                  ', Bal To Date : ' +
                  StDateToDateString('dd/mm/yyyy', MyClient.clFields.clTemp_FRS_To_Date, true) +
                  ', Rpt From Date : ' +
                  StDateToDateString('dd/mm/yyyy', FromDate, true) +
                  ', Rpt To Date : ' +
                  StDateToDateString('dd/mm/yyyy', ToDate, true), 0);}

  MyClient.clFields.clFRS_Reporting_Period_Type               := frpCustom;
  MyClient.clFields.clTemp_FRS_Last_Period_To_Show            := 1;
  MyClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use      := MyClient.clFields.clTemp_FRS_Last_Period_To_Show;
  MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only       := False;
  MyClient.clFields.clTemp_FRS_Division_To_Use                := 0;
  MyClient.clFields.clTemp_FRS_Job_To_Use                     := '';
  MyClient.clFields.clTemp_FRS_Budget_To_Use                  := '';
  MyClient.clFields.clTemp_FRS_Budget_To_Use_Date             := -1;
  MyClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
  MyClient.clFields.clGST_Inclusive_Cashflow                  := False;

  for AccountIndex := 0 to MyClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAcc := MyClient.clBank_Account_List.Bank_Account_At(AccountIndex);
    BankAcc.baFields.baTemp_Include_In_Report := True;
  end;

  CalculateAccountTotalsForClient(MyClient,
                                  True,
                                  nil,
                                  -1,
                                  False,
                                  True);

  CalculateTransactionTotals;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.CheckIfNonBasicCodesHaveBalances(aClosingBalanceDate: TstDate;
                                                           var aNonBasicCodesHaveBalances: boolean;
                                                           var aNonBasicCodes : TStringList);
var
  CodeIndex : integer;
  ChartExportItem : TChartExportItem;
begin
  aNonBasicCodesHaveBalances := false;
  aNonBasicCodes.Clear;

  UpdateClosingBalances(aClosingBalanceDate);

  for CodeIndex := 0 to Count-1 do
  begin
    if ItemAtColIndex(CodeIndex, ChartExportItem) then
    begin
      if (not ChartExportItem.IsBasicChartItem) and
         (ChartExportItem.HasOpeningBalance) then
      begin
        aNonBasicCodesHaveBalances := true;
        aNonBasicCodes.Add(ChartExportItem.AccountCode);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportCol.DoesTxUseGSTClass(aClient  : TClientObj;
                                           aClassId : string;
                                           aTrans   : pTransaction_Rec): Boolean;
var
  Dissection : pDissection_Rec;
begin
  Result := False;
  // check mainline
  if (aTrans.txGST_Class in [ 1..MAX_GST_CLASS ]) and
     (aClient.clFields.clGST_Class_Codes[aTrans.txGST_Class] = aClassId) and
     (aTrans.txGST_Amount <> 0) then
  begin
    Result := True;
    Exit;
  end;

  // check dissection lines
  Dissection := aTrans.txFirst_Dissection;
  while Dissection <> nil do
  begin
    if (Dissection.dsGST_Class in [ 1..MAX_GST_CLASS ]) and
       (aClient.clFields.clGST_Class_Codes[Dissection.dsGST_Class] = aClassId) and
       (Dissection.dsGST_Amount <> 0) then
    begin
      Result := True;
      Exit;
    end;
    Dissection := Dissection.dsNext;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportCol.IsABankContra(aCode: string; aStart: Integer): Integer;
var
  BankAcc      : TBank_Account;
  TransRec     : pTransaction_Rec;
  BankAccIndex : Integer;
  TransIndex   : Integer;
begin
  Result := -1;
  if aCode = '' then
    Exit;
  for BankAccIndex := aStart to Pred(MyClient.clBank_Account_List.ItemCount) do
  begin
    BankAcc := MyClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
    if (BankAcc.baFields.baContra_Account_Code = aCode) and
       (not (BankAcc.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
    begin
      // Does this account have any transactions coded within the report dates
      for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
      begin
        TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
        if (TransRec.txDate_Effective >= FromDate) and
           (TransRec.txDate_Effective <= Todate) then
        begin
          Result := BankAccIndex;
          exit;
        end;
      end;
    end;
  end;
end;

// Is the given Code used as a GST control account
// Returns index into GST rates list, or -1 if not a control account
//------------------------------------------------------------------------------
function TChartExportCol.IsAGSTContra(aCode: string; aStart: Integer): Integer;
var
  AccCodeIndex, AccIndex, TransIndex: Integer;
  BankAcc: TBank_Account;
  TransRec: pTransaction_Rec;
begin
  Result := -1;
  if aCode = '' then
    Exit;

  for AccCodeIndex := aStart to High(MyClient.clFields.clGST_Account_Codes) do
  begin
    if MyClient.clFields.clGST_Account_Codes[AccCodeIndex] = aCode then
    begin
      // Is this GST class used in any included bank account
      for AccIndex := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
      begin
         BankAcc := MyClient.clBank_Account_List.Bank_Account_At(AccIndex);
        // Are there any txns using this gst class within the report dates
        for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
        begin
          TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
          if (TransRec.txDate_Effective >= FromDate) and
             (TransRec.txDate_Effective <= Todate) and
             DoesTxUseGSTClass(MyClient, MyClient.clFields.clGST_Class_Codes[AccCodeIndex], TransRec) then
          begin
            Result := AccCodeIndex;
            Exit;
          end;
        end;
      end;

      for AccIndex := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
      begin
        BankAcc := MyClient.clBank_Account_List.Bank_Account_At(AccIndex);
        if BankAcc.baFields.baAccount_Type in BKConst.NonTrfJournalsLedgerSet then
        begin
          // Are there any txns using this gst class within the report dates
          for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
          begin
            TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
            if (TransRec.txDate_Effective >= Fromdate) and
               (TransRec.txDate_Effective <= Todate) and
               DoesTxUseGSTClass(MyClient, MyClient.clFields.clGST_Class_Codes[AccCodeIndex], TransRec) then
            begin
              Result := AccCodeIndex;
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportCol.IsThisAContraCode(aCode: string): Boolean;
begin
  Result := (IsABankContra(aCode, 0) > -1) or
            (IsAGSTContra(aCode, Low(MyClient.clFields.clGST_Account_Codes)) > -1);
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.LGR_Contra_PrintEntry(Sender:TObject);
var
  Code : Bk5CodeStr;
  ContraTravMgr  : TTravManagerCashBookExport;
  GSTControlAccount : string;
  baFields : tBank_Account_Rec;
begin
  ContraTravMgr := TTravManagerCashBookExport(Sender);

  //is bank account included in this report?
  //if not IsBankAccountIncluded(ReportJob, Mgr) then
  // Exit;

  Code := ContraTravMgr.Transaction^.txAccount;
  baFields := ContraTravMgr.Bank_Account.baFields;
  //IsSummary := TListLedgerReport(ReportJob).SummaryOnly;

  //get GST control account if we need to display gst contras
  if (ContraTravMgr.GSTContraType > Byte(gcNone)) and
     (ContraTravMgr.Transaction^.txGst_Class in [ 1..MAX_GST_CLASS ]) then
    GSTControlAccount := MyClient.clFields.clGST_Account_Codes[ContraTravMgr.Transaction^.txGst_Class]
  else
    GSTControlAccount := '';

  //does this transaction need to be handled? only if:
  //it is coded to the handled acount
  //the bank account it belongs to has this account as the contra
  //its GST class has this account as the control account
  //Skip dissections, they are handled in a seperate method
  if ((ContraTravMgr.ContraCodePrinted <> ContraTravMgr.Transaction^.txAccount) and
     (ContraTravMgr.ContraCodePrinted <> baFields.baContra_Account_Code) and
     (ContraTravMgr.ContraCodePrinted <> GSTControlAccount)) or (ContraTravMgr.Transaction^.txAccount = DISSECT_DESC) then
    exit;

  // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
  if (GSTControlAccount = ContraTravMgr.ContraCodePrinted) and
     (ContraTravMgr.Transaction^.txGST_Amount = 0) and
     (ContraTravMgr.Transaction^.txAccount <> GSTControlAccount) then
    exit;

  // #2861 - do not show contras for journals (but show GST)
  if (baFields.baAccount_Type in LedgerNoContrasJournalSet) and
     (ContraTravMgr.ContraCodePrinted <> GSTControlAccount) and
     (ContraTravMgr.ContraCodePrinted <> Code) and
     (Code <> baFields.baContra_Account_Code) then
    exit;

  //print contra entries if requested
  //note: txn may be printed twice (actual entry and contra) if its coded to this account

  //normal txn
  if (ContraTravMgr.ContraCodePrinted = ContraTravMgr.Transaction^.txAccount) then
  begin
    ContraTravMgr.AccountTotalNet := ContraTravMgr.AccountTotalNet +
                          (ContraTravMgr.Transaction^.txTemp_Base_Amount - ContraTravMgr.Transaction^.txGST_Amount);
    ContraTravMgr.AccountHasActivity := (ContraTravMgr.Transaction^.txTemp_Base_Amount <> 0) or
                              (ContraTravMgr.Transaction^.txGST_Amount <> 0);
  end;

  //bank contra
  if (ContraTravMgr.ContraCodePrinted = baFields.baContra_Account_Code) and
     (not (baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
  begin
    ContraTravMgr.AccountTotalNet    := ContraTravMgr.AccountTotalNet + (-ContraTravMgr.Transaction^.txTemp_Base_Amount);
    ContraTravMgr.AccountHasActivity := ContraTravMgr.Transaction^.txTemp_Base_Amount <> 0;
  end;

  //GST contra
  if (ContraTravMgr.ContraCodePrinted = GSTControlAccount) then
  begin
    ContraTravMgr.AccountTotalNet    := ContraTravMgr.AccountTotalNet + ContraTravMgr.Transaction^.txGST_Amount;
    ContraTravMgr.AccountHasActivity := ContraTravMgr.Transaction^.txGST_Amount <> 0;
  end;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.LGR_Contra_PrintDissect(Sender:Tobject);
var
  Code : Bk5CodeStr;
  ContraTravMgr  : TTravManagerCashBookExport;
  GSTControlAccount : string;
  baFields : tBank_Account_Rec;
begin
  ContraTravMgr := TTravManagerCashBookExport(Sender);

  //is bank account included in this report?
  //if not IsBankAccountIncluded(ReportJob, Mgr) then
  // Exit;

  Code := ContraTravMgr.Dissection^.dsAccount;
  baFields := ContraTravMgr.Bank_Account.baFields;
  //IsSummary := TListLedgerReport(ReportJob).SummaryOnly;

  //get GST control account if we need to display gst contras
  if (ContraTravMgr.GSTContraType > Byte(gcNone)) and (ContraTravMgr.Dissection^.dsGst_Class in [ 1..MAX_GST_CLASS ]) then
    GSTControlAccount := MyClient.clFields.clGST_Account_Codes[ContraTravMgr.Dissection^.dsGst_Class]
  else
    GSTControlAccount := '';

  //does this dissection line need to be handled? only if:
  //it is coded to the handled acount
  //the bank account it belongs to has this account as the contra
  //its GST class has this account as the control account
  if (ContraTravMgr.ContraCodePrinted <> ContraTravMgr.Dissection^.dsAccount) and
     (ContraTravMgr.ContraCodePrinted <> baFields.baContra_Account_Code) and
     (ContraTravMgr.ContraCodePrinted <> GSTControlAccount) then
    exit;

  // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
  if (GSTControlAccount = ContraTravMgr.ContraCodePrinted) and
     (ContraTravMgr.Dissection^.dsGST_Amount = 0) and
     (ContraTravMgr.Dissection^.dsAccount <> GSTControlAccount) then
    exit;

  // #2861 - do not show contras for journals (but show GST)
  if (baFields.baAccount_Type in LedgerNoContrasJournalSet) and
     (ContraTravMgr.ContraCodePrinted <> GSTControlAccount) and
     (ContraTravMgr.ContraCodePrinted <> Code) and
     (Code <> baFields.baContra_Account_Code) then
    exit;

  //print contra entries if requested
  //note: txn may be printed twice (actual entry and contra) if its coded to this account

  //normal txn
  if (ContraTravMgr.ContraCodePrinted = ContraTravMgr.Dissection^.dsAccount) then
  begin
    ContraTravMgr.AccountTotalNet    := ContraTravMgr.AccountTotalNet +
                             (ContraTravMgr.Dissection^.dsTemp_Base_Amount - ContraTravMgr.Dissection^.dsGST_Amount);
    ContraTravMgr.AccountHasActivity := (ContraTravMgr.Dissection^.dsTemp_Base_Amount <> 0) or
                              (ContraTravMgr.Dissection^.dsGST_Amount <> 0);
    ContraTravMgr.AccountHasActivity := True;
  end;

  //bank contra
  if (ContraTravMgr.ContraCodePrinted = baFields.baContra_Account_Code) and
     (not (baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
  begin
    ContraTravMgr.AccountTotalNet := ContraTravMgr.AccountTotalNet + (-ContraTravMgr.Dissection^.dsTemp_Base_Amount);
    ContraTravMgr.AccountHasActivity := ContraTravMgr.Dissection^.dsTemp_Base_Amount <> 0;
  end;

  //GST contra
  if (ContraTravMgr.ContraCodePrinted = GSTControlAccount) then // gst contra txn
  begin
    ContraTravMgr.AccountTotalNet := ContraTravMgr.AccountTotalNet + ContraTravMgr.Dissection^.dsGST_Amount;
    ContraTravMgr.AccountHasActivity := ContraTravMgr.Dissection^.dsGST_Amount <> 0;
  end;
end;

// Print the bank and gst contra entries
//------------------------------------------------------------------------------
function TChartExportCol.DoContras(aTravMgr : TTravManagerCashBookExport; aCode: string) : boolean;
var
  ContraTravMgr : TTravManagerCashBookExport;
  IsBankContra, IsGSTContra: Boolean;
  BC, GC: Integer;
  BCType, GCType: Byte;
begin
  Result := false;
  //are bank contras needed in this report for this code
  BC := IsABankContra(aCode, 0);
  BCType := aTravMgr.BankContra;
  IsBankContra := (BCType > Byte(bcNone)) and
                  (BC > -1);
  //are gst contras needed in this report for this code
  GC := IsAGSTContra(aCode, Low(MyClient.clFields.clGST_Account_Codes));
  GCType := aTravMgr.GSTContra;
  IsGSTContra := (GCType > Byte(gcNone)) and
                 (GC > -1);
  //we will have to look at every transaction again to find transactions with
  //bank accounts with this contra and to find gst contras
  if IsBankContra or IsGSTContra then
  begin
    ContraTravMgr := TTravManagerCashBookExport.Create;
    try
      ContraTravMgr.Clear;
      ContraTravMgr.SortType             := csDateEffective; // Date order within the contra code
      ContraTravMgr.SelectionCriteria    := TravList.twAllEntries;
      ContraTravMgr.AccountTotalNet      := 0;
      ContraTravMgr.AccountHasActivity   := false;
      ContraTravMgr.LastCodePrinted      := NullCode;
      ContraTravMgr.ContraCodePrinted    := aCode;
      ContraTravMgr.BankContraType       := BCType;
      ContraTravMgr.GSTContraType        := GCType;
      ContraTravMgr.OnEnterEntryExt      := LGR_Contra_PrintEntry;
      ContraTravMgr.OnEnterDissectionExt := LGR_Contra_PrintDissect;

      {HelpfulErrorMsg('Code : ' + aCode +
                      ', Rpt From Date : ' +
                      StDateToDateString('dd/mm/yyyy', FromDate, true) +
                      ', Rpt To Date : ' +
                      StDateToDateString('dd/mm/yyyy', ToDate, true), 0);}

      ContraTravMgr.TraverseAllEntries(fromdate ,Todate);

      aTravMgr.AccountTotalNet := aTravMgr.AccountTotalNet + ContraTravMgr.AccountTotalNet;

      aTravMgr.DoneSubTotal := True;
      Result := true;
    finally
      ContraTravMgr.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.CalculateEntry( Sender : TObject);
//trav manager has transactions sorted by account code
Var
  Code      : Bk5CodeStr;
  TravMgr   : TTravManagerCashBookExport;
  ChartItem : pAccount_Rec;
  IsContras, IsValidCode, OKToPrint: Boolean;
  ClosingBalance : Money;
begin
  TravMgr := TTravManagerCashBookExport(Sender);
  Code := TravMgr.Transaction^.txAccount;

  if ( Code = '') then
  begin
    IsTransactionsUncodedorInvalidlyCoded := true;
    exit;
  end;

  // has tx already been printed during contras?
  if (Code = TravMgr.ContraCodePrinted) and (TravMgr.ContraCodePrinted <> NullCode) then
    exit;

  TravMgr.ContraCodePrinted := NullCode;
  IsValidCode := Assigned(Chart.FindCode( Code ));

  if ( Code <> TravMgr.LastCodePrinted) then
  begin
    if ( TravMgr.LastCodePrinted <> NullCode) then
    begin
      if (TravMgr.AccountHasActivity or TravMgr.PrintEmptyCodes) and
         (not TravMgr.DoneSubTotal) and
         (TravMgr.LastCodePrinted <> '') then
      begin
        if IsValidCode then
          ClosingBalance := GetOpeningBalanceAmount(MyClient, TravMgr.LastCodePrinted) + TravMgr.AccountTotalNet
        else
        begin
          ClosingBalance := GetOpeningBalanceForInvalidCode(MyClient, TravMgr.LastCodePrinted, Fromdate) + TravMgr.AccountTotalNet;
          IsTransactionsUncodedorInvalidlyCoded := true;
        end;

        UpdateClosingBalancesForCode(TravMgr.LastCodePrinted, ClosingBalance, false);
      end;
    end;

    //clear temp information
    TravMgr.AccountHasActivity := false;
    TravMgr.AccountTotalNet    := 0;
    TravMgr.DoneSubTotal       := False;
    TravMgr.SplitCode          := '';

    //request to show all codes regardless of any activity
    //look for all codes in between last (valid) one printed and next to be printed
    if (TravMgr.LastCodePrinted = NullCode) or (TravMgr.LastValidCode = NullCode) then
      ChartItem := Chart.FindNextCode('', False)
    else if TravMgr.LastCodePrinted <> TravMgr.LastValidCode then
      ChartItem := Chart.FindNextCode(TravMgr.LastValidCode, False)
    else
      ChartItem := Chart.FindNextCode(TravMgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and
                   Assigned(ChartItem) and
                  (ChartItem^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (TravMgr.LastCodePrinted = TravMgr.LastValidCode) and
                  (TravMgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

    if Assigned(ChartItem) and (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and (ChartItem^.chAccount_Code <> Code) and (ChartItem^.chAccount_Code < Code) do
      begin
        //is code in range?
        IsContras := IsThisAContraCode(ChartItem^.chAccount_Code);
        if (IsContras) or
           (ChartItem^.chPosting_Allowed or
            (GetOpeningBalanceAmount(MyClient, ChartItem^.chAccount_Code) <> 0)) then
        begin
          DoContras(TravMgr, ChartItem^.chAccount_Code);
          ClosingBalance := GetOpeningBalanceAmount(MyClient, ChartItem^.chAccount_Code);
          ClosingBalance := ClosingBalance + TravMgr.AccountTotalNet;
          UpdateClosingBalancesForCode(ChartItem^.chAccount_Code, ClosingBalance, IsContras);
          TravMgr.LastValidCode := ChartItem^.chAccount_Code;
        end;
        TravMgr.AccountTotalNet := 0;
        TravMgr.DoneSubTotal := False;
        TravMgr.SplitCode := '';
        ChartItem := Chart.FindNextCode(ChartItem^.chAccount_Code, False);
        if not Assigned(ChartItem) then
          Break;
      end;
    end;

    TravMgr.LastCodePrinted    := Code;
    if IsValidCode then
      TravMgr.LastValidCode := Code;
    TravMgr.DoneSubTotal := False;
    TravMgr.SplitCode := '';

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code
    if IsThisAContraCode(Code) then
    begin
      TravMgr.AccountHasActivity := DoContras(TravMgr, Code);
      TravMgr.ContraCodePrinted := Code;
      Exit;
    end;
  end;

  //store values
  TravMgr.AccountTotalNet := TravMgr.AccountTotalNet +
                             ( TravMgr.Transaction^.txTemp_Base_Amount -
                               TravMgr.Transaction^.txGST_Amount);

  if (TravMgr.Transaction^.txTemp_Base_Amount <> 0) or
     (TravMgr.Transaction^.txGST_Amount <> 0) then
    TravMgr.AccountHasActivity := true;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.CalculateDisection( Sender : TObject);
Var
  Code    : Bk5CodeStr;
  TravMgr : TTravManagerCashBookExport;
  ChartItem : pAccount_Rec;
  IsContras, IsValidCode, OKToPrint: Boolean;
  ClosingBalance : Money;
begin
  TravMgr := TTravManagerCashBookExport(Sender);
   //with Mgr, ReportJob,TListLedgerReport(ReportJob).Params, Mgr.Transaction^, Mgr.Dissection^ do begin

  Code := TravMgr.Dissection^.dsAccount;
  //is code in range?
  //if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then
  //   Exit;

  // has tx already been printed during contras?
  if (Code = TravMgr.ContraCodePrinted) and (TravMgr.ContraCodePrinted <> NullCode) then
    Exit;

  TravMgr.ContraCodePrinted := NullCode;
  IsValidCode := Assigned(Chart.FindCode( Code ));

//code has changed

  if ( Code <> TravMgr.LastCodePrinted) then
  begin
    if ( TravMgr.LastCodePrinted <> NullCode) then
    begin
      if (TravMgr.AccountHasActivity or TravMgr.PrintEmptyCodes) and
         (not TravMgr.DoneSubTotal) and
         (TravMgr.LastCodePrinted <> '') then
      begin
        if IsValidCode then
          ClosingBalance := GetOpeningBalanceAmount(MyClient, TravMgr.LastCodePrinted) + TravMgr.AccountTotalNet
        else
        begin
          ClosingBalance := GetOpeningBalanceForInvalidCode(MyClient, TravMgr.LastCodePrinted, Fromdate) + TravMgr.AccountTotalNet;
          IsTransactionsUncodedorInvalidlyCoded := true;
        end;

        UpdateClosingBalancesForCode(TravMgr.LastCodePrinted, ClosingBalance, false);
      end;
    end;

    //clear temp information
    TravMgr.AccountHasActivity := false;
    TravMgr.AccountTotalNet    := 0;
    TravMgr.DoneSubTotal       := False;
    TravMgr.SplitCode          := '';

    //request to show all codes regardless of any activity
     //look for all codes in between last one printed and next to be printed
    if (TravMgr.LastCodePrinted = NullCode) or (TravMgr.LastValidCode = NullCode) then
      ChartItem := Chart.FindNextCode('', False)
    else if TravMgr.LastCodePrinted <> TravMgr.LastValidCode then
      ChartItem := Chart.FindNextCode(TravMgr.LastValidCode, False)
    else
      ChartItem := Chart.FindNextCode(TravMgr.LastCodePrinted, False);

    OKToPrint := ((not IsValidCode) and
                   Assigned(ChartItem) and
                  (ChartItem^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (TravMgr.LastCodePrinted = TravMgr.LastValidCode) and
                  (TravMgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

    if Assigned(ChartItem) and (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and (ChartItem^.chAccount_Code <> Code) and (ChartItem^.chAccount_Code < Code) do
      begin
        //is code in range?
        IsContras := IsThisAContraCode(ChartItem^.chAccount_Code);
        if (IsContras) or
           (ChartItem^.chPosting_Allowed or
            (GetOpeningBalanceAmount(MyClient, ChartItem^.chAccount_Code) <> 0)) then
        begin
          DoContras(TravMgr, ChartItem^.chAccount_Code);
          ClosingBalance := GetOpeningBalanceAmount(MyClient, ChartItem^.chAccount_Code);
          ClosingBalance := ClosingBalance + TravMgr.AccountTotalNet;
          UpdateClosingBalancesForCode(ChartItem^.chAccount_Code, ClosingBalance, IsContras);
          TravMgr.LastValidCode := ChartItem^.chAccount_Code;
        end;
        TravMgr.AccountTotalNet := 0;
        TravMgr.DoneSubTotal := False;
        TravMgr.SplitCode := '';
        ChartItem := Chart.FindNextCode(ChartItem^.chAccount_Code, False);
        if not Assigned(ChartItem) then
          Break;
      end;
    end;

    TravMgr.LastCodePrinted    := Code;
    if IsValidCode then
      TravMgr.LastValidCode := Code;
    TravMgr.DoneSubTotal := False;
    TravMgr.SplitCode := '';

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code
    if IsThisAContraCode(Code) then
    begin
      TravMgr.AccountHasActivity := DoContras(TravMgr, Code);
      TravMgr.ContraCodePrinted := Code;
      Exit;
    end;
  end;

  //store values
  TravMgr.AccountTotalNet := TravMgr.AccountTotalNet +
                             ( TravMgr.Dissection^.dsTemp_Base_Amount -
                               TravMgr.Dissection^.dsGST_Amount);

  if (TravMgr.Dissection^.dsTemp_Base_Amount <> 0) or
     (TravMgr.Dissection^.dsGST_Amount <> 0) then
    TravMgr.AccountHasActivity := true;
end;

//------------------------------------------------------------------------------
procedure TChartExportCol.CalculateTransactionTotals;
var
  TravMgr   : TTravManagerCashBookExport;
  ChartItem : pAccount_Rec;
  IsContras : Boolean;
  ISOCodes  : string;
  ClosingBalance : Money;
begin
  IsTransactionsUncodedorInvalidlyCoded := false;
  //Check Forex
  if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, {ForReport=}True, {AllBankAccounts=}False) then
  begin
    HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
    Exit;
  end;

  TravMgr := TTravManagerCashBookExport.Create;
  try
     TravMgr.Clear;
     TravMgr.SortType             := csAccountCode;
     TravMgr.SelectionCriteria    := TravList.twAllEntries;

     TravMgr.AccountTotalNet      := 0;
     TravMgr.AccountHasActivity   := false;
     TravMgr.LastCodePrinted      := NullCode;
     TravMgr.ContraCodePrinted    := NullCode;
     TravMgr.LastValidCode        := NullCode;

     TravMgr.OnEnterEntryExt      := CalculateEntry;
     TravMgr.OnEnterDissectionExt := CalculateDisection;
     TravMgr.DoneSubTotal := False;
     TravMgr.SplitCode := '';
     TravMgr.BankContra := Byte(bcAll);
     TravMgr.GSTContra  := Byte(gcAll);

     TravMgr.TraverseAllEntries(Fromdate, Todate);

     if TravMgr.AccountHasActivity then
     begin
       if (TravMgr.LastCodePrinted = TravMgr.ContraCodePrinted) then
       begin
         ClosingBalance := GetOpeningBalanceAmount(MyClient, TravMgr.LastCodePrinted) + TravMgr.AccountTotalNet;
         UpdateClosingBalancesForCode(TravMgr.LastCodePrinted, ClosingBalance, false);
       end
       else if (TravMgr.ContraCodePrinted = NullCode) then
       begin
         if TravMgr.LastCodePrinted = TravMgr.LastValidCode then
           ClosingBalance := GetOpeningBalanceAmount(MyClient, TravMgr.LastCodePrinted) + TravMgr.AccountTotalNet
         else
           ClosingBalance := GetOpeningBalanceForInvalidCode(MyClient, TravMgr.LastCodePrinted, Fromdate) + TravMgr.AccountTotalNet;
         UpdateClosingBalancesForCode(TravMgr.LastCodePrinted, ClosingBalance, false);
       end;

     end;

     // show remaining empty codes
     // Show inactive codes if requested
     TravMgr.AccountTotalNet := 0;
     TravMgr.DoneSubTotal := False;
     TravMgr.SplitCode := '';
     if TravMgr.LastValidCode = NullCode then
       ChartItem := Chart.FindNextCode('', False)
     else
       ChartItem := Chart.FindNextCode(TravMgr.LastValidCode, False);
     if Assigned(ChartItem) then
     begin
       while Assigned(ChartItem) do
       begin
         IsContras := IsThisAContraCode(ChartItem^.chAccount_Code);
         if IsContras then
         begin
           DoContras(TravMgr, ChartItem^.chAccount_Code);
           ClosingBalance := GetOpeningBalanceAmount(MyClient, ChartItem^.chAccount_Code);
           ClosingBalance := ClosingBalance + TravMgr.AccountTotalNet;
           UpdateClosingBalancesForCode(ChartItem^.chAccount_Code, ClosingBalance, IsContras);
         end;
         TravMgr.AccountTotalNet := 0;
         TravMgr.DoneSubTotal := False;
         TravMgr.SplitCode := '';
         ChartItem := Chart.FindNextCode(ChartItem^.chAccount_Code, False);
       end;
     end;
  finally
    TravMgr.Free;
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

    if AccountRec.chInactive then
      continue;

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

//------------------------------------------------------------------------------
function TChartExportCol.ItemAtCode(aCode: string; out aChartExportItem : TChartExportItem) : boolean;
var
  ChartIndex : integer;
  ChartExportItem : TChartExportItem;
begin
  aChartExportItem := nil;
  result := false;

  for ChartIndex := 0 to Count - 1 do
  begin
    if ItemAtColIndex(ChartIndex, ChartExportItem) then
    begin
      if ChartExportItem.AccountCode = aCode then
      begin
        aChartExportItem := ChartExportItem;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

{ TGSTMapClassInfo }
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

  NewGSTMapItem.DispPracCode     := aPracticeGstCode;
  NewGSTMapItem.DispPracDesc     := aPracticeGstDesc;
  NewGSTMapItem.DispMYOBIndex    := ord(aCashbookGstClass)-1;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetMappedAUGSTTypeCode(aGSTClassDescription : string): TCashBookGSTClasses;
var
  UpperCaseInput : string;
begin
  UpperCaseInput := FixCharactersInString(aGSTClassDescription);

  if (UpperCaseInput = FixCharactersInString('10% GST (Sales)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions subject to GST (other)')) or
     (UpperCaseInput = FixCharactersInString('Expenses')) or
     (UpperCaseInput = FixCharactersInString('Goods and services tax')) or
     (UpperCaseInput = FixCharactersInString('GST')) or
     (UpperCaseInput = FixCharactersInString('GST Payable (Output Tax)')) or
     (UpperCaseInput = FixCharactersInString('Income')) or
     (UpperCaseInput = FixCharactersInString('Income subject to GST')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap. Acq. - Inc GST')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap. Aqn. - Inc. GST')) or
     (UpperCaseInput = FixCharactersInString('Non-capital Purchases')) or
     (UpperCaseInput = FixCharactersInString('Other Acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Purchases (other)')) or
     (UpperCaseInput = FixCharactersInString('Purchases subject to GST')) or
     (UpperCaseInput = FixCharactersInString('Sales subject to GST')) or
     (UpperCaseInput = FixCharactersInString('Supplies subject to GST (normal)')) or
     (UpperCaseInput = FixCharactersInString('Taxable acquisitions - other (purchases)')) or
     (UpperCaseInput = FixCharactersInString('Taxable purchases (non-capital)')) or
     (UpperCaseInput = FixCharactersInString('Taxable sales')) or
     (UpperCaseInput = FixCharactersInString('Taxable supplies')) or
     (UpperCaseInput = FixCharactersInString('Taxable supplies (sales)')) then
  begin
    Result := cgGoodsandServices;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Acquisitions subject to GST (capital)')) or
     (UpperCaseInput = FixCharactersInString('Cap. Aqn. - Inc GST')) or
     (UpperCaseInput = FixCharactersInString('Capital Acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Capital Purchases')) or
     (UpperCaseInput = FixCharactersInString('Purchases (capital)')) or
     (UpperCaseInput = FixCharactersInString('Taxable acquisitions - capital (purchases)')) or
     (UpperCaseInput = FixCharactersInString('Cap. Acq. – Inc GST')) or
     (UpperCaseInput = FixCharactersInString('Taxable purchases (capital)')) then
  begin
    Result := cgCapitalAcquisitions;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Export sales')) or
     (UpperCaseInput = FixCharactersInString('Export sales and income')) or
     (UpperCaseInput = FixCharactersInString('Export Supplies')) or
     (UpperCaseInput = FixCharactersInString('Exports')) or
     (UpperCaseInput = FixCharactersInString('Exports (GST Free)')) or
     (UpperCaseInput = FixCharactersInString('Exports (not subject to GST)')) or
     (UpperCaseInput = FixCharactersInString('Exports (sales)')) or
     (UpperCaseInput = FixCharactersInString('GST Free Exports')) then
  begin
    Result := cgExportSales;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Acquisition with no GST')) or
     (UpperCaseInput = FixCharactersInString('Acquisition with no GST (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions used for private use/non deductible  (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions used for private use/non deductible  (other)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions with no GST in the price (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions with no GST in the price (other)')) or
     (UpperCaseInput = FixCharactersInString('Cap. Acq. - GST Free')) or
     (UpperCaseInput = FixCharactersInString('Capital GST free supplies')) or
     (UpperCaseInput = FixCharactersInString('Capital purchases with no GST')) or
     (UpperCaseInput = FixCharactersInString('Estimated purchases for private use/non-deductible')) or
     (UpperCaseInput = FixCharactersInString('Estimated purchases for private use/non-deductible (capital)')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap. Aqn. – GST FREE')) or
     (UpperCaseInput = FixCharactersInString('Non-taxable supplies')) or
     (UpperCaseInput = FixCharactersInString('GST Free')) or
     (UpperCaseInput = FixCharactersInString('GST free capital acquisitions')) or
     (UpperCaseInput = FixCharactersInString('GST free other acquisitions')) or
     (UpperCaseInput = FixCharactersInString('GST free purchases')) or
     (UpperCaseInput = FixCharactersInString('GST free sales')) or
     (UpperCaseInput = FixCharactersInString('GST Free Supplies')) or
     (UpperCaseInput = FixCharactersInString('GST free supplies (sales')) or
     (UpperCaseInput = FixCharactersInString('GST free supplies (sales)')) or
     (UpperCaseInput = FixCharactersInString('GST-free purchases')) or
     (UpperCaseInput = FixCharactersInString('GST-free purchases (capital)')) or
     (UpperCaseInput = FixCharactersInString('No GST applicable')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap. Acq. - GST Free')) or
     (UpperCaseInput = FixCharactersInString('Non-capital purchases with no GST')) or
     (UpperCaseInput = FixCharactersInString('Non-income tax deductible acquisition')) or
     (UpperCaseInput = FixCharactersInString('Non-taxable purchases')) or
     (UpperCaseInput = FixCharactersInString('Other GST free supplies')) or
     (UpperCaseInput = FixCharactersInString('Other GST-free sales')) or
     (UpperCaseInput = FixCharactersInString('Private Purchases')) or
     (UpperCaseInput = FixCharactersInString('Private use capital acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Private use of non-deductible purchases')) or
     (UpperCaseInput = FixCharactersInString('Private use other acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Private use/non deductible - capital (purchases)')) or
     (UpperCaseInput = FixCharactersInString('Private use/non deductible - other (purchases)')) or
     (UpperCaseInput = FixCharactersInString('Sales not subject to GST')) then
  begin
    Result := cgGSTFree;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Input taxed sales')) or
     (UpperCaseInput = FixCharactersInString('Input taxed sales & supplies')) or
     (UpperCaseInput = FixCharactersInString('Input taxed sales and income')) or
     (UpperCaseInput = FixCharactersInString('Input Taxed Supplies')) or
     (UpperCaseInput = FixCharactersInString('Input taxed supplies (sales)')) or
     (UpperCaseInput = FixCharactersInString('Input taxed supplies (sales)')) or
     (UpperCaseInput = FixCharactersInString('Input-taxed Sales & Income & other Supplies')) then
  begin
    Result := cgInputTaxedSales;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Acquisition for input taxed sales')) or
     (UpperCaseInput = FixCharactersInString('Acquisition for input taxed sales (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisition with no GST (input taxed)')) or
     (UpperCaseInput = FixCharactersInString('Acquisition with no GST (input taxed) (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions used to make input taxed income (capital)')) or
     (UpperCaseInput = FixCharactersInString('Acquisitions used to make input taxed income (other)')) or
     (UpperCaseInput = FixCharactersInString('Cap. Acq. - for making Input Taxed Sales')) or
     (UpperCaseInput = FixCharactersInString('Capital purchases for input taxed supplies')) or
     (UpperCaseInput = FixCharactersInString('Capital Purchases for producing input taxed supplies')) or
     (UpperCaseInput = FixCharactersInString('Input taxed capital acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Input taxed other acquisitions')) or
     (UpperCaseInput = FixCharactersInString('Input Taxed Purchases')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap. Aqn. - For Making Input Taxes Supplies')) or
     (UpperCaseInput = FixCharactersInString('Non-Cap.Acq. - for making Input Taxed Sales')) or
     (UpperCaseInput = FixCharactersInString('Other purchases for input taxed supplies')) or
     (UpperCaseInput = FixCharactersInString('Purchases for input taxed sales')) or
     (UpperCaseInput = FixCharactersInString('Purchases for making input-taxed sales')) or
     (UpperCaseInput = FixCharactersInString('Purchases for making input-taxed sales (capital)')) or
     (UpperCaseInput = FixCharactersInString('Purchases for producing input taxed supplies')) or
     (UpperCaseInput = FixCharactersInString('Reduced input tax credit - capital (purchases)')) or
     (UpperCaseInput = FixCharactersInString('Reduced input tax credit - other (purchases)')) then
  begin
    Result := cgPurchaseForInput;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('Items not reported')) then
  begin
    Result := cgNotReportable;
    Exit;
  end;

  if (UpperCaseInput = FixCharactersInString('No GST/unregistered supplier - capital (purchases)')) or
     (UpperCaseInput = FixCharactersInString('No GST/unregistered supplier - other (purchases)')) then
  begin
    Result := cgGSTNotRegistered;
    Exit;
  end;

  Result := cgNone;
end;

//------------------------------------------------------------------------------
function TGSTMapCol.CheckIfAllGstCodesAreMapped: boolean;
var
  GstIndex : integer;
  GSTMapItem: TGSTMapItem;
begin
  Result := true;
  for GstIndex := 0 to Count-1 do
  begin
    if ItemAtColIndex(GstIndex, GSTMapItem) then
    begin
      GSTMapItem.CashbookGstClass := TCashBookGSTClasses(GSTMapItem.DispMYOBIndex + 1);

      if GSTMapItem.CashbookGstClass = cgNone then
      begin
        Result := false;
        Exit;
      end;
    end;
  end;
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
function TGSTMapCol.FixCharactersInString(aInstring: string): string;
const
  MINUS = '-';
  DASH = '–';
var
  Index : integer;
begin
  Result := '';

  for Index := 1 to length(aInstring) do
  begin
    if aInstring[Index] = DASH then
      Result := Result + MINUS
    else
      Result := Result + aInstring[Index];
  end;

  Result := Uppercase(Result);
end;

//------------------------------------------------------------------------------
function TGSTMapCol.GetGSTClassCode(aCashbookGstClass: TCashBookGSTClasses): string;
var
  GstClassIndex : integer;
begin
  Result := 'NA';
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
            begin
              GSTMapItem.CashbookGstClass := GSTClass;
              GSTMapItem.DispMYOBIndex := ord(GSTClass)-1;
            end;
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

        TGSTMapItem(self.Items[LineIndex]).fCashbookGstClass :=
          TCashBookGSTClasses(TGSTMapItem(self.Items[LineIndex]).DispMYOBIndex+1);

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
          on e : EInOutError do
          begin
            aError := GetIOErrorDescription(E.ErrorCode, E.Message);
            Exit;
          end;
          on e: exception do
          begin
            aError := e.Message;
            Exit;
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
function TChartExportToMYOBCashbook.CheckNZGStTypes() : boolean;
var
  GstIndex : integer;
begin
  Result := true;

  for GstIndex := 1 to 99 do
  begin
    if MyClient.clfields.clGST_Class_Names[GstIndex] > '' then
    begin
      if GetGSTClassTypeIndicatorFromGSTClass(GstIndex) = 0 then
      begin
        Result := false;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.CheckReportGroups() : boolean;
var
  ChartIndex : integer;
  ChartExportItem: TChartExportItem;
begin
  Result := true;
  for ChartIndex := 0 to ChartExportCol.Count-1 do
  begin
    ChartExportCol.ItemAtColIndex(ChartIndex, ChartExportItem);

    if (ChartExportItem.PostingAllowed) and
       (ChartExportCol.GetMappedReportGroupId(ChartExportItem.ReportGroupId) = ccNone) then
    begin
      Result := false;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.CheckGSTControlAccAndRates() : boolean;
var
  GstIndex : integer;
begin
  Result := true;

  for GstIndex := 1 to 99 do
  begin
    if MyClient.clfields.clGST_Class_Names[GstIndex] > '' then
    begin
      if not ((MyClient.clfields.clGST_Rates[GstIndex,1] = 0) and
              (MyClient.clfields.clGST_Rates[GstIndex,2] = 0) and
              (MyClient.clfields.clGST_Rates[GstIndex,3] = 0) and
              (MyClient.clfields.clGST_Rates[GstIndex,4] = 0) and
              (MyClient.clfields.clGST_Rates[GstIndex,5] = 0)) then
      begin
        if MyClient.clfields.clGST_Account_Codes[GstIndex] = '' then
        begin
          Result := false;
          Exit;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.RunExportChartToFile(aFilename : string;
                                                         var aErrorStr : string;
                                                         aShowUI : boolean): boolean;
var
  FileLines   : TStringList;
  LineColumns : TStringList;
  LineIndex   : integer;
  GSTMapItem  : TGSTMapItem;
  GSTClass    : TCashBookGSTClasses;
  CashBookGstClassCode : string;
  CashBookGstClassDesc : string;
  ChartExportItem: TChartExportItem;
  GSTClassTypeIndicator : byte;
  MappedGroupId : TCashBookChartClasses;
begin
  Result := False;

  FileLines := TStringList.Create;
  try
    FileLines.Clear;
    FileLines.Add('Code,Description,Account Group,GST Type,Opening Balance,Opening Balance Date');

    LineColumns := TStringList.Create;
    try
      LineColumns.Delimiter := ',';
      LineColumns.StrictDelimiter := True;

      for LineIndex := 0 to ChartExportCol.Count - 1 do
      begin
        if ChartExportCol.ItemAtColIndex(LineIndex, ChartExportItem) then
        begin
          // Don't Allow Non Basic Items when option is set
          if (self.ExportChartFrmProperties.ExportBasicChart = true) and
             (ChartExportItem.IsBasicChartItem = false) then
            Continue;

          // Don't Allow Non Posting Codes
          if (ChartExportItem.fPostingAllowed = false) then
            Continue;

          LineColumns.Clear;

          LineColumns.Add(ChartExportItem.AccountCode);
          LineColumns.Add(StripInvalidCharacters(ChartExportItem.AccountDescription));

          MappedGroupId := ChartExportCol.GetMappedReportGroupId(ChartExportItem.fReportGroupId);
          LineColumns.Add(GetMappedReportGroupCode(MappedGroupId));

          if (Country = whAustralia) then
          begin
            if GSTMapCol.ItemAtGstIndex(ChartExportItem.GSTClassId, GSTMapItem) then
              CashBookGstClassCode := GSTMapCol.GetGSTClassCode(GSTMapItem.CashbookGstClass)
            else
              CashBookGstClassCode := GSTMapCol.GetGSTClassCode(cgNone);
          end
          else if (Country = whNewZealand) then
          begin
            GSTClassTypeIndicator := GetGSTClassTypeIndicatorFromGSTClass(ChartExportItem.GSTClassId);
            GSTClass := GetMappedNZGSTTypeCode(GSTClassTypeIndicator);
            GetMYOBCashbookGSTDetails(GSTClass, CashBookGstClassCode, CashBookGstClassDesc);
          end;
          LineColumns.Add(CashBookGstClassCode);
          LineColumns.Add(ChartExportItem.ClosingBalance); // Opeing Balance
          LineColumns.Add(ChartExportItem.ClosingBalanceDate); // Opeing Balance Date
          FileLines.Add(LineColumns.DelimitedText);
        end;
      end;

      if FileLines.Count > 0 then
      begin
        try
          FileLines.SaveToFile(aFilename);

          if aShowUI then
            HelpfulInfoMsg(inttostr(FileLines.Count) +
                                    ' Account codes successfully exported to ' + #13#10#13#10 +
                                    aFilename,0);
          Result := True;
        except
          on e: exception do
          begin
            aErrorStr := e.Message;
            Exit;
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

//------------------------------------------------------------------------------
constructor TChartExportToMYOBCashbook.Create;
begin
  fCountry := GetCountry();

  fChartExportCol := TChartExportCol.Create(TChartExportItem);
  fGSTMapCol := TGSTMapCol.Create(TGSTMapItem);

  fExportChartFrmProperties := TExportChartFrmProperties.Create;
  ExportChartFrmProperties.ExportBasicChart := false;
  ExportChartFrmProperties.IncludeClosingBalances := false;
  ExportChartFrmProperties.ClosingBalanceDate := CurrentDate;
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
procedure TChartExportToMYOBCashbook.DoChartExport(aPopupParent: TForm; aOverrideFilename : string; aOverrideIncludeBalances : boolean);
const
  ThisMethodName = 'DoChartExport';
var
  Res : Boolean;
  ErrorStr : string;
  Filename : string;
  ErrorStrings : TStringList;
  BalDate : TStDate;
  ShowUI : boolean;
begin
  Res := true;

  if not assigned(MyClient) then
    Exit;

  ShowUI := Assigned(aPopupParent);

  ErrorStrings := TStringList.Create;
  Try
    if not ChartExportCol.CheckAccountCodesLength(ErrorStrings) then
    begin
      if ShowUI then
        ShowChartExportAccountCodeErrors(Application.MainForm, ErrorStrings);

      Res := false;
      Exit;
    end;
  Finally
    FreeAndNil(ErrorStrings);
  End;

  ExportChartFrmProperties.ClientCode := MyClient.clFields.clCode;
  ChartExportCol.FillChartExportCol(false);

  if (Country = whAustralia) then
  begin
    GSTMapCol.PrevGSTFileLocation := MyClient.clExtra.ceCashbook_GST_Map_File_Location;
    FillGstMapCol(ChartExportCol, GSTMapCol);

    if GSTMapCol.PrevGSTFileLocation <> '' then
    begin
      if FileExists(GSTMapCol.PrevGSTFileLocation) then
      begin
        Filename := GSTMapCol.PrevGSTFileLocation;
        if not GSTMapCol.LoadGSTFile(Filename, ErrorStr) then
        begin
          if ShowUI then
          begin
            HelpfulErrorMsg(ErrorStr,0);
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
          end;
        end;
      end;
    end;

    if ShowUI then
      Res := ShowMapGSTClass(aPopupParent, fGSTMapCol)
    else
      Res := true;

    if Res then
    begin
      if (ShowUI) and
         (not (Filename = '')) then
        Res := GSTMapCol.SaveGSTFile(Filename, ErrorStr);

      if Res then
      begin
        if (GSTMapCol.PrevGSTFileLocation <> MyClient.clExtra.ceCashbook_GST_Map_File_Location) then
          MyClient.clExtra.ceCashbook_GST_Map_File_Location := GSTMapCol.PrevGSTFileLocation;
      end
      else
      begin
        if ShowUI then
        begin
          HelpfulErrorMsg(ErrorStr,0);
          LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
        end;
      end;
    end;
  end
  else if (Country = whNewZealand) then
  begin
    if not CheckNZGStTypes() then
    begin
      if ShowUI then
      begin
        ErrorStr := 'Please assign a GST type to all rates, Other Functions | GST Setup | Rates.';
        HelpfulWarningMsg(ErrorStr,0);
      end;
      Exit;
    end;
  end;

  if Res then
  begin
    if (MyClient.clExtra.ceCashbook_Export_File_Location = '') then
      ExportChartFrmProperties.ExportFileLocation := UserDir + MyClient.clFields.clCode +
                                                     '_MYOB_Cashbook_Chart.csv'
    else
      ExportChartFrmProperties.ExportFileLocation := MyClient.clExtra.ceCashbook_Export_File_Location;

    ExportChartFrmProperties.IncludeClosingBalances := aOverrideIncludeBalances;

    if GetLastFullyCodedMonth(BalDate) then
      ExportChartFrmProperties.ClosingBalanceDate := BalDate
    else
      ExportChartFrmProperties.ClosingBalanceDate := BkNull2St(MyClient.clFields.clPeriod_End_Date);

    ExportChartFrmProperties.AreGSTAccountSetup := CheckGSTControlAccAndRates();
    ExportChartFrmProperties.AreOpeningBalancesSetup :=
      JnlUtils32.CheckForOpeningBalance( MyClient, MyClient.clFields.clReporting_Year_Starts);
    ExportChartFrmProperties.NonBasicCodesHaveBalances :=
      DoNonBasicCodesHaveBalances(ExportChartFrmProperties.NonBasicCodes);
    ExportChartFrmProperties.IsTransactionsUncodedorInvalidlyCoded :=
      ChartExportCol.IsTransactionsUncodedorInvalidlyCoded;
    ExportChartFrmProperties.CalcClosingBalanceEvent := ChartExportCol.CheckIfNonBasicCodesHaveBalances;

    if ShowUI then
      Res := ShowChartExport(aPopupParent, ExportChartFrmProperties)
    else
      Res := true;

    if Res then
    begin
      if Length(aOverrideFilename) > 0 then
        ExportChartFrmProperties.ExportFileLocation := aOverrideFilename;

      Res := RunExportChartToFile(ExportChartFrmProperties.ExportFileLocation, ErrorStr, ShowUI);

      if Res then
      begin
        if (ExportChartFrmProperties.ExportFileLocation <> MyClient.clExtra.ceCashbook_Export_File_Location) then
          MyClient.clExtra.ceCashbook_Export_File_Location := ExportChartFrmProperties.ExportFileLocation;
      end
      else
      begin
        if ShowUI then
        begin
          HelpfulErrorMsg(ErrorStr,0);
          LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TChartExportToMYOBCashbook.DoNonBasicCodesHaveBalances(var aNonBasicCodes : TStringList) : boolean;
var
  ChartIndex : integer;
  aChartExportItem : TChartExportItem;
begin
  Result := false;
  aNonBasicCodes.Clear;
  for ChartIndex := 0 to ChartExportCol.Count-1 do
  begin
    if ChartExportCol.ItemAtColIndex(ChartIndex, aChartExportItem) then
    begin
      if (aChartExportItem.HasOpeningBalance) and
         (not aChartExportItem.IsBasicChartItem) then
      begin
        Result := true;
        aNonBasicCodes.Add(aChartExportItem.AccountCode);
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
