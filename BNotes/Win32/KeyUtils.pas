unit KeyUtils;
//------------------------------------------------------------------------------
{
   Title:       Key Utils

   Description: Utilities for creating key strings from different types of
                variable.

   Remarks:     Routines borrowed from btree filer NumKey32.pas

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

{$A-} {No alignment}
{$H-} {No long string support--all short string routines}
{$V-} {No var string checking}

interface

type
  String1  = String[1];
  String2  = String[2];
  String4  = String[4];
  String5  = String[5];
  String6  = String[6];
  String7  = String[7];
  String8  = String[8];
  String9  = String[9];
  String10 = String[10];

function ByteToKey(B : Byte) : String1;
  {-Convert a byte to a string}

function ExtToKey(E : Extended) : String10;
  {-Convert an extended to a string}

function Int32ToKey(L : LongInt) : String4;
  {-Convert a longint to a string}



implementation

{===Helper routines==================================================}
procedure ReverseBytes(var V; Size : Word); assembler;
  {-Reverse the ordering of bytes from V[1] to V[Size]. Size must be >= 2.}
  asm
    push ebx
    movzx edx, dx
    mov ecx, eax
    add ecx, edx
    dec ecx
    shr edx, 1
  @@Again:
    mov bl, [eax]
    xchg bl, [ecx]
    mov [eax], bl
    inc eax
    dec ecx
    dec edx
    jnz @@Again
    pop ebx
  end;
{--------}
procedure ToggleBits(var V; Size : Word); assembler;
  {-Toggle the bits from V[1] to V[Size]}
  asm
    movzx edx, dx
  @@Again:
    not byte ptr [eax]
    inc eax
    dec edx
    jnz @@Again
  end;
{--------}

function ByteToKey(B : Byte) : String1;
  {-Convert a byte to a string}
  begin
    Result[0] := #1;
    Result[1] := Char(B);
  end;
{--------}
function ExtToKey(E : Extended) : String10;
  {-Convert an extended to a string}
  var
    LResult : record
      case Byte of
        0 : (Len : Byte; EE : Extended);
        1 : (XXX, Exp : Byte);
        2 : (Str : String10);
    end absolute Result;
  begin
    LResult.EE := E;

    {move the exponent to the front and put mantissa in MSB->LSB order}
    ReverseBytes(LResult.EE, 10);

    {flip the sign bit}
    LResult.Exp := LResult.Exp xor $80;

    if LResult.Exp and $80 = 0 then begin
      ToggleBits(LResult.EE, 10);
      LResult.Exp := LResult.Exp and $7F;
    end;

    LResult.Len := 10;
  end;
{--------}
function Int32ToKey(L : LongInt) : String4;
  {-Convert a 32-bit integer to a string}
  var
    LRec : record
      L1 : Word;
      L2 : Word;
    end absolute L;
    LResult : record
      Len : Byte;
      W1, W2 : Word;
    end absolute Result;
  begin
    L := L xor longint($80000000);                             {!!.55}
    LResult.Len := 4;
    LResult.W1 := Swap(LRec.L2);
    LResult.W2 := Swap(LRec.L1);
  end;
{--------}


end.
