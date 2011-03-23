UNIT SYfdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Practice_Details             = 10 ;
   tkEnd_Practice_Details               = 11 ;

FUNCTION  IsAPractice_Details_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Practice_Details_Rec ( Var O : TPractice_Details_Rec ; Var F : TIOStream );
PROCEDURE Read_Practice_Details_Rec ( Var O : TPractice_Details_Rec ; Var F : TIOStream );
FUNCTION  New_Practice_Details_Rec : pPractice_Details_Rec ;
PROCEDURE Free_Practice_Details_Rec_Dynamic_Fields ( Var O : TPractice_Details_Rec );
function Practice_Details_Rec_Delta(P1, P2, P3: pPractice_Details_Rec): boolean;
procedure Copy_Practice_Details_Rec(P1, P2: pPractice_Details_Rec);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYFDIO';
   SBoundsError        = 'SYFDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYFDIO Error: Pointer is NIL in IsAPractice_Details_Rec';
   SInvalidType        = 'SYFDIO Error: Type is invalid in IsAPractice_Details_Rec';
   SInvalidEOR         = 'SYFDIO Error: EOR is missing in IsAPractice_Details_Rec';
   SUnknownToken       = 'SYFDIO Error: Unknown token %d in Read_Practice_Details_Rec';
   SInsufficientMemory = 'SYFDIO Error: Out of memory in New_Practice_Details_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkfdPractice_Name_for_Reports        = 12 ;
   tkfdPractice_EMail_Address           = 13 ;
   tkfdAccounting_System_Used           = 14 ;
   tkfdCountry                          = 15 ;
   tkfdLoad_Client_Files_From           = 16 ;
   tkfdSave_Client_Files_To             = 17 ;
   tkfdShort_Name                       = 18 ;
   tkfdLong_Name                        = 19 ;
   tkfdGST_Class_Names                  = 20 ;
   tkfdGST_Class_Types                  = 21 ;
   tkfdGST_Account_Codes                = 22 ;
   tkfdGST_Rates                        = 23 ;
   tkfdGST_Applies_From                 = 24 ;
   tkfdDate_of_Last_Entry_Received      = 25 ;
   tkfdPrint_Reports_Up_To              = 26 ;
   tkfdSpare_Boolean_3                  = 27 ;
   tkfdPrint_Staff_Member_Header_Page   = 28 ;
   tkfdPrint_Client_Header_Page         = 29 ;
   tkfdPIN_Number                       = 30 ;
   tkfdBankLink_Code                    = 31 ;
   tkfdDisk_Sequence_No                 = 32 ;
   tkfdMagic_Number                     = 33 ;
   tkfdCoding_Report_Style              = 34 ;
   tkfdCoding_Report_Sort_Order         = 35 ;
   tkfdCoding_Report_Entry_Selection    = 36 ;
   tkfdCoding_Report_Blank_Lines        = 37 ;
   tkfdCoding_Report_Rule_Line          = 38 ;
   tkfdBank_Account_LRN_Counter         = 39 ;
   tkfdUser_LRN_Counter                 = 40 ;
   tkfdTransaction_LRN_Counter          = 41 ;
   tkfdClient_File_LRN_Counter          = 42 ;
   tkfdBankLink_Connect_Password        = 43 ;
   tkfdOld_GST_Class_Codes              = 44 ;
   tkfdAccount_Code_Mask                = 45 ;
   tkfdFile_Version                     = 46 ;
   tkfdSched_Rep_Email_Subject          = 47 ;
   tkfdOld_Sched_Rep_Email_Line1        = 48 ;
   tkfdOld_Sched_Rep_Email_Line2        = 49 ;
   tkfdOLD_BAS_Special_Accounts         = 50 ;
   tkfdGST_Class_Codes                  = 51 ;
   tkfdBAS_Field_Number                 = 52 ;
   tkfdBAS_Field_Source                 = 53 ;
   tkfdBAS_Field_Account_Code           = 54 ;
   tkfdBAS_Field_Balance                = 55 ;
   tkfdSched_Rep_Include_Email          = 56 ;
   tkfdSched_Rep_Email_Only             = 57 ;
   tkfdSched_Rep_Include_Printer        = 58 ;
   tkfdSched_Rep_Include_Fax            = 59 ;
   tkfdSched_Rep_Send_Fax_Off_Peak      = 60 ;
   tkfdEnhanced_Software_Options        = 61 ;
   tkfdSched_Rep_Include_ECoding        = 62 ;
   tkfdSched_Rep_Cover_Page_Name        = 63 ;
   tkfdSched_Rep_Cover_Page_Subject     = 64 ;
   tkfdSched_Rep_Cover_Page_Message     = 65 ;
   tkfdSched_Rep_Email_Message          = 66 ;
   tkfdDownload_Report_Options          = 67 ;
   tkfdDownload_Report_Hide_Deleted     = 68 ;
   tkfdBulk_Export_Enabled              = 69 ;
   tkfdSpare_Byte_0                     = 70 ;
   tkfdBulk_Export_Code                 = 71 ;
   tkfdSched_Rep_Include_CSV_Export     = 72 ;
   tkfdTax_Interface_Used               = 73 ;
   tkfdSave_Tax_Files_To                = 74 ;
   tkfdLast_Disk_Image_Version          = 75 ;
   tkfdPractice_Web_Site                = 76 ;
   tkfdPractice_Phone                   = 77 ;
   tkfdPractice_Logo_Filename           = 78 ;
   tkfdSched_Rep_Print_Custom_Doc_GUID  = 79 ;
   tkfdSched_Rep_Print_Custom_Doc       = 80 ;
   tkfdLast_ChargeFile_Date             = 81 ;
   tkfdAudit_Record_ID                  = 82 ;
   tkfdSched_Rep_Fax_Custom_Doc_GUID    = 83 ;
   tkfdSched_Rep_Fax_Custom_Doc         = 84 ;
   tkfdSpare_Text_3                     = 85 ;
   tkfdSched_Rep_Email_Custom_Doc_GUID  = 86 ;
   tkfdSched_Rep_Email_Custom_Doc       = 87 ;
   tkfdSpare_Text_5                     = 88 ;
   tkfdSched_Rep_Books_Custom_Doc_GUID  = 89 ;
   tkfdSched_Rep_Books_Custom_Doc       = 90 ;
   tkfdSpare_Integer_3                  = 91 ;
   tkfdSpare_Integer_4                  = 92 ;
   tkfdSched_Rep_Notes_Custom_Doc_GUID  = 93 ;
   tkfdSched_Rep_Notes_Custom_Doc       = 94 ;
   tkfdSpare_Text_8                     = 95 ;
   tkfdSched_Rep_WebNotes_Custom_Doc_GUID = 96 ;
   tkfdSched_Rep_WebNotes_Custom_Doc    = 97 ;
   tkfdSpare_Integer_5                  = 98 ;
   tkfdSpare_Integer_6                  = 99 ;
   tkfdSpare_Text_10                    = 100 ;
   tkfdSpare_Byte_7                     = 101 ;
   tkfdSpare_Text_11                    = 102 ;
   tkfdSpare_Text_12                    = 103 ;
   tkfdSpare_Byte_8                     = 104 ;
   tkfdSpare_Text_13                    = 105 ;
   tkfdSpare_Text_14                    = 106 ;
   tkfdSpare_Byte_9                     = 107 ;
   tkfdSpare_Integer_7                  = 108 ;
   tkfdSpare_Integer_8                  = 109 ;
   tkfdSched_Rep_WebNotes_Subject       = 110 ;
   tkfdSpare_Byte_10                    = 111 ;
   tkfdSched_Rep_webNotes_Message       = 112 ;
   tkfdSpare_Byte_11                    = 113 ;
   tkfdSched_Rep_Header_Message         = 114 ;
   tkfdSched_Rep_BNotes_Subject         = 115 ;
   tkfdSched_Rep_BNotes_Message         = 116 ;
   tkfdSpare_Boolean_4                  = 117 ;
   tkfdTask_Tracking_Prompt_Type        = 118 ;
   tkfdSpare_Bool_1                     = 119 ;
   tkfdSpare_Bool_2                     = 120 ;
   tkfdSpare_Integer_9                  = 121 ;
   tkfdSched_Rep_Fax_Transport          = 122 ;
   tkfdSched_Rep_Include_WebX           = 123 ;
   tkfdWeb_Export_Format                = 124 ;
   tkfdForce_Login                      = 125 ;
   tkfdLogin_Bitmap_Filename            = 126 ;
   tkfdAuto_Print_Sched_Rep_Summary     = 127 ;
   tkfdIgnore_Quantity_In_Download      = 128 ;
   tkfdSpare_Boolean_1                  = 129 ;
   tkfdspare_Boolean_2                  = 130 ;
   tkfdCopy_Dissection_Narration        = 131 ;
   tkfdRound_Cashflow_Reports           = 132 ;
   tkfdUse_Xlon_Chart_Order             = 133 ;
   tkfdExtract_Multiple_Accounts_PA     = 134 ;
   tkfdExtract_Journal_Accounts_PA      = 135 ;
   tkfdExtract_Quantity                 = 136 ;
   tkfdReports_New_Page                 = 137 ;
   tkfdPrint_Merge_Report_Summary       = 138 ;
   tkfdEmail_Merge_Report_Summary       = 139 ;
   tkfdMaximum_Narration_Extract        = 140 ;
   tkfdSched_Rep_Include_CheckOut       = 141 ;
   tkfdSched_Rep_CheckOut_Subject       = 142 ;
   tkfdSched_Rep_CheckOut_Message       = 143 ;
   tkfdSched_Rep_Include_Business_Products = 144 ;
   tkfdSched_Rep_Business_Products_Subject = 145 ;
   tkfdSched_Rep_Business_Products_Message = 146 ;
   tkfdReplace_Narration_With_Payee     = 147 ;
   tkfdLast_Export_Charges_Saved_To     = 148 ;
   tkfdManual_Account_XML               = 149 ;
   tkfdUpdates_Pending                  = 150 ;
   tkfdUpdate_Server_For_Offsites       = 151 ;
   tkfdCollect_Usage_Data               = 152 ;
   tkfdFixed_Charge_Increase            = 153 ;
   tkfdPercentage_Charge_Increase       = 154 ;
   tkfdFixed_Dollar_Amount              = 155 ;
   tkfdDistributed_Dollar_Amount        = 156 ;
   tkfdPercentage_Increase_Amount       = 157 ;
   tkfdExtract_Quantity_Decimal_Places  = 158 ;
   tkfdExport_Charges_Remarks           = 159 ;
   tkfdSystem_Report_Password           = 160 ;
   tkfdPrint_Reports_From               = 161 ;
   tkfdHighest_Date_Ever_Downloaded     = 162 ;
   tkfdAuto_Retrieve_New_Transactions   = 163 ;
   tkfdCoding_Font                      = 164 ;
   tkfdSort_Reports_Option              = 165 ;
   tkfdSpare_Byte_12                    = 166 ;
   tkfdGroup_LRN_Counter                = 167 ;
   tkfdClient_Type_LRN_Counter          = 168 ;
   tkfdTAX_Applies_From                 = 169 ;
   tkfdTAX_Rates                        = 170 ;
   tkfdSuperfund_System                 = 171 ;
   tkfdSuperfund_Code_Mask              = 172 ;
   tkfdLoad_Client_Super_Files_From     = 173 ;
   tkfdSave_Client_Super_Files_To       = 174 ;
   tkfdSort_Reports_By                  = 175 ;
   tkfdSet_Fixed_Dollar_Amount          = 176 ;
   tkfdPrint_Group_Header_Page          = 177 ;
   tkfdPrint_Client_Type_Header_Page    = 178 ;
   tkfdPractice_Management_System       = 179 ;
   tkfdAutomatic_Task_Creation_Flags    = 180 ;
   tkfdAutomatic_Task_Reminder_Delay    = 181 ;
   tkfdAutomatic_Task_Closing_Flags     = 182 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPractice_Details_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPractice_Details_Rec ( P )^ do Begin
      If fdRecord_Type <> tkBegin_Practice_Details then
         Raise ECorruptData.Create( SInvalidType );
      If fdEOR <> tkEnd_Practice_Details then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Practice_Details_Rec ( Var O : TPractice_Details_Rec ; Var F : TIOStream );

