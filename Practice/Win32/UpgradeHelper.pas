unit UpgradeHelper;

interface
uses windows, Classes;

procedure CheckForUpgrade_Offsite(aHandle : HWnd; CatalogServer : string; Country : byte; WarningNeeded : boolean = true);
procedure EditInternetSettings( EditUpdateServer : boolean);
procedure ReportFirstRun(aHandle : HWnd);

procedure WriteInstallUpdatesLock;
procedure ClearInstallUpdatesLock;
function  IsInstallInProgress : boolean;

type
  TReportFirstRunThread = class(TThread)
    private
      FCallingAppName: string;
      FHandle: HWnd;
      FApplicationID: Integer;
      FMarjorVer, FMinorVer, FRelease, FBuild: word;
      FBConnectCode: string;
      FCountry: Byte;
      FExtraIdentInfo: string;
      FConfig: string;
    protected
      procedure Execute; override;
    public
      procedure SetParameters(CallingAppName: string;
        aHandle: THandle; ApplicationID: Integer; caMajorVer, caMinorVer, caRelease,
        caBuild: word; BConnectCode : string; Country : byte; ExtraIdentInfo: string; Config : string);
  end;


implementation
uses
  YesNoDlg, glConst, upgConstants, upgClientCommon, WinUtils, Globals,
  ErrorMoreFrm, Dialogs, DlgSettings, Forms, ipshttps, bkconst, sysUtils,
  LogUtil, ActiveX, StrUtils, iniFiles;

const
  InstallLockFilename = 'install.lck';
  Unitname = 'upgradeHelper';

var
  AttemptedReportBack : boolean;

procedure CheckForUpgrade_Offsite(aHandle : HWnd; CatalogServer : string; Country : byte; WarningNeeded : boolean = true);
var
  Upgrader : TBkCommonUpgrader;
  Major, Minor, Release, Build : word;
  Action : integer;
  ConfigStr : string;
begin
  //offsite version only
  //check for upgrade and install immediately
  if WarningNeeded then
  begin
    if AskYesNo( 'Check for updates',
                 'You should only check for upgrades if you have been instructed '+
                 'to do so by your Accountant.'#13#13+
                 'If you upgrade before your Accountant, they may no longer be able to open your files.'#13#13+                 

                 'Do you wish to proceed?', DLG_YES, 0) <> DLG_YES then
    begin
      Exit;
    end;
  end;

  //get version info
  WinUtils.GetBuildInfo( Major, Minor, Release, Build);
  //construct config str which allows us to pass in all of the proxy/fw settings
    //proxy/firewall
  ConfigStr := upgClientCommon.ConstructConfigXml( INI_BCTimeout,
                                                   INI_BCUseWinInet,
                                                   INI_BCUseProxy,
                                                   INI_BCProxyHost,
                                                   INI_BCProxyPort,
                                                   INI_BCProxyUsername,
                                                   INI_BCProxyPassword,
                                                   INI_BCProxyAuthMethod,
                                                   INI_BCFirewallHost <> '',
                                                   INI_BCFirewallHost,
                                                   INI_BCFirewallPort,
                                                   INI_BCFirewallType,
                                                   INI_BCFirewallUseAuth,
                                                   INI_BCFirewallUsername,
                                                   INI_BCFirewallPassword);

  Upgrader := TBkCommonUpgrader.Create;
  try
    //Upgrader.LoadShadowDll := false;  //turn this off for debugging
    action := Upgrader.CheckForUpdates( PChar(Globals.SHORTAPPNAME), aHandle, aidBK5_Offsite, Major, Minor, Release, Build, PChar(CatalogServer), Country, PChar( ConfigStr));

    case action of
      uaUnableToLoad : HelpfulErrorMsg( 'Unable to load Upgrader', 0);

      uaInstallPending : begin
        //see if can upgrade now ie. no other users in system
        //reload admin system to get current # of users
        if AskYesNo( 'Update ' + shortappname, 'Updates have been downloaded, do you want to install them now?', dlg_yes, 0) = dlg_yes then
        begin
          //install updates
          case Upgrader.InstallUpdates( PChar(ShortAppName), aHandle, aidBK5_Offsite, ifCloseIfRequired, 0) of
            uaCloseCallingApp :
            begin
               Globals.ApplicationMustShutdownForUpdate := true;
            end;
            uaUnableToLoad : ShowMessage('Load failed');
          end;
        end;
      end;
    end;
  finally
    Upgrader.Free;
  end;
