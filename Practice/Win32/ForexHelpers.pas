unit ForexHelpers;

// ----------------------------------------------------------------------------
interface

uses
   BKDefs,
   MoneyDef,
   clObj32,
   baObj32;
// ----------------------------------------------------------------------------

Type
  TTransactionHelper = record helper for TTransaction_Rec
  private
    procedure SetLocal_Amount(const Value: Money);
    procedure SetForex_Rate(const Value: Double);
    function Client : TClientObj;
    function GetForex_Rate: Double;
    function GetLocal_Amount: Money;
    function GetForeign_Amount: Money;
    procedure SetForeign_Amount(const Value: Money);
    function GetStatement_Amount: Money;
    function GetAccount: string;
    procedure SetAccount(const Value: string);
    function GetGSTClass: Integer;
    procedure SetGSTClass(const Value: Integer);
    procedure SetStatement_Amount(const Value: Money);
    function GetDefault_Forex_Rate: Double;
    function GetOriginal_Statement_Amount: Money;


  public
    Procedure ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
    function IsDissected : Boolean;
    function Locked: Boolean;
    function AddDissection : pDissection_Rec;
    function Bank_Account : TBank_Account;
    procedure SetForeignCurrencyAmountOnDissection( D : pDissection_Rec; FCAmount : Money );
    property Foreign_Amount : Money read GetForeign_Amount write SetForeign_Amount;
    property Local_Amount : Money read GetLocal_Amount write SetLocal_Amount;
    property Forex_Rate : Double read GetForex_Rate write SetForex_Rate;
    property Statement_Amount : Money read GetStatement_Amount write SetStatement_Amount;
    property Original_Statement_Amount : Money read GetOriginal_Statement_Amount;
    property Account : string read GetAccount write SetAccount;
    property GST_Class : Integer read GetGSTClass write SetGSTClass;
    property Default_Forex_Rate : Double read GetDefault_Forex_Rate;
    function Is_Default_Forex_Rate : Boolean;
  end;

  TDissection_Helper = record helper for TDissection_Rec
  private
    procedure SetLocal_Amount(const Value: Money);
    procedure SetForex_Rate(const Value: Double);
    function GetForex_Rate: Double;
    function GetLocal_Amount: Money;
    function Client : TClientObj;
    function GetForeign_Amount: Money;
    procedure SetForeign_Amount(const Value: Money);
    function GetDefault_Forex_Rate: Double;
    function GetDate_Effective: Integer;
  public
    function Locked: Boolean;
    property Foreign_Amount : Money read GetForeign_Amount write SetForeign_Amount;
    property Local_Amount : Money read GetLocal_Amount write SetLocal_Amount;
    property Forex_Rate : Double read GetForex_Rate write SetForex_Rate;
    property Default_Forex_Rate : Double read GetDefault_Forex_Rate;
    property Date_Effective: Integer  read GetDate_Effective;
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
Begin
  Result := TClientObj( txClient );
End;

function TTransactionHelper.GetAccount: string;
begin
  Result := txAccount;
end;

function TTransactionHelper.GetStatement_Amount: Money;
begin
  if Bank_Account.IsAForexAccount then
     Result := txForeign_Currency_Amount
  else
     Result := txAmount;
end;

function TTransactionHelper.GetDefault_Forex_Rate: Double;
begin
  Result := Bank_Account.Default_Forex_Conversion_Rate( txDate_Effective );
end;

function TTransactionHelper.GetForeign_Amount: Money;
begin
  Result := txForeign_Currency_Amount;
end;


function TTransactionHelper.GetForex_Rate: Double;
begin
  Result := txForex_Conversion_Rate;
end;

function TTransactionHelper.GetGSTClass: Integer;
begin
  Result := txGST_Class;
end;

function TTransactionHelper.GetLocal_Amount: Money;
begin
  Result := txAmount;
end;



function TTransactionHelper.GetOriginal_Statement_Amount: Money;
begin
   if Bank_Account.IsAForexAccount then
     Result := txOriginal_Foreign_Currency_Amount
  else
     Result := txOriginal_Amount;
end;

// ----------------------------------------------------------------------------

function TTransactionHelper.AddDissection: pDissection_Rec;
Var
  Seq : Integer;
Begin
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
Var
  dMax   : pDissection_Rec;
  dThis  : pDissection_Rec;
  Total  : Money;
