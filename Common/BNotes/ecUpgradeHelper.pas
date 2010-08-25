unit ecUpgradeHelper;

interface

uses
  Windows,ecObj;

function CheckForUpgrade_BNotes( CatalogServer : string; Country : byte; aHandle: Cardinal; WarningNeeded : boolean = true): Byte;

procedure ReportFirstRun(aHandle: HWnd; MyFile: TEcClient);

var
  AttemptedReportBack: boolean = False;

implementation

uses
  SysUtils,Classes,ActiveX,
  Forms, WinUtils, ecGlobalConst,
  ecMessageBoxUtils, upgClientCommon, upgConstants;





function CheckForUpgrade_BNotes( CatalogServer : string; Country : byte; aHandle: Cardinal; WarningNeeded : boolean = true): Byte;
var
  Upgrader : TBkCommonUpgrader;
  Major, Minor, Release, Build : word;
  Action : integer;
  ConfigStr : string;
begin
  Result := upCancel;
  if WarningNeeded then
  begin
    if Application.MessageBox(
                 'You should only check for upgrades if you have been instructed '+
                 'to do so by your Accountant.'#13#13+
                 'If you upgrade before your Accountant, they may no longer be able to open your files.'#13#13+

                 'Do you wish to proceed?', 'Check for updates', MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) <> IDYES then
    begin
      Exit;
    end;
  end;
  //get version info
  WinUtils.GetBuildInfo( Major, Minor, Release, Build);
  //assume direct net connection
  ConfigStr := '';
  Upgrader := TBkCommonUpgrader.Create;
  try
    action := Upgrader.CheckForUpdates( APP_TITLE, aHandle, aidBNotes, Major, Minor, Release, Build, PChar(CatalogServer), Country,
                   PChar( ConfigStr));

    case action of
      uaUnableToLoad : ErrorMessage( 'Unable to load Upgrader');
      uaUserCancelled : Result := upCancel;
      uaInstallPending : begin
        if Application.MessageBox('Updates have been downloaded, do you want to install them now?', 'Update ' + APP_TITLE,
               MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES then
        begin
          //install updates
          case Upgrader.InstallUpdates( APP_TITLE, aHandle, aidBNotes, ifCloseIfRequired, 0) of
            uaCloseCallingApp : Result := upShutdown;
            uaUnableToLoad : ErrorMessage('Load failed');
          end;
        end;
      end;
    end;
  finally
    Upgrader.Free;
  end;
end;

// Should be moved to its own unit
// Same as BK5Win UpgradeHelper


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
       //LogUtil.LogMsg(lmError, UnitName, 'Exception in Reporting First Run. ' + E.Message);
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


procedure ReportFirstRun(aHandle: HWnd; MyFile: TEcClient);
var
  ReportThread : TReportFirstRunThread;
  appID: integer;
  Major, Minor, Release, Build : word;
  ConfigStr : string;
  BConnectCode: string;
  Country: Byte;
  ExtraInfo: TStringList;
begin


  //Only want to try to report back once per time application is open
  //so for example if a books user opens a file for the second time, don't try again
  if AttemptedReportBack then
    Exit;

  if not assigned(MyFile) then
    Exit;  
  try
    ExtraInfo := TStringList.Create;
    try

       appID := aidbNotes;
       BConnectCode := ''; // DontHave one
       Country := MyFile.ecFields.ecCountry;
       //Always need to send practice name, since we might not have practice code
       ExtraInfo.Add(eiPracticeName + '=' + MyFile.ecFields.ecPractice_Name);
       ExtraInfo.Add(eiPracticeCode + '=' + MyFile.ecFields.ecPractice_Code);
       ExtraInfo.Add(eiClientCode + '=' + MyFile.ecFields.ecCode);

       WinUtils.GetBuildInfo(Major, Minor, Release, Build);
       ConfigStr := '';
         (*
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

           *)
       //Report back in seperate thread, so user isn't waiting for a potential timeout
       ReportThread := TReportFirstRunThread.Create(True);
       ReportThread.SetParameters(APP_NAME, aHandle, appID,
         Major, Minor, Release, Build, BConnectCode, Country,
         ExtraInfo.DelimitedText, ConfigStr);
      ReportThread.FreeOnTerminate := True;
      ReportThread.Resume;
    finally
      ExtraInfo.Free;
    end;
  except on E: Exception do
     //LogUtil.LogMsg(lmError, UnitName, 'Exception in Reporting First Run. ' + E.Message);
  end;

  AttemptedReportBack := True; // Only do this once..
end;





end.
