UNIT BKjhIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Job_Heading                  = 210 ;
   tkEnd_Job_Heading                    = 211 ;

FUNCTION  IsAJob_Heading_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );
PROCEDURE Read_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );
FUNCTION  New_Job_Heading_Rec : pJob_Heading_Rec ;
PROCEDURE Free_Job_Heading_Rec_Dynamic_Fields ( Var O : TJob_Heading_Rec );
FUNCTION Job_Heading_Rec_Delta(P1, P2, P3: pJob_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Job_Heading_Rec(P1, P2: pJob_Heading_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKJHIO';
   SBoundsError        = 'BKJHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKJHIO Error: Pointer is NIL in IsAJob_Heading_Rec';
   SInvalidType        = 'BKJHIO Error: Type is invalid in IsAJob_Heading_Rec';
   SInvalidEOR         = 'BKJHIO Error: EOR is missing in IsAJob_Heading_Rec';
   SUnknownToken       = 'BKJHIO Error: Unknown token %d in Read_Job_Heading_Rec';
   SInsufficientMemory = 'BKJHIO Error: Out of memory in New_Job_Heading_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkjhHeading                          = 212 ;
   tkjhLRN                              = 213 ;
   tkjhDate_Completed                   = 214 ;
   tkjhCode                             = 215 ;
   tkjhAudit_Record_ID                  = 216 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAJob_Heading_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PJob_Heading_Rec ( P )^ do Begin
      If jhRecord_Type <> tkBegin_Job_Heading then
         Raise ECorruptData.Create( SInvalidType );
      If jhEOR <> tkEnd_Job_Heading then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Job_Heading_Rec ( Var O : TJob_Heading_Rec ; Var F : TIOStream );

Begin
   If IsAJob_Heading_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Job_Heading );
      F.WriteStringValue( tkjhHeading , jhHeading );
      F.WriteIntegerValue( tkjhLRN , jhLRN );
      F.WriteDateValue( tkjhDate_Completed , jhDate_Completed );
      F.WriteStringValue( tkjhCode , jhCode );
      F.WriteIntegerValue( tkjhAudit_Record_ID , jhAudit_Record_ID );
      F.WriteToken( tkEnd_Job_Heading );
   end;
end; { of Write_Job_Heading_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Job_Heading_Rec ( Var O : TJob_Heading_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Job_Heading_Rec_Size, 0 );
   O.jhRecord_Type := tkBegin_Job_Heading;
   O.jhEOR := tkEnd_Job_Heading;
   Token := tkBegin_Job_Heading;

   While Token <> tkEnd_Job_Heading do With O do
   Begin
      Case Token of
         tkBegin_Job_Heading :; { Do Nothing }
         tkEnd_Job_Heading :; { Do Nothing }
         tkjhHeading                          : jhHeading := F.ReadStringValue;
         tkjhLRN                              : jhLRN := F.ReadIntegerValue;
         tkjhDate_Completed                   : jhDate_Completed := F.ReadDateValue;
         tkjhCode                             : jhCode := F.ReadStringValue;
         tkjhAudit_Record_ID                  : jhAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Job_Heading_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Job_Heading_Rec : pJob_Heading_Rec ;

Var
   P : pJob_Heading_Rec;
Begin
   SafeGetMem( P, Job_Heading_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Job_Heading_Rec_Size, 0 );
      jhRecord_Type := tkBegin_Job_Heading;
      jhEOR         := tkEnd_Job_Heading;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Job_Heading_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Job_Heading_Rec_Dynamic_Fields ( Var O : TJob_Heading_Rec );

Begin
   If IsAJob_Heading_Rec ( @O ) then With O do
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
  for i := tkjhHeading to tkjhAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Job_Heading_Rec_Delta(P1, P2, P3: pJob_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Job_Heading_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.jhHeading <> P2.jhHeading) then begin
    P3.jhHeading := P1.jhHeading;
    ChangedFields[i] := tkjhHeading;
    Inc(i);
  end;
  if (P1.jhLRN <> P2.jhLRN) then begin
    P3.jhLRN := P1.jhLRN;
    ChangedFields[i] := tkjhLRN;
    Inc(i);
  end;
  if (P1.jhDate_Completed <> P2.jhDate_Completed) then begin
    P3.jhDate_Completed := P1.jhDate_Completed;
    ChangedFields[i] := tkjhDate_Completed;
    Inc(i);
  end;
  if (P1.jhCode <> P2.jhCode) then begin
    P3.jhCode := P1.jhCode;
    ChangedFields[i] := tkjhCode;
    Inc(i);
  end;
  if (P1.jhAudit_Record_ID <> P2.jhAudit_Record_ID) then begin
    P3.jhAudit_Record_ID := P1.jhAudit_Record_ID;
    ChangedFields[i] := tkjhAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Job_Heading_Rec(P1, P2: pJob_Heading_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Job_Heading_Rec(P1^, S);
    S.Position := 0;
    Read_Job_Heading_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
