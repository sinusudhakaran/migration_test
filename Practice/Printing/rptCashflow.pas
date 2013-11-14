unit RptCashflow;
//------------------------------------------------------------------------------
{
   Title:       Cash flow Reports

   Description:

   Author:      Matthew Hopkins Jul 2002 - Major rewrite

   Remarks:     All of the DoCashflow... routines now call DoCashflowEX.  The
                old procedures have been left behind to provide back compatibility
}
//------------------------------------------------------------------------------


interface

uses
  ReportDefs, clObj32, UbatchBase;

procedure DoCashflow12ActualBudgetReport(Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflow12ActualReport      (Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflowActualBudgetReport  (Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflowActualBudgetVarianceReport(Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflowActualReport        (Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflowActualLastYearVariance( Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashFlowBudgetRem           (Destination : TReportDest;
                                         RptBatch : TReportBase = nil);

procedure DoCashflowDate                (Destination : TReportDest;
                                         RptBatch : TReportBase = nil);
procedure DoCashflowExport;

procedure DoCashflowEx                  (Destination : TReportDest;
                                         aReportType: Integer;
                                         RptBatch : TReportBase = nil);

function  GetCFHeading(ClientForReport : TClientObj; No : Integer): string;

//******************************************************************************
implementation

uses
  ReportTypes,
  Controls,
  Graphics,
  AccountInfoObj,
  baObj32,
  bkconst,
  bkhelp,
  bkDateUtils,
  bkdefs,
  BudgetLookup,
  BudObj32,
  CalculateAccountTotals,
  cashflowDateRepDlg,
  cashflowRepDlg,
  cfHead,
  CheckBoxOptionsDlg,
  chList32,
  Forms,
  glConst,
  globals,
  InfoMoreFrm,
  Math,
  MoneyDef,
  NewReportObj,
  NewReportUtils,
  OfficeDM, OpExcel,
  repcols,
  ReportCashflowBase,
  SignUtils,
  stDate,
  stDateSt,
  SysUtils, ECollect, BaList32, trxList32,
  RptParams,
  CountryUtils,
  baUtils,
  Classes, PeriodUtils, GenUtils,
  ExchangeGainLoss,
  DateUtils,
  ISO_4217,
  glObj32;


{$IFDEF SmartBooks}
    !! The SmartBooks specific code has been removed
{$ENDIF}

const
   UnitName = 'RPTCASHFLOW';

type
  TBaseAmounts = record
    OpeningBalance: array of TValuesArray;
    Movement: array of TValuesArray;
    ClosingBalance: array of TValuesArray;
    ForexGainLoss: array of TValuesArray;
    ClosingBalanceWithGainLoss: array of TValuesArray;
  end;

  //this is the cashflow report object.  It adds functionality to print a
  //cash on hand section, and provides routines to retrieve values for each
  //account
  TCashflowReportEx = class( TFinancialReportBase)
  protected
    function GetBudgetAmountForPeriod(GainLossCode: String; PeriodNo: Integer): Money;
    function GetFullYearBudget(GainlossCode: String): Money;
    
    procedure GetValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray; UsePeriodStartEnd: boolean = false); override;
    procedure GetYTD_ValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); override;

    procedure GetOpeningBalancesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray);
    function GetClosingBalancesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray): Boolean;
    procedure GetExchangeGainLossForPeriod(const pAcct: pAccount_Rec; const ForPeriod: Integer; var Values: TValuesArray);
    procedure GetYTD_ExchangeGainLoss(const pAcct : pAccount_Rec; const ToPeriod : integer; var Values : TValuesArray);
    
    function  AccountNeedsPrinting( pAcct : pAccount_Rec) : boolean; override;

    procedure SetupColumnsTypes; override;
    function NonBaseCurrencyContra(AContraCode: string; var ForexLabel: string): boolean;
    function GetExchangeRateForForexContra(AContraCode: string; ForPeriod: integer; EndOfPerod: Boolean = False;
                                           LastYear: Boolean = False; GetRateFromEndOfLastMonth: Boolean = False): Double;
    procedure SetBaseAmounts(const pAcct : pAccount_Rec; var BaseAmounts: TBaseAmounts);
  private
    // FClosingBalanceExchangeRate: double;
    FUseBaseAmounts: Boolean;
    function GetOpeningBalanceAmount(Code: string; IsStartOfFinancialYear: boolean;
                                     PeriodNo: integer): Money;
  public
    constructor Create(aClient : TClientObj; aRptParameters: TRptParameters); override;

    function  GetHeading( No : Integer): string; override;
    procedure PrintCashOnHandSection;

    function GetPrintGainLossSummaryLegend: Boolean;
  end;

  TExchangeGainLossTable = class
  private
    FOwner: TCashflowReportEx;
    FTable: array of TValuesArray;
    FColumnsPerPeriod: Integer;
    FFromPeriod: Integer;
    FToPeriod: Integer;

    procedure InitializeTable;
    
    procedure Clear;
  public
    constructor Create(Owner: TCashflowReportEx; ColumnsPerPeriod, FromPeriod, ToPeriod: Integer);
    destructor Destroy; override;
    
    procedure Initialize(Account: pAccount_Rec);

    procedure GetValuesForPeriod(Period: Integer; var ValuesArray: TValuesArray);
    procedure SumValuesToPeriod(ToPeriod: Integer; var ValuesArray: TValuesArray);
  end;
  
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflowActualReport(Destination : TReportDest;
                                  RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(Report_Cashflow_Act),MyClient,RptBatch,DYear);
   try
      repeat
      {$B-}
      with LParam do if BatchRun  then// Get and validate settings

      else begin
         //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - Actual';
         if not GetFYearParameters(REPORT_LIST_NAMES[Report_Cashflow_Act],
                 Lparam, BKH_Cash_Flow_Actual) then exit;


         case RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Exit;
         end;
      end;

      if Destination <> rdNone  then begin

         with  Lparam, Client, clFields do begin
         clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Detailed;
         clFRS_Compare_Type                        := cflCompare_None;

         clFRS_Show_Variance                       := False;
         clFRS_Show_YTD                            := True;
         clFRS_Show_Quantity                       := False;
         //clFRS_Print_Chart_Codes  Set by Dialog
         clFRS_Reporting_Period_Type               := frpMonthly;
         clFRS_Report_Style                        := crsSinglePeriod;
         //clReporting_Year_Starts
         clFRS_Report_Detail_Type                  := cflReport_Detailed;

         clGST_Inclusive_Cashflow                  := ShowGST;
         clFRS_Prompt_User_to_use_Budgeted_figures := False;

         //now save temporary client variables
         clTemp_FRS_Last_Period_To_Show            := Period;
         clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
         clTemp_FRS_From_Date                      := 0;
         clTemp_FRS_To_Date                        := 0;
         clTemp_FRS_Division_To_Use                := Division;
         clTemp_FRS_Job_To_Use                     := '';
         clTemp_FRS_Budget_To_Use                  := '';
         clTemp_FRS_Budget_To_Use_Date             := -1;
         clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
         clFRS_Print_Chart_Codes                   := ChartCodes;
         //now set temporary flag into bank accounts;
         FlagAllAccountsForUse( Client);
         end;
         //**********************************
         LParam.Savedates;
         DoCashflowEx(Destination,lparam.ReportType,RptBatch);
         //**********************************
      end;
      until  LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflowActualBudgetReport(Destination : TReportDest;
                                         RptBatch : TReportBase = nil);
var
   lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(Report_Cashflow_ActBud),MyClient,RptBatch,DYear,True);
   try repeat
      {$B-}
      with LParam do if BatchRun  // Get and validate settings
      and (Period <> -1) then begin

         //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;;
      end else begin

        //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - Actual and Budget';
        if not GetFYearParameters( REPORT_LIST_NAMES[Report_Cashflow_ActBud],
                 Lparam, BKH_Cash_Flow_Actual_and_budget,False,True,True) then exit;



        case RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
        end;

     end;

     if Destination <> rdNone then begin

        with LParam do if not Assigned(Budget) then begin
           if BatchRun then
              RptBatch.RunResult := 'No budget selected';
           exit;
        end;


        with MyClient, Myclient.clFields, LParam do  begin
        clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_None;
        clFRS_Compare_Type                        := cflCompare_To_Budget;

        clFRS_Show_Variance                       := False;
        clFRS_Show_YTD                            := True;
        clFRS_Show_Quantity                       := False;
        //clFRS_Print_Chart_Codes  Set by Dialog
        clFRS_Reporting_Period_Type               := frpMonthly;
        clFRS_Report_Style                        := crsSinglePeriod;
        //clReporting_Year_Starts
        clFRS_Report_Detail_Type                  := cflReport_Detailed;

        clGST_Inclusive_Cashflow                  := ShowGST;
        clFRS_Prompt_User_to_use_Budgeted_figures := False;

        //now save temporary client variables
        clTemp_FRS_Last_Period_To_Show            := Period;
        clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;

        clTemp_FRS_From_Date                      := 0;
        clTemp_FRS_To_Date                        := 0;
        clTemp_FRS_Job_To_Use                     := '';
        clTemp_FRS_Division_To_Use                := Division;
        clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
        clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
        clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
        clFRS_Print_Chart_Codes                   := ChartCodes;

        //now set temporary flag into bank accounts;
        FlagAllAccountsForUse( MyClient);
        end;
        //********************************
        LParam.Savedates;
        DoCashflowEx( Destination,LParam.ReportType, RptBatch);
        //********************************
     end;
   until LParam.RunExit(Destination);

   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflowActualBudgetVarianceReport(Destination: TReportDest;
                                         RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(Report_Cashflow_ActBudVar),MyClient,RptBatch,DYear,True);
   try
      Repeat

      {$B-}
      with lParam do if BatchRun  // Get and validate settings
      and (Period <> -1) then begin
         //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;
      end else begin
         //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - Actual, Budget and Variance';
         if not GetFYearParameters( REPORT_LIST_NAMES[Report_Cashflow_ActBudVar],
                 Lparam, BKH_Cash_Flow_Actual_budget_and_variance, False, True,True) then exit;


         case RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
         end;
      end;

      if Destination <> rdNone then begin

         with lparam do if not Assigned( Budget ) then begin
            if BatchRun then
               RptBatch.RunResult := 'No budget selected';
            exit;
         end;


         with MyClient, Myclient.clFields, LParam do begin
            clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_None;
            clFRS_Compare_Type                        := cflCompare_To_Budget;

            clFRS_Show_Variance                       := True;
            clFRS_Show_YTD                            := True;
            clFRS_Show_Quantity                      := False;
            //clFRS_Print_Chart_Codes  Set by Dialog
            clFRS_Reporting_Period_Type               := frpMonthly;
            clFRS_Report_Style                        := crsSinglePeriod;
            //clReporting_Year_Starts
            clFRS_Report_Detail_Type                  := cflReport_Detailed;

            clGST_Inclusive_Cashflow                  := ShowGST;
            clFRS_Prompt_User_to_use_Budgeted_figures := False;

            //now save temporary client variables
            clTemp_FRS_Last_Period_To_Show            := Period;
            clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
            clTemp_FRS_From_Date                      := 0;
            clTemp_FRS_To_Date                        := 0;
            clTemp_FRS_Division_To_Use                := Division;
            clTemp_FRS_Job_To_Use                     := '';
            clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
            clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
            clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
            clFRS_Print_Chart_Codes                   := ChartCodes;

            //now set temporary flag into bank accounts;
            FlagAllAccountsForUse( MyClient);
         end;
         //*********************************
         LParam.Savedates;
         DoCashflowEx(Destination, lParam.ReportType, RptBatch);
         //*********************************
      end;
      until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoCashflowActualLastYearVariance( Destination : TReportDest;
                                         RptBatch : TReportBase = nil);
var lParam    : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(Report_Cashflow_ActLastYVar),MyClient,RptBatch,DYear);
   try
      repeat
      {$B-}
      with lParam do if BatchRun  // Get and validate settings
      and (Period <> -1) then begin
         //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;
      end else begin

          //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - This Year, Last Year and Variance';
          if not GetFYearParameters( REPORT_LIST_NAMES[Report_Cashflow_ActLastYVar],
                 Lparam, BKH_Cash_Flow_This_year_last_year_and_variance) then exit;


         case RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
         end;
      end;

      if Destination <> rdNone then begin
         with MyClient, Myclient.clFields, LParam do
         begin
            if MyClient.HasForeignCurrencyAccounts then
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Detailed
            else
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Summarised;
            clFRS_Compare_Type                        := cflCompare_To_Last_Year;

            clFRS_Show_Variance                       := True;
            clFRS_Show_YTD                            := True;
            clFRS_Show_Quantity                      := False;
            //clFRS_Print_Chart_Codes  Set by Dialog
            clFRS_Reporting_Period_Type               := frpMonthly;
            clFRS_Report_Style                        := crsSinglePeriod;
            //clReporting_Year_Starts
            clFRS_Report_Detail_Type                  := cflReport_Detailed;

            clGST_Inclusive_Cashflow                  := showGST;
            clFRS_Prompt_User_to_use_Budgeted_figures := False;

            //now save temporary client variables
            clTemp_FRS_Last_Period_To_Show            := Period;
            clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
            clTemp_FRS_From_Date                      := 0;
            clTemp_FRS_To_Date                        := 0;
            clTemp_FRS_Division_To_Use                := Division;
            clTemp_FRS_Job_To_Use                     := '';
            clTemp_FRS_Budget_To_Use                  := '';
            clTemp_FRS_Budget_To_Use_Date             := -1;
            clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
            clFRS_Print_Chart_Codes                   := ChartCodes;

            //now set temporary flag into bank accounts;
            FlagAllAccountsForUse( MyClient);
         end;

         //********************************
         LParam.Savedates;
         DoCashflowEx(Destination, lparam.ReportType, RptBatch);
         //********************************
      end;
      until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflow12ActualReport(Destination : TReportDest;
                                         RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_CASHFLOW_12ACT), MyClient,RptBatch,DYear);
   try repeat
       {$B-}
       with Lparam do if BatchRun  // Get and validate settings
       and (Period <> -1) then begin
          //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;
       end else begin
         //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - 12 Months Actual';
         if not GetFYearParameters( REPORT_LIST_NAMES[REPORT_CASHFLOW_12ACT],
                 Lparam, BKH_Cash_Flow_12_months_actual) then exit;



         case lParam.RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
         end;
       end;


       if Destination <> rdNone then begin

          with MyClient, Myclient.clFields, LParam do
          begin
            if MyClient.HasForeignCurrencyAccounts then
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Detailed
            else
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Summarised;

          clFRS_Compare_Type                        := cflCompare_None;

          clFRS_Show_Variance                       := False;
          clFRS_Show_YTD                            := True;
          clFRS_Show_Quantity                       := False;
          //clFRS_Print_Chart_Codes  Set by Dialog
          clFRS_Reporting_Period_Type               := frpMonthly;
          clFRS_Report_Style                        := crsMultiplePeriod;
          //clReporting_Year_Starts
          clFRS_Report_Detail_Type                  := cflReport_Detailed;

          clGST_Inclusive_Cashflow                  := ShowGST;
          clFRS_Prompt_User_to_use_Budgeted_figures := False;

          //now save temporary client variables
          clTemp_FRS_Last_Period_To_Show            := Period;
          clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
          clTemp_FRS_From_Date                      := 0;
          clTemp_FRS_To_Date                        := 0;
          clTemp_FRS_Division_To_Use                := Division;
          clTemp_FRS_Job_To_Use                     := '';
          clTemp_FRS_Budget_To_Use                  := '';
          clTemp_FRS_Budget_To_Use_Date             := -1;
          clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
          clFRS_Print_Chart_Codes                   := ChartCodes;

          FlagAllAccountsForUse(MyClient);
          end;

          //*********************************
          LParam.Savedates;
          DoCashflowEx(Destination, LParam.ReportType, RptBatch);
          //*********************************
      end;
      until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflow12ActualBudgetReport(Destination : TReportDest;
                                         RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(REPORT_CASHFLOW_12ACTBUD),MyClient,RptBatch,DYear,True);
   try repeat

       {$B-}
       with lparam do if BatchRun  // Get and validate settings
       and (Period <> -1) then begin
          //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;
       end else begin
          //Title := GetCFHeading(MyClient, hdCash_Flow) + ' - 12 Months Actual or Budget';
          // need Start, Period and IncGST

          if not GetFYearParameters( REPORT_LIST_NAMES[REPORT_CASHFLOW_12ACTBUD],
                 Lparam, BKH_Cash_Flow_12_months_actual_or_budget, False, True, True) then exit;

          case lParam.RunBtn of
             BTN_PRINT: Destination := rdPrinter;
             BTN_PREVIEW: Destination := rdScreen;
             BTN_FILE: Destination := rdFile;
             BTN_SAVE: Destination := rdNone;
             else Destination := rdAsk;
          end;
       end;


       if Destination <> rdNone then begin

          if not Assigned( LParam.Budget ) then begin
             if lParam.BatchRun then
                RptBatch.RunResult := 'No budget selected';
             exit;
          end;


          // Setup the Client fields
          with MyClient, Myclient.clFields, Lparam do
          begin
            if MyClient.HasForeignCurrencyAccounts then
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Detailed
            else
              clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Summarised;

          clFRS_Compare_Type                        := cflCompare_None;

          clFRS_Show_Variance                       := False;
          clFRS_Show_YTD                            := True;
          clFRS_Show_Quantity                       := False;
          //clFRS_Print_Chart_Codes  Set by Dialog
          clFRS_Reporting_Period_Type               := frpMonthly;
          clFRS_Report_Style                        := crsMultiplePeriod;
          //clReporting_Year_Starts
          clFRS_Report_Detail_Type                  := cflReport_Detailed;

          clGST_Inclusive_Cashflow                  := showGST;
          clFRS_Prompt_User_to_use_Budgeted_figures := False;

           //now save temporary client variables
           {     clTemp_FRS_Last_Period_To_Show            := Period + 1;
           clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;}

          clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
          clTemp_FRS_Last_Actual_Period_To_Use      := Period;

          clTemp_FRS_From_Date                      := 0;
          clTemp_FRS_To_Date                        := 0;
          clTemp_FRS_Division_To_Use                := Division;
          clTemp_FRS_Job_To_Use                     := '';
          clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
          clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
          clTemp_FRS_Use_Budgeted_Data_If_No_Actual := True;
          clFRS_Print_Chart_Codes                   := ChartCodes;

           //now set temporary flag into bank accounts;
          FlagAllAccountsForUse( MyClient);
          end;

          // Run the Report..
          //*********************************
          LParam.Savedates;
          DoCashflowEx(Destination, lParam.ReportType, RptBatch);
          //*********************************
       end;
   until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashFlowBudgetRem(Destination : TReportDest;
                              RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;

begin
   lParam := TProfitRptParameters.Create(ord(REPORT_CASHFLOW_BUDREM), MyClient,RptBatch,DYear,True);
   try repeat

      with lparam do if BatchRun  // Get and validate settings
      and (Period <> -1) then begin
         //MyClient.clFields.clReporting_Year_Starts := RptBatch.RundateFrom;
      end else begin
         if not GetFYearParameters(
                     REPORT_LIST_NAMES[REPORT_CASHFLOW_BUDREM],
                     lparam, BKH_Budget_remaining, False, True, True) then exit;




          case lParam.RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
         end;
      end;

      if Destination <> rdNone then begin

         if not Assigned( lparam.Budget ) then begin
            if lParam.BatchRun then
               RptBatch.RunResult := 'No budget selected';
            exit;
         end;



         with MyClient, Myclient.clFields, Lparam do begin
         clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_None;
         clFRS_Compare_Type                        := cflCompare_To_Budget;

         clFRS_Show_Variance                       := True;
         clFRS_Show_YTD                            := True;
         clFRS_Show_Quantity                      := False;
         //clFRS_Print_Chart_Codes  Set by Dialog
         clFRS_Reporting_Period_Type               := frpMonthly;
         clFRS_Report_Style                        := crsBudgetRemaining;
         //clReporting_Year_Starts
         clFRS_Report_Detail_Type                  := cflReport_Detailed;

         clGST_Inclusive_Cashflow                  := ShowGST;
         clFRS_Prompt_User_to_use_Budgeted_figures := False;

         //now save temporary client variables
         clTemp_FRS_Last_Period_To_Show            := Period;
         clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
         clTemp_FRS_From_Date                      := 0;
         clTemp_FRS_To_Date                        := 0;
         clTemp_FRS_Division_To_Use                := Division;
         clTemp_FRS_Job_To_Use                     := '';
         clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
         clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
         clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
         clFRS_Print_Chart_Codes                   := ChartCodes;

         //now set temporary flag into bank accounts;
         FlagAllAccountsForUse( MyClient);
         end;

         //********************************
         LParam.Savedates;
         DoCashflowEx(Destination, lparam.ReportType, RptBatch);
         //********************************
      end;
   until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflowDate(Destination : TReportDest;
                         RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(Report_Cashflow_Date), MyClient,RptBatch,DPeriod);
   with lParam, Client.clFields do begin
         // Wrong name for here.. but a boolean is a boolean
         SpareBool := GetBatchBool('Show_Last_Year',(clFRS_Compare_Type = cflCompare_To_Last_Year));
   end;
   try repeat


      With LParam do if BatchRun  // Get and validate settings
      then begin
      end else begin
         //Title := GetCFHeading(MyClient, hdCash_Flow) + ' Report - From Date to Date';

         if not GetCFDateParameters(REPORT_LIST_NAMES[Report_Cashflow_Date], lparam ) then
            Exit;


         case LParam.BatchRunMode of
           R_Normal : begin
                  LParam.SaveClientSettings;
               end;
           R_Setup,
           R_BatchAdd : if LParam.Runbtn = BTN_SAVE then begin

                  LParam.SaveNodeSettings;
                  SetBatchBool('Show_Last_Year',SpareBool);
                  {if LParam.BatchRunMode = R_Setup then} Exit
                  {else LParam.RptBatch.BatchRunMode := R_Setup};
              end;

           R_Batch : if LParam.Runbtn= BTN_SAVE then begin
                  Exit;
               end else begin
                  LParam.SaveClientSettings;
                  Client.clFields.clGST_Inclusive_Cashflow := ShowGST;
               end;
          end;//Case

         case RunBtn of
            BTN_PRINT : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE : Destination := rdFile;
            BTN_SAVE : Destination := rdNone;
            else Destination := rdAsk;
         end;
      end;


      if Destination <> rdNone then begin

         with lparam, Client, client.clFields do begin
         clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_None;
         if SpareBool then
           clFRS_Compare_Type                      := cflCompare_To_Last_Year
         else
           clFRS_Compare_Type                      := cflCompare_None;

         clFRS_Show_Variance                       := SpareBool;

         clFRS_Show_YTD                            := False;
         clFRS_Show_Quantity                       := False;
         clFRS_Reporting_Period_Type               := frpCustom;
         clFRS_Report_Style                        := crsSinglePeriod;
         //clReporting_Year_Starts
         clFRS_Report_Detail_Type                  := cflReport_Detailed;

         clGST_Inclusive_Cashflow                  := ShowGST;
         clFRS_Prompt_User_to_use_Budgeted_figures := False;

         //now save temporary client variables
         clTemp_FRS_Last_Period_To_Show            := 1;
         clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
         clTemp_FRS_From_Date                      := Fromdate;
         clTemp_FRS_To_Date                        := Todate;
         clTemp_FRS_Division_To_Use                := Division;
         clTemp_FRS_Job_To_Use                     := '';
         clTemp_FRS_Budget_To_Use                  := '';
         clTemp_FRS_Budget_To_Use_Date             := -1;
         clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
         clTemp_FRS_Split_By_Division              := False;
         SetLength(clTemp_FRS_Divisions, 0);
         //Done in dialog
         //clFRS_Print_Chart_Codes                   := ChartCodes;

         //now set temporary flag into bank accounts;
         FlagAllAccountsForUse( MyClient);
         end;

         //********************************
         LParam.Savedates;
         DoCashflowEx(Destination,lParam.ReportType, RptBatch);
         //********************************
     end;
   until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FirstMovementDateForAccount( aClient : TClientObj; pAcct : pAccount_Rec) : integer;
var
  i,t : integer;
  ba : TBank_Account;
  pT : pTransaction_Rec;
  pD : pDissection_Rec;
begin
  //need to find out when the first activity occurs for this account code
  //this is so that balances only appear for relevant periods
  //get first date from all bank accounts that use this contra code
  result := MaxInt;
  try
    //search through bank accounts for date of first transactio
    for i := 0 to aClient.clBank_Account_List.Last do
    begin
      ba := aClient.clBank_Account_List.Bank_Account_At(i);
      if ( ba.baFields.baAccount_Type in [ btBank]) and ( ba.baFields.baContra_Account_Code = pAcct.chAccount_Code) then
      begin
        if ba.baTransaction_List.ItemCount > 0 then
        begin
          pT := ba.baTransaction_List.Transaction_At(0);
          if pT^.txDate_Effective < result then
            result := pT^.txDate_Effective;
        end;
      end;
    end;
    //search through transactions for first transaction coded to this code
    for i := 0 to aClient.clBank_Account_List.Last do
    begin
      ba := aClient.clBank_Account_List.Bank_Account_At(i);
      if ( ba.baFields.baAccount_Type in [ btBank, btCashJournals, btOpeningBalances]) then
      begin
        for t := 0 to ba.baTransaction_List.Last do
        begin
          pT := ba.baTransaction_List.Transaction_At(t);

          //first transaction for this account is later than the date we have anyway
          if pT^.txDate_Effective >= Result then
            Break;

          if pT^.txFirst_Dissection = nil then
          begin
            if pT^.txAccount = pAcct.chAccount_Code then
            begin
              result := pT^.txDate_Effective;
              Break;
            end;
          end
          else
          begin
            //transaction is dissected
            pD := pT^.txFirst_Dissection;
            while pD <> nil do
            begin
              if pD^.dsAccount = pAcct.chAccount_Code then
              begin
                result := pT^.txDate_Effective;
                Break;
              end;
              pD := pD^.dsNext;
            end;
          end;
        end;
      end;
    end;
  finally
    if result = MaxInt then
      result := 0;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetDateOfFirstMovement( aClient : TClientObj);
//cycle through the chart setting the date of first movement for each
//bank account contra code
var
  pAcct : pAccount_Rec;
  i     : integer;
begin
  for i := 0 to aClient.clChart.Last do
  begin
    pAcct := aClient.clChart.Account_At(i);
    if pAcct^.chAccount_Type = atBankAccount then
    begin
      if pAcct^.chTemp_Calc_Totals_Tag = Tag_Budget_Movement then
        pAcct^.chTemp_Date_First_Movement := 1
      else
      begin
        pAcct^.chTemp_Date_First_Movement := FirstMovementDateForAccount( aClient, pAcct);
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IncludeBalance( PeriodStart, PeriodEnd, FirstMovement : integer) : boolean;
var
  d,m,y : integer;
  FirstOfMth : integer;
begin
  result := false;
  //convert first movement date to a first of month date
  if FirstMovement > 0 then
  begin
    StDateToDmy( FirstMovement, d, m, y);
    d := 1;
    FirstOfMth := DmyToStDate( d, m, y, BKDATEEPOCH);
    //date of first movement must be on or earlier than the period start date OR
    //must be inside this period
    result := (FirstOfMth <= PeriodStart) or
              ((FirstMovement >= PeriodStart) and (FirstMovement <= PeriodEnd));
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetPeriodEndDate( aClient : TClientObj; ForPeriod : integer; var PeriodEndDate_TY, PeriodEndDate_LY : integer);
//return the period start dates for this year and last year
begin
  //this year
  if ForPeriod <= aClient.clFields.clTemp_Periods_This_Year then begin
    PeriodEndDate_TY := aClient.clFields.clTemp_Period_Details_This_Year[ ForPeriod].Period_End_Date;
  end
  else begin
    PeriodEndDate_TY := 0;
  end;

  //last year
  if ForPeriod <= aClient.clFields.clTemp_Periods_This_Year then begin
    PeriodEndDate_LY := aClient.clFields.clTemp_Period_Details_Last_Year[ ForPeriod].Period_End_Date;
  end
  else begin
    PeriodEndDate_LY := 0;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetPeriodStartDate( aClient : TClientObj; ForPeriod : integer; var PeriodStartDate_TY, PeriodStartDate_LY : integer);
//return the period start dates for this year and last year
begin
  //this year
  if ForPeriod <= aClient.clFields.clTemp_Periods_This_Year then begin
    PeriodStartDate_TY := aClient.clFields.clTemp_Period_Details_This_Year[ ForPeriod].Period_Start_Date;
  end
  else begin
    PeriodStartDate_TY := 0;
  end;

  //last year
  if ForPeriod <= aClient.clFields.clTemp_Periods_This_Year then begin
    PeriodStartDate_LY := aClient.clFields.clTemp_Period_Details_Last_Year[ ForPeriod].Period_Start_Date;
  end
  else begin
    PeriodStartDate_LY := 0;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  GetCFHeading(ClientForReport : TClientObj; No : Integer): string;
begin
  result := '';

  if No = -1 then Exit;

  result := ClientForReport.clFields.clCF_Headings[ No ];

  if result = '' then
     result := CFHEAD.hdNames[ No ];

  if Uppercase(result) = 'HIDE' then
     result := '';
end;

{ TCashflowReportEx }

function TCashflowReportEx.GetBudgetAmountForPeriod(GainLossCode: String; PeriodNo: Integer): Money;
var
  ChartIndex: Integer;
  BudgetIndex: Integer;
  Budget: TBudget;
  DetailIndex: Integer;
  Detail: pBudget_Detail_Rec;
  GainLossAccount: pAccount_Rec;
begin
  Result := 0;

  for ChartIndex := 0 to ClientForReport.clChart.ItemCount - 1 do
  begin
    GainLossAccount := ClientForReport.clChart.Account_At(ChartIndex);

    if GainLossAccount.chAccount_Code = GainLossCode then
    begin
      for BudgetIndex := 0 to ClientForReport.clBudget_List.ItemCount - 1 do
      begin
        Budget := ClientForReport.clBudget_List.Budget_At(BudgetIndex);

        for DetailIndex := 0 to Budget.buDetail.ItemCount - 1 do
        begin
          Detail := Budget.buDetail.Budget_Detail_At(DetailIndex);

          if (Detail.bdAccount_Code = GainLossCode) then
          begin
            Result := Detail.bdBudget[PeriodNo] * 100;

            if ExpectedSign(GainLossAccount.chAccount_Type) = Credit then
            begin
              Result := -Result;
            end;

            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function TCashflowReportEx.GetClosingBalancesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer;
  var Values: TValuesArray): Boolean;
