unit Globals;
//------------------------------------------------------------------------------
{
   Title:         Application global var's and constants

   Description:   Should be split into vars and const in seperate units

   Author:        Matthew Hopkins

   Remarks:

   Revisions:     Nov 2004 - Conditional compile LOOKUPDLL allows the bkLookup.dll file
                  to be compiled without linking in the whole system.

}
//------------------------------------------------------------------------------
{$IFDEF LOOKUPDLL}
interface

uses
  sysobj32,
  appuserobj,
  sysUtils,
  Forms,
  bkConst,
  IPClientLocking;

const

  SHORTAPPNAME        = BRAND_FULL_NAME;

  SYSTEMFILE          = 'SYSTEM';
  SYSFILENAME         = SYSTEMFILE+ '.DB';
  SYSLOCKNAME         = SYSTEMFILE+ '.$$$';
  SYSBACKNAME         = SYSTEMFILE+ '.BAK';
  SYSSAVEDNAME        = SYSTEMFILE+ '.SAV';

  PRACINI_TicksToWaitForAdmin = 30000;
  PRACINI_AlwaysReloadAdmin = false;
  PRACINI_DisableBankLRNCheck = true;
  PRACINI_ExtractDecimalPlaces = 4;

  INI_CustomColors = '';
  INI_MAX_EXTRACT_NARRATION_LENGTH = 200;
  BKCOLOR_CREAM       = $00F0FBFF;  //budgets, mems, payees

var
  DataDir : string;
  AdminSystem              : TSystemObj       = nil;
  GlobalAdminSnapshot      : TSystemObj       = nil;

  PRACINI_IPClientLocking_SwitchedOn : Boolean;
  PRACINI_IPClientLocking_UDP_Server_IP : string;
  PRACINI_IPClientLocking_UDP_Server_Port : integer;

  PRACINI_IPClientLocking_UDP_Client_Port : integer;
  PRACINI_IPClientLocking_UDP_BuffInitSize : integer;
  PRACINI_IPClientLocking_DiscoveryTimeOut : integer;
  PRACINI_IPClientLocking_UDPTimeOut : integer;
  PRACINI_IPClientLocking_LockTimeOut : integer;
  PRACINI_IPClientLocking_TCPTimeOut : integer;
  PRACINI_IPClientLocking_ProcessMessageDelay : integer;
  PRACINI_IPClientLocking_GROUP_ID : string;

type
  TBrandType = (btBankLink, btMYOBBankLink);

var
  ProductBrand: TBrandType = btMYOBBankLink;
  
implementation

initialization
   DataDir                   := '';  //will be passed in as a parameter

{$ELSE}

//------------------------------------------------------------------------------
//
//   MAIN GLOBALS CODE HERE...
//
//------------------------------------------------------------------------------

interface
uses
   forms,
   Windows,
   ovcDate,
   sysutils,
   clObj32,
{$IFNDEF TESTLOCKING}
   PrintMgrObj,
{$ENDIF}
   sysObj32,
   appUserObj,
   WinUtils,
   GlobalDirectories,
{$IFNDEF DLLONLY}
   OneInst,
{$ENDIF}
   Classes,
   Messages,
   IPClientLocking,
   bkConst;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
