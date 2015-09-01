UNIT BKtxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Transaction                  = 160 ;
   tkEnd_Transaction                    = 161 ;

FUNCTION  IsATransaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Transaction_Rec ( Var O : TTransaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Transaction_Rec ( Var O : TTransaction_Rec ; Var F : TIOStream );
FUNCTION  New_Transaction_Rec : pTransaction_Rec ;
PROCEDURE Free_Transaction_Rec_Dynamic_Fields ( Var O : TTransaction_Rec );
FUNCTION Transaction_Rec_Delta(P1, P2, P3: pTransaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Transaction_Rec(P1, P2: pTransaction_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKTXIO';
   SBoundsError        = 'BKTXIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKTXIO Error: Pointer is NIL in IsATransaction_Rec';
   SInvalidType        = 'BKTXIO Error: Type is invalid in IsATransaction_Rec';
   SInvalidEOR         = 'BKTXIO Error: EOR is missing in IsATransaction_Rec';
   SUnknownToken       = 'BKTXIO Error: Unknown token %d in Read_Transaction_Rec';
   SInsufficientMemory = 'BKTXIO Error: Out of memory in New_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tktxSequence_No                      = 162 ;
   tktxLRN_NOW_UNUSED                   = 163 ;
   tktxType                             = 164 ;
   tktxSource                           = 165 ;
   tktxDate_Presented                   = 166 ;
   tktxDate_Effective                   = 167 ;
   tktxDate_Transferred                 = 168 ;
   tktxAmount                           = 169 ;
   tktxGST_Class                        = 170 ;
   tktxGST_Amount                       = 171 ;
   tktxHas_Been_Edited                  = 172 ;
   tktxQuantity                         = 173 ;
   tktxCheque_Number                    = 174 ;
   tktxReference                        = 175 ;
   tktxParticulars                      = 176 ;
   tktxAnalysis                         = 177 ;
   tktxOrigBB                           = 178 ;
   tktxOther_Party                      = 179 ;
   tktxOld_Narration                    = 180 ;
   tktxAccount                          = 181 ;
   tktxCoded_By                         = 182 ;
   tktxPayee_Number                     = 183 ;
   tktxLocked                           = 184 ;
   tktxBankLink_ID                      = 185 ;
   tktxGST_Has_Been_Edited              = 186 ;
   tktxMatched_Item_ID                  = 187 ;
   tktxUPI_State                        = 188 ;
   tktxOriginal_Reference               = 189 ;
   tktxOriginal_Source                  = 190 ;
   tktxOriginal_Type                    = 191 ;
   tktxOriginal_Cheque_Number           = 192 ;
   tktxOriginal_Amount                  = 193 ;
   tktxNotes                            = 194 ;
   tktxECoding_Import_Notes             = 195 ;
   tktxECoding_Transaction_UID          = 196 ;
   tktxGL_Narration                     = 197 ;
   tktxStatement_Details                = 198 ;
   tktxTax_Invoice_Available            = 199 ;
   tktxSF_Imputed_Credit                = 200 ;
   tktxSF_Tax_Free_Dist                 = 201 ;
   tktxSF_Tax_Exempt_Dist               = 202 ;
   tktxSF_Tax_Deferred_Dist             = 203 ;
   tktxSF_TFN_Credits                   = 204 ;
   tktxSF_Foreign_Income                = 205 ;
   tktxSF_Foreign_Tax_Credits           = 206 ;
   tktxSF_Capital_Gains_Indexed         = 207 ;
   tktxSF_Capital_Gains_Disc            = 208 ;
   tktxSF_Super_Fields_Edited           = 209 ;
   tktxSF_Capital_Gains_Other           = 210 ;
   tktxSF_Other_Expenses                = 211 ;
   tktxSF_CGT_Date                      = 212 ;
   tktxExternal_GUID                    = 213 ;
   tktxDocument_Title                   = 214 ;
   tktxDocument_Status_Update_Required  = 215 ;
   tktxBankLink_UID                     = 216 ;
   tktxNotes_Read                       = 217 ;
   tktxImport_Notes_Read                = 218 ;
   tktxSpare_String                     = 219 ;
   tktxSpare_Boolean                    = 220 ;
   tktxSF_Franked                       = 221 ;
   tktxSF_Unfranked                     = 222 ;
   tktxSF_Interest                      = 223 ;
   tktxSF_Capital_Gains_Foreign_Disc    = 224 ;
   tktxSF_Rent                          = 225 ;
   tktxSF_Special_Income                = 226 ;
   tktxSF_Other_Tax_Credit              = 227 ;
   tktxSF_Non_Resident_Tax              = 228 ;
   tktxSF_Member_ID                     = 229 ;
   tktxSF_Foreign_Capital_Gains_Credit  = 230 ;
   tktxSF_Member_Component              = 231 ;
   tktxSF_Fund_ID                       = 232 ;
   tktxSF_Member_Account_ID             = 233 ;
   tktxSF_Fund_Code                     = 234 ;
   tktxSF_Member_Account_Code           = 235 ;
   tktxSF_Transaction_ID                = 236 ;
   tktxSF_Transaction_Code              = 237 ;
   tktxSF_Capital_Gains_Fraction_Half   = 238 ;
   tktxAudit_Record_ID                  = 239 ;
   tktxJob_Code                         = 240 ;
   tktxForex_Conversion_Rate            = 241 ;
   tktxSpare_Money_1                    = 242 ;
   tktxOriginal_Forex_Conversion_Rate   = 243 ;
   tktxSpare_Money_2                    = 244 ;
   tktxCore_Transaction_ID              = 245 ;
   tktxTransfered_To_Online             = 246 ;
   tktxCore_Transaction_ID_High         = 247 ;
   tktxIsOnline_Transaction             = 248 ;
   tktxSuggested_Mem_State              = 249 ;
   tktxSuggested_Mem_Index              = 250 ;

{  -------------------------------------------------------------------  }

FUNCTION IsATransaction_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PTransaction_Rec ( P )^ do Begin
      If txRecord_Type <> tkBegin_Transaction then
         Raise ECorruptData.Create( SInvalidType );
      If txEOR <> tkEnd_Transaction then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Transaction_Rec ( Var O : TTransaction_Rec ; Var F : TIOStream );

Begin
   If IsATransaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Transaction );
      F.WriteIntegerValue( tktxSequence_No , txSequence_No );
      F.WriteIntegerValue( tktxLRN_NOW_UNUSED , txLRN_NOW_UNUSED );
      F.WriteByteValue( tktxType , txType );
      F.WriteByteValue( tktxSource , txSource );
      F.WriteDateValue( tktxDate_Presented , txDate_Presented );
      F.WriteDateValue( tktxDate_Effective , txDate_Effective );
      F.WriteDateValue( tktxDate_Transferred , txDate_Transferred );
      F.WriteMoneyValue( tktxAmount , txAmount );
      F.WriteByteValue( tktxGST_Class , txGST_Class );
      F.WriteMoneyValue( tktxGST_Amount , txGST_Amount );
      F.WriteBooleanValue( tktxHas_Been_Edited , txHas_Been_Edited );
      F.WriteMoneyValue( tktxQuantity , txQuantity );
      F.WriteIntegerValue( tktxCheque_Number , txCheque_Number );
      F.WriteStringValue( tktxReference , txReference );
      F.WriteStringValue( tktxParticulars , txParticulars );
      F.WriteStringValue( tktxAnalysis , txAnalysis );
      F.WriteStringValue( tktxOrigBB , txOrigBB );
      F.WriteStringValue( tktxOther_Party , txOther_Party );
      F.WriteStringValue( tktxOld_Narration , txOld_Narration );
      F.WriteStringValue( tktxAccount , txAccount );
      F.WriteByteValue( tktxCoded_By , txCoded_By );
      F.WriteIntegerValue( tktxPayee_Number , txPayee_Number );
      F.WriteBooleanValue( tktxLocked , txLocked );
      F.WriteIntegerValue( tktxBankLink_ID , txBankLink_ID );
      F.WriteBooleanValue( tktxGST_Has_Been_Edited , txGST_Has_Been_Edited );
      F.WriteIntegerValue( tktxMatched_Item_ID , txMatched_Item_ID );
      F.WriteByteValue( tktxUPI_State , txUPI_State );
      F.WriteStringValue( tktxOriginal_Reference , txOriginal_Reference );
      F.WriteByteValue( tktxOriginal_Source , txOriginal_Source );
      F.WriteByteValue( tktxOriginal_Type , txOriginal_Type );
      F.WriteIntegerValue( tktxOriginal_Cheque_Number , txOriginal_Cheque_Number );
      F.WriteMoneyValue( tktxOriginal_Amount , txOriginal_Amount );
      F.WriteAnsiStringValue( tktxNotes , txNotes );
      F.WriteAnsiStringValue( tktxECoding_Import_Notes , txECoding_Import_Notes );
      F.WriteIntegerValue( tktxECoding_Transaction_UID , txECoding_Transaction_UID );
      F.WriteAnsiStringValue( tktxGL_Narration , txGL_Narration );
      F.WriteAnsiStringValue( tktxStatement_Details , txStatement_Details );
      F.WriteBooleanValue( tktxTax_Invoice_Available , txTax_Invoice_Available );
      F.WriteMoneyValue( tktxSF_Imputed_Credit , txSF_Imputed_Credit );
      F.WriteMoneyValue( tktxSF_Tax_Free_Dist , txSF_Tax_Free_Dist );
      F.WriteMoneyValue( tktxSF_Tax_Exempt_Dist , txSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tktxSF_Tax_Deferred_Dist , txSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tktxSF_TFN_Credits , txSF_TFN_Credits );
      F.WriteMoneyValue( tktxSF_Foreign_Income , txSF_Foreign_Income );
      F.WriteMoneyValue( tktxSF_Foreign_Tax_Credits , txSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tktxSF_Capital_Gains_Indexed , txSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tktxSF_Capital_Gains_Disc , txSF_Capital_Gains_Disc );
      F.WriteBooleanValue( tktxSF_Super_Fields_Edited , txSF_Super_Fields_Edited );
      F.WriteMoneyValue( tktxSF_Capital_Gains_Other , txSF_Capital_Gains_Other );
      F.WriteMoneyValue( tktxSF_Other_Expenses , txSF_Other_Expenses );
      F.WriteIntegerValue( tktxSF_CGT_Date , txSF_CGT_Date );
      F.WriteAnsiStringValue( tktxExternal_GUID , txExternal_GUID );
      F.WriteAnsiStringValue( tktxDocument_Title , txDocument_Title );
      F.WriteBooleanValue( tktxDocument_Status_Update_Required , txDocument_Status_Update_Required );
      F.WriteAnsiStringValue( tktxBankLink_UID , txBankLink_UID );
      F.WriteBooleanValue( tktxNotes_Read , txNotes_Read );
      F.WriteBooleanValue( tktxImport_Notes_Read , txImport_Notes_Read );
      F.WriteAnsiStringValue( tktxSpare_String , txSpare_String );
      F.WriteBooleanValue( tktxSpare_Boolean , txSpare_Boolean );
      F.WriteMoneyValue( tktxSF_Franked , txSF_Franked );
      F.WriteMoneyValue( tktxSF_Unfranked , txSF_Unfranked );
      F.WriteMoneyValue( tktxSF_Interest , txSF_Interest );
      F.WriteMoneyValue( tktxSF_Capital_Gains_Foreign_Disc , txSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tktxSF_Rent , txSF_Rent );
      F.WriteMoneyValue( tktxSF_Special_Income , txSF_Special_Income );
      F.WriteMoneyValue( tktxSF_Other_Tax_Credit , txSF_Other_Tax_Credit );
      F.WriteMoneyValue( tktxSF_Non_Resident_Tax , txSF_Non_Resident_Tax );
      F.WriteStringValue( tktxSF_Member_ID , txSF_Member_ID );
      F.WriteMoneyValue( tktxSF_Foreign_Capital_Gains_Credit , txSF_Foreign_Capital_Gains_Credit );
      F.WriteByteValue( tktxSF_Member_Component , txSF_Member_Component );
      F.WriteIntegerValue( tktxSF_Fund_ID , txSF_Fund_ID );
      F.WriteIntegerValue( tktxSF_Member_Account_ID , txSF_Member_Account_ID );
      F.WriteStringValue( tktxSF_Fund_Code , txSF_Fund_Code );
      F.WriteStringValue( tktxSF_Member_Account_Code , txSF_Member_Account_Code );
      F.WriteIntegerValue( tktxSF_Transaction_ID , txSF_Transaction_ID );
      F.WriteAnsiStringValue( tktxSF_Transaction_Code , txSF_Transaction_Code );
      F.WriteBooleanValue( tktxSF_Capital_Gains_Fraction_Half , txSF_Capital_Gains_Fraction_Half );
      F.WriteIntegerValue( tktxAudit_Record_ID , txAudit_Record_ID );
      F.WriteStringValue( tktxJob_Code , txJob_Code );
      F.WriteDoubleValue( tktxForex_Conversion_Rate, txForex_Conversion_Rate );
      F.WriteMoneyValue( tktxSpare_Money_1 , txSpare_Money_1 );
      F.WriteDoubleValue( tktxOriginal_Forex_Conversion_Rate, txOriginal_Forex_Conversion_Rate );
      F.WriteMoneyValue( tktxSpare_Money_2 , txSpare_Money_2 );
      F.WriteIntegerValue( tktxCore_Transaction_ID , txCore_Transaction_ID );
      F.WriteBooleanValue( tktxTransfered_To_Online , txTransfered_To_Online );
      F.WriteIntegerValue( tktxCore_Transaction_ID_High , txCore_Transaction_ID_High );
      F.WriteBooleanValue( tktxIsOnline_Transaction , txIsOnline_Transaction );
      F.WriteByteValue( tktxSuggested_Mem_State , txSuggested_Mem_State );
      F.WriteIntegerValue( tktxSuggested_Mem_Index , txSuggested_Mem_Index );
      F.WriteToken( tkEnd_Transaction );
   end;
end; { of Write_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Transaction_Rec ( Var O : TTransaction_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Transaction_Rec_Size, 0 );
   O.txRecord_Type := tkBegin_Transaction;
   O.txEOR := tkEnd_Transaction;
   Token := tkBegin_Transaction;

   While Token <> tkEnd_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Transaction :; { Do Nothing }
         tkEnd_Transaction :; { Do Nothing }
         tktxSequence_No                      : txSequence_No := F.ReadIntegerValue;
         tktxLRN_NOW_UNUSED                   : txLRN_NOW_UNUSED := F.ReadIntegerValue;
         tktxType                             : txType := F.ReadByteValue;
         tktxSource                           : txSource := F.ReadByteValue;
         tktxDate_Presented                   : txDate_Presented := F.ReadDateValue;
         tktxDate_Effective                   : txDate_Effective := F.ReadDateValue;
         tktxDate_Transferred                 : txDate_Transferred := F.ReadDateValue;
         tktxAmount                           : txAmount := F.ReadMoneyValue;
         tktxGST_Class                        : txGST_Class := F.ReadByteValue;
         tktxGST_Amount                       : txGST_Amount := F.ReadMoneyValue;
         tktxHas_Been_Edited                  : txHas_Been_Edited := F.ReadBooleanValue;
         tktxQuantity                         : txQuantity := F.ReadMoneyValue;
         tktxCheque_Number                    : txCheque_Number := F.ReadIntegerValue;
         tktxReference                        : txReference := F.ReadStringValue;
         tktxParticulars                      : txParticulars := F.ReadStringValue;
         tktxAnalysis                         : txAnalysis := F.ReadStringValue;
         tktxOrigBB                           : txOrigBB := F.ReadStringValue;
         tktxOther_Party                      : txOther_Party := F.ReadStringValue;
         tktxOld_Narration                    : txOld_Narration := F.ReadStringValue;
         tktxAccount                          : txAccount := F.ReadStringValue;
         tktxCoded_By                         : txCoded_By := F.ReadByteValue;
         tktxPayee_Number                     : txPayee_Number := F.ReadIntegerValue;
         tktxLocked                           : txLocked := F.ReadBooleanValue;
         tktxBankLink_ID                      : txBankLink_ID := F.ReadIntegerValue;
         tktxGST_Has_Been_Edited              : txGST_Has_Been_Edited := F.ReadBooleanValue;
         tktxMatched_Item_ID                  : txMatched_Item_ID := F.ReadIntegerValue;
         tktxUPI_State                        : txUPI_State := F.ReadByteValue;
         tktxOriginal_Reference               : txOriginal_Reference := F.ReadStringValue;
         tktxOriginal_Source                  : txOriginal_Source := F.ReadByteValue;
         tktxOriginal_Type                    : txOriginal_Type := F.ReadByteValue;
         tktxOriginal_Cheque_Number           : txOriginal_Cheque_Number := F.ReadIntegerValue;
         tktxOriginal_Amount                  : txOriginal_Amount := F.ReadMoneyValue;
         tktxNotes                            : txNotes := F.ReadAnsiStringValue;
         tktxECoding_Import_Notes             : txECoding_Import_Notes := F.ReadAnsiStringValue;
         tktxECoding_Transaction_UID          : txECoding_Transaction_UID := F.ReadIntegerValue;
         tktxGL_Narration                     : txGL_Narration := F.ReadAnsiStringValue;
         tktxStatement_Details                : txStatement_Details := F.ReadAnsiStringValue;
         tktxTax_Invoice_Available            : txTax_Invoice_Available := F.ReadBooleanValue;
         tktxSF_Imputed_Credit                : txSF_Imputed_Credit := F.ReadMoneyValue;
         tktxSF_Tax_Free_Dist                 : txSF_Tax_Free_Dist := F.ReadMoneyValue;
         tktxSF_Tax_Exempt_Dist               : txSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tktxSF_Tax_Deferred_Dist             : txSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tktxSF_TFN_Credits                   : txSF_TFN_Credits := F.ReadMoneyValue;
         tktxSF_Foreign_Income                : txSF_Foreign_Income := F.ReadMoneyValue;
         tktxSF_Foreign_Tax_Credits           : txSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tktxSF_Capital_Gains_Indexed         : txSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tktxSF_Capital_Gains_Disc            : txSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tktxSF_Super_Fields_Edited           : txSF_Super_Fields_Edited := F.ReadBooleanValue;
         tktxSF_Capital_Gains_Other           : txSF_Capital_Gains_Other := F.ReadMoneyValue;
         tktxSF_Other_Expenses                : txSF_Other_Expenses := F.ReadMoneyValue;
         tktxSF_CGT_Date                      : txSF_CGT_Date := F.ReadIntegerValue;
         tktxExternal_GUID                    : txExternal_GUID := F.ReadAnsiStringValue;
         tktxDocument_Title                   : txDocument_Title := F.ReadAnsiStringValue;
         tktxDocument_Status_Update_Required  : txDocument_Status_Update_Required := F.ReadBooleanValue;
         tktxBankLink_UID                     : txBankLink_UID := F.ReadAnsiStringValue;
         tktxNotes_Read                       : txNotes_Read := F.ReadBooleanValue;
         tktxImport_Notes_Read                : txImport_Notes_Read := F.ReadBooleanValue;
         tktxSpare_String                     : txSpare_String := F.ReadAnsiStringValue;
         tktxSpare_Boolean                    : txSpare_Boolean := F.ReadBooleanValue;
         tktxSF_Franked                       : txSF_Franked := F.ReadMoneyValue;
         tktxSF_Unfranked                     : txSF_Unfranked := F.ReadMoneyValue;
         tktxSF_Interest                      : txSF_Interest := F.ReadMoneyValue;
         tktxSF_Capital_Gains_Foreign_Disc    : txSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tktxSF_Rent                          : txSF_Rent := F.ReadMoneyValue;
         tktxSF_Special_Income                : txSF_Special_Income := F.ReadMoneyValue;
         tktxSF_Other_Tax_Credit              : txSF_Other_Tax_Credit := F.ReadMoneyValue;
         tktxSF_Non_Resident_Tax              : txSF_Non_Resident_Tax := F.ReadMoneyValue;
         tktxSF_Member_ID                     : txSF_Member_ID := F.ReadStringValue;
         tktxSF_Foreign_Capital_Gains_Credit  : txSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         tktxSF_Member_Component              : txSF_Member_Component := F.ReadByteValue;
         tktxSF_Fund_ID                       : txSF_Fund_ID := F.ReadIntegerValue;
         tktxSF_Member_Account_ID             : txSF_Member_Account_ID := F.ReadIntegerValue;
         tktxSF_Fund_Code                     : txSF_Fund_Code := F.ReadStringValue;
         tktxSF_Member_Account_Code           : txSF_Member_Account_Code := F.ReadStringValue;
         tktxSF_Transaction_ID                : txSF_Transaction_ID := F.ReadIntegerValue;
         tktxSF_Transaction_Code              : txSF_Transaction_Code := F.ReadAnsiStringValue;
         tktxSF_Capital_Gains_Fraction_Half   : txSF_Capital_Gains_Fraction_Half := F.ReadBooleanValue;
         tktxAudit_Record_ID                  : txAudit_Record_ID := F.ReadIntegerValue;
         tktxJob_Code                         : txJob_Code := F.ReadStringValue;
         tktxForex_Conversion_Rate            : txForex_Conversion_Rate := F.ReadDoubleValue;
         tktxSpare_Money_1                    : txSpare_Money_1 := F.ReadMoneyValue;
         tktxOriginal_Forex_Conversion_Rate   : txOriginal_Forex_Conversion_Rate := F.ReadDoubleValue;
         tktxSpare_Money_2                    : txSpare_Money_2 := F.ReadMoneyValue;
         tktxCore_Transaction_ID              : txCore_Transaction_ID := F.ReadIntegerValue;
         tktxTransfered_To_Online             : txTransfered_To_Online := F.ReadBooleanValue;
         tktxCore_Transaction_ID_High         : txCore_Transaction_ID_High := F.ReadIntegerValue;
         tktxIsOnline_Transaction             : txIsOnline_Transaction := F.ReadBooleanValue;
         tktxSuggested_Mem_State              : txSuggested_Mem_State := F.ReadByteValue;
         tktxSuggested_Mem_Index              : txSuggested_Mem_Index := F.ReadIntegerValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Transaction_Rec : pTransaction_Rec ;

Var
   P : pTransaction_Rec;
Begin
   SafeGetMem( P, Transaction_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Transaction_Rec_Size, 0 );
      txRecord_Type := tkBegin_Transaction;
      txEOR         := tkEnd_Transaction;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Transaction_Rec_Dynamic_Fields ( Var O : TTransaction_Rec );

Begin
   If IsATransaction_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      txNotes := '' ;
      txECoding_Import_Notes := '' ;
      txGL_Narration := '' ;
      txStatement_Details := '' ;
      txExternal_GUID := '' ;
      txDocument_Title := '' ;
      txBankLink_UID := '' ;
      txSpare_String := '' ;
      txSF_Transaction_Code := '' ;
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
  for i := tktxSequence_No to tktxSuggested_Mem_Index do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Transaction_Rec_Delta(P1, P2, P3: pTransaction_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Transaction_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.txSequence_No <> P2.txSequence_No) then begin
    P3.txSequence_No := P1.txSequence_No;
    ChangedFields[i] := tktxSequence_No;
    Inc(i);
  end;
  if (P1.txLRN_NOW_UNUSED <> P2.txLRN_NOW_UNUSED) then begin
    P3.txLRN_NOW_UNUSED := P1.txLRN_NOW_UNUSED;
    ChangedFields[i] := tktxLRN_NOW_UNUSED;
    Inc(i);
  end;
  if (P1.txType <> P2.txType) then begin
    P3.txType := P1.txType;
    ChangedFields[i] := tktxType;
    Inc(i);
  end;
  if (P1.txSource <> P2.txSource) then begin
    P3.txSource := P1.txSource;
    ChangedFields[i] := tktxSource;
    Inc(i);
  end;
  if (P1.txDate_Presented <> P2.txDate_Presented) then begin
    P3.txDate_Presented := P1.txDate_Presented;
    ChangedFields[i] := tktxDate_Presented;
    Inc(i);
  end;
  if (P1.txDate_Effective <> P2.txDate_Effective) then begin
    P3.txDate_Effective := P1.txDate_Effective;
    ChangedFields[i] := tktxDate_Effective;
    Inc(i);
  end;
  if (P1.txDate_Transferred <> P2.txDate_Transferred) then begin
    P3.txDate_Transferred := P1.txDate_Transferred;
    ChangedFields[i] := tktxDate_Transferred;
    Inc(i);
  end;
  if (P1.txAmount <> P2.txAmount) then begin
    P3.txAmount := P1.txAmount;
    ChangedFields[i] := tktxAmount;
    Inc(i);
  end;
  if (P1.txGST_Class <> P2.txGST_Class) then begin
    P3.txGST_Class := P1.txGST_Class;
    ChangedFields[i] := tktxGST_Class;
    Inc(i);
  end;
  if (P1.txGST_Amount <> P2.txGST_Amount) then begin
    P3.txGST_Amount := P1.txGST_Amount;
    ChangedFields[i] := tktxGST_Amount;
    Inc(i);
  end;
  if (P1.txHas_Been_Edited <> P2.txHas_Been_Edited) then begin
    P3.txHas_Been_Edited := P1.txHas_Been_Edited;
    ChangedFields[i] := tktxHas_Been_Edited;
    Inc(i);
  end;
  if (P1.txQuantity <> P2.txQuantity) then begin
    P3.txQuantity := P1.txQuantity;
    ChangedFields[i] := tktxQuantity;
    Inc(i);
  end;
  if (P1.txCheque_Number <> P2.txCheque_Number) then begin
    P3.txCheque_Number := P1.txCheque_Number;
    ChangedFields[i] := tktxCheque_Number;
    Inc(i);
  end;
  if (P1.txReference <> P2.txReference) then begin
    P3.txReference := P1.txReference;
    ChangedFields[i] := tktxReference;
    Inc(i);
  end;
  if (P1.txParticulars <> P2.txParticulars) then begin
    P3.txParticulars := P1.txParticulars;
    ChangedFields[i] := tktxParticulars;
    Inc(i);
  end;
  if (P1.txAnalysis <> P2.txAnalysis) then begin
    P3.txAnalysis := P1.txAnalysis;
    ChangedFields[i] := tktxAnalysis;
    Inc(i);
  end;
  if (P1.txOrigBB <> P2.txOrigBB) then begin
    P3.txOrigBB := P1.txOrigBB;
    ChangedFields[i] := tktxOrigBB;
    Inc(i);
  end;
  if (P1.txOther_Party <> P2.txOther_Party) then begin
    P3.txOther_Party := P1.txOther_Party;
    ChangedFields[i] := tktxOther_Party;
    Inc(i);
  end;
  if (P1.txOld_Narration <> P2.txOld_Narration) then begin
    P3.txOld_Narration := P1.txOld_Narration;
    ChangedFields[i] := tktxOld_Narration;
    Inc(i);
  end;
  if (P1.txAccount <> P2.txAccount) then begin
    P3.txAccount := P1.txAccount;
    ChangedFields[i] := tktxAccount;
    Inc(i);
  end;
  if (P1.txCoded_By <> P2.txCoded_By) then begin
    P3.txCoded_By := P1.txCoded_By;
    ChangedFields[i] := tktxCoded_By;
    Inc(i);
  end;
  if (P1.txPayee_Number <> P2.txPayee_Number) then begin
    P3.txPayee_Number := P1.txPayee_Number;
    ChangedFields[i] := tktxPayee_Number;
    Inc(i);
  end;
  if (P1.txLocked <> P2.txLocked) then begin
    P3.txLocked := P1.txLocked;
    ChangedFields[i] := tktxLocked;
    Inc(i);
  end;
  if (P1.txBankLink_ID <> P2.txBankLink_ID) then begin
    P3.txBankLink_ID := P1.txBankLink_ID;
    ChangedFields[i] := tktxBankLink_ID;
    Inc(i);
  end;
  if (P1.txGST_Has_Been_Edited <> P2.txGST_Has_Been_Edited) then begin
    P3.txGST_Has_Been_Edited := P1.txGST_Has_Been_Edited;
    ChangedFields[i] := tktxGST_Has_Been_Edited;
    Inc(i);
  end;
  if (P1.txMatched_Item_ID <> P2.txMatched_Item_ID) then begin
    P3.txMatched_Item_ID := P1.txMatched_Item_ID;
    ChangedFields[i] := tktxMatched_Item_ID;
    Inc(i);
  end;
  if (P1.txUPI_State <> P2.txUPI_State) then begin
    P3.txUPI_State := P1.txUPI_State;
    ChangedFields[i] := tktxUPI_State;
    Inc(i);
  end;
  if (P1.txOriginal_Reference <> P2.txOriginal_Reference) then begin
    P3.txOriginal_Reference := P1.txOriginal_Reference;
    ChangedFields[i] := tktxOriginal_Reference;
    Inc(i);
  end;
  if (P1.txOriginal_Source <> P2.txOriginal_Source) then begin
    P3.txOriginal_Source := P1.txOriginal_Source;
    ChangedFields[i] := tktxOriginal_Source;
    Inc(i);
  end;
  if (P1.txOriginal_Type <> P2.txOriginal_Type) then begin
    P3.txOriginal_Type := P1.txOriginal_Type;
    ChangedFields[i] := tktxOriginal_Type;
    Inc(i);
  end;
  if (P1.txOriginal_Cheque_Number <> P2.txOriginal_Cheque_Number) then begin
    P3.txOriginal_Cheque_Number := P1.txOriginal_Cheque_Number;
    ChangedFields[i] := tktxOriginal_Cheque_Number;
    Inc(i);
  end;
  if (P1.txOriginal_Amount <> P2.txOriginal_Amount) then begin
    P3.txOriginal_Amount := P1.txOriginal_Amount;
    ChangedFields[i] := tktxOriginal_Amount;
    Inc(i);
  end;
  if (P1.txNotes <> P2.txNotes) then begin
    P3.txNotes := P1.txNotes;
    ChangedFields[i] := tktxNotes;
    Inc(i);
  end;
  if (P1.txECoding_Import_Notes <> P2.txECoding_Import_Notes) then begin
    P3.txECoding_Import_Notes := P1.txECoding_Import_Notes;
    ChangedFields[i] := tktxECoding_Import_Notes;
    Inc(i);
  end;
  if (P1.txECoding_Transaction_UID <> P2.txECoding_Transaction_UID) then begin
    P3.txECoding_Transaction_UID := P1.txECoding_Transaction_UID;
    ChangedFields[i] := tktxECoding_Transaction_UID;
    Inc(i);
  end;
  if (P1.txGL_Narration <> P2.txGL_Narration) then begin
    P3.txGL_Narration := P1.txGL_Narration;
    ChangedFields[i] := tktxGL_Narration;
    Inc(i);
  end;
  if (P1.txStatement_Details <> P2.txStatement_Details) then begin
    P3.txStatement_Details := P1.txStatement_Details;
    ChangedFields[i] := tktxStatement_Details;
    Inc(i);
  end;
  if (P1.txTax_Invoice_Available <> P2.txTax_Invoice_Available) then begin
    P3.txTax_Invoice_Available := P1.txTax_Invoice_Available;
    ChangedFields[i] := tktxTax_Invoice_Available;
    Inc(i);
  end;
  if (P1.txSF_Imputed_Credit <> P2.txSF_Imputed_Credit) then begin
    P3.txSF_Imputed_Credit := P1.txSF_Imputed_Credit;
    ChangedFields[i] := tktxSF_Imputed_Credit;
    Inc(i);
  end;
  if (P1.txSF_Tax_Free_Dist <> P2.txSF_Tax_Free_Dist) then begin
    P3.txSF_Tax_Free_Dist := P1.txSF_Tax_Free_Dist;
    ChangedFields[i] := tktxSF_Tax_Free_Dist;
    Inc(i);
  end;
  if (P1.txSF_Tax_Exempt_Dist <> P2.txSF_Tax_Exempt_Dist) then begin
    P3.txSF_Tax_Exempt_Dist := P1.txSF_Tax_Exempt_Dist;
    ChangedFields[i] := tktxSF_Tax_Exempt_Dist;
    Inc(i);
  end;
  if (P1.txSF_Tax_Deferred_Dist <> P2.txSF_Tax_Deferred_Dist) then begin
    P3.txSF_Tax_Deferred_Dist := P1.txSF_Tax_Deferred_Dist;
    ChangedFields[i] := tktxSF_Tax_Deferred_Dist;
    Inc(i);
  end;
  if (P1.txSF_TFN_Credits <> P2.txSF_TFN_Credits) then begin
    P3.txSF_TFN_Credits := P1.txSF_TFN_Credits;
    ChangedFields[i] := tktxSF_TFN_Credits;
    Inc(i);
  end;
  if (P1.txSF_Foreign_Income <> P2.txSF_Foreign_Income) then begin
    P3.txSF_Foreign_Income := P1.txSF_Foreign_Income;
    ChangedFields[i] := tktxSF_Foreign_Income;
    Inc(i);
  end;
  if (P1.txSF_Foreign_Tax_Credits <> P2.txSF_Foreign_Tax_Credits) then begin
    P3.txSF_Foreign_Tax_Credits := P1.txSF_Foreign_Tax_Credits;
    ChangedFields[i] := tktxSF_Foreign_Tax_Credits;
    Inc(i);
  end;
  if (P1.txSF_Capital_Gains_Indexed <> P2.txSF_Capital_Gains_Indexed) then begin
    P3.txSF_Capital_Gains_Indexed := P1.txSF_Capital_Gains_Indexed;
    ChangedFields[i] := tktxSF_Capital_Gains_Indexed;
    Inc(i);
  end;
  if (P1.txSF_Capital_Gains_Disc <> P2.txSF_Capital_Gains_Disc) then begin
    P3.txSF_Capital_Gains_Disc := P1.txSF_Capital_Gains_Disc;
    ChangedFields[i] := tktxSF_Capital_Gains_Disc;
    Inc(i);
  end;
  if (P1.txSF_Super_Fields_Edited <> P2.txSF_Super_Fields_Edited) then begin
    P3.txSF_Super_Fields_Edited := P1.txSF_Super_Fields_Edited;
    ChangedFields[i] := tktxSF_Super_Fields_Edited;
    Inc(i);
  end;
  if (P1.txSF_Capital_Gains_Other <> P2.txSF_Capital_Gains_Other) then begin
    P3.txSF_Capital_Gains_Other := P1.txSF_Capital_Gains_Other;
    ChangedFields[i] := tktxSF_Capital_Gains_Other;
    Inc(i);
  end;
  if (P1.txSF_Other_Expenses <> P2.txSF_Other_Expenses) then begin
    P3.txSF_Other_Expenses := P1.txSF_Other_Expenses;
    ChangedFields[i] := tktxSF_Other_Expenses;
    Inc(i);
  end;
  if (P1.txSF_CGT_Date <> P2.txSF_CGT_Date) then begin
    P3.txSF_CGT_Date := P1.txSF_CGT_Date;
    ChangedFields[i] := tktxSF_CGT_Date;
    Inc(i);
  end;
  if (P1.txExternal_GUID <> P2.txExternal_GUID) then begin
    P3.txExternal_GUID := P1.txExternal_GUID;
    ChangedFields[i] := tktxExternal_GUID;
    Inc(i);
  end;
  if (P1.txDocument_Title <> P2.txDocument_Title) then begin
    P3.txDocument_Title := P1.txDocument_Title;
    ChangedFields[i] := tktxDocument_Title;
    Inc(i);
  end;
  if (P1.txDocument_Status_Update_Required <> P2.txDocument_Status_Update_Required) then begin
    P3.txDocument_Status_Update_Required := P1.txDocument_Status_Update_Required;
    ChangedFields[i] := tktxDocument_Status_Update_Required;
    Inc(i);
  end;
  if (P1.txBankLink_UID <> P2.txBankLink_UID) then begin
    P3.txBankLink_UID := P1.txBankLink_UID;
    ChangedFields[i] := tktxBankLink_UID;
    Inc(i);
  end;
  if (P1.txNotes_Read <> P2.txNotes_Read) then begin
    P3.txNotes_Read := P1.txNotes_Read;
    ChangedFields[i] := tktxNotes_Read;
    Inc(i);
  end;
  if (P1.txImport_Notes_Read <> P2.txImport_Notes_Read) then begin
    P3.txImport_Notes_Read := P1.txImport_Notes_Read;
    ChangedFields[i] := tktxImport_Notes_Read;
    Inc(i);
  end;
  if (P1.txSpare_String <> P2.txSpare_String) then begin
    P3.txSpare_String := P1.txSpare_String;
    ChangedFields[i] := tktxSpare_String;
    Inc(i);
  end;
  if (P1.txSpare_Boolean <> P2.txSpare_Boolean) then begin
    P3.txSpare_Boolean := P1.txSpare_Boolean;
    ChangedFields[i] := tktxSpare_Boolean;
    Inc(i);
  end;
  if (P1.txSF_Franked <> P2.txSF_Franked) then begin
    P3.txSF_Franked := P1.txSF_Franked;
    ChangedFields[i] := tktxSF_Franked;
    Inc(i);
  end;
  if (P1.txSF_Unfranked <> P2.txSF_Unfranked) then begin
    P3.txSF_Unfranked := P1.txSF_Unfranked;
    ChangedFields[i] := tktxSF_Unfranked;
    Inc(i);
  end;
  if (P1.txSF_Interest <> P2.txSF_Interest) then begin
    P3.txSF_Interest := P1.txSF_Interest;
    ChangedFields[i] := tktxSF_Interest;
    Inc(i);
  end;
  if (P1.txSF_Capital_Gains_Foreign_Disc <> P2.txSF_Capital_Gains_Foreign_Disc) then begin
    P3.txSF_Capital_Gains_Foreign_Disc := P1.txSF_Capital_Gains_Foreign_Disc;
    ChangedFields[i] := tktxSF_Capital_Gains_Foreign_Disc;
    Inc(i);
  end;
  if (P1.txSF_Rent <> P2.txSF_Rent) then begin
    P3.txSF_Rent := P1.txSF_Rent;
    ChangedFields[i] := tktxSF_Rent;
    Inc(i);
  end;
  if (P1.txSF_Special_Income <> P2.txSF_Special_Income) then begin
    P3.txSF_Special_Income := P1.txSF_Special_Income;
    ChangedFields[i] := tktxSF_Special_Income;
    Inc(i);
  end;
  if (P1.txSF_Other_Tax_Credit <> P2.txSF_Other_Tax_Credit) then begin
    P3.txSF_Other_Tax_Credit := P1.txSF_Other_Tax_Credit;
    ChangedFields[i] := tktxSF_Other_Tax_Credit;
    Inc(i);
  end;
  if (P1.txSF_Non_Resident_Tax <> P2.txSF_Non_Resident_Tax) then begin
    P3.txSF_Non_Resident_Tax := P1.txSF_Non_Resident_Tax;
    ChangedFields[i] := tktxSF_Non_Resident_Tax;
    Inc(i);
  end;
  if (P1.txSF_Member_ID <> P2.txSF_Member_ID) then begin
    P3.txSF_Member_ID := P1.txSF_Member_ID;
    ChangedFields[i] := tktxSF_Member_ID;
    Inc(i);
  end;
  if (P1.txSF_Foreign_Capital_Gains_Credit <> P2.txSF_Foreign_Capital_Gains_Credit) then begin
    P3.txSF_Foreign_Capital_Gains_Credit := P1.txSF_Foreign_Capital_Gains_Credit;
    ChangedFields[i] := tktxSF_Foreign_Capital_Gains_Credit;
    Inc(i);
  end;
  if (P1.txSF_Member_Component <> P2.txSF_Member_Component) then begin
    P3.txSF_Member_Component := P1.txSF_Member_Component;
    ChangedFields[i] := tktxSF_Member_Component;
    Inc(i);
  end;
  if (P1.txSF_Fund_ID <> P2.txSF_Fund_ID) then begin
    P3.txSF_Fund_ID := P1.txSF_Fund_ID;
    ChangedFields[i] := tktxSF_Fund_ID;
    Inc(i);
  end;
  if (P1.txSF_Member_Account_ID <> P2.txSF_Member_Account_ID) then begin
    P3.txSF_Member_Account_ID := P1.txSF_Member_Account_ID;
    ChangedFields[i] := tktxSF_Member_Account_ID;
    Inc(i);
  end;
  if (P1.txSF_Fund_Code <> P2.txSF_Fund_Code) then begin
    P3.txSF_Fund_Code := P1.txSF_Fund_Code;
    ChangedFields[i] := tktxSF_Fund_Code;
    Inc(i);
  end;
  if (P1.txSF_Member_Account_Code <> P2.txSF_Member_Account_Code) then begin
    P3.txSF_Member_Account_Code := P1.txSF_Member_Account_Code;
    ChangedFields[i] := tktxSF_Member_Account_Code;
    Inc(i);
  end;
  if (P1.txSF_Transaction_ID <> P2.txSF_Transaction_ID) then begin
    P3.txSF_Transaction_ID := P1.txSF_Transaction_ID;
    ChangedFields[i] := tktxSF_Transaction_ID;
    Inc(i);
  end;
  if (P1.txSF_Transaction_Code <> P2.txSF_Transaction_Code) then begin
    P3.txSF_Transaction_Code := P1.txSF_Transaction_Code;
    ChangedFields[i] := tktxSF_Transaction_Code;
    Inc(i);
  end;
  if (P1.txSF_Capital_Gains_Fraction_Half <> P2.txSF_Capital_Gains_Fraction_Half) then begin
    P3.txSF_Capital_Gains_Fraction_Half := P1.txSF_Capital_Gains_Fraction_Half;
    ChangedFields[i] := tktxSF_Capital_Gains_Fraction_Half;
    Inc(i);
  end;
  if (P1.txAudit_Record_ID <> P2.txAudit_Record_ID) then begin
    P3.txAudit_Record_ID := P1.txAudit_Record_ID;
    ChangedFields[i] := tktxAudit_Record_ID;
    Inc(i);
  end;
  if (P1.txJob_Code <> P2.txJob_Code) then begin
    P3.txJob_Code := P1.txJob_Code;
    ChangedFields[i] := tktxJob_Code;
    Inc(i);
  end;
  if (P1.txForex_Conversion_Rate <> P2.txForex_Conversion_Rate) then begin
    P3.txForex_Conversion_Rate := P1.txForex_Conversion_Rate;
    ChangedFields[i] := tktxForex_Conversion_Rate;
    Inc(i);
  end;
  if (P1.txSpare_Money_1 <> P2.txSpare_Money_1) then begin
    P3.txSpare_Money_1 := P1.txSpare_Money_1;
    ChangedFields[i] := tktxSpare_Money_1;
    Inc(i);
  end;
  if (P1.txOriginal_Forex_Conversion_Rate <> P2.txOriginal_Forex_Conversion_Rate) then begin
    P3.txOriginal_Forex_Conversion_Rate := P1.txOriginal_Forex_Conversion_Rate;
    ChangedFields[i] := tktxOriginal_Forex_Conversion_Rate;
    Inc(i);
  end;
  if (P1.txSpare_Money_2 <> P2.txSpare_Money_2) then begin
    P3.txSpare_Money_2 := P1.txSpare_Money_2;
    ChangedFields[i] := tktxSpare_Money_2;
    Inc(i);
  end;
  if (P1.txCore_Transaction_ID <> P2.txCore_Transaction_ID) then begin
    P3.txCore_Transaction_ID := P1.txCore_Transaction_ID;
    ChangedFields[i] := tktxCore_Transaction_ID;
    Inc(i);
  end;
  if (P1.txTransfered_To_Online <> P2.txTransfered_To_Online) then begin
    P3.txTransfered_To_Online := P1.txTransfered_To_Online;
    ChangedFields[i] := tktxTransfered_To_Online;
    Inc(i);
  end;
  if (P1.txCore_Transaction_ID_High <> P2.txCore_Transaction_ID_High) then begin
    P3.txCore_Transaction_ID_High := P1.txCore_Transaction_ID_High;
    ChangedFields[i] := tktxCore_Transaction_ID_High;
    Inc(i);
  end;
  if (P1.txIsOnline_Transaction <> P2.txIsOnline_Transaction) then begin
    P3.txIsOnline_Transaction := P1.txIsOnline_Transaction;
    ChangedFields[i] := tktxIsOnline_Transaction;
    Inc(i);
  end;
  if (P1.txSuggested_Mem_State <> P2.txSuggested_Mem_State) then begin
    P3.txSuggested_Mem_State := P1.txSuggested_Mem_State;
    ChangedFields[i] := tktxSuggested_Mem_State;
    Inc(i);
  end;
  if (P1.txSuggested_Mem_Index <> P2.txSuggested_Mem_Index) then begin
    P3.txSuggested_Mem_Index := P1.txSuggested_Mem_Index;
    ChangedFields[i] := tktxSuggested_Mem_Index;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Transaction_Rec(P1, P2: pTransaction_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Transaction_Rec(P1^, S);
    S.Position := 0;
    Read_Transaction_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
