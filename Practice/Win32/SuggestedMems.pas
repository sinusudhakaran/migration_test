unit SuggestedMems;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  baObj32,
  BKDEFS,
  clObj32,
  Classes;

type
  TTransSuggestedState = (tssUnScanned,
                          tssSimpleCompareDone,
                          tssLongestPhraseDone);

  TSuggestedMems = class(TObject)
  private
    procedure ProcessTransaction(aBankAccount : TBank_Account; aTranRec : tTransaction_Rec);
    procedure ProcessAccount(aBankAccount : TBank_Account);
    procedure ProcessClient(aClient: TClientObj);
  protected
  public
  end;

Const
  TRAN_SUGGESTIONS_ALLDONE = tssLongestPhraseDone;

  //----------------------------------------------------------------------------
  function CallSuggestedMems(): TSuggestedMems;

//------------------------------------------------------------------------------
implementation

uses
  LogUtil;

const
  UnitName = 'SuggestedMems';

var
  fSuggestedMems: TSuggestedMems;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function CallSuggestedMems(): TSuggestedMems;
begin
  if not assigned(fSuggestedMems) then
  begin
    fSuggestedMems := TSuggestedMems.Create;
  end;

  result := fSuggestedMems;
end;

{ TSuggestedMems }
//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(aBankAccount: TBank_Account; aTranRec : tTransaction_Rec);
begin
  if aTranRec.txSuggested_Mem_State = tssUnScanned then
  begin
    aTranRec.txSuggested_Mem_State := tssSimpleCompareDone;
  end;
  if aTranRec.txSuggested_Mem_State = tssSimpleCompareDone then
  begin
    aTranRec.txSuggested_Mem_State := tssLongestPhraseDone;
  end;

  Dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessAccount(aBankAccount: TBank_Account);
var
  TranIndex : integer;
  TranRec : tTransaction_Rec;
begin
  if aBankAccount.baFields.baSuggested_UnProcessed_Count = 0 then
    Exit;

  for TranIndex := aBankAccount.baTransaction_List.ItemCount-1 downto 0 do
  begin
    TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex)^;

    if TranRec.txSuggested_Mem_State = TRAN_SUGGESTIONS_ALLDONE then
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
  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);

    ProcessAccount(BankAccount);
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
