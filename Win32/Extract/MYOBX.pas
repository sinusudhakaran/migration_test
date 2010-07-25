unit MYOBX;

(*
   H&R Block Australia

   For MYOB technical support, our contact is

   Alan Brewer
   Datatech
   Auckland

   Ph 443 4497
   Fax 443 4026

Sample Data:

JNL Number,Date,Desc,Account,DR,CR,Job
1000000,8/09/98,Bank Account Contra,1-1110,,100,
1000000,8/09/98,Advertising,6-1000,100,,

2000000,8/09/98,Bank Account Contra,1-1110,,506.25,
2000000,8/09/98,Freight,6-1700,506.25,,

3000000,8/09/98,Bank Account Contra,1-1110,1000.33,,
3000000,8/09/98,Sales,4-1000,,1000.33,

*)


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
   UnitName = 'MYOBX';
   DebugMe  : Boolean = False;
   Tab      : char = #09;
   

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   JnlNumber     : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure MYOBWrite( const ADate       : TStDate;
                     const ARefce      : ShortString;
                     const AAccount    : ShortString;
                     const AAmount     : Money;
                     const ANarration  : ShortString );
const
   ThisMethodName = 'MYOBWrite';
Var
   S, S1, S2 : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, JnlNumber, Tab );
   Write( XFile, Date2Str( ADate, 'dd/mm/yyyy' ), Tab );

   S1 := ARefce;
   S2 := ANarration;
   S2 := Copy(S2, 1, GetMaxNarrationLength);
   S := S1;
   If S2<>'' then
      If S = '' then
         S := S2
      else
         S := S + ' ' + S2;
   Write( XFile, S, Tab );
   Write( XFile, AAccount, Tab );
   If AAmount >= 0 then
      Write( XFile, AAmount/100.0:0:2, Tab, Tab )
   else
      Write( XFile, Tab, Abs( AAmount )/100.0:0:2, Tab );
   Writeln( XFile, Tab );

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

      Inc( JnlNumber );
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         If ( txGST_Class=0 ) then txGST_Amount := 0;

         MYOBWrite( txDate_Effective,           { const ADate       : TStDate;      }
                    GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                    txAccount,                  { const AAccount    : ShortString;  }
                    txAmount-txGST_Amount,      { const AAmount     : Money;        }
                    S                           { const ANarration  : ShortString ) }
                  );

         If txGST_Amount<>0 then
         Begin
            CC := '';
            if txGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ txGST_Class ];

            MYOBWrite( txDate_Effective,           { const ADate       : TStDate;      }
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
   S  : string[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Transaction^, Dissection^ do
   Begin
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      S := dsGL_Narration;

      MYOBWrite( txDate_Effective,           { const ADate       : TStDate;      }
                 getDsctReference(Dissection,Transaction, Bank_Account.baFields.baAccount_Type),
                                             { const ARefce      : ShortString;  }
                 dsAccount,                  { const AAccount    : ShortString;  }
                 dsAmount-dsGST_Amount,      { const AAmount     : Money;        }
                 S                           { const ANarration  : ShortString ) }
                );

      If dsGST_Amount<>0 then
      Begin
         CC := '';
         if dsGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ dsGST_Class ];
         MYOBWrite( txDate_Effective,           { const ADate       : TStDate;      }
                    getDsctReference(Dissection,Transaction,Bank_Account.baFields.baAccount_Type ),
                                                { const ARefce      : ShortString;  }
                    CC,                         { const AAccount    : ShortString;  }
                    dsGST_Amount,               { const AAmount     : Money;        }
                    S                           { const ANarration  : ShortString ) }
                   );

      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoContra;

const
   ThisMethodName = 'DoContra';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      MYOBWrite( txDate_Effective,           { const ADate       : TStDate;      }
                 '',                         { const ARefce      : ShortString;  }
                 baContra_Account_Code,      { const AAccount    : ShortString;  }
                 -txAmount,                  { const AAmount     : Money;        }
                 'Bank Contra'               { const ANarration  : ShortString ) }
                  );

      Writeln( XFile );
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
            NoOfEntries := 0;
            JnlNumber   := clLast_Batch_Number;
            
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


