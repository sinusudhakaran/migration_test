unit SimpleUIhomepagefrm;
//------------------------------------------------------------------------------
{
   Title: SimpleUI HomePage form

   Description: Homepage form for simplified UI.  Default view for Smartbooks

   Author: Matthew Hopkins Aug 2010

   Remarks: Descends from TBaseClientHomepage declared in ClientHomePageFrm
            The reason to descend from here is to minimise the need to change
            all of the references to ClientHomePageFrm in units that call it.




}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ClientHomePagefrm, CodingFormCommands, clObj32, StdCtrls, ExtCtrls,
  RzPanel, ActnList;

type
  TfrmSimpleUIHomePage = class(TBaseClientHomepage)
    pnlFrameHolder: TPanel;
    pnlNavigator: TPanel;
    lblHome: TLabel;
    lblNavLevel1: TLabel;
    lblNavLevel2: TLabel;
    lblNavLevel3: TLabel;
    pnlExtraTitleBar: TRzPanel;
    lblClientName: TLabel;
    lblCurrentPeriod: TLabel;
    imgRight: TImage;
    imgLeft: TImage;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure RefreshClient;
    procedure RefreshFiles;
    procedure RefreshCoding;
    procedure RefreshStatus;
    procedure FormActivate(Sender: TObject);
    procedure lblHomeClick(Sender: TObject);
    procedure lblNavLevel1Click(Sender: TObject);
  private
    { Private declarations }
    FDisableProcessing : Boolean;      //stop processing, either on file open or close
    FClosingClient : Boolean;          //need to close client file
    FAbandon : Boolean;                //mh - what is this for?

    FLockCount: Integer;
    FCurrentClient : TClientObj;
    FRefreshRequest : THP_Refresh;

    FLastDownloadedTransDate : integer;

    CurrentFrame : TFrame;
    CurrentFrameIndex : integer;
    FTransInCurrentPeriodCount: integer;
    FNumStatementsToCode: integer;
    FLastBackupDateTime: TDateTime;
    FLastBackupSucceeded: boolean;
    procedure ProcessPendingRefreshRequest;
    procedure SwitchToFrame( NewFrameIndex : integer);

    procedure wmsyscommand( var msg: TWMSyscommand ); message wm_syscommand;
    function FindStartDateOfLatestUncodedMonth: integer;
    function GetLastDownloadedDate: integer;
    procedure SetLastBackupDateTime(const Value: TDateTime);
    procedure SetLastBackupSucceeded(const Value: boolean);

  protected
    function GetGlobalRedrawForeign: boolean; override;
    procedure SetGlobalRedrawForeign(Value: boolean); override;
    function GetTheClient : TClientObj; override;
    procedure SetTheClient(const Value: TClientObj); override;
    function GetRefreshRequest : THP_Refresh; override;
    procedure SetRefreshRequest(const Value: THP_Refresh); override;
    function GetAbandon : boolean; override;
    procedure SetAbandon(const Value: Boolean); override;
  public
    { Public declarations }
    procedure Lock; override;
    procedure Unlock; override;
    procedure ProcessExternalCmd(Command : TExternalCmd); override;
    procedure ResetSUIPeriod;
    property ReadCurrentClient : TClientObj read GetTheClient;
    property LastDownloadTransDate : integer read GetLastDownloadedDate;
    property TransInCurrentPeriodCount : integer read FTransInCurrentPeriodCount;
    property NumStatementsToCode : integer read FNumStatementsToCode;
    property LastBackupDateTime : TDateTime read FLastBackupDateTime write SetLastBackupDateTime;
    property LastBackupSucceeded : boolean read FLastBackupSucceeded write SetLastBackupSucceeded;
    function CheckFinished : boolean;
    function GetFillDate: integer; override;
  end;

  procedure DoSimpleUICommand( command : byte);
  procedure ChangeHomepageFrame( NewFrameIndex : integer);

