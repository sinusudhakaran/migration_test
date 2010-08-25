Unit CFHEAD;

INTERFACE

CONST

   hdIncome                      = 0;              hdMin = 0;
   hdTotal_Income                = 1;
   hdLess_Direct_Expenses        = 2;
   hdTotal_Direct_Expenses       = 3;
   hdGross_Profit_or_Loss        = 4;
   hdLess_Expenses               = 5;
   hdTotal_Expenses              = 6;
   hdNet_Trading_Profit_Or_Loss  = 7;
   hdPlus_Other_Deposits         = 8;
   hdTotal_Other_Deposits        = 9;
   hdLess_Other_Withdrawals      = 10;
   hdTotal_Other_Withdrawals     = 11;
   hdLess_Capital_Development    = 12;
   hdTotal_Capital_Development   = 13;
   hdGST_Movements               = 14;
   hdNet_GST_Movement            = 15;
   hdUncoded_Deposits            = 16;
   hdUncoded_Withdrawals         = 17;
   hdNet_Cash_Movement_In_Out    = 18;
   hdCashbook_Balances           = 19;
   hdOpening_Balance             = 20;
   hdPlus_Movement               = 21;
   hdClosing_Balance             = 22;
   hdNet_GST                     = 23;
   hdBank_Account_Summary        = 24;
   hdLess_Equity                 = 25;
   hdTotal_Equity                = 26;
   hdCash_Flow                  = 27;

   hdBlank                      = 28;
   hdMax = 28;

   { Maximum no is 40 in the client record }

   hdNames : Array[ hdMin..hdMax ] of String[40] =
      (  'Income',
         'Total Income',
         'Less: Direct Expenses',
         'Total Direct Expenses',
         'Gross Profit (Loss)',
         'Less: Expenses',
         'Total Expenses',
         'Operating Profit (Loss)',
         'Plus: Other Deposits',
         'Total Other Deposits',
         'Less: Other Withdrawals',
         'Total Other Withdrawals',
         'Less: Capital and Development',
         'Total Capital and Development',
         'GST Movements',
         'Net GST Movement',
         'Plus: Uncoded Deposits',
         'Less: Uncoded Withdrawals',
         'Net Cash Movement In (Out)',
         'Cash Book Balances',
         'Opening Balance',
         'Plus: Movement',
         'Closing Balance',
         'Net GST',
         'Cash Book Summary',
         'Less: Equity',
         'Total Equity',
         'Cash Flow',
         ''
   );

IMPLEMENTATION

END.
