unit BKLedgerRptColumnManager;

interface

uses
  SysUtils, Classes, BKReportColumnManager, clObj32, NewReportObj, TravList,
  bkConst, OmniXML, OmniXMLUtils;

const
  //Super Field tokens
  tktxSF_Imputed_Credit                = 200 ;
  tktxSF_Tax_Free_Dist                 = 201 ;
  tktxSF_Tax_Exempt_Dist               = 202 ;
  tktxSF_Tax_Deferred_Dist             = 203 ;
  tktxSF_TFN_Credits                   = 204 ;
  tktxSF_Foreign_Income                = 205 ;
  tktxSF_Foreign_Tax_Credits           = 206 ;
  tktxSF_Capital_Gains_Indexed         = 207 ;
  tktxSF_Capital_Gains_Disc            = 208 ;
  tktxSF_Capital_Gains_Other           = 210 ;
  tktxSF_Other_Expenses                = 211 ;
  tktxSF_CGT_Date                      = 212 ;
  tktxSF_Franked                       = 221 ;
  tktxSF_UnFranked                     = 222 ;
  tktxSF_Interest                      = 223 ;
  tktxSF_Capital_Gains_Foreign_Disc    = 224 ;
  tktxSF_Rent                          = 225 ;
  tktxSF_Special_Income                = 226 ;
  tktxSF_Other_Tax_Credit              = 227 ;
  tktxSF_Non_Resident_Tax              = 228 ;
  tktxSF_Member_ID                     = 229 ;
  tktxSF_Foreign_Capital_Gains_Credit  = 230 ;
  tktxSF_Member_Component              = 231 ;
  tktxSF_Fund_ID                       = 232 ;
  tktxSF_Member_Account_ID             = 233 ;
  tktxSF_Fund_Code                     = 234 ;
  tktxSF_Member_Account_Code           = 235 ;
  tktxSF_Transaction_ID                = 236 ;
  tktxSF_Transaction_Code              = 237 ;
  tktxSF_Capital_Gains_Fraction_Half   = 238 ;


//Transaction Extension Record - Super Fund fields
  tkteSF_Other_Income                  = 166 ;
  tkteSF_Other_Trust_Deductions        = 167 ;
  tkteSF_CGT_Concession_Amount         = 168 ;
  tkteSF_CGT_ForeignCGT_Before_Disc    = 169 ;
  tkteSF_CGT_ForeignCGT_Indexation     = 170 ;
  tkteSF_CGT_ForeignCGT_Other_Method   = 171 ;
  tkteSF_CGT_TaxPaid_Indexation        = 172 ;
  tkteSF_CGT_TaxPaid_Other_Method      = 173 ;
  tkteSF_Other_Net_Foreign_Income      = 174 ;
  tkteSF_Cash_Distribution             = 175 ;
  tkteSF_AU_Franking_Credits_NZ_Co     = 176 ;
  tkteSF_Non_Res_Witholding_Tax        = 177 ;
  tkteSF_LIC_Deductions                = 178 ;
  tkteSF_Non_Cash_CGT_Discounted_Before_Discount = 179 ;
  tkteSF_Non_Cash_CGT_Indexation       = 180 ;
  tkteSF_Non_Cash_CGT_Other_Method     = 181 ;
  tkteSF_Non_Cash_CGT_Capital_Losses   = 182 ;
  tkteSF_Share_Brokerage               = 183 ;
  tkteSF_Share_Consideration           = 184 ;
  tkteSF_Share_GST_Amount              = 185 ;
  tkteSF_Share_GST_Rate                = 186 ;
  tkteSF_Cash_Date                     = 187 ;
  tkteSF_Accrual_Date                  = 188 ;
  tkteSF_Record_Date                   = 189 ;
  tkteSF_Contract_Date                 = 190 ;
  tkteSF_Settlement_Date               = 191 ;


  //Calculated fields
  CALC_NET        = CALC_FIELD + 1;
  CALC_AVG_NET    = CALC_FIELD + 2;

type

  TLedgerReportColumnList = class(TReportColumnList)
  private
    FIsSuperFund: boolean;
    FIsDissection: boolean;
    FIsSummarised: boolean;
    FCode: BK5CodeStr;
    FIsBankContra: boolean;
    FIsGSTContra: boolean;
    FShowBalances: boolean;
    FShowNotes: boolean;
    FShowQuantity: boolean;
    FShowGrossGST: boolean;
    function HasSuperFundColumns: boolean;
    procedure OutputTransaction(aReportColumnItem: TReportColumnItem);
    procedure OutputDissection(aReportColumnItem: TReportColumnItem);
    procedure OutputSummarised(aReportColumnItem: TReportColumnItem);
    procedure OutputContra(aReportColumnItem: TReportColumnItem);
    procedure PutSuperMoney(aAmount: comp);
    procedure SetDefaultColWidths;
    procedure AddBGLColumns;
    procedure AddBGL360Columns;
    procedure AddDesktopSuperColumns;
    procedure AddMYOBSuperFundColumns;
    procedure SetIsDissection(const Value: boolean);
    procedure SetIsSummarised(const Value: boolean);
    procedure SetCode(const Value: BK5CodeStr);
    procedure SetIsBankContra(const Value: boolean);
    procedure SetIsGSTContra(const Value: boolean);
    procedure SetShowBalances(const Value: boolean);
    procedure SetShowGrossGST(const Value: boolean);
    procedure SetShowNotes(const Value: boolean);
    procedure SetShowQuantity(const Value: boolean);
//    procedure AddIRESSXplanColumns;
//    procedure AddPraemiumColumns;
//    procedure AddSuperIPColumns;
  protected
    function CanClipColumn(aColumnItem: TReportColumnItem): boolean; override;
    function CanWrapColumn(aColumnItem: TReportColumnItem): boolean; override;
    function GetColumnTitle(aDataUnit: string; aDataToken: integer): string; override;
    function GetFieldSize(aReportColumnItem: TReportColumnItem): double; override;
    procedure AutoCalcColumnWidths; override;
    procedure OutputColumn(aReportColumnItem: TReportColumnItem); override;
    procedure SaveReportSettings; override;
  public
    function CompatableSuperfund(AccountingSystem: byte): boolean;
    procedure SetupColumns; override;
    procedure UpdateColumns;
    property IsDissection: boolean read FIsDissection write SetIsDissection;
    property IsSummarised: boolean read FIsSummarised write SetIsSummarised;
    property Code: BK5CodeStr read FCode write SetCode;
    property IsBankContra: boolean read FIsBankContra write SetIsBankContra;
    property IsGSTContra: boolean read FIsGSTContra write SetIsGSTContra;
    property ShowBalances: boolean read FShowBalances write SetShowBalances;
    property ShowGrossGST: boolean read FShowGrossGST write SetShowGrossGST;
    property ShowQuantity: boolean read FShowQuantity write SetShowQuantity;
    property ShowNotes: boolean read FShowNotes write SetShowNotes;
  end;

implementation

uses
  Globals, Software, repcols, LedgerRepDlg, BKDEFS, GenUtils,
  rptLedgerReport, bkdateutils, TransactionUtils, MoneyDef, GstCalc32;

{ TLedgerReportColumnList }

