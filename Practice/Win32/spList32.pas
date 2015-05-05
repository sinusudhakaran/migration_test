unit spList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKspIO,
  spObj32,
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
  pSuggested_Phrase_Index_Rec = ^TSuggested_Phrase_Index_Rec;
  TSuggested_Phrase_Index_Rec = Packed Record
    Id     : Integer;
    Phrase : String[200];
  end;

const
  Suggested_Phrase_Index_Rec_Size = Sizeof(TSuggested_Phrase_Index_Rec);

type
  //----------------------------------------------------------------------------
  TSuggested_Phrase_Index = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  end;

  //----------------------------------------------------------------------------
  TSuggested_Phrase_List = class(TExtdSortedCollection)
  private
    fHighId : integer;
    fSuggested_Phrase_Index : TSuggested_Phrase_Index;

  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    destructor Destroy; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    function Insert_Suggested_Phrase_Rec(var aSuggested_Phrase : TSuggested_Phrase; aNew : Boolean = true) : integer;
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function SearchUsingPhraseId(aPhraseId : integer; var aIndex : integer) : Boolean;
    function SearchUsingPhrase(aPhrase : string; var aIndex : integer) : Boolean;

    function  GetPRec(aIndex: integer): pSuggested_Phrase_Rec;
    function  GetIndexPRec(aIndex: integer): pSuggested_Phrase_Index_Rec;

    function  Suggested_Phrase_At(aIndex: integer): TSuggested_Phrase;

    function  GetAs_pRec(aItem: TSuggested_Phrase): pSuggested_Phrase_Rec;
  end;

//------------------------------------------------------------------------------
implementation

uses
  MALLOC;

const
  UnitName = 'spList32';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TSuggested_Phrase_Index.NewItem';

{ TSuggested_Phrase_Index }
//------------------------------------------------------------------------------
function TSuggested_Phrase_Index.NewItem: Pointer;
var
  P : pSuggested_Phrase_Index_Rec;
Begin
  SafeGetMem( P, Suggested_Phrase_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Suggested_Phrase_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Phrase_Index.FreeItem(Item: Pointer);
begin
  SafeFreeMem(Item, Suggested_Phrase_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
constructor TSuggested_Phrase_Index.Create;
begin
  inherited;

end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_Index.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareText(pSuggested_Phrase_Index_Rec(Item1)^.Phrase,
                        pSuggested_Phrase_Index_Rec(Item2)^.Phrase);
end;

{ TSuggested_Phrase_List }
//------------------------------------------------------------------------------
constructor TSuggested_Phrase_List.Create;
begin
  inherited Create;

  fSuggested_Phrase_Index := TSuggested_Phrase_Index.Create;

  fHighId := 0;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
destructor TSuggested_Phrase_List.Destroy;
begin
  FreeAndNil(fSuggested_Phrase_Index);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggested_Phrase_List.DeleteFreeAll;
var
  index : integer;
begin
  fHighId := 0;
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);

  fSuggested_Phrase_Index.FreeAll;
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareValue(TSuggested_Phrase(Item1).spFields.spId,
                         TSuggested_Phrase(Item2).spFields.spId);
end;

//------------------------------------------------------------------------------
procedure TSuggested_Phrase_List.FreeItem(Item: Pointer);
var
  P: TSuggested_Phrase;
begin
  P := TSuggested_Phrase(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.Insert_Suggested_Phrase_Rec(var aSuggested_Phrase : TSuggested_Phrase; aNew : boolean) : integer;
var
  NewSuggested_Phrase_Index_Rec : pSuggested_Phrase_Index_Rec;
Begin
  if aNew then
  begin
    Inc( fHighId );
    aSuggested_Phrase.spFields.spId := fHighId;
  end
  else
  begin
    if fHighId < aSuggested_Phrase.spFields.spId then
      fHighId := aSuggested_Phrase.spFields.spId;
  end;
  Result := fHighId;

  NewSuggested_Phrase_Index_Rec := fSuggested_Phrase_Index.NewItem;
  NewSuggested_Phrase_Index_Rec^.Id     := aSuggested_Phrase.spFields.spId;
  NewSuggested_Phrase_Index_Rec^.Phrase := aSuggested_Phrase.spFields.spPhrase;
  fSuggested_Phrase_Index.Insert(NewSuggested_Phrase_Index_Rec);

  Inherited Insert( aSuggested_Phrase );
end;

//------------------------------------------------------------------------------
procedure TSuggested_Phrase_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Phrase_List.SaveToFile';
var
  i: integer;
  Item: TSuggested_Phrase;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginSuggested_Phrase_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Suggested_Phrase_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TSuggested_Phrase_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Phrase_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TSuggested_Phrase;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;

  fSuggested_Phrase_Index.SortingOn := false;
  SortingOn := false;

  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Suggested_Phrase) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TSuggested_Phrase.Create;
    try
      P.LoadFromFile(S);

      Insert_Suggested_Phrase_Rec(P, false);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  fSuggested_Phrase_Index.SortingOn := true;
  SortingOn := true;

  fSuggested_Phrase_Index.Sort();
  Sort();

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.SearchUsingPhraseId(aPhraseId: integer; var aIndex: integer): Boolean;
var
  SearchSuggested_Phrase : TSuggested_Phrase;
begin
  SearchSuggested_Phrase := TSuggested_Phrase.Create;
  try
    SearchSuggested_Phrase.spFields.spId := aPhraseId;
    Result := Search(SearchSuggested_Phrase, aIndex);
  finally
    FreeAndNil(SearchSuggested_Phrase);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.SearchUsingPhrase(aPhrase: string; var aIndex: integer): Boolean;
var
  SearchpSuggested_Phrase_Index_Rec : pSuggested_Phrase_Index_Rec;
begin
  SearchpSuggested_Phrase_Index_Rec := fSuggested_Phrase_Index.NewItem;
  try
    SearchpSuggested_Phrase_Index_Rec.Phrase := aPhrase;
    Result := fSuggested_Phrase_Index.Search(SearchpSuggested_Phrase_Index_Rec, aIndex);
  finally
    fSuggested_Phrase_Index.FreeItem(SearchpSuggested_Phrase_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.GetPRec(aIndex: integer): pSuggested_Phrase_Rec;
begin
  Result := TSuggested_Phrase(At(aIndex)).As_pRec;
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.GetIndexPRec(aIndex: integer): pSuggested_Phrase_Index_Rec;
begin
  Result := fSuggested_Phrase_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.Suggested_Phrase_At(aIndex: integer): TSuggested_Phrase;
var
  P: Pointer;
Begin
  P := At(aIndex);

  result := TSuggested_Phrase(P);
end;

//------------------------------------------------------------------------------
function TSuggested_Phrase_List.GetAs_pRec(aItem: TSuggested_Phrase): pSuggested_Phrase_Rec;
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
