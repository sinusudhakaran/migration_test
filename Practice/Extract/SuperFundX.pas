//------------------------------------------------------------------------------
//
// SuperFundX
//
// This is the extract data program for Solution 6 Superfund.
//
// Author        Date        Version Description
// Michael Foot  26/03/2003  1.00    Initial version
//
//
//------------------------------------------------------------------------------
unit SuperFundX;

!! Not used, superfund uses the generic format for refresh/extract

interface

uses
  StDate;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

implementation

uses
  Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
  LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
  InfoMoreFrm, S6INI, glConst, ErrorMoreFrm;

const
  UnitName = 'SuperFundX';
  DebugMe  : Boolean = False;

var
  XFile             : Text;
  Buffer            : array[ 1..2048 ] of Byte;
  NoOfEntries       : LongInt;
  RecordNumber      : LongInt;
  LastEffectiveDate : TStDate;
  CSVLines          : TStringList;
  LedgerBalance, AvailableBalance : Money;
  DebitTotal, CreditTotal : Money;

procedure CSVWrite(	 ADate        : TStDate;
                     AAccountNumber : ShortString;
                     AAmount      : Money;
                     ANarration   : ShortString;
                     ARefce       : ShortString;
                     AClientCode  : ShortString;
                     AAccount     : ShortString );
const
  ThisMethodName = 'CSVWrite';
var
  i : Integer;
  S, LB0, LB1{, AB0, AB1} : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if (ADate <> LastEffectiveDate) then
  begin
    //write out csvlist
    for i := 0 to CSVLines.Count-1 do
    begin
      if (AvailableBalance < 0) then
        LB0 := '-'
      else
        LB0 := ' ';
      LB1 := FormatFloat( '0.00', Abs(LedgerBalance/100));
      WriteLn( XFile, Format(CSVLines[i], [LB0, LB1]));
    end;

    CSVLines.Clear;
    LedgerBalance := 0;
    AvailableBalance := 0;
    LastEffectiveDate := ADate;
  end;

  LedgerBalance := LedgerBalance + AAmount;
  //AvailableBalance := AvailableBalance +

  Inc(RecordNumber);

  S := 'CM,';//record type
  S := S + Date2Str( ADate, 'mm/dd/yyyy' ) + ','; //transaction date
  S := S + '"' + ReplaceCommasAndQuotes(AAccountNumber) + '",'; //client account number
  if (AAmount < 0) then
  begin
    DebitTotal := DebitTotal + AAmount;
    S := S + '"D",' //debit
  end else
  begin
    CreditTotal := CreditTotal + AAmount;
    S := S + '"C",'; //credit
  end;
  S := S + FormatFloat('0.00', Abs(AAmount)/100) + ','; //amount (absolute value)
  S := S + '"  ",'; //transaction code
  S := S + '"' + Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength) + '",'; //narration
  S := S + '%s%s,'; //ledger balance
  S := S + '0.00,'; //available balance
  S := S + '"' + ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ARefce )) + '",'; //reference
  S := S + '"' + ReplaceCommasAndQuotes(AClientCode) + '",'; //client id
  S := S + '"' + ReplaceCommasAndQuotes(AAccount) + '",'; //account name
  S := S + IntToStr(RecordNumber); //row number}
  CSVLines.Add(S);

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
  S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      Inc( NoOfEntries );
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         If ( txGST_Class=0 ) then txGST_Amount := 0;

         CSVWrite( txDate_Effective, //ADate : TStDate;
                   baBank_Account_Number,
                   txAmount, //AAmount : Money;
                   S, //ANarration	: ShortString;
                   GetReference(TransAction,Bank_Account.baFields.baAccount_Type), //ARefce : ShortString;
                   clCode, //client id
                   baBank_Account_Name);
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
var
   s : ShortSTring;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      CSVWrite( txDate_Effective, //ADate : TStDate;
                baBank_Account_Number,
                txAmount,  //AAmount : Money;
                S,         //ANarration	: ShortString;
                getDsctReference(Dissection,Transaction), //ARefce : ShortString;
                clCode,   //client id
                baBank_Account_Name);

   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
  ThisMethodName = 'ExtractData';
