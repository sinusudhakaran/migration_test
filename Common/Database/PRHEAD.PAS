Unit PRHEAD;

INTERFACE

CONST

   phdIncome                      = 0; phdMin = 0;
   phdTotal_Income                = 1;
   phdLess_Direct_Expenses        = 2;
   phdCOGS                        = 3;
   phdOther_Direct_Expenses       = 4;
   phdTotal_Direct_Expenses       = 5;
   phdGross_Profit_or_Loss        = 6;
   phdLess_Other_Expenses         = 7;
   phdTotal_Other_Expenses        = 8;
   phdNet_Trading_Profit_Or_Loss  = 9;

   phdDebtors                     = 10;  //balance sheet item - obosolete from 5.2
   phdTDebtors                    = 11;  //balance sheet item - obosolete from 5.2
   phdCreditors                   = 12;  //balance sheet item - obosolete from 5.2
   phdTCreditors                  = 13;  //balance sheet item - obosolete from 5.2
   phdStockOnHand                 = 14;  //balance sheet item - obosolete from 5.2
   phdTStockOnHand                = 15;  //balance sheet item - obosolete from 5.2
   phdFixedAssets                 = 16;  //balance sheet item - obosolete from 5.2
   phdTFixedAssets                = 17;  //balance sheet item - obosolete from 5.2
   phdBank                        = 18;  //balance sheet item - obosolete from 5.2
   phdTBank                       = 19;  //balance sheet item - obosolete from 5.2
   phdGross_PL_Margin             = 20;  //not used
   phdNet_PL_Margin               = 21;  //not used

   phdExpenses                    = 22;
   phdTotal_Expenses              = 23;
   phdOperating_Profit            = 24;
   phdOther_Income                = 25;
   phdTotal_Other_Income          = 26;

   phdTotal_COGS                  = 27;
   phdTotal_Other_Direct_Expenses = 28;
   phdProfit_And_Loss             = 29;

   phdBlank                       = 30;
   phdMax = 30;

   phdNames : Array[ phdMin..phdMax ] of String[40] =
      (  'Income',
         'Total Income',
         'Less: Direct Expenses',
         'Cost of Goods Sold',
         'Other Direct Expenses',
         'Total Direct Expenses',
         'Gross Profit (Loss)',
         'Less: Other Expenses',
         'Total Other Expenses',
         'Net Profit (Loss)',

         'Debtors',
         'Total Debtors',
         'Creditors',
         'Total Creditors',
         'Stock On Hand',
         'Total Stock on Hand',
         'Fixed Assets',
         'Total Fixed Assets',
         'Bank',
         'Total Bank',
         'Gross Profit (Loss) As % Of Income',
         'Net Profit (Loss) As % Of Income',
//NEW in bk5.2
         'Less: Expenses',
         'Total Expenses',
         'Operating Profit (Loss)',
         'Plus: Other Income',
         'Total Other Income',

         'Total Cost of Goods Sold',
         'Total Other Direct Expenses',
         'Profit and Loss',
         ''
         );

IMPLEMENTATION

Initialization
   Assert( phdMax <= 40, 'Client record can only hold 40 headings');
END.
