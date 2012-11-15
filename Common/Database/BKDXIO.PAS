UNIT BKdxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Deleted_Transaction          = 233 ;
   tkEnd_Deleted_Transaction            = 234 ;

FUNCTION  IsADeleted_Transaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Deleted_Transaction_Rec ( Var O : TDeleted_Transaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Deleted_Transaction_Rec ( Var O : TDeleted_Transaction_Rec ; Var F : TIOStream );
FUNCTION  New_Deleted_Transaction_Rec : pDeleted_Transaction_Rec ;
PROCEDURE Free_Deleted_Transaction_Rec_Dynamic_Fields ( Var O : TDeleted_Transaction_Rec );
FUNCTION Deleted_Transaction_Rec_Delta(P1, P2, P3: pDeleted_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Deleted_Transaction_Rec(P1, P2: pDeleted_Transaction_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKDXIO';
   SBoundsError        = 'BKDXIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKDXIO Error: Pointer is NIL in IsADeleted_Transaction_Rec';
   SInvalidType        = 'BKDXIO Error: Type is invalid in IsADeleted_Transaction_Rec';
   SInvalidEOR         = 'BKDXIO Error: EOR is missing in IsADeleted_Transaction_Rec';
   SUnknownToken       = 'BKDXIO Error: Unknown token %d in Read_Deleted_Transaction_Rec';
   SInsufficientMemory = 'BKDXIO Error: Out of memory in New_Deleted_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdxDate_Deleted                     = 235 ;
   tkdxDeleted_By                       = 236 ;
   tkdxExternal_GUID                    = 237 ;
   tkdxDate_Effective                   = 238 ;
   tkdxDate_Presented                   = 239 ;
   tkdxSequence_No                      = 240 ;
   tkdxAmount                           = 241 ;
   tkdxGST_Amount                       = 242 ;
   tkdxQuantity                         = 243 ;
   tkdxAccount                          = 244 ;
   tkdxReference                        = 245 ;
   tkdxParticulars                      = 246 ;
   tkdxCore_Transaction_ID              = 247 ;
   tkdxCore_Transaction_ID_High         = 248 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADeleted_Transaction_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PDeleted_Transaction_Rec ( P )^ do Begin
      If dxRecord_Type <> tkBegin_Deleted_Transaction then
         Raise ECorruptData.Create( SInvalidType );
      If dxEOR <> tkEnd_Deleted_Transaction then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Deleted_Transaction_Rec ( Var O : TDeleted_Transaction_Rec ; Var F : TIOStream );

Begin
   If IsADeleted_Transaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Deleted_Transaction );
      F.WriteDateValue( tkdxDate_Deleted , dxDate_Deleted );
      F.WriteStringValue( tkdxDeleted_By , dxDeleted_By );
      F.WriteAnsiStringValue( tkdxExternal_GUID , dxExternal_GUID );
      F.WriteDateValue( tkdxDate_Effective , dxDate_Effective );
      F.WriteDateValue( tkdxDate_Presented , dxDate_Presented );
      F.WriteIntegerValue( tkdxSequence_No , dxSequence_No );
      F.WriteMoneyValue( tkdxAmount , dxAmount );
      F.WriteMoneyValue( tkdxGST_Amount , dxGST_Amount );
      F.WriteMoneyValue( tkdxQuantity , dxQuantity );
      F.WriteStringValue( tkdxAccount , dxAccount );
      F.WriteStringValue( tkdxReference , dxReference );
      F.WriteStringValue( tkdxParticulars , dxParticulars );
      F.WriteIntegerValue( tkdxCore_Transaction_ID , dxCore_Transaction_ID );
      F.WriteIntegerValue( tkdxCore_Transaction_ID_High , dxCore_Transaction_ID_High );
      F.WriteToken( tkEnd_Deleted_Transaction );
   end;
end; { of Write_Deleted_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Deleted_Transaction_Rec ( Var O : TDeleted_Transaction_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Deleted_Transaction_Rec_Size, 0 );
   O.dxRecord_Type := tkBegin_Deleted_Transaction;
   O.dxEOR := tkEnd_Deleted_Transaction;
   Token := tkBegin_Deleted_Transaction;

   While Token <> tkEnd_Deleted_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Deleted_Transaction :; { Do Nothing }
         tkEnd_Deleted_Transaction :; { Do Nothing }
         tkdxDate_Deleted                     : dxDate_Deleted := F.ReadDateValue;
         tkdxDeleted_By                       : dxDeleted_By := F.ReadStringValue;
         tkdxExternal_GUID                    : dxExternal_GUID := F.ReadAnsiStringValue;
         tkdxDate_Effective                   : dxDate_Effective := F.ReadDateValue;
         tkdxDate_Presented                   : dxDate_Presented := F.ReadDateValue;
         tkdxSequence_No                      : dxSequence_No := F.ReadIntegerValue;
         tkdxAmount                           : dxAmount := F.ReadMoneyValue;
         tkdxGST_Amount                       : dxGST_Amount := F.ReadMoneyValue;
         tkdxQuantity                         : dxQuantity := F.ReadMoneyValue;
         tkdxAccount                          : dxAccount := F.ReadStringValue;
         tkdxReference                        : dxReference := F.ReadStringValue;
         tkdxParticulars                      : dxParticulars := F.ReadStringValue;
         tkdxCore_Transaction_ID              : dxCore_Transaction_ID := F.ReadIntegerValue;
         tkdxCore_Transaction_ID_High         : dxCore_Transaction_ID_High := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Deleted_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Deleted_Transaction_Rec : pDeleted_Transaction_Rec ;

Var
   P : pDeleted_Transaction_Rec;
Begin
   SafeGetMem( P, Deleted_Transaction_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Deleted_Transaction_Rec_Size, 0 );
      dxRecord_Type := tkBegin_Deleted_Transaction;
      dxEOR         := tkEnd_Deleted_Transaction;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Deleted_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Deleted_Transaction_Rec_Dynamic_Fields ( Var O : TDeleted_Transaction_Rec );

Begin
   If IsADeleted_Transaction_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      dxExternal_GUID := '' ;
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
  for i := tkdxDate_Deleted to tkdxCore_Transaction_ID_High do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Deleted_Transaction_Rec_Delta(P1, P2, P3: pDeleted_Transaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Deleted_Transaction_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.dxDate_Deleted <> P2.dxDate_Deleted) then begin
    P3.dxDate_Deleted := P1.dxDate_Deleted;
    ChangedFields[i] := tkdxDate_Deleted;
    Inc(i);
  end;
  if (P1.dxDeleted_By <> P2.dxDeleted_By) then begin
    P3.dxDeleted_By := P1.dxDeleted_By;
    ChangedFields[i] := tkdxDeleted_By;
    Inc(i);
  end;
  if (P1.dxExternal_GUID <> P2.dxExternal_GUID) then begin
    P3.dxExternal_GUID := P1.dxExternal_GUID;
    ChangedFields[i] := tkdxExternal_GUID;
    Inc(i);
  end;
  if (P1.dxDate_Effective <> P2.dxDate_Effective) then begin
    P3.dxDate_Effective := P1.dxDate_Effective;
    ChangedFields[i] := tkdxDate_Effective;
    Inc(i);
  end;
  if (P1.dxDate_Presented <> P2.dxDate_Presented) then begin
    P3.dxDate_Presented := P1.dxDate_Presented;
    ChangedFields[i] := tkdxDate_Presented;
    Inc(i);
  end;
  if (P1.dxSequence_No <> P2.dxSequence_No) then begin
    P3.dxSequence_No := P1.dxSequence_No;
    ChangedFields[i] := tkdxSequence_No;
    Inc(i);
  end;
  if (P1.dxAmount <> P2.dxAmount) then begin
    P3.dxAmount := P1.dxAmount;
    ChangedFields[i] := tkdxAmount;
    Inc(i);
  end;
  if (P1.dxGST_Amount <> P2.dxGST_Amount) then begin
    P3.dxGST_Amount := P1.dxGST_Amount;
    ChangedFields[i] := tkdxGST_Amount;
    Inc(i);
  end;
  if (P1.dxQuantity <> P2.dxQuantity) then begin
    P3.dxQuantity := P1.dxQuantity;
    ChangedFields[i] := tkdxQuantity;
    Inc(i);
  end;
  if (P1.dxAccount <> P2.dxAccount) then begin
    P3.dxAccount := P1.dxAccount;
    ChangedFields[i] := tkdxAccount;
    Inc(i);
  end;
  if (P1.dxReference <> P2.dxReference) then begin
    P3.dxReference := P1.dxReference;
    ChangedFields[i] := tkdxReference;
    Inc(i);
  end;
  if (P1.dxParticulars <> P2.dxParticulars) then begin
    P3.dxParticulars := P1.dxParticulars;
    ChangedFields[i] := tkdxParticulars;
    Inc(i);
  end;
  if (P1.dxCore_Transaction_ID <> P2.dxCore_Transaction_ID) then begin
    P3.dxCore_Transaction_ID := P1.dxCore_Transaction_ID;
    ChangedFields[i] := tkdxCore_Transaction_ID;
    Inc(i);
  end;
  if (P1.dxCore_Transaction_ID_High <> P2.dxCore_Transaction_ID_High) then begin
    P3.dxCore_Transaction_ID_High := P1.dxCore_Transaction_ID_High;
    ChangedFields[i] := tkdxCore_Transaction_ID_High;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Deleted_Transaction_Rec(P1, P2: pDeleted_Transaction_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Deleted_Transaction_Rec(P1^, S);
    S.Position := 0;
    Read_Deleted_Transaction_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