CONST
    {dates}
    BKDATEEPOCH           = 1970;
    BKDATEFORMAT          = 'dd/mm/yy';
    BKCENTURYWINDOW       = 30;        {19xx will be applied to dates until more than 30years less that today}

    BCONNECTNAME        = BRAND_SECURE;
    BConnectShort       = BRAND_SECURE_SHORT;
    BKBOOKSNAME         = BRAND_BOOKS;
    BKPRACTICENAME      = BRAND_PRACTICE;
    BANKLINK_ONLINE_NAME= BRAND_ONLINE;
{$IFDEF SmartLink}
    DocumentManagementSystemName = 'FingerTips';
{$ENDIF}
    {about pages}
{$IFNDEF SmartLink}
    COPYRIGHTNAME       = BRAND_COPYRIGHT;
{$ELSE}
    COPYRIGHTNAME       = 'Media Transfer Services';
{$ENDIF}

    {superuser}
    SUPERUSER           = 'BANKLNK5';
    SuperUserCode       = 'SUPERUSER';

    {filenames}
    INIFILENAME         = 'BK5WIN.INI';     //c:\windows\
    PRACTICEINIFILENAME = 'BK5PRAC.INI';    //DATADIR
    MEMSINIFILENAME = 'memorisation.ini';
    DEFAULTTEMPLOGFILENAME = 'BK5WIN_.LOG';
    MAIL_MERGE_PRINT_TEMPLATE_FILENAME = 'BKPrintMerge.doc';
    MAIL_MERGE_EMAIL_TEMPLATE_FILENAME = 'BKEmailMerge.doc';
    MAIL_MERGE_PRINT_RESULT_FILENAME   = 'BKPrinted.doc';
    MAIL_MERGE_EMAIL_RESULT_FILENAME   = 'BKEmailed.doc';
    MAIL_MERGE_DATASOURCE_FILENAME = 'BKDataSource.csv';
    ADMIN_OPTIONS_LOCK = 'options.lck';
    SCHEDULED_LOCK = 'scheduled.lck';
    WEBNOTESUPDATE_Data = 'webnotesdata.xml';
    TPA_FILENAME = 'Third Party Authority.pdf';
    CAF_FILENAME = 'Client Authority Form.pdf';
    INSTITUTIONS_FILENAME = 'Institutions.dat';
    REMINDER_VERSION_FILENAME = 'Reminder.dat';


    FILEEXTN            = '.BK5';
    USERPRINTEXTN       = '.PRS';
    PASSWORDEXTN        = '.MD5';
    RENAMEEXTN          = '.BK!';
    BACKUPEXTN          = '.BAK';
    TMPEXTN             = '.TMP';
    AUTOSAVEEXTN        = '.BK~';
    OFFSITEBACKUPEXTN   = '.OSB';
    OFFSITERESTOREEXTN  = '.OSR';

    ZIP_EXTN            = '.Z';
    SAV_EXTN            = '.SAV';
    QSV_EXTN            = '.QSV';

    MASTER_CLIENT_CODE  = 'MASTER';
    MASTERMEMFILENAMENZ = 'MASTERNZ';
    MASTERMEMFILENAMEOZ = 'MASTEROZ';
    MASTERMEMTRAILINGCHAR = 'D';
    MASTERMEMLOCKCHAR   = '$';

    DEFAULTUSERPRINT    = 'USER'+USERPRINTEXTN;
    SCHEDULED_REPORTS_ID= 'SCHEDULE';
    SCHEDULED_FAX_ID    = 'FAX';

    SYSTEMFILE          = 'SYSTEM';
    SYSFILENAME         = SYSTEMFILE+ '.DB';
    SYSLOCKNAME         = SYSTEMFILE+ '.$$$';
    SYSBACKNAME         = SYSTEMFILE+ '.BAK';
    SYSSAVEDNAME        = SYSTEMFILE+ '.SAV';

    //Registry
    regBK5RootKey       = '\Software\BankLink 5.0';
    regExeLocationData  = 'ExeLocation';

    //Coding form
    PANELF1             = 0;
    PANELMSG            = 1;
    PANELBAR            = 2;
    PANELTIME           = 3;
    PANELNET            = 4;

    BKCOLOR_CREAM       = $00F0FBFF;  //budgets, mems, payees
    bkGSTEditedColor    = $FF0000;    //clBlue constants defined in Graphics.pas

    //YesNo Dialogs
    DLG_YES             = 1;     //duplicated in glConst.pas  SHOULD REMOVE!
    DLG_NO              = 2;     //duplicated in glConst.pas
    DLG_OK              = 1;

    GST_CLASS_CODE_LENGTH = 4;

    //UPI's
    MAXUNCHQ            = 9;          {unpresented cheques}
    MAX_INIT_CHQ_COLS   = 5;          {must be this number in grid}
    MAX_INIT_CHQ_ROWS   = 9;          {change this to increase number}
    MAX_INIT_CHQ        = MAX_INIT_CHQ_COLS * MAX_INIT_CHQ_ROWS;

    MAX_MRU             = 9;
    MAX_TRX_TYPE        = 100;

    MAX_CODING_COLUMNS  = 15;
    MAX_CLIENT_MANAGER_COLUMNS = 23;
    MAX_CLIENT_HOMEPAGE_COLUMNS = 8;
    MAX_FAVOURITE_REPORTS_COLUMNS = 1;
    MAX_EXCHANGE_RATE_COLUMNS = 99;

    //Print / Preview dialog constants
    BTN_NONE            = 0;
    BTN_PRINT           = 1; BTN_OKPRINT = 1;
    BTN_PREVIEW         = 2;
    BTN_FILE            = 3;
    BTN_OK              = 4;
    BTN_SAVE            = 5;
    BTN_EMAIL           = 6;


    DEFAULT_MIN_LOG_KB  = 512;
    DEFAULT_MAX_LOG_KB  = 1536;
    DEFAULT_LOG_BACKUP_DIR = '';

    DEFAULT_SECS_TO_WAIT_FOR_ADMIN = 60;

    //BCONNECT
    OVERDUEFILE         = 'OVERDUE.$$$';
    BC_TEMPFILENAME        = 'TEMPDLD.000';
    BCONNECTHOST        = 'www.banklink5.com';

    Default_BConnect_Primary_Host = 'secure1.banklink.co.nz';
    Default_BConnect_Secondary_Host = 'secure2.banklink.co.nz';

    NZDESCRIPTOR        = 'BankLink';
    OZDESCRIPTOR        = 'OZLink';
    DefaultBConnectHTTPTimeout = 120;

    //Mail Descriptors
    SMTP_MAIL           = 'SMTP';
    MAPI_MAIL           = 'MAPI';

    MAIL_PASS_KEY       = 'abdfjkh38247lkjhgsldtwe42!';

    //------------------------------------------
    //Integrity Check Parameters
    MinValidDate        = 138792;   // 01/01/1980
    MaxValidDate        = 161072;   // 31/12/2040

    //HDE
    MaxHDETempMths      = 4;

    DefaultWaitForWinfax = 500;
    DefaultWaitForWinfaxPrinter = 10000;

    DefaultFaxBannerHeight = 15; // mm

    ExtendedMapiComName = 'bkExtMapi';
    ExtendedMapiDllName = 'bkExtMapi.dll';
    MapiAuthKey = 'bkExtendedMAPI';

    CashBookStartCacheFileName  = 'CMst.html';
    CashBookDetailCacheFileName = 'CMdt.html';

    //ui style
    UIS_Standard = 0;
    UIS_Simple   = 1;

    // Startup actions
    sa_BulkExport = 1;
    sa_Connect = 2;
    sa_ExportTransactions = 3;

    // actions that require system users
    System_Actions   = [sa_BulkExport, sa_Connect, sa_ExportTransactions];

    ClientCodeDelimiter = '~';

    //User Messages
    BK_SYSTEMDB_LOADED          = WM_USER + 380;
    BK_PRACTICE_DETAILS_CHANGED = WM_USER + 381;

    //BankLink Online Pass Key
    BANKLINK_ONLINE_PASS_KEY = 'jucuene88d8uje9whdwjhi9dc!';

    // BankLink Books Default URL
    BANKLINK_ONLINE_BOOKS_DEFAULT_URL = 'https://www.banklinkonline.com';
    BANKLINK_ONLINE_SERVICES_DEFAULT_URL = 'https://www.banklinkonline.com';


    {BGL 360 API}
    cBGL_API_Test_Scope = 'fundList';
    cBGL_API_Scope      = 'audit';

    Def_Original_BGL360_Client_ID     = 'bankLinkTest';                          //Testing ClientID
    Def_Original_BGL360_Client_Secret = 'bankLinkSecret';                        //Testing ClientSecret
    Def_Production_BGL360_Client_ID     = 'efa239d1-c884-4d04-9c08-cc4792fc718b';  //Production ClientID
    Def_Production_BGL360_Client_Secret = '04fadcd5-33c6-4ad3-9071-ea1c169fd785';  //Production ClientSecret



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
var
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Globals objects
{$IFNDEF TESTLOCKING}
    UserPrintSettings        : TPrintManagerObj = nil;
    FaxPrintSettings         : TPrintManagerObj = nil;
{$ENDIF}
    MyClient                 : TClientObj       = nil;
    AdminSystem              : TSystemObj       = nil;
    GlobalAdminSnapshot      : TSystemObj       = nil; //is not automatically updated

    CurrUser                 : TAppUser         = nil;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    DataDir                  : string;
    ExecDir                  : string;
    DownloadInboxDir         : string;
    DownloadWorkDir          : string;
    DownloadOffsiteWorkDir   : string;
    DownloadArchiveDir       : string;
    EmailOutboxDir           : string;
    TemplateDir              : string;
    LogFileBackupDir         : string = '';
    CSVExportDefaultDir      : string = '';
    UsageDir                 : string;
    APPTITLE                 : string = '';
    SHORTAPPNAME             : string = '';
    StyleDir                 : string;
    PublicKeysDir            : string;
    UserDir                  : string;
    HtmlCache                : string;
    RTFTemp                  : string;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Misc settings
    MaxLoginAttempts         : integer = 5;
    SuperUserLoggedIn        : boolean = false;
    AppCriticalErrorOccured  : boolean = false;
    mfModalCommandResult : integer = 0;    //MH - used to store the result of the last modal command, -1 is failed
    gCodingDateFrom,
    gCodingDateTo            : TSTDate;
    // AppHelpForm              : TfrmHelp;
    AppVersionStr            : string;

    StartupParam_ClientToOpen        : string = '';    //#2086
    StartupParam_UserToLoginAs       : string = '';
    StartupParam_UserPassword        : string = '';
    StartupParam_Action              : Byte = 0;
    StartupParam_ExcludeCOA          : Boolean = False;


    ApplicationIsTerminating : boolean = false;
    ApplicationMustShutdownForUpdate: Boolean = false;
    ShowClientNotesOnOpen: Boolean = false;
    
    DDE_Macro_To_Process: string = '';
    DDE_Filename_To_Process: string = '';
    CheckInExtnDetected : boolean;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Coding Form Defaults
    DEFAULT_COLUMN_WIDTH : Array [0..MAX_CODING_COLUMNS] of integer =
                 (32,
                  64,           //default width for the columns in the coding screen
                  103,
                  124,
                  82,
                  144,
                  160,
                  160,
                  150,
                  61,
                  40,
                  80,
                  77,
                  150,
                  75,
                  150);

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Windows INI File settings

    INI_mfTop                : integer;  //main form values
    INI_mfLeft               : integer;
    INI_mfWidth              : integer;
    INI_mfHeight             : integer;
    INI_mfStatus             : integer;

    INI_dsTop                : integer; //dissect form values
    INI_dsLeft               : integer;
    INI_dsWidth              : integer;
    INI_dsHeight             : integer;
    INI_dsStatus             : integer;

    INI_jsTop                : integer; //journal form values
    INI_jsLeft               : integer;
    INI_jsWidth              : integer;
    INI_jsHeight             : integer;
    INI_jsStatus             : integer;

    INI_ShowToolbarCaptions  : boolean = true;
    INI_ShowFormHints        : boolean = true;
    INI_ShowClientProperties : boolean = false;
    INI_ShowPrintOptions     : boolean = false;
    INI_AutoSaveTime         : Integer;
    INI_ShowCodeHints        : Boolean = True;
    INI_AllowCheckOut        : Boolean = true;
    INI_MRUList              : Array [1..MAX_MRU] of String;
    INI_DownloadFrom         : string = '';
    INI_CheckOutDir          : string = '';
    INI_CheckInDir           : string = '';

    INI_CODING_FONT_NAME     : string = '';
    INI_CODING_FONT_SIZE     : integer = 0;
    INI_CODING_ROW_HEIGHT    : integer = 0;

    INI_INTERNET_TIMEOUT  : integer = 60;  //60 seconds, used by SendEmail.pas

    INI_BCPrimaryHost     : string;
    INI_BCSecondaryHost   : string;
    INI_BCPrimaryPort     : integer;
    INI_BCSecondaryPort   : integer;
    INI_BCTimeout         : integer = DefaultBConnectHTTPTimeout;
    INI_BCCustomConfig    : boolean = false;
    INI_BCUseWinInet      : boolean = false;

    INI_BCUseProxy        : boolean;
    INI_BCProxyHost       : string;
    INI_BCProxyPort       : integer;
    INI_BCProxyAuthMethod : integer;
    INI_BCProxyUsername   : string;
    INI_BCProxyPassword   : string;

    INI_BCUseFirewall     : boolean;
    INI_BCFirewallHost    : string;
    INI_BCFirewallPort    : integer;
    INI_BCFirewallType    : integer;
    INI_BCFirewallUseAuth : boolean;
    INI_BCFirewallUsername : string;
    INI_BCFirewallPassword : string;
    INI_BCHTTPMethod : string;    

    //mail
    INI_Mail_Type         : string = MAPI_MAIL;
    INI_MAPI_UseExtended  : Boolean = false;

    INI_MAPI_Profile      : string = '';
    INI_MAPI_Password     : string = '';
    INI_MAPI_Default      : boolean = true;

    INI_SMTP_Account      : string = '';
    INI_SMTP_Password     : string = '';
    INI_SMTP_Server       : string = '';
    INI_SMTP_Auth         : boolean = false;
    INI_SMTP_PortNo       : string = ''; 
    INI_SMTP_From         : string = '';
    INI_SMTP_UseSSL       : boolean = false;

    INI_DontShowMe_EditChartGST : boolean = false;
    INI_DontShowMe_NoOpeningBalances : Boolean = false;

    INI_Default_User_Code : string = '';
    INI_PlaySounds        : Boolean = True;
    INI_ShowVersionInFooter : Boolean = False;

    INI_BackupDir : string = 'A:\';
    INI_BackupLevel : integer = 0;
    INI_BackupOverwrite : boolean = true;

    INI_MAX_EXTRACT_NARRATION_LENGTH: Integer = 200;

    INI_SOL6_SYSTEM_PATH : string;

    INI_Coding_Font: string;

    INI_Report_Style: string;

    INI_BooksExtact: Boolean = False;

    INI_CustomColors: string;

    PRACINI_Check_Data_Minutes: Integer;

    INI_UI_Style : integer = 0;
    Active_UI_Style : integer = 0;     //independant of INI setting so can override in Practice

    INI_BankLink_Online_Username  : string = '';
    INI_BankLink_Online_Password  : string = '';
    INI_BankLink_Online_SubDomain : string = '';

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //general user settings
    UserINI_Client_Lookup_Sort_Column: integer;
    UserINI_Client_Lookup_Sort_Direction: integer;

    UserINI_GST_Lookup_Sort_Column: integer;
    UserINI_Payee_Lookup_Sort_Column: integer;
    UserINI_Chart_Lookup_Sort_Column: integer;
    UserINI_Job_Lookup_Sort_Column: integer;

    UserINI_Version: Integer;
    //UserINI_Show_Promo_Window: Boolean;
    //client manager settings
    UserINI_CM_Default_View : integer;  // 0 = all files, 1 = my files
    UserINI_CM_Column_Widths : Array[ 0..MAX_CLIENT_MANAGER_COLUMNS] of integer;
    UserINI_CM_Column_Positions : Array[ 0..MAX_CLIENT_MANAGER_COLUMNS] of integer;
    UserINI_CM_Column_Visible : Array[ 0..MAX_CLIENT_MANAGER_COLUMNS] of boolean;
    UserINI_CM_Var_Col_Count : integer;
    UserINI_CM_Var_Col_Widths : Array of integer;
    UserINI_CM_Var_Col_Positions : Array of integer;
    UserINI_CM_Var_Col_Visible : Array of boolean;
    UserINI_CM_Var_Col_Guid : Array of WideString;
    UserINI_CM_Filter: integer; // see filter definitions in bkconst.pas
    UserINI_CM_SubFilter: Int64; // see filter definitions in bkconst.pas
    UserINI_CM_SubFilter_Name: string;
    UserINI_CM_UserFilter: TStringList;
    UserINI_CM_GroupFilter: TStringList;
    UserINI_CM_ClientTypeFilter: TStringList;
    UserINI_CM_ShowLegend: Boolean; // Shared with ClientHomepage
    UserINI_CM_SortColumn: Integer;
    UserINI_CM_SortDescending: Boolean;

    //Client Homepage
    UserINI_HP_GroupWidth: Integer;
    UserINI_HP_Column_Widths : Array[ 0..MAX_CLIENT_HOMEPAGE_COLUMNS ] of integer;

    //Favourite Reports
    UserINI_FR_GroupWidth: Integer;
    UserINI_FR_Column_Widths : Array[ 0..MAX_FAVOURITE_REPORTS_COLUMNS ] of integer;

    UserINI_CES_Show_Find: Boolean = true;
    UserINI_Mem_Show_Find: Boolean = true;

    //global setup settings
    UserINI_GS_Column_Widths : Array[ 0..MAX_CLIENT_MANAGER_COLUMNS] of integer;
    UserINI_GS_Column_Positions : Array[ 0..MAX_CLIENT_MANAGER_COLUMNS] of integer;
    UserINI_GS_Grid_Alternate_Color : Integer;

    // System Pactice Accounts
    UserINI_SPA_Columns: string;

    // Other GroupBars
    UserINI_CD_GroupWidth: Integer;
    UserINI_RS_GroupWidth: Integer;

    //Include Interim Reports
    UserINI_Show_Interim_Reports: Boolean = False;

    //Get and send client file options
