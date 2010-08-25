UNIT BKblIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Balances                     = 190 ;
   tkEnd_Balances                       = 191 ;

FUNCTION  IsABalances_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Balances_Rec ( Var O : TBalances_Rec ; Var F : TIOStream );
PROCEDURE Read_Balances_Rec ( Var O : TBalances_Rec ; Var F : TIOStream );
FUNCTION  New_Balances_Rec : pBalances_Rec ;
PROCEDURE Free_Balances_Rec_Dynamic_Fields ( Var O : TBalances_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKBLIO';
   SBoundsError        = 'BKBLIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKBLIO Error: Pointer is NIL in IsABalances_Rec';
   SInvalidType        = 'BKBLIO Error: Type is invalid in IsABalances_Rec';
   SInvalidEOR         = 'BKBLIO Error: EOR is missing in IsABalances_Rec';
   SUnknownToken       = 'BKBLIO Error: Unknown token %d in Read_Balances_Rec';
   SInsufficientMemory = 'BKBLIO Error: Out of memory in New_Balances_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkblGST_Period_Starts                = 192 ;
   tkblGST_Period_Ends                  = 193 ;
   tkblClosing_Debtors_Balance          = 194 ;
   tkblOpening_Debtors_Balance          = 195 ;
   tkblFBT_Adjustments                  = 196 ;
   tkblOther_Adjustments                = 197 ;
   tkblClosing_Creditors_Balance        = 198 ;
   tkblOpening_Creditors_Balance        = 199 ;
   tkblCredit_Adjustments               = 200 ;
   tkblBAS_Document_ID                  = 201 ;
   tkblBAS_1C_PT_Last_Months_Income     = 202 ;
   tkblBAS_1D_PT_Branch_Income          = 203 ;
   tkblBAS_1E_PT_Assets                 = 204 ;
   tkblBAS_1F_PT_Tax                    = 205 ;
   tkblBAS_1G_PT_Refund_Used            = 206 ;
   tkblBAS_5B_PT_Ratio                  = 207 ;
   tkblBAS_6B_GST_Adj_PrivUse           = 208 ;
   tkblBAS_7_VAT4_GST_Adj_BAssets       = 209 ;
   tkblBAS_G7_GST_Adj_Assets            = 210 ;
   tkblBAS_G18_GST_Adj_Entertain        = 211 ;
   tkblBAS_W1_GST_Adj_Change            = 212 ;
   tkblBAS_W2_GST_Adj_Exempt            = 213 ;
   tkblBAS_W3_GST_Adj_Other             = 214 ;
   tkblBAS_W4_GST_Cdj_BusUse            = 215 ;
   tkblBAS_T1_VAT1_GST_Cdj_PAssets      = 216 ;
   tkblBAS_T2_VAT2_GST_Cdj_Change       = 217 ;
   tkblBAS_T3_VAT3_GST_Cdj_Other        = 218 ;
   tkblBAS_T4                           = 219 ;
   tkblBAS_F1_GST_Closing_Debtors_BalanceA = 220 ;
   tkblBAS_F2_GST_Opening_Debtors_BalanceB = 221 ;
   tkblBAS_F3                           = 222 ;
   tkblBAS_F4                           = 223 ;
   tkblBAS_Form_Used                    = 224 ;
   tkblBAS_GST_Option                   = 225 ;
   tkblBAS_GST_Included                 = 226 ;
   tkblBAS_G21_GST_Closing_Creditors_BalanceA = 227 ;
   tkblBAS_G22_GST_Opening_Creditors_BalanceB = 228 ;
   tkblBAS_G23                          = 229 ;
   tkblBAS_G24                          = 230 ;
   tkblBAS_PAYG_Instalment_Option       = 231 ;
   tkblBAS_T7_VAT7                      = 232 ;
   tkblBAS_T8_VAT8                      = 233 ;
   tkblBAS_T9_VAT9                      = 234 ;
   tkblBAS_1H                           = 235 ;
   tkblGST_Adj_PrivUse                  = 236 ;
   tkblGST_Adj_BAssets                  = 237 ;
   tkblGST_Adj_Assets                   = 238 ;
   tkblGST_Adj_Entertain                = 239 ;
   tkblGST_Adj_Change                   = 240 ;
   tkblGST_Adj_Exempt                   = 241 ;
   tkblGST_Adj_Other                    = 242 ;
   tkblGST_Cdj_BusUse                   = 243 ;
   tkblGST_Cdj_PAssets                  = 244 ;
   tkblGST_Cdj_Change                   = 245 ;
   tkblGST_Cdj_Other                    = 246 ;
   tkblBAS_7C                           = 247 ;
   tkblBAS_7D                           = 248 ;
   tkblBAS_T6_VAT6                      = 249 ;
   tkblBAS_T5_VAT5                      = 250 ;
   tkblUsing_Fuel_Percent_Method        = 251 ;
   tkblPT_Form_Type                     = 252 ;
   tkblGST_Cdj_Customs                  = 253 ;

{  -------------------------------------------------------------------  }

FUNCTION IsABalances_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PBalances_Rec ( P )^ do Begin
      If blRecord_Type <> tkBegin_Balances then
         Raise ECorruptData.Create( SInvalidType );
      If blEOR <> tkEnd_Balances then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_Balances_Rec ( Var O : TBalances_Rec ; Var F : TIOStream );

Begin
   If IsABalances_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_Balances );
      F.WriteDateValue( tkblGST_Period_Starts , blGST_Period_Starts );
      F.WriteDateValue( tkblGST_Period_Ends , blGST_Period_Ends );
      F.WriteMoneyValue( tkblClosing_Debtors_Balance , blClosing_Debtors_Balance );
      F.WriteMoneyValue( tkblOpening_Debtors_Balance , blOpening_Debtors_Balance );
      F.WriteMoneyValue( tkblFBT_Adjustments , blFBT_Adjustments );
      F.WriteMoneyValue( tkblOther_Adjustments , blOther_Adjustments );
      F.WriteMoneyValue( tkblClosing_Creditors_Balance , blClosing_Creditors_Balance );
      F.WriteMoneyValue( tkblOpening_Creditors_Balance , blOpening_Creditors_Balance );
      F.WriteMoneyValue( tkblCredit_Adjustments , blCredit_Adjustments );
      F.WriteStringValue( tkblBAS_Document_ID , blBAS_Document_ID );
      F.WriteMoneyValue( tkblBAS_1C_PT_Last_Months_Income , blBAS_1C_PT_Last_Months_Income );
      F.WriteMoneyValue( tkblBAS_1D_PT_Branch_Income , blBAS_1D_PT_Branch_Income );
      F.WriteMoneyValue( tkblBAS_1E_PT_Assets , blBAS_1E_PT_Assets );
      F.WriteMoneyValue( tkblBAS_1F_PT_Tax , blBAS_1F_PT_Tax );
      F.WriteMoneyValue( tkblBAS_1G_PT_Refund_Used , blBAS_1G_PT_Refund_Used );
      F.WriteMoneyValue( tkblBAS_5B_PT_Ratio , blBAS_5B_PT_Ratio );
      F.WriteMoneyValue( tkblBAS_6B_GST_Adj_PrivUse , blBAS_6B_GST_Adj_PrivUse );
      F.WriteMoneyValue( tkblBAS_7_VAT4_GST_Adj_BAssets , blBAS_7_VAT4_GST_Adj_BAssets );
      F.WriteMoneyValue( tkblBAS_G7_GST_Adj_Assets , blBAS_G7_GST_Adj_Assets );
      F.WriteMoneyValue( tkblBAS_G18_GST_Adj_Entertain , blBAS_G18_GST_Adj_Entertain );
      F.WriteMoneyValue( tkblBAS_W1_GST_Adj_Change , blBAS_W1_GST_Adj_Change );
      F.WriteMoneyValue( tkblBAS_W2_GST_Adj_Exempt , blBAS_W2_GST_Adj_Exempt );
      F.WriteMoneyValue( tkblBAS_W3_GST_Adj_Other , blBAS_W3_GST_Adj_Other );
      F.WriteMoneyValue( tkblBAS_W4_GST_Cdj_BusUse , blBAS_W4_GST_Cdj_BusUse );
      F.WriteMoneyValue( tkblBAS_T1_VAT1_GST_Cdj_PAssets , blBAS_T1_VAT1_GST_Cdj_PAssets );
      F.WriteMoneyValue( tkblBAS_T2_VAT2_GST_Cdj_Change , blBAS_T2_VAT2_GST_Cdj_Change );
      F.WriteMoneyValue( tkblBAS_T3_VAT3_GST_Cdj_Other , blBAS_T3_VAT3_GST_Cdj_Other );
      F.WriteIntegerValue( tkblBAS_T4 , blBAS_T4 );
      F.WriteMoneyValue( tkblBAS_F1_GST_Closing_Debtors_BalanceA , blBAS_F1_GST_Closing_Debtors_BalanceA );
      F.WriteMoneyValue( tkblBAS_F2_GST_Opening_Debtors_BalanceB , blBAS_F2_GST_Opening_Debtors_BalanceB );
      F.WriteMoneyValue( tkblBAS_F3 , blBAS_F3 );
      F.WriteIntegerValue( tkblBAS_F4 , blBAS_F4 );
      F.WriteByteValue( tkblBAS_Form_Used , blBAS_Form_Used );
      F.WriteByteValue( tkblBAS_GST_Option , blBAS_GST_Option );
      F.WriteBooleanValue( tkblBAS_GST_Included , blBAS_GST_Included );
      F.WriteMoneyValue( tkblBAS_G21_GST_Closing_Creditors_BalanceA , blBAS_G21_GST_Closing_Creditors_BalanceA );
      F.WriteMoneyValue( tkblBAS_G22_GST_Opening_Creditors_BalanceB , blBAS_G22_GST_Opening_Creditors_BalanceB );
      F.WriteMoneyValue( tkblBAS_G23 , blBAS_G23 );
      F.WriteIntegerValue( tkblBAS_G24 , blBAS_G24 );
      F.WriteByteValue( tkblBAS_PAYG_Instalment_Option , blBAS_PAYG_Instalment_Option );
      F.WriteMoneyValue( tkblBAS_T7_VAT7 , blBAS_T7_VAT7 );
      F.WriteMoneyValue( tkblBAS_T8_VAT8 , blBAS_T8_VAT8 );
      F.WriteMoneyValue( tkblBAS_T9_VAT9 , blBAS_T9_VAT9 );
      F.WriteMoneyValue( tkblBAS_1H , blBAS_1H );
      F.WriteMoneyValue( tkblGST_Adj_PrivUse , blGST_Adj_PrivUse );
      F.WriteMoneyValue( tkblGST_Adj_BAssets , blGST_Adj_BAssets );
      F.WriteMoneyValue( tkblGST_Adj_Assets , blGST_Adj_Assets );
      F.WriteMoneyValue( tkblGST_Adj_Entertain , blGST_Adj_Entertain );
      F.WriteMoneyValue( tkblGST_Adj_Change , blGST_Adj_Change );
      F.WriteMoneyValue( tkblGST_Adj_Exempt , blGST_Adj_Exempt );
      F.WriteMoneyValue( tkblGST_Adj_Other , blGST_Adj_Other );
      F.WriteMoneyValue( tkblGST_Cdj_BusUse , blGST_Cdj_BusUse );
      F.WriteMoneyValue( tkblGST_Cdj_PAssets , blGST_Cdj_PAssets );
      F.WriteMoneyValue( tkblGST_Cdj_Change , blGST_Cdj_Change );
      F.WriteMoneyValue( tkblGST_Cdj_Other , blGST_Cdj_Other );
      F.WriteMoneyValue( tkblBAS_7C , blBAS_7C );
      F.WriteMoneyValue( tkblBAS_7D , blBAS_7D );
      F.WriteMoneyValue( tkblBAS_T6_VAT6 , blBAS_T6_VAT6 );
      F.WriteMoneyValue( tkblBAS_T5_VAT5 , blBAS_T5_VAT5 );
      F.WriteBooleanValue( tkblUsing_Fuel_Percent_Method , blUsing_Fuel_Percent_Method );
      F.WriteByteValue( tkblPT_Form_Type , blPT_Form_Type );
      F.WriteMoneyValue( tkblGST_Cdj_Customs , blGST_Cdj_Customs );
      F.WriteToken( tkEnd_Balances );
   end;
