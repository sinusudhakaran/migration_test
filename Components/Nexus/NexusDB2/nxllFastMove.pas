{##############################################################################}
{# NexusDB: nxllFastMove.pas 2.00                                             #}
{# NexusDB Memory Manager: nxllFastMove.pas 2.03                              #}
{##############################################################################}
{# NexusDB: CPU specific fast move operations from the FastCode project       #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllFastMove;
(*
FastMove by John O'Harrow (john@elmcrest.demon.co.uk)

Version: 1.20 - 30-MAY-2004
*)

interface

uses
  nxllFastCpuDetect;

type
  TnxMove = procedure(const Source; var Dest; Count : Integer);


type
  TCheckOSVersionInfo = record
    dwOSVersionInfoSize : LongWord;
    dwMajorVersion      : LongWord;
    dwMinorVersion      : LongWord;
    dwBuildNumber       : LongWord;
    dwPlatformId        : LongWord;
    szCSDVersion        : array[0..127] of AnsiChar;
  end;

function GetVersionEx(var lpVersionInformation: TCheckOSVersionInfo): LongBool; stdcall;


var
  nxMove    : TnxMove;

implementation


{--------------------------------------------------------------------------}
function GetVersionEx; external 'kernel32.dll' name 'GetVersionExA';
{--------------------------------------------------------------------------}
function OSIsWin95_or_NT4 : Boolean;
var
  OSVersionInfo: TCheckOSVersionInfo;
begin
  Result := False;
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
    with OSVersionInfo do
      Result := ((dwPlatformId = 1) and { win9x }
                 (dwMajorVersion = 4) and
                 (dwMinorVersion < 10)) or
                ((dwPlatformId = 2) and { winNT }
                 (dwMajorVersion = 4) and
                 (dwMinorVersion = 0));
end;
{--------------------------------------------------------------------------}


{--------------------------------------------------------------------------}
const
  SMALLMOVESIZE = 36;

{-------------------------------------------------------------------------}
procedure SmallForwardMove;
asm
  jmp     dword ptr [@@FwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@FwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Fwd01,@@Fwd02,@@Fwd03,@@Fwd04,@@Fwd05,@@Fwd06,@@Fwd07,@@Fwd08
  dd      @@Fwd09,@@Fwd10,@@Fwd11,@@Fwd12,@@Fwd13,@@Fwd14,@@Fwd15,@@Fwd16
  dd      @@Fwd17,@@Fwd18,@@Fwd19,@@Fwd20,@@Fwd21,@@Fwd22,@@Fwd23,@@Fwd24
  dd      @@Fwd25,@@Fwd26,@@Fwd27,@@Fwd28,@@Fwd29,@@Fwd30,@@Fwd31,@@Fwd32
  dd      @@Fwd33,@@Fwd34,@@Fwd35,@@Fwd36
@@Fwd36:
  mov     ecx,[eax-36]
  mov     [edx-36],ecx
@@Fwd32:
  mov     ecx,[eax-32]
  mov     [edx-32],ecx
@@Fwd28:
  mov     ecx,[eax-28]
  mov     [edx-28],ecx
@@Fwd24:
  mov     ecx,[eax-24]
  mov     [edx-24],ecx
@@Fwd20:
  mov     ecx,[eax-20]
  mov     [edx-20],ecx
@@Fwd16:
  mov     ecx,[eax-16]
  mov     [edx-16],ecx
@@Fwd12:
  mov     ecx,[eax-12]
  mov     [edx-12],ecx
@@Fwd08:
  mov     ecx,[eax-8]
  mov     [edx-8],ecx
@@Fwd04:
  mov     ecx,[eax-4]
  mov     [edx-4],ecx
  ret
@@Fwd35:
  mov     ecx,[eax-35]
  mov     [edx-35],ecx
@@Fwd31:
  mov     ecx,[eax-31]
  mov     [edx-31],ecx
@@Fwd27:
  mov     ecx,[eax-27]
  mov     [edx-27],ecx
@@Fwd23:
  mov     ecx,[eax-23]
  mov     [edx-23],ecx
@@Fwd19:
  mov     ecx,[eax-19]
  mov     [edx-19],ecx
@@Fwd15:
  mov     ecx,[eax-15]
  mov     [edx-15],ecx
@@Fwd11:
  mov     ecx,[eax-11]
  mov     [edx-11],ecx
@@Fwd07:
  mov     ecx,[eax-7]
  mov     [edx-7],ecx
@@Fwd03:
  mov     cx,[eax-3]
  mov     [edx-3],cx
  mov     cl,[eax-1]
  mov     [edx-1],cl
  ret
@@Fwd34:
  mov     ecx,[eax-34]
  mov     [edx-34],ecx
@@Fwd30:
  mov     ecx,[eax-30]
  mov     [edx-30],ecx
@@Fwd26:
  mov     ecx,[eax-26]
  mov     [edx-26],ecx
@@Fwd22:
  mov     ecx,[eax-22]
  mov     [edx-22],ecx
@@Fwd18:
  mov     ecx,[eax-18]
  mov     [edx-18],ecx
@@Fwd14:
  mov     ecx,[eax-14]
  mov     [edx-14],ecx
@@Fwd10:
  mov     ecx,[eax-10]
  mov     [edx-10],ecx
@@Fwd06:
  mov     ecx,[eax-6]
  mov     [edx-6],ecx
@@Fwd02:
  mov     cx,[eax-2]
  mov     [edx-2],cx
  ret
@@Fwd33:
  mov     ecx,[eax-33]
  mov     [edx-33],ecx
@@Fwd29:
  mov     ecx,[eax-29]
  mov     [edx-29],ecx
@@Fwd25:
  mov     ecx,[eax-25]
  mov     [edx-25],ecx
@@Fwd21:
  mov     ecx,[eax-21]                     
  mov     [edx-21],ecx
@@Fwd17:
  mov     ecx,[eax-17]
  mov     [edx-17],ecx
@@Fwd13:
  mov     ecx,[eax-13]
  mov     [edx-13],ecx
@@Fwd09:
  mov     ecx,[eax-9]
  mov     [edx-9],ecx
@@Fwd05:
  mov     ecx,[eax-5]
  mov     [edx-5],ecx
@@Fwd01:
  mov     cl,[eax-1]
  mov     [edx-1],cl
@@Done:
  ret
end; {SmallForwardMove}

{-------------------------------------------------------------------------}
procedure SmallBackwardMove;
asm
  jmp     dword ptr [@@BwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@BwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Bwd01,@@Bwd02,@@Bwd03,@@Bwd04,@@Bwd05,@@Bwd06,@@Bwd07,@@Bwd08
  dd      @@Bwd09,@@Bwd10,@@Bwd11,@@Bwd12,@@Bwd13,@@Bwd14,@@Bwd15,@@Bwd16
  dd      @@Bwd17,@@Bwd18,@@Bwd19,@@Bwd20,@@Bwd21,@@Bwd22,@@Bwd23,@@Bwd24
  dd      @@Bwd25,@@Bwd26,@@Bwd27,@@Bwd28,@@Bwd29,@@Bwd30,@@Bwd31,@@Bwd32
  dd      @@Bwd33,@@Bwd34,@@Bwd35,@@Bwd36
@@Bwd36:
  mov     ecx,[eax+32]
  mov     [edx+32],ecx
@@Bwd32:
  mov     ecx,[eax+28]
  mov     [edx+28],ecx
@@Bwd28:
  mov     ecx,[eax+24]
  mov     [edx+24],ecx
@@Bwd24:
  mov     ecx,[eax+20]
  mov     [edx+20],ecx
@@Bwd20:
  mov     ecx,[eax+16]
  mov     [edx+16],ecx
@@Bwd16:
  mov     ecx,[eax+12]
  mov     [edx+12],ecx
@@Bwd12:
  mov     ecx,[eax+8]
  mov     [edx+8],ecx
@@Bwd08:
  mov     ecx,[eax+4]
  mov     [edx+4],ecx
@@Bwd04:
  mov     ecx,[eax]
  mov     [edx],ecx
  ret
@@Bwd35:
  mov     ecx,[eax+31]
  mov     [edx+31],ecx
@@Bwd31:
  mov     ecx,[eax+27]
  mov     [edx+27],ecx
@@Bwd27:
  mov     ecx,[eax+23]
  mov     [edx+23],ecx
@@Bwd23:
  mov     ecx,[eax+19]
  mov     [edx+19],ecx
@@Bwd19:
  mov     ecx,[eax+15]
  mov     [edx+15],ecx
@@Bwd15:
  mov     ecx,[eax+11]
  mov     [edx+11],ecx
@@Bwd11:
  mov     ecx,[eax+7]
  mov     [edx+7],ecx
@@Bwd07:
  mov     ecx,[eax+3]
  mov     [edx+3],ecx
@@Bwd03:
  mov     cx,[eax+1]
  mov     [edx+1],cx
  mov     cl,[eax]
  mov     [edx],cl
  ret
@@Bwd34:
  mov     ecx,[eax+30]
  mov     [edx+30],ecx
@@Bwd30:
  mov     ecx,[eax+26]
  mov     [edx+26],ecx
@@Bwd26:
  mov     ecx,[eax+22]
  mov     [edx+22],ecx
@@Bwd22:
  mov     ecx,[eax+18]
  mov     [edx+18],ecx
@@Bwd18:
  mov     ecx,[eax+14]
  mov     [edx+14],ecx
@@Bwd14:
  mov     ecx,[eax+10]
  mov     [edx+10],ecx
@@Bwd10:
  mov     ecx,[eax+6]
  mov     [edx+6],ecx
@@Bwd06:
  mov     ecx,[eax+2]
  mov     [edx+2],ecx
@@Bwd02:
  mov     cx,[eax]
  mov     [edx],cx
  ret
@@Bwd33:
  mov     ecx,[eax+29]
  mov     [edx+29],ecx
@@Bwd29:
  mov     ecx,[eax+25]
  mov     [edx+25],ecx
@@Bwd25:
  mov     ecx,[eax+21]
  mov     [edx+21],ecx
@@Bwd21:
  mov     ecx,[eax+17]
  mov     [edx+17],ecx
@@Bwd17:
  mov     ecx,[eax+13]
  mov     [edx+13],ecx
@@Bwd13:
  mov     ecx,[eax+9]
  mov     [edx+9],ecx
@@Bwd09:
  mov     ecx,[eax+5]
  mov     [edx+5],ecx
@@Bwd05:
  mov     ecx,[eax+1]
  mov     [edx+1],ecx
@@Bwd01:
  mov     cl,[eax]
  mov     [edx],cl
@@Done:
  ret
end; {SmallBackwardMove}

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure AlignedFwdMoveSSE(const Source; var Dest; Count: Integer);
const
  Prefetch = 512;
asm
  push    esi
  mov     esi,eax             {ESI = Source}
  mov     eax,ecx             {EAX = Count}
  and     eax,-128            {EAX = No of Bytes to Block Move}
  add     esi,eax
  add     edx,eax
  shr     eax,3               {EAX = No of QWORD's to Block Move}
  neg     eax
  cmp     eax, -(32*1024)     {Count > 256K}
  jl      @Large
@Small: {<256K}
  test    esi,15              {Check if Both Source/Dest Aligned}
  jnz     @SmallUnaligned
@SmallAligned:                {Both Source and Dest 16-Byte Aligned}
@SmallAlignedLoop:
  {$IFDEF DCC6OrLater}
  movaps  xmm0,[esi+8*eax]
  movaps  xmm1,[esi+8*eax+16]
  movaps  xmm2,[esi+8*eax+32]
  movaps  xmm3,[esi+8*eax+48]
  movaps  [edx+8*eax],xmm0
  movaps  [edx+8*eax+16],xmm1
  movaps  [edx+8*eax+32],xmm2
  movaps  [edx+8*eax+48],xmm3
  movaps  xmm4,[esi+8*eax+64]
  movaps  xmm5,[esi+8*eax+80]
  movaps  xmm6,[esi+8*eax+96]
  movaps  xmm7,[esi+8*eax+112]
  movaps  [edx+8*eax+64],xmm4
  movaps  [edx+8*eax+80],xmm5
  movaps  [edx+8*eax+96],xmm6
  movaps  [edx+8*eax+112],xmm7
  {$ELSE}
  db      $0F, $28, $04, $C6
  db      $0F, $28, $4C, $C6, $10
  db      $0F, $28, $54, $C6, $20
  db      $0F, $28, $5C, $C6, $30
  db      $0F, $29, $04, $C2
  db      $0F, $29, $4C, $C2, $10
  db      $0F, $29, $54, $C2, $20
  db      $0F, $29, $5C, $C2, $30
  db      $0F, $28, $64, $C6, $40
  db      $0F, $28, $6C, $C6, $50
  db      $0F, $28, $74, $C6, $60
  db      $0F, $28, $7C, $C6, $70
  db      $0F, $29, $64, $C2, $40
  db      $0F, $29, $6C, $C2, $50
  db      $0F, $29, $74, $C2, $60
  db      $0F, $29, $7C, $C2, $70
  {$ENDIF}
  add     eax,16
  js      @SmallAlignedLoop
  jmp     @Remainder
@SmallUnaligned:              {Source Not 16-Byte Aligned}
@SmallUnalignedLoop:
  {$IFDEF DCC6OrLater}
  movups  xmm0,[esi+8*eax]
  movups  xmm1,[esi+8*eax+16]
  movups  xmm2,[esi+8*eax+32]
  movups  xmm3,[esi+8*eax+48]
  movaps  [edx+8*eax],xmm0
  movaps  [edx+8*eax+16],xmm1
  movaps  [edx+8*eax+32],xmm2
  movaps  [edx+8*eax+48],xmm3
  movups  xmm4,[esi+8*eax+64]
  movups  xmm5,[esi+8*eax+80]
  movups  xmm6,[esi+8*eax+96]
  movups  xmm7,[esi+8*eax+112]
  movaps  [edx+8*eax+64],xmm4
  movaps  [edx+8*eax+80],xmm5
  movaps  [edx+8*eax+96],xmm6
  movaps  [edx+8*eax+112],xmm7
  {$ELSE}
  db      $0F, $10, $04, $C6
  db      $0F, $10, $4C, $C6, $10
  db      $0F, $10, $54, $C6, $20
  db      $0F, $10, $5C, $C6, $30
  db      $0F, $29, $04, $C2
  db      $0F, $29, $4C, $C2, $10
  db      $0F, $29, $54, $C2, $20
  db      $0F, $29, $5C, $C2, $30
  db      $0F, $10, $64, $C6, $40
  db      $0F, $10, $6C, $C6, $50
  db      $0F, $10, $74, $C6, $60
  db      $0F, $10, $7C, $C6, $70
  db      $0F, $29, $64, $C2, $40
  db      $0F, $29, $6C, $C2, $50
  db      $0F, $29, $74, $C2, $60
  db      $0F, $29, $7C, $C2, $70
  {$ENDIF}
  add     eax,16
  js      @SmallUnalignedLoop
  jmp     @Remainder
@Large: {>256K}
  test    esi,15              {Check if Both Source/Dest Aligned}
  jnz     @LargeUnaligned
@LargeAligned:                {Both Source and Dest 16-Byte Aligned}
@LargeAlignedLoop:
  {$IFDEF DCC6OrLater}
  prefetchnta  [esi+8*eax+Prefetch]
  prefetchnta  [esi+8*eax+Prefetch+64]
  movaps  xmm0,[esi+8*eax]
  movaps  xmm1,[esi+8*eax+16]
  movaps  xmm2,[esi+8*eax+32]
  movaps  xmm3,[esi+8*eax+48]
  movntps [edx+8*eax],xmm0
  movntps [edx+8*eax+16],xmm1
  movntps [edx+8*eax+32],xmm2
  movntps [edx+8*eax+48],xmm3
  movaps  xmm4,[esi+8*eax+64]
  movaps  xmm5,[esi+8*eax+80]
  movaps  xmm6,[esi+8*eax+96]
  movaps  xmm7,[esi+8*eax+112]
  movntps [edx+8*eax+64],xmm4
  movntps [edx+8*eax+80],xmm5
  movntps [edx+8*eax+96],xmm6
  movntps [edx+8*eax+112],xmm7
  {$ELSE}
  db      $0F, $18, $84, $C6, $00, $02, $00, $00
  db      $0F, $18, $84, $C6, $40, $02, $00, $00
  db      $0F, $28, $04, $C6
  db      $0F, $28, $4C, $C6, $10
  db      $0F, $28, $54, $C6, $20
  db      $0F, $28, $5C, $C6, $30
  db      $0F, $2B, $04, $C2
  db      $0F, $2B, $4C, $C2, $10
  db      $0F, $2B, $54, $C2, $20
  db      $0F, $2B, $5C, $C2, $30
  db      $0F, $28, $64, $C6, $40
  db      $0F, $28, $6C, $C6, $50
  db      $0F, $28, $74, $C6, $60
  db      $0F, $28, $7C, $C6, $70
  db      $0F, $2B, $64, $C2, $40
  db      $0F, $2B, $6C, $C2, $50
  db      $0F, $2B, $74, $C2, $60
  db      $0F, $2B, $7C, $C2, $70
  {$ENDIF}
  add     eax,16
  js      @LargeAlignedLoop
  {$IFDEF DCC6OrLater}
  sfence
  {$ELSE}
  db      $0F, $AE, $F8
  {$ENDIF}
  jmp     @Remainder
@LargeUnaligned:              {Source Not 16-Byte Aligned}
@LargeUnalignedLoop:
  {$IFDEF DCC6OrLater}
  prefetchnta  [esi+8*eax+Prefetch]
  prefetchnta  [esi+8*eax+Prefetch+64]
  movups  xmm0,[esi+8*eax]
  movups  xmm1,[esi+8*eax+16]
  movups  xmm2,[esi+8*eax+32]
  movups  xmm3,[esi+8*eax+48]
  movntps [edx+8*eax],xmm0
  movntps [edx+8*eax+16],xmm1
  movntps [edx+8*eax+32],xmm2
  movntps [edx+8*eax+48],xmm3
  movups  xmm4,[esi+8*eax+64]
  movups  xmm5,[esi+8*eax+80]
  movups  xmm6,[esi+8*eax+96]
  movups  xmm7,[esi+8*eax+112]
  movntps [edx+8*eax+64],xmm4
  movntps [edx+8*eax+80],xmm5
  movntps [edx+8*eax+96],xmm6
  movntps [edx+8*eax+112],xmm7
  {$ELSE}
  db      $0F, $18, $84, $C6, $00, $02, $00, $00
  db      $0F, $18, $84, $C6, $40, $02, $00, $00
  db      $0F, $10, $04, $C6
  db      $0F, $10, $4C, $C6, $10
  db      $0F, $10, $54, $C6, $20
  db      $0F, $10, $5C, $C6, $30
  db      $0F, $2B, $04, $C2
  db      $0F, $2B, $4C, $C2, $10
  db      $0F, $2B, $54, $C2, $20
  db      $0F, $2B, $5C, $C2, $30
  db      $0F, $10, $64, $C6, $40
  db      $0F, $10, $6C, $C6, $50
  db      $0F, $10, $74, $C6, $60
  db      $0F, $10, $7C, $C6, $70
  db      $0F, $2B, $64, $C2, $40
  db      $0F, $2B, $6C, $C2, $50
  db      $0F, $2B, $74, $C2, $60
  db      $0F, $2B, $7C, $C2, $70
  {$ENDIF}
  add     eax,16
  js      @LargeUnalignedLoop
  {$IFDEF DCC6OrLater}
  sfence
  {$ELSE}
  db      $0F, $AE, $F8
  {$ENDIF}
@Remainder:
  and     ecx,$7F {ECX = Remainder (0..112 - Multiple of 16)}
  jz      @Done
  add     esi,ecx
  add     edx,ecx
  neg     ecx
@RemainderLoop:
  {$IFDEF DCC6OrLater}
  movups  xmm0,[esi+ecx]
  movaps  [edx+ecx],xmm0
  {$ELSE}
  db      $0F, $10, $04, $31
  db      $0F, $29, $04, $11
  {$ENDIF}
  add     ecx,16
  jnz     @RemainderLoop
@Done:
  pop     esi
end; {AlignedFwdMoveSSE}

{-------------------------------------------------------------------------}
procedure Forwards_IA32;
asm
  push    ebx
  mov     ebx,edx
  fild    qword ptr [eax]
  add     eax,ecx {QWORD Align Writes}
  add     ecx,edx
  add     edx,7
  and     edx,-8
  sub     ecx,edx
  add     edx,ecx {Now QWORD Aligned}
  sub     ecx,16
  neg     ecx
@FwdLoop:
  fild    qword ptr [eax+ecx-16]
  fistp   qword ptr [edx+ecx-16]
  fild    qword ptr [eax+ecx-8]
  fistp   qword ptr [edx+ecx-8]
  add     ecx,16
  jle     @FwdLoop
  fistp   qword ptr [ebx]
  neg     ecx
  add     ecx,16
  pop     ebx
  jmp     SmallForwardMove
end;

{-------------------------------------------------------------------------}
procedure Backwards_IA32;
asm
  push    ebx
  fild    qword ptr [eax+ecx-8]
  lea     ebx,[edx+ecx] {QWORD Align Writes}
  and     ebx,7
  sub     ecx,ebx
  add     ebx,ecx {Now QWORD Aligned, EBX = Original Length}
  sub     ecx,16
@BwdLoop:
  fild    qword ptr [eax+ecx]
  fild    qword ptr [eax+ecx+8]
  fistp   qword ptr [edx+ecx+8]
  fistp   qword ptr [edx+ecx]
  sub     ecx,16
  jge     @BwdLoop
  fistp   qword ptr [edx+ebx-8]
  add     ecx,16
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure Forwards_MMX;
const
  LARGESIZE = 1024;
asm
  cmp     ecx,LARGESIZE
  jge     @FwdLargeMove
  cmp     ecx,72 {Size at which using MMX becomes worthwhile}
  jl      @FwdMoveNonMMX
  push    ebx
  mov     ebx,edx
  {$IFDEF DCC6OrLater}
  movq    mm0,[eax] {First 8 Characters}
  {$ELSE}
  db      $0F, $6F, $00
  {$ENDIF}
  {QWORD Align Writes}
  add     eax,ecx
  add     ecx,edx
  add     edx,7
  and     edx,-8
  sub     ecx,edx
  add     edx,ecx
  {Now QWORD Aligned}
  sub     ecx,32
  neg     ecx
@FwdLoopMMX:
  {$IFDEF DCC6OrLater}
  movq    mm1,[eax+ecx-32]
  movq    mm2,[eax+ecx-24]
  movq    mm3,[eax+ecx-16]
  movq    mm4,[eax+ecx- 8]
  movq    [edx+ecx-32],mm1
  movq    [edx+ecx-24],mm2
  movq    [edx+ecx-16],mm3
  movq    [edx+ecx- 8],mm4
  {$ELSE}
  db      $0F, $6F, $4C, $01, $E0
  db      $0F, $6F, $54, $01, $E8
  db      $0F, $6F, $5C, $01, $F0
  db      $0F, $6F, $64, $01, $F8
  db      $0F, $7F, $4C, $11, $E0
  db      $0F, $7F, $54, $11, $E8
  db      $0F, $7F, $5C, $11, $F0
  db      $0F, $7F, $64, $11, $F8
  {$ENDIF}
  add     ecx,32
  jle     @FwdLoopMMX
  {$IFDEF DCC6OrLater}
  movq    [ebx],mm0 {First 8 Characters}
  emms
  {$ELSE}
  db      $0F, $7F, $03
  db      $0F, $77
  {$ENDIF}
  pop     ebx
  neg     ecx
  add     ecx,32
  jmp     SmallForwardMove
@FwdMoveNonMMX:
  push    edi
  push    ebx
  push    edx
  mov     edi,[eax]
  {DWORD Align Reads}
  add     edx,ecx
  add     ecx,eax
  add     eax,3
  and     eax,-4
  sub     ecx,eax
  add     eax,ecx
  {Now DWORD Aligned}
  sub     ecx,32
  neg     ecx
@FwdLoop:
  mov     ebx,[eax+ecx-32]
  mov     [edx+ecx-32],ebx
  mov     ebx,[eax+ecx-28]
  mov     [edx+ecx-28],ebx
  mov     ebx,[eax+ecx-24]
  mov     [edx+ecx-24],ebx
  mov     ebx,[eax+ecx-20]
  mov     [edx+ecx-20],ebx
  mov     ebx,[eax+ecx-16]
  mov     [edx+ecx-16],ebx
  mov     ebx,[eax+ecx-12]
  mov     [edx+ecx-12],ebx
  mov     ebx,[eax+ecx-8]
  mov     [edx+ecx-8],ebx
  mov     ebx,[eax+ecx-4]
  mov     [edx+ecx-4],ebx
  add     ecx,32
  jle     @FwdLoop
  pop     ebx {Orig EDX}
  mov     [ebx],edi
  neg     ecx
  add     ecx,32
  pop     ebx
  pop     edi
  jmp     SmallForwardMove
@FwdLargeMove:
  push    ebx
  mov     ebx,ecx
  test    edx,15
  jz      @FwdAligned
  {16 byte Align Destination}
  mov     ecx,edx
  add     ecx,15
  and     ecx,-16
  sub     ecx,edx
  add     eax,ecx
  add     edx,ecx
  sub     ebx,ecx
  {Destination now 16 Byte Aligned}
  call    SmallForwardMove
@FwdAligned:
  mov     ecx,ebx
  and     ecx,-16
  sub     ebx,ecx {EBX = Remainder}
  push    esi
  push    edi
  mov     esi,eax          {ESI = Source}
  mov     edi,edx          {EDI = Dest}
  mov     eax,ecx          {EAX = Count}
  and     eax,-64          {EAX = No of Bytes to Blocks Moves}
  and     ecx,$3F          {ECX = Remaining Bytes to Move (0..63)}
  add     esi,eax
  add     edi,eax
  shr     eax,3            {EAX = No of QWORD's to Block Move}
  neg     eax
@MMXcopyloop:
  {$IFDEF DCC6OrLater}
  movq    mm0,[esi+eax*8   ]
  movq    mm1,[esi+eax*8+ 8]
  movq    mm2,[esi+eax*8+16]
  movq    mm3,[esi+eax*8+24]
  movq    mm4,[esi+eax*8+32]
  movq    mm5,[esi+eax*8+40]
  movq    mm6,[esi+eax*8+48]
  movq    mm7,[esi+eax*8+56]
  movq    [edi+eax*8   ],mm0
  movq    [edi+eax*8+ 8],mm1
  movq    [edi+eax*8+16],mm2
  movq    [edi+eax*8+24],mm3
  movq    [edi+eax*8+32],mm4
  movq    [edi+eax*8+40],mm5
  movq    [edi+eax*8+48],mm6
  movq    [edi+eax*8+56],mm7
  {$ELSE}
  db      $0F, $6F, $04, $C6
  db      $0F, $6F, $4C, $C6, $08
  db      $0F, $6F, $54, $C6, $10
  db      $0F, $6F, $5C, $C6, $18
  db      $0F, $6F, $64, $C6, $20
  db      $0F, $6F, $6C, $C6, $28
  db      $0F, $6F, $74, $C6, $30
  db      $0F, $6F, $7C, $C6, $38
  db      $0F, $7F, $04, $C7
  db      $0F, $7F, $4C, $C7, $08
  db      $0F, $7F, $54, $C7, $10
  db      $0F, $7F, $5C, $C7, $18
  db      $0F, $7F, $64, $C7, $20
  db      $0F, $7F, $6C, $C7, $28
  db      $0F, $7F, $74, $C7, $30
  db      $0F, $7F, $7C, $C7, $38
  {$ENDIF}
  add     eax,8
  jnz     @MMXcopyloop
  {$IFDEF DCC6OrLater}
  emms                   {Empty MMX State}
  {$ELSE}
  db      $0F, $77
  {$ENDIF}
  add     ecx,ebx
  shr     ecx,2
  rep     movsd
  mov     ecx,ebx
  and     ecx,3
  rep     movsb
  pop     edi
  pop     esi
  pop     ebx
end;

{-------------------------------------------------------------------------}
procedure Backwards_MMX;
asm
  push    ebx
  cmp     ecx,72 {Size at which using MMX becomes worthwhile}
  jl      @BwdMove
  {$IFDEF DCC6OrLater}
  movq    mm0,[eax+ecx-8] {Get Last QWORD}
  {$ELSE}
  db      $0F, $6F, $44, $01, $F8 
  {$ENDIF}
  {QWORD Align Writes}
  lea     ebx,[edx+ecx]
  and     ebx,7
  sub     ecx,ebx
  add     ebx,ecx
  {Now QWORD Aligned}
  sub     ecx,32
@BwdLoopMMX:
  {$IFDEF DCC6OrLater}
  movq    mm1,[eax+ecx   ]
  movq    mm2,[eax+ecx+ 8]
  movq    mm3,[eax+ecx+16]
  movq    mm4,[eax+ecx+24]
  movq    [edx+ecx+24],mm4
  movq    [edx+ecx+16],mm3
  movq    [edx+ecx+ 8],mm2
  movq    [edx+ecx   ],mm1
  {$ELSE}
  db      $0F, $6F, $0C, $01
  db      $0F, $6F, $54, $01, $08
  db      $0F, $6F, $5C, $01, $10
  db      $0F, $6F, $64, $01, $18
  db      $0F, $7F, $64, $11, $18
  db      $0F, $7F, $5C, $11, $10
  db      $0F, $7F, $54, $11, $08
  db      $0F, $7F, $0C, $11
  {$ENDIF}
  sub     ecx,32
  jge     @BwdLoopMMX
  {$IFDEF DCC6OrLater}
  movq    [edx+ebx-8], mm0 {Last QWORD}
  emms
  {$ELSE}
  db      $0F, $7F, $44, $13, $F8
  db      $0F, $77
  {$ENDIF}
  add     ecx,32
  pop     ebx
  jmp     SmallBackwardMove
@BwdMove:
  push    edi
  push    ecx
  mov     edi,[eax+ecx-4] {Get Last DWORD}
  {DWORD Align Writes}
  lea     ebx,[edx+ecx]
  and     ebx,3
  sub     ecx,ebx
  {Now DWORD Aligned}
  sub     ecx,32
@BwdLoop:
  mov     ebx,[eax+ecx+28]
  mov     [edx+ecx+28],ebx
  mov     ebx,[eax+ecx+24]
  mov     [edx+ecx+24],ebx
  mov     ebx,[eax+ecx+20]
  mov     [edx+ecx+20],ebx
  mov     ebx,[eax+ecx+16]
  mov     [edx+ecx+16],ebx
  mov     ebx,[eax+ecx+12]
  mov     [edx+ecx+12],ebx
  mov     ebx,[eax+ecx+8]
  mov     [edx+ecx+8],ebx
  mov     ebx,[eax+ecx+4]
  mov     [edx+ecx+4],ebx
  mov     ebx,[eax+ecx]
  mov     [edx+ecx],ebx
  sub     ecx,32
  jge     @BwdLoop
  pop     ebx
  add     ecx,32
  mov     [edx+ebx-4],edi {Last DWORD}
  pop     edi
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure Forwards_SSE;
const
  LARGESIZE = 2048;
asm
  cmp     ecx,LARGESIZE
  jge     @FwdLargeMove
  cmp     ecx,SMALLMOVESIZE+32
  jg      @FwdMoveSSE
  {$IFDEF DCC6OrLater}
  movups  xmm1,[eax]
  movups  xmm2,[eax+16]
  movups  [edx],xmm1
  movups  [edx+16],xmm2
  {$ELSE}
  db      $0F, $10, $08
  db      $0F, $10, $50, $10
  db      $0F, $11, $0A
  db      $0F, $11, $52, $10
  {$ENDIF}
  add     eax,ecx
  add     edx,ecx
  sub     ecx,32
  jmp     SmallForwardMove
@FwdMoveSSE:
  push    ebx
  {$IFDEF DCC6OrLater}
  movups  xmm0,[eax] {First 16 Bytes}
  {$ELSE}
  db      $0F, $10, $00
  {$ENDIF}
  mov     ebx,edx
  {Align Writes}
  add     eax,ecx
  add     ecx,edx
  add     edx,15
  and     edx,-16
  sub     ecx,edx
  add     edx,ecx
  {Now Aligned}
  sub     ecx,32
  neg     ecx
@FwdLoopSSE:
  {$IFDEF DCC6OrLater}
  movups  xmm1,[eax+ecx-32]
  movups  xmm2,[eax+ecx-16]
  movaps  [edx+ecx-32],xmm1
  movaps  [edx+ecx-16],xmm2
  {$ELSE}
  db      $0F, $10, $4C, $01, $E0
  db      $0F, $10, $54, $01, $F0
  db      $0F, $29, $4C, $11, $E0
  db      $0F, $29, $54, $11, $F0
  {$ENDIF}
  add     ecx,32
  jle     @FwdLoopSSE
  {$IFDEF DCC6OrLater}
  movups  [ebx],xmm0 {First 16 Bytes}
  {$ELSE}
  db      $0F, $11, $03
  {$ENDIF}
  neg     ecx
  pop     ebx
  add     ecx,32
  jmp     SmallForwardMove
@FwdLargeMove:
  push    ebx
  mov     ebx,ecx
  test    edx,15
  jz      @FwdLargeAligned
  {16 byte Align Destination}
  mov     ecx,edx
  add     ecx,15
  and     ecx,-16
  sub     ecx,edx
  add     eax,ecx
  add     edx,ecx
  sub     ebx,ecx
  {Destination now 16 Byte Aligned}
  call    SmallForwardMove
  mov     ecx,ebx
@FwdLargeAligned:
  and     ecx,-16
  sub     ebx,ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    AlignedFwdMoveSSE
  pop     ecx
  pop     eax
  pop     edx
  add     ecx,ebx
  add     eax,ecx
  add     edx,ecx
  mov     ecx,ebx
  pop     ebx
  jmp     SmallForwardMove
end;

{-------------------------------------------------------------------------}
procedure Backwards_SSE;
asm
  cmp     ecx,SMALLMOVESIZE+32
  jg      @BwdMoveSSE
  sub     ecx,32
  {$IFDEF DCC6OrLater}
  movups  xmm1,[eax+ecx]
  movups  xmm2,[eax+ecx+16]
  movups  [edx+ecx],xmm1
  movups  [edx+ecx+16],xmm2
  {$ELSE}
  db      $0F, $10, $0C, $01
  db      $0F, $10, $54, $01, $10
  db      $0F, $11, $0C, $11
  db      $0F, $11, $54, $11, $10
  {$ENDIF}
  jmp     SmallBackwardMove
@BwdMoveSSE:
  push    ebx
  {$IFDEF DCC6OrLater}
  movups  xmm0,[eax+ecx-16] {Last 16 Bytes}
  {$ELSE}
  db      $0F, $10, $44, $01, $F0
  {$ENDIF}
  {Align Writes}
  lea     ebx,[edx+ecx]
  and     ebx,15
  sub     ecx,ebx
  add     ebx,ecx
  {Now Aligned}
  sub     ecx,32
@BwdLoop:
  {$IFDEF DCC6OrLater}
  movups  xmm1,[eax+ecx]
  movups  xmm2,[eax+ecx+16]
  movaps  [edx+ecx],xmm1
  movaps  [edx+ecx+16],xmm2
  {$ELSE}
  db      $0F, $10, $0C, $01
  db      $0F, $10, $54, $01, $10
  db      $0F, $29, $0C, $11
  db      $0F, $29, $54, $11, $10
  {$ENDIF}
  sub     ecx,32
  jge     @BwdLoop
  {$IFDEF DCC6OrLater}
  movups  [edx+ebx-16],xmm0  {Last 16 Bytes}
  {$ELSE}
  db      $0F, $11, $44, $13, $F0
  {$ENDIF}
  add     ecx,32
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure MoveJOH_IA32(const Source; var Dest; Count : Integer);
asm {ReplaceMove Code depends on the following not Changing}
  cmp     ecx,SMALLMOVESIZE
  ja      @Large
  cmp     eax,edx
  lea     eax,[eax+ecx]
  jle     @SmallCheck
@SmallForward:
  add     edx,ecx
  jmp     SmallForwardMove
@SmallCheck:
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  sub     eax,ecx
  jmp     SmallBackwardMove
@Large:
  jng     @Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax,edx
  jg      Forwards_IA32
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  push    eax
  add     eax,ecx
  cmp     eax,edx
  pop     eax
  jg      Backwards_IA32 {Source/Dest Overlap}
  jmp     Forwards_IA32
@Done:
end; {MoveJOH_IA32}

{-------------------------------------------------------------------------}
procedure MoveJOH_MMX(const Source; var Dest; Count : Integer);
asm {MUST be identical layout as MoveJOH_IA32 for ReplaceMove to Work}
  cmp     ecx,SMALLMOVESIZE
  ja      @Large
  cmp     eax,edx
  lea     eax,[eax+ecx]
  jle     @SmallCheck
@SmallForward:
  add     edx,ecx
  jmp     SmallForwardMove
@SmallCheck:
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  sub     eax,ecx
  jmp     SmallBackwardMove
@Large:
  jng     @Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax,edx
  jg      Forwards_MMX
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  push    eax
  add     eax,ecx
  cmp     eax,edx
  pop     eax
  jg      Backwards_MMX {Source/Dest Overlap}
  jmp     Forwards_MMX
@Done:
end; {MoveJOH_MMX}

{-------------------------------------------------------------------------}
procedure MoveJOH_SSE(const Source; var Dest; Count : Integer);
asm {MUST be identical layout as MoveJOH_IA32 for ReplaceMove to Work}
  cmp     ecx,SMALLMOVESIZE
  ja      @Large
  cmp     eax,edx
  lea     eax,[eax+ecx]
  jle     @SmallCheck
@SmallForward:
  add     edx,ecx
  jmp     SmallForwardMove
@SmallCheck:
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  sub     eax,ecx
  jmp     SmallBackwardMove
@Large:
  jng     @Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax,edx
  jg      Forwards_SSE
  je      @Done {For Compatibility with Delphi's move for Source = Dest}
  push    eax
  add     eax,ecx
  cmp     eax,edx
  pop     eax
  jg      Backwards_SSE {Source/Dest Overlap}
  jmp     Forwards_SSE
@Done:
end; {MoveJOH_SSE}

procedure FindMove;
begin
  case CpuType of    //
    ctXP:
      if EnableMMX then
        nxMove := @MoveJOH_MMX
      else
        nxMove := @MoveJOH_IA32;
  else
    if (not OSIsWin95_or_NT4) and EnableSSE then
      nxMove := @MoveJOH_SSE
    else                             
      if EnableMMX then
        nxMove := @MoveJOH_MMX
      else
        nxMove := @MoveJOH_IA32;
  end;    // case
end;


initialization
  FindMove;
end.

