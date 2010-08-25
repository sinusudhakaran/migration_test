UNIT BKfsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Fuel_Sheet                   = 243 ;
   tkEnd_Fuel_Sheet                     = 244 ;

FUNCTION  IsAFuel_Sheet_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec ; Var F : TIOStream );
PROCEDURE Read_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec ; Var F : TIOStream );
FUNCTION  New_Fuel_Sheet_Rec : pFuel_Sheet_Rec ;
PROCEDURE Free_Fuel_Sheet_Rec_Dynamic_Fields ( Var O : TFuel_Sheet_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKFSIO';
   SBoundsError        = 'BKFSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKFSIO Error: Pointer is NIL in IsAFuel_Sheet_Rec';
   SInvalidType        = 'BKFSIO Error: Type is invalid in IsAFuel_Sheet_Rec';
   SInvalidEOR         = 'BKFSIO Error: EOR is missing in IsAFuel_Sheet_Rec';
   SUnknownToken       = 'BKFSIO Error: Unknown token %d in Read_Fuel_Sheet_Rec';
   SInsufficientMemory = 'BKFSIO Error: Out of memory in New_Fuel_Sheet_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkfsAccount                          = 245 ;
   tkfsFuel_Type                        = 246 ;
   tkfsFuel_Litres                      = 247 ;
   tkfsFuel_Use                         = 248 ;
   tkfsPercentage                       = 249 ;
   tkfsFuel_Eligible                    = 250 ;
   tkfsCredit_Rate                      = 251 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAFuel_Sheet_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PFuel_Sheet_Rec ( P )^ do Begin
      If fsRecord_Type <> tkBegin_Fuel_Sheet then
         Raise ECorruptData.Create( SInvalidType );
      If fsEOR <> tkEnd_Fuel_Sheet then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec ; Var F : TIOStream );

Begin
   If IsAFuel_Sheet_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Fuel_Sheet );
      F.WriteStringValue( tkfsAccount , fsAccount );
      F.WriteAnsiStringValue( tkfsFuel_Type , fsFuel_Type );
      F.WriteMoneyValue( tkfsFuel_Litres , fsFuel_Litres );
      F.WriteAnsiStringValue( tkfsFuel_Use , fsFuel_Use );
      F.WriteMoneyValue( tkfsPercentage , fsPercentage );
      F.WriteMoneyValue( tkfsFuel_Eligible , fsFuel_Eligible );
      F.WriteMoneyValue( tkfsCredit_Rate , fsCredit_Rate );
      F.WriteToken( tkEnd_Fuel_Sheet );
   end;
end; { of Write_Fuel_Sheet_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Fuel_Sheet_Rec_Size, 0 );
   O.fsRecord_Type := tkBegin_Fuel_Sheet;
   O.fsEOR := tkEnd_Fuel_Sheet;
   Token := tkBegin_Fuel_Sheet;

   While Token <> tkEnd_Fuel_Sheet do With O do
   Begin
      Case Token of
         tkBegin_Fuel_Sheet :; { Do Nothing }
         tkEnd_Fuel_Sheet :; { Do Nothing }
         tkfsAccount                          : fsAccount := F.ReadStringValue;
         tkfsFuel_Type                        : fsFuel_Type := F.ReadAnsiStringValue;
         tkfsFuel_Litres                      : fsFuel_Litres := F.ReadMoneyValue;
         tkfsFuel_Use                         : fsFuel_Use := F.ReadAnsiStringValue;
         tkfsPercentage                       : fsPercentage := F.ReadMoneyValue;
         tkfsFuel_Eligible                    : fsFuel_Eligible := F.ReadMoneyValue;
         tkfsCredit_Rate                      : fsCredit_Rate := F.ReadMoneyValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Fuel_Sheet_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Fuel_Sheet_Rec : pFuel_Sheet_Rec ;

Var
   P : pFuel_Sheet_Rec;
Begin
   SafeGetMem( P, Fuel_Sheet_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Fuel_Sheet_Rec_Size, 0 );
      fsRecord_Type := tkBegin_Fuel_Sheet;
      fsEOR         := tkEnd_Fuel_Sheet;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Fuel_Sheet_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Fuel_Sheet_Rec_Dynamic_Fields ( Var O : TFuel_Sheet_Rec );

Begin
   If IsAFuel_Sheet_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      fsFuel_Type := '' ;
      fsFuel_Use := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
