Unit BKDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   BK_IOLIB_Version : Integer = 774;
   BK_IOLIB_Date    = '29/02/16';
   BK_FILE_VERSION  = 188;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   BK_FILE_VERSION_STR = '5.41';   (* Should be changed whenever BK_FILE_VERSION changes. Is used to show user what version they need *)
   
   (*
       History  :     31    New format for GST class codes ( delimited string)
                      33    Account Codes now String[20]
                      35    New fields in the Balance List Item record
                      36    New format for GST Class codes ( array )
                      37    MAX_GST_CLASS now 99, was 20.
                      38    New field added to store tax ledger code for sol 6 etc
                      39    New fields for determining how the BAS fields are calculated
                      40    Business Norm Percentages added for AU
                      41    GST Has Been Edited fields added to Transactions, Dissections, Memorised Transactions
                      42    BAS calculation methods added
                            Bank Account Expiry Date added for HDE
                      43    Matched Item ID added to transaction
                            Highest Matched Item ID added to Bank Account
                            Included in 5.1.59.x
                      44    BAS PAYG period field added to client
                      45    GST class added to payee
                      46    GST Has Been Edited field added to payee
                      47    Payee field added to dissection lines
                      48    UPI State field added to transaction for use at later date
        5.1.60.5      49    Changes for new UPI coding.
        5.1.60.9      50    No structural changes.  Forces an upgrade of the gst balances info
        5.1.61.0      51    Report Sub Headings array added.  Sub type setting added to chart.
                            Fax Setting Added for later use.
                            Max payee lines extend to 50
        5.1.61.1      52    Added Notes String Array Field
                            Added clCheques_Expire_When Field for later use.
            61.3      53    Added flag for show client notes on open
            62.0      54    Added flags for ECoding Options
            62.8      55    Added flags for schedule reports changes
            62.15     56    Added BAS_PAYG_Instalment_Period and BAS_Include_FBT-WET-LCT
            62.18     57    Additional ECoding vars
            62.25     58    Added notes to memorisations
            64.2      59    Added 'Reversal' state to journals
                            Added baColumn_Not_Editable to baFields
                            Added buEstimated_Opening_Bank_Balance
                            Extended Memorisation Lines to 50
        5.2.0.1	     60    Added GLNarration field and Statement Details fields.
                      61    Added flag for ECoding Import Options
                            Added fields for default ecoding import/exports dirs
                      62    Added GLNarration field to dissections.
                      64    Added narration fields into payees
                            Added narration fields to memorisations
                      65    Extended Sub Group Heading Array to 255
                      66    Added new fields to support new options for financial reports
                            Added non-persistent fields for period, budget, and divisions used in cash flow reporting
                            Added non-persistent fields for temporary opening balances to chart
                      67    Added NEW record type for sub group headings
                      68    Added link accounts records to chart
        5.2.0.23      69    Added Headings for Balance Sheet
                      70    Added field to store last financial year
                      71    Changed to force upgrade of sub groups
   		     72    Changed to force upgrade of report groups for alpha versions
                      73    Added NEW record type for division headings
                      74    Added NEW record type to hold ALL custom headings
              .47     75    Added new field to store csv export flag
                            Added fields to store tax interface type and dir
                      76    Added new transaction field to store tax invoice and temp balance field
                      77    No structure change, just force upgrade of stored coding report settings
                      78    Added reversal date to dissections so can use for jnls
        5.2.0.56      79    Added field to store processing period for automatic journals
                      80    No structure change, force upgrade of Payee names
                            Added field to store disk image format last used
        5.2.0.74      81    Added field so can tell in client file if unlimited temp accounts are available
                            Added field to store practice web site address
        5.2.1.97      82    Added field for practice logo
                            Added Website login URL
                            Added ability to select optional contact details to show
                            Added more ecoding export flags to hide columns
                            Added more ecoding attachment list
                      83    Separated out settings for manual and scheduled coding report
                            Added Scheduled Client Note Message
                            Added Last Auto Save CRC and File Read Only temporary fields.
                      84    Added Is A Manual Account flag.
                            Added Custom Contact details to Client.
                      85    Added flag to indicate that contact details have been changed
                      86    Added field to store counter for manual accounts
                      87    Added field to store analysis coding setting at bank account level
                      88    Remove Temp Column fields. These are stored locally in Coding.pas.
                      89    New master mem fields
                      90    New payee list object and records added
                      91    New memorisation list object and records added
                      92    New fields for super fund fields
                      93    Added Client CC Email Address
        5.4.0.299     94    New field to store date a memorisation last applied
             .304     95    New field to store BAS format
             .315     96    More Super Fund fields added
   	    .422           Temp field added to store Download From setting on open
        5.5.0         97    Added Acclipse WebXOffice to Scheduled Reports, and WebSpace to ECoding options
        5.5.0         98    Add Web Export Format
        5.6.0         99    Add Mobile Telephone Number
        5.6.0        100    Add coding screen sort order
        5.6.0        101    Added temp budget start date - cannot match on name only
        5.6.0        102    Add ledger report options
                     103    Read Only flag for client file is now stored
        5.6.0        104    Add Check Out option on Scheduled Reports
                            Add SR bank account exclusion list
        5.6.0        105    Further Ledger Report Settings
                     106    Force an upgrade of bank account layout for payee name
                     107    Add salutation client field
        5.7.0        108    ** SmartLink fields added to client and transactions
        5.8.0        109    SmartLink fields added into BK5
                            Added field to store admin system lrn of client for generating trx uid
                            Added field to store transaction uid from production system for each trx
                     111    Added flag to tell extracts to ignore client id and use alternate id
        5.9.0        112    Added manual account fields for bank accounts
                            Added notes read field for transactions
                            Added basic chart of accounts
                            Added last use date of client file
                     113    Need to increase number for upgrading Temp accounts to manual accounts
                            Add temp field to tx to indicate date change outside of CES range
                            Add flag for displaying full or basic account
                            Add spare fields
                     114    Add payee to every mem line
                     115    Add Adjustments to the Balances
                     116    Add reference to dissections/journals
                     117    Add field to store location of update server
        5.9.1        118    Add fuel tax - used spare boolean
        5.9.1        118    Add new super fund fields
        5.10         119    Increase version number for manual account upgrade
                     120    Add config columns, add BGL member component super field
        5.11 (2007)  121    Increase length of all email fields
        5.11         122    Add Profit Report Percentage - Used spare boolean,
                            and Add Favourite Report XML
                     123    Version number change so we can upgrade quantities, gst rates and percentages to 4 decimal places
                     124    T6 field for IAS form N
                     125    Save R/ALL mode in CES/Dissection
                     126    Add TFN
                     127    Save R/ALL mode in Journals
                     128    BAS T5, Remember budget column widths, Desktop Super
                     129    Added BAS fuel tax worksheet, Desktop super ledger ID is bank account specific, Add Archive option
                     130    Password Encryption OFF in Wrapper
                     131    New fields in Desktop Super
        5.13 (2008)  132    Journal processing duration, increase statement details size in mems, auto purge
                     133    Bigger cc email address field
                     134    Add Job costing
                     135    Renamed Old Report Headings to Graph Headings
                     136    Add Code to Jobs
                     137    Add Provisional tax to balances
                     138    Change Update_server to Practice_code (Practice banklink Code)
        5.14 (SMSF)  139    Fuel Tax to 4 dp.
                            Add Client Extra structure (Client is full) for company tax
                            Add Superfund fields to Memorization Lines
                            Add Acounting System to Memorizations
        5.15 (2009)  140    Renamed Client: ECoding File Attachments -> Scheduled File Attachments
                     141    Add List Entries report settings to ClientExtra structure
                            Add From/To Date to Memorizations
                            Add Job-code to Memorization Lines
                     142    Add temp fields for reporting on multiple Divisions
                     143    Add IsBasic to Budget
                     144    (Restict Books Users to Basic Chart - Case 5333 - Removed after V150)
                     145    Add flag for printing non-posting chart code titles
                     146    Add flag for Restricting Books Clients to Basic Chart Codes - Case 5333 Restrict_Chart'
                     147    Add Tax Invoice Flag to Dissection Record
                     148    Add flag for summarising reports on non-posting chart codes
                     149    Add flags for restricting books clients from editting charts and unlocking entries - Case 1006
                     150    Add flag for not sending Jobs in ECoding - Case 9385
                     151    Add Custom_Coding_Report_XML field so save custom coding report settings - Case 1639
                            Add flag for vertical column lines option - Case 1639
                     152    Add Scheduled_Custom_CR_XML field so save scheduled custom coding report settings - Case 1639
                     153    Add Budget Include Quantities to save Include Quantaties flag for budget report - Case 784
                     154    Add flag for vertical column lines option in scheduled reports
                     155    Add fields to save custom ledger report settings - Case 1796
                     156    Add GST Customs Figure to Balances - Case 11771
        5.16 (2010)  157    Add Local_Currency_Code to ClientExtra
                            Add Currency_Code, Is_Forex_Account, Default_Forex_Source, Default_Forex_Description to Bank_Account
                            Add Forex_Conversion_Rate & Local_Currency_Amount to Transactions and Dissections
                     158    Add Books Ristrict Edit Memorisations
                     159    Add option to send custom documents with scheduled reports
                     160    Add fields to save List Payee report options
     5.18 (2010SMSF) 161    Add more Super fields to Mems
                            Add ASX Code to Chart(Renamed Alternative Code to Chart_ID and reintoduced Alternative Code)
                            Add SF Ledger Code to Bank account
                            Add Super Report Titles
                            Add Super fields to Payee, as per Mem, there are some extra fields not used(yet)
                            Add Extra GST fields for Transitional return, spanning 1 Oct 2010.
                            Add Simple UI status flags and period start
     5.19 (2010SMSF) 162    Add SF_Ledger_ID to Payee Line and Memorisation Line for payee memorisations
                            Add SF_Ledger_Name to Payee Line and Memorisation Line for payee memorisations
     5.20 (2011/UK)  163    Add Send Job List to Client Extra for scheduled reports
                            Change txForeign_Currency_Amount, and txOriginal_Foreign_Currency_Amount to spare
                            Add temp fields txTemp_Forex_Rate, txTemp_Base_Amount, and dxTemp_Base_Amount,
                            Add IsProvisional to Bank account
                            Add Opening Balance Curreny field to Dissection and temp fields to Account
     5.21 (2011AUDIT)164    Add Audit Record ID field to memorisation records
                     165    Add remaining Audit Record ID fields to records
                            Add Audit Table (Defined in SY.TXT)
                            Add temp fileds to Txn for Provisional info
                     168    Add VAT Adjustments field to Balance rec
     5.22 (2011 CICO)166    Add Client File GUID to Client Extra
                     167    Add field for CheckOut Online Scheduled Reports
                            Client File GUID not needed. Added field for File Transfer Method
     5.23 (2012BLOPI)168    Add Offline version of Client Settings for a New Client when Notes online is used
     5.24 (2012 Tag) 169    Add Core Trans ID and sent to Online to Transactions
     5.25            170    Added DeliverDataDirectToBLO and BLOSecureCode fields to ClientExtra, to store
                            tagging additions to the BLO settings form
                            Added Core Trans ID High Integer
                            Added Bank Account Core ID
                            Added Bank Account Online Secure Code
                            Changed Transaction Matched_By from type "Memorised Transaction Rec" to "Memorisation Detail Rec"
     5.25            171    Added fields Contractor..ABN to Payee Detail record
                            Added Exchange Gain_Loss_Code
                            Added new structure DeleteTransaction
     5.25            172    Added new structure ExchangeGainLoss
     5.25            173    Adding Include Unused Chart Codes and Include Non-Posting Chart Codes
     5.25            174    Moved the aforesaid fields (see 173) to ClientExtra, there's no room for new fields in Client
     5.25            175    Upgrading now adds a default value to clFields.clECoding_Import_Options, but this doesn't change anything below
     5.25            176    CSV Add prefix account code option
     5.25            177    Adding 'Percent Account' and 'Percentage' to Account Code fields
     5.25            178    Adding 'Percent Account' and 'Percentage' to Budget Detail fields
     5.25            179    Changes for automatically calculation of GST (on/off)
     5.25            180    Removing 178 changes, only need 177 changes
     5.25            181    Memorisations upgrade, code only
     5.25            182    New Table TPR Payer Detail
     5.25	    183	   Changed length of Statement Details fields in several records to 200
     5.26            184    Fix for journals being scanned for suggested mems 
     5.27            185    Payee Inactive
     5.28            186    Account Inactive
                            Suggested Mems
                            Cashbook Migration
     5.29            187    Suggested Mems Improvements
                            BGL Export
                            Practice Ledger Export
   *)
   //Audit Trail - 135 Don't reuse token!!! - Record defined in SY.TXT but also used in Client File

