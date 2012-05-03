unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, BK_XMLHelper, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, Progress, OvcDate;

type
  TExportOptions = record
    MaxTransactionDate: TStDate;
    ExportChartOfAccounts: Boolean;
  end;
  
  TTaggedAccount = record
    AccountNo: WideString;
    VendorNames: TBloArrayOfString;
    VendorGuids: TBloArrayOfGuid;
  end;

  TExportStatistics = record
    TransactionsExported: Integer;
    AccountsExported: Integer;
    ClientFilesProcessed: Integer;
  end;
  
  TBanklinkOnlineTaggingServices = class
  private
    type
      TExportedClient = class
      strict private
        FClientCode: String;
        FTransactionsExported: Integer;
        FAccountsExported: Integer;
      public
        constructor Create(const ClientCode: String; ExportedAccounts, ExportedTransactions: Integer);
         
        property ClientCode: String read FClientCode;
        property TransactionsExports: Integer read FTransactionsExported;
        property AccountsExported: Integer read FAccountsExported;
      end;

  private
    class procedure ExportTaggedClientsToXML(ParentNode: IXMLNode; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; ExportedClients: TObjectList); static;
    class procedure ClientToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; out AccountsExported, TransactionsExported: Integer); static;
    class function BankAccountToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer; static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;
    class function IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean; static;
    class function IsExportableBankAccount(BankAccount: TBank_Account): Boolean; static;
    class procedure FlagTransactionsAsSent(Client: TClientObj; MaxTransactionDate: TStDate); static;
    class function HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean; static;
  public
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; Vendors: TBloArrayOfGuid); overload; static;  
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; Client: TClientObj; Vendors: TBloArrayOfGuid; ProgressForm: ISingleProgressForm); overload; static;  
     
    class procedure GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount); static;
    class procedure GetTaggedAccounts(ClientReadDetail: TBloClientReadDetail; out TaggedAccounts: array of TTaggedAccount); overload; static;
    class procedure GetTaggedAccounts(Practice: TBloPracticeRead; out TaggedAccounts: array of TTaggedAccount); overload; static;

    class procedure ResetTransactionSentFlag(BankAccount: TBank_Account; ProgressFrm: ISingleProgressForm); overload; static;
    class procedure ResetTransactionSentFlag(Client: TClientObj; ProgressFrm: ISingleProgressForm); overload; static;  
    
    class procedure ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; out Statistics: TExportStatistics); static;
    
    class function GetMaxExportableTransactionDate: TStDate; static;
  end;

implementation

uses
  Files, Globals, ErrorMoreFrm, LogUtil;

{ TBanklinkOnlineServices }

class function TBanklinkOnlineTaggingServices.BankAccountToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer;
var
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
begin
  Result := 0;

  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    Transaction := BankAccount.baTransaction_List[TransactionIndex];

    try
      if IsExportableTransaction(Transaction, MaxTransactionDate) then    
      begin
        Transaction.WriteRecToNode(ParentNode);
        
        Inc(Result);
      end;
    except
      on E:Exception do
      begin
        LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Bank Account ' + BankAccount.baFields.baBank_Account_Number + ' ' + Client.clFields.clCode + ' could not be exported - ' + E.Message);
      end;
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

class procedure TBanklinkOnlineTaggingServices.ClientToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; out AccountsExported, TransactionsExported: Integer);
var
  Index: Integer;
  BankAccount: TBank_Account;
  TransactionNode: IXMLNode;
  TempTransExported: Integer;    
begin
  AccountsExported := 0;
  TransactionsExported := 0;

  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := Client.clBank_Account_List[Index];

    try
      //Only delivered accounts can be sent
      if IsExportableBankAccount(BankAccount) and HasExportableTransactions(BankAccount, MaxTransactionDate) then
      begin
        TempTransExported := BankAccountToXML(ParentNode, Client, BankAccount, MaxTransactionDate);

        if TempTransExported > 0 then
        begin
          TransactionsExported := TransactionsExported + TempTransExported;
          
          Inc(AccountsExported);
        end;
      end;
    except
      on E:Exception do
      begin
        LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Bank Account ' + BankAccount.baFields.baBank_Account_Number + ' ' + Client.clFields.clCode + ' could not be exported - ' + E.Message);
      end;
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ResetTransactionSentFlag(BankAccount: TBank_Account; ProgressFrm: ISingleProgressForm);
var
  Index: Integer;
  ClientProgressSize: Double;
