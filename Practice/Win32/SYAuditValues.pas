{-----------------------------------------------------------------------------
 Unit Name: SYAuditValues
 Author:    scott.wilson
 Date:      16-Jun-2011
 Purpose:   Gets System DB audit information for the audit report.
 History:
-----------------------------------------------------------------------------}

unit SYAuditValues;

interface

uses
  BKDEFS, AuditMgr, SYAuditUtils, bkProduct;

  procedure AddSystemAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddUserAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddSystemBankAccountAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddClientAccountMapAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddClientFileAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddMasterMemorisationAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
  procedure AddExchangeGainLossAuditValues(const AAuditRecord: TAudit_Trail_Rec;
              var Values: string);

  //Not used because the system disk log is an audit!
//  procedure AddSystemDiskLogAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);

implementation

uses
  SYAUDIT, BKAUDIT, SYDEFS, BKCONST, MoneyDef, bkdateutils, GenUtils, SysUtils, CountryUtils,
  SYATIO, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKMDIO, BKMLIO, BKglIO;

const
  BANK_ACCOUNT = 'Bank Account';
  CLIENT_CODE = 'Client Code';

procedure GST_Class_Names_Audit_Values(V1: TGST_Class_Names_Array; var Values: string);
var
  i: integer;
  Value: string;
  FieldName: string;
  TempStr: string;
begin
  TempStr := '';
  for i := Low(V1) to High(V1) do begin
    Value := V1[i];
    if Value <> '' then begin
      if (Values <> '') or (TempStr <> '') then
        TempStr := TempStr + VALUES_DELIMITER;
      FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 20);
      FieldName := Localise(SystemAuditMgr.Country, FieldName);      
      TempStr := Format('%s%s[%d]=%s', [TempStr, FieldName, i, Value]);
    end;
  end;
  Values := Values + TempStr;
end;

procedure GST_Rates_Audit_Values(V1: TGST_Rates_Array; var Values: string);
var
  i, j: integer;
  Value: money;
  FieldName: string;
  TempStr: string;
begin
  TempStr := '';
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do begin
      Value := V1[i, j];
      if Value <> 0 then begin
        if (Values <> '') or (TempStr <> '') then
          TempStr := TempStr + VALUES_DELIMITER;
        FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 23);
        FieldName := Localise(SystemAuditMgr.Country, FieldName);
        TempStr := Format('%s%s[%d, %d]=%s', [TempStr, FieldName, i, j, Money2Str(Value / 100)]);
      end;
    end;
  Values := Values + TempStr;
end;

procedure GST_Applies_From_Array(V1: TGST_Applies_From_Array; var Values: string);
var
  i: integer;
  Value: string;
  FieldName: string;
  TempStr: string;
begin
  TempStr := '';
  for i := Low(V1) to High(V1) do begin
    Value := bkDate2Str(V1[i]);
    if Value <> '' then begin
      if (Values <> '') or (TempStr <> '') then
        TempStr := TempStr + VALUES_DELIMITER;
      FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 24);
      FieldName := Localise(SystemAuditMgr.Country, FieldName);
      TempStr := Format('%s%s[%d]=%s', [TempStr, FieldName, i, Value]);
    end;
  end;
  Values := Values + TempStr;
end;


