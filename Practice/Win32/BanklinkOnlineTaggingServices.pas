unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, Progress, OvcDate;

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
    ErrorCode: Integer;
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

      TTransactionExporter = class
      private
        FProgressControl: IProgressControl;
        FProgressWeight: Double;
        FLastStepSize: Double;

        procedure OnSendTransactions(Sent: Integer; Total: Integer);
      public
        function SendTransactionData(TransactionData: String; ProgressWeight: Double; ProgressControl: IProgressControl; out AuthenticationError: Boolean): TBloUploadResult;
      end;

  private
    class procedure BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount; TransactionsExported: TList; ProgressControl: IProgressControl; ProgressWeight: Double; out AccountsExported: Integer); static;
    class procedure TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate; TransactionsExported: TList); static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;
    class function AddDeletedTransactionsToXML(ParentNode: IXMLNode; Client: TClientObj): Integer; static;
    class procedure ClearDeletedTransactions(Client: TClientObj); static;
    class function HasDeletedTransactions(Client: TClientObj): Boolean; static;
    
    class function IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean; static;
    class function IsExportableBankAccount(BankAccount: TBank_Account; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount): Boolean; static;
    class function HasExportableTransactions(BankAccount: TBank_Account; MaxTransactionDate: TStDate): Boolean; static;
    class function IsBankAccountTagged(BankAccount: TBank_Account; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount): Boolean; static;

    class procedure CleanXML(Node: IXMLNode); static;
  public
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; Client: TClientObj; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ProgressForm: ISingleProgressForm); overload; static; // Update vendors for a client
    class procedure UpdateAccountVendors(ClientReadDetail: TBloClientReadDetail; BankAccount: TBank_Account; OriginalVendors, ModifiedVendors: TBloArrayOfGuid; ShowProgressBar: Boolean = True); overload; static; // Update vendors for a single account

    class procedure GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount); static;
    class procedure GetTaggedAccounts(ClientReadDetail: TBloClientReadDetail; out TaggedAccounts: array of TTaggedAccount); overload; static;
    class procedure GetTaggedAccounts(Practice: TBloPracticeRead; out TaggedAccounts: array of TTaggedAccount); overload; static;

    class procedure ResetTransactionSentFlag(BankAccount: TBank_Account; ProgressFrm: ISingleProgressForm); overload; static;
    class procedure ResetTransactionSentFlag(Client: TClientObj; ProgressFrm: ISingleProgressForm); overload; static;  
    
    class procedure ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: IDualProgressForm; out Statistics: TExportStatistics; out FatalError: Boolean; out FatalErrorDetails: TFatalErrorDetails); static;
    
    class function GetMaxExportableTransactionDate(ProgressForm: ISingleProgressForm): TStDate; static;

    class function TestDataService: Boolean; static;
  end;

implementation

uses
  Files, Globals, ErrorMoreFrm, LogUtil, StDateSt, SYDEFS, BK_TransactionExportXMLHelper, bkConst, math, WebUtils, DirUtils, TransactionUtils, SoapHTTPClient, InfoMoreFrm, BKUTIL32;

var
  DebugMe : Boolean = False;

{ TBanklinkOnlineServices }

class function TBanklinkOnlineTaggingServices.TestDataService: Boolean;
var
  Response: WideString;
begin
  {
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
  }

  Result := True;
end;

class procedure TBanklinkOnlineTaggingServices.TransactionsToXML(ParentNode: IXMLNode; Client: TClientObj; BankAccount: TBank_Account; MaxTransactionDate: TStDate; TransactionsExported: TList);
var
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
  TransactionNode: IXMLNode;
  Dissection: pDissection_Rec;
  DissectionNode: IXMLNode;
  TransactionGuid: String;
  IdNode: IXMLNode;
  TransactionCoreId: Int64;
