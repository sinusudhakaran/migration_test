unit cmList32;

interface

uses
  eCollect, BKDEFS, BKcmIO, cmObj32, IOSTREAM, Math, SysUtils, TOKENS, LogUtil,
  BKDbExcept,
  StDate,
  bkDateUtils,
  MoneyDef,
  bkConst;

type
  { ----------------------------------------------------------------------------
    TCandidate_Mem_List
  ---------------------------------------------------------------------------- }
  TCandidate_Mem_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item: Pointer); override;

  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Candidate_Mem_At(Index: integer): TCandidate_Mem;

    function  GetAs_pRec(Item: TCandidate_Mem): pCandidate_Mem_Rec;
  end;


implementation

const
   UnitName = 'cmList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TCandidate_Mem_List
------------------------------------------------------------------------------ }
constructor TCandidate_Mem_List.Create;
begin
  inherited Create;

  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TCandidate_Mem_List.Compare(Item1, Item2: Pointer): integer;
begin
  if (TCandidate_Mem(Item1).cmFields.cmType             <> TCandidate_Mem(Item2).cmFields.cmType) or
  (TCandidate_Mem(Item1).cmFields.cmBank_Account_Number <> TCandidate_Mem(Item2).cmFields.cmBank_Account_Number) or
  (TCandidate_Mem(Item1).cmFields.cmAccount             <> TCandidate_Mem(Item2).cmFields.cmAccount) or
  (TCandidate_Mem(Item1).cmFields.cmID                  <> TCandidate_Mem(Item2).cmFields.cmID) or
  (AnsiCompareText(TCandidate_Mem(Item1).cmFields.cmStatement_Details,
                   TCandidate_Mem(Item2).cmFields.cmStatement_Details) <> 0) then
    Result := 1
  else
    Result := 0;
end;

{------------------------------------------------------------------------------}
procedure TCandidate_Mem_List.FreeItem(Item: Pointer);
var
  P: TCandidate_Mem;
begin
  P := TCandidate_Mem(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
procedure TCandidate_Mem_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TCandidate_Mem_List.SaveToFile';
var
  i: integer;
  Item: TCandidate_Mem;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginCandidate_Mem_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Candidate_Mem_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TCandidate_Mem_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TCandidate_Mem_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TCandidate_Mem;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Candidate_Mem) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TCandidate_Mem.Create;
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
function TCandidate_Mem_List.Candidate_Mem_At(Index: integer
  ): TCandidate_Mem;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TCandidate_Mem(P);
end;

{------------------------------------------------------------------------------}
function TCandidate_Mem_List.GetAs_pRec(Item: TCandidate_Mem
  ): pCandidate_Mem_Rec;
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
