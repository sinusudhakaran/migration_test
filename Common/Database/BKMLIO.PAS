UNIT BKmlIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Memorisation_Line            = 145 ;
   tkEnd_Memorisation_Line              = 146 ;

FUNCTION  IsAMemorisation_Line_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );
PROCEDURE Read_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );
FUNCTION  New_Memorisation_Line_Rec : pMemorisation_Line_Rec ;
PROCEDURE Free_Memorisation_Line_Rec_Dynamic_Fields ( Var O : TMemorisation_Line_Rec );
FUNCTION Memorisation_Line_Rec_Delta(P1, P2, P3: pMemorisation_Line_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Memorisation_Line_Rec(P1, P2: pMemorisation_Line_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMLIO';
   SBoundsError        = 'BKMLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMLIO Error: Pointer is NIL in IsAMemorisation_Line_Rec';
   SInvalidType        = 'BKMLIO Error: Type is invalid in IsAMemorisation_Line_Rec';
   SInvalidEOR         = 'BKMLIO Error: EOR is missing in IsAMemorisation_Line_Rec';
   SUnknownToken       = 'BKMLIO Error: Unknown token %d in Read_Memorisation_Line_Rec';
   SInsufficientMemory = 'BKMLIO Error: Out of memory in New_Memorisation_Line_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmlAccount                          = 147 ;
   tkmlPercentage                       = 148 ;
   tkmlGST_Class                        = 149 ;
   tkmlGST_Has_Been_Edited              = 150 ;
   tkmlGL_Narration                     = 151 ;
   tkmlLine_Type                        = 152 ;
   tkmlGST_Amount                       = 153 ;
   tkmlPayee                            = 154 ;
   tkmlSF_PCFranked                     = 155 ;
   tkmlSF_Member_ID                     = 156 ;
   tkmlSF_Fund_ID                       = 157 ;
   tkmlSF_Fund_Code                     = 158 ;
   tkmlSF_Trans_ID                      = 159 ;
   tkmlSF_Trans_Code                    = 160 ;
   tkmlSF_Member_Account_ID             = 161 ;
   tkmlSF_Member_Account_Code           = 162 ;
   tkmlSF_Edited                        = 163 ;
   tkmlSF_Member_Component              = 164 ;
   tkmlSF_PCUnFranked                   = 165 ;
   tkmlJob_Code                         = 166 ;
   tkmlQuantity                         = 167 ;
   tkmlSF_GDT_Date                      = 168 ;
   tkmlSF_Tax_Free_Dist                 = 169 ;
   tkmlSF_Tax_Exempt_Dist               = 170 ;
   tkmlSF_Tax_Deferred_Dist             = 171 ;
   tkmlSF_TFN_Credits                   = 172 ;
   tkmlSF_Foreign_Income                = 173 ;
   tkmlSF_Foreign_Tax_Credits           = 174 ;
   tkmlSF_Capital_Gains_Indexed         = 175 ;
   tkmlSF_Capital_Gains_Disc            = 176 ;
   tkmlSF_Capital_Gains_Other           = 177 ;
   tkmlSF_Other_Expenses                = 178 ;
   tkmlSF_Interest                      = 179 ;
   tkmlSF_Capital_Gains_Foreign_Disc    = 180 ;
   tkmlSF_Rent                          = 181 ;
   tkmlSF_Special_Income                = 182 ;
   tkmlSF_Other_Tax_Credit              = 183 ;
   tkmlSF_Non_Resident_Tax              = 184 ;
   tkmlSF_Foreign_Capital_Gains_Credit  = 185 ;
   tkmlSF_Capital_Gains_Fraction_Half   = 186 ;
   tkmlAudit_Record_ID                  = 187 ;
   tkmlSF_Imputed_Credit                = 188 ;
   tkmlSF_Other_Income                  = 189 ;
   tkmlSF_Other_Trust_Deductions        = 190 ;
   tkmlSF_CGT_Concession_Amount         = 191 ;
   tkmlSF_CGT_ForeignCGT_Before_Disc    = 192 ;
   tkmlSF_CGT_ForeignCGT_Indexation     = 193 ;
   tkmlSF_CGT_ForeignCGT_Other_Method   = 194 ;
   tkmlSF_CGT_TaxPaid_Indexation        = 195 ;
   tkmlSF_CGT_TaxPaid_Other_Method      = 196 ;
   tkmlSF_Other_Net_Foreign_Income      = 197 ;
   tkmlSF_Cash_Distribution             = 198 ;
   tkmlSF_AU_Franking_Credits_NZ_Co     = 199 ;
   tkmlSF_Non_Res_Witholding_Tax        = 200 ;
   tkmlSF_LIC_Deductions                = 201 ;
   tkmlSF_Non_Cash_CGT_Discounted_Before_Discount = 202 ;
   tkmlSF_Non_Cash_CGT_Indexation       = 203 ;
   tkmlSF_Non_Cash_CGT_Other_Method     = 204 ;
   tkmlSF_Non_Cash_CGT_Capital_Losses   = 205 ;
   tkmlSF_Share_Brokerage               = 206 ;
   tkmlSF_Share_Consideration           = 207 ;
   tkmlSF_Share_GST_Amount              = 208 ;
   tkmlSF_Share_GST_Rate                = 209 ;
   tkmlSF_Cash_Date                     = 210 ;
   tkmlSF_Accrual_Date                  = 211 ;
   tkmlSF_Record_Date                   = 212 ;
   tkmlSF_Contract_Date                 = 213 ;
   tkmlSF_Settlement_Date               = 214 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMemorisation_Line_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMemorisation_Line_Rec ( P )^ do Begin
      If mlRecord_Type <> tkBegin_Memorisation_Line then
         Raise ECorruptData.Create( SInvalidType );
      If mlEOR <> tkEnd_Memorisation_Line then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec ; Var F : TIOStream );

Begin
   If IsAMemorisation_Line_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Memorisation_Line );
      F.WriteStringValue( tkmlAccount , mlAccount );
      F.WriteMoneyValue( tkmlPercentage , mlPercentage );
      F.WriteByteValue( tkmlGST_Class , mlGST_Class );
      F.WriteBooleanValue( tkmlGST_Has_Been_Edited , mlGST_Has_Been_Edited );
      F.WriteAnsiStringValue( tkmlGL_Narration , mlGL_Narration );
      F.WriteByteValue( tkmlLine_Type , mlLine_Type );
      F.WriteMoneyValue( tkmlGST_Amount , mlGST_Amount );
      F.WriteIntegerValue( tkmlPayee , mlPayee );
      F.WriteMoneyValue( tkmlSF_PCFranked , mlSF_PCFranked );
      F.WriteStringValue( tkmlSF_Member_ID , mlSF_Member_ID );
      F.WriteIntegerValue( tkmlSF_Fund_ID , mlSF_Fund_ID );
      F.WriteStringValue( tkmlSF_Fund_Code , mlSF_Fund_Code );
      F.WriteIntegerValue( tkmlSF_Trans_ID , mlSF_Trans_ID );
      F.WriteAnsiStringValue( tkmlSF_Trans_Code , mlSF_Trans_Code );
      F.WriteIntegerValue( tkmlSF_Member_Account_ID , mlSF_Member_Account_ID );
      F.WriteStringValue( tkmlSF_Member_Account_Code , mlSF_Member_Account_Code );
      F.WriteBooleanValue( tkmlSF_Edited , mlSF_Edited );
      F.WriteByteValue( tkmlSF_Member_Component , mlSF_Member_Component );
      F.WriteMoneyValue( tkmlSF_PCUnFranked , mlSF_PCUnFranked );
      F.WriteStringValue( tkmlJob_Code , mlJob_Code );
      F.WriteMoneyValue( tkmlQuantity , mlQuantity );
      F.WriteDateValue( tkmlSF_GDT_Date , mlSF_GDT_Date );
      F.WriteMoneyValue( tkmlSF_Tax_Free_Dist , mlSF_Tax_Free_Dist );
      F.WriteMoneyValue( tkmlSF_Tax_Exempt_Dist , mlSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tkmlSF_Tax_Deferred_Dist , mlSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tkmlSF_TFN_Credits , mlSF_TFN_Credits );
      F.WriteMoneyValue( tkmlSF_Foreign_Income , mlSF_Foreign_Income );
      F.WriteMoneyValue( tkmlSF_Foreign_Tax_Credits , mlSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Indexed , mlSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Disc , mlSF_Capital_Gains_Disc );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Other , mlSF_Capital_Gains_Other );
      F.WriteMoneyValue( tkmlSF_Other_Expenses , mlSF_Other_Expenses );
      F.WriteMoneyValue( tkmlSF_Interest , mlSF_Interest );
      F.WriteMoneyValue( tkmlSF_Capital_Gains_Foreign_Disc , mlSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tkmlSF_Rent , mlSF_Rent );
      F.WriteMoneyValue( tkmlSF_Special_Income , mlSF_Special_Income );
      F.WriteMoneyValue( tkmlSF_Other_Tax_Credit , mlSF_Other_Tax_Credit );
      F.WriteMoneyValue( tkmlSF_Non_Resident_Tax , mlSF_Non_Resident_Tax );
      F.WriteMoneyValue( tkmlSF_Foreign_Capital_Gains_Credit , mlSF_Foreign_Capital_Gains_Credit );
      F.WriteBooleanValue( tkmlSF_Capital_Gains_Fraction_Half , mlSF_Capital_Gains_Fraction_Half );
      F.WriteIntegerValue( tkmlAudit_Record_ID , mlAudit_Record_ID );
      F.WriteMoneyValue( tkmlSF_Imputed_Credit , mlSF_Imputed_Credit );
      F.WriteMoneyValue( tkmlSF_Other_Income , mlSF_Other_Income );
      F.WriteMoneyValue( tkmlSF_Other_Trust_Deductions , mlSF_Other_Trust_Deductions );
      F.WriteMoneyValue( tkmlSF_CGT_Concession_Amount , mlSF_CGT_Concession_Amount );
      F.WriteMoneyValue( tkmlSF_CGT_ForeignCGT_Before_Disc , mlSF_CGT_ForeignCGT_Before_Disc );
      F.WriteMoneyValue( tkmlSF_CGT_ForeignCGT_Indexation , mlSF_CGT_ForeignCGT_Indexation );
      F.WriteMoneyValue( tkmlSF_CGT_ForeignCGT_Other_Method , mlSF_CGT_ForeignCGT_Other_Method );
      F.WriteMoneyValue( tkmlSF_CGT_TaxPaid_Indexation , mlSF_CGT_TaxPaid_Indexation );
      F.WriteMoneyValue( tkmlSF_CGT_TaxPaid_Other_Method , mlSF_CGT_TaxPaid_Other_Method );
      F.WriteMoneyValue( tkmlSF_Other_Net_Foreign_Income , mlSF_Other_Net_Foreign_Income );
      F.WriteMoneyValue( tkmlSF_Cash_Distribution , mlSF_Cash_Distribution );
      F.WriteMoneyValue( tkmlSF_AU_Franking_Credits_NZ_Co , mlSF_AU_Franking_Credits_NZ_Co );
      F.WriteMoneyValue( tkmlSF_Non_Res_Witholding_Tax , mlSF_Non_Res_Witholding_Tax );
      F.WriteMoneyValue( tkmlSF_LIC_Deductions , mlSF_LIC_Deductions );
      F.WriteMoneyValue( tkmlSF_Non_Cash_CGT_Discounted_Before_Discount , mlSF_Non_Cash_CGT_Discounted_Before_Discount );
      F.WriteMoneyValue( tkmlSF_Non_Cash_CGT_Indexation , mlSF_Non_Cash_CGT_Indexation );
      F.WriteMoneyValue( tkmlSF_Non_Cash_CGT_Other_Method , mlSF_Non_Cash_CGT_Other_Method );
      F.WriteMoneyValue( tkmlSF_Non_Cash_CGT_Capital_Losses , mlSF_Non_Cash_CGT_Capital_Losses );
      F.WriteMoneyValue( tkmlSF_Share_Brokerage , mlSF_Share_Brokerage );
      F.WriteMoneyValue( tkmlSF_Share_Consideration , mlSF_Share_Consideration );
      F.WriteMoneyValue( tkmlSF_Share_GST_Amount , mlSF_Share_GST_Amount );
      F.WriteStringValue( tkmlSF_Share_GST_Rate , mlSF_Share_GST_Rate );
      F.WriteDateValue( tkmlSF_Cash_Date , mlSF_Cash_Date );
      F.WriteDateValue( tkmlSF_Accrual_Date , mlSF_Accrual_Date );
      F.WriteDateValue( tkmlSF_Record_Date , mlSF_Record_Date );
      F.WriteDateValue( tkmlSF_Contract_Date , mlSF_Contract_Date );
      F.WriteDateValue( tkmlSF_Settlement_Date , mlSF_Settlement_Date );
      F.WriteToken( tkEnd_Memorisation_Line );
   end;
