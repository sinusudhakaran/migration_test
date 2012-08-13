unit upgMainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, XPMan, ExtCtrls, upgObjects, CheckLst, ipscore,
  ipshttps, upgConstants, upgServiceUpgrader;

type
  TWizardStep = (wsCheckingForUpdates, wsSelectDownload, wsDownloading, wsNoUpdates, wsInstalling, wsFinishing);

type
  TfrmUpdMain = class(TForm)
    pnlHeader: TPanel;
    lbHeaderAction: TLabel;
    pnlButtons: TPanel;
    pnlMain: TPanel;
    btnMain: TButton;
    btnCancel: TButton;
    pnlProgress: TPanel;
    lblCurrentAction: TLabel;
    pbProgress: TProgressBar;
    lblStatus: TLabel;
    lblAnimation: TLabel;
    pnlNoUpdates: TPanel;
    lblNoUpdates: TLabel;
    tmrStart: TTimer;
    tmrMovement: TTimer;
    pnlSelectDownload: TPanel;
    clbUpdates: TCheckListBox;
    lblUpdatesAvailable: TLabel;
    label1: TLabel;
    lblVersion: TLabel;
    pnlInstallProgress: TPanel;
    lblInstallAction: TLabel;
    lblInstallStatus: TLabel;
    pbInstall: TProgressBar;
    procedure btnCancelClick(Sender: TObject);
    procedure clbUpdatesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure clbUpdatesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnMainClick(Sender: TObject);
    procedure tmrStartTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrMovementTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnDownloadStatusUpdate( StatusMsg : string; StatusPosition : integer);
    procedure OnInstallStatusUpdate( StatusMsg : string; StatusPosition : integer);
    procedure clbUpdatesClickCheck(Sender: TObject);
    procedure clbUpdatesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure clbUpdatesMouseLeave(Sender: TObject);
  private
    FApplicationTitle: string;
    FAppMajorVersion: integer;
    FApplicationID: integer;
    FAppMinorVersion: integer;
    FAppBuild: integer;
    FAppRelease: integer;
    FActivationCount : integer;
    FAnimationStep : integer;

    FWizardStep : TWizardStep;

    obsDownloadStatus : TbkUpgObserver;  //observer of status changes when downloading files
    obsInstallStatus : TbkUpgObserver;  //observer of status changes when installing files
    CatalogObj : TbkUpgCatalog;
//    Downloader : TbkUpgFileBasedDownloader;
    Installer : TbkUpgInstaller;
    FResult: integer;
    FFormAction: integer;
    FActionFilter: integer;
    FCatalogServer: string;
    FConfigParam: string;
    FInstallScriptCRC: longword;
    FCatalogCountry: byte;
    FDownloadType: TbkUpgDownloaderType;
    FForceUpdate: boolean;
    FCheckIndividualFiles: boolean;
    FSilentifNothing: boolean;
    FServiceUpgrader: TServiceUpgrader;
    procedure SetCatalogCountry(const Value: byte);
    procedure SetInstallScriptCRC(const Value: longword);
    procedure SetCatalogServer(const Value: string);
    procedure SetConfigParam(const Value: string);
    procedure SetActionFilter(const Value: integer);
    procedure SetFormAction(const Value: integer);
    procedure SetResult(const Value: integer);

    procedure SetApplicationTitle(const Value: string);
    procedure SetAppBuild(const Value: integer);
    procedure SetApplicationID(const Value: integer);
    procedure SetAppMajorVersion(const Value: integer);
    procedure SetAppMinorVersion(const Value: integer);
    procedure SetAppRelease(const Value: integer);

    procedure CheckForUpdatesStart;
    procedure InstallStart;
    procedure SetDownloadType(const Value: TbkUpgDownloaderType);
    function TempDir : string;
    procedure SetForceUpdate(const Value: boolean);
    procedure SetCheckIndividualFiles(const Value: boolean);
    procedure SetSilentifNothing(const Value: boolean);
    procedure CheckForUpdatesStartDownloader;
    function GetUsingDownloadServer: Boolean;
    function DownloadAppFromServer(AppToUpdate: Integer; Version: string; CopyWhenFinished: boolean; var ScriptCRC: Cardinal): integer;
    function GetServiceUpgrader: TServiceUpgrader;
    procedure PresentDownloaderError(CallResult: TDownloadServiceResult; ErrorNumber: string);
  public
    constructor Create (AnOwner : TComponent; ADownloadType : TbkUpgDownloaderType); reintroduce;
    destructor Destroy; override;
    property ApplicationTitle : string read FApplicationTitle write SetApplicationTitle;
    property ApplicationID : integer read FApplicationID write SetApplicationID;
    property AppMajorVersion : integer read FAppMajorVersion write SetAppMajorVersion;
    property AppMinorVersion : integer read FAppMinorVersion write SetAppMinorVersion;
    property AppRelease : integer read FAppRelease write SetAppRelease;
    property AppBuild : integer read FAppBuild write SetAppBuild;
    property FormAction : integer read FFormAction write SetFormAction;
    property ActionFilter : integer read FActionFilter write SetActionFilter;
    property CatalogServer : string read FCatalogServer write SetCatalogServer;
    property CatalogCountry : byte read FCatalogCountry write SetCatalogCountry;
    property ConfigParam : string read FConfigParam write SetConfigParam;
    property DownloadType : TbkUpgDownloaderType read FDownloadType write SetDownloadType;
    property ForceUpdate : boolean read FForceUpdate write SetForceUpdate;
    property CheckIndividualFiles : boolean read FCheckIndividualFiles write SetCheckIndividualFiles;
    property SilentifNothing : boolean read FSilentifNothing write SetSilentifNothing;

    property Result : integer read FResult write SetResult;
    property InstallScriptCRC : longword read FInstallScriptCRC write SetInstallScriptCRC;

    property UsingDownloadServer: Boolean read GetUsingDownloadServer;
    property ServiceUpgrader: TServiceUpgrader read GetServiceUpgrader;
  end;