const
  //main form_modal command
  sui_mcUnknown                 = 0;
  sui_mcOpenFile                = 1;
  sui_mcCheckIn                 = 4;
  sui_mcCheckOut                = 5;
  sui_mcAbandon                 = 6;
  sui_mcSave                    = 7;
  sui_mcSaveAs                  = 8;
  sui_mcOpenFromMRU             = 9;
  sui_mcCoding                  = 10;
  sui_mcHDE                     = 11;
  sui_mcBudgets                 = 12;
  sui_mcCashJournals            = 13;
  sui_mcAccrualJournals         = 14;
  sui_mcOpeningBalanceJnls      = 15;
  sui_mcOpeningBalances         = 19;
  sui_mcYearEnd                 = 20;
  sui_mcClientDetails           = 21;
  sui_mcGSTDetails              = 23;
  sui_mcMaintainChart           = 25;
  sui_mcMaintainPayees          = 28;
  sui_mcMaintainBankAccounts    = 29;
  sui_mcMaintainMems            = 30;
  sui_mcClearTransferFlags      = 39;
  sui_mcLockPeriod              = 40;
  sui_mcUnlockPeriod            = 41;
  sui_mcSynchronise             = 45;
  sui_mcAnnualGSTReport         = 46;
  sui_mcAnnualGSTReturn         = 47;
  sui_mcOffsiteBackup           = 50;
  sui_mcOffsiteRestore          = 51;
  sui_mcMDE                     = 55;
  sui_mcmaintainJob             = 63;
  sui_mcSetTransferFlags        = 64;
  sui_mcChangePeriod            = 66;
  sui_mcCodingCurrent           = 68;
  sui_mcFinished                  = 69;
  sui_mcMaintainDiv             = 70;

  sui_mcRetrieveData            = 100;
  sui_mcSystemOptions           = 101;
  sui_mcEmailSupport            = 102;

  sui_mcBankRecSummary_Cur      = 103;
  sui_mcProfitAndLossAct_Cur    = 104;
  sui_mcGSTAuditreport_Cur      = 105;
  sui_mcCashflowAct_Cur         = 106;
  sui_mcGraphs_Cur              = 107;
  sui_mcGSTReturn_Cur           = 108;
  sui_mcCheckForUpdates         = 109;
  sui_mcCodingReport            = 110;
  sui_mcLedgerReport            = 111;
  sui_mcPayeeReport             = 112;
  sui_mcJobsReport              = 113;
  sui_mcTrialBalanceReport      = 114;
  sui_mcGraphsR                 = 115;

  sui_mcCFA                     = 120;
  sui_mcCFAB                    = 121;
  sui_mcCFABV                   = 122;
  sui_mcCF12A                   = 123;
  sui_mcCF12B                   = 124;
  sui_mcCF12AB                  = 125;
  sui_mcCFDateToDate            = 126;
  sui_mcCFBudRem                = 127;
  sui_mcThisYearLastYear        = 128;

  sui_mcPLA                     = 140;
  sui_mcPLAB                    = 141;
  sui_mcPLABV                   = 142;
  sui_mcPL12A                   = 143;
  sui_mcPL12B                   = 144;
  sui_mcPL12AB                  = 145;

  sui_mcBankRecSum              = 150;
  sui_mcBankRecDet              = 151;

  sui_mcListBankAccounts        = 160;
  sui_mcListChart               = 161;
  sui_mcListPayees              = 162;
  sui_mcListJobs                = 163;
  sui_mcListJournals            = 164;
  sui_mcListMems                = 165;
  sui_mcListMissingCheques      = 166;
  sui_mcListEntries             = 167;

  sui_mcGSTReturnR              = 170;
  sui_mcGSTAuditR               = 171;
  sui_mcGSTSummaryR             = 172;
  sui_mcGSTDetailsR             = 173;
  sui_mcGSTAnnualReturnAU       = 174;
  sui_mcGSTAnnualReportAU       = 175;

  sui_mcAddCashJnl              = 180;
  sui_mcAddAccrualJnl           = 181;
  sui_mcViewCashJnl             = 182;
  sui_mcViewAccrualJnl          = 183;
  sui_mcTaxablePayments         = 184;



const
  suiHomepage = 0;
  suiMorepage = 1;
  suiStdReportsPage = 2;
  suiMoreInputPage = 3;
  suiJournalsPage = 4;
  suiMoreReportsPage = 5;
  suiAdvancedPage = 6;
  suiFileOptionsPage = 7;
  suiCashflowReportsPage = 8;
  suiProfitReportsPage = 9;
  suiGSTReportsPage = 10;
  suiListReportsPage = 11;
  suiBankRecReportsPage = 12;

  //status values
  SUI_Status_NotStarted = 0;
  SUI_Status_InProgress = 1;
  SUI_Status_Complete = 2;

  //steps
  sui_step_min = 0;
  sui_Retrieve    = 1;
  sui_Coded       = 2;
  sui_ReportsRun  = 3;
  sui_BackupDone  = 4;


  sui_step_max = 32;


implementation
uses
  MadUtils,
  LogUtil,
  Merge32,
  BKHelp,
  bkBranding,
  bkConst,
  ReportDefs,
  CodingFrm,
  MailFrm,
  ModalProcessorDlg,
  Globals,
  StDate,
  Math,
  MainFrm,
  BKdateUtils,
  UpdateMF,
  baObj32,
  ApplicationUtils,
  AutoSaveUtils,
  Files,
  BudgetFrm,
  bkXPThemes,
  Graphs,
  GraphDefs,
  SimpleEOYform,
  clDateUtils,
  travUtils,
  baUtils,
  CodeDateDlg,
  InfoMorefrm,
  ErrorMoreFrm,
  YesNoDlg,

  SUIHomepageFme,
  SUIMorepageFme,
  SUIStdReportsFme,
  SUIMoreInputPageFme,
  SUIJournalsFme,
  SUIMoreReportsPageFme,
  SUIAdvancedPageFme,
  SUIFileOptionsFme,
  SUICashflowReportsPageFme,
  SUIProfitReportsPageFme,
  suiGSTReportsPageFme,
  suiListReportsFme,
  suiBankRecReportsFme,

  ShellAPI, imagesfrm, UpgradeHelper;
{$R *.dfm}

var
  DebugMe : boolean = false;

const
  UnitName = 'SIMPLEHOME';

