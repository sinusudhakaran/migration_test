unit WebClient;
//------------------------------------------------------------------------------
{
   Title: WebClient

   Description:

        Base Class which Handle the Soap and Http Client Calls

   Author: Ralph Austen

   Remarks:
}
//------------------------------------------------------------------------------
interface

uses
  Classes,
  IpsCore,
  IpsSoaps,
  IpsHttps,
  stDate,
  SysUtils;

Type
  //----------------------------------------------------------------------------
  EWebClientError = class(Exception)
  private
    FErrorCode : integer;
  public
    constructor Create(AMsg       : string;
                       AErrorCode : integer); overload;
  published
    function IsConnectionProblem : boolean; virtual;

    property ErrorCode : integer read FErrorCode write FErrorCode;
  end;

  //----------------------------------------------------------------------------
  EWebSoapClientError = class(EWebClientError)
  published
    function IsConnectionProblem : boolean; override;
  end;

  //----------------------------------------------------------------------------
  EWebHttpClientError = class(EWebClientError)
  end;

  //----------------------------------------------------------------------------
  TWebClient = class
  private
    // Soap
    FSoapURLList    : TStringList;
    FSoapURLIndex   : integer;
    FSoapRequester  : TIpsSOAPS;
    FSoapHeaderInfo : TStringList;

    // Http
    fHttpRequester  : TIpsHTTPS;
    FHttpHeaderInfo : TStringList;

    procedure AppendHeaderInfo(const ARequester  : TipsCore;
                               const AHeaderInfo : TStringList);
    procedure SetURL(const ARequester : TipsCore;
                     const AURLList   : TStringList;
                     AURLIndex        : integer);
  protected
    // Soap
    procedure AppendSoapHeaderInfo;
    procedure AddSoapHeaderInfo(AName  : string;
                                AValue : string);
    procedure ClearSoapHeader;
    procedure SetSoapURL;
    procedure RaiseSoapErrors(AError : EIpsSOAPS);
    procedure RaiseSoapError(AErrMessage : String;
                             AErrCode    : integer); virtual;
    procedure SoapSetup;
    procedure AddSoapStringParam(AName  : string;
                                 AValue : string);
    procedure AddSoapBooleanParam(AName  : string;
                                  AValue : Boolean);
    procedure AddSoapDateParam(AName  : string;
                               AValue : tStDate);
    procedure AddSoapIntParam(AName  : string;
                              AValue : Integer);
    procedure DoSoapConnectionStatus(ASender : TObject;
                                     const AConnectionEvent : String;
                                     AStatusCode : Integer;
                                     const ADescription : String); Virtual;
    procedure DoSoapSSLServerAuthentication(ASender      : TObject;
                                            ACertEncoded : String;
                                            const ACertSubject : String;
                                            const ACertIssuer  : String;
                                            const AStatus      : String;
                                            var   AAccept      : Boolean); Virtual;
    procedure SetSoapMethod(AMethod : string);
    procedure SendSoapRequest(var ATriedAllServers : Boolean;
                              AFirstSoapURLIndex   : Integer);
    procedure CallSoapMethod; Virtual;

    // Http
    procedure AppendHttpHeaderInfo;
    procedure AddHttpHeaderInfo(AName  : string;
                                AValue : string);
    procedure ClearHttpHeader;
    procedure RaiseHttpErrors(AError : EIpsHTTPS);
    procedure RaiseHttpError(AErrMessage : String;
                             AErrCode    : integer); virtual;
    procedure HttpSetup;
    procedure DoHttpConnected(Sender     : TObject;
                              StatusCode : Integer;
                              const Description : String); Virtual;
    procedure DoHttpDisconnected(Sender     : TObject;
                                 StatusCode : Integer;
                                 const Description : String); Virtual;
    procedure DoHttpConnectionStatus(ASender : TObject;
                                     const AConnectionEvent : String;
                                     AStatusCode : Integer;
                                     const ADescription : String); Virtual;
    procedure DoHttpSSLServerAuthentication(ASender      : TObject;
                                            ACertEncoded : String;
                                            const ACertSubject : String;
                                            const ACertIssuer  : String;
                                            const AStatus      : String;
                                            var   AAccept      : Boolean); Virtual;
    procedure DoHttpStartTransfer(ASender    : TObject;
                                  ADirection : Integer); Virtual;
    procedure DoHttpTransfer(ASender           : TObject;
                             ADirection        : Integer;
                             ABytesTransferred : LongInt;
                             AText             : String); Virtual;
    procedure DoHttpEndTransfer(ASender    : TObject;
                                ADirection : Integer); Virtual;
    procedure DoHttpHeader(ASender : TObject;
                           const AField : String;
                           const AValue : String); Virtual;
    procedure HttpSendRequest(Aaddress : string);
    procedure HttpPostFile(Aaddress : string;
                           AFileName : string);
    procedure HttpGetFile(Aaddress : string;
                          AFileName : string);

    procedure WaitForServerMessage(AMessage : String); virtual;

    property SoapRequester : TIpsSOAPS   read fSoapRequester write fSoapRequester;
    property SoapURLList   : TStringList read fSoapURLList   write fSoapURLList;
    property SoapURLIndex  : integer     read fSoapURLIndex  write fSoapURLIndex;

    property HttpRequester : TIpsHTTPS   read fHttpRequester write fHttpRequester;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure ReSetup;

    procedure Interupt;
  end;

