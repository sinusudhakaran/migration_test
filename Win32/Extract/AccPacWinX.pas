unit AccPacWinX;
{
Sample Data from Awie:

"RECTYPE","BATCHID","BTCHENTRY","SRCELEDGER","SRCETYPE","JRNLDESC"
"RECTYPE","BATCHNBR","JOURNALID","TRANSNBR","ACCTID","TRANSAMT","TRANSDESC","TRANSREF"
"1","000001","00001","GL","JE","testing                       "
"2","000001","00001","0000000020","1000                                         ",1234.000,"                              ","                      "
"2","000001","00001","0000000040","400010040                                    ",-1234.000,"                              ","                      "
"1","000001","00002","GL","JE","Check Run for June 10, 2010   "
"2","000001","00002","0000 000020","2010                                         ",7500.500,"Jump Air Shuttle              ","278995                "
"2","000001","00002","0000000040","2010                                         ",3000.000,"Baker Johnson and Brown       ","278995                "
"2","000001","00002","0000000060","2010                                         ",8000.000,"State Insurance               ","278996                "
"2","000001","00002","0000000080","2010                                         ",1500.000,"World Charities               ","278997                "
"2","000001","00002","0000000100","2010                                         ",17500.680,"National Telephone            ","278998                "
"2","000001","00002","0000000120","2010                                         ",200.650,"U Fly Airlines Freight        ","278999                "
"2","000001","00002","0000000140","1020                                         ",-37701.830,"Check run for June 10, 2010   ","                      "
"1","000001","00003","GL","JE","Another Testing               "
"2","000001","00003","0000000020","1000                                         ",1000.000,"                              ","                      "
"2","000001","00003","0000000040","400010020                                    ",-1000.000,"                              ","                      "

Sent by Chris Timms ctimms@kpmg.co.nz

Max narration 30 char
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses transactionutils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, 
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'AccPacWinX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   SequenceNo    : LongInt;
   TransNBR      : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AccPacWrite( const ARefce      : ShortString;
                       const AAccount    : ShortString;
                       const AAmount     : Money;
                       const ANarration  : ShortString );
const
   ThisMethodName = 'AccPacWrite';
Var
   S : ShortString;
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   (*
     "RECTYPE","BATCHNBR","JOURNALID","TRANSNBR","ACCTID","TRANSAMT","TRANSDESC","TRANSREF"
   *)
   Write( XFile, '"2",' );                      { RECTYPE }
   Write( XFile, '"000001",' );                 { BATCHNBR }
   Str( SequenceNo, S ); While Length( S )< 5 do S := '0'+S;
   Write( XFile, '"', S, '",' );                { JOURNALID }
   Inc( TransNBR, 20 );
   Str( TransNBR, S ); While Length( S )< 10 do S := '0'+S;
   Write( XFile, '"', S, '",' );                { TRANSNBR }
   Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );       { ACCTID   }
   Write( XFile, AAmount/100:0:3, ',' );                { TRANSAMT }
   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 30 then
     ExtractLength := 30;
   Write( XFile, '"', Copy(ReplaceCommasAndQuotes(ANarration), 1, ExtractLength ), '",' ); { TRANSDESC }
   Writeln( XFile, '"',TrimSpacesS(ReplaceCommasAndQuotes(ARefce)),'"' ); { TRANSREF }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
Var
   CC   : string[10];
   S    : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Transaction.txDate_Transferred := CurrentDate;
   if SkipZeroAmountExport(Transaction) then
      Exit; // Im done...
   
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin

      Inc( SequenceNo );
      TransNBR := 0;
      (*
      "RECTYPE","BATCHID","BTCHENTRY","SRCELEDGER","SRCETYPE","JRNLDESC"
      *)
      Write( XFile, '"1",' );          { RECTYPE }
      Write( XFile, '"000001",' );     { BATCHID }
      Str( SequenceNo, S ); While Length( S )< 5 do S := '0'+S;
      Write( XFile, '"', S, '",' );    { BTCHENTRY }
      Write( XFile, '"GL",' );         { SCRELEDGER }
      Write( XFile, '"JE",' );         { SCRETYPE }
      S := 'B/S Date '+Date2Str( txDate_Effective, 'dd/mm/yy' );
      Writeln( XFile, '"', S, '"' );   { JRNLDESC }

      If ( txFirst_Dissection = NIL ) then
      Begin
         If ( txGST_Class=0 ) then txGST_Amount := 0;

         AccPacWrite( GetReference(TransAction,Bank_Account.baFields.baAccount_Type), { const ARefce      : ShortString;  }
                      txAccount,                  { const AAccount    : ShortString;  }
                      txAmount-txGST_Amount,      { const AAmount     : Money;        }
                      GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)  { const ANarration  : ShortString ) }
                    );

         If txGST_Amount<>0 then
         Begin
            CC := '';
            if txGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ txGST_Class ];

            AccPacWrite( GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                         CC,                         { const AAccount    : ShortString;  }
                         txGST_Amount,               { const AAmount     : Money;        }
                          GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)              { const ANarration  : ShortString ) }
                       );

         end;
      end;

      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
Var   
   CC : string[10];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Transaction^, Dissection^ do
   Begin
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      AccPacWrite( getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type), { const ARefce      : ShortString;  }
                   dsAccount,                  { const AAccount    : ShortString;  }
                   dsAmount-dsGST_Amount,      { const AAmount     : Money;        }
                   dsGL_Narration                 { const ANarration  : ShortString ) }
                  );

      If dsGST_Amount<>0 then
      Begin
         CC := '';
         if dsGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ dsGST_Class ];
         AccPacWrite( getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type), { const ARefce      : ShortString;  }
                      CC,                         { const AAccount    : ShortString;  }
                      dsGST_Amount,               { const AAmount     : Money;        }
                      dsGL_Narration                 { const ANarration  : ShortString ) }
                     );
         
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoContra;

const
   ThisMethodName = 'DoContra';
Var
   S : ShortString;   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
   
      AccPacWrite( GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                   baContra_Account_Code,      { const AAccount    : ShortString;  }
                   -txAmount,                  { const AAmount     : Money;        }
                   S                           { const ANarration  : ShortString ) }
                 );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';
var
   Msg          : String; 
   Selected     : TStringList;
   BA           : TBank_Account;
   No           : Integer;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [AccPac for Windows format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      with MyClient.clFields do
      begin
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            With BA.baFields do
            Begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
               Begin
                  HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
                  exit;
               end;

               if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
               Begin
                  HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' + 
                  'You must code all the entries before you can extract them.',  0 );
                  Exit;
               end;
      
               if BA.baFields.baContra_Account_Code = '' then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for this bank account. '+
                     ' To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;

               If not HasRequiredGSTContraCodes( BA, FromDate, ToDate ) then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify the control account for each GST Class.' + 
                     ' To do this, go to the Other Functions|GST Details and Rates option.', 0 );
                  exit;
               end;
               
            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
      
         Try
            Writeln( XFile, '"RECTYPE","BATCHID","BTCHENTRY","SRCELEDGER","SRCETYPE","JRNLDESC"' );
            Writeln( XFile, '"RECTYPE","BATCHNBR","JOURNALID","TRANSNBR","ACCTID","TRANSAMT","TRANSDESC","TRANSREF"' );
         
            NoOfEntries := 0;
            SequenceNo  := 0;
            
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnAHProc( DoAccountHeader );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.SetOnETProc( DoContra );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            end;
            OK := True;
         finally            
            System.Close( XFile );
         end;

         if OK then
         Begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      end; { Scope of MyClient }
   finally
      Selected.Free;            
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