{  -------------------------------------------------------------------  }

Type
   pClient_Rec                           = ^tClient_Rec ;
   pAccount_Rec                          = ^tAccount_Rec ;
   pPayee_Rec                            = ^tPayee_Rec ;
   pPayee_Detail_Rec                     = ^tPayee_Detail_Rec ;
   pPayee_Line_Rec                       = ^tPayee_Line_Rec ;
   pBudget_Header_Rec                    = ^tBudget_Header_Rec ;
   pBudget_Detail_Rec                    = ^tBudget_Detail_Rec ;
   pDisk_Log_Rec                         = ^tDisk_Log_Rec ;
   pMemorisation_Detail_Rec              = ^tMemorisation_Detail_Rec ;
   pMemorisation_Line_Rec                = ^tMemorisation_Line_Rec ;
   pBank_Account_Rec                     = ^tBank_Account_Rec ;
   pTransaction_Rec                      = ^tTransaction_Rec ;
   pTransaction_Extension_Rec            = ^tTransaction_Extension_Rec ;
   pDissection_Rec                       = ^tDissection_Rec ;
   pDissection_Extension_Rec             = ^tDissection_Extension_Rec ;
   pBalances_Rec                         = ^tBalances_Rec ;
   pSubGroup_Heading_Rec                 = ^tSubGroup_Heading_Rec ;
   pDivision_Heading_Rec                 = ^tDivision_Heading_Rec ;
   pMemorised_Transaction_Rec            = ^tMemorised_Transaction_Rec ;
   pCustom_Heading_Rec                   = ^tCustom_Heading_Rec ;
   pMacro_Rec                            = ^tMacro_Rec ;
   pFuel_Sheet_Rec                       = ^tFuel_Sheet_Rec ;
   pMoreClient_Rec                       = ^tMoreClient_Rec ;
   pJob_Heading_Rec                      = ^tJob_Heading_Rec ;
   pClientExtra_Rec                      = ^tClientExtra_Rec ;
   pDeleted_Transaction_Rec              = ^tDeleted_Transaction_Rec ;
   pExchange_Gain_Loss_Rec               = ^tExchange_Gain_Loss_Rec ;
   pFinalized_Exchange_Rate_Rec          = ^tFinalized_Exchange_Rate_Rec ;
   pTPR_Payer_Detail_Rec                 = ^tTPR_Payer_Detail_Rec ;
   pUnscanned_Transaction_Rec            = ^tUnscanned_Transaction_Rec ;
   pCandidate_Mem_Processing_Rec         = ^tCandidate_Mem_Processing_Rec ;
   pCandidate_Mem_Rec                    = ^tCandidate_Mem_Rec ;
   pRecommended_Mem_Rec                  = ^tRecommended_Mem_Rec ;
   pTran_Suggested_Link_Rec              = ^tTran_Suggested_Link_Rec ;
   pSuggested_Mem_Rec                    = ^tSuggested_Mem_Rec ;
   pSuggested_Account_Link_Rec           = ^tSuggested_Account_Link_Rec ;
   pSuggested_Account_Rec                = ^tSuggested_Account_Rec ;
   pSuggested_Phrase_Rec                 = ^tSuggested_Phrase_Rec ;

