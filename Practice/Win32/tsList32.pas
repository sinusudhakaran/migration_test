unit tsList32;

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
  TTranSuggSortType = (tstTranId, tstSuggId);

  TTran_Suggested_Link_List = class(TExtdSortedCollection)
  private
    fSortType : TTranSuggSortType;
    fSortingOn : boolean;
  protected
    procedure FreeItem(Item: Pointer); override;

    procedure SetSortType(aValue : TTranSuggSortType);
  public
    constructor Create; override;
    function Compare(Item1, Item2: Pointer) : integer; override;
    procedure Copyfrom(aSourceList : TTran_Suggested_Link_List);
    procedure Insert( Item : Pointer ); override;
    procedure DeleteFreeAll();

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function Tran_Suggested_Link_At(Index: integer): TTran_Suggested_Link;

    function GetAs_pRec(Item: TTran_Suggested_Link): pTran_Suggested_Link_Rec;

    property SortType : TTranSuggSortType read fSortType write SetSortType;
    property SortingOn : boolean read fSortingOn write fSortingOn;
  end;


implementation

const
  UnitName = 'rmList32';
  DebugMe: boolean = false;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.SetSortType(aValue: TTranSuggSortType);
begin
  fSortType := aValue;
end;

//------------------------------------------------------------------------------
constructor TTran_Suggested_Link_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.DeleteFreeAll;
var
  index : integer;
begin
  for index := ItemCount-1 downto 0 do
    DelFreeItem(self.Items[index]);
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  if fSortType = tstTranId then
  begin
    Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsTran_Seq_No,
                           TTran_Suggested_Link(Item2).tsFields.tsTran_Seq_No);

    if (Result <> 0) then
      Exit;

    Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsSuggestedId,
                           TTran_Suggested_Link(Item2).tsFields.tsSuggestedId);
  end
  else
  begin
    Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsSuggestedId,
                           TTran_Suggested_Link(Item2).tsFields.tsSuggestedId);

    if (Result <> 0) then
      Exit;

    Result := CompareValue(TTran_Suggested_Link(Item1).tsFields.tsTran_Seq_No,
                           TTran_Suggested_Link(Item2).tsFields.tsTran_Seq_No);
  end;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.Copyfrom(aSourceList: TTran_Suggested_Link_List);
var
  SourceIndex : integer;
  NewSuggLink : TTran_Suggested_Link;
begin
  for SourceIndex := 0 to aSourceList.ItemCount-1 do
  begin
    NewSuggLink := TTran_Suggested_Link.Create();
    NewSuggLink.tsFields.tsDate_Effective := aSourceList.Tran_Suggested_Link_At(SourceIndex).tsFields.tsDate_Effective;
    NewSuggLink.tsFields.tsTran_Seq_No    := aSourceList.Tran_Suggested_Link_At(SourceIndex).tsFields.tsTran_Seq_No;
    NewSuggLink.tsFields.tsSuggestedId    := aSourceList.Tran_Suggested_Link_At(SourceIndex).tsFields.tsSuggestedId;
    Insert(NewSuggLink);
  end;
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
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
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
      Insert(P);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.Tran_Suggested_Link_At(Index: integer): TTran_Suggested_Link;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TTran_Suggested_Link(P);
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Link_List.GetAs_pRec(Item: TTran_Suggested_Link): pTran_Suggested_Link_Rec;
begin
  if Assigned(Item) then
    result := Item.As_pRec
  else
    result := nil;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Link_List.Insert(Item: Pointer);
var
  Index : integer;
begin
  if fSortingOn then
    inherited
  else
  begin
    if ( Item = nil ) then Error( coInvalidPointer, 0 );
    Index := FCount;
    AtInsert( Index, Item );
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
