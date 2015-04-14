unit SuggestedMems;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  baObj32,
  BKDEFS,
  clObj32,
  ExtCtrls,
  Classes;

type
  TTransSuggestedState = (tssNoScan,
                          tssSimpleCompare,
                          tssLongestPhrase);

const
  Min_Sugg_State = ord(tssNoScan);
  Max_Sugg_State = ord(tssLongestPhrase);

type
  TSuggestedMems = class(TObject)
  private
    fMainState : TTransSuggestedState;
    fScanTimer : TTimer;
    fMemScanRefCount : integer;
  protected
    procedure DoScanTimer(Sender: TObject);

    function SimpleSearchForSameText() : boolean;
    function SearchForLongestCommonPhrase() : boolean;

    procedure MemScan();
    procedure ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
    procedure ProcessAccount(aBankAccount : TBank_Account);
    procedure ProcessClient(aClient: TClientObj);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : TTransSuggestedState);
    procedure UpdateAccountWithTransDelete(aBankAccount : TBank_Account);
    procedure UpdateAccountWithTransInsert(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aNew : boolean);

    procedure SetMainState();
    procedure ResetAll(aClient: TClientObj);

    procedure StartMemScan(aForceStart : boolean = false);
    procedure StopMemScan(aForceStop : boolean = false);

    property MainState : TTransSuggestedState read fMainState write fMainState;
  end;

  //----------------------------------------------------------------------------
  function SuggestedMem(): TSuggestedMems;

//------------------------------------------------------------------------------
implementation

uses
  Globals,
  LogUtil;

const
  UnitName = 'SuggestedMems';

var
  fSuggestedMems: TSuggestedMems;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function SuggestedMem(): TSuggestedMems;
begin
  if not assigned(fSuggestedMems) then
  begin
    fSuggestedMems := TSuggestedMems.Create;
  end;

  result := fSuggestedMems;
end;

{ TSuggestedMems }
//------------------------------------------------------------------------------
procedure TSuggestedMems.DoScanTimer(Sender: TObject);
begin
  if fMemScanRefCount > 0 then
    Exit;

  try
    StopMemScan();
    MemScan();
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.SimpleSearchForSameText() : boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.SearchForLongestCommonPhrase() : boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.MemScan();
begin

end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
begin
  if MainState = tssNoScan then
    Exit;

  if aTrans^.txSuggested_Mem_State = ord(tssNoScan) then
  begin
    SimpleSearchForSameText();
    SetSuggestedTransactionState(aBankAccount, aTrans, tssSimpleCompare);
  end;

  if MainState = tssSimpleCompare then
    Exit;

  if aTrans^.txSuggested_Mem_State = ord(tssSimpleCompare) then
  begin
    SearchForLongestCommonPhrase();
    SetSuggestedTransactionState(aBankAccount, aTrans, tssLongestPhrase);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessAccount(aBankAccount: TBank_Account);
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
begin
  if MainState = tssNoScan then
    Exit;

  if aBankAccount.baFields.baSuggested_UnProcessed_Count = 0 then
    Exit;

  for TranIndex := aBankAccount.baTransaction_List.ItemCount-1 downto 0 do
  begin
    TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    if TranRec^.txSuggested_Mem_State = ord(MainState) then
      Continue;

    ProcessTransaction(aBankAccount, TranRec);

    if aBankAccount.baFields.baSuggested_UnProcessed_Count = 0 then
      Exit;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessClient(aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if MainState = tssNoScan then
    Exit;

  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);

    ProcessAccount(BankAccount);
  end;
end;

//------------------------------------------------------------------------------
constructor TSuggestedMems.Create;
begin
  fScanTimer := TTimer.Create(nil);
  fScanTimer.Enabled  := false;
  fScanTimer.Interval := 100;
  fScanTimer.OnTimer  := DoScanTimer;
  fMemScanRefCount := 1;
end;

//------------------------------------------------------------------------------
destructor TSuggestedMems.Destroy;
begin
  FreeandNil(fScanTimer);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : TTransSuggestedState);
var
  OldState : byte;
begin
  OldState := aTrans^.txSuggested_Mem_State;
  if OldState = ord(aState) then
    Exit;

  aTrans^.txSuggested_Mem_State := ord(aState);

  if (OldState = ord(MainState)) then
    inc(TBank_Account(aBankAccount).baFields.baSuggested_UnProcessed_Count);

  if (aState = MainState) then
    if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
      dec(TBank_Account(aBankAccount).baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.StartMemScan(aForceStart : boolean);
begin
  if aForceStart then
  begin
    fMemScanRefCount := 0;
    fScanTimer.Enabled := true;

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'StartMemScan, Client ' + MyClient.clFields.clCode);

    Exit;
  end;

  if fMemScanRefCount > 0 then
    dec(fMemScanRefCount);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.StopMemScan(aForceStop : boolean);
begin
  inc(fMemScanRefCount);

  if aForceStop then
  begin
    fScanTimer.Enabled := false;

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'StopMemScan, Client ' + MyClient.clFields.clCode);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransDelete(aBankAccount: TBank_Account);
begin
  if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
    Dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransInsert(aBankAccount: TBank_Account; aTrans: pTransaction_Rec; aNew : boolean);
begin
  if aNew then
    aTrans^.txSuggested_Mem_State := 0;

  if aTrans^.txSuggested_Mem_State = 0 then
    inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetMainState();
begin
  case MEMSINI_SupportOptions of
    meiDisableSuggestedMemsAll : fMainState := tssNoScan;
    meiDisableSuggestedMemsv2  : fMainState := tssSimpleCompare;
    meiFullfunctionality       : fMainState := tssLongestPhrase;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetAll(aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
  TranIndex : integer;
  TranRec : pTransaction_Rec;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'ResetAll, Client ' + aClient.clFields.clCode);

  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
    BankAccount.baFields.baSuggested_UnProcessed_Count := BankAccount.baTransaction_List.ItemCount;

    for TranIndex := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      TranRec := BankAccount.baTransaction_List.Transaction_At(TranIndex);
      TranRec^.txSuggested_Mem_State := ord(tssNoScan);
    end;
  end;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  fSuggestedMems := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fSuggestedMems);
end;

end.