var
  DebugMe : Boolean = False;

//------------------------------------------------------------------------------
implementation

uses
  WebUtils,
  LogUtil,
  StrUtils,
  Globals;

const
  UnitName = 'WebClient';

{ EWebClientError }
//------------------------------------------------------------------------------
constructor EWebClientError.Create(AMsg       : string;
                                   AErrorCode : integer);
begin
  inherited Create(AMsg);
  FErrorCode := AErrorCode;

  if DebugMe then
    LogUtil.LogMsg(lmError, UnitName, AMsg);
end;

//------------------------------------------------------------------------------
function EWebClientError.IsConnectionProblem : Boolean;
begin
  Result := False;
end;

{ EWebSoapClientError }
//------------------------------------------------------------------------------
function EWebSoapClientError.IsConnectionProblem: boolean;
begin
  Result := true;
  if (ErrorCode in [100..102, 104,105,106,107,112,116,117,211..213, 135 ]) then
    exit; //IPPort Errors

  if (ErrorCode > 1000) then
    exit;  //TCP/IP and Port error
  Result := false;
end;

{ TWebClient }
//------------------------------------------------------------------------------
procedure TWebClient.AppendHeaderInfo(const ARequester  : TipsCore;
                                      const AHeaderInfo : TStringList);
var
  Headers: string;