//is called from the cash on hand summary, will only be called for accounts
//with bank account report groups
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
  PeriodStartDate_TY, PeriodStartDate_LY,
  PeriodEndDate_TY, PeriodEndDate_LY : integer;
  ThisYearOpeningBalance: Money;
  LastYearOpeningBalance: Money;
begin
  Assert( Length( ColumnTypes) = Length( Values));
  // Result only used for cash books to indicate movement within period
  Result := False;
  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TAccountInformation.Create( ClientForReport);
  try
    AccountInfo.UseBaseAmounts := FUseBaseAmounts; 
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    //need to check if any movement has occured on this code on or before the
    //date of this period, if nothing has happened yet then return 0 for balance
    GetPeriodStartDate( ClientForReport, ForPeriod, PeriodStartDate_TY, PeriodStartDate_LY);
    GetPeriodEndDate( ClientForReport, ForPeriod, PeriodEndDate_TY, PeriodEndDate_LY);

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : begin
          if IncludeBalance(PeriodStartDate_TY, PeriodEndDate_TY, pAcct^.chTemp_Date_First_Movement) then
          begin
            Values[ i]  := AccountInfo.ClosingBalanceActualOrBudget( ForPeriod);

             if AccountInfo.YTD_ActualOrBudget(ForPeriod) = 0 then
             begin
               Result := AccountInfo.OpeningBalanceActualOrBudget(ForPeriod) <> 0;
             end
             else
             begin
               Result := True;
             end;
          end;
        end;
        ftComparative : begin
          //does the user want last year or budget
          if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            if ShowLastYear then
              Values[i]   := AccountInfo.ClosingBalance_LastYear( ForPeriod)
            else if ShowBudget then
              Values[i]   := AccountInfo.ClosingBalanceBudget(ForPeriod);
        end;
        ftVariance :
        begin
          if ShowLastYear then
          begin
            ThisYearOpeningBalance := 0;
            LastYearOpeningBalance := 0;

            if IncludeBalance(PeriodStartDate_TY, PeriodEndDate_TY, pAcct^.chTemp_Date_First_Movement) then
            begin
              ThisYearOpeningBalance := AccountInfo.ClosingBalanceActualOrBudget( ForPeriod);
            end;

            if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            begin
              LastYearOpeningBalance := AccountInfo.ClosingBalance_LastYear(ForPeriod);
            end;

            Values[i] := ThisYearOpeningBalance - LastYearOpeningBalance; 
          end;
        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TCashflowReportEx.GetExchangeGainLossForPeriod(const pAcct: pAccount_Rec; const ForPeriod: Integer; var Values: TValuesArray);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  PeriodStartDate_TY, PeriodStartDate_LY,
  PeriodEndDate_TY, PeriodEndDate_LY: integer;
  j: integer;
  ThisYearGainLossAmount: Money;
  LastYearGainLossAmount: Money;
  BudgetGainLossAmount: Money;
  AccountIndex: Integer;
  BankAccount: TBank_Account;
  GainLossIndex: Integer;
  GainLossEntry: TExchange_Gain_Loss;
  BudgetAmount: Money;
  FullYearBudget: Money;
  Period: Integer;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);

  //need to check if any movement has occured on this code on or before the
  //date of this period, if nothing has happened yet then return 0 for balance
  GetPeriodStartDate( ClientForReport, ForPeriod, PeriodStartDate_TY, PeriodStartDate_LY);
  GetPeriodEndDate( ClientForReport, ForPeriod, PeriodEndDate_TY, PeriodEndDate_LY);

  ThisYearGainLossAmount := 0;
  LastYearGainLossAmount := 0;
  BudgetAmount := 0;

  for AccountIndex := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := ClientForReport.clBank_Account_List.Bank_Account_At(AccountIndex);

    if BankAccount.baFields.baContra_Account_Code = pAcct.chAccount_Code then
    begin
      for GainLossIndex := 0 to BankAccount.baExchange_Gain_Loss_List.ItemCount - 1 do
      begin
        GainLossEntry := BankAccount.baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(GainLossIndex);

        if (GainLossEntry.glFields.glDate >= PeriodStartDate_TY) and (GainLossEntry.glFields.glDate <= PeriodEndDate_TY) then
        begin
          ThisYearGainLossAmount := ThisYearGainLossAmount + GainLossEntry.glFields.glAmount;
        end
        else
        if (GainLossEntry.glFields.glDate >= PeriodStartDate_LY) and (GainLossEntry.glFields.glDate <= PeriodEndDate_LY) then
        begin
          LastYearGainLossAmount := LastYearGainLossAmount + GainLossEntry.glFields.glAmount;
        end;
      end;

      BudgetAmount := BudgetAmount + GetBudgetAmountForPeriod(BankAccount.baFields.baExchange_Gain_Loss_Code, ForPeriod);
    end;
  end;

  for i := Low(Values) to High(Values) do
  begin
    case ColumnTypes[i] of
      ftActual:
      begin
        Values[i] := ThisYearGainLossAmount;
      end;
      ftComparative:
      begin
        if ShowLastYear then
        begin
          Values[i] := LastYearGainLossAmount;
        end
        else
        begin
          Values[i] := BudgetAmount;
        end;
      end;
      ftVariance:
      begin
        if ShowLastYear then
        begin
          Values[i] := -(LastYearGainLossAmount - ThisYearGainLossAmount);
        end
        else
        begin
          Values[i] := -(BudgetAmount - ThisYearGainLossAmount);
        end;
      end;
    end;
  end;
