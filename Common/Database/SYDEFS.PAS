Unit SYDEFS;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
Interface uses MONEYDEF, DATEDEF;
{  -------------------------------------------------------------------  }

Const
   SY_IOLIB_Version : Integer = 396;
   SY_IOLIB_Date    = '10/08/11';
   SY_FILE_VERSION   = 126;  (* Current Version counter for files
                              Changes if structure or method of storing a value would cause
                              data to be represented incorrectly, or an exception to be raised *)
   
   (*
        History :     33   GST Class Codes field now stored as delimited
                      36   GST Class Codes now stored in array
                      37   MAX_GST_CLASS up to 99 (was 20).
                      38   Added Computer name string to user record
                      39   New fields for determining how the BAS fields are calculated
                      40   No structure change, increase because memorised transaction def changed
                           if BKDEFS.  Version change need to force rebuild of master memorised files
                      41   Added Reports last printed date for use in scheduled reporting
                      42   Added Last Entry Date and Date of Last Entry Printed to bank accounts
                           Now stores Include email settings for sched reports
                           Renamed
                      43   Added Mark_As_Deleted to bank accounts.
         5.1.60.1     44   Added Enhanced Software Options Flag
         5.1.62.9     45   Added ECoding and FAxing vars
                      46   Added Ansi String values for email message and cover page message
         5.1.62.13    47   No structure change, want to force copying of the proxy ini settings
         5.1.62.25    48   No structure change, want to force upgrade of master memorised files
         5.1.64.1     49   No structure change, want to force renaming of master memorised files
         5.1.64.2     50   No structure change, want to force upgrade of master memorised files
         5.1.65.1     51   Added File Access List structure
                           Added Remote User checkbox to user record
         5.2.0.5      52   No structure change, want to force upgrade of master mem files
              .42     53   Added flag to store detailed download
                      54   MAJOR!!! no structure change to system db, FORCES UPGRADE of TRX Files
                      55   Added flag to enable CSV Export and associated settings
                      56   Added fields to store tax interface settings
                      57   Added field to store file version of last disk image
         5.2.0.74     58   Added field to store web site address
         5.2.1.97     59   Added field to store path to practice logo
                           Store Users direct dial number
                      60   Added Headers and Footers for reports
                           Added Report Date Type Style
                           Added Scheduled Reports Header and BNotes messages
         5.3.0.104    61   Added contact type field to client details cache
                           Added Fin Year Starts to client details cache
                           Added Schedule Reports method to cache
         5.3.0.105    62   Added field to indicate that contact details cache has changed
                           Added fields to store Task Tracking Settings
         5.3.0.121    63   Added header and footer display flags
                      64   Added user field to set show client manager
         5.3.0.131    65   Store date of last transaction printed during schedule reports at client level
               142    66   Force upgrade of master mem files
                      67   Added Last Print Reports Up To
         5.4.0.338/341    68   Master Memorisation file structure changed
         5.4.0.342    69   For master mem files to be reupgraded if missed in 5.4.0.338
         5.4.1        70   Store fax transport method
         5.5.0        71   Add Acclipse WebXOffice to Scheduled Reports
         5.5.0        72   Add Web Export Format
         5.6.0        73   Add Practice Marketing
         5.6.0        74   Move some prac ini settings to admin db
         5.6.0        75   Add setting for maximum narration length when extracting
         5.6.0        76   Add CheckOut to Scheduled Reports
                           Add Client Account Map list
         5.8.0        77   Add QID and OFX support
                           Add option for replacing narration with payee
         5.9          78   Add user printer choice when printing
                           Add system bank account fields for export charges
                           Add last export charges saved to
         5.9          79   Add XML field for sennding manual account info to BConnect
                           Add system bank account type (used for offsite accounts in export charges)
         5.9          80   Increase version for upgrading master mems to have payee per line
         5.9          81   Add field to store "upgrades pending flag" so can decide when to show button
         5.9          82   Add field for collection of usage data
         5.9          83   Add EULA acceptance per user
         5.11 (2007)  84   Add flags for processing status, Increase length of all email fields
                      85   Add export charges options for increasing charges, job code column, rename 'cm show legend' to spare, store numer of d.p's to extract in qty
                      86   Need a seperate sched rep method for use in filtering - don't want to mess with the Scheduled Reports one!
                      87   Version number change so we can upgrade quantities, gst rates and percentages to 4 decimal places
                      88   Edit mode settings now stored in client file, System Report Password
                      89   Add export charges options for HandiSoft, Add Archive option, Usage Counters
                      90   Force update of archive to fix duplicate tx bug
         5.12         91   Add bkmap code to upgrade (now in version 98)
                      93   Last run date for a bank account in scheduled reports in map
                      94   Option to auto-import new txns. Add downloaded processing stats.
         5.13 (2008)  95   Configurable CES font, Sched Rep using a selection instead of range, Auto-purge
                      96   System groups and client types
                      97   Remove Report headers and footers
                      98   Just increase version number os we can bkmap on upgrade
                      99   Usage counters for client files with Jobs and divisions
         5.14 (SMSF) 100   Add Tax Types
                     101   Add fields for separate superfund system
         5.15 (2009) 102   Add First Available Date field to system bank account
                     103   Add Earliest Download Date to Client Account Map
                     104   Create fd "Sort Reports By" to replace "Sort Reports By Staff Member" to allow Client Type and Group options to be used
                     105   Add Suppress Header and Footers option to User Record
                     106   Add Set Fixed Export Charge to Practice Details Record for Exporting Charges (Case 8013)
                     107   Added Print Group Header Page and Print Client Type Header Page to Pratice Details (Case 8563)
                     108   Add Practice Management System
                     109   Add Marking of an Account as No Charge (Case 6342)
                     110   Added Array of Settings for Automatic Task Creation (Case 1210)
                     111   Add Show Practice Logo option to User Record
                     112   Added GST Period Type and GST Start Month
                     113   Updated Precessing cashe to 36 months
                     114   Practice Management
                     115   Bulk Extract Code per Client
         5.16 (2009) 116   MultiCurrency
                     117   System Bankaccount Inactive, Institution and Practice code, Repurposed Spare-Integer-1 to Last-ChargeFile-Date
                     118   Repurposed Spare Text 1 and Spare Byte 1 for custom documents
       5.16.8 (2010) 119   Add frequency column to system bank account
                     120   Add frequency change pending column to system bank account
       5.17.1 (WebNotes) 121   Add Custom Document for Webnotes email
                           Add Webnotes Email Notification flags.
                           Add WebNotes available status
       5.20.0 (UK 2011)  122   Add ISO Codes array for quick access to a list of currencies used in the Client File
       5.21.0 (UK AUDIT) 123   Added Audit table and Audit Record ID to all tables
                         124   Added System Memorisation List for storing Master Memorisations
                         125   Added Provisional Entries Log
       5.22.0 (CICO)     126   Added Send Method and Client File GUID to Client rec
   *)
   //Memorisation Detail - 140 Don't reuse token!!! - Record defined in BK.TXT but used in SY for Master Mems
   //Memorisation Line - 145 Don't reuse token!!! - Record defined in BK.TXT but used in SY for Master Mems

