unit upgMain;
//------------------------------------------------------------------------------
{
   Title:       Main unit for upgrader dll

   Description: The unit contains the functions for all of the external calls
                supported by the dll

   Author:      Matthew Hopkins  Feb 2006

   Remarks:
}
//------------------------------------------------------------------------------

interface
uses
  SysUtils, dialogs, Windows,upgMainFrm;

 function CheckForUpdates( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar; out InstCRC : longword) : LongInt; stdcall;
 function CheckForUpdatesEx(  CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; CatalogServer : PChar; Country : byte; Config : PChar; ForceUpdate : boolean; CheckIndividualFiles : boolean; SilentifNothing : boolean; out InstCRC : LongWord) : LongInt; stdcall;
 function FilesWaitingToBeInstalled( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint ) : boolean; stdCall;
 function InstallUpdates( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; ExpectedCRC : longword) : LongInt; stdcall;
 function InstallUpdatesEx( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; ForceUpdate : boolean; CheckIndividualFiles : boolean; ExpectedCRC : longword) : LongInt; stdcall;
 procedure InitDllApplication( ApplicationHandle: HWnd ); stdcall;
 procedure ReportFirstRun( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer, caRelease, caBuild : word; BConnectCode : PChar; Country : byte; ExtraIdentInfo : PChar; Config : PChar); stdcall;
 //function GetLastError : PChar;

implementation

uses
  Controls, Forms,  upgConstants, upgExceptions, ipshttps,
  Classes, upgDownloaderService, IniFiles, upgCommon, upgServiceUpgrader;

// export this procedure and call it after loading the DLL
procedure InitDllApplication( ApplicationHandle: HWnd );
begin
   // This sould only ocurr if this is in the Dll...
   if ApplicationHandle <> 0 Then begin
      Application.Handle := ApplicationHandle;
   end;
end;

function MakeUpdateTempFilename( aAppID : integer) : string;
begin
  result := inttostr( aAppID) + '.xml';
end;

function CheckForUpdates( CallingAppName : PChar;  aHandle : THandle;
                          ApplicationID : longint;
                          caMajorVer, caMinorVer, caRelease, caBuild : word;
                          CatalogServer : PChar; Country : byte;
                          Config : PChar;
                          out InstCRC : longword) : LongInt; stdcall;
//parameters:
//  CallingAppName  : text description of app to update
//  aHandle         : handle for main form so can associate any new windows
//  ApplicationID   : id so know which app we are updating
//  Version information : contains version of calling app
//  CatalogServer   : location of catalog server, expected to be an http server
//  Country         : country code for install 0 = nz 1 = au
//  Config          : optional string containing proxy/firewall config settings
//  InstCRC         : crc for the install script, used to detect tampering
//
//returns:
//  result : integer representing upgrade action  see upgConstants.pas
//
//purpose:
//  Does the downloading of the latest catalog file, checked for later versions
//  and downloads the updates to a temp folder if requested
//
//notes:
//  Writes a file <appid>.xml which contains a list of the files that are
//  included in the update.
begin
  Result := CheckForUpdatesEx (CallingAppName,aHandle,ApplicationID,
                          caMajorVer, caMinorVer, caRelease, caBuild,
                          CatalogServer,Country,Config, false, false, false, InstCRC);
end;

function CheckForUpdatesEx( CallingAppName : PChar;  aHandle : THandle;
                          ApplicationID : longint;
                          caMajorVer, caMinorVer, caRelease, caBuild : word;
                          CatalogServer : PChar; Country : byte;
                          Config : PChar;
                          ForceUpdate : boolean;
                          CheckIndividualFiles : boolean;
                          SilentifNothing : boolean; 
                          out InstCRC : longword) : LongInt; stdcall;
//parameters:
//  CallingAppName  : text description of app to update
//  aHandle         : handle for main form so can associate any new windows
//  ApplicationID   : id so know which app we are updating
//  Version information : contains version of calling app
//  CatalogServer   : location of catalog server, expected to be an http server
//  Country         : country code for install 0 = nz 1 = au
//  Config          : optional string containing proxy/firewall config settings
//  ForceUpdate     : Force the Update to be found
//  CheckIndividualFiles : For files with update methods specified, check them to determine if an update is available
//  SilentifNothing : If there is no update then don't wait on the finish button
//  InstCRC         : crc for the install script, used to detect tampering
//
//returns:
//  result : integer representing upgrade action  see upgConstants.pas
//
//purpose:
//  Does the downloading of the latest catalog file, checked for later versions
//  and downloads the updates to a temp folder if requested
//
//notes:
//  Writes a file <appid>.xml which contains a list of the files that are
//  included in the update.
var
  aForm : TfrmUpdMain;
  sFilename : string;
  sTempDir : string;
  sSaveDir : string;
  aDownloadType : TbkUpgDownloaderType;
