UNIT BKsaIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Suggested_Account            = 172 ;
   tkEnd_Suggested_Account              = 173 ;

FUNCTION  IsASuggested_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Suggested_Account_Rec ( Var O : TSuggested_Account_Rec ; Var F : TIOStream );
PROCEDURE Read_Suggested_Account_Rec ( Var O : TSuggested_Account_Rec ; Var F : TIOStream );
FUNCTION  New_Suggested_Account_Rec : pSuggested_Account_Rec ;
PROCEDURE Free_Suggested_Account_Rec_Dynamic_Fields ( Var O : TSuggested_Account_Rec );
FUNCTION Suggested_Account_Rec_Delta(P1, P2, P3: pSuggested_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Suggested_Account_Rec(P1, P2: pSuggested_Account_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKSAIO';
   SBoundsError        = 'BKSAIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKSAIO Error: Pointer is NIL in IsASuggested_Account_Rec';
   SInvalidType        = 'BKSAIO Error: Type is invalid in IsASuggested_Account_Rec';
   SInvalidEOR         = 'BKSAIO Error: EOR is missing in IsASuggested_Account_Rec';
   SUnknownToken       = 'BKSAIO Error: Unknown token %d in Read_Suggested_Account_Rec';
   SInsufficientMemory = 'BKSAIO Error: Out of memory in New_Suggested_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tksaId                               = 174 ;
   tksaAccount                          = 175 ;

{  -------------------------------------------------------------------  }

FUNCTION IsASuggested_Account_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PSuggested_Account_Rec ( P )^ do Begin
      If saRecord_Type <> tkBegin_Suggested_Account then
         Raise ECorruptData.Create( SInvalidType );
      If saEOR <> tkEnd_Suggested_Account then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Suggested_Account_Rec ( Var O : TSuggested_Account_Rec ; Var F : TIOStream );

Begin
   If IsASuggested_Account_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Suggested_Account );
      F.WriteIntegerValue( tksaId , saId );
      F.WriteStringValue( tksaAccount , saAccount );
      F.WriteToken( tkEnd_Suggested_Account );
   end;
end; { of Write_Suggested_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Suggested_Account_Rec ( Var O : TSuggested_Account_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Suggested_Account_Rec_Size, 0 );
   O.saRecord_Type := tkBegin_Suggested_Account;
   O.saEOR := tkEnd_Suggested_Account;
   Token := tkBegin_Suggested_Account;

   While Token <> tkEnd_Suggested_Account do With O do
   Begin
      Case Token of
         tkBegin_Suggested_Account :; { Do Nothing }
         tkEnd_Suggested_Account :; { Do Nothing }
         tksaId                               : saId := F.ReadIntegerValue;
         tksaAccount                          : saAccount := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Suggested_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Suggested_Account_Rec : pSuggested_Account_Rec ;

Var
   P : pSuggested_Account_Rec;
Begin
   SafeGetMem( P, Suggested_Account_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Suggested_Account_Rec_Size, 0 );
      saRecord_Type := tkBegin_Suggested_Account;
      saEOR         := tkEnd_Suggested_Account;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Suggested_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Suggested_Account_Rec_Dynamic_Fields ( Var O : TSuggested_Account_Rec );

Begin
   If IsASuggested_Account_Rec ( @O ) then With O do
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
  for i := tksaId to tksaAccount do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Suggested_Account_Rec_Delta(P1, P2, P3: pSuggested_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Suggested_Account_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.saId <> P2.saId) then begin
    P3.saId := P1.saId;
    ChangedFields[i] := tksaId;
    Inc(i);
  end;
  if (P1.saAccount <> P2.saAccount) then begin
    P3.saAccount := P1.saAccount;
    ChangedFields[i] := tksaAccount;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Suggested_Account_Rec(P1, P2: pSuggested_Account_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Suggested_Account_Rec(P1^, S);
    S.Position := 0;
    Read_Suggested_Account_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
