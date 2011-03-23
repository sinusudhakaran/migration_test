UNIT BKshIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_SubGroup_Heading             = 200 ;
   tkEnd_SubGroup_Heading               = 201 ;

FUNCTION  IsASubGroup_Heading_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_SubGroup_Heading_Rec ( Var O : TSubGroup_Heading_Rec ; Var F : TIOStream );
PROCEDURE Read_SubGroup_Heading_Rec ( Var O : TSubGroup_Heading_Rec ; Var F : TIOStream );
FUNCTION  New_SubGroup_Heading_Rec : pSubGroup_Heading_Rec ;
PROCEDURE Free_SubGroup_Heading_Rec_Dynamic_Fields ( Var O : TSubGroup_Heading_Rec );
FUNCTION SubGroup_Heading_Rec_Delta(P1, P2, P3: pSubGroup_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_SubGroup_Heading_Rec(P1, P2: pSubGroup_Heading_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSHIO';
   SBoundsError        = 'BKSHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSHIO Error: Pointer is NIL in IsASubGroup_Heading_Rec';
   SInvalidType        = 'BKSHIO Error: Type is invalid in IsASubGroup_Heading_Rec';
   SInvalidEOR         = 'BKSHIO Error: EOR is missing in IsASubGroup_Heading_Rec';
   SUnknownToken       = 'BKSHIO Error: Unknown token %d in Read_SubGroup_Heading_Rec';
   SInsufficientMemory = 'BKSHIO Error: Out of memory in New_SubGroup_Heading_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkshHeading                          = 202 ;
   tkshReport_Group_No                  = 203 ;
   tkshSub_Group_No                     = 204 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASubGroup_Heading_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSubGroup_Heading_Rec ( P )^ do Begin
      If shRecord_Type <> tkBegin_SubGroup_Heading then
         Raise ECorruptData.Create( SInvalidType );
      If shEOR <> tkEnd_SubGroup_Heading then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_SubGroup_Heading_Rec ( Var O : TSubGroup_Heading_Rec ; Var F : TIOStream );

Begin
   If IsASubGroup_Heading_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_SubGroup_Heading );
      F.WriteStringValue( tkshHeading , shHeading );
      F.WriteIntegerValue( tkshReport_Group_No , shReport_Group_No );
      F.WriteIntegerValue( tkshSub_Group_No , shSub_Group_No );
      F.WriteToken( tkEnd_SubGroup_Heading );
   end;
end; { of Write_SubGroup_Heading_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_SubGroup_Heading_Rec ( Var O : TSubGroup_Heading_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, SubGroup_Heading_Rec_Size, 0 );
   O.shRecord_Type := tkBegin_SubGroup_Heading;
   O.shEOR := tkEnd_SubGroup_Heading;
   Token := tkBegin_SubGroup_Heading;

   While Token <> tkEnd_SubGroup_Heading do With O do
   Begin
      Case Token of
         tkBegin_SubGroup_Heading :; { Do Nothing }
         tkEnd_SubGroup_Heading :; { Do Nothing }
         tkshHeading                          : shHeading := F.ReadStringValue;
         tkshReport_Group_No                  : shReport_Group_No := F.ReadIntegerValue;
         tkshSub_Group_No                     : shSub_Group_No := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_SubGroup_Heading_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_SubGroup_Heading_Rec : pSubGroup_Heading_Rec ;

Var
   P : pSubGroup_Heading_Rec;
Begin
   SafeGetMem( P, SubGroup_Heading_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, SubGroup_Heading_Rec_Size, 0 );
      shRecord_Type := tkBegin_SubGroup_Heading;
      shEOR         := tkEnd_SubGroup_Heading;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_SubGroup_Heading_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_SubGroup_Heading_Rec_Dynamic_Fields ( Var O : TSubGroup_Heading_Rec );

Begin
   If IsASubGroup_Heading_Rec ( @O ) then With O do
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
  for i := tkshHeading to tkshSub_Group_No do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION SubGroup_Heading_Rec_Delta(P1, P2, P3: pSubGroup_Heading_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_SubGroup_Heading_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.shHeading <> P2.shHeading) then begin
    P3.shHeading := P1.shHeading;
    ChangedFields[i] := tkshHeading;
    Inc(i);
  end;
  if (P1.shReport_Group_No <> P2.shReport_Group_No) then begin
    P3.shReport_Group_No := P1.shReport_Group_No;
    ChangedFields[i] := tkshReport_Group_No;
    Inc(i);
  end;
  if (P1.shSub_Group_No <> P2.shSub_Group_No) then begin
    P3.shSub_Group_No := P1.shSub_Group_No;
    ChangedFields[i] := tkshSub_Group_No;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_SubGroup_Heading_Rec(P1, P2: pSubGroup_Heading_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_SubGroup_Heading_Rec(P1^, S);
    S.Position := 0;
    Read_SubGroup_Heading_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
