unit WebCiCoClient;
//------------------------------------------------------------------------------
{
   Title: WebCiCoClient

   Description:

        Web Check-in Check-out Class, this handles the client Http and Soaop calls

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
  WebClient;

{$M+}
type
  TDirectionIndicator = (dirFromClient, dirFromServer);
  TTransferStatus = (trsStartTrans, trsTransInProgress, trsEndTrans);

  TClientStatusItem = class
  private
    fClientCode   : string;
    fStatus       : string;
    fUserModified : string;
    fDateModified : TDatetime;
  public
    property ClientCode    : String    read fClientCode   write fClientCode;
    property Status        : string    read fStatus       write fStatus;
    property UserModified  : string    read fUserModified write fUserModified;
    property DateModified  : TDatetime read fDateModified write fDateModified;
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
                                  TotalBytes: LongInt) of object;

  TStatusEvent = procedure (StatusMessage : string) of object;

  //----------------------------------------------------------------------------
  TWebCiCoClient = class(TWebClient)
  private
    fTotalBytes   : LongInt;
    fStatusEvent : TStatusEvent;
    fTransferFileEvent : TTransferFileEvent;

  protected
    procedure RaiseSoapError(ErrMessage : String; ErrCode : integer); override;
    procedure RaiseHttpError(ErrMessage : String; ErrCode : integer); override;

    // Soap Used Events
    procedure DoSoapConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Override;

    procedure DoSoapSSLServerAuthentication(Sender: TObject;
                                            CertEncoded: String;
                                            const CertSubject: String;
                                            const CertIssuer: String;
                                            const Status: String;
                                            var  Accept: Boolean); Override;

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

    procedure UploadFile(FileName : string;
                         HttpAddress : string);

    procedure GetPracticeDetailsToSend(ClientCode       : string;
                                       var FileName     : String;
                                       var Guid         : TGuid;
                                       var ClientEmail  : String;
                                       var PracUser     : String;
                                       var CountryCode  : String;
                                       var PracPass     : String;
                                       CreateNewGuid   : Boolean);

    procedure GetBooksDetailsToSend(ClientCode      : string;
                                    var FileName    : String;
                                    var Guid        : TGuid;
                                    var ClientEmail : string;
                                    CreateNewGuid   : Boolean);
  public
    constructor Create; Override;

    procedure SetBooksUserPassword(ClientCode  : string;
                                   OldPassword : string;
                                   NewPassword : string);

    procedure GetClientFileStatus(FromBooks : Boolean;
                                  var ClientStatusList : TClientStatusList;
                                  ClientCode : string = '');

    procedure UploadFileFromPractice(ClientCode : string);
    procedure UploadFileFromBooks(ClientCode : string);

    procedure DownloadFileToPractice(ClientCode : string);
    procedure DownloadFileToBooks(ClientCode : string);

    property OnStatusEvent : TStatusEvent read fStatusEvent write fStatusEvent;
    property OnTransferFileEvent : TTransferFileEvent read fTransferFileEvent write fTransferFileEvent;
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
  WebUtils;

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
procedure TWebCiCoClient.RaiseSoapError(ErrMessage: String; ErrCode: integer);
begin
  raise EWebSoapCiCoClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseHttpError(ErrMessage : String; ErrCode : integer);
begin
  raise EWebHttpCiCoClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoSoapConnectionStatus(Sender: TObject;
                                                 const ConnectionEvent: String;
                                                 StatusCode: Integer;
                                                 const Description: String);
begin
  UpdateAppStatusLine2(Format('%s server %d',[ConnectionEvent, SoapURLIndex]));
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoSoapSSLServerAuthentication(Sender: TObject;
                                                       CertEncoded: String;
                                                       const CertSubject: String;
                                                       const CertIssuer: String;
                                                       const Status: String;
                                                       var   Accept: Boolean);
begin
  UpdateAppStatusLine2(Format('%s Authenticate %d',[Status, SoapURLIndex]));
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpConnectionStatus(Sender: TObject;
                                                const ConnectionEvent: String;
                                                StatusCode: Integer;
                                                const Description: String);
begin
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
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('Start Transfer : from Client')
    else
      fStatusEvent('Start Transfer : from Server');
  end;

  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsStartTrans, 0, fTotalBytes);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpTransfer(Sender: TObject;
                                        Direction: Integer;
                                        BytesTransferred: LongInt;
                                        Text: String);
