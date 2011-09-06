unit WebCiCoClient;
//------------------------------------------------------------------------------
{
   Title: WebCiCoClient

   Description:

        Web Check-in Check-out Class, this handles the client Http calls

   Author: Ralph Austen

   Remarks:
}
//------------------------------------------------------------------------------
interface

uses
  StDate,
  IpsSoaps,
  Classes,
  SysUtils,
  WebClient,
  XMLDoc,
  XMLIntf,
  EncdDecd;

{$M+}
type
  TDirectionIndicator = (dirFromClient, dirFromServer);
  TTransferStatus = (trsStartTrans, trsTransInProgress, trsEndTrans);

  TClientStatusItem = class
  private
    fClientCode : string;
    fStatusCode : string;
    fStatusDesc : string;
    fFileGuid   : string;
  public
    property ClientCode : String read fClientCode write fClientCode;
    property StatusCode : string read fStatusCode write fStatusCode;
    property StatusDesc : string read fStatusDesc write fStatusDesc;
    property FileGuid   : string read fFileGuid   write fFileGuid;
  end;

  //------------------------------------------------------------------------------
  TClientStatusList = class(TList)
  protected
    function Get(Index: Integer): TClientStatusItem;
    procedure Put(Index: Integer; Item: TClientStatusItem);
  public
    destructor Destroy; override;

    function GetStatusFromCode(ClientCode : string) : TClientStatusItem;

    property Items[Index: Integer]: TClientStatusItem read Get write Put; default;
  end;

  //----------------------------------------------------------------------------
  EWebSoapCiCoClientError = class(EWebSoapClientError)
  end;

  EWebHttpCiCoClientError = class(EWebSoapClientError)
  end;

  TTransferFileEvent = procedure (Direction: TDirectionIndicator;
                                  TransferStatus : TTransferStatus;
                                  BytesTransferred: LongInt;
                                  TotalBytes: LongInt;
                                  ContentType: String) of object;

  TStatusEvent = procedure (StatusMessage : string) of object;

  TXMLReplyEvent = procedure (Status : String;
                              Description : String;
                              DetailedDesc : String;
                              ClientStatusList : TClientStatusList) of object;

  //----------------------------------------------------------------------------
  TWebCiCoClient = class(TWebClient)
  private
    fStatusEvent       : TStatusEvent;
    fTransferFileEvent : TTransferFileEvent;
    fXMLReplyEvent     : TXMLReplyEvent;

    fTotalBytes       : LongInt;
    fClientPassword   : string;
    fIsBooks          : Boolean;
    fServerReply      : string;
    fFirstSeverBlock  : Boolean;
    fIsServerResponce : Boolean;
    fContentType      : string;

  protected
    procedure RaiseHttpError(ErrMessage : String; ErrCode : integer); override;

    // Http Used Events
    procedure DoHttpConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Override;
    procedure DoHttpSSLServerAuthentication(Sender: TObject;
                                            CertEncoded: String;
                                            const CertSubject: String;
                                            const CertIssuer: String;
                                            const Status: String;
                                            var  Accept: Boolean); Override;
    procedure DoHttpStartTransfer(Sender: TObject;
                                  Direction: Integer); Override;
    procedure DoHttpTransfer(Sender: TObject;
                             Direction: Integer;
                             BytesTransferred: LongInt;
                             Text: String); Override;
    procedure DoHttpEndTransfer(Sender: TObject;
                                Direction: Integer); Override;

    procedure DoHttpHeader(Sender: TObject;
                           const Field: String;
                           const Value: String); Override;

    procedure FileInfo(Filename     : String;
                       var FileCRC  : String;
                       var FileSize : Integer);

    Function CreateAndSaveGuid(ClientCode : String) : TGuid;
    function GetClientGuid(ClientCode : String) : TGuid;

    function TrimedGuid(Guid : TGuid) : String;

    procedure UploadFile(HttpAddress : string;
                         FileName : string);

    procedure GetPracticeDetailsToSend(ClientCode       : string;
                                       var FileName     : String;
                                       var ClientEmail  : String;
                                       var ClientName   : String;
                                       var PracCode     : String;
                                       var CountryCode  : String;
                                       var PracPass     : String);

    procedure GetBooksDetailsToSend(ClientCode      : string;
                                    var FileName    : string;
                                    var ClientEmail : string;
                                    var ClientName  : string;
                                    var PracCode    : String;
                                    var CountryCode : String);

    function GetValueFromNode(ParentNode : IXMLNode; NodeName : String) : String;

    procedure GetDetailsFromXML(Reply : String;
                                var Status : String;
                                var Description : String;
                                var DetailedDesc : String;
                                var ClientStatusList : TClientStatusList);

    function BuildStatusListFromXml(const CurrentNode : IXMLNode) : TClientStatusList;
  public
    constructor Create; Override;

    procedure SetBooksUserPassword(ClientCode  : string;
                                   OldPassword : string;
                                   NewPassword : string);

    procedure GetClientFileStatus(ClientCode : string = '');

    procedure UploadFileFromPractice(ClientCode : string; var Email: string);
    procedure DownloadFileToPractice(ClientCode : string);

    procedure UploadFileFromBooks(ClientCode : string);
    procedure DownloadFileToBooks(ClientCode : string);

    property OnStatusEvent : TStatusEvent read fStatusEvent write fStatusEvent;
    property OnTransferFileEvent : TTransferFileEvent read fTransferFileEvent write fTransferFileEvent;
    property OnXMLReplyEvent : TXMLReplyEvent read fXMLReplyEvent write fXMLReplyEvent;
  published

  end;

  //----------------------------------------------------------------------------
  Function CiCoClient : TWebCiCoClient;

