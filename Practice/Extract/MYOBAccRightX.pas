//------------------------------------------------------------------------------
//  Export for MYOB Account Right format Name : MYOB General Journals (2012)
//------------------------------------------------------------------------------
unit MYOBAccRightX;

//------------------------------------------------------------------------------
interface

uses
  StDate;

//------------------------------------------------------------------------------
procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

//------------------------------------------------------------------------------
implementation

uses
  TransactionUtils,
  Classes,
  Traverse,
  Globals,
  GenUtils,
  bkDateUtils,
  TravUtils,
  LogUtil,
  BaObj32,
  dlgSelect,
  BkConst,
  MoneyDef,
  SysUtils,
  InfoMoreFrm,
  BKDefs,
  glConst;

const
   UnitName = 'MYOBAccRightX';
   DebugMe  : Boolean = False;
   TAB      : char = #09;

var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   JnlNumber     : LongInt;

//------------------------------------------------------------------------------
function ValidId(aUID: string): Boolean;
var
  UniqueID: integer;
begin
  Result := (aUID <> '');  //Can't be blank
  Result := Result and (Length(aUID) = 6); //Must be 6 characters
  Result := Result and (TryStrToInt(aUID, UniqueID));  //Must be an integer
  Result := Result and ((UniqueID > 0) and //Must be greater than 0
            (UniqueID <= JnlNumber)); //...and less than or equal to the last JnlNum
end;

//------------------------------------------------------------------------------
function GetJnlID(var aUID: ansistring; aBankAccntType: Byte = btBank): string;
var
  UniqueID: integer;
begin
  Result := '';
  if ValidId(aUID) then
     UniqueID := StrToInt(aUID)
  else begin
     //Create or reset the external ID
     Inc( JnlNumber );
     aUID := Format('%.6d', [JnlNumber]);
     UniqueID := JnlNumber;
  end;

  //Format the ID
  case aBankAccntType of
    btCashJournals    : Result := Format('CJ%.6d', [UniqueID]);
    btAccrualJournals : Result := Format('AJ%.6d', [UniqueID]);
    else                Result := Format('BL%.6d', [UniqueID]); //Bank account
  end;
end;

//------------------------------------------------------------------------------
function FormatAmount(AAmount: Currency): string;
begin
  Result := Format('%s%0.2n', [MyClient.CurrencySymbol, AAmount]);
//  if (AAmount >= 1000) or (AAmount <= -1000) then
//    Result := Format('"%s%0.2n"', [MyClient.CurrencySymbol, AAmount]);
end;

//------------------------------------------------------------------------------
procedure MYOBWrite( const AJnlID       : string;
                     const ADate        : TStDate;
                     const ARefce       : ShortString;
                     const AAccount     : ShortString;
                     const AAmount      : Money;
                     const ANarration   : ShortString;
                     const AGST         : Money;
                     const AGSTClass    : string;
                     const Indicator    : ShortString;
                     const JobCode      : ShortString;
                     const IsYearEndAdj : Boolean);
const
   ThisMethodName = 'MYOBWrite';
var
   RefAndNarration : ShortString;
   AmountStr: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Write( XFile, AJnlID, TAB ); // Unique ID
  Write( XFile, Date2Str( ADate, 'dd/mm/yyyy' ), TAB );

  if ANarration = '' then
    RefAndNarration := Trim(ARefce)
  else if ARefce = '' then
    RefAndNarration := ANarration
  else
    RefAndNarration := Format('%s %s', [ARefce, ANarration]);

  RefAndNarration := Copy(RefAndNarration, 1, GetMaxNarrationLength);
  Write( XFile, RefAndNarration, TAB );

  Write (XFile, Indicator, TAB); // S = Sale, P = Purchase
  Write (XFile, TAB); // Inclusive (blank)
  Write( XFile, AAccount, TAB );

  if AAmount < 0 then  //Is Credit
    Write( XFile, 'Y', TAB )
  else
    Write( XFile, 'N', TAB );

  AmountStr := FormatAmount((Abs(AAmount) - Abs(AGST))/100.0);
   Write(XFile, AmountStr, TAB); // Amount

  Write(XFile, TAB); //Job
  Write(XFile, AGSTClass, TAB); // Tax Code

  AmountStr := FormatAmount(AGST/100.0);
  Write(XFile, AmountStr, TAB); // Credit exc tax

  Write( XFile, RefAndNarration, TAB ); //Allocation Memo - Ref and Narration
  Write(XFile); //Category (Blank)

  if IsYearEndAdj then  //Is Year End Adjustment
    Writeln( XFile, 'Y', TAB )
  else
    Writeln( XFile, 'N', TAB );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure DoAccountHeader;
