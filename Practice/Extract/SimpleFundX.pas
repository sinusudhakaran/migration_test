unit SimpleFundX;
//------------------------------------------------------------------------------
{
   Title:       BGL Simple fund export

   Description:

   Remarks:     Oct 2000  Added GST amount and class fields

                Feb 2004  Added Super fund specific fields

   Author:

   Notes:       Simple Super from BGL Corporate Solutions
                Unit 2, Ormond Centre, 578-596 North Road
                Ormond Vic 3204

                Phone 00613 9530 6077

                Contact Ron Lesh

         Feb 04  Matt Crofts  mcrofts@bglcorp.com.au
                 Simple Fund Product Manager
                 1300 654 401

                Used by Flinders
}
//------------------------------------------------------------------------------
interface

uses
  Classes,
  StDate;

procedure ExtractData( const SuperFundType: byte; const FromDate, ToDate : TStDate; const SaveTo : string );
procedure ExtractDataBGL(const FromDate, ToDate: TStDate; const SaveTo : string);
procedure ExtractDataBGL360(const FromDate, ToDate: TStDate; const SaveTo : string; TestAccountList: TStringList = nil);

//******************************************************************************
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  BaObj32,
  baUtils,
  BkConst,
  bkDateUtils,
  BKDefs,
  dlgSelect,
  ExtractCommon,
  ExtractHelpers,
  GenUtils,
  glConst,
  Globals,
  InfoMoreFrm,
  IniFiles,
  LogUtil,
  MoneyDef,
  OmniXML,
  OmniXMLUtils,
  StStrS,
  SuperFieldsUtils,
  SysUtils,
  TransactionUtils,
  Traverse,
  TravUtils,
  YesNoDlg;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'SimpleFundX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
  XFile               : Text;
  Buffer              : array[ 1..2048 ] of Byte;
  NoOfEntries         : LongInt;
  FCloseBalance       : Money;
  FAccountNode        : IxmlNode;
  FOutputDocument     : IXMLDocument;
  FClientNode         : IxmlNode;
  FBalancesNode       : IxmlNode;
  FDateMask           : shortString;
  FRootNode           : IxmlNode;
  FTransactionsNode   : IxmlNode;
  FTransactionNode    : IxmlNode;
  FExtractFieldHelper : TExtractFieldHelper;
  FFields             : TStringList;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ExtractFieldHelper: TExtractFieldHelper;
begin
   if not Assigned(FExtractFieldHelper) then
      FExtractFieldHelper := TExtractFieldHelper.Create;

   Result := FExtractFieldHelper;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SWrite(  const ADate        : TStDate;
                   const ARefce       : ShortString;
                   const AAccount     : ShortString;
                   const AAmount      : Money;
                   const AQuantity    : Money;
                   const ANarration   : ShortString;
                   const AGSTClass    : integer;
                   const AGSTAmount   : Money;

                   const aCGTDate              : integer;
                   const aImputedCredit        : Money;
                   const aTaxFreeDist          : Money;
                   const aTaxExemptDist        : Money;
                   const aTaxDeferredDist      : Money;
                   const aTFNCredit            : Money;
                   const aForeignIncome        : Money;
                   const aForeignTaxCredits    : Money;
                   const aOtherExpenses        : Money;
                   const aCapitalGainsIndexed  : Money;
                   const aCapitalGainsDisc     : Money;
                   const aCapitalGainsOther    : Money;
                   const aFranked              : Money;
                   const aUnfranked            : Money;
                   const aMember               : Byte);
const
   ThisMethodName = 'SWrite';
