unit ApplicationStartupAndShutDown;
//------------------------------------------------------------------------------
{
   Title:       Application Startup and Shutdown routines

   Description:

   Remarks:     This unit contains a code that was previously found in the
                dpr file.  This increasing amount of code in the dpr meant
                that it was time to add a specific unit to handle this operations.
                This allows better code seperation and makes it easier for
                multiple developers to maintain.

   Author:      Matthew Hopkins   Oct 2004

}
//------------------------------------------------------------------------------
interface
uses
  SysUtils;

type
  EBKStartUpError = class( Exception);
  EBKStartupForceTerminate = class( Exception);

procedure BeforeAppInitialize;
procedure AfterAppInitialize;
procedure AfterFormCreation;
procedure HandleStartupError( e : Exception);
procedure ApplicationShutdown;

implementation
uses
  //MadExcept,
  Forms, Dialogs, Windows,
  ImagesFrm,
  Globals,
  WinUtils,
  ErrorLog,
  LockUtils,
  Admin32,
  LogUtil,
  IniSettings,
  Setup,
  TsUtils,
  Upgrade,
  RegistryUtils,
  DbCreate,
  UpgradeHelper,
  bkBranding,
  MadUtils,
  UsageUtils, BKHelp,
  ThirdPartyHelper;

const
  UnitName = 'AppStartupShutDown';
var
  StartupStep : string;  //allows error handler to tell where we were upto
  FaxHandle: THandle;
  DebugMe       : boolean = false;

procedure SetCommandLineParameters;
const
  UserSwitch = '/USER=';
  ClientSwitch = '/CLIENT=';
  pwSwitch = '/PW=';
  ActionSwitch = '/ACTION=';
  MaxUserCodeLength = 8;
  MaxClientCodeLength  = 8;
  MaxPWLenght = 8;
  ThisMethodName = 'SetCommandLineParameters';