procedure TLedgerReportColumnList.AddBGLColumns;
begin
  //BGLSimpleFund & BGLSimpleLedger
  AddColumn(BKTX, tktxSF_Imputed_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);
  AddColumn(BKTX, tktxSF_CGT_Date, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP);
  AddColumn(BKTX, tktxSF_Tax_Free_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Exempt_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Deferred_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Member_Component,  0, jtLeft, ctFormat,
            '', '', DEFAULT_GAP);
  AddColumn(BKTX, tktxSF_TFN_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Tax_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Expenses,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Indexed,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Other,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
//		Units??
end;

procedure TLedgerReportColumnList.AddBGL360Columns;
begin
  AddColumn(BKTX, tktxSF_Imputed_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);
//  AddColumn(BKTX, tktxSF_CGT_Date, 0, jtLeft,
//            ctAuto, '', '', DEFAULT_GAP);

  AddColumn(BKTE, tkteSF_Cash_Date,  0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, false);
  AddColumn(BKTE, tkteSF_Accrual_Date,  0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, false);
  AddColumn(BKTE, tkteSF_Record_Date,  0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, false);
  AddColumn(BKTE, tkteSF_Contract_Date,  0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, false);
  AddColumn(BKTE, tkteSF_Settlement_Date,  0, jtRight, ctFormat,
            '', '', DEFAULT_GAP, false);

  AddColumn(BKTX, tktxSF_Tax_Free_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Exempt_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Deferred_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
//  AddColumn(BKTX, tktxSF_Member_Component,  0, jtLeft, ctFormat,
//            '', '', DEFAULT_GAP);
  AddColumn(BKTX, tktxSF_TFN_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Tax_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Expenses,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Indexed,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Other,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);

//BGL360 extended fields

  AddColumn(BKTX, tktxSF_Interest,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);

  AddColumn(BKTE, tkteSF_Other_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Other_Trust_Deductions,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_CGT_Concession_Amount,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_CGT_ForeignCGT_Before_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_CGT_ForeignCGT_Indexation,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_CGT_ForeignCGT_Other_Method,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);

  AddColumn(BKTX, tktxSF_Capital_Gains_Foreign_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);


  AddColumn(BKTE, tkteSF_CGT_TaxPaid_Indexation,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_CGT_TaxPaid_Other_Method,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Other_Net_Foreign_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Cash_Distribution,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_AU_Franking_Credits_NZ_Co,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Non_Res_Witholding_Tax,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_LIC_Deductions,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Non_Cash_CGT_Discounted_Before_Discount,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);



  AddColumn(BKTE, tkteSF_Non_Cash_CGT_Indexation,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Non_Cash_CGT_Other_Method,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Non_Cash_CGT_Capital_Losses,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Share_Brokerage,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTE, tkteSF_Share_Consideration,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);

  AddColumn(BKTE, tkteSF_Share_GST_Amount,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);

  AddColumn(BKTE, tkteSF_Share_GST_Rate, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, False, False);
(*  AddColumn(BKTE, tkteSF_Share_GST_Rate,  0, jtRight, ctAuto, '', '', ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, false); *)
//		Units??
end;

procedure TLedgerReportColumnList.AddDesktopSuperColumns;
begin
  //DesktopSuper
  AddColumn(BKTX, tktxSF_Imputed_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);
  AddColumn(BKTX, tktxSF_Transaction_Code, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, False);
  AddColumn(BKTX, tktxSF_Fund_Code, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, False);
  AddColumn(BKTX, tktxSF_Member_Account_Code, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP, False, False);
  AddColumn(BKTX, tktxSF_CGT_Date, 0, jtLeft,
            ctAuto, '', '', DEFAULT_GAP);
  AddColumn(BKTX, tktxSF_Special_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Expenses,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Other,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Indexed,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Deferred_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Free_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Exempt_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_TFN_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Capital_Gains_Credit, 0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Tax_Credit, 0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
end;

procedure TLedgerReportColumnList.AddMYOBSuperFundColumns;
begin
  //Solution6SuperFund & Supervisor
  AddColumn(BKTX, tktxSF_Imputed_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);
  AddColumn(BKTX, tktxSF_Member_ID,  0, jtRight, ctAuto,
            '', '', DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Interest,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Other,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Foreign_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Rent,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Indexed,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Capital_Gains_Disc,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Expenses,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Deferred_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Free_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Tax_Exempt_Dist,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Special_Income,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Tax_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Foreign_Capital_Gains_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_TFN_Credits,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Other_Tax_Credit,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
  AddColumn(BKTX, tktxSF_Non_Resident_Tax,  0, jtRight, ctFormat,
            NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True);
end;

procedure TLedgerReportColumnList.AutoCalcColumnWidths;
var
  i: integer;
//  ReportSettings: TLRParameters;
//  TempTravMgr: TTravManagerWithNewReport;
  TotalWidthPercent, FixedWidthPercent, VarWidthPercent, VarRatio, Ratio: double;
  ColumnItem: TReportColumnItem;
begin
  TotalWidthPercent := 0;
  FixedWidthPercent := 0;

  //Reset column widths
  for i := 0 to Pred(Count) do begin
    ColumnItem := Columns[i];
    ColumnItem.WidthPercent := 0;
  end;
  SetDefaultColWidths;

  for i := 0 to Pred(Count) do begin
    ColumnItem := Columns[i];
    if ColumnItem.OutputCol then begin
      //set widths based on field size
      if ColumnItem.WidthPercent = 0 then
        ColumnItem.WidthPercent := GetFieldSize(ColumnItem);
      if not CanClipColumn(ColumnItem) then
        FixedWidthPercent := FixedWidthPercent + ColumnItem.WidthPercent;
      TotalWidthPercent := TotalWidthPercent + ColumnItem.WidthPercent;
    end;
  end;

  if (FixedWidthPercent < 100) then begin
    VarWidthPercent := TotalWidthPercent - FixedWidthPercent;
    if (VarWidthPercent > 0) then begin
      //Scale variable 'AllowClipping' columns down
      VarRatio := ((100 - FixedWidthPercent) / VarWidthPercent);
      for i := 0 to Pred(Count) do begin
        ColumnItem := Columns[i];
        if (ColumnItem.OutputCol) and (CanClipColumn(ColumnItem)) then
          ColumnItem.WidthPercent := Round(VarRatio * ColumnItem.WidthPercent);
      end;
    end;
  end else begin
    //Scale all columns up or down
    Ratio := (100 / TotalWidthPercent);
    for i := 0 to Pred(Count) do begin
      ColumnItem := Columns[i];
      if ColumnItem.OutputCol then
        ColumnItem.WidthPercent := Abs(Ratio * ColumnItem.WidthPercent);
    end;
  end;
end;

function TLedgerReportColumnList.CanClipColumn(
  aColumnItem: TReportColumnItem): boolean;
begin
  Result := False;
end;

function TLedgerReportColumnList.CanWrapColumn(
  aColumnItem: TReportColumnItem): boolean;
begin
  Result := (aColumnItem.DataUnit = BKTX) and
            (aColumnItem.DataToken in [tktxNotes, tktxGL_Narration, tktxSF_Member_Component]);
end;

function TLedgerReportColumnList.CompatableSuperfund(
  AccountingSystem: byte): boolean;
begin
  Result := False;
  if (AccountingSystem = AccountingSystemUsed) then
    Result := True
  else begin
    case AccountingSystem of
      saBGLSimpleFund, saBGLSimpleLedger (*, saBGL360 *): Result := (AccountingSystemUsed in [saBGLSimpleFund, saBGLSimpleLedger, saBGL360]);
      saSolution6SuperFund, saSupervisor, saSuperMate: Result := (AccountingSystemUsed in [saSolution6SuperFund, saSupervisor, saSuperMate]);
    end;
  end;
end;

function TLedgerReportColumnList.GetColumnTitle(aDataUnit: string; aDataToken: integer): string;
begin
  //Common
//  if then
  Result := ''; 
  if ( aDataUnit = BKTX ) or ( aDataUnit = BKCH ) or ( aDataUnit = NO_DATA_UNIT ) then begin
    case aDataToken of
      tktxAccount              : Result := 'Account';
      tkchAccount_Description  : Result := 'Description';
      tktxDate_Effective       : Result := 'Date';
      tktxReference            : Result := 'Reference';
      tktxGL_Narration         : Result := 'Narration';
      tktxGST_Class            : Result := TaxName;
      tktxAmount               : Result := '$ Gross';
      tktxGST_Amount           : Result := '$ ' + TaxName;
      tktxQuantity             : Result := 'Quantity';
      tktxNotes                : Result := 'Notes';
      tktxSF_Franked           : Result := 'Franked';
      tktxSF_Unfranked         : Result := 'Unfranked';
      CALC_NET                 : Result := '$ Net';
      CALC_AVG_NET             : Result := 'Avg $ Net';
      tkchAlternative_Code     : Result := Software.AlternativeChartCodeName(Country,AccountingSystemUsed);
//    end;
    else
      case AccountingSystemUsed of
        saBGLSimpleFund, saBGLSimpleLedger: begin
          //BGL
          case aDataToken of
            tktxSF_Imputed_Credit        : Result := 'Imputed CR';
            tktxSF_CGT_Date              : Result := 'CGT Date';
            tktxSF_Tax_Free_Dist         : Result := 'Tax Free Dist';
            tktxSF_Tax_Exempt_Dist       : Result := 'Tax Exempt Dist';
            tktxSF_Tax_Deferred_Dist     : Result := 'Tax Deferred Dist';
            tktxSF_Member_Component      : Result := 'Member Component';
            tktxSF_TFN_Credits           : Result := 'TFN Credits';
            tktxSF_Foreign_Income        : Result := 'Foreign Income';
            tktxSF_Foreign_Tax_Credits   : Result := 'Foreign Tax CR';
            tktxSF_Other_Expenses        : Result := 'Other Expenses';
            tktxSF_Capital_Gains_Indexed : Result := 'CG Indexed';
            tktxSF_Capital_Gains_Disc    : Result := 'CG Discounted';
            tktxSF_Capital_Gains_Other   : Result := 'CG Other';
          end;
        end;
        saBGL360 : begin
           case aDataToken of
            tktxSF_Imputed_Credit        : Result := 'Franking CR';
  //          tktxSF_CGT_Date              : Result := 'CGT Date';
            tktxSF_Interest              : Result := 'Gross Interest';
            tktxSF_Capital_Gains_Foreign_Disc : Result := 'Tax Paid CR Before Disc';
            tktxSF_Tax_Free_Dist         : Result := 'Tax Free';
            tktxSF_Tax_Exempt_Dist       : Result := 'Tax Exempt';
            tktxSF_Tax_Deferred_Dist     : Result := 'Tax Deferred';
            tktxSF_TFN_Credits           : Result := 'TFN Withheld';
            tktxSF_Foreign_Income        : Result := 'Foreign Income';
            tktxSF_Foreign_Tax_Credits   : Result := 'Foreign Tax CR';
            tktxSF_Other_Expenses        : Result := 'Other Expenses';
            tktxSF_Capital_Gains_Indexed : Result := 'CG Indexed';
            tktxSF_Capital_Gains_Disc    : Result := 'CG Discounted';
            tktxSF_Capital_Gains_Other   : Result := 'CG Other';
          end;
        end;
        saDesktopSuper:
          //DesktopSuper
          case aDataToken of
            tktxSF_Imputed_Credit        : Result := 'Franking Credits';
            tktxSF_Transaction_Code      : Result := 'Tran Type';
            tktxSF_Fund_Code             : Result := 'Inv Code';
            tktxSF_Member_Account_Code   : Result := 'Member Account';
            tktxSF_CGT_Date              : Result := 'CGT/Tax Date';
            tktxSF_Special_Income        : Result := 'Undeducted Contrib';
            tktxSF_Foreign_Income        : Result := 'Foreign Income';
            tktxSF_Other_Expenses        : Result := 'Other Taxable';
            tktxSF_Capital_Gains_Other   : Result := 'CG Other';
            tktxSF_Capital_Gains_Disc    : Result := 'CG Disc';
            tktxSF_Capital_Gains_Indexed : Result := 'CG Conc';
            tktxSF_Tax_Deferred_Dist     : Result := 'Tax Deferred';
            tktxSF_Tax_Free_Dist         : Result := 'Tax Free Trust';
            tktxSF_Tax_Exempt_Dist       : Result := 'Non-Taxable';
            tktxSF_TFN_Credits           : Result := 'TFN Credit';
            tktxSF_Foreign_Capital_Gains_Credit : Result := 'Foreign Tax CR';
            tktxSF_Other_Tax_Credit      : Result := 'ABN Credit';
          end;
        saSolution6SuperFund, saSupervisor, saSuperMate:
          //Solution6SuperFund & Supervisor
          case aDataToken of
            tktxSF_Imputed_Credit        : Result := 'Imputation CR';
            tktxSF_Member_ID             : Result := 'Member ID';
            tktxSF_Interest              : Result := 'Interest';
            tktxSF_Foreign_Income        : Result := 'Foreign';
            tktxSF_Capital_Gains_Other   : Result := 'Foreign CG';
            tktxSF_Capital_Gains_Foreign_Disc : Result := 'Foreign Disc CG';
            tktxSF_Rent                  : Result := 'Rent';
            tktxSF_Capital_Gains_Indexed : Result := 'Capital Gain';
            tktxSF_Capital_Gains_Disc    : Result := 'Discount CG';
            tktxSF_Other_Expenses        : Result := 'Other Taxable';
            tktxSF_Tax_Deferred_Dist     : Result := 'Tax Deferred';
            tktxSF_Tax_Free_Dist         : Result := 'Tax Free Trust';
            tktxSF_Tax_Exempt_Dist       : Result := 'Non-Taxable';
            tktxSF_Special_Income        : Result := 'Special Income';
            tktxSF_Foreign_Tax_Credits   : Result := 'Foreign CR';
            tktxSF_Foreign_Capital_Gains_Credit : Result := 'Foreign CG CR';
            tktxSF_TFN_Credits           : Result := 'Withholding CR';
            tktxSF_Other_Tax_Credit      : Result := 'Other Tax CR';
            tktxSF_Non_Resident_Tax      : Result := 'Non-resident Tax';
          end;
      else
        Result := inherited GetColumnTitle(aDataUnit, aDataToken);
      end;
    end;  
  end
  else
    if ( aDataUnit = BKTE ) then begin
      case  AccountingSystemUsed of
        saBGL360 : begin
          //BGL360
          case aDataToken of
            tkteSF_Other_Income                            : Result := 'Other Income';
            tkteSF_Other_Trust_Deductions                  : Result := 'Trust Deductions';
            tkteSF_CGT_Concession_Amount                   : Result := 'CGT Concession';
            tkteSF_CGT_ForeignCGT_Before_Disc              : Result := 'Foreign CG Before Disc';
            tkteSF_CGT_ForeignCGT_Indexation               : Result := 'Foreign CG Indexed';
            tkteSF_CGT_ForeignCGT_Other_Method             : Result := 'Foreign CG Other';
            tkteSF_CGT_TaxPaid_Indexation                  : Result := 'Tax Paid CR Indexed';
            tkteSF_CGT_TaxPaid_Other_Method                : Result := 'Tax Paid CR Other';
            tkteSF_Other_Net_Foreign_Income                : Result := 'Other Net Foreign Income';
            tkteSF_Cash_Distribution                       : Result := 'Cash Distribution';
            tkteSF_AU_Franking_Credits_NZ_Co               : Result := 'AU Franking CR from NZ Co.';
            tkteSF_Non_Res_Witholding_Tax                  : Result := 'Non-Resident Tax';
            tkteSF_LIC_Deductions                          : Result := 'LIC Deduction';
            tkteSF_Non_Cash_CGT_Discounted_Before_Discount : Result := 'Non-Cash CG Before Disc';
            tkteSF_Non_Cash_CGT_Indexation                 : Result := 'Non-Cash CG Indexed';
            tkteSF_Non_Cash_CGT_Other_Method               : Result := 'Non-Cash CG Other';
            tkteSF_Non_Cash_CGT_Capital_Losses             : Result := 'Non-Cash Capital Losses';
            tkteSF_Share_Brokerage                         : Result := 'Brokerage';
            tkteSF_Share_Consideration                     : Result := 'Consideration';
            tkteSF_Share_GST_Amount                        : Result := 'GST Amount';
            tkteSF_Share_GST_Rate                          : Result := 'GST Rate';
            tkteSF_Cash_Date                               : Result := 'Cash Date';
            tkteSF_Accrual_Date                            : Result := 'Accrual Date';
            tkteSF_Record_Date                             : Result := 'Record Date';
            tkteSF_Contract_Date                           : Result := 'Contract Date';
            tkteSF_Settlement_Date                         : Result := 'Settlement Date';
          end;
        end;
      end;
    end;
end;

function TLedgerReportColumnList.GetFieldSize(
  aReportColumnItem: TReportColumnItem): double;
var
  Transaction_Rec: TTransaction_Rec;
  Transaction_Extension_Rec : tTransaction_Extension_Rec;
begin
  Result := 0;
  if (aReportColumnItem.DataUnit = BKTX) then begin
    case aReportColumnItem.DataToken of
      tktxSF_Imputed_Credit                : Result := AMOUNT_SIZE;
      tktxSF_Tax_Free_Dist                 : Result := AMOUNT_SIZE;
      tktxSF_Tax_Exempt_Dist               : Result := AMOUNT_SIZE;
      tktxSF_Tax_Deferred_Dist             : Result := AMOUNT_SIZE;
      tktxSF_TFN_Credits                   : Result := AMOUNT_SIZE;
      tktxSF_Foreign_Income                : Result := AMOUNT_SIZE;
      tktxSF_Foreign_Tax_Credits           : Result := AMOUNT_SIZE;
      tktxSF_Capital_Gains_Indexed         : Result := AMOUNT_SIZE;
      tktxSF_Capital_Gains_Disc            : Result := AMOUNT_SIZE;
      tktxSF_Capital_Gains_Other           : Result := AMOUNT_SIZE;
      tktxSF_Other_Expenses                : Result := AMOUNT_SIZE;
      tktxSF_CGT_Date                      : Result := DATE_SIZE;
      tktxSF_Franked                       : Result := AMOUNT_SIZE;
      tktxSF_UnFranked                     : Result := AMOUNT_SIZE;
      tktxSF_Interest                      : Result := AMOUNT_SIZE;
      tktxSF_Capital_Gains_Foreign_Disc    : Result := AMOUNT_SIZE;
      tktxSF_Rent                          : Result := AMOUNT_SIZE;
      tktxSF_Special_Income                : Result := AMOUNT_SIZE;
      tktxSF_Other_Tax_Credit              : Result := AMOUNT_SIZE;
      tktxSF_Non_Resident_Tax              : Result := AMOUNT_SIZE;
      tktxSF_Member_ID                     :
        Result := SizeOf(Transaction_Rec.txSF_Member_ID);
      tktxSF_Foreign_Capital_Gains_Credit  : Result := AMOUNT_SIZE;
      tktxSF_Member_Account_ID             : Result := INTEGER_SIZE;
      tktxSF_Transaction_ID                : Result := INTEGER_SIZE;
      tktxSF_Fund_ID                       : Result := INTEGER_SIZE;
      tktxSF_Member_Component              : Result := 12; //Can wrap
      tktxSF_Transaction_Code              : Result := 12;
      tktxSF_Fund_Code                     : Result := 12;
      tktxSF_Member_Account_Code           : Result := 12;
//        tktxSF_Capital_Gains_Fraction_Half   : Result := ;
    end;
  end;
  if (aReportColumnItem.DataUnit = BKTE) then begin
    case aReportColumnItem.DataToken of
      tkteSF_Other_Income                            : Result := Amount_Size;
      tkteSF_Other_Trust_Deductions                  : Result := Amount_Size;
      tkteSF_CGT_Concession_Amount                   : Result := Amount_Size;
      tkteSF_CGT_ForeignCGT_Before_Disc              : Result := Amount_Size;
      tkteSF_CGT_ForeignCGT_Indexation               : Result := Amount_Size;
      tkteSF_CGT_ForeignCGT_Other_Method             : Result := Amount_Size;
      tkteSF_CGT_TaxPaid_Indexation                  : Result := Amount_Size;
      tkteSF_CGT_TaxPaid_Other_Method                : Result := Amount_Size;
      tkteSF_Other_Net_Foreign_Income                : Result := Amount_Size;
      tkteSF_Cash_Distribution                       : Result := Amount_Size;
      tkteSF_AU_Franking_Credits_NZ_Co               : Result := Amount_Size;
      tkteSF_Non_Res_Witholding_Tax                  : Result := Amount_Size;
      tkteSF_LIC_Deductions                          : Result := Amount_Size;
      tkteSF_Non_Cash_CGT_Discounted_Before_Discount : Result := Amount_Size;
      tkteSF_Non_Cash_CGT_Indexation                 : Result := Amount_Size;
      tkteSF_Non_Cash_CGT_Other_Method               : Result := Amount_Size;
      tkteSF_Non_Cash_CGT_Capital_Losses             : Result := Amount_Size;
      tkteSF_Share_Brokerage                         : Result := Amount_Size;
      tkteSF_Share_GST_Amount                        : Result := Amount_Size;
      tkteSF_Share_GST_Rate                          :
        Result := sizeof( Transaction_Extension_Rec.teSF_Share_GST_Rate );
      tkteSF_Cash_Date                               : Result := DATE_SIZE;
      tkteSF_Accrual_Date                            : Result := DATE_SIZE;
      tkteSF_Record_Date                             : Result := DATE_SIZE;
      tkteSF_Contract_Date                           : Result := DATE_SIZE;
      tkteSF_Settlement_Date                         : Result := DATE_SIZE;
    end;
  end;
end;

function TLedgerReportColumnList.HasSuperFundColumns: boolean;
begin
  Result := False;
  if Assigned(FClient) then
    Result :=  CanUseSuperFundFields(Country, AccountingSystemUsed);
end;

procedure TLedgerReportColumnList.OutputContra(
  aReportColumnItem: TReportColumnItem);
begin
  if (aReportColumnItem.DataUnit = NO_DATA_UNIT) then begin
    case aReportColumnItem.DataToken of
      CALC_NET        : if IsBankContra then
                          FBkReport.PutMoney(TListLedgerTMgr(TravManager).AccountTotalGross)
                        else
                          FBkReport.PutMoney(TListLedgerTMgr(TravManager).AccountTotalNet);
      CALC_AVG_NET    : FBkReport.PutCurrency(0);
    else
      BKReport.SkipColumn;      
    end;
  end else if (aReportColumnItem.DataUnit = BKTX) then begin
    case aReportColumnItem.DataToken of
      tktxDate_Effective                   : BkReport.PutString('');
      tktxReference                        : BkReport.PutString('CONTRA');
      tktxGL_Narration                     : BkReport.PutString('MOVEMENT');
      tktxAmount                           : if IsBankContra then
                                               BkReport.PutMoney(TListLedgerTMgr(TravManager).AccountTotalGross)
                                             else
                                               BkReport.PutMoney(0);
      tktxNotes                            : BkReport.PutString('');
      tktxGST_Amount                       : if IsBankContra then
                                               BkReport.PutMoney(0)
                                             else
                                               BkReport.PutMoney(TListLedgerTMgr(TravManager).AccountTotalTax);
      tktxQuantity                         : BkReport.PutQuantity(0);
      tktxGST_Class                        : BkReport.PutString('');
    else
      BKReport.SkipColumn;
    end;
  end else
    BKReport.SkipColumn;
end;

procedure TLedgerReportColumnList.OutputColumn(
  aReportColumnItem: TReportColumnItem);
begin
  if IsSummarised then
    OutputSummarised(aReportColumnItem)
  else begin
    if IsBankContra or IsGSTContra then
      OutputContra(aReportColumnItem)
    else if IsDissection then
      OutputDissection(aReportColumnItem)
    else
      OutputTransaction(aReportColumnItem);
  end;
end;

procedure TLedgerReportColumnList.OutputDissection(
  aReportColumnItem: TReportColumnItem);
var
  Transaction_Rec: tTransaction_Rec;
  Dissection_Rec: tDissection_Rec;
  Account_Rec: pAccount_Rec;
  Avg: Currency;
  Net: Money;
  Qty: Money;
  MemberComponentText: string;
begin
  Transaction_Rec := tTransaction_Rec(TravManager.Transaction^);
  Dissection_Rec := tDissection_Rec(TravManager.Dissection^);
  //Calculations
  Net := (Dissection_Rec.dsAmount - Dissection_Rec.dsGST_Amount);
  Qty := 0;
  Avg := 0;
  if TListLedgerTMgr(TravManager).Quantities then begin
    Qty := Dissection_Rec.dsQuantity;
    Avg := calcAverage(Net/100, Qty/10000);
  end;

  if (aReportColumnItem.DataUnit = NO_DATA_UNIT) then begin
    case aReportColumnItem.DataToken of
      CALC_NET        : FBkReport.PutMoney(Net);
      CALC_AVG_NET    : FBkReport.PutCurrency(Avg);
    end;
  end
  else
    if (aReportColumnItem.DataUnit = BKTX) then begin
      case aReportColumnItem.DataToken of
        tktxAccount                          : FBkReport.PutString(Trim(Dissection_Rec.dsAccount));
        tktxReference                        :
          begin
            if Length(Dissection_Rec.dsReference) > 0 then
              BkReport.PutString(Dissection_Rec.dsReference)
            else
              BkReport.PutString(GetFormattedReference(TravManager.Transaction,
                                                       TravManager.Bank_Account.baFields.baAccount_Type));
          end;
        tktxGL_Narration                     : WrapColumn(aReportColumnItem,
                                                          GetNarration(TravManager.Dissection, TravManager.Bank_Account.baFields.baAccount_Type));
        tktxAmount                           : BkReport.PutMoney((Dissection_Rec.dsAmount));
        tktxDate_Effective                   :
          begin
            if TravManager.Bank_Account.IsAJournalAccount then
              FBkReport.PutString( bkDate2Str (Transaction_Rec.txDate_Effective ))
            else
              FBkReport.PutString( bkDate2Str (Transaction_Rec.txDate_Effective ) + ' [D]');
          end;
        tktxNotes                            : WrapColumn(aReportColumnItem, GetFullNotes(TravManager.Dissection));
        tktxGST_Amount                       : BkReport.PutMoney(Dissection_Rec.dsGST_Amount);
        tktxQuantity                         : BkReport.PutQuantity(Qty);
        tktxGST_Class                        : if Dissection_Rec.dsGST_Class = 0 then
                                                 BkReport.SkipColumn
                                               else
                                                 BkReport.PutString(GetGstClassCode(FClient, Dissection_Rec.dsGST_Class));

        //Super fields
        tktxSF_Imputed_Credit                : PutSuperMoney(Dissection_Rec.dsSF_Imputed_Credit);
        tktxSF_Tax_Free_Dist                 : PutSuperMoney(Dissection_Rec.dsSF_Tax_Free_Dist);
        tktxSF_Tax_Exempt_Dist               : PutSuperMoney(Dissection_Rec.dsSF_Tax_Exempt_Dist);
        tktxSF_Tax_Deferred_Dist             : PutSuperMoney(Dissection_Rec.dsSF_Tax_Deferred_Dist);
        tktxSF_TFN_Credits                   : PutSuperMoney(Dissection_Rec.dsSF_TFN_Credits);
        tktxSF_Foreign_Income                : PutSuperMoney(Dissection_Rec.dsSF_Foreign_Income);
        tktxSF_Foreign_Tax_Credits           : PutSuperMoney(Dissection_Rec.dsSF_Foreign_Tax_Credits);
        tktxSF_Capital_Gains_Indexed         : PutSuperMoney(Dissection_Rec.dsSF_Capital_Gains_Indexed);
        tktxSF_Capital_Gains_Disc            : PutSuperMoney(Dissection_Rec.dsSF_Capital_Gains_Disc);
        tktxSF_Capital_Gains_Other           : PutSuperMoney(Dissection_Rec.dsSF_Capital_Gains_Other);
        tktxSF_Other_Expenses                : PutSuperMoney(Dissection_Rec.dsSF_Other_Expenses);
        tktxSF_CGT_Date                      : FBkReport.PutString(bkDate2Str(Dissection_Rec.dsSF_CGT_Date));
        tktxSF_Franked                       : PutSuperMoney(Dissection_Rec.dsSF_Franked);
        tktxSF_UnFranked                     : PutSuperMoney(Dissection_Rec.dsSF_UnFranked);
        tktxSF_Interest                      : PutSuperMoney(Dissection_Rec.dsSF_Interest);
        tktxSF_Capital_Gains_Foreign_Disc    : PutSuperMoney(Dissection_Rec.dsSF_Capital_Gains_Foreign_Disc);
        tktxSF_Rent                          : PutSuperMoney(Dissection_Rec.dsSF_Rent);
        tktxSF_Special_Income                : PutSuperMoney(Dissection_Rec.dsSF_Special_Income);
        tktxSF_Other_Tax_Credit              : PutSuperMoney(Dissection_Rec.dsSF_Other_Tax_Credit);
        tktxSF_Non_Resident_Tax              : PutSuperMoney(Dissection_Rec.dsSF_Non_Resident_Tax);
        tktxSF_Member_ID                     : BkReport.PutString(Dissection_Rec.dsSF_Member_ID);
        tktxSF_Foreign_Capital_Gains_Credit  : PutSuperMoney(Dissection_Rec.dsSF_Foreign_Capital_Gains_Credit);
        tktxSF_Member_Component              :
          begin
            MemberComponentText := '';
            if (Dissection_Rec.dsSF_Member_Component > 0) then begin
              if (Transaction_Rec.txDate_Effective = 0) or (Transaction_Rec.txDate_Effective >= mcSwitchDate) then
                MemberComponentText := mcNewNames[Dissection_Rec.dsSF_Member_Component]
              else
                MemberComponentText := mcOldNames[Dissection_Rec.dsSF_Member_Component]
            end;
            WrapColumn(aReportColumnItem, MemberComponentText);
          end;
        tktxSF_Fund_ID                       : BkReport.PutString(IntToStr(Dissection_Rec.dsSF_Fund_ID));
        tktxSF_Member_Account_ID             : BkReport.PutString(IntToStr(Dissection_Rec.dsSF_Member_Account_ID));
        tktxSF_Fund_Code                     : BkReport.PutString(Dissection_Rec.dsSF_Fund_Code);
        tktxSF_Member_Account_Code           : BkReport.PutString(Dissection_Rec.dsSF_Member_Account_Code);
        tktxSF_Transaction_ID                : BkReport.PutString(IntToStr(Dissection_Rec.dsSF_Transaction_ID));
        tktxSF_Transaction_Code              : BkReport.PutString(Dissection_Rec.dsSF_Transaction_Code);
  //        tktxSF_Capital_Gains_Fraction_Half   : Result := ;
      else
        FBkReport.PutString(MISSINGFIELD);
      end;
    end
    else
      if (aReportColumnItem.DataUnit = BKCH) then begin
        Account_Rec := MyClient.clChart.FindCode(TravManager.Dissection^.dsAccount);
        if Assigned(Account_Rec) then
          case aReportColumnItem.DataToken of
            tkchAccount_Description   : FBkReport.PutString(Trim(Account_Rec.chAccount_Description));
          else
            FBkReport.PutString('');
          end
        else
          FBkReport.PutString('');
      end
      else
        if (aReportColumnItem.DataUnit = BKTE) then begin // Transaction Extension Record
          case aReportColumnItem.DataToken of
            tkteSF_Other_Income                            :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Other_Income);
            tkteSF_Other_Trust_Deductions                  :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Other_Trust_Deductions);
            tkteSF_CGT_Concession_Amount                   :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_Concession_Amount);
            tkteSF_CGT_ForeignCGT_Before_Disc              :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Before_Disc);
            tkteSF_CGT_ForeignCGT_Indexation               :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Indexation);
            tkteSF_CGT_ForeignCGT_Other_Method             :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Other_Method);
            tkteSF_CGT_TaxPaid_Indexation                  :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_TaxPaid_Indexation);
            tkteSF_CGT_TaxPaid_Other_Method                :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_CGT_TaxPaid_Other_Method);
            tkteSF_Other_Net_Foreign_Income                :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Other_Net_Foreign_Income);
            tkteSF_Cash_Distribution                       :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Cash_Distribution);
            tkteSF_AU_Franking_Credits_NZ_Co               :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_AU_Franking_Credits_NZ_Co);
            tkteSF_Non_Res_Witholding_Tax                  :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Non_Res_Witholding_Tax);
            tkteSF_LIC_Deductions                          :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_LIC_Deductions);
            tkteSF_Non_Cash_CGT_Discounted_Before_Discount :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Non_Cash_CGT_Discounted_Before_Discount);
            tkteSF_Non_Cash_CGT_Indexation                 :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Non_Cash_CGT_Indexation);
            tkteSF_Non_Cash_CGT_Other_Method               :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Non_Cash_CGT_Other_Method);
            tkteSF_Non_Cash_CGT_Capital_Losses             :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Non_Cash_CGT_Capital_Losses);
            tkteSF_Share_Brokerage                         :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Share_Brokerage);
            tkteSF_Share_Consideration                        :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Share_Consideration);
            tkteSF_Share_GST_Amount                        :
              PutSuperMoney(Dissection_Rec.dsDissection_Extension^.deSF_Share_GST_Amount);
            tkteSF_Share_GST_Rate                          :
              FBkReport.PutString(Dissection_Rec.dsDissection_Extension^.deSF_Share_GST_Rate);
            tkteSF_Cash_Date                               :
              FBkReport.PutString(bkDate2Str(
                Dissection_Rec.dsDissection_Extension^.deSF_Cash_Date ) );
            tkteSF_Accrual_Date                            :
              FBkReport.PutString(bkDate2Str(
                Dissection_Rec.dsDissection_Extension^.deSF_Accrual_Date ) );
            tkteSF_Record_Date                             :
              FBkReport.PutString(bkDate2Str(
                Dissection_Rec.dsDissection_Extension^.deSF_Record_Date ) );
            tkteSF_Contract_Date                             :
              FBkReport.PutString(bkDate2Str(
                Dissection_Rec.dsDissection_Extension^.deSF_Contract_Date ) );
            tkteSF_Settlement_Date                             :
              FBkReport.PutString(bkDate2Str(
                Dissection_Rec.dsDissection_Extension^.deSF_Settlement_Date ) );
          end;
        end
        else
          FBkReport.PutString(MISSINGFIELD);