procedure DoSimpleUICommand(command: byte);
//most of these commands will be passed on to the main form
begin
   //need to force the period dates to current period for actions
   if Assigned(MyClient) and (Command in [
        sui_mcCodingCurrent,
        sui_mcBankRecSummary_Cur,
        sui_mcProfitAndLossAct_Cur,
        sui_mcGSTAuditreport_Cur,
        sui_mcGraphs_Cur,
        sui_mcGSTReturn_Cur ]) then
   begin
     //force dates to current period
     MyClient.clFields.clPeriod_Start_Date := MyClient.clExtra.ceSUI_Period_Start;
     MyClient.clFields.clPeriod_End_Date := MyClient.clExtra.ceSUI_Period_End;
     //mark reports as having been run as long as coding done
     if MyClient.clExtra.ceSUI_Step_Done[ sui_Coded] then
       MyClient.clExtra.ceSUI_Step_Done[ sui_ReportsRun] := true;
   end;

   case Command of
     //home page
     sui_mcRetrieveData          : ModalProcessorDlg.DoModalCommand( mpcDoOffsiteDownload);
     sui_mcCodingCurrent         : frmMain.DoMainFormCommand( mf_mcCoding);
     //reports...
     sui_mcOffsiteBackup         : begin
        TfrmSimpleUIHomePage( ClientHomePage).LastBackupSucceeded := false;
        frmMain.DoMainFormCommand( mf_mcOffsiteBackup);
        if Globals.mfModalCommandResult = 1 then
        begin
          TfrmSimpleUIHomePage( ClientHomePage).LastBackupDateTime := SysUtils.Time;
          TfrmSimpleUIHomePage( ClientHomePage).LastBackupSucceeded := true;
        end;
     end;
     sui_mcFinished                : begin
        if TfrmSimpleUIHomePage( ClientHomePage).CheckFinished then
          RefreshHomepage( [ HRP_INIT]);
     end;
     //more...

     //std reports page
     sui_mcBankRecSummary_Cur    : DoModalReport(REPORT_BANKREC_SUM,rdNone);
     sui_mcProfitAndLossAct_Cur  : DoModalReport(REPORT_PROFIT_ACT,rdNone);
     sui_mcGSTAuditreport_Cur    : DoModalReport(REPORT_GST_AUDIT,rdNone);
     sui_mcCashflowAct_Cur       : DoModalReport(REPORT_CASHFLOW_ACT, rdNone);
     sui_mcGraphs_Cur            : Graphs.DoGraph(GRAPH_SUMMARY);
     sui_mcGSTReturn_Cur         : frmMain.DoMainFormCommand( mf_mcGSTReturn);

     //advanced page
     sui_mcHDE                   : frmMain.DoMainFormCommand( mf_mcHDE );
     sui_mcGSTDetails            : frmMain.DoMainFormCommand( mf_mcGSTDetails );
     sui_mcMaintainChart         : frmMain.DoMainFormCommand( mf_mcMaintainChart );
     sui_mcMaintainPayees        : frmMain.DoMainFormCommand( mf_mcMaintainPayees );
     sui_mcMaintainMems          : frmMain.DoMainFormCommand( mf_mcMaintainMems );
     sui_mcmaintainJob           : frmMain.DoMainFormCommand( mf_mcmaintainJob );
     sui_mcSystemOptions         : frmMain.DoMainFormCommand( mf_mcSystemOptions );
     sui_mcMaintainDiv           : frmMain.DoMainFormCommand( mf_mcEditDivisions);
     sui_mcEmailSupport          : MailFrm.SendMailToSupport( GetSupportEmailAddress);
     sui_mcCheckForUpdates       : begin
                                     UpgradeHelper.CheckForUpgrade_Offsite(frmMain.Handle, '',
                                                                           MyClient.clFields.clCountry);
                                     if Globals.ApplicationMustShutdownForUpdate then
                                       frmMain.Close;
                                   end;

     //more input
     sui_mcCoding                : frmMain.DoMainFormCommand( mf_mcCoding);
     //journals...
     sui_mcBudgets               : frmMain.DoMainFormCommand( mf_mcBudgets);
     sui_mcOpeningBalances       : frmMain.DoMainFormCommand( mf_mcOpeningBalances);
     sui_mcMaintainBankAccounts  : frmMain.DoMainFormCommand( mf_mcMaintainBankAccounts);
     sui_mcMDE                   : frmMain.DoMainFormCommand( mf_mcMDE);

     //file options
     sui_mcClientDetails         : frmMain.DoMainFormCommand( mf_mcClientDetails);
     sui_mcCheckIn               : frmMain.DoMainFormCommand( mf_mcCheckIn);
     sui_mcCheckOut              : if Assigned( MyClient) then
                                   begin
                                     MailFrm.SendClientFileTo('');
                                   end;
     sui_mcSaveAs                : frmMain.DoMainFormCommand( mf_mcSaveAs);
     sui_mcOpenFile              : frmMain.DoMainFormCommand( mf_mcOpenFile);
     sui_mcAbandon               : frmMain.DoMainFormCommand( mf_mcAbandon);

     //more reports
     sui_mcCodingReport          : DoModalReport(REPORT_CODING,rdNone);
     sui_mcLedgerReport          : DoModalReport(REPORT_LIST_LEDGER,rdNone);
     sui_mcPayeeReport           : DoModalReport(REPORT_PAYEE_SPENDING,rdNone);
     sui_mcJobsReport            : DoModalReport(Report_Job_Summary, rdNone);
     sui_mcTrialBalanceReport    : frmMain.DoMainFormCommand( mf_mcTrialBalance);
     sui_mcGraphsR               : Graphs.DoGraph(GRAPH_SUMMARY);

     //cashflow
     sui_mcCFA                   : DoModalReport(REPORT_CASHFLOW_ACT, rdNone);
     sui_mcCFAB                  : DoModalReport(REPORT_CASHFLOW_ACTBUD, rdNone);
     sui_mcCFABV                 : DoModalReport(REPORT_CASHFLOW_ACTBUDVAR, rdNone);
     sui_mcCF12A                 : DoModalReport(REPORT_CASHFLOW_12ACT, rdNone);
     sui_mcCF12B                 : DoModalReport(REPORT_BUDGET_12CASHFLOW, rdNone);
     sui_mcCF12AB                : DoModalReport(REPORT_CASHFLOW_12ACTBud, rdNone);
     sui_mcCFDateToDate          : DoModalReport(REPORT_CASHFLOW_DATE, rdNone);
     sui_mcCFBudRem              : DoModalReport(REPORT_CASHFLOW_BUDREM, rdNone);
     sui_mcThisYearLastYear      : DoModalReport(Report_Cashflow_ActLastYVar, rdNone);

     //p&l
     sui_mcPLA                   : DoModalReport(REPORT_PROFIT_ACT,rdNone);
     sui_mcPLAB                  : DoModalReport(REPORT_PROFIT_ACTBUD,rdNone);
     sui_mcPLABV                 : DoModalReport(REPORT_PROFIT_ACTBUDVAR,rdNone);
     sui_mcPL12A                 : DoModalReport(REPORT_PROFIT_12ACT,rdNone);
     sui_mcPL12B                 : DoModalReport(REPORT_PROFIT_12BUD, rdNone);
     sui_mcPL12AB                : DoModalReport(REPORT_PROFIT_12ACTBUD,rdNone);

     //bank rec
     sui_mcBankRecSum            : DoModalReport(REPORT_BANKREC_SUM,rdNone);
     sui_mcBankRecDet            : DoModalReport(REPORT_BANKREC_DETAIL, rdNone);

     //listings
     sui_mcListBankAccounts      : DoModalReport(REPORT_LIST_BANKACCTS,rdAsk, BKH_List_bank_accounts);
     sui_mcListChart             : DoModalReport(REPORT_LIST_CHART, rdAsk, BKH_List_chart_of_accounts);
     sui_mcListPayees            : DoModalReport(REPORT_LIST_PAYEE, rdNone);
     sui_mcListJobs              : DoModalReport( Report_List_Jobs, rdAsk, BKH_List_jobs);
     sui_mcListJournals          : DoModalReport(REPORT_LIST_JOURNALS,rdNone);
     sui_mcListMems              : DoModalReport( Report_List_Memorisations, rdNone, BKH_List_memorisations);
     sui_mcListMissingCheques    : DoModalReport( Report_Missing_Cheques, rdNone);
     sui_mcListEntries           : DoModalReport(REPORT_LIST_ENTRIES,rdNone);

     //gst reports
     sui_mcGSTReturnR            : frmMain.DoMainFormCommand( mf_mcGSTReturn);
     sui_mcGSTAuditR             : DoModalReport(REPORT_GST_AUDIT,rdNone);
     sui_mcGSTSummaryR           : DoModalReport(REPORT_GST_SUMMARY,rdNone);
     sui_mcGSTDetailsR           : DoModalReport( REPORT_LIST_GST_DETAILS, rdAsk, BKH_List_GST_details);
     sui_mcGSTAnnualReturnAU     : frmMain.DoMainFormCommand( mf_mcAnnualGSTReturn);
     sui_mcGSTAnnualReportAU     : frmMain.DoMainFormCommand( mf_mcAnnualGSTReport);

     //jnls
     sui_mcAddCashJnl            : frmMain.DoMainFormCommand( mf_mcCashJournals);
     sui_mcAddAccrualJnl         : frmMain.DoMainFormCommand( mf_mcAccrualJournals);
     sui_mcViewCashJnl           : frmMain.DoMainFormCommand( mf_mcViewCashJournals);
     sui_mcViewAccrualJnl        : frmMain.DoMainFormCommand( mf_mcViewAccrualJournals);

     sui_mcOffsiteRestore        : frmMain.DoMainFormCommand( mf_mcOffsiteRestore);
     sui_mcYearEnd               : begin
                                     if DoSimpleEOY then ;
                                   end;

     sui_mcChangePeriod          : begin
       //select a new current period
       if CodeDateDlg.EnterDateRange('Select a date range',
                                  'Select dates for the current period',
                                  MyClient.clExtra.ceSUI_Period_Start,
                                  MyClient.clExtra.ceSUI_Period_End,
                                  0,
                                  false,
                                  true) then
       begin
         TfrmSimpleUIHomePage( ClientHomePage).ResetSUIPeriod;
         RefreshHomepage( [HPR_CODING, HPR_CLIENT]);
       end;
     end;

     sui_mcTaxablePayments:
     begin
       if Assigned(MyClient) then
       begin
         if MyClient.clFields.clCountry = whAustralia then
         begin
           DoModalReport(REPORT_TAXABLE_PAYMENTS, rdNone);
         end;
       end;
     end;
   else
      ShowMessage('unknown');
   end;

   if Assigned(MyClient) and (Command in [  sui_mcOffsiteBackup]) then
   begin
     MyClient.clExtra.ceSUI_Step_Done[ sui_BackupDone] := true;
     RefreshHomepage( [ HPR_Status]);
   end;
