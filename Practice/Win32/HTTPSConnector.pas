unit HTTPSConnector;

interface
uses
 classes,
 ipshttps;


type
  THTTPSConnector = class(tObject)
  private
     HTTPClient: TipsHTTPS;
     FUsingPrimaryHost: Boolean;
     FServerResponseMsg: string;
     FPostData: TStringList;
     FHeaders: TStringList;
     FAction: string;
     FsKey: string;
     procedure HTTPClientHeader(Sender: TObject; const Field, Value: string);
     function CountryAsString: string;
     function BConnectServerPath: string;
     function ExtractDetails: Integer;
     function GetFirewallType: TipshttpsFirewallTypes;
     procedure Init;
     procedure Post(const Service: string);
  public
     constructor Create(Action: string);
     destructor Destroy; override;

     function LogIn: Boolean;
     procedure LogOut;
     function CheckBulkExtract: Boolean;
  end;

implementation

uses
  WinUtils,
  logUtil,
  progress,
  sysUtils,
  glConst,
  Globals,
  ipscore;

const
   WebAppPath = '/bconnect/bcWebServer.dll/';
   MaxAttempt = 3;


{ HTTPSConnector }

function THTTPSConnector.BConnectServerPath: string;
var AHost: string;
    APort: integer;
begin
   if FUsingPrimaryHost then begin
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

function THTTPSConnector.CheckBulkExtract: Boolean;
var
   Reply: string;
   AttemptCount: Integer;
begin
   AttemptCount := 0;
   Result := False;
   while AttemptCount < MaxAttempt do
      try
         Inc(AttemptCount);
         FPostData.Clear;
         FPostData.Add('skey=' + FsKey);
         FPostData.Add('username=' + AdminSystem.fdFields.fdBankLink_Code);

         Post('checkBulkExtract');

         case ExtractDetails of
            0: begin
                  Reply := FHeaders.Values['AllowBulkExtract'];
                  Result := (Reply > '')
                      and (UpCase(Reply[1]) = 'Y');//True
                  Break; // Im Done...
              end;

            1002: LogError('Authenticate CanExport','Session Key supplied is invalid');
            1003: LogError('Authenticate CanExport','Session Key has expired');
            1004: LogError('Authenticate CanExport','Session has already been completed');

            2001: LogError('Authenticate CanExport','The service is currently unavailable');
            9000: LogError('Authenticate CanExport','Unknown Error at data provider');

         end;
      except
         on E: Exception do
           LogError('Authenticate CanExport',E.Message);
             // Nothing much I can do
      end;
end;

function THTTPSConnector.CountryAsString: string;
begin
   case  AdminSystem.fdFields.fdCountry of
      0: Result := 'NZ';
      1: Result := 'OZ';
      2: Result := 'UK';
   end;
end;


constructor THTTPSConnector.Create(Action: string);
begin
   inherited Create;
   FAction := Action;
   FPostData := TStringList.Create;
   FHeaders := TStringList.Create;

   HTTPClient := TipsHTTPS.Create(nil);
   httpClient.OnHeader := HTTPClientHeader;

end;

destructor THTTPSConnector.Destroy;
begin
  FreeAndNil(FPostData);
  FreeAndNil(FHeaders);
  FreeAndNil(HTTPClient);
  inherited;
end;

function THTTPSConnector.ExtractDetails: Integer;
begin
   FServerResponseMsg := FHeaders.Values['serverresponse'];
   Result := StrToIntDef(FHeaders.Values['errorno'], 0);
end;

function THTTPSConnector.GetFirewallType: TipshttpsFirewallTypes;
begin
   try
      Result := TipshttpsFirewallTypes(INI_BCFirewallType);
   except
      Result := TipshttpsFirewallTypes(0);
   end;
end;


procedure THTTPSConnector.HTTPClientHeader(Sender: TObject; const Field,
  Value: string);
begin
  FHeaders.Add (Format ('%s=%s', [Field, Value]));
