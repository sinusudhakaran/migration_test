//------------------------------------------------------------------------------
{
   Title:       Main Form

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------
unit MainFrm;

{..$DEFINE PLAYSOUNDS}

{$ifdef Win32}
  {$ifdef VER150}
    {$define DELPHI7}
  {$endif}
{$endif}

interface
uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ExtCtrls, ImgList, reportdefs,
  ReportStyleDlg,

  {bk5 code units}
  Filewrapper,Globals, Files, StdCtrls, ToolWin, {helpFrm,} PrintMgrObj, Reports, cfNamesDlg,
  pfNamesDlg, updateMF, CodingFrm, SysObj32, Admin32, BudgetFrm, Login32, CodingFormCommands,
  jpeg, AppEvnts, ModalProcessorDlg, ActnList, RzButton, RzPanel, DdeMan, ExportChargesFrm,
  BatchReportFrm,{,threadData}
  OSFont, Progress, BudgetImportExport, RzTabs, uNPS, MultiCast;

const
  BK_SHOWCM = (WM_USER + 1);
  BK_DIR_REQUEST = (WM_USER + 377);
  BK_IS_BUSY = (WM_USER + 378);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type
  TfrmMain = class(TForm)
    MainMenu: TMainMenu;
    MainStatus: TStatusBar;
    tmClock: TTimer;
    mnsFile: TMenuItem;
    mnsDataEntry: TMenuItem;
    mnsReport: TMenuItem;
    mnsGraph: TMenuItem;
    mnsHelp: TMenuItem;
    mniFileNew: TMenuItem;
    mniFileOpen: TMenuItem;
    mniFileClose: TMenuItem;
    mniSeparator: TMenuItem;
    mniFileSave: TMenuItem;
    NA2: TMenuItem;
    mniSendClientFiles: TMenuItem;
    mniFileCheckIn: TMenuItem;
    NA4: TMenuItem;
    mniFileAbandonChanges: TMenuItem;
    MRUEnd: TMenuItem;
    mniFileExit: TMenuItem;
    mniHelpAbout: TMenuItem;
    mnsOtherFunctions: TMenuItem;
    mniDECodeEntries: TMenuItem;
    NB1: TMenuItem;
    mniDEEnterBudgets: TMenuItem;
    mniDECashJournals: TMenuItem;
    mniCodingReport: TMenuItem;
    mnsCashFlowReports: TMenuItem;
    mnsProfitabilityReports: TMenuItem;
    mnsBankReconciliation: TMenuItem;
    mnsGSTReports: TMenuItem;
    mnsSpendingbyPayee: TMenuItem;
    mnsExceptions: TMenuItem;
    N9: TMenuItem;
    mnsListings: TMenuItem;
    SepReportSchedule: TMenuItem;
    mniReportSchedule: TMenuItem;
    mniCFRActual: TMenuItem;
    mniCFRActualandBudget: TMenuItem;
    mniCFRActualBudgetandVariance: TMenuItem;
    mniCFR12MonthsActual: TMenuItem;
    mniCFR12MonthsActualandBudget: TMenuItem;
    mniCFRFromDatetoDate: TMenuItem;
    mniCFRBudgetRemaining: TMenuItem;
    N11: TMenuItem;
    mniCFRSetupReportHeadings: TMenuItem;
    mniPRActual: TMenuItem;
    mniPRActualAndBudget: TMenuItem;
    mniPRActualBudgetAndVariance: TMenuItem;
    mniPR12MonthsActual: TMenuItem;
    mniPR12MonthsActualandBudget: TMenuItem;
    N12: TMenuItem;
    mniPRSetupReportHeadings: TMenuItem;
    mniBRRSummarised: TMenuItem;
    mniBRRDetailed: TMenuItem;
    mniGSTReturn: TMenuItem;
    mniGSTSummary: TMenuItem;
    mniGSTAuditTrail: TMenuItem;
    N13: TMenuItem;
    mniGSTSetupReportOptions: TMenuItem;
    mniExPrintExceptionReport: TMenuItem;
    N14: TMenuItem;
    mniSetupExceptionCriteria: TMenuItem;
    mniListEntries: TMenuItem;
    mniListJournals: TMenuItem;
    mniListBankAccounts: TMenuItem;
    mniListChartofAccounts: TMenuItem;
    mniListPayees: TMenuItem;
    mniListLedger: TMenuItem;
    mnsTest: TMenuItem;
    mnsWindow: TMenuItem;
    mniWindowCascade: TMenuItem;
    mniWindowTile: TMenuItem;
    popView: TPopupMenu;
    mniViewAllEntries: TMenuItem;
    mniViewUncodedEntriesOnly: TMenuItem;
    popSortBy: TPopupMenu;
    mniGraphSales: TMenuItem;
    mniGraphPayments: TMenuItem;
    mniGraphTradingResults: TMenuItem;
    mniGraphBankBalances: TMenuItem;
    mniGraphOnePageSummary: TMenuItem;
    mniOFClientDetails: TMenuItem;
    mniOFAccountingSystem: TMenuItem;
    mniOFRefreshChart: TMenuItem;
    N15: TMenuItem;
    mnsOFChartofAccounts: TMenuItem;
    mniOFGSTDetailsandRates: TMenuItem;
    mniOFBankAccounts: TMenuItem;
    mniOFMemorisedEntries: TMenuItem;
    mniOFPayees: TMenuItem;
    mniOFMacros: TMenuItem;
    N16: TMenuItem;
    mnsOFHouseKeeping: TMenuItem;
    N17: TMenuItem;
    mniOFExtractData: TMenuItem;
    mniOFPurgeOldEntries: TMenuItem;
    mniOFUnlockaFinalisedPeriod: TMenuItem;
    mniDEAccrualJournals: TMenuItem;
    NB2: TMenuItem;
    MRUStart: TMenuItem;
    mniFileSaveAs: TMenuItem;
    mniDENTJGSTJournals: TMenuItem;
    mniSystemPracticeDetails: TMenuItem;
    N5: TMenuItem;
    mniSystemUsers: TMenuItem;
    mnsSystemClients: TMenuItem;
    mniSystemGSTDefaults: TMenuItem;
    mniSystemTranTypes: TMenuItem;
    N19: TMenuItem;
    mnsSystemStartNewMonth: TMenuItem;
    mniSystemReports: TMenuItem;
    mniSystemBankLinkConnect: TMenuItem;
    mniSystemDownloadfromFloppy: TMenuItem;
    N20: TMenuItem;
    mniSystemMonthlyReports: TMenuItem;
    mniSystemNewAccounts: TMenuItem;
    N22: TMenuItem;
    mniSystemUtilities: TMenuItem;
    mniDENTJStockJournals: TMenuItem;
    NB3: TMenuItem;
    mniHelpViewSystemLog: TMenuItem;
    NA5: TMenuItem;
    mniFileInformation: TMenuItem;
    mniFilePreferences: TMenuItem;
    mnsDENoTransJournals: TMenuItem;
    mniDEOpeningBalances: TMenuItem;
    mniDEFinalisePeriod: TMenuItem;
    popOpen: TPopupMenu;
    popReport: TPopupMenu;
    popGraph: TPopupMenu;
    popGST: TPopupMenu;
    popUPI: TPopupMenu;
    mniUPIAddOutChq: TMenuItem;
    mniUPIAddOutDep: TMenuItem;
    mniUPIMatchEntry: TMenuItem;
    mniUPIAddInitChq: TMenuItem;
    mniUPISep1: TMenuItem;
    N1: TMenuItem;
    mniViewEditCodesOnly: TMenuItem;
    mniViewEditAllCol: TMenuItem;
    MasterMemorisedEntries1: TMenuItem;
    PracticeBankAccounts1: TMenuItem;
    ListReportsDue1: TMenuItem;
    N3: TMenuItem;
    DownloadReport1: TMenuItem;
    N4: TMenuItem;
    EmailSupport1: TMenuItem;
    N7: TMenuItem;
    mniListAdminBankAccounts: TMenuItem;
    mniClientsByStaff: TMenuItem;
    mniClientReportOptions: TMenuItem;
    mniDownloadLog: TMenuItem;
    N8: TMenuItem;
    mniOffsiteDownload: TMenuItem;
    mniImportUpdate: TMenuItem;
    mniOffsiteDownloadLog: TMenuItem;
    mniResyncroniseClient: TMenuItem;
    mniSyncroniseMyClient: TMenuItem;
    N21: TMenuItem;
    mniAddHistorical: TMenuItem;
    N23: TMenuItem;
    mniConfigureColumns: TMenuItem;
    RestoreColumnDefaults: TMenuItem;
    mnsTemplates: TMenuItem;
    mniLoadBASTemplate: TMenuItem;
    mniSaveBASTemplate: TMenuItem;
    mniBusinessNorms: TMenuItem;
    GSTOverrides1: TMenuItem;
    mniListGSTDetails: TMenuItem;
    N2: TMenuItem;
    mniTransferEntries: TMenuItem;
    mniListMemorisations: TMenuItem;
    IncrementDates1: TMenuItem;
    mniTestAdminLocking: TMenuItem;
    N18: TMenuItem;
    mniRecombine: TMenuItem;
    mniClientStatusReport: TMenuItem;
    miCFRActualLastYearVariance: TMenuItem;
    mniSetupDivisions: TMenuItem;
    mniSetupSubgroups: TMenuItem;
    mniMaintainChart: TMenuItem;
    N26: TMenuItem;
    mnsExportBNoteFile: TMenuItem;
    mniExportBNToFile: TMenuItem;
    mniExportBNtoMail: TMenuItem;
    mnsImportBNotes: TMenuItem;
    N25: TMenuItem;
    N27: TMenuItem;
    mniAnnualGSTreport: TMenuItem;
    mniAnnualGSTReturn: TMenuItem;
    mnsSystem: TMenuItem;
    EmailSystemLog1: TMenuItem;
    mniClearTransferFlags: TMenuItem;
    N28: TMenuItem;
    mniClientFileAccessReport: TMenuItem;
    mniCFCustom: TMenuItem;
    N6: TMenuItem;
    N29: TMenuItem;
    mnsTrialBalance: TMenuItem;
    mniPRCustom: TMenuItem;
    mnsBalanceSheet: TMenuItem;
    mniBalanceSheet: TMenuItem;
    N30: TMenuItem;
    mniSetUpReportHeadings: TMenuItem;
    mniYearEnd: TMenuItem;
    N31: TMenuItem;
    N32: TMenuItem;
    mniYearEndAdjustments: TMenuItem;
    mniOpeningsBalanceJnls: TMenuItem;
    DownloadReportSummarised1: TMenuItem;
    mnsDownloadReport: TMenuItem;
    N34: TMenuItem;
    Options1: TMenuItem;
    N35: TMenuItem;
    mniUnpresentedItems: TMenuItem;
    mniListDivisions: TMenuItem;
    mniListSubGroups: TMenuItem;
    Image1: TImage;
    N37: TMenuItem;
    lblClientName: TLabel;
    imgLogo: TImage;
    lblVersion: TLabel;
    imgPracticeLogo: TImage;
    tmAutoSave: TTimer;
    mniGST12MonthSummary: TMenuItem;
    actClients: TActionList;
    actClientManager: TAction;
    mniCFExport: TMenuItem;
    mniPRExport: TMenuItem;
    mniBalanceExport: TMenuItem;
    mniCFExportSeperator: TMenuItem;
    mniPRExportSeperator: TMenuItem;
    mniBalanceExportSeperator: TMenuItem;
    mniViewTasks: TMenuItem;
    actTasks: TAction;
    CreateAnalysisCodingTest1: TMenuItem;
    mniStatistics: TMenuItem;
    Utilities1: TMenuItem;
    mniRaiseException: TMenuItem;
    N10: TMenuItem;
    mniMissingCheques: TMenuItem;
    mniBKHelp: TMenuItem;
    N36: TMenuItem;
    mniBackup: TMenuItem;
    mniRestore: TMenuItem;
    mniTutorialsTOC: TMenuItem;
    rzToolbars: TPanel;
    rztFile: TRzToolbar;
    tbOpen: TRzToolButton;
    tbSave: TRzToolButton;
    tbGetClientFiles: TRzToolButton;
    tbSendClientFiles: TRzToolButton;
    rztClient: TRzToolbar;
    tbCoding: TRzToolButton;
    tbBudget: TRzToolButton;
    tbReport: TRzToolButton;
    tbGraph: TRzToolButton;
    tbGST: TRzToolButton;
    RzToolButton13: TRzToolButton;
    rztCoding: TRzToolbar;
    rztBudget: TRzToolbar;
    tbZero: TRzToolButton;
    tbGenerate: TRzToolButton;
    tbSmooth: TRzToolButton;
    tbAverage: TRzToolButton;
    tbCopy: TRzToolButton;
    tbIncrease: TRzToolButton;
    tbSplit: TRzToolButton;
    tbBudgetHelp: TRzToolButton;
    tbCodingHelp: TRzToolButton;
    tbUPI: TRzToolButton;
    tbFind: TRzToolButton;
    tbView: TRzToolButton;
    tbRepeat: TRzToolButton;
    tbGoto: TRzToolButton;
    tbSort: TRzToolButton;
    tbSuper: TRzToolButton;
    tbDissect: TRzToolButton;
    tbMemorise: TRzToolButton;
    tbPayee: TRzToolButton;
    tbChart: TRzToolButton;
    tbNew: TRzToolButton;
    mniExportWebX: TMenuItem;
    mniImportWebX: TMenuItem;
    mniBudgetReport: TMenuItem;
    bk5win: TDdeServerConv;
    DdeStatus: TDdeServerItem;
    mniInstallCheckInExtn: TMenuItem;
    tmProcessStartupCmds: TTimer;
    mniImportFromCSV: TMenuItem;
    Viewdownloaddocuments1: TMenuItem;
    N24: TMenuItem;
    mniCharges: TMenuItem;
    mniExportCharges: TMenuItem;
    mniCombineAccounts: TMenuItem;
    mniListInactive: TMenuItem;
    mniAddManual: TMenuItem;
    mniUPIAddWith: TMenuItem;
    mniBatchReports: TMenuItem;
    N33: TMenuItem;
    N38: TMenuItem;
    mniViewNotesOnly: TMenuItem;
    mniDeleteNotes: TMenuItem;
    mniUPIAddInitWith: TMenuItem;
    mniUPIAddInitDep: TMenuItem;
    mniCheckForUpdates: TMenuItem;
    nUpdates: TMenuItem;
    mniCombineManual: TMenuItem;
    ActHomePage: TAction;
    N39: TMenuItem;
    mniQuery: TMenuItem;
    tbQuery: TRzToolButton;
    mniGSTAllocationSummary: TMenuItem;
    CRCFileCheck: TMenuItem;
    tbHome: TRzToolButton;
    mniHome: TMenuItem;
    N40: TMenuItem;
    mniResetFingerTipsLinks: TMenuItem;
    tmrDataThread: TTimer;
    mniStockBalancesJnls: TMenuItem;
    mniSystemGroups: TMenuItem;
    ClientTypes1: TMenuItem;
    mniReportStyle: TMenuItem;
    RzSpacer1: TRzSpacer;
    RzSpacer2: TRzSpacer;
    RzSpacer4: TRzSpacer;
    mniReportOption: TMenuItem;
    N41: TMenuItem;
    mniJobs: TMenuItem;
    mniSetupGraphHeadings: TMenuItem;
    N42: TMenuItem;
    ListJobs1: TMenuItem;
    ListGroups1: TMenuItem;
    ListClientTypes1: TMenuItem;
    tbJob: TRzToolButton;
    mnsJobReport: TMenuItem;
    N43: TMenuItem;
    mniEntrieswithNotes: TMenuItem;
    mniEntrieswithoutNotes: TMenuItem;
    tmrReportRun: TTimer;
    mniRemapChart: TMenuItem;
    SettheTransferFlagsforaPeriod1: TMenuItem;
    ChangetoUK1: TMenuItem;
    mniListCharges: TMenuItem;
    mniMaintainFileCostCodes: TMenuItem;
    mniRP12MonthsBudget: TMenuItem;
    tbBudgetHide: TRzToolButton;
    tbBudgetShow: TRzToolButton;
    tbBudgetChart: TRzToolButton;
    mniImportHSBC: TMenuItem;
    mniExtractBulkData: TMenuItem;
    mniBulkExportData: TMenuItem;
    mniBulkClearTransferFlags: TMenuItem;
    mniCodingOptimisationReport: TMenuItem;
    mniForexReport: TMenuItem;
    mniCustomDocs: TMenuItem;
    N44: TMenuItem;
    N99: TMenuItem;
    mniFindandReplace: TMenuItem;
    tbOnline: TRzToolButton;
    tbClose: TRzToolButton;
    tbBudgetClose: TRzToolButton;
    tbCodingClose: TRzToolButton;
    tbAbout: TRzToolButton;
    mniListProvisional: TMenuItem;
    mniFileExchangeRates: TMenuItem;
    N45: TMenuItem;
    mniSystemAuditReport: TMenuItem;
    PopGetClients: TPopupMenu;
    PopSendClients: TPopupMenu;
    fromFolder1: TMenuItem;
    fromBankLinkOnline1: TMenuItem;
    toFile1: TMenuItem;
    viaEmail1: TMenuItem;
    viaBankLinkOnline1: TMenuItem;
    actSendToFile: TAction;
    actSendViaEmail: TAction;
    actSendViaOnline: TAction;
    oFile1: TMenuItem;
    viaEmail2: TMenuItem;
    viaBankLinkOnline2: TMenuItem;
    fromFile1: TMenuItem;
    viaBankLinkOnline3: TMenuItem;
    actGetFromFolder: TAction;
    actGetFromOnline: TAction;
    mniChangePassword: TMenuItem;
    mniExportdatatoBanklinkOnline: TMenuItem;
    mmiTaxablePaymentsReport: TMenuItem;
    mniExchangeGainLossWizard: TMenuItem;
    N46: TMenuItem;
    tbBudgetImport: TRzToolButton;
    tbBudgetExport: TRzToolButton;
    RzSpacer5: TRzSpacer;
    tbRecommendedMemorisations: TRzToolButton;
    mniExportCharttoMYOBCashBooks1: TMenuItem;
    mniAssert: TMenuItem;
    mniListManual: TMenuItem;
    mniHelpProvideFeedback: TMenuItem;
    mniPromos: TMenuItem;
    procedure FormResize(Sender: TObject);
    procedure tmClockTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mniFileExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mniHelpAboutClick(Sender: TObject);
    procedure mniFileOpenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mniFileInformationClick(Sender: TObject);
    procedure mniFileCloseClick(Sender: TObject);
    procedure mniFileAbandonChangesClick(Sender: TObject);
    procedure mniFileSaveClick(Sender: TObject);
    procedure mniDECodeEntriesClick(Sender: TObject);
    procedure mniWindowCascadeClick(Sender: TObject);
    procedure mniWindowTileClick(Sender: TObject);
    procedure tbtPrevClick(Sender: TObject);
    procedure tbtNextClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniListChartofAccountsClick(Sender: TObject);
    procedure mniListEntriesClick(Sender: TObject);
    procedure mniListJournalsClick(Sender: TObject);
    procedure mniListBankAccountsClick(Sender: TObject);
    procedure mniListPayeesClick(Sender: TObject);
    procedure mniListLedgerClick(Sender: TObject);
    procedure mniBatchReportsClick(Sender: TObject);
    procedure mniCodingReportClick(Sender: TObject);
    procedure mniCFRActualClick(Sender: TObject);
    procedure mniCFRActualandBudgetClick(Sender: TObject);
    procedure mniCFRActualBudgetandVarianceClick(Sender: TObject);
    procedure mniCFR12MonthsActualClick(Sender: TObject);
    procedure mniCFR12MonthsActualandBudgetClick(Sender: TObject);
    procedure mniCFRSetupReportHeadingsClick(Sender: TObject);
    procedure mniFilePreferenceClick(Sender: TObject);
    procedure tbPayeesClick(Sender: TObject);
    procedure mniSortByClick(Sender: TObject);
    procedure mniViewAllEntriesClick(Sender: TObject);
    procedure mniViewUncodedEntriesOnlyClick(Sender: TObject);
    procedure AddOutChqClick(Sender: TObject);
    procedure AddOutDepClick(Sender: TObject);
    procedure MatchEntryClick(Sender: TObject);
    procedure AddInitChqClick(Sender: TObject);
    procedure popViewPopup(Sender: TObject);
    procedure popSortByPopup(Sender: TObject);
    procedure mniOFClientDetailsClick(Sender: TObject);
    procedure mniOFAccountingSystemClick(Sender: TObject);
    procedure mniBRRSummarisedClick(Sender: TObject);
    procedure mniBRRDetailedClick(Sender: TObject);
    procedure mniSPSummarisedClick(Sender: TObject);
    procedure mniSPDetailedClick(Sender: TObject);
    procedure mniOFGSTDetailsandRatesClick(Sender: TObject);
    procedure mniGSTSetupReportOptionsClick(Sender: TObject);
    procedure mniGSTReturnClick(Sender: TObject);
    procedure mniExPrintExceptionReportClick(Sender: TObject);
    procedure mniSetupExceptionCriteriaClick(Sender: TObject);
    procedure mniCFRFromDatetoDateClick(Sender: TObject);
    procedure mniCFRBudgetRemainingClick(Sender: TObject);
    procedure mniPRActualClick(Sender: TObject);
    procedure mniPRActualAndBudgetClick(Sender: TObject);
    procedure mniPRActualBudgetAndVarianceClick(Sender: TObject);
    procedure mniPR12MonthsActualClick(Sender: TObject);
    procedure mniPR12MonthsActualandBudgetClick(Sender: TObject);
    procedure N6FromDatetoDate2Click(Sender: TObject);
    procedure mniPRBudgetRemainingClick(Sender: TObject);
    procedure mniPRSetupReportHeadingsClick(Sender: TObject);
    procedure mniGSTSummaryClick(Sender: TObject);
    procedure mniGSTAuditTrailClick(Sender: TObject);
    procedure mniGraphSalesClick(Sender: TObject);
    procedure mniGraphPaymentsClick(Sender: TObject);
    procedure mniGraphTradingResultsClick(Sender: TObject);
    procedure mniGraphBankBalancesClick(Sender: TObject);
    procedure mniGraphOnePageSummaryClick(Sender: TObject);
    procedure mniOFPayeesClick(Sender: TObject);
    procedure mnsOFChartofAccountsClick(Sender: TObject);
    procedure mniOFMemorisedEntriesClick(Sender: TObject);
    procedure mniDECashJournalsClick(Sender: TObject);
    procedure mniDEAccrualJournalsClick(Sender: TObject);
    procedure mniDEEnterBudgetsClick(Sender: TObject);
    procedure MRUStartClick(Sender: TObject);
    procedure mniSystemPracticeDetailsClick(Sender: TObject);
    procedure mniSystemUsersClick(Sender: TObject);
    procedure mniSystemGSTDefaultsClick(Sender: TObject);
    procedure mniSystemTranTypesClick(Sender: TObject);
    procedure mniOFBankAccountsClick(Sender: TObject);
    procedure mniSystemNewAccountsClick(Sender: TObject);
    procedure mniSystemBankLinkConnectClick(Sender: TObject);
    procedure mniSystemDownloadfromFloppyClick(Sender: TObject);
    procedure mniSendClientFilesClick(Sender: TObject);
    procedure mniFileCheckInClick(Sender: TObject);
    procedure mniOFRefreshChartClick(Sender: TObject);
    procedure mniOFExtractDataClick(Sender: TObject);
    procedure ViewSystemLog1Click(Sender: TObject);
    procedure mniFileSaveAsClick(Sender: TObject);
    procedure mniFileNewClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tbarVisibleChanged(Sender: TObject);
    procedure mniHelpViewSystemLogClick(Sender: TObject);
    procedure MasterMemorisedEntries1Click(Sender: TObject);
    procedure mniViewEditCodesOnlyClick(Sender: TObject);
    procedure mniViewEditAllColClick(Sender: TObject);
    procedure mniDEOpeningBalancesClick(Sender: TObject);
    procedure mniDENTJStockJournalsClick(Sender: TObject);
    procedure mniDENTJGSTJournalsClick(Sender: TObject);
    procedure mniBudgetReportClick(Sender: TObject);
    procedure mniDEFinalisePeriodClick(Sender: TObject);
    procedure mniOFUnlockaFinalisedPeriodClick(Sender: TObject);
    procedure PracticeBankAccounts1Click(Sender: TObject);
    procedure mniReportScheduleClick(Sender: TObject);
    procedure mniSystemMonthlyReportsClick(Sender: TObject);
    procedure EmailSupport1Click(Sender: TObject);
    procedure DownloadReport1Click(Sender: TObject);
    procedure ListReportsDue1Click(Sender: TObject);
    procedure mniListAdminBankAccountsClick(Sender: TObject);
    procedure mniClientsByStaffClick(Sender: TObject);
    procedure mniClientReportOptionsClick(Sender: TObject);
    procedure mniDownloadLogClick(Sender: TObject);
    procedure mniOffsiteDownloadClick(Sender: TObject);
    procedure mniImportUpdateClick(Sender: TObject);
    procedure mniOffsiteDownloadLogClick(Sender: TObject);
    procedure mniResyncroniseClientClick(Sender: TObject);
    procedure mniSyncroniseMyClientClick(Sender: TObject);
    procedure mniAddHistoricalClick(Sender: TObject);
    procedure mniOFPurgeOldEntriesClick(Sender: TObject);
    procedure mniConfigureColumnsClick(Sender: TObject);
    procedure mnsTestClick(Sender: TObject);
    procedure RestoreColumnDefaultsClick(Sender: TObject);
    procedure mniLoadBASTemplateClick(Sender: TObject);
    procedure mniSaveBASTemplateClick(Sender: TObject);
    procedure mniBusinessNormsClick(Sender: TObject);
    procedure GSTOverrides1Click(Sender: TObject);
    procedure mniListGSTDetailsClick(Sender: TObject);
    procedure mniTransferEntriesClick(Sender: TObject);
    procedure mniListMemorisationsClick(Sender: TObject);
    procedure IncrementDates1Click(Sender: TObject);
    procedure mniTestAdminLockingClick(Sender: TObject);
    procedure mniRecombineClick(Sender: TObject);
    procedure mniClientStatusReportClick(Sender: TObject);
    procedure miCFRActualLastYearVarianceClick(Sender: TObject);
    procedure mniMaintainChartClick(Sender: TObject);
    procedure mniSetupDivisionsClick(Sender: TObject);
    procedure mniSetupSubgroupsClick(Sender: TObject);
    procedure mniExportBNToFileClick(Sender: TObject);
    procedure mniExportBNtoMailClick(Sender: TObject);
    procedure mniImportECodingFileClick(Sender: TObject);
    procedure mniAnnualGSTreportClick(Sender: TObject);
    procedure mniAnnualGSTReturnClick(Sender: TObject);
    procedure EmailSystemLog1Click(Sender: TObject);
    procedure mniClearTransferFlagsClick(Sender: TObject);
    procedure mniClientFileAccessReportClick(Sender: TObject);
    procedure mniCFCustomClick(Sender: TObject);
    procedure mnsTrialBalanceClick(Sender: TObject);
    procedure mniPRCustomClick(Sender: TObject);
    procedure mniSetUpReportHeadingsClick(Sender: TObject);
    procedure mniBalanceSheetClick(Sender: TObject);
    procedure mniYearEndAdjustmentsClick(Sender: TObject);
    procedure mniYearEndClick(Sender: TObject);
    procedure mniOpeningsBalanceJnlsClick(Sender: TObject);
    procedure DownloadReportSummarised1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure mniUnpresentedItemsClick(Sender: TObject);
    procedure mniListSubGroupsClick(Sender: TObject);
    procedure mniListDivisionsClick(Sender: TObject);
    procedure tmAutoSaveTimer(Sender: TObject);
    procedure mniGST12MonthSummaryClick(Sender: TObject);
    procedure actClientManagerExecute(Sender: TObject);
    procedure mniCFExportClick(Sender: TObject);
    procedure mniPRExportClick(Sender: TObject);
    procedure mniBalanceExportClick(Sender: TObject);
    procedure mnsSystemClientsClick(Sender: TObject);
    procedure actTasksExecute(Sender: TObject);
    procedure CreateAnalysisCodingTest1Click(Sender: TObject);
    procedure mniStatisticsClick(Sender: TObject);
    procedure mniRaiseExceptionClick(Sender: TObject);
    procedure mniMissingChequesClick(Sender: TObject);
    procedure mniBKHelpClick(Sender: TObject);
    procedure WMENTERMENULOOP (var Msg: TWMEnterMenuLoop ); message WM_ENTERMENULOOP;
    procedure WMEXITMENULOOP (var Msg: TWMEnterMenuLoop ); message WM_EXITMENULOOP;
    procedure mnsSpendingbyPayeeClick(Sender: TObject);
    procedure mniBackupClick(Sender: TObject);
    procedure mniRestoreClick(Sender: TObject);
    procedure mnsImportBNotesClick(Sender: TObject);
    procedure mniTutorialsTOCClick(Sender: TObject);
    procedure tbBudgetHelpClick(Sender: TObject);
    procedure tbCodingHelpClick(Sender: TObject);
    procedure tbGenerateClick(Sender: TObject);
    procedure tbSmoothClick(Sender: TObject);
    procedure tbAverageClick(Sender: TObject);
    procedure tbCopyClick(Sender: TObject);
    procedure tbIncreaseClick(Sender: TObject);
    procedure tbSplitClick(Sender: TObject);
    procedure tbChartClick(Sender: TObject);
    procedure tbPayeeClick(Sender: TObject);
    procedure tbMemoriseClick(Sender: TObject);
    procedure tbDissectClick(Sender: TObject);
    procedure tbSuperClick(Sender: TObject);
    procedure tbGotoClick(Sender: TObject);
    procedure tbRepeatClick(Sender: TObject);
    procedure tbFindClick(Sender: TObject);
    procedure tbUPIClick(Sender: TObject);
    procedure rzToolbarsResize(Sender: TObject);
    procedure mniExportWebXClick(Sender: TObject);
    procedure mniImportWebXClick(Sender: TObject);
    procedure bk5winExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure DdeStatusPokeData(Sender: TObject);
    procedure mniInstallCheckInExtnClick(Sender: TObject);
    procedure tmProcessStartupCmdsTimer(Sender: TObject);
    procedure mniImportFromCSVClick(Sender: TObject);
    procedure Viewdownloaddocuments1Click(Sender: TObject);
    procedure mniAddManualClick(Sender: TObject);
    procedure mniUPIAddWithClick(Sender: TObject);
    procedure mniExportChargesClick(Sender: TObject);
    procedure mniViewNotesOnlyClick(Sender: TObject);
    procedure mniDeleteNotesClick(Sender: TObject);
    procedure mniCombineAccountsClick(Sender: TObject);
    procedure mniListInactiveClick(Sender: TObject);
    procedure mniUPIAddInitWithClick(Sender: TObject);
    procedure mniUPIAddInitDepClick(Sender: TObject);
    procedure mniCheckForUpdatesClick(Sender: TObject);

    procedure mnsReportClick(Sender: TObject);
    procedure mniCombineManualClick(Sender: TObject);
    procedure ActHomePageExecute(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mniQueryClick(Sender: TObject);
    procedure tbQueryClick(Sender: TObject);
    procedure mniGSTAllocationSummaryClick(Sender: TObject);
    procedure CRCFileCheckClick(Sender: TObject);
    procedure mniResetFingerTipsLinksClick(Sender: TObject);
    procedure tmrDataThreadTimer(Sender: TObject);
    //procedure mniStockBalancesClick(Sender: TObject);
    procedure mniStockBalancesJnlsClick(Sender: TObject);
    procedure mniSystemGroupsClick(Sender: TObject);
    procedure ClientTypes1Click(Sender: TObject);
    procedure mniReportStyleClick(Sender: TObject);
    procedure mniJobsClick(Sender: TObject);
    procedure mniSetupGraphHeadingsClick(Sender: TObject);
    procedure ListJobs1Click(Sender: TObject);
    procedure ListClientTypes1Click(Sender: TObject);
    procedure ListGroups1Click(Sender: TObject);
    procedure tbJobClick(Sender: TObject);
    procedure mnsJobReportClick(Sender: TObject);
    procedure mniEntrieswithNotesClick(Sender: TObject);
    procedure mniEntrieswithoutNotesClick(Sender: TObject);
    procedure tmrReportRunTimer(Sender: TObject);
    procedure mniReMapChartClick(Sender: TObject);
    procedure mniSystemReportsClick(Sender: TObject);
    //procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND; //removed because of case 11054
    procedure SettheTransferFlagsforaPeriod1Click(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure ChangetoUK1Click(Sender: TObject);
    procedure mniListChargesClick(Sender: TObject);
    procedure mniMaintainFileCostCodesClick(Sender: TObject);
    procedure mniRP12MonthsBudgetClick(Sender: TObject);
    procedure tbBudgetHideClick(Sender: TObject);
    procedure tbBudgetShowClick(Sender: TObject);
    procedure tbBudgetChartClick(Sender: TObject);
    procedure mniForexReportClick(Sender: TObject);
    procedure mniImportHSBCClick(Sender: TObject);
    procedure mniBulkExportDataClick(Sender: TObject);
    procedure mniBulkClearTransferFlagsClick(Sender: TObject);
    procedure mniCodingOptimisationReportClick(Sender: TObject);
    procedure mniFindandReplaceClick(Sender: TObject);
    procedure mniCustomDocsClick(Sender: TObject);
    procedure tbOnlineClick(Sender: TObject);
    procedure mniExtractBulkDataClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure tbBudgetCloseClick(Sender: TObject);
    procedure tbCodingCloseClick(Sender: TObject);
    procedure mniListProvisionalClick(Sender: TObject);
    procedure mniFileExchangeRatesClick(Sender: TObject);
    procedure mniSystemAuditReportClick(Sender: TObject);
    procedure AUDITREPORTTEST1Click(Sender: TObject);
    procedure viaBankLinkOnline1Click(Sender: TObject);
    procedure actSendToFileExecute(Sender: TObject);
    procedure actSendViaEmailExecute(Sender: TObject);
    procedure actSendViaOnlineExecute(Sender: TObject);
    procedure actGetFromFolderExecute(Sender: TObject);
    procedure actGetFromOnlineExecute(Sender: TObject);
    procedure mniChangePasswordClick(Sender: TObject);
    procedure mniExportdatatoBanklinkOnlineClick(Sender: TObject);
    procedure mmiTaxablePaymentsReportClick(Sender: TObject);
    procedure mniExchangeGainLossWizardClick(Sender: TObject);
    procedure tbBudgetImportClick(Sender: TObject);
    procedure tbBudgetExportClick(Sender: TObject);
    procedure tbRecommendedMemorisationsClick(Sender: TObject);
    procedure mniExportCharttoMYOBCashBooks1Click(Sender: TObject);
    procedure mniAssertClick(Sender: TObject);
    procedure mniListManualClick(Sender: TObject);
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure mniHelpProvideFeedbackClick(Sender: TObject);
    procedure mniPromosClick(Sender: TObject);

  private
    FOnToolBarResize : TMultiCastNotify;
    FClientInstance,
    FPrevClientProc : TFarProc;
    Image1Top, Image1Left, Image1Width, Image1Height : Integer;
    BackGroundImageVisible : boolean;
    TutorialsFile : string;

    LastMFTop,
    LastMFLeft,
    LastMFWidth,
    LastMFHeight : integer;

    ApplicationIsStarting: Boolean;
    ProcessingDDECommand : Boolean;
    FLastActiveMDIChild: Forms.TForm;
    FLastActiveMDIChild2: Forms.TForm;
    FAdminSystemFound: boolean;
    fMDIChildSortedList : TStringList;
    fMDIChildSortedIndex : integer;

  //LeanEngage NPS service
    NPSLeanEngage : TNPSLeanEngage;
    procedure InitialiseLeanEngage;


    procedure SetExportdatatoBanklinkOnlineVisiblility();

    procedure ClientWndProc(var WinMsg: TMessage);

    procedure AddMenuItem( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );
    procedure AddMenuItems( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );
    procedure AssignMenuItems( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );

    procedure ExitBankLink;
    procedure SetupHelp;
    procedure DoCodingTBarCommand(command: TExternalCmd);
    procedure DoBudgetTBarCommand(command: TExternalCmdBudget);
    procedure ProcessModalCmdWithDlg( command : TModalProcessorCommand);

    function  LoadCustomLogofromString(S: String): boolean;
    procedure ResetCustomLogoSize;
    procedure DoFileOpen;
    procedure DoOpenFromMRU( Sender : TObject);
    procedure bkShowCM( var msg: TMessage ); message BK_SHOWCM;
//    procedure bkDirRequest( var msg: TMessage); message BK_DIR_REQUEST;
//    procedure bkIsBusy( var msg : TMessage); message BK_IS_BUSY;

    function DoAutoSave: Boolean;
    function CanAutoSaveNow: boolean;
    function LoadCustomLogoFromFile(filename: string) : boolean;
    procedure ResetAutoSave;
    procedure DoHDE;
    procedure DoMDE;
    procedure DoClientDetails(PopupParent: Forms.TForm; ViewNotes : Boolean = False);
    procedure DoEditGSTDetails;
    procedure DoGSTReturn;
    procedure DoAccountingSystem;
    procedure DoMaintainChart;
    procedure DoMaintainBankAccounts;
    procedure MaintainMems;
    procedure DoLoadBasTemplate;
    procedure DoRefreshChart;
    procedure DoExtract;
    procedure DoBNotesExport(Dest: byte);
    procedure ImportBNotesFromFile(Dest: Byte);
    procedure DoTasks;
    procedure DoLockPeriod;
    procedure DoUnlockPeriod;
    procedure ImportUpdateFile;
    procedure PurgeEntries;
    procedure TransferTempEntries;
    procedure Synchronise;
    procedure DoAnnualGST_AU;
    procedure DoAnnualGSTReturn_AU;
    procedure DoMasterMems;
    procedure ForceOffsiteBackup;
    procedure RepositionLogos( Sender : TObject);
    procedure ResetToolbarSize(TBar: TRzToolbar);
    procedure SetCaptionState( TBar : TRzToolbar; CaptionOn: boolean);
    procedure StopAutoSaveTimer;
    procedure RestartAutoSaveTimer;
    procedure DoCombineAccounts;
    procedure DoCombineManualAccounts;
    procedure WMQueryEndSession(var Msg : TWMQueryEndSession); message WM_QueryEndSession;
    procedure WMEndSession(var Msg : TWMEndSession); message WM_ENDSESSION;
    procedure ProcessDDEMacro(var Macro: string);
    procedure SetLastActiveMDIChild(const Value: Forms.TForm);
    property LastActiveMDIChild :Forms.TForm read FLastActiveMDIChild write SetLastActiveMDIChild;
    procedure RunGSTReport (Value: REPORT_LIST_TYPE);
    procedure ShowExportTransactionsDialog;
    procedure ExportTransactionsToBankLinkOnline;

    procedure ExportTaggedAccounts(ProgressForm: IDualProgressForm; CallbackParams: Pointer);
    procedure DoRebranding();

    //procedure ThreadMessage(var Message: TMessage);	message THREAD_MESSAGE;
    procedure DisplayAvailableNPSSurveys(Sender: TObject);

  protected
    procedure UpdateActions; override;
    function GetMDIChildSortedList : TStringList;

    property MDIChildSortedList : TStringList read GetMDIChildSortedList write fMDIChildSortedList;
  public
    { Public declarations }
    ProgressBar1        : TProgressBar;
    AutoSaveInProgress  : Boolean;
    AutoSaveOutstanding : Boolean;
    SavedAutoSaveEnabled : Boolean;
    SavedAutoSaveInterval : Integer;
    SavedAutoSaveClient : string;
    UsingCustomPracticeLogo : boolean;
    property LastActiveMDIChild2 :Forms.TForm read FLastActiveMDIChild2 write FLastActiveMDIChild2;

    function GetTabIndex(aTabWindow : TRzTabControl; aMDIIndex: integer): integer;
    procedure SetActiveMDI(aTabWindow : TRzTabControl; aTabIndex: integer);

    procedure RemoveMDI(aMDIindex : integer);

    procedure NextSortedMDI();
    procedure PrevSortedMDI();
    function GetMDIIndexFromCaption(aCaption : string) : integer;
    procedure ActivateMDIChild(aMDIIndex: integer);
    procedure UpdateTabs(aTabWindow : TRzTabControl; aActionedPage: string = '');
    procedure UpdateAllWindowTabs(Sender: TObject;aActionedPage: string = '';Destroying:Boolean=False);

    procedure DoMainFormCommand( command : byte; Modal : boolean = true); overload;
    procedure DoMainFormCommand( command : byte; Sender : TObject; Modal : boolean = true); overload;

    procedure DisplayHint(Sender: TObject);
    procedure OnUnHandledError( Sender:TObject; E:Exception);
    procedure OnAppIdle(Sender: TObject; var Done: Boolean);
    procedure OnActive(Sender:TObject);

    procedure RedrawClientName;
    procedure RedrawFormBackground;
    procedure BKArrangeToolBars;
    procedure SetToolBarCaptionState( CaptionOn: boolean);
    procedure RebuildPopups;
    procedure ReloadCustomLogo;
    procedure RefreshClientManager;
    procedure MenuCopyToPopUp(Option: String; MPopUp: TPopUpMenu);
    procedure TryAutoSave;
    procedure ActiveFormChange(Sender: TObject);
    procedure ActivateApplication(Sender: TObject);
    procedure RefreshUserControls;
    procedure UpdateWindowsAfterChartRefresh();

    function GetMDICurrentChildCaption : string;
    property MDIChildSortedIndex : Integer read fMDIChildSortedIndex write fMDIChildSortedIndex;
    property OnToolBarResize : TMultiCastNotify read FOnToolBarResize write FOnToolBarResize;
  end;


const
  //main form_modal command
  mf_mcUnknown                 = 0;
  mf_mcOpenFile                = 1;
  mf_mcCloseFile               = 2;
  mf_mcNewFile                 = 3;
  mf_mcCheckIn                 = 4;
  mf_mcSendClientFiles         = 5;
  mf_mcAbandon                 = 6;
  mf_mcSave                    = 7;
  mf_mcSaveAs                  = 8;
  mf_mcOpenFromMRU             = 9;
  mf_mcCoding                  = 10;
  mf_mcHDE                     = 11;
  mf_mcBudgets                 = 12;
  mf_mcCashJournals            = 13;
  mf_mcAccrualJournals         = 14;
  mf_mcOpeningBalanceJnls      = 15;
  mf_mcStockJournals           = 16;
  mf_mcYearEndJournals         = 17;
  mf_mcGSTJournals             = 18;
  mf_mcOpeningBalances         = 19;
  mf_mcYearEnd                 = 20;
  mf_mcClientDetails           = 21;
  mf_mcAccountingSystem        = 22;
  mf_mcGSTDetails              = 23;
  mf_mcGSTReturn               = 24;
  mf_mcMaintainChart           = 25;
  mf_mcEditDivisions           = 26;
  mf_mcEditSubgroups           = 27;
  mf_mcMaintainPayees          = 28;
  mf_mcMaintainBankAccounts    = 29;
  mf_mcMaintainMems            = 30;
  mf_mcLoadBasTemplate         = 31;
  mf_mcSaveBasTemplate         = 32;
  mf_mcRefreshChart            = 33;
  mf_mcExtract                 = 34;
  mf_mcExportBNotesToFile      = 35;
  mf_mcExportBNotesToMail      = 36;
  mf_mcImportBNotesFromFile    = 37;
  mf_mcDoTasks                 = 38;
  mf_mcClearTransferFlags      = 39;
  mf_mcLockPeriod              = 40;
  mf_mcUnlockPeriod            = 41;
  mf_mcImportUpdateFile        = 42;
  mf_mcTransferEntries         = 43;
  mf_mcPurgeEntries            = 44;
  mf_mcSynchronise             = 45;
  mf_mcAnnualGSTReport         = 46;
  mf_mcAnnualGSTReturn         = 47;
  mf_mcSys_MasterMems          = 48;
  mf_mcSys_AttachAccounts      = 49;
  mf_mcOffsiteBackup           = 50;
  mf_mcOffsiteRestore          = 51;
  mf_mcExportWebX              = 52;
  mf_mcImportWebX              = 53;
  mf_mcViewDiskDocs            = 54;
  mf_mcMDE                     = 55;
  mf_mcExportCharges           = 56;
  mf_mcClearNotes              = 57;
  mf_mcCombineAccounts         = 58;
  mf_mcClientNotes             = 59;
  mf_mcCombineManualAccounts   = 60;
  mf_mcQueryUncoded            = 61;
  mf_mcStockBalanceJnls        = 62;
  mf_mcmaintainJob             = 63;
  mf_mcSetTransferFlags        = 64;
  mf_mcListCharges             = 65;
  mf_mcMaintainFileCostCodes   = 66;
  mf_DoBulkExtract             = 67;
  mf_DoBulkClear               = 68;
  mf_FindAndReplace            = 69;
  mf_MaintainInactiveBankAccounts = 70;
  mf_mcSystemOptions           = 71;
  mf_mcTrialBalance            = 72;
  mf_mcViewCashJournals        = 73;
  mf_mcViewAccrualJournals     = 74;
  mf_mcExchangeRates           = 75;
  mf_mcSendOnline              = 76;
  mf_mcGetOnline               = 77;
  mf_mcTransactionsToBankLinkOnline = 78;
  mf_mcExchangeGainLossWizard  = 79;
  mf_mcExportChartToMYOBEssentialsCashbook = 80;

  // Data Export Menu item has been disabled until at a later date the code has been completed
  DATA_EXPORT_MENU_ITEM_ENABLED = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
var
  frmMain: TfrmMain;

//******************************************************************************
implementation

uses
  FindReplacefrm,
  BulkExtractfrm,
  hh,
  frmFiletest,
  About,
  AcctSystemDlg,
  AdminOptionsDlg,
  ApplicationUtils,
  Archivecheck,
  AttachNewDlg,
  AutoSaveUtils,
  BalancesForward,
  BalancesForwardWiz,
  BalanceSheetNamesDlg,
  BalanceSheetOptionsDlg,
  Basfrm,
  bkBranding,
  bkconst,
  bkdefs,
  BKHelp,
//  CurrencyConversions,
  ClientHomePagefrm,
  bkutil32,
  bkXPThemes,
  ChartFrm,
  cInfoFrm,
  CashflowOptionsDlg,
  ClientDetailsFrm,
  ClientManagerFrm,
  ClientReportScheduleDlg,
  cmObj32,
  DateUtils,
  DivisionFrm,
  DownloadEx,
  ECodingUtils,
  EditGstDlg,
  EditPracGSTDlg,
  ErrorLog,
  ErrorMoreFrm,
  ExceptH,
  ExchangeGainLossWiz,
  Extract32,
{$IFDEF SmartLink}
  FingerTipsInterface,
{$ENDIF}
  CheckWebnotesData,
  finalise32,
  genUtils,
  glConst,
  graphDefs,
  GraphNamesDlg,
  graphs,
  GST101frm,
  GSTUtil32,
  HistoricalDlg,
  Imagesfrm,
  Import32,
  ImportExtraDlg,
  InfoMoreFrm,
  Journals,
  JnlUtils32,
  LockUtils,
  LogUtil,
  MailFrm,
  MaintainBankFrm,
  MaintainChartfrm,
  MaintainMemFrm,
  MaintainPayeesFrm,
  MaintainPracBankFrm,
  MaintainUsersFrm,
  MaintainGroupsFrm,
  Math,
  Merge32,
  MimeUtils,
  NewClientWiz,
  OffsiteBackup,
  OffsiteDownload,
  OpeningBalancesDlg,
  Optionsfrm,
  ovcDate,
  PayeeDetailDlg,
  PracDetailsFrm,
  PracticeLogo,
  ProfitAndLossOptionsDlg,
  PurgeClientEntriesDlg,
  RecommendedMems,
  Resync,
  Scheduled,
  SetClearTransferFlags,
  SetCriteriaDlg,
  SetupSubgroupsFrm,
  ShellAPI,
  SimpleUIOpenPageFrm,
  StatusFrm,
  StatsFrm,
  Templates,
  ToDoHandler,
  TransferEntriesDlg,
  TransTypeDlg,
  TrialBalanceOptionsDlg,
  utList32,
  utObj32,
  VATReturn,
  WarningMoreFrm,
  rptParams,
{$IFDEF BK5_TESTLOCKING}
  LockingTestFrm,
{$ENDIF}
  WinUtils,
  YesNoDlg,
{$IFDEF CSVImport}
  CSVImportfrm,
{$ENDIF}
  BillingDocReaderFrm,
  UpgradeHelper,
  dlgReportOptions,
  ZipUtils,
  clObj32,
  baObj32,
  trxList32,
  CombineAccountsDlg,
  CombineManualAccountsDlg,
  UsageUtils,
  SyDefs,
  QueryTx,
  EnterPwdDlg,
  Chartremapfrm,
  ListChargesDlg,
  CountryUtils,
  HSBCDemo,
  CustomDocEditorFrm,
  frmExchangeRates,
  BankLinkOnlineServices,
  EditUserPassword,
  TransactionsToBankLinkOnlineFrm,
  BankLinkOnlineTaggingServices,
  ModalDualProgressFrm,
  BlopiServiceAgreement,
  bkProduct,
  BroadcastSystem,
  UpgradeReminder,
  RecommendedMemorisationsFrm,
  JournalDlg,
  SuggestedMems,
  ChartExportToMYOBCashbook,
  WebUtils,
  formWebHost,
  uLeanEngageLib,
  formLEFeedback,
  PromoWindowObj,
  PromoDisplayForm;
  //StockBalancesDlg;

const
  AutoSaveMultiplier = 60000;  //should be 60000;  from ms to a minute
  DebugAutoSave: Boolean = False;
  AutoSaveUnit = 'AutoSave';

const
  ToolBarButtonGlyphOnlyWidth = 26;
  ToolBarButtonWithTextWidth  = 35;
  ToolbarButtonDropArrowWidth = 12;
  ToolbarFontSize             = 4;

const
  UnitName = 'MAINFRM';

const
  ModalFileCommands = [ mf_mcUnknown,
                        mf_mcOpenFile,
                        mf_mcCloseFile,
                        mf_mcNewFile,
                        mf_mcAbandon,
                        mf_mcSave,
                        mf_mcSaveAs,
                        mf_mcOpenFromMRU,
                        mf_mcExchangeRates
                       ];

const
  CANNOT_CLOSE_MDI_MSG = 'Cannot close current Code Entries/Budget windows';

type
  TMyPanel = class( TPanel)
    public
      property Canvas;
  end;

{$R *.DFM}

var
  DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Do a tidy close if windows is shutting down

procedure TfrmMain.WMQueryEndSession(var Msg : TWMQueryEndSession);
begin
  LogUtil.LogMsg(lmInfo, UnitName, 'Windows is shutting down from main screen');
  Close;
  Msg.Result := 1;
end;

procedure TfrmMain.WMSyscommand(var Message: TWmSysCommand);
begin
  case (Message.CmdType and $FFF0) of
    sc_NextWindow:
    begin
      Message.Result := 0;
    end;
    sc_PrevWindow:
    begin
      Message.Result := 0;
    end;
    else
      inherited;
  end;
end;

procedure TfrmMain.WMEndSession(var Msg : TWMEndSession);
begin
  inherited;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Randomize;
  FOnToolBarResize := TMultiCastNotify.Create(self);
  ApplicationIsStarting := true;
  Globals.DDE_Macro_To_Process := '';

  //turn on XP theme manager
  bkXPThemes.ThemeForm( Self);

  //set the global constants for colors and graphics
  bkBranding.InitialiseGraphicsAndColors( Self.Canvas.Handle);
  lblClientName.Font.Name := Font.Name;
  UsingCustomPracticeLogo := false;

  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
     GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW
           or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);


  LastMFTop := 0;
  LastMFLeft := 0;
  LastMFWidth := 0;
  LastMFHeight := 0;

  //redirect the messge handler to ClientWndProc, only need to do this is
  //drawing an image on the background
  FClientInstance := Classes.MakeObjectInstance(ClientWndProc);
  FPrevClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));
  SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FClientInstance));
  {Initialise}
  Application.Title       := APPTITLE;
  Application.OnHint      := DisplayHint;
  {$ifdef MadExcept}
  {$else}
  Application.OnException := OnUnHandledError;
  {$endif}
  Application.OnIdle      := OnAppIdle;
  Application.OnActivate  := OnActive;

  Self.Caption            := APPTITLE;
  BackGroundImageVisible  := true;

  MainStatus.Panels[PANELF1].Text   := '';  //until such time as we have help!!