Var
   AbsGSTAmount : Money;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ),'",' );

   Write( XFile, '"',TrimSpacesS(ARefce), '",' );

   Write( XFile, '"',AAccount, '",' );

   Write( XFile, '"', AAmount/100:0:2, '",' );

   if (Globals.PRACINI_ExtractQuantity) then
     Write( XFile, '"', GetQuantityStringForExtract(Abs( AQuantity)), '",' )
   else
     Write( XFile, '"', GetQuantityStringForExtract(0), '",' );

   Write( XFile, '"',Copy(TrimSpacesS( ANarration), 1, GetMaxNarrationLength), '",' );

   //BGL Simplefund requires that gst amount is always a positive number
   AbsGSTAmount := abs( AGSTAmount);

   if not ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then
      Write( XFile, '"0.00","",' ) { No GST }
   else begin
      Write( XFile, '"', AbsGSTAmount/100:0:2, '",' );
      Write( XFile, '"', Copy( MyClient.clFields.clGST_Class_Codes[ AGSTClass ],1,1), '",' );
   end;

   Write( XFile, '"', AAmount/100:0:2, '",' );

   //super fields

   Write( XFile, '"', Date2Str( aCGTDate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"', abs( aImputedCredit)/100:0:2, '",');       //must be +ve
   Write( XFile, '"', aTaxFreeDist/100:0:2, '",');
   Write( XFile, '"', aTaxExemptDist/100:0:2, '",');
   Write( XFile, '"', aTaxDeferredDist/100:0:2, '",');          
   Write( XFile, '"', abs( aTFNCredit)/100:0:2, '",');          //must be +ve
   Write( XFile, '"', aForeignIncome/100:0:2, '",');
   Write( XFile, '"', abs( aForeignTaxCredits)/100:0:2, '",');  //must be +ve
   Write( XFile, '"', abs( aOtherExpenses)/100:0:2, '",');      //must be +ve
   Write( XFile, '"', abs( aCapitalGainsIndexed)/100:0:2, '",');//must be +ve
   Write( XFile, '"', abs( aCapitalGainsDisc)/100:0:2, '",');   //must be +ve
   Write( XFile, '"', abs( aCapitalGainsOther)/100:0:2, '",');   //must be +ve
   Write( XFile, '"', abs( aFranked)/100:0:2, '",');             //must be +ve
   Write( XFile, '"', abs( aUnfranked)/100:0:2, '",');           //must be +ve
   write( XFile, '"', GetSFMemberText(ADate,aMember,true), '"');

   Writeln( XFile );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ Moved to ExtractCommon, remove this after successful build
function FormatFloatForXml(AFloat: comp; ADecimalPlaces: integer = 2;
                           AdivBy: integer = 100): string;
var
  i: integer;
  FormatPic: string;
begin
  if AFloat = 0 then
    Exit;

  FormatPic := '#0.';
  for i := 0 to ADecimalPlaces - 1 do
    FormatPic := FormatPic + '0';
  FormatPic := FormatPic + ';-' + FormatPic;
  Result := FormatFloat(FormatPic, AFloat/ADivBy);
end;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
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
         SWrite( txDate_Effective,           { ADate        : TStDate;         }
                 GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { ARefce       : ShortString;     }
                 txAccount,                  { AAccount     : ShortString;     }
                 txAmount,                   { AAmount      : Money;           }
                 txQuantity,                 { AQuantity    : Money;           }
                  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),             { ANarration   : ShortString );   }
                 txGST_Class,
                 txGST_Amount,

                 txSF_CGT_Date,
                 txSF_Imputed_Credit,
                 txSF_Tax_Free_Dist,
                 txSF_Tax_Exempt_Dist,
                 txSF_Tax_Deferred_Dist,
                 txSF_TFN_Credits,
                 txSF_Foreign_Income,
                 txSF_Foreign_Tax_Credits,
                 txSF_Other_Expenses,
                 txSF_Capital_Gains_Indexed,
                 txSF_Capital_Gains_Disc,
                 txSF_Capital_Gains_Other,
                 txSF_Franked,
                 txSF_Unfranked,
                 txSF_Member_Component
                 );
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
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      SWrite( txDate_Effective,           { ADate        : TStDate;         }
              getDsctReference(Dissection,Transaction,baAccount_Type),
                                          { ARefce       : ShortString;     }
              dsAccount,                  { AAccount     : ShortString;     }
              dsAmount,                   { AAmount      : Money;           }
              dsQuantity,                 { AQuantity    : Money;           }
              dsGL_Narration,             { ANarration   : ShortString      }
              dsGST_Class,
              dsGST_Amount,

              dsSF_CGT_Date,
              dsSF_Imputed_Credit,
              dsSF_Tax_Free_Dist,
              dsSF_Tax_Exempt_Dist,
              dsSF_Tax_Deferred_Dist,
              dsSF_TFN_Credits,
              dsSF_Foreign_Income,
              dsSF_Foreign_Tax_Credits,
              dsSF_Other_Expenses,
              dsSF_Capital_Gains_Indexed,
              dsSF_Capital_Gains_Disc,
              dsSF_Capital_Gains_Other,
              dsSF_Franked,
              dsSF_Unfranked,
              dsSF_Member_Component
             );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function OutputDocument: IXMLDocument;
