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
  TProcessState = (psNothing, psChangePass, psGetStatus, psUploadBooks, psDownloadBooks, psUploadPrac, psDownloadPrac);
  TClientFileStatus = (cfsNoFile, cfsUploadedPractice, cfsDownloadedPractice, cfsUploadedBooks, cfsDownloadedBooks, cfsCopyUploadedBooks);

  TClientStatusItem = class
  private
    fClientCode : string;
    fStatusCode : TClientFileStatus;
  protected
    function GetStatusDesc : string;
  public
    property ClientCode : String read fClientCode write fClientCode;
    property StatusCode : TClientFileStatus read fStatusCode write fStatusCode;
    property StatusDesc : string read GetStatusDesc;
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

  EWebHttpCiCoClientError = class(EWebHttpClientError)
  end;

  //----------------------------------------------------------------------------
  TServerResponce = record
    Status : String;
    Description : String;
    DetailedDesc : String;
  end;

  //----------------------------------------------------------------------------
  TTransferFileEvent = procedure (Direction: TDirectionIndicator;
                                  TransferStatus : TTransferStatus;
                                  BytesTransferred: LongInt;
                                  TotalBytes: LongInt;
                                  ContentType: String) of object;

  TStatusEvent = procedure (StatusMessage : string) of object;

  TServerStatusEvent = procedure (ServerResponce : TServerResponce;
                                  ClientStatusList : TClientStatusList) of object;

  //----------------------------------------------------------------------------
  TWebCiCoClient = class(TWebClient)
  private
    fStatusEvent       : TStatusEvent;
    fTransferFileEvent : TTransferFileEvent;
    fServerStatusEvent : TServerStatusEvent;

    fTotalBytes       : LongInt;
    fClientPassword   : string;
    fIsBooks          : Boolean;
    fServerReply      : string;
    fContentType      : string;
    FServerCrc        : string;

    fProcessState     : TProcessState;

    fServerResponce : TServerResponce;
    fServerClientStatusList : TClientStatusList;

    FASyncCall : Boolean;
    procedure FileInfo(Filename     : String;
                       var FileCRC  : String;
                       var FileSize : Integer);
    function TrimedGuid(Guid: TGuid): String;
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

    procedure UploadFile(HttpAddress : string;
                         FileName : string);

    function GetValueFromNode(ParentNode : IXMLNode; NodeName : String) : String;
    procedure GetUpdateServerReply;
    procedure GetDetailsFromXML;
    procedure BuildStatusListFromXml(const CurrentNode : IXMLNode);

    procedure WaitForProcess;
  public
    constructor Create; Override;
    destructor Destroy; Override;

    procedure SetBooksUserPassword(ClientCode  : string;
                                   OldPassword : string;
                                   NewPassword : string);
    procedure GetClientFileStatus(var ServerResponce : TServerResponce;
                                  var ClientStatusList : TClientStatusList;
                                  ClientCode : string = '';
                                  ASyncCall : Boolean = False);
    procedure UploadFileFromPractice(ClientCode : string;
                                     var Email: string;
                                     var ServerResponce : TServerResponce);
    procedure DownloadFileToPractice(ClientCode : string;
                                     var ServerResponce : TServerResponce);
    procedure UploadFileFromBooks(ClientCode : string;
                                  var ServerResponce : TServerResponce);
    procedure DownloadFileToBooks(ClientCode : string;
                                  var ServerResponce : TServerResponce);

    property OnStatusEvent : TStatusEvent read fStatusEvent write fStatusEvent;
    property OnTransferFileEvent : TTransferFileEvent read fTransferFileEvent write fTransferFileEvent;
    property OnServerStatusEvent : TServerStatusEvent read fServerStatusEvent write fServerStatusEvent;
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
  StrUtils,
  Windows;

const
  XML_STATUS_HEADNAME             = 'Result';
  XML_STATUS_CODE                 = 'Code';
  XML_STATUS_DESC                 = 'Description';
  XML_STATUS_DETAIL_DESC          = 'DetailedDescription';
  XML_STATUS_CLIENT               = 'File';
  XML_STATUS_CLIENT_CODE          = 'ClientCode';
  XML_STATUS_FILE_ATTR_STATUSCODE = 'StatusCode';
  XML_STATUS_FILE_ATTR_STATUSDESC = 'StatusCodeDescription';

  SERVER_CONTENT_TYPE_XML = '.xml; charset=utf-8';
  SERVER_CONTENT_TYPE_BK5 = '.bk5';

  WAIT_TIMEOUT = 60000; // milliseconds