procedure AddSystemAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  PW: string;
  ARecord: Pointer;
  Token, idx: byte;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Name
      12: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                       tPractice_Details_Rec(ARecord^).fdPractice_Name_for_Reports, Values);
      //Phone
      77: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                       tPractice_Details_Rec(ARecord^).fdPractice_Phone, Values);
      //Email
      13: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdPractice_EMail_Address, Values);
      //Website
      76: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdPractice_Web_Site, Values);
      //Logo
      78: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdPractice_Logo_Filename, Values);
      //Secure Code
      31: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdBankLink_Code, Values);
      //Last Download Processed
      32: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdDisk_Sequence_No, Values);
      //Accounting system
      14: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   suNames[tPractice_Details_Rec(ARecord^).fdAccounting_System_Used], Values);
      //GST Names
      20: GST_Class_Names_Audit_Values(TGST_Class_Names_Array(tPractice_Details_Rec(ARecord^).fdGST_Class_Names), Values);
      //GST Rates
      23: GST_Rates_Audit_Values(TGST_Rates_Array(tPractice_Details_Rec(ARecord^).fdGST_Rates), Values);
      //GST Dates
      24: GST_Applies_From_Array(TGST_Applies_From_Array(tPractice_Details_Rec(ARecord^).fdGST_Applies_From), Values);

      //***System Options

      //Bulk_Export_Enabled
      69: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdBulk_Export_Enabled, Values);
      //Bulk_Export_Code
      71: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdBulk_Export_Code, Values);
      //Updates_Pending
      150: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdUpdates_Pending, Values);
      //Update_Server_For_Offsites
      151: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdUpdate_Server_For_Offsites, Values);
      //Login_Bitmap_Filename
      126: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdLogin_Bitmap_Filename, Values);
      //Force_Login
      125: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdForce_Login, Values);
      //Auto_Print_Sched_Rep_Summary
      127: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdAuto_Print_Sched_Rep_Summary, Values);
      //Ignore_Quantity_In_Download
      128: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdIgnore_Quantity_In_Download, Values);
      //Replace_Narration_With_Payee
      147: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdReplace_Narration_With_Payee, Values);
      //Collect_Usage_Data
      152: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdCollect_Usage_Data, Values);
      //Auto_Retrieve_New_Transactions
      163: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdAuto_Retrieve_New_Transactions, Values);
      //Maximum_Narration_Extract
      140: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdMaximum_Narration_Extract, Values);
      //System_Report_Password
      160: begin
             for i := 1 to Length(tPractice_Details_Rec(ARecord^).fdSystem_Report_Password) do
               PW := PW + '*';
             SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                     PW, Values);
           end;
      //Coding_Font
      164: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdCoding_Font, Values);
      //Copy_Dissection_Narration
      131: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdCopy_Dissection_Narration, Values);
      //Use_Xlon_Chart_Order
      133: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdUse_Xlon_Chart_Order, Values);

      //Extract_Multiple_Accounts_PA
      134: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Multiple_Accounts_PA, Values);
      //Extract_Journal_Accounts_PA
      135: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Journal_Accounts_PA, Values);
      //Extract_Quantity
      136: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Quantity, Values);
      //Extract_Quantity_Decimal_Places
      158: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, Token),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Quantity_Decimal_Places, Values);

