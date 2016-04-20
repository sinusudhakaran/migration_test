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
  EncdDecd,
  CodingStatsList32,
  BKDateUtils;

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
                   psDownloadPrac,
                   psGetBookUserExists);

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
    procedure Clear; override;
    property Items[Index : Integer]: TClientStatusItem read Get write Put; default;
  end;

  //----------------------------------------------------------------------------
  EWebSoapCiCoClientError = class(EWebSoapClientError)
  end;

  EWebHttpCiCoClientError = class(EWebHttpClientError)
  end;

  //----------------------------------------------------------------------------
  TServerResponse = record
    Status       : String;
    Description  : String;
    DetailedDesc : String;
    ContentType  : String;
    ServerReply  : String;
  end;

  TByteArr20 = Array[0..19] of Byte;

  //----------------------------------------------------------------------------
  TTransferFileEvent = procedure (Direction        : TDirectionIndicator;
                                  TransferStatus   : TTransferStatus;
                                  BytesTransferred : LongInt;
                                  TotalBytes       : LongInt;
                                  ContentType      : String) of object;

  TStatusEvent = procedure (StatusMessage : string) of object;

  TServerStatusEvent = procedure (ServerResponce   : TServerResponse;
                                  ClientStatusList : TClientStatusList) of object;

  TProgressEvent = procedure (APercentComplete : integer;
                              AMessage         : string) of object;

  //----------------------------------------------------------------------------
  TWebCiCoClient = class(TWebClient)
  private
    fStatusEvent       : TStatusEvent;
    fTransferFileEvent : TTransferFileEvent;
    fServerStatusEvent : TServerStatusEvent;
    fProgressEvent     : TProgressEvent;

    fTotalBytes       : LongInt;
    fIsBooks          : Boolean;
    fServerReply      : string;
    fContentType      : string;
    FServerCrc        : string;
    fProcessState     : TProcessState;

    fServerResponce : TServerResponse;
    fServerClientStatusList : TClientStatusList;

    FASyncCall : Boolean;
    procedure FileInfo(AFilename     : String;
                       var AFileCRC  : String;
                       var AFileSize : Integer);
    function TrimedGuid(AGuid : TGuid): String;
    function ServerToDateTime(AInString : String) : TDateTime;
    function GetProgressPercent(aProgressValue : integer) : integer;
  protected
    procedure RaiseHttpError(AErrMessage : String;
                             AErrCode    : integer); override;

    // Http Used Events
    procedure DoHttpConnected(Sender     : TObject;
                              StatusCode : Integer;
                              const Description : String); Override;
    procedure DoHttpDisconnected(Sender     : TObject;
                                 StatusCode : Integer;
                                 const Description : String); Override;
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
    procedure GetIniDetails(var AClientEmail : string;
                            var AClientPass  : string;
                            var ASubDomain   : String);

    // Generic Upload File
    procedure UploadFile(AHttpAddress : string;
                         AFileName    : string);

    // Server Response Handling
    function GetValueFromNode(AParentNode : IXMLNode;
                              ANodeName   : String) : String;
    procedure GetUpdateServerReply;
    procedure GetDetailsFromXML;
    procedure BuildStatusListFromXml(const ACurrentNode : IXMLNode);

    procedure WaitForProcess;
    function GetHttpAddress : String;
  public
    constructor Create; Override;
    destructor Destroy; Override;

    procedure GetBooksUserExists(AClientEmail    : string;
                                 AClientPassword : string;
                                 var AServerResponce : TServerResponse);
    procedure SetBooksUserPassword(AClientEmail    : string;
                                   AClientPassword : string;
                                   ANewPassword    : string;
                                   var AServerResponce : TServerResponse);
    procedure GetClientFileStatus(var AServerResponce   : TServerResponse;
                                  var AClientStatusList : TClientStatusList;
                                  AClientCode : string = '';
                                  AaSyncCall  : Boolean = False);
    procedure UploadFileFromPractice(AClientCode : string;
                                     AClientName, AClientEmail, AClientContact : string;
                                     var AServerResponce : TServerResponse);
    procedure DownloadFileToPractice(AClientCode : string;
                                     var ATempBk5File    : string;
                                     var AServerResponce : TServerResponse);
    procedure UploadFileFromBooks(AClientCode : string;
                                  AIsCopy     : Boolean;
                                  ANotifyPractice     : Boolean;
                                  ANotifyEMail: string;                                  
                                  var AServerResponce : TServerResponse);
    procedure DownloadFileToBooks(AClientCode : string;
                                  var ATempBk5File    : string;
                                  var AServerResponce : TServerResponse);

    property OnStatusEvent       : TStatusEvent       read fStatusEvent       write fStatusEvent;
    property OnTransferFileEvent : TTransferFileEvent read fTransferFileEvent write fTransferFileEvent;
    property OnServerStatusEvent : TServerStatusEvent read fServerStatusEvent write fServerStatusEvent;
    property OnProgressEvent     : TProgressEvent     read fProgressEvent     write fProgressEvent;
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
  Globals,
  SyDefs,
  ClObj32,
  WebUtils,
  StrUtils,
  Windows,
  LogUtil,
  CSDEFS,
  UsageUtils,
  INIsettings,
  BankLinkOnlineServices,
  bkBranding;