//    UserINI_Client_Lookup_Available_Only : Boolean = True;
    UserINI_Client_Lookup_Flag_Read_Only : Boolean = True;
    UserINI_Client_Lookup_Edit_Email     : Boolean = True;
    UserINI_Client_Lookup_Send_Email     : Boolean = True;
    UserINI_Suggested_Mems_Show_Popup    : Boolean = True;

    {my.MYOB user credentials}
    UserINI_myMYOB_Random_Key : string = '';
    UserINI_myMYOB_Access_Token: string = '';
    UserINI_myMYOB_Refresh_Token : string = '';
    UserINI_myMYOB_Expires_TokenAt : TDateTime ;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //practice INI settings bk5prac.INI
    PRACINI_REMOVEGST        : boolean = false;
    PRACINI_PROMPTFORGST     : boolean = false;
    PRACINI_ForceLogin       : boolean = false;
    PRACINI_OSAdminOnly      : boolean = true;
    PRACINI_TicksToWaitForAdmin : integer = 15000;
    PRACINI_DoNotReportFirstRun : boolean = false;

    PRACINI_Reports_NewPage  : boolean = false;
    PRACINI_Reports_GrandTotal:boolean = true;
    PRACINI_CurrentVersion   : string  = '';
    PRACINI_CreateCSVFile    : boolean = false; //Do we create a CSV File during the Download?

    //Custom INI settings
    PRACINI_CustomBitmapFilename        : string = '';
    PRACINI_ValidateArchive             : boolean = true; //Do we need to validate the archive dir
    PRACINI_ValidateArchiveDownloadOnly : boolean = true; //Validate before download if this is off
                                                          //validation will occur at login also
    PRACINI_AllowAdvanceOptions         : Boolean = false;
    PRACINI_DefaultCodeEntryMode        : Integer;
    PRACINI_DefaultDissectionMode       : Integer;
    PRACINI_CopyNarrationDissection     : Boolean = False;
    PRACINI_DontAskForPGDiskNo          : boolean = false;
    PRACINI_ViewOpeningBalanceJournals  : boolean = false;

    PRACINI_DisableBankLRNCheck         : boolean = false; //disable admin integrity test of bank lrn
    PRACINI_MinLogFileSize              : integer = DEFAULT_MIN_LOG_KB;
    PRACINI_MaxLogFileSize              : integer = DEFAULT_MAX_LOG_KB;
    PRACINI_LogBackupDir                : string = '';
    PRACINI_MYOBStripAlpha              : boolean = false;
    PRACINI_AutoSaveTime                : Integer;

    PRACINI_AutoPrintSchdRepSummary     : boolean = false;
    PRACINI_UseXLonChartOrder           : boolean = false;
    PRACINI_ExtractQuantity             : Boolean = True;
    PRACINI_ExtractDecimalPlaces        : Integer = 4;
    PRACINI_ExtractZeroAmounts          : Boolean = False;
    PRACINI_IgnoreDiskImageVersion      : boolean = false;
    PRACINI_RoundCashFlowReports        : Boolean = False;

    PRACINI_IgnoreQtyInDownload         : Boolean = False;
    PRACINI_ExportReports               : Boolean = False;
    PRACINI_AlwaysReloadAdmin           : Boolean = False;
    PRACINI_ShowStatistics              : Boolean = False;
    PRACINI_ExtractMultipleAccountsToPA : Boolean = False;
    PRACINI_ExtractJournalsAsPAJournals : Boolean = False;

    PRACINI_msToWaitForWinfax           : Integer = 500;  //milliseconds
    PRACINI_msToWaitForWinfaxPrinter    : Integer = 10000;
    PRACINI_HideWinFaxPro               : Boolean = true;

    PRACINI_mmFaxBannerHeight           : Integer = 15; // mm
    PRACINI_SuppressBanner              : Boolean = True;

    PRACINI_PostingAlwaysTrue           : Boolean = False;
    PRACINI_AllowOffsiteDiskDownload    : boolean = False;

    PRACINI_DoubleGraphGridLines        : Boolean = False;
    PRACINI_GraphPrintResolution        : Integer = 0;

    PRACINI_CSVExport                   : Boolean = False;

    PRACINI_ShowAcclipseInOz            : Boolean = False;

    PRACINI_ShowImportExportInOffsite   : Boolean = False;
    
    PRACINI_ShowSol6Systems             : Boolean = False;
    PRACINI_MYOB_AO_Systems             : Boolean = False;

    PRACINI_RestrictFileFormats         : Boolean = true;
    PRACINI_GST101Link                  : String = '';
    PRACINI_InstListLinkNZ              : String = '';
    PRACINI_InstListLinkAU              : String = '';
    PRACINI_InstListLinkUK              : String = '';

    PRACINI_SecureFormLinkNZ            : String = '';
    PRACINI_SecureFormLinkAU            : String = '';
    PRACINI_IBizzFormLinkAU             : String = '';
    PRACINI_AdditionalFormLinkAU        : String = '';

    PRACINI_OnlineLink                  : String = '';

    PRACINI_MAPI_MaskError              : string = '';

    PRACINI_NZCashMigrationURLOverview1 : String = '';
    PRACINI_AUCashMigrationURLOverview1 : String = '';
    PRACINI_NZCashMigrationURLOverview2 : String = '';
    PRACINI_AUCashMigrationURLOverview2 : String = '';

    PRACINI_DefaultCashbookForgotPasswordURL : String = '';
    PRACINI_CashbookAPILoginURL              : String = '';
    PRACINI_CashbookAPILoginID               : String = '';
    PRACINI_CashbookAPILoginSecret           : String = '';
    PRACINI_CashbookAPILoginScope            : String = '';
    PRACINI_CashbookAPIFirmsURL              : String = '';
    PRACINI_CashbookAPIBusinessesURL   : String = '';
    PRACINI_CashbookTransactionViewURL   : String = ''; // This is to show the transactions list of the selected business
    PRACINI_CashbookAPITransactionsURL : String = '';
    PRACINI_CashbookAPIJournalsURL     : string = '';
    PRACINI_CashbookAPICOAURL          : String = '';
    PRACINI_CashbookAPIUploadURL             : String = '';
    PRACINI_CashbookAPIUploadDataStore       : String = '';
    PRACINI_CashbookAPIUploadQueue           : String = '';
    PRACINI_DefaultCashbookLoginNZURL        : String = '';
    PRACINI_DefaultCashbookLoginAUURL        : String = '';
    PRACINI_CashbookModifiedCodeCount        : integer = 0;