end;

procedure TLedgerReportColumnList.OutputSummarised(
  aReportColumnItem: TReportColumnItem);
var
  Account_Rec: pAccount_Rec;
  TravMgr: TListLedgerTMgr;
  Avg: Currency;
begin
  TravMgr := TListLedgerTMgr(TravManager);

  Avg := CalcAverage(TravMgr.AccountTotalNet/100, TravMgr.AccountTotalQuantity/10000);

  if (aReportColumnItem.DataUnit = NO_DATA_UNIT) then begin
    case aReportColumnItem.DataToken of
      CALC_NET        : FBkReport.PutMoney(TListLedgerTMgr(TravManager).AccountTotalNet);
      CALC_AVG_NET    : FBkReport.PutCurrency(Avg);
    end;
  end
  else
    if (aReportColumnItem.DataUnit = BKTX) then begin  // Transaction Record
      case aReportColumnItem.DataToken of
        tktxAccount                          : if Code <> '' then
                                                 BkReport.PutString(Code)
                                               else
                                                 BkReport.PutString('Uncoded');
        tktxAmount                           : BkReport.PutMoney(TravMgr.AccountTotalGross);
        tktxGST_Amount                       : BkReport.PutMoney(TravMgr.AccountTotalTax);
        tktxQuantity                         : BkReport.PutQuantity(TravMgr.AccountTotalQuantity);

        //Super
        tktxSF_Imputed_Credit                : PutSuperMoney(TravMgr.SuperTotalImputed_Credit);
        tktxSF_Tax_Free_Dist                 : PutSuperMoney(TravMgr.SuperTotalTax_Free_Dist);
        tktxSF_Tax_Exempt_Dist               : PutSuperMoney(TravMgr.SuperTotalTax_Exempt_Dist);
        tktxSF_Tax_Deferred_Dist             : PutSuperMoney(TravMgr.SuperTotalTax_Deferred_Dist);
        tktxSF_TFN_Credits                   : PutSuperMoney(TravMgr.SuperTotalTFN_Credits);
        tktxSF_Foreign_Income                : PutSuperMoney(TravMgr.SuperTotalForeign_Income);
        tktxSF_Foreign_Tax_Credits           : PutSuperMoney(TravMgr.SuperTotalForeign_Tax_Credits);
        tktxSF_Capital_Gains_Indexed         : PutSuperMoney(TravMgr.SuperTotalCapital_Gains_Indexed);
        tktxSF_Capital_Gains_Disc            : PutSuperMoney(TravMgr.SuperTotalCapital_Gains_Disc);
        tktxSF_Capital_Gains_Other           : PutSuperMoney(TravMgr.SuperTotalCapital_Gains_Other);
        tktxSF_Other_Expenses                : PutSuperMoney(TravMgr.SuperTotalOther_Expenses);
        tktxSF_Franked                       : PutSuperMoney(TravMgr.SuperTotalFranked);
        tktxSF_UnFranked                     : PutSuperMoney(TravMgr.SuperTotalUnFranked);
        tktxSF_Interest                      : PutSuperMoney(TravMgr.SuperTotalInterest);
        tktxSF_Capital_Gains_Foreign_Disc    : PutSuperMoney(TravMgr.SuperTotalCapital_Gains_Foreign_Disc);
        tktxSF_Rent                          : PutSuperMoney(TravMgr.SuperTotalRent);
        tktxSF_Special_Income                : PutSuperMoney(TravMgr.SuperTotalSpecial_Income);
        tktxSF_Other_Tax_Credit              : PutSuperMoney(TravMgr.SuperTotalOther_Tax_Credit);
        tktxSF_Non_Resident_Tax              : PutSuperMoney(TravMgr.SuperTotalNon_Resident_Tax);
        tktxSF_Foreign_Capital_Gains_Credit  : PutSuperMoney(TravMgr.SuperTotalForeign_Capital_Gains_Credit);
  //        tktxSF_Capital_Gains_Fraction_Half   : Result := ;

        //Non amount columns
        tktxSF_CGT_Date                      : BkReport.SkipColumn;
        tktxSF_Fund_Code                     : BkReport.SkipColumn;
        tktxSF_Fund_ID                       : BkReport.SkipColumn;
        tktxSF_Member_Account_Code           : BkReport.SkipColumn;
        tktxSF_Member_Account_ID             : BkReport.SkipColumn;
        tktxSF_Member_Component              : BkReport.SkipColumn;
        tktxSF_Member_ID                     : BkReport.SkipColumn;
        tktxSF_Transaction_Code              : BkReport.SkipColumn;
        tktxSF_Transaction_ID                : BkReport.SkipColumn;
      end;
    end
    else
      if (aReportColumnItem.DataUnit = BKCH) then begin
        case aReportColumnItem.DataToken of
           tkchAccount_Description : begin
              if Code = '' then
                 BKReport.PutString( 'Uncoded')
              else begin
                 if FShowBalances then
                    BkReport.PutString('MOVEMENT')
                 else begin
                    Account_Rec := MyClient.clChart.FindCode(Code);
                    if Assigned(Account_Rec) then
                       BkReport.PutString(Trim(Account_Rec.chAccount_Description))
                    else
                       BkReport.PutString('INVALID CODE');
                 end;
              end;
           end;
           tkchAlternative_Code : begin
               Account_Rec := MyClient.clChart.FindCode(Code);
               if Assigned(Account_Rec) then
                  BkReport.PutString(Trim(Account_Rec.chAlternative_code ))
               else
                  BkReport.PutString('')
           end;
        end;
      end
      else
        FBkReport.PutString('');
