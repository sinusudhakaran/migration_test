unit SageHandisoftSuperConst;

interface

type
  TTxnTypes = (ttGeneralExpenses, ttIncome, ttExpenses, ttPurchases,
               ttDisposal, ttTransfer);

  TGeneralExpenses = (geAustralian_Interest, geOverseasInterest,
                      geAuditorFees, geInvestmentExpense,
                      geManagementAndAdministration, geOtherDeductions);

  TIncome = (inMemberContributions, inBankInterest, inTermDeposit,
             inListedCompanyDividend, inListedTrustDistributions,
             inUnlistedTrustDistributions, inManagedFundDistributions,
             inPartnershipDistributions, inRentalIncome);

  TExpenses = (exGeneral, exPensionPayments, exInsurancePremiums,
               exTaxPaymentRefund, exPropertyAdditions);

  TPurchases = (puTermDeposit, puListedCompanyShares,
                puUnlistedCompanyShares, puListedTrustUnits,
                puUnlistedTrustUnits, puManagedFundUnits,
                puPartnershipUnits, puOtherFinancialAssets,
                puProperty, puArtwork, puOtherPhysicalAssets);

  TDisposals = (diTermDeposit, diListedCompanyShares,
                diUnlistedCompanyShares, diListedTrustUnits,
                diUnlistedTrustUnits, diManagedFundUnits,
                diPartnershipUnits, diOtherFinancialAssets,
                diProperty, diArtwork, diOtherPhysicalAssets);

  TTransfers = (trRolloverIn, trRolloverOut, trLumpSum,
                trFormAnotherAccount);

