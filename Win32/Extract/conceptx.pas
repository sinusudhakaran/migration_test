unit conceptx;

(*
   Concept Cash Manager from

   Computer Concepts
   PO Box 692
   Masterton

   Phone 06 370 0280
   Fax   06 378 6003
   email manager@concept.co.nz

   Paul Younger

   Used by Mackay Bailey Butchard ( Steve Boscoskie )

   There is a bit of a gotcha here. Instead of a Contra Account Code for your
   bank account, you need to enter the NUMBER 1-99 for that bank account in 
   CCM.

*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, SignUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'ConceptX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
Procedure CalculateGSTRateAndProportion( Amount, GSTAmount : Money;
                                         GSTClass : Byte;
                                         Var Rate : Real;
                                         Var Proportion : Integer );

Var
   GrossAmount : Money;
   ERate : Extended;
Begin
   { Deal with the special cases first }
   If ( GSTAmount = 0 ) then
   Begin
      If ( GSTClass = 4 ) then
      Begin
         Rate := 0.0;
         Proportion := -1;
         exit;
      end
      else
      Begin
         Rate := 0.0;
         Proportion := 0;
         exit;
      end;
   end
   else
   If ( GSTAmount = Amount ) then
   Begin
      Rate := 100.0;
      Proportion := 101;
      exit;
   end;
   Proportion  := 100;
   GrossAmount := Amount - GSTAmount; { 11250 - 1250 = 10000 }
   
   ERate := 0.0;

   If Amount <> 0.0 then
      ERate := 10000.0 * GSTAmount / GrossAmount;

   Rate := Round( 10.0 * ERate ) / 10.0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CWrite( const ADate       : TStDate;
                  const ARefce      : ShortString;
                  const AContra     : ShortString;
                  const AAccount    : ShortString;
                  const AAmount     : Money;
                  const AGST_Amount : Money;
                  const AGST_Class  : Byte;
                  const AQuantity   : Money;
                  const AOther_Party : ShortString;
                  const ADescription : ShortString );
const
   ThisMethodName = 'CWrite';
Var
   Amount_Sign               : tSign;
   Expected_Sign_For_Account : tSign;
   S                         : ShortString;   
   Rate                      : Real;
   Account                   : pAccount_Rec;
   Reverse_the_Sign          : Boolean;
   Proportion                : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Expected_Sign_For_Account := Credit;

   Account := MyClient.clChart.FindCode( AAccount );

   Case Account.chAccount_Type of
      atIncome       : Expected_Sign_For_Account := Credit; 
      atExpense : Expected_Sign_For_Account := Debit;
      else
      Begin
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' Error: chAccount_Type must be "I" or "E".' );
         Halt( 1 );
      end;
   end;

   { InvoiceDate }   Write( XFile, Date2Str( ADate, 'dd/mm/yy' ), ',' );

   { OtherParty  }   Write( XFile, '"', ReplaceCommasAndQuotes(AOther_Party), '",' );

   { Account     }   Write( XFile, ReplaceCommasAndQuotes(AContra), ',' );

   { Ref         }   S := TrimSpacesS(ReplaceCommasAndQuotes(ARefce));
                     While Length( S )>6 do System.Delete( S, 1, 1 );
                     Write( XFile, '"', S, '",' );

   { PageNo     }    Write( XFile, '"",' );

   { Cheque     }    Str( Abs( AAmount )/100:0:2, S );
                     Write( XFile, S, ',' );

   { Tran Type }
                     
   Case Account.chAccount_Type of
      atIncome       : Write( XFile, '"I",' );
      atExpense : Write( XFile, '"E",' );
   end;
                        
   { Code }          Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );

   { Enterprise }    Write( XFile, '"",' );

   Amount_Sign := SignUtils.SignOf( AAmount );
   
   Reverse_The_Sign := ( Expected_Sign_For_Account <> Amount_Sign );

   { Amount }        Str( Abs( AAmount )/100:0:2, S );
                     If Reverse_The_Sign then S := '-' + S;
                     Write( XFile, S, ',' );

                     if (Globals.PRACINI_ExtractQuantity) then
   { Quantity }        Str( AQuantity/10000:0:0,S )
                     else
   { Quantity }        Str( 0.0:0:0,S );
                     Write( XFile, S, ',' );

   CalculateGSTRateAndProportion( AAmount, AGST_Amount, AGST_Class, Rate, Proportion );

   { GST Rate }      Str( Rate/100.0:0:1, S );
                     Write( XFile, S, ',' );

   { Proportion }    Write( XFile, Proportion, ',' );

   { Description }   Write( XFile, '"', TrimSpacesS(ReplaceCommasAndQuotes(ADescription)), '",' );
   { Stock Code }    Write( XFile, '"",' );
   { Stock Weight }  Write( XFile, '0.0,' );
   { Stock Cover }   Write( XFile, '0.00' );
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
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         CWrite( txDate_Effective,       { const ADate       : TStDate;       }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),            { const ARefce      : ShortString;   }
                 baContra_Account_Code,  { const AContra     : ShortString;   }
                 txAccount,              { const AAccount    : ShortString;   }
                 txAmount,               { const AAmount     : Money;         }
                 txGST_Amount,           { const AGST_Amount : Money;         }
                 txGST_Class,            { const AGST_Class  : Byte;          }
                 txQuantity,             { const AQuantity   : Money;         }
                 txOther_Party,          { const AOther_Party : ShortString;  }
                 txParticulars           { const ADescription : ShortString );}
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
var
  ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      ExtractLength := GetMaxNarrationLength;
      if ExtractLength > 20 then
        ExtractLength := 20;
      CWrite( txDate_Effective,          { const ADate       : TStDate;       }
              getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ const ARefce      : ShortString;   }
              baContra_Account_Code,     { const AContra     : ShortString;   }
              dsAccount,                 { const AAccount    : ShortString;   }
              dsAmount,                  { const AAmount     : Money;         }
              dsGST_Amount,              { const AGST_Amount : Money;         }
              dsGST_Class,               { const AGST_Class  : Byte;          }
              dsQuantity,                { const AQuantity   : Money;         }
              txOther_Party,             { const AOther_Party : ShortString;  }
              Copy( dsGL_Narration, 1, ExtractLength ) { const ADescription : ShortString );}
            );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VAR
   Types_Used : Array[ atMin..atMax ] of Boolean;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure CheckTransactions;

Var
   Account : pAccount_Rec;   
Begin
   With Transaction^ do if txFirst_Dissection = NIL then
   Begin
      Account := MyClient.clChart.FindCode( txAccount );
      If Assigned( Account ) then With Account^ do Types_Used[ chAccount_Type ] := True;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure CheckDissections;

Var
   Account : pAccount_Rec;   
Begin
   With Dissection^ do
   Begin
      Account := MyClient.clChart.FindCode( dsAccount );
      If Assigned( Account ) then With Account^ do Types_Used[ chAccount_Type ] := True;
   end;
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
   i            : Byte;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Concept Cash Manager format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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

               FillChar( Types_Used, Sizeof( Types_Used ), 0 );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnEHProc( CheckTransactions );
               TRAVERSE.SetOnDSProc( CheckDissections );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );

               For i := atMin to atMax do
               Begin
                  If ( i<>atIncome ) and ( i<>atExpense ) and Types_Used[ i ] then
                  Begin
                     HelpfulInfoMsg( 'To export to Concept Cash Manager, all the accounts must be set to '+
                        'either Income or Expense.', 0 );
                     Exit;
                  end;
               end;
            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
      
         Try
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

