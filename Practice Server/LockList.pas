unit LockList;

interface

uses
  Windows, Contnrs, SysUtils, PracticeClientServer, IdContext, Common;

type
  THeldLock = record
    LockToken: DWord;
    LockType: DWord;
    GroupId: TGroupId;
  end;

  TLocksHeld = array of THeldLock;
        
  TLockList = class sealed
  private
    FItems: TObjectList;

    FLock: TRTLCriticalSection;

    function GetCount: Integer;
    function GetItem(Index: Integer): TLockRecord;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Identifier: ULongLong; LockToken: DWord; Context: TIdContext; LockType: DWord; Status: TLockStatus; GroupId: TGroupId);

    procedure Remove(LockRecord: TLockRecord); overload;
    procedure Remove(Context: TIdContext; out LocksHeld: TLocksHeld); overload;

    function Find(Context: TIdContext; LockType: DWord; LockStatus: TLockStatus; GroupId: TGroupId): TLockRecord; overload;
    function Find(Context: TIdContext; LockType: DWord; GroupId: TGroupId): TLockRecord; overload;

    function FindFirst(LockType: DWord; GroupId: TGroupId): TLockRecord;
    function FindNext(StartIndex: Integer; LockType: DWord; GroupId: TGroupId): TLockRecord;
    function FindNextWaiting(StartIndex: Integer; LockType: DWord; GroupId: TGroupId): TLockRecord;
    
    function FindAquired(Context: TIdContext; LockType: DWord; GroupId: TGroupId): TLockRecord; overload;
    function FindAquired(LockType: DWord; GroupId: TGroupId): TLockRecord; overload;

    function FindFirstWaiting(LockType: DWord; GroupId: TGroupId): TLockRecord;

    procedure Clear;
    
    property Count: Integer read GetCount;

    property Items[Index: Integer]: TLockRecord read GetItem; default;
  end;
  
implementation

{ TFIFOQueue }

procedure TLockList.Add(Identifier: ULongLong; LockToken: DWord; Context: TIdContext; LockType: DWord; Status: TLockStatus; GroupId: TGroupId);
begin
  FItems.Add(TLockRecord.Create(Identifier, LockToken, Context, LockType, Status, GroupId));
end;

procedure TLockList.Clear;
begin
  FItems.Clear;
end;

constructor TLockList.Create;
begin
  FItems := TObjectList.Create(True);

  InitializeCriticalSection(FLock);
end;

destructor TLockList.Destroy;
begin
  FItems.Free;

  DeleteCriticalSection(FLock);
  
  inherited;
end;

function TLockList.Find(Context: TIdContext; LockType: DWord; LockStatus: TLockStatus; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);

    if (LockRecord.Context = Context) and (LockRecord.LockType = LockType) and (LockRecord.Status = LockStatus) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindFirst(LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.LockType = LockType) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.Find(Context: TIdContext; LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);

    if (LockRecord.Context = Context) and (LockRecord.LockType = LockType) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindAquired(LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.LockType = LockType) and (LockRecord.Status = lsAquired) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindAquired(Context: TIdContext; LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.Context = Context) and (LockRecord.LockType = LockType) and (LockRecord.Status = lsAquired) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindFirstWaiting(LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  LockRecord: TLockRecord;
  Index: Integer;
begin
  Result := nil;
  
  for Index := 0 to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.LockType = LockType) and (TLockRecord(FItems[Index]).Status = lsWaiting) and (CompareText(TLockRecord(FItems[Index]).GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindNext(StartIndex: Integer; LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := StartIndex to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.LockType = LockType) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.FindNextWaiting(StartIndex: Integer; LockType: DWord; GroupId: TGroupId): TLockRecord;
var
  Index: Integer;
  LockRecord: TLockRecord;
begin
  Result := nil;
  
  for Index := StartIndex to FItems.Count - 1 do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if (LockRecord.LockType = LockType) and (LockRecord.Status = lsWaiting) and (CompareText(LockRecord.GroupId, GroupId) = 0) then
    begin
      Result := LockRecord;

      Break;
    end;
  end;
end;

function TLockList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TLockList.GetItem(Index: Integer): TLockRecord;
begin
  Result := TLockRecord(FItems[Index]);
end;

procedure TLockList.Remove(Context: TIdContext; out LocksHeld: TLocksHeld);
var
  Index: Integer;
  LockRecord: TLockRecord;
  Count: Integer;
begin
  Index := 0;
  Count := 0;

  SetLength(LocksHeld, 0);
  
  while (Index < FItems.Count) and (FItems.Count > 0) do
  begin
    LockRecord := TLockRecord(FItems[Index]);
    
    if LockRecord.Context = Context then
    begin
      if LockRecord.Status = lsAquired then
      begin
        SetLength(LocksHeld, Count + 1);

        LocksHeld[Count].LockToken := LockRecord.Token;
        LocksHeld[Count].LockType := LockRecord.LockType;
        LocksHeld[Count].GroupId := LockRecord.GroupId;

        Inc(Count);
      end;
      
      FItems.Delete(Index); 
    end
    else
    begin
      Inc(Index);
    end;
  end;
end;

procedure TLockList.Remove(LockRecord: TLockRecord);
begin
  FItems.Remove(LockRecord);
end;

end.