{  -------------------------------------------------------------------  }

Type
   pPractice_Details_Rec                 = ^tPractice_Details_Rec ;
   pSystem_Disk_Log_Rec                  = ^tSystem_Disk_Log_Rec ;
   pUser_Rec                             = ^tUser_Rec ;
   pSystem_Bank_Account_Rec              = ^tSystem_Bank_Account_Rec ;
   pClient_File_Rec                      = ^tClient_File_Rec ;
   pFile_Access_Mapping_Rec              = ^tFile_Access_Mapping_Rec ;
   pClient_Account_Map_Rec               = ^tClient_Account_Map_Rec ;
   pGroup_Rec                            = ^tGroup_Rec ;
   pClient_Type_Rec                      = ^tClient_Type_Rec ;
   pAudit_Trail_Rec                      = ^tAudit_Trail_Rec ;
   pProvisional_Entries_Log_Rec          = ^tProvisional_Entries_Log_Rec ;
   pSystem_Memorisation_List_Rec         = ^tSystem_Memorisation_List_Rec ;

{  -------------------------------------------------------------------  }

   tPractice_Details_Rec = Packed Record
      fdRecord_Type                      : Byte;
      fdPractice_Name_for_Reports        : String[ 60 ];       { Stored }
      fdPractice_EMail_Address           : String[ 80 ];       { Stored }
      fdAccounting_System_Used           : Byte;       { Stored }
      fdCountry                          : Byte;       { Stored }
      fdLoad_Client_Files_From           : String[ 128 ];       { Stored }
      fdSave_Client_Files_To             : String[ 128 ];       { Stored }
      fdShort_Name                       : Array[ 0..100 ] of String[ 10 ];       { Stored }
      fdLong_Name                        : Array[ 0..100 ] of String[ 30 ];       { Stored }
      fdGST_Class_Names                  : Array[ 1..99 ] of String[ 60 ];       { Stored }
      fdGST_Class_Types                  : Array[ 1..99 ] of Byte;       { Stored }
      fdGST_Account_Codes                : Array[ 1..99 ] of String[ 20 ];       { Stored }
      fdGST_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      fdGST_Applies_From                 : Array[ 1..5 ] of Integer;       { Stored }
      fdDate_of_Last_Entry_Received      : Integer;       { Stored }
      fdPrint_Reports_Up_To              : Integer;       { Stored }
      fdSpare_Boolean_3                  : Boolean;       { Stored }
      fdPrint_Staff_Member_Header_Page   : Boolean;       { Stored }
      fdPrint_Client_Header_Page         : Boolean;       { Stored }
      fdPIN_Number                       : Integer;       { Stored }
      fdBankLink_Code                    : String[ 8 ];       { Stored }
      fdDisk_Sequence_No                 : Integer;       { Stored }
      fdMagic_Number                     : Integer;       { Stored }
      fdCoding_Report_Style              : Byte;       { Stored }
      fdCoding_Report_Sort_Order         : Byte;       { Stored }
      fdCoding_Report_Entry_Selection    : Byte;       { Stored }
      fdCoding_Report_Blank_Lines        : Byte;       { Stored }
      fdCoding_Report_Rule_Line          : Boolean;       { Stored }
      fdBank_Account_LRN_Counter         : Integer;       { Stored }
      fdUser_LRN_Counter                 : Integer;       { Stored }
      fdTransaction_LRN_Counter          : Integer;       { Stored }
      fdClient_File_LRN_Counter          : Integer;       { Stored }
      fdBankLink_Connect_Password        : String[ 60 ];       { Stored }
      fdOld_GST_Class_Codes              : String[ 255 ];       { Stored }
      fdAccount_Code_Mask                : String[ 20 ];       { Stored }
      fdFile_Version                     : Integer;       { Stored }
      fdSched_Rep_Email_Subject          : String[ 128 ];       { Stored }
      fdOld_Sched_Rep_Email_Line1        : String[ 255 ];       { Stored }
      fdOld_Sched_Rep_Email_Line2        : String[ 255 ];       { Stored }
      fdOLD_BAS_Special_Accounts         : Array[ 1..10 ] of String[ 20 ];       { Stored }
      fdGST_Class_Codes                  : Array[ 1..99 ] of String[ 5 ];       { Stored }
      fdBAS_Field_Number                 : Array[ 1..100 ] of Byte;       { Stored }
      fdBAS_Field_Source                 : Array[ 1..100 ] of Byte;       { Stored }
      fdBAS_Field_Account_Code           : Array[ 1..100 ] of String[ 20 ];       { Stored }
      fdBAS_Field_Balance                : Array[ 1..100 ] of Byte;       { Stored }
      fdSched_Rep_Include_Email          : Boolean;       { Stored }
      fdSched_Rep_Email_Only             : Boolean;       { Stored }
      fdSched_Rep_Include_Printer        : Boolean;       { Stored }
      fdSched_Rep_Include_Fax            : Boolean;       { Stored }
      fdSched_Rep_Send_Fax_Off_Peak      : Boolean;       { Stored }
      fdEnhanced_Software_Options        : Array[ 1..20 ] of Boolean;       { Stored }
      fdSched_Rep_Include_ECoding        : Boolean;       { Stored }
      fdSched_Rep_Cover_Page_Name        : AnsiString;       { Stored }
      fdSched_Rep_Cover_Page_Subject     : String[ 128 ];       { Stored }
      fdSched_Rep_Cover_Page_Message     : AnsiString;       { Stored }
      fdSched_Rep_Email_Message          : AnsiString;       { Stored }
      fdDownload_Report_Options          : Integer;       { Stored }
      fdDownload_Report_Hide_Deleted     : Boolean;       { Stored }
      fdBulk_Export_Enabled              : Boolean;       { Stored }
      fdSpare_Byte_0                     : Byte;       { Stored }
      fdBulk_Export_Code                 : AnsiString;       { Stored }
      fdSched_Rep_Include_CSV_Export     : Boolean;       { Stored }
      fdTax_Interface_Used               : Byte;       { Stored }
      fdSave_Tax_Files_To                : AnsiString;       { Stored }
      fdLast_Disk_Image_Version          : Integer;       { Stored }
      fdPractice_Web_Site                : AnsiString;       { Stored }
      fdPractice_Phone                   : String[ 20 ];       { Stored }
      fdPractice_Logo_Filename           : AnsiString;       { Stored }
      fdSched_Rep_Print_Custom_Doc_GUID  : AnsiString;       { Stored }
      fdSched_Rep_Print_Custom_Doc       : Byte;       { Stored }
      fdLast_ChargeFile_Date             : Integer;       { Stored }
      fdAudit_Record_ID                  : Integer;       { Stored }
      fdSched_Rep_Fax_Custom_Doc_GUID    : AnsiString;       { Stored }
      fdSched_Rep_Fax_Custom_Doc         : Byte;       { Stored }
      fdSpare_Text_3                     : AnsiString;       { Stored }
      fdSched_Rep_Email_Custom_Doc_GUID  : AnsiString;       { Stored }
      fdSched_Rep_Email_Custom_Doc       : Byte;       { Stored }
      fdSpare_Text_5                     : AnsiString;       { Stored }
      fdSched_Rep_Books_Custom_Doc_GUID  : AnsiString;       { Stored }
      fdSched_Rep_Books_Custom_Doc       : Byte;       { Stored }
      fdSpare_Integer_3                  : Integer;       { Stored }
      fdSpare_Integer_4                  : Integer;       { Stored }
      fdSched_Rep_Notes_Custom_Doc_GUID  : AnsiString;       { Stored }
      fdSched_Rep_Notes_Custom_Doc       : Byte;       { Stored }
      fdSpare_Text_8                     : AnsiString;       { Stored }
      fdSched_Rep_WebNotes_Custom_Doc_GUID : AnsiString;       { Stored }
      fdSched_Rep_WebNotes_Custom_Doc    : Byte;       { Stored }
      fdSpare_Integer_5                  : Integer;       { Stored }
      fdSpare_Integer_6                  : Integer;       { Stored }
      fdSpare_Text_10                    : AnsiString;       { Stored }
      fdSpare_Byte_7                     : Byte;       { Stored }
      fdSpare_Text_11                    : AnsiString;       { Stored }
      fdSpare_Text_12                    : AnsiString;       { Stored }
      fdSpare_Byte_8                     : Byte;       { Stored }
      fdSpare_Text_13                    : AnsiString;       { Stored }
      fdSpare_Text_14                    : AnsiString;       { Stored }
      fdSpare_Byte_9                     : Byte;       { Stored }
      fdSpare_Integer_7                  : Integer;       { Stored }
      fdSpare_Integer_8                  : Integer;       { Stored }
      fdSched_Rep_WebNotes_Subject       : AnsiString;       { Stored }
      fdSpare_Byte_10                    : Byte;       { Stored }
      fdSched_Rep_webNotes_Message       : AnsiString;       { Stored }
      fdSpare_Byte_11                    : Byte;       { Stored }
      fdSched_Rep_Header_Message         : AnsiString;       { Stored }
      fdSched_Rep_BNotes_Subject         : String[ 128 ];       { Stored }
      fdSched_Rep_BNotes_Message         : AnsiString;       { Stored }
      fdSpare_Boolean_4                  : Boolean;       { Stored }
      fdTask_Tracking_Prompt_Type        : Byte;       { Stored }
      fdSpare_Bool_1                     : Boolean;       { Stored }
      fdSpare_Bool_2                     : Boolean;       { Stored }
      fdSpare_Integer_9                  : Integer;       { Stored }
      fdSched_Rep_Fax_Transport          : Byte;       { Stored }
      fdSched_Rep_Include_WebX           : Boolean;       { Stored }
      fdWeb_Export_Format                : Byte;       { Stored }
      fdForce_Login                      : Boolean;       { Stored }
      fdLogin_Bitmap_Filename            : String[ 255 ];       { Stored }
      fdAuto_Print_Sched_Rep_Summary     : Boolean;       { Stored }
      fdIgnore_Quantity_In_Download      : Boolean;       { Stored }
      fdSpare_Boolean_1                  : Byte;       { Stored }
      fdspare_Boolean_2                  : Byte;       { Stored }
      fdCopy_Dissection_Narration        : Boolean;       { Stored }
      fdRound_Cashflow_Reports           : Boolean;       { Stored }
      fdUse_Xlon_Chart_Order             : Boolean;       { Stored }
      fdExtract_Multiple_Accounts_PA     : Boolean;       { Stored }
      fdExtract_Journal_Accounts_PA      : Boolean;       { Stored }
      fdExtract_Quantity                 : Boolean;       { Stored }
      fdReports_New_Page                 : Boolean;       { Stored }
      fdPrint_Merge_Report_Summary       : Byte;       { Stored }
      fdEmail_Merge_Report_Summary       : Byte;       { Stored }
      fdMaximum_Narration_Extract        : Integer;       { Stored }
      fdSched_Rep_Include_CheckOut       : Boolean;       { Stored }
      fdSched_Rep_CheckOut_Subject       : String[ 128 ];       { Stored }
      fdSched_Rep_CheckOut_Message       : AnsiString;       { Stored }
      fdSched_Rep_Include_Business_Products : Boolean;       { Stored }
      fdSched_Rep_Business_Products_Subject : String[ 128 ];       { Stored }
      fdSched_Rep_Business_Products_Message : AnsiString;       { Stored }
      fdReplace_Narration_With_Payee     : Boolean;       { Stored }
      fdLast_Export_Charges_Saved_To     : AnsiString;       { Stored }
      fdManual_Account_XML               : AnsiString;       { Stored }
      fdUpdates_Pending                  : Boolean;       { Stored }
      fdUpdate_Server_For_Offsites       : AnsiString;       { Stored }
      fdCollect_Usage_Data               : Boolean;       { Stored }
      fdFixed_Charge_Increase            : Boolean;       { Stored }
      fdPercentage_Charge_Increase       : Boolean;       { Stored }
      fdFixed_Dollar_Amount              : Money;       { Stored }
      fdDistributed_Dollar_Amount        : Money;       { Stored }
      fdPercentage_Increase_Amount       : Money;       { Stored }
      fdExtract_Quantity_Decimal_Places  : Byte;       { Stored }
      fdExport_Charges_Remarks           : AnsiString;       { Stored }
      fdSystem_Report_Password           : String[ 8 ];       { Stored }
      fdPrint_Reports_From               : Integer;       { Stored }
      fdHighest_Date_Ever_Downloaded     : Integer;       { Stored }
      fdAuto_Retrieve_New_Transactions   : Boolean;       { Stored }
      fdCoding_Font                      : AnsiString;       { Stored }
      fdSort_Reports_Option              : Byte;       { Stored }
      fdSpare_Byte_12                    : Byte;       { Stored }
      fdGroup_LRN_Counter                : Integer;       { Stored }
      fdClient_Type_LRN_Counter          : Integer;       { Stored }
      fdTAX_Applies_From                 : Array[ 1..99, 1..5 ] of Integer;       { Stored }
      fdTAX_Rates                        : Array[ 1..99, 1..5 ] of Money;       { Stored }
      fdSuperfund_System                 : Byte;       { Stored }
      fdSuperfund_Code_Mask              : String[ 20 ];       { Stored }
      fdLoad_Client_Super_Files_From     : String[ 128 ];       { Stored }
      fdSave_Client_Super_Files_To       : String[ 128 ];       { Stored }
      fdSort_Reports_By                  : Integer;       { Stored }
      fdSet_Fixed_Dollar_Amount          : Money;       { Stored }
      fdPrint_Group_Header_Page          : Boolean;       { Stored }
      fdPrint_Client_Type_Header_Page    : Boolean;       { Stored }
      fdPractice_Management_System       : Byte;       { Stored }
      fdAutomatic_Task_Creation_Flags    : Array[ 1..7 ] of Boolean;       { Stored }
      fdAutomatic_Task_Reminder_Delay    : Array[ 1..7 ] of Integer;       { Stored }
      fdAutomatic_Task_Closing_Flags     : Array[ 1..7 ] of Boolean;       { Stored }
      fdEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSystem_Disk_Log_Rec = Packed Record
      dlRecord_Type                      : Byte;
      dlDisk_ID                          : String[ 20 ];       { Stored }
      dlDate_Downloaded                  : Integer;       { Stored }
      dlNo_of_Accounts                   : Integer;       { Stored }
      dlNo_of_Entries                    : Integer;       { Stored }
      dlWas_In_Last_Download             : Boolean;       { Stored }
      dlAudit_Record_ID                  : Integer;       { Stored }
      dlEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tUser_Rec = Packed Record
      usRecord_Type                      : Byte;
      usCode                             : String[ 8 ];       { Stored }
      usName                             : String[ 60 ];       { Stored }
      usPassword                         : String[ 8 ];       { Stored }
      usEMail_Address                    : String[ 80 ];       { Stored }
      usSystem_Access                    : Boolean;       { Stored }
      usDialog_Colour                    : Byte;       { Stored }
      usLogged_In                        : Boolean;       { Stored }
      usReverse_Mouse_Buttons            : Boolean;       { Stored }
      usMASTER_Access                    : Boolean;       { Stored }
      usLRN                              : Integer;       { Stored }
      usSpare_String                     : String[ 40 ];       { Stored }
      usWorkstation_Logged_In_At         : String[ 20 ];       { Stored }
      usIs_Remote_User                   : Boolean;       { Stored }
      usDirect_Dial                      : String[ 20 ];       { Stored }
      usShow_CM_on_open                  : Boolean;       { Stored }
      usShow_Printer_Choice              : Boolean;       { Stored }
      usEULA_Version                     : AnsiString;       { Stored }
      usSpare_Boolean                    : Boolean;       { Stored }
      usLogin_Count                      : Integer;       { Stored }
      usReset_Count                      : Integer;       { Stored }
      usSuppress_HF                      : Byte;       { Stored }
      usShow_Practice_Logo               : Boolean;       { Stored }
      usAudit_Record_ID                  : Integer;       { Stored }
      usEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSystem_Bank_Account_Rec = Packed Record
      sbRecord_Type                      : Byte;
      sbAccount_Number                   : String[ 20 ];       { Stored }
      sbAccount_Name                     : String[ 60 ];       { Stored }
      sbAccount_Password                 : String[ 20 ];       { Stored }
      sbLRN                              : Integer;       { Stored }
      sbClient                           : Integer;       { Stored }
      sbCurrent_Balance                  : Money;       { Stored }
      sbLast_Transaction_LRN             : Integer;       { Stored }
      sbNew_This_Month                   : Boolean;       { Stored }
      sbNo_of_Entries_This_Month         : Integer;       { Stored }
      sbFrom_Date_This_Month             : Integer;       { Stored }
      sbTo_Date_This_Month               : Integer;       { Stored }
      sbCost_Code                        : String[ 10 ];       { Stored }
      sbCharges_This_Month               : Money;       { Stored }
      sbOpening_Balance_from_Disk        : Money;       { Stored }
      sbClosing_Balance_from_Disk        : Money;       { Stored }
      sbAttach_Required                  : Boolean;       { Stored }
      sbWas_On_Latest_Disk               : Boolean;       { Stored }
      sbLast_Entry_Date                  : Integer;       { Stored }
      sbDate_Of_Last_Entry_Printed       : Integer;       { Stored }
      sbMark_As_Deleted                  : Boolean;       { Stored }
      sbFile_Code                        : AnsiString;       { Stored }
      sbClient_ID                        : AnsiString;       { Stored }
      sbMatter_ID                        : AnsiString;       { Stored }
      sbAssignment_ID                    : AnsiString;       { Stored }
      sbDisbursement_ID                  : AnsiString;       { Stored }
      sbAccount_Type                     : Byte;       { Stored }
      sbJob_Code                         : String[ 8 ];       { Stored }
      sbActivity_Code                    : String[ 2 ];       { Stored }
      sbUnused                           : Integer;       { Stored }
      sbFirst_Available_Date             : Integer;       { Stored }
      sbNo_Charge_Account                : Boolean;       { Stored }
      sbCurrency_Code                    : String[ 3 ];       { Stored }
      sbInstitution                      : String[ 40 ];       { Stored }
      sbInActive                         : Boolean;       { Stored }
      sbBankLink_Code                    : String[ 8 ];       { Stored }
      sbFrequency                        : Byte;       { Stored }
      sbFrequency_Change_Pending         : Byte;       { Stored }
      sbAudit_Record_ID                  : Integer;       { Stored }
      sbEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tClient_File_Rec = Packed Record
      cfRecord_Type                      : Byte;
      cfFile_Code                        : String[ 10 ];       { Stored }
      cfFile_Name                        : String[ 60 ];       { Stored }
      cfFile_Type                        : Byte;       { Stored }
      cfFile_Status                      : Byte;       { Stored }
      cfFile_Password                    : String[ 8 ];       { Stored }
      cfDate_Last_Accessed               : Integer;       { Stored }
      cfFile_Save_Count                  : Integer;       { Stored }
      cfUser_Responsible                 : Integer;       { Stored }
      cfCurrent_User                     : Integer;       { Stored }
      cfLRN                              : Integer;       { Stored }
      cfReport_Start_Date                : Integer;       { Stored }
      cfReporting_Period                 : Byte;       { Stored }
      cfForeign_File                     : Boolean;       { Stored }
      cfUnused_Date_Field                : Integer;       { Stored }
      cfReports_Due                      : Boolean;       { Stored }
      cfContact_Details_To_Show          : Byte;       { Stored }
      cfFinancial_Year_Starts            : Integer;       { Stored }
      cfSchd_Rep_Method                  : Byte;       { Stored }
      cfSpareBoolean                     : Boolean;       { Stored }
      cfPending_ToDo_Count               : Integer;       { Stored }
      cfNext_ToDo_Desc                   : String[ 80 ];       { Stored }
      cfNext_ToDo_Rem_Date               : Integer;       { Stored }
      cfHas_Client_Notes                 : Boolean;       { Stored }
      cfOverdue_ToDo_Count               : Integer;       { Stored }
      cfSched_Rep_Reports_To_Send        : Integer;       { Stored }
      cfContact_Details_Edit_Date        : Integer;       { Stored }
      cfContact_Details_Edit_Time        : Integer;       { Stored }
      cfBank_Accounts                    : AnsiString;       { Stored }
      cfDate_Of_Last_Entry_Printed       : Integer;       { Stored }
      cfLast_Print_Reports_Up_To         : Integer;       { Stored }
      cfClient_Type                      : Byte;       { Stored }
      cfCoded                            : Array[ 1..36 ] of Byte;       { Stored }
      cfFinalized                        : Array[ 1..36 ] of Byte;       { Stored }
      cfTransferred                      : Array[ 1..36 ] of Byte;       { Stored }
      cfLast_Processing_Status_Date      : Integer;       { Stored }
      cfSchd_Rep_Method_Filter           : Byte;       { Stored }
      cfArchived                         : Boolean;       { Stored }
      cfPayee_Count                      : Integer;       { Stored }
      cfBank_Account_Count               : Integer;       { Stored }
      cfManual_Account_Count             : Integer;       { Stored }
      cfMem_Count                        : Integer;       { Stored }
      cfAccounting_System                : AnsiString;       { Stored }
      cfDownloaded                       : Array[ 1..36 ] of Byte;       { Stored }
      cfGroup_LRN                        : Integer;       { Stored }
      cfClient_Type_LRN                  : Integer;       { Stored }
      cfJob_Count                        : Integer;       { Stored }
      cfDivision_Count                   : Integer;       { Stored }
      cfGST_Period                       : Byte;       { Stored }
      cfGST_Start_Month                  : Byte;       { Stored }
      cfBulk_Extract_Code                : String[ 8 ];       { Stored }
      cfWebNotesAvailable                : Array[ 1..36 ] of Byte;       { Stored }
      cfWebNotes_Email_Notifications     : Integer;       { Stored }
      cfISO_Codes                        : Array[ 1..99 ] of String[ 3 ];       { Stored }
      cfAudit_Record_ID                  : Integer;       { Stored }
      cfSend_Method                      : Byte;       { Stored }
      cfClient_File_GUID                 : AnsiString;       { Stored }
      cfEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tFile_Access_Mapping_Rec = Packed Record
      acRecord_Type                      : Byte;
      acUser_LRN                         : Integer;       { Stored }
      acClient_File_LRN                  : Integer;       { Stored }
      acAudit_Record_ID                  : Integer;       { Stored }
      acEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tClient_Account_Map_Rec = Packed Record
      amRecord_Type                      : Byte;
      amClient_LRN                       : Integer;       { Stored }
      amAccount_LRN                      : Integer;       { Stored }
      amLast_Date_Printed                : Integer;       { Stored }
      amTemp_Last_Date_Printed           : Integer;       { Stored }
      amEarliest_Download_Date           : Integer;       { Stored }
      amAudit_Record_ID                  : Integer;       { Stored }
      amEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tGroup_Rec = Packed Record
      grRecord_Type                      : Byte;
      grLRN                              : Integer;       { Stored }
      grName                             : String[ 60 ];       { Stored }
      grAudit_Record_ID                  : Integer;       { Stored }
      grEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tClient_Type_Rec = Packed Record
      ctRecord_Type                      : Byte;
      ctLRN                              : Integer;       { Stored }
      ctName                             : String[ 60 ];       { Stored }
      ctAudit_Record_ID                  : Integer;       { Stored }
      ctEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tAudit_Trail_Rec = Packed Record
      atRecord_Type                      : Byte;
      atAudit_ID                         : Integer;       { Stored }
      atTransaction_Type                 : Byte;       { Stored }
      atAudit_Action                     : Byte;       { Stored }
      atDate_Time                        : TDateTime;       { Stored }
      atUser_Code                        : String[ 8 ];       { Stored }
      atRecord_ID                        : Integer;       { Stored }
      atParent_ID                        : Integer;       { Stored }
      atChanged_Fields                   : Array[ 0..254 ] of Byte;       { Stored }
      atOther_Info                       : AnsiString;       { Stored }
      atAudit_Record_Type                : Byte;       { Stored }
      atAudit_Record                     : Pointer;
      atEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tProvisional_Entries_Log_Rec = Packed Record
      peRecord_Type                      : Byte;
      peDate_Time                        : TDateTime;       { Stored }
      peUser_Code                        : String[ 8 ];       { Stored }
      peFirst_LRN                        : Integer;       { Stored }
      peLast_LRN                         : Integer;       { Stored }
      peEOR                              : Byte;
   end;