//  MainStatus.Panels[PANELTIME].Text := '  '+DateToStr(Now)+'   '+TimeToStr(Now)+'  ';
  MainStatus.Panels[PANELMSG].Text  := 'Ready...';

  //Copy Menus to ToolBar PopUps
  MenuCopyToPopUp( 'mnsReport', popReport );
  MenuCopyToPopUp( 'mnsGraph',  popGraph  );
  AddMenuItems( popGST, mnsGSTReports, popGST.Items );

//  SetupHelp;

  //Setup Form size status etc from INI settings
  //default of -1 indicates value not present
  if INI_mfStatus <> 0 then begin
     if INI_mfTop <> -1 then Top := INI_mfTop;
     if INI_mfLeft <> -1 then Left := INI_mfLeft;
     if INI_mfWidth <> -1 then Width := INI_mfWidth;
     if INI_mfHeight <> -1 then Height := INI_mfHeight;
  end;

  case INI_mfStatus of
     {1: WindowState := wsNormal; //this is already the default}
     3: WindowState := wsMaximized;
  end;
  if PRACINI_CRCFileTest then
     CRCFileCheck.Visible := True;

  rztFile.Visible := false;
  rztClient.Visible := false;
  rztCoding.Visible := false;
  rztBudget.Visible := false;

  bkBranding.StyleBankLinkButton(tbOnline);
  bkBranding.StyleECFHOnlineMenuItem(viaBankLinkOnline3);
  bkBranding.StyleECFHOnlineMenuItem(viaBankLinkOnline2);
  bkBranding.StyleECFHOnlineMenuItem(fromBankLinkOnline1);
  bkBranding.StyleECFHOnlineMenuItem(viaBankLinkOnline1);
  bkBranding.StyleECFHOnlineMenuItem(mniCodingReport);
  bkBranding.StyleECFHOnlineMenuItem(mnsExportBNoteFile);
  bkBranding.StyleECFHOnlineMenuItem(mnsImportBNotes);
  bkBranding.StyleECFHOnlineMenuItem(mniExportWebX);
  bkBranding.StyleECFHOnlineMenuItem(mniImportWebX);


  mnsExportBNoteFile.Caption := 'Export ' + bkBranding.NotesProductName + ' File';
  mnsImportBNotes.Caption    := 'Import ' + bkBranding.NotesProductName + ' File';

  mniExportWebX.Caption := 'Export ' + glConst.WEBX_GENERIC_APP_NAME  + ' File';
  mniImportWebX.Caption := 'Import ' + glConst.WEBX_GENERIC_APP_NAME + ' File';

  UPDATEMF.UpdateMenus;
  UPDATEMF.UpdateSystemMenus;

  DoRebranding();

  Screen.OnActiveFormChange := ActiveFormChange;
  if DebugMe then LogUtil.LogMsg(lmDebug,unitname,'Form Created');

  //Initialise LeanEngage artefacts
  NPSLeanEngage := nil;
  frmLEFeedback := nil;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.actGetFromFolderExecute(Sender: TObject);
begin
  IncUsage('Check In');
  DoMainFormCommand( mf_mcCheckIn);
end;

procedure TfrmMain.actGetFromOnlineExecute(Sender: TObject);
begin
  if not ProductConfigService.IsPracticeActive then
    Exit;

  //From BankLink Online
  DoMainFormCommand( mf_mcGetOnline);
end;

procedure TfrmMain.ActHomePageExecute(Sender: TObject);
begin
  RefreshHomepage([HRP_Init]);
end;

procedure TfrmMain.ActivateApplication(Sender: TObject);
begin
  // There are strange focus problems on some machines - try to always bring the
  // whole app back when it gets activated...
  // Changed this to only work in the forms that are causing problems,
  // otherwise when we view stuff in word/excel/pdf etc it doesnt get focus!
  Application.BringToFront;
end;

procedure TfrmMain.ActiveFormChange(Sender: TObject);
begin
  LastActiveMDIChild := OsFont.TForm (ActiveMDIChild);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.SetupHelp;
var
  AppName1, AppName2: string;
begin
   //standard buttons
   tbOpen.Hint  :=
                'Open Clients (Shift+F12)|'
                +'Open Clients (Click the arrow for recently used files)';
   tbSave.Hint  :=
                'Save Client File|'
                +'Save the Client File you are working on';
   if FAdminSystemFound then begin
     //Practice
     AppName1 := bkBranding.BooksProductName;
     AppName2 := bkBranding.PracticeProductName;
   end else begin
     //Books
     AppName1 := bkBranding.PracticeProductName;
     AppName2 := bkBranding.BooksProductName;
   end;
   tbGetClientFiles.Hint  :=
                'Update a Client File|'
                +'Update a Client File from ' + AppName1 + ' or another '+ AppName2 + ' System';
   tbSendClientFiles.Hint :=
                'Send a Client File|'
                +'Send a Client File for coding by ' + AppName1 + ' or another ' + AppName2 + ' System';
//   tbSendTo.Hint  :=
//                'Email the Client File|'
//                +'Email the Client File';

   //Open client toolbar
   tbCoding.Hint  :=
                'Code Transactions|'
                +'Code Transactions, Memorise Entries, Enter Unpresented Items...';
   tbBudget.Hint  :=
                'Enter Budgets|'
                +'Enter Budgets';
   tbReport.Hint  :=
                'Print Reports|'+
                'Print Reports';
   tbGraph.Hint  :=
                'Print Graphs|'+
                'Print Graphs';
   tbGST.Hint  :=
                'GST Reports and Setup|'
                +'Print GST Reports and setup the GST Options, Details and Rates';

   //budget toolbar
   tbZero.Hint  :=
                'Clear all of the figures in this Budget';
   tbGenerate.Hint  :=
                'Generate an Initial Budget|'
                +'Generate an Initial Budget from the client''s actual figures';
   tbSmooth.Hint  :=
                'Smooth Table|'
                +'Smooth ALL figures to rounded amounts';
   tbAverage.Hint :=
                'Average Row Total|'
                +'Total the figures in this row and put the average figure in each period';
   tbSplit.Hint  :=
                'Split Figure|'
                +'Split the figure in the current cell across all twelve periods';
   tbcopy.Hint  :=
                'Copy figure to the rest of this row|'
                +'Copy the figure in the current cell to all the remaining cells in this row';
   tbIncrease.Hint :=
                'Increase/Decrease figures by a specified percentage';
   tbBudgetHide.Hint := 'Hide Zero Rows|' +
                        'Hide all rows with no values';
   tbBudgetShow.Hint := 'Show All Rows|' +
                        'Shows all chart codes in the budget';
   tbBudgetChart.Hint := 'Lookup Chart of Accounts|' +
                         'Lookup the chart of accounts and move selection to that account';
   //Coding toolbar
   tbView.Hint  :=
                'Change View|'
                +'View all transactions or uncoded only, edit all columns or code column only etc..';
   tbChart.Hint  :=
                'Look up the Chart of Accounts|'
                +'Look up the client''s Chart of Accounts';
   tbFind.Hint  :=
                'Find a Transaction|'
                +'Find a transaction by date, reference and/or amount';
   tbRepeat.Hint  :=
                'Repeat Field|'
                +'Repeat the information from the row above';
   tbGoto.Hint  :=
                'Go to Next Uncoded|'
                +'Go to the next uncoded transaction';
   tbSort.Hint  :=
                'Sort the Transactions|'
                +'Sort the transactions into a different order';
   tbDissect.Hint  :=
                'Dissect a Transaction|'
                +'Dissect the transaction total over multiple chart codes';
   tbMemorise.Hint  :=
                'Memorise a Transaction|'
                +'Memorise a transaction and code it automatically each time it appears';
   tbPayee.Hint  :=
                'Look up the Payee List|'
                +'Look up the client''s Payee List';
   tbJob.Hint  :=
                'Look up the Job List|'
                +'Look up the client''s Job List';
   tbUPI.Hint  :=
                'Enter Unpresented Cheques|'
                +'Enter Unpresented Cheques (Click the arrow for more options)';
   tbSuper.Hint := 'Superfund details|'
                + 'View/Edit Superfund details for this transaction';

   tbQuery.Hint :=
                'Query Uncoded Transactions|'
                +'Send an email to query uncoded transactions';

   BKHelpSetUp( Self, BKH_Start_here_);

   TutorialsFile := ExecDir + 'tutorial.chm';
   mniTutorialsTOC.Caption := AppTitle + ' &Tutorial';
   mniTutorialsTOC.Visible := BKFileExists(TutorialsFile);
   
   mniBKHelp.Caption := AppTitle + ' &Help';
   mniBKHelp.Visible := bkHelp.BKHelpFileExists;

   tbCodingHelp.Visible := bkHelp.BKHelpFileExists;

   tbBudgetHelp.Visible := bkHelp.BKHelpFileExists;

   N4.Visible := not( mniTutorialsTOC.Visible and mniHelpAbout.Visible);

   mniHelpProvideFeedback.Visible := FAdminSystemFound; // Books users do not get any LeanEngage functionality
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormShow(Sender: TObject);

   //--------------------------------------------------------------
   procedure ArchiveLogFile( const LogBackupDir : string);
   var
      sMsg         : string;
   begin
      Progress.UpdateAppStatus( 'Archiving System Log', 'This may take a few minutes', 60, ProcessMessages_On);
      try
         try
            SysLog.Archive( LogBackupDir, 'BK' );
         except
            on E : Exception do begin
               sMsg := 'Unable to archive log file. Error = ' + E.Message +
                       ' [' + E.ClassName + ']';
               HelpfulErrorMsg( sMsg, 0);
            end;
         end;
      finally
         Progress.ClearStatus;
      end;
   end;
   //--------------------------------------------------------------
const
  unitname = 'FormShow';
var
  UsernameToTry     : string;
  NumUsersLoggedIn  : integer;
  i                 : integer;
  ArchiveLogNeeded  : boolean;
  LogBackupDir      : string;
{$IFDEF SmartLink}
  ShowSmartLinkHelp : boolean;
{$ENDIF}
(*  ClientManagerFormPointer : TfrmClientManager; *)

begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug,unitname,'Form Show Started');

  FAdminSystemFound := Assigned( AdminSystem) or AdminExists;
  SetupHelp;

  mniChangePassword.Visible := FAdminSystemFound;


  if FAdminSystemFound then
  begin
    DoClientManager(0, 0, 0, 0);
    Globals.Active_UI_Style := UIS_Standard;
  end
  else
  begin
    Globals.Active_UI_Style := INI_UI_STYLE;
  end;

  if Globals.Active_UI_Style = UIS_Simple then
    ShowSimpleUIOpen;

  lblClientName.Caption := '';

  if Globals.ApplicationIsTerminating then
  begin
    frmMain.Constraints.MinHeight := 0; frmMain.Height := 0;
    frmMain.Constraints.MinWidth := 0; frmMain.Width := 0;
    Exit;
  end;

  //display correct graphic
  if Globals.Active_UI_Style = UIS_Simple then
  begin
    Self.Color := bkBranding.BKSIMPLEUI_FRAME_COLOR;
    //no branding logo
    //no background image
  end
  else
  begin
    Self.Color := bkBranding.MainFormBackgroundColor;

    bkBranding.StyleBooksBackgroundLogo(imgLogo);
    bkBranding.StyleBooksBackgroundImage(Image1);
    bkBranding.StyleBooksClientName(lblClientName);

    if TProduct.ProductBrand = btMYOBBankLink then
    begin
      Color := clWhite;
    end;
  end;

  AutoSaveInProgress  := False;
  AutoSaveOutstanding := False;
  SavedAutoSaveEnabled := False;
  SavedAutoSaveInterval := 0;
  SavedAutoSaveClient := '';

  //position version label correctly
  with lblVersion do
  begin
    Caption := ShortAppName + ' ' + WinUtils.GetAppYearVersionStr;
  end;

  bkBranding.StyleBooksVersionLabel(lblVersion);
    
  //form is about to be shown, get user details, use ini setting if specified
  if INI_Default_User_Code <> '' then
     UserNameToTry := INI_Default_User_Code
  else
     UserNameToTry := Copy(UpperCase(ReadUserName),1,8);

  if Globals.StartupParam_UserToLoginAs <> '' then
    UserNameToTry := Globals.StartupParam_UserToLoginAs;

  Self.Tag := 99999;  //set this to tell the yes no dialog to display screen center
                  //rather than main form

  if DebugMe then
    LogUtil.LogMsg(lmDebug,unitname,'Form Shown Step 1 - before Disable mainform');

  ApplicationUtils.DisableMainForm;
