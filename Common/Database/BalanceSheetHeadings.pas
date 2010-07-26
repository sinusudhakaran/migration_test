unit BalanceSheetHeadings;

interface

const
  bhdAssets                     = 0;   bhdMin = 0;
  bhdCurrent_Assets             = 1;
  bhdTotal_Current_Assets       = 2;
  bhdFixed_Assets               = 3;
  bhdTotal_Fixed_Assets         = 4;
  bhdTotal_Assets               = 5;
  bhdLiabilities                = 6;
  bhdTotal_Liabilities          = 7;
  bhdCurrent_Liabilities        = 8;
  bhdTotal_Current_Liabilities  = 9;
  bhdLong_Term_Liabilities      = 10;
  bhdTotal_Long_Term_Liab       = 11;
  bhdEquity                     = 12;
  bhdTotal_Equity               = 13;
  bhdNet_Assets                 = 14;
  bhdBalance_Sheet              = 15;

  bhdBlank                       = 16;
  bhdMax = 16;

  bhdNames : Array[ bhdMin..bhdMax ] of String[40] =
      (  'Assets',
         'Current Assets',
         'Total Current Assets',
         'Fixed Assets',
         'Total Fixed Assets',
         'Total Assets',
         'Liabilities',
         'Total Liabilities',
         'Current Liabilities',
         'Total Current Liabilities',
         'Long Term Liabilities',
         'Total Long Term Liabilities',
         'Equity',
         'Total Equity',
         'Net Assets',
         'Balance Sheet',
         ''
      );

implementation

end.
