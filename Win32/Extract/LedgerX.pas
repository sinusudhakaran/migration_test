unit LedgerX;

!! Not supported

This was going to be an interface to Teletax's Ledger Windows product but they
dumped it for CA-Systems instead.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'LedgerX';
   DebugMe  : Boolean = False;
   

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   JnlNumber     : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LWrite( const ADate       : TStDate;
                  const ARefce      : ShortString;
                  const AAccount    : ShortString;
                  const AAmount     : Money;
                  const ANarration  : ShortString );
const
   ThisMethodName = 'LWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( JnlNumber );
   
   Write( XFile, 'TR~' );
   Write( XFile, JnlNumber, '~' );
   Write( XFile, Date2Str( ADate, 'dd/mm/yy' ), '~' );
   Write( XFile, AAccount, '~' );
   Write( XFile, ARefce, '~' );
   Write( XFile, AAmount/100:0:2, '~' );
   Write( XFile, '~' );
   Writeln( XFile, Copy(ANarration, 1, GetMaxNarrationLength, '~' );
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
   S  : String[80];
   CC : string[10];
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
         If ( txGST_Class=0 ) then txGST_Amount := 0;

         LWrite( txDate_Effective,           { const ADate       : TStDate;      }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                 txAccount,                  { const AAccount    : ShortString;  }
                 txAmount-txGST_Amount,      { const AAmount     : Money;        }
                 S                           { const ANarration  : ShortString ) }
               );

         If txGST_Amount<>0 then
         Begin
            CC := '';
            if txGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ txGST_Class ];
               
            LWrite( txDate_Effective,           { const ADate       : TStDate;      }
                    GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                    CC,                         { const AAccount    : ShortString;  }
                    txGST_Amount,               { const AAmount     : Money;        }
                    S                           { const ANarration  : ShortString ) }
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
      LWrite( txDate_Effective,           { const ADate       : TStDate;      }
              getDsctReference(Dissection,Transaction),
                                          { const ARefce      : ShortString;  }
              dsAccount,                  { const AAccount    : ShortString;  }
              dsAmount-dsGST_Amount,      { const AAmount     : Money;        }
              dsNarration                 { const ANarration  : ShortString ) }
             );

      If dsGST_Amount<>0 then
      Begin
         CC := '';
         if dsGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ dsGST_Class ];
         LWrite( txDate_Effective,           { const ADate       : TStDate;      }
                 getDsctReference(Dissection,Transaction),
                                             { const ARefce      : ShortString;  }
                 CC,                         { const AAccount    : ShortString;  }
                 dsGST_Amount,               { const AAmount     : Money;        }
                 dsNarration                 { const ANarration  : ShortString ) }
                );
         
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoContra;

Var
   S : String[80];
const
   ThisMethodName = 'DoContra';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      Case clCountry of
         whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
         whAustralia  : S := tx{removeme}Narration;
      end;
   
      LWrite( txDate_Effective,           { const ADate       : TStDate;      }
              '',                         { const ARefce      : ShortString;  }
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
   D, M, Y      : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   OK  := False;

   Msg := 'Extract data [MYOB format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
            Writeln( XFile, 'TTX1~', clName, 
               '~', Date2Str( FromDate, 'dd/mm/yy' ),
               '~', Date2Str( ToDate, 'dd/mm/yy' ) );
            
            with MyClient.clChart do Begin
               for No := 0 to Pred( ItemCount ) do with Account_At( No )^ do Begin
                  Writeln( XFile, 'AC~', chAccount_Code, '~', chAccount_Description );
               end;
            end;
         
            NoOfEntries := 0;
            JnlNumber   := clLast_Batch_Number;
            if JnlNumber = 0 then
            Begin
               StDateToDMY( FromDate, D, M, Y );
               { yymmddnnn }
               JnlNumber := ( ( Y mod 100 ) * 10000000 ) + 
                            ( M * 100000  ) + 
                            ( D * 1000 );
            end;
            
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
            clLast_Batch_Number := JnlNumber;
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