end;

procedure THTTPSConnector.Init;
begin
   httpClient.Timeout :=  INI_BCTimeout;
   httpClient.ProxyServer := '';
   httpClient.ProxyPort := 0;
   httpClient.ProxyUser := '';
   httpClient.ProxyPassword := '';

   httpClient.FirewallUser := '';
   httpClient.FirewallPassword := '';
   httpClient.FirewallHost := '';
   httpClient.FirewallPort := 0;
   httpClient.FirewallType := fwNone;
   FUsingPrimaryHost := True;

   if (not  INI_BCCustomConfig or (INI_BCCustomConfig and INI_BCUseWinInet)) then
      httpClient.Config('useWinInet=True')
   else
      httpClient.Config('useWinInet=False');

   httpClient.Config (Format( 'UserAgent=BConnect/2.1 (%s %s, %s)',
                            [Globals.ShortAppName,
                             WinUtils.GetShortAppVersionStr,
                             WinUtils.GetWinVer
                            ])
                     );

   httpClient.Config ('SSLSecurityFlags=0x80000000');
   httpClient.Config ('SSLEnabledProtocols=140');

   if INI_BCCustomConfig then begin
      if INI_BCUseProxy then begin
         httpClient.ProxyServer := INI_BCProxyHost;
         httpClient.ProxyPort  := INI_BCProxyPort;
         case INI_BCProxyAuthMethod of
            1 : begin
                  httpClient.ProxyUser := INI_BCProxyUsername;
                  httpClient.ProxyPassword := INI_BCProxyPassword;
                  httpClient.OtherHeaders := Format ('Proxy-Authorization: %s'#13#10, [httpClient.ProxyAuthorization]);
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

end;

function THTTPSConnector.LogIn: Boolean;
var
   AttemptCount: integer;
begin
   Init;

   AttemptCount := 0;
   Result := False;
   while AttemptCount < MaxAttempt do begin
      try
         Inc(AttemptCount);


         if FUsingPrimaryHost then
            UpdateAppStatus(Format('Authenticating %s',[FAction]) , 'Primary Host'{httpClient.URL Too explicit} ,(AttemptCount / MaxAttempt)* 100 )
         else
            UpdateAppStatus(Format('Authenticating %s',[FAction]) , 'Secondary Host' ,(AttemptCount / MaxAttempt)* 100 );

         FPostData.Clear;
         FPostData.Add('user=' + AdminSystem.fdFields.fdBankLink_Code);
         FPostData.Add('pwd=' + AdminSystem.fdFields.fdBankLink_Connect_Password);
         FPostData.Add('country=' + CountryAsString);
         FPostData.Add('encrypted=Y');

         Post('login');

         case ExtractDetails of
            0: begin // success
                FsKey := FHeaders.Values['skey'];
                Result := True;
                Break; // Im done
            end;
            2000: begin // overdue accounts
                LogError('Authenticate Logon','Overdue Accounts');
                Break;
            end;
            1000 : begin //'Invalid Password file (Wrong Practice Code..');
                LogError('Authenticate Logon','Wrong Username');
                Break;
            end;
            1001 : begin //Invalid Password
                LogError('Authenticate Logon','Wrong Password');
                Break;
            end;
         end;

      except
         // Try the other one...
         FUsingPrimaryHost := not FUsingPrimaryHost;
      end;
   end;
end;


procedure THTTPSConnector.LogOut;
begin
   try
      FPostData.Clear;
      FPostData.Add('skey=' + FsKey);
      FPostData.Add('username=' + AdminSystem.fdFields.fdBankLink_Code);
      Post('logout');
   except
      //At least we tried...
   end;
end;


procedure THTTPSConnector.Post(const Service: string);
begin
   FHeaders.Clear;
   httpClient.ResetHeaders;
   httpClient.PostData := FPostData.Text;
   httpClient.URL := BConnectServerPath + Service;
   httpClient.Post(httpClient.URL);
end;

end.
