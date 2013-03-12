unit IntersoftX;

{
   Author, SPA 25-05-99
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'IntersoftX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure IWrite(     const ADate        : TStDate;
                      const ARefce       : ShortString;
                      const AAccount     : ShortString;
                      const AContra      : ShortString;
                      const AAmount      : Money;
                      const AGSTClass    : Byte;
                      const AGSTAmount   : Money;
                      const AQuantity    : Money;
                      const AParticulars : ShortString;
                      const AOtherParty  : ShortString );

const
   ThisMethodName = 'IWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   { Date }    Write( XFile, Date2Str( ADate, 'ddmmyyyy' ), ',' );
   { Source }  Write( XFile, ',' );
   { TrxTyp }  If AAmount >= 0 then
                  Write( XFile, 'W,' )
               else
                  Write( XFile, 'D,' );
   { Refce }   Write( XFile, '"', TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), '",' );
   { Branch }  Write( XFile, '0,' );
   { Dept }    Write( XFile, ',' );
   { Account } Write( XFile, ReplaceCommasAndQuotes(AAccount), ',' );
   { Bank }    Write( XFile, ReplaceCommasAndQuotes(AContra), ',' );
               if (Globals.PRACINI_ExtractQuantity) then
   { Qty }       Write( XFile, GetQuantityStringForExtract(AQuantity), ',' )
               else
   { Qty }       Write( XFile, GetQuantityStringForExtract(0), ',' );

   Case AGSTClass of
      1: Begin { Income }
               { Amount }  Write( XFile, Abs( AAmount )/100.0:0:2, ',' );
               { Tax }     Write( XFile, Abs( AGSTAmount )/100.0:0:2, ',' );
               { TaxIO }   Write( XFile, 'O,' );
               { TaxType } Write( XFile, 'I,' );
         end;
      2: Begin { Expenditure }
               { Amount }  Write( XFile, Abs( AAmount )/100.0:0:2, ',' );
               { Tax }     Write( XFile, Abs( AGSTAmount )/100.0:0:2, ',' );
               { TaxIO }   Write( XFile, 'I,' );
               { TaxType } Write( XFile, 'I,' );
         end;
      3: Begin { Exempt }
               { Amount }  Write( XFile, Abs( AAmount )/100.0:0:2, ',' );
               { Tax }     Write( XFile, Abs( AGSTAmount )/100.0:0:2, ',' );
               { TaxIO }   Write( XFile, 'I,' );
               { TaxType } Write( XFile, 'E,' );
         end;
      else
         Begin { Not Known }
               { Amount }  Write( XFile, Abs( AAmount )/100.0:0:2, ',' );
               { Tax }     Write( XFile, Abs( AGSTAmount )/100.0:0:2, ',' );
               { TaxIO }   Write( XFile, 'I,' );
               { TaxType } Write( XFile, 'I,' );
         end;
   end; { of Case }

   { Comment } Write( XFile,   '"', TrimSpacesS(ReplaceCommasAndQuotes(AParticulars)), '",' );
   { OP }      Writeln( XFile, '"', TrimSpacesS(ReplaceCommasAndQuotes(AOtherParty)), '"' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
var
  sOther  : string[20];
  sPart   : string[12];
  Narration: string;
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
         Narration := Copy( GetNarration(TransAction,Bank_Account.baFields.baAccount_Type), 1, GetMaxNarrationLength);
         sOther := Copy( Narration, 1, 20);
         sPart  := Copy( Narration, 21, 12);
         IWrite( txDate_Effective,      { const ADate        : TStDate;         }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),           { const ARefce       : ShortString;     }
                 txAccount,             { const AAccount     : ShortString;     }
                 baContra_Account_Code, { const AContra      : ShortString;     }
                 txAmount,              { const AAmount      : Money;           }
                 txGST_Class,           { const AGSTClass    : Byte;            }
                 txGST_Amount,          { const AGSTAmount   : Money;           }
                 txQuantity,            { const AQuantity    : Money;           }
                 sPart,         { const AParticulars : ShortString;     }
                 sOther );       { const AOtherParty  : ShortString );   }
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
   sOther : string[20];
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      ExtractLength := GetMaxNarrationLength;
      if ExtractLength > 20 then
        ExtractLength := 20;
      sOther := Copy( dsGL_Narration, 1, ExtractLength);
      IWrite( txDate_Effective,      { const ADate        : TStDate;         }
              getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),
                                     { const ARefce       : ShortString;     }
              dsAccount,             { const AAccount     : ShortString;     }
              baContra_Account_Code, { const AContra      : ShortString;     }
              dsAmount,              { const AAmount      : Money;           }
              dsGST_Class,           { const AGSTClass    : Byte;            }
              dsGST_Amount,          { const AGSTAmount   : Money;           }
              dsQuantity,            { const AQuantity    : Money;           }
              '',                    { const AParticulars : ShortString;     }
              sOther );              { const AOtherParty  : ShortString );   }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
   
var
   Msg          : String; 
   Selected     : TStringList;
   No           : Integer;
   BA           : TBank_Account;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Intersoft format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
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
            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile ); 

         Inc( clLast_Batch_Number );
      
         Try
            Write( XFile, 'GLEXPORT,' );              { File ID }
            Write( XFile, clCode, ',' );              { Client Code }
            Write( XFile, clLast_Batch_Number, ',' ); { Batch Number }
            Writeln( XFile, '"', clName , '"' );      { Client Name }
            
            NoOfEntries       := 0;

            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( twAllNewEntries );
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
