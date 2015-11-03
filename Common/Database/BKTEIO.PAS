UNIT BKteIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Transaction_Extension        = 162 ;
   tkEnd_Transaction_Extension          = 163 ;

FUNCTION  IsATransaction_Extension_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Transaction_Extension_Rec ( Var O : TTransaction_Extension_Rec ; Var F : TIOStream );
PROCEDURE Read_Transaction_Extension_Rec ( Var O : TTransaction_Extension_Rec ; Var F : TIOStream );
FUNCTION  New_Transaction_Extension_Rec : pTransaction_Extension_Rec ;
PROCEDURE Free_Transaction_Extension_Rec_Dynamic_Fields ( Var O : TTransaction_Extension_Rec );
FUNCTION Transaction_Extension_Rec_Delta(P1, P2, P3: pTransaction_Extension_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Transaction_Extension_Rec(P1, P2: pTransaction_Extension_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKTEIO';
   SBoundsError        = 'BKTEIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKTEIO Error: Pointer is NIL in IsATransaction_Extension_Rec';
   SInvalidType        = 'BKTEIO Error: Type is invalid in IsATransaction_Extension_Rec';
   SInvalidEOR         = 'BKTEIO Error: EOR is missing in IsATransaction_Extension_Rec';
   SUnknownToken       = 'BKTEIO Error: Unknown token %d in Read_Transaction_Extension_Rec';
   SInsufficientMemory = 'BKTEIO Error: Out of memory in New_Transaction_Extension_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkteSequence_No                      = 164 ;
   tkteDate_Effective                   = 165 ;
   tkteSF_Other_Income                  = 166 ;
   tkteSF_Other_Trust_Deductions        = 167 ;
   tkteSF_CGT_Concession_Amount         = 168 ;
   tkteSF_CGT_ForeignCGT_Before_Disc    = 169 ;
   tkteSF_CGT_ForeignCGT_Indexation     = 170 ;
   tkteSF_CGT_ForeignCGT_Other_Method   = 171 ;
   tkteSF_CGT_TaxPaid_Indexation        = 172 ;
   tkteSF_CGT_TaxPaid_Other_Method      = 173 ;
   tkteSF_Other_Net_Foreign_Income      = 174 ;
   tkteSF_Cash_Distribution             = 175 ;
   tkteSF_AU_Franking_Credits_NZ_Co     = 176 ;
   tkteSF_Non_Res_Witholding_Tax        = 177 ;
   tkteSF_LIC_Deductions                = 178 ;
   tkteSF_Non_Cash_CGT_Discounted_Before_Discount = 179 ;
   tkteSF_Non_Cash_CGT_Indexation       = 180 ;
   tkteSF_Non_Cash_CGT_Other_Method     = 181 ;
   tkteSF_Non_Cash_CGT_Capital_Losses   = 182 ;
   tkteSF_Share_Brokerage               = 183 ;
   tkteSF_Share_Consideration           = 184 ;
   tkteSF_Share_GST_Amount              = 185 ;
   tkteSF_Share_GST_Rate                = 186 ;
   tkteSF_Cash_Date                     = 187 ;
   tkteSF_Accrual_Date                  = 188 ;
   tkteSF_Record_Date                   = 189 ;
   tkteSF_Contract_Date                 = 190 ;
   tkteSF_Settlement_Date               = 191 ;

{  -------------------------------------------------------------------  }

FUNCTION IsATransaction_Extension_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PTransaction_Extension_Rec ( P )^ do Begin
      If teRecord_Type <> tkBegin_Transaction_Extension then
         Raise ECorruptData.Create( SInvalidType );
      If teEOR <> tkEnd_Transaction_Extension then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Transaction_Extension_Rec ( Var O : TTransaction_Extension_Rec ; Var F : TIOStream );

Begin
   If IsATransaction_Extension_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Transaction_Extension );
      F.WriteIntegerValue( tkteSequence_No , teSequence_No );
      F.WriteDateValue( tkteDate_Effective , teDate_Effective );
      F.WriteMoneyValue( tkteSF_Other_Income , teSF_Other_Income );
      F.WriteMoneyValue( tkteSF_Other_Trust_Deductions , teSF_Other_Trust_Deductions );
      F.WriteMoneyValue( tkteSF_CGT_Concession_Amount , teSF_CGT_Concession_Amount );
      F.WriteMoneyValue( tkteSF_CGT_ForeignCGT_Before_Disc , teSF_CGT_ForeignCGT_Before_Disc );
      F.WriteMoneyValue( tkteSF_CGT_ForeignCGT_Indexation , teSF_CGT_ForeignCGT_Indexation );
      F.WriteMoneyValue( tkteSF_CGT_ForeignCGT_Other_Method , teSF_CGT_ForeignCGT_Other_Method );
      F.WriteMoneyValue( tkteSF_CGT_TaxPaid_Indexation , teSF_CGT_TaxPaid_Indexation );
      F.WriteMoneyValue( tkteSF_CGT_TaxPaid_Other_Method , teSF_CGT_TaxPaid_Other_Method );
      F.WriteMoneyValue( tkteSF_Other_Net_Foreign_Income , teSF_Other_Net_Foreign_Income );
      F.WriteMoneyValue( tkteSF_Cash_Distribution , teSF_Cash_Distribution );
      F.WriteMoneyValue( tkteSF_AU_Franking_Credits_NZ_Co , teSF_AU_Franking_Credits_NZ_Co );
      F.WriteMoneyValue( tkteSF_Non_Res_Witholding_Tax , teSF_Non_Res_Witholding_Tax );
      F.WriteMoneyValue( tkteSF_LIC_Deductions , teSF_LIC_Deductions );
      F.WriteMoneyValue( tkteSF_Non_Cash_CGT_Discounted_Before_Discount , teSF_Non_Cash_CGT_Discounted_Before_Discount );
      F.WriteMoneyValue( tkteSF_Non_Cash_CGT_Indexation , teSF_Non_Cash_CGT_Indexation );
      F.WriteMoneyValue( tkteSF_Non_Cash_CGT_Other_Method , teSF_Non_Cash_CGT_Other_Method );
      F.WriteMoneyValue( tkteSF_Non_Cash_CGT_Capital_Losses , teSF_Non_Cash_CGT_Capital_Losses );
      F.WriteMoneyValue( tkteSF_Share_Brokerage , teSF_Share_Brokerage );
      F.WriteMoneyValue( tkteSF_Share_Consideration , teSF_Share_Consideration );
      F.WriteMoneyValue( tkteSF_Share_GST_Amount , teSF_Share_GST_Amount );
      F.WriteStringValue( tkteSF_Share_GST_Rate , teSF_Share_GST_Rate );
      F.WriteDateValue( tkteSF_Cash_Date , teSF_Cash_Date );
      F.WriteDateValue( tkteSF_Accrual_Date , teSF_Accrual_Date );
      F.WriteDateValue( tkteSF_Record_Date , teSF_Record_Date );
      F.WriteDateValue( tkteSF_Contract_Date , teSF_Contract_Date );
      F.WriteDateValue( tkteSF_Settlement_Date , teSF_Settlement_Date );
      F.WriteToken( tkEnd_Transaction_Extension );
   end;
end; { of Write_Transaction_Extension_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Transaction_Extension_Rec ( Var O : TTransaction_Extension_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Transaction_Extension_Rec_Size, 0 );
   O.teRecord_Type := tkBegin_Transaction_Extension;
   O.teEOR := tkEnd_Transaction_Extension;
   Token := tkBegin_Transaction_Extension;

   While Token <> tkEnd_Transaction_Extension do With O do
   Begin
      Case Token of
         tkBegin_Transaction_Extension :; { Do Nothing }
         tkEnd_Transaction_Extension :; { Do Nothing }
         tkteSequence_No                      : teSequence_No := F.ReadIntegerValue;
         tkteDate_Effective                   : teDate_Effective := F.ReadDateValue;
         tkteSF_Other_Income                  : teSF_Other_Income := F.ReadMoneyValue;
         tkteSF_Other_Trust_Deductions        : teSF_Other_Trust_Deductions := F.ReadMoneyValue;
         tkteSF_CGT_Concession_Amount         : teSF_CGT_Concession_Amount := F.ReadMoneyValue;
         tkteSF_CGT_ForeignCGT_Before_Disc    : teSF_CGT_ForeignCGT_Before_Disc := F.ReadMoneyValue;
         tkteSF_CGT_ForeignCGT_Indexation     : teSF_CGT_ForeignCGT_Indexation := F.ReadMoneyValue;
         tkteSF_CGT_ForeignCGT_Other_Method   : teSF_CGT_ForeignCGT_Other_Method := F.ReadMoneyValue;
         tkteSF_CGT_TaxPaid_Indexation        : teSF_CGT_TaxPaid_Indexation := F.ReadMoneyValue;
         tkteSF_CGT_TaxPaid_Other_Method      : teSF_CGT_TaxPaid_Other_Method := F.ReadMoneyValue;
         tkteSF_Other_Net_Foreign_Income      : teSF_Other_Net_Foreign_Income := F.ReadMoneyValue;
         tkteSF_Cash_Distribution             : teSF_Cash_Distribution := F.ReadMoneyValue;
         tkteSF_AU_Franking_Credits_NZ_Co     : teSF_AU_Franking_Credits_NZ_Co := F.ReadMoneyValue;
         tkteSF_Non_Res_Witholding_Tax        : teSF_Non_Res_Witholding_Tax := F.ReadMoneyValue;
         tkteSF_LIC_Deductions                : teSF_LIC_Deductions := F.ReadMoneyValue;
         tkteSF_Non_Cash_CGT_Discounted_Before_Discount : teSF_Non_Cash_CGT_Discounted_Before_Discount := F.ReadMoneyValue;
         tkteSF_Non_Cash_CGT_Indexation       : teSF_Non_Cash_CGT_Indexation := F.ReadMoneyValue;
         tkteSF_Non_Cash_CGT_Other_Method     : teSF_Non_Cash_CGT_Other_Method := F.ReadMoneyValue;
         tkteSF_Non_Cash_CGT_Capital_Losses   : teSF_Non_Cash_CGT_Capital_Losses := F.ReadMoneyValue;
         tkteSF_Share_Brokerage               : teSF_Share_Brokerage := F.ReadMoneyValue;
         tkteSF_Share_Consideration           : teSF_Share_Consideration := F.ReadMoneyValue;
         tkteSF_Share_GST_Amount              : teSF_Share_GST_Amount := F.ReadMoneyValue;
         tkteSF_Share_GST_Rate                : teSF_Share_GST_Rate := F.ReadStringValue;
         tkteSF_Cash_Date                     : teSF_Cash_Date := F.ReadDateValue;
         tkteSF_Accrual_Date                  : teSF_Accrual_Date := F.ReadDateValue;
         tkteSF_Record_Date                   : teSF_Record_Date := F.ReadDateValue;
         tkteSF_Contract_Date                 : teSF_Contract_Date := F.ReadDateValue;
         tkteSF_Settlement_Date               : teSF_Settlement_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Transaction_Extension_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Transaction_Extension_Rec : pTransaction_Extension_Rec ;

Var
   P : pTransaction_Extension_Rec;
Begin
   SafeGetMem( P, Transaction_Extension_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Transaction_Extension_Rec_Size, 0 );
      teRecord_Type := tkBegin_Transaction_Extension;
      teEOR         := tkEnd_Transaction_Extension;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Transaction_Extension_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Transaction_Extension_Rec_Dynamic_Fields ( Var O : TTransaction_Extension_Rec );

Begin
   If IsATransaction_Extension_Rec ( @O ) then With O do
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
  for i := tkteSequence_No to tkteSF_Settlement_Date do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Transaction_Extension_Rec_Delta(P1, P2, P3: pTransaction_Extension_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Transaction_Extension_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.teSequence_No <> P2.teSequence_No) then begin
    P3.teSequence_No := P1.teSequence_No;
    ChangedFields[i] := tkteSequence_No;
    Inc(i);
  end;
  if (P1.teDate_Effective <> P2.teDate_Effective) then begin
    P3.teDate_Effective := P1.teDate_Effective;
    ChangedFields[i] := tkteDate_Effective;
    Inc(i);
  end;
  if (P1.teSF_Other_Income <> P2.teSF_Other_Income) then begin
    P3.teSF_Other_Income := P1.teSF_Other_Income;
    ChangedFields[i] := tkteSF_Other_Income;
    Inc(i);
  end;
  if (P1.teSF_Other_Trust_Deductions <> P2.teSF_Other_Trust_Deductions) then begin
    P3.teSF_Other_Trust_Deductions := P1.teSF_Other_Trust_Deductions;
    ChangedFields[i] := tkteSF_Other_Trust_Deductions;
    Inc(i);
  end;
  if (P1.teSF_CGT_Concession_Amount <> P2.teSF_CGT_Concession_Amount) then begin
    P3.teSF_CGT_Concession_Amount := P1.teSF_CGT_Concession_Amount;
    ChangedFields[i] := tkteSF_CGT_Concession_Amount;
    Inc(i);
  end;
  if (P1.teSF_CGT_ForeignCGT_Before_Disc <> P2.teSF_CGT_ForeignCGT_Before_Disc) then begin
    P3.teSF_CGT_ForeignCGT_Before_Disc := P1.teSF_CGT_ForeignCGT_Before_Disc;
    ChangedFields[i] := tkteSF_CGT_ForeignCGT_Before_Disc;
    Inc(i);
  end;
  if (P1.teSF_CGT_ForeignCGT_Indexation <> P2.teSF_CGT_ForeignCGT_Indexation) then begin
    P3.teSF_CGT_ForeignCGT_Indexation := P1.teSF_CGT_ForeignCGT_Indexation;
    ChangedFields[i] := tkteSF_CGT_ForeignCGT_Indexation;
    Inc(i);
  end;
  if (P1.teSF_CGT_ForeignCGT_Other_Method <> P2.teSF_CGT_ForeignCGT_Other_Method) then begin
    P3.teSF_CGT_ForeignCGT_Other_Method := P1.teSF_CGT_ForeignCGT_Other_Method;
    ChangedFields[i] := tkteSF_CGT_ForeignCGT_Other_Method;
    Inc(i);
  end;
  if (P1.teSF_CGT_TaxPaid_Indexation <> P2.teSF_CGT_TaxPaid_Indexation) then begin
    P3.teSF_CGT_TaxPaid_Indexation := P1.teSF_CGT_TaxPaid_Indexation;
    ChangedFields[i] := tkteSF_CGT_TaxPaid_Indexation;
    Inc(i);
  end;
  if (P1.teSF_CGT_TaxPaid_Other_Method <> P2.teSF_CGT_TaxPaid_Other_Method) then begin
    P3.teSF_CGT_TaxPaid_Other_Method := P1.teSF_CGT_TaxPaid_Other_Method;
    ChangedFields[i] := tkteSF_CGT_TaxPaid_Other_Method;
    Inc(i);
  end;
  if (P1.teSF_Other_Net_Foreign_Income <> P2.teSF_Other_Net_Foreign_Income) then begin
    P3.teSF_Other_Net_Foreign_Income := P1.teSF_Other_Net_Foreign_Income;
    ChangedFields[i] := tkteSF_Other_Net_Foreign_Income;
    Inc(i);
  end;
  if (P1.teSF_Cash_Distribution <> P2.teSF_Cash_Distribution) then begin
    P3.teSF_Cash_Distribution := P1.teSF_Cash_Distribution;
    ChangedFields[i] := tkteSF_Cash_Distribution;
    Inc(i);
  end;
  if (P1.teSF_AU_Franking_Credits_NZ_Co <> P2.teSF_AU_Franking_Credits_NZ_Co) then begin
    P3.teSF_AU_Franking_Credits_NZ_Co := P1.teSF_AU_Franking_Credits_NZ_Co;
    ChangedFields[i] := tkteSF_AU_Franking_Credits_NZ_Co;
    Inc(i);
  end;
  if (P1.teSF_Non_Res_Witholding_Tax <> P2.teSF_Non_Res_Witholding_Tax) then begin
    P3.teSF_Non_Res_Witholding_Tax := P1.teSF_Non_Res_Witholding_Tax;
    ChangedFields[i] := tkteSF_Non_Res_Witholding_Tax;
    Inc(i);
  end;
  if (P1.teSF_LIC_Deductions <> P2.teSF_LIC_Deductions) then begin
    P3.teSF_LIC_Deductions := P1.teSF_LIC_Deductions;
    ChangedFields[i] := tkteSF_LIC_Deductions;
    Inc(i);
  end;
  if (P1.teSF_Non_Cash_CGT_Discounted_Before_Discount <> P2.teSF_Non_Cash_CGT_Discounted_Before_Discount) then begin
    P3.teSF_Non_Cash_CGT_Discounted_Before_Discount := P1.teSF_Non_Cash_CGT_Discounted_Before_Discount;
    ChangedFields[i] := tkteSF_Non_Cash_CGT_Discounted_Before_Discount;
    Inc(i);
  end;
  if (P1.teSF_Non_Cash_CGT_Indexation <> P2.teSF_Non_Cash_CGT_Indexation) then begin
    P3.teSF_Non_Cash_CGT_Indexation := P1.teSF_Non_Cash_CGT_Indexation;
    ChangedFields[i] := tkteSF_Non_Cash_CGT_Indexation;
    Inc(i);
  end;
  if (P1.teSF_Non_Cash_CGT_Other_Method <> P2.teSF_Non_Cash_CGT_Other_Method) then begin
    P3.teSF_Non_Cash_CGT_Other_Method := P1.teSF_Non_Cash_CGT_Other_Method;
    ChangedFields[i] := tkteSF_Non_Cash_CGT_Other_Method;
    Inc(i);
  end;
  if (P1.teSF_Non_Cash_CGT_Capital_Losses <> P2.teSF_Non_Cash_CGT_Capital_Losses) then begin
    P3.teSF_Non_Cash_CGT_Capital_Losses := P1.teSF_Non_Cash_CGT_Capital_Losses;
    ChangedFields[i] := tkteSF_Non_Cash_CGT_Capital_Losses;
    Inc(i);
  end;
  if (P1.teSF_Share_Brokerage <> P2.teSF_Share_Brokerage) then begin
    P3.teSF_Share_Brokerage := P1.teSF_Share_Brokerage;
    ChangedFields[i] := tkteSF_Share_Brokerage;
    Inc(i);
  end;
  if (P1.teSF_Share_Consideration <> P2.teSF_Share_Consideration) then begin
    P3.teSF_Share_Consideration := P1.teSF_Share_Consideration;
    ChangedFields[i] := tkteSF_Share_Consideration;
    Inc(i);
  end;
  if (P1.teSF_Share_GST_Amount <> P2.teSF_Share_GST_Amount) then begin
    P3.teSF_Share_GST_Amount := P1.teSF_Share_GST_Amount;
    ChangedFields[i] := tkteSF_Share_GST_Amount;
    Inc(i);
  end;
  if (P1.teSF_Share_GST_Rate <> P2.teSF_Share_GST_Rate) then begin
    P3.teSF_Share_GST_Rate := P1.teSF_Share_GST_Rate;
    ChangedFields[i] := tkteSF_Share_GST_Rate;
    Inc(i);
  end;
  if (P1.teSF_Cash_Date <> P2.teSF_Cash_Date) then begin
    P3.teSF_Cash_Date := P1.teSF_Cash_Date;
    ChangedFields[i] := tkteSF_Cash_Date;
    Inc(i);
  end;
  if (P1.teSF_Accrual_Date <> P2.teSF_Accrual_Date) then begin
    P3.teSF_Accrual_Date := P1.teSF_Accrual_Date;
    ChangedFields[i] := tkteSF_Accrual_Date;
    Inc(i);
  end;
  if (P1.teSF_Record_Date <> P2.teSF_Record_Date) then begin
    P3.teSF_Record_Date := P1.teSF_Record_Date;
    ChangedFields[i] := tkteSF_Record_Date;
    Inc(i);
  end;
  if (P1.teSF_Contract_Date <> P2.teSF_Contract_Date) then begin
    P3.teSF_Contract_Date := P1.teSF_Contract_Date;
    ChangedFields[i] := tkteSF_Contract_Date;
    Inc(i);
  end;
  if (P1.teSF_Settlement_Date <> P2.teSF_Settlement_Date) then begin
    P3.teSF_Settlement_Date := P1.teSF_Settlement_Date;
    ChangedFields[i] := tkteSF_Settlement_Date;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Transaction_Extension_Rec(P1, P2: pTransaction_Extension_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Transaction_Extension_Rec(P1^, S);
    S.Position := 0;
    Read_Transaction_Extension_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
