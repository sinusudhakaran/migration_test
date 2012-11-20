unit ExchangeGainLoss;

interface

uses
  SysUtils,
  DateUtils,
  Classes,
  ExtCtrls,
  Math,
  clObj32,
  baObj32,
  BKDEFS,
  SYDEFS,
  trxList32,
  stDate,
  bkDateUtils,
  ForexHelpers,
  MoneyDef,
  PeriodUtils,
  ExchangeRateList,
  imagesfrm,
  bkConst,
  Globals,
  MoneyUtils,
  bautils,
  InsertTrans,
  AuditMgr,
  LogUtil;

type
  { ----------------------------------------------------------------------------
    TValidateExchangeGainLoss
  ---------------------------------------------------------------------------- }
  TValidateExchangeGainLoss = class
  private
    fClient: TClientObj;
    fErrors: TStringList;
    fErrorCount: integer;

    procedure AddError(const aError: string);

  public
    // Constructors
    constructor Create(const aClient: TClientObj);
    destructor Destroy; override;

    function  Validate(var aErrors: string): boolean;
  end;


  { ----------------------------------------------------------------------------
    TPostedEntry
  ---------------------------------------------------------------------------- }
  TPostedEntry = object
  public
    GainLoss: Money;
    Date: TStDate; // Zero if not posted. Could be any date.

  public
    // Whether anything was posted for this month
    function  GetPosted: boolean;
    property  Posted: boolean read GetPosted;

    // Gain/Loss with currency symbol of the practice, NOT the bank account
    function  GetGainLossCurrency: string;
    property  GainLossCurrency: string read GetGainLossCurrency;
    // CR/DR
    function  GetGainLossCrDr: string;
    property  GainLossCrDr: string read GetGainLossCrDr;
  end;


  { ----------------------------------------------------------------------------
    TMonthEndingBankAccount
  ---------------------------------------------------------------------------- }
  PMonthEndingBankAccount = ^TMonthEndingBankAccount;

  TMonthEndingBankAccount = object
  public
    BankAccount: TBank_Account;
    PostedEntry: TPostedEntry; // As it is currently posted (may not be there)
    GainLoss: Money;

  public
    // Name/Currency combination
    function  GetAccountNameCurrency: string;
    property  AccountNameCurrency: string read GetAccountNameCurrency;
    // Gain/Loss with currency symbol of the practice, NOT the bank account
    function  GetGainLossCurrency: string;
    property  GainLossCurrency: string read GetGainLossCurrency;
    // CR/DR
    function  GetGainLossCrDr: string;
    property  GainLossCrDr: string read GetGainLossCrDr;
  end;

  TMonthEndingBankAccounts = array of TMonthEndingBankAccount;


  { ----------------------------------------------------------------------------
    TMonthEnding
  ---------------------------------------------------------------------------- }
  PMonthEnding = ^TMonthEnding;

  TMonthEnding = object
  public
    // Date
    Date: TDateTime; // Day part is always 1

    // Bank Accounts and additional information for grid, etc
    BankAccounts: TMonthEndingBankAccounts;

    { Overall Status
      Locked      => (NrTransactions = NrLocked)
      Transferred => (NrTransactions = NrTransferred)
      AlreadyRun  => (NrGainLossTransactions = NrBankAccounts) for a given month
    }
    NrTransactions: integer;
    NrLocked: integer;
    NrTransferred: integer;
    AvailableData: boolean;
    NrAlreadyRun: integer;

    // Exchange Rate rules
    ExchangeRateMissing: boolean;
    ExchangeRateMissingLastDayOfPreviousMonth: boolean;

  public
    // Bank Accounts
    function  RegisterBankAccount(const aBankAccount: TBank_Account): PMonthEndingBankAccount;

    // Calculated fields
    function  GetDateAsStDate: TStDate;
    property  DateAsStDate: TStDate read GetDateAsStDate;
    function  GetYear: integer;
    property  Year: integer read GetYear;
    function  GetMonth: integer;
    property  Month: integer read GetMonth;
    function  GetFinalised: boolean;
    property  Finalised: boolean read GetFinalised;
    function  GetTransferred: boolean;
    property  Transferred: boolean read GetTransferred;
    function  GetAlreadyRun: boolean;
    property  AlreadyRun: boolean read GetAlreadyRun;
    function  GetCanCalculateGainLoss: boolean;
    property  CanCalculateGainLoss: boolean read GetCanCalculateGainLoss;
    function  GetMonthEndingDate: TDateTime;
    property  MonthEndingDate: TDateTime read GetMonthEndingDate;
    function  GetMonthEndingDateAsStDate: TStDate;
    property  MonthEndingDateAsStdate: TStDate read GetMonthEndingDateAsStDate;
    procedure DetermineMonthStartEnd(var aStart: TStDate; var aEnd: TStDate);
  end;

  TMonthEndingArray = array of TMonthEnding;


  { ----------------------------------------------------------------------------
    TMonthEndingOption
  ---------------------------------------------------------------------------- }
  TMonthEndingOption = (
    // Prevent culling of first months - necessary for client home screen
    meoCullFirstMonths
  );

  TMonthEndingOptions = set of TMonthEndingOption;


  { ----------------------------------------------------------------------------
    TMonthEndings
  ---------------------------------------------------------------------------- }
  TMonthEndings = class(TObject)
  private
    fClient: TClientObj;
    fOptions: TMonthEndingOptions;
    fMonthEndings: TMonthEndingArray;
    fExchangeSource: TExchangeSource;

    // Generic helpers
    procedure AddError(const aError: string; var aErrors: string);
    procedure SplitYearMonth(const aDate: TDateTime; var aYear: integer; var aMonth: integer); overload;
    procedure SplitYearMonth(const aDate: TStDate; var aYear: integer; var aMonth: integer); overload;
    procedure IncreaseYearMonth(var aYear: integer; var aMonth: integer);

    // Exchange helpers
    function  GetIsoIndex(const aCurrencyCode: string): integer;
    function  HasExchangeRate(const aDate: TStDate; const aIsoIndex: integer): boolean;
    function  ApplyExchangeRateForexToBase(const aDate: TStDate; const aIsoIndex: integer;
                const aValue: Money): Money;

    // Implementation helpers
    function  GetFirstLastEffective(var aFirstEffective: TDateTime;
                var aLastEffective: TDateTime): boolean;
    procedure CreateMonthRange(const aFirstEffective: TDateTime;
                const aLastEffective: TDateTime);
    function  FindMonthEnding(const aDate: TStDate; var aIndex: integer): boolean; overload;
    function  FindMonthEnding(const aDate: TStDate): PMonthEnding; overload;
    procedure SetMonthEnding(const aBankAccount: TBank_Account); overload;
    procedure SetAvailableData(const aFrom: TStDate; const aTo: TStDate);
    procedure SetMonthEnding; overload;
    procedure DeleteFirstMonth;
    procedure CullFirstMonths;
    procedure VerifyExchangeRatePreviousMonth;
    // Calculate Gain/Loss
    procedure GetOpeningClosingBalance(const aStart: TStDate; const aEnd: TStDate;
                const aBankAccount: TBank_Account; var aOpening: Money;
                var aClosing: Money);
    procedure CalculateGainLoss(var aBankAccount: TMonthEndingBankAccount;
                const aStart: TStDate; const aEnd: TStDate); overload;
    procedure CalculateGainLoss(var aMonth: TMonthEnding); overload;
    procedure CalculateGainLoss; overload;
    // Post entries
    procedure DeletePreviousGainLossEntry(const aMonth: PMonthEnding;
                const aTransactions: TTransaction_List);
    procedure PostGainLossEntry(const aMonth: PMonthEnding;
                const aBankAccount: TMonthEndingBankAccount);

  public
    // Constructors
    constructor Create(const aClient: TClientObj);
    destructor Destroy; override;

    // These work during the Refresh
    property  Options: TMonthEndingOptions read fOptions write fOptions;

    procedure Refresh;

    function  GetCount: integer;
    property  Count: integer read GetCount;
    function  GetItem(const aIndex: integer): TMonthEnding;
    property  Items[const aIndex: integer]: TMonthEnding read GetItem; default;

    function  ValidateMonthEnding(const aMonthIndex: integer;
                var aErrors: string): boolean;

    procedure PostGainLossEntries(const aMonthIndex: integer);
  end;


  TMonthEndingsClass = class of TMonthEndings;


  { ----------------------------------------------------------------------------
    Helper functions
  ---------------------------------------------------------------------------- }
  function  ValidateExchangeGainLoss(const aClient: TClientObj;
              var aErrors: string): boolean;

  { The Gain/Loss transaction is posted to the last day of the month with the
    Gain/Loss amount from the wizard. }
  function  IsGainLossTransaction(const aTransaction: pTransaction_Rec): boolean;

  // Special field in transaction
  function  GetGainLossPostedDate(const aTransaction: pTransaction_Rec): TStDate;
  procedure SetGainLossPostedDate(const aTransaction: pTransaction_Rec;
              const aValue: TStDate);

  { Special baUtils.GetBalances that ignores the Gain/Loss Transaction
    Note: this is quite important because it distorts the COB/CSUM/CCB
    calculations. }
  procedure GainLossGetBalances(b: TBank_Account; d1, d2: tStDate; var BankOpBal,
              BankClBal, SystemOpBal, SystemClBal: money);


