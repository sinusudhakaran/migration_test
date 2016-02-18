unit Reports;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    Reports

  Written:
  Authors:

  Purpose:  Handles the calling of all reports, except the GST 101

  Notes:

  Calling Templates:
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      (Sender : TObject);
      begin
        with TBKReport(Sender), AdminSystem do begin

        end;
      end;
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      (Dest : TReportDest);
      var
        Job : TBKReport;
      begin
        Job := TBKReport.Create;
        try
          //construct report
          Job.LoadReportSettings(Settings,Report_List_Names[REPORT_DOWNLOAD]);

          {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }{
          AddAdminHeader(Job);

          Job.OnBKPrint := nil;
          Job.Generate( Dest);
        finally
          Job.Free;
        end;
      end;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
   reportDefs, scheduled,YesNoDlg, SchedrepUtils,UBatchBase;

procedure DoReport(ReportType : Report_List_Type;
                   Destination : TReportDest;
                   HelpCtx : integer = 0;
                   RptBatch : TReportBase = nil;
                   InfoForReport: string = '';
                   ExtraReportInfo: Pointer = nil);

{$IFNDEF SmartBooks}
procedure DoAdminReport(ReportType : Report_List_Type; Destination : TReportDest; HelpCtx : integer = 0);
{$ENDIF}
function DoScheduledReport(ReportType : Report_List_Type; Destination : TReportDest; var srOptions : TSchReportOptions): Boolean;
procedure SetupScheduledReport(ReportType : Report_List_Type);

function DoScheduledFax( ReportType : Report_List_Type; Destination : TReportDest;
                          srOptions : TSchReportOptions): Boolean;
procedure SetupScheduledFax( ReportType : Report_List_Type );

procedure CheckDefaultFaxSettings;

procedure TestReport;
procedure TestPDFReport( i : integer);

//******************************************************************************
implementation

uses
   Forms,
   ReportTypes,
   RptParams,
   RptListings,
   RptLedgerReport,
   RptCashflow,
   RptBudget,
   RptBalanceSheet,
   RptProfit,
   RptCoding,
   RptCodingScheduled,
   RptException,
   RptPayee,
   RptJob,
   RptGST,
   RptBankRec,
   RptScheduled,
   RptTrialBalance,
   RptOffSite,
   NewReportUtils,
   ForexReports,
   RptAdmin,
   Globals,
   ShellAPI,
   PrintMgrObj,
   NewReportObj,
   Windows,
   LogUtil,
   PrintDestDlg,
   InfoMoreFrm,
   bkUtil32,
   bkConst,
   Admin32,
   NNWFax,
   SysUtils,
   ComObj,
   laDefs,
   repcols,
   UserReportSettings,
   ReportImages,
   WinFaxEventManager,
   ErrorMoreFrm,
   FaxParametersObj,
   WinUtils,
   CustomDocEditorFrm,
   AuditReportOptionsDlg,
   Files,
   RptContractorPayee,
   RptJournalList;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const
   UnitName = 'REPORTS';

var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoReport(ReportType: Report_List_Type; Destination: TReportDest;
                    HelpCtx: integer = 0;
                    RptBatch: TReportBase = nil; InfoForReport: string = ''; ExtraReportInfo: Pointer = nil);
var
  RunNow: Boolean;
  Msg : String;

   function LocalAsk(After: Boolean): Boolean;
   var Params: TRPTParameters;
   begin
      Result := False;
      Params := TRPTParameters.Create(ord(ReportType),nil,RptBatch);
      try
         if After
         and (Params.BatchRunMode = R_Batch) then
            Exit;
         RunNow := true;

         if SelectReportDest(Report_List_Names[ReportType], Params, HelpCtx) then begin

            case Params.RunBtn of
               BTN_PRINT    : Destination := rdPrinter;
               BTN_PREVIEW  : Destination := rdScreen;
               BTN_FILE     : Destination := rdFile;
               BTN_EMAIL    : Destination := rdEmail;
               BTN_SAVE     : case Params.BatchRunMode of
                              R_Setup,R_Batch,R_BatchAdd : exit;
                              {else begin
                                 Params.RptBatch.BatchRunMode := R_setup;
                                 RunNow := False;
                                 RptBatch := Params.RptBatch;
                              end; }
                              end;
               else Destination := rdScreen;
            end;
         end else Exit;

         Result := True;
       finally
          Params.Free;
       end;
   end;

begin
   if not Assigned(MyClient) then exit;

   //Save client file to ensure UK audit trail matches report
   if (MyClient.clFields.clCountry = whUK) then begin
//     Msg := Format('Report Run (%s)',[REPORT_LIST_NAMES[ReportType]]);
//     MyClient.ClientAuditMgr.FlagAudit(arClientFiles,
//                                       MyClient.clExtra.ceAudit_Record_ID,
//                                       aaNone,
//                                       Msg);
     SaveClient(false);
   end;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for any budget reports
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if ReportType in
      [
         REPORT_CASHFLOW_ACTBUD,
         REPORT_CASHFLOW_ACTBUDVAR,
         REPORT_CASHFLOW_12ACTBUD,
         REPORT_CASHFLOW_BUDREM,
         REPORT_PROFIT_ACTBUD,
         REPORT_PROFIT_ACTBUD_LY,
         REPORT_PROFIT_ACTBUDVAR,
         REPORT_PROFIT_12ACTBUD,
         REPORT_PROFIT_12BUD,
         REPORT_PROFIT_BUDREM,
         REPORT_BUDGET_LISTING,
         REPORT_BUDGET_12CASHFLOW,
         REPORT_PROFIT_EXPORT
      ]
        then if not HasBudgets then exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for payee reports
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if ReportType in
      [
         Report_List_Payee,
         REPORT_PAYEE_SPENDING,
         REPORT_PAYEE_SPENDING_DETAILED,
         Report_Taxable_Payments,
         Report_Taxable_Payments_Detailed
      ]
        then if not HasPayees then exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for job reports
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if ReportType in
      [
        Report_Job_Summary,
        Report_Job_Detailed
      ]

    then
      if not HasJobs then
        Exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for chart reports
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if ReportType in [ Report_List_Chart ] then if not HasAChart then exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for journals
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if ReportType in [ REPORT_LIST_JOURNALS ] then
           if not HasJournals then exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for bank accounts
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if ReportType in
      [
         Report_List_Entries,
         Report_List_BankAccts,
         Report_List_Manual,
         Report_List_Ledger,
         Report_Summary_List_Ledger,
         Report_Coding,
         Report_Coding_Standard,
         Report_Coding_Standard_With_Notes,
         Report_Coding_TwoCol,
         Report_Coding_TwoCol_With_Notes,
         Report_Coding_Details,
         Report_Coding_Anomalies,
         Report_Cashflow_Act,
         Report_Cashflow_12Act,
         Report_Cashflow_ActLastYVar,
         Report_BankRec_Sum,
         Report_BankRec_Detail,
         Report_Foreign_Exchange,
         Report_Unpresented_Items,
         Report_GST101,
         Report_Exception,
         Report_Cashflow_Date,
         Report_Cashflow_BudRem,
         Report_Profit_Date,
         Report_Profit_BudRem,
         REPORT_Profit_ACT,
         REPORT_Profit_ACT_LY,
         REPORT_Profit_12ACT,
         REPORT_PROFIT_12BUD,
         Report_GST_Summary,
         Report_GST_allocationSummary,
         Report_GST_Audit,
         Report_GST_Overrides,
         Report_TrialBalance,
         Report_Income_Expenditure,
         Report_GST_BusinessNorms,
         Report_Cashflow_Single,
         Report_Cashflow_Multiple,
         Report_ProfitAndLoss_Single,
         Report_ProfitAndLoss_Multiple,
         Report_BalanceSheet_Single,
         Report_BalanceSheet_Multiple,
         Report_Missing_Cheques
      ]
         then if ( not BKUTIL32.HasAccounts ) then exit;

   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // check for entries
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


   if ReportType in
      [
         Report_List_Entries,
         Report_List_Ledger,
         Report_Summary_List_Ledger,
         Report_Coding,
         Report_Coding_Standard,
         Report_Coding_Standard_With_Notes,
         Report_Coding_TwoCol,
         Report_Coding_TwoCol_With_Notes,
         Report_Coding_Details,
         Report_Coding_Anomalies,
         Report_Cashflow_Act,
         Report_Cashflow_12Act,
         Report_Cashflow_ActLastYVar,
         Report_Foreign_Exchange,
         Report_BankRec_Sum,
         Report_BankRec_Detail,
         Report_Unpresented_Items,
         Report_GST101,
         Report_Exception,
         Report_Cashflow_Date,
         Report_Cashflow_BudRem,
         Report_Profit_Date,
         Report_Profit_BudRem,
         REPORT_Profit_ACT,
         REPORT_Profit_ACT_LY,
         REPORT_Profit_12ACT,
         Report_GST_Summary,
         Report_GST_allocationSummary,
         Report_GST_Audit,
         Report_GST_Overrides,
         Report_TrialBalance,
         Report_Income_Expenditure,
         Report_GST_BusinessNorms,
         Report_Cashflow_Single,
         Report_Cashflow_Multiple,
         Report_ProfitAndLoss_Single,
         Report_ProfitAndLoss_Multiple,
         Report_BalanceSheet_Single,
         Report_BalanceSheet_Multiple,
         Report_Cashflow_Export,
         Report_Missing_Cheques
      ]
         then if ( not BKUTIL32.HasEntries ) then exit;

   { check if any printers exist in windows}
   if not AreThereAnyPrinters then
   begin
     HelpfulInfoMsg('You must setup a Windows Printer before running any Reports.  '+
                    SHORTAPPNAME+' will now take you to the Windows Printers Folder.  '+
                    'You can then select Add Printer to add a printer for windows to use.',0);
     ShellExecute(0, 'open', 'control.exe', 'printers', nil, SW_NORMAL);
     exit;
   end;
   RunNow := true;
   if Destination in [rdAsk] then
      if not Localask(False) then
            Exit;



   ShowClientNameOnReportStatus := true;

   try

     CreateReportImageList;
     try repeat
       //load report images only if doing a report that needs it
       (*
       if ReportType in [ REPORT_CASHFLOW_ACT, REPORT_CASHFLOW_ACTBUD, REPORT_CASHFLOW_ACTBUDVAR,
                          REPORT_CASHFLOW_12ACT, REPORT_CASHFLOW_12ACTBUD, Report_Cashflow_ActLastYVar,
                          REPORT_CODING, REPORT_CASHFLOW_DATE, REPORT_CASHFLOW_BUDREM,
                          REPORT_PROFIT_ACT,  REPORT_PROFIT_ACT_LY, REPORT_PROFIT_ACTBUD,
                          REPORT_PROFIT_ACTBUDVAR, REPORT_PROFIT_12ACT, REPORT_PROFIT_12ACTBUD,
                          REPORT_TRIALBALANCE, REPORT_BUDGET_12CASHFLOW, REPORT_CASHFLOW_SINGLE,
                          REPORT_CASHFLOW_MULTIPLE, REPORT_PROFITANDLOSS_SINGLE,
                          REPORT_PROFITANDLOSS_MULTIPLE, Report_BalanceSheet_Single,
                          Report_BalanceSheet_Multiple ] then
        LoadReportImageList;
        *)
      if RunNow then case ReportType of
         REPORT_LIST_CHART         : DoChartListReport(Destination,RptBatch);
         REPORT_LIST_ENTRIES       : DoListEntriesReport(Destination,false,RptBatch);
         REPORT_LIST_JOURNALS      : DoListJournalsReport(Destination, RptBatch);
         REPORT_LIST_BANKACCTS     : DoListBankAccountsReport(Destination,RptBatch);
         REPORT_LIST_PAYEE         : DoListPayeesReport(Destination,RptBatch);
         REPORT_LIST_MANUAL        : DoListManualAccountsReport(Destination,RptBatch);
         REPORT_LIST_LEDGER        : DoListLedgerReport(Destination,RptBatch);
         REPORT_LIST_DIVISIONS     : RptListings.DoListDivisions( Destination,RptBatch);
         REPORT_LIST_SUBGROUPS     : RptListings.DoListSubGroups( Destination,RptBatch);
         REPORT_LIST_JOBS          : RptListings.DoListJobs( Destination,RptBatch);
         REPORT_SUMMARY_LIST_LEDGER: DoListLedgerReport(Destination,RptBatch);
         REPORT_CODING             : DoCodingReport(Destination,RptBatch);
         REPORT_CASHFLOW_ACT       : DoCashflowActualReport(Destination,RptBatch);
         REPORT_CASHFLOW_ACTBUD    : DoCashflowActualBudgetReport(Destination,RptBatch);
         REPORT_CASHFLOW_ACTBUDVAR : DoCashflowActualBudgetVarianceReport(Destination,RptBatch);
         REPORT_CASHFLOW_12ACT     : DoCashflow12ActualReport(Destination,RptBatch);
         REPORT_CASHFLOW_12ACTBUD  : DoCashflow12ActualBudgetReport(Destination,RptBatch);
         Report_Cashflow_ActLastYVar: DoCashflowActualLastYearVariance(Destination,RptBatch);
         Report_Foreign_Exchange   : DoListForexEntriesReport( Destination, RptBatch, InfoForReport, ExtraReportInfo );
         REPORT_BANKREC_SUM        : DoBankRecReport(Destination,false,RptBatch);
         REPORT_BANKREC_DETAIL     : DoBankRecReport(Destination,true,RptBatch);
         REPORT_UNPRESENTED_ITEMS  : RptBankRec.DoUnpresentedItemsReport( Destination,RptBatch);
         REPORT_PAYEE_SPENDING     : DoPayeeSpendingReport(Destination,Rptbatch);
         Report_Job_Summary       : DoJobSpendingReport(Destination, Rptbatch);	
    //     REPORT_PAYEE_SPENDING_DETAILED: DoDetailedPayeeSpendingReport(Destination);
    //     REPORT_GST101            : DoGST101Report(Destination);
         REPORT_EXCEPTION          : DoExceptionReportEx(Destination,RptBatch);
         REPORT_CASHFLOW_DATE      : DoCashflowDate(Destination,RptBatch);
         REPORT_CASHFLOW_BUDREM    : DoCashflowBudgetRem(Destination,RptBatch);
         REPORT_PROFIT_ACT         : DoProfitActualReport(Destination,RptBatch);
         REPORT_PROFIT_ACT_LY      : DoProfitActualLYReport(Destination,RptBatch);
         REPORT_PROFIT_ACTBUD      : DoProfitActualBudgetReport(Destination,RptBatch);
    //      REPORT_PROFIT_ACTBUD_LY   : DoProfitActualBudgetLYReport(Destination);
         REPORT_PROFIT_ACTBUDVAR   : DoProfitActualBudgetVarianceReport(Destination,RptBatch);
         REPORT_PROFIT_12ACT       : DoProfit12ActualReport(Destination,RptBatch);
         REPORT_PROFIT_12ACTBUD    : DoProfit12ActualBudgetReport(Destination,RptBatch);
         REPORT_PROFIT_12BUD       : DoProfit12BudgetReport(Destination, RptBatch);
    //     REPORT_PROFIT_DATE       : DoProfitDate(Destination);
    //     REPORT_PROFIT_BUDREM      : DoProfitBudgetRem(Destination);
         REPORT_GST_SUMMARY        : DoGSTSummary(Destination,RptBatch);
         Report_GST_allocationSummary : DoGSTAllocationSummary(Destination,RptBatch);
         REPORT_GST_SUMMARY_12     : DoGSTReconciliation(Destination,RptBatch);
         REPORT_GST_AUDIT          : DoGSTAudit(Destination,RptBatch);
         REPORT_GST_OVERRIDES      : DoGSTOverrides(Destination,RptBatch);
         REPORT_GST_BUSINESSNORMS  : DoBusinessNorms(Destination,RptBatch);
         REPORT_LIST_GST_DETAILS   : DoListGSTDetails( Destination,RptBatch);
         REPORT_BUDGET_LISTING     : DoBudgetListing(Destination,RptBatch);
         REPORT_BUDGET_12CASHFLOW  : DoBudgetReport(Destination,RptBatch);
         REPORT_TRIALBALANCE       : DoTrialBalance(Destination,RptBatch);
    {$IFDEF SmartBooks}
         REPORT_INCOME_EXPENDITURE : DoIncomeExpenditure(Destination);
    {$ENDIF}
         REPORT_DOWNLOAD_LOG_OFFSITE: DoOffsiteDownloadLog(Destination);
         REPORT_LIST_MEMORISATIONS  : DoListMemorisations( Destination, RptBatch);

         REPORT_CASHFLOW_SINGLE,
         REPORT_CASHFLOW_MULTIPLE   : DoCashflowEx(Destination,ord(REPORT_CASHFLOW_SINGLE),RptBatch);
         REPORT_PROFITANDLOSS_SINGLE,
         REPORT_PROFITANDLOSS_MULTIPLE : DoProfitAndLossEx(Destination,ord(REPORT_PROFITANDLOSS_SINGLE),RptBatch);
         Report_BalanceSheet_Single,
         Report_BalanceSheet_Multiple  : DoBalanceSheet( Destination, RptBatch);
         Report_Cashflow_Export     : DoCashflowExport;
         Report_Profit_Export       : DoProfitExport;
         Report_BalanceSheet_Export : DoBalanceExport;
         Report_Missing_Cheques     : RptBankRec.DoMissingChequesReport( Destination, RptBatch);
         REPORT_TEST_FAX            : DoTestFax( Destination);
         REPORT_CUSTOM_DOCUMENT     : CustomDocManager.DoCustomDoc(MyClient, RptBatch, Destination);
         REPORT_TAXABLE_PAYMENTS    : RptContractorPayee.DoTaxablePaymentsReport(Destination, Rptbatch);
      else
         ;
      end;

      if  (ReportType in [ // These do not have their own dialog
              Report_List_GST_Details,
              Report_List_Jobs,
              Report_List_Divisions,
              Report_List_SubGroups,
              Report_List_bankAccts,
              REPORT_DOWNLOAD_LOG_OFFSITE,
              REPORT_CUSTOM_DOCUMENT
           ]) then begin
               if not LocalAsk(True) then
                   Break; // Canceled
       end else
          Break; // "normal" report

     until False;
    finally
      DestroyReportImageList;
    end;
  except
     on E : Exception do
     begin
       helpfulinfomsg( 'Unhandled exception ' + E.Message, 0);
     end;
  end;
end;

//------------------------------------------------------------------------------
function DoScheduledReport(ReportType : Report_List_Type; Destination : TReportDest;
                           var srOptions : TSchReportOptions): Boolean;
{
   Information in the srOptions record is only used by some of the reports,
   however it is passed in the this routine anyway to avoid having an
   overloaded procedure.

   This routine temporarily loads the SCHEDULE.PRS file to read the print settings
   for scheduled reports.
}
var
  SchedulePRS : TPrintManagerObj;
  RequiresClient,
  RequiresAdmin : boolean;

begin
  Result := True;
  srOptions.srAttachment := '';
  RequiresClient := ReportType in [REPORT_LIST_CHART, REPORT_LIST_PAYEE, REPORT_CODING,
                                   REPORT_CLIENT_HEADER, REPORT_LIST_JOBS];

  RequiresAdmin  := ReportType in [REPORT_STAFF_MEMBER_HEADER, REPORT_GROUP_HEADER, REPORT_CODING];

  if RequiresClient and (not Assigned(MyClient))then exit;
  if RequiresAdmin and (not Assigned(AdminSystem))then exit;

  ShowClientNameOnReportStatus := true;

  SchedulePRS := TPrintManagerObj.Create;
  try
    SchedulePRS.FileName := DATADIR + SCHEDULED_REPORTS_ID + USERPRINTEXTN;
    SchedulePRS.Open;

    case ReportType of
      REPORT_LIST_CHART          : DoChartListReport( Destination, SchedulePRS, true);
      REPORT_LIST_PAYEE          : DoListPayeesReport( Destination, SchedulePRS, true);
      REPORT_LIST_JOBS           : DoListJobsReport( Destination, SchedulePRS, true);
      REPORT_CODING              : begin
         Result := DoScheduledCodingReport( Destination, srOptions, SchedulePRS);
      end;
      REPORT_CLIENT_HEADER       : DoClientHeader( Destination, srOptions.srTrxFromDate, srOptions.srTrxToDate, SchedulePRS);
      REPORT_STAFF_MEMBER_HEADER : DoStaffHeaderPage( Destination, srOptions.srUserLRN, SchedulePRS);
      REPORT_GROUP_HEADER        : DoGroupHeaderPage( Destination, srOptions.srUserLRN, SchedulePRS);
      REPORT_CLIENT_TYPE_HEADER  : DoClientTypeHeaderPage( Destination, srOptions.srUserLRN, SchedulePRS);

      REPORT_SCHD_REP_SUMMARY    : DoScheduleReportsSummary( Destination, SchedulePRS, srOptions);
      REPORT_WHATSDUE            : DoReportsDue( Destination, srOptions);
      REPORT_CUSTOM_DOCUMENT     : if Destination = rdfax then
                                      DoScheduledfax(REPORT_CUSTOM_DOCUMENT,rdfax,srOptions)
                                   else
                                      Result := CustomDocManager.DoScheduledCustomDoc(Destination, SchedulePRS,srOptions);
    end;

  finally
    SchedulePRS.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure SetupScheduledReport(ReportType : Report_List_Type);
var
  Job : TBKReport;
  SchedulePRS : TPrintManagerObj;
begin
  SchedulePRS := TPrintManagerObj.Create;
  try
    SchedulePRS.FileName := DATADIR + SCHEDULED_REPORTS_ID + USERPRINTEXTN;
    SchedulePRS.Open;

    Job := TBKReport.Create(ReportTypes.rptOther);
    try
      Job.LoadReportSettings(SchedulePRS,Report_List_Names[ReportType]);
      Job.SetupReport( rdPrinter);
    finally
      Job.Free;
    end;
    SchedulePRS.Save;
  finally
    SchedulePRS.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFNDEF SmartBooks}