const
  // XML Server packet Names
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

  // Http headers been passed to and from the server
  HTTP_HEAD_PRACTICE_CODE      = 'PracticeCode';
  HTTP_HEAD_PRACTICE_PASSWORD  = 'PracticePassword';
  HTTP_HEAD_PRACTICE_SUBDOMAIN = 'PracticeDomain';
  HTTP_HEAD_CLIENT_CODE        = 'ClientCode';
  HTTP_HEAD_CLIENT_EMAIL       = 'ClientEmail';
  HTTP_HEAD_CLIENT_PASSWORD    = 'ClientPassword';
  HTTP_HEAD_CLIENT_NAME        = 'ClientName';
  HTTP_HEAD_CLIENT_CONTACT     = 'ClientContactName';
  HTTP_HEAD_COUNTRY_CODE       = 'CountryCode';
  HTTP_HEAD_BOOKS_COPY         = 'Copy';
  HTTP_HEAD_BOOKS_NEWPASSWORD  = 'NewPassword';
  HTTP_HEAD_FILE_CRC           = 'FileCRC';
  HTTP_HEAD_FILE_LENGTH        = 'FileLength';
  HTTP_HEAD_CONTENT_LENGTH     = 'Content-Length';
  HTTP_HEAD_CONTENT_TYPE       = 'Content-Type';
  HTTP_HEAD_SERVER_FILE_CRC    = 'CRC';
  HTTP_HEAD_NOTIFY_PRACTICE    = 'NotifyPractice';
  HTTP_HEAD_NOTIFY_EMAIL       = 'NotifyEMailAddress';

  // Content Type of the data passed to and from the server
  SERVER_CONTENT_TYPE_XML = '.xml; charset=utf-8';
  SERVER_CONTENT_TYPE_BK5 = '.bk5';
  SERVER_STATUS_XML_DESC  = 'Status Data';

  // Values used to build the Full URL address to call for each command
  PRODUCT_URL_NAME               = '/cico';
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
    cfsNoFile             : Result := '';
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
procedure TClientStatusList.Clear;
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

destructor TClientStatusList.Destroy;
begin
  Clear;

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
const
  SHA_STR_SIZE = 20;
var
  CrcHash    : T5x4LongWordRecord;
  IdHashSHA1 : TIdHashSHA1;
  FileStream : TFileStream;
  Sha1String : String[SHA_STR_SIZE];
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
      for Index := 0 to SHA_STR_SIZE-1 do
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
Const
  DATE_DELIMETER = '/';
  TIME_DELIMETER = ':';
  END_DELIMETER  = ' ';
  PM_START_CHAR  = 'P';
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
    // Searchs from the Current position for the ASearch string once found it converts the
    // charcters from the start to the one before the ASearch string into a number an returns it.
    EndStr := Pos(ASearch, RightStr(AInString, Length(AInString) - (StartStr-1))) + StartStr-2;
    Result := StrToInt(MidStr(AInString, StartStr, EndStr-StartStr+1));
    StartStr := EndStr + 2;
  end;
