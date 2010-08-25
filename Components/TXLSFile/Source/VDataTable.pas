unit VDataTable;
{-----------------------------------------------------------------
    SM Software, 2000-2004

    Virtual data table
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, HList, XLSBase;

type
  { TVirtualDataTable }
  TVirtualDataTable = class
  private
    FDataTable: THashedStringList;
    function GetCount: Integer;
    function GetItem(Index: Integer): AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddItem(const AItem: AnsiString): Integer;
    function AddItemWithDuplicates(const AItem: AnsiString): Integer;
    function FindItem(const AItem: AnsiString): Integer;
    function ChangeItem(const AOldItem: AnsiString; const AItem: AnsiString): Integer;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: AnsiString read GetItem;
  end;

implementation

{ TVirtualDataTable }
constructor TVirtualDataTable.Create;
begin
  FDataTable:= THashedStringList.Create(1024 * 16 - 1); 
end;

destructor TVirtualDataTable.Destroy;
begin
  FDataTable.Destroy;
  inherited;
end;

function TVirtualDataTable.GetCount: Integer;
begin
  Result:= FDataTable.Count;
end;

function TVirtualDataTable.GetItem(Index: Integer): AnsiString;
begin
  Result:= FDataTable.Item[Index];
end;

procedure TVirtualDataTable.Clear;
begin
  FDataTable.Clear;
end;

function TVirtualDataTable.AddItem(const AItem: AnsiString): Integer;
var
  LItem: AnsiString;
begin
  LItem:= AItem;
  { If AItem already exists then return its index }
  Result:= FDataTable.IndexByKey(LItem);
  if Result < 0 then
  begin
    FDataTable.Add(AItem);
    Result:= FDataTable.Count - 1; // 0-based index
  end;
end;

function TVirtualDataTable.AddItemWithDuplicates(const AItem: AnsiString): Integer;
begin
  FDataTable.Add(AItem);
  Result:= FDataTable.Count - 1; // 0-based index
end;

function TVirtualDataTable.FindItem(const AItem: AnsiString): Integer;
var
  LItem: AnsiString;
begin
  LItem:= AItem;
  Result:= FDataTable.IndexByKey(LItem);
end;

function TVirtualDataTable.ChangeItem(const AOldItem: AnsiString;
  const AItem: AnsiString): Integer;
var
  OldIndex: Integer;
begin
  { If items are identical then do nothing }
  if AOldItem = AItem then
  begin
    OldIndex:= FindItem(AOldItem);  
    Result:= OldIndex;
    Exit;
  end;

  { Add new item }
  Result:= AddItem(AItem);
end;

end.
