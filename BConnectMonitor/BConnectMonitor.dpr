program BConnectMonitor;   // based off BulkExtractfrm in Practice

{$APPTYPE CONSOLE}

uses
  SysUtils,
  ipshttps,
  idsmtp,
  idmessage,
  idemailaddress,
  Classes,
  Forms,
  Contnrs,
  Globals,
  Winutils,
  INISettings,
  HyperFrm,
  Dialogs;

const
  WebAppPath = '/bconnect/bcWebServer.dll/';

type
  TBulkExtractors = class(TObjectList)
  private
    procedure HTTPClientHeader(Sender: TObject; const Field, Value: string);  
  public
  end;

var
  HTTPClient: TipsHTTPS;
  LServerResponseMsg : string;
  LUsingPrimaryHost: Boolean;
  LsKey: string;
  PostData, FHeaders: TStringList;

  FBulkExtractors : TBulkExtractors;

function ExtractDetails: Integer;
begin
  LServerResponseMsg := FHeaders.Values['serverresponse'];
  Result := StrToIntDef(FHeaders.Values['errorno'], 0);
  FHeaders.Clear;
end;

function GetFirewallType: TipshttpsFirewallTypes;
begin
  try
    Result := TipshttpsFirewallTypes(INI_BCFirewallType);
  except
    Result := TipshttpsFirewallTypes(0);
  end;
end;

function BConnectServerPath: string;
var
  AHost: string;
  APort: integer;
begin
  if LUsingPrimaryHost then begin
     AHost := INI_BCPrimaryHost;
     APort := INI_BCPrimaryPort;
  end else begin
     AHost := INI_BCSecondaryHost;
     APort := INI_BCSecondaryPort;
  end;
  if APort <> 0 then
     Result := Format('%s%s:%d%s', [INI_BCHTTPMethod, AHost, APort, WebAppPath])
  else
     Result := Format('%s%s%s', [INI_BCHTTPMethod, AHost, WebAppPath]);
end;

procedure LogIn;
var
  ParamNum, SleepInterval, FirstEmailParam: integer;
  Secure1IsDown, Secure2IsDown, LastSecure1Status, LastSecure2Status: boolean;
  AllRecipients: string;
  IdSMTP1: TIdSMTP;
  Message1: TIdMessage;

  procedure ConnectAndSendMessage;
  begin
    try
      IdSMTP1.ConnectTimeout := 1000;
      IdSMTP1.Connect;
      IdSMTP1.Send(Message1);
    finally
      if idSMTP1.Connected then
        idSMTP1.Disconnect(true);
    end;
  end;

  // This isn't to test if the email address is valid, only to distinguish email addresses from the 'time
  // between checks' parameter 
  function CheckParamIsEmail(LocalParamNum: integer): boolean;
  begin
    Result := (AnsiPos('@', ParamStr(LocalParamNum)) > 0);
  end;

  procedure ConnectToBConnect(BConnectURL: string);
  begin
    PostData.Clear;
    PostData.Add('user=testuser');
    PostData.Add('pwd=testpass');
    PostData.Add('country=NZ');
    PostData.Add('encrypted=Y');
    httpClient.ResetHeaders;
    httpClient.PostData := PostData.Text;
    httpClient.URL := BConnectURL;
    httpClient.Post(httpClient.URL);
  end;

