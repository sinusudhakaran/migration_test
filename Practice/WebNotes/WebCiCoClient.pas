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
  stDate,
  IpsSoaps,
  Classes,
  SysUtils,
  WebClient;

{$M+}
type
  TTransferStatus = (trsStartTrans, trsTransInProgress, trsEndTrans);

  //----------------------------------------------------------------------------
  EWebCiCoClientError = class(EWebSoapClientError)
  end;

  TTransferFileEvent = procedure (Direction: Integer;
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

    procedure DoHttpConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Override;

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

    procedure GetDetailsToSend(ClientCode : string);
  public
    constructor Create; Override;

    procedure UploadFileToPractice(ClientCode : string);

    procedure DownLoadFileFromPractice(Filename : string;
                                       HttpAddress : string);

    property OnStatusEvent : TStatusEvent read fStatusEvent write fStatusEvent;
    property OnTransferFileEvent : TTransferFileEvent read fTransferFileEvent write fTransferFileEvent;
  published

  end;

  //----------------------------------------------------------------------------
  Function CiCoClient : TWebCiCoClient;

//------------------------------------------------------------------------------
implementation

uses
  progress,
  IdHashSHA1,
  IdHash,
  Base64,
  Globals,
  SyDefs,
  clObj32;

var
  fWebCiCoClient : TWebCiCoClient;

//------------------------------------------------------------------------------
function CiCoClient : TWebCiCoClient;
begin
  if not Assigned( fWebCiCoClient) then
    fWebCiCoClient := TWebCiCoClient.Create;

  result := fWebCiCoClient;
end;

{ TWebCiCoClient }
//------------------------------------------------------------------------------
procedure TWebCiCoClient.RaiseSoapError(ErrMessage: String; ErrCode: integer);
begin
  raise EWebCiCoClientError.Create(ErrMessage, ErrCode);
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
                                                        var  Accept: Boolean);
begin
  UpdateAppStatusLine2(Format('%s Authenticate %d',[Status, SoapURLIndex]));
end;

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
    fTransferFileEvent(Direction, trsStartTrans, 0, fTotalBytes);
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
                   'Bytes Transferred : ' + InttoStr(BytesTransferred) + ', ' +
                   'Text : ' + Text )
    else
      fStatusEvent('Transfer : from Server, ' +
                   'Bytes Transferred : ' + InttoStr(BytesTransferred) + ', ' +
                   'Text : ' + Text );
  end;

  if Assigned(fTransferFileEvent) then
    fTransferFileEvent(Direction, trsTransInProgress, BytesTransferred, fTotalBytes);
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
    fTransferFileEvent(Direction, trsEndTrans, fTotalBytes, fTotalBytes);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DoHttpHeader(Sender: TObject;
                                      const Field: String;
                                      const Value: String);
begin
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
constructor TWebCiCoClient.Create;
begin
  inherited;
  fTotalBytes := 0;
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.UploadFileToPractice(ClientCode : string);
var
  HttpAddress : string;
  Filename    : string;
begin
  HttpAddress := 'http://posttestserver.com/post.php';

  ClearHttpHeader;

  UploadFile(Filename, HttpAddress);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.DownLoadFileFromPractice(Filename : string;
                                                  HttpAddress : string);
begin
  HttpAddress := 'http://www.getfiddler.com/dl/Fiddler2Setup.exe';

  HttpGetFile(HttpAddress, Filename);
end;

//------------------------------------------------------------------------------
procedure TWebCiCoClient.GetDetailsToSend(ClientCode : string);
var
  ClientFileRec : pClient_File_Rec;
  FileName : String;
  BankLinkCode : String;
  Guid : TGuid;
  fClientObj : TClientObj;
begin
  ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if Assigned(ClientFileRec) then
  begin
    BankLinkCode := AdminSystem.fdFields.fdBankLink_Code;
    CreateGUID(Guid);
    FileName     := ClientFileRec^.cfFile_Name;

    fClientObj := TClientObj.Create;
    Try
      fClientObj.Open(FileName, FILEEXTN);
    Finally
      FreeAndNil(fClientObj);
    End;
  end;
end;

//------------------------------------------------------------------------------
initialization
  fWebCiCoClient := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(fWebCiCoClient);

end.
