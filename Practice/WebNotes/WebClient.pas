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
    FErrorCode: integer;
  public
    constructor Create(Msg: string; ErrorCode: integer); overload;
  published
    property ErrorCode: integer read FErrorCode write FErrorCode;
    function IsConnectionProblem : boolean; virtual;
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
    FSoapURLList   : TStringList;
    FSoapURLIndex  : integer;

    FHttpURLList   : TStringList;
    FHttpURLIndex  : integer;

    FSoapRequester : TIpsSOAPS;
    fHttpRequester : TIpsHTTPS;

    FSoapHeaderInfo : TStringList;
    FHttpHeaderInfo : TStringList;

    procedure AppendHeaderInfo(const Requester  : TipsCore;
                               const HeaderInfo : TStringList);
    procedure SetURL(const Requester : TipsCore;
                     const URLList   : TStringList;
                     URLIndex        : integer);
    procedure RaiseSoapErrors(Error : EIpsSOAPS);
    procedure RaiseHttpErrors(Error : EIpsHTTPS);
    function SearchReplaceStr(InString, Search, Replace : String) : String;
  protected
    procedure AppendSoapHeaderInfo;
    procedure AppendHttpHeaderInfo;
    procedure AddSoapHeaderInfo(Name, Value: string);
    procedure AddHttpHeaderInfo(Name, Value: string);
    procedure ClearSoapHeader;
    procedure ClearHttpHeader;

    procedure SetSoapURL;
    procedure SetHttpURL;

    procedure RaiseSoapError(ErrMessage : String; ErrCode : integer); virtual;
    procedure RaiseHttpError(ErrMessage : String; ErrCode : integer); virtual;

    procedure SoapSetup;
    procedure HttpSetup;

    procedure AddSoapStringParam(Name, Value: string);
    procedure AddSoapBooleanParam(Name: string; Value: Boolean);
    procedure AddSoapDateParam(Name: string; Value: tStDate);
    procedure AddSoapIntParam(Name: string; Value: Integer);

    procedure DoSoapConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Virtual;

    procedure DoSoapSSLServerAuthentication(Sender: TObject;
                                            CertEncoded: String;
                                            const CertSubject: String;
                                            const CertIssuer: String;
                                            const Status: String;
                                            var  Accept: Boolean); Virtual;

    procedure DoHttpConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Virtual;

    procedure DoHttpSSLServerAuthentication(Sender: TObject;
                                            CertEncoded: String;
                                            const CertSubject: String;
                                            const CertIssuer: String;
                                            const Status: String;
                                            var Accept: Boolean); Virtual;

    procedure DoHttpStartTransfer(Sender: TObject;
                                  Direction: Integer); Virtual;
    procedure DoHttpTransfer(Sender: TObject;
                             Direction: Integer;
                             BytesTransferred: LongInt;
                             Text: String); Virtual;
    procedure DoHttpEndTransfer(Sender: TObject;
                                Direction: Integer); Virtual;

    procedure DoHttpHeader(Sender: TObject;
                           const Field: String;
                           const Value: String); Virtual;

    procedure SetSoapMethod(Method: string);
    procedure SendSoapRequest(var TriedAllServers : Boolean;
                              FirstSoapURLIndex : Integer);
    procedure CallSoapMethod; Virtual;

    procedure HttpSendRequest(Address : string);
    procedure HttpPostFile(Address, FileName : string);
    procedure HttpGetFile(Address, FileName : string);

    procedure WaitForServerMessage(Message : String); virtual;

    property SoapRequester : TIpsSOAPS   read fSoapRequester write fSoapRequester;
    property HttpRequester : TIpsHTTPS   read fHttpRequester write fHttpRequester;
    property SoapURLList   : TStringList read fSoapURLList   write fSoapURLList;
    property SoapURLIndex  : integer     read fSoapURLIndex  write fSoapURLIndex;
    property HttpURLList   : TStringList read fHttpURLList   write fHttpURLList;
    property HttpURLIndex  : integer     read fHttpURLIndex  write fHttpURLIndex;
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
constructor EWebClientError.Create(Msg: string; ErrorCode: integer);
begin
  inherited Create(Msg);
  FErrorCode := ErrorCode;

  if DebugMe then
    LogUtil.LogMsg(lmError, UnitName, Msg);
end;

//------------------------------------------------------------------------------
function EWebClientError.IsConnectionProblem: Boolean;
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
procedure TWebClient.AppendHeaderInfo(const Requester : TipsCore; const HeaderInfo : TStringList);
var
  Headers: string;
