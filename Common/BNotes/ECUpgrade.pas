// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
unit ECUpgrade;

interface

// ----------------------------------------------------------------------------

uses
  ecObj;

procedure UpgradeClientToLatestVersion(aClient : TEcClient );

// ----------------------------------------------------------------------------

implementation

uses
  ecBankAccountObj, ECDEFS, BKCONST, ECollect, ECPayeeObj, ECPLIO, glConst;

// ----------------------------------------------------------------------------

const
  DebugMe  : Boolean = False;
  UnitName = 'UPGRADE';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UpgradeClientToLatestVersion( aClient : TEcClient );
const
  MethodName = 'UpgradeClientToLatestVersion';

  procedure UpgradeToVersion12;
  var
    i: integer;
    BankAccount : TEcBank_Account;
  begin
    for i := 0 to aClient.ecBankAccounts.ItemCount - 1 do
    begin
      BankAccount := aClient.ecBankAccounts.Bank_Account_At(i);
      BankAccount.baFields.baCurrency_Code:=whCurrencyCodes[aClient.ecFields.ecCountry];
    end;
  end;

  procedure UpgradeToVersion11;
  begin
    aClient.ecFields.ecHide_Job_Col := true; //hide by default since there will be no data.
  end;

  procedure UpgradeToVersion06;
  var
    i, j : Integer;
    BankAccount : TEcBank_Account;
    pT : pTransaction_Rec;
    pD : pDissection_Rec;    
    p: TECPayee;
    PLine: pPayee_Line_Rec;
  begin
    // upgrade quantities
    for i := 0 to aClient.ecBankAccounts.ItemCount - 1 do
    begin
      BankAccount := aClient.ecBankAccounts.Bank_Account_At(i);
      for j := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
      begin
        pT := BankAccount.baTransaction_List.Transaction_At(j);
        if pT.txFirst_Dissection = nil then begin
          pT^.txQuantity := pT^.txQuantity * 10;
        end
        else begin
           pD := pT.txFirst_Dissection;
           while (pD <> nil) do with pD^ do begin
              pD.dsQuantity := pD.dsQuantity * 10;
              pD := pD^.dsNext;
           end;
        end;
      end;
    end;
    // upgrade GST rates
    for i := 1 to MAX_GST_CLASS do
    begin
      for j := 1 to MAX_VISIBLE_GST_CLASS_RATES do
        aClient.ecFields.ecGST_Rates[ i, j ] := aClient.ecFields.ecGST_Rates[ i, j ] * 100;
    end;
    // upgrade payees
    for i := aClient.ecPayees.First to aClient.ecPayees.Last do
    begin
      p := aClient.ecPayees.Payee_At(i);
      for j := p.pdLines.First to p.pdLines.Last do
      begin
        PLine := p.pdLines.PayeeLine_At(j);
        if PLine.plLine_Type = pltPercentage then
          PLine.plPercentage := PLine.plPercentage * 100;
      end;
    end;
  end;

  procedure UpgradeToVersion03;
  const
    Max_Py_Lines_V53 = 50;  //version 5.3
  var
    OldPayee : pPayee_Rec;
    NewPayee : TECPayee;
    NewPayeeLine : pPayee_Line_Rec;
    i,j      : integer;
  begin
    for i := 0 to aClient.ecPayees_V53.ItemCount-1 do
    begin
      OldPayee := aClient.ecPayees_V53.Payee_At(i);
      NewPayee := ECPayeeObj.TECPayee.Create;

      NewPayee.pdFields.pdNumber := OldPayee^.pyNumber;
      NewPayee.pdFields.pdName   := OldPayee^.pyName;

      for j := 1 to Max_Py_Lines_V53 do
        begin
          if OldPayee^.pyAccount[j] <> '' then
            begin
              //assume is a valid line if account exists
              NewPayeeLine := ECPLIO.New_Payee_Line_Rec;
              NewPayeeLine.plAccount := OldPayee.pyAccount[j];
              NewPayeeLine.plPercentage := OldPayee.pyPercentage[j];
              NewPayeeLine.plGST_Class := OldPayee.pyGST_Class[j];
              NewPayeeLine.plGST_Has_Been_Edited := OldPayee.pyGST_Has_Been_Edited[j];
              //NewPayeeLine.plGL_Narration := OldPayee.pyGL_Narration[j];
              NewPayeeLine.plLine_Type := pltPercentage;

              NewPayee.pdLines.Insert( NewPayeeLine);
            end;
        end;
      aClient.ecPayees.Insert( NewPayee);
    end;

    //verify upgrade
    Assert( aClient.ecPayees.ItemCount = aClient.ecPayees_V53.ItemCount, 'aClient.ecPayee_List_Ex.ItemCount = aClient.ecPayee_List.ItemCount');
    aClient.ecPayees.CheckIntegrity;

    //remove all items from the old list
    aClient.ecPayees_V53.FreeAll;
  end;

  procedure UpgradeToVersion02;
  var
    i, j : Integer;
    BankAccount : TEcBank_Account;
    pT : pTransaction_Rec;
  begin
    //copy particulars and other party to narration
    for i := 0 to aClient.ecBankAccounts.ItemCount - 1 do
    begin
      BankAccount := aClient.ecBankAccounts.Bank_Account_At(i);
      for j := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
      begin
        pT := BankAccount.baTransaction_List.Transaction_At(j);
        if (pT.txOther_Party <> '') then
        begin
          pT.txNarration := pT.txNarration + ' ' + pT.txOther_Party;
          pT.txOther_Party := '';
        end;
        if (pT.txParticulars <> '') and (pT.txParticulars <> pT.txOther_Party) then
        begin
          pT.txNarration := pT.txNarration + ' ' + pT.txParticulars;
          pT.txParticulars := '';
        end;
      end;
    end;
  end;

begin
  if (aClient.ecFields.ecFile_Version = EC_FILE_VERSION) then
    Exit;

  if (aClient.ecFields.ecFile_Version < 02) and (aClient.ecFields.ecCountry = whNewZealand) then
  begin
    UpgradeToVersion02;
    aClient.ecFields.ecFile_Version := 02;
  end;

  if (aClient.ecFields.ecFile_Version < 03) then
  begin
    UpgradeToVersion03;
    aClient.ecFields.ecFile_Version := 03;
  end;

  if (aClient.ecFields.ecFile_Version < 06) then
  begin
    UpgradeToVersion06;
    aClient.ecFields.ecFile_Version := 06;
  end;

  if (aClient.ecFields.ecFile_Version < 11) then
  begin
    UpgradeToVersion11;
    aClient.ecFields.ecFile_Version := 11;
  end;

  if (aClient.ecFields.ecFile_Version < 12) then
  begin
    UpgradeToVersion12;
    aClient.ecFields.ecFile_Version := 12;
  end;
  

  //upgrade file to latest version
  if (aClient.ecFields.ecFile_Version < EC_FILE_VERSION) then
    aClient.ecFields.ecFile_Version := EC_FILE_VERSION;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