end;

procedure TLedgerReportColumnList.OutputTransaction(
  aReportColumnItem: TReportColumnItem);
var
  Transaction_Rec: tTransaction_Rec;
  Account_Rec: pAccount_Rec;
  Avg: Currency;
  Net: Money;
  Qty: Money;
  MemberComponentText: string;
begin
  Transaction_Rec := tTransaction_Rec(TravManager.Transaction^);
  Net := (Transaction_Rec.txAmount - Transaction_Rec.txGST_Amount);
  Qty := 0;
  Avg := 0;
  if TListLedgerTMgr(TravManager).Quantities then begin
    Qty := Transaction_Rec.txQuantity;
    Avg := calcAverage(Net/100, Qty/10000);
  end;

  if (aReportColumnItem.DataUnit = NO_DATA_UNIT) then begin
    case aReportColumnItem.DataToken of
      CALC_NET        : FBkReport.PutMoney(Net);
      CALC_AVG_NET    : FBkReport.PutCurrency(Avg);
    end;
  end
  else
    if (aReportColumnItem.DataUnit = BKTX) then begin
      case aReportColumnItem.DataToken of
        tktxAccount                          : FBkReport.PutString(Trim(Transaction_Rec.txAccount));
        tktxDate_Effective                   : FBkReport.PutString(bkDate2Str(Transaction_Rec.txDate_Effective));
        tktxReference                        : FBkReport.PutString(GetFormattedReference(TravManager.Transaction,
                                                                     TravManager.Bank_Account.baFields.baAccount_Type));
        tktxGL_Narration                     : WrapColumn(aReportColumnItem, Transaction_Rec.txGL_Narration);
        tktxAmount                           : BkReport.PutMoney((Transaction_Rec.txAmount));
        tktxNotes                            : WrapColumn(aReportColumnItem, GetFullNotes(TravManager.Transaction));
        tktxGST_Amount                       : BkReport.PutMoney(Transaction_Rec.txGST_Amount);
        tktxQuantity                         : BkReport.PutQuantity(Qty);
        tktxGST_Class                        : if Transaction_Rec.txGST_Class = 0 then
                                                 BkReport.SkipColumn
                                               else
                                                 BkReport.PutString(GetGstClassCode(FClient, Transaction_Rec.txGST_Class));

        //Super fields
        tktxSF_Imputed_Credit                : PutSuperMoney(Transaction_Rec.txSF_Imputed_Credit);
        tktxSF_Tax_Free_Dist                 : PutSuperMoney(Transaction_Rec.txSF_Tax_Free_Dist);
        tktxSF_Tax_Exempt_Dist               : PutSuperMoney(Transaction_Rec.txSF_Tax_Exempt_Dist);
        tktxSF_Tax_Deferred_Dist             : PutSuperMoney(Transaction_Rec.txSF_Tax_Deferred_Dist);
        tktxSF_TFN_Credits                   : PutSuperMoney(Transaction_Rec.txSF_TFN_Credits);
        tktxSF_Foreign_Income                : PutSuperMoney(Transaction_Rec.txSF_Foreign_Income);
        tktxSF_Foreign_Tax_Credits           : PutSuperMoney(Transaction_Rec.txSF_Foreign_Tax_Credits);
        tktxSF_Capital_Gains_Indexed         : PutSuperMoney(Transaction_Rec.txSF_Capital_Gains_Indexed);
        tktxSF_Capital_Gains_Disc            : PutSuperMoney(Transaction_Rec.txSF_Capital_Gains_Disc);
        tktxSF_Capital_Gains_Other           : PutSuperMoney(Transaction_Rec.txSF_Capital_Gains_Other);
        tktxSF_Other_Expenses                : PutSuperMoney(Transaction_Rec.txSF_Other_Expenses);
        tktxSF_CGT_Date                      : FBkReport.PutString(bkDate2Str(Transaction_Rec.txSF_CGT_Date));
        tktxSF_Franked                       : PutSuperMoney(Transaction_Rec.txSF_Franked);
        tktxSF_UnFranked                     : PutSuperMoney(Transaction_Rec.txSF_UnFranked);
        tktxSF_Interest                      : PutSuperMoney(Transaction_Rec.txSF_Interest);
        tktxSF_Capital_Gains_Foreign_Disc    : PutSuperMoney(Transaction_Rec.txSF_Capital_Gains_Foreign_Disc);
        tktxSF_Rent                          : PutSuperMoney(Transaction_Rec.txSF_Rent);
        tktxSF_Special_Income                : PutSuperMoney(Transaction_Rec.txSF_Special_Income);
        tktxSF_Other_Tax_Credit              : PutSuperMoney(Transaction_Rec.txSF_Other_Tax_Credit);
        tktxSF_Non_Resident_Tax              : PutSuperMoney(Transaction_Rec.txSF_Non_Resident_Tax);
        tktxSF_Member_ID                     : BkReport.PutString(Transaction_Rec.txSF_Member_ID);
        tktxSF_Foreign_Capital_Gains_Credit  : PutSuperMoney(Transaction_Rec.txSF_Foreign_Capital_Gains_Credit);
        tktxSF_Member_Component              :
          begin
            MemberComponentText := '';
            if (Transaction_Rec.txSF_Member_Component > 0)  then begin
              if (Transaction_Rec.txDate_Effective = 0) or (Transaction_Rec.txDate_Effective >= mcSwitchDate) then
                MemberComponentText := mcNewNames[Transaction_Rec.txSF_Member_Component]
              else
                MemberComponentText := mcOldNames[Transaction_Rec.txSF_Member_Component]
            end;
            WrapColumn(aReportColumnItem, MemberComponentText);
          end;
        tktxSF_Fund_ID                       : BkReport.PutString(IntToStr(Transaction_Rec.txSF_Fund_ID));
        tktxSF_Member_Account_ID             : BkReport.PutString(IntToStr(Transaction_Rec.txSF_Member_Account_ID));
        tktxSF_Fund_Code                     : BkReport.PutString(Transaction_Rec.txSF_Fund_Code);
        tktxSF_Member_Account_Code           : BkReport.PutString(Transaction_Rec.txSF_Member_Account_Code);
        tktxSF_Transaction_ID                : BkReport.PutString(IntToStr(Transaction_Rec.txSF_Transaction_ID));
        tktxSF_Transaction_Code              : BkReport.PutString(Transaction_Rec.txSF_Transaction_Code);
  //        tktxSF_Capital_Gains_Fraction_Half   : Result := ;
      else
        FBkReport.PutString(MISSINGFIELD);
      end;
    end
    else
      if (aReportColumnItem.DataUnit = BKCH) then begin
        Account_Rec := MyClient.clChart.FindCode(TravManager.Transaction^.txAccount);
        if Assigned(Account_Rec) then
          case aReportColumnItem.DataToken of
            tkchAccount_Description : FBkReport.PutString(Trim(Account_Rec.chAccount_Description));
            tkchAlternative_Code    : FBkReport.PutString(Trim(Account_Rec.chAlternative_Code));
          else
            FBkReport.PutString('');
          end
        else
          FBkReport.PutString('');
      end
      else
        if (aReportColumnItem.DataUnit = BKTE) then begin // Transaction Extension Record
          case aReportColumnItem.DataToken of
            tkteSF_Other_Income                            :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Other_Income);
                  tkteSF_Other_Trust_Deductions                  :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Other_Trust_Deductions);
            tkteSF_CGT_Concession_Amount                   :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_Concession_Amount);
            tkteSF_CGT_ForeignCGT_Before_Disc              :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Before_Disc);
            tkteSF_CGT_ForeignCGT_Indexation               :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Indexation);
            tkteSF_CGT_ForeignCGT_Other_Method             :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Other_Method);
            tkteSF_CGT_TaxPaid_Indexation                  :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_TaxPaid_Indexation);
            tkteSF_CGT_TaxPaid_Other_Method                :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_CGT_TaxPaid_Other_Method);
            tkteSF_Other_Net_Foreign_Income                :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Other_Net_Foreign_Income);
            tkteSF_Cash_Distribution                       :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Cash_Distribution);
            tkteSF_AU_Franking_Credits_NZ_Co               :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_AU_Franking_Credits_NZ_Co);
            tkteSF_Non_Res_Witholding_Tax                  :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax);
            tkteSF_LIC_Deductions                          :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_LIC_Deductions);
            tkteSF_Non_Cash_CGT_Discounted_Before_Discount :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Non_Cash_CGT_Discounted_Before_Discount);
            tkteSF_Non_Cash_CGT_Indexation                 :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Non_Cash_CGT_Indexation);
            tkteSF_Non_Cash_CGT_Other_Method               :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Non_Cash_CGT_Other_Method);
            tkteSF_Non_Cash_CGT_Capital_Losses             :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Non_Cash_CGT_Capital_Losses);
            tkteSF_Share_Brokerage                         :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Share_Brokerage);
            tkteSF_Share_Consideration                        :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Share_Consideration);
            tkteSF_Share_GST_Amount                        :
              PutSuperMoney(Transaction_Rec.txTransaction_Extension^.teSF_Share_GST_Amount);
            tkteSF_Share_GST_Rate                          :
              FBkReport.PutString(Transaction_Rec.txTransaction_Extension^.teSF_Share_GST_Rate);
            tkteSF_Cash_Date                               :
              FBkReport.PutString(bkDate2Str(
                Transaction_Rec.txTransaction_Extension^.teSF_Cash_Date ) );
            tkteSF_Accrual_Date                            :
              FBkReport.PutString(bkDate2Str(
                Transaction_Rec.txTransaction_Extension^.teSF_Accrual_Date ) );
            tkteSF_Record_Date                             :
              FBkReport.PutString(bkDate2Str(
                Transaction_Rec.txTransaction_Extension^.teSF_Record_Date ) );
            tkteSF_Contract_Date                             :
              FBkReport.PutString(bkDate2Str(
                Transaction_Rec.txTransaction_Extension^.teSF_Contract_Date ) );
            tkteSF_Settlement_Date                             :
              FBkReport.PutString(bkDate2Str(
                Transaction_Rec.txTransaction_Extension^.teSF_Settlement_Date ) );
          end;
        end
        else
          FBkReport.PutString(MISSINGFIELD);
