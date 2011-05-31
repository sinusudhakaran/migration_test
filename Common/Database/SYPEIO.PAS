UNIT SYpeIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Provisional_Entries_Log      = 137 ;
   tkEnd_Provisional_Entries_Log        = 138 ;

FUNCTION  IsAProvisional_Entries_Log_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Provisional_Entries_Log_Rec ( Var O : TProvisional_Entries_Log_Rec ; Var F : TIOStream );
PROCEDURE Read_Provisional_Entries_Log_Rec ( Var O : TProvisional_Entries_Log_Rec ; Var F : TIOStream );
FUNCTION  New_Provisional_Entries_Log_Rec : pProvisional_Entries_Log_Rec ;
PROCEDURE Free_Provisional_Entries_Log_Rec_Dynamic_Fields ( Var O : TProvisional_Entries_Log_Rec );
FUNCTION Provisional_Entries_Log_Rec_Delta(P1, P2, P3: pProvisional_Entries_Log_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Provisional_Entries_Log_Rec(P1, P2: pProvisional_Entries_Log_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYPEIO';
   SBoundsError        = 'SYPEIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYPEIO Error: Pointer is NIL in IsAProvisional_Entries_Log_Rec';
   SInvalidType        = 'SYPEIO Error: Type is invalid in IsAProvisional_Entries_Log_Rec';
   SInvalidEOR         = 'SYPEIO Error: EOR is missing in IsAProvisional_Entries_Log_Rec';
   SUnknownToken       = 'SYPEIO Error: Unknown token %d in Read_Provisional_Entries_Log_Rec';
   SInsufficientMemory = 'SYPEIO Error: Out of memory in New_Provisional_Entries_Log_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpeDate_Time                        = 139 ;
   tkpeUser_Code                        = 140 ;
   tkpeFirst_LRN                        = 141 ;
   tkpeLast_LRN                         = 142 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAProvisional_Entries_Log_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PProvisional_Entries_Log_Rec ( P )^ do Begin
      If peRecord_Type <> tkBegin_Provisional_Entries_Log then
         Raise ECorruptData.Create( SInvalidType );
      If peEOR <> tkEnd_Provisional_Entries_Log then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Provisional_Entries_Log_Rec ( Var O : TProvisional_Entries_Log_Rec ; Var F : TIOStream );

Begin
   If IsAProvisional_Entries_Log_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Provisional_Entries_Log );
      F.WriteDateTimeValue( tkpeDate_Time , peDate_Time );
      F.WriteStringValue( tkpeUser_Code , peUser_Code );
      F.WriteIntegerValue( tkpeFirst_LRN , peFirst_LRN );
      F.WriteIntegerValue( tkpeLast_LRN , peLast_LRN );
      F.WriteToken( tkEnd_Provisional_Entries_Log );
   end;
end; { of Write_Provisional_Entries_Log_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Provisional_Entries_Log_Rec ( Var O : TProvisional_Entries_Log_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Provisional_Entries_Log_Rec_Size, 0 );
   O.peRecord_Type := tkBegin_Provisional_Entries_Log;
   O.peEOR := tkEnd_Provisional_Entries_Log;
   Token := tkBegin_Provisional_Entries_Log;

   While Token <> tkEnd_Provisional_Entries_Log do With O do
   Begin
      Case Token of
         tkBegin_Provisional_Entries_Log :; { Do Nothing }
         tkEnd_Provisional_Entries_Log :; { Do Nothing }
         tkpeDate_Time                        : peDate_Time := F.ReadDateTimeValue;
         tkpeUser_Code                        : peUser_Code := F.ReadStringValue;
         tkpeFirst_LRN                        : peFirst_LRN := F.ReadIntegerValue;
         tkpeLast_LRN                         : peLast_LRN := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Provisional_Entries_Log_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Provisional_Entries_Log_Rec : pProvisional_Entries_Log_Rec ;

Var
   P : pProvisional_Entries_Log_Rec;
Begin
   SafeGetMem( P, Provisional_Entries_Log_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Provisional_Entries_Log_Rec_Size, 0 );
      peRecord_Type := tkBegin_Provisional_Entries_Log;
      peEOR         := tkEnd_Provisional_Entries_Log;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Provisional_Entries_Log_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Provisional_Entries_Log_Rec_Dynamic_Fields ( Var O : TProvisional_Entries_Log_Rec );

Begin
   If IsAProvisional_Entries_Log_Rec ( @O ) then With O do
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
  for i := tkpeDate_Time to tkpeLast_LRN do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Provisional_Entries_Log_Rec_Delta(P1, P2, P3: pProvisional_Entries_Log_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Provisional_Entries_Log_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.peDate_Time <> P2.peDate_Time) then begin
    P3.peDate_Time := P1.peDate_Time;
    ChangedFields[i] := tkpeDate_Time;
    Inc(i);
  end;
  if (P1.peUser_Code <> P2.peUser_Code) then begin
    P3.peUser_Code := P1.peUser_Code;
    ChangedFields[i] := tkpeUser_Code;
    Inc(i);
  end;
  if (P1.peFirst_LRN <> P2.peFirst_LRN) then begin
    P3.peFirst_LRN := P1.peFirst_LRN;
    ChangedFields[i] := tkpeFirst_LRN;
    Inc(i);
  end;
  if (P1.peLast_LRN <> P2.peLast_LRN) then begin
    P3.peLast_LRN := P1.peLast_LRN;
    ChangedFields[i] := tkpeLast_LRN;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Provisional_Entries_Log_Rec(P1, P2: pProvisional_Entries_Log_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Provisional_Entries_Log_Rec(P1^, S);
    S.Position := 0;
    Read_Provisional_Entries_Log_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