//  HelpfulInfoMsg('This version is for internal use only & is not to be distributed to clients under any circumstances.', 0);
  try
    // Make sure there are no Parameter actions set and the bconnect password has been set
    if (Globals.StartupParam_Action = 0) and
       (Assigned(AdminSystem)) and
       (AdminSystem.fdFields.fdBankLink_Connect_Password <> '') then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug,unitname,'Form Shown Step 2.1 - before TryGetandShowHTMLReminder');
      {This is commented out in version 5.29 since we implemented similar feature using contentful.
      TFS id : 89551}
      //UpgradeReminderMsg.TryGetandShowHTMLReminder;
    end;

    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,'Form Shown Step 2.2 - before LoginUser');

    //login user
    if not LoginUser( UserNameToTry ) then
    begin
       Application.Terminate;      //couldn't login user so exit
       Exit;
    end
    else
    begin
       //Self.Tag := 0; case 7071 - everything now goes screen center

       if Assigned(AdminSystem) then
       begin
         if AdminSystem.fdFields.fdUse_BankLink_Online then
         begin
           if not Assigned(ProductConfigService.Practice) then
           begin
             ProductConfigService.GetPractice(True);
           end;

           if ProductConfigService.OnLine and ProductConfigService.Registered then
           begin
             if TBlopiServiceAgreement.EnterServiceAgreement then
             begin
               try
                 if TBlopiServiceAgreement.NewVersionAvailable then
                 begin
                   // Suspend when new version is available and then on Resume when ok is clicked
                   ProductConfigService.SuspendService;

                   LogUtil.LogMsg(lmInfo, 'ServiceAgreementDlg', 'The ' + bkBranding.ProductOnlineName + ' service agreement version has changed. The ' + bkBranding.ProductOnlineName + ' service has been suspended until the new version is accepted.', 0);

                   if TBlopiServiceAgreement.SignServiceAgreement then
                   begin
                     ProductConfigService.ResumeService;

                     LogUtil.LogMsg(lmInfo, 'ServiceAgreementDlg', 'The ' + bkBranding.ProductOnlineName + ' service has been resumed.', 0);
                   end
                   else
                   begin
                     LogUtil.LogMsg(lmInfo, 'ServiceAgreementDlg', 'The ' + bkBranding.ProductOnlineName + ' service agreement has not been accepted. The service will remain suspended until the new service agreement is accepted.', 0);
                   end;
                 end;
               finally
                 TBlopiServiceAgreement.LeaveServiceAgreement;
               end;
             end;
           end;
         end;

///////// Start LeanEngage code
(* DN - Change #89926 Remove the check for Support Staff
        if ( AdminSystem.fdFields.fdBankLink_Code <>
                cLeanEngage_Support_Practice_Code ) // Make sure this is not on MYOB IT Support Practice Code
         then begin DN - Change #89926 Remove the check for Support Staff *)

         // Check that we have been able to reach LeanEngage
         if not PRACINI_Disable_LeanEngage then begin
           if DebugMe then
             LogUtil.LogMsg(lmDebug,unitname,
               format('Form Shown Step 2.3 - LeanEngage Reachable, Initialising - StartupParam_Action = %d, CurrUser.Code = %s',
               [ StartupParam_Action, CurrUser.Code ] ) );


         // Start the intialisation of this
           mniHelpProvideFeedback.Enabled := true; //User is notSupport and should be subscribed to LeanEngage
           if DebugMe then
             LogUtil.LogMsg(lmDebug,unitname,
               format('Form Shown Step 2.4 - before InitialiseLeanEngage - StartupParam_Action = %d, CurrUser.Code = %s',
               [ StartupParam_Action, CurrUser.Code ] ) );

           // Add LeanEngage functionality
           InitialiseLeanEngage;
           if not assigned( frmLEFeedback ) then begin  // The LeanEngage Symbol at the bottom right of the screen

             frmLEFeedback := TfrmLEFeedback.Create( frmMain );

             frmLEFeedback.InitialiseAndShowForm( frmMain, frmMain.ClientHeight,
               frmMain.ClientWidth);

             frmLEFeedback.imgIcon.OnClick := mniHelpProvideFeedbackClick;

             if GetClientManagerFormPointer <> nil then
               GetClientManagerFormPointer.LEFeedbackForm := TForm(frmLEFeedback);
           end;

           if DebugMe then
             LogUtil.LogMsg(lmDebug,unitname,
               format('Form Shown Step 2.5 - After InitialiseLeanEngage - StartupParam_Action = %d, CurrUser.Code = %s',
               [ StartupParam_Action, CurrUser.Code ] ) );
(* DN - Change #89926 Remove the check for Support Staff
         end  // End LeanEngage active
         else begin
           mniHelpProvideFeedback.Enabled := false; //User is Support and should not be subscribed to LeanEngage
         end; // End LeanEngage code
DN - Change #89926 Remove the check for Support Staff *)
/////////// End LeanEngage code
         end
         else begin
           mniHelpProvideFeedback.Enabled := false;

           if DebugMe then
             LogUtil.LogMsg(lmDebug,unitname,
               format('Form Shown Step 2.3 - LeaneEngage Unreachable - StartupParam_Action = %d, CurrUser.Code = %s',
               [ StartupParam_Action, CurrUser.Code ] ) );
         end;
       end;

       ReloadCustomLogo;

       Image1Top := Image1.Top;
       Image1Left := Image1.Left;
       Image1Width := Image1.Width;
       Image1Height := Image1.Height;

       RepositionLogos( Self);

       DisplayMRU;
       UpdateSystemMenus;         //set system menus dependant on access level
       UpdateMenus;

       if (ParamCount = 1) and (ParamStr(1) = '/TestCode') then
       begin
         if EnterRandomPassword('TestCode') then
           mnsTest.Visible := true;
       end;

       if mnsTest.Visible then
         ShowMessage( 'Test Menu Item Available');

  {$IFDEF BK5_TESTLOCKING}
       ShowMessage( 'BK5_TESTLOCKING Defined');
       mnsTest.Visible := true;
       mniTestAdminLocking.Visible := true;
  {$ENDIF}
  //     tbarFile.Visible := True;  //turn on toolbar

  {$IFDEF CSVImport}
       mniImportfromCSV.Visible := Globals.PRACINI_AllowCSVImport;
  {$ELSE}
       mniImportfromCSV.Visible := false;
  {$ENDIF}

       rztFile.Visible := true;

       SetToolbarCaptionState(INI_ShowToolbarCaptions );

       if (not PRACINI_ExportReports) then
       begin
         //hide the export report options
         mniCFExportSeperator.Visible := False;
         mniCFExport.Visible := False;
         mniPRExportSeperator.Visible := False;
         mniPRExport.Visible := False;
         mniBalanceExportSeperator.Visible := False;
         mniBalanceExport.Visible := False;
       end;

       SetExportdatatoBanklinkOnlineVisiblility();

       //test to see if the log file should be archived
       SysLog.MinSize  := PRACINI_MinLogFileSize * 1000; //convert KB to Bytes
       SysLog.MaxSize  := PRACINI_MaxLogFileSize * 1000;
       ArchiveLogNeeded := SysLog.ArchiveNeeded;
       if Trim( PRACINI_LogBackupDir) <> '' then begin
          LogBackupDir := GenUtils.AddSlash( PRACINI_LogBackupDir);
       end
       else
          LogBackupDir := Globals.LogFileBackupDir;

       if FAdminSystemFound then begin
          //count no of users so can do single user operations
          NumUsersLoggedIn := 0;
          with AdminSystem.fdSystem_User_List do begin
             for i := 0 to Pred( ItemCount) do begin
                if User_At( i).usLogged_In then
                   Inc( NumUsersLoggedIn);
             end;
          end;
       end
       else begin
          NumUsersLoggedIn := 1;
       end;

       if FAdminSystemFound then begin
          //compress the log file
          //can be turned off in BK5PRAC.INI
          //   [Environment]
          //   MaxLogFileSizeK=0
          if ( NumUsersLoggedIn = 1) and ( ArchiveLogNeeded) then begin
             if Admin32.LoadAdminSystem( true, 'Archive Log') then begin
                try
                   //Note: Application Process Messages will be called during this procedure
                   ArchiveLogFile( LogBackupDir);
                finally
                   Admin32.UnlockAdmin;
                end;
             end;
          end;
          //validate the admin system and transaction archive if selected.
          //can be turned off in BK5PRAC.INI
          //   [Environment]
          //   ValidateArchiveDownloadOnly=1
          if ( not PRACINI_ValidateArchiveDownloadOnly) and PRACINI_ValidateArchive then begin
             //if we are the only user logged in then test archive
             if NumUsersLoggedIn = 1 then
             begin
                //Note: Application Process Messages will be called during this procedure
                ArchiveCheck.CheckArchiveDirSynchronised;
             end;
          end;

       end
       else begin
          //no admin system
          if ArchiveLogNeeded then
             ArchiveLogFile( LogBackupDir);

       end;
    end;

   ResetAutoSave;

{$IFDEF SmartLink}
   if Assigned( CurrUser) then
     ShowSmartLinkHelp := not CurrUser.HasRestrictedAccess
   else
     ShowSmartLinkHelp := false;

   mniTutorialsTOC.Visible := False;

   mniBKHelp.Caption := AppTitle + ' &Help';
   mniBKHelp.Visible := ShowSmartLinkHelp;

   tbCodingHelp.Visible := ShowSmartLinkHelp;
   tbCodingHelpSep.Visible := tbCodingHelp.Visible;

   tbBudgetHelp.Visible := ShowSmartLinkHelp;
   tbBudgetHelpSep.Visible := tbBudget.Visible;

   N4.Visible := not( mniTutorialsTOC.Visible and mniHelpAbout.Visible);
{$ENDIF}
  finally
    ApplicationUtils.EnableMainForm;
  end;

  if Assigned( CurrUser) then
  begin
    if ( Globals.DDE_Macro_To_Process <> '') then
      ProcessDDEMacro( Globals.DDE_Macro_To_Process)
    else
    if ( Globals.StartupParam_ClientToOpen <> '') or
       (( CurrUser.ShowCMOnOpen or GLOBALS.SuperUserLoggedIn) and ( actClientManager.Visible)) then
    begin
      frmMain.Enabled := False;
      tmProcessStartupCmds.Enabled := true;
    end;
  end;
  if FAdminSystemFound then
    tmrReportRun.Enabled := true;

  //allow DDE commands to be processed
  ApplicationIsStarting := false;
  mniPromos.Enabled := (DisplayPromoContents.Count > 0);
  if DebugMe then
    LogUtil.LogMsg(lmDebug,unitname,'Form Show Finished');
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RepositionLogos( Sender : TObject);
var
  AreaHeight : Integer;
  MaxLogoHeight : Integer;
begin
  with imgLogo do
  begin
  {$ifdef DELPHI7}
    Top := rzToolbars.Height + 2;
  {$else}
    Top := 16;
  {$endif}
    if TProduct.ProductBrand = btMYOBBankLink then
    begin
      Top := rzToolbars.Height + 2;
      Left := 10;
    end
    else
    begin
      Left := 0;
    end;
  end;

  if imgPracticeLogo.Visible then
  begin
    //position practice logo
    with imgPracticeLogo do
    begin
      if TProduct.ProductBrand = btMYOBBankLink then
      begin
        Top := imgLogo.Top;
      end
      else
      begin
        Top := imgLogo.Top + lblVersion.Height;
      end;
      
      Left := TForm(Sender).ClientWidth - (imgPracticeLogo.Width + GetSystemMetrics( SM_CXVSCROLL ) + 8);
    end;

    //if the logos overlap then make sure that the practice logo is visible
    imgLogo.Visible := ( imgLogo.Left + imgLogo.Width) < imgPracticeLogo.Left;
    if imgLogo.Visible then
      MaxLogoHeight := Max( imgLogo.Height, imgPracticeLogo.Height)
    else
      MaxLogoHeight := imgPracticeLogo.Height;
  end
  else
    MaxLogoHeight := imgLogo.Height;

  with lblClientName do
  begin
    Top := (imgLogo.Top + MaxLogoHeight + 20);
    Left := 0;
    Width := TForm(Sender).Width;
  end;

  with lblVersion do
  begin
{$ifdef DELPHI7}
    Top := imgLogo.Top + 2;
{$else}
    Top := imgLogo.Top - (lblVersion.Height + 2);
{$endif}
   if TProduct.ProductBrand = btMYOBBankLink then
   begin
     if imgPracticeLogo.Visible then
     begin
       Visible := False;
     end
     else
     begin
       Top := imgLogo.Top;
     end;
   end;
   
   Left := TForm(Sender).ClientWidth - (lblVersion.Width + GetSystemMetrics( SM_CXVSCROLL ) + 8);
  end;

  if not bkBranding.Is256Color then
  begin
    AreaHeight := (TForm(Sender).ClientHeight - rzToolbars.Top -  rzToolbars.Height
                                              - MainStatus.Height
                                              - lblClientName.Top - lblClientName.Height);

    if (TForm(Sender).Width >= (Image1.Width + 16)) and (AreaHeight >= (Image1.Height + 16)) then
    begin
      with Image1 do
      begin
        Image1Top := lblClientName.Top + lblClientName.Height + 8 + trunc(((AreaHeight - Image1.Height) / 3));
        Image1Left := ((TForm(Sender).ClientWidth - Image1.Width) div 2);
        Image1Width := Image1.Width;
        Image1Height := Image1.Height;
      end;
    end else
    begin
      if (TForm(Sender).ClientWidth >= (Image1Width + 16)) then
        Image1Left := ((TForm(Sender).ClientWidth - Image1Width) div 2)
      else
        Image1Left := 8;

      if (AreaHeight > (Image1Height + 16)) then
        Image1Top := lblClientName.Top + lblClientName.Height + 8 +
          ((AreaHeight - Image1Height) div 2)
      else
        Image1Top := (lblClientName.Top + lblClientName.Height + 8);
    end;

    Image1.SetBounds(Image1Left,Image1Top,Image1Width,Image1Height   );

  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormResize(Sender: TObject);
(*
var
  ClientManagerFormPointer : TfrmClientManager; *)
begin
  inherited;
 if not ApplicationIsStarting then
   case WindowState of
      wsNormal: begin
         INI_mfStatus := 1; // Normal
         //save position and size
         INI_mfTop := Top;
         INI_mfLeft := Left;
         INI_mfWidth := Width;
         INI_mfHeight := Height;
      end;
      wsMinimized:
         INI_mfStatus := 2;  {useless: this value is never set by VCL!!}
      wsMaximized:
         INI_mfStatus := 3;
   end;

  if Globals.ApplicationIsTerminating then
    Exit;

  //see if anything changed...
  if not (( Self.Top <> Self.LastMFTop) or
     ( Self.Left <> Self.LastMFLeft) or
     ( Self.Width <> Self.LastMFWidth) or
     ( Self.Height <> Self.LastMFHeight)) then
    Exit;

  RepositionLogos( Sender);
  Invalidate;
  ArrangeIcons; // keep minimized mdi icons in view
  MainStatus.Panels[PANELMSG].Width := Width - (MainStatus.Panels[PANELF1].width +
                                       MainStatus.Panels[PANELTIME].width +
                                       MainStatus.Panels[PANELBAR].width );
  if assigned( frmLEFeedback ) then begin
(*    ClientManagerFormPointer := GetClientManagerFormPointer; *)
    frmLEFeedback.FloatForm( (*ClientManagerFormPointer.*)frmMain.ClientHeight, (*ClientManagerFormPointer.*)frmMain.ClientWidth );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
const
   ThisMethodName = 'TfrmMain.FormClose';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Globals.ApplicationIsTerminating then
   begin
     //Update window state into INI values
     case WindowState of
        wsNormal: begin
           INI_mfStatus := 1; // Normal
           //save position and size
           INI_mfTop := Top;
           INI_mfLeft := Left;
           INI_mfWidth := Width;
           INI_mfHeight := Height;
        end;
        wsMinimized:                                                                       
           INI_mfStatus := 2;  {useless: this value is never set by VCL!!}
        wsMaximized:
           INI_mfStatus := 3;
     end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );

   if Assigned(Globals.AdminSystem) then
     Application.ProcessMessages; // Prevents critical application error, see bug 51395 in TFS
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (AutoSaveInProgress) then
    CanClose := False
  else
    ExitBankLink;  {perform all necessary app shutdown tasks}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil( fMDIChildSortedList);
  FreeAndNil( AdminSystem);
  FreeAndNil( GlobalAdminSnapshot);

  //remove redirect of messge handler to ClientWndProc
  SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FPrevClientProc));
  Classes.FreeObjectInstance(FClientInstance);

  //Free LeanEngage artefacts
  FreeAndNil( frmLEFeedback );
  FreeAndNil( NPSLeanEngage );
  FreeAndNil( FOnToolBarResize );
