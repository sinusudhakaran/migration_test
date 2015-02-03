UNIT BKmsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Mem_Scan_Command             = 169 ;
   tkEnd_Mem_Scan_Command               = 170 ;

FUNCTION  IsAMem_Scan_Command_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Mem_Scan_Command_Rec ( Var O : TMem_Scan_Command_Rec ; Var F : TIOStream );
PROCEDURE Read_Mem_Scan_Command_Rec ( Var O : TMem_Scan_Command_Rec ; Var F : TIOStream );
FUNCTION  New_Mem_Scan_Command_Rec : pMem_Scan_Command_Rec ;
PROCEDURE Free_Mem_Scan_Command_Rec_Dynamic_Fields ( Var O : TMem_Scan_Command_Rec );
FUNCTION Mem_Scan_Command_Rec_Delta(P1, P2, P3: pMem_Scan_Command_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Mem_Scan_Command_Rec(P1, P2: pMem_Scan_Command_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMSIO';
   SBoundsError        = 'BKMSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMSIO Error: Pointer is NIL in IsAMem_Scan_Command_Rec';
   SInvalidType        = 'BKMSIO Error: Type is invalid in IsAMem_Scan_Command_Rec';
   SInvalidEOR         = 'BKMSIO Error: EOR is missing in IsAMem_Scan_Command_Rec';
   SUnknownToken       = 'BKMSIO Error: Unknown token %d in Read_Mem_Scan_Command_Rec';
   SInsufficientMemory = 'BKMSIO Error: Out of memory in New_Mem_Scan_Command_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmsCommand                          = 171 ;
   tkmsSection                          = 172 ;
   tkmsIndex                            = 173 ;
   tkmsSubIndex                         = 174 ;
   tkmsBank_Account_Number              = 175 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMem_Scan_Command_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMem_Scan_Command_Rec ( P )^ do Begin
      If msRecord_Type <> tkBegin_Mem_Scan_Command then
         Raise ECorruptData.Create( SInvalidType );
      If msEOR <> tkEnd_Mem_Scan_Command then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Mem_Scan_Command_Rec ( Var O : TMem_Scan_Command_Rec ; Var F : TIOStream );

Begin
   If IsAMem_Scan_Command_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Mem_Scan_Command );
      F.WriteIntegerValue( tkmsCommand , msCommand );
      F.WriteIntegerValue( tkmsSection , msSection );
      F.WriteIntegerValue( tkmsIndex , msIndex );
      F.WriteIntegerValue( tkmsSubIndex , msSubIndex );
      F.WriteStringValue( tkmsBank_Account_Number , msBank_Account_Number );
      F.WriteToken( tkEnd_Mem_Scan_Command );
   end;
end; { of Write_Mem_Scan_Command_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Mem_Scan_Command_Rec ( Var O : TMem_Scan_Command_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Mem_Scan_Command_Rec_Size, 0 );
   O.msRecord_Type := tkBegin_Mem_Scan_Command;
   O.msEOR := tkEnd_Mem_Scan_Command;
   Token := tkBegin_Mem_Scan_Command;

   While Token <> tkEnd_Mem_Scan_Command do With O do
   Begin
      Case Token of
         tkBegin_Mem_Scan_Command :; { Do Nothing }
         tkEnd_Mem_Scan_Command :; { Do Nothing }
         tkmsCommand                          : msCommand := F.ReadIntegerValue;
         tkmsSection                          : msSection := F.ReadIntegerValue;
         tkmsIndex                            : msIndex := F.ReadIntegerValue;
         tkmsSubIndex                         : msSubIndex := F.ReadIntegerValue;
         tkmsBank_Account_Number              : msBank_Account_Number := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Mem_Scan_Command_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Mem_Scan_Command_Rec : pMem_Scan_Command_Rec ;

Var
   P : pMem_Scan_Command_Rec;
Begin
   SafeGetMem( P, Mem_Scan_Command_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Mem_Scan_Command_Rec_Size, 0 );
      msRecord_Type := tkBegin_Mem_Scan_Command;
      msEOR         := tkEnd_Mem_Scan_Command;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Mem_Scan_Command_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Mem_Scan_Command_Rec_Dynamic_Fields ( Var O : TMem_Scan_Command_Rec );

Begin
   If IsAMem_Scan_Command_Rec ( @O ) then With O do
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
  for i := tkmsCommand to tkmsBank_Account_Number do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Mem_Scan_Command_Rec_Delta(P1, P2, P3: pMem_Scan_Command_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Mem_Scan_Command_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.msCommand <> P2.msCommand) then begin
    P3.msCommand := P1.msCommand;
    ChangedFields[i] := tkmsCommand;
    Inc(i);
  end;
  if (P1.msSection <> P2.msSection) then begin
    P3.msSection := P1.msSection;
    ChangedFields[i] := tkmsSection;
    Inc(i);
  end;
  if (P1.msIndex <> P2.msIndex) then begin
    P3.msIndex := P1.msIndex;
    ChangedFields[i] := tkmsIndex;
    Inc(i);
  end;
  if (P1.msSubIndex <> P2.msSubIndex) then begin
    P3.msSubIndex := P1.msSubIndex;
    ChangedFields[i] := tkmsSubIndex;
    Inc(i);
  end;
  if (P1.msBank_Account_Number <> P2.msBank_Account_Number) then begin
    P3.msBank_Account_Number := P1.msBank_Account_Number;
    ChangedFields[i] := tkmsBank_Account_Number;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Mem_Scan_Command_Rec(P1, P2: pMem_Scan_Command_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Mem_Scan_Command_Rec(P1^, S);
    S.Position := 0;
    Read_Mem_Scan_Command_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
