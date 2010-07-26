UNIT BKmlIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Memorisation_Line            = 145 ;
   tkEnd_Memorisation_Line              = 146 ;

FUNCTION  IsAMemorisation_Line_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );
PROCEDURE Read_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );
FUNCTION  New_Memorisation_Line_Rec : pMemorisation_Line_Rec ;
PROCEDURE Free_Memorisation_Line_Rec_Dynamic_Fields ( Var O : TMemorisation_Line_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMLIO';
   SBoundsError        = 'BKMLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMLIO Error: Pointer is NIL in IsAMemorisation_Line_Rec';
   SInvalidType        = 'BKMLIO Error: Type is invalid in IsAMemorisation_Line_Rec';
   SInvalidEOR         = 'BKMLIO Error: EOR is missing in IsAMemorisation_Line_Rec';
   SUnknownToken       = 'BKMLIO Error: Unknown token %d in Read_Memorisation_Line_Rec';
   SInsufficientMemory = 'BKMLIO Error: Out of memory in New_Memorisation_Line_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmlAccount                          = 147 ;
   tkmlPercentage                       = 148 ;
   tkmlGST_Class                        = 149 ;
   tkmlGST_Has_Been_Edited              = 150 ;
   tkmlGL_Narration                     = 151 ;
   tkmlLine_Type                        = 152 ;
   tkmlGST_Amount                       = 153 ;
   tkmlPayee                            = 154 ;
   tkmlSF_PCFranked                     = 155 ;
   tkmlSF_Member_ID                     = 156 ;
   tkmlSF_Fund_ID                       = 157 ;
   tkmlSF_Fund_Code                     = 158 ;
   tkmlSF_Trans_ID                      = 159 ;
   tkmlSF_Trans_Code                    = 160 ;
   tkmlSF_Member_Account_ID             = 161 ;
   tkmlSF_Member_Account_Code           = 162 ;
   tkmlSF_Edited                        = 163 ;
   tkmlSF_Member_Component              = 164 ;
   tkmlSF_PCUnFranked                   = 165 ;
   tkmlJob_Code                         = 166 ;
   tkmlQuantity                         = 167 ;
   tkmlSF_GDT_Date                      = 168 ;
   tkmlSF_Tax_Free_Dist                 = 169 ;
   tkmlSF_Tax_Exempt_Dist               = 170 ;
   tkmlSF_Tax_Deferred_Dist             = 171 ;
   tkmlSF_TFN_Credits                   = 172 ;
   tkmlSF_Foreign_Income                = 173 ;
   tkmlSF_Foreign_Tax_Credits           = 174 ;
   tkmlSF_Capital_Gains_Indexed         = 175 ;
   tkmlSF_Capital_Gains_Disc            = 176 ;
   tkmlSF_Capital_Gains_Other           = 177 ;
   tkmlSF_Other_Expenses                = 178 ;
   tkmlSF_Interest                      = 179 ;
   tkmlSF_Capital_Gains_Foreign_Disc    = 180 ;
   tkmlSF_Rent                          = 181 ;
   tkmlSF_Special_Income                = 182 ;
   tkmlSF_Other_Tax_Credit              = 183 ;
   tkmlSF_Non_Resident_Tax              = 184 ;
   tkmlSF_Foreign_Capital_Gains_Credit  = 185 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMemorisation_Line_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMemorisation_Line_Rec ( P )^ do Begin
      If mlRecord_Type <> tkBegin_Memorisation_Line then
         Raise ECorruptData.Create( SInvalidType );
      If mlEOR <> tkEnd_Memorisation_Line then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );

Begin
   If IsAMemorisation_Line_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Memorisation_Line );
      F.WriteStringValue( tkmlAccount , mlAccount );
      F.WriteMoneyValue( tkmlPercentage , mlPercentage );
      F.WriteByteValue( tkmlGST_Class , mlGST_Class );
      F.WriteBooleanValue( tkmlGST_Has_Been_Edited , mlGST_Has_Been_Edited );
      F.WriteAnsiStringValue( tkmlGL_Narration , mlGL_Narration );
      F.WriteByteValue( tkmlLine_Type , mlLine_Type );
      F.WriteMoneyValue( tkmlGST_Amount , mlGST_Amount );
      F.WriteIntegerValue( tkmlPayee , mlPayee );
      F.WriteMoneyValue( tkmlSF_PCFranked , mlSF_PCFranked );
      F.WriteStringValue( tkmlSF_Member_ID , mlSF_Member_ID );
      F.WriteIntegerValue( tkmlSF_Fund_ID , mlSF_Fund_ID );
      F.WriteStringValue( tkmlSF_Fund_Code , mlSF_Fund_Code );
      F.WriteIntegerValue( tkmlSF_Trans_ID , mlSF_Trans_ID );
      F.WriteAnsiStringValue( tkmlSF_Trans_Code , mlSF_Trans_Code );
      F.WriteIntegerValue( tkmlSF_Member_Account_ID , mlSF_Member_Account_ID );
      F.WriteStringValue( tkmlSF_Member_Account_Code , mlSF_Member_Account_Code );
      F.WriteBooleanValue( tkmlSF_Edited , mlSF_Edited );
      F.WriteByteValue( tkmlSF_Member_Component , mlSF_Member_Component );
      F.WriteMoneyValue( tkmlSF_PCUnFranked , mlSF_PCUnFranked );
      F.WriteStringValue( tkmlJob_Code , mlJob_Code );
      F.WriteMoneyValue( tkmlQuantity , mlQuantity );
      F.WriteDateValue( tkmlSF_GDT_Date , mlSF_GDT_Date );
      F.WriteMoneyValue( tkmlSF_Tax_Free_Dist , mlSF_Tax_Free_Dist );
      F.WriteMoneyValue( tkmlSF_Tax_Exempt_Dist , mlSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tkmlSF_Tax_Deferred_Dist , mlSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tkmlSF_TFN_Credits , mlSF_TFN_Credits );
      F.WriteMoneyValue( tkmlSF_Foreign_Income , mlSF_Foreign_Income );
      F.WriteMoneyValue( tkmlSF_Foreign_Tax_Credits , mlSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Indexed , mlSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Disc , mlSF_Capital_Gains_Disc );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Other , mlSF_Capital_Gains_Other );
      F.WriteMoneyValue( tkmlSF_Other_Expenses , mlSF_Other_Expenses );
      F.WriteMoneyValue( tkmlSF_Interest , mlSF_Interest );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Foreign_Disc , mlSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tkmlSF_Rent , mlSF_Rent );
      F.WriteMoneyValue( tkmlSF_Special_Income , mlSF_Special_Income );
      F.WriteMoneyValue( tkmlSF_Other_Tax_Credit , mlSF_Other_Tax_Credit );
      F.WriteMoneyValue( tkmlSF_Non_Resident_Tax , mlSF_Non_Resident_Tax );
      F.WriteMoneyValue( tkmlSF_Foreign_Capital_Gains_Credit , mlSF_Foreign_Capital_Gains_Credit );
      F.WriteToken( tkEnd_Memorisation_Line );
   end;