begin
  if FOutputDocument = nil then
    FOutputDocument := CreateXMLDoc;
  Result := FOutputDocument;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddFieldNode(var ToNode: IxmlNode; const Name, Value: string; AllowEmpty: boolean = false);
begin
  if (Value > '') or AllowEmpty then
    SetNodeTextStr(ToNode,Name,Value);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const SuperFundType: byte; const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if (SuperFundType = saBGLSimpleFund) then
    ExtractDataBGL(FromDate, ToDate, SaveTo)
  else if (SuperFundType = saBGL360) then
    ExtractDataBGL360(FromDate, ToDate, SaveTo);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractDataBGL(const FromDate, ToDate: TStDate; const SaveTo : string);
const
   ThisMethodName = 'ExtractDataBGL';
VAR
   BA : TBank_Account;
   Msg          : String;
   OK           : Boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Msg := 'Extract data [BGL Simple Fund format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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

procedure DoAccountHeader;
const
  ThisMethodName = 'DoAccountHeader';
var
  OpenBalance, SystemOpBal, SystemClBal: Money;
  BSB, AccountNum: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  OpenBalance := 0;
  FCloseBalance := 0;
  if Assigned(Bank_Account) then
  begin
    baUtils.GetBalances(Bank_Account,  Traverse_From, Traverse_To, OpenBalance,
                        FCloseBalance, SystemOpBal, SystemClBal);
    if OpenBalance = Unknown then
      Exit; // don't show accounts with unknown amounts
  end;

  FAccountNode := OutputDocument.CreateElement('Balance');
  FBalancesNode.AppendChild(FAccountNode);
  AddFieldNode(FAccountNode, 'BalanceDate', Date2Str(Traverse_From, FdateMask ));
  AddFieldNode(FAccountNode, 'BalanceAmount', FormatFloatForXml(OpenBalance, 2, 100, true));
  ProcessDiskCode(Bank_Account.baFields.baBank_Account_Number, BSB, AccountNum);
  AddFieldNode(FAccountNode, 'BSB', BSB);
  AddFieldNode(FAccountNode, 'Bank_Account_No', AccountNum);
  AddFieldNode(FAccountNode, 'Balance_Type', '10'); // 10 = Opening Balance, 15 = Closing Balance

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddGuid(var ToNode: IxmlNode; const Value: string; MaxLen: integer = 16);
var
  id: string;
  i : integer;
begin
  id := '';
  for i := Length(Value) downto 1 do begin
    if Value[i] in ['0'..'9', 'A'..'F'] then begin
       id := Value[i] + id;
        if Length(id) >= MaxLen then
          Break; // Thats all we can fit..
     end;
  end;
  AddFieldNode(ToNode, 'Other_Reference', id);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddAccountCodeNode(AccountCode: string);
var
  PracIniFile: TIniFile;
begin
  if (AccountCode = '') then
  begin
    try
      PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
      AccountCode := PracIniFile.ReadString(BGL360code, 'ExtractCode', '91000');
      if AccountCode = '' then
        AccountCode := '91000'; // default account code for uncoded transactions
    finally
      PracIniFile.Free;
    end;
  end;
  AddFieldNode(FTransactionNode, 'Account_Code', AccountCode);
