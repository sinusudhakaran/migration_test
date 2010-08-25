{##############################################################################}
{# NexusDB: nxllMemoryManagerImpl.pas 2.00                                    #}
{# NexusDB Memory Manager: nxllMemoryManagerImpl.pas 2.03                     #}
{# Portions Copyright (c) Thorsten Engler 2001-2002                           #}
{# Portions Copyright (c) Real Business Software Pty. Ltd. 2002-2003          #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Implementation of NexusDB Memory Management                       #}
{##############################################################################}

{$I nxDefine.inc}
{.$DEFINE NX_DEBUG_MEMORYMANAGER_CLEARONFREE}
{.$DEFINE NX_DEBUG_MEMORYMANAGER_SEPERATEBLOCKS}
{.$DEFINE NX_DEBUG_MEMORYMANAGER_ADDR_CHECK}

unit nxllMemoryManagerImpl;

interface

uses
  nxllTypes;

const
  nxcNexusMM2Hook = 'NexusMM2Hook';

type
  PnxMemoryManagerImpl = ^TnxMemoryManagerImpl;
  TnxMemoryManagerImpl = record
    __MemoryManager               : TMemoryManager;
    __GetPool                     : Pointer;
    __GetAllocSize                : Pointer;
    __GetHeapStatus               : Pointer;

    __BlockPools                  : array[TnxBlockSize] of Pointer;
    __EmptyBlock                  : Pointer;

    __TnxBlockPool_Alloc          : Pointer;
    __TnxBlockPool_Dispose        : Pointer;

    __TnxMemoryPool_Alloc         : Pointer;
    __TnxMemoryPool_Dispose       : Pointer;
    __TnxMemoryPool_DisposeDirect : Pointer;
  end;

  TBeforeGetMem = procedure(var aSize: Integer); register;
  TAfterGetMem = procedure(aSize: Integer; var p: Pointer); register;

  TBeforeFreeMem = procedure(var p: Pointer); register;

  TBeforeReallocMem = procedure(var p: Pointer; var aSize: Integer); register;
  TAfterReallocMem = procedure(aSize: Integer; var p: Pointer); register;

  TBeforeGetAllocSize = procedure(var p: Pointer); register;
  TAfterGetAllocSize = procedure(p: Pointer; var aSize: Integer); register;

  TAfterBlockPoolAlloc = procedure(p: Pointer); register;
  TBeforeBlockPoolDispose = procedure(p: Pointer); register;

  TBeforeGetPool = procedure(var aSize: Integer); register;
  TAfterMemoryPoolAlloc = procedure(aSize: Integer; var p: Pointer); register;
  TBeforeMemoryPoolDispose = procedure(var p: Pointer); register;

function InitMemoryManager: PnxMemoryManagerImpl;

implementation

uses
  Windows,
  nxllFastMove,
  nxllFastFillChar,
  nxllLockedFuncs;

const
  nxcl_1KB                        = 1024;
  nxcl_1MB                        = 1024 * nxcl_1KB;

  nxcl_SystemPageSize             =  4 * nxcl_1KB;
  nxcl_SystemAllocationSize       = 64 * nxcl_1KB;
  nxcl_AllocGranularity           =  8;
  nxcl_AllocGranularityUnpaged    = 32;
  nxcl_AllocGranularityUnfreeable = 32;

var
  _MemoryManagerInitialized : Boolean = False;

  _ReservedAddressSpace     : Cardinal;
  _CommitedMemory           : Cardinal;

  _CommitedOverhead         : Cardinal;

  _BeforeGetMem             : TBeforeGetMem;
  _AfterGetMem              : TAfterGetMem;

  _BeforeFreeMem            : TBeforeFreeMem;

  _BeforeReallocMem         : TBeforeReallocMem;
  _AfterReallocMem          : TAfterReallocMem;

  _BeforeGetAllocSize       : TBeforeGetAllocSize;
  _AfterGetAllocSize        : TAfterGetAllocSize;

  _AfterBlockPoolAlloc      : TAfterBlockPoolAlloc;
  _BeforeBlockPoolDispose   : TBeforeBlockPoolDispose;

  _BeforeGetPool            : TBeforeGetPool;
  _AfterMemoryPoolAlloc     : TAfterMemoryPoolAlloc;
  _BeforeMemoryPoolDispose  : TBeforeMemoryPoolDispose;
{------------------------------------------------------------------------------}


{===nxFreeAndNil=================================================================}
procedure nxFreeAndNil(var Obj);
asm
       xor  ecx, ecx
  lock xchg [eax], ecx
       mov  eax, ecx
       jmp  TObject.Free
end;
{==============================================================================}



{===Unpaged low level allocator================================================}
var
  UnpagedPool                : Pointer;
  CurrentUnpagedPoolPosition : Pointer;
{------------------------------------------------------------------------------}
function AllocUnpaged(aSize : Cardinal)
                            : Pointer;
var
  p                         : Pointer;
  i                         : Cardinal;
begin
  { Is the pool already reserved? }
  if UnpagedPool = nil then begin
    { No. Allocate it. }
    p := VirtualAlloc(nil, nxcl_1MB, MEM_RESERVE, PAGE_NOACCESS);
    if p = nil then
      {$IFNDEF DCC6OrLater}
      System.RunError(1 {reOutOfMemory});
      {$ELSE}
      System.Error(reOutOfMemory);
      {$ENDIF}

    { Did another thread already initialize the UnpagedPool? }
    if LockedCompareExchange(UnpagedPool, p, nil) <> nil then begin
      { Yes. Release our address range again. }
      if not VirtualFree(p, 0, MEM_RELEASE) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}
    end else begin
      CurrentUnpagedPoolPosition := UnpagedPool;
      LockedAdd(_ReservedAddressSpace, nxcl_1MB);
    end;
  end;

  if CurrentUnpagedPoolPosition = nil then
    { Wait until the other thread has set CurrentUnpagedPoolPosition. }
    while LockedCompareExchange(CurrentUnpagedPoolPosition, nil, nil) = nil do
      Sleep(1);

  { Round up to the next allocation boundary. }
  aSize := ((aSize div nxcl_AllocGranularityUnpaged) +
    Cardinal(Ord((aSize mod nxcl_AllocGranularityUnpaged) <> 0))) * nxcl_AllocGranularityUnpaged;

  { Threadsafe increase the CurrentUnpagedPoolPosition. }
  repeat
    Result := CurrentUnpagedPoolPosition;
    p := Pointer(Cardinal(Result) + aSize);
  until LockedCompareExchange(CurrentUnpagedPoolPosition,
    p, Result) = Result;

  { Ensure that the memory is commited. }

  if VirtualAlloc(Result, aSize, MEM_COMMIT, PAGE_READWRITE) = nil then
    {$IFNDEF DCC6OrLater}
    System.RunError(1 {reOutOfMemory});
    {$ELSE}
    System.Error(reOutOfMemory);
    {$ENDIF}

  i :=
    (Cardinal(p) div nxcl_SystemPageSize) -
    (Cardinal(Result) div nxcl_SystemPageSize);

  if Result = UnpagedPool then
    Inc(i);

  if i > 0 then begin
    LockedAdd(_CommitedMemory, i * nxcl_SystemPageSize);
    LockedAdd(_CommitedOverhead, i * nxcl_SystemPageSize);
  end;

  { lock it in place. }
  VirtualLock(Result, aSize);
end;
{------------------------------------------------------------------------------}
procedure FinalizeUnpagedPool;
begin
  CurrentUnpagedPoolPosition := nil;

  if Assigned(UnpagedPool) then begin
    VirtualUnlock(UnpagedPool, nxcl_1MB);
    if not VirtualFree(UnpagedPool, 0, MEM_RELEASE) then
      {$IFNDEF DCC6OrLater}
      System.RunError(2 {reInvalidPtr});
      {$ELSE}
      System.Error(reInvalidPtr);
      {$ENDIF}
    UnpagedPool := nil;
  end;
end;
{==============================================================================}



{===TnxUnpagedObject===========================================================}
type
  TnxUnpagedObject = class(TObject)
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
procedure TnxUnpagedObject.FreeInstance;
begin
  CleanupInstance;
  { Can't free these objects... }
end;
{------------------------------------------------------------------------------}
class function TnxUnpagedObject.NewInstance: TObject;
begin
  Result := InitInstance(AllocUnpaged(InstanceSize));
end;
{==============================================================================}



{===TnxUnpagedThreadSafeStack==================================================}
type
  TAllocPageFunc = function(aSize : Cardinal): Pointer;

  TnxUnpagedThreadSafeStack = class(TnxUnpagedObject)
  protected {private}
    { implict pointer to class, 4 byte}
    tssReserved1 : Cardinal;     {filler to ensure alignment}
    tssFreeHead  : TnxListHead;  {make sure this is 8 byte aligned!}
    tssStackHead : TnxListHead;  {make sure this is 8 byte aligned!}
  protected
    AllocPage    : TAllocPageFunc;
    procedure tssAllocBlock;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Push(p: Pointer); register;
    function Pop: Pointer; register;
  end;
{------------------------------------------------------------------------------}
var
  _AllocPage: TAllocPageFunc = AllocUnpaged;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
constructor TnxUnpagedThreadSafeStack.Create;
begin
  AllocPage := _AllocPage;
  inherited Create;
end;
{------------------------------------------------------------------------------}
destructor TnxUnpagedThreadSafeStack.Destroy;
begin
  inherited Destroy;
  LockedFlushSList(@tssFreeHead);
  LockedFlushSList(@tssStackHead);
end;
{------------------------------------------------------------------------------}
function TnxUnpagedThreadSafeStack.Pop: Pointer;
asm
        push      ebx
        push      esi
        push      edi

        mov       esi, eax
  { esi = Self}

        mov       edx, [esi + tssStackHead.lhSequence]
        mov       eax, [esi + tssStackHead.lhFirst]
  @@loop1:
        or        eax, eax
        jz       @@Exit
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + tssStackHead]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop1

   { eax = item from stack }
        mov       edi, [eax + TnxStackEntry.seData]
   { edi = content of item from stack = result }

        mov       ebx, eax
   { ebx = empty item add to tssFreeHead}

        mov       edx, [esi + tssFreeHead.lhSequence]
        mov       eax, [esi + tssFreeHead.lhFirst]
  @@loop2:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + tssFreeHead]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop2

        mov       eax, edi
   { eax = content of item from stack = result }

  @@Exit:
   { cleanup and get out of here }
        pop       edi
        pop       esi
        pop       ebx
end;
{------------------------------------------------------------------------------}
procedure TnxUnpagedThreadSafeStack.Push(p: Pointer);
asm
        push      ebx
        push      esi
        push      edi

        mov       esi, eax
        mov       edi, edx
  { esi = Self, edi = p}

  @@AcquireFree:
        mov       edx, [esi + tssFreeHead.lhSequence]
        mov       eax, [esi + tssFreeHead.lhFirst]
  @@loop1:
        or        eax, eax
        jz       @@AllocBlock
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + tssFreeHead]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop1

   { eax = newly acquired free item }

        mov       [eax + TnxStackEntry.seData], edi
        mov       ebx, eax

   { ebx = item with seData Assigned to p, add to tssStackHead}

        mov       edx, [esi + tssStackHead.lhSequence]
        mov       eax, [esi + tssStackHead.lhFirst]
  @@loop2:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + tssStackHead]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop2

   { cleanup and get out of here }
        pop       edi
        pop       esi
        pop       ebx

        ret

  @@AllocBlock:
        mov       eax, esi
        call      TnxUnpagedThreadSafeStack.tssAllocBlock
        jmp      @@AcquireFree
end;
{------------------------------------------------------------------------------}
procedure TnxUnpagedThreadSafeStack.tssAllocBlock;
var
  p, q                        : PnxStackEntry;
  i                           : Integer;
begin
  p := AllocPage(4 * nxcl_1KB);

  q := p;

  { Fill the rest of the page with 8 byte items. Each pointing to the next item.
    The last will be used to link to the item pointed to by tssFreeHead.
    Counting downward is faster. }
  for i := (nxcl_1KB div 8) - 2 downto 0 do begin
    q^.seListEntry.leNext := Pointer(Cardinal(q) + SizeOf(TnxStackEntry));
    Inc(q);
  end;

  { p should now point to the first item. q should point to the last item. }

  { Insert our items into the free list. The head must point to our first item.
    Our last item must point to the current head. }
  LockedPushEntriesSList(@tssFreeHead, Pointer(p), Pointer(q));
end;
{==============================================================================}



{===Chunk Allocator============================================================}
function AllocUnfreeable(aSize: Cardinal): Pointer; forward;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
var
  AvailableChunks : TnxUnpagedThreadSafeStack;
  FailedCunks     : TnxUnpagedThreadSafeStack;
  AllocatedCunks  : TnxUnpagedThreadSafeStack;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
procedure PrepareChunkAllocator;
var
  j : Integer;
  P : Pointer;
begin
  AvailableChunks := TnxUnpagedThreadSafeStack.Create;
  FailedCunks := TnxUnpagedThreadSafeStack.Create;
  AllocatedCunks := TnxUnpagedThreadSafeStack.Create;

  for j := 3 * 1024 downto 1 do begin
    p := Pointer(j shl 20);

    if Assigned(VirtualAlloc(p, nxcl_1MB, MEM_RESERVE, PAGE_NOACCESS)) then begin
      VirtualFree(p, 0, MEM_RELEASE);
      AvailableChunks.Push(p);
      AvailableChunks.AllocPage := AllocUnfreeable;
      FailedCunks.AllocPage := AllocUnfreeable;
      _AllocPage := AllocUnfreeable;
    end;
  end;
end;
{------------------------------------------------------------------------------}
procedure FinalizeChunkAllocator;
var
  p: Pointer;
begin
  nxFreeAndNil(FailedCunks);
  nxFreeAndNil(AvailableChunks);

  p := AllocatedCunks.Pop;
  while Assigned(p) do begin
    if not VirtualFree(p, 0, MEM_RELEASE) then
      {$IFNDEF DCC6OrLater}
      System.RunError(2 {reInvalidPtr});
      {$ELSE}
      System.Error(reInvalidPtr);
      {$ENDIF}
    p := AllocatedCunks.Pop;
  end;

  nxFreeAndNil(AllocatedCunks);
end;
{------------------------------------------------------------------------------}
function ReserveChunk: Pointer;
var
  p                           : Pointer;
begin
  Result := nil;

  p := AvailableChunks.Pop;
  while Assigned(p) do begin
    Result := VirtualAlloc(p, nxcl_1MB, MEM_RESERVE, PAGE_NOACCESS);
    if Result = nil then
      FailedCunks.Push(p)
    else
      break;
    p := AvailableChunks.Pop;
  end;

  if not Assigned(p) then begin
    p := FailedCunks.Pop;
    while Assigned(p) do begin
      AvailableChunks.Push(p);
      p := FailedCunks.Pop;
    end;

    p := AvailableChunks.Pop;
    while Assigned(p) do begin
      Result := VirtualAlloc(p, nxcl_1MB, MEM_RESERVE, PAGE_NOACCESS);
      if Result = nil then
        FailedCunks.Push(p)
      else
        break;
      p := AvailableChunks.Pop;
    end;
  end;

  if not Assigned(Result) then
    {$IFNDEF DCC6OrLater}
    System.RunError(1 {reOutOfMemory});
    {$ELSE}
    System.Error(reOutOfMemory);
    {$ENDIF}

  LockedAdd(_ReservedAddressSpace, nxcl_1MB);
end;
{------------------------------------------------------------------------------}
procedure ReleaseChunk(p : Pointer);
begin
  if not VirtualFree(p, 0, MEM_RELEASE) then
    {$IFNDEF DCC6OrLater}
    System.RunError(2 {reInvalidPtr});
    {$ELSE}
    System.Error(reInvalidPtr);
    {$ENDIF}

  AvailableChunks.Push(p);
  LockedSub(_ReservedAddressSpace, nxcl_1MB);
end;
{==============================================================================}



{===Unfreeable low level allocator================================================}
var
  CurrentUnfreeablePoolPosition         : Pointer;
{------------------------------------------------------------------------------}
function AllocUnfreeable(aSize: Cardinal): Pointer;
var
  p                           : Pointer;
  i                           : Cardinal;
begin
  //Result:= nil;
  repeat
    { Is the pool already reserved? }
    if CurrentUnfreeablePoolPosition = nil then begin
      { No. Allocate it. }
      p := ReserveChunk;

      { Did another thread already initialize the UnfreeablePool? }
      if LockedCompareExchange(CurrentUnfreeablePoolPosition, p, nil) <> nil then
        { Yes. Release our address range again. }
        ReleaseChunk(p)
      else
        AllocatedCunks.Push(p);
    end;

    { Round up to the next allocation boundary. }
    aSize := ((aSize div nxcl_AllocGranularityUnfreeable) +
      Cardinal(Ord((aSize mod nxcl_AllocGranularityUnfreeable) <> 0))) * nxcl_AllocGranularityUnfreeable;

    { Threadsafe increase the CurrentUnfreeablePoolPosition. }
    repeat

      Result := CurrentUnfreeablePoolPosition;
      p := Pointer(Cardinal(Result) + aSize);

      if (Cardinal(Result) and $FFF00000) <> (Cardinal(p) and $FFF00000) then
        p := nil;

    until LockedCompareExchange(CurrentUnfreeablePoolPosition,
      p, Result) = Result;

    if not Assigned(P) then
      Result := nil;

    { Ensure that the memory is commited. }
    if Assigned(Result) then
      if VirtualAlloc(Result, aSize, MEM_COMMIT, PAGE_READWRITE) = nil then
        {$IFNDEF DCC6OrLater}
        System.RunError(1 {reOutOfMemory});
        {$ELSE}
        System.Error(reOutOfMemory);
        {$ENDIF}

  until Assigned(Result);

  i :=
    (Cardinal(p) div nxcl_SystemPageSize) -
    (Cardinal(Result) div nxcl_SystemPageSize);

  if (Cardinal(Result) and $000FFFFF) = 0 then
    Inc(i);

  if i > 0 then begin
    LockedAdd(_CommitedMemory, i * nxcl_SystemPageSize);
    LockedAdd(_CommitedOverhead, i * nxcl_SystemPageSize);
  end;
end;
{==============================================================================}



{===TnxBlockPool===============================================================}
type
  TnxBlockPool = class;

  PnxBlockPoolChunkHeader = ^TnxBlockPoolChunkHeader;
  TnxBlockPoolChunkHeader = packed record
    bpchFreeListEntry : TnxListEntry;
    bpchBlockPool     : TnxBlockPool;                          {the block pool that owns this chunk}

    bpchFreeListHead  : TnxListHead;
    bpchStackListHead : TnxListHead;

    bpchFull          : Integer;                               {0 = contained in free list}

    bpchChunkBase     : Pointer;

    bpchBlockAddrMask : Cardinal;

    bpchReserved1     : Cardinal;
    bpchReserved2     : Cardinal;
    bpchReserved3     : Cardinal;
  end;

  TnxBlockPool = class(TnxUnpagedObject)
  protected                                                 {private}
    { implict pointer to class, 4 byte}
    bpPartialFreeChunkBool  : Cardinal;

    bpPartialFreeChunkHead1 : TnxListHead;               {make sure this is 8 byte aligned!}
    bpPartialFreeChunkHead2 : TnxListHead;               {make sure this is 8 byte aligned!}
    bpFreeChunkHead         : TnxListHead;               {make sure this is 8 byte aligned!}

    bpNeedCleanup           : Cardinal;

    bpPagesPerBlock         : Cardinal;
    bpBlocksPerChunk        : Cardinal;

    bpBlockSize             : Cardinal;
    bpHeaderSize            : Cardinal;

    bpCommitedItems         : TnxUnpagedThreadSafeStack;
    bpChunkHeaders          : TnxUnpagedThreadSafeStack;
  protected
    function bpAllocChunkHeader: PnxBlockPoolChunkHeader;

    function bpAllocChunk: PnxBlockPoolChunkHeader;
    procedure bpDisposeChunk(p: PnxBlockPoolChunkHeader);

    procedure bpInternalCleanup;
    procedure bpInternalRemoveUnusedItems;

    function bpAllocReservedBlock: Pointer;
    procedure bpDisposeReservedBlock(p : Pointer);
  public
    constructor Create(aPagesPerBlock: Cardinal);
    destructor Destroy; override;

    function Alloc: Pointer; register;
    procedure Dispose(var P: Pointer); register;

    class procedure Cleanup;
    class procedure RemoveUnusedItems;

    class procedure Prepare;
    class procedure Finalize;
  end;
const
  nxcl_BlockPoolChunkHeaderSize   = SizeOf(TnxBlockPoolChunkHeader);
var
  _BlockPools   : array[TnxBlockSize] of TnxBlockPool; {4K, 8K, 16K, 32K, 64K}
  _ChunkHeaders : array[0..Pred(4 * 1024)] of PnxBlockPoolChunkHeader;
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
function TnxBlockPool.Alloc: Pointer;
{$IFDEF NX_DEBUG_BUFFERMANAGER_PROTECT_READONLY}
var
  OldProtection : Cardinal;
{$ENDIF}
begin
  { Do we have a already commited page that can be reused? }
  Result := bpCommitedItems.Pop;
  if Assigned(Result) then begin
    { Yes. Get ride of the protection. }
    VirtualAlloc(Result, bpBlockSize, MEM_RESET, PAGE_READWRITE);

    {$IFDEF NX_DEBUG_BUFFERMANAGER_PROTECT_READONLY}
    if not VirtualProtect(Result, bpBlockSize, PAGE_READWRITE, OldProtection) then
      {$IFNDEF DCC6OrLater}
      System.RunError(2 {reInvalidPtr});
      {$ELSE}
      System.Error(reInvalidPtr);
      {$ENDIF}
    {$ENDIF}
    Exit;
  end;

  Result := bpAllocReservedBlock;
  Result := VirtualAlloc(Result, bpBlockSize, MEM_COMMIT, PAGE_READWRITE);
  if Result = nil then
    {$IFNDEF DCC6OrLater}
    System.RunError(1 {reOutOfMemory});
    {$ELSE}
    System.Error(reOutOfMemory);
    {$ENDIF}

  LockedAdd(_CommitedMemory, bpBlockSize);
end;
{------------------------------------------------------------------------------}
function _Hooked_TnxBlockPool_Alloc(Self : TnxBlockPool): Pointer; register;
begin
  Result := Self.Alloc;
  _AfterBlockPoolAlloc(Result);
end;
{------------------------------------------------------------------------------}
function TnxBlockPool.bpAllocChunk: PnxBlockPoolChunkHeader;
var
  p                           : Pointer;
  i                           : Integer;
  StackEntry                  : PnxStackEntry;
begin
  p := ReserveChunk;

  if not Assigned(p) then begin
    Result := nil;
    Exit;
  end;

  i := Cardinal(p) shr 20;
  Assert(not Assigned(_ChunkHeaders[i]));

  Result := bpAllocChunkHeader;
  _ChunkHeaders[i] := Result;

  if not Assigned(Result) then
    Exit;

  nxFillChar(Result^, SizeOf(Result^), 0);

  Result.bpchChunkBase := p;
  Result.bpchBlockPool := Self;
  Result.bpchBlockAddrMask := not Pred(bpBlockSize);

  StackEntry := Pointer(Cardinal(Result) + nxcl_BlockPoolChunkHeaderSize);
  Result.bpchStackListHead.lhFirst := Pointer(StackEntry);

  { Put the items in the reserved list. }
  for i := 1 to bpBlocksPerChunk do begin      
    {$IFDEF NX_DEBUG_MEMORYMANAGER_SEPERATEBLOCKS}
    if i mod 2 = 0 then
    {$ENDIF}                
    begin
      StackEntry.seData := p;
      StackEntry.seListEntry.leNext :=
        Pointer(Cardinal(StackEntry) + SizeOf(TnxStackEntry));

      StackEntry := Pointer(StackEntry.seListEntry.leNext);
    end;
    Inc(Cardinal(p), bpBlockSize);
  end;

  StackEntry := Pointer(Cardinal(StackEntry) - SizeOf(TnxStackEntry));
  StackEntry.seListEntry.leNext := nil;
end;
{------------------------------------------------------------------------------}
function TnxBlockPool.bpAllocChunkHeader: PnxBlockPoolChunkHeader;
begin
  Result := bpChunkHeaders.Pop;
  if not Assigned(Result) then
    Result := AllocUnfreeable(bpHeaderSize);    
end;
{------------------------------------------------------------------------------}
function TnxBlockPool.bpAllocReservedBlock: Pointer;
asm
        push      esi
        push      edi
        push      ebx
  { esi = Self }
        mov       esi, eax

  @@MainLoop:
  { threadsafe remove first entry from bpPartialFreeChunkHead and put it into eax }
        cmp       dword [esi + bpPartialFreeChunkBool], 0
        jne      @@LoadFromList2

        mov       edx, [esi + bpPartialFreeChunkHead1.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead1.lhFirst]
  @@loop1a:
        or        eax, eax
        jz       @@CheckFreeList
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop1a
        jmp      @@FoundChunk

  @@LoadFromList2:
        mov       edx, [esi + bpPartialFreeChunkHead2.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead2.lhFirst]
  @@loop1b:
        or        eax, eax
        jz       @@CheckFreeList
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop1b

  @@FoundChunk:
        cmp       [eax + TnxBlockPoolChunkHeader.bpchFreeListHead.lhFirst], 0
        jne       @@HeaderFound
  { eax = Header, Chunk completely empty, add to free list }

        mov       ebx, eax
        mov       edx, [esi + bpFreeChunkHead.lhSequence]
        mov       eax, [esi + bpFreeChunkHead.lhFirst]
  @@loop2:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpFreeChunkHead]
        db        $F0, $0F, $C7, $4E, $18
        jnz      @@loop2

        jmp      @@MainLoop

  @@CheckFreeList:
  { threadsafe remove first entry from bpFreeChunkHead and put it into eax }
        mov       edx, [esi + bpFreeChunkHead.lhSequence]
        mov       eax, [esi + bpFreeChunkHead.lhFirst]
  @@loop3:
        or        eax, eax
        jz       @@AllocChunk
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + bpFreeChunkHead]
        db        $F0, $0F, $C7, $4E, $18
        jnz      @@loop3
        jmp      @@HeaderFound
  @@AllocChunk:
        mov       eax, esi
        call      TnxBlockPool.bpAllocChunk
        cmp       eax, 0
        jnz      @@HeaderFound
  { eax = Result = nil }
        jmp      @@exit
  @@HeaderFound:
        mov       edi, eax
  { edi = Header}

        mov       edx, [edi + TnxBlockPoolChunkHeader.bpchStackListHead.lhSequence]
        mov       eax, [edi + TnxBlockPoolChunkHeader.bpchStackListHead.lhFirst]
  @@loop4a:
        or        eax, eax
        jz       @@NoItemFound
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [edi + TnxBlockPoolChunkHeader.bpchStackListHead]
        db        $F0, $0F, $C7, $4F, $10
        jnz      @@loop4a

   { eax = item from stack }
        push      dword ptr [eax + TnxStackEntry.seData]

        mov       ebx, eax
   { ebx = empty item add to tssFreeHead}

        mov       edx, [edi + TnxBlockPoolChunkHeader.bpchFreeListHead.lhSequence]
        mov       eax, [edi + TnxBlockPoolChunkHeader.bpchFreeListHead.lhFirst]
  @@loop4b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [edi + TnxBlockPoolChunkHeader.bpchFreeListHead]
        db        $F0, $0F, $C7, $4F, $08
        jnz      @@loop4b

        pop       eax
        jmp      @@ItemFound

  @@NoItemFound:
  { eax = nil}

  { set full marker, assumption: bpbhFull = 0}
        xor       eax, eax
        mov       edx, 1
