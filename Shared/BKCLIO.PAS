UNIT BKclIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client                       = 20 ;
   tkEnd_Client                         = 21 ;

FUNCTION  IsAClient_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_Rec ( Var O : TClient_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_Rec ( Var O : TClient_Rec ; Var F : TIOStream );
FUNCTION  New_Client_Rec : pClient_Rec ;
PROCEDURE Free_Client_Rec_Dynamic_Fields ( Var O : TClient_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKCLIO';
   SBoundsError        = 'BKCLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKCLIO Error: Pointer is NIL in IsAClient_Rec';
   SInvalidType        = 'BKCLIO Error: Type is invalid in IsAClient_Rec';
   SInvalidEOR         = 'BKCLIO Error: EOR is missing in IsAClient_Rec';
   SUnknownToken       = 'BKCLIO Error: Unknown token %d in Read_Client_Rec';
   SInsufficientMemory = 'BKCLIO Error: Out of memory in New_Client_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkclCode                             = 22 ;
   tkclName                             = 23 ;
   tkclAddress_L1                       = 24 ;
   tkclAddress_L2                       = 25 ;
   tkclAddress_L3                       = 26 ;
   tkclContact_Name                     = 27 ;
   tkclPhone_No                         = 28 ;
   tkclFax_No                           = 29 ;
   tkclFile_Password                    = 30 ;
   tkclPractice_Name                    = 31 ;
   tkclStaff_Member_Name                = 32 ;
   tkclPractice_EMail_Address           = 33 ;
   tkclStaff_Member_EMail_Address       = 34 ;
   tkclClient_EMail_Address             = 35 ;
   tkclCountry                          = 36 ;
   tkclFile_Name                        = 37 ;
   tkclFile_Type                        = 38 ;
   tkclFile_Version                     = 39 ;
   tkclFile_Save_Count                  = 40 ;
   tkclBankLink_Connect_Password        = 41 ;
   tkclPIN_Number                       = 42 ;
   tkclOld_Restrict_Analysis_Codes      = 43 ;
   tkclFinancial_Year_Starts            = 44 ;
   tkclReport_Start_Date                = 45 ;
   tkclReporting_Period                 = 46 ;
   tkclOld_Send_Reports_To              = 47 ;
   tkclSend_Coding_Report               = 48 ;
   tkclSend_Chart_of_Accounts           = 49 ;
   tkclSend_Unpresented_Cheque_List     = 50 ;
   tkclSend_Payee_List                  = 51 ;
   tkclSend_Payee_Report                = 52 ;
   tkclShort_Name                       = 53 ;
   tkclLong_Name                        = 54 ;
   tkclGST_Number                       = 55 ;
   tkclGST_Period                       = 56 ;
   tkclGST_Start_Month                  = 57 ;
   tkclGST_Applies_From                 = 58 ;
   tkclGST_Class_Names                  = 59 ;
   tkclGST_Class_Types                  = 60 ;
   tkclGST_Account_Codes                = 61 ;
   tkclGST_Rates                        = 62 ;
   tkclGST_Basis                        = 63 ;
   tkclGST_on_Presentation_Date         = 64 ;
   tkclGST_Excludes_Accruals            = 65 ;
   tkclGST_Inclusive_Cashflow           = 66 ;
   tkclAccounting_System_Used           = 67 ;
   tkclAccount_Code_Mask                = 68 ;
   tkclLoad_Client_Files_From           = 69 ;
   tkclSave_Client_Files_To             = 70 ;
   tkclChart_Is_Locked                  = 71 ;
   tkclChart_Last_Updated               = 72 ;
   tkclCoding_Report_Style              = 73 ;
   tkclCoding_Report_Sort_Order         = 74 ;
   tkclCoding_Report_Entry_Selection    = 75 ;
   tkclCoding_Report_Blank_Lines        = 76 ;
   tkclCoding_Report_Rule_Line          = 77 ;
   tkclCoding_Report_New_Page           = 78 ;
   tkclOld_Division_Names               = 79 ;
   tkclCF_Headings                      = 80 ;
   tkclPR_Headings                      = 81 ;
   tkclMagic_Number                     = 82 ;
   tkclException_Options                = 83 ;
   tkclPeriod_Start_Date                = 84 ;
   tkclPeriod_End_Date                  = 85 ;
   tkclFRS_Print_Chart_Codes            = 86 ;
   tkclBankLink_Code                    = 87 ;
   tkclDisk_Sequence_No                 = 88 ;
   tkclStaff_Member_LRN                 = 89 ;
   tkclSuppress_Check_for_New_TXns      = 90 ;
   tkclDownload_From                    = 91 ;
   tkclLast_Batch_Number                = 92 ;
   tkclOld_GST_Class_Codes              = 93 ;
   tkclDivision_Code_List               = 94 ;
   tkclSB_Export_As                     = 95 ;
   tkclSB_Upload_To                     = 96 ;
   tkclCoding_Report_Print_TI           = 97 ;
   tkclV31_GST_Format_Used              = 98 ;
   tkclEmail_Scheduled_Reports          = 99 ;
   tkclOLD_BAS_Special_Accounts         = 100 ;
   tkclGST_Class_Codes                  = 101 ;
   tkclTax_Ledger_Code                  = 102 ;
   tkclEOY_Locked_SB_Only               = 103 ;
   tkclBAS_Field_Number                 = 104 ;
   tkclBAS_Field_Source                 = 105 ;
   tkclBAS_Field_Account_Code           = 106 ;
   tkclBAS_Field_Balance_Type           = 107 ;
   tkclBAS_Field_Percent                = 108 ;
   tkclGST_Business_Percent             = 109 ;
   tkclBAS_Calculation_Method           = 110 ;
   tkclBAS_Dont_Print_Calc_Sheet        = 111 ;
   tkclBAS_PAYG_Withheld_Period         = 112 ;
   tkclFax_Scheduled_Reports            = 113 ;
   tkclGraph_Headings                   = 114 ;
   tkclNotes                            = 115 ;
   tkclCheques_Expire_When              = 116 ;
   tkclShow_Notes_On_Open               = 117 ;
   tkclECoding_Entry_Selection          = 118 ;
   tkclECoding_Dont_Send_Chart          = 119 ;
   tkclECoding_Dont_Send_Payees         = 120 ;
   tkclECoding_Dont_Show_Quantity       = 121 ;
   tkclECoding_Last_File_No             = 122 ;
   tkclECoding_Last_File_No_Imported    = 123 ;
   tkclECoding_Export_Scheduled_Reports = 124 ;
   tkclEmail_Report_Format              = 125 ;
   tkclBAS_PAYG_Instalment_Period       = 126 ;
   tkclBAS_Include_FBT_WET_LCT          = 127 ;
   tkclBAS_Last_GST_Option              = 128 ;
   tkclBAS_Last_PAYG_Instalment_Option  = 129 ;
   tkclECoding_Default_Password         = 130 ;
   tkclECoding_Import_Options           = 131 ;
   tkclECoding_Last_Import_Dir          = 132 ;
   tkclECoding_Last_Export_Dir          = 133 ;
   tkclCoding_Report_Show_OP            = 134 ;
   tkclFRS_Show_Quantity                = 135 ;
   tkclCflw_Cash_On_Hand_Style          = 136 ;
   tkclCSV_Export_Scheduled_Reports     = 137 ;
   tkclFRS_Show_YTD                     = 138 ;
   tkclFRS_Show_Variance                = 139 ;
   tkclFRS_Compare_Type                 = 140 ;
   tkclFRS_Reporting_Period_Type        = 141 ;
   tkclFRS_Report_Style                 = 142 ;
   tkclReporting_Year_Starts            = 143 ;
   tkclFRS_Report_Detail_Type           = 144 ;
   tkclFRS_Prompt_User_to_use_Budgeted_figures = 145 ;
   tkclBalance_Sheet_Headings           = 146 ;
   tkclLast_Financial_Year_Start        = 147 ;
   tkcl520_Reference_Fix_Run            = 148 ;
   tkclTax_Interface_Used               = 149 ;
   tkclSave_Tax_Files_To                = 150 ;
   tkclJournal_Processing_Period        = 151 ;
   tkclLast_Disk_Image_Version          = 152 ;
   tkclPractice_Web_Site                = 153 ;
   tkclPractice_Phone                   = 154 ;
   tkclPractice_Logo                    = 155 ;
   tkclWeb_Site_Login_URL               = 156 ;
   tkclStaff_Member_Direct_Dial         = 157 ;
   tkclContact_Details_To_Show          = 158 ;
   tkclECoding_Dont_Allow_UPIs          = 159 ;
   tkclECoding_Dont_Show_Account        = 160 ;
   tkclECoding_Dont_Show_Payees         = 161 ;
   tkclECoding_Dont_Show_GST            = 162 ;
   tkclECoding_Dont_Show_TaxInvoice     = 163 ;
   tkclScheduled_File_Attachments       = 164 ;
   tkclScheduled_Coding_Report_Style    = 165 ;
   tkclScheduled_Coding_Report_Sort_Order = 166 ;
   tkclScheduled_Coding_Report_Entry_Selection = 167 ;
   tkclScheduled_Coding_Report_Blank_Lines = 168 ;
   tkclScheduled_Coding_Report_Rule_Line = 169 ;
   tkclScheduled_Coding_Report_New_Page = 170 ;
   tkclScheduled_Coding_Report_Print_TI = 171 ;
   tkclScheduled_Coding_Report_Show_OP  = 172 ;
   tkclScheduled_Client_Note_Message    = 173 ;
   tkclCustom_Contact_Name              = 174 ;
   tkclCustom_Contact_EMail_Address     = 175 ;
   tkclCustom_Contact_Phone             = 176 ;
   tkclEmpty_Journals_Removed           = 177 ;
   tkclHighest_Manual_Account_No        = 178 ;
   tkclContact_Details_Edit_Date        = 179 ;
   tkclContact_Details_Edit_Time        = 180 ;
   tkclCopy_Narration_Dissection        = 181 ;
   tkclClient_CC_EMail_Address          = 182 ;
   tkclBAS_Report_Format                = 183 ;
   tkclWebX_Export_Scheduled_Reports    = 184 ;
   tkclECoding_WebSpace                 = 185 ;
   tkclLast_ECoding_Account_UID         = 186 ;
   tkclWeb_Export_Format                = 187 ;
   tkclMobile_No                        = 188 ;
   tkclLedger_Report_Summary            = 189 ;
   tkclLedger_Report_Show_Notes         = 190 ;
   tkclLedger_Report_Show_Quantities    = 191 ;
   tkclLedger_Report_Show_Non_Trf       = 192 ;
   tkclLedger_Report_Show_Inactive_Codes = 193 ;
   tkclLedger_Report_Bank_Contra        = 194 ;
   tkclLedger_Report_GST_Contra         = 195 ;
   tkclLedger_Report_Show_Balances      = 196 ;
   tkclFile_Read_Only                   = 197 ;
   tkclCheckOut_Scheduled_Reports       = 198 ;
   tkclExclude_From_Scheduled_Reports   = 199 ;
   tkclLedger_Report_Show_Gross_And_GST = 200 ;
   tkclSalutation                       = 201 ;
   tkclExternal_ID                      = 202 ;
   tkclSystem_LRN                       = 203 ;
   tkclBusiness_Products_Scheduled_Reports = 204 ;
   tkclBusiness_Products_Report_Format  = 205 ;
   tkclCoding_Report_Wrap_Narration     = 206 ;
   tkclLedger_Report_Wrap_Narration     = 207 ;
   tkclScheduled_Coding_Report_Wrap_Narration = 208 ;
   tkclForce_Offsite_Check_Out          = 209 ;
   tkclDisable_Offsite_Check_Out        = 210 ;
   tkclAlternate_Extract_ID             = 211 ;
   tkclUse_Alterate_ID_for_extract      = 212 ;
   tkclLast_Use_Date                    = 213 ;
   tkclUse_Basic_Chart                  = 214 ;
   tkclGroup_Name                       = 215 ;
   tkclClient_Type_Name                 = 216 ;
   tkclBAS_Include_Fuel                 = 217 ;
   tkclProfit_Report_Show_Percentage    = 218 ;
   tkclECoding_Send_Superfund           = 219 ;
   tkclGroup_LRN                        = 220 ;
   tkclClient_Type_LRN                  = 221 ;
   tkclSpare_Byte_1                     = 222 ;
   tkclSpare_Byte_2                     = 223 ;
   tkclPractice_Code                    = 224 ;
   tkclCashJ_Column_Order               = 225 ;
   tkclCashJ_Column_Width               = 226 ;
   tkclCashJ_Column_is_Hidden           = 227 ;
   tkclCashJ_Column_is_Not_Editable     = 228 ;
   tkclCashJ_Sort_Order                 = 229 ;
   tkclAcrlJ_Column_Order               = 230 ;
   tkclAcrlJ_Column_Width               = 231 ;
   tkclAcrlJ_Column_is_Hidden           = 232 ;
   tkclAcrlJ_Column_is_Not_Editable     = 233 ;
   tkclAcrlJ_Sort_Order                 = 234 ;
   tkclStockJ_Column_Order              = 235 ;
   tkclStockJ_Column_Width              = 236 ;
   tkclStockJ_Column_is_Hidden          = 237 ;
   tkclStockJ_Column_is_Not_Editable    = 238 ;
   tkclStockJ_Sort_Order                = 239 ;
   tkclYrEJ_Column_Order                = 240 ;
   tkclYrEJ_Column_Width                = 241 ;
   tkclYrEJ_Column_is_Hidden            = 242 ;
   tkclYrEJ_Column_is_Not_Editable      = 243 ;
   tkclYrEJ_Sort_Order                  = 244 ;
   tkclgstJ_Column_Order                = 245 ;
   tkclgstJ_Column_Width                = 246 ;
   tkclgstJ_Column_is_Hidden            = 247 ;
   tkclgstJ_Column_is_Not_Editable      = 248 ;
   tkclgstJ_Sort_Order                  = 249 ;
   tkclFavourite_Report_XML             = 250 ;
   tkclAll_EditMode_CES                 = 251 ;
   tkclAll_EditMode_DIS                 = 252 ;
   tkclTFN                              = 253 ;
   tkclAll_EditMode_Journals            = 254 ;
   tkclBudget_Column_Width              = 255 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClient_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClient_Rec ( P )^ do Begin
      If clRecord_Type <> tkBegin_Client then
         Raise ECorruptData.Create( SInvalidType );
      If clEOR <> tkEnd_Client then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Client_Rec ( Var O : TClient_Rec ; Var F : TIOStream );

Var
   I     : Byte;
   I1    : Byte;
   I2    : Byte;

Begin
   If IsAClient_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Client );
      F.WriteStringValue( tkclCode , clCode );
      F.WriteStringValue( tkclName , clName );
      F.WriteStringValue( tkclAddress_L1 , clAddress_L1 );
      F.WriteStringValue( tkclAddress_L2 , clAddress_L2 );
      F.WriteStringValue( tkclAddress_L3 , clAddress_L3 );
      F.WriteStringValue( tkclContact_Name , clContact_Name );
      F.WriteStringValue( tkclPhone_No , clPhone_No );
      F.WriteStringValue( tkclFax_No , clFax_No );
      F.WriteStringValue( tkclFile_Password , clFile_Password );
      F.WriteStringValue( tkclPractice_Name , clPractice_Name );
      F.WriteStringValue( tkclStaff_Member_Name , clStaff_Member_Name );
      F.WriteStringValue( tkclPractice_EMail_Address , clPractice_EMail_Address );
      F.WriteStringValue( tkclStaff_Member_EMail_Address , clStaff_Member_EMail_Address );
      F.WriteStringValue( tkclClient_EMail_Address , clClient_EMail_Address );
      F.WriteByteValue( tkclCountry , clCountry );
      F.WriteStringValue( tkclFile_Name , clFile_Name );
      F.WriteByteValue( tkclFile_Type , clFile_Type );
      F.WriteIntegerValue( tkclFile_Version , clFile_Version );
      F.WriteIntegerValue( tkclFile_Save_Count , clFile_Save_Count );
      F.WriteStringValue( tkclBankLink_Connect_Password , clBankLink_Connect_Password );
      F.WriteIntegerValue( tkclPIN_Number , clPIN_Number );
      F.WriteBooleanValue( tkclOld_Restrict_Analysis_Codes , clOld_Restrict_Analysis_Codes );
      F.WriteDateValue( tkclFinancial_Year_Starts , clFinancial_Year_Starts );
      F.WriteDateValue( tkclReport_Start_Date , clReport_Start_Date );
      F.WriteByteValue( tkclReporting_Period , clReporting_Period );
      F.WriteByteValue( tkclOld_Send_Reports_To , clOld_Send_Reports_To );
      F.WriteBooleanValue( tkclSend_Coding_Report , clSend_Coding_Report );
      F.WriteBooleanValue( tkclSend_Chart_of_Accounts , clSend_Chart_of_Accounts );
      F.WriteBooleanValue( tkclSend_Unpresented_Cheque_List , clSend_Unpresented_Cheque_List );
      F.WriteBooleanValue( tkclSend_Payee_List , clSend_Payee_List );
      F.WriteBooleanValue( tkclSend_Payee_Report , clSend_Payee_Report );
      For i := 0 to 100 do F.WriteBStringValue( tkclShort_Name , i, clShort_Name[ i ] );
      For i := 0 to 100 do F.WriteBStringValue( tkclLong_Name , i, clLong_Name[ i ] );
      F.WriteStringValue( tkclGST_Number , clGST_Number );
      F.WriteByteValue( tkclGST_Period , clGST_Period );
      F.WriteByteValue( tkclGST_Start_Month , clGST_Start_Month );
      For i := 1 to 5 do F.WriteBDateValue( tkclGST_Applies_From , i, clGST_Applies_From[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkclGST_Class_Names , i, clGST_Class_Names[ i ] );
      For i := 1 to 99 do F.WriteBByteValue( tkclGST_Class_Types , i, clGST_Class_Types[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkclGST_Account_Codes , i, clGST_Account_Codes[ i ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkclGST_Rates , I1, I2, clGST_Rates[ I1, I2 ] );
      F.WriteByteValue( tkclGST_Basis , clGST_Basis );
      F.WriteBooleanValue( tkclGST_on_Presentation_Date , clGST_on_Presentation_Date );
      F.WriteBooleanValue( tkclGST_Excludes_Accruals , clGST_Excludes_Accruals );
      F.WriteBooleanValue( tkclGST_Inclusive_Cashflow , clGST_Inclusive_Cashflow );
      F.WriteByteValue( tkclAccounting_System_Used , clAccounting_System_Used );
      F.WriteStringValue( tkclAccount_Code_Mask , clAccount_Code_Mask );
      F.WriteStringValue( tkclLoad_Client_Files_From , clLoad_Client_Files_From );
      F.WriteStringValue( tkclSave_Client_Files_To , clSave_Client_Files_To );
      F.WriteBooleanValue( tkclChart_Is_Locked , clChart_Is_Locked );
      F.WriteDateValue( tkclChart_Last_Updated , clChart_Last_Updated );
      F.WriteByteValue( tkclCoding_Report_Style , clCoding_Report_Style );
      F.WriteByteValue( tkclCoding_Report_Sort_Order , clCoding_Report_Sort_Order );
      F.WriteByteValue( tkclCoding_Report_Entry_Selection , clCoding_Report_Entry_Selection );
      F.WriteByteValue( tkclCoding_Report_Blank_Lines , clCoding_Report_Blank_Lines );
      F.WriteBooleanValue( tkclCoding_Report_Rule_Line , clCoding_Report_Rule_Line );
      F.WriteBooleanValue( tkclCoding_Report_New_Page , clCoding_Report_New_Page );
      For i := 1 to 9 do F.WriteBStringValue( tkclOld_Division_Names , i, clOld_Division_Names[ i ] );
      For i := 0 to 40 do F.WriteBStringValue( tkclCF_Headings , i, clCF_Headings[ i ] );
      For i := 0 to 40 do F.WriteBStringValue( tkclPR_Headings , i, clPR_Headings[ i ] );
      F.WriteIntegerValue( tkclMagic_Number , clMagic_Number );
      F.WriteIntegerValue( tkclException_Options , clException_Options );
      F.WriteDateValue( tkclPeriod_Start_Date , clPeriod_Start_Date );
      F.WriteDateValue( tkclPeriod_End_Date , clPeriod_End_Date );
      F.WriteBooleanValue( tkclFRS_Print_Chart_Codes , clFRS_Print_Chart_Codes );
      F.WriteStringValue( tkclBankLink_Code , clBankLink_Code );
      F.WriteIntegerValue( tkclDisk_Sequence_No , clDisk_Sequence_No );
      F.WriteIntegerValue( tkclStaff_Member_LRN , clStaff_Member_LRN );
      F.WriteBooleanValue( tkclSuppress_Check_for_New_TXns , clSuppress_Check_for_New_TXns );
      F.WriteByteValue( tkclDownload_From , clDownload_From );
      F.WriteIntegerValue( tkclLast_Batch_Number , clLast_Batch_Number );
      F.WriteStringValue( tkclOld_GST_Class_Codes , clOld_GST_Class_Codes );
      For i := 1 to 9 do F.WriteBStringValue( tkclDivision_Code_List , i, clDivision_Code_List[ i ] );
      F.WriteByteValue( tkclSB_Export_As , clSB_Export_As );
      F.WriteByteValue( tkclSB_Upload_To , clSB_Upload_To );
      F.WriteBooleanValue( tkclCoding_Report_Print_TI , clCoding_Report_Print_TI );
      F.WriteBooleanValue( tkclV31_GST_Format_Used , clV31_GST_Format_Used );
      F.WriteBooleanValue( tkclEmail_Scheduled_Reports , clEmail_Scheduled_Reports );
      For i := 1 to 10 do F.WriteBStringValue( tkclOLD_BAS_Special_Accounts , i, clOLD_BAS_Special_Accounts[ i ] );
      For i := 1 to 99 do F.WriteBStringValue( tkclGST_Class_Codes , i, clGST_Class_Codes[ i ] );
      F.WriteStringValue( tkclTax_Ledger_Code , clTax_Ledger_Code );
      F.WriteBooleanValue( tkclEOY_Locked_SB_Only , clEOY_Locked_SB_Only );
      For i := 1 to 100 do F.WriteBByteValue( tkclBAS_Field_Number , i, clBAS_Field_Number[ i ] );
      For i := 1 to 100 do F.WriteBByteValue( tkclBAS_Field_Source , i, clBAS_Field_Source[ i ] );
      For i := 1 to 100 do F.WriteBStringValue( tkclBAS_Field_Account_Code , i, clBAS_Field_Account_Code[ i ] );
      For i := 1 to 100 do F.WriteBByteValue( tkclBAS_Field_Balance_Type , i, clBAS_Field_Balance_Type[ i ] );
      For i := 1 to 100 do F.WriteBMoneyValue( tkclBAS_Field_Percent , i, clBAS_Field_Percent[ i ] );
      For i := 1 to 100 do F.WriteBMoneyValue( tkclGST_Business_Percent , i, clGST_Business_Percent[ i ] );
      F.WriteByteValue( tkclBAS_Calculation_Method , clBAS_Calculation_Method );
      F.WriteBooleanValue( tkclBAS_Dont_Print_Calc_Sheet , clBAS_Dont_Print_Calc_Sheet );
      F.WriteByteValue( tkclBAS_PAYG_Withheld_Period , clBAS_PAYG_Withheld_Period );
      F.WriteBooleanValue( tkclFax_Scheduled_Reports , clFax_Scheduled_Reports );
      For i := 0 to 200 do F.WriteBStringValue( tkclGraph_Headings , i, clGraph_Headings[ i ] );
      For i := 0 to 200 do F.WriteBStringValue( tkclNotes , i, clNotes[ i ] );
      F.WriteByteValue( tkclCheques_Expire_When , clCheques_Expire_When );
      F.WriteBooleanValue( tkclShow_Notes_On_Open , clShow_Notes_On_Open );
      F.WriteByteValue( tkclECoding_Entry_Selection , clECoding_Entry_Selection );
      F.WriteBooleanValue( tkclECoding_Dont_Send_Chart , clECoding_Dont_Send_Chart );
      F.WriteBooleanValue( tkclECoding_Dont_Send_Payees , clECoding_Dont_Send_Payees );
      F.WriteBooleanValue( tkclECoding_Dont_Show_Quantity , clECoding_Dont_Show_Quantity );
      F.WriteIntegerValue( tkclECoding_Last_File_No , clECoding_Last_File_No );
      F.WriteIntegerValue( tkclECoding_Last_File_No_Imported , clECoding_Last_File_No_Imported );
      F.WriteBooleanValue( tkclECoding_Export_Scheduled_Reports , clECoding_Export_Scheduled_Reports );
      F.WriteByteValue( tkclEmail_Report_Format , clEmail_Report_Format );
      F.WriteByteValue( tkclBAS_PAYG_Instalment_Period , clBAS_PAYG_Instalment_Period );
      F.WriteBooleanValue( tkclBAS_Include_FBT_WET_LCT , clBAS_Include_FBT_WET_LCT );
      F.WriteByteValue( tkclBAS_Last_GST_Option , clBAS_Last_GST_Option );
      F.WriteByteValue( tkclBAS_Last_PAYG_Instalment_Option , clBAS_Last_PAYG_Instalment_Option );
      F.WriteStringValue( tkclECoding_Default_Password , clECoding_Default_Password );
      F.WriteIntegerValue( tkclECoding_Import_Options , clECoding_Import_Options );
      F.WriteStringValue( tkclECoding_Last_Import_Dir , clECoding_Last_Import_Dir );
      F.WriteStringValue( tkclECoding_Last_Export_Dir , clECoding_Last_Export_Dir );
      F.WriteBooleanValue( tkclCoding_Report_Show_OP , clCoding_Report_Show_OP );
      F.WriteBooleanValue( tkclFRS_Show_Quantity , clFRS_Show_Quantity );
      F.WriteByteValue( tkclCflw_Cash_On_Hand_Style , clCflw_Cash_On_Hand_Style );
      F.WriteBooleanValue( tkclCSV_Export_Scheduled_Reports , clCSV_Export_Scheduled_Reports );
      F.WriteBooleanValue( tkclFRS_Show_YTD , clFRS_Show_YTD );
      F.WriteBooleanValue( tkclFRS_Show_Variance , clFRS_Show_Variance );
      F.WriteByteValue( tkclFRS_Compare_Type , clFRS_Compare_Type );
      F.WriteByteValue( tkclFRS_Reporting_Period_Type , clFRS_Reporting_Period_Type );
      F.WriteByteValue( tkclFRS_Report_Style , clFRS_Report_Style );
      F.WriteIntegerValue( tkclReporting_Year_Starts , clReporting_Year_Starts );
      F.WriteByteValue( tkclFRS_Report_Detail_Type , clFRS_Report_Detail_Type );
      F.WriteBooleanValue( tkclFRS_Prompt_User_to_use_Budgeted_figures , clFRS_Prompt_User_to_use_Budgeted_figures );
      For i := 0 to 30 do F.WriteBStringValue( tkclBalance_Sheet_Headings , i, clBalance_Sheet_Headings[ i ] );
      F.WriteIntegerValue( tkclLast_Financial_Year_Start , clLast_Financial_Year_Start );
      F.WriteBooleanValue( tkcl520_Reference_Fix_Run , cl520_Reference_Fix_Run );
      F.WriteByteValue( tkclTax_Interface_Used , clTax_Interface_Used );
      F.WriteAnsiStringValue( tkclSave_Tax_Files_To , clSave_Tax_Files_To );
      F.WriteByteValue( tkclJournal_Processing_Period , clJournal_Processing_Period );
      F.WriteIntegerValue( tkclLast_Disk_Image_Version , clLast_Disk_Image_Version );
      F.WriteAnsiStringValue( tkclPractice_Web_Site , clPractice_Web_Site );
      F.WriteStringValue( tkclPractice_Phone , clPractice_Phone );
      F.WriteAnsiStringValue( tkclPractice_Logo , clPractice_Logo );
      F.WriteAnsiStringValue( tkclWeb_Site_Login_URL , clWeb_Site_Login_URL );
      F.WriteStringValue( tkclStaff_Member_Direct_Dial , clStaff_Member_Direct_Dial );
      F.WriteByteValue( tkclContact_Details_To_Show , clContact_Details_To_Show );
      F.WriteBooleanValue( tkclECoding_Dont_Allow_UPIs , clECoding_Dont_Allow_UPIs );
      F.WriteBooleanValue( tkclECoding_Dont_Show_Account , clECoding_Dont_Show_Account );
      F.WriteBooleanValue( tkclECoding_Dont_Show_Payees , clECoding_Dont_Show_Payees );
      F.WriteBooleanValue( tkclECoding_Dont_Show_GST , clECoding_Dont_Show_GST );
      F.WriteBooleanValue( tkclECoding_Dont_Show_TaxInvoice , clECoding_Dont_Show_TaxInvoice );
      F.WriteAnsiStringValue( tkclScheduled_File_Attachments , clScheduled_File_Attachments );
      F.WriteByteValue( tkclScheduled_Coding_Report_Style , clScheduled_Coding_Report_Style );
      F.WriteByteValue( tkclScheduled_Coding_Report_Sort_Order , clScheduled_Coding_Report_Sort_Order );
      F.WriteByteValue( tkclScheduled_Coding_Report_Entry_Selection , clScheduled_Coding_Report_Entry_Selection );
      F.WriteByteValue( tkclScheduled_Coding_Report_Blank_Lines , clScheduled_Coding_Report_Blank_Lines );
      F.WriteBooleanValue( tkclScheduled_Coding_Report_Rule_Line , clScheduled_Coding_Report_Rule_Line );
      F.WriteBooleanValue( tkclScheduled_Coding_Report_New_Page , clScheduled_Coding_Report_New_Page );
      F.WriteBooleanValue( tkclScheduled_Coding_Report_Print_TI , clScheduled_Coding_Report_Print_TI );
      F.WriteBooleanValue( tkclScheduled_Coding_Report_Show_OP , clScheduled_Coding_Report_Show_OP );
      F.WriteAnsiStringValue( tkclScheduled_Client_Note_Message , clScheduled_Client_Note_Message );
      F.WriteStringValue( tkclCustom_Contact_Name , clCustom_Contact_Name );
      F.WriteStringValue( tkclCustom_Contact_EMail_Address , clCustom_Contact_EMail_Address );
      F.WriteStringValue( tkclCustom_Contact_Phone , clCustom_Contact_Phone );
      F.WriteBooleanValue( tkclEmpty_Journals_Removed , clEmpty_Journals_Removed );
      F.WriteIntegerValue( tkclHighest_Manual_Account_No , clHighest_Manual_Account_No );
      F.WriteIntegerValue( tkclContact_Details_Edit_Date , clContact_Details_Edit_Date );
      F.WriteIntegerValue( tkclContact_Details_Edit_Time , clContact_Details_Edit_Time );
      F.WriteBooleanValue( tkclCopy_Narration_Dissection , clCopy_Narration_Dissection );
      F.WriteStringValue( tkclClient_CC_EMail_Address , clClient_CC_EMail_Address );
      F.WriteByteValue( tkclBAS_Report_Format , clBAS_Report_Format );
      F.WriteBooleanValue( tkclWebX_Export_Scheduled_Reports , clWebX_Export_Scheduled_Reports );
      F.WriteIntegerValue( tkclECoding_WebSpace , clECoding_WebSpace );
      F.WriteIntegerValue( tkclLast_ECoding_Account_UID , clLast_ECoding_Account_UID );
      F.WriteByteValue( tkclWeb_Export_Format , clWeb_Export_Format );
      F.WriteStringValue( tkclMobile_No , clMobile_No );
      F.WriteBooleanValue( tkclLedger_Report_Summary , clLedger_Report_Summary );
      F.WriteBooleanValue( tkclLedger_Report_Show_Notes , clLedger_Report_Show_Notes );
      F.WriteBooleanValue( tkclLedger_Report_Show_Quantities , clLedger_Report_Show_Quantities );
      F.WriteBooleanValue( tkclLedger_Report_Show_Non_Trf , clLedger_Report_Show_Non_Trf );
      F.WriteBooleanValue( tkclLedger_Report_Show_Inactive_Codes , clLedger_Report_Show_Inactive_Codes );
      F.WriteByteValue( tkclLedger_Report_Bank_Contra , clLedger_Report_Bank_Contra );
      F.WriteByteValue( tkclLedger_Report_GST_Contra , clLedger_Report_GST_Contra );
      F.WriteBooleanValue( tkclLedger_Report_Show_Balances , clLedger_Report_Show_Balances );
      F.WriteBooleanValue( tkclFile_Read_Only , clFile_Read_Only );
      F.WriteBooleanValue( tkclCheckOut_Scheduled_Reports , clCheckOut_Scheduled_Reports );
      F.WriteAnsiStringValue( tkclExclude_From_Scheduled_Reports , clExclude_From_Scheduled_Reports );
      F.WriteBooleanValue( tkclLedger_Report_Show_Gross_And_GST , clLedger_Report_Show_Gross_And_GST );
      F.WriteStringValue( tkclSalutation , clSalutation );
      F.WriteAnsiStringValue( tkclExternal_ID , clExternal_ID );
      F.WriteIntegerValue( tkclSystem_LRN , clSystem_LRN );
      F.WriteBooleanValue( tkclBusiness_Products_Scheduled_Reports , clBusiness_Products_Scheduled_Reports );
      F.WriteByteValue( tkclBusiness_Products_Report_Format , clBusiness_Products_Report_Format );
      F.WriteBooleanValue( tkclCoding_Report_Wrap_Narration , clCoding_Report_Wrap_Narration );
      F.WriteBooleanValue( tkclLedger_Report_Wrap_Narration , clLedger_Report_Wrap_Narration );
      F.WriteBooleanValue( tkclScheduled_Coding_Report_Wrap_Narration , clScheduled_Coding_Report_Wrap_Narration );
      F.WriteBooleanValue( tkclForce_Offsite_Check_Out , clForce_Offsite_Check_Out );
      F.WriteBooleanValue( tkclDisable_Offsite_Check_Out , clDisable_Offsite_Check_Out );
      F.WriteAnsiStringValue( tkclAlternate_Extract_ID , clAlternate_Extract_ID );
      F.WriteBooleanValue( tkclUse_Alterate_ID_for_extract , clUse_Alterate_ID_for_extract );
      F.WriteDateValue( tkclLast_Use_Date , clLast_Use_Date );
      F.WriteBooleanValue( tkclUse_Basic_Chart , clUse_Basic_Chart );
      F.WriteAnsiStringValue( tkclGroup_Name , clGroup_Name );
      F.WriteAnsiStringValue( tkclClient_Type_Name , clClient_Type_Name );
      F.WriteBooleanValue( tkclBAS_Include_Fuel , clBAS_Include_Fuel );
      F.WriteBooleanValue( tkclProfit_Report_Show_Percentage , clProfit_Report_Show_Percentage );
      F.WriteBooleanValue( tkclECoding_Send_Superfund , clECoding_Send_Superfund );
      F.WriteIntegerValue( tkclGroup_LRN , clGroup_LRN );
      F.WriteIntegerValue( tkclClient_Type_LRN , clClient_Type_LRN );
      F.WriteByteValue( tkclSpare_Byte_1 , clSpare_Byte_1 );
      F.WriteByteValue( tkclSpare_Byte_2 , clSpare_Byte_2 );
      F.WriteAnsiStringValue( tkclPractice_Code , clPractice_Code );
      For i := 0 to 32 do F.WriteBByteValue( tkclCashJ_Column_Order , i, clCashJ_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkclCashJ_Column_Width , i, clCashJ_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclCashJ_Column_is_Hidden , i, clCashJ_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclCashJ_Column_is_Not_Editable , i, clCashJ_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkclCashJ_Sort_Order , clCashJ_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkclAcrlJ_Column_Order , i, clAcrlJ_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkclAcrlJ_Column_Width , i, clAcrlJ_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclAcrlJ_Column_is_Hidden , i, clAcrlJ_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclAcrlJ_Column_is_Not_Editable , i, clAcrlJ_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkclAcrlJ_Sort_Order , clAcrlJ_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkclStockJ_Column_Order , i, clStockJ_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkclStockJ_Column_Width , i, clStockJ_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclStockJ_Column_is_Hidden , i, clStockJ_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclStockJ_Column_is_Not_Editable , i, clStockJ_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkclStockJ_Sort_Order , clStockJ_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkclYrEJ_Column_Order , i, clYrEJ_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkclYrEJ_Column_Width , i, clYrEJ_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclYrEJ_Column_is_Hidden , i, clYrEJ_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclYrEJ_Column_is_Not_Editable , i, clYrEJ_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkclYrEJ_Sort_Order , clYrEJ_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkclgstJ_Column_Order , i, clgstJ_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkclgstJ_Column_Width , i, clgstJ_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclgstJ_Column_is_Hidden , i, clgstJ_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkclgstJ_Column_is_Not_Editable , i, clgstJ_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkclgstJ_Sort_Order , clgstJ_Sort_Order );
      F.WriteAnsiStringValue( tkclFavourite_Report_XML , clFavourite_Report_XML );
      F.WriteBooleanValue( tkclAll_EditMode_CES , clAll_EditMode_CES );
      F.WriteBooleanValue( tkclAll_EditMode_DIS , clAll_EditMode_DIS );
      F.WriteStringValue( tkclTFN , clTFN );
      For i := 0 to 7 do F.WriteBBooleanValue( tkclAll_EditMode_Journals , i, clAll_EditMode_Journals[ i ] );
      For i := 0 to 14 do F.WriteBIntegerValue( tkclBudget_Column_Width , i, clBudget_Column_Width[ i ] );
      F.WriteToken( tkEnd_Client );
   end;
end; { of Write_Client_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Client_Rec ( Var O : TClient_Rec; Var F : TIOStream );

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
   FillChar( O, Client_Rec_Size, 0 );
   O.clRecord_Type := tkBegin_Client;
   O.clEOR := tkEnd_Client;
   Token := tkBegin_Client;

   While Token <> tkEnd_Client do With O do
   Begin
      Case Token of
         tkBegin_Client :; { Do Nothing }
         tkEnd_Client :; { Do Nothing }
         tkclCode                             : clCode := F.ReadStringValue;
         tkclName                             : clName := F.ReadStringValue;
         tkclAddress_L1                       : clAddress_L1 := F.ReadStringValue;
         tkclAddress_L2                       : clAddress_L2 := F.ReadStringValue;
         tkclAddress_L3                       : clAddress_L3 := F.ReadStringValue;
         tkclContact_Name                     : clContact_Name := F.ReadStringValue;
         tkclPhone_No                         : clPhone_No := F.ReadStringValue;
         tkclFax_No                           : clFax_No := F.ReadStringValue;
         tkclFile_Password                    : clFile_Password := F.ReadStringValue;
         tkclPractice_Name                    : clPractice_Name := F.ReadStringValue;
         tkclStaff_Member_Name                : clStaff_Member_Name := F.ReadStringValue;
         tkclPractice_EMail_Address           : clPractice_EMail_Address := F.ReadStringValue;
         tkclStaff_Member_EMail_Address       : clStaff_Member_EMail_Address := F.ReadStringValue;
         tkclClient_EMail_Address             : clClient_EMail_Address := F.ReadStringValue;
         tkclCountry                          : clCountry := F.ReadByteValue;
         tkclFile_Name                        : clFile_Name := F.ReadStringValue;
         tkclFile_Type                        : clFile_Type := F.ReadByteValue;
         tkclFile_Version                     : clFile_Version := F.ReadIntegerValue;
         tkclFile_Save_Count                  : clFile_Save_Count := F.ReadIntegerValue;
         tkclBankLink_Connect_Password        : clBankLink_Connect_Password := F.ReadStringValue;
         tkclPIN_Number                       : clPIN_Number := F.ReadIntegerValue;
         tkclOld_Restrict_Analysis_Codes      : clOld_Restrict_Analysis_Codes := F.ReadBooleanValue;
         tkclFinancial_Year_Starts            : clFinancial_Year_Starts := F.ReadDateValue;
         tkclReport_Start_Date                : clReport_Start_Date := F.ReadDateValue;
         tkclReporting_Period                 : clReporting_Period := F.ReadByteValue;
         tkclOld_Send_Reports_To              : clOld_Send_Reports_To := F.ReadByteValue;
         tkclSend_Coding_Report               : clSend_Coding_Report := F.ReadBooleanValue;
         tkclSend_Chart_of_Accounts           : clSend_Chart_of_Accounts := F.ReadBooleanValue;
         tkclSend_Unpresented_Cheque_List     : clSend_Unpresented_Cheque_List := F.ReadBooleanValue;
         tkclSend_Payee_List                  : clSend_Payee_List := F.ReadBooleanValue;
         tkclSend_Payee_Report                : clSend_Payee_Report := F.ReadBooleanValue;
         tkclShort_Name                       : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 100, 'clShort_Name' );
               clShort_Name[ I ] := S;
            end;
         tkclLong_Name                        : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 100, 'clLong_Name' );
               clLong_Name[ I ] := S;
            end;
         tkclGST_Number                       : clGST_Number := F.ReadStringValue;
         tkclGST_Period                       : clGST_Period := F.ReadByteValue;
         tkclGST_Start_Month                  : clGST_Start_Month := F.ReadByteValue;
         tkclGST_Applies_From                 : 
            Begin
               D := F.ReadBDateValue( I );
               CheckBounds( I, 1, 5, 'clGST_Applies_From' );
               clGST_Applies_From[ I ] := D;
            end;
         tkclGST_Class_Names                  : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'clGST_Class_Names' );
               clGST_Class_Names[ I ] := S;
            end;
         tkclGST_Class_Types                  : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 99, 'clGST_Class_Types' );
               clGST_Class_Types[ I ] := B;
            end;
         tkclGST_Account_Codes                : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'clGST_Account_Codes' );
               clGST_Account_Codes[ I ] := S;
            end;
         tkclGST_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'clGST_Rates' );
               CheckBounds( I2, 1, 5, 'clGST_Rates' );
               clGST_Rates[ I1, I2 ] := M;
            end;
         tkclGST_Basis                        : clGST_Basis := F.ReadByteValue;
         tkclGST_on_Presentation_Date         : clGST_on_Presentation_Date := F.ReadBooleanValue;
         tkclGST_Excludes_Accruals            : clGST_Excludes_Accruals := F.ReadBooleanValue;
         tkclGST_Inclusive_Cashflow           : clGST_Inclusive_Cashflow := F.ReadBooleanValue;
         tkclAccounting_System_Used           : clAccounting_System_Used := F.ReadByteValue;
         tkclAccount_Code_Mask                : clAccount_Code_Mask := F.ReadStringValue;
         tkclLoad_Client_Files_From           : clLoad_Client_Files_From := F.ReadStringValue;
         tkclSave_Client_Files_To             : clSave_Client_Files_To := F.ReadStringValue;
         tkclChart_Is_Locked                  : clChart_Is_Locked := F.ReadBooleanValue;
         tkclChart_Last_Updated               : clChart_Last_Updated := F.ReadDateValue;
         tkclCoding_Report_Style              : clCoding_Report_Style := F.ReadByteValue;
         tkclCoding_Report_Sort_Order         : clCoding_Report_Sort_Order := F.ReadByteValue;
         tkclCoding_Report_Entry_Selection    : clCoding_Report_Entry_Selection := F.ReadByteValue;
         tkclCoding_Report_Blank_Lines        : clCoding_Report_Blank_Lines := F.ReadByteValue;
         tkclCoding_Report_Rule_Line          : clCoding_Report_Rule_Line := F.ReadBooleanValue;
         tkclCoding_Report_New_Page           : clCoding_Report_New_Page := F.ReadBooleanValue;
         tkclOld_Division_Names               : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 9, 'clOld_Division_Names' );
               clOld_Division_Names[ I ] := S;
            end;
         tkclCF_Headings                      : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 40, 'clCF_Headings' );
               clCF_Headings[ I ] := S;
            end;
         tkclPR_Headings                      : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 40, 'clPR_Headings' );
               clPR_Headings[ I ] := S;
            end;
         tkclMagic_Number                     : clMagic_Number := F.ReadIntegerValue;
         tkclException_Options                : clException_Options := F.ReadIntegerValue;
         tkclPeriod_Start_Date                : clPeriod_Start_Date := F.ReadDateValue;
         tkclPeriod_End_Date                  : clPeriod_End_Date := F.ReadDateValue;
         tkclFRS_Print_Chart_Codes            : clFRS_Print_Chart_Codes := F.ReadBooleanValue;
         tkclBankLink_Code                    : clBankLink_Code := F.ReadStringValue;
         tkclDisk_Sequence_No                 : clDisk_Sequence_No := F.ReadIntegerValue;
         tkclStaff_Member_LRN                 : clStaff_Member_LRN := F.ReadIntegerValue;
         tkclSuppress_Check_for_New_TXns      : clSuppress_Check_for_New_TXns := F.ReadBooleanValue;
         tkclDownload_From                    : clDownload_From := F.ReadByteValue;
         tkclLast_Batch_Number                : clLast_Batch_Number := F.ReadIntegerValue;
         tkclOld_GST_Class_Codes              : clOld_GST_Class_Codes := F.ReadStringValue;
         tkclDivision_Code_List               : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 9, 'clDivision_Code_List' );
               clDivision_Code_List[ I ] := S;
            end;
         tkclSB_Export_As                     : clSB_Export_As := F.ReadByteValue;
         tkclSB_Upload_To                     : clSB_Upload_To := F.ReadByteValue;
         tkclCoding_Report_Print_TI           : clCoding_Report_Print_TI := F.ReadBooleanValue;
         tkclV31_GST_Format_Used              : clV31_GST_Format_Used := F.ReadBooleanValue;
         tkclEmail_Scheduled_Reports          : clEmail_Scheduled_Reports := F.ReadBooleanValue;
         tkclOLD_BAS_Special_Accounts         : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 10, 'clOLD_BAS_Special_Accounts' );
               clOLD_BAS_Special_Accounts[ I ] := S;
            end;
         tkclGST_Class_Codes                  : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'clGST_Class_Codes' );
               clGST_Class_Codes[ I ] := S;
            end;
         tkclTax_Ledger_Code                  : clTax_Ledger_Code := F.ReadStringValue;
         tkclEOY_Locked_SB_Only               : clEOY_Locked_SB_Only := F.ReadBooleanValue;
         tkclBAS_Field_Number                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'clBAS_Field_Number' );
               clBAS_Field_Number[ I ] := B;
            end;
         tkclBAS_Field_Source                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'clBAS_Field_Source' );
               clBAS_Field_Source[ I ] := B;
            end;
         tkclBAS_Field_Account_Code           : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 100, 'clBAS_Field_Account_Code' );
               clBAS_Field_Account_Code[ I ] := S;
            end;
         tkclBAS_Field_Balance_Type           : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 100, 'clBAS_Field_Balance_Type' );
               clBAS_Field_Balance_Type[ I ] := B;
            end;
         tkclBAS_Field_Percent                : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 100, 'clBAS_Field_Percent' );
               clBAS_Field_Percent[ I ] := M;
            end;
         tkclGST_Business_Percent             : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 100, 'clGST_Business_Percent' );
               clGST_Business_Percent[ I ] := M;
            end;
         tkclBAS_Calculation_Method           : clBAS_Calculation_Method := F.ReadByteValue;
         tkclBAS_Dont_Print_Calc_Sheet        : clBAS_Dont_Print_Calc_Sheet := F.ReadBooleanValue;
         tkclBAS_PAYG_Withheld_Period         : clBAS_PAYG_Withheld_Period := F.ReadByteValue;
         tkclFax_Scheduled_Reports            : clFax_Scheduled_Reports := F.ReadBooleanValue;
         tkclGraph_Headings                   : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 200, 'clGraph_Headings' );
               clGraph_Headings[ I ] := S;
            end;
         tkclNotes                            : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 200, 'clNotes' );
               clNotes[ I ] := S;
            end;
         tkclCheques_Expire_When              : clCheques_Expire_When := F.ReadByteValue;
         tkclShow_Notes_On_Open               : clShow_Notes_On_Open := F.ReadBooleanValue;
         tkclECoding_Entry_Selection          : clECoding_Entry_Selection := F.ReadByteValue;
         tkclECoding_Dont_Send_Chart          : clECoding_Dont_Send_Chart := F.ReadBooleanValue;
         tkclECoding_Dont_Send_Payees         : clECoding_Dont_Send_Payees := F.ReadBooleanValue;
         tkclECoding_Dont_Show_Quantity       : clECoding_Dont_Show_Quantity := F.ReadBooleanValue;
         tkclECoding_Last_File_No             : clECoding_Last_File_No := F.ReadIntegerValue;
         tkclECoding_Last_File_No_Imported    : clECoding_Last_File_No_Imported := F.ReadIntegerValue;
         tkclECoding_Export_Scheduled_Reports : clECoding_Export_Scheduled_Reports := F.ReadBooleanValue;
         tkclEmail_Report_Format              : clEmail_Report_Format := F.ReadByteValue;
         tkclBAS_PAYG_Instalment_Period       : clBAS_PAYG_Instalment_Period := F.ReadByteValue;
         tkclBAS_Include_FBT_WET_LCT          : clBAS_Include_FBT_WET_LCT := F.ReadBooleanValue;
         tkclBAS_Last_GST_Option              : clBAS_Last_GST_Option := F.ReadByteValue;
         tkclBAS_Last_PAYG_Instalment_Option  : clBAS_Last_PAYG_Instalment_Option := F.ReadByteValue;
         tkclECoding_Default_Password         : clECoding_Default_Password := F.ReadStringValue;
         tkclECoding_Import_Options           : clECoding_Import_Options := F.ReadIntegerValue;
         tkclECoding_Last_Import_Dir          : clECoding_Last_Import_Dir := F.ReadStringValue;
         tkclECoding_Last_Export_Dir          : clECoding_Last_Export_Dir := F.ReadStringValue;
         tkclCoding_Report_Show_OP            : clCoding_Report_Show_OP := F.ReadBooleanValue;
         tkclFRS_Show_Quantity                : clFRS_Show_Quantity := F.ReadBooleanValue;
         tkclCflw_Cash_On_Hand_Style          : clCflw_Cash_On_Hand_Style := F.ReadByteValue;
         tkclCSV_Export_Scheduled_Reports     : clCSV_Export_Scheduled_Reports := F.ReadBooleanValue;
         tkclFRS_Show_YTD                     : clFRS_Show_YTD := F.ReadBooleanValue;
         tkclFRS_Show_Variance                : clFRS_Show_Variance := F.ReadBooleanValue;
         tkclFRS_Compare_Type                 : clFRS_Compare_Type := F.ReadByteValue;
         tkclFRS_Reporting_Period_Type        : clFRS_Reporting_Period_Type := F.ReadByteValue;
         tkclFRS_Report_Style                 : clFRS_Report_Style := F.ReadByteValue;
         tkclReporting_Year_Starts            : clReporting_Year_Starts := F.ReadIntegerValue;
         tkclFRS_Report_Detail_Type           : clFRS_Report_Detail_Type := F.ReadByteValue;
         tkclFRS_Prompt_User_to_use_Budgeted_figures : clFRS_Prompt_User_to_use_Budgeted_figures := F.ReadBooleanValue;
         tkclBalance_Sheet_Headings           : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 0, 30, 'clBalance_Sheet_Headings' );
               clBalance_Sheet_Headings[ I ] := S;
            end;
         tkclLast_Financial_Year_Start        : clLast_Financial_Year_Start := F.ReadIntegerValue;
         tkcl520_Reference_Fix_Run            : cl520_Reference_Fix_Run := F.ReadBooleanValue;
         tkclTax_Interface_Used               : clTax_Interface_Used := F.ReadByteValue;
         tkclSave_Tax_Files_To                : clSave_Tax_Files_To := F.ReadAnsiStringValue;
         tkclJournal_Processing_Period        : clJournal_Processing_Period := F.ReadByteValue;
         tkclLast_Disk_Image_Version          : clLast_Disk_Image_Version := F.ReadIntegerValue;
         tkclPractice_Web_Site                : clPractice_Web_Site := F.ReadAnsiStringValue;
         tkclPractice_Phone                   : clPractice_Phone := F.ReadStringValue;
         tkclPractice_Logo                    : clPractice_Logo := F.ReadAnsiStringValue;
         tkclWeb_Site_Login_URL               : clWeb_Site_Login_URL := F.ReadAnsiStringValue;
         tkclStaff_Member_Direct_Dial         : clStaff_Member_Direct_Dial := F.ReadStringValue;
         tkclContact_Details_To_Show          : clContact_Details_To_Show := F.ReadByteValue;
         tkclECoding_Dont_Allow_UPIs          : clECoding_Dont_Allow_UPIs := F.ReadBooleanValue;
         tkclECoding_Dont_Show_Account        : clECoding_Dont_Show_Account := F.ReadBooleanValue;
         tkclECoding_Dont_Show_Payees         : clECoding_Dont_Show_Payees := F.ReadBooleanValue;
         tkclECoding_Dont_Show_GST            : clECoding_Dont_Show_GST := F.ReadBooleanValue;
         tkclECoding_Dont_Show_TaxInvoice     : clECoding_Dont_Show_TaxInvoice := F.ReadBooleanValue;
         tkclScheduled_File_Attachments       : clScheduled_File_Attachments := F.ReadAnsiStringValue;
         tkclScheduled_Coding_Report_Style    : clScheduled_Coding_Report_Style := F.ReadByteValue;
         tkclScheduled_Coding_Report_Sort_Order : clScheduled_Coding_Report_Sort_Order := F.ReadByteValue;
         tkclScheduled_Coding_Report_Entry_Selection : clScheduled_Coding_Report_Entry_Selection := F.ReadByteValue;
         tkclScheduled_Coding_Report_Blank_Lines : clScheduled_Coding_Report_Blank_Lines := F.ReadByteValue;
         tkclScheduled_Coding_Report_Rule_Line : clScheduled_Coding_Report_Rule_Line := F.ReadBooleanValue;
         tkclScheduled_Coding_Report_New_Page : clScheduled_Coding_Report_New_Page := F.ReadBooleanValue;
         tkclScheduled_Coding_Report_Print_TI : clScheduled_Coding_Report_Print_TI := F.ReadBooleanValue;
         tkclScheduled_Coding_Report_Show_OP  : clScheduled_Coding_Report_Show_OP := F.ReadBooleanValue;
         tkclScheduled_Client_Note_Message    : clScheduled_Client_Note_Message := F.ReadAnsiStringValue;
         tkclCustom_Contact_Name              : clCustom_Contact_Name := F.ReadStringValue;
         tkclCustom_Contact_EMail_Address     : clCustom_Contact_EMail_Address := F.ReadStringValue;
         tkclCustom_Contact_Phone             : clCustom_Contact_Phone := F.ReadStringValue;
         tkclEmpty_Journals_Removed           : clEmpty_Journals_Removed := F.ReadBooleanValue;
         tkclHighest_Manual_Account_No        : clHighest_Manual_Account_No := F.ReadIntegerValue;
         tkclContact_Details_Edit_Date        : clContact_Details_Edit_Date := F.ReadIntegerValue;
         tkclContact_Details_Edit_Time        : clContact_Details_Edit_Time := F.ReadIntegerValue;
         tkclCopy_Narration_Dissection        : clCopy_Narration_Dissection := F.ReadBooleanValue;
         tkclClient_CC_EMail_Address          : clClient_CC_EMail_Address := F.ReadStringValue;
         tkclBAS_Report_Format                : clBAS_Report_Format := F.ReadByteValue;
         tkclWebX_Export_Scheduled_Reports    : clWebX_Export_Scheduled_Reports := F.ReadBooleanValue;
         tkclECoding_WebSpace                 : clECoding_WebSpace := F.ReadIntegerValue;
         tkclLast_ECoding_Account_UID         : clLast_ECoding_Account_UID := F.ReadIntegerValue;
         tkclWeb_Export_Format                : clWeb_Export_Format := F.ReadByteValue;
         tkclMobile_No                        : clMobile_No := F.ReadStringValue;
         tkclLedger_Report_Summary            : clLedger_Report_Summary := F.ReadBooleanValue;
         tkclLedger_Report_Show_Notes         : clLedger_Report_Show_Notes := F.ReadBooleanValue;
         tkclLedger_Report_Show_Quantities    : clLedger_Report_Show_Quantities := F.ReadBooleanValue;
         tkclLedger_Report_Show_Non_Trf       : clLedger_Report_Show_Non_Trf := F.ReadBooleanValue;
         tkclLedger_Report_Show_Inactive_Codes : clLedger_Report_Show_Inactive_Codes := F.ReadBooleanValue;
         tkclLedger_Report_Bank_Contra        : clLedger_Report_Bank_Contra := F.ReadByteValue;
         tkclLedger_Report_GST_Contra         : clLedger_Report_GST_Contra := F.ReadByteValue;
         tkclLedger_Report_Show_Balances      : clLedger_Report_Show_Balances := F.ReadBooleanValue;
         tkclFile_Read_Only                   : clFile_Read_Only := F.ReadBooleanValue;
         tkclCheckOut_Scheduled_Reports       : clCheckOut_Scheduled_Reports := F.ReadBooleanValue;
         tkclExclude_From_Scheduled_Reports   : clExclude_From_Scheduled_Reports := F.ReadAnsiStringValue;
         tkclLedger_Report_Show_Gross_And_GST : clLedger_Report_Show_Gross_And_GST := F.ReadBooleanValue;
         tkclSalutation                       : clSalutation := F.ReadStringValue;
         tkclExternal_ID                      : clExternal_ID := F.ReadAnsiStringValue;
         tkclSystem_LRN                       : clSystem_LRN := F.ReadIntegerValue;
         tkclBusiness_Products_Scheduled_Reports : clBusiness_Products_Scheduled_Reports := F.ReadBooleanValue;
         tkclBusiness_Products_Report_Format  : clBusiness_Products_Report_Format := F.ReadByteValue;
         tkclCoding_Report_Wrap_Narration     : clCoding_Report_Wrap_Narration := F.ReadBooleanValue;
         tkclLedger_Report_Wrap_Narration     : clLedger_Report_Wrap_Narration := F.ReadBooleanValue;
         tkclScheduled_Coding_Report_Wrap_Narration : clScheduled_Coding_Report_Wrap_Narration := F.ReadBooleanValue;
         tkclForce_Offsite_Check_Out          : clForce_Offsite_Check_Out := F.ReadBooleanValue;
         tkclDisable_Offsite_Check_Out        : clDisable_Offsite_Check_Out := F.ReadBooleanValue;
         tkclAlternate_Extract_ID             : clAlternate_Extract_ID := F.ReadAnsiStringValue;
         tkclUse_Alterate_ID_for_extract      : clUse_Alterate_ID_for_extract := F.ReadBooleanValue;
         tkclLast_Use_Date                    : clLast_Use_Date := F.ReadDateValue;
         tkclUse_Basic_Chart                  : clUse_Basic_Chart := F.ReadBooleanValue;
         tkclGroup_Name                       : clGroup_Name := F.ReadAnsiStringValue;
         tkclClient_Type_Name                 : clClient_Type_Name := F.ReadAnsiStringValue;
         tkclBAS_Include_Fuel                 : clBAS_Include_Fuel := F.ReadBooleanValue;
         tkclProfit_Report_Show_Percentage    : clProfit_Report_Show_Percentage := F.ReadBooleanValue;
         tkclECoding_Send_Superfund           : clECoding_Send_Superfund := F.ReadBooleanValue;
         tkclGroup_LRN                        : clGroup_LRN := F.ReadIntegerValue;
         tkclClient_Type_LRN                  : clClient_Type_LRN := F.ReadIntegerValue;
         tkclSpare_Byte_1                     : clSpare_Byte_1 := F.ReadByteValue;
         tkclSpare_Byte_2                     : clSpare_Byte_2 := F.ReadByteValue;
         tkclPractice_Code                    : clPractice_Code := F.ReadAnsiStringValue;
         tkclCashJ_Column_Order               : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'clCashJ_Column_Order' );
               clCashJ_Column_Order[ I ] := B;
            end;
         tkclCashJ_Column_Width               : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'clCashJ_Column_Width' );
               clCashJ_Column_Width[ I ] := L;
            end;
         tkclCashJ_Column_is_Hidden           : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clCashJ_Column_is_Hidden' );
               clCashJ_Column_is_Hidden[ I ] := Y;
            end;
         tkclCashJ_Column_is_Not_Editable     : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clCashJ_Column_is_Not_Editable' );
               clCashJ_Column_is_Not_Editable[ I ] := Y;
            end;
         tkclCashJ_Sort_Order                 : clCashJ_Sort_Order := F.ReadIntegerValue;
         tkclAcrlJ_Column_Order               : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'clAcrlJ_Column_Order' );
               clAcrlJ_Column_Order[ I ] := B;
            end;
         tkclAcrlJ_Column_Width               : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'clAcrlJ_Column_Width' );
               clAcrlJ_Column_Width[ I ] := L;
            end;
         tkclAcrlJ_Column_is_Hidden           : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clAcrlJ_Column_is_Hidden' );
               clAcrlJ_Column_is_Hidden[ I ] := Y;
            end;
         tkclAcrlJ_Column_is_Not_Editable     : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clAcrlJ_Column_is_Not_Editable' );
               clAcrlJ_Column_is_Not_Editable[ I ] := Y;
            end;
         tkclAcrlJ_Sort_Order                 : clAcrlJ_Sort_Order := F.ReadIntegerValue;
         tkclStockJ_Column_Order              : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'clStockJ_Column_Order' );
               clStockJ_Column_Order[ I ] := B;
            end;
         tkclStockJ_Column_Width              : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'clStockJ_Column_Width' );
               clStockJ_Column_Width[ I ] := L;
            end;
         tkclStockJ_Column_is_Hidden          : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clStockJ_Column_is_Hidden' );
               clStockJ_Column_is_Hidden[ I ] := Y;
            end;
         tkclStockJ_Column_is_Not_Editable    : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clStockJ_Column_is_Not_Editable' );
               clStockJ_Column_is_Not_Editable[ I ] := Y;
            end;
         tkclStockJ_Sort_Order                : clStockJ_Sort_Order := F.ReadIntegerValue;
         tkclYrEJ_Column_Order                : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'clYrEJ_Column_Order' );
               clYrEJ_Column_Order[ I ] := B;
            end;
         tkclYrEJ_Column_Width                : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'clYrEJ_Column_Width' );
               clYrEJ_Column_Width[ I ] := L;
            end;
         tkclYrEJ_Column_is_Hidden            : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clYrEJ_Column_is_Hidden' );
               clYrEJ_Column_is_Hidden[ I ] := Y;
            end;
         tkclYrEJ_Column_is_Not_Editable      : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clYrEJ_Column_is_Not_Editable' );
               clYrEJ_Column_is_Not_Editable[ I ] := Y;
            end;
         tkclYrEJ_Sort_Order                  : clYrEJ_Sort_Order := F.ReadIntegerValue;
         tkclgstJ_Column_Order                : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'clgstJ_Column_Order' );
               clgstJ_Column_Order[ I ] := B;
            end;
         tkclgstJ_Column_Width                : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'clgstJ_Column_Width' );
               clgstJ_Column_Width[ I ] := L;
            end;
         tkclgstJ_Column_is_Hidden            : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clgstJ_Column_is_Hidden' );
               clgstJ_Column_is_Hidden[ I ] := Y;
            end;
         tkclgstJ_Column_is_Not_Editable      : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'clgstJ_Column_is_Not_Editable' );
               clgstJ_Column_is_Not_Editable[ I ] := Y;
            end;
         tkclgstJ_Sort_Order                  : clgstJ_Sort_Order := F.ReadIntegerValue;
         tkclFavourite_Report_XML             : clFavourite_Report_XML := F.ReadAnsiStringValue;
         tkclAll_EditMode_CES                 : clAll_EditMode_CES := F.ReadBooleanValue;
         tkclAll_EditMode_DIS                 : clAll_EditMode_DIS := F.ReadBooleanValue;
         tkclTFN                              : clTFN := F.ReadStringValue;
         tkclAll_EditMode_Journals            : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 7, 'clAll_EditMode_Journals' );
               clAll_EditMode_Journals[ I ] := Y;
            end;
         tkclBudget_Column_Width              : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 14, 'clBudget_Column_Width' );
               clBudget_Column_Width[ I ] := L;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Client_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Client_Rec : pClient_Rec ;

Var
   P : pClient_Rec;
Begin
   SafeGetMem( P, Client_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Client_Rec_Size, 0 );
      clRecord_Type := tkBegin_Client;
      clEOR         := tkEnd_Client;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Client_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Client_Rec_Dynamic_Fields ( Var O : TClient_Rec );

Begin
   If IsAClient_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      clSave_Tax_Files_To := '' ;
      clPractice_Web_Site := '' ;
      clPractice_Logo := '' ;
      clWeb_Site_Login_URL := '' ;
      clScheduled_File_Attachments := '' ;
      clScheduled_Client_Note_Message := '' ;
      clExclude_From_Scheduled_Reports := '' ;
      clExternal_ID := '' ;
      clAlternate_Extract_ID := '' ;
      clGroup_Name := '' ;
      clClient_Type_Name := '' ;
      clPractice_Code := '' ;
      clFavourite_Report_XML := '' ;
      SetLength( clTemp_FRS_Divisions, 0 );
      SetLength( clTemp_Period_Details_This_Year, 0 );
      SetLength( clTemp_Period_Details_Last_Year, 0 );
   end;
end;

{  -------------------------------------------------------------------  }

END.
