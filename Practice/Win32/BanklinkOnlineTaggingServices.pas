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
    class procedure BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; out AccountsExported, TransactionsExported: Integer); static;
    class function TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer; static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;

    class function IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean; static;
    class function IsExportableBankAccount(BankAccount: TBank_Account): Boolean; static;
    class function HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean; static;

    class procedure FlagTransactionsAsSent(Client: TClientObj; MaxTransactionDate: TStDate); static;
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
  Files, Globals, ErrorMoreFrm, LogUtil, StDateSt, SYDEFS, bkConst, math;

{ TBanklinkOnlineServices }

class function TBanklinkOnlineTaggingServices.TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate): Integer;
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
begin
  for Index := 0 to ChartOfAccounts.ItemCount - 1 do
  begin
    ChartOfAccounts.Account_At(Index).WriteRecToNode(ParentNode);
  end;
end;

class procedure TBanklinkOnlineTaggingServices.BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; out AccountsExported, TransactionsExported: Integer);
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
      if IsExportableBankAccount(BankAccount) and HasExportableTransactions(BankAccount, MaxTransactionDate) then
      begin
        BankAccountNode := ParentNode.OwnerDocument.CreateElement('BKBankAccount', '');

        BankAccountNode.Attributes['AccountNumber'] := BankAccount.baFields.baBank_Account_Number;

        TempTransExported := TransactionsToXML(BankAccountNode, Client, BankAccount, MaxTransactionDate);

        if TempTransExported > 0 then
        begin
          ParentNode.ChildNodes.Add(BankAccountNode);
           
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
  ClientProgressSize: Double;
  ExportedClient: TExportedClient;
  ErrorReported: Boolean;
  AccountsExported: Integer;
  TransactionsExported: Integer;
begin
  Statistics.TransactionsExported := 0;
  Statistics.AccountsExported := 0;
  Statistics.ClientFilesProcessed := 0;
  
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
                XMLDocument := XMLDoc.NewXMLDocument;

                XMLDocument.Active := True;

                try
                  XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
                  XMLDocument.Version:= '1.0';
                  XMLDocument.Encoding:= 'UTF-8';

                  RootNode := XMLDocument.AddChild('BKClientTransactions');
      
                  AccountsExported := 0;
                  TransactionsExported := 0;

                  BankAccountsToXML(RootNode, Client, ExportOptions.MaxTransactionDate, AccountsExported, TransactionsExported);

                  if TransactionsExported > 0 then
                  begin
                    if ExportOptions.ExportChartOfAccounts then
                    begin
                      try
                        //Add chart of accounts for this client
                        ChartToXML(RootNode, Client.clChart);
                      except
                        on E:Exception do
                        begin
                          LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could export the Chart of Accounts - ' + E.Message);
                        end;
                      end;
                    end;

                    XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions' + IntToStr(Index) + '.xml');

                    DoClientSave(true, Client);

                    Statistics.TransactionsExported := Statistics.TransactionsExported + TransactionsExported;
                    Statistics.AccountsExported := Statistics.AccountsExported + AccountsExported;
                    Statistics.ClientFilesProcessed := Statistics.ClientFilesProcessed + 1;
                  end;
                finally
                  XMLDocument.Active := False;
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

    ProgressForm.CompleteProgress;

    if Statistics.TransactionsExported > 0 then
    begin
      LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice successfully exported data to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ': ' + IntToStr(Statistics.TransactionsExported) + ' Transaction(s) exported, ' + IntToStr(Statistics.AccountsExported) + ' Account(s) exported ' + IntToStr(Statistics.ClientFilesProcessed) + ' Client file(s) processed.');
    end
    else
    begin
      LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice could not find any data up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ' to export to BankLink Online.');
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

  Result := True;
end;

// Update account vendors for a client
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
    ProductConfigService.SaveClientVendorExports(ClientReadDetail.Id, Vendors, true);

    for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
    begin
      if not ProgressForm.Cancelled then
      begin
        if not Client.clFields.clFile_Read_Only then
        begin
          for IIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
          begin
            BankAccount := Client.clBank_Account_List[IIndex];
            // no tagging for Journals or Provisional/Manual accounts. Temporarily removed for testing
            // if (BankAccount.baFields.baAccount_Type = btBank) and
            // (BankAccount.baFields.baBank_Account_Number[1] <> 'M') then
              UpdateAccountVendors(ClientReadDetail, BankAccount, Vendors);
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

// Update account vendors for a single account
class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; Vendors: TBloArrayOfGuid);
begin
  ProductConfigService.SaveAccountVendorExports(ClientReadDetail.Id,
                                                BankAccount.baFields.baBank_Account_Number,
                                                Vendors,
                                                True);
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
  
  for ClientIndex := 0 to Min(AdminSystem.fdSystem_Client_File_List.ItemCount -1, 99) do
  begin
    OpenAClientForRead(AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Code, Client);
    
    if Assigned(Client) then
    begin
      try
        if not Client.clFields.clFile_Read_Only then
        begin
          for AccountIndex := 0 to Min(Client.clBank_Account_List.ItemCount - 1, 2) do
          begin
            BankAccount := Client.clBank_Account_List[AccountIndex];

            if IsExportableBankAccount(BankAccount) then
            begin
              for TransactionIndex := 0 to Min(BankAccount.baTransaction_List.ItemCount - 1, 19) do
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
