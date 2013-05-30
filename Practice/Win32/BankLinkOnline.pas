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
    FSilent : Boolean;

    function GetBankLinkOnlineErrorString(Response: TServerResponse; ForClient: Boolean): String;

    procedure DebugMsg(AMessage: string);
    procedure CheckBankLinkOnlineStatus(AClientCode: string; AAction: TOnlineAction; var AFirstUpload : Boolean);
    procedure CheckPracticeUploadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckPracticeDownloadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksUploadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksDownLoadStatus(AClientCode: string; AStatus: TClientStatusItem);
    procedure CheckBooksUploadCopyStatus(AClientCode: string; AStatus: TClientStatusItem);
  public
    constructor Create;
    destructor Destroy; override;
    function UploadClient(AClientCode: string; AProgressFrm: TfrmChkProgress;
                          AClientName, AClientEmail, AClientContact: string; var AFirstUpload : Boolean;
                          IsCopy: Boolean = False;
                          NotifyPractice: Boolean = False; NotifyEmail: string = ''): boolean;
    function DownloadClient(AClientCode: string; AProgressFrm: TfrmChkProgress;
                            var ARemoteFileName: string): boolean;

    property Silent : Boolean read FSilent write FSilent;
  end;

const
  CICOERRORSTR_CLIENT_CLIENTDEACTIVATED = 'This client file is currently de-activated or suspended so you will not be able to transfer files via BankLink Online. Please contact your accountant for assistance.';
  CICOERRORSTR_PRACTICE_CLIENTDEACTIVATED = 'This client file is currently de-activated or suspended so you will not be able to transfer files via BankLink Online.';


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
  progress,
  RegExprUtils,
  BankLinkOnlineServices,
  bkBranding, bkProduct;

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
                                                           AAction: TOnlineAction;
                                                           var AFirstUpload : Boolean);
var
  Msg: string;
  StatusList: TClientStatusList;
  Status: TClientStatusItem;
  ServerResponce : TServerResponse;

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
  AFirstUpload := false;
  //Get client status from BankLink Online
  StatusList := TClientStatusList.Create;
  try

    try
      CiCoClient.GetClientFileStatus(ServerResponce, StatusList, AClientCode);
    except
      on E: Exception do
      begin
        //Can't get status - what do we do? Retry?
        Msg := Format('Unable to get client file status for %s: %s', [AClientCode, E.Message]);
        raise EUploadFailed.Create(Msg);
      end;
    end;

    Status := nil;
    if StatusList.Count > 0 then
      Status := StatusList.Items[0];

    if Assigned(Status) then
    begin
      DoStatusCheck;
      AFirstUpload := (Status.StatusCode = cfsNoFile);
    end
    else
    begin
      //Create NoFile status responce
      if ServerResponce.Status = '105' then
      begin
        Status := TClientStatusItem.Create;
        try
          Status.ClientCode := 'AClientCode';
          Status.ClientName := '';
          Status.StatusCode := cfsNoFile;
          AFirstUpload := true;
          DoStatusCheck;
        finally
          Status.Free;
        end;
      end
      else
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
    //Send
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
    //Update
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
                        'Would you like to overwrite the client file in %s ' +
                        'with the client file on %s?', [AClientCode, bkBranding.BooksProductName, bkBranding.ProductOnlineName]);

          if (Silent) or (AskYesNo('Update from ' + bkBranding.ProductOnlineName, Msg, DLG_YES, 0) <> DLG_YES) then
            raise EDownloadFailed.CreateFmt('The client file %s has been updated by your accountant.',
                                          [AClientCode]);
        end;
      cfsDownloadedBooks: ; //OK
      cfsUploadedBooks:
        begin
          Msg := Format('The client file %s on %s has already been ' +
                        'updated to %s.', [AClientCode, bkBranding.ProductOnlineName, bkBranding.BooksProductName]);
                        
          raise EDownloadFailed.Create(Msg);
        end;
      cfsCopyUploadedBooks: ; //OK
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s is currently with ' +
                        'your accountant. Please contact your accountant.',
                        [AClientCode, bkBranding.ProductOnlineName]);
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
    //Send
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
    //Update
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
    ReadOnly := True; //If no file exists then assume not read-only in Practice! 

  if ReadOnly then begin
    //Sent
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
      cfsUploadedBooks: ;      //OK
      cfsCopyUploadedBooks: ;  //OK
      cfsDownloadedPractice: ; //OK
    end;
  end else begin
    //Updated
    case AStatus.StatusCode of
      cfsNoFile:
        begin
          Msg := Format('The client file %s is not available via %s.',
                        [AClientCode, bkBranding.ProductOnlineName]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsUploadedPractice:
        begin
          Msg := Format('The client file %s on %s is older than the file ' +
                        'currently available. You may lose some data if you update ' +
                        'this client. Are you sure you want to continue?',
                        [AClientCode, bkBranding.ProductOnlineName]);
                        
          if (Silent) or (AskYesNo('Update from ' + bkBranding.ProductOnlineName, Msg, DLG_YES, 0) <> DLG_YES) then
            raise EDownloadFailed.CreateFmt('The client file %s on %s is older ' +
                                            'than the file currently available.',
                                            [AClientCode, bkBranding.ProductOnlineName]);
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
                        'your client. Would you like to overwrite the client file ' +
                        'in %s with the client file from %s?',
                        [AClientCode, bkBranding.ProductOnlineName, bkBranding.PracticeProductName, bkBranding.ProductOnlineName]);
                        
          if (Silent) or (AskYesNo('Update from ' + bkBranding.ProductOnlineName, Msg, DLG_YES, 0) <> DLG_YES) then
            raise EDownloadFailed.CreateFmt('The client file %s on %s '+
                                            'has been updated by your client.',
                                            [AClientCode, bkBranding.ProductOnlineName]);
        end;
      cfsDownloadedPractice:
        begin
          Msg := Format('The client file %s on %s has already been ' +
                        'updated to ' + bkBranding.PracticeProductName + '.',
                        [AClientCode, BANKLINK_ONLINE_NAME]);
          raise EDownloadFailed.Create(Msg);
        end;
      cfsCopyUploadedBooks: ;//  
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

  //Read-only - Should not get here if client file read only
  CFRec := AdminSystem.fdSystem_Client_File_List.FindCode(AClientCode);
  if Assigned(CFRec) then begin
    ReadOnly := (CFRec.cfFile_Status in [fsCheckedOut, fsOffsite]);
    if ReadOnly then begin
      Msg := Format('Cannot send a Read-only file %s.', [AClientCode]);
      raise EUploadFailed.Create(Msg);
    end;
  end;

  //Updated
  case AStatus.StatusCode of
    cfsNoFile: ; //OK to upload
    cfsUploadedPractice:
      begin
        Msg := Format('The client file %s has already been sent to %s. '+
                      'Would you like to overwrite the client file on %s '+
                      'with the version you currently have?',
                      [AClientCode, BANKLINK_ONLINE_NAME, BANKLINK_ONLINE_NAME]);
        if (Silent) then
          LogUtil.LogMsg(lmInfo, UNIT_NAME, Format('Overwrite client file %s on %s.',
                                                   [AClientCode, BANKLINK_ONLINE_NAME]))
        else if (AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES) then
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
        if (Silent) or (AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES) then
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
        if (Silent) or (AskYesNo('Send to ' + BANKLINK_ONLINE_NAME, Msg, DLG_YES, 0) <> DLG_YES) then
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
  AProgressFrm: TfrmChkProgress; var ARemoteFileName: string): boolean;
