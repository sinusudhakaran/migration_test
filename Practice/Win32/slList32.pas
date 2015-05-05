unit slList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKslIO,
  slObj32,
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
  pSuggested_Account_Link_Index_Rec = ^TSuggested_Account_Link_Index_Rec;
  TSuggested_Account_Link_Index_Rec = Packed Record
    SuggestedId : Integer;
    AccountId   : Integer;
  end;

const
  Suggested_Account_Link_Index_Rec_Size = Sizeof(TSuggested_Account_Link_Index_Rec);

type
  //----------------------------------------------------------------------------
  TSuggested_Account_Link_Index = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

  //----------------------------------------------------------------------------
  TSuggested_Account_Link_List = class(TExtdSortedCollection)
  private
    fHighId : integer;
    fSuggested_Account_Link_Index : TSuggested_Account_Link_Index;

  protected
    procedure FreeItem(Item: Pointer); override;
    function FindFirstUsingSuggestedId( aSuggestedId: integer; var aIndex: integer): Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure Insert_Suggested_Account_Link_Rec(var aSuggested_Account_Link : TSuggested_Account_Link);
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function SearchUsingSuggestedId(aSuggestedId: integer; var aBottomIndex, aTopIndex : integer): Boolean;
    function SearchUsingSuggestedAndAccountId(aSuggestedId, aAccountId : integer; var aIndex : integer) : Boolean;
    function SearchUsingAccountAndSuggestedId(aAccountId, aSuggestedId : integer; var aIndex : integer) : Boolean;

    function  GetPRec(aIndex: integer): pSuggested_Account_Link_Rec;
    function  GetIndexPRec(aIndex: integer): pSuggested_Account_Link_Index_Rec;

    function  Suggested_Account_Link_At(aIndex: integer): TSuggested_Account_Link;

    function  GetAs_pRec(aItem: TSuggested_Account_Link): pSuggested_Account_Link_Rec;

    property Suggested_Account_Link_Index : TSuggested_Account_Link_Index read fSuggested_Account_Link_Index;
  end;

//------------------------------------------------------------------------------
implementation

uses
  MALLOC;

const
  UnitName = 'slList32';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TSuggested_Account_Link_Index.NewItem';

{ TSuggested_Account_Link_Index }
//------------------------------------------------------------------------------
function TSuggested_Account_Link_Index.NewItem: Pointer;
var
  P : pSuggested_Account_Link_Index_Rec;
