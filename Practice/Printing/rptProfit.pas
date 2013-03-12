unit RptProfit;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Contains ALL profitability Reports
//
//uses the Base Cashflow Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  ReportDefs, clObj32, uBatchbase;

procedure DoProfit12ActualBudgetReport(Destination : TReportDest;
                                       RptBatch : TReportBase = nil);
procedure DoProfit12BudgetReport(Destination: TReportDest;
                                 RptBatch: TReportBase = nil);
procedure DoProfit12ActualReport(Destination : TReportDest;
                                 RptBatch : TReportBase = nil);
procedure DoProfitActualBudgetReport(Destination : TReportDest;
                                     RptBatch : TReportBase = nil);
procedure DoProfitActualBudgetVarianceReport(Destination : TReportDest;
                                             RptBatch : TReportBase = nil);
procedure DoProfitActualReport(Destination : TReportDest;
                               RptBatch : TReportBase = nil);
procedure DoProfitActualLYReport(Destination : TReportDest;
                                 RptBatch : TReportBase = nil);
procedure DoProfitExport;

procedure DoProfitAndLossEx( Destination : TReportDest;
                             aReportType: Integer;
                             RptBatch : TReportBase = nil);

procedure VerifyProfitAndLossPreconditions( ForClient : TClientObj);

function  GetPRHeading(ClientForReport : TClientObj; No : Integer): string;

//******************************************************************************
implementation

uses
  ReportTypes,
  Controls,
  Forms,
  Graphics,
  Math,
  SysUtils,
  AccountInfoObj,
  bkconst,
  bkDateUtils,
  bkdefs,
  bkhelp,
  BudgetLookup,
  budObj32,
  CalculateAccountTotals,
  cashflowRepDlg,
  CheckBoxOptionsDlg,
  glConst,
  globals,
  InfoMoreFrm,
  MoneyDef,
  NewReportUtils,
  OfficeDM, OpExcel,
  prHead,
  repcols,
  ReportCashflowBase,
  SignUtils,
  RptParams,
  stDateSt,
  chList32,
  SectionManager,
  CountryUtils;

const
   UnitName = 'RPTPROFIT';

const
   ExcludePercentage = [{atOpeningStock,atClosingStock}];

type
  //this is the profit and loss report object.  It adds to retrieve values for each account
  TProfitAndLossReportEx = class( TFinancialReportBase)
  protected

    procedure GetValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray; UsePeriodStartEnd: boolean = false); override;
    procedure GetYTD_ValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); override;

    procedure SetupColumnsTypes; override;
    procedure PrintProfitAndLossDirectExpesesSection;
  public
    function  GetHeading(No : Integer): string; override;
    procedure PrintDirectExpensesSection;
  end;

{$IFDEF SmartBooks}
    !! The SmartBooks specific code has been removed.
{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoProfitActualReport(Destination : TReportDest;
                               RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_ACT),MyClient,RptBatch,DYear);
   try
   repeat
      //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - Actual';

      if not GetFYearParameters(REPORT_LIST_NAMES[REPORT_PROFIT_ACT],
         lparam, BKH_Profit_Loss_Actual, True) then exit;

      case lParam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

     if Destination <> rdNone then begin
     with lParam, Client, clFields do
     begin
       clFRS_Compare_Type                        := cflCompare_None;
       clFRS_Show_Variance                       := False;
       clFRS_Show_YTD                            := True;
       clFRS_Show_Quantity                       := False;
       //clFRS_Print_Chart_Codes  Set by Dialog
       clFRS_Reporting_Period_Type               := frpMonthly;
       clFRS_Report_Style                        := crsSinglePeriod;
       //clReporting_Year_Starts  Set by Dialog
       clFRS_Report_Detail_Type                  := cflReport_Detailed;
       clGST_Inclusive_Cashflow                  := ShowGst;
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
     end;

     //**********************************
     LParam.SaveDates;
     DoProfitAndLossEx(Destination, LParam.ReportType, RptBatch);
     //**********************************
     end;
   until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
//------------------------------------------------------------------------------
procedure DoProfitActualLYReport(Destination : TReportDest;
                                   RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_ACT_LY),MyClient,RptBatch,DYear);
   try

   Repeat
      //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - Actual & LY';

      if not GetFYearParameters(REPORT_LIST_NAMES[REPORT_PROFIT_ACT_LY]
         ,lparam,BKH_Profit_Loss_Actual, True) then exit;

      case lParam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;
     if Destination <> rdNone then begin
     with lParam, Client, clFields do begin
     clFRS_Compare_Type                        := cflCompare_To_Last_Year;
     clFRS_Show_Variance                       := True;
     clFRS_Show_YTD                            := True;
     clFRS_Show_Quantity                       := False;
     //clFRS_Print_Chart_Codes  Set by Dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clFRS_Report_Style                        := crsSinglePeriod;
     //clReporting_Year_Starts  Set by Dialog
     clFRS_Report_Detail_Type                  := cflReport_Detailed;
     clGST_Inclusive_Cashflow                  := ShowGst;
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
   end;

   //**********************************
   lParam.Savedates;
   DoProfitAndLossEx(Destination, LParam.ReportType, RptBatch);
   //**********************************
   end;
   until LParam.RunExit(Destination);
   finally
      LParam.Free;
   end;
