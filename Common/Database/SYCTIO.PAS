UNIT SYctIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Client_Type                  = 120 ;
   tkEnd_Client_Type                    = 121 ;

FUNCTION  IsAClient_Type_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );
PROCEDURE Read_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );
FUNCTION  New_Client_Type_Rec : pClient_Type_Rec ;
PROCEDURE Free_Client_Type_Rec_Dynamic_Fields ( Var O : TClient_Type_Rec );
FUNCTION Client_Type_Rec_Delta(P1, P2, P3: pClient_Type_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Client_Type_Rec(P1, P2: pClient_Type_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYCTIO';
   SBoundsError        = 'SYCTIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYCTIO Error: Pointer is NIL in IsAClient_Type_Rec';
   SInvalidType        = 'SYCTIO Error: Type is invalid in IsAClient_Type_Rec';
   SInvalidEOR         = 'SYCTIO Error: EOR is missing in IsAClient_Type_Rec';
   SUnknownToken       = 'SYCTIO Error: Unknown token %d in Read_Client_Type_Rec';
   SInsufficientMemory = 'SYCTIO Error: Out of memory in New_Client_Type_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkctLRN                              = 122 ;
   tkctName                             = 123 ;
   tkctAudit_Record_ID                  = 124 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClient_Type_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClient_Type_Rec ( P )^ do Begin
      If ctRecord_Type <> tkBegin_Client_Type then
         Raise ECorruptData.Create( SInvalidType );
      If ctEOR <> tkEnd_Client_Type then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Client_Type_Rec ( Var O : TClient_Type_Rec ; Var F : TIOStream );

Begin
   If IsAClient_Type_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Client_Type );
      F.WriteIntegerValue( tkctLRN , ctLRN );
      F.WriteStringValue( tkctName , ctName );
      F.WriteIntegerValue( tkctAudit_Record_ID , ctAudit_Record_ID );
      F.WriteToken( tkEnd_Client_Type );
   end;
end; { of Write_Client_Type_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Client_Type_Rec ( Var O : TClient_Type_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Client_Type_Rec_Size, 0 );
   O.ctRecord_Type := tkBegin_Client_Type;
   O.ctEOR := tkEnd_Client_Type;
   Token := tkBegin_Client_Type;

   While Token <> tkEnd_Client_Type do With O do
   Begin
      Case Token of
         tkBegin_Client_Type :; { Do Nothing }
         tkEnd_Client_Type :; { Do Nothing }
         tkctLRN                              : ctLRN := F.ReadIntegerValue;
         tkctName                             : ctName := F.ReadStringValue;
         tkctAudit_Record_ID                  : ctAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Client_Type_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Client_Type_Rec : pClient_Type_Rec ;

Var
   P : pClient_Type_Rec;
Begin
   SafeGetMem( P, Client_Type_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Client_Type_Rec_Size, 0 );
      ctRecord_Type := tkBegin_Client_Type;
      ctEOR         := tkEnd_Client_Type;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Client_Type_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Client_Type_Rec_Dynamic_Fields ( Var O : TClient_Type_Rec );

Begin
   If IsAClient_Type_Rec ( @O ) then With O do
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
  for i := tkctLRN to tkctAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Client_Type_Rec_Delta(P1, P2, P3: pClient_Type_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Client_Type_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.ctLRN <> P2.ctLRN) then begin
    P3.ctLRN := P1.ctLRN;
    ChangedFields[i] := tkctLRN;
    Inc(i);
  end;
  if (P1.ctName <> P2.ctName) then begin
    P3.ctName := P1.ctName;
    ChangedFields[i] := tkctName;
    Inc(i);
  end;
  if (P1.ctAudit_Record_ID <> P2.ctAudit_Record_ID) then begin
    P3.ctAudit_Record_ID := P1.ctAudit_Record_ID;
    ChangedFields[i] := tkctAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Client_Type_Rec(P1, P2: pClient_Type_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Client_Type_Rec(P1^, S);
    S.Position := 0;
    Read_Client_Type_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
