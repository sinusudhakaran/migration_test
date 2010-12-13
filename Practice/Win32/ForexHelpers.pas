unit ForexHelpers;

// ----------------------------------------------------------------------------
interface

uses
   BKDefs,
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
    procedure SetAccount(const Value: string);
    procedure SetGSTClass(const Value: Integer);
    procedure SetStatement_Amount(const Value: Money);
  public
    function AddDissection : pDissection_Rec;
    function Bank_Account : TBank_Account;
    function Is_Default_Forex_Rate : Boolean;
    function IsDissected : Boolean;
    function Locked: Boolean;
    procedure ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
    procedure SetForeignCurrencyAmountOnDissection( D : pDissection_Rec; FCAmount : Money );
    property Account : string read GetAccount write SetAccount;
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


implementation

uses
   GSTCalc32,
   BKConst,
   BKDSIO;

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
  Result := 0;
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

// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetAccount(const Value: string);
begin
  txAccount := Value;
  if txAccount = '' then
  begin
    { The user has deleted the account code, so uncode the transaction }
    txGST_Class := 0;
    txGST_Amount := 0;
    txHas_Been_Edited := False;
    txGST_Has_Been_Edited := False;
    if ( txCoded_By <> cbManualSuper ) then txCoded_By := cbNotcoded; // Keep
    exit;
  End;

  { The user has entered an Account Code }

  If not Client.clChart.CanCodeTo( txAccount ) then
  Begin { If they have entered an invalid account code, flag the entry as manually coded so
          that the AutoCode doesn't try to recode it. }
    if (txCoded_By <> cbManualSuper) then txCoded_By := cbManual; // Keep
    exit;
  end;

  If ( txType in [9,10] ) and Bank_Account.IsAnEldersAccount then
  Begin
    // special case - elders accounts receive transaction is strange way so
    //                GST needs to be blank by default
    //                !! Only if Misc Dr or Cr,  GST should still be calced
    //                on cheques.
    txGST_Class := 0;
    txGST_Amount := 0;
    if (txCoded_By <> cbManualSuper) then txCoded_By := cbManual; // Keep
    txHas_Been_Edited := False;
    txGST_Has_Been_Edited := True;
    exit;
  end;

  { Normal post account code processing - calculate the GST class and amount and flag the transaction as manually coded }

  CalculateGST( Client, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
  if (txCoded_By <> cbManualSuper) then
     txCoded_By := cbManual; // Keep
  txGST_Has_Been_Edited := False;
end;

procedure TTransactionHelper.SetStatement_Amount(const Value: Money);
begin
  if Locked then
     exit;

//This is no longer used!!!

//  if Bank_Account.IsAForexAccount then
//     Foreign_Amount := Value
//  else
//     Local_Amount := Value;
end;

// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetForeignCurrencyAmountOnDissection(
  D: pDissection_Rec; FCAmount: Money);
begin
  D.dsForeign_Currency_Amount := FCAmount;
  D.dsForex_Conversion_Rate := txForex_Conversion_Rate;
  if D.dsForex_Conversion_Rate <> 0.0 then
     D.dsAmount := Round( D.dsForeign_Currency_Amount / D.dsForex_Conversion_Rate )
  else
     D.dsAmount := 0;
end;

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
  if  Bank_Account.IsAForexAccount then
     Result := dsForeign_Currency_Amount
  else
     Result := dsAmount;
end;

function TDissection_Helper.Locked: Boolean;
begin
   Result := dsTransaction.Locked;
end;


end.
