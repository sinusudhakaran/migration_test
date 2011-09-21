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
    function Get(Index : Integer): TClientStatusItem;
    procedure Put(Index : Integer;
                  Item  : TClientStatusItem);
  public
    destructor Destroy; override;

    function GetStatusFromCode(AClientCode : string) : TClientStatusItem;

    property Items[Index : Integer]: TClientStatusItem read Get write Put; default;
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
  TTransferFileEvent = procedure (Direction        : TDirectionIndicator;
                                  TransferStatus   : TTransferStatus;
                                  BytesTransferred : LongInt;
                                  TotalBytes       : LongInt;
                                  ContentType      : String) of object;

  TStatusEvent = procedure (StatusMessage : string) of object;

  TServerStatusEvent = procedure (ServerResponce   : TServerResponce;
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
    procedure FileInfo(AFilename     : String;
                       var AFileCRC  : String;
                       var AFileSize : Integer);
    function TrimedGuid(AGuid : TGuid): String;
    function ServerToDateTime(AInString : String) : TDateTime;
  protected
    procedure RaiseHttpError(AErrMessage : String;
                             AErrCode    : integer); override;

    // Http Used Events
    procedure DoHttpConnectionStatus(ASender : TObject;
                                     const AConnectionEvent : String;
                                     AStatusCode : Integer;
                                     const ADescription : String); Override;
    procedure DoHttpSSLServerAuthentication(ASender      : TObject;
                                            ACertEncoded : String;
                                            const ACertSubject : String;
                                            const ACertIssuer  : String;
                                            const AStatus      : String;
                                            var   AAccept      : Boolean); Override;
    procedure DoHttpStartTransfer(ASender    : TObject;
                                  ADirection : Integer); Override;
    procedure DoHttpTransfer(ASender           : TObject;
                             ADirection        : Integer;
                             ABytesTransferred : LongInt;
                             AText             : String); Override;
    procedure DoHttpEndTransfer(ASender    : TObject;
                                ADirection : Integer); Override;
    procedure DoHttpHeader(ASender: TObject;
                           const AField : String;
                           const AValue : String); Override;

    // Get Details Required by Service
    procedure GetAdminDetails(var APracCode    : String;
                              var APracPass    : String;
                              var ACountryCode : String);
    procedure GetClientDetails(AClientCode      : string;
                               var AClientEmail : string;
                               var AClientName  : string);
    procedure GetIniDetails(var AClientEmail : string;
                            var AClientPass  : string;
                            var ASubDomain   : String);

    // Generic Upload File
    procedure UploadFile(AHttpAddress : string;
                         AFileName    : string);

    // Server Responce Handling
    function GetValueFromNode(AParentNode : IXMLNode;
                              ANodeName   : String) : String;
    procedure GetUpdateServerReply;
    procedure GetDetailsFromXML;
    procedure BuildStatusListFromXml(const ACurrentNode : IXMLNode);

    procedure WaitForProcess;
  public
    constructor Create; Override;
    destructor Destroy; Override;

    procedure GetBooksUserExists(AClientEmail    : string;
                                 AClientPassword : string;
                                 var AServerResponce : TServerResponce);
    procedure SetBooksUserPassword(AClientEmail    : string;
                                   AClientPassword : string;
                                   ANewPassword    : string;
                                   var AServerResponce : TServerResponce);
    procedure GetClientFileStatus(var AServerResponce   : TServerResponce;
                                  var AClientStatusList : TClientStatusList;
                                  AClientCode : string = '';
                                  AaSyncCall  : Boolean = False);
    procedure UploadFileFromPractice(AClientCode : string;
                                     var AClientEmail    : string;
                                     var AServerResponce : TServerResponce);
    procedure DownloadFileToPractice(AClientCode : string;
                                     var ATempBk5File    : string;
                                     var AServerResponce : TServerResponce);
    procedure UploadFileFromBooks(AClientCode : string;
                                  AIsCopy     : Boolean;
                                  var AServerResponce : TServerResponce);
    procedure DownloadFileToBooks(AClientCode : string;
                                  var ATempBk5File    : string;
                                  var AServerResponce : TServerResponce);

    property OnStatusEvent       : TStatusEvent       read fStatusEvent       write fStatusEvent;
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
  HTTP_HEAD_CLIENT_NAME        = 'ClientName';
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
procedure TClientStatusList.Put(Index : Integer;
                                Item  : TClientStatusItem);
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
function TClientStatusList.GetStatusFromCode(AClientCode : string) : TClientStatusItem;
var
  ClientIndex : integer;
begin
  Result := nil;
  for ClientIndex := 0 to Count-1 do
  begin
    if Self.Items[ClientIndex].ClientCode = AClientCode then
    begin
      Result := Self.Items[ClientIndex];
      Exit;
    end;
  end;
end;

{ TWebCiCoClient }
//------------------------------------------------------------------------------
procedure TWebCiCoClient.FileInfo(AFilename     : String;
                                  var AFileCRC  : String;
                                  var AFileSize : Integer);
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
  FileStream := TFileStream.Create(AFilename, fmOpenRead);
  Try
    AFileSize := FileStream.Size;

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

      AFileCRC := EncodeString(Sha1String);
    Finally
      FreeAndNil(IdHashSHA1);
    End;
  Finally
    FreeAndNil(FileStream);
  End;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.TrimedGuid(AGuid: TGuid): String;
begin
  // Trims the { and } off the ends of the Guid to pass to the server
  Result := midstr(GuidToString(AGuid),2,length(GuidToString(AGuid))-2);
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.ServerToDateTime(AInString : String) : TDateTime;
var
  Year     : word;
  Month    : word;
  Day      : word;
  Hour     : word;
  Minute   : word;
  Second   : word;
  StartStr : Integer;
  EndStr   : Integer;

  //------------------------------------------------
  Function GetNextNumber(ASearch : String) : integer;
  begin
    EndStr := Pos(ASearch, RightStr(AInString, Length(AInString) - (StartStr-1))) + StartStr-2;
    Result := StrToInt(MidStr(AInString, StartStr, EndStr-StartStr+1));
    StartStr := EndStr + 2;
  end;
begin
  Result := 0;
  StartStr := 1;

  Try
    Day   := GetNextNumber('/');
    Month := GetNextNumber('/');
    Year  := GetNextNumber(' ');
    Result := EncodeDate(Year, Month, Day);

    Hour   := GetNextNumber(':');
    Minute := GetNextNumber(':');
    Second := GetNextNumber(' ');

    if (UpperCase(MidStr(AInString, StartStr, 1)) = 'P') and
       (Hour < 12) then
      Hour := Hour + 12;

    Result := Result + EncodeTime(Hour, Minute, Second, 0);
  except
    RaiseHttpError('Cico - Error in XML Server Responce! Last Change Date Invalid.', 303);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseHttpError(AErrMessage : String;
                                        AErrCode    : integer);
begin
  logutil.LogError(UNIT_NAME, format('%s Error:<%s>',[InttoStr(AErrCode), AErrMessage] ));

  raise EWebHttpCiCoClientError.Create(AErrMessage, AErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpConnectionStatus(ASender: TObject;
                                                const AConnectionEvent: String;
                                                AStatusCode: Integer;
                                                const ADescription: String);
var
  StrMessage : String;
begin
  inherited;

  StrMessage := 'ConnectionEvent : ' + AConnectionEvent + ', ' +
                'Status Code : ' + InttoStr(AStatusCode) + ', ' +
                'Description : ' + ADescription;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpSSLServerAuthentication(ASender: TObject;
                                                       ACertEncoded: String;
                                                       const ACertSubject: String;
                                                       const ACertIssuer: String;
                                                       const AStatus: String;
                                                       var  AAccept: Boolean);
var
  StrMessage : String;
begin
  inherited;

  StrMessage := 'Cert Encoded : ' + ACertEncoded + ', ' +
                'Cert Subject : ' + ACertSubject + ', ' +
                'Cert Issuer : ' + ACertIssuer + ', ' +
                'Status : ' + AStatus;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpStartTransfer(ASender: TObject;
                                             ADirection: Integer);
var
  StrMessage : String;
begin
  inherited;

  if ADirection = 0 then
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
    fTransferFileEvent(TDirectionIndicator(ADirection), trsStartTrans, 0, fTotalBytes, fContentType);

  // Clears Server Reply
  if TDirectionIndicator(ADirection) = dirFromServer then
    fServerReply := '';
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpTransfer(ASender: TObject;
                                        ADirection: Integer;
                                        ABytesTransferred: LongInt;
                                        AText: String);
var
  StrMessage : String;
begin
  inherited;

  if ADirection = 0 then
    StrMessage := 'Transfer : from Client, ' +
                  'Bytes Transferred : ' + InttoStr(ABytesTransferred)
  else
    StrMessage := 'Transfer : from Server, ' +
                  'Bytes Transferred : ' + InttoStr(ABytesTransferred);

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

  // Transfer File Event
  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(ADirection), trsTransInProgress, ABytesTransferred, fTotalBytes, fContentType);

  // Builds Server Message
  if TDirectionIndicator(ADirection) = dirFromServer then
    fServerReply := fServerReply + AText;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpEndTransfer(ASender: TObject;
                                           ADirection: Integer);
var
  StrMessage : String;
begin
  inherited;

  if ADirection = 0 then
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
    fTransferFileEvent(TDirectionIndicator(ADirection), trsEndTrans, fTotalBytes, fTotalBytes, fContentType);

  // Handle Server Reply
  if (TDirectionIndicator(ADirection) = dirFromServer) then
    GetUpdateServerReply;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpHeader(ASender: TObject;
                                      const AField: String;
                                      const AValue: String);
var
  StrMessage : String;
begin
  Inherited;

  StrMessage := 'Header Field : ' + AField + ', ' +
                'Header Value : ' + AValue;

  // Status Event
  if Assigned(fStatusEvent) then
    fStatusEvent(StrMessage);

  if DebugMe then
    logutil.LogError(UNIT_NAME, StrMessage);

  // works out Content Length, Type and CRC from headers
  if AField = HTTP_HEAD_CONTENT_LENGTH then
    trystrtoint(AValue, fTotalBytes)
  else if AField = HTTP_HEAD_CONTENT_TYPE then
    fContentType := AValue
  else if AField = HTTP_HEAD_SERVER_FILE_CRC then
    FServerCrc := AValue;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetAdminDetails(var APracCode    : String;
                                         var APracPass    : String;
                                         var ACountryCode : String);
begin
  APracCode    := AdminSystem.fdFields.fdBankLink_Code;
  APracPass    := AdminSystem.fdFields.fdBankLink_Connect_Password;
  ACountryCode := CountryText(AdminSystem.fdFields.fdCountry);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientDetails(AClientCode      : string;
                                          var AClientEmail : string;
                                          var AClientName  : string);
var
  fClientObj : TClientObj;
begin
  fClientObj := TClientObj.Create;
  Try
    fClientObj.Open(AClientCode, FILEEXTN);
    AClientEmail := fClientObj.clFields.clClient_EMail_Address;
    AClientName  := fClientObj.clFields.clName;
  Finally
    FreeAndNil(fClientObj);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetIniDetails(var AClientEmail : string;
                                       var AClientPass  : string;
                                       var ASubDomain   : String);
begin
  // Todo Get Ini Details
  AClientEmail := INI_BankLink_Online_Username;
  AClientPass  := INI_BankLink_Online_Password;
  ASubDomain   := INI_BankLink_Online_SubDomain;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFile(AHttpAddress : string;
                                    AFileName    : string);
var
  FileCRC      : String;
  FileLength   : Integer;
begin
  if not FileExists(AFilename) then
    RaiseHttpError('Can''t open AttachedFile. (' + AFilename + ')', 302);

  FileInfo(AFilename, FileCRC, FileLength);

  // Adding Crc to Header Section
  AddHttpHeaderInfo(HTTP_HEAD_FILE_CRC,    FileCRC);
  AddHttpHeaderInfo(HTTP_HEAD_FILE_LENGTH, inttostr(FileLength));
  HttpRequester.ContentType := SERVER_CONTENT_TYPE_BK5;
  fContentType := HttpRequester.ContentType;
  fTotalBytes  := FileLength;
  AppendHttpHeaderInfo;

  HttpPostFile(AHttpAddress, AFilename);
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.GetValueFromNode(AParentNode : IXMLNode;
                                         ANodeName   : String) : String;
var
  CurrentNode : IXMLNode;
begin
  Result := '';

  CurrentNode := AParentNode.ChildNodes.FindNode(ANodeName);
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
procedure TWebCiCoClient.BuildStatusListFromXml(const ACurrentNode : IXMLNode);
var
  NewClientStatusItem : TClientStatusItem;
  LocalNode  : IXMLNode;
  StatusInt  : integer;
  StringDate : String;
begin
  LocalNode := ACurrentNode.ChildNodes.FindNode(XML_STATUS_CLIENT);

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

    LocalNode := ACurrentNode.ChildNodes.FindSibling(LocalNode, 1);
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
procedure TWebCiCoClient.GetBooksUserExists(AClientEmail        : string;
                                            AClientPassword     : string;
                                            var AServerResponce : TServerResponce);
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

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       AClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    AClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD,  '');
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,        '');
    AppendHttpHeaderInfo;

    FASyncCall := False;
    HttpSendRequest(HttpAddress);

    WaitForProcess;

    AServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.SetBooksUserPassword(AClientEmail    : string;
                                              AClientPassword : string;
                                              ANewPassword    : string;
                                              var AServerResponce : TServerResponce);
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

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       AClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    AClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_BOOKS_NEWPASSWORD,  ANewPassword);
    AppendHttpHeaderInfo;

    HttpSendRequest(HttpAddress);

    WaitForProcess;

    AServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientFileStatus(var AServerResponce   : TServerResponce;
                                             var AClientStatusList : TClientStatusList;
                                             AClientCode : string = '';
                                             AaSyncCall  : Boolean = False);
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

      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
      AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,      '');
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,   '');
    end
    else
    begin
      GetIniDetails(ClientEmail, ClientPassword, SubDomain);

      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
      AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, '');
    end;

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, AClientCode);
    AppendHttpHeaderInfo;

    FASyncCall := AaSyncCall;

    HttpSendRequest(HttpAddress);

    if not AaSyncCall then
    begin
      WaitForProcess;

      AServerResponce := fServerResponce;

      for Index := 0 to fServerClientStatusList.Count - 1 do
      begin
        NewClientStatusItem := TClientStatusItem.Create;
        NewClientStatusItem.ClientCode := fServerClientStatusList.Items[Index].ClientCode;
        NewClientStatusItem.ClientName := fServerClientStatusList.Items[Index].ClientName;
        NewClientStatusItem.StatusCode := fServerClientStatusList.Items[Index].StatusCode;
        NewClientStatusItem.LastChange := fServerClientStatusList.Items[Index].LastChange;
        AClientStatusList.Add(NewClientStatusItem);
      end;
    end;

  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromPractice(AClientCode : string;
                                                var AClientEmail    : string;
                                                var AServerResponce : TServerResponce);
