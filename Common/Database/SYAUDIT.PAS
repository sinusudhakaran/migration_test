unit SYAUDIT;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

interface

uses
  SysUtils;

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
    FAuditNamesArray[10,12] := 'Practice_Name_for_Reports';
    FAuditNamesArray[10,13] := 'Practice_EMail_Address';
    FAuditNamesArray[10,14] := 'Accounting_System_Used';
    FAuditNamesArray[10,15] := 'Country';
    FAuditNamesArray[10,16] := 'Load_Client_Files_From';
    FAuditNamesArray[10,17] := 'Save_Client_Files_To';
    FAuditNamesArray[10,18] := 'Short_Name';
    FAuditNamesArray[10,19] := 'Long_Name';
    FAuditNamesArray[10,20] := 'GST_Class_Names';
    FAuditNamesArray[10,21] := 'GST_Class_Types';
    FAuditNamesArray[10,22] := 'GST_Account_Codes';
    FAuditNamesArray[10,23] := 'GST_Rates';
    FAuditNamesArray[10,24] := 'GST_Applies_From';
    FAuditNamesArray[10,25] := 'Date_of_Last_Entry_Received';
    FAuditNamesArray[10,26] := 'Print_Reports_Up_To';
    FAuditNamesArray[10,27] := 'Use_BankLink_Online';
    FAuditNamesArray[10,28] := 'Print_Staff_Member_Header_Page';
    FAuditNamesArray[10,29] := 'Print_Client_Header_Page';
    FAuditNamesArray[10,30] := 'PIN_Number';
    FAuditNamesArray[10,31] := 'BankLink_Code';
    FAuditNamesArray[10,32] := 'Disk_Sequence_No';
    FAuditNamesArray[10,33] := 'Magic_Number';
    FAuditNamesArray[10,34] := 'Coding_Report_Style';
    FAuditNamesArray[10,35] := 'Coding_Report_Sort_Order';
    FAuditNamesArray[10,36] := 'Coding_Report_Entry_Selection';
    FAuditNamesArray[10,37] := 'Coding_Report_Blank_Lines';
    FAuditNamesArray[10,38] := 'Coding_Report_Rule_Line';
    FAuditNamesArray[10,39] := 'Bank_Account_LRN_Counter';
    FAuditNamesArray[10,40] := 'User_LRN_Counter';
    FAuditNamesArray[10,41] := 'Transaction_LRN_Counter';
    FAuditNamesArray[10,42] := 'Client_File_LRN_Counter';
    FAuditNamesArray[10,43] := 'BankLink_Connect_Password';
    FAuditNamesArray[10,44] := 'Old_GST_Class_Codes';
    FAuditNamesArray[10,45] := 'Account_Code_Mask';
    FAuditNamesArray[10,46] := 'File_Version';
    FAuditNamesArray[10,47] := 'Sched_Rep_Email_Subject';
    FAuditNamesArray[10,48] := 'Old_Sched_Rep_Email_Line1';
    FAuditNamesArray[10,49] := 'Old_Sched_Rep_Email_Line2';
    FAuditNamesArray[10,50] := 'OLD_BAS_Special_Accounts';
    FAuditNamesArray[10,51] := 'GST_Class_Codes';
    FAuditNamesArray[10,52] := 'BAS_Field_Number';
    FAuditNamesArray[10,53] := 'BAS_Field_Source';
    FAuditNamesArray[10,54] := 'BAS_Field_Account_Code';
    FAuditNamesArray[10,55] := 'BAS_Field_Balance';
    FAuditNamesArray[10,56] := 'Sched_Rep_Include_Email';
    FAuditNamesArray[10,57] := 'Sched_Rep_Email_Only';
    FAuditNamesArray[10,58] := 'Sched_Rep_Include_Printer';
    FAuditNamesArray[10,59] := 'Sched_Rep_Include_Fax';
    FAuditNamesArray[10,60] := 'Sched_Rep_Send_Fax_Off_Peak';
    FAuditNamesArray[10,61] := 'Enhanced_Software_Options';
    FAuditNamesArray[10,62] := 'Sched_Rep_Include_ECoding';
    FAuditNamesArray[10,63] := 'Sched_Rep_Cover_Page_Name';
    FAuditNamesArray[10,64] := 'Sched_Rep_Cover_Page_Subject';
    FAuditNamesArray[10,65] := 'Sched_Rep_Cover_Page_Message';
    FAuditNamesArray[10,66] := 'Sched_Rep_Email_Message';
    FAuditNamesArray[10,67] := 'Download_Report_Options';
    FAuditNamesArray[10,68] := 'Download_Report_Hide_Deleted';
    FAuditNamesArray[10,69] := 'Bulk_Export_Enabled';
    FAuditNamesArray[10,70] := 'Spare_Byte_0';
    FAuditNamesArray[10,71] := 'Bulk_Export_Code';
    FAuditNamesArray[10,72] := 'Sched_Rep_Include_CSV_Export';
    FAuditNamesArray[10,73] := 'Tax_Interface_Used';
    FAuditNamesArray[10,74] := 'Save_Tax_Files_To';
    FAuditNamesArray[10,75] := 'Last_Disk_Image_Version';
    FAuditNamesArray[10,76] := 'Practice_Web_Site';
    FAuditNamesArray[10,77] := 'Practice_Phone';
    FAuditNamesArray[10,78] := 'Practice_Logo_Filename';
    FAuditNamesArray[10,79] := 'Sched_Rep_Print_Custom_Doc_GUID';
    FAuditNamesArray[10,80] := 'Sched_Rep_Print_Custom_Doc';
    FAuditNamesArray[10,81] := 'Last_ChargeFile_Date';
    FAuditNamesArray[10,82] := 'Audit_Record_ID';
    FAuditNamesArray[10,83] := 'Sched_Rep_Fax_Custom_Doc_GUID';
    FAuditNamesArray[10,84] := 'Sched_Rep_Fax_Custom_Doc';
    FAuditNamesArray[10,85] := 'Spare_Text_3';
    FAuditNamesArray[10,86] := 'Sched_Rep_Email_Custom_Doc_GUID';
    FAuditNamesArray[10,87] := 'Sched_Rep_Email_Custom_Doc';
    FAuditNamesArray[10,88] := 'Spare_Text_5';
    FAuditNamesArray[10,89] := 'Sched_Rep_Books_Custom_Doc_GUID';
    FAuditNamesArray[10,90] := 'Sched_Rep_Books_Custom_Doc';
    FAuditNamesArray[10,91] := 'Spare_Integer_3';
    FAuditNamesArray[10,92] := 'Spare_Integer_4';
    FAuditNamesArray[10,93] := 'Sched_Rep_Notes_Custom_Doc_GUID';
    FAuditNamesArray[10,94] := 'Sched_Rep_Notes_Custom_Doc';
    FAuditNamesArray[10,95] := 'Spare_Text_8';
    FAuditNamesArray[10,96] := 'Sched_Rep_WebNotes_Custom_Doc_GUID';
    FAuditNamesArray[10,97] := 'Sched_Rep_WebNotes_Custom_Doc';
    FAuditNamesArray[10,98] := 'Spare_Integer_5';
    FAuditNamesArray[10,99] := 'Spare_Integer_6';
    FAuditNamesArray[10,100] := 'Spare_Text_10';
    FAuditNamesArray[10,101] := 'Spare_Byte_7';
    FAuditNamesArray[10,102] := 'Spare_Text_11';
    FAuditNamesArray[10,103] := 'Spare_Text_12';
    FAuditNamesArray[10,104] := 'Spare_Byte_8';
    FAuditNamesArray[10,105] := 'Spare_Text_13';
    FAuditNamesArray[10,106] := 'BankLink_Online_Config';
    FAuditNamesArray[10,107] := 'Spare_Byte_9';
    FAuditNamesArray[10,108] := 'Spare_Integer_7';
    FAuditNamesArray[10,109] := 'Spare_Integer_8';
    FAuditNamesArray[10,110] := 'Sched_Rep_WebNotes_Subject';
    FAuditNamesArray[10,111] := 'Spare_Byte_10';
    FAuditNamesArray[10,112] := 'Sched_Rep_webNotes_Message';
    FAuditNamesArray[10,113] := 'Spare_Byte_11';
    FAuditNamesArray[10,114] := 'Sched_Rep_Header_Message';
    FAuditNamesArray[10,115] := 'Sched_Rep_BNotes_Subject';
    FAuditNamesArray[10,116] := 'Sched_Rep_BNotes_Message';
    FAuditNamesArray[10,117] := 'Spare_Boolean_4';
    FAuditNamesArray[10,118] := 'Task_Tracking_Prompt_Type';
    FAuditNamesArray[10,119] := 'Spare_Bool_1';
    FAuditNamesArray[10,120] := 'Spare_Bool_2';
    FAuditNamesArray[10,121] := 'Spare_Integer_9';
    FAuditNamesArray[10,122] := 'Sched_Rep_Fax_Transport';
    FAuditNamesArray[10,123] := 'Sched_Rep_Include_WebX';
    FAuditNamesArray[10,124] := 'Web_Export_Format';
    FAuditNamesArray[10,125] := 'Force_Login';
    FAuditNamesArray[10,126] := 'Login_Bitmap_Filename';
    FAuditNamesArray[10,127] := 'Auto_Print_Sched_Rep_Summary';
    FAuditNamesArray[10,128] := 'Ignore_Quantity_In_Download';
    FAuditNamesArray[10,129] := 'Spare_Boolean_1';
    FAuditNamesArray[10,130] := 'spare_Boolean_2';
    FAuditNamesArray[10,131] := 'Copy_Dissection_Narration';
    FAuditNamesArray[10,132] := 'Round_Cashflow_Reports';
    FAuditNamesArray[10,133] := 'Use_Xlon_Chart_Order';
    FAuditNamesArray[10,134] := 'Extract_Multiple_Accounts_PA';
    FAuditNamesArray[10,135] := 'Extract_Journal_Accounts_PA';
    FAuditNamesArray[10,136] := 'Extract_Quantity';
    FAuditNamesArray[10,137] := 'Reports_New_Page';
    FAuditNamesArray[10,138] := 'Print_Merge_Report_Summary';
    FAuditNamesArray[10,139] := 'Email_Merge_Report_Summary';
    FAuditNamesArray[10,140] := 'Maximum_Narration_Extract';
    FAuditNamesArray[10,141] := 'Sched_Rep_Include_CheckOut';
    FAuditNamesArray[10,142] := 'Sched_Rep_CheckOut_Subject';
    FAuditNamesArray[10,143] := 'Sched_Rep_CheckOut_Message';
    FAuditNamesArray[10,144] := 'Sched_Rep_Include_Business_Products';
    FAuditNamesArray[10,145] := 'Sched_Rep_Business_Products_Subject';
    FAuditNamesArray[10,146] := 'Sched_Rep_Business_Products_Message';
    FAuditNamesArray[10,147] := 'Replace_Narration_With_Payee';
    FAuditNamesArray[10,148] := 'Last_Export_Charges_Saved_To';
    FAuditNamesArray[10,149] := 'Manual_Account_XML';
    FAuditNamesArray[10,150] := 'Updates_Pending';
    FAuditNamesArray[10,151] := 'Update_Server_For_Offsites';
    FAuditNamesArray[10,152] := 'Collect_Usage_Data';
    FAuditNamesArray[10,153] := 'Fixed_Charge_Increase';
    FAuditNamesArray[10,154] := 'Percentage_Charge_Increase';
    FAuditNamesArray[10,155] := 'Fixed_Dollar_Amount';
    FAuditNamesArray[10,156] := 'Distributed_Dollar_Amount';
    FAuditNamesArray[10,157] := 'Percentage_Increase_Amount';
    FAuditNamesArray[10,158] := 'Extract_Quantity_Decimal_Places';
    FAuditNamesArray[10,159] := 'Export_Charges_Remarks';
    FAuditNamesArray[10,160] := 'System_Report_Password';
    FAuditNamesArray[10,161] := 'Print_Reports_From';
    FAuditNamesArray[10,162] := 'Highest_Date_Ever_Downloaded';
    FAuditNamesArray[10,163] := 'Auto_Retrieve_New_Transactions';
    FAuditNamesArray[10,164] := 'Coding_Font';
    FAuditNamesArray[10,165] := 'Sort_Reports_Option';
    FAuditNamesArray[10,166] := 'Spare_Byte_12';
    FAuditNamesArray[10,167] := 'Group_LRN_Counter';
    FAuditNamesArray[10,168] := 'Client_Type_LRN_Counter';
    FAuditNamesArray[10,169] := 'TAX_Applies_From';
    FAuditNamesArray[10,170] := 'TAX_Rates';
    FAuditNamesArray[10,171] := 'Superfund_System';
    FAuditNamesArray[10,172] := 'Superfund_Code_Mask';
    FAuditNamesArray[10,173] := 'Load_Client_Super_Files_From';
    FAuditNamesArray[10,174] := 'Save_Client_Super_Files_To';
    FAuditNamesArray[10,175] := 'Sort_Reports_By';
    FAuditNamesArray[10,176] := 'Set_Fixed_Dollar_Amount';
    FAuditNamesArray[10,177] := 'Print_Group_Header_Page';
    FAuditNamesArray[10,178] := 'Print_Client_Type_Header_Page';
    FAuditNamesArray[10,179] := 'Practice_Management_System';
    FAuditNamesArray[10,180] := 'Automatic_Task_Creation_Flags';
    FAuditNamesArray[10,181] := 'Automatic_Task_Reminder_Delay';
    FAuditNamesArray[10,182] := 'Automatic_Task_Closing_Flags';
    FAuditNamesArray[10,183] := 'Sched_Rep_Include_Online';
    FAuditNamesArray[10,184] := 'Sched_Rep_Online_Subject';
    FAuditNamesArray[10,185] := 'Sched_Rep_Online_Message';
    FAuditNamesArray[10,186] := 'Sched_Rep_Online_Custom_Doc_GUID';
    FAuditNamesArray[10,187] := 'Sched_Rep_Online_Custom_Doc';
    FAuditNamesArray[10,188] := 'Last_BankLink_Online_Update';
    FAuditNamesArray[10,189] := 'Last_Agreed_To_BLOSA';
    FAuditNamesArray[10,190] := 'Banklink_Online_Suspended';

   FAuditTableArray[40] := 'System_Disk_Log';
    FAuditNamesArray[40,42] := 'Disk_ID';
    FAuditNamesArray[40,43] := 'Date_Downloaded';
    FAuditNamesArray[40,44] := 'No_of_Accounts';
    FAuditNamesArray[40,45] := 'No_of_Entries';
    FAuditNamesArray[40,46] := 'Was_In_Last_Download';
    FAuditNamesArray[40,47] := 'Audit_Record_ID';

   FAuditTableArray[60] := 'User';
    FAuditNamesArray[60,62] := 'User Code'; //Code
    FAuditNamesArray[60,63] := 'User Name'; //Name
    FAuditNamesArray[60,64] := 'Redundant_Password';
    FAuditNamesArray[60,65] := 'Email'; //EMail_Address
    FAuditNamesArray[60,66] := 'System_Access';
    FAuditNamesArray[60,67] := 'Dialog_Colour';
    FAuditNamesArray[60,68] := 'Logged_In';
    FAuditNamesArray[60,69] := 'Reverse_Mouse_Buttons';
    FAuditNamesArray[60,70] := 'MASTER_Access';
    FAuditNamesArray[60,71] := 'LRN';
    FAuditNamesArray[60,72] := 'Spare_String';
    FAuditNamesArray[60,73] := 'Workstation_Logged_In_At';
    FAuditNamesArray[60,74] := 'Is_Remote_User';
    FAuditNamesArray[60,75] := 'Direct_Dial';
    FAuditNamesArray[60,76] := 'Show_CM_on_open';
    FAuditNamesArray[60,77] := 'Show_Printer_Choice';
    FAuditNamesArray[60,78] := 'EULA_Version';
    FAuditNamesArray[60,79] := 'Spare_Boolean';
    FAuditNamesArray[60,80] := 'Login_Count';
    FAuditNamesArray[60,81] := 'Reset_Count';
    FAuditNamesArray[60,82] := 'Suppress_HF';
    FAuditNamesArray[60,83] := 'Show_Practice_Logo';
    FAuditNamesArray[60,84] := 'Audit_Record_ID';
    FAuditNamesArray[60,85] := 'Allow_Banklink_Online';
    FAuditNamesArray[60,86] := 'Password';
    FAuditNamesArray[60,87] := 'Use_Practice_Password_Online';
    FAuditNamesArray[60,88] := 'Using_Mixed_Case_Password';
    FAuditNamesArray[60,89] := 'Using_Secure_Authentication';
    FAuditNamesArray[60,90] := 'User_Data_Block';
    FAuditNamesArray[60,91] := 'Salt';

   FAuditTableArray[50] := 'System_Bank_Account';
    FAuditNamesArray[50,52] := 'Account_Number';
    FAuditNamesArray[50,53] := 'Account_Name';
    FAuditNamesArray[50,54] := 'Account_Password';
    FAuditNamesArray[50,55] := 'LRN';
    FAuditNamesArray[50,56] := 'Client';
    FAuditNamesArray[50,57] := 'Current_Balance';
    FAuditNamesArray[50,58] := 'Last_Transaction_LRN';
    FAuditNamesArray[50,59] := 'New_This_Month';
    FAuditNamesArray[50,60] := 'No_of_Entries_This_Month';
    FAuditNamesArray[50,61] := 'From_Date_This_Month';
    FAuditNamesArray[50,62] := 'To_Date_This_Month';
    FAuditNamesArray[50,63] := 'Cost_Code';
    FAuditNamesArray[50,64] := 'Charges_This_Month';
    FAuditNamesArray[50,65] := 'Opening_Balance_from_Disk';
    FAuditNamesArray[50,66] := 'Closing_Balance_from_Disk';
    FAuditNamesArray[50,67] := 'Attach_Required';
    FAuditNamesArray[50,68] := 'Was_On_Latest_Disk';
    FAuditNamesArray[50,69] := 'Last_Entry_Date';
    FAuditNamesArray[50,70] := 'Date_Of_Last_Entry_Printed';
    FAuditNamesArray[50,71] := 'Mark_As_Deleted';
    FAuditNamesArray[50,72] := 'File_Code';
    FAuditNamesArray[50,73] := 'Client_ID';
    FAuditNamesArray[50,74] := 'Matter_ID';
    FAuditNamesArray[50,75] := 'Assignment_ID';
    FAuditNamesArray[50,76] := 'Disbursement_ID';
    FAuditNamesArray[50,77] := 'Account_Type';
    FAuditNamesArray[50,78] := 'Job_Code';
    FAuditNamesArray[50,79] := 'Activity_Code';
    FAuditNamesArray[50,80] := 'Unused';
    FAuditNamesArray[50,81] := 'First_Available_Date';
    FAuditNamesArray[50,82] := 'No_Charge_Account';
    FAuditNamesArray[50,83] := 'Currency_Code';
    FAuditNamesArray[50,84] := 'Institution';
    FAuditNamesArray[50,85] := 'InActive';
    FAuditNamesArray[50,86] := 'BankLink_Code';
    FAuditNamesArray[50,87] := 'Frequency';
    FAuditNamesArray[50,88] := 'Frequency_Change_Pending';
    FAuditNamesArray[50,89] := 'Audit_Record_ID';
    FAuditNamesArray[50,90] := 'Core_Account_ID';
    FAuditNamesArray[50,91] := 'Secure_Online_Code';

   FAuditTableArray[80] := 'Client_File';
    FAuditNamesArray[80,82] := 'File_Code';
    FAuditNamesArray[80,83] := 'File_Name';
    FAuditNamesArray[80,84] := 'File_Type';
    FAuditNamesArray[80,85] := 'File_Status';
    FAuditNamesArray[80,86] := 'File_Password';
    FAuditNamesArray[80,87] := 'Date_Last_Accessed';
    FAuditNamesArray[80,88] := 'File_Save_Count';
    FAuditNamesArray[80,89] := 'User_Responsible';
    FAuditNamesArray[80,90] := 'Current_User';
    FAuditNamesArray[80,91] := 'LRN';
    FAuditNamesArray[80,92] := 'Report_Start_Date';
    FAuditNamesArray[80,93] := 'Reporting_Period';
    FAuditNamesArray[80,94] := 'Foreign_File';
    FAuditNamesArray[80,95] := 'Unused_Date_Field';
    FAuditNamesArray[80,96] := 'Reports_Due';
    FAuditNamesArray[80,97] := 'Contact_Details_To_Show';
    FAuditNamesArray[80,98] := 'Financial_Year_Starts';
    FAuditNamesArray[80,99] := 'Schd_Rep_Method';
    FAuditNamesArray[80,100] := 'SpareBoolean';
    FAuditNamesArray[80,101] := 'Pending_ToDo_Count';
    FAuditNamesArray[80,102] := 'Next_ToDo_Desc';
    FAuditNamesArray[80,103] := 'Next_ToDo_Rem_Date';
    FAuditNamesArray[80,104] := 'Has_Client_Notes';
    FAuditNamesArray[80,105] := 'Overdue_ToDo_Count';
    FAuditNamesArray[80,106] := 'Sched_Rep_Reports_To_Send';
    FAuditNamesArray[80,107] := 'Contact_Details_Edit_Date';
    FAuditNamesArray[80,108] := 'Contact_Details_Edit_Time';
    FAuditNamesArray[80,109] := 'Bank_Accounts';
    FAuditNamesArray[80,110] := 'Date_Of_Last_Entry_Printed';
    FAuditNamesArray[80,111] := 'Last_Print_Reports_Up_To';
    FAuditNamesArray[80,112] := 'Client_Type';
    FAuditNamesArray[80,113] := 'Coded';
    FAuditNamesArray[80,114] := 'Finalized';
    FAuditNamesArray[80,115] := 'Transferred';
    FAuditNamesArray[80,116] := 'Last_Processing_Status_Date';
    FAuditNamesArray[80,117] := 'Schd_Rep_Method_Filter';
    FAuditNamesArray[80,118] := 'Archived';
    FAuditNamesArray[80,119] := 'Payee_Count';
    FAuditNamesArray[80,120] := 'Bank_Account_Count';
    FAuditNamesArray[80,121] := 'Manual_Account_Count';
    FAuditNamesArray[80,122] := 'Mem_Count';
    FAuditNamesArray[80,123] := 'Accounting_System';
    FAuditNamesArray[80,124] := 'Downloaded';
    FAuditNamesArray[80,125] := 'Group_LRN';
    FAuditNamesArray[80,126] := 'Client_Type_LRN';
    FAuditNamesArray[80,127] := 'Job_Count';
    FAuditNamesArray[80,128] := 'Division_Count';
    FAuditNamesArray[80,129] := 'GST_Period';
    FAuditNamesArray[80,130] := 'GST_Start_Month';
    FAuditNamesArray[80,131] := 'Bulk_Extract_Code';
    FAuditNamesArray[80,132] := 'WebNotesAvailable';
    FAuditNamesArray[80,133] := 'WebNotes_Email_Notifications';
    FAuditNamesArray[80,134] := 'ISO_Codes';
    FAuditNamesArray[80,135] := 'Audit_Record_ID';
    FAuditNamesArray[80,136] := 'File_Transfer_Method';
    FAuditNamesArray[80,137] := 'Client_File_GUID';

   FAuditTableArray[100] := 'File_Access_Mapping';
    FAuditNamesArray[100,102] := 'User_LRN';
    FAuditNamesArray[100,103] := 'Client_File_LRN';
    FAuditNamesArray[100,104] := 'Audit_Record_ID';

   FAuditTableArray[90] := 'Client_Account_Map';
    FAuditNamesArray[90,92] := 'Client_LRN';
    FAuditNamesArray[90,93] := 'Account_LRN';
    FAuditNamesArray[90,94] := 'Last_Date_Printed';
    FAuditNamesArray[90,95] := 'Temp_Last_Date_Printed';
    FAuditNamesArray[90,96] := 'Earliest_Download_Date';
    FAuditNamesArray[90,97] := 'Audit_Record_ID';

   FAuditTableArray[110] := 'Group';
    FAuditNamesArray[110,112] := 'LRN';
    FAuditNamesArray[110,113] := 'Name';
    FAuditNamesArray[110,114] := 'Audit_Record_ID';

   FAuditTableArray[120] := 'Client_Type';
    FAuditNamesArray[120,122] := 'LRN';
    FAuditNamesArray[120,123] := 'Name';
    FAuditNamesArray[120,124] := 'Audit_Record_ID';

   FAuditTableArray[135] := 'Audit_Trail';
    FAuditNamesArray[135,137] := 'Audit_ID';
    FAuditNamesArray[135,138] := 'Transaction_Type';
    FAuditNamesArray[135,139] := 'Audit_Action';
    FAuditNamesArray[135,140] := 'Date_Time';
    FAuditNamesArray[135,141] := 'User_Code';
    FAuditNamesArray[135,142] := 'Record_ID';
    FAuditNamesArray[135,143] := 'Parent_ID';
    FAuditNamesArray[135,144] := 'Changed_Fields';
    FAuditNamesArray[135,145] := 'Other_Info';
    FAuditNamesArray[135,146] := 'Audit_Record_Type';

   FAuditTableArray[137] := 'Provisional_Entries_Log';
    FAuditNamesArray[137,139] := 'Date_Time';
    FAuditNamesArray[137,140] := 'User_Code';
    FAuditNamesArray[137,141] := 'First_LRN';
    FAuditNamesArray[137,142] := 'Last_LRN';

   FAuditTableArray[150] := 'System_Memorisation_List';
    FAuditNamesArray[150,152] := 'Audit_Record_ID';
    FAuditNamesArray[150,153] := 'Bank_Prefix';

end;

initialization
  _AuditNames := nil;
finalization
  if Assigned(_AuditNames) then
    FreeAndNil(_AuditNames);
end.
