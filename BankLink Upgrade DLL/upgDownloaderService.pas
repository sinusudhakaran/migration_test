unit upgDownloaderService;

interface

uses IpsSoaps, SysUtils;

type
{$M+}
  EServiceError = class(Exception)
  private
    FErrorCode: integer;
  public
    constructor Create(Msg: string; ErrorCode: integer); overload;
  published
    property ErrorCode: integer read FErrorCode write FErrorCode;
  end;

  TDownloaderService = class
  private
    FConfig: string;
    FSOAPRequester: TipsSOAPS;
    FServiceURL1: string;
    FServiceURL2: string;
    FCurrentURLIndex: Integer;
    FTriedBothServers: Boolean;
    procedure SetMethod(Method: string);
    procedure AddStringParam(Name, Value: string);
    procedure AddBooleanParam(Name: string; Value: Boolean);
    procedure AddIntParam(Name: string; Value: Integer);
    procedure CallMethod;
    procedure SetCurrentURLIndex(const Value: Integer);
  public
    constructor Create(Config: string);
    destructor Destroy; override;
    procedure LoadConfig(Config: string);
    procedure Interupt;
  published
    //Web Service Methods
    function Ping(pingAppService: Boolean): string;
    procedure RecordFirstRun(appID: Integer; appVersion, bConnectCode: string;
      countryID: integer; extraIdentInfo, extraInfo: string);
    function IsUpdateAvailable(appID: Integer; appVersion, bConnectCode: string;
      countryID: integer; extraIdentInfo, extraInfo: string; var newVersionNumber: string;
      var newVersionDescription: string; var detailsHref: string; var subAppDetails: string): boolean;
    function GetAppParser(appID: Integer; appVersion: string; windowsVersion: string; var crc: LongWord): string;
    function GetVersion(appID: Integer; bConnectCode: string; countryID: Integer; extraIdentInfo, desiredVersion, extraInfo: string): string;
  end;

implementation

uses OmniXML, OmniXMLUtils, IniFiles, upgCommon, upgConstants, StrUtils;

{ TDownloaderService }

constructor TDownloaderService.Create(Config: string);
var
  FileName: string;
  IniFile: TIniFile;
  IniURL1, IniURL2: string;
  IniMethodURI: string;
begin
  FTriedBothServers := false;
  FSOAPRequester := TipsSOAPS.Create(nil);
  IniURL1 := '';
  IniURL2 := '';
  IniMethodURI := '';
  FileName := ExtractFilePath(GetDllPath) + bkupgIniFile;
  if FileExists(FileName) then
  begin
    IniFile := TIniFile.Create(FileName);
    try
      IniURL1 := IniFile.ReadString(IniDownloaderSection, 'URL', '');
      IniURL2 := IniFile.ReadString(IniDownloaderSection, 'URL2', '');
      IniMethodURI := IniFile.ReadString(IniDownloaderSection, 'MethodURI', '');
    finally
      IniFile.Free;
    end;
  end;

  if IniURL1 <> '' then
    FServiceURL1 := IniURL1
  else
    FServiceURL1 := DefaultDownloaderURL;

  if IniURL2 <> '' then
    FServiceURL2 := IniURL2
  else
    FServiceURL2 := DefaultDownloaderURL;

  SetCurrentURLIndex(1);  

  if IniMethodURI <> '' then
    FSOAPRequester.MethodURI := IniMethodURI
  else
    FSOAPRequester.MethodURI := DefaultDownloaderMethodURI;
  LoadConfig(Config);
end;

destructor TDownloaderService.Destroy;
begin
  FreeAndNil(FSOAPRequester);
  inherited;
end;

procedure TDownloaderService.LoadConfig(Config: string);
var
  xmldoc: IXMLDocument;
  StartNode, ProxyNode, FirewallNode: IXmlNode;
  FProxyAuthType: integer;
  FProxyUser, FProxyPwd: string;