begin
  Result := 0;
  StartStr := 1;

  Try
    // Date Encoding
    Day   := GetNextNumber(DATE_DELIMETER);
    Month := GetNextNumber(DATE_DELIMETER);
    Year  := GetNextNumber(END_DELIMETER);
    Result := EncodeDate(Year, Month, Day);

    // Time Encoding
    Hour   := GetNextNumber(TIME_DELIMETER);
    Minute := GetNextNumber(TIME_DELIMETER);
    Second := GetNextNumber(END_DELIMETER);
    if (UpperCase(MidStr(AInString, StartStr, 1)) = PM_START_CHAR) and
       (Hour < 12) then
      Hour := Hour + 12;
    Result := Result + EncodeTime(Hour, Minute, Second, 0);
  except
    RaiseHttpError('Error in XML Server Response. Last Change Date Invalid.', 303);
  End;
end;

//------------------------------------------------------------------------------
function TWebCiCoClient.GetProgressPercent(aProgressValue : integer) : integer;
begin
  // This adjusts the percentage progress depending on what the call is doing.
  // Example : for an upload it will adjust the first part to be larger.
  if fProcessState in [psChangePass, psGetStatus, psGetBookUserExists] then
    Result := aProgressValue
  else if fProcessState in [psUploadBooks, psUploadPrac] then
  begin
    if aProgressValue <= 50 then
      Result := trunc(aProgressValue * 1.5)
    else
      Result := trunc(aProgressValue * 0.5) + 50;
  end
  else
  begin
    if aProgressValue <= 50 then
      Result := trunc(aProgressValue * 0.5)
    else
      Result := trunc(aProgressValue * 1.5) - 50;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseHttpError(AErrMessage : String;
                                        AErrCode    : integer);
