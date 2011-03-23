unit SYAUDIT;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

interface

type
TAuditTableArray = array[byte] of string;
TAuditNamesArray = array[byte, byte] of string;

TSYAuditNames = class(TObject)
private
  FAuditNamesArray: TAuditNamesArray;
  FAuditTableArray: TAuditTableArray;
  procedure FillArray;
public
  constructor Create;
  function GetAuditTableName(ATable: byte): string;
  function GetAuditFieldName(ATable, AField: byte): string;
end;

function SYAuditNames: TSYAuditNames;

implementation

var
  _AuditNames: TSYAuditNames;

function SYAuditNames: TSYAuditNames;
begin
  if not Assigned(_AuditNames) then
    _AuditNames := TSYAuditNames.Create;
  Result := _AuditNames;
end;

{ TAuditNames }

constructor TSYAuditNames.Create;
begin
  FillArray;
end;

function TSYAuditNames.GetAuditFieldName(ATable, AField: byte): string;
begin
  Result := FAuditNamesArray[ATable, AField];
end;

function TSYAuditNames.GetAuditTableName(ATable: byte): string;
begin
  Result := FAuditTableArray[ATable];
end;

procedure TSYAuditNames.FillArray;
var
  i, j: integer;
begin
  //Clear arrays
  for i := 0 to High(FAuditNamesArray) do begin
    FAuditTableArray[i] := '';
    for j := 0 to High(FAuditNamesArray[i]) do
      FAuditNamesArray[i, j] := '';
  end;
   FAuditTableArray[10] := 'Practice_Details';
    FAuditNamesArray[10,11] := 'Practice_Name_for_Reports';
    FAuditNamesArray[10,12] := 'Practice_EMail_Address';
    FAuditNamesArray[10,13] := 'Accounting_System_Used';
    FAuditNamesArray[10,14] := 'Country';
    FAuditNamesArray[10,15] := 'Load_Client_Files_From';
    FAuditNamesArray[10,16] := 'Save_Client_Files_To';
    FAuditNamesArray[10,17] := 'Short_Name';
    FAuditNamesArray[10,18] := 'Long_Name';
    FAuditNamesArray[10,19] := 'GST_Class_Names';
    FAuditNamesArray[10,20] := 'GST_Class_Types';
    FAuditNamesArray[10,21] := 'GST_Account_Codes';
    FAuditNamesArray[10,22] := 'GST_Rates';
    FAuditNamesArray[10,23] := 'GST_Applies_From';
    FAuditNamesArray[10,24] := 'Date_of_Last_Entry_Received';
    FAuditNamesArray[10,25] := 'Print_Reports_Up_To';
    FAuditNamesArray[10,26] := 'Spare_Boolean_3';
    FAuditNamesArray[10,27] := 'Print_Staff_Member_Header_Page';
    FAuditNamesArray[10,28] := 'Print_Client_Header_Page';
    FAuditNamesArray[10,29] := 'PIN_Number';
    FAuditNamesArray[10,30] := 'BankLink_Code';
    FAuditNamesArray[10,31] := 'Disk_Sequence_No';
    FAuditNamesArray[10,32] := 'Magic_Number';
    FAuditNamesArray[10,33] := 'Coding_Report_Style';
    FAuditNamesArray[10,34] := 'Coding_Report_Sort_Order';
    FAuditNamesArray[10,35] := 'Coding_Report_Entry_Selection';
    FAuditNamesArray[10,36] := 'Coding_Report_Blank_Lines';
    FAuditNamesArray[10,37] := 'Coding_Report_Rule_Line';
    FAuditNamesArray[10,38] := 'Bank_Account_LRN_Counter';
    FAuditNamesArray[10,39] := 'User_LRN_Counter';
    FAuditNamesArray[10,40] := 'Transaction_LRN_Counter';
    FAuditNamesArray[10,41] := 'Client_File_LRN_Counter';
    FAuditNamesArray[10,42] := 'BankLink_Connect_Password';
    FAuditNamesArray[10,43] := 'Old_GST_Class_Codes';
    FAuditNamesArray[10,44] := 'Account_Code_Mask';
    FAuditNamesArray[10,45] := 'File_Version';
    FAuditNamesArray[10,46] := 'Sched_Rep_Email_Subject';
    FAuditNamesArray[10,47] := 'Old_Sched_Rep_Email_Line1';
    FAuditNamesArray[10,48] := 'Old_Sched_Rep_Email_Line2';
    FAuditNamesArray[10,49] := 'OLD_BAS_Special_Accounts';
    FAuditNamesArray[10,50] := 'GST_Class_Codes';
    FAuditNamesArray[10,51] := 'BAS_Field_Number';
    FAuditNamesArray[10,52] := 'BAS_Field_Source';
    FAuditNamesArray[10,53] := 'BAS_Field_Account_Code';
    FAuditNamesArray[10,54] := 'BAS_Field_Balance';
    FAuditNamesArray[10,55] := 'Sched_Rep_Include_Email';
    FAuditNamesArray[10,56] := 'Sched_Rep_Email_Only';
    FAuditNamesArray[10,57] := 'Sched_Rep_Include_Printer';
    FAuditNamesArray[10,58] := 'Sched_Rep_Include_Fax';
    FAuditNamesArray[10,59] := 'Sched_Rep_Send_Fax_Off_Peak';
    FAuditNamesArray[10,60] := 'Enhanced_Software_Options';
    FAuditNamesArray[10,61] := 'Sched_Rep_Include_ECoding';
    FAuditNamesArray[10,62] := 'Sched_Rep_Cover_Page_Name';
    FAuditNamesArray[10,63] := 'Sched_Rep_Cover_Page_Subject';
    FAuditNamesArray[10,64] := 'Sched_Rep_Cover_Page_Message';
    FAuditNamesArray[10,65] := 'Sched_Rep_Email_Message';
    FAuditNamesArray[10,66] := 'Download_Report_Options';
    FAuditNamesArray[10,67] := 'Download_Report_Hide_Deleted';
    FAuditNamesArray[10,68] := 'Bulk_Export_Enabled';
    FAuditNamesArray[10,69] := 'Spare_Byte_0';
    FAuditNamesArray[10,70] := 'Bulk_Export_Code';
    FAuditNamesArray[10,71] := 'Sched_Rep_Include_CSV_Export';
    FAuditNamesArray[10,72] := 'Tax_Interface_Used';
    FAuditNamesArray[10,73] := 'Save_Tax_Files_To';
    FAuditNamesArray[10,74] := 'Last_Disk_Image_Version';
    FAuditNamesArray[10,75] := 'Practice_Web_Site';
    FAuditNamesArray[10,76] := 'Practice_Phone';
    FAuditNamesArray[10,77] := 'Practice_Logo_Filename';
    FAuditNamesArray[10,78] := 'Sched_Rep_Print_Custom_Doc_GUID';
    FAuditNamesArray[10,79] := 'Sched_Rep_Print_Custom_Doc';
    FAuditNamesArray[10,80] := 'Last_ChargeFile_Date';
    FAuditNamesArray[10,81] := 'Audit_Record_ID';
    FAuditNamesArray[10,82] := 'Sched_Rep_Fax_Custom_Doc_GUID';
    FAuditNamesArray[10,83] := 'Sched_Rep_Fax_Custom_Doc';
    FAuditNamesArray[10,84] := 'Spare_Text_3';
    FAuditNamesArray[10,85] := 'Sched_Rep_Email_Custom_Doc_GUID';
    FAuditNamesArray[10,86] := 'Sched_Rep_Email_Custom_Doc';
    FAuditNamesArray[10,87] := 'Spare_Text_5';
    FAuditNamesArray[10,88] := 'Sched_Rep_Books_Custom_Doc_GUID';
    FAuditNamesArray[10,89] := 'Sched_Rep_Books_Custom_Doc';
    FAuditNamesArray[10,90] := 'Spare_Integer_3';
    FAuditNamesArray[10,91] := 'Spare_Integer_4';
    FAuditNamesArray[10,92] := 'Sched_Rep_Notes_Custom_Doc_GUID';
    FAuditNamesArray[10,93] := 'Sched_Rep_Notes_Custom_Doc';
    FAuditNamesArray[10,94] := 'Spare_Text_8';
    FAuditNamesArray[10,95] := 'Sched_Rep_WebNotes_Custom_Doc_GUID';
    FAuditNamesArray[10,96] := 'Sched_Rep_WebNotes_Custom_Doc';
    FAuditNamesArray[10,97] := 'Spare_Integer_5';
    FAuditNamesArray[10,98] := 'Spare_Integer_6';
    FAuditNamesArray[10,99] := 'Spare_Text_10';
    FAuditNamesArray[10,100] := 'Spare_Byte_7';
    FAuditNamesArray[10,101] := 'Spare_Text_11';
    FAuditNamesArray[10,102] := 'Spare_Text_12';
    FAuditNamesArray[10,103] := 'Spare_Byte_8';
    FAuditNamesArray[10,104] := 'Spare_Text_13';
    FAuditNamesArray[10,105] := 'Spare_Text_14';
    FAuditNamesArray[10,106] := 'Spare_Byte_9';
    FAuditNamesArray[10,107] := 'Spare_Integer_7';
    FAuditNamesArray[10,108] := 'Spare_Integer_8';
    FAuditNamesArray[10,109] := 'Sched_Rep_WebNotes_Subject';
    FAuditNamesArray[10,110] := 'Spare_Byte_10';
    FAuditNamesArray[10,111] := 'Sched_Rep_webNotes_Message';
    FAuditNamesArray[10,112] := 'Spare_Byte_11';
    FAuditNamesArray[10,113] := 'Sched_Rep_Header_Message';
    FAuditNamesArray[10,114] := 'Sched_Rep_BNotes_Subject';
    FAuditNamesArray[10,115] := 'Sched_Rep_BNotes_Message';
    FAuditNamesArray[10,116] := 'Spare_Boolean_4';
    FAuditNamesArray[10,117] := 'Task_Tracking_Prompt_Type';
    FAuditNamesArray[10,118] := 'Spare_Bool_1';
    FAuditNamesArray[10,119] := 'Spare_Bool_2';
    FAuditNamesArray[10,120] := 'Spare_Integer_9';
    FAuditNamesArray[10,121] := 'Sched_Rep_Fax_Transport';
    FAuditNamesArray[10,122] := 'Sched_Rep_Include_WebX';
    FAuditNamesArray[10,123] := 'Web_Export_Format';
    FAuditNamesArray[10,124] := 'Force_Login';
    FAuditNamesArray[10,125] := 'Login_Bitmap_Filename';
    FAuditNamesArray[10,126] := 'Auto_Print_Sched_Rep_Summary';
    FAuditNamesArray[10,127] := 'Ignore_Quantity_In_Download';
    FAuditNamesArray[10,128] := 'Spare_Boolean_1';
    FAuditNamesArray[10,129] := 'spare_Boolean_2';
    FAuditNamesArray[10,130] := 'Copy_Dissection_Narration';
    FAuditNamesArray[10,131] := 'Round_Cashflow_Reports';
    FAuditNamesArray[10,132] := 'Use_Xlon_Chart_Order';
    FAuditNamesArray[10,133] := 'Extract_Multiple_Accounts_PA';
    FAuditNamesArray[10,134] := 'Extract_Journal_Accounts_PA';
    FAuditNamesArray[10,135] := 'Extract_Quantity';
    FAuditNamesArray[10,136] := 'Reports_New_Page';
    FAuditNamesArray[10,137] := 'Print_Merge_Report_Summary';
    FAuditNamesArray[10,138] := 'Email_Merge_Report_Summary';
    FAuditNamesArray[10,139] := 'Maximum_Narration_Extract';
    FAuditNamesArray[10,140] := 'Sched_Rep_Include_CheckOut';
    FAuditNamesArray[10,141] := 'Sched_Rep_CheckOut_Subject';
    FAuditNamesArray[10,142] := 'Sched_Rep_CheckOut_Message';
    FAuditNamesArray[10,143] := 'Sched_Rep_Include_Business_Products';
    FAuditNamesArray[10,144] := 'Sched_Rep_Business_Products_Subject';
    FAuditNamesArray[10,145] := 'Sched_Rep_Business_Products_Message';
    FAuditNamesArray[10,146] := 'Replace_Narration_With_Payee';
    FAuditNamesArray[10,147] := 'Last_Export_Charges_Saved_To';
    FAuditNamesArray[10,148] := 'Manual_Account_XML';
    FAuditNamesArray[10,149] := 'Updates_Pending';
    FAuditNamesArray[10,150] := 'Update_Server_For_Offsites';
    FAuditNamesArray[10,151] := 'Collect_Usage_Data';
    FAuditNamesArray[10,152] := 'Fixed_Charge_Increase';
    FAuditNamesArray[10,153] := 'Percentage_Charge_Increase';
    FAuditNamesArray[10,154] := 'Fixed_Dollar_Amount';
    FAuditNamesArray[10,155] := 'Distributed_Dollar_Amount';
    FAuditNamesArray[10,156] := 'Percentage_Increase_Amount';
    FAuditNamesArray[10,157] := 'Extract_Quantity_Decimal_Places';
    FAuditNamesArray[10,158] := 'Export_Charges_Remarks';
    FAuditNamesArray[10,159] := 'System_Report_Password';
    FAuditNamesArray[10,160] := 'Print_Reports_From';
    FAuditNamesArray[10,161] := 'Highest_Date_Ever_Downloaded';
    FAuditNamesArray[10,162] := 'Auto_Retrieve_New_Transactions';
    FAuditNamesArray[10,163] := 'Coding_Font';
    FAuditNamesArray[10,164] := 'Sort_Reports_Option';
    FAuditNamesArray[10,165] := 'Spare_Byte_12';
    FAuditNamesArray[10,166] := 'Group_LRN_Counter';
    FAuditNamesArray[10,167] := 'Client_Type_LRN_Counter';
    FAuditNamesArray[10,168] := 'TAX_Applies_From';
    FAuditNamesArray[10,169] := 'TAX_Rates';
    FAuditNamesArray[10,170] := 'Superfund_System';
    FAuditNamesArray[10,171] := 'Superfund_Code_Mask';
    FAuditNamesArray[10,172] := 'Load_Client_Super_Files_From';
    FAuditNamesArray[10,173] := 'Save_Client_Super_Files_To';
    FAuditNamesArray[10,174] := 'Sort_Reports_By';
    FAuditNamesArray[10,175] := 'Set_Fixed_Dollar_Amount';
    FAuditNamesArray[10,176] := 'Print_Group_Header_Page';
    FAuditNamesArray[10,177] := 'Print_Client_Type_Header_Page';
    FAuditNamesArray[10,178] := 'Practice_Management_System';
    FAuditNamesArray[10,179] := 'Automatic_Task_Creation_Flags';
    FAuditNamesArray[10,180] := 'Automatic_Task_Reminder_Delay';
    FAuditNamesArray[10,181] := 'Automatic_Task_Closing_Flags';

   FAuditTableArray[40] := 'System_Disk_Log';
    FAuditNamesArray[40,41] := 'Disk_ID';
    FAuditNamesArray[40,42] := 'Date_Downloaded';
    FAuditNamesArray[40,43] := 'No_of_Accounts';
    FAuditNamesArray[40,44] := 'No_of_Entries';
    FAuditNamesArray[40,45] := 'Was_In_Last_Download';
    FAuditNamesArray[40,46] := 'Audit_Record_ID';

   FAuditTableArray[60] := 'User';
    FAuditNamesArray[60,61] := 'User Code'; //Code
    FAuditNamesArray[60,62] := 'User Name'; //Name
    FAuditNamesArray[60,63] := 'Password';
    FAuditNamesArray[60,64] := 'Email'; //EMail_Address
    FAuditNamesArray[60,65] := 'System_Access';
    FAuditNamesArray[60,66] := 'Dialog_Colour';
    FAuditNamesArray[60,67] := 'Logged_In';
    FAuditNamesArray[60,68] := 'Reverse_Mouse_Buttons';
    FAuditNamesArray[60,69] := 'MASTER_Access';
    FAuditNamesArray[60,70] := 'LRN';
    FAuditNamesArray[60,71] := 'Spare_String';
    FAuditNamesArray[60,72] := 'Workstation_Logged_In_At';
    FAuditNamesArray[60,73] := 'Is_Remote_User';
    FAuditNamesArray[60,74] := 'Direct_Dial';
    FAuditNamesArray[60,75] := 'Show_CM_on_open';
    FAuditNamesArray[60,76] := 'Show_Printer_Choice';
    FAuditNamesArray[60,77] := 'EULA_Version';
    FAuditNamesArray[60,78] := 'Spare_Boolean';
    FAuditNamesArray[60,79] := 'Login_Count';
    FAuditNamesArray[60,80] := 'Reset_Count';
    FAuditNamesArray[60,81] := 'Suppress_HF';
    FAuditNamesArray[60,82] := 'Show_Practice_Logo';
    FAuditNamesArray[60,83] := 'Audit_Record_ID';

   FAuditTableArray[50] := 'System_Bank_Account';
    FAuditNamesArray[50,51] := 'Account_Number';
    FAuditNamesArray[50,52] := 'Account_Name';
    FAuditNamesArray[50,53] := 'Account_Password';
    FAuditNamesArray[50,54] := 'LRN';
    FAuditNamesArray[50,55] := 'Client';
    FAuditNamesArray[50,56] := 'Current_Balance';
    FAuditNamesArray[50,57] := 'Last_Transaction_LRN';
    FAuditNamesArray[50,58] := 'New_This_Month';
    FAuditNamesArray[50,59] := 'No_of_Entries_This_Month';
    FAuditNamesArray[50,60] := 'From_Date_This_Month';
    FAuditNamesArray[50,61] := 'To_Date_This_Month';
    FAuditNamesArray[50,62] := 'Cost_Code';
    FAuditNamesArray[50,63] := 'Charges_This_Month';
    FAuditNamesArray[50,64] := 'Opening_Balance_from_Disk';
    FAuditNamesArray[50,65] := 'Closing_Balance_from_Disk';
    FAuditNamesArray[50,66] := 'Attach_Required';
    FAuditNamesArray[50,67] := 'Was_On_Latest_Disk';
    FAuditNamesArray[50,68] := 'Last_Entry_Date';
    FAuditNamesArray[50,69] := 'Date_Of_Last_Entry_Printed';
    FAuditNamesArray[50,70] := 'Mark_As_Deleted';
    FAuditNamesArray[50,71] := 'File_Code';
    FAuditNamesArray[50,72] := 'Client_ID';
    FAuditNamesArray[50,73] := 'Matter_ID';
    FAuditNamesArray[50,74] := 'Assignment_ID';
    FAuditNamesArray[50,75] := 'Disbursement_ID';
    FAuditNamesArray[50,76] := 'Account_Type';
    FAuditNamesArray[50,77] := 'Job_Code';
    FAuditNamesArray[50,78] := 'Activity_Code';
    FAuditNamesArray[50,79] := 'Unused';
    FAuditNamesArray[50,80] := 'First_Available_Date';
    FAuditNamesArray[50,81] := 'No_Charge_Account';
    FAuditNamesArray[50,82] := 'Currency_Code';
    FAuditNamesArray[50,83] := 'Institution';
    FAuditNamesArray[50,84] := 'InActive';
    FAuditNamesArray[50,85] := 'BankLink_Code';
    FAuditNamesArray[50,86] := 'Frequency';
    FAuditNamesArray[50,87] := 'Frequency_Change_Pending';
    FAuditNamesArray[50,88] := 'Audit_Record_ID';

   FAuditTableArray[80] := 'Client_File';
    FAuditNamesArray[80,81] := 'File_Code';
    FAuditNamesArray[80,82] := 'File_Name';
    FAuditNamesArray[80,83] := 'File_Type';
    FAuditNamesArray[80,84] := 'File_Status';
    FAuditNamesArray[80,85] := 'File_Password';
    FAuditNamesArray[80,86] := 'Date_Last_Accessed';
    FAuditNamesArray[80,87] := 'File_Save_Count';
    FAuditNamesArray[80,88] := 'User_Responsible';
    FAuditNamesArray[80,89] := 'Current_User';
    FAuditNamesArray[80,90] := 'LRN';
    FAuditNamesArray[80,91] := 'Report_Start_Date';
    FAuditNamesArray[80,92] := 'Reporting_Period';
    FAuditNamesArray[80,93] := 'Foreign_File';
    FAuditNamesArray[80,94] := 'Unused_Date_Field';
    FAuditNamesArray[80,95] := 'Reports_Due';
    FAuditNamesArray[80,96] := 'Contact_Details_To_Show';
    FAuditNamesArray[80,97] := 'Financial_Year_Starts';
    FAuditNamesArray[80,98] := 'Schd_Rep_Method';
    FAuditNamesArray[80,99] := 'SpareBoolean';
    FAuditNamesArray[80,100] := 'Pending_ToDo_Count';
    FAuditNamesArray[80,101] := 'Next_ToDo_Desc';
    FAuditNamesArray[80,102] := 'Next_ToDo_Rem_Date';
    FAuditNamesArray[80,103] := 'Has_Client_Notes';
    FAuditNamesArray[80,104] := 'Overdue_ToDo_Count';
    FAuditNamesArray[80,105] := 'Sched_Rep_Reports_To_Send';
    FAuditNamesArray[80,106] := 'Contact_Details_Edit_Date';
    FAuditNamesArray[80,107] := 'Contact_Details_Edit_Time';
    FAuditNamesArray[80,108] := 'Bank_Accounts';
    FAuditNamesArray[80,109] := 'Date_Of_Last_Entry_Printed';
    FAuditNamesArray[80,110] := 'Last_Print_Reports_Up_To';
    FAuditNamesArray[80,111] := 'Client_Type';
    FAuditNamesArray[80,112] := 'Coded';
    FAuditNamesArray[80,113] := 'Finalized';
    FAuditNamesArray[80,114] := 'Transferred';
    FAuditNamesArray[80,115] := 'Last_Processing_Status_Date';
    FAuditNamesArray[80,116] := 'Schd_Rep_Method_Filter';
    FAuditNamesArray[80,117] := 'Archived';
    FAuditNamesArray[80,118] := 'Payee_Count';
    FAuditNamesArray[80,119] := 'Bank_Account_Count';
    FAuditNamesArray[80,120] := 'Manual_Account_Count';
    FAuditNamesArray[80,121] := 'Mem_Count';
    FAuditNamesArray[80,122] := 'Accounting_System';
    FAuditNamesArray[80,123] := 'Downloaded';
    FAuditNamesArray[80,124] := 'Group_LRN';
    FAuditNamesArray[80,125] := 'Client_Type_LRN';
    FAuditNamesArray[80,126] := 'Job_Count';
    FAuditNamesArray[80,127] := 'Division_Count';
    FAuditNamesArray[80,128] := 'GST_Period';
    FAuditNamesArray[80,129] := 'GST_Start_Month';
    FAuditNamesArray[80,130] := 'Bulk_Extract_Code';
    FAuditNamesArray[80,131] := 'WebNotesAvailable';
    FAuditNamesArray[80,132] := 'WebNotes_Email_Notifications';
    FAuditNamesArray[80,133] := 'ISO_Codes';
    FAuditNamesArray[80,134] := 'Audit_Record_ID';

   FAuditTableArray[100] := 'File_Access_Mapping';
    FAuditNamesArray[100,101] := 'User_LRN';
    FAuditNamesArray[100,102] := 'Client_File_LRN';
    FAuditNamesArray[100,103] := 'Audit_Record_ID';

   FAuditTableArray[90] := 'Client_Account_Map';
    FAuditNamesArray[90,91] := 'Client_LRN';
    FAuditNamesArray[90,92] := 'Account_LRN';
    FAuditNamesArray[90,93] := 'Last_Date_Printed';
    FAuditNamesArray[90,94] := 'Temp_Last_Date_Printed';
    FAuditNamesArray[90,95] := 'Earliest_Download_Date';
    FAuditNamesArray[90,96] := 'Audit_Record_ID';

   FAuditTableArray[110] := 'Group';
    FAuditNamesArray[110,111] := 'LRN';
    FAuditNamesArray[110,112] := 'Name';
    FAuditNamesArray[110,113] := 'Audit_Record_ID';

   FAuditTableArray[120] := 'Client_Type';
    FAuditNamesArray[120,121] := 'LRN';
    FAuditNamesArray[120,122] := 'Name';
    FAuditNamesArray[120,123] := 'Audit_Record_ID';

   FAuditTableArray[130] := 'Audit_Trail';
    FAuditNamesArray[130,131] := 'Audit_ID';
    FAuditNamesArray[130,132] := 'Transaction_Type';
    FAuditNamesArray[130,133] := 'Audit_Action';
    FAuditNamesArray[130,134] := 'Date_Time';
    FAuditNamesArray[130,135] := 'User_Code';
    FAuditNamesArray[130,136] := 'Record_ID';
    FAuditNamesArray[130,137] := 'Parent_ID';
    FAuditNamesArray[130,138] := 'Audit_Record_Type';

end;

end.
