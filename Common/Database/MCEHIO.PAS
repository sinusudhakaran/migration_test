UNIT MCehIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES MCDEFS, IOSTREAM, MCAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Exchange_Rates_Header        = 10 ;
   tkEnd_Exchange_Rates_Header          = 11 ;

FUNCTION  IsAExchange_Rates_Header_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Exchange_Rates_Header_Rec ( Var O : TExchange_Rates_Header_Rec ; Var F : TIOStream );
PROCEDURE Read_Exchange_Rates_Header_Rec ( Var O : TExchange_Rates_Header_Rec ; Var F : TIOStream );
FUNCTION  New_Exchange_Rates_Header_Rec : pExchange_Rates_Header_Rec ;
PROCEDURE Free_Exchange_Rates_Header_Rec_Dynamic_Fields ( Var O : TExchange_Rates_Header_Rec );
FUNCTION Exchange_Rates_Header_Rec_Delta(P1, P2, P3: pExchange_Rates_Header_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Exchange_Rates_Header_Rec(P1, P2: pExchange_Rates_Header_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'MCEHIO';
   SBoundsError        = 'MCEHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'MCEHIO Error: Pointer is NIL in IsAExchange_Rates_Header_Rec';
   SInvalidType        = 'MCEHIO Error: Type is invalid in IsAExchange_Rates_Header_Rec';
   SInvalidEOR         = 'MCEHIO Error: EOR is missing in IsAExchange_Rates_Header_Rec';
   SUnknownToken       = 'MCEHIO Error: Unknown token %d in Read_Exchange_Rates_Header_Rec';
   SInsufficientMemory = 'MCEHIO Error: Out of memory in New_Exchange_Rates_Header_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkehFile_Version                     = 12 ;
   tkehLRN                              = 13 ;
   tkehName                             = 14 ;
   tkehList_Type                        = 15 ;
   tkehISO_Codes                        = 16 ;
   tkehCur_Type                         = 17 ;
   tkehAudit_Record_ID                  = 18 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAExchange_Rates_Header_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PExchange_Rates_Header_Rec ( P )^ do Begin
      If ehRecord_Type <> tkBegin_Exchange_Rates_Header then
         Raise ECorruptData.Create( SInvalidType );
      If ehEOR <> tkEnd_Exchange_Rates_Header then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Exchange_Rates_Header_Rec ( Var O : TExchange_Rates_Header_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAExchange_Rates_Header_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Exchange_Rates_Header );
      F.WriteIntegerValue( tkehFile_Version , ehFile_Version );
      F.WriteIntegerValue( tkehLRN , ehLRN );
      F.WriteStringValue( tkehName , ehName );
      F.WriteByteValue( tkehList_Type , ehList_Type );
      For i := 1 to 99 do F.WriteBStringValue( tkehISO_Codes , i, ehISO_Codes[ i ] );
      For i := 1 to 99 do F.WriteBByteValue( tkehCur_Type , i, ehCur_Type[ i ] );
      F.WriteIntegerValue( tkehAudit_Record_ID , ehAudit_Record_ID );
      F.WriteToken( tkEnd_Exchange_Rates_Header );
   end;
end; { of Write_Exchange_Rates_Header_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Exchange_Rates_Header_Rec ( Var O : TExchange_Rates_Header_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   B     : Byte;   
   S     : ShortString;

Begin
   FillChar( O, Exchange_Rates_Header_Rec_Size, 0 );
   O.ehRecord_Type := tkBegin_Exchange_Rates_Header;
   O.ehEOR := tkEnd_Exchange_Rates_Header;
   Token := tkBegin_Exchange_Rates_Header;

   While Token <> tkEnd_Exchange_Rates_Header do With O do
   Begin
      Case Token of
         tkBegin_Exchange_Rates_Header :; { Do Nothing }
         tkEnd_Exchange_Rates_Header :; { Do Nothing }
         tkehFile_Version                     : ehFile_Version := F.ReadIntegerValue;
         tkehLRN                              : ehLRN := F.ReadIntegerValue;
         tkehName                             : ehName := F.ReadStringValue;
         tkehList_Type                        : ehList_Type := F.ReadByteValue;
         tkehISO_Codes                        : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 99, 'ehISO_Codes' );
               ehISO_Codes[ I ] := S;
            end;
         tkehCur_Type                         : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 99, 'ehCur_Type' );
               ehCur_Type[ I ] := B;
            end;
         tkehAudit_Record_ID                  : ehAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Exchange_Rates_Header_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Exchange_Rates_Header_Rec : pExchange_Rates_Header_Rec ;

Var
   P : pExchange_Rates_Header_Rec;
Begin
   SafeGetMem( P, Exchange_Rates_Header_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Exchange_Rates_Header_Rec_Size, 0 );
      ehRecord_Type := tkBegin_Exchange_Rates_Header;
      ehEOR         := tkEnd_Exchange_Rates_Header;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Exchange_Rates_Header_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Exchange_Rates_Header_Rec_Dynamic_Fields ( Var O : TExchange_Rates_Header_Rec );

Begin
   If IsAExchange_Rates_Header_Rec ( @O ) then With O do
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
  for i := tkehFile_Version to tkehAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Exchange_Rates_Header_Rec_Delta(P1, P2, P3: pExchange_Rates_Header_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Exchange_Rates_Header_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.ehFile_Version <> P2.ehFile_Version) then begin
    P3.ehFile_Version := P1.ehFile_Version;
    ChangedFields[i] := tkehFile_Version;
    Inc(i);
  end;
  if (P1.ehLRN <> P2.ehLRN) then begin
    P3.ehLRN := P1.ehLRN;
    ChangedFields[i] := tkehLRN;
    Inc(i);
  end;
  if (P1.ehName <> P2.ehName) then begin
    P3.ehName := P1.ehName;
    ChangedFields[i] := tkehName;
    Inc(i);
  end;
  if (P1.ehList_Type <> P2.ehList_Type) then begin
    P3.ehList_Type := P1.ehList_Type;
    ChangedFields[i] := tkehList_Type;
    Inc(i);
  end;
  if ISO_Codes_Changed(TISO_Codes_Array(P1.ehISO_Codes), 
                  TISO_Codes_Array(P2.ehISO_Codes), 
                  TISO_Codes_Array(P3.ehISO_Codes)) then begin
    ChangedFields[i] := tkehISO_Codes;
    Inc(i);
  end;
  if Cur_Type_Changed(TCur_Type_Array(P1.ehCur_Type), 
                  TCur_Type_Array(P2.ehCur_Type), 
                  TCur_Type_Array(P3.ehCur_Type)) then begin
    ChangedFields[i] := tkehCur_Type;
    Inc(i);
  end;
  if (P1.ehAudit_Record_ID <> P2.ehAudit_Record_ID) then begin
    P3.ehAudit_Record_ID := P1.ehAudit_Record_ID;
    ChangedFields[i] := tkehAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Exchange_Rates_Header_Rec(P1, P2: pExchange_Rates_Header_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Exchange_Rates_Header_Rec(P1^, S);
    S.Position := 0;
    Read_Exchange_Rates_Header_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
