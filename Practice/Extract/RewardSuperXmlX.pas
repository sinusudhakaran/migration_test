unit RewardSuperXmlX;

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
  SysUtils, StStrS, InfoMoreFrm, BKDefs, glConst, OmniXMLUtils, OmniXML, ExtractCommon;

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
  AddFieldNode(FAccountNode, 'Opening_Balance', FormatFloatForXml(OpenBalance));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;

procedure DoAccountTrailer;
const
  ThisMethodName = 'DoAccountTrailer';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  AddFieldNode(FAccountNode, 'Closing_Balance', FormatFloatForXml(FCloseBalance));
  AddFieldNode(FAccountNode, 'Closing_Date', Date2Str(Traverse_To, FdateMask ));

  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends');
end;


procedure DoRewardSuperTransaction;
const
  ThisMethodName = 'DoRewardSuperTransaction';
begin
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins');

  Transaction.txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(Transaction.txDate_Effective);

  Transaction.txDate_Transferred := CurrentDate;

  if SkipZeroAmountExport(Transaction) then
     Exit; // Im done...

  FTransactionNode := OutputDocument.CreateElement('Transaction');
  FAccountNode.AppendChild(FTransactionNode);

  TransactionUtils.CheckExternalGUID(Transaction);
  AddGuid(FTransactionNode, Transaction^.txExternal_GUID);

  AddFieldNode(FTransactionNode, 'Date', Date2Str(Transaction^.txDate_Effective, FDateMask));
  AddFieldNode(FTransactionNode, 'Narration', Transaction^.txGL_Narration);
  AddFieldNode(FTransactionNode, 'Reference', Transaction^.txReference);
  if Assigned(Transaction^.txFirst_Dissection) then begin
    //Can't output code if dissected
    AddFieldNode(FTransactionNode, 'Code', '');
    AddFieldNode(FTransactionNode, 'Code_Desc', '');
  end else begin
    AddFieldNode(FTransactionNode, 'Code', Transaction^.txAccount);
    AddFieldNode(FTransactionNode, 'Code_Desc', LookupChart(Transaction^.txAccount));
  end;
  AddFieldNode(FTransactionNode, 'Amount', FormatFloatForXml(Transaction^.txAmount));
  AddFieldNode(FTransactionNode, 'GST', FormatFloatForXml(Transaction^.txGST_Amount));
  AddFieldNode(FTransactionNode, 'GST_Class', LookupGSTClassCode(Transaction^.txGST_Class));
  AddFieldNode(FTransactionNode, 'GST_Desc', LookupGSTClassName(Transaction^.txGST_Class));
  AddFieldNode(FTransactionNode, 'Quantity', FormatFloatForXml(Transaction^.txQuantity, 4, 10000));
  // Supper fields
  AddFieldNode(FTransactionNode, 'CGT_Transaction_Date', Date2Str(Transaction^.txSF_CGT_Date, FdateMask ));
  AddFieldNode(FTransactionNode, 'Franked_Dividend', FormatFloatForXml(Transaction^.txSF_Franked));
  AddFieldNode(FTransactionNode, 'UnFranked_Dividend', FormatFloatForXml(Transaction^.txSF_Unfranked));
  AddFieldNode(FTransactionNode, 'Imputation_Credit', FormatFloatForXml(Transaction^.txSF_Imputed_Credit));
  AddFieldNode(FTransactionNode, 'Tax_Free_Distribution', FormatFloatForXml(Transaction^.txSF_Tax_Free_Dist));
  AddFieldNode(FTransactionNode, 'Tax_Exempt_Distribution', FormatFloatForXml(Transaction^.txSF_Tax_Exempt_Dist));
  AddFieldNode(FTransactionNode, 'Tax_Defered_Distribution', FormatFloatForXml(Transaction^.txSF_Tax_Deferred_Dist));
  AddFieldNode(FTransactionNode, 'TFN_Credit', FormatFloatForXml(Transaction^.txSF_TFN_Credits));
  AddFieldNode(FTransactionNode, 'Foreign_Income', FormatFloatForXml(Transaction^.txSF_Foreign_Income));
  AddFieldNode(FTransactionNode, 'Foreign_Credit', FormatFloatForXml(Transaction^.txSF_Foreign_Capital_Gains_Credit));
  AddFieldNode(FTransactionNode, 'Other_Expenses', FormatFloatForXml(Transaction^.txSF_Other_Expenses));
  AddFieldNode(FTransactionNode, 'Indexed_Capital_Gain', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Indexed));
  AddFieldNode(FTransactionNode, 'Discount_Capital_Gain', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Disc));
  AddFieldNode(FTransactionNode, 'Other_Capital_Gain', FormatFloatForXml(Transaction^.txSF_Capital_Gains_Other));
  if Transaction^.txSF_Member_Component > 0 then
    AddFieldNode(FTransactionNode, 'Member_Component', IntToStr(Transaction^.txSF_Member_Component));

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
      FDateMask := 'dd/mm/YYYY';

      for No := 0 to Pred( Selected.Count ) do begin
        BA := TBank_Account(Selected.Objects[ No ]);
        Traverse.Clear;
        Traverse.SetSortMethod(csDateEffective);
        Traverse.SetSelectionMethod(Traverse.twAllNewEntries);
        Traverse.SetOnAHProc(DoAccountHeader);
        Traverse.SetOnATProc(DoAccountTrailer);
        Traverse.SetOnEHProc(DoRewardSuperTransaction);
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

