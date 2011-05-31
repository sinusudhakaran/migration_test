{-----------------------------------------------------------------------------
 Unit Name: BKAuditValues
 Author:    scott.wilson
 Date:      31-May-2011
 Purpose:   Gets Client File audit information for the audit report.
 History:
-----------------------------------------------------------------------------}

unit BKAuditValues;

interface

uses
  BKDEFS, AuditMgr, BKAuditUtils;

  procedure AddClientAuditValues(AAuditRecord: TAudit_Trail_Rec;
                                 AAuditMgr: TClientAuditManager;
                                 var Values: string);
  procedure AddBankAccountAuditValues(const AAuditRecord: TAudit_Trail_Rec;
                                      AAuditMgr: TClientAuditManager;  
                                      var Values: string);
  procedure AddTransactionAuditValues(const AAuditRecord: TAudit_Trail_Rec;
                                      AAuditMgr: TClientAuditManager;
                                      ClientFields: TClient_Rec;
                                      var Values: string);
  procedure AddPayeeAuditValues(const AAuditRecord: TAudit_Trail_Rec;
                                AAuditMgr: TClientAuditManager;
                                var Values: string);

implementation

uses
  BKCONST, GenUtils, MoneyUtils, BkDateUtils, TransactionUtils,
  BKAudit,
  BKCLIO,
  BKCEIO,
  BKBAIO,
  BKTXIO,
  BKPDIO,
  BKPLIO;

procedure AddClientAuditValues(AAuditRecord: TAudit_Trail_Rec;
  AAuditMgr: TClientAuditManager; var Values: string);
