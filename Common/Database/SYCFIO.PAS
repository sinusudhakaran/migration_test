UNIT SYcfIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client_File                  = 80 ;
   tkEnd_Client_File                    = 81 ;

FUNCTION  IsAClient_File_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_File_Rec ( Var O : TClient_File_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_File_Rec ( Var O : TClient_File_Rec ; Var F : TIOStream );
FUNCTION  New_Client_File_Rec : pClient_File_Rec ;
PROCEDURE Free_Client_File_Rec_Dynamic_Fields ( Var O : TClient_File_Rec );
FUNCTION Client_File_Rec_Delta(P1, P2, P3: pClient_File_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Client_File_Rec(P1, P2: pClient_File_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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
   tkcfAudit_Record_ID                  = 135 ;

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
      F.WriteIntegerValue( tkcfAudit_Record_ID , cfAudit_Record_ID );
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
         tkcfAudit_Record_ID                  : cfAudit_Record_ID := F.ReadIntegerValue;
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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tkcfFile_Code to tkcfAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Client_File_Rec_Delta(P1, P2, P3: pClient_File_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Client_File_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.cfFile_Code <> P2.cfFile_Code) then begin
    P3.cfFile_Code := P1.cfFile_Code;
    ChangedFields[i] := tkcfFile_Code;
    Inc(i);
  end;
  if (P1.cfFile_Name <> P2.cfFile_Name) then begin
    P3.cfFile_Name := P1.cfFile_Name;
    ChangedFields[i] := tkcfFile_Name;
    Inc(i);
  end;
  if (P1.cfFile_Type <> P2.cfFile_Type) then begin
    P3.cfFile_Type := P1.cfFile_Type;
    ChangedFields[i] := tkcfFile_Type;
    Inc(i);
  end;
  if (P1.cfFile_Status <> P2.cfFile_Status) then begin
    P3.cfFile_Status := P1.cfFile_Status;
    ChangedFields[i] := tkcfFile_Status;
    Inc(i);
  end;
  if (P1.cfFile_Password <> P2.cfFile_Password) then begin
    P3.cfFile_Password := P1.cfFile_Password;
    ChangedFields[i] := tkcfFile_Password;
    Inc(i);
  end;
  if (P1.cfDate_Last_Accessed <> P2.cfDate_Last_Accessed) then begin
    P3.cfDate_Last_Accessed := P1.cfDate_Last_Accessed;
    ChangedFields[i] := tkcfDate_Last_Accessed;
    Inc(i);
  end;
  if (P1.cfFile_Save_Count <> P2.cfFile_Save_Count) then begin
    P3.cfFile_Save_Count := P1.cfFile_Save_Count;
    ChangedFields[i] := tkcfFile_Save_Count;
    Inc(i);
  end;
  if (P1.cfUser_Responsible <> P2.cfUser_Responsible) then begin
    P3.cfUser_Responsible := P1.cfUser_Responsible;
    ChangedFields[i] := tkcfUser_Responsible;
    Inc(i);
  end;
  if (P1.cfCurrent_User <> P2.cfCurrent_User) then begin
    P3.cfCurrent_User := P1.cfCurrent_User;
    ChangedFields[i] := tkcfCurrent_User;
    Inc(i);
  end;
  if (P1.cfLRN <> P2.cfLRN) then begin
    P3.cfLRN := P1.cfLRN;
    ChangedFields[i] := tkcfLRN;
    Inc(i);
  end;
  if (P1.cfReport_Start_Date <> P2.cfReport_Start_Date) then begin
    P3.cfReport_Start_Date := P1.cfReport_Start_Date;
    ChangedFields[i] := tkcfReport_Start_Date;
    Inc(i);
  end;
  if (P1.cfReporting_Period <> P2.cfReporting_Period) then begin
    P3.cfReporting_Period := P1.cfReporting_Period;
    ChangedFields[i] := tkcfReporting_Period;
    Inc(i);
  end;
  if (P1.cfForeign_File <> P2.cfForeign_File) then begin
    P3.cfForeign_File := P1.cfForeign_File;
    ChangedFields[i] := tkcfForeign_File;
    Inc(i);
  end;
  if (P1.cfUnused_Date_Field <> P2.cfUnused_Date_Field) then begin
    P3.cfUnused_Date_Field := P1.cfUnused_Date_Field;
    ChangedFields[i] := tkcfUnused_Date_Field;
    Inc(i);
  end;
  if (P1.cfReports_Due <> P2.cfReports_Due) then begin
    P3.cfReports_Due := P1.cfReports_Due;
    ChangedFields[i] := tkcfReports_Due;
    Inc(i);
  end;
  if (P1.cfContact_Details_To_Show <> P2.cfContact_Details_To_Show) then begin
    P3.cfContact_Details_To_Show := P1.cfContact_Details_To_Show;
    ChangedFields[i] := tkcfContact_Details_To_Show;
    Inc(i);
  end;
  if (P1.cfFinancial_Year_Starts <> P2.cfFinancial_Year_Starts) then begin
    P3.cfFinancial_Year_Starts := P1.cfFinancial_Year_Starts;
    ChangedFields[i] := tkcfFinancial_Year_Starts;
    Inc(i);
  end;
  if (P1.cfSchd_Rep_Method <> P2.cfSchd_Rep_Method) then begin
    P3.cfSchd_Rep_Method := P1.cfSchd_Rep_Method;
    ChangedFields[i] := tkcfSchd_Rep_Method;
    Inc(i);
  end;
  if (P1.cfSpareBoolean <> P2.cfSpareBoolean) then begin
    P3.cfSpareBoolean := P1.cfSpareBoolean;
    ChangedFields[i] := tkcfSpareBoolean;
    Inc(i);
  end;
  if (P1.cfPending_ToDo_Count <> P2.cfPending_ToDo_Count) then begin
    P3.cfPending_ToDo_Count := P1.cfPending_ToDo_Count;
    ChangedFields[i] := tkcfPending_ToDo_Count;
    Inc(i);
  end;
  if (P1.cfNext_ToDo_Desc <> P2.cfNext_ToDo_Desc) then begin
    P3.cfNext_ToDo_Desc := P1.cfNext_ToDo_Desc;
    ChangedFields[i] := tkcfNext_ToDo_Desc;
    Inc(i);
  end;
  if (P1.cfNext_ToDo_Rem_Date <> P2.cfNext_ToDo_Rem_Date) then begin
    P3.cfNext_ToDo_Rem_Date := P1.cfNext_ToDo_Rem_Date;
    ChangedFields[i] := tkcfNext_ToDo_Rem_Date;
    Inc(i);
  end;
  if (P1.cfHas_Client_Notes <> P2.cfHas_Client_Notes) then begin
    P3.cfHas_Client_Notes := P1.cfHas_Client_Notes;
    ChangedFields[i] := tkcfHas_Client_Notes;
    Inc(i);
  end;
  if (P1.cfOverdue_ToDo_Count <> P2.cfOverdue_ToDo_Count) then begin
    P3.cfOverdue_ToDo_Count := P1.cfOverdue_ToDo_Count;
    ChangedFields[i] := tkcfOverdue_ToDo_Count;
    Inc(i);
  end;
  if (P1.cfSched_Rep_Reports_To_Send <> P2.cfSched_Rep_Reports_To_Send) then begin
    P3.cfSched_Rep_Reports_To_Send := P1.cfSched_Rep_Reports_To_Send;
    ChangedFields[i] := tkcfSched_Rep_Reports_To_Send;
    Inc(i);
  end;
  if (P1.cfContact_Details_Edit_Date <> P2.cfContact_Details_Edit_Date) then begin
    P3.cfContact_Details_Edit_Date := P1.cfContact_Details_Edit_Date;
    ChangedFields[i] := tkcfContact_Details_Edit_Date;
    Inc(i);
  end;
  if (P1.cfContact_Details_Edit_Time <> P2.cfContact_Details_Edit_Time) then begin
    P3.cfContact_Details_Edit_Time := P1.cfContact_Details_Edit_Time;
    ChangedFields[i] := tkcfContact_Details_Edit_Time;
    Inc(i);
  end;
  if (P1.cfBank_Accounts <> P2.cfBank_Accounts) then begin
    P3.cfBank_Accounts := P1.cfBank_Accounts;
    ChangedFields[i] := tkcfBank_Accounts;
    Inc(i);
  end;
  if (P1.cfDate_Of_Last_Entry_Printed <> P2.cfDate_Of_Last_Entry_Printed) then begin
    P3.cfDate_Of_Last_Entry_Printed := P1.cfDate_Of_Last_Entry_Printed;
    ChangedFields[i] := tkcfDate_Of_Last_Entry_Printed;
    Inc(i);
  end;
  if (P1.cfLast_Print_Reports_Up_To <> P2.cfLast_Print_Reports_Up_To) then begin
    P3.cfLast_Print_Reports_Up_To := P1.cfLast_Print_Reports_Up_To;
    ChangedFields[i] := tkcfLast_Print_Reports_Up_To;
    Inc(i);
  end;
  if (P1.cfClient_Type <> P2.cfClient_Type) then begin
    P3.cfClient_Type := P1.cfClient_Type;
    ChangedFields[i] := tkcfClient_Type;
    Inc(i);
  end;
  if Coded_Changed(TCoded_Array(P1.cfCoded), 
                  TCoded_Array(P2.cfCoded), 
                  TCoded_Array(P3.cfCoded)) then begin
    ChangedFields[i] := tkcfCoded;
    Inc(i);
  end;
  if Finalized_Changed(TFinalized_Array(P1.cfFinalized), 
                  TFinalized_Array(P2.cfFinalized), 
                  TFinalized_Array(P3.cfFinalized)) then begin
    ChangedFields[i] := tkcfFinalized;
    Inc(i);
  end;
  if Transferred_Changed(TTransferred_Array(P1.cfTransferred), 
                  TTransferred_Array(P2.cfTransferred), 
                  TTransferred_Array(P3.cfTransferred)) then begin
    ChangedFields[i] := tkcfTransferred;
    Inc(i);
  end;
  if (P1.cfLast_Processing_Status_Date <> P2.cfLast_Processing_Status_Date) then begin
    P3.cfLast_Processing_Status_Date := P1.cfLast_Processing_Status_Date;
    ChangedFields[i] := tkcfLast_Processing_Status_Date;
    Inc(i);
  end;
  if (P1.cfSchd_Rep_Method_Filter <> P2.cfSchd_Rep_Method_Filter) then begin
    P3.cfSchd_Rep_Method_Filter := P1.cfSchd_Rep_Method_Filter;
    ChangedFields[i] := tkcfSchd_Rep_Method_Filter;
    Inc(i);
  end;
  if (P1.cfArchived <> P2.cfArchived) then begin
    P3.cfArchived := P1.cfArchived;
    ChangedFields[i] := tkcfArchived;
    Inc(i);
  end;
  if (P1.cfPayee_Count <> P2.cfPayee_Count) then begin
    P3.cfPayee_Count := P1.cfPayee_Count;
    ChangedFields[i] := tkcfPayee_Count;
    Inc(i);
  end;
  if (P1.cfBank_Account_Count <> P2.cfBank_Account_Count) then begin
    P3.cfBank_Account_Count := P1.cfBank_Account_Count;
    ChangedFields[i] := tkcfBank_Account_Count;
    Inc(i);
  end;
  if (P1.cfManual_Account_Count <> P2.cfManual_Account_Count) then begin
    P3.cfManual_Account_Count := P1.cfManual_Account_Count;
    ChangedFields[i] := tkcfManual_Account_Count;
    Inc(i);
  end;
  if (P1.cfMem_Count <> P2.cfMem_Count) then begin
    P3.cfMem_Count := P1.cfMem_Count;
    ChangedFields[i] := tkcfMem_Count;
    Inc(i);
  end;
  if (P1.cfAccounting_System <> P2.cfAccounting_System) then begin
    P3.cfAccounting_System := P1.cfAccounting_System;
    ChangedFields[i] := tkcfAccounting_System;
    Inc(i);
  end;
  if Downloaded_Changed(TDownloaded_Array(P1.cfDownloaded), 
                  TDownloaded_Array(P2.cfDownloaded), 
                  TDownloaded_Array(P3.cfDownloaded)) then begin
    ChangedFields[i] := tkcfDownloaded;
    Inc(i);
  end;
  if (P1.cfGroup_LRN <> P2.cfGroup_LRN) then begin
    P3.cfGroup_LRN := P1.cfGroup_LRN;
    ChangedFields[i] := tkcfGroup_LRN;
    Inc(i);
  end;
  if (P1.cfClient_Type_LRN <> P2.cfClient_Type_LRN) then begin
    P3.cfClient_Type_LRN := P1.cfClient_Type_LRN;
    ChangedFields[i] := tkcfClient_Type_LRN;
    Inc(i);
  end;
  if (P1.cfJob_Count <> P2.cfJob_Count) then begin
    P3.cfJob_Count := P1.cfJob_Count;
    ChangedFields[i] := tkcfJob_Count;
    Inc(i);
  end;
  if (P1.cfDivision_Count <> P2.cfDivision_Count) then begin
    P3.cfDivision_Count := P1.cfDivision_Count;
    ChangedFields[i] := tkcfDivision_Count;
    Inc(i);
  end;
  if (P1.cfGST_Period <> P2.cfGST_Period) then begin
    P3.cfGST_Period := P1.cfGST_Period;
    ChangedFields[i] := tkcfGST_Period;
    Inc(i);
  end;
  if (P1.cfGST_Start_Month <> P2.cfGST_Start_Month) then begin
    P3.cfGST_Start_Month := P1.cfGST_Start_Month;
    ChangedFields[i] := tkcfGST_Start_Month;
    Inc(i);
  end;
  if (P1.cfBulk_Extract_Code <> P2.cfBulk_Extract_Code) then begin
    P3.cfBulk_Extract_Code := P1.cfBulk_Extract_Code;
    ChangedFields[i] := tkcfBulk_Extract_Code;
    Inc(i);
  end;
  if WebNotesAvailable_Changed(TWebNotesAvailable_Array(P1.cfWebNotesAvailable), 
                  TWebNotesAvailable_Array(P2.cfWebNotesAvailable), 
                  TWebNotesAvailable_Array(P3.cfWebNotesAvailable)) then begin
    ChangedFields[i] := tkcfWebNotesAvailable;
    Inc(i);
  end;
  if (P1.cfWebNotes_Email_Notifications <> P2.cfWebNotes_Email_Notifications) then begin
    P3.cfWebNotes_Email_Notifications := P1.cfWebNotes_Email_Notifications;
    ChangedFields[i] := tkcfWebNotes_Email_Notifications;
    Inc(i);
  end;
  if ISO_Codes_Changed(TISO_Codes_Array(P1.cfISO_Codes), 
                  TISO_Codes_Array(P2.cfISO_Codes), 
                  TISO_Codes_Array(P3.cfISO_Codes)) then begin
    ChangedFields[i] := tkcfISO_Codes;
    Inc(i);
  end;
  if (P1.cfAudit_Record_ID <> P2.cfAudit_Record_ID) then begin
    P3.cfAudit_Record_ID := P1.cfAudit_Record_ID;
    ChangedFields[i] := tkcfAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Client_File_Rec(P1, P2: pClient_File_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Client_File_Rec(P1^, S);
    S.Position := 0;
    Read_Client_File_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
