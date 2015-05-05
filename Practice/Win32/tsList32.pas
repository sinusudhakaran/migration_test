unit tsList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKtsIO,
  tsObj32,
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
  pTran_Suggested_Link_Index_Rec = ^TTran_Suggested_Link_Index_Rec;
  TTran_Suggested_Link_Index_Rec = Packed Record
    Date_Effective : integer;
    Tran_Seq_No    : integer;
    SuggestedId    : Integer;
  end;

const
  Tran_Suggested_Link_Index_Rec_Size = Sizeof(TTran_Suggested_Link_Index_Rec);

type
  //----------------------------------------------------------------------------
  TTran_Suggested_Link_Index = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

  //----------------------------------------------------------------------------
  TTran_Suggested_Link_List = class(TExtdSortedCollection)
  private
    fHighId : integer;
    fTran_Suggested_Link_Index : TTran_Suggested_Link_Index;

  protected
    procedure FreeItem(Item: Pointer); override;
    function FindFirstUsingSuggestedId(aSuggestedId : integer; var aIndex : integer) : Boolean;
    function FindFirstUsingTranSeqNo(aTranSeqNo : integer; var aIndex : integer) : Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure Insert_Tran_Suggested_Link_Rec(var aTran_Suggested_Link : TTran_Suggested_Link);
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function SearchUsingSuggestedId(aSuggestedId: integer; var aBottomIndex, aTopIndex : integer): Boolean;
    function SearchUsingTranSeqNo(aTranSeqNo : integer; var aBottomIndex, aTopIndex : integer): Boolean;
    function SearchUsingTranSeqNoAndSuggestedId(aTranSeqNo, aSuggestedId : integer; var aIndex : integer) : Boolean;
    function SearchUsingSuggestedIdAndTranSeqNo(aSuggestedId, aTranSeqNo : integer; var aIndex : integer) : Boolean;

    function  GetPRec(aIndex: integer): pTran_Suggested_Link_Rec;
    function  GetIndexPRec(aIndex: integer): pTran_Suggested_Link_Index_Rec;

    function  Tran_Suggested_Link_At(aIndex: integer): TTran_Suggested_Link;

    function  GetAs_pRec(aItem: TTran_Suggested_Link): pTran_Suggested_Link_Rec;

    property Tran_Suggested_Link_Index : TTran_Suggested_Link_Index read fTran_Suggested_Link_Index;
  end;

//------------------------------------------------------------------------------
implementation

uses
  MALLOC;

const
  UnitName = 'slList32';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TTran_Suggested_Link_Index.NewItem';

{ TTran_Suggested_Link_Index }
//------------------------------------------------------------------------------
function TTran_Suggested_Link_Index.NewItem: Pointer;
var
  P : pTran_Suggested_Link_Index_Rec;
Begin
  SafeGetMem( P, Tran_Suggested_Link_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Tran_Suggested_Link_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_Index.FreeItem(Item: Pointer);
begin
  SafeFreeMem(Item, Tran_Suggested_Link_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
constructor TTran_Suggested_Link_Index.Create;
begin
  inherited;

  Duplicates := false;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_Index.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(pTran_Suggested_Link_Index_Rec(Item1)^.SuggestedId,
                         pTran_Suggested_Link_Index_Rec(Item2)^.SuggestedId);

  if Result <> 0 then
    Exit;

  Result := CompareValue(pTran_Suggested_Link_Index_Rec(Item1)^.Tran_Seq_No,
                         pTran_Suggested_Link_Index_Rec(Item2)^.Tran_Seq_No);
end;

{ TTran_Suggested_Link_List }
//------------------------------------------------------------------------------
constructor TTran_Suggested_Link_List.Create;
begin
  inherited Create;

  fTran_Suggested_Link_Index := TTran_Suggested_Link_Index.Create;

  fHighId := 0;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
destructor TTran_Suggested_Link_List.Destroy;
begin
  FreeAndNil(fTran_Suggested_Link_Index);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.DeleteFreeAll;
var
  index : integer;
begin
  fHighId := 0;
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);

  fTran_Suggested_Link_Index.FreeAll;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsTran_Seq_No,
                         TTran_Suggested_Link(Item2).tsFields.tsTran_Seq_No);

  if Result <> 0 then
    Exit;

  Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsSuggestedId,
                         TTran_Suggested_Link(Item2).tsFields.tsSuggestedId);
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.FreeItem(Item: Pointer);
var
  P: TTran_Suggested_Link;