const
   ThisMethodName = 'DoAccountHeader';
begin
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function GetGSTClassStr(AGSTClass: Byte): string;
begin
  Result := '';
  if AGSTClass in [1..MAX_GST_CLASS] then begin
    //Strip 'S' or 'P' off tax code
    Result := UpperCase(MyClient.clFields.clGST_Class_Codes[AGSTClass]);
    if (Length(Result) > 3) and (Result[Length(Result)] in ['S', 'P'])
    or Sametext(Result,'GSTE') then
        //Assumes 'S' or 'P' needs to be removed from all!
       Result := Copy(Result, 1, Length(Result) - 1);

  end;
end;

//------------------------------------------------------------------------------
procedure DoTransaction;
const
   ThisMethodName = 'DoTransaction';
var
   Indicate: ShortString;
   JnlID: string;
   IsYearEndAdj : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   with MyClient.clFields, Bank_Account.baFields, Transaction^ do begin

      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      if ( txFirst_Dissection = nil ) then
      begin
         JnlID := GetJnlID(Transaction^.txExternal_GUID, Bank_Account.baFields.baAccount_Type);
         if ( txGST_Class = 0 ) then txGST_Amount := 0;

         if txAmount < 0 then
           Indicate := 'S'
         else
           Indicate := 'P';

         IsYearEndAdj := (baAccount_Type = btYearEndAdjustments );

         MYOBWrite( JnlID,
                    txDate_Effective,           { const ADate       : TStDate      }
                    GetReference(TransAction,Bank_Account.baFields.baAccount_Type),
                                                { const ARefce      : ShortString  }
                    txAccount,                  { const AAccount    : ShortString  }
                    txAmount,                   { const AAmount     : Money        }
                    GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),
                                                { const ANarration  : ShortString  }
                    txGST_Amount,               { const AGST        : Money        }
                    GetGSTClassStr(txGST_Class),{ const AGSTClass   : String       }
                    Indicate,                   { const Indicator   : ShortString  }
                    txJob_Code,                 { const JobCode     : ShortString  }
                    IsYearEndAdj                { const JobCode     : ShortString  }
                  );
      end;

   end;
   Inc( NoOfEntries );   

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure DoDissection ;
const
   ThisMethodName = 'DoDissection';
var
   Indicate: ShortString;
   JnlID: string;
   IsYearEndAdj : boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  with MyClient.clFields, Transaction^, Dissection^, Bank_Account.baFields do
  begin
    if ( dsGST_Class=0 ) then dsGST_Amount := 0;

    if txAmount < 0 then
      Indicate := 'S'
    else
      Indicate := 'P';

    JnlID := GetJnlID(Transaction^.txExternal_GUID, Bank_Account.baFields.baAccount_Type);

    IsYearEndAdj := (baAccount_Type = btYearEndAdjustments );

    MYOBWrite( JnlID,
               txDate_Effective,           { const ADate       : TStDate      }
               getDsctReference(Dissection, Transaction, baAccount_Type),
                                           { const ARefce      : ShortString  }
               dsAccount,                  { const AAccount    : ShortString  }
               dsAmount,                   { const AAmount     : Money        }
               dsGL_Narration,             { const ANarration  : ShortString ) }
               dsGST_Amount,               { const AGST        : Money }
               GetGSTClassStr(dsGST_Class),{ const AGSTClass   : string }
               Indicate,                    { const Indicator  : ShortString }
               dsJob_Code,                  { const JobCode    : ShortString }
               IsYearEndAdj                { const JobCode     : ShortString  }
              );

  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure DoBlankLine;