var
  i : integer;
  s : string;
  p : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  for i := 1 to ParamCount do begin
    s := Uppercase( ParamStr(i));
    if Pos( UserSwitch, S) > 0 then begin
       //user specified
       p := Copy( S, Pos( UserSwitch, S) + Length(UserSwitch), MaxUserCodeLength);
       if p <> '' then
          Globals.StartupParam_UserToLoginAs := p;
    end else if Pos( ClientSwitch, S) > 0 then begin
      //Client specified
      p := Copy( S, Pos( ClientSwitch, S) + Length(ClientSwitch), MaxClientCodeLength);
      if p <> '' then
         Globals.StartupParam_ClientToOpen := p;
    end else if Pos( pwSwitch, S) > 0 then begin
      //Password specified
      p := Copy( S, Pos( pwSwitch, S) + Length(pwSwitch), MaxPWLenght);
      if p <> '' then
         Globals.StartupParam_UserPassword := p;
    end else if Pos( ActionSwitch, S) > 0 then begin
      //Action specified
      p := Copy( S, Pos( ActionSwitch, S) + Length(ActionSwitch), 255);
      if p <> '' then begin
         if p = 'BULKEXPORT' then begin
            StartupParam_Action := sa_BulkExport;
         end else  if p = 'DOWNLOAD' then begin
            StartupParam_Action := sa_Connect;
         end
         else if p = 'EXPORTTRANSACTIONS' then
           StartupParam_Action := sa_ExportTransactions;
      end;
    end;
  end;

  // Fix any conflicts..
  if StartupParam_Action in System_Actions then begin
     if StartupParam_UserPassword = '' then
        StartupParam_Action := 0; // cannot logon..No action
  end;

  if StartupParam_Action = 0 then
     StartupParam_UserPassword := ''; // Not allowed to logon

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure BeforeAppInitialize;
const
  ThisMethodName = 'BeforeAppInitialize';

  Var v1, v2, v3, v4: Word;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  AdminSystem := nil;

  StartUpStep := 'Check for fxsapi dll';
  if BKFileExists(GetWinSysDir + 'fxsapi.dll') then
    FaxHandle := LoadLibrary(PANSIChar(GetWinSysDir + 'fxsapi.dll'));

  StartUpStep := 'Check for third party dll';
  ThirdPartyHelper.CheckForThirdPartyDLL;

  StartUpStep := 'Reading practice settings';
  //Read Practice INI settings
  LockUtils.ObtainLock( ltPracIni, TimeToWaitForPracINI );
  try
    ReadPracticeINI;
    //Check if version no has changed, if it has write a new line in the log file
    if PRACINI_CurrentVersion <> WINUTILS.GetAppVersionStr then begin
       PRACINI_CurrentVersion := WINUTILS.GetAppVersionStr;
       LogUtil.LogMsg(lmDebug, UnitName, 'New Version Detected '+PRACINI_CurrentVersion, ERRORLOG.stat_ResetStatsFile);
       //Update the practice ini file with new version str
       GetBuildInfo(v1, v2, v3, v4);
       if (v1 = 5)
       and (v2 = 14)
       and (v3 = 0) then begin // I have moved to 5.14.0...
          if Pos('19.0715',PRACINI_FuelCreditRates) = 0 then
             PRACINI_FuelCreditRates := PRACINI_FuelCreditRates + ',19.0715';
       end;
       if (v1 = 5)
       and (v2 = 16)
       {and (v3 < 2)} then begin // I have moved to 5.16.x...
          if Pos('16.443',PRACINI_FuelCreditRates) = 0 then
             PRACINI_FuelCreditRates := PRACINI_FuelCreditRates + ',16.443';
       end;
       WritePracticeINI;
    end;
  finally
    LockUtils.ReleaseLock( ltPracINI)
  end;

  // Why Wait...
  ReportMemoryLeaksOnShutdown := PRACINI_ReportMemoryLeak;

  {application titles}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  {$IFDEF SmartLink}
    APPTITLE            := 'SmartLink for Business';
    SHORTAPPNAME        := 'SmartLink';
  {$ELSE}
    {$IFDEF BKMAP}
      APPTITLE            = 'BankLink Map Utility';
      SHORTAPPNAME        = 'BKMAP';
    {$ELSE}
      {$IFDEF BKCRYPT}
        APPTITLE            = 'BankLink Decryption Utility';
        SHORTAPPNAME        = 'BKCRYPT';
      {$ELSE}
         if AdminExists or CheckDBCreateParam or CheckDBCreateParamNoRun then
         begin
           APPTITLE := 'BankLink Practice';
           SHORTAPPNAME := 'BankLink Practice';
           bkBranding.BrandingImageSet := imPractice;
         end
         else
         begin
           //default to books
           APPTITLE := 'BankLink Books';
           SHORTAPPNAME := 'BankLink Books';
           bkBranding.BrandingImageSet := imBooks;

           if ThirdPartyHelper.ThirdPartyDLLDetected then
           begin
             if (ThirdPartyBannerLogo <> nil) then
                bkBranding.BrandingImageSet := imDLL;
             if (ThirdPartyName <> '') then
                APPTITLE := 'BankLink Books provided by ' + ThirdPartyName;
           end;
         end;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}


  if (Pos('Windows 95', WinUtils.GetWinVer) > 0) then
    Raise Exception.Create( 'This application does not run on Windows 95.');

  if (Pos('Windows NT', WinUtils.GetWinVer) > 0) then
    Raise Exception.Create( 'This application does not run on Windows NT.');

  //Read Users INI file
  StartUpStep := 'Reading user settings';
  BK5ReadINI;
  SetMadEmailOptions;

  StartUpStep := 'Initialising application';

  SetApplicationName(APPTITLE);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure AfterAppInitialize;
const
  ThisMethodName = 'AfterAppInitialize';
begin
  Application.Title := APPTITLE;
  if BKFileExists(ExtractFilePath(Application.ExeName) + HelpFileName) then
    Application.HelpFile := ExtractFilePath(Application.ExeName) + HelpFileName;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure AfterFormCreation;
const
  ThisMethodName = 'AfterFormCreation';
var
  CustomBitmapFileName : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  StartUpStep := 'Checking for TS and Reg';
  if ( not TSUtils.UsingTerminalServices) then  //note Evaluate to true for XP and later
  begin
    //See if this is the first time that BK5 has been run
    if ( not TestRegistryForBK5Key) then
      begin
         //Test rights to EXE directory
         if not TestUserDirRights then
           raise EBKStartupError.Create('Insufficent user rights');

         SetupBK5;  //create desktop shortcut and reg entry with path info
      end;
  end;

  //update in progress
  if UpgradeHelper.IsInstallInProgress then
    raise EBkStartupError.Create( 'Upgrade in progress');

  //create database if command line parameter specified
  if CheckDBCreateParam then
  begin
     StartUpStep := 'Creating new system db';          
     if not TfrmDBCreate.Execute then
       raise EBKStartupError.Create('Create system.db cancelled');
  end;

  //create database if command line parameter specified
  //in this case continue running banklink after the database has been created.
  if CheckDBCreateParamNoRun then
  begin
     StartUpStep := 'Creating new system db';
     TfrmDBCreate.Execute;
     raise EBKStartupForceTerminate.Create('');
  end;

  //record the default user and default client code as specified in command
  //parameters
  SetCommandLineParameters;

  //Try to read Admin System.  A refresh will check that the admin system can
  //be loaded, but will not leave a lock file behind if an exception is raised.
  //Without this the lock file will always read Requested by Upgrade...
  StartUpStep := 'Checking admin system';
  try
    if AdminExists then
    begin
      LoadAdminSystem(false, 'StartUp');
      Assert( Assigned( AdminSystem), 'Admin System Assigned');
      // While we are Here:
      MadAddEmailSubjectValue('Practice-Code',AdminSystem.fdFields.fdBankLink_Code);
      MadAddEmailBodyValue('Practice-Code',AdminSystem.fdFields.fdBankLink_Code);
      MadAddEmailBodyValue('Practice-Name',AdminSystem.fdFields.fdPractice_Name_for_Reports);
      MadAddEmailBodyValue('Practice-Email',AdminSystem.fdFields.fdPractice_EMail_Address);

    end;
  except
    on e : Exception do
    begin
      raise EBKStartupError.Create('Unable to load system.db ' + E.Message);
    end;
  end;

