unit DiskUtils;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

{ Pack a ShortString into an Array of Char - Pad with spaces if necessary }
Procedure S2A( CONST S : ShortString; Var A; Len : Byte );

{ Unpack an Array of Char into a ShorString - Remove any Illegal characters and any Trailing Spaces }
Function A2S( Const A; Len : Byte ): ShortString;

// ----------------------------------------------------------------------------
implementation uses Math;
// ----------------------------------------------------------------------------

Procedure S2A( Const S : ShortString; Var A; Len : Byte );
Var
  SLen : Byte Absolute S;
Begin
  FillChar( A, Len, $20 ); (* Fill with spaces *)
  Move( S[1], A, Min( SLen, Len ) );
end;

// ----------------------------------------------------------------------------

Function A2S( Const A; Len : Byte ): ShortString;

Var
  i : Byte;
  RLen : Byte Absolute Result;
Begin
  RLen := Len; Move( A, Result[1],Len );
  For i := 1 to RLen do if ( Result[i] < ' ' ) or ( Result[i] > #$7F ) then Result[i]:=' ';
  While ( RLen > 0 ) and ( Result[ RLen ]=' ' ) do Dec( RLen );
end;

// ----------------------------------------------------------------------------

end.
