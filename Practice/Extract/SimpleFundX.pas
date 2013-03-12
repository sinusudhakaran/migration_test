unit SimpleFundX;
//------------------------------------------------------------------------------
{
   Title:       BGL Simple fund export

   Description:

   Remarks:     Oct 2000  Added GST amount and class fields

                Feb 2004  Added Super fund specific fields

   Author:

   Notes:       Simple Super from BGL Corporate Solutions
                Unit 2, Ormond Centre, 578-596 North Road
                Ormond Vic 3204

                Phone 00613 9530 6077

                Contact Ron Lesh

         Feb 04  Matt Crofts  mcrofts@bglcorp.com.au
                 Simple Fund Product Manager
                 1300 654 401

                Used by Flinders
}
//------------------------------------------------------------------------------
interface uses StDate;

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

//******************************************************************************
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
   SuperFieldsUtils,
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
   glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'SimpleFundX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SWrite(  const ADate        : TStDate;
                   const ARefce       : ShortString;
                   const AAccount     : ShortString;
                   const AAmount      : Money;
                   const AQuantity    : Money;
                   const ANarration   : ShortString;
                   const AGSTClass    : integer;
                   const AGSTAmount   : Money;

                   const aCGTDate              : integer;
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
                   const aMember               : Byte);
const
   ThisMethodName = 'SWrite';
Var
   AbsGSTAmount : Money;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ),'",' );

   Write( XFile, '"',TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), '",' );

   Write( XFile, '"',ReplaceCommasAndQuotes(AAccount), '",' );

   Write( XFile, '"', AAmount/100:0:2, '",' );

   if (Globals.PRACINI_ExtractQuantity) then
     Write( XFile, '"', GetQuantityStringForExtract(Abs( AQuantity)), '",' )
   else
     Write( XFile, '"', GetQuantityStringForExtract(0), '",' );

   Write( XFile, '"',Copy(TrimSpacesS( ReplaceCommasAndQuotes(ANarration)), 1, GetMaxNarrationLength), '",' );

   //BGL Simplefund requires that gst amount is always a positive number
   AbsGSTAmount := abs( AGSTAmount);

   if not ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then
      Write( XFile, '"0.00","",' ) { No GST }
   else begin
      Write( XFile, '"', AbsGSTAmount/100:0:2, '",' );
      Write( XFile, '"', Copy( MyClient.clFields.clGST_Class_Codes[ AGSTClass ],1,1), '",' );
   end;

   Write( XFile, '"', AAmount/100:0:2, '",' );

   //super fields

   Write( XFile, '"', Date2Str( aCGTDate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"', abs( aImputedCredit)/100:0:2, '",');       //must be +ve
   Write( XFile, '"', aTaxFreeDist/100:0:2, '",');
   Write( XFile, '"', aTaxExemptDist/100:0:2, '",');
   Write( XFile, '"', aTaxDeferredDist/100:0:2, '",');          
   Write( XFile, '"', abs( aTFNCredit)/100:0:2, '",');          //must be +ve
   Write( XFile, '"', aForeignIncome/100:0:2, '",');
   Write( XFile, '"', abs( aForeignTaxCredits)/100:0:2, '",');  //must be +ve
   Write( XFile, '"', abs( aOtherExpenses)/100:0:2, '",');      //must be +ve
   Write( XFile, '"', abs( aCapitalGainsIndexed)/100:0:2, '",');//must be +ve
   Write( XFile, '"', abs( aCapitalGainsDisc)/100:0:2, '",');   //must be +ve
   Write( XFile, '"', abs( aCapitalGainsOther)/100:0:2, '",');   //must be +ve
   Write( XFile, '"', abs( aFranked)/100:0:2, '",');             //must be +ve
   Write( XFile, '"', abs( aUnfranked)/100:0:2, '",');           //must be +ve
   write( XFile, '"', GetSFMemberText(ADate,aMember,true), '"');

   Writeln( XFile );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         SWrite( txDate_Effective,           { ADate        : TStDate;         }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { ARefce       : ShortString;     }
                 txAccount,                  { AAccount     : ShortString;     }
                 txAmount,                   { AAmount      : Money;           }
                 txQuantity,                 { AQuantity    : Money;           }
                  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),             { ANarration   : ShortString );   }
                 txGST_Class,
                 txGST_Amount,

                 txSF_CGT_Date,
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
                 txSF_Member_Component
                 );
      end;

      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;
const
   ThisMethodName = 'DoDissection';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      SWrite( txDate_Effective,           { ADate        : TStDate;         }
              getDsctReference(Dissection,Transaction,baAccount_Type),
                                          { ARefce       : ShortString;     }
              dsAccount,                  { AAccount     : ShortString;     }
              dsAmount,                   { AAmount      : Money;           }
              dsQuantity,                 { AQuantity    : Money;           }
              dsGL_Narration,             { ANarration   : ShortString      }
              dsGST_Class,
              dsGST_Amount,

              dsSF_CGT_Date,
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
              dsSF_Member_Component
             );
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
   Msg := 'Extract data [BGL Simple Fund format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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

         (*
         if not TravUtils.AllCoded( BA, FromDate, ToDate ) then
         Begin
            HelpfulInfoMsg( 'You must code all the entries before you can extract them.', 0 );
            Exit;
         end;
         *)

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         Try
            NoOfEntries := 0;
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



