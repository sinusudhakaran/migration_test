unit frList32;

interface

uses
  eCollect, BKDEFS, BKfrIO, frObj32, IOSTREAM, Math, SysUtils, TOKENS, LogUtil,
  BKDbExcept,
  StDate,
  MoneyDef,
  AuditMgr,
  bkConst;
  
type
  TFinalized_Exchange_Rate_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create;

    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    procedure AddExchangeRate(ADate: TStDate; AExchangeRate: Double);
    function FindRate(ADate: TStDate; out AFinalizedExchangeRate: TFinalized_Exchange_Rate): Boolean;
  end;
  
implementation

const
   UnitName = 'frList32';
   DebugMe: boolean = false;
   
{ TFinalized_Exchange_Rate_List }

procedure TFinalized_Exchange_Rate_List.AddExchangeRate(ADate: TStDate; AExchangeRate: Double);
var
  FinalizedRate: TFinalized_Exchange_Rate;
begin
  if not FindRate(ADate, FinalizedRate) then
  begin
    FinalizedRate := TFinalized_Exchange_Rate.Create;

    FinalizedRate.frFields.frDate := ADate;
    
    Insert(FinalizedRate);
  end;
  
  FinalizedRate.frFields.frRate := AExchangeRate;
end;

function TFinalized_Exchange_Rate_List.Compare(Item1, Item2: Pointer): integer;
var
  Exchange1: TFinalized_Exchange_Rate;
  Exchange2: TFinalized_Exchange_Rate;
begin
  Exchange1 := TFinalized_Exchange_Rate(Item1);
  ASSERT(Assigned(Exchange1));
  Exchange2 := TFinalized_Exchange_Rate(Item2);
  ASSERT(Assigned(Exchange2));

  result := CompareValue(Exchange1.frFields.frDate, Exchange2.frFields.frDate);
end;

constructor TFinalized_Exchange_Rate_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

function TFinalized_Exchange_Rate_List.FindRate(ADate: TStDate; out AFinalizedExchangeRate: TFinalized_Exchange_Rate): Boolean;
var
  FinalizedRate: TFinalized_Exchange_Rate;
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to ItemCount - 1 do
  begin
    FinalizedRate := Items[Index];

    if FinalizedRate.frFields.frDate = ADate then
    begin
      AFinalizedExchangeRate := FinalizedRate;

      Result := True;

      Exit;
    end;
  end;
end;

procedure TFinalized_Exchange_Rate_List.FreeItem(Item: Pointer);
var
  P: TFinalized_Exchange_Rate;
begin
  P := TFinalized_Exchange_Rate(Item);
  if Assigned(P) then
    P.Free;
end;

procedure TFinalized_Exchange_Rate_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TFinalized_Exchange_Rate_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TFinalized_Exchange_Rate;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Finalized_Exchange_Rate) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TFinalized_Exchange_Rate.Create;
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

procedure TFinalized_Exchange_Rate_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TFinalized_Exchange_Rate_List.SaveToFile';
var
  i: integer;
  Item: TFinalized_Exchange_Rate;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginFinalized_Exchange_Rate_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := TFinalized_Exchange_Rate(Items[i]);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

initialization
  DebugMe := DebugUnit(UnitName);
  
end.
