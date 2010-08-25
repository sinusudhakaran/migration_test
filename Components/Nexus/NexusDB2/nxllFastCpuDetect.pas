{##############################################################################}
{# NexusDB: nxllFastCpuDetect.pas 2.00                                        #}
{# NexusDB Memory Manager: nxllFastCpuDetect.pas 2.03                         #}
{##############################################################################}
{# NexusDB: functions from the FastCode project to detect CPU type            #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllFastCpuDetect;

interface

type
  TCpuType = (ctUnknown, ctP3, ctP4, ctXP, ctOpteron, ctPrescott);
  TCpuVendor = (cvUnknown, cvIntel, cvAMD);

var
  Family, Model               : Integer;
  VendorID                    : SHortString;
  CpuType                     : TCpuType;
  CPUVendor                   : TCpuVendor;

  EnableMMX                   : Boolean;
  EnableSSE                   : Boolean;

implementation

const
  ID_BIT                      = $200000;

type
  TCpuID = array[1..4] of Longint;
  TVendor = array [0..11] of char;


function GetCPUVendor : TVendor; assembler; register;
asm
  PUSH    EBX     {Save affected register}
  PUSH    EDI
  MOV     EDI,EAX   {@Result (TVendor)}
  MOV     EAX,0
  DW      $A20F    {CPUID Command}
  MOV     EAX,EBX
  XCHG EBX,ECX     {save ECX result}
  MOV ECX,4
@1:
  STOSB
  SHR     EAX,8
  LOOP    @1
  MOV     EAX,EDX
  MOV ECX,4
@2:
  STOSB
  SHR     EAX,8
  LOOP    @2
  MOV   EAX,EBX
  MOV ECX,4
@3:
  STOSB
  SHR     EAX,8
  LOOP    @3
  POP     EDI     {Restore registers}
  POP     EBX
end;

function IsCpuIDAvailable: Boolean; register;
asm
	pushfd							{direct access to flags no possible, only via stack}
  pop     eax 				{flags to EAX}
  mov     edx,eax			{save current flags}
  xor     eax,id_bit	{not ID bit}
  push    eax					{onto stack}
  popfd								{from stack to flags, with not ID bit}
  pushfd							{back to stack}
  pop     eax					{get back to EAX}
  xor     eax,edx			{check if ID bit affected}
  jz      @exit				{no, CpuID not availavle}
  mov     al,True			{Result=True}
@exit:
end;

function GetCpuID: TCpuID; assembler; register;
asm
  push    ebx         {Save affected register}
  push    edi
  mov     edi,eax     {@Result}
  mov     eax,1
  dw      $a20f       {CpuID Command}
  stosd			          {CpuID[1]}
  mov     eax,ebx
  stosd               {CpuID[2]}
  mov     eax,ecx
  stosd               {CpuID[3]}
  mov     eax,edx
  stosd               {CpuID[4]}
  pop     edi					{Restore registers}
  pop     ebx
end;

procedure CheckMMXSSE;
asm
  push    ebx
  pushfd
  pop     eax
  mov     edx, eax
  xor     edx, $200000
  push    eax
  popfd
  pushfd
  pop     eax
  cmp     eax, edx
  jz      @Exit {No CPUID Support}
  mov     eax, 0 {Check for Get Fetures Support}
//  cpuid {Get highest supported cpuid fuction into eax}
  dw      $a20f       {CpuID Command}
  jz      @Exit {No support for getting CPU features}
  mov     eax, 1
//  cpuid {Get feature bits into edx}
  dw      $a20f       {CpuID Command}
  test    edx, (1 shl 23) {Test for MMX Support}
  setnz   EnableMMX
  test    edx, (1 shl 25) {Test for SSE Support}
  setnz   EnableSSE
@Exit:
  pop     ebx
end;

procedure DetectCpuType;
var
  P3Array                     : array[0..3] of Integer;     // Family : 6
  P4Array                     : array[0..2] of Integer;     // Family : 15
  XPArray                     : array[0..2] of Integer;     // Family : 6
  OpteronArray                : array[0..0] of Integer;     // Family : 15
  PrescottArray               : array[0..0] of Integer;     // Family : 15
  i                           : Integer;
begin
  CpuType := ctUnknown;

  VendorID:=GetCPUVendor();
  CPUVendor:=cvUnknown;
  if VendorID = 'AuthenticAMD' then
    CPUVendor:=cvAMD;
  if VendorID = 'GenuineIntel' then
    CPUVendor:=cvIntel;

  if CpuVendor=cvAMD then
  begin
    XPArray[0] := 6;                                          // 0110
    XPArray[1] := 8;                                          // 1000
    XPArray[2] := 10;                                         // 1010
    if Family = 6 then
      for i := Low(XPArray) to High(XPArray) do
        if Model = XPArray[i] then begin
          CpuType := ctXP;
          Exit;
        end;
  
    OpteronArray[0] := 5;                                     // 0101
    if Family = 15 then
      for i := Low(OpteronArray) to High(OpteronArray) do
        if Model = OpteronArray[i] then begin
          CpuType := ctOpteron;
          Exit;
        end;
  end
  else
  if CpuVendor=cvIntel then
  begin
    P3Array[0] := 7;                                          // 0111
    P3Array[1] := 8;                                          // 1000
    P3Array[2] := 10;                                         // 1010
    P3Array[3] := 11;                                         // 1011
    if Family = 6 then
      for i := Low(P3Array) to High(P3Array) do
        if Model = P3Array[i] then begin
          CpuType := ctP3;
          Exit;
        end;
  
    P4Array[0] := 0;                                          // 0000
    P4Array[1] := 1;                                          // 0001
    P4Array[2] := 2;                                          // 0010
    if Family = 15 then
      for i := Low(P4Array) to High(P4Array) do
        if Model = P4Array[i] then begin
          CpuType := ctP4;
          Exit;
        end;
  
    PrescottArray[0] := 3;                                    // 0011
    if Family = 15 then
      for i := Low(PrescottArray) to High(PrescottArray) do
        if Model = PrescottArray[i] then begin
          CpuType := ctPrescott;
          Exit;
        end;
  end;
end;

procedure DeclareCpu;
var
  CpuID                       : TCpuID;
  i                           : Integer;
begin
  try
    CheckMMXSSE;
    for i := Low(CpuID) to High(CpuID) do CpuID[i] := -1;
    if IsCpuIDAvailable then begin
      CpuID := GetCpuID;
      Family := (CpuID[1] shr 8 and $F);
      Model := (CpuID[1] shr 4 and $F);
    end;
    DetectCpuType;
  except
    Family := -1;
    Model := -1;
    CpuType := ctUnknown;
    EnableMMX := False;
    EnableSSE := False;
  end;
end;

initialization
  DeclareCpu;
end.