end;

function TCashflowReportEx.GetExchangeRateForForexContra(AContraCode: string; ForPeriod: integer
 ; EndOfPerod: Boolean = False; LastYear: Boolean = False; GetRateFromEndOfLastMonth: Boolean = False): Double;
var
  i: integer;
  ba : TBank_Account;
  PeriodDate_TY, PeriodDate_LY, PeriodDate_TY_Modified: integer;
  TestStr: string;
  IsStartOfFinancialYear: boolean;
begin
  Result := 0;
  for i := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do begin
    ba := TBank_Account(ClientForReport.clBank_Account_List.Bank_Account_At(i));
    if Assigned(ba) then begin
      if (ba.baFields.baContra_Account_Code = AContraCode) then begin
        if EndOfPerod then
          GetPeriodEndDate(ClientForReport, ForPeriod, PeriodDate_TY, PeriodDate_LY)
        else
          GetPeriodStartDate(ClientForReport, ForPeriod, PeriodDate_TY, PeriodDate_LY);
        TestStr := DateToStr(StDateToDateTime(PeriodDate_TY));

        if GetRateFromEndOfLastMonth then
          PeriodDate_TY := IncDate(PeriodDate_TY, -1, 0, 0); // We want to get the rate from the last day of the previous month
        TestStr := DateToStr(StDateToDateTime(PeriodDate_TY));
        Result := ba.Default_Forex_Conversion_Rate(PeriodDate_TY);
        if LastYear then
          Result := ba.Default_Forex_Conversion_Rate(PeriodDate_LY);
      end;
    end;
  end;
end;

function TCashflowReportEx.GetFullYearBudget(GainlossCode: String): Money;
var
  ChartIndex: Integer;
  BudgetIndex: Integer;
  Budget: TBudget;
  DetailIndex: Integer;
  Detail: pBudget_Detail_Rec;
  GainLossAccount: pAccount_Rec;
  Period: Integer;
  AccountInfo: TAccountInformation;
begin
  Result := 0;

  for ChartIndex := 0 to ClientForReport.clChart.ItemCount - 1 do
  begin
    GainLossAccount := ClientForReport.clChart.Account_At(ChartIndex);

    if GainLossAccount.chAccount_Code = GainLossCode then
    begin
      AccountInfo := TAccountInformation.Create( ClientForReport);

      try
        AccountInfo.UseBaseAmounts := FUseBaseAmounts;
        AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
        AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
        AccountInfo.AccountCode                 := GainLossCode;

        for BudgetIndex := 0 to ClientForReport.clBudget_List.ItemCount - 1 do
        begin
          Budget := ClientForReport.clBudget_List.Budget_At(BudgetIndex);

          for DetailIndex := 0 to Budget.buDetail.ItemCount - 1 do
          begin
            Detail := Budget.buDetail.Budget_Detail_At(DetailIndex);

            if (Detail.bdAccount_Code = GainLossCode) then
            begin
              for Period := 0 to AccountInfo.HighestPeriod do
              begin
                Result := Result + Detail.bdBudget[Period] * 100;
              end;

              if ExpectedSign(GainLossAccount.chAccount_Type) = Credit then
              begin
                Result := -Result;
              end;

              Exit;
            end;
          end;
        end;
      finally
        AccountInfo.Free;
      end;
    end;
  end;
end;

constructor TCashflowReportEx.Create(aClient : TClientObj; aRptParameters: TRptParameters);
begin
  inherited; // FIRST

  FIncludeGainLossCode := false;
end;

function TCashflowReportEx.GetHeading(No: Integer): string;
begin
  Result := GetCFHeading(ClientForReport, No);
end;

procedure TCashflowReportEx.GetOpeningBalancesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer;
  var Values: TValuesArray);
//is called from the cash on hand summary, will only be called for accounts
//with bank account report groups
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
  PeriodStartDate_TY, PeriodStartDate_LY,
  PeriodEndDate_TY, PeriodEndDate_LY: integer;
  ThisYearOpeningBalance: Money;
  LastYearOpeningBalance: Money;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TAccountInformation.Create( ClientForReport);
  try
    AccountInfo.UseBaseAmounts :=  FUseBaseAmounts;
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    //need to check if any movement has occured on this code on or before the
    //date of this period, if nothing has happened yet then return 0 for balance
    GetPeriodStartDate( ClientForReport, ForPeriod, PeriodStartDate_TY, PeriodStartDate_LY);
    GetPeriodEndDate( ClientForReport, ForPeriod, PeriodEndDate_TY, PeriodEndDate_LY);

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : begin
          if IncludeBalance(PeriodStartDate_TY, PeriodEndDate_TY, pAcct^.chTemp_Date_First_Movement) then
            Values[ i]     := AccountInfo.OpeningBalanceActualOrBudget( ForPeriod);
        end;
        ftComparative : begin
          //does the user want last year or budget
          if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            if ShowLastYear then
              Values[i]   := AccountInfo.OpeningBalance_LastYear( ForPeriod)
            else if ShowBudget then
              Values[i] := AccountInfo.OpeningBalanceBudget(ForPeriod);
        end;
        ftVariance :
        begin
          if ShowLastYear then
          begin
            ThisYearOpeningBalance := 0;
            LastYearOpeningBalance := 0;
            
            if IncludeBalance(PeriodStartDate_TY, PeriodEndDate_TY, pAcct^.chTemp_Date_First_Movement) then
            begin
              ThisYearOpeningBalance := AccountInfo.OpeningBalanceActualOrBudget( ForPeriod);
            end;

            if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            begin
              LastYearOpeningBalance := AccountInfo.OpeningBalance_LastYear( ForPeriod)
            end;

            Values[i] := ThisYearOpeningBalance - LastYearOpeningBalance;
          end;
        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

function TCashflowReportEx.GetPrintGainLossSummaryLegend: Boolean;
var
  Index: Integer;
  pAcct: pAccount_Rec;
  ForexLabel: String;