begin
  logutil.LogError(UNIT_NAME, format('%s Error:<%s>',[InttoStr(AErrCode), AErrMessage] ));

  raise EWebHttpCiCoClientError.Create('Unable to connect to ' + bkBranding.ProductOnlineName + '. (' + inttostr(AErrCode) + ')', AErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpConnected(Sender     : TObject;
                                         StatusCode : Integer;
                                         const Description : String);
begin
  inherited;

  if Assigned(fProgressEvent) then
    fProgressEvent(5, 'Connected to ' + bkBranding.ProductOnlineName);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpDisconnected(Sender     : TObject;
                                            StatusCode : Integer;
                                            const Description : String);
begin
  inherited;

  if Assigned(fProgressEvent) then
    fProgressEvent(100, bkBranding.ProductOnlineName + ' Connection Completed');
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
    StrMessage := 'Start Transfer : to ' + bkBranding.ProductOnlineName
  else
    StrMessage := 'Start Transfer : from ' + bkBranding.ProductOnlineName;

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

  // Progress Event
  if Assigned(fProgressEvent) then
    fProgressEvent(GetProgressPercent((ADirection * 45) + 10), StrMessage);
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
    StrMessage := 'Transfering : to ' + bkBranding.ProductOnlineName
  else
    StrMessage := 'Transfering : from ' + bkBranding.ProductOnlineName;

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

  // Progress Event
  if Assigned(fProgressEvent) then
    fProgressEvent(GetProgressPercent((ADirection*45) + trunc((ABytesTransferred/fTotalBytes) * 35) + 10), StrMessage);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpEndTransfer(ASender: TObject;
                                           ADirection: Integer);
var
  StrMessage : String;
begin
  inherited;

  if ADirection = 0 then
    StrMessage := 'End Transfer : to ' + bkBranding.ProductOnlineName
  else
    StrMessage := 'End Transfer : from ' + bkBranding.ProductOnlineName;

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

  // Progress Event
  if Assigned(fProgressEvent) then
    fProgressEvent(GetProgressPercent((ADirection*45) + 45), StrMessage);
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
procedure TWebCiCoClient.GetIniDetails(var AClientEmail : string;
                                       var AClientPass  : string;
                                       var ASubDomain   : String);
begin
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

  // Adding Crc, file length and Content Type to Header Section
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

  // Try's to finds the Child XML Node, is sucessful if assigned and the variant
  // returned is a string.
  CurrentNode := AParentNode.ChildNodes.FindNode(ANodeName);
  if (Assigned(CurrentNode)) and
     (TVarData(CurrentNode.NodeValue).Vtype = varOleStr) then
    Result := CurrentNode.NodeValue;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetUpdateServerReply;
begin
  Try
    Try
      fServerResponce.Status       := '';
      fServerResponce.Description  := '';
      fServerResponce.DetailedDesc := '';
      fServerResponce.ContentType  := fContentType;
      fServerResponce.ServerReply  := fServerReply;

      fServerClientStatusList.Clear;

      if fContentType = SERVER_CONTENT_TYPE_XML then
        GetDetailsFromXML
      else if fContentType = SERVER_CONTENT_TYPE_BK5 then
      begin
        fServerResponce.Status       := '200';
        fServerResponce.Description  := 'File Downloaded';
        fServerResponce.DetailedDesc := 'BK5 File Downloaded';
      end
      else
      begin
        fServerResponce.Status       := '500';
        fServerResponce.Description  := 'Internal Server Error';
        fServerResponce.DetailedDesc := 'Unexpected content type';
        RaiseHttpError('Internal Server Error', 500);
      end;
    Except
      on E : EWebHttpCiCoClientError do
      begin
        fServerResponce.Status       := InttoStr(E.ErrorCode);
        fServerResponce.Description  := 'Server Response Error';
        fServerResponce.DetailedDesc := trim(E.Message);
        fServerClientStatusList.Clear;

        if (Assigned(fServerStatusEvent)) and
          (fASyncCall) then
          fServerStatusEvent(fServerResponce, fServerClientStatusList);
      end;
    End;
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
  // Looks for the XML header value
  if pos('<' + XML_STATUS_HEADNAME + '>', fServerReply) = 0 then
    RaiseHttpError('Error in XML Server Response.', 303);

  XMLDoc := MakeXMLDoc(fServerReply);
  try
    CurrentNode := XMLDoc.DocumentElement;
    if CurrentNode.NodeName <> XML_STATUS_HEADNAME then
      RaiseHttpError('Error in XML Server Response.', 303);

    if XMLDoc.DocumentElement.ChildNodes.Count = 0 then
      RaiseHttpError('Error in XML Server Response.', 303);

    // Fills the server response
    fServerResponce.Status       := GetValueFromNode(CurrentNode, XML_STATUS_CODE);
    fServerResponce.Description  := GetValueFromNode(CurrentNode, XML_STATUS_DESC);
    fServerResponce.DetailedDesc := GetValueFromNode(CurrentNode, XML_STATUS_DETAIL_DESC);

    // try's to build the extra status section if call is a status call
    if (fServerResponce.Description = SERVER_STATUS_XML_DESC) and
       (trim(fServerResponce.DetailedDesc) <> '') then
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
function TWebCiCoClient.GetHttpAddress: String;
begin
  //Builds a differant URL address depending if from books or not
  if fIsBooks then
    Result := PRACINI_BankLink_Online_Books_URL + PRODUCT_URL_NAME
  else
  begin
    if (Globals.PRACINI_OnlineLink = '') then
    begin
      Globals.PRACINI_OnlineLink := ProductConfigService.BankLinkOnlinePracticeURL;
      WritePracticeINI_WithLock;
    end;

    Result := Globals.PRACINI_OnlineLink + PRODUCT_URL_NAME;
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
  // Looks for first node, if node not found there is no Extra xml section so continue
  // as normal
  LocalNode := ACurrentNode.ChildNodes.FindNode(XML_STATUS_CLIENT);

  if Not Assigned(LocalNode) then
    RaiseHttpError('Error in XML Server Response. No Status List.', 303);

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
        RaiseHttpError('Error in XML Server Response. Status Code Invalid.', 303);
    end
    else
      RaiseHttpError('Error in XML Server Response. Status Code Invalid.', 303);

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
  // all working times are in milliseconds
  TimeOut   := (HttpRequester.Timeout * 1000);
  StartTick := GetTickCount;
  while (fProcessState <> psNothing) do
  begin
    HttpRequester.DoEvents;

    if ((GetTickCount - StartTick) >= TimeOut ) then
      RaiseHttpError('Operation timeout.', 301);
  end;
end;

//------------------------------------------------------------------------------
constructor TWebCiCoClient.Create;
begin
  inherited;
  fTotalBytes := 0;
  fIsBooks := not Assigned(Globals.AdminSystem);

  fServerReply := '';
  fContentType := '';
  fProcessState := psNothing;

  fServerClientStatusList := TClientStatusList.Create;
end;

//------------------------------------------------------------------------------
destructor TWebCiCoClient.Destroy;
begin
  fServerClientStatusList.Clear;
  FreeAndNil(fServerClientStatusList);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetBooksUserExists(AClientEmail        : string;
                                            AClientPassword     : string;
                                            var AServerResponce : TServerResponse);
var
  HttpAddress    : String;
  BooksEmail     : String;
  BooksPassword  : String;
  SubDomain      : String;
begin
  if not fIsBooks then
    Exit;

  fProcessState := psGetBookUserExists;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Books User Exists.');

  try
    ClearHttpHeader;

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_GET_STATUS;

    GetIniDetails(BooksEmail, BooksPassword, SubDomain);

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       AClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    AClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD,  '');

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
                                              var AServerResponce : TServerResponse);
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

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_PASS_CHANGE;

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
// if AaSyncCall is not set the method will work like all the other service call
// and only exit once done. If set to true it will call the server and exit and
// you will need to use the Server Status call back event to get the response
procedure TWebCiCoClient.GetClientFileStatus(var AServerResponce   : TServerResponse;
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

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_GET_STATUS;

    if not fIsBooks then
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
      AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD,  '');
    end;

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE, AClientCode);
    AppendHttpHeaderInfo;

    FASyncCall := AaSyncCall;

    HttpSendRequest(HttpAddress);

    // if AaSyncCall then it does not get the response here and the Server Status
    // call back will need to be used
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

    //Clear it here as well so we don't have data hanging around until next time we run this.
    ClearHttpHeader;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromPractice(AClientCode : string;
                                                AClientName, AClientEmail, AClientContact : string;
                                                var AServerResponce : TServerResponse);