end;
//------------------------------------------------------------------------------
procedure DoProfitActualBudgetReport(Destination : TReportDest;
                                       RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_ACTBUD),MyClient,RptBatch,DYear,True);
   try

   Repeat
   //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - Actual and Budget';

   if not GetFYearParameters(REPORT_LIST_NAMES[REPORT_PROFIT_ACTBUD],
         lparam, BKH_Profit_Loss_Actual_and_budget, True, True, True) then exit;

      case Lparam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

     if Destination <> rdNone then begin
     with lParam, Client, clFields do begin

     //Budget := SelectBudget('Select a Budget', MyClient.clFields.clReporting_Year_Starts);
     if not Assigned( Budget ) then
        Exit;

     clFRS_Compare_Type                        := cflCompare_To_Budget;
     clFRS_Show_Variance                       := False;
     clFRS_Show_YTD                            := True;
     clFRS_Show_Quantity                       := False;
     //clFRS_Print_Chart_Codes  Set by Dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clFRS_Report_Style                        := crsSinglePeriod;
     //clReporting_Year_Starts  Set by Dialog
     clFRS_Report_Detail_Type                  := cflReport_Detailed;
     clGST_Inclusive_Cashflow                  := ShowGst;
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
   end;

   //*********************************
   LParam.Savedates;
   DoProfitAndLossEx(Destination, lparam.ReportType, RptBatch);
   //*********************************
   end;

   Until LParam.RunExit(Destination);
   finally
    LParam.Free;
   end;
end;
//------------------------------------------------------------------------------
procedure DoProfitActualBudgetVarianceReport(Destination : TReportDest;
                                       RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_ACTBUDVAR),MyClient,RptBatch,DYear,True);
   try

   Repeat
      //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - Actual, Budget and Variance';

      if not GetFYearParameters(REPORT_LIST_NAMES[REPORT_PROFIT_ACTBUDVAR],
          lparam, BKH_Profit_Loss_Actual_budget_and_variance, True,True, True) then exit;

      case lparam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

     if Destination <> rdNone then begin
     with LParam, Client, clFields do begin
     if not Assigned( Budget ) then
        Exit;

     clFRS_Compare_Type                        := cflCompare_To_Budget;
     clFRS_Show_Variance                       := True;
     clFRS_Show_YTD                            := True;
     clFRS_Show_Quantity                       := False;
     //clFRS_Print_Chart_Codes  Set by Dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clFRS_Report_Style                        := crsSinglePeriod;
     //clReporting_Year_Starts  Set by Dialog
     clFRS_Report_Detail_Type                  := cflReport_Detailed;
     clGST_Inclusive_Cashflow                  := ShowGst;
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
   end;

   //*********************************
   LParam.Savedates;
   DoProfitAndLossEx(Destination, lparam.ReportType, RptBatch);
   //*********************************
   end;
   Until LParam.RunExit(Destination);
   finally
    LParam.Free;
   end;
end;
//------------------------------------------------------------------------------
procedure DoProfit12ActualReport(Destination : TReportDest;
                                 RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin

   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_12ACT),MyClient,RptBatch,DYear);
   try

   Repeat
   //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - 12 Months Actual';

      if not GetFYearParameters( REPORT_LIST_NAMES[REPORT_PROFIT_12ACT]
        ,lparam,BKH_Profit_Loss_12_months_actual, True ) then exit;


      case lParam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

   if Destination <> rdNone then begin
   with LParam, Client, clFields do
   begin
     clFRS_Compare_Type                        := cflCompare_None;
     clFRS_Show_Variance                       := False;
     clFRS_Show_YTD                            := True;
     clFRS_Show_Quantity                       := False;
     //clFRS_Print_Chart_Codes  Set by Dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clFRS_Report_Style                        := crsMultiplePeriod;
     //clReporting_Year_Starts  Set by Dialog
     clFRS_Report_Detail_Type                  := cflReport_Detailed;
     clGST_Inclusive_Cashflow                  := ShowGst;
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
   end;
   //*********************************
   LParam.Savedates;
   DoProfitAndLossEx(Destination, lparam.ReportType, RptBatch);
   //*********************************
   end;
   Until LParam.RunExit(Destination);
   finally
    LParam.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure DoProfit12ActualBudgetReport(Destination : TReportDest;
                                       RptBatch : TReportBase = nil);
var lParam : TProfitRptParameters;
begin
   lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_12ACTBUD),MyClient,RptBatch,DYear,True);
   try

   Repeat
      //Title := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - 12 Months Actual or Budget';

      if not GetFYearParameters( REPORT_LIST_NAMES[REPORT_PROFIT_12ACTBUD],
         lparam,
         BKH_Profit_Loss_12_Months_actual_or_budget, True,True, True) then exit;


      case lParam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

   if Destination <> rdNone then begin
   with lparam, Client, clFields do
   begin
     if not Assigned( Budget ) then  // Assert...
        Exit;
     clFRS_Compare_Type                        := cflCompare_None;
     clFRS_Show_Variance                       := False;
     clFRS_Show_YTD                            := True;
     clFRS_Show_Quantity                       := False;
     //clFRS_Print_Chart_Codes  Set by Dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clFRS_Report_Style                        := crsMultiplePeriod;
     //clReporting_Year_Starts  Set by Dialog
     clFRS_Report_Detail_Type                  := cflReport_Detailed;
     clGST_Inclusive_Cashflow                  := ShowGst;
     clFRS_Prompt_User_to_use_Budgeted_figures := False;

     //now save temporary client variables
     clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
     clTemp_FRS_Last_Actual_Period_To_Use      := Period;
     clTemp_FRS_From_Date                      := 0;
     clTemp_FRS_To_Date                        := 0;
     clTemp_FRS_Division_To_Use                := Division;
     clTemp_FRS_Job_To_Use                     := '';
     clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
     clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
     clTemp_FRS_Use_Budgeted_Data_If_No_Actual := True;
   end;
   //*********************************
   LParam.Savedates;
   DoProfitAndLossEx(Destination, lparam.ReportType, RptBatch);
   //*********************************
   end;
   Until LParam.RunExit(Destination);
   finally
    LParam.Free;
   end;
end;

procedure DoProfit12BudgetReport(Destination: TReportDest;
                                 RptBatch: TReportBase = nil);
