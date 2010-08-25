{##############################################################################}
{# NexusDB: nxllMemoryManager.pas 2.00                                        #}
{# NexusDB Memory Manager: nxllMemoryManager.pas 2.03                         #}
{# Portions Copyright (c) Thorsten Engler 2001-2002                           #}
{# Portions Copyright (c) Real Business Software Pty. Ltd. 2002-2003          #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Interface for NexusDB Memory Management                           #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllMemoryManager;

interface

uses
  nxllFastFillChar,
{$IFDEF NX_MEMMANTRIAL}
  mmSystem,
{$endif}
  nxllTypes;

type
  TnxObject = class(TObject)
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

  TnxInterfacedObject = class(TnxObject, InxInterface)
  protected
    ioRefCount  : Integer;
    ioKeepAlive : Boolean;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure ioDeactivate; virtual;
  public
    constructor Create(aKeepAlive : Boolean = False);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;

    procedure Free;

    property RefCount: Integer
      read ioRefCount;
  end;

  TnxBlockPool = class(TObject)
    function Alloc: Pointer; register;
    procedure Dispose(var P{: Pointer}); register;
  end;

  TnxMemoryPool = class(TObject)
    function Alloc: Pointer; register;
    procedure Dispose(var P{: Pointer}); register;
    procedure DisposeDirect(P: Pointer); register;
  end;

procedure nxFreeMem(var P); register;

procedure nxGetMem(var P; Size : TnxMemSize); register; overload;
function nxGetMem(Size : TnxMemSize): Pointer; register; overload;

procedure nxGetZeroMem(var P; Size : TnxMemSize); register; overload;
function nxGetZeroMem(Size : TnxMemSize): Pointer; register; overload;

procedure nxReallocMem(var P; NewSize: TnxMemSize); register;

function nxGetPool(Size : TnxMemSize)
                        : TnxMemoryPool; register;
function nxGetAllocSize(P : Pointer)
                          : Integer; register;
function nxGetHeapStatus: THeapStatus; register;

var
  _nxMemoryManager : TMemoryManager;

  BlockPools : array[TnxBlockSize] of TnxBlockPool;
  EmptyBlock : Pointer; {empty 64kB block, read-only}

const
  _BlockSizes : array[TnxBlockSize] of TnxWord32 = (
     4 * 1024,
     8 * 1024,
    16 * 1024,
    32 * 1024,
    64 * 1024);

procedure nxFreeAndNil(var Obj);

implementation

uses
  Windows,
  nxllLockedFuncs,
  nxllMemoryManagerImpl;

{===TnxObject==================================================================}
class function TnxObject.NewInstance: TObject;
asm
   push  ebx
   mov   ebx, eax
//   mov   dword ptr eax, [eax + vmtInstanceSize]
   db    $8B, $40, $D8
   call  [_nxMemoryManager.GetMem]
   test  eax, eax
   jnz  @@GetMemOk

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}

  @@GetMemOk:
   mov   edx, eax
   mov   eax, ebx
   pop   ebx
   jmp   TObject.InitInstance
end;
{------------------------------------------------------------------------------}
procedure TnxObject.FreeInstance;
asm
  push eax
  call TObject.CleanupInstance
  pop  eax
  jmp  _nxMemoryManager.FreeMem
end;
{==============================================================================}



{===TnxInterfacedObject========================================================}
function TnxInterfacedObject._AddRef: Integer;
begin
  Result := LockedInc(ioRefCount);
end;
{------------------------------------------------------------------------------}
function TnxInterfacedObject._Release: Integer;
begin
  Result := LockedDec(ioRefCount);
  if (Result = 0) and not ioKeepAlive then
    Destroy;
end;
{------------------------------------------------------------------------------}
procedure TnxInterfacedObject.AfterConstruction;
{begin
  LockedDec(ioRefCount);
end;}
asm
  lock dec dword ptr [eax + ioRefCount]
end;
{------------------------------------------------------------------------------}
procedure TnxInterfacedObject.BeforeDestruction;
{$IFNDEF DCC6OrLater}
type
  TErrorProc = procedure(ErrorCode: Integer; ErrorAddr: Pointer);
{$ENDIF}
begin
  if ioRefCount <> 0 then
    {$IFDEF DCC6OrLater}
    ErrorProc(Ord(reInvalidPtr), nil);
    {$ELSE}
    TErrorProc(ErrorProc)(2, nil);
    {$ENDIF}
end;
{------------------------------------------------------------------------------}
constructor TnxInterfacedObject.Create(aKeepAlive: Boolean);
begin
  ioKeepAlive := aKeepAlive;
end;
{------------------------------------------------------------------------------}
procedure TnxInterfacedObject.Free;
begin
  if not Assigned(Self) then
    Exit;
  _AddRef;
  if ioKeepAlive then begin
    ioDeactivate;
    ioKeepAlive := False;
  end;
  _Release;
end;
{------------------------------------------------------------------------------}
procedure TnxInterfacedObject.ioDeactivate;
begin
end;
{------------------------------------------------------------------------------}
class function TnxInterfacedObject.NewInstance: TObject;
asm
   push  ebx
   mov   ebx, eax
//   mov   dword ptr eax, [eax + vmtInstanceSize]
   db    $8B, $40, $D8
   call  [_nxMemoryManager.GetMem]
   test  eax, eax
   jnz  @@GetMemOk

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}

  @@GetMemOk:
   mov   edx, eax
   mov   eax, ebx
   pop   ebx
   call  TObject.InitInstance

   mov   dword [eax + ioRefCount], 1
end;
{------------------------------------------------------------------------------}
function TnxInterfacedObject.QueryInterface(const IID: TGUID;
                                              out Obj)
                                                     : HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;
{==============================================================================}



{==============================================================================}
var
  _nxGetPool       : Pointer;
  _nxGetAllocSize  : Pointer;
  _nxGetHeapStatus : Pointer;
{------------------------------------------------------------------------------}
procedure nxFreeMem(var P);
asm
   xor       ecx, ecx
   xchg      [eax], ecx
   test      ecx, ecx
   jz       @@Exit

   mov       eax, ecx
   call      [_nxMemoryManager.FreeMem]
   test      eax, eax
   jz       @@Exit

  {$IFNDEF DCC6OrLater}
   mov   al, 2 {reInvalidPtr}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reInvalidPtr
   jmp   System.Error
  {$ENDIF}

  @@Exit:
end;
{------------------------------------------------------------------------------}
procedure nxGetMem(var P; Size : TnxMemSize);
asm
   xchg  eax, edx

   test  eax, eax
   jz   @@Exit

   push  edx
   call  [_nxMemoryManager.GetMem]
   pop   edx

   test  eax, eax
   jnz  @@Exit

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}

  @@Exit:
   mov   [edx], eax
end;
{------------------------------------------------------------------------------}
function nxGetMem(Size : TnxMemSize): Pointer;
asm
   test  eax, eax
   jz   @@Exit

   call  [_nxMemoryManager.GetMem]

   test  eax, eax
   jnz  @@Exit

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}
  @@Exit:
end;
{------------------------------------------------------------------------------}
procedure nxGetZeroMem(var P; Size : TnxMemSize);
asm
   xchg  eax, edx

   test  eax, eax
   jz   @@Exit

   push  edx
   push  eax
   call  [_nxMemoryManager.GetMem]

   test  eax, eax
   jnz  @@FillChar

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}

  @@FillChar:
   pop   edx
   pop   ecx
   mov   [ecx], eax
   xor   ecx, ecx
   jmp   [nxFillChar]
  @@Exit:
   mov   [edx], eax