begin
  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    Transaction := BankAccount.baTransaction_List[TransactionIndex];

    try
      if IsExportableTransaction(Transaction, MaxTransactionDate) then
      begin
        CheckExternalGUID(Transaction);

        TransactionNode := Transaction.WriteRecToNode(ParentNode);

        TransactionCoreId := GetTransCoreID(Transaction);

        TransactionNode.Attributes['CoreTransactionID'] := TransactionCoreId;

        IdNode := TransactionNode.OwnerDocument.CreateNode('Id', ntAttribute, '');

        IdNode.NodeValue := Transaction.txExternal_GUID;

        TransactionNode.AttributeNodes.Add(IdNode);

        CleanXML(TransactionNode);

        Dissection := Transaction.txFirst_Dissection;

        while Dissection <> nil do
        begin
          CheckExternalGuid(Dissection);

          DissectionNode := Dissection.WriteRecToNode(TransactionNode);

          IdNode := DissectionNode.OwnerDocument.CreateNode('Id', ntAttribute, '');

          IdNode.NodeValue := Dissection.dsExternal_GUID;

          DissectionNode.AttributeNodes.Add(IdNode);

          CleanXML(DissectionNode);

          Dissection := Dissection.dsNext;
        end;

        TransactionsExported.Add(Transaction);
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
  TempNode: IXMLNode;
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

  if (Uppercase(Node.NodeName) = 'BKTRANSACTION') then
  begin
    TempNode := Node.AttributeNodes.FindNode('CoreTransactionIDHigh');

    if Assigned(TempNode) then
    begin
      Node.AttributeNodes.Remove(TempNode); 
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.ClearDeletedTransactions(Client: TClientObj);
var
  Index: Integer;
begin
  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    Client.clBank_Account_List.Bank_Account_At(Index).baDeleted_Transaction_List.DeleteAll;
  end;
end;

class function TBanklinkOnlineTaggingServices.AddDeletedTransactionsToXML(ParentNode: IXMLNode; Client: TClientObj): Integer;
var
  Index: Integer;
  BankAccount: TBank_Account;
  IIndex: Integer;
  ChildNode: IXMLNode;
  DeletedTransaction: pDeleted_Transaction_Rec;
  TransactionCoreId: Int64;
begin
  Result := 0;
  
  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    BankAccount := Client.clBank_Account_List.Bank_Account_At(Index);

    for IIndex := 0 to BankAccount.baDeleted_Transaction_List.ItemCount - 1 do
    begin
      DeletedTransaction := BankAccount.baDeleted_Transaction_List.Transaction_At(IIndex);
      
      ChildNode := ParentNode.AddChild('BKDeletedTransaction');
      ChildNode.Attributes['Id'] := DeletedTransaction.dxExternal_GUID;

      Int64Rec(TransactionCoreId).Lo := DeletedTransaction.dxCore_Transaction_ID;
      Int64Rec(TransactionCoreId).Hi := DeletedTransaction.dxCore_Transaction_ID_High;

      ChildNode.Attributes['CoreTransactionID'] := TransactionCoreId;

      Inc(Result);
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.BankAccountsToXML(ParentNode: IXMLNode; Client: TClientObj; MaxTransactionDate: TStDate; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount; TransactionsExported: TList; ProgressControl: IProgressControl; ProgressWeight: Double; out AccountsExported: Integer);
var
  Index: Integer;
  BankAccount: TBank_Account;
  TransactionNode: IXMLNode;
  TempTransExported: Integer;
  BankAccountNode: IXMLNode;
  StepSize: Double;
