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
  TDirectionIndicator = (dirFromClient,
                         dirFromServer);

  TTransferStatus = (trsStartTrans,
                     trsTransInProgress,
                     trsEndTrans);

  TProcessState = (psNothing,
                   psChangePass,
                   psGetStatus,
                   psUploadBooks,
                   psDownloadBooks,
                   psUploadPrac,
                   psDownloadPrac);

  TClientFileStatus = (cfsNoFile,
                       cfsUploadedPractice,
                       cfsDownloadedBooks,
                       cfsUploadedBooks,
                       cfsCopyUploadedBooks,
                       cfsDownloadedPractice);

  //----------------------------------------------------------------------------
  TClientStatusItem = class
  private
    fClientCode : string;
    fClientName : string;
    fLastChange : TDateTime;
    fStatusCode : TClientFileStatus;
  protected
    function GetStatusDesc : string;
  public
    property ClientCode : String read fClientCode write fClientCode;
    property ClientName : String read fClientName write fClientName;
    property LastChange : TDateTime read fLastChange write fLastChange;
    property StatusCode : TClientFileStatus read fStatusCode write fStatusCode;
    property StatusDesc : string read GetStatusDesc;
  end;

  //----------------------------------------------------------------------------
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
    function ServerToDateTime(InString : String) : TDateTime;
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

    // Get Details Required by Service
    procedure GetAdminDetails(var PracCode     : String;
                              var PracPass     : String;
                              var CountryCode  : String);
    procedure GetClientDetails(ClientCode      : string;
                               var ClientEmail : string);
    procedure GetIniDetails(var ClientEmail : string;
                            var ClientPass  : string;
                            var SubDomain   : String);

    // Generic Upload File
    procedure UploadFile(HttpAddress : string;
                         FileName : string);

    // Server Responce Handling
    function GetValueFromNode(ParentNode : IXMLNode; NodeName : String) : String;
    procedure GetUpdateServerReply;
    procedure GetDetailsFromXML;
    procedure BuildStatusListFromXml(const CurrentNode : IXMLNode);

    procedure WaitForProcess;
  public
    constructor Create; Override;
    destructor Destroy; Override;

    procedure GetBooksUserExists(ClientEmail        : string;
                                 ClientPassword     : string;
                                 var ServerResponce : TServerResponce);
    procedure SetBooksUserPassword(ClientEmail    : string;
                                   ClientPassword : string;
                                   NewPassword    : string;
                                   var ServerResponce : TServerResponce);
    procedure GetClientFileStatus(var ServerResponce : TServerResponce;
                                  var ClientStatusList : TClientStatusList;
                                  ClientCode : string = '';
                                  ASyncCall : Boolean = False);
    procedure UploadFileFromPractice(ClientCode : string;
                                     var ClientEmail: string;
                                     var ServerResponce : TServerResponce);
    procedure DownloadFileToPractice(ClientCode : string;
                                     var TempBk5File : string;
                                     var ServerResponce : TServerResponce);
    procedure UploadFileFromBooks(ClientCode : string;
                                  IsCopy : Boolean;
                                  var ServerResponce : TServerResponce);
    procedure DownloadFileToBooks(ClientCode : string;
                                  var TempBk5File : string;
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
  Windows,
  LogUtil;

const
  XML_STATUS_HEADNAME             = 'Result';
  XML_STATUS_CODE                 = 'Code';
  XML_STATUS_DESC                 = 'Description';
  XML_STATUS_DETAIL_DESC          = 'DetailedDescription';
  XML_STATUS_CLIENT               = 'File';
  XML_STATUS_CLIENT_CODE          = 'ClientCode';
  XML_STATUS_CLIENT_NAME          = 'ClientName';
  XML_STATUS_LAST_CHANGE_DATE     = 'LastChange';
  XML_STATUS_FILE_ATTR_STATUSCODE = 'StatusCode';
  XML_STATUS_FILE_ATTR_STATUSDESC = 'StatusCodeDescription';

  HTTP_HEAD_PRACTICE_CODE      = 'PracticeCode';
  HTTP_HEAD_PRACTICE_PASSWORD  = 'PracticePassword';
  HTTP_HEAD_PRACTICE_SUBDOMAIN = 'PracticeDomain';
  HTTP_HEAD_CLIENT_CODE        = 'ClientCode';
  HTTP_HEAD_CLIENT_EMAIL       = 'ClientEmail';
  HTTP_HEAD_CLIENT_PASSWORD    = 'ClientPassword';
  HTTP_HEAD_COUNTRY_CODE       = 'CountryCode';
  HTTP_HEAD_BOOKS_COPY         = 'Copy';
  HTTP_HEAD_BOOKS_NEWPASSWORD  = 'NewPassword';
  HTTP_HEAD_FILE_CRC           = 'FileCRC';
  HTTP_HEAD_FILE_LENGTH        = 'FileLength';
  HTTP_HEAD_CONTENT_LENGTH     = 'Content-Length';
  HTTP_HEAD_CONTENT_TYPE       = 'Content-Type';
  HTTP_HEAD_SERVER_FILE_CRC    = 'CRC';

  SERVER_CONTENT_TYPE_XML = '.xml; charset=utf-8';
  SERVER_CONTENT_TYPE_BK5 = '.bk5';

  BASE_URL_ADDRESS = 'http://development.banklinkonline.com';
  PRODUCT_URL_NAME = '/cico';
  URL_ADDRESS      = BASE_URL_ADDRESS + PRODUCT_URL_NAME;
  URL_SERVICE_ACTION_UPLOAD      = '.upload';
  URL_SERVICE_ACTION_DONWNLOAD   = '.download';
  URL_SERVICE_ACTION_GET_STATUS  = '.status';
  URL_SERVICE_ACTION_PASS_CHANGE = '.admin';

  UNIT_NAME = 'WebCiCoClient';

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
    cfsUploadedBooks      : Result := 'Uploaded by BOOKS';
    cfsDownloadedBooks    : Result := 'Downloaded by BOOKS';
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
function TWebCiCoClient.ServerToDateTime(InString : String) : TDateTime;
var
  Year : word;
  Month : word;
  Day : word;
  Hour : word;
  Minute : word;
  Second : word;
  StartStr : Integer;
  EndStr   : Integer;

  //------------------------------------------------
  Function GetNextNumber(Search : String) : integer;
  begin
    EndStr := Pos(Search, RightStr(InString, Length(InString) - (StartStr-1))) + StartStr-2;
    Result := StrToInt(MidStr(InString, StartStr, EndStr-StartStr+1));
    StartStr := EndStr + 2;
  end;
begin
  Result := 0;
  StartStr := 1;

  Try
    Day := GetNextNumber('/');
    Month := GetNextNumber('/');
    Year := GetNextNumber(' ');
    Result := EncodeDate(Year, Month, Day);

    Hour := GetNextNumber(':');
    Minute := GetNextNumber(':');
    Second := GetNextNumber(' ');

    if (UpperCase(MidStr(InString, StartStr, 1)) = 'P') and
       (Hour < 12) then
      Hour := Hour + 12;

    Result := Result + EncodeTime(Hour, Minute, Second, 0);
  except
    RaiseHttpError('Cico - Error in XML Server Responce! Last Change Date Invalid.', 303);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseHttpError(ErrMessage : String; ErrCode : integer);
begin
  logutil.LogError(UNIT_NAME, format('%s Error:<%s>',[InttoStr(ErrCode), ErrMessage] ));

  raise EWebHttpCiCoClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpConnectionStatus(Sender: TObject;
                                                const ConnectionEvent: String;
                                                StatusCode: Integer;
                                                const Description: String);
var
  StrMessage : String;
begin
  inherited;

  StrMessage := 'ConnectionEvent : ' + ConnectionEvent + ', ' +
                'Status Code : ' + InttoStr(StatusCode) + ', ' +
                'Description : ' + Description;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpSSLServerAuthentication(Sender: TObject;
                                                       CertEncoded: String;
                                                       const CertSubject: String;
                                                       const CertIssuer: String;
                                                       const Status: String;
                                                       var  Accept: Boolean);
var
  StrMessage : String;
begin
  inherited;

  StrMessage := 'Cert Encoded : ' + CertEncoded + ', ' +
                'Cert Subject : ' + CertSubject + ', ' +
                'Cert Issuer : ' + CertIssuer + ', ' +
                'Status : ' + Status;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpStartTransfer(Sender: TObject;
                                             Direction: Integer);
var
  StrMessage : String;
begin
  inherited;

  if Direction = 0 then
    StrMessage := 'Start Transfer : from Client'
  else
    StrMessage := 'Start Transfer : from Server';

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

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
var
  StrMessage : String;
begin
  inherited;

  if Direction = 0 then
    StrMessage := 'Transfer : from Client, ' +
                  'Bytes Transferred : ' + InttoStr(BytesTransferred)
  else
    StrMessage := 'Transfer : from Server, ' +
                  'Bytes Transferred : ' + InttoStr(BytesTransferred);

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

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
var
  StrMessage : String;
begin
  inherited;

  if Direction = 0 then
    StrMessage := 'End Transfer : from Client, Total Bytes : ' + InttoStr(fTotalBytes)
  else
    StrMessage := 'End Transfer : from Server, Total Bytes : ' + InttoStr(fTotalBytes);

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

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
var
  StrMessage : String;
begin
  Inherited;

  StrMessage := 'Header Field : ' + Field + ', ' +
                'Header Value : ' + Value;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

  // works out Content Length, Type and CRC from headers
  if Field = HTTP_HEAD_CONTENT_LENGTH then
    trystrtoint(Value, fTotalBytes)
  else if Field = HTTP_HEAD_CONTENT_TYPE then
    fContentType := Value
  else if Field = HTTP_HEAD_SERVER_FILE_CRC then
    FServerCrc := Value;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetAdminDetails(var PracCode    : String;
                                         var PracPass    : String;
                                         var CountryCode : String);
begin
  PracCode    := AdminSystem.fdFields.fdBankLink_Code;
  PracPass    := AdminSystem.fdFields.fdBankLink_Connect_Password;
  CountryCode := CountryText(AdminSystem.fdFields.fdCountry);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientDetails(ClientCode      : string;
                                          var ClientEmail : string);
var
  fClientObj    : TClientObj;
begin
  fClientObj := TClientObj.Create;
  Try
    fClientObj.Open(ClientCode, FILEEXTN);
    ClientEmail := fClientObj.clFields.clClient_EMail_Address;
  Finally
    FreeAndNil(fClientObj);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetIniDetails(var ClientEmail : string;
                                       var ClientPass  : string;
                                       var SubDomain   : String);
begin
  // Todo Get Ini Details
  ClientEmail := StartupParam_UserToLoginAs;
  ClientPass  := StartupParam_UserPassword;
  SubDomain   := INI_BankLink_Online_SubDomain;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFile(HttpAddress : string;
                                    FileName : string);
var
  FileCRC      : String;
  FileLength   : Integer;
begin
  if not FileExists(Filename) then
    RaiseHttpError('Can''t open AttachedFile. (' + Filename + ')', 302);

  FileInfo(Filename, FileCRC, FileLength);

  // Adding Crc to Header Section
  AddHttpHeaderInfo(HTTP_HEAD_FILE_CRC,    FileCRC);
  AddHttpHeaderInfo(HTTP_HEAD_FILE_LENGTH, inttostr(FileLength));
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
  if (Assigned(CurrentNode)) and
     (TVarData(CurrentNode.NodeValue).Vtype = varOleStr) then
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
      RaiseHttpError('Cico - Error in XML Server Responce!', 303);

    if XMLDoc.DocumentElement.ChildNodes.Count = 0 then
      RaiseHttpError('Cico - Error in XML Server Responce!', 303);

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
  NewClientStatusItem : TClientStatusItem;
  LocalNode  : IXMLNode;
  StatusInt  : integer;
  StringDate : String;
begin
  LocalNode := CurrentNode.ChildNodes.FindNode(XML_STATUS_CLIENT);

  while Assigned(LocalNode) do
  begin
    NewClientStatusItem := TClientStatusItem.Create;
    NewClientStatusItem.ClientCode := LocalNode.Attributes[XML_STATUS_CLIENT_CODE];
    NewClientStatusItem.ClientName := LocalNode.Attributes[XML_STATUS_CLIENT_NAME];

    // Status Code
    if TryStrToInt(LocalNode.Attributes[XML_STATUS_FILE_ATTR_STATUSCODE], StatusInt) then
    begin
      if (StatusInt >= ord(cfsNoFile)) and
         (StatusInt <= ord(cfsDownloadedPractice)) then
        NewClientStatusItem.StatusCode := TClientFileStatus(StatusInt)
      else
        RaiseHttpError('Cico - Error in XML Server Responce! Status Code Invalid.', 303);
    end
    else
      RaiseHttpError('Cico - Error in XML Server Responce! Status Code Invalid.', 303);

    // Last Change Date
    if NewClientStatusItem.StatusCode = cfsNoFile  then
    begin
      NewClientStatusItem.LastChange := 0;
    end
    else
    begin
      StringDate := LocalNode.Attributes[XML_STATUS_LAST_CHANGE_DATE];
      NewClientStatusItem.LastChange := ServerToDateTime(StringDate);
    end;

    fServerClientStatusList.Add(NewClientStatusItem);

    LocalNode := CurrentNode.ChildNodes.FindSibling(LocalNode, 1);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.WaitForProcess;
var
  StartTick : Longword;
  TimeOut   : Longword;
begin
  TimeOut   := (HttpRequester.Timeout * 1000);
  StartTick := GetTickCount;
  while (fProcessState <> psNothing) do
  begin
    HttpRequester.DoEvents;

    if ((GetTickCount - StartTick) >= TimeOut ) then
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
procedure TWebCiCoClient.GetBooksUserExists(ClientEmail        : string;
                                            ClientPassword     : string;
                                            var ServerResponce : TServerResponce);
var
  HttpAddress    : String;
  BooksEmail     : String;
  BooksPassword  : String;
  SubDomain      : String;
begin
  if Assigned(AdminSystem) then
    Exit;

  fProcessState := psGetStatus;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Client File Status.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_GET_STATUS;

    GetIniDetails(BooksEmail, BooksPassword, SubDomain);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       'pj.jacobs@banklink.co.nz');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    '1qaz!QAZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, 'nzpractice');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '');
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE      , '');
    AppendHttpHeaderInfo;

    FASyncCall := False;
    HttpSendRequest(HttpAddress);

    WaitForProcess;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.SetBooksUserPassword(ClientEmail    : string;
                                              ClientPassword : string;
                                              NewPassword    : string;
                                              var ServerResponce : TServerResponce);