end;

procedure TLedgerReportColumnList.PutSuperMoney(aAmount: comp);
begin
  if aAmount <> 0 then
    BKReport.PutMoney(aAmount)
  else
    BKReport.SkipColumn;
end;

procedure TLedgerReportColumnList.SetDefaultColWidths;
var
  i: integer;
  ColumnItem: TReportColumnItem;
begin
  for i := 0 to Count - 1 do begin
    ColumnItem := Columns[i];
    if ColumnItem.OutputCol then
      case ColumnItem.DataToken of
        tktxAccount,
        tkchAlternative_Code     : ColumnItem.WidthPercent := 8.0;
        tkchAccount_Description  : ColumnItem.WidthPercent := 28.0;
        tktxDate_Effective       : ColumnItem.WidthPercent := 10.0;
        tktxReference            : ColumnItem.WidthPercent := 10.0;
        tktxGL_Narration         : ColumnItem.WidthPercent := 28.0;
        tktxGST_Class            : ColumnItem.WidthPercent := 5.0;
        tktxAmount               : ColumnItem.WidthPercent := 12.0;
        tktxGST_Amount           : ColumnItem.WidthPercent := 12.0;
        CALC_NET                 : ColumnItem.WidthPercent := 12.0;
        tktxQuantity             : ColumnItem.WidthPercent := 10.0;
        CALC_AVG_NET             : ColumnItem.WidthPercent := 12.0;
        tktxNotes                : ColumnItem.WidthPercent := 28.0;
      end;
  end;
