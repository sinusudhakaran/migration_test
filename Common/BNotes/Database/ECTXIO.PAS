UNIT ECtxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
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
   SUnitName           = 'ECTXIO';
   SBoundsError        = 'ECTXIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECTXIO Error: Pointer is NIL in IsATransaction_Rec';
   SInvalidType        = 'ECTXIO Error: Type is invalid in IsATransaction_Rec';
   SInvalidEOR         = 'ECTXIO Error: EOR is missing in IsATransaction_Rec';
   SUnknownToken       = 'ECTXIO Error: Unknown token %d in Read_Transaction_Rec';
   SInsufficientMemory = 'ECTXIO Error: Out of memory in New_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tktxAuto_Sequence_No                 = 162 ;
   tktxType                             = 163 ;
   tktxSource                           = 164 ;
   tktxDate_Presented                   = 165 ;
   tktxDate_Effective                   = 166 ;
   tktxAmount                           = 167 ;
   tktxGST_Class                        = 168 ;
   tktxGST_Amount                       = 169 ;
   tktxHas_Been_Edited                  = 170 ;
   tktxQuantity                         = 171 ;
   tktxCheque_Number                    = 172 ;
   tktxReference                        = 173 ;
   tktxParticulars                      = 174 ;
   tktxAnalysis                         = 175 ;
   tktxOrigBB                           = 176 ;
   tktxOther_Party                      = 177 ;
   tktxNarration                        = 178 ;
   tktxAccount                          = 179 ;
   tktxCoded_By                         = 180 ;
   tktxPayee_Number                     = 181 ;
   tktxLocked                           = 182 ;
   tktxGST_Has_Been_Edited              = 183 ;
   tktxNotes                            = 184 ;
   tktxECoding_ID                       = 185 ;
   tktxTax_Invoice_Available            = 186 ;
   tktxUPI_State                        = 187 ;
   tktxCode_Locked                      = 188 ;
   tktxUPI_Can_Delete                   = 189 ;
   tktxSF_Edited                        = 190 ;
   tktxSF_Franked                       = 191 ;
   tktxSF_Unfranked                     = 192 ;
   tktxSF_Franking_Credit               = 193 ;
   tktxOld_Narration                    = 194 ;
   tktxJob_Code                         = 195 ;

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
      F.WriteIntegerValue( tktxAuto_Sequence_No , txAuto_Sequence_No );
      F.WriteByteValue( tktxType , txType );
      F.WriteByteValue( tktxSource , txSource );
      F.WriteDateValue( tktxDate_Presented , txDate_Presented );
      F.WriteDateValue( tktxDate_Effective , txDate_Effective );
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
      F.WriteStringValue( tktxNarration , txNarration );
      F.WriteStringValue( tktxAccount , txAccount );
      F.WriteByteValue( tktxCoded_By , txCoded_By );
      F.WriteIntegerValue( tktxPayee_Number , txPayee_Number );
      F.WriteBooleanValue( tktxLocked , txLocked );
      F.WriteBooleanValue( tktxGST_Has_Been_Edited , txGST_Has_Been_Edited );
      F.WriteAnsiStringValue( tktxNotes , txNotes );
      F.WriteIntegerValue( tktxECoding_ID , txECoding_ID );
      F.WriteBooleanValue( tktxTax_Invoice_Available , txTax_Invoice_Available );
      F.WriteByteValue( tktxUPI_State , txUPI_State );
      F.WriteBooleanValue( tktxCode_Locked , txCode_Locked );
      F.WriteBooleanValue( tktxUPI_Can_Delete , txUPI_Can_Delete );
      F.WriteBooleanValue( tktxSF_Edited , txSF_Edited );
      F.WriteMoneyValue( tktxSF_Franked , txSF_Franked );
      F.WriteMoneyValue( tktxSF_Unfranked , txSF_Unfranked );
      F.WriteMoneyValue( tktxSF_Franking_Credit , txSF_Franking_Credit );
      F.WriteStringValue( tktxOld_Narration , txOld_Narration );
      F.WriteStringValue( tktxJob_Code , txJob_Code );
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
         tktxAuto_Sequence_No                 : txAuto_Sequence_No := F.ReadIntegerValue;
         tktxType                             : txType := F.ReadByteValue;
         tktxSource                           : txSource := F.ReadByteValue;
         tktxDate_Presented                   : txDate_Presented := F.ReadDateValue;
         tktxDate_Effective                   : txDate_Effective := F.ReadDateValue;
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
         tktxNarration                        : txNarration := F.ReadStringValue;
         tktxAccount                          : txAccount := F.ReadStringValue;
         tktxCoded_By                         : txCoded_By := F.ReadByteValue;
         tktxPayee_Number                     : txPayee_Number := F.ReadIntegerValue;
         tktxLocked                           : txLocked := F.ReadBooleanValue;
         tktxGST_Has_Been_Edited              : txGST_Has_Been_Edited := F.ReadBooleanValue;
         tktxNotes                            : txNotes := F.ReadAnsiStringValue;
         tktxECoding_ID                       : txECoding_ID := F.ReadIntegerValue;
         tktxTax_Invoice_Available            : txTax_Invoice_Available := F.ReadBooleanValue;
         tktxUPI_State                        : txUPI_State := F.ReadByteValue;
         tktxCode_Locked                      : txCode_Locked := F.ReadBooleanValue;
         tktxUPI_Can_Delete                   : txUPI_Can_Delete := F.ReadBooleanValue;
         tktxSF_Edited                        : txSF_Edited := F.ReadBooleanValue;
         tktxSF_Franked                       : txSF_Franked := F.ReadMoneyValue;
         tktxSF_Unfranked                     : txSF_Unfranked := F.ReadMoneyValue;
         tktxSF_Franking_Credit               : txSF_Franking_Credit := F.ReadMoneyValue;
         tktxOld_Narration                    : txOld_Narration := F.ReadStringValue;
         tktxJob_Code                         : txJob_Code := F.ReadStringValue;
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
   end;
end;

{  -------------------------------------------------------------------  }

END.