end;

function TfrmSimpleUIHomePage.CheckFinished: boolean;
var
  RequiredStepsMsg : string;
  OptionalStepsMsg : string;
  i : integer;
  s : string;
  ba : TBank_Account;
  PeriodStart, PeriodEnd : integer;
begin
  //returns true if everything is done for this period and the user has selected
  //to move to the next period
  result := false;
  if not Assigned (FCurrentClient) then
    Exit;

  PeriodStart := FCurrentClient.clExtra.ceSUI_Period_Start;
  PeriodEnd   := FCurrentClient.clExtra.ceSUI_Period_End;

  RequiredStepsMsg := '';
  OptionalStepsMsg := '';

  //transactions retrieved
  if not FCurrentClient.clExtra.ceSUI_Step_Done[ sui_Retrieve] then
    RequiredStepsMsg := RequiredStepsMsg + '- Retrieve all transaction for the current period'+#13;

  //all coded, check all accounts to make sure that there are no invalid jnls
  if not FCurrentClient.clExtra.ceSUI_Step_Done[ sui_Coded]  then
    RequiredStepsMsg := RequiredStepsMsg + '- Code all statements'+#13;

  //now check for journals
  for I := FCurrentClient.clBank_Account_List.First to FCurrentClient.clBank_Account_List.Last do
  begin
    ba := FCurrentClient.clBank_Account_List.Bank_Account_At(i);
    if not TravUtils.AllCoded( ba, PeriodStart, PeriodEnd) then
    begin
       if not (ba.baFields.baAccount_Type in [btBank]) then
       begin
         RequiredStepsMsg := RequiredStepsMsg + '- Code all ' + btNames[ ba.baFields.baAccount_Type] + #13;
       end
       else
       begin
         //this shouldnt happen as it should be caught above but double check
         //it would mean that the flag is set to coded, but have found a bank
         //account that is not
         if FCurrentClient.clExtra.ceSUI_Step_Done[ sui_Coded] then
           RequiredStepsMsg := RequiredStepsMsg + '- Code all statements' +#13;
       end;
    end;
  end;

  ///reports run
  if not FCurrentClient.clExtra.ceSUI_Step_Done[ sui_ReportsRun]  then
    RequiredStepsMsg := RequiredStepsMsg + '- Run reports'+#13;


  //----- OPTIONAL STEPS -------------------------------------------------------
  //backup done
  //this was made optional after discussions with PS and RR
  if not (FCurrentClient.clFields.clCRC_at_Last_Save = FCurrentClient.clFields.clTemp_CRC_at_Last_Backup) then
  begin
    FCurrentClient.clExtra.ceSUI_Step_Done[ sui_BackupDone] := false;
    OptionalStepsMsg := OptionalStepsMsg + '- Do a recent backup'+#13;
  end;

  if RequiredStepsMsg <> '' then
  begin
    HelpfulInfoMsg( 'There is still some work to do.  Before you can finish this period you need to: ' + #13#13 +
                      RequiredStepsMsg, 0);
    exit;
  end;

  if OptionalStepsMsg <> '' then
  begin
    s := 'It is suggested that you do the following before proceeding:'+#13+#13+
         OptionalStepsMsg+#13#13+
         'Do you want to go back and do this now?';

    if YesNoDlg.AskYesNo( 'Complete optional steps', s, DLG_YES, 0) = DLG_YES then
      Exit;
  end;

  //---------  PROCEED WITH END OF PERIOD -------------------------------------
  //prompt user
  PeriodStart := FCurrentClient.clExtra.ceSUI_Period_End + 1;
  PeriodEnd   := bkDateUtils.GetLastDayOfMonth( PeriodStart);
  s := 'You have finished everything that needs to be done for this period. ' +
       'Please confirm that you want to move to the next period?  (' +
       bkDate2Str( PeriodStart) + ' - ' +
       bkDate2Str( PeriodEnd) + ')';

  if YesNoDlg.AskYesNo( 'Finish Period', s, DLG_YES, 0) = DLG_YES then
  begin
    //move to next month
    ResetSUIPeriod;
    FCurrentClient.clExtra.ceSUI_Period_Start := PeriodStart;
    FCurrentClient.clExtra.ceSUI_Period_End := PeriodEnd;
    result := true;
  end;
