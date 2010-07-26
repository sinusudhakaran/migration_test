UNIT LACRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses LADefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPrinter_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TForm_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TReport_Setting_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TWindows_Report_Setting_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TPrinter_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @s3Record_Type;
      RE    := @s3EOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TForm_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @s5Record_Type;
      RE    := @s5EOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TReport_Setting_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @s6Record_Type;
      RE    := @s6EOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TWindows_Report_Setting_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @s7Record_Type;
      RE    := @s7Is_Default;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

end.