const
  //Types
  TYPE_GENERAL_EXPENCES = 'General Expenses';
  TYPE_INCOME           = 'Income';
  TYPE_EXPENSES         = 'Expenses';
  TYPE_PURCHASES        = 'Purchases';
  TYPE_DISPOSAL         = 'Disposal';
  TYPE_TRANSFER         = 'Transfer';

  //General
  GEN_AUSTRALIAN_INTEREST           = 'Australian interest';
  GEN_OVERSEAS_INTEREST             =	'Overseas interest';
  GEN_AUDITOR_FEES                  = 'Auditor fees';
  GEN_INVESTMENT_EXPENSE            = 'Investment expense';
  GEN_MANAGEMENT_AND_ADMINISTRATION = 'Management and administration';
  GEN_OTHER_DEDUCTIONS              = 'Other deductions';

  //Income
  INC_MEMBER_CONTRIBUTIONS          = 'Member contributions';
  INC_BANK_INTEREST                 = 'Bank Interest';
  INC_TERM_DEPOSIT                  = 'Term Deposit Interest';
  INC_LISTED_COMPANY_DIVIDE         = 'Listed company dividend';
  INC_LISTED_TRUST_DISTRIBUTIONS    = 'Listed trust distributions';
  INC_UNLISTED_TRUST_DISTRIBUTIONS  = 'Unlisted trust distributions';
  INC_MANAGED_FUND_DISTRIBUTIONS    = 'Managed fund distributions';
  INC_PARTNERSHIP_DISTRIBUTIONS     = 'Partnership distributions';
  INC_RENTAL_INCOME                 = 'Rental income';

  //Expenses
  EXP_GENERAL            = 'General';
  EXP_PENSION_PAYMENTS   = 'Pension payments';
  EXP_INSURANCE_PREMIUMS = 'Insurance premiums';
  EXP_TAX_PAYMENT_REFUND = 'Tax payment/refund';
  EXP_PROPERTY_ADDITIONS = 'Property additions';

  //Purchases
  PUR_TERM_DEPOSIT              = 'Term deposit';
  PUR_LISTED_COMPANY_SHARES     = 'Listed company shares';
  PUR_UNLISTED_COMPANY_SHARES 	= 'Unlisted company shares';
  PUR_LISTED_TRUST_UNITS 	      = 'Listed trust units';
  PUR_UNLISTED_TRUST_UNITS 	    = 'Unlisted trust units';
  PUR_MANAGED_FUND_UNITS 	      = 'Managed fund units';
  PUR_PARTNERSHIP_UNITS 	      = 'Partnership units';
  PUR_OTHER_FINANCIAL_ASSETS 	  = 'Other financial assets';
  PUR_PROPERTY 	                = 'Property/real estate';
  PUR_ARTWORK	                  = 'Artwork/collectables etc';
  PUR_OTHER_PHYSICAL_ASSETS 	  = 'Other physical assets';

  //Disposal
  DIS_TERM_DEPOSIT            = 'Term deposit';
  DIS_LISTED_COMPANY_SHARES   = 'Listed company shares';
  DIS_UNLISTED_COMPANY_SHARES = 'Unlisted company shares';
  DIS_LISTED_TRUST_UNITS      = 'Listed trust units';
  DIS_UNLISTED_TRUST_UNITS    = 'Unlisted trust units';
  DIS_MANAGED_FUND_UNITS      = 'Managed fund units';
  DIS_PARTNERSHIP_UNITS       = 'Partnership units';
  DIS_OTHER_FINANCIAL_ASSETS  = 'Other financial assets';
  DIS_PROPERTY                = 'Property/real estate';
  DIS_ARTWORK                 = 'Artwork/collectables etc';
  DIS_OTHER_PHYSICAL_ASSETS   = 'Other physical assets';

  //Transfer
  TRN_ROLLOVER_IN           = 'Rollover in';
  TRN_ROLLOVER_OUT          = 'Rollover out';
  TRN_LUMP_SUM              = 'Lump sum';
  TRN_FORM_ANOTHER_ACCOUNT  = 'From another account';

  TypesArray: array[TTxnTypes] of string = (TYPE_GENERAL_EXPENCES,
                                            TYPE_INCOME, TYPE_EXPENSES,
                                            TYPE_PURCHASES, TYPE_DISPOSAL,
                                            TYPE_TRANSFER);

  GeneralExpensesArray: array[TGeneralExpenses] of string =
                        (GEN_AUSTRALIAN_INTEREST, GEN_OVERSEAS_INTEREST,
                         GEN_AUDITOR_FEES, GEN_INVESTMENT_EXPENSE,
                         GEN_MANAGEMENT_AND_ADMINISTRATION,
                         GEN_OTHER_DEDUCTIONS);

  IncomeArray: array[TIncome] of string =
               (INC_MEMBER_CONTRIBUTIONS, INC_BANK_INTEREST, INC_TERM_DEPOSIT,
                INC_LISTED_COMPANY_DIVIDE, INC_LISTED_TRUST_DISTRIBUTIONS,
                INC_UNLISTED_TRUST_DISTRIBUTIONS, INC_MANAGED_FUND_DISTRIBUTIONS,
                INC_PARTNERSHIP_DISTRIBUTIONS, INC_RENTAL_INCOME);

  ExpensesArray: array[TExpenses] of string =
                 (EXP_GENERAL, EXP_PENSION_PAYMENTS, EXP_INSURANCE_PREMIUMS,
                  EXP_TAX_PAYMENT_REFUND, EXP_PROPERTY_ADDITIONS);

  PurchasesArray: array[TPurchases] of string =
                  (PUR_TERM_DEPOSIT, PUR_LISTED_COMPANY_SHARES,
                   PUR_UNLISTED_COMPANY_SHARES, PUR_LISTED_TRUST_UNITS,
                   PUR_UNLISTED_TRUST_UNITS, PUR_MANAGED_FUND_UNITS,
                   PUR_PARTNERSHIP_UNITS, PUR_OTHER_FINANCIAL_ASSETS,
                   PUR_PROPERTY, PUR_ARTWORK, PUR_OTHER_PHYSICAL_ASSETS);

  DisposalsArray: array[TDisposals] of string =
                  (DIS_TERM_DEPOSIT, DIS_LISTED_COMPANY_SHARES,
                   DIS_UNLISTED_COMPANY_SHARES, DIS_LISTED_TRUST_UNITS,
                   DIS_UNLISTED_TRUST_UNITS, DIS_MANAGED_FUND_UNITS,
                   DIS_PARTNERSHIP_UNITS, DIS_OTHER_FINANCIAL_ASSETS,
                   DIS_PROPERTY, DIS_ARTWORK, DIS_OTHER_PHYSICAL_ASSETS);

  TransfersArray: array[TTransfers] of string =
                  (TRN_ROLLOVER_IN, TRN_ROLLOVER_OUT, TRN_LUMP_SUM,
                   TRN_FORM_ANOTHER_ACCOUNT);


implementation

end.
