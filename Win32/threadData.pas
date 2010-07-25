// The vcl is generally considered to not be thread-safe
// So we can't just use the existing bconnect form - tried it and it causes all sorts of weird errors!
// This module assumes use of SSL v6
unit threadData;

interface

uses Classes, SysUtils, Windows, Forms, Messages, WinInet, ipsHttps;

const
   THREAD_MESSAGE = WM_USER + 379;
   THREAD_DATA_AVAILABLE = 1;
   THREAD_NOT_ONLINE = 2;
   THREAD_NO_DATA = 3;

type
  TDataThread = class(TThread)
  private
    FhttpClient: TipsHTTPS;
    FUsingPrimaryHost, FAccountIsOverdue: Boolean;
    Fskey: string;
    FHeaders : TStringList;
    function IsConnectedToInternet: Boolean;
    function ThreadSafeBankLinkConnect: Integer;
    procedure InitialiseHTTPS;
    procedure SetBasicProxyAuthenticate;
    procedure Login;
    procedure Logout;
    procedure GetFileList(AStringList: TStringList);
    function BConnectServerPath: string;
    procedure HTTPClientHeader(Sender: TObject; const Field, Value: String);
    procedure HTTPClientError(Sender: TObject; ErrorCode: Integer; const Description: String);
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

implementation

uses BankLinkConnect, Globals, WinUtils, DownloadUtils, LogUtil;

const UnitName = 'threadData';

constructor TDataThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  Resume;
end;

procedure TDataThread.Execute;
begin
  try
    try
      if not IsConnectedToInternet then // not online
        PostMessage(Application.MainForm.Handle, THREAD_MESSAGE, THREAD_NOT_ONLINE, 0)
      else // query bconnect to see if there is data available
      begin
        if ThreadSafeBankLinkConnect > 0 then // New data files available
          PostMessage(Application.MainForm.Handle, THREAD_MESSAGE, THREAD_DATA_AVAILABLE, 0)
        else // Nothing new
          PostMessage(Application.MainForm.Handle, THREAD_MESSAGE, THREAD_NO_DATA, 0);
      end;
    except on E: Exception do // Any error will just show 'no data'
     begin
      // don't want to interrupt whatever they are doing, they can always check manually and fix it next time they download
      LogUtil.LogMsg(lmError, UnitName, 'Exception checking for new data ' + E.Message);
      PostMessage(Application.MainForm.Handle, THREAD_MESSAGE, THREAD_NO_DATA, 0);
     end;
    end;
  finally
    Terminate;
  end;
end;

// Do we have an interweb connection?
function TDataThread.IsConnectedToInternet: Boolean;
var
  ConnectionTypes: Integer;
begin
  ConnectionTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState(@ConnectionTypes, 0);
end;

// Some setup stuff

procedure TDataThread.SetBasicProxyAuthenticate;
begin
  if (INI_BCProxyAuthMethod <> 1) or (Trim(INI_BCProxyUsername) = '') then
    Exit;
  FhttpClient.ProxyUser := INI_BCProxyUsername;
  FhttpClient.ProxyPassword := INI_BCProxyPassword;
  FhttpClient.OtherHeaders := Format ('Proxy-Authorization: %s' + Chr (13) + Chr (10), [FhttpClient.ProxyAuthorization]);
  FhttpClient.ProxyUser := '';
  FhttpClient.ProxyPassword := '';
end;

procedure TDataThread.InitialiseHTTPS;
const
  PROTOCOL_TLS1       = $C0;
  PROTOCOL_SSL3       = $30;
  IGNORE_CN_ERROR     = $80000000;
begin
  FhttpClient.Timeout := INI_BCTimeout;
  FhttpClient.ProxyServer := '';
  FhttpClient.ProxyPort := 0;
  FhttpClient.ProxyUser := '';
  FhttpClient.ProxyPassword := '';

  FhttpClient.FirewallUser := '';
  FhttpClient.FirewallPassword := '';
  FhttpClient.FirewallHost := '';
  FhttpClient.FirewallPort := 0;
  FhttpClient.FirewallType := fwNone;

  if not  (not INI_BCCustomConfig or (INI_BCCustomConfig and INI_BCUseWinInet)) then
    FhttpClient.Config('useWinInet=False')
  else
    FhttpClient.Config('useWinInet=True');

  FhttpClient.Config (Format( 'UserAgent=BConnect/2.1 (%s, %s)',
      [Globals.ShortAppName + ' ' + WinUtils.GetShortAppVersionStr, GetWinVer]));

  FhttpClient.Config ('SSLSecurityFlags=0x80000000');
  FhttpClient.Config ('SSLEnabledProtocols=140');

  if INI_BCCustomConfig then
  begin
      if INI_BCUseProxy then
      begin
        FhttpClient.ProxyServer   := INI_BCProxyHost;
        FhttpClient.ProxyPort     := INI_BCProxyPort;
        case INI_BCProxyAuthMethod of
          1 :  SetBasicProxyAuthenticate;
          2 :  FhttpClient.ProxyServer := Format ('*%s*%s', [INI_BCProxyUsername, INI_BCProxyPassword]);
        end;
        FhttpClient.ProxyUser     := INI_BCProxyUsername;
        FhttpClient.ProxyPassword := INI_BCProxyPassword;
      end;

      if INI_BCUseFirewall then
      begin
        FhttpClient.FirewallHost := INI_BCFirewallHost;
        FhttpClient.FirewallPort := INI_BCFirewallPort;
        try
          FhttpClient.FirewallType := TipshttpsFirewallTypes(INI_BCFirewallType);
        except
          FhttpClient.FirewallType := TipshttpsFirewallTypes(0);
        end;
        if INI_BCFirewallUseAuth then
        begin
          FhttpClient.FirewallUser     := INI_BCFirewallUsername;
          FhttpClient.FirewallPassword := INI_BCFirewallPassword;
        end;
      end;
  end;