end;

function TfrmSimpleUIHomePage.FindStartDateOfLatestUncodedMonth : integer;
//looking for the last month that is fully coded and move to the next one
Var
   FirstTransaction,
   LastTransaction : integer;
   MonthStart, MonthEnd : integer;
   MonthFound : boolean;
   AllCoded : boolean;
   i : integer;
   ba : TBank_account;
begin
   MonthFound := false;
   FirstTransaction := clDateUtils.BBankData( FCurrentClient);
   LastTransaction := clDateUtils.EBankData( FCurrentClient);
   MonthStart := bkDateUtils.GetFirstDayOfMonth( LastTransaction);
   MonthEnd   := bkDateUtils.GetLastDayOfMonth( LastTransaction);

   Repeat
     AllCoded := true;
     for I := FCurrentClient.clBank_Account_List.First to FCurrentClient.clBank_Account_List.Last  do
       begin
          ba := FCurrentClient.clBank_Account_List.Bank_Account_At(i);
          if ba.baFields.baAccount_Type in [btBank] then
          begin
            AllCoded := AllCoded and TravUtils.AllCoded( ba, MonthStart, MonthEnd);
          end;
       end;

       if AllCoded then
       begin
         //have found a fully coded month, so set dates to next month
         MonthFound := true;
         MonthStart := MonthEnd + 1;
         MonthEnd := bkDateUtils.GetLastDayOfMonth( MonthEnd);
       end
       else
       begin
         MonthEnd := MonthStart - 1;
         MonthStart := bkDateUtils.GetFirstDayOfMonth( MonthEnd);
       end;
   Until (MonthFound or (MonthStart < FirstTransaction));

   if (not AllCoded) or (MonthStart < FirstTransaction) then
   begin
     //couldnt find a coded month, just start from first month in file
     result := GetFirstDayOfMonth( FirstTransaction);
   end
   else
   begin
     result := MonthStart;
   end;
end;


procedure TfrmSimpleUIHomePage.FormActivate(Sender: TObject);
begin
//   if not FClosing then
//       RefreshRequest := [HPR_Coding];

  //Disable System Menu items
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MINIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_RESTORE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MAXIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
end;