begin
  P := TTran_Suggested_Link(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.FindFirstUsingSuggestedId( aSuggestedId: integer; var aIndex: integer): Boolean;
var
  Top, Bottom, Index, CompRes : Integer;
begin
  Result := False;
  Top := 0;
  Bottom := FCount - 1;
  while Top <= Bottom do
  begin
    Index := ( Top + Bottom ) shr 1;

    CompRes := CompareValue(aSuggestedId, GetIndexPRec(Index)^.SuggestedId);

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
function TTran_Suggested_Link_List.FindFirstUsingTranSeqNo(aTranSeqNo : integer; var aIndex: integer): Boolean;
var
  Top, Bottom, Index, CompRes : Integer;
begin
  Result := False;
  Top := 0;
  Bottom := FCount - 1;
  while Top <= Bottom do
  begin
    Index := ( Top + Bottom ) shr 1;

    CompRes := CompareValue(aTranSeqNo, GetPRec(Index)^.tsTran_Seq_No);

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
procedure TTran_Suggested_Link_List.Insert_Tran_Suggested_Link_Rec(var aTran_Suggested_Link : TTran_Suggested_Link);
var
  NewTran_Suggested_Link_Index_Rec : pTran_Suggested_Link_Index_Rec;
Begin
  NewTran_Suggested_Link_Index_Rec := fTran_Suggested_Link_Index.NewItem;
  NewTran_Suggested_Link_Index_Rec^.Date_Effective := aTran_Suggested_Link.tsFields.tsDate_Effective;
  NewTran_Suggested_Link_Index_Rec^.Tran_Seq_No    := aTran_Suggested_Link.tsFields.tsTran_Seq_No;
  NewTran_Suggested_Link_Index_Rec^.SuggestedId    := aTran_Suggested_Link.tsFields.tsSuggestedId;
  fTran_Suggested_Link_Index.Insert(NewTran_Suggested_Link_Index_Rec);

  Inherited Insert( aTran_Suggested_Link );
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTran_Suggested_Link_List.SaveToFile';
var
  i: integer;
  Item: TTran_Suggested_Link;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginTran_Suggested_Link_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Tran_Suggested_Link_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TTran_Suggested_Link_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TTran_Suggested_Link;
  NewTran_Suggested_Link_Index_Rec : pTran_Suggested_Link_Index_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;

  fTran_Suggested_Link_Index.SortingOn := false;
  SortingOn := false;

  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Tran_Suggested_Link) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TTran_Suggested_Link.Create;
    try
      P.LoadFromFile(S);

      Insert_Tran_Suggested_Link_Rec(P);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  fTran_Suggested_Link_Index.SortingOn := true;
  SortingOn := true;

  fTran_Suggested_Link_Index.Sort();
  Sort();

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.SearchUsingSuggestedId(aSuggestedId: integer; var aBottomIndex, aTopIndex : integer): Boolean;
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
      CompRes := CompareValue(aSuggestedId, GetIndexPRec(SearchIndex)^.SuggestedId);
      while (SearchIndex < ItemCount) and
            (CompRes = 0) do
      begin
        inc(SearchIndex);
        if SearchIndex < ItemCount then
          CompRes := CompareValue(aSuggestedId, GetIndexPRec(SearchIndex)^.SuggestedId)
        else
          CompRes := 1;
      end;
    end;

    dec(SearchIndex);
    aTopIndex := SearchIndex;

    if SearchIndex > -1 then
    begin
      CompRes := CompareValue(aSuggestedId, GetIndexPRec(SearchIndex)^.SuggestedId);
      while (SearchIndex > -1) and
            (CompRes = 0) do
      begin
        dec(SearchIndex);
        if SearchIndex > -1 then
          CompRes := CompareValue(aSuggestedId, GetIndexPRec(SearchIndex)^.SuggestedId)
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
function TTran_Suggested_Link_List.SearchUsingTranSeqNo(aTranSeqNo : integer; var aBottomIndex, aTopIndex: integer): Boolean;
var
  FirstIndex : integer;
  SearchIndex : integer;
  CompRes : integer;
