UNIT SYsmIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_System_Memorisation_List     = 150 ;
   tkEnd_System_Memorisation_List       = 151 ;

FUNCTION  IsASystem_Memorisation_List_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_System_Memorisation_List_Rec ( Var O : TSystem_Memorisation_List_Rec ; Var F : TIOStream );
PROCEDURE Read_System_Memorisation_List_Rec ( Var O : TSystem_Memorisation_List_Rec ; Var F : TIOStream );
FUNCTION  New_System_Memorisation_List_Rec : pSystem_Memorisation_List_Rec ;
PROCEDURE Free_System_Memorisation_List_Rec_Dynamic_Fields ( Var O : TSystem_Memorisation_List_Rec );
FUNCTION System_Memorisation_List_Rec_Delta(P1, P2, P3: pSystem_Memorisation_List_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_System_Memorisation_List_Rec(P1, P2: pSystem_Memorisation_List_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYSMIO';
   SBoundsError        = 'SYSMIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYSMIO Error: Pointer is NIL in IsASystem_Memorisation_List_Rec';
   SInvalidType        = 'SYSMIO Error: Type is invalid in IsASystem_Memorisation_List_Rec';
   SInvalidEOR         = 'SYSMIO Error: EOR is missing in IsASystem_Memorisation_List_Rec';
   SUnknownToken       = 'SYSMIO Error: Unknown token %d in Read_System_Memorisation_List_Rec';
   SInsufficientMemory = 'SYSMIO Error: Out of memory in New_System_Memorisation_List_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksmAudit_Record_ID                  = 152 ;
   tksmBank_Prefix                      = 153 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASystem_Memorisation_List_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSystem_Memorisation_List_Rec ( P )^ do Begin
      If smRecord_Type <> tkBegin_System_Memorisation_List then
         Raise ECorruptData.Create( SInvalidType );
      If smEOR <> tkEnd_System_Memorisation_List then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_System_Memorisation_List_Rec ( Var O : TSystem_Memorisation_List_Rec ; Var F : TIOStream );

Begin
   If IsASystem_Memorisation_List_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_System_Memorisation_List );
      F.WriteIntegerValue( tksmAudit_Record_ID , smAudit_Record_ID );
      F.WriteStringValue( tksmBank_Prefix , smBank_Prefix );
      F.WriteToken( tkEnd_System_Memorisation_List );
   end;
end; { of Write_System_Memorisation_List_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_System_Memorisation_List_Rec ( Var O : TSystem_Memorisation_List_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, System_Memorisation_List_Rec_Size, 0 );
   O.smRecord_Type := tkBegin_System_Memorisation_List;
   O.smEOR := tkEnd_System_Memorisation_List;
   Token := tkBegin_System_Memorisation_List;

   While Token <> tkEnd_System_Memorisation_List do With O do
   Begin
      Case Token of
         tkBegin_System_Memorisation_List :; { Do Nothing }
         tkEnd_System_Memorisation_List :; { Do Nothing }
         tksmAudit_Record_ID                  : smAudit_Record_ID := F.ReadIntegerValue;
         tksmBank_Prefix                      : smBank_Prefix := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_System_Memorisation_List_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_System_Memorisation_List_Rec : pSystem_Memorisation_List_Rec ;

Var
   P : pSystem_Memorisation_List_Rec;
Begin
   SafeGetMem( P, System_Memorisation_List_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, System_Memorisation_List_Rec_Size, 0 );
      smRecord_Type := tkBegin_System_Memorisation_List;
      smEOR         := tkEnd_System_Memorisation_List;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_System_Memorisation_List_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_System_Memorisation_List_Rec_Dynamic_Fields ( Var O : TSystem_Memorisation_List_Rec );

Begin
   If IsASystem_Memorisation_List_Rec ( @O ) then With O do
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
  for i := tksmAudit_Record_ID to tksmBank_Prefix do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION System_Memorisation_List_Rec_Delta(P1, P2, P3: pSystem_Memorisation_List_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_System_Memorisation_List_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.smAudit_Record_ID <> P2.smAudit_Record_ID) then begin
    P3.smAudit_Record_ID := P1.smAudit_Record_ID;
    ChangedFields[i] := tksmAudit_Record_ID;
    Inc(i);
  end;
  if (P1.smBank_Prefix <> P2.smBank_Prefix) then begin
    P3.smBank_Prefix := P1.smBank_Prefix;
    ChangedFields[i] := tksmBank_Prefix;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_System_Memorisation_List_Rec(P1, P2: pSystem_Memorisation_List_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_System_Memorisation_List_Rec(P1^, S);
    S.Position := 0;
    Read_System_Memorisation_List_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
