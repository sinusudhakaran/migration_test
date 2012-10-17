unit ForexHelpers;

// ----------------------------------------------------------------------------
interface

uses
  SysUtils,
  BKDefs,
  MCDefs,
  MoneyDef,
  clObj32,
  baObj32;
// ----------------------------------------------------------------------------

type
  TTransactionHelper = record helper for TTransaction_Rec
  private
    function Client : TClientObj;
    function GetAccount: string;
    function GetDefault_Forex_Rate: Double;
    function GetGSTClass: Integer;
    function GetLocal_Amount: Money;
    function GetOriginal_Statement_Amount: Money;
    function GetStatement_Amount: Money;
    procedure SetGSTClass(const Value: Integer);
    procedure SetStatement_Amount(const Value: Money);
  public
    function AddDissection : pDissection_Rec;
    function Bank_Account : TBank_Account;
    function Is_Default_Forex_Rate : Boolean;
    function IsDissected : Boolean;
    function Locked: Boolean;
    procedure ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
    property Default_Forex_Rate : Double read GetDefault_Forex_Rate;
    property GST_Class : Integer read GetGSTClass write SetGSTClass;
    property Local_Amount : Money read GetLocal_Amount;
    property Original_Statement_Amount : Money read GetOriginal_Statement_Amount;
    property Statement_Amount : Money read GetStatement_Amount write SetStatement_Amount;
  end;

  TDissection_Helper = record helper for TDissection_Rec
  private
    function Bank_Account : TBank_Account;
    function Client : TClientObj;
    function GetDate_Effective: Integer;
    function GetDefault_Forex_Rate: Double;
    function GetLocal_Amount: Money;
    function GetStatement_Amount: Money;
  public
    function Locked: Boolean;
    property Date_Effective: Integer  read GetDate_Effective;
    property Default_Forex_Rate : Double read GetDefault_Forex_Rate;
    property Local_Amount : Money read GetLocal_Amount;
    property Statement_Amount : Money read GetStatement_Amount;
  end;

  // UK Multi-Currencies
  function  GetCountry: byte;
  function  SupportsMultiCurrencies: boolean;
  function  IsGainLossClient: boolean;
  function  IsGainLossAccount(const aAccount: TBank_Account): boolean;
  function  IsValidGainLossCode(const aCode: string): boolean;
  function  CurrencyExists(aExchange: pExchange_Rates_Header_Rec;
              const aCurrency: string): boolean; overload;
  function  CurrencyExists(const aCurrency: string): boolean; overload;


implementation

uses
   GSTCalc32,
   BKConst,
   BKDSIO,
   Globals,
   BaList32;

{ TTransactionHelper }

function TTransactionHelper.Bank_Account: TBank_Account;
begin
  Result := TBank_Account( txBank_Account );
end;

function TTransactionHelper.Client : TClientObj;
begin
  Result := TClientObj( txClient );
end;

function TTransactionHelper.GetAccount: string;
begin
  Result := txAccount;
end;

function TTransactionHelper.GetStatement_Amount: Money;
begin
  Result := txAmount;
end;

function TTransactionHelper.GetDefault_Forex_Rate: Double;
begin
  if (txDate_Transferred > 0) or (txLocked) then
    Result := txForex_Conversion_Rate
  else
    Result := Bank_Account.Default_Forex_Conversion_Rate( txDate_Effective );
end;

function TTransactionHelper.GetGSTClass: Integer;
begin
  Result := txGST_Class;
end;

function TTransactionHelper.GetLocal_Amount: Money;
var
  ExchangeRate: double;
begin
  Result := txAmount;

  if not Assigned(txBank_Account) then Exit;

  if (Bank_Account.IsAForexAccount) then begin
    ExchangeRate :=  Default_Forex_Rate;
    if ExchangeRate <> 0 then
      Result := (txAmount / ExchangeRate)
    else
      Result := 0;
  end;
end;

