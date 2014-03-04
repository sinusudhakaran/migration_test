UNIT SYsrIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES SYDEFS, IOSTREAM, SYAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_TPR_Supplier_Detail          = 175 ;
   tkEnd_TPR_Supplier_Detail            = 176 ;

FUNCTION  IsATPR_Supplier_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_TPR_Supplier_Detail_Rec ( Var O : TTPR_Supplier_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_TPR_Supplier_Detail_Rec ( Var O : TTPR_Supplier_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_TPR_Supplier_Detail_Rec : pTPR_Supplier_Detail_Rec ;
PROCEDURE Free_TPR_Supplier_Detail_Rec_Dynamic_Fields ( Var O : TTPR_Supplier_Detail_Rec );
FUNCTION TPR_Supplier_Detail_Rec_Delta(P1, P2, P3: pTPR_Supplier_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_TPR_Supplier_Detail_Rec(P1, P2: pTPR_Supplier_Detail_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'SYSRIO';
   SBoundsError        = 'SYSRIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'SYSRIO Error: Pointer is NIL in IsATPR_Supplier_Detail_Rec';
   SInvalidType        = 'SYSRIO Error: Type is invalid in IsATPR_Supplier_Detail_Rec';
   SInvalidEOR         = 'SYSRIO Error: EOR is missing in IsATPR_Supplier_Detail_Rec';
   SUnknownToken       = 'SYSRIO Error: Unknown token %d in Read_TPR_Supplier_Detail_Rec';
   SInsufficientMemory = 'SYSRIO Error: Out of memory in New_TPR_Supplier_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksrABN                              = 177 ;
   tksrContactName                      = 178 ;
   tksrContactPhone                     = 179 ;
   tksrStreetAddress1                   = 180 ;
   tksrStreetAddress2                   = 181 ;
   tksrSuburb                           = 182 ;
   tksrStateId                          = 183 ;
   tksrCountry                          = 184 ;
   tksrPostCode                         = 185 ;

{  -------------------------------------------------------------------  }

FUNCTION IsATPR_Supplier_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PTPR_Supplier_Detail_Rec ( P )^ do Begin
      If srRecord_Type <> tkBegin_TPR_Supplier_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If srEOR <> tkEnd_TPR_Supplier_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_TPR_Supplier_Detail_Rec ( Var O : TTPR_Supplier_Detail_Rec ; Var F : TIOStream );

Begin
   If IsATPR_Supplier_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_TPR_Supplier_Detail );
      F.WriteStringValue( tksrABN , srABN );
      F.WriteStringValue( tksrContactName , srContactName );
      F.WriteStringValue( tksrContactPhone , srContactPhone );
      F.WriteStringValue( tksrStreetAddress1 , srStreetAddress1 );
      F.WriteStringValue( tksrStreetAddress2 , srStreetAddress2 );
      F.WriteStringValue( tksrSuburb , srSuburb );
      F.WriteIntegerValue( tksrStateId , srStateId );
      F.WriteStringValue( tksrCountry , srCountry );
      F.WriteStringValue( tksrPostCode , srPostCode );
      F.WriteToken( tkEnd_TPR_Supplier_Detail );
   end;
end; { of Write_TPR_Supplier_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_TPR_Supplier_Detail_Rec ( Var O : TTPR_Supplier_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, TPR_Supplier_Detail_Rec_Size, 0 );
   O.srRecord_Type := tkBegin_TPR_Supplier_Detail;
   O.srEOR := tkEnd_TPR_Supplier_Detail;
   Token := tkBegin_TPR_Supplier_Detail;

   While Token <> tkEnd_TPR_Supplier_Detail do With O do
   Begin
      Case Token of
         tkBegin_TPR_Supplier_Detail :; { Do Nothing }
         tkEnd_TPR_Supplier_Detail :; { Do Nothing }
         tksrABN                              : srABN := F.ReadStringValue;
         tksrContactName                      : srContactName := F.ReadStringValue;
         tksrContactPhone                     : srContactPhone := F.ReadStringValue;
         tksrStreetAddress1                   : srStreetAddress1 := F.ReadStringValue;
         tksrStreetAddress2                   : srStreetAddress2 := F.ReadStringValue;
         tksrSuburb                           : srSuburb := F.ReadStringValue;
         tksrStateId                          : srStateId := F.ReadIntegerValue;
         tksrCountry                          : srCountry := F.ReadStringValue;
         tksrPostCode                         : srPostCode := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_TPR_Supplier_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_TPR_Supplier_Detail_Rec : pTPR_Supplier_Detail_Rec ;

Var
   P : pTPR_Supplier_Detail_Rec;
Begin
   SafeGetMem( P, TPR_Supplier_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, TPR_Supplier_Detail_Rec_Size, 0 );
      srRecord_Type := tkBegin_TPR_Supplier_Detail;
      srEOR         := tkEnd_TPR_Supplier_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_TPR_Supplier_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_TPR_Supplier_Detail_Rec_Dynamic_Fields ( Var O : TTPR_Supplier_Detail_Rec );

Begin
   If IsATPR_Supplier_Detail_Rec ( @O ) then With O do
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
  for i := tksrABN to tksrPostCode do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION TPR_Supplier_Detail_Rec_Delta(P1, P2, P3: pTPR_Supplier_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_TPR_Supplier_Detail_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.srABN <> P2.srABN) then begin
    P3.srABN := P1.srABN;
    ChangedFields[i] := tksrABN;
    Inc(i);
  end;
  if (P1.srContactName <> P2.srContactName) then begin
    P3.srContactName := P1.srContactName;
    ChangedFields[i] := tksrContactName;
    Inc(i);
  end;
  if (P1.srContactPhone <> P2.srContactPhone) then begin
    P3.srContactPhone := P1.srContactPhone;
    ChangedFields[i] := tksrContactPhone;
    Inc(i);
  end;
  if (P1.srStreetAddress1 <> P2.srStreetAddress1) then begin
    P3.srStreetAddress1 := P1.srStreetAddress1;
    ChangedFields[i] := tksrStreetAddress1;
    Inc(i);
  end;
  if (P1.srStreetAddress2 <> P2.srStreetAddress2) then begin
    P3.srStreetAddress2 := P1.srStreetAddress2;
    ChangedFields[i] := tksrStreetAddress2;
    Inc(i);
  end;
  if (P1.srSuburb <> P2.srSuburb) then begin
    P3.srSuburb := P1.srSuburb;
    ChangedFields[i] := tksrSuburb;
    Inc(i);
  end;
  if (P1.srStateId <> P2.srStateId) then begin
    P3.srStateId := P1.srStateId;
    ChangedFields[i] := tksrStateId;
    Inc(i);
  end;
  if (P1.srCountry <> P2.srCountry) then begin
    P3.srCountry := P1.srCountry;
    ChangedFields[i] := tksrCountry;
    Inc(i);
  end;
  if (P1.srPostCode <> P2.srPostCode) then begin
    P3.srPostCode := P1.srPostCode;
    ChangedFields[i] := tksrPostCode;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_TPR_Supplier_Detail_Rec(P1, P2: pTPR_Supplier_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_TPR_Supplier_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_TPR_Supplier_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
