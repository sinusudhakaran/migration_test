unit smList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKsmIO,
  smObj32,
  IOSTREAM,
  Math,
  SysUtils,
  TOKENS,
  LogUtil,
  BKDbExcept,
  StDate,
  bkDateUtils,
  MoneyDef,
  bkConst;

type
  //----------------------------------------------------------------------------
  pSuggested_Mem_Index_Rec = ^TSuggested_Mem_Index_Rec;
  TSuggested_Mem_Index_Rec = Packed Record
    Id       : Integer;
    TypeId   : byte;
    PhraseId : Integer;
  end;

const
  Suggested_Mem_Index_Rec_Size = Sizeof(TSuggested_Mem_Index_Rec);

type
  //----------------------------------------------------------------------------
  TSuggested_Mem_Index = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

  //----------------------------------------------------------------------------
  TSuggested_Mem_List = class(TExtdSortedCollection)
  private
    fHighId : integer;
    fSuggested_Mem_Index : TSuggested_Mem_Index;

  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    destructor Destroy; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    function Insert_Suggested_Mem_Rec(var aSuggested_Mem : TSuggested_Mem; aNew : Boolean = true) : integer;
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function SearchUsingSuggestedId(aSuggestedId : integer; var aIndex : integer) : Boolean;
    function SearchUsingTypeAndPhraseId(aTypeId : byte; aPhraseId : integer; var aIndex : integer) : Boolean;

    function  GetPRec(aIndex: integer): pSuggested_Mem_Rec;
    function  GetIndexPRec(aIndex: integer): pSuggested_Mem_Index_Rec;

    function  Suggested_Mem_At(aIndex: integer): TSuggested_Mem;

    function  GetAs_pRec(aItem: TSuggested_Mem): pSuggested_Mem_Rec;

    property Suggested_Mem_Index : TSuggested_Mem_Index read fSuggested_Mem_Index;
  end;

//------------------------------------------------------------------------------
implementation

uses
  MALLOC;

const
  UnitName = 'smList32';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TSuggested_Mem_Index.NewItem';

{ TSuggested_Mem_Index }
//------------------------------------------------------------------------------
function TSuggested_Mem_Index.NewItem: Pointer;
var
  P : pSuggested_Mem_Index_Rec;
Begin
  SafeGetMem( P, Suggested_Mem_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Suggested_Mem_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Mem_Index.FreeItem(Item: Pointer);
begin
  SafeFreeMem(Item, Suggested_Mem_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
constructor TSuggested_Mem_Index.Create;
begin
  inherited;

end;

//------------------------------------------------------------------------------
function TSuggested_Mem_Index.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(pSuggested_Mem_Index_Rec(Item1)^.TypeId,
                         pSuggested_Mem_Index_Rec(Item2)^.TypeId);

  if Result <> 0 then
    Exit;

  Result := CompareValue(pSuggested_Mem_Index_Rec(Item1)^.PhraseId,
                         pSuggested_Mem_Index_Rec(Item2)^.PhraseId);
end;

{ TSuggested_Mem_List }
//------------------------------------------------------------------------------
constructor TSuggested_Mem_List.Create;
begin
  inherited Create;

  fSuggested_Mem_Index := TSuggested_Mem_Index.Create;

  fHighId := 0;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
destructor TSuggested_Mem_List.Destroy;
begin
  FreeAndNil(fSuggested_Mem_Index);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Mem_List.DeleteFreeAll;
var
  index : integer;
begin
  fHighId := 0;
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);

  fSuggested_Mem_Index.FreeAll;
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(TSuggested_Mem(Item1).smFields.smId,
                         TSuggested_Mem(Item2).smFields.smId);
end;

//------------------------------------------------------------------------------
procedure TSuggested_Mem_List.FreeItem(Item: Pointer);
var
  P: TSuggested_Mem;
begin
  P := TSuggested_Mem(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.Insert_Suggested_Mem_Rec(var aSuggested_Mem : TSuggested_Mem; aNew : boolean) : integer;
var
  NewSuggested_Mem_Index_Rec : pSuggested_Mem_Index_Rec;
begin
  Result := -1;

  if aNew then
  begin
    Inc( fHighId );
    aSuggested_Mem.smFields.smId := fHighId;
  end
  else
  begin
    if fHighId < aSuggested_Mem.smFields.smId then
      fHighId := aSuggested_Mem.smFields.smId;
  end;
  Result := fHighId;

  NewSuggested_Mem_Index_Rec := fSuggested_Mem_Index.NewItem;
  NewSuggested_Mem_Index_Rec^.Id       := aSuggested_Mem.smFields.smId;
  NewSuggested_Mem_Index_Rec^.TypeId   := aSuggested_Mem.smFields.smTypeId;
  NewSuggested_Mem_Index_Rec^.PhraseId := aSuggested_Mem.smFields.smPhraseId;

  fSuggested_Mem_Index.Insert(NewSuggested_Mem_Index_Rec);

  Inherited Insert( aSuggested_Mem );
end;

//------------------------------------------------------------------------------
procedure TSuggested_Mem_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Mem_List.SaveToFile';
var
  i: integer;
  Item: TSuggested_Mem;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginSuggested_Mem_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Suggested_Mem_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TSuggested_Mem_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Mem_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TSuggested_Mem;
  NewSuggested_Mem_Index_Rec : pSuggested_Mem_Index_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;

  fSuggested_Mem_Index.SortingOn := false;
  SortingOn := false;

  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Suggested_Mem) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TSuggested_Mem.Create;
    try
      P.LoadFromFile(S);

      Insert_Suggested_Mem_Rec(P, false);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  fSuggested_Mem_Index.SortingOn := true;
  SortingOn := true;

  fSuggested_Mem_Index.Sort();
  Sort();

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.SearchUsingSuggestedId(aSuggestedId: integer; var aIndex: integer): Boolean;
var
  SearchSuggested_Mem : TSuggested_Mem;
begin
  SearchSuggested_Mem := TSuggested_Mem.Create;
  try
    SearchSuggested_Mem.smFields.smId := aSuggestedId;
    Result := Search(SearchSuggested_Mem, aIndex);
  finally
    FreeAndNil(SearchSuggested_Mem);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.SearchUsingTypeAndPhraseId(aTypeId : byte; aPhraseId: integer; var aIndex: integer): Boolean;
var
  SearchpSuggested_Mem_Index_Rec : pSuggested_Mem_Index_Rec;
begin
  SearchpSuggested_Mem_Index_Rec := fSuggested_Mem_Index.NewItem;
  try
    SearchpSuggested_Mem_Index_Rec.TypeId   := aTypeId;
    SearchpSuggested_Mem_Index_Rec.PhraseId := aPhraseId;
    Result := fSuggested_Mem_Index.Search(SearchpSuggested_Mem_Index_Rec, aIndex);
  finally
    fSuggested_Mem_Index.FreeItem(SearchpSuggested_Mem_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.GetPRec(aIndex: integer): pSuggested_Mem_Rec;
begin
  Result := TSuggested_Mem(At(aIndex)).As_pRec;
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.GetIndexPRec(aIndex: integer): pSuggested_Mem_Index_Rec;
begin
  Result := fSuggested_Mem_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.Suggested_Mem_At(aIndex: integer): TSuggested_Mem;
var
  P: Pointer;
Begin
  P := At(aIndex);

  result := TSuggested_Mem(P);
end;

//------------------------------------------------------------------------------
function TSuggested_Mem_List.GetAs_pRec(aItem: TSuggested_Mem): pSuggested_Mem_Rec;
begin
  if Assigned(aItem) then
    result := aItem.As_pRec
  else
    result := nil;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