//   lock cmpxchg   dword ptr [edi + TnxBlockPoolChunkHeader.bpchFull], edx
        db        $F0, $0F, $B1, $57, $18
        je       @@MakerSet1
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
   @@MakerSet1:
  { check if the Chunk really is full, between trying to get a item from the
    free list and setting the Chunk full marker another thread might have added
    a free item to the Chunk again }
        xor       eax, eax
        xor       edx, edx
   lock cmpxchg   dword ptr [edi + TnxBlockPoolChunkHeader.bpchStackListHead], edx
        je       @@MainLoop
  { the Chunk wasn't really full, the first thread to set bpbhFull back to 0 has
    to add the Chunk to the free list again }

        xor       edx, edx
        cmp       dword ptr [edi + TnxBlockPoolChunkHeader.bpchFull], edx
        je       @@MainLoop

        mov       eax, 1
   lock cmpxchg   dword ptr [edi + TnxBlockPoolChunkHeader.bpchFull], edx
        jne      @@MainLoop
  { we are the first thread to set the flag back again, add the Chunk to the
    free list }

        mov       ebx, edi

        cmp       dword [esi + bpPartialFreeChunkBool], 0
        jne       @@SaveToList2a

  { threadsafe add Chunk to PartialFree list, esi = self, edi = Header }
        mov       edx, [esi + bpPartialFreeChunkHead1.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead1.lhFirst]
  @@loop5a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop5a
        jmp      @@MainLoop

  @@SaveToList2a:

        mov       edx, [esi + bpPartialFreeChunkHead2.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead2.lhFirst]
  @@loop5b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop5b
        jmp      @@MainLoop


  @@ItemFound:
        mov       ebx, eax
        xchg      ebx, edi
  { ebx = Header, edi/eax = Item }

        cmp       [ebx + TnxBlockPoolChunkHeader.bpchStackListHead.lhFirst], 0
        jz       @@LastItem
  { still other items left in the page }

        cmp       dword [esi + bpPartialFreeChunkBool], 0
        jne       @@SaveToList2b

  { threadsafe add Chunk to PartialFree list, esi = self, edi = Header }
        mov       edx, [esi + bpPartialFreeChunkHead1.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead1.lhFirst]
  @@loop6a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop6a
        jmp      @@ExitItemFound

  @@SaveToList2b:

        mov       edx, [esi + bpPartialFreeChunkHead2.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead2.lhFirst]
  @@loop6b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop6b
        jmp      @@ExitItemFound

  @@LastItem:
  { we removed the last item from the Chunk }

  { set full marker, assumption: bpbhFull = 0}
        xor       eax, eax
        mov       edx, 1
