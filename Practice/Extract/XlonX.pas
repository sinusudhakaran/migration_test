unit XlonX;

(*
  XLon 2 format
*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs, StStrS, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'XlonX';
   DebugMe  : Boolean = False;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   TransactionID : Integer;
   DissectionID  : Integer;
   NoOfEntries   : Integer;
   D1, D2        : TStDate;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure XLonWrite( const ItemID      : Integer;
                     const ADate       : TStDate;
                     const ACashFlag   : Char; { Cash or Non-Cash }
                     const ARefce      : ShortString;
                     const AAccount    : ShortString;
                     const AContra     : ShortString;
                     const AAmount     : Money;
                     const AGSTClass   : Byte;
                     const AGSTAmount  : Money;
                     const AQuantity   : Money;
                     const ANarration  : ShortString );
const
   ThisMethodName = 'XlonWrite';
Var
   S : ShortString;   
   GSTCode : String[10];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   Write( XFile, '"TR",' );
   Write( XFile, '"', TransactionID, '",' );
   Write( XFile, '"', ItemID, '",' );
   Write( XFile, '"', ACashFlag, '",' );
   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ), '",' );
   Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );
   Write( XFile, '"', ReplaceCommasAndQuotes(AContra), '",' );

   S := StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce));
   While ( Length( S )>7 ) do Delete( S, 1, 1 );
   Write( XFile, '"', S, '",' );
   
   Write( XFile, '"', AAmount/100:0:2, '",' );
   Write( XFile, '"', AGSTAmount/100:0:2, '",' );

   GSTCode := '';
   If AGSTClass in [ 1..MAX_GST_CLASS ] then GSTCode := MyClient.clFields.clGST_Class_Codes[ AGSTClass ];
   
   Write( XFile, '"', TrimS( Copy( GSTCode, 1, 2 ) ), '",' );
   
   If ( Length( GSTCode ) = 3 ) and ( GSTCode[3]='C' ) then { The C indicates the Capital Clases }
      Write( XFile, '"C",' )
   else
      Write( XFile, '"O",' );
   
   if (Globals.PRACINI_ExtractQuantity) then
     Write( XFile, '"', GetQuantityStringForExtract(AQuantity, 2), '",' )
   else
     Write( XFile, '"', GetQuantityStringForExtract(0, 2), '",' );

   Writeln( XFile, '"', Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength) , '"' );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Var
  CashFlag : Char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( TransactionID ); DissectionID := 0;
   
   With MyClient.clFields, Bank_Account, baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( baAccount_Type = btAccrualJournals ) then
         CashFlag := 'N'
      else
         CashFlag := 'C';

      { Note: Cash Journals have to transfer as Cash entries }
      
      If ( txFirst_Dissection = NIL ) then
      Begin
         XLonWrite( 0,
                    txDate_Effective,
                    CashFlag,
                    GetReference(TransAction,Bank_Account.baFields.baAccount_Type),
                    txAccount,
                    baContra_Account_Code,
                    txAmount,
                    txGST_Class,
                    txGST_Amount,
                    txQuantity,
                    GetNarration(TransAction,Bank_Account.baFields.baAccount_Type) );
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
   CashFlag : Char;   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Bank_Account, baFields, Transaction^, Dissection^ do
   Begin
      Inc( DissectionID );
      If ( baAccount_Type = btAccrualJournals ) then
         CashFlag := 'N'
      else
         CashFlag := 'C';

      XLonWrite( DissectionID,
                 txDate_Effective,
                 CashFlag,
                 getDsctReference(Dissection,Transaction,baAccount_Type),
                 dsAccount,
                 baContra_Account_Code,
                 dsAmount,
                 dsGST_Class,
                 dsGST_Amount,
                 dsQuantity,
                 dsGL_Narration );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate );

const
   ThisMethodName = 'ExtractData';
var
   Msg          : String; 
   BA           : TBank_Account;
   OK           : Boolean;
   FileName     : ShortString;
   i, No        : Integer;
   Selected		 : TStringList;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   D1  := FromDate;
   D2  := ToDate;

   Msg := 'Extract data [Xlon2 format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      For No := 0 to Pred( Selected.Count ) do
      Begin
         BA := TBank_Account( Selected.Objects[ No ] );
         With BA.baFields do
         Begin
            If TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
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

            if baContra_Account_Code = '' then
            Begin
               HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                  baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
               exit;
            end;
         end;
      end;      

      With MyClient.clFields do
      Begin   
         TransactionID := clLast_Batch_Number;

         FileName := clCode + '.xlon2';

         Assign( XFile, FileName );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
         Try
            { Write a File Header }
            Write( XFile, '"XLON2",' );
            Write( XFile, '"', clName, '",' );
            Write( XFile, '"',Date2Str( D1, 'dd/mm/yyyy' ), '",' );
            Write( XFile, '"',Date2Str( D2, 'dd/mm/yyyy' ), '"' );
            Writeln( XFile );

            { Write the Chart }
            
            With MyClient.clChart do For i := 0 to Pred( ItemCount ) do With Account_At( i )^ do If chPosting_Allowed then
            Begin
               Write( XFile, '"AC",' );
               Write( XFile, '"', chAccount_Code, '",' );
               Write( XFile, '"', chAccount_Description, '"' );
               Writeln( XFile );
            end;
            
            { Write the transactions }
            
            NoOfEntries := 0;
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            end;
            OK := True;
         finally            
            System.Close( XFile );
         end;

         if OK then
         Begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, FileName ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
            clLast_Batch_Number := TransactionID;
         end;
      end; { Scope of BA.baFields }
   finally
      Selected.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.