//   tkfdCountry                          = 15 ;
//   tkfdLoad_Client_Files_From           = 16 ;
//   tkfdSave_Client_Files_To             = 17 ;
//   tkfdShort_Name                       = 18 ;
//   tkfdLong_Name                        = 19 ;
//   tkfdGST_Class_Types                  = 21 ;
//   tkfdGST_Account_Codes                = 22 ;
//   tkfdGST_Applies_From                 = 24 ;
//   tkfdDate_of_Last_Entry_Received      = 25 ;
//   tkfdPrint_Reports_Up_To              = 26 ;
//   tkfdSpare_Boolean_3                  = 27 ;
//   tkfdPrint_Staff_Member_Header_Page   = 28 ;
//   tkfdPrint_Client_Header_Page         = 29 ;
//   tkfdPIN_Number                       = 30 ;
//   tkfdMagic_Number                     = 33 ;
//   tkfdCoding_Report_Style              = 34 ;
//   tkfdCoding_Report_Sort_Order         = 35 ;
//   tkfdCoding_Report_Entry_Selection    = 36 ;
//   tkfdCoding_Report_Blank_Lines        = 37 ;
//   tkfdCoding_Report_Rule_Line          = 38 ;
//   tkfdBank_Account_LRN_Counter         = 39 ;
//   tkfdUser_LRN_Counter                 = 40 ;
//   tkfdTransaction_LRN_Counter          = 41 ;
//   tkfdClient_File_LRN_Counter          = 42 ;
//   tkfdBankLink_Connect_Password        = 43 ;
//   tkfdOld_GST_Class_Codes              = 44 ;
//   tkfdAccount_Code_Mask                = 45 ;
//   tkfdFile_Version                     = 46 ;
//   tkfdSched_Rep_Email_Subject          = 47 ;
//   tkfdOld_Sched_Rep_Email_Line1        = 48 ;
//   tkfdOld_Sched_Rep_Email_Line2        = 49 ;
//   tkfdOLD_BAS_Special_Accounts         = 50 ;
//   tkfdGST_Class_Codes                  = 51 ;
//   tkfdBAS_Field_Number                 = 52 ;
//   tkfdBAS_Field_Source                 = 53 ;
//   tkfdBAS_Field_Account_Code           = 54 ;
//   tkfdBAS_Field_Balance                = 55 ;
//   tkfdSched_Rep_Include_Email          = 56 ;
//   tkfdSched_Rep_Email_Only             = 57 ;
//   tkfdSched_Rep_Include_Printer        = 58 ;
//   tkfdSched_Rep_Include_Fax            = 59 ;
//   tkfdSched_Rep_Send_Fax_Off_Peak      = 60 ;
//   tkfdEnhanced_Software_Options        = 61 ;
//   tkfdSched_Rep_Include_ECoding        = 62 ;
//   tkfdSched_Rep_Cover_Page_Name        = 63 ;
//   tkfdSched_Rep_Cover_Page_Subject     = 64 ;
//   tkfdSched_Rep_Cover_Page_Message     = 65 ;
//   tkfdSched_Rep_Email_Message          = 66 ;
//   tkfdDownload_Report_Options          = 67 ;
//   tkfdDownload_Report_Hide_Deleted     = 68 ;
//   tkfdSpare_Byte_0                     = 70 ;
//   tkfdSched_Rep_Include_CSV_Export     = 72 ;
//   tkfdTax_Interface_Used               = 73 ;
//   tkfdSave_Tax_Files_To                = 74 ;
//   tkfdLast_Disk_Image_Version          = 75 ;
//   tkfdSched_Rep_Print_Custom_Doc_GUID  = 79 ;
//   tkfdSched_Rep_Print_Custom_Doc       = 80 ;
//   tkfdLast_ChargeFile_Date             = 81 ;
//   tkfdAudit_Record_ID                  = 82 ;
//   tkfdSched_Rep_Fax_Custom_Doc_GUID    = 83 ;
//   tkfdSched_Rep_Fax_Custom_Doc         = 84 ;
//   tkfdSpare_Text_3                     = 85 ;
//   tkfdSched_Rep_Email_Custom_Doc_GUID  = 86 ;
//   tkfdSched_Rep_Email_Custom_Doc       = 87 ;
//   tkfdSpare_Text_5                     = 88 ;
//   tkfdSched_Rep_Books_Custom_Doc_GUID  = 89 ;
//   tkfdSched_Rep_Books_Custom_Doc       = 90 ;
//   tkfdSpare_Integer_3                  = 91 ;
//   tkfdSpare_Integer_4                  = 92 ;
//   tkfdSched_Rep_Notes_Custom_Doc_GUID  = 93 ;
//   tkfdSched_Rep_Notes_Custom_Doc       = 94 ;
//   tkfdSpare_Text_8                     = 95 ;
//   tkfdSched_Rep_WebNotes_Custom_Doc_GUID = 96 ;
//   tkfdSched_Rep_WebNotes_Custom_Doc    = 97 ;
//   tkfdSpare_Integer_5                  = 98 ;
//   tkfdSpare_Integer_6                  = 99 ;
//   tkfdSpare_Text_10                    = 100 ;
//   tkfdSpare_Byte_7                     = 101 ;
//   tkfdSpare_Text_11                    = 102 ;
//   tkfdSpare_Text_12                    = 103 ;
//   tkfdSpare_Byte_8                     = 104 ;
//   tkfdSpare_Text_13                    = 105 ;
//   tkfdSpare_Text_14                    = 106 ;
//   tkfdSpare_Byte_9                     = 107 ;
//   tkfdSpare_Integer_7                  = 108 ;
//   tkfdSpare_Integer_8                  = 109 ;
//   tkfdSched_Rep_WebNotes_Subject       = 110 ;
//   tkfdSpare_Byte_10                    = 111 ;
//   tkfdSched_Rep_webNotes_Message       = 112 ;
//   tkfdSpare_Byte_11                    = 113 ;
//   tkfdSched_Rep_Header_Message         = 114 ;
//   tkfdSched_Rep_BNotes_Subject         = 115 ;
//   tkfdSched_Rep_BNotes_Message         = 116 ;
//   tkfdSpare_Boolean_4                  = 117 ;
//   tkfdTask_Tracking_Prompt_Type        = 118 ;
//   tkfdSpare_Bool_1                     = 119 ;
//   tkfdSpare_Bool_2                     = 120 ;
//   tkfdSpare_Integer_9                  = 121 ;
//   tkfdSched_Rep_Fax_Transport          = 122 ;
//   tkfdSched_Rep_Include_WebX           = 123 ;
//   tkfdWeb_Export_Format                = 124 ;
//   tkfdSpare_Boolean_1                  = 129 ;
//   tkfdspare_Boolean_2                  = 130 ;
//   tkfdRound_Cashflow_Reports           = 132 ;
//   tkfdReports_New_Page                 = 137 ;
//   tkfdPrint_Merge_Report_Summary       = 138 ;
//   tkfdEmail_Merge_Report_Summary       = 139 ;
//   tkfdSched_Rep_Include_CheckOut       = 141 ;
//   tkfdSched_Rep_CheckOut_Subject       = 142 ;
//   tkfdSched_Rep_CheckOut_Message       = 143 ;
//   tkfdSched_Rep_Include_Business_Products = 144 ;
//   tkfdSched_Rep_Business_Products_Subject = 145 ;
//   tkfdSched_Rep_Business_Products_Message = 146 ;
//   tkfdLast_Export_Charges_Saved_To     = 148 ;
//   tkfdManual_Account_XML               = 149 ;
//   tkfdFixed_Charge_Increase            = 153 ;
//   tkfdPercentage_Charge_Increase       = 154 ;
//   tkfdFixed_Dollar_Amount              = 155 ;
//   tkfdDistributed_Dollar_Amount        = 156 ;
//   tkfdPercentage_Increase_Amount       = 157 ;
//   tkfdExport_Charges_Remarks           = 159 ;
//   tkfdPrint_Reports_From               = 161 ;
//   tkfdHighest_Date_Ever_Downloaded     = 162 ;
//   tkfdSort_Reports_Option              = 165 ;
//   tkfdSpare_Byte_12                    = 166 ;
//   tkfdGroup_LRN_Counter                = 167 ;
//   tkfdClient_Type_LRN_Counter          = 168 ;
//   tkfdTAX_Applies_From                 = 169 ;
//   tkfdTAX_Rates                        = 170 ;
//   tkfdSuperfund_System                 = 171 ;
//   tkfdSuperfund_Code_Mask              = 172 ;
//   tkfdLoad_Client_Super_Files_From     = 173 ;
//   tkfdSave_Client_Super_Files_To       = 174 ;
//   tkfdSort_Reports_By                  = 175 ;
//   tkfdSet_Fixed_Dollar_Amount          = 176 ;
//   tkfdPrint_Group_Header_Page          = 177 ;
//   tkfdPrint_Client_Type_Header_Page    = 178 ;
//   tkfdPractice_Management_System       = 179 ;
//   tkfdAutomatic_Task_Creation_Flags    = 180 ;
//   tkfdAutomatic_Task_Reminder_Delay    = 181 ;
//   tkfdAutomatic_Task_Closing_Flags     = 182 ;


    end;
    inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure AddUserAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  Token, Idx: byte;
  PW, UserType: string;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Code
      62: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usCode, Values);
      //Name
      63: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usName, Values);
      //Email
      65: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usEMail_Address, Values);
      //Password
      64: begin
            for i := 1 to Length(tUser_Rec(ARecord^).usPassword) do
              PW := PW + '*';
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                         PW, Values);
          end;
      //Direct Dial
      75: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usDirect_Dial, Values);
      //Type
      66: begin
            if (tUser_Rec(ARecord^).usSystem_Access) then
              UserType := ustNames[ustSystem]
            else if (tUser_Rec(ARecord^).usIs_Remote_User) then
              UserType := ustNames[ustRestricted]
            else
              UserType := ustNames[ustNormal];
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                         UserType, Values);
          end;
      //Master mems
      70: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usMASTER_Access, Values);

      //Print options
      77: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usShow_Printer_Choice, Values);
      //Headers
      82: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usSuppress_HF, Values);
      //Logo
      83: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, Token),
                                       tUser_Rec(ARecord^).usShow_Practice_Logo, Values);
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure AddSystemBankAccountAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  Token, Idx: byte;
  PW: string;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Account number
      52: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                       TSystem_Bank_Account_Rec(ARecord^).sbAccount_Number, Values);
      //Account name
      53: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                       TSystem_Bank_Account_Rec(ARecord^).sbAccount_Name, Values);
      //Password
      54: begin
            for i := 1 to Length(TSystem_Bank_Account_Rec(ARecord^).sbAccount_Password) do
              PW := PW + '*';
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                         PW, Values);
          end;