end;
procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AddMenuItem( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );
// Add the Source TMenuItem to the Dest
var
   m : TMenuItem;
begin
   m := TMenuItem.Create( OwnerMenu );
   with Source do begin
      m.Caption := Caption;
      m.Hint    := Hint;
      m.OnClick := OnClick;
      m.Visible := Visible;
      m.Enabled := Enabled;
      m.ImageIndex := ImageIndex;
      Dest.Add( m );
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AddMenuItems( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );
// Adds all the Menu Items and Sub Items in the Source to the Dest
var
   i : Integer;
begin
  with Source do begin
    for i := 0 to Pred( Count ) do begin
      AddMenuItem( OwnerMenu, Source.Items[i], Dest );
      // Call this routine recusively to handle Sub Items
      AddMenuItems( OwnerMenu, Source.Items[i], Dest.Items[i] );
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Adds all the Menu Items and Sub Items in the Source to the Dest
//
procedure TfrmMain.AssignMenuItems( OwnerMenu : TPopUpMenu; Source : TMenuItem; Dest : TMenuItem );
var
   i : Integer;
begin
  with Source do begin
    for i := 0 to Pred( Count ) do begin
      //AddMenuItem( OwnerMenu, Source.Items[i], Dest );
      //Dest.Assign(Source.Items[i]);
      Dest.Items[i].Caption := Source.Items[i].Caption;
      Dest.Items[i].Hint    := Source.Items[i].Hint;
      Dest.Items[i].OnClick := Source.Items[i].OnClick;
      Dest.Items[i].Visible := Source.Items[i].Visible;
      Dest.Items[i].Enabled := Source.Items[i].Enabled;

      // Call this routine recusively to handle Sub Items
      AssignMenuItems( OwnerMenu, Source.Items[i], Dest.Items[i] );
    end;
  end;
end;


procedure TfrmMain.AUDITREPORTTEST1Click(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.MenuCopyToPopUp( Option : String; MPopUp : TPopUpMenu );
// Copies all the Menu Options under the named Main Menu option to the
// named PopUp
var
  i{,j} : Integer;
//  MenuItem : TMenuItem;
begin

   i := 0;
   while ( i <  MainMenu.Items.Count ) do begin
      if MainMenu.Items[i].Name = Option then
         Break;
      Inc( i );
   end;
   if not ( MainMenu.Items[i].Name = Option ) then
      Exit;
   //Empty the PopUp
   MPopUp.Items.Clear;
   {
   with MPopUp do begin
     for j := 0 to Pred( Items.Count ) do
     begin
       MenuItem := Items[ Pred( Items.Count ) ];
       Items.Remove( Items[ Pred( Items.Count ) ] );
       FreeAndNil(MenuItem);
     end;
   end;
   }
   // Add all the TMenuItems under the selected option
   AddMenuItems( MPopUp, MainMenu.Items[i], MPopUp.Items );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Assigns all the Menu Options under the named Main Menu option to the
// named PopUp
//
(*
procedure TfrmMain.MenuAssignToPopUp( Option : String; MPopUp : TPopUpMenu );
var
  i : Integer;
begin
  i := 0;
  while ( i <  MainMenu.Items.Count ) do begin
    if MainMenu.Items[i].Name = Option then
      Break;
    Inc( i );
  end;
  if not ( MainMenu.Items[i].Name = Option ) then
    Exit;
  //Assign all the TMenuItems under the selected option
  AssignMenuItems(MPopUp, MainMenu.Items[i], MPopUp.Items);
end;
*)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tmClockTimer(Sender: TObject);
begin
  MainStatus.Panels[PANELTIME].Text := '  '+DateToStr(Now)+'   '+TimeToStr(Now)+'  ';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ExitBankLink;
begin
  Globals.ApplicationIsTerminating := True;
  Screen.OnActiveFormChange := nil;
  CloseSimpleUIOpen(False);
  DoMainFormCommand(mf_mcCloseFile);
  CloseClientManager(False);
  LogoutUser;
end;

procedure TfrmMain.ExportTaggedAccounts(ProgressForm: IDualProgressForm; CallbackParams: Pointer);
var
  ExportOptions: TExportOptions;
  ExportStatistics: TExportStatistics;
  ExportError: Boolean;
  ErrorDetails: TFatalErrorDetails;
begin
  ExportOptions.MaxTransactionDate := CurrentDate;
  ExportOptions.ExportChartOfAccounts := not StartupParam_ExcludeCOA;

  try
    TBankLinkOnlineTaggingServices.ExportTaggedAccounts(ProductConfigService.CachedPractice, ExportOptions, ProgressForm, ExportStatistics, ExportError, ErrorDetails);
  except
    on E:Exception do
    begin
      LogUtil.LogMsg(lmError, 'ExportTaggedAccounts', 'The following error occurred while exporting transactions to BankLink Online: ' + E.Message);
    end;
  end;
end;

procedure TfrmMain.ExportTransactionsToBankLinkOnline;
var
  ProgressData: TProgressData;
begin
  if CurrUser.CanAccessAdmin and ProductConfigService.OnLine and ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False) then
  begin
    ProductConfigService.LoadClientList;
    
    TfrmModalDualProgress.ShowProgress(Self, 'Please wait...', 'Exporting Client Transactions', ExportTaggedAccounts, ProgressData);

    if ProgressData.ExceptionRaised then
    begin
      LogUtil.LogMsg(lmError, UnitName, 'Exception exporting account transactions, Error Message : ' + ProgressData.Exception.Message);
    end;
  end
  else
  if not CurrUser.AllowBanklinkOnline then
  begin
    LogUtil.LogMsg(lmError, 'ExportTransactionsToBankLinkOnline', 'Export transactions to BankLink Online could be be performed because the current user is not enabled for BankLink Online.');
  end
  else
  if not CurrUser.CanAccessAdmin then
  begin
    LogUtil.LogMsg(lmError, 'ExportTransactionsToBankLinkOnline', 'Export transactions to BankLink Online could be be performed because the current user does not have system level access.');
  end
  else
  if not ProductConfigService.OnLine then
  begin
    LogUtil.LogMsg(lmError, 'ExportTransactionsToBankLinkOnline', 'Export transactions to BankLink Online could be be performed because BankLink Online is not enabled.');
  end
  else
  if not ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False) then
  begin
    LogUtil.LogMsg(lmError, 'ExportTransactionsToBankLinkOnline', 'Export transactions to BankLink Online could be be performed because the Export Data product is not enabled for this Practice.');
  end;
end;

procedure TfrmMain.mniBulkClearTransferFlagsClick(Sender: TObject);
begin
   DoMainFormCommand(mf_DoBulkClear);
end;

procedure TfrmMain.mniBulkExportDataClick(Sender: TObject);
begin
    DoMainFormCommand(mf_DoBulkExtract);
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.OnAppIdle(Sender: TObject; var Done: Boolean);
begin
//
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RunGSTReport(Value: REPORT_LIST_TYPE);

var lParams: TRptParameters;
begin
   lParams := TRptParameters.Create(Ord (Value),MyClient,nil);
   try
      case Value of
           Report_GST101,
           Report_BAS :

              case MyClient.clFields.clCountry of
                whNewZealand :
                  begin
                    lParams.ReportType := Ord(Report_GST101);
                    ShowGST101Form(0,0,lParams);
                  end;
                whAustralia  :
                  begin
                    lParams.ReportType := Ord(Report_BAS);
                    ShowBasForm(0,0,LParams);
                  end;
                whUK :
                  begin
                    lParams.ReportType := Ord(Report_VAT);
                    ShowVATReturn( 0, 0, LParams );
                  end;
              end;


           REPORT_BASSUMMARY : case MyClient.clFields.clCountry of
                             whAustralia  : ShowAnnualGSTInformationReport(lParams);
                         end;
           Report_GST372 : case MyClient.clFields.clCountry of
                             whAustralia  : ShowAnnualGSTReturn(lParams);
                         end;
      end;
      incUsage(lparams.UsageTitle(rdScreen));      
   finally
      lParams.Free;
   end;
end;

procedure TfrmMain.DisplayAvailableNPSSurveys(Sender: TObject);
var
  i : integer;
begin
  if assigned( NPSLeanEngage ) and
       assigned( Application ) and
       assigned( Application.MainForm ) and
       (AdminSystem.fdFields.fdBankLink_Code <> // DN - Change #89926 Remove the check for Support Staff but force to test API site
          cLeanEngage_Support_Practice_Code )  then
    if NPSLeanEngage.HasSurvey then
      for I := 0 to NPSLeanEngage.Surveys.Count - 1 do begin
        if DebugMe then
          LogUtil.LogMsg(lmDebug,unitname,
            format( 'TfrmWebHost.Show( NPSLeanEngage.Surveys[ i ].Url = %s, Application.MainForm)',
            [ NPSLeanEngage.Surveys[ i ].Url ] ) );
        TfrmWebHost.Show( NPSLeanEngage.Surveys[ i ].Url );
      end;
end;

procedure TfrmMain.DisplayHint(Sender: TObject);
begin
  MainStatus.Panels[PANELMSG].Text := GetLongHint(Application.Hint);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.OnUnhandledError( Sender:TObject; E:Exception);
begin
   ExceptH.UnHandledError(Sender,E);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.OnActive(Sender:TObject);
begin
   {repaint mdi child forms}
   SendCmdToAllCodingWindows( ecRefreshTable);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.FormActivate(Sender: TObject);
begin
  if Assigned(myClient) then
    lblClientName.Caption := MyClient.clExtendedName
  else
    lblClientName.Caption := 'No Client Selected';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RedrawClientName;
//invalidates the background and forces a repaint
//called from UpdateMF.UpdateName
var
   cRect : TRect;
begin
  //invalidate the client name label to force a repaint
  CRect := lblClientName.BoundsRect;
  InvalidateRect(ClientHandle,@CRect,true);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.SetToolBarCaptionState( CaptionOn: boolean);
begin
   //Get and Send buttons need minimum width to display the caption correctly
   tbGetClientFiles.Constraints.MinWidth := 0;
   tbSendClientFiles.Constraints.MinWidth := 0;
   tbRecommendedMemorisations.Constraints.MinWidth := 0;
   if CaptionOn then begin
     tbRecommendedMemorisations.Constraints.MinWidth := 134; 
     tbGetClientFiles.Constraints.MinWidth := 145;
     tbSendClientFiles.Constraints.MinWidth := 145;
   end;
   //resize all of the buttons and turn captions on if needed
   SetCaptionState( rztFile, CaptionOn);
   SetCaptionState( rztClient, CaptionOn);
   SetCaptionState( rztCoding, CaptionOn);
   SetCaptionState( rztBudget, CaptionOn);
   bkArrangeToolBars;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ShowExportTransactionsDialog;
begin
  TfrmTransactionsToBankLinkOnline.ShowDialog(Self, Self);
end;

procedure TfrmMain.SetCaptionState( TBar: TRzToolbar; CaptionOn: boolean);
var
  pS : PChar;
  TextExt : TSize;
  i : Integer;
  BarWidth : integer;

begin
  BarWidth := 0;

  with TBar do begin
    Tbar.AutoSize := false;
    for i := 0 to Pred( ControlCount ) do
    begin
       if Controls[i] is TRzToolButton then
       begin
          with TRzToolButton( Controls[i] ) do
          begin
             UseToolbarButtonSize := false;

             if CaptionOn then
             begin
                //find the width of the text
                pS := PChar(Caption);


                GetTextExtentPoint32( TMyPanel(rzToolbars).Canvas.Handle, pS, Length(pS), TextExt );
                if Assigned(DropDownMenu)then
                begin
                    Width := ToolBarButtonWithTextWidth +
                       ToolbarButtonDropArrowWidth + TextExt.CX;
                end
                else
                begin
                    Width := ToolBarButtonWithTextWidth + TextExt.CX + 4;
                end;
             end
             else
             begin
               if Assigned(DropDownMenu)then
                 Width := ToolBarButtonGlyphOnlyWidth + ToolbarButtonDropArrowWidth
               else
                 Width := ToolBarButtonGlyphOnlyWidth;
             end;
             ShowCaption := CaptionOn;
          end;
       end;

       BarWidth := BarWidth + Controls[i].Width;
    end;
    Tbar.Width := BarWidth;
  end;
end;

procedure TfrmMain.SetExportdatatoBanklinkOnlineVisiblility();
begin
  mniExportdatatoBanklinkOnline.Visible := ProductConfigService.ServiceActive and
                                           CurrUser.CanAccessAdmin and
                                           CurrUser.AllowBanklinkOnline and
                                           ProductConfigService.OnLine and
                                           ProductConfigService.IsPracticeProductEnabled(ProductConfigService.GetExportDataId, False) and
                                           DATA_EXPORT_MENU_ITEM_ENABLED;
end;

procedure TfrmMain.SetLastActiveMDIChild(const Value: Forms.TForm);
begin
  FLastActiveMDIChild := Value;
end;

procedure TfrmMain.SettheTransferFlagsforaPeriod1Click(Sender: TObject);
begin
    DoMainFormCommand( mf_mcSetTransferFlags);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ResetToolbarSize( TBar : TRzToolbar);
var
  BarWidth : integer;
  i : integer;
begin
  BarWidth := 0;

  TBar.AutoSize := false;
  for i := 0 to Pred( TBar.ControlCount) do
  begin
    if TBar.Controls[i].Visible then
      BarWidth := BarWidth + TBar.Controls[i].Width;
  end;

  Tbar.Width := BarWidth + 2 + TBar.Margin;
  TBar.Height := TBar.ButtonHeight + Tbar.TopMargin + 2;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tbarVisibleChanged(Sender: TObject);
begin
   bkArrangeToolBars;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.bkArrangeToolBars;
// Sets the Positions of all Toolbars on the Top Dock
// ToolBar Tags are set 0,1,2,3 in left to right order

   procedure PositionToolbar( tbar : TRzToolbar; var PrevBar : TRzToolbar; var TotalHeight : integer);
   begin
     //reset to full length
     ResetToolbarSize( tBar);

     //see if can file client toolbar on same line
     if ( PrevBar.Left + PrevBar.Width + Tbar.Width) < Self.ClientWidth then
     begin
       tBar.Top := PrevBar.Top;
       tBar.Left := PrevBar.Left + PrevBar.Width + 1;
     end
     else
     begin
       tBar.Left := 1;
       tBar.Top := PrevBar.Top + PrevBar.Height;

       if tBar.WrapControls then
       begin
        if tBar.Width > Self.ClientWidth then
        begin
          tBar.Height := (tBar.RowHeight * 2) + Tbar.TopMargin + 2;
          tBar.Width := Self.ClientWidth - 2;
        end;
       end;
     end;

     if tBar.Top <> prevBar.Top then
       TotalHeight := TotalHeight + tBar.Height + 2;

     PrevBar := TBar;
   end;

var
  PanelHeight : integer;
  PrevToolbar : TRzToolbar;
begin
  rzToolBars.OnResize := nil;
  try
    //file toolbar is always positioned top left
    rztFile.Left := 1;
    rztFile.Top := 2;
    ResetToolbarSize( rztFile);

    PrevToolbar := rztFile;
    PanelHeight := rztFile.Top + rztFile.Height + 1;

    if rztClient.Visible then
    begin
      PositionToolbar( rztClient, PrevToolbar, PanelHeight);

      if ( rztCoding.Visible) then
        PositionToolbar( rztCoding, PrevToolbar, PanelHeight);

      if ( rztBudget.Visible) then
        PositionToolbar( rztBudget, PrevToolbar, PanelHeight);
    end;
    rzToolbars.Height := PanelHeight + 2;

    FOnToolBarResize.DoEvent();
  finally
    rzToolBars.OnResize := rzToolBarsResize;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoBudgetTBarCommand(command: TExternalCmdBudget);
begin
  if ActiveMDIChild is TfrmBudget then
    TfrmBudget(ActiveMDIChild).ProcessExternalCmd( command);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoCodingTBarCommand(command: TExternalCmd);
begin
  if ActiveMDIChild is TfrmCoding then
    TfrmCoding(ActiveMDIChild).ProcessExternalCmd(command);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// MENU AND TOOLBAR CLICKS
// MENU AND TOOLBAR CLICKS
// MENU AND TOOLBAR CLICKS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
procedure TfrmMain.mniHelpAboutClick(Sender: TObject);
begin
    frmAbout := TfrmAbout.Create(Self);
    frmAbout.ShowModal;
    frmAbout.Free;
end;
procedure TfrmMain.mniHelpProvideFeedbackClick(Sender: TObject);
begin
  if assigned( NPSLeanEngage ) then begin
    if NPSLeanEngage.HasFeedbackURL then begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug,unitname,
          format( 'TfrmWebHost.Show( NPSLeanEngage.FeedbackURL = %s, Self)',
          [ NPSLeanEngage.FeedbackURL ] ) );
      TfrmWebHost.Show( NPSLeanEngage.FeedbackURL );
    end
    else begin // Try again, something went wrong
      TfrmWebHost.Show( 'http://localhost/' );
  	end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileNewClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcNewFile);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileOpenClick(Sender: TObject);
var
  AdminAccess : Boolean;
begin
  StopAutoSaveTimer;
  if Assigned(CurrUser) then
    AdminAccess := (not CurrUser.HasRestrictedAccess) and Assigned(AdminSystem)
  else
    AdminAccess := Assigned(AdminSystem);
  if AdminAccess then
    actClientManagerExecute(Sender)
  else
    DoMainFormCommand( mf_mcOpenFile);
  RestartAutoSaveTimer;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.MRUStartClick(Sender: TObject);
begin
  StopAutoSaveTimer;
  DoMainFormCommand( mf_mcOpenFromMRU, Sender);
  RestartAutoSaveTimer;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileSaveClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSave);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileSaveAsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSaveAs);
  RefreshHomepage([HPR_Client]);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileCloseClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcCloseFile);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileAbandonChangesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcAbandon);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileInformationClick(Sender: TObject);
begin
   ShowClientProperties;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFilePreferenceClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSystemOptions);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileCheckInClick(Sender: TObject);
begin

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.mniSendClientFilesClick(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileExitClick(Sender: TObject);
begin
  Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniDECodeEntriesClick(Sender: TObject);
begin
  incUsage('Do Coding');
  DoMainFormCommand( mf_mcCoding);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniWindowCascadeClick(Sender: TObject);
begin
   incUsage('Cascade');
   Cascade;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniWindowTileClick(Sender: TObject);
begin
   incUsage('Tile');
   TileMode := tbHorizontal;
   Tile;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tbtPrevClick(Sender: TObject);
begin
   Next;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tbtNextClick(Sender: TObject);
begin
   Previous;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoClientDetails(PopupParent: Forms.TForm; ViewNotes : Boolean = False);
var
  OldFinYear : integer;
begin
  OldFinYear := MyClient.clFields.clFinancial_Year_Starts;
  if EditClientDetails(PopupParent, ViewNotes) then begin
    UpdateName;
    // Invalidate, Repaint, Refresh, Update do not work here. No idea why!!?? so this is a hack to force a repaint...
    lblClientName.Top := lblClientName.Top - 1;
    lblClientName.Top := lblClientName.Top + 1;

    //now test to see if a rollover is required, dont ask if dates didnt change
    //or if this is the first time we have set the fin year starts date
    if (Active_UI_Style <> UIS_Simple) and ( OldFinYear > 0) and
       ( MyClient.clFields.clFinancial_Year_Starts > OldFinYear) then
    begin
      //the year end balances routine should now be availalbe because the financial year start has been moved
      //forward, only prompt however if opening balances exist
      if JnlUtils32.CheckForOpeningBalance( MyClient,
                                                 MyClient.clFields.clLast_Financial_Year_Start) then
      begin
        //prompt the user to do move the balance forward now
        if YesNoDlg.AskYesNo( 'Enter Year End Balances',
                              'You have moved the Financial Year Starts date forward. ' +
                              'Do you want to enter your Year End Balances at this time?',
                              DLG_YES, 0) = DLG_YES then
        begin
          RunBalancesForwardWizard( MyClient);
        end;
      end;

    end;
    if ( OldFinYear <> MyClient.clFields.clFinancial_Year_Starts) then
    begin
      //update the following when fin year is changed
      INI_DontShowMe_NoOpeningBalances := False;
      MyClient.clFields.clReporting_Year_Starts := MyClient.clFields.clFinancial_Year_Starts;
    end;
    UpdateMenus;
  end;

  RefreshHomepage([HPR_Files]);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFClientDetailsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcClientDetails);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSetupDivisionsClick(Sender: TObject);
begin
  IncUsage('Divisions');
  DoMainFormCommand( mf_mcEditDivisions);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSetupSubgroupsClick(Sender: TObject);
begin
  IncUsage('Sub Groups');
  DoMainFormCommand( mf_mcEditSubgroups);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniExportCharttoMYOBCashBooks1Click(Sender: TObject);
begin
  DoMainFormCommand( mf_mcExportChartToMYOBEssentialsCashbook);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMaintainChart;
