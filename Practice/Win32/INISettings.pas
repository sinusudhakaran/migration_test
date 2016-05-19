unit INISettings;
//------------------------------------------------------------------------------
{
  Title:  INI settings

  Written:
  Authors: Matthew

  Purpose: Load and Save the practice and users INI files

  Notes:  Loads values into globals variables.

          mh Aug 02    now stores an ini version no so that we can upgrade settings


}
//------------------------------------------------------------------------------

interface

function GetBK5Ini: string;
procedure BK5ReadINI;
procedure BK5WriteINI;

procedure ReadPracticeINI;
procedure WritePracticeINI;
procedure WritePracticeINI_WithLock;

procedure WriteUsersINI( UserCode : string);
procedure ReadUsersINI( UserCode : string);

procedure ReadAppINI;

procedure UpdateMemorisationINI_WithLock();
procedure WriteMemorisationINI_WithLock(aClientCode : string);
procedure ReadMemorisationINI(aClientCode : string);

function EncryptAToken(aToken: string;var RandomKey: string):string;
function DecryptAToken(aToken: string;RandomKey: string):string;
procedure ResetMYOBTokensInUsersINI(userCode : string);

//------------------------------------------------------------------------------
implementation
uses
  bkqrprntr,
  bkConst,
  Globals,
  IniFiles,
  sysUtils,
  STStrL,
  LogUtil,
  CryptUtils,
  LockUtils,
  WinUtils,
  ThirdPartyHelper,
  Classes,
  Windows,
  SHFolder,
  GenUtils,
  bkUrls,
  bkProduct,
  StrUtils,
  dbCreate,
  BKIniFiles,
  EncryptOpenSSL,
  BkBranding;

const
   GrpMainForm = 'MainForm';
   GrpDissectForm = 'DissectForm';
   GrpJournalForm = 'JournalForm';
   GrpOptions  = 'Options';
   GrpKeyring  = 'Keyring';
   GrpMRU      = 'MRU';
   GrpProxy    = 'Proxy';
   GrpInternet = 'Internet';
   GrpColumnWidths = 'ColumnWidths';
   GrpCustom     = 'Customise';
   GrpDontShowMe = 'DontShowMe';
   GrpInfo       = 'Info';
   GrpMAPI       = 'MAPI';
   GrpSysAccounts = 'SystemAccounts';
   GrpLocking    = 'Locking';

   GrpClientMgr  = 'ClientMgr';
   GrpGlobalSetup = 'GlobalSetup';
   GrpUserOptions = 'UserOptions';

   GrpClientHomepg  = 'ClientHomePg';
   GrpFavouriteReports  = 'FavouriteReports';
   GrpCustomDocuments = 'CustomDocuments';
   GrpReportSettings = 'ReportSettings';
   GrpExchangeRates  = 'ExchangeRates';

   //Lean Engage Section
   GrpLeanEngage = 'LeanEngage';

   // BGL360 Keys
   ikBGL360_API_URL       = 'BGL360APIURL';
   ikRandom_Key           = 'BGL360Key';
   ikBGL360_Client_ID     = 'BGL360ClientID';
   ikBGL360_Client_Secret = 'BGL360ClientSecret';

   //Contentful API URL Key
   ikContentful_API_URL   = 'ContentfulAPIURL';

   //Promo Window Keys
   ikDisablePromoWindow         = 'DisablePromoWindow';

   //Lean Engage Keys
   ikDisableLeanEngage          = 'DisableLeanEngage';
   ikLeanEngage_BASE_URL        = 'LeanEngageBaseUrl';
   ikLeanEngage_System_Switch   = 'LeanEngageSystemSwitch';

   //Practice INI groups
   GrpPracEnv    = 'Environment';
   GrpPracPrint  = 'Printing';
   GrpPracInfo   = 'Info';
   GrpPracNetwork= 'Network';
   GrpPracCustom = 'Customize';
   GrpPracDev    = 'Developer';
   GrpBConnect   = 'BConnect';
   GrpPracFingerTips = 'Fingertips';
   GrpPracLinks  = 'Links';
   GrpPracBankLinkOnline = 'BankLinkOnline';
   GrpPracThirdParty = 'ThirdParty';
   GrpPracmyMYOB = 'MYOB';

   //Mems Ini groups
   GrpMemsSupport = 'Support';

   MEM_COMMENTS : Array[ 0..5 ] of String =
      (  '; Support Section Help',
         '; 0 = Full Suggested Mems functionality',
         '; 1 = Refresh/Reset Suggested Mems',
         '; 2 = Disable Suggested Mems',
         '; Format to use is ClientCode=Number e.g. SAMPLE=1',
         '' );


   DefLinkGST101 = 'https://www.ird.govt.nz/cgi-bin/form.cgi?form=gst101';
   DefLinkGST103 = 'https://www.ird.govt.nz/cgi-bin/form.cgi?form=gst103';
   DefLinkTaxAgentGSTReturn = 'https://www.ird.govt.nz/cgi-bin/form.cgi?form=taxagentgstreturn';
   DefLinkGST_Books = 'https://www.ird.govt.nz';
   DefInstListLinkNZ = 'http://www.banklink.co.nz/about_institutions.html';
   DefInstListLinkAU = 'http://www.banklink.com.au/about_institutions.html';
   DefInstListLinkUK = 'http://www.banklink.co.uk/institutions.html';
   DefLeanEngageLink = 'https://www.leanengage.com';

//   DefBGLOriginalClientID     = 'bankLinkTest';
//   DefBGLOriginalClientSecret = 'bankLinkSecret';

   UnitName      = 'INISettings';

  INIT_VECTOR = '@AT^NK(@YUVK)$#Y';
  RANDOM_KEY = 'BANKLNK5';
const
   BK5_INI_Version = 1;

   (* History
      5.2.0.47     1: Introduced versioning of ini file
   *)

   PRAC_INI_Version = 4;

   (* History
      5.2.0.47     1: Introduced versioning of ini file
      5.6.0        2: moved some settings to db
   *)

   USER_INI_VERSION = 4;
   (* History
      ?.?.?.?     1: Base Version
      ?.?.?.?     2: Introduce UserINI_CM_Filter
      5.15.0      3: Introduce GST Due column, reorder columns around it
      5.27.0      4: Update CES find to be visible
   *)

//------------------------------------------------------------------------------
function BConnectPassKey : string;
const
   KeyPart1          = 'z3f5b37c';
   KeyPart2          = 'vk9(SFG%';
var
   i : integer;
begin
   for i := 1 to 8 do
      result := result + KeyPart1[i] + KeyPart2[ i];
end;