begin
  AccountsExported := 0;

  if Client.clBank_Account_List.ItemCount > 0 then
  begin
    StepSize := ProgressWeight / Client.clBank_Account_List.ItemCount;

    for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
    begin
      BankAccount := Client.clBank_Account_List[Index];

      try
        //Only delivered accounts can be sent
        if IsExportableBankAccount(BankAccount, ClientBankAccountVendors) and HasExportableTransactions(BankAccount, MaxTransactionDate) then
        begin
          BankAccountNode := ParentNode.OwnerDocument.CreateElement('BKBankAccount', '');

          BankAccountNode.Attributes['CoreId'] := BankAccount.baFields.baCore_Account_ID;
          BankAccountNode.Attributes['BankAccountNumber'] := BankAccount.baFields.baBank_Account_Number;
          BankAccountNode.Attributes['BankAccountName'] := BankAccount.baFields.baBank_Account_Name;  

          TempTransExported := TransactionsExported.Count;
        
          TransactionsToXML(BankAccountNode, Client, BankAccount, MaxTransactionDate, TransactionsExported);

          if TransactionsExported.Count - TempTransExported > 0 then
          begin
            Inc(AccountsExported);

            ParentNode.ChildNodes.Add(BankAccountNode); 
          end;
        end;

        ProgressControl.UpdateProgress(StepSize); 
      except
        on E:Exception do
        begin
          LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Bank Account ' + BankAccount.baFields.baBank_Account_Number + ' ' + Client.clFields.clCode + ' could not be exported - ' + E.Message);
        end;
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

class procedure TBanklinkOnlineTaggingServices.ExportTaggedAccounts(Practice: TBloPracticeRead; ExportOptions: TExportOptions; ProgressForm: IDualProgressForm; out Statistics: TExportStatistics; out FatalError: Boolean; out FatalErrorDetails: TFatalErrorDetails);
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  IIndex: Integer;
  CompressedXml: String;
  Client: TClientObj;
  ClientProgressSize: Double;
  ExportedClient: TExportedClient;
  ErrorReported: Boolean;
  AccountsExported: Integer;
  ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount;
  ClientGuid: TBloGuid;
  ClientNode: IXMLNode;
  ExportClient: Boolean;
  TransactionsExported: TList;
  ServiceResponse: TBloUploadResult;
  ServiceErrors: String;
  ExportTransactionsWeight: Integer;
  AuthenticationError: Boolean;
  DeletedTransactions: IXMLNode;