var
  ARecord: Pointer;
  Token, idx: byte;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;


  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Client:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Code
            22: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clCode, Values);
            //Name
            23: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clName, Values);
            //Address_L1
            24: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clAddress_L1, Values);
            //Address_L2
            25: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clAddress_L2, Values);
            //Address_L3
            26: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clAddress_L3, Values);
            //Contact_Name
            27: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clContact_Name, Values);
            //Phone_No
            28: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clPhone_No, Values);
            //Fax_No
            29: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clFax_No, Values);
      //    FAuditNamesArray[20,29] := 'File_Password';
            //Practice_Name
            31: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clPractice_Name, Values);
            //Staff_Member_Name
            32: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clStaff_Member_Name, Values);
            //Practice_EMail_Address
            33: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clPractice_EMail_Address, Values);
            //Staff_Member_EMail_Address
            34: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clStaff_Member_EMail_Address, Values);
            //Client_EMail_Address
            35: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clClient_EMail_Address, Values);
      //    FAuditNamesArray[20,35] := 'Country';
      //    FAuditNamesArray[20,36] := 'File_Name';
      //    FAuditNamesArray[20,37] := 'File_Type';
      //    FAuditNamesArray[20,38] := 'File_Version';
      //    FAuditNamesArray[20,39] := 'File_Save_Count';
      //    FAuditNamesArray[20,40] := 'BankLink_Connect_Password';
      //    FAuditNamesArray[20,41] := 'PIN_Number';
      //    FAuditNamesArray[20,42] := 'Old_Restrict_Analysis_Codes';
            //Financial_Year_Starts
            44: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              BkDate2Str(tClient_Rec(ARecord^).clFinancial_Year_Starts), Values);
    //    FAuditNamesArray[20,44] := 'Report_Start_Date';
    //    FAuditNamesArray[20,45] := 'Reporting_Period';
      //    FAuditNamesArray[20,46] := 'Old_Send_Reports_To';
    //    FAuditNamesArray[20,47] := 'Send_Coding_Report';
    //    FAuditNamesArray[20,48] := 'Send_Chart_of_Accounts';
    //    FAuditNamesArray[20,49] := 'Send_Unpresented_Cheque_List';
    //    FAuditNamesArray[20,50] := 'Send_Payee_List';
    //    FAuditNamesArray[20,51] := 'Send_Payee_Report';
    //    FAuditNamesArray[20,52] := 'Short_Name';
    //    FAuditNamesArray[20,53] := 'Long_Name';
    //    FAuditNamesArray[20,54] := 'GST_Number';
    //    FAuditNamesArray[20,55] := 'GST_Period';
      //    FAuditNamesArray[20,56] := 'GST_Start_Month';
      //    FAuditNamesArray[20,57] := 'GST_Applies_From';
      //    FAuditNamesArray[20,58] := 'GST_Class_Names';
      //    FAuditNamesArray[20,59] := 'GST_Class_Types';
      //    FAuditNamesArray[20,60] := 'GST_Account_Codes';
      //    FAuditNamesArray[20,61] := 'GST_Rates';
      //    FAuditNamesArray[20,62] := 'GST_Basis';
      //    FAuditNamesArray[20,63] := 'GST_on_Presentation_Date';
      //    FAuditNamesArray[20,64] := 'GST_Excludes_Accruals';
      //    FAuditNamesArray[20,65] := 'GST_Inclusive_Cashflow';
      //    FAuditNamesArray[20,66] := 'Accounting_System_Used';
      //    FAuditNamesArray[20,67] := 'Account_Code_Mask';
      //    FAuditNamesArray[20,68] := 'Load_Client_Files_From';
      //    FAuditNamesArray[20,69] := 'Save_Client_Files_To';
      //    FAuditNamesArray[20,70] := 'Chart_Is_Locked';
      //    FAuditNamesArray[20,71] := 'Chart_Last_Updated';
      //    FAuditNamesArray[20,72] := 'Coding_Report_Style';
      //    FAuditNamesArray[20,73] := 'Coding_Report_Sort_Order';
      //    FAuditNamesArray[20,74] := 'Coding_Report_Entry_Selection';
      //    FAuditNamesArray[20,75] := 'Coding_Report_Blank_Lines';
      //    FAuditNamesArray[20,76] := 'Coding_Report_Rule_Line';
      //    FAuditNamesArray[20,77] := 'Coding_Report_New_Page';
      //    FAuditNamesArray[20,78] := 'Old_Division_Names';
      //    FAuditNamesArray[20,79] := 'CF_Headings';
      //    FAuditNamesArray[20,80] := 'PR_Headings';
      //    FAuditNamesArray[20,81] := 'Magic_Number';
      //    FAuditNamesArray[20,82] := 'Exception_Options';
      //    FAuditNamesArray[20,83] := 'Period_Start_Date';
      //    FAuditNamesArray[20,84] := 'Period_End_Date';
      //    FAuditNamesArray[20,85] := 'FRS_Print_Chart_Codes';
      //    FAuditNamesArray[20,86] := 'BankLink_Code';
            //BankLink_Code
            87: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clBankLink_Code, Values);
      //    FAuditNamesArray[20,87] := 'Disk_Sequence_No';
      //    FAuditNamesArray[20,88] := 'Staff_Member_LRN';
      //    FAuditNamesArray[20,89] := 'Suppress_Check_for_New_TXns';
            //Download_From
            91: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              dlNames[tClient_Rec(ARecord^).clDownload_From], Values);
            //Last_Batch_Number
            92: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                              tClient_Rec(ARecord^).clLast_Batch_Number, Values);
      //    FAuditNamesArray[20,92] := 'Old_GST_Class_Codes';
      //    FAuditNamesArray[20,93] := 'Division_Code_List';
      //    FAuditNamesArray[20,94] := 'SB_Export_As';
      //    FAuditNamesArray[20,95] := 'SB_Upload_To';
      //    FAuditNamesArray[20,96] := 'Coding_Report_Print_TI';
      //    FAuditNamesArray[20,97] := 'V31_GST_Format_Used';
      //    FAuditNamesArray[20,98] := 'Email_Scheduled_Reports';
      //    FAuditNamesArray[20,99] := 'OLD_BAS_Special_Accounts';
      //    FAuditNamesArray[20,100] := 'GST_Class_Codes';
      //    FAuditNamesArray[20,101] := 'Tax_Ledger_Code';
      //    FAuditNamesArray[20,102] := 'EOY_Locked_SB_Only';
      //    FAuditNamesArray[20,103] := 'BAS_Field_Number';
      //    FAuditNamesArray[20,104] := 'BAS_Field_Source';
      //    FAuditNamesArray[20,105] := 'BAS_Field_Account_Code';
      //    FAuditNamesArray[20,106] := 'BAS_Field_Balance_Type';
      //    FAuditNamesArray[20,107] := 'BAS_Field_Percent';
      //    FAuditNamesArray[20,108] := 'GST_Business_Percent';
      //    FAuditNamesArray[20,109] := 'BAS_Calculation_Method';
      //    FAuditNamesArray[20,110] := 'BAS_Dont_Print_Calc_Sheet';
      //    FAuditNamesArray[20,111] := 'BAS_PAYG_Withheld_Period';
      //    FAuditNamesArray[20,112] := 'Fax_Scheduled_Reports';
      //    FAuditNamesArray[20,113] := 'Graph_Headings';
      //    FAuditNamesArray[20,114] := 'Notes';
      //    FAuditNamesArray[20,115] := 'Cheques_Expire_When';
      //    FAuditNamesArray[20,116] := 'Show_Notes_On_Open';
      //    FAuditNamesArray[20,117] := 'ECoding_Entry_Selection';
      //    FAuditNamesArray[20,118] := 'ECoding_Dont_Send_Chart';
      //    FAuditNamesArray[20,119] := 'ECoding_Dont_Send_Payees';
      //    FAuditNamesArray[20,120] := 'ECoding_Dont_Show_Quantity';
      //    FAuditNamesArray[20,121] := 'ECoding_Last_File_No';
      //    FAuditNamesArray[20,122] := 'ECoding_Last_File_No_Imported';
      //    FAuditNamesArray[20,123] := 'ECoding_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,124] := 'Email_Report_Format';
      //    FAuditNamesArray[20,125] := 'BAS_PAYG_Instalment_Period';
      //    FAuditNamesArray[20,126] := 'BAS_Include_FBT_WET_LCT';
      //    FAuditNamesArray[20,127] := 'BAS_Last_GST_Option';
      //    FAuditNamesArray[20,128] := 'BAS_Last_PAYG_Instalment_Option';
      //    FAuditNamesArray[20,129] := 'ECoding_Default_Password';
      //    FAuditNamesArray[20,130] := 'ECoding_Import_Options';
      //    FAuditNamesArray[20,131] := 'ECoding_Last_Import_Dir';
      //    FAuditNamesArray[20,132] := 'ECoding_Last_Export_Dir';
      //    FAuditNamesArray[20,133] := 'Coding_Report_Show_OP';
      //    FAuditNamesArray[20,134] := 'FRS_Show_Quantity';
      //    FAuditNamesArray[20,135] := 'Cflw_Cash_On_Hand_Style';
      //    FAuditNamesArray[20,136] := 'CSV_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,137] := 'FRS_Show_YTD';
      //    FAuditNamesArray[20,138] := 'FRS_Show_Variance';
      //    FAuditNamesArray[20,139] := 'FRS_Compare_Type';
      //    FAuditNamesArray[20,140] := 'FRS_Reporting_Period_Type';
      //    FAuditNamesArray[20,141] := 'FRS_Report_Style';
      //    FAuditNamesArray[20,142] := 'Reporting_Year_Starts';
      //    FAuditNamesArray[20,143] := 'FRS_Report_Detail_Type';
      //    FAuditNamesArray[20,144] := 'FRS_Prompt_User_to_use_Budgeted_figures';
      //    FAuditNamesArray[20,145] := 'Balance_Sheet_Headings';
      //    FAuditNamesArray[20,146] := 'Last_Financial_Year_Start';
      //    FAuditNamesArray[20,147] := '520_Reference_Fix_Run';
      //    FAuditNamesArray[20,148] := 'Tax_Interface_Used';
      //    FAuditNamesArray[20,149] := 'Save_Tax_Files_To';
      //    FAuditNamesArray[20,150] := 'Journal_Processing_Period';
      //    FAuditNamesArray[20,151] := 'Last_Disk_Image_Version';
      //    FAuditNamesArray[20,152] := 'Practice_Web_Site';
      //    FAuditNamesArray[20,153] := 'Practice_Phone';
      //    FAuditNamesArray[20,154] := 'Practice_Logo';
      //    FAuditNamesArray[20,155] := 'Web_Site_Login_URL';
      //    FAuditNamesArray[20,156] := 'Staff_Member_Direct_Dial';
      //    FAuditNamesArray[20,157] := 'Contact_Details_To_Show';
      //    FAuditNamesArray[20,158] := 'ECoding_Dont_Allow_UPIs';
      //    FAuditNamesArray[20,159] := 'ECoding_Dont_Show_Account';
      //    FAuditNamesArray[20,160] := 'ECoding_Dont_Show_Payees';
      //    FAuditNamesArray[20,161] := 'ECoding_Dont_Show_GST';
      //    FAuditNamesArray[20,162] := 'ECoding_Dont_Show_TaxInvoice';
      //    FAuditNamesArray[20,163] := 'Scheduled_File_Attachments';
      //    FAuditNamesArray[20,164] := 'Scheduled_Coding_Report_Style';
      //    FAuditNamesArray[20,165] := 'Scheduled_Coding_Report_Sort_Order';
      //    FAuditNamesArray[20,166] := 'Scheduled_Coding_Report_Entry_Selection';
      //    FAuditNamesArray[20,167] := 'Scheduled_Coding_Report_Blank_Lines';
      //    FAuditNamesArray[20,168] := 'Scheduled_Coding_Report_Rule_Line';
      //    FAuditNamesArray[20,169] := 'Scheduled_Coding_Report_New_Page';
      //    FAuditNamesArray[20,170] := 'Scheduled_Coding_Report_Print_TI';
      //    FAuditNamesArray[20,171] := 'Scheduled_Coding_Report_Show_OP';
      //    FAuditNamesArray[20,172] := 'Scheduled_Client_Note_Message';
      //    FAuditNamesArray[20,173] := 'Custom_Contact_Name';
      //    FAuditNamesArray[20,174] := 'Custom_Contact_EMail_Address';
      //    FAuditNamesArray[20,175] := 'Custom_Contact_Phone';
      //    FAuditNamesArray[20,176] := 'Empty_Journals_Removed';
      //    FAuditNamesArray[20,177] := 'Highest_Manual_Account_No';
      //    FAuditNamesArray[20,178] := 'Contact_Details_Edit_Date';
      //    FAuditNamesArray[20,179] := 'Contact_Details_Edit_Time';
      //    FAuditNamesArray[20,180] := 'Copy_Narration_Dissection';
      //    FAuditNamesArray[20,181] := 'Client_CC_EMail_Address';
      //    FAuditNamesArray[20,182] := 'BAS_Report_Format';
      //    FAuditNamesArray[20,183] := 'WebX_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,184] := 'ECoding_WebSpace';
      //    FAuditNamesArray[20,185] := 'Last_ECoding_Account_UID';
      //    FAuditNamesArray[20,186] := 'Web_Export_Format';
            //Mobile_No
            188: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                               tClient_Rec(ARecord^).clMobile_No, Values);
      //    FAuditNamesArray[20,188] := 'Ledger_Report_Summary';
      //    FAuditNamesArray[20,189] := 'Ledger_Report_Show_Notes';
      //    FAuditNamesArray[20,190] := 'Ledger_Report_Show_Quantities';
      //    FAuditNamesArray[20,191] := 'Ledger_Report_Show_Non_Trf';
      //    FAuditNamesArray[20,192] := 'Ledger_Report_Show_Inactive_Codes';
      //    FAuditNamesArray[20,193] := 'Ledger_Report_Bank_Contra';
      //    FAuditNamesArray[20,194] := 'Ledger_Report_GST_Contra';
      //    FAuditNamesArray[20,195] := 'Ledger_Report_Show_Balances';
      //    FAuditNamesArray[20,196] := 'File_Read_Only';
      //    FAuditNamesArray[20,197] := 'CheckOut_Scheduled_Reports';
      //    FAuditNamesArray[20,198] := 'Exclude_From_Scheduled_Reports';
      //    FAuditNamesArray[20,199] := 'Ledger_Report_Show_Gross_And_GST';
      //    FAuditNamesArray[20,200] := 'Salutation';
      //    FAuditNamesArray[20,201] := 'External_ID';
      //    FAuditNamesArray[20,202] := 'System_LRN';
      //    FAuditNamesArray[20,203] := 'Business_Products_Scheduled_Reports';
      //    FAuditNamesArray[20,204] := 'Business_Products_Report_Format';
      //    FAuditNamesArray[20,205] := 'Coding_Report_Wrap_Narration';
      //    FAuditNamesArray[20,206] := 'Ledger_Report_Wrap_Narration';
      //    FAuditNamesArray[20,207] := 'Scheduled_Coding_Report_Wrap_Narration';
      //    FAuditNamesArray[20,208] := 'Force_Offsite_Check_Out';
            //Disable_Offsite_Check_Out
            210: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                               tClient_Rec(ARecord^).clDisable_Offsite_Check_Out, Values);
      //    FAuditNamesArray[20,210] := 'Alternate_Extract_ID';
      //    FAuditNamesArray[20,211] := 'Use_Alterate_ID_for_extract';
      //    FAuditNamesArray[20,212] := 'Last_Use_Date';
      //    FAuditNamesArray[20,213] := 'Use_Basic_Chart';
      //    FAuditNamesArray[20,214] := 'Group_Name';
            //Group_Name
            215: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                               tClient_Rec(ARecord^).clGroup_Name, Values);
            //Client_Type_Name
            216: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, Token),
                                               tClient_Rec(ARecord^).clClient_Type_Name, Values);
      //    FAuditNamesArray[20,216] := 'BAS_Include_Fuel';
      //    FAuditNamesArray[20,217] := 'Profit_Report_Show_Percentage';
      //    FAuditNamesArray[20,218] := 'ECoding_Send_Superfund';
      //    FAuditNamesArray[20,219] := 'Group_LRN';
      //    FAuditNamesArray[20,220] := 'Client_Type_LRN';
      //    FAuditNamesArray[20,221] := 'Spare_Byte_1';
      //    FAuditNamesArray[20,222] := 'Spare_Byte_2';
      //    FAuditNamesArray[20,223] := 'Practice_Code';
      //    FAuditNamesArray[20,224] := 'CashJ_Column_Order';
      //    FAuditNamesArray[20,225] := 'CashJ_Column_Width';
      //    FAuditNamesArray[20,226] := 'CashJ_Column_is_Hidden';
      //    FAuditNamesArray[20,227] := 'CashJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,228] := 'CashJ_Sort_Order';
      //    FAuditNamesArray[20,229] := 'AcrlJ_Column_Order';
      //    FAuditNamesArray[20,230] := 'AcrlJ_Column_Width';
      //    FAuditNamesArray[20,231] := 'AcrlJ_Column_is_Hidden';
      //    FAuditNamesArray[20,232] := 'AcrlJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,233] := 'AcrlJ_Sort_Order';
      //    FAuditNamesArray[20,234] := 'StockJ_Column_Order';
      //    FAuditNamesArray[20,235] := 'StockJ_Column_Width';
      //    FAuditNamesArray[20,236] := 'StockJ_Column_is_Hidden';
      //    FAuditNamesArray[20,237] := 'StockJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,238] := 'StockJ_Sort_Order';
      //    FAuditNamesArray[20,239] := 'YrEJ_Column_Order';
      //    FAuditNamesArray[20,240] := 'YrEJ_Column_Width';
      //    FAuditNamesArray[20,241] := 'YrEJ_Column_is_Hidden';
      //    FAuditNamesArray[20,242] := 'YrEJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,243] := 'YrEJ_Sort_Order';
      //    FAuditNamesArray[20,244] := 'gstJ_Column_Order';
      //    FAuditNamesArray[20,245] := 'gstJ_Column_Width';
      //    FAuditNamesArray[20,246] := 'gstJ_Column_is_Hidden';
      //    FAuditNamesArray[20,247] := 'gstJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,248] := 'gstJ_Sort_Order';
      //    FAuditNamesArray[20,249] := 'Favourite_Report_XML';
      //    FAuditNamesArray[20,250] := 'All_EditMode_CES';
      //    FAuditNamesArray[20,251] := 'All_EditMode_DIS';
      //    FAuditNamesArray[20,252] := 'TFN';
      //    FAuditNamesArray[20,253] := 'All_EditMode_Journals';
      //    FAuditNamesArray[20,254] := 'Budget_Column_Width';
          end;
          inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_ClientExtra :
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
//    FAuditNamesArray[40,41] := 'TAX_Applies_From';
//    FAuditNamesArray[40,42] := 'TAX_Rates';
            //List_Entries_Sort_Order
            44: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, Token),
                                             tClientExtra_Rec(ARecord^).ceList_Entries_Sort_Order, Values);
