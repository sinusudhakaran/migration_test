UNIT SYCRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses SYDefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPractice_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TSystem_Disk_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TUser_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TSystem_Bank_Account_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TClient_File_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TFile_Access_Mapping_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TClient_Account_Map_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TGroup_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TClient_Type_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TAudit_Trail_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TProvisional_Entries_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TSystem_Memorisation_List_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPractice_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @fdRecord_Type;
      RE    := @fdEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( fdSched_Rep_Cover_Page_Name );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Cover_Page_Name )^, Len );
      Len := Length( fdSched_Rep_Cover_Page_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Cover_Page_Message )^, Len );
      Len := Length( fdSched_Rep_Email_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Email_Message )^, Len );
      Len := Length( fdBulk_Export_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdBulk_Export_Code )^, Len );
      Len := Length( fdSave_Tax_Files_To );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSave_Tax_Files_To )^, Len );
      Len := Length( fdPractice_Web_Site );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdPractice_Web_Site )^, Len );
      Len := Length( fdPractice_Logo_Filename );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdPractice_Logo_Filename )^, Len );
      Len := Length( fdSched_Rep_Print_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Print_Custom_Doc_GUID )^, Len );
      Len := Length( fdSched_Rep_Fax_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Fax_Custom_Doc_GUID )^, Len );
      Len := Length( fdSpare_Text_3 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_3 )^, Len );
      Len := Length( fdSched_Rep_Email_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Email_Custom_Doc_GUID )^, Len );
      Len := Length( fdSpare_Text_5 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_5 )^, Len );
      Len := Length( fdSched_Rep_Books_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Books_Custom_Doc_GUID )^, Len );
      Len := Length( fdSched_Rep_Notes_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Notes_Custom_Doc_GUID )^, Len );
      Len := Length( fdSpare_Text_8 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_8 )^, Len );
      Len := Length( fdSched_Rep_WebNotes_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_WebNotes_Custom_Doc_GUID )^, Len );
      Len := Length( fdSpare_Text_10 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_10 )^, Len );
      Len := Length( fdSpare_Text_11 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_11 )^, Len );
      Len := Length( fdSpare_Text_12 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_12 )^, Len );
      Len := Length( fdSpare_Text_13 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_13 )^, Len );
      Len := Length( fdSpare_Text_14 );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSpare_Text_14 )^, Len );
      Len := Length( fdSched_Rep_WebNotes_Subject );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_WebNotes_Subject )^, Len );
      Len := Length( fdSched_Rep_webNotes_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_webNotes_Message )^, Len );
      Len := Length( fdSched_Rep_Header_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Header_Message )^, Len );
      Len := Length( fdSched_Rep_BNotes_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_BNotes_Message )^, Len );
      Len := Length( fdSched_Rep_CheckOut_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_CheckOut_Message )^, Len );
      Len := Length( fdSched_Rep_Business_Products_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Business_Products_Message )^, Len );
      Len := Length( fdLast_Export_Charges_Saved_To );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdLast_Export_Charges_Saved_To )^, Len );
      Len := Length( fdManual_Account_XML );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdManual_Account_XML )^, Len );
      Len := Length( fdUpdate_Server_For_Offsites );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdUpdate_Server_For_Offsites )^, Len );
      Len := Length( fdExport_Charges_Remarks );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdExport_Charges_Remarks )^, Len );
      Len := Length( fdCoding_Font );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdCoding_Font )^, Len );
      Len := Length( fdSched_Rep_Online_Message );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Online_Message )^, Len );
      Len := Length( fdSched_Rep_Online_Custom_Doc_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( fdSched_Rep_Online_Custom_Doc_GUID )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TSystem_Disk_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
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

PROCEDURE UpdateCRC( CONST Rec : TUser_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @usRecord_Type;
      RE    := @usEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( usEULA_Version );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( usEULA_Version )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TSystem_Bank_Account_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @sbRecord_Type;
      RE    := @sbEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( sbFile_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( sbFile_Code )^, Len );
      Len := Length( sbClient_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( sbClient_ID )^, Len );
      Len := Length( sbMatter_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( sbMatter_ID )^, Len );
      Len := Length( sbAssignment_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( sbAssignment_ID )^, Len );
      Len := Length( sbDisbursement_ID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( sbDisbursement_ID )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClient_File_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @cfRecord_Type;
      RE    := @cfEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( cfBank_Accounts );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( cfBank_Accounts )^, Len );
      Len := Length( cfAccounting_System );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( cfAccounting_System )^, Len );
      Len := Length( cfClient_File_GUID );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( cfClient_File_GUID )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TFile_Access_Mapping_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @acRecord_Type;
      RE    := @acEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClient_Account_Map_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @amRecord_Type;
      RE    := @amEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TGroup_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @grRecord_Type;
      RE    := @grEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TClient_Type_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @ctRecord_Type;
      RE    := @ctEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TAudit_Trail_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @atRecord_Type;
      RE    := @atAudit_Record;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( atOther_Info );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( atOther_Info )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TProvisional_Entries_Log_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @peRecord_Type;
      RE    := @peEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TSystem_Memorisation_List_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @smRecord_Type;
      RE    := @smMemorisations;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

end.
