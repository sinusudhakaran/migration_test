UNIT SYsbIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_System_Bank_Account          = 50 ;
   tkEnd_System_Bank_Account            = 51 ;

FUNCTION  IsASystem_Bank_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec ; Var F : TIOStream );
PROCEDURE Read_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec ; Var F : TIOStream );
FUNCTION  New_System_Bank_Account_Rec : pSystem_Bank_Account_Rec ;
PROCEDURE Free_System_Bank_Account_Rec_Dynamic_Fields ( Var O : TSystem_Bank_Account_Rec );
FUNCTION System_Bank_Account_Rec_Delta(P1, P2, P3: pSystem_Bank_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_System_Bank_Account_Rec(P1, P2: pSystem_Bank_Account_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYSBIO';
   SBoundsError        = 'SYSBIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYSBIO Error: Pointer is NIL in IsASystem_Bank_Account_Rec';
   SInvalidType        = 'SYSBIO Error: Type is invalid in IsASystem_Bank_Account_Rec';
   SInvalidEOR         = 'SYSBIO Error: EOR is missing in IsASystem_Bank_Account_Rec';
   SUnknownToken       = 'SYSBIO Error: Unknown token %d in Read_System_Bank_Account_Rec';
   SInsufficientMemory = 'SYSBIO Error: Out of memory in New_System_Bank_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksbAccount_Number                   = 52 ;
   tksbAccount_Name                     = 53 ;
   tksbAccount_Password                 = 54 ;
   tksbLRN                              = 55 ;
   tksbClient                           = 56 ;
   tksbCurrent_Balance                  = 57 ;
   tksbLast_Transaction_LRN             = 58 ;
   tksbNew_This_Month                   = 59 ;
   tksbNo_of_Entries_This_Month         = 60 ;
   tksbFrom_Date_This_Month             = 61 ;
   tksbTo_Date_This_Month               = 62 ;
   tksbCost_Code                        = 63 ;
   tksbCharges_This_Month               = 64 ;
   tksbOpening_Balance_from_Disk        = 65 ;
   tksbClosing_Balance_from_Disk        = 66 ;
   tksbAttach_Required                  = 67 ;
   tksbWas_On_Latest_Disk               = 68 ;
   tksbLast_Entry_Date                  = 69 ;
   tksbDate_Of_Last_Entry_Printed       = 70 ;
   tksbMark_As_Deleted                  = 71 ;
   tksbFile_Code                        = 72 ;
   tksbClient_ID                        = 73 ;
   tksbMatter_ID                        = 74 ;
   tksbAssignment_ID                    = 75 ;
   tksbDisbursement_ID                  = 76 ;
   tksbAccount_Type                     = 77 ;
   tksbJob_Code                         = 78 ;
   tksbActivity_Code                    = 79 ;
   tksbUnused                           = 80 ;
   tksbFirst_Available_Date             = 81 ;
   tksbNo_Charge_Account                = 82 ;
   tksbCurrency_Code                    = 83 ;
   tksbInstitution                      = 84 ;
   tksbInActive                         = 85 ;
   tksbBankLink_Code                    = 86 ;
   tksbFrequency                        = 87 ;
   tksbFrequency_Change_Pending         = 88 ;
   tksbAudit_Record_ID                  = 89 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASystem_Bank_Account_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSystem_Bank_Account_Rec ( P )^ do Begin
      If sbRecord_Type <> tkBegin_System_Bank_Account then
         Raise ECorruptData.Create( SInvalidType );
      If sbEOR <> tkEnd_System_Bank_Account then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec ; Var F : TIOStream );

Begin
   If IsASystem_Bank_Account_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_System_Bank_Account );
      F.WriteStringValue( tksbAccount_Number , sbAccount_Number );
      F.WriteStringValue( tksbAccount_Name , sbAccount_Name );
      F.WriteStringValue( tksbAccount_Password , sbAccount_Password );
      F.WriteIntegerValue( tksbLRN , sbLRN );
      F.WriteIntegerValue( tksbClient , sbClient );
      F.WriteMoneyValue( tksbCurrent_Balance , sbCurrent_Balance );
      F.WriteIntegerValue( tksbLast_Transaction_LRN , sbLast_Transaction_LRN );
      F.WriteBooleanValue( tksbNew_This_Month , sbNew_This_Month );
      F.WriteIntegerValue( tksbNo_of_Entries_This_Month , sbNo_of_Entries_This_Month );
      F.WriteIntegerValue( tksbFrom_Date_This_Month , sbFrom_Date_This_Month );
      F.WriteIntegerValue( tksbTo_Date_This_Month , sbTo_Date_This_Month );
      F.WriteStringValue( tksbCost_Code , sbCost_Code );
      F.WriteMoneyValue( tksbCharges_This_Month , sbCharges_This_Month );
      F.WriteMoneyValue( tksbOpening_Balance_from_Disk , sbOpening_Balance_from_Disk );
      F.WriteMoneyValue( tksbClosing_Balance_from_Disk , sbClosing_Balance_from_Disk );
      F.WriteBooleanValue( tksbAttach_Required , sbAttach_Required );
      F.WriteBooleanValue( tksbWas_On_Latest_Disk , sbWas_On_Latest_Disk );
      F.WriteIntegerValue( tksbLast_Entry_Date , sbLast_Entry_Date );
      F.WriteIntegerValue( tksbDate_Of_Last_Entry_Printed , sbDate_Of_Last_Entry_Printed );
      F.WriteBooleanValue( tksbMark_As_Deleted , sbMark_As_Deleted );
      F.WriteAnsiStringValue( tksbFile_Code , sbFile_Code );
      F.WriteAnsiStringValue( tksbClient_ID , sbClient_ID );
      F.WriteAnsiStringValue( tksbMatter_ID , sbMatter_ID );
      F.WriteAnsiStringValue( tksbAssignment_ID , sbAssignment_ID );
      F.WriteAnsiStringValue( tksbDisbursement_ID , sbDisbursement_ID );
      F.WriteByteValue( tksbAccount_Type , sbAccount_Type );
      F.WriteStringValue( tksbJob_Code , sbJob_Code );
      F.WriteStringValue( tksbActivity_Code , sbActivity_Code );
      F.WriteIntegerValue( tksbUnused , sbUnused );
      F.WriteDateValue( tksbFirst_Available_Date , sbFirst_Available_Date );
      F.WriteBooleanValue( tksbNo_Charge_Account , sbNo_Charge_Account );
      F.WriteStringValue( tksbCurrency_Code , sbCurrency_Code );
      F.WriteStringValue( tksbInstitution , sbInstitution );
      F.WriteBooleanValue( tksbInActive , sbInActive );
      F.WriteStringValue( tksbBankLink_Code , sbBankLink_Code );
      F.WriteByteValue( tksbFrequency , sbFrequency );
      F.WriteByteValue( tksbFrequency_Change_Pending , sbFrequency_Change_Pending );
      F.WriteIntegerValue( tksbAudit_Record_ID , sbAudit_Record_ID );
      F.WriteToken( tkEnd_System_Bank_Account );
   end;