begin
  Result := false;
  if FindFirstUsingTranSeqNo(aTranSeqNo, FirstIndex) then
  begin
    SearchIndex := FirstIndex;
    inc(SearchIndex);

    if SearchIndex < ItemCount then
    begin
      CompRes := CompareValue(aTranSeqNo, GetPRec(SearchIndex)^.tsTran_Seq_No);
      while (SearchIndex < ItemCount) and
            (CompRes = 0) do
      begin
        inc(SearchIndex);
        if SearchIndex < ItemCount then
          CompRes := CompareValue(aTranSeqNo, GetPRec(SearchIndex)^.tsTran_Seq_No)
        else
          CompRes := 1;
      end;
    end;

    dec(SearchIndex);
    aTopIndex := SearchIndex;

    if SearchIndex > -1 then
    begin
      CompRes := CompareValue(aTranSeqNo, GetPRec(SearchIndex)^.tsTran_Seq_No);
      while (SearchIndex > -1) and
            (CompRes = 0) do
      begin
        dec(SearchIndex);
        if SearchIndex > -1 then
          CompRes := CompareValue(aTranSeqNo, GetPRec(SearchIndex)^.tsTran_Seq_No)
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
function TTran_Suggested_Link_List.SearchUsingTranSeqNoAndSuggestedId(aTranSeqNo, aSuggestedId : integer; var aIndex : integer) : Boolean;
var
  SearchTran_Suggested_Link : TTran_Suggested_Link;
begin
  SearchTran_Suggested_Link := TTran_Suggested_Link.Create;
  try
    SearchTran_Suggested_Link.tsFields.tsTran_Seq_No := aTranSeqNo;
    SearchTran_Suggested_Link.tsFields.tsSuggestedId := aSuggestedId;
    Result := Search(SearchTran_Suggested_Link, aIndex);
  finally
    FreeAndNil(SearchTran_Suggested_Link);
  end;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.SearchUsingSuggestedIdAndTranSeqNo(aSuggestedId, aTranSeqNo : integer; var aIndex : integer) : Boolean;
var
  SearchpTran_Suggested_Link_Index_Rec : pTran_Suggested_Link_Index_Rec;
begin
  SearchpTran_Suggested_Link_Index_Rec := fTran_Suggested_Link_Index.NewItem;
  try
    SearchpTran_Suggested_Link_Index_Rec.SuggestedId := aSuggestedId;
    SearchpTran_Suggested_Link_Index_Rec.Tran_Seq_No := aTranSeqNo;
    Result := fTran_Suggested_Link_Index.Search(SearchpTran_Suggested_Link_Index_Rec, aIndex);
  finally
    fTran_Suggested_Link_Index.FreeItem(SearchpTran_Suggested_Link_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.GetPRec(aIndex: integer): pTran_Suggested_Link_Rec;
begin
  Result := TTran_Suggested_Link(At(aIndex)).As_pRec;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.GetIndexPRec(aIndex: integer): pTran_Suggested_Link_Index_Rec;
begin
  Result := fTran_Suggested_Link_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.Tran_Suggested_Link_At(aIndex: integer): TTran_Suggested_Link;
var
  P: Pointer;
Begin
  P := At(aIndex);

  result := TTran_Suggested_Link(P);
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.GetAs_pRec(aItem: TTran_Suggested_Link): pTran_Suggested_Link_Rec;
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
