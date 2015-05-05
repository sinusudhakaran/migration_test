UNIT BKspIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Suggested_Phrase             = 173 ;
   tkEnd_Suggested_Phrase               = 174 ;

FUNCTION  IsASuggested_Phrase_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Suggested_Phrase_Rec ( Var O : TSuggested_Phrase_Rec ; Var F : TIOStream );
PROCEDURE Read_Suggested_Phrase_Rec ( Var O : TSuggested_Phrase_Rec ; Var F : TIOStream );
FUNCTION  New_Suggested_Phrase_Rec : pSuggested_Phrase_Rec ;
PROCEDURE Free_Suggested_Phrase_Rec_Dynamic_Fields ( Var O : TSuggested_Phrase_Rec );
FUNCTION Suggested_Phrase_Rec_Delta(P1, P2, P3: pSuggested_Phrase_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Suggested_Phrase_Rec(P1, P2: pSuggested_Phrase_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSPIO';
   SBoundsError        = 'BKSPIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSPIO Error: Pointer is NIL in IsASuggested_Phrase_Rec';
   SInvalidType        = 'BKSPIO Error: Type is invalid in IsASuggested_Phrase_Rec';
   SInvalidEOR         = 'BKSPIO Error: EOR is missing in IsASuggested_Phrase_Rec';
   SUnknownToken       = 'BKSPIO Error: Unknown token %d in Read_Suggested_Phrase_Rec';
   SInsufficientMemory = 'BKSPIO Error: Out of memory in New_Suggested_Phrase_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkspId                               = 175 ;
   tkspPhrase                           = 176 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASuggested_Phrase_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSuggested_Phrase_Rec ( P )^ do Begin
      If spRecord_Type <> tkBegin_Suggested_Phrase then
         Raise ECorruptData.Create( SInvalidType );
      If spEOR <> tkEnd_Suggested_Phrase then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Suggested_Phrase_Rec ( Var O : TSuggested_Phrase_Rec ; Var F : TIOStream );

Begin
   If IsASuggested_Phrase_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Suggested_Phrase );
      F.WriteIntegerValue( tkspId , spId );
      F.WriteStringValue( tkspPhrase , spPhrase );
      F.WriteToken( tkEnd_Suggested_Phrase );
   end;
end; { of Write_Suggested_Phrase_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Suggested_Phrase_Rec ( Var O : TSuggested_Phrase_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Suggested_Phrase_Rec_Size, 0 );
   O.spRecord_Type := tkBegin_Suggested_Phrase;
   O.spEOR := tkEnd_Suggested_Phrase;
   Token := tkBegin_Suggested_Phrase;

   While Token <> tkEnd_Suggested_Phrase do With O do
   Begin
      Case Token of
         tkBegin_Suggested_Phrase :; { Do Nothing }
         tkEnd_Suggested_Phrase :; { Do Nothing }
         tkspId                               : spId := F.ReadIntegerValue;
         tkspPhrase                           : spPhrase := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Suggested_Phrase_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Suggested_Phrase_Rec : pSuggested_Phrase_Rec ;

Var
   P : pSuggested_Phrase_Rec;
Begin
   SafeGetMem( P, Suggested_Phrase_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Suggested_Phrase_Rec_Size, 0 );
      spRecord_Type := tkBegin_Suggested_Phrase;
      spEOR         := tkEnd_Suggested_Phrase;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Suggested_Phrase_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Suggested_Phrase_Rec_Dynamic_Fields ( Var O : TSuggested_Phrase_Rec );

Begin
   If IsASuggested_Phrase_Rec ( @O ) then With O do
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
  for i := tkspId to tkspPhrase do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Suggested_Phrase_Rec_Delta(P1, P2, P3: pSuggested_Phrase_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Suggested_Phrase_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.spId <> P2.spId) then begin
    P3.spId := P1.spId;
    ChangedFields[i] := tkspId;
    Inc(i);
  end;
  if (P1.spPhrase <> P2.spPhrase) then begin
    P3.spPhrase := P1.spPhrase;
    ChangedFields[i] := tkspPhrase;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Suggested_Phrase_Rec(P1, P2: pSuggested_Phrase_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Suggested_Phrase_Rec(P1^, S);
    S.Position := 0;
    Read_Suggested_Phrase_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
