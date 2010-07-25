unit upgClientCommon;
//------------------------------------------------------------------------------
{
   Title:       Upgrade Client Common routines

   Description: Contains common routines for use by the calling application
                ie BK5 or BNotes

   Author:      Matthew Hopkins  Jan 2006

   Remarks:     All exceptions are handled within the dll

   Last Reviewed :

}
//------------------------------------------------------------------------------
interface
uses windows, classes;

type
  TCheckForUpdates = function ( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar; out InstCRC : LongWord) : LongInt; stdcall;
  TCheckForUpdatesEx = function ( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar; ForceUpdate : boolean; CheckIndividualFiles : boolean; SilentifNothing : boolean; out InstCRC : LongWord) : LongInt; stdcall;
  TInstallUpdates = function ( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; expectedcrc : longword) : LongInt; stdcall;
  TInstallUpdatesEx = function ( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; ForceUpdates : boolean; CheckIndividualFiles : boolean; expectedcrc : longword) : LongInt; stdcall;
  TUpdatesPending = function ( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint ) : boolean; stdCall;
  TReportFirstRun = procedure ( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; BConnectCode : PChar; Country : byte; ExtraIdentInfo : PChar; Config: PChar); stdcall;
  TGetLastExceptionMsg = function : string; stdCall;
  TInitDllApplication = Procedure (ApplicationHandle : HWnd); stdcall;

type
  TBkCommonUpgrader = class      //could make this a singleton???
    constructor Create;
    destructor Destroy; override;
  private
    DllHandle : THandle;
    DllPath : string;
    ShadowDllPath : string;
    CheckForUpdatesProc : TCheckForUpdates;  //need to move this into object
    CheckForUpdatesExProc : TCheckForUpdatesEx;  //need to move this into object
    InstallUpdatesProc : TInstallUpdates;
    InstallUpdatesExProc : TInstallUpdatesEx;
    GetLastExceptionProc : TGetLastExceptionMsg;
    UpdatesPendingProc : TUpdatesPending;
    ReportFirstRunProc : TReportFirstRun;
    InitDllApp : TInitDllApplication;
    FLoadShadowDll: boolean;
    FInstallScriptCRC: longword;
    procedure SetInstallScriptCRC(const Value: longword);
    procedure SetLoadShadowDll(const Value: boolean);

    function LoadUpdateDLL : boolean;
    function UnloadUpdateDLL : boolean;
    function ReloadDll : boolean;
  public
    //tell object whether to load from a shadow copy of the dll rather than
    //the real thing
    property LoadShadowDll : boolean read FLoadShadowDll write SetLoadShadowDll;
    property InstallScriptCRC : longword read FInstallScriptCRC write SetInstallScriptCRC;
    //pass in proxy settings etc
    procedure InitialiseSettings;

    function CheckForUpdates( CallingApp : PChar;
                              aHandle : THandle;
                              ApplicationID : longint;
                              caMajorVer, caMinorVer, caRelease, caBuild : word;
                              CatalogServer : PChar;
                              Country : byte;
                              Config : PChar) : integer;

    function CheckForUpdatesEx ( CallingApp : PChar;
                              aHandle : THandle;
                              ApplicationID : longint;
                              caMajorVer, caMinorVer, caRelease, caBuild : word;
                              CatalogServer : PChar;
                              Country : byte;
                              Config : PChar;
                              ForceUpdate : boolean;
                              CheckIndividualFiles : boolean;
                              SilentifNothing : boolean) : integer;

    function InstallUpdates( CallingApp : PChar;
                             aHandle : THandle;
                             ApplicationID : longint;
                             Filter : longint;
                             ExpectedCRC : longword) : integer;

    function InstallUpdatesEx( CallingApp : PChar;
                             aHandle : THandle;
                             ApplicationID : longint;
                             Filter : longint;
                             ForceUpdate : boolean;
                             CheckIndividualFiles : boolean;
                             ExpectedCRC : longword) : integer;

    function UpdatesPending( CallingAppName : PChar;
                             aHandle : THandle;
                             ApplicationID : longint ) : boolean;

    procedure ReportFirstRun( CallingAppName : PChar;
                              aHandle : THandle;
                              ApplicationID : longint;
                              caMajorVer, caMinorVer, caRelease, caBuild : word;
                              BConnectCode : PChar;
                              Country : byte;
                              ExtraIdentInfo : PChar;
                              Config : PChar);

    function GetLastExceptionMsg : string;
  end;

  function ConstructConfigXml( Timeout : integer;
                               UseWininet : boolean;
                               UseProxy : boolean;
                               ProxyServer : string;
                               ProxyPort : integer;
                               ProxyUser : string;
                               ProxyPassword : string;
                               ProxyAuthType : integer;
                               UseFirewall : boolean;
                               FirewallHost : string;
                               FirewallPort : integer;
                               FirewallType : integer;
                               FirewallUseAuth : boolean;
                               FirewallUser : string;
                               FirewallPassword : string) : string;

