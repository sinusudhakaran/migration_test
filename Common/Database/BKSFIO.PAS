UNIT BKsfIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Super_Fund_Fields            = 185 ;
   tkEnd_Super_Fund_Fields              = 186 ;

FUNCTION  IsASuper_Fund_Fields_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Super_Fund_Fields_Rec ( Var O : TSuper_Fund_Fields_Rec ; Var F : TIOStream );
PROCEDURE Read_Super_Fund_Fields_Rec ( Var O : TSuper_Fund_Fields_Rec ; Var F : TIOStream );
FUNCTION  New_Super_Fund_Fields_Rec : pSuper_Fund_Fields_Rec ;
PROCEDURE Free_Super_Fund_Fields_Rec_Dynamic_Fields ( Var O : TSuper_Fund_Fields_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSFIO';
   SBoundsError        = 'BKSFIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSFIO Error: Pointer is NIL in IsASuper_Fund_Fields_Rec';
   SInvalidType        = 'BKSFIO Error: Type is invalid in IsASuper_Fund_Fields_Rec';
   SInvalidEOR         = 'BKSFIO Error: EOR is missing in IsASuper_Fund_Fields_Rec';
   SUnknownToken       = 'BKSFIO Error: Unknown token %d in Read_Super_Fund_Fields_Rec';
   SInsufficientMemory = 'BKSFIO Error: Out of memory in New_Super_Fund_Fields_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksfImputed_Credit                   = 187 ;
   tksfTax_Free_Dist                    = 188 ;
   tksfTax_Exempt_Dist                  = 189 ;
   tksfTax_Deferred_Dist                = 190 ;
   tksfTFN_Credits                      = 191 ;
   tksfForeign_Income                   = 192 ;
   tksfCapital_Gains                    = 193 ;
   tksfDiscounted_Capital_Gains         = 194 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASuper_Fund_Fields_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSuper_Fund_Fields_Rec ( P )^ do Begin
      If sfRecord_Type <> tkBegin_Super_Fund_Fields then
         Raise ECorruptData.Create( SInvalidType );
      If sfEOR <> tkEnd_Super_Fund_Fields then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Super_Fund_Fields_Rec ( Var O : TSuper_Fund_Fields_Rec ; Var F : TIOStream );

Begin
   If IsASuper_Fund_Fields_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Super_Fund_Fields );
      F.WriteMoneyValue( tksfImputed_Credit , sfImputed_Credit );
      F.WriteMoneyValue( tksfTax_Free_Dist , sfTax_Free_Dist );
      F.WriteMoneyValue( tksfTax_Exempt_Dist , sfTax_Exempt_Dist );
      F.WriteMoneyValue( tksfTax_Deferred_Dist , sfTax_Deferred_Dist );
      F.WriteMoneyValue( tksfTFN_Credits , sfTFN_Credits );
      F.WriteMoneyValue( tksfForeign_Income , sfForeign_Income );
      F.WriteMoneyValue( tksfCapital_Gains , sfCapital_Gains );
      F.WriteMoneyValue( tksfDiscounted_Capital_Gains , sfDiscounted_Capital_Gains );
      F.WriteToken( tkEnd_Super_Fund_Fields );
   end;
end; { of Write_Super_Fund_Fields_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Super_Fund_Fields_Rec ( Var O : TSuper_Fund_Fields_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Super_Fund_Fields_Rec_Size, 0 );
   O.sfRecord_Type := tkBegin_Super_Fund_Fields;
   O.sfEOR := tkEnd_Super_Fund_Fields;
   Token := tkBegin_Super_Fund_Fields;

   While Token <> tkEnd_Super_Fund_Fields do With O do
   Begin
      Case Token of
         tkBegin_Super_Fund_Fields :; { Do Nothing }
         tkEnd_Super_Fund_Fields :; { Do Nothing }
         tksfImputed_Credit                   : sfImputed_Credit := F.ReadMoneyValue;
         tksfTax_Free_Dist                    : sfTax_Free_Dist := F.ReadMoneyValue;
         tksfTax_Exempt_Dist                  : sfTax_Exempt_Dist := F.ReadMoneyValue;
         tksfTax_Deferred_Dist                : sfTax_Deferred_Dist := F.ReadMoneyValue;
         tksfTFN_Credits                      : sfTFN_Credits := F.ReadMoneyValue;
         tksfForeign_Income                   : sfForeign_Income := F.ReadMoneyValue;
         tksfCapital_Gains                    : sfCapital_Gains := F.ReadMoneyValue;
         tksfDiscounted_Capital_Gains         : sfDiscounted_Capital_Gains := F.ReadMoneyValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Super_Fund_Fields_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Super_Fund_Fields_Rec : pSuper_Fund_Fields_Rec ;

Var
   P : pSuper_Fund_Fields_Rec;
Begin
   SafeGetMem( P, Super_Fund_Fields_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Super_Fund_Fields_Rec_Size, 0 );
      sfRecord_Type := tkBegin_Super_Fund_Fields;
      sfEOR         := tkEnd_Super_Fund_Fields;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Super_Fund_Fields_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Super_Fund_Fields_Rec_Dynamic_Fields ( Var O : TSuper_Fund_Fields_Rec );

Begin
   If IsASuper_Fund_Fields_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