begin
  FatalError := False;

  try
    Statistics.TransactionsExported := 0;
    Statistics.AccountsExported := 0;
    Statistics.ClientFilesProcessed := 0;

    if ExportOptions.ExportChartOfAccounts then
    begin
      ExportTransactionsWeight := 50;
    end
    else
    begin
      ExportTransactionsWeight := 60;
    end;

    if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
    begin
      ProgressForm.Initialize;
      
      if AdminSystem.fdSystem_Client_File_List.ItemCount > 0 then
      begin
        ClientProgressSize := 100 / AdminSystem.fdSystem_Client_File_List.ItemCount;

        for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
        begin                                                                                                                                                       
          ProgressForm.SecondaryProgress.Initialize;
          
          ProgressForm.PrimaryProgress.UpdateProgressLabel('Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code);

          ErrorReported := False;
      
          Client := nil;

          if AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Status = bkConst.fsNormal then
          begin
            try
              OpenAClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client, True);

              ProgressForm.SecondaryProgress.UpdateProgress(10);
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
                  ClientGuid := ProductConfigService.Clients.GetClientGuid(Client.clFields.clCode);

                  if ClientGuid <> '' then
                  begin
                    XMLDocument := XMLDoc.NewXMLDocument;

                    XMLDocument.Active := True;

                    try
                      XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
                      XMLDocument.Version:= '1.0';
                      XMLDocument.Encoding:= 'UTF-8';

                      RootNode := XMLDocument.CreateElement('BKClients', '');

                      if not (ProductConfigService.GetClientBankAccounts(ClientGuid, ClientBankAccountVendors, False, False) in [bloSuccess, bloFailedNonFatal]) then
                      begin
                        FatalError := True;

                        Exit;
                      end;
                               
                      ProgressForm.SecondaryProgress.UpdateProgress(10);
                      
                      ClientNode := RootNode.AddChild('BKClient');

                      ClientNode.Attributes['Id'] := ClientGuid;
                                    
                      AccountsExported := 0;
                      
                      TransactionsExported := TList.Create;

                      try
                        BankAccountsToXML(ClientNode, Client, ExportOptions.MaxTransactionDate, ClientBankAccountVendors, TransactionsExported, ProgressForm.SecondaryProgress, ExportTransactionsWeight, AccountsExported);

                        if (TransactionsExported.Count > 0) or (HasDeletedTransactions(Client)) then
                        begin
                          ExportClient := True;

                          if ExportOptions.ExportChartOfAccounts and (TransactionsExported.Count > 0) then
                          begin
                            try
                              //Add chart of accounts for this client
                              ChartToXML(ClientNode, Client.clChart);

                              ProgressForm.SecondaryProgress.UpdateProgress(10);
                            except
                              on E:Exception do
                              begin
                                LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could export the Chart of Accounts - ' + E.Message);

                                ExportClient := False;
                              end;
                            end;
                          end;

                          DeletedTransactions := XMLDocument.CreateElement('BKDeletedTransactions', ''); 

                          if AddDeletedTransactionsToXML(DeletedTransactions, Client) > 0 then
                          begin
                            ClientNode.ChildNodes.Add(DeletedTransactions); 
                          end;

                          if ExportClient then
                          begin
                            XMLDocument.ChildNodes.Add(RootNode);

                            with TTransactionExporter.Create do
                            begin
                              try
                                if DebugMe then
                                begin
                                  XMLDocument.SaveToFile(Globals.DataDir + 'Tagging_ExportTaggedAccounts' + '_' +  FormatDateTime('yyyy-mm-dd hh-mm-ss zzz', Now) + '.xml');
                                end;

                                ServiceResponse := SendTransactionData(XMLDocument.XML.Text, 20, ProgressForm.SecondaryProgress, AuthenticationError);
                              finally
                                Free;
                              end;
                            end;

                            if not AuthenticationError then
                            begin
                              if TBloUploadResultCode(ServiceResponse.Result) = Success then
                              begin
                                for IIndex := 0 to TransactionsExported.Count - 1 do
                                begin
                                  pTransaction_Rec(TransactionsExported[IIndex]).txTransfered_To_Online := True;
                                  pTransaction_Rec(TransactionsExported[IIndex]).txIsOnline_Transaction := True;
                                end;

                                ClearDeletedTransactions(Client);
                                
                                Client.clFields.clFile_Save_Required := True;

                                DoClientSave(False, Client, True);
                                
                                Statistics.TransactionsExported := Statistics.TransactionsExported + TransactionsExported.Count;
                                Statistics.AccountsExported := Statistics.AccountsExported + AccountsExported;
                                Statistics.ClientFilesProcessed := Statistics.ClientFilesProcessed + 1;

                                LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', Format('Client File %s successfully exported to BankLink Online - %s transactions, %s accounts.', [AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Name, IntToStr(AccountsExported), IntToStr(TransactionsExported.Count)]));
                              end
                              else
                              begin
                                if Length(ServiceResponse.Messages) > 0  then
                                begin
                                  for IIndex := 0 to Length(ServiceResponse.Messages) - 1 do
                                  begin
                                    ServiceErrors := ServiceErrors + ServiceResponse.Messages[IIndex] + #10#13;
                                  end;
                                end
                                else
                                begin
                                  case TBloUploadResultCode(ServiceResponse.Result)  of
                                    NoFileReceived: ServiceErrors := 'The service call to BankLink Online did not include any transactions.';
                                    InvalidCredentials: ServiceErrors := 'BankLink Online did not recognise the practice credentials.';
                                    InternalError: ServiceErrors := 'BankLink Online encountered an unknown internal error.';
                                    FileFormatError: ServiceErrors := 'BankLink Online did not recognise the transaction data format.';
                                  end; 
                                end;

                                raise Exception.Create(ServiceErrors);
                              end;
                            end
                            else
                            begin
                              HelpfulErrorMsg('Data export cannot continue because you are not authenticated with BankLink Online.', 0);
                              
                              LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'Data export could export all transactions because the user is not authenticated with Banklink Online.');

                              FatalError := True;

                              Exit;
                            end;
                          end;
                        end;
                      finally
                        XMLDocument.Active := False;
                      end;
                    finally
                      TransactionsExported.Free;
                    end;
                  end;
                end
                else
                begin
                  LogUtil.LogMsg(lmError, 'BankLinkOnlineTaggingService', 'Client File ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code + ' could not be exported - The client file is read-only.');
                end;
              finally
                CloseAClient(Client);
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
                                                                          
          ProgressForm.SecondaryProgress.CompleteProgress;
          
          ProgressForm.PrimaryProgress.UpdateProgress(ClientProgressSize);
        end;
      end;

      ProgressForm.PrimaryProgress.CompleteProgress;
      ProgressForm.SecondaryProgress.CompleteProgress;

      Application.ProcessMessages;

      if Statistics.TransactionsExported > 0 then
      begin
        LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice successfully exported data to BankLink Online up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ': ' + IntToStr(Statistics.TransactionsExported) + ' Transaction(s) exported, ' + IntToStr(Statistics.AccountsExported) + ' Account(s) exported ' + IntToStr(Statistics.ClientFilesProcessed) + ' Client file(s) processed.');
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'BankLink Practice could not find any data up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ' to export to BankLink Online.');
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('ExportTaggedAccounts', 'BanklinkOnlineTaggingServices', E);

      LogUtil.LogMsg(lmInfo, 'BankLinkOnlineTaggingService', 'The following transactions up to ' + StDateToDateString(BKDATEFORMAT, ExportOptions.MaxTransactionDate, False) + ' were exported to BankLink Online: ' + IntToStr(Statistics.TransactionsExported) + ' Transaction(s) exported, ' + IntToStr(Statistics.AccountsExported) + ' Account(s) exported ' + IntToStr(Statistics.ClientFilesProcessed) + ' Client file(s) processed.');

      FatalError := True;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.IsBankAccountTagged(BankAccount: TBank_Account; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount): Boolean;
