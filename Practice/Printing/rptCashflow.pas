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
  CountryUtils;


{$IFDEF SmartBooks}
    !! The SmartBooks specific code has been removed
{$ENDIF}

const
   UnitName = 'RPTCASHFLOW';

type
  //this is the cashflow report object.  It adds functionality to print a
  //cash on hand section, and provides routines to retrieve values for each
  //account
  TCashflowReportEx = class( TFinancialReportBase)
  protected
    procedure GetValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); override;
    procedure GetYTD_ValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); override;

    procedure GetOpeningBalancesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray);
    function GetClosingBalancesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray): Boolean;

    function  AccountNeedsPrinting( pAcct : pAccount_Rec) : boolean; override;

    procedure SetupColumnsTypes; override;
  public
    function  GetHeading( No : Integer): string; override;
    procedure PrintCashOnHandSection;
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
            Values[ i]  := AccountInfo.ClosingBalanceActualOrBudget( ForPeriod);
          Result := AccountInfo.YTD_ActualOrBudget(ForPeriod) <> 0;
        end;
        ftComparative : begin
          //does the user want last year or budget
          if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            if ShowLastYear then
              Values[i]   := AccountInfo.ClosingBalance_LastYear( ForPeriod)
            else if ShowBudget then
              Values[i]   := AccountInfo.ClosingBalanceBudget(ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            if ShowLastYear then
              Values[i]   := AccountInfo.Variance_ClosingBalance_ActualLastYear( ForPeriod);
        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
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
        ftVariance : begin
          //does the user want last year or budget
          if IncludeBalance(PeriodStartDate_LY, PeriodEndDate_LY, pAcct^.chTemp_Date_First_Movement) then
            if ShowLastYear then
              Values[i] := AccountInfo.Variance_OpeningBalance_ActualLastYear( ForPeriod);

        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TCashflowReportEx.GetValuesForPeriod(const pAcct: pAccount_Rec;
  const ForPeriod: integer; var Values: TValuesArray);
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
            Values[i]   := AccountInfo.Variance_ActualBudget( ForPeriod);
        end;
      end;
    end;
  finally
   AccountInfo.Free;
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

procedure TCashflowReportEx.PrintCashOnHandSection;
//prints either a detailed or summarised cash on hand section.
//this routine does not currently support sub groups.
var
  sSectionHeading        : string;
  sAccountDesc : string;
  PeriodNo     : integer;

  ValuesArray  : TValuesArray;

  OB_ValuesArray : TValuesArray;
  MV_ValuesArray : TValuesArray;
  CB_ValuesArray : TValuesArray;

  OpeningBalanceTotals : TValuesArray;
  MovementTotals       : TValuesArray;
  ClosingBalanceTotals : TValuesArray;
  TotalsArrayPos       : integer;
  NumOfTotals          : integer;

  i,j          : integer;
  pAcct        : pAccount_Rec;
  Budget       : TBudget;
  BudgetedOpeningBalance : Money;

  ShowThisAccount : boolean;

  function GetFormatForBankAccount(AContraCode: string): string;
  var
    i: integer;
    ba : TBank_Account;
    CS: string;
  begin
    Result := MyClient.FmtMoneyStrBrackets;
    for i := 0 to ClientForReport.clBank_Account_List.ItemCount - 1 do begin
      ba := TBank_Account(ClientForReport.clBank_Account_List.Bank_Account_At(i));
      if Assigned(ba) then begin
        if (ba.baFields.baContra_Account_Code = AContraCode) then
          CS := ba.CurrencySymbol;
          if ClientForReport.clFields.clFRS_Report_Style in [crsSinglePeriod, crsBudgetRemaining] then
          begin
            if ReportTypeParams.RoundValues then
            begin
              Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]);
              Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]); //note:sign is reversed
            end else
            begin
              Result := Format('%s#,##0.00;%s(#,##0.00);-',[CS, CS]);
              Result := Format('%s#,##0.00;%s(#,##0.00);-',[CS, CS]); //note:sign is reversed
            end;
          end else
          begin
             Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]);
             Result := Format('%s#,##0;%s(#,##0);-',[CS, CS]); //note:sign is reversed
          end;

      end;
    end;                                 
  end;