end;


procedure EditInternetSettings( EditUpdateServer : boolean);
//uses the existing bconnect form with some minor tweaks to hide the bconnect
//server information
const
   DefaultTag = '(use default)';
var
   TempFireWallType : TipshttpsFirewallTypes;
   UpdateServer : string;
begin
   try
     TempFireWallType := TipshttpsFirewallTypes( INI_BCFirewallType);
   except
     TempFireWallType := TipshttpsFirewallTypes(0);
   end;


   UpdateServer := DefaultTag;


   with TdlgSettings.Create(Application,
                              UpdateServer, 80, '', 0,
                              INI_BCTimeout,
                              INI_BCCustomConfig,
                              INI_BCUseWinInet,
                              INI_BCUseProxy,
                              INI_BCProxyHost,
                              INI_BCProxyPort,
                              INI_BCProxyAuthMethod,
                              INI_BCProxyUsername,
                              INI_BCProxyPassword,
                              INI_BCUseFirewall,
                              INI_BCFirewallHost,
                              INI_BCFirewallPort,
                              TempFireWallType,
                              INI_BCFirewallUseAuth,
                              INI_BCFirewallUsername,
                              INI_BCFirewallPassword) do
    begin
      try
        Caption := 'Configure Internet Settings';

        //hide secure 1
        rnPrimaryPort.Visible := false;
        lblPrimaryPort.Visible := false;
        lblPrimaryHost.Visible := false;
        rePrimaryHost.Visible := false;
        rnPrimaryPort.Visible := false;
        //lblPrimaryHost.Caption := 'Calatog Server';
        //rePrimaryHost.Enabled := EditUpdateServer;
        //rePrimaryHost.MaxLength := 60;
        //rePrimaryHost.Width := 270;

        //hide secure 2
        lblSecondaryHost.Visible := false;
        lblSecondaryPort.Visible := false;
        reSecondaryHost.Visible := false;
        rnSecondaryPort.Visible := false;

        //move timeout up
        pnlBasic.Height := lblTimeout.Top - lblPrimaryHost.Top;
        lblTimeout.Top := lblPrimaryHost.top;
        rnTimeout.Top := rePrimaryHost.Top;
        chkUseCustomConfiguration.Top := lblTimeout.Top;

        ShowModal;
        if SettingsUpdated then
          begin
            
            INI_BCTimeout                     := iniTimeout;
            INI_BCCustomConfig      := iniUseCustomConfiguration;
            INI_BCUseWinInet                  := iniUseWinINet;
            INI_BCUseProxy                    := iniUseProxy;
            INI_BCProxyHost                   := iniProxyHost;
            INI_BCProxyPort                   := iniProxyPort;
            INI_BCProxyAuthMethod             := iniProxyAuthMethod;
            INI_BCProxyUsername               := iniProxyUserName;
            INI_BCProxyPassword               := iniProxyPassword;
            INI_BCUseFirewall                 := iniUseFirewall;
            INI_BCFirewallHost                := iniFirewallHost;
            INI_BCFirewallPort                := iniFirewallPort;
            INI_BCFirewallType                := Ord(iniFirewallType);
            INI_BCFirewallUseAuth             := iniUseFirewallAuthentication;
            INI_BCFirewallUsername            := iniFirewallUserName;
            INI_BCFirewallPassword            := iniFirewallPassword;
          end;
      finally
        Free;
      end;
    end;