{$IFDEF SmartLink}
    PRACINI_FingertipsURL : string = '';
    PRACINI_FingertipsSQL_IP : string = '';
    PRACINI_FingertipsTimeout : integer = 60;
{$ENDIF}
    PRACINI_DisableCheckInCheckOut: Boolean = False;
{$IFDEF CSVImport}
    PRACINI_AllowCSVImport : boolean = false;
{$ENDIF}
    PRACINI_UPGDefaultServer  : string;
    PRACINI_UPGDefaultCountry : string;

    PRACINI_PaperSmartBooks             : Boolean = False;
    PRACINI_CRCFileTest                 : Boolean = False;

    PRACINI_FuelCreditRates             : string;

    PRACINI_AutoUpdateProcessing       : Boolean = False;
    PRACINI_AllowChartRemap            : boolean = False;
    PRACINI_AllowHistoricalImport      : Boolean = False;
    PRACINI_ReportMemoryLeak           : Boolean = False;
    PRACINI_ShowProSuper               : Boolean = False;
    PRACINI_ShowRewardSuper            : Boolean = False;

    //Exchange Rate columns
    PRACINI_ER_Column_Widths : Array[ 0..MAX_EXCHANGE_RATE_COLUMNS ] of integer;
    PRACINI_ER_Column_Positions : Array[ 0..MAX_EXCHANGE_RATE_COLUMNS ] of integer;

    PRACINI_FastDownloadStatsUpdate    : Boolean = false;

    //BankLink Online Books URL
    PRACINI_BankLink_Online_Books_URL  : string = BANKLINK_ONLINE_BOOKS_DEFAULT_URL;
    PRACINI_BankLink_Online_BLOPI_URL  : string;
    PRACINI_DataPlatform_Services_URL : string;
    PRACINI_Banklink_Online_Services_URL: string;

    PRACINI_IPClientLocking_SwitchedOn : Boolean;
    PRACINI_IPClientLocking_UDP_Server_IP : string;
    PRACINI_IPClientLocking_UDP_Server_Port : integer;

    PRACINI_IPClientLocking_UDP_Client_Port : integer;
    PRACINI_IPClientLocking_UDP_BuffInitSize : integer;
    PRACINI_IPClientLocking_DiscoveryTimeOut : integer;
    PRACINI_IPClientLocking_UDPTimeOut : integer;
    PRACINI_IPClientLocking_LockTimeOut : integer;
    PRACINI_IPClientLocking_TCPTimeOut : integer;
    PRACINI_IPClientLocking_ProcessMessageDelay : integer;
    PRACINI_IPClientLocking_GROUP_ID : string;

    {BGL 360 API}
    PRACINI_BGL360_API_URL: string = '';
    PRACINI_Random_Key : string = '';
    TEST_PRACINI_BGL360_Client_ID: string     = Def_Original_BGL360_Client_ID;       //Testing ClientID
    TEST_PRACINI_BGL360_Client_Secret: string = Def_Original_BGL360_Client_Secret;   //Testing ClientSecret
    PRACINI_BGL360_Client_ID: string          = Def_Production_BGL360_Client_ID;     //Production ClientID
    PRACINI_BGL360_Client_Secret: string      = Def_Production_BGL360_Client_Secret; //Production ClientSecret

    {Contentful API URL}
    PRACINI_Contentful_API_URL : string = '';

    PRACINI_Disable_Promo_Window: Boolean = false;
    PRACINI_Disable_LeanEngage: Boolean = false;


