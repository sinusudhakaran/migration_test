unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, BK_XMLHelper, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, ModalProgressFrm;

type
  TBanklinkOnlineTaggingServices = class
  private
    class function BankAccountToXML(ParentNode: IXMLNode; BankAccount: TBank_Account): Integer; static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;
  public
    class procedure UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String); static;

    class procedure ExportTaggedAccounts(ProgressFrm: TfrmModalProgress); static;
  end;

implementation

uses
  Files, Globals;

{ TBanklinkOnlineServices }

class function TBanklinkOnlineTaggingServices.BankAccountToXML(ParentNode: IXMLNode; BankAccount: TBank_Account): Integer;
var
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
  BankAccountNode: IXMLNode;
begin
  Result := 0;

  BankAccountNode := BankAccount.baFields.WriteRecToNode(ParentNode);
   
  for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
  begin
    Transaction := BankAccount.baTransaction_List[TransactionIndex];

    if (Transaction.txCore_Transaction_ID <> 0) and not Transaction.txTransfered_To_Online then
    begin
      Transaction.WriteRecToNode(BankAccountNode);

      Transaction.txTransfered_To_Online := True;

      Inc(Result);
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

class procedure TBanklinkOnlineTaggingServices.ExportTaggedAccounts(ProgressFrm: TfrmModalProgress);
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  CompressedXml: String;
  Client: TClientObj;
  ClientList: TObjectList;
  ClientProgressSize: Double;
begin
  XMLDocument := XMLDoc.NewXMLDocument;

  XMLDocument.Active := True;

  XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
  XMLDocument.Version:= '1.0';
  XMLDocument.Encoding:= 'UTF-8';

  RootNode := XMLDocument.AddChild('BKTaggedAccounts');

  ClientList := TObjectList.Create(True);

  try
    ClientProgressSize := 60 / AdminSystem.fdSystem_Client_File_List.ItemCount;

    ProgressFrm.Initialize('Exporting Client Transactions'); 
    
    for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
    begin
      Client := nil;

      if not ProgressFrm.Cancelled then
      begin
        ProgressFrm.UpdateProgress('Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, ClientProgressSize);

        try
          OpenAClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, Client, True);

          if Assigned(Client) then
          begin
            if not Client.clFields.clFile_Read_Only then
            begin
              ClientList.Add(Client);

              for IIndex := 0 to Client.clBank_Account_List.ItemCount - 1 do
              begin
                BankAccount := Client.clBank_Account_List[IIndex];

                //Only delivered accounts can be sent
                if not (BankAccount.IsManual or BankAccount.IsAJournalAccount) then
                begin
                  //if bank account tagged then
                  begin
                    BankAccountToXML(RootNode, BankAccount);
                  end;
                end;
              end;
            end;
          end;
        except
          on E:Exception do
          begin

          end;
        end;
      end;
    end;

    if not ProgressFrm.Cancelled then
    begin
      ProgressFrm.UpdateProgress('Exporting chart of accounts', 10);

      //Add chart of accounts to xml packet
      ChartToXML(RootNode, Client.clChart);

      ProgressFrm.ToggleCancelEnabled(False);

      ProgressFrm.UpdateProgress('Sending transactions to Banklink Online', 10);

      //Zip the xml to reduce the size of the packet sent
      CompressedXml := ZipUtils.CompressString(XMLDocument.XML.Text);

      //Send xml to Banklink online.
      XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions.xml');

      ProgressFrm.UpdateProgress('Saving changes to transactions', 10);

      for Index := 0 to ClientList.Count -1 do
      begin
        Client := TClientObj(ClientList[Index]);

        DoClientSave(True, Client, True);
      end;

      ProgressFrm.UpdateProgress(10);
    end;
  finally
    ClientList.Free;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String);
begin
  
end;

end.
