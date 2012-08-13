unit upgObjects;
//-------------------------------------------------------------------------
//   Hold all of the objects involving in upgrading
//
//
//-------------------------------------------------------------------------

interface
uses
  ipshttps,
  Contnrs,
  classes,
  upgConstants;

type
  TbkAppDetailsList = class;
  TbkApplicationDetail = class;
  TbkAppComponent = class;
  TbkUpgInstaller = class;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  TbkOnStatusChangedEvent = procedure(StatusMsg: string; StatusPosition: integer)
    of object;

  TbkUpgObserver = class
  public
    UpdateProgress: TbkOnStatusChangedEvent;
  end;

  TbkObserverServer = class
    constructor Create;
    destructor Destroy; override;
  protected
    ObserverList: TObjectList;
    ObserverCount: integer;
    procedure UpdateObservers(aMsg: string; aPosition: integer);
  public
    procedure RegisterObserver(aObserver: TbkUpgObserver);
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  TbkUpgDownloader = class(TbkObserverServer)
    constructor Create;
  private
    FTempDir: string;
    FUseTempDir: boolean;
    FDownloading: boolean;
    FForceUpdate: boolean;
    FCheckIndividualFiles: boolean;
    procedure SetTempDir(const Value: string);
    procedure SetUseTempDir(const Value: boolean);
    procedure SetForceUpdate(const Value: boolean);
    procedure SetCheckIndividualFiles(const Value: boolean);
  public
    property TempDir: string read FTempDir write SetTempDir;
    property UseTempDir: boolean read FUseTempDir write SetUseTempDir;
    function GetFile(FromLocation: string; ToLocation: string; ExpectedCRC:
      LongWord): integer; virtual; abstract;

    procedure CancelDownload; virtual; abstract;
    procedure LoadConfig(ConfigStr: string); virtual; abstract;

    property DownloadInProgress: boolean read FDownloading;
    property ForceUpdate: boolean read FForceUpdate write SetForceUpdate;
    property CheckIndividualFiles: boolean read FCheckIndividualFiles write
      SetCheckIndividualFiles;
  end;

    ///<author>Matthew Hopkins</author>
  TbkUpgFileBasedDownloader = class(TbkUpgDownloader)
  private
    FCancelled: boolean;
    FCurrentFile: string;
  public
    function GetFile(FromLocation: string; ToLocation: string; ExpectedCRC:
      LongWord): integer; override;
    procedure CancelDownload; override;
    procedure LoadConfig(ConfigStr: string); override;
    property CurrentFile: string read FCurrentFile;
  end;

  ///<author>Matthew Hopkins</author>
  TbkUpgHTTPDownloader = class(TbkUpgDownloader)
    constructor Create;
    destructor Destroy; override;
  private
    HttpsHandler: TipsHttps;
    LastErrorNo: integer;
    ReasonForFailure: string;

    FFileSize: Int64;
    FContentType: string;
    FBytesReceived: Integer;
    FFilename: string;
    FHeaders: TStringList;
    FIsHtml: boolean;
    FRawConfig: string;

    procedure HttpsHandlerError(Sender: TObject; ErrorCode: Integer;
      const Description: string);

    procedure HttpsHandlerEndTransfer(Sender: TObject; Direction: Integer);
    procedure HttpsHandlerHeader(Sender: TObject; const Field, Value: string);
    procedure HttpsHandlerStartTransfer(Sender: TObject; Direction: Integer);
    procedure HttpsHandlerTransfer(Sender: TObject; Direction, BytesTransferred:
      Integer; Text: string);
    procedure HTTPHandlerConnectionStatus(Sender: TObject; const
      ConnectionEvent: string; StatusCode: Integer;
      const Description: string);
    procedure HTTPHandlerConnected(Sender: TObject; StatusCode: Integer;
      const Description: string);

    procedure InitialiseHTTPS;
  public
    function GetFile(FromLocation: string; ToLocation: string; ExpectedCRC:
      LongWord): integer; override;
    procedure CancelDownload; override;
    procedure LoadConfig(ConfigStr: string); override;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  ///<author>Matthew Hopkins</author>
  TbkUpgInstaller = class(TbkObserverServer)
    destructor Destroy; override;
  private
    FFilter: integer;
    FTempDir: string;
    FExpectedCRC: longword;
    procedure SetExpectedCRC(const Value: longword);
    procedure SetTempDir(const Value: string);
    procedure SetFilter(const Value: integer);
    function WaitforMutex(aMutex: string; const Timeout: Integer = 10000):
      boolean;
    function ExecuteFile(ExeParam: string; Param: string; ComponentName:
      string): integer;
  public
    property TempDir: string read FTempDir write SetTempDir;
    function InstallFilesForApp(aAppID: integer): integer;
    property Filter: integer read FFilter write SetFilter;
    property ExpectedCRC: longword read FExpectedCRC write SetExpectedCRC;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  TbkUpgCatalog = class
  private
    CatalogDownloaded: boolean;
    FStatusObserver: TbkUpgObserver;
    ApplicationList: TbkAppDetailsList;
    FCatalogServer: string;
    FInstallScriptCRC: longword;
    FCatalogCountry: byte;
    FServerPath: string;
    FDownloaderType: TbkUpgDownloaderType;
    FTempDir: string;
    FDownloader: TbkUpgDownloader;
    FForceUpdate: boolean;
    FCheckIndividualFiles: boolean;

    procedure SetServerPath;
    procedure SetCatalogCountry(const Value: byte);
    procedure SetInstallScriptCRC(const Value: longword);
    procedure SetCatalogServer(const Value: string);
    procedure SetStatusObserver(const Value: TbkUpgObserver);
    procedure SetTempDir(const Value: string);
    function GetDownloader: TbkUpgDownloader;
    procedure SetForceUpdate(const Value: boolean);
    function IsNewVersion(LatestMajor: Word; LatestMinor: Word; LatestRelease:
      Word; LatestBuild: Word; CurrMajor: Word; CurrMinor: Word; CurrRelease:
      Word; CurrBuild: Word): boolean;
    function IsNewComponentVersion(CurrComponent: TbkAppComponent; IsNewCatalog:
      boolean; InstallPath: string = ''): boolean;
    function DoesComponentExist(CurrComponent: TbkAppComponent; InstallPath:
      string = ''): boolean;
    procedure BuildComponentXMLString(Component: TbkAppComponent; const
      installpath: string; var s: string);
    procedure SetCheckIndividualFiles(const Value: boolean);
  public
    property Downloader: TbkUpgDownloader read GetDownloader;
    //Installer : TbkUpgInstaller;

    constructor Create(AType: TbkUpgDownloaderType = dtHTTP); reintroduce;
    destructor Destroy; override;

    function RetrieveCatalog: boolean;
    function UpdateAvailable(aAppId: integer; CurrMajor, CurrMinor, CurrRelease,
      CurrBuild: word;
      var Title: string; var DetailFrom: string): boolean; overload;
    function UpdateAvailable(aFilename: string): boolean; overload;
    function DownloadUpdatesToApp(aAppId: integer; CopyWhenFinished: boolean =
      false): integer;
    function FindApplication(aAppId: integer): TbkApplicationDetail;
    procedure Initialise;

    procedure LoadDownloaderConfig(ConfigStr: string);

    property StatusObserver: TbkUpgObserver read FStatusObserver write
      SetStatusObserver;
    property CatalogServer: string read FCatalogServer write SetCatalogServer;
    property CatalogCountry: byte read FCatalogCountry write SetCatalogCountry;
    property InstallScriptCRC: longword read FInstallScriptCRC write
      SetInstallScriptCRC;
    property TempDir: string read FTempDir write SetTempDir;
    property ForceUpdate: boolean read FForceUpdate write SetForceUpdate;
    property CheckIndividualFiles: boolean read FCheckIndividualFiles write
      SetCheckIndividualFiles;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  TbkAppComponent = class
    Filename: string;
    SrcURL: string;
    crc: LongWord;
    size: int64;
    execute: boolean;
    subdir: string;
    param: string;
    AppMustBeClosed: boolean;
    RestartTiming: smallint;
    UpgradeMethod: smallint;
    DownloadFile: boolean;
    DownloadOK: boolean;
    VerMajor: word;
    VerMinor: word;
    VerRelease: word;
    VerBuild: word;
    AgeOfFile: int64;
    IsExisting: boolean;
  end;

  TbkDownloadServerApp = class
  private
    FVersionString: string;
    FDescription: string;
    FDetailsHref: string;
    FSelected: boolean;
    function GetDetailsURLText: string;
  public
    constructor Create(VersionString, Description, DetailsHref: string);
    property Description: string read FDescription write FDescription;
    property VersionString: string read FVersionString write FVersionString;
    property DetailsHref: string read FDetailsHref write FDetailsHref;
    property DetailsURLText: string read GetDetailsURLText;
    property Selected: boolean read FSelected write FSelected;
  end;

  TbkApplicationComponents = class(TObjectList)
    constructor Create;
  public
    procedure AddItem(aComponent: TbkAppComponent);
    function ComponentAt(index: integer): TbkAppComponent;
  end;

  TbkAppSubApplication = class
    constructor Create;
    destructor Destroy; override;
  private
    FSelected: boolean;
    procedure SetSelected(const Value: boolean);
    function GetHasExisting: boolean;
  published
  public
    OwnerApp: TbkApplicationDetail;
    AppTitle: string;
    AppDirectory: string;
    Manditory: boolean;
    AppComponents: TbkApplicationComponents;
    function GetAppDirectory: string;
    property Selected: boolean read FSelected write SetSelected;
    property HasExisting: boolean read GetHasExisting;
  end;

  TbkApplicationSubApplications = class(TObjectList)
    constructor Create;
  public
    procedure AddItem(aSubApp: TbkAppSubApplication);
    function SubApplicationAt(index: integer): TbkAppSubApplication;
  end;

  TbkApplicationDetail = class
    constructor Create;
    destructor Destroy; override;
  private
    FVerMinor: word;
    FVerRelease: word;
    FVerMajor: word;
    FAppId: Integer;
    FVerBuild: word;
    FDetailsURL: string;
    FAppName: string;
    FDetailsURLText: string;
    FMinVersion: string;
    FSelected: boolean;
    AppComponents: TbkApplicationComponents;
    procedure SetDetailsURLText(const Value: string);
    procedure SetSelected(const Value: boolean);
    procedure SetAppId(val: Integer);
    procedure SetAppName(val: string);
    procedure SetDetailsURL(val: string);
    procedure SetVerBuild(val: word);
    procedure SetVerMajor(val: word);
    procedure SetVerMinor(val: word);
    procedure SetVerRelease(val: word);
  public
    AppSubApps: TbkApplicationSubApplications;
    property AppId: Integer read FAppId write SetAppId;
    property AppName: string read FAppName write SetAppName;
    property VerMajor: word read FVerMajor write SetVerMajor;
    property VerMinor: word read FVerMinor write SetVerMinor;
    property VerRelease: word read FVerRelease write SetVerRelease;
    property VerBuild: word read FVerBuild write SetVerBuild;

    ///<preconditions>Specifies a href to a description of this application</preconditions>
    property DetailsURL: string read FDetailsURL write SetDetailsURL;
    property DetailsURLText: string read FDetailsURLText write SetDetailsURLText;
    property MinVersion: string read FMinVersion write FMinVersion;
    property Selected: boolean read FSelected write SetSelected;
  end;

  TbkAppDetailsList = class(TObjectList)
    constructor Create;
  private
    function ApplicationAt(aIndex: integer): TbkApplicationDetail;
    procedure LoadFromXml(xmlFile: string);
  public
    procedure AddToList(aApp: TbkApplicationDetail);
  end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
  forms,
  SysUtils,
  Windows,
  Dialogs,
  omnixml,
  omniXmlUtils,
  dateutils,
  ShellAPI,
  CRCFileUtils,
  upgExceptions,
  inifiles,
  StrUtils,
  upgCommon;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CopyFileWithProgressBarCallBack(TotalFileSize,
  TotalBytesTransferred,
  StreamSize,
  StreamBytesTransferred: LARGE_INTEGER;
  dwStreamNumber,
  dwCallbackReason: DWORD;
  hSourceFile,
  hDestinationFile: THandle;
  lpData: Pointer): DWORD; stdcall;
