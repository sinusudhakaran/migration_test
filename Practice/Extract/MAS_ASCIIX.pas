unit MAS_ASCIIX;

  !! Not Used 

{
   Author, SPA 07-09-1999

   This is the extract data program for Solution 6 MAS 4 Release 5.0A.

   The data is extracted in the internal MAS5.0 Ledger format.

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
     InfoMoreFrm, S6INI;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'MAS_ASCIIX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   GST_Inclusive : Boolean;
   UsingGST      : Boolean;
   D1, D2        : TstDate;
   Contra        : Money;
   ECount        : Longint;
   EType         : string[4];
   ECashJnlFlag  : string[4];

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Contra  := 0;
   ECount  := 0;
   with Bank_Account.baFields do
   Begin
      EType := '???';
      ECashJnlFlag := '?';
      Case baAccount_Type of
         btBank            : Begin EType := 'BSt'; ECashJnlFlag := ''; end;
         btCashJournals    : Begin EType := 'Jnl'; ECashJnlFlag := 'Y'; end;
         btAccrualJournals : Begin EType := 'Jnl'; ECashJnlFlag := 'N'; end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AWrite(  ADate        : TStDate;
                   ARefce       : ShortString;
                   AAccount     : ShortString;
                   AAmount      : Money;
                   AQuantity    : Money;
                   ANarration   : ShortString;
                   AContra      : ShortString );

const
   ThisMethodName = 'AWrite';
   Sep = ':';

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   function RemoveFS( S : ShortString ): ShortString;
   Var i : Byte;
   Begin
      Result := S;
      For i := 1 to Length( S ) do If Result[i]=Sep then Result[i] := ';';
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   write( XFile, Date2Str( ADate, 'dd/mm/yyyy' ), Sep );
   Write( XFile, EType , Sep );
   write( XFile, Sep ); { No Group }
   Write( XFile, ARefce, Sep );
   Write( XFile, AAccount, Sep );
   Write( XFile, AAmount/100:0:2, Sep );
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, GetQuantityStringForExtract(AQuantity), Sep )
   else
     write( XFile, GetQuantityStringForExtract(0), Sep );
   write( XFile, Copy(RemoveFS( ANarration ), 1, GetMaxNarrationLength), Sep );
   write( XFile, AContra, Sep );
   write( XFile, ECashJnlFlag ); { No Cash Jnl Flag }
   writeln( XFile );

   Contra := Contra + AAmount;
   Inc( ECount );
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Var
  S         : String[80];
  Refce     : ShortString;
  Narration : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         If ( txCheque_Number = 0 ) then
            S := ''
         else
         Begin
            Str( txCheque_Number, S );
            While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
            While ( Length( S )<6 ) do S:=' '+S;
         end;
         Refce := S;
         
         Case clCountry of
            whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : S := txOld_Narration;
         end;
         Narration := S;

         If ( txGST_Class=0 ) then txGST_Amount := 0;

         if GST_Inclusive then
         Begin
            AWrite(  txDate_Effective,
                     Refce,
                     txAccount,
                     txAmount,
                     txQuantity,
                     Narration,
                     baContra_Account_Code );
         end
         else
         Begin
            AWrite(  txDate_Effective,
                     Refce,
                     txAccount,
                     txAmount - txGST_Amount,
                     txQuantity,
                     Narration,
                     baContra_Account_Code );

            if ( txGST_Amount<>0 ) then
            Begin
               AWrite(  txDate_Effective,
                        '',
                        clGST_Account_Codes[ txGST_Class ],
                        txGST_Amount,
                        0, 
                        Narration,
                        baContra_Account_Code );
            end;
         end;
      end;
      Inc ( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
Var 
   S         : String[80];
   Refce     : ShortString;
   Narration : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      If ( txCheque_Number = 0 ) then
         S := ''
      else
      Begin
         Str( txCheque_Number, S );
         While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
         While ( Length( S )<6 ) do S:=' '+S;
      end;
      Refce := S;
      
      if ( dsNarration<> '' ) then 
         Narration := dsNarration
      else
      Begin
         Case clCountry of
            whNewZealand : Narration := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : Narration :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         end;
      end;      
      
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;

      if GST_Inclusive then
      Begin
         AWrite(  txDate_Effective,
                  Refce, 
                  dsAccount,
                  dsAmount,
                  dsQuantity,
                  Narration,
                  baContra_Account_Code );
      end
      else
      Begin
         AWrite(  txDate_Effective,
                  Refce, 
                  dsAccount,
                  dsAmount - dsGST_Amount,
                  dsQuantity,
                  Narration,
                  baContra_Account_Code );

         if ( dsGST_Amount<>0 ) then
         Begin
            AWrite(  txDate_Effective,
                     '', 
                     clGST_Account_Codes[ txGST_Class ],
                     dsGST_Amount,
                     0, 
                     Narration,
                     baContra_Account_Code );
         end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountTrailer;
const
   ThisMethodName = 'DoAccountTrailer';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With Bank_Account.baFields do
   Begin
      if ( Contra <> 0 ) or ( ECount > 0 ) then
      Begin
         AWrite(  D2,
                  '', 
                  baContra_Account_Code,
                  -Contra,
                  0, 
                  'Contra Total',
                  '' );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
var
   GI           : Boolean;
   Msg          : String; 
   Selected     : TStringList;
   No           : Integer;
   ti           : Integer;
   M1, Y1       : Integer;
   M,Y          : Integer;
   BA           : TBank_Account;
   L            : ShortString;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [MAS ASCII format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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

         UsingGST := False;
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            UsingGST := UsingGST or TravUtils.HasAnyGST( BA, FromDate, ToDate );
         end;

         GI := Globals.PRACINI_REMOVEGST; { Usually FALSE }
         If UsingGST and Globals.PRACINI_PromptForGST then
         Begin
            Case GI of
               TRUE  :  GI := ( AskYesNo('GST Inclusive?','Do you want to transfer the entries GST INCLUSIVE?',
                                DLG_YES,0) = DLG_YES);

               FALSE :  GI := ( AskYesNo('GST Inclusive?','Do you want to transfer the entries GST INCLUSIVE?',
                                            DLG_NO,0) = DLG_YES);
            end;
         end;
         GST_Inclusive := GI;

         if ( not GST_Inclusive ) then
         begin { We will be creating entries for the GST Totals, so we need to check that the GST contra accounts exist }
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
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
            L := 'BankLink data for '+MyClient.clFields.clCode+' from '+
                  Date2Str( FromDate, 'dd/nnn/yyyy' ) + ' to '+Date2Str( ToDate, 'dd/nnn/yyyy' );
            Writeln( XFile, L );
            
            NoOfEntries := 0;

            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
               M := M1; Y := Y1;
               Repeat
                  D1 := DMYToStDate( 1, M, Y, Epoch );
                  If D1<FromDate then D1 := FromDate;
                  D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
                  If D2 > ToDate then D2 := ToDate;

                  TRAVERSE.Clear;
                  TRAVERSE.SetSortMethod( csDateEffective );
                  TRAVERSE.SetSelectionMethod( twAllNewEntries );
                  TRAVERSE.SetOnAHProc( DoAccountHeader );
                  TRAVERSE.SetOnEHProc( DoTransaction );
                  TRAVERSE.SetOnDSProc( DoDissection );
                  TRAVERSE.SetOnATProc( DoAccountTrailer );
                  TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

                  Inc( M ); If M>12 then Begin M:= 1; Inc( Y ); end;
               Until ( D2 = ToDate );
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


