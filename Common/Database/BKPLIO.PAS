UNIT BKplIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Payee_Line                   = 95 ;
   tkEnd_Payee_Line                     = 96 ;

FUNCTION  IsAPayee_Line_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );
FUNCTION  New_Payee_Line_Rec : pPayee_Line_Rec ;
PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );
FUNCTION Payee_Line_Rec_Delta(P1, P2, P3: pPayee_Line_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Payee_Line_Rec(P1, P2: pPayee_Line_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKPLIO';
   SBoundsError        = 'BKPLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKPLIO Error: Pointer is NIL in IsAPayee_Line_Rec';
   SInvalidType        = 'BKPLIO Error: Type is invalid in IsAPayee_Line_Rec';
   SInvalidEOR         = 'BKPLIO Error: EOR is missing in IsAPayee_Line_Rec';
   SUnknownToken       = 'BKPLIO Error: Unknown token %d in Read_Payee_Line_Rec';
   SInsufficientMemory = 'BKPLIO Error: Out of memory in New_Payee_Line_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkplAccount                          = 97 ;
   tkplPercentage                       = 98 ;
   tkplGST_Class                        = 99 ;
   tkplGST_Has_Been_Edited              = 100 ;
   tkplGL_Narration                     = 101 ;
   tkplLine_Type                        = 102 ;
   tkplGST_Amount                       = 103 ;
   tkplSF_PCFranked                     = 104 ;
   tkplSF_Member_ID                     = 105 ;
   tkplSF_Fund_ID                       = 106 ;
   tkplSF_Fund_Code                     = 107 ;
   tkplSF_Trans_ID                      = 108 ;
   tkplSF_Trans_Code                    = 109 ;
   tkplSF_Member_Account_ID             = 110 ;
   tkplSF_Member_Account_Code           = 111 ;
   tkplSF_Edited                        = 112 ;
   tkplSF_Member_Component              = 113 ;
   tkplSF_PCUnFranked                   = 114 ;
   tkplQuantity                         = 115 ;
   tkplSF_GDT_Date                      = 116 ;
   tkplSF_Tax_Free_Dist                 = 117 ;
   tkplSF_Tax_Exempt_Dist               = 118 ;
   tkplSF_Tax_Deferred_Dist             = 119 ;
   tkplSF_TFN_Credits                   = 120 ;
   tkplSF_Foreign_Income                = 121 ;
   tkplSF_Foreign_Tax_Credits           = 122 ;
   tkplSF_Capital_Gains_Indexed         = 123 ;
   tkplSF_Capital_Gains_Disc            = 124 ;
   tkplSF_Capital_Gains_Other           = 125 ;
   tkplSF_Other_Expenses                = 126 ;
   tkplSF_Interest                      = 127 ;
   tkplSF_Capital_Gains_Foreign_Disc    = 128 ;
   tkplSF_Rent                          = 129 ;
   tkplSF_Special_Income                = 130 ;
   tkplSF_Other_Tax_Credit              = 131 ;
   tkplSF_Non_Resident_Tax              = 132 ;
   tkplSF_Foreign_Capital_Gains_Credit  = 133 ;
   tkplSF_Capital_Gains_Fraction_Half   = 134 ;
   tkplSF_Ledger_ID                     = 135 ;
   tkplSF_Ledger_Name                   = 136 ;
   tkplAudit_Record_ID                  = 137 ;
   tkplSF_Other_Income                  = 138 ;
   tkplSF_Other_Trust_Deductions        = 139 ;
   tkplSF_CGT_Concession_Amount         = 140 ;
   tkplSF_CGT_ForeignCGT_Before_Disc    = 141 ;
   tkplSF_CGT_ForeignCGT_Indexation     = 142 ;
   tkplSF_CGT_ForeignCGT_Other_Method   = 143 ;
   tkplSF_CGT_TaxPaid_Indexation        = 144 ;
   tkplSF_CGT_TaxPaid_Other_Method      = 145 ;
   tkplSF_Other_Net_Foreign_Income      = 146 ;
   tkplSF_Cash_Distribution             = 147 ;
   tkplSF_AU_Franking_Credits_NZ_Co     = 148 ;
   tkplSF_Non_Res_Witholding_Tax        = 149 ;
   tkplSF_LIC_Deductions                = 150 ;
   tkplSF_Non_Cash_CGT_Discounted_Before_Discount = 151 ;
   tkplSF_Non_Cash_CGT_Indexation       = 152 ;
   tkplSF_Non_Cash_CGT_Other_Method     = 153 ;
   tkplSF_Non_Cash_CGT_Capital_Losses   = 154 ;
   tkplSF_Share_Brokerage               = 155 ;
   tkplSF_Share_Consideration           = 156 ;
   tkplSF_Share_GST_Amount              = 157 ;
   tkplSF_Share_GST_Rate                = 158 ;
   tkplSF_Cash_Date                     = 159 ;
   tkplSF_Accrual_Date                  = 160 ;
   tkplSF_Record_Date                   = 161 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAPayee_Line_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PPayee_Line_Rec ( P )^ do Begin
      If plRecord_Type <> tkBegin_Payee_Line then
         Raise ECorruptData.Create( SInvalidType );
      If plEOR <> tkEnd_Payee_Line then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Payee_Line_Rec ( Var O : TPayee_Line_Rec ; Var F : TIOStream );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Payee_Line );
      F.WriteStringValue( tkplAccount , plAccount );
      F.WriteMoneyValue( tkplPercentage , plPercentage );
      F.WriteByteValue( tkplGST_Class , plGST_Class );
      F.WriteBooleanValue( tkplGST_Has_Been_Edited , plGST_Has_Been_Edited );
      F.WriteAnsiStringValue( tkplGL_Narration , plGL_Narration );
      F.WriteByteValue( tkplLine_Type , plLine_Type );
      F.WriteMoneyValue( tkplGST_Amount , plGST_Amount );
      F.WriteMoneyValue( tkplSF_PCFranked , plSF_PCFranked );
      F.WriteStringValue( tkplSF_Member_ID , plSF_Member_ID );
      F.WriteIntegerValue( tkplSF_Fund_ID , plSF_Fund_ID );
      F.WriteStringValue( tkplSF_Fund_Code , plSF_Fund_Code );
      F.WriteIntegerValue( tkplSF_Trans_ID , plSF_Trans_ID );
      F.WriteAnsiStringValue( tkplSF_Trans_Code , plSF_Trans_Code );
      F.WriteIntegerValue( tkplSF_Member_Account_ID , plSF_Member_Account_ID );
      F.WriteStringValue( tkplSF_Member_Account_Code , plSF_Member_Account_Code );
      F.WriteBooleanValue( tkplSF_Edited , plSF_Edited );
      F.WriteByteValue( tkplSF_Member_Component , plSF_Member_Component );
      F.WriteMoneyValue( tkplSF_PCUnFranked , plSF_PCUnFranked );
      F.WriteMoneyValue( tkplQuantity , plQuantity );
      F.WriteDateValue( tkplSF_GDT_Date , plSF_GDT_Date );
      F.WriteMoneyValue( tkplSF_Tax_Free_Dist , plSF_Tax_Free_Dist );
      F.WriteMoneyValue( tkplSF_Tax_Exempt_Dist , plSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tkplSF_Tax_Deferred_Dist , plSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tkplSF_TFN_Credits , plSF_TFN_Credits );
      F.WriteMoneyValue( tkplSF_Foreign_Income , plSF_Foreign_Income );
      F.WriteMoneyValue( tkplSF_Foreign_Tax_Credits , plSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Indexed , plSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Disc , plSF_Capital_Gains_Disc );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Other , plSF_Capital_Gains_Other );
      F.WriteMoneyValue( tkplSF_Other_Expenses , plSF_Other_Expenses );
      F.WriteMoneyValue( tkplSF_Interest , plSF_Interest );
      F.WriteMoneyValue( tkplSF_Capital_Gains_Foreign_Disc , plSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tkplSF_Rent , plSF_Rent );
      F.WriteMoneyValue( tkplSF_Special_Income , plSF_Special_Income );
      F.WriteMoneyValue( tkplSF_Other_Tax_Credit , plSF_Other_Tax_Credit );
      F.WriteMoneyValue( tkplSF_Non_Resident_Tax , plSF_Non_Resident_Tax );
      F.WriteMoneyValue( tkplSF_Foreign_Capital_Gains_Credit , plSF_Foreign_Capital_Gains_Credit );
      F.WriteBooleanValue( tkplSF_Capital_Gains_Fraction_Half , plSF_Capital_Gains_Fraction_Half );
      F.WriteIntegerValue( tkplSF_Ledger_ID , plSF_Ledger_ID );
      F.WriteAnsiStringValue( tkplSF_Ledger_Name , plSF_Ledger_Name );
      F.WriteIntegerValue( tkplAudit_Record_ID , plAudit_Record_ID );
      F.WriteMoneyValue( tkplSF_Other_Income , plSF_Other_Income );
      F.WriteMoneyValue( tkplSF_Other_Trust_Deductions , plSF_Other_Trust_Deductions );
      F.WriteMoneyValue( tkplSF_CGT_Concession_Amount , plSF_CGT_Concession_Amount );
      F.WriteMoneyValue( tkplSF_CGT_ForeignCGT_Before_Disc , plSF_CGT_ForeignCGT_Before_Disc );
      F.WriteMoneyValue( tkplSF_CGT_ForeignCGT_Indexation , plSF_CGT_ForeignCGT_Indexation );
      F.WriteMoneyValue( tkplSF_CGT_ForeignCGT_Other_Method , plSF_CGT_ForeignCGT_Other_Method );
      F.WriteMoneyValue( tkplSF_CGT_TaxPaid_Indexation , plSF_CGT_TaxPaid_Indexation );
      F.WriteMoneyValue( tkplSF_CGT_TaxPaid_Other_Method , plSF_CGT_TaxPaid_Other_Method );
      F.WriteMoneyValue( tkplSF_Other_Net_Foreign_Income , plSF_Other_Net_Foreign_Income );
      F.WriteMoneyValue( tkplSF_Cash_Distribution , plSF_Cash_Distribution );
      F.WriteMoneyValue( tkplSF_AU_Franking_Credits_NZ_Co , plSF_AU_Franking_Credits_NZ_Co );
      F.WriteMoneyValue( tkplSF_Non_Res_Witholding_Tax , plSF_Non_Res_Witholding_Tax );
      F.WriteMoneyValue( tkplSF_LIC_Deductions , plSF_LIC_Deductions );
      F.WriteMoneyValue( tkplSF_Non_Cash_CGT_Discounted_Before_Discount , plSF_Non_Cash_CGT_Discounted_Before_Discount );
      F.WriteMoneyValue( tkplSF_Non_Cash_CGT_Indexation , plSF_Non_Cash_CGT_Indexation );
      F.WriteMoneyValue( tkplSF_Non_Cash_CGT_Other_Method , plSF_Non_Cash_CGT_Other_Method );
      F.WriteMoneyValue( tkplSF_Non_Cash_CGT_Capital_Losses , plSF_Non_Cash_CGT_Capital_Losses );
      F.WriteMoneyValue( tkplSF_Share_Brokerage , plSF_Share_Brokerage );
      F.WriteMoneyValue( tkplSF_Share_Consideration , plSF_Share_Consideration );
      F.WriteMoneyValue( tkplSF_Share_GST_Amount , plSF_Share_GST_Amount );
      F.WriteStringValue( tkplSF_Share_GST_Rate , plSF_Share_GST_Rate );
      F.WriteDateValue( tkplSF_Cash_Date , plSF_Cash_Date );
      F.WriteDateValue( tkplSF_Accrual_Date , plSF_Accrual_Date );
      F.WriteDateValue( tkplSF_Record_Date , plSF_Record_Date );
      F.WriteToken( tkEnd_Payee_Line );
   end;
