unit mcList32;

//------------------------------------------------------------------------------
interface

uses
  eCollect,
  BKDEFS,
  BKmsIO,
  msObj32,
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
  TMem_Scan_Command_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Mem_Scan_Command_At(Index: integer): TMem_Scan_Command;

    function  GetAs_pRec(Item: TMem_Scan_Command): pMem_Scan_Command_Rec;
  end;

//------------------------------------------------------------------------------
implementation

const
   UnitName = 'mcList32';
   DebugMe: boolean = false;

//------------------------------------------------------------------------------
// TMem_Scan_Command_List
//------------------------------------------------------------------------------
constructor TMem_Scan_Command_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

//------------------------------------------------------------------------------
function TMem_Scan_Command_List.Compare(Item1, Item2: Pointer): integer;
begin
  Result := CompareText(TMem_Scan_Command(Item1).msFields.msBank_Account_Number,
                        TMem_Scan_Command(Item2).msFields.msBank_Account_Number);
end;

//------------------------------------------------------------------------------
procedure TMem_Scan_Command_List.FreeItem(Item: Pointer);
var
  P: TMem_Scan_Command;
begin
  P := TMem_Scan_Command(Item);
  if Assigned(P) then
    P.Free;
end;

//------------------------------------------------------------------------------
procedure TMem_Scan_Command_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction_List.SaveToFile';
var
  i: integer;
  Item: TMem_Scan_Command;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginMem_Scan_Command_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Mem_Scan_Command_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure TMem_Scan_Command_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TUnscanned_Transaction_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TMem_Scan_Command;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Mem_Scan_Command) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TMem_Scan_Command.Create;
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
function TMem_Scan_Command_List.Mem_Scan_Command_At(Index: integer
  ): TMem_Scan_Command;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TMem_Scan_Command(P);
end;

//------------------------------------------------------------------------------
function TMem_Scan_Command_List.GetAs_pRec(Item: TMem_Scan_Command): pMem_Scan_Command_Rec;
begin
  if Assigned(Item) then
    result := Item.As_pRec
  else
    result := nil;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
