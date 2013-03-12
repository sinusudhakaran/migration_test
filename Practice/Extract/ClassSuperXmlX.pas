unit ClassSuperXmlX;

interface

uses
  stDate;

procedure ExtractData(const FromDate, ToDate: TStDate; const SaveTo: string;
                      AllowUncoded: boolean = False;
                      AllowBlankContra: boolean = False);

implementation

uses
  Software,
  TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, bautils,
  TravUtils, YesNoDlg, LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef,
  SysUtils, StStrS, InfoMoreFrm, BKDefs, glConst, OmniXMLUtils, OmniXML;

const
  UNIT_NAME = 'CSVX';
  DEBUG_ME  : Boolean = False;

var
  FOutputDocument: IXMLDocument;
  FRootNode: IxmlNode;
  FClientNode: IxmlNode;
  FAccountNode: IXMLNode;
  FTransactionNode: IxmlNode;
  FNoOfEntries: integer;
  FCloseBalance: Money;
  FDateMask: shortString;

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

function LookupChart(const Value: string): string;
begin
  Result := '';
  if (Value > '') and Assigned(MyClient) then
    Result := MyClient.clChart.FindDesc(Value);
end;

function LookupGSTClassCode(const Value: integer): string;
begin
  Result := '';
  if Assigned(MyClient) and (Value in [1..MAX_GST_CLASS]) then
    Result := MyClient.clFields.clGST_Class_Codes[Value]
end;

function LookupGSTClassName(const Value: integer): string;
begin
  Result := '';
  if Assigned(MyClient) and (Value in [1..MAX_GST_CLASS]) then
    Result := MyClient.clFields.clGST_Class_Names[Value];
end;

function LookupJob(const Value: string): string;
begin
   Result := '';
   if (Value > '')
   and Assigned(MyClient) then
       Result := MyClient.clJobs.JobName(Value);
end;

function OutputDocument: IXMLDocument;
begin
  if FOutputDocument = nil then
    FOutputDocument := CreateXMLDoc;
  Result := FOutputDocument;
end;

procedure AddFieldNode(var ToNode: IxmlNode; const Name, Value: string);
begin
  if Value > '' then // No empty Tags...
    SetNodeTextStr(ToNode,Name,Value);
end;

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
  AddFieldNode(ToNode, 'Transaction_UID', id);
end;

procedure DoAccountHeader;
const
  ThisMethodName = 'DoAccountHeader';
var
  OpenBalance, SystemOpBal, SystemClBal: Money;
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  OpenBalance := 0;
  FCloseBalance := 0;
  if Assigned(Bank_Account) then begin
    baUtils.GetBalances(Bank_Account,  Traverse_From, Traverse_To, OpenBalance,
                        FCloseBalance, SystemOpBal, SystemClBal);
  end;

  FAccountNode := OutputDocument.CreateElement('Account');
  FClientNode.AppendChild(FAccountNode);

  AddFieldNode(FAccountNode, 'Account_Number', Bank_Account.baFields.baBank_Account_Number);
  AddFieldNode(FAccountNode, 'Account_Type', btNames[Bank_Account.baFields.baAccount_Type]);
  AddFieldNode(FAccountNode, 'Account_Name', Bank_Account.baFields.baBank_Account_Name);
  AddFieldNode(FAccountNode, 'Account_Contra_Code', Bank_Account.baFields.baContra_Account_Code);
  AddFieldNode(FAccountNode, 'Fund_Code', Bank_Account.baFields.baSuperFund_Ledger_Code );
  AddFieldNode(FAccountNode, 'Opening_Date', Date2Str(Traverse_From, FdateMask ));
  AddFieldNode(FAccountNode, 'Opening_Balance', FormatFloatForXml(OpenBalance));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;

procedure DoAccountTrailer;
const
  ThisMethodName = 'DoAccountTrailer';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  AddFieldNode(FAccountNode, 'Closing_Date', Date2Str(Traverse_To, FdateMask ));
  AddFieldNode(FAccountNode, 'Closing_Balance', FormatFloatForXml(FCloseBalance));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;

