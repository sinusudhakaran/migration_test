unit saList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKsaIO,
  saObj32,
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
  pSuggested_Account_Index_Rec = ^TSuggested_Account_Index_Rec;
  TSuggested_Account_Index_Rec = Packed Record
    Id      : Integer;
    Account : String[20];
  end;

const
  Suggested_Account_Index_Rec_Size = Sizeof(TSuggested_Account_Index_Rec);

type
  //----------------------------------------------------------------------------
  TSuggested_Account_Index = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

  //----------------------------------------------------------------------------
  TSuggested_Account_List = class(TExtdSortedCollection)
  private
    fHighId : integer;
    fSuggested_Account_Index : TSuggested_Account_Index;

  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    destructor Destroy; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    function Insert_Suggested_Account_Rec(var aSuggested_Account : TSuggested_Account; aNew : Boolean = true) : integer;
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function SearchUsingAccountId(aAccountId : integer; var aIndex : integer) : Boolean;
    function SearchUsingAccount(aAccount : string; var aIndex : integer) : Boolean;

    function  GetPRec(aIndex: integer): pSuggested_Account_Rec;
    function  GetIndexPRec(aIndex: integer): pSuggested_Account_Index_Rec;

    function  Suggested_Account_At(aIndex: integer): TSuggested_Account;

    function  GetAs_pRec(aItem: TSuggested_Account): pSuggested_Account_Rec;
  end;

//------------------------------------------------------------------------------
implementation

uses
  MALLOC;

const
  UnitName = 'saList32';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TSuggested_Account_Index.NewItem';

{ TSuggested_Account_Index }
//------------------------------------------------------------------------------
function TSuggested_Account_Index.NewItem: Pointer;
var
  P : pSuggested_Account_Index_Rec;
Begin
  SafeGetMem( P, Suggested_Account_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Suggested_Account_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_Index.FreeItem(Item: Pointer);
begin
  SafeFreeMem(Item, Suggested_Account_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
constructor TSuggested_Account_Index.Create;
begin
  inherited;

end;

//------------------------------------------------------------------------------
function TSuggested_Account_Index.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareText(pSuggested_Account_Index_Rec(Item1)^.Account,
                        pSuggested_Account_Index_Rec(Item2)^.Account);
end;

{ TSuggested_Account_List }
//------------------------------------------------------------------------------
constructor TSuggested_Account_List.Create;
begin
  inherited Create;

  fSuggested_Account_Index := TSuggested_Account_Index.Create;

  fHighId := 0;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
destructor TSuggested_Account_List.Destroy;
begin
  FreeAndNil(fSuggested_Account_Index);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_List.DeleteFreeAll;
var
  index : integer;
begin
  fHighId := 0;
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);

  fSuggested_Account_Index.FreeAll;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(TSuggested_Account(Item1).saFields.saId,
                         TSuggested_Account(Item2).saFields.saId);
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_List.FreeItem(Item: Pointer);
var
  P: TSuggested_Account;
begin
  P := TSuggested_Account(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.Insert_Suggested_Account_Rec(var aSuggested_Account : TSuggested_Account; aNew : boolean) : integer;
var
  NewSuggested_Account_Index_Rec : pSuggested_Account_Index_Rec;
Begin
  Result := -1;

  if aNew then
  begin
    Inc( fHighId );
    aSuggested_Account.saFields.saId := fHighId;
  end
  else
  begin
    if fHighId < aSuggested_Account.saFields.saId then
      fHighId := aSuggested_Account.saFields.saId;
  end;
  Result := fHighId;

  NewSuggested_Account_Index_Rec := fSuggested_Account_Index.NewItem;
  NewSuggested_Account_Index_Rec^.Id      := aSuggested_Account.saFields.saId;
  NewSuggested_Account_Index_Rec^.Account := aSuggested_Account.saFields.saAccount;
  fSuggested_Account_Index.Insert(NewSuggested_Account_Index_Rec);

  Inherited Insert(aSuggested_Account);
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Account_List.SaveToFile';
var
  i: integer;
  Item: TSuggested_Account;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginSuggested_Account_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Suggested_Account_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.SearchUsingAccountId(aAccountId: integer; var aIndex: integer): Boolean;
var
  SearchSuggested_Mem : TSuggested_Account;
begin
  SearchSuggested_Mem := TSuggested_Account.Create;
  try
    SearchSuggested_Mem.saFields.saId := aAccountId;
    Result := Search(SearchSuggested_Mem, aIndex);
  finally
    FreeAndNil(SearchSuggested_Mem);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.SearchUsingAccount(aAccount: string; var aIndex: integer): Boolean;
var
  SearchpSuggested_Account_Index_Rec : pSuggested_Account_Index_Rec;
begin
  SearchpSuggested_Account_Index_Rec := fSuggested_Account_Index.NewItem;
  try
    SearchpSuggested_Account_Index_Rec.Account := aAccount;
    Result := fSuggested_Account_Index.Search(SearchpSuggested_Account_Index_Rec, aIndex);
  finally
    fSuggested_Account_Index.FreeItem(SearchpSuggested_Account_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Account_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Account_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TSuggested_Account;
  NewSuggested_Account_Index_Rec : pSuggested_Account_Index_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;

  fSuggested_Account_Index.SortingOn := false;
  SortingOn := false;

  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Suggested_Account) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TSuggested_Account.Create;
    try
      P.LoadFromFile(S);

      Insert_Suggested_Account_Rec(P, false);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  fSuggested_Account_Index.SortingOn := true;
  SortingOn := true;

  fSuggested_Account_Index.Sort();
  Sort();

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.GetPRec(aIndex: integer): pSuggested_Account_Rec;
begin
  Result := TSuggested_Account(At(aIndex)).As_pRec;
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.GetIndexPRec(aIndex: integer): pSuggested_Account_Index_Rec;
begin
  Result := fSuggested_Account_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.Suggested_Account_At(aIndex: integer): TSuggested_Account;
var
  P: Pointer;
Begin
  P := At(aIndex);

  result := TSuggested_Account(P);
end;

//------------------------------------------------------------------------------
function TSuggested_Account_List.GetAs_pRec(aItem: TSuggested_Account): pSuggested_Account_Rec;
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
