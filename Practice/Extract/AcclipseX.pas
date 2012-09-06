unit AcclipseX;
// Copied and modified from MYOBAOX

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, CAUtils, BKDefs, glConst, MYOBAOX_bcLink, Software, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'AcclipseX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   Contra        : Money;
   CrValue       : Money;
   DrValue       : Money;
   SPCD          : LongInt;
   TotalAmount   : Money;
   TotalGST      : Money;
   TotalQty      : Money;
   ECount        : Longint;

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
  S : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         { BNK_PRFX }      Write( XFile, 'B,' );
         { EXT_CDATE}      Write( XFile, '"',Date2Str( txDate_Effective, 'dd/mm/yy' ), '",' );
         { BNK_TTYPE}      Write( XFile, txType, ',' );

                           if Trim( GetReference(TransAction,Bank_Account.baFields.baAccount_Type)) = '' then
                             Write( XFile, '"0",')
                           else
         { EXT_REF}          Write( XFile, '"', ReplaceCommasAndQuotes(GetReference(TransAction,Bank_Account.baFields.baAccount_Type)), '",' );

         { EXT_ACCNO}      Write( XFile, '"', ReplaceCommasAndQuotes(txAccount), '",' );

         { EXT_AMT }       Write( XFile, txAmount/100:0:2, ',' );

         { EXT_DESC }      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
                           S := Copy(ReplaceCommasAndQuotes(S), 1, GetMaxNarrationLength);
                           Write( XFile, '"',S,'"' );

         { EXT_DATE }      Write( XFile, ',' );

                           if (Globals.PRACINI_ExtractQuantity) then
         { EXT_QTY }         Write( XFile, txQuantity/10000:0:0, ',' )
                           else
         { EXT_QTY }         Write( XFile, 0.0:0:0, ',' );

         { EXT_GSTAMT }    if not ( txGST_Class in [ 1..MAX_GST_CLASS ] ) then
                              write( XFile, '0.00,"",' ) { No GST }
                           else
                           begin
                              write( XFile, txGST_Amount/100:0:2, ',' );
         { EXT_GSTACC }       write( XFile, '"', Copy( clGST_Class_Codes[ txGST_Class ],1,GST_CLASS_CODE_LENGTH), '",' );
                           end;

         { EXT_GSTDNE }    Write( XFile, ',' );
         { EXT_BCHTYP }    Write( XFile, ',' );
         { EXT_UPDT }      Write( XFile, ',' );
         { EXT_PERD }      Write( XFile, ',' );
         { EXT_OPEN }      Write( XFile, ',' );
         { EXT_ETYPE }     Write( XFile, ',' );
         { EXT_SPCD }      Write( XFile, '0,' );
         { EXT_ACPART }    Write( XFile, ',' );
         { EXT_SBPART }    Write( XFile, ',' );

         Writeln( XFile );
         Inc( ECount );
      end
      else
      Begin { It is dissected }
         Inc( SPCD );
         TotalAmount := 0;
         TotalGST    := 0;
         TotalQty    := 0;
      end;

      Contra := Contra + txAmount;
      If txAmount<0 then
         CrValue:=CrValue + txAmount
      else
         DrValue:=DrValue + txAmount;

      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
Var
  S : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      { BNK_PRFX }      Write( XFile, 'B,' );
      { EXT_CDATE}      Write( XFile, '"', bkDateUtils.Date2Str( txDate_Effective, 'dd/mm/yy' ), '",' );
      { BNK_TTYPE}      Write( XFile, txType, ',' );
                        s := Trim(getDsctReference(Dissection,Transaction,baAccount_Type));
                        if s = '' then
                          Write( XFile, '"0",')
                        else
      { EXT_REF}          Write( XFile, '"', ReplaceCommasAndQuotes(s), '",' );

      { EXT_ACCNO}      Write( XFile, '"', ReplaceCommasAndQuotes(dsAccount), '",' );

      { EXT_AMT }       Write( XFile, dsAmount/100:0:2, ',' );

      { EXT_DESC }      S := dsGL_Narration;
                        Write( XFile, '"',Copy(ReplaceCommasAndQuotes(S), 1, GetMaxNarrationLength),'"' );

      { EXT_DATE }      Write( XFile, ',' );

                        if (Globals.PRACINI_ExtractQuantity) then
      { EXT_QTY }         Write( XFile, dsQuantity/10000:0:0, ',' )
                        else
      { EXT_QTY }         Write( XFile, 0.0:0:0, ',' );

      { EXT_GSTAMT }    if not ( dsGST_Class in [ 1..MAX_GST_CLASS ] ) then
                           write( XFile, '0.00,"",' ) { No GST }
                        else
                        begin
                           write( XFile, dsGST_Amount/100:0:2, ',' );
      { EXT_GSTACC }       write( XFile, '"', Copy( clGST_Class_Codes[ dsGST_Class ],1,GST_CLASS_CODE_LENGTH), '",' );
                        end;

      { EXT_GSTDNE }    Write( XFile, ',' );
      { EXT_BCHTYP }    Write( XFile, ',' );
      { EXT_UPDT }      Write( XFile, ',' );
      { EXT_PERD }      Write( XFile, ',' );
      { EXT_OPEN }      Write( XFile, ',' );
      { EXT_ETYPE }     Write( XFile, '"S",' );
      { EXT_SPCD }      Write( XFile, SPCD, ',' );
      { EXT_ACPART }    Write( XFile, ',' );
      { EXT_SBPART }    Write( XFile, ',' );

      Writeln( XFile );
      Inc( ECount );

      TotalAmount := TotalAmount + dsAmount;
      TotalQty    := TotalQty    + dsQuantity;
      TotalGST    := TotalGST    + dsGST_Amount;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransactionTrailer ; FAR;

