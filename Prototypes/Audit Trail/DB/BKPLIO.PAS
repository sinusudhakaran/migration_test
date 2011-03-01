UNIT BKplIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Line                   = 95 ;
   tkEnd_Payee_Line                     = 96 ;

FUNCTION  IsAPayee_Line_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Line_Rec : pPayee_Line_Rec ;
PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPLIO';
   SBoundsError        = 'BKPLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPLIO Error: Pointer is NIL in IsAPayee_Line_Rec';
   SInvalidType        = 'BKPLIO Error: Type is invalid in IsAPayee_Line_Rec';
   SInvalidEOR         = 'BKPLIO Error: EOR is missing in IsAPayee_Line_Rec';
   SUnknownToken       = 'BKPLIO Error: Unknown token %d in Read_Payee_Line_Rec';
   SInsufficientMemory = 'BKPLIO Error: Out of memory in New_Payee_Line_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkplAccount                          = 97 ;
   tkplPercentage                       = 98 ;
   tkplGST_Class                        = 99 ;
   tkplGST_Has_Been_Edited              = 100 ;
   tkplGL_Narration                     = 101 ;
   tkplLine_Type                        = 102 ;
   tkplGST_Amount                       = 103 ;
   tkplSF_PCFranked                     = 104 ;
   tkplSF_Member_ID                     = 105 ;
   tkplSF_Fund_ID                       = 106 ;
   tkplSF_Fund_Code                     = 107 ;
   tkplSF_Trans_ID                      = 108 ;
   tkplSF_Trans_Code                    = 109 ;
   tkplSF_Member_Account_ID             = 110 ;
   tkplSF_Member_Account_Code           = 111 ;
   tkplSF_Edited                        = 112 ;
   tkplSF_Member_Component              = 113 ;
   tkplSF_PCUnFranked                   = 114 ;
   tkplQuantity                         = 115 ;
   tkplSF_GDT_Date                      = 116 ;
   tkplSF_Tax_Free_Dist                 = 117 ;
   tkplSF_Tax_Exempt_Dist               = 118 ;
   tkplSF_Tax_Deferred_Dist             = 119 ;
   tkplSF_TFN_Credits                   = 120 ;
   tkplSF_Foreign_Income                = 121 ;
   tkplSF_Foreign_Tax_Credits           = 122 ;
   tkplSF_Capital_Gains_Indexed         = 123 ;
   tkplSF_Capital_Gains_Disc            = 124 ;
   tkplSF_Capital_Gains_Other           = 125 ;
   tkplSF_Other_Expenses                = 126 ;
   tkplSF_Interest                      = 127 ;
   tkplSF_Capital_Gains_Foreign_Disc    = 128 ;
   tkplSF_Rent                          = 129 ;
   tkplSF_Special_Income                = 130 ;
   tkplSF_Other_Tax_Credit              = 131 ;
   tkplSF_Non_Resident_Tax              = 132 ;
   tkplSF_Foreign_Capital_Gains_Credit  = 133 ;
   tkplSF_Capital_Gains_Fraction_Half   = 134 ;
   tkplSF_Ledger_ID                     = 135 ;
   tkplSF_Ledger_Name                   = 136 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Line_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Line_Rec ( P )^ do Begin
      If plRecord_Type <> tkBegin_Payee_Line then
         Raise ECorruptData.Create( SInvalidType );
      If plEOR <> tkEnd_Payee_Line then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Line );
      F.WriteStringValue( tkplAccount , plAccount );
      F.WriteMoneyValue( tkplPercentage , plPercentage );
      F.WriteByteValue( tkplGST_Class , plGST_Class );
      F.WriteBooleanValue( tkplGST_Has_Been_Edited , plGST_Has_Been_Edited );
      F.WriteAnsiStringValue( tkplGL_Narration , plGL_Narration );
      F.WriteByteValue( tkplLine_Type , plLine_Type );
      F.WriteMoneyValue( tkplGST_Amount , plGST_Amount );
      F.WriteMoneyValue( tkplSF_PCFranked , plSF_PCFranked );
      F.WriteStringValue( tkplSF_Member_ID , plSF_Member_ID );
      F.WriteIntegerValue( tkplSF_Fund_ID , plSF_Fund_ID );
      F.WriteStringValue( tkplSF_Fund_Code , plSF_Fund_Code );
      F.WriteIntegerValue( tkplSF_Trans_ID , plSF_Trans_ID );
      F.WriteAnsiStringValue( tkplSF_Trans_Code , plSF_Trans_Code );
      F.WriteIntegerValue( tkplSF_Member_Account_ID , plSF_Member_Account_ID );
      F.WriteStringValue( tkplSF_Member_Account_Code , plSF_Member_Account_Code );
      F.WriteBooleanValue( tkplSF_Edited , plSF_Edited );
      F.WriteByteValue( tkplSF_Member_Component , plSF_Member_Component );
      F.WriteMoneyValue( tkplSF_PCUnFranked , plSF_PCUnFranked );
      F.WriteMoneyValue( tkplQuantity , plQuantity );
      F.WriteDateValue( tkplSF_GDT_Date , plSF_GDT_Date );
      F.WriteMoneyValue( tkplSF_Tax_Free_Dist , plSF_Tax_Free_Dist );
      F.WriteMoneyValue( tkplSF_Tax_Exempt_Dist , plSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tkplSF_Tax_Deferred_Dist , plSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tkplSF_TFN_Credits , plSF_TFN_Credits );
      F.WriteMoneyValue( tkplSF_Foreign_Income , plSF_Foreign_Income );
      F.WriteMoneyValue( tkplSF_Foreign_Tax_Credits , plSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Indexed , plSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Disc , plSF_Capital_Gains_Disc );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Other , plSF_Capital_Gains_Other );
      F.WriteMoneyValue( tkplSF_Other_Expenses , plSF_Other_Expenses );
      F.WriteMoneyValue( tkplSF_Interest , plSF_Interest );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Foreign_Disc , plSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tkplSF_Rent , plSF_Rent );
      F.WriteMoneyValue( tkplSF_Special_Income , plSF_Special_Income );
      F.WriteMoneyValue( tkplSF_Other_Tax_Credit , plSF_Other_Tax_Credit );
      F.WriteMoneyValue( tkplSF_Non_Resident_Tax , plSF_Non_Resident_Tax );
      F.WriteMoneyValue( tkplSF_Foreign_Capital_Gains_Credit , plSF_Foreign_Capital_Gains_Credit );
      F.WriteBooleanValue( tkplSF_Capital_Gains_Fraction_Half , plSF_Capital_Gains_Fraction_Half );
      F.WriteIntegerValue( tkplSF_Ledger_ID , plSF_Ledger_ID );
      F.WriteAnsiStringValue( tkplSF_Ledger_Name , plSF_Ledger_Name );
      F.WriteToken( tkEnd_Payee_Line );
   end;
