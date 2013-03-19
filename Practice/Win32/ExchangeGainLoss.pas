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
  LogUtil,
  glObj32,
  frObj32;

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
    FExchangeGainLossCode: String;

    procedure SetExchangeGainLossCode(const Value: String);
  public
    // Whether anything was posted for this month
    function  GetValid: boolean;
    property  Valid: boolean read GetValid;

    // Gain/Loss with currency symbol of the practice, NOT the bank account
    function  GetGainLossCurrency: string;
    property  GainLossCurrency: string read GetGainLossCurrency;
    // CR/DR
    function  GetGainLossCrDr: string;
    property  GainLossCrDr: string read GetGainLossCrDr;

    property ExchangeGainLossCode: String read FExchangeGainLossCode write SetExchangeGainLossCode; 
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
    ExchangeRateMissingLastDayOfCurrentMonth: boolean;
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
    function  GetCanBeFirstMonth: boolean;
    property  CanBeFirstMonth: boolean read GetCanBeFirstMonth;
    function  HasMissingExchangeRates: boolean;
  end;

  TMonthEndingArray = array of TMonthEnding;


  { ----------------------------------------------------------------------------
    TMonthEndingOption
  ---------------------------------------------------------------------------- }
  TMonthEndingOption = (
    // Prevent culling of first months - necessary for client home screen
    meoCullMonths,
    // Calculate gain/loss during Refresh
    meoCalculateGainLoss
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

    // Exchange helpers
    function  GetIsoIndex(const aCurrencyCode: string): integer;
    function  HasExchangeRate(const aDate: TStDate; const aIsoIndex: integer): boolean;

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
    procedure CullCurrentMonth;
    procedure VerifyExchangeRateOpeningClosing;
    // Calculate Gain/Loss
    procedure CalculateGainLoss(var aBankAccount: TMonthEndingBankAccount;
                const aStart: TStDate; const aEnd: TStDate); overload;
    procedure CalculateGainLoss(var aMonth: TMonthEnding); overload;
    procedure CalculateGainLoss; overload;
    // Post entries
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

    function  DetermineFirstMonth: integer;

    function  ValidateMonthEnding(const aMonthIndex: integer;
                var aErrors: string): boolean;

    procedure PostGainLossEntries(const aMonthIndex: integer);

    function FindBankAccountEntry(BankAccount: TBank_Account; aDate: Integer): PMonthEndingBankAccount;
  end;


  TMonthEndingsClass = class of TMonthEndings;


  { ----------------------------------------------------------------------------
    TCalculateGainLoss

    Throws exceptions
  ---------------------------------------------------------------------------- }
  TCalculateGainLoss = class(TObject)
  private
    fExchangeSourceOwner: boolean;
    fExchangeSource: TExchangeSource;

  public
    // Constructors
    constructor Create(const aSource: TExchangeSource = nil);
    destructor  Destroy; override;

    // Main entry point
    procedure Calculate(const aBankAccount: TBank_Account;
                const aYearMonth: TStDate; var aGainLoss: Money); overload;
                
    procedure Calculate(const aBankAccount: TBank_Account;
                const aStart: TStDate; const aEnd: TStDate; var aGainLoss: Money
                ); overload;
  private
    function  GetIsoIndex(const aCurrencyCode: string): integer;

    function  ApplyExchangeRateForeignToBase(const aDate: TStDate; const aIsoIndex: integer;
                const aValue: Money): Money;
  end;


  // Declared here, because it can't be added to Components\SysTools\StDate.pas
  TStDateDynArray = array of TStDate;


  { ----------------------------------------------------------------------------
    ITransactionSnapshot
  ---------------------------------------------------------------------------- }
  ITransactionSnapshot = interface(IUnknown)
  ['{E6F0F00E-051D-4336-B850-659D1DC3EB67}']
    function  HasChanges: boolean; overload;
    function  HasChanges(const aBankAccount: TBank_Account;
                var aMonths: TStDateDynArray): boolean; overload;
  end;


  { ----------------------------------------------------------------------------
    TTransactionSnapshot
  ---------------------------------------------------------------------------- }
  TTransactionSnapshot = class(TInterfacedObject, ITransactionSnapshot)
  private
    fClient: TClientObj;

  public
    // Constructors
    constructor Create(const aClient: TClientObj);
    destructor  Destroy; override;

    // ITransactionSnapshot
    function  HasChanges: boolean; overload;
    function  HasChanges(const aBankAccount: TBank_Account;
                var aMonths: TStDateDynArray): boolean; overload;

  private
    procedure Tag(const aValue: integer);
    procedure Add(const aValue: TStDate; var aMonths: TStDateDynArray);

  end;

  TPeriodLockState = (psFullyLocked, psNotFullyLocked, psUnknown);

  { ----------------------------------------------------------------------------
    Helper functions
  ---------------------------------------------------------------------------- }
  procedure SplitYearMonth(const aDate: TDateTime; var aYear: integer; var aMonth: integer); overload;
  procedure SplitYearMonth(const aDate: TStDate; var aYear: integer; var aMonth: integer); overload;
  procedure IncreaseYearMonth(var aYear: integer; var aMonth: integer);

  function  GetLocalCurrencyAmount(const aValue: Money): string;
  function  GetCrDr(const aValue: Money): string;

  procedure GetOpeningClosingBalance(const aStart: TStDate; const aEnd: TStDate;
              const aBankAccount: TBank_Account; var aOpening: Money;
              var aClosing: Money);

  function  ValidateExchangeGainLoss(const aClient: TClientObj;
              var aErrors: string): boolean;

  function  CalculateGainLoss(const aBankAccount: TBank_Account;
              const aYearMonth: TStDate; var aGainLoss: Money;
              var aError: string): boolean;

  // Automatically post gain/loss entries ('Silent Wizard')
  function  PostGainLossEntries(const aClient: TClientObj;
              const aFrom: TStDate; const aTo: TStDate): boolean;

  // Compare the posted entry with the most recent calculated entry
  function  HasInvalidGainLossEntries(const aClient: TClientObj): boolean; overload;
  function  HasInvalidGainLossEntries(const aBankAccount: TBank_Account): boolean; overload;

  // Transaction Snapshot
  function  CreateTransactionSnapshot(const aClient: TClientObj): ITransactionSnapshot;
  function  HasGainLossEntriesIn(const aClient: TClientObj; const aSnapshot: ITransactionSnapshot): boolean;

  // Validation of exchange rates in transactions
  function  ValidateTransactionExchangeRates(const aClient: TClientObj): boolean;


  function GetLastDayExchangeRate(BankAccount: TBank_Account; ISOIndex: Integer; ExchangeSource: TExchangeSource; LastDayOfPeriod: TStDate; PartialPeriod: Boolean; PeriodLockState: TPeriodLockState): Double; overload;
  function GetLastDayExchangeRate(BankAccount: TBank_Account; LastDayOfPeriod: TStDate; PartialPeriod: Boolean; PeriodLockState: TPeriodLockState): Double; overload;
  function GetLastDayExchangeRate(BankAccount: TBank_Account; LastDayOfPeriod: TStDate; PeriodLockState: TPeriodLockState): Double; overload;

  function IsPartialPeriod(ToDate: TStDate): Boolean;

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

  ERR_MISSING_EXCHANGE_RATE_CURRENT_MONTH =
    'Please select a Month Ending to calculate the Exchange Gains and/or Losses that has all exchange rates available for the last day of the current month.';
    
  ERR_MISSING_EXCHANGE_RATE_PREVIOUS_MONTH =
    'Please select a Month Ending to calculate the Exchange Gains and/or Losses that has all exchange rates available for the last day of the previous month.';


// Debug
const
   UnitName = 'ExchangeGainLoss';
var
   DebugMe: boolean = false;


{-------------------------------------------------------------------------------
  YearMonth helpers
-------------------------------------------------------------------------------}
procedure SplitYearMonth(const aDate: TDateTime; var aYear: integer;
  var aMonth: integer);
begin
  aYear := YearOf(aDate);
  aMonth := MonthOf(aDate);
end;

{------------------------------------------------------------------------------}
procedure SplitYearMonth(const aDate: TStDate; var aYear: integer;
  var aMonth: integer);
var
  dtDate: TDateTime;
begin
  dtDate := StDateToDateTime(aDate);
  SplitYearMonth(dtDate, aYear, aMonth);
end;

{------------------------------------------------------------------------------}
procedure IncreaseYearMonth(var aYear: integer; var aMonth: integer);
begin
  Inc(aMonth);
  if (aMonth > 12) then
  begin
    Inc(aYear);
    aMonth := 1;
  end;
end;


{-------------------------------------------------------------------------------
  Amount helpers
-------------------------------------------------------------------------------}
function GetLocalCurrencyAmount(const aValue: Money): string;
var
  mAbsGainLoss: Money;
  sCurrency: string;
begin
  // We're using CR/DR so don't display the sign
  mAbsGainLoss := Abs(aValue);
  sCurrency := GetCountryCurrency;
  result := MoneyStr(mAbsGainLoss, sCurrency);
end;

{------------------------------------------------------------------------------}
function GetCrDr(const aValue: Money): string;
begin
  if (aValue <= 0) then
    result := 'CR'
  else
    result := 'DR';
end;


{-------------------------------------------------------------------------------
  GetOpeningClosingBalance
-------------------------------------------------------------------------------}
procedure GetOpeningClosingBalance(const aStart: TStDate; const aEnd: TStDate;
  const aBankAccount: TBank_Account; var aOpening: Money; var aClosing: Money);
var
  SystemOpBal: Money; // Dummy
  SystemClBal: Money; // Dummy
begin
  baUtils.GetBalances(aBankAccount, aStart, aEnd, aOpening, aClosing, SystemOpBal, SystemClBal);
end;


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
  CalculateGainLoss
-------------------------------------------------------------------------------}
function CalculateGainLoss(const aBankAccount: TBank_Account;
  const aYearMonth: TStDate; var aGainLoss: Money; var aError: string): boolean;
