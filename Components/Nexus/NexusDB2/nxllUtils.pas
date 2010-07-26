{##############################################################################}
{# NexusDB: nxllUtils.pas 2.00                                                #}
{# NexusDB Memory Manager: nxllUtils.pas 2.03                                 #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: low level utility functions                                       #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllUtils;

interface

uses
  SysUtils,
  nxllFastFillChar,
  nxllTypes;

{== comparison functions ==}
function nxCmpB8(            a, b : TnxByte8)                         : TnxValueRelationship;
function nxCmpW16(           a, b : TnxWord16)                        : TnxValueRelationship;
function nxCmpW32(           a, b : TnxWord32)                        : TnxValueRelationship;
function nxCmpObj(           a, b : TObject)                          : TnxValueRelationship;
function nxCmpPtr(           a, b : Pointer)                          : TnxValueRelationship;
function nxCmpI8(            a, b : TnxInt8)                          : TnxValueRelationship;
function nxCmpI16(           a, b : TnxInt16)                         : TnxValueRelationship;
function nxCmpI32(           a, b : TnxInt32)                         : TnxValueRelationship;
function nxCmpI64(const      a, b : TnxInt64)                         : TnxValueRelationship;
function nxCmpBytes(         a, b : PnxByteArray; MaxLen : TnxWord32) : TnxValueRelationship;
function nxCmpDynBytes(      a, b : TnxDynByteArray)                  : TnxValueRelationship;
function nxCmpShStr(const    a, b : TnxShStr; MaxLen : TnxByte8)      : TnxValueRelationship;
function nxCmpShStrUC(const  a, b : TnxShStr; MaxLen : TnxByte8)      : TnxValueRelationship;
function nxCmpStr(const      a, b : string)                           : TnxValueRelationship;
function nxCmpStrUC(const    a, b : string)                           : TnxValueRelationship;
function nxCmpSingle(const   a, b : TnxSingle)                        : TnxValueRelationship;
function nxCmpDouble(const   a, b : TnxDouble)                        : TnxValueRelationship;
function nxCmpExtended(const a, b : TnxExtended)                      : TnxValueRelationship;

function nxSameDynBytes(     a, b : TnxDynByteArray)                  : Boolean;

{== minimum/maximum functions ==}
function nxMinW16(      a, b : TnxWord16) : TnxWord16;
function nxMaxW16(      a, b : TnxWord16) : TnxWord16;
function nxMinW32(      a, b : TnxWord32) : TnxWord32;
function nxMaxW32(      a, b : TnxWord32) : TnxWord32;
function nxMinI32(      a, b : TnxInt32)  : TnxInt32;
function nxMaxI32(      a, b : TnxInt32)  : TnxInt32;
function nxMinI64(const a, b : TnxInt64)  : TnxInt64;
function nxMaxI64(const a, b : TnxInt64)  : TnxInt64;

{== BitSet functions ==}
procedure nxClearAllBits(BitSet : PnxByteArray; BitCount : Integer);
procedure nxClearBit(BitSet : PnxByteArray; Bit : Integer); register;
function nxIsBitSet(BitSet : PnxByteArray; Bit : Integer) : Boolean;
procedure nxSetAllBits(BitSet : PnxByteArray; BitCount : Integer);
procedure nxSetBit(BitSet : PnxByteArray; Bit : Integer); register;

{== String functions ==}
function nxAnsiStrIComp(S1, S2: PChar): Integer;
function nxAnsiStrLIComp(S1, S2: PChar; MaxLen: Cardinal): Integer;

function  nxCommaizeChL(L : Integer; Ch : AnsiChar) : string;

procedure nxStrSplit(S          : string;
               const SplitChars : TnxCharSet;
                 var Left       : string;
                 var Right      : string);

{== Wide-String functions ==}
function nxCharToWideChar(Ch: AnsiChar): WideChar;
function nxNullStrLToWideStr(ZStr: PAnsiChar; WS: PWideChar; MaxLen: Integer): PWideChar;
function nxShStrLToWideStr(const S: TnxShStr; WS: PWideChar; MaxLen: Integer): PWideChar;
function nxWideCharToChar(WC: WideChar): AnsiChar;
function nxWideStrLToNullStr(WS: PWideChar; ZStr: PAnsiChar; MaxLen: Integer): PAnsiChar;
function nxWideStrLToShStr(WS: PWideChar; MaxLen: Integer): TnxShStr;
function nxWideStrLToWideStr(aSourceValue, aTargetValue: PWideChar; MaxLength: Integer): PWideChar;
procedure nxExpandAnsiToWide(aSource : PChar;
                             aTarget : PWideChar;
                             aCount  : Cardinal);
procedure nxSwapByteOrder(aWideString : PWideChar;
                          aCount      : Cardinal);

{== ByteArray functions ==}
procedure HexStringToByteArray(S : string; ArrayLength : Integer; ByteArray : Pointer);

{== Hash functions ==}
function nxCalcELFHash(const Buffer; BufSize : Integer) : TnxWord32;
function nxCalcStrELFHash(const S : string) : TnxWord32;
function nxCalcShStrELFHash(const S : TnxShStr) : TnxWord32;

{== file handlings functions ==}
function nxVerifyExtension(const Ext : string) : Boolean;
function nxVerifyFileName(const FileName : string) : Boolean;

function nxFindCmdLineSwitch(const aSwitch: string): Boolean;
function nxFindCmdLineParam(const aSwitch     : string;
                            const aChars      : TSysCharSet;
                                  aIgnoreCase : Boolean;
                              out aValue      : string)
                                              : Boolean; overload;
function nxFindCmdLineParam(const aSwitch : string;
                              out aValue  : string)
                                          : Boolean; overload;

{== date/time functions ==}
function nxMakeTimeStamp(const aDate : TnxDate; const aTime : TnxTime) : TTimeStamp;


resourcestring
  rsOSError = 'Win32 Error in %s.  Code: %d.'#10'%s';
  rsUnkOSError = 'A Win32 API function failed in %s.';
  rsOSErrorSourceUnknown = '[unknown]';
  rsInvalidHexChar = 'Invalid character encountered - use only hexadecimal digits 0..9, A..F!';

procedure nxRaiseLastOSError(aSilentException: Boolean; const aSource: String); overload;
procedure nxRaiseLastOSError(aSilentException: Boolean; aSource: PResStringRec); overload;
procedure nxRaiseLastOSError(const aSource: String); overload;
procedure nxRaiseLastOSError(aSource: PResStringRec); overload;
procedure nxRaiseLastOSError(aSilentException: Boolean); overload;
procedure nxRaiseLastOSError; overload;

function nxOSCheck(RetVal: Boolean): Boolean; overload;
function nxOSCheck(RetVal: Boolean; const aSource: PResStringRec): Boolean; overload;
function nxOSCheck(RetVal: Boolean; const aSource: String): Boolean; overload;

var
  nxDefaultUserCodePage : Integer;
  {$IFNDEF DCC60OrLater}
  nxRaiseLastOSErrorD5Workaround : procedure = nxRaiseLastOSError;
  {$ENDIF}

implementation

uses
  Windows;

{==comparison functions =======================================================}
function nxCmpB8(a, b : TnxByte8) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp al, dl
  ja @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpW16(a, b : TnxWord16) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp ax, dx
  ja @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpW32(a, b : TnxWord32) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp eax, edx
  ja @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpObj(a, b : TObject) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp eax, edx
  ja @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpPtr(a, b : Pointer) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp eax, edx
  ja @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpI8(a, b : TnxInt8) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp al, dl
  jg @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpI16(a, b : TnxInt16) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp ax, dx
  jg @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpI32(a, b : TnxInt32) : TnxValueRelationship;
asm
  xor ecx, ecx
  cmp eax, edx
  jg @@GT
  je @@EQ
@@LT:
  dec ecx
  dec ecx
@@GT:
  inc ecx
@@EQ:
  mov eax, ecx
end;
{------------------------------------------------------------------------------}
function nxCmpI64(const a, b : TnxInt64) : TnxValueRelationship;
//begin
//  if a = b then
//    Result := nxEqual
//  else if a < b then
//    Result := nxSmallerThan
//  else
//    Result := nxGreaterThan;
//end;
asm
  xor eax, eax
  mov edx, [ebp+20]
  cmp edx, [ebp+12]
  jg @@GT
  jl @@LT
  mov edx, [ebp+16]
  cmp edx, [ebp+8]
  ja @@GT
  je @@EQ
@@LT:
  dec eax
  dec eax
@@GT:
  inc eax
@@EQ:
end;
{------------------------------------------------------------------------------}
function nxCmpBytes(a, b : PnxByteArray; MaxLen : TnxWord32) : TnxValueRelationship;
asm
  push esi
  push edi
  mov esi, eax
  mov edi, edx
  xor eax, eax
  or ecx, ecx
  jz @@Equal
  repe cmpsb
  jb @@Exit
  je @@Equal
  inc eax
@@Equal:
  inc eax
@@Exit:
  dec eax
  pop edi
  pop esi
end;
{------------------------------------------------------------------------------}
function nxCmpDynBytes(a, b : TnxDynByteArray) : TnxValueRelationship;
var
  LenA : Integer;
  LenB : Integer;
begin
  LenA := Length(a);
  LenB := Length(b);

  if (LenA > 0) and (LenB > 0) then
    Result := nxCmpBytes(@a[0], @b[0], nxMinI32(LenA, LenB))
  else
    Result := nxEqual;

  if Result = nxEqual then
    Result := nxCmpI16(LenA, LenB);
end;
{------------------------------------------------------------------------------}
function nxCmpShStr(const a, b : TnxShStr; MaxLen : TnxByte8) : TnxValueRelationship;
asm
  push esi
  push edi
  mov esi, eax
  mov edi, edx
  movzx ecx, cl
  mov ch, cl
  xor eax, eax
  mov dl, [esi]
  inc esi
  mov dh, [edi]
  inc edi
  cmp cl, dl
  jbe @@Check2ndLength
  mov cl, dl
@@Check2ndLength:
  cmp cl, dh
  jbe @@CalcSigLengths
  mov cl, dh
@@CalcSigLengths:
  cmp dl, ch
  jbe @@Calc2ndSigLength
  mov dl, ch
@@Calc2ndSigLength:
  cmp dh, ch
  jbe @@CompareStrings
  mov dh, ch
@@CompareStrings:
  movzx ecx, cl
  or ecx, ecx
  jz @@CompareLengths
  repe cmpsb
  jb @@Exit
  ja @@GT
@@CompareLengths:
  cmp dl, dh
  je @@Equal
  jb @@Exit
@@GT:
  inc eax
@@Equal:
  inc eax
@@Exit:
  dec eax
  pop edi
  pop esi
end;
{------------------------------------------------------------------------------}
function nxCmpShStrUC(const a, b : TnxShStr; MaxLen : TnxByte8) : TnxValueRelationship;
asm
  push esi
  push edi
  push ebx
  mov esi, eax
  mov edi, edx
  movzx ecx, cl
  mov ch, cl
  xor eax, eax
  mov dl, [esi]
  inc esi
  mov dh, [edi]
  inc edi
  cmp cl, dl
  jbe @@Check2ndLength
  mov cl, dl
@@Check2ndLength:
  cmp cl, dh
  jbe @@CalcSigLengths
  mov cl, dh
@@CalcSigLengths:
  cmp dl, ch
  jbe @@Calc2ndSigLength
  mov dl, ch
@@Calc2ndSigLength:
  cmp dh, ch
  jbe @@CompareStrings
  mov dh, ch
@@CompareStrings:
  movzx ecx, cl
  or ecx, ecx
  jz @@CompareLengths
@@NextChars:
  mov bl, [esi]
  cmp bl, 'a'
  jb @@OtherChar
  cmp bl, 'z'
  ja @@OtherChar
  sub bl, 'a'-'A'
@@OtherChar:
  mov bh, [edi]
  cmp bh, 'a'
  jb @@CompareChars
  cmp bh, 'z'
  ja @@CompareChars
  sub bh, 'a'-'A'
@@CompareChars:
  cmp bl, bh
  jb @@Exit
  ja @@GT
  inc esi
  inc edi
  dec ecx
  jnz @@NextChars
@@CompareLengths:
  cmp dl, dh
  je @@Equal
  jb @@Exit
@@GT:
  inc eax
@@Equal:
  inc eax
@@Exit:
  dec eax
  pop ebx
  pop edi
  pop esi
end;
{------------------------------------------------------------------------------}
function nxCmpStr(const a, b : string): TnxValueRelationship;
begin   
  Result := Windows.CompareStringA
             (LOCALE_SYSTEM_DEFAULT,
              0,
              PAnsiChar(a), -1,
              PAnsiChar(b), -1)-2
end;
{------------------------------------------------------------------------------}
function nxCmpStrUC(const a, b : string): TnxValueRelationship;
begin
  Result := Windows.CompareStringA
             (LOCALE_SYSTEM_DEFAULT,
              NORM_IGNORECASE,
              PAnsiChar(a), -1,
              PAnsiChar(b), -1)-2
end;
{------------------------------------------------------------------------------}
function nxCmpSingle(const a, b : TnxSingle) : TnxValueRelationship;
begin
  if      a > b then Result := nxGreaterThan
  else if a < b then Result := nxSmallerThan
  else               Result := nxEqual;
end;
{------------------------------------------------------------------------------}
function nxCmpDouble(const a, b : TnxDouble) : TnxValueRelationship;
begin
  if      a > b then Result := nxGreaterThan
  else if a < b then Result := nxSmallerThan
  else               Result := nxEqual;
end;
{------------------------------------------------------------------------------}
function nxCmpExtended(const a, b : TnxExtended) : TnxValueRelationship;
begin
  if      a > b then Result := nxGreaterThan
  else if a < b then Result := nxSmallerThan
  else               Result := nxEqual;
end;
{==============================================================================}



{===nxSameDynBytes=============================================================}
function nxSameDynBytes(a, b : TnxDynByteArray): Boolean;
var
  LenA : Integer;
  LenB : Integer;
begin
  LenA := Length(a);
  LenB := Length(b);

  Result := LenA = LenB;
  if Result and (LenA > 0) then
    Result := nxCmpBytes(@a[0], @b[0], LenA) = nxEqual;
end;
{==============================================================================}



{== minimum/maximum functions =================================================}
function nxMinW16(a, b : TnxWord16) : TnxWord16;
asm
  cmp ax, dx
  jbe @@Exit
  mov ax, dx
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMaxW16(a, b : TnxWord16) : TnxWord16;
asm
  cmp ax, dx
  jae @@Exit
  mov ax, dx
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMinW32(a, b : TnxWord32) : TnxWord32;
asm
  cmp eax, edx
  jbe @@Exit
  mov eax, edx
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMaxW32(a, b : TnxWord32) : TnxWord32;
asm
  cmp eax, edx
  jae @@Exit
  mov eax, edx
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMinI32(a, b : TnxInt32) : TnxInt32;
asm
  cmp eax, edx
  jle @@Exit
  mov eax, edx
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMaxI32(a, b : TnxInt32) : TnxInt32;
asm
  cmp eax, edx
  jge @@Exit
  mov eax, edx
@@Exit:
end;
{------------------------------------------------------------------------------}
{$D+}
function nxMinI64(const a, b : TnxInt64) : TnxInt64;
asm
  mov edx, [ebp+12]
  cmp edx, [ebp+20]
  jg  @@AIsSmaller
  mov eax, [ebp+8]
  jl  @@Exit
  cmp eax, [ebp+16]
  jbe @@Exit
@@AIsSmaller:
  mov eax, [ebp+16]
  mov edx, [ebp+20]
@@Exit:
end;
{------------------------------------------------------------------------------}
function nxMaxI64(const a, b : TnxInt64) : TnxInt64;
asm
  mov edx, [ebp+12]
  cmp edx, [ebp+20]
  jl  @@AIsGreater
  mov eax, [ebp+8]
  jg  @@Exit
  cmp eax, [ebp+16]
  jae @@Exit
@@AIsGreater:
  mov eax, [ebp+16]
  mov edx, [ebp+20]
@@Exit:
end;
{==============================================================================}



{== BitSet functions ==========================================================}
procedure nxClearAllBits(BitSet : PnxByteArray; BitCount : Integer);
asm
  add edx, 7
  shr edx, 3
  xor cl, cl
  jmp [nxFillChar]
end;
{------------------------------------------------------------------------------}
procedure nxClearBit(BitSet : PnxByteArray; Bit : Integer);
asm
  btr [eax], edx
end;
{------------------------------------------------------------------------------}
function nxIsBitSet(BitSet : PnxByteArray; Bit : Integer) : Boolean;
asm
  mov ecx, eax
  xor eax, eax
  bt  [ecx], edx
  adc eax, eax
end;
{------------------------------------------------------------------------------}
procedure nxSetAllBits(BitSet : PnxByteArray; BitCount : Integer);
asm
  add edx, 7
  shr edx, 3
  mov cl, $ff
  jmp [nxFillChar]
end;
{------------------------------------------------------------------------------}
procedure nxSetBit(BitSet : PnxByteArray; Bit : Integer);
asm
  bts [eax], edx
end;
{==============================================================================}



{== String functions ==========================================================}
function nxAnsiStrIComp(S1, S2: PChar): Integer;
begin
  {$IFDEF SafeAnsiCompare}
  Result := AnsiStrIComp(AnsiStrLower(S1), AnsiStrLower(S2));
  {$ELSE}
  Result := AnsiStrIComp(S1, S2);
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
function nxAnsiStrLIComp(S1, S2: PChar; MaxLen: Cardinal): Integer;
begin
  {$IFDEF SafeAnsiCompare}
  Result := AnsiStrLIComp(AnsiStrLower(S1), AnsiStrLower(S2), MaxLen);
  {$ELSE}
  Result := AnsiStrLIComp(S1, S2, MaxLen);
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
function nxCommaizeChL(L : Integer; Ch : AnsiChar) : string;
  {-Convert a long Integer to a string with Ch in comma positions}
var
  Temp : string;
  NumCommas, I, Len : Cardinal;
  Neg : Boolean;
begin
  SetLength(Temp, 1);
  Temp[1] := Ch;
  if L < 0 then begin
    Neg := True;
    L := Abs(L);
  end else
    Neg := False;
  Result := IntToStr(L);
  Len := Length(Result);
  NumCommas := (Pred(Len)) div 3;
  for I := 1 to NumCommas do
    System.Insert(Temp, Result, Succ(Len-(I * 3)));
  if Neg then
    System.Insert('-', Result, 1);
end;
{------------------------------------------------------------------------------}
procedure nxStrSplit(S          : string;
               const SplitChars : TnxCharSet;
                 var Left       : string;
                 var Right      : string);
var
  I: Integer;
begin
  Left := S;
  Right := '';
  for I := 1 to Length(S) do begin
    if s[i] in SplitChars then begin  
      Left := Copy(S, 1, I - 1);
      Right := Copy(S, I + 1, High(Integer));
      Break;
    end;
  end;
end;
{==============================================================================}



{== Wide-String functions =====================================================}
function nxCharToWideChar(Ch: AnsiChar): WideChar;
begin
  Result := WideChar(Ord(Ch));
end;
{------------------------------------------------------------------------------}
function nxNullStrLToWideStr(ZStr: PAnsiChar; WS: PWideChar; MaxLen: Integer): PWideChar;
begin
  WS[MultiByteToWideChar(0, 0, ZStr, MaxLen, WS, MaxLen)] := #0;
  Result := WS;
end;
{------------------------------------------------------------------------------}
function nxShStrLToWideStr(const S: TnxShStr; WS: PWideChar; MaxLen: Integer): PWideChar;
begin
  WS[MultiByteToWideChar(0, 0, @S[1], MaxLen, WS, MaxLen + 1)] := #0;
  Result := WS;
end;
{------------------------------------------------------------------------------}
function nxWideCharToChar(WC: WideChar): AnsiChar;
begin
  if WC >= #256 then WC := #0;
  Result := AnsiChar(Ord(WC));
end;
{------------------------------------------------------------------------------}
function nxWideStrLToNullStr(WS: PWideChar; ZStr: PAnsiChar; MaxLen: Integer): PAnsiChar;
begin
  ZStr[WideCharToMultiByte(0, 0, WS, MaxLen, ZStr, MaxLen, nil, nil)] := #0;
  Result := ZStr;
end;
{------------------------------------------------------------------------------}
function nxWideStrLToShStr(WS: PWideChar; MaxLen: Integer): TnxShStr;
begin
  Result := WideCharLenToString(WS, MaxLen);
end;
{------------------------------------------------------------------------------}
function nxWideStrLToWideStr(aSourceValue, aTargetValue: PWideChar; MaxLength: Integer): PWideChar;
begin
  { Assumption: MaxLength is really # units multiplied by 2, which is how
    a Wide String's length is stored in the table's data dictionary. }
  Move(aSourceValue^, aTargetValue^, MaxLength);
  aTargetValue[MaxLength div 2] := #0;
  Result := aTargetValue;
end;
{------------------------------------------------------------------------------}
procedure nxExpandAnsiToWide(aSource : PChar;
                             aTarget : PWideChar;
                             aCount  : Cardinal);
asm
  JECXZ   @@Exit
  PUSH    ESI
  MOV     ESI, EAX
  XOR     EAX, EAX
@@Loop:
  MOV     AL, [ESI]
  INC     ESI
  MOV     [EDX], AX
  ADD     EDX, 2
  LOOP    @@Loop
  POP     ESI
@@Exit:
end;
{------------------------------------------------------------------------------}
procedure nxSwapByteOrder(aWideString : PWideChar;
                          aCount      : Cardinal);
asm
  MOV   ECX, EDX
  JECXZ @@Exit
@@Loop:
  MOV   DX, [EAX];
  XCHG  DL, DH
  MOV   [EAX], DX;
  ADD   EAX, 2
  LOOP  @@Loop
@@Exit:
end;
{==============================================================================}



{== ByteArray functions ============================================================}
procedure HexStringToByteArray(S : string; ArrayLength : Integer; ByteArray : Pointer);
var
  idx : Integer;
  BArr : PnxByteArray absolute ByteArray;
begin
  for idx := 0 to ArrayLength-1 do begin
    if Odd(Length(S)) then
      S := S + '0';
    if Length(S)>1 then begin
      try
        BArr[idx] := StrToInt('$'+Copy(S, 1, 2));
      except
        on EConvertError do begin
          raise EConvertError.Create(rsInvalidHexChar);
        end;
      end;
      Delete(S, 1, 2);
    end
    else
      BArr[idx] := 0;
  end;
end;
{==============================================================================}

{== Hash functions ============================================================}
{$Q-}
function nxCalcELFHash(const Buffer; BufSize : Integer) : TnxWord32;
var
  BufAsBytes : TnxByteArray absolute Buffer;
  G : TnxWord32;
  i : Integer;
begin
  Result := 0;
  for i := 0 to pred(BufSize) do begin
    Result := (Result shl 4) + BufAsBytes[i];
    G := Result and $F0000000;
    if (G <> 0) then
      Result := Result xor (G shr 24);
    Result := Result and (not G);
  end;
end;
{$Q+}
{------------------------------------------------------------------------------}
function nxCalcStrELFHash(const S : string) : TnxWord32;
begin
  if Length(s) > 0 then
    Result := nxCalcELFHash(S[1], length(S))
  else
    Result := 0;
end;
{------------------------------------------------------------------------------}
function nxCalcShStrELFHash(const S : TnxShStr) : TnxWord32;
begin
  Result := nxCalcELFHash(S[1], length(S));
end;
{==============================================================================}

{== file handlings functions ==================================================}
function ValidFileNameHelper(const S : string) : Boolean;
const
  UnacceptableChars : set of AnsiChar =
    ['"', '*', '.', '/', ':', '<', '>', '?', '\', '|'];
var
  i    : Integer;
  LenS : Integer;
begin
  Result := false;
  LenS := Length(S);
  if 0 < LenS then begin
    for i := 1 to LenS do
      if (S[i] in UnacceptableChars) then
        Exit;
    Result := true;
  end;
end;
{------------------------------------------------------------------------------}
function nxVerifyExtension(const Ext : string) : Boolean;
begin
  Result := ValidFileNameHelper(Ext);
end;
{------------------------------------------------------------------------------}
function nxVerifyFileName(const FileName : string) : Boolean;
begin
  Result := ValidFileNameHelper(FileName);
end;
{==============================================================================}



{==============================================================================}
function nxFindCmdLineSwitch(const aSwitch: string): Boolean;
begin
  Result := FindCmdLineSwitch(aSwitch, ['-', '/'], True);
end;
{------------------------------------------------------------------------------}
function nxFindCmdLineParam(const aSwitch     : string;
                            const aChars      : TSysCharSet;
                                  aIgnoreCase : Boolean;
                              out aValue      : string)
                                              : Boolean;
var
  i : Integer;
  s : string;
begin
  Result := False;
  aValue := '';
  for i := 1 to ParamCount do begin
    s := ParamStr(i);
    if (aChars = []) or (s[1] in aChars) then
      if aIgnoreCase then begin
        if AnsiCompareText(Copy(s, 2, Length(aSwitch)), aSwitch) = 0 then begin
          if s[Length(aSwitch) + 2] = ':' then begin
            aValue := Copy(s, Length(aSwitch) + 3, MaxInt);
            Result := True;
          end;
          Exit;
        end;
      end else
        if AnsiCompareStr(Copy(s, 2, Length(aSwitch)), aSwitch) = 0 then begin
          if s[Length(aSwitch) + 2] = ':' then begin
            aValue := Copy(s, Length(aSwitch) + 3, MaxInt);
            Result := True;
          end;
          Exit;
        end;
  end;
end;
{------------------------------------------------------------------------------}
function nxFindCmdLineParam(const aSwitch : string;
                              out aValue  : string)
                                          : Boolean;
begin
  Result := nxFindCmdLineParam(aSwitch, ['-', '/'], True, aValue);
end;
{==============================================================================}


{== date/time functions =======================================================}
function nxMakeTimeStamp(const aDate : TnxDate; const aTime : TnxTime) : TTimeStamp;
begin
  Result.Date := aDate;
  Result.Time := aTime;
end;
{==============================================================================}



{==============================================================================}
{$IFNDEF DCC6OrLater}
type
  EOSError = EWin32Error;
{$ENDIF}

procedure nxRaiseLastOSError(aSilentException: Boolean; const aSource: String); overload;
var
  LastError: Integer;
  Error: EOSError;
begin
  if aSilentException then begin
    if GetLastError <> 0 then
      Abort;
  end else
  begin
    LastError := GetLastError;
    if LastError <> 0 then
      Error := EOSError.CreateResFmt(@rsOSError, [aSource, LastError,
        SysErrorMessage(LastError)])
    else
      Error := EOSError.CreateRes(@rsUnkOSError);
    Error.ErrorCode := LastError;
    raise Error;
  end;
end;
{==============================================================================}
procedure nxRaiseLastOSError(const aSource: String); overload;
begin
  nxRaiseLastOSError(false, aSource);
end;
{==============================================================================}
procedure nxRaiseLastOSError(aSource: PResStringRec); overload;
begin
  nxRaiseLastOSError(false, LoadResString(aSource));
end;
{==============================================================================}
procedure nxRaiseLastOSError(aSilentException: Boolean; aSource: PResStringRec); overload;
begin
  nxRaiseLastOSError(aSilentException, LoadResString(aSource));
end;
{==============================================================================}
procedure nxRaiseLastOSError; overload;
begin
  nxRaiseLastOSError(false, rsOSErrorSourceUnknown);
end;
{==============================================================================}
procedure nxRaiseLastOSError(aSilentException: Boolean); overload;
begin
  nxRaiseLastOSError(aSilentException, rsOSErrorSourceUnknown);
end;
{==============================================================================}
function nxOSCheck(RetVal: Boolean): Boolean;
begin
  Result := nxOSCheck(RetVal, @rsOSErrorSourceUnknown);
end;
{==============================================================================}
function nxOSCheck(RetVal: Boolean; const aSource: PResStringRec): Boolean;
begin
  Result := RetVal;
  if not Result then
    nxOSCheck(RetVal, LoadResString(aSource));
end;
{==============================================================================}
function nxOSCheck(RetVal: Boolean; const aSource: String): Boolean;
begin
  if not RetVal then
    nxRaiseLastOSError(aSource);
  Result := RetVal;
end;
{==============================================================================}



{==============================================================================}
procedure InitDefaultUserCodePage;

  function LCIDToCodePage(ALcid: LongWord): Integer;
  const
    CP_ACP = 0;                                // system default code page
    LOCALE_IDEFAULTANSICODEPAGE = $00001004;   // default ansi code page
  var
    ResultCode: Integer;
    Buffer: array [0..6] of Char;
  begin
    GetLocaleInfo(ALcid, LOCALE_IDEFAULTANSICODEPAGE, Buffer, SizeOf(Buffer));
    Val(Buffer, Result, ResultCode);
    if ResultCode <> 0 then
      Result := CP_ACP;
  end;

begin
  // High bit is set for Win95/98/ME
  if GetVersion and $80000000 <> $80000000 then
  begin
    if Lo(GetVersion) > 4 then
      nxDefaultUserCodePage := 3  // Use CP_THREAD_ACP with Win2K/XP
    else
      // Use thread's current locale with NT4
      nxDefaultUserCodePage := LCIDToCodePage(GetThreadLocale);
  end
  else
    // Convert thread's current locale with Win95/98/ME
    nxDefaultUserCodePage := LCIDToCodePage(GetThreadLocale);
end;
{==============================================================================}

initialization
  InitDefaultUserCodePage;
end.