begin
  ProgressFrm.Initialize;

  if BankAccount.baTransaction_List.ItemCount > 0 then
  begin
    ClientProgressSize := 100 / BankAccount.baTransaction_List.ItemCount;

    ProgressFrm.UpdateProgressLabel('Clearing sent to BankLink Online');

    for Index := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
    begin
      BankAccount.baTransaction_List.Transaction_At(Index).txTransfered_To_Online := False;

      ProgressFrm.UpdateProgress(ClientProgressSize);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ResetTransactionSentFlag(Client: TClientObj; ProgressFrm: ISingleProgressForm);
var
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  ClientProgressSize: Double;
begin
  ProgressFrm.Initialize;

  if Client.clBank_Account_List.ItemCount > 0 then
  begin
    ClientProgressSize := 100 / Client.clBank_Account_List.ItemCount;

    ProgressFrm.UpdateProgressLabel('Clearing sent to BankLink Online');

    for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
    begin
      BankAccount := Client.clBank_Account_List[Index];

      for IIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
      begin
        BankAccount.baTransaction_List.Transaction_At(Index).txTransfered_To_Online := False;
      end;

      ProgressFrm.UpdateProgress(ClientProgressSize);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; out Statistics: TExportStatistics);
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  CompressedXml: String;
  Client: TClientObj;
  ClientList: TObjectList;
  TaggedAccounts: array of TTaggedAccount;
  ClientProgressSize: Double;
begin
  Statistics.TransactionsExported := 0;
  Statistics.AccountsExported := 0;
  Statistics.ClientFilesProcessed := 0;
  
  if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
  begin
    ClientList := TObjectList.Create(True);

    try
      XMLDocument := XMLDoc.NewXMLDocument;

      XMLDocument.Active := True;

      XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
      XMLDocument.Version:= '1.0';
      XMLDocument.Encoding:= 'UTF-8';

      RootNode := XMLDocument.AddChild('BKTaggedAccounts');

      ProgressForm.Initialize; 

      ProgressForm.UpdateProgressLabel('Getting account vendors');
         
      GetTaggedAccounts(Practice, TaggedAccounts);
    
      ProgressForm.UpdateProgress(10);

      ExportTaggedClientsToXML(RootNode, ExportOptions, ProgressForm, ClientList);

      ProgressForm.ToggleCancelEnabled(False);

      if not ProgressForm.Cancelled then
      begin
        ProgressForm.UpdateProgressLabel('Sending transactions to Banklink Online');

        //Zip the xml to reduce the size of the packet sent
        CompressedXml := ZipUtils.CompressString(XMLDocument.XML.Text);

        //Send xml to Banklink online.
        XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions.xml');

        //We don't need this anymore so release the memory
        XMLDocument.Active := False;
        XMLDocument := nil;

        if ClientList.Count > 0 then
        begin
          ProgressForm.UpdateProgress('Saving changes to transactions', 10);
      
          ClientProgressSize := 40 / ClientList.Count;

          for Index := 0 to ClientList.Count -1 do
          begin
            OpenAClient(TExportedClient(ClientList[Index]).ClientCode, Client, True);

            if Assigned(Client) then
            begin
              try
                FlagTransactionsAsSent(Client, ExportOptions.MaxTransactionDate);
              finally
                CloseAClient(Client);
              end;
            end;
            ProgressForm.UpdateProgress(ClientProgressSize);
          end; 
        end;

        ProgressForm.CompleteProgress;
      end;
    finally
      ClientList.Free;
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ExportTaggedClientsToXML(ParentNode: IXMLNode; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; ExportedClients: TObjectList);
var
  ClientProgressSize: Double;
  Client: TClientObj;
  AccountsExported: Integer;
  TransactionsExported: Integer;
  Index: Integer;
  ClientNode: IXMLNode;
