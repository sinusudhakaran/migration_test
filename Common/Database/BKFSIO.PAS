UNIT BKfsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Fuel_Sheet                   = 243 ;
   tkEnd_Fuel_Sheet                     = 244 ;

FUNCTION  IsAFuel_Sheet_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec ; Var F : TIOStream );
PROCEDURE Read_Fuel_Sheet_Rec ( Var O : TFuel_Sheet_Rec ; Var F : TIOStream );
FUNCTION  New_Fuel_Sheet_Rec : pFuel_Sheet_Rec ;
PROCEDURE Free_Fuel_Sheet_Rec_Dynamic_Fields ( Var O : TFuel_Sheet_Rec );
FUNCTION Fuel_Sheet_Rec_Delta(P1, P2, P3: pFuel_Sheet_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Fuel_Sheet_Rec(P1, P2: pFuel_Sheet_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tkfsAccount to tkfsCredit_Rate do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Fuel_Sheet_Rec_Delta(P1, P2, P3: pFuel_Sheet_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Fuel_Sheet_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.fsAccount <> P2.fsAccount) then begin
    P3.fsAccount := P1.fsAccount;
    ChangedFields[i] := tkfsAccount;
    Inc(i);
  end;
  if (P1.fsFuel_Type <> P2.fsFuel_Type) then begin
    P3.fsFuel_Type := P1.fsFuel_Type;
    ChangedFields[i] := tkfsFuel_Type;
    Inc(i);
  end;
  if (P1.fsFuel_Litres <> P2.fsFuel_Litres) then begin
    P3.fsFuel_Litres := P1.fsFuel_Litres;
    ChangedFields[i] := tkfsFuel_Litres;
    Inc(i);
  end;
  if (P1.fsFuel_Use <> P2.fsFuel_Use) then begin
    P3.fsFuel_Use := P1.fsFuel_Use;
    ChangedFields[i] := tkfsFuel_Use;
    Inc(i);
  end;
  if (P1.fsPercentage <> P2.fsPercentage) then begin
    P3.fsPercentage := P1.fsPercentage;
    ChangedFields[i] := tkfsPercentage;
    Inc(i);
  end;
  if (P1.fsFuel_Eligible <> P2.fsFuel_Eligible) then begin
    P3.fsFuel_Eligible := P1.fsFuel_Eligible;
    ChangedFields[i] := tkfsFuel_Eligible;
    Inc(i);
  end;
  if (P1.fsCredit_Rate <> P2.fsCredit_Rate) then begin
    P3.fsCredit_Rate := P1.fsCredit_Rate;
    ChangedFields[i] := tkfsCredit_Rate;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Fuel_Sheet_Rec(P1, P2: pFuel_Sheet_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Fuel_Sheet_Rec(P1^, S);
    S.Position := 0;
    Read_Fuel_Sheet_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
