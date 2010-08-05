UNIT ECecIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_ECoding_File_Details         = 20 ;
   tkEnd_ECoding_File_Details           = 21 ;

FUNCTION  IsAECoding_File_Details_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_ECoding_File_Details_Rec ( Var O : TECoding_File_Details_Rec ; Var F : TIOStream );
PROCEDURE Read_ECoding_File_Details_Rec ( Var O : TECoding_File_Details_Rec ; Var F : TIOStream );
FUNCTION  New_ECoding_File_Details_Rec : pECoding_File_Details_Rec ;
PROCEDURE Free_ECoding_File_Details_Rec_Dynamic_Fields ( Var O : TECoding_File_Details_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'ECECIO';
   SBoundsError        = 'ECECIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECECIO Error: Pointer is NIL in IsAECoding_File_Details_Rec';
   SInvalidType        = 'ECECIO Error: Type is invalid in IsAECoding_File_Details_Rec';
   SInvalidEOR         = 'ECECIO Error: EOR is missing in IsAECoding_File_Details_Rec';
   SUnknownToken       = 'ECECIO Error: Unknown token %d in Read_ECoding_File_Details_Rec';
   SInsufficientMemory = 'ECECIO Error: Out of memory in New_ECoding_File_Details_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkecCode                             = 22 ;
   tkecName                             = 23 ;
   tkecContact_Name                     = 24 ;
   tkecFile_Password                    = 25 ;
   tkecPractice_Name                    = 26 ;
   tkecContact_Person                   = 27 ;
   tkecContact_EMail_Address            = 28 ;
   tkecContact_Phone_Number             = 29 ;
   tkecCountry                          = 30 ;
   tkecFile_Save_Count                  = 31 ;
   tkecAccount_Code_Mask                = 32 ;
   tkecMagic_Number                     = 33 ;
   tkecGST_Applies_From                 = 34 ;
   tkecGST_Rates                        = 35 ;
   tkecHide_Quantity_Col                = 36 ;
   tkecDate_Range_From                  = 37 ;
   tkecDate_Range_To                    = 38 ;
   tkecFirst_Save_Done                  = 39 ;
   tkecFile_Number                      = 40 ;
   tkecHide_GST_Col                     = 41 ;
   tkecHide_Tax_Invoice_Col             = 42 ;
   tkecHide_Account_Col                 = 43 ;
   tkecHide_Payee_Col                   = 44 ;
   tkecRestrict_UPIs                    = 45 ;
   tkecPractice_Logo                    = 46 ;
   tkecPractice_Web_Site                = 47 ;
   tkecNotes                            = 48 ;
   tkecShow_Notes_On_Open               = 49 ;
   tkecFile_Version                     = 50 ;
   tkecPractice_Code                    = 51 ;
   tkecSuper_Fund_System                = 52 ;
   tkecTAX_Applies_From                 = 53 ;
   tkecTAX_Rates                        = 54 ;
   tkecHide_Job_Col                     = 55 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAECoding_File_Details_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PECoding_File_Details_Rec ( P )^ do Begin
      If ecRecord_Type <> tkBegin_ECoding_File_Details then
         Raise ECorruptData.Create( SInvalidType );
      If ecEOR <> tkEnd_ECoding_File_Details then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_ECoding_File_Details_Rec ( Var O : TECoding_File_Details_Rec ; Var F : TIOStream );

Var
   I     : Byte;
   I1    : Byte;
   I2    : Byte;

Begin
   If IsAECoding_File_Details_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_ECoding_File_Details );
      F.WriteStringValue( tkecCode , ecCode );
      F.WriteStringValue( tkecName , ecName );
      F.WriteStringValue( tkecContact_Name , ecContact_Name );
      F.WriteStringValue( tkecFile_Password , ecFile_Password );
      F.WriteStringValue( tkecPractice_Name , ecPractice_Name );
      F.WriteStringValue( tkecContact_Person , ecContact_Person );
      F.WriteStringValue( tkecContact_EMail_Address , ecContact_EMail_Address );
      F.WriteStringValue( tkecContact_Phone_Number , ecContact_Phone_Number );
      F.WriteByteValue( tkecCountry , ecCountry );
      F.WriteIntegerValue( tkecFile_Save_Count , ecFile_Save_Count );
      F.WriteStringValue( tkecAccount_Code_Mask , ecAccount_Code_Mask );
      F.WriteIntegerValue( tkecMagic_Number , ecMagic_Number );
      For i := 1 to 5 do F.WriteBDateValue( tkecGST_Applies_From , i, ecGST_Applies_From[ i ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkecGST_Rates , I1, I2, ecGST_Rates[ I1, I2 ] );
      F.WriteBooleanValue( tkecHide_Quantity_Col , ecHide_Quantity_Col );
      F.WriteIntegerValue( tkecDate_Range_From , ecDate_Range_From );
      F.WriteIntegerValue( tkecDate_Range_To , ecDate_Range_To );
      F.WriteBooleanValue( tkecFirst_Save_Done , ecFirst_Save_Done );
      F.WriteIntegerValue( tkecFile_Number , ecFile_Number );
      F.WriteBooleanValue( tkecHide_GST_Col , ecHide_GST_Col );
      F.WriteBooleanValue( tkecHide_Tax_Invoice_Col , ecHide_Tax_Invoice_Col );
      F.WriteBooleanValue( tkecHide_Account_Col , ecHide_Account_Col );
      F.WriteBooleanValue( tkecHide_Payee_Col , ecHide_Payee_Col );
      F.WriteBooleanValue( tkecRestrict_UPIs , ecRestrict_UPIs );
      F.WriteAnsiStringValue( tkecPractice_Logo , ecPractice_Logo );
      F.WriteAnsiStringValue( tkecPractice_Web_Site , ecPractice_Web_Site );
      F.WriteAnsiStringValue( tkecNotes , ecNotes );
      F.WriteBooleanValue( tkecShow_Notes_On_Open , ecShow_Notes_On_Open );
      F.WriteIntegerValue( tkecFile_Version , ecFile_Version );
      F.WriteAnsiStringValue( tkecPractice_Code , ecPractice_Code );
      F.WriteByteValue( tkecSuper_Fund_System , ecSuper_Fund_System );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBDateValue( tkecTAX_Applies_From , I1, I2, ecTAX_Applies_From[ I1, I2 ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkecTAX_Rates , I1, I2, ecTAX_Rates[ I1, I2 ] );
      F.WriteBooleanValue( tkecHide_Job_Col , ecHide_Job_Col );
      F.WriteToken( tkEnd_ECoding_File_Details );
   end;
end; { of Write_ECoding_File_Details_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_ECoding_File_Details_Rec ( Var O : TECoding_File_Details_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   I1    : Byte;
   I2    : Byte;
   M     : Money;
   D     : Integer;

Begin
   FillChar( O, ECoding_File_Details_Rec_Size, 0 );
   O.ecRecord_Type := tkBegin_ECoding_File_Details;
   O.ecEOR := tkEnd_ECoding_File_Details;
   Token := tkBegin_ECoding_File_Details;

   While Token <> tkEnd_ECoding_File_Details do With O do
   Begin
      Case Token of
         tkBegin_ECoding_File_Details :; { Do Nothing }
         tkEnd_ECoding_File_Details :; { Do Nothing }
         tkecCode                             : ecCode := F.ReadStringValue;
         tkecName                             : ecName := F.ReadStringValue;
         tkecContact_Name                     : ecContact_Name := F.ReadStringValue;
         tkecFile_Password                    : ecFile_Password := F.ReadStringValue;
         tkecPractice_Name                    : ecPractice_Name := F.ReadStringValue;
         tkecContact_Person                   : ecContact_Person := F.ReadStringValue;
         tkecContact_EMail_Address            : ecContact_EMail_Address := F.ReadStringValue;
         tkecContact_Phone_Number             : ecContact_Phone_Number := F.ReadStringValue;
         tkecCountry                          : ecCountry := F.ReadByteValue;
         tkecFile_Save_Count                  : ecFile_Save_Count := F.ReadIntegerValue;
         tkecAccount_Code_Mask                : ecAccount_Code_Mask := F.ReadStringValue;
         tkecMagic_Number                     : ecMagic_Number := F.ReadIntegerValue;
         tkecGST_Applies_From                 : 
            Begin
               D := F.ReadBDateValue( I );
               CheckBounds( I, 1, 5, 'ecGST_Applies_From' );
               ecGST_Applies_From[ I ] := D;
            end;
         tkecGST_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'ecGST_Rates' );
               CheckBounds( I2, 1, 5, 'ecGST_Rates' );
               ecGST_Rates[ I1, I2 ] := M;
            end;
         tkecHide_Quantity_Col                : ecHide_Quantity_Col := F.ReadBooleanValue;
         tkecDate_Range_From                  : ecDate_Range_From := F.ReadIntegerValue;
         tkecDate_Range_To                    : ecDate_Range_To := F.ReadIntegerValue;
         tkecFirst_Save_Done                  : ecFirst_Save_Done := F.ReadBooleanValue;
         tkecFile_Number                      : ecFile_Number := F.ReadIntegerValue;
         tkecHide_GST_Col                     : ecHide_GST_Col := F.ReadBooleanValue;
         tkecHide_Tax_Invoice_Col             : ecHide_Tax_Invoice_Col := F.ReadBooleanValue;
         tkecHide_Account_Col                 : ecHide_Account_Col := F.ReadBooleanValue;
         tkecHide_Payee_Col                   : ecHide_Payee_Col := F.ReadBooleanValue;
         tkecRestrict_UPIs                    : ecRestrict_UPIs := F.ReadBooleanValue;
         tkecPractice_Logo                    : ecPractice_Logo := F.ReadAnsiStringValue;
         tkecPractice_Web_Site                : ecPractice_Web_Site := F.ReadAnsiStringValue;
         tkecNotes                            : ecNotes := F.ReadAnsiStringValue;
         tkecShow_Notes_On_Open               : ecShow_Notes_On_Open := F.ReadBooleanValue;
         tkecFile_Version                     : ecFile_Version := F.ReadIntegerValue;
         tkecPractice_Code                    : ecPractice_Code := F.ReadAnsiStringValue;
         tkecSuper_Fund_System                : ecSuper_Fund_System := F.ReadByteValue;
         tkecTAX_Applies_From                 : 
            Begin
               D := F.ReadBBDateValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'ecTAX_Applies_From' );
               CheckBounds( I2, 1, 5, 'ecTAX_Applies_From' );
               ecTAX_Applies_From[ I1, I2 ] := D;
            end;
         tkecTAX_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'ecTAX_Rates' );
               CheckBounds( I2, 1, 5, 'ecTAX_Rates' );
               ecTAX_Rates[ I1, I2 ] := M;
            end;
         tkecHide_Job_Col                     : ecHide_Job_Col := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_ECoding_File_Details_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_ECoding_File_Details_Rec : pECoding_File_Details_Rec ;

Var
   P : pECoding_File_Details_Rec;
Begin
   SafeGetMem( P, ECoding_File_Details_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, ECoding_File_Details_Rec_Size, 0 );
      ecRecord_Type := tkBegin_ECoding_File_Details;
      ecEOR         := tkEnd_ECoding_File_Details;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_ECoding_File_Details_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_ECoding_File_Details_Rec_Dynamic_Fields ( Var O : TECoding_File_Details_Rec );

Begin
   If IsAECoding_File_Details_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      ecPractice_Logo := '' ;
      ecPractice_Web_Site := '' ;
      ecNotes := '' ;
      ecPractice_Code := '' ;
      ecFilename := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