implementation

type
  { ----------------------------------------------------------------------------
    Helper functions
  ---------------------------------------------------------------------------- }
  TValidationRule = (
    ruleForeignTransactionsMustExist,
    ruleBankAccountsMustHaveGainLossCode,
    ruleGainLossCodesMustBeValid,
    ruleCurrenciesMustBeSetup,
    ruleOpeningBalanceMustBeSet
  );


const
  { ----------------------------------------------------------------------------
    Validation error messages
  ---------------------------------------------------------------------------- }
  ERR_FOREIGN_TRANSACTIONS_MUST_EXIST =
    'There are no foreign currency transactions available to run the wizard for';

  ERR_ACCOUNTS_MUST_HAVE_GAINLOSS_CODE =
    'Some foreign currency Bank Accounts do not have an Exchange Gain/Loss Code assigned to them';

  ERR_ACCOUNTS_MUST_HAVE_VALID_GAINLOSS_CODE =
    'Some foreign currency Bank Accounts have an invalid Exchange Gain/Loss Code assigned to them';

  ERR_CURRENCIES_MUST_BE_SETUP =
    'There are currencies used by this client’s foreign currency Bank Accounts that are not set up in Maintain Currencies';

  ERR_ACCOUNTS_MUST_HAVE_OPENING_BALANCE =
    'Some foreign currency Bank Accounts do not have a Balance set';

  RULE_ERRORS: array[TValidationRule] of string = (
    ERR_FOREIGN_TRANSACTIONS_MUST_EXIST,
    ERR_ACCOUNTS_MUST_HAVE_GAINLOSS_CODE,
    ERR_ACCOUNTS_MUST_HAVE_VALID_GAINLOSS_CODE,
    ERR_CURRENCIES_MUST_BE_SETUP,
    ERR_ACCOUNTS_MUST_HAVE_OPENING_BALANCE
  );