const


  //LeanEngage
  cLeanEngage_PracticeAppID = 'b99ea988-f21c-4dd3-a6bd-327fd615d1cc';
  cLeanEngage_TestAPIKey = 'axcUDK7vH2HhUZfLvMXgcA';
  cLeanEngage_ProdAPIKey = 'GEKPKtJyWzmMPxYaKYubWA';
  cLeanEngage_TestSwitch = 'TEST';
  cLeanEngage_ProdSwitch = 'PRODUCTION';
  cLeanEngage_Support_Practice_Code = 'BSUPPORT';

{$ifdef DEBUG}
  INI_LeanEngage_System_Switch : string = cLeanEngage_TestSwitch;
{$else}{ifdef DEBUG}
  INI_LeanEngage_System_Switch : string = cLeanEngage_ProdSwitch;
{$endif}{ifdef DEBUG}


  cLeanEngageApp_Key : string = cLeanEngage_TestAPIKey;
  cLeanEngageActive : boolean = false;

  INI_LeanEngage_BASE_URL : string = 'https://www.leanengage.com';
  INI_LeanEngage_API_KEY : string = '';

  // Transaction Type equivalent account numbers
  cttanDistribution = 23800;
  cttanDividend     = 23900;
  cttanInterest     = 25000;
  cttanShareTradeRangeStart   = 70000;
  cttanShareTradeRangeEnd     = 79999;

