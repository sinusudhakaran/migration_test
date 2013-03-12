unit LockScheduler;

interface

uses
  Windows, Contnrs, LockList, SysUtils, PracticeClientServer, IdContext, Common;

type
  TReleasedLocks = TLocksHeld;

  TLockScheduler = class
  private
    FLockQueue: TLockList;
    
    function GetQueueCount: Integer;
    function GetQueueRecord(Index: Integer): TLockRecord;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function RequestLock(Identifier: ULongLong; LockToken: DWord; Context: TIdContext; LockType: DWORD): TLockStatus;
    function ReleaseLock(Context: TIdContext; LockType: DWord): TLockStatus; overload;
    function ReleaseLock(LockRecord: TLockRecord): TLockStatus; overload;

    procedure ReleaseAllLocks(Context: TIdContext; out ReleasedLocks: TReleasedLocks);

    procedure ClearQueue;

    function AquireReleasedLock(LockType: DWord; out AquiredLock: TLockRecord): Boolean;

    property QueueCount: Integer read GetQueueCount;
    property QueueRecord[Index: Integer]: TLockRecord read GetQueueRecord;
  end;
  
implementation

{ TLockScheduler }

function TLockScheduler.RequestLock(Identifier: ULongLong; LockToken: DWord; Context: TIdContext; LockType: DWORD): TLockStatus;
var
  LockRecord: TLockRecord;
begin
  LockRecord := FLockQueue.Find(Context, LockType);

  if LockRecord = nil then
  begin
    if FLockQueue.FindAquired(LockType) = nil then
    begin
      Result := lsAquired;
    end
    else
    begin
      Result := lsWaiting;
    end;

    FLockQueue.Add(Identifier, LockToken, Context, LockType, Result);
  end
  else
  begin
    if LockRecord.Status = lsAquired then
    begin
      Result := lsAquiredExisting;
    end
    else
    begin
      Result := LockRecord.Status;
    end;
  end;
end;

procedure TLockScheduler.ClearQueue;
begin
  FLockQueue.Clear;
end;

constructor TLockScheduler.Create;
begin
  FLockQueue := TLockList.Create;
end;

destructor TLockScheduler.Destroy;
begin
  FLockQueue.Free;
  
  inherited;
end;

function TLockScheduler.GetQueueCount: Integer;
begin
  Result := FLockQueue.Count;
end;

function TLockScheduler.GetQueueRecord(Index: Integer): TLockRecord;
begin
  Result := FLockQueue[Index];
end;

function TLockScheduler.AquireReleasedLock(LockType: DWord; out AquiredLock: TLockRecord): Boolean;
var
  LockRecord: TLockRecord;
begin
  LockRecord := FLockQueue.FindFirstWaiting(LockType);

  if LockRecord <> nil then
  begin
    LockRecord.Status := lsAquired;
    LockRecord.TimeAquired := Now;

    AquiredLock := LockRecord;

    Result := True;
  end
  else
  begin
    AquiredLock := nil;

    Result := False;
  end;
end;

procedure TLockScheduler.ReleaseAllLocks(Context: TIdContext; out ReleasedLocks: TReleasedLocks);
begin
  FLockQueue.Remove(Context, ReleasedLocks);
end;

function TLockScheduler.ReleaseLock(LockRecord: TLockRecord): TLockStatus;
begin
  if LockRecord.Status = lsAquired then
  begin
    FLockQueue.Remove(LockRecord);

    Result := lsUnlocked;
  end
  else
  begin
    FLockQueue.Remove(LockRecord);

    Result := lsRemovedWaiting;
  end;
end;

function TLockScheduler.ReleaseLock(Context: TIdContext; LockType: DWord): TLockStatus;
var
  LockRecord: TLockRecord;
begin
  LockRecord := FLockQueue.Find(Context, LockType);

  if LockRecord <> nil then
  begin
    Result := ReleaseLock(LockRecord);
  end
  else
  begin
    Result := lsNoLock;
  end;
end;

end.