procedure DoAdminReport(ReportType : Report_List_Type; Destination : TReportDest; HelpCtx : integer = 0);
var
 btn : integer;
begin
   if not RefreshAdmin then exit;

   { check if any printers exist in windows}
   if not AreThereAnyPrinters then begin
     HelpfulInfoMsg('You must setup a Windows Printer before running any Reports.  '+
                    SHORTAPPNAME+' will now take you to the Windows Printers Folder.  '+
                    'You can then select Add Printer to add a printer for windows to use.',0);
     ShellExecute(0, 'open', 'control.exe', 'printers', nil, SW_NORMAL);
     exit;
   end;

   if ReportType in [REPORT_ADMIN_ACCOUNTS,REPORT_ADMIN_INACTIVE_ACCOUNTS,REPORT_LIST_MANUAL] then begin
      if (AskYesNo( Report_List_Names[ReportType], 'The ' + Report_List_Names[ReportType] + ' Report may take a while '+
                 'to complete as it must access transaction archive information from the file system. '#13#13+
                 'Are you sure you want to run this report now?',DLG_YES,0 ) <> DLG_YES )
        then
            exit;
   end;

   CreateReportImageList;
   try
   repeat
      if Destination = rdAsk then
      if SimpleSelectReportDest(Report_List_Names[ReportType], Btn, HelpCtx) then
      begin
         case Btn of
            BTN_PRINT   : Destination := rdPrinter;
            BTN_PREVIEW : Destination := rdScreen;
            BTN_FILE    : Destination := rdFile;
            BTN_EMAIL   : Destination := rdEmail;
         else
            Destination := rdScreen;
         end;
      end
      else exit;

      ShowClientNameOnReportStatus := false;

      case ReportType of
      REPORT_DOWNLOAD        : DoDownloadReport(Destination);
      REPORT_SUMMARY_DOWNLOAD: DoSummarisedDownloadReport(Destination);
      REPORT_ADMIN_ACCOUNTS  : DoListAdminBankAccounts(False, Destination);
      REPORT_ADMIN_INACTIVE_ACCOUNTS  : DoListAdminBankAccounts(True, Destination);
      REPORT_PROV_ACCOUNTS   : DoListAdminBankAccounts(False, Destination, True);
      REPORT_CLIENTS_BY_STAFF: DoClientsByStaffMember(Destination);
      REPORT_CLIENT_REPORT_OPT:DoClientReportOptions(Destination);
      REPORT_DOWNLOAD_LOG    : DoDownloadLog(Destination);
      REPORT_CLIENT_STATUS   : DoClientStatusReport(Destination);
      REPORT_CODING_OPTIMISATION : DoCodingOptimisationReport(Destination);
      REPORT_AUDIT           : DoAuditreport(Destination);
      REPORT_LIST_MANUAL     : DoListManualAccountsReport(Destination);

      List_Groups            : DoGroupList(Destination);
      List_Client_Types      : DoClientTypelistList(Destination);

      Report_File_Access_Control : DoClientFileAccessControl( Destination );
      end;
      if ReportType in [REPORT_SUMMARY_DOWNLOAD,
                        REPORT_CLIENTS_BY_STAFF,
                        REPORT_CLIENT_REPORT_OPT,
                        REPORT_DOWNLOAD_LOG,
                        List_Groups,
                        List_Client_Types,
                        Report_File_Access_Control] then
          Destination := rdAsk;

   until Destination = rdNone;
   finally
     DestroyReportImageList;
   end;