var
  GainLoss: TCalculateGainLoss;
begin
  aGainLoss := 0;
  aError := '';

  GainLoss := TCalculateGainLoss.Create;
  try
    try
      GainLoss.Calculate(aBankAccount, aYearMonth, aGainLoss);
    except
      on E: Exception do
      begin
        aError := E.Message;
        result := false;
        exit;
      end;
    end;

    result := true;
  finally
    FreeAndNil(GainLoss);
  end;
end;


{-------------------------------------------------------------------------------
  PostGainLossEntries (Silent Wizard)
-------------------------------------------------------------------------------}
procedure PostGainLossEntry(const aBankAccount: TBank_Account;
  const aDate: TStDate; const aAmount: Money);
var
  sLog: string;
begin
  // Post entry with all relevant data from today
  with aBankAccount, baFields, baExchange_Gain_Loss_List do
  begin
    // Post Entry into Exchange Gain/Loss list
    PostEntry(aDate, aAmount, baExchange_Gain_Loss_Code);

    // Log?
    sLog := Format(
      'Exchange Gain/Loss Entry created for %s/%s (%s), %s %s',
      [
      baBank_Account_Number,
      baBank_Account_Name,
      baExchange_Gain_Loss_Code,
      GetLocalCurrencyAmount(aAmount),
      GetCrDr(aAmount)
      ]);
    LogMsg(lmInfo, UnitName, sLog);
  end;

  // Note: Audits are done automatically when new transactions are inserted