procedure TfrmSimpleUIHomePage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //if we are not already closing the client then do it now
  if not FClosingClient then
  begin
   FClosingClient := True;
    if not FAbandon then
      files.CloseClient( True, False);

    Action := caFree;
  end
  else
  begin
    FDisableProcessing := True;
    Action := caFree;
  end;

  //reshow open

end;

procedure TfrmSimpleUIHomePage.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  FDisableProcessing := True;
end;

procedure TfrmSimpleUIHomePage.FormCreate(Sender: TObject);
var
  hDiff : integer;
begin
   FCurrentClient := nil;
   FRefreshRequest := [];
   FClosingClient := false;
   FLockCount := 0;
   //base object
   FAbandon := false;
   CurrentFrame := nil;
   CurrentFrameIndex := -2;  //page neven been set
   FLastBackupDateTime := 0;
   FTransInCurrentPeriodCount:= 0;
   FNumStatementsToCode := 0;

   bkXPThemes.ThemeForm(Self);
   //BKHelpSetUp(self, BKH_The_Client_Home_Page);

   FDisableProcessing := True;        //used here to tell form not to do things, need to understand more
   //make sure tops aligned
   lblNavLevel1.Top := lblHome.Top;
   lblNavLevel2.Top := lblHome.Top;
   lblNavLevel3.Top := lblHome.Top;

   pnlExtraTitleBar.GradientColorStart := clWhite; //bkBranding.TobBarStartColor;
   pnlExtraTitleBar.GradientColorStop  := clGray;  //bkBranding.TopBarStopColor;
   pnlNavigator.Color := clGray;                   //bkBranding.TopBarStopColor;
   lblClientName.Font.Color := $00494949;          //bkBranding.TopTitleColor;

   imgLeft.Picture := bkBranding.TopBannerImage;    
   imgRight.Picture := bkBranding.ClientBanner;
   pnlExtraTitleBar.Height := imgRight.Picture.Height;
   lblClientName.Left := imgLeft.Width + 10;
   lblCurrentPeriod.Left := imgLeft.Width + 10;

   //see if a practice logo file has been loaded from the books file
   if frmMain.UsingCustomPracticeLogo then begin
      imgRight.AutoSize := False;
      imgRight.Stretch := True;
      imgRight.Picture := frmMain.imgPracticeLogo.Picture;
      imgRight.Transparent := False;
      imgRight.Width := frmMain.imgPracticeLogo.Width;
   end else begin
      imgRight.Transparent := True;
      imgRight.Picture := bkBranding.ClientBanner;
   end;
   pnlExtraTitlebar.Height := Max( 45, imgRight.Height);
   //now center the clientname and current period labels
   hDiff := (pnlExtraTitlebar.height - lblClientName.Height - lblCurrentPeriod.Height - 4) div 2;
   lblClientName.Top := hDiff;
   lblCurrentPeriod.Top := hDiff + lblClientname.height + 1;

   SwitchToFrame(suiHomepage);

   FDisableProcessing := False;
end;

procedure TfrmSimpleUIHomePage.FormDestroy(Sender: TObject);
begin
  OutputDebugString( 'TfrmSimpleUIHomePage.FormDestroy' );
  ClientHomepagefrm.SetClientHomePageToNil;
end;

function TfrmSimpleUIHomePage.GetAbandon: boolean;
begin
  Result := FAbandon;
end;

// Have only created this to override the abstract function
// and thus remove a warning, shouldn't ever get called
function TfrmSimpleUIHomePage.GetFillDate: integer;
begin
  Result := -1;
end;

// Have only created this to override the abstract function
// and thus remove a warning, shouldn't ever get called
function TfrmSimpleUIHomePage.GetGlobalRedrawForeign: boolean;
begin
  Result := False;
end;

// Have only created this to override the abstract function
// and thus remove a warning, shouldn't ever get called
procedure TfrmSimpleUIHomePage.SetGlobalRedrawForeign(Value: boolean);
begin
  //
end;

function TfrmSimpleUIHomePage.GetLastDownloadedDate: integer;
begin
  result := FLastDownloadedTransDate;
end;

function TfrmSimpleUIHomePage.GetRefreshRequest: THP_Refresh;
begin
  result := FRefreshRequest;
end;

function TfrmSimpleUIHomePage.GetTheClient: TClientObj;
begin
  result := FCurrentClient;
end;

procedure TfrmSimpleUIHomePage.lblHomeClick(Sender: TObject);
begin
  SwitchToFrame( suiHomepage);
end;

procedure TfrmSimpleUIHomePage.lblNavLevel1Click(Sender: TObject);
begin
  if TLabel( Sender).Tag > 0 then
  begin
    SwitchToFrame( TLabel( Sender).Tag);
  end;
end;

procedure TfrmSimpleUIHomePage.Lock;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Lock');
  inc(FLockCount);
end;

procedure TfrmSimpleUIHomePage.ProcessExternalCmd(Command: TExternalCmd);
begin
   //mh: dont think this is needed here
   //if not FDisableProcessing then
   //   RefreshRequest := [HPR_Coding]; // Should Check the command...
end;

procedure TfrmSimpleUIHomePage.SetAbandon(const Value: Boolean);
begin
  FAbandon := Value;
end;

procedure TfrmSimpleUIHomePage.SetLastBackupDateTime(const Value: TDateTime);
begin
  FLastBackupDateTime := Value;
end;

procedure TfrmSimpleUIHomePage.SetLastBackupSucceeded(const Value: boolean);
begin
  FLastBackupSucceeded := Value;
end;