Begin
  SafeGetMem( P, Suggested_Account_Link_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Suggested_Account_Link_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_Index.FreeItem(Item: Pointer);
begin
  SafeFreeMem(Item, Suggested_Account_Link_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
constructor TSuggested_Account_Link_Index.Create;
begin
  inherited;

end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_Index.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(pSuggested_Account_Link_Index_Rec(Item1)^.AccountId,
                         pSuggested_Account_Link_Index_Rec(Item2)^.AccountId);

  if Result <> 0 then
    Exit;

  Result := CompareValue(pSuggested_Account_Link_Index_Rec(Item1)^.SuggestedId,
                         pSuggested_Account_Link_Index_Rec(Item2)^.SuggestedId);
end;

{ TSuggested_Account_Link_List }
//------------------------------------------------------------------------------
constructor TSuggested_Account_Link_List.Create;
begin
  inherited Create;

  fSuggested_Account_Link_Index := TSuggested_Account_Link_Index.Create;

  fHighId := 0;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
destructor TSuggested_Account_Link_List.Destroy;
begin
  FreeAndNil(fSuggested_Account_Link_Index);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_List.DeleteFreeAll;
var
  index : integer;
begin
  fHighId := 0;
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);

  fSuggested_Account_Link_Index.FreeAll;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(TSuggested_Account_Link(Item1).slFields.slSuggestedId,
                         TSuggested_Account_Link(Item2).slFields.slSuggestedId);

  if Result <> 0 then
    Exit;

  Result := CompareValue(TSuggested_Account_Link(Item1).slFields.slAccountId,
                         TSuggested_Account_Link(Item2).slFields.slAccountId);
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_List.FreeItem(Item: Pointer);
var
  P: TSuggested_Account_Link;
begin
  P := TSuggested_Account_Link(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.FindFirstUsingSuggestedId( aSuggestedId: integer; var aIndex: integer): Boolean;
var
  Top, Bottom, Index, CompRes : Integer;
begin
  Result := False;
  Top := 0;
  Bottom := FCount - 1;
  while Top <= Bottom do
  begin
    Index := ( Top + Bottom ) shr 1;

    CompRes := CompareValue(aSuggestedId, GetPRec(Index)^.slSuggestedId);

    if CompRes > 0 then
      Top := Index + 1
    else
    begin
      Bottom := Index - 1;
      if CompRes = 0 then
      begin
        Result := True;
        aIndex := Index;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_List.Insert_Suggested_Account_Link_Rec(var aSuggested_Account_Link : TSuggested_Account_Link);
var
  NewSuggested_Account_Link_Index_Rec : pSuggested_Account_Link_Index_Rec;
Begin
  NewSuggested_Account_Link_Index_Rec := fSuggested_Account_Link_Index.NewItem;
  NewSuggested_Account_Link_Index_Rec^.SuggestedId := aSuggested_Account_Link.slFields.slSuggestedId;
  NewSuggested_Account_Link_Index_Rec^.AccountId   := aSuggested_Account_Link.slFields.slAccountId;
  fSuggested_Account_Link_Index.Insert(NewSuggested_Account_Link_Index_Rec);

  Inherited Insert( aSuggested_Account_Link );
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Account_Link_List.SaveToFile';
var
  i: integer;
  Item: TSuggested_Account_Link;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginSuggested_Account_Link_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Suggested_Account_Link_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Link_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Account_Link_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TSuggested_Account_Link;
  NewSuggested_Account_Link_Index_Rec : pSuggested_Account_Link_Index_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;

  fSuggested_Account_Link_Index.SortingOn := false;
  SortingOn := false;

  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Suggested_Account_Link) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TSuggested_Account_Link.Create;
    try
      P.LoadFromFile(S);

      Insert_Suggested_Account_Link_Rec(P);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  fSuggested_Account_Link_Index.SortingOn := true;
  SortingOn := true;

  fSuggested_Account_Link_Index.Sort();
  Sort();

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.SearchUsingSuggestedId(aSuggestedId: integer; var aBottomIndex, aTopIndex: integer): Boolean;
var
  FirstIndex : integer;
  SearchIndex : integer;
  CompRes : integer;
begin
  Result := false;
  if FindFirstUsingSuggestedId(aSuggestedId, FirstIndex) then
  begin
    SearchIndex := FirstIndex;
    inc(SearchIndex);

    if SearchIndex < ItemCount then
    begin
      CompRes := CompareValue(aSuggestedId, GetPRec(SearchIndex)^.slSuggestedId);
      while (SearchIndex < ItemCount) and
            (CompRes = 0) do
      begin
        inc(SearchIndex);
        if SearchIndex < ItemCount then
          CompRes := CompareValue(aSuggestedId, GetPRec(SearchIndex)^.slSuggestedId)
        else
          CompRes := 1;
      end;
    end;

    dec(SearchIndex);
    aTopIndex := SearchIndex;

    if SearchIndex > -1 then
    begin
      CompRes := CompareValue(aSuggestedId, GetPRec(SearchIndex)^.slSuggestedId);
      while (SearchIndex > -1) and
            (CompRes = 0) do
      begin
        dec(SearchIndex);
        if SearchIndex > -1 then
          CompRes := CompareValue(aSuggestedId, GetPRec(SearchIndex)^.slSuggestedId)
        else
          CompRes := -1;
      end;
    end;

    inc(SearchIndex);
    aBottomIndex := SearchIndex;
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.SearchUsingSuggestedAndAccountId(aSuggestedId, aAccountId : integer; var aIndex : integer) : Boolean;
var
  SearchSuggested_Account_Link : TSuggested_Account_Link;
begin
  SearchSuggested_Account_Link := TSuggested_Account_Link.Create;
  try
    SearchSuggested_Account_Link.slFields.slSuggestedId := aSuggestedId;
    SearchSuggested_Account_Link.slFields.slAccountId   := aAccountId;
    Result := Search(SearchSuggested_Account_Link, aIndex);
  finally
    FreeAndNil(SearchSuggested_Account_Link);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.SearchUsingAccountAndSuggestedId(aAccountId, aSuggestedId : integer; var aIndex : integer) : Boolean;
var
  SearchpSuggested_Account_Link_Index_Rec : pSuggested_Account_Link_Index_Rec;
begin
  SearchpSuggested_Account_Link_Index_Rec := fSuggested_Account_Link_Index.NewItem;
  try
    SearchpSuggested_Account_Link_Index_Rec.AccountId   := aAccountId;
    SearchpSuggested_Account_Link_Index_Rec.SuggestedId := aSuggestedId;
    Result := fSuggested_Account_Link_Index.Search(SearchpSuggested_Account_Link_Index_Rec, aIndex);
  finally
    fSuggested_Account_Link_Index.FreeItem(SearchpSuggested_Account_Link_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.GetPRec(aIndex: integer): pSuggested_Account_Link_Rec;
begin
  Result := TSuggested_Account_Link(At(aIndex)).As_pRec;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.GetIndexPRec(aIndex: integer): pSuggested_Account_Link_Index_Rec;
begin
  Result := fSuggested_Account_Link_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.Suggested_Account_Link_At(aIndex: integer): TSuggested_Account_Link;
var
  P: Pointer;
Begin
  P := At(aIndex);

  result := TSuggested_Account_Link(P);
end;

//------------------------------------------------------------------------------
function TSuggested_Account_Link_List.GetAs_pRec(aItem: TSuggested_Account_Link): pSuggested_Account_Link_Rec;
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
