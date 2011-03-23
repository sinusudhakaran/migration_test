UNIT BKbuIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Budget_Header                = 110 ;
   tkEnd_Budget_Header                  = 111 ;

FUNCTION  IsABudget_Header_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );
PROCEDURE Read_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );
FUNCTION  New_Budget_Header_Rec : pBudget_Header_Rec ;
PROCEDURE Free_Budget_Header_Rec_Dynamic_Fields ( Var O : TBudget_Header_Rec );
FUNCTION Budget_Header_Rec_Delta(P1, P2, P3: pBudget_Header_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Budget_Header_Rec(P1, P2: pBudget_Header_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKBUIO';
   SBoundsError        = 'BKBUIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKBUIO Error: Pointer is NIL in IsABudget_Header_Rec';
   SInvalidType        = 'BKBUIO Error: Type is invalid in IsABudget_Header_Rec';
   SInvalidEOR         = 'BKBUIO Error: EOR is missing in IsABudget_Header_Rec';
   SUnknownToken       = 'BKBUIO Error: Unknown token %d in Read_Budget_Header_Rec';
   SInsufficientMemory = 'BKBUIO Error: Out of memory in New_Budget_Header_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkbuStart_Date                       = 112 ;
   tkbuName                             = 113 ;
   tkbuEstimated_Opening_Bank_Balance   = 114 ;
   tkbuIs_Inclusive                     = 115 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABudget_Header_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBudget_Header_Rec ( P )^ do Begin
      If buRecord_Type <> tkBegin_Budget_Header then
         Raise ECorruptData.Create( SInvalidType );
      If buEOR <> tkEnd_Budget_Header then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Budget_Header_Rec ( Var O : TBudget_Header_Rec ; Var F : TIOStream );

Begin
   If IsABudget_Header_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Budget_Header );
      F.WriteDateValue( tkbuStart_Date , buStart_Date );
      F.WriteStringValue( tkbuName , buName );
      F.WriteMoneyValue( tkbuEstimated_Opening_Bank_Balance , buEstimated_Opening_Bank_Balance );
      F.WriteBooleanValue( tkbuIs_Inclusive , buIs_Inclusive );
      F.WriteToken( tkEnd_Budget_Header );
   end;
end; { of Write_Budget_Header_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Budget_Header_Rec ( Var O : TBudget_Header_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Budget_Header_Rec_Size, 0 );
   O.buRecord_Type := tkBegin_Budget_Header;
   O.buEOR := tkEnd_Budget_Header;
   Token := tkBegin_Budget_Header;

   While Token <> tkEnd_Budget_Header do With O do
   Begin
      Case Token of
         tkBegin_Budget_Header :; { Do Nothing }
         tkEnd_Budget_Header :; { Do Nothing }
         tkbuStart_Date                       : buStart_Date := F.ReadDateValue;
         tkbuName                             : buName := F.ReadStringValue;
         tkbuEstimated_Opening_Bank_Balance   : buEstimated_Opening_Bank_Balance := F.ReadMoneyValue;
         tkbuIs_Inclusive                     : buIs_Inclusive := F.ReadBooleanValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Budget_Header_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Budget_Header_Rec : pBudget_Header_Rec ;

Var
   P : pBudget_Header_Rec;
Begin
   SafeGetMem( P, Budget_Header_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Budget_Header_Rec_Size, 0 );
      buRecord_Type := tkBegin_Budget_Header;
      buEOR         := tkEnd_Budget_Header;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Budget_Header_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Budget_Header_Rec_Dynamic_Fields ( Var O : TBudget_Header_Rec );

Begin
   If IsABudget_Header_Rec ( @O ) then With O do
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
  for i := tkbuStart_Date to tkbuIs_Inclusive do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Budget_Header_Rec_Delta(P1, P2, P3: pBudget_Header_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Budget_Header_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.buStart_Date <> P2.buStart_Date) then begin
    P3.buStart_Date := P1.buStart_Date;
    ChangedFields[i] := tkbuStart_Date;
    Inc(i);
  end;
  if (P1.buName <> P2.buName) then begin
    P3.buName := P1.buName;
    ChangedFields[i] := tkbuName;
    Inc(i);
  end;
  if (P1.buEstimated_Opening_Bank_Balance <> P2.buEstimated_Opening_Bank_Balance) then begin
    P3.buEstimated_Opening_Bank_Balance := P1.buEstimated_Opening_Bank_Balance;
    ChangedFields[i] := tkbuEstimated_Opening_Bank_Balance;
    Inc(i);
  end;
  if (P1.buIs_Inclusive <> P2.buIs_Inclusive) then begin
    P3.buIs_Inclusive := P1.buIs_Inclusive;
    ChangedFields[i] := tkbuIs_Inclusive;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Budget_Header_Rec(P1, P2: pBudget_Header_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Budget_Header_Rec(P1^, S);
    S.Position := 0;
    Read_Budget_Header_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