implementation
uses
  SysUtils,
  Forms,
  upgConstants,
  omnixml, omniXmlUtils;

const
 DllName = 'bkupgcor.dll';   //expects to find in app dir
 ShadowExtn = '.shadow';

{ TBkCommonUpgrader }

function TBkCommonUpgrader.CheckForUpdates( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar) : integer;
//calls the routine in the dll, the dll will return a status indicator that
//will indicate if the necessary files to carryout an update are available
//the calling application may then choose to trigger the update using InstallUpdates()
var
  ScriptCRC : longword;  //this is returned so that we can detect any tampering
begin
  if LoadUpdateDll then
  begin
    result := CheckForUpdatesProc( CallingApp, aHandle, ApplicationID, caMajorVer, caMinorVer,caRelease, caBuild, CatalogServer, Country, Config, ScriptCRC);
    //see if we need to reload and reissue the request
    if (result = uaReloadUpgrader) and ReloadDll then
    begin
      result := CheckForUpdatesProc( CallingApp, aHandle, ApplicationID, caMajorVer, caMinorVer,caRelease, caBuild, CatalogServer, Country, Config, ScriptCRC);
    end;
  end
  else
    result := uaUnableToLoad;

  if result = uaInstallPending then
    FInstallScriptCRC := ScriptCRC
  else
    FInstallScriptCRC := 0;
end;

function TBkCommonUpgrader.CheckForUpdatesEx( CallingApp : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar; ForceUpdate : boolean; CheckIndividualFiles : boolean; SilentifNothing : boolean) : integer;
//calls the routine in the dll, the dll will return a status indicator that
//will indicate if the necessary files to carryout an update are available
//the calling application may then choose to trigger the update using InstallUpdatesEx()
var
  ScriptCRC : longword;  //this is returned so that we can detect any tampering
begin
  if LoadUpdateDll then
  begin
    result := CheckForUpdatesExProc( CallingApp, aHandle, ApplicationID, caMajorVer, caMinorVer,caRelease, caBuild, CatalogServer, Country, Config, ForceUpdate, CheckIndividualFiles, SilentifNothing, ScriptCRC);
    //see if we need to reload and reissue the request
    if (result = uaReloadUpgrader) and ReloadDll then
    begin
      result := CheckForUpdatesExProc( CallingApp, aHandle, ApplicationID, caMajorVer, caMinorVer,caRelease, caBuild, CatalogServer, Country, Config, ForceUpdate, CheckIndividualFiles, SilentifNothing, ScriptCRC);
    end;
  end
  else
    result := uaUnableToLoad;

  if result = uaInstallPending then
    FInstallScriptCRC := ScriptCRC
  else
    FInstallScriptCRC := 0;
end;

procedure TBkCommonUpgrader.ReportFirstRun(CallingAppName: PChar;
  aHandle: THandle; ApplicationID: Integer; caMajorVer, caMinorVer, caRelease,
  caBuild: word; BConnectCode : PChar; Country : byte; ExtraIdentInfo: PChar; Config : PChar);