end;

procedure TLedgerReportColumnList.SaveReportSettings;
var
  LedgerReport: TListLedgerReport;
  LedgerReportSettings: TLRParameters;
begin
  FReportSettings := nil;
  LedgerReportSettings := nil;
  if Assigned(FBKReport) then begin
    //Needs to allow for the two versions of the Coding Report
    if FBKReport is TListLedgerReport then begin
      LedgerReport := TListLedgerReport(FBKReport);
      LedgerReportSettings := TLRParameters(LedgerReport.Params);
    end;

    //Save required settings
    if Assigned(LedgerReportSettings) then begin
      //Include accounts with no movement

      //Details/Summarized
      //Show opening/closing balances
      //Include non-transfering journals

      //Gross & GST Amounts
      //Quantities
      //Notes
      //Wrap (FWrapColumns)
      //Bank Contras
      //GST Control Accounts
    end;
  end;
end;

procedure TLedgerReportColumnList.SetCode(const Value: BK5CodeStr);
begin
  FCode := Value;
end;

procedure TLedgerReportColumnList.SetIsBankContra(const Value: boolean);
begin
  FIsBankContra := Value;
end;

procedure TLedgerReportColumnList.SetIsDissection(const Value: boolean);
begin
  FIsDissection := Value;
end;

procedure TLedgerReportColumnList.SetIsGSTContra(const Value: boolean);
begin
  FIsGSTContra := Value;
