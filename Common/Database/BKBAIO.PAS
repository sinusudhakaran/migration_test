UNIT BKbaIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Bank_Account                 = 150 ;
   tkEnd_Bank_Account                   = 151 ;

FUNCTION  IsABank_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Bank_Account_Rec ( Var O : TBank_Account_Rec ; Var F : TIOStream );
PROCEDURE Read_Bank_Account_Rec ( Var O : TBank_Account_Rec ; Var F : TIOStream );
FUNCTION  New_Bank_Account_Rec : pBank_Account_Rec ;
PROCEDURE Free_Bank_Account_Rec_Dynamic_Fields ( Var O : TBank_Account_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKBAIO';
   SBoundsError        = 'BKBAIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKBAIO Error: Pointer is NIL in IsABank_Account_Rec';
   SInvalidType        = 'BKBAIO Error: Type is invalid in IsABank_Account_Rec';
   SInvalidEOR         = 'BKBAIO Error: EOR is missing in IsABank_Account_Rec';
   SUnknownToken       = 'BKBAIO Error: Unknown token %d in Read_Bank_Account_Rec';
   SInsufficientMemory = 'BKBAIO Error: Out of memory in New_Bank_Account_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkbaBank_Account_Number              = 152 ;
   tkbaBank_Account_Name                = 153 ;
   tkbaBank_Account_Password            = 154 ;
   tkbaContra_Account_Code              = 155 ;
   tkbaCurrent_Balance                  = 156 ;
   tkbaApply_Master_Memorised_Entries   = 157 ;
   tkbaAccount_Type                     = 158 ;
   tkbaColumn_Order                     = 159 ;
   tkbaColumn_Width                     = 160 ;
   tkbaPreferred_View                   = 161 ;
   tkbaHighest_BankLink_ID              = 162 ;
   tkbaHighest_LRN                      = 163 ;
   tkbaColumn_is_Hidden                 = 164 ;
   tkbaAccount_Expiry_Date              = 165 ;
   tkbaHighest_Matched_Item_ID          = 166 ;
   tkbaNotes_Always_Visible             = 167 ;
   tkbaNotes_Height                     = 168 ;
   tkbaLast_ECoding_Transaction_UID     = 169 ;
   tkbaColumn_Is_Not_Editable           = 170 ;
   tkbaExtend_Expiry_Date               = 171 ;
   tkbaIs_A_Manual_Account              = 172 ;
   tkbaAnalysis_Coding_Level            = 173 ;
   tkbaECoding_Account_UID              = 174 ;
   tkbaCoding_Sort_Order                = 175 ;
   tkbaManual_Account_Type              = 176 ;
   tkbaManual_Account_Institution       = 177 ;
   tkbaManual_Account_Sent_To_Admin     = 178 ;
   tkbaSpare_String                     = 179 ;
   tkbaSpare_Boolean                    = 180 ;
   tkbaSpare_Number                     = 181 ;
   tkbaSpare_Byte                       = 182 ;
   tkbaHDE_Column_Order                 = 183 ;
   tkbaHDE_Column_Width                 = 184 ;
   tkbaHDE_Column_is_Hidden             = 185 ;
   tkbaHDE_Column_is_Not_Editable       = 186 ;
   tkbaHDE_Sort_Order                   = 187 ;
   tkbaMDE_Column_Order                 = 188 ;
   tkbaMDE_Column_Width                 = 189 ;
   tkbaMDE_Column_is_Hidden             = 190 ;
   tkbaMDE_Column_is_Not_Editable       = 191 ;
   tkbaMDE_Sort_Order                   = 192 ;
   tkbaDIS_Column_Order                 = 193 ;
   tkbaDIS_Column_Width                 = 194 ;
   tkbaDIS_Column_is_Hidden             = 195 ;
   tkbaDIS_Column_is_Not_Editable       = 196 ;
   tkbaDIS_Sort_Order                   = 197 ;
   tkbaDesktop_Super_Ledger_ID          = 198 ;
   tkbaCurrency_Code                    = 199 ;
   tkbaDefault_Forex_Source             = 200 ;
   tkbaDefault_Forex_Description        = 201 ;
   tkbaSuperFund_Ledger_Code            = 202 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABank_Account_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBank_Account_Rec ( P )^ do Begin
      If baRecord_Type <> tkBegin_Bank_Account then
         Raise ECorruptData.Create( SInvalidType );
      If baEOR <> tkEnd_Bank_Account then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Bank_Account_Rec ( Var O : TBank_Account_Rec ; Var F : TIOStream );

Var
   I     : Byte;

Begin
   If IsABank_Account_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Bank_Account );
      F.WriteStringValue( tkbaBank_Account_Number , baBank_Account_Number );
      F.WriteStringValue( tkbaBank_Account_Name , baBank_Account_Name );
      F.WriteStringValue( tkbaBank_Account_Password , baBank_Account_Password );
      F.WriteStringValue( tkbaContra_Account_Code , baContra_Account_Code );
      F.WriteMoneyValue( tkbaCurrent_Balance , baCurrent_Balance );
      F.WriteBooleanValue( tkbaApply_Master_Memorised_Entries , baApply_Master_Memorised_Entries );
      F.WriteByteValue( tkbaAccount_Type , baAccount_Type );
      For i := 0 to 32 do F.WriteBByteValue( tkbaColumn_Order , i, baColumn_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkbaColumn_Width , i, baColumn_Width[ i ] );
      F.WriteByteValue( tkbaPreferred_View , baPreferred_View );
      F.WriteIntegerValue( tkbaHighest_BankLink_ID , baHighest_BankLink_ID );
      F.WriteIntegerValue( tkbaHighest_LRN , baHighest_LRN );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaColumn_is_Hidden , i, baColumn_is_Hidden[ i ] );
      F.WriteDateValue( tkbaAccount_Expiry_Date , baAccount_Expiry_Date );
      F.WriteIntegerValue( tkbaHighest_Matched_Item_ID , baHighest_Matched_Item_ID );
      F.WriteBooleanValue( tkbaNotes_Always_Visible , baNotes_Always_Visible );
      F.WriteIntegerValue( tkbaNotes_Height , baNotes_Height );
      F.WriteIntegerValue( tkbaLast_ECoding_Transaction_UID , baLast_ECoding_Transaction_UID );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaColumn_Is_Not_Editable , i, baColumn_Is_Not_Editable[ i ] );
      F.WriteBooleanValue( tkbaExtend_Expiry_Date , baExtend_Expiry_Date );
      F.WriteBooleanValue( tkbaIs_A_Manual_Account , baIs_A_Manual_Account );
      F.WriteIntegerValue( tkbaAnalysis_Coding_Level , baAnalysis_Coding_Level );
      F.WriteIntegerValue( tkbaECoding_Account_UID , baECoding_Account_UID );
      F.WriteIntegerValue( tkbaCoding_Sort_Order , baCoding_Sort_Order );
      F.WriteIntegerValue( tkbaManual_Account_Type , baManual_Account_Type );
      F.WriteStringValue( tkbaManual_Account_Institution , baManual_Account_Institution );
      F.WriteBooleanValue( tkbaManual_Account_Sent_To_Admin , baManual_Account_Sent_To_Admin );
      F.WriteAnsiStringValue( tkbaSpare_String , baSpare_String );
      F.WriteBooleanValue( tkbaSpare_Boolean , baSpare_Boolean );
      F.WriteIntegerValue( tkbaSpare_Number , baSpare_Number );
      F.WriteByteValue( tkbaSpare_Byte , baSpare_Byte );
      For i := 0 to 32 do F.WriteBByteValue( tkbaHDE_Column_Order , i, baHDE_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkbaHDE_Column_Width , i, baHDE_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaHDE_Column_is_Hidden , i, baHDE_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaHDE_Column_is_Not_Editable , i, baHDE_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkbaHDE_Sort_Order , baHDE_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkbaMDE_Column_Order , i, baMDE_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkbaMDE_Column_Width , i, baMDE_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaMDE_Column_is_Hidden , i, baMDE_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaMDE_Column_is_Not_Editable , i, baMDE_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkbaMDE_Sort_Order , baMDE_Sort_Order );
      For i := 0 to 32 do F.WriteBByteValue( tkbaDIS_Column_Order , i, baDIS_Column_Order[ i ] );
      For i := 0 to 32 do F.WriteBIntegerValue( tkbaDIS_Column_Width , i, baDIS_Column_Width[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaDIS_Column_is_Hidden , i, baDIS_Column_is_Hidden[ i ] );
      For i := 0 to 32 do F.WriteBBooleanValue( tkbaDIS_Column_is_Not_Editable , i, baDIS_Column_is_Not_Editable[ i ] );
      F.WriteIntegerValue( tkbaDIS_Sort_Order , baDIS_Sort_Order );
      F.WriteIntegerValue( tkbaDesktop_Super_Ledger_ID , baDesktop_Super_Ledger_ID );
      F.WriteStringValue( tkbaCurrency_Code , baCurrency_Code );
      F.WriteStringValue( tkbaDefault_Forex_Source , baDefault_Forex_Source );
      F.WriteStringValue( tkbaDefault_Forex_Description , baDefault_Forex_Description );
      F.WriteStringValue( tkbaSuperFund_Ledger_Code , baSuperFund_Ledger_Code );
      F.WriteToken( tkEnd_Bank_Account );
   end;
end; { of Write_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Bank_Account_Rec ( Var O : TBank_Account_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   L     : Integer;
   B     : Byte;   
   Y     : Boolean;

Begin
   FillChar( O, Bank_Account_Rec_Size, 0 );
   O.baRecord_Type := tkBegin_Bank_Account;
   O.baEOR := tkEnd_Bank_Account;
   Token := tkBegin_Bank_Account;

   While Token <> tkEnd_Bank_Account do With O do
   Begin
      Case Token of
         tkBegin_Bank_Account :; { Do Nothing }
         tkEnd_Bank_Account :; { Do Nothing }
         tkbaBank_Account_Number              : baBank_Account_Number := F.ReadStringValue;
         tkbaBank_Account_Name                : baBank_Account_Name := F.ReadStringValue;
         tkbaBank_Account_Password            : baBank_Account_Password := F.ReadStringValue;
         tkbaContra_Account_Code              : baContra_Account_Code := F.ReadStringValue;
         tkbaCurrent_Balance                  : baCurrent_Balance := F.ReadMoneyValue;
         tkbaApply_Master_Memorised_Entries   : baApply_Master_Memorised_Entries := F.ReadBooleanValue;
         tkbaAccount_Type                     : baAccount_Type := F.ReadByteValue;
         tkbaColumn_Order                     : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'baColumn_Order' );
               baColumn_Order[ I ] := B;
            end;
         tkbaColumn_Width                     : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'baColumn_Width' );
               baColumn_Width[ I ] := L;
            end;
         tkbaPreferred_View                   : baPreferred_View := F.ReadByteValue;
         tkbaHighest_BankLink_ID              : baHighest_BankLink_ID := F.ReadIntegerValue;
         tkbaHighest_LRN                      : baHighest_LRN := F.ReadIntegerValue;
         tkbaColumn_is_Hidden                 : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baColumn_is_Hidden' );
               baColumn_is_Hidden[ I ] := Y;
            end;
         tkbaAccount_Expiry_Date              : baAccount_Expiry_Date := F.ReadDateValue;
         tkbaHighest_Matched_Item_ID          : baHighest_Matched_Item_ID := F.ReadIntegerValue;
         tkbaNotes_Always_Visible             : baNotes_Always_Visible := F.ReadBooleanValue;
         tkbaNotes_Height                     : baNotes_Height := F.ReadIntegerValue;
         tkbaLast_ECoding_Transaction_UID     : baLast_ECoding_Transaction_UID := F.ReadIntegerValue;
         tkbaColumn_Is_Not_Editable           : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baColumn_Is_Not_Editable' );
               baColumn_Is_Not_Editable[ I ] := Y;
            end;
         tkbaExtend_Expiry_Date               : baExtend_Expiry_Date := F.ReadBooleanValue;
         tkbaIs_A_Manual_Account              : baIs_A_Manual_Account := F.ReadBooleanValue;
         tkbaAnalysis_Coding_Level            : baAnalysis_Coding_Level := F.ReadIntegerValue;
         tkbaECoding_Account_UID              : baECoding_Account_UID := F.ReadIntegerValue;
         tkbaCoding_Sort_Order                : baCoding_Sort_Order := F.ReadIntegerValue;
         tkbaManual_Account_Type              : baManual_Account_Type := F.ReadIntegerValue;
         tkbaManual_Account_Institution       : baManual_Account_Institution := F.ReadStringValue;
         tkbaManual_Account_Sent_To_Admin     : baManual_Account_Sent_To_Admin := F.ReadBooleanValue;
         tkbaSpare_String                     : baSpare_String := F.ReadAnsiStringValue;
         tkbaSpare_Boolean                    : baSpare_Boolean := F.ReadBooleanValue;
         tkbaSpare_Number                     : baSpare_Number := F.ReadIntegerValue;
         tkbaSpare_Byte                       : baSpare_Byte := F.ReadByteValue;
         tkbaHDE_Column_Order                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'baHDE_Column_Order' );
               baHDE_Column_Order[ I ] := B;
            end;
         tkbaHDE_Column_Width                 : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'baHDE_Column_Width' );
               baHDE_Column_Width[ I ] := L;
            end;
         tkbaHDE_Column_is_Hidden             : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baHDE_Column_is_Hidden' );
               baHDE_Column_is_Hidden[ I ] := Y;
            end;
         tkbaHDE_Column_is_Not_Editable       : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baHDE_Column_is_Not_Editable' );
               baHDE_Column_is_Not_Editable[ I ] := Y;
            end;
         tkbaHDE_Sort_Order                   : baHDE_Sort_Order := F.ReadIntegerValue;
         tkbaMDE_Column_Order                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'baMDE_Column_Order' );
               baMDE_Column_Order[ I ] := B;
            end;
         tkbaMDE_Column_Width                 : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'baMDE_Column_Width' );
               baMDE_Column_Width[ I ] := L;
            end;
         tkbaMDE_Column_is_Hidden             : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baMDE_Column_is_Hidden' );
               baMDE_Column_is_Hidden[ I ] := Y;
            end;
         tkbaMDE_Column_is_Not_Editable       : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baMDE_Column_is_Not_Editable' );
               baMDE_Column_is_Not_Editable[ I ] := Y;
            end;
         tkbaMDE_Sort_Order                   : baMDE_Sort_Order := F.ReadIntegerValue;
         tkbaDIS_Column_Order                 : 
            Begin
               B := F.ReadBByteValue( I );
               CheckBounds( I, 0, 32, 'baDIS_Column_Order' );
               baDIS_Column_Order[ I ] := B;
            end;
         tkbaDIS_Column_Width                 : 
            Begin
               L := F.ReadBIntegerValue( I );
               CheckBounds( I, 0, 32, 'baDIS_Column_Width' );
               baDIS_Column_Width[ I ] := L;
            end;
         tkbaDIS_Column_is_Hidden             : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baDIS_Column_is_Hidden' );
               baDIS_Column_is_Hidden[ I ] := Y;
            end;
         tkbaDIS_Column_is_Not_Editable       : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'baDIS_Column_is_Not_Editable' );
               baDIS_Column_is_Not_Editable[ I ] := Y;
            end;
         tkbaDIS_Sort_Order                   : baDIS_Sort_Order := F.ReadIntegerValue;
         tkbaDesktop_Super_Ledger_ID          : baDesktop_Super_Ledger_ID := F.ReadIntegerValue;
         tkbaCurrency_Code                    : baCurrency_Code := F.ReadStringValue;
         tkbaDefault_Forex_Source             : baDefault_Forex_Source := F.ReadStringValue;
         tkbaDefault_Forex_Description        : baDefault_Forex_Description := F.ReadStringValue;
         tkbaSuperFund_Ledger_Code            : baSuperFund_Ledger_Code := F.ReadStringValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Bank_Account_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Bank_Account_Rec : pBank_Account_Rec ;

Var
   P : pBank_Account_Rec;
Begin
   SafeGetMem( P, Bank_Account_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Bank_Account_Rec_Size, 0 );
      baRecord_Type := tkBegin_Bank_Account;
      baEOR         := tkEnd_Bank_Account;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Bank_Account_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Bank_Account_Rec_Dynamic_Fields ( Var O : TBank_Account_Rec );

Begin
   If IsABank_Account_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      baSpare_String := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