procedure DoClassSuperIPTransaction;
const
  ThisMethodName = 'DoClassSuperIPTransaction';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  Transaction.txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(Transaction.txDate_Effective);

  Transaction.txDate_Transferred := CurrentDate;
  if SkipZeroAmountExport(Transaction) then
     Exit; // Im done...
  if Assigned(Transaction^.txFirst_Dissection) then
     Exit; // just do the dissection

  FTransactionNode := OutputDocument.CreateElement('Transaction');
  FAccountNode.AppendChild(FTransactionNode);

  TransactionUtils.CheckExternalGUID(Transaction);
  AddGuid(FTransactionNode, Transaction^.txExternal_GUID);

  AddFieldNode(FTransactionNode, 'Date', Date2Str(Transaction^.txDate_Effective, FDateMask));
  AddFieldNode(FTransactionNode, 'Reference', Transaction^.txReference);
  AddFieldNode(FTransactionNode, 'Narration', Transaction^.txGL_Narration);

  AddFieldNode(FTransactionNode, 'Code', Transaction^.txAccount);
  AddFieldNode(FTransactionNode, 'Code_Desc', LookupChart(Transaction^.txAccount));

  AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Transaction^.txAmount));
  AddFieldNode(FTransactionNode, 'GST', FormatFloatForXml(Transaction^.txGST_Amount));
  AddFieldNode(FTransactionNode, 'GST_Class', LookupGSTClassCode(Transaction^.txGST_Class));
  AddFieldNode(FTransactionNode, 'GST_Desc', LookupGSTClassName(Transaction^.txGST_Class));
  AddFieldNode(FTransactionNode, 'Quantity', FormatFloatForXml(Transaction^.txQuantity, 4, 10000));
  // Supper fields
  AddFieldNode(FTransactionNode, 'Investment_Code', Transaction^.txSF_Fund_Code );
  AddFieldNode(FTransactionNode, 'Member_Account', Transaction^.txSF_Member_Account_Code );


  AddFieldNode(FTransactionNode, 'CGT_Transaction_Date', Date2Str(Transaction^.txSF_CGT_Date, FdateMask ));
  AddFieldNode(FTransactionNode, 'Undeducted_Contrib', FormatFloatForXml(Transaction^.txSF_Special_Income ));
  AddFieldNode(FTransactionNode, 'Franked_Amount', FormatFloatForXml(Transaction^.txSF_Franked));
  AddFieldNode(FTransactionNode, 'Unfranked_Amount', FormatFloatForXml(Transaction^.txSF_Unfranked));


  AddFieldNode(FTransactionNode, 'Foreign_Income', FormatFloatForXml(Transaction^.txSF_Foreign_Income));
  AddFieldNode(FTransactionNode, 'Other_Taxable', FormatFloatForXml(Transaction^.txSF_Other_Expenses));
  AddFieldNode(FTransactionNode, 'Capital_Gain_Other', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Other));
  AddFieldNode(FTransactionNode, 'Capital_Gain_Disc', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Disc));

  if Transaction.txSF_Capital_Gains_Fraction_Half then
    AddFieldNode(FTransactionNode, 'Capital_Gain_Fraction', '1/2')
  else
    AddFieldNode(FTransactionNode, 'Capital_Gain_Fraction', '2/3');

  AddFieldNode(FTransactionNode, 'Capital_Gain_Conc', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Indexed));
  AddFieldNode(FTransactionNode, 'Tax_Deferred', FormatFloatForXml(Transaction^.txSF_Tax_Deferred_Dist));
  AddFieldNode(FTransactionNode, 'Tax_Free_Trust', FormatFloatForXml(Transaction^.txSF_Tax_Free_Dist));
  AddFieldNode(FTransactionNode, 'Non_Taxable', FormatFloatForXml(Transaction^.txSF_Tax_Exempt_Dist));

  AddFieldNode(FTransactionNode, 'Franking_Credit', FormatFloatForXml(Transaction^.txSF_Imputed_Credit));
  AddFieldNode(FTransactionNode, 'TFN_Credit', FormatFloatForXml(Transaction^.txSF_TFN_Credits));
  AddFieldNode(FTransactionNode, 'Foreign_Tax_Credit', FormatFloatForXml(Transaction^.txSF_Foreign_Capital_Gains_Credit));
  AddFieldNode(FTransactionNode, 'ABN_Credit', FormatFloatForXml(Transaction^.txSF_Other_Tax_Credit));

  Inc(FNoOfEntries);

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;