Var
   I     : Byte;
   I1    : Byte;
   I2    : Byte;

Begin
   If IsAPractice_Details_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Practice_Details );
      F.WriteStringValue( tkfdPractice_Name_for_Reports , fdPractice_Name_for_Reports );
      F.WriteStringValue( tkfdPractice_EMail_Address , fdPractice_EMail_Address );
      F.WriteByteValue( tkfdAccounting_System_Used , fdAccounting_System_Used );
      F.WriteByteValue( tkfdCountry , fdCountry );
      F.WriteStringValue( tkfdLoad_Client_Files_From , fdLoad_Client_Files_From );
      F.WriteStringValue( tkfdSave_Client_Files_To , fdSave_Client_Files_To );
      For i := 0 to 100 do F.WriteBStringValue( tkfdShort_Name , i, fdShort_Name[ i ] );
      For i := 0 to 100 do F.WriteBStringValue( tkfdLong_Name , i, fdLong_Name[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkfdGST_Class_Names , i, fdGST_Class_Names[ i ] );
      For i := 1 to 99 do F.WriteBByteValue( tkfdGST_Class_Types , i, fdGST_Class_Types[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkfdGST_Account_Codes , i, fdGST_Account_Codes[ i ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkfdGST_Rates , I1, I2, fdGST_Rates[ I1, I2 ] );
      For i := 1 to 5 do F.WriteBDateValue( tkfdGST_Applies_From , i, fdGST_Applies_From[ i ] );
      F.WriteDateValue( tkfdDate_of_Last_Entry_Received , fdDate_of_Last_Entry_Received );
      F.WriteDateValue( tkfdPrint_Reports_Up_To , fdPrint_Reports_Up_To );
      F.WriteBooleanValue( tkfdSpare_Boolean_3 , fdSpare_Boolean_3 );
      F.WriteBooleanValue( tkfdPrint_Staff_Member_Header_Page , fdPrint_Staff_Member_Header_Page );
      F.WriteBooleanValue( tkfdPrint_Client_Header_Page , fdPrint_Client_Header_Page );
      F.WriteIntegerValue( tkfdPIN_Number , fdPIN_Number );
      F.WriteStringValue( tkfdBankLink_Code , fdBankLink_Code );
      F.WriteIntegerValue( tkfdDisk_Sequence_No , fdDisk_Sequence_No );
      F.WriteIntegerValue( tkfdMagic_Number , fdMagic_Number );
      F.WriteByteValue( tkfdCoding_Report_Style , fdCoding_Report_Style );
      F.WriteByteValue( tkfdCoding_Report_Sort_Order , fdCoding_Report_Sort_Order );
      F.WriteByteValue( tkfdCoding_Report_Entry_Selection , fdCoding_Report_Entry_Selection );
      F.WriteByteValue( tkfdCoding_Report_Blank_Lines , fdCoding_Report_Blank_Lines );
      F.WriteBooleanValue( tkfdCoding_Report_Rule_Line , fdCoding_Report_Rule_Line );
      F.WriteIntegerValue( tkfdBank_Account_LRN_Counter , fdBank_Account_LRN_Counter );
      F.WriteIntegerValue( tkfdUser_LRN_Counter , fdUser_LRN_Counter );
      F.WriteIntegerValue( tkfdTransaction_LRN_Counter , fdTransaction_LRN_Counter );
      F.WriteIntegerValue( tkfdClient_File_LRN_Counter , fdClient_File_LRN_Counter );
      F.WriteStringValue( tkfdBankLink_Connect_Password , fdBankLink_Connect_Password );
      F.WriteStringValue( tkfdOld_GST_Class_Codes , fdOld_GST_Class_Codes );
      F.WriteStringValue( tkfdAccount_Code_Mask , fdAccount_Code_Mask );
      F.WriteIntegerValue( tkfdFile_Version , fdFile_Version );
      F.WriteStringValue( tkfdSched_Rep_Email_Subject , fdSched_Rep_Email_Subject );
      F.WriteStringValue( tkfdOld_Sched_Rep_Email_Line1 , fdOld_Sched_Rep_Email_Line1 );
      F.WriteStringValue( tkfdOld_Sched_Rep_Email_Line2 , fdOld_Sched_Rep_Email_Line2 );
      For i := 1 to 10 do F.WriteBStringValue( tkfdOLD_BAS_Special_Accounts , i, fdOLD_BAS_Special_Accounts[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkfdGST_Class_Codes , i, fdGST_Class_Codes[ i ] );
      For i := 1 to 100 do F.WriteBByteValue( tkfdBAS_Field_Number , i, fdBAS_Field_Number[ i ] );
      For i := 1 to 100 do F.WriteBByteValue( tkfdBAS_Field_Source , i, fdBAS_Field_Source[ i ] );
      For i := 1 to 100 do F.WriteBStringValue( tkfdBAS_Field_Account_Code , i, fdBAS_Field_Account_Code[ i ] );
      For i := 1 to 100 do F.WriteBByteValue( tkfdBAS_Field_Balance , i, fdBAS_Field_Balance[ i ] );
      F.WriteBooleanValue( tkfdSched_Rep_Include_Email , fdSched_Rep_Include_Email );
      F.WriteBooleanValue( tkfdSched_Rep_Email_Only , fdSched_Rep_Email_Only );
      F.WriteBooleanValue( tkfdSched_Rep_Include_Printer , fdSched_Rep_Include_Printer );
      F.WriteBooleanValue( tkfdSched_Rep_Include_Fax , fdSched_Rep_Include_Fax );
      F.WriteBooleanValue( tkfdSched_Rep_Send_Fax_Off_Peak , fdSched_Rep_Send_Fax_Off_Peak );
      For i := 1 to 20 do F.WriteBBooleanValue( tkfdEnhanced_Software_Options , i, fdEnhanced_Software_Options[ i ] );
      F.WriteBooleanValue( tkfdSched_Rep_Include_ECoding , fdSched_Rep_Include_ECoding );
      F.WriteAnsiStringValue( tkfdSched_Rep_Cover_Page_Name , fdSched_Rep_Cover_Page_Name );
      F.WriteStringValue( tkfdSched_Rep_Cover_Page_Subject , fdSched_Rep_Cover_Page_Subject );
      F.WriteAnsiStringValue( tkfdSched_Rep_Cover_Page_Message , fdSched_Rep_Cover_Page_Message );
      F.WriteAnsiStringValue( tkfdSched_Rep_Email_Message , fdSched_Rep_Email_Message );
      F.WriteIntegerValue( tkfdDownload_Report_Options , fdDownload_Report_Options );
      F.WriteBooleanValue( tkfdDownload_Report_Hide_Deleted , fdDownload_Report_Hide_Deleted );
      F.WriteBooleanValue( tkfdBulk_Export_Enabled , fdBulk_Export_Enabled );
      F.WriteByteValue( tkfdSpare_Byte_0 , fdSpare_Byte_0 );
      F.WriteAnsiStringValue( tkfdBulk_Export_Code , fdBulk_Export_Code );
      F.WriteBooleanValue( tkfdSched_Rep_Include_CSV_Export , fdSched_Rep_Include_CSV_Export );
      F.WriteByteValue( tkfdTax_Interface_Used , fdTax_Interface_Used );
      F.WriteAnsiStringValue( tkfdSave_Tax_Files_To , fdSave_Tax_Files_To );
      F.WriteIntegerValue( tkfdLast_Disk_Image_Version , fdLast_Disk_Image_Version );
      F.WriteAnsiStringValue( tkfdPractice_Web_Site , fdPractice_Web_Site );
      F.WriteStringValue( tkfdPractice_Phone , fdPractice_Phone );
      F.WriteAnsiStringValue( tkfdPractice_Logo_Filename , fdPractice_Logo_Filename );
      F.WriteAnsiStringValue( tkfdSched_Rep_Print_Custom_Doc_GUID , fdSched_Rep_Print_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_Print_Custom_Doc , fdSched_Rep_Print_Custom_Doc );
      F.WriteIntegerValue( tkfdLast_ChargeFile_Date , fdLast_ChargeFile_Date );
      F.WriteIntegerValue( tkfdAudit_Record_ID , fdAudit_Record_ID );
      F.WriteAnsiStringValue( tkfdSched_Rep_Fax_Custom_Doc_GUID , fdSched_Rep_Fax_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_Fax_Custom_Doc , fdSched_Rep_Fax_Custom_Doc );
      F.WriteAnsiStringValue( tkfdSpare_Text_3 , fdSpare_Text_3 );
      F.WriteAnsiStringValue( tkfdSched_Rep_Email_Custom_Doc_GUID , fdSched_Rep_Email_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_Email_Custom_Doc , fdSched_Rep_Email_Custom_Doc );
      F.WriteAnsiStringValue( tkfdSpare_Text_5 , fdSpare_Text_5 );
      F.WriteAnsiStringValue( tkfdSched_Rep_Books_Custom_Doc_GUID , fdSched_Rep_Books_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_Books_Custom_Doc , fdSched_Rep_Books_Custom_Doc );
      F.WriteIntegerValue( tkfdSpare_Integer_3 , fdSpare_Integer_3 );
      F.WriteIntegerValue( tkfdSpare_Integer_4 , fdSpare_Integer_4 );
      F.WriteAnsiStringValue( tkfdSched_Rep_Notes_Custom_Doc_GUID , fdSched_Rep_Notes_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_Notes_Custom_Doc , fdSched_Rep_Notes_Custom_Doc );
      F.WriteAnsiStringValue( tkfdSpare_Text_8 , fdSpare_Text_8 );
      F.WriteAnsiStringValue( tkfdSched_Rep_WebNotes_Custom_Doc_GUID , fdSched_Rep_WebNotes_Custom_Doc_GUID );
      F.WriteByteValue( tkfdSched_Rep_WebNotes_Custom_Doc , fdSched_Rep_WebNotes_Custom_Doc );
      F.WriteIntegerValue( tkfdSpare_Integer_5 , fdSpare_Integer_5 );
      F.WriteIntegerValue( tkfdSpare_Integer_6 , fdSpare_Integer_6 );
      F.WriteAnsiStringValue( tkfdSpare_Text_10 , fdSpare_Text_10 );
      F.WriteByteValue( tkfdSpare_Byte_7 , fdSpare_Byte_7 );
      F.WriteAnsiStringValue( tkfdSpare_Text_11 , fdSpare_Text_11 );
      F.WriteAnsiStringValue( tkfdSpare_Text_12 , fdSpare_Text_12 );
      F.WriteByteValue( tkfdSpare_Byte_8 , fdSpare_Byte_8 );
      F.WriteAnsiStringValue( tkfdSpare_Text_13 , fdSpare_Text_13 );
      F.WriteAnsiStringValue( tkfdSpare_Text_14 , fdSpare_Text_14 );
      F.WriteByteValue( tkfdSpare_Byte_9 , fdSpare_Byte_9 );
      F.WriteIntegerValue( tkfdSpare_Integer_7 , fdSpare_Integer_7 );
      F.WriteIntegerValue( tkfdSpare_Integer_8 , fdSpare_Integer_8 );
      F.WriteAnsiStringValue( tkfdSched_Rep_WebNotes_Subject , fdSched_Rep_WebNotes_Subject );
      F.WriteByteValue( tkfdSpare_Byte_10 , fdSpare_Byte_10 );
      F.WriteAnsiStringValue( tkfdSched_Rep_webNotes_Message , fdSched_Rep_webNotes_Message );
      F.WriteByteValue( tkfdSpare_Byte_11 , fdSpare_Byte_11 );
      F.WriteAnsiStringValue( tkfdSched_Rep_Header_Message , fdSched_Rep_Header_Message );
      F.WriteStringValue( tkfdSched_Rep_BNotes_Subject , fdSched_Rep_BNotes_Subject );
      F.WriteAnsiStringValue( tkfdSched_Rep_BNotes_Message , fdSched_Rep_BNotes_Message );
      F.WriteBooleanValue( tkfdSpare_Boolean_4 , fdSpare_Boolean_4 );
      F.WriteByteValue( tkfdTask_Tracking_Prompt_Type , fdTask_Tracking_Prompt_Type );
      F.WriteBooleanValue( tkfdSpare_Bool_1 , fdSpare_Bool_1 );
      F.WriteBooleanValue( tkfdSpare_Bool_2 , fdSpare_Bool_2 );
      F.WriteIntegerValue( tkfdSpare_Integer_9 , fdSpare_Integer_9 );
      F.WriteByteValue( tkfdSched_Rep_Fax_Transport , fdSched_Rep_Fax_Transport );
      F.WriteBooleanValue( tkfdSched_Rep_Include_WebX , fdSched_Rep_Include_WebX );
      F.WriteByteValue( tkfdWeb_Export_Format , fdWeb_Export_Format );
      F.WriteBooleanValue( tkfdForce_Login , fdForce_Login );
      F.WriteStringValue( tkfdLogin_Bitmap_Filename , fdLogin_Bitmap_Filename );
      F.WriteBooleanValue( tkfdAuto_Print_Sched_Rep_Summary , fdAuto_Print_Sched_Rep_Summary );
      F.WriteBooleanValue( tkfdIgnore_Quantity_In_Download , fdIgnore_Quantity_In_Download );
      F.WriteByteValue( tkfdSpare_Boolean_1 , fdSpare_Boolean_1 );
      F.WriteByteValue( tkfdspare_Boolean_2 , fdspare_Boolean_2 );
      F.WriteBooleanValue( tkfdCopy_Dissection_Narration , fdCopy_Dissection_Narration );
      F.WriteBooleanValue( tkfdRound_Cashflow_Reports , fdRound_Cashflow_Reports );
      F.WriteBooleanValue( tkfdUse_Xlon_Chart_Order , fdUse_Xlon_Chart_Order );
      F.WriteBooleanValue( tkfdExtract_Multiple_Accounts_PA , fdExtract_Multiple_Accounts_PA );
      F.WriteBooleanValue( tkfdExtract_Journal_Accounts_PA , fdExtract_Journal_Accounts_PA );
      F.WriteBooleanValue( tkfdExtract_Quantity , fdExtract_Quantity );
      F.WriteBooleanValue( tkfdReports_New_Page , fdReports_New_Page );
      F.WriteByteValue( tkfdPrint_Merge_Report_Summary , fdPrint_Merge_Report_Summary );
      F.WriteByteValue( tkfdEmail_Merge_Report_Summary , fdEmail_Merge_Report_Summary );
      F.WriteIntegerValue( tkfdMaximum_Narration_Extract , fdMaximum_Narration_Extract );
      F.WriteBooleanValue( tkfdSched_Rep_Include_CheckOut , fdSched_Rep_Include_CheckOut );
      F.WriteStringValue( tkfdSched_Rep_CheckOut_Subject , fdSched_Rep_CheckOut_Subject );
      F.WriteAnsiStringValue( tkfdSched_Rep_CheckOut_Message , fdSched_Rep_CheckOut_Message );
      F.WriteBooleanValue( tkfdSched_Rep_Include_Business_Products , fdSched_Rep_Include_Business_Products );
      F.WriteStringValue( tkfdSched_Rep_Business_Products_Subject , fdSched_Rep_Business_Products_Subject );
      F.WriteAnsiStringValue( tkfdSched_Rep_Business_Products_Message , fdSched_Rep_Business_Products_Message );
      F.WriteBooleanValue( tkfdReplace_Narration_With_Payee , fdReplace_Narration_With_Payee );
      F.WriteAnsiStringValue( tkfdLast_Export_Charges_Saved_To , fdLast_Export_Charges_Saved_To );
      F.WriteAnsiStringValue( tkfdManual_Account_XML , fdManual_Account_XML );
      F.WriteBooleanValue( tkfdUpdates_Pending , fdUpdates_Pending );
      F.WriteAnsiStringValue( tkfdUpdate_Server_For_Offsites , fdUpdate_Server_For_Offsites );
      F.WriteBooleanValue( tkfdCollect_Usage_Data , fdCollect_Usage_Data );
      F.WriteBooleanValue( tkfdFixed_Charge_Increase , fdFixed_Charge_Increase );
      F.WriteBooleanValue( tkfdPercentage_Charge_Increase , fdPercentage_Charge_Increase );
      F.WriteMoneyValue( tkfdFixed_Dollar_Amount , fdFixed_Dollar_Amount );
      F.WriteMoneyValue( tkfdDistributed_Dollar_Amount , fdDistributed_Dollar_Amount );
      F.WriteMoneyValue( tkfdPercentage_Increase_Amount , fdPercentage_Increase_Amount );
      F.WriteByteValue( tkfdExtract_Quantity_Decimal_Places , fdExtract_Quantity_Decimal_Places );
      F.WriteAnsiStringValue( tkfdExport_Charges_Remarks , fdExport_Charges_Remarks );
      F.WriteStringValue( tkfdSystem_Report_Password , fdSystem_Report_Password );
      F.WriteDateValue( tkfdPrint_Reports_From , fdPrint_Reports_From );
      F.WriteDateValue( tkfdHighest_Date_Ever_Downloaded , fdHighest_Date_Ever_Downloaded );
      F.WriteBooleanValue( tkfdAuto_Retrieve_New_Transactions , fdAuto_Retrieve_New_Transactions );
      F.WriteAnsiStringValue( tkfdCoding_Font , fdCoding_Font );
      F.WriteByteValue( tkfdSort_Reports_Option , fdSort_Reports_Option );
      F.WriteByteValue( tkfdSpare_Byte_12 , fdSpare_Byte_12 );
      F.WriteIntegerValue( tkfdGroup_LRN_Counter , fdGroup_LRN_Counter );
      F.WriteIntegerValue( tkfdClient_Type_LRN_Counter , fdClient_Type_LRN_Counter );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBDateValue( tkfdTAX_Applies_From , I1, I2, fdTAX_Applies_From[ I1, I2 ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkfdTAX_Rates , I1, I2, fdTAX_Rates[ I1, I2 ] );
      F.WriteByteValue( tkfdSuperfund_System , fdSuperfund_System );
      F.WriteStringValue( tkfdSuperfund_Code_Mask , fdSuperfund_Code_Mask );
      F.WriteStringValue( tkfdLoad_Client_Super_Files_From , fdLoad_Client_Super_Files_From );
      F.WriteStringValue( tkfdSave_Client_Super_Files_To , fdSave_Client_Super_Files_To );
      F.WriteIntegerValue( tkfdSort_Reports_By , fdSort_Reports_By );
      F.WriteMoneyValue( tkfdSet_Fixed_Dollar_Amount , fdSet_Fixed_Dollar_Amount );
      F.WriteBooleanValue( tkfdPrint_Group_Header_Page , fdPrint_Group_Header_Page );
      F.WriteBooleanValue( tkfdPrint_Client_Type_Header_Page , fdPrint_Client_Type_Header_Page );
      F.WriteByteValue( tkfdPractice_Management_System , fdPractice_Management_System );
      For i := 1 to 7 do F.WriteBBooleanValue( tkfdAutomatic_Task_Creation_Flags , i, fdAutomatic_Task_Creation_Flags[ i ] );
      For i := 1 to 7 do
         F.WriteBIntegerValue( tkfdAutomatic_Task_Reminder_Delay , i, fdAutomatic_Task_Reminder_Delay[ i ] );
      For i := 1 to 7 do F.WriteBBooleanValue( tkfdAutomatic_Task_Closing_Flags , i, fdAutomatic_Task_Closing_Flags[ i ] );
      F.WriteToken( tkEnd_Practice_Details );
   end;
end; { of Write_Practice_Details_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Practice_Details_Rec ( Var O : TPractice_Details_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   I1    : Byte;
   I2    : Byte;
   L     : Integer;
   M     : Money;
   B     : Byte;   
   D     : Integer;
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, Practice_Details_Rec_Size, 0 );
   O.fdRecord_Type := tkBegin_Practice_Details;
   O.fdEOR := tkEnd_Practice_Details;
   Token := tkBegin_Practice_Details;

   While Token <> tkEnd_Practice_Details do With O do
   Begin
      Case Token of
         tkBegin_Practice_Details :; { Do Nothing }
         tkEnd_Practice_Details :; { Do Nothing }
         tkfdPractice_Name_for_Reports        : fdPractice_Name_for_Reports := F.ReadStringValue;
         tkfdPractice_EMail_Address           : fdPractice_EMail_Address := F.ReadStringValue;
         tkfdAccounting_System_Used           : fdAccounting_System_Used := F.ReadByteValue;
         tkfdCountry                          : fdCountry := F.ReadByteValue;
         tkfdLoad_Client_Files_From           : fdLoad_Client_Files_From := F.ReadStringValue;
         tkfdSave_Client_Files_To             : fdSave_Client_Files_To := F.ReadStringValue;
         tkfdShort_Name                       : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 100, 'fdShort_Name' );
               fdShort_Name[ I ] := S;
            end;
         tkfdLong_Name                        : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 100, 'fdLong_Name' );
               fdLong_Name[ I ] := S;
            end;
         tkfdGST_Class_Names                  : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'fdGST_Class_Names' );
               fdGST_Class_Names[ I ] := S;
            end;
         tkfdGST_Class_Types                  : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 99, 'fdGST_Class_Types' );
               fdGST_Class_Types[ I ] := B;
            end;
         tkfdGST_Account_Codes                : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'fdGST_Account_Codes' );
               fdGST_Account_Codes[ I ] := S;
            end;
         tkfdGST_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'fdGST_Rates' );
               CheckBounds( I2, 1, 5, 'fdGST_Rates' );
               fdGST_Rates[ I1, I2 ] := M;
            end;
         tkfdGST_Applies_From                 : 
            Begin
               D := F.ReadBDateValue( I );
               CheckBounds( I, 1, 5, 'fdGST_Applies_From' );
               fdGST_Applies_From[ I ] := D;
            end;
         tkfdDate_of_Last_Entry_Received      : fdDate_of_Last_Entry_Received := F.ReadDateValue;
         tkfdPrint_Reports_Up_To              : fdPrint_Reports_Up_To := F.ReadDateValue;
         tkfdSpare_Boolean_3                  : fdSpare_Boolean_3 := F.ReadBooleanValue;
         tkfdPrint_Staff_Member_Header_Page   : fdPrint_Staff_Member_Header_Page := F.ReadBooleanValue;
         tkfdPrint_Client_Header_Page         : fdPrint_Client_Header_Page := F.ReadBooleanValue;
         tkfdPIN_Number                       : fdPIN_Number := F.ReadIntegerValue;
         tkfdBankLink_Code                    : fdBankLink_Code := F.ReadStringValue;
         tkfdDisk_Sequence_No                 : fdDisk_Sequence_No := F.ReadIntegerValue;
         tkfdMagic_Number                     : fdMagic_Number := F.ReadIntegerValue;
         tkfdCoding_Report_Style              : fdCoding_Report_Style := F.ReadByteValue;
         tkfdCoding_Report_Sort_Order         : fdCoding_Report_Sort_Order := F.ReadByteValue;
         tkfdCoding_Report_Entry_Selection    : fdCoding_Report_Entry_Selection := F.ReadByteValue;
         tkfdCoding_Report_Blank_Lines        : fdCoding_Report_Blank_Lines := F.ReadByteValue;
         tkfdCoding_Report_Rule_Line          : fdCoding_Report_Rule_Line := F.ReadBooleanValue;
         tkfdBank_Account_LRN_Counter         : fdBank_Account_LRN_Counter := F.ReadIntegerValue;
         tkfdUser_LRN_Counter                 : fdUser_LRN_Counter := F.ReadIntegerValue;
         tkfdTransaction_LRN_Counter          : fdTransaction_LRN_Counter := F.ReadIntegerValue;
         tkfdClient_File_LRN_Counter          : fdClient_File_LRN_Counter := F.ReadIntegerValue;
         tkfdBankLink_Connect_Password        : fdBankLink_Connect_Password := F.ReadStringValue;
         tkfdOld_GST_Class_Codes              : fdOld_GST_Class_Codes := F.ReadStringValue;
         tkfdAccount_Code_Mask                : fdAccount_Code_Mask := F.ReadStringValue;
         tkfdFile_Version                     : fdFile_Version := F.ReadIntegerValue;
         tkfdSched_Rep_Email_Subject          : fdSched_Rep_Email_Subject := F.ReadStringValue;
         tkfdOld_Sched_Rep_Email_Line1        : fdOld_Sched_Rep_Email_Line1 := F.ReadStringValue;
         tkfdOld_Sched_Rep_Email_Line2        : fdOld_Sched_Rep_Email_Line2 := F.ReadStringValue;
         tkfdOLD_BAS_Special_Accounts         : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 10, 'fdOLD_BAS_Special_Accounts' );
               fdOLD_BAS_Special_Accounts[ I ] := S;
            end;
         tkfdGST_Class_Codes                  : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'fdGST_Class_Codes' );
               fdGST_Class_Codes[ I ] := S;
            end;
         tkfdBAS_Field_Number                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'fdBAS_Field_Number' );
               fdBAS_Field_Number[ I ] := B;
            end;
         tkfdBAS_Field_Source                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'fdBAS_Field_Source' );
               fdBAS_Field_Source[ I ] := B;
            end;
         tkfdBAS_Field_Account_Code           : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 100, 'fdBAS_Field_Account_Code' );
               fdBAS_Field_Account_Code[ I ] := S;
            end;
         tkfdBAS_Field_Balance                : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'fdBAS_Field_Balance' );
               fdBAS_Field_Balance[ I ] := B;
            end;
         tkfdSched_Rep_Include_Email          : fdSched_Rep_Include_Email := F.ReadBooleanValue;
         tkfdSched_Rep_Email_Only             : fdSched_Rep_Email_Only := F.ReadBooleanValue;
         tkfdSched_Rep_Include_Printer        : fdSched_Rep_Include_Printer := F.ReadBooleanValue;
         tkfdSched_Rep_Include_Fax            : fdSched_Rep_Include_Fax := F.ReadBooleanValue;
         tkfdSched_Rep_Send_Fax_Off_Peak      : fdSched_Rep_Send_Fax_Off_Peak := F.ReadBooleanValue;
         tkfdEnhanced_Software_Options        : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 20, 'fdEnhanced_Software_Options' );
               fdEnhanced_Software_Options[ I ] := Y;
            end;
         tkfdSched_Rep_Include_ECoding        : fdSched_Rep_Include_ECoding := F.ReadBooleanValue;
         tkfdSched_Rep_Cover_Page_Name        : fdSched_Rep_Cover_Page_Name := F.ReadAnsiStringValue;
         tkfdSched_Rep_Cover_Page_Subject     : fdSched_Rep_Cover_Page_Subject := F.ReadStringValue;
         tkfdSched_Rep_Cover_Page_Message     : fdSched_Rep_Cover_Page_Message := F.ReadAnsiStringValue;
         tkfdSched_Rep_Email_Message          : fdSched_Rep_Email_Message := F.ReadAnsiStringValue;
         tkfdDownload_Report_Options          : fdDownload_Report_Options := F.ReadIntegerValue;
         tkfdDownload_Report_Hide_Deleted     : fdDownload_Report_Hide_Deleted := F.ReadBooleanValue;
         tkfdBulk_Export_Enabled              : fdBulk_Export_Enabled := F.ReadBooleanValue;
         tkfdSpare_Byte_0                     : fdSpare_Byte_0 := F.ReadByteValue;
         tkfdBulk_Export_Code                 : fdBulk_Export_Code := F.ReadAnsiStringValue;
         tkfdSched_Rep_Include_CSV_Export     : fdSched_Rep_Include_CSV_Export := F.ReadBooleanValue;
         tkfdTax_Interface_Used               : fdTax_Interface_Used := F.ReadByteValue;
         tkfdSave_Tax_Files_To                : fdSave_Tax_Files_To := F.ReadAnsiStringValue;
         tkfdLast_Disk_Image_Version          : fdLast_Disk_Image_Version := F.ReadIntegerValue;
         tkfdPractice_Web_Site                : fdPractice_Web_Site := F.ReadAnsiStringValue;
         tkfdPractice_Phone                   : fdPractice_Phone := F.ReadStringValue;
         tkfdPractice_Logo_Filename           : fdPractice_Logo_Filename := F.ReadAnsiStringValue;
         tkfdSched_Rep_Print_Custom_Doc_GUID  : fdSched_Rep_Print_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_Print_Custom_Doc       : fdSched_Rep_Print_Custom_Doc := F.ReadByteValue;
         tkfdLast_ChargeFile_Date             : fdLast_ChargeFile_Date := F.ReadIntegerValue;
         tkfdAudit_Record_ID                  : fdAudit_Record_ID := F.ReadIntegerValue;
         tkfdSched_Rep_Fax_Custom_Doc_GUID    : fdSched_Rep_Fax_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_Fax_Custom_Doc         : fdSched_Rep_Fax_Custom_Doc := F.ReadByteValue;
         tkfdSpare_Text_3                     : fdSpare_Text_3 := F.ReadAnsiStringValue;
         tkfdSched_Rep_Email_Custom_Doc_GUID  : fdSched_Rep_Email_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_Email_Custom_Doc       : fdSched_Rep_Email_Custom_Doc := F.ReadByteValue;
         tkfdSpare_Text_5                     : fdSpare_Text_5 := F.ReadAnsiStringValue;
         tkfdSched_Rep_Books_Custom_Doc_GUID  : fdSched_Rep_Books_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_Books_Custom_Doc       : fdSched_Rep_Books_Custom_Doc := F.ReadByteValue;
         tkfdSpare_Integer_3                  : fdSpare_Integer_3 := F.ReadIntegerValue;
         tkfdSpare_Integer_4                  : fdSpare_Integer_4 := F.ReadIntegerValue;
         tkfdSched_Rep_Notes_Custom_Doc_GUID  : fdSched_Rep_Notes_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_Notes_Custom_Doc       : fdSched_Rep_Notes_Custom_Doc := F.ReadByteValue;
         tkfdSpare_Text_8                     : fdSpare_Text_8 := F.ReadAnsiStringValue;
         tkfdSched_Rep_WebNotes_Custom_Doc_GUID : fdSched_Rep_WebNotes_Custom_Doc_GUID := F.ReadAnsiStringValue;
         tkfdSched_Rep_WebNotes_Custom_Doc    : fdSched_Rep_WebNotes_Custom_Doc := F.ReadByteValue;
         tkfdSpare_Integer_5                  : fdSpare_Integer_5 := F.ReadIntegerValue;
         tkfdSpare_Integer_6                  : fdSpare_Integer_6 := F.ReadIntegerValue;
         tkfdSpare_Text_10                    : fdSpare_Text_10 := F.ReadAnsiStringValue;
         tkfdSpare_Byte_7                     : fdSpare_Byte_7 := F.ReadByteValue;
         tkfdSpare_Text_11                    : fdSpare_Text_11 := F.ReadAnsiStringValue;
         tkfdSpare_Text_12                    : fdSpare_Text_12 := F.ReadAnsiStringValue;
         tkfdSpare_Byte_8                     : fdSpare_Byte_8 := F.ReadByteValue;
         tkfdSpare_Text_13                    : fdSpare_Text_13 := F.ReadAnsiStringValue;
         tkfdSpare_Text_14                    : fdSpare_Text_14 := F.ReadAnsiStringValue;
         tkfdSpare_Byte_9                     : fdSpare_Byte_9 := F.ReadByteValue;
         tkfdSpare_Integer_7                  : fdSpare_Integer_7 := F.ReadIntegerValue;
         tkfdSpare_Integer_8                  : fdSpare_Integer_8 := F.ReadIntegerValue;
         tkfdSched_Rep_WebNotes_Subject       : fdSched_Rep_WebNotes_Subject := F.ReadAnsiStringValue;
         tkfdSpare_Byte_10                    : fdSpare_Byte_10 := F.ReadByteValue;
         tkfdSched_Rep_webNotes_Message       : fdSched_Rep_webNotes_Message := F.ReadAnsiStringValue;
         tkfdSpare_Byte_11                    : fdSpare_Byte_11 := F.ReadByteValue;
         tkfdSched_Rep_Header_Message         : fdSched_Rep_Header_Message := F.ReadAnsiStringValue;
         tkfdSched_Rep_BNotes_Subject         : fdSched_Rep_BNotes_Subject := F.ReadStringValue;
         tkfdSched_Rep_BNotes_Message         : fdSched_Rep_BNotes_Message := F.ReadAnsiStringValue;
         tkfdSpare_Boolean_4                  : fdSpare_Boolean_4 := F.ReadBooleanValue;
         tkfdTask_Tracking_Prompt_Type        : fdTask_Tracking_Prompt_Type := F.ReadByteValue;
         tkfdSpare_Bool_1                     : fdSpare_Bool_1 := F.ReadBooleanValue;
         tkfdSpare_Bool_2                     : fdSpare_Bool_2 := F.ReadBooleanValue;
         tkfdSpare_Integer_9                  : fdSpare_Integer_9 := F.ReadIntegerValue;
         tkfdSched_Rep_Fax_Transport          : fdSched_Rep_Fax_Transport := F.ReadByteValue;
         tkfdSched_Rep_Include_WebX           : fdSched_Rep_Include_WebX := F.ReadBooleanValue;
         tkfdWeb_Export_Format                : fdWeb_Export_Format := F.ReadByteValue;
         tkfdForce_Login                      : fdForce_Login := F.ReadBooleanValue;
         tkfdLogin_Bitmap_Filename            : fdLogin_Bitmap_Filename := F.ReadStringValue;
         tkfdAuto_Print_Sched_Rep_Summary     : fdAuto_Print_Sched_Rep_Summary := F.ReadBooleanValue;
         tkfdIgnore_Quantity_In_Download      : fdIgnore_Quantity_In_Download := F.ReadBooleanValue;
         tkfdSpare_Boolean_1                  : fdSpare_Boolean_1 := F.ReadByteValue;
         tkfdspare_Boolean_2                  : fdspare_Boolean_2 := F.ReadByteValue;
         tkfdCopy_Dissection_Narration        : fdCopy_Dissection_Narration := F.ReadBooleanValue;
         tkfdRound_Cashflow_Reports           : fdRound_Cashflow_Reports := F.ReadBooleanValue;
         tkfdUse_Xlon_Chart_Order             : fdUse_Xlon_Chart_Order := F.ReadBooleanValue;
         tkfdExtract_Multiple_Accounts_PA     : fdExtract_Multiple_Accounts_PA := F.ReadBooleanValue;
         tkfdExtract_Journal_Accounts_PA      : fdExtract_Journal_Accounts_PA := F.ReadBooleanValue;
         tkfdExtract_Quantity                 : fdExtract_Quantity := F.ReadBooleanValue;
         tkfdReports_New_Page                 : fdReports_New_Page := F.ReadBooleanValue;
         tkfdPrint_Merge_Report_Summary       : fdPrint_Merge_Report_Summary := F.ReadByteValue;
         tkfdEmail_Merge_Report_Summary       : fdEmail_Merge_Report_Summary := F.ReadByteValue;
         tkfdMaximum_Narration_Extract        : fdMaximum_Narration_Extract := F.ReadIntegerValue;
         tkfdSched_Rep_Include_CheckOut       : fdSched_Rep_Include_CheckOut := F.ReadBooleanValue;
         tkfdSched_Rep_CheckOut_Subject       : fdSched_Rep_CheckOut_Subject := F.ReadStringValue;
         tkfdSched_Rep_CheckOut_Message       : fdSched_Rep_CheckOut_Message := F.ReadAnsiStringValue;
         tkfdSched_Rep_Include_Business_Products : fdSched_Rep_Include_Business_Products := F.ReadBooleanValue;
         tkfdSched_Rep_Business_Products_Subject : fdSched_Rep_Business_Products_Subject := F.ReadStringValue;
         tkfdSched_Rep_Business_Products_Message : fdSched_Rep_Business_Products_Message := F.ReadAnsiStringValue;
         tkfdReplace_Narration_With_Payee     : fdReplace_Narration_With_Payee := F.ReadBooleanValue;
         tkfdLast_Export_Charges_Saved_To     : fdLast_Export_Charges_Saved_To := F.ReadAnsiStringValue;
         tkfdManual_Account_XML               : fdManual_Account_XML := F.ReadAnsiStringValue;
         tkfdUpdates_Pending                  : fdUpdates_Pending := F.ReadBooleanValue;
         tkfdUpdate_Server_For_Offsites       : fdUpdate_Server_For_Offsites := F.ReadAnsiStringValue;
         tkfdCollect_Usage_Data               : fdCollect_Usage_Data := F.ReadBooleanValue;
         tkfdFixed_Charge_Increase            : fdFixed_Charge_Increase := F.ReadBooleanValue;
         tkfdPercentage_Charge_Increase       : fdPercentage_Charge_Increase := F.ReadBooleanValue;
         tkfdFixed_Dollar_Amount              : fdFixed_Dollar_Amount := F.ReadMoneyValue;
         tkfdDistributed_Dollar_Amount        : fdDistributed_Dollar_Amount := F.ReadMoneyValue;
         tkfdPercentage_Increase_Amount       : fdPercentage_Increase_Amount := F.ReadMoneyValue;
         tkfdExtract_Quantity_Decimal_Places  : fdExtract_Quantity_Decimal_Places := F.ReadByteValue;
         tkfdExport_Charges_Remarks           : fdExport_Charges_Remarks := F.ReadAnsiStringValue;
         tkfdSystem_Report_Password           : fdSystem_Report_Password := F.ReadStringValue;
         tkfdPrint_Reports_From               : fdPrint_Reports_From := F.ReadDateValue;
         tkfdHighest_Date_Ever_Downloaded     : fdHighest_Date_Ever_Downloaded := F.ReadDateValue;
         tkfdAuto_Retrieve_New_Transactions   : fdAuto_Retrieve_New_Transactions := F.ReadBooleanValue;
         tkfdCoding_Font                      : fdCoding_Font := F.ReadAnsiStringValue;
         tkfdSort_Reports_Option              : fdSort_Reports_Option := F.ReadByteValue;
         tkfdSpare_Byte_12                    : fdSpare_Byte_12 := F.ReadByteValue;
         tkfdGroup_LRN_Counter                : fdGroup_LRN_Counter := F.ReadIntegerValue;
         tkfdClient_Type_LRN_Counter          : fdClient_Type_LRN_Counter := F.ReadIntegerValue;
         tkfdTAX_Applies_From                 : 
            Begin
               D := F.ReadBBDateValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'fdTAX_Applies_From' );
               CheckBounds( I2, 1, 5, 'fdTAX_Applies_From' );
               fdTAX_Applies_From[ I1, I2 ] := D;
            end;
         tkfdTAX_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'fdTAX_Rates' );
               CheckBounds( I2, 1, 5, 'fdTAX_Rates' );
               fdTAX_Rates[ I1, I2 ] := M;
            end;
         tkfdSuperfund_System                 : fdSuperfund_System := F.ReadByteValue;
         tkfdSuperfund_Code_Mask              : fdSuperfund_Code_Mask := F.ReadStringValue;
         tkfdLoad_Client_Super_Files_From     : fdLoad_Client_Super_Files_From := F.ReadStringValue;
         tkfdSave_Client_Super_Files_To       : fdSave_Client_Super_Files_To := F.ReadStringValue;
         tkfdSort_Reports_By                  : fdSort_Reports_By := F.ReadIntegerValue;
         tkfdSet_Fixed_Dollar_Amount          : fdSet_Fixed_Dollar_Amount := F.ReadMoneyValue;
         tkfdPrint_Group_Header_Page          : fdPrint_Group_Header_Page := F.ReadBooleanValue;
         tkfdPrint_Client_Type_Header_Page    : fdPrint_Client_Type_Header_Page := F.ReadBooleanValue;
         tkfdPractice_Management_System       : fdPractice_Management_System := F.ReadByteValue;
         tkfdAutomatic_Task_Creation_Flags    : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 7, 'fdAutomatic_Task_Creation_Flags' );
               fdAutomatic_Task_Creation_Flags[ I ] := Y;
            end;
         tkfdAutomatic_Task_Reminder_Delay    : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 1, 7, 'fdAutomatic_Task_Reminder_Delay' );
               fdAutomatic_Task_Reminder_Delay[ I ] := L;
            end;
         tkfdAutomatic_Task_Closing_Flags     : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 7, 'fdAutomatic_Task_Closing_Flags' );
               fdAutomatic_Task_Closing_Flags[ I ] := Y;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Practice_Details_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Practice_Details_Rec : pPractice_Details_Rec ;