procedure TfrmSimpleUIHomePage.SetRefreshRequest(const Value: THP_Refresh);
//mh: this is where the pending refresh request is stored and triggered
begin
  FRefreshRequest := FRefreshRequest + Value;
  if FLockCount = 0 then
     ProcessPendingRefreshRequest;
end;

procedure TfrmSimpleUIHomePage.SetTheClient(const Value: TClientObj);
//stores a pointer to the current client
//if nil then closes form otherwise forces an init request
begin
   if FDisableProcessing then
     Exit;

   FCurrentClient := Value;
   if assigned(FCurrentClient) then
   begin
      //trigger an init
      RefreshRequest := [HRP_Init];
      Self.Visible := True;  //!!
   end
   else
   begin
      //current client is nil so close me
      FDisableProcessing := True;
      Self.Close;
   end;
end;

procedure TfrmSimpleUIHomePage.SwitchToFrame(NewFrameIndex: integer);
//note: passing -1 as the frame index will destroy the current frame and not
//      create a new one
begin
  if (CurrentFrameIndex <> NewFrameIndex) then
  begin
     //unload current frame
    if Assigned( CurrentFrame) then
      FreeandNil( CurrentFrame);

    //load new frame
    if NewFrameIndex <> -1 then
    begin
      case NewFrameIndex of
        suiHomepage : begin
           CurrentFrame := TfmeSUIHomepage.Create( pnlFrameHolder);
        end;
        suiMorepage : CurrentFrame := TfmeSUIMorepage.Create( pnlFrameHolder);
        suiStdReportsPage : CurrentFrame := TfmeSUIStdReports.Create( pnlFrameHolder);
        suiMoreInputPage : CurrentFrame := TfmeSUIMoreInputPage.Create( pnlFrameHolder);
        suiJournalsPage : CurrentFrame := TfmeSUIJournalsPage.Create( pnlFrameHolder);
        suiMoreReportsPage : CurrentFrame := TfmeSUIMoreReportsPage.Create( pnlFrameHolder);
        suiAdvancedPage : CurrentFrame := TfmeSUIAdvancedPage.Create( pnlFrameHolder);
        suiFileOptionsPage : CurrentFrame := TfmeFileOptionsPage.Create( pnlFrameHolder);
        suiCashflowReportsPage : CurrentFrame := TfmeSUICashflowReportsPage.Create( pnlFrameHolder);
        suiProfitReportsPage : CurrentFrame := TfmeSUIProfitReportsPage.Create( pnlFrameHolder);
        suiGSTReportsPage : CurrentFrame := TfmeSUIGSTReportsPage.Create( pnlFrameHolder);
        suiListReportsPage : CurrentFrame := TfmeSUIListReportsPage.Create( pnlFrameHolder);
        suiBankRecReportsPage : CurrentFrame := TfmeSUIBankREcReportsPage.Create( pnlFrameHolder);
      end;

      CurrentFrame.Parent := pnlFrameHolder;
      CurrentFrame.Align  := alClient;
      CurrentFrameIndex := NewFrameIndex;  //update so dont change unnecessarily
    end;

    //re-build the navigator
    lblNavLevel1.Caption := '';
    lblNavLevel2.Caption := '';
    lblNavLevel3.Caption := '';

    lblNavLevel1.Tag     := 0;
    lblNavLevel2.Tag     := 0;
    lblNavLevel3.Tag     := 0;

    case NewFrameIndex of
      suiHomepage : ;

      //level one pages
      suiMorepage : lblNavLevel1.Caption := ' > More';
      suiStdReportsPage : lblNavLevel1.Caption := ' > Reports';

      //level two pages
      suiMoreInputPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More input';
      end;
      suiMoreReportsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports';
      end;
      suiAdvancedPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > Advanced';
      end;
      suiFileOptionsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > File options';
      end;

      //level three pages
      suiJournalsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More input'; lblNavLevel2.Tag := suiMoreInputPage;
        lblNavLevel3.Caption := ' > Journals';
      end;
      suiCashflowReportsPage: begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports'; lblNavLevel2.Tag := suiMoreReportsPage;
        lblNavLevel3.Caption := ' > Cash flow reports';
      end;
      suiProfitReportsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports'; lblNavLevel2.Tag := suiMoreReportsPage;
        lblNavLevel3.Caption := ' > Profit and loss reports';
      end;
      suiGSTReportsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports'; lblNavLevel2.Tag := suiMoreReportsPage;
        lblNavLevel3.Caption := ' > GST reports';
      end;
      suiListReportsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports'; lblNavLevel2.Tag := suiMoreReportsPage;
        lblNavLevel3.Caption := ' > List reports';
      end;
      suiBankRecReportsPage : begin
        lblNavLevel1.Caption := ' > More';  lblNavLevel1.Tag := suiMorePage;
        lblNavLevel2.Caption := ' > More reports'; lblNavLevel2.Tag := suiMoreReportsPage;
        lblNavLevel3.Caption := ' > Bank reconciliation reports';
      end;
    end;

    lblNavLevel1.Left := lblHome.Left + lblHome.Width + 5;
    lblNavLevel2.Left := lblNavLevel1.Left + lblNavLevel1.Width + 5;
    lblNavLevel3.Left := lblNavLevel2.Left + lblNavLevel2.Width + 5;
  end;

   //some forms need to initialised after switching
  if NewFrameIndex <> -1 then
  begin
     case NewFrameIndex of
        suiHomepage : begin
           TfmeSUIHomepage(CurrentFrame).InitFrame;
        end;
     end;
  end;

  //need to get into the frame
  Self.SelectFirst;