begin
  //FLoadShadowDll := False; Could Do But don't fix What is not broken
  if LoadUpdateDLL and (@ReportFirstRunProc <> nil) then
    ReportFirstRunProc( CallingAppName, aHandle, ApplicationID, caMajorVer, caMinorVer, caRelease, caBuild, BConnectCode, Country, ExtraIdentInfo, Config)
end;


constructor TBkCommonUpgrader.Create;
begin
  inherited Create;

  DllPath := ExtractFilePath( Application.ExeName) + DllName;
  ShadowDllPath := ExtractFilePath( Application.ExeName) + DllName + ShadowExtn;
  FLoadShadowDll := true;
  DllHandle := 0;
  GetLastExceptionProc := nil;
end;

destructor TBkCommonUpgrader.Destroy;
begin
  UnloadUpdateDLL;

  inherited;
end;

function TBkCommonUpgrader.GetLastExceptionMsg: string;
begin
  if @GetLastExceptionProc <> nil then
    result := GetLastExceptionProc;
end;

function TBkCommonUpgrader.InstallUpdates(CallingApp: PChar; aHandle: THandle;
  ApplicationID: Integer; Filter : longint; expectedCRC : longword): integer;
//parameters:
//  CallingApp : pchar to title
//  aHandle : handle of main form in app
//  ApplicationId : identifies app so know what to install
//  Filter : integer setting so can decide if what files to install/execute
begin
  if LoadUpdateDll then
    result := InstallUpdatesProc( CallingApp, AHandle, ApplicationID, Filter, ExpectedCRC)
  else
    result := uaUnableToLoad;
end;

function TBkCommonUpgrader.InstallUpdatesEx(CallingApp: PChar; aHandle: THandle;
  ApplicationID : longint; Filter : longint; ForceUpdate : boolean; CheckIndividualFiles : boolean; expectedCRC : longword): integer;
//parameters:
//  CallingApp : pchar to title
//  aHandle : handle of main form in app
//  ApplicationIds : identifies apps so know what to install
//  Filter : integer setting so can decide if what files to install/execute
begin
  if LoadUpdateDll then
    result := InstallUpdatesExProc( CallingApp, AHandle, ApplicationID, Filter, ForceUpdate, CheckIndividualFiles, ExpectedCRC)
  else
    result := uaUnableToLoad;
end;

procedure TBkCommonUpgrader.InitialiseSettings;
begin

end;

function TBkCommonUpgrader.LoadUpdateDLL: boolean;
var
  sSaveDir: string;
begin
  sSavedir := GetCurrentDir;
  try
    SetCurrentDir(ExtractFilePath( Application.ExeName));
    //see if it has already been loaded in this session
    if DllHandle <> 0 then
      result := true
    else
    begin
      if FLoadShadowDll then
      begin
        //create a copy of the dll and load that,
        //this allows us to upgrade the real dll while running the copy
        if FileExists( ShadowDllPath) then
          DeleteFile( PChar(ShadowDllPath));

        CopyFile( PChar( DllPath), PChar( ShadowDllPath), false);
          //set file attributes to hidden
          //  maybe later...

        //now load the dll handle
        DllHandle := LoadLibrary( PChar( ShadowDllPath));
      end
      else
        DllHandle := LoadLibrary( PChar( DllPath));

       if DllHandle <> 0 then
       begin
         @CheckForUpdatesProc := GetProcAddress( DllHandle, 'CheckForUpdates');
         @CheckForUpdatesExProc := GetProcAddress( DllHandle, 'CheckForUpdatesEx');
         @InstallUpdatesProc := GetProcAddress( DllHandle, 'InstallUpdates');
         @InstallUpdatesExProc := GetProcAddress( DllHandle, 'InstallUpdatesEx');
         @GetLastExceptionProc := GetProcAddress( DllHandle, 'GetLastError');
         @UpdatesPendingProc := GetProcAddress( DllHandle, 'FilesWaitingToBeInstalled');
         @InitDllApp := GetProcAddress( DllHandle, 'InitDllApplication'); // not in all Dlls (Yet)
         @ReportFirstRunProc := GetProcAddress( DllHandle, 'ReportFirstRun');
         if (@CheckForUpdatesProc = nil) or
            //(@CheckForUpdatesExProc = nil) or
            (@InstallUpdatesProc = nil) or
            //(@InstallUpdatesExProc = nil) or
            (@UpdatesPendingProc = nil)
         then
           UnloadUpdateDll;  //no point having it if we can't use it
       end;

       result := dllHandle <> 0;

       if result
       And Assigned(InitDllApp) then begin
          if assigned( Application.MainForm) then
             InitDllApp(Application.MainForm.Handle);
       end;

    end;
  finally
    SetCurrentDir(sSaveDir);
  end;