begin
  if ClientForReport.clFields.clCflw_Cash_On_Hand_Style = cflCash_On_Hand_None then Exit;

  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil this afterward
                                              //delphi will handle it through
                                              //reference counting
  //test to see if the report is detailed or summarised
  if ClientForReport.clFields.clCflw_Cash_On_Hand_Style = cflCash_On_Hand_Detailed then begin

    sSectionHeading := GetHeading( hdCashbook_Balances);
    if sSectionHeading <> '' then
      RenderTitleLine( sSectionHeading);

//    if not HasSubGroups then begin
    for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
      pAcct := FRptParameters.Chart.Account_At(i);

      //see if should show this account
      ShowThisAccount := ( pAcct^.chAccount_Type in [ atBankAccount]) and
                         ( pAcct^.chTemp_Include_In_Report);

      if ShowThisAccount then begin
        //Print Account Info
        if ClientForReport.clFields.clFRS_Print_Chart_Codes then begin
           sAccountDesc := Trim( pAcct^.chAccount_Code) + ' ' + Trim( pAcct^.chAccount_Description);
        end
        else
           sAccountDesc := Trim( pAcct^.chAccount_Description);

        RenderTitleLine( sAccountDesc);




        //------ Opening Balance
        PutString( GetHeading( hdOpening_Balance));
        //Print Periodic Information
        for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetOpeningBalancesForPeriod( pAcct, PeriodNo, ValuesArray);

//            if MyClient.HasForeignCurrencyAccounts then
//               SetCurrencyFormatForPeriod(ValuesArray, GetFormatForBankAccount(pAcct^.chAccount_Code));

            //PrintValues
            PrintValuesForPeriod( ValuesArray, Debit);
          end
          else
             SkipPeriod;
        end;

        //Period YTD Information
        if ClientForReport.clFields.clFRS_Show_YTD then begin
           //GetYTDValues
           GetOpeningBalancesForPeriod( pAcct, 1, ValuesArray);