begin
   //will return true if ApplyGSTDefaults need to be called
   if MaintainChart(False, BKH_Entering_a_chart_directly_into_BankLink) then begin
      ApplyDefaultGST( false);
      SendCmdToAllCodingWindows( ecRecodeTrans);
   end;
   UpdateMenus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniMaintainChartClick(Sender: TObject);
begin
  IncUsage('Maintain Chart');
  DoMainFormCommand( mf_mcMaintainChart);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniMaintainFileCostCodesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcMaintainFileCostCodes);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoAccountingSystem;
var
  AutoRefreshDone : Boolean;
begin
   EditAccountingSystem(Self, AutoRefreshDone, BKH_Direct_link_to_the_main_accounting_system);
   SendCmdToAllCodingWindows( ecRecodeTrans);
   SendCmdToAllCodingWindows( ecUpdatePopups);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFAccountingSystemClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcAccountingSystem);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoEditGSTDetails;
begin
   EditGstDetails(BKH_Set_up_GST);
   SendCmdToAllCodingWindows( ecRefreshTable);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFGSTDetailsandRatesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcGSTDetails);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoGSTReturn;
begin
   if not Assigned( myClient) then exit;
   RunGSTReport (Report_GST101);
   //may have locked accounting period so update any coding windows
   SendCmdToAllCodingWindows( ecRecodeTrans);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGSTReturnClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcGSTReturn);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSetupExceptionCriteriaClick(Sender: TObject);
begin
   SetExceptionCriteria;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFPayeesClick(Sender: TObject);
begin
  IncUsage('Payees');
  DoMainFormCommand( mf_mcMaintainPayees);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mnsOFChartofAccountsClick(Sender: TObject);
begin
   //
end;
procedure TfrmMain.mnsReportClick(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.MaintainMems;
begin
   if MaintainMemorised then
      SendCmdToAllCodingWindows( ecRecodeTrans);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFMemorisedEntriesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcMaintainMems);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniDECashJournalsClick(Sender: TObject);
begin
  IncUsage('Cash Journals');
  DoMainFormCommand( mf_mcCashJournals);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniDEAccrualJournalsClick(Sender: TObject);
begin
   IncUsage('Accrual Journals');
   DoMainFormCommand( mf_mcAccrualJournals);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniDEEnterBudgetsClick(Sender: TObject);
begin
  IncUsage('Budgets');
  DoMainFormCommand( mf_mcBudgets);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemPracticeDetailsClick(Sender: TObject);
var
  LastDiskNum: Integer;
begin
   LastDiskNum := AdminSystem.fdFields.fdDisk_Sequence_No;
   tmrDataThread.Enabled := False;
   try
     EditPracticeDetails(Self);

     if Assigned( MyClient) then
       Merge32.SyncClientToAdmin( MyClient, false, false);

     ReloadCustomLogo;
     UpdateClientManagerCaption(AdminSystem.fdFields.fdPractice_Name_for_Reports);
     FormResize( Self);
     RedrawFormBackground;

     if UseBankLinkOnline then
     begin
       SetExportdatatoBanklinkOnlineVisiblility();
     end
     else
     begin
       mniExportdatatoBanklinkOnline.Visible := False;
     end;
   finally
     if LastDiskNum <> AdminSystem.fdFields.fdDisk_Sequence_No then
       // recheck status immediately if disk seq changed
       tmrDataThread.Interval := 1;
       tmrDataThread.Enabled := True;
   end;
end;
procedure TfrmMain.mniSystemReportsClick(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemUsersClick(Sender: TObject);
begin
  MaintainUsers(Self);

  RefreshUserControls;

  RefreshClientManager;
  if Assigned( MyClient) then
    Merge32.SyncClientToAdmin( MyClient, false, false);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemGroupsClick(Sender: TObject);
begin
  IncUsage('Client Groups');
  MaintainGroups;
  RefreshClientManager;
  if Assigned( MyClient) then
    Merge32.SyncClientToAdmin( MyClient, false, false);
end;

procedure TfrmMain.mniSystemGSTDefaultsClick(Sender: TObject);
begin
   EditPracticeGSTDetails;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemTranTypesClick(Sender: TObject);
begin
   EditTransactionTypes;

  if Assigned( MyClient) then
    Merge32.SyncClientToAdmin( MyClient, false, false);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMaintainBankAccounts;
begin
  if MaintainBankAccounts(BKH_Bank_Accounts1) then
    //recode in case master memorisations flag has been changed
    SendCmdToAllCodingWindows( ecRecodeTrans);

  if Assigned( MyClient) then begin
     Merge32.SyncClientToAdmin( MyClient, false, false);
     RefreshHomepage([HPR_Files]);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFBankAccountsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcMaintainBankAccounts);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemNewAccountsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSys_AttachAccounts);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemBankLinkConnectClick(Sender: TObject);
begin
  tmrDataThread.Enabled := False;
  try
    ProcessModalCmdWithDlg( mpcDoDownloadFromBConnect);
    {$B-}
    if assigned(ActiveMDIChild)
    and (ActiveMDIChild is TfrmClientManager) then begin
       RefreshHomepage([HPR_Client]);
    end else begin
       RefreshClientManager;
       RefreshHomepage([HPR_Client]);
    end;


  finally
    // recheck status immediately after bconnect has been run
    {tmrDataThread.Interval := 1;}
    tmrDataThread.Enabled := True;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSystemDownloadfromFloppyClick(Sender: TObject);
begin
  ProcessModalCmdWithDlg( mpcDoDownloadFromFloppy);
  RefreshClientManager;
  RefreshHomepage([HPR_Client]);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoRebranding;
begin
  mniExportdatatoBanklinkOnline.Caption := 'E&xport data to ' + BRAND_ONLINE;
  mniSystemBankLinkConnect.Caption      := 'Download from &' + BRAND_SECURE;
  actSendViaOnline.Caption              := 'via &' + BRAND_ONLINE;
  actGetFromOnline.Caption              := 'from &' + BRAND_ONLINE;
  tbOnline.Caption                      := BRAND_ONLINE_FULL;
end;

procedure TfrmMain.DoRefreshChart;
begin
  Import32.RefreshChart;
  SendCmdToAllCodingWindows( ecRecodeTrans);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFRefreshChartClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcRefreshChart);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoExtract;
begin
   ExtractData;
   //The transfered flag may now be set, reload any coding windows that are visible
   SendCmdToAllCodingWindows( ecReloadTrans);
end;                                                                                                                 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFExtractDataClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcExtract);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoBNotesExport( Dest : byte);
begin
   if ECodingUtils.ExportECodingFileToFile( MyClient, Dest) then
   begin
      //force a save of the client file, otherwise could lose ecoding ID's
      SaveClient(false);
      SendCmdToAllCodingWindows( ecRecodeTrans);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniFileExchangeRatesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcExchangeRates);
end;

procedure TfrmMain.mniExportBNToFileClick(Sender: TObject);
begin
  IncUsage('Notes File');
  DoMainFormCommand( mf_mcExportBNotesToFile);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniExportBNtoMailClick(Sender: TObject);
begin
  IncUsage('Notes Email');
  DoMainFormCommand( mf_mcExportBNotesToMail);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ViewSystemLog1Click(Sender: TObject);
begin
//
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniHelpViewSystemLogClick(Sender: TObject);
begin
   ShellExecute(Handle,'open',pChar('notepad.exe'),PChar(ExecDir + LogUtil.LogFileName) ,nil,SW_SHOWNORMAL);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// POPUPS
// POPUPS
// POPUPS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
procedure TfrmMain.popViewPopup(Sender: TObject);
begin
   if ActiveMDIChild is TfrmCoding then  begin
      mniViewAllEntries.Checked         := TfrmCoding(ActiveMDIChild).ShowingAllTran = SHOW_ALL_TX;
      mniViewUncodedEntriesOnly.Checked := TfrmCoding(ActiveMDIChild).ShowingAllTran = SHOW_UNCODED_TX;
      mniViewNotesOnly.Checked := TfrmCoding(ActiveMDIChild).ShowingAllTran = SHOW_UnreadNOTES_TX;
      mniEntrieswithNotes.Checked := TfrmCoding(ActiveMDIChild).ShowingAllTran = SHOW_NOTES_TX;
      mniEntrieswithoutNotes.Checked := TfrmCoding(ActiveMDIChild).ShowingAllTran = SHOW_NoNOTES_TX;

      if  TfrmCoding(ActiveMDIChild).IsJournal then begin
         mniViewEditCodesOnly.Visible := False;
         mniViewEditAllCol.Visible := False;
      end else begin
         mniViewEditCodesOnly.Visible := True;
         mniViewEditAllCol.Visible := True;
         mniViewEditCodesOnly.checked := (TfrmCoding(ActiveMDIChild).RestrictedMode);
         mniViewEditAllCol.checked    := not (TfrmCoding(ActiveMDIChild).RestrictedMode);
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.popSortByPopup(Sender: TObject);
var
  j         : integer;
begin
   tbSort.Down := false;
   //put the check box in the correct place
   if ActiveMDIChild is TfrmCoding then begin
      for j := 0 to Pred( popSortBy.Items.Count ) do
         PopSortBy.Items[ j].Checked := ( PopSortBy.Items[j].Tag = TfrmCoding(ActiveMDIChild).CurrentSortOrder);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// TOOLBAR COMMANDS
// TOOLBAR COMMANDS
// TOOLBAR COMMANDS
// TOOLBAR COMMANDS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tbPayeesClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecPayee);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSortByClick(Sender: TObject);
begin
   case TMenuItem( Sender).Tag of
      csDateEffective :  DoCodingTBarCommand(ecSortDate);
      csChequeNumber  :  DoCodingTBarCommand(ecSortChq);
      csReference     :  DoCodingTBarCommand(ecSortRef);
      csDatePresented :  DoCodingTBarCommand(ecSortPres);
      csAccountCode   :  DoCodingTBarCommand(ecSortAcct);
      csByValue       :  DoCodingTBarCommand(ecSortValue);
      csByNarration   :  DoCodingTBarCommand(ecSortNarr);
      csByAccountDesc :  DoCodingTBarCommand(ecSortAccountDesc);
      csByOtherParty  :  DoCodingTBarCommand(ecSortOther);
      csByParticulars :  DoCodingTBarCommand(ecSortParticulars);
      csByStatementDetails : DoCodingTBarCommand(ecSortStatementDetails);
      csByEntryType   :  DoCodingTBarCommand(ecSortEntryType);
      csByAnalysis    :  DoCodingTBarCommand(ecSortAnalysis);
      csByCodedBy     :  DoCodingTBarCommand(ecSortCodedBy);
      csByPayee       :  DoCodingTBarCommand(ecSortPayee);
      csByPayeeName   :  DoCodingTBarCommand(ecSortPayeeName);
      csByGSTClass    :  DoCodingTBarCommand(ecSortGSTClass);
      csByGSTAmount   :  DoCodingTBarCommand(ecSortGSTAmount);
      csByQuantity    :  DoCodingTBarCommand(ecSortQuantity);
      csByForexAmount :  DoCodingTBarCommand(ecSortForexAmount);
      csByForexRate   :  DoCodingTBarCommand(ecSortForexRate);
      csByAltChartCode:  DoCodingTBarCommand(ecSortAltChartCode);
      csByDocumentTitle : DoCodingTBarCommand(ecSortDocumentTitle);
      csByjob         : DoCodingTBarCommand(ecSortJobs);
      csByjobName     : DoCodingTBarCommand(ecSortJobName);
      csByTransId      : DoCodingTBarCommand(ecSortTransId);
      csBySentToAndAcc : DoCodingTBarCommand(ecSortSentToAndAcc);
      csSuggestedMemCount : DoCodingTBarCommand(ecSuggestedMemCount);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniConfigureColumnsClick(Sender: TObject);
begin
   DoCodingTbarCommand(ecConfigureCols);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RestoreColumnDefaultsClick(Sender: TObject);
begin
   DoCodingTbarCommand(ecRestoreCols);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniViewAllEntriesClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecViewAll);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniViewUncodedEntriesOnlyClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecViewUncoded);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AddOutChqClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddOutChq);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AddOutDepClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddOutDep);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.MatchEntryClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecMatch);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.AddInitChqClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddInitChq);
end;
//------------------------------------------------------------------------------
procedure TfrmMain.mniRecombineClick(Sender: TObject);
begin
   DoCodingTBarCommand( ecRecombine);
end;
procedure TfrmMain.mniReMapChartClick(Sender: TObject);
begin
   RemapChart;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// REPORTS
// REPORTS
// REPORTS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
procedure TfrmMain.mniGSTSetupReportOptionsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcGSTDetails);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRSetupReportHeadingsClick(Sender: TObject);
begin
  IncUsage('Cash Flow Report - Set up Titles and Headings');
  SetupCFNames;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRSetupReportHeadingsClick(Sender: TObject);
begin
  IncUsage('Profit and Loss Report - Set up Titles and Headings');
  SetupPRNames;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSetupGraphHeadingsClick(Sender: TObject);
begin
  IncUsage('Graphs - Set up Titles and Headings');
  SetupGraphNames;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniQueryClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcQueryUncoded);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListEntriesClick(Sender: TObject);
