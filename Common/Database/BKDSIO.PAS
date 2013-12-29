UNIT BKdsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Dissection                   = 180 ;
   tkEnd_Dissection                     = 181 ;

FUNCTION  IsADissection_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Dissection_Rec ( Var O : TDissection_Rec ; Var F : TIOStream );
PROCEDURE Read_Dissection_Rec ( Var O : TDissection_Rec ; Var F : TIOStream );
FUNCTION  New_Dissection_Rec : pDissection_Rec ;
PROCEDURE Free_Dissection_Rec_Dynamic_Fields ( Var O : TDissection_Rec );
FUNCTION Dissection_Rec_Delta(P1, P2, P3: pDissection_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Dissection_Rec(P1, P2: pDissection_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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
   tkdsAudit_Record_ID                  = 236 ;
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
      F.WriteIntegerValue( tkdsAudit_Record_ID , dsAudit_Record_ID );
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
         tkdsAudit_Record_ID                  : dsAudit_Record_ID := F.ReadIntegerValue;
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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tkdsSequence_No to tkdsOpening_Balance_Currency do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Dissection_Rec_Delta(P1, P2, P3: pDissection_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Dissection_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.dsSequence_No <> P2.dsSequence_No) then begin
    P3.dsSequence_No := P1.dsSequence_No;
    ChangedFields[i] := tkdsSequence_No;
    Inc(i);
  end;
  if (P1.dsAccount <> P2.dsAccount) then begin
    P3.dsAccount := P1.dsAccount;
    ChangedFields[i] := tkdsAccount;
    Inc(i);
  end;
  if (P1.dsAmount <> P2.dsAmount) then begin
    P3.dsAmount := P1.dsAmount;
    ChangedFields[i] := tkdsAmount;
    Inc(i);
  end;
  if (P1.dsGST_Class <> P2.dsGST_Class) then begin
    P3.dsGST_Class := P1.dsGST_Class;
    ChangedFields[i] := tkdsGST_Class;
    Inc(i);
  end;
  if (P1.dsGST_Amount <> P2.dsGST_Amount) then begin
    P3.dsGST_Amount := P1.dsGST_Amount;
    ChangedFields[i] := tkdsGST_Amount;
    Inc(i);
  end;
  if (P1.dsQuantity <> P2.dsQuantity) then begin
    P3.dsQuantity := P1.dsQuantity;
    ChangedFields[i] := tkdsQuantity;
    Inc(i);
  end;
  if (P1.dsOld_Narration <> P2.dsOld_Narration) then begin
    P3.dsOld_Narration := P1.dsOld_Narration;
    ChangedFields[i] := tkdsOld_Narration;
    Inc(i);
  end;
  if (P1.dsHas_Been_Edited <> P2.dsHas_Been_Edited) then begin
    P3.dsHas_Been_Edited := P1.dsHas_Been_Edited;
    ChangedFields[i] := tkdsHas_Been_Edited;
    Inc(i);
  end;
  if (P1.dsJournal_Type <> P2.dsJournal_Type) then begin
    P3.dsJournal_Type := P1.dsJournal_Type;
    ChangedFields[i] := tkdsJournal_Type;
    Inc(i);
  end;
  if (P1.dsGST_Has_Been_Edited <> P2.dsGST_Has_Been_Edited) then begin
    P3.dsGST_Has_Been_Edited := P1.dsGST_Has_Been_Edited;
    ChangedFields[i] := tkdsGST_Has_Been_Edited;
    Inc(i);
  end;
  if (P1.dsPayee_Number <> P2.dsPayee_Number) then begin
    P3.dsPayee_Number := P1.dsPayee_Number;
    ChangedFields[i] := tkdsPayee_Number;
    Inc(i);
  end;
  if (P1.dsNotes <> P2.dsNotes) then begin
    P3.dsNotes := P1.dsNotes;
    ChangedFields[i] := tkdsNotes;
    Inc(i);
  end;
  if (P1.dsECoding_Import_Notes <> P2.dsECoding_Import_Notes) then begin
    P3.dsECoding_Import_Notes := P1.dsECoding_Import_Notes;
    ChangedFields[i] := tkdsECoding_Import_Notes;
    Inc(i);
  end;
  if (P1.dsGL_Narration <> P2.dsGL_Narration) then begin
    P3.dsGL_Narration := P1.dsGL_Narration;
    ChangedFields[i] := tkdsGL_Narration;
    Inc(i);
  end;
  if (P1.dsLinked_Journal_Date <> P2.dsLinked_Journal_Date) then begin
    P3.dsLinked_Journal_Date := P1.dsLinked_Journal_Date;
    ChangedFields[i] := tkdsLinked_Journal_Date;
    Inc(i);
  end;
  if (P1.dsSF_Imputed_Credit <> P2.dsSF_Imputed_Credit) then begin
    P3.dsSF_Imputed_Credit := P1.dsSF_Imputed_Credit;
    ChangedFields[i] := tkdsSF_Imputed_Credit;
    Inc(i);
  end;
  if (P1.dsSF_Tax_Free_Dist <> P2.dsSF_Tax_Free_Dist) then begin
    P3.dsSF_Tax_Free_Dist := P1.dsSF_Tax_Free_Dist;
    ChangedFields[i] := tkdsSF_Tax_Free_Dist;
    Inc(i);
  end;
  if (P1.dsSF_Tax_Exempt_Dist <> P2.dsSF_Tax_Exempt_Dist) then begin
    P3.dsSF_Tax_Exempt_Dist := P1.dsSF_Tax_Exempt_Dist;
    ChangedFields[i] := tkdsSF_Tax_Exempt_Dist;
    Inc(i);
  end;
  if (P1.dsSF_Tax_Deferred_Dist <> P2.dsSF_Tax_Deferred_Dist) then begin
    P3.dsSF_Tax_Deferred_Dist := P1.dsSF_Tax_Deferred_Dist;
    ChangedFields[i] := tkdsSF_Tax_Deferred_Dist;
    Inc(i);
  end;
  if (P1.dsSF_TFN_Credits <> P2.dsSF_TFN_Credits) then begin
    P3.dsSF_TFN_Credits := P1.dsSF_TFN_Credits;
    ChangedFields[i] := tkdsSF_TFN_Credits;
    Inc(i);
  end;
  if (P1.dsSF_Foreign_Income <> P2.dsSF_Foreign_Income) then begin
    P3.dsSF_Foreign_Income := P1.dsSF_Foreign_Income;
    ChangedFields[i] := tkdsSF_Foreign_Income;
    Inc(i);
  end;
  if (P1.dsSF_Foreign_Tax_Credits <> P2.dsSF_Foreign_Tax_Credits) then begin
    P3.dsSF_Foreign_Tax_Credits := P1.dsSF_Foreign_Tax_Credits;
    ChangedFields[i] := tkdsSF_Foreign_Tax_Credits;
    Inc(i);
  end;
  if (P1.dsSF_Capital_Gains_Indexed <> P2.dsSF_Capital_Gains_Indexed) then begin
    P3.dsSF_Capital_Gains_Indexed := P1.dsSF_Capital_Gains_Indexed;
    ChangedFields[i] := tkdsSF_Capital_Gains_Indexed;
    Inc(i);
  end;
  if (P1.dsSF_Capital_Gains_Disc <> P2.dsSF_Capital_Gains_Disc) then begin
    P3.dsSF_Capital_Gains_Disc := P1.dsSF_Capital_Gains_Disc;
    ChangedFields[i] := tkdsSF_Capital_Gains_Disc;
    Inc(i);
  end;
  if (P1.dsSF_Super_Fields_Edited <> P2.dsSF_Super_Fields_Edited) then begin
    P3.dsSF_Super_Fields_Edited := P1.dsSF_Super_Fields_Edited;
    ChangedFields[i] := tkdsSF_Super_Fields_Edited;
    Inc(i);
  end;
  if (P1.dsSF_Capital_Gains_Other <> P2.dsSF_Capital_Gains_Other) then begin
    P3.dsSF_Capital_Gains_Other := P1.dsSF_Capital_Gains_Other;
    ChangedFields[i] := tkdsSF_Capital_Gains_Other;
    Inc(i);
  end;
  if (P1.dsSF_Other_Expenses <> P2.dsSF_Other_Expenses) then begin
    P3.dsSF_Other_Expenses := P1.dsSF_Other_Expenses;
    ChangedFields[i] := tkdsSF_Other_Expenses;
    Inc(i);
  end;
  if (P1.dsSF_CGT_Date <> P2.dsSF_CGT_Date) then begin
    P3.dsSF_CGT_Date := P1.dsSF_CGT_Date;
    ChangedFields[i] := tkdsSF_CGT_Date;
    Inc(i);
  end;
  if (P1.dsExternal_GUID <> P2.dsExternal_GUID) then begin
    P3.dsExternal_GUID := P1.dsExternal_GUID;
    ChangedFields[i] := tkdsExternal_GUID;
    Inc(i);
  end;
  if (P1.dsDocument_Title <> P2.dsDocument_Title) then begin
    P3.dsDocument_Title := P1.dsDocument_Title;
    ChangedFields[i] := tkdsDocument_Title;
    Inc(i);
  end;
  if (P1.dsDocument_Status_Update_Required <> P2.dsDocument_Status_Update_Required) then begin
    P3.dsDocument_Status_Update_Required := P1.dsDocument_Status_Update_Required;
    ChangedFields[i] := tkdsDocument_Status_Update_Required;
    Inc(i);
  end;
  if (P1.dsNotes_Read <> P2.dsNotes_Read) then begin
    P3.dsNotes_Read := P1.dsNotes_Read;
    ChangedFields[i] := tkdsNotes_Read;
    Inc(i);
  end;
  if (P1.dsImport_Notes_Read <> P2.dsImport_Notes_Read) then begin
    P3.dsImport_Notes_Read := P1.dsImport_Notes_Read;
    ChangedFields[i] := tkdsImport_Notes_Read;
    Inc(i);
  end;
  if (P1.dsReference <> P2.dsReference) then begin
    P3.dsReference := P1.dsReference;
    ChangedFields[i] := tkdsReference;
    Inc(i);
  end;
  if (P1.dsSF_Franked <> P2.dsSF_Franked) then begin
    P3.dsSF_Franked := P1.dsSF_Franked;
    ChangedFields[i] := tkdsSF_Franked;
    Inc(i);
  end;
  if (P1.dsSF_Unfranked <> P2.dsSF_Unfranked) then begin
    P3.dsSF_Unfranked := P1.dsSF_Unfranked;
    ChangedFields[i] := tkdsSF_Unfranked;
    Inc(i);
  end;
  if (P1.dsSF_Interest <> P2.dsSF_Interest) then begin
    P3.dsSF_Interest := P1.dsSF_Interest;
    ChangedFields[i] := tkdsSF_Interest;
    Inc(i);
  end;
  if (P1.dsSF_Capital_Gains_Foreign_Disc <> P2.dsSF_Capital_Gains_Foreign_Disc) then begin
    P3.dsSF_Capital_Gains_Foreign_Disc := P1.dsSF_Capital_Gains_Foreign_Disc;
    ChangedFields[i] := tkdsSF_Capital_Gains_Foreign_Disc;
    Inc(i);
  end;
  if (P1.dsSF_Rent <> P2.dsSF_Rent) then begin
    P3.dsSF_Rent := P1.dsSF_Rent;
    ChangedFields[i] := tkdsSF_Rent;
    Inc(i);
  end;
  if (P1.dsSF_Special_Income <> P2.dsSF_Special_Income) then begin
    P3.dsSF_Special_Income := P1.dsSF_Special_Income;
    ChangedFields[i] := tkdsSF_Special_Income;
    Inc(i);
  end;
  if (P1.dsSF_Other_Tax_Credit <> P2.dsSF_Other_Tax_Credit) then begin
    P3.dsSF_Other_Tax_Credit := P1.dsSF_Other_Tax_Credit;
    ChangedFields[i] := tkdsSF_Other_Tax_Credit;
    Inc(i);
  end;
  if (P1.dsSF_Non_Resident_Tax <> P2.dsSF_Non_Resident_Tax) then begin
    P3.dsSF_Non_Resident_Tax := P1.dsSF_Non_Resident_Tax;
    ChangedFields[i] := tkdsSF_Non_Resident_Tax;
    Inc(i);
  end;
  if (P1.dsSF_Member_ID <> P2.dsSF_Member_ID) then begin
    P3.dsSF_Member_ID := P1.dsSF_Member_ID;
    ChangedFields[i] := tkdsSF_Member_ID;
    Inc(i);
  end;
  if (P1.dsSF_Foreign_Capital_Gains_Credit <> P2.dsSF_Foreign_Capital_Gains_Credit) then begin
    P3.dsSF_Foreign_Capital_Gains_Credit := P1.dsSF_Foreign_Capital_Gains_Credit;
    ChangedFields[i] := tkdsSF_Foreign_Capital_Gains_Credit;
    Inc(i);
  end;
  if (P1.dsSF_Member_Component <> P2.dsSF_Member_Component) then begin
    P3.dsSF_Member_Component := P1.dsSF_Member_Component;
    ChangedFields[i] := tkdsSF_Member_Component;
    Inc(i);
  end;
  if (P1.dsPercent_Amount <> P2.dsPercent_Amount) then begin
    P3.dsPercent_Amount := P1.dsPercent_Amount;
    ChangedFields[i] := tkdsPercent_Amount;
    Inc(i);
  end;
  if (P1.dsAmount_Type_Is_Percent <> P2.dsAmount_Type_Is_Percent) then begin
    P3.dsAmount_Type_Is_Percent := P1.dsAmount_Type_Is_Percent;
    ChangedFields[i] := tkdsAmount_Type_Is_Percent;
    Inc(i);
  end;
  if (P1.dsSF_Fund_ID <> P2.dsSF_Fund_ID) then begin
    P3.dsSF_Fund_ID := P1.dsSF_Fund_ID;
    ChangedFields[i] := tkdsSF_Fund_ID;
    Inc(i);
  end;
  if (P1.dsSF_Member_Account_ID <> P2.dsSF_Member_Account_ID) then begin
    P3.dsSF_Member_Account_ID := P1.dsSF_Member_Account_ID;
    ChangedFields[i] := tkdsSF_Member_Account_ID;
    Inc(i);
  end;
  if (P1.dsSF_Fund_Code <> P2.dsSF_Fund_Code) then begin
    P3.dsSF_Fund_Code := P1.dsSF_Fund_Code;
    ChangedFields[i] := tkdsSF_Fund_Code;
    Inc(i);
  end;
  if (P1.dsSF_Member_Account_Code <> P2.dsSF_Member_Account_Code) then begin
    P3.dsSF_Member_Account_Code := P1.dsSF_Member_Account_Code;
    ChangedFields[i] := tkdsSF_Member_Account_Code;
    Inc(i);
  end;
  if (P1.dsSF_Transaction_ID <> P2.dsSF_Transaction_ID) then begin
    P3.dsSF_Transaction_ID := P1.dsSF_Transaction_ID;
    ChangedFields[i] := tkdsSF_Transaction_ID;
    Inc(i);
  end;
  if (P1.dsSF_Transaction_Code <> P2.dsSF_Transaction_Code) then begin
    P3.dsSF_Transaction_Code := P1.dsSF_Transaction_Code;
    ChangedFields[i] := tkdsSF_Transaction_Code;
    Inc(i);
  end;
  if (P1.dsSF_Capital_Gains_Fraction_Half <> P2.dsSF_Capital_Gains_Fraction_Half) then begin
    P3.dsSF_Capital_Gains_Fraction_Half := P1.dsSF_Capital_Gains_Fraction_Half;
    ChangedFields[i] := tkdsSF_Capital_Gains_Fraction_Half;
    Inc(i);
  end;
  if (P1.dsAudit_Record_ID <> P2.dsAudit_Record_ID) then begin
    P3.dsAudit_Record_ID := P1.dsAudit_Record_ID;
    ChangedFields[i] := tkdsAudit_Record_ID;
    Inc(i);
  end;
  if (P1.dsJob_Code <> P2.dsJob_Code) then begin
    P3.dsJob_Code := P1.dsJob_Code;
    ChangedFields[i] := tkdsJob_Code;
    Inc(i);
  end;
  if (P1.dsTax_Invoice <> P2.dsTax_Invoice) then begin
    P3.dsTax_Invoice := P1.dsTax_Invoice;
    ChangedFields[i] := tkdsTax_Invoice;
    Inc(i);
  end;
  if (P1.dsForex_Conversion_Rate <> P2.dsForex_Conversion_Rate) then begin
    P3.dsForex_Conversion_Rate := P1.dsForex_Conversion_Rate;
    ChangedFields[i] := tkdsForex_Conversion_Rate;
    Inc(i);
  end;
  if (P1.dsForeign_Currency_Amount <> P2.dsForeign_Currency_Amount) then begin
    P3.dsForeign_Currency_Amount := P1.dsForeign_Currency_Amount;
    ChangedFields[i] := tkdsForeign_Currency_Amount;
    Inc(i);
  end;
  if (P1.dsForex_Document_Date <> P2.dsForex_Document_Date) then begin
    P3.dsForex_Document_Date := P1.dsForex_Document_Date;
    ChangedFields[i] := tkdsForex_Document_Date;
    Inc(i);
  end;
  if (P1.dsOpening_Balance_Currency <> P2.dsOpening_Balance_Currency) then begin
    P3.dsOpening_Balance_Currency := P1.dsOpening_Balance_Currency;
    ChangedFields[i] := tkdsOpening_Balance_Currency;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Dissection_Rec(P1, P2: pDissection_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Dissection_Rec(P1^, S);
    S.Position := 0;
    Read_Dissection_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