const
  { ----------------------------------------------------------------------------
    Month Ending error messages
  ---------------------------------------------------------------------------- }
  ERR_FINALISED_OR_TRANSFERRED =
    'Please select a Month Ending to calculate the Exchange Gains and/or Losses that is not finalised or transferred.';

  ERR_AVAILABLE_DATA =
    'Please retrieve all available data before calculating the Exchange Gains and/or Losses for this Month Ending.';

  ERR_MISSING_EXCHANGE_RATE =
    'Please select a Month Ending to calculate the Exchange Gains and/or Losses that has a complete list of exchange rates available.';

  ERR_MISSING_EXCHANGE_RATE_PREVIOUS_MONTH =
    'Please select a Month Ending to calculate the Exchange Gains and/or Losses that has all exchange rates available for the last day of the previous month.';


const
  TRANSACTION_REFERENCE = 'GAIN/LOSS';
  TRANSACTION_DESCRIPTION = 'Exchange Gain/Loss';


// Debug
const
   UnitName = 'ExchangeGainLoss';
var
   DebugMe: boolean = false;


{-------------------------------------------------------------------------------
  ValidateExchangeGainLoss
-------------------------------------------------------------------------------}
function ValidateExchangeGainLoss(const aClient: TClientObj; var aErrors: string): boolean;
var
  Validator: TValidateExchangeGainLoss;
begin
  ASSERT(assigned(aClient));

  aErrors := '';

  Validator := TValidateExchangeGainLoss.Create(aClient);
  try
    result := Validator.Validate(aErrors);
  finally
    FreeAndNil(Validator);
  end;
end;


{-------------------------------------------------------------------------------
  TValidateExchangeGainLoss
-------------------------------------------------------------------------------}
constructor TValidateExchangeGainLoss.Create(const aClient: TClientObj);
begin
  ASSERT(assigned(aClient));
  fClient := aClient;
  fErrors := TStringList.Create;
end;

{------------------------------------------------------------------------------}
destructor TValidateExchangeGainLoss.Destroy;
begin
  FreeAndNil(fErrors);
  // Do not free fClient
end;

{------------------------------------------------------------------------------}
procedure TValidateExchangeGainLoss.AddError(const aError: string);
var
  sPrefix: string;
begin
  // Separator?
  if (fErrors.Count > 0) then
    fErrors.Add('');

  // Determine line prefix (don't use fErrors.Count, because it has empty lines)
  Inc(fErrorCount);
  sPrefix := Format('%d) ', [fErrorCount]);

  // Add error
  fErrors.Add(sPrefix + aError);
end;

{------------------------------------------------------------------------------}
function TValidateExchangeGainLoss.Validate(var aErrors: string): boolean;
var
  iRule: TValidationRule;
  Errors: array[TValidationRule] of boolean;
  i: integer;
  BankAccount: TBank_Account;
begin
  // Init error messages
  for iRule := Low(TValidationRule) to High(TValidationRule) do
  begin
    Errors[iRule] := false;
  end;
  Errors[ruleForeignTransactionsMustExist] := true;

  // Validate bank accounts
  for i := 0 to fClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := fClient.clBank_Account_List[i];
    ASSERT(assigned(BankAccount));

    // Not a foreign account?
    if not IsForeignCurrencyAccount(BankAccount) then
      continue;

    // Transactions exist for this bank account?
    if (BankAccount.baTransaction_List.ItemCount <> 0) then
      Errors[ruleForeignTransactionsMustExist] := false; // Turn the error off

    // Code not set?
    if (BankAccount.baFields.baExchange_Gain_Loss_Code = '') then
      Errors[ruleBankAccountsMustHaveGainLossCode] := true
    else
    begin
      // If code is set, it must be valid
      if not IsValidGainLossCode(BankAccount.baFields.baExchange_Gain_Loss_Code) then
        Errors[ruleGainLossCodesMustBeValid] := true;
    end;

    // Currency does not exist?
    if not CurrencyExists(BankAccount.baFields.baCurrency_Code) then
      Errors[ruleCurrenciesMustBeSetup] := true;

    // Opening balance not set?
    if (BankAccount.baFields.baCurrent_Balance = UNKNOWN) then
      Errors[ruleOpeningBalanceMustBeSet] := true;
  end;

  // Determine the combined error message
  for iRule := Low(TValidationRule) to High(TValidationRule) do
  begin
    // Not an error?
    if not Errors[iRule] then
      continue;

    AddError(RULE_ERRORS[iRule]);

    // Don't report any more errors if there are no transactions
    if (iRule = ruleForeignTransactionsMustExist) then
      break;
  end;

  // Determine the end result
  aErrors := fErrors.Text;
  result := (fErrors.Count = 0);
end;


{ ------------------------------------------------------------------------------
  TMonthEnding record helpers (calculated fields)
------------------------------------------------------------------------------ }
function TMonthEnding.RegisterBankAccount(const aBankAccount: TBank_Account): PMonthEndingBankAccount;
var
  i: integer;
  iCount: integer;
begin
  ASSERT(assigned(aBankAccount));

  // Already there?
  for i := 0 to High(BankAccounts) do
  begin
    if (BankAccounts[i].BankAccount = aBankAccount) then
    begin
      result := @BankAccounts[i];
      exit;
    end;
  end;

  // Add
  iCount := Length(BankAccounts);
  SetLength(BankAccounts, iCount+1);
  BankAccounts[iCount].BankAccount := aBankAccount;

  result := @BankAccounts[iCount];
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetDateAsStDate: TStDate;
begin
  result := DateTimeToStDate(Date);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetYear: integer;
begin
  result := YearOf(Date);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetMonth: integer;