begin
  DoModalReport(REPORT_LIST_ENTRIES,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListJournalsClick(Sender: TObject);
begin
  DoModalReport(REPORT_LIST_JOURNALS,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListBankAccountsClick(Sender: TObject);
begin
   DoModalReport(REPORT_LIST_BANKACCTS,rdAsk, BKH_List_bank_accounts);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListPayeesClick(Sender: TObject);
begin
   DoModalReport(REPORT_LIST_PAYEE, rdNone);
end;
//------------------------------------------------------------------------------
procedure TfrmMain.mniListManualClick(Sender: TObject);
begin
  DoModalReport(REPORT_LIST_MANUAL, rdNone);
end;

procedure TfrmMain.mniListMemorisationsClick(Sender: TObject);
begin
   DoModalReport( Report_List_Memorisations, rdNone, BKH_List_memorisations);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListLedgerClick(Sender: TObject);
begin
   DoModalReport(REPORT_LIST_LEDGER,rdNone);
end;
//------------------------------------------------------------------------------

procedure TfrmMain.mniListGSTDetailsClick(Sender: TObject);
begin
   DoModalReport( REPORT_LIST_GST_DETAILS, rdAsk, BKH_List_GST_details);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCodingOptimisationReportClick(Sender: TObject);
begin
   DoModalReport( REPORT_CODING_OPTIMISATION, rdNone);
end;

procedure TfrmMain.mniCodingReportClick(Sender: TObject);
begin
   DoModalReport(REPORT_CODING,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRActualClick(Sender: TObject);
begin
   DoModalReport(REPORT_CASHFLOW_ACT, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRActualandBudgetClick(Sender: TObject);
begin
   DoModalReport(REPORT_CASHFLOW_ACTBUD, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRActualBudgetandVarianceClick(Sender: TObject);
begin
   DoModalReport(REPORT_CASHFLOW_ACTBUDVAR, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFR12MonthsActualClick(Sender: TObject);
begin
   doReport(REPORT_CASHFLOW_12ACT, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFR12MonthsActualandBudgetClick(Sender: TObject);
begin
   doReport(REPORT_CASHFLOW_12ACTBud, rdNone);
end;
//------------------------------------------------------------------------------
procedure TfrmMain.miCFRActualLastYearVarianceClick(Sender: TObject);
begin
   DoModalReport( Report_Cashflow_ActLastYVar, rdNone);
end;
procedure TfrmMain.mmiTaxablePaymentsReportClick(Sender: TObject);
begin
  DoModalReport(REPORT_TAXABLE_PAYMENTS,rdNone);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniListChartofAccountsClick(Sender: TObject);
begin
  if Assigned(AdminSystem) then
    DoModalReport(REPORT_LIST_CHART, rdNone, BKH_List_chart_of_accounts)
  else
    DoModalReport(REPORT_LIST_CHART, rdAsk, BKH_List_chart_of_accounts)
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniBRRSummarisedClick(Sender: TObject);
begin
   DoModalReport(REPORT_BANKREC_SUM,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniBRRDetailedClick(Sender: TObject);
begin
   DoModalReport(REPORT_BANKREC_DETAIL, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSPSummarisedClick(Sender: TObject);
begin
//   DoModalReport(REPORT_PAYEE_SPENDING,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSPDetailedClick(Sender: TObject);
begin
//   DoModalReport(REPORT_PAYEE_SPENDING_DETAILED,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniExPrintExceptionReportClick(Sender: TObject);
begin
   DoModalReport(REPORT_EXCEPTION,rdNone);
end;
procedure TfrmMain.mniExtractBulkDataClick(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRFromDatetoDateClick(Sender: TObject);
begin
  DoModalReport(REPORT_CASHFLOW_DATE,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFRBudgetRemainingClick(Sender: TObject);
begin
  Doreport(REPORT_CASHFLOW_BUDREM,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRActualClick(Sender: TObject);
begin
  DoModalReport(REPORT_PROFIT_ACT,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRActualAndBudgetClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_ACTBUD,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRActualBudgetAndVarianceClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_ACTBUDVAR,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPR12MonthsActualClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_12ACT,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPR12MonthsActualandBudgetClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_12ACTBUD,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniRP12MonthsBudgetClick(Sender: TObject);
begin
  DoModalReport(REPORT_PROFIT_12BUD, rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.N6FromDatetoDate2Click(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_DATE,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRBudgetRemainingClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_BUDREM,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGSTSummaryClick(Sender: TObject);
begin
   DoModalReport(REPORT_GST_SUMMARY,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGST12MonthSummaryClick(Sender: TObject);
begin
  DoModalReport(REPORT_GST_SUMMARY_12,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGSTAllocationSummaryClick(Sender: TObject);
begin
  DoModalReport(REPORT_GST_ALLOCATIONSUMMARY,rdNone);
end;

procedure TfrmMain.mniGSTAuditTrailClick(Sender: TObject);
begin
   DoModalReport(REPORT_GST_AUDIT,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.mniBusinessNormsClick(Sender: TObject);
begin
  DoModalReport(REPORT_GST_BUSINESSNORMS, rdNone);
end;

//------------------------------------------------------------------------------
function TfrmMain.GetMDIChildSortedList: TStringList;
begin
  if not Assigned(fMDIChildSortedList) then
  begin
    fMDIChildSortedList := TStringList.Create;
  end;

  Result := fMDIChildSortedList;
end;

function TfrmMain.GetMDICurrentChildCaption: string;
begin
  Result := MDIChildSortedList.Strings[MDIChildSortedIndex];
end;

function TfrmMain.GetMDIIndexFromCaption(aCaption: string): integer;
var
  MDIIndex : integer;
begin
  Result := -1;
  for MDIIndex := 0 to MDIChildSortedList.Count-1 do
  begin
    if MDIChildSortedList.Strings[MDIIndex] = aCaption then
    begin
      Result := MDIIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.GSTOverrides1Click(Sender: TObject);
begin
  DoModalReport( REPORT_GST_OVERRIDES, rdNone);
end;


//------------------------------------------------------------------------------
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// GRAPHS
// GRAPHS
// GRAPHS
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGraphSalesClick(Sender: TObject);
begin
  DoGraph(GRAPH_TRADING_SALES);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGraphPaymentsClick(Sender: TObject);
begin
  DoGraph(GRAPH_TRADING_PAYMENTS);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGraphTradingResultsClick(Sender: TObject);
begin
  DoGraph(GRAPH_TRADING_RESULTS);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGraphBankBalancesClick(Sender: TObject);
begin
   DoGraph(GRAPH_BANK_BALANCE);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniGraphOnePageSummaryClick(Sender: TObject);
begin
   DoGraph(GRAPH_SUMMARY);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//******************************************************************************
//******************************************************************************
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMasterMems;
begin
   //edit master memorised entries, reload coding windows if any changed
   if MaintainMasters then
      SendCmdToAllCodingWindows( ecRecodeTrans);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.MasterMemorisedEntries1Click(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSys_MasterMems);
end;

procedure TfrmMain.mniViewEditCodesOnlyClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecEditAcctCol);
end;

procedure TfrmMain.mniViewEditAllColClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecEditAllCol);
end;

procedure TfrmMain.mniDEOpeningBalancesClick(Sender: TObject);
begin
  IncUsage('Opening Balances');
  DoMainFormCommand( mf_mcOpeningBalances);
end;

procedure TfrmMain.mniDENTJStockJournalsClick(Sender: TObject);
begin
  IncUsage('Non-Transferring Journals - Stock Adjustment Journals');
  DoMainFormCommand( mf_mcStockJournals);
end;

procedure TfrmMain.mniDENTJGSTJournalsClick(Sender: TObject);
begin
  IncUsage('Non-Transferring Journals - GST Journals');
  DoMainFormCommand( mf_mcGSTJournals);
end;

procedure TfrmMain.mniOpeningsBalanceJnlsClick(Sender: TObject);
begin
  IncUsage('Non-Transferring Journals - Opening Balances');
  DoMainFormCommand( mf_mcOpeningBalanceJnls);
end;

procedure TfrmMain.mniBudgetReportClick(Sender: TObject);
begin
  DoModalReport(REPORT_BUDGET_12CASHFLOW,rdNone);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoLockPeriod;
begin
   FinaliseAccountingPeriod;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniDEFinalisePeriodClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcLockPeriod);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoUnlockPeriod;
begin
   UnlockAccountingPeriod;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFUnlockaFinalisedPeriodClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcUnlockPeriod);
end;

procedure TfrmMain.mniClearTransferFlagsClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcClearTransferFlags);
end;

procedure TfrmMain.PracticeBankAccounts1Click(Sender: TObject);
begin
  MaintainPracticeBankAccounts(mpba_Normal);
end;

procedure TfrmMain.mniListChargesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcListCharges);
end;

procedure TfrmMain.mniReportScheduleClick(Sender: TObject);
begin
   SetupClientSchedule(MyClient, BKH_Scheduled_Reports);
   UpdateMenus;
end;

procedure TfrmMain.mniReportStyleClick(Sender: TObject);
begin
  IncUsage('Report and Graph Options');
  ReportOptions;
end;

procedure TfrmMain.mniSystemMonthlyReportsClick(Sender: TObject);
begin
  IncUsage('Scheduled Reports');
  ProcessModalCmdWithDlg( mpcDoPrintScheduledReports);
end;

procedure TfrmMain.EmailSupport1Click(Sender: TObject);
begin
  SendMailToSupport( GetSupportEmailAddress);
end;

procedure TfrmMain.DownloadReport1Click(Sender: TObject);
begin
   DoModalReport(REPORT_DOWNLOAD,rdNone);
end;

procedure TfrmMain.ListClientTypes1Click(Sender: TObject);
begin
   DoModalReport(List_Client_Types,rdask);
end;

procedure TfrmMain.ListGroups1Click(Sender: TObject);
begin
   DoModalReport(List_Groups,rdAsk,BKH_List_Groups)
end;

procedure TfrmMain.ListJobs1Click(Sender: TObject);
begin
  if not assigned(MyClient) then
     exit;

  if MyClient.clJobs.ItemCount = 0 then begin
     HelpfulInfoMsg( 'There are no job set up for this client.', 0);
     Exit;
  end;
  DoModalReport( Report_List_Jobs, rdAsk, BKH_List_jobs);
end;

procedure TfrmMain.ListReportsDue1Click(Sender: TObject);
begin
   DoModalReport(REPORT_WHATSDUE,rdNone );
end;

procedure TfrmMain.mniListAdminBankAccountsClick(Sender: TObject);
begin
   DoModalReport(REPORT_ADMIN_ACCOUNTS,rdNone);
end;

procedure TfrmMain.mniListProvisionalClick(Sender: TObject);
begin
  DoModalReport(REPORT_PROV_ACCOUNTS, rdNone);
end;

procedure TfrmMain.mniListInactiveClick(Sender: TObject);
begin
   DoModalReport(REPORT_ADMIN_INACTIVE_ACCOUNTS,rdNone);
end;

procedure TfrmMain.mniClientsByStaffClick(Sender: TObject);
begin
   DoModalReport(REPORT_CLIENTS_BY_STAFF, rdAsk, BKH_List_Clients_by_Staff_Member);
end;

procedure TfrmMain.mniClientReportOptionsClick(Sender: TObject);
begin
   DoModalReport(REPORT_CLIENT_REPORT_OPT,rdAsk, BKH_List_Client_Report_Options);
end;

procedure TfrmMain.mniDownloadLogClick(Sender: TObject);
begin
   DoModalReport(REPORT_DOWNLOAD_LOG,rdAsk, BKH_Download_Log);
end;


procedure TfrmMain.mniClientStatusReportClick(Sender: TObject);
begin
   DoModalReport( REPORT_CLIENT_STATUS, rdNone);
end;

procedure TfrmMain.mniClientFileAccessReportClick(Sender: TObject);
begin
   DoModalReport( REPORT_FILE_ACCESS_CONTROL, rdAsk, BKH_Client_File_Access_Report);
end;

procedure TfrmMain.mniOffsiteDownloadClick(Sender: TObject);
begin
   ProcessModalCmdWithDlg( mpcDoOffsiteDownload);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ImportUpdateFile;
begin
   //close visible accounts in case new transactions added
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
     DoImportUpdateFiles;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniImportUpdateClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcImportUpdateFile);
end;

procedure TfrmMain.mniOffsiteDownloadLogClick(Sender: TObject);
begin
   DoModalReport(REPORT_DOWNLOAD_LOG_OFFSITE,rdAsk);
end;

procedure TfrmMain.mniResyncroniseClientClick(Sender: TObject);
begin
   DoResyncClientFile;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.Synchronise;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
   begin
     DoResyncMyClient;
     UpdateMenus;  //if resync was successful then menus need updating
   end;
end;

procedure TfrmMain.mniSystemAuditReportClick(Sender: TObject);
begin
  DoModalReport(Report_Audit, rdNone);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniSyncroniseMyClientClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcSynchronise);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoHDE;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else begin
     // Posted entries?
     if AddHistoricalData then begin
       ASSERT(assigned(MyClient));
       RefreshHomepage([HPR_ExchangeGainLoss_Message]);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMDE;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else begin
     // Posted entries?
     if AddManualData then begin
       ASSERT(assigned(MyClient));
       RefreshHomepage([HPR_ExchangeGainLoss_Message]);
     end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniAddHistoricalClick(Sender: TObject);
begin
  IncUsage('Historical Entries');
  DoMainFormCommand( mf_mcHDE);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.PurgeEntries;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
     DoPurgeClientEntries;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniOFPurgeOldEntriesClick(Sender: TObject);
begin
  IncUsage('Purge Entries');
  DoMainFormCommand( mf_mcPurgeEntries);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RebuildPopups;
var
  j : integer;
  xclude: set of byte;
  NewItem : TMenuItem;  
begin
   //Copy Menus to ToolBar PopUps
   MenuCopyToPopUp( 'mnsReport', popReport );
   MenucopyToPopUp( 'mnsGraph',  popGraph  );

   //Copy GST Manually
   AssignMenuItems(popGST, mnsGSTReports, popGST.Items);

   //add sorting options
   if Assigned( MyClient) then begin
       if MyClient.clFields.clCountry = whAustralia then
         xclude := [ csByOtherParty, csByParticulars, csByAnalysis, csAccountCodeXLON]
       else
         xclude := [ csAccountCodeXLON]
   end else
      XClude := [];
   {$IFNDEF SmartLink}
   XClude :=  XClude + [csByDocumentTitle];
   {$ENDIF}

  //rebuild sort by pop up
  //add sorting options
  PopSortBy.Items.Clear;
  for j := csMin to csMax do
  begin
    NewItem := TMenuItem.Create( popSortBy );
    if Assigned(MyClient) then
       NewItem.Caption := 'By '+ Localise( MyClient.clFields.clCountry, csNames[csSortByOrder[j]])
    else
       NewItem.Caption := 'By '+ csNames[csSortByOrder[j]];
    NewItem.OnClick := mniSortByClick;
    NewItem.Visible := not( csSortByOrder[j] in xclude);
    NewItem.Enabled := true;
    NewItem.Tag     := csSortByOrder[j];
    popSortBy.Items.Add( NewItem);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mnsTestClick(Sender: TObject);
begin

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoLoadBasTemplate;
begin
   Template.LoadFromTemplate;
   SendCmdToAllCodingWindows( ecRefreshTable);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniLoadBASTemplateClick(Sender: TObject);
begin
  IncUsage('Load BAS Template');
  DoMainFormCommand( mf_mcLoadBasTemplate);
end;
//------------------------------------------------------------------------------

procedure TfrmMain.mniSaveBASTemplateClick(Sender: TObject);
begin
  IncUsage('Save BAS Template');
  DoMainFormCommand( mf_mcSaveBasTemplate);
end;
//------------------------------------------------------------------------------
procedure TfrmMain.TransferTempEntries;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
     TransferEntriesDlg.TransferEntries;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniTransferEntriesClick(Sender: TObject);
begin
  IncUsage('Transfer Manual Account Entries');
  DoMainFormCommand( mf_mcTransferEntries);
end;
//------------------------------------------------------------------------------

procedure TfrmMain.IncrementDates1Click(Sender: TObject);
var
   i : integer;
   t : integer;
   pT : pTransaction_Rec;
begin
   //add 1 year to all transaction dates
   with MyClient do
      with clBank_Account_List do
         for i := 0 to Pred( ItemCount) do
            with Bank_Account_At(i) do begin
               with baTransaction_List do begin
                  for  t := 0 to Pred( baTransaction_List.ItemCount) do begin
                     pT := Transaction_At( t);
                     if pt^.txDate_Presented <> 0 then
                        pt^.txDate_Presented := IncDate( pT^.txDate_Presented, 0,0,1);

                     if pt^.txDate_Effective <> 0 then
                        pt^.txDate_Effective := IncDate( pT^.txDate_Effective, 0,0,1);

                     if pt^.txDate_Transferred <> 0 then
                        pt^.txDate_Transferred := IncDate( pT^.txDate_Transferred, 0,0,1);
                  end;
               end;
            end;
end;

procedure TfrmMain.InitialiseLeanEngage;
var
  sIdentityID : string;
begin
  sIdentityID := '';
// Setup the key for different environments
 // DN - Change #89926 Remove the check for Support Staff but force to test API site
    if ( INI_LeanEngage_System_Switch = cLeanEngage_TestSwitch ) or
    ( AdminSystem.fdFields.fdBankLink_Code =
          cLeanEngage_Support_Practice_Code ) then // Make sure this is an MYOB IT Support Practice Code
      cLeanEngageApp_Key := cLeanEngage_TestAPIKey
    else
      cLeanEngageApp_Key := cLeanEngage_ProdAPIKey;

    sIdentityID := CurrUser.Code + AdminSystem.fdFields.fdPractice_Name_for_Reports;
  if not (StartupParam_Action in System_Actions) and
         ((CurrUser.Code <> 'BANKLNK5') and
          (CurrUser.Code <> 'SUPERUSER') and
          (CurrUser.Code <> 'SUPERVIS' )) then begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,
         Format( 'InitialiseLeanEngage NPSLeanEngage := TNPSLeanEngage.Create( ' +
           'sIdentityID = %s, PRACINI_LeanEngage_BASE_URL = %s, ' +
           'LeanEngageApp_Key = %s, AdminSystem.fdFields.fdPractice_Name_for_Reports = %s, ' +
           'CountryText( AdminSystem.fdFields.fdCountry ) = %s, sIdentityID = %s, ' +
           'BRAND_FULL_PRACTICE = %s, VersionInfo.GetAppVersionStr = %s ',
           [ sIdentityID, INI_LeanEngage_BASE_URL, cLeanEngageApp_Key,
             AdminSystem.fdFields.fdPractice_Name_for_Reports,
             CountryText( AdminSystem.fdFields.fdCountry ), sIdentityID,
             BRAND_FULL_PRACTICE, VersionInfo.GetAppVersionStr ] ) );

    NPSLeanEngage := TNPSLeanEngage.Create( sIdentityID,         // Create LeanEngage Object
      INI_LeanEngage_BASE_URL, cLeanEngageApp_Key,
      AdminSystem.fdFields.fdBankLink_Code,
      AdminSystem.fdFields.fdPractice_Name_for_Reports,
      CountryText( AdminSystem.fdFields.fdCountry ), sIdentityID,
      BRAND_FULL_PRACTICE, VersionInfo.GetAppVersionStr );

    if assigned( NPSLeanEngage ) then begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug,unitname,
          'InitialiseLeanEngage TriggerIdentifyAsync' );

      NPSLeanEngage.TriggerIdentifyAsync( ); // Initialise the Identity EndPoint to log the session

      if DebugMe then
        LogUtil.LogMsg(lmDebug,unitname,
          'InitialiseLeanEngage TriggerSurveyAsync' );

      NPSLeanEngage.TriggerSurveyAsync( DisplayAvailableNPSSurveys ); // Initialise and display surveys

      if DebugMe then
        LogUtil.LogMsg(lmDebug,unitname,
          'InitialiseLeanEngage TriggerFeedbackAsync( taFeedbackResponse )' );

      NPSLeanEngage.TriggerFeedbackAsync( taFeedbackResponse ); // Initialise for Feedback
    end;
  end;
end;

procedure TfrmMain.mniTestAdminLockingClick(Sender: TObject);
begin
{$IFDEF BK5_TESTLOCKING}
     LockingTestFrm.TestLocking;
{$ENDIF}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ImportBNotesFromFile(Dest: Byte);
var
   fName : string;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
   begin
     fName := '';
     ImportECodingFileFromFile( MyClient, fName,true, Dest);
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniImportECodingFileClick(Sender: TObject);
begin

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoAnnualGST_AU;
begin
   if not Assigned( myClient) then exit;
   RunGSTReport(REPORT_BASSUMMARY);
   //may have locked accounting period so update any coding windows
   SendCmdToAllCodingWindows( ecRecodeTrans);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniAnnualGSTreportClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcAnnualGSTReport);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoAnnualGSTReturn_AU;
begin
   if not Assigned( myClient) then exit;
   RunGSTReport( Report_GST372);
   //may have locked accounting period so update any coding windows
   SendCmdToAllCodingWindows( ecRecodeTrans);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniAnnualGSTReturnClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcAnnualGSTReturn);
end;

procedure TfrmMain.EmailSystemLog1Click(Sender: TObject);
var
   TempFilename : string;
   ZipFilename  : string;
   dummy: Boolean;
begin
   Dummy := false;

   //copy log to temp dir and compress
   if Assigned( AdminSystem) then
      TempFilename := WinUtils.GetTempDir( DataDir) +
                      AdminSystem.fdFields.fdBankLink_Code + '.LOG'
   else
      TempFilename := WinUtils.GetTempDir( DataDir) +
                      DEFAULTTEMPLOGFILENAME;

   ZipFilename  := ChangeFileExt( TempFilename, '.ZIP');
   try
      DeleteFile( TempFilename);
      DeleteFile( ZipFilename);

      try
         ErrorLog.SysLog.SaveCopyTo( TempFilename);
      except
         on E : Exception do begin
           HelpfulErrorMsg( 'Cannot Send Log File, Copy Failed - ' +
                            E.Message + '[' +
                            E.Classname + ']', 0);
           Exit;
         end;
      end;

      try
         ZipUtils.CompressFile( TempFilename, ZipFilename);
      except
         on E : Exception do begin
            HelpfulErrorMsg( 'Cannot Send Log File, Compress Failed  - ' +
                             E.Message + ' [' +
                             E.ClassName + ']', 0);
            Exit;
         end;
      end;

      //send to support
      MailFrm.SendFileTo( 'Send Log File', GetSupportEmailAddress, '', ZipFilename, dummy);
   finally
      DeleteFile( TempFilename);
      DeleteFile( ZipFilename);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFCustomClick(Sender: TObject);
begin
   CashflowOptionsDlg.UpdateCashflowReportOptions( MyClient);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mnsTrialBalanceClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcTrialBalance);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniPRCustomClick(Sender: TObject);
begin
   ProfitAndLossOptionsDlg.UpdateProfitAndLossReportOptions( MyClient);
end;
                                              
procedure TfrmMain.mniSetUpReportHeadingsClick(Sender: TObject);
begin
  IncUsage('Balance Sheet Report - Set up Titles and Headings');
  BalanceSheetNamesDlg.SetupBSNames;
end;

procedure TfrmMain.mniBalanceSheetClick(Sender: TObject);
begin
  BalanceSheetOptionsDlg.UpdateBalanceSheetOptions( MyClient);
end;

procedure TfrmMain.mniBatchReportsClick(Sender: TObject);
begin
   RunBatchreports(ByReport);
end;

procedure TfrmMain.mniYearEndAdjustmentsClick(Sender: TObject);
begin
  IncUsage('Non-Transferring Journals - Year End Adjustments');
  DoMainFormCommand( mf_mcYearEndJournals);
end;

procedure TfrmMain.mniYearEndClick(Sender: TObject);
begin
  IncUsage('Year End Balances');
  DoMainFormCommand( mf_mcYearEnd);
end;

procedure TfrmMain.mniExchangeGainLossWizardClick(Sender: TObject);
begin
  IncUsage('Exchange Gain/Loss Wizard');
  DoMainFormCommand(mf_mcExchangeGainLossWizard);
  RefreshHomepage;
end;

procedure TfrmMain.DownloadReportSummarised1Click(Sender: TObject);
begin
   //IncUsage('Summarised System Download Report');
   DoModalReport(REPORT_SUMMARY_DOWNLOAD,rdAsk, BKH_Running_the_Download_Report);
end;

procedure TfrmMain.Options1Click(Sender: TObject);
begin
  AdminOptionsDlg.UpdateAdminOptions;


  if Globals.ApplicationMustShutdownForUpdate then
      Close
  else if not AutoSaveOutstanding then
     ResetAutoSave;
end;

procedure TfrmMain.mniUnpresentedItemsClick(Sender: TObject);
begin
  DoModalReport( Report_Unpresented_Items, rdNone);
end;


procedure TfrmMain.mniListSubGroupsClick(Sender: TObject);
var
   i : integer;
   Found : boolean;
begin
   if not assigned( MyClient) then exit;

   //see if there are any sub groups
   Found := false;
   for i := 1 to glConst.Max_SubGroups do
   begin
     if MyClient.clCustom_Headings_List.Get_SubGroup_Heading( i) <> '' then
       Found := true;
   end;
   if not Found then
   begin
     HelpfulInfoMsg( 'There are no sub-groups set up for this client.', 0);
     Exit;
   end;
   DoModalReport( Report_List_SubGroups, rdAsk, BKH_List_sub_groups);
end;

procedure TfrmMain.mniListDivisionsClick(Sender: TObject);
var
   i : integer;
   Found : boolean;
begin
   if not assigned( MyClient) then exit;

   //see if there are any divisions
   Found := false;
   for i := 1 to glConst.Max_Divisions do
   begin
     if MyClient.clCustom_Headings_List.Get_Division_Heading( i) <> '' then
       Found := true;
   end;
   if not Found then
   begin
     HelpfulInfoMsg( 'There are no divisions set up for this client.', 0);
     Exit;
   end;
   DoModalReport( Report_List_Divisions, rdAsk, BKH_List_divisions);
end;

procedure TfrmMain.ClientTypes1Click(Sender: TObject);
begin
  IncUsage('Client Types');
  MaintainClientTypes;
  RefreshClientManager;
  if Assigned( MyClient) then
    Merge32.SyncClientToAdmin( MyClient, false, false);
end;

procedure TfrmMain.ClientWndProc(var WinMsg: TMessage);
var
  MyDC : hDC;

  procedure Default;
  begin
    //call previous client window handler
    with WinMsg do
      Result := CallWindowProc(FPrevClientProc, ClientHandle, Msg, wParam, lParam);
  end;

begin
  with WinMsg do
    case Msg of
      WM_ERASEBKGND:
        begin

          //display bitmap on MDI background

          with Image1 do
          begin
            MyDC := TWMEraseBkGnd(WinMsg).DC;
            //paint background
            FillRect(MyDC, Self.ClientRect, Self.Brush.Handle);

            if (not bkBranding.Is256Color) and BackGroundImageVisible then
            begin
              //render the resized image on the background
              StretchBlt(MyDC, Image1Left, Image1Top, Image1Width, Image1Height,
                Picture.Bitmap.Canvas.Handle, 0, 0, Width, Height, SRCCOPY);
            end;
            Result := 1;
          end;

        end;
      WM_SIZE :
        begin
          //window has been resized
          Default;
          InvalidateRect(Self.ClientHandle, nil, True);
        end;
    else
      Default;
    end;
end;

procedure TfrmMain.CRCFileCheckClick(Sender: TObject);
begin
   frmFiletest.ShowFileTestForm;
end;

procedure TfrmMain.ProcessModalCmdWithDlg(command: TModalProcessorCommand);
//this routine is used to process routines that call application process messages
begin
  ModalProcessorDlg.DoModalCommand( Command);
end;

procedure TfrmMain.ResetCustomLogoSize;
const
  MaxCustomLogoWidth          = 300;
  MaxCustomLogoHeight         = 150;
var
  AspectRatio : double;
begin
  //set to actual size to start with
  imgPracticeLogo.Width    := imgPracticeLogo.Picture.Width;
  imgPracticeLogo.Height   := imgPracticeLogo.Picture.Height;

  //calculate aspect ratio of logo
  if imgPracticeLogo.Height > 0 then
    AspectRatio := imgPracticeLogo.Width / imgPracticeLogo.Height
  else
    AspectRatio := 1.0;

  if AspectRatio <= 0 then
    AspectRatio := 1.0;

  //make sure not bigger than max
  if ( imgPracticeLogo.Width > MaxCustomLogoWidth) or ( imgPracticeLogo.Height > MaxCustomLogoHeight) then
  begin
    if AspectRatio >= ( MaxCustomLogoWidth / MaxCustomLogoHeight) then
    begin
      //scale width, then adjust height
      imgPracticeLogo.Width    := MaxCustomLogoWidth;
      imgPracticeLogo.Height   := Round( imgPracticeLogo.Width / AspectRatio);

      imgPracticeLogo.AutoSize := False;
      imgPracticeLogo.Stretch  := True;
    end
    else
    begin
      //scale height, then adjust width
      imgPracticeLogo.Height   := MaxCustomLogoHeight;
      imgPracticeLogo.Width    := Round( imgPracticeLogo.Height * AspectRatio);

      imgPracticeLogo.AutoSize := False;
      imgPracticeLogo.Stretch  := True;
    end;
  end;
end;

function TfrmMain.LoadCustomLogoFromFile(filename: string) : boolean;
//load the logo and resize is according to max allowable, maintain aspect
//the logo is first loaded into the images form so that it can be used in the
//about screen
begin
   result := false;

   if BKFileExists( filename) then
   begin
     try
       imgPracticeLogo.Picture.LoadFromFile( filename);
     except
       on e : exception do
     end;
     //set the height and width for graphic
     ResetCustomLogoSize;
     result := true;
   end;
end;

function TfrmMain.LoadCustomLogofromString( S : String) : boolean;
begin
  result := false;
  if s <> '' then
  begin
    try
      MimeUtils.DecodePictureFromString( S, imgPracticeLogo.Picture);
    except
      on e : exception do
    end;
     //set the height and width for graphic
     ResetCustomLogoSize;
     result := true;
  end;
end;

procedure TfrmMain.RedrawFormBackground;
var
  CRect : TRect;
begin
  //repaint the client area
  CRect := Self.BoundsRect;
  InvalidateRect(ClientHandle,@CRect,true);
end;

procedure TfrmMain.RefreshClientManager;
var Restore: Boolean;
begin
   Restore := False;
   if Assigned (ActiveMDIChild) then
     Restore := (ActiveMDIChild is TfrmClientManager);
  ClientManagerFrm.RefreshClientManager('',Restore);
end;

procedure TfrmMain.RefreshUserControls;
begin
  mniChangePassword.Visible := (CurrUser.AllowBanklinkOnline
                               and FAdminSystemFound);

  SetExportdatatoBanklinkOnlineVisiblility();
end;

procedure TfrmMain.ReloadCustomLogo;
//loads the correct logo, or makes it invisible
//load the practice logo if admin system is present
//load the logo from a client file is one is specified, this will only happen
//when files have been checked in to an offsite system
var
  ShowCustomLogo : boolean;
begin
  ShowCustomLogo := false;
  UsingCustomPracticeLogo := false;

  //force application to use logo from Branding DLL if present
  if (bkBranding.BrandingImageSet = imDLL) then
  begin
    imgPracticeLogo.Picture := bkBranding.ClientBanner;
    imgPracticeLogo.transparent := true;
    imgPracticeLogo.Visible := true;
    BackGroundImageVisible  := false;
    Exit;
  end;

  if Assigned( AdminSystem) then begin
    //Display the custom practice logo if user option is on
    if not Assigned(CurrUser) then // Checking CurrUser in case the Practice window has been closed
      Exit;
    if CurrUser.ShowPracticeLogo  then begin
      ShowCustomLogo := LoadCustomLogoFromFile( AdminSystem.fdFields.fdPractice_Logo_Filename);
      if ShowCustomLogo then begin
        AppImages.imgAboutHiColor.Picture.Assign(imgPracticeLogo.Picture);
        imgPracticeLogo.Refresh;
      end;
    end else
      Exit;
  end;

  try
    //decide if we should use the logo from the client file, normal client files
    //will not have a logo because this will have been removed when the file was
    //checked back into the admin system
    if Assigned( MyClient) then
    begin
      if MyClient.clFields.clTemp_Logo_Was_Loaded_OK then
      begin
        //have already loaded the logo, don't do it again
        ShowCustomLogo := true;
      end
      else
      begin
        if MyClient.clFields.clPractice_Logo <> '' then
        begin
          try
            MyClient.clFields.clTemp_Logo_Was_Loaded_OK := LoadCustomLogoFromString( MyClient.clFields.clPractice_Logo);
            ShowCustomLogo := MyClient.clFields.clTemp_Logo_Was_Loaded_OK;
            UsingCustomPracticeLogo := true;
          except
            On E : Exception do
              LogUtil.LogError( Unitname, E.Message);
          end;
        end;
      end;
    end;
  finally
    imgPracticeLogo.Visible         := ShowCustomLogo;
    BackGroundImageVisible          := not imgPracticeLogo.Visible;
    UsingCustomPracticeLogo         := ShowCustomLogo;
    //force repositioning of graphics on background
    FormResize( Self);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.CanAutoSaveNow : boolean;
var
  TopHandle : THandle;
  i : Integer;
  Buffer : array[0..127] of Char;
begin
  result := false;

  //see if auto save is currently disabled
  if not AutoSaveUtils.AutoSaveAllowed then
    Exit;

  //get the handle for the top most window for this application
  TopHandle := Application.MainFormHandle;
  TopHandle := GetLastActivePopup(TopHandle);
  if (TopHandle <> 0) then
  begin
    //get class name for form
    i := GetClassName(TopHandle, @Buffer, 128);
    if (i > 0)
    and (StriComp(Buffer, PChar('TfrmMain')) = 0) then
    begin
      //the form on top is this form (TfrmMain), this may include one of
      //its mdi children
      Result := not UpdateMF.MDIChildInEditState;
      (*  // The above check does the whole thing anyway...
      if (MDIChildCount > 0) then
      begin
        if (MDIChildren[0] is TfrmCoding)
        or (MDIChildren[0] is TfrmBudget) then
        begin
          //the top most child window is a TfrmCoding or TfrmBudget so do the autosave
          result := not UpdateMF.MDIChildInEditState;
        end else result := True;
      end
      else
      begin
        //no MDI children, do auto save now
        result := True;
      end;
      *)
    end
  end;
end;

procedure TfrmMain.ChangetoUK1Click(Sender: TObject);
Var
  i : Integer;
  pCF : pClient_File_Rec;
  aClient : TClientObj;
  aSnapshot : TSystemObj;
begin
  if Assigned( MyClient ) then
  Begin
    MyClient.clFields.clCountry := whUK;
    MyClient.clFields.clAccounting_System_Used := 0;
    SaveClient(false);
  End;

  if AdminExists then
  begin
    aSnapshot := TSystemObj.Create;
    Admin32.ReloadAdminAndTakeSnapshot( aSnapshot);
    for i := aSnapshot.fdSystem_Client_File_List.First to aSnapshot.fdSystem_Client_File_List.Last do
    begin
      pCF := aSnapshot.fdSystem_Client_File_List.Client_File_At( i);
      try
        aClient := NIL;
        OpenAClient( pCF^.cfFile_Code, aClient, TRUE, FALSE, TRUE, FALSE );
        try
          if Assigned( aClient) then
          begin
            aClient.clFields.clCountry := whUK;
            aClient.clFields.clAccounting_System_Used := 0;
            CloseAClient( aClient, True );
          end;
        finally
          FreeAndNil( aClient );
        end;
      except
      end;
    end;
    FreeandNil( aSnapShot );

    if LoadAdminSystem(true, 'Change SYSTEM.DB To UK' ) then
    begin
      AdminSystem.fdFields.fdCountry := whUK;
      SaveAdminSystem;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//procedure TfrmMain.DisableMainMenuAndToolbar;
//var
//  i : Integer;
//begin
//  //disable menus and toolbar
//  for i := 0 to MainMenu.Items.Count-1 do
//  begin
//    with TMenuItem(MainMenu.Items[i]) do
//    begin
//      if (Enabled) then Tag := 1 else Tag := 0;
//      Enabled := False;
//    end;
//  end;
//  dokMainTop.Enabled := False;
//end;
//// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//procedure TfrmMain.EnableMainMenuAndToolbar;
//var
//  i : Integer;
//begin
//  //enable menus and toolbar
//  dokMainTop.Enabled := True;
//  for i := 0 to MainMenu.Items.Count-1 do
//  begin
//    with TMenuItem(MainMenu.Items[i]) do
//    begin
//      Enabled := (Tag = 1);
//      Tag := 0;
//    end;
//  end;
//end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.TryAutoSave;
//attempts an auto save after checking that we can do one now
const
  INTERVAL_RANGE = 10;
  INTERVAL_MIN   = 30;
  SECOND_MUTLIPLIER = 1000;
var
  ActiveForm: Forms.TForm;
  Saved: Boolean;
  Random_Interval : integer;
begin
  if Assigned(myClient) then begin
     if Self.CanAutoSaveNow then begin
        if DebugAutoSave then
           LogUtil.LogMsg(lmDebug,AutoSaveUnit,'Can Save');
        //make sure we can do an auto save now
        AutoSaveInProgress := True;
        ActiveForm := GetActiveForm;
        DisableMainForm;
        Saved := False;
        try
           Saved := DoAutoSave;
        finally
           EnableMainForm;
           AutoSaveInProgress := False;
           if Saved then begin
              // Refocus the correct window if its visible so we don't lose cursor control (#1596/1800)
              if ActiveForm is TfrmCoding then
                 CodingWindowFocus(ActiveForm)
              else if ActiveForm is TfrmBudget then
                 BudgetWindowFocus(ActiveForm);
           end;
        end;
     end else begin
        //set shorter auto save period so auto save triggered as soon as possible
        AutoSaveOutstanding := true;

        Random_Interval := (INTERVAL_MIN * SECOND_MUTLIPLIER) + Random(INTERVAL_RANGE * SECOND_MUTLIPLIER);

        tmAutoSave.Interval := Random_Interval;
        if DebugAutoSave then
           LogUtil.LogMsg(lmDebug,AutoSaveUnit,'Cannot save, try in ' +
                                               inttostr(trunc(Random_Interval/SECOND_MUTLIPLIER)) + ' Sec');
     end;
  end else begin
    // No Client.. Just reset the timer
    if DebugAutoSave then
       LogUtil.LogMsg(lmDebug,AutoSaveUnit,'No Client file open');
    ResetAutoSave;
  end;
end;

procedure TfrmMain.UpdateActions;
var HadMenu : Boolean;
begin
  inherited;
  
  if FLastActiveMDIChild2 <> FLastActiveMDIChild then
  begin
    if Assigned(FLastActiveMDIChild2) then
      if FLastActiveMDIChild2.HandleAllocated then
       if (FLastActiveMDIChild2 is TfrmCoding) and (not (csDestroying in FLastActiveMDIChild2.ComponentState)) then
         TfrmCoding(FLastActiveMDIChild2).CloseSuggMemPopup();

     FLastActiveMDIChild2 := FLastActiveMDIChild;
     LockMainForm;
     try
     HadMenu := rztCoding.Visible or rztBudget.Visible;

     if Assigned(FLastActiveMDIChild) then
        if FLastActiveMDIChild is TfrmCoding then
        begin
          rztCoding.Visible := True;
          rztBudget.Visible := False;
          UpdateMF.UpdateSortByMenu;
        end else if FLastActiveMDIChild is tfrmBudget then
        begin
           rztCoding.Visible := False;
           rztBudget.Visible := True;
        end else
        begin
           rztCoding.Visible := False;
           rztBudget.Visible := False;
        end
     else begin
        rztCoding.Visible := False;
        rztBudget.Visible := False;
     end;
     if HadMenu <> (rztCoding.Visible or rztBudget.Visible) then begin
        RepositionLogos(self);
        HadMenu := true;
     end else HadMenu := False;

     finally
       UnlockMainForm;
     end;
     //Update;
     if HadMenu then // menu Changed
     if assigned(FLastActiveMDIChild) then begin
        FLastActiveMDIChild.Invalidate; // repaint it..
     end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMain.GetTabIndex(aTabWindow : TRzTabControl; aMDIIndex: integer): integer;
var
  TabIndex : integer;
begin
  Result := -1;

  if (aMDIIndex > MDIChildSortedList.count-1) then
    Exit;

  for TabIndex := 0 to aTabWindow.Tabs.Count-1 do
  begin
    if (aTabWindow.Tabs[TabIndex].Caption = MDIChildSortedList.Strings[aMDIIndex]) then
    begin
      Result := TabIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.SetActiveMDI(aTabWindow: TRzTabControl; aTabIndex: integer);
var
  MDIIndex : integer;
begin
  for MDIIndex := 0 to MDIChildSortedList.Count-1 do
  begin
    if (aTabWindow.Tabs[aTabIndex].Caption = MDIChildSortedList.Strings[MDIIndex]) then
    begin
      fMDIChildSortedIndex := MDIIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.RemoveMDI(aMDIindex : integer);
begin
  MDIChildSortedList.Delete(aMDIindex);
  if fMDIChildSortedIndex > (MDIChildSortedList.Count-1) then
    fMDIChildSortedIndex := (MDIChildSortedList.Count-1);
end;

//------------------------------------------------------------------------------
procedure TfrmMain.NextSortedMDI();
begin
  if MDIChildSortedList.Count < 2 then
    Exit;

  if (fMDIChildSortedIndex < (MDIChildSortedList.Count-1)) then
    fMDIChildSortedIndex := fMDIChildSortedIndex + 1
  else
    fMDIChildSortedIndex := 0;

  ActivateMDIChild(fMDIChildSortedIndex);
end;

//------------------------------------------------------------------------------
procedure TfrmMain.PrevSortedMDI();
begin
  if MDIChildSortedList.Count < 2 then
    Exit;

  if (fMDIChildSortedIndex > 0) then
    fMDIChildSortedIndex := fMDIChildSortedIndex - 1
  else
    fMDIChildSortedIndex := MDIChildSortedList.Count - 1;

  ActivateMDIChild(fMDIChildSortedIndex);
end;

//------------------------------------------------------------------------------
procedure TfrmMain.ActivateMDIChild(aMDIIndex: integer);
var
  obj : TObject;
begin
  obj := TObject(MDIChildSortedList.Objects[aMDIIndex]);
  if obj is TForm then
  begin
    TForm(obj).BringToFront;

    if (obj is TfrmCoding) then
      TfrmCoding(obj).ActivateCurrentTabUsingMDI(aMDIIndex);

    if (obj is TfrmBudget) then
      TfrmBudget(obj).ActivateCurrentTabUsingMDI(aMDIIndex);

    if (obj is TfrmClientHomePage) then
    begin
      TfrmClientHomePage(obj).ActivateCurrentTabUsingMDI(aMDIIndex);

      if assigned(AdminSystem) then
        if assigned(frmLEFeedback) then
          frmLEFeedback.Show;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.UpdateTabs(aTabWindow : TRzTabControl; aActionedPage: string = '');
var
  TabIndex, StrPos : Integer;
  MDIIndex : integer;
  TempStr : string;
  TabList : TStringList;
  TabItem : TRzTabCollectionItem;
  CurMDIIndex : integer;
  ActiveCaption : string;
  PreviousStr : string;
  ClientManagerIndex : integer;
begin
  fMDIChildSortedIndex := 0;
  MDIChildSortedList.Clear;
  TabList := TStringList.Create;
  try
    aTabWindow.TabIndex := -1;
    for TabIndex := Pred(aTabWindow.Tabs.Count) downto 0 do
      aTabWindow.Tabs.Delete(TabIndex);

    // Build Internal Tab List from Valid MDIChildren windows and save active window
    // Re Build Global MDI List from current MDIChildren
    ClientManagerIndex := -1;
    for MDIIndex := 0 to Pred(MDIChildCount) do
    begin
      if (MDIChildren[MDIIndex].Caption = aActionedPage) then
        continue;

      if ((MDIChildren[MDIIndex] is TfrmCoding) or
          (MDIChildren[MDIIndex] is TfrmBudget) or
          (MDIChildren[MDIIndex] is TfrmClientHomePage)) then
      begin
        // Note: only replace the first &, the remaining &s are output normally anyway
        TempStr := StringReplace(MDIChildren[MDIIndex].Caption, '&', '&&', []);
        StrPos := Pos('Code Entries', TempStr);
        if StrPos > 0 then
          TempStr := Copy(TempStr, 14, Length(TempStr))
        else
        begin
          StrPos := Pos('Edit Budget', TempStr);
          if StrPos > 0 then
            TempStr := Copy(TempStr, 13, Length(TempStr));
        end;
        TabList.AddObject(TempStr, MDIChildren[MDIIndex]);
      end
      else
        TempStr := MDIChildren[MDIIndex].Caption;

      if (MDIChildren[MDIIndex] is TfrmClientManager) then
      begin
        ClientManagerIndex := MDIIndex;
        Continue;
      end;

      if MDIChildren[MDIIndex].Active then
        ActiveCaption := MDIChildren[MDIIndex].Caption;

      MDIChildSortedList.AddObject(TempStr, MDIChildren[MDIIndex]);
    end;

    // Sort Internal Tab List and then remove duplicates using Caption Names
    PreviousStr := '';
    TabList.CaseSensitive := true;
    TabList.Sort;
    for TabIndex := 0 to Pred(TabList.Count) do
    begin
      if (PreviousStr = TabList.Strings[TabIndex]) and
         (TabIndex > 0) then
        continue;

      TabItem := aTabWindow.Tabs.Add;
      TabItem.Caption := TabList.Strings[TabIndex];
      TabItem.Tag := Integer(TabList.Objects[TabIndex]);
      PreviousStr := TabItem.Caption;
    end;
    aTabWindow.TabIndex := -1;

    // Sort Global Internal MDI List and then remove duplicates using Caption Names
    MDIChildSortedList.CaseSensitive := true;
    MDIChildSortedList.Sort;

    if ClientManagerIndex > 0 then
      MDIChildSortedList.AddObject(MDIChildren[ClientManagerIndex].Caption, MDIChildren[ClientManagerIndex]);

    PreviousStr := '';
    for CurMDIIndex := MDIChildSortedList.Count-1 downto 0 do
    begin
      if (PreviousStr = MDIChildSortedList.Strings[CurMDIIndex]) and
         (CurMDIIndex < (MDIChildSortedList.Count-1)) then
        MDIChildSortedList.Delete(CurMDIIndex)
      else
        PreviousStr := MDIChildSortedList.Strings[CurMDIIndex];
    end;

    // Set Active Page
    for CurMDIIndex := 0 to MDIChildSortedList.Count-1 do
    begin
      if (TForm(MDIChildSortedList.Objects[CurMDIIndex]).Caption = ActiveCaption) then
        fMDIChildSortedIndex := CurMDIIndex;
    end;
  finally
    TabList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMain.UpdateAllWindowTabs(Sender:TObject; aActionedPage: string = '';Destroying:Boolean=False);
var
  MDIIndex : Integer;
begin
  // Updates all the window Tabs
  for MDIIndex := 0 to Pred(MDIChildCount) do
  begin
    if (MDIChildren[MDIIndex].caption = aActionedPage) then
      continue;

    if (MDIChildren[MDIIndex] is TfrmCoding) then
      TfrmCoding(MDIChildren[MDIIndex]).UpdateTabs(fMDIChildSortedIndex, aActionedPage);

    if (MDIChildren[MDIIndex] is TfrmBudget) then
      TfrmBudget(MDIChildren[MDIIndex]).UpdateTabs(fMDIChildSortedIndex, aActionedPage);

    if (MDIChildren[MDIIndex] is TfrmClientHomePage) then
      TfrmClientHomePage(MDIChildren[MDIIndex]).UpdateTabs(fMDIChildSortedIndex, aActionedPage);
  end;

  // Now that the Tabs are updated send the sorted index to each MDI Child with tabs
  // to be used when menu is selected
  for MDIIndex := 0 to Pred(MDIChildSortedList.Count) do
  begin
    if (MDIChildSortedList.Strings[MDIIndex] = aActionedPage) then
      continue;

    if (MDIChildSortedList.Objects[MDIIndex] is TfrmCoding) then
      TfrmCoding(MDIChildSortedList.Objects[MDIIndex]).MDIChildSortedIndex := MDIIndex;

    if (MDIChildSortedList.Objects[MDIIndex] is TfrmBudget) then
      TfrmBudget(MDIChildSortedList.Objects[MDIIndex]).MDIChildSortedIndex := MDIIndex;

    if (MDIChildSortedList.Objects[MDIIndex] is TfrmClientHomePage) then
      TfrmClientHomePage(MDIChildSortedList.Objects[MDIIndex]).MDIChildSortedIndex := MDIIndex;
  end;

  if Destroying then
  begin
    if ((LastActiveMDIChild2 is TfrmCoding) or
        (LastActiveMDIChild2 is TfrmBudget) or
        (LastActiveMDIChild2 is TfrmClientHomePage)) then
      FLastActiveMDIChild2 := Nil;
  end;
end;

procedure TfrmMain.UpdateWindowsAfterChartRefresh;
begin
  SendCmdToAllCodingWindows( ecRecodeTrans);
end;

procedure TfrmMain.viaBankLinkOnline1Click(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.tmAutoSaveTimer(Sender: TObject);
begin
  TryAutoSave;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.ResetAutoSave;
begin
   //set auto save interval back to default and clear outstanding flag
   if Assigned(AdminSystem) then
      tmAutoSave.Interval := (Globals.PRACINI_AutoSaveTime * AutoSaveMultiplier) //convert to milliseconds
   else
      tmAutoSave.Interval := (Globals.INI_AutoSaveTime * AutoSaveMultiplier); //convert to milliseconds

   tmAutoSave.Enabled := tmAutoSave.Interval <> 0;
   AutoSaveUtils.AutoSaveInUse := tmAutoSave.Enabled;
   if DebugAutoSave then
      LogUtil.LogMsg(lmDebug,AutoSaveUnit,'Reset to ' + intToStr(tmAutoSave.Interval) + 'ms');
   //clear outstanding auto save flag
   AutoSaveOutstanding := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMain.DoAutoSave: Boolean;
//auto save the currently opened file, no need if file is read only
const
  ThisMethodName = 'DoAutoSave';
var
  S : String;
begin
  Result := False;
  AutoSaveUtils.DisableAutoSave;
  try
    //check the CRC to see if anything has changed
    MyClient.clFields.clCurrent_CRC := MyClient.GetCurrentCRC;

    if (MyClient.clFields.clCurrent_CRC <> MyClient.clFields.clLast_Auto_Save_CRC) then
    begin
      if MyClient.clFields.clFile_Read_Only then begin
         if DebugAutoSave then
            LogUtil.LogMsg(lmDebug,AutoSaveUnit,'Client file is read only');
      end else begin

        S := MainStatus.Panels[PANELMSG].Text;
        MainStatus.Panels[PANELMSG].Text := 'Auto saving...';

        MyClient.AutoSave;

        LogUtil.LogMsg(lmInfo, UnitName, Format('%s: Client File %s Saved', [ ThisMethodName, MyClient.clFields.clCode ]));
        MainStatus.Panels[PANELMSG].Text := S;
        Result := True;
      end;


    end else begin
      if DebugAutoSave then
         LogUtil.LogMsg(lmDebug,AutoSaveUnit,'No Client file change');
    end;
    //Reset the timer interval
    ResetAutoSave;
  finally
    EnableAutoSave;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.actClientManagerExecute(Sender: TObject);
begin
  StopAutoSaveTimer;
  ApplicationUtils.DisableMainForm;
  try
    ClientManagerFrm.DoClientManager(Self.Left, Self.Top, Self.Height, Self.Width);
  finally
    ApplicationUtils.EnableMainForm;
  end;
  RestartAutoSaveTimer;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.mniCFExportClick(Sender: TObject);
begin
  //if INI setting
  DoModalReport(REPORT_CASHFLOW_EXPORT, rdNone);
end;

procedure TfrmMain.mniPRExportClick(Sender: TObject);
begin
   DoModalReport(REPORT_PROFIT_EXPORT,rdNone);
end;

procedure TfrmMain.mniPromosClick(Sender: TObject);
var
  ShowForm : TPromoDisplayFrm;
begin
  if DisplayPromoContents.TotalContents > 0 then
  begin
    DisplayPromoContents.DisplayTypes := [ctUpgrade, ctMarketing, ctTechnical];
    DisplayPromoContents.ListValidContents;
    if DisplayPromoContents.Count > 0 then
    begin
      ShowForm := TPromoDisplayFrm.Create(Nil);
      try
        ShowForm.ShowModal;
      finally
        FreeAndNil(ShowForm);
      end;
    end;
  end;
end;

procedure TfrmMain.mniBalanceExportClick(Sender: TObject);
begin
  DoModalReport(REPORT_BALANCESHEET_EXPORT,rdNone);
end;

procedure TfrmMain.mnsSystemClientsClick(Sender: TObject);
begin
  ClientManagerFrm.DoGlobalClientSetup(Self, Self.Left, Self.Top, Self.Height, Self.Width);
end;

procedure TfrmMain.DoFileOpen;
begin
  OpenClient('');
  if Assigned( MyClient ) then
  begin
    MyClient.clFields.clLast_Auto_Save_CRC := MyClient.clFields.clCurrent_CRC;

    FormResize(Self);
    RefreshHomepage([HRP_Init]);

    if ClientHomePage <> nil then
      TfrmClientHomePage(ClientHomePage).LEFeedbackForm := TForm( frmLEFeedback );

    //Enable Report Run timer for books.
    //Is enabled for Practice when they start up
    if (not Assigned(AdminSystem)) then
      if (MyClient.clFields.clDownload_From = dlBankLinkConnect) then
         tmrReportRun.Enabled := True;
  end;
end;

procedure TfrmMain.DoOpenFromMRU( Sender : TObject);
begin
  OpenFromMRU(Sender);
  if Assigned( MyClient ) then
  begin
    MyClient.clFields.clLast_Auto_Save_CRC := MyClient.clFields.clCurrent_CRC;
    ClientManagerFrm.RefreshClientManager(MyClient.clFields.clCode);
  end;
  FormResize(Self);
  RefreshHomepage([HRP_Init]);

  //Enable Report Run timer for books.
  //Is enabled for Practice when they start up
  if (not Assigned(AdminSystem))
  and (Assigned(MyClient)) then
     if (MyClient.clFields.clDownload_From = dlBankLinkConnect) then
       tmrReportRun.Enabled := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMainFormCommand( command: byte; Modal: boolean);
begin
  DoMainFormCommand( Command, nil, Modal);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoMainFormCommand( command: byte; Sender : TObject; Modal: boolean);
//processes command from menu and toolbar
//not yet fully implemented for all items, is done here for commands that
//require the main form to be disabled so that application process messages
//doesnt cause problems

//the processing form is used so that the main form does not lose focus when
//DisableMainForm is used
   function TestPractiManSystem: Boolean;
   begin
      Result := True;
      if AdminSystem.fdFields.fdPractice_Management_System <> xcNA  then
         Exit; // Already set.
      HelpfulInfoMsg( 'A Practice Management system has not been selected.', 0);
      EditPracticeDetails(Self, True);

      Result := (AdminSystem.fdFields.fdPractice_Management_System <> xcNA);
   end;
var
  ProcessFrm : TdlgModalProcessor;
begin
  if Modal then
    ProcessFrm := TdlgModalProcessor.Create(Application)
  else
    ProcessFrm := nil;

  mfModalCommandResult := -1;
  AutoSaveUtils.DisableAutoSave;
  try
    if Modal then DisableMainForm;
    try
      if Assigned( ProcessFrm) then
      begin
        ProcessFrm.PopupParent := Screen.ActiveForm;
        ProcessFrm.PopupMode := pmExplicit;

        ProcessFrm.Show;
      end;

      case Command of
        mf_mcOpenFile : DoFileOpen;
        mf_mcCloseFile : begin
                          CloseClientHomePage;
                          FormResize(Self);
                         end;
        mf_mcNewFile : CreateClient(Self, true);
        mf_mcOpenFromMRU : DoOpenFromMRU( Sender);
        mf_mcSave : SaveClient(false);
        mf_mcSaveAs : SaveAs;
        mf_mcCheckIn         : Files.CheckIn(ftmFile);
        mf_mcGetOnline       : Files.CheckIn(ftmOnline);
        mf_mcSendClientFiles : Files.SendClientFiles('', ftmFile);
        mf_mcSendOnline      : Files.SendClientFiles('', ftmOnline);
        mf_mcAbandon : AbandonChanges(true);
        mf_mcExchangeRates: begin
          if MaintainExchangeRates then
            RefreshHomePage([HPR_ExchangeGainLoss_Rates]);
        end;
        mf_mcCoding : DoCoding;
        mf_mcHDE : DoHDE;
        mf_mcMDE : DoMDE;
        mf_mcBudgets : DoBudgets(tbZero);
        mf_mcCashJournals : EnterJournal(btCashJournals);
        mf_mcAccrualJournals : EnterJournal(btAccrualJournals);
        mf_mcOpeningBalanceJnls : EnterJournal( btOpeningBalances);
        mf_mcStockBalanceJnls : EnterJournal( btStockBalances);
        mf_mcStockJournals : EnterJournal(btStockJournals);
        mf_mcYearEndJournals : EnterJournal( btYearEndAdjustments);
        mf_mcGSTJournals   : EnterJournal(btGSTJournals);
        mf_mcOpeningBalances : EditOpeningBalances( MyClient);
       // mf_mcStockBalances : EditStockBalances( MyClient);
        mf_mcYearEnd : begin
           RunBalancesForwardWizard( MyClient);
           UPDATEMF.UpdateMenus;
        end;
        mf_mcClientDetails : DoClientDetails(Screen.ActiveForm);
        mf_mcClientNotes : DoClientDetails(Screen.ActiveForm, True);
        mf_mcAccountingSystem : begin
          DoAccountingSystem;
          UPDATEMF.UpdateMenus;
        end;
        mf_mcGSTDetails : DoEditGSTDetails;
        mf_mcGSTReturn  : DoGSTReturn;
        mf_mcMaintainChart : DoMaintainChart;
        mf_mcEditDivisions : DivisionFrm.EditDivisions;
        mf_mcEditSubGroups : SetupSubgroupsFrm.SetupSubGroups;
        mf_mcExportChartToMYOBEssentialsCashbook : ChartExportToMYOBEssentialsCashbook.DoChartExport(Screen.ActiveForm);
        mf_mcMaintainPayees : MaintainPayees(BKH_Payees);
        mf_mcmaintainJob:  MaintainJobHeadings;
        mf_mcMaintainBankAccounts : DoMaintainBankAccounts;
        mf_mcMaintainMems : MaintainMems;
        mf_mcLoadBasTemplate : DoLoadBasTemplate;
        mf_mcSaveBasTemplate : Template.SaveAsTemplate;
        mf_mcRefreshChart : DoRefreshChart;
        mf_mcExtract : DoExtract;
        mf_mcExportBNotesToFile : DoBNotesExport( ecDestFile);
        mf_mcExportBNotesToMail : DoBNotesExport( ecDestEmail);
        mf_mcImportBNotesFromFile : ImportBNotesFromFile(ecDestFile);
        mf_mcDoTasks : DoTasks;
        mf_mcClearTransferFlags : ClearTransferFlagsForPeriod;
        mf_mcSetTransferFlags : SetTransferFlagsForPeriod;
        mf_mcLockPeriod : DoLockPeriod;
        mf_mcUnlockPeriod : DoUnlockPeriod;
        mf_mcImportUpdateFile : ImportUpdateFile;
        mf_mcTransferEntries : TransferTempEntries;
        mf_mcPurgeEntries : PurgeEntries;
        mf_mcSynchronise : Synchronise;
        mf_mcAnnualGSTReport : DoAnnualGST_AU;
        mf_mcAnnualGSTReturn : DoAnnualGSTReturn_AU;
        mf_mcSys_MasterMems : DoMasterMems;
        mf_mcSys_AttachAccounts : AttachNewBankAccounts;
        mf_mcOffsiteBackup : ForceOffsiteBackup;
        mf_mcOffsiteRestore : DoOffsiteRestore;
        mf_mcExportWebX : DoBNotesExport(ecDestWebX);
        mf_mcImportWebX : ImportBNotesFromFile(ecDestWebX);
        mf_mcViewDiskDocs :  BillingDocReaderFrm.SelectReport;
        mf_mcExportCharges: if TestPractiManSystem then begin
          case AdminSystem.fdFields.fdPractice_Management_System of
            xcAPS    : IncUsage('Export Charges APS');
            xcHandi  : IncUsage('Export Charges HandiLedger');
            xcMYOB   : IncUsage('Export Charges MYOB');
            xcMYOBAO : IncUsage('Export Charges MYOBAO');
            xcOther  : IncUsage('Export Charges Other');
          end;
          DoExportCharges(AdminSystem.fdFields.fdPractice_Management_System);
        end;
        mf_mcClearNotes : DeleteNotesForPeriod;
        mf_mcCombineAccounts : DoCombineAccounts;
        mf_mcCombineManualAccounts : DoCombineManualAccounts;
        mf_mcQueryUncoded : SendUncodedTransactions;
        mf_mcListCharges: if TestPractiManSystem then
          DoListChargesReport(AdminSystem.fdFields.fdPractice_Management_System);
        mf_mcMaintainFileCostCodes: if TestPractiManSystem then
          DoMaintainCharges(AdminSystem.fdFields.fdPractice_Management_System);

        mf_DoBulkExtract :  BulkExtractfrm.DoBulkExtract('',False);
        mf_DoBulkClear   :  BulkExtractfrm.DoBulkExtract('',True);
        mf_FindAndReplace : FindReplacefrm.FindAndReplace;
        mf_mcSystemOptions : begin
          ShowOptions;
            if not AutoSaveOutstanding then
                 ResetAutoSave;
        end;
        mf_mcTrialBalance : begin
             TrialBalanceOptionsDlg.UpdateTrialBalanceReportOptions(MyClient);
        end;
        mf_mcViewCashJournals : ViewJournals(btCashJournals);
        mf_mcViewAccrualJournals : ViewJournals(btAccrualJournals);
        mf_mcTransactionsToBankLinkOnline: ShowExportTransactionsDialog;
        mf_mcExchangeGainLossWizard:
        begin
          RunExchangeGainLossWizard(MyClient);
          RefreshHomepage;
        end;
      end;

      //reset auto save time after the following actions
      if Command in ModalFileCommands then
        ResetAutoSave;

    finally
      if Modal then EnableMainForm;
    end;

    // Broadcast system for main menu notifications
    BroadcastMessage(UM_MAINFORM_MODALCOMMAND, command);
  finally
    ProcessFrm.Free;
    if not Globals.ApplicationIsTerminating then // causes AV if shutting down
      EnableAutoSave;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure TfrmMain.bkShowCM(var msg: TMessage);
begin
  frmMain.Enabled := True;
  if actClientManager.Visible then
    actClientManager.Execute;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.DoTasks;
begin
  if Assigned( MyClient) then
    ToDoHandler.MaintainToDoItems( MyClient.clFields.clCode, false);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.actSendToFileExecute(Sender: TObject);
begin
  IncUsage('Check Out');
  if (ActiveMDIChild is TfrmClientManager) and CheckOutEnabled then
    ClientManagerCheckOut
  else
    DoMainFormCommand( mf_mcSendClientFiles);
end;

procedure TfrmMain.actSendViaEmailExecute(Sender: TObject);
begin
  if (ActiveMDIChild is TfrmClientManager) and SendFilesEnabled then
    ClientManagerSend
  else
    SendClientFileTo('');
end;

procedure TfrmMain.actSendViaOnlineExecute(Sender: TObject);
begin
  if not ProductConfigService.IsPracticeActive then
    Exit;

  IncUsage('Check Out');
  if (ActiveMDIChild is TfrmClientManager) and CheckOutEnabled then
    ClientManagerSendOnline
  else
    DoMainFormCommand( mf_mcSendOnline);
end;

procedure TfrmMain.actTasksExecute(Sender: TObject);
begin
  DoMainFormCommand( mf_mcDoTasks);
end;

procedure TfrmMain.CreateAnalysisCodingTest1Click(Sender: TObject);
var
  i : integer;
  pT : pTransaction_Rec;
begin
  if not Assigned( MyClient) then
    exit;

  for i := 0 to 100 do
  begin
    pT := MyClient.clBank_Account_List.Bank_Account_At(0).baTransaction_List.Transaction_At(i);

    pT^.txType := i;
    pT^.txAnalysis := GenUtils.PadStr( inttostr( i + 100), 12, ' ');
  end;

  ShowMessage('Done');
end;



procedure TfrmMain.mniStatisticsClick(Sender: TObject);
begin
  StatsFrm.ShowStatistics;
end;

{procedure TfrmMain.mniStockBalancesClick(Sender: TObject);
begin
  IncUsage('Stock Balances');
  DoMainFormCommand( mf_mcStockBalances);
end;}

procedure TfrmMain.mniStockBalancesJnlsClick(Sender: TObject);
begin
  IncUsage('Non-Transferring Journals - Stock Balances');
  DoMainFormCommand( mf_mcStockBalanceJnls);
end;

procedure TfrmMain.mniRaiseExceptionClick(Sender: TObject);
begin
  Raise Exception.Create( 'Test Exception raised');
end;

procedure TfrmMain.mniAssertClick(Sender: TObject);
begin
  ASSERT(false);
end;

procedure TfrmMain.mniMissingChequesClick(Sender: TObject);
begin
  DoModalReport( Report_Missing_Cheques, rdNone);
end;

procedure TfrmMain.mniBKHelpClick(Sender: TObject);
begin
{$IFDEF SmartLink}
  if Assigned( CurrUser) then
    if (not CurrUser.HasRestrictedAccess) then
{$ENDIF}
  Application.HelpContext(0);
end;

procedure TfrmMain.WMENTERMENULOOP(var Msg: TWMEnterMenuLoop);
begin
  AutoSaveUtils.DisableAutoSave;
  inherited;
end;

procedure TfrmMain.WMEXITMENULOOP(var Msg: TWMExitMenuLoop);
begin
  AutoSaveUtils.EnableAutoSave;
  inherited;
end;

procedure TfrmMain.mnsSpendingbyPayeeClick(Sender: TObject);
begin
  DoModalReport(REPORT_PAYEE_SPENDING,rdNone);
end;

procedure TfrmMain.mnsJobReportClick(Sender: TObject);
begin
  DoModalReport(Report_Job_Summary, rdNone);
end;

procedure TfrmMain.mniBackupClick(Sender: TObject);
begin
  IncUsage('Backup');
  DoMainFormCommand( mf_mcOffsiteBackup);
end;

procedure TfrmMain.ForceOffsiteBackup;
begin
  if Assigned( MyClient) then
  begin
    SaveClient(false);
    DoOffsiteBackup( MyClient.clFields.clCode, True);
    if Globals.mfModalCommandResult = 1 then
    begin
       MyClient.clFields.clTemp_CRC_at_Last_Backup := MyClient.clFields.clCRC_at_Last_Save;
    end;
  end;
end;

procedure TfrmMain.mniResetFingerTipsLinksClick(Sender: TObject);
{$IFDEF SmartLink}
var
  aMSg : string;
begin
  FingerTipsInterface.RefreshDocumentLinks( MyClient);
  HelpfulInfoMsg( aMsg, 0);
{$ELSE}
begin;

{$ENDIF}
end;

procedure TfrmMain.mniRestoreClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcOffsiteRestore);
end;

procedure TfrmMain.mnsImportBNotesClick(Sender: TObject);
begin
   IncUsage('Notes Import');
  DoMainFormCommand( mf_mcImportBnotesFromFile);
end;

procedure TfrmMain.mniTutorialsTOCClick(Sender: TObject);
begin
  if BKFileExists(ExtractFilePath(Application.ExeName) + HelpFileName) then
    Application.HelpFile := TutorialsFile;
  bkHelp.BKHelpShowContext(HH_DISPLAY_TOC);
  if BKFileExists(ExtractFilePath(Application.ExeName) + HelpFileName) then
    Application.HelpFile := ExtractFilePath(Application.ExeName) + HelpFileName;
end;

procedure TfrmMain.tbBudgetHelpClick(Sender: TObject);
begin
  BKHelpShowContext( BKH_Chapter_9_Budgets);
end;

procedure TfrmMain.tbCodingCloseClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecQuit);
end;

procedure TfrmMain.tbCodingHelpClick(Sender: TObject);
begin
  BKHelpShowContext( BKH_Using_the_Code_Entries_Screen);
end;

procedure TfrmMain.tmrReportRunTimer(Sender: TObject);
begin
  tmrReportRun.Enabled := false;
  UpgradeHelper.ReportFirstRun(self.Handle);
end;

procedure TfrmMain.tbGenerateClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbGenerate);
end;

procedure TfrmMain.tbSmoothClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbSmooth);
end;

procedure TfrmMain.tbAverageClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbAverage);
end;

procedure TfrmMain.tbCopyClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbCopy);
end;