end;
{$ENDIF}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoScheduledFax_WinFax( ReportType : Report_List_Type; Destination : TReportDest;
                          srOptions : TSchReportOptions): Boolean;
{
   Information in the srOptions record is only used by some of the reports,
   however it is passed in the this routine anyway to avoid having an
   overloaded procedure.

   This routine temporarily loads the FAX.PRS file to read the print settings
   for scheduled faxes.

   Steve Teare, 29 April 2004:
   Tried to make this a bit more reliable:
   - loading up the Fax.PRS file settings is now done before we get to the printing
     because its done from disk and may slow things down.
   - added a delay after the SendFax call to try to make sure it has completed the call,
     although NNWFax is looping waiting for IsReadyToPrint to become true so it should have been ok.
   - its now checking the last error status after the SendFax call - if there was an error
     then it doesnt try to print, instead raises an exception and halts the send of this report.
   - added an error message to tell user if something goes wrong cos in some cases
     it was just not sent and the user didn't know why.
}
var
   RequiresClient,
   RequiresAdmin : boolean;
   FaxObj        : TNNWFax;
   Recipient     : TRecipient;
   CoverFileName : String;
   msToWait : integer;
   EventMgr: TWinFaxEventMgr;
   Msg: string;
   ClientCode : string;
begin
   Result := True;
   RequiresClient := ReportType in [ REPORT_LIST_CHART, REPORT_LIST_PAYEE, REPORT_LIST_JOBS, REPORT_CODING ];
   RequiresAdmin  := ReportType in [ REPORT_CODING];

   if RequiresClient and (not Assigned(MyClient))then exit;
   if RequiresAdmin and (not Assigned(AdminSystem))then exit;

   ShowClientNameOnReportStatus := true;

   //winfax seems to have additional problems if a coverpage has been specified
   //to compensate for this we wait longer if a coverpage is being done
   if ( AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name <> '') and
      ( ReportType = REPORT_CODING ) then
     msToWait := Globals.PRACINI_msToWaitForWinfax * 2
   else
     msToWait := Globals.PRACINI_msToWaitForWinfax;

   try
      EventMgr := TWinFaxEventMgr.Create;
      FaxObj := TNNWFax.Create( NIL );
      Try
         Try
            EventMgr.SetFaxEvents(FaxObj);

            FaxObj.PrintFromApplication := True;
            FaxObj.Cover                := cNoCover;
            FaxObj.Resolution           := rFine;
            FaxObj.PreviewBeforeSending := False;
            FaxObj.ShowSendScreen       := False;
            Recipient             := FaxObj.Recipients.Add;

            if ReportType = REPORT_TEST_FAX then
            begin
              FaxObj.Subject := 'Test Fax';
              Recipient.Company     := srOptions.srTestFaxRecip;
              Recipient.Name        := 'Contact Name';
              Recipient.LocalNumber := srOptions.srTestFaxNumber;
              ClientCode := 'TEST';

              if BKFileExists( srOptions.srTestCoverpageFilename) then
              begin
                FaxObj.Cover := cCoverFile;
                FaxObj.CoverFile := srOptions.srTestCoverpageFilename;
                FaxObj.Subject := 'Cover page subject goes here';
                FaxObj.CoverText.Add( 'Cover page text goes here');
              end;
            end
            else
            begin
              FaxObj.Subject        := REPORT_LIST_NAMES[ ReportType] + ' (' + MyClient.clFields.clCode + ')';
              Recipient.Company     := MyClient.clFields.clName;
              Recipient.Name        := MyClient.clFields.clContact_Name;
              Recipient.LocalNumber := MyClient.clFields.clFax_No;
              ClientCode := MyClient.clFields.clCode;
            end;

            CoverFileName := AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name;
            If ( ReportType = REPORT_CODING ) and BKFileExists( CoverFileName ) then begin
               FaxObj.Cover     := cCoverFile;
               FaxObj.CoverFile := AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name;
               FaxObj.Subject   := '[' + MyClient.clFields.clCode + '] ' +
                                   AdminSystem.fdFields.fdSched_Rep_Cover_Page_Subject;
               FaxObj.CoverText.Add( ' ' );
               if ( MyClient.clFields.clScheduled_Client_Note_Message <> '') then
                  FaxObj.CoverText.Add( MyClient.clFields.clScheduled_Client_Note_Message);
               if ( AdminSystem.fdFields.fdSched_Rep_Cover_Page_Message <> '') then
                  FaxObj.CoverText.Add( AdminSystem.fdFields.fdSched_Rep_Cover_Page_Message);
            end;

            If AdminSystem.fdFields.fdSched_Rep_Send_Fax_Off_Peak then
               Recipient.Delivery := dOffPeak
            else
               Recipient.Delivery := dSendNow;

            if (FaxObj.SendFax) then
            begin
              try
                 Sleep( msToWait); //give NNWFax time to re-initialise
                 Application.ProcessMessages;
                 Sleep( msToWait); //give NNWFax time to re-initialise
                 // Check ok to continue
                 if EventMgr.IsWinFaxReady(FaxObj, Msg) then
                 begin
                   Case ReportType of
                      REPORT_LIST_CHART : DoChartListReport( rdFax, Globals.FaxPrintSettings, true);
                      REPORT_LIST_PAYEE : DoListPayeesReport( rdFax, Globals.FaxPrintSettings, true);
                      REPORT_LIST_JOBS  : DoListJobsReport( rdFax, Globals.FaxPrintSettings, true);
                      REPORT_CODING     : DoScheduledCodingReport( rdFax, srOptions, Globals.FaxPrintSettings );
                      REPORT_TEST_FAX   : DoTestFax( rdFax, Globals.FaxPrintSettings, nil);
                   end;
                 end
                 else
                   raise EOleError.Create(Msg);
              Finally
                Sleep( msToWait); //give NNWFax time to re-initialise
                Application.ProcessMessages;
                Sleep( msToWait); //give NNWFax time to re-initialise
              end;
            end;
         Except // Swallow all exceptions.
            On E : Exception do
            begin
              EventMgr.IsError := True;
              Result := False;
              Msg := 'Failed to Fax "' + REPORT_LIST_NAMES[ReportType] +
                     ' Report" for ' + ClientCode +  ': ' + E.Message;
              LogUtil.LogError( UnitName, Msg);
              //HelpFulErrorMsg(Msg, 0);  mjch - Don't want to interupt user
           end;
         end;
      Finally
         Sleep( msToWait); //give NNWFax time to re-initialise
         Application.ProcessMessages;
         Sleep( msToWait); //give NNWFax time to re-initialise
         Result := EventMgr.WaitForFaxSent;
         EventMgr.Free;
         FaxObj.Free;
      end;
   except
      On E : EOleError do
         LogUtil.LogError( Unitname, 'Fax Failed for ' +
                           MyClient.clFields.clCode + ': ' + E.Message + ' [' +
                           E.ClassName + ']');
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoScheduledFax_WindowsFaxService( ReportType : Report_List_Type; Destination : TReportDest;
                          srOptions : TSchReportOptions): Boolean;