end;

//-------------------------------------------------
procedure WriteInstallUpdatesLock;
//write out a file install.lck that contains this computer name
var
  LockFile : TStringList;
begin
    LockFile := TStringList.Create;
    try
      LockFile.Add( WinUtils.ReadComputerName);
      try
        LockFile.SaveToFile( Globals.DataDir + InstallLockFilename);
      except
        On E : exception do
          logUtil.LogError( Unitname, 'Unable to write ' + Globals.DataDir + InstallLockFilename);
      end;
    finally
      LockFile.Free;
    end;
end;


//-------------------------------------------------
procedure ClearInstallUpdatesLock;
//delete install.lck
begin
  DeleteFile( Globals.DataDir + InstallLockFilename);
end;

//-------------------------------------------------
function  IsInstallInProgress : boolean;
//function will only block users on other computers
var
  LockFile : TStringList;
begin
  result := false;
  if BKFileExists( Globals.DataDir + InstallLockFilename) then
  begin
    LockFile := TStringList.Create;
    try
      LockFile.LoadFromFile( Globals.DataDir + InstallLockFilename);
      if LockFile.Count > 0 then
      begin
        if LockFile[0] <> WinUtils.ReadComputerName then
          result := true
        else
        begin
          //was locked for me so clear lock
          ClearInstallUpdatesLock;
        end;
      end;
    finally
      LockFile.Free;
    end;


  end;
end;

procedure ReportFirstRun(aHandle : HWnd);
var
  ReportThread : TReportFirstRunThread;
  appID: integer;
  Major, Minor, Release, Build : word;
  ConfigStr : string;
  BConnectCode: string;
  Country: Byte;
  ExtraInfo: TStringList;


  function NoNeedToReport: Boolean;
  const
       LastVersionKeyName = 'LastReportedAppVersion'; // need to be moved to upgConstants
       MaxTry = 10;
       MinWait = 20 / MinsPerDay;
       FailedCount = 'FailedCount';
       LastFailDateTime =  'LastFailedTime';
       LastFailedError = 'LastFailedError';

  var VersionString: string;
      LastReportedVersion: string;
      AppSection: string;
      IniFile: TiniFile;
  begin
     Result := True;
     //find out if we need to report this run (i.e. has the version changed).
     VersionString := Format('%d.%d.%d.%d',[Major, Minor, Release, Build]);
     if Assigned(AdminSystem) then // Gets done agian later..
        appID := aidBK5_Practice
     else
        appID := aidBK5_Offsite;
     AppSection := Format(IniAppSection,[AppID]);
     IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + bkupgIniFile);
     try
        LastReportedVersion := IniFile.ReadString(AppSection, LastVersionKeyName, '');
        if SameText(VersionString, LastReportedVersion) then
             Exit; // Already done.
        // Should report but...
        if IniFile.ReadInteger(AppSection,FailedCount,0) > MaxTry then
             Exit; // Tried too many times

        if (IniFile.ReadDateTime(AppSection,LastFailDateTime,0) + MinWait) > Now then
            Exit; // Tried too recent

        Result := False; // Should realy report
     finally
        IniFile.Free;
     end;
  end;