end;

procedure TLedgerReportColumnList.SetIsSummarised(const Value: boolean);
begin
  FIsSummarised := Value;
end;

procedure TLedgerReportColumnList.SetShowBalances(const Value: boolean);
begin
  FShowBalances := Value;
end;

procedure TLedgerReportColumnList.SetShowGrossGST(const Value: boolean);
begin
  FShowGrossGST := Value;
end;

procedure TLedgerReportColumnList.SetShowNotes(const Value: boolean);
begin
  FShowNotes := Value;
end;

procedure TLedgerReportColumnList.SetShowQuantity(const Value: boolean);
begin
  FShowQuantity := Value;
end;

procedure TLedgerReportColumnList.SetupColumns;
begin
  Country := FClient.clFields.clCountry;
  AccountingSystemUsed := FClient.clFields.clAccounting_System_Used;

  FIsSuperFund := HasSuperFundColumns;
  if FIsSuperFund then begin
    FIsDefault := True;
    FOrientation := 1;
    FIsSummarised := False;

    ClearColumnList;

    //Add all columns currently available in the custom ledger report
    //and set output depending on the ledger dialog settings
    AddColumn(BKTX, tktxAccount, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);
    AddColumn(BKCH, tkchAccount_Description, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);
    AddColumn(BKTX, tktxDate_Effective, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);
    AddColumn(BKTX, tktxReference, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);
    AddColumn(BKTX, tktxGL_Narration, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);

    if Software.HasAlternativeChartCode(Country,AccountingSystemUsed) then
        AddColumn(BKCH, tkchAlternative_Code, 0, jtLeft,
                        ctAuto, '', '', DEFAULT_GAP, False, False, true);
    //Gross & GST
    AddColumn(BKTX, tktxGST_Class, 0, jtRight, ctFormat,
              INTEGER_FORMAT, INTEGER_FORMAT, DEFAULT_GAP, False , False, True);
    AddColumn(BKTX, tktxAmount, 0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , False, True);
    AddColumn(BKTX, tktxGST_Amount, 0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , False, True);
    //Net amount
    AddColumn(NO_DATA_UNIT, CALC_NET, 0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , True, True);
    //Quantity
    AddColumn(BKTX, tktxQuantity, 0, jtRight, ctFormat,
              QUANTITY_FORMAT, QUANTITY_FORMAT, DEFAULT_GAP, True, True, True);
    AddColumn(NO_DATA_UNIT, CALC_AVG_NET, 0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True , False, True);
    //Notes
    AddColumn(BKTX, tktxNotes, 0, jtLeft,
              ctAuto, '', '', DEFAULT_GAP, False, False, True);

    SetDefaultColWidths;

    //Common superfund columns
    AddColumn(BKTX, tktxSF_Franked,  0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);
    AddColumn(BKTX, tktxSF_Unfranked,  0, jtRight, ctFormat,
              NUMBER_FORMAT, DOLLAR_FORMAT, DEFAULT_GAP, True, True);

    //Superfund specific columns
    case AccountingSystemUsed of
      saBGLSimpleFund,
      saBGLSimpleLedger : AddBGLColumns;
      saBGL360: AddBGL360Columns;
      saDesktopSuper: AddDesktopSuperColumns;
      saSolution6SuperFund, saSupervisor, saSuperMate: AddMYOBSuperFundColumns;
      //These superfunds currently don't have any additional fields in Practice
      //saIRESSXplan: AddIRESSXplanColumns;
      //saPraemium: AddPraemiumColumns;
      //saClassSuperIP: AddSuperIPColumns;
    end;
  end;
