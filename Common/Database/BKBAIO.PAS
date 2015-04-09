UNIT BKbaIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_Bank_Account                 = 150 ;
   tkEnd_Bank_Account                   = 151 ;

FUNCTION  IsABank_Account_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_Bank_Account_Rec ( Var O : TBank_Account_Rec ; Var F : TIOStream );
PROCEDURE Read_Bank_Account_Rec ( Var O : TBank_Account_Rec ; Var F : TIOStream );
FUNCTION  New_Bank_Account_Rec : pBank_Account_Rec ;
PROCEDURE Free_Bank_Account_Rec_Dynamic_Fields ( Var O : TBank_Account_Rec );
FUNCTION Bank_Account_Rec_Delta(P1, P2, P3: pBank_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_Bank_Account_Rec(P1, P2: pBank_Account_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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
   tkbaIs_A_Provisional_Account         = 180 ;
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
   tkbaAudit_Record_ID                  = 203 ;
   tkbaCore_Account_ID                  = 204 ;
   tkbaSecure_Online_Code               = 205 ;
   tkbaExchange_Gain_Loss_Code          = 206 ;
   tkbaSuggested_UnProcessed_Count      = 207 ;

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
      F.WriteBooleanValue( tkbaIs_A_Provisional_Account , baIs_A_Provisional_Account );
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
      F.WriteIntegerValue( tkbaAudit_Record_ID , baAudit_Record_ID );
      F.WriteIntegerValue( tkbaCore_Account_ID , baCore_Account_ID );
      F.WriteStringValue( tkbaSecure_Online_Code , baSecure_Online_Code );
      F.WriteStringValue( tkbaExchange_Gain_Loss_Code , baExchange_Gain_Loss_Code );
      F.WriteIntegerValue( tkbaSuggested_UnProcessed_Count , baSuggested_UnProcessed_Count );
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
         tkbaIs_A_Provisional_Account         : baIs_A_Provisional_Account := F.ReadBooleanValue;
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
         tkbaAudit_Record_ID                  : baAudit_Record_ID := F.ReadIntegerValue;
         tkbaCore_Account_ID                  : baCore_Account_ID := F.ReadIntegerValue;
         tkbaSecure_Online_Code               : baSecure_Online_Code := F.ReadStringValue;
         tkbaExchange_Gain_Loss_Code          : baExchange_Gain_Loss_Code := F.ReadStringValue;
         tkbaSuggested_UnProcessed_Count      : baSuggested_UnProcessed_Count := F.ReadIntegerValue;
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

procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);
var
  i, j: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;
  j := 0;
  for i := tkbaBank_Account_Number to tkbaSuggested_UnProcessed_Count do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION Bank_Account_Rec_Delta(P1, P2, P3: pBank_Account_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_Bank_Account_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if (P1.baBank_Account_Number <> P2.baBank_Account_Number) then begin
    P3.baBank_Account_Number := P1.baBank_Account_Number;
    ChangedFields[i] := tkbaBank_Account_Number;
    Inc(i);
  end;
  if (P1.baBank_Account_Name <> P2.baBank_Account_Name) then begin
    P3.baBank_Account_Name := P1.baBank_Account_Name;
    ChangedFields[i] := tkbaBank_Account_Name;
    Inc(i);
  end;
  if (P1.baBank_Account_Password <> P2.baBank_Account_Password) then begin
    P3.baBank_Account_Password := P1.baBank_Account_Password;
    ChangedFields[i] := tkbaBank_Account_Password;
    Inc(i);
  end;
  if (P1.baContra_Account_Code <> P2.baContra_Account_Code) then begin
    P3.baContra_Account_Code := P1.baContra_Account_Code;
    ChangedFields[i] := tkbaContra_Account_Code;
    Inc(i);
  end;
  if (P1.baCurrent_Balance <> P2.baCurrent_Balance) then begin
    P3.baCurrent_Balance := P1.baCurrent_Balance;
    ChangedFields[i] := tkbaCurrent_Balance;
    Inc(i);
  end;
  if (P1.baApply_Master_Memorised_Entries <> P2.baApply_Master_Memorised_Entries) then begin
    P3.baApply_Master_Memorised_Entries := P1.baApply_Master_Memorised_Entries;
    ChangedFields[i] := tkbaApply_Master_Memorised_Entries;
    Inc(i);
  end;
  if (P1.baAccount_Type <> P2.baAccount_Type) then begin
    P3.baAccount_Type := P1.baAccount_Type;
    ChangedFields[i] := tkbaAccount_Type;
    Inc(i);
  end;
  if Column_Order_Changed(TColumn_Order_Array(P1.baColumn_Order), 
                  TColumn_Order_Array(P2.baColumn_Order), 
                  TColumn_Order_Array(P3.baColumn_Order)) then begin
    ChangedFields[i] := tkbaColumn_Order;
    Inc(i);
  end;
  if Column_Width_Changed(TColumn_Width_Array(P1.baColumn_Width), 
                  TColumn_Width_Array(P2.baColumn_Width), 
                  TColumn_Width_Array(P3.baColumn_Width)) then begin
    ChangedFields[i] := tkbaColumn_Width;
    Inc(i);
  end;
  if (P1.baPreferred_View <> P2.baPreferred_View) then begin
    P3.baPreferred_View := P1.baPreferred_View;
    ChangedFields[i] := tkbaPreferred_View;
    Inc(i);
  end;
  if (P1.baHighest_BankLink_ID <> P2.baHighest_BankLink_ID) then begin
    P3.baHighest_BankLink_ID := P1.baHighest_BankLink_ID;
    ChangedFields[i] := tkbaHighest_BankLink_ID;
    Inc(i);
  end;
  if (P1.baHighest_LRN <> P2.baHighest_LRN) then begin
    P3.baHighest_LRN := P1.baHighest_LRN;
    ChangedFields[i] := tkbaHighest_LRN;
    Inc(i);
  end;
  if Column_is_Hidden_Changed(TColumn_is_Hidden_Array(P1.baColumn_is_Hidden), 
                  TColumn_is_Hidden_Array(P2.baColumn_is_Hidden), 
                  TColumn_is_Hidden_Array(P3.baColumn_is_Hidden)) then begin
    ChangedFields[i] := tkbaColumn_is_Hidden;
    Inc(i);
  end;
  if (P1.baAccount_Expiry_Date <> P2.baAccount_Expiry_Date) then begin
    P3.baAccount_Expiry_Date := P1.baAccount_Expiry_Date;
    ChangedFields[i] := tkbaAccount_Expiry_Date;
    Inc(i);
  end;
  if (P1.baHighest_Matched_Item_ID <> P2.baHighest_Matched_Item_ID) then begin
    P3.baHighest_Matched_Item_ID := P1.baHighest_Matched_Item_ID;
    ChangedFields[i] := tkbaHighest_Matched_Item_ID;
    Inc(i);
  end;
  if (P1.baNotes_Always_Visible <> P2.baNotes_Always_Visible) then begin
    P3.baNotes_Always_Visible := P1.baNotes_Always_Visible;
    ChangedFields[i] := tkbaNotes_Always_Visible;
    Inc(i);
  end;
  if (P1.baNotes_Height <> P2.baNotes_Height) then begin
    P3.baNotes_Height := P1.baNotes_Height;
    ChangedFields[i] := tkbaNotes_Height;
    Inc(i);
  end;
  if (P1.baLast_ECoding_Transaction_UID <> P2.baLast_ECoding_Transaction_UID) then begin
    P3.baLast_ECoding_Transaction_UID := P1.baLast_ECoding_Transaction_UID;
    ChangedFields[i] := tkbaLast_ECoding_Transaction_UID;
    Inc(i);
  end;
  if Column_Is_Not_Editable_Changed(TColumn_Is_Not_Editable_Array(P1.baColumn_Is_Not_Editable), 
                  TColumn_Is_Not_Editable_Array(P2.baColumn_Is_Not_Editable), 
                  TColumn_Is_Not_Editable_Array(P3.baColumn_Is_Not_Editable)) then begin
    ChangedFields[i] := tkbaColumn_Is_Not_Editable;
    Inc(i);
  end;
  if (P1.baExtend_Expiry_Date <> P2.baExtend_Expiry_Date) then begin
    P3.baExtend_Expiry_Date := P1.baExtend_Expiry_Date;
    ChangedFields[i] := tkbaExtend_Expiry_Date;
    Inc(i);
  end;
  if (P1.baIs_A_Manual_Account <> P2.baIs_A_Manual_Account) then begin
    P3.baIs_A_Manual_Account := P1.baIs_A_Manual_Account;
    ChangedFields[i] := tkbaIs_A_Manual_Account;
    Inc(i);
  end;
  if (P1.baAnalysis_Coding_Level <> P2.baAnalysis_Coding_Level) then begin
    P3.baAnalysis_Coding_Level := P1.baAnalysis_Coding_Level;
    ChangedFields[i] := tkbaAnalysis_Coding_Level;
    Inc(i);
  end;
  if (P1.baECoding_Account_UID <> P2.baECoding_Account_UID) then begin
    P3.baECoding_Account_UID := P1.baECoding_Account_UID;
    ChangedFields[i] := tkbaECoding_Account_UID;
    Inc(i);
  end;
  if (P1.baCoding_Sort_Order <> P2.baCoding_Sort_Order) then begin
    P3.baCoding_Sort_Order := P1.baCoding_Sort_Order;
    ChangedFields[i] := tkbaCoding_Sort_Order;
    Inc(i);
  end;
  if (P1.baManual_Account_Type <> P2.baManual_Account_Type) then begin
    P3.baManual_Account_Type := P1.baManual_Account_Type;
    ChangedFields[i] := tkbaManual_Account_Type;
    Inc(i);
  end;
  if (P1.baManual_Account_Institution <> P2.baManual_Account_Institution) then begin
    P3.baManual_Account_Institution := P1.baManual_Account_Institution;
    ChangedFields[i] := tkbaManual_Account_Institution;
    Inc(i);
  end;
  if (P1.baManual_Account_Sent_To_Admin <> P2.baManual_Account_Sent_To_Admin) then begin
    P3.baManual_Account_Sent_To_Admin := P1.baManual_Account_Sent_To_Admin;
    ChangedFields[i] := tkbaManual_Account_Sent_To_Admin;
    Inc(i);
  end;
  if (P1.baSpare_String <> P2.baSpare_String) then begin
    P3.baSpare_String := P1.baSpare_String;
    ChangedFields[i] := tkbaSpare_String;
    Inc(i);
  end;
  if (P1.baIs_A_Provisional_Account <> P2.baIs_A_Provisional_Account) then begin
    P3.baIs_A_Provisional_Account := P1.baIs_A_Provisional_Account;
    ChangedFields[i] := tkbaIs_A_Provisional_Account;
    Inc(i);
  end;
  if (P1.baSpare_Number <> P2.baSpare_Number) then begin
    P3.baSpare_Number := P1.baSpare_Number;
    ChangedFields[i] := tkbaSpare_Number;
    Inc(i);
  end;
  if (P1.baSpare_Byte <> P2.baSpare_Byte) then begin
    P3.baSpare_Byte := P1.baSpare_Byte;
    ChangedFields[i] := tkbaSpare_Byte;
    Inc(i);
  end;
  if HDE_Column_Order_Changed(THDE_Column_Order_Array(P1.baHDE_Column_Order), 
                  THDE_Column_Order_Array(P2.baHDE_Column_Order), 
                  THDE_Column_Order_Array(P3.baHDE_Column_Order)) then begin
    ChangedFields[i] := tkbaHDE_Column_Order;
    Inc(i);
  end;
  if HDE_Column_Width_Changed(THDE_Column_Width_Array(P1.baHDE_Column_Width), 
                  THDE_Column_Width_Array(P2.baHDE_Column_Width), 
                  THDE_Column_Width_Array(P3.baHDE_Column_Width)) then begin
    ChangedFields[i] := tkbaHDE_Column_Width;
    Inc(i);
  end;
  if HDE_Column_is_Hidden_Changed(THDE_Column_is_Hidden_Array(P1.baHDE_Column_is_Hidden), 
                  THDE_Column_is_Hidden_Array(P2.baHDE_Column_is_Hidden), 
                  THDE_Column_is_Hidden_Array(P3.baHDE_Column_is_Hidden)) then begin
    ChangedFields[i] := tkbaHDE_Column_is_Hidden;
    Inc(i);
  end;
  if HDE_Column_is_Not_Editable_Changed(THDE_Column_is_Not_Editable_Array(P1.baHDE_Column_is_Not_Editable), 
                  THDE_Column_is_Not_Editable_Array(P2.baHDE_Column_is_Not_Editable), 
                  THDE_Column_is_Not_Editable_Array(P3.baHDE_Column_is_Not_Editable)) then begin
    ChangedFields[i] := tkbaHDE_Column_is_Not_Editable;
    Inc(i);
  end;
  if (P1.baHDE_Sort_Order <> P2.baHDE_Sort_Order) then begin
    P3.baHDE_Sort_Order := P1.baHDE_Sort_Order;
    ChangedFields[i] := tkbaHDE_Sort_Order;
    Inc(i);
  end;
  if MDE_Column_Order_Changed(TMDE_Column_Order_Array(P1.baMDE_Column_Order), 
                  TMDE_Column_Order_Array(P2.baMDE_Column_Order), 
                  TMDE_Column_Order_Array(P3.baMDE_Column_Order)) then begin
    ChangedFields[i] := tkbaMDE_Column_Order;
    Inc(i);
  end;
  if MDE_Column_Width_Changed(TMDE_Column_Width_Array(P1.baMDE_Column_Width), 
                  TMDE_Column_Width_Array(P2.baMDE_Column_Width), 
                  TMDE_Column_Width_Array(P3.baMDE_Column_Width)) then begin
    ChangedFields[i] := tkbaMDE_Column_Width;
    Inc(i);
  end;
  if MDE_Column_is_Hidden_Changed(TMDE_Column_is_Hidden_Array(P1.baMDE_Column_is_Hidden), 
                  TMDE_Column_is_Hidden_Array(P2.baMDE_Column_is_Hidden), 
                  TMDE_Column_is_Hidden_Array(P3.baMDE_Column_is_Hidden)) then begin
    ChangedFields[i] := tkbaMDE_Column_is_Hidden;
    Inc(i);
  end;
  if MDE_Column_is_Not_Editable_Changed(TMDE_Column_is_Not_Editable_Array(P1.baMDE_Column_is_Not_Editable), 
                  TMDE_Column_is_Not_Editable_Array(P2.baMDE_Column_is_Not_Editable), 
                  TMDE_Column_is_Not_Editable_Array(P3.baMDE_Column_is_Not_Editable)) then begin
    ChangedFields[i] := tkbaMDE_Column_is_Not_Editable;
    Inc(i);
  end;
  if (P1.baMDE_Sort_Order <> P2.baMDE_Sort_Order) then begin
    P3.baMDE_Sort_Order := P1.baMDE_Sort_Order;
    ChangedFields[i] := tkbaMDE_Sort_Order;
    Inc(i);
  end;
  if DIS_Column_Order_Changed(TDIS_Column_Order_Array(P1.baDIS_Column_Order), 
                  TDIS_Column_Order_Array(P2.baDIS_Column_Order), 
                  TDIS_Column_Order_Array(P3.baDIS_Column_Order)) then begin
    ChangedFields[i] := tkbaDIS_Column_Order;
    Inc(i);
  end;
  if DIS_Column_Width_Changed(TDIS_Column_Width_Array(P1.baDIS_Column_Width), 
                  TDIS_Column_Width_Array(P2.baDIS_Column_Width), 
                  TDIS_Column_Width_Array(P3.baDIS_Column_Width)) then begin
    ChangedFields[i] := tkbaDIS_Column_Width;
    Inc(i);
  end;
  if DIS_Column_is_Hidden_Changed(TDIS_Column_is_Hidden_Array(P1.baDIS_Column_is_Hidden), 
                  TDIS_Column_is_Hidden_Array(P2.baDIS_Column_is_Hidden), 
                  TDIS_Column_is_Hidden_Array(P3.baDIS_Column_is_Hidden)) then begin
    ChangedFields[i] := tkbaDIS_Column_is_Hidden;
    Inc(i);
  end;
  if DIS_Column_is_Not_Editable_Changed(TDIS_Column_is_Not_Editable_Array(P1.baDIS_Column_is_Not_Editable), 
                  TDIS_Column_is_Not_Editable_Array(P2.baDIS_Column_is_Not_Editable), 
                  TDIS_Column_is_Not_Editable_Array(P3.baDIS_Column_is_Not_Editable)) then begin
    ChangedFields[i] := tkbaDIS_Column_is_Not_Editable;
    Inc(i);
  end;
  if (P1.baDIS_Sort_Order <> P2.baDIS_Sort_Order) then begin
    P3.baDIS_Sort_Order := P1.baDIS_Sort_Order;
    ChangedFields[i] := tkbaDIS_Sort_Order;
    Inc(i);
  end;
  if (P1.baDesktop_Super_Ledger_ID <> P2.baDesktop_Super_Ledger_ID) then begin
    P3.baDesktop_Super_Ledger_ID := P1.baDesktop_Super_Ledger_ID;
    ChangedFields[i] := tkbaDesktop_Super_Ledger_ID;
    Inc(i);
  end;
  if (P1.baCurrency_Code <> P2.baCurrency_Code) then begin
    P3.baCurrency_Code := P1.baCurrency_Code;
    ChangedFields[i] := tkbaCurrency_Code;
    Inc(i);
  end;
  if (P1.baDefault_Forex_Source <> P2.baDefault_Forex_Source) then begin
    P3.baDefault_Forex_Source := P1.baDefault_Forex_Source;
    ChangedFields[i] := tkbaDefault_Forex_Source;
    Inc(i);
  end;
  if (P1.baDefault_Forex_Description <> P2.baDefault_Forex_Description) then begin
    P3.baDefault_Forex_Description := P1.baDefault_Forex_Description;
    ChangedFields[i] := tkbaDefault_Forex_Description;
    Inc(i);
  end;
  if (P1.baSuperFund_Ledger_Code <> P2.baSuperFund_Ledger_Code) then begin
    P3.baSuperFund_Ledger_Code := P1.baSuperFund_Ledger_Code;
    ChangedFields[i] := tkbaSuperFund_Ledger_Code;
    Inc(i);
  end;
  if (P1.baAudit_Record_ID <> P2.baAudit_Record_ID) then begin
    P3.baAudit_Record_ID := P1.baAudit_Record_ID;
    ChangedFields[i] := tkbaAudit_Record_ID;
    Inc(i);
  end;
  if (P1.baCore_Account_ID <> P2.baCore_Account_ID) then begin
    P3.baCore_Account_ID := P1.baCore_Account_ID;
    ChangedFields[i] := tkbaCore_Account_ID;
    Inc(i);
  end;
  if (P1.baSecure_Online_Code <> P2.baSecure_Online_Code) then begin
    P3.baSecure_Online_Code := P1.baSecure_Online_Code;
    ChangedFields[i] := tkbaSecure_Online_Code;
    Inc(i);
  end;
  if (P1.baExchange_Gain_Loss_Code <> P2.baExchange_Gain_Loss_Code) then begin
    P3.baExchange_Gain_Loss_Code := P1.baExchange_Gain_Loss_Code;
    ChangedFields[i] := tkbaExchange_Gain_Loss_Code;
    Inc(i);
  end;
  if (P1.baSuggested_UnProcessed_Count <> P2.baSuggested_UnProcessed_Count) then begin
    P3.baSuggested_UnProcessed_Count := P1.baSuggested_UnProcessed_Count;
    ChangedFields[i] := tkbaSuggested_UnProcessed_Count;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_Bank_Account_Rec(P1, P2: pBank_Account_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Bank_Account_Rec(P1^, S);
    S.Position := 0;
    Read_Bank_Account_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
