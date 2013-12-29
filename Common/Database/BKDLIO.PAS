UNIT BKdlIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Disk_Log                     = 130 ;
   tkEnd_Disk_Log                       = 131 ;

FUNCTION  IsADisk_Log_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Disk_Log_Rec ( Var O : TDisk_Log_Rec ; Var F : TIOStream );
PROCEDURE Read_Disk_Log_Rec ( Var O : TDisk_Log_Rec ; Var F : TIOStream );
FUNCTION  New_Disk_Log_Rec : pDisk_Log_Rec ;
PROCEDURE Free_Disk_Log_Rec_Dynamic_Fields ( Var O : TDisk_Log_Rec );
FUNCTION Disk_Log_Rec_Delta(P1, P2, P3: pDisk_Log_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Disk_Log_Rec(P1, P2: pDisk_Log_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKDLIO';
   SBoundsError        = 'BKDLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKDLIO Error: Pointer is NIL in IsADisk_Log_Rec';
   SInvalidType        = 'BKDLIO Error: Type is invalid in IsADisk_Log_Rec';
   SInvalidEOR         = 'BKDLIO Error: EOR is missing in IsADisk_Log_Rec';
   SUnknownToken       = 'BKDLIO Error: Unknown token %d in Read_Disk_Log_Rec';
   SInsufficientMemory = 'BKDLIO Error: Out of memory in New_Disk_Log_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdlDisk_ID                          = 132 ;
   tkdlDate_Downloaded                  = 133 ;
   tkdlNo_of_Accounts                   = 134 ;
   tkdlNo_of_Entries                    = 135 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADisk_Log_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PDisk_Log_Rec ( P )^ do Begin
      If dlRecord_Type <> tkBegin_Disk_Log then
         Raise ECorruptData.Create( SInvalidType );
      If dlEOR <> tkEnd_Disk_Log then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Disk_Log_Rec ( Var O : TDisk_Log_Rec ; Var F : TIOStream );

Begin
   If IsADisk_Log_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Disk_Log );
      F.WriteStringValue( tkdlDisk_ID , dlDisk_ID );
      F.WriteDateValue( tkdlDate_Downloaded , dlDate_Downloaded );
      F.WriteIntegerValue( tkdlNo_of_Accounts , dlNo_of_Accounts );
      F.WriteIntegerValue( tkdlNo_of_Entries , dlNo_of_Entries );
      F.WriteToken( tkEnd_Disk_Log );
   end;
end; { of Write_Disk_Log_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Disk_Log_Rec ( Var O : TDisk_Log_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Disk_Log_Rec_Size, 0 );
   O.dlRecord_Type := tkBegin_Disk_Log;
   O.dlEOR := tkEnd_Disk_Log;
   Token := tkBegin_Disk_Log;

   While Token <> tkEnd_Disk_Log do With O do
   Begin
      Case Token of
         tkBegin_Disk_Log :; { Do Nothing }
         tkEnd_Disk_Log :; { Do Nothing }
         tkdlDisk_ID                          : dlDisk_ID := F.ReadStringValue;
         tkdlDate_Downloaded                  : dlDate_Downloaded := F.ReadDateValue;
         tkdlNo_of_Accounts                   : dlNo_of_Accounts := F.ReadIntegerValue;
         tkdlNo_of_Entries                    : dlNo_of_Entries := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Disk_Log_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Disk_Log_Rec : pDisk_Log_Rec ;

Var
   P : pDisk_Log_Rec;
Begin
   SafeGetMem( P, Disk_Log_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Disk_Log_Rec_Size, 0 );
      dlRecord_Type := tkBegin_Disk_Log;
      dlEOR         := tkEnd_Disk_Log;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Disk_Log_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Disk_Log_Rec_Dynamic_Fields ( Var O : TDisk_Log_Rec );

Begin
   If IsADisk_Log_Rec ( @O ) then With O do
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
  for i := tkdlDisk_ID to tkdlNo_of_Entries do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Disk_Log_Rec_Delta(P1, P2, P3: pDisk_Log_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Disk_Log_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.dlDisk_ID <> P2.dlDisk_ID) then begin
    P3.dlDisk_ID := P1.dlDisk_ID;
    ChangedFields[i] := tkdlDisk_ID;
    Inc(i);
  end;
  if (P1.dlDate_Downloaded <> P2.dlDate_Downloaded) then begin
    P3.dlDate_Downloaded := P1.dlDate_Downloaded;
    ChangedFields[i] := tkdlDate_Downloaded;
    Inc(i);
  end;
  if (P1.dlNo_of_Accounts <> P2.dlNo_of_Accounts) then begin
    P3.dlNo_of_Accounts := P1.dlNo_of_Accounts;
    ChangedFields[i] := tkdlNo_of_Accounts;
    Inc(i);
  end;
  if (P1.dlNo_of_Entries <> P2.dlNo_of_Entries) then begin
    P3.dlNo_of_Entries := P1.dlNo_of_Entries;
    ChangedFields[i] := tkdlNo_of_Entries;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Disk_Log_Rec(P1, P2: pDisk_Log_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Disk_Log_Rec(P1^, S);
    S.Position := 0;
    Read_Disk_Log_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