//------------------------------------------------------------------------------
implementation

uses
  Progress,
  IdHashSHA1,
  IdHash,
  Base64,
  Globals,
  SyDefs,
  ClObj32,
  WebUtils,
  StrUtils;

const
  XML_STATUS_HEADNAME             = 'Result';
  XML_STATUS_CODE                 = 'Code';
  XML_STATUS_DESC                 = 'Description';
  XML_STATUS_DETAIL_DESC          = 'DetailedDescription';
  XML_STATUS_CLIENT               = 'Client';
  XML_STATUS_CLIENT_CODE          = 'ClientCode';
  XML_STATUS_FILE                 = 'File';
  XML_STATUS_FILE_ATTR_GUID       = 'GUID';
  XML_STATUS_FILE_ATTR_STATUSCODE = 'StatusCode';
  XML_STATUS_FILE_ATTR_STATUSDESC = 'StatusCodeDescription';

  SERVER_CONTENT_TYPE_XML = '.xml; charset=utf-8';

var
  fWebCiCoClient : TWebCiCoClient;

//------------------------------------------------------------------------------
function CiCoClient : TWebCiCoClient;
begin
  if not Assigned( fWebCiCoClient) then
    fWebCiCoClient := TWebCiCoClient.Create;

  result := fWebCiCoClient;
end;

{ TClientStatusList }
//------------------------------------------------------------------------------
function TClientStatusList.Get(Index: Integer): TClientStatusItem;
begin
  Result := inherited Get(Index);
end;

//------------------------------------------------------------------------------
procedure TClientStatusList.Put(Index: Integer; Item: TClientStatusItem);
begin
  inherited Put(Index, Item);
end;

//------------------------------------------------------------------------------
destructor TClientStatusList.Destroy;
var
  ItemIndex : integer;
begin
  for ItemIndex := Count - 1 downto 0 do
  begin
    Items[ItemIndex].Free;
    Self.Remove(Items[ItemIndex]);
  end;

  inherited;
end;

//------------------------------------------------------------------------------
function TClientStatusList.GetStatusFromCode(ClientCode : string) : TClientStatusItem;
var
  ClientIndex : integer;
begin
  Result := nil;
  for ClientIndex := 0 to Count-1 do
  begin
    if Self.Items[ClientIndex].ClientCode = ClientCode then
    begin
      Result := Self.Items[ClientIndex];
      Exit;
    end;
  end;