end; { of Write_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Payee_Line_Rec ( Var O : TPayee_Line_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Payee_Line_Rec_Size, 0 );
   O.plRecord_Type := tkBegin_Payee_Line;
   O.plEOR := tkEnd_Payee_Line;
   Token := tkBegin_Payee_Line;

   While Token <> tkEnd_Payee_Line do With O do
   Begin
      Case Token of
         tkBegin_Payee_Line :; { Do Nothing }
         tkEnd_Payee_Line :; { Do Nothing }
         tkplAccount                          : plAccount := F.ReadStringValue;
         tkplPercentage                       : plPercentage := F.ReadMoneyValue;
         tkplGST_Class                        : plGST_Class := F.ReadByteValue;
         tkplGST_Has_Been_Edited              : plGST_Has_Been_Edited := F.ReadBooleanValue;
         tkplGL_Narration                     : plGL_Narration := F.ReadAnsiStringValue;
         tkplLine_Type                        : plLine_Type := F.ReadByteValue;
         tkplGST_Amount                       : plGST_Amount := F.ReadMoneyValue;
         tkplSF_PCFranked                     : plSF_PCFranked := F.ReadMoneyValue;
         tkplSF_Member_ID                     : plSF_Member_ID := F.ReadStringValue;
         tkplSF_Fund_ID                       : plSF_Fund_ID := F.ReadIntegerValue;
         tkplSF_Fund_Code                     : plSF_Fund_Code := F.ReadStringValue;
         tkplSF_Trans_ID                      : plSF_Trans_ID := F.ReadIntegerValue;
         tkplSF_Trans_Code                    : plSF_Trans_Code := F.ReadAnsiStringValue;
         tkplSF_Member_Account_ID             : plSF_Member_Account_ID := F.ReadIntegerValue;
         tkplSF_Member_Account_Code           : plSF_Member_Account_Code := F.ReadStringValue;
         tkplSF_Edited                        : plSF_Edited := F.ReadBooleanValue;
         tkplSF_Member_Component              : plSF_Member_Component := F.ReadByteValue;
         tkplSF_PCUnFranked                   : plSF_PCUnFranked := F.ReadMoneyValue;
         tkplQuantity                         : plQuantity := F.ReadMoneyValue;
         tkplSF_GDT_Date                      : plSF_GDT_Date := F.ReadDateValue;
         tkplSF_Tax_Free_Dist                 : plSF_Tax_Free_Dist := F.ReadMoneyValue;
         tkplSF_Tax_Exempt_Dist               : plSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tkplSF_Tax_Deferred_Dist             : plSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tkplSF_TFN_Credits                   : plSF_TFN_Credits := F.ReadMoneyValue;
         tkplSF_Foreign_Income                : plSF_Foreign_Income := F.ReadMoneyValue;
         tkplSF_Foreign_Tax_Credits           : plSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Indexed         : plSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Disc            : plSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Other           : plSF_Capital_Gains_Other := F.ReadMoneyValue;
         tkplSF_Other_Expenses                : plSF_Other_Expenses := F.ReadMoneyValue;
         tkplSF_Interest                      : plSF_Interest := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Foreign_Disc    : plSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tkplSF_Rent                          : plSF_Rent := F.ReadMoneyValue;
         tkplSF_Special_Income                : plSF_Special_Income := F.ReadMoneyValue;
         tkplSF_Other_Tax_Credit              : plSF_Other_Tax_Credit := F.ReadMoneyValue;
         tkplSF_Non_Resident_Tax              : plSF_Non_Resident_Tax := F.ReadMoneyValue;
         tkplSF_Foreign_Capital_Gains_Credit  : plSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         tkplSF_Capital_Gains_Fraction_Half   : plSF_Capital_Gains_Fraction_Half := F.ReadBooleanValue;
         tkplSF_Ledger_ID                     : plSF_Ledger_ID := F.ReadIntegerValue;
         tkplSF_Ledger_Name                   : plSF_Ledger_Name := F.ReadAnsiStringValue;
         tkplAudit_Record_ID                  : plAudit_Record_ID := F.ReadIntegerValue;
         tkplSF_Other_Income                  : plSF_Other_Income := F.ReadMoneyValue;
         tkplSF_Other_Trust_Deductions        : plSF_Other_Trust_Deductions := F.ReadMoneyValue;
         tkplSF_CGT_Concession_Amount         : plSF_CGT_Concession_Amount := F.ReadMoneyValue;
         tkplSF_CGT_ForeignCGT_Before_Disc    : plSF_CGT_ForeignCGT_Before_Disc := F.ReadMoneyValue;
         tkplSF_CGT_ForeignCGT_Indexation     : plSF_CGT_ForeignCGT_Indexation := F.ReadMoneyValue;
         tkplSF_CGT_ForeignCGT_Other_Method   : plSF_CGT_ForeignCGT_Other_Method := F.ReadMoneyValue;
         tkplSF_CGT_TaxPaid_Indexation        : plSF_CGT_TaxPaid_Indexation := F.ReadMoneyValue;
         tkplSF_CGT_TaxPaid_Other_Method      : plSF_CGT_TaxPaid_Other_Method := F.ReadMoneyValue;
         tkplSF_Other_Net_Foreign_Income      : plSF_Other_Net_Foreign_Income := F.ReadMoneyValue;
         tkplSF_Cash_Distribution             : plSF_Cash_Distribution := F.ReadMoneyValue;
         tkplSF_AU_Franking_Credits_NZ_Co     : plSF_AU_Franking_Credits_NZ_Co := F.ReadMoneyValue;
         tkplSF_Non_Res_Witholding_Tax        : plSF_Non_Res_Witholding_Tax := F.ReadMoneyValue;
         tkplSF_LIC_Deductions                : plSF_LIC_Deductions := F.ReadMoneyValue;
         tkplSF_Non_Cash_CGT_Discounted_Before_Discount : plSF_Non_Cash_CGT_Discounted_Before_Discount := F.ReadMoneyValue;
         tkplSF_Non_Cash_CGT_Indexation       : plSF_Non_Cash_CGT_Indexation := F.ReadMoneyValue;
         tkplSF_Non_Cash_CGT_Other_Method     : plSF_Non_Cash_CGT_Other_Method := F.ReadMoneyValue;
         tkplSF_Non_Cash_CGT_Capital_Losses   : plSF_Non_Cash_CGT_Capital_Losses := F.ReadMoneyValue;
         tkplSF_Share_Brokerage               : plSF_Share_Brokerage := F.ReadMoneyValue;
         tkplSF_Share_Consideration           : plSF_Share_Consideration := F.ReadMoneyValue;
         tkplSF_Share_GST_Amount              : plSF_Share_GST_Amount := F.ReadMoneyValue;
         tkplSF_Share_GST_Rate                : plSF_Share_GST_Rate := F.ReadStringValue;
         tkplSF_Cash_Date                     : plSF_Cash_Date := F.ReadDateValue;
         tkplSF_Accrual_Date                  : plSF_Accrual_Date := F.ReadDateValue;
         tkplSF_Record_Date                   : plSF_Record_Date := F.ReadDateValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Payee_Line_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Payee_Line_Rec : pPayee_Line_Rec ;

Var
   P : pPayee_Line_Rec;
Begin
   SafeGetMem( P, Payee_Line_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Payee_Line_Rec_Size, 0 );
      plRecord_Type := tkBegin_Payee_Line;
      plEOR         := tkEnd_Payee_Line;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Payee_Line_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Payee_Line_Rec_Dynamic_Fields ( Var O : TPayee_Line_Rec );

Begin
   If IsAPayee_Line_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      plGL_Narration := '' ;
      plSF_Trans_Code := '' ;
      plSF_Ledger_Name := '' ;
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
  for i := tkplAccount to tkplSF_Record_Date do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Payee_Line_Rec_Delta(P1, P2, P3: pPayee_Line_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Payee_Line_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.plAccount <> P2.plAccount) then begin
    P3.plAccount := P1.plAccount;
    ChangedFields[i] := tkplAccount;
    Inc(i);
  end;
  if (P1.plPercentage <> P2.plPercentage) then begin
    P3.plPercentage := P1.plPercentage;
    ChangedFields[i] := tkplPercentage;
    Inc(i);
  end;
  if (P1.plGST_Class <> P2.plGST_Class) then begin
    P3.plGST_Class := P1.plGST_Class;
    ChangedFields[i] := tkplGST_Class;
    Inc(i);
  end;
  if (P1.plGST_Has_Been_Edited <> P2.plGST_Has_Been_Edited) then begin
    P3.plGST_Has_Been_Edited := P1.plGST_Has_Been_Edited;
    ChangedFields[i] := tkplGST_Has_Been_Edited;
    Inc(i);
  end;
  if (P1.plGL_Narration <> P2.plGL_Narration) then begin
    P3.plGL_Narration := P1.plGL_Narration;
    ChangedFields[i] := tkplGL_Narration;
    Inc(i);
  end;
  if (P1.plLine_Type <> P2.plLine_Type) then begin
    P3.plLine_Type := P1.plLine_Type;
    ChangedFields[i] := tkplLine_Type;
    Inc(i);
  end;
  if (P1.plGST_Amount <> P2.plGST_Amount) then begin
    P3.plGST_Amount := P1.plGST_Amount;
    ChangedFields[i] := tkplGST_Amount;
    Inc(i);
  end;
  if (P1.plSF_PCFranked <> P2.plSF_PCFranked) then begin
    P3.plSF_PCFranked := P1.plSF_PCFranked;
    ChangedFields[i] := tkplSF_PCFranked;
    Inc(i);
  end;
  if (P1.plSF_Member_ID <> P2.plSF_Member_ID) then begin
    P3.plSF_Member_ID := P1.plSF_Member_ID;
    ChangedFields[i] := tkplSF_Member_ID;
    Inc(i);
  end;
  if (P1.plSF_Fund_ID <> P2.plSF_Fund_ID) then begin
    P3.plSF_Fund_ID := P1.plSF_Fund_ID;
    ChangedFields[i] := tkplSF_Fund_ID;
    Inc(i);
  end;
  if (P1.plSF_Fund_Code <> P2.plSF_Fund_Code) then begin
    P3.plSF_Fund_Code := P1.plSF_Fund_Code;
    ChangedFields[i] := tkplSF_Fund_Code;
    Inc(i);
  end;
  if (P1.plSF_Trans_ID <> P2.plSF_Trans_ID) then begin
    P3.plSF_Trans_ID := P1.plSF_Trans_ID;
    ChangedFields[i] := tkplSF_Trans_ID;
    Inc(i);
  end;
  if (P1.plSF_Trans_Code <> P2.plSF_Trans_Code) then begin
    P3.plSF_Trans_Code := P1.plSF_Trans_Code;
    ChangedFields[i] := tkplSF_Trans_Code;
    Inc(i);
  end;
  if (P1.plSF_Member_Account_ID <> P2.plSF_Member_Account_ID) then begin
    P3.plSF_Member_Account_ID := P1.plSF_Member_Account_ID;
    ChangedFields[i] := tkplSF_Member_Account_ID;
    Inc(i);
  end;
  if (P1.plSF_Member_Account_Code <> P2.plSF_Member_Account_Code) then begin
    P3.plSF_Member_Account_Code := P1.plSF_Member_Account_Code;
    ChangedFields[i] := tkplSF_Member_Account_Code;
    Inc(i);
  end;
  if (P1.plSF_Edited <> P2.plSF_Edited) then begin
    P3.plSF_Edited := P1.plSF_Edited;
    ChangedFields[i] := tkplSF_Edited;
    Inc(i);
  end;
  if (P1.plSF_Member_Component <> P2.plSF_Member_Component) then begin
    P3.plSF_Member_Component := P1.plSF_Member_Component;
    ChangedFields[i] := tkplSF_Member_Component;
    Inc(i);
  end;
  if (P1.plSF_PCUnFranked <> P2.plSF_PCUnFranked) then begin
    P3.plSF_PCUnFranked := P1.plSF_PCUnFranked;
    ChangedFields[i] := tkplSF_PCUnFranked;
    Inc(i);
  end;
  if (P1.plQuantity <> P2.plQuantity) then begin
    P3.plQuantity := P1.plQuantity;
    ChangedFields[i] := tkplQuantity;
    Inc(i);
  end;
  if (P1.plSF_GDT_Date <> P2.plSF_GDT_Date) then begin
    P3.plSF_GDT_Date := P1.plSF_GDT_Date;
    ChangedFields[i] := tkplSF_GDT_Date;
    Inc(i);
  end;
  if (P1.plSF_Tax_Free_Dist <> P2.plSF_Tax_Free_Dist) then begin
    P3.plSF_Tax_Free_Dist := P1.plSF_Tax_Free_Dist;
    ChangedFields[i] := tkplSF_Tax_Free_Dist;
    Inc(i);
  end;
  if (P1.plSF_Tax_Exempt_Dist <> P2.plSF_Tax_Exempt_Dist) then begin
    P3.plSF_Tax_Exempt_Dist := P1.plSF_Tax_Exempt_Dist;
    ChangedFields[i] := tkplSF_Tax_Exempt_Dist;
    Inc(i);
  end;
  if (P1.plSF_Tax_Deferred_Dist <> P2.plSF_Tax_Deferred_Dist) then begin
    P3.plSF_Tax_Deferred_Dist := P1.plSF_Tax_Deferred_Dist;
    ChangedFields[i] := tkplSF_Tax_Deferred_Dist;
    Inc(i);
  end;
  if (P1.plSF_TFN_Credits <> P2.plSF_TFN_Credits) then begin
    P3.plSF_TFN_Credits := P1.plSF_TFN_Credits;
    ChangedFields[i] := tkplSF_TFN_Credits;
    Inc(i);
  end;
  if (P1.plSF_Foreign_Income <> P2.plSF_Foreign_Income) then begin
    P3.plSF_Foreign_Income := P1.plSF_Foreign_Income;
    ChangedFields[i] := tkplSF_Foreign_Income;
    Inc(i);
  end;
  if (P1.plSF_Foreign_Tax_Credits <> P2.plSF_Foreign_Tax_Credits) then begin
    P3.plSF_Foreign_Tax_Credits := P1.plSF_Foreign_Tax_Credits;
    ChangedFields[i] := tkplSF_Foreign_Tax_Credits;
    Inc(i);
  end;
  if (P1.plSF_Capital_Gains_Indexed <> P2.plSF_Capital_Gains_Indexed) then begin
    P3.plSF_Capital_Gains_Indexed := P1.plSF_Capital_Gains_Indexed;
    ChangedFields[i] := tkplSF_Capital_Gains_Indexed;
    Inc(i);
  end;
  if (P1.plSF_Capital_Gains_Disc <> P2.plSF_Capital_Gains_Disc) then begin
    P3.plSF_Capital_Gains_Disc := P1.plSF_Capital_Gains_Disc;
    ChangedFields[i] := tkplSF_Capital_Gains_Disc;
    Inc(i);
  end;
  if (P1.plSF_Capital_Gains_Other <> P2.plSF_Capital_Gains_Other) then begin
    P3.plSF_Capital_Gains_Other := P1.plSF_Capital_Gains_Other;
    ChangedFields[i] := tkplSF_Capital_Gains_Other;
    Inc(i);
  end;
  if (P1.plSF_Other_Expenses <> P2.plSF_Other_Expenses) then begin
    P3.plSF_Other_Expenses := P1.plSF_Other_Expenses;
    ChangedFields[i] := tkplSF_Other_Expenses;
    Inc(i);
  end;
  if (P1.plSF_Interest <> P2.plSF_Interest) then begin
    P3.plSF_Interest := P1.plSF_Interest;
    ChangedFields[i] := tkplSF_Interest;
    Inc(i);
  end;
  if (P1.plSF_Capital_Gains_Foreign_Disc <> P2.plSF_Capital_Gains_Foreign_Disc) then begin
    P3.plSF_Capital_Gains_Foreign_Disc := P1.plSF_Capital_Gains_Foreign_Disc;
    ChangedFields[i] := tkplSF_Capital_Gains_Foreign_Disc;
    Inc(i);
  end;
  if (P1.plSF_Rent <> P2.plSF_Rent) then begin
    P3.plSF_Rent := P1.plSF_Rent;
    ChangedFields[i] := tkplSF_Rent;
    Inc(i);
  end;
  if (P1.plSF_Special_Income <> P2.plSF_Special_Income) then begin
    P3.plSF_Special_Income := P1.plSF_Special_Income;
    ChangedFields[i] := tkplSF_Special_Income;
    Inc(i);
  end;
  if (P1.plSF_Other_Tax_Credit <> P2.plSF_Other_Tax_Credit) then begin
    P3.plSF_Other_Tax_Credit := P1.plSF_Other_Tax_Credit;
    ChangedFields[i] := tkplSF_Other_Tax_Credit;
    Inc(i);
  end;
  if (P1.plSF_Non_Resident_Tax <> P2.plSF_Non_Resident_Tax) then begin
    P3.plSF_Non_Resident_Tax := P1.plSF_Non_Resident_Tax;
    ChangedFields[i] := tkplSF_Non_Resident_Tax;
    Inc(i);
  end;
  if (P1.plSF_Foreign_Capital_Gains_Credit <> P2.plSF_Foreign_Capital_Gains_Credit) then begin
    P3.plSF_Foreign_Capital_Gains_Credit := P1.plSF_Foreign_Capital_Gains_Credit;
    ChangedFields[i] := tkplSF_Foreign_Capital_Gains_Credit;
    Inc(i);
  end;
  if (P1.plSF_Capital_Gains_Fraction_Half <> P2.plSF_Capital_Gains_Fraction_Half) then begin
    P3.plSF_Capital_Gains_Fraction_Half := P1.plSF_Capital_Gains_Fraction_Half;
    ChangedFields[i] := tkplSF_Capital_Gains_Fraction_Half;
    Inc(i);
  end;
  if (P1.plSF_Ledger_ID <> P2.plSF_Ledger_ID) then begin
    P3.plSF_Ledger_ID := P1.plSF_Ledger_ID;
    ChangedFields[i] := tkplSF_Ledger_ID;
    Inc(i);
  end;
  if (P1.plSF_Ledger_Name <> P2.plSF_Ledger_Name) then begin
    P3.plSF_Ledger_Name := P1.plSF_Ledger_Name;
    ChangedFields[i] := tkplSF_Ledger_Name;
    Inc(i);
  end;
  if (P1.plAudit_Record_ID <> P2.plAudit_Record_ID) then begin
    P3.plAudit_Record_ID := P1.plAudit_Record_ID;
    ChangedFields[i] := tkplAudit_Record_ID;
    Inc(i);
  end;
  if (P1.plSF_Other_Income <> P2.plSF_Other_Income) then begin
    P3.plSF_Other_Income := P1.plSF_Other_Income;
    ChangedFields[i] := tkplSF_Other_Income;
    Inc(i);
  end;
  if (P1.plSF_Other_Trust_Deductions <> P2.plSF_Other_Trust_Deductions) then begin
    P3.plSF_Other_Trust_Deductions := P1.plSF_Other_Trust_Deductions;
    ChangedFields[i] := tkplSF_Other_Trust_Deductions;
    Inc(i);
  end;
  if (P1.plSF_CGT_Concession_Amount <> P2.plSF_CGT_Concession_Amount) then begin
    P3.plSF_CGT_Concession_Amount := P1.plSF_CGT_Concession_Amount;
    ChangedFields[i] := tkplSF_CGT_Concession_Amount;
    Inc(i);
  end;
  if (P1.plSF_CGT_ForeignCGT_Before_Disc <> P2.plSF_CGT_ForeignCGT_Before_Disc) then begin
    P3.plSF_CGT_ForeignCGT_Before_Disc := P1.plSF_CGT_ForeignCGT_Before_Disc;
    ChangedFields[i] := tkplSF_CGT_ForeignCGT_Before_Disc;
    Inc(i);
  end;
  if (P1.plSF_CGT_ForeignCGT_Indexation <> P2.plSF_CGT_ForeignCGT_Indexation) then begin
    P3.plSF_CGT_ForeignCGT_Indexation := P1.plSF_CGT_ForeignCGT_Indexation;
    ChangedFields[i] := tkplSF_CGT_ForeignCGT_Indexation;
    Inc(i);
  end;
  if (P1.plSF_CGT_ForeignCGT_Other_Method <> P2.plSF_CGT_ForeignCGT_Other_Method) then begin
    P3.plSF_CGT_ForeignCGT_Other_Method := P1.plSF_CGT_ForeignCGT_Other_Method;
    ChangedFields[i] := tkplSF_CGT_ForeignCGT_Other_Method;
    Inc(i);
  end;
  if (P1.plSF_CGT_TaxPaid_Indexation <> P2.plSF_CGT_TaxPaid_Indexation) then begin
    P3.plSF_CGT_TaxPaid_Indexation := P1.plSF_CGT_TaxPaid_Indexation;
    ChangedFields[i] := tkplSF_CGT_TaxPaid_Indexation;
    Inc(i);
  end;
  if (P1.plSF_CGT_TaxPaid_Other_Method <> P2.plSF_CGT_TaxPaid_Other_Method) then begin
    P3.plSF_CGT_TaxPaid_Other_Method := P1.plSF_CGT_TaxPaid_Other_Method;
    ChangedFields[i] := tkplSF_CGT_TaxPaid_Other_Method;
    Inc(i);
  end;
  if (P1.plSF_Other_Net_Foreign_Income <> P2.plSF_Other_Net_Foreign_Income) then begin
    P3.plSF_Other_Net_Foreign_Income := P1.plSF_Other_Net_Foreign_Income;
    ChangedFields[i] := tkplSF_Other_Net_Foreign_Income;
    Inc(i);
  end;
  if (P1.plSF_Cash_Distribution <> P2.plSF_Cash_Distribution) then begin
    P3.plSF_Cash_Distribution := P1.plSF_Cash_Distribution;
    ChangedFields[i] := tkplSF_Cash_Distribution;
    Inc(i);
  end;
  if (P1.plSF_AU_Franking_Credits_NZ_Co <> P2.plSF_AU_Franking_Credits_NZ_Co) then begin
    P3.plSF_AU_Franking_Credits_NZ_Co := P1.plSF_AU_Franking_Credits_NZ_Co;
    ChangedFields[i] := tkplSF_AU_Franking_Credits_NZ_Co;
    Inc(i);
  end;
  if (P1.plSF_Non_Res_Witholding_Tax <> P2.plSF_Non_Res_Witholding_Tax) then begin
    P3.plSF_Non_Res_Witholding_Tax := P1.plSF_Non_Res_Witholding_Tax;
    ChangedFields[i] := tkplSF_Non_Res_Witholding_Tax;
    Inc(i);
  end;
  if (P1.plSF_LIC_Deductions <> P2.plSF_LIC_Deductions) then begin
    P3.plSF_LIC_Deductions := P1.plSF_LIC_Deductions;
    ChangedFields[i] := tkplSF_LIC_Deductions;
    Inc(i);
  end;
  if (P1.plSF_Non_Cash_CGT_Discounted_Before_Discount <> P2.plSF_Non_Cash_CGT_Discounted_Before_Discount) then begin
    P3.plSF_Non_Cash_CGT_Discounted_Before_Discount := P1.plSF_Non_Cash_CGT_Discounted_Before_Discount;
    ChangedFields[i] := tkplSF_Non_Cash_CGT_Discounted_Before_Discount;
    Inc(i);
  end;
  if (P1.plSF_Non_Cash_CGT_Indexation <> P2.plSF_Non_Cash_CGT_Indexation) then begin
    P3.plSF_Non_Cash_CGT_Indexation := P1.plSF_Non_Cash_CGT_Indexation;
    ChangedFields[i] := tkplSF_Non_Cash_CGT_Indexation;
    Inc(i);
  end;
  if (P1.plSF_Non_Cash_CGT_Other_Method <> P2.plSF_Non_Cash_CGT_Other_Method) then begin
    P3.plSF_Non_Cash_CGT_Other_Method := P1.plSF_Non_Cash_CGT_Other_Method;
    ChangedFields[i] := tkplSF_Non_Cash_CGT_Other_Method;
    Inc(i);
  end;
  if (P1.plSF_Non_Cash_CGT_Capital_Losses <> P2.plSF_Non_Cash_CGT_Capital_Losses) then begin
    P3.plSF_Non_Cash_CGT_Capital_Losses := P1.plSF_Non_Cash_CGT_Capital_Losses;
    ChangedFields[i] := tkplSF_Non_Cash_CGT_Capital_Losses;
    Inc(i);
  end;
  if (P1.plSF_Share_Brokerage <> P2.plSF_Share_Brokerage) then begin
    P3.plSF_Share_Brokerage := P1.plSF_Share_Brokerage;
    ChangedFields[i] := tkplSF_Share_Brokerage;
    Inc(i);
  end;
  if (P1.plSF_Share_Consideration <> P2.plSF_Share_Consideration) then begin
    P3.plSF_Share_Consideration := P1.plSF_Share_Consideration;
    ChangedFields[i] := tkplSF_Share_Consideration;
    Inc(i);
  end;
  if (P1.plSF_Share_GST_Amount <> P2.plSF_Share_GST_Amount) then begin
    P3.plSF_Share_GST_Amount := P1.plSF_Share_GST_Amount;
    ChangedFields[i] := tkplSF_Share_GST_Amount;
    Inc(i);
  end;
  if (P1.plSF_Share_GST_Rate <> P2.plSF_Share_GST_Rate) then begin
    P3.plSF_Share_GST_Rate := P1.plSF_Share_GST_Rate;
    ChangedFields[i] := tkplSF_Share_GST_Rate;
    Inc(i);
  end;
  if (P1.plSF_Cash_Date <> P2.plSF_Cash_Date) then begin
    P3.plSF_Cash_Date := P1.plSF_Cash_Date;
    ChangedFields[i] := tkplSF_Cash_Date;
    Inc(i);
  end;
  if (P1.plSF_Accrual_Date <> P2.plSF_Accrual_Date) then begin
    P3.plSF_Accrual_Date := P1.plSF_Accrual_Date;
    ChangedFields[i] := tkplSF_Accrual_Date;
    Inc(i);
  end;
  if (P1.plSF_Record_Date <> P2.plSF_Record_Date) then begin
    P3.plSF_Record_Date := P1.plSF_Record_Date;
    ChangedFields[i] := tkplSF_Record_Date;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Payee_Line_Rec(P1, P2: pPayee_Line_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Payee_Line_Rec(P1^, S);
    S.Position := 0;
    Read_Payee_Line_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