{  -------------------------------------------------------------------  }

   tSystem_Memorisation_List_Rec = Packed Record
      smRecord_Type                      : Byte;
      smAudit_Record_ID                  : Integer;       { Stored }
      smBank_Prefix                      : String[ 5 ];       { Stored }
      smMemorisations                    : Pointer;
      smEOR                              : Byte;
   end;

Const
   Practice_Details_Rec_Size                 = Sizeof( TPractice_Details_Rec ); 
   System_Disk_Log_Rec_Size                  = Sizeof( TSystem_Disk_Log_Rec ); 
   User_Rec_Size                             = Sizeof( TUser_Rec ); 
   System_Bank_Account_Rec_Size              = Sizeof( TSystem_Bank_Account_Rec ); 
   Client_File_Rec_Size                      = Sizeof( TClient_File_Rec ); 
   File_Access_Mapping_Rec_Size              = Sizeof( TFile_Access_Mapping_Rec ); 
   Client_Account_Map_Rec_Size               = Sizeof( TClient_Account_Map_Rec ); 
   Group_Rec_Size                            = Sizeof( TGroup_Rec ); 
   Client_Type_Rec_Size                      = Sizeof( TClient_Type_Rec ); 
   Audit_Trail_Rec_Size                      = Sizeof( TAudit_Trail_Rec ); 
   Provisional_Entries_Log_Rec_Size          = Sizeof( TProvisional_Entries_Log_Rec ); 
   System_Memorisation_List_Rec_Size         = Sizeof( TSystem_Memorisation_List_Rec ); 

{  -------------------------------------------------------------------  }
Implementation
{  -------------------------------------------------------------------  }

end.
