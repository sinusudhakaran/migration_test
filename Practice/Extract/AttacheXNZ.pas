unit AttacheXNZ;

{
   Author, SPA 25-05-99

   Max narration extract length = 30
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
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'AttacheXNZ';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AttacheWrite(  ADate        : TStDate;
                         ARefce       : ShortString;
                         AAccount     : ShortString;
                         AAmount      : Money;
                         AGSTClass    : Byte;
                         AGSTAmount   : Money;
                         ANarration   : ShortString );
const
   ThisMethodName = 'AttacheWrite';
Var   
   GrossAmt : Money;
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '"',bkDateUtils.Date2Str( ADate, 'ddmmyy' ),'",' );
   Write( XFile, '"',StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), '",' );

   with MyClient.clChart do 
   Begin
      if CodeIsThere( AAccount ) then
         Write( XFile, '"',ReplaceCommasAndQuotes(AAccount), '",' )
      else
         Write( XFile, '"?",' );
   end;

   If not AGSTClass in [ 1..MAX_GST_CLASS ] then AGSTAmount := 0;

   GrossAmt := AAmount - AGSTAmount;
   write( XFile, Abs( GrossAmt )/100:0:2, ',' );
   write( XFile, Abs( AGSTAmount )/100:0:2, ',' );
   If AAmount >= 0 then Write( XFile, 'D,' ) else Write( XFile, 'C,' ) ;
   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 30 then
     ExtractLength := 30;
   Writeln( XFile, '"', Copy(StStrS.TrimSpacesS( ReplaceCommasAndQuotes(ANarration)), 1, ExtractLength), '"' );
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
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
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);
      
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         AttacheWrite( txDate_Effective, { ADate        : TStDate;         }
                       GetReference(TransAction,Bank_Account.baFields.baAccount_Type),      { ARefce       : ShortString;     }
                       txAccount,        { AAccount     : ShortString;     }
                       txAmount,         { AAmount      : Money;           }
                       txGST_Class,      { AGSTClass    : Byte;            }
                       txGST_Amount,     { AGSTAmount   : Money;           }
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
   S : shortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      AttacheWrite( txDate_Effective, { ADate        : TStDate;         }
                    getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),      { ARefce       : ShortString;     }
                    dsAccount,        { AAccount     : ShortString;     }
                    dsAmount,         { AAmount      : Money;           }
                    dsGST_Class,      { AGSTClass    : Byte;            }
                    dsGST_Amount,     { AGSTAmount   : Money;           }
                    S);               { ANarration   : ShortString );   }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';
  
VAR
   BA           : TBank_Account;
   Msg          : String; 
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Attache NZ format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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