//   lock cmpxchg   dword ptr [ebx + TnxBlockPoolChunkHeader.bpchFull], edx
        db        $F0, $0F, $B1, $53, $18
        je       @@MakerSet2
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
   @@MakerSet2:
  { check if the Chunk really is full, between trying to get a item from the
    free list and setting the Chunk full marker another thread might have added
    a free item to the Chunk again }
        xor       eax, eax
        xor       edx, edx
   lock cmpxchg   dword ptr [ebx + TnxBlockPoolChunkHeader.bpchStackListHead], edx
        je       @@ExitItemFound
  { the Chunk wasn't really full, the first thread to set bpbhFull back to 0 has
    to add the Chunk to the free list again }

        xor       edx, edx
        cmp       dword ptr [ebx + TnxBlockPoolChunkHeader.bpchFull], edx
        je       @@ExitItemFound

        mov       eax, 1
   lock cmpxchg   dword ptr [ebx + TnxBlockPoolChunkHeader.bpchFull], edx
        jne      @@ExitItemFound
  { we are the first thread to set the flag back again, add the Chunk to the
    free list }

        cmp       dword [esi + bpPartialFreeChunkBool], 0
        jne       @@SaveToList2c

  { threadsafe add Chunk to PartialFree list, esi = self, ebx = Header }
        mov       edx, [esi + bpPartialFreeChunkHead1.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead1.lhFirst]
  @@loop7a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop7a
        jmp      @@ExitItemFound

  @@SaveToList2c:

        mov       edx, [esi + bpPartialFreeChunkHead2.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead2.lhFirst]
  @@loop7b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop7b

  @@ExitItemFound:
        mov       eax, edi
  @@exit:
        pop       ebx
        pop       edi
        pop       esi
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.bpDisposeChunk(p: PnxBlockPoolChunkHeader);
var
  i: Integer;