var
  Index: Integer;
begin
  for Index := 0 to Length(ClientBankAccountVendors) - 1 do
  begin
    if BankAccount.baFields.baCore_Account_ID = ClientBankAccountVendors[Index].AccountId then
    begin
      Result := Length(ClientBankAccountVendors[Index].Subscribers) > 0;

      Break;
    end;
  end;
end;

class function TBanklinkOnlineTaggingServices.IsExportableBankAccount(BankAccount: TBank_Account; ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount): Boolean;
begin
  Result := not (BankAccount.IsManual or BankAccount.IsAJournalAccount) and (BankAccount.baFields.baCore_Account_ID > 0) and IsBankAccountTagged(BankAccount, ClientBankAccountVendors);

  result := true;
end;

class function TBanklinkOnlineTaggingServices.IsExportableTransaction(Transaction: pTransaction_Rec; MaxTransactionDate: TStDate = -1): Boolean;
begin
  if MaxTransactionDate > -1 then
  begin
    Result := ((Transaction.txCore_Transaction_ID <> 0) or (Transaction.txUPI_State in[upUPC, upUPD, upUPW])) and (not Transaction.txTransfered_To_Online) and (Transaction.txDate_Effective <= MaxTransactionDate);
  end
  else
  begin
    Result := ((Transaction.txCore_Transaction_ID <> 0) or (Transaction.txUPI_State in[upUPC, upUPD, upUPW])) and (not Transaction.txTransfered_To_Online);
  end;

  result := true;
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
                                                           BankAccount.baFields.baCore_Account_ID,
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
                                                BankAccount.baFields.baBank_Account_Name,
                                                BankAccount.baFields.baBank_Account_Number,
                                                AccountVendorsModified,
                                                False,
                                                False);