end;

{------------------------------------------------------------------------------}
function PostGainLossEntriesRange(const aBankAccount: TBank_Account;
  const aFrom: TStDate; const aTo: TStDate): boolean;
var
  dtMonth: TStDate;
  mGainLoss: Money;
  dtDate: TStDate;
  sError: string;
begin
  ASSERT(assigned(aBankAccount));
  ASSERT(IsForeignCurrencyAccount(aBankAccount));

  result := true;

  dtMonth := GetFirstDayOfMonth(aFrom);

  while true do
  begin
    // Post entry?
    if CalculateGainLoss(aBankAccount, dtMonth, mGainLoss, sError) then
    begin
      dtDate := GetLastDayOfMonth(dtMonth);
      PostGainLossEntry(aBankAccount, dtDate, mGainLoss);
    end
    else
      result := false;

    dtMonth := IncDate(dtMonth, 0, 1, 0);

    if (dtMonth > aTo) then
      break;
  end;
end;

{------------------------------------------------------------------------------}
function PostGainLossEntries(const aClient: TClientObj; const aFrom: TStDate;
  const aTo: TStDate): boolean;
var
  iBankAccount: integer;
  BankAccount: TBank_Account;
begin
  ASSERT(assigned(aClient));

  result := true;

  for iBankAccount := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    // Not foreign currency account?
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(iBankAccount);
    if not IsForeignCurrencyAccount(BankAccount) then
      continue;

    // Continue with other entries
    if not PostGainLossEntriesRange(BankAccount, aFrom, aTo) then
    begin
      result := false;
      continue;
    end;
  end;
end;


{-------------------------------------------------------------------------------
  HasInvalidGainLossEntries
------------------------------------------------------------------------------}
function HasInvalidGainLossEntries(const aClient: TClientObj): boolean;
var
  i: integer;
  BankAccount: TBank_Account;
begin
  ASSERT(assigned(aClient));

  result := false;

  // No entries?
  if not IsForeignCurrencyClient(aClient) then
    exit;

  // Examine all bank accounts
  for i := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(i);
    if not HasInvalidGainLossEntries(BankAccount) then
      continue;

    result := true;
    exit;
  end;
end;

{------------------------------------------------------------------------------}
function HasInvalidGainLossEntries(const aBankAccount: TBank_Account): boolean;
var
  i: integer;
  ExchangeGainLoss: TExchange_Gain_Loss;
  mGainLoss: Money;
  sError: string;