begin
  result := MonthOf(Date);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetFinalised: boolean;
begin
  // All transactions need to be locked
  result := (NrTransactions <> 0) and (NrTransactions = NrLocked);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetTransferred: boolean;
begin
  // ALL transactions need to be transferred
  result := (NrTransactions <> 0) and (NrTransactions = NrTransferred);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetAlreadyRun: boolean;
begin
  // ALL bank accounts must be run
  result := (NrAlreadyRun <> 0) and (NrAlreadyRun = Length(BankAccounts));
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetCanCalculateGainLoss: boolean;
begin
  result := (NrTransactions <> 0) and not Finalised and not Transferred;
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetMonthEndingDate: TDateTime;
var
  iDay: integer;
begin
  iDay := DateUtils.DaysInMonth(Date);
  result := SysUtils.EncodeDate(Year, Month, iDay);
end;

{------------------------------------------------------------------------------}
function TMonthEnding.GetMonthEndingDateAsStDate: TStDate;
begin
  result := DateTimeToStDate(MonthEndingDate);
end;

{------------------------------------------------------------------------------}
procedure TMonthEnding.DetermineMonthStartEnd(var aStart: TStDate; var aEnd: TStDate);
begin
  aStart := DateTimeToStDate(Date);

  aEnd := DateTimeToStdate(MonthEndingDate);
end;


{ ------------------------------------------------------------------------------
  TPostedEntry
------------------------------------------------------------------------------ }
function TPostedEntry.GetPosted: boolean;
begin
  result := (Date > 0);
end;

{------------------------------------------------------------------------------}
function TPostedEntry.GetGainLossCurrency: string;
var
  mAbsGainLoss: Money;
  sCurrency: string;
begin
  // We're using CR/DR so don't display the sign
  mAbsGainLoss := Abs(GainLoss);
  sCurrency := GetCountryCurrency;
  result := MoneyStr(mAbsGainLoss, sCurrency);
end;

{------------------------------------------------------------------------------}
function TPostedEntry.GetGainLossCrDr: string;
begin
  if (GainLoss >= 0) then
    result := 'CR'
  else
    result := 'DR';
end;


{ ------------------------------------------------------------------------------
  TMonthEndings
------------------------------------------------------------------------------ }
function TMonthEndingBankAccount.GetAccountNameCurrency: string;
begin
  result := BankAccount.baFields.baBank_Account_Name + ' (' + BankAccount.baFields.baCurrency_Code + ')';
end;

{------------------------------------------------------------------------------}
function TMonthEndingBankAccount.GetGainLossCurrency: string;
var
  mAbsGainLoss: Money;
  sCurrency: string;
begin
  // We're using CR/DR so don't display the sign
  mAbsGainLoss := Abs(GainLoss);
  sCurrency := GetCountryCurrency;
  result := MoneyStr(mAbsGainLoss, sCurrency);
end;

{------------------------------------------------------------------------------}
function TMonthEndingBankAccount.GetGainLossCrDr: string;
begin
  if (GainLoss >= 0) then
    result := 'CR'
  else
    result := 'DR';
end;


{ ------------------------------------------------------------------------------
  TMonthEndings
------------------------------------------------------------------------------ }
constructor TMonthEndings.Create(const aClient: TClientObj);
begin
  inherited Create; // FIRST

  ASSERT(assigned(aClient));

  fClient := aClient;
end;

{------------------------------------------------------------------------------}
destructor TMonthEndings.Destroy;
begin
  FreeAndNil(fExchangeSource);

  // Do not free fClient

  inherited; // LAST
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.AddError(const aError: string; var aErrors: string);
begin
  if (aErrors <> '') then
    aErrors := aErrors + sLineBreak + sLineBreak;
  aErrors := aErrors + aError;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.SplitYearMonth(const aDate: TDateTime; var aYear: integer;
  var aMonth: integer);
begin
  aYear := YearOf(aDate);
  aMonth := MonthOf(aDate);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.SplitYearMonth(const aDate: TStDate; var aYear: integer;
  var aMonth: integer);
var
  dtDate: TDateTime;
begin
  dtDate := StDateToDateTime(aDate);
  SplitYearMonth(dtDate, aYear, aMonth);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.IncreaseYearMonth(var aYear: integer; var aMonth: integer);
begin
  Inc(aMonth);
  if (aMonth > 12) then
  begin
    Inc(aYear);
    aMonth := 1;
  end;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.GetIsoIndex(const aCurrencyCode: string): integer;
begin
  result := fExchangeSource.GetISOIndex(aCurrencyCode, fExchangeSource.Header);
end;

{------------------------------------------------------------------------------}
function TMonthEndings.HasExchangeRate(const aDate: TStDate;
  const aIsoIndex: integer): boolean;
var
  Rate: TExchangeRecord;
  RateAmount: double; // Exchange Rates are doubles
begin
  result := false;

  // Now data for this currency?
  Rate := fExchangeSource.GetDateRates(aDate);
  if not Assigned(Rate) then
    exit;

  // No amount?
  RateAmount := Rate.Rates[aIsoIndex];
  if (RateAmount = 0) then
    exit;

  result := true;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.ApplyExchangeRateForexToBase(const aDate: TStDate;
  const aIsoIndex: integer; const aValue: Money): Money;
var
  Rate: TExchangeRecord;
  RateAmount: double; // Exchange Rates are doubles
begin
  // Exchange rate missing?
  Rate := fExchangeSource.GetDateRates(aDate);
  ASSERT(Assigned(Rate), 'Exchange Rate for '+Date2Str(aDate, 'dd/mm/yy')+' not found');

  // This is a double
  RateAmount := Rate.Rates[aIsoIndex];
  ASSERT(RateAmount <> 0);

  result := Round(aValue / RateAmount);