//    FAuditNamesArray[40,44] := 'List_Entries_Include';
//    FAuditNamesArray[40,45] := 'List_Entries_Two_Column';
//    FAuditNamesArray[40,46] := 'List_Entries_Show_Balance';
//    FAuditNamesArray[40,47] := 'List_Entries_Show_Notes';
//    FAuditNamesArray[40,48] := 'List_Entries_Wrap_Narration';
//    FAuditNamesArray[40,49] := 'List_Entries_Show_Other_Party';
//    FAuditNamesArray[40,50] := 'Book_Gen_Finance_Reports';
            //Book_Gen_Finance_Reports
            51: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, Token),
                                             tClientExtra_Rec(ARecord^).ceBook_Gen_Finance_Reports, Values);
//    FAuditNamesArray[40,51] := 'FRS_Print_NP_Chart_Code_Titles';
//    FAuditNamesArray[40,52] := 'FRS_NP_Chart_Code_Detail_Type';
            //Allow_Client_Unlock_Entries
            54: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, Token),
                                             tClientExtra_Rec(ARecord^).ceAllow_Client_Unlock_Entries, Values);
            //Allow_Client_Edit_Chart
            55: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, Token),
                                             tClientExtra_Rec(ARecord^).ceAllow_Client_Edit_Chart, Values);
