unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, BK_XMLHelper, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, Progress, OvcDate, DataPlatformPractice;

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

  TFatalErrorDetails = record
    ClientCode: String;
    ErrorMessage: String;
  end;
  
  TBanklinkOnlineTaggingServices = class
  strict private
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
    class procedure BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; ClientAccountVendors: TClientAccVendors; out AccountsExported, TransactionsExported: Integer); static;
    class function TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer; static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;

    class function IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean; static;
    class function IsExportableBankAccount(BankAccount: TBank_Account; ClientAccountVendors: TClientAccVendors): Boolean; static;
    class function HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean; static;
    class function IsBankAccountTagged(BankAccount: TBank_Account; ClientAccountVendors: TClientAccVendors): Boolean; static;

    class function GetClientGuid(const ClientCode: String): TBloGuid; static;
    class procedure CleanXML(Node: IXMLNode); static;
  public
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; Client: TClientObj; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ProgressForm: ISingleProgressForm); overload; static; // Update vendors for a client
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ShowProgressBar: Boolean = True); overload; static; // Update vendors for a single account

    class procedure GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount); static;
    class procedure GetTaggedAccounts(ClientReadDetail: TBloClientReadDetail; out TaggedAccounts: array of TTaggedAccount); overload; static;
    class procedure GetTaggedAccounts(Practice: TBloPracticeRead; out TaggedAccounts: array of TTaggedAccount); overload; static;

    class procedure ResetTransactionSentFlag(BankAccount: TBank_Account; ProgressFrm: ISingleProgressForm); overload; static;
    class procedure ResetTransactionSentFlag(Client: TClientObj; ProgressFrm: ISingleProgressForm); overload; static;  
    
    class procedure ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; out Statistics: TExportStatistics; out FatalError: Boolean; out FatalErrorDetails: TFatalErrorDetails); static;
    
    class function GetMaxExportableTransactionDate(ProgressForm: ISingleProgressForm): TStDate; static;

    class function UploadXMLData(const XmlData: WideString): Boolean; static;
    class function TestDataService: Boolean; static;
  end;

implementation

uses
  Files, Globals, ErrorMoreFrm, LogUtil, StDateSt, SYDEFS, bkConst, math, WebUtils;

{ TBanklinkOnlineServices }

class function TBanklinkOnlineTaggingServices.TestDataService: Boolean;
var
  DataPlatformInterface: IDataPlatformPractice;
  Response: WideString;
begin
  Result := False;

  try
    if not Assigned(AdminSystem) then
      Exit;

    DataPlatformInterface :=  GetIDataPlatformPractice;
      
    Response := DataPlatformInterface.Echo('TEST');

    Result := Pos('TEST', Response) > 0;
  except
    on E:Exception do
    begin
      HelpfulErrorMsg('Error contacting server: ' + E.Message, 0);
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer;
var
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
  TransactionNode: IXMLNode;
begin
  Result := 0;

  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    Transaction := BankAccount.baTransaction_List[TransactionIndex];

    try
      if IsExportableTransaction(Transaction, MaxTransactionDate) then    
      begin
        TransactionNode := Transaction.WriteRecToNode(ParentNode);

        CleanXML(TransactionNode);
        
        Transaction.txTransfered_To_Online := True;

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
  ChartNode: IXMLNode;
begin
  for Index := 0 to ChartOfAccounts.ItemCount - 1 do
  begin
    ChartNode := ChartOfAccounts.Account_At(Index).WriteRecToNode(ParentNode);

    CleanXML(ChartNode);
  end;
end;

class procedure TBanklinkOnlineTaggingServices.CleanXML(Node: IXMLNode);
var
  NodeIndex: Integer;
  ChildNode: IXMLNode;
begin
  NodeIndex := 0;
  
  while NodeIndex < Node.ChildNodes.Count do
  begin
    ChildNode := Node.ChildNodes[NodeIndex];

    if Pos('COLUMNORDERS', Uppercase(ChildNode.NodeName)) > 0 then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    if Pos('COLUMNWIDTHS', Uppercase(ChildNode.NodeName)) > 0 then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    if Pos('COLUMNIS', Uppercase(ChildNode.NodeName)) > 0 then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    if Pos('HEADINGS', Uppercase(ChildNode.NodeName)) > 0 then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    if Uppercase(ChildNode.NodeName) = 'SHORTNAMES' then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    if Uppercase(ChildNode.NodeName) = 'LONGNAMES' then
    begin
      Node.ChildNodes.Delete(NodeIndex);
    end
    else
    begin
      Inc(NodeIndex);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; ClientAccountVendors: TClientAccVendors; out AccountsExported, TransactionsExported: Integer);
