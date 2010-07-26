{##############################################################################}
{# NexusDB: nxllList.pas 2.00                                                 #}
{# NexusDB Memory Manager: nxllList.pas 2.03                                  #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: list classes                                                      #}
{##############################################################################}

{$I nxDefine.inc}

unit nxllList;

interface

uses
  Classes,
  nxllFastMove,
  nxllFastFillChar,
  nxllTypes,
  nxllMemoryManager,
  nxllSync;

type
  TnxBaseList = class(TnxObject)
  protected { private }
    blList         : PPointerList;
    blUseData      : Boolean;
    blData         : PPointerList;
    blCount        : Integer;
    blCapacity     : Integer;
  protected
    function blGet(aIndex: Integer): Pointer;

    class procedure Error(const Msg: string; Data: Integer); overload; virtual;
    class procedure Error(Msg: PResStringRec; Data: Integer); overload;
  public
    function IndexOf(aItem: Pointer): Integer; virtual; abstract;

    function First: Pointer;
    function Last: Pointer;

    property Capacity: Integer
      read blCapacity;

    property Count: Integer
      read blCount;

    property Items[aIndex: Integer]: Pointer
      read blGet; default;

    property List: PPointerList
      read blList;

    property Data: PPointerList
      read blData;
  end;

  TnxWriteableListClass = class of TnxWriteableList;
  TnxWriteableList = class(TnxBaseList)
  protected { private }
    wlInitCapacity : Integer;
  protected
    procedure wlGrow;
    procedure wlSetCapacity(aNewCapacity: Integer);
  public
    constructor Create(aInitCapacity : Integer = 0;
                       aUseData      : Boolean = False);
    destructor Destroy; override;

    function Add(aItem: Pointer): Integer; virtual; abstract;

    function Remove(aItem: Pointer): Integer;
    procedure Delete(aIndex: Integer);

    procedure Clear;

    property Capacity: Integer
      read blCapacity
      write wlSetCapacity;
  end;

  TnxList = class(TnxWriteableList)
  protected
    procedure liPut(aIndex: Integer; Item: Pointer);
    procedure liSetCount(aNewCount: Integer);
  public
    function Add(aItem: Pointer): Integer; override;
    procedure Insert(aIndex: Integer; Item: Pointer);

    procedure Pack;
    procedure Sort(Compare: TListSortCompare);

    procedure Exchange(aIndex1, aIndex2: Integer);
    procedure Move(aCurIndex, aNewIndex: Integer);

    function IndexOf(aItem: Pointer): Integer; override;

    property Count: Integer
      read blCount
      write liSetCount;

    property Items[aIndex: Integer]: Pointer
      read blGet
      write liPut; default;
  end;

  TnxSortedList = class(TnxWriteableList)
  protected
    function slCompare(a, b : Pointer) : TnxValueRelationship; virtual;
  public
    function Add(aItem: Pointer): Integer; override;
    function IndexOf(aItem: Pointer): Integer; override;
    function Find(aItem: Pointer; out aIndex: Integer): Boolean;
  end;

  TnxListSyncAccess = class(TnxObject)
  protected
    lsaList: TnxWriteableList;
  public
    constructor Create(aList: TnxWriteableList); virtual;
    destructor Destroy; override;

    function BeginRead: TnxBaseList; virtual;
    procedure EndRead; virtual;

    function BeginWrite: TnxWriteableList; virtual; abstract;
    procedure EndWrite; virtual; abstract;

    procedure Add(aItem: Pointer);
    procedure Remove(aItem: Pointer);
    procedure Clear;
  end;

  TnxListPortal = class(TnxListSyncAccess)
  protected
    lptPortal : TnxReadWritePortal;
  public
    constructor Create(aList: TnxWriteableList); override;
    destructor Destroy; override;

    function BeginRead: TnxBaseList; override;
    procedure EndRead; override;

    function BeginWrite: TnxWriteableList; override;
    procedure EndWrite; override;
  end;

  TnxListPadlock = class(TnxListSyncAccess)
  protected
    lplPadlock : TnxPadlock;
  public
    constructor Create(aList: TnxWriteableList); override;
    destructor Destroy; override;

    function BeginWrite: TnxWriteableList; override;
    procedure EndWrite; override;
  end;


procedure QuickSort(SortList, DataList: PPointerList; L, R: Integer;
  SCompare: TListSortCompare);

implementation

uses
  {$IFDEF DCC6OrLater}
  RTLConsts,
  {$ELSE}
  Consts,
  {$ENDIF}
  SysUtils,
  nxllUtils;

{===QuickSort==================================================================}
procedure QuickSort(SortList, DataList: PPointerList; L, R: Integer;
  SCompare: TListSortCompare);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do
        Inc(I);
      while SCompare(SortList^[J], P) > 0 do
        Dec(J);
      if I <= J then begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        if Assigned(DataList) then begin
          T := DataList^[I];
          DataList^[I] := DataList^[J];
          DataList^[J] := T;
        end;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(SortList, DataList, L, J, SCompare);
    L := I;
  until I >= R;
end;
{==============================================================================}



{===TnxBaseList================================================================}
function TnxBaseList.blGet(aIndex: Integer): Pointer;
begin
  if (aIndex < 0) or (aIndex >= blCount) then
    Error(@SListIndexError, aIndex);
  Result := blList^[aIndex];
end;
{------------------------------------------------------------------------------}
function TnxBaseList.First: Pointer;
begin
  Result := blGet(0);
end;
{------------------------------------------------------------------------------}
function TnxBaseList.Last: Pointer;
begin
  Result := blGet(Pred(blCount));
end;
{------------------------------------------------------------------------------}
class procedure TnxBaseList.Error(Msg: PResStringRec; Data: Integer);
begin
  TnxBaseList.Error(LoadResString(Msg), Data);
end;
{------------------------------------------------------------------------------}
class procedure TnxBaseList.Error(const Msg: string; Data: Integer);
  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;
{==============================================================================}



{===TnxWriteableList===========================================================}
procedure TnxWriteableList.Clear;
begin
  blCount := 0;
  wlSetCapacity(wlInitCapacity);
end;
{------------------------------------------------------------------------------}
constructor TnxWriteableList.Create(aInitCapacity : Integer;
                                    aUseData      : Boolean);
begin
  blUseData := aUseData;
  wlInitCapacity := aInitCapacity;
  if wlInitCapacity < 0 then
    wlInitCapacity := 0;

  if aInitCapacity > 0 then
    wlSetCapacity(aInitCapacity);

  inherited Create;
end;
{------------------------------------------------------------------------------}
procedure TnxWriteableList.Delete(aIndex: Integer);
begin
  if (aIndex < 0) or (aIndex >= blCount) then
    Error(@SListIndexError, aIndex);
  Dec(blCount);
  if aIndex < blCount then begin
    nxMove(blList^[Succ(aIndex)], blList^[aIndex],
      (blCount - aIndex) * SizeOf(Pointer));
    if blUseData then
      nxMove(blData^[Succ(aIndex)], blData^[aIndex],
        (blCount - aIndex) * SizeOf(Pointer));
  end;
end;
{------------------------------------------------------------------------------}
destructor TnxWriteableList.Destroy;
begin
  wlInitCapacity := 0;
  Clear;
  inherited;
end;
{------------------------------------------------------------------------------}
function TnxWriteableList.Remove(aItem: Pointer): Integer;
begin
  Result := IndexOf(aItem);
  if Result >= 0 then
    Delete(Result);
end;
{------------------------------------------------------------------------------}
procedure TnxWriteableList.wlGrow;
var
  Delta: Integer;
begin
  if blCapacity > 64 then
    Delta := blCapacity div 4
  else
    if blCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  wlSetCapacity(blCapacity + Delta);
end;
{------------------------------------------------------------------------------}
procedure TnxWriteableList.wlSetCapacity(aNewCapacity: Integer);
begin
  if (aNewCapacity < blCount) or (aNewCapacity > MaxListSize) then
    Error(@SListCapacityError, aNewCapacity);
  if aNewCapacity <> blCapacity then begin
    nxReallocMem(blList, aNewCapacity * SizeOf(Pointer));
    if blUseData then
      nxReallocMem(blData, aNewCapacity * SizeOf(Pointer));
    blCapacity := aNewCapacity;
  end;
end;
{==============================================================================}



{===TnxList====================================================================}
function TnxList.Add(aItem: Pointer): Integer;
begin
  Result := blCount;
  if Result = blCapacity then
    wlGrow;
  blList^[Result] := aItem;
  if blUseData then
    blData^[Result] := nil;
  Inc(blCount);
end;
{------------------------------------------------------------------------------}
procedure TnxList.Exchange(aIndex1, aIndex2: Integer);
var
  Item: Pointer;
begin
  if (aIndex1 < 0) or (aIndex1 >= blCount) then
    Error(@SListIndexError, aIndex1);
  if (aIndex2 < 0) or (aIndex2 >= blCount) then
    Error(@SListIndexError, aIndex2);
  Item := blList^[aIndex1];
  blList^[aIndex1] := blList^[aIndex2];
  blList^[aIndex2] := Item;
  if blUseData then begin
    Item := blData^[aIndex1];
    blData^[aIndex1] := blData^[aIndex2];
    blData^[aIndex2] := Item;
  end;
end;
{------------------------------------------------------------------------------}
function TnxList.IndexOf(aItem: Pointer): Integer;
begin
  Result := 0;
  while (Result < blCount) and (blList^[Result] <> aItem) do
    Inc(Result);
  if Result = blCount then
    Result := -1;
end;
{------------------------------------------------------------------------------}
procedure TnxList.Insert(aIndex: Integer; Item: Pointer);
begin
  if (aIndex < 0) or (aIndex > blCount) then
    Error(@SListIndexError, aIndex);
  if blCount = blCapacity then
    wlGrow;
  if aIndex < blCount then begin
    nxMove(blList^[aIndex], blList^[Succ(aIndex)],
      (blCount - aIndex) * SizeOf(Pointer));
    if blUseData then
      nxMove(blData^[aIndex], blData^[Succ(aIndex)],
        (blCount - aIndex) * SizeOf(Pointer));
  end;
  blList^[aIndex] := Item;
  if blUseData then
    blData^[aIndex] := nil;
  Inc(blCount);
end;
{------------------------------------------------------------------------------}
procedure TnxList.liPut(aIndex: Integer; Item: Pointer);
begin
  if (aIndex < 0) or (aIndex >= blCount) then
    Error(@SListIndexError, aIndex);
  blList^[aIndex] := Item;
end;
{------------------------------------------------------------------------------}
procedure TnxList.liSetCount(aNewCount: Integer);
begin
  if (aNewCount < 0) or (aNewCount > MaxListSize) then
    Error(@SListCountError, aNewCount);
  if aNewCount > blCapacity then
    wlSetCapacity(aNewCount);
  if aNewCount > blCount then begin
    nxFillChar(blList^[blCount], (aNewCount - blCount) * SizeOf(Pointer), 0);
    if blUseData then
      nxFillChar(blData^[blCount], (aNewCount - blCount) * SizeOf(Pointer), 0);
  end;
  blCount := aNewCount;
end;
{------------------------------------------------------------------------------}
procedure TnxList.Move(aCurIndex, aNewIndex: Integer);
var
  Item: Pointer;
begin
  if aCurIndex <> aNewIndex then begin
    if (aNewIndex < 0) or (aNewIndex >= blCount) then
      Error(@SListIndexError, aNewIndex);
    Item := blGet(aCurIndex);
    Delete(aCurIndex);
    Insert(aNewIndex, Item);
  end;
end;
{------------------------------------------------------------------------------}
procedure TnxList.Pack;
var
  i, j: Integer;
begin
  i := 0;
  j := 0;
  while i < blCount do begin
    if blList[i] <> nil then begin
      if i <> j then begin
        blList[j] := blList[i];
        if blUseData  then
          blData[j] := blData[i];
      end;
      Inc(j);
    end;
    Inc(i);
  end;
  blCount := j;
end;
{------------------------------------------------------------------------------}
procedure TnxList.Sort(Compare: TListSortCompare);
begin
  if (blList <> nil) and (blCount > 0) then
    QuickSort(blList, blData, 0, Pred(blCount), Compare);
end;
{==============================================================================}



{==============================================================================}
function TnxSortedList.Add(aItem: Pointer): Integer;
begin
  if not Find(aItem, Result) then begin
    if blCount = blCapacity then
      wlGrow;
    if Result < blCount then begin
      nxMove(blList^[Result], blList^[Succ(Result)],
        (blCount - Result) * SizeOf(Pointer));
      if blUseData then
        nxMove(blData^[Result], blData^[Succ(Result)],
          (blCount - Result) * SizeOf(Pointer));
    end;
    blList^[Result] := aItem;
    if blUseData then
      blData^[Result] := nil;
    Inc(blCount);
  end;
end;
{------------------------------------------------------------------------------}
function TnxSortedList.Find(aItem: Pointer; out aIndex: Integer): Boolean;
var
  l, h: Integer;
begin
  Result := False;
  l := 0;
  h := Pred(blCount);
  aIndex := 0;
  while l <= h do begin
    aIndex := (l + h) shr 1;
    case slCompare(blList^[aIndex], aItem) of
//      nxSmallerThan: h := Pred(aIndex);
//      nxGreaterThan: l := Succ(aIndex);
      nxSmallerThan: l := Succ(aIndex);
      nxGreaterThan: h := Pred(aIndex);
    else
      Result := True;
      Break;
    end;
  end;

  if not Result then
    aIndex := l;
end;
{------------------------------------------------------------------------------}
function TnxSortedList.IndexOf(aItem: Pointer): Integer;
begin
  if not Find(aItem, Result) then
    Result := -1;
end;
{------------------------------------------------------------------------------}
function TnxSortedList.slCompare(a, b: Pointer): TnxValueRelationship;
begin
  Result := nxCmpPtr(a, b);
end;
{==============================================================================}



{===TnxListSyncAccess==========================================================}
procedure TnxListSyncAccess.Add(aItem: Pointer);
begin
  with BeginWrite do try
    Add(aItem);
  finally
    EndWrite;
  end;
end;
{------------------------------------------------------------------------------}
function TnxListSyncAccess.BeginRead: TnxBaseList;
begin
  Result := BeginWrite;
end;
{------------------------------------------------------------------------------}
procedure TnxListSyncAccess.Clear;
begin
  with BeginWrite do try
    Clear;
  finally
    EndWrite;
  end;
end;
{------------------------------------------------------------------------------}
constructor TnxListSyncAccess.Create(aList: TnxWriteableList);
begin
  lsaList := aList;
  inherited Create;
end;
{------------------------------------------------------------------------------}
destructor TnxListSyncAccess.Destroy;
begin
  nxFreeAndNil(lsaList);
  inherited;
end;
{------------------------------------------------------------------------------}
procedure TnxListSyncAccess.EndRead;
begin
  EndWrite;
end;
{------------------------------------------------------------------------------}
procedure TnxListSyncAccess.Remove(aItem: Pointer);
begin
  with BeginWrite do try
    Remove(aItem);
  finally
    EndWrite;
  end;
end;
{==============================================================================}



{==============================================================================}
function TnxListPortal.BeginRead: TnxBaseList;
begin
  lptPortal.BeginRead;
  Result := lsaList;
end;
{------------------------------------------------------------------------------}
function TnxListPortal.BeginWrite: TnxWriteableList;
begin
  lptPortal.BeginWrite;
  Result := lsaList;
end;
{------------------------------------------------------------------------------}
constructor TnxListPortal.Create(aList: TnxWriteableList);
begin
  lptPortal := TnxReadWritePortal.Create;
  inherited;
end;
{------------------------------------------------------------------------------}
destructor TnxListPortal.Destroy;
begin
  inherited;
  nxFreeAndNil(lptPortal);
end;
{------------------------------------------------------------------------------}
procedure TnxListPortal.EndRead;
begin
  lptPortal.EndRead;
end;
{------------------------------------------------------------------------------}
procedure TnxListPortal.EndWrite;
begin
  lptPortal.EndWrite;
end;
{==============================================================================}



{===TnxListPadlock=============================================================}
function TnxListPadlock.BeginWrite: TnxWriteableList;
begin
  lplPadlock.Lock;
  Result := lsaList;
end;
{------------------------------------------------------------------------------}
constructor TnxListPadlock.Create(aList: TnxWriteableList);
begin
  lplPadlock := TnxPadlock.Create;
  inherited;
end;
{------------------------------------------------------------------------------}
destructor TnxListPadlock.Destroy;
begin
  inherited;
  nxFreeAndNil(lplPadlock);
end;
{------------------------------------------------------------------------------}
procedure TnxListPadlock.EndWrite;
begin
  lplPadlock.Unlock;
end;
{==============================================================================}

end.
