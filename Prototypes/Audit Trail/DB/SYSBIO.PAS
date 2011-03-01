UNIT SYsbIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_System_Bank_Account          = 50 ;
   tkEnd_System_Bank_Account            = 51 ;

FUNCTION  IsASystem_Bank_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec ; Var F : TIOStream );
PROCEDURE Read_System_Bank_Account_Rec ( Var O : TSystem_Bank_Account_Rec ; Var F : TIOStream );
FUNCTION  New_System_Bank_Account_Rec : pSystem_Bank_Account_Rec ;
PROCEDURE Free_System_Bank_Account_Rec_Dynamic_Fields ( Var O : TSystem_Bank_Account_Rec );

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

END.