begin
  i := Cardinal(p.bpchChunkBase) shr 20;
  Assert(_ChunkHeaders[i] = p);
  _ChunkHeaders[i] := nil;

  ReleaseChunk(p.bpchChunkBase);
  p.bpchChunkBase := nil;
  bpChunkHeaders.Push(p);
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.bpDisposeReservedBlock(p: Pointer);
asm
        cmp       edx, 0
        jz       @@Exit

        push      ebx
        push      esi
        push      edi

        mov       esi, eax
        mov       edi, edx
        shr       edi, 20
        mov       edi, dword ptr [_ChunkHeaders + edi * 4]
  { esi = Self, edi = Header}

        cmp       esi, [edi + TnxBlockPoolChunkHeader.bpchBlockPool];
        jne      @@Error

  @@HeaderValid:
        push      edx

        mov       edx, [edi + TnxBlockPoolChunkHeader.bpchFreeListHead.lhSequence]
        mov       eax, [edi + TnxBlockPoolChunkHeader.bpchFreeListHead.lhFirst]
  @@loop1a:
        or        eax, eax
        jz       @@Error
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [edi + TnxBlockPoolChunkHeader.bpchFreeListHead]
        db        $F0, $0F, $C7, $4F, $08
        jnz      @@loop1a

   { eax = newly acquired free item }
        pop       edx
        mov       [eax + TnxStackEntry.seData], edx
        mov       ebx, eax

        cmp       dword ptr [eax + TnxStackEntry.seListEntry.leNext], 0
        jne      @@AddItem
        mov       dword ptr [esi + bpNeedCleanup], 1

  @@AddItem:
   { ebx = item with seData Assigned to p}

        mov       edx, [edi + TnxBlockPoolChunkHeader.bpchStackListHead.lhSequence]
        mov       eax, [edi + TnxBlockPoolChunkHeader.bpchStackListHead.lhFirst]
  @@loop1b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [edi + TnxBlockPoolChunkHeader.bpchStackListHead]
        db        $F0, $0F, $C7, $4F, $10
        jnz      @@loop1b

        xor       edx, edx
        cmp       dword ptr [edi + TnxBlockPoolChunkHeader.bpchFull], edx
        je       @@Success

  { the Chunk now contains a free item, try to reset the full flag }
        mov       eax, 1
//   lock cmpxchg   dword ptr [edi + TnxBlockPoolChunkHeader.bpchFull], edx
        db        $F0, $0F, $B1, $57, $18
        jne      @@Success
  { we are the first thread to set the flag back again, add the Chunk to the
    free list }

        mov       ebx, edi
        cmp       dword [esi + bpPartialFreeChunkBool], 0
        jne      @@SaveToList2

  { threadsafe add Chunk to PartialFree list, esi = self, ebx = Header }
        mov       edx, [esi + bpPartialFreeChunkHead1.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead1.lhFirst]
  @@loop2a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop2a
        jmp      @@Success

  @@SaveToList2:

        mov       edx, [esi + bpPartialFreeChunkHead2.lhSequence]
        mov       eax, [esi + bpPartialFreeChunkHead2.lhFirst]
  @@loop2b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + bpPartialFreeChunkHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop2b

  @@Success:
  { eax = Result = 0 = everything ok}
        xor       eax, eax
  @@Cleanup:
        pop       edi
        pop       esi
        pop       ebx
  @@Exit:
        ret
  @@Error:
        {$IFNDEF DCC6OrLater}
        mov     AL,1
        jmp     System.@RunError
        {$ELSE}
        mov     AL,reOutOfMemory
        jmp     System.Error
        {$ENDIF}
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.bpInternalCleanup;
var
  Header    : PnxBlockPoolChunkHeader;
begin
  bpInternalRemoveUnusedItems;

  if bpNeedCleanup <> 0 then begin
    bpNeedCleanup := 0;

    if bpPartialFreeChunkBool = 0 then begin

      Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpPartialFreeChunkHead1));
      while Assigned(Header) do begin

        if not Assigned(Header.bpchFreeListHead.lhFirst) then
          bpDisposeChunk(Header)
        else begin
          LockedPushEntrySList(@bpPartialFreeChunkHead2, Pointer(Header));
          bpPartialFreeChunkBool := 1;
        end;

        Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpPartialFreeChunkHead1));
      end;

    end else begin

      Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpPartialFreeChunkHead2));
      while Assigned(Header) do begin
        if not Assigned(Header.bpchFreeListHead.lhFirst) then
          bpDisposeChunk(Header)
        else begin
          LockedPushEntrySList(@bpPartialFreeChunkHead1, Pointer(Header));
          bpPartialFreeChunkBool := 0;
        end;

        Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpPartialFreeChunkHead2));
      end;

    end;
  end;

  Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpFreeChunkHead));
  while Assigned(Header) do begin
    if not Assigned(Header.bpchFreeListHead.lhFirst) then
      bpDisposeChunk(Header)
    else
      Assert(False);

    Header := PnxBlockPoolChunkHeader(LockedPopEntrySList(@bpFreeChunkHead));
  end;
end;
{------------------------------------------------------------------------------}
class procedure TnxBlockPool.Cleanup;
var
  i: TnxBlockSize;
begin
  for i := Low(_BlockPools) to High(_BlockPools) do
    _BlockPools[i].bpInternalCleanup;
end;
{------------------------------------------------------------------------------}
class procedure TnxBlockPool.Prepare;
var
  PagesPerBlock               : Integer;
  i                           : TnxBlockSize;
begin
  PagesPerBlock := 1;
  for i := Low(_BlockPools) to High(_BlockPools) do begin
    _BlockPools[i] := TnxBlockPool.Create(PagesPerBlock);
    PagesPerBlock := PagesPerBlock shl 1;
  end;
end;
{------------------------------------------------------------------------------}
class procedure TnxBlockPool.Finalize;
var
  i                           : TnxBlockSize;
  j                           : Integer;
begin
  for i := Low(_BlockPools) to High(_BlockPools) do
    nxFreeAndNil(_BlockPools[i]);

  for j := Low(_ChunkHeaders) to High(_ChunkHeaders) do
    if Assigned(_ChunkHeaders[j]) then begin
      if not VirtualFree(_ChunkHeaders[j].bpchChunkBase, 0, MEM_RELEASE) then
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}
      _ChunkHeaders[j] := nil;
    end;
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.bpInternalRemoveUnusedItems;
var
  p                           : Pointer;
begin
  p := bpCommitedItems.Pop;
  while Assigned(p) do begin
    if not VirtualFree(p, bpBlockSize, MEM_DECOMMIT) then
      {$IFNDEF DCC6OrLater}
      System.RunError(2 {reInvalidPtr});
      {$ELSE}
      System.Error(reInvalidPtr);
      {$ENDIF}
    LockedSub(_CommitedMemory, bpBlockSize);
    bpDisposeReservedBlock(p);
    p := bpCommitedItems.Pop;
  end;
end;
{------------------------------------------------------------------------------}
class procedure TnxBlockPool.RemoveUnusedItems;
var
  i: TnxBlockSize;
begin
  for i := Low(_BlockPools) to High(_BlockPools) do
    _BlockPools[i].bpInternalRemoveUnusedItems;
end;
{------------------------------------------------------------------------------}
constructor TnxBlockPool.Create(aPagesPerBlock: Cardinal);
begin
  inherited Create;

  bpPagesPerBlock := aPagesPerBlock;

  bpBlocksPerChunk := 256 div bpPagesPerBlock;

  bpBlockSize := bpPagesPerBlock * nxcl_SystemPageSize;

  Assert(bpBlockSize <= nxcl_SystemAllocationSize);
  Assert(bpBlockSize * bpBlocksPerChunk = nxcl_1MB);

  bpHeaderSize := nxcl_BlockPoolChunkHeaderSize +
    (bpBlocksPerChunk * SizeOf(TnxStackEntry));

  bpCommitedItems := TnxUnpagedThreadSafeStack.Create;
  bpChunkHeaders := TnxUnpagedThreadSafeStack.Create;
end;
{------------------------------------------------------------------------------}
destructor TnxBlockPool.Destroy;
begin
  bpInternalCleanup;
  inherited;
  bpChunkHeaders.Free;
  bpCommitedItems.Free;
end;
{------------------------------------------------------------------------------}
procedure TnxBlockPool.Dispose(var p: Pointer);
begin
  if Assigned(p) then begin
    { Tell the OS that we don't care about the current contents of the page
      if it is currently swapped out the OS will not bother to get it back in
      case of an access. If the page is currently in memory and the OS needs
      physical memory before any write access to the page takes place it will
      simply discard the contents. We also put a protection on the page, so
      that it will raise an exception when accesed. }

    VirtualAlloc(p, bpBlockSize, MEM_RESET, PAGE_NOACCESS);
    bpCommitedItems.Push(p);

    p := nil;
  end;
end;
{------------------------------------------------------------------------------}
procedure _Hooked_TnxBlockPool_Dispose(Self: TnxBlockPool; var P: Pointer); register;
begin
  if assigned(p) then begin
    _BeforeBlockPoolDispose(p);
    Self.Dispose(p);
  end;
end;
{==============================================================================}



{===TnxMemoryPool==============================================================}
type
  TnxMemoryPool = class;

  PnxMemoryPoolBlockHeader = ^TnxMemoryPoolBlockHeader;
  TnxMemoryPoolBlockHeader = packed record
    mpbhFreeListEntry : TnxListEntry;
    mpbhMemoryPool    : TnxMemoryPool;                          {the memory pool that owns this block}

    mpbhFreeListHead  : TnxListHead;                            {pointer to the first free item in this block}
    mpbhUsedCount     : Cardinal;

    mpbhFull          : Integer;                                {0 = contained in free list}

    mpbhReserved2     : Integer;
    mpbhReserved3     : Integer;
  end;

  TnxMemoryPool = class(TnxUnpagedObject)
  public                                                 {private}
    { implict pointer to class, 4 byte}
    mpPartialFreeBlockBool  : Cardinal;

    mpPartialFreeBlockHead1 : TnxListHead;               {make sure this is 8 byte aligned!}
    mpPartialFreeBlockHead2 : TnxListHead;               {make sure this is 8 byte aligned!}
    mpFreeBlockHead         : TnxListHead;               {make sure this is 8 byte aligned!}

    mpNeedCleanup           : Cardinal;

    mpBlockHeaderSize       : Cardinal;

    mpItemSize              : Cardinal;
    mpItemsPerBlock         : Cardinal;

    mpBlockAdrMask          : Cardinal;
    mpBlockAdrMaskInv       : Cardinal;

    mpBlockSize             : TnxBlockSize;
  protected
    function mpAllocBlock: PnxMemoryPoolBlockHeader;
    procedure mpDisposeBlock(var aBlock: PnxMemoryPoolBlockHeader);

    procedure mpInternalCleanup;
  public
    constructor Create(aItemSize: Cardinal);
    destructor Destroy; override;

    function Alloc: Pointer; register;
    procedure Dispose(var P: Pointer); register;
    procedure DisposeDirect(P: Pointer); register;

    class procedure Cleanup;

    class procedure Prepare;
    class procedure Finalize;
  end;
const
  nxcl_MemoryPoolBlockHeaderSize  = SizeOf(TnxMemoryPoolBlockHeader);

  _MemPoolsVarSizes            : array[0..15] of Integer = (
     4064,
     4352,
     4672,
     5024,
     5440,
     5952,
     6528,
     7264,
     8160,
     9344,
    10912,
    13088,
    16352,
    21824,
    32736,
    65472);
  _MemPoolsVarSizesHigh = 65472;