procedure TfrmMain.tbIncreaseClick(Sender: TObject);
begin
  DoBudgetTBarCommand( ecbPercentageChange);
end;

procedure TfrmMain.tbJobClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecLookupJobs);
end;

procedure TfrmMain.tbSplitClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbSplit);
end;

procedure TfrmMain.tbBudgetHideClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbHideUnused);
end;

procedure TfrmMain.tbBudgetShowClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbShowAll);
end;

procedure TfrmMain.tbBudgetChartClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbChart);
end;

procedure TfrmMain.tbBudgetCloseClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbQuit);
end;

procedure TfrmMain.tbBudgetImportClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbImport);
end;

procedure TfrmMain.tbBudgetExportClick(Sender: TObject);
begin
  DoBudgetTBarCommand(ecbExport);
end;

procedure TfrmMain.tbChartClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecChart);
end;

procedure TfrmMain.tbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.tbPayeeClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecPayee);
end;

procedure TfrmMain.tbMemoriseClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecMemorise);
end;

procedure TfrmMain.tbNewClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecNewJournal);
end;

procedure TfrmMain.tbOnlineClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(ProductConfigService.BanklinkOnlinePracticeURL), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.tbDissectClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecDissect);
end;

procedure TfrmMain.tbSuperClick(Sender: TObject);
begin
  DoCodingTBarCommand( ecSuper);