begin
  Result := False;
  
  if ReportSectionNeedsPrinting( [ atBankAccount]) then
  begin
    if ClientForReport.clFields.clCflw_Cash_On_Hand_Style = cflCash_On_Hand_Summarised then
    begin
      for Index := 0 to Pred(FRptParameters.Chart.ItemCount) do
      begin
        pAcct := FRptParameters.Chart.Account_At(Index);

        if (pAcct^.chAccount_Type in [atBankAccount]) and (pAcct^.chTemp_Include_In_Report) then
        begin
          if NonBaseCurrencyContra(pAcct.chAccount_Code, ForexLabel) then
          begin
            Result := True;

            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCashflowReportEx.GetValuesForPeriod(const pAcct: pAccount_Rec;
  const ForPeriod: integer; var Values: TValuesArray; UsePeriodStartEnd: boolean = false);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
  Act: Money;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TAccountInformation.Create( ClientForReport);
  try
    AccountInfo.UseBaseAmounts := FUseBaseAmounts;
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : Values[ i]     := AccountInfo.ActualOrBudget( ForPeriod);
        ftQuantity : Values[ i]   := AccountInfo.QuantityOrBudget( ForPeriod);
        ftBudgetQuantity: Values[ i] := AccountInfo.BudgetQuantity(ForPeriod);
        ftBudgetUnitPrice: Values[ i] := AccountInfo.BudgetUnitPrice(ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
            Values[i]   := AccountInfo.LastYear( ForPeriod);
          if ShowBudget then
            Values[i]   := AccountInfo.Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
            Values[i]   := AccountInfo.Variance_ActualLastYear( ForPeriod);
          if ShowBudget then
          begin
            Values[i]   := AccountInfo.Variance_ActualBudget( ForPeriod);
          end;
        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TCashflowReportEx.GetYTD_ExchangeGainLoss(const pAcct: pAccount_Rec; const ToPeriod: integer; var Values: TValuesArray);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  PeriodStartDate_TY, PeriodStartDate_LY,
  PeriodEndDate_TY, PeriodEndDate_LY: integer;
  j: integer;
  ThisYearGainLossAmount: Money;
  LastYearGainLossAmount: Money;
  BudgetGainLossAmount: Money;
  AccountIndex: Integer;
  BankAccount: TBank_Account;
  GainLossIndex: Integer;
  GainLossEntry: TExchange_Gain_Loss;
  BudgetAmount: Money;
  FullYearBudget: Money;
  Period: Integer;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);

  ThisYearGainLossAmount := 0;
  LastYearGainLossAmount := 0;
  BudgetAmount := 0;
  FullYearBudget := 0;
  
  for AccountIndex := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := ClientForReport.clBank_Account_List.Bank_Account_At(AccountIndex);

    if BankAccount.baFields.baContra_Account_Code = pAcct.chAccount_Code then
    begin
      for Period := 1 to ToPeriod do
      begin
        //need to check if any movement has occured on this code on or before the
        //date of this period, if nothing has happened yet then return 0 for balance
        GetPeriodStartDate( ClientForReport, Period, PeriodStartDate_TY, PeriodStartDate_LY);
        GetPeriodEndDate( ClientForReport, Period, PeriodEndDate_TY, PeriodEndDate_LY);

        for GainLossIndex := 0 to BankAccount.baExchange_Gain_Loss_List.ItemCount - 1 do
        begin
          GainLossEntry := BankAccount.baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(GainLossIndex);

          if (GainLossEntry.glFields.glDate >= PeriodStartDate_TY) and (GainLossEntry.glFields.glDate <= PeriodEndDate_TY) then
          begin
            ThisYearGainLossAmount := ThisYearGainLossAmount + GainLossEntry.glFields.glAmount;
          end
          else
          if (GainLossEntry.glFields.glDate >= PeriodStartDate_LY) and (GainLossEntry.glFields.glDate <= PeriodEndDate_LY) then
          begin
            LastYearGainLossAmount := LastYearGainLossAmount + GainLossEntry.glFields.glAmount;
          end;
        end;
        
        BudgetAmount := BudgetAmount + GetBudgetAmountForPeriod(BankAccount.baFields.baExchange_Gain_Loss_Code, Period);
      end;

      FullYearBudget := GetFullYearBudget(BankAccount.baFields.baExchange_Gain_Loss_Code);
    end;
  end;

  for i := Low(Values) to High(Values) do
  begin
    case ColumnTypes[i] of
      ftActual:
      begin
        Values[i] := ThisYearGainLossAmount;
      end;
      ftComparative:
      begin
        if ShowLastYear then
        begin
          Values[i] := LastYearGainLossAmount;
        end
        else
        begin
          Values[i] := BudgetAmount;
        end;
      end;
      ftVariance:
      begin
        if ShowLastYear then
        begin
          Values[i] := -(LastYearGainLossAmount - ThisYearGainLossAmount);
        end
        else
        begin
          Values[i] := -(BudgetAmount - ThisYearGainLossAmount);
        end;
      end;
  
      ftFullPeriodBudget:
      begin
        Values[i] := FullYearBudget;
      end;

      ftBudgetRemaining:
      begin
        Values[i] := FullYearBudget - ThisYearGainLossAmount;
      end;
    end;
  end;
end;

