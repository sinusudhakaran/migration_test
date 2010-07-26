unit HList;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    Hash Table, Hashed Lists
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses classes
   , SysUtils
   , XCrc32
   , Lists
   , XLSBase;

{$IFDEF XLF_D3}
type
  Longword = Cardinal;
{$ENDIF}

type
  TItemGetKeyProc = procedure (AItem: Pointer; var Key: AnsiString) of object;

  THItemType = Pointer;

  {TCustomHashTable}
  TCustomHashTable = class
  protected
    FHBuckets: TList;
    FHTableSize: Longword;
    FOnGetKey: TItemGetKeyProc;
    FFound: boolean;
    function HashFunction(Key: PAnsiChar; Count: Integer): Longword;
    function ItemByKey(var Key: AnsiString): Pointer; virtual;
    procedure GetKey(AItem: Pointer; var Key: AnsiString); virtual;
    procedure Add(AItem: Pointer); virtual;
    procedure Remove(AItem: Pointer); virtual;
    procedure Error(Code: Integer);
    procedure Clear;
  public
    constructor Create(AHTableSize: Longword; AOnItemKey: TItemGetKeyProc); virtual;
    destructor Destroy; override;
  end;

  THashTable = class(TCustomHashTable);

  {THashedList}
  THashedList = class(THashTable)
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Ind: Integer): Pointer;
  protected
    procedure GetKey(AItem: Pointer; var Key: AnsiString); override;
  public
    constructor Create(AHTableSize: Longword; AOnItemKey: TItemGetKeyProc); override;
    destructor Destroy; override;
    procedure Add(AItem: Pointer); override;
    procedure RemoveItemByKey(var Key: AnsiString);
    procedure ItemKeyChanged(Index: Integer; var AOldKey: AnsiString);
    function ItemByKey(var Key: AnsiString): Pointer; override;
    function IndexByKey(var Key: AnsiString): Integer;
    property Count: Integer read GetCount;
    property Item[Ind: Integer]: Pointer read GetItem; default;
  end;

  {THashedStringList}
  THashedStringList = class
  private
    FList: TAnsiStringList;
    FHashTable: THashTable;
    function GetCount: Integer;
    function GetItem(Ind: Integer): AnsiString;
  protected
    procedure GetKey(AItem: Pointer; var Key: AnsiString);
  public
    constructor Create(AHTableSize: Longword);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const AItem: AnsiString);
    function ItemByKey(var Key: AnsiString): AnsiString;
    function IndexByKey(var Key: AnsiString): Integer;
    property Count: Integer read GetCount;
    property Item[Ind: Integer]: AnsiString read GetItem; default;
  end;

  {EHashTable}
  EHashTable = Exception;

const
  EHTABLE_BAD_SIZE = 1;


implementation

{TCustomHashTable}
constructor TCustomHashTable.Create(AHTableSize: Longword; AOnItemKey: TItemGetKeyProc);
var
  I: Longword;
begin
  FHTableSize:= AHTableSize;
  FFound:= false;
  if FHTableSize = 0 then
    Error(EHTABLE_BAD_SIZE);

  FHBuckets:= TList.Create;
  FHBuckets.Capacity:= FHTableSize;
  for I:= 0 to FHTableSize - 1 do
    FHBuckets.Add(nil);

  if Assigned(AOnItemKey) then
    FOnGetKey:= AOnItemKey;
end;

destructor TCustomHashTable.Destroy;
begin
  Clear;
  FHBuckets.Destroy;
  inherited;
end;

procedure TCustomHashTable.Clear;
var
  I: Longword;
begin
  for I:= 0 to FHTableSize - 1 do
  begin
    if Assigned(FHBuckets[I]) then
    begin
      TList(FHBuckets[I]).Destroy;
      FHBuckets[I]:= nil;
    end;
  end;
end;

procedure TCustomHashTable.Error(Code: Integer);
var
  S: String;
begin
  case Code of
    EHTABLE_BAD_SIZE:
      S:= 'Bad hash table size !';
  end;
  raise EHashTable.Create(S);
end;

function TCustomHashTable.HashFunction(Key: PAnsiChar; Count: Integer): Longword;
begin
  { crc32 }
  Result:= (BloCrc32($0FFFFFFF, Count, Key)) mod FHTableSize;
end;

procedure TCustomHashTable.GetKey(AItem: Pointer; var Key: AnsiString);
begin
  if Assigned(FOnGetKey) then FOnGetKey(AItem, Key);
end;

procedure TCustomHashTable.Add(AItem: Pointer);
var
  HV: Longword;
  HB: TList;
  Key: AnsiString;
begin
  GetKey(AItem, Key);
  HV:= HashFunction(@Key[1], Length(Key));
  HB:= TList(FHBuckets[HV]);
  if not Assigned(HB) then begin
    HB:= TList.Create;
    FHBuckets[HV]:=HB;
  end;
  HB.Add(AItem);
end;

procedure TCustomHashTable.Remove(AItem: Pointer);
var
  HV: Longword;
  HB: TList;
  Key: AnsiString;
  I: Integer;