begin
  ASSERT(assigned(aBankAccount));

  result := false;

  // No entries?
  if not IsForeignCurrencyAccount(aBankAccount) then
    exit;

  // Examine all gain/loss entries
  for i := 0 to aBankAccount.baExchange_Gain_Loss_List.ItemCount-1 do
  begin
    ExchangeGainLoss := aBankAccount.baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(i);

    // Missing exchange rates?
    if not CalculateGainLoss(aBankAccount, ExchangeGainLoss.glFields.glDate, mGainLoss, sError) then
    begin
      result := true;
      exit;
    end;

    // Amount is different?
    if (ExchangeGainLoss.glFields.glAmount <> mGainLoss) then
    begin
      result := true;
      exit;
    end;
  end;
end;


{-------------------------------------------------------------------------------
  HasGainLossEntriesIn
-------------------------------------------------------------------------------}
function CreateTransactionSnapshot(const aClient: TClientObj): ITransactionSnapshot;
begin
  result := TTransactionSnapshot.Create(aClient);
end;


{-------------------------------------------------------------------------------
  HasGainLossEntriesIn
-------------------------------------------------------------------------------}
function HasGainLossEntriesIn(const aClient: TClientObj;
  const aSnapshot: ITransactionSnapshot): boolean;
var
  iBankAccount: integer;
  BankAccount: TBank_Account;
  Months: TStDateDynArray;
  iMonth: integer;
  dtLastDayOfTheMonth: TStDate;
  PostedEntry: TExchange_Gain_Loss;
begin
  result := false;

  // Can be nil when IsForeignClient check hasn't created it
  if not assigned(aSnapshot) then
    exit;

  for iBankAccount := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(iBankAccount);

    // For G/L we're only interested in foreign currency bank accounts
    if not IsForeignCurrencyAccount(BankAccount) then
      continue;

    // No changes?
    if not aSnapshot.HasChanges(BankAccount, Months) then
      continue;

    // Check for G/L entries
    for iMonth := 0 to High(Months) do
    begin
      dtLastDayOfTheMonth := GetLastDayOfMonth(Months[iMonth]);
      PostedEntry := BankAccount.baExchange_Gain_Loss_List.GetPostedEntry(dtLastDayOfTheMonth);
      if not assigned(PostedEntry) then
        continue;

      // Found an entry, so stop the search
      result := true;
      exit;
    end;
  end;
end;


{-------------------------------------------------------------------------------
  ValidateTransactionExchangeRates
-------------------------------------------------------------------------------}
function ValidateTransactionExchangeRates(const aClient: TClientObj): boolean;
var
  ExchangeSource: TExchangeSource;
  iBankAccount: integer;
  BankAccount: TBank_Account;
  iIsoIndex: integer;
  iTransaction: integer;
  Transaction: pTransaction_Rec;
  Rate: TExchangeRecord;
  RateAmount: double; // Exchange Rates are doubles
begin
  ASSERT(assigned(aClient));

  // Not a client with foreign bank accounts?
  if not IsForeignCurrencyClient(aClient) then
  begin
    result := true;
    exit;
  end;

  result := false;

  ExchangeSource := CreateExchangeSource;
  try
    for iBankAccount := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(iBankAccount);

      // Not a foreign bank account?
      if not IsForeignCurrencyAccount(BankAccount) then
        continue;

      // Get ISO index
      iIsoIndex := ExchangeSource.GetISOIndex(BankAccount.baFields.baCurrency_Code,
        ExchangeSource.Header);

      for iTransaction := 0 to BankAccount.baTransaction_List.ItemCount-1 do
      begin
        Transaction := BankAccount.baTransaction_List.Transaction_At(iTransaction);

        // Finalised?
        if Transaction.txLocked then
          continue;

        // Transferred?
        if (Transaction.txDate_Transferred <> 0) then
          continue;

        // Transaction month does not have a gain/loss entry?
        if not BankAccount.baExchange_Gain_Loss_List.HasEntryIn(Transaction.txDate_Effective) then
          continue;

        // No data for this currency?
        Rate := ExchangeSource.GetDateRates(Transaction.txDate_Effective);
        if not Assigned(Rate) then
          exit;

        // No amount?
        RateAmount := Rate.Rates[iIsoIndex];
        if (RateAmount = 0) then
          exit;

        // Exchange rate not the same?
        if not SameValue(Transaction.txForex_Conversion_Rate, RateAmount) then
          exit;

        // Valid, continue
      end;
    end;
  finally
    FreeAndNil(ExchangeSource);
  end;

  result := true;
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
  PostedEntry: TExchange_Gain_Loss;
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

  // See if we've run before for this month
  with aBankAccount.baExchange_Gain_Loss_List do
    PostedEntry := GetPostedEntry(MonthEndingDateAsStdate);

  // Nothing to record?
  if not Assigned(PostedEntry) then
    exit;

  Inc(NrAlreadyRun);

  // Store this locally for backwards compatability
  result.PostedEntry.Date := PostedEntry.glFields.glDate;
  result.PostedEntry.GainLoss := PostedEntry.glFields.glAmount;
  result.PostedEntry.ExchangeGainLossCode := PostedEntry.glFields.glAccount;
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