Var
   P : pPractice_Details_Rec;
Begin
   SafeGetMem( P, Practice_Details_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Practice_Details_Rec_Size, 0 );
      fdRecord_Type := tkBegin_Practice_Details;
      fdEOR         := tkEnd_Practice_Details;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Practice_Details_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Practice_Details_Rec_Dynamic_Fields ( Var O : TPractice_Details_Rec );

Begin
   If IsAPractice_Details_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      fdSched_Rep_Cover_Page_Name := '' ;
      fdSched_Rep_Cover_Page_Message := '' ;
      fdSched_Rep_Email_Message := '' ;
      fdBulk_Export_Code := '' ;
      fdSave_Tax_Files_To := '' ;
      fdPractice_Web_Site := '' ;
      fdPractice_Logo_Filename := '' ;
      fdSched_Rep_Print_Custom_Doc_GUID := '' ;
      fdSched_Rep_Fax_Custom_Doc_GUID := '' ;
      fdSpare_Text_3 := '' ;
      fdSched_Rep_Email_Custom_Doc_GUID := '' ;
      fdSpare_Text_5 := '' ;
      fdSched_Rep_Books_Custom_Doc_GUID := '' ;
      fdSched_Rep_Notes_Custom_Doc_GUID := '' ;
      fdSpare_Text_8 := '' ;
      fdSched_Rep_WebNotes_Custom_Doc_GUID := '' ;
      fdSpare_Text_10 := '' ;
      fdSpare_Text_11 := '' ;
      fdSpare_Text_12 := '' ;
      fdSpare_Text_13 := '' ;
      fdSpare_Text_14 := '' ;
      fdSched_Rep_WebNotes_Subject := '' ;
      fdSched_Rep_webNotes_Message := '' ;
      fdSched_Rep_Header_Message := '' ;
      fdSched_Rep_BNotes_Message := '' ;
      fdSched_Rep_CheckOut_Message := '' ;
      fdSched_Rep_Business_Products_Message := '' ;
      fdLast_Export_Charges_Saved_To := '' ;
      fdManual_Account_XML := '' ;
      fdUpdate_Server_For_Offsites := '' ;
      fdExport_Charges_Remarks := '' ;
      fdCoding_Font := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

