unit BankLinkOnline;

interface

uses
  Forms, Dialogs, Classes, Windows, Sysutils, ChkProgressFrm, WebCiCoClient;

type
  EUploadFailed = class(Exception);
  EDownloadFailed = class(Exception);

  TOnlineAction = (oaPracticeUpload, oaPracticeDownload, oaBooksUpload,
                   oaBooksDownload, oaBooksUploadCopy);

  TBankLinkOnlineManager = class(TObject)
  private
    FClientStatusList: TClientStatusList;
    procedure DebugMsg(AMessage: string);
    procedure CheckBankLinkOnlineStatus(AClientCode: string; AAction: TOnlineAction);
    procedure CheckPracticeUploadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckPracticeDownloadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksUploadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksDownLoadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksUploadCopyStatus(AClientCode: string; AStatus: TClientStatusItem);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RefreshStatus;
    function UploadClient(AClientCode: string; AProgressFrm: TfrmChkProgress;
                          Silent: boolean; var AEmail: string): boolean;
    function DownloadClient(AClientCode: string; AProgressFrm: TfrmChkProgress;
                            var ARemoteFileName: string; Silent: boolean = False): boolean;
    function GetStatus(AClientCode: string; FromWebService: boolean): TClientStatusItem;
  end;

  function BankLinkOnlineMgr: TBankLinkOnlineManager;

implementation

uses
  Globals,
  clObj32,
  glConst,
  bkConst,
  SYDEFS,
  ErrorMoreFrm,
  CheckInOutFrm,
  LogUtil,
  YesNoDlg,
  ClientWrapper;

const
  UNIT_NAME = 'BankLinkOnline';

var
  DebugMe: boolean = false;
  __BankLinkOnlineMgr: TBankLinkOnlineManager;

function BankLinkOnlineMgr: TBankLinkOnlineManager;
begin
  if not Assigned(__BankLinkOnlineMgr) then
    __BankLinkOnlineMgr := TBankLinkOnlineManager.Create;
  Result := __BankLinkOnlineMgr;
end;

{ TBankLinkOnlineManager }

procedure TBankLinkOnlineManager.CheckBankLinkOnlineStatus(AClientCode: string;
  AAction: TOnlineAction);
var
  Msg: string;
  StatusList: TClientStatusList;
  Status: TClientStatusItem;
  ServerResponce : TServerResponce;
begin
  //Get client status from BankLink Online
  StatusList := TClientStatusList.Create;
  try
    try
      CiCoClient.GetClientFileStatus(ServerResponce, StatusList, AClientCode);
    except
      on E: Exception do begin
        //Can't get status - what do we do? Retry?
        Msg := Format('Unable to get client file status for %s: %s', [AClientCode, E.Message]);
        raise EUploadFailed.Create(Msg);
      end;
    end;

    Status := nil;
    if StatusList.Count > 0 then
      Status := StatusList.Items[0];

    if Assigned(Status) then begin
      case AAction of
        oaPracticeUpload  : CheckPracticeUploadStatus(AClientCode, Status);
        oaPracticeDownload: CheckPracticeDownloadStatus(AClientCode, Status);
        oaBooksUpload     : CheckBooksUploadStatus(AClientCode, Status);
        oaBooksDownload   : CheckBooksDownLoadStatus(AClientCode, Status);
        oaBooksUploadCopy : CheckBooksUploadCopyStatus(AClientCode, Status);
      end;
    end else
      raise EUploadFailed.CreateFmt('Unable to get client file status for %s',
                                    [AClientCode]);
  finally
    StatusList.Free;
  end;
end;

procedure TBankLinkOnlineManager.CheckBooksDownLoadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
begin

end;

procedure TBankLinkOnlineManager.CheckBooksUploadCopyStatus(
  AClientCode: string; AStatus: TClientStatusItem);
begin

end;

procedure TBankLinkOnlineManager.CheckBooksUploadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
begin

end;

procedure TBankLinkOnlineManager.CheckPracticeDownloadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
var
  CFRec : pClient_File_Rec;
  ReadOnly: Boolean;
  Msg: string;
begin
  if not Assigned(AdminSystem) then
    raise EUploadFailed.CreateFmt('No Admin database for %s', [AClientCode]);

  //Get the Client File Rec
  CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(AClientCode);
  if Assigned(CFRec) then
    ReadOnly := (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite]);

  if ReadOnly then begin
    //Checked out
  end else begin
    //Checked in
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s is not available via BankLink Online.', [AClientCode]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s on BankLink Online is older than the file ' +
                        'currently available. You may lose some data if you update ' +
                        'this client. Are you sure you want to continue?', [AClientCode]);
          if AskYesNo('Update from BankLink Online', Msg, DLG_YES, 0) <> DLG_YES then
            raise EUploadFailed.CreateFmt('The client file %s on BankLink Online is older ' +
                                          'than the file currently available.',
                                          [AClientCode]);
        end;
      cfsDownloadedBooks:
        begin
          Msg := Format('The client file %s on BankLink Online is currently with ' +
                        'your client.', [AClientCode]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedBooks:
        begin
          Msg := Format('The client file %s on BankLink Online has been updated by ' +
                        'your client. Would you like to overwrite this client file ' +
                        'in BankLink Practice with the client file on BankLink Online?',
                        [AClientCode]);
          if AskYesNo('Update from BankLink Online', Msg, DLG_YES, 0) <> DLG_YES then
            raise EUploadFailed.CreateFmt('The client file %s on BankLink Online '+
                                          'has been updated by your client.',
                                          [AClientCode]);
        end;
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on BankLink Online has already been ' +
                        'updated to BankLink Practice.', [AClientCode]);
          raise EDownloadFailed.Create(Msg);
        end;
    else
      raise EUploadFailed.CreateFmt('Unable to get client file status for %s', [AClientCode]);
    end;
  end;