var lParam : TProfitRptParameters;
begin
  lParam := TProfitRptParameters.Create(ord(REPORT_PROFIT_12BUD),MyClient,RptBatch,DYear,True);
  try
    repeat
      if not GetFYearParameters( REPORT_LIST_NAMES[REPORT_PROFIT_12BUD],
         lparam, BKH_12_months_budget, True,True, True, False, False, False, True) then //help link to be added in later
         exit;

      case lParam.RunBtn of
         BTN_PRINT : Destination := rdPrinter;
         BTN_PREVIEW : Destination := rdScreen;
         BTN_FILE : Destination := rdFile;
         BTN_SAVE : Destination := rdNone;
      else
         Destination := rdAsk;
      end;

      if Destination <> rdNone then
      begin
        if not Assigned( lparam.Budget ) then  // Assert...
          Exit;
        with lParam.Client.clFields do
        begin
          clFRS_Compare_Type                        := cflCompare_None;
          clFRS_Show_Variance                       := False;
          clFRS_Show_YTD                            := True;
          clFRS_Show_Quantity                       := False;
          //clFRS_Print_Chart_Codes  Set by Dialog
          clFRS_Reporting_Period_Type               := frpMonthly;
          clFRS_Report_Style                        := crsMultiplePeriod;
          clReporting_Year_Starts                   := lparam.Budget.buFields.buStart_Date;  
          clFRS_Report_Detail_Type                  := cflReport_Detailed;
          clGST_Inclusive_Cashflow                  := lParam.ShowGst;
          clFRS_Prompt_User_to_use_Budgeted_figures := False;

          //now save temporary client variables
          clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
          clTemp_FRS_Last_Actual_Period_To_Use      := -1;
          clTemp_FRS_From_Date                      := 0;
          clTemp_FRS_To_Date                        := 0;
          clTemp_FRS_Division_To_Use                := 0;
          clTemp_FRS_Job_To_Use                     := '';
          clTemp_FRS_Budget_To_Use                  := lparam.Budget.buFields.buName;
          clTemp_FRS_Budget_To_Use_Date             := lparam.Budget.buFields.buStart_Date;
          clTemp_FRS_Use_Budgeted_Data_If_No_Actual := true;
        end;
        //*********************************
        LParam.Savedates;
        DoProfitAndLossEx(Destination, lparam.ReportType, RptBatch);
        //*********************************
      end;
    Until LParam.RunExit(Destination);
  finally
    LParam.Free;
  end;
end;

function GetPRHeading(ClientForReport : TClientObj; No: Integer): string;
begin
  result := '';

  if No = -1 then Exit;

  result := ClientForReport.clFields.clPR_Headings[ No ];

  if result = '' then
     result := PRHEAD.phdNames[ No ];

  if Uppercase(result) = 'HIDE' then
     result := '';
end;

{ TProfitAndLossReportEx }

function TProfitAndLossReportEx.GetHeading(No: Integer): string;
begin
  Result := GetPRHeading(ClientForReport, No);
end;

procedure TProfitAndLossReportEx.GetValuesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer;
  var Values: TValuesArray; UsePeriodStartEnd: boolean = false);
var
  AccountInfo  : TProfitAndLossAccountInfo;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for P & L reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TProfitAndLossAccountInfo.Create( ClientForReport);
  try
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : Values[i] := AccountInfo.ActualOrBudget( ForPeriod);
        ftQuantity : Values[i] := AccountInfo.QuantityOrBudget ( ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.LastYear( ForPeriod);
          if ShowBudget then
             Values[i]:= AccountInfo.Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.Variance_ActualLastYear(ForPeriod);
          if ShowBudget then
             Values[i] := AccountInfo.Variance_ActualBudget(ForPeriod);
        end;

        ftPercentage : Values[i] := Values[Pred(i)];

      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TProfitAndLossReportEx.GetYTD_ValuesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer;
  var Values: TValuesArray);