end;

{ TWebCiCoClient }
//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseHttpError(ErrMessage : String; ErrCode : integer);
begin
  raise EWebHttpCiCoClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpConnectionStatus(Sender: TObject;
                                                const ConnectionEvent: String;
                                                StatusCode: Integer;
                                                const Description: String);
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent('ConnectionEvent : ' + ConnectionEvent + ', ' +
                 'Status Code : ' + InttoStr(StatusCode) + ', ' +
                 'Description : ' + Description);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpSSLServerAuthentication(Sender: TObject;
                                                       CertEncoded: String;
                                                       const CertSubject: String;
                                                       const CertIssuer: String;
                                                       const Status: String;
                                                       var  Accept: Boolean);
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent('Cert Encoded : ' + CertEncoded + ', ' +
                 'Cert Subject : ' + CertSubject + ', ' +
                 'Cert Issuer : ' + CertIssuer + ', ' +
                 'Status : ' + Status);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpStartTransfer(Sender: TObject;
                                             Direction: Integer);
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('Start Transfer : from Client')
    else
      fStatusEvent('Start Transfer : from Server');
  end;

  // Transfer File Event
  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsStartTrans, 0, fTotalBytes, fContentType);

  // Clears Server Reply
  if TDirectionIndicator(Direction) = dirFromServer then
  begin
    fServerReply := '';
    fIsServerResponce := (fContentType = SERVER_CONTENT_TYPE_XML);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpTransfer(Sender: TObject;
                                        Direction: Integer;
                                        BytesTransferred: LongInt;
                                        Text: String);
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('Transfer : from Client, ' +
                   'Bytes Transferred : ' + InttoStr(BytesTransferred))
    else
      fStatusEvent('Transfer : from Server, ' +
                   'Bytes Transferred : ' + InttoStr(BytesTransferred));
  end;

  // Transfer File Event
  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsTransInProgress, BytesTransferred, fTotalBytes, fContentType);

  // Attempts to retrieve Server Message
  if (TDirectionIndicator(Direction) = dirFromServer) and
     (fIsServerResponce) then
    fServerReply := fServerReply + Text;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpEndTransfer(Sender: TObject;
                                           Direction: Integer);
var
  Status : String;
  Description : String;
  DetailedDesc : String;
  ClientStatusList : TClientStatusList;
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('End Transfer : from Client')
    else
      fStatusEvent('End Transfer : from Server');
  end;

  // Transfer File Event
  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsEndTrans, fTotalBytes, fTotalBytes, fContentType);

  // Server Reply Event
  if (TDirectionIndicator(Direction) = dirFromServer) and
     (fIsServerResponce) then
  begin
    try
      GetDetailsFromXML(fServerReply, Status, Description, DetailedDesc, ClientStatusList);

      if (Status <> '') and
         (Assigned(fXMLReplyEvent)) then
        fXMLReplyEvent(Status, Description, DetailedDesc, ClientStatusList);
    finally
      FreeAndNil(ClientStatusList);
    end;

    fIsServerResponce := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpHeader(Sender: TObject;
                                      const Field: String;
                                      const Value: String);
begin
  Inherited;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent('Header Field : ' + Field + ', ' +
                 'Header Value : ' + Value);

  // works out content length and type
  if Field = 'Content-Length' then
    trystrtoint(Value, fTotalBytes)
  else if Field = 'Content-Type' then
    fContentType := Value;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.FileInfo(Filename     : String;
                                  var FileCRC  : String;
                                  var FileSize : Integer);
var
  CrcHash    : T5x4LongWordRecord;
  IdHashSHA1 : TIdHashSHA1;
  FileStream : TFileStream;
  Sha1String : String[20];
  Index : integer;
  Value : Byte;