var
  Index: Integer;
  BankAccount: TBank_Account;
  TransactionNode: IXMLNode;
  TempTransExported: Integer;
  BankAccountNode: IXMLNode;
begin
  AccountsExported := 0;
  TransactionsExported := 0;

  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := Client.clBank_Account_List[Index];

    try
      //Only delivered accounts can be sent
      if IsExportableBankAccount(BankAccount, ClientAccountVendors) and HasExportableTransactions(BankAccount, MaxTransactionDate) then
      begin
        BankAccountNode := BankAccount.baFields.WriteRecToNode(ParentNode);

        CleanXML(BankAccountNode);
        
        TempTransExported := TransactionsToXML(BankAccountNode, Client, BankAccount, MaxTransactionDate);

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

class procedure TBanklinkOnlineTaggingServices.ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: ISingleProgressForm; out Statistics: TExportStatistics; out FatalError: Boolean; out FatalErrorDetails: TFatalErrorDetails);
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  CompressedXml: String;
  Client: TClientObj;
  ClientProgressSize: Double;
  ExportedClient: TExportedClient;
  ErrorReported: Boolean;
  AccountsExported: Integer;
  TransactionsExported: Integer;
  ClientAccountVendors: TClientAccVendors;
  ClientGuid: TBloGuid;
  ClientNode: IXMLNode;
  ExportClient: Boolean;
begin
  FatalError := False;
  
  Statistics.TransactionsExported := 0;
  Statistics.AccountsExported := 0;
  Statistics.ClientFilesProcessed := 0;

  if TestDataService then
  begin
    if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
    begin
      ProgressForm.Initialize;
      
      if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
      begin
        ClientProgressSize := 100 / AdminSystem.fdSystem_Client_File_List.ItemCount;

        for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
        begin
          ProgressForm.UpdateProgressLabel('Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code);

          ErrorReported := False;
      
          Client := nil;

          if AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Status = bkConst.fsNormal then
          begin
            try
              OpenAClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client, True);
            except
              on E:Exception do
              begin
                LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - ' + E.Message);

                ErrorReported := True;
              end;
            end;

            if Assigned(Client) then
            begin
              try
                if not Client.clFields.clFile_Read_Only then
                begin
                  ClientGuid := GetClientGuid(Client.clFields.clCode);

                  if ClientGuid <> '' then
                  begin
                    XMLDocument := XMLDoc.NewXMLDocument;

                    XMLDocument.Active := True;

                    try
                      XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
                      XMLDocument.Version:= '1.0';
                      XMLDocument.Encoding:= 'UTF-8';

                      RootNode := XMLDocument.CreateElement('BKClients', '');
      
                      AccountsExported := 0;
                      TransactionsExported := 0;

                      if not ProductConfigService.GetClientAccountsVendors(Client.clFields.clCode, ClientGuid, ClientAccountVendors, False) then
                      begin
                        FatalError := True;

                        Exit;
                      end;

                      ClientNode := Client.clFields.WriteRecToNode(RootNode);

                      CleanXML(ClientNode);
                    
                      BankAccountsToXML(ClientNode, Client, ExportOptions.MaxTransactionDate, ClientAccountVendors, AccountsExported, TransactionsExported);

                      if TransactionsExported > 0 then
                      begin
                        ExportClient := True;
                      
                        if ExportOptions.ExportChartOfAccounts then
                        begin
                          try
                            //Add chart of accounts for this client
                            ChartToXML(ClientNode, Client.clChart);
                          except
                            on E:Exception do
                            begin
                              LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could export the Chart of Accounts - ' + E.Message);

                              ExportClient := False;
                            end;
                          end;
                        end;

                        if ExportClient then
                        begin
                          XMLDocument.ChildNodes.Add(RootNode);

                          //XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions' + IntToStr(Index) + '.xml');

                          if UploadXMLData(XMLDocument.XML.Text) then
                          begin
                            DoClientSave(true, Client);

                            Statistics.TransactionsExported := Statistics.TransactionsExported + TransactionsExported;
                            Statistics.AccountsExported := Statistics.AccountsExported + AccountsExported;
                            Statistics.ClientFilesProcessed := Statistics.ClientFilesProcessed + 1;
                          end;
                        end;
                      end;
                    finally
                      XMLDocument.Active := False;
                    end;
                  end;
                end
                else
                begin
                  LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file is read-only.');
                end;
              finally
                FreeAndNil(Client);
              end;
            end
            else
            begin
              if not ErrorReported then
              begin
                LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file could not be opened or does not exist.');
              end;
            end;
          end
          else
          begin
            case AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Status of
              bkConst.fsOpen: LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file is currently open.');
              bkConst.fsCheckedOut: LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file is checked out.');
              bkConst.fsOffsite: LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file is offsite.');
            end;
          end;

          ProgressForm.UpdateProgress(ClientProgressSize);
        end;
      end;

      if not FatalError then
      begin
        ProgressForm.CompleteProgress;

        if Statistics.TransactionsExported > 0 then
        begin
          LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice successfully exported data to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ': ' + IntToStr(Statistics.TransactionsExported) + ' Transaction(s) exported, ' + IntToStr(Statistics.AccountsExported) + ' Account(s) exported ' + IntToStr(Statistics.ClientFilesProcessed) + ' Client file(s) processed.');
        end
        else
        begin
          LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice could not find any data up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ' to export to BankLink Online.');
        end;
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'The following error occurred during the export of client ' + FatalErrorDetails.ClientCode + ' : ' + FatalErrorDetails.ErrorMessage + ' BankLink Practice completed the following data export to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ': ' + IntToStr(Statistics.TransactionsExported) + ' Transaction(s) exported, ' + IntToStr(Statistics.AccountsExported) + ' Account(s) exported ' + IntToStr(Statistics.ClientFilesProcessed) + ' Client file(s) processed.');
      end;
    end;
  end
  else
  begin
    LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'The BankLink Online data export service did not respond or the response was incorrect.');

    FatalErrorDetails.ClientCode := '';
    FatalErrorDetails.ErrorMessage := 'The BankLink Online data export service is not available.';
    FatalError := True; 
  end;
