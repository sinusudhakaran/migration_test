{##############################################################################}
{# NexusDB: nxllSync.pas 2.00                                                 #}
{# NexusDB Memory Manager: nxllSync.pas 2.03                                  #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: low level thread syncronization objects                           #}
{##############################################################################}

{$I nxDefine.inc}

{.$DEFINE DebugPadlocks}
{.$DEFINE SimplePortal}
{$DEFINE FastPadlock}

{$UNDEF OverwriteReadWritePortal}
{$IFDEF SimplePortal}
  {$DEFINE OverwriteReadWritePortal}
{$ENDIF}
{$IFDEF NoLocking}
  {$DEFINE OverwriteReadWritePortal}
  {$UNDEF FastPadlock}
{$ENDIF}
{$IFDEF DebugPadlocks}
  {$UNDEF FastPadlock}
{$ENDIF}

unit nxllSync;

interface

uses
  Windows,
  SysUtils,
{$IFNDEF NX_MEMMAN_ONLY}
  nxllException,
{$ENDIF}
  nxllTypes,
  nxllLockedFuncs,
  nxllMemoryManager,
  nxllSyncPortal;

resourcestring
  rsCallingWaitForSingleObject = 'calling WaitForSingleObject';

const
  nxcl_InitialEventCount = 250;  {Initial # of events in event pool.}
  nxcl_RetainEventCount = 2500;  {# of events to retain when flush event pool.}

  nxcl_INFINITE = High(Cardinal);

type
  EnxSyncExceptionClass = class of EnxSyncException;
{$IFDEF NX_MEMMAN_ONLY}
  EnxSyncException = class(Exception);
{$ELSE}
  EnxSyncException = class(EnxBaseException);
{$ENDIF}

  TnxEvent = class(TnxObject)
  private
    nxeEvent : THandle;
  public
    constructor Create;
    destructor Destroy; override;

    procedure WaitFor(aTimeOut : TnxWord32);
    function WaitForQuietly(aTimeOut : TnxWord32) : TnxWord32;

    procedure SignalEvent;

    property Handle : THandle read nxeEvent;
  end;

  TnxPadlock = class(TnxObject)
  protected
    plCritSect  : TRTLCriticalSection;
    {$IFDEF DebugPadlocks}
    plLockCount : Integer;
    {$ENDIF}
  public
    {$IFDEF DebugPadlocks}
    class function Check: Boolean;
    {$ENDIF}

    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
  end;

  {$IFDEF OverwriteReadWritePortal}
  {$IFDEF SimplePortal}
  TnxReadWritePortal = class(TnxPadlock)
  {$ELSE}
  TnxReadWritePortal = class(TnxInternalReadWritePortal)
  {$ENDIF}
  public
    procedure BeginRead;
    procedure BeginWrite;
    procedure EndRead;
    procedure EndWrite;
  end;
  {$ELSE}
  TnxReadWritePortal = TnxInternalReadWritePortal;
  {$ENDIF}

  TnxThreadSafeStack = class(TnxObject)
  private
    tssCount     : Integer;
    tssPagesHead : TnxListHead;
    tssFreeHead  : TnxListHead;
    tssStackHead : TnxListHead;
  protected
    procedure tssAllocBlock;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Push(p: Pointer);
    function Pop: Pointer;

    property Count : Integer
      read tssCount;
  end;

  TnxEventPool = class(TnxObject)
  protected
    epList        : TnxThreadSafeStack;
    epRetainCount : Integer;
  public
    constructor Create(const InitialCount, RetainCount : Integer);
    destructor Destroy; override;
    procedure Flush;
    function Get : THandle;
    procedure Put(const aHandle : THandle);
  end;

var
  nxEventPool : TnxEventPool;

type
  TnxBreathCallback = procedure of object;

procedure nxBeginBreathCallback(aCallback: TnxBreathCallback);
procedure nxEndBreathCallback;

procedure nxBreath;

implementation

uses
  {$IFNDEF NX_MEMMAN_ONLY}
  nxllBde,
  {$ENDIF}
  nxllConst;

{===TnxEvent===================================================================}
constructor TnxEvent.Create;
begin
  inherited Create;
  if Assigned(nxEventPool) then begin
    nxeEvent := nxEventPool.Get;
    ResetEvent(nxeEvent);
  end else
    nxeEvent := CreateEvent(nil, False, False, nil);
end;
{------------------------------------------------------------------------------}
destructor TnxEvent.Destroy;
begin
  if Assigned(nxEventPool) then
    nxEventPool.Put(nxeEvent)
  else
    CloseHandle(nxeEvent);
  inherited Destroy;
end;
{------------------------------------------------------------------------------}
procedure TnxEvent.WaitFor(aTimeOut : TnxWord32);
var
  waitResult : TnxWord32;
begin
  if aTimeOut <= 0 then
    aTimeOut := nxcl_INFINITE;

  waitResult := WaitForSingleObject(nxeEvent, aTimeout);
  if waitResult = WAIT_TIMEOUT then
    {$IFDEF NX_MEMMAN_ONLY}
    raise EnxSyncException.Create('Timeout waiting for Event')
    {$ELSE}
    raise EnxSyncException.nxCreate(DBIERR_NX_GeneralTimeout)
    {$ENDIF}
  else if waitResult <> WAIT_OBJECT_0 then
    {$IFDEF NX_MEMMAN_ONLY}
    RaiseLastWin32Error;
    {$ELSE}
    raise nxCreateOSError(EnxSyncException, DBIERR_OSUNKNOWN,
      @rsCallingWaitForSingleObject);
    {$ENDIF}
end;
{------------------------------------------------------------------------------}
function TnxEvent.WaitForQuietly(aTimeOut : TnxWord32) : TnxWord32;
begin
  if aTimeOut <= 0 then
    aTimeOut := nxcl_INFINITE;

  Result := WaitForSingleObject(nxeEvent, aTimeout);
end;
{------------------------------------------------------------------------------}
procedure TnxEvent.SignalEvent;
begin
  SetEvent(nxeEvent);
end;
{==============================================================================}



{$IFDEF OverwriteReadWritePortal}
{===TnxReadWritePortal=========================================================}
procedure TnxReadWritePortal.BeginRead;
begin
  {$IFDEF SimplePortal}
  Lock;
  {$ELSE}
    {$IFNDEF NoLocking}
    inherited;
    {$ENDIF}
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
procedure TnxReadWritePortal.BeginWrite;
begin
  {$IFDEF SimplePortal}
  Lock;
  {$ELSE}
    {$IFNDEF NoLocking}
    inherited BeginWrite;
    {$ENDIF}
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
procedure TnxReadWritePortal.EndRead;
begin
  {$IFDEF SimplePortal}
  Unlock;
  {$ELSE}
    {$IFNDEF NoLocking}
    inherited;
    {$ENDIF}
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
procedure TnxReadWritePortal.EndWrite;
begin
  {$IFDEF SimplePortal}
  Unlock;
  {$ELSE}
    {$IFNDEF NoLocking}
    inherited;
    {$ENDIF}
  {$ENDIF}
end;
{==============================================================================}
{$ENDIF}



{===TnxPadlock=================================================================}
{$IFDEF DebugPadlocks}
var
  _PadlockList: TThreadList;
{------------------------------------------------------------------------------}
class function TnxPadlock.Check: Boolean;
var
  i: Integer;
begin
  if not Assigned(_PadlockList) then
    Result := False
  else begin
    Result := True;
    with _PadlockList, LockList do try
      for i:= 0 to Pred(Count) do
        if TnxPadlock(Items[i]).plLockCount <> 0 then
          Exit;
      Result := False;
    finally
      UnlockList;
    end;
  end;
end;
{------------------------------------------------------------------------------}
{$ENDIF}
constructor TnxPadlock.Create;
begin
  inherited Create;
  {$IFNDEF NoLocking}
  InitializeCriticalSection(plCritSect);
  {$ENDIF}

  {$IFDEF DebugPadlocks}
  if not Assigned(_PadlockList) then
    _PadlockList := TThreadList.Create;

  _PadlockList.Add(Self);
  {$ENDIF}
end;
{------------------------------------------------------------------------------}
destructor TnxPadlock.Destroy;
begin
  {$IFDEF DebugPadlocks}
  _PadlockList.Remove(Self);
  {$ENDIF}

  {$IFNDEF NoLocking}
  DeleteCriticalSection(plCritSect);
  {$ENDIF}
  inherited Destroy;
end;
{------------------------------------------------------------------------------}
procedure TnxPadlock.Lock;
{$IFDEF FastPadlock}
asm
  add  eax, OFFSET plCritSect {eax = address of plCritSect}
  xchg [esp], eax             {exchange return address on the stack with address of plCritSect}
  push eax                    {push return address on the stack again}
  jmp  EnterCriticalSection   {jump to EnterCriticalSection, will return to caller directly}
end;
{$ELSE}
begin
  {$IFNDEF NoLocking}
  EnterCriticalSection(plCritSect);
  {$ENDIF}
  {$IFDEF DebugPadlocks}
  Inc(plLockCount);
  {$ENDIF}
end;
{$ENDIF}
{------------------------------------------------------------------------------}
procedure TnxPadlock.Unlock;
{$IFDEF FastPadlock}
asm
  add  eax, OFFSET plCritSect {eax = address of plCritSect}
  xchg [esp], eax             {exchange return address on the stack with address of plCritSect}
  push eax                    {push return address on the stack again}
  jmp  LeaveCriticalSection   {jump to LeaveCriticalSection, will return to caller directly}
end;
{$ELSE}
begin
  {$IFDEF DebugPadlocks}
  Dec(plLockCount);
  {$ENDIF}
  {$IFNDEF NoLocking}
  LeaveCriticalSection(plCritSect);
  {$ENDIF}
end;
{$ENDIF}
{==============================================================================}



{===TnxThreadSafeStack=========================================================}
constructor TnxThreadSafeStack.Create;
begin
  inherited Create;
  tssAllocBlock;
end;
{------------------------------------------------------------------------------}
destructor TnxThreadSafeStack.Destroy;
var
  Page                        : PnxListEntry;
  Next                        : PnxListEntry;
begin
  inherited Destroy;

  Page := LockedFlushSList(@tssPagesHead);
  LockedFlushSList(@tssFreeHead);
  LockedFlushSList(@tssStackHead);

  while Assigned(Page) do begin
    Next := Page.leNext;
    BlockPools[nxbs4k].Dispose(Pointer(Page));
    Page := Next;
  end;
end;
{------------------------------------------------------------------------------}
function TnxThreadSafeStack.Pop: Pointer;
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
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [esi + tssStackHead]
   {$ELSE}
        db        $F0, $0F, $C7, $4E, $18
   {$ENDIF}
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
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [esi + tssFreeHead]
   {$ELSE}
        db        $F0, $0F, $C7, $4E, $10
   {$ENDIF}
        jnz      @@loop2

   lock dec       dword ptr [esi + tssCount]

        mov       eax, edi
   { eax = content of item from stack = result }

  @@Exit:
   { cleanup and get out of here }
        pop       edi
        pop       esi
        pop       ebx
end;
{------------------------------------------------------------------------------}
procedure TnxThreadSafeStack.Push(p: Pointer);
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
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [esi + tssFreeHead]
   {$ELSE}
        db        $F0, $0F, $C7, $4E, $10
   {$ENDIF}
        jnz      @@loop1

   { eax = newly acquired free item }

        mov       [eax + TnxStackEntry.seData], edi
        mov       ebx, eax

   { ebx = item with seData assigned to p, add to tssStackHead}

        mov       edx, [esi + tssStackHead.lhSequence]
        mov       eax, [esi + tssStackHead.lhFirst]
  @@loop2:
        mov       [ebx], eax
        lea       ecx, [edx+1]
   {$IFDEF DCC6OrLater}
   lock cmpxchg8b qword ptr [esi + tssStackHead]
   {$ELSE}
        db        $F0, $0F, $C7, $4E, $18
   {$ENDIF}
        jnz      @@loop2

   lock inc       dword ptr [esi + tssCount]

   { cleanup and get out of here }
        pop       edi
        pop       esi
        pop       ebx

        ret

  @@AllocBlock:
        mov       eax, esi
        call      TnxThreadSafeStack.tssAllocBlock
        jmp      @@AcquireFree
end;
{------------------------------------------------------------------------------}
procedure TnxThreadSafeStack.tssAllocBlock;
var
  p, q                        : PnxStackEntry;
  i                           : Integer;
begin
  p := BlockPools[nxbs4k].Alloc;
  q := p;
  Inc(q);

  for i := (_BlockSizes[nxbs4k] div 8)-3 downto 0 do begin
    q^.seListEntry.leNext := Pointer(Cardinal(q) + SizeOf(TnxStackEntry));
    Inc(q);
  end;

  LockedPushEntrySList(@tssPagesHead, Pointer(p));
  Inc(p);
  LockedPushEntriesSList(@tssFreeHead, Pointer(p), Pointer(q));
end;
{==============================================================================}



{===TnxEventPool===============================================================}
constructor TnxEventPool.Create(const initialCount, retainCount : Integer);
var
  Index : Integer;
begin
  inherited Create;
  epList := TnxThreadSafeStack.Create;
  epRetainCount := RetainCount;

  for Index := 1 to InitialCount do
    epList.Push(Pointer(CreateEvent(nil, False, False, nil)));
end;
{------------------------------------------------------------------------------}
destructor TnxEventPool.Destroy;
begin
  epRetainCount := 0;
  Flush;
  epList.Free;
  inherited Destroy;
end;
{------------------------------------------------------------------------------}
procedure TnxEventPool.Flush;
var
  p: Pointer;
begin
  while epRetainCount < epList.Count do begin
    p := epList.Pop;
    if p <> nil then
      CloseHandle(Cardinal(p))
  end;
end;
{------------------------------------------------------------------------------}
function TnxEventPool.Get : THandle;
begin
  Result := THandle(epList.Pop);
  if Result = 0 then
    { manual reset, start signaled }
    Result := CreateEvent(nil, False, False, nil)
end;
{------------------------------------------------------------------------------}
procedure TnxEventPool.Put(const aHandle : THandle);
begin
  epList.Push(Pointer(aHandle));
end;
{==============================================================================}



{==============================================================================}
threadvar
  nxtv_BreathCallback: TnxBreathCallback;
{------------------------------------------------------------------------------}
procedure nxBeginBreathCallback(aCallback: TnxBreathCallback);
begin
  Assert(not Assigned(nxtv_BreathCallback));
  nxtv_BreathCallback := aCallback;
  Assert(Assigned(nxtv_BreathCallback));
end;
{------------------------------------------------------------------------------}
procedure nxEndBreathCallback;
begin
  Assert(Assigned(nxtv_BreathCallback));
  nxtv_BreathCallback := nil;
end;
{------------------------------------------------------------------------------}
procedure nxBreath;
  {if assigned(nxtv_BreathCallback) then
    nxtv_BreathCallback;}
asm
   call  SysInit.@GetTLS
   lea   ecx, [eax].nxtv_BreathCallback
   mov   eax, [ecx + 4]
   test  eax, eax
   jz   @@Exit
   jmp   dword ptr [ecx]
  @@Exit:
end;
{==============================================================================}



{===Initialization/Finalization================================================}
procedure InitializeUnit;
begin
  nxEventPool := TnxEventPool.Create(nxcl_InitialEventCount, nxcl_RetainEventCount);
end;
{------------------------------------------------------------------------------}
procedure FinalizeUnit;
begin
  nxFreeAndNil(nxEventPool);
end;
{==============================================================================}

initialization
  InitializeUnit;
finalization
  FinalizeUnit;
end.

