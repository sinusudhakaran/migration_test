UNIT BKdeIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Dissection_Extension         = 182 ;
   tkEnd_Dissection_Extension           = 183 ;

FUNCTION  IsADissection_Extension_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Dissection_Extension_Rec ( Var O : TDissection_Extension_Rec ; Var F : TIOStream );
PROCEDURE Read_Dissection_Extension_Rec ( Var O : TDissection_Extension_Rec ; Var F : TIOStream );
FUNCTION  New_Dissection_Extension_Rec : pDissection_Extension_Rec ;
PROCEDURE Free_Dissection_Extension_Rec_Dynamic_Fields ( Var O : TDissection_Extension_Rec );
FUNCTION Dissection_Extension_Rec_Delta(P1, P2, P3: pDissection_Extension_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Dissection_Extension_Rec(P1, P2: pDissection_Extension_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKDEIO';
   SBoundsError        = 'BKDEIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKDEIO Error: Pointer is NIL in IsADissection_Extension_Rec';
   SInvalidType        = 'BKDEIO Error: Type is invalid in IsADissection_Extension_Rec';
   SInvalidEOR         = 'BKDEIO Error: EOR is missing in IsADissection_Extension_Rec';
   SUnknownToken       = 'BKDEIO Error: Unknown token %d in Read_Dissection_Extension_Rec';
   SInsufficientMemory = 'BKDEIO Error: Out of memory in New_Dissection_Extension_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdeSequence_No                      = 184 ;
   tkdeSF_Other_Income                  = 185 ;
   tkdeSF_Other_Trust_Deductions        = 186 ;
   tkdeSF_CGT_Concession_Amount         = 187 ;
   tkdeSF_CGT_ForeignCGT_Before_Disc    = 188 ;
   tkdeSF_CGT_ForeignCGT_Indexation     = 189 ;
   tkdeSF_CGT_ForeignCGT_Other_Method   = 190 ;
   tkdeSF_CGT_TaxPaid_Indexation        = 191 ;
   tkdeSF_CGT_TaxPaid_Other_Method      = 192 ;
   tkdeSF_Other_Net_Foreign_Income      = 193 ;
   tkdeSF_Cash_Distribution             = 194 ;
   tkdeSF_AU_Franking_Credits_NZ_Co     = 195 ;
   tkdeSF_Non_Res_Witholding_Tax        = 196 ;
   tkdeSF_LIC_Deductions                = 197 ;
   tkdeSF_Non_Cash_CGT_Discounted_Before_Discount = 198 ;
   tkdeSF_Non_Cash_CGT_Indexation       = 199 ;
   tkdeSF_Non_Cash_CGT_Other_Method     = 200 ;
   tkdeSF_Non_Cash_CGT_Capital_Losses   = 201 ;
   tkdeSF_Share_Brokerage               = 202 ;
   tkdeSF_Share_Consideration           = 203 ;
   tkdeSF_Share_GST_Amount              = 204 ;
   tkdeSF_Share_GST_Rate                = 205 ;
   tkdeSF_Cash_Date                     = 206 ;
   tkdeSF_Accrual_Date                  = 207 ;
   tkdeSF_Record_Date                   = 208 ;
   tkdeSF_Contract_Date                 = 209 ;
   tkdeSF_Settlement_Date               = 210 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADissection_Extension_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PDissection_Extension_Rec ( P )^ do Begin
      If deRecord_Type <> tkBegin_Dissection_Extension then
         Raise ECorruptData.Create( SInvalidType );
      If deEOR <> tkEnd_Dissection_Extension then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Dissection_Extension_Rec ( Var O : TDissection_Extension_Rec ; Var F : TIOStream );

Begin
   If IsADissection_Extension_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Dissection_Extension );
      F.WriteIntegerValue( tkdeSequence_No , deSequence_No );
      F.WriteMoneyValue( tkdeSF_Other_Income , deSF_Other_Income );
      F.WriteMoneyValue( tkdeSF_Other_Trust_Deductions , deSF_Other_Trust_Deductions );
      F.WriteMoneyValue( tkdeSF_CGT_Concession_Amount , deSF_CGT_Concession_Amount );
      F.WriteMoneyValue( tkdeSF_CGT_ForeignCGT_Before_Disc , deSF_CGT_ForeignCGT_Before_Disc );
      F.WriteMoneyValue( tkdeSF_CGT_ForeignCGT_Indexation , deSF_CGT_ForeignCGT_Indexation );
      F.WriteMoneyValue( tkdeSF_CGT_ForeignCGT_Other_Method , deSF_CGT_ForeignCGT_Other_Method );
      F.WriteMoneyValue( tkdeSF_CGT_TaxPaid_Indexation , deSF_CGT_TaxPaid_Indexation );
      F.WriteMoneyValue( tkdeSF_CGT_TaxPaid_Other_Method , deSF_CGT_TaxPaid_Other_Method );
      F.WriteMoneyValue( tkdeSF_Other_Net_Foreign_Income , deSF_Other_Net_Foreign_Income );
      F.WriteMoneyValue( tkdeSF_Cash_Distribution , deSF_Cash_Distribution );
      F.WriteMoneyValue( tkdeSF_AU_Franking_Credits_NZ_Co , deSF_AU_Franking_Credits_NZ_Co );
      F.WriteMoneyValue( tkdeSF_Non_Res_Witholding_Tax , deSF_Non_Res_Witholding_Tax );
      F.WriteMoneyValue( tkdeSF_LIC_Deductions , deSF_LIC_Deductions );
      F.WriteMoneyValue( tkdeSF_Non_Cash_CGT_Discounted_Before_Discount , deSF_Non_Cash_CGT_Discounted_Before_Discount );
      F.WriteMoneyValue( tkdeSF_Non_Cash_CGT_Indexation , deSF_Non_Cash_CGT_Indexation );
      F.WriteMoneyValue( tkdeSF_Non_Cash_CGT_Other_Method , deSF_Non_Cash_CGT_Other_Method );
      F.WriteMoneyValue( tkdeSF_Non_Cash_CGT_Capital_Losses , deSF_Non_Cash_CGT_Capital_Losses );
      F.WriteMoneyValue( tkdeSF_Share_Brokerage , deSF_Share_Brokerage );
      F.WriteMoneyValue( tkdeSF_Share_Consideration , deSF_Share_Consideration );
      F.WriteMoneyValue( tkdeSF_Share_GST_Amount , deSF_Share_GST_Amount );
      F.WriteStringValue( tkdeSF_Share_GST_Rate , deSF_Share_GST_Rate );
      F.WriteDateValue( tkdeSF_Cash_Date , deSF_Cash_Date );
      F.WriteDateValue( tkdeSF_Accrual_Date , deSF_Accrual_Date );
      F.WriteDateValue( tkdeSF_Record_Date , deSF_Record_Date );
      F.WriteDateValue( tkdeSF_Contract_Date , deSF_Contract_Date );
      F.WriteDateValue( tkdeSF_Settlement_Date , deSF_Settlement_Date );
      F.WriteToken( tkEnd_Dissection_Extension );
   end;
end; { of Write_Dissection_Extension_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Dissection_Extension_Rec ( Var O : TDissection_Extension_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Dissection_Extension_Rec_Size, 0 );
   O.deRecord_Type := tkBegin_Dissection_Extension;
   O.deEOR := tkEnd_Dissection_Extension;
   Token := tkBegin_Dissection_Extension;

   While Token <> tkEnd_Dissection_Extension do With O do
   Begin
      Case Token of
         tkBegin_Dissection_Extension :; { Do Nothing }
         tkEnd_Dissection_Extension :; { Do Nothing }
         tkdeSequence_No                      : deSequence_No := F.ReadIntegerValue;
         tkdeSF_Other_Income                  : deSF_Other_Income := F.ReadMoneyValue;
         tkdeSF_Other_Trust_Deductions        : deSF_Other_Trust_Deductions := F.ReadMoneyValue;
         tkdeSF_CGT_Concession_Amount         : deSF_CGT_Concession_Amount := F.ReadMoneyValue;
         tkdeSF_CGT_ForeignCGT_Before_Disc    : deSF_CGT_ForeignCGT_Before_Disc := F.ReadMoneyValue;
         tkdeSF_CGT_ForeignCGT_Indexation     : deSF_CGT_ForeignCGT_Indexation := F.ReadMoneyValue;
         tkdeSF_CGT_ForeignCGT_Other_Method   : deSF_CGT_ForeignCGT_Other_Method := F.ReadMoneyValue;
         tkdeSF_CGT_TaxPaid_Indexation        : deSF_CGT_TaxPaid_Indexation := F.ReadMoneyValue;
         tkdeSF_CGT_TaxPaid_Other_Method      : deSF_CGT_TaxPaid_Other_Method := F.ReadMoneyValue;
         tkdeSF_Other_Net_Foreign_Income      : deSF_Other_Net_Foreign_Income := F.ReadMoneyValue;
         tkdeSF_Cash_Distribution             : deSF_Cash_Distribution := F.ReadMoneyValue;
         tkdeSF_AU_Franking_Credits_NZ_Co     : deSF_AU_Franking_Credits_NZ_Co := F.ReadMoneyValue;
         tkdeSF_Non_Res_Witholding_Tax        : deSF_Non_Res_Witholding_Tax := F.ReadMoneyValue;
         tkdeSF_LIC_Deductions                : deSF_LIC_Deductions := F.ReadMoneyValue;
         tkdeSF_Non_Cash_CGT_Discounted_Before_Discount : deSF_Non_Cash_CGT_Discounted_Before_Discount := F.ReadMoneyValue;
         tkdeSF_Non_Cash_CGT_Indexation       : deSF_Non_Cash_CGT_Indexation := F.ReadMoneyValue;
         tkdeSF_Non_Cash_CGT_Other_Method     : deSF_Non_Cash_CGT_Other_Method := F.ReadMoneyValue;
         tkdeSF_Non_Cash_CGT_Capital_Losses   : deSF_Non_Cash_CGT_Capital_Losses := F.ReadMoneyValue;
         tkdeSF_Share_Brokerage               : deSF_Share_Brokerage := F.ReadMoneyValue;
         tkdeSF_Share_Consideration           : deSF_Share_Consideration := F.ReadMoneyValue;
         tkdeSF_Share_GST_Amount              : deSF_Share_GST_Amount := F.ReadMoneyValue;
         tkdeSF_Share_GST_Rate                : deSF_Share_GST_Rate := F.ReadStringValue;
         tkdeSF_Cash_Date                     : deSF_Cash_Date := F.ReadDateValue;
         tkdeSF_Accrual_Date                  : deSF_Accrual_Date := F.ReadDateValue;
         tkdeSF_Record_Date                   : deSF_Record_Date := F.ReadDateValue;
         tkdeSF_Contract_Date                 : deSF_Contract_Date := F.ReadDateValue;
         tkdeSF_Settlement_Date               : deSF_Settlement_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Dissection_Extension_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Dissection_Extension_Rec : pDissection_Extension_Rec ;

Var
   P : pDissection_Extension_Rec;
Begin
   SafeGetMem( P, Dissection_Extension_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Dissection_Extension_Rec_Size, 0 );
      deRecord_Type := tkBegin_Dissection_Extension;
      deEOR         := tkEnd_Dissection_Extension;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Dissection_Extension_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Dissection_Extension_Rec_Dynamic_Fields ( Var O : TDissection_Extension_Rec );

Begin
   If IsADissection_Extension_Rec ( @O ) then With O do
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
  for i := tkdeSequence_No to tkdeSF_Settlement_Date do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Dissection_Extension_Rec_Delta(P1, P2, P3: pDissection_Extension_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Dissection_Extension_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.deSequence_No <> P2.deSequence_No) then begin
    P3.deSequence_No := P1.deSequence_No;
    ChangedFields[i] := tkdeSequence_No;
    Inc(i);
  end;
  if (P1.deSF_Other_Income <> P2.deSF_Other_Income) then begin
    P3.deSF_Other_Income := P1.deSF_Other_Income;
    ChangedFields[i] := tkdeSF_Other_Income;
    Inc(i);
  end;
  if (P1.deSF_Other_Trust_Deductions <> P2.deSF_Other_Trust_Deductions) then begin
    P3.deSF_Other_Trust_Deductions := P1.deSF_Other_Trust_Deductions;
    ChangedFields[i] := tkdeSF_Other_Trust_Deductions;
    Inc(i);
  end;
  if (P1.deSF_CGT_Concession_Amount <> P2.deSF_CGT_Concession_Amount) then begin
    P3.deSF_CGT_Concession_Amount := P1.deSF_CGT_Concession_Amount;
    ChangedFields[i] := tkdeSF_CGT_Concession_Amount;
    Inc(i);
  end;
  if (P1.deSF_CGT_ForeignCGT_Before_Disc <> P2.deSF_CGT_ForeignCGT_Before_Disc) then begin
    P3.deSF_CGT_ForeignCGT_Before_Disc := P1.deSF_CGT_ForeignCGT_Before_Disc;
    ChangedFields[i] := tkdeSF_CGT_ForeignCGT_Before_Disc;
    Inc(i);
  end;
  if (P1.deSF_CGT_ForeignCGT_Indexation <> P2.deSF_CGT_ForeignCGT_Indexation) then begin
    P3.deSF_CGT_ForeignCGT_Indexation := P1.deSF_CGT_ForeignCGT_Indexation;
    ChangedFields[i] := tkdeSF_CGT_ForeignCGT_Indexation;
    Inc(i);
  end;
  if (P1.deSF_CGT_ForeignCGT_Other_Method <> P2.deSF_CGT_ForeignCGT_Other_Method) then begin
    P3.deSF_CGT_ForeignCGT_Other_Method := P1.deSF_CGT_ForeignCGT_Other_Method;
    ChangedFields[i] := tkdeSF_CGT_ForeignCGT_Other_Method;
    Inc(i);
  end;
  if (P1.deSF_CGT_TaxPaid_Indexation <> P2.deSF_CGT_TaxPaid_Indexation) then begin
    P3.deSF_CGT_TaxPaid_Indexation := P1.deSF_CGT_TaxPaid_Indexation;
    ChangedFields[i] := tkdeSF_CGT_TaxPaid_Indexation;
    Inc(i);
  end;
  if (P1.deSF_CGT_TaxPaid_Other_Method <> P2.deSF_CGT_TaxPaid_Other_Method) then begin
    P3.deSF_CGT_TaxPaid_Other_Method := P1.deSF_CGT_TaxPaid_Other_Method;
    ChangedFields[i] := tkdeSF_CGT_TaxPaid_Other_Method;
    Inc(i);
  end;
  if (P1.deSF_Other_Net_Foreign_Income <> P2.deSF_Other_Net_Foreign_Income) then begin
    P3.deSF_Other_Net_Foreign_Income := P1.deSF_Other_Net_Foreign_Income;
    ChangedFields[i] := tkdeSF_Other_Net_Foreign_Income;
    Inc(i);
  end;
  if (P1.deSF_Cash_Distribution <> P2.deSF_Cash_Distribution) then begin
    P3.deSF_Cash_Distribution := P1.deSF_Cash_Distribution;
    ChangedFields[i] := tkdeSF_Cash_Distribution;
    Inc(i);
  end;
  if (P1.deSF_AU_Franking_Credits_NZ_Co <> P2.deSF_AU_Franking_Credits_NZ_Co) then begin
    P3.deSF_AU_Franking_Credits_NZ_Co := P1.deSF_AU_Franking_Credits_NZ_Co;
    ChangedFields[i] := tkdeSF_AU_Franking_Credits_NZ_Co;
    Inc(i);
  end;
  if (P1.deSF_Non_Res_Witholding_Tax <> P2.deSF_Non_Res_Witholding_Tax) then begin
    P3.deSF_Non_Res_Witholding_Tax := P1.deSF_Non_Res_Witholding_Tax;
    ChangedFields[i] := tkdeSF_Non_Res_Witholding_Tax;
    Inc(i);
  end;
  if (P1.deSF_LIC_Deductions <> P2.deSF_LIC_Deductions) then begin
    P3.deSF_LIC_Deductions := P1.deSF_LIC_Deductions;
    ChangedFields[i] := tkdeSF_LIC_Deductions;
    Inc(i);
  end;
  if (P1.deSF_Non_Cash_CGT_Discounted_Before_Discount <> P2.deSF_Non_Cash_CGT_Discounted_Before_Discount) then begin
    P3.deSF_Non_Cash_CGT_Discounted_Before_Discount := P1.deSF_Non_Cash_CGT_Discounted_Before_Discount;
    ChangedFields[i] := tkdeSF_Non_Cash_CGT_Discounted_Before_Discount;
    Inc(i);
  end;
  if (P1.deSF_Non_Cash_CGT_Indexation <> P2.deSF_Non_Cash_CGT_Indexation) then begin
    P3.deSF_Non_Cash_CGT_Indexation := P1.deSF_Non_Cash_CGT_Indexation;
    ChangedFields[i] := tkdeSF_Non_Cash_CGT_Indexation;
    Inc(i);
  end;
  if (P1.deSF_Non_Cash_CGT_Other_Method <> P2.deSF_Non_Cash_CGT_Other_Method) then begin
    P3.deSF_Non_Cash_CGT_Other_Method := P1.deSF_Non_Cash_CGT_Other_Method;
    ChangedFields[i] := tkdeSF_Non_Cash_CGT_Other_Method;
    Inc(i);
  end;
  if (P1.deSF_Non_Cash_CGT_Capital_Losses <> P2.deSF_Non_Cash_CGT_Capital_Losses) then begin
    P3.deSF_Non_Cash_CGT_Capital_Losses := P1.deSF_Non_Cash_CGT_Capital_Losses;
    ChangedFields[i] := tkdeSF_Non_Cash_CGT_Capital_Losses;
    Inc(i);
  end;
  if (P1.deSF_Share_Brokerage <> P2.deSF_Share_Brokerage) then begin
    P3.deSF_Share_Brokerage := P1.deSF_Share_Brokerage;
    ChangedFields[i] := tkdeSF_Share_Brokerage;
    Inc(i);
  end;
  if (P1.deSF_Share_Consideration <> P2.deSF_Share_Consideration) then begin
    P3.deSF_Share_Consideration := P1.deSF_Share_Consideration;
    ChangedFields[i] := tkdeSF_Share_Consideration;
    Inc(i);
  end;
  if (P1.deSF_Share_GST_Amount <> P2.deSF_Share_GST_Amount) then begin
    P3.deSF_Share_GST_Amount := P1.deSF_Share_GST_Amount;
    ChangedFields[i] := tkdeSF_Share_GST_Amount;
    Inc(i);
  end;
  if (P1.deSF_Share_GST_Rate <> P2.deSF_Share_GST_Rate) then begin
    P3.deSF_Share_GST_Rate := P1.deSF_Share_GST_Rate;
    ChangedFields[i] := tkdeSF_Share_GST_Rate;
    Inc(i);
  end;
  if (P1.deSF_Cash_Date <> P2.deSF_Cash_Date) then begin
    P3.deSF_Cash_Date := P1.deSF_Cash_Date;
    ChangedFields[i] := tkdeSF_Cash_Date;
    Inc(i);
  end;
  if (P1.deSF_Accrual_Date <> P2.deSF_Accrual_Date) then begin
    P3.deSF_Accrual_Date := P1.deSF_Accrual_Date;
    ChangedFields[i] := tkdeSF_Accrual_Date;
    Inc(i);
  end;
  if (P1.deSF_Record_Date <> P2.deSF_Record_Date) then begin
    P3.deSF_Record_Date := P1.deSF_Record_Date;
    ChangedFields[i] := tkdeSF_Record_Date;
    Inc(i);
  end;
  if (P1.deSF_Contract_Date <> P2.deSF_Contract_Date) then begin
    P3.deSF_Contract_Date := P1.deSF_Contract_Date;
    ChangedFields[i] := tkdeSF_Contract_Date;
    Inc(i);
  end;
  if (P1.deSF_Settlement_Date <> P2.deSF_Settlement_Date) then begin
    P3.deSF_Settlement_Date := P1.deSF_Settlement_Date;
    ChangedFields[i] := tkdeSF_Settlement_Date;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Dissection_Extension_Rec(P1, P2: pDissection_Extension_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Dissection_Extension_Rec(P1^, S);
    S.Position := 0;
    Read_Dissection_Extension_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