var
  _MemPool4                    : TnxMemoryPool;                 {                   4 byte}
  _MemPools8                   : array[0..07] of TnxMemoryPool; {    8 ..   64 in   8 byte steps}
  _MemPools32                  : array[0..29] of TnxMemoryPool; {   96 .. 1024 in  32 byte steps}
  _MemPools256                 : array[0..10] of TnxMemoryPool; { 1280 .. 3840 in 256 byte steps}
  _MemPoolsVar                 : array[0..15] of TnxMemoryPool; { 16 pools from (64k-32)/16 to (64k-32)/1}
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
function TnxMemoryPool.Alloc: Pointer;
asm
        push      esi
        push      edi
        push      ebx
  { esi = Self }
        mov       esi, eax

  @@MainLoop:
  { threadsafe remove first entry from mpPartialFreeBlockHead and put it into eax }
        cmp       dword [esi + mpPartialFreeBlockBool], 0
        jne      @@LoadFromList2

        mov       edx, [esi + mpPartialFreeBlockHead1.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead1.lhFirst]
  @@loop1a:
        or        eax, eax
        jz       @@CheckFreeList
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop1a
        jmp      @@FoundBlock

  @@LoadFromList2:
        mov       edx, [esi + mpPartialFreeBlockHead2.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead2.lhFirst]
  @@loop1b:
        or        eax, eax
        jz       @@CheckFreeList
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop1b

  @@FoundBlock:
        cmp       dword ptr [eax + TnxMemoryPoolBlockHeader.mpbhUsedCount], 0
        jne       @@HeaderFound
  { eax = Header, block completely empty, add to free list }

        mov       ebx, eax
        mov       edx, [esi + mpFreeBlockHead.lhSequence]
        mov       eax, [esi + mpFreeBlockHead.lhFirst]
  @@loop2:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpFreeBlockHead]
        db        $F0, $0F, $C7, $4E, $18
        jnz      @@loop2

        jmp      @@MainLoop

  @@CheckFreeList:
  { threadsafe remove first entry from mpFreeBlockHead and put it into eax }
        mov       edx, [esi + mpFreeBlockHead.lhSequence]
        mov       eax, [esi + mpFreeBlockHead.lhFirst]
  @@loop3:
        or        eax, eax
        jz       @@AllocBlock
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [esi + mpFreeBlockHead]
        db        $F0, $0F, $C7, $4E, $18
        jnz      @@loop3
        jmp      @@HeaderFound
  @@AllocBlock:
        mov       eax, esi
        call      TnxMemoryPool.mpAllocBlock
        cmp       eax, 0
        jnz      @@HeaderFound
  { eax = Result = nil }
        jmp      @@exit
  @@HeaderFound:
        mov       edi, eax
  { edi = Header}
  { threadsafe remove first entry from Header.mpbhFreeListHead and put it into eax }
        mov       edx, [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead.lhSequence]
        mov       eax, [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead.lhFirst]
  @@loop4:
        or        eax, eax
        jz       @@NoItemFound
        lea       ecx, [edx + 1]
        mov       ebx, [eax]
//   lock cmpxchg8b qword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead]
        db        $F0, $0F, $C7, $4F, $08
        jnz      @@loop4
   lock inc       dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhUsedCount]
  { eax = Item}
        jmp      @@ItemFound
  @@NoItemFound:
  { eax = nil}

  { set full marker, assumption: mpbhFull = 0}
        xor       eax, eax
        mov       edx, 1
   lock cmpxchg   dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFull], edx
        je       @@MakerSet1
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
   @@MakerSet1:
  { check if the block really is full, between trying to get a item from the
    free list and setting the block full marker another thread might have added
    a free item to the block again }
        xor       eax, eax
        xor       edx, edx
   lock cmpxchg   dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead], edx
        je       @@MainLoop

        xor       edx, edx
        cmp       dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFull], edx
        je       @@MainLoop

  { the block wasn't really full, the first thread to set mpbhFull back to 0 has
    to add the block to the free list again }
        mov       eax, 1
   lock cmpxchg   dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFull], edx
        jne      @@MainLoop
  { we are the first thread to set the flag back again, add the block to the
    free list }

        mov       ebx, edi

        cmp       dword [esi + mpPartialFreeBlockBool], 0
        jne       @@SaveToList2a

  { threadsafe add block to PartialFree list, esi = self, edi = Header }
        mov       edx, [esi + mpPartialFreeBlockHead1.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead1.lhFirst]
  @@loop5a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop5a
        jmp      @@MainLoop

  @@SaveToList2a:

        mov       edx, [esi + mpPartialFreeBlockHead2.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead2.lhFirst]
  @@loop5b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop5b
        jmp      @@MainLoop


  @@ItemFound:
        mov       ebx, eax
        xchg      ebx, edi
  { ebx = Header, edi/eax = Item }

        mov       eax, [eax]
        cmp       eax, 0
        jz       @@LastItem
  { still other items left in the page }

        cmp       dword [esi + mpPartialFreeBlockBool], 0
        jne       @@SaveToList2b

  { threadsafe add block to PartialFree list, esi = self, edi = Header }
        mov       edx, [esi + mpPartialFreeBlockHead1.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead1.lhFirst]
  @@loop6a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop6a
        jmp      @@ExitItemFound

  @@SaveToList2b:

        mov       edx, [esi + mpPartialFreeBlockHead2.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead2.lhFirst]
  @@loop6b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop6b
        jmp      @@ExitItemFound

  @@LastItem:
  { we removed the last item from the block }

  { set full marker, assumption: mpbhFull = 0}
        xor       eax, eax
        mov       edx, 1
   lock cmpxchg   dword ptr [ebx + TnxMemoryPoolBlockHeader.mpbhFull], edx
        je       @@MakerSet2
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
   @@MakerSet2:
  { check if the block really is full, between trying to get a item from the
    free list and setting the block full marker another thread might have added
    a free item to the block again }
        xor       eax, eax
        xor       edx, edx
   lock cmpxchg   dword ptr [ebx + TnxMemoryPoolBlockHeader.mpbhFreeListHead], edx
        je       @@ExitItemFound

        xor       edx, edx
        cmp       dword ptr [ebx + TnxMemoryPoolBlockHeader.mpbhFull], edx
        je       @@ExitItemFound

  { the block wasn't really full, the first thread to set mpbhFull back to 0 has
    to add the block to the free list again }
        mov       eax, 1
   lock cmpxchg   dword ptr [ebx + TnxMemoryPoolBlockHeader.mpbhFull], edx
        jne      @@ExitItemFound
  { we are the first thread to set the flag back again, add the block to the
    free list }

        cmp       dword [esi + mpPartialFreeBlockBool], 0
        jne       @@SaveToList2c

  { threadsafe add block to PartialFree list, esi = self, ebx = Header }
        mov       edx, [esi + mpPartialFreeBlockHead1.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead1.lhFirst]
  @@loop7a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop7a
        jmp      @@ExitItemFound

  @@SaveToList2c:

        mov       edx, [esi + mpPartialFreeBlockHead2.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead2.lhFirst]
  @@loop7b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop7b

  @@ExitItemFound:
        mov       eax, edi
{$IFDEF NX_DEBUG_MEMORYMANAGER_ADDR_CHECK}
        and       eax, [esi + mpBlockAdrMask]
        sub       eax, [esi + mpBlockHeaderSize]
        xor       edx, edx
        div       [esi + mpItemSize]
        cmp       edx, 0
        jne      @@Error
        cmp       eax, [esi + mpItemsPerBlock]
        jge      @@Error

        mov       edx, edi
        and       edx, [esi + mpBlockAdrMaskInv]
   lock bts       [edx + nxcl_MemoryPoolBlockHeaderSize], eax
        jc       @@Error

        mov       eax, edi
{$ENDIF}
  @@exit:
        pop       ebx
        pop       edi
        pop       esi
        ret
  @@Error:
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
end;
{------------------------------------------------------------------------------}
function _Hooked_TnxMemoryPool_Alloc(Self : TnxMemoryPool): Pointer; register;
begin
  Result := Self.Alloc;
  _AfterMemoryPoolAlloc(Self.mpItemSize, Result);
end;
{------------------------------------------------------------------------------}
class procedure TnxMemoryPool.Cleanup;
var
  i : Integer;
begin
  _MemPool4.mpInternalCleanup;

  for i := Low(_MemPools8) to High(_MemPools8) do
    _MemPools8[i].mpInternalCleanup;

  for i := Low(_MemPools32) to High(_MemPools32) do
    _MemPools32[i].mpInternalCleanup;

  for i := Low(_MemPools256) to High(_MemPools256) do
    _MemPools256[i].mpInternalCleanup;

  for i := Low(_MemPoolsVar) to High(_MemPoolsVar) do
    _MemPoolsVar[i].mpInternalCleanup;
end;
{------------------------------------------------------------------------------}
constructor TnxMemoryPool.Create(aItemSize: Cardinal);
var
  OverHead     : Cardinal;
  BestOverHead : Cardinal;
  i            : TnxBlockSize;
begin
  inherited Create;

  InitSListHead(@mpPartialFreeBlockHead1);
  InitSListHead(@mpPartialFreeBlockHead2);
  InitSListHead(@mpFreeBlockHead);


  { All allocations will be aligned at nxcl_AllocGranularity addresses }
  if aItemSize = 4 then
    mpItemSize := 4
  else
    mpItemSize := ((aItemSize div nxcl_AllocGranularity) +
      Cardinal(Ord((aItemSize mod nxcl_AllocGranularity) <> 0))) *
      nxcl_AllocGranularity;

  BestOverHead := High(OverHead);

  for i := Low(i) to High(i) do begin

    mpBlockHeaderSize := nxcl_MemoryPoolBlockHeaderSize;

    mpItemsPerBlock := Pred(_BlockPools[i].bpBlockSize - mpBlockHeaderSize)
      div mpItemSize;

    {$IFDEF NX_DEBUG_MEMORYMANAGER_ADDR_CHECK}
    mpBlockHeaderSize := (((nxcl_MemoryPoolBlockHeaderSize + ((mpItemsPerBlock + 7) div 8)) + 15) div 16) * 16;

    mpItemsPerBlock := Pred(_BlockPools[i].bpBlockSize - mpBlockHeaderSize)
      div mpItemSize;
    {$ENDIF}

    OverHead := (64 * 1024) -
      ((mpItemsPerBlock * mpItemSize) shl (4-Ord(i)));


    //if mpItemsPerBlock > 0 then {always use the smalles block size possible}
    //  OverHead := 0;

    if OverHead < BestOverHead then begin
      BestOverHead := OverHead;
      mpBlockSize := i;
    end;

  end;

  // mpBlockSize  := High(mpBlockSize); {always use the largest block size possible}

  if mpBlockSize <> High(mpBlockSize) then begin
    mpBlockHeaderSize := nxcl_MemoryPoolBlockHeaderSize;

    mpItemsPerBlock := Pred(_BlockPools[mpBlockSize].bpBlockSize - mpBlockHeaderSize)
      div mpItemSize;

    {$IFDEF NX_DEBUG_MEMORYMANAGER_ADDR_CHECK}
    mpBlockHeaderSize := (((nxcl_MemoryPoolBlockHeaderSize + ((mpItemsPerBlock + 7) div 8)) + 15) div 16) * 16;

    mpItemsPerBlock := Pred(_BlockPools[mpBlockSize].bpBlockSize - mpBlockHeaderSize)
      div mpItemSize;
    {$ENDIF}
  end;

  Assert(mpItemsPerBlock > 0);
  mpBlockAdrMask := Pred(_BlockPools[mpBlockSize].bpBlockSize);
  mpBlockAdrMaskInv := not mpBlockAdrMask;
