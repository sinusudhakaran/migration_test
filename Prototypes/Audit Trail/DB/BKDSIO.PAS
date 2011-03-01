UNIT BKdsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Dissection                   = 180 ;
   tkEnd_Dissection                     = 181 ;

FUNCTION  IsADissection_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Dissection_Rec ( Var O : TDissection_Rec ; Var F : TIOStream );
PROCEDURE Read_Dissection_Rec ( Var O : TDissection_Rec ; Var F : TIOStream );
FUNCTION  New_Dissection_Rec : pDissection_Rec ;
PROCEDURE Free_Dissection_Rec_Dynamic_Fields ( Var O : TDissection_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKDSIO';
   SBoundsError        = 'BKDSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKDSIO Error: Pointer is NIL in IsADissection_Rec';
   SInvalidType        = 'BKDSIO Error: Type is invalid in IsADissection_Rec';
   SInvalidEOR         = 'BKDSIO Error: EOR is missing in IsADissection_Rec';
   SUnknownToken       = 'BKDSIO Error: Unknown token %d in Read_Dissection_Rec';
   SInsufficientMemory = 'BKDSIO Error: Out of memory in New_Dissection_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdsSequence_No                      = 182 ;
   tkdsAccount                          = 183 ;
   tkdsAmount                           = 184 ;
   tkdsGST_Class                        = 185 ;
   tkdsGST_Amount                       = 186 ;
   tkdsQuantity                         = 187 ;
   tkdsOld_Narration                    = 188 ;
   tkdsHas_Been_Edited                  = 189 ;
   tkdsJournal_Type                     = 190 ;
   tkdsGST_Has_Been_Edited              = 191 ;
   tkdsPayee_Number                     = 192 ;
   tkdsNotes                            = 193 ;
   tkdsECoding_Import_Notes             = 194 ;
   tkdsGL_Narration                     = 195 ;
   tkdsLinked_Journal_Date              = 196 ;
   tkdsSF_Imputed_Credit                = 197 ;
   tkdsSF_Tax_Free_Dist                 = 198 ;
   tkdsSF_Tax_Exempt_Dist               = 199 ;
   tkdsSF_Tax_Deferred_Dist             = 200 ;
   tkdsSF_TFN_Credits                   = 201 ;
   tkdsSF_Foreign_Income                = 202 ;
   tkdsSF_Foreign_Tax_Credits           = 203 ;
   tkdsSF_Capital_Gains_Indexed         = 204 ;
   tkdsSF_Capital_Gains_Disc            = 205 ;
   tkdsSF_Super_Fields_Edited           = 206 ;
   tkdsSF_Capital_Gains_Other           = 207 ;
   tkdsSF_Other_Expenses                = 208 ;
   tkdsSF_CGT_Date                      = 209 ;
   tkdsExternal_GUID                    = 210 ;
   tkdsDocument_Title                   = 211 ;
   tkdsDocument_Status_Update_Required  = 212 ;
   tkdsNotes_Read                       = 213 ;
   tkdsImport_Notes_Read                = 214 ;
   tkdsReference                        = 215 ;
   tkdsSF_Franked                       = 216 ;
   tkdsSF_Unfranked                     = 217 ;
   tkdsSF_Interest                      = 218 ;
   tkdsSF_Capital_Gains_Foreign_Disc    = 219 ;
   tkdsSF_Rent                          = 220 ;
   tkdsSF_Special_Income                = 221 ;
   tkdsSF_Other_Tax_Credit              = 222 ;
   tkdsSF_Non_Resident_Tax              = 223 ;
   tkdsSF_Member_ID                     = 224 ;
   tkdsSF_Foreign_Capital_Gains_Credit  = 225 ;
   tkdsSF_Member_Component              = 226 ;
   tkdsPercent_Amount                   = 227 ;
   tkdsAmount_Type_Is_Percent           = 228 ;
   tkdsSF_Fund_ID                       = 229 ;
   tkdsSF_Member_Account_ID             = 230 ;
   tkdsSF_Fund_Code                     = 231 ;
   tkdsSF_Member_Account_Code           = 232 ;
   tkdsSF_Transaction_ID                = 233 ;
   tkdsSF_Transaction_Code              = 234 ;
   tkdsSF_Capital_Gains_Fraction_Half   = 235 ;
   tkdsSpareL                           = 236 ;
   tkdsJob_Code                         = 237 ;
   tkdsTax_Invoice                      = 238 ;
   tkdsForex_Conversion_Rate            = 239 ;
   tkdsForeign_Currency_Amount          = 240 ;
   tkdsForex_Document_Date              = 241 ;
   tkdsOpening_Balance_Currency         = 242 ;

{  -------------------------------------------------------------------  }

FUNCTION IsADissection_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PDissection_Rec ( P )^ do Begin
      If dsRecord_Type <> tkBegin_Dissection then
         Raise ECorruptData.Create( SInvalidType );
      If dsEOR <> tkEnd_Dissection then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Dissection_Rec ( Var O : TDissection_Rec ; Var F : TIOStream );

Begin
   If IsADissection_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Dissection );
      F.WriteIntegerValue( tkdsSequence_No , dsSequence_No );
      F.WriteStringValue( tkdsAccount , dsAccount );
      F.WriteMoneyValue( tkdsAmount , dsAmount );
      F.WriteByteValue( tkdsGST_Class , dsGST_Class );
      F.WriteMoneyValue( tkdsGST_Amount , dsGST_Amount );
      F.WriteMoneyValue( tkdsQuantity , dsQuantity );
      F.WriteStringValue( tkdsOld_Narration , dsOld_Narration );
      F.WriteBooleanValue( tkdsHas_Been_Edited , dsHas_Been_Edited );
      F.WriteByteValue( tkdsJournal_Type , dsJournal_Type );
      F.WriteBooleanValue( tkdsGST_Has_Been_Edited , dsGST_Has_Been_Edited );
      F.WriteIntegerValue( tkdsPayee_Number , dsPayee_Number );
      F.WriteAnsiStringValue( tkdsNotes , dsNotes );
      F.WriteAnsiStringValue( tkdsECoding_Import_Notes , dsECoding_Import_Notes );
      F.WriteAnsiStringValue( tkdsGL_Narration , dsGL_Narration );
      F.WriteDateValue( tkdsLinked_Journal_Date , dsLinked_Journal_Date );
      F.WriteMoneyValue( tkdsSF_Imputed_Credit , dsSF_Imputed_Credit );
      F.WriteMoneyValue( tkdsSF_Tax_Free_Dist , dsSF_Tax_Free_Dist );
      F.WriteMoneyValue( tkdsSF_Tax_Exempt_Dist , dsSF_Tax_Exempt_Dist );
      F.WriteMoneyValue( tkdsSF_Tax_Deferred_Dist , dsSF_Tax_Deferred_Dist );
      F.WriteMoneyValue( tkdsSF_TFN_Credits , dsSF_TFN_Credits );
      F.WriteMoneyValue( tkdsSF_Foreign_Income , dsSF_Foreign_Income );
      F.WriteMoneyValue( tkdsSF_Foreign_Tax_Credits , dsSF_Foreign_Tax_Credits );
      F.WriteMoneyValue( tkdsSF_Capital_Gains_Indexed , dsSF_Capital_Gains_Indexed );
      F.WriteMoneyValue( tkdsSF_Capital_Gains_Disc , dsSF_Capital_Gains_Disc );
      F.WriteBooleanValue( tkdsSF_Super_Fields_Edited , dsSF_Super_Fields_Edited );
      F.WriteMoneyValue( tkdsSF_Capital_Gains_Other , dsSF_Capital_Gains_Other );
      F.WriteMoneyValue( tkdsSF_Other_Expenses , dsSF_Other_Expenses );
      F.WriteIntegerValue( tkdsSF_CGT_Date , dsSF_CGT_Date );
      F.WriteAnsiStringValue( tkdsExternal_GUID , dsExternal_GUID );
      F.WriteAnsiStringValue( tkdsDocument_Title , dsDocument_Title );
      F.WriteBooleanValue( tkdsDocument_Status_Update_Required , dsDocument_Status_Update_Required );
      F.WriteBooleanValue( tkdsNotes_Read , dsNotes_Read );
      F.WriteBooleanValue( tkdsImport_Notes_Read , dsImport_Notes_Read );
      F.WriteStringValue( tkdsReference , dsReference );
      F.WriteMoneyValue( tkdsSF_Franked , dsSF_Franked );
      F.WriteMoneyValue( tkdsSF_Unfranked , dsSF_Unfranked );
      F.WriteMoneyValue( tkdsSF_Interest , dsSF_Interest );
      F.WriteMoneyValue( tkdsSF_Capital_Gains_Foreign_Disc , dsSF_Capital_Gains_Foreign_Disc );
      F.WriteMoneyValue( tkdsSF_Rent , dsSF_Rent );
      F.WriteMoneyValue( tkdsSF_Special_Income , dsSF_Special_Income );
      F.WriteMoneyValue( tkdsSF_Other_Tax_Credit , dsSF_Other_Tax_Credit );
      F.WriteMoneyValue( tkdsSF_Non_Resident_Tax , dsSF_Non_Resident_Tax );
      F.WriteStringValue( tkdsSF_Member_ID , dsSF_Member_ID );
      F.WriteMoneyValue( tkdsSF_Foreign_Capital_Gains_Credit , dsSF_Foreign_Capital_Gains_Credit );
      F.WriteByteValue( tkdsSF_Member_Component , dsSF_Member_Component );
      F.WriteMoneyValue( tkdsPercent_Amount , dsPercent_Amount );
      F.WriteBooleanValue( tkdsAmount_Type_Is_Percent , dsAmount_Type_Is_Percent );
      F.WriteIntegerValue( tkdsSF_Fund_ID , dsSF_Fund_ID );
      F.WriteIntegerValue( tkdsSF_Member_Account_ID , dsSF_Member_Account_ID );
      F.WriteStringValue( tkdsSF_Fund_Code , dsSF_Fund_Code );
      F.WriteStringValue( tkdsSF_Member_Account_Code , dsSF_Member_Account_Code );
      F.WriteIntegerValue( tkdsSF_Transaction_ID , dsSF_Transaction_ID );
      F.WriteAnsiStringValue( tkdsSF_Transaction_Code , dsSF_Transaction_Code );
      F.WriteBooleanValue( tkdsSF_Capital_Gains_Fraction_Half , dsSF_Capital_Gains_Fraction_Half );
      F.WriteIntegerValue( tkdsSpareL , dsSpareL );
      F.WriteStringValue( tkdsJob_Code , dsJob_Code );
      F.WriteBooleanValue( tkdsTax_Invoice , dsTax_Invoice );
      F.WriteDoubleValue( tkdsForex_Conversion_Rate, dsForex_Conversion_Rate );
      F.WriteMoneyValue( tkdsForeign_Currency_Amount , dsForeign_Currency_Amount );
      F.WriteDateValue( tkdsForex_Document_Date , dsForex_Document_Date );
      F.WriteStringValue( tkdsOpening_Balance_Currency , dsOpening_Balance_Currency );
      F.WriteToken( tkEnd_Dissection );
   end;
