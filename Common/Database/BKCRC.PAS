UNIT BKCRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses BKDefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClient_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TAccount_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Line_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TBudget_Header_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TBudget_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TDisk_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TMemorisation_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TMemorisation_Line_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TBank_Account_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TTransaction_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TDissection_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TBalances_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TSubGroup_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TDivision_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TMemorised_Transaction_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TCustom_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TMacro_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TFuel_Sheet_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TMoreClient_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TJob_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TClientExtra_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClient_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @clRecord_Type;
      RE    := @clLast_Payee_Number;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( clSave_Tax_Files_To );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clSave_Tax_Files_To )^, Len );
      Len := Length( clPractice_Web_Site );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clPractice_Web_Site )^, Len );
      Len := Length( clPractice_Logo );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clPractice_Logo )^, Len );
      Len := Length( clWeb_Site_Login_URL );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clWeb_Site_Login_URL )^, Len );
      Len := Length( clScheduled_File_Attachments );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clScheduled_File_Attachments )^, Len );
      Len := Length( clScheduled_Client_Note_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clScheduled_Client_Note_Message )^, Len );
      Len := Length( clExclude_From_Scheduled_Reports );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clExclude_From_Scheduled_Reports )^, Len );
      Len := Length( clExternal_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clExternal_ID )^, Len );
      Len := Length( clAlternate_Extract_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clAlternate_Extract_ID )^, Len );
      Len := Length( clGroup_Name );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clGroup_Name )^, Len );
      Len := Length( clClient_Type_Name );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clClient_Type_Name )^, Len );
      Len := Length( clPractice_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clPractice_Code )^, Len );
      Len := Length( clFavourite_Report_XML );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( clFavourite_Report_XML )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TAccount_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @chRecord_Type;
      RE    := @chTemp_Quantity;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPayee_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @pyRecord_Type;
      RE    := @pyAmount;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPayee_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @pdRecord_Type;
      RE    := @pdAmount;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPayee_Line_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @plRecord_Type;
      RE    := @plTemp_Tag;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( plGL_Narration );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( plGL_Narration )^, Len );
      Len := Length( plSF_Trans_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( plSF_Trans_Code )^, Len );
      Len := Length( plSF_Ledger_Name );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( plSF_Ledger_Name )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TBudget_Header_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @buRecord_Type;
      RE    := @buEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TBudget_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @bdRecord_Type;
      RE    := @bdEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TDisk_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @dlRecord_Type;
      RE    := @dlEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TMemorisation_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @mdRecord_Type;
      RE    := @mdNext_Memorisation;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TMemorisation_Line_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @mlRecord_Type;
      RE    := @mlTemp_Tag;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( mlGL_Narration );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( mlGL_Narration )^, Len );
      Len := Length( mlSF_Trans_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( mlSF_Trans_Code )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TBank_Account_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @baRecord_Type;
      RE    := @baLast_Sequence_No;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( baSpare_String );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( baSpare_String )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TTransaction_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @txRecord_Type;
      RE    := @txBank_Seq;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( txNotes );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txNotes )^, Len );
      Len := Length( txECoding_Import_Notes );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txECoding_Import_Notes )^, Len );
      Len := Length( txGL_Narration );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txGL_Narration )^, Len );
      Len := Length( txStatement_Details );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txStatement_Details )^, Len );
      Len := Length( txExternal_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txExternal_GUID )^, Len );
      Len := Length( txDocument_Title );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txDocument_Title )^, Len );
      Len := Length( txBankLink_UID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txBankLink_UID )^, Len );
      Len := Length( txSpare_String );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txSpare_String )^, Len );
      Len := Length( txSF_Transaction_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( txSF_Transaction_Code )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TDissection_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @dsRecord_Type;
      RE    := @dsTransaction;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( dsNotes );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsNotes )^, Len );
      Len := Length( dsECoding_Import_Notes );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsECoding_Import_Notes )^, Len );
      Len := Length( dsGL_Narration );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsGL_Narration )^, Len );
      Len := Length( dsExternal_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsExternal_GUID )^, Len );
      Len := Length( dsDocument_Title );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsDocument_Title )^, Len );
      Len := Length( dsSF_Transaction_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( dsSF_Transaction_Code )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TBalances_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @blRecord_Type;
      RE    := @blFirst_Fuel_Sheet;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TSubGroup_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @shRecord_Type;
      RE    := @shEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TDivision_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @dhRecord_Type;
      RE    := @dhEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TMemorised_Transaction_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @mxRecord_Type;
      RE    := @mxNext;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TCustom_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @hdRecord_Type;
      RE    := @hdEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TMacro_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @maRecord_Type;
      RE    := @maEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TFuel_Sheet_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @fsRecord_Type;
      RE    := @fsNext;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( fsFuel_Type );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fsFuel_Type )^, Len );
      Len := Length( fsFuel_Use );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fsFuel_Use )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TMoreClient_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @mcRecord_Type;
      RE    := @mcEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TJob_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @jhRecord_Type;
      RE    := @jhEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClientExtra_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @ceRecord_Type;
      RE    := @ceEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( ceCustom_Coding_Report_XML );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ceCustom_Coding_Report_XML )^, Len );
      Len := Length( ceScheduled_Custom_CR_XML );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ceScheduled_Custom_CR_XML )^, Len );
      Len := Length( ceCustom_Ledger_Report_XML );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ceCustom_Ledger_Report_XML )^, Len );
      Len := Length( ceSpare_String );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ceSpare_String )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

end.
