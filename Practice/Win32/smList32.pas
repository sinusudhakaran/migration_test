unit smList32;

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
  { ----------------------------------------------------------------------------
    TRecommended_Mem_List
  ---------------------------------------------------------------------------- }
  TSuggested_Mem_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Suggested_Mem_At(Index: integer): TSuggested_Mem;

    function  GetAs_pRec(Item: TSuggested_Mem): pSuggested_Mem_Rec;
  end;


implementation

const
   UnitName = 'rmList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TRecommended_Mem_List
------------------------------------------------------------------------------ }
constructor TSuggested_Mem_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TSuggested_Mem_List.Compare(Item1, Item2: Pointer): integer;
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
procedure TSuggested_Mem_List.FreeItem(Item: Pointer);
var
  P: TSuggested_Mem;
begin
  P := TSuggested_Mem(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
procedure TSuggested_Mem_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSuggested_Mem_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TSuggested_Mem;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
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
function TSuggested_Mem_List.Suggested_Mem_At(Index: integer): TSuggested_Mem;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TSuggested_Mem(P);
end;

{------------------------------------------------------------------------------}
function TSuggested_Mem_List.GetAs_pRec(Item: TSuggested_Mem): pSuggested_Mem_Rec;
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