const
   ThisMethodName = 'DoTransactionTrailer';
Var
   S : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   with MyClient.clfields, Transaction^ do
   Begin
      If ( txFirst_Dissection<>nil ) then
      Begin
         { BNK_PRFX }      Write( XFile, 'B,' );
         { EXT_CDATE}      Write( XFile, '"',Date2Str( txDate_Effective, 'dd/mm/yy' ), '",' );
         { BNK_TTYPE}      Write( XFile, txType, ',' );

                           if Trim( txReference) = '' then
                             Write( XFile, '"0",')
                           else
           { EXT_REF}        Write( XFile, '"', ReplaceCommasAndQuotes(txReference), '",' );

         { EXT_ACCNO}      Write( XFile, '"",' );

         { EXT_AMT }       Write( XFile, TotalAmount/100:0:2, ',' );

         { EXT_DESC }      S := GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
                           S := Copy(ReplaceCommasAndQuotes(S), 1, GetMaxNarrationLength);
                           Write( XFile, '"',S,'"' );

         { EXT_DATE }      Write( XFile, ',' );

                           if (Globals.PRACINI_ExtractQuantity) then
         { EXT_QTY }         Write( XFile, TotalQty/10000:0:0, ',' )
                           else
         { EXT_QTY }         Write( XFile, 0.0:0:0, ',' );

         { EXT_GSTAMT }    Write( XFile, TotalGST/100:0:2, ',' );

         { EXT_GSTACC }    Write( XFile, '"",' );

         { EXT_GSTDNE }    Write( XFile, ',' );
         { EXT_BCHTYP }    Write( XFile, ',' );
         { EXT_UPDT }      Write( XFile, ',' );
         { EXT_PERD }      Write( XFile, ',' );
         { EXT_OPEN }      Write( XFile, ',' );
         { EXT_ETYPE }     Write( XFile, '"M",' );
         { EXT_SPCD }      Write( XFile, SPCD, ',' );
         { EXT_ACPART }    Write( XFile, ',' );
         { EXT_SBPART }    Write( XFile, ',' );

         Writeln( XFile );
         Inc( ECount );

      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractDataStd( const FromDate, ToDate : TStDate; const SaveTo : string );

VAR
   BA : TBank_Account;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   Procedure ExportPeriod( D1, D2 : TStDate );
   const
      ThisMethodName = 'ExportPeriod';
   Var
      Amount : Money;

   Begin { ExportPeriod }
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

      With MyClient, BA.baFields do
      Begin
         Contra := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.SetOnETProc( DoTransactionTrailer );
         TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

         Amount := -Contra;

         { BNK_PRFX }      Write( XFile, 'B,' );
         { EXT_CDATE}      Write( XFile, '"',Date2Str( D2, 'dd/mm/yy' ), '",' );
         { BNK_TTYPE}      Write( XFile, '100,' );
         { EXT_REF}        Write( XFile, '"0",' );
         { EXT_ACCNO}      Write( XFile, '"', baContra_Account_Code, '",' );
         { EXT_AMT }       Write( XFile, Amount/100:0:2, ',' );
         { EXT_DESC }      Write( XFile, '"Bank Account Contra"' );
         { EXT_DATE }      Write( XFile, ',' );
         { EXT_QTY }       Write( XFile, '0,' );
         { EXT_GSTAMT }    Write( XFile, '0.00,' );
         { EXT_GSTACC }    Write( XFile, '"E",' );
         { EXT_GSTDNE }    Write( XFile, ',' );
         { EXT_BCHTYP }    Write( XFile, ',' );
         { EXT_UPDT }      Write( XFile, ',' );
         { EXT_PERD }      Write( XFile, ',' );
         { EXT_OPEN }      Write( XFile, ',' );
         { EXT_ETYPE }     Write( XFile, ',' );
         { EXT_SPCD }      Write( XFile, '0,' );
         { EXT_ACPART }    Write( XFile, ',' );
         { EXT_SBPART }    Write( XFile, ',' );

         Writeln( XFile );
         Inc( ECount );
         
         If Amount<0 then
            CrValue:=CrValue + Amount
         else
            DrValue:=DrValue + Amount;
      end;
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   ThisMethodName = 'ExtractData';
   