var
  HttpAddress  : String;
  PracticeCode : String;
  PracticePass : String;
  CountryCode  : String;
  PS: pCoding_Statistics_Rec;
  lMonth: TstDate;
  lPractice: TSystem_Coding_Statistics;
begin
  fProcessState := psUploadPrac;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Upload File From Practice.');

  try
    ClearHttpHeader;

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_UPLOAD;

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);

    // Can't do upload without email address. Should raise an exception (but not http except?)
    if Trim(AClientEmail) = '' then
      RaiseHttpError('No email address', 302);

    AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,      AClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,       AClientCode);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_NAME,       AClientName);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CONTACT,    AClientContact);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,   '');

    UploadFile(HttpAddress, DataDir + AClientCode + FILEEXTN);

    WaitForProcess;

    AServerResponce := fServerResponce;
    
    //Clear it here as well so we don't have data hanging around until next time we run this.
    ClearHttpHeader;

    // Increasing stat for 'total number of client files sent'
    lPractice := CodingStatsList32.CodingStatsManager.GetPracticeStats;
    try
      lMonth := GetFirstDayOfMonth(CurrentDate);
      PS := lPractice.FindClientMonth(PracticeLRN, lMonth);
      if (PS = nil) then
        PS := lPractice.Insert(PracticeLRN, lMonth);
      inc(PS.csClient_Files_Sent);
      IncUsage('Client Files Sent');
    finally
      lPractice.Free;
    end;
  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToPractice(AClientCode : string;
                                                var ATempBk5File    : string;
                                                var AServerResponce : TServerResponse);
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
  PS: pCoding_Statistics_Rec;
  lMonth: TstDate;
  lPractice: TSystem_Coding_Statistics;