end; { of Write_Memorisation_Line_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Memorisation_Line_Rec_Size, 0 );
   O.mlRecord_Type := tkBegin_Memorisation_Line;
   O.mlEOR := tkEnd_Memorisation_Line;
   Token := tkBegin_Memorisation_Line;

   While Token <> tkEnd_Memorisation_Line do With O do
   Begin
      Case Token of
         tkBegin_Memorisation_Line :; { Do Nothing }
         tkEnd_Memorisation_Line :; { Do Nothing }
         tkmlAccount                          : mlAccount := F.ReadStringValue;
         tkmlPercentage                       : mlPercentage := F.ReadMoneyValue;
         tkmlGST_Class                        : mlGST_Class := F.ReadByteValue;
         tkmlGST_Has_Been_Edited              : mlGST_Has_Been_Edited := F.ReadBooleanValue;
         tkmlGL_Narration                     : mlGL_Narration := F.ReadAnsiStringValue;
         tkmlLine_Type                        : mlLine_Type := F.ReadByteValue;
         tkmlGST_Amount                       : mlGST_Amount := F.ReadMoneyValue;
         tkmlPayee                            : mlPayee := F.ReadIntegerValue;
         tkmlSF_PCFranked                     : mlSF_PCFranked := F.ReadMoneyValue;
         tkmlSF_Member_ID                     : mlSF_Member_ID := F.ReadStringValue;
         tkmlSF_Fund_ID                       : mlSF_Fund_ID := F.ReadIntegerValue;
         tkmlSF_Fund_Code                     : mlSF_Fund_Code := F.ReadStringValue;
         tkmlSF_Trans_ID                      : mlSF_Trans_ID := F.ReadIntegerValue;
         tkmlSF_Trans_Code                    : mlSF_Trans_Code := F.ReadAnsiStringValue;
         tkmlSF_Member_Account_ID             : mlSF_Member_Account_ID := F.ReadIntegerValue;
         tkmlSF_Member_Account_Code           : mlSF_Member_Account_Code := F.ReadStringValue;
         tkmlSF_Edited                        : mlSF_Edited := F.ReadBooleanValue;
         tkmlSF_Member_Component              : mlSF_Member_Component := F.ReadByteValue;
         tkmlSF_PCUnFranked                   : mlSF_PCUnFranked := F.ReadMoneyValue;
         tkmlJob_Code                         : mlJob_Code := F.ReadStringValue;
         tkmlQuantity                         : mlQuantity := F.ReadMoneyValue;
         tkmlSF_GDT_Date                      : mlSF_GDT_Date := F.ReadDateValue;
         tkmlSF_Tax_Free_Dist                 : mlSF_Tax_Free_Dist := F.ReadMoneyValue;
         tkmlSF_Tax_Exempt_Dist               : mlSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tkmlSF_Tax_Deferred_Dist             : mlSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tkmlSF_TFN_Credits                   : mlSF_TFN_Credits := F.ReadMoneyValue;
         tkmlSF_Foreign_Income                : mlSF_Foreign_Income := F.ReadMoneyValue;
         tkmlSF_Foreign_Tax_Credits           : mlSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Indexed         : mlSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Disc            : mlSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Other           : mlSF_Capital_Gains_Other := F.ReadMoneyValue;
         tkmlSF_Other_Expenses                : mlSF_Other_Expenses := F.ReadMoneyValue;
         tkmlSF_Interest                      : mlSF_Interest := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Foreign_Disc    : mlSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tkmlSF_Rent                          : mlSF_Rent := F.ReadMoneyValue;
         tkmlSF_Special_Income                : mlSF_Special_Income := F.ReadMoneyValue;
         tkmlSF_Other_Tax_Credit              : mlSF_Other_Tax_Credit := F.ReadMoneyValue;
         tkmlSF_Non_Resident_Tax              : mlSF_Non_Resident_Tax := F.ReadMoneyValue;
         tkmlSF_Foreign_Capital_Gains_Credit  : mlSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Memorisation_Line_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Memorisation_Line_Rec : pMemorisation_Line_Rec ;

Var
   P : pMemorisation_Line_Rec;
Begin
   SafeGetMem( P, Memorisation_Line_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Memorisation_Line_Rec_Size, 0 );
      mlRecord_Type := tkBegin_Memorisation_Line;
      mlEOR         := tkEnd_Memorisation_Line;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Memorisation_Line_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Memorisation_Line_Rec_Dynamic_Fields ( Var O : TMemorisation_Line_Rec );

Begin
   If IsAMemorisation_Line_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      mlGL_Narration := '' ;
      mlSF_Trans_Code := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
