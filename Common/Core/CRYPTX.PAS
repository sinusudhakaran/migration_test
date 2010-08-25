UNIT CRYPTX;
//------------------------------------------------------------------------------
{
   Title:       Encrypt/Decrypt code

   Description:

   Author:

   Remarks:     Any changes to this unit should be mirrored in production
                and in the BankLink Client Software !!!

}
//------------------------------------------------------------------------------

INTERFACE

procedure Encrypt( Var Buffer ; Len : Integer );
procedure Decrypt( Var Buffer ; Len : Integer );

//******************************************************************************
IMPLEMENTATION

CONST                 {12345678901234567890}
   Key : String[20] = '-Wv6Z€V¢#UÒ¥”{ÃŒ';

VAR
   Cypher : Array[0..( Sizeof( Key ) -1 )] of Byte;

TYPE
   PByte = ^Byte;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Encrypt( Var Buffer ; Len : Integer );
var
  i,j : Integer;
  pCypherText : pByte;
begin
  Move( Key[1], Cypher, SizeOf( Cypher ) );
  pCypherText := @Buffer;
  j := 0;
  for i := 1 to Len do
  begin
    PCypherText^ := PCypherText^ xor Cypher[j];
    Inc( pCypherText );
    Inc( j );
    j := j mod ( Sizeof( Key ) -1 );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Decrypt( Var Buffer ; Len : Integer );
begin
   Encrypt(buffer,len);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
