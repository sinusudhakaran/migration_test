UNIT CSsfIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES CSDEFS, IOSTREAM, CSAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Coding_Stat_Fields           = 20 ;
   tkEnd_Coding_Stat_Fields             = 21 ;

FUNCTION  IsACoding_Stat_Fields_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );
PROCEDURE Read_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );
FUNCTION  New_Coding_Stat_Fields_Rec : pCoding_Stat_Fields_Rec ;
PROCEDURE Free_Coding_Stat_Fields_Rec_Dynamic_Fields ( Var O : TCoding_Stat_Fields_Rec );
FUNCTION Coding_Stat_Fields_Rec_Delta(P1, P2, P3: pCoding_Stat_Fields_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Coding_Stat_Fields_Rec(P1, P2: pCoding_Stat_Fields_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'CSSFIO';
   SBoundsError        = 'CSSFIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'CSSFIO Error: Pointer is NIL in IsACoding_Stat_Fields_Rec';
   SInvalidType        = 'CSSFIO Error: Type is invalid in IsACoding_Stat_Fields_Rec';
   SInvalidEOR         = 'CSSFIO Error: EOR is missing in IsACoding_Stat_Fields_Rec';
   SUnknownToken       = 'CSSFIO Error: Unknown token %d in Read_Coding_Stat_Fields_Rec';
   SInsufficientMemory = 'CSSFIO Error: Out of memory in New_Coding_Stat_Fields_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksfFile_Version                     = 22 ;
   tksfRead_Version                     = 23 ;

{  -------------------------------------------------------------------  }

FUNCTION IsACoding_Stat_Fields_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PCoding_Stat_Fields_Rec ( P )^ do Begin
      If sfRecord_Type <> tkBegin_Coding_Stat_Fields then
         Raise ECorruptData.Create( SInvalidType );
      If sfEOR <> tkEnd_Coding_Stat_Fields then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec ; Var F : TIOStream );

Begin
   If IsACoding_Stat_Fields_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Coding_Stat_Fields );
      F.WriteIntegerValue( tksfFile_Version , sfFile_Version );
      F.WriteIntegerValue( tksfRead_Version , sfRead_Version );
      F.WriteToken( tkEnd_Coding_Stat_Fields );
   end;
end; { of Write_Coding_Stat_Fields_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Coding_Stat_Fields_Rec ( Var O : TCoding_Stat_Fields_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Coding_Stat_Fields_Rec_Size, 0 );
   O.sfRecord_Type := tkBegin_Coding_Stat_Fields;
   O.sfEOR := tkEnd_Coding_Stat_Fields;
   Token := tkBegin_Coding_Stat_Fields;

   While Token <> tkEnd_Coding_Stat_Fields do With O do
   Begin
      Case Token of
         tkBegin_Coding_Stat_Fields :; { Do Nothing }
         tkEnd_Coding_Stat_Fields :; { Do Nothing }
         tksfFile_Version                     : sfFile_Version := F.ReadIntegerValue;
         tksfRead_Version                     : sfRead_Version := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Coding_Stat_Fields_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Coding_Stat_Fields_Rec : pCoding_Stat_Fields_Rec ;

Var
   P : pCoding_Stat_Fields_Rec;
Begin
   SafeGetMem( P, Coding_Stat_Fields_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Coding_Stat_Fields_Rec_Size, 0 );
      sfRecord_Type := tkBegin_Coding_Stat_Fields;
      sfEOR         := tkEnd_Coding_Stat_Fields;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Coding_Stat_Fields_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Coding_Stat_Fields_Rec_Dynamic_Fields ( Var O : TCoding_Stat_Fields_Rec );

Begin
   If IsACoding_Stat_Fields_Rec ( @O ) then With O do
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
  for i := tksfFile_Version to tksfRead_Version do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Coding_Stat_Fields_Rec_Delta(P1, P2, P3: pCoding_Stat_Fields_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Coding_Stat_Fields_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.sfFile_Version <> P2.sfFile_Version) then begin
    P3.sfFile_Version := P1.sfFile_Version;
    ChangedFields[i] := tksfFile_Version;
    Inc(i);
  end;
  if (P1.sfRead_Version <> P2.sfRead_Version) then begin
    P3.sfRead_Version := P1.sfRead_Version;
    ChangedFields[i] := tksfRead_Version;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Coding_Stat_Fields_Rec(P1, P2: pCoding_Stat_Fields_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Coding_Stat_Fields_Rec(P1^, S);
    S.Position := 0;
    Read_Coding_Stat_Fields_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
