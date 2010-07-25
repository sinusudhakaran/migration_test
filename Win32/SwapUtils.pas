unit SwapUtils;

// -----------------------------------------------------------------------------
interface
// -----------------------------------------------------------------------------

Procedure SwapIntegers( Var A, B : Integer );
Procedure SwapBytes( Var A, B : Byte );
Procedure SwapPointers( Var A, B : Pointer );

// -----------------------------------------------------------------------------
implementation
// -----------------------------------------------------------------------------

Procedure SwapIntegers( Var A, B : Integer );
Var
  Old_A : Integer;
Begin
  Old_A := A;
  A := B;
  B := Old_A;
end;

// -----------------------------------------------------------------------------

Procedure SwapBytes( Var A, B : Byte );
Var
  Old_A : Byte;
Begin
  Old_A := A;
  A := B;
  B := Old_A;
end;

// -----------------------------------------------------------------------------

Procedure SwapPointers( Var A, B : Pointer );
Var
  Old_A : Pointer;
Begin
  Old_A := A;
  A := B;
  B := Old_A;
end;

// -----------------------------------------------------------------------------

end.