begin
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
  dMax.Local_Amount := dMax.dsAmount + ( txAmount - Total );
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
  Begin
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

  CalculateGST( Client, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount );
  if (txCoded_By <> cbManualSuper) then
     txCoded_By := cbManual; // Keep
  txGST_Has_Been_Edited := False;
end;

procedure TTransactionHelper.SetStatement_Amount(const Value: Money);
begin
  if Locked then
     exit;

  if Bank_Account.IsAForexAccount then
     Foreign_Amount := Value
  else
     Local_Amount := Value;
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

// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetForeign_Amount(const Value: Money);
begin
  if Locked then
     Exit;

  txForeign_Currency_Amount := Value;
  if txForex_Conversion_Rate <> 0.0 then
     Local_Amount := Round( txForeign_Currency_Amount / txForex_Conversion_Rate )
  else
     Local_Amount := 0;
end;

// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetLocal_Amount(const Value: Money);
begin
  if Locked then
     exit;
  txAmount := Value;
  if txFirst_Dissection = NIL then
  Begin
    CalculateGST( Client, txDate_Effective, txAccount, txAmount, txGST_Class, txGST_Amount );
    txGST_Has_Been_Edited := False;
  End;
end;



// ----------------------------------------------------------------------------

procedure TTransactionHelper.SetForex_Rate(const Value: Double);
Var
  pD : pDissection_Rec;
Begin
  if Locked then
     exit;
  txForex_Conversion_Rate := Value;

  if ( txForeign_Currency_Amount <> 0 )
  and ( txForex_Conversion_Rate <> 0.0 ) then
     Local_Amount := Round( txForeign_Currency_Amount / txForex_Conversion_Rate )
  else
     Local_Amount := 0;

  if IsDissected then
  Begin
    pD := txFirst_Dissection;
    while ( pD <> NIL ) do Begin
      pD.Forex_Rate := Value;
      pD := pD.dsNext;
    End;
    ApplyAnyLocalCurrencyRoundingDiscrepancyToTheBiggestDissectionAmount;
  end;
End;


procedure TTransactionHelper.SetGSTClass(const Value: Integer);
begin
  if Locked then
     exit;
  txGST_Class := Value;
  if txGST_Class = 0 then
    txGST_Amount := 0
  else
    txGST_Amount := ( CalculateGSTForClass( Client, txDate_Effective, txAmount, txGST_Class ) );
end;

{ TDissection_Helper }

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
  Result := dsTransaction.Default_Forex_Rate;
end;


function TDissection_Helper.GetForeign_Amount: Money;
begin
  Result := Self.dsForeign_Currency_Amount;
end;

function TDissection_Helper.GetForex_Rate: Double;
begin
  Result := dsForex_Conversion_Rate;
end;


function TDissection_Helper.GetLocal_Amount: Money;
begin
  Result := dsAmount;
end;

function TDissection_Helper.Locked: Boolean;
begin
   Result := dsTransaction.Locked;
end;


procedure TDissection_Helper.SetForeign_Amount(const Value: Money);
begin
  if Locked then
     Exit;

  dsForeign_Currency_Amount := Value;
  dsForex_Conversion_Rate := Forex_Rate;

  if (dsForeign_Currency_Amount <> 0 )
  and (dsForex_Conversion_Rate <> 0.0 ) then
     Local_Amount := Round( dsForeign_Currency_Amount / dsForex_Conversion_Rate )
  else
     Local_Amount := 0;
end;

procedure TDissection_Helper.SetForex_Rate(const Value: Double);
Begin
  if Locked then
     Exit;

  dsForex_Conversion_Rate := Value;
  if ( dsForeign_Currency_Amount <> 0 )
  and ( dsForex_Conversion_Rate <> 0.0 ) then
     Local_Amount := Round( dsForeign_Currency_Amount / dsForex_Conversion_Rate )
  else
     Local_Amount := 0;
end;


procedure TDissection_Helper.SetLocal_Amount(const Value: Money);
begin
  if Locked then
     Exit;

  dsAmount := Value;
  CalculateGST( Client, dsTransaction.txDate_Effective, dsAccount, dsAmount, dsGST_Class, dsGST_Amount );
  dsGST_Has_Been_Edited := False;
end;


end.