implementation
uses
  ShellAPi,
  upgClientCommon,
  upgCommon;

{$R *.dfm}
const
  FormTitleStr = '%s Update';
  CheckingStr = '%s is now checking for available updates...';
  InstallingStr = '%s is now installing updates...';
  AppsUsingDownloaderService = [aidBK5_Practice, aidBK5_Offsite, aidBNotes, aidInvoicePlus, aidPayablesPlus];

{ TfrmUpdMain }

procedure TfrmUpdMain.SetApplicationTitle(const Value: string);
begin
  FApplicationTitle := Value;
end;

procedure TfrmUpdMain.FormShow(Sender: TObject);
begin
  Self.caption := Format( FormTitleStr, [ FApplicationTitle]);
  lblCurrentAction.Caption := Format( CheckingStr, [ FApplicationTitle]);
  lblInstallAction.Caption := Format( InstallingStr, [ FApplicationTitle]);

  if FFormAction = acDownloadUpdates then
  begin
    lblVersion.Caption := FApplicationTitle + ' ' + IntToStr( FAppMajorVersion) + '.' +
                         IntToStr( FAppMinorVersion) + '.' +
                         IntToStr( FAppRelease) + '.' +
                         IntToStr( FAppBuild);
  end
  else
  begin
    lblVersion.Caption := FApplicationTitle;
  end;
  lblAnimation.caption := '-';
end;

function TfrmUpdMain.GetServiceUpgrader: TServiceUpgrader;
begin
  if not Assigned(FServiceUpgrader) then
  begin
    FServiceUpgrader := TServiceUpgrader.Create(FConfigParam);
    FServiceUpgrader.StatusObserver := obsDownloadStatus;
  end;
  Result := FServiceUpgrader;
end;

function TfrmUpdMain.GetUsingDownloadServer: Boolean;
begin
  Result := FApplicationID in AppsUsingDownloaderService;
end;

procedure TfrmUpdMain.InstallStart;
begin
  pnlProgress.Visible := false;
  pnlInstallProgress.Align := alClient;
  pnlInstallProgress.Visible := true;

  Installer.RegisterObserver( obsInstallStatus);
  Installer.TempDir := TempDir;
  Installer.Filter := FActionFilter;
//  Installer.ForceUpdate := FForceUpdate;
//  Installer.CheckIndividualFiles := FCheckIndividualFiles;
  Installer.ExpectedCRC := FInstallScriptCRC;
  FResult := Installer.InstallFilesForApp( ApplicationID);

  ModalResult := mrOK;
  //Release; // Should not need this we are running modal..
end;

procedure TfrmUpdMain.SetActionFilter(const Value: integer);
begin
  FActionFilter := Value;
