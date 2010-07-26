unit BeyondX;

{
   Author, SPA 25-05-99

   This is the extract data program for Beyond Private Ledger sites.

   John Bird: john@beyond.co.nz

   Used by Malloch Maclean
           Prosser Quirke
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'BeyondX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   HasInvalidGSTRates : Boolean;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure CheckForInvalidGSTRates ;

const
   ThisMethodName = 'CheckForInvalidGSTRates ';
   
VAR
   dThis : pDissection_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient, Transaction^ do 
   Begin
      If Assigned( txFirst_Dissection ) then
      Begin
         dThis := txFirst_Dissection;
         while ( dThis<>nil ) do with dThis^ do
         Begin
            if not ( dsGST_Class in [ 1..4 ] ) then
               HasInvalidGSTRates := True;
            dThis := dsNext;
         end;
      end
      else
      Begin
         if not ( txGST_Class in [ 1.. 4 ] ) then 
            HasInvalidGSTRates := True;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;




// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure BeyondWrite( const ADate        : TStDate;
                       const ARefce       : ShortString;
                       const AAccount     : ShortString;
                       const AAmount      : Money;
                       const AGSTClass    : Byte;
                       const AGSTAmount   : Money;
                       const AQuantity    : Money;
                       const ANarration   : ShortString );
Begin
   Write( XFile, '"', Date2Str( ADate, 'dd/mm/yy' ), '",' );
   Write( XFile, '"', StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), '",' );
   Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );
   Write( XFile, AAmount/100.0:0:2, ',' );

   If not ( AGSTClass in [ 1..4 ] ) then
   Begin
      write( XFile, '0,0.00,' );
   end
   else
   begin
      write( XFile, AGSTClass, ',' );
      write( XFile, AGSTAmount/100.0:0:2, ',' );
   end;
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, GetQuantityStringForExtract(AQuantity), ',' )
   else
     write( XFile, GetQuantityStringForExtract(0), ',' );
   Writeln( XFile, '"', Copy(StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ANarration)), 1, GetMaxNarrationLength), '"' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
Var
  S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         BeyondWrite(  txDate_Effective, { ADate        : TStDate;         }
                       GetReference(TransAction,Bank_Account.baFields.baAccount_Type),      { ARefce       : ShortString;     }
                       txAccount,        { AAccount     : ShortString;     }
                       txAmount,         { AAmount      : Money;           }
                       txGST_Class,      { AGSTClass    : Byte;            }
                       txGST_Amount,     { AGSTAmount   : Money;           }
                       txQuantity,       { AQuantity    : Money;           }
                       S );              { ANarration   : ShortString );   }
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
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      BeyondWrite(  txDate_Effective, { ADate        : TStDate;         }
                    getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ ARefce       : ShortString;     }
                    dsAccount,        { AAccount     : ShortString;     }
                    dsAmount,         { AAmount      : Money;           }
                    dsGST_Class,      { AGSTClass    : Byte;            }
                    dsGST_Amount,     { AGSTAmount   : Money;           }
                    dsQuantity,       { AQuantity    : Money;           }
                    S );              { ANarration   : ShortString );   }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA : TBank_Account;
   Msg          : String;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Beyond P/L format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   with MyClient.clFields do
   begin
      BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
      if not Assigned( BA ) then Exit;

      With BA.baFields do
      Begin
         if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
         Begin
            HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
            exit;
         end;

         if not ( TravUtils.AllCoded( BA, FromDate, ToDate ) ) then
         Begin
            HelpfulInfoMsg( 'There are still some uncoded entries. You must code them all before you can extract them.', 0 );
            exit;
         end;

         HasInvalidGSTRates := False;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetOnEHProc( CheckForInvalidGSTRates );
         TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
         if HasInvalidGSTRates then
         Begin
            HelpfulInfoMsg( 'Before you import the entries, they must all have a valid GST Rate.', 0 );
            exit;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         Try
            NoOfEntries := 0;

            Writeln( XFile, '[BPL]' );

            Write( XFile, '"Date",' );
            Write( XFile, '"Reference",' );
            Write( XFile, '"Account",' );
            Write( XFile, '"Amount",' );
            Write( XFile, '"GST Class",' );
            Write( XFile, '"GST Amount",' );
            Write( XFile, '"Quantity",' );
            Write( XFile, '"Narration"' );
            Writeln( XFile );

            TRAVERSE.Clear;
            TRAVERSE.SetSortMethod( csDateEffective );
            TRAVERSE.SetSelectionMethod( twAllNewEntries );
            TRAVERSE.SetOnEHProc( DoTransaction );
            TRAVERSE.SetOnDSProc( DoDissection );
            TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            OK := True;
         finally            
            System.Close( XFile );
         end;
      end;
      if OK then
      Begin
         Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulInfoMsg( Msg, 0 );
      end;
   end; { Scope of MyClient }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


