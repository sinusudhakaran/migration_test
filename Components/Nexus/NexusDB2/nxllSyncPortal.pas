{##############################################################################}
{# NexusDB: nxllSyncPortal.pas 2.00                                           #}
{# NexusDB Memory Manager: nxllSyncPortal.pas 2.03                            #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: read write portal                                                 #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllSyncPortal;

interface

uses
  Windows,
  SysUtils,
  nxllTypes,
  nxllMemoryManager;

const
  nxc_ThreadHashCount = 15;

type
  TnxThreadHashIndex = 0..nxc_ThreadHashCount;

  PnxThreadState = ^TnxThreadState;
  TnxThreadState = record
    tsNext     : PnxThreadState;
    tsInUse    : TnxInt32;
    tsCount    : TnxWord32;
    tsID       : TnxWord32;
  end;

  TnxThreadStateTable = array[TnxThreadHashIndex] of PnxThreadState;

  TnxThreadStates = class(TnxObject)
  protected {private}
    tlcHashTable : TnxThreadStateTable;

    function tlcHashIndex(aThreadID : TnxWord32)
                                    : TnxThreadHashIndex;
  public
    destructor Destroy; override;

    procedure Acquire(aThreadID    : TnxWord32;
                  out aThreadState : PnxThreadState);
    procedure Release(aThreadState : PnxThreadState);
  end;

  TnxInternalReadWritePortal = class(TnxObject)
  protected {private}
    rwpPortal        : TnxInt32;

    rwpThreadStates  : TnxThreadStates;

    rwpReadEvent     : THandle;

    rwpWriteEvent    : THandle;
    rwpWriterID      : TnxWord32;
    rwpWriterCount   : TnxWord32;

    rwpGeneration    : TnxWord32;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginRead;
    procedure EndRead;

    function BeginWrite: Boolean;
    procedure EndWrite;
  end;

implementation

uses
  nxllLockedFuncs;

var
  _ThreadStatePool : TnxMemoryPool;

const
  Yes : TnxInt32 = -1;

{===TnxThreadStates============================================================}
procedure TnxThreadStates.Acquire(aThreadID    : TnxWord32;
                              out aThreadState : PnxThreadState);
var
  HashIndex : TnxThreadHashIndex;
begin
  HashIndex := tlcHashIndex(aThreadID);

  aThreadState := tlcHashTable[HashIndex];
  while Assigned(aThreadState) and (LockedCompareExchange(Integer(aThreadState.tsID),
    Integer(aThreadID), Integer(aThreadID)) <> Integer(aThreadID)) do
    LockedExchange(Integer(aThreadState), Integer(aThreadState.tsNext));

  if not Assigned(aThreadState) then begin
    aThreadState := tlcHashTable[HashIndex];
    while Assigned(aThreadState) do
      if LockedExchange(aThreadState.tsInUse, Yes) <> Yes then
        Break
      else
        LockedExchange(Integer(aThreadState), Integer(aThreadState.tsNext));

    if not Assigned(aThreadState) then begin
      aThreadState := PnxThreadState(_ThreadStatePool.Alloc);
      with aThreadState^ do begin
        tsID := 0;
        tsCount := 0;
        tsInUse := Yes;
        tsNext := aThreadState;
        tsNext := PnxThreadState(
          LockedExchange(TnxInt32(tlcHashTable[HashIndex]), TnxInt32(aThreadState)));
      end;
    end;

    LockedCompareExchange(Integer(aThreadState.tsID), Integer(aThreadID), 0);
    Assert(aThreadState.tsID = aThreadID);
  end;
end;
{------------------------------------------------------------------------------}
destructor TnxThreadStates.Destroy;
var
  HashIndex : TnxThreadHashIndex;
  Next      : PnxThreadState;
  Current   : PnxThreadState;
begin
  for HashIndex := Low(tlcHashTable) to High(tlcHashTable) do begin
    Next := tlcHashTable[HashIndex];
    tlcHashTable[HashIndex] := nil;
    while Assigned(Next) do begin
      Current := Next;
      Next := Next^.tsNext;
      _ThreadStatePool.DisposeDirect(Current);
    end;
  end;
  inherited;
end;
{------------------------------------------------------------------------------}
procedure TnxThreadStates.Release(aThreadState: PnxThreadState);
begin
  with aThreadState^ do begin
    LockedExchange(Integer(tsID), 0);
    LockedExchange(tsInUse, 0);
  end;
end;
{------------------------------------------------------------------------------}
function TnxThreadStates.tlcHashIndex(aThreadID : TnxWord32)
                                                : TnxThreadHashIndex;
asm
  xor  al, ah
  and  al, nxc_ThreadHashCount
end;
{==============================================================================}

const
  nxc_RequestingWrite              = $FFFF;

{==============================================================================}
procedure TnxInternalReadWritePortal.BeginRead;
var
  ThreadID    : TnxWord32;
  ThreadState : PnxThreadState;
  NewLock     : Boolean;
  Portal      : TnxInt32;
begin
  ThreadID := GetCurrentThreadID;

  rwpThreadStates.Acquire(ThreadID, ThreadState);
  Inc(ThreadState.tsCount);
  NewLock := ThreadState.tsCount < 2;

  if rwpWriterID <> ThreadID then
    if NewLock then begin
      WaitForSingleObject(rwpReadEvent, INFINITE);
      while LockedDec(rwpPortal) <= 0 do begin
        Portal := LockedInc(rwpPortal);
        if Portal = nxc_RequestingWrite then
          SetEvent(rwpWriteEvent);

        Sleep(0);
        WaitForSingleObject(rwpReadEvent, INFINITE);
      end;
    end;
end;
{------------------------------------------------------------------------------}
function TnxInternalReadWritePortal.BeginWrite: Boolean;
var
  ThreadID      : TnxWord32;
  ThreadState   : PnxThreadState;
  OldGeneration : TnxWord32;
  AlreadyLocked : Boolean;
  Portal        : TnxInt32;
begin
  Result := True;

  ThreadID := GetCurrentThreadID;

  if rwpWriterID <> ThreadID then begin
    ResetEvent(rwpReadEvent);

    OldGeneration := rwpGeneration;

    rwpThreadStates.Acquire(ThreadID, ThreadState);
    AlreadyLocked := ThreadState.tsCount > 0;

    if AlreadyLocked then
      LockedInc(rwpPortal);

    while LockedExchangeAdd(rwpPortal, -nxc_RequestingWrite) <> nxc_RequestingWrite do begin
      Portal := LockedExchangeAdd(rwpPortal, nxc_RequestingWrite);

      if Portal <> 0 then
        WaitForSingleObject(rwpWriteEvent, INFINITE);
    end;

    ResetEvent(rwpReadEvent);

    if AlreadyLocked then
      LockedDec(rwpPortal);

    rwpWriterID := ThreadID;

    Result := TnxInt32(OldGeneration) = Pred(LockedInc(TnxInt32(rwpGeneration)));
  end;

  Inc(rwpWriterCount);
end;
{------------------------------------------------------------------------------}
constructor TnxInternalReadWritePortal.Create;
begin
  rwpPortal := nxc_RequestingWrite;

  rwpReadEvent := CreateEvent(nil, True, True, nil);
  rwpWriteEvent := CreateEvent(nil, False, False, nil);

  rwpThreadStates := TnxThreadStates.Create;

  inherited Create;
end;
{------------------------------------------------------------------------------}
destructor TnxInternalReadWritePortal.Destroy;
begin
  BeginWrite;

  inherited Destroy;

  CloseHandle(rwpReadEvent);
  CloseHandle(rwpWriteEvent);
  nxFreeAndNil(rwpThreadStates);
end;
{------------------------------------------------------------------------------}
procedure TnxInternalReadWritePortal.EndRead;
var
  ThreadID    : TnxWord32;
  ThreadState : PnxThreadState;
  Portal      : TnxInt32;
begin
  ThreadID := GetCurrentThreadID;

  rwpThreadStates.Acquire(ThreadID, ThreadState);
  Dec(ThreadState.tsCount);

  if ThreadState.tsCount = 0 then begin
    rwpThreadStates.Release(ThreadState);

    if rwpWriterID <> ThreadID then begin
      Portal := LockedInc(rwpPortal);
      if Portal = nxc_RequestingWrite then
        SetEvent(rwpWriteEvent)
      else if Portal <= 0 then
        if (Portal mod nxc_RequestingWrite) = 0 then
          SetEvent(rwpWriteEvent);
    end;
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxInternalReadWritePortal.EndWrite;
var
  ThreadID    : TnxWord32;
  ThreadState : PnxThreadState;
begin
  ThreadID := GetCurrentThreadID;

  Assert(rwpWriterID = ThreadID);

  rwpThreadStates.Acquire(ThreadID ,ThreadState);
  Dec(rwpWriterCount);

  if rwpWriterCount = 0 then begin
    rwpWriterID := 0;
    LockedExchangeAdd(rwpPortal, nxc_RequestingWrite);
    SetEvent(rwpWriteEvent);
    SetEvent(rwpReadEvent);
  end;

  if ThreadState.tsCount = 0 then
    rwpThreadStates.Release(ThreadState);
end;
{==============================================================================}

initialization
  _ThreadStatePool := nxGetPool(SizeOf(TnxThreadState));
end.