end;

procedure TfrmUpdMain.SetAppBuild(const Value: integer);
begin
  FAppBuild := Value;
end;

procedure TfrmUpdMain.SetApplicationID(const Value: integer);
begin
  FApplicationID := Value;
end;

procedure TfrmUpdMain.SetAppMajorVersion(const Value: integer);
begin
  FAppMajorVersion := Value;
end;

procedure TfrmUpdMain.SetAppMinorVersion(const Value: integer);
begin
  FAppMinorVersion := Value;
end;

procedure TfrmUpdMain.SetAppRelease(const Value: integer);
begin
  FAppRelease := Value;
end;

procedure TfrmUpdMain.SetCatalogCountry(const Value: byte);
begin
  FCatalogCountry := Value;
end;

procedure TfrmUpdMain.SetCatalogServer(const Value: string);
begin
  FCatalogServer := Value;
end;

procedure TfrmUpdMain.SetCheckIndividualFiles(const Value: boolean);
begin
  FCheckIndividualFiles := Value;
end;

procedure TfrmUpdMain.SetConfigParam(const Value: string);
begin
  FConfigParam := Value;
end;

procedure TfrmUpdMain.SetDownloadType(const Value: TbkUpgDownloaderType);
begin
  FDownloadType := Value;
end;

procedure TfrmUpdMain.SetForceUpdate(const Value: boolean);
begin
  FForceUpdate := Value;
end;

procedure TfrmUpdMain.SetFormAction(const Value: integer);
begin
  FFormAction := Value;
end;

procedure TfrmUpdMain.SetInstallScriptCRC(const Value: longword);
begin
  FInstallScriptCRC := Value;
end;

procedure TfrmUpdMain.SetResult(const Value: integer);
begin
  FResult := Value;
end;

procedure TfrmUpdMain.SetSilentifNothing(const Value: boolean);
begin
  FSilentifNothing := Value;
end;

function TfrmUpdMain.TempDir: string;
begin
  Result := ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR;
end;

procedure TfrmUpdMain.CheckForUpdatesStartDownloader;
var
  NewVersionString, NewVersionDescription, DetailsHref: string;
  IsNewVersion: boolean;
  CallResult : TDownloadServiceResult;
  ScriptCRC: Cardinal;
  upgVMajor, upgVMinor, upgVRelease, upgVBuild : word;
begin
  //First See if there's updates to the upgrader
  RetrieveFileVersion( GetDllPath, upgVMajor, upgVMinor, upgVRelease, upgVBuild);
  CallResult := ServiceUpgrader.IsUpdateAvailable(Application.Handle, FApplicationTitle, aidUpgrader, FApplicationID, upgVMajor, upgVMinor, upgVRelease, upgVBuild,
    FCatalogCountry, IsNewVersion, NewVersionString, NewVersionDescription, DetailsHref);
  if CallResult <> dsrSuccess then
  begin
    PresentDownloaderError(CallResult, ServiceUpgrader.LastErrorCode);
    Exit;
  end;

  if IsNewVersion then
  begin
    //do the upgrader
    obsDownloadStatus.UpdateProgress('', 0);
    if DownloadAppFromServer(aidUpgrader, NewVersionString, True, ScriptCRC) = uaInstallPending then
    begin
      FResult := uaReloadUpgrader;
      ModalResult := mrOk;
    end
    else
      FResult := uaReloadUpgrader;
    Exit;
  end;

  IsNewVersion := false;
  NewVersionString := '';
  NewVersionDescription := '';
  CallResult :=  ServiceUpgrader.IsUpdateAvailable(Application.Handle, FApplicationTitle, FApplicationID, FApplicationID, FAppMajorVersion, FAppMinorVersion, FAppRelease, FAppBuild,
    FCatalogCountry, IsNewVersion, NewVersionString, NewVersionDescription, DetailsHref);
  if CallResult = dsrSuccess then
  begin
    if IsNewVersion then
    begin
      FWizardStep := wsSelectDownload;

      pnlSelectDownload.Align := alClient;
      pnlProgress.Visible := false;
      btnMain.Enabled := true;
      pnlSelectDownload.Visible := true;
      obsDownloadStatus.UpdateProgress( '', 0);

      //fill the list box with components
      //ask the user if they want to download the application
      clbUpdates.Clear;
      clbUpdates.Items.AddObject(NewVersionDescription,
        TbkDownloadServerApp.Create(NewVersionString, NewVersionDescription, DetailsHref));
      clbUpdatesClickCheck(clbUpdates);
    end
    else
    begin
      FWizardStep := wsFinishing;

      obsDownloadStatus.UpdateProgress( '', 0);
      pnlNoUpdates.Align := alClient;
      pnlProgress.Visible := false;
      pnlNoUpdates.Visible := True;
      btnMain.Caption := 'Finish';
      btnMain.Enabled := true;
      btnCancel.Enabled := false;
      if SilentifNothing then
      begin
        ModalResult := mrOK;
        Close;
      end;
    end;
  end
  else
    PresentDownloaderError(CallResult, ServiceUpgrader.LastErrorCode);
