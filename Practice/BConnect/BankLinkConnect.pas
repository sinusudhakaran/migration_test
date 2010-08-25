unit BankLinkConnect;
//------------------------------------------------------------------------------
{
   Title:       BankLink Connect Unit

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

function DoBankLinkConnect: integer;
function DoBankLinkOffsiteConnect : integer;
function EncryptPassword( const PlainPassword : string; IncludeDash: boolean = true ) : string;

//******************************************************************************
implementation
uses
   FormBConnect,       //https
   bkconst,
   Dialogs,
   Classes,
   Globals,
   ErrorLog,
   LogUtil,
   SysUtils,
   Admin32,
   ExtCtrls,
   Cryptcon,
   md5unit,
   forms,
   GenUtils,
   DownloadUtils,
   imagesfrm,
   WinUtils,
   SYDEFS,
   baObj32,
   baUtils,
   UsageUtils,
   FileExtensionUtils;

const
   Unitname = 'BConnect';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function B2H( B : Byte ): String;
Const
   H : Array[ 0..$F ] of Char = '0123456789ABCDEF';
Begin
   B2H := H[ B shr 4 ] + H[ B and $0F ];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function D2S( Digest : Pointer; IncludeDash: boolean ): String;
Var
   DArray : Array[ 0..15 ] of Byte;
   i  : Byte;
Begin
   Result := '';
   Move( Digest^, DArray, Sizeof( DArray ) );
   For i := 0 to 15 do
   Begin
      Result := Result + B2H( DArray[i] );
      If IncludeDash and (i < 15) then
        Result := Result + '-';
   end;
   D2S := Result;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EncryptPassword( const PlainPassword : string; IncludeDash: boolean = true) : string;
{returns the MD5 encrypted output}
var
   md5hash  : TMD5;
   passmd5,
   outarray   : array[0..16] of char;
begin
   result := '';
   outarray[16] := #0;
   passmd5  := '';
   //apply md5 algorithm to text
   md5hash := TMD5.Create(nil);
   try
       md5hash.InputType    := SourceString;
       md5hash.InputString  := PlainPassword;
       md5hash.pOutputArray := @outarray;
       md5hash.MD5_Hash;

       result               := D2S(md5Hash.pOutputArray, IncludeDash);
   finally
       md5hash.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ColorsDepthIs256 : boolean;
begin
  result := (WinUtils.GetScreenColors( Application.MainForm.Canvas.Handle) <= 256);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LogBConnectMsg( S : string);
begin
   LogUtil.LogMsg( lmInfo, Unitname, S);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function BuildStatsString : string;
var
  StatisticsData  : TStringList;
  Logins, Logouts : integer;
  LockErrors      : integer;
  ReliabilityPerc : double;
  TempAccountsLevel : integer;
  StatsDate       : string;
  SiteID          : integer;
  UnhandledErrorCount : integer;
begin
  result := '';
  try
    StatisticsData := TStringList.Create;
    try
      StatisticsData.Text := ERRORLOG.SysLog.GetStatistics;
      if StatisticsData.Text = '' then
        Exit;

      //subtract current session login
      StatsDate := StatisticsData.Values['Created'];
      Logins := StrToIntDef( StatisticsData.Values['Logins'], 0) - 1;
      Logouts := StrToIntDef( StatisticsData.Values['Logouts'], 0);
      if Logins <> 0 then
        ReliabilityPerc := Logouts/Logins * 100
      else
        ReliabilityPerc := 100.0;
      LockErrors := StrToIntDef( StatisticsData.Values['LockErrors'], 0);
      UnhandledErrorCount := StrToIntDef( StatisticsData.Values['UnHandledErrors'], 0);

      //find out if temp accounts is on
      // will now always be on because of manual data entry
      TempAccountsLevel := 1;

      if Assigned( AdminSystem) then
      begin
        if AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts] then
          TempAccountsLevel := 2;

        SiteID := AdminSystem.fdFields.fdMagic_Number;
      end
      else
        SiteID := 0;

      //verify data before submitting to webserver as could force overflows by
      //editing the stats file
      if ReliabilityPerc > 100.0 then
        ReliabilityPerc := 100.0;
      if Abs(Logins) > 1000000 then
        Logins := 9999999;
      if Abs(LockErrors) > 1000000 then
        LockErrors := 9999999;
      if Abs(UnhandledErrorCount) > 1000000 then
        UnhandledErrorCount := 9999999;
      StatsDate := Copy( StatsDate, 1, 8);

      //construct stats string
      result := Format( '"STARTS:%s,LOGINS:%d,RELIAB:%4.2f,LOCKERR:%d,ERR:%d,SITEID:%d,TMPLEVEL:%d"',
                        [ StatsDate, Logins, ReliabilityPerc, LockErrors, UnhandledErrorCount, SiteID, TempAccountsLevel]);

      //ShowMessage( result);

    finally
      StatisticsData.Free;
    end;
  except
    on E : Exception do ;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoBankLinkConnect: integer;