var
  HttpAddress  : String;
  PracticeCode : String;
  PracticePass : String;
  CountryCode  : String;
  ClientName   : String;
begin
  fProcessState := psUploadPrac;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Upload File From Practice.');

  try
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_UPLOAD;

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);
    GetClientDetails(AClientCode, AClientEmail, ClientName);

    AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,      AClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,       AClientCode);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_NAME,       ClientName);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,   '');

    UploadFile(HttpAddress, DataDir + AClientCode + FILEEXTN);

    WaitForProcess;

    AServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToPractice(AClientCode : string;
                                                var ATempBk5File    : string;
                                                var AServerResponce : TServerResponce);
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
    ATempBk5File := '';
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);

    AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,       AClientCode);

    AppendHttpHeaderInfo;

    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    ATempBk5File := TempPath + AClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, ATempBk5File);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(ATempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    AServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromBooks(AClientCode : string;
                                             AIsCopy     : Boolean;
                                             var AServerResponce : TServerResponce);
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

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,        AClientCode);

    if AIsCopy then
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '1')
    else
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '0');

    UploadFile(HttpAddress, DataDir + AClientCode + FILEEXTN);

    WaitForProcess;

    AServerResponce := fServerResponce;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToBooks(AClientCode      : string;
                                             var ATempBk5File : string;
                                             var AServerResponce : TServerResponce);
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
    ATempBk5File := '';
    ClearHttpHeader;

    HttpAddress := URL_ADDRESS + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetIniDetails(ClientEmail, ClientPassword, SubDomain);

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,        AClientCode);
    AppendHttpHeaderInfo;

    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    ATempBk5File := TempPath + AClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, ATempBk5File);

    WaitForProcess;

    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(ATempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('Cico - File CRC Error!', 304);
    end;

    AServerResponce := fServerResponce;
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