function TTransactionHelper.GetOriginal_Statement_Amount: Money;
begin
  Result := txOriginal_Amount;
end;

// ----------------------------------------------------------------------------

function TTransactionHelper.AddDissection: pDissection_Rec;
var
  Seq : Integer;
begin
  Result := New_Dissection_Rec;
  Seq := 0;
  If txLast_Dissection <> nil then
     Seq := txLast_Dissection^.dsSequence_No;
  Inc(Seq);
  with Result^ do
  begin
    dsTransaction  := @Self;
    dsSequence_No  := Seq;
    dsNext         := NIL;
    dsClient       := txClient;
    dsBank_Account := txBank_Account;
  end;
  if (txFirst_Dissection = nil) then
     txFirst_Dissection := Result; // Im the first
  if (txLast_Dissection <> nil) then
     txLast_Dissection^.dsNext := Result; // Hook me in
  txLast_Dissection := Result;// Im always the last
end;

// ----------------------------------------------------------------------------

procedure TTransactionHelper.ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
var
  dMax   : pDissection_Rec;
  dThis  : pDissection_Rec;
  Total  : Money;
begin
//This is no longer used!!!
  if not IsDissected then
     exit;

  dThis := txFirst_Dissection;
  dMax := dThis;
  Total := 0;
  while dThis <> NIL do
  Begin
    Total := Total + dThis.dsAmount;
    if Abs( dThis.dsAmount ) > Abs( dMax.dsAmount ) then
       dMax := dThis; { Find the biggest figure }
    dThis := dThis.dsNext;
  End;
//  dMax.Local_Amount := dMax.dsAmount + ( txAmount - Total );
end;

// ----------------------------------------------------------------------------

function TTransactionHelper.IsDissected: Boolean;
begin
  Result := ( txFirst_Dissection <> NIL );
end;

function TTransactionHelper.Is_Default_Forex_Rate: Boolean;
begin
  Result := ( txForex_Conversion_Rate = Default_Forex_Rate );
end;

function TTransactionHelper.Locked: Boolean;
begin
  Result := txLocked
         or (txDate_Transferred <> 0);
end;

procedure TTransactionHelper.SetStatement_Amount(const Value: Money);
begin
  if Locked then
     exit;
  txAmount := Value;  //Statement_Amount should be removed and ues txAmount directly instead?
  if txFirst_Dissection = nil then
  begin
    CalculateGST( Client, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount );
    txGST_Has_Been_Edited := False;
  end;
end;

// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetGSTClass(const Value: Integer);
begin
  if Locked then
     exit;
  txGST_Class := Value;
  if txGST_Class = 0 then
    txGST_Amount := 0
  else
    txGST_Amount := ( CalculateGSTForClass( Client, txDate_Effective, Local_Amount, txGST_Class ) );
end;

{ TDissection_Helper }

function TDissection_Helper.Bank_Account: TBank_Account;
begin
   Result := TBank_Account(dsBank_Account);
end;

function TDissection_Helper.Client: TClientObj;
begin
  Result := TClientObj( dsClient );
end;

function TDissection_Helper.GetDate_Effective: Integer;
begin
  Result := dsTransaction.txDate_Effective;
end;

function TDissection_Helper.GetDefault_Forex_Rate: Double;
begin
  //Gets the exchange rate from the transaction
  Result := dsTransaction.Default_Forex_Rate;
end;

function TDissection_Helper.GetLocal_Amount: Money;
var
  ExchangeRate: double;
  DissectionRec: pDissection_Rec;
  DissectionTotal: double;
