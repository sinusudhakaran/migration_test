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
  { ----------------------------------------------------------------------------
    TRecommended_Mem_List
  ---------------------------------------------------------------------------- }
  TTran_Suggested_Link_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Tran_Suggested_Link_At(Index: integer): TTran_Suggested_Link;

    function  GetAs_pRec(Item: TTran_Suggested_Link): pTran_Suggested_Link_Rec;
  end;


implementation

const
   UnitName = 'rmList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TRecommended_Mem_List
------------------------------------------------------------------------------ }
constructor TTran_Suggested_Link_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TTran_Suggested_Link_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := 0;
  {Result := CompareText(TSuggested_Mem(Item1).smFields.rmStatement_Details,
                        TSuggested_Mem(Item2).smFields.rmStatement_Details);
  if (Result <> 0) then Exit;
  Result := CompareValue(TSuggested_Mem(Item1).smFields.rmType,
                         TSuggested_Mem(Item2).smFields.rmType);
  if (Result <> 0) then Exit;
  Result := CompareText(TSuggested_Mem(Item1).smFields.rmBank_Account_Number,
                        TSuggested_Mem(Item2).smFields.rmBank_Account_Number);
  if (Result <> 0) then Exit;
  Result := CompareText(TSuggested_Mem(Item1).smFields.rmAccount,
                        TSuggested_Mem(Item2).smFields.rmAccount);
  if (Result <> 0) then Exit;
  Result := CompareValue(TSuggested_Mem(Item1).smFields.rmManual_Count,
                         TSuggested_Mem(Item2).smFields.rmManual_Count);
  if (Result <> 0) then Exit;
  Result := CompareValue(TSuggested_Mem(Item1).smFields.rmUncoded_Count,
                         TSuggested_Mem(Item2).smFields.rmUncoded_Count);}
end;

{------------------------------------------------------------------------------}
procedure TTran_Suggested_Link_List.FreeItem(Item: Pointer);
var
  P: TTran_Suggested_Link;
begin
  P := TTran_Suggested_Link(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
function TTran_Suggested_Link_List.Tran_Suggested_Link_At(Index: integer): TTran_Suggested_Link;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TTran_Suggested_Link(P);
end;

{------------------------------------------------------------------------------}
function TTran_Suggested_Link_List.GetAs_pRec(Item: TTran_Suggested_Link): pTran_Suggested_Link_Rec;
begin
  if Assigned(Item) then
    result := Item.As_pRec
  else
    result := nil;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