{$IFDEF Smartlink}
   if not Assigned( AdminSystem) then
     raise EBKStartUpError.Create('No admin system found');
{$ENDIF}

  //See if the admin system needs to be upgraded

  if Assigned( AdminSystem) then
  begin
    StartUpStep := 'Checking for admin upgrade';
    Upgrade.UpgradeAdminToLatestVersion;
    Upgrade.UpgradeExchangeRatesToLatestVersion;
//    ShowMessage('1');
    Upgrade.UpgradeClientTypes;
  end;

  StartUpStep := 'Checking for custom bitmap';

  if Assigned(AdminSystem) then
  begin
    AppImages.CustomLoginBitmapLoaded := false;
    CustomBitmapFileName := AdminSystem.fdFields.fdLogin_Bitmap_Filename;

    try
      if CustomBitmapFileName <> '' then
      begin
        if FileExists( CustomBitmapFileName ) then
        begin
          AppImages.imgCustomLogin.Picture.LoadFromFile( CustomBitmapFileName );
          AppImages.CustomLoginBitmapLoaded := true;
        end;
      end
    except
      on e : Exception do ;
    end;
  end;

  StartUpStep := 'Assigning INI Settings to Admin System';
  // Override these with db if the db exists
  // Must still support ini entries for offsites
  if Assigned(AdminSystem) then
  begin
    PRACINI_CopyNarrationDissection := AdminSystem.fdFields.fdCopy_Dissection_Narration;
    PRACINI_RoundCashFlowReports := AdminSystem.fdFields.fdRound_Cashflow_Reports;
    PRACINI_UseXLonChartOrder := AdminSystem.fdFields.fdUse_Xlon_Chart_Order;
    PRACINI_ExtractMultipleAccountsToPA := AdminSystem.fdFields.fdExtract_Multiple_Accounts_PA;
    PRACINI_ExtractJournalsAsPAJournals := AdminSystem.fdFields.fdExtract_Journal_Accounts_PA;
    PRACINI_ExtractQuantity := AdminSystem.fdFields.fdExtract_Quantity;
    PRACINI_ExtractDecimalPlaces := AdminSystem.fdFields.fdExtract_Quantity_Decimal_Places;
    PRACINI_Reports_NewPage := AdminSystem.fdFields.fdReports_New_Page;
  end;

  StartupStep := 'Updating Registry Values';

  //need to tell the registry where we are
  RegistryUtils.StoreCurrentExePath( ExecDir);
  Globals.CheckInExtnDetected := RegistryUtils.TRFHandlerInstalled;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure HandleStartupError( e : Exception);
begin
  try
    if not E.ClassNameIs('EBKStartupForceTerminate') then
    begin
      ShowMessage( 'An error has occured during start up. '+ E.Message + ' [' + E.Classname + ']'#13#13 +
                   SHORTAPPNAME + ' will now terminate.' );
      LogMsg( lmError, Unitname, 'Start Up error ' + StartUpStep + '. ' + E.Message + ' [' + E.Classname + ']');
    end;
  finally
    Globals.ApplicationIsTerminating := true;
    Application.Terminate;
  end;
end;

procedure ApplicationShutdown;
begin
  // Write stats if allowed to
  If (Assigned(AdminSystem)) and (AdminSystem.fdFields.fdCollect_Usage_Data) then SaveUsage;
  //Write local INI settings to c:\windows\system\bk5win.ini
  Bk5WriteINI;
  //Write a practice ini file if one doesnt exists already
  if not FileExists( DATADIR + PRACTICEINIFILENAME ) then
  begin
    WritePracticeINI_WithLock;
  end;
  if FaxHandle <> 0 then
    FreeLibrary(FaxHandle);
  if ThirdPartyDLLDetected then
    FreeThirdPartyObjects;
end;

initialization
  StartUpStep := '';
  FaxHandle := 0;
  DebugMe        := DebugUnit( UnitName );

end.
