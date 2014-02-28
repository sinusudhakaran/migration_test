UNIT BKcmIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Candidate_Mem                = 167 ;
   tkEnd_Candidate_Mem                  = 168 ;

FUNCTION  IsACandidate_Mem_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Candidate_Mem_Rec ( Var O : TCandidate_Mem_Rec ; Var F : TIOStream );
PROCEDURE Read_Candidate_Mem_Rec ( Var O : TCandidate_Mem_Rec ; Var F : TIOStream );
FUNCTION  New_Candidate_Mem_Rec : pCandidate_Mem_Rec ;
PROCEDURE Free_Candidate_Mem_Rec_Dynamic_Fields ( Var O : TCandidate_Mem_Rec );
FUNCTION Candidate_Mem_Rec_Delta(P1, P2, P3: pCandidate_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Candidate_Mem_Rec(P1, P2: pCandidate_Mem_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKCMIO';
   SBoundsError        = 'BKCMIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKCMIO Error: Pointer is NIL in IsACandidate_Mem_Rec';
   SInvalidType        = 'BKCMIO Error: Type is invalid in IsACandidate_Mem_Rec';
   SInvalidEOR         = 'BKCMIO Error: EOR is missing in IsACandidate_Mem_Rec';
   SUnknownToken       = 'BKCMIO Error: Unknown token %d in Read_Candidate_Mem_Rec';
   SInsufficientMemory = 'BKCMIO Error: Out of memory in New_Candidate_Mem_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkcmID                               = 169 ;
   tkcmCount                            = 170 ;
   tkcmType                             = 171 ;
   tkcmBank_Account_Number              = 172 ;
   tkcmCoded_By                         = 173 ;
   tkcmAccount                          = 174 ;
   tkcmStatement_Details                = 175 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACandidate_Mem_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PCandidate_Mem_Rec ( P )^ do Begin
      If cmRecord_Type <> tkBegin_Candidate_Mem then
         Raise ECorruptData.Create( SInvalidType );
      If cmEOR <> tkEnd_Candidate_Mem then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Candidate_Mem_Rec ( Var O : TCandidate_Mem_Rec ; Var F : TIOStream );

Begin
   If IsACandidate_Mem_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Candidate_Mem );
      F.WriteIntegerValue( tkcmID , cmID );
      F.WriteIntegerValue( tkcmCount , cmCount );
      F.WriteByteValue( tkcmType , cmType );
      F.WriteStringValue( tkcmBank_Account_Number , cmBank_Account_Number );
      F.WriteByteValue( tkcmCoded_By , cmCoded_By );
      F.WriteStringValue( tkcmAccount , cmAccount );
      F.WriteStringValue( tkcmStatement_Details , cmStatement_Details );
      F.WriteToken( tkEnd_Candidate_Mem );
   end;
end; { of Write_Candidate_Mem_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Candidate_Mem_Rec ( Var O : TCandidate_Mem_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Candidate_Mem_Rec_Size, 0 );
   O.cmRecord_Type := tkBegin_Candidate_Mem;
   O.cmEOR := tkEnd_Candidate_Mem;
   Token := tkBegin_Candidate_Mem;

   While Token <> tkEnd_Candidate_Mem do With O do
   Begin
      Case Token of
         tkBegin_Candidate_Mem :; { Do Nothing }
         tkEnd_Candidate_Mem :; { Do Nothing }
         tkcmID                               : cmID := F.ReadIntegerValue;
         tkcmCount                            : cmCount := F.ReadIntegerValue;
         tkcmType                             : cmType := F.ReadByteValue;
         tkcmBank_Account_Number              : cmBank_Account_Number := F.ReadStringValue;
         tkcmCoded_By                         : cmCoded_By := F.ReadByteValue;
         tkcmAccount                          : cmAccount := F.ReadStringValue;
         tkcmStatement_Details                : cmStatement_Details := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Candidate_Mem_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Candidate_Mem_Rec : pCandidate_Mem_Rec ;

Var
   P : pCandidate_Mem_Rec;
Begin
   SafeGetMem( P, Candidate_Mem_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Candidate_Mem_Rec_Size, 0 );
      cmRecord_Type := tkBegin_Candidate_Mem;
      cmEOR         := tkEnd_Candidate_Mem;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Candidate_Mem_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Candidate_Mem_Rec_Dynamic_Fields ( Var O : TCandidate_Mem_Rec );

Begin
   If IsACandidate_Mem_Rec ( @O ) then With O do
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
  for i := tkcmID to tkcmStatement_Details do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Candidate_Mem_Rec_Delta(P1, P2, P3: pCandidate_Mem_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Candidate_Mem_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.cmID <> P2.cmID) then begin
    P3.cmID := P1.cmID;
    ChangedFields[i] := tkcmID;
    Inc(i);
  end;
  if (P1.cmCount <> P2.cmCount) then begin
    P3.cmCount := P1.cmCount;
    ChangedFields[i] := tkcmCount;
    Inc(i);
  end;
  if (P1.cmType <> P2.cmType) then begin
    P3.cmType := P1.cmType;
    ChangedFields[i] := tkcmType;
    Inc(i);
  end;
  if (P1.cmBank_Account_Number <> P2.cmBank_Account_Number) then begin
    P3.cmBank_Account_Number := P1.cmBank_Account_Number;
    ChangedFields[i] := tkcmBank_Account_Number;
    Inc(i);
  end;
  if (P1.cmCoded_By <> P2.cmCoded_By) then begin
    P3.cmCoded_By := P1.cmCoded_By;
    ChangedFields[i] := tkcmCoded_By;
    Inc(i);
  end;
  if (P1.cmAccount <> P2.cmAccount) then begin
    P3.cmAccount := P1.cmAccount;
    ChangedFields[i] := tkcmAccount;
    Inc(i);
  end;
  if (P1.cmStatement_Details <> P2.cmStatement_Details) then begin
    P3.cmStatement_Details := P1.cmStatement_Details;
    ChangedFields[i] := tkcmStatement_Details;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Candidate_Mem_Rec(P1, P2: pCandidate_Mem_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Candidate_Mem_Rec(P1^, S);
    S.Position := 0;
    Read_Candidate_Mem_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