var
  AccountInfo  : TProfitAndLossAccountInfo;
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

  AccountInfo := TProfitAndLossAccountInfo.Create( ClientForReport);
  try
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual :  Values[i] := AccountInfo.YTD_ActualOrBudget( ForPeriod);
        ftQuantity : Values[i]   := AccountInfo.YTD_Quantity( ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.YTD_LastYear( ForPeriod);
          if ShowBudget then
             Values[i] := AccountInfo.YTD_Budget( ForPeriod);
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.YTD_Variance_ActualLastYear( ForPeriod);
          if ShowBudget then
             Values[i] := AccountInfo.YTD_Variance_ActualBudget( ForPeriod);
        end;
        ftFullPeriodBudget : Values[i] := AccountInfo.BudgetRemaining( 0, AccountInfo.HighestPeriod);
        ftBudgetRemaining  : Values[i] := AccountInfo.BudgetRemaining( ForPeriod, AccountInfo.HighestPeriod);
        ftPercentage : Values[i] := Values[Pred(i)]; // should always follow the columns
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TProfitAndLossReportEx.PrintDirectExpensesSection;
//this is a special section because it contains opening and closing stock accounts
//which use balances instead of movement

const
  DefaultSign = Debit;

  procedure PrintSubSection(ReportGroupsSet : ATTypeSet; SubGroupNo : integer; var LinesPrinted : integer);
  var
    i : integer;
    pAcct : pAccount_Rec;
  begin
    LinesPrinted := 0;
    for i := 0 to Pred( ClientForReport.clChart.ItemCount) do begin
      pAcct := ClientForReport.clChart.Account_At( i);
      if  (pAcct^.chAccount_Type in ReportGroupsSet)
      and (pAcct^.chSubtype = SubGroupNo)
      and (pAcct^.chTemp_Include_In_Report) then begin
         FSuppressPercentage :=  pAcct^.chAccount_Type in ExcludePercentage;
         PrintDetailForAccount( pAcct, DefaultSign);
         Inc( LinesPrinted);
         FSuppressPercentage := False;
      end;
    end;
  end;

  function  COGSNeedsPrinting( ForSubGroup : integer) : boolean;
  begin
    result := SubGroupNeedsPrinting( [atOpeningStock, atPurchases, atClosingStock], ForSubGroup);
  end;

  procedure PrintCOGSForSubGroup( SubGroupNo : integer; var LinesPrinted : integer);
  var
    SubSectionLinesPrinted : integer;
  begin
    LinesPrinted  := 0;
    PrintSubSection( [atOpeningStock], SubGroupNo, SubSectionLinesPrinted);
    LinesPrinted := LinesPrinted + SubSectionLinesPrinted;
    PrintSubSection( [atPurchases]   , SubGroupNo, SubSectionLinesPrinted);
    LinesPrinted := LinesPrinted + SubSectionLinesPrinted;
    PrintSubSection( [atClosingStock], SubGroupNo, SubSectionLinesPrinted);
    LinesPrinted := LinesPrinted + SubSectionLinesPrinted;
  end;

  procedure GetTotalsForSubSection( ReportGroupSet : ATTypeSet; SubGroupNo : integer; var aTotalsArray : TValuesArray);
  var
    i : integer;
    TotalsArrayPos : integer;
    PeriodNo       : integer;
    pAcct : pAccount_Rec;
    ValuesArray    : TValuesArray;
    j              : integer;
  begin
    //clear totals
    for i := Low( aTotalsArray) to High( aTotalsArray) do
      aTotalsArray[i] := 0;
    //set up array for period values
    SetLength( ValuesArray, ColumnsPerPeriod);

    for i := 0 to Pred( ClientForReport.clChart.ItemCount) do begin
      pAcct := ClientForReport.clChart.Account_At(i);
      if  (pAcct^.chAccount_Type in ReportGroupSet)
      and (pAcct^.chTemp_Include_In_Report)
      and (pAcct^.chSubtype = SubGroupNo) then
      begin
        FSuppressPercentage :=  pAcct^.chAccount_Type in ExcludePercentage;
        TotalsArrayPos := 0;

        for PeriodNo := MinPeriodToShow to MaxPeriodToShow do begin
          if PeriodNo <= ClientForReport.clFields.clTemp_FRS_last_Period_To_Show then begin
            //GetValues
            GetValuesForPeriod( pAcct, PeriodNo, ValuesArray);

            //Add account values to report group total
            for j := Low( ValuesArray) to High( ValuesArray) do begin
              aTotalsArray[ TotalsArrayPos] := aTotalsArray[ TotalsArrayPos] + ValuesArray[j];
              Inc(TotalsArrayPos);
            end;
          end
          else
            Inc(TotalsArrayPos, ColumnsPerPeriod);
        end;
        //add YTD values to totals
        GetYTD_ValuesForPeriod( pAcct, ClientForReport.clFields.clTemp_FRS_last_Period_To_Show, ValuesArray);
        //Add account values to report group total
        for j := Low( ValuesArray) to High( ValuesArray) do begin
           aTotalsArray[ TotalsArrayPos] := aTotalsArray[ TotalsArrayPos] + ValuesArray[j];
           Inc(TotalsArrayPos);
        end;
        FSuppressPercentage := False;
      end;
    end;
  end;

var
  sSectionHeading         : string;
  sSectionTotal           : string;
  sSubGroupHeading        : string;
  sSubGroupTotal          : string;
  ValuesArray             : TValuesArray;
  TotalsArray             : TValuesArray;
  HasSubGroups            : boolean;
  iNumOfCOGS_SubGroups    : integer; //Cost of Goods Sold
  iNumOfODE_SubGroups     : integer; //Other Direct Expenses
  iSubGroupHits           : integer;
  ReportGroupNo           : integer;
  i,j                     : integer;
  NoOfCOGSLines           : integer;
  NoOfODELines            : integer;
  NumOfTotals              : integer;
  SubGroupNo              : integer;
begin //PrintDirectExpensesSection
  sSectionHeading := GetHeading( phdLess_Direct_Expenses);
  sSectionTotal   := GetHeading( phdTotal_Direct_Expenses);
  SetLength( ValuesArray, ColumnsPerPeriod);  //no need to nil these afterward
                                              //delphi will handle it through
                                              //reference counting

  //See if section has report groups with sub groups, count no of sub groups
  //now so that we can use it later to determine if totals should be written
  HasSubGroups         := false;
  iNumOfCOGS_SubGroups := 0;
  iNumOfODE_SubGroups  := 0;

  for ReportGroupNo := atMin to atMax do begin
    //count how many sub groups will appear in the COGS section
    if (ReportGroupNo in [ atOpeningStock, atPurchases, atClosingStock]) then begin
      iSubGroupHits := 0;
      //see if has sub groups
      for i := 0 to Max_SubGroups do
        if SubGroupNeedsPrinting( [ReportGroupNo], i) then begin
          if i > 0 then  //0 is the unassigned sub group
            HasSubGroups    := True;
          Inc( iSubGroupHits);
        end;
      //keep track of high no of sub groups, cant just inc each time because
      //may be counted for each report group
      iNumOfCOGS_SubGroups := Max( iNumOfCOGS_SubGroups, iSubGroupHits);
    end;

    //count how many sub groups will appear in the Other Direct Expenses section
    if (ReportGroupNo in [ atDirectExpense]) then begin
      //see if has sub groups
      for i := 0 to Max_SubGroups do
        if SubGroupNeedsPrinting( [ReportGroupNo], i) then begin
          if i > 0 then
            HasSubGroups    := True;
          Inc( iNumOfODE_SubGroups);
        end;
    end;
  end;

  if ClientForReport.clFields.clFRS_Report_Detail_Type = cflReport_Detailed then begin
    if sSectionHeading <> '' then
      RenderTitleLine( sSectionHeading);

    //COGS
    if ReportSectionNeedsPrinting( [ atOpeningStock, atPurchases, atClosingStock]) then begin
      RenderTitleLine( GetHeading( phdCOGS));
      if not HasSubGroups then begin
        SubGroupNo := 0;
        //no need for sub group headers or footers as this is the only section
        PrintCOGSForSubGroup( SubGroupNo, NoOfCOGSLines);
      end
      else begin
        //has sub groups, cycle through sub groups first, then print unassigned
        for j := 1 to Max_SubGroups + 1 do begin
          if j > Max_SubGroups then
            SubGroupNo := 0
          else
            SubGroupNo := j;

          //print the COGS for this sub group
          if COGSNeedsPrinting( SubGroupNo) then begin
            //print sub group heading
            sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
            sSubGroupTotal   := '';
            if ( SubGroupNo <> 0) and ( sSubGroupHeading <> '') then
              sSubGroupTotal := sSubGroupHeading + ' Total';

            if sSubGroupHeading <> '' then
              RenderTitleLine( sSubGroupHeading)
            else
              RenderTextLine('');

            PrintCOGSForSubGroup( SubGroupNo, NoOfCOGSLines);
            //print sub group total if more than one sub group printed
            if ( iNumOfCOGS_SubGroups > 1) and ( NoOfCOGSLines > 1) then
              RenderDetailSubSectionTotal( sSubGroupTotal, DefaultSign);

            ClearSubSectionTotal;
          end;
        end;
      end;
      //print cogs total only if
      //other direct expenses section was printed
      if ( iNumOfODE_SubGroups > 0) then
        RenderDetailSectionTotal( GetHeading( phdTotal_COGS), DefaultSign);

      ClearSectionTotal;
    end;

    //Other Direct Expenses
    if ReportSectionNeedsPrinting( [ atDirectExpense]) then begin
      RenderTitleLine( GetHeading( phdOther_Direct_Expenses));

      if not HasSubGroups then begin
        SubGroupNo := 0;
        PrintSubSection( [atDirectExpense], SubGroupNo, NoOfODELines);
      end
      else begin
        //has sub groups, cycle through sub groups first, then print unassigned
        for j := 1 to Max_SubGroups + 1 do begin
          if j > Max_SubGroups then
            SubGroupNo := 0
          else
            SubGroupNo := j;

          //print the Other Direct Expenses for this sub group
          if SubGroupNeedsPrinting( [atDirectExpense], SubGroupNo) then begin
            //print sub group heading
            sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
            sSubGroupTotal   := '';
            if ( SubGroupNo <> 0) and ( sSubGroupHeading <> '') then
              sSubGroupTotal := sSubGroupHeading + ' Total';

            if sSubGroupHeading <> '' then
              RenderTitleLine( sSubGroupHeading)
            else
              RenderTextLine('');

            PrintSubSection( [atDirectExpense], SubGroupNo, NoOfODELines);
            //print sub group total if more than one sub group printed
            if ( iNumOfODE_SubGroups > 1) and ( NoOfODELines > 1) then
                RenderDetailSubSectionTotal( sSubGroupTotal, DefaultSign);

            ClearSubSectionTotal;
          end;
        end;
      end;

      //print other direct expenses total only if
      //cogs section was printed
      if ( iNumOfCOGS_SubGroups > 0)  and ( HasSubGroups or ( NoOfODELines > 1)) then
        RenderDetailSectionTotal( GetHeading( phdTotal_Other_Direct_Expenses), DefaultSign);
      ClearSectionTotal;
    end;

    RenderDetailSubTotal( sSectionTotal, DefaultSign);
  end
  else begin
    NumOfTotals := ColumnsPerPeriod * ( iVisiblePeriods + 1);
    SetLength( TotalsArray, NumOfTotals);

    if not HasSubGroups then begin
      //if there is only one line to be printed then print with section heading
      if ( iNumOfCOGS_SubGroups + iNumOfODE_SubGroups = 1) then begin
        if ( iNumOfCOGS_SubGroups = 1) then begin
          GetTotalsForSubSection( [atOpeningStock, atPurchases, atClosingStock], 0, TotalsArray);
          PrintTotalsArray( sSectionHeading, TotalsArray, DefaultSign);
        end
        else begin
          GetTotalsForSubSection( [atDirectExpense], 0, TotalsArray);
          PrintTotalsArray( sSectionHeading, TotalsArray, DefaultSign);
        end;
      end
      else begin
        //has both sections so show all titles
        if sSectionHeading <> '' then
          RenderTitleLine( sSectionHeading);

        //Cost of Goods Sold
        GetTotalsForSubSection( [atOpeningStock, atPurchases, atClosingStock], 0, TotalsArray);
        PrintTotalsArray( GetHeading( phdCOGS), TotalsArray, DefaultSign);
        //Other Direct Expenses
        GetTotalsForSubSection( [atDirectExpense], 0, TotalsArray);
        PrintTotalsArray( GetHeading( phdOther_Direct_Expenses), TotalsArray, DefaultSign);

      end;
    end
    else begin
      if sSectionHeading <> '' then
        RenderTitleLine( sSectionHeading);

      //Cost of Goods Sold
      if iNumOfCOGS_SubGroups > 0 then
          RenderTitleLine(GetHeading( phdCOGS));

      //has sub groups, cycle through sub groups first, then print unassigned
      for j := 1 to Max_SubGroups + 1 do begin
          if j > Max_SubGroups then
            SubGroupNo := 0
          else
            SubGroupNo := j;

          //print the COGS for this sub group
          if COGSNeedsPrinting( SubGroupNo) then begin
            //print sub group heading
            sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
            GetTotalsForSubSection( [ atOpeningStock, atPurchases, atClosingStock], SubGroupNo, TotalsArray);
            PrintTotalsArray( sSubGroupHeading, TotalsArray, DefaultSign);
          end;
        end;

      if (iNumOfCOGS_SubGroups > 1) and (iNumOfODE_SubGroups > 0) then
          RenderDetailSubSectionTotal( GetHeading( phdTotal_COGS), DefaultSign);

      ClearSubSectionTotal;

      //Other Direct Expenses
      if iNumOfODE_SubGroups > 0 then
          RenderTitleLine( GetHeading( phdOther_Direct_Expenses));

      //has sub groups, cycle through sub groups first, then print unassigned
      for j := 1 to Max_SubGroups + 1 do begin
          if j > Max_SubGroups then
            SubGroupNo := 0
          else
            SubGroupNo := j;

          //print the COGS for this sub group
          if SubGroupNeedsPrinting( [atDirectExpense], SubGroupNo) then begin
            //print sub group heading
            sSubGroupHeading := ClientForReport.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
            GetTotalsForSubSection( [ atDirectExpense], SubGroupNo, TotalsArray);
            PrintTotalsArray( sSubGroupHeading, TotalsArray, DefaultSign);
          end;
        end;

      if (iNumOfODE_SubGroups > 1) and ( iNumOfCOGS_SubGroups > 0) then
          RenderDetailSubSectionTotal( GetHeading( phdTotal_Other_Direct_Expenses), DefaultSign);

      ClearSubSectionTotal;
    end;
    RenderDetailSubTotal( sSectionTotal, DefaultSign);
 end;
end;

procedure TProfitAndLossReportEx.PrintProfitAndLossDirectExpesesSection;
var
  Section: TSectionProfitAndLossDirectExpenses;
begin
  //This replaces PrintDirectExpenses and includes copies of:
  //    GetValuesForPeriod
  //    GetYTD_ValuesForPeriod
  Section := TSectionProfitAndLossDirectExpenses.Create(ClientForReport, Self, FRptParameters);
  try
    Section.PrintSection;
  finally
    FreeAndNil(Section);
  end;
end;

procedure TProfitAndLossReportEx.SetupColumnsTypes;
begin
  ClearColumnTypeArray;
  //Assume that the first column will always be actual values
  AddColumnTypeToArray( ftActual);
  if fDoPercentage then
     AddColumnTypeToArray( ftPercentage);


  with ClientForReport.clFields do begin
    if ( clFRS_Compare_Type in [ cflCompare_To_Budget, cflCompare_To_Last_Year]) then begin
      AddColumnTypeToArray( ftComparative);
      if fDoPercentage then
         AddColumnTypeToArray( ftPercentage);
      if clFRS_Show_Variance then
         AddColumnTypeToArray( ftVariance);
    end;

    if clFRS_Show_Quantity then
       AddColumnTypeToArray( ftQuantity);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure VerifyProfitAndLossPreconditions( ForClient : TClientObj);
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
       Assert( clFRS_Reporting_Period_Type in [frpMonthly..frpYearly],
               'clFRS_Reporting_Period_Type in [frpMonthly..frpYearly]');
       Assert( clFRS_Report_Style in [crsSinglePeriod, crsMultiplePeriod],
               'clFRS_Report_Style in [crsSinglePeriod, crsMultiplePeriod]');
       Assert( clReporting_Year_Starts > 0,
               'clReporting_Year_Starts > 0');
       Assert( clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised],
               'clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised]');

       //Assert( clGST_Inclusive_Cashflow = false,          allowed as of Nov 2002
       //        'clGST_Inclusive_Cashflow = false');

     //Non-persistant fields
       Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]],
               'clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]');
       Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions],
               'clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]');
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
procedure ListProfitAndLoss(Sender : TObject);
var
  DivisionIdx: integer;
  DivisionArray: DynamicBooleanArray;
  DivisionTitle: string;
  ProfitAndLossReport: TProfitAndLossReportEx;
  ReportCount: integer;
  lClient: TClientObj;

  procedure DoOutput(aProfitAndLossReport: TProfitAndLossReportEx);
  var
    i : integer;
  begin
    with aProfitAndLossReport ,MyClient, MyClient.clFields do begin
      if ReportSectionNeedsPrinting( [ atIncome, atOpeningStock, atPurchases,
                                       atClosingStock, atDirectExpense,
                                      atExpense] ) then begin
        //Income
        PrintSection( [atIncome], phdIncome, phdTotal_Income, Credit);
        // Need to set the PercentRef To income..
        for i := 0 to pred(Columns.ItemCount) do
          if Columns.Report_Column_At(I).IsPercentageCol then begin
            //Columns.Report_Column_At(I).GrandTotal := 0;
            Columns.Report_Column_At(I).PercentReference :=
              - Columns.Report_Column_At(pred(I)).GrandTotal;
          end;
       //Direct Expenses section  Cost of Goods Sold + Other Direct Expenses
       if ReportSectionNeedsPrinting( [ atOpeningStock, atPurchases,
                                        atClosingStock, atDirectExpense ]) then begin