//   tksbLRN                              = 55 ;
//   tksbClient                           = 56 ;
//   tksbCurrent_Balance                  = 57 ;
//   tksbLast_Transaction_LRN             = 58 ;
//   tksbNew_This_Month                   = 59 ;
      //No of Entries
      60: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                       TSystem_Bank_Account_Rec(ARecord^).sbNo_of_Entries_This_Month, Values);

//   tksbFrom_Date_This_Month             = 61 ;
//   tksbTo_Date_This_Month               = 62 ;
//   tksbCost_Code                        = 63 ;
//   tksbCharges_This_Month               = 64 ;
//   tksbOpening_Balance_from_Disk        = 65 ;
//   tksbClosing_Balance_from_Disk        = 66 ;
//   tksbAttach_Required                  = 67 ;
//   tksbWas_On_Latest_Disk               = 68 ;
//   tksbLast_Entry_Date                  = 69 ;
//   tksbDate_Of_Last_Entry_Printed       = 70 ;
      //Mark as deleted
      71: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                       TSystem_Bank_Account_Rec(ARecord^).sbMark_As_Deleted, Values);
//   tksbFile_Code                        = 72 ;
//   tksbClient_ID                        = 73 ;
//   tksbMatter_ID                        = 74 ;
//   tksbAssignment_ID                    = 75 ;
//   tksbDisbursement_ID                  = 76 ;
//   tksbAccount_Type                     = 77 ;
//   tksbJob_Code                         = 78 ;
//   tksbActivity_Code                    = 79 ;
//   tksbUnused                           = 80 ;
//   tksbFirst_Available_Date             = 81 ;
      //Account name
      82: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Bank_Account, Token),
                                       TSystem_Bank_Account_Rec(ARecord^).sbNo_Charge_Account, Values);