begin
  GetKey(AItem, Key);
  HV:= HashFunction(@Key[1], Length(Key));
  HB:= TList(FHBuckets[HV]);
  if Assigned(HB) then begin
    I:= HB.IndexOf(AItem);
    if I>=0 then HB.Delete(I);
  end;
end;

function TCustomHashTable.ItemByKey(var Key: AnsiString): Pointer;
var
  HV: Longword;
  HB: TList;
  I: Integer;
  AKey: AnsiString;
begin
  FFound:= false;
  result:= nil;

  HV:=  HashFunction(@Key[1], Length(Key));
  HB:= TList(FHBuckets[HV]);
  if Assigned(HB) then
    for I:= 0 to HB.Count -1 do
    begin
      GetKey(HB[I], AKey);
      if Key = AKey then
      begin
        result:= HB[I];
        FFound:= true;
        break;
      end;
    end;
end;

{THashedList}
constructor THashedList.Create(AHTableSize: Longword; AOnItemKey: TItemGetKeyProc);
begin
  inherited;
  FList:= TList.Create;
end;

destructor THashedList.Destroy;
begin
  FList.Destroy;
  inherited;
end;

procedure THashedList.GetKey(AItem: Pointer; var Key: AnsiString);
var
  Ind: Integer;
begin
  Ind:= Integer(AItem);
  inherited GetKey(FList[Ind], Key);
end;

procedure THashedList.Add(AItem: Pointer);
var
  Ind: Integer;
begin
  FList.Add(AItem);
  Ind:= FList.Count - 1;
  inherited Add(Pointer(Ind));
end;

procedure THashedList.RemoveItemByKey(var Key: AnsiString);
var
  PInd: Pointer;
  Index, BucketIndex, I: Integer;
  Bucket: TList;
begin
  PInd:= inherited ItemByKey(Key);
  if FFound then
  begin
    Index:= Integer(PInd);
    inherited Remove(PInd);
    FList.Delete(Index);

    {Shift all hashtable elements}
    for BucketIndex:= 0 to FHBuckets.Count - 1 do
    begin
      Bucket:= FHBuckets[BucketIndex];
      if Assigned(Bucket) then
        for I:= 0 to Bucket.Count - 1 do
          if Integer(Bucket[I])> Index then
            Bucket[I]:= Pointer(Integer(Bucket[I]) - 1);
    end;
  end;
end;

function THashedList.ItemByKey(var Key: AnsiString): Pointer;
var
  PInd: Pointer;
begin
  result:= nil;
  PInd:= inherited ItemByKey(Key);
  if FFound then
    result:= FList[Integer(PInd)]
end;

function THashedList.IndexByKey(var Key: AnsiString): Integer;
var
  PInd: Pointer;
begin
  result:= -1;
  PInd:= inherited ItemByKey(Key);
  if FFound then
    result:= Integer(PInd);
end;

procedure THashedList.ItemKeyChanged(Index: Integer; var AOldKey: AnsiString);
var
  BucketIndex, I: Integer;
  Bucket: TList;
begin
  BucketIndex:=  HashFunction(@AOldKey[1], Length(AOldKey));

  { unlink old key }
  Bucket:= FHBuckets[BucketIndex];
  if Assigned(Bucket) then
    for I:= 0 to Bucket.Count - 1 do
      if Integer(Bucket[I])= Index then
      begin
        Bucket.Delete(I);
        break;
      end;

  { insert with new key }
  inherited Add(Pointer(Index));
end;

function THashedList.GetCount: Integer;
begin
  result:= FList.Count;
end;

function THashedList.GetItem(Ind: Integer): Pointer;
begin
  Result:= FList[Ind];
end;

{THashedStringList}
constructor THashedStringList.Create(AHTableSize: Longword);
begin
  FHashTable:= THashTable.Create(AHTableSize, GetKey);
  FList:= TAnsiStringList.Create;
end;

destructor THashedStringList.Destroy;
begin
  FList.Destroy;
  FHashTable.Destroy;
  inherited;
end;

procedure THashedStringList.Clear;
begin
  FList.Clear;
  FHashTable.Clear;
end;

procedure THashedStringList.GetKey(AItem: Pointer; var Key: AnsiString);
var
  Ind: Integer;
begin
  Ind:= Integer(AItem);
  Key:= FList[Ind];
end;

procedure THashedStringList.Add(const AItem: AnsiString);
var
  Ind: Integer;
begin
  FList.Add(AItem);
  Ind:= FList.Count - 1;
  FHashTable.Add(Pointer(Ind));
end;

function THashedStringList.ItemByKey(var Key: AnsiString): AnsiString;
var
  PInd: Pointer;
begin
  PInd:= FHashTable.ItemByKey(Key);
  if FHashTable.FFound then
    result:= FList[Integer(PInd)]
  else
    result:= '';
end;

function THashedStringList.IndexByKey(var Key: AnsiString): Integer;
var
  PInd: Pointer;
begin
  result:= -1;
  PInd:= FHashTable.ItemByKey(Key);
  if FHashTable.FFound then
    result:= Integer(PInd);
end;

function THashedStringList.GetCount: Integer;
begin
  result:= FList.Count;
end;

function THashedStringList.GetItem(Ind: Integer): AnsiString;
begin
  result:= FList[Ind];
end;

end.

