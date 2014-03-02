unit utList32;

interface

uses
  eCollect, BKDEFS, BKutIO, utObj32, IOSTREAM, Math, SysUtils, TOKENS, LogUtil,
  BKDbExcept,
  StDate,
  bkDateUtils,
  MoneyDef,
  bkConst;

type
  { ----------------------------------------------------------------------------
    TUnscanned_Transaction_List
  ---------------------------------------------------------------------------- }
  TUnscanned_Transaction_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Unscanned_Transaction_At(Index: integer): TUnscanned_Transaction;

    function  GetAs_pRec(Item: TUnscanned_Transaction): pUnscanned_Transaction_Rec;
  end;


implementation

const
   UnitName = 'utList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TUnscanned_Transaction_List
------------------------------------------------------------------------------ }
constructor TUnscanned_Transaction_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TUnscanned_Transaction_List.Compare(Item1, Item2: Pointer): integer;
begin
  result := 0;
end;

{------------------------------------------------------------------------------}
procedure TUnscanned_Transaction_List.FreeItem(Item: Pointer);
var
  P: TUnscanned_Transaction;
begin
  P := TUnscanned_Transaction(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
procedure TUnscanned_Transaction_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction_List.SaveToFile';
var
  i: integer;
  Item: TUnscanned_Transaction;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginUnscanned_Transaction_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Unscanned_Transaction_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TUnscanned_Transaction_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TUnscanned_Transaction;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Unscanned_Transaction) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TUnscanned_Transaction.Create;
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
function TUnscanned_Transaction_List.Unscanned_Transaction_At(Index: integer
  ): TUnscanned_Transaction;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TUnscanned_Transaction(P);
end;

{------------------------------------------------------------------------------}
function TUnscanned_Transaction_List.GetAs_pRec(Item: TUnscanned_Transaction
  ): pUnscanned_Transaction_Rec;
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