procedure DoClassSuperIPDissection;
const
  ThisMethodName = 'DoClassSuperIPDissection';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  FTransactionNode := OutputDocument.CreateElement('Transaction');
  FAccountNode.AppendChild(FTransactionNode);

  TransactionUtils.CheckExternalGUID(Dissection);
  AddGuid(FTransactionNode, Dissection^.dsExternal_GUID);

  AddFieldNode(FTransactionNode, 'Date', Date2Str(Transaction^.txDate_Effective, FDateMask));
  AddFieldNode(FTransactionNode, 'Reference', TransactionUtils.getDsctReference(Dissection, Bank_Account.baFields.baAccount_Type));
  AddFieldNode(FTransactionNode, 'Narration', Dissection^.dsGL_Narration);

  AddFieldNode(FTransactionNode, 'Code', Dissection^.dsAccount);
  AddFieldNode(FTransactionNode, 'Code_Desc', LookupChart(Dissection^.dsAccount));

  AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Dissection^.dsAmount));
  AddFieldNode(FTransactionNode, 'GST', FormatFloatForXml(Dissection^.dsGST_Amount));
  AddFieldNode(FTransactionNode, 'GST_Class', LookupGSTClassCode(Dissection^.dsGST_Class));
  AddFieldNode(FTransactionNode, 'GST_Desc', LookupGSTClassName(Dissection^.dsGST_Class));
  AddFieldNode(FTransactionNode, 'Quantity', FormatFloatForXml(Dissection^.dsQuantity, 4, 10000));
  // Supper fields
  AddFieldNode(FTransactionNode, 'Investment_Code', Dissection^.dsSF_Fund_Code );
  AddFieldNode(FTransactionNode, 'Member_Account', Dissection^.dsSF_Member_Account_Code );


  AddFieldNode(FTransactionNode, 'CGT_Transaction_Date', Date2Str(Dissection^.dsSF_CGT_Date, FdateMask ));
  AddFieldNode(FTransactionNode, 'Undeducted_Contrib', FormatFloatForXml(Dissection^.dsSF_Special_Income ));
  AddFieldNode(FTransactionNode, 'Franked_Amount', FormatFloatForXml(Dissection^.dsSF_Franked));
  AddFieldNode(FTransactionNode, 'Unfranked_Amount', FormatFloatForXml(Dissection^.dsSF_Unfranked));


  AddFieldNode(FTransactionNode, 'Foreign_Income', FormatFloatForXml(Dissection^.dsSF_Foreign_Income));
  AddFieldNode(FTransactionNode, 'Other_Taxable', FormatFloatForXml(Dissection^.dsSF_Other_Expenses));
  AddFieldNode(FTransactionNode, 'Capital_Gain_Other', FormatFloatForXml(Dissection^.dsSF_Capital_Gains_Other));
  AddFieldNode(FTransactionNode, 'Capital_Gain_Disc', FormatFloatForXml(Dissection^.dsSF_Capital_Gains_Disc));

  if Dissection^.dsSF_Capital_Gains_Fraction_Half then
     AddFieldNode(FTransactionNode, 'Capital_Gain_Fraction', '1/2')
  else
     AddFieldNode(FTransactionNode, 'Capital_Gain_Fraction', '2/3');

  AddFieldNode(FTransactionNode, 'Capital_Gain_Conc', FormatFloatForXml(Dissection^.dsSF_Capital_Gains_Indexed));
  AddFieldNode(FTransactionNode, 'Tax_Deferred', FormatFloatForXml(Dissection^.dsSF_Tax_Deferred_Dist));
  AddFieldNode(FTransactionNode, 'Tax_Free_Trust', FormatFloatForXml(Dissection^.dsSF_Tax_Free_Dist));
  AddFieldNode(FTransactionNode, 'Non_Taxable', FormatFloatForXml(Dissection^.dsSF_Tax_Exempt_Dist));

  AddFieldNode(FTransactionNode, 'Franking_Credit', FormatFloatForXml(Dissection^.dsSF_Imputed_Credit));
  AddFieldNode(FTransactionNode, 'TFN_Credit', FormatFloatForXml(Dissection^.dsSF_TFN_Credits));
  AddFieldNode(FTransactionNode, 'Foreign_Tax_Credit', FormatFloatForXml(Dissection^.dsSF_Foreign_Capital_Gains_Credit));
  AddFieldNode(FTransactionNode, 'ABN_Credit', FormatFloatForXml(Dissection^.dsSF_Other_Tax_Credit));

  Inc(FNoOfEntries);

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;