procedure TCashflowReportEx.GetYTD_ValuesForPeriod( const pAcct: pAccount_Rec;
                                                    const ForPeriod: integer;
                                                    var Values: TValuesArray);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TAccountInformation.Create( ClientForReport);
  try
    AccountInfo.UseBaseAmounts := FUseBaseAmounts;
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : Values[ i]     := AccountInfo.YTD_ActualOrBudget( ForPeriod);
        ftQuantity : Values[ i]   := AccountInfo.YTD_Quantity( ForPeriod);
        ftBudgetQuantity: Values[ i] := AccountInfo.YTD_BudgetQuantity(ForPeriod);
        ftBudgetUnitPrice: Values[ i] := AccountInfo.AVG_BudgetUnitPrice(ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
            Values[i]   := AccountInfo.YTD_LastYear( ForPeriod);
          if ShowBudget then
            Values[i]   := AccountInfo.YTD_Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
            Values[i]   := AccountInfo.YTD_Variance_ActualLastYear( ForPeriod);
          if ShowBudget then
            Values[i]   := AccountInfo.YTD_Variance_ActualBudget( ForPeriod);
        end;
        ftFullPeriodBudget : Values[i] := AccountInfo.BudgetRemaining( 0, AccountInfo.HighestPeriod);
        ftBudgetRemaining  : Values[i] := AccountInfo.BudgetRemaining( ForPeriod, AccountInfo.HighestPeriod);
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

function TCashflowReportEx.NonBaseCurrencyContra(AContraCode: string; var ForexLabel: string): boolean;
var
  i, k: integer;
  ba : TBank_Account;
  pAcct        : pAccount_Rec;
begin
  ForexLabel := '';

  Result := False;

  for i := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do
  begin
    ba := TBank_Account(ClientForReport.clBank_Account_List.Bank_Account_At(i));

    if Assigned(ba) then
    begin
      if (ba.baFields.baContra_Account_Code = AContraCode) then
      begin
        if ba.IsAForexAccount then
        begin
          for k := 0 to Pred(FRptParameters.Chart.ItemCount) do
          begin
            pAcct := FRptParameters.Chart.Account_At(k);

            if (pAcct^.chAccount_Code = ba.baFields.baExchange_Gain_Loss_Code) then
            begin
              if ClientForReport.clFields.clFRS_Print_Chart_Codes then
              begin
                ForexLabel := pAcct.chAccount_Code + ' ';
              end;
              
              ForexLabel := ForexLabel + pAcct^.chAccount_Description;

              Break;
            end;
          end;
            
          Result := True;

          Break;
        end;
      end;
    end;
  end;
end;

procedure TCashflowReportEx.PrintCashOnHandSection;
//prints either a detailed or summarised cash on hand section.
//this routine does not currently support sub groups.
var
  sSectionHeading        : string;
  sAccountDesc : string;
  PeriodNo     : integer;

  ValuesArray  : TValuesArray;
  ValuesArrayBase  : TValuesArray;

  OB_ValuesArray : TValuesArray;
  MV_ValuesArray : TValuesArray;
  CB_ValuesArray : TValuesArray;
  EX_ValuesArray : TValuesArray;
  EX_PreviousValuesArray: TValuesArray;
  EX_TotalValuesArray : TValuesArray;

  OpeningBalanceTotals : TValuesArray;
  MovementTotals       : TValuesArray;
  ClosingBalanceTotals : TValuesArray;
  ExchangeGainLossTotals: TValuesArray;
  ClosingBalanceTotalsIncForex: TValuesArray;
  TotalsArrayPos       : integer;
  NumOfTotals          : integer;
  OpeningBalance       : Money;
  ClosingBalance       : Money;

  i,j,k,GainLossNum : integer;
  pAcct        : pAccount_Rec;
  Budget       : TBudget;
  BudgetedOpeningBalance : Money;

  ShowThisAccount : boolean;

  BaseAmounts: TBaseAmounts;
  NonBaseCurrencyAccount: Boolean;

  YearClosingBalance, YTDForex: double;
  ForexLabel: string;
  ForexPreviousPeriods: Money;
  CurrencyFormat: String;
  CurrencySymbol: String;
  PrintedYTD: boolean;
  FoundForexAccount: Boolean;
  Index: Integer;
  ExchangeGainLossTable: TExchangeGainLossTable;
  ActualPos: Integer;
  VariancePos: Integer;
  BudgetPos: Integer;


//  function GetFormatForBankAccount(AContraCode: string): string;
//  var
//    i: integer;
//    ba : TBank_Account;
//    CS: string;
//  begin
//    Result := MyClient.FmtMoneyStrBrackets;
//    for i := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do begin
//      ba := TBank_Account(ClientForReport.clBank_Account_List.Bank_Account_At(i));
//      if Assigned(ba) then begin
//        if (ba.baFields.baContra_Account_Code = AContraCode) then
//          CS := ba.CurrencySymbol;
//          if ClientForReport.clFields.clFRS_Report_Style in [crsSinglePeriod, crsBudgetRemaining] then
//          begin
//            if ReportTypeParams.RoundValues then
//            begin
//              Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]);
//              Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]); //note:sign is reversed
//            end else
//            begin
//              Result := Format('%s#,##0.00;%s(#,##0.00);-',[CS, CS]);
//              Result := Format('%s#,##0.00;%s(#,##0.00);-',[CS, CS]); //note:sign is reversed
//            end;
//          end else
//          begin
//             Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]);
//             Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]); //note:sign is reversed
//          end;
//
//      end;
//    end;
//  end;



begin

  if ClientForReport.clFields.clCflw_Cash_On_Hand_Style = cflCash_On_Hand_None then Exit;

  SetLength( ValuesArray, ColumnsPerPeriod);      //no need to nil this afterward
  SetLength( ValuesArrayBase, ColumnsPerPeriod);  //delphi will handle it through
  SetLength( EX_ValuesArray, ColumnsPerPeriod);
  SetLength( EX_PreviousValuesArray, ColumnsPerPeriod);
  SetLength( EX_TotalValuesArray, ColumnsPerPeriod);
                                                  //reference counting
  //test to see if the report is detailed or summarised
  if ClientForReport.clFields.clCflw_Cash_On_Hand_Style = cflCash_On_Hand_Detailed then
  begin
    //Precalculate all of the exchange gain/loss values for each column upto the last period being reported.
    ExchangeGainLossTable := TExchangeGainLossTable.Create(Self, ColumnsPerPeriod, 1, MaxPeriodToShow);

    try
      sSectionHeading := GetHeading( hdCashbook_Balances);
      if sSectionHeading <> '' then
        RenderTitleLine( sSectionHeading);

      for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
        pAcct := FRptParameters.Chart.Account_At(i);
        NonBaseCurrencyAccount := NonBaseCurrencyContra(pAcct.chAccount_Code, ForexLabel);
        if NonBaseCurrencyAccount then begin
          //Populate all the totals arrays for non-base currency contra accounts
          RequireLines(7);
        end else begin
          FUseBaseAmounts := False;
          RequireLines(5);
        end;

        //see if should show this account
        ShowThisAccount :=  (( pAcct^.chAccount_Type in [ atBankAccount]) and
                             ( pAcct^.chTemp_Include_In_Report));

        if ShowThisAccount then
        begin
          TotalsArrayPos := 0; // DONT CHECK THIS IN
          if NonBaseCurrencyAccount then
          begin
            ExchangeGainLossTable.Initialize(pAcct);
          end;
          
          CurrencySymbol := Get_ISO_4217_Symbol(MyClient.clExtra.ceLocal_Currency_Code);
        
          if Self.ReportTypeParams.RoundValues then
          begin
            CurrencyFormat := CurrencySymbol + '#,##0;-' + CurrencySymbol + '#,##0' + ';-';
          end
          else
          begin
            CurrencyFormat := MyClient.FmtMoneyStr + ';-';
          end;
        
        
          //Print Account Info
          if ClientForReport.clFields.clFRS_Print_Chart_Codes then begin
             sAccountDesc := Trim( pAcct^.chAccount_Code) + ' ' + Trim( pAcct^.chAccount_Description);
          end
          else
             sAccountDesc := Trim( pAcct^.chAccount_Description);
           
        
          RenderTitleLine( sAccountDesc);

          //1A. Opening Balance
          PutString( GetHeading( hdOpening_Balance));
          //Print Periodic Information
          for PeriodNo := MinPeriodToShow to MaxPeriodToShow do 
          begin
            if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then 
            begin 
              if NonBaseCurrencyAccount then 
              begin
                FUseBaseAmounts := True;

                GetOpeningBalancesForPeriod(pAcct, PeriodNo, ValuesArray);

                SetCurrencyFormatForPeriod(ValuesArray, CurrencyFormat);
                
                ExchangeGainLossTable.SumValuesToPeriod(PeriodNo -1, EX_PreviousValuesArray);

                for Index := Low(EX_PreviousValuesArray) to High(EX_PreviousValuesArray) do
                begin
                  ValuesArray[Index] := ValuesArray[Index] - EX_PreviousValuesArray[Index];              
                end;

                //PrintValues
                PrintValuesForPeriod(ValuesArray, Debit);
              end 
              else
              begin
                //GetValues
                FUseBaseAmounts := False;

                GetOpeningBalancesForPeriod( pAcct, PeriodNo, ValuesArray);

                if MyClient.HasForeignCurrencyAccounts then
                  SetCurrencyFormatForPeriod(ValuesArray, CurrencyFormat);
                  
                //PrintValues
                PrintValuesForPeriod( ValuesArray, Debit);
              end;
            end
            else
               SkipPeriod;
          end;

          //1B. YTD Opening Balance
          if ClientForReport.clFields.clFRS_Show_YTD then
          begin
             //GetYTDValues
             GetOpeningBalancesForPeriod(pAcct, 1, ValuesArray);

             if MyClient.HasForeignCurrencyAccounts then
                SetCurrencyFormatForPeriod(ValuesArray, CurrencyFormat);

             //PrintValues
             PrintValuesForPeriod( ValuesArray, Debit);
          end;
          RenderDetailLine;

          //2A. Movement
          PutString( GetHeading( hdPlus_Movement ));
          for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do 
          begin
            if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then 
            begin
              if NonBaseCurrencyAccount then 
              begin
                FUseBaseAmounts := True;

                GetValuesForPeriod(pAcct, PeriodNo, ValuesArray);

                //PrintValues
                PrintValuesForPeriod(ValuesArray, Debit);
              end 
              else 
              begin
                //GetValues
                FUseBaseAmounts := False;
                GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
                //PrintValues
                PrintValuesForPeriod( ValuesArray, Debit);
              end;
            end
            else
               SkipPeriod;
          end;

          //2B. YTD Movement
          if ClientForReport.clFields.clFRS_Show_YTD then
          begin
             //GetYTDValues
             GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
             //PrintValues
             PrintValuesForPeriod( ValuesArray, Debit);
          end;

          RenderDetailLine;
          SingleUnderLine;

          //3A. Closing Balance
          PutString( GetHeading( hdClosing_Balance));

          for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do 
          begin
            if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then
            begin
              if NonBaseCurrencyAccount then
              begin
                FUseBaseAmounts := True;

                ExchangeGainLossTable.SumValuesToPeriod(PeriodNo -1, EX_PreviousValuesArray);

                GetClosingBalancesForPeriod(pAcct, PeriodNo, ValuesArray);

                for Index := Low(EX_PreviousValuesArray) to High(EX_PreviousValuesArray) do
                begin
                  ValuesArray[Index] := ValuesArray[Index] - EX_PreviousValuesArray[Index];
                end;

                PrintValuesForPeriod(ValuesArray, Debit);
              end
              else 
              begin
                { DONT CHECK THIS IN (START) }
                {
                NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
                SetLength( MovementTotals, NumOfTotals );
                SetLength( MV_ValuesArray, ColumnsPerPeriod);
                GetValuesForPeriod( pAcct, PeriodNo, MV_ValuesArray);
                for j := Low(MovementTotals) to High(MovementTotals) do
                  MovementTotals[j] := 0;
                for j := Low( MV_ValuesArray) to High( MV_ValuesArray) do
                  MovementTotals[TotalsArrayPos] := MovementTotals[TotalsArrayPos] + MV_ValuesArray[j];
                Inc(TotalsArrayPos);
                }
                { DONT CHECK THIS IN (END) }

                FUseBaseAmounts := False;
                GetClosingBalancesForPeriod( pAcct, PeriodNo, ValuesArray);
                //PrintValues (Actual closing balance)
                PrintValuesForPeriod(ValuesArray{MovementTotals}, Debit{, False}); // dont check this in
              end;
            end
            else
            begin
              SkipPeriod;
            end;
          end;

          //3B. YTD Closing Balance
          if ClientForReport.clFields.clFRS_Show_YTD then 
          begin
            if NonBaseCurrencyAccount then
            begin
              FUseBaseAmounts := True;
            
              //GetYTDValues
              GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);

              //PrintValues
              PrintValuesForPeriod( ValuesArray, Debit);
            end
            else
            begin
              //GetYTDValues
              FUseBaseAmounts := False;

              GetClosingBalancesForPeriod(pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);

              //PrintValues
              PrintValuesForPeriod( ValuesArray, Debit);
            end;
          end;

          RenderDetailLine;

          if NonBaseCurrencyAccount then
          begin
            //4A. Current period exchange gain/loss
            PutString(ForexLabel);

            FUseBaseAmounts := True;

            for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do 
            begin
              if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then 
              begin
                ExchangeGainLossTable.GetValuesForPeriod(PeriodNo, EX_ValuesArray);

                //PrintValues
                PrintValuesForPeriod(EX_ValuesArray, Credit);
              end 
              else
              begin
                SkipPeriod;
              end;
            end;

            //4B. YTD exchange gain/loss
            if ClientForReport.clFields.clFRS_Show_YTD then 
            begin
              ExchangeGainLossTable.SumValuesToPeriod(ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, EX_TotalValuesArray);
                        
              //PrintValues
              PrintValuesForPeriod(EX_TotalValuesArray, Credit);
            end;

            RenderDetailLine;

            //5A. Closing balance including exchange gain/loss
            PutString( GetHeading( hdClosing_Balance));
          
            ForexPreviousPeriods := 0;
            
            for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do 
            begin
              if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then
              begin
                ExchangeGainLossTable.SumValuesToPeriod(PeriodNo -1, EX_PreviousValuesArray);

                ExchangeGainLossTable.GetValuesForPeriod(PeriodNo, EX_ValuesArray);
                
                GetClosingBalancesForPeriod(pAcct, PeriodNo, ValuesArray);
            
                for Index := Low(ValuesArray) to High(ValuesArray) do
                begin
                  ValuesArray[Index] := ValuesArray[Index] - EX_PreviousValuesArray[Index] - EX_ValuesArray[Index];
                end;
              
                PrintValuesForPeriod(ValuesArray, Debit);
              end
              else
              begin
                SkipPeriod;
              end;
            end;

            //5B. YTD closing balance including exchange gain/loss
            if ClientForReport.clFields.clFRS_Show_YTD then 
            begin
              GetClosingBalancesForPeriod(pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
                        
              for Index := Low(EX_TotalValuesArray) to High(EX_TotalValuesArray) do
              begin
                ValuesArray[Index] := ValuesArray[Index] - EX_TotalValuesArray[Index];
              end;
            
              //PrintValues
              PrintValuesForPeriod(ValuesArray, Debit);
            end;

            RenderDetailLine;
          end;
        
          DoubleUnderLine;
        end; // if ShowThisAccount then begin
      end; // for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
    finally
      ExchangeGainLossTable.Free;
    end;
  end //detailed
  else
  begin
    //report is summarised, only show totals for report group
    //get totals, make enough space for the total for each period plus YTD
    //note: The size of the values array was set earlier to ColumnsPerPeriod
    NumOfTotals := ColumnsPerPeriod * (iVisiblePeriods + 1);
    SetLength( OpeningBalanceTotals, NumOfTotals );
    SetLength( MovementTotals,       NumOfTotals );
    SetLength( ClosingBalanceTotals, NumOfTotals );
    SetLength(ExchangeGainLossTotals, NumOfTotals);
    SetLength(ClosingBalanceTotalsIncForex, NumOfTotals);

    SetLength( OB_ValuesArray, ColumnsPerPeriod);
    SetLength( MV_ValuesArray, ColumnsPerPeriod);
    SetLength( CB_ValuesArray, ColumnsPerPeriod);
    SetLength( EX_ValuesArray, ColumnsPerPeriod);
    SetLength( EX_PreviousValuesArray, ColumnsPerPeriod);
    
    //clear totals
    for i := Low(OpeningBalanceTotals) to High(OpeningBalanceTotals) do begin
       OpeningBalanceTotals[i] := 0;
       MovementTotals[i]       := 0;
       ClosingBalanceTotals[i] := 0;
       ExchangeGainLossTotals[i] := 0;
       ClosingBalanceTotalsIncForex[i] := 0;
    end;

    RenderTextLine('');

    sSectionHeading := GetHeading( hdCashbook_Balances) + ' Summary';
    if sSectionHeading <> '' then
      RenderTitleLine( sSectionHeading);

    FoundForexAccount := False;

    //cycle thru accounts, load values into array
    for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
      pAcct :=FRptParameters.Chart.Account_At(i);

      //see if should show this account
      ShowThisAccount := ( pAcct^.chAccount_Type in [ atBankAccount]) and
                         ( pAcct^.chTemp_Include_In_Report);

      if ShowThisAccount then begin
        //add values for this accounts to the totals
        TotalsArrayPos := 0;

        NonBaseCurrencyAccount := NonBaseCurrencyContra(pAcct.chAccount_Code, ForexLabel);
        
        if NonBaseCurrencyAccount then
        begin
          FoundForexAccount := True;

          FUseBaseAmounts := True;
        end
        else
        begin
          FUseBaseAmounts := False;
        end;

        for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
          
            //GetValues
            GetOpeningBalancesForPeriod( pAcct, PeriodNo, OB_ValuesArray);
            GetValuesForPeriod(          pAcct, PeriodNo, MV_ValuesArray);
            GetClosingBalancesForPeriod( pAcct, PeriodNo, CB_ValuesArray);
            GetExchangeGainLossForPeriod(pAcct, PeriodNo, EX_ValuesArray);

            ForexPreviousPeriods := 0;
            if NonBaseCurrencyAccount then
            begin
              GetYTD_ExchangeGainLoss(pAcct, PeriodNo -1, EX_PreviousValuesArray);

              for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do
              begin
                OpeningBalance := OB_ValuesArray[j] - EX_PreviousValuesArray[j];
                ClosingBalance := CB_ValuesArray[j] - EX_PreviousValuesArray[j];

                OpeningBalanceTotals[TotalsArrayPos] := OpeningBalanceTotals[TotalsArrayPos] + OpeningBalance;

                MovementTotals[TotalsArrayPos] := MovementTotals[TotalsArrayPos] + MV_ValuesArray[j];

                ClosingBalanceTotals[TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] + ClosingBalance;

                ExchangeGainLossTotals[TotalsArrayPos] := ExchangeGainLossTotals[TotalsArrayPos] - EX_ValuesArray[j];

                ClosingBalanceTotalsIncForex[TotalsArrayPos] := ClosingBalanceTotalsIncForex[TotalsArrayPos] + ClosingBalance - EX_ValuesArray[j];

                Inc(TotalsArrayPos);
              end;
            end
            else
            begin
              //Add account values to report group total
              for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do begin
                 OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] + OB_ValuesArray[j];
                 MovementTotals[ TotalsArrayPos]       := MovementTotals[ TotalsArrayPos]       + MV_ValuesArray[j];
                 ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] + CB_ValuesArray[j];
                 ClosingBalanceTotalsIncForex[TotalsArrayPos] := ClosingBalanceTotalsIncForex[TotalsArrayPos] + CB_ValuesArray[j];
                 Inc(TotalsArrayPos);
              end;
            end;
          end
          else
            Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;

        //add YTD values to totals
        GetOpeningBalancesForPeriod( pAcct, 1, OB_ValuesArray);
        GetYTD_ValuesForPeriod(      pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, MV_ValuesArray);
        GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, CB_ValuesArray);
        GetYTD_ExchangeGainLoss(pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, EX_ValuesArray);

        //Add account values to report group total
        for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do
        begin
           OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] + OB_ValuesArray[j];
           MovementTotals[ TotalsArrayPos]       := MovementTotals[ TotalsArrayPos]       + MV_ValuesArray[j];
           ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] + CB_ValuesArray[j];

           if NonBaseCurrencyAccount then
           begin
             ExchangeGainLossTotals[TotalsArrayPos] := ExchangeGainLossTotals[TotalsArrayPos] - EX_ValuesArray[J];
           end;

           if not (ColumnTypes[J] in [ftFullPeriodBudget, ftBudgetRemaining]) then
           begin
             ClosingBalanceTotalsIncForex[TotalsArrayPos] := ClosingBalanceTotals[TotalsArrayPos] + ExchangeGainLossTotals[TotalsArrayPos];
           end;

           Inc(TotalsArrayPos);
        end;
      end;
    end;

    //now check to see if budgeted opening balance figures should be used
    //currently the user can only specify one opening balance figures for all
    //bank accounts, therefore this amount must be added into the totals
    //after the accounts have been summed up.
    //must match name and start date in case of duplicate names
    Budget := nil;
    for i := 0 to Pred(ClientForReport.clBudget_List.ItemCount) do
    begin
      Budget := ClientForReport.clBudget_List.Budget_At(i);
      if (Budget.buFields.buName = ClientForReport.clFields.clTemp_FRS_Budget_To_Use) and
         (Budget.buFields.buStart_Date = ClientForReport.clFields.clTemp_FRS_Budget_To_Use_Date) then
         Break
      else
        Budget := nil;
    end;


    if ( Assigned( Budget)) then begin
      TotalsArrayPos := 0;
      BudgetedOpeningBalance := Budget.buFields.buEstimated_Opening_Bank_Balance;

      for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
        if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
          //Add account values to report group total
          for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do begin
            //see if should add to this column
            if ((ColumnTypes[ j] in [ftActual, ftVariance])and (ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use < 0 ))
            or (ColumnTypes[ j] in [ftcomparative]) then begin
              OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] - BudgetedOpeningBalance;
              ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] - BudgetedOpeningBalance;
              ClosingBalanceTotalsIncForex[TotalsArrayPos] := ClosingBalanceTotalsIncForex[TotalsArrayPos] - BudgetedOpeningBalance;
            end;
            Inc(TotalsArrayPos);
          end;
        end
        else
          Inc(TotalsArrayPos, ColumnsPerPeriod);
      end;

      //now add YTD totals
      for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do begin
        //see if should add to this column
        if ((ColumnTypes[ j] in [ftActual, ftVariance])and (ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use < 0 ))
        or (ColumnTypes[ j] in [ftcomparative]) then begin
           OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] - BudgetedOpeningBalance;
           ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] - BudgetedOpeningBalance;
           ClosingBalanceTotalsIncForex[TotalsArrayPos] := ClosingBalanceTotalsIncForex[TotalsArrayPos] - BudgetedOpeningBalance;
        end;
        Inc(TotalsArrayPos);
      end;

      ActualPos := -1;
      VariancePos := -1;
      BudgetPos := -1;

      for j := Low(ColumnTypes) to High(ColumnTypes) do
      begin
        if ColumnTypes[j] = ftActual then
        begin
          ActualPos := j;
        end
        else
        if ColumnTypes[j] = ftVariance then
        begin
          VariancePos := j;
        end
        else
        if ColumnTypes[j] = ftComparative then
        begin
          BudgetPos := j;
        end;
        
        if (ActualPos > -1) and (VariancePos > -1) and (BudgetPos > -1) then
        begin
          Break;
        end;
      end;
                                 
      if (ActualPos > -1) and (VariancePos > -1) and (BudgetPos > -1) then
      begin
        TotalsArrayPos := 0;

        while TotalsArrayPos < NumOfTotals do
        begin
          OpeningBalanceTotals[VariancePos + TotalsArrayPos] := OpeningBalanceTotals[ActualPos + TotalsArrayPos] - OpeningBalanceTotals[BudgetPos + TotalsArrayPos];
          ClosingBalanceTotals[VariancePos + TotalsArrayPos] := ClosingBalanceTotals[ActualPos + TotalsArrayPos] - ClosingBalanceTotals[BudgetPos + TotalsArrayPos];
          ClosingBalanceTotalsIncForex[VariancePos + TotalsArrayPos] := ClosingBalanceTotalsIncForex[ActualPos + TotalsArrayPos] - ClosingBalanceTotalsIncForex[BudgetPos + TotalsArrayPos];

          Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;
      end;
    end;

    //now print results, need to load values back into a value array for printing
    PrintTotalsArray( GetHeading( hdOpening_Balance), OpeningBalanceTotals, Debit, siSectionTotal);
    PrintTotalsArray( GetHeading( hdPlus_Movement), MovementTotals, Debit, siSectionTotal);

    RequireLines(3);
    SingleUnderline;
    PrintTotalsArray( GetHeading( hdClosing_Balance), ClosingBalanceTotals, Debit, siSectionTotal);

    //***** FOREX ACCOUNTS ONLY *****
    if FoundForexAccount then
    begin
      PrintTotalsArray( GetHeading( hdExchangeGainLoss), ExchangeGainLossTotals, Debit, siSectionTotal);
      PrintTotalsArray( GetHeading( hdClosing_Balance), ClosingBalanceTotalsIncForex, Debit, siSectionTotal);
    end // if FoundForexAccount;
    else
    begin
      PrintValuesForPeriod( ValuesArray, Debit);
    end;

    DoubleUnderline;

    ClearAllTotals;
  end;
  FUseBaseAmounts := False;
end;

function TCashflowReportEx.AccountNeedsPrinting( pAcct: pAccount_Rec): boolean;
//needs printing if has values if any period that is visible, including ytd
var
  i           : integer;
  ValuesArray : TValuesArray;
  PeriodNo    : integer;
