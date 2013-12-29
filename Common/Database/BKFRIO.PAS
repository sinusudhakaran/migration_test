UNIT BKfrIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Finalized_Exchange_Rate      = 214 ;
   tkEnd_Finalized_Exchange_Rate        = 215 ;

FUNCTION  IsAFinalized_Exchange_Rate_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Finalized_Exchange_Rate_Rec ( Var O : TFinalized_Exchange_Rate_Rec ; Var F : TIOStream );
PROCEDURE Read_Finalized_Exchange_Rate_Rec ( Var O : TFinalized_Exchange_Rate_Rec ; Var F : TIOStream );
FUNCTION  New_Finalized_Exchange_Rate_Rec : pFinalized_Exchange_Rate_Rec ;
PROCEDURE Free_Finalized_Exchange_Rate_Rec_Dynamic_Fields ( Var O : TFinalized_Exchange_Rate_Rec );
FUNCTION Finalized_Exchange_Rate_Rec_Delta(P1, P2, P3: pFinalized_Exchange_Rate_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Finalized_Exchange_Rate_Rec(P1, P2: pFinalized_Exchange_Rate_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKFRIO';
   SBoundsError        = 'BKFRIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKFRIO Error: Pointer is NIL in IsAFinalized_Exchange_Rate_Rec';
   SInvalidType        = 'BKFRIO Error: Type is invalid in IsAFinalized_Exchange_Rate_Rec';
   SInvalidEOR         = 'BKFRIO Error: EOR is missing in IsAFinalized_Exchange_Rate_Rec';
   SUnknownToken       = 'BKFRIO Error: Unknown token %d in Read_Finalized_Exchange_Rate_Rec';
   SInsufficientMemory = 'BKFRIO Error: Out of memory in New_Finalized_Exchange_Rate_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkfrDate                             = 216 ;
   tkfrRate                             = 217 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAFinalized_Exchange_Rate_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PFinalized_Exchange_Rate_Rec ( P )^ do Begin
      If frRecord_Type <> tkBegin_Finalized_Exchange_Rate then
         Raise ECorruptData.Create( SInvalidType );
      If frEOR <> tkEnd_Finalized_Exchange_Rate then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Finalized_Exchange_Rate_Rec ( Var O : TFinalized_Exchange_Rate_Rec ; Var F : TIOStream );

Begin
   If IsAFinalized_Exchange_Rate_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Finalized_Exchange_Rate );
      F.WriteDateValue( tkfrDate , frDate );
      F.WriteDoubleValue( tkfrRate, frRate );
      F.WriteToken( tkEnd_Finalized_Exchange_Rate );
   end;
end; { of Write_Finalized_Exchange_Rate_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Finalized_Exchange_Rate_Rec ( Var O : TFinalized_Exchange_Rate_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Finalized_Exchange_Rate_Rec_Size, 0 );
   O.frRecord_Type := tkBegin_Finalized_Exchange_Rate;
   O.frEOR := tkEnd_Finalized_Exchange_Rate;
   Token := tkBegin_Finalized_Exchange_Rate;

   While Token <> tkEnd_Finalized_Exchange_Rate do With O do
   Begin
      Case Token of
         tkBegin_Finalized_Exchange_Rate :; { Do Nothing }
         tkEnd_Finalized_Exchange_Rate :; { Do Nothing }
         tkfrDate                             : frDate := F.ReadDateValue;
         tkfrRate                             : frRate := F.ReadDoubleValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Finalized_Exchange_Rate_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Finalized_Exchange_Rate_Rec : pFinalized_Exchange_Rate_Rec ;

Var
   P : pFinalized_Exchange_Rate_Rec;
Begin
   SafeGetMem( P, Finalized_Exchange_Rate_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Finalized_Exchange_Rate_Rec_Size, 0 );
      frRecord_Type := tkBegin_Finalized_Exchange_Rate;
      frEOR         := tkEnd_Finalized_Exchange_Rate;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Finalized_Exchange_Rate_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Finalized_Exchange_Rate_Rec_Dynamic_Fields ( Var O : TFinalized_Exchange_Rate_Rec );

Begin
   If IsAFinalized_Exchange_Rate_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
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
  for i := tkfrDate to tkfrRate do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Finalized_Exchange_Rate_Rec_Delta(P1, P2, P3: pFinalized_Exchange_Rate_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Finalized_Exchange_Rate_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.frDate <> P2.frDate) then begin
    P3.frDate := P1.frDate;
    ChangedFields[i] := tkfrDate;
    Inc(i);
  end;
  if (P1.frRate <> P2.frRate) then begin
    P3.frRate := P1.frRate;
    ChangedFields[i] := tkfrRate;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Finalized_Exchange_Rate_Rec(P1, P2: pFinalized_Exchange_Rate_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Finalized_Exchange_Rate_Rec(P1^, S);
    S.Position := 0;
    Read_Finalized_Exchange_Rate_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
