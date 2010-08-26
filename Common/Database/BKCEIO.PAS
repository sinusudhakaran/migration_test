UNIT BKceIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_ClientExtra                  = 40 ;
   tkEnd_ClientExtra                    = 41 ;

FUNCTION  IsAClientExtra_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_ClientExtra_Rec ( Var O : TClientExtra_Rec ; Var F : TIOStream );
PROCEDURE Read_ClientExtra_Rec ( Var O : TClientExtra_Rec ; Var F : TIOStream );
FUNCTION  New_ClientExtra_Rec : pClientExtra_Rec ;
PROCEDURE Free_ClientExtra_Rec_Dynamic_Fields ( Var O : TClientExtra_Rec );

{  -------------------------------------------------------------------  }
IMPLEMENTATION USES MONEYDEF, MALLOC, BKDBEXCEPT;
{  -------------------------------------------------------------------  }

CONST
   SUnitName           = 'BKCEIO';
   SBoundsError        = 'BKCEIO Error: %s is out of bounds [ %d %d ], value is %d';
   SInvalidPointer     = 'BKCEIO Error: Pointer is NIL in IsAClientExtra_Rec';
   SInvalidType        = 'BKCEIO Error: Type is invalid in IsAClientExtra_Rec';
   SInvalidEOR         = 'BKCEIO Error: EOR is missing in IsAClientExtra_Rec';
   SUnknownToken       = 'BKCEIO Error: Unknown token %d in Read_ClientExtra_Rec';
   SInsufficientMemory = 'BKCEIO Error: Out of memory in New_ClientExtra_Rec';

{  -------------------------------------------------------------------  }

PROCEDURE CheckBounds( Const Value, Min, Max : Integer; Const FieldName : ShortString );
Begin
   If ( Value >= Min ) and
      ( Value <= Max ) then exit;
   Raise EBoundsException.CreateFmt( SBoundsError, [ FieldName, Min, Max, Value ] );
end;

{  -------------------------------------------------------------------  }

CONST
   tkceTAX_Applies_From                 = 42 ;
   tkceTAX_Rates                        = 43 ;
   tkceList_Entries_Sort_Order          = 44 ;
   tkceList_Entries_Include             = 45 ;
   tkceList_Entries_Two_Column          = 46 ;
   tkceList_Entries_Show_Balance        = 47 ;
   tkceList_Entries_Show_Notes          = 48 ;
   tkceList_Entries_Wrap_Narration      = 49 ;
   tkceList_Entries_Show_Other_Party    = 50 ;
   tkceBook_Gen_Finance_Reports         = 51 ;
   tkceFRS_Print_NP_Chart_Code_Titles   = 52 ;
   tkceFRS_NP_Chart_Code_Detail_Type    = 53 ;
   tkceAllow_Client_Unlock_Entries      = 54 ;
   tkceAllow_Client_Edit_Chart          = 55 ;
   tkceECoding_Dont_Send_Jobs           = 56 ;
   tkceCustom_Coding_Report_XML         = 57 ;
   tkceCustom_Coding_Report             = 58 ;
   tkceCoding_Report_Column_Line        = 59 ;
   tkceScheduled_Custom_CR_XML          = 60 ;
   tkceBudget_Include_Quantities        = 61 ;
   tkceScheduled_CR_Column_Line         = 62 ;
   tkceCustom_Ledger_Report             = 63 ;
   tkceCustom_Ledger_Report_XML         = 64 ;
   tkceLocal_Currency_Code              = 65 ;
   tkceBlock_Client_Edit_Mems           = 66 ;
   tkceSend_Custom_Documents            = 67 ;
   tkceSend_Custom_Documents_List       = 68 ;
   tkceList_Payees_Detailed             = 69 ;
   tkceList_Payees_SortBy               = 70 ;
   tkceList_Payees_Rule_Line            = 71 ;
   tkceCustom_SFLedger_Titles           = 72 ;
   tkceSUI_Period_Start                 = 73 ;
   tkceSUI_Period_End                   = 74 ;
   tkceSUI_Period_Status                = 75 ;
   tkceSUI_Step_Done                    = 76 ;