begin
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('Transfer : from Client, ' +
                   'Bytes Transferred : ' + InttoStr(BytesTransferred))
    else
      fStatusEvent('Transfer : from Server, ' +
                   'Bytes Transferred : ' + InttoStr(BytesTransferred));
  end;

  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsTransInProgress, BytesTransferred, fTotalBytes);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpEndTransfer(Sender: TObject;
                                           Direction: Integer);
begin
  if Assigned(fStatusEvent) then
  begin
    if Direction = 0 then
      fStatusEvent('End Transfer : from Client')
    else
      fStatusEvent('End Transfer : from Server');
  end;

  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(TDirectionIndicator(Direction), trsEndTrans, fTotalBytes, fTotalBytes);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpHeader(Sender: TObject;
                                      const Field: String;
                                      const Value: String);
begin
  Inherited;

  if Assigned(fStatusEvent) then
    fStatusEvent('Header Field : ' + Field + ', ' +
                 'Header Value : ' + Value);

  if Field = 'Content-Length' then
    trystrtoint(Value, fTotalBytes);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFile(Filename    : string;
                                    HttpAddress : string);
var
  FileStream   : TFileStream;
  FileCRC      : String;
  CrcHash      : T5x4LongWordRecord;
  IdHashSHA1   : TIdHashSHA1;
begin
  if not FileExists(Filename) then
    Exit;

  // Opening the File to Work out the SHA1 hash which is then
  // Base 64 encoded and sent as a CRC header
  FileStream := TFileStream.Create(Filename, fmOpenRead);
  Try
    IdHashSHA1 := TIdHashSHA1.Create;
    Try
      FileStream.Position := 0;
      CrcHash := IdHashSHA1.HashValue(FileStream);
      B64Encode(CrcHash, FileCRC);
    Finally
      FreeAndNil(IdHashSHA1);
    End;
  Finally
    FreeAndNil(FileStream);
  End;

  // Adding Crc to Header Section
  AddHttpHeaderInfo('CRC', FileCRC);
  AppendHttpHeaderInfo;

  HttpPostFile(HttpAddress, Filename);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetPracticeDetailsToSend(ClientCode       : string;
                                                  var FileName     : String;
                                                  var Guid         : TGuid;
                                                  var ClientEmail  : String;
                                                  var PracUser     : String;
                                                  var CountryCode  : String;
                                                  var PracPass     : String;
                                                  CreateNewGuid   : Boolean);
var
  ClientFileRec : pClient_File_Rec;
  fClientObj    : TClientObj;
begin
  ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if Assigned(ClientFileRec) then
  begin
    PracUser    := CurrUser.Code;
    PracPass    := AdminSystem.fdSystem_User_List.FindLRN(CurrUser.LRN).usPassword;
    CountryCode := CountryText(AdminSystem.fdFields.fdCountry);

    GetBooksDetailsToSend(ClientCode, FileName, Guid, ClientEmail, CreateNewGuid);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetBooksDetailsToSend(ClientCode      : string;
                                               var FileName    : String;
                                               var Guid        : TGuid;
                                               var ClientEmail : String;
                                               CreateNewGuid   : Boolean);
var
  ClientFileRec : pClient_File_Rec;
  fClientObj    : TClientObj;
begin
  ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if Assigned(ClientFileRec) then
  begin
    if CreateNewGuid then
    begin
      CreateGUID(Guid);
      ClientFileRec.cfClient_File_GUID := GuidToString(Guid);
    end
    else
      Guid := StringToGuid(ClientFileRec.cfClient_File_GUID);

    FileName   := ClientFileRec^.cfFile_Code;

    fClientObj := TClientObj.Create;
    Try
      fClientObj.Open(FileName, FILEEXTN);

      FileName := DataDir + FileName + FILEEXTN;
      ClientEmail := fClientObj.clFields.clClient_EMail_Address;

      if CreateNewGuid then
      begin
        fClientObj.clExtra.ceClient_File_GUID := GuidToString(Guid);
        fClientObj.Save;
      end;
    Finally
      FreeAndNil(fClientObj);
    End;

    if CreateNewGuid then
      AdminSystem.Save;
  end;
end;

//------------------------------------------------------------------------------
constructor TWebCiCoClient.Create;
begin
  inherited;
  fTotalBytes := 0;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.SetBooksUserPassword(ClientCode  : string;
                                              OldPassword : string;
                                              NewPassword : string);
var
  ClientEmail : String;
  FileName    : String;
  Guid        : TGuid;
  Reply       : String;