end;

procedure TLedgerReportColumnList.UpdateColumns;
var
  i: integer;
begin
  FIsSuperFund := HasSuperFundColumns;
  if FIsSuperFund then begin
    for i := 0 to Count - 1 do begin
      if Columns[i].DataUnit = BKTX then
        case Columns[i].DataToken of
          //Summarised
          tktxAccount: if FShowBalances then
                         OutputCol(i, False)
                       else
                         OutputCol(i, FIsSummarised);
          tkchAccount_Description : OutputCol(i, FIsSummarised);
          tkchAlternative_Code    : begin
                 OutputCol(i, FIsSummarised);
                 EnableCol(i, FisSummarised);
             end;
          //Detailed
          tktxDate_Effective,
          tktxReference,
          tktxGL_Narration : OutputCol(i, (not FIsSummarised));
          //Show Gross & GST
          tktxGST_Class: OutputCol(i, (FShowGrossGst and not FIsSummarised));
          tktxAmount,
          tktxGST_Amount   : OutputCol(i, FShowGrossGst);

          //Show quantity
          tktxQuantity,
          CALC_AVG_NET     : OutputCol(i, FShowQuantity);
          //Show notes
          tktxNotes        : OutputCol(i, FShowNotes);
        end
      else;
    end;
  end;
end;

end.
