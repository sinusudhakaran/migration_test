{##############################################################################}
{# NexusDB: nxllFastFillChar.pas 2.00                                         #}
{# NexusDB Memory Manager: nxllFastFillChar.pas 2.03                          #}
{##############################################################################}
{# NexusDB: CPU specific fast FillChar operations from the FastCode project   #}
{##############################################################################}

{$I nxDefine.inc}
//{$undef DCC6OrLater}

unit nxllFastFillChar;

//Version : 0.1. Preliminary version
//Only direct calling supported

interface

uses
  nxllFastCpuDetect;

type
  TnxFillChar = procedure(var Dest; Count: Integer; Value: Byte);

var
  nxFillChar : TnxFillChar;

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


implementation


function GetVersionEx; external 'kernel32.dll' name 'GetVersionExA';


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


//Author:            John O'Harrow
//Date:              N/A
//Optimized for:     P4
//Instructionset(s): N/A
//Original Name:     FillCharJOH_SSE2

procedure FillCharFastcodeP4(var Dest; Count: Integer; Value: Char);
asm {Size = 161 Bytes}
  cmp       edx, 32
  mov       ch, cl                {Copy Value into both Bytes of CX}
  jl        @@Small
  sub       edx, 16
  {$IFDEF DCC6OrLater}
  movd      xmm0, ecx
  pshuflw   xmm0, xmm0, 0
  pshufd    xmm0, xmm0, 0
  movups    [eax], xmm0           {Fill First 16 Bytes}
  movups    [eax+edx], xmm0       {Fill Last 16 Bytes}
  {$ELSE}
  db        $66, $0F, $6E, $C1
  db        $F2, $0F, $70, $C0, $00
  db        $66, $0F, $70, $C0, $00
  db        $0F, $11, $00
  db        $0F, $11, $04, $02
  {$ENDIF}
  mov       ecx, eax              {16-Byte Align Writes}
  and       ecx, 15
  sub       ecx, 16
  sub       eax, ecx
  add       edx, ecx
  add       eax, edx
  neg       edx
  cmp       edx, -512*1024
  jb        @@Large
@@Loop:
  {$IFDEF DCC6OrLater}
  movaps    [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  {$ELSE}
  db        $0F, $29, $04, $02
  {$ENDIF}
  add       edx, 16
  jl        @@Loop
  ret
@@Large:
  {$IFDEF DCC6OrLater}
  movntdq    [eax+edx], xmm0      {Fill 16 Bytes per Loop}
  {$ELSE}
  db        $66, $0F, $E7, $04, $02
  {$ENDIF}
  add       edx, 16
  jl        @@Large
  ret
@@Small:
  test      edx, edx
  jle       @@Done
  mov       [eax+edx-1], cl       {Fill Last Byte}
  and       edx, -2               {No. of Words to Fill}                                 
  neg       edx
  lea       edx, [@@SmallFill + 60 + edx * 2]
  jmp       edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov       [eax+28], cx
  mov       [eax+26], cx
  mov       [eax+24], cx
  mov       [eax+22], cx
  mov       [eax+20], cx
  mov       [eax+18], cx
  mov       [eax+16], cx
  mov       [eax+14], cx
  mov       [eax+12], cx
  mov       [eax+10], cx
  mov       [eax+ 8], cx
  mov       [eax+ 6], cx
  mov       [eax+ 4], cx
  mov       [eax+ 2], cx
  mov       [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

//Author:            Dennis Kjaer Christensen
//Date:              16/9 2003
//Optimized for:     P3
//Instructionset(s): IA32, MMX, SSE
//Original Name:     FillCharDKC_SSE_9

procedure FillCharFastcodeP3(var Dest; Count: Integer; Value: Char);
asm
   test edx,edx
   jle  @Exit2
   //case Count of
   cmp  edx,31
   jnbe @CaseElse
   jmp  dword ptr [edx*4+@Case1JmpTable]
 @CaseCount0 :
   ret
 @CaseCount1 :
   mov  [eax],cl
   ret
 @CaseCount2 :
   mov  ch,cl
   mov  [eax],cx
   ret
 @CaseCount3 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cl
   ret
 @CaseCount4 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   ret
 @CaseCount5 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cl
   ret
 @CaseCount6 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   ret
 @CaseCount7 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cl
   ret
 @CaseCount8 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   ret
 @CaseCount9 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cl
   ret
 @CaseCount10 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   ret
 @CaseCount11 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cl
   ret
 @CaseCount12 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   ret
 @CaseCount13 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cl
   ret
 @CaseCount14 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   ret
 @CaseCount15 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cl
   ret
 @CaseCount16 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   ret
 @CaseCount17 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cl
   ret
 @CaseCount18 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   ret
 @CaseCount19 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   mov  [eax+18],cl
   ret
 @CaseCount20 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   ret
 @CaseCount21 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cl
   ret
 @CaseCount22 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   ret
 @CaseCount23 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cl
   ret
 @CaseCount24 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   ret
 @CaseCount25 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cl
   ret
 @CaseCount26 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   ret
 @CaseCount27 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cl
   ret
 @CaseCount28 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   ret
 @CaseCount29 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cl
   ret
 @CaseCount30 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   ret
 @CaseCount31 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   mov   [eax+30],cl
   ret
 @CaseElse :
   //Need at least 24 bytes here. Max 8 for alignment and 16 for loop
   push  ebx
   push  esi
   push  edi
   //P := PChar(@Dest);
   mov   esi,eax
   //StopP2 := P + Count;
   lea   ebx,[edx+eax]
   //8 byte Align
 @Repeat3 :
   mov    [esi],cl
   add    esi,1
   sub    edx,1     //Decrement Count
   mov    edi,esi
   and    edi,7
   test   edi,edi
   jnz    @Repeat3
   //Broadcast value
   mov    ch, cl
  {$IFDEF DCC6OrLater}
   movd   mm0, ecx
   pshufw mm0, mm0, 0
  {$ELSE}
   db     $0F, $6E, $C1
   db     $0F, $70, $C0, $00
  {$ENDIF}
   //I := 0;
   xor    eax,eax
   sub    edx,15
   cmp    edx,256000
   ja     @Repeat4
 @Repeat1 :
  {$IFDEF DCC6OrLater}
   movq   [esi+eax],  mm0
   movq   [esi+eax+8],mm0
  {$ELSE}
   db     $0F, $7F, $04, $30
   db     $0F, $7F, $44, $30, $08
  {$ENDIF}
   add    eax,16
   cmp    eax,edx
   jl     @Repeat1
   jmp    @Repeat4End
 @Repeat4 :
  {$IFDEF DCC6OrLater}
   movntq [esi+eax],  mm0
   movntq [esi+eax+8],mm0
  {$ELSE}
   db     $0F, $E7, $04, $30
   db     $0F, $E7, $44, $30, $08
  {$ENDIF}
   add    eax,16
   cmp    eax,edx
   jl     @Repeat4
 @Repeat4End :
  {$IFDEF DCC6OrLater}
   emms
  {$ELSE}
   db     $0F, $77
  {$ENDIF}
   //Fill the rest if any
   add   esi,eax
   cmp   esi,ebx
   jnb   @Exit1
 @Repeat2 :
   mov   [esi],cl
   add   esi,1
   cmp   esi,ebx
   jb    @Repeat2
 @Exit1 :
   pop   edi
   pop   esi
   pop   ebx
 @Exit2 :
   ret
   nop
   nop
   nop
   nop
   nop

@Case1JmpTable:
 dd @CaseCount0
 dd @CaseCount1
 dd @CaseCount2
 dd @CaseCount3
 dd @CaseCount4
 dd @CaseCount5
 dd @CaseCount6
 dd @CaseCount7
 dd @CaseCount8
 dd @CaseCount9
 dd @CaseCount10
 dd @CaseCount11
 dd @CaseCount12
 dd @CaseCount13
 dd @CaseCount14
 dd @CaseCount15
 dd @CaseCount16
 dd @CaseCount17
 dd @CaseCount18
 dd @CaseCount19
 dd @CaseCount20
 dd @CaseCount21
 dd @CaseCount22
 dd @CaseCount23
 dd @CaseCount24
 dd @CaseCount25
 dd @CaseCount26
 dd @CaseCount27
 dd @CaseCount28
 dd @CaseCount29
 dd @CaseCount30
 dd @CaseCount31

end;

//Author:            John O'Harrow
//Date:              N/A
//Optimized for:     XP
//Instructionset(s): N/A
//Original Name:     FillCharJOH_SSE

procedure FillCharFastcodeXP(var Dest; Count: Integer; Value: Char);
asm {Size = 161 Bytes}
  cmp       edx, 32
  mov       ch, cl                {Copy Value into both Bytes of CX}
  jl        @@Small
  sub       edx, 16
  mov       [eax], cx             {Fill First 4 Bytes}
  mov       [eax+2], cx
  {$IFDEF DCC6OrLater}
  movss     xmm0, [eax]           {Set each byte of XMM0 to Value}
  shufps    xmm0, xmm0, 0
  movups    [eax], xmm0           {Fill First 16 Bytes}
  movups    [eax+edx], xmm0       {Fill Last 16 Bytes}
  {$ELSE}
  db        $F3, $0F, $10, $00
  db        $0F, $C6, $C0, $00
  db        $0F, $11, $00
  db        $0F, $11, $04, $02
  {$ENDIF}
  mov       ecx, eax              {16-Byte Align Writes}
  and       ecx, 15
  sub       ecx, 16
  sub       eax, ecx
  add       edx, ecx
  add       eax, edx
  neg       edx
  cmp       edx, -512*1024
  jb        @@Large
@@Loop:
  {$IFDEF DCC6OrLater}
  movaps    [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  {$ELSE}
  db        $0F, $29, $04, $02
  {$ENDIF}
  add       edx, 16
  jl        @@Loop
  ret
@@Large:
  {$IFDEF DCC6OrLater}
  movntps   [eax+edx], xmm0       {Fill 16 Bytes per Loop}
  {$ELSE}
  db        $0F, $2B, $04, $02
  {$ENDIF}
  add       edx, 16
  jl        @@Large
  ret
@@Small:
  test      edx, edx
  jle       @@Done
  mov       [eax+edx-1], cl       {Fill Last Byte}
  and       edx, -2               {No. of Words to Fill}
  neg       edx
  lea       edx, [@@SmallFill + 60 + edx * 2]
  jmp       edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov       [eax+28], cx
  mov       [eax+26], cx
  mov       [eax+24], cx
  mov       [eax+22], cx
  mov       [eax+20], cx
  mov       [eax+18], cx
  mov       [eax+16], cx
  mov       [eax+14], cx
  mov       [eax+12], cx
  mov       [eax+10], cx
  mov       [eax+ 8], cx
  mov       [eax+ 6], cx
  mov       [eax+ 4], cx
  mov       [eax+ 2], cx
  mov       [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

//Author:            Dennis Kjaer Christensen
//Date:              22/12 2003
//Optimized for:     Opteron
//Instructionset(s): IA32, MMX, SSE
//Original Name:     FillCharDKC_SSE2_10

procedure FillCharFastcodeOpteron(var Dest; Count: Integer; Value: Char);
asm
   test edx,edx
   jle  @Exit2
   //case Count of
   cmp  edx,31
   jnbe @CaseElse
   jmp  dword ptr [edx*4+@Case1JmpTable]
 @CaseCount0 :
   ret
 @CaseCount1 :
   mov  [eax],cl
   ret
 @CaseCount2 :
   mov  ch,cl
   mov  [eax],cx
   ret
 @CaseCount3 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cl
   ret
 @CaseCount4 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   ret
 @CaseCount5 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cl
   ret
 @CaseCount6 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   ret
 @CaseCount7 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cl
   ret
 @CaseCount8 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   ret
 @CaseCount9 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cl
   ret
 @CaseCount10 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   ret
 @CaseCount11 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cl
   ret
 @CaseCount12 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   ret
 @CaseCount13 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cl
   ret
 @CaseCount14 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   ret
 @CaseCount15 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cl
   ret
 @CaseCount16 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   ret
 @CaseCount17 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cl
   ret
 @CaseCount18 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   ret
 @CaseCount19 :
   mov  ch,cl
   mov  [eax],cx
   mov  [eax+2],cx
   mov  [eax+4],cx
   mov  [eax+6],cx
   mov  [eax+8],cx
   mov  [eax+10],cx
   mov  [eax+12],cx
   mov  [eax+14],cx
   mov  [eax+16],cx
   mov  [eax+18],cl
   ret
 @CaseCount20 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   ret
 @CaseCount21 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cl
   ret
 @CaseCount22 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   ret
 @CaseCount23 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cl
   ret
 @CaseCount24 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   ret
 @CaseCount25 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cl
   ret
 @CaseCount26 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   ret
 @CaseCount27 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cl
   ret
 @CaseCount28 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   ret
 @CaseCount29 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cl
   ret
 @CaseCount30 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   ret
 @CaseCount31 :
   mov   ch,cl
   mov   [eax],cx
   mov   [eax+2],cx
   mov   [eax+4],cx
   mov   [eax+6],cx
   mov   [eax+8],cx
   mov   [eax+10],cx
   mov   [eax+12],cx
   mov   [eax+14],cx
   mov   [eax+16],cx
   mov   [eax+18],cx
   mov   [eax+20],cx
   mov   [eax+22],cx
   mov   [eax+24],cx
   mov   [eax+26],cx
   mov   [eax+28],cx
   mov   [eax+30],cl
   ret
   nop
   nop
   nop
   nop
   nop
 @CaseElse :
   //Need at least 32 bytes here. Max 16 for alignment and 16 for loop
   push    esi
   push    edi
   //Broadcast value
   mov     ch, cl
  {$IFDEF DCC6OrLater}
   movd    xmm0, ecx
   pshuflw xmm0, xmm0, 0
   pshufd  xmm0, xmm0, 0
   //Fill first 16 non aligned bytes
   movdqu  [eax],xmm0
  {$ELSE}
   db      $66, $0F, $6E, $C1
   db      $F2, $0F, $70, $C0, $00
   db      $66, $0F, $70, $C0, $00
   //Fill first 16 non aligned bytes
   db      $F3, $0F, $7F, $00
  {$ENDIF}
   //StopP2 := P + Count;
   lea     ecx,[eax+edx]
   //16 byte Align
   mov     edi,eax
   and     edi,$F
   mov     esi,16
   sub     esi,edi
   add     eax,esi
   sub     edx,esi
   //I := 0;
   xor     esi,esi
   sub     edx,15
   cmp     edx,1048576
   ja      @Repeat4
 @Repeat1 :
  {$IFDEF DCC6OrLater}
   movdqa  [eax+esi],xmm0
  {$ELSE}
   db      $66, $0F, $7F, $04, $06
  {$ENDIF}
   add     esi,16
   cmp     esi,edx
   jl      @Repeat1
   jmp     @Repeat4End
   nop
   nop
 @Repeat4 :
  {$IFDEF DCC6OrLater}
   movntdq [eax+esi],xmm0
  {$ELSE}
   db      $66, $0F, $E7, $04, $06
  {$ENDIF}
   add     esi,16
   cmp     esi,edx
   jl      @Repeat4
 @Repeat4End :
   {movdq2q mm0,xmm0
   movntq  [ecx-16],mm0
   movntq  [ecx-8], mm0
   emms}
   //Fill the rest
  {$IFDEF DCC6OrLater}
   movdqu [ecx-16],xmm0
  {$ELSE}
   db      $F3, $0F, $7F, $41, $F0
  {$ENDIF}
 @Exit1 :
   pop   edi
   pop   esi
 @Exit2 :
   ret
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop

@Case1JmpTable:
 dd @CaseCount0
 dd @CaseCount1
 dd @CaseCount2
 dd @CaseCount3
 dd @CaseCount4
 dd @CaseCount5
 dd @CaseCount6
 dd @CaseCount7
 dd @CaseCount8
 dd @CaseCount9
 dd @CaseCount10
 dd @CaseCount11
 dd @CaseCount12
 dd @CaseCount13
 dd @CaseCount14
 dd @CaseCount15
 dd @CaseCount16
 dd @CaseCount17
 dd @CaseCount18
 dd @CaseCount19
 dd @CaseCount20
 dd @CaseCount21
 dd @CaseCount22
 dd @CaseCount23
 dd @CaseCount24
 dd @CaseCount25
 dd @CaseCount26
 dd @CaseCount27
 dd @CaseCount28
 dd @CaseCount29
 dd @CaseCount30
 dd @CaseCount31

end;

//Author:            Pierre Le Riche
//Date:              N/A
//Optimized for:     Blended
//Instructionset(s): N/A
//Original Name:     FillCharPLRMMX1

{MMX instruction set. Size = 240 + 4 * 40 = 400}
procedure FillCharFastcodeBlended(var Dest; Count: Integer; Value: Char);
asm
  {Copy the fill character into ch}
  mov ch, cl
  {Big or small fill?}
  cmp edx, 39
  ja @BigFill
  {Jump to the correct handler}
  jmp dword ptr [edx * 4 + @JumpTable]
@BigFill:
  cmp edx, 0
  jl @DoneFill
  {Get the values in mm0}
  {$IFDEF DCC6OrLater}
  movd mm0, ecx
  punpcklwd mm0, mm0
  punpckldq mm0, mm0
  {Store the first qword}
  movq [eax], mm0
  {$ELSE}
  db      $0F, $6E, $C1
  db      $0F, $61, $C0
  db      $0F, $62, $C0
  {Store the first qword}
  db      $0F, $7F, $00
  {$ENDIF}
  {qword align eax}
  add edx, eax
  add eax, 8
  and eax, -8
  sub edx, eax
  {Fill 32 bytes}
@Fill32Loop:
  {Subtract 32 from edx so long}
  sub edx, 32
  {Fill 32 bytes}
  {$IFDEF DCC6OrLater}
  movq [eax], mm0
  movq [eax + 8], mm0
  movq [eax + 16], mm0
  movq [eax + 24], mm0
  {$ELSE}
  db      $0F, $7F, $00
  db      $0F, $7F, $40, $08
  db      $0F, $7F, $40, $10
  db      $0F, $7F, $40, $18
  {$ENDIF}
  add eax, 32
  cmp edx, 32
  jae @Fill32Loop
  {Exit mmx state}
  {$IFDEF DCC6OrLater}
  emms
  {$ELSE}
  db      $0F, $77
  {$ENDIF}
  {Do the rest of the bytes}
  jmp dword ptr [edx * 4 + @JumpTable]
@DoneFill:
  ret
  nop
  nop
  nop //align branch targets
@Fill38:
  mov [eax + 36], cx
@Fill36:
  mov [eax + 34], cx
@Fill34:
  mov [eax + 32], cx
@Fill32:
  mov [eax + 30], cx
@Fill30:
  mov [eax + 28], cx
@Fill28:
  mov [eax + 26], cx
@Fill26:
  mov [eax + 24], cx
@Fill24:
  mov [eax + 22], cx
@Fill22:
  mov [eax + 20], cx
@Fill20:
  mov [eax + 18], cx
@Fill18:
  mov [eax + 16], cx
@Fill16:
  mov [eax + 14], cx
@Fill14:
  mov [eax + 12], cx
@Fill12:
  mov [eax + 10], cx
@Fill10:
  mov [eax + 8], cx
@Fill8:
  mov [eax + 6], cx
@Fill6:
  mov [eax + 4], cx
@Fill4:
  mov [eax + 2], cx
@Fill2:
  mov [eax], cx
  ret
@Fill39:
  mov [eax + 37], cx
@Fill37:
  mov [eax + 35], cx
@Fill35:
  mov [eax + 33], cx
@Fill33:
  mov [eax + 31], cx
@Fill31:
  mov [eax + 29], cx
@Fill29:
  mov [eax + 27], cx
@Fill27:
  mov [eax + 25], cx
@Fill25:
  mov [eax + 23], cx
@Fill23:
  mov [eax + 21], cx
@Fill21:
  mov [eax + 19], cx
@Fill19:
  mov [eax + 17], cx
@Fill17:
  mov [eax + 15], cx
@Fill15:
  mov [eax + 13], cx
@Fill13:
  mov [eax + 11], cx
@Fill11:
  mov [eax + 9], cx
@Fill9:
  mov [eax + 7], cx
@Fill7:
  mov [eax + 5], cx
@Fill5:
  mov [eax + 3], cx
@Fill3:
  mov [eax + 1], cx
@Fill1:
  mov [eax], cl
  ret
  nop //dword align jump table
@JumpTable:
  dd @DoneFill
  dd @Fill1, @Fill2, @Fill3, @Fill4, @Fill5, @Fill6, @Fill7, @Fill8, @Fill9
  dd @Fill10, @Fill11, @Fill12, @Fill13, @Fill14, @Fill15, @Fill16, @Fill17
  dd @Fill18, @Fill19, @Fill20, @Fill21, @Fill22, @Fill23, @Fill24, @Fill25
  dd @Fill26, @Fill27, @Fill28, @Fill29, @Fill30, @Fill31, @Fill32, @Fill33
  dd @Fill34, @Fill35, @Fill36, @Fill37, @Fill38, @Fill39
end;

//Author:            John O'Harrow
//Date:              N/A
//Optimized for:     RTL
//Instructionset(s): N/A
//Original Name:     FillCharJOH_FPU

procedure FillCharFastcodeRTL(var Dest; Count: Integer; Value: Char);
asm {Size = 153 Bytes}
  cmp   edx, 32
  mov   ch, cl                    {Copy Value into both Bytes of CX}
  jl    @@Small
  mov   [eax  ], cx               {Fill First 8 Bytes}
  mov   [eax+2], cx
  mov   [eax+4], cx
  mov   [eax+6], cx
  sub   edx, 16
  fld   qword ptr [eax]
  fst   qword ptr [eax+edx]       {Fill Last 16 Bytes}
  fst   qword ptr [eax+edx+8]
  mov   ecx, eax
  and   ecx, 7                    {8-Byte Align Writes}
  sub   ecx, 8
  sub   eax, ecx
  add   edx, ecx
  add   eax, edx
  neg   edx
@@Loop:
  fst   qword ptr [eax+edx]       {Fill 16 Bytes per Loop}
  fst   qword ptr [eax+edx+8]
  add   edx, 16
  jl    @@Loop
  ffree st(0)
  ret
  nop
  nop
  nop
@@Small:
  test  edx, edx
  jle   @@Done
  mov   [eax+edx-1], cl       {Fill Last Byte}
  and   edx, -2               {No. of Words to Fill}
  neg   edx
  lea   edx, [@@SmallFill + 60 + edx * 2]
  jmp   edx
  nop                             {Align Jump Destinations}
  nop
@@SmallFill:
  mov   [eax+28], cx
  mov   [eax+26], cx
  mov   [eax+24], cx
  mov   [eax+22], cx
  mov   [eax+20], cx
  mov   [eax+18], cx
  mov   [eax+16], cx
  mov   [eax+14], cx
  mov   [eax+12], cx
  mov   [eax+10], cx
  mov   [eax+ 8], cx
  mov   [eax+ 6], cx
  mov   [eax+ 4], cx
  mov   [eax+ 2], cx
  mov   [eax   ], cx
  ret {DO NOT REMOVE - This is for Alignment}
@@Done:
end;

procedure FindFillChar;
begin
  { win95 does not support SSE/2 processor state }
  if OSIsWin95_or_NT4 then begin
    if EnableMMX then
      nxFillChar := @FillCharFastcodeBlended
    else
      nxFillChar := @FillCharFastcodeRTL;
  end
  else begin
    case CpuType of
      ctP3:
        nxFillChar := @FillCharFastcodeP3;
      ctP4, ctPrescott:
        nxFillChar := @FillCharFastcodeP4;
      ctXP:
        nxFillChar := @FillCharFastcodeXP;
      ctOpteron:
        nxFillChar := @FillCharFastcodeOpteron;
    else
      if EnableMMX then
        nxFillChar := @FillCharFastcodeBlended
      else
        nxFillChar := @FillCharFastcodeRTL;
    end;
  end;
end;

initialization
  FindFillChar;
end.
