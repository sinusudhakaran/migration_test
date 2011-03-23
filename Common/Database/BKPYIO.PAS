UNIT BKpyIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee                        = 100 ;
   tkEnd_Payee                          = 101 ;

FUNCTION  IsAPayee_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Rec : pPayee_Rec ;
PROCEDURE Free_Payee_Rec_Dynamic_Fields ( Var O : TPayee_Rec );
FUNCTION Payee_Rec_Delta(P1, P2, P3: pPayee_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Payee_Rec(P1, P2: pPayee_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPYIO';
   SBoundsError        = 'BKPYIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPYIO Error: Pointer is NIL in IsAPayee_Rec';
   SInvalidType        = 'BKPYIO Error: Type is invalid in IsAPayee_Rec';
   SInvalidEOR         = 'BKPYIO Error: EOR is missing in IsAPayee_Rec';
   SUnknownToken       = 'BKPYIO Error: Unknown token %d in Read_Payee_Rec';
   SInsufficientMemory = 'BKPYIO Error: Out of memory in New_Payee_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkpyNumber                           = 102 ;
   tkpyName                             = 103 ;
   tkpyAccount                          = 104 ;
   tkpyPercentage                       = 105 ;
   tkpyGST_Class                        = 106 ;
   tkpyGST_Has_Been_Edited              = 107 ;
   tkpyGL_Narration                     = 108 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Rec ( P )^ do Begin
      If pyRecord_Type <> tkBegin_Payee then
         Raise ECorruptData.Create( SInvalidType );
      If pyEOR <> tkEnd_Payee then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Rec ( Var O : TPayee_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAPayee_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee );
      F.WriteIntegerValue( tkpyNumber , pyNumber );
      F.WriteStringValue( tkpyName , pyName );
      For i := 1 to 50 do F.WriteBStringValue( tkpyAccount , i, pyAccount[ i ] );
      For i := 1 to 50 do F.WriteBMoneyValue( tkpyPercentage , i, pyPercentage[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkpyGST_Class , i, pyGST_Class[ i ] );
      For i := 1 to 50 do F.WriteBBooleanValue( tkpyGST_Has_Been_Edited , i, pyGST_Has_Been_Edited[ i ] );
      For i := 1 to 50 do F.WriteBStringValue( tkpyGL_Narration , i, pyGL_Narration[ i ] );
      F.WriteToken( tkEnd_Payee );
   end;
end; { of Write_Payee_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Rec ( Var O : TPayee_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;
   B     : Byte;   
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, Payee_Rec_Size, 0 );
   O.pyRecord_Type := tkBegin_Payee;
   O.pyEOR := tkEnd_Payee;
   Token := tkBegin_Payee;

   While Token <> tkEnd_Payee do With O do
   Begin
      Case Token of
         tkBegin_Payee :; { Do Nothing }
         tkEnd_Payee :; { Do Nothing }
         tkpyNumber                           : pyNumber := F.ReadIntegerValue;
         tkpyName                             : pyName := F.ReadStringValue;
         tkpyAccount                          : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'pyAccount' );
               pyAccount[ I ] := S;
            end;
         tkpyPercentage                       : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 50, 'pyPercentage' );
               pyPercentage[ I ] := M;
            end;
         tkpyGST_Class                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'pyGST_Class' );
               pyGST_Class[ I ] := B;
            end;
         tkpyGST_Has_Been_Edited              : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 50, 'pyGST_Has_Been_Edited' );
               pyGST_Has_Been_Edited[ I ] := Y;
            end;
         tkpyGL_Narration                     : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'pyGL_Narration' );
               pyGL_Narration[ I ] := S;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Rec : pPayee_Rec ;

Var
   P : pPayee_Rec;
Begin
   SafeGetMem( P, Payee_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Rec_Size, 0 );
      pyRecord_Type := tkBegin_Payee;
      pyEOR         := tkEnd_Payee;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Rec_Dynamic_Fields ( Var O : TPayee_Rec );

Begin
   If IsAPayee_Rec ( @O ) then With O do
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
  for i := tkpyNumber to tkpyGL_Narration do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Payee_Rec_Delta(P1, P2, P3: pPayee_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Payee_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.pyNumber <> P2.pyNumber) then begin
    P3.pyNumber := P1.pyNumber;
    ChangedFields[i] := tkpyNumber;
    Inc(i);
  end;
  if (P1.pyName <> P2.pyName) then begin
    P3.pyName := P1.pyName;
    ChangedFields[i] := tkpyName;
    Inc(i);
  end;
  if Account_Changed(TAccount_Array(P1.pyAccount), 
                  TAccount_Array(P2.pyAccount), 
                  TAccount_Array(P3.pyAccount)) then begin
    ChangedFields[i] := tkpyAccount;
    Inc(i);
  end;
  if Percentage_Changed(TPercentage_Array(P1.pyPercentage), 
                  TPercentage_Array(P2.pyPercentage), 
                  TPercentage_Array(P3.pyPercentage)) then begin
    ChangedFields[i] := tkpyPercentage;
    Inc(i);
  end;
  if GST_Class_Changed(TGST_Class_Array(P1.pyGST_Class), 
                  TGST_Class_Array(P2.pyGST_Class), 
                  TGST_Class_Array(P3.pyGST_Class)) then begin
    ChangedFields[i] := tkpyGST_Class;
    Inc(i);
  end;
  if GST_Has_Been_Edited_Changed(TGST_Has_Been_Edited_Array(P1.pyGST_Has_Been_Edited), 
                  TGST_Has_Been_Edited_Array(P2.pyGST_Has_Been_Edited), 
                  TGST_Has_Been_Edited_Array(P3.pyGST_Has_Been_Edited)) then begin
    ChangedFields[i] := tkpyGST_Has_Been_Edited;
    Inc(i);
  end;
  if GL_Narration_Changed(TGL_Narration_Array(P1.pyGL_Narration), 
                  TGL_Narration_Array(P2.pyGL_Narration), 
                  TGL_Narration_Array(P3.pyGL_Narration)) then begin
    ChangedFields[i] := tkpyGL_Narration;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Payee_Rec(P1, P2: pPayee_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Payee_Rec(P1^, S);
    S.Position := 0;
    Read_Payee_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