end;

procedure TfrmUpdMain.CheckForUpdatesStart;
var
  DetailText: string;
  href: string;
  ApplicationDetails : TbkApplicationDetail;
  SubApplication : TbkAppSubApplication;
  upgVMajor, upgVMinor, upgVRelease, upgVBuild : word;
  I: Integer;
begin
  if UsingDownloadServer then
  begin
    CheckForUpdatesStartDownloader;
    Exit;
  end;

  //check for updates
  //first check to see if this is the latest version of the updater
  //may need to update upgstub.exe and bkupgcor.dll
  //restart if needed

  FWizardStep := wsCheckingForUpdates;

  //configure the catalog object
  CatalogObj.CatalogServer := Self.FCatalogServer;
  CatalogObj.CatalogCountry := Self.FCatalogCountry;

  CatalogObj.Initialise;
  CatalogObj.StatusObserver := obsDownloadStatus;
  CatalogObj.LoadDownloaderConfig( Self.FConfigParam);

  //retrieve catalog
  if CatalogObj.RetrieveCatalog then
  begin
    //check for updates to upgrader
    //get current version of upgrader
    RetrieveFileVersion( GetDllPath, upgVMajor, upgVMinor, upgVRelease, upgVBuild);

    CatalogObj.ForceUpdate := False;
    CatalogObj.CheckIndividualFiles := False;
    if CatalogObj.UpdateAvailable( aidUpgrader, upgVMajor, upgVMinor, upgVRelease, upgVBuild, DetailText, href) then
    begin
      CatalogObj.StatusObserver.UpdateProgress( '', 0);
      //ShowMessage( 'Update available for ' + detailText + '  see ' + href + ' for details');

      //download latest version and notify restart
      if CatalogObj.DownloadUpdatesToApp( aidUpgrader, true) = upgConstants.uaInstallPending then
      begin
        FResult := upgConstants.uaReloadUpgrader;
        ModalResult := mrOk;
      end
      else
          FResult := upgConstants.uaReloadUpgrader;
      Exit;
    end;

    CatalogObj.ForceUpdate := Self.FForceUpdate;
    CatalogObj.CheckIndividualFiles := Self.FCheckIndividualFiles;
    //now check for updates to requested applicatoin
    if CatalogObj.UpdateAvailable( Self.ApplicationID, AppMajorVersion, AppMinorVersion, AppRelease, AppBuild, DetailText, href) then
    begin
      FWizardStep := wsSelectDownload;

      pnlSelectDownload.Align := alClient;
      pnlProgress.Visible := false;
      btnMain.Enabled := true;
      pnlSelectDownload.Visible := true;
      CatalogObj.StatusObserver.UpdateProgress( '', 0);

      //fill the list box with components
      //ask the user if they want to download the application
      clbUpdates.Clear;
      ApplicationDetails := CatalogObj.FindApplication( ApplicationID);
      clbUpdates.Items.AddObject( ApplicationDetails.AppName, ApplicationDetails );
      for I := 0 to ApplicationDetails.AppSubApps.Count - 1 do
        begin
          SubApplication := TbkAppSubApplication(ApplicationDetails.AppSubApps[i]);
          clbUpdates.Items.AddObject( SubApplication.AppTitle, SubApplication );
        end;
      clbUpdatesClickCheck(clbUpdates);
    end
    else
    begin
      FWizardStep := wsFinishing;

      CatalogObj.StatusObserver.UpdateProgress( '', 0);
      pnlNoUpdates.Align := alClient;
      pnlProgress.Visible := false;
      pnlNoUpdates.Visible := True;
      btnMain.Caption := 'Finish';
      btnMain.Enabled := true;
      btnCancel.Enabled := false;
      if SilentifNothing then
        begin
          ModalResult := mrOK;
          Close;
        end;
    end;
  end
  else
  begin
    //catalog not retrieved

  end;