begin
  if AHeaderInfo.Count <= 0 then
    Exit; // nothing to do

  if (ARequester is TIpsSOAPS) then
    Headers := TIpsSOAPS(ARequester).OtherHeaders
  else if (ARequester is TIpsHTTPS) then
    Headers := TIpsHTTPS(ARequester).OtherHeaders;

  if (Headers > '') and
    (Headers[Length(Headers)]<> #10 ) then
  begin
    //Add separator
    Headers := Headers + #13#10
  end;

  if (ARequester is TIpsSOAPS) then
    TIpsSOAPS(ARequester).OtherHeaders := Headers + AHeaderInfo.Text
  else if (ARequester is TIpsHTTPS) then
    TIpsHTTPS(ARequester).OtherHeaders := Headers + AHeaderInfo.Text;
end;

//------------------------------------------------------------------------------
procedure TWebClient.SetURL(const ARequester : TipsCore;
                            const AURLList   : TStringList;
                            AURLIndex        : integer);
begin
  if (AURLIndex < 0) or
    (AURLIndex > (AURLList.Count - 1)) then
    Exit;

  if (ARequester is TIpsSOAPS) then
    TIpsSOAPS(ARequester).URL := AURLList.Strings[AURLIndex]
  else if (ARequester is TIpsHTTPS) then
    TIpsHTTPS(ARequester).URL := AURLList.Strings[AURLIndex];
end;

//------------------------------------------------------------------------------
procedure TWebClient.AppendSoapHeaderInfo;
begin
  AppendHeaderInfo(FSOAPRequester, FSoapHeaderInfo);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapHeaderInfo(AName  : string;
                                       AValue : string);
begin
  FSoapHeaderInfo.Values[AName] := AValue;
end;

//------------------------------------------------------------------------------
procedure TWebClient.ClearSoapHeader;
begin
  FSoapHeaderInfo.Clear;
end;

//------------------------------------------------------------------------------
procedure TWebClient.SetSoapURL;
begin
  SetURL(FSoapRequester, FSoapURLList, FSoapURLIndex);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseSoapErrors(AError : EIpsSOAPS);
var
  HttpCode : integer;
  ErrorPart : string;
begin
  // Cannot use a case statement Code can be too big
  if AError.Code in [169, 170, 171, 172, 173] then
  begin
    RaiseSoapError(Format('%s. (<%s>, <%s>)',
      [AError.Message, SOAPRequester.FaultCode, SOAPRequester.FaultString]), AError.Code)
  end
  else if AError.Code in [210] then
  begin
    // typically happens when the WebNotes facade server fails (No proper SOAP message back)
    RaiseSoapError('Wrong server response', 210);
  end
  else if AError.Code = 151 then
  begin
    //Could be either. Need to look at response code
    //e.message is in format 151: <HTTPCODE> <HTTPMESSAGE>
    try
      ErrorPart := MidStr(AError.Message, 6, 3); //Actually just interested in first digit
    except
      RaiseSoapError(AError.Message, 151);
    end;
    HttpCode := StrToIntDef(ErrorPart, 0);
    RaiseSoapError(AError.Message, HttpCode);
  end
  else
    // What else..
    RaiseSoapError(AError.Message, AError.Code);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseSoapError(AErrMessage : String;
                                    AErrCode    : integer);
begin
  raise EWebSoapClientError.Create(AErrMessage, AErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebClient.SoapSetup;
begin
  FSoapHeaderInfo.NameValueSeparator := ':';

  FSOAPRequester.OnConnectionStatus        := DoSoapConnectionStatus;
  FSOAPRequester.OnSSLServerAuthentication := DoSoapSSLServerAuthentication;

  FSOAPRequester.Config ('SSLSecurityFlags=0x80000000');
  FSOAPRequester.Config ('SSLEnabledProtocols=140');

  // Reset to Default...
  FSOAPRequester.ProxyServer := '*';
  FSOAPRequester.ProxyPort := 0;
  FSOAPRequester.ProxyAuthorization := '';

  //set up firewall
  FSOAPRequester.FirewallHost := '';
  FSOAPRequester.FirewallPort := 0;
  FSOAPRequester.FirewallUser := '';
  FSOAPRequester.FirewallPassword := '';
  FSOAPRequester.FirewallType := TipssoapsFirewallTypes(fwNone);

  // For Now just take the rsst from the BConnect settings...
  if INI_BCCustomConfig then
  begin
    if INI_BCUseProxy then
    begin
      FSOAPRequester.ProxyServer := INI_BCProxyHost;
      FSOAPRequester.ProxyPort := INI_BCProxyPort;
      case INI_BCProxyAuthMethod of
        1 : begin //basic
              FSOAPRequester.Config('ProxyUser=' + INI_BCProxyUsername);
              FSOAPRequester.Config('ProxyPassword=' + INI_BCProxyPassword);
            end;
        2 : begin //ntlm
              FSOAPRequester.ProxyServer := Format('*%s*%s',
                [INI_BCProxyUsername, INI_BCProxyPassword]);
            end;
      end;
    end;

    if not INI_BCUseWinInet then
      FSOAPRequester.Config('usewininet=false');

    if INI_BCUseFirewall then
    begin
      FSOAPRequester.FirewallHost := INI_BCFirewallHost;
      FSOAPRequester.FirewallPort := INI_BCFirewallPort;
      FSOAPRequester.FirewallUser := INI_BCFirewallUsername;
      FSOAPRequester.FirewallPassword := INI_BCFirewallPassword;
      FSOAPRequester.FirewallType :=  TipsSoapsFirewallTypes(INI_BCFirewallType);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapStringParam(AName  : string;
                                        AValue : string);
begin
  FSOAPRequester.AddParam(AName, AValue);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapBooleanParam(AName  : string;
                                         AValue : Boolean);
begin
  if AValue then
    FSOAPRequester.AddParam(AName, '1')
  else
    FSOAPRequester.AddParam(AName, '0');
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapDateParam(AName  : string;
                                      AValue : tStDate);
begin
  FSOAPRequester.AddParam(AName, FormatXMLdate (AValue));
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapIntParam(AName  : string;
                                     AValue : Integer);
begin
  FSOAPRequester.AddParam(AName, IntToStr(AValue));
end;

//------------------------------------------------------------------------------
procedure TWebClient.DoSoapConnectionStatus(ASender : TObject;
                                            const AConnectionEvent : String;
                                            AStatusCode : Integer;
                                            const ADescription : String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoSoapSSLServerAuthentication(ASender      : TObject;
                                                   ACertEncoded : String;
                                                   const ACertSubject : String;
                                                   const ACertIssuer  : String;
                                                   const AStatus      : String;
                                                   var   AAccept      : Boolean);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.SetSoapMethod(AMethod: string);
begin
  // This will also set the internal custom headers
  fSOAPRequester.Method := AMethod;
  // SOAPRequester.MethodURI := DefaultWebNotesMethodURI;
  fSOAPRequester.ActionURI := fSOAPRequester.MethodURI + '/' + fSOAPRequester.Method;
end;

//------------------------------------------------------------------------------
procedure TWebClient.SendSoapRequest(var ATriedAllServers : Boolean;
                                     AFirstSoapURLIndex   : Integer);
begin
  Try
    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName,
        format( 'SendRequest %s, %s', [fSOAPRequester.URL,  fSOAPRequester.ActionURI]) );

    WaitForServerMessage(Format('Waiting for server %d',[SoapURLIndex+1]));

    // Could just do SOAPRequester.SendRequest;
    // but this way we can caputre the actual packet
    fSOAPRequester.BuildPacket;

    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName,format('Sending %s ',[fSOAPRequester.SOAPPacket]));

    fSOAPRequester.SendPacket;

    fSOAPRequester.EvalPacket;
    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName,format('Reply %s ',[fSOAPRequester.ReturnValue]));
  except
    on E : EIpsSOAPS do
    begin
      if ATriedAllServers then
      begin
        RaiseSoapErrors(E);
      end
      else
      begin
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, format('Exception %s ',[ E.Message]));

        inc(fSoapURLIndex);
        if SoapURLIndex > (SoapURLList.Count-1) then
          SoapURLIndex := 0;

        SetSoapURL;

        if SoapURLIndex = AFirstSoapURLIndex then
          ATriedAllServers := True;

        // Recalls it self to try with the next Server Settings
        SendSoapRequest(ATriedAllServers, AFirstSoapURLIndex);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.CallSoapMethod;