begin
  result := false;

  if pAcct^.chAccount_Type = atBankAccount then
  begin
    SetLength( ValuesArray, ColumnsPerPeriod);

    //see if anything in periodic columns
    for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
      if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
        //GetValues
        Result := GetClosingBalancesForPeriod( pAcct, PeriodNo, ValuesArray);
        //see if anything there
        for i := Low( ValuesArray) to High( ValuesArray) do
          if ValuesArray[i] <> 0 then begin
            result := true;
            Exit;
          end;
      end;
    end;

    //Period YTD Information
    if ClientForReport.clFields.clFRS_Show_YTD then
    begin
      //GetYTDValues
      Result := Result or GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
      //see if anything there
      for i := Low( ValuesArray) to High( ValuesArray) do
        if ValuesArray[i] <> 0 then begin
          result := true;
          Exit;
        end;
    end;
  end
  else
    result := inherited AccountNeedsPrinting( pAcct);
end;

function TCashflowReportEx.GetOpeningBalanceAmount(Code: string; IsStartOfFinancialYear: boolean;
                                                   PeriodNo: integer): Money;
var
  AccountInfo: TAccountInformation;
  Bal, ForexBal: Money;
  i: integer;
begin
  AccountInfo := TAccountInformation.Create(ClientForReport);
  try
    AccountInfo.UseBudgetIfNoActualData     := False;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode := Code;
    AccountInfo.UseBaseAmounts := True;
    if (IsStartOfFinancialYear) then // If start date = financial year start then just get opening bal
      Bal := AccountInfo.OpeningBalanceActualOrBudget(1)
    else
    begin
      Bal := AccountInfo.ClosingBalanceActualOrBudget(1); // else opening bal at last financial year start + movement up to previous day
    end;
  finally
    AccountInfo.Free;
  end;
  Result := Bal;
end;

procedure TCashflowReportEx.SetBaseAmounts(const pAcct : pAccount_Rec; var BaseAmounts: TBaseAmounts);
var
  i: integer;
  PeriodNo: integer;
  PeriodCount: integer;
  ColumnCount: integer;
  OpeningBalanceExchangeRate, ClosingBalanceExchangeRate: double;
  LastYear, IsStartOfFinancialYear, NonBaseCurrencyAccount: Boolean;
  AccountInfo: TAccountInformation;
  ForexLabel: string;
  TestStr: string;
  iVarianceCol: integer;
begin
  FUseBaseAmounts := True;
  PeriodCount := MaxPeriodToShow + 1; //zero base array but periods start at 1?
  ColumnCount := Length(ColumnTypes);

  //Set width - no need to nil afterward
  SetLength(BaseAmounts.OpeningBalance, PeriodCount, ColumnCount);
  SetLength(BaseAmounts.Movement, PeriodCount, ColumnCount);
  SetLength(BaseAmounts.ClosingBalance, PeriodCount, ColumnCount);
  SetLength(BaseAmounts.ForexGainLoss, PeriodCount, ColumnCount);
  SetLength(BaseAmounts.ClosingBalanceWithGainLoss, PeriodCount, ColumnCount);

  with BaseAmounts do begin
    for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
      if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin

        //1. Opening balances
        FUseBaseAmounts := True;
        GetOpeningBalancesForPeriod(pAcct, PeriodNo, OpeningBalance[PeriodNo]);
        for i := Low(OpeningBalance[PeriodNo]) to High(OpeningBalance[PeriodNo]) do begin
          //Get opening balance exchange rate for each period
          LastYear := i > 0;
          IsStartOfFinancialYear :=
            (ClientForReport.clFields.clTemp_Period_Details_This_Year[PeriodNo].Period_Start_Date =
             ClientForReport.clFields.clFinancial_Year_Starts);
        end;

        //2. Movement
        GetValuesForPeriod( pAcct, PeriodNo, Movement[PeriodNo]);
        //Calculate variance
        iVarianceCol := GetIndexFromColumnType(ftVariance);
        if (iVarianceCol <> -1) then
            Movement[PeriodNo, iVarianceCol] := -(Movement[PeriodNo, integer(ftComparative)] -
                                                         Movement[PeriodNo, integer(ftActual)]);

        //3. Closing balances
        FUseBaseAmounts := False;
        GetClosingBalancesForPeriod( pAcct, PeriodNo, ClosingBalance[PeriodNo]);
        FUseBaseAmounts := True;
        for i := Low(ClosingBalance[PeriodNo]) to High(ClosingBalance[PeriodNo]) do
          ClosingBalance[PeriodNo, i] := OpeningBalance[PeriodNo, i] + Movement[PeriodNo, i];

        //4. Closing balances with forex gain/loss
        FUseBaseAmounts := False;
        GetClosingBalancesForPeriod( pAcct, PeriodNo, ClosingBalanceWithGainLoss[PeriodNo]);
        FUseBaseAmounts := True;
        for i := Low(ClosingBalanceWithGainLoss[PeriodNo]) to High(ClosingBalanceWithGainLoss[PeriodNo]) do begin
          //Get closing balance exchange rate for each period
          LastYear := i > 0;
          ClosingBalanceExchangeRate := GetExchangeRateForForexContra(pAcct.chAccount_Code, PeriodNo, True, LastYear);

          if (i = integer(ftVariance)) then
            ClosingBalanceWithGainLoss[PeriodNo, i] := -(ClosingBalanceWithGainLoss[PeriodNo, integer(ftComparative)] -
                                                         ClosingBalanceWithGainLoss[PeriodNo, integer(ftActual)])
          else if ClosingBalanceExchangeRate > 0 then
            ClosingBalanceWithGainLoss[PeriodNo, i] := Double2Money(Money2Double(ClosingBalanceWithGainLoss[PeriodNo, i]) / ClosingBalanceExchangeRate);
        end;

        //5. Forex gain/loss
        for i := Low(OpeningBalance[PeriodNo]) to High(OpeningBalance[PeriodNo]) do
          ForexGainLoss[PeriodNo, i] :=  ClosingBalanceWithGainLoss[PeriodNo, i] - ClosingBalance[PeriodNo, i];
      end;
    end;
  end;
end;

procedure TCashflowReportEx.SetupColumnsTypes;
begin
  ClearColumnTypeArray;
  //Assume that the first column will always be actual values
  AddColumnTypeToArray( ftActual);
  with ClientForReport, clFields do begin
    if ( clFRS_Compare_Type in [ cflCompare_To_Budget, cflCompare_To_Last_Year]) then begin
      AddColumnTypeToArray( ftComparative);
      if clFRS_Show_Variance then
         AddColumnTypeToArray( ftVariance);
    end;
    if clFRS_Show_Quantity then
    begin
      if not (clTemp_FRS_Use_Budget_Quantities) then
        AddColumnTypeToArray( ftQuantity)
      else
      begin
        AddColumnTypeToArray( ftBudgetQuantity);
        AddColumnTypeToArray( ftBudgetUnitPrice);
      end;
    end;
    //if we're only showing budget and are showing quantity, use different columns

    if clFRS_Report_Style = crsBudgetRemaining then begin
       AddColumnTypeToArray( ftFullPeriodBudget);
       AddColumnTypeToArray( ftBudgetRemaining);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure VerifyCashflowPreconditions( ForClient : TClientObj);
begin
   //Check parameters, no need to check booleans
   with ForClient.clFields do begin
     //Persistant Fields
       //clGST_Inclusive_Cashflow
       //clFRS_Print_Chart_Codes
       //clFRS_Show_YTD
       //clFRS_Show_Variance
       //clFRS_Prompt_User_to_use_Budgeted_figures

       Assert( clFRS_Compare_Type in [cflCompare_None, cflCompare_To_Budget, cflCompare_To_Last_Year],
               'clFRS_Compare_Type in [cflCompare_None, cflCompare_To_Budget, cflCompare_To_Last_Year]');
       Assert( clFRS_Reporting_Period_Type in [frpWeekly..frpMax],
               'clFRS_Reporting_Period_Type in [frpWeekly..frpMax]');
       Assert( clFRS_Report_Style in [crsMin..crsMax],
               'clFRS_Report_Style in [crsMin..crsMax]');
       Assert( clReporting_Year_Starts > 0,
               'clReporting_Year_Starts > 0');
       Assert( clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised],
               'clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised]');
     //Non-persistant fields
       Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]],
               'clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]');
       Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions],
               'clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]');
       if (clFRS_Reporting_Period_Type = frpCustom) then begin
         Assert( clTemp_FRS_From_Date > 0,
                 'clTemp_FRS_From_Date > 0');
         Assert( clTemp_FRS_To_Date > 0,
                 'clTemp_FRS_To_Date > 0');
       end;
       Assert( clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show,
               'clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show');

       //clTemp_FRS_Budget_To_Use
       //clTemp_FRS_Account_Totals_Cash_Only
       //clTemp_FRS_Use_Budgeted_Data_If_No_Actual_Data

     //The following fields are filled automatically by the CalculateAccountTotals routine
       //clTemp_Period_Details_This_Year
       //clTemp_Period_Details_Last_Year
       //clTemp_Periods_This_Year
       //clTemp_Periods_Last_Year
       //clTemp_Last_Period_Of_Actual_Data
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetAmountFormats(const RoundValues: Boolean; var NumberFormatStr, TotalFormatStr: string; var DescriptionWidth: double);
begin
  if MyClient.clfields.clFRS_Report_Style in [crsSinglePeriod, crsBudgetRemaining] then
  begin
    if RoundValues then
    begin
      NumberFormatStr  := '#,##0;(#,##0);-';
      TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
    end else
    begin
      NumberFormatStr  := '#,##0.00;(#,##0.00);-';
      TotalFormatStr   := '#,##0.00;(#,##0.00);-';   //note:sign is reversed
    end;
    DescriptionWidth := 22.0;
  end else
  begin
     NumberFormatStr  := '#,##0;(#,##0);-';
     TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
     DescriptionWidth := 13.0;
  end;
end;


procedure ListCashflow(Sender : TObject);
var
  i: integer;
  DivisionIdx: integer;
  DivisionArray: DynamicBooleanArray;
  DivisionTitle: string;
  CashFlowReport: TCashFlowReportEx;
  ReportCount: integer;
  lClient: TClientObj;
  NumberFormatStr, TotalFormatStr: string;
  DescriptionWidth: Double;

  procedure DoOutput(aCashFlowReport: TCashFlowReportEx);
  begin
    with TCashflowReportEx(Sender) ,MyClient, MyClient.clFields do begin
      if ReportSectionNeedsPrinting( [ atIncome, atDirectExpense, atPurchases, atExpense]) then
      begin
         //Income
        PrintSection( [atIncome], hdIncome, hdTotal_Income, Credit);
        //Direct Expenses
        if ReportSectionNeedsPrinting( [atDirectExpense, atPurchases]) then begin
          PrintSection( [atDirectExpense, atPurchases], hdLess_Direct_Expenses, hdTotal_Direct_Expenses, Debit);
          //Gross Profit
          RenderDetailRunningTotal( GetHeading( hdGross_Profit_Or_Loss ) , Credit);
        end;
        //Expenses
        PrintSection( [atExpense], hdLess_Expenses, hdTotal_Expenses, Debit);

        //Operating Profit - only show if has section(s) below it
        if ReportSectionNeedsPrinting( [atOtherIncome,
                                        atUnknownCR,
                                        atClosingStock,
                                        atOtherExpense,
                                        atUnknownDR,
                                        atOpeningStock] +
                                        BalanceSheetReportGroupsSet - [ atBankAccount] ) then begin
           RenderDetailRunningTotal( GetHeading( hdNet_Trading_Profit_Or_Loss ) , Credit);
        end;
      end;

      //Other deposits, withdrawls
      if ReportSectionNeedsPrinting( [atOtherIncome, atUnknownCR, atClosingStock]) then
        PrintSection( [atOtherIncome, atUnknownCR, atClosingStock], hdPlus_Other_Deposits, hdTotal_Other_Deposits, Credit);
      if ReportSectionNeedsPrinting( [atOtherExpense, atUnknownDR, atOpeningStock]) then
        PrintSection( [atOtherExpense, atUnknownDR, atOpeningStock], hdLess_Other_Withdrawals, hdTotal_Other_Withdrawals, Debit);
      //capital development
      if ReportSectionNeedsPrinting( BalanceSheetReportGroupsSet - [ atEquity, atGSTPayable, atGSTReceivable, atBankAccount]) then
        PrintSection( BalanceSheetReportGroupsSet - [ atEquity, atGSTPayable, atGSTReceivable, atBankAccount], hdLess_Capital_Development, hdTotal_Capital_Development, Debit);
      //equity
      if ReportSectionNeedsPrinting( [atEquity]) then
        PrintSection( [atEquity], hdLess_Equity, hdTotal_Equity, Debit);
      //GST
      if ReportSectionNeedsPrinting( [ atGSTPayable, atGSTReceivable]) then
        PrintSection( [atGSTPayable, atGSTReceivable], hdGST_Movements, hdNet_GST, Credit);
      //Uncoded items
      if ReportSectionNeedsPrinting( [atUncodedCR]) then
        PrintSection( [atUncodedCR], hdUncoded_Deposits, -1, Credit);
      if ReportSectionNeedsPrinting( [atUncodedDR]) then
        PrintSection( [atUncodedDR], hdUncoded_Withdrawals, -1, Debit);

      //Net Cash Movement
      RenderDetailGrandTotal( GetHeading( hdNet_Cash_Movement_In_Out), Credit);

      //Cash on Hand Section
      if ReportSectionNeedsPrinting( [ atBankAccount]) then
        PrintCashOnHandSection;
    end;
  end;

begin
  CashFlowReport := TCashFlowReportEx(Sender);
  CashFlowReport.ResetControlAccounts;
  CashFlowReport.FUseBaseAmounts := False;

  //Reset amount column format for printing (may have been changed by SetCurrencyFormatForPeriod)
  SetAmountFormats(CashFlowReport.ReportTypeParams.RoundValues, NumberFormatStr, TotalFormatStr, DescriptionWidth);
  for i := CashFlowReport.Columns.First to CashFlowReport.Columns.Last do
  begin
    if i <= High(CashFlowReport.FColumnTypes) then
    begin
      if not (CashFlowReport.FColumnTypes[i] in [ftQuantity, ftBudgetQuantity, ftPercentage]) then
      begin
        CashFlowReport.Columns.Report_Column_At(CashFlowReport.FCurrDetail.Count + i).FormatString := NumberFormatStr;
        CashFlowReport.Columns.Report_Column_At(CashFlowReport.FCurrDetail.Count + i).TotalFormat := TotalFormatStr;
      end;
    end
    else
    begin
      CashFlowReport.Columns.Report_Column_At(CashFlowReport.FCurrDetail.Count + i).FormatString := NumberFormatStr;
      CashFlowReport.Columns.Report_Column_At(CashFlowReport.FCurrDetail.Count + i).TotalFormat := TotalFormatStr;
    end;
  end;

  lClient := CashFlowReport.ClientForReport;

  with lClient.clFields do
  begin
    if clTemp_FRS_Split_By_Division then
    begin
      //Separate report for each division
      ReportCount := 0;
      DivisionArray := clTemp_FRS_Divisions;
      for DivisionIdx := 0 to Length(DivisionArray) - 1 do
      begin
        TCashflowReportEx(Sender).ClearSubTotals;
        if DivisionArray[DivisionIdx] then
        begin
          clTemp_FRS_Division_To_Use := DivisionIdx;
          CalculateAccountTotals.CalculateAccountTotalsForClient( lClient, True, nil, -1, False, False, True, True);
          CalculateAccountTotals.EstimateOpeningBalancesForBankAccountContras( MyClient);
          CashFlowReport.ResetControlAccounts;
          CashFlowReport.LoadAccountsToPrint;
          CashFlowReport.ClearRunningTotals;
          if ReportCount > 0 then
            CashFlowReport.ReportNewPage;
          DivisionTitle := CashFlowReport.GetDivisionSubHeading(DivisionIdx);
          CashFlowReport.RenderTextLine(DivisionTitle, True, False);
          DoOutput(CashFlowReport);
          Inc(ReportCount);
        end
      end;
    end
    else
      //Single report for selected division(s)
      DoOutput(CashFlowReport);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function HasOpenAndCloseBalanceExchangeRates(const aClient: TClientObj; var FromDate, ToDate: integer): Boolean;