end; { of Write_Memorisation_Line_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Memorisation_Line_Rec ( Var O : TMemorisation_Line_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Memorisation_Line_Rec_Size, 0 );
   O.mlRecord_Type := tkBegin_Memorisation_Line;
   O.mlEOR := tkEnd_Memorisation_Line;
   Token := tkBegin_Memorisation_Line;

   While Token <> tkEnd_Memorisation_Line do With O do
   Begin
      Case Token of
         tkBegin_Memorisation_Line :; { Do Nothing }
         tkEnd_Memorisation_Line :; { Do Nothing }
         tkmlAccount                          : mlAccount := F.ReadStringValue;
         tkmlPercentage                       : mlPercentage := F.ReadMoneyValue;
         tkmlGST_Class                        : mlGST_Class := F.ReadByteValue;
         tkmlGST_Has_Been_Edited              : mlGST_Has_Been_Edited := F.ReadBooleanValue;
         tkmlGL_Narration                     : mlGL_Narration := F.ReadAnsiStringValue;
         tkmlLine_Type                        : mlLine_Type := F.ReadByteValue;
         tkmlGST_Amount                       : mlGST_Amount := F.ReadMoneyValue;
         tkmlPayee                            : mlPayee := F.ReadIntegerValue;
         tkmlSF_PCFranked                     : mlSF_PCFranked := F.ReadMoneyValue;
         tkmlSF_Member_ID                     : mlSF_Member_ID := F.ReadStringValue;
         tkmlSF_Fund_ID                       : mlSF_Fund_ID := F.ReadIntegerValue;
         tkmlSF_Fund_Code                     : mlSF_Fund_Code := F.ReadStringValue;
         tkmlSF_Trans_ID                      : mlSF_Trans_ID := F.ReadIntegerValue;
         tkmlSF_Trans_Code                    : mlSF_Trans_Code := F.ReadAnsiStringValue;
         tkmlSF_Member_Account_ID             : mlSF_Member_Account_ID := F.ReadIntegerValue;
         tkmlSF_Member_Account_Code           : mlSF_Member_Account_Code := F.ReadStringValue;
         tkmlSF_Edited                        : mlSF_Edited := F.ReadBooleanValue;
         tkmlSF_Member_Component              : mlSF_Member_Component := F.ReadByteValue;
         tkmlSF_PCUnFranked                   : mlSF_PCUnFranked := F.ReadMoneyValue;
         tkmlJob_Code                         : mlJob_Code := F.ReadStringValue;
         tkmlQuantity                         : mlQuantity := F.ReadMoneyValue;
         tkmlSF_GDT_Date                      : mlSF_GDT_Date := F.ReadDateValue;
         tkmlSF_Tax_Free_Dist                 : mlSF_Tax_Free_Dist := F.ReadMoneyValue;
         tkmlSF_Tax_Exempt_Dist               : mlSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tkmlSF_Tax_Deferred_Dist             : mlSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tkmlSF_TFN_Credits                   : mlSF_TFN_Credits := F.ReadMoneyValue;
         tkmlSF_Foreign_Income                : mlSF_Foreign_Income := F.ReadMoneyValue;
         tkmlSF_Foreign_Tax_Credits           : mlSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Indexed         : mlSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Disc            : mlSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Other           : mlSF_Capital_Gains_Other := F.ReadMoneyValue;
         tkmlSF_Other_Expenses                : mlSF_Other_Expenses := F.ReadMoneyValue;
         tkmlSF_Interest                      : mlSF_Interest := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Foreign_Disc    : mlSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tkmlSF_Rent                          : mlSF_Rent := F.ReadMoneyValue;
         tkmlSF_Special_Income                : mlSF_Special_Income := F.ReadMoneyValue;
         tkmlSF_Other_Tax_Credit              : mlSF_Other_Tax_Credit := F.ReadMoneyValue;
         tkmlSF_Non_Resident_Tax              : mlSF_Non_Resident_Tax := F.ReadMoneyValue;
         tkmlSF_Foreign_Capital_Gains_Credit  : mlSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         tkmlSF_Capital_Gains_Fraction_Half   : mlSF_Capital_Gains_Fraction_Half := F.ReadBooleanValue;
         tkmlAudit_Record_ID                  : mlAudit_Record_ID := F.ReadIntegerValue;
         tkmlSF_Imputed_Credit                : mlSF_Imputed_Credit := F.ReadMoneyValue;
         tkmlSF_Other_Income                  : mlSF_Other_Income := F.ReadMoneyValue;
         tkmlSF_Other_Trust_Deductions        : mlSF_Other_Trust_Deductions := F.ReadMoneyValue;
         tkmlSF_CGT_Concession_Amount         : mlSF_CGT_Concession_Amount := F.ReadMoneyValue;
         tkmlSF_CGT_ForeignCGT_Before_Disc    : mlSF_CGT_ForeignCGT_Before_Disc := F.ReadMoneyValue;
         tkmlSF_CGT_ForeignCGT_Indexation     : mlSF_CGT_ForeignCGT_Indexation := F.ReadMoneyValue;
         tkmlSF_CGT_ForeignCGT_Other_Method   : mlSF_CGT_ForeignCGT_Other_Method := F.ReadMoneyValue;
         tkmlSF_CGT_TaxPaid_Indexation        : mlSF_CGT_TaxPaid_Indexation := F.ReadMoneyValue;
         tkmlSF_CGT_TaxPaid_Other_Method      : mlSF_CGT_TaxPaid_Other_Method := F.ReadMoneyValue;
         tkmlSF_Other_Net_Foreign_Income      : mlSF_Other_Net_Foreign_Income := F.ReadMoneyValue;
         tkmlSF_Cash_Distribution             : mlSF_Cash_Distribution := F.ReadMoneyValue;
         tkmlSF_AU_Franking_Credits_NZ_Co     : mlSF_AU_Franking_Credits_NZ_Co := F.ReadMoneyValue;
         tkmlSF_Non_Res_Witholding_Tax        : mlSF_Non_Res_Witholding_Tax := F.ReadMoneyValue;
         tkmlSF_LIC_Deductions                : mlSF_LIC_Deductions := F.ReadMoneyValue;
         tkmlSF_Non_Cash_CGT_Discounted_Before_Discount : mlSF_Non_Cash_CGT_Discounted_Before_Discount := F.ReadMoneyValue;
         tkmlSF_Non_Cash_CGT_Indexation       : mlSF_Non_Cash_CGT_Indexation := F.ReadMoneyValue;
         tkmlSF_Non_Cash_CGT_Other_Method     : mlSF_Non_Cash_CGT_Other_Method := F.ReadMoneyValue;
         tkmlSF_Non_Cash_CGT_Capital_Losses   : mlSF_Non_Cash_CGT_Capital_Losses := F.ReadMoneyValue;
         tkmlSF_Share_Brokerage               : mlSF_Share_Brokerage := F.ReadMoneyValue;
         tkmlSF_Share_Consideration           : mlSF_Share_Consideration := F.ReadMoneyValue;
         tkmlSF_Share_GST_Amount              : mlSF_Share_GST_Amount := F.ReadMoneyValue;
         tkmlSF_Share_GST_Rate                : mlSF_Share_GST_Rate := F.ReadStringValue;
         tkmlSF_Cash_Date                     : mlSF_Cash_Date := F.ReadDateValue;
         tkmlSF_Accrual_Date                  : mlSF_Accrual_Date := F.ReadDateValue;
         tkmlSF_Record_Date                   : mlSF_Record_Date := F.ReadDateValue;
         tkmlSF_Contract_Date                 : mlSF_Contract_Date := F.ReadDateValue;
         tkmlSF_Settlement_Date               : mlSF_Settlement_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Memorisation_Line_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Memorisation_Line_Rec : pMemorisation_Line_Rec ;

Var
   P : pMemorisation_Line_Rec;
Begin
   SafeGetMem( P, Memorisation_Line_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Memorisation_Line_Rec_Size, 0 );
      mlRecord_Type := tkBegin_Memorisation_Line;
      mlEOR         := tkEnd_Memorisation_Line;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Memorisation_Line_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Memorisation_Line_Rec_Dynamic_Fields ( Var O : TMemorisation_Line_Rec );

Begin
   If IsAMemorisation_Line_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      mlGL_Narration := '' ;
      mlSF_Trans_Code := '' ;
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
  for i := tkmlAccount to tkmlSF_Settlement_Date do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Memorisation_Line_Rec_Delta(P1, P2, P3: pMemorisation_Line_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Memorisation_Line_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.mlAccount <> P2.mlAccount) then begin
    P3.mlAccount := P1.mlAccount;
    ChangedFields[i] := tkmlAccount;
    Inc(i);
  end;
  if (P1.mlPercentage <> P2.mlPercentage) then begin
    P3.mlPercentage := P1.mlPercentage;
    ChangedFields[i] := tkmlPercentage;
    Inc(i);
  end;
  if (P1.mlGST_Class <> P2.mlGST_Class) then begin
    P3.mlGST_Class := P1.mlGST_Class;
    ChangedFields[i] := tkmlGST_Class;
    Inc(i);
  end;
  if (P1.mlGST_Has_Been_Edited <> P2.mlGST_Has_Been_Edited) then begin
    P3.mlGST_Has_Been_Edited := P1.mlGST_Has_Been_Edited;
    ChangedFields[i] := tkmlGST_Has_Been_Edited;
    Inc(i);
  end;
  if (P1.mlGL_Narration <> P2.mlGL_Narration) then begin
    P3.mlGL_Narration := P1.mlGL_Narration;
    ChangedFields[i] := tkmlGL_Narration;
    Inc(i);
  end;
  if (P1.mlLine_Type <> P2.mlLine_Type) then begin
    P3.mlLine_Type := P1.mlLine_Type;
    ChangedFields[i] := tkmlLine_Type;
    Inc(i);
  end;
  if (P1.mlGST_Amount <> P2.mlGST_Amount) then begin
    P3.mlGST_Amount := P1.mlGST_Amount;
    ChangedFields[i] := tkmlGST_Amount;
    Inc(i);
  end;
  if (P1.mlPayee <> P2.mlPayee) then begin
    P3.mlPayee := P1.mlPayee;
    ChangedFields[i] := tkmlPayee;
    Inc(i);
  end;
  if (P1.mlSF_PCFranked <> P2.mlSF_PCFranked) then begin
    P3.mlSF_PCFranked := P1.mlSF_PCFranked;
    ChangedFields[i] := tkmlSF_PCFranked;
    Inc(i);
  end;
  if (P1.mlSF_Member_ID <> P2.mlSF_Member_ID) then begin
    P3.mlSF_Member_ID := P1.mlSF_Member_ID;
    ChangedFields[i] := tkmlSF_Member_ID;
    Inc(i);
  end;
  if (P1.mlSF_Fund_ID <> P2.mlSF_Fund_ID) then begin
    P3.mlSF_Fund_ID := P1.mlSF_Fund_ID;
    ChangedFields[i] := tkmlSF_Fund_ID;
    Inc(i);
  end;
  if (P1.mlSF_Fund_Code <> P2.mlSF_Fund_Code) then begin
    P3.mlSF_Fund_Code := P1.mlSF_Fund_Code;
    ChangedFields[i] := tkmlSF_Fund_Code;
    Inc(i);
  end;
  if (P1.mlSF_Trans_ID <> P2.mlSF_Trans_ID) then begin
    P3.mlSF_Trans_ID := P1.mlSF_Trans_ID;
    ChangedFields[i] := tkmlSF_Trans_ID;
    Inc(i);
  end;
  if (P1.mlSF_Trans_Code <> P2.mlSF_Trans_Code) then begin
    P3.mlSF_Trans_Code := P1.mlSF_Trans_Code;
    ChangedFields[i] := tkmlSF_Trans_Code;
    Inc(i);
  end;
  if (P1.mlSF_Member_Account_ID <> P2.mlSF_Member_Account_ID) then begin
    P3.mlSF_Member_Account_ID := P1.mlSF_Member_Account_ID;
    ChangedFields[i] := tkmlSF_Member_Account_ID;
    Inc(i);
  end;
  if (P1.mlSF_Member_Account_Code <> P2.mlSF_Member_Account_Code) then begin
    P3.mlSF_Member_Account_Code := P1.mlSF_Member_Account_Code;
    ChangedFields[i] := tkmlSF_Member_Account_Code;
    Inc(i);
  end;
  if (P1.mlSF_Edited <> P2.mlSF_Edited) then begin
    P3.mlSF_Edited := P1.mlSF_Edited;
    ChangedFields[i] := tkmlSF_Edited;
    Inc(i);
  end;
  if (P1.mlSF_Member_Component <> P2.mlSF_Member_Component) then begin
    P3.mlSF_Member_Component := P1.mlSF_Member_Component;
    ChangedFields[i] := tkmlSF_Member_Component;
    Inc(i);
  end;
  if (P1.mlSF_PCUnFranked <> P2.mlSF_PCUnFranked) then begin
    P3.mlSF_PCUnFranked := P1.mlSF_PCUnFranked;
    ChangedFields[i] := tkmlSF_PCUnFranked;
    Inc(i);
  end;
  if (P1.mlJob_Code <> P2.mlJob_Code) then begin
    P3.mlJob_Code := P1.mlJob_Code;
    ChangedFields[i] := tkmlJob_Code;
    Inc(i);
  end;
  if (P1.mlQuantity <> P2.mlQuantity) then begin
    P3.mlQuantity := P1.mlQuantity;
    ChangedFields[i] := tkmlQuantity;
    Inc(i);
  end;
  if (P1.mlSF_GDT_Date <> P2.mlSF_GDT_Date) then begin
    P3.mlSF_GDT_Date := P1.mlSF_GDT_Date;
    ChangedFields[i] := tkmlSF_GDT_Date;
    Inc(i);
  end;
  if (P1.mlSF_Tax_Free_Dist <> P2.mlSF_Tax_Free_Dist) then begin
    P3.mlSF_Tax_Free_Dist := P1.mlSF_Tax_Free_Dist;
    ChangedFields[i] := tkmlSF_Tax_Free_Dist;
    Inc(i);
  end;
  if (P1.mlSF_Tax_Exempt_Dist <> P2.mlSF_Tax_Exempt_Dist) then begin
    P3.mlSF_Tax_Exempt_Dist := P1.mlSF_Tax_Exempt_Dist;
    ChangedFields[i] := tkmlSF_Tax_Exempt_Dist;
    Inc(i);
  end;
  if (P1.mlSF_Tax_Deferred_Dist <> P2.mlSF_Tax_Deferred_Dist) then begin
    P3.mlSF_Tax_Deferred_Dist := P1.mlSF_Tax_Deferred_Dist;
    ChangedFields[i] := tkmlSF_Tax_Deferred_Dist;
    Inc(i);
  end;
  if (P1.mlSF_TFN_Credits <> P2.mlSF_TFN_Credits) then begin
    P3.mlSF_TFN_Credits := P1.mlSF_TFN_Credits;
    ChangedFields[i] := tkmlSF_TFN_Credits;
    Inc(i);
  end;
  if (P1.mlSF_Foreign_Income <> P2.mlSF_Foreign_Income) then begin
    P3.mlSF_Foreign_Income := P1.mlSF_Foreign_Income;
    ChangedFields[i] := tkmlSF_Foreign_Income;
    Inc(i);
  end;
  if (P1.mlSF_Foreign_Tax_Credits <> P2.mlSF_Foreign_Tax_Credits) then begin
    P3.mlSF_Foreign_Tax_Credits := P1.mlSF_Foreign_Tax_Credits;
    ChangedFields[i] := tkmlSF_Foreign_Tax_Credits;
    Inc(i);
  end;
  if (P1.mlSF_Capital_Gains_Indexed <> P2.mlSF_Capital_Gains_Indexed) then begin
    P3.mlSF_Capital_Gains_Indexed := P1.mlSF_Capital_Gains_Indexed;
    ChangedFields[i] := tkmlSF_Capital_Gains_Indexed;
    Inc(i);
  end;
  if (P1.mlSF_Capital_Gains_Disc <> P2.mlSF_Capital_Gains_Disc) then begin
    P3.mlSF_Capital_Gains_Disc := P1.mlSF_Capital_Gains_Disc;
    ChangedFields[i] := tkmlSF_Capital_Gains_Disc;
    Inc(i);
  end;
  if (P1.mlSF_Capital_Gains_Other <> P2.mlSF_Capital_Gains_Other) then begin
    P3.mlSF_Capital_Gains_Other := P1.mlSF_Capital_Gains_Other;
    ChangedFields[i] := tkmlSF_Capital_Gains_Other;
    Inc(i);
  end;
  if (P1.mlSF_Other_Expenses <> P2.mlSF_Other_Expenses) then begin
    P3.mlSF_Other_Expenses := P1.mlSF_Other_Expenses;
    ChangedFields[i] := tkmlSF_Other_Expenses;
    Inc(i);
  end;
  if (P1.mlSF_Interest <> P2.mlSF_Interest) then begin
    P3.mlSF_Interest := P1.mlSF_Interest;
    ChangedFields[i] := tkmlSF_Interest;
    Inc(i);
  end;
  if (P1.mlSF_Capital_Gains_Foreign_Disc <> P2.mlSF_Capital_Gains_Foreign_Disc) then begin
    P3.mlSF_Capital_Gains_Foreign_Disc := P1.mlSF_Capital_Gains_Foreign_Disc;
    ChangedFields[i] := tkmlSF_Capital_Gains_Foreign_Disc;
    Inc(i);
  end;
  if (P1.mlSF_Rent <> P2.mlSF_Rent) then begin
    P3.mlSF_Rent := P1.mlSF_Rent;
    ChangedFields[i] := tkmlSF_Rent;
    Inc(i);
  end;
  if (P1.mlSF_Special_Income <> P2.mlSF_Special_Income) then begin
    P3.mlSF_Special_Income := P1.mlSF_Special_Income;
    ChangedFields[i] := tkmlSF_Special_Income;
    Inc(i);
  end;
  if (P1.mlSF_Other_Tax_Credit <> P2.mlSF_Other_Tax_Credit) then begin
    P3.mlSF_Other_Tax_Credit := P1.mlSF_Other_Tax_Credit;
    ChangedFields[i] := tkmlSF_Other_Tax_Credit;
    Inc(i);
  end;
  if (P1.mlSF_Non_Resident_Tax <> P2.mlSF_Non_Resident_Tax) then begin
    P3.mlSF_Non_Resident_Tax := P1.mlSF_Non_Resident_Tax;
    ChangedFields[i] := tkmlSF_Non_Resident_Tax;
    Inc(i);
  end;
  if (P1.mlSF_Foreign_Capital_Gains_Credit <> P2.mlSF_Foreign_Capital_Gains_Credit) then begin
    P3.mlSF_Foreign_Capital_Gains_Credit := P1.mlSF_Foreign_Capital_Gains_Credit;
    ChangedFields[i] := tkmlSF_Foreign_Capital_Gains_Credit;
    Inc(i);
  end;
  if (P1.mlSF_Capital_Gains_Fraction_Half <> P2.mlSF_Capital_Gains_Fraction_Half) then begin
    P3.mlSF_Capital_Gains_Fraction_Half := P1.mlSF_Capital_Gains_Fraction_Half;
    ChangedFields[i] := tkmlSF_Capital_Gains_Fraction_Half;
    Inc(i);
  end;
  if (P1.mlAudit_Record_ID <> P2.mlAudit_Record_ID) then begin
    P3.mlAudit_Record_ID := P1.mlAudit_Record_ID;
    ChangedFields[i] := tkmlAudit_Record_ID;
    Inc(i);
  end;
  if (P1.mlSF_Imputed_Credit <> P2.mlSF_Imputed_Credit) then begin
    P3.mlSF_Imputed_Credit := P1.mlSF_Imputed_Credit;
    ChangedFields[i] := tkmlSF_Imputed_Credit;
    Inc(i);
  end;
  if (P1.mlSF_Other_Income <> P2.mlSF_Other_Income) then begin
    P3.mlSF_Other_Income := P1.mlSF_Other_Income;
    ChangedFields[i] := tkmlSF_Other_Income;
    Inc(i);
  end;
  if (P1.mlSF_Other_Trust_Deductions <> P2.mlSF_Other_Trust_Deductions) then begin
    P3.mlSF_Other_Trust_Deductions := P1.mlSF_Other_Trust_Deductions;
    ChangedFields[i] := tkmlSF_Other_Trust_Deductions;
    Inc(i);
  end;
  if (P1.mlSF_CGT_Concession_Amount <> P2.mlSF_CGT_Concession_Amount) then begin
    P3.mlSF_CGT_Concession_Amount := P1.mlSF_CGT_Concession_Amount;
    ChangedFields[i] := tkmlSF_CGT_Concession_Amount;
    Inc(i);
  end;
  if (P1.mlSF_CGT_ForeignCGT_Before_Disc <> P2.mlSF_CGT_ForeignCGT_Before_Disc) then begin
    P3.mlSF_CGT_ForeignCGT_Before_Disc := P1.mlSF_CGT_ForeignCGT_Before_Disc;
    ChangedFields[i] := tkmlSF_CGT_ForeignCGT_Before_Disc;
    Inc(i);
  end;
  if (P1.mlSF_CGT_ForeignCGT_Indexation <> P2.mlSF_CGT_ForeignCGT_Indexation) then begin
    P3.mlSF_CGT_ForeignCGT_Indexation := P1.mlSF_CGT_ForeignCGT_Indexation;
    ChangedFields[i] := tkmlSF_CGT_ForeignCGT_Indexation;
    Inc(i);
  end;
  if (P1.mlSF_CGT_ForeignCGT_Other_Method <> P2.mlSF_CGT_ForeignCGT_Other_Method) then begin
    P3.mlSF_CGT_ForeignCGT_Other_Method := P1.mlSF_CGT_ForeignCGT_Other_Method;
    ChangedFields[i] := tkmlSF_CGT_ForeignCGT_Other_Method;
    Inc(i);
  end;
  if (P1.mlSF_CGT_TaxPaid_Indexation <> P2.mlSF_CGT_TaxPaid_Indexation) then begin
    P3.mlSF_CGT_TaxPaid_Indexation := P1.mlSF_CGT_TaxPaid_Indexation;
    ChangedFields[i] := tkmlSF_CGT_TaxPaid_Indexation;
    Inc(i);
  end;
  if (P1.mlSF_CGT_TaxPaid_Other_Method <> P2.mlSF_CGT_TaxPaid_Other_Method) then begin
    P3.mlSF_CGT_TaxPaid_Other_Method := P1.mlSF_CGT_TaxPaid_Other_Method;
    ChangedFields[i] := tkmlSF_CGT_TaxPaid_Other_Method;
    Inc(i);
  end;
  if (P1.mlSF_Other_Net_Foreign_Income <> P2.mlSF_Other_Net_Foreign_Income) then begin
    P3.mlSF_Other_Net_Foreign_Income := P1.mlSF_Other_Net_Foreign_Income;
    ChangedFields[i] := tkmlSF_Other_Net_Foreign_Income;
    Inc(i);
  end;
  if (P1.mlSF_Cash_Distribution <> P2.mlSF_Cash_Distribution) then begin
    P3.mlSF_Cash_Distribution := P1.mlSF_Cash_Distribution;
    ChangedFields[i] := tkmlSF_Cash_Distribution;
    Inc(i);
  end;
  if (P1.mlSF_AU_Franking_Credits_NZ_Co <> P2.mlSF_AU_Franking_Credits_NZ_Co) then begin
    P3.mlSF_AU_Franking_Credits_NZ_Co := P1.mlSF_AU_Franking_Credits_NZ_Co;
    ChangedFields[i] := tkmlSF_AU_Franking_Credits_NZ_Co;
    Inc(i);
  end;
  if (P1.mlSF_Non_Res_Witholding_Tax <> P2.mlSF_Non_Res_Witholding_Tax) then begin
    P3.mlSF_Non_Res_Witholding_Tax := P1.mlSF_Non_Res_Witholding_Tax;
    ChangedFields[i] := tkmlSF_Non_Res_Witholding_Tax;
    Inc(i);
  end;
  if (P1.mlSF_LIC_Deductions <> P2.mlSF_LIC_Deductions) then begin
    P3.mlSF_LIC_Deductions := P1.mlSF_LIC_Deductions;
    ChangedFields[i] := tkmlSF_LIC_Deductions;
    Inc(i);
  end;
  if (P1.mlSF_Non_Cash_CGT_Discounted_Before_Discount <> P2.mlSF_Non_Cash_CGT_Discounted_Before_Discount) then begin
    P3.mlSF_Non_Cash_CGT_Discounted_Before_Discount := P1.mlSF_Non_Cash_CGT_Discounted_Before_Discount;
    ChangedFields[i] := tkmlSF_Non_Cash_CGT_Discounted_Before_Discount;
    Inc(i);
  end;
  if (P1.mlSF_Non_Cash_CGT_Indexation <> P2.mlSF_Non_Cash_CGT_Indexation) then begin
    P3.mlSF_Non_Cash_CGT_Indexation := P1.mlSF_Non_Cash_CGT_Indexation;
    ChangedFields[i] := tkmlSF_Non_Cash_CGT_Indexation;
    Inc(i);
  end;
  if (P1.mlSF_Non_Cash_CGT_Other_Method <> P2.mlSF_Non_Cash_CGT_Other_Method) then begin
    P3.mlSF_Non_Cash_CGT_Other_Method := P1.mlSF_Non_Cash_CGT_Other_Method;
    ChangedFields[i] := tkmlSF_Non_Cash_CGT_Other_Method;
    Inc(i);
  end;
  if (P1.mlSF_Non_Cash_CGT_Capital_Losses <> P2.mlSF_Non_Cash_CGT_Capital_Losses) then begin
    P3.mlSF_Non_Cash_CGT_Capital_Losses := P1.mlSF_Non_Cash_CGT_Capital_Losses;
    ChangedFields[i] := tkmlSF_Non_Cash_CGT_Capital_Losses;
    Inc(i);
  end;
  if (P1.mlSF_Share_Brokerage <> P2.mlSF_Share_Brokerage) then begin
    P3.mlSF_Share_Brokerage := P1.mlSF_Share_Brokerage;
    ChangedFields[i] := tkmlSF_Share_Brokerage;
    Inc(i);
  end;
  if (P1.mlSF_Share_Consideration <> P2.mlSF_Share_Consideration) then begin
    P3.mlSF_Share_Consideration := P1.mlSF_Share_Consideration;
    ChangedFields[i] := tkmlSF_Share_Consideration;
    Inc(i);
  end;
  if (P1.mlSF_Share_GST_Amount <> P2.mlSF_Share_GST_Amount) then begin
    P3.mlSF_Share_GST_Amount := P1.mlSF_Share_GST_Amount;
    ChangedFields[i] := tkmlSF_Share_GST_Amount;
    Inc(i);
  end;
  if (P1.mlSF_Share_GST_Rate <> P2.mlSF_Share_GST_Rate) then begin
    P3.mlSF_Share_GST_Rate := P1.mlSF_Share_GST_Rate;
    ChangedFields[i] := tkmlSF_Share_GST_Rate;
    Inc(i);
  end;
  if (P1.mlSF_Cash_Date <> P2.mlSF_Cash_Date) then begin
    P3.mlSF_Cash_Date := P1.mlSF_Cash_Date;
    ChangedFields[i] := tkmlSF_Cash_Date;
    Inc(i);
  end;
  if (P1.mlSF_Accrual_Date <> P2.mlSF_Accrual_Date) then begin
    P3.mlSF_Accrual_Date := P1.mlSF_Accrual_Date;
    ChangedFields[i] := tkmlSF_Accrual_Date;
    Inc(i);
  end;
  if (P1.mlSF_Record_Date <> P2.mlSF_Record_Date) then begin
    P3.mlSF_Record_Date := P1.mlSF_Record_Date;
    ChangedFields[i] := tkmlSF_Record_Date;
    Inc(i);
  end;
  if (P1.mlSF_Contract_Date <> P2.mlSF_Contract_Date) then begin
    P3.mlSF_Contract_Date := P1.mlSF_Contract_Date;
    ChangedFields[i] := tkmlSF_Contract_Date;
    Inc(i);
  end;
  if (P1.mlSF_Settlement_Date <> P2.mlSF_Settlement_Date) then begin
    P3.mlSF_Settlement_Date := P1.mlSF_Settlement_Date;
    ChangedFields[i] := tkmlSF_Settlement_Date;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Memorisation_Line_Rec(P1, P2: pMemorisation_Line_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Memorisation_Line_Rec(P1^, S);
    S.Position := 0;
    Read_Memorisation_Line_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