begin
  if PRACINI_DoNotReportFirstRun then
    Exit;

  //Only want to try to report back once per time application is open
  //so for example if a books user opens a file for the second time, don't try again
  if AttemptedReportBack then
     Exit;

  WinUtils.GetBuildInfo(Major, Minor, Release, Build);

  if NoNeedToReport then
     Exit;

  try
    ExtraInfo := TStringList.Create;
    try
      if Assigned(AdminSystem) then
      begin
        appID := aidBK5_Practice;
        BConnectCode := AdminSystem.fdFields.fdBankLink_Code;
        Country := AdminSystem.fdFields.fdCountry;
        ExtraInfo.Add(eiPracticeName + '=' + ReplaceText(AdminSystem.fdFields.fdPractice_Name_for_Reports, ',', '_'));
      end
      else
      begin
        appID := aidBK5_Offsite;
        BConnectCode := MyClient.clFields.clBankLink_Code;
        Country := MyClient.clFields.clCountry;
        //Always need to send practice name, since we might not have practice code
        ExtraInfo.Add(eiPracticeName + '=' + ReplaceText(MyClient.clFields.clPractice_Name, ',', '_'));
        ExtraInfo.Add(eiPracticeCode + '=' + MyClient.clFields.clPractice_Code);
        ExtraInfo.Add(eiClientCode + '=' + MyClient.clFields.clCode);
      end;



      ConfigStr := upgClientCommon.ConstructConfigXml( INI_BCTimeout,
                                                     INI_BCUseWinInet,
                                                     INI_BCUseProxy,
                                                     INI_BCProxyHost,
                                                     INI_BCProxyPort,
                                                     INI_BCProxyUsername,
                                                     INI_BCProxyPassword,
                                                     INI_BCProxyAuthMethod,
                                                     INI_BCFirewallHost <> '',
                                                     INI_BCFirewallHost,
                                                     INI_BCFirewallPort,
                                                     INI_BCFirewallType,
                                                     INI_BCFirewallUseAuth,
                                                     INI_BCFirewallUsername,
                                                     INI_BCFirewallPassword);


    //Report back in seperate thread, so user isn't waiting for a potential timeout
      ReportThread := TReportFirstRunThread.Create(True);
      ReportThread.SetParameters(Globals.SHORTAPPNAME, aHandle, appID,
        Major, Minor, Release, Build, BConnectCode, Country,
        ExtraInfo.DelimitedText, ConfigStr);
      ReportThread.FreeOnTerminate := True;
      ReportThread.Resume;
    finally
      ExtraInfo.Free;
    end;
  except on E: Exception do
     LogUtil.LogMsg(lmError, UnitName, 'Exception in Reporting First Run. ' + E.Message);
  end;

  AttemptedReportBack := True;
end;


{ TReportFirstRunThread }

procedure TReportFirstRunThread.Execute;
var
  Upgrader: TBkCommonUpgrader;
begin
  //need to call CoInitialize in new threads that make COM calls.
  //The report first run makes a call to a web service that needs it.
  //Prefer to do it here inside the thread rather than the DLL, since the
  //DLL method may not always be called in a new thread.
  CoInitialize(nil);
  try
    try //wrap whole function in try, since we really don't want exceptions here being shown to user
      Upgrader := TBkCommonUpgrader.Create;
      try
        Upgrader.ReportFirstRun(PChar(FCallingAppName), FHandle, FApplicationID,
          FMarjorVer, FMinorVer, FRelease, FBuild, PChar(FBConnectCode), FCountry,
          PChar(FExtraIdentInfo), PChar(FConfig));
      finally
        Upgrader.Free;
      end;
    except on E: Exception do
       LogUtil.LogMsg(lmError, UnitName, 'Exception in Reporting First Run. ' + E.Message);
    end;
  finally
    CoUninitialize();
  end;
end;

procedure TReportFirstRunThread.SetParameters(CallingAppName: string;
  aHandle: THandle; ApplicationID: Integer; caMajorVer, caMinorVer, caRelease,
  caBuild: word; BConnectCode : string; Country : byte; ExtraIdentInfo: string; Config : string);
begin
  FCallingAppName := CallingAppName;
  FHandle := aHandle;
  FApplicationID := ApplicationID;
  FMarjorVer := caMajorVer;
  FMinorVer := caMinorVer;
  FRelease := caRelease;
  FBuild := caBuild;
  FBConnectCode := BConnectCode;
  FCountry := Country;
  FExtraIdentInfo := ExtraIdentInfo;
  FConfig := Config;
end;

end.
