UNIT SYgrIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Group                        = 110 ;
   tkEnd_Group                          = 111 ;

FUNCTION  IsAGroup_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Group_Rec ( Var O : TGroup_Rec ; Var F : TIOStream );
PROCEDURE Read_Group_Rec ( Var O : TGroup_Rec ; Var F : TIOStream );
FUNCTION  New_Group_Rec : pGroup_Rec ;
PROCEDURE Free_Group_Rec_Dynamic_Fields ( Var O : TGroup_Rec );
FUNCTION Group_Rec_Delta(P1, P2, P3: pGroup_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Group_Rec(P1, P2: pGroup_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYGRIO';
   SBoundsError        = 'SYGRIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYGRIO Error: Pointer is NIL in IsAGroup_Rec';
   SInvalidType        = 'SYGRIO Error: Type is invalid in IsAGroup_Rec';
   SInvalidEOR         = 'SYGRIO Error: EOR is missing in IsAGroup_Rec';
   SUnknownToken       = 'SYGRIO Error: Unknown token %d in Read_Group_Rec';
   SInsufficientMemory = 'SYGRIO Error: Out of memory in New_Group_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkgrLRN                              = 112 ;
   tkgrName                             = 113 ;
   tkgrAudit_Record_ID                  = 114 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAGroup_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PGroup_Rec ( P )^ do Begin
      If grRecord_Type <> tkBegin_Group then
         Raise ECorruptData.Create( SInvalidType );
      If grEOR <> tkEnd_Group then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Group_Rec ( Var O : TGroup_Rec ; Var F : TIOStream );

Begin
   If IsAGroup_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Group );
      F.WriteIntegerValue( tkgrLRN , grLRN );
      F.WriteStringValue( tkgrName , grName );
      F.WriteIntegerValue( tkgrAudit_Record_ID , grAudit_Record_ID );
      F.WriteToken( tkEnd_Group );
   end;
end; { of Write_Group_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Group_Rec ( Var O : TGroup_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Group_Rec_Size, 0 );
   O.grRecord_Type := tkBegin_Group;
   O.grEOR := tkEnd_Group;
   Token := tkBegin_Group;

   While Token <> tkEnd_Group do With O do
   Begin
      Case Token of
         tkBegin_Group :; { Do Nothing }
         tkEnd_Group :; { Do Nothing }
         tkgrLRN                              : grLRN := F.ReadIntegerValue;
         tkgrName                             : grName := F.ReadStringValue;
         tkgrAudit_Record_ID                  : grAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Group_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Group_Rec : pGroup_Rec ;

Var
   P : pGroup_Rec;
Begin
   SafeGetMem( P, Group_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Group_Rec_Size, 0 );
      grRecord_Type := tkBegin_Group;
      grEOR         := tkEnd_Group;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Group_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Group_Rec_Dynamic_Fields ( Var O : TGroup_Rec );

Begin
   If IsAGroup_Rec ( @O ) then With O do
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
  for i := tkgrLRN to tkgrAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Group_Rec_Delta(P1, P2, P3: pGroup_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Group_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.grLRN <> P2.grLRN) then begin
    P3.grLRN := P1.grLRN;
    ChangedFields[i] := tkgrLRN;
    Inc(i);
  end;
  if (P1.grName <> P2.grName) then begin
    P3.grName := P1.grName;
    ChangedFields[i] := tkgrName;
    Inc(i);
  end;
  if (P1.grAudit_Record_ID <> P2.grAudit_Record_ID) then begin
    P3.grAudit_Record_ID := P1.grAudit_Record_ID;
    ChangedFields[i] := tkgrAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Group_Rec(P1, P2: pGroup_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Group_Rec(P1^, S);
    S.Position := 0;
    Read_Group_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