begin
  InstCRC := 0;
  sSaveDir := GetCurrentDir;
  aDownloadType := dtHTTP;
  if Country = coInternal then
    aDownloadType := dtFILE;
  //delete existing upgrade xml files
  try
    sTempDir :=  ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR;
    SetCurrentDir(ExtractFilePath( Application.ExeName));
    ForceDirectories(sTempDir);
    sFilename := sTempDir + MakeUpdateTempFilename( ApplicationID);
    if FileExists( sFilename) then
      if not DeleteFile( PChar(sFilename)) then
        raise EBkUpgFileAccess.Create('Error deleting ' + sFilename);

    //create the process form.  this form also triggers the check for updates
    //process.
    aForm := TfrmUpdMain.Create( nil, aDownloadType);
    try
      aForm.ApplicationTitle := CallingAppName;
      aForm.ApplicationID := ApplicationID;
      aForm.AppMajorVersion := caMajorVer;
      aForm.AppMinorVersion := caMinorVer;
      aForm.AppRelease := caRelease;
      aForm.AppBuild := caBuild;
      aForm.FormAction := acDownloadUpdates;
      aForm.ForceUpdate := ForceUpdate;
      aForm.CheckIndividualFiles := CheckIndividualFiles;
      aForm.SilentifNothing := SilentifNothing;
       // the application Handle should take care of that...
      if (aHandle <> 0) and (aHandle <> Application.Handle) then
      begin
        aForm.ParentWindow := AHandle;
      end;

      aForm.CatalogServer := CatalogServer;
      aForm.CatalogCountry := Country;
      aForm.DownloadType := aDownloadType;

      aForm.ConfigParam := Config;
      try
         if aForm.ShowModal = mrOK then
         begin
           result := aForm.Result;
           InstCRC := aForm.InstallScriptCRC;
         end
         else
            result := upgConstants.uaUserCancelled;
         if ahandle <> 0 then
            SetActiveWindow(AHandle);
      Except
         on e : exception do
            Result :=  uaUnableToLoad;
      end;

    finally
      aForm.Free;
    end;
  except
    on E : Exception do
    begin
      ShowMessage('Error occurred checking for updates - '+ E.Message + ' [' +
                         E.ClassName + ']');
      result := uaExceptionRaised;
    end;
  end;
  SetCurrentDir(sSaveDir);
end;

function FilesWaitingToBeInstalled( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint ) : boolean; stdCall;
var
  sTempDir: string;
  sFilename: string;
//parameters:
//  CallingAppName  : text description of app to update
//  aHandle         : handle for main form so can associate any new windows
//  ApplicationID   : id so know which app we are updating
//
//purpose:
//  Allows the calling app to see if any updates are pending
begin
  //look into the butemp folder for files for this application
  sTempDir :=  ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR;
  sFilename := sTempDir + MakeUpdateTempFilename( ApplicationID);
  result := FileExists( sFilename);
end;

function InstallUpdates( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; ExpectedCRC : longword) : LongInt; stdcall;
//parameters:
//  CallingAppName  : text description of app to update
//  aHandle         : handle for main form so can associate any new windows
//  ApplicationID   : id so know which app we are updating
//  Filter          :
//  ExpectedCRC     : crc expected for install script, used to detect tampering
//                    as this could be bad considering that the installer
//                    executes code
//
//purpose:
//  Does the install of downloaded files, action taken will depend on app being upgraded
//  for bk5 a set up exe will be executed
//
//  this routine will most likely be called via the bkinstall.exe which will
//  be called by bk5/bnotes.
//
//notes:
//  Looks for a file <appid>.xml which contains a list of the files that are
//  included in the update.

begin
  Result := InstallUpdatesEx( CallingAppName, aHandle, ApplicationID, Filter, false, false, ExpectedCRC);
end;

function InstallUpdatesEx( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; Filter : longint; ForceUpdate : boolean; CheckIndividualFiles : boolean; ExpectedCRC : longword) : LongInt; stdcall;
//parameters:
//  CallingAppName  : text description of app to update
//  aHandle         : handle for main form so can associate any new windows
//  ApplicationID   : id so know which app we are updating
//  Filter          :
//  ExpectedCRC     : crc expected for install script, used to detect tampering
//                    as this could be bad considering that the installer
//                    executes code
//
//purpose:
//  Does the install of downloaded files, action taken will depend on app being upgraded
//  for bk5 a set up exe will be executed
//
//  this routine will most likely be called via the bkinstall.exe which will
//  be called by bk5/bnotes.
//
//notes:
//  Looks for a file <appid>.xml which contains a list of the files that are
//  included in the update.

var
  aForm : TfrmUpdMain;
  sFilename : string;
  sTempDir : string;
begin
  sTempDir :=  ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR;
  sFilename := sTempDir + MakeUpdateTempFilename( ApplicationID);

  try
    //can file be found
    if not FileExists( sFilename) then
      raise EbkupgFileAccess.Create('Cannot find file ' + sFilename);

    aForm := TfrmUpdMain.Create( Application, dtFILE);
    try
      aForm.ApplicationTitle := CallingAppName;
      aForm.ApplicationID := ApplicationID;
      aForm.FormAction := acInstallUpdates;
      aForm.ActionFilter := Filter;
      aForm.ForceUpdate := ForceUpdate;
      aForm.InstallScriptCRC := ExpectedCRC;
       // the application Handle should take care of that...
      if (aHandle <> 0)
      and (aHandle <> Application.Handle) then begin
         aForm.ParentWindow := AHandle;
      end;
      if aForm.ShowModal = mrOK then
        result := aForm.Result
      else
        result := upgConstants.uaUserCancelled;
    finally
      aForm.Free;
    end;
  except
    on E : Exception do
    begin
      ShowMessage('Error occurred while installing updates - ' + E.Message + ' [' +
                         E.ClassName + ']');
      result := uaExceptionRaised;
    end;
  end;
