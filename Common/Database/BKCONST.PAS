// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ __revision_history__
  __revision_history__ }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
UNIT bkConst;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   MaxBK5CodeLen = 20; { Version 33 Upgrade }
   MaxBankPrefixLen = 3;

   MaxNarrationEditLength = 200;   //cannot be more than 255

   ECodingDisplayName = 'BankLink Notes';

   WebXDisplayName = 'CCH Web Manager';

   WebNotesName = 'BankLink Notes Online';
   BankLinkLiveName = 'BankLink Online';


   DISSECT_DESC = 'DISSECTED';

   EldersPrefix = '92';

TYPE
   BK5CodeStr    = String[ MaxBK5CodeLen ];
   BankPrefixStr = String[ MaxBankPrefixLen];
   SetOfBytes    = Set Of Byte;
   TViewMode     = ( vmMyFiles, vmAllFiles);
   TBankContra = (bcNone = 0, bcAll = 1, bcTotal = 2);
   TGSTContra  = (gcNone = 0, gcAll = 1, gcTotal = 2);
   TFundNavigation = (fnNoMove, fnNothing, fnIsFirst, fnIsLast, fnGoBack, fnGoForward);
  

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   VALUES_DELIMITER = '¦'; //non-keyboard character

   cnLPT1         = 0;  cnMin = 0;
   cnLPT2         = 1;
   cnLPT3         = 2;
   cnNetWareQueue = 3;
   cnUNCName      = 4;  cnMax = 4;
   cnNames : Array[ cnMin..cnMax ] of String[19] =
      (  'LPT1:', 'LPT2:', 'LPT3:', 'NetWare Print Queue', 'Windows Print Queue' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   ftContinuous   = 0;  ftMin = 0;
   ftSingleSheet  = 1;  ftMax = 1;
   ftNames : Array[ ftMin..ftMax ] of String[12] = ( 'Continuous', 'Single Sheet' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   coBlue   = 0;  coMin = 0;
   coCyan   = 1;
   coGray   = 2;  coMax = 2;
   coNames : Array[ coMin..coMax ] of String[4] = ( 'Blue', 'Cyan', 'Gray' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   moMin = 0;
   moMax = 12;
   moNames : Array[ moMin..moMax ] of String[9] = (  'N/A', 'January', 'February', 'March', 'April', 'May', 'June',
                                                     'July', 'August', 'September', 'October', 'November', 'December' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   gpNone      = 0;  gpMin = 0;
   gpMonthly   = 1;
   gp2Monthly  = 2;
   gp6Monthly  = 3;
   gpQuarterly = 4;
   gpAnnually  = 5;  gpMax = 5;
   gpNames : Array[ gpMin..gpMax ] of String[11] = ( 'N/A', 'Monthly', 'Two Monthly', 'Six Monthly', 'Quarterly',
                                                     'Annually' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   roDontSendReports         = 0; roMin  = 0;
   roSendEveryMonth          = 1;
   roSendEveryTwoMonths      = 2;
   roSendEveryThreeMonths    = 3;
   roSendEveryFourMonths     = 4;
   roSendEverySixMonths      = 5;
   roSendAnnually            = 6;
   roSendEveryMonthQuarter   = 7;
   roSendEveryMonthTwoMonths = 8;
   roSendEveryTwoMonthsMonth = 9;
   roMax  = 9;

   roNames : Array[ roMin..roMax ] of String[28] =
      (  'Don''t Send'        ,
         'Every Month'        ,
         'Every Two Months'   ,
         'Every Three Months' ,
         'Every Four Months'  ,
         'Every Six Months'   ,
         'Annually'           ,
         'Every Month and Quarter',
         'Every Month and Two Months',
         'Every Two Months then Month');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   stSendToStaffMember     = 0; stMin = 0;
   stSendToClient          = 1; stMax = 1;

   stNames : Array[ stMin..stMax ] of String[20] =
      ( 'Staff Member', 'Client' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   cbNotCoded              = 0; cbMin = 0;
   cbManual                = 1;
   cbMemorisedC            = 2;
   cbAnalysis              = 3;
   cbManualPayee           = 4;
   cbAutoPayee             = 5;
   cbMemorisedM            = 6;
   cbECodingManual         = 7;
   cbECodingManualPayee    = 8;
   cbCodeIT                = 9;
   cbManualSuper           = 10;
   cbImported              = 11; cbMax = 11;

   cbNames : Array[ cbMin..cbMax ] of String[11] =
      (  '',
         'Manually',
         'Memorised',
         'Analysis',
         'Man Payee',
         'Anl Payee',
         'Master',
         'Notes',
         'Notes Payee',
         'Web',
         'Superfund',
         'Imported' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   orBank         = 0;     orMin = 0;
   orGenerated    = 1;
   orManual       = 2;     // Journal
   orHistorical   = 3;
   orGeneratedRev = 4;
   orMDE          = 5;     // Manual entry
   orProvisional  = 6;     orMax = 6;

   orNames : Array[ orMin..orMax ] of String[20] =
      (  'Bank Data',
         'Generated',
         'Manually Entered',
         'Historical',
         'Generated Reversal',
         'Manual Data Entry',
         'Provisional Data');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   lkUnlocked  = 0;     lkMin = 0;
   lkLocked    = 1;     lkMax = 1;
   lkNames : Array[ lkMin..lkMax ] of String[12] = ( 'Unlocked', 'Locked' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   atNone            = 0;     atMin = 0;
   atIncome          = 1;
   atDirectExpense   = 2;
   atExpense         = 3;     //was atOtherExpense
   atOtherExpense    = 4;
   atOtherIncome     = 5;
   atEquity          = 6;     //was Current Account
   atDebtors         = 7;
   atCreditors       = 8;
   atOpeningStock    = 9;
   atPurchases       = 10;
   atClosingStock    = 11;
   atFixedAssets     = 12;
   atStockOnHand     = 13;
   atBankAccount     = 14;    
   atRetainedPorL    = 15;    //no longer used in 5.2 mapped to Equity
   atGSTPayable      = 16;
   atUnknownDR       = 17;
   atUnknownCR       = 18;
   //new report groups for 5.2
   atCurrentAsset    = 19;
   atCurrentLiability  = 20;
   atLongTermLiability = 21;
   atUncodedCR       = 22;
   atUncodedDR       = 23;
   atCurrentYearsEarnings = 24;
   atGSTReceivable   = 25;

   atMax = 25;

   atNames : Array[ atMin..atMax ] of String[24] =
      ( 'N/A',
        'Income',
        'Direct Expense',
        'Expense',               //was Other Expense
        'Other Expense',
        'Other Income',
        'Equity',                //was Current Account
        'Debtors',
        'Creditors',
        'Opening Stock',
        'Purchases',
        'Closing Stock',
        'Fixed Asset',
        'Stock on Hand',
        'Cash on Hand',
        'Retained P/L',
        'GST Payable',
        'Unknown (DR)',
        'Unknown (CR)',
        'Current Asset',
        'Current Liability',
        'Long Term Liability',
        'Uncoded DR',
        'Uncoded CR',
        'Current Years Earnings',
        'GST Receivable'
        );

   BalanceSheetReportGroupsSet = [
                                   atCurrentAsset,          //Assets
                                   atStockOnHand,
                                   atBankAccount,
                                   atDebtors,
                                   atGSTReceivable,
                                   atFixedAssets,

                                   atCurrentLiability,     //Liabilities
                                   atCreditors,
                                   atGSTPayable,
                                   atLongTermLiability,

                                   atEquity,              //Equity
                                   atCurrentYearsEarnings,
                                   atRetainedPorL
                                 ];

   ProfitAndLossReportGroupsSet = [
                                   atIncome,
                                   atDirectExpense,
                                   atExpense,
                                   atOpeningStock,
                                   atPurchases,
                                   atClosingStock,
                                   atUnknownDR,
                                   atUnknownCR,
                                   atOtherIncome,
                                   atOtherExpense,
                                   atUncodedCR,
                                   atUncodedDR
                                  ];

  //use this array to pick out items in the order the should appear in picklists
  ReportGroupsDisplayOrder : Array[atMin..atMax] of byte =
               (
                 atNone,
                 atIncome,
                 atPurchases,
                 atDirectExpense,
                 atExpense,
                 atOtherExpense,
                 atOtherIncome,
                 atOpeningStock,
                 atClosingStock,
                 atBankAccount,
                 atDebtors,
                 atStockOnHand,
                 atGSTReceivable,
                 atCurrentAsset,
                 atFixedAssets,
                 atCreditors,
                 atGSTPayable,
                 atCurrentLiability,
                 atLongTermLiability,
                 atEquity,
                 atUnknownDR,
                 atUnknownCR,
                 //the following are not normally shown
                 atRetainedPorL,
                 atUncodedCR,
                 atUncodedDR,
                 atCurrentYearsEarnings
               );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Coding Report Styles
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   rsStandard            = 0; rsMin = 0;
   rsTwoColumn           = 1;
   rsStandardWithNotes   = 2;
   rsTwoColumnWithNotes  = 3;
   rsCustom              = 4; rsMax = 4;

   rsNames : Array[ rsMin..rsMax ] of String[ 21 ] =
      ( 'Standard', 'Two Column', 'Standard with Notes', 'Two Column with Notes', 'Custom' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   spNone   = 0; spMin = 0;
   sp1      = 1;
   sp2      = 2; spMax = 2;
   spNames : Array[ spMin..spMax ] of String[4] = ( 'None', 'One', 'Two' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



   csDateEffective = 0; csMin = 0;
   csChequeNumber  = 1;
   csDatePresented = 2;
   csAccountCode   = 3;
   csByValue       = 4;
   csByNarration   = 5;

   csByOtherParty  = 6;   //mjch Apr 2002 - allow different sorting in CES
   csByParticulars = 7;
   csByStatementDetails = 8;
   csByEntryType   = 9;
   csByAnalysis    = 10;
   csByCodedBy     = 11;
   csByPayee       = 12;
   csAccountCodeXLON = 13;
   csReference     = 14;
   csByPayeeName   = 15;
   csByAccountDesc = 16;
   csByGSTClass    = 17;
   csByGSTAmount   = 18;
   csByQuantity    = 19;
   csByDocumentTitle = 20;
   csByJob         = 21;
   csByJobName     = 22;
   csByAction      = 23;
   csByForexAmount = 24;
   csByForexRate   = 25;

   csByAltChartCode = 26;
   csByTransId      = 27;
   csBySentToAndAcc = 28;

   csMax = 28;

   csNames : Array[ csMin..csMax ] of String[20]=
      (  'Date Effective',
         'Cheque Number',
         'Date Presented',
         'Account Code',
         'Amount',
         'Narration',
         'Other Party',
         'Particulars',
         'Statement Details',
         'Entry Type',
         'Analysis',
         'Coded By',
         'Payee',
         'Account Code',  //xlon sort order
         'Reference',
         'Payee Name',
         'A/c Desc',
         'GST Class ID',
         'GST Amount',
         'Quantity',
         'Attachment',
         'Job',
         'Job Name',
         'Action',
         'F/C Amount',
         'Exchange Rate',
         'Alternative Code',
         'Transaction ID',
         'Sent to Banklink'
          );

  //use this array to pick out items in the order the should appear in picklists
  //alphabetical
  csSortByOrder : Array [csMin..csMax] of Integer =
  (
    csByAction,
    csAccountCode,
    csByAccountDesc,
    csByValue,
    csByAnalysis,
    csByDocumentTitle,
    csChequeNumber,
    csByCodedBy,
    csDateEffective,
    csDatePresented,
    csByEntryType,
    csByForexRate,
    csByForexAmount,
    csByGSTClass,
    csByGSTAmount,
    csByJob,
    csByJobName,
    csByNarration,
    csByOtherParty,
    csByParticulars,
    csByPayee,
    csByPayeeName,
    csReference,
    csByStatementDetails,
    csAccountCodeXLON,
    csByQuantity,
    csByAltChartCode,
    csByTransId,
    csBySentToAndAcc
  );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   esAllEntries   = 0;  esMin = 0;
   esUncodedOnly  = 1;  esMax = 1;
   esNames : Array[ esMin..esMax ] of String[ 20 ] = ( 'All Entries', 'Uncoded Only  ');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   asNone         = 255;
   asNoneName     = '(None)';

   snOther        = 0;     snMin = 0;
   snSolution6MAS42 = 1;
   snHAPAS        = 2;
   snGLMan        = 3;
   snGlobal       = 4;
   snMaster2000   = 5;
   snAdvance      = 6;
   snSmartLink    = 7;
   snJobal        = 8;
   snCashManager  = 9;
   snAttache      = 10;
   snASCIICSV     = 11;
   snCharterQX    = 12;
   snIntech       = 13;
   snKelloggs     = 14;
   snAclaim       = 15;
   snIntersoft    = 16;
   snLotus123     = 17;
   snAccPac       = 18;
   snCCM          = 19;
   snMYOB         = 20;
   snAccPacW      = 21;
   snSmartBooks   = 22;
   snBeyond       = 23;
   snPastel       = 24;
   snSolution6CLS3   = 25;
   snSolution6CLS4   = 26;
   snSolution6MAS41  = 27;     //obosolete  Apr 2003
   snAttacheBP       = 28;
   snBK5CSV          = 29;
   snCaseWare        = 30;
   snSolution6CLSY2K = 31;
   snConceptCash2000 = 32;
   snQBWO            = 33;
   snMYOBGen         = 34;
   snXPA             = 35;     //XPA 8
   snQIF             = 36;
   snOFXV1           = 37;
   snOFXV2           = 38;
   snMYOB_AO_COM     = 39;
   snQBWN            = 40;
   snAcclipse        = 41;
   snMax = 41;

   snNames : Array[ snMin..snMax ] of String[32] =
      //'12345678901234567890123467890'
      ( 'Other'                   ,       //snOther
        'MYOB Accountants Enterprise MAS',//snSolution6MAS4
        'HAPAS Client Accounting' ,       //snHAPAS
        'MYOB Accountants Office' ,       //snGLMan
        'Global Accounting'       ,       //snGlobal
        'Master 2000'             ,       //snMaster2000
        'Professional Accounting 7',      //snAdvance
        'SmartLink'               ,       //snSmartLink
        'EasyBooks NZ'            ,       //snJobal
        'Accomplish CashManager'  ,       //snCashManager
        'Attaché 5'               ,       //snAttache
        'ASCII CSV'               ,       //snASCIICSV
        'Charter QX'              ,       //snCharterQX
        'Intech'                  ,       //snIntech
        'Kellogg FRS'             ,       //snKelloggs
        'Coopers & Lybrand Aclaim',       //snAclaim
        'Intersoft'               ,       //snIntersoft
        'Lotus 1-2-3'             ,       //snLotus123
        'AccPac Plus'             ,       //snAccPac
        'Concept Cash Manager'    ,       //snCCM
        'MYOB Transaction Journals',      //snMYOB
        'AccPac for Windows'      ,       //snAccPacW
        'SmartBooks 2000'         ,       //snSmartBooks
        'Beyond Private Ledger'   ,       //snBeyond
        'Pastel Accounting'       ,       //snPastel
        'Solution 6 MAS 3 [CLS]'  ,       //snSolution6CLS3
        'Solution 6 MAS 4.1 [CLS]',       //snSolution6CLS4
        'Solution 6 MAS 4.1 [MAS]',       //snSolution6MAS4
        'Attaché Business Partner',       //snAttacheBP
        'Generic'                 ,       //snBK5CSV
        'CaseWare'                ,       //snCaseWare
        'Solution 6 MAS [CLSY2K]' ,       //snSolution6CLSY
        'Concept Cash Manager 2000',      //snConceptCash2000
        'QuickBooks 2007/2008',           //snQBWO
        'MYOB General Journals'   ,       //snMYOBGen
        'Professional Accounting XPA 8',
        'Business Products - QIF',
        'Business Products - OFX V1',
        'Business Products - OFX V2',
        'MYOB AO (manual posting)',       //snMYOB_COM
        'QuickBooks 2008/2009',           // snQBWN
        'iFirm'                           //snAcclipse
         );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   saOther        = 0;  saMin = 0;
   saSolution6MAS42= 1;
   saHAPAS        = 2; // Obsolete
   saCeeData      = 3;
   saGLMan        = 4;
   saOmicom       = 5;
   saASCIICSV     = 6;
   saLotus123     = 7; // Obsolete
   saAttache      = 8;
   saHandiLedger  = 9;
   saBGLSimpleFund= 10;
   saMYOB         = 11;
   saCeeDataCDS1  = 12; // Obsolete
   saSolution6CLS3   = 13;
   saSolution6CLS4   = 14;
   saSolution6MAS41  = 15; // Obsolete Apr 2003
   saQBWO            = 16;
   saCaseware        = 17;
   saBK5CSV          = 18;
   saAccountSoft     = 19;
   saProflex         = 20; // Obsolete
   saTeletaxLW       = 21; // Obsolete
   saAttacheBP       = 22;
   saSolution6CLSY2K = 23;
   saEasyBooks       = 24;
   saMGL             = 25;
   saComparto        = 26;
   saXlon            = 27;
   saCatSoft         = 28;
   saBCSAccounting   = 29;
   saMYOBAccountantsOffice = 30;
   saSolution6SuperFund = 31;
   saTaxAssistant    = 32;
   saMYOBGen         = 33;
   saAccomplishCashManager = 34;
   saPraemium = 35;
   saSupervisor = 36;
   saXPA =37;
   saQIF = 38;
   saOFXV1 = 39;
   saOFXV2 = 40;
   saElite = 41;
   saMYOB_AO_COM = 42;
   saDesktopSuper = 43;
   saBGLSimpleLedger = 44;
   saClassSuperIP = 45;
   saQBWN = 46;
   saIRESSXplan = 47;
   saSuperMate = 48;
   saRewardSuper = 49;
   saProSuper = 50;
   saSageHandisoftSuperfund = 51; saMax = 51;

   saNames : Array[ saMin..saMax ] of String[36] =
      //'123456789012345678901234567890'
      ( 'Other'                     ,                 //saOther
        'MYOB Accountants Enterprise MAS',            //saSolution6MAS4
        'HAPAS Client Accounting'   , // Obsolete     //saHAPAS
        'Cee-Data'                  ,                 //saCeeData
        'CA-Systems GL'             ,                 //saGLMan
        'Professional Accounting 7' ,                 //saOmicom
        'ASCII CSV'                 ,                 //saASCIICSV
        'Lotus 1-2-3'               , // Obsolete     //saLotus123
        'Attaché'                   ,    {é = 130}    //saAttache
        'HandiSoft HandiLedger'     ,                 //saHandiLedger
        'BGL Simple Fund'           ,                 //saBGLSimpleFund
        'MYOB Transaction Journals' ,                 //saMYOB
        'Cee-Data CDS1'             , // Obsolete     //saCeeDataCDS1
        'Solution 6 MAS 3 [CLS]'    ,                 //saSolution6CLS3
        'Solution 6 MAS 4.1 [CLS]'  ,                 //saSolution6CLS4
        'Solution 6 MAS 4.1 [MAS]'  , // obsolete     //saSolution6MAS4
        'QuickBooks 2007/2008'      ,                 //saQBWO
        'CaseWare'                  ,                 //saCaseware
        'Generic'                   ,                 //saBK5CSV
        'The Client Accountant'     ,                 //saAccountSoft
        'Proflex'                   , // Obsolete     //saProflex
        'Teletax Ledger Windows'    , // Obsolete     //saTeletaxLW
        'Attache Business Partner'  ,                 //saAttacheBP
        'Solution 6 MAS [CLSY2K]'   ,                 //saSolution6CLSY
        'EasyBooks'                 ,                 //saEasyBooks
        'M/GL General Ledger'       ,                 //saMGL
        'Comparto'                  ,                 //saComparto
        'MYOB Accountants Enterprise Accounts',       //saXlon
        'Catsoft Ledgercat 2000'    ,                 //saCatSoft
        'BCS Accounting'            ,                 //saBCSAccounting
        'MYOB Accountants Office'   ,                 //saMYOBAccountan
        'Supercorp Superfund'            ,                 //saSolution6SuperFund
        'Ledger Assistant'          ,                 //saTaxAssistant
        'MYOB General Journals',                      //saMYOBGen
        'Accomplish CashManager',                     //saAccomplishCashManager
        'Praemium',                                   //saPraemium
        'Supercorp Supervisor II',                    //saSupervisor
        'Professional Accounting XPA 8',              //saXPA
        'Business Products - QIF',                    //saQIF
        'Business Products - OFX V1',                 //saOFXV1
        'Business Products - OFX V2',                 //saOFXV2
        'Ledger Elite',                               //saElite
        'MYOB AO (manual posting)',                   //saMYOB_COM
        'Desktop Super',                              //saDesktopSuper
        'BGL Simple Ledger',                          //saBGLSimpleLedger
        'Class Super',                                //saClassSuperIP
        'QuickBooks 2008/2009',                       // saQBWN
        'IRESS Xplan',                                //saIRESSXplan
        'superMate',                                  //saSuperMate
        'RewardSuper',                                //saRewardSuper
        'ProSuper',                                   //saProSuper
        'Sage HandiSoft SuperFund'                    //saSageHandisoftSuperfund
      );

      DESKTOP_SUPER_CHART_FILENAME = 'Desktop Super Chart List.csv';
      DESKTOP_SUPER_INVESTMENT_FILENAME = 'Desktop Super Investment List.csv';
      DESKTOP_SUPER_LEDGER_FILENAME = 'Desktop Super Ledger List.csv';
      DESKTOP_SUPER_MEMBER_FILENAME = 'Desktop Super Member List.csv';
      DESKTOP_SUPER_TRANS_FILENAME = 'Desktop Super Transaction Type List.csv';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   suOther                            = 0; suMin = 0;
   suSageLine50                       = 1;
   suQuickBooks                       = 2;
   suQIF                              = 3;
   suOFXV1                            = 4;
   suOFXV2                            = 5;
   suBK5CSV                           = 6;
   suTASBooks                         = 7; suMax = 7;

//UK systems to be added when we get spec for extracts
//   suDigita                           = ?;
//   suSage                             = ?;
//        'Digita Accounting',
//        'Sage Accounting',

   suNames : Array[ suMin..suMax ] of String[36] =
      //'123456789012345678901234567890'
      ( 'Other',
        'Sage 50 Accounts',                           //suSageLine50
        'QuickBooks',                             //suQuickBooks
        'Business Products - QIF',                //suOIF
        'Business Products - OFX V1',             //suOFXV1
        'Business Products - OFX V2',             //suOFXV2
        'Generic',                                //suBK5CSV
        'TASBooks'                                //suTASBooks
       );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Tax System Constants

   tsNone              = 0;      tsMin    = 0;
   tsBAS_XML           = 1;
   tsBAS_Sol6ELS       = 2;
   tsBAS_APS_XML       = 3;
   tsElite_XML         = 4;
   tsBAS_MYOB          = 5;
   tsBAS_HANDI         = 6;      tsMax    = 6;

   tsNames : Array[ tsMin..tsMax] of String[ 31] =
      (
        '(None)',
        'Standard XML Interface',
        'MYOB Accountants Enterprise Tax',
        'APS Tax',
        'Tax Elite',
        'MYOB Accountants Office Tax',
        'HandiSoft HandiTax'
      );

   tsSortOrder : Array[ tsMin..tsMax] of Byte =
     ( tsNone, tsBAS_APS_XML, tsElite_XML, tsBAS_Sol6ELS, tsBAS_XML, tsBAS_MYOB, tsBAS_HANDI);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   mxNo                = 0;  mxMin = 0;
   mxAmtEqual          = 1;
   mxOld_Yes           = 1;   //used prior to 5.3
   mxOld_FixVbl        = 2;   //used prior to 5.3
   mxAmtGreaterThan    = 3;
   mxAmtGreaterOrEqual = 4;
   mxAmtLessThan       = 5;
   mxAmtLessOrEqual    = 6;
   mxMax = 6;

   mxNames : Array[ mxMin..mxMax ] of String[ 30 ] = ( 'No',
                                                      'equal to',
                                                      '$/%',  //hidden
                                                      'larger than',
                                                      'larger than or equal to',
                                                      'smaller than',
                                                      'smaller than or equal to'
                                                      );

   mxSymbols : Array[ mxMin..mxMax ] of String[ 2 ] = ( '',
                                                      '=',
                                                      '$%',  //hidden
                                                      '>',
                                                      '>=',
                                                      '<',
                                                      '<='
                                                      );


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //Memorisation Line Type (M.L.T.)

   mltPercentage = 0;  mltMin = 0;
   mltDollarAmt  = 1;  mltMax = 1;

   mltNames : Array[ mltMin..mltMax ] of String[1] = ( '%', '$');  { $ May be changed by UpdateMF.PAS }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //Payee List Line Type

   pltPercentage = 0;  pltMin = 0;
   pltDollarAmt  = 1;  pltMax = 1;

   pltNames : Array[ pltMin..pltMax] of String[1] = ( '%', '$');   { $ May be changed by UpdateMF.PAS }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   fuUnknown   = 0;  fuMin = 0;
   fuInFunds   = 1;
   fuOverdrawn = 2;  fuMax = 2;
   fuNames : Array[ fuMin..fuMax ] of String[ 12 ] = ( 'Unknown', 'In Funds', 'Overdrawn' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   whNewZealand  = 0;  whMin = 0;
   whAustralia   = 1;
   whUK          = 2;  whMax = 2;
   whNames : Array[ whMin..whMax ] of String[ 20 ] =
   ( 'New Zealand', 'Australia', 'United Kingdom' );

   whShortNames : Array[ whMin..whMax ] of String[ 2 ] =
   ( 'NZ', 'AU', 'UK' );  // Used to name the Master Memorised Entry files and as an indicator on the screen

   whBankLinkWebSites : Array[ whMin..whMax ] of String[ 20 ] =
   ( 'www.banklink.co.nz', 'www.banklink.com.au', 'www.banklink.co.uk' );

   whBankLinkWebSiteURLs : Array[ whMin..whMax ] of String[ 30 ] =
   ( 'http://www.banklink.co.nz', 'http://www.banklink.com.au', 'http://www.banklink.co.uk' );

   whSupportPhoneNo : Array[ whMin..whMax ] of String[ 20 ] =
   ( '0800 226 554', '1 800 123 242', '0800 500 3081' );

   whSupportEmail : Array[ whMin..whMax ] of String[ 30 ] =
   ( 'support@banklink.co.nz', 'support@banklink.com.au', 'support@banklink.co.uk' );

   whClientServicesEmail : Array[ whMin..whMax ] of String[ 30 ] =
   ( 'clientservices@banklink.co.nz', 'clientservices@banklink.com.au', 'clientservices@banklink.co.uk' );

   whChequeEntryType : Array[ whMin..whMax ] of Byte = ( 0, 1, 1 );
   whWithdrawalEntryType : Array[ whMin..whMax ] of Byte = ( 49, 9, 9 );
   whDepositEntryType : Array[ whMin..whMax ] of Byte = ( 50, 10, 10 );
   whAutopaymentEntryType : Array[ whMin..whMax ] of Byte = ( 15, 3, 3 );
   whBankChangesEntryType : Array[ whMin..whMax ] of Byte = ( 13, 8, 8 );

   istUKNone = 0; istMin = 0;
   istUKNormal = 1;
   istUKHSBC = 2; istMax = 2;

   istUKNames : Array[ istMin..istMax ] of String[ 20 ] =
   ( 'None', 'Other', 'HSBC' );
   istUKTemplateFileNames : Array[ istMin..istMax ] of String[ 20 ] =
   ( '', 'UK_CAF_Template.pdf', 'UK_HSBC_Template.pdf' );

   ukCAFNameOfAccount = 'NameOfAccount';
   ukCAFClientCode    = 'ClientCode';
   ukCAFBankCode      = 'BankCode';
   ukCAFAccountNumber = 'AccountNumber';
   ukCAFCostCode      = 'CostCode';
   ukCAFBankName      = 'BankName';
   ukCAFBranchName    = 'BranchName';
   ukCAFStartMonth    = 'cmbStartMonth';
   ukCAFStartYear     = 'StartYear';
   ukCAFPracticeName  = 'PracticeName';
   ukCAFPracticeCode  = 'PracticeCode';
   ukCAFSupplyProvisionalAccounts = 'chkSupplyProvisionalAccounts';
   ukCAFMonthly       = 'radMonthly';
   ukCAFWeekly        = 'radWeekly';
   ukCAFDaily         = 'radDaily';
   ukCAFHSBCAccountSign1  = 'AccountSignatory1';
   ukCAFHSBCAccountSign2  = 'AccountSignatory2';
   ukCAFHSBCAddressLine1  = 'AddressLine1';
   ukCAFHSBCAddressLine2  = 'AddressLine2';
   ukCAFHSBCAddressLine3  = 'AddressLine3';
   ukCAFHSBCAddressLine4  = 'AddressLine4';
   ukCAFHSBCPostalCode    = 'PostalCode';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   whCurrencySymbols : Array[ whMin..whMax ] of String[1] = ( '$', '$', '£' );
   whCurrencyNames   : Array[ whMin..whMax ] of String[6] = ( 'Dollar', 'Dollar', 'Pound' );
   whCurrencyCodes   : Array[ whMin..whMax ] of String[3] = ( 'NZD', 'AUD', 'GBP' );


   whTaxSystemNames : Array[ whMin..whMax ] of String[10] = ( 'Gst', 'Gst', 'Vat' );
   whTaxSystemNamesUC : Array[ whMin..whMax ] of String[10] = ( 'GST', 'GST', 'VAT' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   rc1 = 0;  rcMin = 0;
   rc2 = 1;
   rc3 = 2; 
   rc4 = 3;
   rc5 = 4;  rcMax = 4;
   rcNames : Array[ rcMin..rcMax ] of String[ 1 ] =
   ( '1', '2', '3', '4', '5' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   fsNormal       = 0; fsMin = 0;
   fsOpen         = 1;
   fsCheckedOut   = 2;
   fsOffsite      = 3;
   fsError        = 4; fsMax = 4;

   fsNames : Array[ fsMin..fsMax ] of String[ 12 ] =
   ( '',
     'Open',
     'Read-only',
     'Off-site',
     'Error'
    );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   gbPayments     = 0; gbMin = 0;
   gbInvoice      = 1; gbMax = 1;

   gbNames : Array[ gbMin..gbMax ] of String[ 8 ] =
   ( 'Payments', 'Invoice' );

   //Australian Bas has different names for payments and invoice basis
   gbaNames : Array[ gbMin..gbMax ] of String[ 8 ] =
   ( 'Cash', 'Accrual');

   gbUKMin = 0;  gbuCash = 0;
   gbUKMax = 1;  gbuAccrual = 1;
   gbuNames : Array[ gbUKMin..gbUKMax ] of String[ 8 ] =
   ( 'Cash', 'Accrual' );

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   dfAdmin        = 0; dfMin = 0;
   dfConnect      = 1;
   dfFloppy       = 2; dfMax = 2;

   dfNames : Array[ dfMin..dfMax ] of String[ 20 ] =
   ( 'Admin System', 'BankLink Secure', 'Floppy Disk' );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   jtNormal       = 0; jtMin = 0;
   jtReversing    = 1;
   jtStanding     = 2;
   jtReversed     = 3;
   jtProcessed    = 4;
   jtReversal     = 5; jtMax = 5;

   jtNames : Array[ jtMin..jtMax ] of String[ 10 ] =
   ( 'Normal', 'Reversing', 'Standing', 'Reversed', 'Processed', 'Reversal' );

    EditableTypesSet = [jtNormal, jtReversing, jtStanding ]; 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   btBank            = 0; btMin = 0;
   btCashJournals    = 1;
   btAccrualJournals = 2;
   btGSTJournals     = 3;
   btStockJournals   = 4;          //non transferring
   btOpeningBalances = 5;          //non transferring
   btYearEndAdjustments = 6;       //non transferring
   btStockBalances = 7;            //non transferring

   btMax = 7;

   btForeign = btMax + 1; //Not a Direct type, but used in the filter...




   btNames : Array[ btMin..btMax ] of String[ 25 ] =
   //'1234567890123456789012345'
   ( 'Bank Account',
     'Cash Journals',
     'Accrual Journals',
     'GST Journals',
     'Stock/Adjustment Journals',
     'Opening Balances',
     'Year End Adjustments',
     'Stock Balances' );

   btReferences : Array[btMin..btMax ] of String [12] =
   ( '',
     'CASH JNL',
     'ACCRUAL JNL',
     'GST JNL',
     'ADJUST JNL',
     'OP BAL JNL',
     'YEAR END JNL',
     'STOCK JNL'
   );

   CashAccountsSet            = [ btBank, btCashJournals];
   NonTransferringJournalsSet = [ btGSTJournals, btStockJournals, btOpeningBalances, btYearEndAdjustments];
   NonTrfJournalsLedgerSet    = [ btGSTJournals, btStockJournals, btYearEndAdjustments];
   TransferringJournalsSet    = [ btBank, btCashJournals, btAccrualJournals];
   JournalsWithNoGSTSet       = [ btOpeningBalances, btYearEndAdjustments, btStockBalances];
   SchedRepSet                = [ btBank ];
   LedgerNoContrasJournalSet  = [ btCashJournals, btAccrualJournals, btGSTJournals, btStockJournals, btStockBalances ];

   // system bank account types
   sbtData = 0; sbtMin = 0; // can receive downloaded data
   sbtOffsite = 1; // offsite account has charges
   sbtProvisional = 2;
   sbtOnlineSecure = 3; sbtMax = 3; // provisional accounts

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//GST class types indicators NEW ZEALAND

   gtUndefined = 0;  gtMin = 0;
   gtOutputTax = 1;      gtIncomeGST      = 1;    // I
   gtInputTax  = 2;      gtExpenditureGST = 2;    // E
   gtExempt    = 3;                               // X
   gtZeroRated = 4;                               // Z
   gtCustoms   = 5;      gtMax = 5;               // C

   gtNames : array[ gtMin..gtMax ] of string[22] =
      ( 'Undefined',
        'Income',
        'Expenditure',
        'Exempt',
        'Zero Rated',
        'GST on Customs Invoice' );

   gtShortCodes : array[ gtMin..gtMax ] of string[3] =
      ( 'N',
        'I',
        'E',
        'X',
        'Z',
        'C');

   vtNoVAT                      = 0;    vtMin = 0;
   vtSalesStandard              = 1;
   vtSalesReduced               = 2;
   vtSalesZeroRated             = 3;
   vtSalesExempt                = 4;
   vtSalesECStandard            = 5;
   vtSalesECReduced             = 6;
   vtSalesECZeroRated           = 7;
   vtSalesECExempt              = 8;
   vtPurchasesStandard          = 9;
   vtPurchasesReduced           = 10;
   vtPurchasesZeroRated         = 11;
   vtPurchasesExempt            = 12;
   vtPurchasesECStandard        = 13;
   vtPurchasesECReduced         = 14;
   vtPurchasesECZeroRated       = 15;
   vtPurchasesECExempt          = 16;
   vtPurchasesOutsideScope      = 17; vtmax = 17;

   vtShortCodes : Array[ vtMin..vtMax ] of String[3] =
    (

      'N',    {    vtNoVAT                      }
      'SS',   {    vtSalesStandard              }
      'SR',   {    vtSalesReduced               }
      'SZ',   {    vtSalesZeroRated             }
      'SE',   {    vtSalesExempt                }
      'ESS',  {    vtSalesECStandard            }
      'ESR',  {    vtSalesECReduced             }
      'ESZ',  {    vtSalesECZeroRated           }
      'ESX',  {    vtSalesECExempt              }
      'PS',   {    vtPurchasesStandard          }
      'PR',   {    vtPurchasesReduced           }
      'PZ',   {    vtPurchasesZeroRated         }
      'PE',   {    vtPurchasesExempt            }
      'EPS',  {    vtPurchasesECStandard        }
      'EPR',  {    vtPurchasesECReduced         }
      'EPZ',  {    vtPurchasesECZeroRated       }
      'EPE',  {    vtPurchasesECExempt          }
      'POS'   {    vtPurchasesOutsideScope      }
    );

   vtNames : Array[ vtMin..vtMax ] of String[ 30 ] =
    (
      'No VAT',                       {    vtNoVAT                      }
      'Sales - Standard Rate',        {    vtSalesStandard              }
      'Sales - Reduced Rate',         {    vtSalesReduced               }
      'Sales - Zero Rate',            {    vtSalesZeroRated             }
      'Sales - Exempt',               {    vtSalesExempt                }
      'Sales EC - Standard Rate',     {    vtSalesECStandard            }
      'Sales EC - Reduced Rate',      {    vtSalesECReduced             }
      'Sales EC - Zero Rate',         {    vtSalesECZeroRated           }
      'Sales EC - Exempt',            {    vtSalesECExempt              }
      'Purchases - Standard Rate',    {    vtPurchasesStandard          }
      'Purchases - Reduced Rate',     {    vtPurchasesReduced           }
      'Purchases - Zero Rate',        {    vtPurchasesZeroRated         }
      'Purchases - Exempt',           {    vtPurchasesExempt            }
      'Purchases EC - Standard Rate', {    vtPurchasesECStandard        }
      'Purchases EC - Reduced Rate',  {    vtPurchasesECReduced         }
      'Purchases EC - Zero Rate',     {    vtPurchasesECZeroRated       }
      'Purchases EC - Exempt',        {    vtPurchasesECExempt          }
      'Purchases Outside Scope'       {    vtPurchasesOutsideScope      }
    );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//download options for client file. Connect and Floppy are for off-site clients

   dlAdminSystem     = 0; dlMin = 0;
   dlBankLinkConnect = 1;
   dlFloppyDisk      = 2; dlMax = 2;

   dlNames : array[ dlMin..dlMax ] of string[20] =
      ( 'Practice',
        'Internet',
        'Floppy Disk');

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Upload options for SmartBooks client file.

   ulSBFloppyDisk      = 0; ulSBMin = 0;
   ulSBInternet        = 1; ulSBMax = 1;

   ulSBNames : array[ ulSBMin..ulSBMax ] of string[20] =
      ( 'Floppy Disk',
        'Internet' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Export as options for SmartBooks client file.

   eaSBStandard         = 0; eaSBMin = 0;
   eaSBASCII            = 1; eaSBMax = 1;

   eaSBNames : array[ eaSBMin..eaSBMax ] of string[20] =
      ( 'Standard',
        'ASCII' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//update file status types
   usOkToImport      = 0; usMin = 0;
   usUnknownAccount  = 1;
   usInvalidDates    = 2;
   usErrorInFile     = 3;
   usNoForexSource   = 4;
   usForexRatesNeedUpdating = 5; usMax = 5;

   usNames : array[ usMin..usMax ] of string[20] =
      ( 'OK to Import',
        'Unknown Account',
        'Dates Overlap',
        'Error in file',
        'Forex Source Reqd',
        'Forex Update Reqd' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  UPC Status
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   ucNone            = 0; ucMin = 0;
   ucUnpresented     = 1;
   ucMatchingRef     = 2;
   ucMatchingAmount  = 3; ucMax = 3;

   ucNames : array[ ucMin..ucMax ] of string[4] =
      ( '', 'UNP!', 'REF!', 'AMT!' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  Cheque Numbers Expire When
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   ceNever          = 0; ceMin = 0;
   ce6Months        = 1;
   ce12Months       = 2;
   ce18Months       = 3;
   ce24Months       = 4; ceMax = 4;

   ceNames : array[ ceMin..ceMax ] of string[10] =
      ( 'Never', '6 Months', '12 Months', '18 Months', '24 Months' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  Report To File formats
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   rfCSV            = 0; rfMin = 0;
   rfFixedWidth     = 1;
   rfExcel          = 2;
   rfPDF            = 3;
   rfAcclipse       = 4;  rfMax = 4;
   {rfRTF            = 5; rfMax = 5;}

   rfNames : array [ rfMin.. rfMax] of string[30] =
      (
       'Comma Separated (CSV)',
       'Fixed Width Text (TXT)',
       'Microsoft Excel (XLS)',
       'Adobe Acrobat Format (PDF)',
       'CCH Web Manager'{,
       'Rich Text'}
       );

   rfFileExtn : array [ rfMin..rfMax] of string[4] =
      ( '.CSV','.TXT' , '.XLS', '.PDF', '.PDF'{, '.RTF'});

   bpOFXV1 = 0; bpMin = 0;
   bpOFXV2 = 1;
   bpQIF = 2; bpMax = 2;

   bpNames : array [ bpMin.. bpMax] of string[33] =
      (
       'Open Financial Exchange V1 (OFX)',
       'Open Financial Exchange V2 (OFX)',
       'Quicken Interchange Format (QIF)'
       );

   bpFileExtn : array [ bpMin..bpMax] of string[4] =
      ( '.OFX','.OFX', '.QIF' );

const
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  BAS Field Numbers and Names
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   bfG1  = 1;   bfMin = 1;
   bfG2  = 2;
   bfG3  = 3;
   bfG4  = 4;
   bfG7  = 5;
   bfG10 = 6;
   bfG11 = 7;
   bfG13 = 8;
   bfG14 = 9;
   bfG15 = 10;
   bfG18 = 11;
   bfW1  = 12;
   bfW2  = 13;
   bfW3  = 14;
   bfW4  = 15;
   bf1C  = 16;
   bf1D  = 17;
   bf1E  = 18;
   bf1F  = 19;
   bf1G  = 20;
   bf5B  = 21;
   bf6B  = 22;
   bf7   = 23;

   //new fields added sep 01
   bfGSTOption1  = 24;
   bfG1IncludesGST = 25;
   bfGSTOption2  = 26;
   bfGSTOption3  = 27;
   bfG21         = 28;
   bfG22         = 29;
   bfG23         = 30;
   bfG24         = 31;
   bfW5          = 32;
   bfPAYGOption1 = 33;
   bfT7          = 34;
   bfT8          = 35;
   bfT9          = 36;
   bfT4          = 37;
   bfPAYGOption2 = 38;
   bfT1          = 39;
   bfT2          = 40;
   bfT3          = 41;
   bfT11         = 42;
   bf1A          = 43;
   bf2A          = 44;
   bf4           = 45;
   bf5A          = 46;
   bf6A          = 47;
   bf8A          = 48;
   bf1B          = 49;
   bf1H          = 50;
   bf2B          = 51;
   bf8B          = 52;
   bf9           = 53;
   bfF1          = 54;
   bfF2          = 55;
   bfF3          = 56;
   bfF4          = 57;

   //more fields added 23 Jan 04

   bfG5          = 58;
   bfG6          = 59;
   bfG8          = 60;
   bfG9          = 61;
   bfG12         = 62;
   bfG16         = 63;
   bfG17         = 64;
   bfG19         = 65;
   bfG20         = 66;

   // Fuel tax credits june 06
   bf7c  = 67;
   bf7d  = 68;
   bfG2IncludesGST = 69;

   // IAS N october 06
   bfPAYGOption3 = 70;
   bfT6 = 71;
   bfT5 = 72;

   bfMax = 72;

   bfObsoleteFields = [ bf1G ];

   bfNames : Array[ bfMin..bfMax ] of String[80] =
      ( 'Total Sales',
        'Export Sales',
        'Other GST-Free supplies',
        'Input taxed sales & income & other supplies',
        'Adjustments',
        'Capital purchases',
        'Non-capital purchases',
        'Purchases for making input taxed sales',
        'GST-free purchases',
        'Estimated purchases for private use or not income tax deductible',
        'Adjustments',
        'Total of salary, wages and other payments',
        'Amounts withheld from salary, wages and other payments',
        'Amounts withheld from investment distributions where no TFN is quoted',
        'Amounts withheld from payment of invoices where no ABN is quoted',
        'Wine Equalisation tax payable',
        'Wine Equalisation tax refundable',
        'Luxury car tax payable',
        'Luxury car tax refundable',
        'Credit for wholesale sales tax',
        'Credit arising from reduced Pay As You Go instalments',
        'Credit arising from reduced fringe benefits tax instalments',
        'Deferred company/fund instalment',

        'Option 1: Calculate GST and report quarterly',
        'Does the amount shown at G1 include GST?',
        'Option 2: Calculate GST and report annually',
        'Option 3: Pay GST instalment amount',
        'ATO Instalment amount',                       //bfg21
        'Estimated net GST for the year',              //bfG22
        'Varied amount for the quarter',               //bfG23
        'Reason code for variation',                   //bfG24
        'Total amounts withheld',                      //bfW5
        'Option 1: Pay a PAYG instalment amount',      //bfPAYGOption1
        'ATO instalment amount',                       //bfT7
        'Estimated tax for the year',                  //bfT8
        'Varied amount for the quarter',               //bfT9
        'Reason code for variation',                   //bfT4
        'Option 2: Calculate PAYG instalment using income x rate', //bfPAYGOption2
        'PAYG Instalment income',                      //bfT1
        'Commissioner''s rate',                        //bfT2
        'New varied rate',                             //bfT3
        'T1 x T2 (or x T3)',                           //bfT11
        'GST on sales or GST instalment',              //bf1A
        '1A + 1C + 1E',                                //bf2A
        'Reason code for variation',                   //bf4
        'PAYG income tax instalment',                  //bf5A
        'FBT instalment',                              //bf6A
        '1A + 1C + 1E + 4 + 5A + 6A + 7',              //bf8A
        'GST on purchases',                            //bf1B
        'GST instalments',                             //bf1H
        '1B + 1D + 1F + 1H',                           //bf2B
        '1B + 1D + 1F + 5B + 6B',                      //bf8B
        '',                                            //bf9
        'ATO instalment amount',                       //bfF1
        'Estimated FBT for the year',                  //bfF2
        'Varied amount for the quarter',               //bfF3
        'Reason code for variation',                   //bfF4

        'G2 + G3 + G4',                                //bfG5
        'Total sales subject to GST',                  //bfG6
        'Total sales subject to GST after adjustments', //bfG8
        'GST on sales',                                //bfG9
        'G10 + G11',                                   //bfG12
        'G13 + G14 + G15',                             //bfG16
        'Total purchases subject to GST',              //bfG17
        'Total purchases subject to GST after adjustments', //bfG19
        'GST on purchases',                            //bfG20
        'Fuel tax credit over claim',                  //bf7c
        'Fuel tax credit',                             //bf7d
        'Does the amount shown at G1 include GST?',    //bfG2IncludesGST
        'Vary your PAYG instalment amount',            //bfPAYGOption1N
        'Varied instalment amount',                    //bfT6
        ''                                             //bfT5
      );

   bfFieldIDs  : Array[ bfMin..bfMax ] of String[3] =
      (
        'G1',
        'G2',
        'G3',
        'G4',
        'G7',
        'G10',
        'G11',
        'G13',
        'G14',
        'G15',
        'G18',
        'W1',
        'W2',
        'W3',
        'W4',
        '1C',
        '1D',
        '1E',
        '1F',
        '1G',
        '5B',
        '6B',
        '7',

        '',
        '',
        '',
        '',
        'G21',
        'G22',
        'G23',
        'G24',
        'W5',
        '',
        'T7',
        'T8',
        'T9',
        'T4',
        '',
        'T1',
        'T2',
        'T3',
        'T11',
        '1A',
        '2A',
        '4',
        '5A',
        '6A',
        '8A',
        '1B',
        '1H',
        '2B',
        '8B',
        '9',
        'F1',
        'F2',
        'F3',
        'F4',

        'G5',
        'G6',
        'G8',
        'G9',
        'G12',
        'G16',
        'G17',
        'G19',
        'G20',
        '7C',
        '7D',
        '',
        '',
        'T6',
        'T5'
      );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  BAS Balances
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   blGross     = 0;  blMin = 0;
   blNet       = 1;
   blTax       = 2;  blMax = 2;

   blNames : Array[ blMin..blMax ] of String[24] =
      ( 'Gross [ Net + Tax ]', 'Net [ Gross - Tax ]', 'Tax [ Gross - Net ]' );

//------------------------------------------------------------------------------
//  BAS Calculation Methods
//------------------------------------------------------------------------------

   bmFull        = 0;    bmMin = 0;
   bmSimplified  = 1;    bmMax = 1;

   bmNames : Array[ bmMin..bmMax ] of String[20] =
      ( 'Full Method', 'Simplified Method' );


//------------------------------------------------------------------------------
//  BAS Forms
//------------------------------------------------------------------------------
    bs2000  = 0;           bsMin = 0;
    bsBasA  = 1;
    bsBasC  = 2;
    bsBasD  = 3;
    bsBasF  = 4;
    bsBasG  = 5;
    bsIasB  = 6;
    bsIASI  = 7;
    bsIASJ  = 8;
    bsH     = 9;
    bsK     = 10;
    bsBasU  = 11;
    bsBasV  = 12;
    bsBasW  = 13;
    bsBasX  = 14;
    bsBasY  = 15;
    bsBasZ  = 16;
    bsIASN  = 17;          bsMax = 17;


    bsNames : Array[ bsMin..bsMax] of String[10] =
       ( 'BAS', 'A', 'C', 'D', 'F', 'G',
         'B', 'I', 'J',
         'P', 'Q', 'U', 'V', 'W', 'X', 'Y', 'Z', 'N');

//------------------------------------------------------------------------------
//  GST Provisional Tax and its Ratio settings use BAS Fields
//  Data in Bas Field 1  (bfGSTProvisional)
//  clBAS_Field_Source[bfGSTProvisional] =
//     0 No provisional
//     1 provisional
//  clBAS_Field_Number[bfGSTProvisional] is Use Ratio
//     0 No Ratio
//     1 Use Ratio
//  clBAS_Field_Percent[bfGSTProvisional] is the Ratio (with one decimal)
//------------------------------------------------------------------------------
   bfGSTProvisional  = 1;
   GSTprovisional = 1;
   GSTRatio = 1;


//------------------------------------------------------------------------------
//  UPI States
//------------------------------------------------------------------------------

   upNone            = 0;     upMin = 0;
   upUPC             = 1;
   upMatchedUPC      = 2;
   upBalanceOfUPC    = 3;
   upReversedUPC     = 4;
   upReversalOfUPC   = 5;

   upUPD             = 6;
   upMatchedUPD      = 7;
   upBalanceOfUPD    = 8;
   upReversedUPD     = 9;
   upReversalOfUPD   = 10;

   upUPW             = 11;
   upMatchedUPW      = 12;
   upBalanceOfUPW    = 13;
   upReversedUPW     = 14;
   upReversalOfUPW   = 15;    upMax = 15;

   upNames : Array[ upMin..upMax] of String[4] =
        ( '', 'UPC ', 'UPC*', '[*] ', 'UPC#', '[#] ',
              'UPD ', 'UPD*', '[*] ', 'UPD#', '[#] ',
              'UPW ', 'UPW*', '[*] ', 'UPW#', '[#] ');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// financial reporting periods for use by Cash flow, profit and loss etc
   frpNone            = 0;      frpMin = 0;
   frpWeekly          = 1;
   frpFortnightly     = 2;
   frpFourWeekly      = 3;
   frpMonthly         = 4;
   frp2Monthly        = 5;
   frpQuarterly       = 6;
   frp6Monthly        = 7;
   frpYearly          = 8;
   frpCustom          = 9;

   frpMax = 9;

   frpNames : Array[ frpMin..frpMax ] of String[11] =
       (
         'None',
         'Weekly',
         'Fortnightly',
         'Four Weekly',
         'Monthly',
         'Two Monthly',
         'Quarterly',
         'Six Monthly',
         'Annually',
         'Custom'
       );

   pdMaximumNoOfPeriods : Array[ frpMin..frpMax ] of integer =
       (
         0,             //None
         53,            //Weekly
         37,            //Fortnightly
         14,            //Four Weekly
         12,            //Monthly
         6,             //Two Monthly
         4,             //Quarterly
         2,             //Six Monthly
         1,             //Annually
         1              //Custom
       );

    IncBy : array[ frpMin..frpMax ] of Integer =
       (
         0,             //None
         7,             //Weekly
         14,            //Fortnightly
         28,            //Four Weekly
         1,             //Monthly
         2,             //Two Monthly
         3,             //Quarterly
         6,             //Six Monthly
         12,            //Annually
         0              //Custom
       );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// cash flow report styles
   crsSinglePeriod    = 0;      crsMin = 0;
   crsMultiplePeriod  = 1;
   crsBudgetRemaining = 2;      crsMax = 2;

   crsNames : Array[ crsMin..crsMax] of String[16] =
      (
        'Single Period',
        'Multiple Period',
        'Budget Remaining'
      );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// period settings for automatic journals
   jpsNextMonth      = 0;      jpsMin = 0;
   jpsTwoMonths      = 1;
   jpsThreeMonths    = 2;
   jpsFiveMonths     = 5;
   jpsSixMonths      = 3;
   jpsElevenMonths   = 6;
   jpsNextYear       = 4;
   jpsNextWeek       = 7;      jpsWeekly = 7;
   jpsTwoWeeks       = 8;
   jpsThreeWeeks     = 9;
   jpsFourWeeks      = 10;
   jpsNextDay        = 11;      jpsMax = 11;

   jpsNames : Array[ jpsMin..jpsMax] of String[16] =
      (
        'Next Month',
        'in 2 Months',
        'in 3 Months',
        'in 5 Months',
        'in 6 Months',
        'in 11 Months',
        'Next Year',
        'Next Week',
        'in 2 Weeks',
        'in 3 Weeks',
        'in 4 Weeks',
        'Next Day'
      );

   jpsComboBoxOrder : array [ jpsMin..jpsMax ] of Byte =
      (
       jpsNextMonth,
       jpsTwoMonths,
       jpsThreeMonths,
       jpsFiveMonths,
       jpsSixMonths,
       jpsElevenMonths,
       jpsNextYear,
       jpsNextWeek,
       jpsTwoWeeks,
       jpsThreeWeeks,
       jpsFourWeeks,
       jpsNextDay
      );

// duration settings for automatic journals
   jpdNA          = 0;   jpdMin = 0;
   jpd12Months    = 1;
   jpd24Months    = 2;
   jpd36Months    = 3;   jpdMax = 3;

   jpdNames : Array[ jpdMin..jpdMax] of String[13] =
      (
        'n/a',
        'for 12 Months',
        'for 24 Months',
        'for 36 Months'
      );

   jpdComboBoxOrder : array [ jpdMin..jpdMax ] of Byte =
      (
       jpdNA,
       jpd12Months,
       jpd24Months,
       jpd36Months
      );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//cashflow reporting constants
   cflCompare_None         = 0;
   cflCompare_To_Budget    = 1;
   cflCompare_To_Last_Year = 2;

   cflReport_Detailed      = 0;
   cflReport_Summarised    = 1;

   cflCash_On_Hand_None       = 0;
   cflCash_On_Hand_Detailed   = 1;
   cflCash_On_Hand_Summarised = 2;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// User Type constants
//
   ustMin = 0;
   ustRestricted = 0;
   ustNormal = 1;
   ustSystem = 2;
   ustMax = 2;

   ustNames : Array[ ustMin..ustMax] of String[10] =
      (
        'Restricted',
        'Normal',
        'System'
      );
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// User Suppress Header Footer Constants
//
   shfUndefined = 0; shfUnchecked = 1; shfChecked = 2;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Contact Details to show in client files

   cdtMin = 0;

   cdtPractice = 0;
   cdtStaffMember = 1;
   cdtCustom = 2;

   cdtMax = 2;

   cdtNames : Array[ cdtMin..cdtMax] of String[ 20] =
     (
       'Practice Details',
       'Staff Member',
       'Custom'
     );


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Scheduled Reports Destinations

   srdNone       = 0;  srdMin = 0;
   srdPrinted    = 1;
   srdEmail      = 2;
   srdFax        = 3;
   srdECoding    = 4;
   srdCSVExport  = 5;
   srdWebX       = 6;
   srdCheckOut   = 7;
   srdBusinessProducts = 8;
   srdOnline     = 9; srdMax = 9;

   srdNames : Array[ srdMin..srdMax] of String[ 20] =
     ( 'None', 'Printer', 'Email', 'Fax', ECodingDisplayName, 'CSV Export', 'Web', 'BankLink Books', 'Business Products', 'BankLink Online');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Scheduled Reports Report To Send
   srsNone      = 0;
   srsCoding    = 1;
   srsPayee     = 2;
   srsChart     = 4;
   srsJob       = 5;   

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Schedule Reports Sort By Options
  srsoClientCode = 0;
  srsoStaffMember = 1;
  srsoGroup = 2;
  srsoClientType = 3;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Schedule Reports Selection Options
  srslAll = 0;
  srslRange = 1;
  srslSelection = 2;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Task tracking
   ttNeverPrompt       = 0;
   ttOnlyIfOutstanding = 1;
   ttAlwaysPrompt      = 2;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Task Types
    ttyManual           = 0;
    ttyCodingReport     = 1; ttyAutoMin = 1;
    ttyExportBNotes     = 2;
    ttyExportWeb        = 3;
    ttyCheckOut         = 4;
    ttyCheckIn          = 5;
    ttyQueryEmail       = 6; ttyAutoMax = 6;
    //Leave Room for more Automatic Tasks
    ttyMailMergePrint   = 100; //Mail Merge is handled seperatly from normal task settings
    ttyMailMergeEmail   = 101; 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Analysis Coding Level

   acEnabled          = 0;
   acRestrictedLevel1 = 1;
   acRestrictedLevel2 = 2;
   acDisabled         = 3;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// sff Super Fund Fieldnames

   sff_Imputed_Credit             = 0;  sff_Min = 0;
   sff_Tax_Free_Dist              = 1;
   sff_Tax_Exempt_Dist            = 2;
   sff_Tax_Deferred_Dist          = 3;
   sff_TFN_Credits                = 4;
   sff_Foreign_Income             = 5;
   sff_Foreign_Tax_Credits        = 6;
   sff_Capital_Gains              = 7;
   sff_Discounted_Capital_Gains   = 8;
   sff_Capital_Gains_Other        = 9;
   sff_Other_Expenses             = 10;
   sff_CGT_Date                   = 11;
   sff_Franked                    = 12;
   sff_Unfranked                  = 13;
   sff_Interest                   = 14;
   sff_CG_Foreign_Disc            = 15;
   sff_Rent                       = 16;
   sff_Special_Income             = 17;
   sff_Other_Tax_Credit           = 18;
   sff_Non_Resident_Tax           = 19;
   sff_Foreign_CG_Credits         = 20;
   sff_Member_ID                  = 21;
   sff_Member_Component           = 22;
   sff_Transaction_Type           = 23; sff_Max = 23;

   sffNames : Array[ sff_Min..sff_Max] of String[ 20] =
     ( 'Imputed Credits',
       'Tax Free Dist',
       'Tax Exempt Dist',
       'Tax Deferred Dist',
       'TFN Credits',
       'Foreign Income',
       'Foreign Tax Credits',
       'Capital Gains Index',
       'Capital Gains Dist',
       'Capital Gains Other',
       'Other Expenses',
       'CGT Date',
       'Franked',
       'Unfranked', '', '', '', '', '', '', '', '', 'Member Component', '');

   sffNamesSupervis : Array[ sff_Min..sff_Max] of String[ 30] =
     ( 'Imputation Credit',
       'Tax Free Trust',
       'Non-Taxable',
       'Tax Deferred',
       'Withholding Credit',
       'Foreign',
       'Foreign Credit',
       'Capital Gain',
       'Discount Capital Gain',
       'Foreign Capital Gain',
       'Other Taxable',
       '',
       'Franked',
       'Unfranked',
       'Interest',
       'Foreign Discount Capital Gain',
       'Rent',
       'Special Income',
       'Other Tax Credit',
       'Non-resident Tax',
       'Foreign Capital Gain Credit',
       'Member ID', '', '');

   sffNamesDesktop : Array[ sff_Min..sff_Max] of String[ 30] =
     ( 'Franking Credit',
       'Tax Free Trust',
       'Non-Taxable',
       'Tax Deferred',
       'TFN Credit',
       'Foreign Income',
       '',
       'Capital Gain Conc',
       'Capital Gain Disc',
       'Capital Gain Other',
       'Other Taxable',
       'CGT / Tax Date',
       'Franked',
       'Unfranked',
       '',
       '',
       '',
       'Undeducted Contrib',
       'ABN credit',
       '',
       'Foreign Tax Credit',
       'Member Account', 'Investment Code', 'Transaction Type');

   sffNamesHandisoftSuperfund : array[sff_Min..sff_Max] of string[ 30] =
      ( 'Franking Credit',
        '', '', '', '', '', '', '', '', '', '', '',
        'Franked Amount',
        'Unfranked Amount', '', '', '', '', '', '', '', '', '',
        'Transaction' );

CONST
   MaxChequeLength    = 6;          //would like to extend this to 8 digits
                                    //only reason not to is the exports as
                                    //most of them trim to 6 digits.
   ChequeNoMask       = '999999';   //must be same length as MaxChequeLength

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Software Flags
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   sfUnlimitedDateTempAccounts = 1;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Client Manager INI columns IDs
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const
  //ini ids for columns (I)ni (C)lient manager (ID)
  icid_Min = 0;

  icid_Code     = 0;
  icid_Name     = 1;
  icid_Action   = 2;
  icid_ReminderDate = 3;
  icid_Status   = 4;
  icid_User = 5;
  icid_ReportingPeriod = 6;
  icid_SendBy = 7;
  icid_LastAccessed = 8;
  icid_FinYearStarts = 9;
  icid_ContactType = 10;
  icid_Unknown = 11;
  icid_Processing = 12;
  //icid_Starts = 13; no longer used - cant re-use id 13 in case existing users have it configured
  icid_Group = 14;
  icid_ClientType = 15;
  icid_NextGSTDue = 16;
  icid_BankLinkOnline = 17;
  icid_ModifiedDate = 18;
  icid_BOProduct = 19;
  icid_BOBillingFrequency = 20;
  icid_BOUserAdmin = 21;
  icid_BOAccess = 22;
  icid_BOBulkExport = 23;

  icid_Max = 23;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   fxtNone = 0; fxtMin = 0;
   fxtWindowsFaxService = 1;
   fxtWinFax     = 2; fxtMax = 2;

   fxtNames : Array[ fxtMin..fxtMax ] of String[ 20 ] =
      ( 'None', 'Windows Fax Service', 'WinFax');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Font styleas for reports
  bkfsRegular = 0; bkfsMin = 0;
  bkfsItalic = 1;
  bkfsBold = 2;
  bkfsBoldItalic = 3; bkfsMax = 3;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ecDestFile  = 0;
   ecDestEmail = 1;
   ecDestWebX = 2;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // ECoding import options
   noFillWithPayeeName = 0;
   noFillWithNotes     = 1;
   noFillWithBoth      = 2;

   noDontOverwrite     = 16;
   noHideExample       = 32;
   noAppend            = 64;

   noDontFill          = 128;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   wfNone = 0; wfMin = 0;
   wfWebX = 1;
   wfWebNotes = 2; wfMax = 2;

   wfDefault = wfNone;
 

   wfNames : Array[ wfMin..wfMax ] of String[ 25 ] =
      ( 'None', WebXDisplayName,  WebNotesName);

   // Notify options for pClient_File_Rec.cfWebNotes_Email_Notifications
   wnDontNotifyClient = $0001;
   wnDontNotifyMe     = $0002;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Fields for importing prospects
   pfCode = 0; pfMin = 0;
   pfClientName = 1;
   pfAddr1 = 2;
   pfAddr2 = 3;
   pfAddr3 = 4;
   pfSalutation = 5;
   pfContactName = 6;
   pfPhone = 7;
   pfFax = 8;
   pfMobile = 9;
   pfEmail = 10;
   pfUser = 11; pfMax = 11;

   pfNames : Array[ pfMin..pfMax ] of String[ 20 ] =
      ( 'clientcode',
        'clientname',
        'address1',
        'address2',
        'address3',
        'salutation',
        'contactname',
        'phone',
        'fax',
        'mobile',
        'email',
        'user');
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Client types
   ctActive = 0; ctMin = 0;
   ctProspect = 1; ctMax = 1;
   ctNames: array[ctMin..ctMax] of string[20] =
    ( 'Client',
      'Prospect' );

   // Client Manager default filters
   filterAllClients = 0; filterMin = 0;
   filterMyClients = 1;
   filterAllProspects = 2;
   filterMyProspects = 3; filterMax = 3;
   //filterAllArchived = 4;
   //filterMyArchived = 5; filterMax = 5;

   filterNames : array[ filterMin..filterMax ] of string[20] =
      ( 'All Clients',
        'My Clients',
        'All Prospects',
        'My Prospects'{,
        'All Archived Clients',
        'My Archived Clients'} );

   // Filter config options
   // Client types in the filter, Minimum user level for access, File filter
   filterConfig : array [ filterMin..filterMax ] of array[0..2] of Byte =
      ( ( ctActive, ustNormal, Ord(vmAllFiles) ),
        ( ctActive, ustNormal, Ord(vmMyFiles) ),
        ( ctProspect, ustNormal, Ord(vmAllFiles) ),
        ( ctProspect, ustNormal, Ord(vmMyFiles) ){,
        ( ctActive, ustNormal, Ord(vmAllFiles) ),
        ( ctActive, ustNormal, Ord(vmMyFiles) )} );
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Manual bank account types
   mtLoan = 0; mtMin = 0;
   mtPCCard = 1;
   mtBCCard = 2;
   mtTrust = 3;
   mtCash = 4;
   mtSavings = 5;
   mtCheque = 6;
   mtOther = 7;
   mtSuper = 8; mtMax = 8;

   mtNames : Array[ mtMin..mtMax ] of String[ 22 ] =
      ( 'Loan',
        'Personal credit card',
        'Business credit card',
        'Trust (CMT)',
        'Cash',
        'Savings',
        'Cheque',
        'Other',
        'Self-managed superfund');

   // 'Self-managed superfund' and 'Trust (CMT)' are Australia only
   AccountTypeExclusionsNZ = [mtTrust, mtSuper]; 
   AccountTypeExclusionsUK = [mtTrust, mtSuper];

   // No exclusions needed for Australia as of yet

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // period types for payee report totals
  ptMonthly = 0; ptMin = 0;
  ptBi = 1;
  ptQuart = 2; ptMax = 2;

  ptNames : Array[ptMin..ptMax] of string[10] =
    ('Monthly', 'Bi-monthly', 'Quarterly');
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Practice Management (export Charges) Systems
  xcNA = 0; xcMin = 0;
  xcOther = 1;
  xcAPS = 2;
  xcMYOB = 3;
  xcMYOBAO = 4;
  xcHandi = 5; xcMax = 5;

  xcNames : Array[xcMin..xcMax] of string[26] =
    ('<None>',
    'Other System',
    'APS Advance',
    'MYOB Viztopia',
    'MYOB Accountants Office',
    'HandiSoft Time and Billing');

  xcHasFixedFilename : Array[xcMin..xcMax] of Boolean =
    (False,  //na
     False,  //other
     True,   //APS
     False,  //Myob
     False,  //MyobAO
     False); //Handi

  xcFilenames : Array[xcMin..xcMax] of string[12] =
    ('',             //na
     '.csv',         //Other
     'banklink.csv', //APS
     '.txt',         //Myob
     '.csv',         //MyobAO
     '.csv');        //Handi

  xcSaveFilters : Array[xcMin..xcMax] of string[24] =
    ('',                          //na
     'CSV Files (*.csv)|*.csv',   //Other
     '',                          //APS
     'Text Files (*.txt)|*.txt',  //Myob
     'CSV Files (*.csv)|*.csv',   //MyobAO
     'CSV Files (*.csv)|*.csv' ); //Handi

  apsClient = 1;
  apsMatter = 2;


  SHOW_ALL_TX = 0;
  SHOW_UNCODED_TX = 1;
  SHOW_NOTES_TX = 2;
  SHOW_UnReadNOTES_TX = 3;
  SHOW_NoNOTES_TX = 4;

  // config columns template dialog IDs
  CODING_SCREEN = '';
  DISSECTION_SCREEN = 'D';
  MDE_SCREEN = 'M';
  HDE_SCREEN = 'H';
  CASHJNL_SCREEN = 'J';
  ACCRUALJNL_SCREEN = 'A';
  STOCKJNL_SCREEN = 'S';
  YEAREJNL_SCREEN = 'Y';
  GSTJNL_SCREEN = 'G';

  // Old BGL member components In use for transactions before  01/07/2007
  mcOldNA = 0; mcOldMin = 0;
  mcOldGCTExempt = 1;
  mcOldNonQual = 2;
  mcOldConcession = 3;
  mcOldUnCont = 4;
  mcOldUnGov = 5;
  mcOldNonMand = 6;
  mcOldJune94 = 7;
  mcOldJuly83 = 8;
  mcOldJune83Tax = 9;
  mcOldJune83TaxS = 10;
  mcOldJune83UnTax = 11;
  mcOldJune83UnTaxS = 12; mcoldMax = 12;

  mcOldNames : Array[ mcOldMin..mcOldMax ] of String[ 33 ] =
      ( 'N/A',
        'CGT Exempt',
        'Non qualifying',
        'Concessional',
        'Undeducted contributions',
        'Undeducted Gov’t Co contributions',
        'Non Mandated contributions',
        'Post June 1994 Invalidity',
        'Pre Jul 1983',
        'Post June 1983 - Taxed',
        'Post June 1983 - Taxed (S/C)',
        'Post June 1983 - Untaxed',
        'Post June  1983 - Untaxed (S/C)');

  mcOldCharacters : Array[mcOldMin..mcOldMax] of Char =
     (' ',
      'G',
      'N',
      'C',
      'U',
      'O',
      'M',
      'I',
      'L',
      'P',
      'Z',
      'S',
      'Y');

  // New BGL member components In use for transactions After 30/06/2007
  mcSwitchDate = 148835; // 1/7/2007
  mcNewNA = 0; mcNewMin = mcNewNA;

  mcNewEmployerContributions = 1;
  mcNewPersonalDeductible = 2;
  mcNewPersonalNonConcessional = 3;
  mcNewCGTRetirementExemption = 4;
  mcNewSmallBusiness15year = 5;
  mcNewPersonalInjuryElection = 6;
  mcNewSpouseChildContributions = 7;
  mcNewOtherFamilyandFriendContributions = 8;
  mcNewDirectedTerminationPayment = 9;
  mcNewAssessableForeignFund = 10;
  mcNewNonAssessableForeignFund = 11;
  mcNewTransferredFromReservesAssessable = 12;
  mcNewTransferredFromReservesNonAssessable = 13;

  mcNewContributionsToPreviousNonComplyingFund = 14;
  mcNewNonMandatedContributions = 15;
  mcNewGovtCoContributions = 16;

  mcNewContributionReservesPersonalConcessional = 17;
  mcNewContributionReservesPersonalNonConcessional = 18;
  mcNewContributionReservesEmployerConcessional = 19; mcnewMax = mcNewContributionReservesEmployerConcessional;

  mcNewNames : Array[ mcNewMin..mcnewMax ] of String[ 53 ] =

     ('N/A',
      'Employer Contributions',
      'Personal Contributions (Tax Deductible)',
      'Personal Contributions (Non Concessional)',
      '(CGT) cap Small Business Retirement Exemption',
      '(CGT) cap Small Business 15 year',
      'Personal Injury Election',
      'Spouse and Child Contributions',
      'Other Family and Friend Contributions',
      'Directed Termination Payment',
      'Assessable Foreign Fund',
      'Non Assessable Foreign Fund',
      'Transferred from Reserves Assessable',
      'Transferred from Reserves Non Assessable',
      'Contributions to Previous Non Complying Fund',
      'Non Mandated Contributions',
      'Govt Co Contributions',
      'Contribution Reserves (Personal Concessional)',
      'Contribution Reserves (Personal Non Concessional)',
      'Contribution Reserves (Employer Concessional)'
      );

 mcNewCharacters : Array[mcNewMin..mcNewMax] of string[3] =
     (' ',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19'
      );

  RESTRICTED_MODE_STRING = 'Restricted to Account and Amount';
  RESTRICTED_MODE_STRING_CES = 'Restricted to Account';
  ALL_MODE_STRING = 'All Editable Columns';

  //Node Types in client manager
  ntGroup    = 0;
  ntClient   = 1;

  // CM subfilters

  cmfsTopAction = 0; cmfsTopMin = 0;
  cmfsTopStatus = 1;
  cmfsTopUser = 2;
  cmfsTopFreq = 3;
  cmfsTopSend = 4;
  cmfsTopData = 5;
  cmfsTopGroup = 6;
  cmfsTopClientType = 7;
  cmfsTopClientCoding = 8;
  cmfsTopGSTDue = 9; cmfsTopMax = 9;

  cmfsTopLevel: Array [ cmfsTopMin..cmfsTopMax ] of string =
  ('Action', 'File Status', 'User', 'Report Schedule', 'Send By', 'Data', 'Group', 'Client Type','Coding', 'GST Due');

  cmfsCheckOut = 0;   cmfsMin = 0;
  cmfsSynch = 1;
  cmfsUnsynch = 2;
  cmfsBooks = 3;
  cmfsSecure = 4;
  cmfsAction = 5;
  cmfsLater = 6;
  cmfsNoAction = 7;
  cmfsUnassigned = 8;
  cmfsSPrint = 9;
  cmfsSEmail = 10;
  cmfsSFax = 11;
  cmfsSNotes = 12;
  cmfsSCSV = 13;
  cmfsSWeb = 14;
  cmfsSCheckOut = 15;
  cmfsSDont = 16;
  cmfsSMonth = 17;
  cmfsS2Month = 18;
  cmfsS3Month = 19;
  cmfsS4Month = 20;
  cmfsS6Month = 21;
  cmfsSAnnual = 22;
  cmfsSMQ = 23;
  cmfsSM2M = 24;
  cmfsS2MM = 25;
  cmfsNoData = 26;
  cmfsData = 27;
  cmfsArchive = 28;
  cmfsUnassignedGroup = 29;
  cmfsUnassignedClientType = 30;
  cmfsNotArchive = 31;
  cmfsCoded = 32;
  cmfsNotCoded = 33;
  cmfsGSTThisMonth = 34;
  cmfsGSTNextMonth = 35;
  cmfsGST2MonthsOrMore = 36;
  cmfsGSTNotApplicable = 37; cmfsMax = 37;

  cmfsBits: Array[ cmfsMin..cmfsMax ] of UInt64 = // represents a ticked option within a filter group
  ($1, $2, $4, $8, $10, $20, $40, $80, $100, $200, $400, $800,
   $1000, $2000, $4000, $8000, $10000, $20000, $40000, $80000, $100000, $200000,
   $400000, $800000, $1000000, $2000000, $4000000, $8000000, $10000000, $20000000,
   $40000000, $80000000, $100000000, $200000000, $400000000, $800000000, $1000000000,
   $2000000000);

  cmfsNames: Array[ cmfsMin..cmfsMax ] of String =
  (
    'Read-only',
    'Synchronised',
    'Unsynchronised',
    'BankLink Books',
    'BankLink Books (Secure)',
    'Action Required Now',
    'Action Required Later',
    'Action Not Required',
    'Unassigned User',
    'Send To Printer',
    'Send To Email',
    'Send To Fax',
    'Send To ' + ECodingDisplayName,
    'Send To CSV Export',
    'Send To Web',
    'Send To BankLink Books',
    'Don''t Send Report',
    'Report Every Month',
    'Report Every Two Months',
    'Report Every Three Months',
    'Report Every Four Months',
    'Report Every Six Months',
    'Report Annually',
    'Report Every Month and Quarter',
    'Report Every Month and Two Months',
    'Report Every Two Months then Month',
    'No transactions in the last 12 months',
    'Transactions in the last 12 months',
    'Archived',
    'Unassigned Group',
    'Unassigned Client Type',
    'Not Archived',
    'Coded Clients',
    'Uncoded Clients',
    'This Month',
    'Next Month',
    'Two Months or More',
    'Not Applicable'
  );

  cmfsFilterGroup: Array [cmfsMin..cmfsMax] of Integer =
  ( // matches list cmfsNames above
    cmfsTopStatus,
    cmfsTopStatus,
    cmfsTopStatus,
    cmfsTopStatus,
    cmfsTopStatus,
    cmfsTopAction,
    cmfsTopAction,
    cmfsTopAction,
    cmfsTopUser,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopSend,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopFreq,
    cmfsTopData,
    cmfsTopData,
    cmfsTopStatus,
    cmfsTopGroup,
    cmfsTopClientType,
    cmfsTopStatus,
    cmfsTopClientCoding,
    cmfsTopClientCoding,
    cmfsTopGSTDue,
    cmfsTopGSTDue,
    cmfsTopGSTDue,
    cmfsTopGSTDue
    );

    FILTER_ALL = 'No Filter';


  safsTopStatus = 0; safsTopMin = 0;
  safsTopDeleted = 1;
  safsTopTransactions = 2;
  safsTopCharges = 3;
  safsTopPassword = 4;
  safsTopDeliver = 5;
  safsTopFrequency = 6; safsTopMax = 6;

  safsTopLevel: Array [ safsTopMin..safsTopMax ] of string =
  ('Status', 'Deleted', 'Transactions', 'Charges', 'Password', 'Account Type', 'Frequency');


    DefaultCESFontString = '"Courier","",9';

  // Auto purging
  exMin = 0;
  exMax = 6;

  exYears : Array[exMin..exMax] of Byte = (0, 2, 3, 4, 5, 6, 7);
  exNames : Array[exMin..exMax] of string[12] =
    ('Never Prompt', '2 Years', '3 Years', '4 Years', '5 Years', '6 Years', '7 Years');

  // Disk Image Frequency
  difUnspecified = 0;  difMin = 0;
  difMonthly     = 1;
  difWeekly      = 2;
  difNotUsed     = 3;  //not used
  difDaily       = 4;  difMax = 4;

  difFrequencyNames : array[difMin..difMax] of string[10] = ('', 'Monthly', 'Weekly', '', 'Daily');

Const
  ForexDP : Integer = 5;

  //Client file transfer methods
  ftmNone   = 0;  ftmMin = 0;
  ftmFile   = 1;
  ftmEmail  = 2;
  ftmOnline = 3;  ftmMax = 3;

  ftmTransferMethods: array[ftmMin..ftmMax] of string[20] = ('None', 'File', 'Email', 'Online');

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
IMPLEMENTATION
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

END.