//   tksbCurrency_Code                    = 83 ;
//   tksbInstitution                      = 84 ;
//   tksbInActive                         = 85 ;
//   tksbBankLink_Code                    = 86 ;
//   tksbFrequency                        = 87 ;
//   tksbFrequency_Change_Pending         = 88 ;
//   tksbAudit_Record_ID                  = 89 ;

    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure AddClientAccountMapAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  Token, Idx: byte;
  ARecord: Pointer;
  BankAccount, ClientCode: string;
begin
  ARecord := AAuditRecord.atAudit_Record;

  //Delete
  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Bank Account
      92: begin
            BankAccount := SystemAuditMgr.BankAccountFromLRN(TClient_Account_Map_Rec(ARecord^).amAccount_LRN);
            if BankAccount <> '' then
              SystemAuditMgr.AddAuditValue(BANK_ACCOUNT, BankAccount, Values);
          end;
      //Client File
      93: begin
            ClientCode := SystemAuditMgr.ClientCodeFromLRN(TClient_Account_Map_Rec(ARecord^).amClient_LRN);
            if ClientCode <> '' then
              SystemAuditMgr.AddAuditValue(CLIENT_CODE, ClientCode, Values);
          end;
//   tkamClient_LRN                       = 92 ;
//   tkamAccount_LRN                      = 93 ;
//   tkamLast_Date_Printed                = 94 ;
//   tkamTemp_Last_Date_Printed           = 95 ;
//   tkamEarliest_Download_Date           = 96 ;
//   tkamAudit_Record_ID                  = 97 ;
//
//    FAuditNamesArray[90,91] := 'Client_LRN';
//    FAuditNamesArray[90,92] := 'Account_LRN';
//    FAuditNamesArray[90,93] := 'Last_Date_Printed';
//    FAuditNamesArray[90,94] := 'Temp_Last_Date_Printed';
//    FAuditNamesArray[90,95] := 'Earliest_Download_Date';
//    FAuditNamesArray[90,96] := 'Audit_Record_ID';
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure AddClientFileAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  Token, Idx: byte;
  PW, FileStatus: string;
  ARecord: Pointer;

