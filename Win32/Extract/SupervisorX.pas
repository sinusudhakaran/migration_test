unit SupervisorX;
//------------------------------------------------------------------------------
{
   Title:       Supervisor II fund export

   Description: Extract Data for Supervisot II

   Remarks:     April 2006   Created - Supervisor now supports Super Fund fields
                                       was previously using standard CSV extract

   Author:      Steve Teare
}
//------------------------------------------------------------------------------
interface uses StDate;

procedure ExtractData( const SuperFundType: byte; const FromDate, ToDate : TStDate; const SaveTo : string );

implementation

uses
   TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
   YesNoDlg, LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
   InfoMoreFrm, BKDefs, glConst;

const
   UnitName = 'SupervisorX';
   DebugMe  : Boolean = False;

var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;

procedure SWrite(  const AContra      : ShortString;
                   const ADate        : TStDate;
                   const ARefce       : ShortString;
                   const AAccount     : ShortString;
                   const AAmount      : Money;
                   const AQuantity    : Money;
                   const ANarration   : ShortString;
                   const AGSTClass    : integer;
                   const AGSTAmount   : Money;
                   const aImputedCredit        : Money;
                   const aTaxFreeDist          : Money;
                   const aTaxExemptDist        : Money;
                   const aTaxDeferredDist      : Money;
                   const aTFNCredit            : Money;
                   const aForeignIncome        : Money;
                   const aForeignTaxCredits    : Money;
                   const aOtherExpenses        : Money;
                   const aCapitalGainsIndexed  : Money;
                   const aCapitalGainsDisc     : Money;
                   const aCapitalGainsOther    : Money;
                   const aFranked              : Money;
                   const aUnfranked            : Money;
                   const aInterest, aCapitalGainsForeignDisc, aRent, aSpecialIncome,
                     aOtherTaxCredit, aNonResidentTax, aForeignCGCredit: Money;
                   const aMemberID: string );
const
   ThisMethodName = 'SWrite';
var
   AbsGSTAmount : Money;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, NoOfEntries, ',' );
   write( XFile, '"', ReplaceCommasAndQuotes(AContra), '",' );
   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"',ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ARefce )), '",' );
   write( XFile, '"',ReplaceCommasAndQuotes(AAccount), '",' );
   write( XFile, AAmount/100:0:2, ',' );
   write( XFile, '"',Copy(ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ANarration )), 1, GetMaxNarrationLength), '",' );
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, GetQuantityStringForExtract(AQuantity), ',' )
   else
     write( XFile, GetQuantityStringForExtract(0), ',' );

   with MyClient.clFields do
   begin { Convert our internal representation into the code expected by
           the accounting software }
      if ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then
      begin
         write( XFile, '"', clGST_Class_Codes[ AGSTClass] , '",' );
         write( XFile, AGSTAmount/100:0:2 );
      end
      else
      begin
         write( XFile,   '"",' ); { No GST Class }
         write( XFile, '0.00' ); { No GST Amount }
      end;
   end;

   //super fields
   Write( XFile, ',"', aMemberID, '",');
   Write( XFile, aFranked/100:0:2, ',' );
   Write( XFile, aUnfranked/100:0:2, ',' );
   Write( XFile, aInterest/100:0:2, ',' );
   Write( XFile, aForeignIncome/100:0:2, ',' );
   Write( XFile, aCapitalGainsOther/100:0:2, ',' );
   Write( XFile, aCapitalGainsForeignDisc/100:0:2, ',' );
   Write( XFile, aRent/100:0:2, ',' );
   Write( XFile, aCapitalGainsIndexed/100:0:2, ',' );
   Write( XFile, aCapitalGainsDisc/100:0:2, ',' );
   Write( XFile, aOtherExpenses/100:0:2, ',' );
   Write( XFile, aTaxDeferredDist/100:0:2, ',' );
   Write( XFile, aTaxFreeDist/100:0:2, ',' );
   Write( XFile, aTaxExemptDist/100:0:2, ',' );
   Write( XFile, aSpecialIncome/100:0:2, ',' );
   Write( XFile, aImputedCredit/100:0:2, ',' );
   Write( XFile, aForeignTaxCredits/100:0:2, ',' );
   Write( XFile, aForeignCGCredit/100:0:2, ',' );
   Write( XFile, aTFNCredit/100:0:2, ',' );
   Write( XFile, aOtherTaxCredit/100:0:2, ',' );
   Write( XFile, aNonResidentTax/100:0:2);
   Writeln( XFile );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure DoTransaction;