var
  fWebCiCoClient : TWebCiCoClient;

//------------------------------------------------------------------------------
function CiCoClient : TWebCiCoClient;
begin
  if not Assigned( fWebCiCoClient) then
  begin
    fWebCiCoClient := TWebCiCoClient.Create;
  end;

  result := fWebCiCoClient;
end;

{ TClientStatusItem }
//------------------------------------------------------------------------------
function TClientStatusItem.GetStatusDesc: string;
begin
  case fStatusCode of
    cfsNoFile             : Result := 'No File';
    cfsUploadedPractice   : Result := 'Uploaded by PRACTICE';
    cfsDownloadedPractice : Result := 'Downloaded by PRACTICE';
    cfsUploadedBooks      : Result := 'Downloaded by BOOKS';
    cfsDownloadedBooks    : Result := 'Uploaded by BOOKS';
    cfsCopyUploadedBooks  : Result := 'COPY Uploaded by BOOKS';
  end;
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
function TWebCiCoClient.TrimedGuid(Guid: TGuid): String;
begin
  // Trims the { and } off the ends of the Guid to pass to the server
  Result := midstr(GuidToString(Guid),2,length(GuidToString(Guid))-2);
end;

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
    fServerReply := '';
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

  // Builds Server Message
  if TDirectionIndicator(Direction) = dirFromServer then
    fServerReply := fServerReply + Text;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpEndTransfer(Sender: TObject;
                                           Direction: Integer);
begin
  inherited;

  // Status Event
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('End Transfer : from Client, Total Bytes : ' + InttoStr(fTotalBytes))
    else
      fStatusEvent('End Transfer : from Server, Total Bytes : ' + InttoStr(fTotalBytes));
  end;

  // Transfer File Event
  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsEndTrans, fTotalBytes, fTotalBytes, fContentType);

  // Handle Server Reply
  if (TDirectionIndicator(Direction) = dirFromServer) then
    GetUpdateServerReply;
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

  // works out Content Length, Type and CRC from headers
  if Field = 'Content-Length' then
    trystrtoint(Value, fTotalBytes)
  else if Field = 'Content-Type' then
    fContentType := Value
  else if Field = 'CRC' then
    FServerCrc := Value;
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
  HttpRequester.ContentType := SERVER_CONTENT_TYPE_BK5;
  fContentType := HttpRequester.ContentType;
  fTotalBytes  := FileLength;
  AppendHttpHeaderInfo;

  HttpPostFile(HttpAddress, Filename);
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
procedure TWebCiCoClient.GetUpdateServerReply;
begin
  Try
    fServerResponce.Status       := '';
    fServerResponce.Description  := '';
    fServerResponce.DetailedDesc := '';
    fServerClientStatusList.Clear;

    if fContentType = SERVER_CONTENT_TYPE_XML then
      GetDetailsFromXML
    else if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      fServerResponce.Status       := '200';
      fServerResponce.Description  := 'File Downloaded';
      fServerResponce.DetailedDesc := 'BK5 File Downloaded';
    end;
  finally
    fProcessState := psNothing;
  End;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetDetailsFromXML;
var
  XMLDoc : IXMLDocument;
  CurrentNode : IXMLNode;
begin
  if pos('<' + XML_STATUS_HEADNAME + '>', fServerReply) = 0 then
    RaiseHttpError('Cico - Error in XML Server Responce!', 303);

  XMLDoc := MakeXMLDoc(fServerReply);
  try
    CurrentNode := XMLDoc.DocumentElement;
    if CurrentNode.NodeName <> XML_STATUS_HEADNAME then
      Exit;

    if XMLDoc.DocumentElement.ChildNodes.Count = 0 then
      Exit;

    fServerResponce.Status       := GetValueFromNode(CurrentNode, XML_STATUS_CODE);
    fServerResponce.Description  := GetValueFromNode(CurrentNode, XML_STATUS_DESC);
    fServerResponce.DetailedDesc := GetValueFromNode(CurrentNode, XML_STATUS_DETAIL_DESC);

    BuildStatusListFromXml(CurrentNode);

    if (Assigned(fServerStatusEvent)) and
       (fASyncCall) then
      fServerStatusEvent(fServerResponce, fServerClientStatusList);

  finally
    CurrentNode := Nil;
    XMLDoc := Nil;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.BuildStatusListFromXml(const CurrentNode : IXMLNode);