begin
  ARecord := AAuditRecord.atAudit_Record;

  //Delete
  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //File Code
      82: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       TClient_File_Rec(ARecord^).cfFile_Code, Values);
      //File Name
      83: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       TClient_File_Rec(ARecord^).cfFile_Name, Values);
      //File Type
//      84: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
//                                       TClient_File_Rec(ARecord^).cfFile_Type, Values);
      //File Status
      85: begin
            FileStatus := fsNames[TClient_File_Rec(ARecord^).cfFile_Status];
            if FileStatus <> '' then //don't show File_Status=Closed
              SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                           FileStatus, Values);
          end;
      //File Password
      86: begin
            for i := 1 to Length(TClient_File_Rec(ARecord^).cfFile_Password) do
              PW := PW + '*';
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                         PW, Values);
          end;
//   tkcfDate_Last_Accessed               = 87 ;
//   tkcfFile_Save_Count                  = 88 ;
//   tkcfUser_Responsible                 = 89 ;
      //User_Responsible
      89: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       GetUserCode(TClient_File_Rec(ARecord^).cfUser_Responsible), Values);
//   tkcfCurrent_User                     = 90 ;
//   tkcfLRN                              = 91 ;
      //Report_Start_Date
      92: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       bkDate2Str(TClient_File_Rec(ARecord^).cfReport_Start_Date), Values);
      //Reporting_Period
      93: if TClient_File_Rec(ARecord^).cfReporting_Period in [roMin..roMax] then
            SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                         roNames[TClient_File_Rec(ARecord^).cfReporting_Period], Values);
//   tkcfForeign_File                     = 94 ;
//   tkcfUnused_Date_Field                = 95 ;
      //Reports_Due
      96: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       TClient_File_Rec(ARecord^).cfReports_Due, Values);
//   tkcfContact_Details_To_Show          = 97 ;
      //Contact_Details_To_Show
      97: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       cdtNames[TClient_File_Rec(ARecord^).cfContact_Details_To_Show], Values);
      //Financial_Year_Starts
      98: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       bkDate2Str(TClient_File_Rec(ARecord^).cfFinancial_Year_Starts), Values);
      //Schd_Rep_Method
      99: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                       srdNames[TClient_File_Rec(ARecord^).cfSchd_Rep_Method], Values);
//   tkcfSpareBoolean                     = 100 ;
//   tkcfPending_ToDo_Count               = 101 ;
//   tkcfNext_ToDo_Desc                   = 102 ;
//   tkcfNext_ToDo_Rem_Date               = 103 ;
//   tkcfHas_Client_Notes                 = 104 ;
//   tkcfOverdue_ToDo_Count               = 105 ;
//   tkcfSched_Rep_Reports_To_Send        = 106 ;
      //Sched_Rep_Reports_To_Send
//      99: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, 98),
//                                       TClient_File_Rec(ARecord^).cfSched_Rep_Reports_To_Send, Values);
//   tkcfContact_Details_Edit_Date        = 107 ;
//   tkcfContact_Details_Edit_Time        = 108 ;
//   tkcfBank_Accounts                    = 109 ;
//   tkcfDate_Of_Last_Entry_Printed       = 110 ;
//   tkcfLast_Print_Reports_Up_To         = 111 ;
//   tkcfClient_Type                      = 112 ;
//   tkcfCoded                            = 113 ;
//   tkcfFinalized                        = 114 ;
//   tkcfTransferred                      = 115 ;
//   tkcfLast_Processing_Status_Date      = 116 ;
//   tkcfSchd_Rep_Method_Filter           = 117 ;
      //Archived
      118: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                        TClient_File_Rec(ARecord^).cfArchived, Values);
//   tkcfPayee_Count                      = 119 ;
//   tkcfBank_Account_Count               = 120 ;
//   tkcfManual_Account_Count             = 121 ;
//   tkcfMem_Count                        = 122 ;
//   tkcfAccounting_System                = 123 ;
//   tkcfDownloaded                       = 124 ;
      //Group
      125: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                        GetGroupName(TClient_File_Rec(ARecord^).cfGroup_LRN), Values);
      //Client_Type_LRN
      126: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Client_File, Token),
                                        GetClientFileType(TClient_File_Rec(ARecord^).cfClient_Type_LRN), Values);