end;

class function TBanklinkOnlineTaggingServices.IsBankAccountTagged(BankAccount: TBank_Account; ClientAccountVendors: TClientAccVendors): Boolean;
var
  Index: Integer;
begin
  for Index := 0 to Length(ClientAccountVendors.AccountsVendors) - 1 do
  begin
    if BankAccount.baFields.baCore_Account_ID = ClientAccountVendors.AccountsVendors[Index].CoreAccountID then
    begin
      Result := Length(ClientAccountVendors.AccountsVendors[Index].AccountVendors.Current) > 0;

      Break;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.IsExportableBankAccount(BankAccount: TBank_Account; ClientAccountVendors: TClientAccVendors): Boolean;
begin
  Result := not (BankAccount.IsManual or BankAccount.IsAJournalAccount) and (BankAccount.baFields.baCore_Account_ID > 0) and IsBankAccountTagged(BankAccount, ClientAccountVendors);
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

// Update account vendors for a client
class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; Client: TClientObj; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ProgressForm: ISingleProgressForm);
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

    if not ProgressForm.Cancelled then
    begin
      if not Client.clFields.clFile_Read_Only then
      begin
        for IIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
        begin
          BankAccount := Client.clBank_Account_List[IIndex];
          if ProductConfigService.IsExportDataEnabledFoAccount(BankAccount) then
            if not ProductConfigService.CheckGuidArrayEquality(OriginalVendors, ModifiedVendors) then // No need to update the accounts if the vendors haven't changed            
              UpdateAccountVendors(ClientReadDetail, BankAccount, OriginalVendors, ModifiedVendors, False);
        end;
      end;
    end;
    ProgressForm.UpdateProgress(ClientProgressSize);

  except
    on E:Exception do
    begin
      HelpfulErrorMsg('Error exporting transactions to ' + BANKLINK_ONLINE_NAME + ': ' + E.Message, 0);
    end;
  end;
end;

// Update account vendors for a single account
class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ShowProgressBar: boolean = True);
var
  AccountVendors: TBloDataPlatformSubscription;
  ClientVendorsAdded, AccountVendorsModified: TBloArrayOfGuid;
  i, j, AccountVendorsLength: integer;
  FoundVendor: boolean;
  ClientGuid: TBloGuid;
