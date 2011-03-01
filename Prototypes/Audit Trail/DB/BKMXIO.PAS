UNIT BKmxIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Memorised_Transaction        = 220 ;
   tkEnd_Memorised_Transaction          = 221 ;

FUNCTION  IsAMemorised_Transaction_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );
PROCEDURE Read_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );
FUNCTION  New_Memorised_Transaction_Rec : pMemorised_Transaction_Rec ;
PROCEDURE Free_Memorised_Transaction_Rec_Dynamic_Fields ( Var O : TMemorised_Transaction_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKMXIO';
   SBoundsError        = 'BKMXIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKMXIO Error: Pointer is NIL in IsAMemorised_Transaction_Rec';
   SInvalidType        = 'BKMXIO Error: Type is invalid in IsAMemorised_Transaction_Rec';
   SInvalidEOR         = 'BKMXIO Error: EOR is missing in IsAMemorised_Transaction_Rec';
   SUnknownToken       = 'BKMXIO Error: Unknown token %d in Read_Memorised_Transaction_Rec';
   SInsufficientMemory = 'BKMXIO Error: Out of memory in New_Memorised_Transaction_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkmxSequence_No                      = 222 ;
   tkmxType                             = 223 ;
   tkmxAmount                           = 224 ;
   tkmxReference                        = 225 ;
   tkmxParticulars                      = 226 ;
   tkmxAnalysis                         = 227 ;
   tkmxOther_Party                      = 228 ;
   tkmxStatement_Details                = 229 ;
   tkmxMatch_on_Amount                  = 230 ;
   tkmxMatch_on_Refce                   = 231 ;
   tkmxMatch_on_Particulars             = 232 ;
   tkmxMatch_on_Analysis                = 233 ;
   tkmxMatch_on_Other_Party             = 234 ;
   tkmxMatch_On_Statement_Details       = 235 ;
   tkmxAccount                          = 236 ;
   tkmxPercentage                       = 237 ;
   tkmxGST_Class                        = 238 ;
   tkmxPayee_Number                     = 239 ;
   tkmxFrom_Master_List                 = 240 ;
   tkmxGST_Has_Been_Edited              = 241 ;
   tkmxMatch_on_Notes                   = 242 ;
   tkmxNotes                            = 243 ;
   tkmxGL_Narration                     = 244 ;
   tkmxLine_Type                        = 245 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAMemorised_Transaction_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PMemorised_Transaction_Rec ( P )^ do Begin
      If mxRecord_Type <> tkBegin_Memorised_Transaction then
         Raise ECorruptData.Create( SInvalidType );
      If mxEOR <> tkEnd_Memorised_Transaction then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsAMemorised_Transaction_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Memorised_Transaction );
      F.WriteIntegerValue( tkmxSequence_No , mxSequence_No );
      F.WriteByteValue( tkmxType , mxType );
      F.WriteMoneyValue( tkmxAmount , mxAmount );
      F.WriteStringValue( tkmxReference , mxReference );
      F.WriteStringValue( tkmxParticulars , mxParticulars );
      F.WriteStringValue( tkmxAnalysis , mxAnalysis );
      F.WriteStringValue( tkmxOther_Party , mxOther_Party );
      F.WriteStringValue( tkmxStatement_Details , mxStatement_Details );
      F.WriteByteValue( tkmxMatch_on_Amount , mxMatch_on_Amount );
      F.WriteBooleanValue( tkmxMatch_on_Refce , mxMatch_on_Refce );
      F.WriteBooleanValue( tkmxMatch_on_Particulars , mxMatch_on_Particulars );
      F.WriteBooleanValue( tkmxMatch_on_Analysis , mxMatch_on_Analysis );
      F.WriteBooleanValue( tkmxMatch_on_Other_Party , mxMatch_on_Other_Party );
      F.WriteBooleanValue( tkmxMatch_On_Statement_Details , mxMatch_On_Statement_Details );
      For i := 1 to 50 do F.WriteBStringValue( tkmxAccount , i, mxAccount[ i ] );
      For i := 1 to 50 do F.WriteBMoneyValue( tkmxPercentage , i, mxPercentage[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkmxGST_Class , i, mxGST_Class[ i ] );
      F.WriteIntegerValue( tkmxPayee_Number , mxPayee_Number );
      F.WriteBooleanValue( tkmxFrom_Master_List , mxFrom_Master_List );
      For i := 1 to 50 do F.WriteBBooleanValue( tkmxGST_Has_Been_Edited , i, mxGST_Has_Been_Edited[ i ] );
      F.WriteBooleanValue( tkmxMatch_on_Notes , mxMatch_on_Notes );
      F.WriteStringValue( tkmxNotes , mxNotes );
      For i := 1 to 50 do F.WriteBStringValue( tkmxGL_Narration , i, mxGL_Narration[ i ] );
      For i := 1 to 50 do F.WriteBByteValue( tkmxLine_Type , i, mxLine_Type[ i ] );
      F.WriteToken( tkEnd_Memorised_Transaction );
   end;
end; { of Write_Memorised_Transaction_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Memorised_Transaction_Rec ( Var O : TMemorised_Transaction_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   M     : Money;
   B     : Byte;   
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, Memorised_Transaction_Rec_Size, 0 );
   O.mxRecord_Type := tkBegin_Memorised_Transaction;
   O.mxEOR := tkEnd_Memorised_Transaction;
   Token := tkBegin_Memorised_Transaction;

   While Token <> tkEnd_Memorised_Transaction do With O do
   Begin
      Case Token of
         tkBegin_Memorised_Transaction :; { Do Nothing }
         tkEnd_Memorised_Transaction :; { Do Nothing }
         tkmxSequence_No                      : mxSequence_No := F.ReadIntegerValue;
         tkmxType                             : mxType := F.ReadByteValue;
         tkmxAmount                           : mxAmount := F.ReadMoneyValue;
         tkmxReference                        : mxReference := F.ReadStringValue;
         tkmxParticulars                      : mxParticulars := F.ReadStringValue;
         tkmxAnalysis                         : mxAnalysis := F.ReadStringValue;
         tkmxOther_Party                      : mxOther_Party := F.ReadStringValue;
         tkmxStatement_Details                : mxStatement_Details := F.ReadStringValue;
         tkmxMatch_on_Amount                  : mxMatch_on_Amount := F.ReadByteValue;
         tkmxMatch_on_Refce                   : mxMatch_on_Refce := F.ReadBooleanValue;
         tkmxMatch_on_Particulars             : mxMatch_on_Particulars := F.ReadBooleanValue;
         tkmxMatch_on_Analysis                : mxMatch_on_Analysis := F.ReadBooleanValue;
         tkmxMatch_on_Other_Party             : mxMatch_on_Other_Party := F.ReadBooleanValue;
         tkmxMatch_On_Statement_Details       : mxMatch_On_Statement_Details := F.ReadBooleanValue;
         tkmxAccount                          : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'mxAccount' );
               mxAccount[ I ] := S;
            end;
         tkmxPercentage                       : 
            Begin
               M := F.ReadBMoneyValue( I );
               CheckBounds( I, 1, 50, 'mxPercentage' );
               mxPercentage[ I ] := M;
            end;
         tkmxGST_Class                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'mxGST_Class' );
               mxGST_Class[ I ] := B;
            end;
         tkmxPayee_Number                     : mxPayee_Number := F.ReadIntegerValue;
         tkmxFrom_Master_List                 : mxFrom_Master_List := F.ReadBooleanValue;
         tkmxGST_Has_Been_Edited              : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 1, 50, 'mxGST_Has_Been_Edited' );
               mxGST_Has_Been_Edited[ I ] := Y;
            end;
         tkmxMatch_on_Notes                   : mxMatch_on_Notes := F.ReadBooleanValue;
         tkmxNotes                            : mxNotes := F.ReadStringValue;
         tkmxGL_Narration                     : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 50, 'mxGL_Narration' );
               mxGL_Narration[ I ] := S;
            end;
         tkmxLine_Type                        : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 1, 50, 'mxLine_Type' );
               mxLine_Type[ I ] := B;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Memorised_Transaction_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Memorised_Transaction_Rec : pMemorised_Transaction_Rec ;

Var
   P : pMemorised_Transaction_Rec;
Begin
   SafeGetMem( P, Memorised_Transaction_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Memorised_Transaction_Rec_Size, 0 );
      mxRecord_Type := tkBegin_Memorised_Transaction;
      mxEOR         := tkEnd_Memorised_Transaction;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Memorised_Transaction_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Memorised_Transaction_Rec_Dynamic_Fields ( Var O : TMemorised_Transaction_Rec );

Begin
   If IsAMemorised_Transaction_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
