unit AttacheBPNZX;

{
   Attach Business Partner

   Used By Clark Accounting Services, contact Mr Bob Clark.

   Attache Dealer is Alan Dew???? Ph 04-527 8542, or 021 422 093.

   Author, SPA 25-05-99
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
   UnitName = 'AttacheBPNZX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   NarrationLength    : Integer;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure BPWrite( ADate        : TStDate;
                   ARefce       : ShortString;
                   AAccount     : ShortString;
                   AAmount      : Money;
                   AGSTClass    : Byte;
                   AGSTAmount   : Money;
                   ANarration   : ShortString );
                   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
{
 Attache uses '.' characters as a delimiter. These are in the chart file that
 we import, but they aren't required by Attache when it imports data, so we
 strip them out as we export
}                   
                   
   Function MakeBPCode( Const OurCode : ShortString ): ShortString;
   Var p : Byte;
   Begin
     Result := '';
     For p := 1 to Length( OurCode ) do
        If OurCode[p]<>'.' then
           Result := Result + OurCode[p];
   end;
   
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   
const
   ThisMethodName = 'AttacheWrite';
Var Nar: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, Date2Str( ADate, 'ddmmyy' ),',' );
   Write( XFile, StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), ',' );
   Write( XFile, Abs( AAmount )/100:0:2, ',' );


   Nar := StStrS.TrimSpacesS(Copy(ReplaceCommasAndQuotes(ANarration), 1, NarrationLength));
   if Nar = '' then
      Nar := ' ';
   Write( XFile, Nar, ',' );


   If AAmount >= 0 then Write( XFile, 'W,' ) else Write( XFile, 'D,' ) ;

   If not AGSTClass in [ 1..MAX_GST_CLASS ] then AGSTAmount := 0;
   
   If AGSTAmount = 0 then Write( XFile, 'E,' ) else Write( XFile, 'I,' ) ;
   
   Write( XFile, Abs( AGSTAmount )/100:0:2, ',' );

   Write( XFile, MakeBPCode(ReplaceCommasandQuotes(AAccount)), ',' );
   
   Write( XFile, Abs( AAmount - AGSTAmount )/100:0:2, ',' );

   Write( XFile, Nar, ',' );

   Writeln( XFile );
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
Var
   S : string[30];
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
         BPWrite( txDate_Effective, { ADate        : TStDate;         }
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
   S : String[ 30];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      BPWrite( txDate_Effective, { ADate        : TStDate;         }
               getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ ARefce       : ShortString;     }
               dsAccount,        { AAccount     : ShortString;     }
               dsAmount,         { AAmount      : Money;           }
               dsGST_Class,      { AGSTClass    : Byte;            }
               dsGST_Amount,     { AGSTAmount   : Money;           }
               S );              { ANarration   : ShortString );   }
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

   Msg := 'Extract data [Attache Business Partner NZ format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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

         if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
         Begin
            HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' + 
            'You must code all the entries before you can extract them.',  0 );
            Exit;
         end;

         NarrationLength := GetMaxNarrationLength;
         if NarrationLength > 30 then
            NarrationLength := 30;

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