begin
  if HeaderInfo.Count <= 0 then
    Exit; // nothing to do

  if (Requester is TIpsSOAPS) then
    Headers := TIpsSOAPS(Requester).OtherHeaders
  else if (Requester is TIpsHTTPS) then
    Headers := TIpsHTTPS(Requester).OtherHeaders;

  if (Headers > '') and
    (Headers[Length(Headers)]<> #10 ) then
  begin
    //Add separator
    Headers := Headers + #13#10
  end;

  if (Requester is TIpsSOAPS) then
    TIpsSOAPS(Requester).OtherHeaders := Headers + HeaderInfo.Text
  else if (Requester is TIpsHTTPS) then
    TIpsHTTPS(Requester).OtherHeaders := Headers + HeaderInfo.Text;
end;

//------------------------------------------------------------------------------
procedure TWebClient.SetURL(const Requester : TipsCore;
                            const URLList   : TStringList;
                            URLIndex        : integer);
begin
  if (URLIndex < 0) or
    (URLIndex > (URLList.Count - 1)) then
    Exit;

  if (Requester is TIpsSOAPS) then
    TIpsSOAPS(Requester).URL := URLList.Strings[URLIndex]
  else if (Requester is TIpsHTTPS) then
    TIpsHTTPS(Requester).URL := URLList.Strings[URLIndex];
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseSoapErrors(Error : EIpsSOAPS);
var
  HttpCode : integer;
  ErrorPart : string;
begin
  // Cannot use a case statement Code can be too big
  if Error.Code in [169, 170, 171, 172, 173] then
  begin
    RaiseSoapError(Format('%s. (<%s>, <%s>)',
      [Error.Message, SOAPRequester.FaultCode, SOAPRequester.FaultString]), Error.Code)
  end
  else if Error.Code in [210] then
  begin
    // typically happens when the WebNotes facade server fails (No proper SOAP message back)
    RaiseSoapError('Wrong server response', 210);
  end
  else if Error.Code = 151 then
  begin
    //Could be either. Need to look at response code
    //e.message is in format 151: <HTTPCODE> <HTTPMESSAGE>
    try
      ErrorPart := MidStr(Error.Message, 6, 3); //Actually just interested in first digit
    except
      RaiseSoapError(Error.Message, 151);
    end;
    HttpCode := StrToIntDef(ErrorPart, 0);
    RaiseSoapError(Error.Message, HttpCode);
  end
  else
    // What else..
    RaiseSoapError(Error.Message, Error.Code);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseHttpErrors(Error : EIpsHTTPS);
var
  HttpCode : integer;
  ErrorPart : string;
begin
  RaiseHttpError(Error.Message, Error.Code);
end;

//------------------------------------------------------------------------------
function TWebClient.SearchReplaceStr(InString, Search, Replace : String) : String;
var
  StrIndex : integer;
begin
  Result := '';
  for StrIndex := 1 to Length(InString) do
  begin
    if InString[StrIndex] = Search[1] then
      Result := Result + Replace
    else
      Result := Result + InString[StrIndex];
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.AppendSoapHeaderInfo;
begin
  AppendHeaderInfo(FSOAPRequester, FSoapHeaderInfo);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AppendHttpHeaderInfo;
begin
  AppendHeaderInfo(fHttpRequester, FHttpHeaderInfo);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapHeaderInfo(Name, Value: string);
begin
  FSoapHeaderInfo.Values[Name] := Value;
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddHttpHeaderInfo(Name, Value: string);
begin
  FHttpHeaderInfo.Values[Name] := Value;
end;

//------------------------------------------------------------------------------
procedure TWebClient.ClearSoapHeader;
begin
  FSoapHeaderInfo.Clear;
end;

//------------------------------------------------------------------------------
procedure TWebClient.ClearHttpHeader;
begin
  FHttpHeaderInfo.Clear;
  FHttpRequester.OtherHeaders := '';
end;

//------------------------------------------------------------------------------
procedure TWebClient.SetSoapURL;
begin
  SetURL(FSoapRequester, FSoapURLList, FSoapURLIndex);
end;

//------------------------------------------------------------------------------
procedure TWebClient.SetHttpURL;
begin
  SetURL(FHttpRequester, FHttpURLList, FHttpURLIndex);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseSoapError(ErrMessage : String; ErrCode : integer);
begin
  raise EWebSoapClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebClient.RaiseHttpError(ErrMessage : String; ErrCode : integer);
begin
  raise EWebHttpClientError.Create(ErrMessage, ErrCode);
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
procedure TWebClient.HttpSetup;
begin
  FHttpHeaderInfo.NameValueSeparator := ':';

  FHttpRequester.OnConnectionStatus        := DoHttpConnectionStatus;
  FSOAPRequester.OnSSLServerAuthentication := DoHttpSSLServerAuthentication;
  FHttpRequester.OnStartTransfer           := DoHttpStartTransfer;
  FHttpRequester.OnTransfer                := DoHttpTransfer;
  FHttpRequester.OnEndTransfer             := DoHttpEndTransfer;
  FHttpRequester.OnHeader                  := DoHttpHeader;

  FHttpRequester.Config ('SSLSecurityFlags=0x80000000');
  FHttpRequester.Config ('SSLEnabledProtocols=140');
  FSOAPRequester.Config ('usewininet=True');

  // Reset to Default...
  {FHttpRequester.ProxyServer := '*';
  FHttpRequester.ProxyPort := 0;
  FHttpRequester.ProxyAuthorization := '';
  FHttpRequester.ProxyUser := '';
  FHttpRequester.ProxyPassword := '';

  //set up firewall
  FHttpRequester.FirewallHost := '';
  FHttpRequester.FirewallPort := 0;
  FHttpRequester.FirewallUser := '';
  FHttpRequester.FirewallPassword := '';
  FHttpRequester.FirewallType := TipshttpsFirewallTypes(fwNone);}

  {// For Now just take the rsst from the BConnect settings...
  if INI_BCCustomConfig then
  begin
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

    if not INI_BCUseWinInet then
      FHttpRequester.Config('usewininet=false');

    if INI_BCUseFirewall then
    begin
      FHttpRequester.FirewallHost := INI_BCFirewallHost;
      FHttpRequester.FirewallPort := INI_BCFirewallPort;
      FHttpRequester.FirewallUser := INI_BCFirewallUsername;
      FHttpRequester.FirewallPassword := INI_BCFirewallPassword;
      FHttpRequester.FirewallType :=  TipshttpsFirewallTypes(INI_BCFirewallType);
    end;
  end;}
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapStringParam(Name, Value: string);
begin
  FSOAPRequester.AddParam(Name, Value);
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapBooleanParam(Name: string; Value: Boolean);
begin
  if Value then
    FSOAPRequester.AddParam(Name, '1')
  else
    FSOAPRequester.AddParam(Name, '0');
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapDateParam(Name: string; Value: tStDate);
begin
  FSOAPRequester.AddParam(Name, FormatXMLdate (Value));
end;

//------------------------------------------------------------------------------
procedure TWebClient.AddSoapIntParam(Name: string; Value: Integer);
begin
  FSOAPRequester.AddParam(Name, IntToStr(Value));
end;

//------------------------------------------------------------------------------
procedure TWebClient.DoSoapConnectionStatus(Sender: TObject;
                                            const ConnectionEvent: String;
                                            StatusCode: Integer;
                                            const Description: String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoSoapSSLServerAuthentication(Sender: TObject;
                                                   CertEncoded: String;
                                                   const CertSubject: String;
                                                   const CertIssuer: String;
                                                   const Status: String;
                                                   var  Accept: Boolean);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpConnectionStatus(Sender: TObject;
                                            const ConnectionEvent: String;
                                            StatusCode: Integer;
                                            const Description: String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpSSLServerAuthentication(Sender: TObject;
                                                   CertEncoded: String;
                                                   const CertSubject: String;
                                                   const CertIssuer: String;
                                                   const Status: String;
                                                   var  Accept: Boolean);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpStartTransfer(Sender: TObject;
                                         Direction: Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpTransfer(Sender: TObject;
                                    Direction: Integer;
                                    BytesTransferred: LongInt;
                                    Text: String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpEndTransfer(Sender: TObject;
                                       Direction: Integer);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.DoHttpHeader(Sender: TObject;
                                  const Field: String;
                                  const Value: String);
begin

end;

//------------------------------------------------------------------------------
procedure TWebClient.SetSoapMethod(Method: string);
begin
  // This will also set the internal custom headers
  fSOAPRequester.Method := Method;
  //SOAPRequester.MethodURI := DefaultWebNotesMethodURI;
  fSOAPRequester.ActionURI := fSOAPRequester.MethodURI + '/' + fSOAPRequester.Method;
end;

//------------------------------------------------------------------------------
procedure TWebClient.SendSoapRequest(var TriedAllServers : Boolean;
                                     FirstSoapURLIndex : Integer);
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
      if TriedAllServers then
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

        if SoapURLIndex = FirstSoapURLIndex then
          TriedAllServers := True;

        // Recalls it self to try with the next Server Settings
        SendSoapRequest(TriedAllServers, FirstSoapURLIndex);
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
procedure TWebClient.HttpSendRequest(Address: string);
begin
  try
    FHttpRequester.Get(Address)
  except
    on E : EipsHTTPS do
    begin

    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpPostFile(Address, FileName: string);
begin
  if FileName <> '' then
    FHttpRequester.AttachedFile := FileName;

  try
    FHttpRequester.Post(Address);
  except
    on E : EipsHTTPS do
    begin

    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.HttpGetFile(Address, FileName: string);
begin
  FHttpRequester.LocalFile := FileName;

  try
    FHttpRequester.Get(Address);
  except
    on E : EipsHTTPS do
    begin

    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebClient.WaitForServerMessage(Message : String);
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
  FHttpURLList    := TStringList.Create;
  HttpSetup;
end;

//------------------------------------------------------------------------------
destructor TWebClient.Destroy;
begin
  FreeAndNil(FSOAPRequester);
  FreeAndNil(FSoapHeaderInfo);
  FreeAndNil(FSoapURLList);

  FreeAndNil(FHttpRequester);
  FreeAndNil(FHttpHeaderInfo);
  FreeAndNil(FHttpURLList);

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