var
   Msg          : String; 
   Selected     : TStringList;
   HasUncodes   : Boolean;
   No           : Integer;
   ti           : Integer;
   D1, D2       : TStDate;
   M1, Y1       : Integer;
   M,Y          : Integer;
   OK           : Boolean;
   sAccountNo   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [CCH format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      with MyClient.clFields do
      begin
         //check for uncode entries
         HasUncodes := False;
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            HasUncodes := HasUncodes or not TravUtils.AllCoded( BA, FromDate, ToDate );
         end;

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
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account ' +
                                  'code for bank account "' + baBank_Account_Number +
                                  '". To do this, go to the Other Functions|Bank Accounts option and edit ' +
                                  'the account', 0 );
                  exit;
               end;

               if not HasUncodes then
               Begin
                  TRAVERSE.Clear;
                  TRAVERSE.SetSortMethod( csDateEffective );
                  TRAVERSE.SetSelectionMethod( twAllNewEntries );
                  TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
               end;
            end;
         end;
         
         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
      
         Try
            { Write the identification information so BKCASYS.EXE can validate
              the information CA-Systems sends... }

            Writeln( XFile, clCode );
            Writeln( XFile, bkDate2Str( FromDate ) );
            Writeln( XFile, bkDate2Str( ToDate ) );
            if HasUncodes then
               Writeln( XFile, 'U' )
            else
               Writeln( XFile, 'V4' );

            { - - - - - - - - - - - - - - - -  }
         
            NoOfEntries := 0;
            SPCD := 0;

            { - - - - - - - - - - - - - - - -  }

            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );

               sAccountNo := Uppercase( StripM(Ba));
               //see if we need to strip the alpha characters
               //from bank accounts
               if BA.baFields.baAccount_Type = btBank then
               begin
                 if PRACINI_MYOBStripAlpha then
                   sAccountNo := StripAlphaFromAccount( sAccountNo);
               end;

               with BA.baFields do
               Begin
                  Write( XFile,'A,' );
                  Write( XFile,'"',sAccountNo,'",' );
                  Write( XFile,'"',ReplaceCommasAndQuotes(baBank_Account_Name),'",' );
                  Write( XFile,'"',baContra_Account_Code,'",' );
                  Write( XFile,'"',clCode,'",' );
                  Write( XFile,'"',Date2Str( FromDate, 'dd/mm/yy' ) ,'",' );
                  Write( XFile,'"',Date2Str( ToDate, 'dd/mm/yy' ) ,'"' );
                  Writeln( XFile );
  
                  DrValue := 0;
                  CrValue := 0;
                  ECount  := 0;
               
                  StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
                  M := M1; Y := Y1;
                  Repeat
                     D1 := DMYToStDate( 1, M, Y, Epoch );
                     If D1<FromDate then D1 := FromDate;
                     D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
                     If D2 > ToDate then D2 := ToDate;
                     ExportPeriod( D1, D2 );
                     Inc( M ); If M>12 then Begin M:= 1; Inc( Y ); end;
                  Until ( D2 = ToDate );

                  Write( XFile, 'C,' );
                  Write( XFile, ECount, ',' );
                  Write( XFile, DrValue/100:0:2, ',' );
                  Write( XFile, CrValue/100:0:2, ',' );
                  Write( XFile, ( DrValue + CrValue )/100:0:2 );
                  Writeln( XFile );
               end;
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
procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
//determine if bclink interface should be used or existing interface
begin    
  if Software.IsMYOBAO_DLL_Interface( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
    MYOBAOX_bcLink.ExtractData( FromDate, ToDate, SaveTo)
  else
    ExtractDataStd( FromDate,ToDate,SaveTo);
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

