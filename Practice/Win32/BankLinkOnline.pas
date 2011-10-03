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

    procedure DoStatusProgress(APercentComplete : integer;
                               AMessage         : string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RefreshStatus;
    function CheckBooksUserExists(AClientEmail : string;
                                  AClientPassword : string) : Boolean;
    function UploadClient(AClientCode: string; AProgressFrm: TfrmChkProgress;
                          Silent: boolean; AClientName, AClientEmail: string; IsCopy: Boolean = False): boolean;
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
  ClientWrapper,
  WinUtils,
  progress;

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

  procedure DoStatusCheck;
  begin
    case AAction of
      oaPracticeUpload  : CheckPracticeUploadStatus(AClientCode, Status);
      oaPracticeDownload: CheckPracticeDownloadStatus(AClientCode, Status);
      oaBooksUpload     : CheckBooksUploadStatus(AClientCode, Status);
      oaBooksDownload   : CheckBooksDownLoadStatus(AClientCode, Status);
      oaBooksUploadCopy : CheckBooksUploadCopyStatus(AClientCode, Status);
    end;
  end;

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
    if Assigned(Status) then
      DoStatusCheck
    else begin
      //Create NoFile status responce
      if ServerResponce.Status = '103' then begin
        Status := TClientStatusItem.Create;
        try
          Status.ClientCode := 'AClientCode';
          Status.ClientName := '';
          Status.StatusCode := cfsNoFile;
          DoStatusCheck;
      finally
        Status.Free;
      end;
    end else
      raise EUploadFailed.CreateFmt('Unable to get client file status for %s',
                                    [AClientCode]);
    end;
  finally
    StatusList.Free;
  end;
end;

procedure TBankLinkOnlineManager.CheckBooksDownLoadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
var
  ReadOnly: Boolean;
  Msg: string;
  LocalFilename: string;
  WrapperOfExistingFile: TClientWrapper;
begin
  //Get the read only status
  LocalFileName := DATADIR + AClientCode + FILEEXTN;
  if BKFileExists(LocalFileName) then begin
    GetClientWrapper(LocalFilename, WrapperOfExistingFile, False);
    ReadOnly := WrapperOfExistingFile.wRead_Only;
  end else begin
    ReadOnly := True; //If no file exists then assume Books has not been editing it! 
  end;

  if ReadOnly then begin
    //Checked out
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('An error has occurred with client file %s on %s. ' +
                        'Please contact your accountant.', [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice: ; //OK
      cfsDownloadedBooks: ; //Check save count???
      cfsUploadedBooks: ; //OK
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
    end;
  end else begin
    //Checked in
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('An error has occurred with client file %s on %s. ' +
                        'Please contact your accountant.', [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s has been updated by your accountant. '+
                        'Would you like to overwrite the client file in BankLink Books ' +
                        'with the client file on %s?', [AClientCode, BANKLINK_ONLINE_NAME]);
          if AskYesNo('Update from ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
            raise EDownloadFailed.CreateFmt('The client file %s has been updated by your accountant.',
                                          [AClientCode]);
        end;
      cfsDownloadedBooks: ; //OK
      cfsUploadedBooks:
        begin
          Msg := Format('The client file %s on %s has already been ' +
                        'updated to BankLink Books.', [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
    end;
  end;
end;

procedure TBankLinkOnlineManager.CheckBooksUploadCopyStatus(
  AClientCode: string; AStatus: TClientStatusItem);
begin
  //Currently this is the same as Books Upload
  CheckBooksUploadStatus(AClientCode, AStatus);
end;

procedure TBankLinkOnlineManager.DoStatusProgress(APercentComplete : integer;
                                                  AMessage         : string);
begin
  UpdateAppStatus(BANKLINK_ONLINE_NAME, AMessage, APercentComplete);
end;

procedure TBankLinkOnlineManager.CheckBooksUploadStatus(AClientCode: string;
  AStatus: TClientStatusItem);
var
  ReadOnly: Boolean;
  Msg: string;
  LocalFilename: string;
  WrapperOfExistingFile: TClientWrapper;
begin
  //Get the read only status
  LocalFileName := DATADIR + AClientCode + FILEEXTN;
  if BKFileExists(LocalFileName) then begin
    GetClientWrapper(LocalFilename, WrapperOfExistingFile, False);
    ReadOnly := WrapperOfExistingFile.wRead_Only;
  end else begin
    Msg := Format('File not found %s.', [LocalFileName]);
    raise EUploadFailed.Create(Msg);
  end;

  if ReadOnly then begin
    //Checked out
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s on %s does not exist and ' +
                        'cannot be sent. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s on %s has been updated ' +
                        'by your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;
      cfsDownloadedBooks: ; //Check save count???
      cfsUploadedBooks: ; //OK
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;      
    end;
  end else begin
    //Checked in
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s on %s does not exist and ' +
                        'cannot be sent. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s on %s has been updated ' +
                        'by your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;
      cfsDownloadedBooks: ; //OK
      cfsUploadedBooks:  ; //OK
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your accountant. Please contact your accountant.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EUploadFailed.Create(Msg);
        end;
    end;
  end;
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
    ReadOnly := (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite])
  else
    ReadOnly := True; //If no file exists then assume not checked out from Practice! 

  if ReadOnly then begin
    //Checked out
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s is not available via %s.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice: ; //OK
      cfsDownloadedBooks:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your client.', [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedBooks: ; //OK
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice: ; //OK
    end;
  end else begin
    //Checked in
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s is not available via %s.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s on %s is older than the file ' +
                        'currently available. You may lose some data if you update ' +
                        'this client. Are you sure you want to continue?',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          if AskYesNo('Update from ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
            raise EDownloadFailed.CreateFmt('The client file %s on %s is older ' +
                                            'than the file currently available.',
                                            [AClientCode, BANKLINK_ONLINE_NAME]);
        end;
      cfsDownloadedBooks:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your client.', [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedBooks:
        begin
          Msg := Format('The client file %s on %s has been updated by ' +
                        'your client. Would you like to overwrite this client file ' +
                        'in BankLink Practice with the client file on %s?',
                        [AClientCode, BANKLINK_ONLINE_NAME, BANKLINK_ONLINE_NAME]);
          if AskYesNo('Update from ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
            raise EDownloadFailed.CreateFmt('The client file %s on %s '+
                                            'has been updated by your client.',
                                            [AClientCode, BANKLINK_ONLINE_NAME]);
        end;
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s has already been ' +
                        'updated to BankLink Practice.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
    else
      raise EDownloadFailed.CreateFmt('Unable to get client file status for %s',
                                      [AClientCode]);
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

  //Checked Out - Should not get here if client file read only
  CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(AClientCode);
  if Assigned(CFRec) then begin
    ReadOnly := (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite]);
    if ReadOnly then begin
      Msg := Format('Cannot check out a Read-Only file %s.', [AClientCode]);
      raise EUploadFailed.Create(Msg);
    end;
  end;

  //Checked In
  case AStatus.StatusCode of
    cfsNoFile: ; //OK to upload
    cfsUploadedPractice:
      begin
        Msg := Format('The client file %s has already been sent to %s. '+
                      'Would you like to overwrite the client file on %s '+
                      'with the version you currently have?',
                      [AClientCode, BANKLINK_ONLINE_NAME, BANKLINK_ONLINE_NAME]);
        if AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s has already been sent to %s.',
                                        [AClientCode, BANKLINK_ONLINE_NAME]);
      end;
    cfsUploadedBooks,
    cfsCopyUploadedBooks:
      begin
        Msg := Format('The client file %s on %s has been updated '+
                      'by your client. Are you sure you want to overwrite the '+
                      'client file on %s with the version you '+
                      'currently have?', [AClientCode, BANKLINK_ONLINE_NAME, BANKLINK_ONLINE_NAME]);
        if AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s on %s '+
                                        'has been updated by your client.',
                                        [AClientCode, BANKLINK_ONLINE_NAME]);

      end;
    cfsDownloadedPractice: ; //OK to upload
    cfsDownloadedBooks:
      begin
        Msg := Format('The client file %s is currently with your client. '+
                      'Sending this client file will cause your client''s '+
                      'work to be lost. Are you sure you want to continue?', [AClientCode]);
        if AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES then
          raise EUploadFailed.CreateFmt('The client file %s is currently with '+
                                        'your client on %s.',
                                        [AClientCode, BANKLINK_ONLINE_NAME]);
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
    if Assigned(AdminSystem) then
      CheckBankLinkOnlineStatus(AClientCode, oaPracticeDownload)
    else
      CheckBankLinkOnlineStatus(AClientCode, oaBooksDownload);

    //Download from BankLink Online
    if not Silent then begin
      CiCoClient.OnProgressEvent := AProgressFrm.UpdateCICOProgress;
      AProgressFrm.ProgressBar1.Max      := 100;
      AProgressFrm.ProgressBar1.Position := 0;
    end;

    try
      if Assigned(AdminSystem) then begin
        CicoClient.DownloadFileToPractice(AClientCode, ARemoteFilename, ServerResponce);
        if ServerResponce.Status = '200' then begin
          if DebugMe then begin
            AProgressFrm.mProgress.Lines.Add('Downloaded file to: ' + ARemoteFilename);
            AProgressFrm.mProgress.Lines.Add(ServerResponce.Status);
            AProgressFrm.mProgress.Lines.Add(ServerResponce.Description);
            AProgressFrm.mProgress.Lines.Add(ServerResponce.DetailedDesc);
          end;
          Result := True;
        end else begin
          raise EDownloadFailed.Create(ServerResponce.Description);
        end;
      end else begin
        CicoClient.DownloadFileToBooks(AClientCode, ARemoteFilename, ServerResponce);
      end;
    finally
      CiCoClient.OnProgressEvent := Nil;
    end;
  except
    on E: Exception do
      begin
        CiCoClient.OnProgressEvent := Nil;
        raise EDownloadFailed.Create(E.Message);
      end;
  end;
end;

function TBankLinkOnlineManager.GetStatus(AClientCode: string;
  FromWebService: boolean): TClientStatusItem;
begin
  Result := nil;
end;

procedure TBankLinkOnlineManager.DebugMsg(AMessage: string);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, AMessage);
end;

procedure TBankLinkOnlineManager.RefreshStatus;
begin

end;

function TBankLinkOnlineManager.CheckBooksUserExists(AClientEmail : string;
                                                     AClientPassword : string) : Boolean;
var
  ServerResponce : TServerResponce;
begin
  Result := false;
  try
    StatusSilent := False;
    try
      UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 0);
      CiCoClient.OnProgressEvent := DoStatusProgress;

      CiCoClient.GetBooksUserExists(AClientEmail, AClientPassword, ServerResponce);

      if (ServerResponce.Status = '200') or    //Sucessful
         (ServerResponce.Status = '107') then  //Password invalid
        Result := true;
    finally
      StatusSilent := True;
      CiCoClient.OnProgressEvent := Nil;
      ClearStatus;
    end;

  except
    on E: Exception do begin
      raise EUploadFailed.CreateFmt('Error getting %s User status: %s',
                                    [BANKLINK_ONLINE_NAME, E.Message]);
    end;
  end;
end;

function TBankLinkOnlineManager.UploadClient(AClientCode: string;
  AProgressFrm: TfrmChkProgress; Silent: boolean; AClientName, AClientEmail: string;
  IsCopy: Boolean = False): boolean;
const
  ThisMethodName = 'UploadClient';
var
  ServerResponce : TServerResponce;
begin
  DebugMsg('Begins');
  try
    //Check status
    if Assigned(AdminSystem) then
      CheckBankLinkOnlineStatus(AClientCode, oaPracticeUpload)
    else
      CheckBankLinkOnlineStatus(AClientCode, oaBooksUpload);

    //Upload to BankLink Online
    if not Silent then begin
      CiCoClient.OnProgressEvent := AProgressFrm.UpdateCICOProgress;
      AProgressFrm.ProgressBar1.Max      := 100;
      AProgressFrm.ProgressBar1.Position := 0;
    end;

    try
      try
        if Assigned(AdminSystem) then
          CiCoClient.UploadFileFromPractice(AClientCode, AClientName, AClientEmail, ServerResponce)
        else
          CiCoClient.UploadFileFromBooks(AClientCode, IsCopy, ServerResponce);
      except
        on E:Exception do
          raise EUploadFailed.Create(E.Message);
      end;
    finally
      CiCoClient.OnProgressEvent := Nil;
    end;

    if DebugMe then begin
      AProgressFrm.mProgress.Lines.Add(ServerResponce.Status);
      AProgressFrm.mProgress.Lines.Add(ServerResponce.Description);
      AProgressFrm.mProgress.Lines.Add(ServerResponce.DetailedDesc);
    end;

    Result := True;
  except
    on E: Exception do
      begin
        CiCoClient.OnProgressEvent := Nil;
        raise EUploadFailed.Create(E.Message);
      end;
  end;
  DebugMsg('Ends');
end;

initialization
  DebugMe := DebugUnit(UNIT_NAME);
end.
