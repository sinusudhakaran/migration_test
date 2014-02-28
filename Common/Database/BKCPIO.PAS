UNIT BKcpIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Candidate_Mem_Processing     = 166 ;
   tkEnd_Candidate_Mem_Processing       = 167 ;

FUNCTION  IsACandidate_Mem_Processing_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Candidate_Mem_Processing_Rec ( Var O : TCandidate_Mem_Processing_Rec ; Var F : TIOStream );
PROCEDURE Read_Candidate_Mem_Processing_Rec ( Var O : TCandidate_Mem_Processing_Rec ; Var F : TIOStream );
FUNCTION  New_Candidate_Mem_Processing_Rec : pCandidate_Mem_Processing_Rec ;
PROCEDURE Free_Candidate_Mem_Processing_Rec_Dynamic_Fields ( Var O : TCandidate_Mem_Processing_Rec );
FUNCTION Candidate_Mem_Processing_Rec_Delta(P1, P2, P3: pCandidate_Mem_Processing_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Candidate_Mem_Processing_Rec(P1, P2: pCandidate_Mem_Processing_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKCPIO';
   SBoundsError        = 'BKCPIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKCPIO Error: Pointer is NIL in IsACandidate_Mem_Processing_Rec';
   SInvalidType        = 'BKCPIO Error: Type is invalid in IsACandidate_Mem_Processing_Rec';
   SInvalidEOR         = 'BKCPIO Error: EOR is missing in IsACandidate_Mem_Processing_Rec';
   SUnknownToken       = 'BKCPIO Error: Unknown token %d in Read_Candidate_Mem_Processing_Rec';
   SInsufficientMemory = 'BKCPIO Error: Out of memory in New_Candidate_Mem_Processing_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkcpCandidate_ID_To_Process          = 168 ;
   tkcpNext_Candidate_ID                = 169 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACandidate_Mem_Processing_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PCandidate_Mem_Processing_Rec ( P )^ do Begin
      If cpRecord_Type <> tkBegin_Candidate_Mem_Processing then
         Raise ECorruptData.Create( SInvalidType );
      If cpEOR <> tkEnd_Candidate_Mem_Processing then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Candidate_Mem_Processing_Rec ( Var O : TCandidate_Mem_Processing_Rec ; Var F : TIOStream );

Begin
   If IsACandidate_Mem_Processing_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Candidate_Mem_Processing );
      F.WriteIntegerValue( tkcpCandidate_ID_To_Process , cpCandidate_ID_To_Process );
      F.WriteIntegerValue( tkcpNext_Candidate_ID , cpNext_Candidate_ID );
      F.WriteToken( tkEnd_Candidate_Mem_Processing );
   end;
end; { of Write_Candidate_Mem_Processing_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Candidate_Mem_Processing_Rec ( Var O : TCandidate_Mem_Processing_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Candidate_Mem_Processing_Rec_Size, 0 );
   O.cpRecord_Type := tkBegin_Candidate_Mem_Processing;
   O.cpEOR := tkEnd_Candidate_Mem_Processing;
   Token := tkBegin_Candidate_Mem_Processing;

   While Token <> tkEnd_Candidate_Mem_Processing do With O do
   Begin
      Case Token of
         tkBegin_Candidate_Mem_Processing :; { Do Nothing }
         tkEnd_Candidate_Mem_Processing :; { Do Nothing }
         tkcpCandidate_ID_To_Process          : cpCandidate_ID_To_Process := F.ReadIntegerValue;
         tkcpNext_Candidate_ID                : cpNext_Candidate_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Candidate_Mem_Processing_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Candidate_Mem_Processing_Rec : pCandidate_Mem_Processing_Rec ;

Var
   P : pCandidate_Mem_Processing_Rec;
Begin
   SafeGetMem( P, Candidate_Mem_Processing_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Candidate_Mem_Processing_Rec_Size, 0 );
      cpRecord_Type := tkBegin_Candidate_Mem_Processing;
      cpEOR         := tkEnd_Candidate_Mem_Processing;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Candidate_Mem_Processing_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Candidate_Mem_Processing_Rec_Dynamic_Fields ( Var O : TCandidate_Mem_Processing_Rec );

Begin
   If IsACandidate_Mem_Processing_Rec ( @O ) then With O do
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
  for i := tkcpCandidate_ID_To_Process to tkcpNext_Candidate_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Candidate_Mem_Processing_Rec_Delta(P1, P2, P3: pCandidate_Mem_Processing_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Candidate_Mem_Processing_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.cpCandidate_ID_To_Process <> P2.cpCandidate_ID_To_Process) then begin
    P3.cpCandidate_ID_To_Process := P1.cpCandidate_ID_To_Process;
    ChangedFields[i] := tkcpCandidate_ID_To_Process;
    Inc(i);
  end;
  if (P1.cpNext_Candidate_ID <> P2.cpNext_Candidate_ID) then begin
    P3.cpNext_Candidate_ID := P1.cpNext_Candidate_ID;
    ChangedFields[i] := tkcpNext_Candidate_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Candidate_Mem_Processing_Rec(P1, P2: pCandidate_Mem_Processing_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Candidate_Mem_Processing_Rec(P1^, S);
    S.Position := 0;
    Read_Candidate_Mem_Processing_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