end;

procedure TfrmSimpleUIHomePage.Unlock;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'UnLock');
   Dec(FLockCount);
   if FLockCount = 0 then
      ProcessPendingRefreshRequest;
end;

procedure TfrmSimpleUIHomePage.ProcessPendingRefreshRequest;
//processes refresh requests from elsewhere in the application
//note:   HPR_Tasks is not handled by this form as there are no tasks shown
var
   kc: TCursor;
begin
   if FDisableProcessing then
      Exit;

   if FRefreshRequest = [] then
      Exit;

   if not Assigned(FCurrentClient) then
      Exit;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter ProcessPendingRefreshRequest');
   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
      //mh : this is where each part of the refresh is triggered
      // Something to refresh..
      if ([HRP_Init,HPR_Client] * FRefreshRequest) <> [] then
         RefreshClient;

      if ([HRP_Init,HPR_Coding,HPR_Files] * FRefreshRequest) <> [] then
         RefreshCoding;

      if ([HRP_Init,HPR_Files] * FRefreshRequest) <> [] then
         RefreshFiles;

      //force a redrawn if the homepage frame is showing
      if ([HPR_Status] * FRefreshRequest) <> [] then
         RefreshStatus;

      //restore and show the home page window
      if HRP_Init in FRefreshRequest then begin
         if (Self.WindowState = wsMinimized) then
            ShowWindow(Self.Handle, SW_RESTORE);
         Self.BringToFront;
      end;

      FRefreshRequest := [];
   finally
      Screen.Cursor := kc;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit ProcessPendingRefreshRequest');
end;

procedure TfrmSimpleUIHomePage.RefreshClient;
//refresh client details in this form, name, mad except name
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshClient');

   //check period dates are set, will be blank first time run
   if (FCurrentClient.clExtra.ceSUI_Period_Start = 0) or (FCurrentClient.clExtra.ceSUI_Period_End = 0)  then
   begin
     //need to set value dates, find the last fully coded month and set period to the next one
     FCurrentClient.clExtra.ceSUI_Period_Start := FindStartDateOfLatestUncodedMonth;
     FCurrentClient.clExtra.ceSUI_Period_End := bkDateUtils.GetLastDayofMonth(FCurrentClient.clExtra.ceSUI_Period_Start);
     ResetSUIPeriod;
   end;

   lblClientName.Caption := FCurrentClient.clFields.clName;
   lblCurrentPeriod.Caption := 'Current period is ' +
                        bkDate2Str( FCurrentClient.clExtra.ceSUI_Period_Start) +
                        ' to ' +
                        bkDate2Str( FCurrentClient.clExtra.ceSUI_Period_End);

   SwitchToFrame( suiHomepage);

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshClient');
end;

procedure TfrmSimpleUIHomePage.RefreshCoding;
//update coding status
var
  i : integer;
  ba : TBank_Account;
  NumCoded, NumUncoded, NumInvalid : integer;
  NumUncodedAccounts : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshCoding');

   //update coding status, only need to do this if Homepage is showing...
   //reload cached values
   //
   NumUncodedAccounts := 0;
   FTransInCurrentPeriodCount := 0;

   for I := FCurrentClient.clBank_Account_List.First to FCurrentClient.clBank_Account_List.Last do
   begin
      ba := FCurrentClient.clBank_Account_List.Bank_Account_At(i);
      if ba.baFields.baAccount_Type in [btBank] then
      begin
        TravUtils.CountTransactionStatus( ba,
                                          NumCoded,
                                          NumUncoded,
                                          NumInvalid,
                                          FCurrentClient.clExtra.ceSUI_Period_Start,
                                          FCurrentClient.clExtra.ceSUI_Period_End);
        if (NumUncoded + NumInvalid) > 0 then
          Inc( NumUncodedAccounts);

        FTransInCurrentPeriodCount := FTransInCurrentPeriodCount + (NumCoded + NumUncoded + NumInvalid);
      end;
   end;

   FNumStatementsToCode := NumUncodedAccounts;

   RefreshStatus;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshCoding');
end;

procedure TfrmSimpleUIHomePage.RefreshFiles;
//update bconnect data status - in books this just turns on the correct option
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshFiles');

   //update coding status, only need to do this if Homepage is showing...
   //reload cached values
   FLastDownloadedTransDate := baUtils.GetLatestTransDate( FCurrentClient.clBank_Account_List);
   RefreshStatus;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshFiles');
end;

procedure TfrmSimpleUIHomePage.RefreshStatus;
begin
   if (CurrentFrameIndex = suiHomepage) then
   begin
     TfmeSUIHomepage(CurrentFrame).RefreshStatus;
   end;
end;

procedure TfrmSimpleUIHomePage.ResetSUIPeriod;
var
  i : integer;
begin
  //clear status flags and reset status to not started
  if assigned( FCurrentClient) then
  begin
    for i := sui_step_min to sui_step_max  do
      FCurrentClient.clExtra.ceSUI_Step_Done[i] := false;
  end;
end;

procedure TfrmSimpleUIHomePage.wmsyscommand(var msg: TWMSyscommand);
//override default handling to prevent minimise and restore
begin
  if ((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE) then
    exit
  else
    inherited;
end;

procedure ChangeHomepageFrame( NewFrameIndex : integer);
begin
   if ( ClientHomePage is TfrmSimpleUIHomePage) then
     TfrmSimpleUIHomePage( ClientHomePage).SwitchToFrame( NewFrameIndex);
end;

initialization
  DebugMe := DebugUnit(UnitName);
end.
