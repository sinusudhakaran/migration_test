unit GRAPHHEAD;

interface

const

  ghdMonthlySales = 0; ghdMin = 0;
  ghdMonthlyPayments = 1;
  ghdMonthlyTradingResults = 2;
  ghdTRSales = 3;
  ghdTRGrossProfit = 4;
  ghdTROperatingProfit = 5;
  ghdTotalMonthlyBankBalance = 6;
  ghdOnePageSummary = 7;

  ghdBlank = 8;
  ghdMax = 8;

  ghdNames: array[ghdMin..ghdMax] of string[40] =
  (
    'MONTHLY SALES',
    'MONTHLY PAYMENTS',
    'MONTHLY TRADING RESULTS',
    //Indent the next three which are series in the Trading Result Graph
    //The headings are trimmed when displayed
    '    Sales',
    '    Gross Profit',
    '    Operating Profit',
    'TOTAL MONTHLY BANK BALANCE',
    'ONE PAGE SUMMARY',
    ''
  );

implementation

end.