procedure ExtractData(const FromDate, ToDate: TStDate; const SaveTo: string;
                      AllowUncoded: boolean = False;
                      AllowBlankContra: boolean = False);
const
  THIS_METHOD_NAME = 'ExtractData';
var
  BA: TBank_Account;
  Msg: String;
	No: Integer;
  Selected: TStringList;
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Begins');

  Msg := 'Extract data [BK5 XML format] from ' + BkDate2Str(FromDate) +
         ' to ' + bkDate2Str(ToDate);

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' ' + Msg);

  Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
  if Selected = NIL then
    Exit;

  try
    FRootNode := nil;
    FClientNode := nil;
    FAccountNode := nil;
    FTransactionNode := nil;
    FNoOfEntries := 0;
    OutputDocument.LoadXML(''); // Clear
    FRootNode := EnsureNode(OutputDocument, 'BankLink');
    SetNodeTextStr(FRootNode, 'Version', '1');

    for No := 0 to Pred(Selected.Count) do begin
      BA := TBank_Account(Selected.Objects[No]);

      //No entries
      if TravUtils.NumberAvailableForExport(BA, FromDate, ToDate) = 0 then begin
        HelpfulInfoMsg('There are no new entries to extract, for ' +
                       BA.baFields.baBank_Account_Number +
                       ', in the selected date range.',0);
        Exit;
      end;
      //Uncoded entries
      if not AllowUncoded then begin
        if not TravUtils.AllCoded(BA, FromDate, ToDate) then begin
          HelpfulInfoMsg( 'Account "' + BA.baFields.baBank_Account_Number +
                          '" has uncoded entries. You must code all the ' +
                          'entries before you can extract them.',  0 );
          Exit;
        end;
      end;
      //Bank contra
      if not AllowBlankContra then begin
        if BA.baFields.baContra_Account_Code = '' then begin
          HelpfulInfoMsg('Before you can extract these entries, ' +
                         'you must specify a contra account code ' +
                         'for bank account "'+ BA.baFields.baBank_Account_Number +
                         '". To do this, go to the Other ' +
                         'Functions|Bank Accounts option and edit the account', 0 );
          Exit;
        end;
      end;
    end;

    //Output XML
    if Assigned(MyClient) then begin
      //Client
      FClientNode := OutputDocument.CreateElement('Client');
      FRootNode.AppendChild(FClientNode);
      SetNodeTextStr(FClientNode, 'Client_Code', MyClient.clFields.clCode);
      SetNodeTextStr(FClientNode, 'Client_Name', MyClient.clFields.clName);

      // OK for now but this may become Country specific
      FDateMask := 'YYYY-mm-dd';

      for No := 0 to Pred( Selected.Count ) do begin
        BA := TBank_Account(Selected.Objects[ No ]);
        Traverse.Clear;
        Traverse.SetSortMethod(csDateEffective);
        Traverse.SetSelectionMethod(Traverse.twAllNewEntries);
        Traverse.SetOnAHProc(DoAccountHeader);
        Traverse.SetOnATProc(DoAccountTrailer);
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
      FTransactionNode := nil;
      //Display message
      Msg := SysUtils.Format('Extract Data Complete. %d Entries were saved in %s',
                             [FNoOfEntries, SaveTo]);
      LogUtil.LogMsg(lmInfo, UNIT_NAME, THIS_METHOD_NAME + ' : ' + Msg );
      HelpfulInfoMsg( Msg, 0 );
    end;
  finally
    Selected.Free;
  end;

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, THIS_METHOD_NAME + ' Ends');
end;

end.
