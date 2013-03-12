unit DesktopSuperX;
//------------------------------------------------------------------------------
{
   Title:       Desktop Super fund export

   Description:

   Remarks:

   Author:      Steve Teare

   Notes:       APS Desktop Super

                Phone  +61 2 9965 1300

                Contact Richard Harris

}
//------------------------------------------------------------------------------
interface uses StDate;

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

//******************************************************************************
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
   TransactionUtils,
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
   StStrS,
   InfoMoreFrm,
   BKDefs,
   glConst,
   DesktopSuper_Utils,
   baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'DesktopSuper';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SWrite(  const BNum         : string;
                   const ADate        : TStDate;
                   const ARefce       : ShortString;
                   const ANarration   : string;
                   const AAccount     : ShortString;
                   const AAmount      : Money;
                   const AQuantity    : Money;
                   const AGSTClass    : integer;
                   const AGSTAmount   : Money;

                   const aCGTDate : Integer;
                   const aContrib : Money;
                   const aFranked : Money;
                   const aUnfranked : Money;
                   const aForeignIncome : Money;
                   const aOtherExpenses : Money;
                   const aCapitalGainsOther : Money;
                   const aCapitalGainsDisc : Money;
                   const aCapitalGainsIndexed : Money;
                   const aTaxDeferedDist : Money;
                   const aTaxFreeDist : Money;
                   const aTaxExemptDist : Money;
                   const aImputedCredits : Money;
                   const aTFNCredits : Money;
                   const aForeignCapitalGainsCredit : Money;
                   const aOtherTaxCredit : Money;
                   const aFundID : integer;
                   const aFundCode: string;
                   const aMemberAccountID : integer;
                   const aMemberAccountCode: string;
                   const aTransID: Integer;
                   const aTransCode: string;
                   const aFraction: Boolean;
                   const aLedgerID: Integer);
const
   ThisMethodName = 'SWrite';
var
  i: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, NoOfEntries, ',' );

   if (Length(BNum) < 7) or
      (StrToIntDef(Copy(BNum, 1, 6), -1) = -1) then // no BSB
     Write( XFile, '"000000', BNum, '",' )
   else
     Write( XFile, '"', BNum, '",' );

   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ),'",' );

   Write( XFile, '"',Copy(TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), 1, 10), '",' );

   Write( XFile, '"',Copy(ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ANarration )), 1, GetMaxNarrationLength), '",' );

   Write( XFile, '"',ReplaceCommasAndQuotes(AAccount), '",' );

   Write( XFile, ReplaceCommasAndQuotes(DesktopSuper_Utils.GetChartID(AAccount)), ',' );

   Write( XFile, '"', AAmount/100:0:2, '",' );

   if (Globals.PRACINI_ExtractQuantity) then
     Write( XFile, '"', GetQuantityStringForExtract(Abs( AQuantity)), '",' )
   else
     Write( XFile, '"', GetQuantityStringForExtract(0), '",' );

   if not ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then
      Write( XFile, '"","0.00",' ) { No GST }
   else begin
      Write( XFile, '"', MyClient.clFields.clGST_Class_Codes[ AGSTClass ], '",' );
      Write( XFile, '"', AGSTAmount/100:0:2, '",' );
   end;

   //super fields
   Write( XFile, aLedgerID, ',');
   Write( XFile, '"', aFundCode, '",' );
   if aFundCode = '' then
     Write( XFile, '-1,' )
   else
     Write( XFile, aFundID, ',' );
   Write( XFile, '"', aMemberAccountCode, '",' );
   if aMemberAccountCode = '' then
     Write( XFile, '-1,' )
   else
     Write( XFile, aMemberAccountID, ',' );

   Write( XFile, '"',Date2Str( aCGTDate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"', aContrib/100:0:2, '",');
   Write( XFile, '"', aFranked/100:0:2, '",');
   Write( XFile, '"', aUnfranked/100:0:2, '",');
   Write( XFile, '"', aForeignIncome/100:0:2, '",');
   Write( XFile, '"', aOtherExpenses/100:0:2, '",');
   Write( XFile, '"', aCapitalGainsOther/100:0:2, '",');
   Write( XFile, '"', aCapitalGainsDisc/100:0:2, '",');
   Write( XFile, '"', aCapitalGainsIndexed/100:0:2, '",');
   Write( XFile, '"', aTaxDeferedDist/100:0:2, '",');
   Write( XFile, '"', aTaxFreeDist/100:0:2, '",');
   Write( XFile, '"', aTaxExemptDist/100:0:2, '",');
   Write( XFile, '"', aImputedCredits/100:0:2, '",');
   Write( XFile, '"', aTFNCredits/100:0:2, '",');
   Write( XFile, '"', aForeignCapitalGainsCredit/100:0:2, '",');
   Write( XFile, '"', aOtherTaxCredit/100:0:2, '"');
   if aTransCode = '' then
     Write( XFile, ',-1' )
   else
     Write( XFile, ',', aTransID);
   if aFraction then
     Write (XFile, ',"False"')
   else
     Write (XFile, ',"True"');

   Writeln( XFile );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);
      
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      Inc( NoOfEntries );
      If ( txFirst_Dissection = NIL ) then
      Begin
         SWrite( StripM(Bank_Account),
                 txDate_Effective,           { ADate        : TStDate;         }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { ARefce       : ShortString;     }
                  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),
                 txAccount,                  { AAccount     : ShortString;     }
                 txAmount,                   { AAmount      : Money;           }
                 txQuantity,                 { AQuantity    : Money;           }
                 txGST_Class,
                 txGST_Amount,

                 txSF_CGT_Date,
                 txSF_Special_Income,
                 txSF_Franked,
                 txSF_Unfranked,
                 txSF_Foreign_Income,
                 txSF_Other_Expenses,
                 txSF_Capital_Gains_Other,
                 txSF_Capital_Gains_Disc,
                 txSF_Capital_Gains_Indexed,
                 txSF_Tax_Deferred_Dist,
                 txSF_Tax_Free_Dist,
                 txSF_Tax_Exempt_Dist,
                 txSF_Imputed_Credit,
                 txSF_TFN_Credits,
                 txSF_Foreign_Capital_Gains_Credit,
                 txSF_Other_Tax_Credit,
                 txSF_Fund_ID,
                 txSF_Fund_Code,
                 txSF_Member_Account_ID,
                 txSF_Member_Account_Code,
                 txSF_Transaction_ID,
                 txSF_Transaction_Code,
                 txSF_Capital_Gains_Fraction_Half,
                 baDesktop_Super_Ledger_ID
                 );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;