//    FAuditNamesArray[40,55] := 'ECoding_Dont_Send_Jobs';
//    FAuditNamesArray[40,56] := 'Custom_Coding_Report_XML';
//    FAuditNamesArray[40,57] := 'Custom_Coding_Report';
//    FAuditNamesArray[40,58] := 'Coding_Report_Column_Line';
//    FAuditNamesArray[40,59] := 'Scheduled_Custom_CR_XML';
//    FAuditNamesArray[40,60] := 'Budget_Include_Quantities';
//    FAuditNamesArray[40,61] := 'Scheduled_CR_Column_Line';
//    FAuditNamesArray[40,62] := 'Custom_Ledger_Report';
//    FAuditNamesArray[40,63] := 'Custom_Ledger_Report_XML';
//    FAuditNamesArray[40,64] := 'Local_Currency_Code';
            //Block_Client_Edit_Mems
            66: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, Token),
                                              tClientExtra_Rec(ARecord^).ceBlock_Client_Edit_Mems, Values);
//    FAuditNamesArray[40,66] := 'Send_Custom_Documents';
//    FAuditNamesArray[40,67] := 'Send_Custom_Documents_List';
//    FAuditNamesArray[40,68] := 'List_Payees_Detailed';
//    FAuditNamesArray[40,69] := 'List_Payees_SortBy';
//    FAuditNamesArray[40,70] := 'List_Payees_Rule_Line';
//    FAuditNamesArray[40,71] := 'Custom_SFLedger_Titles';
//    FAuditNamesArray[40,72] := 'SUI_Period_Start';
//    FAuditNamesArray[40,73] := 'SUI_Period_End';
//    FAuditNamesArray[40,74] := 'Audit_Record_ID';
//    FAuditNamesArray[40,75] := 'SUI_Step_Done';
//    FAuditNamesArray[40,76] := 'Send_Job_List';
          end;
          inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