begin
  if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
  begin
    ClientProgressSize := 40 / AdminSystem.fdSystem_Client_File_List.ItemCount;

    for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
    begin
      ProgressForm.UpdateProgressLabel('Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code);

      Client := nil;

      if not ProgressForm.Cancelled then
      begin
        try
          OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client);
        except
          on E:Exception do
          begin
            LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - ' + E.Message); 
          end;
        end;

        if Assigned(Client) then
        begin
          try
            if not Client.clFields.clFile_Read_Only then
            begin
              AccountsExported := 0;
              TransactionsExported := 0;

              ClientToXML(ParentNode, Client, ExportOptions.MaxTransactionDate, AccountsExported, TransactionsExported);

              if TransactionsExported > 0 then
              begin
                if ExportOptions.ExportChartOfAccounts then
                begin
                  try
                    //Add chart of accounts for this client
                    ChartToXML(ParentNode, Client.clChart);
                  except
                    on E:Exception do
                    begin
                      LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could export the Chart of Accounts - ' + E.Message);
                    end;
                  end;
                end;

                ExportedClients.Add(TExportedClient.Create(Client.clFields.clCode, AccountsExported, TransactionsExported));
              end;
            end
            else
            begin
              LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client is read-only.');
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

      ProgressForm.UpdateProgress(ClientProgressSize);
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.IsExportableBankAccount(BankAccount: TBank_Account): Boolean;
begin
  Result := not (BankAccount.IsManual or BankAccount.IsAJournalAccount); //and IsTagged
end;

class function TBanklinkOnlineTaggingServices.IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean;
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

class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; Client: TClientObj; Vendors: TBloArrayOfGuid; ProgressForm: ISingleProgressForm);
var
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  ClientProgressSize: Double;
begin
  try
    ProgressForm.Initialize;

    if (Client.clBank_Account_List.ItemCount = 0) then Exit; 
    ClientProgressSize := 100 / Client.clBank_Account_List.ItemCount -1;
  
    ProgressForm.UpdateProgressLabel('Updating bank account vendors for client ' + Client.clFields.clCode);
   
    for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
    begin     
      if not ProgressForm.Cancelled then
      begin
        if not Client.clFields.clFile_Read_Only then
        begin
          for IIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
          begin
            BankAccount := Client.clBank_Account_List[IIndex];
          end;
        end;
      end
      else
      begin
        Break;
      end;

      ProgressForm.UpdateProgress(ClientProgressSize);     
    end;
  except
    on E:Exception do
    begin
      HelpfulErrorMsg('Error exporting transactions to ' + BANKLINK_ONLINE_NAME + ': ' + E.Message, 0);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; Vendors: TBloArrayOfGuid);
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

class procedure TBanklinkOnlineTaggingServices.GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount);
begin

end;

class function TBanklinkOnlineTaggingServices.GetMaxExportableTransactionDate: TStDate;
var
  ClientIndex: Integer;
  AccountIndex: Integer;
  TransactionIndex: Integer;
  Client: TClientObj;
  BankAccount: TBank_Account;
  Transaction: pTransaction_Rec;
begin
  Result := -1;
  
  for ClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
  begin
    OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Code, Client);
    
    if Assigned(Client) then
    begin
      try
        if not Client.clFields.clFile_Read_Only then
        begin
          for AccountIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
          begin
            BankAccount := Client.clBank_Account_List[AccountIndex];

            if IsExportableBankAccount(BankAccount) then
            begin
              for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
              begin
                Transaction := BankAccount.baTransaction_List[TransactionIndex];
                
                if IsExportableTransaction(Transaction) then
                begin
                  if Transaction.txDate_Effective > Result then
                  begin
                    Result := Transaction.txDate_Effective;
                  end;
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

class procedure TBanklinkOnlineTaggingServices.GetTaggedAccounts(Practice: TBloPracticeRead; out TaggedAccounts: array of TTaggedAccount);
begin

end;

class procedure TBanklinkOnlineTaggingServices.GetTaggedAccounts(ClientReadDetail: TBloClientReadDetail; out TaggedAccounts: array of TTaggedAccount);
begin

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

{ TBanklinkOnlineTaggingServices.TExportedClient }

constructor TBanklinkOnlineTaggingServices.TExportedClient.Create(const ClientCode: String; ExportedAccounts, ExportedTransactions: Integer);
begin
  FClientCode := ClientCode;
  FAccountsExported := ExportedAccounts;
  FTransactionsExported := ExportedTransactions;
end;

end.