end; { of Write_Balances_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_Balances_Rec ( Var O : TBalances_Rec; Var F : TIOStream );

Var
   Token : Byte;

Begin
   FillChar( O, Balances_Rec_Size, 0 );
   O.blRecord_Type := tkBegin_Balances;
   O.blEOR := tkEnd_Balances;
   Token := tkBegin_Balances;

   While Token <> tkEnd_Balances do With O do
   Begin
      Case Token of
         tkBegin_Balances :; { Do Nothing }
         tkEnd_Balances :; { Do Nothing }
         tkblGST_Period_Starts                : blGST_Period_Starts := F.ReadDateValue;
         tkblGST_Period_Ends                  : blGST_Period_Ends := F.ReadDateValue;
         tkblClosing_Debtors_Balance          : blClosing_Debtors_Balance := F.ReadMoneyValue;
         tkblOpening_Debtors_Balance          : blOpening_Debtors_Balance := F.ReadMoneyValue;
         tkblFBT_Adjustments                  : blFBT_Adjustments := F.ReadMoneyValue;
         tkblOther_Adjustments                : blOther_Adjustments := F.ReadMoneyValue;
         tkblClosing_Creditors_Balance        : blClosing_Creditors_Balance := F.ReadMoneyValue;
         tkblOpening_Creditors_Balance        : blOpening_Creditors_Balance := F.ReadMoneyValue;
         tkblCredit_Adjustments               : blCredit_Adjustments := F.ReadMoneyValue;
         tkblBAS_Document_ID                  : blBAS_Document_ID := F.ReadStringValue;
         tkblBAS_1C_PT_Last_Months_Income     : blBAS_1C_PT_Last_Months_Income := F.ReadMoneyValue;
         tkblBAS_1D_PT_Branch_Income          : blBAS_1D_PT_Branch_Income := F.ReadMoneyValue;
         tkblBAS_1E_PT_Assets                 : blBAS_1E_PT_Assets := F.ReadMoneyValue;
         tkblBAS_1F_PT_Tax                    : blBAS_1F_PT_Tax := F.ReadMoneyValue;
         tkblBAS_1G_PT_Refund_Used            : blBAS_1G_PT_Refund_Used := F.ReadMoneyValue;
         tkblBAS_5B_PT_Ratio                  : blBAS_5B_PT_Ratio := F.ReadMoneyValue;
         tkblBAS_6B_GST_Adj_PrivUse           : blBAS_6B_GST_Adj_PrivUse := F.ReadMoneyValue;
         tkblBAS_7_VAT4_GST_Adj_BAssets       : blBAS_7_VAT4_GST_Adj_BAssets := F.ReadMoneyValue;
         tkblBAS_G7_GST_Adj_Assets            : blBAS_G7_GST_Adj_Assets := F.ReadMoneyValue;
         tkblBAS_G18_GST_Adj_Entertain        : blBAS_G18_GST_Adj_Entertain := F.ReadMoneyValue;
         tkblBAS_W1_GST_Adj_Change            : blBAS_W1_GST_Adj_Change := F.ReadMoneyValue;
         tkblBAS_W2_GST_Adj_Exempt            : blBAS_W2_GST_Adj_Exempt := F.ReadMoneyValue;
         tkblBAS_W3_GST_Adj_Other             : blBAS_W3_GST_Adj_Other := F.ReadMoneyValue;
         tkblBAS_W4_GST_Cdj_BusUse            : blBAS_W4_GST_Cdj_BusUse := F.ReadMoneyValue;
         tkblBAS_T1_VAT1_GST_Cdj_PAssets      : blBAS_T1_VAT1_GST_Cdj_PAssets := F.ReadMoneyValue;
         tkblBAS_T2_VAT2_GST_Cdj_Change       : blBAS_T2_VAT2_GST_Cdj_Change := F.ReadMoneyValue;
         tkblBAS_T3_VAT3_GST_Cdj_Other        : blBAS_T3_VAT3_GST_Cdj_Other := F.ReadMoneyValue;
         tkblBAS_T4                           : blBAS_T4 := F.ReadIntegerValue;
         tkblBAS_F1_GST_Closing_Debtors_BalanceA : blBAS_F1_GST_Closing_Debtors_BalanceA := F.ReadMoneyValue;
         tkblBAS_F2_GST_Opening_Debtors_BalanceB : blBAS_F2_GST_Opening_Debtors_BalanceB := F.ReadMoneyValue;
         tkblBAS_F3                           : blBAS_F3 := F.ReadMoneyValue;
         tkblBAS_F4                           : blBAS_F4 := F.ReadIntegerValue;
         tkblBAS_Form_Used                    : blBAS_Form_Used := F.ReadByteValue;
         tkblBAS_GST_Option                   : blBAS_GST_Option := F.ReadByteValue;
         tkblBAS_GST_Included                 : blBAS_GST_Included := F.ReadBooleanValue;
         tkblBAS_G21_GST_Closing_Creditors_BalanceA : blBAS_G21_GST_Closing_Creditors_BalanceA := F.ReadMoneyValue;
         tkblBAS_G22_GST_Opening_Creditors_BalanceB : blBAS_G22_GST_Opening_Creditors_BalanceB := F.ReadMoneyValue;
         tkblBAS_G23                          : blBAS_G23 := F.ReadMoneyValue;
         tkblBAS_G24                          : blBAS_G24 := F.ReadIntegerValue;
         tkblBAS_PAYG_Instalment_Option       : blBAS_PAYG_Instalment_Option := F.ReadByteValue;
         tkblBAS_T7_VAT7                      : blBAS_T7_VAT7 := F.ReadMoneyValue;
         tkblBAS_T8_VAT8                      : blBAS_T8_VAT8 := F.ReadMoneyValue;
         tkblBAS_T9_VAT9                      : blBAS_T9_VAT9 := F.ReadMoneyValue;
         tkblBAS_1H                           : blBAS_1H := F.ReadMoneyValue;
         tkblGST_Adj_PrivUse                  : blGST_Adj_PrivUse := F.ReadMoneyValue;
         tkblGST_Adj_BAssets                  : blGST_Adj_BAssets := F.ReadMoneyValue;
         tkblGST_Adj_Assets                   : blGST_Adj_Assets := F.ReadMoneyValue;
         tkblGST_Adj_Entertain                : blGST_Adj_Entertain := F.ReadMoneyValue;
         tkblGST_Adj_Change                   : blGST_Adj_Change := F.ReadMoneyValue;
         tkblGST_Adj_Exempt                   : blGST_Adj_Exempt := F.ReadMoneyValue;
         tkblGST_Adj_Other                    : blGST_Adj_Other := F.ReadMoneyValue;
         tkblGST_Cdj_BusUse                   : blGST_Cdj_BusUse := F.ReadMoneyValue;
         tkblGST_Cdj_PAssets                  : blGST_Cdj_PAssets := F.ReadMoneyValue;
         tkblGST_Cdj_Change                   : blGST_Cdj_Change := F.ReadMoneyValue;
         tkblGST_Cdj_Other                    : blGST_Cdj_Other := F.ReadMoneyValue;
         tkblBAS_7C                           : blBAS_7C := F.ReadMoneyValue;
         tkblBAS_7D                           : blBAS_7D := F.ReadMoneyValue;
         tkblBAS_T6_VAT6                      : blBAS_T6_VAT6 := F.ReadMoneyValue;
         tkblBAS_T5_VAT5                      : blBAS_T5_VAT5 := F.ReadMoneyValue;
         tkblUsing_Fuel_Percent_Method        : blUsing_Fuel_Percent_Method := F.ReadBooleanValue;
         tkblPT_Form_Type                     : blPT_Form_Type := F.ReadByteValue;
         tkblGST_Cdj_Customs                  : blGST_Cdj_Customs := F.ReadMoneyValue;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_Balances_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_Balances_Rec : pBalances_Rec ;

Var
   P : pBalances_Rec;
Begin
   SafeGetMem( P, Balances_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, Balances_Rec_Size, 0 );
      blRecord_Type := tkBegin_Balances;
      blEOR         := tkEnd_Balances;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_Balances_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_Balances_Rec_Dynamic_Fields ( Var O : TBalances_Rec );

Begin
   If IsABalances_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
   end;
end;

{  -------------------------------------------------------------------  }

END.
