UNIT SYacIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_File_Access_Mapping          = 100 ;
   tkEnd_File_Access_Mapping            = 101 ;

FUNCTION  IsAFile_Access_Mapping_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_File_Access_Mapping_Rec ( Var O : TFile_Access_Mapping_Rec ; Var F : TIOStream );
PROCEDURE Read_File_Access_Mapping_Rec ( Var O : TFile_Access_Mapping_Rec ; Var F : TIOStream );
FUNCTION  New_File_Access_Mapping_Rec : pFile_Access_Mapping_Rec ;
PROCEDURE Free_File_Access_Mapping_Rec_Dynamic_Fields ( Var O : TFile_Access_Mapping_Rec );
FUNCTION File_Access_Mapping_Rec_Delta(P1, P2, P3: pFile_Access_Mapping_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_File_Access_Mapping_Rec(P1, P2: pFile_Access_Mapping_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYACIO';
   SBoundsError        = 'SYACIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYACIO Error: Pointer is NIL in IsAFile_Access_Mapping_Rec';
   SInvalidType        = 'SYACIO Error: Type is invalid in IsAFile_Access_Mapping_Rec';
   SInvalidEOR         = 'SYACIO Error: EOR is missing in IsAFile_Access_Mapping_Rec';
   SUnknownToken       = 'SYACIO Error: Unknown token %d in Read_File_Access_Mapping_Rec';
   SInsufficientMemory = 'SYACIO Error: Out of memory in New_File_Access_Mapping_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkacUser_LRN                         = 102 ;
   tkacClient_File_LRN                  = 103 ;
   tkacAudit_Record_ID                  = 104 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAFile_Access_Mapping_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PFile_Access_Mapping_Rec ( P )^ do Begin
      If acRecord_Type <> tkBegin_File_Access_Mapping then
         Raise ECorruptData.Create( SInvalidType );
      If acEOR <> tkEnd_File_Access_Mapping then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_File_Access_Mapping_Rec ( Var O : TFile_Access_Mapping_Rec ; Var F : TIOStream );

Begin
   If IsAFile_Access_Mapping_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_File_Access_Mapping );
      F.WriteIntegerValue( tkacUser_LRN , acUser_LRN );
      F.WriteIntegerValue( tkacClient_File_LRN , acClient_File_LRN );
      F.WriteIntegerValue( tkacAudit_Record_ID , acAudit_Record_ID );
      F.WriteToken( tkEnd_File_Access_Mapping );
   end;
end; { of Write_File_Access_Mapping_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_File_Access_Mapping_Rec ( Var O : TFile_Access_Mapping_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, File_Access_Mapping_Rec_Size, 0 );
   O.acRecord_Type := tkBegin_File_Access_Mapping;
   O.acEOR := tkEnd_File_Access_Mapping;
   Token := tkBegin_File_Access_Mapping;

   While Token <> tkEnd_File_Access_Mapping do With O do
   Begin
      Case Token of
         tkBegin_File_Access_Mapping :; { Do Nothing }
         tkEnd_File_Access_Mapping :; { Do Nothing }
         tkacUser_LRN                         : acUser_LRN := F.ReadIntegerValue;
         tkacClient_File_LRN                  : acClient_File_LRN := F.ReadIntegerValue;
         tkacAudit_Record_ID                  : acAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_File_Access_Mapping_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_File_Access_Mapping_Rec : pFile_Access_Mapping_Rec ;

Var
   P : pFile_Access_Mapping_Rec;
Begin
   SafeGetMem( P, File_Access_Mapping_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, File_Access_Mapping_Rec_Size, 0 );
      acRecord_Type := tkBegin_File_Access_Mapping;
      acEOR         := tkEnd_File_Access_Mapping;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_File_Access_Mapping_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_File_Access_Mapping_Rec_Dynamic_Fields ( Var O : TFile_Access_Mapping_Rec );

Begin
   If IsAFile_Access_Mapping_Rec ( @O ) then With O do
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
  for i := tkacUser_LRN to tkacAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION File_Access_Mapping_Rec_Delta(P1, P2, P3: pFile_Access_Mapping_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_File_Access_Mapping_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.acUser_LRN <> P2.acUser_LRN) then begin
    P3.acUser_LRN := P1.acUser_LRN;
    ChangedFields[i] := tkacUser_LRN;
    Inc(i);
  end;
  if (P1.acClient_File_LRN <> P2.acClient_File_LRN) then begin
    P3.acClient_File_LRN := P1.acClient_File_LRN;
    ChangedFields[i] := tkacClient_File_LRN;
    Inc(i);
  end;
  if (P1.acAudit_Record_ID <> P2.acAudit_Record_ID) then begin
    P3.acAudit_Record_ID := P1.acAudit_Record_ID;
    ChangedFields[i] := tkacAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_File_Access_Mapping_Rec(P1, P2: pFile_Access_Mapping_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_File_Access_Mapping_Rec(P1^, S);
    S.Position := 0;
    Read_File_Access_Mapping_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
