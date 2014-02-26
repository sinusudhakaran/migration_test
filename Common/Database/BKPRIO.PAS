UNIT BKprIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_TPR_Payer_Detail             = 185 ;
   tkEnd_TPR_Payer_Detail               = 186 ;

FUNCTION  IsATPR_Payer_Detail_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_TPR_Payer_Detail_Rec ( Var O : TTPR_Payer_Detail_Rec ; Var F : TIOStream );
PROCEDURE Read_TPR_Payer_Detail_Rec ( Var O : TTPR_Payer_Detail_Rec ; Var F : TIOStream );
FUNCTION  New_TPR_Payer_Detail_Rec : pTPR_Payer_Detail_Rec ;
PROCEDURE Free_TPR_Payer_Detail_Rec_Dynamic_Fields ( Var O : TTPR_Payer_Detail_Rec );
FUNCTION TPR_Payer_Detail_Rec_Delta(P1, P2, P3: pTPR_Payer_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_TPR_Payer_Detail_Rec(P1, P2: pTPR_Payer_Detail_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPRIO';
   SBoundsError        = 'BKPRIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPRIO Error: Pointer is NIL in IsATPR_Payer_Detail_Rec';
   SInvalidType        = 'BKPRIO Error: Type is invalid in IsATPR_Payer_Detail_Rec';
   SInvalidEOR         = 'BKPRIO Error: EOR is missing in IsATPR_Payer_Detail_Rec';
   SUnknownToken       = 'BKPRIO Error: Unknown token %d in Read_TPR_Payer_Detail_Rec';
   SInsufficientMemory = 'BKPRIO Error: Out of memory in New_TPR_Payer_Detail_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkprPracContactName                  = 187 ;
   tkprPracContactPhone                 = 188 ;
   tkprPracEmailAddress                 = 189 ;
   tkprTradingName                      = 190 ;
   tkprSuburb                           = 191 ;
   tkprStateId                          = 192 ;
   tkprCountry                          = 193 ;
   tkprBSB                              = 194 ;
   tkprAccount                          = 195 ;

{  -------------------------------------------------------------------  }

FUNCTION IsATPR_Payer_Detail_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PTPR_Payer_Detail_Rec ( P )^ do Begin
      If prRecord_Type <> tkBegin_TPR_Payer_Detail then
         Raise ECorruptData.Create( SInvalidType );
      If prEOR <> tkEnd_TPR_Payer_Detail then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_TPR_Payer_Detail_Rec ( Var O : TTPR_Payer_Detail_Rec ; Var F : TIOStream );

Begin
   If IsATPR_Payer_Detail_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_TPR_Payer_Detail );
      F.WriteStringValue( tkprPracContactName , prPracContactName );
      F.WriteStringValue( tkprPracContactPhone , prPracContactPhone );
      F.WriteStringValue( tkprPracEmailAddress , prPracEmailAddress );
      F.WriteStringValue( tkprTradingName , prTradingName );
      F.WriteStringValue( tkprSuburb , prSuburb );
      F.WriteIntegerValue( tkprStateId , prStateId );
      F.WriteStringValue( tkprCountry , prCountry );
      F.WriteStringValue( tkprBSB , prBSB );
      F.WriteStringValue( tkprAccount , prAccount );
      F.WriteToken( tkEnd_TPR_Payer_Detail );
   end;
end; { of Write_TPR_Payer_Detail_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_TPR_Payer_Detail_Rec ( Var O : TTPR_Payer_Detail_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, TPR_Payer_Detail_Rec_Size, 0 );
   O.prRecord_Type := tkBegin_TPR_Payer_Detail;
   O.prEOR := tkEnd_TPR_Payer_Detail;
   Token := tkBegin_TPR_Payer_Detail;

   While Token <> tkEnd_TPR_Payer_Detail do With O do
   Begin
      Case Token of
         tkBegin_TPR_Payer_Detail :; { Do Nothing }
         tkEnd_TPR_Payer_Detail :; { Do Nothing }
         tkprPracContactName                  : prPracContactName := F.ReadStringValue;
         tkprPracContactPhone                 : prPracContactPhone := F.ReadStringValue;
         tkprPracEmailAddress                 : prPracEmailAddress := F.ReadStringValue;
         tkprTradingName                      : prTradingName := F.ReadStringValue;
         tkprSuburb                           : prSuburb := F.ReadStringValue;
         tkprStateId                          : prStateId := F.ReadIntegerValue;
         tkprCountry                          : prCountry := F.ReadStringValue;
         tkprBSB                              : prBSB := F.ReadStringValue;
         tkprAccount                          : prAccount := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_TPR_Payer_Detail_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_TPR_Payer_Detail_Rec : pTPR_Payer_Detail_Rec ;

Var
   P : pTPR_Payer_Detail_Rec;
Begin
   SafeGetMem( P, TPR_Payer_Detail_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, TPR_Payer_Detail_Rec_Size, 0 );
      prRecord_Type := tkBegin_TPR_Payer_Detail;
      prEOR         := tkEnd_TPR_Payer_Detail;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_TPR_Payer_Detail_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_TPR_Payer_Detail_Rec_Dynamic_Fields ( Var O : TTPR_Payer_Detail_Rec );

Begin
   If IsATPR_Payer_Detail_Rec ( @O ) then With O do
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
  for i := tkprPracContactName to tkprAccount do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION TPR_Payer_Detail_Rec_Delta(P1, P2, P3: pTPR_Payer_Detail_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_TPR_Payer_Detail_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.prPracContactName <> P2.prPracContactName) then begin
    P3.prPracContactName := P1.prPracContactName;
    ChangedFields[i] := tkprPracContactName;
    Inc(i);
  end;
  if (P1.prPracContactPhone <> P2.prPracContactPhone) then begin
    P3.prPracContactPhone := P1.prPracContactPhone;
    ChangedFields[i] := tkprPracContactPhone;
    Inc(i);
  end;
  if (P1.prPracEmailAddress <> P2.prPracEmailAddress) then begin
    P3.prPracEmailAddress := P1.prPracEmailAddress;
    ChangedFields[i] := tkprPracEmailAddress;
    Inc(i);
  end;
  if (P1.prTradingName <> P2.prTradingName) then begin
    P3.prTradingName := P1.prTradingName;
    ChangedFields[i] := tkprTradingName;
    Inc(i);
  end;
  if (P1.prSuburb <> P2.prSuburb) then begin
    P3.prSuburb := P1.prSuburb;
    ChangedFields[i] := tkprSuburb;
    Inc(i);
  end;
  if (P1.prStateId <> P2.prStateId) then begin
    P3.prStateId := P1.prStateId;
    ChangedFields[i] := tkprStateId;
    Inc(i);
  end;
  if (P1.prCountry <> P2.prCountry) then begin
    P3.prCountry := P1.prCountry;
    ChangedFields[i] := tkprCountry;
    Inc(i);
  end;
  if (P1.prBSB <> P2.prBSB) then begin
    P3.prBSB := P1.prBSB;
    ChangedFields[i] := tkprBSB;
    Inc(i);
  end;
  if (P1.prAccount <> P2.prAccount) then begin
    P3.prAccount := P1.prAccount;
    ChangedFields[i] := tkprAccount;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_TPR_Payer_Detail_Rec(P1, P2: pTPR_Payer_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_TPR_Payer_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_TPR_Payer_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