end;

function TDataThread.BConnectServerPath: string;
var
  AHost: string;
  APort: integer;
begin
  if FUsingPrimaryHost then
  begin
    AHost := INI_BCPrimaryHost;
    APort := INI_BCPrimaryPort;
  end
  else
  begin
    AHost := INI_BCSecondaryHost;
    APort := INI_BCSecondaryPort;
  end;

  if AHost = '' then
    Abort;

  if APort <> 0 then
    Result := Format('%s%s:%d%s', [INI_BCHTTPMethod, AHost, APort, '/bconnect/bcWebServer.dll/'])
  else
    Result := Format('%s%s%s', [INI_BCHTTPMethod, AHost, '/bconnect/bcWebServer.dll/']);
end;

// Attempt to login to bconnect
procedure TDataThread.Login;
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    PostData.Add('user=' + AdminSystem.fdFields.fdBankLink_Code);
    PostData.Add('pwd=' + AdminSystem.fdFields.fdBankLink_Connect_Password);
    case AdminSystem.fdFields.fdCountry of
      0: PostData.Add('country=NZ');
      1: PostData.Add('country=OZ');
    end;
    PostData.Add('encrypted=Y');
    FHeaders.Clear;
    FhttpClient.ResetHeaders;
    FhttpClient.PostData := PostData.Text;
    FhttpClient.URL := BConnectServerPath + 'login';
    SetBasicProxyAuthenticate;
    FhttpClient.Post(FhttpClient.URL);
  finally
    PostData.Free;
  end;
  Fskey := FHeaders.Values['skey'];
  FAccountIsOverdue := StrToIntDef(FHeaders.Values['errorno'], 0) = 2000;
end;


// Attempt to logout from bonnect
procedure TDataThread.Logout;
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    PostData.Add('skey=' + FsKey);
    PostData.Add('username=' + AdminSystem.fdFields.fdBankLink_Code);
    FHeaders.Clear;
    FhttpClient.ResetHeaders;
    FhttpClient.PostData := PostData.Text;
    FhttpClient.URL := BConnectServerPath + 'logout';
    SetBasicProxyAuthenticate;
    FhttpClient.Post(FhttpClient.URL);
  finally
    PostData.Free;
  end;
end;

// Retrieve a bocnnect list of new files - do not download them
procedure TDataThread.GetFileList(AStringList: TStringList);
var
  PostData: TStringList;
begin
  PostData := TStringList.Create;
  try
    PostData.Add('skey=' + FsKey);
    PostData.Add('username=' + AdminSystem.fdFields.fdBankLink_Code);
    PostData.Add('fileid=' + MakeSuffix(AdminSystem.fdFields.fdDisk_Sequence_No));
    PostData.Add('fileversion=2');
    FHeaders.Clear;
    FhttpClient.ResetHeaders;
    FhttpClient.PostData := PostData.Text;
    FhttpClient.URL := BConnectServerPath + 'filelist';
    SetBasicProxyAuthenticate;
    FhttpClient.Post(FhttpClient.URL);
  finally
    PostData.Free;
  end;

  AStringList.CommaText := FHeaders.Values['Files'];
end;

// Store the headers
procedure TDataThread.HTTPClientHeader(Sender: TObject; const Field, Value: String);
begin
  FHeaders.Add (Format('%s=%s', [Field, Value]));
end;

// Log any errors
procedure TDataThread.HTTPClientError(Sender: TObject; ErrorCode: Integer; const Description: String);
begin
   LogUtil.LogMsg(lmError, UnitName, 'Error checking for new data ' + IntToStr(ErrorCode) + ' ' + Description);
end;

function TDataThread.ThreadSafeBankLinkConnect: Integer;
var
  Files: TStringList;
begin
  Result := 0;
  FhttpClient := TipsHttps.Create(nil);
  FhttpClient.OnHeader := HTTPClientHeader;
  FhttpClient.OnError := HTTPClientError;
  FHeaders := TStringList.Create;
  try
    if (AdminSystem.fdFields.fdBankLink_Connect_Password = '') then
      exit;
    InitialiseHTTPS;
    FAccountIsOverdue := False;
    FUsingPrimaryHost := True;
    //Attempt to login, try primary host first, then use secondary host
    while TRUE do
    begin
      try
        Login;
        break;
      except
        on E : EIpsHTTPS do
        begin
          LogUtil.LogMsg(lmError, UnitName, 'Exception EIpsHTTPS checking for new data ' + IntToStr(E.Code) + ' ' + E.Message + ' ' + FHeaders.Text);
          if FUsingPrimaryHost then
            FUsingPrimaryHost := False
          else
            exit;
        end;
      end;
    end;
    if FAccountIsOverdue then
      exit;
    //Login was succesful, now download file list (but do not actually download),
    //always try to log out whatever happens
    try
      Files := TStringList.Create;
      try
        GetFileList(Files);
        Result := Files.Count;
      finally
        FreeAndNil(Files);
      end;
    finally
      Logout;
    end;
   finally
     FreeAndNil(FhttpClient);
     FreeAndNil(FHeaders);
   end;
end;

end.