end;
{------------------------------------------------------------------------------}
function nxGetZeroMem(Size : TnxMemSize): Pointer; register; overload;
asm
   test  eax, eax
   jz   @@Exit

   push  eax
   call  [_nxMemoryManager.GetMem]

   test  eax, eax
   jnz  @@FillChar

  {$IFNDEF DCC6OrLater}
   mov   al, 1 {reOutOfMemory}
   jmp   System.@RunError
  {$ELSE}
   mov   al, reOutOfMemory
   jmp   System.Error
  {$ENDIF}

  @@FillChar:
   pop   edx
   xor   ecx, ecx
   push  eax
   call  [nxFillChar]
   pop   eax
  @@Exit:
end;
{------------------------------------------------------------------------------}
procedure nxReallocMem(var P; NewSize: TnxMemSize);
asm
        mov     ecx,[eax]
        test    ecx,ecx
        je      @@alloc
        test    edx,edx
        je      @@free
@@resize:
        push    eax
        mov     eax,ecx
        call    _nxMemoryManager.ReallocMem
        pop     ecx
        or      eax,eax
        je      @@allocerror
        mov     [ecx],eax
        ret
@@freeerror:
        {$IFNDEF DCC6OrLater}
         mov   al, 2 {reinvalidptr}
         jmp   System.@RunError
        {$ELSE}
         mov   al, reinvalidptr
         jmp   System.Error
        {$ENDIF}