{------------------------------------------------------------------------------}
function TMonthEnding.GetCanBeFirstMonth: boolean;
begin
  result :=
    (NrTransactions > 0) and
    not AlreadyRun and
    not Transferred and
    not Finalised and
    not AvailableData;
end;

{------------------------------------------------------------------------------}
function TMonthEnding.HasMissingExchangeRates: boolean;
begin
  result :=
    ExchangeRateMissing or
    ExchangeRateMissingLastDayOfCurrentMonth or
    ExchangeRateMissingLastDayOfPreviousMonth;
end;


{ ------------------------------------------------------------------------------
  TPostedEntry
------------------------------------------------------------------------------ }
function TPostedEntry.GetValid: boolean;
begin
  result := (Date > 0);
end;

procedure TPostedEntry.SetExchangeGainLossCode(const Value: String);
begin
  FExchangeGainLossCode := Value;
end;

{------------------------------------------------------------------------------}
function TPostedEntry.GetGainLossCurrency: string;
begin
  result := GetLocalCurrencyAmount(GainLoss);
end;

{------------------------------------------------------------------------------}
function TPostedEntry.GetGainLossCrDr: string;
begin
  result := GetCrDr(GainLoss);
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
begin
  result := GetLocalCurrencyAmount(GainLoss);
end;

{------------------------------------------------------------------------------}
function TMonthEndingBankAccount.GetGainLossCrDr: string;
begin
  result := GetCrDr(GainLoss);
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
function TMonthEndings.FindBankAccountEntry(BankAccount: TBank_Account; aDate: Integer): PMonthEndingBankAccount;
var
  MonthEnding: PMonthEnding;
  Index: Integer;
begin
  Result := nil;
  
  MonthEnding := FindMonthEnding(aDate);

  if Assigned(MonthEnding) then
  begin
    for Index := Low(MonthEnding.BankAccounts) to High(MonthEnding.BankAccounts) do
    begin
      if MonthEnding.BankAccounts[Index].BankAccount =  BankAccount then
      begin
        Result := @MonthEnding.BankAccounts[Index];

        Exit;
      end;
    end;
  end;
end;

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

    // Transactions
    Inc(pMonth.NrTransactions);

    // Locked
    if pTransaction.txLocked then
      Inc(pMonth.NrLocked);

    // Transferred
    if (pTransaction.txDate_Transferred <> 0) then
      Inc(pMonth.NrTransferred);

    // Exchange rate missing?
    if pTransaction.txUPI_State in[upMatchedUPC, upMatchedUPD, upMatchedUPW] then
    begin
      if not HasExchangeRate(pTransaction.txDate_Presented, iIsoIndex) then
        pMonth.ExchangeRateMissing := true;      
    end
    else
    begin
      if not HasExchangeRate(pTransaction.txDate_Effective, iIsoIndex) then
        pMonth.ExchangeRateMissing := true;
    end;
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
  if not (meoCullMonths in fOptions) then
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
procedure TMonthEndings.CullCurrentMonth;
var
  iLength: integer;
  iYear: integer;
  iMonth: integer;
  iDay: integer;
  iLastDay: integer;
begin
  // Don't cull?
  if not (meoCullMonths in fOptions) then
    exit;

  // No months?
  iLength := Length(fMonthEndings);
  if (iLength = 0) then
    exit;

  // Last day of current month?
  with fMonthEndings[iLength-1] do
  begin
    // Not same year/month?
    SplitYearMonth(Today, iYear, iMonth);
    if (Year <> iYear) then
      exit;
    if (Month <> iMonth) then
      exit;

    // Not last day of current month?
    iDay := DayOf(Today);
    iLastDay := DateUtils.DaysInMonth(Today);
    if (iDay = iLastDay) then
      exit;
  end;

  // Delete the last entry
  SetLength(fMonthEndings, iLength-1);
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.VerifyExchangeRateOpeningClosing;
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

      iIsoIndex := GetIsoIndex(BankAccount.baFields.baCurrency_Code);

      // Check we have an exchange rate in the last day of the current month
      if not HasExchangeRate(pMonth.MonthEndingDateAsStDate, iIsoIndex) then
        pMonth.ExchangeRateMissingLastDayOfCurrentMonth := true;

      // Check we have an exchange rate in the last day of the previous month
      if not HasExchangeRate(stDate, iIsoIndex) then
        pMonth.ExchangeRateMissingLastDayOfPreviousMonth := true;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.CalculateGainLoss(var aBankAccount: TMonthEndingBankAccount;
  const aStart: TStDate; const aEnd: TStDate);
var
  GainLoss: TCalculateGainLoss;