end;   

procedure TfrmUpdMain.btnCancelClick(Sender: TObject);
begin
  if CatalogObj.Downloader.DownloadInProgress then
  begin
    //need to cancel download
    CatalogObj.Downloader.CancelDownload;
    FResult := uaUserCancelled;
  end;
  if Assigned(FServiceUpgrader) and FServiceUpgrader.OperationInProgress then
  begin
    FServiceUpgrader.CancelOperation;
    FResult := uaUserCancelled;
  end;
end;

procedure TfrmUpdMain.btnMainClick(Sender: TObject);
var
  i : integer;
  SelectCount : integer;
  Item: TObject;
  DownloadApp: TbkDownloadServerApp;
  DownloaderScriptCRC: Cardinal;
begin
  if FWizardStep = wsSelectDownload then
  begin
    SelectCount := 0;
    btnMain.Enabled := false;

    //download updates
    for i := 0 to clbUpdates.Items.Count - 1 do
    begin
      if clbUpdates.Checked[i] then
      begin
        Item := clbUpdates.Items.Objects[i];
        if Item is TbkApplicationDetail then
        begin
          TbkApplicationDetail(Item).Selected := true;
          inc(SelectCount);
        end
        else if Item is TbkAppSubApplication then
        begin
          TbkAppSubApplication(Item).Selected := true;
          inc(SelectCount);
        end
        else if Item is TbkDownloadServerApp then
        begin
          DownloadApp := TbkDownloadServerApp(item);
          pnlSelectDownload.Visible := False;
          pnlProgress.Visible := true;
          lblCurrentAction.Caption := 'Downloading selected updates';
          FWizardStep := wsDownloading;

          FResult := DownloadAppFromServer(FApplicationID, DownloadApp.VersionString, False, DownloaderScriptCRC);
          if FResult = uaDownloadFailed then
            ModalResult := mrNone;

          if FResult = uaInstallPending then
            FInstallScriptCRC := DownloaderScriptCRC;
          Exit;
        end;
      end;
    end;

    if SelectCount > 0 then
    begin
      pnlSelectDownload.Visible := False;
      pnlProgress.Visible := true;
      lblCurrentAction.Caption := 'Downloading selected updates';
      FWizardStep := wsDownloading;

      CatalogObj.ForceUpdate := ForceUpdate;
      CatalogObj.CheckIndividualFiles := CheckIndividualFiles;

      //download application if selected
      if CatalogObj.FindApplication( ApplicationID).Selected then
      begin
        FResult := CatalogObj.DownloadUpdatesToApp( ApplicationID);
        if FResult = uaDownloadFailed then
          ModalResult := mrNone;

        if FResult = uaInstallPending then
          FInstallScriptCRC := CatalogObj.InstallScriptCRC;

        {//in some cases the upgrade and auto install, ie if there is no need
        //to check for concurrent use
        if (FResult = uaInstallPending) and  FAutoInstall then
           InstallStart;}
      end;
    end
    else
    begin
      ShowMessage('Please select the updates that you wish to download');
      btnMain.Enabled := true;
      ModalResult := mrNone;
    end;

    //either failure or nothing selected
    if ModalResult = mrNone then
    begin
      btnCancel.Caption := 'Close';
    end;
  end
  else if FWizardStep = wsFinishing then
    FResult := uaNothingPending;
end;

function TfrmUpdMain.DownloadAppFromServer(AppToUpdate: Integer; Version: string; CopyWhenFinished: boolean; var ScriptCRC: Cardinal): integer;
var
  ResultStatus: TDownloadServiceResult;
  OldVersionString: string;