const
  ThisMethodName = 'DoTransaction';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Inc(NoOfEntries); // Increase even for Dissected
   with MyClient.clFields, Bank_Account.baFields, Transaction^ do
   begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...
         
      if ( txFirst_Dissection = NIL ) then
      begin
         SWrite( baContra_Account_Code,
                 txDate_Effective,           { ADate        : TStDate;         }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { ARefce       : ShortString;     }
                 txAccount,                  { AAccount     : ShortString;     }
                 txAmount,                   { AAmount      : Money;           }
                 txQuantity,                 { AQuantity    : Money;           }
                  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),             { ANarration   : ShortString );   }
                 txGST_Class,
                 txGST_Amount,

                 txSF_Imputed_Credit,
                 txSF_Tax_Free_Dist,
                 txSF_Tax_Exempt_Dist,
                 txSF_Tax_Deferred_Dist,
                 txSF_TFN_Credits,
                 txSF_Foreign_Income,
                 txSF_Foreign_Tax_Credits,
                 txSF_Other_Expenses,
                 txSF_Capital_Gains_Indexed,
                 txSF_Capital_Gains_Disc,
                 txSF_Capital_Gains_Other,
                 txSF_Franked,
                 txSF_Unfranked,
                 txSF_Interest,
                 txSF_Capital_Gains_Foreign_Disc,
                 txSF_Rent,
                 txSF_Special_Income,
                 txSF_Other_Tax_Credit,
                 txSF_Non_Resident_Tax,
                 txSF_Foreign_Capital_Gains_Credit,
                 txSF_Member_ID
                 );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure DoDissection ;
const
   ThisMethodName = 'DoDissection';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   begin
      SWrite( baContra_Account_Code,
              txDate_Effective,           { ADate        : TStDate;         }
              getDsctReference(Dissection,Transaction,baAccount_Type),
                                          { ARefce       : ShortString;     }
              dsAccount,                  { AAccount     : ShortString;     }
              dsAmount,                   { AAmount      : Money;           }
              dsQuantity,                 { AQuantity    : Money;           }
              dsGL_Narration,             { ANarration   : ShortString      }
              dsGST_Class,
              dsGST_Amount,

              dsSF_Imputed_Credit,
              dsSF_Tax_Free_Dist,
              dsSF_Tax_Exempt_Dist,
              dsSF_Tax_Deferred_Dist,
              dsSF_TFN_Credits,
              dsSF_Foreign_Income,
              dsSF_Foreign_Tax_Credits,
              dsSF_Other_Expenses,
              dsSF_Capital_Gains_Indexed,
              dsSF_Capital_Gains_Disc,
              dsSF_Capital_Gains_Other,
              dsSF_Franked,
              dsSF_Unfranked,
              dsSF_Interest,
              dsSF_Capital_Gains_Foreign_Disc,
              dsSF_Rent,
              dsSF_Special_Income,
              dsSF_Other_Tax_Credit,
              dsSF_Non_Resident_Tax,
              dsSF_Foreign_Capital_Gains_Credit,
              dsSF_Member_ID
             );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure ExtractData( const SuperFundType: byte; const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
var
   BA : TBank_Account;
   Msg: string;
   OK: Boolean;
   Selected: TStringList;
   No: Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Msg := 'Extract data [' + saNames[SuperFundType] + ' format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   Ok := False;
   with MyClient.clFields do
   begin
      Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
      if not Assigned( Selected ) then Exit;
      try

         for No := 0 to Pred( Selected.Count ) do Begin
            BA := TBank_Account( Selected.Objects[No] );
            With BA.baFields do Begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then Begin
                  HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
                  exit;
               end;
               {
               if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
               Begin
                  HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' +
                  'You must code all the entries before you can extract them.',  0 );
                  Exit;
               end;

               if BA.baFields.baContra_Account_Code = '' then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                     baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;
               }
            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         try
           	Writeln( XFile, '"Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount",' +
              '"Member","Franked","Unfranked","Interest","Foreign","Foreign CG","Foreign Discount CG","Rent","Capital Gain",' +
              '"Discount CG","OtherTaxable","Tax Deferred","Tax Free Trust","Non-Taxable","Special Income","Imputation Credit","Foreign Credit",'+
              '"Foreign CG Credit","Withholding Credit","Other Tax Credit","Non-Resident Tax"');
            NoOfEntries := 0;
            for No := 0 to Pred(Selected.Count) do begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( twAllNewEntries );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
               OK := True;
            end;
         finally
            System.Close( XFile );
         end;

         if OK then begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      finally
         Selected.Free;
      end;
   end; {Scope of MyClient}
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.