end;
{------------------------------------------------------------------------------}
destructor TnxMemoryPool.Destroy;
begin
  mpInternalCleanup;
  inherited;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.Dispose(var P: Pointer);
asm
        xor       ecx, ecx
        xchg      [edx], ecx
        mov       edx, ecx
        test      edx, edx
        jnz       TnxMemoryPool.DisposeDirect
end;
{------------------------------------------------------------------------------}
procedure _Hooked_TnxMemoryPool_Dispose(Self: TnxMemoryPool; var P: Pointer); register;
begin
  if assigned(p) then begin
    _BeforeMemoryPoolDispose(p);
    Self.Dispose(p);
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.DisposeDirect(P: Pointer);
asm
        push      ebx
        push      esi
        push      edi

        mov       ebx, edx

        mov       esi, eax
        mov       edi, ebx
        and       edi, [esi + mpBlockAdrMaskInv]
  { esi = Self, edi = Header, ebx = p}

        cmp       esi, [edi + TnxMemoryPoolBlockHeader.mpbhMemoryPool];
        jne      @@Error

  @@HeaderValid:
{$IFDEF NX_DEBUG_MEMORYMANAGER_ADDR_CHECK}
        mov       eax, ebx
        and       eax, [esi + mpBlockAdrMask]
        sub       eax, [esi + mpBlockHeaderSize]
        xor       edx, edx
        div       [esi + mpItemSize]
        cmp       edx, 0
        jne      @@Error
        cmp       eax, [esi + mpItemsPerBlock]
        jge      @@Error

   lock btr       [edi + nxcl_MemoryPoolBlockHeaderSize], eax
        jnc      @@Error
{$ENDIF}

  { threadsafe add item back into free list}
        mov       edx, [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead.lhSequence]
        mov       eax, [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead.lhFirst]
  @@loop1:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFreeListHead]
        db        $F0, $0F, $C7, $4F, $08
        jnz      @@loop1
   lock dec       dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhUsedCount]
        jnz      @@NotEmpty
        mov       dword ptr [esi + mpNeedCleanup], 1

  @@NotEmpty:
        xor       edx, edx
        cmp       dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFull], edx
        je       @@Success

  { the block now contains a free item, try to reset the full flag }
        mov       eax, 1
   lock cmpxchg   dword ptr [edi + TnxMemoryPoolBlockHeader.mpbhFull], edx
        jne      @@Success
  { we are the first thread to set the flag back again, add the block to the
    free list }

        mov       ebx, edi
        cmp       dword [esi + mpPartialFreeBlockBool], 0
        jne      @@SaveToList2

  { threadsafe add block to PartialFree list, esi = self, ebx = Header }
        mov       edx, [esi + mpPartialFreeBlockHead1.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead1.lhFirst]
  @@loop2a:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead1]
        db        $F0, $0F, $C7, $4E, $08
        jnz      @@loop2a
        jmp      @@Success

  @@SaveToList2:

        mov       edx, [esi + mpPartialFreeBlockHead2.lhSequence]
        mov       eax, [esi + mpPartialFreeBlockHead2.lhFirst]
  @@loop2b:
        mov       [ebx], eax
        lea       ecx, [edx+1]
//   lock cmpxchg8b qword ptr [esi + mpPartialFreeBlockHead2]
        db        $F0, $0F, $C7, $4E, $10
        jnz      @@loop2b

  @@Success:
        pop       edi
        pop       esi
        pop       ebx
  @@Exit:
        xor       eax, eax
        ret
  @@Error:
        {$IFNDEF DCC6OrLater}
        mov       al, 2
        jmp       System.@RunError { fatal error }
        {$ELSE}
        mov       al, reInvalidPtr
        jmp       System.Error { fatal error }
        {$ENDIF}
end;
{------------------------------------------------------------------------------}
procedure _Hooked_TnxMemoryPool_DisposeDirect(Self: TnxMemoryPool; P: Pointer); register;
begin
  if Assigned(p) then begin
    _BeforeMemoryPoolDispose(p);
    Self.DisposeDirect(p);
  end;
end;
{------------------------------------------------------------------------------}
class procedure TnxMemoryPool.Finalize;
var
  j : Integer;
begin
  nxFreeAndNil(_MemPool4);

  for j := Low(_MemPools8) to High(_MemPools8) do
    nxFreeAndNil(_MemPools8[j]);

  for j := Low(_MemPools32) to High(_MemPools32) do
    nxFreeAndNil(_MemPools32[j]);

  for j := Low(_MemPools256) to High(_MemPools256) do
    nxFreeAndNil(_MemPools256[j]);

  for j := Low(_MemPoolsVar) to High(_MemPoolsVar) do
    nxFreeAndNil(_MemPoolsVar[j]);
end;
{------------------------------------------------------------------------------}
function TnxMemoryPool.mpAllocBlock: PnxMemoryPoolBlockHeader;
var
  Item, LastItem : PnxListEntry;
  i              : Integer;
begin
  Result := _BlockPools[mpBlockSize].Alloc;
  nxFillChar(Result^, mpBlockHeaderSize, 0);

  Result.mpbhMemoryPool := Self;
  InitSListHead(@Result.mpbhFreeListHead);

  Item := PnxListEntry(Result);
  Inc(PByte(Item), mpBlockHeaderSize);
  Result.mpbhFreeListHead.lhFirst := Item;
  Result.mpbhUsedCount := 0;

  LastItem := nil;
  for i:= Pred(mpItemsPerBlock) downto 0 do begin
    LastItem := Item;
    Inc(PByte(Item), mpItemSize);
    LastItem.leNext := Item;
  end;
  LastItem.leNext := nil;
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.mpDisposeBlock(var aBlock: PnxMemoryPoolBlockHeader);
begin
  _BlockPools[mpBlockSize].Dispose(Pointer(aBlock));
end;
{------------------------------------------------------------------------------}
procedure TnxMemoryPool.mpInternalCleanup;
var
  Header    : PnxMemoryPoolBlockHeader;
begin
  if mpNeedCleanup <> 0 then begin
    mpNeedCleanup := 0;
    if mpPartialFreeBlockBool = 0 then begin

      Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpPartialFreeBlockHead1));
      while Assigned(Header) do begin

        if Header.mpbhUsedCount = 0 then
          mpDisposeBlock(Header)
        else begin
          LockedPushEntrySList(@mpPartialFreeBlockHead2, Pointer(Header));
          mpPartialFreeBlockBool := 1;
        end;

        Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpPartialFreeBlockHead1));
      end;

    end else begin

      Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpPartialFreeBlockHead2));
      while Assigned(Header) do begin
        if Header.mpbhUsedCount = 0 then
          mpDisposeBlock(Header)
        else begin
          LockedPushEntrySList(@mpPartialFreeBlockHead1, Pointer(Header));
          mpPartialFreeBlockBool := 0;
        end;

        Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpPartialFreeBlockHead2));
      end;

    end;
  end;

  Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpFreeBlockHead));
  while Assigned(Header) do begin
    if Header.mpbhUsedCount = 0 then
      mpDisposeBlock(Header)
    else
      Assert(False);

    Header := PnxMemoryPoolBlockHeader(LockedPopEntrySList(@mpFreeBlockHead));
  end;
end;
{------------------------------------------------------------------------------}
class procedure TnxMemoryPool.Prepare;
var
  j : Integer;
begin
  _MemPool4 := TnxMemoryPool.Create(4);

  for j := Low(_MemPools8) to High(_MemPools8) do
    _MemPools8[j] := TnxMemoryPool.Create(Succ(j) * 8);

  for j := Low(_MemPools32) to High(_MemPools32) do
    _MemPools32[j] := TnxMemoryPool.Create(_MemPools8[High(_MemPools8)].mpItemSize +
      Cardinal(Succ(j) * 32));

  for j := Low(_MemPools256) to High(_MemPools256) do
    _MemPools256[j] := TnxMemoryPool.Create(_MemPools32[High(_MemPools32)].mpItemSize +
      Cardinal(Succ(j) * 256));

  for j := Low(_MemPoolsVar) to High(_MemPoolsVar) do
    _MemPoolsVar[j] := TnxMemoryPool.Create(_MemPoolsVarSizes[j]);
end;
{==============================================================================}



{===System MemoryManager Replacement===========================================}
function _GetPool(Size : TnxMemSize): TnxMemoryPool;
begin
  case Size of
    1..4:
      Result := _MemPool4;
    5..64:
      Result := _MemPools8[Pred(Size) shr 3];
    65..1024:
      Result := _MemPools32[(Size - 65) shr 5];
    1025..3840:
      Result := _MemPools256[(Size - 1025) shr 8];
    3841..4064:
      Result := _MemPoolsVar[0];
    4065..4352:
      Result := _MemPoolsVar[1];
    4353..4672:
      Result := _MemPoolsVar[2];
    4673..5024:
      Result := _MemPoolsVar[3];
    5025..5440:
      Result := _MemPoolsVar[4];
    5441..5952:
      Result := _MemPoolsVar[5];
    5953..6528:
      Result := _MemPoolsVar[6];
    6529..7264:
      Result := _MemPoolsVar[7];
    7265..8160:
      Result := _MemPoolsVar[8];
    8161..9344:
      Result := _MemPoolsVar[9];
    9345..10912:
      Result := _MemPoolsVar[10];
    10913..13088:
      Result := _MemPoolsVar[11];
    13089..16352:
      Result := _MemPoolsVar[12];
    16353..21824:
      Result := _MemPoolsVar[13];
    21825..32736:
      Result := _MemPoolsVar[14];
    32737..65472:
      Result := _MemPoolsVar[15];
  else
    Result := nil;
  end;
end;
{------------------------------------------------------------------------------}
function _HookedGetPool(Size : TnxMemSize): TnxMemoryPool;
begin
  _BeforeGetPool(Size);
  Result := _GetPool(Size);