end; { of Write_System_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, System_Bank_Account_Rec_Size, 0 );
   O.sbRecord_Type := tkBegin_System_Bank_Account;
   O.sbEOR := tkEnd_System_Bank_Account;
   Token := tkBegin_System_Bank_Account;

   While Token <> tkEnd_System_Bank_Account do With O do
   Begin
      Case Token of
         tkBegin_System_Bank_Account :; { Do Nothing }
         tkEnd_System_Bank_Account :; { Do Nothing }
         tksbAccount_Number                   : sbAccount_Number := F.ReadStringValue;
         tksbAccount_Name                     : sbAccount_Name := F.ReadStringValue;
         tksbAccount_Password                 : sbAccount_Password := F.ReadStringValue;
         tksbLRN                              : sbLRN := F.ReadIntegerValue;
         tksbClient                           : sbClient := F.ReadIntegerValue;
         tksbCurrent_Balance                  : sbCurrent_Balance := F.ReadMoneyValue;
         tksbLast_Transaction_LRN             : sbLast_Transaction_LRN := F.ReadIntegerValue;
         tksbNew_This_Month                   : sbNew_This_Month := F.ReadBooleanValue;
         tksbNo_of_Entries_This_Month         : sbNo_of_Entries_This_Month := F.ReadIntegerValue;
         tksbFrom_Date_This_Month             : sbFrom_Date_This_Month := F.ReadIntegerValue;
         tksbTo_Date_This_Month               : sbTo_Date_This_Month := F.ReadIntegerValue;
         tksbCost_Code                        : sbCost_Code := F.ReadStringValue;
         tksbCharges_This_Month               : sbCharges_This_Month := F.ReadMoneyValue;
         tksbOpening_Balance_from_Disk        : sbOpening_Balance_from_Disk := F.ReadMoneyValue;
         tksbClosing_Balance_from_Disk        : sbClosing_Balance_from_Disk := F.ReadMoneyValue;
         tksbAttach_Required                  : sbAttach_Required := F.ReadBooleanValue;
         tksbWas_On_Latest_Disk               : sbWas_On_Latest_Disk := F.ReadBooleanValue;
         tksbLast_Entry_Date                  : sbLast_Entry_Date := F.ReadIntegerValue;
         tksbDate_Of_Last_Entry_Printed       : sbDate_Of_Last_Entry_Printed := F.ReadIntegerValue;
         tksbMark_As_Deleted                  : sbMark_As_Deleted := F.ReadBooleanValue;
         tksbFile_Code                        : sbFile_Code := F.ReadAnsiStringValue;
         tksbClient_ID                        : sbClient_ID := F.ReadAnsiStringValue;
         tksbMatter_ID                        : sbMatter_ID := F.ReadAnsiStringValue;
         tksbAssignment_ID                    : sbAssignment_ID := F.ReadAnsiStringValue;
         tksbDisbursement_ID                  : sbDisbursement_ID := F.ReadAnsiStringValue;
         tksbAccount_Type                     : sbAccount_Type := F.ReadByteValue;
         tksbJob_Code                         : sbJob_Code := F.ReadStringValue;
         tksbActivity_Code                    : sbActivity_Code := F.ReadStringValue;
         tksbUnused                           : sbUnused := F.ReadIntegerValue;
         tksbFirst_Available_Date             : sbFirst_Available_Date := F.ReadDateValue;
         tksbNo_Charge_Account                : sbNo_Charge_Account := F.ReadBooleanValue;
         tksbCurrency_Code                    : sbCurrency_Code := F.ReadStringValue;
         tksbInstitution                      : sbInstitution := F.ReadStringValue;
         tksbInActive                         : sbInActive := F.ReadBooleanValue;
         tksbBankLink_Code                    : sbBankLink_Code := F.ReadStringValue;
         tksbFrequency                        : sbFrequency := F.ReadByteValue;
         tksbFrequency_Change_Pending         : sbFrequency_Change_Pending := F.ReadByteValue;
         tksbAudit_Record_ID                  : sbAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_System_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_System_Bank_Account_Rec : pSystem_Bank_Account_Rec ;