begin
  GainLoss := TCalculateGainLoss.Create(fExchangeSource);
  try
    try
      GainLoss.Calculate(aBankAccount.BankAccount, aStart, aBankAccount.GainLoss);
    except
      on E: Exception do
      begin
        // All exchange rates should already be there (as checked in validation)
        ASSERT(false, E.Message);
      end;
    end;
  finally
    FreeAndNil(GainLoss);
  end;
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
    if aMonth.HasMissingExchangeRates then
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
  // Don't calculate?
  if not (meoCalculateGainLoss in fOptions) then
    exit;

  for i := 0 to High(fMonthEndings) do
  begin
    CalculateGainLoss(fMonthEndings[i]);
  end;
end;

{------------------------------------------------------------------------------}
procedure TMonthEndings.PostGainLossEntry(const aMonth: PMonthEnding;
  const aBankAccount: TMonthEndingBankAccount);
begin
  ExchangeGainLoss.PostGainLossEntry(aBankAccount.BankAccount,
    aMonth.MonthEndingDateAsStdate, aBankAccount.GainLoss);
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

  // Remove the current month if it's not the last day of the month
  CullCurrentMonth;

  // Verify if there's an exchange rate for the opening/closing balance
  VerifyExchangeRateOpeningClosing;

  { Calculate ALL Gain/Loss amounts. They are the "proposed" values, not the
    values that were already there.
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
function TMonthEndings.DetermineFirstMonth: integer;
var
  i: integer;
begin
  for i := 0 to Count-1 do
  begin
    if fMonthEndings[i].CanBeFirstMonth then
    begin
      result := i;
      exit;
    end;
  end;

  result := -1;
end;

{------------------------------------------------------------------------------}
function TMonthEndings.ValidateMonthEnding(const aMonthIndex: integer;
  var aErrors: string): boolean;
begin
  aErrors := '';

  // Validation - one error message at the time
  with fMonthEndings[aMonthIndex] do
  begin
    if (NrLocked > 0) or (NrTransferred > 0) then
      AddError(ERR_FINALISED_OR_TRANSFERRED, aErrors)
    else if AvailableData then
      AddError(ERR_AVAILABLE_DATA, aErrors)
    else if ExchangeRateMissing then
      AddError(ERR_MISSING_EXCHANGE_RATE, aErrors)
    else if ExchangeRateMissingLastDayOfCurrentMonth then
      AddError(ERR_MISSING_EXCHANGE_RATE_CURRENT_MONTH, aErrors)
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


{-------------------------------------------------------------------------------
 TCalculateGainLoss
-------------------------------------------------------------------------------}
constructor TCalculateGainLoss.Create(const aSource: TExchangeSource = nil);
begin
  if assigned(aSource) then
  begin
    fExchangeSourceOwner := false;
    fExchangeSource := aSource;
  end
  else
  begin
    fExchangeSourceOwner := true;
    fExchangeSource := CreateExchangeSource;
  end;
end;

{------------------------------------------------------------------------------}
destructor TCalculateGainLoss.Destroy;
begin
  if fExchangeSourceOwner then
    FreeAndNil(fExchangeSource)
  else
    fExchangeSource := nil;

  inherited; // LAST
end;

{------------------------------------------------------------------------------}
procedure TCalculateGainLoss.Calculate(const aBankAccount: TBank_Account;
  const aYearMonth: TStDate; var aGainLoss: Money);
var
  Range: TDateRange;
begin
  Range := GetMonthDateRange(aYearMonth);
  Calculate(aBankAccount, Range.FromDate, Range.ToDate, aGainLoss);
end;

{------------------------------------------------------------------------------}
function TCalculateGainLoss.GetIsoIndex(const aCurrencyCode: string): integer;
begin
  result := fExchangeSource.GetISOIndex(aCurrencyCode, fExchangeSource.Header);
end;

{------------------------------------------------------------------------------}
function TCalculateGainLoss.ApplyExchangeRateForeignToBase(const aDate: TStDate;
  const aIsoIndex: integer; const aValue: Money): Money;
var
  Rate: TExchangeRecord;
  RateAmount: double; // Exchange Rates are doubles
begin
  // Exchange rate missing?
  Rate := fExchangeSource.GetDateRates(aDate);
  if not assigned(Rate) then
    raise Exception.Create('Exchange Rate for '+Date2Str(aDate, 'dd/mm/yy')+' not found');

  // This is a double
  RateAmount := Rate.Rates[aIsoIndex];
  if (RateAmount = 0) then
    raise Exception.Create('Exchange Rate for '+Date2Str(aDate, 'dd/mm/yy')+' not set');

  result := Round(aValue / RateAmount);
end;

{------------------------------------------------------------------------------}
procedure TCalculateGainLoss.Calculate(const aBankAccount: TBank_Account; const aStart: TStDate; const aEnd: TStDate; var aGainLoss: Money);

  function ApplyExchangeRate(ISOIndex: Integer; Amount: Money; ADate: TStDate): Money;
  var
    ExchangeRate: Double;
  begin
    ExchangeRate := GetLastDayExchangeRate(aBankAccount, ISOIndex, FExchangeSource, ADate, False, psUnknown);

    if ExchangeRate <> 0 then
    begin
      Result := Round(Amount / ExchangeRate);
    end
    else
    begin
      raise Exception.Create('Exchange Rate for '+Date2Str(ADate, 'dd/mm/yy')+' not set');
    end;
  end;

var
  // See spec
  OB   : Money; // Opening Balance
  COB  : Money; // Converted Opening Balance
  CB   : Money; // Closing Balance
  CCB  : Money; // Converted Closing Balance
  CSUM : Money; // Converted sum of all transactions

  Transactions: TTransaction_List;
  dtLastDayOfPreviousMonth: TStDate;
  Index: integer;
  Transaction: pTransaction_Rec;
  dtEffective: TStDate;
  iIsoIndex: Integer;
begin
  Transactions := aBankAccount.baTransaction_List;

  ASSERT(assigned(Transactions));

  iIsoIndex := GetIsoIndex(aBankAccount.baFields.baCurrency_Code);
  
  // Get Opening/Closing Balance
  GetOpeningClosingBalance(aStart, aEnd, aBankAccount, OB, CB);

  // Use last day of previous month for the opening balance exchange rate
  dtLastDayOfPreviousMonth := IncDate(aStart, -1, 0, 0);

  COB := ApplyExchangeRate(iIsoIndex, OB, dtLastDayOfPreviousMonth);

  // Use last day of the current month for closing balance exchange rate
  CCB := ApplyExchangeRate(iIsoIndex, CB, aEnd);

  // Closing Balance and Sum for transactions
  CSUM := 0;

  for Index := 0 to Transactions.ItemCount-1 do
  begin
    Transaction := Transactions[Index];

    ASSERT(Assigned(Transaction));

    if Transaction.txUPI_State in[upUPC, upUPD, upUPW, upReversedUPC, upReversalOfUPC, upReversedUPD, upReversalOfUPD, upReversedUPW, upReversalOfUPW] then
      continue;

    // Not within range?
    dtEffective := Transaction.GainLossForexDate;
    
    if not ((aStart <= dtEffective) and (dtEffective <= aEnd)) then
      continue;

    // Locked or Transferred?
    if Transaction.Locked then
    begin                                                           
      if Transaction.txForex_Conversion_Rate <> 0 then
      begin
        CSUM := CSUM + Round(Transaction.txAmount / Transaction.txForex_Conversion_Rate);
      end
      else
      begin
        raise Exception.Create('Exchange Rate for '+Date2Str(dtEffective, 'dd/mm/yy')+' not set');
      end;
    end
    else
    begin
      CSUM := CSUM + ApplyExchangeRateForeignToBase(dtEffective, iIsoIndex, Transaction.txAmount);
    end;
  end;

  // Exchange Gain/Loss
  aGainLoss := CCB - COB - CSUM;
end;


{-------------------------------------------------------------------------------
 TTransactionSnapshot
-------------------------------------------------------------------------------}
constructor TTransactionSnapshot.Create(const aClient: TClientObj);
begin
  ASSERT(assigned(aClient));

  fClient := aClient;

  Tag(1);
end;

{------------------------------------------------------------------------------}
destructor TTransactionSnapshot.Destroy;
begin
  Tag(0);

  inherited; // LAST
end;

{------------------------------------------------------------------------------}
function TTransactionSnapshot.HasChanges: boolean;
var
  i: integer;
  BankAccount: TBank_Account;
  Dummy: TStDateDynArray;
begin
  for i := 0 to fClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := fClient.clBank_Account_List.Bank_Account_At(i);

    if HasChanges(BankAccount, Dummy) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

{------------------------------------------------------------------------------}
function TTransactionSnapshot.HasChanges(const aBankAccount: TBank_Account;
  var aMonths: TStDateDynArray): boolean;
var
  iTransaction: integer;
  Transaction: pTransaction_Rec;
begin
  SetLength(aMonths, 0);

  for iTransaction := 0 to aBankAccount.baTransaction_List.ItemCount-1 do
  begin
    Transaction := aBankAccount.baTransaction_List.Transaction_At(iTransaction);

    if (Transaction.txTemp_Tag <> 0) then
      continue;

    Add(Transaction.txDate_Effective, aMonths);
  end;

  result := (Length(aMonths) > 0);
end;

{------------------------------------------------------------------------------}
procedure TTransactionSnapshot.Tag(const aValue: integer);
var
  iBankAccount: integer;
  BankAccount: TBank_Account;
  iTransaction: integer;
  Transaction: pTransaction_Rec;
begin
  for iBankAccount := 0 to fClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := fClient.clBank_Account_List.Bank_Account_At(iBankAccount);

    // Note: Do this for ALL bank accounts (generic - not just foreign, etc)

    for iTransaction := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTransaction);

      Transaction.txTemp_Tag := aValue;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TTransactionSnapshot.Add(const aValue: TStDate;
  var aMonths: TStDateDynArray);