begin
  //Download the XML File
  OldVersionString := Format('%d.%d.%d.%d',[FAppMajorVersion, FAppMinorVersion, FAppRelease, FAppBuild]);
  ResultStatus := ServiceUpgrader.DownloadUpdateXML(Application.Handle, FApplicationTitle, AppToUpdate, FApplicationID, Version, FCatalogCountry, OldVersionString, ScriptCRC);
  if ResultStatus = dsrSuccess then
  begin
    ResultStatus := ServiceUpgrader.DownloadFilesFromXML(AppToUpdate, CopyWhenFinished);
    if ResultStatus = dsrSuccess then
      Result := uaInstallPending
    else
    begin
      PresentDownloaderError(ResultStatus, ServiceUpgrader.LastErrorCode);
      Result := uaDownloadFailed;
    end;
  end
  else
  begin
    PresentDownloaderError(ResultStatus, ServiceUpgrader.LastErrorCode);
    Result := uaDownloadFailed;
  end;
end;

procedure TfrmUpdMain.clbUpdatesClickCheck(Sender: TObject);
var
  I: Integer;
begin
  if not UsingDownloadServer then
  begin
    for I := 0 to clbUpdates.Count - 1 do
      if clbUpdates.Items.Objects[i] is TbkApplicationDetail then
        TbkApplicationDetail(clbUpdates.Items.Objects[i]).Selected := clbUpdates.Checked[i]
      else
        if (clbUpdates.Items.Objects[i] is TbkAppSubApplication) then
        if (i <> clbUpdates.itemindex) then
          begin
            clbUpdates.Checked[i] := TbkAppSubApplication(clbUpdates.Items.Objects[i]).OwnerApp.Selected and (TbkAppSubApplication(clbUpdates.Items.Objects[i]).HasExisting or TbkAppSubApplication(clbUpdates.Items.Objects[i]).Manditory or clbUpdates.Checked[i]);
            clbUpdates.ItemEnabled[i] := TbkAppSubApplication(clbUpdates.Items.Objects[i]).OwnerApp.Selected and not (TbkAppSubApplication(clbUpdates.Items.Objects[i]).HasExisting or TbkAppSubApplication(clbUpdates.Items.Objects[i]).Manditory);
          end
        else
          if (i = clbUpdates.itemindex) and (TbkAppSubApplication(clbUpdates.Items.Objects[i]).Manditory or TbkAppSubApplication(clbUpdates.Items.Objects[i]).HasExisting) then
            clbUpdates.Checked[i] := true;
  end;
end;

procedure TfrmUpdMain.clbUpdatesDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  item: TObject;
  cb : TCheckListBox;
  hrefWidth : integer;
  App : TbkApplicationDetail;
  SubApp : TbkAppSubApplication;
  DownloadApp: TbkDownloadServerApp;
begin
  cb := TCheckListBox( Control);
  cb.Canvas.Brush.Color := clWindow;
  cb.Canvas.FillRect( Rect);
  item := cb.Items.Objects[index];
  if item is TbkApplicationDetail then
  begin
    App := TbkApplicationDetail(item);
    //draw name
    cb.Canvas.Font.Color := clblack;
    if ForceUpdate then
      cb.Canvas.textout( rect.left + 2 ,rect.top + 5, App.AppName + ' (' + Format ('%d.%d.%d.%d', [App.VerMajor, App.VerMinor, App.VerRelease, App.VerBuild]) + ')')
    else
      cb.Canvas.textout( rect.left + 2 ,rect.top + 5, App.AppName);
    //draw href
    cb.Canvas.Font.Color := clblue;
    hrefWidth := cb.Canvas.TextWidth( App.DetailsURLText);
    cb.Canvas.TextOut( rect.Right - hrefWidth -5, rect.top + 5, App.DetailsURLText);
    //draw underline
    cb.Canvas.Pen.Style := psDot;
    cb.Canvas.Polyline( [Point( Rect.Right - hrefWidth - 5, rect.Bottom - 8), Point( Rect.Right - 5, rect.bottom - 8)]);;
    cb.Canvas.Pen.Style := psSolid;
  end
  else if item is TbkAppSubApplication then
  begin
    SubApp :=TbkAppSubApplication(item);
    //draw name
    cb.Canvas.Font.Color := clblack;
    if SubApp.Manditory then
      cb.Canvas.textout( rect.left + 2 ,rect.top + 5, SubApp.AppTitle + ' (Mandatory)')
    else if SubApp.HasExisting then
      cb.Canvas.textout( rect.left + 2 ,rect.top + 5, SubApp.AppTitle + ' (Existing)')
    else
      cb.Canvas.textout( rect.left + 2 ,rect.top + 5, SubApp.AppTitle + ' (Optional)');
  end
  else if item is TbkDownloadServerApp then
  begin
    DownloadApp := TbkDownloadServerApp(item);
    cb.Canvas.Font.Color := clBlack;
    cb.Canvas.TextOut(rect.left + 2, rect.Top + 5, DownloadApp.Description +'(' + DownloadApp.VersionString + ')');
    //draw href
    if DownloadApp.DetailsHref <> '' then
    begin
      cb.Canvas.Font.Color := clblue;
      hrefWidth := cb.Canvas.TextWidth(DownloadApp.DetailsURLText);
      cb.Canvas.TextOut(rect.Right - hrefWidth -5, rect.top + 5, DownloadApp.DetailsURLText);
    end
    else
      hrefWidth := 0;
    //draw underline
    cb.Canvas.Pen.Style := psDot;
    cb.Canvas.Polyline([Point( Rect.Right - hrefWidth - 5, rect.Bottom - 8), Point( Rect.Right - 5, rect.bottom - 8)]);;
    cb.Canvas.Pen.Style := psSolid;
  end;