var
  BA : TBank_Account;
  Msg, Filename : String;
  SDate, STime, SCode : String;
  No : Integer;
  Selected : TStringList;
  OK : Boolean;
  i : Integer;
  LB0, LB1 : String;
  Dir : string;
  CMFilename : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [BK5 SuperFund format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );

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
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                     baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;
            end;
         end;

         //add slash to end unless save to is blank
         Dir := AddSlash( SaveTo);

         //format the date time stamp and client code as required by spec
         SCode := FormatDateTime('yyyymmdd',Now) + ' ' + Copy(MyClient.clFields.clCode,1,6) + '.CSV';

         //check for the existance of another CM file
         CMFilename := Dir + 'CM' + SCode;
         if (BKFileExists(CMFilename)) then
           OK := (AskYesNo('Overwrite File','The file ' + ExtractFileName( CMFilename) +
                 ' already exists. Overwrite?',dlg_yes,0) = DLG_YES)
         else
           OK := True;

         if (OK) then
         begin
           SDate := FormatDateTime('mm/dd/yyyy',Now);
           STime := FormatDateTime('hh:mm:ss', Now);
           try
             //write out PT record
             Filename := Dir + 'PT' + SCode;
             Assign( XFile, Filename );
             SetTextBuf( XFile, Buffer );
             Rewrite( XFile );
             try
               Write( XFile, 'HR', ',' );
               Write( XFile, SDate, ',');
               Write( XFile, STime, ',');
               WriteLn( XFile, 'PT');
               Write( XFile, 'TL', ',' );
               WriteLn( XFile, '2');  //header + footer + number of entries
             finally
               System.Close( XFile );
             end;

             //write out IN record
             Filename := Dir + 'IN' + SCode;
             Assign( XFile, Filename );
             SetTextBuf( XFile, Buffer );
             Rewrite( XFile );
             try
               Write( XFile, 'HR', ',' );
               Write( XFile, SDate, ',');
               Write( XFile, STime, ',');
               WriteLn( XFile, 'IT');
               Write( XFile, 'TL', ',' );
               WriteLn( XFile, '2');  //header + footer + number of entries
             finally
               System.Close( XFile );
             end;

             //write out CM record
             Filename := Dir + 'CM' + SCode;
             Assign( XFile, Filename );
             SetTextBuf( XFile, Buffer );
             Rewrite( XFile );

             try
               //Cash management account transaction header
               Write( XFile, 'HR', ',' );
               Write( XFile, SDate, ',');
               Write( XFile, STime, ',');
               WriteLn( XFile, 'CM');

               CSVLines := TStringList.Create;
               try
                 LastEffectiveDate := 0; //effective date of last transaction
                 LedgerBalance := 0;
                 AvailableBalance := 0;
                 DebitTotal := 0;
                 CreditTotal := 0;

                 NoOfEntries := 0;
                 RecordNumber := 0;

                 for No := 0 to Pred( Selected.Count ) do
                 Begin
                   BA := TBank_Account( Selected.Objects[ No ] );
                   TRAVERSE.Clear;
                   TRAVERSE.SetSortMethod( csDateEffective );
                   TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
                   TRAVERSE.SetOnAHProc( DoAccountHeader );
                   TRAVERSE.SetOnEHProc( DoTransaction );
                   TRAVERSE.SetOnDSProc( DoDissection );
                   TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
                 end;
                 //write out csvlist
                 for i := 0 to CSVLines.Count-1 do
                 begin
                   if (AvailableBalance < 0) then
                     LB0 := '-'
                   else
                     LB0 := ' ';
                   LB1 := FormatFloat( '0.00', LedgerBalance/100);
                   WriteLn( XFile, Format(CSVLines[i], [LB0, LB1]));
                 end;
               finally
                 CSVLines.Free;
               end;

               //Cash management account transaction footer
               Write( XFile, 'TL', ',' );
               Write( XFile, RecordNumber+2, ',');  //header + footer + number of entries
               LB1 := FormatFloat( '0.00', Abs(DebitTotal/100));
               Write( XFile, LB1, ',');
               LB1 := FormatFloat( '0.00', CreditTotal/100);
               WriteLn( XFile, LB1);

             finally
               System.Close( XFile );
             end;
           except
             on E: EInOutError do
             begin
               HelpfulErrorMsg('Extract failed.',0, True, E.Message + ' - ' + Filename, True);
             end;
           end;
           Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, CMFilename ] );
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