var
  dtFirstDayOfMonth: TStDate;
  i: integer;
  iCount: integer;
begin
  // We're only interested in months, so use 1st of the month for comparing
  dtFirstDayOfMonth := GetFirstDayOfMonth(aValue);

  for i := 0 to High(aMonths) do
  begin
    // Already have it?
    if (aMonths[i] = dtFirstDayOfMonth) then
      exit;
  end;

  // Add it
  iCount := Length(aMonths);
  SetLength(aMonths, iCount+1);
  aMonths[iCount] := dtFirstDayOfMonth;
end;

function GetLastDayExchangeRate(BankAccount: TBank_Account; ISOIndex: Integer; ExchangeSource: TExchangeSource; LastDayOfPeriod: TStDate; PartialPeriod: Boolean; PeriodLockState: TPeriodLockState): Double;

  //For efficiency. Only workout if the period is fully locked if we haven't already done so externally.
  function PeriodFullyLocked: Boolean;
  begin
    case PeriodLockState of
      psFullyLocked: Result := True;
      psNotFullyLocked: Result := False;
      else
        Result := BankAccount.AllFinalizedOrTransferred(GetFirstDayOfMonth(LastDayOfPeriod), LastDayOfPeriod);
    end;
  end;

  function GetSystemExchangeRate(ADate: TStDate): Double;
  var
    Rate: TExchangeRecord;
  begin
    Rate := ExchangeSource.GetDateRates(ADate);

    if assigned(Rate) then
    begin
      Result := Rate.Rates[IsoIndex];
    end
    else
    begin
      Result := 0;
    end;
  end;

