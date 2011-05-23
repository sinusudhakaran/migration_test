UNIT BKdhIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Division_Heading             = 210 ;
   tkEnd_Division_Heading               = 211 ;

FUNCTION  IsADivision_Heading_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Division_Heading_Rec ( Var O : TDivision_Heading_Rec ; Var F : TIOStream );
PROCEDURE Read_Division_Heading_Rec ( Var O : TDivision_Heading_Rec ; Var F : TIOStream );
FUNCTION  New_Division_Heading_Rec : pDivision_Heading_Rec ;
PROCEDURE Free_Division_Heading_Rec_Dynamic_Fields ( Var O : TDivision_Heading_Rec );
FUNCTION Division_Heading_Rec_Delta(P1, P2, P3: pDivision_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Division_Heading_Rec(P1, P2: pDivision_Heading_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKDHIO';
   SBoundsError        = 'BKDHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKDHIO Error: Pointer is NIL in IsADivision_Heading_Rec';
   SInvalidType        = 'BKDHIO Error: Type is invalid in IsADivision_Heading_Rec';
   SInvalidEOR         = 'BKDHIO Error: EOR is missing in IsADivision_Heading_Rec';
   SUnknownToken       = 'BKDHIO Error: Unknown token %d in Read_Division_Heading_Rec';
   SInsufficientMemory = 'BKDHIO Error: Out of memory in New_Division_Heading_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdhHeading                          = 212 ;
   tkdhDivision_No                      = 213 ;
   tkdhAudit_Record_ID                  = 214 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADivision_Heading_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PDivision_Heading_Rec ( P )^ do Begin
      If dhRecord_Type <> tkBegin_Division_Heading then
         Raise ECorruptData.Create( SInvalidType );
      If dhEOR <> tkEnd_Division_Heading then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Division_Heading_Rec ( Var O : TDivision_Heading_Rec ; Var F : TIOStream );

Begin
   If IsADivision_Heading_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Division_Heading );
      F.WriteStringValue( tkdhHeading , dhHeading );
      F.WriteIntegerValue( tkdhDivision_No , dhDivision_No );
      F.WriteIntegerValue( tkdhAudit_Record_ID , dhAudit_Record_ID );
      F.WriteToken( tkEnd_Division_Heading );
   end;
end; { of Write_Division_Heading_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Division_Heading_Rec ( Var O : TDivision_Heading_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Division_Heading_Rec_Size, 0 );
   O.dhRecord_Type := tkBegin_Division_Heading;
   O.dhEOR := tkEnd_Division_Heading;
   Token := tkBegin_Division_Heading;

   While Token <> tkEnd_Division_Heading do With O do
   Begin
      Case Token of
         tkBegin_Division_Heading :; { Do Nothing }
         tkEnd_Division_Heading :; { Do Nothing }
         tkdhHeading                          : dhHeading := F.ReadStringValue;
         tkdhDivision_No                      : dhDivision_No := F.ReadIntegerValue;
         tkdhAudit_Record_ID                  : dhAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Division_Heading_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Division_Heading_Rec : pDivision_Heading_Rec ;

Var
   P : pDivision_Heading_Rec;
Begin
   SafeGetMem( P, Division_Heading_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Division_Heading_Rec_Size, 0 );
      dhRecord_Type := tkBegin_Division_Heading;
      dhEOR         := tkEnd_Division_Heading;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Division_Heading_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Division_Heading_Rec_Dynamic_Fields ( Var O : TDivision_Heading_Rec );

Begin
   If IsADivision_Heading_Rec ( @O ) then With O do
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
  for i := tkdhHeading to tkdhAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Division_Heading_Rec_Delta(P1, P2, P3: pDivision_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Division_Heading_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.dhHeading <> P2.dhHeading) then begin
    P3.dhHeading := P1.dhHeading;
    ChangedFields[i] := tkdhHeading;
    Inc(i);
  end;
  if (P1.dhDivision_No <> P2.dhDivision_No) then begin
    P3.dhDivision_No := P1.dhDivision_No;
    ChangedFields[i] := tkdhDivision_No;
    Inc(i);
  end;
  if (P1.dhAudit_Record_ID <> P2.dhAudit_Record_ID) then begin
    P3.dhAudit_Record_ID := P1.dhAudit_Record_ID;
    ChangedFields[i] := tkdhAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Division_Heading_Rec(P1, P2: pDivision_Heading_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Division_Heading_Rec(P1^, S);
    S.Position := 0;
    Read_Division_Heading_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