//         PrintDirectExpensesSection;
         PrintProfitAndLossDirectExpesesSection;
         //Gross Profit
         RenderDetailRunningTotal( GetHeading( phdGross_Profit_Or_Loss ) , Credit);
       end;
       //Expenses
       PrintSection( [atExpense], phdExpenses, phdTotal_Expenses, Debit);
       //Operating Profit - only print if something below this
       if ReportSectionNeedsPrinting( [atOtherIncome, atUnknownCR, atUncodedCR,
                                       atOtherExpense, atUnknownDR,
                                       atUncodedDR]) then
         RenderDetailRunningTotal( GetHeading( phdOperating_Profit), Credit);
      end;
      //Other Income
      if ReportSectionNeedsPrinting( [atOtherIncome, atUnknownCR, atUncodedCR]) then begin
        PrintSection( [atOtherIncome, atUnknownCR, atUncodedCR],
                      phdOther_Income, phdTotal_Other_Income, Credit);
      end;
      //Other Expenses
      if ReportSectionNeedsPrinting( [atOtherExpense, atUnknownDR, atUncodedDR]) then
        PrintSection( [atOtherExpense, atUnknownDR, atUncodedDR],
                      phdLess_Other_Expenses, phdTotal_Other_Expenses, Debit);
      //Net Profit
      RenderDetailGrandTotal( GetHeading( phdNet_Trading_Profit_Or_Loss), Credit);
    end;
  end;