end;

procedure TfrmUpdMain.clbUpdatesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  index : integer;
  App : TbkApplicationDetail;
  hrefWidth : integer;
  DownloadApp: TbkDownloadServerApp;
  item: TObject;
  procedure LaunchHref(URL: string; Name: string);
  var
    FullURL : string;
  begin
    if Pos( 'http', URL) = -1 then
      FullURL := 'http:\\' + URL
    else
      FullURL := URL;
    if FDownloadType = dtHTTP then
      ShellExecute(0, 'open', PChar(FullURL), nil, nil, SW_NORMAL)
    else
      ShowMessage ('There are no on-line details for ' + Name);
  end;

begin
  if Button = mbLeft then
  begin
    index := clbUpdates.ItemAtPos( Point(x,y), true);
    //see if mouse is within are of href text
    if (index <> -1) then
    begin
      item := clbUpdates.Items.Objects[index];
      if (item is TbkApplicationDetail) then
      begin
        App := TbkApplicationDetail(item);
        hrefWidth := clbUpdates.Canvas.TextWidth( App.DetailsURLText);

        if (x > (clbUpdates.Width - hrefWidth - 10)) then
        begin
          LaunchHref(App.DetailsURL, App.AppName);
        end;
      end
      else if item is TbkDownloadServerApp then
      begin
        DownloadApp := TbkDownloadServerApp(item);
        if DownloadApp.DetailsHref <> '' then
        begin
          hrefWidth := clbUpdates.Canvas.TextWidth(DownloadApp.DetailsURLText);

          if (x > (clbUpdates.Width - hrefWidth - 10)) then
          begin
            LaunchHref(DownloadApp.DetailsHref, DownloadApp.Description);
          end;
        end;
      end;

    end;

    //label1.Caption := 'x ' + inttostr(x) + ' y ' + inttostr(y) + ' index ' + inttostr( index);
  end;
end;

procedure TfrmUpdMain.clbUpdatesMouseLeave(Sender: TObject);
begin
  Screen.Cursor := crDefault; //Just in case it's set to hand point and not set back
end;

procedure TfrmUpdMain.clbUpdatesMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  index : integer;
  App : TbkApplicationDetail;
  hrefWidth : integer;
  DownloadApp: TbkDownloadServerApp;
  item: TObject;
begin
  index := clbUpdates.ItemAtPos( Point(x,y), true);
  //see if mouse is within are of href text
  if (index <> -1) then
  begin
    item := clbUpdates.Items.Objects[index];
    if (item is TbkApplicationDetail) then
    begin
      App := TbkApplicationDetail(item);
      hrefWidth := clbUpdates.Canvas.TextWidth( App.DetailsURLText);

      if (x > (clbUpdates.Width - hrefWidth - 10)) then
      begin
        Screen.Cursor := crHandPoint;
        exit;
      end;
    end
    else if item is TbkDownloadServerApp then
    begin
      DownloadApp := TbkDownloadServerApp(item);
      if DownloadApp.DetailsHref <> '' then
      begin
        hrefWidth := clbUpdates.Canvas.TextWidth(DownloadApp.DetailsURLText);

        if (x > (clbUpdates.Width - hrefWidth - 10)) then
        begin
          Screen.Cursor := crHandPoint;
          exit;
        end;
      end;
    end;
  end;

  //if we're still here, set it back to normal
  Screen.Cursor := crDefault;
