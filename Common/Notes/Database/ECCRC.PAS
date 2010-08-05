UNIT ECCRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses ECDefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TECoding_File_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TAccount_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Detail_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TPayee_Line_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TBank_Account_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TTransaction_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TDissection_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TJob_Heading_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TECoding_File_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @ecRecord_Type;
      RE    := @ecFilename;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( ecPractice_Logo );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ecPractice_Logo )^, Len );
      Len := Length( ecPractice_Web_Site );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ecPractice_Web_Site )^, Len );
      Len := Length( ecNotes );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ecNotes )^, Len );
      Len := Length( ecPractice_Code );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( ecPractice_Code )^, Len );
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
      RE    := @chEOR;
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
      RE    := @pyEOR;
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
      RE    := @pdEOR;
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
      RE    := @plEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
      Len := Length( plGL_Narration );
      If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( plGL_Narration )^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TBank_Account_Details_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @baRecord_Type;
      RE    := @baNumber;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
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

end.