end; { of Write_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Line_Rec_Size, 0 );
   O.plRecord_Type := tkBegin_Payee_Line;
   O.plEOR := tkEnd_Payee_Line;
   Token := tkBegin_Payee_Line;

   While Token <> tkEnd_Payee_Line do With O do
   Begin
      Case Token of
         tkBegin_Payee_Line :; { Do Nothing }
         tkEnd_Payee_Line :; { Do Nothing }
         tkplAccount                          : plAccount := F.ReadStringValue;
         tkplPercentage                       : plPercentage := F.ReadMoneyValue;
         tkplGST_Class                        : plGST_Class := F.ReadByteValue;
         tkplGST_Has_Been_Edited              : plGST_Has_Been_Edited := F.ReadBooleanValue;
         tkplGL_Narration                     : plGL_Narration := F.ReadAnsiStringValue;
         tkplLine_Type                        : plLine_Type := F.ReadByteValue;
         tkplGST_Amount                       : plGST_Amount := F.ReadMoneyValue;
         tkplSF_PCFranked                     : plSF_PCFranked := F.ReadMoneyValue;
         tkplSF_Member_ID                     : plSF_Member_ID := F.ReadStringValue;
         tkplSF_Fund_ID                       : plSF_Fund_ID := F.ReadIntegerValue;
         tkplSF_Fund_Code                     : plSF_Fund_Code := F.ReadStringValue;
         tkplSF_Trans_ID                      : plSF_Trans_ID := F.ReadIntegerValue;
         tkplSF_Trans_Code                    : plSF_Trans_Code := F.ReadAnsiStringValue;
         tkplSF_Member_Account_ID             : plSF_Member_Account_ID := F.ReadIntegerValue;
         tkplSF_Member_Account_Code           : plSF_Member_Account_Code := F.ReadStringValue;
         tkplSF_Edited                        : plSF_Edited := F.ReadBooleanValue;
         tkplSF_Member_Component              : plSF_Member_Component := F.ReadByteValue;
         tkplSF_PCUnFranked                   : plSF_PCUnFranked := F.ReadMoneyValue;
         tkplQuantity                         : plQuantity := F.ReadMoneyValue;
         tkplSF_GDT_Date                      : plSF_GDT_Date := F.ReadDateValue;
         tkplSF_Tax_Free_Dist                 : plSF_Tax_Free_Dist := F.ReadMoneyValue;
         tkplSF_Tax_Exempt_Dist               : plSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tkplSF_Tax_Deferred_Dist             : plSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tkplSF_TFN_Credits                   : plSF_TFN_Credits := F.ReadMoneyValue;
         tkplSF_Foreign_Income                : plSF_Foreign_Income := F.ReadMoneyValue;
         tkplSF_Foreign_Tax_Credits           : plSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Indexed         : plSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Disc            : plSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Other           : plSF_Capital_Gains_Other := F.ReadMoneyValue;
         tkplSF_Other_Expenses                : plSF_Other_Expenses := F.ReadMoneyValue;
         tkplSF_Interest                      : plSF_Interest := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Foreign_Disc    : plSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tkplSF_Rent                          : plSF_Rent := F.ReadMoneyValue;
         tkplSF_Special_Income                : plSF_Special_Income := F.ReadMoneyValue;
         tkplSF_Other_Tax_Credit              : plSF_Other_Tax_Credit := F.ReadMoneyValue;
         tkplSF_Non_Resident_Tax              : plSF_Non_Resident_Tax := F.ReadMoneyValue;
         tkplSF_Foreign_Capital_Gains_Credit  : plSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Fraction_Half   : plSF_Capital_Gains_Fraction_Half := F.ReadBooleanValue;
         tkplSF_Ledger_ID                     : plSF_Ledger_ID := F.ReadIntegerValue;
         tkplSF_Ledger_Name                   : plSF_Ledger_Name := F.ReadAnsiStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Line_Rec : pPayee_Line_Rec ;

Var
   P : pPayee_Line_Rec;
Begin
   SafeGetMem( P, Payee_Line_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Line_Rec_Size, 0 );
      plRecord_Type := tkBegin_Payee_Line;
      plEOR         := tkEnd_Payee_Line;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Line_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      plGL_Narration := '' ;
      plSF_Trans_Code := '' ;
      plSF_Ledger_Name := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