end;

procedure DoClassSuperIPTransaction;
const
  ThisMethodName = 'DoClassSuperIPTransaction';
var
  BSB, AccountNum, AccountCode: string;

  procedure AddField(const Name, Value: string);
  begin
     if Value > '' then
        FFields.Add(Name + '=' + Value );
  end;

  procedure AddTextNode;
  var
    Ref, Nar: string;
  begin
    Nar := Transaction^.txGL_Narration;
    Ref := IntToStr(Transaction^.txCheque_Number);
    if (Ref > '') and (Ref <> '0') then
       if Nar > '' then
          Ref := Nar + ' BL Ref: ' + Ref
       else
          Ref := 'BL Ref: ' + Ref
    else
       Ref := Nar;
    AddFieldNode(FTransactionNode, 'Text', Ref, True);
  end;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Transaction^.txDate_Transferred := CurrentDate;

  If ( Transaction^.txFirst_Dissection = NIL ) then
  begin // only create node if there are no dissections, DoClassSuperIPTransaction handles dissections
    FTransactionNode := OutputDocument.CreateElement('Transaction');
    FTransactionsNode.AppendChild(FTransactionNode);
    AddFieldNode(FTransactionNode, 'Transaction_Type', 'Other Transaction');
    TransactionUtils.CheckExternalGUID(Transaction);
    AddGuid(FTransactionNode, Uppercase(Transaction^.txExternal_GUID), 15); // <Other_Reference>
    ProcessDiskCode(TBank_Account(Transaction^.txBank_Account).baFields.baBank_Account_Number, BSB, AccountNum);
    AddFieldNode(FTransactionNode, 'BSB', BSB);
    AddFieldNode(FTransactionNode, 'Bank_Account_No', AccountNum);
    AddAccountCodeNode(Transaction^.txAccount); // <Account_Code>
    AddFieldNode(FTransactionNode, 'Transaction_Date', Date2Str(Transaction^.txDate_Effective, FDateMask));
    AddTextNode; // <Text>
    AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Transaction^.txAmount));
  end;

  inc(NoOfEntries);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end; 

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoClassSuperIPDissection;
const
  ThisMethodName = 'DoClassSuperIPDissection';
var
  BSB, AccountNum: string;

  procedure AddTextNode;
  var
    Ref, Nar: string;
  begin
    Nar := Dissection^.dsGL_Narration;
    Ref := IntToStr(Dissection^.dsTransaction^.txCheque_Number);

    if (Ref > '') and (Ref <> '0') then
       if Nar > '' then
          Ref := Nar + ' BL Ref: ' + Ref
       else
          Ref := 'BL Ref: ' + Ref
    else
       Ref := Nar;
    AddFieldNode(FTransactionNode, 'Text', Ref, True);
  end;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  FTransactionNode := OutputDocument.CreateElement('Transaction'); // BGL 360 export should output dissections as 'transactions'
  FTransactionsNode.AppendChild(FTransactionNode);
  AddFieldNode(FTransactionNode, 'Transaction_Type', 'Other Transaction');
  TransactionUtils.CheckExternalGUID(Dissection);
  AddGuid(FTransactionNode, Uppercase(Dissection^.dsExternal_GUID), 15); // <Other_Reference>
  ProcessDiskCode(TBank_Account(Dissection^.dsBank_Account).baFields.baBank_Account_Number, BSB, AccountNum);
  AddFieldNode(FTransactionNode, 'BSB', BSB);
  AddFieldNode(FTransactionNode, 'Bank_Account_No', AccountNum);
  AddAccountCodeNode(Dissection^.dsAccount); // <Account_Code>
  AddFieldNode(FTransactionNode, 'Transaction_Date', Date2Str(Dissection^.dsTransaction^.txDate_Effective, FDateMask));
  AddTextNode; // <Text>
  AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Dissection^.dsAmount));

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

procedure ExtractDataBGL360(const FromDate, ToDate: TStDate; const SaveTo : string; TestAccountList: TStringList = nil);
const
   ThisMethodName = 'ExtractDataBGL360';