end;

{------------------------------------------------------------------------------}
function TMonthEndings.GetFirstLastEffective(var aFirstEffective: TDateTime;
  var aLastEffective: TDateTime): boolean;
var
  stFirstEffective: TStDate;
  stLastEffective: TStDate;
  i: integer;
  BankAccount: TBank_Account;
begin
  stFirstEffective := MaxDate;
  stLastEffective := MinDate;

  // Determine the month range for all non-base accounts
  for i := 0 to fClient.clBank_Account_List.ItemCount-1 do
  begin
    // Not foreign account?
    BankAccount := fClient.clBank_Account_List.Bank_Account_At(i);
    if not IsForeignCurrencyAccount(BankAccount) then
      continue;

    { No transactions?
      Note: if there are no transactions, then FirstEffectiveDate and
      LastEffectiveDate will be 0. Min will therefore wipe the previous
      EffectiveDate, so we must check for this here.
    }
    if (BankAccount.baTransaction_List.ItemCount = 0) then
      continue;

    // Find lowest First Effective
    ASSERT(BankAccount.baTransaction_List.FirstEffectiveDate <> 0);
    stFirstEffective := Min(stFirstEffective, BankAccount.baTransaction_List.FirstEffectiveDate);

    // Find highest Last Effective
    ASSERT(BankAccount.baTransaction_List.LastEffectiveDate <> 0);
    stLastEffective := Max(stLastEffective, BankAccount.baTransaction_List.LastEffectiveDate);
  end;

  // Valid range?
  result := (stFirstEffective <> MinDate) and (stFirstEffective <> MaxDate) and
            (stLastEffective <> MinDate) and (stLastEffective <> MaxDate);

  // No range?
  if not result then
    exit;

  // Convert to TDateTime
  aFirstEffective := StDateToDateTime(stFirstEffective);
  aLastEffective := StDateToDateTime(stLastEffective);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CreateMonthRange(const aFirstEffective: TDateTime;
  const aLastEffective: TDateTime);
var
  iFirstYear: integer;
  iFirstMonth: integer;
  iLastYear: integer;
  iLastMonth: integer;
  iCount: integer;
begin
  SplitYearMonth(aFirstEffective, iFirstYear, iFirstMonth);
  SplitYearMonth(aLastEffective, iLastYear, iLastMonth);

  while true do
  begin
    // Create new entry
    iCount := Length(fMonthEndings);
    SetLength(fMonthEndings, iCount+1);
    with fMonthEndings[iCount] do
    begin
      Date := EncodeDate(iFirstYear, iFirstMonth, 1);
    end;

    // Do this before increasing the month component
    if (iFirstYear = iLastYear) and (iFirstMonth = iLastMonth) then
      break;

    // Do this last
    IncreaseYearMonth(iFirstYear, iFirstMonth);
  end;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.FindMonthEnding(const aDate: TStDate; var aIndex: integer): boolean;
var
  dtDate: TDateTime;
  iYear: integer;
  iMonth: integer;
  i: integer;
begin
  ASSERT((aDate <> MinDate) and (aDate <> MaxDate));

  dtDate := StDateToDateTime(aDate);
  iYear := YearOf(dtDate);
  iMonth := MonthOf(dtDate);

  for i := 0 to High(fMonthEndings) do
  begin
    with fMonthEndings[i] do
    begin
      if (Year = iYear) and (Month = iMonth) then
      begin
        aIndex := i;
        result := true;
        exit;
      end;
    end;
  end;

  result := false;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.FindMonthEnding(const aDate: TStDate): PMonthEnding;
var
  iIndex: integer;
begin
  if FindMonthEnding(aDate, iIndex) then
    result := @fMonthEndings[iIndex]
  else
    result := nil;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.SetMonthEnding(const aBankAccount: TBank_Account);
var
  iIsoIndex: integer;
  i: integer;
  pTransaction: pTransaction_Rec;
  pMonth: PMonthEnding;
  pBankAccount: PMonthEndingBankAccount;
begin
  ASSERT(assigned(aBankAccount));
  ASSERT(IsForeignCurrencyAccount(aBankAccount));

  // Cache this before we check all transactions
  iIsoIndex := GetIsoIndex(aBankAccount.baFields.baCurrency_Code);

  for i := 0 to aBankAccount.baTransaction_List.ItemCount-1 do
  begin
    pTransaction := aBankAccount.baTransaction_List[i];

    // Find month for it
    pMonth := FindMonthEnding(pTransaction.txDate_Effective);
    ASSERT(assigned(pMonth));

    { Keep track of what bank accounts we're using in this month
      Note: call this before storing the PostedEntry }
    pBankAccount := pMonth.RegisterBankAccount(aBankAccount);
    ASSERT(assigned(pBankAccount));

    // Gain/Loss record?
    if IsGainLossTransaction(pTransaction) then
    begin
      Inc(pMonth.NrAlreadyRun);

      pBankAccount.PostedEntry.GainLoss := pTransaction.txAmount;
      pBankAccount.PostedEntry.Date := GetGainLossPostedDate(pTransaction);

      // Ignore this record completely for our calculations
      continue;
    end;

    // Transactions
    Inc(pMonth.NrTransactions);

    // Locked
    if pTransaction.txLocked then
      Inc(pMonth.NrLocked);

    // Transferred
    if (pTransaction.txDate_Transferred <> 0) then
      Inc(pMonth.NrTransferred);

    // Exchange rate missing?
    if not HasExchangeRate(pTransaction.txDate_Effective, iIsoIndex) then
      pMonth.ExchangeRateMissing := true;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.SetAvailableData(const aFrom: TStDate; const aTo: TStDate);