var
 ServerResponce: TServerResponse;
 FirstUpload : Boolean;
begin
  Result := False;
  try
    if Assigned(AdminSystem) then
      CheckBankLinkOnlineStatus(AClientCode, oaPracticeDownload, FirstUpload)
    else
      CheckBankLinkOnlineStatus(AClientCode, oaBooksDownload, FirstUpload);

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
          raise EDownloadFailed.Create(GetBankLinkOnlineErrorString(ServerResponce, False));
        end;
      end
      else
      begin
        CicoClient.DownloadFileToBooks(AClientCode, ARemoteFilename, ServerResponce);

        if ServerResponce.Status <> '200' then
        begin
          raise EDownloadFailed.Create(GetBankLinkOnlineErrorString(ServerResponce, True));
        end;
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

function TBankLinkOnlineManager.GetBankLinkOnlineErrorString(Response: TServerResponse; ForClient: Boolean): String;
begin
  if Response.Status = '120' then
  begin
    if ForClient then
    begin
      Result := TProduct.Rebrand(CICOERRORSTR_CLIENT_CLIENTDEACTIVATED);
    end
    else
    begin
      Result := TProduct.Rebrand(CICOERRORSTR_PRACTICE_CLIENTDEACTIVATED);
    end;
  end
  else
  begin
    Result := TProduct.Rebrand(Response.Description);
  end;
end;

procedure TBankLinkOnlineManager.DebugMsg(AMessage: string);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UNIT_NAME, AMessage);
end;

function TBankLinkOnlineManager.UploadClient(AClientCode: string;
  AProgressFrm: TfrmChkProgress; AClientName, AClientEmail, AClientContact: string;
  var AFirstUpload : Boolean;
  IsCopy: Boolean = False; NotifyPractice: Boolean = False;
  NotifyEmail: string = ''): boolean;
const
  ThisMethodName = 'UploadClient';
var
  ServerResponce : TServerResponse;
begin
  DebugMsg('Begins');
  try
    //Check status
    if Assigned(AdminSystem) then
      CheckBankLinkOnlineStatus(AClientCode, oaPracticeUpload, AFirstUpload)
    else
      CheckBankLinkOnlineStatus(AClientCode, oaBooksUpload, AFirstUpload);

    //Upload to BankLink Online
    if not Silent then begin
      CiCoClient.OnProgressEvent := AProgressFrm.UpdateCICOProgress;
      AProgressFrm.ProgressBar1.Max      := 100;
      AProgressFrm.ProgressBar1.Position := 0;
    end;

    try
      try
        if Assigned(AdminSystem) then
        begin
          if not RegExIsEmailValid(AClientEmail) then
            raise EUploadFailed.Create('A valid client email is required to upload.');

          if ProductConfigService.PracticeUserExists(AClientEmail, False) then
          begin
            raise EUploadFailed.Create(Format('The email address %s already exists as a Practice user. Please specify a different email address or contact %s Support for assistance.', [AClientEmail, TProduct.BrandName]));
          end;

          CiCoClient.UploadFileFromPractice(AClientCode, AClientName, AClientEmail, AClientContact, ServerResponce);

          if ServerResponce.Status <> '200' then
          begin
            raise EDownloadFailed.Create(GetBankLinkOnlineErrorString(ServerResponce, False));
          end;
        end
        else
          CiCoClient.UploadFileFromBooks(AClientCode, IsCopy, NotifyPractice, NotifyEmail, ServerResponce);

          if ServerResponce.Status <> '200' then
          begin
            raise EDownloadFailed.Create(GetBankLinkOnlineErrorString(ServerResponce, True));
          end;
      except
        on E : Exception do
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
finalization
 if Assigned(__BankLinkOnlineMgr) then
   __BankLinkOnlineMgr.Free;
end.