begin
  // just set size at the beginning
  TbkUpgFileBasedDownloader(lpData).UpdateObservers(TbkUpgFileBasedDownloader(lpData).CurrentFile, Round((TotalBytesTransferred.QuadPart / TotalFileSize.QuadPart) *
    100));
  Application.ProcessMessages;
  if TbkUpgFileBasedDownloader(lpData).FCancelled then
    Result := PROGRESS_CANCEL
  else
    Result := PROGRESS_CONTINUE;
end;

{ TbkUpgDownloader }

constructor TbkUpgDownloader.Create;
begin
  inherited
end;

procedure TbkUpgDownloader.SetCheckIndividualFiles(const Value: boolean);
begin
  FCheckIndividualFiles := Value;
end;

procedure TbkUpgDownloader.SetForceUpdate(const Value: boolean);
begin
  FForceUpdate := Value;
end;

procedure TbkUpgDownloader.SetTempDir(const Value: string);
begin
  FTempDir := Value;
end;

procedure TbkUpgDownloader.SetUseTempDir(const Value: boolean);
begin
  FUseTempDir := Value;
end;

{ TbkUpgCatalog }

constructor TbkUpgCatalog.Create(AType: TbkUpgDownloaderType);
begin
  ApplicationList := TbkAppDetailsList.Create;
  CatalogDownloaded := false;
  FServerPath := '';
  FDownloaderType := AType;
end;

destructor TbkUpgCatalog.Destroy;
begin
  if Assigned(FDownloader) then
    FreeAndNil(FDownloader);
//  if Assigned (Installer) then
//    FreeAndNil (Installer);
  if Assigned(ApplicationList) then
    FreeAndNil(ApplicationList);
  inherited;
end;

function TbkUpgCatalog.DoesComponentExist(CurrComponent: TbkAppComponent;
  InstallPath: string): boolean;
var
  afilename: string;
begin
  Result := false;
  afilename := IncludeTrailingPathDelimiter (InstallPath);
  if Trim(afilename) = '' then
    afilename := ExtractFilePath(GetDllPath);
  if DirectoryExists (afilename) then
    begin
      afilename := afilename + CurrComponent.Filename;

      {$IFDEF DEBUGTIM}
      if Copy(afilename, 1, 1) = '\' then
        afilename := Copy(afilename, 2, length(afilename));
      {$ENDIF}

      Result := FileExists(afilename);
    end;
end;

function TbkUpgCatalog.DownloadUpdatesToApp(aAppId: integer; CopyWhenFinished:
  boolean = false): integer;
var
  App: TbkApplicationDetail;
  SubApp: TbkAppSubApplication;
  Component: TbkAppComponent;
  i: integer;
  s: string;
  sDate: string;
  FromFilename, ToFilename: string;
  Success: boolean;
  InstallScriptFilename: string;

  fs: TFormatSettings;
  j: Integer;
  updatecount: integer;
