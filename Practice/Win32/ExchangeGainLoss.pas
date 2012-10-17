unit ExchangeGainLoss;

interface

uses
  SysUtils,
  Classes,
  clObj32,
  baObj32,
  ForexHelpers,
  MoneyDef;

  function  ValidateExchangeGainLoss(const aClient: TClientObj; var aErrors: string): boolean;

implementation

type
  TValidateExchangeGainLoss = class
  private
    fClient: TClientObj;
    fErrors: TStringList;

    procedure AddError(const aError: string);

  public
    constructor Create(const aClient: TClientObj);
    destructor Destroy; override;

    function  Validate(var aErrors: string): boolean;
  end;

type
  TValidationRule = (
    ruleForeignTransactionsMustExist,
    ruleBankAccountsMustHaveGainLossCode,
    ruleGainLossCodesMustBeValid,
    ruleCurrenciesMustBeSetup,
    ruleOpeningBalanceMustBeSet
  );

const
  ERR_FOREIGN_TRANSACTIONS_MUST_EXIST =
    'There are no foreign currency transactions available to run the wizard for';

  ERR_ACCOUNTS_MUST_HAVE_GAINLOSS_CODE =
    'Some foreign currency Bank Accounts do not have an Exchange Gain/Loss Code assigned to them';

  ERR_ACCOUNTS_MUST_HAVE_VALID_GAINLOSS_CODE =
    'Some foreign currency Bank Accounts have an invalid Exchange Gain/Loss Code assigned to them';

  ERR_CURRENCIES_MUST_BE_SETUP =
    'There are currencies used by this client’s foreign currency Bank Accounts that are not set up in Maintain Currencies';

  ERR_ACCOUNTS_MUST_HAVE_OPENING_BALANCE =
    'Some foreign currency Bank Accounts do not have an Opening Balance set';

  RULE_ERRORS: array[TValidationRule] of string = (
    ERR_FOREIGN_TRANSACTIONS_MUST_EXIST,
    ERR_ACCOUNTS_MUST_HAVE_GAINLOSS_CODE,
    ERR_ACCOUNTS_MUST_HAVE_VALID_GAINLOSS_CODE,
    ERR_CURRENCIES_MUST_BE_SETUP,
    ERR_ACCOUNTS_MUST_HAVE_OPENING_BALANCE
  );


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
end;

{------------------------------------------------------------------------------}
procedure TValidateExchangeGainLoss.AddError(const aError: string);
var
  sPrefix: string;
begin
  if (fErrors.Count <> 0) then
    fErrors.Add('');
  sPrefix := Format('%d) ', [fErrors.Count+1]);
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
    if not IsGainLossAccount(BankAccount) then
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

  // Determine the error message
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


end.
