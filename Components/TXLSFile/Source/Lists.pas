unit Lists;

interface
uses Classes, XLSBase;

type
  { TAnsiStringListItem }
  TAnsiStringListItem = packed record
    S: AnsiString;
  end;
  PAnsiStringListItem = ^TAnsiStringListItem;

  { TAnsiStringList }
  TAnsiStringList = class
  protected
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): AnsiString;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: AnsiString): Integer;
    function IndexOf(const S: AnsiString): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Sort;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: AnsiString read GetItem; default;
  end;

  {TOrderedList}
  TOrderedList = class(TObject)
  private
    FList: TList;
  protected
    procedure PushItem(AItem: Pointer); virtual; abstract;
    function PopItem: Pointer; virtual;
    function PeekItem: Pointer; virtual;
    property List: TList read FList;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    procedure Push(AItem: Pointer);
    function Pop: Pointer;
    function Peek: Pointer;
  end;

  {TStack}
  TStack = class(TOrderedList)
  protected
    procedure PushItem(AItem: Pointer); override;
  end;

  {TStringStack}
  TStringStack = class(TAnsiStringList)
  public
    function AtLeast(ACount: Integer): Boolean;
    procedure Push(AItem: AnsiString);
    function Pop: AnsiString;
    function Peek: AnsiString;
  end;

implementation

uses SysUtils;

{ TAnsiStringList }
constructor TAnsiStringList.Create;
begin
  FList:= TList.Create;
end;

destructor TAnsiStringList.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FList.Count - 1 do
  begin
    if Assigned(FList[I]) then
      Dispose(PAnsiStringListItem(FList[I]));
  end;
  FList.Free;

  inherited;
end;

procedure TAnsiStringList.Clear;
var
  I: Integer;
begin
  for I:= 0 to FList.Count - 1 do
  begin
    if Assigned(FList[I]) then
      Dispose(PAnsiStringListItem(FList[I]));
  end;
  FList.Clear;
end;

function TAnsiStringList.GetCount: Integer;
begin
  Result:= FList.Count;
end;

function TAnsiStringList.GetItem(Index: Integer): AnsiString;
begin
  Result:= PAnsiStringListItem(FList[Index])^.S;
end;

function TAnsiStringList.Add(const S: AnsiString): Integer;
var
  PNewItem: PAnsiStringListItem;
begin
  New(PNewItem);
  PNewItem^.S:= S;
  FList.Add(PNewItem);
  Result:= FList.Count;
end;

procedure TAnsiStringList.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FList.Count) then
  begin
    Dispose(PAnsiStringListItem(FList[Index]));
    FList.Delete(Index);
  end;
end;

function TAnsiStringList.IndexOf(const S: AnsiString): Integer;
var
  I: Integer;
begin
  Result:= -1;
  for I:= 0 to FList.Count - 1 do
    if (PAnsiStringListItem(FList[I])^.S = S) then
    begin
      Result:= I;
      Exit;
    end;
end;

function AnsiStringListItemCompare(Item1, Item2: Pointer): Integer;
begin
  Result:= AnsiStrComp(
      PAnsiChar(PAnsiStringListItem(Item1)^.S)
    , PAnsiChar(PAnsiStringListItem(Item2)^.S));
end;

procedure TAnsiStringList.Sort;
begin
  FList.Sort(AnsiStringListItemCompare);
end;

{TOrderedList}
function TOrderedList.AtLeast(ACount: integer): boolean;
begin
  Result := List.Count >= ACount;
end;

function TOrderedList.Peek: Pointer;
begin
  Result := PeekItem;
end;

function TOrderedList.Pop: Pointer;
begin
  Result := PopItem;
end;

procedure TOrderedList.Push(AItem: Pointer);
begin
  PushItem(AItem);
end;

function TOrderedList.Count: Integer;
begin
  Result := List.Count;
end;

constructor TOrderedList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TOrderedList.Destroy;
begin
  List.Free;
  inherited Destroy;
end;

function TOrderedList.PeekItem: Pointer;
begin
  Result := List[List.Count-1];
end;

function TOrderedList.PopItem: Pointer;
begin
  Result := PeekItem;
  List.Delete(List.Count-1);
end;

{TStack}
procedure TStack.PushItem(AItem: Pointer);
begin
  List.Add(AItem);
end;

{TStringStack}
function TStringStack.AtLeast(ACount: Integer): Boolean;
begin
  Result := Self.Count >= ACount;
end;

procedure TStringStack.Push(AItem: AnsiString);
begin
  Self.Add(AItem);
end;

function TStringStack.Pop: AnsiString;
begin
  Result:= Self[Self.Count - 1];
  Self.Delete(Self.Count - 1);
end;

function TStringStack.Peek: AnsiString;
begin
  Result:= Self[Self.Count - 1];
end;

end.
