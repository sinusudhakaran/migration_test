UNIT BKglIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Exchange_Gain_Loss           = 202 ;
   tkEnd_Exchange_Gain_Loss             = 203 ;

FUNCTION  IsAExchange_Gain_Loss_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Exchange_Gain_Loss_Rec ( Var O : TExchange_Gain_Loss_Rec ; Var F : TIOStream );
PROCEDURE Read_Exchange_Gain_Loss_Rec ( Var O : TExchange_Gain_Loss_Rec ; Var F : TIOStream );
FUNCTION  New_Exchange_Gain_Loss_Rec : pExchange_Gain_Loss_Rec ;
PROCEDURE Free_Exchange_Gain_Loss_Rec_Dynamic_Fields ( Var O : TExchange_Gain_Loss_Rec );
FUNCTION Exchange_Gain_Loss_Rec_Delta(P1, P2, P3: pExchange_Gain_Loss_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Exchange_Gain_Loss_Rec(P1, P2: pExchange_Gain_Loss_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKGLIO';
   SBoundsError        = 'BKGLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKGLIO Error: Pointer is NIL in IsAExchange_Gain_Loss_Rec';
   SInvalidType        = 'BKGLIO Error: Type is invalid in IsAExchange_Gain_Loss_Rec';
   SInvalidEOR         = 'BKGLIO Error: EOR is missing in IsAExchange_Gain_Loss_Rec';
   SUnknownToken       = 'BKGLIO Error: Unknown token %d in Read_Exchange_Gain_Loss_Rec';
   SInsufficientMemory = 'BKGLIO Error: Out of memory in New_Exchange_Gain_Loss_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkglDate                             = 204 ;
   tkglAmount                           = 205 ;
   tkglAccount                          = 206 ;
   tkglPosted_Date                      = 207 ;
   tkglAudit_Record_ID                  = 208 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAExchange_Gain_Loss_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PExchange_Gain_Loss_Rec ( P )^ do Begin
      If glRecord_Type <> tkBegin_Exchange_Gain_Loss then
         Raise ECorruptData.Create( SInvalidType );
      If glEOR <> tkEnd_Exchange_Gain_Loss then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Exchange_Gain_Loss_Rec ( Var O : TExchange_Gain_Loss_Rec ; Var F : TIOStream );

Begin
   If IsAExchange_Gain_Loss_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Exchange_Gain_Loss );
      F.WriteDateValue( tkglDate , glDate );
      F.WriteMoneyValue( tkglAmount , glAmount );
      F.WriteStringValue( tkglAccount , glAccount );
      F.WriteDateValue( tkglPosted_Date , glPosted_Date );
      F.WriteIntegerValue( tkglAudit_Record_ID , glAudit_Record_ID );
      F.WriteToken( tkEnd_Exchange_Gain_Loss );
   end;
end; { of Write_Exchange_Gain_Loss_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Exchange_Gain_Loss_Rec ( Var O : TExchange_Gain_Loss_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Exchange_Gain_Loss_Rec_Size, 0 );
   O.glRecord_Type := tkBegin_Exchange_Gain_Loss;
   O.glEOR := tkEnd_Exchange_Gain_Loss;
   Token := tkBegin_Exchange_Gain_Loss;

   While Token <> tkEnd_Exchange_Gain_Loss do With O do
   Begin
      Case Token of
         tkBegin_Exchange_Gain_Loss :; { Do Nothing }
         tkEnd_Exchange_Gain_Loss :; { Do Nothing }
         tkglDate                             : glDate := F.ReadDateValue;
         tkglAmount                           : glAmount := F.ReadMoneyValue;
         tkglAccount                          : glAccount := F.ReadStringValue;
         tkglPosted_Date                      : glPosted_Date := F.ReadDateValue;
         tkglAudit_Record_ID                  : glAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Exchange_Gain_Loss_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Exchange_Gain_Loss_Rec : pExchange_Gain_Loss_Rec ;

Var
   P : pExchange_Gain_Loss_Rec;
Begin
   SafeGetMem( P, Exchange_Gain_Loss_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Exchange_Gain_Loss_Rec_Size, 0 );
      glRecord_Type := tkBegin_Exchange_Gain_Loss;
      glEOR         := tkEnd_Exchange_Gain_Loss;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Exchange_Gain_Loss_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Exchange_Gain_Loss_Rec_Dynamic_Fields ( Var O : TExchange_Gain_Loss_Rec );

Begin
   If IsAExchange_Gain_Loss_Rec ( @O ) then With O do
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
  for i := tkglDate to tkglAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Exchange_Gain_Loss_Rec_Delta(P1, P2, P3: pExchange_Gain_Loss_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Exchange_Gain_Loss_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.glDate <> P2.glDate) then begin
    P3.glDate := P1.glDate;
    ChangedFields[i] := tkglDate;
    Inc(i);
  end;
  if (P1.glAmount <> P2.glAmount) then begin
    P3.glAmount := P1.glAmount;
    ChangedFields[i] := tkglAmount;
    Inc(i);
  end;
  if (P1.glAccount <> P2.glAccount) then begin
    P3.glAccount := P1.glAccount;
    ChangedFields[i] := tkglAccount;
    Inc(i);
  end;
  if (P1.glPosted_Date <> P2.glPosted_Date) then begin
    P3.glPosted_Date := P1.glPosted_Date;
    ChangedFields[i] := tkglPosted_Date;
    Inc(i);
  end;
  if (P1.glAudit_Record_ID <> P2.glAudit_Record_ID) then begin
    P3.glAudit_Record_ID := P1.glAudit_Record_ID;
    ChangedFields[i] := tkglAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Exchange_Gain_Loss_Rec(P1, P2: pExchange_Gain_Loss_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Exchange_Gain_Loss_Rec(P1^, S);
    S.Position := 0;
    Read_Exchange_Gain_Loss_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
