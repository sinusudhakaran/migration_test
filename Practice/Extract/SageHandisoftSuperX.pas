unit SageHandisoftSuperX;

interface

uses
  stDate;

procedure ExtractData(const FromDate, ToDate: TStDate; const SaveTo: string;
                      AllowUncoded: boolean = False;
                      AllowBlankContra: boolean = False);

implementation

uses
  Classes, SysUtils, Globals, bkconst, BaObj32, bkDateUtils, dlgSelect, bautils,
  LogUtil, MoneyDef, Traverse, TravUtils, InfoMoreFrm, OmniXMLUtils, OmniXML,
  TransactionUtils, glConst, SageHandisoftSuperConst, ExtractCommon;

const
  UNIT_NAME = 'SageHandisoftSuperX';
  DEBUG_ME  : Boolean = False;

var
  FOutputDocument: IXMLDocument;
  FRootNode: IxmlNode;
  FClientNode: IxmlNode;
  FAccountNode: IXMLNode;
  FTransactionNode: IxmlNode;
  FNoOfEntries: integer;
  FCloseBalance: Money;

function OutputDocument: IXMLDocument;
begin
  if FOutputDocument = nil then
    FOutputDocument := CreateXMLDoc;
  Result := FOutputDocument;
end;

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
  AddFieldNode(FAccountNode, 'Opening_Balance', FormatFloatForXml(OpenBalance));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;

procedure DoAccountTrailer;
const
  ThisMethodName = 'DoAccountTrailer';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  AddFieldNode(FAccountNode, 'Closing_Balance', FormatFloatForXml(FCloseBalance));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;


procedure DoTransaction;
const
  ThisMethodName = 'DoTransaction';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  Transaction.txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(Transaction.txDate_Effective);

  Transaction.txDate_Transferred := CurrentDate;
  if SkipZeroAmountExport(Transaction) then
     Exit; // Im done...

  if (Transaction^.txFirst_Dissection = nil) then begin
    FTransactionNode := OutputDocument.CreateElement('Transaction');
    FAccountNode.AppendChild(FTransactionNode);

    //Transaction
    TransactionUtils.CheckExternalGUID(Transaction);
    AddGuid(FTransactionNode, Transaction^.txExternal_GUID);
    AddFieldNode(FTransactionNode, 'Date', Date2Str(Transaction^.txDate_Effective, 'dd/mm/YYYY'));
    AddFieldNode(FTransactionNode, 'Description', GetNarration(Transaction, Bank_Account.baFields.baAccount_Type));
    AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Transaction^.txAmount));
    if Transaction^.txSF_Transaction_ID <> -1 then begin
      AddFieldNode(FTransactionNode, 'Type', TypesArray[TTxnTypes(Transaction^.txSF_Transaction_ID)]);
      AddFieldNode(FTransactionNode, 'Sub_Type', Transaction^.txSF_Transaction_Code);
    end;
    AddFieldNode(FTransactionNode, 'GST', FormatFloatForXml(Transaction^.txGST_Amount));
    AddFieldNode(FTransactionNode, 'GST_Class', LookupGSTClassCode(Transaction^.txGST_Class));
    AddFieldNode(FTransactionNode, 'GST_Desc', LookupGSTClassName(Transaction^.txGST_Class));
    AddFieldNode(FTransactionNode, 'Reference', GetReference(Transaction, Bank_Account.baFields.baAccount_Type));
    AddFieldNode(FTransactionNode, 'Number_Issued', FormatFloatForXml(Transaction^.txQuantity, 4, 10000));
    AddFieldNode(FTransactionNode, 'UnFranked_Amount', FormatFloatForXml(Transaction^.txSF_Unfranked));
    AddFieldNode(FTransactionNode, 'Franked_Amount', FormatFloatForXml(Transaction^.txSF_Franked));
    AddFieldNode(FTransactionNode, 'Franking_Credit', FormatFloatForXml(Transaction^.txSF_Imputed_Credit));

    Inc(FNoOfEntries);
  end;


  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;

procedure DoDissection;
const
  ThisMethodName = 'DoDissection';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  FTransactionNode := OutputDocument.CreateElement('Transaction');
  FAccountNode.AppendChild(FTransactionNode);

  //Dissection
  TransactionUtils.CheckExternalGUID(Dissection);
  AddGuid(FTransactionNode, Dissection^.dsExternal_GUID);
  AddFieldNode(FTransactionNode, 'Date', Date2Str(Transaction^.txDate_Effective, 'dd/mm/YYYY'));
  AddFieldNode(FTransactionNode, 'Description', Dissection^.dsGL_Narration);
  AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Dissection^.dsAmount));
  if Dissection^.dsSF_Transaction_ID <> -1 then begin
    AddFieldNode(FTransactionNode, 'Type', TypesArray[TTxnTypes(Dissection^.dsSF_Transaction_ID)]);
    AddFieldNode(FTransactionNode, 'Sub_Type', Dissection^.dsSF_Transaction_Code);
  end;
  AddFieldNode(FTransactionNode, 'GST', FormatFloatForXml(Dissection^.dsGST_Amount));
  AddFieldNode(FTransactionNode, 'GST_Class', LookupGSTClassCode(Dissection^.dsGST_Class));
  AddFieldNode(FTransactionNode, 'GST_Desc', LookupGSTClassName(Dissection^.dsGST_Class));
  AddFieldNode(FTransactionNode, 'Reference', GetDsctReference(Dissection, Bank_Account.baFields.baAccount_Type));
  AddFieldNode(FTransactionNode, 'Number_Issued', FormatFloatForXml(Dissection^.dsQuantity, 4, 10000));
  AddFieldNode(FTransactionNode, 'UnFranked_Amount', FormatFloatForXml(Dissection^.dsSF_Unfranked));
  AddFieldNode(FTransactionNode, 'Franked_Amount', FormatFloatForXml(Dissection^.dsSF_Franked));
  AddFieldNode(FTransactionNode, 'Franking_Credit', FormatFloatForXml(Dissection^.dsSF_Imputed_Credit));

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

  Msg := 'Extract data [Sage Hadisoft Superfund XML format] from ' + BkDate2Str(FromDate) +
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
      for No := 0 to Pred( Selected.Count ) do begin
        BA := TBank_Account(Selected.Objects[ No ]);
        Traverse.Clear;
        Traverse.SetSortMethod(csDateEffective);
        Traverse.SetSelectionMethod(Traverse.twAllNewEntries);
        Traverse.SetOnAHProc(DoAccountHeader);
        Traverse.SetOnATProc(DoAccountTrailer);
        Traverse.SetOnEHProc(DoTransaction);
        Traverse.SetOnDSProc(DoDissection);
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