begin
  Writeln(XFile);
end;

//------------------------------------------------------------------------------
procedure DoContraAndBlankLine;
const
  ThisMethodName = 'DoContraAndBlankLine';
var
  JnlID,
  Indicate: string;
  IsYearEndAdj : boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  with MyClient.clFields, Transaction^, Bank_Account.baFields do begin
    //Only bank accounts need contra
    if (baAccount_Type = btBank) then begin
      if txAmount < 0 then
           Indicate := 'S'
         else
           Indicate := 'P';

      JnlID := GetJnlID(txExternal_GUID, baAccount_Type);

      IsYearEndAdj := (baAccount_Type = btYearEndAdjustments );

      //Write transaction contra entry
      MYOBWrite( JnlID,
                 txDate_Effective,
                 GetReference(TransAction, baAccount_Type),
                 baContra_Account_Code,
                 -txAmount,
                 GetNarration(TransAction, baAccount_Type),
                 0,
                 'N-T',
                 Indicate,
                 Transaction^.txJob_Code,
                 IsYearEndAdj);
    end;
  end;
  Writeln(XFile); //Blank line

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

//------------------------------------------------------------------------------
procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
var
   Msg          : string;
   Selected     : TStringList;
   BA           : TBank_Account;
   No           : Integer;
   OK           : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := Format('%s Extract data [MYOB format] from %s to %s',
                 [ThisMethodName, BkDate2Str(FromDate), BkDate2Str(ToDate)]);
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName,  Msg );

   Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   if Selected = NIL then exit;

   try
      with MyClient.clFields do
      begin
         for No := 0 to Pred( Selected.Count ) do
         begin
            BA := TBank_Account( Selected.Objects[ No ] );
            with BA.baFields do
            begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
               begin
                  Msg := Format('There aren''t any new entries to extract ' +
                                'from "%s" in this date range!',
                                [baBank_Account_Number]);
                  HelpfulInfoMsg( Msg , 0 );
                  Exit;
               end;

               if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
               begin
                  Msg := Format( 'Account "%s" has uncoded entries. ' +
                                 'You must code all the entries before you ' +
                                 'can extract them.', [baBank_Account_Number] );
                  HelpfulInfoMsg( Msg, 0 );
                  Exit;
               end;

               if BA.baFields.baContra_Account_Code = '' then
               begin
                  Msg := 'Before you can extract these entries, you must ' +
                         'specify a contra account code for this bank account. ' +
                         'To do this, go to the Other Functions|Bank Accounts ' +
                         'option and edit the account';
                  HelpfulInfoMsg( Msg, 0 );
                  exit;
               end;

               if not HasRequiredGSTContraCodes( BA, FromDate, ToDate ) then
               begin
                  Msg := 'Before you can extract these entries, you must ' +
                         'specify the control account for each GST Class. ' +
                         'To do this, go to the Other Functions|GST Details ' +
                         'and Rates option.';
                  HelpfulInfoMsg( Msg, 0 );
                  exit;
               end;

            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
         try
            Writeln(XFile, '{}'); //New format

            NoOfEntries := 0;

            JnlNumber   := clLast_Batch_Number;

            for No := 0 to Pred( Selected.Count ) do
            begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnAHProc( DoAccountHeader );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.SetOnETProc( DoContraAndBlankLine );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            end;
            OK := True;

            clLast_Batch_Number := JnlNumber;

         finally
            System.Close( XFile );
         end;

         if OK then
         begin
            Msg := Format( 'Extract Data Complete. %d Entries were saved in %s',
                           [ NoOfEntries, SaveTo ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      end; { Scope of MyClient }
   finally
      Selected.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