Type
    TMemsSupportOptions = (meiFullfunctionality,
                           meiResetMems,
                           meiDisableSuggestedMems,
                           meiDisableSuggestedMemsOld,
                           meiLogAllMems);

  TTransactionTypes = (ttDistribution, ttDividend, ttInterest, ttShareTrade, ttOtherTx );

var
    MEMSINI_SupportOptions : TMemsSupportOptions;

    // Remember email details in case it fails
    Email_Saved: Boolean = False;
    Email_To: string = '';
    Email_From: string = '';
    Email_Cc: string = '';
    Email_Body: string = '';
    Email_Attachments: string = '';
    Email_Subject: string = '';
    Email_Checkout_File: Boolean = False;

    //BankLink Online - Pracice global setting
    UseBankLinkOnline: Boolean = False;
    NeedToClearMYOBClient : Boolean = False;
//** ****************************************************************************
implementation

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   ShortDateFormat           := BKDATEFORMAT;
   TwoDigitYearCenturyWindow := BKCENTURYWINDOW;

   gCodingDateFrom           := 0;
   gCodingDateTo             := 0;

   {setup directory indicators}
   ExecDir                   := ExtractFilePath(Application.ExeName);
   DownloadInboxDir          := ExtractFilePath(Application.ExeName);
   DataDir                   := ExtractFilePath(Application.ExeName);

   SetCurrentDir( ExecDir );

{testing code only}
//   DataDir := 'U:\testdata\bk5au_testing\';
//   DownloadInboxDir          := DataDir;
{testing code only}

   GlobalDirectories.glDataDir  := DataDir;
   GlobalDirectories.glExecDir  := ExecDir;

   DownloadWorkDir           := DataDir + 'WORK\';
   DownloadOffsiteWorkDir    := DataDir + 'OffSiteWORK\';
   DownloadArchiveDir        := DataDir + 'ARCHIVE\';
   EmailOutboxDir            := DataDir + 'OUTBOX\';
   Templatedir               := DataDir + 'TEMPLATE\';
   LogFileBackupDir          := DataDir + 'OLDLOGS\';
   CSVExportDefaultDir       := DataDir + 'EXPORT\';
   UsageDir                  := DataDir + 'USAGE\';
   StyleDir                  := DataDir + 'STYLES\';
   PublicKeysDir             := DataDir + 'PUBLICKEYS\';
   HtmlCache                 := DataDir + 'CACHE\HTML\';
   AppVersionStr             := GetAppVersionStr;
   UserDir                   := DataDir;
   RTFTemp                   := 'TEMP';


{$ENDIF}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.