var
  iFromYear: integer;
  iFromMonth: integer;
  iToYear: integer;
  iToMonth: integer;
  dtDate: TStDate;
  pMonth: PMonthEnding;
begin
  SplitYearMonth(aFrom, iFromYear, iFromMonth);
  SplitYearMonth(aTo, iToYear, iToMonth);

  while true do
  begin
    // Do we have this year/month combo?
    dtDate := DMYtoStDate(1, iFromMonth, iFromYear, BKDATEEPOCH);
    pMonth := FindMonthEnding(dtDate);
    if Assigned(pMonth) then
      pMonth.AvailableData := true;

    // Do this before increasing the month component
    if (iFromYear = iToYear) and (iFromMonth = iToMonth) then
      break;

    // Do this last
    IncreaseYearMonth(iFromYear, iFromMonth);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.SetMonthEnding;
var
  i: integer;
  BankAccount: TBank_Account;
  pSystemBankAccount: pSystem_Bank_Account_Rec;
begin
  for i := 0 to fClient.clBank_Account_List.ItemCount-1 do
  begin
    // Not Gain/Loss?
    BankAccount := fClient.clBank_Account_List.Bank_Account_At(i);
    if not IsForeignCurrencyAccount(BankAccount) then
      continue;

    // Split the transactions up according to what month they're in
    SetMonthEnding(BankAccount);

    // No system bank account available?
    if not Assigned(AdminSystem) then
      continue;
    if (BankAccount.baFields.baAccount_Type = sbtOnlineSecure) then
      continue;
    if BankAccount.IsManual then
      continue;

    // No match?
    pSystemBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(BankAccount.baFields.baBank_Account_Number);
    if not Assigned(pSystemBankAccount) then
      continue;

    // No new transactions?
    if (pSystemBankAccount.sbLast_Transaction_LRN <= BankAccount.baFields.baHighest_LRN) then
      continue;

    // Mark the relevant month as "Data Available"
    SetAvailableData(pSystemBankAccount.sbFrom_Date_This_Month,
      pSystemBankAccount.sbTo_Date_This_Month);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.DeleteFirstMonth;
var
  i: integer;
  iCount: integer;
begin
  // Move months back one
  for i := 1 to High(fMonthEndings) do
  begin
    fMonthEndings[i-1] := fMonthEndings[i];
  end;

  // Reduce overall size
  iCount := Length(fMonthEndings);
  SetLength(fMonthEndings, iCount-1);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CullFirstMonths;
begin
  // Don't cull?
  if not (meoCullFirstMonths in fOptions) then
    exit;

  while (Length(fMonthEndings) <> 0) do
  begin
    with fMonthEndings[0] do
    begin
      { Can we safely get rid of this month?
        Note: we must also check for empty months, because of situations like
        FFENN (F=Finalised, E=Empty, N=Normal) which should result in NN, and
        not in ENN.
      }
      if (NrTransactions = 0) or Finalised or Transferred then
        DeleteFirstMonth
      else
        break;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.VerifyExchangeRatePreviousMonth;
var
  iMonth: integer;
  pMonth: ^TMonthEnding;
  dtDate: TDateTime;
  stDate: TStDate;
  iBankAccount: integer;
  BankAccount: TBank_Account;
  iIsoIndex: integer;
begin
  for iMonth := 0 to Count-1 do
  begin
    pMonth := @fMonthEndings[iMonth];

    { Date is already in the format of (1/<Month>/<Year>), so decrease is enough
      to get the last day of the previous month }
    dtDate := IncDay(pMonth.Date, -1);
    stDate := DateTimeToStDate(dtDate);

    // Examine all bank accounts
    for iBankAccount := 0 to High(pMonth.BankAccounts) do
    begin
      BankAccount := pMonth.BankAccounts[iBankAccount].BankAccount;
      ASSERT(Assigned(BankAccount));

      // Check we have an exchange rate in the last day of the previous month
      iIsoIndex := GetIsoIndex(BankAccount.baFields.baCurrency_Code);
      if not HasExchangeRate(stDate, iIsoIndex) then
        pMonth.ExchangeRateMissingLastDayOfPreviousMonth := true;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.GetOpeningClosingBalance(const aStart: TStDate;
  const aEnd: TStDate; const aBankAccount: TBank_Account; var aOpening: Money;
  var aClosing: Money);
var
  SystemOpBal: Money; // Dummy
  SystemClBal: Money; // Dummy
begin
  GainLossGetBalances(aBankAccount, aStart, aEnd, aOpening, aClosing, SystemOpBal, SystemClBal);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CalculateGainLoss(var aBankAccount: TMonthEndingBankAccount;
  const aStart: TStDate; const aEnd: TStDate);
var
  // See spec
  OB   : Money; // Opening Balance
  COB  : Money; // Converted Opening Balance
  CB   : Money; // Closing Balance
  CCB  : Money; // Converted Closing Balance
  SUM  : Money;
  CSUM : Money; // Converted sum of all transactions

  BankAccount: TBank_Account;
  Transactions: TTransaction_List;
  iIsoIndex: integer;
  dtLastDayOfPreviousMonth: TStDate;
  i: integer;
  Transaction: pTransaction_Rec;
  dtEffective: TStDate;
  mConvertedAmount: Money;
