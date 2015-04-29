UNIT BKsmIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Suggested_Mem                = 169 ;
   tkEnd_Suggested_Mem                  = 170 ;

FUNCTION  IsASuggested_Mem_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Suggested_Mem_Rec ( Var O : TSuggested_Mem_Rec ; Var F : TIOStream );
PROCEDURE Read_Suggested_Mem_Rec ( Var O : TSuggested_Mem_Rec ; Var F : TIOStream );
FUNCTION  New_Suggested_Mem_Rec : pSuggested_Mem_Rec ;
PROCEDURE Free_Suggested_Mem_Rec_Dynamic_Fields ( Var O : TSuggested_Mem_Rec );
FUNCTION Suggested_Mem_Rec_Delta(P1, P2, P3: pSuggested_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Suggested_Mem_Rec(P1, P2: pSuggested_Mem_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSMIO';
   SBoundsError        = 'BKSMIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSMIO Error: Pointer is NIL in IsASuggested_Mem_Rec';
   SInvalidType        = 'BKSMIO Error: Type is invalid in IsASuggested_Mem_Rec';
   SInvalidEOR         = 'BKSMIO Error: EOR is missing in IsASuggested_Mem_Rec';
   SUnknownToken       = 'BKSMIO Error: Unknown token %d in Read_Suggested_Mem_Rec';
   SInsufficientMemory = 'BKSMIO Error: Out of memory in New_Suggested_Mem_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksmId                               = 171 ;
   tksmMatched_Phrase                   = 172 ;
   tksmTotal_Count                      = 173 ;
   tksmManual_Count                     = 174 ;
   tksmUncoded_Count                    = 175 ;
   tksmUpdate_Date                      = 176 ;
   tksmStart_Data                       = 177 ;
   tksmEnd_Data                         = 178 ;
   tksmHas_Changed                      = 179 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASuggested_Mem_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSuggested_Mem_Rec ( P )^ do Begin
      If smRecord_Type <> tkBegin_Suggested_Mem then
         Raise ECorruptData.Create( SInvalidType );
      If smEOR <> tkEnd_Suggested_Mem then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Suggested_Mem_Rec ( Var O : TSuggested_Mem_Rec ; Var F : TIOStream );

Begin
   If IsASuggested_Mem_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Suggested_Mem );
      F.WriteIntegerValue( tksmId , smId );
      F.WriteStringValue( tksmMatched_Phrase , smMatched_Phrase );
      F.WriteIntegerValue( tksmTotal_Count , smTotal_Count );
      F.WriteIntegerValue( tksmManual_Count , smManual_Count );
      F.WriteIntegerValue( tksmUncoded_Count , smUncoded_Count );
      F.WriteDateValue( tksmUpdate_Date , smUpdate_Date );
      F.WriteBooleanValue( tksmStart_Data , smStart_Data );
      F.WriteBooleanValue( tksmEnd_Data , smEnd_Data );
      F.WriteBooleanValue( tksmHas_Changed , smHas_Changed );
      F.WriteToken( tkEnd_Suggested_Mem );
   end;
end; { of Write_Suggested_Mem_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Suggested_Mem_Rec ( Var O : TSuggested_Mem_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Suggested_Mem_Rec_Size, 0 );
   O.smRecord_Type := tkBegin_Suggested_Mem;
   O.smEOR := tkEnd_Suggested_Mem;
   Token := tkBegin_Suggested_Mem;

   While Token <> tkEnd_Suggested_Mem do With O do
   Begin
      Case Token of
         tkBegin_Suggested_Mem :; { Do Nothing }
         tkEnd_Suggested_Mem :; { Do Nothing }
         tksmId                               : smId := F.ReadIntegerValue;
         tksmMatched_Phrase                   : smMatched_Phrase := F.ReadStringValue;
         tksmTotal_Count                      : smTotal_Count := F.ReadIntegerValue;
         tksmManual_Count                     : smManual_Count := F.ReadIntegerValue;
         tksmUncoded_Count                    : smUncoded_Count := F.ReadIntegerValue;
         tksmUpdate_Date                      : smUpdate_Date := F.ReadDateValue;
         tksmStart_Data                       : smStart_Data := F.ReadBooleanValue;
         tksmEnd_Data                         : smEnd_Data := F.ReadBooleanValue;
         tksmHas_Changed                      : smHas_Changed := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Suggested_Mem_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Suggested_Mem_Rec : pSuggested_Mem_Rec ;

Var
   P : pSuggested_Mem_Rec;
Begin
   SafeGetMem( P, Suggested_Mem_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Suggested_Mem_Rec_Size, 0 );
      smRecord_Type := tkBegin_Suggested_Mem;
      smEOR         := tkEnd_Suggested_Mem;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Suggested_Mem_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Suggested_Mem_Rec_Dynamic_Fields ( Var O : TSuggested_Mem_Rec );

Begin
   If IsASuggested_Mem_Rec ( @O ) then With O do
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
  for i := tksmId to tksmHas_Changed do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Suggested_Mem_Rec_Delta(P1, P2, P3: pSuggested_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Suggested_Mem_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.smId <> P2.smId) then begin
    P3.smId := P1.smId;
    ChangedFields[i] := tksmId;
    Inc(i);
  end;
  if (P1.smMatched_Phrase <> P2.smMatched_Phrase) then begin
    P3.smMatched_Phrase := P1.smMatched_Phrase;
    ChangedFields[i] := tksmMatched_Phrase;
    Inc(i);
  end;
  if (P1.smTotal_Count <> P2.smTotal_Count) then begin
    P3.smTotal_Count := P1.smTotal_Count;
    ChangedFields[i] := tksmTotal_Count;
    Inc(i);
  end;
  if (P1.smManual_Count <> P2.smManual_Count) then begin
    P3.smManual_Count := P1.smManual_Count;
    ChangedFields[i] := tksmManual_Count;
    Inc(i);
  end;
  if (P1.smUncoded_Count <> P2.smUncoded_Count) then begin
    P3.smUncoded_Count := P1.smUncoded_Count;
    ChangedFields[i] := tksmUncoded_Count;
    Inc(i);
  end;
  if (P1.smUpdate_Date <> P2.smUpdate_Date) then begin
    P3.smUpdate_Date := P1.smUpdate_Date;
    ChangedFields[i] := tksmUpdate_Date;
    Inc(i);
  end;
  if (P1.smStart_Data <> P2.smStart_Data) then begin
    P3.smStart_Data := P1.smStart_Data;
    ChangedFields[i] := tksmStart_Data;
    Inc(i);
  end;
  if (P1.smEnd_Data <> P2.smEnd_Data) then begin
    P3.smEnd_Data := P1.smEnd_Data;
    ChangedFields[i] := tksmEnd_Data;
    Inc(i);
  end;
  if (P1.smHas_Changed <> P2.smHas_Changed) then begin
    P3.smHas_Changed := P1.smHas_Changed;
    ChangedFields[i] := tksmHas_Changed;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Suggested_Mem_Rec(P1, P2: pSuggested_Mem_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Suggested_Mem_Rec(P1^, S);
    S.Position := 0;
    Read_Suggested_Mem_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
