UNIT BKslIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Suggested_Account_Link       = 171 ;
   tkEnd_Suggested_Account_Link         = 172 ;

FUNCTION  IsASuggested_Account_Link_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Suggested_Account_Link_Rec ( Var O : TSuggested_Account_Link_Rec ; Var F : TIOStream );
PROCEDURE Read_Suggested_Account_Link_Rec ( Var O : TSuggested_Account_Link_Rec ; Var F : TIOStream );
FUNCTION  New_Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec ;
PROCEDURE Free_Suggested_Account_Link_Rec_Dynamic_Fields ( Var O : TSuggested_Account_Link_Rec );
FUNCTION Suggested_Account_Link_Rec_Delta(P1, P2, P3: pSuggested_Account_Link_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Suggested_Account_Link_Rec(P1, P2: pSuggested_Account_Link_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSLIO';
   SBoundsError        = 'BKSLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSLIO Error: Pointer is NIL in IsASuggested_Account_Link_Rec';
   SInvalidType        = 'BKSLIO Error: Type is invalid in IsASuggested_Account_Link_Rec';
   SInvalidEOR         = 'BKSLIO Error: EOR is missing in IsASuggested_Account_Link_Rec';
   SUnknownToken       = 'BKSLIO Error: Unknown token %d in Read_Suggested_Account_Link_Rec';
   SInsufficientMemory = 'BKSLIO Error: Out of memory in New_Suggested_Account_Link_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkslSuggestedId                      = 173 ;
   tkslAccountId                        = 174 ;
   tkslCount                            = 175 ;
   tkslIsUncoded                        = 176 ;
   tkslIsDissected                      = 177 ;
   tkslManual_Count                     = 178 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASuggested_Account_Link_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSuggested_Account_Link_Rec ( P )^ do Begin
      If slRecord_Type <> tkBegin_Suggested_Account_Link then
         Raise ECorruptData.Create( SInvalidType );
      If slEOR <> tkEnd_Suggested_Account_Link then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Suggested_Account_Link_Rec ( Var O : TSuggested_Account_Link_Rec ; Var F : TIOStream );

Begin
   If IsASuggested_Account_Link_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Suggested_Account_Link );
      F.WriteIntegerValue( tkslSuggestedId , slSuggestedId );
      F.WriteIntegerValue( tkslAccountId , slAccountId );
      F.WriteIntegerValue( tkslCount , slCount );
      F.WriteBooleanValue( tkslIsUncoded , slIsUncoded );
      F.WriteBooleanValue( tkslIsDissected , slIsDissected );
      F.WriteIntegerValue( tkslManual_Count , slManual_Count );
      F.WriteToken( tkEnd_Suggested_Account_Link );
   end;
end; { of Write_Suggested_Account_Link_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Suggested_Account_Link_Rec ( Var O : TSuggested_Account_Link_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Suggested_Account_Link_Rec_Size, 0 );
   O.slRecord_Type := tkBegin_Suggested_Account_Link;
   O.slEOR := tkEnd_Suggested_Account_Link;
   Token := tkBegin_Suggested_Account_Link;

   While Token <> tkEnd_Suggested_Account_Link do With O do
   Begin
      Case Token of
         tkBegin_Suggested_Account_Link :; { Do Nothing }
         tkEnd_Suggested_Account_Link :; { Do Nothing }
         tkslSuggestedId                      : slSuggestedId := F.ReadIntegerValue;
         tkslAccountId                        : slAccountId := F.ReadIntegerValue;
         tkslCount                            : slCount := F.ReadIntegerValue;
         tkslIsUncoded                        : slIsUncoded := F.ReadBooleanValue;
         tkslIsDissected                      : slIsDissected := F.ReadBooleanValue;
         tkslManual_Count                     : slManual_Count := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Suggested_Account_Link_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec ;

Var
   P : pSuggested_Account_Link_Rec;
Begin
   SafeGetMem( P, Suggested_Account_Link_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Suggested_Account_Link_Rec_Size, 0 );
      slRecord_Type := tkBegin_Suggested_Account_Link;
      slEOR         := tkEnd_Suggested_Account_Link;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Suggested_Account_Link_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Suggested_Account_Link_Rec_Dynamic_Fields ( Var O : TSuggested_Account_Link_Rec );

Begin
   If IsASuggested_Account_Link_Rec ( @O ) then With O do
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
  for i := tkslSuggestedId to tkslManual_Count do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Suggested_Account_Link_Rec_Delta(P1, P2, P3: pSuggested_Account_Link_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Suggested_Account_Link_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.slSuggestedId <> P2.slSuggestedId) then begin
    P3.slSuggestedId := P1.slSuggestedId;
    ChangedFields[i] := tkslSuggestedId;
    Inc(i);
  end;
  if (P1.slAccountId <> P2.slAccountId) then begin
    P3.slAccountId := P1.slAccountId;
    ChangedFields[i] := tkslAccountId;
    Inc(i);
  end;
  if (P1.slCount <> P2.slCount) then begin
    P3.slCount := P1.slCount;
    ChangedFields[i] := tkslCount;
    Inc(i);
  end;
  if (P1.slIsUncoded <> P2.slIsUncoded) then begin
    P3.slIsUncoded := P1.slIsUncoded;
    ChangedFields[i] := tkslIsUncoded;
    Inc(i);
  end;
  if (P1.slIsDissected <> P2.slIsDissected) then begin
    P3.slIsDissected := P1.slIsDissected;
    ChangedFields[i] := tkslIsDissected;
    Inc(i);
  end;
  if (P1.slManual_Count <> P2.slManual_Count) then begin
    P3.slManual_Count := P1.slManual_Count;
    ChangedFields[i] := tkslManual_Count;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Suggested_Account_Link_Rec(P1, P2: pSuggested_Account_Link_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Suggested_Account_Link_Rec(P1^, S);
    S.Position := 0;
    Read_Suggested_Account_Link_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