var
  HttpAddress    : String;
  BooksEmail     : String;
  BooksPassword  : String;
  SubDomain      : String;
begin
  fProcessState := psChangePass;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Set Books User Password.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_PASS_CHANGE;

    GetIniDetails(BooksEmail, BooksPassword, SubDomain);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       'pj.jacobs@banklink.co.nz');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    '1qaz!QAZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, 'nzpractice');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_BOOKS_NEWPASSWORD, NewPassword);
    AppendHttpHeaderInfo;

    HttpSendRequest(HttpAddress);

    WaitForProcess;

    ServerResponce := fServerResponce;
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
  HttpAddress    : string;
  PracticeCode   : String;
  PracticePass   : String;
  CountryCode    : String;
  ClientEmail    : String;
  ClientPassword : String;
  SubDomain      : String;
  Index          : Integer;
  NewClientStatusItem : TClientStatusItem;
begin
  fProcessState := psGetStatus;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Client File Status.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_GET_STATUS;

    if Assigned(AdminSystem) then
    begin
      GetAdminDetails(PracticeCode, PracticePass, CountryCode);

      {$IFDEF WebCiCoStatic}
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '123');
        AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      'NZ');
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     'NZPRACTICE');
      {$ELSE}
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
        AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
      {$ENDIF}

      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,    '');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD, '');
    end
    else
    begin
      GetIniDetails(ClientEmail, ClientPassword, SubDomain);

      {$IFDEF WebCiCoStatic}
        AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       'pj.jacobs@banklink.co.nz');
        AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    '1qaz!QAZ');
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, 'nzpractice');
      {$ELSE}
        AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
        AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
        AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
      {$ENDIF}

      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '');
    end;

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, ClientCode);
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
        NewClientStatusItem.ClientName := fServerClientStatusList.Items[Index].ClientName;
        NewClientStatusItem.StatusCode := fServerClientStatusList.Items[Index].StatusCode;
        NewClientStatusItem.LastChange := fServerClientStatusList.Items[Index].LastChange;
        ClientStatusList.Add(NewClientStatusItem);
      end;
    end;

  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromPractice(ClientCode : string;
                                                var ClientEmail: string;
                                                var ServerResponce : TServerResponce);