end;

procedure ReportFirstRun( CallingAppName : PChar; aHandle : THandle; ApplicationID : longint; caMajorVer, caMinorVer,
  caRelease, caBuild : word; BConnectCode : PChar; Country : byte; ExtraIdentInfo : PChar; Config : PChar); stdcall;
var
{$IFDEF DEBUG}
  FileName: string;
  TestOutput: TStringList;
  ExtraInfoList: TStringList;
{$ENDIF}

  VersionString: string;
  LastReportedVersion: string;
  AppSection: string;
  DownloaderService: TDownloaderService;
  IniFile: TiniFile;
  DBCountryID: Integer;
const
  LastVersionKeyName = 'LastReportedAppVersion';
  LastFailDateTime =  'LastFailedTime';
  LastFailedError = 'LastFailedError';
  FailedCount = 'FailedCount';

  MaxTry = 10;
  MinWait = 20 / MinsPerDay;

  function ReportNow: Boolean;
  begin
     Result := False;
     if SameText(VersionString, LastReportedVersion) then
        Exit; // Already done.
     // Should report but...
     if IniFile.ReadInteger(AppSection,FailedCount,0) > MaxTry then
        Exit; // Tried too many times
     if (IniFile.ReadDateTime(AppSection,LastFailDateTime,0) + MinWait) > Now then
        Exit; // Tried too recent
     Result := True; // Ok then, lets try
  end;

begin
  //find out if we need to report this run (i.e. has the version changed).
  VersionString := Format('%d.%d.%d.%d',[caMajorVer, caMinorVer, caRelease, caBuild]);
  AppSection := Format(IniAppSection,[ApplicationID]);
  IniFile := TIniFile.Create(ExtractFilePath(GetDllPath) + bkupgIniFile);
  try
    LastReportedVersion := IniFile.ReadString(AppSection, LastVersionKeyName, '');
    DBCountryID := TServiceUpgrader.TranslationCountryIDToDBID(Country);

{$IFDEF DEBUG}
    //Testing Code!
    FileName := ExtractFilePath(Application.ExeName) + 'ReportFirstRunOutput.txt';
    TestOutput := TStringList.Create();
    try
      if FileExists(FileName) then
        TestOutput.LoadFromFile(FileName);
      Testoutput.Add('========================================================');
      TestOutput.Add('Report First Run:' + DateTimeToStr(Now));
      if not SameStr(VersionString, LastReportedVersion) then
      begin
        TestOutput.Add('Calling Application: ' + CallingAppName);
        TestOutput.Add('ApplicationID: ' + IntToStr(ApplicationID));
        TestOutput.Add(Format('Version: %d.%d.%d.%d',[caMajorVer, caMinorVer, caRelease, caBuild]));
        TestOutput.Add('BConnectCode: ' + BConnectCode);
        TestOutput.Add('Country: ' + IntToStr(DBCountryID));
        TestOutput.Add('ExtraInfo: (below)');
        ExtraInfoList := TStringList.Create;
        try
          ExtraInfoList.DelimitedText := ExtraIdentInfo;
          TestOutput.AddStrings(ExtraInfoList);
        finally
          ExtraInfoList.Free;
        end;
        TestOutput.Add('');
        TestOutput.Add('Config: (below)');
        Testoutput.Add(Config);
      end
      else
        TestOutput.Add(Format('Version %s already reported', [VersionString]));

      Testoutput.SaveToFile(FileName);
    finally
      TestOutPut.Free;
    end;
{$ENDIF}

    if ReportNow then begin
       DownloaderService := TDownloaderService.Create(Config);
       try try
          DownloaderService.RecordFirstRun(ApplicationID, VersionString, BConnectCode, DBCountryID, ExtraIdentInfo, '');
          // Still here.. Must be successful
          IniFile.WriteString(AppSection, LastVersionKeyName, VersionString);
          IniFile.DeleteKey(AppSection,LastFailDateTime);
          IniFile.DeleteKey(AppSection,LastFailedError);
          IniFile.DeleteKey(AppSection,FailedCount);
      except
         on E : Exception do begin
            IniFile.WriteInteger(AppSection,FailedCount,
                  Succ(IniFile.ReadInteger(AppSection,FailedCount,0)));
            IniFile.WriteDateTime(AppSection,LastFailDateTime,Now);
            // Better do this last.. The message may not be compatible with an ini file)
            IniFile.WriteString(AppSection,LastFailedError, E.Message);
         end;
      end;
      finally
         DownloaderService.Free;
      end;

    end;
  finally
    IniFile.Free;
  end;
end;

initialization
finalization
   Application.Handle  := 0;
end.