var
  FinalizedRate: TFinalized_Exchange_Rate;
  Transaction: pTransaction_Rec;
begin
  //A partial period cannot be considered as completely finalized/transferred
  if not PartialPeriod then
  begin
    if BankAccount.FindTransaction(LastDayOfPeriod, Transaction) then //If a transaction exists on the last day and its locked then we will use that rate, otherwise we need to use the system rate.
    begin
      if Transaction.Locked then
      begin
        Result := Transaction.GainLossExchangeRate;
      end
      else
      begin
        Result := GetSystemExchangeRate(LastDayOfPeriod);
      end;
    end
    else
    begin
      if PeriodFullyLocked then //Determine if we should use the stored rate or the system rate.  We only use the stored rate if the period is fully locked.
      begin
        if BankAccount.baFinalized_Exchange_Rate_List.FindRate(LastDayOfPeriod, FinalizedRate) then
        begin
          Result := FinalizedRate.frFields.frRate;
        end
        else
        begin
          Result := GetSystemExchangeRate(LastDayOfPeriod);
        end;        
      end
      else
      begin
        Result := GetSystemExchangeRate(LastDayOfPeriod); 
      end;
    end;
  end
  else
  begin
    Result := GetSystemExchangeRate(LastDayOfPeriod); //Partial period so lets use the system rate,
  end;
end;

function GetLastDayExchangeRate(BankAccount: TBank_Account; LastDayOfPeriod: TStDate; PartialPeriod: Boolean; PeriodLockState: TPeriodLockState): Double; overload;
var
  ExchangeSource: TExchangeSource;
  IsoIndex: Integer;
begin
  ExchangeSource := CreateExchangeSource;

  try
    IsoIndex := ExchangeSource.GetISOIndex(BankAccount.baFields.baCurrency_Code, ExchangeSource.Header);

    Result := GetLastDayExchangeRate(BankAccount, IsoIndex, ExchangeSource, LastDayOfPeriod, PartialPeriod, PeriodLockState); 
  finally
    ExchangeSource.Free;
  end;
end;

function GetLastDayExchangeRate(BankAccount: TBank_Account; LastDayOfPeriod: TStDate; PeriodLockState: TPeriodLockState): Double;
begin
  Result := GetLastDayExchangeRate(BankAccount, LastDayOfPeriod, IsPartialPeriod(LastDayOfPeriod), PeriodLockState);
end;

function IsPartialPeriod(ToDate: TStDate): Boolean;
begin
  if ToDate >= GetFirstDayOfMonth(CurrentDate) then
  begin
    Result := CurrentDate < GetLastDayOfMonth(CurrentDate);
  end
  else
  begin
    Result := False;
  end;
end;

{------------------------------------------------------------------------------}
initialization
   DebugMe := DebugUnit(UnitName);


end.