begin
  // Opening the File to Work out the SHA1 hash which is then
  // Base 64 encoded and sent as a CRC header
  FileStream := TFileStream.Create(Filename, fmOpenRead);
  Try
    FileSize := FileStream.Size;

    IdHashSHA1 := TIdHashSHA1.Create;
    Try
      FileStream.Position := 0;
      CrcHash := IdHashSHA1.HashValue(FileStream);

      Sha1String := '';
      for Index := 0 to 19 do
      begin
        Value := TByteArr20(CrcHash)[Index];
        Sha1String := Sha1String + chr(Value);
      end;

      FileCRC := EncodeString(Sha1String);
    Finally
      FreeAndNil(IdHashSHA1);
    End;
  Finally
    FreeAndNil(FileStream);
  End;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.CreateAndSaveGuid(ClientCode : String): TGuid;
var
  ClientFileRec : pClient_File_Rec;
  fClientObj    : TClientObj;
  FileName      : String;
begin
  ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if Assigned(ClientFileRec) then
  begin
    CreateGUID(Result);
    ClientFileRec.cfClient_File_GUID := GuidToString(Result);

    FileName   := ClientFileRec^.cfFile_Code;

    fClientObj := TClientObj.Create;
    Try
      fClientObj.Open(FileName, FILEEXTN);

      fClientObj.clExtra.ceClient_File_GUID := GuidToString(Result);
      fClientObj.Save;
    Finally
      FreeAndNil(fClientObj);
    End;

    AdminSystem.Save;
  end;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.GetClientGuid(ClientCode : String) : TGuid;
begin
  if Assigned(MyClient) then
    Result := StringToGuid(MyClient.clExtra.ceClient_File_GUID);
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.TrimedGuid(Guid: TGuid): String;
begin
  Result := midstr(GuidToString(Guid),2,length(GuidToString(Guid))-2);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFile(HttpAddress : string;
                                    FileName : string);
var
  FileCRC      : String;
  FileLength   : Integer;
begin
  if not FileExists(Filename) then
    Exit;

  FileInfo(Filename, FileCRC, FileLength);

  // Adding Crc to Header Section
  AddHttpHeaderInfo('FileCRC',    FileCRC);
  AddHttpHeaderInfo('FileLength', inttostr(FileLength));
  HttpRequester.ContentType := 'bk5/xml';
  fContentType := HttpRequester.ContentType;
  AppendHttpHeaderInfo;

  HttpPostFile(HttpAddress, Filename);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetPracticeDetailsToSend(ClientCode       : string;
                                                  var FileName     : String;
                                                  var ClientEmail  : String;
                                                  var ClientName   : String;
                                                  var PracCode     : String;
                                                  var CountryCode  : String;
                                                  var PracPass     : String);
var
  ClientFileRec : pClient_File_Rec;
  fClientObj    : TClientObj;
begin
  ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if Assigned(ClientFileRec) then
  begin
    GetBooksDetailsToSend(ClientCode, FileName, ClientEmail, ClientName, PracCode, CountryCode);

    PracCode    := AdminSystem.fdFields.fdBankLink_Code;
    PracPass    := AdminSystem.fdFields.fdBankLink_Connect_Password;
    CountryCode := CountryText(AdminSystem.fdFields.fdCountry);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetBooksDetailsToSend(ClientCode      : string;
                                               var FileName    : string;
                                               var ClientEmail : string;
                                               var ClientName  : string;
                                               var PracCode    : String;
                                               var CountryCode : String);
var
  fClientObj    : TClientObj;
begin
  fClientObj := TClientObj.Create;
  Try
    fClientObj.Open(ClientCode, FILEEXTN);
    FileName    := DataDir + ClientCode + FILEEXTN;
    ClientEmail := fClientObj.clFields.clClient_EMail_Address;
    ClientName  := fClientObj.clFields.clName;
    PracCode    := fClientObj.clFields.clPractice_Code;
    CountryCode := CountryText(fClientObj.clFields.clCountry);
  Finally
    FreeAndNil(fClientObj);
  End;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.GetValueFromNode(ParentNode : IXMLNode; NodeName : String) : String;
var
  CurrentNode : IXMLNode;
