unit BanklinkOnlineTaggingServices;

interface

uses
  Classes, Forms, Contnrs, Controls, SysUtils, baObj32, BKDEFS, BK_XMLHelper, clObj32, SysObj32, chList32, XMLDoc, XMLIntf, BanklinkOnlineServices, ZipUtils, Progress;

type
  TBanklinkOnlineTaggingServices = class
  private
    class function BankAccountToXML(ParentNode: IXMLNode; BankAccount: TBank_Account): Integer; static;
    class procedure ChartToXML(ParentNode: IXMLNode; ChartOfAccounts: TChart); static;
  public
    class procedure UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String); static;
    class function ExportTaggedAccounts: Integer; static;
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

class function TBanklinkOnlineTaggingServices.ExportTaggedAccounts: Integer;
var
  XMLDocument: IXMLDocument;
  RootNode: IXMLNode;
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  CompressedXml: String;
  Client: TClientObj;
  ClientList: TObjectList;
  ShowProgress: Boolean;
  ClientProgressValue: Double;
  TotalProgress: Double;
begin
  Result := 0;

  XMLDocument := XMLDoc.NewXMLDocument;

  XMLDocument.Active := True;

  XMLDocument.Options := [doNodeAutoIndent,doAttrNull,doNamespaceDecl];
  XMLDocument.Version:= '1.0';
  XMLDocument.Encoding:= 'UTF-8';

  RootNode := XMLDocument.AddChild('BKTaggedAccounts');

  ClientList := TObjectList.Create(True);

  try
    ShowProgress := Progress.StatusSilent;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.AllowClearStatus := False;   
    end;
    
    try
      ClientProgressValue := 70 / AdminSystem.fdSystem_Client_File_List.ItemCount;

      TotalProgress := 0;
      
      for Index := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount -1 do
      begin
        Client := nil;

        if not Progress.Cancelled then
        begin
          if ShowProgress then
          begin
            Progress.UpdateAppStatus('Exporting Client Transactions', 'Exporting transactions for ' + AdminSystem.fdSystem_Client_File_List.Client_File_At(Index).cfFile_Code, TotalProgress, True);
          end;

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

                  //if bank account tagged then
                  begin
                    Result := Result + BankAccountToXML(RootNode, BankAccount);
                  end;
                end;
              end;
            end;
          except
            on E:Exception do
            begin

            end;
          end;
        
          TotalProgress := TotalProgress + ClientProgressValue;
        end;
      end;

      if ShowProgress then
      begin
        Progress.UpdateAppStatus('Exporting Client Transactions', 'Exporting chart of accounts', 70, True);
      end;

      //Add chart of accounts to xml packet
      ChartToXML(RootNode, Client.clChart);

      Progress.ToggleCancelEnabled(False);

      if not Progress.Cancelled then
      begin
        if ShowProgress then
        begin
          Progress.UpdateAppStatus('Exporting Client Transactions', 'Sending transactions to Banklink Online', 80, True);
        end;

        //Zip the xml to reduce the size of the packet sent
        CompressedXml := ZipUtils.CompressString(XMLDocument.XML.Text);

        //Send xml to Banklink online.
        XMLDocument.SaveToFile('C:\Users\kerry.convery\Desktop\ClientAccountTransactions.xml');

        if ShowProgress then
        begin
          Progress.UpdateAppStatus('Exporting Client Transactions', 'Saving changes to transactions', 90, True);
        end;
      
        for Index := 0 to ClientList.Count -1 do
        begin
          Client := TClientObj(ClientList[Index]);

          DoClientSave(True, Client, True);
        end;

        if ShowProgress then
        begin
          Progress.UpdateAppStatus('Exporting Client Transactions', 'Saving changes to transactions', 100, True);

          Progress.ToggleCancelEnabled(True);
        end;
      end;
    finally
      if ShowProgress then
      begin
        Progress.StatusSilent := True;   
        Progress.AllowClearStatus := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    ClientList.Free;
  end;
end;

class procedure TBanklinkOnlineTaggingServices.UpdateAccountVendors(ClientCode: String; BankAccount: TBank_Account; Vendors: array of String);
begin
  
end;

end.