end;
{------------------------------------------------------------------------------}
function _GetMemLarge(Size: Integer): Pointer;
begin
  Result := VirtualAlloc(nil, Size, MEM_COMMIT, PAGE_READWRITE);
  if not Assigned(Result) then
    Exit;

  LockedAdd(_ReservedAddressSpace, ((Size + Pred(nxcl_SystemAllocationSize)) div nxcl_SystemAllocationSize) * nxcl_SystemAllocationSize);
  LockedAdd(_CommitedMemory, ((Size + Pred(nxcl_SystemPageSize)) div nxcl_SystemPageSize) * nxcl_SystemPageSize);

  Assert(Cardinal(Result) and Pred(nxcl_SystemAllocationSize) = 0);
end;
{------------------------------------------------------------------------------}
var
  _GetMemTable: array[0..Pred(_MemPoolsVarSizesHigh div 32)] of TnxMemoryPool;
  _GetMemTableSmall: array[0..16] of TnxMemoryPool;
{------------------------------------------------------------------------------}
procedure PrepareGetMemTable;
var
  i: Integer;
begin
  for i := Low(_GetMemTable) to High(_GetMemTable) do
    _GetMemTable[i] := _GetPool(Succ(i) * 32);

  for i := Low(_GetMemTableSmall) to High(_GetMemTableSmall) do
    _GetMemTableSmall[i] := _GetPool(Succ(i) * 4);
end;
{------------------------------------------------------------------------------}
function _GetMem(Size: Integer): Pointer;
asm
  cmp eax, _MemPoolsVarSizesHigh
  jg _GetMemLarge
  cmp eax, 65
  jl @@Small

  dec eax
  shr eax, 5
  mov eax, dword ptr [_GetMemTable + eax * 4];
  jmp TnxMemoryPool.Alloc
 @@Small:
  and eax, $FFFFFFFC
  mov eax, dword ptr [_GetMemTableSmall + eax];
  jmp TnxMemoryPool.Alloc
end;
{------------------------------------------------------------------------------}
function _HookedGetMem(Size: Integer): Pointer;
begin
  _BeforeGetMem(Size);
  Result := _GetMem(Size);
  _AfterGetMem(Size, Result);
end;
{------------------------------------------------------------------------------}
function _FreeMemLarge(P: Pointer): Integer;
var
  MemInfo : TMemoryBasicInformation;
begin
  Result := 0;
  VirtualQuery(p, MemInfo, SizeOf(MemInfo));
  if VirtualFree(p, 0, MEM_RELEASE) then begin
    LockedSub(_ReservedAddressSpace, ((MemInfo.RegionSize + Pred(nxcl_SystemAllocationSize)) div nxcl_SystemAllocationSize) * nxcl_SystemAllocationSize);
    LockedSub(_CommitedMemory, ((MemInfo.RegionSize + Pred(nxcl_SystemPageSize)) div nxcl_SystemPageSize) * nxcl_SystemPageSize);
  end
  else
    Result := 1;
end;
{------------------------------------------------------------------------------}
function _FreeMem(P: Pointer): Integer;
asm
  mov       ecx, eax
  shr       ecx, 20
  mov       ecx, dword ptr [_ChunkHeaders + ecx * 4]

  test      ecx, ecx
  jz        _FreeMemLarge

  mov       edx, eax
  and       eax, dword ptr [ecx + TnxBlockPoolChunkHeader.bpchBlockAddrMask]
  mov       eax, dword ptr [eax + TnxMemoryPoolBlockHeader.mpbhMemoryPool]
  jmp       TnxMemoryPool.DisposeDirect
end;
{------------------------------------------------------------------------------}
function _HookedFreeMem(P: Pointer): Integer;
begin
  _BeforeFreeMem(p);
  Result := _FreeMem(p);
end;
{------------------------------------------------------------------------------}
function CheckVirtualMem(P : Pointer; AllocSize: PCardinal = nil): Boolean;
var
  Info: TMemoryBasicInformation;
begin
  if VirtualQuery(p, Info, SizeOf(Info)) = 0 then
    {$IFNDEF DCC6OrLater}
    System.RunError(2 {reInvalidPtr});
    {$ELSE}
    System.Error(reInvalidPtr);
    {$ENDIF}

  Result := Info.AllocationBase = p;
  if Assigned(AllocSize) then
    AllocSize^ := Info.RegionSize;
end;
{------------------------------------------------------------------------------}
function _ReallocMemLarge(P: Pointer; Size: Integer): Pointer;
var
  AllocSize : Cardinal;
begin
  Result := nil;

  if CheckVirtualMem(p, @AllocSize) then
    if Cardinal(Size) < AllocSize then
      Result := p
    else begin
      Result := _GetMem(Size);
      nxMove(p^, Result^, AllocSize);
      if VirtualFree(p, 0, MEM_RELEASE) then begin
        LockedSub(_ReservedAddressSpace, ((AllocSize + Pred(nxcl_SystemAllocationSize)) div nxcl_SystemAllocationSize) * nxcl_SystemAllocationSize);
        LockedSub(_CommitedMemory, ((AllocSize + Pred(nxcl_SystemPageSize)) div nxcl_SystemPageSize) * nxcl_SystemPageSize);
      end
      else
        {$IFNDEF DCC6OrLater}
        System.RunError(2 {reInvalidPtr});
        {$ELSE}
        System.Error(reInvalidPtr);
        {$ENDIF}
    end;
end;
{------------------------------------------------------------------------------}
function _ReallocMem(P: Pointer; Size: Integer): Pointer;
asm
  mov       ecx, eax
  shr       ecx, 20
  mov       ecx, dword ptr [_ChunkHeaders + ecx * 4]

  test      ecx, ecx
  jz        _ReallocMemLarge

  push      ebx
  push      esi
  push      edi

  mov       ebx, eax
  and       ebx, dword ptr [ecx + TnxBlockPoolChunkHeader.bpchBlockAddrMask]
  mov       esi, dword ptr [ebx + TnxMemoryPoolBlockHeader.mpbhMemoryPool]
  mov       ecx, dword ptr [esi + TnxMemoryPool.mpItemSize]
  cmp       edx, ecx
  jle      @@Exit

  {eax = p, ebx = block header, ecx = itemsize, edx = new size, esi = old memory pool}

  mov       ebx, ecx

  {eax = p, ebx = itemsize, ecx = itemsize, edx = new size, esi = old memory pool}

  mov       edi, eax
  mov       eax, edx

  {eax = size, ebx = itemsize, ecx = itemsize, edx = new size, esi = old memory pool, edi = p}

  call      _GetMem

  {eax = new memory, ebx = itemsize, ecx = xxx, edx = xxx, esi = old memory pool, edi = p}

  mov       ecx, ebx
  mov       edx, eax
  mov       eax, edi
  mov       ebx, edx

  {eax = p, ebx = new memory, ecx = itemsize, edx = new memory, esi = old memory pool, edi = p}

  call      [nxMove]

  {eax = xxx, ebx = new memory, ecx = xxx, edx = xxx, esi = old memory pool, edi = p}

  mov       eax, esi
  mov       edx, edi

  {eax = old memory pool, ebx = new memory, ecx = xxx, edx = p, esi = old memory pool, edi = p}

  call      TnxMemoryPool.DisposeDirect

  {eax = xxx, ebx = new memory, ecx = xxx, edx = xxx, esi = old memory pool, edi = p}

  mov       eax, ebx

 @@Exit:
  pop       edi
  pop       esi
  pop       ebx
end;
{------------------------------------------------------------------------------}
function _HookedReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  _BeforeReallocMem(p, Size);
  Result := _ReallocMem(p, Size);
  _AfterReallocMem(Size, Result);
end;
{------------------------------------------------------------------------------}
function _GetAllocSize(P : Pointer)
                         : Integer;
var
  Header : PnxMemoryPoolBlockHeader;
  i      : Integer;
begin
  if not (((Cardinal(p) and Pred(nxcl_SystemAllocationSize)) = 0) and CheckVirtualMem(p, @Result)) then begin
    i := Cardinal(p) shr 20;
    Assert(Assigned(_ChunkHeaders[i]));
    Header := Pointer(Cardinal(p) and _ChunkHeaders[i].bpchBlockAddrMask);
    Result := Header.mpbhMemoryPool.mpItemSize;
  end;
end;
{------------------------------------------------------------------------------}
function _HookedGetAllocSize(P : Pointer)
                               : Integer;
begin
  _BeforeGetAllocSize(p);
  Result := _GetAllocSize(p);
  _AfterGetAllocSize(p, Result);
end;
{------------------------------------------------------------------------------}
function _GetHeapStatus: THeapStatus;
begin
  with Result do begin
    TotalAddrSpace := _ReservedAddressSpace;
    TotalCommitted := _CommitedMemory;
    TotalUncommitted := TotalAddrSpace - TotalCommitted;

    Overhead := _CommitedOverhead;

    TotalAllocated := TotalCommitted - Overhead;
    TotalFree := TotalUncommitted;

    FreeSmall := 0;
    FreeBig := TotalFree;
    Unused := 0;

    HeapErrorCode := 0;
  end;
end;
{------------------------------------------------------------------------------}
const
  _MemoryManager : TMemoryManager = (
    GetMem: _GetMem;
    FreeMem: _FreeMem;
    ReallocMem: _ReallocMem;
  );
  _HookedMemoryManager : TMemoryManager = (
    GetMem: _HookedGetMem;
    FreeMem: _HookedFreeMem;
    ReallocMem: _HookedReallocMem;
  );
{==============================================================================}



{===Cleanup Thread=============================================================}
const
  nxcl_CleanupInterval            = 2000; {2 sec}
var
  _CleanupThreadDieEvent        : THandle;
  _CleanupThreadTerminatedEvent : THandle;
  _CleanupThreadMutex           : THandle;
  _CleanupThreadHandle          : THandle;
  _CleanupThread8087CW          : Word;
{------------------------------------------------------------------------------}
{$IFNDEF DCC6OrLater}
function Get8087CW: Word;
asm
  push    0
  fnstcw  [esp].Word
  pop     eax
end;
{$ENDIF}
{------------------------------------------------------------------------------}
function CleanupThreadProc(Parameter: Pointer): Integer; stdcall;
var
  ExceptCount : Integer;
  LoopCount   : Integer;
{$IFDEF NX_DEBUG_THREAD_THREADNAMES}
type
  TThreadNameInfo = record
    FType: LongWord;     // must be 0x1000
    FName: PChar;        // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord;    // reserved for future use, must be zero
  end;