procedure AddBankAccountAuditValues(const AAuditRecord: TAudit_Trail_Rec;
  AAuditMgr: TClientAuditManager; var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Bank_Account:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Bank Account Number
            152: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Bank_Account, Token),
                                        tBank_Account_Rec(ARecord^).baBank_Account_Number, Values);
            //Bank Account Name
            153: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Bank_Account, Token),
                                        tBank_Account_Rec(ARecord^).baBank_Account_Name, Values);
//    FAuditNamesArray[150,154] := 'Bank_Account_Password';
//    FAuditNamesArray[150,155] := 'Contra_Account_Code';
//    FAuditNamesArray[150,156] := 'Current_Balance';
//    FAuditNamesArray[150,157] := 'Apply_Master_Memorised_Entries';
//    FAuditNamesArray[150,158] := 'Account_Type';
//    FAuditNamesArray[150,159] := 'Column_Order';
//    FAuditNamesArray[150,160] := 'Column_Width';
//    FAuditNamesArray[150,161] := 'Preferred_View';
//    FAuditNamesArray[150,162] := 'Highest_BankLink_ID';
//    FAuditNamesArray[150,163] := 'Highest_LRN';
//    FAuditNamesArray[150,164] := 'Column_is_Hidden';
//    FAuditNamesArray[150,165] := 'Account_Expiry_Date';
//    FAuditNamesArray[150,166] := 'Highest_Matched_Item_ID';
//    FAuditNamesArray[150,167] := 'Notes_Always_Visible';
//    FAuditNamesArray[150,168] := 'Notes_Height';
//    FAuditNamesArray[150,169] := 'Last_ECoding_Transaction_UID';
//    FAuditNamesArray[150,170] := 'Column_Is_Not_Editable';
//    FAuditNamesArray[150,171] := 'Extend_Expiry_Date';
//    FAuditNamesArray[150,172] := 'Is_A_Manual_Account';
//    FAuditNamesArray[150,173] := 'Analysis_Coding_Level';
//    FAuditNamesArray[150,174] := 'ECoding_Account_UID';
//    FAuditNamesArray[150,175] := 'Coding_Sort_Order';
//    FAuditNamesArray[150,176] := 'Manual_Account_Type';
//    FAuditNamesArray[150,177] := 'Manual_Account_Institution';
//    FAuditNamesArray[150,178] := 'Manual_Account_Sent_To_Admin';
//    FAuditNamesArray[150,179] := 'Spare_String';
//    FAuditNamesArray[150,180] := 'Is_A_Provisional_Account';
//    FAuditNamesArray[150,181] := 'Spare_Number';
//    FAuditNamesArray[150,182] := 'Spare_Byte';
//    FAuditNamesArray[150,183] := 'HDE_Column_Order';
//    FAuditNamesArray[150,184] := 'HDE_Column_Width';
//    FAuditNamesArray[150,185] := 'HDE_Column_is_Hidden';
//    FAuditNamesArray[150,186] := 'HDE_Column_is_Not_Editable';
//    FAuditNamesArray[150,187] := 'HDE_Sort_Order';
//    FAuditNamesArray[150,188] := 'MDE_Column_Order';
//    FAuditNamesArray[150,189] := 'MDE_Column_Width';
//    FAuditNamesArray[150,190] := 'MDE_Column_is_Hidden';
//    FAuditNamesArray[150,191] := 'MDE_Column_is_Not_Editable';
//    FAuditNamesArray[150,192] := 'MDE_Sort_Order';
//    FAuditNamesArray[150,193] := 'DIS_Column_Order';
//    FAuditNamesArray[150,194] := 'DIS_Column_Width';
//    FAuditNamesArray[150,195] := 'DIS_Column_is_Hidden';
//    FAuditNamesArray[150,196] := 'DIS_Column_is_Not_Editable';
//    FAuditNamesArray[150,197] := 'DIS_Sort_Order';
//    FAuditNamesArray[150,198] := 'Desktop_Super_Ledger_ID';
//    FAuditNamesArray[150,199] := 'Currency_Code';
//    FAuditNamesArray[150,200] := 'Default_Forex_Source';
//    FAuditNamesArray[150,201] := 'Default_Forex_Description';
//    FAuditNamesArray[150,202] := 'SuperFund_Ledger_Code';
//    FAuditNamesArray[150,203] := 'Audit_Record_ID';
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