var
  i, j: integer;
  BA: TBank_Account;
  TempDate: integer;
  MissingDates: TStringList;
  This_Year_Starts  : integer;
  This_Year_Ends    : integer;
  Last_Year_Starts  : integer;
  Last_Year_Ends    : integer;

  procedure CheckDate(ADate: integer);
  begin
    if ADate > 0 then begin
      if (BA.Default_Forex_Conversion_Rate(ADate) = 0) then
        if MissingDates.IndexOf(BKDateUtils.Date2Str(ADate, 'dd/mm/YYYY')) = -1  then
          MissingDates.Add(BKDateUtils.Date2Str(ADate, 'dd/mm/YYYY'));
      Result := Result and (BA.Default_Forex_Conversion_Rate(ADate) > 0);
      if ADate < FromDate then
        FromDate := ADate;
    end;
  end;

begin
  //Get start and end dates
  CalculateAccountTotals.CalcYearStartEndDates(aClient, This_Year_Starts, This_Year_Ends, Last_Year_Starts, Last_Year_Ends);
  //Setup period arrays
  PeriodUtils.LoadPeriodDetailsIntoArray(aClient,
                                         This_Year_Starts,
                                         This_Year_Ends,
                                         aClient.clFields.clTemp_FRS_Account_Totals_Cash_Only,
                                         aClient.clFields.clFRS_Reporting_Period_Type,
                                         aClient.clFields.clTemp_Period_Details_This_Year);
  PeriodUtils.LoadPeriodDetailsIntoArray(aClient,
                                         Last_Year_Starts,
                                         Last_Year_Ends,
                                         aClient.clFields.clTemp_FRS_Account_Totals_Cash_Only,
                                         aClient.clFields.clFRS_Reporting_Period_Type,
                                         aClient.clFields.clTemp_Period_Details_Last_Year);
  //Set from and to dates
  ToDate := aClient.clFields.clTemp_Period_Details_This_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
  if aClient.clFields.clFRS_Report_Style = crsSinglePeriod then begin
    FromDate := aClient.clFields.clTemp_Period_Details_This_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
    if (aClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year) then
      FromDate := aClient.clFields.clTemp_Period_Details_Last_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
  end else begin
    FromDate := aClient.clFields.clTemp_Period_Details_This_Year[1].Period_Start_Date;
    if (aClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year) then
      FromDate := aClient.clFields.clTemp_Period_Details_Last_Year[1].Period_Start_Date;
  end;

  if This_Year_Starts < FromDate then
    FromDate := This_Year_Starts;

  MissingDates := TStringList.Create;
  try
    Result := True;
    //Check that we have exchange rates for the start and end of each period in the report.
    for i := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do begin
      BA := aClient.clBank_Account_List.Bank_Account_At(i);
      if (BA.IsAForexAccount) and (BA.baFields.baTemp_Include_In_Report) then begin
        //Check dates for EstimateOpeningBalancesForBankAccountContras
        CheckDate(This_Year_Starts);
        if (aClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year) then
          CheckDate(Last_Year_Starts);
        if aClient.clFields.clFRS_Report_Style = crsSinglePeriod then begin
          //Single period
          TempDate := aClient.clFields.clTemp_Period_Details_This_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
          CheckDate(TempDate);
          TempDate := aClient.clFields.clTemp_Period_Details_This_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
          CheckDate(TempDate);
        end else begin
          //Multiple period
          for j := 1 to aClient.clFields.clTemp_FRS_Last_Period_To_Show do begin
            //Open date
            TempDate := aClient.clFields.clTemp_Period_Details_This_Year[j].Period_Start_Date;
            CheckDate(TempDate);
            //Close close
            TempDate := aClient.clFields.clTemp_Period_Details_This_Year[j].Period_End_Date;
            CheckDate(TempDate);
          end;
        end;
        //Check exchange rates for last year if comparing to last year
        if (aClient.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year) then begin
          if aClient.clFields.clFRS_Report_Style = crsSinglePeriod then begin
            //Single period
            TempDate := aClient.clFields.clTemp_Period_Details_Last_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
            CheckDate(TempDate);
            TempDate := aClient.clFields.clTemp_Period_Details_Last_Year[aClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
            CheckDate(TempDate);
          end else begin
            //Multiple period
            for j := 1 to aClient.clFields.clTemp_FRS_Last_Period_To_Show do begin
              //Open date
              TempDate := aClient.clFields.clTemp_Period_Details_Last_Year[j].Period_Start_Date;
              CheckDate(TempDate);
              //Close close
              TempDate := aClient.clFields.clTemp_Period_Details_Last_Year[j].Period_End_Date;
              CheckDate(TempDate);
            end;
          end;
        end;
      end;
    end;
    if not Result then
      HelpfulInfoMsg('The report could not be run because there are missing exchange rates ' +
                     'for the following opening or closing balance dates.' + #10#10 + MissingDates.Text, 0);
  finally
    MissingDates.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoCashflowEx( Destination : TReportDest;
                        AReportType: Integer;
                        RptBatch : TReportBase = nil);
var
   Job : TCashflowReportEx;
   i   : integer;
   cWidth : double;
   cLeft  : double;
   cGap   : double;

   ReportSettingsID : string;
   s                : string;

   TotalPeriodCols  : integer;
   TotalYTDCols     : integer;
   TotalCols        : integer;
   PeriodStartDate  : integer;
   PeriodEndDate    : integer;

   ReportScaleFactor : double;

   NumberFormatStr   : string;
   TotalFormatStr    : string;
   DescriptionWidth  : double;

   QuantityStr       : string;
   aColumn           : TReportColumn;

   BudgetedPeriodsUsed : boolean;
   lParams : TRptParameters;
   FromDate, ToDate: integer;
   ISOCodes: string;
begin
   //check pre conditions
   VerifyCashflowPreconditions( MyClient);

   //FOREX
   //Check exchange rates exist for all opening and closing balance dates for
   //all periods in the report, including previous year if comparing fiqures
   if not HasOpenAndCloseBalanceExchangeRates(MyClient, FromDate, ToDate) then begin
     Exit;
   end;
   //Check exchange rates exist for all transactions in the report
   if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, False) then begin
     HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
     Exit;
   end;

   case MyClient.clFields.clFRS_Report_Style of
      crsSinglePeriod, crsBudgetRemaining   : ReportSettingsID := Report_List_Names[REPORT_CASHFLOW_SINGLE];
      crsMultiplePeriod : ReportSettingsID := Report_List_Names[REPORT_CASHFLOW_MULTIPLE];
   else
      ReportSettingsID := Report_List_Names[REPORT_CASHFLOW_MULTIPLE];
   end;
   ReportSettingsID := ReportID(ReportSettingsID,RptBatch);

   MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only := true;
   CalculateAccountTotals.AddAutoContraCodes( MyClient);
   try
      CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, False, True, True);
      // CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient);
      CalculateAccountTotals.EstimateOpeningBalancesForBankAccountContras( MyClient);
      SetDateOfFirstMovement( MyClient);
      
      //build the report
      With MyClient, clFields do
      Begin
        if Destination = rdNone then Destination := rdScreen;
        lParams := TRptParameters.Create(AReportType,MyClient,RptBatch,dPeriod{ Not DNone});
        Job := TCashflowReportEx.Create( MyClient, lParams);
        try
          Job.LoadReportSettings(UserPrintSettings, ReportSettingsID);

          AddCommonHeader(Job);

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          // Build header
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          s := GetCFHeading(MyClient, hdCash_Flow);
          if clFRS_Report_Style = crsBudgetRemaining then
            s := s + ' - Budget Remaining ' + GetGSTString(MyClient)
          else
            s := s + ' - ' + frpNames[ clFRS_Reporting_Period_Type] + ' ' + GetGSTString(MyClient);

          if clTemp_FRS_Last_Actual_Period_To_Use < 0 then
            s := 'BUDGETED ' + s;

          if clFRS_Reporting_Period_Type = frpCustom then begin
             s := s + ' ' + bkDate2Str(clTemp_FRS_From_Date ) + ' - ' + bkDate2Str(clTemp_FRS_To_Date );
             lParams.FromDate := clTemp_FRS_From_Date;
             lParams.ToDate := clTemp_FRS_To_Date;
          end else  begin
             s := s + ' ' + StDateToDateString('NNN yyyy', clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date, true);
             lParams.FromDate := clTemp_FRS_From_Date;
             lParams.ToDate := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date;
          end;

          AddJobHeader(Job,siTitle,S,true,jtCenter, True);

          if clTemp_FRS_Job_To_Use <> '' then begin
             S :=  MyClient.clJobs.JobName(clTemp_FRS_Job_To_Use);
             if S > '' then
               S := ', ' + S;
             S := 'For Job: ' + clTemp_FRS_Job_To_Use + S;
             AddJobHeader(Job,siSubtitle,S,true);
          end;

          if ( clTemp_FRS_Division_To_Use in [1..glConst.Max_Divisions]) then
          begin
            //Single Division
            s := Job.GetDivisionSubHeading(clTemp_FRS_Division_To_Use);
            AddJobHeader(Job,siSubTitle,S,true);
          end
          else
          if (Length(clTemp_FRS_Divisions) > 0) and
            (not clTemp_FRS_Split_By_Division) then
          begin
            //Multiple Divisions
            s := Job.GetDivisionSubHeading;
            // may have to wrap text if there are lots of divisions
            AddJobHeader(Job,siSubTitle,S,true, jtCenter, true);
          end;

          if (clBudget_List.Find_Name( clTemp_FRS_Budget_To_Use) <> nil)
            and ((clFRS_Compare_Type  = cflCompare_To_Budget) or (clTemp_FRS_Use_Budgeted_Data_If_No_Actual)) then
          begin
            AddJobHeader(Job,siSubtitle, 'Using Budget: ' + clTemp_FRS_Budget_To_Use + ' (' + bkDate2Str( clTemp_FRS_Budget_To_Use_Date) + ')', true);
          end;

          AddJobHeader( Job, siSubtitle, '', true);

          //figure out how many columns there will be
          TotalPeriodCols := Job.iVisiblePeriods * Job.ColumnsPerPeriod;

          if clFRS_Show_YTD then
            TotalYTDCols := Job.ColumnsPerPeriod
          else
            TotalYTDCols := 0;

          //auto calculate width
          TotalCols := TotalPeriodCols + TotalYTDCols;

          SetAmountFormats(Job.ReportTypeParams.RoundValues, NumberFormatStr, TotalFormatStr, DescriptionWidth);
          QuantityStr        := '#.####;(#.####); ';

          //decide on the report scaling factor.  This attempts to automatically
          //reduce the font size to make the columns large enough to contain
          //data

          ReportScaleFactor := 1.0;
          if TotalCols > 13 then begin
            ReportScaleFactor := ( 13 / (TotalCols + 1));


            if ReportScaleFactor > 1.0 then
              ReportScaleFactor := 1.0;

            if ReportScaleFactor < 0.05 then
              ReportScaleFactor := 0.05;
          end;

          cGap := GcGap;
          Job.ReportScaleFactor := ReportScaleFactor;  //font will be adjusted during Generate

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          //Set up columns for this report
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          cLeft := GcLeft;
          AddColAuto( Job, cleft , DescriptionWidth * ReportScaleFactor,cGap ,'', jtLeft);          //account column
          cWidth := ( (99.5 - cLeft) / ( TotalCols)) - cGap;

          cWidth := Min(cWidth, 25);

          BudgetedPeriodsUsed := false;
          //Add period columns
          for i := 1 to ( Job.iVisiblePeriods) do begin
            if clFRS_Report_Style in [crsSinglePeriod] then begin
               PeriodStartDate := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
               PeriodEndDate   := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date;
            end
            else begin
              //get period dates, there is a chance that the no of periods in each
              //year may be different, so need to make sure we are getting dates
              //for the correct period
              if i <= clTemp_Periods_This_Year then begin
                 PeriodStartDate := clTemp_Period_Details_This_Year[i].Period_Start_Date;
                 PeriodEndDate   := clTemp_Period_Details_This_Year[i].Period_End_Date;
              end
              else begin
                 PeriodStartDate := clTemp_Period_Details_Last_Year[i].Period_Start_Date;
                 PeriodEndDate   := clTemp_Period_Details_Last_Year[i].Period_End_Date;
              end;
            end;

            //Add actual column
            aColumn :=  AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Actual', jtRight, NumberFormatStr, TotalFormatStr,true);
            case clFRS_Reporting_Period_Type of
              frpWeekly, frpFortnightly, frpFourWeekly, frpCustom : begin
                 aColumn.Caption      := bkDate2Str( PeriodStartDate) + '-';
                 aColumn.CaptionLine2 := bkDate2Str( PeriodEndDate);
              end;
              frpMonthly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
              frp2Monthly, frpQuarterly, frp6Monthly, frpYearly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodStartDate,true) + '-';
                 aColumn.CaptionLine2 := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
            end;

            //show the user when budgeted data is being used
            if ( i > clTemp_FRS_Last_Actual_Period_To_Use) and (clTemp_FRS_Use_Budgeted_Data_If_No_Actual) then begin
              if aColumn.CaptionLine2 <> '' then
                aColumn.CaptionLine2 := aColumn.CaptionLine2 + ' **'
              else
                aColumn.Caption := aColumn.Caption + ' **';

              BudgetedPeriodsUsed := true;
            end;

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;

            if clFRS_Show_Quantity then
            begin
              AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Quantity', jtRight, QuantityStr, QuantityStr, false);
              //see if we're also showing budget unit price
              if clTemp_FRS_Use_Budget_Quantities then
                AddFormatColAuto(Job, cLeft, cWidth, cGap, 'Unit Price', jtRight, NumberFormatStr, TotalFormatStr, false);
            end;

            if clFRS_Report_Style = crsBudgetRemaining then begin
               Assert( false, 'Period columns added to budget remaining report');
            end;
          end;

          if Job.GetPrintGainLossSummaryLegend then
          begin
            AddJobFooter(Job, siFootNote, '* This exchange gain/loss entry has been calculated using the sum of all exchange gain/loss entries for the included accounts', True);
          end;
          
          if BudgetedPeriodsUsed then
             AddJobFooter( Job,siFootNote, '** = This period contains budgeted data', true);

          //Add YTD columns
          if clFRS_Show_YTD then begin
            //Add actual column
            if clFRS_Compare_Type = cflCompare_None then
              AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD', jtRight, NumberFormatStr, TotalFormatStr,true)
            else
              AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Actual', jtRight, NumberFormatStr, TotalFormatStr,true);

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;

            if clFRS_Show_Quantity then
            begin
              AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Quantity', jtRight, QuantityStr, QuantityStr, false);
              //see if we're also showing budget unit price
              if clTemp_FRS_Use_Budget_Quantities then
                AddFormatColAuto(Job, cLeft, cWidth, cGap, 'AVG Unit Price', jtRight, NumberFormatStr, TotalFormatStr, false);
            end;

            if clFRS_Report_Style = crsBudgetRemaining then begin
               AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Full Year Budget', jtRight, NumberFormatStr, TotalFormatStr, true);
               AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Budget Remaining', jtRight, NumberFormatStr, TotalFormatStr, true);
            end;
          end;

          //AddClientFooter(Job);

          //Add Footers
          AddCommonFooter(Job);

          Job.OnBKPrint := ListCashflow;
          Job.Generate(Destination, lParams);
        finally
         Job.Free;
         lParams.Free;
        end;
      end;
   finally
      CalculateAccountTotals.RemoveAutoContraCodes( MyClient);
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Export cash flow data to Excel.
//
procedure DoCashflowExport;
  procedure RenderToExcel(ExcelRange : TOpExcelRange; Col, Row, AFontSize : Integer; FontBold : Boolean; AValue : String);
  begin
    with ExcelRange do begin
      Address := ExcelAddress(Col, Row);
      FontSize := AFontSize;
      if (FontBold) then
        FontAttributes := [xlfaBold]
      else
        FontAttributes := [];
      //format cell
      AsRange.NumberFormat := '@';
      Value := AValue;
    end;
  end;