//   tkcfJob_Count                        = 127 ;
//   tkcfDivision_Count                   = 128 ;
//   tkcfGST_Period                       = 129 ;
//   tkcfGST_Start_Month                  = 130 ;
//   tkcfBulk_Extract_Code                = 131 ;
//   tkcfWebNotesAvailable                = 132 ;
//   tkcfWebNotes_Email_Notifications     = 133 ;
//   tkcfISO_Codes                        = 134 ;
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure AddMasterMemorisationAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
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
    tkBegin_System_Memorisation_List:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Prefix
            153: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, Token),
                                             TSystem_Memorisation_List_Rec(ARecord^).smBank_Prefix, Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Memorisation_Detail :
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Sequence_No
            142: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdSequence_No, Values);
//    FAuditNamesArray[140,142] := 'Type';
            //Amount
            144: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              Money2Str(TMemorisation_Detail_Rec(ARecord^).mdAmount), Values);
            //Reference
            145: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdReference, Values);
            //Particulars
            146: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdParticulars, Values);
            //Analysis
            147: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdAnalysis, Values);
            //Other_Party
            148: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdOther_Party, Values);
            //Statement_Details
            149: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdStatement_Details, Values);
            //Match_on_Amount
            150: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Amount, Values);
            //Match_on_Analysis
            151: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Analysis, Values);
            //Match_on_Other_Party
            152: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Other_Party, Values);
            //Match_on_Notes
            153: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Notes, Values);
            //Match_on_Particulars
            154: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Particulars, Values);
            //Match_on_Refce
            155: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Refce, Values);
            //Match_On_Statement_Details
            156: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_On_Statement_Details, Values);
            //Payee_Number
            157: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdPayee_Number, Values);
//    FAuditNamesArray[140,157] := 'From_Master_List';
            //Notes
            159: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdNotes, Values);
            //Date_Last_Applied
            160: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdDate_Last_Applied), Values);
            161: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdUse_Accounting_System, Values);
            //Accounting_System
            162: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              GetAccountingSystemName(TMemorisation_Detail_Rec(ARecord^).mdAccounting_System), Values);
            //From_Date
            163: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdFrom_Date), Values);
            //Until_Date
            164: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdUntil_Date), Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Memorisation_Line:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Account
            147: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlAccount, Values);
            //Percentage
            148: case TMemorisation_Line_Rec(ARecord^).mlLine_Type of
                   mltPercentage: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, 147),
                                                               Percent2Str(TMemorisation_Line_Rec(ARecord^).mlPercentage) + '%', Values);
                    mltDollarAmt: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, 147),
                                                               Money2Str(TMemorisation_Line_Rec(ARecord^).mlPercentage), Values);
                 end;
            //GST_Class
            149: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGST_Class, Values);
            //GST_Has_Been_Edited
            150: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGST_Has_Been_Edited, Values);
            //GL_Narration
            151: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGL_Narration, Values);
            //Line_Type
            152: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              mltNames[TMemorisation_Line_Rec(ARecord^).mlLine_Type], Values);
            //GST_Amount
            153: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              Money2Str(TMemorisation_Line_Rec(ARecord^).mlGST_Amount), Values);
            //Payee
            154: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlPayee, Values);
            //Job_Code
            166: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlJob_Code, Values);
            //Quantity
            167: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              Money2Str(TMemorisation_Line_Rec(ARecord^).mlQuantity), Values);

