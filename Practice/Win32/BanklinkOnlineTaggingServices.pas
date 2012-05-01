unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, BK_XMLHelper, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, ModalProgressFrm, OvcDate;

type
  TBanklinkOnlineTaggingServices = class
  private
    class procedure BankAccountToXML(ParentNode: IXMLNode; BankAccount: TBank_Account; MaxTransactionDate: TStDate); static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;
    class function IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate): Boolean; static;
    class function IsExportableBankAccount(BankAccount: TBank_Account): Boolean; static;
    class procedure FlagTransactionsAsSent(Client: TClientObj; MaxTransactionDate: TStDate); static;
    class function HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean; static;
  public
    class procedure UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String); static;
    class function GetMaxExportableTransactionDate: TStDate; static;
    
    class procedure ExportTaggedAccounts(MaxTransactionDate: TStDate; ExportChartOfAccounts: Boolean; ProgressFrm: TfrmModalProgress); static;
  end;

implementation

uses
  Files, Globals, ErrorMoreFrm;

{ TBanklinkOnlineServices }

class procedure TBanklinkOnlineTaggingServices.BankAccountToXML(ParentNode: IXMLNode; BankAccount: TBank_Account; MaxTransactionDate: TStDate);
var
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
  BankAccountNode: IXMLNode;
begin
  BankAccountNode := ParentNode.AddChild('BKBankAccount');

  BankAccountNode.Attributes['AccountNumber'] := BankAccount.baFields.baBank_Account_Number;

  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    Transaction := BankAccount.baTransaction_List[TransactionIndex];

    if IsExportableTransaction(Transaction, MaxTransactionDate) then    
    begin
      Transaction.WriteRecToNode(BankAccountNode);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart);
var
  Index: Integer;
begin
  for Index := 0 to ChartOfAccounts.ItemCount - 1 do
  begin
    ChartOfAccounts.Account_At(Index).WriteRecToNode(ParentNode);
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ExportTaggedAccounts(MaxTransactionDate: TStDate; ExportChartOfAccounts: Boolean; ProgressFrm: TfrmModalProgress);
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  CompressedXml: String;
  Client: TClientObj;
  ClientList: TStringList;
  ClientProgressSize: Double;
begin
  if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
  begin
    try
      ClientList := TStringList.Create;

      try
        XMLDocument := XMLDoc.NewXMLDocument;

        XMLDocument.Active := True;

        XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
        XMLDocument.Version:= '1.0';
        XMLDocument.Encoding:= 'UTF-8';

        RootNode := XMLDocument.AddChild('BKTaggedAccounts');

        ClientProgressSize := 40 / AdminSystem.fdSystem_Client_File_List.ItemCount;

        ProgressFrm.Initialize('Exporting Client Transactions'); 
    
        for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
        begin
          ProgressFrm.UpdateProgressLabel('Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code);
      
          Client := nil;

          if not ProgressFrm.Cancelled then
          begin
            try
              OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client);
            except
            end;

            if Assigned(Client) then
            begin
              try
                if not Client.clFields.clFile_Read_Only then
                begin
                  for IIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
                  begin
                    BankAccount := Client.clBank_Account_List[IIndex];

                    //Only delivered accounts can be sent
                    if IsExportableBankAccount(BankAccount) and HasExportableTransactions(BankAccount, MaxTransactionDate) then
                    begin
                      BankAccountToXML(RootNode, BankAccount, MaxTransactionDate);
                    end;
                  end;

                  if ExportChartOfAccounts then
                  begin
                    //Add chart of accounts for this client
                    ChartToXML(RootNode, Client.clChart);
                  end;

                  ClientList.Add(Client.clFields.clCode);
                end;
              finally
                FreeAndNil(Client);
              end;
            end;
          end
          else
          begin
            Break;
          end;

          ProgressFrm.UpdateProgress(ClientProgressSize);
        end;

        if not ProgressFrm.Cancelled then
        begin
          ProgressFrm.ToggleCancelEnabled(False);

          ProgressFrm.UpdateProgressLabel('Sending transactions to Banklink Online');

          //Zip the xml to reduce the size of the packet sent
          CompressedXml := ZipUtils.CompressString(XMLDocument.XML.Text);

          //Send xml to Banklink online.
          XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions.xml');

          //We don't need this anymore so release the memory
          XMLDocument.Active := False;
          XMLDocument := nil;

          if ClientList.Count > 0 then
          begin
            ProgressFrm.UpdateProgress('Saving changes to transactions', 20);
      
            ClientProgressSize := 40 / ClientList.Count;

            for Index := 0 to ClientList.Count -1 do
            begin
              OpenAClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client, True);

              if Assigned(Client) then
              begin
                try
                  FlagTransactionsAsSent(Client, MaxTransactionDate);
                finally
                  CloseAClient(Client);
                end;
              end;
              ProgressFrm.UpdateProgress(ClientProgressSize);
            end; 
          end;
          ProgressFrm.CompleteProgress;
        end;
      finally
        ClientList.Free;
      end;
    except
      on E:Exception do
      begin
        HelpfulErrorMsg('Error exporting transactions to ' + BANKLINK_ONLINE_NAME + ': ' + E.Message, 0);
      end;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.IsExportableBankAccount(BankAccount: TBank_Account): Boolean;