end;

class procedure TBanklinkOnlineTaggingServices.GetAccountVendors(BankAccount: TBank_Account; out TaggedAccount: TTaggedAccount);
begin

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
  ClientBankAccountVendors: TBloArrayOfDataPlatformBankAccount;
  ClientGuid: TBloGuid;
  DeletedTransaction: pDeleted_Transaction_Rec;
begin
  Result := -1;

  try
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
                ClientGuid := ProductConfigService.Clients.GetClientGuid(Client.clFields.clCode);
              
                if ClientGuid <> '' then
                begin
                  if not (ProductConfigService.GetClientBankAccounts(ClientGuid, ClientBankAccountVendors, False, False) in [bloSuccess, bloFailedNonFatal]) then
                  begin
                    Result := -2;

                    Exit;
                  end;

                  if Length(ClientBankAccountVendors) > 0 then
                  begin
                    for AccountIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
                    begin
                      BankAccount := Client.clBank_Account_List[AccountIndex];

                      if IsExportableBankAccount(BankAccount, ClientBankAccountVendors) then
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

                      for TransactionIndex := 0 to BankAccount.baDeleted_Transaction_List.ItemCount -1 do
                      begin
                        DeletedTransaction := BankAccount.baDeleted_Transaction_List.Transaction_At(TransactionIndex);

                        if DeletedTransaction.dxDate_Effective > Result then
                        begin
                          Result := DeletedTransaction.dxDate_Effective;
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
  except
    on E:Exception do
    begin
      HandleException('GetMaxExportableTransactionDate', 'BanklinkOnlineTaggingServices', E);

      Result := -2;
    end;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.GetTaggedAccounts(Practice: TBloPracticeRead; out TaggedAccounts: array of TTaggedAccount);
begin

end;

class procedure TBanklinkOnlineTaggingServices.GetTaggedAccounts(ClientReadDetail: TBloClientReadDetail; out TaggedAccounts: array of TTaggedAccount);
begin

end;

class function TBanklinkOnlineTaggingServices.HasDeletedTransactions(Client: TClientObj): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to Client.clBank_Account_List.ItemCount - 1 do
  begin
    if Client.clBank_Account_List.Bank_Account_At(Index).baDeleted_Transaction_List.ItemCount > 0 then
    begin
      Result := True;
      
      Break;
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

{ TBanklinkOnlineTaggingServices.TExportedClient }

constructor TBanklinkOnlineTaggingServices.TExportedClient.Create(const ClientCode: String; ExportedAccounts, ExportedTransactions: Integer);
begin
  FClientCode := ClientCode;
  FAccountsExported := ExportedAccounts;
  FTransactionsExported := ExportedTransactions;
end;

{ TBanklinkOnlineTaggingServices.TTransactionExporter }

procedure TBanklinkOnlineTaggingServices.TTransactionExporter.OnSendTransactions(Sent, Total: Integer);
var
  StepSize: Double;
begin
  if (Total > 0) and (Sent > 0) then
  begin
    StepSize := FProgressWeight / (Total / Sent);
  end
  else
  begin
    StepSize := 0;
  end;
  
  FProgressControl.UpdateProgress(StepSize - FLastStepSize);

  FLastStepSize := StepSize;
end;

function TBanklinkOnlineTaggingServices.TTransactionExporter.SendTransactionData(TransactionData: String; ProgressWeight: Double; ProgressControl: IProgressControl; out AuthenticationError: Boolean): TBloUploadResult;
begin
  FProgressWeight := ProgressWeight;
  FProgressControl := ProgressControl;
  FLastStepSize := 0;

  Result := ProductConfigService.ProcessData(TransactionData, AuthenticationError, OnSendTransactions);
end;

initialization
  DebugMe := DebugUnit('BanklinkOnlineTaggingServices');
  
end.