//**** No need to audit superfund fields as auditing is UK only
//    FAuditNamesArray[145,154] := 'SF_PCFranked';
//    FAuditNamesArray[145,155] := 'SF_Member_ID';
//    FAuditNamesArray[145,156] := 'SF_Fund_ID';
//    FAuditNamesArray[145,157] := 'SF_Fund_Code';
//    FAuditNamesArray[145,158] := 'SF_Trans_ID';
//    FAuditNamesArray[145,159] := 'SF_Trans_Code';
//    FAuditNamesArray[145,160] := 'SF_Member_Account_ID';
//    FAuditNamesArray[145,161] := 'SF_Member_Account_Code';
//    FAuditNamesArray[145,162] := 'SF_Edited';
//    FAuditNamesArray[145,163] := 'SF_Member_Component';
//    FAuditNamesArray[145,164] := 'SF_PCUnFranked';
//    FAuditNamesArray[145,167] := 'SF_GDT_Date';
//    FAuditNamesArray[145,168] := 'SF_Tax_Free_Dist';
//    FAuditNamesArray[145,169] := 'SF_Tax_Exempt_Dist';
//    FAuditNamesArray[145,170] := 'SF_Tax_Deferred_Dist';
//    FAuditNamesArray[145,171] := 'SF_TFN_Credits';
//    FAuditNamesArray[145,172] := 'SF_Foreign_Income';
//    FAuditNamesArray[145,173] := 'SF_Foreign_Tax_Credits';
//    FAuditNamesArray[145,174] := 'SF_Capital_Gains_Indexed';
//    FAuditNamesArray[145,175] := 'SF_Capital_Gains_Disc';
//    FAuditNamesArray[145,176] := 'SF_Capital_Gains_Other';
//    FAuditNamesArray[145,177] := 'SF_Other_Expenses';
//    FAuditNamesArray[145,178] := 'SF_Interest';
//    FAuditNamesArray[145,179] := 'SF_Capital_Gains_Foreign_Disc';
//    FAuditNamesArray[145,180] := 'SF_Rent';
//    FAuditNamesArray[145,181] := 'SF_Special_Income';
//    FAuditNamesArray[145,182] := 'SF_Other_Tax_Credit';
//    FAuditNamesArray[145,183] := 'SF_Non_Resident_Tax';
//    FAuditNamesArray[145,184] := 'SF_Foreign_Capital_Gains_Credit';
//    FAuditNamesArray[145,185] := 'SF_Capital_Gains_Fraction_Half';
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

//procedure AddSystemDiskLogAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
//var
//  Token, Idx: byte;
//  ARecord: Pointer;
//begin
//  ARecord := AAuditRecord.atAudit_Record;
//  if ARecord = nil then Exit;
//
//  Idx := 0;
//  Token := AAuditRecord.atChanged_Fields[idx];
//  while Token <> 0 do begin
//    case Token of
//      //Disk_ID
//      42: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 41),
//                                       TSystem_Disk_Log_Rec(ARecord^).dlDisk_ID, Values);
//      //Date_Downloaded
//      43: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 42),
//                                       bkDate2Str(TSystem_Disk_Log_Rec(ARecord^).dlDate_Downloaded), Values);
//      //No_of_Accounts
//      44: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 43),
//                                       TSystem_Disk_Log_Rec(ARecord^).dlNo_of_Accounts, Values);
//      //No_of_Entries
//      45: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 44),
//                                       TSystem_Disk_Log_Rec(ARecord^).dlNo_of_Entries, Values);
//      //Was_In_Last_Download
//      46: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Disk_Log, 45),
//                                       TSystem_Disk_Log_Rec(ARecord^).dlWas_In_Last_Download, Values);
//    end;
//    Inc(Idx);
//    Token := AAuditRecord.atChanged_Fields[idx];
//  end;
//end;

procedure AddExchangeGainLossAuditValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
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
    tkBegin_Exchange_Gain_Loss:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];

        while Token <> 0 do begin
          case Token of
            { Note: the token values are declared in the implementation section
              of BKglIO, so we can't use them.
            }
            204: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Exchange_Gain_Loss, Token),
                                              BKDate2Str(TExchange_Gain_Loss_Rec(ARecord^).glDate), Values);

            205: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Exchange_Gain_Loss, Token),
                                              Money2Str(TExchange_Gain_Loss_Rec(ARecord^).glAmount), Values);

            206: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Exchange_Gain_Loss, Token),
                                              TExchange_Gain_Loss_Rec(ARecord^).glAccount, Values);

            207: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Exchange_Gain_Loss, Token),
                                              BKDate2Str(TExchange_Gain_Loss_Rec(ARecord^).glPosted_Date), Values);
        end;

        Inc(Idx);
        Token := AAuditRecord.atChanged_Fields[idx];
      end;
    end;
  end;
end;

end.