begin
  ProfitAndLossReport := TProfitAndLossReportEx(Sender);
  ProfitAndLossReport.ResetControlAccounts;
  lClient := ProfitAndLossReport.ClientForReport;

  with lClient.clFields do begin
    if clTemp_FRS_Split_By_Division then begin
      //Separate report for each division
      ReportCount := 0;
      DivisionArray := clTemp_FRS_Divisions;
      for DivisionIdx := 0 to Length(DivisionArray) - 1 do begin
        if DivisionArray[DivisionIdx] then begin
          clTemp_FRS_Division_To_Use := DivisionIdx;
          CalculateAccountTotals.CalculateAccountTotalsForClient( lClient, True, nil, -1, False, True, True);
          ProfitAndLossReport.ResetControlAccounts;
          ProfitAndLossReport.LoadAccountsToPrint;
          ProfitAndLossReport.ClearRunningTotals;
          if ReportCount > 0 then
            ProfitAndLossReport.ReportNewPage;
          DivisionTitle := ProfitAndLossReport.GetDivisionSubHeading(DivisionIdx);
          ProfitAndLossReport.RenderTextLine(DivisionTitle, True, False);
          DoOutput(ProfitAndLossReport);
          Inc(ReportCount);
        end
      end;
    end else
      //Single report for selected division(s)
      DoOutput(ProfitAndLossReport);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoProfitAndLossEx( Destination : TReportDest;
                             aReportType: Integer;
                             RptBatch : TReportBase = nil);