//------------------------------------------------------------------------------
function GetBK5Ini: string;
begin
  Result := IncludeTrailingPathDelimiter(ShellGetFolderPath(CSIDL_APPDATA) + 'BankLink\' + SHORTAPPNAME) + INIFILENAME;
end;

procedure BK5ReadINI;
var
  S      : String;
  i,j    : integer;
  TempMRU : Array[1..MAX_MRU] of string;
  EncryptedPassword, DocFolder, WinFolder, DocFile, WinFile, CommonDocFolder : string;
  TempBool          : boolean;
  IniFile : TMemIniFile;
  Orig_Version  : integer;
  iDefaultValue  : integer;
  BankLinkOld_DocFolder: string;
  BankLinkOld_DocFile: string;
  BankLinkOld_ShortAppName: string;
begin
   CommonDocFolder := ShellGetFolderPath(CSIDL_APPDATA);

   DocFolder := IncludeTrailingPathDelimiter(CommonDocFolder + TProduct.BrandName + '\' + SHORTAPPNAME);
   DocFile := DocFolder + INIFILENAME;

   // Read from old BankLink location (the old string values are hardcoded)
   BankLinkOld_DocFolder := IncludeTrailingPathDelimiter(CommonDocFolder + 'BankLink' + '\');
   BankLinkOld_ShortAppName := ReplaceStr(SHORTAPPNAME, TProduct.BrandName, 'BankLink');
   BankLinkOld_DocFolder := BankLinkOld_DocFolder + BankLinkOld_ShortAppName + '\';
   BankLinkOld_DocFile := BankLinkOld_DocFolder + INIFILENAME;
   if FileExists(BankLinkOld_DocFile) and not FileExists(DocFile) then
   begin
     if not DirectoryExists(DocFolder) then
       ForceDirectories(DocFolder);
     Windows.CopyFile(PChar(BankLinkOld_DocFile), PChar(DocFile), true);
     DeleteFile(PChar(BankLinkOld_DocFile));
     LogUtil.LogMsg(LogUtil.lmInfo, UnitName, 'Moved INI from ' + BankLinkOld_DocFile + ' to ' + DocFile);
   end;

   // Read from old Windows location
   WinFolder := GetWinDir;
   WinFile := WinFolder + INIFILENAME;
   if BKFileExists(WinFile) and (not BKFileExists(DocFile)) and (DocFolder <> WinFolder) then // move it to common folder
   begin
     if not DirectoryExists(DocFolder) then
       ForceDirectories(DocFolder);
     Windows.CopyFile(PChar(WinFile),PChar(DocFile), True);
     DeleteFile(PChar(WinFile));
     LogUtil.LogMsg(LogUtil.lmInfo, UnitName, 'Moved INI from ' + WinFile + ' to ' + DocFile);
   end;

   IniFile := TMemIniFile.Create(DocFile);
   try
      {read form settings from INI}
      INI_mfStatus := IniFile.ReadInteger (GrpMainForm, 'Status', 3);
{$IFNDEF SmartBooks}
      //default of -1 indicates value not present
      INI_mfTop    := IniFile.ReadInteger (GrpMainForm, 'Top',    -1);
      INI_mfLeft   := IniFile.ReadInteger (GrpMainForm, 'Left',   -1);
      INI_mfWidth  := IniFile.ReadInteger (GrpMainForm, 'Width',  -1);
      INI_mfHeight := IniFile.ReadInteger (GrpMainForm, 'Height', -1);
      INI_ShowCodeHints := IniFile.ReadBool(GrpOptions,'ShowCodeHints',true);
{$ENDIF}

      {read form settings from INI}
      INI_dsStatus := IniFile.ReadInteger (GrpDissectForm, 'Status', 3);
      //default of -1 indicates value not present
      INI_dsTop    := IniFile.ReadInteger (GrpDissectForm, 'Top',    -1);
      INI_dsLeft   := IniFile.ReadInteger (GrpDissectForm, 'Left',   -1);
      INI_dsWidth  := IniFile.ReadInteger (GrpDissectForm, 'Width',  -1);
      INI_dsHeight := IniFile.ReadInteger (GrpDissectForm, 'Height', -1);

      {read form settings from INI}
      INI_jsStatus := IniFile.ReadInteger (GrpJournalForm, 'Status', 3);
      //default of -1 indicates value not present
      INI_jsTop    := IniFile.ReadInteger (GrpJournalForm, 'Top',    -1);
      INI_jsLeft   := IniFile.ReadInteger (GrpJournalForm, 'Left',   -1);
      INI_jsWidth  := IniFile.ReadInteger (GrpJournalForm, 'Width',  -1);
      INI_jsHeight := IniFile.ReadInteger (GrpJournalForm, 'Height', -1);

      {read app options}
      INI_ShowToolbarCaptions := IniFile.ReadBool(GrpOptions,'ToolBarCaptions',true);
      INI_ShowClientProperties := IniFile.ReadBool(GrpOptions,'ClientProperties',false);
      INI_ShowFormHints := IniFile.ReadBool(GrpOptions,'ShowFormHints',true);
      INI_ShowPrintOptions := IniFile.ReadBool(GrpOptions,'ShowPrintOptions',false);
      INI_AutoSaveTime  := IniFile.ReadInteger (GrpOptions,'AutoSaveTime', 5);

      INI_DownloadFrom  := IniFile.ReadString(GrpOptions,'UseFloppy','');
      INI_CheckOutDir   := IniFile.ReadString(GrpOptions,'CheckOutDir', GetMyDocumentsPath);
      INI_CheckInDir    := IniFile.ReadString(GrpOptions,'CheckInDir', GetMyDocumentsPath);
      INI_PlaySounds    := IniFile.ReadBool( GrpOptions, 'PlaySounds', True );

      INI_MAIL_Type     := IniFile.ReadString(GrpOptions,'MailType',MAPI_MAIL);
      INI_MAPI_UseExtended := IniFile.ReadBool(GrpOptions,'UseExtended',False);
      INI_MAPI_Profile  := IniFile.ReadString(GrpOptions,'Profile','');
      INI_SMTP_Account  := IniFile.ReadString(GrpOptions,'Account','');
      INI_MAPI_Default  := IniFile.ReadBool  (GrpOptions,'DefaultProfile',true);
      INI_SMTP_Server   := IniFile.ReadString(GrpOptions,'SMTPServer','');
      INI_SMTP_Auth     := IniFile.ReadBool  (GrpOptions,'AuthReq',false);
      INI_SMTP_From     := IniFile.ReadString(GrpOptions,'SMTPFrom','');
      INI_SMTP_PortNo   := IniFile.ReadString(GrpOptions,'PortNo','');
      INI_SMTP_UseSSL   := IniFile.ReadBool(GrpOptions,'UseSSL',false);

      EncryptedPassword           := IniFile.ReadString ( GrpKeyring, 'Key1','');
      INI_MAPI_Password           := DecryptPass16( MAIL_PASS_KEY, EncryptedPassword);
      EncryptedPassword           := IniFile.ReadString ( GrpKeyring, 'Key2','');
      INI_SMTP_Password           := DecryptPass16( MAIL_PASS_KEY, EncryptedPassword);

      INI_CODING_FONT_NAME  := IniFile.ReadString(GrpOptions, 'CodingFontName','');
      INI_CODING_FONT_SIZE  := IniFile.ReadInteger(GrpOptions,'CodingFontSize',0);
      INI_CODING_ROW_HEIGHT := IniFile.ReadInteger(GrpOptions,'CodingRowHeight',0);
      INI_Report_Style      := IniFile.ReadString(GrpOptions, 'ReportStyle','Simple');

      //These INI settings can be set from the thirdparty DLL
      //MH: The handling of settings from the thirdparty DLL could be extended
      //    to allow for an INI setting to be passed into a routine that then
      //    returns a default value or forced value.  Didnt do this yet as was
      //    out of scope.  Would allow any INI value to be overriden.

      //Allow checkout can be FORCED from DLL
      //  -1 = not set
      //   0 = default FALSE
      //   1 = default TRUE
      //   2 = FORCE FALSE
      if ThirdPartyDLLDetected and (ThirdPartyHelper.AllowCheckOut <> -1) then
      begin
        if (ThirdPartyHelper.AllowCheckOut = 2) then
          INI_AllowCheckOut := False
        else
          INI_AllowCheckOut := IniFile.ReadBool(GrpOptions,'AllowCheckOut',(ThirdPartyHelper.AllowCheckOut = 1)); //not set in DLL
      end
      else
        INI_AllowCheckOut := IniFile.ReadBool(GrpOptions,'AllowCheckOut',True);

      //UI style should be set from the dll on first run after install
      if ThirdPartyDLLDetected then
        iDefaultValue := ThirdPartyHelper.DefaultUIStyle
      else
        iDefaultValue := 0;
      INI_UI_Style          := IniFile.ReadInteger( GrpOptions, 'UIStyle',iDefaultValue);

      {read MRU List}
      for i := 1 to MAX_MRU do begin
        S := IniFile.ReadString(GrpMRU,'Client'+inttostr(i),'');
        TempMRU[i] := SubStituteL( S, '~', #9 );
        INI_MRUList[i] := ''; //Clear INI List
      end;
      {shuffle valid lines to top}
      j := 0;
      for i := 1 to MAX_MRU do
        if TempMRU[i] <> '' then
        begin
           Inc(j);
           INI_MRUList[j] := TempMRU[i];
        end;

      {read internet settings}
      INI_INTERNET_TIMEOUT := IniFile.ReadInteger(GrpInternet,'ConnectTimeOut' ,60);

      //Read any custom settings
      INI_Default_User_Code    := Uppercase( IniFile.ReadString( GrpCustom, 'DefaultUser', ''));

      //Read Dont Show Me settings
      INI_DontShowMe_EditChartGST := IniFile.ReadBool( GrpDontShowMe,'EditChartGST',false);
      INI_DontShowMe_NoOpeningBalances := IniFile.ReadBool( GrpDontShowMe, 'OpeningBalancesWarning', false);

      //New BConnect Settings
      INI_BCPrimaryHost           := IniFile.ReadString ( GrpBConnect, 'BCPrimaryHost',  TUrls.DefaultBConnectPrimaryHost);
      INI_BCSecondaryHost         := IniFile.ReadString ( GrpBConnect, 'BCSecondardHost', TUrls.DefaultBConnectSecondaryHost);
      INI_BCPrimaryPort           := IniFile.ReadInteger( GrpBConnect, 'BCPrimaryPort', 443 );
      INI_BCSecondaryPort         := IniFile.ReadInteger( GrpBConnect, 'BCSecondaryPort', 443 );
      INI_BCTimeout               := IniFile.ReadInteger( GrpBConnect, 'Timeout', DefaultBConnectHTTPTimeout);
      INI_BCCustomConfig          := IniFile.ReadBool   ( GrpBConnect, 'UseCustom', false);

      INI_BCUseProxy              := IniFile.ReadBool   ( GrpBConnect, 'UseProxy', false  );
      INI_BCProxyHost             := IniFile.ReadString ( GrpBConnect, 'ProxyHost', ''  );
      INI_BCProxyPort             := IniFile.ReadInteger( GrpBConnect, 'ProxyPort', 80  );
      INI_BCProxyUsername         := IniFile.ReadString ( GrpBConnect, 'ProxyUsername', ''  );
      //Read Proxy Password - need to decrypt
      EncryptedPassword           := IniFile.ReadString(GrpKeyring,'Key3','');
      INI_BCProxyPassword         := DecryptPass16( BConnectPassKey, EncryptedPassword);

      //New Settings for v2.5
      INI_BCUseWinInet            := IniFile.ReadBool   ( GrpBConnect, 'UseWinInet', true);
      INI_BCProxyAuthMethod       := IniFile.ReadInteger( GrpBConnect, 'ProxyAuthMethod', 0);

      INI_BCUseFirewall           := IniFile.ReadBool   ( GrpBConnect, 'UseFirewall', false);
      INI_BCFirewallHost          := IniFile.ReadString ( GrpBConnect, 'FirewallHost', '');
      INI_BCFirewallPort          := IniFile.ReadInteger( GrpBConnect, 'FirewallPort', 0);
      INI_BCFirewallType          := IniFile.ReadInteger( GrpBConnect, 'FirewallType', 0);
      INI_BCFirewallUseAuth       := IniFile.ReadBool   ( GrpBConnect, 'UseFirewallAuth', false);
      INI_BCFirewallUsername      := IniFile.ReadString ( GrpBConnect, 'FirewallUsername', '');
      INI_BCHTTPMethod            := IniFile.ReadString ( GrpBConnect, 'HTTPMethod', 'https://');

      //Read Firewall Password - need to decrypt
      EncryptedPassword           := IniFile.ReadString ( GrpKeyring, 'Key4','');
      INI_BCFirewallPassword      := DecryptPass16( BConnectPassKey, EncryptedPassword);

      //see if should upgrade v2.0 settings
      if IniFile.ValueExists( GrpBConnect, 'ProxyLoginReqd') then begin
         TempBool := IniFile.ReadBool   ( GrpBConnect, 'ProxyLoginReqd', false  );
         if TempBool then begin
            INI_BCProxyAuthMethod := 2;  //default to NTLM
         end;
      end;

      INI_ShowVersionInFooter     := IniFile.ReadBool( GrpCustom, 'ShowVersionInFooter', false);

      INI_BackupDir               := IniFile.ReadString( GrpOptions, 'BackupDir', 'A:\');
      INI_BackupLevel             := IniFile.ReadInteger( GrpOptions, 'BackupLevel', 0);
      INI_BackupOverwrite         := IniFile.ReadBool( GrpOptions, 'BackupOverwrite', true);

      INI_Coding_Font             := IniFile.ReadString(GrpOptions, 'CodingFont', DefaultCESFontString);

      INI_MAX_EXTRACT_NARRATION_LENGTH := IniFile.ReadInteger( GrpOptions, 'MaxNarrationLength', 200);
      INI_BooksExtact            :=  IniFile.ReadBool( GrpOptions, 'AllowBooksExtract', False);

      INI_SOL6_SYSTEM_PATH := IniFile.ReadString( GrpOptions,'Sol6Dir', '');

      INI_CustomColors := IniFile.ReadString(GrpOptions,'CustomColours',
      'ColorA=0,ColorB=0,ColorC=0,ColorD=0,ColorE=0,ColorF=0,ColorG=0,ColorH=0,ColorI=0,ColorJ=0,ColorK=0,ColorL=0,ColorM=0,ColorN=0,ColorO=0,ColorP=0');

      INI_LeanEngage_BASE_URL    := IniFile.ReadString( GrpLeanEngage,
        ikLeanEngage_BASE_URL, DefLeanEngageLink );
    {$ifdef Debug}
      INI_LeanEngage_System_Switch := cLeanEngage_TestSwitch; // Ensure that Practice only uses test system
    {$else}{ifdef Debug}
      INI_LeanEngage_System_Switch := Uppercase( IniFile.ReadString(
        GrpLeanEngage, ikLeanEngage_System_Switch, cLeanEngage_ProdSwitch ) );
    {$endif}{ifdef Debug}




      Orig_Version                := IniFile.ReadInteger( GrpInfo, 'INIVersion', BK5_INI_VERSION);
      if Orig_Version < BK5_INI_VERSION then
      begin
        //upgrade fields as required
      end;

   finally
      IniFile.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure BK5WriteINI;
var
  S : String;
  i : integer;
  EncryptedPassword, DocFolder : string;
  IniFile : TMemIniFile;
  BankLinkSettingsFile: String;
begin
   {Write Form Settings into INI File}
   DocFolder := ShellGetFolderPath(CSIDL_APPDATA) + TProduct.BrandName + '\' + SHORTAPPNAME + '\';

   if not DirectoryExists(DocFolder) then
     ForceDirectories(DocFolder);

   if TProduct.ProductBrand <> btBankLink then
   begin
     if not FileExists(DocFolder + INIFILENAME) then
     begin
       BankLinkSettingsFile := ShellGetFolderPath(CSIDL_APPDATA) + 'BankLink\' + ReplaceStr(SHORTAPPNAME, TProduct.BrandName, 'BankLink') + '\' + INIFILENAME;

       if FileExists(BankLinkSettingsFile) then
       begin
         CopyFile(PChar(BankLinkSettingsFile), PChar(DocFolder + INIFILENAME), True);
       end;
     end;
   end;

   IniFile := TMemIniFile.Create(DocFolder + INIFILENAME);
   try
     //Save Main Form Window Status
     IniFile.WriteInteger (GrpMainForm, 'Status', INI_mfStatus);
{$IFNDEF SmartBooks}
     //save position and size only if the state is normal}
     IniFile.WriteInteger (GrpMainForm, 'Top', INI_mfTop);
     IniFile.WriteInteger (GrpMainForm, 'Left', INI_mfLeft);
     IniFile.WriteInteger (GrpMainForm, 'Width', INI_mfWidth);
     IniFile.WriteInteger (GrpMainForm, 'Height', INI_mfHeight);
     IniFile.WriteBool  (GrpOptions,'ShowCodeHints',INI_ShowCodeHints);
{$ENDIF}

     //Save Dissect Form Window Status
     IniFile.WriteInteger (GrpDissectForm, 'Status', INI_dsStatus);
     //save position and size only if the state is normal}
     IniFile.WriteInteger (GrpDissectForm, 'Top', INI_dsTop);
     IniFile.WriteInteger (GrpDissectForm, 'Left', INI_dsLeft);
     IniFile.WriteInteger (GrpDissectForm, 'Width', INI_dsWidth);
     IniFile.WriteInteger (GrpDissectForm, 'Height', INI_dsHeight);

     //Save Journal Form Window Status
     IniFile.WriteInteger (GrpJournalForm, 'Status', INI_jsStatus);
     //save position and size only if the state is normal}
     IniFile.WriteInteger (GrpJournalForm, 'Top', INI_jsTop);
     IniFile.WriteInteger (GrpJournalForm, 'Left', INI_jsLeft);
     IniFile.WriteInteger (GrpJournalForm, 'Width', INI_jsWidth);
     IniFile.WriteInteger (GrpJournalForm, 'Height', INI_jsHeight);

     {write MRU List}
     for i := 1 to MAX_MRU do begin
       S := SubStituteL( INI_MRUList[i], #9, '~' );
       IniFile.WriteString(GrpMRU,'Client'+inttostr(i), S );
     end;

     {write internet settings}
     Inifile.WriteInteger(GrpInternet,'ConnectTimeout',INI_INTERNET_TIMEOUT);

     {options}
     IniFile.WriteBool   (GrpOptions,'ToolBarCaptions',INI_ShowToolbarCaptions);
     IniFile.WriteBool   (GrpOptions,'ClientProperties', INI_ShowClientProperties);
     IniFile.WriteBool   (GrpOptions,'ShowFormHints',INI_ShowFormHints);
     IniFile.WriteBool   (GrpOptions,'ShowPrintOptions',INI_ShowPrintOptions);
     IniFile.WriteBool   (GrpOptions,'AllowCheckOut',INI_AllowCheckOut);
     IniFile.WriteInteger(GrpOptions,'AutoSaveTime',INI_AutoSaveTime);

     IniFIle.WriteString(GrpOptions,'CheckoutDir',INI_CheckoutDir);
     IniFIle.WriteString(GrpOptions,'CheckinDir',INI_CheckInDir);
     IniFile.WriteBool  (GrpOptions, 'PlaySounds', INI_PlaySounds );

     IniFile.WriteString(GrpOptions,'Profile',INI_MAPI_Profile);
     IniFile.WriteString(GrpOptions,'Account',INI_SMTP_Account);
     IniFile.WriteString(GrpOptions,'MailType',INI_MAIL_Type);
     IniFile.WriteBool(GrpOptions,'UseExtended', INI_MAPI_UseExtended);
     IniFile.WriteBool  (GrpOptions,'DefaultProfile',INI_MAPI_Default);
     IniFile.WriteString(GrpOptions,'SMTPServer',INI_SMTP_Server);
     IniFile.WriteBool  (GrpOptions,'AuthReq',INI_SMTP_Auth);
     IniFile.WriteBool  (GrpOptions,'UseSSL',INI_SMTP_UseSSL);
     IniFile.WriteString(GrpOptions,'SMTPFrom',INI_SMTP_FROM);
     IniFile.WriteString(GrpOptions,'PortNo',INI_SMTP_PORTNO);
     IniFile.WriteString(GrpOptions,'CodingFont',INI_Coding_Font);
     IniFile.WriteString(GrpOptions,'ReportStyle',INI_Report_Style);
     IniFile.WriteInteger(GrpOptions,'UIStyle', INI_UI_Style);

     EncryptedPassword := EncryptPass16( MAIL_PASS_KEY, INI_MAPI_Password);
     iniFile.WriteString(GrpKeyring,'Key1', EncryptedPassword);
     EncryptedPassword := EncryptPass16( MAIL_PASS_KEY, INI_SMTP_Password);
     iniFile.WriteString(GrpKeyring,'Key2', EncryptedPassword);

     {$IFDEF SmartBooks}
     IniFile.WriteString(GrpSmartBooks,'Default File',INI_DefaultFile);
     IniFile.WriteBool  (GrpSmartBooks,'Edit Mask',INI_EditAcctMask);
     IniFile.WriteBool  (GrpSmartBooks,'Access Setup',INI_AccessSetup);
     IniFile.WriteString(GrpSmartBooks,'Chart Dir',INI_ChartDir);
     IniFile.WriteBool  (GrpSmartBooks,'Backup on Exit',INI_BackupOnExit);
     IniFile.WriteString(GrpSmartBooks,'Backup Drive',INI_BackupDrive);
     IniFile.WriteString(GrpSmartBooks,'HelpFilePath',INI_HelpFilePath);
     {$ENDIF}

     IniFile.WriteBool  (GrpDontShowMe, 'EditChartGST', INI_DontShowMe_EditChartGST);
     IniFile.WriteBool  (GrpDontShowMe, 'OpeningBalancesWarning', INI_DontShowMe_NoOpeningBalances);

     IniFile.WriteString( GrpCustom, 'DefaultUser', INI_Default_User_Code);

     //Erase Old Settings
     try
        if ( IniFile.ValueExists( GrpBConnect, 'ProxyLoginReqd')) or
           ( IniFile.ValueExists( GrpBConnect, 'PrimaryHost'))
        then begin
           IniFile.EraseSection( GrpBConnect);
        end;

        if IniFile.ValueExists( 'ColumnWidths', 'Col0') then begin
           IniFile.EraseSection( 'ColumnWidths');
        end;
     except
        ;  //dont really care if an exception raised, just try again next time
     end;

     //New BConnect Settings
     IniFile.WriteString ( GrpBConnect, 'BCPrimaryHost',   INI_BCPrimaryHost);
     IniFile.WriteString ( GrpBConnect, 'BCSecondardHost', INI_BCSecondaryHost);
     IniFile.WriteInteger( GrpBConnect, 'BCPrimaryPort',   INI_BCPrimaryPort);
     IniFile.WriteInteger( GrpBConnect, 'BCSecondaryPort', INI_BCSecondaryPort);
     IniFile.WriteInteger( GrpBConnect, 'Timeout',       INI_BCTimeout);
     IniFile.WriteBool   ( GrpBConnect, 'UseCustom',     INI_BCCustomConfig);

     IniFile.WriteBool   ( GrpBConnect, 'UseProxy',      INI_BCUseProxy);
     IniFile.WriteString ( GrpBConnect, 'ProxyHost',     INI_BCProxyHost);
     IniFile.WriteInteger( GrpBConnect, 'ProxyPort',     INI_BCProxyPort);
     IniFile.WriteString ( GrpBConnect, 'ProxyUsername', INI_BCProxyUsername);
     EncryptedPassword := EncryptPass16( BConnectPassKey, INI_BCProxyPassword);
     IniFile.WriteString ( GrpKeyring,'Key3',EncryptedPassword);
     IniFile.WriteBool   ( GrpBConnect, 'UseWinInet',      INI_BCUseWinInet);
     IniFile.WriteInteger( GrpBConnect, 'ProxyAuthMethod', INI_BCProxyAuthMethod);
     IniFile.WriteBool   ( GrpBConnect, 'UseFirewall',     INI_BCUseFirewall);
     IniFile.WriteString ( GrpBConnect, 'FirewallHost',    INI_BCFirewallHost);
     IniFile.WriteInteger( GrpBConnect, 'FirewallPort',    INI_BCFirewallPort);
     IniFile.WriteInteger( GrpBConnect, 'FirewallType',    INI_BCFirewallType);
     IniFile.WriteBool   ( GrpBConnect, 'UseFirewallAuth', INI_BCFirewallUseAuth);
     IniFile.WriteString ( GrpBConnect, 'FirewallUsername',INI_BCFirewallUsername);
     EncryptedPassword := EncryptPass16( BConnectPassKey, INI_BCFirewallPassword);
     IniFile.WriteString ( GrpKeyring,'Key4',EncryptedPassword);

     IniFile.WriteString( GrpOptions, 'BackupDir', INI_BackupDir);
     IniFile.WriteInteger( GrpOptions, 'BackupLevel', INI_BackupLevel);
     IniFile.WriteBool( GrpOptions, 'BackupOverwrite', INI_BackupOverwrite);

     // LeanEngage
     IniFile.WriteString( GrpLeanEngage, ikLeanEngage_BASE_URL,
       INI_LeanEngage_BASE_URL );

     If not Assigned(AdminSystem) then
       IniFile.WriteInteger( GrpOptions, 'MaxNarrationLength', INI_MAX_EXTRACT_NARRATION_LENGTH);

     if INI_SOL6_SYSTEM_PATH <> '' then
       IniFile.WriteString( GrpOptions, 'Sol6Dir', INI_SOL6_SYSTEM_PATH);

     IniFile.WriteString(GrpOptions,'CustomColours',INI_CustomColors);

     IniFile.WriteInteger( GrpInfo, 'IniVersion', BK5_INI_VERSION);
   finally
     IniFile.UpdateFile;
     IniFile.Free;
   end;
end;

//------------------------------------------------------------------------------
{$IFNDEF SmartBooks}
procedure ReadPracticeINI;
//reads in any practice wide settings
var
  i : integer;
  PracIniFile : TMemIniFile;
  SecsToWait   : integer;
  Orig_Version : integer;

  SaveRequired : boolean;
  StrGuid : string;
  Guid : TGuid;

  function IsPractice : boolean;
  begin
    Result := assigned(AdminSystem) or
              CheckDBCreateParam or
              CheckDBCreateParamNoRun or
              BKFileExists(DATADIR + SYSFILENAME);
  end;

begin
   SaveRequired := false;

   PracIniFile := TMemIniFile.Create(ExecDir + PRACTICEINIFILENAME);
   try
      with PracINIFile do begin
        // Moved to db - keep reading so we can upgrade, but no longer write, and delete on upgrade
        PRACINI_ForceLogin         := ReadBool( GrpPracEnv,'ForceLogin',false);
        PRACINI_CustomBitmapFilename := ReadString(GrpPracCustom,'BitmapFileName','');
        PRACINI_AutoPrintSchdRepSummary := ReadBool( GrpPracEnv, 'AutoPrintSchdSummary', false);
        PRACINI_IgnoreQtyInDownload  := ReadBool(    GrpPracEnv, 'IgnoreQuantityInDownload',false);

        // These will be overriden with admin system settings later, after admin system has been loaded
        PRACINI_DefaultCodeEntryMode    := ReadInteger( GrpPracEnv, 'DefaultCodeEntryMode', 1); //Restricted
        PRACINI_DefaultDissectionMode   := ReadInteger( GrpPracEnv, 'DefaultDissectMode', 0); //ALL
        PRACINI_CopyNarrationDissection := ReadBool( GrpPracEnv, 'CopyNarrationToDissection', False);
        PRACINI_RoundCashFlowReports := ReadBool( GrpPracEnv, 'RoundCashFlowReports', false);
        PRACINI_UseXLonChartOrder    := ReadBool(    GrpPracEnv, 'UseXlonChartOrder', false);
        PRACINI_ExtractMultipleAccountsToPA := ReadBool( GrpPracEnv, 'AllowMultiPA', false);
        PRACINI_ExtractJournalsAsPAJournals := ReadBool( GrpPracEnv, 'ExtractAsPAJournals',false);
        PRACINI_ExtractQuantity      := ReadBool(    GrpPracEnv, 'ExtractQuantity', True);
        PRACINI_ExtractDecimalPlaces := ReadInteger( GrpPracEnv, 'ExtractDecimalPlaces', 4);
        PRACINI_ExtractZeroAmounts := ReadBool(GrpPracEnv,'ExtractZeroAmounts', PRACINI_ExtractZeroAmounts);
        PRACINI_Reports_NewPage    := ReadBool(GrpPracPrint,'NewPage',false);

        PRACINI_RemoveGST          := ReadBool( GrpPracEnv,'RemoveGST',false);
        PRACINI_PromptforGST       := ReadBool( GrpPracEnv,'PromptForGST',false);

        PRACINI_OSAdminOnly        := ReadBool( GrpPracEnv,'OSAdminOnly',true);
        PRACINI_CreateCSVFile      := ReadBool( GrpPracEnv,'CreateCSVFile',false);
        PRACINI_ValidateArchive    := ReadBool( GrpPracEnv,'ValidateArchive',true);
        PRACINI_ValidateArchiveDownloadOnly := ReadBool( GrpPracEnv, 'ValidateArchiveDownloadOnly',true);
        PRACINI_DisableBankLRNCheck         := ReadBool( GrpPracEnv, 'DisableBankLRNCheck', false);

        PRACINI_AllowAdvanceOptions:= ReadBool( GrpPracEnv,'AllowAdvancedAO', false);
        PRACINI_Reports_GrandTotal := ReadBool(GrpPracPrint,'GrandTotal',false);

        PRACINI_IgnoreDiskImageVersion := ReadBool( GrpPracDev, 'IgnoreDiskImageVersion', false);

        PRACINI_CurrentVersion     := ReadString(GrpPracInfo,'Version','');
        //read the seconds to wait for the admin system lock to be cleared before raising
        //an error.  cannot be set to less than 5 seconds
        SecsToWait := ReadInteger(GrpPracNetwork,'SecondsToWaitForAdmin', DEFAULT_SECS_TO_WAIT_FOR_ADMIN);
        if SecsToWait < 5 then
           SecsToWait := 5;
        PRACINI_TicksToWaitForAdmin  := SecsToWait * 1000;  //convert to milliseconds
        PRACINI_DoNotReportFirstRun  := ReadBool( GrpPracNetwork, 'DoNotReportFirstRun', false);
        PRACINI_DontAskForPGDiskNo   := ReadBool( GrpPracDev, 'NoPGDiskNo', false);

        PRACINI_MinLogFileSize       := ReadInteger( GrpPracEnv, 'MinLogFileSizeK', DEFAULT_MIN_LOG_KB);
        PRACINI_MaxLogFileSize       := ReadInteger( GrpPracEnv, 'MaxLogFileSizeK', DEFAULT_MAX_LOG_KB);
        PRACINI_LogBackupDir         := ReadString(  GrpPracEnv, 'LogArchiveDir', '');

        PRACINI_ViewOpeningBalanceJournals := ReadBool( GrpPracEnv, 'ViewOpeningBalances', false);
        PRACINI_MYOBStripAlpha       := ReadBool( GrpPracEnv, 'MYOBStripAlpha', false);
        PRACINI_AutoSaveTime         := ReadInteger( GrpPracEnv, 'AutoSaveTime', 5);
        if PRACINI_AutoSaveTime < 0 then
          PRACINI_AutoSaveTime := 0;

        PRACINI_ExportReports        := ReadBool(    GrpPracEnv, 'ExportReports',False);

        PRACINI_AlwaysReloadAdmin    := ReadBool( GrpPracDev, 'AlwaysReloadAdmin', false);
        PRACINI_ShowStatistics       := ReadBool( GrpPracDev, 'ShowStatistics', false);

        PRACINI_msToWaitForWinfax    := ReadInteger( GrpPracEnv, 'msToWaitForWinfax', DefaultWaitForWinfax);
        PRACINI_msToWaitForWinfaxPrinter := ReadInteger( GrpPracEnv, 'msToWaitForWinfaxPrinter', DefaultWaitForWinfaxPrinter);
        if PRACINI_msToWaitForWinfaxPrinter < 0 then
          PRACINI_msToWaitForWinfaxPrinter := 0;
        PRACINI_HideWinFaxPro        := ReadBool(GrpPracEnv, 'HideWinFaxPro', true);

        PRACINI_mmFaxBannerHeight := ReadInteger( GrpPracEnv, 'mmFaxBannerHeight', DefaultFaxBannerHeight);
        PRACINI_SuppressBanner := ReadBool( GrpPracEnv,'SuppressFaxBanner', True);

        PRACINI_PostingAlwaysTrue := ReadBool( GrpPracEnv,'PostingAlwaysTrue', false);
        PRACINI_AllowOffsiteDiskDownload := ReadBool( GrpPracEnv, 'AllowOffsiteDiskDownload', False);

        PRACINI_DoubleGraphGridLines := ReadBool( GrpPracEnv,'DoubleGraphGridLines', False);
        PRACINI_GraphPrintResolution := ReadInteger( GrpPracEnv,'GraphResolution',0);

        PRACINI_CSVExport := ReadBool( GrpPracEnv,'CSVExport', False);

        PRACINI_ShowAcclipseInOz := ReadBool( GrpPracEnv,'ShowAcclipseInOz', False);

        PRACINI_ShowImportExportInOffsite := ReadBool( GrpPracEnv,'ShowImportExportInOffsite', False);

        PRACINI_RestrictFileFormats := ReadBool( GrpPracEnv,'RestrictFF', True);

        PRACINI_InstListLinkNZ := ReadString(GrpPracLinks,'InstitutionListNZ', TUrls.DefInstListLinkNZ);
        PRACINI_InstListLinkAU := ReadString(GrpPracLinks,'InstitutionListAU', TUrls.DefInstListLinkAU);
        PRACINI_InstListLinkUK := ReadString(GrpPracLinks,'InstitutionListUK', TUrls.DefInstListLinkUK);

        PRACINI_OnlineLink := ReadString(GrpPracLinks , 'OnlineLink', '');

        PRACINI_SecureFormLinkNZ := ReadString(GrpPracLinks,'SecureFormLinkNZ', TUrls.DefSecureFormLinkNZ);
        PRACINI_SecureFormLinkAU := ReadString(GrpPracLinks,'SecureFormLinkAU', TUrls.DefSecureFormLinkAU);
        PRACINI_IBizzFormLinkAU := ReadString(GrpPracLinks,'IBizzFormLinkAU', TUrls.DefIBizzFormLinkAU);
        PRACINI_AdditionalFormLinkAU := ReadString(GrpPracLinks,'AdditionalFormLinkAU', TUrls.DefAdditionalFormLinkAU);

        PRACINI_NZCashMigrationURLOverview1 := ReadString(GrpPracLinks,'NZCashMigrationURLOverview1', TUrls.DefaultNZCashMigrationURLOverview1);
        PRACINI_AUCashMigrationURLOverview1 := ReadString(GrpPracLinks,'AUCashMigrationURLOverview1', TUrls.DefaultAUCashMigrationURLOverview1);
        PRACINI_NZCashMigrationURLOverview2 := ReadString(GrpPracLinks,'NZCashMigrationURLOverview2', TUrls.DefaultNZCashMigrationURLOverview2);
        PRACINI_AUCashMigrationURLOverview2 := ReadString(GrpPracLinks,'AUCashMigrationURLOverview2', TUrls.DefaultAUCashMigrationURLOverview2);

        PRACINI_DefaultCashbookForgotPasswordURL := ReadString(GrpPracLinks,'DefaultCashbookForgotPasswordURL', TUrls.DefaultCashbookForgotPasswordURL);
        PRACINI_DefaultCashbookLoginNZURL := ReadString(GrpPracLinks,'DefaultCashbookLoginNZURL', TUrls.DefaultCashbookLoginNZURL);
        PRACINI_DefaultCashbookLoginAUURL := ReadString(GrpPracLinks,'DefaultCashbookLoginAUURL', TUrls.DefaultCashbookLoginAUURL);

        // hidden readonly cashbook settings
        PRACINI_CashbookAPILoginURL    := ReadString(GrpPracLinks,'CashbookAPILoginURL', TUrls.CashbookAPILoginURL);
        PRACINI_CashbookAPILoginID     := ReadString(GrpPracLinks,'CashbookAPILoginID', 'bankLink-practice5');
        PRACINI_CashbookAPILoginSecret := ReadString(GrpPracLinks,'CashbookAPILoginSecret', 'z1sb6ggkfhlOXip');
        PRACINI_CashbookAPILoginScope  := ReadString(GrpPracLinks,'CashbookAPILoginScope', 'AccountantsFramework CompanyFile Assets la.global mydot.assets.read mydot.contacts.read practice.online client.portal mydot.assets.write mydot.orders.write mydot.bankfeeds.read mydot.bankfeeds.write');

        PRACINI_CashbookAPIFirmsURL        := ReadString(GrpPracLinks,'CashbookAPIFirmsURL', TUrls.CashbookAPIFirmsURL);
        PRACINI_CashbookAPIUploadURL       := ReadString(GrpPracLinks,'CashbookAPIUploadURL', TUrls.CashbookAPIUploadURL);
        PRACINI_CashbookAPIUploadDataStore := ReadString(GrpPracLinks,'CashbookAPIUploadDataStore', 'assetsmigrationstore-prod');
        PRACINI_CashbookAPIUploadQueue     := ReadString(GrpPracLinks,'CashbookAPIUploadQueue', 'Production-Banklink-SQS');

        PRACINI_CashbookAPIBusinessesURL := ReadString(GrpPracLinks,'CashbookAPIBusinessesURL', TUrls.CashbookAPIBusinessesURL);
        PRACINI_CashbookTransactionViewURL := ReadString(GrpPracLinks,'CashbookTransactionViewURL', TUrls.CashbookTransactionViewURL);
        PRACINI_CashbookAPITransactionsURL := ReadString(GrpPracLinks,'CashbookAPITransactionsURL', TUrls.CashbookAPITransactionsURL);
        PRACINI_CashbookAPIJournalsURL := ReadString(GrpPracLinks,'CashbookAPIJournalsURL', TUrls.CashbookAPIJournalsURL);
        PRACINI_CashbookAPICOAURL := ReadString(GrpPracLinks,'CashbookAPICOAURL', TUrls.CashbookAPICOAURL);

        PRACINI_CashbookModifiedCodeCount  := ReadInteger( GrpPracInfo, 'CashbookModifiedCodeCount', 0);

        // Sets Defaults if no data exists
        if IsPractice then
          PRACINI_GST101Link := ReadString(GrpPracLinks ,'Gst101',DefLinkTaxAgentGSTReturn)
        else
          PRACINI_GST101Link := ReadString(GrpPracLinks ,'Gst101',DefLinkGST_Books);

        // Updates data if set to old defaults
        if (Sametext(PRACINI_GST101Link, DefLinkGST101) or Sametext(PRACINI_GST101Link, DefLinkGST103)) and
           (IsPractice) then
          PRACINI_GST101Link := DefLinkTaxAgentGSTReturn;

        PRACINI_ShowSol6systems := ReadBool( GrpPracEnv,'ShowSol6Systems', False);
        PRACINI_MYOB_AO_Systems := ReadBool( GrpPracEnv,'Show_MYOB_AO_MP_Systems', False);

        {$IFDEF SmartLink}
        PRACINI_FingertipsURL := ReadString( GrpPracFingerTips,'URL', '');
        PRACINI_FingertipsSQL_IP := ReadString( GrpPracFingerTips, 'SQL_IP', '');
        PRACINI_FingertipsTimeout := ReadInteger( GrpPracFingerTips,'timeout', 60);
{$ENDIF}
        PRACINI_DisableCheckInCheckOut := ReadBool(GrpPracEnv,'DisableCheckInCheckOut',False);
{$IFDEF CSVImport}
        PRACINI_AllowCSVImport := ReadBool( GrpPracEnv, 'CSVION', False);
{$ENDIF}
        PRACINI_PaperSmartBooks  := ReadBool(GrpPracEnv,'PaperSmartBooks',False);
        PRACINI_CRCFileTest  := ReadBool(GrpPracEnv,'CRCFileTest',False);

        PRACINI_FuelCreditRates := ReadString(GrpPracEnv,'FuelCreditRates', '15.543,19.0715,38.143');
        PRACINI_Check_Data_Minutes := ReadInteger(GrpPracEnv, 'CheckDataMinutes',30); // read only at the moment

        PRACINI_AutoUpdateProcessing := ReadBool( GrpPracEnv,'AutoUpdateProcessing', PRACINI_AutoUpdateProcessing);
        PRACINI_AllowChartRemap      := ReadBool( GrpPracEnv,'AllowChartRemap', PRACINI_AllowChartRemap);
        PRACINI_AllowHistoricalImport :=  ReadBool( GrpPracEnv,'AllowHistoricalImport', PRACINI_AllowHistoricalImport);
        PRACINI_ReportMemoryLeak := ReadBool(GrpPracEnv,'ReportMemoryLeak', PRACINI_ReportMemoryLeak);

        PRACINI_ShowProSuper := ReadBool(GrpPracEnv,'ShowProSuper', PRACINI_ShowProSuper);
        PRACINI_ShowRewardSuper := ReadBool(GrpPracEnv,'ShowRewardSuper', PRACINI_ShowRewardSuper);

        Orig_Version   := ReadInteger( GrpPracInfo, 'INIVersion', PRAC_INI_VERSION);

        UseDefaultPrinter        := ReadBool  (GrpOptions,'PreviewDefaultPrinter',false);
        PRACINI_MAPI_MaskError   := ReadString ( GrpMAPI, 'MaskError', '');

        //Exchange Rate Columns
        for i := Low(PRACINI_ER_Column_Widths) to high(PRACINI_ER_Column_Widths) do begin
          PRACINI_ER_Column_Widths[i] := ReadInteger( GrpExchangeRates, 'ColWidth' + inttostr( i), -1);
          PRACINI_ER_Column_Positions [i] := ReadInteger( GrpExchangeRates, 'ColPos' + inttostr( i), -1);
        end;

        PRACINI_FastDownloadStatsUpdate := ReadBool( GrpPracEnv,'FastDownloadStatsUpdate', PRACINI_FastDownloadStatsUpdate);

        //Overwrite BankLink Online URL
        PRACINI_BankLink_Online_Books_URL := ReadString( GrpPracEnv, 'BankLinkOnlineBooksURL', TUrls.BooksOnlineDefaultUrl);
        //Overwrite BankLink Online BLOPI URL
        PRACINI_BankLink_Online_BLOPI_URL := ReadString( GrpPracEnv, 'BankLinkOnlineBlopiUrl', '');
        PRACINI_DataPlatform_Services_URL := ReadString( GrpPracEnv, 'DataPlatformServicesURL', '');

        PRACINI_BankLink_Online_Services_URL := ReadString( GrpPracEnv, 'BankLinkOnlineServicesURL', TUrls.OnlineServicesDefaultUrl);

        PRACINI_IPClientLocking_SwitchedOn  := ReadBool( GrpLocking, 'IPClientLockingSwitchedOn', false);
        PRACINI_IPClientLocking_UDP_Server_IP := ReadString( GrpLocking, 'IPClientLockingUDPServerIP', '');
        PRACINI_IPClientLocking_UDP_Server_Port := ReadInteger( GrpLocking, 'IPClientLockingUDPServerPort', -1);

        PRACINI_IPClientLocking_UDP_Client_Port := ReadInteger( GrpLocking, 'IPClientLockingUDPClientPort', 4323);
        PRACINI_IPClientLocking_UDP_BuffInitSize := ReadInteger( GrpLocking, 'IPClientLockingUDPBuffInitSize', 1024);
        PRACINI_IPClientLocking_DiscoveryTimeOut := ReadInteger( GrpLocking, 'IPClientLockingDiscoveryTimeOut', 60000);
        PRACINI_IPClientLocking_UDPTimeOut := ReadInteger( GrpLocking, 'IPClientLockingUDPTimeOut', 100);
        PRACINI_IPClientLocking_LockTimeOut := ReadInteger( GrpLocking, 'IPClientLockingLockTimeOut', 60000);
        PRACINI_IPClientLocking_TCPTimeOut := ReadInteger( GrpLocking, 'IPClientLockingTCPTimeOut', 100);
        PRACINI_IPClientLocking_ProcessMessageDelay := ReadInteger( GrpLocking, 'IPClientLockingProcessMessageDelay', 250);

        {Disable LeanEngage Switch}
        PRACINI_Disable_LeanEngage := ReadBool(GrpPracEnv, ikDisableLeanEngage, false );
                                                                       
        {Disable Promo Window Switch}
        PRACINI_Disable_Promo_Window := ReadBool(GrpPracEnv, ikDisablePromoWindow, false );

        {BGL API URL}
        PRACINI_BGL360_API_URL := ReadString(GrpPracLinks, ikBGL360_API_URL, TUrls.DefBGL360APIUrl);
        PRACINI_Random_Key := ReadString(GrpPracThirdParty, ikRandom_Key, OpenSSLEncription.GetRandomKey);
        PRACINI_BGL360_Client_ID :=
          ReadString( GrpPracThirdParty, ikBGL360_Client_ID,              // Read PRACINI_BGL360_Client_ID from Inifile, if it EXISTS!!
          EncryptAToken( Def_Production_BGL360_Client_ID, PRACINI_Random_Key)); // If not use the original constant value declared in Globals.pas
        PRACINI_BGL360_Client_Secret :=
          ReadString( GrpPracThirdParty, ikBGL360_Client_Secret,             // Read PRACINI_BGL360_Client_Secret from Inifile, if it EXISTS!!
          EncryptAToken( Def_Production_BGL360_Client_Secret, PRACINI_Random_Key)); // If not use the original constant value declared in Globals.pas

        // Ensure that anyone that still has the original default is upgraded to the new default  
        if sameText( PRACINI_BGL360_Client_ID, EncryptAToken( Def_Original_BGL360_Client_ID, PRACINI_Random_Key)) then
          PRACINI_BGL360_Client_ID := EncryptAToken( Def_Production_BGL360_Client_ID, PRACINI_Random_Key);
        if sameText( PRACINI_BGL360_Client_Secret, EncryptAToken( Def_Original_BGL360_Client_Secret, PRACINI_Random_Key)) then
          PRACINI_BGL360_Client_Secret := EncryptAToken( Def_Production_BGL360_Client_Secret, PRACINI_Random_Key);

        {Contentful API URL}
        PRACINI_Contentful_API_URL := ReadString(GrpPracLinks, ikContentful_API_URL, TUrls.DefContentfulAPIUrl);

        CreateGuid(Guid);
        StrGuid := TrimedGuid(Guid);
        PRACINI_IPClientLocking_GROUP_ID := ReadString( GrpLocking, 'IPClientLockingGroupID', StrGuid);

        InitLocking(PRACINI_IPClientLocking_SwitchedOn,
                    PRACINI_IPClientLocking_UDP_Client_Port,
                    PRACINI_IPClientLocking_UDP_BuffInitSize,
                    PRACINI_IPClientLocking_DiscoveryTimeOut,
                    PRACINI_IPClientLocking_UDPTimeOut,
                    PRACINI_IPClientLocking_LockTimeOut,
                    PRACINI_IPClientLocking_TCPTimeOut,
                    PRACINI_IPClientLocking_ProcessMessageDelay,
                    PRACINI_IPClientLocking_UDP_Server_IP,
                    PRACINI_IPClientLocking_UDP_Server_Port,
                    PRACINI_IPClientLocking_GROUP_ID);

        if Orig_Version < PRAC_INI_VERSION then begin
          // moved to db
          DeleteKey(GrpPracEnv, 'ForceLogin');
          EraseSection(GrpPracCustom);
          DeleteKey(GrpPracEnv, 'AutoPrintSchdSummary');
          DeleteKey(GrpPracEnv, 'IgnoreQuantityInDownload');
          SaveRequired := True;
        end;
      end;
   finally
     if SaveRequired then
     begin
       FileLocking.ObtainLock( ltPracIni, TimeToWaitForPracINI );
       try
         PracIniFile.UpdateFile;
       finally
         FileLocking.ReleaseLock( ltPracINI);
       end;
     end;

     PracIniFile.Free;
   end;

   //immediately save ini if fields upgraded
   if SaveRequired then
   begin
     FileLocking.ObtainLock( ltPracIni, TimeToWaitForPracINI );
     try
       WritePracticeINI;
     finally
       FileLocking.ReleaseLock( ltPracINI);
     end;
   end;
end;

//------------------------------------------------------------------------------
procedure WritePracticeINI;
//write back the bk5Prac.ini file with the current values.  Does not write the
//SecondsToWait entry
var
   i : integer;
   PracIniFile : TMemIniFile;
   SecsToWait  : integer;
   sMsg        : String;
begin
   try
      PracIniFile := TMemIniFile.Create(ExecDir + PRACTICEINIFILENAME);
      try
         with PracINIFile do begin
           WriteBool( GrpPracEnv,    'RemoveGST'   ,PRACINI_RemoveGST);
           WriteBool( GrpPracEnv,    'PromptForGST',PRACINI_PromptForGST);

           WriteBool(    GrpPracPrint, 'NewPage'     ,    PRACINI_Reports_NewPage);
           WriteBool(    GrpPracPrint, 'GrandTotal'  ,    PRACINI_Reports_GrandTotal);
           WriteString(  GrpPracInfo,  'Version'     ,    PRACINI_CurrentVersion);

           WriteBool(    GrpPracEnv, 'RoundCashFlowReports', PRACINI_RoundCashFlowReports);
           WriteBool(    GrpPracEnv, 'UseXlonChartOrder', PRACINI_UseXLonChartOrder);
           WriteBool(    GrpPracEnv, 'AllowMultiPA', PRACINI_ExtractMultipleAccountsToPA);
           WriteBool(    GrpPracEnv, 'ExtractAsPAJournals', PRACINI_ExtractJournalsAsPAJournals);
           WriteBool(    GrpPracEnv, 'ExtractQuantity', PRACINI_ExtractQuantity);
           WriteInteger( GrpPracenv, 'ExtractDecimalPlaces', PRACINI_ExtractDecimalPlaces);
           WriteBool(    GrpPracEnv, 'ExtractZeroAmounts', PRACINI_ExtractZeroAmounts);

           WriteInteger( GrpPracEnv, 'MinLogFileSizeK', PRACINI_MinLogFileSize);
           WriteInteger( GrpPracEnv, 'MaxLogFileSizeK', PRACINI_MaxLogFileSize);
           WriteString(  GrpPracEnv, 'LogArchiveDir',   PRACINI_LogBackupDir);
           WriteInteger( GrpPracEnv,'AutoSaveTime',PRACINI_AutoSaveTime);

           SecsToWait := Round( PRACINI_TicksToWaitForAdmin div 1000);
           WriteInteger( GrpPracNetwork,'SecondsToWaitForAdmin',SecsToWait);
           WriteBool(    GrpPracEnv, 'CopyNarrationToDissection', PRACINI_CopyNarrationDissection);
           WriteInteger(GrpPracEnv, 'DefaultCodeEntryMode', PRACINI_DefaultCodeEntryMode);
           WriteInteger(GrpPracEnv, 'DefaultDissectMode', PRACINI_DefaultDissectionMode);

           WriteInteger( GrpPracEnv, 'msToWaitForWinfax', PRACINI_msToWaitForWinfax);
           WriteInteger( GrpPracEnv, 'msToWaitForWinfaxPrinter', PRACINI_msToWaitForWinfaxPrinter);
           WriteBool( GrpPracEnv, 'HideWinFaxPro', PRACINI_HideWinFaxPro);

           WriteInteger( GrpPracEnv, 'mmFaxBannerHeight', PRACINI_mmFaxBannerHeight);
           WriteBool(GrpPracEnv, 'SuppressFaxBanner', PRACINI_SuppressBanner);

           WriteBool(GrpPracEnv, 'PostingAlwaysTrue', PRACINI_PostingAlwaysTrue);

           WriteBool(GrpPracEnv, 'DoubleGraphGridLines', PRACINI_DoubleGraphGridLines);
           WriteInteger(GrpPracEnv, 'GraphResolution', PRACINI_GraphPrintResolution);  //#1556

           WriteString(GrpPracLinks, 'Gst101', PRACINI_GST101Link);
           WriteString(GrpPracLinks, 'InstitutionListNZ',PRACINI_InstListLinkNZ);
           WriteString(GrpPracLinks, 'InstitutionListAU',PRACINI_InstListLinkAU);
           WriteString(GrpPracLinks, 'InstitutionListUK',PRACINI_InstListLinkUK);

           WriteString(GrpPracLinks ,'OnlineLink', PRACINI_OnlineLink);

           WriteString(GrpPracLinks, 'SecureFormLinkNZ',PRACINI_SecureFormLinkNZ);
           WriteString(GrpPracLinks, 'SecureFormLinkAU',PRACINI_SecureFormLinkAU);
           WriteString(GrpPracLinks, 'IBizzFormLinkAU',PRACINI_IBizzFormLinkAU);
           WriteString(GrpPracLinks, 'AdditionalFormLinkAU',PRACINI_AdditionalFormLinkAU);

           WriteString(GrpPracLinks, 'NZCashMigrationURLOverview1', PRACINI_NZCashMigrationURLOverview1);
           WriteString(GrpPracLinks, 'AUCashMigrationURLOverview1', PRACINI_AUCashMigrationURLOverview1);
           WriteString(GrpPracLinks, 'NZCashMigrationURLOverview2', PRACINI_NZCashMigrationURLOverview2);
           WriteString(GrpPracLinks, 'AUCashMigrationURLOverview2', PRACINI_AUCashMigrationURLOverview2);

           WriteString(GrpPracLinks, 'DefaultCashbookForgotPasswordURL', PRACINI_DefaultCashbookForgotPasswordURL);

           WriteString(GrpPracLinks, 'DefaultCashbookLoginNZURL', PRACINI_DefaultCashbookLoginNZURL);
           WriteString(GrpPracLinks, 'DefaultCashbookLoginAUURL', PRACINI_DefaultCashbookLoginAUURL);

           WriteInteger(GrpPracInfo, 'CashbookModifiedCodeCount', PRACINI_CashbookModifiedCodeCount);


{$IFDEF SmartLink}
           WriteString( GrpPracFingerTips,'URL', PRACINI_FingertipsURL);
           WriteString( GrpPracFingerTips,'SQL_IP', PRACINI_FingertipsSQL_IP);
           WriteInteger( GrpPracFingertips,'timeout',PRACINI_FingertipsTimeout);
{$ENDIF}

   //      Keep this hidden at present. Enable on a site-by-site basis.
   //        WriteBool( GrpPracEnv,'CreateCSVFile', PRACINI_CreateCSVFile );

   //      The following are not written because the are security or debug related
   //        WriteBool(GrpPracEnv,'OSAdminOnly',PRACINI_OSAdminOnly);
   //        WriteBool(GrpPracEnv,'ValidateArchiveDownloadOnly', PRACINI_ValidateArchiveDownloadOnly);
   //        WriteString(GrpPracEnv, 'ELSDir'...
   //        WriteString(GrpPracEnv, 'XMLDir'...
   //        WriteBool( GrpPracEnv, 'ValidateArchive'...
   //        WriteBool( GrpPracEnv, 'DisableBankLRNCheck'...
   //        WriteInteger( GrpPracEnv, 'DefaultDissectMode'...
           WriteString(GrpPracEnv,'FuelCreditRates',PRACINI_FuelCreditRates);

           //Exchange Rate Columns
           for i := Low(PRACINI_ER_Column_Widths) to high(PRACINI_ER_Column_Widths) do begin
             if PRACINI_ER_Column_Widths[i] <> -1 then
               WriteInteger( GrpExchangeRates, 'ColWidth' + inttostr( i), PRACINI_ER_Column_Widths[i]);
             if PRACINI_ER_Column_Positions[i] <> -1 then
               WriteInteger( GrpExchangeRates, 'ColPos' + inttostr( i), PRACINI_ER_Column_Positions[i]);
           end;

           WriteBool(GrpLocking, 'IPClientLockingSwitchedOn', PRACINI_IPClientLocking_SwitchedOn);
           WriteString(GrpLocking, 'IPClientLockingUDPServerIP', PRACINI_IPClientLocking_UDP_Server_IP);
           WriteInteger(GrpLocking, 'IPClientLockingUDPServerPort', PRACINI_IPClientLocking_UDP_Server_Port);  //#1556

           WriteInteger(GrpLocking, 'IPClientLockingUDPClientPort', PRACINI_IPClientLocking_UDP_Client_Port);
           WriteInteger(GrpLocking, 'IPClientLockingUDPBuffInitSize', PRACINI_IPClientLocking_UDP_BuffInitSize);
           WriteInteger(GrpLocking, 'IPClientLockingDiscoveryTimeOut', PRACINI_IPClientLocking_DiscoveryTimeOut);
           WriteInteger(GrpLocking, 'IPClientLockingUDPTimeOut', PRACINI_IPClientLocking_UDPTimeOut);
           WriteInteger(GrpLocking, 'IPClientLockingLockTimeOut', PRACINI_IPClientLocking_LockTimeOut);
           WriteInteger(GrpLocking, 'IPClientLockingTCPTimeOut', PRACINI_IPClientLocking_TCPTimeOut);
           WriteInteger(GrpLocking, 'IPClientLockingProcessMessageDelay', PRACINI_IPClientLocking_ProcessMessageDelay);
           WriteString(GrpLocking,  'IPClientLockingGroupID', PRACINI_IPClientLocking_GROUP_ID);

           WriteInteger( GrpPracInfo, 'IniVersion', PRAC_INI_VERSION);

           {BGL API URL}
           WriteString(GrpPracLinks,  'BGL360APIURL', PRACINI_BGL360_API_URL);
           WriteString(GrpPracThirdParty,  'BGL360ClientID', PRACINI_BGL360_Client_ID);
           WriteString(GrpPracThirdParty,  'BGL360ClientSecret', PRACINI_BGL360_Client_Secret);
           WriteString(GrpPracThirdParty,  'BGL360Key', PRACINI_Random_Key);

           {Contentful API URL}
           WriteString(GrpPracLinks,  'ContentfulAPIURL', PRACINI_Contentful_API_URL);
         end;
      finally
         PracIniFile.UpdateFile;
         PracIniFile.Free;
      end;
   except
      on e : Exception do begin
         sMsg := 'Error during WritePracticeINI - '+ e.Message;
         LogUtil.LogError( UnitName, sMsg);
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure WritePracticeINI_WithLock;
begin
  FileLocking.ObtainLock( ltPracIni, TimeToWaitForPracINI );
  try
    WritePracticeINI;
  finally
    FileLocking.ReleaseLock( ltPracIni );
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------
procedure UserIniUpgrade(IniFile: TMemIniFile);
var
  ProcessingPosition: Integer;
  I: Integer;
begin
  UserINI_Version := IniFile.ReadInteger(GrpUserOptions, 'Version', 1);

  //Upgrade Stuff
  if UserINI_Version < 2 then
  begin
    // upgrade: if open dialog listed my files only then set client manager view
    UserINI_CM_Filter:= UserINI_CM_Default_View;
    if (UserINI_CM_Filter = filterMyClients) and (UserINI_CM_UserFilter.IndexOf(CurrUser.Code) = -1) then
      UserINI_CM_UserFilter.Add(CurrUser.Code);
  end;

  if UserINI_Version < 3 then
  begin
    //Want to add NextGSTDue column after processing column, so need to move other columns with custom positions along one
    ProcessingPosition := UserINI_CM_Column_Positions[icid_Processing];
    if ProcessingPosition = -1 then
      ProcessingPosition := 2;

    for I := icid_Min to icid_Max do
    begin
      if UserINI_CM_Column_Positions[I] > ProcessingPosition then
        UserINI_CM_Column_Positions[I] := UserINI_CM_Column_Positions[I] + 1;
    end;
    UserINI_CM_Column_Positions[icid_NextGSTDue] := ProcessingPosition + 1;
    UserINI_CM_Column_Widths[icid_NextGSTDue] := 100;
  end;

  if UserINI_Version < 4 then
  begin
    UserINI_CES_Show_Find := True;
  end;

  UserINI_Version := USER_INI_VERSION;
end;

//------------------------------------------------------------------------------
procedure ReadUsersINI( UserCode : string);
var
  Filename : string;
  IniFile : TMemIniFile;
  i: integer;
  S: string;
  EncryptedPassword: string;
  DefColour : Integer;
begin
  Filename := ExecDir + UserCode + '.INI';

  IniFile := TMemIniFile.Create( Filename);
  try
    with INIFile do begin
      //general per user settings
      UserINI_Client_Lookup_Sort_Column := IniFile.ReadInteger(GrpUserOptions, 'ClientLookupSortColumn', 2);
      UserINI_Client_Lookup_Sort_Direction := IniFile.ReadInteger(GrpUserOptions, 'ClientLookupSortDirection', 0);

      // Lookup sort order
      UserINI_GST_Lookup_Sort_Column := IniFile.ReadInteger(GrpUserOptions, 'GSTLookupSortColumn', 0);
      UserINI_Payee_Lookup_Sort_Column := IniFile.ReadInteger(GrpUserOptions, 'PayeeLookupSortColumn', 1);
      UserINI_Job_Lookup_Sort_Column := IniFile.ReadInteger(GrpUserOptions, 'JobLookupSortColumn', 0);
      UserINI_Chart_Lookup_Sort_Column := IniFile.ReadInteger(GrpUserOptions, 'ChartLookupSortColumn', 0);
      //UserINI_Show_Promo_Window := IniFile.ReadBool(GrpUserOptions, 'ShowPromoWindow', True);
      //client manager settings
      UserINI_CM_Default_View:= IniFile.ReadInteger( GrpClientMgr, 'DefaultView', 0);
      s := IniFile.ReadString( GrpClientMgr, 'SubFilter', '');
      if S > '' then
         UserINI_CM_SubFilter := StrToInt64(S)
      else
         UserINI_CM_SubFilter:= 0;
      UserINI_CM_SubFilter_Name := IniFile.ReadString( GrpClientMgr, 'SubFilterName', FILTER_ALL);
      UserINI_CM_UserFilter := TStringList.Create;
      UserINI_CM_GroupFilter := TStringList.Create;
      UserINI_CM_ClientTypeFilter := TStringList.Create;
      UserINI_CM_UserFilter.CommaText := IniFile.ReadString( GrpClientMgr, 'UserFilter', '');
      UserINI_CM_GroupFilter.CommaText := IniFile.ReadString( GrpClientMgr, 'GroupFilter', '');
      UserINI_CM_ClientTypeFilter.CommaText := IniFile.ReadString( GrpClientMgr, 'ClientTypeFilter', '');
      UserINI_CM_ShowLegend := IniFile.ReadBool(GrpClientMgr,'ShowLegend',True);
      UserINI_CM_SortColumn := IniFile.ReadInteger( GrpClientMgr, 'SortColumn', 3);
      UserINI_CM_SortDescending := IniFile.ReadBool(GrpClientMgr,'SortDescending',True);


      //client manager column settings
      for i := icid_Min to icid_Max do
      begin
        UserINI_CM_Column_Positions[ i] := IniFile.ReadInteger( GrpClientMgr, 'ColPosition' + inttostr( i), -1);
        UserINI_CM_Column_Widths[ i] := IniFile.ReadInteger( GrpClientMgr, 'ColWidth' + inttostr( i), -1);
        UserINI_CM_Column_Visible[ i] := IniFile.ReadBool( GrpClientMgr, 'ColVisible' + inttostr( i), True);
      end;

      UserINI_CM_Var_Col_Count := IniFile.ReadInteger( GrpClientMgr, 'VarColCount', 0);
      SetLength(UserINI_CM_Var_Col_Positions, UserINI_CM_Var_Col_Count);
      SetLength(UserINI_CM_Var_Col_Widths, UserINI_CM_Var_Col_Count);
      SetLength(UserINI_CM_Var_Col_Visible, UserINI_CM_Var_Col_Count);
      SetLength(UserINI_CM_Var_Col_Guid, UserINI_CM_Var_Col_Count);
      for i := 0 to UserINI_CM_Var_Col_Count-1 do
      begin
        UserINI_CM_Var_Col_Positions[i] := IniFile.ReadInteger( GrpClientMgr, 'VarColPosition' + inttostr( i), -1);
        UserINI_CM_Var_Col_Widths[i] := IniFile.ReadInteger( GrpClientMgr, 'VarColWidth' + inttostr( i), -1);
        UserINI_CM_Var_Col_Visible[i] := IniFile.ReadBool( GrpClientMgr, 'VarColVisible' + inttostr( i), True);
        UserINI_CM_Var_Col_Guid[i] := IniFile.ReadString( GrpClientMgr, 'VarColGuid' + inttostr( i), '');
      end;

      UserINI_CM_Filter:= IniFile.ReadInteger( GrpClientMgr, 'Filter', 0);

      //Client HomePage
      UserINI_HP_GroupWidth := IniFile.ReadInteger( GrpClientHomepg, 'GroupWidth', 0);
      for i := Low(UserINI_HP_Column_Widths) to high(UserINI_HP_Column_Widths) do begin
         UserINI_HP_Column_Widths[i] := IniFile.ReadInteger( GrpClientHomepg, 'ColWidth' + inttostr( i), -1);
      end;

      //Code Entry Screen, Show Find..
      UserINI_CES_Show_Find := IniFile.ReadBool(GrpUserOptions,'ShowSECFind',UserINI_CES_Show_Find);
      UserINI_Mem_Show_Find := IniFile.ReadBool(GrpUserOptions,'ShowMEMFind',UserINI_Mem_Show_Find);

      //Favourite Reports
      UserINI_FR_GroupWidth := IniFile.ReadInteger( GrpFavouriteReports, 'GroupWidth', 0);
      for i := Low(UserINI_FR_Column_Widths) to high(UserINI_FR_Column_Widths) do begin
          UserINI_FR_Column_Widths[i] := IniFile.ReadInteger( GrpFavouriteReports, 'ColWidth' + inttostr( i), -1);
      end;

      //CustomDocuments
      UserINI_CD_GroupWidth :=  IniFile.ReadInteger( GrpCustomDocuments, 'GroupWidth', 0);

      //Report settings
      UserINI_RS_GroupWidth :=  IniFile.ReadInteger( GrpReportSettings, 'StyleGroupWidth', 0);
      //global setup/maintain clients column settings
      for i := icid_Min to icid_Max do
      begin
        UserINI_GS_Column_Positions[ i] := IniFile.ReadInteger( GrpGlobalSetup, 'ColPosition' + inttostr( i), -1);
        UserINI_GS_Column_Widths[ i] := IniFile.ReadInteger( GrpGlobalSetup, 'ColWidth' + inttostr( i), -1);
      end;
      StyleAltDefaultRowColor(DefColour);
      UserINI_GS_Grid_Alternate_Color := IniFile.ReadInteger( GrpGlobalSetup, 'GridAlternateColour', DefColour);

      UserINI_SPA_Columns := IniFile.ReadString(GrpSysAccounts,'PracticeAccounts','');
      UserINI_Show_Interim_Reports := ReadBool(GrpUserOptions,'ShowInterimReports', False);

      //Books BankLink Online username and password
      INI_BankLink_Online_Username  := IniFile.ReadString(GrpPracBankLinkOnline, 'BankLinkOnlineUsername', '');
      EncryptedPassword             := IniFile.ReadString(GrpPracBankLinkOnline, 'BankLinkOnlinePassword', '');
      INI_BankLink_Online_Password  := DecryptPass16(BANKLINK_ONLINE_PASS_KEY, EncryptedPassword);
      INI_BankLink_Online_SubDomain := IniFile.ReadString(GrpPracBankLinkOnline, 'BankLinkOnlineSubDomain', '');

      //Get and send checkbox options
//      UserINI_Client_Lookup_Available_Only := IniFile.ReadBool(GrpUserOptions, 'ClientLookupAvailableOnly', UserINI_Client_Lookup_Available_Only);
      UserINI_Client_Lookup_Flag_Read_Only := IniFile.ReadBool(GrpPracThirdParty, 'ClientLookupFlagReadOnly', UserINI_Client_Lookup_Flag_Read_Only);
      UserINI_Client_Lookup_Edit_Email     := IniFile.ReadBool(GrpPracThirdParty, 'ClientLookupEditEmail', UserINI_Client_Lookup_Edit_Email);
      UserINI_Client_Lookup_Send_Email     := IniFile.ReadBool(GrpUserOptions, 'ClientLookupSendEmail', UserINI_Client_Lookup_Send_Email);

      UserINI_Suggested_Mems_Show_Popup := IniFile.ReadBool(GrpUserOptions, 'SuggestedMemsShowPopup', UserINI_Suggested_Mems_Show_Popup);

      {my.MYOB user credentials}
      UserINI_myMYOB_Random_Key := ReadString(GrpPracmyMYOB,'MYOBRandomKey', '');
      UserINI_myMYOB_Access_Token := ReadString(GrpPracmyMYOB,'MYOBAccessToken', '');
      UserINI_myMYOB_Refresh_Token := ReadString(GrpPracmyMYOB,'MYOBRefreshToken', '');
      UserINI_myMYOB_Expires_TokenAt := ReadDateTime(GrpPracmyMYOB,'MYOBExpiresAt', 0);

      UserIniUpgrade(IniFile);

    end;
  finally
    IniFile.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure WriteUsersINI( UserCode : string);
var
  Filename : string;
  IniFile : TMemIniFile;
  i : integer;
  EncryptedPassword: string;
begin
  Filename := ExecDir + UserCode + '.INI';

  IniFile := TMemIniFile.Create( Filename);
  try
    with INIFile do begin
      //general per user settings
      IniFile.WriteInteger( GrpUserOptions, 'ClientLookupSortColumn', UserINI_Client_Lookup_Sort_Column);
      IniFile.WriteInteger( GrpUserOptions, 'ClientLookupSortDirection', UserINI_Client_Lookup_Sort_Direction);
      IniFile.WriteInteger( GrpUserOptions, 'Version', UserINI_Version);

      // Lookup sort order
      IniFile.WriteInteger( GrpUserOptions, 'GSTLookupSortColumn', UserINI_GST_Lookup_Sort_Column);
      IniFile.WriteInteger( GrpUserOptions, 'PayeeLookupSortColumn', UserINI_Payee_Lookup_Sort_Column);
      IniFile.WriteInteger( GrpUserOptions, 'JobLookupSortColumn', UserINI_Job_Lookup_Sort_Column);
      IniFile.WriteInteger( GrpUserOptions, 'ChartLookupSortColumn', UserINI_Chart_Lookup_Sort_Column);

      //Show promo window
      //IniFile.WriteBool( GrpUserOptions, 'ShowPromoWindow', UserINI_Show_Promo_Window);

      //client manager settings
      IniFile.WriteInteger( GrpClientMgr, 'DefaultView', UserINI_CM_Default_View);
      IniFile.WriteInteger( GrpClientMgr, 'Filter', UserINI_CM_Filter);
      IniFile.WriteString( GrpClientMgr, 'SubFilter', IntToStr(UserINI_CM_SubFilter));
      IniFile.WriteString( GrpClientMgr, 'SubFilterName', UserINI_CM_SubFilter_Name);
      if Assigned(UserINI_CM_UserFilter) then
        IniFile.WriteString( GrpClientMgr, 'UserFilter', UserINI_CM_UserFilter.CommaText);
      if Assigned(UserINI_CM_GroupFilter) then
        IniFile.WriteString( GrpClientMgr, 'GroupFilter', UserINI_CM_GroupFilter.CommaText);
      if Assigned(UserINI_CM_ClientTypeFilter) then
        IniFile.WriteString( GrpClientMgr, 'ClientTypeFilter', UserINI_CM_ClientTypeFilter.CommaText);
      FreeAndNil(UserINI_CM_UserFilter);
      FreeAndNil(UserINI_CM_GroupFilter);
      FreeAndNil(UserINI_CM_ClientTypeFilter);

      IniFile.WriteBool(GrpClientMgr,'ShowLegend',UserINI_CM_ShowLegend );
      //client manager column settings
      for i := icid_Min to icid_Max do
      begin
        IniFile.WriteInteger( GrpClientMgr, 'ColPosition' + inttostr( i), UserINI_CM_Column_Positions[ i]);
        IniFile.WriteInteger( GrpClientMgr, 'ColWidth' + inttostr( i), UserINI_CM_Column_Widths[ i]);
        IniFile.WriteBool( GrpClientMgr, 'ColVisible' + inttostr( i), UserINI_CM_Column_Visible[ i]);
      end;

      IniFile.WriteInteger(GrpClientMgr, 'VarColCount', UserINI_CM_Var_Col_Count );
      for i := 0 to UserINI_CM_Var_Col_Count-1 do
      begin
        IniFile.WriteInteger( GrpClientMgr, 'VarColPosition' + inttostr( i), UserINI_CM_Var_Col_Positions[ i]);
        IniFile.WriteInteger( GrpClientMgr, 'VarColWidth' + inttostr( i), UserINI_CM_Var_Col_Widths[ i]);
        IniFile.WriteBool( GrpClientMgr, 'VarColVisible' + inttostr( i), UserINI_CM_Var_Col_Visible[ i]);
        IniFile.WriteString( GrpClientMgr, 'VarColGuid' + inttostr( i), UserINI_CM_Var_Col_Guid[ i]);
      end;

      IniFile.WriteInteger( GrpClientMgr, 'SortColumn', UserINI_CM_SortColumn);
      IniFile.WriteBool( GrpClientMgr, 'SortDescending', UserINI_CM_SortDescending);

      IniFile.WriteBool(GrpUserOptions,'ShowSECFind',UserINI_CES_Show_Find);
      IniFile.WriteBool(GrpUserOptions,'ShowMEMFind',UserINI_Mem_Show_Find);

      //Client HomePage
      IniFile.WriteInteger( GrpClientHomepg, 'GroupWidth', UserINI_HP_GroupWidth);
      for i := Low(UserINI_HP_Column_Widths) to high(UserINI_HP_Column_Widths) do begin
         IniFile.WriteInteger( GrpClientHomepg, 'ColWidth' + inttostr( i), UserINI_HP_Column_Widths[i]);
      end;

      //Favourite Reports
      IniFile.WriteInteger( GrpFavouriteReports, 'GroupWidth', UserINI_FR_GroupWidth);
      for i := Low(UserINI_FR_Column_Widths) to high(UserINI_FR_Column_Widths) do begin
          IniFile.WriteInteger( GrpFavouriteReports, 'ColWidth' + inttostr( i), UserINI_FR_Column_Widths[i]);
      end;

      //CustomDocuments
      IniFile.WriteInteger( GrpCustomDocuments, 'GroupWidth', UserINI_CD_GroupWidth);

      //Report settings
      IniFile.WriteInteger( GrpReportSettings, 'StyleGroupWidth', UserINI_RS_GroupWidth);

      //global setup/maintain clients column settings
      for i := icid_Min to icid_Max do
      begin
        IniFile.WriteInteger( GrpGlobalSetup, 'ColPosition' + inttostr( i), UserINI_GS_Column_Positions[ i]);
        IniFile.WriteInteger( GrpGlobalSetup, 'ColWidth' + inttostr( i), UserINI_GS_Column_Widths[ i]);
      end;
      IniFile.WriteInteger( GrpGlobalSetup, 'GridAlternateColour' , UserINI_GS_Grid_Alternate_Color);

      IniFile.WriteString(GrpSysAccounts,'PracticeAccounts', UserINI_SPA_Columns);
      IniFile.WriteBool( GrpUserOptions, 'ShowInterimReports', UserINI_Show_Interim_Reports);

      //Books BankLink Online username and password
      IniFile.WriteString(GrpPracBankLinkOnline, 'BankLinkOnlineUsername', INI_BankLink_Online_Username);
      EncryptedPassword := EncryptPass16(BANKLINK_ONLINE_PASS_KEY, INI_BankLink_Online_Password);
      IniFile.WriteString(GrpPracBankLinkOnline, 'BankLinkOnlinePassword', EncryptedPassword);
      IniFile.WriteString(GrpPracBankLinkOnline, 'BankLinkOnlineSubDomain', INI_BankLink_Online_SubDomain);

      //Get and send checkbox options
      //IniFile.WriteBool(GrpUserOptions, 'ClientLookupAvailableOnly', UserINI_Client_Lookup_Available_Only);
      IniFile.WriteBool(GrpUserOptions, 'ClientLookupFlagReadOnly', UserINI_Client_Lookup_Flag_Read_Only);
      IniFile.WriteBool(GrpUserOptions, 'ClientLookupEditEmail', UserINI_Client_Lookup_Edit_Email);
      IniFile.WriteBool(GrpUserOptions, 'ClientLookupSendEmail', UserINI_Client_Lookup_Send_Email);

      IniFile.WriteBool(GrpUserOptions, 'SuggestedMemsShowPopup', UserINI_Suggested_Mems_Show_Popup);

      {my.MYOB user credentials}
      IniFile.WriteString(GrpPracmyMYOB, 'MYOBRandomKey', UserINI_myMYOB_Random_Key);
      IniFile.WriteString(GrpPracmyMYOB, 'MYOBAccessToken', UserINI_myMYOB_Access_Token);
      IniFile.WriteString(GrpPracmyMYOB, 'MYOBRefreshToken', UserINI_myMYOB_Refresh_Token);
      IniFile.WriteDateTime(GrpPracmyMYOB, 'MYOBExpiresAt', UserINI_myMYOB_Expires_TokenAt);

    end;
  finally
    IniFile.UpdateFile;
    IniFile.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure ReadAppINI;
var
  Filename: String;
  IniFile: TMemIniFile;
  CountryStr: String;
begin
  TProduct.ProductBrand := btBankLink;

  Filename := ExecDir + 'app.ini';

  if FileExists(Filename) then
  begin
    IniFile := TMemIniFile.Create(Filename);

    try
      CountryStr := IniFile.ReadString('Installer', 'Country', '');

      TProduct.ProductBrand := btMYOBBankLink;
    finally
      IniFile.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure CreateMemsFileIfNotExists();
var
  MemsIniFile : TextFile;
  Msg : string;
  MemCommentIndex : integer;
begin
  FileLocking.ObtainLock( ltMemsIni, TimeToWaitForPracINI );
  try
    try
      AssignFile(MemsIniFile, ExecDir + MEMSINIFILENAME);
      try
        Rewrite(MemsIniFile);

        for MemCommentIndex := 0 to high(MEM_COMMENTS) do
          WriteLn(MemsIniFile, MEM_COMMENTS[MemCommentIndex]);

        WriteLn(MemsIniFile, '[' + GrpMemsSupport + ']');
      finally
        CloseFile(MemsIniFile);
      end;
    except
      on e : Exception do
      begin
        Msg := 'Error creating MemsIniFile - '+ e.Message;
        LogUtil.LogError( UnitName, Msg);
      end;
    end;
  finally
    FileLocking.ReleaseLock( ltMemsIni );
  end;
end;

//------------------------------------------------------------------------------
procedure WriteMemorisationINI(aClientCode : string);
var
  MemsIniFile : TCommentMemIniFile;
  MemCommentIndex : integer;
  Msg : String;
begin
  try
    MemsIniFile := TCommentMemIniFile.Create(ExecDir + MEMSINIFILENAME);
    try
      MemsIniFile.WriteInteger( GrpMemsSupport, aClientCode, ord(MEMSINI_SupportOptions));

      for MemCommentIndex := 0 to high(MEM_COMMENTS) do
        MemsIniFile.Comments.Add(MEM_COMMENTS[MemCommentIndex]);
    finally
      MemsIniFile.UpdateFile;
      FreeAndNil(MemsIniFile);
    end;
  except
    on e : Exception do
    begin
      Msg := 'Error during write of MemsIniFile - '+ e.Message;
      LogUtil.LogError( UnitName, Msg);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure UpdateMemorisationINI_WithLock();
var
  MemsIniFile : TCommentMemIniFile;
  MemCommentIndex : integer;
  Msg : String;
begin
  if not FileExists( ExecDir + MEMSINIFILENAME) then
    CreateMemsFileIfNotExists();

  FileLocking.ObtainLock( ltMemsIni, TimeToWaitForPracINI );
  try
    try
      MemsIniFile := TCommentMemIniFile.Create(ExecDir + MEMSINIFILENAME);
      try
        for MemCommentIndex := 0 to high(MEM_COMMENTS) do
          MemsIniFile.Comments.Add(MEM_COMMENTS[MemCommentIndex]);
      finally
        MemsIniFile.UpdateFile;
        FreeAndNil(MemsIniFile);
      end;
    except
      on e : Exception do
      begin
        Msg := 'Error during write of MemsIniFile - '+ e.Message;
        LogUtil.LogError( UnitName, Msg);
      end;
    end;

  finally
    FileLocking.ReleaseLock( ltMemsIni );
  end;
end;

//------------------------------------------------------------------------------
procedure WriteMemorisationINI_WithLock(aClientCode : string);
begin
  if not FileExists( ExecDir + MEMSINIFILENAME) then
    CreateMemsFileIfNotExists();

  FileLocking.ObtainLock( ltMemsIni, TimeToWaitForPracINI );
  try
    WriteMemorisationINI(aClientCode);
  finally
    FileLocking.ReleaseLock( ltMemsIni );
  end;
end;

//------------------------------------------------------------------------------
procedure ReadMemorisationINI(aClientCode : string);
var
  MemsIniFile : TCommentMemIniFile;
  Msg : String;
begin
  if not FileExists( ExecDir + MEMSINIFILENAME) then
    CreateMemsFileIfNotExists();

  try
    MemsIniFile := TCommentMemIniFile.Create( ExecDir + MEMSINIFILENAME);
    try
      MEMSINI_SupportOptions :=
        TMemsSupportOptions(MemsIniFile.ReadInteger(GrpMemsSupport, aClientCode, 0));

      if MEMSINI_SupportOptions = meiDisableSuggestedMemsOld then
        MEMSINI_SupportOptions := meiDisableSuggestedMems;

    finally
      FreeAndNil(MemsIniFile);
    end;
  except
    on e : Exception do
    begin
      Msg := 'Error during read of MemsIniFile - '+ e.Message;
      LogUtil.LogError( UnitName, Msg);
    end;
  end;
end;

function DecryptAToken(aToken: string; RandomKey: string):string;
begin
  Result := '';

  if OpenSSLEncription.AESDecrypt(RandomKey, aToken, Result, INIT_VECTOR) then
  begin
    //EncryptedKey := OpenSSLEncription.SimpleRSAEncrypt(KeyString, GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN);
    //Result := EncryptedToken + KEY_DELIMMITER + EncryptedKey;
  end;
end;

function EncryptAToken(aToken: string;var RandomKey: string):string;
begin
  Result := '';
  if Trim(RandomKey) = '' then
    RandomKey := OpenSSLEncription.GetRandomKey;
  if OpenSSLEncription.AESEncrypt(RandomKey, aToken, Result, INIT_VECTOR) then
  begin
    //EncryptedKey := OpenSSLEncription.SimpleRSAEncrypt(KeyString, GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN);
    //Result := EncryptedToken + KEY_DELIMMITER + EncryptedKey;
  end;
end;

procedure ResetMYOBTokensInUsersINI(userCode: string);
var
  Filename : string;
  IniFile : TIniFile;
begin
  Filename := ExecDir + UserCode + '.INI';
  IniFile := TIniFile.Create( Filename);
  try
    //Reset MYOB token per user settings
    UserINI_myMYOB_Access_Token := '';
    UserINI_myMYOB_Random_Key := '';
    UserINI_myMYOB_Refresh_Token := '';
    UserINI_myMYOB_Expires_TokenAt := 0;

    IniFile.WriteString(GrpPracmyMYOB, 'MYOBRandomKey', UserINI_myMYOB_Random_Key);
    IniFile.WriteString(GrpPracmyMYOB, 'MYOBAccessToken', UserINI_myMYOB_Access_Token);
    IniFile.WriteString(GrpPracmyMYOB, 'MYOBRefreshToken', UserINI_myMYOB_Refresh_Token);
    IniFile.WriteDateTime(GrpPracmyMYOB, 'MYOBExpiresAt', UserINI_myMYOB_Expires_TokenAt);
  finally
    FreeAndNil(IniFile);
  end;
end;

end.