Var
   P : pSystem_Bank_Account_Rec;
Begin
   SafeGetMem( P, System_Bank_Account_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, System_Bank_Account_Rec_Size, 0 );
      sbRecord_Type := tkBegin_System_Bank_Account;
      sbEOR         := tkEnd_System_Bank_Account;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_System_Bank_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_System_Bank_Account_Rec_Dynamic_Fields ( Var O : TSystem_Bank_Account_Rec );

Begin
   If IsASystem_Bank_Account_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      sbFile_Code := '' ;
      sbClient_ID := '' ;
      sbMatter_ID := '' ;
      sbAssignment_ID := '' ;
      sbDisbursement_ID := '' ;
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
  for i := tksbAccount_Number to tksbAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION System_Bank_Account_Rec_Delta(P1, P2, P3: pSystem_Bank_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_System_Bank_Account_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.sbAccount_Number <> P2.sbAccount_Number) then begin
    P3.sbAccount_Number := P1.sbAccount_Number;
    ChangedFields[i] := tksbAccount_Number;
    Inc(i);
  end;
  if (P1.sbAccount_Name <> P2.sbAccount_Name) then begin
    P3.sbAccount_Name := P1.sbAccount_Name;
    ChangedFields[i] := tksbAccount_Name;
    Inc(i);
  end;
  if (P1.sbAccount_Password <> P2.sbAccount_Password) then begin
    P3.sbAccount_Password := P1.sbAccount_Password;
    ChangedFields[i] := tksbAccount_Password;
    Inc(i);
  end;
  if (P1.sbLRN <> P2.sbLRN) then begin
    P3.sbLRN := P1.sbLRN;
    ChangedFields[i] := tksbLRN;
    Inc(i);
  end;
  if (P1.sbClient <> P2.sbClient) then begin
    P3.sbClient := P1.sbClient;
    ChangedFields[i] := tksbClient;
    Inc(i);
  end;
  if (P1.sbCurrent_Balance <> P2.sbCurrent_Balance) then begin
    P3.sbCurrent_Balance := P1.sbCurrent_Balance;
    ChangedFields[i] := tksbCurrent_Balance;
    Inc(i);
  end;
  if (P1.sbLast_Transaction_LRN <> P2.sbLast_Transaction_LRN) then begin
    P3.sbLast_Transaction_LRN := P1.sbLast_Transaction_LRN;
    ChangedFields[i] := tksbLast_Transaction_LRN;
    Inc(i);
  end;
  if (P1.sbNew_This_Month <> P2.sbNew_This_Month) then begin
    P3.sbNew_This_Month := P1.sbNew_This_Month;
    ChangedFields[i] := tksbNew_This_Month;
    Inc(i);
  end;
  if (P1.sbNo_of_Entries_This_Month <> P2.sbNo_of_Entries_This_Month) then begin
    P3.sbNo_of_Entries_This_Month := P1.sbNo_of_Entries_This_Month;
    ChangedFields[i] := tksbNo_of_Entries_This_Month;
    Inc(i);
  end;
  if (P1.sbFrom_Date_This_Month <> P2.sbFrom_Date_This_Month) then begin
    P3.sbFrom_Date_This_Month := P1.sbFrom_Date_This_Month;
    ChangedFields[i] := tksbFrom_Date_This_Month;
    Inc(i);
  end;
  if (P1.sbTo_Date_This_Month <> P2.sbTo_Date_This_Month) then begin
    P3.sbTo_Date_This_Month := P1.sbTo_Date_This_Month;
    ChangedFields[i] := tksbTo_Date_This_Month;
    Inc(i);
  end;
  if (P1.sbCost_Code <> P2.sbCost_Code) then begin
    P3.sbCost_Code := P1.sbCost_Code;
    ChangedFields[i] := tksbCost_Code;
    Inc(i);
  end;
  if (P1.sbCharges_This_Month <> P2.sbCharges_This_Month) then begin
    P3.sbCharges_This_Month := P1.sbCharges_This_Month;
    ChangedFields[i] := tksbCharges_This_Month;
    Inc(i);
  end;
  if (P1.sbOpening_Balance_from_Disk <> P2.sbOpening_Balance_from_Disk) then begin
    P3.sbOpening_Balance_from_Disk := P1.sbOpening_Balance_from_Disk;
    ChangedFields[i] := tksbOpening_Balance_from_Disk;
    Inc(i);
  end;
  if (P1.sbClosing_Balance_from_Disk <> P2.sbClosing_Balance_from_Disk) then begin
    P3.sbClosing_Balance_from_Disk := P1.sbClosing_Balance_from_Disk;
    ChangedFields[i] := tksbClosing_Balance_from_Disk;
    Inc(i);
  end;
  if (P1.sbAttach_Required <> P2.sbAttach_Required) then begin
    P3.sbAttach_Required := P1.sbAttach_Required;
    ChangedFields[i] := tksbAttach_Required;
    Inc(i);
  end;
  if (P1.sbWas_On_Latest_Disk <> P2.sbWas_On_Latest_Disk) then begin
    P3.sbWas_On_Latest_Disk := P1.sbWas_On_Latest_Disk;
    ChangedFields[i] := tksbWas_On_Latest_Disk;
    Inc(i);
  end;
  if (P1.sbLast_Entry_Date <> P2.sbLast_Entry_Date) then begin
    P3.sbLast_Entry_Date := P1.sbLast_Entry_Date;
    ChangedFields[i] := tksbLast_Entry_Date;
    Inc(i);
  end;
  if (P1.sbDate_Of_Last_Entry_Printed <> P2.sbDate_Of_Last_Entry_Printed) then begin
    P3.sbDate_Of_Last_Entry_Printed := P1.sbDate_Of_Last_Entry_Printed;
    ChangedFields[i] := tksbDate_Of_Last_Entry_Printed;
    Inc(i);
  end;
  if (P1.sbMark_As_Deleted <> P2.sbMark_As_Deleted) then begin
    P3.sbMark_As_Deleted := P1.sbMark_As_Deleted;
    ChangedFields[i] := tksbMark_As_Deleted;
    Inc(i);
  end;
  if (P1.sbFile_Code <> P2.sbFile_Code) then begin
    P3.sbFile_Code := P1.sbFile_Code;
    ChangedFields[i] := tksbFile_Code;
    Inc(i);
  end;
  if (P1.sbClient_ID <> P2.sbClient_ID) then begin
    P3.sbClient_ID := P1.sbClient_ID;
    ChangedFields[i] := tksbClient_ID;
    Inc(i);
  end;
  if (P1.sbMatter_ID <> P2.sbMatter_ID) then begin
    P3.sbMatter_ID := P1.sbMatter_ID;
    ChangedFields[i] := tksbMatter_ID;
    Inc(i);
  end;
  if (P1.sbAssignment_ID <> P2.sbAssignment_ID) then begin
    P3.sbAssignment_ID := P1.sbAssignment_ID;
    ChangedFields[i] := tksbAssignment_ID;
    Inc(i);
  end;
  if (P1.sbDisbursement_ID <> P2.sbDisbursement_ID) then begin
    P3.sbDisbursement_ID := P1.sbDisbursement_ID;
    ChangedFields[i] := tksbDisbursement_ID;
    Inc(i);
  end;
  if (P1.sbAccount_Type <> P2.sbAccount_Type) then begin
    P3.sbAccount_Type := P1.sbAccount_Type;
    ChangedFields[i] := tksbAccount_Type;
    Inc(i);
  end;
  if (P1.sbJob_Code <> P2.sbJob_Code) then begin
    P3.sbJob_Code := P1.sbJob_Code;
    ChangedFields[i] := tksbJob_Code;
    Inc(i);
  end;
  if (P1.sbActivity_Code <> P2.sbActivity_Code) then begin
    P3.sbActivity_Code := P1.sbActivity_Code;
    ChangedFields[i] := tksbActivity_Code;
    Inc(i);
  end;
  if (P1.sbUnused <> P2.sbUnused) then begin
    P3.sbUnused := P1.sbUnused;
    ChangedFields[i] := tksbUnused;
    Inc(i);
  end;
  if (P1.sbFirst_Available_Date <> P2.sbFirst_Available_Date) then begin
    P3.sbFirst_Available_Date := P1.sbFirst_Available_Date;
    ChangedFields[i] := tksbFirst_Available_Date;
    Inc(i);
  end;
  if (P1.sbNo_Charge_Account <> P2.sbNo_Charge_Account) then begin
    P3.sbNo_Charge_Account := P1.sbNo_Charge_Account;
    ChangedFields[i] := tksbNo_Charge_Account;
    Inc(i);
  end;
  if (P1.sbCurrency_Code <> P2.sbCurrency_Code) then begin
    P3.sbCurrency_Code := P1.sbCurrency_Code;
    ChangedFields[i] := tksbCurrency_Code;
    Inc(i);
  end;
  if (P1.sbInstitution <> P2.sbInstitution) then begin
    P3.sbInstitution := P1.sbInstitution;
    ChangedFields[i] := tksbInstitution;
    Inc(i);
  end;
  if (P1.sbInActive <> P2.sbInActive) then begin
    P3.sbInActive := P1.sbInActive;
    ChangedFields[i] := tksbInActive;
    Inc(i);
  end;
  if (P1.sbBankLink_Code <> P2.sbBankLink_Code) then begin
    P3.sbBankLink_Code := P1.sbBankLink_Code;
    ChangedFields[i] := tksbBankLink_Code;
    Inc(i);
  end;
  if (P1.sbFrequency <> P2.sbFrequency) then begin
    P3.sbFrequency := P1.sbFrequency;
    ChangedFields[i] := tksbFrequency;
    Inc(i);
  end;
  if (P1.sbFrequency_Change_Pending <> P2.sbFrequency_Change_Pending) then begin
    P3.sbFrequency_Change_Pending := P1.sbFrequency_Change_Pending;
    ChangedFields[i] := tksbFrequency_Change_Pending;
    Inc(i);
  end;
  if (P1.sbAudit_Record_ID <> P2.sbAudit_Record_ID) then begin
    P3.sbAudit_Record_ID := P1.sbAudit_Record_ID;
    ChangedFields[i] := tksbAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_System_Bank_Account_Rec(P1, P2: pSystem_Bank_Account_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_System_Bank_Account_Rec(P1^, S);
    S.Position := 0;
    Read_System_Bank_Account_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