var
  ThreadNameInfo: TThreadNameInfo;
{$ENDIF}
begin
  asm
    FNINIT
    FWAIT
  end;
  Set8087CW(_CleanupThread8087CW);

  Result := 1;
  ExceptCount := 0;
  LoopCount := 0;
  try
    WaitForSingleObject(_CleanupThreadMutex, 0);
    SetThreadPriority(_CleanupThreadHandle, THREAD_PRIORITY_TIME_CRITICAL);
    while WaitForSingleObject(_CleanupThreadDieEvent, nxcl_CleanupInterval) = WAIT_TIMEOUT do try

      {$IFDEF NX_DEBUG_THREAD_THREADNAMES}
      if Result = 1 then begin
        Result := 0;

        ThreadNameInfo.FType := $1000;
        ThreadNameInfo.FName := 'CleanupThread';
        ThreadNameInfo.FThreadID := $FFFFFFFF;
        ThreadNameInfo.FFlags := 0;

        try
          RaiseException($406D1388, 0, sizeof(ThreadNameInfo) div sizeof(LongWord),
            @ThreadNameInfo);
        except end;
      end;
      {$ENDIF}

      if LoopCount mod 2 = 0 then
        TnxMemoryPool.Cleanup
      else if LoopCount mod 6 = 5 then begin
          TnxBlockPool.Cleanup;
          LoopCount := -1;
        end else
          TnxBlockPool.RemoveUnusedItems;

      Inc(LoopCount);
    except
      Inc(ExceptCount);
      if ExceptCount > 10 then
        Exit;
    end;
  finally
    if _CleanupThreadTerminatedEvent <> 0 then
      SetEvent(_CleanupThreadTerminatedEvent);
  end;
end;
{------------------------------------------------------------------------------}
procedure PrepareCleanupThread;
begin
  _CleanupThreadDieEvent := CreateEvent(nil, True, False, nil);
  _CleanupThreadMutex := CreateMutex(nil, False, nil);
  _CleanupThreadTerminatedEvent := CreateEvent(nil, True, False, nil);
end;
{------------------------------------------------------------------------------}
procedure StartCleanupThread;
var
  ThreadID : Cardinal;
begin
  _CleanupThread8087CW := Get8087CW;
  if _CleanupThreadHandle = 0 then
    _CleanupThreadHandle := CreateThread(nil, 0, @CleanupThreadProc, nil, 0, ThreadID);
end;
{------------------------------------------------------------------------------}
procedure FinalizeCleanupThread;
begin
  if _CleanupThreadMutex <> 0 then

    case WaitForSingleObject(_CleanupThreadMutex, 0) of
      WAIT_ABANDONED_0, WAIT_OBJECT_0: ;
    else

      if _CleanupThreadDieEvent <> 0 then
        SetEvent(_CleanupThreadDieEvent);

      if _CleanupThreadHandle <> 0 then begin

        SetThreadPriority(_CleanupThreadHandle, THREAD_PRIORITY_TIME_CRITICAL);
        Sleep(1);

        if _CleanupThreadTerminatedEvent <> 0 then
          WaitForSingleObject(_CleanupThreadTerminatedEvent, nxcl_CleanupInterval + 500);

        Sleep(1);

      end;

    end;

  if _CleanupThreadDieEvent <> 0 then begin
    CloseHandle(_CleanupThreadDieEvent);
    _CleanupThreadDieEvent := 0;
  end;

  if _CleanupThreadTerminatedEvent <> 0 then begin
    CloseHandle(_CleanupThreadTerminatedEvent);
    _CleanupThreadTerminatedEvent := 0;
  end;

  if _CleanupThreadMutex <> 0 then begin
    CloseHandle(_CleanupThreadMutex);
    _CleanupThreadMutex := 0;
  end;

  if _CleanupThreadHandle <> 0 then begin
    CloseHandle(_CleanupThreadHandle);
    _CleanupThreadHandle := 0;
  end;
end;
{==============================================================================}



{===Init/Done==================================================================}
var
  _MemoryManagerImpl        : TnxMemoryManagerImpl;
{------------------------------------------------------------------------------}
function SafeLoadLibrary(aFilename: PChar; ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;
var
  OldMode: UINT;
  FPUControlWord: Word;
begin
  OldMode := SetErrorMode(ErrorMode);
  try
    asm
      FNSTCW  FPUControlWord
    end;
    try
      Result := LoadLibrary(aFilename);
    finally
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;
{------------------------------------------------------------------------------}
function LoadAttachedHook(aModule: HMODULE): HMODULE;
var
  Buffer : array[0..MAX_PATH] of Char;
  i      : Cardinal;
const
  _nxcNexusMM2HookDLL = '_' + nxcNexusMM2Hook + '.dll'#0;
begin
  Result := 0;

  if aModule <> 0 then begin
    i := GetModuleFileName(aModule, @Buffer, SizeOf(Buffer));
    Result := 0;

    while (i > 0) and (Buffer[i] <> '.') do
      Dec(i);

    if (i > 0) and ((Cardinal(Length(_nxcNexusMM2HookDLL)) + i) < MAX_PATH) then begin
      Move(_nxcNexusMM2HookDLL, Buffer[i], Length(_nxcNexusMM2HookDLL));
      Result := SafeLoadLibrary(@Buffer);
    end;

  end;
end;
{------------------------------------------------------------------------------}
function HookMemMan: Boolean;
var
  Handle : THandle;
  Buffer : array[0..MAX_PATH] of Char;
begin
  Result := False;

  { There are 4 ways to hook the memory manager }

  { if a NexusMM2Hook.dll is already loaded into the process, take it }
  Handle := GetModuleHandle(nxcNexusMM2Hook);

  if Handle = 0 then
    {otherwise... take the main module, remove extension and add _NexusMM2Hook.dll}
    Handle := LoadAttachedHook(MainInstance);

  if Handle = 0 then
    {otherwise... take the current module, remove extension and add _NexusMM2Hook.dll}
    Handle := LoadAttachedHook(HInstance);

  if Handle = 0 then
    {otherwise... check for a env var called NexusMM2Hook and load the referenced dll}
    if GetEnvironmentVariable(nxcNexusMM2Hook, @Buffer, SizeOf(Buffer)) > 0 then
      Handle := SafeLoadLibrary(@Buffer);

  { if we've found a valid module handle, try to load all the required entry points }
  if Handle <> 0 then begin
    _BeforeGetMem            := GetProcAddress(Handle, 'BeforeGetMem');
    _AfterGetMem             := GetProcAddress(Handle, 'AfterGetMem');

    _BeforeFreeMem           := GetProcAddress(Handle, 'BeforeFreeMem');

    _BeforeReallocMem        := GetProcAddress(Handle, 'BeforeReallocMem');
    _AfterReallocMem         := GetProcAddress(Handle, 'AfterReallocMem');

    _BeforeGetAllocSize      := GetProcAddress(Handle, 'BeforeGetAllocSize');
    _AfterGetAllocSize       := GetProcAddress(Handle, 'AfterGetAllocSize');

    _AfterBlockPoolAlloc     := GetProcAddress(Handle, 'AfterBlockPoolAlloc');
    _BeforeBlockPoolDispose  := GetProcAddress(Handle, 'BeforeBlockPoolDispose');

    _BeforeGetPool           := GetProcAddress(Handle, 'BeforeGetPool');
    _AfterMemoryPoolAlloc    := GetProcAddress(Handle, 'AfterMemoryPoolAlloc');
    _BeforeMemoryPoolDispose := GetProcAddress(Handle, 'BeforeMemoryPoolDispose');

    { if the module contained all required exports, activate the hooks }
    Result :=
      Assigned(_BeforeGetMem) and
      Assigned(_AfterGetMem) and
      Assigned(_BeforeFreeMem) and
      Assigned(_BeforeReallocMem) and
      Assigned(_AfterReallocMem) and
      Assigned(_BeforeGetAllocSize) and
      Assigned(_AfterGetAllocSize) and
      Assigned(_AfterBlockPoolAlloc) and
      Assigned(_BeforeBlockPoolDispose) and
      Assigned(_BeforeGetPool) and
      Assigned(_AfterMemoryPoolAlloc) and
      Assigned(_BeforeMemoryPoolDispose);
  end;
end;
{------------------------------------------------------------------------------}
function InitMemoryManager: PnxMemoryManagerImpl;
var
  OldProtection : Cardinal;
begin
  if not _MemoryManagerInitialized then begin
    _MemoryManagerInitialized := True;

    PrepareChunkAllocator;

    TnxBlockPool.Prepare;
    TnxMemoryPool.Prepare;

    PrepareGetMemTable;

    PrepareCleanupThread;

    if HookMemMan then begin
      _MemoryManagerImpl.__MemoryManager := _HookedMemoryManager;
      _MemoryManagerImpl.__GetAllocSize := @_HookedGetAllocSize;

      _MemoryManagerImpl.__TnxBlockPool_Alloc := @_Hooked_TnxBlockPool_Alloc;
      _MemoryManagerImpl.__TnxBlockPool_Dispose := @_Hooked_TnxBlockPool_Dispose;

      _MemoryManagerImpl.__GetPool := @_HookedGetPool;
      _MemoryManagerImpl.__TnxMemoryPool_Alloc := @_Hooked_TnxMemoryPool_Alloc;
      _MemoryManagerImpl.__TnxMemoryPool_Dispose := @_Hooked_TnxMemoryPool_Dispose;
      _MemoryManagerImpl.__TnxMemoryPool_DisposeDirect := @_Hooked_TnxMemoryPool_DisposeDirect;
    end else begin
      _MemoryManagerImpl.__MemoryManager := _MemoryManager;
      _MemoryManagerImpl.__GetAllocSize := @_GetAllocSize;

      _MemoryManagerImpl.__TnxBlockPool_Alloc := @TnxBlockPool.Alloc;
      _MemoryManagerImpl.__TnxBlockPool_Dispose := @TnxBlockPool.Dispose;

      _MemoryManagerImpl.__GetPool := @_GetPool;
      _MemoryManagerImpl.__TnxMemoryPool_Alloc := @TnxMemoryPool.Alloc;
      _MemoryManagerImpl.__TnxMemoryPool_Dispose := @TnxMemoryPool.Dispose;
      _MemoryManagerImpl.__TnxMemoryPool_DisposeDirect := @TnxMemoryPool.DisposeDirect;
    end;

    _MemoryManagerImpl.__GetHeapStatus := @_GetHeapStatus;

    Assert(SizeOf(_BlockPools) = SizeOf(_MemoryManagerImpl.__BlockPools));
    nxMove(_BlockPools, _MemoryManagerImpl.__BlockPools, SizeOf(_BlockPools));

    _MemoryManagerImpl.__EmptyBlock := _BlockPools[nxbs64k].Alloc;
    nxFillChar(_MemoryManagerImpl.__EmptyBlock^, _BlockPools[nxbs64k].bpBlockSize, 0);
    VirtualProtect(_MemoryManagerImpl.__EmptyBlock, _BlockPools[nxbs64k].bpBlockSize, PAGE_READONLY, OldProtection);

    StartCleanupThread;
  end;

  Result := @_MemoryManagerImpl;
end;
{------------------------------------------------------------------------------}
procedure DoneMemoryManager;
begin
  if not _MemoryManagerInitialized then
    Exit;
  _MemoryManagerInitialized := False;

  FinalizeCleanupThread;

  TnxMemoryPool.Finalize;

  _BlockPools[nxbs64k].Dispose(_MemoryManagerImpl.__EmptyBlock);
  TnxBlockPool.Finalize;

  FinalizeChunkAllocator;
  FinalizeUnpagedPool;
end;
{==============================================================================}

initialization
finalization
  DoneMemoryManager;
end.
