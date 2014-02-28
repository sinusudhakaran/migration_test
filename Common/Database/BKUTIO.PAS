UNIT BKutIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Unscanned_Transaction        = 165 ;
   tkEnd_Unscanned_Transaction          = 166 ;

FUNCTION  IsAUnscanned_Transaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Unscanned_Transaction_Rec ( Var O : TUnscanned_Transaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Unscanned_Transaction_Rec ( Var O : TUnscanned_Transaction_Rec ; Var F : TIOStream );
FUNCTION  New_Unscanned_Transaction_Rec : pUnscanned_Transaction_Rec ;
PROCEDURE Free_Unscanned_Transaction_Rec_Dynamic_Fields ( Var O : TUnscanned_Transaction_Rec );
FUNCTION Unscanned_Transaction_Rec_Delta(P1, P2, P3: pUnscanned_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Unscanned_Transaction_Rec(P1, P2: pUnscanned_Transaction_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKUTIO';
   SBoundsError        = 'BKUTIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKUTIO Error: Pointer is NIL in IsAUnscanned_Transaction_Rec';
   SInvalidType        = 'BKUTIO Error: Type is invalid in IsAUnscanned_Transaction_Rec';
   SInvalidEOR         = 'BKUTIO Error: EOR is missing in IsAUnscanned_Transaction_Rec';
   SUnknownToken       = 'BKUTIO Error: Unknown token %d in Read_Unscanned_Transaction_Rec';
   SInsufficientMemory = 'BKUTIO Error: Out of memory in New_Unscanned_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkutBank_Account_Number              = 167 ;
   tkutSequence_No                      = 168 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAUnscanned_Transaction_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PUnscanned_Transaction_Rec ( P )^ do Begin
      If utRecord_Type <> tkBegin_Unscanned_Transaction then
         Raise ECorruptData.Create( SInvalidType );
      If utEOR <> tkEnd_Unscanned_Transaction then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Unscanned_Transaction_Rec ( Var O : TUnscanned_Transaction_Rec ; Var F : TIOStream );

Begin
   If IsAUnscanned_Transaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Unscanned_Transaction );
      F.WriteStringValue( tkutBank_Account_Number , utBank_Account_Number );
      F.WriteIntegerValue( tkutSequence_No , utSequence_No );
      F.WriteToken( tkEnd_Unscanned_Transaction );
   end;
end; { of Write_Unscanned_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Unscanned_Transaction_Rec ( Var O : TUnscanned_Transaction_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Unscanned_Transaction_Rec_Size, 0 );
   O.utRecord_Type := tkBegin_Unscanned_Transaction;
   O.utEOR := tkEnd_Unscanned_Transaction;
   Token := tkBegin_Unscanned_Transaction;

   While Token <> tkEnd_Unscanned_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Unscanned_Transaction :; { Do Nothing }
         tkEnd_Unscanned_Transaction :; { Do Nothing }
         tkutBank_Account_Number              : utBank_Account_Number := F.ReadStringValue;
         tkutSequence_No                      : utSequence_No := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Unscanned_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Unscanned_Transaction_Rec : pUnscanned_Transaction_Rec ;

Var
   P : pUnscanned_Transaction_Rec;
Begin
   SafeGetMem( P, Unscanned_Transaction_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Unscanned_Transaction_Rec_Size, 0 );
      utRecord_Type := tkBegin_Unscanned_Transaction;
      utEOR         := tkEnd_Unscanned_Transaction;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Unscanned_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Unscanned_Transaction_Rec_Dynamic_Fields ( Var O : TUnscanned_Transaction_Rec );

Begin
   If IsAUnscanned_Transaction_Rec ( @O ) then With O do
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
  for i := tkutBank_Account_Number to tkutSequence_No do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Unscanned_Transaction_Rec_Delta(P1, P2, P3: pUnscanned_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Unscanned_Transaction_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.utBank_Account_Number <> P2.utBank_Account_Number) then begin
    P3.utBank_Account_Number := P1.utBank_Account_Number;
    ChangedFields[i] := tkutBank_Account_Number;
    Inc(i);
  end;
  if (P1.utSequence_No <> P2.utSequence_No) then begin
    P3.utSequence_No := P1.utSequence_No;
    ChangedFields[i] := tkutSequence_No;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Unscanned_Transaction_Rec(P1, P2: pUnscanned_Transaction_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Unscanned_Transaction_Rec(P1^, S);
    S.Position := 0;
    Read_Unscanned_Transaction_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