var
  FirstSoapURLIndex : integer;
  TriedAllServers   : Boolean;
begin
  TriedAllServers   := False;
  FirstSoapURLIndex := SoapURLIndex;

  SendSoapRequest(TriedAllServers, FirstSoapURLIndex);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AppendHttpHeaderInfo;
begin
  AppendHeaderInfo(fHttpRequester, FHttpHeaderInfo);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddHttpHeaderInfo(AName  : string;
                                       AValue : string);
begin
  FHttpHeaderInfo.Values[AName] := AValue;
end;

//------------------------------------------------------------------------------
procedure TWebClient.ClearHttpHeader;
begin
  FHttpHeaderInfo.Clear;
  FHttpRequester.OtherHeaders := '';
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseHttpErrors(AError : EIpsHTTPS);
begin
  RaiseHttpError(AError.Message, AError.Code);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseHttpError(AErrMessage : String;
                                    AErrCode    : integer);
begin
  raise EWebHttpClientError.Create(AErrMessage, AErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpSetup;
begin
  FHttpHeaderInfo.NameValueSeparator := ':';

  FHttpRequester.OnConnected               := DoHttpConnected;
  FHttpRequester.OnDisconnected            := DoHttpDisconnected;
  FHttpRequester.OnConnectionStatus        := DoHttpConnectionStatus;
  FHttpRequester.OnSSLServerAuthentication := DoHttpSSLServerAuthentication;
  FHttpRequester.OnStartTransfer           := DoHttpStartTransfer;
  FHttpRequester.OnTransfer                := DoHttpTransfer;
  FHttpRequester.OnEndTransfer             := DoHttpEndTransfer;
  FHttpRequester.OnHeader                  := DoHttpHeader;

  FHttpRequester.Config ('SSLSecurityFlags=0x80000000');
  FHttpRequester.Config ('SSLEnabledProtocols=140');

  // For Now just take the rsst from the BConnect settings...
  FHttpRequester.Timeout := INI_BCTimeout;

  if INI_BCCustomConfig then
  begin
    if not INI_BCUseWinInet then
      FHttpRequester.Config('usewininet=false')
    else
      FHttpRequester.Config ('usewininet=True');

    if INI_BCUseProxy then
    begin
      FHttpRequester.ProxyServer := INI_BCProxyHost;
      FHttpRequester.ProxyPort := INI_BCProxyPort;
      case INI_BCProxyAuthMethod of
        1 : begin //basic
              FHttpRequester.ProxyUser := INI_BCProxyUsername;
              FHttpRequester.ProxyPassword := INI_BCProxyPassword;
            end;
        2 : begin //ntlm
              FHttpRequester.ProxyServer := Format('*%s*%s',
                [INI_BCProxyUsername, INI_BCProxyPassword]);
            end;
      end;
    end;

    if INI_BCUseFirewall then
    begin
      FHttpRequester.FirewallHost := INI_BCFirewallHost;
      FHttpRequester.FirewallPort := INI_BCFirewallPort;
      FHttpRequester.FirewallUser := INI_BCFirewallUsername;
      FHttpRequester.FirewallPassword := INI_BCFirewallPassword;
      FHttpRequester.FirewallType :=  TipshttpsFirewallTypes(INI_BCFirewallType);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpConnected(Sender     : TObject;
                                     StatusCode : Integer;
                                     const Description : String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpDisconnected(Sender     : TObject;
                                        StatusCode : Integer;
                                        const Description : String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpConnectionStatus(ASender: TObject;
                                            const AConnectionEvent: String;
                                            AStatusCode: Integer;
                                            const ADescription: String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpSSLServerAuthentication(ASender      : TObject;
                                                   ACertEncoded : String;
                                                   const ACertSubject : String;
                                                   const ACertIssuer  : String;
                                                   const AStatus      : String;
                                                   var   AAccept      : Boolean);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpStartTransfer(ASender    : TObject;
                                         ADirection : Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpTransfer(ASender           : TObject;
                                    ADirection        : Integer;
                                    ABytesTransferred : LongInt;
                                    AText             : String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpEndTransfer(ASender    : TObject;
                                       ADirection : Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpHeader(ASender : TObject;
                                  const AField : String;
                                  const AValue : String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpSendRequest(Aaddress: string);
begin
  Try
    FHttpRequester.Get(Aaddress);
  Except
    on E : EipsHTTPS do
      RaiseHttpErrors(E);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpPostFile(Aaddress : string;
                                  AFileName : string);
begin
  if AFileName <> '' then
    FHttpRequester.AttachedFile := AFileName;

  Try
    FHttpRequester.Post(Aaddress);
  Except
    on E : EipsHTTPS do
      RaiseHttpErrors(E);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpGetFile(Aaddress : string;
                                 AFileName : string);
begin
  FHttpRequester.LocalFile := AFileName;

  Try
    FHttpRequester.Get(Aaddress);
  Except
    on E : EipsHTTPS do
      RaiseHttpErrors(E);
  End;
end;

//------------------------------------------------------------------------------
procedure TWebClient.WaitForServerMessage(AMessage : String);
begin
end;

//------------------------------------------------------------------------------
constructor TWebClient.Create;
begin
  // Soap
  FSoapRequester  := TipsSOAPS.Create(nil);
  FSoapHeaderInfo := TStringList.Create;
  FSoapURLList    := TStringList.Create;
  SoapSetup;

  // Http
  FHttpRequester  := TIpsHTTPS.Create(nil);
  FHttpHeaderInfo := TStringList.Create;
  HttpSetup;
end;

//------------------------------------------------------------------------------
destructor TWebClient.Destroy;
begin
  // Soap
  FreeAndNil(FSOAPRequester);
  FreeAndNil(FSoapHeaderInfo);
  FreeAndNil(FSoapURLList);

  // Http
  FreeAndNil(FHttpRequester);
  FreeAndNil(FHttpHeaderInfo);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TWebClient.ReSetup;
begin
  SoapSetup;
  HttpSetup;
end;

//------------------------------------------------------------------------------
procedure TWebClient.Interupt;
begin
  FSoapRequester.Interrupt;
  FHttpRequester.Interrupt;
end;

end.
