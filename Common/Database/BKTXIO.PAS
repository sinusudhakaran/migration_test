UNIT BKtxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Transaction                  = 160 ;
   tkEnd_Transaction                    = 161 ;

FUNCTION  IsATransaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Transaction_Rec ( Var O : TTransaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Transaction_Rec ( Var O : TTransaction_Rec ; Var F : TIOStream );
FUNCTION  New_Transaction_Rec : pTransaction_Rec ;
PROCEDURE Free_Transaction_Rec_Dynamic_Fields ( Var O : TTransaction_Rec );

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
   tktxSpareL                           = 239 ;
   tktxJob_Code                         = 240 ;
   tktxForex_Conversion_Rate            = 241 ;
   tktxForeign_Currency_Amount          = 242 ;
   tktxOriginal_Forex_Conversion_Rate   = 243 ;
   tktxOriginal_Foreign_Currency_Amount = 244 ;

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
      F.WriteIntegerValue( tktxSpareL , txSpareL );
      F.WriteStringValue( tktxJob_Code , txJob_Code );
      F.WriteDoubleValue( tktxForex_Conversion_Rate, txForex_Conversion_Rate );
      F.WriteMoneyValue( tktxForeign_Currency_Amount , txForeign_Currency_Amount );
      F.WriteDoubleValue( tktxOriginal_Forex_Conversion_Rate, txOriginal_Forex_Conversion_Rate );
      F.WriteMoneyValue( tktxOriginal_Foreign_Currency_Amount , txOriginal_Foreign_Currency_Amount );
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
         tktxSpareL                           : txSpareL := F.ReadIntegerValue;
         tktxJob_Code                         : txJob_Code := F.ReadStringValue;
         tktxForex_Conversion_Rate            : txForex_Conversion_Rate := F.ReadDoubleValue;
         tktxForeign_Currency_Amount          : txForeign_Currency_Amount := F.ReadMoneyValue;
         tktxOriginal_Forex_Conversion_Rate   : txOriginal_Forex_Conversion_Rate := F.ReadDoubleValue;
         tktxOriginal_Foreign_Currency_Amount : txOriginal_Foreign_Currency_Amount := F.ReadMoneyValue;
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

END.