{  -------------------------------------------------------------------  }

FUNCTION IsAClientExtra_Rec ( P : Pointer ): Boolean;

Begin
   If P=NIL then
      Raise ECorruptData.Create( SInvalidPointer );
   With PClientExtra_Rec ( P )^ do Begin
      If ceRecord_Type <> tkBegin_ClientExtra then
         Raise ECorruptData.Create( SInvalidType );
      If ceEOR <> tkEnd_ClientExtra then
         Raise ECorruptData.Create( SInvalidEOR );
   end;
   Result := TRUE;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Write_ClientExtra_Rec ( Var O : TClientExtra_Rec ; Var F : TIOStream );

Var
   I     : Byte;
   I1    : Byte;
   I2    : Byte;

Begin
   If IsAClientExtra_Rec ( @O ) then With O do
   Begin
      F.WriteToken( tkBegin_ClientExtra );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBDateValue( tkceTAX_Applies_From , I1, I2, ceTAX_Applies_From[ I1, I2 ] );
      For I1 := 1 to 99 do
         For I2 := 1 to 5 do
            F.WriteBBMoneyValue( tkceTAX_Rates , I1, I2, ceTAX_Rates[ I1, I2 ] );
      F.WriteByteValue( tkceList_Entries_Sort_Order , ceList_Entries_Sort_Order );
      F.WriteByteValue( tkceList_Entries_Include , ceList_Entries_Include );
      F.WriteBooleanValue( tkceList_Entries_Two_Column , ceList_Entries_Two_Column );
      F.WriteBooleanValue( tkceList_Entries_Show_Balance , ceList_Entries_Show_Balance );
      F.WriteBooleanValue( tkceList_Entries_Show_Notes , ceList_Entries_Show_Notes );
      F.WriteBooleanValue( tkceList_Entries_Wrap_Narration , ceList_Entries_Wrap_Narration );
      F.WriteBooleanValue( tkceList_Entries_Show_Other_Party , ceList_Entries_Show_Other_Party );
      F.WriteBooleanValue( tkceBook_Gen_Finance_Reports , ceBook_Gen_Finance_Reports );
      F.WriteBooleanValue( tkceFRS_Print_NP_Chart_Code_Titles , ceFRS_Print_NP_Chart_Code_Titles );
      F.WriteByteValue( tkceFRS_NP_Chart_Code_Detail_Type , ceFRS_NP_Chart_Code_Detail_Type );
      F.WriteBooleanValue( tkceAllow_Client_Unlock_Entries , ceAllow_Client_Unlock_Entries );
      F.WriteBooleanValue( tkceAllow_Client_Edit_Chart , ceAllow_Client_Edit_Chart );
      F.WriteBooleanValue( tkceECoding_Dont_Send_Jobs , ceECoding_Dont_Send_Jobs );
      F.WriteAnsiStringValue( tkceCustom_Coding_Report_XML , ceCustom_Coding_Report_XML );
      F.WriteBooleanValue( tkceCustom_Coding_Report , ceCustom_Coding_Report );
      F.WriteBooleanValue( tkceCoding_Report_Column_Line , ceCoding_Report_Column_Line );
      F.WriteAnsiStringValue( tkceScheduled_Custom_CR_XML , ceScheduled_Custom_CR_XML );
      F.WriteBooleanValue( tkceBudget_Include_Quantities , ceBudget_Include_Quantities );
      F.WriteBooleanValue( tkceScheduled_CR_Column_Line , ceScheduled_CR_Column_Line );
      F.WriteBooleanValue( tkceCustom_Ledger_Report , ceCustom_Ledger_Report );
      F.WriteAnsiStringValue( tkceCustom_Ledger_Report_XML , ceCustom_Ledger_Report_XML );
      F.WriteStringValue( tkceLocal_Currency_Code , ceLocal_Currency_Code );
      F.WriteBooleanValue( tkceBlock_Client_Edit_Mems , ceBlock_Client_Edit_Mems );
      F.WriteBooleanValue( tkceSend_Custom_Documents , ceSend_Custom_Documents );
      For i := 1 to 10 do F.WriteBStringValue( tkceSend_Custom_Documents_List , i, ceSend_Custom_Documents_List[ i ] );
      F.WriteBooleanValue( tkceList_Payees_Detailed , ceList_Payees_Detailed );
      F.WriteByteValue( tkceList_Payees_SortBy , ceList_Payees_SortBy );
      F.WriteBooleanValue( tkceList_Payees_Rule_Line , ceList_Payees_Rule_Line );
      For i := 1 to 1 do F.WriteBStringValue( tkceCustom_SFLedger_Titles , i, ceCustom_SFLedger_Titles[ i ] );
      F.WriteDateValue( tkceSUI_Period_Start , ceSUI_Period_Start );
      F.WriteDateValue( tkceSUI_Period_End , ceSUI_Period_End );
      F.WriteIntegerValue( tkceSUI_Period_Status , ceSUI_Period_Status );
      For i := 0 to 32 do F.WriteBBooleanValue( tkceSUI_Step_Done , i, ceSUI_Step_Done[ i ] );
      F.WriteToken( tkEnd_ClientExtra );
   end;
