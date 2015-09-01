UNIT BKsmIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Suggested_Mem                = 170 ;
   tkEnd_Suggested_Mem                  = 171 ;

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
   tksmId                               = 172 ;
   tksmTypeId                           = 173 ;
   tksmPhraseId                         = 174 ;
   tksmStart_Data                       = 175 ;
   tksmEnd_Data                         = 176 ;
   tksmUpdate_Date                      = 177 ;
   tksmHas_Changed                      = 178 ;
   tksmManual_Count                     = 179 ;
   tksmHidden                           = 180 ;
   tksmHiddenForSession                 = 181 ;

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
      F.WriteByteValue( tksmTypeId , smTypeId );
      F.WriteIntegerValue( tksmPhraseId , smPhraseId );
      F.WriteBooleanValue( tksmStart_Data , smStart_Data );
      F.WriteBooleanValue( tksmEnd_Data , smEnd_Data );
      F.WriteDateValue( tksmUpdate_Date , smUpdate_Date );
      F.WriteBooleanValue( tksmHas_Changed , smHas_Changed );
      F.WriteIntegerValue( tksmManual_Count , smManual_Count );
      F.WriteBooleanValue( tksmHidden , smHidden );
      F.WriteBooleanValue( tksmHiddenForSession , smHiddenForSession );
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
         tksmTypeId                           : smTypeId := F.ReadByteValue;
         tksmPhraseId                         : smPhraseId := F.ReadIntegerValue;
         tksmStart_Data                       : smStart_Data := F.ReadBooleanValue;
         tksmEnd_Data                         : smEnd_Data := F.ReadBooleanValue;
         tksmUpdate_Date                      : smUpdate_Date := F.ReadDateValue;
         tksmHas_Changed                      : smHas_Changed := F.ReadBooleanValue;
         tksmManual_Count                     : smManual_Count := F.ReadIntegerValue;
         tksmHidden                           : smHidden := F.ReadBooleanValue;
         tksmHiddenForSession                 : smHiddenForSession := F.ReadBooleanValue;
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
  for i := tksmId to tksmHiddenForSession do begin
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
  if (P1.smTypeId <> P2.smTypeId) then begin
    P3.smTypeId := P1.smTypeId;
    ChangedFields[i] := tksmTypeId;
    Inc(i);
  end;
  if (P1.smPhraseId <> P2.smPhraseId) then begin
    P3.smPhraseId := P1.smPhraseId;
    ChangedFields[i] := tksmPhraseId;
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
  if (P1.smUpdate_Date <> P2.smUpdate_Date) then begin
    P3.smUpdate_Date := P1.smUpdate_Date;
    ChangedFields[i] := tksmUpdate_Date;
    Inc(i);
  end;
  if (P1.smHas_Changed <> P2.smHas_Changed) then begin
    P3.smHas_Changed := P1.smHas_Changed;
    ChangedFields[i] := tksmHas_Changed;
    Inc(i);
  end;
  if (P1.smManual_Count <> P2.smManual_Count) then begin
    P3.smManual_Count := P1.smManual_Count;
    ChangedFields[i] := tksmManual_Count;
    Inc(i);
  end;
  if (P1.smHidden <> P2.smHidden) then begin
    P3.smHidden := P1.smHidden;
    ChangedFields[i] := tksmHidden;
    Inc(i);
  end;
  if (P1.smHiddenForSession <> P2.smHiddenForSession) then begin
    P3.smHiddenForSession := P1.smHiddenForSession;
    ChangedFields[i] := tksmHiddenForSession;
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