@@free:
        mov     [eax],edx
        mov     eax,ecx
        call    _nxMemoryManager.FreeMem
        or      eax,eax
        jne     @@freeerror
        ret
@@allocerror:
        {$IFNDEF DCC6OrLater}
         mov   al, 1 {reoutofmemory}
         jmp   System.@RunError
        {$ELSE}
         mov   al, reoutofmemory
         jmp   System.Error
        {$ENDIF}
@@alloc:
        test    edx,edx
        je      @@exit
        push    eax
        mov     eax,edx
        call    _nxMemoryManager.GetMem
        pop     ecx
        or      eax,eax
        je      @@allocerror
        mov     [ecx],eax
@@exit:
end;
{------------------------------------------------------------------------------}
function  nxGetPool(Size : TnxMemSize): TnxMemoryPool; register;
asm
  jmp [_nxGetPool]
end;
{------------------------------------------------------------------------------}
function nxGetAllocSize(P : Pointer)
                          : Integer;
asm
  jmp [_nxGetAllocSize]
end;
{------------------------------------------------------------------------------}
function nxGetHeapStatus: THeapStatus;
asm
  jmp [_nxGetHeapStatus]
end;
{==============================================================================}



{==============================================================================}
procedure nxFreeAndNil(var Obj);
asm
       xor  ecx, ecx
  lock xchg [eax], ecx
       mov  eax, ecx
       test eax, eax
       jnz  TObject.Free
end;
{==============================================================================}



{===nxMemoryManager============================================================}
function nxMemoryManager: TMemoryManager;
begin
  Result := _nxMemoryManager;
end;
{==============================================================================}



{===TnxBlockPool==============================================================}
var
  _TnxBlockPool_Alloc   : Pointer;
  _TnxBlockPool_Dispose : Pointer;
{------------------------------------------------------------------------------}
function TnxBlockPool.Alloc: Pointer;
asm
  jmp [_TnxBlockPool_Alloc]
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.Dispose(var P{: Pointer});
asm
  jmp [_TnxBlockPool_Dispose]
end;
{==============================================================================}



{===TnxMemoryPool==============================================================}
var
  _TnxMemoryPool_Alloc         : Pointer;
  _TnxMemoryPool_Dispose       : Pointer;
  _TnxMemoryPool_DisposeDirect : Pointer;
{------------------------------------------------------------------------------}
function TnxMemoryPool.Alloc: Pointer;
asm
  jmp [_TnxMemoryPool_Alloc]
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.Dispose(var P{: Pointer});
asm
  jmp [_TnxMemoryPool_Dispose]
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.DisposeDirect(P: Pointer);
asm
  jmp [_TnxMemoryPool_DisposeDirect]
end;
{==============================================================================}



{==============================================================================}
procedure BinToHex(Buffer, Text: PChar; BufSize: Integer); assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB      '0123456789ABCDEF'
@@1:    LODSB
        MOV     DL,AL
        AND     DL,0FH
        MOV     AH,@@0.Byte[EDX]
        MOV     DL,AL
        SHR     DL,4
        MOV     AL,@@0.Byte[EDX]
        STOSW
        DEC     ECX
        JNE     @@1
        POP     EDI
        POP     ESI
