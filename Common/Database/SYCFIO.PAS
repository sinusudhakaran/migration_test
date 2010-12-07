UNIT SYcfIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client_File                  = 80 ;
   tkEnd_Client_File                    = 81 ;

FUNCTION  IsAClient_File_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_File_Rec ( Var O : TClient_File_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_File_Rec ( Var O : TClient_File_Rec ; Var F : TIOStream );
FUNCTION  New_Client_File_Rec : pClient_File_Rec ;
PROCEDURE Free_Client_File_Rec_Dynamic_Fields ( Var O : TClient_File_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYCFIO';
   SBoundsError        = 'SYCFIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYCFIO Error: Pointer is NIL in IsAClient_File_Rec';
   SInvalidType        = 'SYCFIO Error: Type is invalid in IsAClient_File_Rec';
   SInvalidEOR         = 'SYCFIO Error: EOR is missing in IsAClient_File_Rec';
   SUnknownToken       = 'SYCFIO Error: Unknown token %d in Read_Client_File_Rec';
   SInsufficientMemory = 'SYCFIO Error: Out of memory in New_Client_File_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkcfFile_Code                        = 82 ;
   tkcfFile_Name                        = 83 ;
   tkcfFile_Type                        = 84 ;
   tkcfFile_Status                      = 85 ;
   tkcfFile_Password                    = 86 ;
   tkcfDate_Last_Accessed               = 87 ;
   tkcfFile_Save_Count                  = 88 ;
   tkcfUser_Responsible                 = 89 ;
   tkcfCurrent_User                     = 90 ;
   tkcfLRN                              = 91 ;
   tkcfReport_Start_Date                = 92 ;
   tkcfReporting_Period                 = 93 ;
   tkcfForeign_File                     = 94 ;
   tkcfUnused_Date_Field                = 95 ;
   tkcfReports_Due                      = 96 ;
   tkcfContact_Details_To_Show          = 97 ;
   tkcfFinancial_Year_Starts            = 98 ;
   tkcfSchd_Rep_Method                  = 99 ;
   tkcfSpareBoolean                     = 100 ;
   tkcfPending_ToDo_Count               = 101 ;
   tkcfNext_ToDo_Desc                   = 102 ;
   tkcfNext_ToDo_Rem_Date               = 103 ;
   tkcfHas_Client_Notes                 = 104 ;
   tkcfOverdue_ToDo_Count               = 105 ;
   tkcfSched_Rep_Reports_To_Send        = 106 ;
   tkcfContact_Details_Edit_Date        = 107 ;
   tkcfContact_Details_Edit_Time        = 108 ;
   tkcfBank_Accounts                    = 109 ;
   tkcfDate_Of_Last_Entry_Printed       = 110 ;
   tkcfLast_Print_Reports_Up_To         = 111 ;
   tkcfClient_Type                      = 112 ;
   tkcfCoded                            = 113 ;
   tkcfFinalized                        = 114 ;
   tkcfTransferred                      = 115 ;
   tkcfLast_Processing_Status_Date      = 116 ;
   tkcfSchd_Rep_Method_Filter           = 117 ;
   tkcfArchived                         = 118 ;
   tkcfPayee_Count                      = 119 ;
   tkcfBank_Account_Count               = 120 ;
   tkcfManual_Account_Count             = 121 ;
   tkcfMem_Count                        = 122 ;
   tkcfAccounting_System                = 123 ;
   tkcfDownloaded                       = 124 ;
   tkcfGroup_LRN                        = 125 ;
   tkcfClient_Type_LRN                  = 126 ;
   tkcfJob_Count                        = 127 ;
   tkcfDivision_Count                   = 128 ;
   tkcfGST_Period                       = 129 ;
   tkcfGST_Start_Month                  = 130 ;
   tkcfBulk_Extract_Code                = 131 ;
   tkcfWebNotesAvailable                = 132 ;
   tkcfWebNotes_Email_Notifications     = 133 ;
   tkcfISO_Codes                        = 134 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClient_File_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClient_File_Rec ( P )^ do Begin
      If cfRecord_Type <> tkBegin_Client_File then
         Raise ECorruptData.Create( SInvalidType );
      If cfEOR <> tkEnd_Client_File then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Client_File_Rec ( Var O : TClient_File_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAClient_File_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Client_File );
      F.WriteStringValue( tkcfFile_Code , cfFile_Code );
      F.WriteStringValue( tkcfFile_Name , cfFile_Name );
      F.WriteByteValue( tkcfFile_Type , cfFile_Type );
      F.WriteByteValue( tkcfFile_Status , cfFile_Status );
      F.WriteStringValue( tkcfFile_Password , cfFile_Password );
      F.WriteDateValue( tkcfDate_Last_Accessed , cfDate_Last_Accessed );
      F.WriteIntegerValue( tkcfFile_Save_Count , cfFile_Save_Count );
      F.WriteIntegerValue( tkcfUser_Responsible , cfUser_Responsible );
      F.WriteIntegerValue( tkcfCurrent_User , cfCurrent_User );
      F.WriteIntegerValue( tkcfLRN , cfLRN );
      F.WriteDateValue( tkcfReport_Start_Date , cfReport_Start_Date );
      F.WriteByteValue( tkcfReporting_Period , cfReporting_Period );
      F.WriteBooleanValue( tkcfForeign_File , cfForeign_File );
      F.WriteDateValue( tkcfUnused_Date_Field , cfUnused_Date_Field );
      F.WriteBooleanValue( tkcfReports_Due , cfReports_Due );
      F.WriteByteValue( tkcfContact_Details_To_Show , cfContact_Details_To_Show );
      F.WriteIntegerValue( tkcfFinancial_Year_Starts , cfFinancial_Year_Starts );
      F.WriteByteValue( tkcfSchd_Rep_Method , cfSchd_Rep_Method );
      F.WriteBooleanValue( tkcfSpareBoolean , cfSpareBoolean );
      F.WriteIntegerValue( tkcfPending_ToDo_Count , cfPending_ToDo_Count );
      F.WriteStringValue( tkcfNext_ToDo_Desc , cfNext_ToDo_Desc );
      F.WriteIntegerValue( tkcfNext_ToDo_Rem_Date , cfNext_ToDo_Rem_Date );
      F.WriteBooleanValue( tkcfHas_Client_Notes , cfHas_Client_Notes );
      F.WriteIntegerValue( tkcfOverdue_ToDo_Count , cfOverdue_ToDo_Count );
      F.WriteIntegerValue( tkcfSched_Rep_Reports_To_Send , cfSched_Rep_Reports_To_Send );
      F.WriteIntegerValue( tkcfContact_Details_Edit_Date , cfContact_Details_Edit_Date );
      F.WriteIntegerValue( tkcfContact_Details_Edit_Time , cfContact_Details_Edit_Time );
      F.WriteAnsiStringValue( tkcfBank_Accounts , cfBank_Accounts );
      F.WriteIntegerValue( tkcfDate_Of_Last_Entry_Printed , cfDate_Of_Last_Entry_Printed );
      F.WriteDateValue( tkcfLast_Print_Reports_Up_To , cfLast_Print_Reports_Up_To );
      F.WriteByteValue( tkcfClient_Type , cfClient_Type );
      For i := 1 to 36 do F.WriteBByteValue( tkcfCoded , i, cfCoded[ i ] );
      For i := 1 to 36 do F.WriteBByteValue( tkcfFinalized , i, cfFinalized[ i ] );
      For i := 1 to 36 do F.WriteBByteValue( tkcfTransferred , i, cfTransferred[ i ] );
      F.WriteDateValue( tkcfLast_Processing_Status_Date , cfLast_Processing_Status_Date );
      F.WriteByteValue( tkcfSchd_Rep_Method_Filter , cfSchd_Rep_Method_Filter );
      F.WriteBooleanValue( tkcfArchived , cfArchived );
      F.WriteIntegerValue( tkcfPayee_Count , cfPayee_Count );
      F.WriteIntegerValue( tkcfBank_Account_Count , cfBank_Account_Count );
      F.WriteIntegerValue( tkcfManual_Account_Count , cfManual_Account_Count );
      F.WriteIntegerValue( tkcfMem_Count , cfMem_Count );
      F.WriteAnsiStringValue( tkcfAccounting_System , cfAccounting_System );
      For i := 1 to 36 do F.WriteBByteValue( tkcfDownloaded , i, cfDownloaded[ i ] );
      F.WriteIntegerValue( tkcfGroup_LRN , cfGroup_LRN );
      F.WriteIntegerValue( tkcfClient_Type_LRN , cfClient_Type_LRN );
      F.WriteIntegerValue( tkcfJob_Count , cfJob_Count );
      F.WriteIntegerValue( tkcfDivision_Count , cfDivision_Count );
      F.WriteByteValue( tkcfGST_Period , cfGST_Period );
      F.WriteByteValue( tkcfGST_Start_Month , cfGST_Start_Month );
      F.WriteStringValue( tkcfBulk_Extract_Code , cfBulk_Extract_Code );
      For i := 1 to 36 do F.WriteBByteValue( tkcfWebNotesAvailable , i, cfWebNotesAvailable[ i ] );
      F.WriteIntegerValue( tkcfWebNotes_Email_Notifications , cfWebNotes_Email_Notifications );
      For i := 1 to 99 do F.WriteBStringValue( tkcfISO_Codes , i, cfISO_Codes[ i ] );
      F.WriteToken( tkEnd_Client_File );
   end;
end; { of Write_Client_File_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Client_File_Rec ( Var O : TClient_File_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   B     : Byte;   
   S     : ShortString;

Begin
   FillChar( O, Client_File_Rec_Size, 0 );
   O.cfRecord_Type := tkBegin_Client_File;
   O.cfEOR := tkEnd_Client_File;
   Token := tkBegin_Client_File;

   While Token <> tkEnd_Client_File do With O do
   Begin
      Case Token of
         tkBegin_Client_File :; { Do Nothing }
         tkEnd_Client_File :; { Do Nothing }
         tkcfFile_Code                        : cfFile_Code := F.ReadStringValue;
         tkcfFile_Name                        : cfFile_Name := F.ReadStringValue;
         tkcfFile_Type                        : cfFile_Type := F.ReadByteValue;
         tkcfFile_Status                      : cfFile_Status := F.ReadByteValue;
         tkcfFile_Password                    : cfFile_Password := F.ReadStringValue;
         tkcfDate_Last_Accessed               : cfDate_Last_Accessed := F.ReadDateValue;
         tkcfFile_Save_Count                  : cfFile_Save_Count := F.ReadIntegerValue;
         tkcfUser_Responsible                 : cfUser_Responsible := F.ReadIntegerValue;
         tkcfCurrent_User                     : cfCurrent_User := F.ReadIntegerValue;
         tkcfLRN                              : cfLRN := F.ReadIntegerValue;
         tkcfReport_Start_Date                : cfReport_Start_Date := F.ReadDateValue;
         tkcfReporting_Period                 : cfReporting_Period := F.ReadByteValue;
         tkcfForeign_File                     : cfForeign_File := F.ReadBooleanValue;
         tkcfUnused_Date_Field                : cfUnused_Date_Field := F.ReadDateValue;
         tkcfReports_Due                      : cfReports_Due := F.ReadBooleanValue;
         tkcfContact_Details_To_Show          : cfContact_Details_To_Show := F.ReadByteValue;
         tkcfFinancial_Year_Starts            : cfFinancial_Year_Starts := F.ReadIntegerValue;
         tkcfSchd_Rep_Method                  : cfSchd_Rep_Method := F.ReadByteValue;
         tkcfSpareBoolean                     : cfSpareBoolean := F.ReadBooleanValue;
         tkcfPending_ToDo_Count               : cfPending_ToDo_Count := F.ReadIntegerValue;
         tkcfNext_ToDo_Desc                   : cfNext_ToDo_Desc := F.ReadStringValue;
         tkcfNext_ToDo_Rem_Date               : cfNext_ToDo_Rem_Date := F.ReadIntegerValue;
         tkcfHas_Client_Notes                 : cfHas_Client_Notes := F.ReadBooleanValue;
         tkcfOverdue_ToDo_Count               : cfOverdue_ToDo_Count := F.ReadIntegerValue;
         tkcfSched_Rep_Reports_To_Send        : cfSched_Rep_Reports_To_Send := F.ReadIntegerValue;
         tkcfContact_Details_Edit_Date        : cfContact_Details_Edit_Date := F.ReadIntegerValue;
         tkcfContact_Details_Edit_Time        : cfContact_Details_Edit_Time := F.ReadIntegerValue;
         tkcfBank_Accounts                    : cfBank_Accounts := F.ReadAnsiStringValue;
         tkcfDate_Of_Last_Entry_Printed       : cfDate_Of_Last_Entry_Printed := F.ReadIntegerValue;
         tkcfLast_Print_Reports_Up_To         : cfLast_Print_Reports_Up_To := F.ReadDateValue;
         tkcfClient_Type                      : cfClient_Type := F.ReadByteValue;
         tkcfCoded                            : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 36, 'cfCoded' );
               cfCoded[ I ] := B;
            end;
         tkcfFinalized                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 36, 'cfFinalized' );
               cfFinalized[ I ] := B;
            end;
         tkcfTransferred                      : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 36, 'cfTransferred' );
               cfTransferred[ I ] := B;
            end;
         tkcfLast_Processing_Status_Date      : cfLast_Processing_Status_Date := F.ReadDateValue;
         tkcfSchd_Rep_Method_Filter           : cfSchd_Rep_Method_Filter := F.ReadByteValue;
         tkcfArchived                         : cfArchived := F.ReadBooleanValue;
         tkcfPayee_Count                      : cfPayee_Count := F.ReadIntegerValue;
         tkcfBank_Account_Count               : cfBank_Account_Count := F.ReadIntegerValue;
         tkcfManual_Account_Count             : cfManual_Account_Count := F.ReadIntegerValue;
         tkcfMem_Count                        : cfMem_Count := F.ReadIntegerValue;
         tkcfAccounting_System                : cfAccounting_System := F.ReadAnsiStringValue;
         tkcfDownloaded                       : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 36, 'cfDownloaded' );
               cfDownloaded[ I ] := B;
            end;
         tkcfGroup_LRN                        : cfGroup_LRN := F.ReadIntegerValue;
         tkcfClient_Type_LRN                  : cfClient_Type_LRN := F.ReadIntegerValue;
         tkcfJob_Count                        : cfJob_Count := F.ReadIntegerValue;
         tkcfDivision_Count                   : cfDivision_Count := F.ReadIntegerValue;
         tkcfGST_Period                       : cfGST_Period := F.ReadByteValue;
         tkcfGST_Start_Month                  : cfGST_Start_Month := F.ReadByteValue;
         tkcfBulk_Extract_Code                : cfBulk_Extract_Code := F.ReadStringValue;
         tkcfWebNotesAvailable                : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 36, 'cfWebNotesAvailable' );
               cfWebNotesAvailable[ I ] := B;
            end;
         tkcfWebNotes_Email_Notifications     : cfWebNotes_Email_Notifications := F.ReadIntegerValue;
         tkcfISO_Codes                        : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'cfISO_Codes' );
               cfISO_Codes[ I ] := S;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Client_File_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Client_File_Rec : pClient_File_Rec ;

Var
   P : pClient_File_Rec;
Begin
   SafeGetMem( P, Client_File_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Client_File_Rec_Size, 0 );
      cfRecord_Type := tkBegin_Client_File;
      cfEOR         := tkEnd_Client_File;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Client_File_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Client_File_Rec_Dynamic_Fields ( Var O : TClient_File_Rec );

Begin
   If IsAClient_File_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      cfBank_Accounts := '' ;
      cfAccounting_System := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
