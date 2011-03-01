UNIT MCCRC;

// This code was generated automatically by running DBGen
// Do not change it - any changes you make will disappear
// when DBGen is run again.

// ------------------------------------------------------------------- 
Interface uses MCDefs, Windows;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TExchange_Rates_Header_Rec; VAR CRC : LongWord ); OVERLOAD;
PROCEDURE UpdateCRC( CONST Rec : TExchange_Rate_Rec; VAR CRC : LongWord ); OVERLOAD;

// ------------------------------------------------------------------- 
Implementation uses CRC32, MoneyDef;
// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TExchange_Rates_Header_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @ehRecord_Type;
      RE    := @ehEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

PROCEDURE UpdateCRC( CONST Rec : TExchange_Rate_Rec; VAR CRC : LongWord ); OVERLOAD;
Var
   Len    : Integer;
   RS, RE : Pointer;
Begin
   With Rec do begin
      RS    := @erRecord_Type;
      RE    := @erEOR;
      Len   := Integer( RE ) - Integer( RS );
      CRC32.UpdateCRC( CRC , RS^, Len );
   end;
end;

// ------------------------------------------------------------------- 

end.
