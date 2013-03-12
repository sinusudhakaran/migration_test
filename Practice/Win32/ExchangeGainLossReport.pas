unit ExchangeGainLossReport;

interface

uses
  DateDef,
  MoneyDef,
  clObj32,
  baObj32,
  glObj32,
  StDate,
  ForexHelpers;

type
  { ----------------------------------------------------------------------------
    Gain/Loss Period (for Client calculations)
  ---------------------------------------------------------------------------- }
  TGainLossPeriod = (
    glpThisPeriod,
    glpThisPeriodLastYear,
    glpYearToDate,
    glpYearToDateLastYear
  );



  { ----------------------------------------------------------------------------
    Helpers
  ---------------------------------------------------------------------------- }
  procedure AddExchangeGainLossTo(const aClient: TClientObj;
              const aAccount: string; const aPeriod: TGainLossPeriod;
              var aAmount: Money);


implementation

{-------------------------------------------------------------------------------
  Periods
-------------------------------------------------------------------------------}
procedure AddExchangeGainLossTo(const aClient: TClientObj;
  const aAccount: string; const aPeriod: TGainLossPeriod; var aAmount: Money);
var
  iFrom: integer;
  iTo: integer;
  Details: TPeriod_Details_Array;
  iBankAccount: integer;
  BankAccount: TBank_Account;
  iPeriod: integer;
  dtGainLoss: TStDate;
  GainLossEntry: TExchange_Gain_Loss;
begin
  ASSERT(assigned(aClient));

  // Note: do not reset aAmount to zero - we're only adding

  // Nothing to do?
  if not IsForeignCurrencyClient(aClient) then
    exit;

  with aClient, clFields do
  begin
    // Range
    if aPeriod in [glpThisPeriod, glpThisPeriodLastYear] then
      iFrom := clTemp_FRS_Last_Period_To_Show
    else
      iFrom := 1;
    iTo := clTemp_FRS_Last_Period_To_Show;

    // Details
    if aPeriod in [glpThisPeriod, glpYearToDate] then
      Details := clTemp_Period_Details_This_Year
    else
      Details := clTemp_Period_Details_Last_Year;

    // Add them
    for iBankAccount := 0 to clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := clBank_Account_List.Bank_Account_At(iBankAccount);

      // No gain/loss entries?
      if not IsForeignCurrencyAccount(BankAccount) then
        continue;

      for iPeriod := iFrom to iTo do
      begin
        dtGainLoss := Details[iPeriod].Period_End_Date;

        // No gain/loss entry for this month?
        GainLossEntry := BankAccount.baExchange_Gain_Loss_List.GetPostedEntry(dtGainLoss);
        if not assigned(GainLossEntry) then
          continue;

        // Account code not the same?
        if (GainLossEntry.glFields.glAccount <> aAccount) then
          continue;

        // Add to amount
        aAmount := aAmount + GainLossEntry.glFields.glAmount;
      end;
    end;
  end;
end;



end.
