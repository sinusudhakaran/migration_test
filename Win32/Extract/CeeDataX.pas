unit CeeDataX;

(*
  This is the current Cee Data format
*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs, StStrS, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'CeeDataX';
   DebugMe  : Boolean = False;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : Longint;
   CrValue       : Money;
   DrValue       : Money;
   ValTrx        : Money;
   NoTrx         : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CDWrite( const ADate       : TStDate;
                   const AType       : Byte;
                   const ARefce      : ShortString;
                   const AAccount    : ShortString;
                   const AAmount     : Money;
                   const ANarration  : ShortString );
const
   ThisMethodName = 'CDWrite';
Var
   S : ShortString;   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Write( XFile, 'B,' );

   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yy' ), '",' );

   Write( XFile, AType, ',' );

   Write( XFile, '"",' ); { txAnalysis Field }

   S := StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce));
   While ( Length( S )>7 ) do Delete( S, 1, 1 ); // 20-Jun-2000 Reference is now truncated in BTM.
   Write( XFile, '"', S, '",' );
   
   Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );
   write( XFile, AAmount/100:0:2, ',' );
   Writeln( XFile, '"',Copy(StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ANarration)), 1, GetMaxNarrationLength),'"' );
   
   ValTrx   := ValTrx + AAmount;
   If AAmount<0 then
      CrValue  := CrValue  +  AAmount
   else
      DrValue  := DrValue  +  AAmount;
   Inc( NoTrx );
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   with Bank_Account.baFields do
   Begin
      Writeln( XFile,
               'A,',
               '"',  StripM(Bank_Account), '",',
               '"',  baBank_Account_Name,   '",',
               '"',  ''                    ,'"' ); { Was aFile }
   end;
   CrValue  := 0;
   DrValue  := 0;
   ValTrx   := 0;
   NoTrx    := 0;
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
         If ( txGST_Class=0 ) then txGST_Amount := 0;
         CDWrite( txDate_Effective,           { const ADate       : TStDate;       }
                  txType,                     { const AType       : Byte;          }
                  GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;   }
                  txAccount,                  { const AAccount    : ShortString;   }
                  txAmount - txGST_Amount,    { const AAmount     : Money;         }
                   GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)                 { const ANarration  : ShortString ); }
                 );

         If txGST_Amount<>0 then 
         Begin
            CDWrite( txDate_Effective,           { const ADate       : TStDate;      }
                     txType,
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { const ARefce      : ShortString;  }
                     clGST_Account_Codes[ txGST_Class ],
                     txGST_Amount,               { const AAmount     : Money;        }
                      GetNarration(TransAction,Bank_Account.baFields.baAccount_Type)                 { const ANarration  : ShortString ) }
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
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Transaction^, Dissection^ do
   Begin
      CDWrite( txDate_Effective,   { const ADate       : TStDate;       }
               txType,             { const AType       : Byte;          }
               getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),        { const ARefce      : ShortString;   }
               dsAccount,          { const AAccount    : ShortString;   }
               dsAmount-dsGST_Amount, { const AAmount     : Money;         }
               dsGL_Narration         { const ANarration  : ShortString ); }
              );
   
         If ( dsGST_Class=0 ) then dsGST_Amount := 0;
         
         If dsGST_Amount<>0 then 
         Begin
            CDWrite( txDate_Effective,           { const ADate       : TStDate;      }
                     txType,
                     getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type), { const ARefce      : ShortString;  }
                     clGST_Account_Codes[ dsGST_Class ],
                     dsGST_Amount,               { const AAmount     : Money;        }
                     dsGL_Narration                 { const ANarration  : ShortString ) }
                   );
         end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountTrailer;

const
   ThisMethodName = 'DoAccountTrailer';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Write( XFile,  'C,', NoTrx, ',' );
   Write( XFile, DrValue/100:0:2, ',' );
   Write( XFile, CrValue/100:0:2, ',' );
   Writeln( XFile, ValTrx/100:0:2 );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate );

const
   ThisMethodName = 'ExtractData';
var
   Msg          : String; 
   BA           : TBank_Account;
   OK           : Boolean;
   FileName     : ShortString;
   i, c         : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Cee Data format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
   If BA = NIL then exit;

   with BA.baFields do
   Begin
      if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
      Begin
         HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
         exit;
      end;

      if not TravUtils.HasRequiredGSTContraCodes( BA, FromDate, ToDate  ) then
      Begin
         HelpfulInfoMsg( 'Before you can extract these entries, you must specify the control account for each GST Class.' + 
                         ' To do this, go to the Other Functions|GST Details and Rates option.', 0 );
         exit;
      end;
      
//      if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
//      Begin
//         HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' + 
//         'You must code all the entries before you can extract them.',  0 );
//         Exit;
//      end;

      FileName := '';
      
      c := 0;
      for i := Length( baBank_Account_Number ) downto 0 do
      Begin
         if ( UpCase( baBank_Account_Number[i] ) in [ '0'..'9', 'A'..'Z' ] ) then
         Begin
            Inc( c );
            if c <= 8 then FileName := UpCase( baBank_Account_Number[i] ) + FileName;
         end;
      end;
      if ( FileName = '' ) then 
         FileName := DATADIR + 'CEEDATA.TXT'
      else
         FileName := DATADIR + FileName + '.TXT';

      Assign( XFile, FileName );
      SetTextBuf( XFile, Buffer );
      Rewrite( XFile );
      Try
         // Write a file header for the GET4CEE.EXE to find
         Writeln( XFile, StripM(BA) );
         Writeln( XFile, BkDate2Str( FromDate ) );
         Writeln( XFile, BKDate2Str( ToDate ) );
         NoOfEntries := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.SetOnATProc( DoAccountTrailer );
         TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
         Writeln( XFile, 'X, End of File' );
         OK := True;
      finally            
         System.Close( XFile );
      end;

      if OK then
      Begin
         Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, FileName ] );
         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulInfoMsg( Msg, 0 );
      end;
   end; { Scope of BA.baFields }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.