begin
  BankAccount := aBankAccount.BankAccount;
  ASSERT(Assigned(BankACcount));
  Transactions := BankAccount.baTransaction_List;
  ASSERT(assigned(Transactions));

  // Determine currency column for later calculations (ApplyExchangeRate)
  iIsoIndex := GetIsoIndex(BankAccount.baFields.baCurrency_Code);

  // Get Opening/Closing Balance
  GetOpeningClosingBalance(aStart, aEnd, BankAccount, OB, CB);

  // Use last day of previous month for the opening balance exchange rate
  dtLastDayOfPreviousMonth := IncDate(aStart, -1, 0, 0);
  COB := ApplyExchangeRateForexToBase(dtLastDayOfPreviousMonth, iIsoIndex, OB);

  // Use last day of the current month for closing balance exchange rate
  CCB := ApplyExchangeRateForexToBase(aEnd, iIsoIndex, CB);

  // Closing Balance and Sum for transactions
  SUM := 0;
  CSUM := 0;
  for i := 0 to Transactions.ItemCount-1 do
  begin
    Transaction := Transactions[i];
    ASSERT(Assigned(Transaction));

    // Not within range?
    dtEffective := Transaction.txDate_Effective;
    if not ((aStart <= dtEffective) and (dtEffective <= aEnd)) then
      continue;

    // Exclude gain/loss transactions from this calculation (very important)
    if IsGainLossTransaction(Transaction) then
      continue;

    // SUM
    SUM := SUM + Transaction.txAmount;

    // CSUM
    mConvertedAmount := ApplyExchangeRateForexToBase(dtEffective, iIsoIndex, Transaction.txAmount);
    CSUM := CSUM + mConvertedAmount;
  end;

  // Exchange Gain/Loss
  aBankAccount.GainLoss := CCB - COB - CSUM;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CalculateGainLoss(var aMonth: TMonthEnding);
var
  i: integer;
  dtStart: TStDate;
  dtEnd: TStDate;
begin
  for i := 0 to High(aMonth.BankAccounts) do
  begin
    // Not able to calculate the Gain/Loss?
    if not aMonth.CanCalculateGainLoss then
      continue;

    // If there are errors in the exchange rates, don't calculate the gain/loss
    if aMonth.ExchangeRateMissing or aMonth.ExchangeRateMissingLastDayOfPreviousMonth then
      continue;

    aMonth.DetermineMonthStartEnd(dtStart, dtEnd);
    CalculateGainLoss(aMonth.BankAccounts[i], dtStart, dtEnd);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CalculateGainLoss;
var
  i: integer;
begin
  for i := 0 to High(fMonthEndings) do
  begin
    CalculateGainLoss(fMonthEndings[i]);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.DeletePreviousGainLossEntry(const aMonth: PMonthEnding;
  const aTransactions: TTransaction_List);
var
  i: integer;
  pTransaction: pTransaction_Rec;
begin
  for i := aTransactions.ItemCount-1 downto 0 do
  begin
    pTransaction := aTransactions[i];

    // Only delete gain/loss transactions
    if not IsGainLossTransaction(pTransaction) then
      continue;

    if (pTransaction.txDate_Effective <> aMonth.MonthEndingDateAsStdate) then
      continue;

    aTransactions.Delete(pTransaction);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.PostGainLossEntry(const aMonth: PMonthEnding;
  const aBankAccount: TMonthEndingBankAccount);
var
  BankAccount: TBank_Account;
  Transactions: TTransaction_List;
  pTransaction: pTransaction_Rec;
  Dummy1: integer;
  Dummy2: TStDate;
  Dummy3: TStDate;
  sLog: string;
begin
  BankAccount := aBankAccount.BankAccount;

  // Delete previous entry
  DeletePreviousGainLossEntry(aMonth, BankAccount.baTransaction_List);

  // Add new transaction
  Transactions := TTransaction_List.Create(fClient, BankAccount, fClient.ClientAuditMgr);
  try
    // New transaction (FillChar with basic fields set)
    pTransaction := Transactions.New_Transaction;
    ASSERT(assigned(pTransaction));

    // Assign default values
    with pTransaction^ do
    begin
      txSource := orExchangeGainLoss; // New source type
      txDate_Presented := aMonth.MonthEndingDateAsStdate; // Last day of the month
      txDate_Effective := aMonth.MonthEndingDateAsStdate; // Last day of the month
      txAmount := aBankAccount.GainLoss;
      txReference := TRANSACTION_REFERENCE;
      txOld_Narration := TRANSACTION_DESCRIPTION;
      txAccount := BankAccount.baFields.baExchange_Gain_Loss_Code;
      txCoded_By := cbManual;
      txLocked := true;
      txOriginal_Reference := txReference;
      txOriginal_Source := txSource;
      txOriginal_Amount := txAmount;
      txGL_Narration := TRANSACTION_DESCRIPTION;
      SetGainLossPostedDate(pTransaction, CurrentDate); // txLRN_NOW_UNUSED
    end;

    // Insert into Transactions list
    Transactions.Insert_Transaction_Rec(pTransaction);

    // Insert the Transactions into the Bank Account
    InsTranListToBankAcct(fClient, BankAccount, Transactions, {AutoCode=}false,
      Dummy1, Dummy2, Dummy3);

    // Log?
    sLog := Format(
      'Exchange Gain/Loss Entry created for %s/%s (%s), %s %s',
      [
      BankAccount.baFields.baBank_Account_Number,
      BankAccount.baFields.baBank_Account_Name,
      BankAccount.baFields.baExchange_Gain_Loss_Code,
      aBankAccount.GetGainLossCurrency,
      aBankAccount.GainLossCrDr
      ]);
    LogMsg(lmInfo, UnitName, sLog);

    // Note: Audits are done automatically when new transactions are inserted
    
  finally
    FreeAndNil(Transactions);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.Refresh;