//           if MyClient.HasForeignCurrencyAccounts then
//              SetCurrencyFormatForPeriod(ValuesArray, GetFormatForBankAccount(pAcct^.chAccount_Code));

           //PrintValues
           PrintValuesForPeriod( ValuesArray, Debit);
        end;
        RenderDetailLine;

        //--------- Movement
        PutString( GetHeading( hdPlus_Movement ));

        //Print Periodic Information
        for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);
            //PrintValues
            PrintValuesForPeriod( ValuesArray, Debit);
          end
          else
             SkipPeriod;
        end;

        //Period YTD Information
        if ClientForReport.clFields.clFRS_Show_YTD then begin
           //GetYTDValues
           GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
           //PrintValues
           PrintValuesForPeriod( ValuesArray, Debit);
        end;

        RenderDetailLine;

        //--------- Closing Balance
        RequireLines(3);
        SingleUnderLine;
        PutString( GetHeading( hdClosing_Balance));
        //Print Periodic Information
        for PeriodNo:= MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetClosingBalancesForPeriod( pAcct, PeriodNo, ValuesArray);
            //PrintValues
            PrintValuesForPeriod( ValuesArray, Debit);
          end
          else
             SkipPeriod;
        end;

        //Period YTD Information
        if ClientForReport.clFields.clFRS_Show_YTD then begin
           //GetYTDValues
           GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
           //PrintValues
           PrintValuesForPeriod( ValuesArray, Debit);
        end;
        RenderDetailLine(True,siSectiontotal);
        DoubleUnderLine;

        //RenderTextLine( '');
      end;
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

    SetLength( OB_ValuesArray, ColumnsPerPeriod);
    SetLength( MV_ValuesArray, ColumnsPerPeriod);
    SetLength( CB_ValuesArray, ColumnsPerPeriod);

    //clear totals
    for i := Low(OpeningBalanceTotals) to High(OpeningBalanceTotals) do begin
       OpeningBalanceTotals[i] := 0;
       MovementTotals[i]       := 0;
       ClosingBalanceTotals[i] := 0;
    end;

    RenderTextLine('');

    sSectionHeading := GetHeading( hdCashbook_Balances) + ' Summary';
    if sSectionHeading <> '' then
      RenderTitleLine( sSectionHeading);

    //cycle thru accounts, load values into array
    for i := 0 to Pred( FRptParameters.Chart.ItemCount) do begin
      pAcct :=FRptParameters.Chart.Account_At(i);

      //see if should show this account
      ShowThisAccount := ( pAcct^.chAccount_Type in [ atBankAccount]) and
                         ( pAcct^.chTemp_Include_In_Report);

      if ShowThisAccount then begin
        //add values for this accounts to the totals
        TotalsArrayPos := 0;

        for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetOpeningBalancesForPeriod( pAcct, PeriodNo, OB_ValuesArray);
            GetValuesForPeriod(          pAcct, PeriodNo, MV_ValuesArray);
            GetClosingBalancesForPeriod( pAcct, PeriodNo, CB_ValuesArray);

            //Add account values to report group total
            for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do begin
               OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] + OB_ValuesArray[j];
               MovementTotals[ TotalsArrayPos]       := MovementTotals[ TotalsArrayPos]       + MV_ValuesArray[j];
               ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] + CB_ValuesArray[j];
               Inc(TotalsArrayPos);
            end;
          end
          else
            Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;
        //add YTD values to totals
        GetOpeningBalancesForPeriod( pAcct, 1, OB_ValuesArray);
        GetYTD_ValuesForPeriod(      pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, MV_ValuesArray);
        GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, CB_ValuesArray);
        //Add account values to report group total
        for j := Low( OB_ValuesArray) to High( OB_ValuesArray) do begin
           OpeningBalanceTotals[ TotalsArrayPos] := OpeningBalanceTotals[ TotalsArrayPos] + OB_ValuesArray[j];
           MovementTotals[ TotalsArrayPos]       := MovementTotals[ TotalsArrayPos]       + MV_ValuesArray[j];
           ClosingBalanceTotals[ TotalsArrayPos] := ClosingBalanceTotals[ TotalsArrayPos] + CB_ValuesArray[j];
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
        end;
        Inc(TotalsArrayPos);
      end;
    end;

    //now print results, need to load values back into a value array for printing
    PrintTotalsArray( GetHeading( hdOpening_Balance), OpeningBalanceTotals, Debit);
    PrintTotalsArray( GetHeading( hdPlus_Movement), MovementTotals, Debit);

    RequireLines(3);
    SingleUnderline;
    PrintTotalsArray( GetHeading( hdClosing_Balance), ClosingBalanceTotals, Debit);
    DoubleUnderline;
    ClearAllTotals;
  end;
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
      GetClosingBalancesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
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
procedure ListCashflow(Sender : TObject);
var
  DivisionIdx: integer;
  DivisionArray: DynamicBooleanArray;
  DivisionTitle: string;
  CashFlowReport: TCashFlowReportEx;
  ReportCount: integer;
  lClient: TClientObj;

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
        if DivisionArray[DivisionIdx] then
        begin
          clTemp_FRS_Division_To_Use := DivisionIdx;
          CalculateAccountTotals.CalculateAccountTotalsForClient( lClient);
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

   //Check Forex
   if MyClient.clFields.clFRS_Reporting_Period_Type = frpCustom then begin
      FromDate := MyClient.clFields.clTemp_FRS_From_Date;
      ToDate := MyClient.clFields.clTemp_FRS_To_Date;
   end else begin
      FromDate := MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
      ToDate := MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
   end;
   if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, False) then begin
     HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
     Exit;
   end;
   //Check exchange rates for opening and closing balance dates for this year and last year
   if not CalculateAccountTotals.HasOpenAndCloseBalanceExchangeRates(MyClient) then begin
     HelpfulInfoMsg('The report could not be run because there are missing exchange rates ' +
                    'for the opening or closing balance dates.',0);
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
      CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient);
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

          if clFRS_Report_Style in [crsSinglePeriod, crsBudgetRemaining] then
          begin
            if Job.ReportTypeParams.RoundValues then
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
    CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient);

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

end.
