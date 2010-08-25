UNIT CSCRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses CSDefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TCoding_Stat_Fields_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TCoding_Statistics_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TCoding_Stat_Fields_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @sfRecord_Type;
      RE    := @sfEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TCoding_Statistics_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @csRecord_Type;
      RE    := @csEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

end.