end; { of Write_ClientExtra_Rec }

{  -------------------------------------------------------------------  }

PROCEDURE Read_ClientExtra_Rec ( Var O : TClientExtra_Rec; Var F : TIOStream );

Var
   Token : Byte;
   I     : Byte;
   I1    : Byte;
   I2    : Byte;
   M     : Money;
   D     : Integer;
   Y     : Boolean;
   S     : ShortString;

Begin
   FillChar( O, ClientExtra_Rec_Size, 0 );
   O.ceRecord_Type := tkBegin_ClientExtra;
   O.ceEOR := tkEnd_ClientExtra;
   Token := tkBegin_ClientExtra;

   While Token <> tkEnd_ClientExtra do With O do
   Begin
      Case Token of
         tkBegin_ClientExtra :; { Do Nothing }
         tkEnd_ClientExtra :; { Do Nothing }
         tkceTAX_Applies_From                 : 
            Begin
               D := F.ReadBBDateValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'ceTAX_Applies_From' );
               CheckBounds( I2, 1, 5, 'ceTAX_Applies_From' );
               ceTAX_Applies_From[ I1, I2 ] := D;
            end;
         tkceTAX_Rates                        : 
            Begin
               M := F.ReadBBMoneyValue( I1, I2 );
               CheckBounds( I1, 1, 99, 'ceTAX_Rates' );
               CheckBounds( I2, 1, 5, 'ceTAX_Rates' );
               ceTAX_Rates[ I1, I2 ] := M;
            end;
         tkceList_Entries_Sort_Order          : ceList_Entries_Sort_Order := F.ReadByteValue;
         tkceList_Entries_Include             : ceList_Entries_Include := F.ReadByteValue;
         tkceList_Entries_Two_Column          : ceList_Entries_Two_Column := F.ReadBooleanValue;
         tkceList_Entries_Show_Balance        : ceList_Entries_Show_Balance := F.ReadBooleanValue;
         tkceList_Entries_Show_Notes          : ceList_Entries_Show_Notes := F.ReadBooleanValue;
         tkceList_Entries_Wrap_Narration      : ceList_Entries_Wrap_Narration := F.ReadBooleanValue;
         tkceList_Entries_Show_Other_Party    : ceList_Entries_Show_Other_Party := F.ReadBooleanValue;
         tkceBook_Gen_Finance_Reports         : ceBook_Gen_Finance_Reports := F.ReadBooleanValue;
         tkceFRS_Print_NP_Chart_Code_Titles   : ceFRS_Print_NP_Chart_Code_Titles := F.ReadBooleanValue;
         tkceFRS_NP_Chart_Code_Detail_Type    : ceFRS_NP_Chart_Code_Detail_Type := F.ReadByteValue;
         tkceAllow_Client_Unlock_Entries      : ceAllow_Client_Unlock_Entries := F.ReadBooleanValue;
         tkceAllow_Client_Edit_Chart          : ceAllow_Client_Edit_Chart := F.ReadBooleanValue;
         tkceECoding_Dont_Send_Jobs           : ceECoding_Dont_Send_Jobs := F.ReadBooleanValue;
         tkceCustom_Coding_Report_XML         : ceCustom_Coding_Report_XML := F.ReadAnsiStringValue;
         tkceCustom_Coding_Report             : ceCustom_Coding_Report := F.ReadBooleanValue;
         tkceCoding_Report_Column_Line        : ceCoding_Report_Column_Line := F.ReadBooleanValue;
         tkceScheduled_Custom_CR_XML          : ceScheduled_Custom_CR_XML := F.ReadAnsiStringValue;
         tkceBudget_Include_Quantities        : ceBudget_Include_Quantities := F.ReadBooleanValue;
         tkceScheduled_CR_Column_Line         : ceScheduled_CR_Column_Line := F.ReadBooleanValue;
         tkceCustom_Ledger_Report             : ceCustom_Ledger_Report := F.ReadBooleanValue;
         tkceCustom_Ledger_Report_XML         : ceCustom_Ledger_Report_XML := F.ReadAnsiStringValue;
         tkceLocal_Currency_Code              : ceLocal_Currency_Code := F.ReadStringValue;
         tkceBlock_Client_Edit_Mems           : ceBlock_Client_Edit_Mems := F.ReadBooleanValue;
         tkceSend_Custom_Documents            : ceSend_Custom_Documents := F.ReadBooleanValue;
         tkceSend_Custom_Documents_List       : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 10, 'ceSend_Custom_Documents_List' );
               ceSend_Custom_Documents_List[ I ] := S;
            end;
         tkceList_Payees_Detailed             : ceList_Payees_Detailed := F.ReadBooleanValue;
         tkceList_Payees_SortBy               : ceList_Payees_SortBy := F.ReadByteValue;
         tkceList_Payees_Rule_Line            : ceList_Payees_Rule_Line := F.ReadBooleanValue;
         tkceCustom_SFLedger_Titles           : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 1, 'ceCustom_SFLedger_Titles' );
               ceCustom_SFLedger_Titles[ I ] := S;
            end;
         tkceSUI_Period_Start                 : ceSUI_Period_Start := F.ReadDateValue;
         tkceSUI_Period_End                   : ceSUI_Period_End := F.ReadDateValue;
         tkceSUI_Period_Status                : ceSUI_Period_Status := F.ReadIntegerValue;
         tkceSUI_Step_Done                    : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'ceSUI_Step_Done' );
               ceSUI_Step_Done[ I ] := Y;
            end;
         else
            Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
      end; { of Case }
      Token := F.ReadToken;
   end; { of While }
end; { of Read_ClientExtra_Rec }

{  -------------------------------------------------------------------  }

FUNCTION New_ClientExtra_Rec : pClientExtra_Rec ;

Var
   P : pClientExtra_Rec;
Begin
   SafeGetMem( P, ClientExtra_Rec_Size ); 
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, ClientExtra_Rec_Size, 0 );
      ceRecord_Type := tkBegin_ClientExtra;
      ceEOR         := tkEnd_ClientExtra;
   end
   else
      Raise EInsufficientMemory.Create( SInsufficientMemory );
   New_ClientExtra_Rec := P;
end;

{  -------------------------------------------------------------------  }

PROCEDURE Free_ClientExtra_Rec_Dynamic_Fields ( Var O : TClientExtra_Rec );

Begin
   If IsAClientExtra_Rec ( @O ) then With O do
   Begin
      { Free any dynamically allocated memory }
      ceCustom_Coding_Report_XML := '' ;
      ceScheduled_Custom_CR_XML := '' ;
      ceCustom_Ledger_Report_XML := '' ;
   end;
end;

{  -------------------------------------------------------------------  }

END.