end;

constructor TfrmUpdMain.Create(AnOwner: TComponent;
  ADownloadType: TbkUpgDownloaderType);
begin
  inherited Create (AnOwner);
  FAnimationStep := 0;
  FActivationCount := 0;
  FApplicationID := 0;
  FActionFilter := 0;
  FInstallScriptCRC := 0;
  FDownloadType := ADownloadType;

  FResult := upgConstants.uaUnableToLoad;

  obsDownloadStatus := TbkUpgObserver.Create;
  obsDownloadStatus.UpdateProgress := OnDownloadStatusUpdate;
  obsInstallStatus := TbkUpgObserver.Create;
  obsInstallStatus.UpdateProgress := OnInstallStatusUpdate;

  CatalogObj := TbkUpgCatalog.Create (FDownloadType);
  CatalogObj.TempDir := TempDir;
  //CatalogObj.StatusObserver := obsDownloadStatus;

//  Downloader := TbkUpgFileBasedDownloader.Create;
//  Downloader.RegisterObserver( obsDownloadStatus);
  Installer := TbkUpgInstaller.Create;
end;

destructor TfrmUpdMain.Destroy;
begin
  if Assigned (obsDownloadStatus) then
    FreeAndNil (obsDownloadStatus);
  if Assigned (obsInstallStatus) then
    FreeAndNil (obsInstallStatus);
  if Assigned (CatalogObj) then
    FreeAndNil (CatalogObj);
//  if Assigned (Downloader) then
//    FreeAndNil (Downloader);
  if Assigned (Installer) then
    FreeAndNil (Installer);
  if Assigned (FServiceUpgrader) then //If Assigned check not needed as Free checks anyway
    FreeAndNil(FServiceUpgrader);
  
  inherited;
end;

procedure TfrmUpdMain.PresentDownloaderError(CallResult: TDownloadServiceResult; ErrorNumber: string);
var
  ErrorMsg: string;
begin
  if SilentifNothing then
  begin
    ModalResult := mrCancel;
    Close;
  end
  else
  begin
    FWizardStep := wsFinishing;
    FResult := uaDownloadFailed;
    if CallResult <> dsrCancelled then
      ErrorMsg := Format('Could not check for updates. Please try again later, or contact support if the problem persists [%s].', [ErrorNumber])
    else
      ErrorMsg := 'User Cancelled.';
    obsDownloadStatus.UpdateProgress(ErrorMsg, 0);
    tmrMovement.Enabled := false;
    btnMain.Caption := 'Finish';
    btnMain.Enabled := true;
    btnCancel.Enabled := false;
  end;
end;

procedure TfrmUpdMain.tmrMovementTimer(Sender: TObject);
begin
  FAnimationStep := FAnimationStep + 1;
  if FAnimationStep > 3 then
    FAnimationStep := 0;

  case FAnimationStep of
  0 : lblAnimation.Caption := '|';
  1 : lblAnimation.Caption := '/';
  2 : lblAnimation.Caption := '-';
  3 : lblAnimation.Caption := '\';
  end;
end;

procedure TfrmUpdMain.tmrStartTimer(Sender: TObject);
begin
  tmrStart.Enabled := false;
  case FFormAction of
    acDownloadUpdates : CheckForUpdatesStart;
    acInstallUpdates : InstallStart;
  end;
end;

procedure TfrmUpdMain.FormCreate(Sender: TObject);
begin
  pnlSelectDownload.BevelOuter := bvNone;
  pnlProgress.BevelOuter := bvNone;
  pnlProgress.Align := alClient;

  clbUpdates.Clear;
end;

procedure TfrmUpdMain.OnDownloadStatusUpdate(StatusMsg: string;
  StatusPosition: integer);
//note:
// -1 will stop animation
begin
   if (StatusPosition >= 0) and (StatusPosition <= 100)  then
     pbProgress.Position := StatusPosition
   else
     pbProgress.Position := 0;

   lblStatus.Caption := StatusMsg;
   tmrMovement.Enabled :=(StatusPosition >= 0) and (StatusPosition < 100);
end;

procedure TfrmUpdMain.OnInstallStatusUpdate(StatusMsg: string;
  StatusPosition: integer);
begin
   pbInstall.Position := StatusPosition;
   lblInstallStatus.Caption := StatusMsg;
   Refresh;
end;

end.