end;

procedure TBankLinkOnlineManager.CheckPracticeUploadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
var
  CFRec: pClient_File_Rec;
  ReadOnly: boolean;
  Msg: string;
begin
  if not Assigned(AdminSystem) then
    raise EUploadFailed.CreateFmt('No Admin database for %s', [AClientCode]);

  //Should not get here if client file is checked out (read only)
  CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(AClientCode);
  if Assigned(CFRec) then
    ReadOnly := (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite]);
  if ReadOnly then begin
    Msg := Format('Cannot check out a Read-Only file %s.', [AClientCode]);
    raise EUploadFailed.Create(Msg);
  end;

  //Checked In
  case AStatus.StatusCode of
    cfsNoFile: ; //OK to upload
    cfsUploadedPractice:
      begin
        Msg := Format('The client file %s has already been sent to BankLink Online. '+
                      'Would you like to overwrite the client file on BankLink Online '+
                      'with the version you currently have?', [AClientCode]);
        if AskYesNo('Send to BankLink Online', Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s has already been sent to BankLink Online.',
                                        [AClientCode]);
      end;
    cfsUploadedBooks,
    cfsCopyUploadedBooks:
      begin
        Msg := Format('The client file %s on BankLink Online has been updated '+
                      'by your client. Are you sure you want to overwrite the '+
                      'client file on BankLink Online with the version you '+
                      'currently have?', [AClientCode]);
        if AskYesNo('Send to BankLink Online', Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s on BankLink Online '+
                                        'has been updated by your client.',
                                        [AClientCode]);

      end;
    cfsDownloadedPractice: ; //OK to upload
    cfsDownloadedBooks:
      begin
        Msg := Format('The client file %s is currently with your client. '+
                      'Sending this client file will cause your client''s '+
                      'work to be lost. Are you sure you want to continue?', [AClientCode]);
        if AskYesNo('Send to BankLink Online', Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s is currently with '+
                                        'your client on BankLink Online.',
                                        [AClientCode]);
      end;
  else
    raise EUploadFailed.CreateFmt('Unable to get client file status for %s', [AClientCode]);
  end;
end;

constructor TBankLinkOnlineManager.Create;
begin
  inherited;

  FClientStatusList := TClientStatusList.Create;
end;

destructor TBankLinkOnlineManager.Destroy;
begin
  FClientStatusList.Free;

  inherited;
end;

function TBankLinkOnlineManager.DownloadClient(AClientCode: string;
  AProgressFrm: TfrmChkProgress; var ARemoteFileName: string;
  Silent: boolean = False): boolean;
var
 ServerResponce: TServerResponce;
begin
  Result := False;
  try
    CheckBankLinkOnlineStatus(AClientCode, oaPracticeDownload);

    //Download from BankLink Online
    if Silent then begin
      CiCoClient.OnStatusEvent := AProgressFrm.UpdateStatus;
      CiCoClient.OnTransferFileEvent := AProgressFrm.UpdateCICOProgress;
    end;

    if Assigned(AdminSystem) then begin
      CicoClient.DownloadFileToPractice(AClientCode, ARemoteFilename, ServerResponce);
      AProgressFrm.mProgress.Lines.Add('Downloaded file to: ' + ARemoteFilename);
      AProgressFrm.mProgress.Lines.Add(ServerResponce.Status);
      AProgressFrm.mProgress.Lines.Add(ServerResponce.Description);
      AProgressFrm.mProgress.Lines.Add(ServerResponce.DetailedDesc);
      Result := True;      
    end;
  except
    on E: Exception do
      begin
        raise EDownloadFailed.Create(E.Message);
      end;
  end;
end;

function TBankLinkOnlineManager.GetStatus(AClientCode: string;
  FromWebService: boolean): TClientStatusItem;
begin

end;

procedure TBankLinkOnlineManager.DebugMsg(AMessage: string);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, AMessage);
end;

procedure TBankLinkOnlineManager.RefreshStatus;
begin

end;

function TBankLinkOnlineManager.UploadClient(AClientCode: string;
  AProgressFrm: TfrmChkProgress; Silent: boolean; var AEmail: string): boolean;
const
  ThisMethodName = 'UploadClient';
var
  ClientFileRec: pClient_File_Rec;
  ServerResponce : TServerResponce;
begin
  DebugMsg('Begins');

  //Check status
  CheckBankLinkOnlineStatus(AClientCode, oaPracticeUpload);

  //Upload to BankLink Online
  if Silent then begin
    CiCoClient.OnStatusEvent := AProgressFrm.UpdateStatus;
    CiCoClient.OnTransferFileEvent := AProgressFrm.UpdateCICOProgress;
  end;

  if Assigned(AdminSystem) then begin
    CiCoClient.UploadFileFromPractice(AClientCode, AEmail, ServerResponce);
    AProgressFrm.mProgress.Lines.Add(ServerResponce.Status);
    AProgressFrm.mProgress.Lines.Add(ServerResponce.Description);
    AProgressFrm.mProgress.Lines.Add(ServerResponce.DetailedDesc);
  end else
    CiCoClient.UploadFileFromBooks(AClientCode, ServerResponce);

  DebugMsg('Ends');
end;

initialization
  DebugMe := DebugUnit(UNIT_NAME);
end.