var
  FileNode    : IXMLNode;
  ClientIndex : integer;
  NewClientStatusItem : TClientStatusItem;
  LocalNode : IXMLNode;
  StatusInt : integer;
begin
  LocalNode := CurrentNode.ChildNodes.FindNode(XML_STATUS_CLIENT);

  while Assigned(LocalNode) do
  begin
    NewClientStatusItem := TClientStatusItem.Create;
    NewClientStatusItem.ClientCode := LocalNode.Attributes[XML_STATUS_CLIENT_CODE];

    if TryStrToInt(LocalNode.Attributes[XML_STATUS_FILE_ATTR_STATUSCODE], StatusInt) then
    begin
      if (StatusInt >= ord(cfsNoFile)) and
         (StatusInt <= ord(cfsCopyUploadedBooks)) then
        NewClientStatusItem.StatusCode := TClientFileStatus(StatusInt)
      else
        RaiseHttpError('Cico - Error in XML Server Responce! Status Code Invalid.', 303);
    end
    else
      RaiseHttpError('Cico - Error in XML Server Responce! Status Code Invalid.', 303);

    fServerClientStatusList.Add(NewClientStatusItem);

    LocalNode := CurrentNode.ChildNodes.FindSibling(LocalNode, 1);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.WaitForProcess;
var
  StartTick : Longword;
begin
  StartTick := GetTickCount;
  while (fProcessState <> psNothing) do
  begin
    HttpRequester.DoEvents;

    if ((GetTickCount - StartTick) >= WAIT_TIMEOUT) then
      RaiseHttpError('Cico - Operation timeout!', 301);
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
  fProcessState := psNothing;

  fServerClientStatusList := TClientStatusList.Create;
end;

//------------------------------------------------------------------------------
destructor TWebCiCoClient.Destroy;
begin
  FreeAndNil(fServerClientStatusList);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.SetBooksUserPassword(ClientCode  : string;
                                              OldPassword : string;
                                              NewPassword : string);
var
  HttpAddress : String;
begin
  fProcessState := psChangePass;

  try
    HttpAddress := 'http://posttestserver.com/post.php';

    AddHttpHeaderInfo('ClientCode', ClientCode);
    AddHttpHeaderInfo('OldPassword', OldPassword);
    AddHttpHeaderInfo('NewPassword', NewPassword);
    AppendHttpHeaderInfo;

    HttpPostFile(HttpAddress, '');

    //WaitForProcess;

  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientFileStatus(var ServerResponce : TServerResponce;
                                             var ClientStatusList : TClientStatusList;
                                             ClientCode : string = '';
                                             ASyncCall : Boolean = False);
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
  Index        : Integer;
  NewClientStatusItem : TClientStatusItem;
begin
  fProcessState := psGetStatus;

  try
    ClearHttpHeader;

    HttpAddress := 'http://development.banklinkonline.com/cico.status';

    AddHttpHeaderInfo('CountryCode',      'NZ');
    AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
    AddHttpHeaderInfo('PracticePassword', '123');
    AddHttpHeaderInfo('ClientCode',       ClientCode);
    AddHttpHeaderInfo('ClientName',       '');
    AddHttpHeaderInfo('ClientEmail',      '');
    AddHttpHeaderInfo('ClientPassword',   '');

    AppendHttpHeaderInfo;

    FASyncCall := ASyncCall;

    HttpSendRequest(HttpAddress);

    if not ASyncCall then
    begin
      WaitForProcess;

      ServerResponce := fServerResponce;

      for Index := 0 to fServerClientStatusList.Count - 1 do
      begin
        NewClientStatusItem := TClientStatusItem.Create;
        NewClientStatusItem.ClientCode := fServerClientStatusList.Items[Index].ClientCode;
        NewClientStatusItem.StatusCode := fServerClientStatusList.Items[Index].StatusCode;
        ClientStatusList.Add(NewClientStatusItem);
      end;
    end;

  finally
    fProcessState := psNothing;
  end;

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
procedure TWebCiCoClient.UploadFileFromPractice(ClientCode : string;
                                                var Email: string;
                                                var ServerResponce : TServerResponce);