begin
  fProcessState := psDownloadPrac;

  if DebugMe then
    logutil.LogError(UNIT_NAME, 'Called Download File To Practice.');

  try
    ATempBk5File := '';
    ClearHttpHeader;

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetAdminDetails(PracticeCode, PracticePass, CountryCode);

    AddHttpHeaderInfo(HTTP_HEAD_COUNTRY_CODE,      CountryCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_CODE,     PracticeCode);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_PASSWORD, PracticePass);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,       AClientCode);

    AppendHttpHeaderInfo;

    // Get a system Temp path and uses a guid to create a unique file and then
    // downloads to this file.
    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    ATempBk5File := TempPath + AClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, ATempBk5File);

    WaitForProcess;

    // Checks if the Crc is correct for the downloaded file.
    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(ATempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('File CRC Error.', 304);
    end;

    AServerResponce := fServerResponce;

    // Increasing stat for 'total number of client files received'
    lPractice := CodingStatsList32.CodingStatsManager.GetPracticeStats;
    try
      lMonth := GetFirstDayOfMonth(CurrentDate);
      PS := lPractice.FindClientMonth(PracticeLRN, lMonth);
      if (PS = nil) then
        PS := lPractice.Insert(PracticeLRN, lMonth);
      inc(PS.csClient_Files_Received);
      IncUsage('Client Files Received');
    finally
      lPractice.Free;
    end;

  finally
    fProcessState := psNothing;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromBooks(AClientCode : string;
                                             AIsCopy     : Boolean;
                                             ANotifyPractice: Boolean;
                                             ANotifyEMail: string;
                                             var AServerResponce : TServerResponse);
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

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_UPLOAD;

    GetIniDetails(ClientEmail, ClientPassword, SubDomain);

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,        AClientCode);

    if AIsCopy then
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '1')
    else
      AddHttpHeaderInfo(HTTP_HEAD_BOOKS_COPY, '0');

    if ANotifyPractice then begin
      AddHttpHeaderInfo(HTTP_HEAD_NOTIFY_PRACTICE,    '1');
      AddHttpHeaderInfo(HTTP_HEAD_NOTIFY_EMAIL, ANotifyEMail);
    end else
      AddHttpHeaderInfo(HTTP_HEAD_NOTIFY_PRACTICE,    '0');

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
                                             var AServerResponce : TServerResponse);
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

    HttpAddress := GetHttpAddress + URL_SERVICE_ACTION_DONWNLOAD;

    CreateGuid(Guid);
    StrGuid := TrimedGuid(Guid);

    GetIniDetails(ClientEmail, ClientPassword, SubDomain);

    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_EMAIL,       ClientEmail);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_PASSWORD,    ClientPassword);
    AddHttpHeaderInfo(HTTP_HEAD_PRACTICE_SUBDOMAIN, SubDomain);
    AddHttpHeaderInfo(HTTP_HEAD_CLIENT_CODE,        AClientCode);
    AppendHttpHeaderInfo;

    // Get a system Temp path and uses a guid to create a unique file and then
    // downloads to this file.
    SetLength(TempPath,Max_Path);
    SetLength(TempPath,GetTempPath(Max_Path,Pchar(TempPath)));

    ATempBk5File := TempPath + AClientCode + '(' + StrGuid + ')' + FILEEXTN;
    HttpGetFile(HttpAddress, ATempBk5File);

    WaitForProcess;

    // Checks if the Crc is correct for the downloaded file.
    if fContentType = SERVER_CONTENT_TYPE_BK5 then
    begin
      FileInfo(ATempBk5File, FileCrc, FileSize);
      if FServerCrc <> FileCrc then
        RaiseHttpError('File CRC Error.', 304);
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