var
  HttpAddress  : String;
  PracticeCode : String;
  PracticePass : String;
  CountryCode  : String;
begin
  fProcessState := psUploadPrac;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Upload File From Practice.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_UPLOAD;

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);
    GetClientDetails(ClientCode, ClientEmail);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      'NZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     'NZPRACTICE');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '123');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,      'pj.jacobs@banklink.co.nz');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,      ClientEmail);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, ClientCode);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD, '');

    UploadFile(HttpAddress, DataDir + ClientCode + FILEEXTN);

    WaitForProcess;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToPractice(ClientCode : string;
                                                var TempBk5File : string;
                                                var ServerResponce : TServerResponce);
var
  HttpAddress  : String;
  PracticeCode : String;
  PracticePass : String;
  CountryCode  : String;
  FileCrc      : String;
  FileSize     : Integer;
  Guid         : TGuid;
  StrGuid      : String;
  TempPath     : String;
begin
  fProcessState := psDownloadPrac;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Download File To Practice.');

  try
    TempBk5File := '';
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      'NZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     'NZPRACTICE');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '123');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,       ClientCode);

    AppendHttpHeaderInfo;

    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    TempBk5File := TempPath + ClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, TempBk5File);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(TempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromBooks(ClientCode : string;
                                             IsCopy : Boolean;
                                             var ServerResponce : TServerResponce);
var
  HttpAddress    : string;
  ClientEmail    : String;
  SubDomain      : String;
  ClientPassword : String;
begin
  fProcessState := psUploadBooks;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Upload File From Books.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_UPLOAD;

    GetIniDetails(ClientEmail, ClientPassword, SubDomain);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       'pj.jacobs@banklink.co.nz');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    '1qaz!QAZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, 'nzpractice');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, ClientCode);

    if IsCopy then
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '1')
    else
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '0');

    UploadFile(HttpAddress, DataDir + ClientCode + FILEEXTN);

    WaitForProcess;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToBooks(ClientCode : string;
                                             var TempBk5File : string;
                                             var ServerResponce : TServerResponce);
var
  HttpAddress    : string;
  ClientEmail    : String;
  SubDomain      : String;
  ClientPassword : String;
  FileCrc        : String;
  FileSize       : Integer;
  Guid           : TGuid;
  StrGuid        : String;
  TempPath       : String;
begin
  fProcessState := psDownloadBooks;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Download File To Books.');

  try
    TempBk5File := '';
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetIniDetails(ClientEmail, ClientPassword, SubDomain);

    {$IFDEF WebCiCoStatic}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       'pj.jacobs@banklink.co.nz');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    '1qaz!QAZ');
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, 'nzpractice');
    {$ELSE}
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    {$ENDIF}

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, ClientCode);

    AppendHttpHeaderInfo;

    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    TempBk5File := TempPath + ClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, TempBk5File);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(TempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    ServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
initialization
  fWebCiCoClient := nil;
  DebugMe := DebugUnit(UNIT_NAME);
  WebClient.DebugMe := DebugMe;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fWebCiCoClient);

end.
