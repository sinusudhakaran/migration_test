unit glList32;

interface

uses
  eCollect, BKDEFS, BKglIO, glObj32, IOSTREAM, Math, SysUtils, TOKENS, LogUtil,
  BKDbExcept,
  StDate,
  MoneyDef;

type
  { ----------------------------------------------------------------------------
    TExchange_Gain_Loss_List
  ---------------------------------------------------------------------------- }
  TExchange_Gain_Loss_List = class(TExtdSortedCollection)
  public
    constructor Create;
    function  Compare(Item1, Item2: Pointer) : integer; override;
  private
    function  GetItem(const P: Pointer): TExchange_Gain_Loss;
  protected
    procedure FreeItem(Item: Pointer); override;
  public
    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Exchange_Gain_Loss_At(Index: integer): TExchange_Gain_Loss;

    { Date is normally the last day of the month
      When an existing entry is found it will be re-used, otherwise a new entry
      will be created.
      The Account Code is stored because it may change at any time.
      Posted Date in the entry will be set to CurrentDate.
    }
    procedure PostEntry(const aDate: TStDate; const aAmount: Money;
                const aAccount: string);

    { Date is normally the last day of the month
      When found the corresponding item will be returned, otherwise the return
      value will be nil.
    }
    function  GetPostedEntry(const aDate: TStDate): TExchange_Gain_Loss;
  end;


implementation

const
   UnitName = 'glList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TExchange_Gain_Loss_List
------------------------------------------------------------------------------ }
constructor TExchange_Gain_Loss_List.Create;
begin
  inherited Create;
  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.GetItem(const P: Pointer): TExchange_Gain_Loss;
begin
  result := TExchange_Gain_Loss(P);
  ASSERT(result is TExchange_Gain_Loss);
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.Compare(Item1, Item2: Pointer): integer;
var
  Exchange1: TExchange_Gain_Loss;
  Exchange2: TExchange_Gain_Loss;
begin
  Exchange1 := GetItem(Item1);
  ASSERT(Assigned(Exchange1));
  Exchange2 := GetItem(Item2);
  ASSERT(Assigned(Exchange2));

  result := CompareValue(Exchange1.glFields.glDate, Exchange2.glFields.glDate);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.FreeItem(Item: Pointer);
var
  P: TExchange_Gain_Loss;
begin
  P := TExchange_Gain_Loss(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss_List.SaveToFile';
var
  i: integer;
  Item: TExchange_Gain_Loss;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginExchange_Gain_Loss_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Exchange_Gain_Loss_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TExchange_Gain_Loss;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Exchange_Gain_Loss) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TExchange_Gain_Loss.Create;
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
function TExchange_Gain_Loss_List.Exchange_Gain_Loss_At(Index: integer
  ): TExchange_Gain_Loss;
var
  P: Pointer;
Begin
  P := At(Index);

  result := GetItem(P);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.PostEntry(const aDate: TStDate;
  const aAmount: Money; const aAccount: string);
var
  Item: TExchange_Gain_Loss;
begin
  Item := GetPostedEntry(aDate);

  // Need to create new item?
  if not Assigned(Item) then
  begin
    Item := TExchange_Gain_Loss.Create;
    Insert(Item);
  end;

  ASSERT(Assigned(Item));

  // Set fields
  with Item.glFields do
  begin
    glDate := aDate;
    glAmount := aAmount;
    glAccount := aAccount;
    glPosted_Date := CurrentDate;
  end;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.GetPostedEntry(const aDate: TStDate
  ): TExchange_Gain_Loss;
var
  i: integer;
begin
  for i := 0 to ItemCount-1 do
  begin
    result := Exchange_Gain_Loss_At(i);
    ASSERT(Assigned(result));

    // Found?
    if (result.glFields.glDate = aDate) then
      exit;
  end;

  result := nil;
end;


{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