{  -------------------------------------------------------------------  }

   tClient_Rec = Packed Record
      clRecord_Type                      : Byte;
      clCode                             : String[ 8 ];       { Stored }
      clName                             : String[ 60 ];       { Stored }
      clAddress_L1                       : String[ 60 ];       { Stored }
      clAddress_L2                       : String[ 60 ];       { Stored }
      clAddress_L3                       : String[ 60 ];       { Stored }
      clContact_Name                     : String[ 60 ];       { Stored }
      clPhone_No                         : String[ 60 ];       { Stored }
      clFax_No                           : String[ 60 ];       { Stored }
      clFile_Password                    : String[ 8 ];       { Stored }
      clPractice_Name                    : String[ 60 ];       { Stored }
      clStaff_Member_Name                : String[ 60 ];       { Stored }
      clPractice_EMail_Address           : String[ 80 ];       { Stored }
      clStaff_Member_EMail_Address       : String[ 80 ];       { Stored }
      clClient_EMail_Address             : String[ 80 ];       { Stored }
      clCountry                          : Byte;       { Stored }
      clFile_Name                        : String[ 128 ];       { Stored }
      clFile_Type                        : Byte;       { Stored }
      clFile_Version                     : Integer;       { Stored }
      clFile_Save_Count                  : Integer;       { Stored }
      clBankLink_Connect_Password        : String[ 60 ];       { Stored }
      clPIN_Number                       : Integer;       { Stored }
      clOld_Restrict_Analysis_Codes      : Boolean;       { Stored }
      clFinancial_Year_Starts            : Integer;       { Stored }
      clReport_Start_Date                : Integer;       { Stored }
      clReporting_Period                 : Byte;       { Stored }
      clOld_Send_Reports_To              : Byte;       { Stored }
      clSend_Coding_Report               : Boolean;       { Stored }
      clSend_Chart_of_Accounts           : Boolean;       { Stored }
      clSend_Unpresented_Cheque_List     : Boolean;       { Stored }
      clSend_Payee_List                  : Boolean;       { Stored }
      clSend_Payee_Report                : Boolean;       { Stored }
      clShort_Name                       : Array[ 0..100 ] of String[ 10 ];       { Stored }
      clLong_Name                        : Array[ 0..100 ] of String[ 30 ];       { Stored }
      clGST_Number                       : String[ 20 ];       { Stored }
      clGST_Period                       : Byte;       { Stored }
      clGST_Start_Month                  : Byte;       { Stored }
      clGST_Applies_From                 : Array[ 1..5 ] of Integer;       { Stored }
      clGST_Class_Names                  : Array[ 1..99 ] of String[ 60 ];       { Stored }
      clGST_Class_Types                  : Array[ 1..99 ] of Byte;       { Stored }
      clGST_Account_Codes                : Array[ 1..99 ] of String[ 20 ];       { Stored }
      clGST_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      clGST_Basis                        : Byte;       { Stored }
      clGST_on_Presentation_Date         : Boolean;       { Stored }
      clGST_Excludes_Accruals            : Boolean;       { Stored }
      clGST_Inclusive_Cashflow           : Boolean;       { Stored }
      clAccounting_System_Used           : Byte;       { Stored }
      clAccount_Code_Mask                : String[ 20 ];       { Stored }
      clLoad_Client_Files_From           : String[ 128 ];       { Stored }
      clSave_Client_Files_To             : String[ 128 ];       { Stored }
      clChart_Is_Locked                  : Boolean;       { Stored }
      clChart_Last_Updated               : Integer;       { Stored }
      clCoding_Report_Style              : Byte;       { Stored }
      clCoding_Report_Sort_Order         : Byte;       { Stored }
      clCoding_Report_Entry_Selection    : Byte;       { Stored }
      clCoding_Report_Blank_Lines        : Byte;       { Stored }
      clCoding_Report_Rule_Line          : Boolean;       { Stored }
      clCoding_Report_New_Page           : Boolean;       { Stored }
      clOld_Division_Names               : Array[ 1..9 ] of String[ 40 ];       { Stored }
      clCF_Headings                      : Array[ 0..40 ] of String[ 60 ];       { Stored }
      clPR_Headings                      : Array[ 0..40 ] of String[ 60 ];       { Stored }
      clMagic_Number                     : Integer;       { Stored }
      clException_Options                : Integer;       { Stored }
      clPeriod_Start_Date                : Integer;       { Stored }
      clPeriod_End_Date                  : Integer;       { Stored }
      clFRS_Print_Chart_Codes            : Boolean;       { Stored }
      clBankLink_Code                    : String[ 8 ];       { Stored }
      clDisk_Sequence_No                 : Integer;       { Stored }
      clStaff_Member_LRN                 : Integer;       { Stored }
      clSuppress_Check_for_New_TXns      : Boolean;       { Stored }
      clDownload_From                    : Byte;       { Stored }
      clLast_Batch_Number                : Integer;       { Stored }
      clOld_GST_Class_Codes              : String[ 255 ];       { Stored }
      clDivision_Code_List               : Array[ 1..9 ] of String[ 255 ];       { Stored }
      clSB_Export_As                     : Byte;       { Stored }
      clSB_Upload_To                     : Byte;       { Stored }
      clCoding_Report_Print_TI           : Boolean;       { Stored }
      clV31_GST_Format_Used              : Boolean;       { Stored }
      clEmail_Scheduled_Reports          : Boolean;       { Stored }
      clOLD_BAS_Special_Accounts         : Array[ 1..10 ] of String[ 20 ];       { Stored }
      clGST_Class_Codes                  : Array[ 1..99 ] of String[ 5 ];       { Stored }
      clTax_Ledger_Code                  : String[ 16 ];       { Stored }
      clEOY_Locked_SB_Only               : Boolean;       { Stored }
      clBAS_Field_Number                 : Array[ 1..100 ] of Byte;       { Stored }
      clBAS_Field_Source                 : Array[ 1..100 ] of Byte;       { Stored }
      clBAS_Field_Account_Code           : Array[ 1..100 ] of String[ 20 ];       { Stored }
      clBAS_Field_Balance_Type           : Array[ 1..100 ] of Byte;       { Stored }
      clBAS_Field_Percent                : Array[ 1..100 ] of Money;       { Stored }
      clGST_Business_Percent             : Array[ 1..100 ] of Money;       { Stored }
      clBAS_Calculation_Method           : Byte;       { Stored }
      clBAS_Dont_Print_Calc_Sheet        : Boolean;       { Stored }
      clBAS_PAYG_Withheld_Period         : Byte;       { Stored }
      clFax_Scheduled_Reports            : Boolean;       { Stored }
      clGraph_Headings                   : Array[ 0..200 ] of String[ 60 ];       { Stored }
      clNotes                            : Array[ 0..200 ] of String[ 100 ];       { Stored }
      clCheques_Expire_When              : Byte;       { Stored }
      clShow_Notes_On_Open               : Boolean;       { Stored }
      clECoding_Entry_Selection          : Byte;       { Stored }
      clECoding_Dont_Send_Chart          : Boolean;       { Stored }
      clECoding_Dont_Send_Payees         : Boolean;       { Stored }
      clECoding_Dont_Show_Quantity       : Boolean;       { Stored }
      clECoding_Last_File_No             : Integer;       { Stored }
      clECoding_Last_File_No_Imported    : Integer;       { Stored }
      clECoding_Export_Scheduled_Reports : Boolean;       { Stored }
      clEmail_Report_Format              : Byte;       { Stored }
      clBAS_PAYG_Instalment_Period       : Byte;       { Stored }
      clBAS_Include_FBT_WET_LCT          : Boolean;       { Stored }
      clBAS_Last_GST_Option              : Byte;       { Stored }
      clBAS_Last_PAYG_Instalment_Option  : Byte;       { Stored }
      clECoding_Default_Password         : String[ 8 ];       { Stored }
      clECoding_Import_Options           : Integer;       { Stored }
      clECoding_Last_Import_Dir          : String[ 128 ];       { Stored }
      clECoding_Last_Export_Dir          : String[ 128 ];       { Stored }
      clCoding_Report_Show_OP            : Boolean;       { Stored }
      clFRS_Show_Quantity                : Boolean;       { Stored }
      clCflw_Cash_On_Hand_Style          : Byte;       { Stored }
      clCSV_Export_Scheduled_Reports     : Boolean;       { Stored }
      clFRS_Show_YTD                     : Boolean;       { Stored }
      clFRS_Show_Variance                : Boolean;       { Stored }
      clFRS_Compare_Type                 : Byte;       { Stored }
      clFRS_Reporting_Period_Type        : Byte;       { Stored }
      clFRS_Report_Style                 : Byte;       { Stored }
      clReporting_Year_Starts            : Integer;       { Stored }
      clFRS_Report_Detail_Type           : Byte;       { Stored }
      clFRS_Prompt_User_to_use_Budgeted_figures : Boolean;       { Stored }
      clBalance_Sheet_Headings           : Array[ 0..30 ] of String[ 40 ];       { Stored }
      clLast_Financial_Year_Start        : Integer;       { Stored }
      cl520_Reference_Fix_Run            : Boolean;       { Stored }
      clTax_Interface_Used               : Byte;       { Stored }
      clSave_Tax_Files_To                : AnsiString;       { Stored }
      clJournal_Processing_Period        : Byte;       { Stored }
      clLast_Disk_Image_Version          : Integer;       { Stored }
      clPractice_Web_Site                : AnsiString;       { Stored }
      clPractice_Phone                   : String[ 20 ];       { Stored }
      clPractice_Logo                    : AnsiString;       { Stored }
      clWeb_Site_Login_URL               : AnsiString;       { Stored }
      clStaff_Member_Direct_Dial         : String[ 20 ];       { Stored }
      clContact_Details_To_Show          : Byte;       { Stored }
      clECoding_Dont_Allow_UPIs          : Boolean;       { Stored }
      clECoding_Dont_Show_Account        : Boolean;       { Stored }
      clECoding_Dont_Show_Payees         : Boolean;       { Stored }
      clECoding_Dont_Show_GST            : Boolean;       { Stored }
      clECoding_Dont_Show_TaxInvoice     : Boolean;       { Stored }
      clScheduled_File_Attachments       : AnsiString;       { Stored }
      clScheduled_Coding_Report_Style    : Byte;       { Stored }
      clScheduled_Coding_Report_Sort_Order : Byte;       { Stored }
      clScheduled_Coding_Report_Entry_Selection : Byte;       { Stored }
      clScheduled_Coding_Report_Blank_Lines : Byte;       { Stored }
      clScheduled_Coding_Report_Rule_Line : Boolean;       { Stored }
      clScheduled_Coding_Report_New_Page : Boolean;       { Stored }
      clScheduled_Coding_Report_Print_TI : Boolean;       { Stored }
      clScheduled_Coding_Report_Show_OP  : Boolean;       { Stored }
      clScheduled_Client_Note_Message    : AnsiString;       { Stored }
      clCustom_Contact_Name              : String[ 60 ];       { Stored }
      clCustom_Contact_EMail_Address     : String[ 80 ];       { Stored }
      clCustom_Contact_Phone             : String[ 20 ];       { Stored }
      clEmpty_Journals_Removed           : Boolean;       { Stored }
      clHighest_Manual_Account_No        : Integer;       { Stored }
      clContact_Details_Edit_Date        : Integer;       { Stored }
      clContact_Details_Edit_Time        : Integer;       { Stored }
      clCopy_Narration_Dissection        : Boolean;       { Stored }
      clClient_CC_EMail_Address          : String[ 255 ];       { Stored }
      clBAS_Report_Format                : Byte;       { Stored }
      clWebX_Export_Scheduled_Reports    : Boolean;       { Stored }
      clECoding_WebSpace                 : Integer;       { Stored }
      clLast_ECoding_Account_UID         : Integer;       { Stored }
      clWeb_Export_Format                : Byte;       { Stored }
      clMobile_No                        : String[ 60 ];       { Stored }
      clLedger_Report_Summary            : Boolean;       { Stored }
      clLedger_Report_Show_Notes         : Boolean;       { Stored }
      clLedger_Report_Show_Quantities    : Boolean;       { Stored }
      clLedger_Report_Show_Non_Trf       : Boolean;       { Stored }
      clLedger_Report_Show_Inactive_Codes : Boolean;       { Stored }
      clLedger_Report_Bank_Contra        : Byte;       { Stored }
      clLedger_Report_GST_Contra         : Byte;       { Stored }
      clLedger_Report_Show_Balances      : Boolean;       { Stored }
      clFile_Read_Only                   : Boolean;       { Stored }
      clCheckOut_Scheduled_Reports       : Boolean;       { Stored }
      clExclude_From_Scheduled_Reports   : AnsiString;       { Stored }
      clLedger_Report_Show_Gross_And_GST : Boolean;       { Stored }
      clSalutation                       : String[ 10 ];       { Stored }
      clExternal_ID                      : AnsiString;       { Stored }
      clSystem_LRN                       : Integer;       { Stored }
      clBusiness_Products_Scheduled_Reports : Boolean;       { Stored }
      clBusiness_Products_Report_Format  : Byte;       { Stored }
      clCoding_Report_Wrap_Narration     : Boolean;       { Stored }
      clLedger_Report_Wrap_Narration     : Boolean;       { Stored }
      clScheduled_Coding_Report_Wrap_Narration : Boolean;       { Stored }
      clForce_Offsite_Check_Out          : Boolean;       { Stored }
      clDisable_Offsite_Check_Out        : Boolean;       { Stored }
      clAlternate_Extract_ID             : AnsiString;       { Stored }
      clUse_Alterate_ID_for_extract      : Boolean;       { Stored }
      clLast_Use_Date                    : Integer;       { Stored }
      clUse_Basic_Chart                  : Boolean;       { Stored }
      clGroup_Name                       : AnsiString;       { Stored }
      clClient_Type_Name                 : AnsiString;       { Stored }
      clBAS_Include_Fuel                 : Boolean;       { Stored }
      clProfit_Report_Show_Percentage    : Boolean;       { Stored }
      clECoding_Send_Superfund           : Boolean;       { Stored }
      clGroup_LRN                        : Integer;       { Stored }
      clClient_Type_LRN                  : Integer;       { Stored }
      clSpare_Byte_1                     : Byte;       { Stored }
      clSpare_Byte_2                     : Byte;       { Stored }
      clPractice_Code                    : AnsiString;       { Stored }
      clCashJ_Column_Order               : Array[ 0..32 ] of Byte;       { Stored }
      clCashJ_Column_Width               : Array[ 0..32 ] of Integer;       { Stored }
      clCashJ_Column_is_Hidden           : Array[ 0..32 ] of Boolean;       { Stored }
      clCashJ_Column_is_Not_Editable     : Array[ 0..32 ] of Boolean;       { Stored }
      clCashJ_Sort_Order                 : Integer;       { Stored }
      clAcrlJ_Column_Order               : Array[ 0..32 ] of Byte;       { Stored }
      clAcrlJ_Column_Width               : Array[ 0..32 ] of Integer;       { Stored }
      clAcrlJ_Column_is_Hidden           : Array[ 0..32 ] of Boolean;       { Stored }
      clAcrlJ_Column_is_Not_Editable     : Array[ 0..32 ] of Boolean;       { Stored }
      clAcrlJ_Sort_Order                 : Integer;       { Stored }
      clStockJ_Column_Order              : Array[ 0..32 ] of Byte;       { Stored }
      clStockJ_Column_Width              : Array[ 0..32 ] of Integer;       { Stored }
      clStockJ_Column_is_Hidden          : Array[ 0..32 ] of Boolean;       { Stored }
      clStockJ_Column_is_Not_Editable    : Array[ 0..32 ] of Boolean;       { Stored }
      clStockJ_Sort_Order                : Integer;       { Stored }
      clYrEJ_Column_Order                : Array[ 0..32 ] of Byte;       { Stored }
      clYrEJ_Column_Width                : Array[ 0..32 ] of Integer;       { Stored }
      clYrEJ_Column_is_Hidden            : Array[ 0..32 ] of Boolean;       { Stored }
      clYrEJ_Column_is_Not_Editable      : Array[ 0..32 ] of Boolean;       { Stored }
      clYrEJ_Sort_Order                  : Integer;       { Stored }
      clgstJ_Column_Order                : Array[ 0..32 ] of Byte;       { Stored }
      clgstJ_Column_Width                : Array[ 0..32 ] of Integer;       { Stored }
      clgstJ_Column_is_Hidden            : Array[ 0..32 ] of Boolean;       { Stored }
      clgstJ_Column_is_Not_Editable      : Array[ 0..32 ] of Boolean;       { Stored }
      clgstJ_Sort_Order                  : Integer;       { Stored }
      clFavourite_Report_XML             : AnsiString;       { Stored }
      clAll_EditMode_CES                 : Boolean;       { Stored }
      clAll_EditMode_DIS                 : Boolean;       { Stored }
      clTFN                              : String[ 10 ];       { Stored }
      clAll_EditMode_Journals            : Array[ 0..7 ] of Boolean;       { Stored }
      clBudget_Column_Width              : Array[ 0..14 ] of Integer;       { Stored }
      clLast_Payee_Number                : Integer;
      clFile_Memory_Usage                : Integer;
      clFile_Load_Time                   : Integer;
      clFile_Save_Time                   : Integer;
      clFile_Save_Required               : Boolean;
      clUse_Minus_As_Lookup_Key          : Boolean;
      clUppercase_Codes                  : Boolean;
      clCRC_After_Loading                : Integer;
      clCurrent_CRC                      : Integer;
      clCRC_at_Last_Save                 : Integer;
      clTime_of_Last_Save                : Integer;
      clLast_Journal_Date                : Integer;
      clTemp_FRS_Last_Period_To_Show     : Integer;
      clTemp_FRS_Last_Actual_Period_To_Use : Integer;
      clTemp_FRS_Budget_To_Use           : String[ 40 ];
      clTemp_FRS_Division_To_Use         : Integer;
      clTemp_FRS_Divisions               : DynamicBooleanArray;
      clTemp_FRS_Split_By_Division       : Boolean;
      clTemp_FRS_Job_To_Use              : String[ 8 ];
      clTemp_FRS_From_Date               : Integer;
      clTemp_FRS_To_Date                 : Integer;
      clTemp_FRS_Account_Totals_Cash_Only : Boolean;
      clTemp_FRS_Use_Budgeted_Data_If_No_Actual : Boolean;
      clTemp_Period_Details_This_Year    : TPeriod_Details_Array;
      clTemp_Period_Details_Last_Year    : TPeriod_Details_Array;
      clTemp_Periods_This_Year           : Integer;
      clTemp_Periods_Last_Year           : Integer;
      clTemp_Last_Period_Of_Actual_Data  : Integer;
      clTemp_Spare                       : Boolean;
      clLast_Auto_Save_CRC               : Integer;
      clTemp_Logo_Was_Loaded_OK          : Boolean;
      clTemp_Old_Download_From           : Byte;
      clTemp_FRS_Budget_To_Use_Date      : Integer;
      clCompressed_Data_Size             : Integer;
      clUncompressed_Data_Size           : Integer;
      clTemp_FRS_Use_Budget_Quantities   : Boolean;
      clTemp_CRC_at_Last_Backup          : Integer;
      clEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tAccount_Rec = Packed Record
      chRecord_Type                      : Byte;
      chAccount_Code                     : String[ 20 ];       { Stored }
      chChart_ID                         : String[ 20 ];       { Stored }
      chAccount_Description              : String[ 60 ];       { Stored }
      chGST_Class                        : Byte;       { Stored }
      chPosting_Allowed                  : Boolean;       { Stored }
      chAccount_Type                     : Byte;       { Stored }
      chEnter_Quantity                   : Boolean;       { Stored }
      chPrint_in_Division                : Array[ 1..250 ] of Boolean;       { Stored }
      chMoney_Variance_Up                : Money;       { Stored }
      chMoney_Variance_Down              : Money;       { Stored }
      chPercent_Variance_Up              : Money;       { Stored }
      chPercent_Variance_Down            : Money;       { Stored }
      chLast_Years_Totals_SB_Only        : Array[ 1..12 ] of Money;       { Stored }
      chOpening_Balance_SB_Only          : Money;       { Stored }
      chSubtype                          : Byte;       { Stored }
      chAlternative_Code                 : String[ 20 ];       { Stored }
      chLinked_Account_OS                : String[ 20 ];       { Stored }
      chLinked_Account_CS                : String[ 20 ];       { Stored }
      chHide_In_Basic_Chart              : Boolean;       { Stored }
      chAudit_Record_ID                  : Integer;       { Stored }
      chInactive                         : Boolean;       { Stored }
      chTemp_Quantity                    : TDynamic_Balances_Rec;
      chTemp_Amount                      : TDynamic_Balances_Rec;
      chTemp_Base_Amount                 : TDynamic_Balances_Rec;
      chTemp_Money_Value                 : Money;
      chTemp_Calc_Totals_Tag             : Integer;
      chTemp_Include_In_Report           : Boolean;
      chTotal                            : Money;
      chGross                            : Money;
      chNet                              : Money;
      chTax                              : Money;
      chHits                             : Integer;
      chTemp_Tag                         : Integer;
      chTemp_Linked_To_From_SOH          : String[ 20 ];
      chTemp_Date_First_Movement         : Integer;
      chTemp_Opening_Balance_Currency    : String[ 3 ];
      chTemp_Opening_Balance_Forex_Amount : Money;
      chEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Rec = Packed Record
      pyRecord_Type                      : Byte;
      pyNumber                           : Integer;       { Stored }
      pyName                             : String[ 40 ];       { Stored }
      pyAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      pyPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      pyGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      pyGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      pyGL_Narration                     : Array[ 1..50 ] of String[ 40 ];       { Stored }
      pyAudit_Record_ID                  : Integer;       { Stored }
      pyAmount                           : TLBRec;
      pyTotal                            : Money;
      pyEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Detail_Rec = Packed Record
      pdRecord_Type                      : Byte;
      pdNumber                           : Integer;       { Stored }
      pdName                             : String[ 40 ];       { Stored }
      pdAudit_Record_ID                  : Integer;       { Stored }
      pdContractor                       : Boolean;       { Stored }
      pdSurname                          : String[ 30 ];       { Stored }
      pdGiven_Name                       : String[ 15 ];       { Stored }
      pdOther_Name                       : String[ 15 ];       { Stored }
      pdAddress                          : String[ 38 ];       { Stored }
      pdTown                             : String[ 27 ];       { Stored }
      pdState                            : String[ 3 ];       { Stored }
      pdPost_Code                        : String[ 4 ];       { Stored }
      pdPhone_Number                     : String[ 60 ];       { Stored }
      pdABN                              : String[ 14 ];       { Stored }
      pdBusinessName                     : String[ 200 ];       { Stored }
      pdTradingName                      : String[ 200 ];       { Stored }
      pdCountry                          : String[ 20 ];       { Stored }
      pdInstitutionBSB                   : String[ 6 ];       { Stored }
      pdInstitutionAccountNumber         : String[ 9 ];       { Stored }
      pdIsIndividual                     : Boolean;       { Stored }
      pdAddressLine2                     : String[ 38 ];       { Stored }
      pdStateId                          : Integer;       { Stored }
      pdInactive                         : Boolean;       { Stored }
      pdAmount                           : TLBRec;
      pdTotal                            : Money;
      pdTemp_Tag                         : Integer;
      pdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tPayee_Line_Rec = Packed Record
      plRecord_Type                      : Byte;
      plAccount                          : String[ 20 ];       { Stored }
      plPercentage                       : Money;       { Stored }
      plGST_Class                        : Byte;       { Stored }
      plGST_Has_Been_Edited              : Boolean;       { Stored }
      plGL_Narration                     : AnsiString;       { Stored }
      plLine_Type                        : Byte;       { Stored }
      plGST_Amount                       : Money;       { Stored }
      plSF_PCFranked                     : Money;       { Stored }
      plSF_Member_ID                     : String[ 20 ];       { Stored }
      plSF_Fund_ID                       : Integer;       { Stored }
      plSF_Fund_Code                     : String[ 20 ];       { Stored }
      plSF_Trans_ID                      : Integer;       { Stored }
      plSF_Trans_Code                    : AnsiString;       { Stored }
      plSF_Member_Account_ID             : Integer;       { Stored }
      plSF_Member_Account_Code           : String[ 41 ];       { Stored }
      plSF_Edited                        : Boolean;       { Stored }
      plSF_Member_Component              : Byte;       { Stored }
      plSF_PCUnFranked                   : Money;       { Stored }
      plQuantity                         : Money;       { Stored }
      plSF_GDT_Date                      : Integer;       { Stored }
      plSF_Tax_Free_Dist                 : Money;       { Stored }
      plSF_Tax_Exempt_Dist               : Money;       { Stored }
      plSF_Tax_Deferred_Dist             : Money;       { Stored }
      plSF_TFN_Credits                   : Money;       { Stored }
      plSF_Foreign_Income                : Money;       { Stored }
      plSF_Foreign_Tax_Credits           : Money;       { Stored }
      plSF_Capital_Gains_Indexed         : Money;       { Stored }
      plSF_Capital_Gains_Disc            : Money;       { Stored }
      plSF_Capital_Gains_Other           : Money;       { Stored }
      plSF_Other_Expenses                : Money;       { Stored }
      plSF_Interest                      : Money;       { Stored }
      plSF_Capital_Gains_Foreign_Disc    : Money;       { Stored }
      plSF_Rent                          : Money;       { Stored }
      plSF_Special_Income                : Money;       { Stored }
      plSF_Other_Tax_Credit              : Money;       { Stored }
      plSF_Non_Resident_Tax              : Money;       { Stored }
      plSF_Foreign_Capital_Gains_Credit  : Money;       { Stored }
      plSF_Capital_Gains_Fraction_Half   : Boolean;       { Stored }
      plSF_Ledger_ID                     : Integer;       { Stored }
      plSF_Ledger_Name                   : AnsiString;       { Stored }
      plAudit_Record_ID                  : Integer;       { Stored }
      plTemp_Tag                         : Integer;
      plSF_Other_Income                  : Money;       { Stored }
      plSF_Other_Trust_Deductions        : Money;       { Stored }
      plSF_CGT_Concession_Amount         : Money;       { Stored }
      plSF_CGT_ForeignCGT_Before_Disc    : Money;       { Stored }
      plSF_CGT_ForeignCGT_Indexation     : Money;       { Stored }
      plSF_CGT_ForeignCGT_Other_Method   : Money;       { Stored }
      plSF_CGT_TaxPaid_Indexation        : Money;       { Stored }
      plSF_CGT_TaxPaid_Other_Method      : Money;       { Stored }
      plSF_Other_Net_Foreign_Income      : Money;       { Stored }
      plSF_Cash_Distribution             : Money;       { Stored }
      plSF_AU_Franking_Credits_NZ_Co     : Money;       { Stored }
      plSF_Non_Res_Witholding_Tax        : Money;       { Stored }
      plSF_LIC_Deductions                : Money;       { Stored }
      plSF_Non_Cash_CGT_Discounted_Before_Discount : Money;       { Stored }
      plSF_Non_Cash_CGT_Indexation       : Money;       { Stored }
      plSF_Non_Cash_CGT_Other_Method     : Money;       { Stored }
      plSF_Non_Cash_CGT_Capital_Losses   : Money;       { Stored }
      plSF_Share_Brokerage               : Money;       { Stored }
      plSF_Share_Consideration           : Money;       { Stored }
      plSF_Share_GST_Amount              : Money;       { Stored }
      plSF_Share_GST_Rate                : String[ 5 ];       { Stored }
      plSF_Cash_Date                     : Integer;       { Stored }
      plSF_Accrual_Date                  : Integer;       { Stored }
      plSF_Record_Date                   : Integer;       { Stored }
      plSF_Contract_Date                 : Integer;       { Stored }
      plSF_Settlement_Date               : Integer;       { Stored }
      plEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tBudget_Header_Rec = Packed Record
      buRecord_Type                      : Byte;
      buStart_Date                       : Integer;       { Stored }
      buName                             : String[ 40 ];       { Stored }
      buEstimated_Opening_Bank_Balance   : Money;       { Stored }
      buIs_Inclusive                     : Boolean;       { Stored }
      buAutomatically_Calculate_GST      : Boolean;       { Stored }
      buEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tBudget_Detail_Rec = Packed Record
      bdRecord_Type                      : Byte;
      bdAccount_Code                     : String[ 20 ];       { Stored }
      bdBudget                           : Array[ 0..12 ] of Money;       { Stored }
      bdQty_Budget                       : Array[ 0..12 ] of Money;       { Stored }
      bdEach_Budget                      : Array[ 0..12 ] of Money;       { Stored }
      bdPercent_Account                  : String[ 20 ];       { Stored }
      bdPercentage                       : Double;       { Stored }
      bdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDisk_Log_Rec = Packed Record
      dlRecord_Type                      : Byte;
      dlDisk_ID                          : String[ 20 ];       { Stored }
      dlDate_Downloaded                  : Integer;       { Stored }
      dlNo_of_Accounts                   : Integer;       { Stored }
      dlNo_of_Entries                    : Integer;       { Stored }
      dlEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tMemorisation_Detail_Rec = Packed Record
      mdRecord_Type                      : Byte;
      mdSequence_No                      : Integer;       { Stored }
      mdType                             : Byte;       { Stored }
      mdAmount                           : Money;       { Stored }
      mdReference                        : String[ 12 ];       { Stored }
      mdParticulars                      : String[ 12 ];       { Stored }
      mdAnalysis                         : String[ 12 ];       { Stored }
      mdOther_Party                      : String[ 20 ];       { Stored }
      mdStatement_Details                : String[ 200 ];       { Stored }
      mdMatch_on_Amount                  : Byte;       { Stored }
      mdMatch_on_Analysis                : Boolean;       { Stored }
      mdMatch_on_Other_Party             : Boolean;       { Stored }
      mdMatch_on_Notes                   : Boolean;       { Stored }
      mdMatch_on_Particulars             : Boolean;       { Stored }
      mdMatch_on_Refce                   : Boolean;       { Stored }
      mdMatch_On_Statement_Details       : Boolean;       { Stored }
      mdPayee_Number                     : Integer;       { Stored }
      mdFrom_Master_List                 : Boolean;       { Stored }
      mdNotes                            : String[ 40 ];       { Stored }
      mdDate_Last_Applied                : Integer;       { Stored }
      mdUse_Accounting_System            : Boolean;       { Stored }
      mdAccounting_System                : Byte;       { Stored }
      mdFrom_Date                        : Integer;       { Stored }
      mdUntil_Date                       : Integer;       { Stored }
      mdAudit_Record_ID                  : Integer;       { Stored }
      mdNext_Memorisation                : TObject;
      mdTemp_Tag                         : Integer;
      mdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tMemorisation_Line_Rec = Packed Record
      mlRecord_Type                      : Byte;
      mlAccount                          : String[ 20 ];       { Stored }
      mlPercentage                       : Money;       { Stored }
      mlGST_Class                        : Byte;       { Stored }
      mlGST_Has_Been_Edited              : Boolean;       { Stored }
      mlGL_Narration                     : AnsiString;       { Stored }
      mlLine_Type                        : Byte;       { Stored }
      mlGST_Amount                       : Money;       { Stored }
      mlPayee                            : Integer;       { Stored }
      mlSF_PCFranked                     : Money;       { Stored }
      mlSF_Member_ID                     : String[ 20 ];       { Stored }
      mlSF_Fund_ID                       : Integer;       { Stored }
      mlSF_Fund_Code                     : String[ 20 ];       { Stored }
      mlSF_Trans_ID                      : Integer;       { Stored }
      mlSF_Trans_Code                    : AnsiString;       { Stored }
      mlSF_Member_Account_ID             : Integer;       { Stored }
      mlSF_Member_Account_Code           : String[ 41 ];       { Stored }
      mlSF_Edited                        : Boolean;       { Stored }
      mlSF_Member_Component              : Byte;       { Stored }
      mlSF_PCUnFranked                   : Money;       { Stored }
      mlJob_Code                         : String[ 8 ];       { Stored }
      mlQuantity                         : Money;       { Stored }
      mlSF_GDT_Date                      : Integer;       { Stored }
      mlSF_Tax_Free_Dist                 : Money;       { Stored }
      mlSF_Tax_Exempt_Dist               : Money;       { Stored }
      mlSF_Tax_Deferred_Dist             : Money;       { Stored }
      mlSF_TFN_Credits                   : Money;       { Stored }
      mlSF_Foreign_Income                : Money;       { Stored }
      mlSF_Foreign_Tax_Credits           : Money;       { Stored }
      mlSF_Capital_Gains_Indexed         : Money;       { Stored }
      mlSF_Capital_Gains_Disc            : Money;       { Stored }
      mlSF_Capital_Gains_Other           : Money;       { Stored }
      mlSF_Other_Expenses                : Money;       { Stored }
      mlSF_Interest                      : Money;       { Stored }
      mlSF_Capital_Gains_Foreign_Disc    : Money;       { Stored }
      mlSF_Rent                          : Money;       { Stored }
      mlSF_Special_Income                : Money;       { Stored }
      mlSF_Other_Tax_Credit              : Money;       { Stored }
      mlSF_Non_Resident_Tax              : Money;       { Stored }
      mlSF_Foreign_Capital_Gains_Credit  : Money;       { Stored }
      mlSF_Capital_Gains_Fraction_Half   : Boolean;       { Stored }
      mlAudit_Record_ID                  : Integer;       { Stored }
      mlTemp_Tag                         : Integer;
      mlSF_Imputed_Credit                : Money;       { Stored }
      mlSF_Other_Income                  : Money;       { Stored }
      mlSF_Other_Trust_Deductions        : Money;       { Stored }
      mlSF_CGT_Concession_Amount         : Money;       { Stored }
      mlSF_CGT_ForeignCGT_Before_Disc    : Money;       { Stored }
      mlSF_CGT_ForeignCGT_Indexation     : Money;       { Stored }
      mlSF_CGT_ForeignCGT_Other_Method   : Money;       { Stored }
      mlSF_CGT_TaxPaid_Indexation        : Money;       { Stored }
      mlSF_CGT_TaxPaid_Other_Method      : Money;       { Stored }
      mlSF_Other_Net_Foreign_Income      : Money;       { Stored }
      mlSF_Cash_Distribution             : Money;       { Stored }
      mlSF_AU_Franking_Credits_NZ_Co     : Money;       { Stored }
      mlSF_Non_Res_Witholding_Tax        : Money;       { Stored }
      mlSF_LIC_Deductions                : Money;       { Stored }
      mlSF_Non_Cash_CGT_Discounted_Before_Discount : Money;       { Stored }
      mlSF_Non_Cash_CGT_Indexation       : Money;       { Stored }
      mlSF_Non_Cash_CGT_Other_Method     : Money;       { Stored }
      mlSF_Non_Cash_CGT_Capital_Losses   : Money;       { Stored }
      mlSF_Share_Brokerage               : Money;       { Stored }
      mlSF_Share_Consideration           : Money;       { Stored }
      mlSF_Share_GST_Amount              : Money;       { Stored }
      mlSF_Share_GST_Rate                : String[ 5 ];       { Stored }
      mlSF_Cash_Date                     : Integer;       { Stored }
      mlSF_Accrual_Date                  : Integer;       { Stored }
      mlSF_Record_Date                   : Integer;       { Stored }
      mlSF_Contract_Date                 : Integer;       { Stored }
      mlSF_Settlement_Date               : Integer;       { Stored }
      mlEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tBank_Account_Rec = Packed Record
      baRecord_Type                      : Byte;
      baBank_Account_Number              : String[ 20 ];       { Stored }
      baBank_Account_Name                : String[ 60 ];       { Stored }
      baBank_Account_Password            : String[ 20 ];       { Stored }
      baContra_Account_Code              : String[ 20 ];       { Stored }
      baCurrent_Balance                  : Money;       { Stored }
      baApply_Master_Memorised_Entries   : Boolean;       { Stored }
      baAccount_Type                     : Byte;       { Stored }
      baColumn_Order                     : Array[ 0..32 ] of Byte;       { Stored }
      baColumn_Width                     : Array[ 0..32 ] of Integer;       { Stored }
      baPreferred_View                   : Byte;       { Stored }
      baHighest_BankLink_ID              : Integer;       { Stored }
      baHighest_LRN                      : Integer;       { Stored }
      baColumn_is_Hidden                 : Array[ 0..32 ] of Boolean;       { Stored }
      baAccount_Expiry_Date              : Integer;       { Stored }
      baHighest_Matched_Item_ID          : Integer;       { Stored }
      baNotes_Always_Visible             : Boolean;       { Stored }
      baNotes_Height                     : Integer;       { Stored }
      baLast_ECoding_Transaction_UID     : Integer;       { Stored }
      baColumn_Is_Not_Editable           : Array[ 0..32 ] of Boolean;       { Stored }
      baExtend_Expiry_Date               : Boolean;       { Stored }
      baIs_A_Manual_Account              : Boolean;       { Stored }
      baAnalysis_Coding_Level            : Integer;       { Stored }
      baECoding_Account_UID              : Integer;       { Stored }
      baCoding_Sort_Order                : Integer;       { Stored }
      baManual_Account_Type              : Integer;       { Stored }
      baManual_Account_Institution       : String[ 60 ];       { Stored }
      baManual_Account_Sent_To_Admin     : Boolean;       { Stored }
      baSpare_String                     : AnsiString;       { Stored }
      baIs_A_Provisional_Account         : Boolean;       { Stored }
      baSpare_Number                     : Integer;       { Stored }
      baSpare_Byte                       : Byte;       { Stored }
      baHDE_Column_Order                 : Array[ 0..32 ] of Byte;       { Stored }
      baHDE_Column_Width                 : Array[ 0..32 ] of Integer;       { Stored }
      baHDE_Column_is_Hidden             : Array[ 0..32 ] of Boolean;       { Stored }
      baHDE_Column_is_Not_Editable       : Array[ 0..32 ] of Boolean;       { Stored }
      baHDE_Sort_Order                   : Integer;       { Stored }
      baMDE_Column_Order                 : Array[ 0..32 ] of Byte;       { Stored }
      baMDE_Column_Width                 : Array[ 0..32 ] of Integer;       { Stored }
      baMDE_Column_is_Hidden             : Array[ 0..32 ] of Boolean;       { Stored }
      baMDE_Column_is_Not_Editable       : Array[ 0..32 ] of Boolean;       { Stored }
      baMDE_Sort_Order                   : Integer;       { Stored }
      baDIS_Column_Order                 : Array[ 0..32 ] of Byte;       { Stored }
      baDIS_Column_Width                 : Array[ 0..32 ] of Integer;       { Stored }
      baDIS_Column_is_Hidden             : Array[ 0..32 ] of Boolean;       { Stored }
      baDIS_Column_is_Not_Editable       : Array[ 0..32 ] of Boolean;       { Stored }
      baDIS_Sort_Order                   : Integer;       { Stored }
      baDesktop_Super_Ledger_ID          : Integer;       { Stored }
      baCurrency_Code                    : String[ 3 ];       { Stored }
      baDefault_Forex_Source             : String[ 80 ];       { Stored }
      baDefault_Forex_Description        : String[ 80 ];       { Stored }
      baSuperFund_Ledger_Code            : String[ 20 ];       { Stored }
      baAudit_Record_ID                  : Integer;       { Stored }
      baLast_Sequence_No                 : Integer;
      baNumber                           : Integer;
      baOpening_Bank_Balance             : TLBRec;
      baBank_Movement                    : TLBRec;
      baClosing_Bank_Balance             : TLBRec;
      baOpening_CashBook_Balance         : TLBRec;
      baCashBook_Movement                : TLBRec;
      baClosing_CashBook_Balance         : TLBRec;
      baIs_Selected                      : Boolean;
      baEntries_Available                : Integer;
      baTemp_Resync_LRN                  : Integer;
      baTemp_Resync_Date                 : Integer;
      baTemp_Include_In_Scheduled_Coding_Report : Boolean;
      baTemp_Date_Of_Last_Trx_Printed    : Integer;
      baTemp_New_Date_Last_Trx_Printed   : Integer;
      baTemp_Include_In_Report           : Boolean;
      baTemp_Balance                     : Money;
      baCore_Account_ID                  : Integer;       { Stored }
      baSecure_Online_Code               : String[ 20 ];       { Stored }
      baExchange_Gain_Loss_Code          : String[ 20 ];       { Stored }
      baSuggested_UnProcessed_Count      : Integer;
      baExtract_Account_Number           : String[ 20 ];       { Stored }
      baEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tTransaction_Rec = Packed Record
      txRecord_Type                      : Byte;
      txSequence_No                      : Integer;       { Stored }
      txLRN_NOW_UNUSED                   : Integer;       { Stored }
      txType                             : Byte;       { Stored }
      txSource                           : Byte;       { Stored }
      txDate_Presented                   : Integer;       { Stored }
      txDate_Effective                   : Integer;       { Stored }
      txDate_Transferred                 : Integer;       { Stored }
      txAmount                           : Money;       { Stored }
      txGST_Class                        : Byte;       { Stored }
      txGST_Amount                       : Money;       { Stored }
      txHas_Been_Edited                  : Boolean;       { Stored }
      txQuantity                         : Money;       { Stored }
      txCheque_Number                    : Integer;       { Stored }
      txReference                        : String[ 12 ];       { Stored }
      txParticulars                      : String[ 12 ];       { Stored }
      txAnalysis                         : String[ 12 ];       { Stored }
      txOrigBB                           : String[ 6 ];       { Stored }
      txOther_Party                      : String[ 20 ];       { Stored }
      txOld_Narration                    : String[ 40 ];       { Stored }
      txAccount                          : String[ 20 ];       { Stored }
      txCoded_By                         : Byte;       { Stored }
      txPayee_Number                     : Integer;       { Stored }
      txLocked                           : Boolean;       { Stored }
      txBankLink_ID                      : Integer;       { Stored }
      txGST_Has_Been_Edited              : Boolean;       { Stored }
      txMatched_Item_ID                  : Integer;       { Stored }
      txUPI_State                        : Byte;       { Stored }
      txOriginal_Reference               : String[ 12 ];       { Stored }
      txOriginal_Source                  : Byte;       { Stored }
      txOriginal_Type                    : Byte;       { Stored }
      txOriginal_Cheque_Number           : Integer;       { Stored }
      txOriginal_Amount                  : Money;       { Stored }
      txNotes                            : AnsiString;       { Stored }
      txECoding_Import_Notes             : AnsiString;       { Stored }
      txECoding_Transaction_UID          : Integer;       { Stored }
      txGL_Narration                     : AnsiString;       { Stored }
      txStatement_Details                : AnsiString;       { Stored }
      txTax_Invoice_Available            : Boolean;       { Stored }
      txSF_Imputed_Credit                : Money;       { Stored }
      txSF_Tax_Free_Dist                 : Money;       { Stored }
      txSF_Tax_Exempt_Dist               : Money;       { Stored }
      txSF_Tax_Deferred_Dist             : Money;       { Stored }
      txSF_TFN_Credits                   : Money;       { Stored }
      txSF_Foreign_Income                : Money;       { Stored }
      txSF_Foreign_Tax_Credits           : Money;       { Stored }
      txSF_Capital_Gains_Indexed         : Money;       { Stored }
      txSF_Capital_Gains_Disc            : Money;       { Stored }
      txSF_Super_Fields_Edited           : Boolean;       { Stored }
      txSF_Capital_Gains_Other           : Money;       { Stored }
      txSF_Other_Expenses                : Money;       { Stored }
      txSF_CGT_Date                      : Integer;       { Stored }
      txExternal_GUID                    : AnsiString;       { Stored }
      txDocument_Title                   : AnsiString;       { Stored }
      txDocument_Status_Update_Required  : Boolean;       { Stored }
      txBankLink_UID                     : AnsiString;       { Stored }
      txNotes_Read                       : Boolean;       { Stored }
      txImport_Notes_Read                : Boolean;       { Stored }
      txSpare_String                     : AnsiString;       { Stored }
      txSpare_Boolean                    : Boolean;       { Stored }
      txSF_Franked                       : Money;       { Stored }
      txSF_Unfranked                     : Money;       { Stored }
      txSF_Interest                      : Money;       { Stored }
      txSF_Capital_Gains_Foreign_Disc    : Money;       { Stored }
      txSF_Rent                          : Money;       { Stored }
      txSF_Special_Income                : Money;       { Stored }
      txSF_Other_Tax_Credit              : Money;       { Stored }
      txSF_Non_Resident_Tax              : Money;       { Stored }
      txSF_Member_ID                     : String[ 20 ];       { Stored }
      txSF_Foreign_Capital_Gains_Credit  : Money;       { Stored }
      txSF_Member_Component              : Byte;       { Stored }
      txSF_Fund_ID                       : Integer;       { Stored }
      txSF_Member_Account_ID             : Integer;       { Stored }
      txSF_Fund_Code                     : String[ 20 ];       { Stored }
      txSF_Member_Account_Code           : String[ 41 ];       { Stored }
      txSF_Transaction_ID                : Integer;       { Stored }
      txSF_Transaction_Code              : AnsiString;       { Stored }
      txSF_Capital_Gains_Fraction_Half   : Boolean;       { Stored }
      txAudit_Record_ID                  : Integer;       { Stored }
      txJob_Code                         : String[ 8 ];       { Stored }
      txForex_Conversion_Rate            : Double;       { Stored }
      txSpare_Money_1                    : Money;       { Stored }
      txOriginal_Forex_Conversion_Rate   : Double;       { Stored }
      txSpare_Money_2                    : Money;       { Stored }
      txBank_Seq                         : Integer;
      txFirst_Dissection                 : pDissection_Rec;
      txLast_Dissection                  : pDissection_Rec;
      txNext_Transaction                 : pTransaction_Rec;
      txNext_Transaction_By_Type         : pTransaction_Rec;
      txMatched_By                       : pMemorisation_Detail_Rec;
      txMatched_In_Resync                : Boolean;
      txTemp_Admin_LRN                   : Integer;
      txUPC_Status                       : Byte;
      txTemp_Balance                     : Money;
      txTemp_Tag                         : Integer;
      txDate_Change                      : Boolean;
      txBank_Account                     : TObject;
      txClient                           : TObject;
      txTemp_Forex_Rate                  : Double;
      txTemp_Base_Amount                 : Money;
      txTemp_Prov_Entered_By             : String[ 8 ];
      txTemp_Prov_Date_Time              : TDateTime;
      txCore_Transaction_ID              : Integer;       { Stored }
      txTransfered_To_Online             : Boolean;       { Stored }
      txCore_Transaction_ID_High         : Integer;       { Stored }
      txIsOnline_Transaction             : Boolean;       { Stored }
      txSuggested_Mem_State              : Byte;       { Stored }
      txSuggested_Mem_Index              : Integer;       { Stored }
      txSuggested_Manual_Count           : Integer;
      txTransaction_Extension            : pTransaction_Extension_Rec;
      txEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tTransaction_Extension_Rec = Packed Record
      teRecord_Type                      : Byte;
      teSequence_No                      : Integer;       { Stored }
      teDate_Effective                   : Integer;       { Stored }
      teSF_Other_Income                  : Money;       { Stored }
      teSF_Other_Trust_Deductions        : Money;       { Stored }
      teSF_CGT_Concession_Amount         : Money;       { Stored }
      teSF_CGT_ForeignCGT_Before_Disc    : Money;       { Stored }
      teSF_CGT_ForeignCGT_Indexation     : Money;       { Stored }
      teSF_CGT_ForeignCGT_Other_Method   : Money;       { Stored }
      teSF_CGT_TaxPaid_Indexation        : Money;       { Stored }
      teSF_CGT_TaxPaid_Other_Method      : Money;       { Stored }
      teSF_Other_Net_Foreign_Income      : Money;       { Stored }
      teSF_Cash_Distribution             : Money;       { Stored }
      teSF_AU_Franking_Credits_NZ_Co     : Money;       { Stored }
      teSF_Non_Res_Witholding_Tax        : Money;       { Stored }
      teSF_LIC_Deductions                : Money;       { Stored }
      teSF_Non_Cash_CGT_Discounted_Before_Discount : Money;       { Stored }
      teSF_Non_Cash_CGT_Indexation       : Money;       { Stored }
      teSF_Non_Cash_CGT_Other_Method     : Money;       { Stored }
      teSF_Non_Cash_CGT_Capital_Losses   : Money;       { Stored }
      teSF_Share_Brokerage               : Money;       { Stored }
      teSF_Share_Consideration           : Money;       { Stored }
      teSF_Share_GST_Amount              : Money;       { Stored }
      teSF_Share_GST_Rate                : String[ 5 ];       { Stored }
      teSF_Cash_Date                     : Integer;       { Stored }
      teSF_Accrual_Date                  : Integer;       { Stored }
      teSF_Record_Date                   : Integer;       { Stored }
      teSF_Contract_Date                 : Integer;       { Stored }
      teSF_Settlement_Date               : Integer;       { Stored }
      teEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDissection_Rec = Packed Record
      dsRecord_Type                      : Byte;
      dsSequence_No                      : Integer;       { Stored }
      dsAccount                          : String[ 20 ];       { Stored }
      dsAmount                           : Money;       { Stored }
      dsGST_Class                        : Byte;       { Stored }
      dsGST_Amount                       : Money;       { Stored }
      dsQuantity                         : Money;       { Stored }
      dsOld_Narration                    : String[ 40 ];       { Stored }
      dsHas_Been_Edited                  : Boolean;       { Stored }
      dsJournal_Type                     : Byte;       { Stored }
      dsGST_Has_Been_Edited              : Boolean;       { Stored }
      dsPayee_Number                     : Integer;       { Stored }
      dsNotes                            : AnsiString;       { Stored }
      dsECoding_Import_Notes             : AnsiString;       { Stored }
      dsGL_Narration                     : AnsiString;       { Stored }
      dsLinked_Journal_Date              : Integer;       { Stored }
      dsSF_Imputed_Credit                : Money;       { Stored }
      dsSF_Tax_Free_Dist                 : Money;       { Stored }
      dsSF_Tax_Exempt_Dist               : Money;       { Stored }
      dsSF_Tax_Deferred_Dist             : Money;       { Stored }
      dsSF_TFN_Credits                   : Money;       { Stored }
      dsSF_Foreign_Income                : Money;       { Stored }
      dsSF_Foreign_Tax_Credits           : Money;       { Stored }
      dsSF_Capital_Gains_Indexed         : Money;       { Stored }
      dsSF_Capital_Gains_Disc            : Money;       { Stored }
      dsSF_Super_Fields_Edited           : Boolean;       { Stored }
      dsSF_Capital_Gains_Other           : Money;       { Stored }
      dsSF_Other_Expenses                : Money;       { Stored }
      dsSF_CGT_Date                      : Integer;       { Stored }
      dsExternal_GUID                    : AnsiString;       { Stored }
      dsDocument_Title                   : AnsiString;       { Stored }
      dsDocument_Status_Update_Required  : Boolean;       { Stored }
      dsNotes_Read                       : Boolean;       { Stored }
      dsImport_Notes_Read                : Boolean;       { Stored }
      dsReference                        : String[ 12 ];       { Stored }
      dsSF_Franked                       : Money;       { Stored }
      dsSF_Unfranked                     : Money;       { Stored }
      dsSF_Interest                      : Money;       { Stored }
      dsSF_Capital_Gains_Foreign_Disc    : Money;       { Stored }
      dsSF_Rent                          : Money;       { Stored }
      dsSF_Special_Income                : Money;       { Stored }
      dsSF_Other_Tax_Credit              : Money;       { Stored }
      dsSF_Non_Resident_Tax              : Money;       { Stored }
      dsSF_Member_ID                     : String[ 20 ];       { Stored }
      dsSF_Foreign_Capital_Gains_Credit  : Money;       { Stored }
      dsSF_Member_Component              : Byte;       { Stored }
      dsPercent_Amount                   : Money;       { Stored }
      dsAmount_Type_Is_Percent           : Boolean;       { Stored }
      dsSF_Fund_ID                       : Integer;       { Stored }
      dsSF_Member_Account_ID             : Integer;       { Stored }
      dsSF_Fund_Code                     : String[ 20 ];       { Stored }
      dsSF_Member_Account_Code           : String[ 41 ];       { Stored }
      dsSF_Transaction_ID                : Integer;       { Stored }
      dsSF_Transaction_Code              : AnsiString;       { Stored }
      dsSF_Capital_Gains_Fraction_Half   : Boolean;       { Stored }
      dsAudit_Record_ID                  : Integer;       { Stored }
      dsJob_Code                         : String[ 8 ];       { Stored }
      dsTax_Invoice                      : Boolean;       { Stored }
      dsForex_Conversion_Rate            : Double;       { Stored }
      dsForeign_Currency_Amount          : Money;       { Stored }
      dsForex_Document_Date              : Integer;       { Stored }
      dsOpening_Balance_Currency         : String[ 3 ];       { Stored }
      dsTransaction                      : pTransaction_Rec;
      dsNext                             : pDissection_Rec;
      dsBank_Account                     : TObject;
      dsClient                           : TObject;
      dsTemp_Base_Amount                 : Money;
      dsDissection_Extension             : pDissection_Extension_Rec;
      dsEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDissection_Extension_Rec = Packed Record
      deRecord_Type                      : Byte;
      deSequence_No                      : Integer;       { Stored }
      deSF_Other_Income                  : Money;       { Stored }
      deSF_Other_Trust_Deductions        : Money;       { Stored }
      deSF_CGT_Concession_Amount         : Money;       { Stored }
      deSF_CGT_ForeignCGT_Before_Disc    : Money;       { Stored }
      deSF_CGT_ForeignCGT_Indexation     : Money;       { Stored }
      deSF_CGT_ForeignCGT_Other_Method   : Money;       { Stored }
      deSF_CGT_TaxPaid_Indexation        : Money;       { Stored }
      deSF_CGT_TaxPaid_Other_Method      : Money;       { Stored }
      deSF_Other_Net_Foreign_Income      : Money;       { Stored }
      deSF_Cash_Distribution             : Money;       { Stored }
      deSF_AU_Franking_Credits_NZ_Co     : Money;       { Stored }
      deSF_Non_Res_Witholding_Tax        : Money;       { Stored }
      deSF_LIC_Deductions                : Money;       { Stored }
      deSF_Non_Cash_CGT_Discounted_Before_Discount : Money;       { Stored }
      deSF_Non_Cash_CGT_Indexation       : Money;       { Stored }
      deSF_Non_Cash_CGT_Other_Method     : Money;       { Stored }
      deSF_Non_Cash_CGT_Capital_Losses   : Money;       { Stored }
      deSF_Share_Brokerage               : Money;       { Stored }
      deSF_Share_Consideration           : Money;       { Stored }
      deSF_Share_GST_Amount              : Money;       { Stored }
      deSF_Share_GST_Rate                : String[ 5 ];       { Stored }
      deSF_Cash_Date                     : Integer;       { Stored }
      deSF_Accrual_Date                  : Integer;       { Stored }
      deSF_Record_Date                   : Integer;       { Stored }
      deSF_Contract_Date                 : Integer;       { Stored }
      deSF_Settlement_Date               : Integer;       { Stored }
      deEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tBalances_Rec = Packed Record
      blRecord_Type                      : Byte;
      blGST_Period_Starts                : Integer;       { Stored }
      blGST_Period_Ends                  : Integer;       { Stored }
      blClosing_Debtors_Balance          : Money;       { Stored }
      blOpening_Debtors_Balance          : Money;       { Stored }
      blFBT_Adjustments                  : Money;       { Stored }
      blOther_Adjustments                : Money;       { Stored }
      blClosing_Creditors_Balance        : Money;       { Stored }
      blOpening_Creditors_Balance        : Money;       { Stored }
      blCredit_Adjustments               : Money;       { Stored }
      blBAS_Document_ID                  : String[ 20 ];       { Stored }
      blBAS_1C_PT_Last_Months_Income     : Money;       { Stored }
      blBAS_1D_PT_Branch_Income          : Money;       { Stored }
      blBAS_1E_PT_Assets                 : Money;       { Stored }
      blBAS_1F_PT_Tax                    : Money;       { Stored }
      blBAS_1G_PT_Refund_Used            : Money;       { Stored }
      blBAS_5B_PT_Ratio                  : Money;       { Stored }
      blBAS_6B_GST_Adj_PrivUse           : Money;       { Stored }
      blBAS_7_VAT4_GST_Adj_BAssets       : Money;       { Stored }
      blBAS_G7_GST_Adj_Assets            : Money;       { Stored }
      blBAS_G18_GST_Adj_Entertain        : Money;       { Stored }
      blBAS_W1_GST_Adj_Change            : Money;       { Stored }
      blBAS_W2_GST_Adj_Exempt            : Money;       { Stored }
      blBAS_W3_GST_Adj_Other             : Money;       { Stored }
      blBAS_W4_GST_Cdj_BusUse            : Money;       { Stored }
      blBAS_T1_VAT1_GST_Cdj_PAssets      : Money;       { Stored }
      blBAS_T2_VAT2_GST_Cdj_Change       : Money;       { Stored }
      blBAS_T3_VAT3_GST_Cdj_Other        : Money;       { Stored }
      blBAS_T4                           : Integer;       { Stored }
      blBAS_F1_GST_Closing_Debtors_BalanceA : Money;       { Stored }
      blBAS_F2_GST_Opening_Debtors_BalanceB : Money;       { Stored }
      blBAS_F3                           : Money;       { Stored }
      blBAS_F4                           : Integer;       { Stored }
      blBAS_Form_Used                    : Byte;       { Stored }
      blBAS_GST_Option                   : Byte;       { Stored }
      blBAS_GST_Included                 : Boolean;       { Stored }
      blBAS_G21_GST_Closing_Creditors_BalanceA : Money;       { Stored }
      blBAS_G22_GST_Opening_Creditors_BalanceB : Money;       { Stored }
      blBAS_G23                          : Money;       { Stored }
      blBAS_G24                          : Integer;       { Stored }
      blBAS_PAYG_Instalment_Option       : Byte;       { Stored }
      blBAS_T7_VAT7                      : Money;       { Stored }
      blBAS_T8_VAT8                      : Money;       { Stored }
      blBAS_T9_VAT9                      : Money;       { Stored }
      blBAS_1H                           : Money;       { Stored }
      blGST_Adj_PrivUse                  : Money;       { Stored }
      blGST_Adj_BAssets                  : Money;       { Stored }
      blGST_Adj_Assets                   : Money;       { Stored }
      blGST_Adj_Entertain                : Money;       { Stored }
      blGST_Adj_Change                   : Money;       { Stored }
      blGST_Adj_Exempt                   : Money;       { Stored }
      blGST_Adj_Other                    : Money;       { Stored }
      blGST_Cdj_BusUse                   : Money;       { Stored }
      blGST_Cdj_PAssets                  : Money;       { Stored }
      blGST_Cdj_Change                   : Money;       { Stored }
      blGST_Cdj_Other                    : Money;       { Stored }
      blBAS_7C                           : Money;       { Stored }
      blBAS_7D                           : Money;       { Stored }
      blBAS_T6_VAT6                      : Money;       { Stored }
      blBAS_T5_VAT5                      : Money;       { Stored }
      blUsing_Fuel_Percent_Method        : Boolean;       { Stored }
      blPT_Form_Type                     : Byte;       { Stored }
      blGST_Cdj_Customs                  : Money;       { Stored }
      blAudit_Record_ID                  : Integer;       { Stored }
      blVAT_Adjustments                  : Array[ 0..99 ] of Money;       { Stored }
      blFirst_Fuel_Sheet                 : pFuel_Sheet_Rec;
      blLast_Fuel_Sheet                  : pFuel_Sheet_Rec;
      blEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSubGroup_Heading_Rec = Packed Record
      shRecord_Type                      : Byte;
      shHeading                          : String[ 60 ];       { Stored }
      shReport_Group_No                  : Integer;       { Stored }
      shSub_Group_No                     : Integer;       { Stored }
      shAudit_Record_ID                  : Integer;       { Stored }
      shEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDivision_Heading_Rec = Packed Record
      dhRecord_Type                      : Byte;
      dhHeading                          : String[ 60 ];       { Stored }
      dhDivision_No                      : Integer;       { Stored }
      dhAudit_Record_ID                  : Integer;       { Stored }
      dhEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tMemorised_Transaction_Rec = Packed Record
      mxRecord_Type                      : Byte;
      mxSequence_No                      : Integer;       { Stored }
      mxType                             : Byte;       { Stored }
      mxAmount                           : Money;       { Stored }
      mxReference                        : String[ 12 ];       { Stored }
      mxParticulars                      : String[ 12 ];       { Stored }
      mxAnalysis                         : String[ 12 ];       { Stored }
      mxOther_Party                      : String[ 20 ];       { Stored }
      mxStatement_Details                : String[ 200 ];       { Stored }
      mxMatch_on_Amount                  : Byte;       { Stored }
      mxMatch_on_Refce                   : Boolean;       { Stored }
      mxMatch_on_Particulars             : Boolean;       { Stored }
      mxMatch_on_Analysis                : Boolean;       { Stored }
      mxMatch_on_Other_Party             : Boolean;       { Stored }
      mxMatch_On_Statement_Details       : Boolean;       { Stored }
      mxAccount                          : Array[ 1..50 ] of String[ 20 ];       { Stored }
      mxPercentage                       : Array[ 1..50 ] of Money;       { Stored }
      mxGST_Class                        : Array[ 1..50 ] of Byte;       { Stored }
      mxPayee_Number                     : Integer;       { Stored }
      mxFrom_Master_List                 : Boolean;       { Stored }
      mxGST_Has_Been_Edited              : Array[ 1..50 ] of Boolean;       { Stored }
      mxMatch_on_Notes                   : Boolean;       { Stored }
      mxNotes                            : String[ 40 ];       { Stored }
      mxGL_Narration                     : Array[ 1..50 ] of String[ 40 ];       { Stored }
      mxLine_Type                        : Array[ 1..50 ] of Byte;       { Stored }
      mxAudit_Record_ID                  : Integer;       { Stored }
      mxNext                             : pMemorised_Transaction_Rec;
      mxEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tCustom_Heading_Rec = Packed Record
      hdRecord_Type                      : Byte;
      hdHeading_Type                     : Byte;       { Stored }
      hdHeading                          : String[ 60 ];       { Stored }
      hdMajor_ID                         : Integer;       { Stored }
      hdMinor_ID                         : Integer;       { Stored }
      hdAudit_Record_ID                  : Integer;       { Stored }
      hdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tMacro_Rec = Packed Record
      maRecord_Type                      : Byte;
      maCode                             : String[ 10 ];       { Stored }
      maDescription                      : String[ 60 ];       { Stored }
      maEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tFuel_Sheet_Rec = Packed Record
      fsRecord_Type                      : Byte;
      fsAccount                          : String[ 20 ];       { Stored }
      fsFuel_Type                        : AnsiString;       { Stored }
      fsFuel_Litres                      : Money;       { Stored }
      fsFuel_Use                         : AnsiString;       { Stored }
      fsPercentage                       : Money;       { Stored }
      fsFuel_Eligible                    : Money;       { Stored }
      fsCredit_Rate                      : Money;       { Stored }
      fsNext                             : pFuel_Sheet_Rec;
      fsEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tMoreClient_Rec = Packed Record
      mcRecord_Type                      : Byte;
      mcBAS_Dont_Print_Fuel_Sheet        : Boolean;       { Stored }
      mcArchived                         : Boolean;       { Stored }
      mcJournal_Processing_Duration      : Byte;       { Stored }
      mcEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tJob_Heading_Rec = Packed Record
      jhRecord_Type                      : Byte;
      jhHeading                          : String[ 60 ];       { Stored }
      jhLRN                              : Integer;       { Stored }
      jhDate_Completed                   : Integer;       { Stored }
      jhCode                             : String[ 8 ];       { Stored }
      jhAudit_Record_ID                  : Integer;       { Stored }
      jhEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tClientExtra_Rec = Packed Record
      ceRecord_Type                      : Byte;
      ceTAX_Applies_From                 : Array[ 1..99, 1..5 ] of Integer;       { Stored }
      ceTAX_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      ceList_Entries_Sort_Order          : Byte;       { Stored }
      ceList_Entries_Include             : Byte;       { Stored }
      ceList_Entries_Two_Column          : Boolean;       { Stored }
      ceList_Entries_Show_Balance        : Boolean;       { Stored }
      ceList_Entries_Show_Notes          : Boolean;       { Stored }
      ceList_Entries_Wrap_Narration      : Boolean;       { Stored }
      ceList_Entries_Show_Other_Party    : Boolean;       { Stored }
      ceBook_Gen_Finance_Reports         : Boolean;       { Stored }
      ceFRS_Print_NP_Chart_Code_Titles   : Boolean;       { Stored }
      ceFRS_NP_Chart_Code_Detail_Type    : Byte;       { Stored }
      ceAllow_Client_Unlock_Entries      : Boolean;       { Stored }
      ceAllow_Client_Edit_Chart          : Boolean;       { Stored }
      ceECoding_Dont_Send_Jobs           : Boolean;       { Stored }
      ceCustom_Coding_Report_XML         : AnsiString;       { Stored }
      ceCustom_Coding_Report             : Boolean;       { Stored }
      ceCoding_Report_Column_Line        : Boolean;       { Stored }
      ceScheduled_Custom_CR_XML          : AnsiString;       { Stored }
      ceBudget_Include_Quantities        : Boolean;       { Stored }
      ceScheduled_CR_Column_Line         : Boolean;       { Stored }
      ceCustom_Ledger_Report             : Boolean;       { Stored }
      ceCustom_Ledger_Report_XML         : AnsiString;       { Stored }
      ceLocal_Currency_Code              : String[ 3 ];       { Stored }
      ceBlock_Client_Edit_Mems           : Boolean;       { Stored }
      ceSend_Custom_Documents            : Boolean;       { Stored }
      ceSend_Custom_Documents_List       : Array[ 1..10 ] of String[ 40 ];       { Stored }
      ceList_Payees_Detailed             : Boolean;       { Stored }
      ceList_Payees_SortBy               : Byte;       { Stored }
      ceList_Payees_Rule_Line            : Boolean;       { Stored }
      ceCustom_SFLedger_Titles           : Array[ 1..1 ] of String[ 60 ];       { Stored }
      ceSUI_Period_Start                 : Integer;       { Stored }
      ceSUI_Period_End                   : Integer;       { Stored }
      ceAudit_Record_ID                  : Integer;       { Stored }
      ceSUI_Step_Done                    : Array[ 0..32 ] of Boolean;       { Stored }
      ceSend_Job_List                    : Boolean;       { Stored }
      ceSpare_String                     : AnsiString;       { Stored }
      ceOnline_Scheduled_Reports         : Boolean;       { Stored }
      ceFile_Transfer_Method             : Byte;       { Stored }
      ceOnlineBillingFrequency           : String[ 32 ];       { Stored }
      ceOnlineMaxOfflineDays             : Integer;       { Stored }
      ceOnlineStatus                     : Integer;       { Stored }
      ceOnlineSubscription               : Array[ 1..64 ] of String[ 36 ];       { Stored }
      ceOnlineUserEMail                  : String[ 64 ];       { Stored }
      ceOnlineUserFullName               : String[ 32 ];       { Stored }
      ceOnlineValuesStored               : Boolean;       { Stored }
      ceOnlineSubscriptionCount          : Integer;       { Stored }
      ceDeliverDataDirectToBLO           : Boolean;       { Stored }
      ceBLOSecureCode                    : String[ 20 ];       { Stored }
      ceInclude_Unused_Chart_Codes       : Boolean;       { Stored }
      ceInclude_Non_Posting_Chart_Codes  : Boolean;       { Stored }
      ceAdd_Prefix_For_Account_Code      : Integer;       { Stored }
      ceCashbook_GST_Map_File_Location   : String[ 250 ];       { Stored }
      ceCashbook_Export_File_Location    : String[ 250 ];       { Stored }
      ceBGLFundIDSelected                : String[ 64 ];       { Stored }
      ceBGLFundNameSelected              : String[ 250 ];       { Stored }
      cemyMYOBClientIDSelected           : String[ 64 ];       { Stored }
      cemyMYOBClientNameSelected         : String[ 250 ];       { Stored }
      ceList_Entries_Show_Summary        : Boolean;       { Stored }
      ceList_Entries_GroupBy_Journal_Type : Boolean;       { Stored }
      ceEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tDeleted_Transaction_Rec = Packed Record
      dxRecord_Type                      : Byte;
      dxDate_Deleted                     : Integer;       { Stored }
      dxDeleted_By                       : String[ 8 ];       { Stored }
      dxExternal_GUID                    : AnsiString;       { Stored }
      dxDate_Effective                   : Integer;       { Stored }
      dxDate_Presented                   : Integer;       { Stored }
      dxSequence_No                      : Integer;       { Stored }
      dxAmount                           : Money;       { Stored }
      dxGST_Amount                       : Money;       { Stored }
      dxQuantity                         : Money;       { Stored }
      dxAccount                          : String[ 20 ];       { Stored }
      dxReference                        : String[ 12 ];       { Stored }
      dxParticulars                      : String[ 12 ];       { Stored }
      dxCore_Transaction_ID              : Integer;       { Stored }
      dxCore_Transaction_ID_High         : Integer;       { Stored }
      dxEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tExchange_Gain_Loss_Rec = Packed Record
      glRecord_Type                      : Byte;
      glDate                             : Integer;       { Stored }
      glAmount                           : Money;       { Stored }
      glAccount                          : String[ 20 ];       { Stored }
      glPosted_Date                      : Integer;       { Stored }
      glAudit_Record_ID                  : Integer;       { Stored }
      glTemp_Bank_Seq                    : Integer;
      glEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tFinalized_Exchange_Rate_Rec = Packed Record
      frRecord_Type                      : Byte;
      frDate                             : Integer;       { Stored }
      frRate                             : Double;       { Stored }
      frEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tTPR_Payer_Detail_Rec = Packed Record
      prRecord_Type                      : Byte;
      prPracContactName                  : String[ 38 ];       { Stored }
      prPracContactPhone                 : String[ 15 ];       { Stored }
      prPracEmailAddress                 : String[ 76 ];       { Stored }
      prTradingName                      : String[ 200 ];       { Stored }
      prAddressLine1                     : String[ 38 ];       { Stored }
      prAddressLine2                     : String[ 38 ];       { Stored }
      prSuburb                           : String[ 27 ];       { Stored }
      prStateId                          : Integer;       { Stored }
      prCountry                          : String[ 20 ];       { Stored }
      prPostCode                         : String[ 4 ];       { Stored }
      prBSB                              : String[ 6 ];       { Stored }
      prAccount                          : String[ 9 ];       { Stored }
      prUsePracticeTPRSupplierDetails    : Boolean;       { Stored }
      prFirstTimeTPRATOExtractDone       : Boolean;       { Stored }
      prTRPATOReportRunUpToYear          : Integer;       { Stored }
      prEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tUnscanned_Transaction_Rec = Packed Record
      utRecord_Type                      : Byte;
      utBank_Account_Number              : String[ 20 ];       { Stored }
      utSequence_No                      : Integer;       { Stored }
      utEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tCandidate_Mem_Processing_Rec = Packed Record
      cpRecord_Type                      : Byte;
      cpCandidate_ID_To_Process          : Integer;       { Stored }
      cpNext_Candidate_ID                : Integer;       { Stored }
      cpEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tCandidate_Mem_Rec = Packed Record
      cmRecord_Type                      : Byte;
      cmID                               : Integer;       { Stored }
      cmCount                            : Integer;       { Stored }
      cmType                             : Byte;       { Stored }
      cmBank_Account_Number              : String[ 20 ];       { Stored }
      cmCoded_By                         : Byte;       { Stored }
      cmAccount                          : String[ 20 ];       { Stored }
      cmStatement_Details                : String[ 200 ];       { Stored }
      cmEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tRecommended_Mem_Rec = Packed Record
      rmRecord_Type                      : Byte;
      rmType                             : Byte;       { Stored }
      rmBank_Account_Number              : String[ 20 ];       { Stored }
      rmAccount                          : String[ 20 ];       { Stored }
      rmStatement_Details                : String[ 200 ];       { Stored }
      rmManual_Count                     : Integer;       { Stored }
      rmUncoded_Count                    : Integer;       { Stored }
      rmEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tTran_Suggested_Link_Rec = Packed Record
      tsRecord_Type                      : Byte;
      tsDate_Effective                   : Integer;       { Stored }
      tsTran_Seq_No                      : Integer;       { Stored }
      tsSuggestedId                      : Integer;       { Stored }
      tsAccountId                        : Integer;       { Stored }
      tsEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSuggested_Mem_Rec = Packed Record
      smRecord_Type                      : Byte;
      smId                               : Integer;       { Stored }
      smTypeId                           : Byte;       { Stored }
      smPhraseId                         : Integer;       { Stored }
      smStart_Data                       : Boolean;       { Stored }
      smEnd_Data                         : Boolean;       { Stored }
      smUpdate_Date                      : Integer;       { Stored }
      smHas_Changed                      : Boolean;       { Stored }
      smManual_Count                     : Integer;       { Stored }
      smHidden                           : Boolean;       { Stored }
      smEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSuggested_Account_Link_Rec = Packed Record
      slRecord_Type                      : Byte;
      slSuggestedId                      : Integer;       { Stored }
      slAccountId                        : Integer;       { Stored }
      slCount                            : Integer;       { Stored }
      slIsUncoded                        : Boolean;       { Stored }
      slIsDissected                      : Boolean;       { Stored }
      slManual_Count                     : Integer;       { Stored }
      slEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSuggested_Account_Rec = Packed Record
      saRecord_Type                      : Byte;
      saId                               : Integer;       { Stored }
      saAccount                          : String[ 20 ];       { Stored }
      saEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSuggested_Phrase_Rec = Packed Record
      spRecord_Type                      : Byte;
      spId                               : Integer;       { Stored }
      spPhrase                           : String[ 200 ];       { Stored }
      spEOR                              : Byte;
   end;

