unit AccPacx;

(*
   Clive Knauf is the only AccPac user to date.

   For AccPac technical support, our contact is

   AWIE VAN DEN BERG
   MICROCHANNEL
   TEL : 09 - 3029432

Sample Data from Awie:

"H","980825",10
"D","  1000","      ","GLJN","REFERENCE 1 ","980825","DESCRIPTION 1                 ",1000
"D","  1010","      ","GLJN","REFERENCE 2 ","980825","DESCRIPTION 2                 ",-1000

*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses transactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'AccPacX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AccPacWrite( const ADate       : TStDate;
                       const ARefce      : ShortString;
                       const AAccount    : ShortString;
                       const AAmount     : Money;
                       const ANarration  : ShortString );
const
   ThisMethodName = 'AccPacWrite';
Var
   S : ShortString;
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '"D", ' );      { This is an entry }
   S := ReplaceCommasAndQuotes(AAccount); While Length( S )<6 do S := ' '+S;
   Write( XFile, '"', S, '", ' );

   Write( XFile, '"      ", ' ); { No Department Code }
   Write( XFile, '"GLJN", ' );   { Source Code }
   Write( XFile, '"',TrimSpacesS(ReplaceCommasAndQuotes(ARefce)),'", ' ); { Reference }
   Write( XFile, '"', Date2Str( ADate, 'yymmdd' ),  '", ' );
   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 30 then
     ExtractLength := 30;
   Write( XFile, '"', Copy(ReplaceCommasAndQuotes(ANarration), 1, ExtractLength ), '", ' );
   Writeln( XFile, AAmount/100:13:2 );
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
   CC   : string[10];
   D, Y : Integer;
   YSM, TXM, FP : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      Write( XFile, '"H",' );
      Write( XFile, '"', Date2Str( txDate_Effective, 'yymmdd' ), '", ' );
      StDateToDMY( clFinancial_Year_Starts, D, YSM, Y );
      StDateToDMY( txDate_Effective, D, TXM, Y );
      FP := ( TXM-YSM ) + 1;
      If ( FP < 1 ) then Inc( FP, 12 );
      Writeln( XFile, FP ); { Fiscal Period }

      If ( txGST_Class=0 ) then txGST_Amount := 0;

      If ( txFirst_Dissection = NIL ) then
      Begin
         AccPacWrite( txDate_Effective,           { const ADate       : TStDate;      }
                      GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                      txAccount,                  { const AAccount    : ShortString;  }
                      txAmount-txGST_Amount,      { const AAmount     : Money;        }
                       GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)              { const ANarration  : ShortString ) }
                    );

         If txGST_Amount<>0 then
         Begin
            CC := '';
            if txGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ txGST_Class ];

            AccPacWrite( txDate_Effective,           { const ADate       : TStDate;      }
                         GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                         CC,                         { const AAccount    : ShortString;  }
                         txGST_Amount,               { const AAmount     : Money;        }
                          GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)              { const ANarration  : ShortString ) }
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
      AccPacWrite( txDate_Effective,           { const ADate       : TStDate;      }
                   getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ const ARefce      : ShortString;  }
                   dsAccount,                  { const AAccount    : ShortString;  }
                   dsAmount-dsGST_Amount,      { const AAmount     : Money;        }
                   dsGL_Narration                 { const ANarration  : ShortString ) }
                  );

      If dsGST_Amount<>0 then
      Begin
         CC := '';
         if dsGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ dsGST_Class ];
         AccPacWrite( txDate_Effective,           { const ADate       : TStDate;      }
                      getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ const ARefce      : ShortString;  }
                      CC,                         { const AAccount    : ShortString;  }
                      dsGST_Amount,               { const AAmount     : Money;        }
                      dsGL_Narration                 { const ANarration  : ShortString ) }
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
      AccPacWrite( txDate_Effective,           { const ADate       : TStDate;      }
                   GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                   baContra_Account_Code,      { const AAccount    : ShortString;  }
                   -txAmount,                  { const AAmount     : Money;        }
                    GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)              { const ANarration  : ShortString ) }
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
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [AccPac format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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