begin
  Result := dsAmount;

  if not Assigned(dsBank_Account) then Exit;

  if (Bank_Account.IsAForexAccount) then begin

    if (dsNext = nil) then begin
      DissectionTotal := 0;
      DissectionRec := dsTransaction.txFirst_Dissection;
      while (DissectionRec <> nil) and
            (DissectionRec <> Self.dsTransaction.txLast_Dissection) do begin
        DissectionTotal := DissectionTotal + DissectionRec.Local_Amount;
        DissectionRec := DissectionRec.dsNext;
      end;
      Result := (Self.dsTransaction.Local_Amount - DissectionTotal);
    end else begin

      ExchangeRate :=  Default_Forex_Rate;
      if ExchangeRate <> 0 then
        Result := (dsAmount / ExchangeRate)
      else
        Result := 0;
    end;
  end;
end;

function TDissection_Helper.GetStatement_Amount: Money;
begin
//  if  Bank_Account.IsAForexAccount then
//     Result := dsForeign_Currency_Amount
//  else
     Result := dsAmount;
end;

function TDissection_Helper.Locked: Boolean;
begin
   Result := dsTransaction.Locked;
end;

// ----------------------------------------------------------------------------
function GetCountry: byte;
begin
  if Assigned(AdminSystem) then
    result := AdminSystem.fdFields.fdCountry
  else if Assigned(MyClient) then
    result := MyClient.clFields.clCountry
  else
    result := whNewZealand; // Default (may be necessary during startup)
end;

// ----------------------------------------------------------------------------
function SupportsMultiCurrencies: boolean;
begin
  result := (GetCountry = whUK);
end;

// ----------------------------------------------------------------------------
function IsGainLossClient: boolean;
begin
  result := false;

  // Must be UK practice (currently)
  if not SupportsMultiCurrencies then
    exit;

  // Could happen during startup
  if not Assigned(MyClient) then
    exit;

  // Any of the accounts is a foreign currency?
  result := MyClient.HasForeignCurrencyAccounts;
end;

// ----------------------------------------------------------------------------
function IsGainLossAccount(const aAccount: TBank_Account): boolean;
begin
  ASSERT(assigned(aAccount));

  result := false;

  // Must be UK practice (currently)
  if not SupportsMultiCurrencies then
    exit;

  // Foreign account
  result := aAccount.IsAForexAccount;
end;

// ----------------------------------------------------------------------------
function IsValidGainLossCode(const aCode: string): boolean;
const
  ALLOWED_TYPES = [atIncome, atExpense, atOtherIncome, atOtherExpense];
var
  pAccount: pAccount_Rec;
begin
  // If the Chart of Accounts is empty, then any code is correct (same as Contra)
  if (MyClient.clChart.ItemCount = 0) then
  begin
    result := true;
    exit;
  end;

  // Code not in chart?
  pAccount := MyClient.clChart.FindCode(aCode);
  if not Assigned(pAccount) then
  begin
    result := false;
    exit;
  end;

  // Type not allowed for Gain/Loss?
  if not (pAccount.chAccount_Type in ALLOWED_TYPES) then
  begin
    result := false;
    exit;
  end;

  result := true;
end;

// ----------------------------------------------------------------------------
function CurrencyExists(aExchange: pExchange_Rates_Header_Rec; const aCurrency: string): boolean;
var
  i: integer;
begin
  ASSERT(assigned(aExchange));
  
  for i := Low(aExchange.ehISO_Codes) to High(aExchange.ehISO_Codes) do
  begin
    if SameText(aExchange.ehISO_Codes[i], aCurrency) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

// ----------------------------------------------------------------------------
function CurrencyExists(const aCurrency: string): boolean;
begin
  result := true;

  // This is what "Maintain Currencies" uses
  if Assigned(AdminSystem) then
  begin
    AdminSystem.SyncCurrenciesToSystemAccounts;
    if CurrencyExists(@AdminSystem.fCurrencyList, aCurrency) then
      exit;
  end;

  // We need to use this for Books
  if Assigned(MyClient) then
  begin
    if CurrencyExists(@MyClient.ExchangeSource.Header, aCurrency) then
      exit;

    if (MyClient.clExtra.ceLocal_Currency_Code = aCurrency) then
      exit;
  end;

  result := false;
end;


end.