end;
{------------------------------------------------------------------------------}
var
  FileMappingHandle : THandle;
{------------------------------------------------------------------------------}
procedure Init;
type
  PnxShareMemRec = ^TnxShareMemRec;
  TnxShareMemRec = packed record
    InitOk            : Integer;
    MemoryManagerImpl : PnxMemoryManagerImpl;
  end;
var
  ProcessID         : Cardinal;
  FileMappingName   : array[0..20] of Char;
  p                 : PnxShareMemRec;
  MemoryManagerImpl : PnxMemoryManagerImpl;
begin
  MemoryManagerImpl := nil;

  ProcessID := GetCurrentProcessId;
  FileMappingName := '__NexusMM2__';
  BinToHex(@ProcessID, @FileMappingName[12], 4);
  FileMappingName[20] := #0;

  FileMappingHandle := CreateFileMapping(
    INVALID_HANDLE_VALUE,
    nil,
    PAGE_READWRITE,
    0, 1024,
    @FileMappingName);

  if FileMappingHandle = 0 then
    {$IFNDEF DCC6OrLater}
    System.RunError(2 {reInvalidPtr});
    {$ELSE}
    System.Error(reInvalidPtr);
    {$ENDIF}

  case GetLastError of
    ERROR_ALREADY_EXISTS: begin

      p := MapViewOfFile(
        FileMappingHandle,
        FILE_MAP_WRITE,
        0, 0,
        1024);

      if not Assigned(p) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}

      while LockedCompareExchange(p.InitOk, 1, 1) <> 1 do
        Sleep(10);

      MemoryManagerImpl := p.MemoryManagerImpl;

      if not UnmapViewOfFile(p) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}

      if not CloseHandle(FileMappingHandle) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}

      FileMappingHandle := INVALID_HANDLE_VALUE;
    end;
    ERROR_SUCCESS: begin

      MemoryManagerImpl := InitMemoryManager;

      p := MapViewOfFile(
        FileMappingHandle,
        FILE_MAP_WRITE,
        0, 0,
        1024);

      if not Assigned(p) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}

      p.MemoryManagerImpl := MemoryManagerImpl;
      LockedExchange(p.InitOk, 1);

      if not UnmapViewOfFile(p) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}
    end;
  else
    {$IFNDEF DCC6OrLater}
    System.RunError(2 {reInvalidPtr});
    {$ELSE}
    System.Error(reInvalidPtr);
    {$ENDIF}
  end;

  with MemoryManagerImpl^ do begin
    _nxMemoryManager := __MemoryManager;
    _nxGetPool := __GetPool;
    _nxGetAllocSize := __GetAllocSize;
    _nxGetHeapStatus := __GetHeapStatus;

    Assert(SizeOf(BlockPools) = SizeOf(__BlockPools));
    Move(__BlockPools, BlockPools, SizeOf(BlockPools));
    EmptyBlock := __EmptyBlock;

    _TnxBlockPool_Alloc := __TnxBlockPool_Alloc;
    _TnxBlockPool_Dispose := __TnxBlockPool_Dispose;

    _TnxMemoryPool_Alloc := __TnxMemoryPool_Alloc;
    _TnxMemoryPool_Dispose := __TnxMemoryPool_Dispose;
    _TnxMemoryPool_DisposeDirect := __TnxMemoryPool_DisposeDirect;
  end;
end;
{------------------------------------------------------------------------------}
procedure Done;
begin
  if FileMappingHandle <> INVALID_HANDLE_VALUE then begin
    CloseHandle(FileMappingHandle);
  end;
  FileMappingHandle := INVALID_HANDLE_VALUE;
end;
{==============================================================================}


{$IFDEF NX_MEMMANTRIAL}
  {$i Trial\nxmemmantrial.inc}
{$endif}

initialization
  Init;
  {$IFDEF NX_MEMMANTRIAL}
    {$i Trial\nxMemManTrial2.inc}
  {$ENDIF}
finalization
  Done;
end.