var
  fp : TFaxParameters;
  RequiresClient,
  RequiresAdmin : boolean;
  cpFilename : string;
  cpSubject : string;
  cpText : string;
  ClientCode : string;
begin
   result := true;
   //make sure this is a scheduled report
   if not ( ReportType in [Report_Custom_Document, REPORT_LIST_CHART, REPORT_LIST_PAYEE, REPORT_LIST_JOBS, REPORT_CODING, REPORT_TEST_FAX ]) then
     Exit;

   RequiresClient := ReportType in [ REPORT_LIST_CHART, REPORT_LIST_PAYEE, REPORT_LIST_JOBS, REPORT_CODING, Report_Custom_Document ];
   RequiresAdmin  := ReportType in [ REPORT_CODING, Report_Custom_Document];

   if RequiresClient and (not Assigned(MyClient))then
     exit;
   if RequiresAdmin and (not Assigned(AdminSystem))then
     exit;

   ShowClientNameOnReportStatus := true;
   try
     if (ReportType in [REPORT_CODING]) and (AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name <> '') and
        (BKFileExists(AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name)) then
     begin
       cpFilename := AdminSystem.fdFields.fdSched_Rep_Cover_Page_Name;
       cpSubject := AdminSystem.fdFields.fdSched_Rep_Cover_Page_Subject;
       cpText := '';
       if ( MyClient.clFields.clScheduled_Client_Note_Message <> '') then
          cpText := cpText + #13 + MyClient.clFields.clScheduled_Client_Note_Message;
       if ( AdminSystem.fdFields.fdSched_Rep_Cover_Page_Message <> '') then
          cpText := cpText + #13 + AdminSystem.fdFields.fdSched_Rep_Cover_Page_Message;
     end
     else
     begin
       cpFilename := '';
       cpSubject := '';
       cpText := '';
     end;

     //Offpeak faxing is not available in the Windows Faxing API

       // If AdminSystem.fdFields.fdSched_Rep_Send_Fax_Off_Peak then
       //    Recipient.Delivery := dOffPeak
       // else
       //    Recipient.Delivery := dSendNow;

     if ReportType = REPORT_TEST_FAX then
     begin
       ClientCode := 'TEST';
       fp := TFaxParameters.NewFaxParameters( srOptions.srTestFaxRecip,
                                              'Client Code',
                                              srOptions.srTestFaxNumber,
                                              REPORT_LIST_NAMES[ ReportType] + ' (TEST)',
                                              srOptions.srTestCoverpageFilename,
                                              'Cover page subject goes here',
                                              'Cover page text goes here',
                                              'Practice Name');
     end
     else
     begin
       ClientCode := MyClient.clFields.clCode;
       fp := TFaxParameters.NewFaxParameters( MyClient.clFields.clName,
                                              MyClient.clFields.clContact_Name,
                                              MyClient.clFields.clFax_No,
                                              REPORT_LIST_NAMES[ ReportType] + ' (' + ClientCode + ')',
                                              cpFilename,
                                              cpSubject,
                                              cpText,
                                              MyClient.clFields.clPractice_Name);
     end;

     try
       Case ReportType of
         REPORT_LIST_CHART : result := DoChartListReport( rdFax, Globals.FaxPrintSettings, true, fp );
         REPORT_LIST_PAYEE : result := DoListPayeesReport( rdFax, Globals.FaxPrintSettings, true, fp );
         REPORT_LIST_JOBS  : result := DoListJobsReport( rdFax, Globals.FaxPrintSettings, true, fp );
         REPORT_CODING     : result := DoScheduledCodingReport( rdFax, srOptions, Globals.FaxPrintSettings, fp );
         REPORT_TEST_FAX :   result := DoTestFax( rdFax, Globals.FaxPrintSettings, fp);
         Report_Custom_Document : Result := 
              CustomDocManager.DoScheduledCustomDoc(rdFax, Globals.FaxPrintSettings,srOptions, fp);
       end;
     finally
       fp.Free;
     end;
   except
      On E : Exception do
      begin
         result := false;
         LogUtil.LogError( Unitname, 'Fax Failed for ' +
                           ClientCode + ': ' + E.Message + ' [' +
                           E.ClassName + ']');
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoScheduledFax( ReportType : Report_List_Type; Destination : TReportDest;
                          srOptions : TSchReportOptions): Boolean;
