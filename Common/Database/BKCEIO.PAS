UNIT BKceIO;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

{  -------------------------------------------------------------------  }
INTERFACE USES BKDEFS, IOSTREAM, BKAUDITUTILS;
{  -------------------------------------------------------------------  }

CONST
   tkBegin_ClientExtra                  = 40 ;
   tkEnd_ClientExtra                    = 41 ;

FUNCTION  IsAClientExtra_Rec ( P : Pointer ): Boolean;
PROCEDURE Write_ClientExtra_Rec ( Var O : TClientExtra_Rec ; Var F : TIOStream );
PROCEDURE Read_ClientExtra_Rec ( Var O : TClientExtra_Rec ; Var F : TIOStream );
FUNCTION  New_ClientExtra_Rec : pClientExtra_Rec ;
PROCEDURE Free_ClientExtra_Rec_Dynamic_Fields ( Var O : TClientExtra_Rec );
FUNCTION ClientExtra_Rec_Delta(P1, P2, P3: pClientExtra_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
procedure Copy_ClientExtra_Rec(P1, P2: pClientExtra_Rec);
procedure SetAllFieldsChanged(var ChangedFields: TChanged_Fields_Array);

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
   tkceAudit_Record_ID                  = 75 ;
   tkceSUI_Step_Done                    = 76 ;
   tkceSend_Job_List                    = 77 ;
   tkceSpare_String                     = 78 ;
   tkceOnline_Scheduled_Reports         = 79 ;
   tkceFile_Transfer_Method             = 80 ;
   tkceOnlineBillingFrequency           = 81 ;
   tkceOnlineMaxOfflineDays             = 82 ;
   tkceOnlineStatus                     = 83 ;
   tkceOnlineSubscription               = 84 ;
   tkceOnlineUserEMail                  = 85 ;
   tkceOnlineUserFullName               = 86 ;
   tkceOnlineValuesStored               = 87 ;
   tkceOnlineSubscriptionCount          = 88 ;
   tkceDeliverDataDirectToBLO           = 89 ;
   tkceBLOSecureCode                    = 90 ;
   tkceInclude_Unused_Chart_Codes       = 91 ;
   tkceInclude_Non_Posting_Chart_Codes  = 92 ;
   tkceAdd_Prefix_For_Account_Code      = 93 ;
   tkceCashbook_GST_Map_File_Location   = 94 ;
   tkceCashbook_Export_File_Location    = 95 ;
   tkceBGLAccessToken                   = 96 ;
   tkceBGLRefreshToken                  = 97 ;
   tkceBGLTokenType                     = 98 ;
   tkceBGLTokenExpiresAt                = 99 ;
   tkceBGLFundIDSelected                = 100 ;
   tkceBGLFundNameSelected              = 101 ;

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
      F.WriteIntegerValue( tkceAudit_Record_ID , ceAudit_Record_ID );
      For i := 0 to 32 do F.WriteBBooleanValue( tkceSUI_Step_Done , i, ceSUI_Step_Done[ i ] );
      F.WriteBooleanValue( tkceSend_Job_List , ceSend_Job_List );
      F.WriteAnsiStringValue( tkceSpare_String , ceSpare_String );
      F.WriteBooleanValue( tkceOnline_Scheduled_Reports , ceOnline_Scheduled_Reports );
      F.WriteByteValue( tkceFile_Transfer_Method , ceFile_Transfer_Method );
      F.WriteStringValue( tkceOnlineBillingFrequency , ceOnlineBillingFrequency );
      F.WriteIntegerValue( tkceOnlineMaxOfflineDays , ceOnlineMaxOfflineDays );
      F.WriteIntegerValue( tkceOnlineStatus , ceOnlineStatus );
      For i := 1 to 64 do F.WriteBStringValue( tkceOnlineSubscription , i, ceOnlineSubscription[ i ] );
      F.WriteStringValue( tkceOnlineUserEMail , ceOnlineUserEMail );
      F.WriteStringValue( tkceOnlineUserFullName , ceOnlineUserFullName );
      F.WriteBooleanValue( tkceOnlineValuesStored , ceOnlineValuesStored );
      F.WriteIntegerValue( tkceOnlineSubscriptionCount , ceOnlineSubscriptionCount );
      F.WriteBooleanValue( tkceDeliverDataDirectToBLO , ceDeliverDataDirectToBLO );
      F.WriteStringValue( tkceBLOSecureCode , ceBLOSecureCode );
      F.WriteBooleanValue( tkceInclude_Unused_Chart_Codes , ceInclude_Unused_Chart_Codes );
      F.WriteBooleanValue( tkceInclude_Non_Posting_Chart_Codes , ceInclude_Non_Posting_Chart_Codes );
      F.WriteIntegerValue( tkceAdd_Prefix_For_Account_Code , ceAdd_Prefix_For_Account_Code );
      F.WriteStringValue( tkceCashbook_GST_Map_File_Location , ceCashbook_GST_Map_File_Location );
      F.WriteStringValue( tkceCashbook_Export_File_Location , ceCashbook_Export_File_Location );
      F.WriteStringValue( tkceBGLAccessToken , ceBGLAccessToken );
      F.WriteStringValue( tkceBGLRefreshToken , ceBGLRefreshToken );
      F.WriteStringValue( tkceBGLTokenType , ceBGLTokenType );
      F.WriteDateTimeValue( tkceBGLTokenExpiresAt , ceBGLTokenExpiresAt );
      F.WriteStringValue( tkceBGLFundIDSelected , ceBGLFundIDSelected );
      F.WriteStringValue( tkceBGLFundNameSelected , ceBGLFundNameSelected );
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
         tkceAudit_Record_ID                  : ceAudit_Record_ID := F.ReadIntegerValue;
         tkceSUI_Step_Done                    : 
            Begin
               Y := F.ReadBBooleanValue( I );
               CheckBounds( I, 0, 32, 'ceSUI_Step_Done' );
               ceSUI_Step_Done[ I ] := Y;
            end;
         tkceSend_Job_List                    : ceSend_Job_List := F.ReadBooleanValue;
         tkceSpare_String                     : ceSpare_String := F.ReadAnsiStringValue;
         tkceOnline_Scheduled_Reports         : ceOnline_Scheduled_Reports := F.ReadBooleanValue;
         tkceFile_Transfer_Method             : ceFile_Transfer_Method := F.ReadByteValue;
         tkceOnlineBillingFrequency           : ceOnlineBillingFrequency := F.ReadStringValue;
         tkceOnlineMaxOfflineDays             : ceOnlineMaxOfflineDays := F.ReadIntegerValue;
         tkceOnlineStatus                     : ceOnlineStatus := F.ReadIntegerValue;
         tkceOnlineSubscription               : 
            Begin
               S := F.ReadBStringValue( I );
               CheckBounds( I, 1, 64, 'ceOnlineSubscription' );
               ceOnlineSubscription[ I ] := S;
            end;
         tkceOnlineUserEMail                  : ceOnlineUserEMail := F.ReadStringValue;
         tkceOnlineUserFullName               : ceOnlineUserFullName := F.ReadStringValue;
         tkceOnlineValuesStored               : ceOnlineValuesStored := F.ReadBooleanValue;
         tkceOnlineSubscriptionCount          : ceOnlineSubscriptionCount := F.ReadIntegerValue;
         tkceDeliverDataDirectToBLO           : ceDeliverDataDirectToBLO := F.ReadBooleanValue;
         tkceBLOSecureCode                    : ceBLOSecureCode := F.ReadStringValue;
         tkceInclude_Unused_Chart_Codes       : ceInclude_Unused_Chart_Codes := F.ReadBooleanValue;
         tkceInclude_Non_Posting_Chart_Codes  : ceInclude_Non_Posting_Chart_Codes := F.ReadBooleanValue;
         tkceAdd_Prefix_For_Account_Code      : ceAdd_Prefix_For_Account_Code := F.ReadIntegerValue;
         tkceCashbook_GST_Map_File_Location   : ceCashbook_GST_Map_File_Location := F.ReadStringValue;
         tkceCashbook_Export_File_Location    : ceCashbook_Export_File_Location := F.ReadStringValue;
         tkceBGLAccessToken                   : ceBGLAccessToken := F.ReadStringValue;
         tkceBGLRefreshToken                  : ceBGLRefreshToken := F.ReadStringValue;
         tkceBGLTokenType                     : ceBGLTokenType := F.ReadStringValue;
         tkceBGLTokenExpiresAt                : ceBGLTokenExpiresAt := F.ReadDateTimeValue;
         tkceBGLFundIDSelected                : ceBGLFundIDSelected := F.ReadStringValue;
         tkceBGLFundNameSelected              : ceBGLFundNameSelected := F.ReadStringValue;
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
      ceSpare_String := '' ;
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
  for i := tkceTAX_Applies_From to tkceBGLFundNameSelected do begin
    ChangedFields[j] := i;
    Inc(j);
  end;
end;

{  -------------------------------------------------------------------  }

FUNCTION ClientExtra_Rec_Delta(P1, P2, P3: pClientExtra_Rec; var ChangedFields: TChanged_Fields_Array): Boolean;
var
  i: integer;
begin
  for i := Low(ChangedFields) to High(ChangedFields) do
    ChangedFields[i] := 0;

  //Add
  if not Assigned(P2) then begin
    Copy_ClientExtra_Rec(P1, P3);
    SetAllFieldsChanged(ChangedFields);
    Result := True;
    Exit;
  end;

  //Change
  i := 0;
  if TAX_Applies_From_Changed(TTAX_Applies_From_Array(P1.ceTAX_Applies_From), 
                  TTAX_Applies_From_Array(P2.ceTAX_Applies_From), 
                  TTAX_Applies_From_Array(P3.ceTAX_Applies_From)) then begin
    ChangedFields[i] := tkceTAX_Applies_From;
    Inc(i);
  end;
  if TAX_Rates_Changed(TTAX_Rates_Array(P1.ceTAX_Rates), 
                  TTAX_Rates_Array(P2.ceTAX_Rates), 
                  TTAX_Rates_Array(P3.ceTAX_Rates)) then begin
    ChangedFields[i] := tkceTAX_Rates;
    Inc(i);
  end;
  if (P1.ceList_Entries_Sort_Order <> P2.ceList_Entries_Sort_Order) then begin
    P3.ceList_Entries_Sort_Order := P1.ceList_Entries_Sort_Order;
    ChangedFields[i] := tkceList_Entries_Sort_Order;
    Inc(i);
  end;
  if (P1.ceList_Entries_Include <> P2.ceList_Entries_Include) then begin
    P3.ceList_Entries_Include := P1.ceList_Entries_Include;
    ChangedFields[i] := tkceList_Entries_Include;
    Inc(i);
  end;
  if (P1.ceList_Entries_Two_Column <> P2.ceList_Entries_Two_Column) then begin
    P3.ceList_Entries_Two_Column := P1.ceList_Entries_Two_Column;
    ChangedFields[i] := tkceList_Entries_Two_Column;
    Inc(i);
  end;
  if (P1.ceList_Entries_Show_Balance <> P2.ceList_Entries_Show_Balance) then begin
    P3.ceList_Entries_Show_Balance := P1.ceList_Entries_Show_Balance;
    ChangedFields[i] := tkceList_Entries_Show_Balance;
    Inc(i);
  end;
  if (P1.ceList_Entries_Show_Notes <> P2.ceList_Entries_Show_Notes) then begin
    P3.ceList_Entries_Show_Notes := P1.ceList_Entries_Show_Notes;
    ChangedFields[i] := tkceList_Entries_Show_Notes;
    Inc(i);
  end;
  if (P1.ceList_Entries_Wrap_Narration <> P2.ceList_Entries_Wrap_Narration) then begin
    P3.ceList_Entries_Wrap_Narration := P1.ceList_Entries_Wrap_Narration;
    ChangedFields[i] := tkceList_Entries_Wrap_Narration;
    Inc(i);
  end;
  if (P1.ceList_Entries_Show_Other_Party <> P2.ceList_Entries_Show_Other_Party) then begin
    P3.ceList_Entries_Show_Other_Party := P1.ceList_Entries_Show_Other_Party;
    ChangedFields[i] := tkceList_Entries_Show_Other_Party;
    Inc(i);
  end;
  if (P1.ceBook_Gen_Finance_Reports <> P2.ceBook_Gen_Finance_Reports) then begin
    P3.ceBook_Gen_Finance_Reports := P1.ceBook_Gen_Finance_Reports;
    ChangedFields[i] := tkceBook_Gen_Finance_Reports;
    Inc(i);
  end;
  if (P1.ceFRS_Print_NP_Chart_Code_Titles <> P2.ceFRS_Print_NP_Chart_Code_Titles) then begin
    P3.ceFRS_Print_NP_Chart_Code_Titles := P1.ceFRS_Print_NP_Chart_Code_Titles;
    ChangedFields[i] := tkceFRS_Print_NP_Chart_Code_Titles;
    Inc(i);
  end;
  if (P1.ceFRS_NP_Chart_Code_Detail_Type <> P2.ceFRS_NP_Chart_Code_Detail_Type) then begin
    P3.ceFRS_NP_Chart_Code_Detail_Type := P1.ceFRS_NP_Chart_Code_Detail_Type;
    ChangedFields[i] := tkceFRS_NP_Chart_Code_Detail_Type;
    Inc(i);
  end;
  if (P1.ceAllow_Client_Unlock_Entries <> P2.ceAllow_Client_Unlock_Entries) then begin
    P3.ceAllow_Client_Unlock_Entries := P1.ceAllow_Client_Unlock_Entries;
    ChangedFields[i] := tkceAllow_Client_Unlock_Entries;
    Inc(i);
  end;
  if (P1.ceAllow_Client_Edit_Chart <> P2.ceAllow_Client_Edit_Chart) then begin
    P3.ceAllow_Client_Edit_Chart := P1.ceAllow_Client_Edit_Chart;
    ChangedFields[i] := tkceAllow_Client_Edit_Chart;
    Inc(i);
  end;
  if (P1.ceECoding_Dont_Send_Jobs <> P2.ceECoding_Dont_Send_Jobs) then begin
    P3.ceECoding_Dont_Send_Jobs := P1.ceECoding_Dont_Send_Jobs;
    ChangedFields[i] := tkceECoding_Dont_Send_Jobs;
    Inc(i);
  end;
  if (P1.ceCustom_Coding_Report_XML <> P2.ceCustom_Coding_Report_XML) then begin
    P3.ceCustom_Coding_Report_XML := P1.ceCustom_Coding_Report_XML;
    ChangedFields[i] := tkceCustom_Coding_Report_XML;
    Inc(i);
  end;
  if (P1.ceCustom_Coding_Report <> P2.ceCustom_Coding_Report) then begin
    P3.ceCustom_Coding_Report := P1.ceCustom_Coding_Report;
    ChangedFields[i] := tkceCustom_Coding_Report;
    Inc(i);
  end;
  if (P1.ceCoding_Report_Column_Line <> P2.ceCoding_Report_Column_Line) then begin
    P3.ceCoding_Report_Column_Line := P1.ceCoding_Report_Column_Line;
    ChangedFields[i] := tkceCoding_Report_Column_Line;
    Inc(i);
  end;
  if (P1.ceScheduled_Custom_CR_XML <> P2.ceScheduled_Custom_CR_XML) then begin
    P3.ceScheduled_Custom_CR_XML := P1.ceScheduled_Custom_CR_XML;
    ChangedFields[i] := tkceScheduled_Custom_CR_XML;
    Inc(i);
  end;
  if (P1.ceBudget_Include_Quantities <> P2.ceBudget_Include_Quantities) then begin
    P3.ceBudget_Include_Quantities := P1.ceBudget_Include_Quantities;
    ChangedFields[i] := tkceBudget_Include_Quantities;
    Inc(i);
  end;
  if (P1.ceScheduled_CR_Column_Line <> P2.ceScheduled_CR_Column_Line) then begin
    P3.ceScheduled_CR_Column_Line := P1.ceScheduled_CR_Column_Line;
    ChangedFields[i] := tkceScheduled_CR_Column_Line;
    Inc(i);
  end;
  if (P1.ceCustom_Ledger_Report <> P2.ceCustom_Ledger_Report) then begin
    P3.ceCustom_Ledger_Report := P1.ceCustom_Ledger_Report;
    ChangedFields[i] := tkceCustom_Ledger_Report;
    Inc(i);
  end;
  if (P1.ceCustom_Ledger_Report_XML <> P2.ceCustom_Ledger_Report_XML) then begin
    P3.ceCustom_Ledger_Report_XML := P1.ceCustom_Ledger_Report_XML;
    ChangedFields[i] := tkceCustom_Ledger_Report_XML;
    Inc(i);
  end;
  if (P1.ceLocal_Currency_Code <> P2.ceLocal_Currency_Code) then begin
    P3.ceLocal_Currency_Code := P1.ceLocal_Currency_Code;
    ChangedFields[i] := tkceLocal_Currency_Code;
    Inc(i);
  end;
  if (P1.ceBlock_Client_Edit_Mems <> P2.ceBlock_Client_Edit_Mems) then begin
    P3.ceBlock_Client_Edit_Mems := P1.ceBlock_Client_Edit_Mems;
    ChangedFields[i] := tkceBlock_Client_Edit_Mems;
    Inc(i);
  end;
  if (P1.ceSend_Custom_Documents <> P2.ceSend_Custom_Documents) then begin
    P3.ceSend_Custom_Documents := P1.ceSend_Custom_Documents;
    ChangedFields[i] := tkceSend_Custom_Documents;
    Inc(i);
  end;
  if Send_Custom_Documents_List_Changed(TSend_Custom_Documents_List_Array(P1.ceSend_Custom_Documents_List), 
                  TSend_Custom_Documents_List_Array(P2.ceSend_Custom_Documents_List), 
                  TSend_Custom_Documents_List_Array(P3.ceSend_Custom_Documents_List)) then begin
    ChangedFields[i] := tkceSend_Custom_Documents_List;
    Inc(i);
  end;
  if (P1.ceList_Payees_Detailed <> P2.ceList_Payees_Detailed) then begin
    P3.ceList_Payees_Detailed := P1.ceList_Payees_Detailed;
    ChangedFields[i] := tkceList_Payees_Detailed;
    Inc(i);
  end;
  if (P1.ceList_Payees_SortBy <> P2.ceList_Payees_SortBy) then begin
    P3.ceList_Payees_SortBy := P1.ceList_Payees_SortBy;
    ChangedFields[i] := tkceList_Payees_SortBy;
    Inc(i);
  end;
  if (P1.ceList_Payees_Rule_Line <> P2.ceList_Payees_Rule_Line) then begin
    P3.ceList_Payees_Rule_Line := P1.ceList_Payees_Rule_Line;
    ChangedFields[i] := tkceList_Payees_Rule_Line;
    Inc(i);
  end;
  if Custom_SFLedger_Titles_Changed(TCustom_SFLedger_Titles_Array(P1.ceCustom_SFLedger_Titles), 
                  TCustom_SFLedger_Titles_Array(P2.ceCustom_SFLedger_Titles), 
                  TCustom_SFLedger_Titles_Array(P3.ceCustom_SFLedger_Titles)) then begin
    ChangedFields[i] := tkceCustom_SFLedger_Titles;
    Inc(i);
  end;
  if (P1.ceSUI_Period_Start <> P2.ceSUI_Period_Start) then begin
    P3.ceSUI_Period_Start := P1.ceSUI_Period_Start;
    ChangedFields[i] := tkceSUI_Period_Start;
    Inc(i);
  end;
  if (P1.ceSUI_Period_End <> P2.ceSUI_Period_End) then begin
    P3.ceSUI_Period_End := P1.ceSUI_Period_End;
    ChangedFields[i] := tkceSUI_Period_End;
    Inc(i);
  end;
  if (P1.ceAudit_Record_ID <> P2.ceAudit_Record_ID) then begin
    P3.ceAudit_Record_ID := P1.ceAudit_Record_ID;
    ChangedFields[i] := tkceAudit_Record_ID;
    Inc(i);
  end;
  if SUI_Step_Done_Changed(TSUI_Step_Done_Array(P1.ceSUI_Step_Done), 
                  TSUI_Step_Done_Array(P2.ceSUI_Step_Done), 
                  TSUI_Step_Done_Array(P3.ceSUI_Step_Done)) then begin
    ChangedFields[i] := tkceSUI_Step_Done;
    Inc(i);
  end;
  if (P1.ceSend_Job_List <> P2.ceSend_Job_List) then begin
    P3.ceSend_Job_List := P1.ceSend_Job_List;
    ChangedFields[i] := tkceSend_Job_List;
    Inc(i);
  end;
  if (P1.ceSpare_String <> P2.ceSpare_String) then begin
    P3.ceSpare_String := P1.ceSpare_String;
    ChangedFields[i] := tkceSpare_String;
    Inc(i);
  end;
  if (P1.ceOnline_Scheduled_Reports <> P2.ceOnline_Scheduled_Reports) then begin
    P3.ceOnline_Scheduled_Reports := P1.ceOnline_Scheduled_Reports;
    ChangedFields[i] := tkceOnline_Scheduled_Reports;
    Inc(i);
  end;
  if (P1.ceFile_Transfer_Method <> P2.ceFile_Transfer_Method) then begin
    P3.ceFile_Transfer_Method := P1.ceFile_Transfer_Method;
    ChangedFields[i] := tkceFile_Transfer_Method;
    Inc(i);
  end;
  if (P1.ceOnlineBillingFrequency <> P2.ceOnlineBillingFrequency) then begin
    P3.ceOnlineBillingFrequency := P1.ceOnlineBillingFrequency;
    ChangedFields[i] := tkceOnlineBillingFrequency;
    Inc(i);
  end;
  if (P1.ceOnlineMaxOfflineDays <> P2.ceOnlineMaxOfflineDays) then begin
    P3.ceOnlineMaxOfflineDays := P1.ceOnlineMaxOfflineDays;
    ChangedFields[i] := tkceOnlineMaxOfflineDays;
    Inc(i);
  end;
  if (P1.ceOnlineStatus <> P2.ceOnlineStatus) then begin
    P3.ceOnlineStatus := P1.ceOnlineStatus;
    ChangedFields[i] := tkceOnlineStatus;
    Inc(i);
  end;
  if OnlineSubscription_Changed(TOnlineSubscription_Array(P1.ceOnlineSubscription), 
                  TOnlineSubscription_Array(P2.ceOnlineSubscription), 
                  TOnlineSubscription_Array(P3.ceOnlineSubscription)) then begin
    ChangedFields[i] := tkceOnlineSubscription;
    Inc(i);
  end;
  if (P1.ceOnlineUserEMail <> P2.ceOnlineUserEMail) then begin
    P3.ceOnlineUserEMail := P1.ceOnlineUserEMail;
    ChangedFields[i] := tkceOnlineUserEMail;
    Inc(i);
  end;
  if (P1.ceOnlineUserFullName <> P2.ceOnlineUserFullName) then begin
    P3.ceOnlineUserFullName := P1.ceOnlineUserFullName;
    ChangedFields[i] := tkceOnlineUserFullName;
    Inc(i);
  end;
  if (P1.ceOnlineValuesStored <> P2.ceOnlineValuesStored) then begin
    P3.ceOnlineValuesStored := P1.ceOnlineValuesStored;
    ChangedFields[i] := tkceOnlineValuesStored;
    Inc(i);
  end;
  if (P1.ceOnlineSubscriptionCount <> P2.ceOnlineSubscriptionCount) then begin
    P3.ceOnlineSubscriptionCount := P1.ceOnlineSubscriptionCount;
    ChangedFields[i] := tkceOnlineSubscriptionCount;
    Inc(i);
  end;
  if (P1.ceDeliverDataDirectToBLO <> P2.ceDeliverDataDirectToBLO) then begin
    P3.ceDeliverDataDirectToBLO := P1.ceDeliverDataDirectToBLO;
    ChangedFields[i] := tkceDeliverDataDirectToBLO;
    Inc(i);
  end;
  if (P1.ceBLOSecureCode <> P2.ceBLOSecureCode) then begin
    P3.ceBLOSecureCode := P1.ceBLOSecureCode;
    ChangedFields[i] := tkceBLOSecureCode;
    Inc(i);
  end;
  if (P1.ceInclude_Unused_Chart_Codes <> P2.ceInclude_Unused_Chart_Codes) then begin
    P3.ceInclude_Unused_Chart_Codes := P1.ceInclude_Unused_Chart_Codes;
    ChangedFields[i] := tkceInclude_Unused_Chart_Codes;
    Inc(i);
  end;
  if (P1.ceInclude_Non_Posting_Chart_Codes <> P2.ceInclude_Non_Posting_Chart_Codes) then begin
    P3.ceInclude_Non_Posting_Chart_Codes := P1.ceInclude_Non_Posting_Chart_Codes;
    ChangedFields[i] := tkceInclude_Non_Posting_Chart_Codes;
    Inc(i);
  end;
  if (P1.ceAdd_Prefix_For_Account_Code <> P2.ceAdd_Prefix_For_Account_Code) then begin
    P3.ceAdd_Prefix_For_Account_Code := P1.ceAdd_Prefix_For_Account_Code;
    ChangedFields[i] := tkceAdd_Prefix_For_Account_Code;
    Inc(i);
  end;
  if (P1.ceCashbook_GST_Map_File_Location <> P2.ceCashbook_GST_Map_File_Location) then begin
    P3.ceCashbook_GST_Map_File_Location := P1.ceCashbook_GST_Map_File_Location;
    ChangedFields[i] := tkceCashbook_GST_Map_File_Location;
    Inc(i);
  end;
  if (P1.ceCashbook_Export_File_Location <> P2.ceCashbook_Export_File_Location) then begin
    P3.ceCashbook_Export_File_Location := P1.ceCashbook_Export_File_Location;
    ChangedFields[i] := tkceCashbook_Export_File_Location;
    Inc(i);
  end;
  if (P1.ceBGLAccessToken <> P2.ceBGLAccessToken) then begin
    P3.ceBGLAccessToken := P1.ceBGLAccessToken;
    ChangedFields[i] := tkceBGLAccessToken;
    Inc(i);
  end;
  if (P1.ceBGLRefreshToken <> P2.ceBGLRefreshToken) then begin
    P3.ceBGLRefreshToken := P1.ceBGLRefreshToken;
    ChangedFields[i] := tkceBGLRefreshToken;
    Inc(i);
  end;
  if (P1.ceBGLTokenType <> P2.ceBGLTokenType) then begin
    P3.ceBGLTokenType := P1.ceBGLTokenType;
    ChangedFields[i] := tkceBGLTokenType;
    Inc(i);
  end;
  if (P1.ceBGLTokenExpiresAt <> P2.ceBGLTokenExpiresAt) then begin
    P3.ceBGLTokenExpiresAt := P1.ceBGLTokenExpiresAt;
    ChangedFields[i] := tkceBGLTokenExpiresAt;
    Inc(i);
  end;
  if (P1.ceBGLFundIDSelected <> P2.ceBGLFundIDSelected) then begin
    P3.ceBGLFundIDSelected := P1.ceBGLFundIDSelected;
    ChangedFields[i] := tkceBGLFundIDSelected;
    Inc(i);
  end;
  if (P1.ceBGLFundNameSelected <> P2.ceBGLFundNameSelected) then begin
    P3.ceBGLFundNameSelected := P1.ceBGLFundNameSelected;
    ChangedFields[i] := tkceBGLFundNameSelected;
    Inc(i);
  end;

  Result := (i > 0);
end;

{  -------------------------------------------------------------------  }

procedure Copy_ClientExtra_Rec(P1, P2: pClientExtra_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_ClientExtra_Rec(P1^, S);
    S.Position := 0;
    Read_ClientExtra_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

{  -------------------------------------------------------------------  }

END.
