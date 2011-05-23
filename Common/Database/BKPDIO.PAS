UNIT BKpdIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Detail                 = 90 ;
   tkEnd_Payee_Detail                   = 91 ;

FUNCTION  IsAPayee_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Detail_Rec : pPayee_Detail_Rec ;
PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );
FUNCTION Payee_Detail_Rec_Delta(P1, P2, P3: pPayee_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Payee_Detail_Rec(P1, P2: pPayee_Detail_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPDIO';
   SBoundsError        = 'BKPDIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPDIO Error: Pointer is NIL in IsAPayee_Detail_Rec';
   SInvalidType        = 'BKPDIO Error: Type is invalid in IsAPayee_Detail_Rec';
   SInvalidEOR         = 'BKPDIO Error: EOR is missing in IsAPayee_Detail_Rec';
   SUnknownToken       = 'BKPDIO Error: Unknown token %d in Read_Payee_Detail_Rec';
   SInsufficientMemory = 'BKPDIO Error: Out of memory in New_Payee_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpdNumber                           = 92 ;
   tkpdName                             = 93 ;
   tkpdAudit_Record_ID                  = 94 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Detail_Rec ( P )^ do Begin
      If pdRecord_Type <> tkBegin_Payee_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If pdEOR <> tkEnd_Payee_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Detail );
      F.WriteIntegerValue( tkpdNumber , pdNumber );
      F.WriteStringValue( tkpdName , pdName );
      F.WriteIntegerValue( tkpdAudit_Record_ID , pdAudit_Record_ID );
      F.WriteToken( tkEnd_Payee_Detail );
   end;
end; { of Write_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Detail_Rec ( Var O : TPayee_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Detail_Rec_Size, 0 );
   O.pdRecord_Type := tkBegin_Payee_Detail;
   O.pdEOR := tkEnd_Payee_Detail;
   Token := tkBegin_Payee_Detail;

   While Token <> tkEnd_Payee_Detail do With O do
   Begin
      Case Token of
         tkBegin_Payee_Detail :; { Do Nothing }
         tkEnd_Payee_Detail :; { Do Nothing }
         tkpdNumber                           : pdNumber := F.ReadIntegerValue;
         tkpdName                             : pdName := F.ReadStringValue;
         tkpdAudit_Record_ID                  : pdAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Detail_Rec : pPayee_Detail_Rec ;

Var
   P : pPayee_Detail_Rec;
Begin
   SafeGetMem( P, Payee_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Detail_Rec_Size, 0 );
      pdRecord_Type := tkBegin_Payee_Detail;
      pdEOR         := tkEnd_Payee_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Detail_Rec_Dynamic_Fields ( Var O : TPayee_Detail_Rec );

Begin
   If IsAPayee_Detail_Rec ( @O ) then With O do
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
  for i := tkpdNumber to tkpdAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Payee_Detail_Rec_Delta(P1, P2, P3: pPayee_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Payee_Detail_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.pdNumber <> P2.pdNumber) then begin
    P3.pdNumber := P1.pdNumber;
    ChangedFields[i] := tkpdNumber;
    Inc(i);
  end;
  if (P1.pdName <> P2.pdName) then begin
    P3.pdName := P1.pdName;
    ChangedFields[i] := tkpdName;
    Inc(i);
  end;
  if (P1.pdAudit_Record_ID <> P2.pdAudit_Record_ID) then begin
    P3.pdAudit_Record_ID := P1.pdAudit_Record_ID;
    ChangedFields[i] := tkpdAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Payee_Detail_Rec(P1, P2: pPayee_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Payee_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_Payee_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