end;

procedure TfrmMain.tbGotoClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecGoto);
end;

procedure TfrmMain.tbRecommendedMemorisationsClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecRecommendedMems);
end;

procedure TfrmMain.tbRepeatClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecRepeat);
end;

procedure TfrmMain.tbFindClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecFind);
end;

procedure TfrmMain.tbUPIClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddOutChq);
end;

procedure TfrmMain.rzToolbarsResize(Sender: TObject);
begin
  bkArrangeToolBars;
end;

procedure TfrmMain.tbQueryClick(Sender: TObject);
begin
  IncUsage('Send Query');
  DoCodingTBarCommand(ecQueryUncoded);
end;

// We need to really disable the timer when performing operations
// that may result in a change of client file - AVs could happen
// if autosave occurs during an open of a new client

procedure TfrmMain.StopAutoSaveTimer;
begin
  SavedAutoSaveEnabled := tmAutoSave.Enabled;
  SavedAutoSaveInterval := tmAutoSave.Interval;
  tmAutoSave.Enabled := False;
  if Assigned(MyClient) then
    SavedAutoSaveClient := MyClient.clFields.clCode
  else
    SavedAutoSaveClient := '';
end;

procedure TfrmMain.RestartAutoSaveTimer;
begin
  if SavedAutoSaveEnabled then
  begin
    tmAutoSave.Interval := SavedAutoSaveInterval;
    tmAutoSave.Enabled := SavedAutoSaveEnabled;
  end;
  if Assigned(MyClient) and (MyClient.clFields.clCode <> SavedAutoSaveClient) then
    ResetAutoSave;
end;

// Acclipse Export
procedure TfrmMain.mniExportWebXClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcExportWebX);
end;

// Acclipse Import
procedure TfrmMain.mniImportWebXClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcImportWebX);
end;

procedure TfrmMain.mniFindandReplaceClick(Sender: TObject);
begin
  IncUsage('Find and Replace');
  DoMainFormCommand( mf_FindAndReplace);
end;

procedure TfrmMain.mniForexReportClick(Sender: TObject);
begin
  DoModalReport( REPORT_FOREIGN_EXCHANGE, rdNone );
end;

procedure TfrmMain.mniCustomDocsClick(Sender: TObject);
begin
  IncUsage('Custom Documents');
  AddCustomDocument;
end;

procedure TfrmMain.ProcessDDEMacro( var Macro : string);
//processes a macro command contained in Macro
//command contains a keyword and some parameters, commands are very simple at this stage
//this procedure can be called directly or called with a cached command if the
//command was received during startup
//
//parameters:  Macro : command string to process

  function CommandIs( Keyword : string) : boolean;
  begin
    result := Pos( '[' + Keyword, lowercase(Macro)) = 1;
  end;

const
  CheckInKeyword = 'checkin(';
  CheckInKeywordLength = Length(CheckInKeyword);

  ImportKeyword = 'import(';
  ImportKeywordLength = Length(ImportKeyword);

  HelloKeyword = 'sayhello';


  function DoImportTrf : Boolean;
  var LWrapper : Filewrapper.TWrapper;
      Filename : string;
      procedure FailImport (Reason : String);
      begin
         HelpfulInfoMsg(TProduct.BrandName + ' can not import the file at this stage'#13'because '+ Reason,0);
      end;
  begin
     Result := False;
     //command will be in the format   import("filename")
     if (Not Assigned( AdminSystem))
     and (not PRACINI_ShowImportExportInOffsite) then begin
         FailImport('the current configuration does not allow it');
         exit;
     end;
     Filename := Copy( Macro, ImportKeywordLength + 3, Length( Macro) - ImportKeywordLength - 5);  //-3 =  [(" + ")]
     if Filewrapper.GetWrapper(Filename,LWrapper) then begin
        if assigned(MyClient) then begin
            if Not Sametext( MyClient.clWas_Code,LWrapper.wCode) then begin
               // Need to log out first...
               FailImport('client ' + MyClient.clWas_Code +
                          ' is open,'#13'try later.') ;
               exit;
            end;
        end else begin
           OpenClient( LWrapper.wCode, True);
        end;
        {  Case 4462: Would have prompted...  }
        if NOT assigned(MyClient) then begin
           //FailImport( LWrapper.wCode + ' does not open'  );
           exit;
        end;

        if not CloseMDIChildren then begin
           FailImport( 'a Code Entries/Budget screen is open');
           exit;
        end;
        Sleep(500);
        DDE_Filename_To_Process := Filename;
        RefreshHomepage([HRP_Init]);
        DoMainformCommand(mf_mcImportBNotesFromFile, True);
        DDE_Filename_To_Process := '';
        Result := True;
     end else begin
        FailImport( Filename + #13'does not open' );
     end;
  end;
var
  Filename : string;
  Code : string;
  CheckInAllowed, ImportOK : boolean;
  F: Forms.TForm;
begin
  if Macro = '' then
    Exit;

  ProcessingDDECommand := true;
  Application.ProcessMessages;
  Sleep(500);
  Application.ProcessMessages;
  DisableMainForm;
  try
    if CommandIs( CheckInKeyword) then
    begin
      //command will be in the format  Checkin("filename")
      Filename := Copy( Macro, CheckInKeywordLength + 3, Length( Macro) - CheckInKeywordLength - 5);  //-3 =  [(" + ")]
      Globals.INI_CheckInDir := ExtractFilePath( Filename);
      Code := Uppercase(ExtractFileName( Filename));
      Code := '"' + Copy( Code, 1, Pos( Globals.FILEEXTN, Code) - 1) + '"';

      IncUsage('Check In DDE ');                            
      //check that user has rights to do this
      if Assigned( AdminSystem) then
      begin
        CheckInAllowed := CurrUser.CanAccessAdmin or ((not PRACINI_OSAdminOnly) and (not CurrUser.HasRestrictedAccess));
      end
      else
        //no admin system, checkin always allowed
        CheckInAllowed := true;                     

      //call check in using a filename rather than a code
      if CheckInAllowed then
        Files.CheckInRemoteClient( filename)
      else
      begin
        UPDATEMF.UpdateMenus;
        UPDATEMF.UpdateSystemMenus;
        HelpfulErrorMsg( 'You do not have sufficient rights to Update a file,' + #13 +
         'please see your ' + TProduct.BrandName + ' Administrator.',0);
        if Assigned(AdminSystem) then
          DoClientManager(0,0,0,0);
      end;
    end                                            
    else
    if CommandIs( ImportKeyword) then
    begin
       // import a TRF file..
       IncUsage('Notes DDE Import');
       F := ActiveMDIChild;
       ImportOK := False;
       if CurrUser.CanAccessAdmin or
          (Assigned(AdminSystem) and (not CurrUser.HasRestrictedAccess)) or
          ((not Assigned(AdminSystem)) and PRACINI_ShowImportExportInOffsite) then
         ImportOK := DoImportTRF
       else
         HelpfulErrorMsg( 'You do not have sufficient rights to Import a ' + bkBranding.NotesProductName + ' file,' + #13 +
          'please see your ' + TProduct.BrandName + ' Administrator.',0);
       if Assigned(AdminSystem) then
         DoClientManager(0,0,0,0);
       if (not (F is TfrmClientManager)) or ImportOK then
         RefreshHomepage([HRP_Init]);
    end
    else
    if CommandIs( HelloKeyword) then
    begin
      ShowMessage('Hello');
    end;
  finally
    ProcessingDDECommand := false;
    EnableMainForm;
  end;
end;

procedure TfrmMain.bk5winExecuteMacro(Sender: TObject; Msg: TStrings);
//handle a macro command contained in line 0 of the TStrings structure
//parameters:  Sender : Object issueing the command (TDDEServerConv)
//             Msg : TString structure with list of macro commands
var
  MacroCommand : string;
  SaveStatus: integer;
  Animation: Boolean;

  function GetAnimation: Boolean;
  var
    Info: TAnimationInfo;
  begin
    Info.cbSize := SizeOf(TAnimationInfo);
    if SystemParametersInfo(SPI_GETANIMATION, SizeOf(Info), @Info, 0) then
      Result := Info.iMinAnimate <> 0 else
      Result := False;
  end;

  procedure SetAnimation(Value: Boolean);
  var
    Info: TAnimationInfo;
  begin
    ZeroMemory(@Info,SizeOf(Info));
    Info.cbSize := SizeOf(TAnimationInfo);
    BOOL(Info.iMinAnimate) := Value;
    SystemParametersInfo(SPI_SETANIMATION, SizeOf(Info), @Info, 0);
  end;
begin
  if Msg.Text = '' then
    exit;

  //check to see if we are doing any modal tasks at the moment
  if not ApplicationUtils.CanProcessCommands then
    Exit;

  if ApplicationIsStarting then
  begin
    //INI_mfStatus gets reset on Application.Restore
    SaveStatus := INI_mfStatus;

    if (Length(Msg[0]) > 0) and
       (Application.MainFormOnTaskBar) then
    begin
      Animation := GetAnimation;
      if Animation then SetAnimation(False);
      ShowWindow(Application.Mainform.Handle, CmdShow);
      if Animation then SetAnimation(True);

      Application.MainForm.Show;
    end
    else
      Application.Restore;

    INI_mfStatus := SaveStatus;
    if INI_mfStatus = 3 then
      Application.MainForm.WindowState := wsMaximized;
  end;

  MacroCommand := Msg[0];

  //if application is in startup mode then hold the dde requests until after login
  //has succeeded
  Globals.DDE_Macro_To_Process := MacroCommand;

  if not ApplicationIsStarting then
  begin
    ProcessDDEMacro( Globals.DDE_Macro_To_Process);
  end;
end;

(*
procedure TfrmMain.bkDirRequest(var msg: TMessage); //message BK_DIR_REQUEST;
//responds to a BK_DIR_REQUEST message recieved from bkHandlr.exe
var
  CopyData: TCopyDataStruct;  // WM_COPYDATA data structure
  DataSize: Integer;      // size of storage required for all parameters
  Data: PChar;                // pointer to parameter storage
  RequesterHWND : THandle;
  DataToSend : string;
begin
  RequesterHWND := Msg.WParam;
  Msg.Result := -2;

  if RequesterHWND <> 0 then
  begin
    //see if we can process commands at this time, if not send <busy> as path
    if true then//ApplicationUtils.CanProcessCommands then
    begin
      DataToSend := Globals.ExecDir;

      //send a wm_copy_data message back to caller
      DataSize := Length( DataToSend) + 1;
      Data := StrAlloc(DataSize);
      try
        StrPCopy( Data, DataToSend);
        // Now allocate data storage and copy parameters into it
        CopyData.lpData := Data;
        CopyData.cbData := DataSize;
        CopyData.dwData := Msg.WParam;  //handle of calling app

        //send the copy data message back to bkhandlr and wait for response
        if SendMessage( RequesterHWND, WM_COPYDATA, 0, LPARAM(@CopyData)) = 1 then
          Msg.Result := 1
        else
          Msg.Result := -1;
      finally
        StrDispose( Data);
      end;
    end
    else
      Msg.Result := 2;
  end;
end;

procedure TfrmMain.bkIsBusy(var msg: TMessage); //message bk_is_busy
begin
  if ApplicationUtils.CanProcessCommands then
    Msg.result := 1
  else
    Msg.result := 2;
end;
*)

procedure TfrmMain.DdeStatusPokeData(Sender: TObject);
//responds to commands from client with a status string
//this allow the calling app to display the application is busy message
//rather than displaying a modal dialog in this app
var
  PathFromClient : string;
begin
  if DdeStatus.Text = '' then
    exit;

  if pos( '?=', DdeStatus.Text) = 1 then
  begin
    //check that path from client is really this app
    PathFromClient := lowercase( Copy( DdeStatus.Text, 3, length( DdeStatus.Text)));
    if PathFromClient <> lowercase( Globals.ExecDir) then
    begin
      DdeStatus.Text := '<WRONG>';
      exit;
    end;

    //path matches, return status
    if ApplicationIsStarting then
      DdeStatus.Text := '<BUSYSTART>'
    else
    if ProcessingDDECommand then
      DdeStatus.Text := '<BUSYDDE>'
    else
    if (ApplicationUtils.CanProcessCommands) then
      DdeStatus.Text := '<OK>'
    else
      DdeStatus.Text := '<BUSY>';
  end;
end;

procedure TfrmMain.mniInstallCheckInExtnClick(Sender: TObject);
var
  filename : string;
begin
  filename := ExecDir + 'bkHandlerSetup.exe';

  if FileExists( filename) then
    ShellExecute(Handle,nil,pChar( filename), nil ,nil,SW_SHOWNORMAL)
  else
    HelpfulWarningMsg( 'Client File Handler setup not found.',0);
end;

procedure TfrmMain.mniJobsClick(Sender: TObject);
begin
  IncUsage('Jobs');
  DoMainFormCommand( mf_mcmaintainJob);
end;

procedure TfrmMain.tmProcessStartupCmdsTimer(Sender: TObject);
//put this on a timer so that the DDE check in message can be handled first
begin
  tmProcessStartupCmds.Enabled := false;
  frmMain.Enabled := True;

  //don't do anything if we have processed a DDE command
  if Globals.DDE_Macro_To_Process <> '' then
    Exit;

  if ( CurrUser.ShowCMOnOpen or Globals.SuperUserLoggedIn)
  and ( actClientManager.Visible) then
     actClientManager.Execute;
  //see if a default client file has been specified
  if Globals.StartupParam_Action <> 0 then begin
     case Globals.StartupParam_Action of
       sa_BulkExport:
       begin
         DoMainFormCommand(mf_DoBulkExtract);
       end;
       
       sa_Connect:
       begin
         tmrDataThread.Enabled := False;
         ProcessModalCmdWithDlg( mpcDoDownloadFromBConnect);
       end;

       sa_ExportTransactions:
       begin
         ExportTransactionsToBankLinkOnline;
       end;
     end;

     Close;
     Exit;
  end;


  if Globals.StartupParam_ClientToOpen <> '' then
  begin
    Files.OpenClient( StartupParam_ClientToOpen);
    RefreshHomepage([HRP_Init]);
  end
  //see if should display client manager

  else if ( CurrUser.ShowCMOnOpen or Globals.SuperUserLoggedIn)
       and ( actClientManager.Visible) then
  begin
    frmMain.Enabled := False;
    PostMessage( Self.Handle, BK_SHOWCM, 0, 0);
  end;

end;

procedure TfrmMain.tmrDataThreadTimer(Sender: TObject);
begin
  //CheckAvailableWebNotesData; // Not Polling...
  tmrDataThread.Enabled := False;
  (*
  tmrDataThread.Interval := PRACINI_Check_Data_Minutes * 60 * 1000;
  if Assigned(CurrUser) and (CurrUser.CanAccessAdmin) then
    DataThread := TDataThread.Create;
  *)  
end;

procedure TfrmMain.mniImportFromCSVClick(Sender: TObject);
begin
{$IFDEF CSVImport}
  if Assigned( myClient) then
  begin
    CloseAllCodingForms;
    CSVImportfrm.ImportFromCSVFile;
  end;
{$ENDIF}
end;

procedure TfrmMain.mniImportHSBCClick(Sender: TObject);
begin
  HSBCDemo.ImportHSBCDemoData;
end;

procedure TfrmMain.Viewdownloaddocuments1Click(Sender: TObject);
begin
  if (AdminSystem.fdFields.fdSystem_Report_Password <> '') and
     (not EnterPwdDlg.EnterPassword( 'Statements and Download Documents',
                                   AdminSystem.fdFields.fdSystem_Report_Password,
                                   0,
                                   pwdNormal,
                                   pwdHidePassword )) then
  begin
    HelpfulErrorMsg( 'A valid password is required to view this report.', 0);
    Exit;
  end;
  IncUsage('Stataments and Download Documents');
  DoMainFormCommand( mf_mcViewDiskDocs);
end;

//procedure TfrmMain.CRC1Click(Sender: TObject);
//begin
//   crctestfrm.TfrmCRCTest.Create( application).ShowModal;
//end;

procedure TfrmMain.mniAddManualClick(Sender: TObject);
begin
  IncUsage('Manual Entries');
  DoMainFormCommand( mf_mcMDE);
end;

procedure TfrmMain.mniUPIAddWithClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddOutWith);
end;

procedure TfrmMain.mniEntrieswithNotesClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecViewNotes);
end;

procedure TfrmMain.mniEntrieswithoutNotesClick(Sender: TObject);
begin
  DoCodingTBarCommand(ecViewNoNotes);
end;

procedure TfrmMain.mniExportChargesClick(Sender: TObject);
begin
  DoMainFormCommand(mf_mcExportCharges);
end;

procedure TfrmMain.mniExportdatatoBanklinkOnlineClick(Sender: TObject);
begin
  DoMainFormCommand(mf_mcTransactionsToBankLinkOnline);
end;

procedure TfrmMain.mniViewNotesOnlyClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecViewUnreadNotes);
end;

procedure TfrmMain.mniDeleteNotesClick(Sender: TObject);
begin
  DoMainFormCommand( mf_mcClearNotes);
end;

procedure TfrmMain.DoCombineAccounts;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
     CombineAccounts;
end;

procedure TfrmMain.DoCombineManualAccounts;
begin
   if not CloseMDIChildren then
     HelpfulErrorMsg( CANNOT_CLOSE_MDI_MSG, 0)
   else
     CombineManualAccounts;
end;

procedure TfrmMain.mniCombineAccountsClick(Sender: TObject);
begin
  IncUsage('Combine Bank Accounts');
  DoMainFormCommand( mf_mcCombineAccounts);
end;

procedure TfrmMain.mniCombineManualClick(Sender: TObject);
begin
  IncUsage('Combine Manual Bank Accounts');
  DoMainFormCommand( mf_mcCombineManualAccounts);
end;

procedure TfrmMain.mniUPIAddInitWithClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddInitWith);
end;

procedure TfrmMain.mniUPIAddInitDepClick(Sender: TObject);
begin
   DoCodingTBarCommand(ecAddInitDep);
end;

procedure TfrmMain.mniChangePasswordClick(Sender: TObject);
begin
  ChangeUserPassword;
end;

procedure TfrmMain.mniCheckForUpdatesClick(Sender: TObject);
begin
  UpgradeHelper.CheckForUpgrade_Offsite(Self.Handle, '', MyClient.clFields.clCountry);
  if Globals.ApplicationMustShutdownForUpdate then
    Close;
end;

(*
procedure TfrmMain.ThreadMessage(var Message: TMessage);
begin
  case Message.WParam of
    THREAD_DATA_AVAILABLE: begin
      SetDownloadAvailability(THREAD_DATA_AVAILABLE);
      // will restart the thread once we have downloaded or if disk number is updated
    end;
    THREAD_NOT_ONLINE: begin
      SetDownloadAvailability(THREAD_NOT_ONLINE);
      tmrDataThread.Enabled := True; // try again after a set period
    end;
    THREAD_NO_DATA: begin
      SetDownloadAvailability(THREAD_NO_DATA);
      tmrDataThread.Enabled := True; // try again after a set period
    end;
  end;
end;
*)

//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);
   DebugAutoSave := DebugUnit(AutoSaveUnit);

end.