var
   Job               : TProfitAndLossReportEx;
   i                 : integer;
   Bwidth            : double;// Period (Block width)
   mWidth            : double;// Money / Qty width
   pWidth            : double;// Percentage width
   cLeft             : double;
   cGap              : double;
   ReportSettingsID  : string;
   s                 : string;
   TotalCols         : integer;
   TotalPCols        : integer;
   PeriodStartDate   : integer;
   PeriodEndDate     : integer;
   ReportScaleFactor : double;
   NumberFormatStr   : string;
   TotalFormatStr    : string;
   QuantityStr       : string;
   DescriptionWidth  : double;
   aColumn           : TReportColumn;
   BudgetedPeriodsUsed : boolean;
   Params : TRptParameters;
   FromDate, ToDate: integer;
   ISOCodes: string;
begin
   //Don't use account selection for Profit and Loss report TFS 10495
   FlagAllAccountsForUse( MyClient);

   VerifyProfitAndLossPreconditions( MyClient);

   case MyClient.clFields.clFRS_Report_Style of
      crsSinglePeriod   : ReportSettingsID := Report_List_Names[REPORT_PROFITANDLOSS_SINGLE];
      crsMultiplePeriod : ReportSettingsID := Report_List_Names[REPORT_PROFITANDLOSS_MULTIPLE];
   else
      ReportSettingsID := Report_List_Names[REPORT_PROFITANDLOSS_MULTIPLE];
   end;
   MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only := false;

   //Check Forex
   FromDate := MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
   ToDate := MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
   if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, False) then begin
     HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
     Exit;
   end;

   CalculateAccountTotals.AddAutoContraCodes( MyClient);
   try
      CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, True, True);

      //build the report
      With MyClient, clFields do
      Begin
        if Destination = rdNone then Destination := rdScreen;
        Params := TRptParameters.Create(AreportType,MyClient,RptBatch);

        Job := TProfitAndLossReportEx.Create( MyClient, Params);
        try
          Job.LoadReportSettings(UserPrintSettings, Params.MakeRptName( ReportSettingsID));
          //AddClientHeader(Job);

          //Add Headers
          AddCommonHeader(Job);

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          // Build header
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          Params.FromDate := clTemp_FRS_From_Date;
          Params.ToDate := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date;
          
          s := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - ' + frpNames[ clFRS_Reporting_Period_Type] + ' ' + GetGSTString(MyClient);

          if clTemp_FRS_Last_Actual_Period_To_Use < 0 then
            s := 'BUDGETED ' + s;

          s := s + ' ' + StDateToDateString('NNN yyyy', clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date, true);
          AddJobHeader(Job,siTitle,S,true,jtCenter,True);

          if clTemp_FRS_Job_To_Use <> '' then begin
             S :=  MyClient.clJobs.JobName(clTemp_FRS_Job_To_Use);
             if S > '' then
               S := ', ' + S;
             S := 'For Job: ' + clTemp_FRS_Job_To_Use + S;
             AddJobHeader(Job,siSubtitle,S,true);
          end;

          if ( clTemp_FRS_Division_To_Use in [1..glConst.Max_Divisions]) then begin
            //Single Division
            s := Job.GetDivisionSubHeading(clTemp_FRS_Division_To_Use);
            AddJobHeader(Job,siSubTitle,S,true);
          end else if (Length(clTemp_FRS_Divisions) > 0) and
                      (not clTemp_FRS_Split_By_Division) then begin
            //Multiple Divisions
            s := Job.GetDivisionSubHeading;
            // may have to wrap text if there are lots of divisions
            AddJobHeader(Job,siSubTitle,S,true, jtCenter, true);
          end;

          if (clBudget_List.Find_Name( clTemp_FRS_Budget_To_Use) <> nil)
            and ((clFRS_Compare_Type  = cflCompare_To_Budget) or ( clTemp_FRS_Use_Budgeted_Data_If_No_Actual)) then
          begin
            AddJobHeader(Job,siSubTitle, 'Using Budget: ' + clTemp_FRS_Budget_To_Use + ' (' + bkDate2Str( clTemp_FRS_Budget_To_Use_Date) + ')', true);
          end;

          AddJobHeader(Job,siSubTitle, '', true);

          //figure out how many columns there will be

          if clFRS_Report_Style in [crsSinglePeriod] then begin
            if (Job.ReportTypeParams.RoundValues) then
            begin
              NumberFormatStr  := '#,##0;(#,##0);-';
              TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
            end else
            begin
              NumberFormatStr  := '#,##0.00;(#,##0.00);-';
              TotalFormatStr   := '#,##0.00;(#,##0.00);-';   //note:sign is reversed
            end;
             DescriptionWidth := 22.0;
          end
          else begin
             NumberFormatStr  := '#,##0;(#,##0);-';
             TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
             DescriptionWidth := 13.0;
          end;
          QuantityStr        := '#.####;(#.####); ';

          //decide on the report scaling factor.  This attempts to automatically
          //reduce the font size to make the columns large enough to contain
          //data

          TotalCols := Job.iVisiblePeriods * Job.ColumnsPerPeriod;
          TotalPCols := Job.iVisiblePeriods * Job.PercentColumnsPerPeriod;
          if clFRS_Show_YTD then begin
            inc(TotalCols ,Job.ColumnsPerPeriod);
            inc(ToTalPCols,Job.PercentColumnsPerPeriod);
          end;

          ReportScaleFactor := 1.0;
          if TotalCols > 13 then begin
            ReportScaleFactor := ( 13 / (TotalCols + 1));
            if ReportScaleFactor > 1.0 then
              ReportScaleFactor := 1.0;

            if ReportScaleFactor < 0.05 then
              ReportScaleFactor := 0.05;
          end;
          cGap := Gcgap * ReportScaleFactor;
          Job.ReportScaleFactor := ReportScaleFactor;  //font will be adjusted during Generate

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          //Set up columns for this report
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          cLeft := GCLeft;
          AddColAuto( Job, cLeft ,DescriptionWidth * ReportScaleFactor,cGap,'', jtLeft);          //account column


          if Job.fDoPercentage then begin
             bWidth := (99.5 - cLeft) / ( (TotalCols -TotalPCols) * 2 + TotalPCols);
             pWidth := (bwidth ) - Cgap;
             mWidth := (bWidth * 2) - CGap;
          end else begin
             bWidth := (99.5 - cLeft) / ( TotalCols);
             mWidth := bwidth - cgap;
             pWidth := 0;
          end;

          mWidth := Min( mWidth, 20);
          pWidth := Min( pWidth, 10);

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
            aColumn :=  AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Actual', jtRight, NumberFormatStr, TotalFormatStr,true);

            case clFRS_Reporting_Period_Type of
              frpMonthly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
              frp2Monthly, frpQuarterly, frp6Monthly, frpYearly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodStartDate,true) + '-';
                 aColumn.CaptionLine2 := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
            end;
            if job.fDoPercentage then begin
               aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight, '#0.00', TotalFormatStr,False);
               aColumn.IsPercentageCol := True;
            end;
            //show the user when budgeted data is being used (unless it's always being used (Last actual period < 0)
            if ( i > clTemp_FRS_Last_Actual_Period_To_Use) and (clTemp_FRS_Last_Actual_Period_To_Use >= 0)
              and (clTemp_FRS_Use_Budgeted_Data_If_No_Actual) then
            begin
              if aColumn.CaptionLine2 <> '' then
                aColumn.CaptionLine2 := aColumn.CaptionLine2 + ' **'
              else
                aColumn.Caption := aColumn.Caption + ' **';

              BudgetedPeriodsUsed := true;
            end;

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if job.fDoPercentage then begin
                    aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight,'#0.00', TotalFormatStr,False);
                    aColumn.IsPercentageCol := True;
                 end;
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if job.fDoPercentage then begin
                    aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight,'#0.00', TotalFormatStr,False);
                    aColumn.IsPercentageCol := True;
                 end;
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;

            if clFRS_Show_Quantity then
              AddFormatColAuto( Job, cLeft, mWidth, cGap, 'Quantity', jtRight, QuantityStr, QuantityStr, false);

            if clFRS_Report_Style = crsBudgetRemaining then begin
               Assert( false, 'Period columns added to budget remaining report');
            end;
          end;

          if BudgetedPeriodsUsed then
             AddJobFooter( Job,siFootNote , '** = This period contains budgeted data', true);

          //Add YTD columns
          if clFRS_Show_YTD then begin
            //Add actual column
            if clFRS_Compare_Type = cflCompare_None then
              AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD', jtRight, NumberFormatStr, TotalFormatStr,true)
            else
              AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Actual', jtRight, NumberFormatStr, TotalFormatStr,true);

            if job.fDoPercentage then begin
               aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight,'#0.00', TotalFormatStr,False);
               aColumn.IsPercentageCol := True;
            end;

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if job.fDoPercentage then begin
                    aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight,'#0.00', TotalFormatStr,False);
                    aColumn.IsPercentageCol := True;
                 end;
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if job.fDoPercentage then begin
                    aColumn :=  AddFormatColAuto( Job, cLeft, pWidth, cGap, '%', jtRight,'#0.00', TotalFormatStr,False);
                    aColumn.IsPercentageCol := True;
                 end;
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;

            if clFRS_Show_Quantity then
              AddFormatColAuto( Job, cLeft, mWidth, cGap, 'YTD Quantity', jtRight, QuantityStr, QuantityStr, false);

          end;
          //Add Footers
          AddCommonFooter(Job);

          Job.OnBKPrint := ListProfitAndLoss;
          Job.Generate(Destination,Params);
        finally
         Job.Free;
         Params.Free;
        end;
      end;
   finally
      CalculateAccountTotals.RemoveAutoContraCodes( Myclient);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Export profit and loss data to Excel.
//
procedure DoProfitExport;
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
  HeaderLineNo : Integer;

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
      Caption := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - Export';
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

    clGST_Inclusive_Cashflow                  := IncGst;
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

    //now set temporary flag into bank accounts;
    //Don't use account selection for Profit and Loss report TFS 10495
    FlagAllAccountsForUse( MyClient);
  end;

  //check pre conditions
  VerifyProfitAndLossPreconditions( MyClient);

  MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only := False;
  CalculateAccountTotals.AddAutoContraCodes( MyClient);
  try
    CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, True, True);

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
                Value   := GetPRHeading(MyClient, phdProfit_And_Loss) + ' - ' + GetGSTString(MyClient) +
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
                    S := Localise( MyClient.clFields.clCountry,  atNames[pAcct^.chAccount_Type])
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
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