begin
  Result := '';

  CurrentNode := ParentNode.ChildNodes.FindNode(NodeName);
  if Assigned(CurrentNode) then
    Result := CurrentNode.NodeValue;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetDetailsFromXML(Reply : String;
                                           var Status : String;
                                           var Description : String;
                                           var DetailedDesc : String;
                                           var ClientStatusList : TClientStatusList);
var
  XMLDoc : IXMLDocument;
  CurrentNode : IXMLNode;
begin
  Status       := '';
  Description  := '';
  DetailedDesc := '';

  if pos('<' + XML_STATUS_HEADNAME + '>', Reply) = 0 then
    Exit;

  XMLDoc := MakeXMLDoc(Reply);
  try
    CurrentNode := XMLDoc.DocumentElement;
    if CurrentNode.NodeName <> XML_STATUS_HEADNAME then
      Exit;

    if XMLDoc.DocumentElement.ChildNodes.Count = 0 then
      Exit;

    Status       := GetValueFromNode(CurrentNode, XML_STATUS_CODE);
    Description  := GetValueFromNode(CurrentNode, XML_STATUS_DESC);
    DetailedDesc := GetValueFromNode(CurrentNode, XML_STATUS_DETAIL_DESC);

    ClientStatusList := BuildStatusListFromXml(CurrentNode);
  finally
    CurrentNode := Nil;
    XMLDoc := Nil;
  end;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.BuildStatusListFromXml(const CurrentNode : IXMLNode): TClientStatusList;
var
  FileNode    : IXMLNode;
  ClientIndex : integer;
  NewClientStatusItem : TClientStatusItem;
  LocalNode : IXMLNode;
begin
  Result := TClientStatusList.Create;

  LocalNode := CurrentNode.ChildNodes.FindNode(XML_STATUS_CLIENT);

  while Assigned(LocalNode) do
  begin
    FileNode := LocalNode.ChildNodes.FindNode(XML_STATUS_FILE);

    NewClientStatusItem := TClientStatusItem.Create;
    NewClientStatusItem.ClientCode := LocalNode.Attributes[XML_STATUS_CLIENT_CODE];;
    NewClientStatusItem.FileGuid   := FileNode.Attributes[XML_STATUS_FILE_ATTR_GUID];
    NewClientStatusItem.StatusCode := FileNode.Attributes[XML_STATUS_FILE_ATTR_STATUSCODE];
    NewClientStatusItem.StatusDesc := FileNode.Attributes[XML_STATUS_FILE_ATTR_STATUSDESC];
    Result.Add(NewClientStatusItem);

    LocalNode := CurrentNode.ChildNodes.FindSibling(LocalNode, 1);
  end;
end;

//------------------------------------------------------------------------------
constructor TWebCiCoClient.Create;
begin
  inherited;
  fTotalBytes := 0;
  fIsBooks := not Assigned(Globals.AdminSystem);

  if fIsBooks then
    fClientPassword := Globals.INI_BankLink_Online_Password
  else
    fClientPassword := '';

  fServerReply := '';
  fContentType := '';
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.SetBooksUserPassword(ClientCode  : string;
                                              OldPassword : string;
                                              NewPassword : string);
var
  HttpAddress : String;
begin
  HttpAddress := 'http://posttestserver.com/post.php';

  AddHttpHeaderInfo('ClientCode', ClientCode);
  AddHttpHeaderInfo('OldPassword', OldPassword);
  AddHttpHeaderInfo('NewPassword', NewPassword);
  AppendHttpHeaderInfo;

  HttpPostFile(HttpAddress, '');
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientFileStatus(ClientCode : string = '');
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  Guid         : TGuid;
  ClientEmail  : String;
  ClientName   : String;
  PracCode     : String;
  CountryCode  : String;
  PracPass     : String;