procedure AddTransactionAuditValues(const AAuditRecord: TAudit_Trail_Rec;
  AAuditMgr: TClientAuditManager; ClientFields: TClient_Rec; var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Transaction:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Sequence_No
            162: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txSequence_No, Values);
            //LRN_NOW_UNUSED
            163: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txLRN_NOW_UNUSED, Values);
            //Type
            164: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         GetFormattedEntryType(ClientFields,
                                                               tTransaction_Rec(ARecord^).txType,
                                                               tTransaction_Rec(ARecord^).txHas_Been_Edited),
                                         Values);
            //Source
            165: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         orNames[tTransaction_Rec(ARecord^).txSource], Values);
            //Source
            166: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         BKDate2Str(tTransaction_Rec(ARecord^).txDate_Presented), Values);
            //Date_Effective
            167: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         BKDate2Str(tTransaction_Rec(ARecord^).txDate_Effective), Values);
            //Date_Transferred
            168: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         BKDate2Str(tTransaction_Rec(ARecord^).txDate_Transferred), Values);
            //Amount
            169: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         Money2Str(tTransaction_Rec(ARecord^).txAmount), Values);
            //GST_Class
            170: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txGST_Class, Values);
            //GST_Amount
            171: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         Money2Str(tTransaction_Rec(ARecord^).txGST_Amount), Values);
            //Has_Been_Edited
            172: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txHas_Been_Edited, Values);
            //Quantity
            173: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         Quantity2Str(tTransaction_Rec(ARecord^).txQuantity), Values);
            //Cheque_Number
            174: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txCheque_Number, Values);
            //Reference
            175: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txReference, Values);
            //Particulars
            176: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txParticulars, Values);
            //Analysis
            177: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txAnalysis, Values);
            //OrigBB
            178: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOrigBB, Values);
            //Other_Party
            179: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOther_Party, Values);
            //Old_Narration
            180: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOld_Narration, Values);
            //Account
            181: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txAccount, Values);
            //Coded_By
            182: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txCoded_By, Values);
            //Payee_Number
            183: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txPayee_Number, Values);
            //Locked
            184: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txLocked, Values);
            //BankLink_ID
            185: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txBankLink_ID, Values);
            //GST_Has_Been_Edited
            186: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txGST_Has_Been_Edited, Values);
            //Matched_Item_ID
            187: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txMatched_Item_ID, Values);
            //UPI_State
            188: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         upNames[tTransaction_Rec(ARecord^).txUPI_State], Values);
            //Original_Reference
            189: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOriginal_Reference, Values);
            //Original_Source
            190: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         orNames[tTransaction_Rec(ARecord^).txOriginal_Source], Values);
            //Original_Type
            191: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         GetFormattedEntryType(ClientFields,
                                                               tTransaction_Rec(ARecord^).txOriginal_Type,
                                                               tTransaction_Rec(ARecord^).txHas_Been_Edited),
                                         Values);                                                               
            //Original_Cheque_Number
            192: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOriginal_Cheque_Number, Values);
            //Original_Amount
            193: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         Money2Str(tTransaction_Rec(ARecord^).txOriginal_Amount), Values);
            //Notes
            194: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txNotes, Values);
            //ECoding_Import_Notes
            195: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txECoding_Import_Notes, Values);
            //ECoding_Transaction_UID
            196: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txECoding_Transaction_UID, Values);
            //GL_Narration
            197: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txGL_Narration, Values);
            //Statement_Details
            198: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txStatement_Details, Values);
            //Tax_Invoice_Available
            199: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txTax_Invoice_Available, Values);
            //External_GUID
            213: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txExternal_GUID, Values);
            //Document_Title
            214: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txDocument_Title, Values);
            //Document_Status_Update_Required
            215: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txDocument_Status_Update_Required, Values);
            //BankLink_UID
            216: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txBankLink_UID, Values);
            //Notes_Read
            217: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txNotes_Read, Values);
            //Import_Notes_Read
            218: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txImport_Notes_Read, Values);
            //Job_Code
            240: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txJob_Code, Values);
            //Forex_Conversion_Rate
            241: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txForex_Conversion_Rate, Values);
            //Original_Forex_Conversion_Rate
            243: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Transaction, Token),
                                         tTransaction_Rec(ARecord^).txOriginal_Forex_Conversion_Rate, Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