VAR
  BA : TBank_Account;
  Msg          : String;
  No           : Integer;
  Selected: TStringList;
  PI: IXMLProcessingInstruction;
  IsJournal: boolean;

  function OutputDocument: IXMLDocument;
  begin
    if FOutputDocument = nil then
      FOutputDocument := CreateXMLDoc;
    Result := FOutputDocument;
  end;

  procedure AddNumberField(const Name: string; Value: Integer);
  begin
     FFields.Add(Name + '=' + InttoStr(Value));
  end;

begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Msg := 'Extract data [BK5 XML format] from ' + BkDate2Str(FromDate) +
         ' to ' + bkDate2Str(ToDate);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg);

  if (TestAccountList <> nil) then
  begin
    Selected := TestAccountList;
  end else
  begin
    Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
    if Selected = NIL then
      Exit;
  end;

  try
    FRootNode := nil;
    FClientNode := nil;
    FAccountNode := nil;
    FTransactionsNode := nil;
    NoOfEntries := 0;
    OutputDocument.LoadXML(''); // Clear
    PI := OutputDocument.CreateProcessingInstruction('xml', 'version="1.0" encoding="ISO-8859-1"');
    OutputDocument.AppendChild(PI);
    FRootNode := EnsureNode(OutputDocument, 'BGL_Import_Export');
    SetNodeTextStr(FRootNode, 'Supplier', 'MYOB BankLink');
    SetNodeTextStr(FRootNode, 'Product', 'SF360');
    SetNodeTextStr(FRootNode, 'Import_Export_Version', '5.0');

    FDateMask := 'dd/mm/YYYY';

    for No := 0 to Pred(Selected.Count) do
    begin
      BA := TBank_Account(Selected.Objects[No]);

      //No entries
      if TravUtils.NumberAvailableForExport(BA, FromDate, ToDate) = 0 then begin
        HelpfulInfoMsg('There are no new entries to extract, for ' +
                       BA.baFields.baBank_Account_Number +
                       ', in the selected date range.',0);
        Exit;
      end;
    end;

    //Output XML
    if Assigned(MyClient) then
    begin
      //Client
      FClientNode := OutputDocument.CreateElement('Entity_Details');
      FRootNode.AppendChild(FClientNode);
      SetNodeTextStr(FClientNode, 'Entity_Code', MyClient.clFields.clCode);
      FBalancesNode := OutputDocument.CreateElement('BankBalances');
      FClientNode.AppendChild(FBalancesNode);
      FTransactionsNode := OutputDocument.CreateElement('Transactions');
      FClientNode.AppendChild(FTransactionsNode);

      for No := 0 to Pred( Selected.Count ) do begin
        BA := TBank_Account(Selected.Objects[No]);
        Traverse.Clear;
        IsJournal := (AnsiPos('Journals', TBank_Account(Selected.Objects[No]).baFields.baBank_Account_Number) <> 0);

        Traverse.SetSortMethod(csDateEffective);
        Traverse.SetSelectionMethod(Traverse.twAllNewEntries);
        if not IsJournal then
          Traverse.SetOnAHProc(DoAccountHeader);
        Traverse.SetOnEHProc(DoClassSuperIPTransaction);
        Traverse.SetOnDSProc(DoClassSuperIPDissection);
        Traverse.TraverseEntriesForAnAccount(BA, FromDate, ToDate);
      end;

      //Write XML file
      OutputDocument.Save(SaveTo ,ofIndent);
      FOutputDocument := nil;
      FRootNode := nil;
      FClientNode := nil;
      FAccountNode := nil;
      FTransactionsNode := nil;
      //Display message
      Msg := SysUtils.Format('Extract Data Complete. %d Entries were saved in %s',
                             [NoOfEntries, SaveTo]);
      if DebugMe then      
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
      if (TestAccountList = nil) then
        HelpfulInfoMsg( Msg, 0 );
    end;

  finally

  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
Finalization
  FreeAndNil(FExtractFieldHelper);
end.



