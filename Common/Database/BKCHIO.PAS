UNIT BKchIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Account                      = 80 ;
   tkEnd_Account                        = 81 ;

FUNCTION  IsAAccount_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );
PROCEDURE Read_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );
FUNCTION  New_Account_Rec : pAccount_Rec ;
PROCEDURE Free_Account_Rec_Dynamic_Fields ( Var O : TAccount_Rec );
FUNCTION Account_Rec_Delta(P1, P2, P3: pAccount_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Account_Rec(P1, P2: pAccount_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKCHIO';
   SBoundsError        = 'BKCHIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKCHIO Error: Pointer is NIL in IsAAccount_Rec';
   SInvalidType        = 'BKCHIO Error: Type is invalid in IsAAccount_Rec';
   SInvalidEOR         = 'BKCHIO Error: EOR is missing in IsAAccount_Rec';
   SUnknownToken       = 'BKCHIO Error: Unknown token %d in Read_Account_Rec';
   SInsufficientMemory = 'BKCHIO Error: Out of memory in New_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkchAccount_Code                     = 82 ;
   tkchChart_ID                         = 83 ;
   tkchAccount_Description              = 84 ;
   tkchGST_Class                        = 85 ;
   tkchPosting_Allowed                  = 86 ;
   tkchAccount_Type                     = 87 ;
   tkchEnter_Quantity                   = 88 ;
   tkchPrint_in_Division                = 89 ;
   tkchMoney_Variance_Up                = 90 ;
   tkchMoney_Variance_Down              = 91 ;
   tkchPercent_Variance_Up              = 92 ;
   tkchPercent_Variance_Down            = 93 ;
   tkchLast_Years_Totals_SB_Only        = 94 ;
   tkchOpening_Balance_SB_Only          = 95 ;
   tkchSubtype                          = 96 ;
   tkchAlternative_Code                 = 97 ;
   tkchLinked_Account_OS                = 98 ;
   tkchLinked_Account_CS                = 99 ;
   tkchHide_In_Basic_Chart              = 100 ;
   tkchAudit_Record_ID                  = 101 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAAccount_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PAccount_Rec ( P )^ do Begin
      If chRecord_Type <> tkBegin_Account then
         Raise ECorruptData.Create( SInvalidType );
      If chEOR <> tkEnd_Account then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Account_Rec ( Var O : TAccount_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAAccount_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Account );
      F.WriteStringValue( tkchAccount_Code , chAccount_Code );
      F.WriteStringValue( tkchChart_ID , chChart_ID );
      F.WriteStringValue( tkchAccount_Description , chAccount_Description );
      F.WriteByteValue( tkchGST_Class , chGST_Class );
      F.WriteBooleanValue( tkchPosting_Allowed , chPosting_Allowed );
      F.WriteByteValue( tkchAccount_Type , chAccount_Type );
      F.WriteBooleanValue( tkchEnter_Quantity , chEnter_Quantity );
      For i := 1 to 250 do F.WriteBBooleanValue( tkchPrint_in_Division , i, chPrint_in_Division[ i ] );
      F.WriteMoneyValue( tkchMoney_Variance_Up , chMoney_Variance_Up );
      F.WriteMoneyValue( tkchMoney_Variance_Down , chMoney_Variance_Down );
      F.WriteMoneyValue( tkchPercent_Variance_Up , chPercent_Variance_Up );
      F.WriteMoneyValue( tkchPercent_Variance_Down , chPercent_Variance_Down );
      For i := 1 to 12 do F.WriteBMoneyValue( tkchLast_Years_Totals_SB_Only , i, chLast_Years_Totals_SB_Only[ i ] );
      F.WriteMoneyValue( tkchOpening_Balance_SB_Only , chOpening_Balance_SB_Only );
      F.WriteByteValue( tkchSubtype , chSubtype );
      F.WriteStringValue( tkchAlternative_Code , chAlternative_Code );
      F.WriteStringValue( tkchLinked_Account_OS , chLinked_Account_OS );
      F.WriteStringValue( tkchLinked_Account_CS , chLinked_Account_CS );
      F.WriteBooleanValue( tkchHide_In_Basic_Chart , chHide_In_Basic_Chart );
      F.WriteIntegerValue( tkchAudit_Record_ID , chAudit_Record_ID );
      F.WriteToken( tkEnd_Account );
   end;
end; { of Write_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Account_Rec ( Var O : TAccount_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;
   Y     : Boolean;

Begin
   FillChar( O, Account_Rec_Size, 0 );
   O.chRecord_Type := tkBegin_Account;
   O.chEOR := tkEnd_Account;
   Token := tkBegin_Account;

   While Token <> tkEnd_Account do With O do
   Begin
      Case Token of
         tkBegin_Account :; { Do Nothing }
         tkEnd_Account :; { Do Nothing }
         tkchAccount_Code                     : chAccount_Code := F.ReadStringValue;
         tkchChart_ID                         : chChart_ID := F.ReadStringValue;
         tkchAccount_Description              : chAccount_Description := F.ReadStringValue;
         tkchGST_Class                        : chGST_Class := F.ReadByteValue;
         tkchPosting_Allowed                  : chPosting_Allowed := F.ReadBooleanValue;
         tkchAccount_Type                     : chAccount_Type := F.ReadByteValue;
         tkchEnter_Quantity                   : chEnter_Quantity := F.ReadBooleanValue;
         tkchPrint_in_Division                : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 250, 'chPrint_in_Division' );
               chPrint_in_Division[ I ] := Y;
            end;
         tkchMoney_Variance_Up                : chMoney_Variance_Up := F.ReadMoneyValue;
         tkchMoney_Variance_Down              : chMoney_Variance_Down := F.ReadMoneyValue;
         tkchPercent_Variance_Up              : chPercent_Variance_Up := F.ReadMoneyValue;
         tkchPercent_Variance_Down            : chPercent_Variance_Down := F.ReadMoneyValue;
         tkchLast_Years_Totals_SB_Only        : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 12, 'chLast_Years_Totals_SB_Only' );
               chLast_Years_Totals_SB_Only[ I ] := M;
            end;
         tkchOpening_Balance_SB_Only          : chOpening_Balance_SB_Only := F.ReadMoneyValue;
         tkchSubtype                          : chSubtype := F.ReadByteValue;
         tkchAlternative_Code                 : chAlternative_Code := F.ReadStringValue;
         tkchLinked_Account_OS                : chLinked_Account_OS := F.ReadStringValue;
         tkchLinked_Account_CS                : chLinked_Account_CS := F.ReadStringValue;
         tkchHide_In_Basic_Chart              : chHide_In_Basic_Chart := F.ReadBooleanValue;
         tkchAudit_Record_ID                  : chAudit_Record_ID := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Account_Rec : pAccount_Rec ;

Var
   P : pAccount_Rec;
Begin
   SafeGetMem( P, Account_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Account_Rec_Size, 0 );
      chRecord_Type := tkBegin_Account;
      chEOR         := tkEnd_Account;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Account_Rec_Dynamic_Fields ( Var O : TAccount_Rec );

Begin
   If IsAAccount_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      DBR_SetLength( chTemp_Quantity, 0 );
      DBR_SetLength( chTemp_Amount, 0 );
      DBR_SetLength( chTemp_Base_Amount, 0 );
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
  for i := tkchAccount_Code to tkchAudit_Record_ID do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Account_Rec_Delta(P1, P2, P3: pAccount_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Account_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Exit;
  end;

  //Change
  i := 0;
  if (P1.chAccount_Code <> P2.chAccount_Code) then begin
    P3.chAccount_Code := P1.chAccount_Code;
    ChangedFields[i] := tkchAccount_Code;
    Inc(i);
  end;
  if (P1.chChart_ID <> P2.chChart_ID) then begin
    P3.chChart_ID := P1.chChart_ID;
    ChangedFields[i] := tkchChart_ID;
    Inc(i);
  end;
  if (P1.chAccount_Description <> P2.chAccount_Description) then begin
    P3.chAccount_Description := P1.chAccount_Description;
    ChangedFields[i] := tkchAccount_Description;
    Inc(i);
  end;
  if (P1.chGST_Class <> P2.chGST_Class) then begin
    P3.chGST_Class := P1.chGST_Class;
    ChangedFields[i] := tkchGST_Class;
    Inc(i);
  end;
  if (P1.chPosting_Allowed <> P2.chPosting_Allowed) then begin
    P3.chPosting_Allowed := P1.chPosting_Allowed;
    ChangedFields[i] := tkchPosting_Allowed;
    Inc(i);
  end;
  if (P1.chAccount_Type <> P2.chAccount_Type) then begin
    P3.chAccount_Type := P1.chAccount_Type;
    ChangedFields[i] := tkchAccount_Type;
    Inc(i);
  end;
  if (P1.chEnter_Quantity <> P2.chEnter_Quantity) then begin
    P3.chEnter_Quantity := P1.chEnter_Quantity;
    ChangedFields[i] := tkchEnter_Quantity;
    Inc(i);
  end;
  if Print_in_Division_Changed(TPrint_in_Division_Array(P1.chPrint_in_Division), 
                  TPrint_in_Division_Array(P2.chPrint_in_Division), 
                  TPrint_in_Division_Array(P3.chPrint_in_Division)) then begin
    ChangedFields[i] := tkchPrint_in_Division;
    Inc(i);
  end;
  if (P1.chMoney_Variance_Up <> P2.chMoney_Variance_Up) then begin
    P3.chMoney_Variance_Up := P1.chMoney_Variance_Up;
    ChangedFields[i] := tkchMoney_Variance_Up;
    Inc(i);
  end;
  if (P1.chMoney_Variance_Down <> P2.chMoney_Variance_Down) then begin
    P3.chMoney_Variance_Down := P1.chMoney_Variance_Down;
    ChangedFields[i] := tkchMoney_Variance_Down;
    Inc(i);
  end;
  if (P1.chPercent_Variance_Up <> P2.chPercent_Variance_Up) then begin
    P3.chPercent_Variance_Up := P1.chPercent_Variance_Up;
    ChangedFields[i] := tkchPercent_Variance_Up;
    Inc(i);
  end;
  if (P1.chPercent_Variance_Down <> P2.chPercent_Variance_Down) then begin
    P3.chPercent_Variance_Down := P1.chPercent_Variance_Down;
    ChangedFields[i] := tkchPercent_Variance_Down;
    Inc(i);
  end;
  if Last_Years_Totals_SB_Only_Changed(TLast_Years_Totals_SB_Only_Array(P1.chLast_Years_Totals_SB_Only), 
                  TLast_Years_Totals_SB_Only_Array(P2.chLast_Years_Totals_SB_Only), 
                  TLast_Years_Totals_SB_Only_Array(P3.chLast_Years_Totals_SB_Only)) then begin
    ChangedFields[i] := tkchLast_Years_Totals_SB_Only;
    Inc(i);
  end;
  if (P1.chOpening_Balance_SB_Only <> P2.chOpening_Balance_SB_Only) then begin
    P3.chOpening_Balance_SB_Only := P1.chOpening_Balance_SB_Only;
    ChangedFields[i] := tkchOpening_Balance_SB_Only;
    Inc(i);
  end;
  if (P1.chSubtype <> P2.chSubtype) then begin
    P3.chSubtype := P1.chSubtype;
    ChangedFields[i] := tkchSubtype;
    Inc(i);
  end;
  if (P1.chAlternative_Code <> P2.chAlternative_Code) then begin
    P3.chAlternative_Code := P1.chAlternative_Code;
    ChangedFields[i] := tkchAlternative_Code;
    Inc(i);
  end;
  if (P1.chLinked_Account_OS <> P2.chLinked_Account_OS) then begin
    P3.chLinked_Account_OS := P1.chLinked_Account_OS;
    ChangedFields[i] := tkchLinked_Account_OS;
    Inc(i);
  end;
  if (P1.chLinked_Account_CS <> P2.chLinked_Account_CS) then begin
    P3.chLinked_Account_CS := P1.chLinked_Account_CS;
    ChangedFields[i] := tkchLinked_Account_CS;
    Inc(i);
  end;
  if (P1.chHide_In_Basic_Chart <> P2.chHide_In_Basic_Chart) then begin
    P3.chHide_In_Basic_Chart := P1.chHide_In_Basic_Chart;
    ChangedFields[i] := tkchHide_In_Basic_Chart;
    Inc(i);
  end;
  if (P1.chAudit_Record_ID <> P2.chAudit_Record_ID) then begin
    P3.chAudit_Record_ID := P1.chAudit_Record_ID;
    ChangedFields[i] := tkchAudit_Record_ID;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Account_Rec(P1, P2: pAccount_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Account_Rec(P1^, S);
    S.Position := 0;
    Read_Account_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
