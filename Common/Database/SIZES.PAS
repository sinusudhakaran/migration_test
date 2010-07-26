Program Sizes;

Uses 
   BKDEFS;
Var
   NoOfChartCodes    : LongInt;
   NoOfTransactions  : LongInt;
Begin
   Writeln;
   Writeln( 'SIZES þ Estimates the Memory Requirement to load a BK5 Client file' );
   Writeln;
   NoOfChartCodes := 0;
   NoOfTransactions := 0;
   Write( 'No of account codes = ' ); Readln( NoOfChartCodes );
   Writeln;
   Write( 'No of transactions = ' ); Readln( NoOfTransactions );
   Writeln;

   Writeln( 'Memory Requirement = ',
      1.10 * ( 
      Client_Rec_Size +
      NoOfChartCodes * Account_Rec_Size +
      NoOfTransactions * Transaction_Rec_Size +
      2 * Bank_Account_Rec_Size +
      NoOfTransactions div 10 * 2 * Dissection_Rec_Size +
      100 * Memorised_Transaction_Rec_Size +
      20 * Payee_Rec_Size ):10:0 ,' Bytes' );

   Writeln;
   Writeln( 'Assumptions: 10% of entries are dissected, 2 dissections' );
   Writeln( '100 memorised entries, 20 Payees, 2 Bank Accounts' );
   Writeln( '10% extra allowed for overhead' );
end.