var
  dtFirstEffective: TDateTime;
  dtLastEffective: TDateTime;
begin
  // Clear previous months
  SetLength(fMonthEndings, 0);

  // Refresh the exchange rates
  FreeAndNil(fExchangeSource);
  fExchangeSource := CreateExchangeSource;

  // Nothing?
  if not GetFirstLastEffective(dtFirstEffective, dtLastEffective) then
    exit;

  // Create month range based on the first/last Effective dates
  CreateMonthRange(dtFirstEffective, dtLastEffective);

  // Update the month status (Locked, Transferred, Already Run, Exchange)
  SetMonthEnding;

  // Remove the first months that have already been run
  CullFirstMonths;

  // Verify if there's an exchange rate on the last day of the previous month
  VerifyExchangeRatePreviousMonth;

  { Calculate ALL Gain/Loss amounts
    Note: we may later need to replace this with an "on-demand" system, where
    calculations only occur as required. }
  CalculateGainLoss;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.GetCount: integer;
begin
  result := Length(fMonthEndings);
end;

{------------------------------------------------------------------------------}
function TMonthEndings.GetItem(const aIndex: integer): TMonthEnding;
begin
  result := fMonthEndings[aIndex];
end;

{------------------------------------------------------------------------------}
function TMonthEndings.ValidateMonthEnding(const aMonthIndex: integer;
  var aErrors: string): boolean;
begin
  aErrors := '';

  // Validation - one error message at the time
  with fMonthEndings[aMonthIndex] do
  begin
    if Finalised or Transferred then
      AddError(ERR_FINALISED_OR_TRANSFERRED, aErrors)
    else if AvailableData then
      AddError(ERR_AVAILABLE_DATA, aErrors)
    else if ExchangeRateMissing then
      AddError(ERR_MISSING_EXCHANGE_RATE, aErrors)
    else if ExchangeRateMissingLastDayOfPreviousMonth then
      AddError(ERR_MISSING_EXCHANGE_RATE_PREVIOUS_MONTH, aErrors);
  end;

  result := (aErrors = '');
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.PostGainLossEntries(const aMonthIndex: integer);
var
  pMonth: PMonthEnding;
  i: integer;
begin
  pMonth := @fMonthEndings[aMonthIndex];

  for i := 0 to High(pMonth.BankAccounts) do
  begin
    PostGainLossEntry(pMonth, pMonth.BankAccounts[i]);
  end;
end;

{------------------------------------------------------------------------------}
function IsGainLossTransaction(const aTransaction: pTransaction_Rec): boolean;
begin
  result := (aTransaction.txSource = orExchangeGainLoss);
end;

{------------------------------------------------------------------------------}
function GetGainLossPostedDate(const aTransaction: pTransaction_Rec): TStDate;
begin
  result := aTransaction.txLRN_NOW_UNUSED;
end;

{------------------------------------------------------------------------------}
procedure SetGainLossPostedDate(const aTransaction: pTransaction_Rec;
  const aValue: TStDate);
begin
  aTransaction.txLRN_NOW_UNUSED := aValue;
end;

{------------------------------------------------------------------------------}
Procedure GainLossGetBalances( b: TBank_Account; d1, d2: tStDate; Var BankOpBal,
   BankClBal, SystemOpBal, SystemClBal: money);
Var
   E           : Integer;
   Transaction : pTransaction_Rec;
   Amount      : Money;
Begin { GetBalances }
   With b Do
   Begin
      BankOpBal := bafields.baCurrent_Balance;
      BankClBal := bafields.baCurrent_Balance;
      SystemOpBal := bafields.baCurrent_Balance;
      SystemClBal := bafields.baCurrent_Balance;

      If bafields.baCurrent_Balance = Unknown Then
      Begin
        exit
      End { bafields.baCurrent_Balance = Unknown };


      With baTransaction_List Do
      Begin
         For E := 0 to Pred(ItemCount) Do
         Begin
            Transaction := Transaction_At(E);
            With Transaction^ Do
            Begin

               // Completely ignore posted gain/loss transactions for our month
               if IsGainLossTransaction(Transaction) and (txDate_Effective = d2) then
                  continue;

               Amount := txAmount;

               If txDate_Presented <> 0 Then
               Begin
                  Case bkDateUtils.CompareDates(txDate_Presented, d1, d2) Of
                     Earlier:;
                     Within:
                     Begin
                        BankOpBal := BankOpBal - Amount;
                     End;
                     Later:
                     Begin
                        BankOpBal := BankOpBal - Amount;
                        BankClBal := BankClBal - Amount;
                     End;
                  End;

                  Case bkDateUtils.CompareDates(txDate_Effective, d1, d2) Of
                     Earlier:;
                     Within:
                     Begin
                        SystemOpBal := SystemOpBal - Amount;
                     End;
                     Later:
                     Begin
                        SystemOpBal := SystemOpBal - Amount;
                        SystemClBal := SystemClBal - Amount;
                     End;
                  End
               End { txDate_Presented <> 0 }
               Else
               Begin { Unpresented }
                  Case bkDateUtils.CompareDates(txDate_Effective, d1, d2) Of
                     Earlier:
                     Begin
                        SystemOpBal := SystemOpBal + Amount;
                        SystemClBal := SystemClBal + Amount;
                     End;
                     Within:
                     Begin
                        SystemClBal := SystemClBal + Amount
                     End;
                     Later:;
                     End
               End { not (txDate_Presented <> 0) };
            End { with Transaction_At(E)^ }
         End { for E }
      End { with baTransaction_List };
   End { with b };
End; { GetBalances }


{------------------------------------------------------------------------------}
initialization
   DebugMe := DebugUnit(UnitName);


end.