const
  THIS_YEAR_LEFT = 4;
  LAST_YEAR_LEFT = 17;
  BUDGET_LEFT = 30;
  REPORT_HEADER : Array[0..3] of String =
    ('Code', 'Description', 'Report Group', 'Sub-Group');
var
  dlgCheckBoxOptions: TdlgCheckBoxOptions;
  IncGST, IncBudget : boolean;
  Budget : tBudget;
  MyDataModule : TDataModuleOffice;
  ExcelRange   : TOpExcelRange;

  i, PeriodNo : Integer;
  CurrentLineNo : Integer;
  HeaderLineNo  : Integer;

  PeriodEndDate    : integer;

  pAcct: pAccount_Rec;
  AccountInfo  : TAccountInformation;
  MValue : Money;
  S      : string;
begin
  dlgCheckBoxOptions := TdlgCheckBoxOptions.Create(Application.MainForm);
  try
    with dlgCheckBoxOptions do
    begin
      Caption := GetCFHeading(MyClient, hdCash_Flow) + ' - Export';
      lblLine1.Caption := 'Choose which options to include in the Export.';
      chkBox1.Caption := MyClient.TaxSystemNameUC + ' Inclusive';
      chkBox1.Checked := False;
      chkBox1.Visible := True;
      chkBox2.Caption := 'Include Budget';
      chkBox2.Checked := True;
      chkBox2.Visible := True;
      if (ShowModal = mrOK) then
      begin
        IncGST := chkBox1.Checked;
        IncBudget := chkBox2.Checked;
      end else
        Exit;
    end;
  finally
    dlgCheckBoxOptions.Free;
  end;

  if (IncBudget) then
  begin
    Budget := SelectBudget('Select a Budget', MyClient.clFields.clReporting_Year_Starts);
    if not Assigned( Budget ) then
      Exit;
  end else
    Budget := nil;

  with MyClient, Myclient.clFields do
  begin
    clFRS_Compare_Type                        := cflCompare_None;

    clFRS_Show_Variance                       := False;
    clFRS_Show_YTD                            := True;
    clFRS_Show_Quantity                       := False;

    clFRS_Reporting_Period_Type               := frpMonthly;
    clFRS_Report_Style                        := crsMultiplePeriod;

    clFRS_Report_Detail_Type                  := cflReport_Detailed;

    clGST_Inclusive_Cashflow                  := IncGST;
    clFRS_Prompt_User_to_use_Budgeted_figures := False;

    //now save temporary client variables
    clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
    clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
    clTemp_FRS_From_Date                      := 0;
    clTemp_FRS_To_Date                        := 0;

    if (IncBudget) then
    begin
      clTemp_FRS_Budget_To_Use                := Budget.buFields.buName;
      clTemp_FRS_Budget_To_Use_Date           := Budget.buFields.buStart_Date;
    end
    else
    begin
      clTemp_FRS_Budget_To_Use                := '';
      clTemp_FRS_Budget_To_Use_Date           := -1;
    end;

    //Budgeted data will be shown seperately to the actual data so dont use in actual section
    clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
    //clFRS_Print_Chart_Codes                   := ChartCodes;

    //now set temporary flag into bank accounts;
    FlagAllAccountsForUse( MyClient);
  end;

  //check pre conditions
  VerifyCashflowPreconditions( MyClient);

  MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only := true;
  CalculateAccountTotals.AddAutoContraCodes( MyClient);
  try
    CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, False, True, True);

    MyDataModule := TDataModuleOffice.Create( nil);

    if Assigned( MyDataModule) then
    begin
      try
        //create the data module that contains the Excel component
        with MyDataModule do begin
           //connect to Excel
           OpExcel1.Connected := true;

           with OpExcel1 do begin
              WindowState := XlwsNormal;
              Caption     := ShortAppName + ' Report in Microsoft Excel';
              Interactive := False; // Don't let the user access it
              //Add initial workbook and range
              Workbooks.Add;
              ExcelRange := Workbooks[0].Worksheets[0].Ranges.Add;
              // show it
              Visible     := true;

              with ExcelRange do begin
                Address := 'A1';
                AsRange.Font.Color := clNavy;
                AsRange.Font.Size  := 16;
                Value   := 'Generating Report: Loading report data...'
              end;

              with ExcelRange do begin
                Address := 'A2';
                AsRange.Font.Size := 12;
                AsRange.Font.Bold := True;
                //format cell
                AsRange.NumberFormat := '@';
                Value   := MyClient.clFields.clName;

                Address := 'A3';
                AsRange.Font.Size := 16;
                AsRange.Font.Bold := True;
                //format cell
                AsRange.NumberFormat := '@';
                Value := GetCFHeading(MyClient, hdCash_Flow) + ' - ' + GetGSTString(MyClient) +
                  StDateToDateString('NNN yyyy', MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date, true);
              end;
              if (IncBudget) then
              begin
                with ExcelRange do begin
                  Address := 'A4';
                  AsRange.Font.Size := 10;
                  AsRange.Font.Bold := True;
                  //format cell
                  AsRange.NumberFormat := '@';
                  Value   := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use + ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';
                end;
              end;
              CurrentLineNo := 7;

              RenderToExcel(ExcelRange, THIS_YEAR_LEFT + 1, CurrentLineNo-1, 10, True, 'This Year');
              RenderToExcel(ExcelRange, LAST_YEAR_LEFT + 1, CurrentLineNo-1, 10, True, 'Last Year');
              if (IncBudget) then
                RenderToExcel(ExcelRange, BUDGET_LEFT + 1, CurrentLineNo-1, 10, True, 'Budget');

              for i := 0 to 3 do
                RenderToExcel(ExcelRange, i, CurrentLineNo, 10, True, REPORT_HEADER[i]);

              //this year
              for i := 1 to 12 do
              begin
                PeriodEndDate := MyClient.clFields.clTemp_Period_Details_This_Year[i].Period_End_Date;
                RenderToExcel(ExcelRange, THIS_YEAR_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
              end;
              //last year
              for i := 1 to 12 do
              begin
                PeriodEndDate := MyClient.clFields.clTemp_Period_Details_Last_Year[i].Period_End_Date;
                RenderToExcel(ExcelRange, LAST_YEAR_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
              end;
              if (IncBudget) then
              begin
                //budget
                for i := 1 to 12 do
                begin
                  PeriodEndDate := MyClient.clFields.clTemp_Period_Details_This_Year[i].Period_End_Date;
                  RenderToExcel(ExcelRange, BUDGET_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
                end;
              end;

              HeaderLineNo := CurrentLineNo;
              CurrentLineNo := CurrentLineNo + 2;

              AccountInfo := TAccountInformation.Create(MyClient);
              try
                AccountInfo.UseBudgetIfNoActualData     := MyClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
                AccountInfo.LastPeriodOfActualDataToUse := MyClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;

                //cycle thru accounts
                for i := 0 to MyClient.clChart.ItemCount - 1 do
                begin
                  pAcct := MyClient.clChart.Account_At(i);
                  RenderToExcel(ExcelRange, 0, CurrentLineNo, 10, False, Trim( pAcct^.chAccount_Code));
                  RenderToExcel(ExcelRange, 1, CurrentLineNo, 10, False, Trim( pAcct^.chAccount_Description));

                  if pAcct^.chAccount_Type in [atMin..atMax] then
                    S := Localise( MyClient.clFields.clCountry, atNames[pAcct^.chAccount_Type])
                  else
                    S := '';
                  RenderToExcel(ExcelRange, 2, CurrentLineNo, 10, False, S);

                  S := Trim(MyClient.clCustom_Headings_List.Get_SubGroup_Heading( pAcct^.chSubType));
                  RenderToExcel(ExcelRange, 3, CurrentLineNo, 10, False, S);

                  AccountInfo.AccountCode := pAcct.chAccount_Code;
                  //this year
                  for PeriodNo := 1 to 12 do
                  begin
                    MValue := (AccountInfo.ActualOrBudget(PeriodNo) / 100);
                    RenderToExcel(ExcelRange, THIS_YEAR_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MValue));
                  end;
                  //last year
                  for PeriodNo := 1 to 12 do
                  begin
                    MValue := (AccountInfo.LastYear(PeriodNo) / 100);
                    RenderToExcel(ExcelRange, LAST_YEAR_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MValue));
                  end;
                  if (IncBudget) then
                  begin
                    //budget
                    for PeriodNo := 1 to 12 do
                    begin
                      MValue := (AccountInfo.Budget(PeriodNo) / 100);
                      RenderToExcel(ExcelRange, BUDGET_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MValue));
                    end;
                  end;
                  Inc(CurrentLineNo);
                end;
              finally
               AccountInfo.Free;
              end;
           end;

           //autosize columns
           with ExcelRange do
           begin
             Address := 'A1';
             Value   := 'Generating Report: Auto sizing columns...';

             if (IncBudget) then
               Address := ExcelAddress( 0, HeaderLineNo) + ':' + ExcelAddress( BUDGET_LEFT + 12, CurrentLineNo)
             else
               Address := ExcelAddress( 0, HeaderLineNo) + ':' + ExcelAddress( LAST_YEAR_LEFT + 12, CurrentLineNo);

             AsRange.Columns.AutoFit;
           end;

           //remove please wait text...
           with ExcelRange do begin
              Address := 'A1';
              Value   := '';
           end;
           OpExcel1.Interactive := True; // Let the user access it
           //maximise when finished
           OpExcel1.WindowState := xlwsMaximized;
        end;

        HelpfulInfoMsg('Click OK if you have finished using Excel.',0);
      finally
        //Make sure memory is freed before leaving
        MyDataModule.Free;
      end;
    end;

  finally
    CalculateAccountTotals.RemoveAutoContraCodes( MyClient);
  end;
end;

{ TExchangeGainLossCache }

procedure TExchangeGainLossTable.Clear;
var
  Row: Integer;
begin
  for Row := 0 to Length(FTable) -1 do
  begin
    SetLength(FTable[Row], 0);    
  end;

  SetLength(FTable, 0);
end;

constructor TExchangeGainLossTable.Create(Owner: TCashflowReportEx; ColumnsPerPeriod, FromPeriod, ToPeriod: Integer);
begin
  FOwner := Owner;
  FColumnsPerPeriod := ColumnsPerPeriod;
  FFromPeriod := FromPeriod;
  FToPeriod := ToPeriod;

  InitializeTable;
end;

destructor TExchangeGainLossTable.Destroy;
begin
  Clear;
  
  inherited;
end;

procedure TExchangeGainLossTable.GetValuesForPeriod(Period: Integer; var ValuesArray: TValuesArray);
var
  Row: Integer; 
  Index: Integer; 
begin
  Row := Period - FFromPeriod;

  for Index := Low(ValuesArray) to High(ValuesArray) do
  begin
    ValuesArray[Index] := FTable[Row][Index];
  end;
end;

procedure TExchangeGainLossTable.InitializeTable;
var
  RowCount: Integer;
  Row: Integer;
begin
  RowCount := FToPeriod - FFromPeriod;

  SetLength(FTable, RowCount + 1);

  for Row := 0 to RowCount do
  begin
    SetLength(FTable[Row], FColumnsPerPeriod);
  end;
end;

procedure TExchangeGainLossTable.SumValuesToPeriod(ToPeriod: Integer; var ValuesArray: TValuesArray);
var
  MaxRow: Integer;
  Row: Integer;  
  Index: Integer;
begin
  for Index := Low(ValuesArray) to High(ValuesArray) do
  begin
    ValuesArray[Index] := 0;
  end;
  
  MaxRow := ToPeriod - FFromPeriod;

  for Row := 0 to MaxRow do
  begin
    for Index := Low(ValuesArray) to High(ValuesArray) do
    begin
      ValuesArray[Index] := ValuesArray[Index] + FTable[Row][Index];
    end;
  end;
end;

procedure TExchangeGainLossTable.Initialize(Account: pAccount_Rec);
var
  PeriodNo: Integer;
begin
  for PeriodNo := FFromPeriod to FToPeriod do
  begin
    FOwner.GetExchangeGainLossForPeriod(Account, PeriodNo, FTable[PeriodNo - FFromPeriod]);
  end;
end;

end.
