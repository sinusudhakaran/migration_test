unit RptBudget;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Budget Reports, this is essentially a 12mth cashflow report with budget figures only
//
//note: this calls the Cashflow report unit so that it can print a periodic cashflow
//with budget figures only
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   UBatchBase, ReportDefs;

procedure DoBudgetReport(Destination : TReportDest;
                         RptBatch : TReportBase = nil);
procedure DoBudgetListing(Destination : TReportDest;
                          RptBatch : TReportBase = nil);

//******************************************************************************
implementation
uses
   ReportTypes,
   baUtils,
   bkconst,
   bkDateUtils,
   bkdefs,
   BudgetLookup,
   BudgetReportOptionsDlg,
   budObj32,
   CalculateAccountTotals,
   globals,
   MoneyDef,
   NewReportObj,
   NewReportUtils,
   repcols,
   rptCashflow,
   stDate,
   stDateSt,
   sysUtils,
   RptParams;

type
   //---------------------------------------------------------------------------
   TBudgetReport = class(TBKReport)
   private
     Budget : TBudget;
   protected
     procedure BKPrint;  override;
   end;

//------------------------------------------------------------------------------
//TBudgetReport
procedure TBudgetReport.BKPrint;
var
  i,j : integer;
  DetailLine : pBudget_Detail_Rec;
  S : string;
  Total12Mths : Money;
begin
  for i := 0 to MyClient.clChart.ITemCount-1 do with Myclient.clchart do
    with Account_At(i)^ do begin
      S := chAccount_Description;
      if (s='') or MyClient.clFields.clFRS_Print_Chart_Codes then
           s := Trim(chAccount_Code)+' '+S;

      Total12Mths := 0;
      //now find budget line for chart code
      DetailLine := Budget.buDetail.FindLineByCode(chAccount_Code);
      if ( DetailLine <> nil) then
      begin
        PutString( S );
        for j := 1 to 12 do
        begin
          PutMoney(DetailLine.bdBudget[j]*100);
          Total12Mths := Total12Mths + DetailLine.bdBudget[j];
        end;
        PutMoney(Total12Mths*100);
        RenderDetailLine;
      end
      else
      begin
        //no detail exists for chart, show only if is a non posting (could be a group header)
        if not chPosting_Allowed then
        begin
          PutString( S );
          for j := 1 to 13 do PutString('');  //include total
          RenderDetailLine;
        end;
      end;
    end; //with
end;

//------------------------------------------------------------------------------
procedure DoSpecifiedBudgetListing(BudgetToReportOn : TBudget;
                                   Destination : TReportDest;
                                   RptBatch : TReportBase = nil);
var
  BTN      : integer;
  Job      : TBudgetReport;
  cLeft,cGap : Double;
  pd         : integer;
  ColDAte    : integer;