begin
  FConfig := Config;
  //set up proxy
  FSOAPRequester.ProxyServer := '*';
  FSOAPRequester.ProxyPort := 0;
  FSOAPRequester.ProxyAuthorization := '';

  //FProxyAuthType := 0;
  FProxyUser := '';
  FProxyPwd := '';

  //set up firewall
  FSOAPRequester.FirewallHost := '';
  FSOAPRequester.FirewallPort := 0;
  FSOAPRequester.FirewallUser := '';
  FSOAPRequester.FirewallPassword := '';
  FSOAPRequester.FirewallType := fwNone;
  //other configuration settings
  FSOAPRequester.Config('useragent=bupgrade/3.0');
  FSOAPRequester.Config('usewininet=true');
  //lUseWinIni := true;
  if Config <> '' then
  begin
    //customer configuration info provided
    //parse xml string
    xmldoc := CreateXMLDoc;
    try
      xmldoc.PreserveWhiteSpace := false;
      if xmldoc.LoadXML(Config) then
      begin
        StartNode := FindNode(xmlDoc.FirstChild, 'config');
        if Assigned(StartNode) then
        begin
          if not GetNodeTextBool(StartNode, 'UseWininet', true) then
            FSOAPRequester.Config('usewininet=false');

          //proxy used?
          ProxyNode := FindNode(StartNode, 'ProxyServer');
          if Assigned(ProxyNode) then
          begin
            FSOAPRequester.ProxyServer := GetNodeTextStr(StartNode,
              'ProxyServer');
          // Defaulting the rest allows 'Blanking' the Proxyserver
            FSOAPRequester.ProxyPort := GetNodeTextInt(StartNode, 'ProxyPort', 0);

            FProxyAuthType := GetNodeTextInt(StartNode, 'ProxyAuthType', 0);
            FProxyUser := GetNodeTextStr(StartNode, 'ProxyUser', '');
            FProxyPwd := GetNodeTextStr(StartNode, 'ProxyPwd', '');
            case FProxyAuthType of
            //note: proxy user and pwd are cleared once the URL is set
              1:
                begin //basic
                  FSOAPRequester.Config('ProxyUser=' + FProxyUser);
                  FSOAPRequester.Config('ProxyPassword=' + FProxyPwd);
                end;
              2:
                begin //ntlm
                  FSOAPRequester.ProxyServer := Format('*%s*%s',
                    [FProxyUser, FProxyPwd]);
                end;
            end;
          end;

    //firewall used?
          FirewallNode := FindNode(StartNode, 'FwHost');
          if Assigned(FirewallNode) then
          begin
            FSOAPRequester.FirewallHost := GetNodeTextStr(StartNode, 'FwHost');
            FSOAPRequester.FirewallPort := GetNodeTextInt(StartNode, 'FwPort');
            FSOAPRequester.FirewallUser := GetNodeTextStr(StartNode, 'FwUser');
            FSOAPRequester.FirewallPassword := GetNodeTextStr(StartNode, 'FwPwd');
            FSOAPRequester.FirewallType :=
              TipssoapsFirewallTypes (GetNodeTextInt(StartNode, 'FwType'));
          end;
        end;
      end;
    finally
      xmldoc := nil;
    end;
  end;
end;

function TDownloaderService.Ping(pingAppService: Boolean): string;
begin
  SetMethod('Ping');
  AddBooleanParam('pingAppService', pingAppService);
  CallMethod;
  Result := FSOAPRequester.ReturnValue;
end;

procedure TDownloaderService.RecordFirstRun(appID: Integer; appVersion: string; bConnectCode: string; countryID: integer;
  extraIdentInfo: string; extraInfo: string);
begin
  SetMethod('RecordFirstRun');
  AddIntParam('appID', appID);
  AddStringParam('appVersion', appVersion);
  AddStringParam('bConnectCode', bConnectCode);
  AddIntParam('countryID', countryID);
  AddStringParam('extraIdentInfo', extraIdentInfo);
  AddStringParam('extraInfo', extraInfo);
  CallMethod;
end;

procedure TDownloaderService.Interupt;
begin
  FSOAPRequester.Interrupt;
end;

function TDownloaderService.IsUpdateAvailable(appID: Integer; appVersion,
  bConnectCode: string; countryID: integer; extraIdentInfo, extraInfo: string;
  var newVersionNumber, newVersionDescription, detailsHref, subAppDetails: string): boolean;
begin
  newVersionNumber := '';
  newVersionDescription := '';
  subAppDetails := '';
  detailsHref := '';
  SetMethod('IsUpdateAvailable');
  AddIntParam('appID', appID);
  AddStringParam('appVersion', appVersion);
  AddStringParam('bConnectCode', bConnectCode);
  AddIntParam('countryID', countryID);
  AddStringParam('extraIdentInfo', extraIdentInfo);
  AddStringParam('extraInfo', extraInfo);
  CallMethod;
  //Out Params Start at 1 (0 is the return value);
  Result := StrToBool(FSOAPRequester.ReturnValue);
  if Result then
  begin
    newVersionNumber := FSOAPRequester.ParamValue[1];
    newVersionDescription := FSOAPRequester.ParamValue[2];
    if FSOAPRequester.ParamCount > 2 then
    begin
      detailsHref := FSOAPRequester.ParamValue[3];
      if FSOAPRequester.ParamCount > 3 then
        subAppDetails := FSOAPRequester.ParamValue[4];
    end;
  end;