end; { of Write_Dissection_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Dissection_Rec ( Var O : TDissection_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Dissection_Rec_Size, 0 );
   O.dsRecord_Type := tkBegin_Dissection;
   O.dsEOR := tkEnd_Dissection;
   Token := tkBegin_Dissection;

   While Token <> tkEnd_Dissection do With O do
   Begin
      Case Token of
         tkBegin_Dissection :; { Do Nothing }
         tkEnd_Dissection :; { Do Nothing }
         tkdsSequence_No                      : dsSequence_No := F.ReadIntegerValue;
         tkdsAccount                          : dsAccount := F.ReadStringValue;
         tkdsAmount                           : dsAmount := F.ReadMoneyValue;
         tkdsGST_Class                        : dsGST_Class := F.ReadByteValue;
         tkdsGST_Amount                       : dsGST_Amount := F.ReadMoneyValue;
         tkdsQuantity                         : dsQuantity := F.ReadMoneyValue;
         tkdsOld_Narration                    : dsOld_Narration := F.ReadStringValue;
         tkdsHas_Been_Edited                  : dsHas_Been_Edited := F.ReadBooleanValue;
         tkdsJournal_Type                     : dsJournal_Type := F.ReadByteValue;
         tkdsGST_Has_Been_Edited              : dsGST_Has_Been_Edited := F.ReadBooleanValue;
         tkdsPayee_Number                     : dsPayee_Number := F.ReadIntegerValue;
         tkdsNotes                            : dsNotes := F.ReadAnsiStringValue;
         tkdsECoding_Import_Notes             : dsECoding_Import_Notes := F.ReadAnsiStringValue;
         tkdsGL_Narration                     : dsGL_Narration := F.ReadAnsiStringValue;
         tkdsLinked_Journal_Date              : dsLinked_Journal_Date := F.ReadDateValue;
         tkdsSF_Imputed_Credit                : dsSF_Imputed_Credit := F.ReadMoneyValue;
         tkdsSF_Tax_Free_Dist                 : dsSF_Tax_Free_Dist := F.ReadMoneyValue;
         tkdsSF_Tax_Exempt_Dist               : dsSF_Tax_Exempt_Dist := F.ReadMoneyValue;
         tkdsSF_Tax_Deferred_Dist             : dsSF_Tax_Deferred_Dist := F.ReadMoneyValue;
         tkdsSF_TFN_Credits                   : dsSF_TFN_Credits := F.ReadMoneyValue;
         tkdsSF_Foreign_Income                : dsSF_Foreign_Income := F.ReadMoneyValue;
         tkdsSF_Foreign_Tax_Credits           : dsSF_Foreign_Tax_Credits := F.ReadMoneyValue;
         tkdsSF_Capital_Gains_Indexed         : dsSF_Capital_Gains_Indexed := F.ReadMoneyValue;
         tkdsSF_Capital_Gains_Disc            : dsSF_Capital_Gains_Disc := F.ReadMoneyValue;
         tkdsSF_Super_Fields_Edited           : dsSF_Super_Fields_Edited := F.ReadBooleanValue;
         tkdsSF_Capital_Gains_Other           : dsSF_Capital_Gains_Other := F.ReadMoneyValue;
         tkdsSF_Other_Expenses                : dsSF_Other_Expenses := F.ReadMoneyValue;
         tkdsSF_CGT_Date                      : dsSF_CGT_Date := F.ReadIntegerValue;
         tkdsExternal_GUID                    : dsExternal_GUID := F.ReadAnsiStringValue;
         tkdsDocument_Title                   : dsDocument_Title := F.ReadAnsiStringValue;
         tkdsDocument_Status_Update_Required  : dsDocument_Status_Update_Required := F.ReadBooleanValue;
         tkdsNotes_Read                       : dsNotes_Read := F.ReadBooleanValue;
         tkdsImport_Notes_Read                : dsImport_Notes_Read := F.ReadBooleanValue;
         tkdsReference                        : dsReference := F.ReadStringValue;
         tkdsSF_Franked                       : dsSF_Franked := F.ReadMoneyValue;
         tkdsSF_Unfranked                     : dsSF_Unfranked := F.ReadMoneyValue;
         tkdsSF_Interest                      : dsSF_Interest := F.ReadMoneyValue;
         tkdsSF_Capital_Gains_Foreign_Disc    : dsSF_Capital_Gains_Foreign_Disc := F.ReadMoneyValue;
         tkdsSF_Rent                          : dsSF_Rent := F.ReadMoneyValue;
         tkdsSF_Special_Income                : dsSF_Special_Income := F.ReadMoneyValue;
         tkdsSF_Other_Tax_Credit              : dsSF_Other_Tax_Credit := F.ReadMoneyValue;
         tkdsSF_Non_Resident_Tax              : dsSF_Non_Resident_Tax := F.ReadMoneyValue;
         tkdsSF_Member_ID                     : dsSF_Member_ID := F.ReadStringValue;
         tkdsSF_Foreign_Capital_Gains_Credit  : dsSF_Foreign_Capital_Gains_Credit := F.ReadMoneyValue;
         tkdsSF_Member_Component              : dsSF_Member_Component := F.ReadByteValue;
         tkdsPercent_Amount                   : dsPercent_Amount := F.ReadMoneyValue;
         tkdsAmount_Type_Is_Percent           : dsAmount_Type_Is_Percent := F.ReadBooleanValue;
         tkdsSF_Fund_ID                       : dsSF_Fund_ID := F.ReadIntegerValue;
         tkdsSF_Member_Account_ID             : dsSF_Member_Account_ID := F.ReadIntegerValue;
         tkdsSF_Fund_Code                     : dsSF_Fund_Code := F.ReadStringValue;
         tkdsSF_Member_Account_Code           : dsSF_Member_Account_Code := F.ReadStringValue;
         tkdsSF_Transaction_ID                : dsSF_Transaction_ID := F.ReadIntegerValue;
         tkdsSF_Transaction_Code              : dsSF_Transaction_Code := F.ReadAnsiStringValue;
         tkdsSF_Capital_Gains_Fraction_Half   : dsSF_Capital_Gains_Fraction_Half := F.ReadBooleanValue;
         tkdsSpareL                           : dsSpareL := F.ReadIntegerValue;
         tkdsJob_Code                         : dsJob_Code := F.ReadStringValue;
         tkdsTax_Invoice                      : dsTax_Invoice := F.ReadBooleanValue;
         tkdsForex_Conversion_Rate            : dsForex_Conversion_Rate := F.ReadDoubleValue;
         tkdsForeign_Currency_Amount          : dsForeign_Currency_Amount := F.ReadMoneyValue;
         tkdsForex_Document_Date              : dsForex_Document_Date := F.ReadDateValue;
         tkdsOpening_Balance_Currency         : dsOpening_Balance_Currency := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Dissection_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Dissection_Rec : pDissection_Rec ;

Var
   P : pDissection_Rec;
Begin
   SafeGetMem( P, Dissection_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Dissection_Rec_Size, 0 );
      dsRecord_Type := tkBegin_Dissection;
      dsEOR         := tkEnd_Dissection;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Dissection_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Dissection_Rec_Dynamic_Fields ( Var O : TDissection_Rec );

Begin
   If IsADissection_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      dsNotes := '' ;
      dsECoding_Import_Notes := '' ;
      dsGL_Narration := '' ;
      dsExternal_GUID := '' ;
      dsDocument_Title := '' ;
      dsSF_Transaction_Code := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