begin
  Result := not (BankAccount.IsManual or BankAccount.IsAJournalAccount); //and IsTagged
end;

class function TBanklinkOnlineTaggingServices.IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate): Boolean;
begin
  if MaxTransactionDate > -1 then
  begin
    Result := (Transaction.txCore_Transaction_ID <> 0) and (not Transaction.txTransfered_To_Online) and (Transaction.txDate_Transferred <= MaxTransactionDate);
  end
  else
  begin
    Result := (Transaction.txCore_Transaction_ID <> 0) and (not Transaction.txTransfered_To_Online);
  end;
end;

class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String);
begin

end;

class procedure TBanklinkOnlineTaggingServices.FlagTransactionsAsSent(Client: TClientObj; MaxTransactionDate: TStDate);
var
  Index: Integer;
  BankAccount: TBank_Account;
  Transaction: pTransaction_Rec;
  IIndex: Integer;
begin
  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := Client.clBank_Account_List[Index];

    if IsExportableBankAccount(BankAccount) then
    begin
      for IIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
      begin
        Transaction := BankAccount.baTransaction_List[IIndex];

        if IsExportableTransaction(Transaction, MaxTransactionDate) then
        begin
          Transaction.txTransfered_To_Online := True;
        end;
      end;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.GetMaxExportableTransactionDate: TStDate;
var
  ClientIndex: Integer;
  AccountIndex: Integer;
  TransactionIndex: Integer;
  Client: TClientObj;
  BankAccount: TBank_Account;
begin
  Result := -1;
  
  for ClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
  begin
    try
      OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Code, Client);
    except
    end;

    if Assigned(Client) then
    begin
      try
        if not Client.clFields.clFile_Read_Only then
        begin
          for AccountIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
          begin
            BankAccount := Client.clBank_Account_List[AccountIndex];

            if IsExportableBankAccount(BankAccount) and HasExportableTransactions(BankAccount, -1) then
            begin
              for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
              begin
                if BankAccount.baTransaction_List.Transaction_At(TransactionIndex).txDate_Effective > Result then
                begin
                  Result := BankAccount.baTransaction_List.Transaction_At(TransactionIndex).txDate_Effective;
                end;
              end;
            end;
          end;
        end;
      finally
        FreeAndNil(Client);
      end;
    end;
  end;  
end;

class function TBanklinkOnlineTaggingServices.HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean;
var
  TransactionIndex: Integer;
begin
  Result := False;

  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    if IsExportableTransaction(BankAccount.baTransaction_List[TransactionIndex], MaxTransactionDate) then
    begin
      Result := True;

      Break;
    end;
  end;
end;

end.