var
  HttpAddress : String;
  FileName    : String;
  PracCode    : String;
  CountryCode : String;
  PracPass    : String;
  ClientName  : String;
  Guid        : TGuid;
  StrGuid     : String;
begin
  fProcessState := psUploadPrac;
  try
    ClearHttpHeader;

    HttpAddress := 'http://development.banklinkonline.com/cico.upload';

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);
    AddHttpHeaderInfo('FileGuid',         StrGuid);
    AddHttpHeaderInfo('CountryCode',      'NZ');
    AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
    AddHttpHeaderInfo('PracticePassword', '123');
    AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
    AddHttpHeaderInfo('ClientName',       'NZ Test client');
    AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
    AddHttpHeaderInfo('ClientPassword',   '');

    UploadFile(HttpAddress, 'c:\temp\UploadPrac.bk5');

    WaitForProcess;

    Email        := '';
    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;

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
procedure TWebCiCoClient.DownloadFileToPractice(ClientCode : string;
                                                var ServerResponce : TServerResponce);
var
  HttpAddress : String;
  FileName    : String;
  PracCode    : String;
  CountryCode : String;
  PracPass    : String;
  ClientName  : String;
  Email       : String;
  FileCrc     : String;
  FileSize    : Integer;
  Guid         : TGuid;
  StrGuid      : String;
begin
  fProcessState := psDownloadPrac;
  try
    ClearHttpHeader;

    HttpAddress := 'http://development.banklinkonline.com/cico.download';

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);
    AddHttpHeaderInfo('FileGuid',         StrGuid);
    AddHttpHeaderInfo('CountryCode',      'NZ');
    AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
    AddHttpHeaderInfo('PracticePassword', '123');
    AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
    AddHttpHeaderInfo('ClientName',       'NZ Test client');
    AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
    AddHttpHeaderInfo('ClientPassword',   '');

    AppendHttpHeaderInfo;

    FileName := 'C:\Temp\110906_101924.bk5';
    HttpGetFile(HttpAddress, FileName);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(FileName, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;

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
procedure TWebCiCoClient.UploadFileFromBooks(ClientCode : string;
                                             var ServerResponce : TServerResponce);
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  ClientEmail  : String;
  ClientName   : String;
  PracCode     : String;
  CountryCode  : String;
  Guid         : TGuid;
  StrGuid      : String;
begin
  fProcessState := psUploadBooks;
  try
    ClearHttpHeader;

    HttpAddress := 'http://development.banklinkonline.com/cico.upload';

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);
    AddHttpHeaderInfo('FileGuid',         StrGuid);
    AddHttpHeaderInfo('CountryCode',      'NZ');
    AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
    AddHttpHeaderInfo('PracticePassword', '');
    AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
    AddHttpHeaderInfo('ClientName',       'NZ Test client');
    AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
    AddHttpHeaderInfo('ClientPassword',   '1qaz!QAZ');

    UploadFile(HttpAddress, 'c:\Temp\UploadBooks.bk5');

    WaitForProcess;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
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
procedure TWebCiCoClient.DownloadFileToBooks(ClientCode : string;
                                             var ServerResponce : TServerResponce);
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  ClientEmail  : String;
  ClientName   : String;
  PracCode     : String;
  CountryCode  : String;
  FileCrc      : String;
  FileSize     : Integer;
  Guid         : TGuid;
  StrGuid      : String;
begin
  fProcessState := psDownloadBooks;
  try
    ClearHttpHeader;

    HttpAddress := 'http://development.banklinkonline.com/cico.download';

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);
    AddHttpHeaderInfo('FileGuid',         StrGuid);
    AddHttpHeaderInfo('CountryCode',      'NZ');
    AddHttpHeaderInfo('PracticeCode',     'NZPRACTICE');
    AddHttpHeaderInfo('PracticePassword', '');
    AddHttpHeaderInfo('ClientCode',       'NZCLIENT');
    AddHttpHeaderInfo('ClientName',       'NZ Test client');
    AddHttpHeaderInfo('ClientEmail',      'pj.jacobs@banklink.co.nz');
    AddHttpHeaderInfo('ClientPassword',   '1qaz!QAZ');

    AppendHttpHeaderInfo;

    FileName := 'C:\Temp\110906_013259.bk5';
    HttpGetFile(HttpAddress, FileName);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(FileName, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
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