var
  ft : byte;
begin
   if Assigned( AdminSystem) then
     ft := AdminSystem.fdFields.fdSched_Rep_Fax_Transport
   else
     ft := fxtNone;

   case ft of
     bkConst.fxtWinFax :  result := DoScheduledFax_WinFax( ReportType, Destination, srOptions);
     bkConst.fxtWindowsFaxService : result := DoScheduledFax_WindowsFaxService( ReportType, Destination, srOptions);
   else
     begin
       result := false;
       LogUtil.LogError( Unitname, 'Fax Failed for ' + MyClient.clFields.clCode + ': Unknown Transport.');
     end;
   end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetupScheduledFax( ReportType : Report_List_Type );
var
  Job : TBKReport;
  FaxSchedulePRS : TPrintManagerObj;
begin
  FaxSchedulePRS := TPrintManagerObj.Create;
  try
    FaxSchedulePRS.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;
    FaxSchedulePRS.Open;
    Job := TBKReport.Create(ReportTypes.rptOther);
    try
      Job.LoadReportSettings( FaxSchedulePRS,Report_List_Names[ ReportType ] );
      Job.SetupReport( rdFax );
    finally
      Job.Free;
    end;
    FaxSchedulePRS.Save;
  finally
    FaxSchedulePRS.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckDefaultFaxSettings;