procedure AddPayeeAuditValues(const AAuditRecord: TAudit_Trail_Rec;
   AAuditMgr: TClientAuditManager; var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Payee_Detail:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Number
            92: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, Token),
                                        tPayee_Detail_Rec(ARecord^).pdNumber, Values);
            //Name
            93: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Detail, Token),
                                        tPayee_Detail_Rec(ARecord^).pdName, Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Payee_Line:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Account
            97: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        tPayee_Line_Rec(ARecord^).plAccount, Values);
            //Percentage
            98: case tPayee_Line_Rec(ARecord^).plLine_Type of
                  pltPercentage : AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                                          Percent2Str(tPayee_Line_Rec(ARecord^).plPercentage), Values);
                  pltDollarAmt  : AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                                          Money2Str(tPayee_Line_Rec(ARecord^).plPercentage), Values);
                end;
            //GST Class
            99: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        tPayee_Line_Rec(ARecord^).plGST_Class, Values);
            //GST has been edited
            100: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         tPayee_Line_Rec(ARecord^).plGST_Has_Been_Edited, Values);

            //GL_Narration
            101: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         tPayee_Line_Rec(ARecord^).plGL_Narration, Values);
            //Line type
            102: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                        pltNames[tPayee_Line_Rec(ARecord^).plLine_Type], Values);
            //GST_Amount
            103: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         Money2Str(tPayee_Line_Rec(ARecord^).plGST_Amount), Values);
            //Quantity
            115: AAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Payee_Line, Token),
                                         Quantity2Str(tPayee_Line_Rec(ARecord^).plQuantity), Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;


end.
