UNIT ECdsIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES ECDEFS, IOSTREAM;
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
   SUnitName           = 'ECDSIO';
   SBoundsError        = 'ECDSIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'ECDSIO Error: Pointer is NIL in IsADissection_Rec';
   SInvalidType        = 'ECDSIO Error: Type is invalid in IsADissection_Rec';
   SInvalidEOR         = 'ECDSIO Error: EOR is missing in IsADissection_Rec';
   SUnknownToken       = 'ECDSIO Error: Unknown token %d in Read_Dissection_Rec';
   SInsufficientMemory = 'ECDSIO Error: Out of memory in New_Dissection_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkdsAuto_Sequence_No                 = 182 ;
   tkdsAccount                          = 183 ;
   tkdsAmount                           = 184 ;
   tkdsGST_Class                        = 185 ;
   tkdsGST_Amount                       = 186 ;
   tkdsQuantity                         = 187 ;
   tkdsNarration                        = 188 ;
   tkdsHas_Been_Edited                  = 189 ;
   tkdsGST_Has_Been_Edited              = 190 ;
   tkdsPayee_Number                     = 191 ;
   tkdsNotes                            = 192 ;
   tkdsSF_Edited                        = 193 ;
   tkdsSF_Franked                       = 194 ;
   tkdsSF_Unfranked                     = 195 ;
   tkdsSF_Franking_Credit               = 196 ;
   tkdsTax_Invoice                      = 197 ;
   tkdsJob_Code                         = 198 ;

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
      F.WriteIntegerValue( tkdsAuto_Sequence_No , dsAuto_Sequence_No );
      F.WriteStringValue( tkdsAccount , dsAccount );
      F.WriteMoneyValue( tkdsAmount , dsAmount );
      F.WriteByteValue( tkdsGST_Class , dsGST_Class );
      F.WriteMoneyValue( tkdsGST_Amount , dsGST_Amount );
      F.WriteMoneyValue( tkdsQuantity , dsQuantity );
      F.WriteStringValue( tkdsNarration , dsNarration );
      F.WriteBooleanValue( tkdsHas_Been_Edited , dsHas_Been_Edited );
      F.WriteBooleanValue( tkdsGST_Has_Been_Edited , dsGST_Has_Been_Edited );
      F.WriteIntegerValue( tkdsPayee_Number , dsPayee_Number );
      F.WriteAnsiStringValue( tkdsNotes , dsNotes );
      F.WriteBooleanValue( tkdsSF_Edited , dsSF_Edited );
      F.WriteMoneyValue( tkdsSF_Franked , dsSF_Franked );
      F.WriteMoneyValue( tkdsSF_Unfranked , dsSF_Unfranked );
      F.WriteMoneyValue( tkdsSF_Franking_Credit , dsSF_Franking_Credit );
      F.WriteBooleanValue( tkdsTax_Invoice , dsTax_Invoice );
      F.WriteStringValue( tkdsJob_Code , dsJob_Code );
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
         tkdsAuto_Sequence_No                 : dsAuto_Sequence_No := F.ReadIntegerValue;
         tkdsAccount                          : dsAccount := F.ReadStringValue;
         tkdsAmount                           : dsAmount := F.ReadMoneyValue;
         tkdsGST_Class                        : dsGST_Class := F.ReadByteValue;
         tkdsGST_Amount                       : dsGST_Amount := F.ReadMoneyValue;
         tkdsQuantity                         : dsQuantity := F.ReadMoneyValue;
         tkdsNarration                        : dsNarration := F.ReadStringValue;
         tkdsHas_Been_Edited                  : dsHas_Been_Edited := F.ReadBooleanValue;
         tkdsGST_Has_Been_Edited              : dsGST_Has_Been_Edited := F.ReadBooleanValue;
         tkdsPayee_Number                     : dsPayee_Number := F.ReadIntegerValue;
         tkdsNotes                            : dsNotes := F.ReadAnsiStringValue;
         tkdsSF_Edited                        : dsSF_Edited := F.ReadBooleanValue;
         tkdsSF_Franked                       : dsSF_Franked := F.ReadMoneyValue;
         tkdsSF_Unfranked                     : dsSF_Unfranked := F.ReadMoneyValue;
         tkdsSF_Franking_Credit               : dsSF_Franking_Credit := F.ReadMoneyValue;
         tkdsTax_Invoice                      : dsTax_Invoice := F.ReadBooleanValue;
         tkdsJob_Code                         : dsJob_Code := F.ReadStringValue;
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
   end;
end;

{  -------------------------------------------------------------------  }

END.