end;

function TDownloaderService.GetAppParser(appID: Integer; appVersion,
  windowsVersion: string; var crc: LongWord): string;
begin
  SetMethod('GetAppParser');
  AddIntParam('appID', appID);
  AddStringParam('appVersion', appVersion);
  AddStringParam('windowsVersion', windowsVersion);
  CallMethod;
  Result := FSOAPRequester.ReturnValue;
  if (Result <> '') and (FSOAPRequester.ParamCount > 0) then
  begin
    crc := StrToInt64Def(FSOAPRequester.ParamValue[1], 0);
  end;
end;

function TDownloaderService.GetVersion(appID: Integer; bConnectCode: string;
  countryID: Integer; extraIdentInfo, desiredVersion, extraInfo: string): string;
begin
  SetMethod('GetVersion');
  AddIntParam('appID', appID);
  AddStringParam('bConnectCode', bConnectCode);
  AddIntParam('countryID', countryID);
  AddStringParam('extraIdentInfo', extraIdentInfo);
  AddStringParam('desiredVersion', desiredVersion);
  AddStringParam('extraInfo', extraInfo);
  CallMethod;
  Result := FSOAPRequester.ReturnValue;
end;

procedure TDownloaderService.CallMethod;
var
  s: string;
  httpCode: Integer;
begin
  try
    FSOAPRequester.SendRequest;
    FTriedBothServers := false;
  except
    on E: EipsSOAPS do
    begin
      //Try the second one (unless we're already on second).
      if (FCurrentURLIndex = 1) and not FTriedBothServers then
      begin
        SetCurrentURLIndex(2);
        CallMethod;
      end
      else if (FCurrentURLIndex = 2) then
      begin
        //If the second one fails, try one again to get the original error back.
        FTriedBothServers := true;
        SetCurrentURLIndex(1);
        CallMethod;
      end
      else
      begin
        if E.Code in [169, 170, 171, 172, 173] then
          raise EServiceError.Create(Format('%s. (<%s>, <%s>)',[E.Message, FSOAPRequester.FaultCode, FSOAPRequester.FaultString]),
            E.Code)
        else if E.Code = 151 then
        begin
          //Could be either. Need to look at response code
          //e.message is in format 151: <HTTPCODE> <HTTPMESSAGE>
          try
            s := MidStr(E.Message, 6, 3); //Actually just interested in first digit
          except
            raise EServiceError.Create(E.Message, 151);
          end;
          httpCode := StrToIntDef(s, 0);
          raise EServiceError.Create(E.Message, httpCode);
        end
        else if E.Code >= 10000 then
        begin
          //Only interested in the bottom three numbers
          raise EServiceError.Create(E.Message, E.Code mod 100);
        end
        else
          raise EServiceError.Create(E.Message, E.Code)
      end;
    end;
  end;

end;

procedure TDownloaderService.AddStringParam(Name, Value: string);
begin
  FSOAPRequester.AddParam(Name, Value);
end;

procedure TDownloaderService.AddIntParam(Name: string; Value: Integer);
begin
  FSOAPRequester.AddParam(Name, IntToStr(Value));
end;

procedure TDownloaderService.AddBooleanParam(Name: string; Value: Boolean);
begin
  if Value then
    FSOAPRequester.AddParam(Name, '1')
  else
    FSOAPRequester.AddParam(Name, '0')
end;

procedure TDownloaderService.SetCurrentURLIndex(const Value: Integer);
begin
  FCurrentURLIndex := Value;
  if Value = 2 then
    FSOAPRequester.URL := FServiceURL2
  else
    FSOAPRequester.URL := FServiceURL1;
end;

procedure TDownloaderService.SetMethod(Method: string);
begin
  FSOAPRequester.Method := Method;
  FSOAPRequester.ActionURI := FSOAPRequester.MethodURI + '/' + FSOAPRequester.Method;
end;

{ EServiceError }

constructor EServiceError.Create(Msg: string; ErrorCode: integer);
begin
  inherited Create(Msg);
  FErrorCode := ErrorCode;
end;

end.