begin
  if not CheckParamIsEmail(ParamCount) then // the last parameter must be an email address
  begin
    ShowMessage('You must enter one or more email addresses as parameters. You can also ' +
                'include a number of minutes between checks, this will default to 10. eg: ' + #13#10 +
                'BConnectMonitor.exe 20 bigbird@banklink.co.nz' + #13#10#13#10 +
                'Program will now exit.');
    Exit;
  end;

  if not CheckParamIsEmail(1) then
  begin
    FirstEmailParam := 2;
    SleepInterval := StrToInt(ParamStr(1)) * 1000 * 60; // x minutes, x being the number entered by the user
  end else
  begin
    FirstEmailParam := 1;
    SleepInterval := 1000 * 60 * 10; // 10 minutes
  end;

  AllRecipients := '';
  INI_Mail_Type := SMTP_MAIL;

  try
    IdSMTP1 := TIdSMTP.Create(Application);
    IdSMTP1.Host := 'BANKLINK-XX1';
    IdSMTP1.Port := 25;
    
    for ParamNum := FirstEmailParam to ParamCount do
      AllRecipients := ParamStr(ParamNum) + ';';

    Message1 := TIdMessage.Create(Application);
    Message1.From.Address := 'Tony.Kelly@banklink.co.nz';
    Message1.Recipients.EMailAddresses := AllRecipients;

    LastSecure1Status := False;
    LastSecure2Status := False;

    while true do begin // Keep running this loop until the program is terminated
      // Trying Secure1
      ConnectToBConnect(BConnectServerPath + 'login');
      Secure1IsDown := (ExtractDetails = 0);

      // Trying Secure2
      LUsingPrimaryHost := false;
      ConnectToBConnect(BConnectServerPath + 'login');
      Secure2IsDown := (ExtractDetails = 0);

      if Secure1IsDown
        then WriteLn('FAILED to connect to BConnect (Secure1) at ' + DateTimeToStr(Now))
        else WriteLn('Successfully connected to BConnect (Secure1) at ' + DateTimeToStr(Now));
      if Secure2IsDown
        then WriteLn('FAILED to connect to BConnect (Secure2) at ' + DateTimeToStr(Now))
        else WriteLn('Successfully connected to BConnect (Secure2) and ' + DateTimeToStr(Now));

      if (Secure1IsDown <> LastSecure1Status) or (Secure2IsDown <> LastSecure2Status) then
      begin
        Message1.Subject := 'BConnect status has changed';
        // Send email (if we haven't already)
        if Secure1IsDown and Secure2IsDown then
          Message1.Body.Text := 'Secure1 and Secure2 are down.'
        else if Secure1IsDown then
          Message1.Body.Text := 'Secure1 is down, Secure2 is operational.'
        else if Secure2IsDown then
          Message1.Body.Text := 'Secure1 is operational, Secure2 is down.'
        else
          Message1.Body.Text := 'Secure1 and Secure2 are operational.';

        Message1.Body.Text := Message1.Body.Text + #13#10 +
                              'No further notifications will be sent until the status of either server has changed.';
        ConnectAndSendMessage;
      end;

      LastSecure1Status := Secure1IsDown;
      LastSecure2Status := Secure2IsDown;
      Sleep(SleepInterval); // Check BConnect status every so often, default to 10 minutes
    end;

  finally
    Message1.Free;
    Message1 := nil;
    IdSMTP1.Free;
    IdSMTP1 := nil;
  end;


end;

procedure TBulkExtractors.HTTPClientHeader(Sender: TObject; const Field, Value: string);
begin
  FHeaders.Add (Format ('%s=%s', [Field, Value]));
end;

begin
  try
    SHORTAPPNAME := 'BankLink Practice';
    BK5ReadINI;

    FHeaders := TStringList.Create;
    HTTPClient := TipsHTTPS.Create(nil);
    PostData := TStringList.Create;
    try
      // Initialize the HTTPClient;

      httpClient.OnHeader := FBulkExtractors.HTTPClientHeader;
      httpClient.Timeout :=  INI_BCTimeout;
      httpClient.ProxyServer := '';
      httpClient.ProxyPort := 0;
      httpClient.ProxyUser := '';
      httpClient.ProxyPassword := '';

      httpClient.FirewallUser := '';
      httpClient.FirewallPassword := '';
      httpClient.FirewallHost := '';
      httpClient.FirewallPort := 0;
//      httpClient.FirewallType := fwNone;
      LUsingPrimaryHost := True;

      if not (not  INI_BCCustomConfig or (INI_BCCustomConfig and INI_BCUseWinInet)) then
         httpClient.Config('useWinInet=False')
      else
         httpClient.Config('useWinInet=True');

      httpClient.Config (Format( 'UserAgent=BConnect/2.1 (%s %s, %s)',
                                [ Globals.ShortAppName,
                                  WinUtils.GetShortAppVersionStr,
                                  WinUtils.GetWinVer]));

      httpClient.Config ('SSLSecurityFlags=0x80000000');
      httpClient.Config ('SSLEnabledProtocols=140');

      if INI_BCCustomConfig then begin
         if INI_BCUseProxy then begin
            httpClient.ProxyServer   := INI_BCProxyHost;
            httpClient.ProxyPort     := INI_BCProxyPort;
            case INI_BCProxyAuthMethod of
              1 :  begin
                       httpClient.ProxyUser := INI_BCProxyUsername;
                       httpClient.ProxyPassword := INI_BCProxyPassword;
                       httpClient.OtherHeaders := Format ('Proxy-Authorization: %s' + Chr (13) + Chr (10), [httpClient.ProxyAuthorization]);
                       httpClient.ProxyUser := '';
                       httpClient.ProxyPassword := '';
                   end;
              2 :  httpClient.ProxyServer := Format ('*%s*%s', [INI_BCProxyUsername, INI_BCProxyPassword]);
            end;
            httpClient.ProxyUser     := INI_BCProxyUsername;
            httpClient.ProxyPassword := INI_BCProxyPassword;
         end;

        if INI_BCUseFirewall then begin
           httpClient.FirewallHost := INI_BCFirewallHost;
           httpClient.FirewallPort := INI_BCFirewallPort;
           httpClient.FirewallType := GetFirewallType;
           if INI_BCFirewallUseAuth then begin
              httpClient.FirewallUser     := INI_BCFirewallUsername;
              httpClient.FirewallPassword := INI_BCFirewallPassword;
          end;
        end;
      end;
      Login; // Try to logon
    finally
      HTTPClient.Free;
      Postdata.Free;
    end;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;

end.