Function Practice_Details_Rec_Delta(P1, P2, P3: pPractice_Details_Rec): boolean;
begin
  Result := False;

  //Add
  if not Assigned(P2) then begin
    Copy_Practice_Details_Rec(P1, P3);
    Result := True;
    Exit;
  end;

  //Change
  if (P1.fdPractice_Name_for_Reports <> P2.fdPractice_Name_for_Reports) then begin
    Result := true;
    P3.fdPractice_Name_for_Reports := P1.fdPractice_Name_for_Reports;
  end;
  if (P1.fdPractice_EMail_Address <> P2.fdPractice_EMail_Address) then begin
    Result := true;
    P3.fdPractice_EMail_Address := P1.fdPractice_EMail_Address;
  end;
  if (P1.fdAccounting_System_Used <> P2.fdAccounting_System_Used) then begin
    Result := true;
    P3.fdAccounting_System_Used := P1.fdAccounting_System_Used;
  end;
  if (P1.fdCountry <> P2.fdCountry) then begin
    Result := true;
    P3.fdCountry := P1.fdCountry;
  end;
  if (P1.fdLoad_Client_Files_From <> P2.fdLoad_Client_Files_From) then begin
    Result := true;
    P3.fdLoad_Client_Files_From := P1.fdLoad_Client_Files_From;
  end;
  if (P1.fdSave_Client_Files_To <> P2.fdSave_Client_Files_To) then begin
    Result := true;
    P3.fdSave_Client_Files_To := P1.fdSave_Client_Files_To;
  end;
  if Short_Name_Changed(TShort_Name_Array(P1.fdShort_Name), 
                  TShort_Name_Array(P2.fdShort_Name), 
                  TShort_Name_Array(P3.fdShort_Name)) then
    Result := true;
  if Long_Name_Changed(TLong_Name_Array(P1.fdLong_Name), 
                  TLong_Name_Array(P2.fdLong_Name), 
                  TLong_Name_Array(P3.fdLong_Name)) then
    Result := true;
  if GST_Class_Names_Changed(TGST_Class_Names_Array(P1.fdGST_Class_Names), 
                  TGST_Class_Names_Array(P2.fdGST_Class_Names), 
                  TGST_Class_Names_Array(P3.fdGST_Class_Names)) then
    Result := true;
  if GST_Class_Types_Changed(TGST_Class_Types_Array(P1.fdGST_Class_Types), 
                  TGST_Class_Types_Array(P2.fdGST_Class_Types), 
                  TGST_Class_Types_Array(P3.fdGST_Class_Types)) then
    Result := true;
  if GST_Account_Codes_Changed(TGST_Account_Codes_Array(P1.fdGST_Account_Codes), 
                  TGST_Account_Codes_Array(P2.fdGST_Account_Codes), 
                  TGST_Account_Codes_Array(P3.fdGST_Account_Codes)) then
    Result := true;
  if GST_Rates_Changed(TGST_Rates_Array(P1.fdGST_Rates), 
                  TGST_Rates_Array(P2.fdGST_Rates), 
                  TGST_Rates_Array(P3.fdGST_Rates)) then
    Result := true;
  if GST_Applies_From_Changed(TGST_Applies_From_Array(P1.fdGST_Applies_From), 
                  TGST_Applies_From_Array(P2.fdGST_Applies_From), 
                  TGST_Applies_From_Array(P3.fdGST_Applies_From)) then
    Result := true;
  if (P1.fdDate_of_Last_Entry_Received <> P2.fdDate_of_Last_Entry_Received) then begin
    Result := true;
    P3.fdDate_of_Last_Entry_Received := P1.fdDate_of_Last_Entry_Received;
  end;
  if (P1.fdPrint_Reports_Up_To <> P2.fdPrint_Reports_Up_To) then begin
    Result := true;
    P3.fdPrint_Reports_Up_To := P1.fdPrint_Reports_Up_To;
  end;
  if (P1.fdSpare_Boolean_3 <> P2.fdSpare_Boolean_3) then begin
    Result := true;
    P3.fdSpare_Boolean_3 := P1.fdSpare_Boolean_3;
  end;
  if (P1.fdPrint_Staff_Member_Header_Page <> P2.fdPrint_Staff_Member_Header_Page) then begin
    Result := true;
    P3.fdPrint_Staff_Member_Header_Page := P1.fdPrint_Staff_Member_Header_Page;
  end;
  if (P1.fdPrint_Client_Header_Page <> P2.fdPrint_Client_Header_Page) then begin
    Result := true;
    P3.fdPrint_Client_Header_Page := P1.fdPrint_Client_Header_Page;
  end;
  if (P1.fdPIN_Number <> P2.fdPIN_Number) then begin
    Result := true;
    P3.fdPIN_Number := P1.fdPIN_Number;
  end;
  if (P1.fdBankLink_Code <> P2.fdBankLink_Code) then begin
    Result := true;
    P3.fdBankLink_Code := P1.fdBankLink_Code;
  end;
  if (P1.fdDisk_Sequence_No <> P2.fdDisk_Sequence_No) then begin
    Result := true;
    P3.fdDisk_Sequence_No := P1.fdDisk_Sequence_No;
  end;
  if (P1.fdMagic_Number <> P2.fdMagic_Number) then begin
    Result := true;
    P3.fdMagic_Number := P1.fdMagic_Number;
  end;
  if (P1.fdCoding_Report_Style <> P2.fdCoding_Report_Style) then begin
    Result := true;
    P3.fdCoding_Report_Style := P1.fdCoding_Report_Style;
  end;
  if (P1.fdCoding_Report_Sort_Order <> P2.fdCoding_Report_Sort_Order) then begin
    Result := true;
    P3.fdCoding_Report_Sort_Order := P1.fdCoding_Report_Sort_Order;
  end;
  if (P1.fdCoding_Report_Entry_Selection <> P2.fdCoding_Report_Entry_Selection) then begin
    Result := true;
    P3.fdCoding_Report_Entry_Selection := P1.fdCoding_Report_Entry_Selection;
  end;
  if (P1.fdCoding_Report_Blank_Lines <> P2.fdCoding_Report_Blank_Lines) then begin
    Result := true;
    P3.fdCoding_Report_Blank_Lines := P1.fdCoding_Report_Blank_Lines;
  end;
  if (P1.fdCoding_Report_Rule_Line <> P2.fdCoding_Report_Rule_Line) then begin
    Result := true;
    P3.fdCoding_Report_Rule_Line := P1.fdCoding_Report_Rule_Line;
  end;
  if (P1.fdBank_Account_LRN_Counter <> P2.fdBank_Account_LRN_Counter) then begin
    Result := true;
    P3.fdBank_Account_LRN_Counter := P1.fdBank_Account_LRN_Counter;
  end;
  if (P1.fdUser_LRN_Counter <> P2.fdUser_LRN_Counter) then begin
    Result := true;
    P3.fdUser_LRN_Counter := P1.fdUser_LRN_Counter;
  end;
  if (P1.fdTransaction_LRN_Counter <> P2.fdTransaction_LRN_Counter) then begin
    Result := true;
    P3.fdTransaction_LRN_Counter := P1.fdTransaction_LRN_Counter;
  end;
  if (P1.fdClient_File_LRN_Counter <> P2.fdClient_File_LRN_Counter) then begin
    Result := true;
    P3.fdClient_File_LRN_Counter := P1.fdClient_File_LRN_Counter;
  end;
  if (P1.fdBankLink_Connect_Password <> P2.fdBankLink_Connect_Password) then begin
    Result := true;
    P3.fdBankLink_Connect_Password := P1.fdBankLink_Connect_Password;
  end;
  if (P1.fdOld_GST_Class_Codes <> P2.fdOld_GST_Class_Codes) then begin
    Result := true;
    P3.fdOld_GST_Class_Codes := P1.fdOld_GST_Class_Codes;
  end;
  if (P1.fdAccount_Code_Mask <> P2.fdAccount_Code_Mask) then begin
    Result := true;
    P3.fdAccount_Code_Mask := P1.fdAccount_Code_Mask;
  end;
  if (P1.fdFile_Version <> P2.fdFile_Version) then begin
    Result := true;
    P3.fdFile_Version := P1.fdFile_Version;
  end;
  if (P1.fdSched_Rep_Email_Subject <> P2.fdSched_Rep_Email_Subject) then begin
    Result := true;
    P3.fdSched_Rep_Email_Subject := P1.fdSched_Rep_Email_Subject;
  end;
  if (P1.fdOld_Sched_Rep_Email_Line1 <> P2.fdOld_Sched_Rep_Email_Line1) then begin
    Result := true;
    P3.fdOld_Sched_Rep_Email_Line1 := P1.fdOld_Sched_Rep_Email_Line1;
  end;
  if (P1.fdOld_Sched_Rep_Email_Line2 <> P2.fdOld_Sched_Rep_Email_Line2) then begin
    Result := true;
    P3.fdOld_Sched_Rep_Email_Line2 := P1.fdOld_Sched_Rep_Email_Line2;
  end;
  if OLD_BAS_Special_Accounts_Changed(TOLD_BAS_Special_Accounts_Array(P1.fdOLD_BAS_Special_Accounts), 
                  TOLD_BAS_Special_Accounts_Array(P2.fdOLD_BAS_Special_Accounts), 
                  TOLD_BAS_Special_Accounts_Array(P3.fdOLD_BAS_Special_Accounts)) then
    Result := true;
  if GST_Class_Codes_Changed(TGST_Class_Codes_Array(P1.fdGST_Class_Codes), 
                  TGST_Class_Codes_Array(P2.fdGST_Class_Codes), 
                  TGST_Class_Codes_Array(P3.fdGST_Class_Codes)) then
    Result := true;
  if BAS_Field_Number_Changed(TBAS_Field_Number_Array(P1.fdBAS_Field_Number), 
                  TBAS_Field_Number_Array(P2.fdBAS_Field_Number), 
                  TBAS_Field_Number_Array(P3.fdBAS_Field_Number)) then
    Result := true;
  if BAS_Field_Source_Changed(TBAS_Field_Source_Array(P1.fdBAS_Field_Source), 
                  TBAS_Field_Source_Array(P2.fdBAS_Field_Source), 
                  TBAS_Field_Source_Array(P3.fdBAS_Field_Source)) then
    Result := true;
  if BAS_Field_Account_Code_Changed(TBAS_Field_Account_Code_Array(P1.fdBAS_Field_Account_Code), 
                  TBAS_Field_Account_Code_Array(P2.fdBAS_Field_Account_Code), 
                  TBAS_Field_Account_Code_Array(P3.fdBAS_Field_Account_Code)) then
    Result := true;
  if BAS_Field_Balance_Changed(TBAS_Field_Balance_Array(P1.fdBAS_Field_Balance), 
                  TBAS_Field_Balance_Array(P2.fdBAS_Field_Balance), 
                  TBAS_Field_Balance_Array(P3.fdBAS_Field_Balance)) then
    Result := true;
  if (P1.fdSched_Rep_Include_Email <> P2.fdSched_Rep_Include_Email) then begin
    Result := true;
    P3.fdSched_Rep_Include_Email := P1.fdSched_Rep_Include_Email;
  end;
  if (P1.fdSched_Rep_Email_Only <> P2.fdSched_Rep_Email_Only) then begin
    Result := true;
    P3.fdSched_Rep_Email_Only := P1.fdSched_Rep_Email_Only;
  end;
  if (P1.fdSched_Rep_Include_Printer <> P2.fdSched_Rep_Include_Printer) then begin
    Result := true;
    P3.fdSched_Rep_Include_Printer := P1.fdSched_Rep_Include_Printer;
  end;
  if (P1.fdSched_Rep_Include_Fax <> P2.fdSched_Rep_Include_Fax) then begin
    Result := true;
    P3.fdSched_Rep_Include_Fax := P1.fdSched_Rep_Include_Fax;
  end;
  if (P1.fdSched_Rep_Send_Fax_Off_Peak <> P2.fdSched_Rep_Send_Fax_Off_Peak) then begin
    Result := true;
    P3.fdSched_Rep_Send_Fax_Off_Peak := P1.fdSched_Rep_Send_Fax_Off_Peak;
  end;
  if Enhanced_Software_Options_Changed(TEnhanced_Software_Options_Array(P1.fdEnhanced_Software_Options), 
                  TEnhanced_Software_Options_Array(P2.fdEnhanced_Software_Options), 
                  TEnhanced_Software_Options_Array(P3.fdEnhanced_Software_Options)) then
    Result := true;
  if (P1.fdSched_Rep_Include_ECoding <> P2.fdSched_Rep_Include_ECoding) then begin
    Result := true;
    P3.fdSched_Rep_Include_ECoding := P1.fdSched_Rep_Include_ECoding;
  end;
  if (P1.fdSched_Rep_Cover_Page_Name <> P2.fdSched_Rep_Cover_Page_Name) then begin
    Result := true;
    P3.fdSched_Rep_Cover_Page_Name := P1.fdSched_Rep_Cover_Page_Name;
  end;
  if (P1.fdSched_Rep_Cover_Page_Subject <> P2.fdSched_Rep_Cover_Page_Subject) then begin
    Result := true;
    P3.fdSched_Rep_Cover_Page_Subject := P1.fdSched_Rep_Cover_Page_Subject;
  end;
  if (P1.fdSched_Rep_Cover_Page_Message <> P2.fdSched_Rep_Cover_Page_Message) then begin
    Result := true;
    P3.fdSched_Rep_Cover_Page_Message := P1.fdSched_Rep_Cover_Page_Message;
  end;
  if (P1.fdSched_Rep_Email_Message <> P2.fdSched_Rep_Email_Message) then begin
    Result := true;
    P3.fdSched_Rep_Email_Message := P1.fdSched_Rep_Email_Message;
  end;
  if (P1.fdDownload_Report_Options <> P2.fdDownload_Report_Options) then begin
    Result := true;
    P3.fdDownload_Report_Options := P1.fdDownload_Report_Options;
  end;
  if (P1.fdDownload_Report_Hide_Deleted <> P2.fdDownload_Report_Hide_Deleted) then begin
    Result := true;
    P3.fdDownload_Report_Hide_Deleted := P1.fdDownload_Report_Hide_Deleted;
  end;
  if (P1.fdBulk_Export_Enabled <> P2.fdBulk_Export_Enabled) then begin
    Result := true;
    P3.fdBulk_Export_Enabled := P1.fdBulk_Export_Enabled;
  end;
  if (P1.fdSpare_Byte_0 <> P2.fdSpare_Byte_0) then begin
    Result := true;
    P3.fdSpare_Byte_0 := P1.fdSpare_Byte_0;
  end;
  if (P1.fdBulk_Export_Code <> P2.fdBulk_Export_Code) then begin
    Result := true;
    P3.fdBulk_Export_Code := P1.fdBulk_Export_Code;
  end;
  if (P1.fdSched_Rep_Include_CSV_Export <> P2.fdSched_Rep_Include_CSV_Export) then begin
    Result := true;
    P3.fdSched_Rep_Include_CSV_Export := P1.fdSched_Rep_Include_CSV_Export;
  end;
  if (P1.fdTax_Interface_Used <> P2.fdTax_Interface_Used) then begin
    Result := true;
    P3.fdTax_Interface_Used := P1.fdTax_Interface_Used;
  end;
  if (P1.fdSave_Tax_Files_To <> P2.fdSave_Tax_Files_To) then begin
    Result := true;
    P3.fdSave_Tax_Files_To := P1.fdSave_Tax_Files_To;
  end;
  if (P1.fdLast_Disk_Image_Version <> P2.fdLast_Disk_Image_Version) then begin
    Result := true;
    P3.fdLast_Disk_Image_Version := P1.fdLast_Disk_Image_Version;
  end;
  if (P1.fdPractice_Web_Site <> P2.fdPractice_Web_Site) then begin
    Result := true;
    P3.fdPractice_Web_Site := P1.fdPractice_Web_Site;
  end;
  if (P1.fdPractice_Phone <> P2.fdPractice_Phone) then begin
    Result := true;
    P3.fdPractice_Phone := P1.fdPractice_Phone;
  end;
  if (P1.fdPractice_Logo_Filename <> P2.fdPractice_Logo_Filename) then begin
    Result := true;
    P3.fdPractice_Logo_Filename := P1.fdPractice_Logo_Filename;
  end;
  if (P1.fdSched_Rep_Print_Custom_Doc_GUID <> P2.fdSched_Rep_Print_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_Print_Custom_Doc_GUID := P1.fdSched_Rep_Print_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_Print_Custom_Doc <> P2.fdSched_Rep_Print_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_Print_Custom_Doc := P1.fdSched_Rep_Print_Custom_Doc;
  end;
  if (P1.fdLast_ChargeFile_Date <> P2.fdLast_ChargeFile_Date) then begin
    Result := true;
    P3.fdLast_ChargeFile_Date := P1.fdLast_ChargeFile_Date;
  end;
  if (P1.fdAudit_Record_ID <> P2.fdAudit_Record_ID) then begin
    Result := true;
    P3.fdAudit_Record_ID := P1.fdAudit_Record_ID;
  end;
  if (P1.fdSched_Rep_Fax_Custom_Doc_GUID <> P2.fdSched_Rep_Fax_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_Fax_Custom_Doc_GUID := P1.fdSched_Rep_Fax_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_Fax_Custom_Doc <> P2.fdSched_Rep_Fax_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_Fax_Custom_Doc := P1.fdSched_Rep_Fax_Custom_Doc;
  end;
  if (P1.fdSpare_Text_3 <> P2.fdSpare_Text_3) then begin
    Result := true;
    P3.fdSpare_Text_3 := P1.fdSpare_Text_3;
  end;
  if (P1.fdSched_Rep_Email_Custom_Doc_GUID <> P2.fdSched_Rep_Email_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_Email_Custom_Doc_GUID := P1.fdSched_Rep_Email_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_Email_Custom_Doc <> P2.fdSched_Rep_Email_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_Email_Custom_Doc := P1.fdSched_Rep_Email_Custom_Doc;
  end;
  if (P1.fdSpare_Text_5 <> P2.fdSpare_Text_5) then begin
    Result := true;
    P3.fdSpare_Text_5 := P1.fdSpare_Text_5;
  end;
  if (P1.fdSched_Rep_Books_Custom_Doc_GUID <> P2.fdSched_Rep_Books_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_Books_Custom_Doc_GUID := P1.fdSched_Rep_Books_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_Books_Custom_Doc <> P2.fdSched_Rep_Books_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_Books_Custom_Doc := P1.fdSched_Rep_Books_Custom_Doc;
  end;
  if (P1.fdSpare_Integer_3 <> P2.fdSpare_Integer_3) then begin
    Result := true;
    P3.fdSpare_Integer_3 := P1.fdSpare_Integer_3;
  end;
  if (P1.fdSpare_Integer_4 <> P2.fdSpare_Integer_4) then begin
    Result := true;
    P3.fdSpare_Integer_4 := P1.fdSpare_Integer_4;
  end;
  if (P1.fdSched_Rep_Notes_Custom_Doc_GUID <> P2.fdSched_Rep_Notes_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_Notes_Custom_Doc_GUID := P1.fdSched_Rep_Notes_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_Notes_Custom_Doc <> P2.fdSched_Rep_Notes_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_Notes_Custom_Doc := P1.fdSched_Rep_Notes_Custom_Doc;
  end;
  if (P1.fdSpare_Text_8 <> P2.fdSpare_Text_8) then begin
    Result := true;
    P3.fdSpare_Text_8 := P1.fdSpare_Text_8;
  end;
  if (P1.fdSched_Rep_WebNotes_Custom_Doc_GUID <> P2.fdSched_Rep_WebNotes_Custom_Doc_GUID) then begin
    Result := true;
    P3.fdSched_Rep_WebNotes_Custom_Doc_GUID := P1.fdSched_Rep_WebNotes_Custom_Doc_GUID;
  end;
  if (P1.fdSched_Rep_WebNotes_Custom_Doc <> P2.fdSched_Rep_WebNotes_Custom_Doc) then begin
    Result := true;
    P3.fdSched_Rep_WebNotes_Custom_Doc := P1.fdSched_Rep_WebNotes_Custom_Doc;
  end;
  if (P1.fdSpare_Integer_5 <> P2.fdSpare_Integer_5) then begin
    Result := true;
    P3.fdSpare_Integer_5 := P1.fdSpare_Integer_5;
  end;
  if (P1.fdSpare_Integer_6 <> P2.fdSpare_Integer_6) then begin
    Result := true;
    P3.fdSpare_Integer_6 := P1.fdSpare_Integer_6;
  end;
  if (P1.fdSpare_Text_10 <> P2.fdSpare_Text_10) then begin
    Result := true;
    P3.fdSpare_Text_10 := P1.fdSpare_Text_10;
  end;
  if (P1.fdSpare_Byte_7 <> P2.fdSpare_Byte_7) then begin
    Result := true;
    P3.fdSpare_Byte_7 := P1.fdSpare_Byte_7;
  end;
  if (P1.fdSpare_Text_11 <> P2.fdSpare_Text_11) then begin
    Result := true;
    P3.fdSpare_Text_11 := P1.fdSpare_Text_11;
  end;
  if (P1.fdSpare_Text_12 <> P2.fdSpare_Text_12) then begin
    Result := true;
    P3.fdSpare_Text_12 := P1.fdSpare_Text_12;
  end;
  if (P1.fdSpare_Byte_8 <> P2.fdSpare_Byte_8) then begin
    Result := true;
    P3.fdSpare_Byte_8 := P1.fdSpare_Byte_8;
  end;
  if (P1.fdSpare_Text_13 <> P2.fdSpare_Text_13) then begin
    Result := true;
    P3.fdSpare_Text_13 := P1.fdSpare_Text_13;
  end;
  if (P1.fdSpare_Text_14 <> P2.fdSpare_Text_14) then begin
    Result := true;
    P3.fdSpare_Text_14 := P1.fdSpare_Text_14;
  end;
  if (P1.fdSpare_Byte_9 <> P2.fdSpare_Byte_9) then begin
    Result := true;
    P3.fdSpare_Byte_9 := P1.fdSpare_Byte_9;
  end;
  if (P1.fdSpare_Integer_7 <> P2.fdSpare_Integer_7) then begin
    Result := true;
    P3.fdSpare_Integer_7 := P1.fdSpare_Integer_7;
  end;
  if (P1.fdSpare_Integer_8 <> P2.fdSpare_Integer_8) then begin
    Result := true;
    P3.fdSpare_Integer_8 := P1.fdSpare_Integer_8;
  end;
  if (P1.fdSched_Rep_WebNotes_Subject <> P2.fdSched_Rep_WebNotes_Subject) then begin
    Result := true;
    P3.fdSched_Rep_WebNotes_Subject := P1.fdSched_Rep_WebNotes_Subject;
  end;
  if (P1.fdSpare_Byte_10 <> P2.fdSpare_Byte_10) then begin
    Result := true;
    P3.fdSpare_Byte_10 := P1.fdSpare_Byte_10;
  end;
  if (P1.fdSched_Rep_webNotes_Message <> P2.fdSched_Rep_webNotes_Message) then begin
    Result := true;
    P3.fdSched_Rep_webNotes_Message := P1.fdSched_Rep_webNotes_Message;
  end;
  if (P1.fdSpare_Byte_11 <> P2.fdSpare_Byte_11) then begin
    Result := true;
    P3.fdSpare_Byte_11 := P1.fdSpare_Byte_11;
  end;
  if (P1.fdSched_Rep_Header_Message <> P2.fdSched_Rep_Header_Message) then begin
    Result := true;
    P3.fdSched_Rep_Header_Message := P1.fdSched_Rep_Header_Message;
  end;
  if (P1.fdSched_Rep_BNotes_Subject <> P2.fdSched_Rep_BNotes_Subject) then begin
    Result := true;
    P3.fdSched_Rep_BNotes_Subject := P1.fdSched_Rep_BNotes_Subject;
  end;
  if (P1.fdSched_Rep_BNotes_Message <> P2.fdSched_Rep_BNotes_Message) then begin
    Result := true;
    P3.fdSched_Rep_BNotes_Message := P1.fdSched_Rep_BNotes_Message;
  end;
  if (P1.fdSpare_Boolean_4 <> P2.fdSpare_Boolean_4) then begin
    Result := true;
    P3.fdSpare_Boolean_4 := P1.fdSpare_Boolean_4;
  end;
  if (P1.fdTask_Tracking_Prompt_Type <> P2.fdTask_Tracking_Prompt_Type) then begin
    Result := true;
    P3.fdTask_Tracking_Prompt_Type := P1.fdTask_Tracking_Prompt_Type;
  end;
  if (P1.fdSpare_Bool_1 <> P2.fdSpare_Bool_1) then begin
    Result := true;
    P3.fdSpare_Bool_1 := P1.fdSpare_Bool_1;
  end;
  if (P1.fdSpare_Bool_2 <> P2.fdSpare_Bool_2) then begin
    Result := true;
    P3.fdSpare_Bool_2 := P1.fdSpare_Bool_2;
  end;
  if (P1.fdSpare_Integer_9 <> P2.fdSpare_Integer_9) then begin
    Result := true;
    P3.fdSpare_Integer_9 := P1.fdSpare_Integer_9;
  end;
  if (P1.fdSched_Rep_Fax_Transport <> P2.fdSched_Rep_Fax_Transport) then begin
    Result := true;
    P3.fdSched_Rep_Fax_Transport := P1.fdSched_Rep_Fax_Transport;
  end;
  if (P1.fdSched_Rep_Include_WebX <> P2.fdSched_Rep_Include_WebX) then begin
    Result := true;
    P3.fdSched_Rep_Include_WebX := P1.fdSched_Rep_Include_WebX;
  end;
  if (P1.fdWeb_Export_Format <> P2.fdWeb_Export_Format) then begin
    Result := true;
    P3.fdWeb_Export_Format := P1.fdWeb_Export_Format;
  end;
  if (P1.fdForce_Login <> P2.fdForce_Login) then begin
    Result := true;
    P3.fdForce_Login := P1.fdForce_Login;
  end;
  if (P1.fdLogin_Bitmap_Filename <> P2.fdLogin_Bitmap_Filename) then begin
    Result := true;
    P3.fdLogin_Bitmap_Filename := P1.fdLogin_Bitmap_Filename;
  end;
  if (P1.fdAuto_Print_Sched_Rep_Summary <> P2.fdAuto_Print_Sched_Rep_Summary) then begin
    Result := true;
    P3.fdAuto_Print_Sched_Rep_Summary := P1.fdAuto_Print_Sched_Rep_Summary;
  end;
  if (P1.fdIgnore_Quantity_In_Download <> P2.fdIgnore_Quantity_In_Download) then begin
    Result := true;
    P3.fdIgnore_Quantity_In_Download := P1.fdIgnore_Quantity_In_Download;
  end;
  if (P1.fdSpare_Boolean_1 <> P2.fdSpare_Boolean_1) then begin
    Result := true;
    P3.fdSpare_Boolean_1 := P1.fdSpare_Boolean_1;
  end;
  if (P1.fdspare_Boolean_2 <> P2.fdspare_Boolean_2) then begin
    Result := true;
    P3.fdspare_Boolean_2 := P1.fdspare_Boolean_2;
  end;
  if (P1.fdCopy_Dissection_Narration <> P2.fdCopy_Dissection_Narration) then begin
    Result := true;
    P3.fdCopy_Dissection_Narration := P1.fdCopy_Dissection_Narration;
  end;
  if (P1.fdRound_Cashflow_Reports <> P2.fdRound_Cashflow_Reports) then begin
    Result := true;
    P3.fdRound_Cashflow_Reports := P1.fdRound_Cashflow_Reports;
  end;
  if (P1.fdUse_Xlon_Chart_Order <> P2.fdUse_Xlon_Chart_Order) then begin
    Result := true;
    P3.fdUse_Xlon_Chart_Order := P1.fdUse_Xlon_Chart_Order;
  end;
  if (P1.fdExtract_Multiple_Accounts_PA <> P2.fdExtract_Multiple_Accounts_PA) then begin
    Result := true;
    P3.fdExtract_Multiple_Accounts_PA := P1.fdExtract_Multiple_Accounts_PA;
  end;
  if (P1.fdExtract_Journal_Accounts_PA <> P2.fdExtract_Journal_Accounts_PA) then begin
    Result := true;
    P3.fdExtract_Journal_Accounts_PA := P1.fdExtract_Journal_Accounts_PA;
  end;
  if (P1.fdExtract_Quantity <> P2.fdExtract_Quantity) then begin
    Result := true;
    P3.fdExtract_Quantity := P1.fdExtract_Quantity;
  end;
  if (P1.fdReports_New_Page <> P2.fdReports_New_Page) then begin
    Result := true;
    P3.fdReports_New_Page := P1.fdReports_New_Page;
  end;
  if (P1.fdPrint_Merge_Report_Summary <> P2.fdPrint_Merge_Report_Summary) then begin
    Result := true;
    P3.fdPrint_Merge_Report_Summary := P1.fdPrint_Merge_Report_Summary;
  end;
  if (P1.fdEmail_Merge_Report_Summary <> P2.fdEmail_Merge_Report_Summary) then begin
    Result := true;
    P3.fdEmail_Merge_Report_Summary := P1.fdEmail_Merge_Report_Summary;
  end;
  if (P1.fdMaximum_Narration_Extract <> P2.fdMaximum_Narration_Extract) then begin
    Result := true;
    P3.fdMaximum_Narration_Extract := P1.fdMaximum_Narration_Extract;
  end;
  if (P1.fdSched_Rep_Include_CheckOut <> P2.fdSched_Rep_Include_CheckOut) then begin
    Result := true;
    P3.fdSched_Rep_Include_CheckOut := P1.fdSched_Rep_Include_CheckOut;
  end;
  if (P1.fdSched_Rep_CheckOut_Subject <> P2.fdSched_Rep_CheckOut_Subject) then begin
    Result := true;
    P3.fdSched_Rep_CheckOut_Subject := P1.fdSched_Rep_CheckOut_Subject;
  end;
  if (P1.fdSched_Rep_CheckOut_Message <> P2.fdSched_Rep_CheckOut_Message) then begin
    Result := true;
    P3.fdSched_Rep_CheckOut_Message := P1.fdSched_Rep_CheckOut_Message;
  end;
  if (P1.fdSched_Rep_Include_Business_Products <> P2.fdSched_Rep_Include_Business_Products) then begin
    Result := true;
    P3.fdSched_Rep_Include_Business_Products := P1.fdSched_Rep_Include_Business_Products;
  end;
  if (P1.fdSched_Rep_Business_Products_Subject <> P2.fdSched_Rep_Business_Products_Subject) then begin
    Result := true;
    P3.fdSched_Rep_Business_Products_Subject := P1.fdSched_Rep_Business_Products_Subject;
  end;
  if (P1.fdSched_Rep_Business_Products_Message <> P2.fdSched_Rep_Business_Products_Message) then begin
    Result := true;
    P3.fdSched_Rep_Business_Products_Message := P1.fdSched_Rep_Business_Products_Message;
  end;
  if (P1.fdReplace_Narration_With_Payee <> P2.fdReplace_Narration_With_Payee) then begin
    Result := true;
    P3.fdReplace_Narration_With_Payee := P1.fdReplace_Narration_With_Payee;
  end;
  if (P1.fdLast_Export_Charges_Saved_To <> P2.fdLast_Export_Charges_Saved_To) then begin
    Result := true;
    P3.fdLast_Export_Charges_Saved_To := P1.fdLast_Export_Charges_Saved_To;
  end;
  if (P1.fdManual_Account_XML <> P2.fdManual_Account_XML) then begin
    Result := true;
    P3.fdManual_Account_XML := P1.fdManual_Account_XML;
  end;
  if (P1.fdUpdates_Pending <> P2.fdUpdates_Pending) then begin
    Result := true;
    P3.fdUpdates_Pending := P1.fdUpdates_Pending;
  end;
  if (P1.fdUpdate_Server_For_Offsites <> P2.fdUpdate_Server_For_Offsites) then begin
    Result := true;
    P3.fdUpdate_Server_For_Offsites := P1.fdUpdate_Server_For_Offsites;
  end;
  if (P1.fdCollect_Usage_Data <> P2.fdCollect_Usage_Data) then begin
    Result := true;
    P3.fdCollect_Usage_Data := P1.fdCollect_Usage_Data;
  end;
  if (P1.fdFixed_Charge_Increase <> P2.fdFixed_Charge_Increase) then begin
    Result := true;
    P3.fdFixed_Charge_Increase := P1.fdFixed_Charge_Increase;
  end;
  if (P1.fdPercentage_Charge_Increase <> P2.fdPercentage_Charge_Increase) then begin
    Result := true;
    P3.fdPercentage_Charge_Increase := P1.fdPercentage_Charge_Increase;
  end;
  if (P1.fdFixed_Dollar_Amount <> P2.fdFixed_Dollar_Amount) then begin
    Result := true;
    P3.fdFixed_Dollar_Amount := P1.fdFixed_Dollar_Amount;
  end;
  if (P1.fdDistributed_Dollar_Amount <> P2.fdDistributed_Dollar_Amount) then begin
    Result := true;
    P3.fdDistributed_Dollar_Amount := P1.fdDistributed_Dollar_Amount;
  end;
  if (P1.fdPercentage_Increase_Amount <> P2.fdPercentage_Increase_Amount) then begin
    Result := true;
    P3.fdPercentage_Increase_Amount := P1.fdPercentage_Increase_Amount;
  end;
  if (P1.fdExtract_Quantity_Decimal_Places <> P2.fdExtract_Quantity_Decimal_Places) then begin
    Result := true;
    P3.fdExtract_Quantity_Decimal_Places := P1.fdExtract_Quantity_Decimal_Places;
  end;
  if (P1.fdExport_Charges_Remarks <> P2.fdExport_Charges_Remarks) then begin
    Result := true;
    P3.fdExport_Charges_Remarks := P1.fdExport_Charges_Remarks;
  end;
  if (P1.fdSystem_Report_Password <> P2.fdSystem_Report_Password) then begin
    Result := true;
    P3.fdSystem_Report_Password := P1.fdSystem_Report_Password;
  end;
  if (P1.fdPrint_Reports_From <> P2.fdPrint_Reports_From) then begin
    Result := true;
    P3.fdPrint_Reports_From := P1.fdPrint_Reports_From;
  end;
  if (P1.fdHighest_Date_Ever_Downloaded <> P2.fdHighest_Date_Ever_Downloaded) then begin
    Result := true;
    P3.fdHighest_Date_Ever_Downloaded := P1.fdHighest_Date_Ever_Downloaded;
  end;
  if (P1.fdAuto_Retrieve_New_Transactions <> P2.fdAuto_Retrieve_New_Transactions) then begin
    Result := true;
    P3.fdAuto_Retrieve_New_Transactions := P1.fdAuto_Retrieve_New_Transactions;
  end;
  if (P1.fdCoding_Font <> P2.fdCoding_Font) then begin
    Result := true;
    P3.fdCoding_Font := P1.fdCoding_Font;
  end;
  if (P1.fdSort_Reports_Option <> P2.fdSort_Reports_Option) then begin
    Result := true;
    P3.fdSort_Reports_Option := P1.fdSort_Reports_Option;
  end;
  if (P1.fdSpare_Byte_12 <> P2.fdSpare_Byte_12) then begin
    Result := true;
    P3.fdSpare_Byte_12 := P1.fdSpare_Byte_12;
  end;
  if (P1.fdGroup_LRN_Counter <> P2.fdGroup_LRN_Counter) then begin
    Result := true;
    P3.fdGroup_LRN_Counter := P1.fdGroup_LRN_Counter;
  end;
  if (P1.fdClient_Type_LRN_Counter <> P2.fdClient_Type_LRN_Counter) then begin
    Result := true;
    P3.fdClient_Type_LRN_Counter := P1.fdClient_Type_LRN_Counter;
  end;
  if TAX_Applies_From_Changed(TTAX_Applies_From_Array(P1.fdTAX_Applies_From), 
                  TTAX_Applies_From_Array(P2.fdTAX_Applies_From), 
                  TTAX_Applies_From_Array(P3.fdTAX_Applies_From)) then
    Result := true;
  if TAX_Rates_Changed(TTAX_Rates_Array(P1.fdTAX_Rates), 
                  TTAX_Rates_Array(P2.fdTAX_Rates), 
                  TTAX_Rates_Array(P3.fdTAX_Rates)) then
    Result := true;
  if (P1.fdSuperfund_System <> P2.fdSuperfund_System) then begin
    Result := true;
    P3.fdSuperfund_System := P1.fdSuperfund_System;
  end;
  if (P1.fdSuperfund_Code_Mask <> P2.fdSuperfund_Code_Mask) then begin
    Result := true;
    P3.fdSuperfund_Code_Mask := P1.fdSuperfund_Code_Mask;
  end;
  if (P1.fdLoad_Client_Super_Files_From <> P2.fdLoad_Client_Super_Files_From) then begin
    Result := true;
    P3.fdLoad_Client_Super_Files_From := P1.fdLoad_Client_Super_Files_From;
  end;
  if (P1.fdSave_Client_Super_Files_To <> P2.fdSave_Client_Super_Files_To) then begin
    Result := true;
    P3.fdSave_Client_Super_Files_To := P1.fdSave_Client_Super_Files_To;
  end;
  if (P1.fdSort_Reports_By <> P2.fdSort_Reports_By) then begin
    Result := true;
    P3.fdSort_Reports_By := P1.fdSort_Reports_By;
  end;
  if (P1.fdSet_Fixed_Dollar_Amount <> P2.fdSet_Fixed_Dollar_Amount) then begin
    Result := true;
    P3.fdSet_Fixed_Dollar_Amount := P1.fdSet_Fixed_Dollar_Amount;
  end;
  if (P1.fdPrint_Group_Header_Page <> P2.fdPrint_Group_Header_Page) then begin
    Result := true;
    P3.fdPrint_Group_Header_Page := P1.fdPrint_Group_Header_Page;
  end;
  if (P1.fdPrint_Client_Type_Header_Page <> P2.fdPrint_Client_Type_Header_Page) then begin
    Result := true;
    P3.fdPrint_Client_Type_Header_Page := P1.fdPrint_Client_Type_Header_Page;
  end;
  if (P1.fdPractice_Management_System <> P2.fdPractice_Management_System) then begin
    Result := true;
    P3.fdPractice_Management_System := P1.fdPractice_Management_System;
  end;
  if Automatic_Task_Creation_Flags_Changed(TAutomatic_Task_Creation_Flags_Array(P1.fdAutomatic_Task_Creation_Flags), 
                  TAutomatic_Task_Creation_Flags_Array(P2.fdAutomatic_Task_Creation_Flags), 
                  TAutomatic_Task_Creation_Flags_Array(P3.fdAutomatic_Task_Creation_Flags)) then
    Result := true;
  if Automatic_Task_Reminder_Delay_Changed(TAutomatic_Task_Reminder_Delay_Array(P1.fdAutomatic_Task_Reminder_Delay), 
                  TAutomatic_Task_Reminder_Delay_Array(P2.fdAutomatic_Task_Reminder_Delay), 
                  TAutomatic_Task_Reminder_Delay_Array(P3.fdAutomatic_Task_Reminder_Delay)) then
    Result := true;
  if Automatic_Task_Closing_Flags_Changed(TAutomatic_Task_Closing_Flags_Array(P1.fdAutomatic_Task_Closing_Flags), 
                  TAutomatic_Task_Closing_Flags_Array(P2.fdAutomatic_Task_Closing_Flags), 
                  TAutomatic_Task_Closing_Flags_Array(P3.fdAutomatic_Task_Closing_Flags)) then
    Result := true;

end;

{  -------------------------------------------------------------------  }

procedure Copy_Practice_Details_Rec(P1, P2: pPractice_Details_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Practice_Details_Rec(P1^, S);
    S.Position := 0;
    Read_Practice_Details_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
