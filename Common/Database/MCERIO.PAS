UNIT MCerIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES MCDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Exchange_Rate                = 15 ;
   tkEnd_Exchange_Rate                  = 16 ;

FUNCTION  IsAExchange_Rate_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Exchange_Rate_Rec ( Var O : TExchange_Rate_Rec ; Var F : TIOStream );
PROCEDURE Read_Exchange_Rate_Rec ( Var O : TExchange_Rate_Rec ; Var F : TIOStream );
FUNCTION  New_Exchange_Rate_Rec : pExchange_Rate_Rec ;
PROCEDURE Free_Exchange_Rate_Rec_Dynamic_Fields ( Var O : TExchange_Rate_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'MCERIO';
   SBoundsError        = 'MCERIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'MCERIO Error: Pointer is NIL in IsAExchange_Rate_Rec';
   SInvalidType        = 'MCERIO Error: Type is invalid in IsAExchange_Rate_Rec';
   SInvalidEOR         = 'MCERIO Error: EOR is missing in IsAExchange_Rate_Rec';
   SUnknownToken       = 'MCERIO Error: Unknown token %d in Read_Exchange_Rate_Rec';
   SInsufficientMemory = 'MCERIO Error: Out of memory in New_Exchange_Rate_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkerApplies_Until                    = 17 ;
   tkerRate                             = 18 ;
   tkerLocked                           = 19 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAExchange_Rate_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PExchange_Rate_Rec ( P )^ do Begin
      If erRecord_Type <> tkBegin_Exchange_Rate then
         Raise ECorruptData.Create( SInvalidType );
      If erEOR <> tkEnd_Exchange_Rate then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Exchange_Rate_Rec ( Var O : TExchange_Rate_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAExchange_Rate_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Exchange_Rate );
      F.WriteDateValue( tkerApplies_Until , erApplies_Until );
      For i := 1 to 99 do F.WriteBDoubleValue( tkerRate , i, erRate[ i ] );
      F.WriteBooleanValue( tkerLocked , erLocked );
      F.WriteToken( tkEnd_Exchange_Rate );
   end;
end; { of Write_Exchange_Rate_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Exchange_Rate_Rec ( Var O : TExchange_Rate_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   R     : Double;

Begin
   FillChar( O, Exchange_Rate_Rec_Size, 0 );
   O.erRecord_Type := tkBegin_Exchange_Rate;
   O.erEOR := tkEnd_Exchange_Rate;
   Token := tkBegin_Exchange_Rate;

   While Token <> tkEnd_Exchange_Rate do With O do
   Begin
      Case Token of
         tkBegin_Exchange_Rate :; { Do Nothing }
         tkEnd_Exchange_Rate :; { Do Nothing }
         tkerApplies_Until                    : erApplies_Until := F.ReadDateValue;
         tkerRate                             : 
            Begin
               R := F.ReadBDoubleValue( I );
               CheckBounds( I, 1, 99, 'erRate' );
               erRate[ I ] := R;
            end;
         tkerLocked                           : erLocked := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Exchange_Rate_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Exchange_Rate_Rec : pExchange_Rate_Rec ;

Var
   P : pExchange_Rate_Rec;
Begin
   SafeGetMem( P, Exchange_Rate_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Exchange_Rate_Rec_Size, 0 );
      erRecord_Type := tkBegin_Exchange_Rate;
      erEOR         := tkEnd_Exchange_Rate;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Exchange_Rate_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Exchange_Rate_Rec_Dynamic_Fields ( Var O : TExchange_Rate_Rec );

Begin
   If IsAExchange_Rate_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