const
   ThisMethodName = 'DoDissection';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      SWrite( StripM(Bank_Account),
              txDate_Effective,           { ADate        : TStDate;         }
              getDsctReference(Dissection,Transaction,baAccount_Type),
                                          { ARefce       : ShortString;     }
              dsGL_Narration,
              dsAccount,                  { AAccount     : ShortString;     }
              dsAmount,                   { AAmount      : Money;           }
              dsQuantity,                 { AQuantity    : Money;           }
              dsGST_Class,
              dsGST_Amount,

              dsSF_CGT_Date,
              dsSF_Special_Income,
              dsSF_Franked,
              dsSF_Unfranked,
              dsSF_Foreign_Income,
              dsSF_Other_Expenses,
              dsSF_Capital_Gains_Other,
              dsSF_Capital_Gains_Disc,
              dsSF_Capital_Gains_Indexed,
              dsSF_Tax_Deferred_Dist,
              dsSF_Tax_Free_Dist,
              dsSF_Tax_Exempt_Dist,
              dsSF_Imputed_Credit,
              dsSF_TFN_Credits,
              dsSF_Foreign_Capital_Gains_Credit,
              dsSF_Other_Tax_Credit,
              dsSF_Fund_ID,
              dsSF_Fund_Code,
              dsSF_Member_Account_ID,
              dsSF_Member_Account_Code,
              dsSF_Transaction_ID,
              dsSF_Transaction_Code,
              dsSF_Capital_Gains_Fraction_Half,
              baDesktop_Super_Ledger_ID
             );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA: TBank_Account;
   Selected: TStringList;
   Msg: String;
   OK: Boolean;
   No: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Msg := 'Extract data [Desktop Super Fund format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   Ok := False;
   with MyClient, clFields do
   begin
      Selected := SelectBankAccountsForExport(FromDate, ToDate);
      if not Assigned(selected) then
         Exit;
      try
         NoOfEntries := 0;
         for No := 0 to Pred( Selected.Count ) do Begin
            BA := TBank_Account(Selected.Objects[No]);
            With BA.baFields do If baIs_Selected then begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then begin
                  HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
                  exit;
               end;

               if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then begin
                  HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' +
                     'You must code all the entries before you can extract them.',  0 );
                 Exit;
               end;

               {if BA.baFields.baContra_Account_Code = '' then Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                     baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;}
            end;
         end;

         Assign(XFile, SaveTo);
         SetTextBuf(XFile, Buffer);
         Rewrite(XFile);
         try

            for No := 0 to Pred( Selected.Count ) do Begin
               BA := TBank_Account(Selected.Objects[No]);
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod(csDateEffective);
               TRAVERSE.SetSelectionMethod(TRAVERSE.twAllNewEntries);
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
               OK := True;
            end;

         finally
             System.Close( XFile );
         end;

         if OK then Begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      finally
         Selected.Free;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.