begin
  {SetSoapMethod('SetUserPassword');

  GetBooksDetailsToSend(ClientCode, FileName, Guid, ClientEmail, False);

  AppendSoapHeaderInfo;

  AddSoapStringParam('ClientEmail', ClientEmail);
  AddSoapStringParam('OldPassword', OldPassword);
  AddSoapStringParam('NewPassword', NewPassword);

  CallSoapMethod; }

  //Reply := DecodeText(SOAPRequester.ReturnValue);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetClientFileStatus(FromBooks : Boolean;
                                             var ClientStatusList : TClientStatusList;
                                             ClientCode : string = '');
var
  ClientFileRec : pClient_File_Rec;
  ClientIndex : integer;
  NewClientStatusItem : TClientStatusItem;

  //-------------------------------------
  function ReturnRandomStatus : String;
  begin
    case Random(4) of
      0 : Result := 'Not Valid';
      1 : Result := 'PracticeUpload';
      2 : Result := 'BooksDownload';
      3 : Result := 'BooksUpload';
      4 : Result := 'PracticeDownload';
    end;
  end;
begin
  if not Assigned(ClientStatusList) then
    Exit;

  Assert((FromBooks = False) or ((FromBooks = True) and (ClientCode <> '')),
         'If This is from books the Client Code should not be empty');

  if (ClientCode = '') then
  begin
    for ClientIndex := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
    begin
      NewClientStatusItem := TClientStatusItem.Create;
      NewClientStatusItem.ClientCode   := AdminSystem.fdSystem_Client_File_List.Client_File_At(ClientIndex).cfFile_Code;
      NewClientStatusItem.Status       := ReturnRandomStatus;
      NewClientStatusItem.UserModified := 'Test User';
      NewClientStatusItem.DateModified := Now;
      ClientStatusList.Add(NewClientStatusItem);
    end;
  end
  else
  begin
    NewClientStatusItem := TClientStatusItem.Create;
    NewClientStatusItem.ClientCode   := ClientCode;
    NewClientStatusItem.Status       := ReturnRandomStatus;
    NewClientStatusItem.UserModified := 'Test User';
    NewClientStatusItem.DateModified := Now;
    ClientStatusList.Add(NewClientStatusItem);
  end;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromPractice(ClientCode : string);
var
  HttpAddress : String;
  FileName    : String;
  Guid        : TGuid;
  ClientEmail : String;
  PracName    : String;
  CountryCode : String;
  PracPass    : String;
begin
  HttpAddress := 'http://posttestserver.com/post.php';

  GetPracticeDetailsToSend(ClientCode, FileName, Guid, ClientEmail, PracName,
                           CountryCode, PracPass, True);

  if not FileExists(FileName) then
    Exit;

  ClearHttpHeader;

  AddHttpHeaderInfo('ClientId',         ClientCode);
  AddHttpHeaderInfo('ClientEmail',      ClientEmail);
  AddHttpHeaderInfo('Guid',             GuidToString(Guid));
  AddHttpHeaderInfo('PracticeCode',     PracName);
  AddHttpHeaderInfo('CountryCode',      CountryCode);
  AddHttpHeaderInfo('PracticePassword', PracPass);

  UploadFile(Filename, HttpAddress);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileFromBooks(ClientCode : string);
var
  HttpAddress  : string;
  FileName     : String;
  BankLinkCode : String;
  Guid         : TGuid;
  ClientEmail  : String;
begin
  HttpAddress := 'http://posttestserver.com/post.php';

  GetBooksDetailsToSend(ClientCode, FileName, Guid, ClientEmail, True);
  ClearHttpHeader;

  AddHttpHeaderInfo('ClientId',    ClientCode);
  AddHttpHeaderInfo('ClientEmail', ClientEmail);
  AddHttpHeaderInfo('Guid',        GuidToString(Guid));

  UploadFile(Filename, HttpAddress);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToPractice(ClientCode : string);
var
  HttpAddress : string;
  FileName    : String;
begin
  HttpAddress := 'http://www.getfiddler.com/dl/Fiddler2Setup.exe';

  HttpGetFile(HttpAddress, Filename);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownloadFileToBooks(ClientCode : string);
var
  HttpAddress : string;
  FileName    : String;
begin
  HttpAddress := 'http://www.getfiddler.com/dl/Fiddler2Setup.exe';

  HttpGetFile(HttpAddress, Filename);
end;

//------------------------------------------------------------------------------
initialization
  fWebCiCoClient := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fWebCiCoClient);

end.