begin
  ClearHttpHeader;

  HttpAddress := 'http://development.banklinkonline.com/cico.status';

  AddHttpHeaderInfo('CountryCode',      'NZ');
  AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
  AddHttpHeaderInfo('PracticePassword', '123');
  //AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
  AddHttpHeaderInfo('ClientCode',       '');
  AddHttpHeaderInfo('ClientName',       '');
  AddHttpHeaderInfo('ClientEmail',      '');
  AddHttpHeaderInfo('ClientPassword',   '');

  AppendHttpHeaderInfo;

  HttpSendRequest(HttpAddress);

  {HttpAddress := 'http://development.banklinkonline.com/cico.status';

  PracPass := '';
  if fIsBooks then
    GetBooksDetailsToSend(ClientCode, FileName, ClientEmail, ClientName,
                          CountryCode, PracCode)
  else
    GetPracticeDetailsToSend(ClientCode, FileName, ClientEmail, ClientName,
                             PracCode, CountryCode, PracPass);

  ClearHttpHeader;

  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticeCode',     PracCode);
  AddHttpHeaderInfo('PracticePassword', PracPass);
  AddHttpHeaderInfo('ClientCode',       ClientCode);
  AddHttpHeaderInfo('ClientName',       ClientName);
  AddHttpHeaderInfo('ClientEmail',      ClientEmail);
  AddHttpHeaderInfo('ClientPassword',   fClientPassword);

  AppendHttpHeaderInfo;

  HttpSendRequest(HttpAddress);}
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromPractice(ClientCode : string; var Email: string);
var
  HttpAddress : String;
  FileName    : String;
  Guid        : TGuid;
  PracCode    : String;
  CountryCode : String;
  PracPass    : String;
  ClientName  : String;
  StrGuid     : String;
begin
  ClearHttpHeader;

  HttpAddress := 'http://development.banklinkonline.com/cico.upload';

  CreateGuid(Guid);
  StrGuid := TrimedGuid(Guid);

  AddHttpHeaderInfo('CountryCode',      'NZ');
  AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
  AddHttpHeaderInfo('PracticePassword', '123');
  AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
  AddHttpHeaderInfo('ClientName',       'NZ Test client');
  AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
  AddHttpHeaderInfo('ClientPassword',   '');
  AddHttpHeaderInfo('FileGuid',         StrGuid);

  UploadFile(HttpAddress, 'c:\temp\UploadPrac.bk5');

  {if not FileExists(FileName) then
    Exit;

  HttpAddress := 'http://development.banklinkonline.com/cico.upload';

  GetPracticeDetailsToSend(ClientCode, FileName, Email, ClientName,
                           PracCode, CountryCode, PracPass);

  Guid := CreateAndSaveGuid(ClientCode);

  ClearHttpHeader;

  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticeCode',     PracCode);
  AddHttpHeaderInfo('PracticePassword', PracPass);
  AddHttpHeaderInfo('ClientCode',       ClientCode);
  AddHttpHeaderInfo('ClientName',       ClientName);
  AddHttpHeaderInfo('ClientEmail',      Email);
  AddHttpHeaderInfo('ClientPassword',   '');
  AddHttpHeaderInfo('FileGuid',         TrimedGuid(Guid));

  UploadFile(Filename, HttpAddress);}
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToPractice(ClientCode : string);
var
  HttpAddress : String;
  FileName    : String;
  PracCode    : String;
  CountryCode : String;
  PracPass    : String;
  ClientName  : String;
  Email       : String;
  Guid        : TGuid;
  StrGuid     : String;
begin
  ClearHttpHeader;

  HttpAddress := 'http://development.banklinkonline.com/cico.download';

  CreateGuid(Guid);
  StrGuid := TrimedGuid(Guid);

  AddHttpHeaderInfo('CountryCode',      'NZ');
  AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
  AddHttpHeaderInfo('PracticePassword', '123');
  AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
  AddHttpHeaderInfo('ClientName',       'NZ Test client');
  AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
  AddHttpHeaderInfo('ClientPassword',   '');
  AddHttpHeaderInfo('FileGuid',         StrGuid);

  AppendHttpHeaderInfo;

  HttpGetFile(HttpAddress, 'C:\Temp\110906_101924.bk5');

  {HttpAddress := 'http://development.banklinkonline.com/cico.download';

  GetPracticeDetailsToSend(ClientCode, FileName, Email, ClientName,
                           PracCode, CountryCode, PracPass);

  ClearHttpHeader;

  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticeCode',     PracCode);
  AddHttpHeaderInfo('PracticePassword', PracPass);
  AddHttpHeaderInfo('ClientCode',       ClientCode);
  AddHttpHeaderInfo('ClientName',       ClientName);
  AddHttpHeaderInfo('ClientEmail',      Email);
  AddHttpHeaderInfo('ClientPassword',   '');

  AppendHttpHeaderInfo;

  HttpGetFile(HttpAddress, FileName);}
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromBooks(ClientCode : string);
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  Guid         : TGuid;
  ClientEmail  : String;
  ClientName   : String;
  PracCode     : String;
  CountryCode  : String;
  StrGuid     : String;