begin
  result := 0;
  updatecount := 0;
  s := '';
  Success := true;
  FInstallScriptCRC := 0;

  App := FindApplication(aAppId);
  if Assigned(App) then
    begin
    //download files to temporary location from which they can be installed
      Downloader.UseTempDir := true;

    //get tformat settings so can use thread safe call to DateToSt
      GetLocaleFormatSettings(64, fs);
      sDate := FormatDateTime('ddmmyyyy', Today, fs);

    //delete any existing files from dir
      for i := 0 to App.AppComponents.Count - 1 do
        begin
          Component := App.AppComponents.ComponentAt(i);
          s := Downloader.TempDir + Component.Filename;
          DeleteFile(PChar(s));
        end;
      for i := 0 to App.AppSubApps.Count - 1 do
        begin
          SubApp := App.AppSubApps.SubApplicationAt(i);
          for j := 0 to SubApp.AppComponents.Count - 1 do
            begin
              Component := SubApp.AppComponents.ComponentAt(j);
              s := Downloader.TempDir + Component.Filename;
              DeleteFile(PChar(s));
            end
        end;

    //download all files contained in the components list for this application
    //all components must download successfuly otherwise clear out downloaded
    //files
      s := '<files><dl>' + sDate + '</dl>';
      if ForceUpdate then
        s := s + '<forceupdate>1</forceupdate>'
      else
        s := s + '<forceupdate>0</forceupdate>';
      if CheckIndividualFiles then
        s := s + '<checkindividualfiles>1</checkindividualfiles>'
      else
        s := s + '<checkindividualfiles>0</checkindividualfiles>';

      for i := 0 to App.AppComponents.Count - 1 do
        begin
          Component := App.AppComponents.ComponentAt(i);
          if Component.DownloadFile then
            begin
              Component.DownloadOK := false;
              if Success and (FDownloader.GetFile(FServerPath +
                Component.SrcURL, Component.Filename, Component.crc) = 1) then
                begin
                  Component.DownloadOK := true;
                  Inc(updatecount);
               //construct xml file detailing where to install files to
                  if not CopyWhenFinished then
                    BuildComponentXMLString(Component, '', s);
                end
              else
                success := false;
            end;
        end;
      for i := 0 to App.AppSubApps.Count - 1 do
        begin
          SubApp := App.AppSubApps.SubApplicationAt(i);
          if SubApp.Selected then
            for j := 0 to SubApp.AppComponents.Count - 1 do
              begin
                Component := SubApp.AppComponents.ComponentAt(j);
                if Component.DownloadFile then
                  begin
                    Component.DownloadOK := false;
                    if Success and (FDownloader.GetFile(FServerPath +
                      Component.SrcURL, Component.Filename, Component.crc) = 1)
                      then
                      begin
                        Component.DownloadOK := true;
                        Inc(updatecount);
                  //construct xml file detailing where to install files to
                        if not CopyWhenFinished then
                          BuildComponentXMLString(Component,
                            subapp.GetAppDirectory, s);
                      end
                    else
                      success := false;
                  end;
              end;
        end;
      s := s + '</files>';

      if Success and (updatecount > 0) then
        begin
          result := upgConstants.uaInstallPending;

          if not CopyWhenFinished then
            begin
        //will need to write a file that tells app what files are waiting to be
        //installed
              with TStringList.Create do
                begin
                  try
                    Text := s;
                    InstallScriptFilename := Downloader.TempDir +
                      IntToStr(aAppId) + '.xml';
                    SaveToFile(InstallScriptFilename);
            //store the CRC of the install script so this can be passed back to
            //the calling app.  this allows us to test for corruption or
            //tampering.
                    FInstallScriptCRC :=
                      CRCFileUtils.CalculateCRC(InstallScriptFilename);
                  finally
                    Free;
                  end;
                end;
            end
          else
            begin
        //this is a special case that copies the file to the live location
        //as soon as they are downloaded
        //used for when downloading all updates for the upgrader
              for i := 0 to App.AppComponents.Count - 1 do
                begin
                  Component := App.AppComponents.ComponentAt(i);
                  s := Component.Filename;
                  FromFilename := Downloader.TempDir + s;
                  ToFilename := ExtractFilePath(GetDllPath) + s;
                  repeat
                    if CopyFile(PChar(FromFilename), PChar(ToFilename), false)
                      then
                      break
                    else
                      begin
                        S := SysErrorMessage(GetLastError);
                        case
                          Application.MessageBox(PChar('Could not file copy to ' +
                          ToFilename +
                          #13'[' + S +
                            ']'#13'Please make sure it is not in use'), 'Confirm',
                          MB_RETRYCANCEL + MB_ICONERROR)
                       {
                  case MessageDlg('Could not file copy to ' + ToFilename +
                                  #13'[' +  S + ']'#13'Please make sure it is not in use',
                                  mterror, [ mbRetry, mbCancel], 0)
                        }
                        of
                          idRetry: ;
                          idCancel:
                            begin
                              Result := uaUserCancelled;
                                // Should be uaExceptionRaised ??
                              Exit;
                            end;
                        end;
                      end;
                  until false;
                end;
              for i := 0 to App.AppSubApps.Count - 1 do
                begin
                  SubApp := App.AppSubApps.SubApplicationAt(i);
                  for j := 0 to SubApp.AppComponents.Count - 1 do
                    begin
                      Component := SubApp.AppComponents.ComponentAt(j);
                      s := Component.Filename;
                      FromFilename := Downloader.TempDir + s;
                      ToFilename := ExtractFilePath(GetDllPath) + s;
                      repeat
                        if CopyFile(PChar(FromFilename), PChar(ToFilename),
                          false) then
                          break
                        else
                          begin
                            S := SysErrorMessage(GetLastError);
                            case
                              Application.MessageBox(PChar('Could not file copy to ' + ToFilename +
                              #13'[' + S +
                                ']'#13'Please make sure it is not in use'),
                                'Confirm',
                              MB_RETRYCANCEL + MB_ICONERROR)
                          {
                     case MessageDlg('Could not file copy to ' + ToFilename +
                                     #13'[' +  S + ']'#13'Please make sure it is not in use',
                                     mterror, [ mbRetry, mbCancel], 0)
                           }
                            of
                              idRetry: ;
                              idCancel:
                                begin
                                  Result := uaUserCancelled;
                                    // Should be uaExceptionRaised ??
                                  Exit;
                                end;
                            end;
                          end;
                      until false;
                    end;
                end;
            end;
        end
      else
        begin
      //delete any files that did succedd
          for i := 0 to App.AppComponents.Count - 1 do
            begin
              Component := App.AppComponents.ComponentAt(i);
              if Component.DownloadOK then
                begin
                  s := Downloader.TempDir + Component.Filename;
                  DeleteFile(PChar(s));
                end;
            end;
          for i := 0 to App.AppSubApps.Count - 1 do
            begin
              SubApp := App.AppSubApps.SubApplicationAt(i);
              for j := 0 to SubApp.AppComponents.Count - 1 do
                begin
                  Component := SubApp.AppComponents.ComponentAt(j);
                  if Component.DownloadOK then
                    begin
                      s := Downloader.TempDir + Component.Filename;
                      DeleteFile(PChar(s));
                    end;
                end;
            end;
          result := uaDownloadFailed;
        end;
    end;
end;

function TbkUpgCatalog.FindApplication(aAppId: integer): TbkApplicationDetail;
var
  i: integer;
  App: TbkApplicationDetail;
begin
  result := nil;

  if Assigned(ApplicationList) then
    begin
      for i := 0 to ApplicationList.Count - 1 do
        begin
          App := ApplicationList.ApplicationAt(i);
          if App.AppId = aAppId then
            begin
              result := App;
              Exit;
            end;
        end;
    end;
end;

function TbkUpgCatalog.GetDownloader: TbkUpgDownloader;
begin
  if not Assigned(FDownloader) then
    begin
      if FDownloaderType = dtHTTP then
        FDownloader := TbkUpgHTTPDownloader.Create
      else
        FDownloader := TbkUpgFileBasedDownloader.Create;
      FDownloader.TempDir := TempDir;
      FDownloader.ForceUpdate := ForceUpdate;
    end;
  Result := FDownloader;
end;

procedure TbkUpgCatalog.Initialise;
begin
  if Assigned(FDownloader) then
    FreeAndNil(FDownloader);

//  if Assigned (Installer) then
//    FreeAndNil (Installer);
//  Installer := TbkUpgInstaller.Create;

  SetServerPath;
end;

procedure TbkUpgCatalog.LoadDownloaderConfig(ConfigStr: string);
begin

end;

procedure TbkUpgCatalog.BuildComponentXMLString(Component: TbkAppComponent; const
  installpath: string; var s: string);
begin
  s := s + '<component><filename>' + Component.Filename + '</filename>';
  if Component.subdir <> '' then
    s := s + '<subdir>' + Component.subdir + '</subdir>'
  else
    if installpath <> '' then
      s := s + '<subdir>' + installpath + '</subdir>';
  if Component.crc <> 0 then
    s := s + '<crc>' + IntToStr(Component.crc) + '</crc>';
  if Component.size <> 0 then
    s := s + '<size>' + IntToStr(Component.size) + '</size>';
  if Component.execute then
    s := s + '<execute>1</execute>';
  if Component.param <> '' then
    s := s + '<param>' + Component.param + '</param>';
  if Component.AppMustBeClosed then
    s := s + '<closeapp>1</closeapp>';
  if Component.RestartTiming > -1 then
    s := s + '<restarttiming>' + IntToStr(Component.RestartTiming) +
      '</restarttiming>';
  if Component.UpgradeMethod > 0 then
    s := s + '<upgrademethod>' + IntToStr(Component.UpgradeMethod) +
      '</upgrademethod>';
  if Component.VerMajor <> 0 then
    s := s + '<major>' + IntToStr(Component.VerMajor) + '</major>';
  if Component.VerMinor <> 0 then
    s := s + '<minor>' + IntToStr(Component.VerMinor) + '</minor>';
  if Component.VerRelease <> 0 then
    s := s + '<release>' + IntToStr(Component.VerRelease) + '</release>';
  if Component.VerBuild <> 0 then
    s := s + '<build>' + IntToStr(Component.VerBuild) + '</build>';
  if Component.AgeOfFile <> 0 then
    s := s + '<ageoffile>' + IntToStr(Component.AgeOfFile) + '</ageoffile>';
  //write in signature
  s := s + '</component>';
end;

function TbkUpgCatalog.IsNewComponentVersion(
  CurrComponent: TbkAppComponent; IsNewCatalog: boolean; InstallPath: string):
    boolean;
var
  imajor, iminor, irelease, ibuild: word;
  afilename: string;
begin
  Result := IsNewCatalog;
  if CurrComponent.UpgradeMethod <> umNone then
    begin
      afilename := InstallPath;
      if Trim(afilename) = '' then
        afilename := ExtractFilePath(GetDllPath);
      if not DirectoryExists (afilename) then
        Result := true
      else
        begin
          afilename := afilename + CurrComponent.Filename;
          if not FileExists(afilename) then
            Result := true
          else
            begin
              case CurrComponent.UpgradeMethod of
                umVersion:
                  begin
                    RetrieveFileVersion(afilename, imajor, iminor, irelease,
                      ibuild);
                    Result := IsNewVersion(CurrComponent.VerMajor,
                      CurrComponent.VerMinor, CurrComponent.VerRelease,
                      CurrComponent.VerBuild, imajor, iminor, irelease, ibuild);
                  end;
                umVersionCRC:
                  begin
                    RetrieveFileVersion(afilename, imajor, iminor, irelease,
                      ibuild);
                    Result := IsNewVersion(CurrComponent.VerMajor,
                      CurrComponent.VerMinor, CurrComponent.VerRelease,
                      CurrComponent.VerBuild, imajor, iminor, irelease, ibuild);
                    if not Result and (CurrComponent.VerMajor = imajor) and
                      (CurrComponent.VerMinor = iminor) and (CurrComponent.VerRelease
                      = irelease) and (CurrComponent.VerBuild = ibuild) then
                      Result := CurrComponent.crc <>
                        crcFileUtils.CalculateCRC(aFileName);

                  end;
                umCRC:
                  Result := CurrComponent.crc <>
                    crcFileUtils.CalculateCRC(aFileName);
                umCRCSize:
                  begin
                    Result := CurrComponent.crc <>
                      crcFileUtils.CalculateCRC(aFileName);
                    if not Result and (CurrComponent.crc =
                      crcFileUtils.CalculateCRC(aFileName)) then
                      Result := CurrComponent.size <> GetFileSize(aFileName);

                  end;
                umSize:
                  Result := CurrComponent.size <> GetFileSize(aFileName);
                umSizeDate:
                  begin
                    Result := CurrComponent.size <> GetFileSize(aFileName);
                    if not result and (CurrComponent.size = GetFileSize(aFileName))
                      then
                      Result := CurrComponent.AgeOfFile <> FileAge(aFileName);

                  end;
                umDate:
                  begin
                    Result := CurrComponent.AgeOfFile <> FileAge(aFileName);
                  end;
                umVersionDate:
                  begin
                    RetrieveFileVersion(afilename, imajor, iminor, irelease,
                      ibuild);
                    Result := IsNewVersion(CurrComponent.VerMajor,
                      CurrComponent.VerMinor, CurrComponent.VerRelease,
                      CurrComponent.VerBuild, imajor, iminor, irelease, ibuild);
                    if not Result and (CurrComponent.VerMajor = imajor) and
                      (CurrComponent.VerMinor = iminor) and (CurrComponent.VerRelease
                      = irelease) and (CurrComponent.VerBuild = ibuild) then
                      Result := CurrComponent.AgeOfFile <> FileAge(aFileName);
                  end;
                umFull:
                  begin
                    RetrieveFileVersion(afilename, imajor, iminor, irelease,
                      ibuild);
                    Result := IsNewVersion(CurrComponent.VerMajor,
                      CurrComponent.VerMinor, CurrComponent.VerRelease,
                      CurrComponent.VerBuild, imajor, iminor, irelease, ibuild);
                    if not Result and (CurrComponent.VerMajor = imajor) and
                      (CurrComponent.VerMinor = iminor) and (CurrComponent.VerRelease
                      = irelease) and (CurrComponent.VerBuild = ibuild) then
                      begin
                        Result := CurrComponent.crc <>
                          crcFileUtils.CalculateCRC(aFileName);
                        if not Result and (CurrComponent.crc =
                          crcFileUtils.CalculateCRC(aFileName)) then
                          begin
                            Result := CurrComponent.size <> GetFileSize(aFileName);
                            if not result and (CurrComponent.size =
                              GetFileSize(aFileName)) then
                              Result := CurrComponent.AgeOfFile <>
                                FileAge(aFileName);
                          end;
                      end;
                  end;

              end;
            end;
        end
    end;
end;

function TbkUpgCatalog.IsNewVersion(LatestMajor: Word; LatestMinor: Word;
  LatestRelease: Word; LatestBuild: Word; CurrMajor: Word; CurrMinor: Word;
  CurrRelease: Word; CurrBuild: Word): boolean;
begin
  Result := false;
  //see if version in catalog is later
  if LatestMajor > CurrMajor then
    result := true
  else
    if LatestMajor = CurrMajor then
      begin
        if LatestMinor > CurrMinor then
          result := true
        else
          if LatestMinor = CurrMinor then
            begin
              if LatestRelease > CurrRelease then
                result := true
              else
                if LatestRelease = CurrRelease then
                  begin
                    if LatestBuild > CurrBuild then
                      result := true;
                  end;
            end;
      end;
end;

procedure TbkUpgCatalog.SetServerPath;
var
  server: string;
  path: string;
  upgINI: TIniFile;
  fn: string;
  IniServer: string;
  IniCountry: integer;
begin
  //override from ini file if exists
  fn := ExtractFilePath(GetDllPath) + bkupgIniFile;
  if FileExists(fn) then
    begin
      upgINI := TIniFile.Create(fn);
      try
        IniServer := upgINI.ReadString('config', 'server', '');
        if IniServer <> '' then
          FCatalogServer := IniServer;

        IniCountry := upgINI.ReadInteger('config', 'country', -1);
        if IniCountry <> -1 then
          FCatalogCountry := IniCountry;
      finally
        upgINI.Free;
      end;
    end;

  case FCatalogCountry of
    coNewZealand:
      begin
        server := DefaultNZCatalogServer;
        path := 'bupgrade/nz/';
      end;
    coAustralia:
      begin
        server := DefaultAUCatalogServer;
        path := 'bupgrade/au/';
      end;
    coTest:
      begin
        server := DefaultNZCatalogServer;
        path := 'bupgrade/test/';
      end;
    coInternal:
      begin
        server := DefaultInternalCatalogServer;
        path := '';
      end;
  else
    begin
      server := DefaultNZCatalogServer;
      path := 'bupgrade/nz/';
    end;
  end;

  //override default path if specified

  if Downloader is TbkUpgHTTPDownloader then
    begin
      if FCatalogServer <> '' then
        server := FCatalogServer;
      FServerPath := 'http://' + Server + '/' + Path
    end
  else
    if FCatalogServer <> '' then
      FServerPath := IncludeTrailingPathDelimiter(FCatalogServer)
    else
      FServerPath := IncludeTrailingPathDelimiter(StringReplace(Server, '/', '\',
        [rfReplaceAll])) + IncludeTrailingPathDelimiter(StringReplace(Path, '/',
        '\', [rfReplaceAll]));
end;

function TbkUpgCatalog.RetrieveCatalog: boolean;
begin
  result := false;
  Downloader.UseTempDir := false; //download to current dir
  StatusObserver.UpdateProgress('Downloading Catalog', 1);
  CatalogDownloaded := (Downloader.GetFile(FServerPath + CatalogFilename,
    CatalogFilename, 0) = 1);
  if CatalogDownloaded then
    begin
      StatusObserver.UpdateProgress('Checking for updates', 50);
    //parse catalog into objects
      ApplicationList.LoadFromXml(CatalogFilename);
      result := true;
    end;
end;

function TbkUpgCatalog.UpdateAvailable(aAppId: integer; CurrMajor, CurrMinor,
  CurrRelease, CurrBuild: word; var Title: string; var DetailFrom: string):
    boolean;
var
  IsNewCatalog: boolean;
  LatestApp: TbkApplicationDetail;
  LatestSubApp: TbkAppSubApplication;
  LatestComponent: TbkAppComponent;
  i: integer;
  j: Integer;
  k: Integer;
  x: Integer;
  WinVer, NTVer, MachineVer: Double;
  OSVersionInfo32: OSVERSIONINFO;
begin
  result := false;
  Title := '';
  DetailFrom := '';

  if not CatalogDownloaded then
    RetrieveCatalog;

  //find app id in list and see if later version is available
  for i := 0 to ApplicationList.Count - 1 do
    begin
      LatestApp := ApplicationList.ApplicationAt(i);
      if LatestApp.AppId = aAppId then
        begin
          { If unsupported on this version of windows then skip it
            Uses the same format as INNO setup:
            Format: a.bb,c.dd, where a.bb is the Windows version, and c.dd is the Windows NT version.
            Default value: 4.0,4.0
            Windows versions:
            4.0 Windows 95
            4.1 Windows 98
            4.9 Windows ME

            Windows NT versions:
            4.0 Windows NT 4.0
            5.0 Windows 2000
            5.01 Windows XP
            5.02 Windows Server 2003
            6    Windows Vista
          }
          x := Pos(',', LatestApp.MinVersion);
          if x > 0 then
          begin
            WinVer := StrToFloatDef(Copy(LatestApp.MinVersion, 1, x - 1), 4.0);
            NTVer  := StrToFloatDef(Copy(LatestApp.MinVersion, x + 1, Length(LatestApp.MinVersion)), 4.0);
            OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
            GetVersionEx(OSVersionInfo32);
            MachineVer := StrToFloatDef(IntToStr(OSVersionInfo32.dwMajorVersion) + '.' + IntToStr(OSVersionInfo32.dwMinorVersion), 99);
            if OSVersionInfo32.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
            begin
              if (MachineVer < WinVer) or (WinVer = 0) then
              begin
                Result := False;
                exit;
              end;
            end
            else if OSVersionInfo32.dwPlatformId = VER_PLATFORM_WIN32_NT then
            begin
              if (MachineVer < NTVer) or (NTVer = 0) then
              begin
                Result := False;
                exit;
              end;
            end;
          end;

          if ForceUpdate then
            Result := true
          else
            begin
              IsNewCatalog := IsNewVersion(LatestApp.VerMajor,
                LatestApp.VerMinor, LatestApp.VerRelease, LatestApp.VerBuild,
                CurrMajor, CurrMinor, CurrRelease, CurrBuild);
              Result := IsNewCatalog;
            end;

          //Check the components flagged for checking
          for j := 0 to LatestApp.AppComponents.Count - 1 do
            begin
              LatestComponent := LatestApp.AppComponents.ComponentAt(j);
              LatestComponent.IsExisting := DoesComponentExist(LatestComponent,
                ExtractFilePath(GetDllPath));
              if ForceUpdate then
                LatestComponent.DownloadFile := Result
              else
                if CheckIndividualFiles then
                  begin
                    if IsNewComponentVersion(LatestComponent, IsNewCatalog,
                      ExtractFilePath(GetDllPath)) then
                      begin
                        LatestComponent.DownloadFile := true;
                        if not Result then
                          Result := true;
                      end;
                  end
                else
                  LatestComponent.DownloadFile := Result;
            end;

          //Check the subcomponents flagged for checking
          for j := 0 to LatestApp.AppSubApps.Count - 1 do
          begin
            LatestSubApp := LatestApp.AppSubApps.SubApplicationAt(j);

            for k := 0 to LatestSubApp.AppComponents.Count - 1 do
            begin
              LatestComponent := LatestSubApp.AppComponents.ComponentAt(k);
              LatestComponent.IsExisting := DoesComponentExist(LatestComponent, LatestSubApp.GetAppDirectory);

              //If an optional component already exists on this install then force the sub app mandatory -
              //therefore the optional is only specific to the first install, it will stay optional during all
              //upgrades until it is installed therefore making it mandatory from then on
              if (LatestComponent.IsExisting = True) and (LatestSubApp.Manditory = False) then
              begin
                LatestSubApp.Manditory := True;
              end;

              if ForceUpdate then
              begin
                LatestComponent.DownloadFile := Result;
              end
              else
              begin
                if CheckIndividualFiles then
                begin
                  if IsNewComponentVersion(LatestComponent, IsNewCatalog, LatestSubApp.GetAppDirectory) then
                  begin
                    LatestComponent.DownloadFile := LatestSubApp.Manditory or (not LatestSubApp.Manditory and LatestComponent.IsExisting);

                    if not Result and LatestComponent.DownloadFile then
                      Result := true;
                  end;
                end
                else
                begin
                  LatestComponent.DownloadFile := Result;
                end;
              end;
            end;
          end;

          if result then
            begin
              Title := LatestApp.FAppName + ' ' +
                intToStr(LatestApp.VerMajor) + '.' +
                inttostr(latestApp.verminor) + '.' +
                inttostr(latestApp.VerRelease) + '.' +
                inttostr(latestApp.VerBuild);
              DetailFrom := LatestApp.DetailsURLText;
            end;

          break;
        end;
    end;
end;

procedure TbkUpgCatalog.SetCatalogCountry(const Value: byte);
begin
  FCatalogCountry := Value;
end;

procedure TbkUpgCatalog.SetCatalogServer(const Value: string);
begin
  FCatalogServer := Value;
end;

procedure TbkUpgCatalog.SetCheckIndividualFiles(const Value: boolean);
begin
  FCheckIndividualFiles := Value;
end;

procedure TbkUpgCatalog.SetForceUpdate(const Value: boolean);
begin
  FForceUpdate := Value;
end;

procedure TbkUpgCatalog.SetInstallScriptCRC(const Value: longword);
begin
  FInstallScriptCRC := Value;
end;

procedure TbkUpgCatalog.SetStatusObserver(const Value: TbkUpgObserver);
begin
  FStatusObserver := Value;
  Downloader.RegisterObserver(Value)
end;

procedure TbkUpgCatalog.SetTempDir(const Value: string);
begin
  FTempDir := Value;
end;

function TbkUpgCatalog.UpdateAvailable(aFilename: string): boolean;
//parameters:
//              aFilename : name of file to test for updates
//returns:
//              true if an update is available
//purpose:
//        To determine if there is a later version of the specified file
//
begin
  result := false;
  if not CatalogDownloaded then
    if not RetrieveCatalog then
      begin
      //could not retrieve catalog
        exit;
      end;

  //compare version information
  //read version using windows calls
end;

{ TbkUpgFileBasedDownloader }

procedure TbkApplicationDetail.SetAppId(val: Integer);
begin
  FAppId := val;
end;

procedure TbkApplicationDetail.SetAppName(val: string);
begin
  FAppname := val;
end;

procedure TbkApplicationDetail.SetVerMajor(val: word);
begin
  FVerMajor := val;
end;

procedure TbkApplicationDetail.SetVerMinor(val: word);
begin
  FVerMinor := val;
end;

procedure TbkApplicationDetail.SetVerRelease(val: word);
begin
  FVerRelease := val;
end;

procedure TbkApplicationDetail.SetVerBuild(val: word);
begin
  FVerBuild := val;
end;

procedure TbkApplicationDetail.SetDetailsURL(val: string);
begin
  FDetailsURL := val;
end;

procedure TbkApplicationDetail.SetDetailsURLText(const Value: string);
begin
  FDetailsURLText := Value;
end;

procedure TbkApplicationDetail.SetSelected(const Value: boolean);
begin
  FSelected := Value;
end;

function TbkAppDetailsList.ApplicationAt(aIndex: integer): TbkApplicationDetail;
begin
  result := TbkApplicationDetail(Self.GetItem(aIndex));
end;

constructor TbkAppDetailsList.Create;
begin
  inherited;
  Self.OwnsObjects := true;
end;

procedure TbkAppDetailsList.LoadFromXml(xmlfile: string);
var
  xmlParser: IXMLDocument;
  ApplicationNode, SubApplicationNode, Rootnode, n: IxmlNode;
  AppList, ComponentList, SubAppList, SubAppComponentList: IXMLNodeList;
  i, j, k: Integer;
  App: TbkApplicationDetail;
  AppComponent: TbkAppComponent;
  SubApp: TbkAppSubApplication;
  ComponentNode: IXMLNode;
begin
  //parse xml list, loading details for each application section
  //this will list the application version, details, and component parts
  Self.Clear;

  xmlParser := CreateXMLDoc;
  try
    xmlParser.PreserveWhiteSpace := false;
    if xmlParser.Load(xmlFile) then
      begin
       //showmessage(xmlParser.Text)
       //load objects
        RootNode := xmlParser.SelectSingleNode('catalog');
        n := FindNode(RootNode, 'applist');
        if Assigned(n) then
          begin
            AppList := FilterNodes(n, 'application');
            for i := 0 to AppList.Length - 1 do
              begin
                ApplicationNode := AppList.Item[i];
                App := TbkApplicationDetail.Create;

                App.AppId := GetNodeTextInt(ApplicationNode, 'appid');
                App.AppName := GetNodeTextStr(ApplicationNode, 'apptitle');
                App.VerMajor := GetNodeTextInt(ApplicationNode, 'major');
                App.VerMinor := GetNodeTextInt(ApplicationNode, 'minor');
                App.VerRelease := GetNodeTextInt(ApplicationNode, 'release');
                App.VerBuild := GetNodeTextInt(ApplicationNode, 'build');
                App.DetailsURL := GetNodeTextStr(ApplicationNode, 'href', '');
                App.DetailsURLText := GetNodeTextStr(ApplicationNode,
                  'hrefdisplay', '');
                App.MinVersion := GetNodeTextStr(ApplicationNode, 'minver', '4.0,4.0');


           //load components
                ComponentList := FilterNodes(ApplicationNode, 'component');
                for j := 0 to ComponentList.Length - 1 do
                  begin
                    ComponentNode := ComponentList.Item[j];
                    AppComponent := TbkAppComponent.Create;
                    AppComponent.Filename := GetNodeTextStr(ComponentNode,
                      'filename');
                    AppComponent.SrcURL := GetNodeTextStr(ComponentNode,
                      'srcname');
                    AppComponent.crc := GetNodeTextInt64(ComponentNode, 'crc');
                    AppComponent.size := GetNodeTextInt64(ComponentNode,
                      'size');
                    AppComponent.execute := GetNodeTextBool(ComponentNode,
                      'execute', false);
                    AppComponent.subdir := GetNodeTextStr(ComponentNode,
                      'subdir', '');
                    AppComponent.param := GetNodeTextStr(ComponentNode, 'param',
                      '');
                    AppComponent.AppMustBeClosed :=
                      GetNodeTextBool(ComponentNode, 'closeapp', false);
                    AppComponent.RestartTiming := GetNodeTextInt(ComponentNode,
                      'restarttiming', -1);
                    AppComponent.UpgradeMethod := GetNodeTextInt(ComponentNode,
                      'upgrademethod', 0);
                    AppComponent.VerMajor := GetNodeTextInt(ComponentNode,
                      'major', 0);
                    AppComponent.VerMinor := GetNodeTextInt(ComponentNode,
                      'minor', 0);
                    AppComponent.VerRelease := GetNodeTextInt(ComponentNode,
                      'release', 0);
                    AppComponent.VerBuild := GetNodeTextInt(ComponentNode,
                      'build', 0);
                    AppComponent.AgeOfFile := GetNodeTextInt(ComponentNode,
                      'ageoffile', 0);
                    AppComponent.DownloadFile := false;

                    App.AppComponents.AddItem(AppComponent);
                  end;
           //load components
                SubAppList := FilterNodes(ApplicationNode, 'subapplication');
                for j := 0 to SubAppList.Length - 1 do
                  begin
                    SubApplicationNode := SubAppList.Item[j];
                    SubApp := TbkAppSubApplication.Create;
                    SubApp.OwnerApp := App;
                    SubApp.AppTitle := GetNodeTextStr(SubApplicationNode,
                      'apptitle');
                    SubApp.AppDirectory := GetNodeTextStr(SubApplicationNode,
                      'appdir', '');
                    SubApp.Manditory := GetNodeTextBool(SubApplicationNode,
                      'manditory', false);

                    SubAppComponentList := FilterNodes(SubApplicationNode,
                      'component');
                    for k := 0 to SubAppComponentList.Length - 1 do
                      begin
                        ComponentNode := SubAppComponentList.Item[k];
                        AppComponent := TbkAppComponent.Create;
                        AppComponent.Filename := GetNodeTextStr(ComponentNode,
                          'filename');
                        AppComponent.SrcURL := GetNodeTextStr(ComponentNode,
                          'srcname');
                        AppComponent.crc := GetNodeTextInt64(ComponentNode,
                          'crc');
                        AppComponent.size := GetNodeTextInt64(ComponentNode,
                          'size');
                        AppComponent.execute := GetNodeTextBool(ComponentNode,
                          'execute', false);
                        AppComponent.subdir := GetNodeTextStr(ComponentNode,
                          'subdir', '');
                        AppComponent.param := GetNodeTextStr(ComponentNode,
                          'param', '');
                        AppComponent.AppMustBeClosed :=
                          GetNodeTextBool(ComponentNode, 'closeapp', false);
                        AppComponent.RestartTiming :=
                          GetNodeTextInt(ComponentNode, 'restarttiming', -1);
                        AppComponent.UpgradeMethod :=
                          GetNodeTextInt(ComponentNode, 'upgrademethod', 0);
                        AppComponent.VerMajor := GetNodeTextInt(ComponentNode,
                          'major', 0);
                        AppComponent.VerMinor := GetNodeTextInt(ComponentNode,
                          'minor', 0);
                        AppComponent.VerRelease := GetNodeTextInt(ComponentNode,
                          'release', 0);
                        AppComponent.VerBuild := GetNodeTextInt(ComponentNode,
                          'build', 0);
                        AppComponent.AgeOfFile := GetNodeTextInt(ComponentNode,
                          'ageoffile', 0);
                        AppComponent.DownloadFile := false;

                        SubApp.AppComponents.AddItem(AppComponent);
                      end;
                    App.AppSubApps.AddItem(SubApp);
                  end;
                AddToList(App);
              end;
          end;
      end
    else
      showmessage('xml error');
  finally
    xmlParser := nil;
  end;
end;

procedure TbkAppDetailsList.AddToList(aApp: TbkApplicationDetail);
begin
  Add(aApp);
end;

constructor TbkApplicationDetail.Create;
begin
  AppComponents := TbkApplicationComponents.Create;
  AppSubApps := TbkApplicationSubApplications.Create;
end;

destructor TbkApplicationDetail.Destroy;
begin
  AppComponents.Free;
  AppSubApps.Free;
  inherited Destroy;
end;

procedure TbkApplicationComponents.AddItem(aComponent: TbkAppComponent);
begin
  Add(aComponent);
end;

function TbkApplicationComponents.ComponentAt(index: integer): TbkAppComponent;
begin
  result := TbkAppComponent(Self.GetItem(index));
end;

constructor TbkApplicationComponents.Create;
begin
  Self.OwnsObjects := true;
end;

procedure TbkUpgFileBasedDownloader.LoadConfig(ConfigStr: string);
begin

end;

{ TbkUpgInstaller }

destructor TbkUpgInstaller.Destroy;
begin

  inherited;
end;

function TbkUpgInstaller.InstallFilesForApp(aAppID: integer): integer;
var
  xmlParser: IXMLDocument;
  FileListName: string;
  RootNode: IXMLNode;
  ComponentNode: IXmlNode;

  ComponentToInstall,
    FileList: IXMLNodeList;

  i: integer;
  FromFilename, ToFilename: string;
  Executable: boolean;
  Param: string;
  ExeParam: string;
  ToPath: string;
  CloseMainApp: boolean;
  ComponentName: string;
  ExecuteTiming: smallint;
  //VerMajor : word;
  //VerMinor : word;
  //VerRelease : word;
  //VerBuild : word;
  //ForceUpdate : boolean;
  //CheckIndividualFiles : boolean;

  AddToList: boolean;
  CloseAppWhenFinished: boolean;
  AfterCopyExecute: boolean;

  s,
    bkInstallParam: string;
  ActualCRC: longword;

  AllComponentsInstalled: boolean;

  function GetXMLFile: Boolean;
  begin
    try
      result := xmlParser.Load(FileListName);
    except
      result := false;
    end;
  end;

begin
  result := 0;
  UpdateObservers('Checking updates...', 1);
  //read <aAppID>.xml to get list of files to upgrade
  //copy each file to subdir under main app dir
  //execute if required
  FileListName := FTempDir + IntToStr(aAppID) + '.xml';

  //crc check the install script to detect tampering
  if ExpectedCRC <> 0 then
    begin
      ActualCRC := crcFileUtils.CalculateCRC(FileListName);
      if ActualCRC <> FExpectedCRC then
        raise EbkupgIntegrityError.Create('Crc failure in xml script');
    end;

  xmlParser := CreateXMLDoc;
  try
    xmlParser.PreserveWhiteSpace := false;
    if GetXMLFile then
      begin

       //showmessage(xmlParser.Text)
       //load objects
        RootNode := xmlParser.SelectSingleNode('files');
       //ForceUpdate := GetNodeText( RootNode, 'forceupdate');
       //CheckIndividualFiles := GetNodeTextStr( RootNode, 'checkindividualfiles');

        FileList := FilterNodes(RootNode, 'component');
       //create temp list to store components to install list
        ComponentToInstall := TXMLNodeList.Create;
        CloseAppWhenFinished := false;
        AfterCopyExecute := false;

       //filter list depending on if can be installed with app open or closed
        for i := 0 to FileList.Length - 1 do
          begin
            ComponentNode := FileList.Item[i];
            ComponentName := GetNodeTextStr(ComponentNode, 'filename');
            CloseMainApp := GetNodeTextBool(ComponentNode, 'closeapp', false);

            AddToList := (FFilter = ifAll) or (FFilter = ifCloseIfRequired);

            if (FFilter = ifUpgradeWithAppClosed) and CloseMainApp then
              AddToList := true;

            if (FFilter = ifUpgradeWithAppOpen) and (not CloseMainApp) then
              AddToList := true;

            if AddToList then
              ComponentToInstall.AddNode(ComponentNode);
          end;

        if (FFilter = ifUpgradeWithAppClosed) and
          (ExtractFileName(Application.ExeName) = InstallExeName) then
          begin
            UpdateObservers('Waiting for app to close', 5);
            repeat
              if WaitforMutex(GetAppIDMutex(AAppID)) then
                break
              else
                begin
              {case MessageDlg( 'Application did not shut down',
                      mtConfirmation, [ mbRetry, mbCancel], 0) of}
                  case Application.MessageBox('Application did not shut down',
                    'Confirm',
                    MB_RETRYCANCEL + MB_ICONINFORMATION)
                    of

                    idCancel:
                      begin
                        Result := uaUserCancelled;
                        Exit;
                      end;
                  end;
                end;
            until False;
        //Give the app a little time to fully close;
            Sleep(2500);
          end;

        for i := 0 to ComponentToInstall.Length - 1 do
          begin
            ComponentNode := ComponentToInstall.Item[i];
            ComponentName := GetNodeTextStr(ComponentNode, 'filename');
            Executable := GetNodeTextBool(ComponentNode, 'execute', false);
            Param := GetNodeTextStr(ComponentNode, 'param', '');
            CloseMainApp := GetNodeTextBool(ComponentNode, 'closeapp', false);
            ExecuteTiming := GetNodeTextInt(ComponentNode, 'restarttiming', 0);
            if Executable and not (CloseMainApp and (FFilter =
              ifCloseIfRequired)) then
              if ExecuteTiming = 2 then
                begin
                  if ExecuteFile(ExeParam, Param, ComponentName) =
                    uaUserCancelled then
                    Exit;
                end;
          end;

        UpdateObservers('Installing updates...', 10);
       //now install
        for i := 0 to ComponentToInstall.Length - 1 do
          begin

            ComponentNode := ComponentToInstall.Item[i];
            ComponentName := GetNodeTextStr(ComponentNode, 'filename');
            Executable := GetNodeTextBool(ComponentNode, 'execute', false);
            Param := GetNodeTextStr(ComponentNode, 'param', '');
            CloseMainApp := GetNodeTextBool(ComponentNode, 'closeapp', false);
            ExecuteTiming := GetNodeTextInt(ComponentNode, 'restarttiming', 0);
            ToPath := GetNodeTextStr(ComponentNode, 'subdir', '');

            if CloseMainApp and (FFilter = ifCloseIfRequired) then
              begin
           //found component that need to close app for set flag and ignore
                CloseAppWhenFinished := true;
              end
            else
              begin
                FromFilename := FTempDir + ComponentName;
                if ToPath <> '' then
                  ToFilename := IncludeTrailingPathDelimiter(ToPath) +
                    ComponentName
                else
                  ToFilename := ExtractFilePath(GetDllPath) + ComponentName;

                s := 'Installing ' + ComponentName;
                if CloseAppWhenFinished then //Begin
                  s := s + ', application will be shut down...';
                UpdateObservers(s, 10 + Round(80 * (i + 1 /
                  (ComponentToInstall.Length))));

                repeat
                  if CopyFile(PChar(FromFilename), PChar(ToFilename), false)
                    then
                    break
                  else
                    begin
                      S := SysErrorMessage(GetLastError);
                      case Application.MessageBox(PChar('Could not file copy to '
                        + ToFilename +
                        #13'[' + S + ']'#13'Please make sure it is not in use'),
                          'Confirm',
                        MB_RETRYCANCEL + MB_ICONERROR)
                      {
                 case MessageDlg('Could not file copy to ' + ToFilename +
                                 #13'[' +  S + ']'#13'Please make sure it is not in use',
                                 mterror, [ mbRetry, mbCancel], 0)
                       }
                      of
                        idRetry: ;
                        idCancel:
                          begin
                            Result := uaUserCancelled;
                              // Should be uaExceptionRaised ??
                            Exit;
                          end;
                      end;
                    end;
                until false;

//           if not CopyFile( PChar( FromFilename), PChar( ToFilename), false) then
//           begin
//            ans := idRetry;
//            while ans = idRetry do
//
//             raise EbkupgFileAccess('could not file copy to ' + ToFilename + ' [' +
//                                           inttostr( GetLastError) + ']');
//           end;

           //add node to say that this component has been installed
                SetNodeTextBool(ComponentNode, 'installed', true);
           //now execute it
                if Executable then
                  begin
                    if ExecuteTiming = 0 then
                      begin
                        if ExecuteFile(ExeParam, Param, ComponentName) =
                          uaUserCancelled then
                          Exit;
                      end
                    else
                      if not AfterCopyExecute then
                        AfterCopyExecute := ExecuteTiming = 1;
                  end;
              end;
          end;

        if AfterCopyExecute then
          for i := 0 to ComponentToInstall.Length - 1 do
            begin
              ComponentNode := ComponentToInstall.Item[i];
              ComponentName := GetNodeTextStr(ComponentNode, 'filename');
              Executable := GetNodeTextBool(ComponentNode, 'execute', false);
              Param := GetNodeTextStr(ComponentNode, 'param', '');
              CloseMainApp := GetNodeTextBool(ComponentNode, 'closeapp', false);
              ExecuteTiming := GetNodeTextInt(ComponentNode, 'restarttiming',
                0);
              if Executable and not (CloseMainApp and (FFilter =
                ifCloseIfRequired)) then
                if ExecuteTiming = 1 then
                  begin
                    if ExecuteFile(ExeParam, Param, ComponentName) =
                      uaUserCancelled then
                      Exit;
                  end;
            end;

        if CloseAppWhenFinished then
          begin
           //launch bkinstall and tell calling app to close
            UpdateObservers('Running ' + InstallExeName + ' ...', 90);
            bkInstallParam := '/aid=' + inttostr(aAppID);
            try
              ShellExecute(0, 'open', PChar(ExtractFilePath(GetDllPath) +
                InstallExeName), PChar(bkInstallParam), nil, sw_NORMAL);
              result := upgConstants.uaCloseCallingApp;
            except
              result := 0;
            end;
          end
        else
          result := upgConstants.uaInstallComplete;

       //check to see if all components are installed and then delete the
       //file, otherwise update it
        UpdateObservers('Cleaning up ...', 95);
        AllComponentsInstalled := true;
        for i := 0 to FileList.Length - 1 do
          begin
            ComponentNode := FileList.Item[i];
            if not GetNodeTextBool(ComponentNode, 'installed', false) then
              AllComponentsInstalled := false;
          end;

        if AllComponentsInstalled then
          DeleteFile(PChar(FileListName))
        else
          begin
         //save updated xml
            xmlParser.Save(FileListName);
          end;

      end;
  finally
    xmlParser := nil;
    ComponentToInstall := nil;
  end;

end;

function TbkUpgInstaller.ExecuteFile(ExeParam: string; Param: string;
  ComponentName: string): integer;
begin
  Result := 0;
  //ask the user to confirm before executing file
  case Application.MessageBox(PChar('About to execute file ' + ComponentName +
    '.  Please confirm that this is ok'), 'Confirm', MB_YESNO + MB_ICONINFORMATION)
    of
    ID_No:
      Result := uaUserCancelled;
    ID_Yes:
      begin
        //interpret param
        ExeParam := '';
        if Param = '%appdir%' then
          ExeParam := ExtractFilePath(GetDllPath);
        if Param = '%instdir%' then
          //inno setup param for install dir
          ExeParam := '/DIR="' + ExtractFilePath(GetDllPath) + '"';
        ShellExecute(0, 'open', PCHar(ExtractFilePath(GetDllPath) +
          ComponentName), PChar(ExeParam), nil, SW_NORMAL);
      end;
  end;
end;

procedure TbkUpgInstaller.SetExpectedCRC(const Value: longword);
begin
  FExpectedCRC := Value;
end;

procedure TbkUpgInstaller.SetFilter(const Value: integer);
begin
  FFilter := Value;
end;

procedure TbkUpgInstaller.SetTempDir(const Value: string);
begin
  FTempDir := Value;
end;

procedure TbkUpgFileBasedDownloader.CancelDownload;
begin
  FCancelled := true;
end;

function TbkUpgFileBasedDownloader.GetFile(FromLocation: string; ToLocation:
  string; ExpectedCRC: LongWord): integer;
//returns 1 when file has been successfully retrieved and verified
var
  ToPath: string;
  aFilename: string;
  ActualCRC: LongWord;
begin
  Result := 0;
  if FUseTempDir then
    ToPath := FTempDir + ToLocation
  else
    ToPath := ToLocation;

  aFilename := ExtractFilename(FromLocation);

  try
    FDownloading := true;
    FCurrentFile := 'Downloading ' + aFilename;

    if CopyFileEx(PChar(FromLocation), PChar(ToPath),
      @CopyFileWithProgressBarCallBack,
      Self, @FCancelled, 0) then
      begin
      //verify crc
        if ExpectedCRC <> 0 then
          begin
            ActualCRC := CRCFileUtils.CalculateCRC(ToPath);
            if (ActualCRC <> ExpectedCRC) then
              begin
                raise EbkupgIntegrityError.Create('CRC invalid');
              end;
          end;
        result := 1
      end
    else
      Application.MessageBox(PChar('An error occured while copying file:' +
        #13#10 +
        SysErrorMessage(GetLastError)),
        'Error while Copying file!',
        MB_OK);
  finally
    FDownloading := false;
  end;

//  UpdateObservers( 'Downloading ' + aFilename, 20);
//  Sleep( 20);
//  UpdateObservers( 'Downloading ' + aFilename, 40);
//  Sleep( 20);
//  UpdateObservers( 'Downloading ' + aFilename, 60);
//  Sleep( 20);
//  UpdateObservers( 'Downloading ' + aFilename, 80);
//  Sleep( 20);
//  UpdateObservers( 'Downloading ' + aFilename, 100);
//  Sleep( 20);

  if result = 1 then
    UpdateObservers('Downloaded ' + aFilename, 100)
  else
    UpdateObservers('Download failed ' + aFilename, -1);
end;

function TbkUpgInstaller.waitforMutex(aMutex: string; const Timeout: Integer):
  Boolean;
var
  Mutex: THandle;
  c: Integer;
begin
    //We can assume if there is no mutex then we are not waiting on anything.
  if Trim(aMutex) = '' then
    Result := true
  else
    begin
      Result := False;
      c := 0;
      repeat
        Mutex := CreateMutex(nil, False {I Don't need to own it},
          PChar(aMutex));
        if (Mutex <> 0) then
          try
            case GetlastError of
              0: Result := true; //Nobody owened one..Done..
              ERROR_ALREADY_EXISTS:
                begin
                  case WaitforSingleObject(Mutex, Timeout) of
                    WAIT_OBJECT_0:
                      begin
                          // unfortunatly BK5 does not Own it (either)
                          // So this does not realy mean anything
                          // Just have to try again..
                        inc(c);
                        if c > (Timeout div 100) then
                          Break
                        else
                          begin
                            Application.ProcessMessages;
                            Sleep(500);
                            Application.ProcessMessages;
                            Sleep(500);
                          end;
                      end; // Mutex Released
                    WAIT_ABANDONED:
                      begin // Or Mutex(handle) closed (More likely senario)
                        Result := True;
                          // Mutex is gone, but still have to wait for the file to be 'free'
                        Sleep(1000);
                      end;
                  end;
                end;
            end; //case
          finally
            CloseHandle(Mutex);
          end;
      until Result;
    end;
end;

{ TbkObserverServer }

constructor TbkObserverServer.Create;
begin
  ObserverCount := 0;
  ObserverList := TObjectList.Create;
  ObserverList.OwnsObjects := false;
end;

destructor TbkObserverServer.Destroy;
begin
  ObserverList.Free;
  inherited;
end;

procedure TbkObserverServer.RegisterObserver(aObserver: TbkUpgObserver);
begin
  ObserverCount := ObserverCount + 1;
  ObserverList.Add(aObserver);
end;

procedure TbkObserverServer.UpdateObservers(aMsg: string; aPosition: integer);
var
  i: integer;
  o: TbkUpgObserver;
begin
  for i := 0 to ObserverList.Count - 1 do
    begin
      o := TbkUpgObserver(ObserverList.Items[i]);
      if Assigned(o.UpdateProgress) then
        o.UpdateProgress(aMsg, aPosition);
    end;
end;

{ TbkUpgHTTPDownloader }

procedure TbkUpgHTTPDownloader.CancelDownload;
begin
  HttpsHandler.Interrupt;
end;

constructor TbkUpgHTTPDownloader.create;
begin
  inherited Create;

  HttpsHandler := TipsHTTPS.Create(nil);

  //link events
  HttpsHandler.OnConnected := HTTPHandlerConnected;
  HttpsHandler.OnConnectionStatus := HTTPHandlerConnectionStatus;
  HttpsHandler.OnHeader := HttpsHandlerHeader;
  HttpsHandler.OnStartTransfer := HttpsHandlerStartTransfer;
  HttpsHandler.OnEndTransfer := HttpsHandlerEndTransfer;
  HttpsHandler.OnTransfer := HttpsHandlerTransfer;
  HttpsHandler.OnError := HttpsHandlerError;

  FHeaders := TStringlist.Create;
end;

destructor TbkUpgHTTPDownloader.destroy;
begin
  FreeAndNil(HTTPSHandler);
  FreeAndNil(FHeaders);
  inherited;
end;

function TbkUpgHTTPDownloader.GetFile(FromLocation, ToLocation: string;
  ExpectedCRC: LongWord): integer;
//parameters:
//   FromURL : URL of file
//   ToLocation : file name and path to save into
//   ExpectedCRC: crc to so can verify file
//returns:
//   1 if download succesful
//purpose:
//   retrieves a file from give URL to dir specified in location
var
  ToPath: string;
  TransferOK: boolean;
  ActualCRC: Longword;
begin
  result := 0;
  FFilename := ExtractFilename(ToLocation);

  if FUseTempDir then
    ToPath := FTempDir + ToLocation
  else
    ToPath := ToLocation;

  UpdateObservers('Downloading ' + FFilename, 0);

  try
    FFileSize := 0;
    LastErrorNo := 0;
    ReasonForFailure := '';
    TransferOK := false;

    //init proxy and firewall settings
    try
      HTTPSHandler.ResetHeaders;
      InitialiseHTTPS;
    except
      on E: Exception do
        begin
          LastErrorNo := -6;
          ReasonForFailure := 'Error during init [' + E.Message + ']';
          Exit;
        end;
    end;

    //retrieve file from specified URL
    try
      HTTPSHandler.Timeout := 3600;
      try
        HTTPSHandler.LocalFile := ToPath; //dir + filename
        FDownloading := true;
        HttpsHandler.Get(FromLocation);
      finally
        FDownloading := false;
      end;

      //crc check the file
      //verify crc
      if ExpectedCRC <> 0 then
        begin
          ActualCRC := CRCFileUtils.CalculateCRC(ToPath);
          if (ActualCRC <> ExpectedCRC) then
            begin
              raise EbkupgIntegrityError.Create('CRC invalid');
            end;
        end;

      //transferred ok and crc verified
      TransferOK := (LastErrorNo = 0);
    except
      //handle specific ip works errors
      on E: EipsHTTPS do
        begin
          ReasonForFailure := 'Error during transfer [' + E.Message + ']';
          LastErrorNo := E.Code;
        end;

      on E: Exception do
        begin
          ReasonForFailure := 'Error during transfer [' + E.Message + ']';
          LastErrorNo := -1;
        end;
    end;

    //no exceptions occured, see what was transferred
    try
      if TransferOK then
        begin
          result := 1;
        end
      else
        if LastErrorNo = 0 then
          begin
            ReasonForFailure := 'Unspecified error occured';
            LastErrorNo := -6;
          end;
    finally
      if LastErrorNo <> 0 then
        DeleteFile(PChar(ToPath));
    end;

  finally
    if result = 1 then
      UpdateObservers('Downloaded ' + FFilename, 100)
    else
      UpdateObservers('Download of ' + FFilename + ' failed - ' +
        ReasonForFailure, -1);
  end;
end;

{procedure TbkUpgHTTPDownloader.SetBasicProxyAuthenticate;
begin
  if FProxyAuthType <> 1 then
    Exit;

  if Trim (FProxyUser) = '' then
    Exit;

  HTTPSHandler.ProxyUser := FProxyUser;
  HTTPSHandler.ProxyPassword := FProxyPwd;
  HTTPSHandler.OtherHeaders := Format ('Proxy-Authorization: %s' + Chr (13) + Chr (10), [HTTPSHandler.ProxyAuthorization]);
  HTTPSHandler.ProxyUser := '';
  HTTPSHandler.ProxyPassword := '';
end;}

procedure TbkUpgHTTPDownloader.InitialiseHTTPS;
var
  xmldoc: OmniXml.IXMLDocument;
  n,
    ProxyNode, FirewallNode: IXmlNode;
  FProxyAuthType: integer;
  FProxyUser,
    FProxyPwd: string;
//  FirewallAuth :
begin
  //set up proxy
  HTTPSHandler.ProxyServer := '*';
  HTTPSHandler.ProxyPort := 0;
  HTTPSHandler.ProxyUser := '';
  HTTPSHandler.ProxyPassword := '';

  //FProxyAuthType := 0;
  FProxyUser := '';
  FProxyPwd := '';

  //set up firewall
  HTTPSHandler.FirewallHost := '';
  HTTPSHandler.FirewallPort := 0;
  HTTPSHandler.FirewallUser := '';
  HTTPSHandler.FirewallPassword := '';
  HTTPSHandler.FirewallType := fwNone;
  //other configuration settings
  HTTPSHandler.Config('useragent=bupgrade/3.0');
  HTTPSHandler.Config('usewininet=true');
  //lUseWinIni := true;
  if FRawConfig <> '' then
    begin
    //customer configuration info provided
    //parse xml string
      xmldoc := CreateXMLDoc;
      try
        xmldoc.PreserveWhiteSpace := false;
        if xmldoc.LoadXML(FRawConfig) then
          begin
            n := FindNode(xmlDoc.FirstChild, 'config');
            if Assigned(n) then
              begin
                if not GetNodeTextBool(n, 'UseWininet', true) then
                  HTTPSHandler.Config('usewininet=false');

          //proxy used?
                ProxyNode := FindNode(n, 'ProxyServer');
                if Assigned(ProxyNode) then
                  begin
                    HttpsHandler.ProxyServer := GetNodeTextStr(n,
                      'ProxyServer');
             // Defaulting the rest allows 'Blanking' the Proxyserver
                    HttpsHandler.ProxyPort := GetNodeTextInt(n, 'ProxyPort', 0);

                    FProxyAuthType := GetNodeTextInt(n, 'ProxyAuthType', 0);
                    FProxyUser := GetNodeTextStr(n, 'ProxyUser', '');
                    FProxyPwd := GetNodeTextStr(n, 'ProxyPwd', '');
                    case FProxyAuthType of
                //note: proxy user and pwd are cleared once the URL is set
                      1:
                        begin //basic
                          HttpsHandler.ProxyUser := FProxyUser;
                          HttpsHandler.ProxyPassword := FProxyPwd;
                        end;
                      2:
                        begin //ntlm
                          HttpsHandler.ProxyServer := Format('*%s*%s',
                            [FProxyUser, FProxyPwd]);
                        end;
                    end;
                  end;

          //firewall used?
                FirewallNode := FindNode(n, 'FwHost');
                if Assigned(FirewallNode) then
                  begin
                    HttpsHandler.FirewallHost := GetNodeTextStr(n, 'FwHost');
                    HttpsHandler.FirewallPort := GetNodeTextInt(n, 'FwPort');
                    HttpsHandler.FirewallUser := GetNodeTextStr(n, 'FwUser');
                    HttpsHandler.FirewallPassword := GetNodeTextStr(n, 'FwPwd');
                    HttpsHandler.FirewallType :=
                      TipshttpsFirewallTypes(GetNodeTextInt(n, 'FwType'));
                  end;
              end;
          end;
      finally
        xmldoc := nil;
      end;
    end;
end;

procedure TbkUpgHTTPDownloader.LoadConfig(ConfigStr: string);
begin
  if ConfigStr <> '' then
    begin
      FRawConfig := ConfigStr;
    end
  else
    FRawConfig := '';
end;

procedure TbkUpgHTTPDownloader.HTTPHandlerConnected(Sender: TObject; StatusCode:
  Integer;
  const Description: string);
begin
  if StatusCode = 0 then
    UpdateObservers('Connected ', 0)
  else
    UpdateObservers('Connection failed - ' + Description, -1);
end;

procedure TbkUpgHTTPDownloader.HTTPHandlerConnectionStatus(Sender: TObject;
  const ConnectionEvent: string; StatusCode: Integer;
  const Description: string);
begin
  UpdateObservers('Connecting ' + Description, 0);
end;

procedure TbkUpgHTTPDownloader.HttpsHandlerHeader(Sender: TObject; const Field,
  Value: string);
begin
  if uppercase(Field) = 'CONTENT-LENGTH' then
    FFileSize := StrToInt64Def(Value, 0);

  if uppercase(field) = 'CONTENT-TYPE' then
    FContentType := Value;
end;

procedure TbkUpgHTTPDownloader.HttpsHandlerEndTransfer(Sender: TObject;
  Direction: Integer);
begin
  if (Direction = 1) and (LastErrorNo = 0) then
    begin
    //UpdateObservers( 'Download complete', 100);
    end;
end;

procedure TbkUpgHTTPDownloader.HttpsHandlerStartTransfer(Sender: TObject;
  Direction: Integer);
begin
  if Direction = 1 then
    begin
      UpdateObservers('Downloading...', 1);
      if Pos('html', FContentType) > 0 then
        FIsHtml := true;
    end;

  FBytesReceived := 0;
  FIsHtml := Pos('html', FContentType) > 0;
end;

procedure TbkUpgHTTPDownloader.HttpsHandlerTransfer(Sender: TObject; Direction,
  BytesTransferred: Integer; Text: string);
begin
  if (Direction = 1) and (FFileSize > 0) and (BytesTransferred <= FFileSize) and
    (not FIsHTML) then
    begin
      FBytesReceived := BytesTransferred;
      UpdateObservers('Downloading ' + FFilename, Trunc(BytesTransferred /
        FFileSize * 100));
    end;
end;

procedure TbkUpgHTTPDownloader.HttpsHandlerError(Sender: TObject; ErrorCode:
  Integer;
  const Description: string);
begin
  LastErrorNo := ErrorCode;
  ReasonForFailure := Description;
end;

{ TbkApplicationSubApplications }

procedure TbkApplicationSubApplications.AddItem(aSubApp: TbkAppSubApplication);
begin
  Add(aSubApp);
end;

constructor TbkApplicationSubApplications.Create;
begin
  Self.OwnsObjects := true;
end;

function TbkApplicationSubApplications.SubApplicationAt(
  index: integer): TbkAppSubApplication;
begin
  result := TbkAppSubApplication(Self.GetItem(index));
end;

{ TbkAppSubApplication }

constructor TbkAppSubApplication.Create;
begin
  AppComponents := TbkApplicationComponents.Create;
end;

destructor TbkAppSubApplication.Destroy;
begin
  AppComponents.Free;
  inherited;
end;

function TbkAppSubApplication.GetAppDirectory: string;
var
  chrResult: array[0..MAX_PATH] of Char;
  wrdReturn: DWORD;
begin
  Result := '';
  if AppDirectory <> '' then
    begin
      Result := AppDirectory;

      if Pos('%WINSYSDIR%', Result) > 0 then
        begin
          wrdReturn := GetSystemDirectory(chrResult, MAX_PATH);
          if wrdReturn <> 0 then
            Result := StringReplace(Result, '%WINSYSDIR%', chrResult,
              [rfReplaceAll])
        end;
      if Pos('%WINDIR%', Result) > 0 then
        begin
          wrdReturn := GetWindowsDirectory(chrResult, MAX_PATH);
          if wrdReturn <> 0 then
            Result := StringReplace(Result, '%WINDIR%', chrResult,
              [rfReplaceAll])
        end;
      wrdReturn := ExpandEnvironmentStrings(PChar(Result), chrResult, MAX_PATH);
      if wrdReturn <> 0 then
        Result := Trim(chrResult);
      if not ForceDirectories(Result) then
        begin
          raise
            EbkupgDirectoryAccess.Create('Directory specified by SubApplicationMainDir (' + AppDirectory + ' = ' + Result + ') does not exist');
          Result := '';
        end;
    end;
end;

function TbkAppSubApplication.GetHasExisting: boolean;
var
  x: Integer;
begin
  Result := false;
  for x := 0 to AppComponents.Count - 1 do
    if TbkAppComponent(AppComponents[x]).IsExisting then
      begin
        Result := true;
        Exit;
      end;
end;

procedure TbkAppSubApplication.SetSelected(const Value: boolean);
begin
  FSelected := Value;
end;

{ TbkDownloadServerApp }

constructor TbkDownloadServerApp.Create(VersionString, Description, DetailsHref: string);
begin
  self.FVersionString := VersionString;
  self.FDescription := Description;
  self.FDetailsHref := DetailsHref;
end;

function TbkDownloadServerApp.GetDetailsURLText: string;
begin
  Result := 'More Info';
end;

begin
end.