begin
   //ask which budget to report on
   if (BudgetToReportOn = nil) and (Destination = rdNone) then
      BudgetToReportOn := SelectBudgetToPrint('Select Budget to Print',BTN);

   if not Assigned(BudgetToReportOn) then exit;

   if Destination = rdNone then
   case btn of
     BTN_PRINT   : Destination := rdPrinter;
     BTN_PREVIEW : Destination := rdScreen;
     BTN_FILE    : Destination := rdFile;
     BTN_EMAIL   : Destination := rdScreen;
   else
     Destination := rdAsk;
   end;

   Job := TBudgetReport.Create(rptOther);
   try
     Job.LoadReportSettings(UserPrintSettings,ReportID(Report_List_Names[REPORT_BUDGET_LISTING],Rptbatch));
     Job.Budget := BudgetToReportOn;

     //Add Headers
     AddCommonHeader(Job);

     AddJobHeader(Job,siTitle,'BUDGET REPORT', true);
     AddJobHeader(Job,siTitle,Uppercase(Job.Budget.buFields.buName)+'  Starts : '+bkDate2Str(Job.Budget.buFields.buStart_Date),true);

     {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
     cLeft := GcLeft;
     cGap  := GcGap;

     AddColAuto(Job,cLeft,16.6,cGap,'Description',jtLeft);

     for pd := 0 to 11 do
     begin
       ColDate := IncDate(Job.Budget.buFields.buStart_Date,0,pd,0);
       AddFormatColAuto(Job,cLeft,5.3,cGap,StDateToDateString('nnn yy',ColDate,true),jtRight,'#,##0;(#,##0);-','#,##0;(#,##0);-',true);
     end;

     AddFormatColAuto(Job,cLeft,7.5,cGap,'Full 12Mths',jtRight,'#,##0;(#,##0);-', MyClient.FmtMoneyStrBrackets, True );

     //Add Footers
     AddCommonFooter(Job);
     
     Job.Generate( Destination);
   finally
    Job.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure DoBudgetListing(Destination : TReportDest;
                          RptBatch : TReportBase = nil);
begin
//print a list of the budget figures.
  DoSpecifiedBudgetListing(nil,Destination,RptBatch);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoSpecifiedBudgetReport(BudgetToReportOn : TBudget;
                                  Destination : TReportDest;
                                  RptBatch : TReportBase = nil);
//print a budgeted CASH FLOW for ths specified report
var
  btn      : integer;
  tmpReporting_Year_Starts : Integer;
  StartDate, Day, Month, Year : Integer;
  Params :TGenRptParameters;
begin
   //ask which budget to report on
   Params := TGenRptParameters.Create(ord(Report_Budget_12CashFlow), MyClient,RptBatch);
   try
     if (BudgetToReportOn = nil)  then
        Params.Budget := params.GetbatchBudget
     else
        Params.Budget := BudgetToReportOn;
     tmpReporting_Year_Starts := 0;
     repeat

        with params do
          if Batchrun then
          begin
           BudgetToReportOn := Params.Budget;
          end
          else
          begin
            Division := 0;
            Btn      := BTN_NONE;

            if (BudgetToReportOn = nil) then begin
              btn := GetBudgetOptions( Params );
              if btn = BTN_NONE then
                 Exit;

              BudgetToReportOn := Params.Budget;
              if not Assigned(BudgetToReportOn) then
                 Exit;
            end;

           //if Destination = rdNone then
            case btn of
              BTN_PRINT   : Destination := rdPrinter;
              BTN_PREVIEW : Destination := rdScreen;
              BTN_FILE    : Destination := rdFile;
              BTN_EMAIL   : Destination := rdEmail;
              BTN_SAVE    : Destination := rdNone;
              else Destination := rdAsk;
            end;
          end;

        if Destination <> rdNone then begin

           with params, Client, client.clFields do
           begin
             //store the current clReporting_Year_Starts
             tmpReporting_Year_Starts := clReporting_Year_Starts;

             clCflw_Cash_On_Hand_Style                 := cflCash_On_Hand_Summarised;
             clFRS_Compare_Type                        := cflCompare_None;

             clFRS_Show_Variance                       := False;
             clFRS_Show_YTD                            := True;
             clFRS_Show_Quantity                       := Params.ShowBudgetQuantities;
             clFRS_Print_Chart_Codes                   := Params.ChartCodes;
             clFRS_Reporting_Period_Type               := frpMonthly;
             clFRS_Report_Style                        := crsMultiplePeriod;

             //make sure the budget start date is the beginning of the month
             StDateToDMY(BudgetToReportOn.buFields.buStart_Date, Day, Month, Year);
             StartDate := DMYToStDate(1, Month, Year, EPOCH);
             clReporting_Year_Starts                   := StartDate;
             clFRS_Report_Detail_Type                  := cflReport_Detailed;
             clGST_Inclusive_Cashflow                  := ShowGST;
             clFRS_Prompt_User_to_use_Budgeted_figures := False;

             //now save temporary client variables
             clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
             clTemp_FRS_Last_Actual_Period_To_Use      := -1;   //0 would be use actual balances

             clTemp_FRS_From_Date                      := 0;
             clTemp_FRS_To_Date                        := 0;
             clTemp_FRS_Job_To_Use                     := '';
             clTemp_FRS_Division_To_Use                := Division;
             clTemp_FRS_Budget_To_Use                  := Budget.buFields.buName;
             clTemp_FRS_Budget_To_Use_Date             := Budget.buFields.buStart_Date;
             clTemp_FRS_Use_Budgeted_Data_If_No_Actual := True;
             clExtra.ceBudget_Include_Quantities       := Params.ShowBudgetQuantities;
             clTemp_FRS_Use_Budget_Quantities          := Params.ShowBudgetQuantities;

             //now set temporary flag into bank accounts;
             FlagAllAccountsForUse( MyClient);
           end;

           DoCashflowEx(Destination,params.ReportType, RptBatch);
           params.Client.clFields.clTemp_FRS_Use_Budget_Quantities := false;  //only report that uses this so far, so reset.
           Params.Budget := BudgetToReportOn; // save default..
           BudgetToReportOn := nil; // Reselect...
       end;
     until Params.RunExit(Destination);
        //reset clReporting_Year_Starts
     if Destination <> rdNone then
       params.Client.clFields.clReporting_Year_Starts := tmpReporting_Year_Starts;

   finally
      Params.Free;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoBudgetReport(Destination : TReportDest;
                         RptBatch : TReportBase = nil);
begin
  DoSpecifiedBudgetReport(nil,Destination,RptBatch);
end;


end.