begin
  ClearHttpHeader;

  HttpAddress := 'http://development.banklinkonline.com/cico.upload';

  CreateGuid(Guid);
  StrGuid := TrimedGuid(Guid);

  AddHttpHeaderInfo('CountryCode',      'NZ');
  AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
  AddHttpHeaderInfo('PracticePassword', '');
  AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
  AddHttpHeaderInfo('ClientName',       'NZ Test client');
  AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
  AddHttpHeaderInfo('ClientPassword',   '1qaz!QAZ');
  AddHttpHeaderInfo('FileGuid',         StrGuid);

  UploadFile(HttpAddress, 'c:\Temp\UploadBooks.bk5');

  {HttpAddress := 'http://development.banklinkonline.com/cico.upload';

  GetBooksDetailsToSend(ClientCode, FileName, ClientEmail, ClientName, CountryCode, PracCode);

  Guid := GetClientGuid(ClientCode);

  ClearHttpHeader;

  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticeCode',     PracCode);
  AddHttpHeaderInfo('PracticePassword', '');
  AddHttpHeaderInfo('ClientCode',       ClientCode);
  AddHttpHeaderInfo('ClientName',       ClientName);
  AddHttpHeaderInfo('ClientEmail',      ClientEmail);
  AddHttpHeaderInfo('ClientPassword',   fClientPassword);
  AddHttpHeaderInfo('FileGuid',         TrimedGuid(Guid));

  UploadFile(Filename, HttpAddress);}
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToBooks(ClientCode : string);
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  ClientEmail  : String;
  ClientName   : String;
  PracCode     : String;
  CountryCode  : String;
  Guid         : TGuid;
  StrGuid     : String;
begin
  ClearHttpHeader;

  HttpAddress := 'http://development.banklinkonline.com/cico.download';

  CreateGuid(Guid);
  StrGuid := TrimedGuid(Guid);

  AddHttpHeaderInfo('CountryCode',      'NZ');
  AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
  AddHttpHeaderInfo('PracticePassword', '');
  AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
  AddHttpHeaderInfo('ClientName',       'NZ Test client');
  AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
  AddHttpHeaderInfo('ClientPassword',   '1qaz!QAZ');
  AddHttpHeaderInfo('FileGuid',         StrGuid);

  AppendHttpHeaderInfo;

  HttpGetFile(HttpAddress, 'C:\Temp\110906_013259.bk5');

  {HttpAddress := 'http://development.banklinkonline.com/cico.download';

  GetBooksDetailsToSend(ClientCode, FileName, ClientEmail, ClientName, CountryCode, PracCode);
  ClearHttpHeader;

  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticeCode',     PracCode);
  AddHttpHeaderInfo('PracticePassword', '');
  AddHttpHeaderInfo('ClientCode',       ClientCode);
  AddHttpHeaderInfo('ClientName',       ClientName);
  AddHttpHeaderInfo('ClientEmail',      ClientEmail);
  AddHttpHeaderInfo('ClientPassword',   fClientPassword);

  AppendHttpHeaderInfo;

  HttpGetFile(HttpAddress, Filename);}
end;

//------------------------------------------------------------------------------
initialization
  fWebCiCoClient := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fWebCiCoClient);

end.