Const
   Client_Rec_Size                           = Sizeof( TClient_Rec ); 
   Account_Rec_Size                          = Sizeof( TAccount_Rec ); 
   Payee_Rec_Size                            = Sizeof( TPayee_Rec ); 
   Payee_Detail_Rec_Size                     = Sizeof( TPayee_Detail_Rec ); 
   Payee_Line_Rec_Size                       = Sizeof( TPayee_Line_Rec ); 
   Budget_Header_Rec_Size                    = Sizeof( TBudget_Header_Rec ); 
   Budget_Detail_Rec_Size                    = Sizeof( TBudget_Detail_Rec ); 
   Disk_Log_Rec_Size                         = Sizeof( TDisk_Log_Rec ); 
   Memorisation_Detail_Rec_Size              = Sizeof( TMemorisation_Detail_Rec ); 
   Memorisation_Line_Rec_Size                = Sizeof( TMemorisation_Line_Rec ); 
   Bank_Account_Rec_Size                     = Sizeof( TBank_Account_Rec ); 
   Transaction_Rec_Size                      = Sizeof( TTransaction_Rec ); 
   Transaction_Extension_Rec_Size            = Sizeof( TTransaction_Extension_Rec ); 
   Dissection_Rec_Size                       = Sizeof( TDissection_Rec ); 
   Dissection_Extension_Rec_Size             = Sizeof( TDissection_Extension_Rec ); 
   Balances_Rec_Size                         = Sizeof( TBalances_Rec ); 
   SubGroup_Heading_Rec_Size                 = Sizeof( TSubGroup_Heading_Rec ); 
   Division_Heading_Rec_Size                 = Sizeof( TDivision_Heading_Rec ); 
   Memorised_Transaction_Rec_Size            = Sizeof( TMemorised_Transaction_Rec ); 
   Custom_Heading_Rec_Size                   = Sizeof( TCustom_Heading_Rec ); 
   Macro_Rec_Size                            = Sizeof( TMacro_Rec ); 
   Fuel_Sheet_Rec_Size                       = Sizeof( TFuel_Sheet_Rec ); 
   MoreClient_Rec_Size                       = Sizeof( TMoreClient_Rec ); 
   Job_Heading_Rec_Size                      = Sizeof( TJob_Heading_Rec ); 
   ClientExtra_Rec_Size                      = Sizeof( TClientExtra_Rec ); 
   Deleted_Transaction_Rec_Size              = Sizeof( TDeleted_Transaction_Rec ); 
   Exchange_Gain_Loss_Rec_Size               = Sizeof( TExchange_Gain_Loss_Rec ); 
   Finalized_Exchange_Rate_Rec_Size          = Sizeof( TFinalized_Exchange_Rate_Rec ); 
   TPR_Payer_Detail_Rec_Size                 = Sizeof( TTPR_Payer_Detail_Rec ); 
   Unscanned_Transaction_Rec_Size            = Sizeof( TUnscanned_Transaction_Rec ); 
   Candidate_Mem_Processing_Rec_Size         = Sizeof( TCandidate_Mem_Processing_Rec ); 
   Candidate_Mem_Rec_Size                    = Sizeof( TCandidate_Mem_Rec ); 
   Recommended_Mem_Rec_Size                  = Sizeof( TRecommended_Mem_Rec ); 
   Tran_Suggested_Link_Rec_Size              = Sizeof( TTran_Suggested_Link_Rec ); 
   Suggested_Mem_Rec_Size                    = Sizeof( TSuggested_Mem_Rec ); 
   Suggested_Account_Link_Rec_Size           = Sizeof( TSuggested_Account_Link_Rec ); 
   Suggested_Account_Rec_Size                = Sizeof( TSuggested_Account_Rec ); 
   Suggested_Phrase_Rec_Size                 = Sizeof( TSuggested_Phrase_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
