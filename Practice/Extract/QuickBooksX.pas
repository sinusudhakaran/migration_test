unit QuickBooksX;
//------------------------------------------------------------------------------
{
   Title:       Quickbooks Export

   Description:

   Remarks:     Currently supports Quickbooks 5,6,7

   Author:      SPA 30-08-99

   Notes:
      20-10-99  Reversed the sign of the amount in the header entry.
             Added QBW_ID - the manual says this is a required field for
             SPLIT lines.
             I don't think this ever worked, even if Jason Daniels says it did!

      25-10-00  Added tax gst class and amount to export.

}
//------------------------------------------------------------------------------

interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; Old: Boolean; const SaveTo : string );

//******************************************************************************
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
   Classes,
   Traverse,
   Globals,
   GenUtils,
   bkDateUtils,
   TravUtils,
   YesNoDlg,
   LogUtil,
   BaObj32,
   dlgSelect,
   BkConst,
   MoneyDef,
   SysUtils,
   TransactionUtils,
   StStrS,
   InfoMoreFrm,
   BKDefs,
   glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'QuickBooksX';
   DebugMe  : Boolean = False;
   Tab      : char = #09;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   QBW_ID             : LongInt;

   TAXINVCode : string = 'INVCODE';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure QBWWrite(  AAccount     : ShortString;
                     AAmount      : Money;
                     ANarration   : ShortString;
                     AGSTClass    : integer;
                     AGSTAmount   : Money );
const
   ThisMethodName = 'QBWWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( QBW_ID );
   Write( XFile, 'SPL', Tab );
   Write( XFile, QBW_ID, Tab );
   Write( XFile, 'GENERAL JOURNAL', Tab );
   write( XFile, AAccount, Tab );
   if AGSTClass in [ 1..MAX_GST_CLASS ] then
      write( XFile, ( AAmount - AGSTAmount) /100:0:2, Tab )
   else
      write( XFile, ( AAmount) /100:0:2, Tab );
   Write( XFile, Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength), Tab );

   if AGSTClass in [ 1..MAX_GST_CLASS ] then begin
      Write( XFile, MyClient.clFields.clGST_Class_Codes[ AGSTClass ], Tab);
      Write( XFile, AGSTAmount/100:0:2);
   end
   else begin
      Write( XFile, Tab , Tab);
   end;
   Writeln( XFile , '');

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure QBTranWrite( ADate        : integer;
                       AAccount     : ShortString;
                       AAmount      : Money;
                       ACheq_No     : integer;
                       ANarration   : ShortString;
                       AGSTClass    : integer;
                       AGSTAmount   : Money );
//the gst class and amount are not used for the bank transaction line.
const
   ThisMethodName = 'QBTranWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( QBW_ID );

   Write( XFile, 'TRNS', Tab );
   Write( XFile, QBW_ID, Tab );
   Write( XFile, 'GENERAL JOURNAL', Tab );
   Write( XFile, Date2Str( ADate, 'mm/dd/yy' ), Tab );
   Write( XFile, AAccount, Tab );

//   if AGSTClass in [ 1..MAX_GST_CLASS ] then
//      write( XFile, -( AAmount - AGSTAmount) /100:0:2, Tab )
//   else

   Write( XFile, -( AAmount) /100:0:2, Tab );
   Write( XFile, ACheq_No, Tab );
   Write( XFile, Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength), Tab );

//   if AGSTClass in [ 1..MAX_GST_CLASS ] then begin
//      Write( XFile, MyClient.clFields.clGST_Class_Codes[ AGSTClass ], Tab);
//      Write( XFile, -AGSTAmount/100:0:2);
//   end
//   else begin

   Write( XFile, Tab , Tab);

//   end;
   Writeln( XFile, '');

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
   S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient, MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
      QBTranWrite( txDate_Effective,
                   clChart.FindDesc( baContra_Account_Code ),
                   txAmount,
                   txCheque_Number,
                   S,
                   txGST_Class,
                   txGST_Amount);

      If ( txFirst_Dissection = NIL ) then
      Begin
         QBWWrite( clChart.FindDesc( txAccount ),
                   txAmount,
                   S,
                   txGST_Class,
                   txGST_Amount );
      end;
      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
var
   S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient, MyClient.clFields, Dissection^ do
   Begin
      S := dsGL_Narration;
      QBWWrite( clChart.FindDesc( dsAccount ),
                dsAmount,
                S,
                dsGST_Class,
                dsGST_Amount );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoEndTransaction;

const
   ThisMethodName = 'DoEndTransaction';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Writeln( XFile, 'ENDTRNS' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; Old: Boolean; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA           : TBank_Account;
   Msg          : String;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Msg := 'Extract data [QuickBooks format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
   If BA = NIL then exit;

   if old then
      TAXINVCode := 'TAXCODE'
   else
      TAXINVCode := 'INVITEM';

   with MyClient.clFields do
   begin
      With BA.baFields do
      Begin
         if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
         Begin
            HelpfulInfoMsg( 'There are no new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
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
      end;

      Assign( XFile, SaveTo );
      SetTextBuf( XFile, Buffer );
      Rewrite( XFile );

      Try
      	Writeln( XFile, '!TRNS', Tab,
                  'TRNSID', Tab,
                  'TRNSTYPE', Tab,
                  'DATE', Tab,
                  'ACCNT', Tab,
                  'AMOUNT', Tab,
                  'DOCNUM', Tab,
                  'MEMO', Tab,
                  'TAXCODE', Tab,
                  'TAXAMOUNT' );

      	Writeln( XFile, '!SPL', Tab,
                  'SPLID', Tab,
                  'TRNSTYPE', Tab,
                  'ACCNT', Tab,
                  'AMOUNT', Tab,
                  'MEMO', Tab,
                   TAXINVCode, Tab,
                  'TAXAMOUNT' );

      	Writeln( XFile, '!ENDTRNS' );

         NoOfEntries := 0;
         QBW_ID      := clLast_Batch_Number;

         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.SetOnETProc( DoEndTransaction );
         TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
         OK := True;
      finally
         System.Close( XFile );
      end;

      if OK then
      Begin
         Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulInfoMsg( Msg, 0 );
         clLast_Batch_Number := QBW_ID;
      end;
   end; { Scope of MyClient }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