end;

function TBkCommonUpgrader.ReloadDll : boolean;
begin
  //unload existing dll
  UnloadUpdateDll;

  //reload new one
  result := LoadUpdateDll;
end;

procedure TBkCommonUpgrader.SetInstallScriptCRC(const Value: longword);
begin
  FInstallScriptCRC := Value;
end;

procedure TBkCommonUpgrader.SetLoadShadowDll(const Value: boolean);
begin
  FLoadShadowDll := Value;
end;

function TBkCommonUpgrader.UnloadUpdateDLL: boolean;
begin
  if DllHandle <> 0 then
  begin
    FreeLibrary( DllHandle);
    dllHandle := 0;
  end;
  result := true;
end;

function TBkCommonUpgrader.UpdatesPending(CallingAppName: PChar;
  aHandle: THandle; ApplicationID: Integer): boolean;
begin
  if LoadUpdateDLL then
    result := UpdatesPendingProc( CallingAppName, aHandle, ApplicationID)
  else
    result := false;
end;

function ConstructConfigXml( Timeout : integer;
                             UseWininet : boolean;
                             UseProxy : boolean;
                             ProxyServer : string;
                             ProxyPort : integer;
                             ProxyUser : string;
                             ProxyPassword : string;
                             ProxyAuthType : integer;
                             UseFirewall : boolean;
                             FirewallHost : string;
                             FirewallPort : integer;
                             FirewallType : integer;
                             FirewallUseAuth : boolean;
                             FirewallUser : string;
                             FirewallPassword : string) : string;
var
   XMLDoc : IXMLDocument;
   RootNode : IxmlNode;
begin
  XMLDoc := ConstructXMLDocument( 'xml');
  try
    XMLDoc.PreserveWhiteSpace := false;
    RootNode := AppendNode( XMLDoc.FirstChild, 'config');
    SetNodeTextBool( rootnode, 'UseWininet', UseWininet);
    SetNodeTextInt( RootNode, 'Timeout', Timeout);

    if UseProxy then
    begin
       SetNodeTextStr( RootNode, 'ProxyServer', ProxyServer);
       SetNodeTextStr( RootNode, 'ProxyUser', ProxyUser);
       SetNodeTextStr( RootNode, 'ProxyPwd', ProxyPassword);
       SetNodeTextInt( RootNode, 'ProxyPort', ProxyPort);
       SetNodeTextInt( RootNode, 'ProxyAuthType', ProxyAuthType);
    end;
    if UseFirewall then
    begin
       SetNodeTextStr( RootNode, 'FwHost', FirewallHost);
       SetNodeTextInt( RootNode, 'FwPort', FirewallPort);
       SetNodeTextInt( RootNode, 'FwType', FirewallType);
       if FirewallUseAuth then
       begin
          SetNodeTextStr( RootNode, 'FwUser', FirewallUser);
          SetNodeTextStr( RootNode, 'FwPwd', FirewallPassword);
       end;
    end;
    Result := XMLDoc.XML;
  finally
    xmlDoc := nil;
  end;
end;

end.