var
  FaxSchedulePRS : TPrintManagerObj;
  Report: REPORT_LIST_TYPE;
  Updated: Boolean;
  UserReportSettings : pWindows_Report_Setting_Rec;

begin
  Updated := False;
  FaxSchedulePRS := TPrintManagerObj.Create;
  try
    FaxSchedulePRS.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;

    for Report in [REPORT_CODING,REPORT_LIST_PAYEE,REPORT_LIST_JOBS,REPORT_LIST_CHART,REPORT_TEST_FAX,REPORT_CUSTOM_DOCUMENT] do begin
        UserReportSettings := FaxSchedulePRS.pmWindows_Report_Setting_List.Find_Windows_Report_Setting(Report_List_Names[Report]);
        if not assigned(UserReportSettings) then begin
           UserReportSettings := GetDefaultReportSettings(Report_List_Names[Report]);
           with UserReportSettings^ do begin
              s7Is_Default    := false;
              s7Save_Required := false;
              s7Printer_Name  := '';
           end;
           InsertNewUserReportSettings(FaxSchedulePRS, UserReportSettings);
           Updated := True;
        end;
    end;

    //commit new settings
    if Updated then
       FaxSchedulePRS.Save;
  finally
    FaxSchedulePRS.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestDetail(Sender:TObject);
var
   i       : integer;
begin
   with TBKReport(Sender) do
   begin
     for i := 1 to 10 do
       RenderTextLine('Line ' + inttostr(i));
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestReport;
var
  MyReport : TBkReport;
begin
  MyReport := TbkReport.Create(ReportTypes.rptOther);
  try
    MyReport.LoadReportSettings(UserPrintSettings,'TEST');
    MyReport.OnBkPrint := TestDetail;
    AddJobHeader(MyReport,jtCenter,1.6,'TEST REPORT',true);
    MyReport.Generate( rdScreen);
  finally
    MyReport.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TestPDFReport( i : integer);
var
  MyReport : TBkReport;
begin
  MyReport := TbkReport.Create(ReportTypes.rptOther);
  try
    MyReport.LoadReportSettings(UserPrintSettings,'TEST');
    MyReport.OnBkPrint := TestDetail;
    AddJobHeader(MyReport,jtCenter,1.6,'TEST REPORT '+inttostr(i),true);
    MyReport.GenerateToFile( 'apdf'+inttostr(i)+'.pdf', rfpdf);
  finally
    MyReport.Free;
  end;
end;


initialization
  DebugMe := DebugUnit(UnitName);
end.   