begin
  // Creating list of vendors that have been added to the client
  for i := 0 to High(ModifiedVendors) do
  begin
    FoundVendor := False;
    for j := 0 to High(OriginalVendors) do
    begin
      if (ModifiedVendors[i] = OriginalVendors[j]) then
      begin
        FoundVendor := True; // Vendor was already there, it has not been added
        break;
      end;
    end;
    if not FoundVendor then // This is a new vendor
      ProductConfigService.AddItemToArrayGuid(ClientVendorsAdded, ModifiedVendors[i]);
  end;

  if Assigned(ClientReadDetail) then
    ClientGuid := ClientReadDetail.Id
  else
    ClientGuid := ProductConfigService.GetClientGuid(MyClient.clFields.clCode);
  AccountVendors := ProductConfigService.GetAccountVendors(ClientGuid,
                                                           BankAccount.baFields.baBank_Account_Number,
                                                           ShowProgressBar);

  // Creating list of vendors that the account currently has. Note that, when the
  // user removes a vendor from a client, this change should NOT recurse down to
  // its accounts (nor should removing a vendor from a practice recurse to its
  // clients)
  for i := 0 to High(AccountVendors.Current) do
    ProductConfigService.AddItemToArrayGuid(AccountVendorsModified, AccountVendors.Current[i].Id);

  // Adding vendors which have just been added to the client to the list
  // of account vendors
  for i := 0 to High(ClientVendorsAdded) do
    ProductConfigService.AddItemToArrayGuid(AccountVendorsModified, ClientVendorsAdded[i]);

  // Save account vendors
  ProductConfigService.SaveAccountVendorExports(ClientGuid,
                                                BankAccount.baFields.baCore_Account_ID,
                                                AccountVendorsModified,
                                                False,
                                                False);
end;

class function TBanklinkOnlineTaggingServices.UploadXMLData(const XmlData: WideString): Boolean;
var
  DataPlatformInterface: IDataPlatformPractice;
begin
  Result := False;
  
  try
    if not Assigned(AdminSystem) then
      Exit;

    DataPlatformInterface :=  GetIDataPlatformPractice;
      
    Result := DataPlatformInterface.UploadData(CountryText(AdminSystem.fdFields.fdCountry),
                                                           AdminSystem.fdFields.fdBankLink_Code,
                                                           AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                           XmlData);

  except
    on E:Exception do
    begin
      HelpfulErrorMsg('Error sending xml data: ' + E.Message, 0);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount);
begin

end;

class function TBanklinkOnlineTaggingServices.GetClientGuid(const ClientCode: String): TBloGuid;
var
  Index: Integer;
begin
  Result := '';
  
  if Assigned(ProductConfigService.Clients) then
  begin
    for Index := 0 to Length(ProductConfigService.Clients.Clients) - 1 do
    begin
      if ProductConfigService.Clients.Clients[Index].ClientCode = ClientCode then
      begin
        Result := ProductConfigService.Clients.Clients[Index].Id;

        Break;
      end;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.GetMaxExportableTransactionDate(ProgressForm: ISingleProgressForm): TStDate;
var
  ClientIndex: Integer;
  AccountIndex: Integer;
  TransactionIndex: Integer;
  Client: TClientObj;
  BankAccount: TBank_Account;
  Transaction: pTransaction_Rec;
  ClientProgressStepSize: Double;
  ClientAccountVendors: TClientAccVendors;
  ClientGuid: TBloGuid;
begin
  Result := -1;

  if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
  begin
    ClientProgressStepSize := 100 / AdminSystem.fdSystem_Client_File_List.ItemCount;

    ProgressForm.UpdateProgressLabel('Checking client files and bank accounts'); 

    for ClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
    begin
      if AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Status = bkConst.fsNormal then
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
              ClientGuid := TBanklinkOnlineTaggingServices.GetClientGuid(Client.clFields.clCode);
              
              if ClientGuid <> '' then
              begin
                if not ProductConfigService.GetClientAccountsVendors(Client.clFields.clCode, ClientGuid, ClientAccountVendors, False) then
                begin
                  Result := -1;

                  Exit;
                end;
              
                if Length(ClientAccountVendors.AccountsVendors) > 0 then
                begin
                  for AccountIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
                  begin
                    BankAccount := Client.clBank_Account_List[AccountIndex];

                    if IsExportableBankAccount(BankAccount, ClientAccountVendors) then
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
              end;
            end;
          finally
            FreeAndNil(Client);
          end;
        end;
      end;

      ProgressForm.UpdateProgress(ClientProgressStepSize); 
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