//returns the number of disks to process
//returns -1 if process not clicked
const
   ThisMethodName = 'DoBankLinkConnect';
var
   PasswordChanged : boolean;
   NewPassword     : string;
   VerString       : string;
   StatsString     : string;
   ImageToUse      : TImage;
begin
   LogMsg( lmInfo, Unitname, ThisMethodName + ' for ' + AdminSystem.fdFields.fdBankLink_Code);

   if ColorsDepthIs256 then
   begin
     ImageToUse := AppImages.imgBankLinkLogo256;
   end
   else
   begin
     ImageToUse := AppImages.imgBankLinkLogoHiColor;
   end;

   VerString := Globals.ShortAppName + ' ' + WinUtils.GetShortAppVersionStr;
   StatsString := BuildStatsString;
   If (Assigned(AdminSystem)) and (AdminSystem.fdFields.fdCollect_Usage_Data) then SaveUsage;
   //--------------------------- HTTPS BCONNECT -----------------------------
   with TfrmBConnectHTTPS.Create ( Application.MainForm,
                              INI_BCPrimaryHost,
                              INI_BCPrimaryPort,
                              INI_BCSecondaryHost,
                              INI_BCSecondaryPort,
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
                              INI_BCFirewallType,
                              INI_BCFirewallUseAuth,
                              INI_BCFirewallUsername,
                              INI_BCFirewallPassword,
                              BCONNECTNAME,
                              ImageToUse.Picture,
                              AdminSystem.fdFields.fdBankLink_Code,
                              AdminSystem.fdFields.fdBankLink_Connect_Password,
                              AdminSystem.fdFields.fdCountry,
                              MakeSuffix( AdminSystem.fdFields.fdDisk_Sequence_No),
                              TRUE,
                              '2',            //preferred file format
                              LogBConnectMsg,
                              Globals.DownloadInboxDir,
                              VerString,
                              StatsString,
                              False,
                              AdminSystem.fdFields.fdManual_Account_XML,
                              AdminSystem.fdFields.fdCollect_Usage_Data,
                              INI_BCHTTPMethod) do
   try
     ShowModal;
     result := FilesDownloaded;

     if SettingsChanged then begin
        INI_BCPrimaryHost      := PrimaryHost;
        INI_BCPrimaryPort      := PrimaryPort;
        INI_BCSecondaryHost    := SecondaryHost;
        INI_BCSecondaryPort    := SecondaryPort;
        INI_BCTimeout          := Timeout;
        INI_BCCustomConfig     := UseCustomConfiguration;
        INI_BCUseWinInet       := UseWinINet;
        INI_BCUseProxy         := UseProxy;
        INI_BCProxyHost        := ProxyHost;
        INI_BCProxyPort        := ProxyPort;
        INI_BCProxyAuthMethod  := ProxyAuthMethod;
        INI_BCProxyUsername    := ProxyUserName;
        INI_BCProxyPassword    := ProxyPassword;
        INI_BCUseFirewall      := UseFirewall;
        INI_BCFirewallHost     := FirewallHost;
        INI_BCFirewallPort     := FirewallPort;
        INI_BCFirewallType     := FirewallTypeAsInt;
        INI_BCFirewallUseAuth  := UseFirewallAuthentication;
        INI_BCFirewallUsername := FirewallUserName;
        INI_BCFirewallPassword := FirewallPassword;
      end;

      //UserName doesnt change
      //Country  doesnt change
      //don't care about LastFileID;
      if( AdminSystem.fdFields.fdBankLink_Connect_Password <> Password) then begin
         PasswordChanged := true;
         //password will be returned as plain text, need to reencrypt
         NewPassword     := EncryptPassword( Password);
      end
      else
         PasswordChanged := false;

      // Reset usage data if it was sent
      if UsageInfoSent then
        DeleteUsageData;

      //save password into admin system if changed
      if PasswordChanged or ManualAccountInfoSent then
         if LoadAdminSystem(true, ThisMethodName ) then begin
            if ManualAccountInfoSent then
              AdminSystem.fdFields.fdManual_Account_XML := '';
            if PasswordChanged then
              AdminSystem.fdFields.fdBankLink_Connect_Password := NewPassword;
            SaveAdminSystem;
         end;
   finally
     Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoBankLinkOffsiteConnect : integer;
//returns the number of disks to process
//returns -1 if process not clicked
const
   ThisMethodName = 'DoBankLinkOffsiteConnect';
var
   VerString : string;
   StatsString : string;
   ImageToUse : TImage;
   i: Integer;
   b: TBank_Account;
   ManualString: string;
begin
   LogMsg( lmInfo, Unitname, ThisMethodName + ' for ' + MyClient.clFields.clBankLink_Code);
   //--------------------------- HTTPS BCONNECT -----------------------------
   VerString := Globals.ShortAppName + ' ' + WinUtils.GetShortAppVersionStr;
   StatsString := BuildStatsString;

   if ColorsDepthIs256 then
   begin
     ImageToUse := AppImages.imgBankLinkLogo256;
   end
   else
   begin
     ImageToUse := AppImages.imgBankLinkLogoHiColor;
   end;

   // See if this client has manual account info to send
   // Do not reset flag until we know its been sent
   ManualString := '';
   for i := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
   begin
     b := MyClient.clBank_Account_List.Bank_Account_At(i);
     if b.baFields.baIs_A_Manual_Account and (not b.baFields.baManual_Account_Sent_To_Admin) and (b.baFields.baManual_Account_Type > -1) then
       ManualString := ManualString + MakeManualXMLString(mtNames[b.baFields.baManual_Account_Type], b.baFields.baManual_Account_Institution);
   end;


   with TfrmBConnectHTTPS.Create ( Application.MainForm,
                              INI_BCPrimaryHost,
                              INI_BCPrimaryPort,
                              INI_BCSecondaryHost,
                              INI_BCSecondaryPort,
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
                              INI_BCFirewallType,
                              INI_BCFirewallUseAuth,
                              INI_BCFirewallUsername,
                              INI_BCFirewallPassword,
                              BCONNECTNAME,
                              ImageToUse.Picture,
                              MyClient.clFields.clBankLink_Code,
                              MyClient.clFields.clBankLink_Connect_Password,
                              MyClient.clFields.clCountry,
                              MakeSuffix( MyClient.clFields.clDisk_Sequence_No),
                              TRUE,
                              '2',            //preferred file format
                              LogBConnectMsg,
                              Globals.DownloadInboxDir,
                              VerString,
                              StatsString,
                              True,
                              ManualString,
                              False,
                              INI_BCHTTPMethod) do
   try
     ShowModal;
     result := FilesDownloaded;

     if SettingsChanged then begin
        INI_BCPrimaryHost      := PrimaryHost;
        INI_BCPrimaryPort      := PrimaryPort;
        INI_BCSecondaryHost    := SecondaryHost;
        INI_BCSecondaryPort    := SecondaryPort;
        INI_BCTimeout          := Timeout;
        INI_BCCustomConfig     := UseCustomConfiguration;
        INI_BCUseWinInet       := UseWinINet;
        INI_BCUseProxy         := UseProxy;
        INI_BCProxyHost        := ProxyHost;
        INI_BCProxyPort        := ProxyPort;
        INI_BCProxyAuthMethod  := ProxyAuthMethod;
        INI_BCProxyUsername    := ProxyUserName;
        INI_BCProxyPassword    := ProxyPassword;
        INI_BCUseFirewall      := UseFirewall;
        INI_BCFirewallHost     := FirewallHost;
        INI_BCFirewallPort     := FirewallPort;
        INI_BCFirewallType     := FirewallTypeAsInt;
        INI_BCFirewallUseAuth  := UseFirewallAuthentication;
        INI_BCFirewallUsername := FirewallUserName;
        INI_BCFirewallPassword := FirewallPassword;
      end;

      //UserName doesnt change
      //Country  doesnt change
      //don't care about LastFileID;
      if( MyClient.clFields.clBankLink_Connect_Password <> Password) then begin
         //password will be returned as plain text, need to reencrypt
         MyClient.clFields.clBankLink_Connect_Password     := EncryptPassword( Password);
      end;

      if ManualAccountInfoSent then
        for i := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
        begin
          b := MyClient.clBank_Account_List.Bank_Account_At(i);
          if b.baFields.baIs_A_Manual_Account and (not b.baFields.baManual_Account_Sent_To_Admin) then
            b.baFields.baManual_Account_Sent_To_Admin := True;
        end;

   finally
     Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
