unit WebNotesClient;
//------------------------------------------------------------------------------
{
   Title: WebNotesClient

   Description:

        Handles the TipsSOAPS client
        Connection details based on the Bconnect settings
        The actual URL comes from BK5ini file (Hand written)


   Author: Andre' Joosten

   Remarks:


}
//------------------------------------------------------------------------------

interface

uses
    stDate,
    IpsSoaps,
    Classes,
    SysUtils;

type
{$M+}
  EWebNotesClientError = class(Exception)
  private
    FErrorCode: integer;
  public
    constructor Create(Msg: string; ErrorCode: integer); overload;
  published
    property ErrorCode: integer read FErrorCode write FErrorCode;
    function IsConnectionProblem: boolean;
  end;

  TWebNotesClient = class
  private
    FSOAPRequester: TipsSOAPS;
    FServiceURL1: string;
    FServiceURL2: string;
    FCurrentURLIndex: Integer;
    FTriedBothServers: Boolean;
    FCountry: string;
    FPassWord: string;
    FPracticeCode: string;
    FOtherHeaders: TStringList;
    Fprogress: double;
    FHidden: Boolean;

    procedure SetMethod(Method: string);
    procedure AddStringParam(Name, Value: string);
    procedure AddCustomHeader(Name, Value: string);
    procedure AddBooleanParam(Name: string; Value: Boolean);
    procedure AddDateParam(Name: string; Value: tStDate);
   
    procedure AddIntParam(Name: string; Value: Integer);
    procedure CallMethod;
    procedure SetCurrentURLIndex(const Value: Integer);

    procedure SetCountry(const Value: string);
    procedure SetPassWord(const Value: string);
    procedure SetPracticeCode(const Value: string);

    procedure AppendCustomHeaders;
    procedure StatusEvent (Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String);
    procedure SSLEvent( Sender: TObject;
                            CertEncoded: String;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const Status: String;
                           var  Accept: Boolean);
    procedure SetHidden(const Value: Boolean);

  public
    constructor Create(IniFileName: string);

    destructor Destroy; override;
    //procedure LoadConfig(Config: string);
    procedure Interupt;

    property PassWord: string read FPassWord write SetPassWord;
    property PracticeCode: string read FPracticeCode write SetPracticeCode;
    property Country: string read FCountry write SetCountry;


    property Hidden: Boolean read FHidden write SetHidden;


    // Actual Web service calls
    function Upload(const Batch: string; var Reply: string ): Boolean;
    function DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
    function GetAvailableData(const Client: string; var Reply: string): Boolean;
    function SetDownloadStatus(const DataId, Status: string; var Reply: string): Boolean;
  published

  end;


  
procedure HandleWNException(e: Exception; UnitName, Action : string; Prompt: Boolean = true);


implementation

uses
   bkConst,
   ErrorMoreFrm,
   WebnotesSchema,
   progress,
   Globals,
   LogUtil,
   IniFiles,
   StrUtils;

var
  DebugMe: Boolean = False;

  
procedure HandleWNException(e: Exception; UnitName, Action : string; Prompt: Boolean = true );
begin

   logutil.LogError(UnitName,format('%s Error:<%s>',[Action, e.Message] ));
   if not Prompt then
      Exit;

   if (e is EWebNotesClientError)
   and  EWebNotesClientError(e).IsConnectionProblem then  begin
        HelpfulErrorMsg(format(
          '%s failed'#13#13 +
          'Could not connect to %s'#13 +
          'Please check your internet'#13 +
          'or connection settings'#13#13 +
          'Error: %s',
          [Action, BankLinkLiveName, e.message]),0);

   end else begin
       HelpfulErrorMsg(format(
          '%s failed'#13#13 +
          '%s service response incorrect'#13'Please try again later'#13#13 +
          'Error: %s',
          [Action, BankLinkLiveName, e.message]),0);

   end;

end;



{ TWebNotesService }

const
   UnitName = 'WebNotesService';

   IniWebNotesSection = 'WebNotesService';
  // DefaultWebNotesURL =  'http://localhost:8731/';
   //DefaultWebNotesURL =  'http://bessielou.banklinkonline.com/services/practiceintegrationfacade.svc';
   DefaultWebNotesURL =  'https://www.banklinkonline.com/services/practiceintegrationfacade.svc';
   //DefaultWebNotesMethodURI =  'http://BankLink.WebNotesTest.Interfaces/ITestService';
   DefaultWebNotesMethodURI ='http://BankLink.WebNotes.Interfaces/IPracticeIntegrationFacade';

   //DefaultWebNotesMethodURI = '';
   GrpBConnect = 'BConnect'; // Borrowed from The Bconnect setting...


   

constructor TWebNotesClient.Create(IniFileName: string);
var

  IniFile: TIniFile;
  IniURL1, IniURL2: string;
  IniMethodURI: string;


begin
  FTriedBothServers := false;
  FOtherHeaders := TStringList.Create;
  FOtherHeaders.NameValueSeparator := ':';
  FSOAPRequester := TipsSOAPS.Create(nil);
  FSOAPRequester.OnConnectionStatus := StatusEvent;
  FSOAPRequester.FOnSSLServerAuthentication := SSLEvent;
  FSOAPRequester.Config ('SSLSecurityFlags=0x80000000');
  FSOAPRequester.Config ('SSLEnabledProtocols=140');
   


  IniURL1 := '';
  IniURL2 := '';
  IniMethodURI := '';

  // Reset to Default...
  
  FSOAPRequester.ProxyServer := '*';
  FSOAPRequester.ProxyPort := 0;
  FSOAPRequester.ProxyAuthorization := '';

  

  //set up firewall
  FSOAPRequester.FirewallHost := '';
  FSOAPRequester.FirewallPort := 0;
  FSOAPRequester.FirewallUser := '';
  FSOAPRequester.FirewallPassword := '';
  FSOAPRequester.FirewallType := fwNone;
  //other configuration settings
  FSOAPRequester.Config('useragent=BankLinkPractice/5.0');
  FSOAPRequester.Config('usewininet=true');


  if FileExists(IniFileName) then
  begin
    IniFile := TIniFile.Create(IniFileName);
    try
      IniURL1 := IniFile.ReadString(IniWebNotesSection, 'URL', '');
      IniURL2 := IniFile.ReadString(IniWebNotesSection, 'URL2', '');
      IniMethodURI := IniFile.ReadString(IniWebNotesSection, 'MethodURI', '');

    finally
      IniFile.Free;
    end;
  end;

  if IniURL1 <> '' then
    FServiceURL1 := IniURL1
  else
    FServiceURL1 := DefaultWebNotesURL;

  if IniURL2 <> '' then
    FServiceURL2 := IniURL2
  else
    FServiceURL2 := DefaultWebNotesURL;

  SetCurrentURLIndex(1);  

  if IniMethodURI <> '' then
    FSOAPRequester.MethodURI := IniMethodURI
  else
    FSOAPRequester.MethodURI := DefaultWebNotesMethodURI;


  // For Now just take the rsst from the BConnect settings...

  if INI_BCCustomConfig then begin
     if INI_BCUseProxy then begin
        FSOAPRequester.ProxyServer := INI_BCProxyHost;
        FSOAPRequester.ProxyPort := INI_BCProxyPort;
        case INI_BCProxyAuthMethod of
           1:begin //basic
                  FSOAPRequester.Config('ProxyUser=' + INI_BCProxyUsername);
                  FSOAPRequester.Config('ProxyPassword=' + INI_BCProxyPassword);
                end;
           2: begin //ntlm
                  FSOAPRequester.ProxyServer := Format('*%s*%s',
                    [INI_BCProxyUsername, INI_BCProxyPassword]);
                end;
        end;
     end;

     if not INI_BCUseWinInet then
         FSOAPRequester.Config('usewininet=false');

     if INI_BCUseFirewall then begin
        FSOAPRequester.FirewallHost := INI_BCFirewallHost;
        FSOAPRequester.FirewallPort := INI_BCFirewallPort;
        FSOAPRequester.FirewallUser := INI_BCFirewallUsername;
        FSOAPRequester.FirewallPassword := INI_BCFirewallPassword;
        FSOAPRequester.FirewallType :=  TipssoapsFirewallTypes(INI_BCFirewallType);
     end;

  end;


end;



destructor TWebNotesClient.Destroy;
begin
  FreeAndNil(FSOAPRequester);
  FreeAndNil(FOtherHeaders);
  inherited;
end;

 (*
function TWebNotesClient.Ping(pingAppService: Boolean): string;
begin

  //'SOAPAction: http://BankLink.WebNotesTest.Interfaces/ITestService/Ping';
  SetMethod('Ping');
  AppendCustomHeaders;
  //FSOAPRequester.OtherHeaders := FSOAPRequester.OtherHeaders + #13#10'myuser: pw'#13#10;
   AddBooleanParam('pingAppService', pingAppService);


  //

  CallMethod;
  Result := FSOAPRequester.ReturnValue;
end;
  *)


procedure TWebNotesClient.Interupt;
begin
  FSOAPRequester.Interrupt;
end;


procedure TWebNotesClient.CallMethod;
var
  s: string;
  httpCode: Integer;
begin
  try
    if DebugMe then
       LogUtil.LogMsg(lmDebug,UnitName,
           format( 'SendRequest %s, %s', [FSOAPRequester.URL,  FSOAPRequester.ActionURI]) );

    if not Hidden then begin
       UpdateAppStatusPerc(FProgress);
       FProgress := FProgress + 30;
       UpdateAppStatusLine2(Format('Waiting for server %d',[FCurrentURLIndex]));
    end;

    // Could just do FSOAPRequester.SendRequest;
    // but this way we can caputre the actual packet

    FSOAPRequester.BuildPacket;

    if DebugMe then
       LogUtil.LogMsg(lmDebug,UnitName,format('Sending %s ',[FSOAPRequester.SOAPPacket]));
    FSOAPRequester.SendPacket;

    FSOAPRequester.EvalPacket;
    if DebugMe then
       LogUtil.LogMsg(lmDebug,UnitName,format('Reply %s ',[FSOAPRequester.ReturnValue]));

    // Had no exceptions Set for next time
    FTriedBothServers := False;
  except
    on E: EipsSOAPS do
    begin

      if DebugMe then
         LogUtil.LogMsg(lmDebug,UnitName,format('Exception %s ',[ E.Message]));

      //Try the second one (unless we're already on second).
      if (FCurrentURLIndex = 1)
      and (not FTriedBothServers) then begin
        SetCurrentURLIndex(2);
        // Try again...
        CallMethod;

      end else if (FCurrentURLIndex = 2) then begin
        //If the second one fails, try one again to get the original error back.
        FTriedBothServers := true;
        SetCurrentURLIndex(1);
        // Try Again
        CallMethod;

      end else begin
        // Have tryed enough, Deal with the error
        // Cannot use a case statement Code can be too big
        if E.Code in [169, 170, 171, 172, 173] then begin

          raise EWebNotesClientError.Create(Format('%s. (<%s>, <%s>)',
             [E.Message, FSOAPRequester.FaultCode, FSOAPRequester.FaultString]), E.Code)
        end else if E.Code in [210] then begin
           // typically happens when the WebNotes facade server fails (No proper SOAP message back)
           raise EWebNotesClientError.Create('Wrong server response', 210);
        end  else if E.Code = 151 then begin
           //Could be either. Need to look at response code
           //e.message is in format 151: <HTTPCODE> <HTTPMESSAGE>
           try
             s := MidStr(E.Message, 6, 3); //Actually just interested in first digit
           except
             raise EWebNotesClientError.Create(E.Message, 151);
           end;
           httpCode := StrToIntDef(s, 0);
           raise EWebNotesClientError.Create(E.Message, httpCode);
        end else
           // What else..
           raise EWebNotesClientError.Create(E.Message, E.Code)
      end;
    end;
  end;

end;

procedure TWebNotesClient.AddStringParam(Name, Value: string);
begin
  FSOAPRequester.AddParam(Name, Value);
end;

procedure TWebNotesClient.AppendCustomHeaders;
 var
   Headers: string;
begin
    if FOtherHeaders.Count <= 0 then
       Exit; // nothing to do

    Headers :=  FSOAPRequester.OtherHeaders;
    if (Headers > '')
    and (Headers[Length(Headers)]<> #10 ) then begin
       //Add separator
       Headers :=  Headers + #13#10
    end;
    FSOAPRequester.OtherHeaders := Headers + FOtherHeaders.Text;
end;

procedure TWebNotesClient.AddCustomHeader(Name, Value: string);
begin
   FOtherHeaders.Values[Name] := Value;
end;


procedure TWebNotesClient.AddDateParam(Name: string; Value: tStDate);
begin
  FSOAPRequester.AddParam(Name, FormatXMLdate (Value));
end;

procedure TWebNotesClient.AddIntParam(Name: string; Value: Integer);
begin
  FSOAPRequester.AddParam(Name, IntToStr(Value));
end;


procedure TWebNotesClient.AddBooleanParam(Name: string; Value: Boolean);
begin
  if Value then
    FSOAPRequester.AddParam(Name, '1')
  else
    FSOAPRequester.AddParam(Name, '0')
end;


procedure TWebNotesClient.SetCountry(const Value: string);
begin
   FCountry := Value;
   AddCustomHeader('countrycode',FCountry);
end;

procedure TWebNotesClient.SetCurrentURLIndex(const Value: Integer);
begin
  FCurrentURLIndex := Value;
  if Value = 2 then
    FSOAPRequester.URL := FServiceURL2
  else
    FSOAPRequester.URL := FServiceURL1;
end;


procedure TWebNotesClient.SetHidden(const Value: Boolean);
begin
  FHidden := Value;
end;

procedure TWebNotesClient.SetMethod(Method: string);
begin
  // This will also set the internal custom headers
  FSOAPRequester.Method := Method;
  //FSOAPRequester.MethodURI := DefaultWebNotesMethodURI;
  FSOAPRequester.ActionURI := FSOAPRequester.MethodURI + '/' + FSOAPRequester.Method;

end;

procedure TWebNotesClient.SetPassWord(const Value: string);
begin
  FPassWord := Value;
  AddCustomHeader('password',FPassWord);
end;

procedure TWebNotesClient.SetPracticeCode(const Value: string);
begin
  FPracticeCode := Value;
  AddCustomHeader('practicecode',FPracticeCode);
end;


procedure TWebNotesClient.SSLEvent(Sender: TObject; CertEncoded: String;
  const CertSubject, CertIssuer, Status: String; var Accept: Boolean);
begin
  UpdateAppStatusLine2(Format('%s Authenticate %d',[Status, FCurrentURLIndex]));
end;

procedure TWebNotesClient.StatusEvent(Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String);
begin
   UpdateAppStatusLine2(Format('%s server %d',[ConnectionEvent, FCurrentURLIndex]));
end;

{$IFDEF WebNotesLocal}

function TWebNotesClient.Upload(const Batch: string; var Reply: string ): Boolean;
var lFile:TStringList;
begin
   Result := False;
      lFile := TStringList.Create;
      LFile.Text := batch;
      lFile.SaveToFile(dataDir + 'Upload.xml' );
      lFile.Free;
      Reply :=
      '<?xml version="1.0" encoding="utf-8"?><ResponseType xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
      'xmlns:q1="http://banklink.co.nz/oct/schema" xsi:type="q1:UploadBatchResponseType"><q1:Success>true</q1:Success><q1:ClientURL>https://best.banklinkonline.com?email=andre.joosten@banklink.co.nz</q1:ClientURL></ResponseType>';
   Result := Reply > '';
end;

{$ELSE}

function TWebNotesClient.Upload(const Batch: string; var Reply: string ): Boolean;
begin
   Result := False;

      Reply := '';
      Fprogress := 10;
      SetMethod('UploadBatch');
      AppendCustomHeaders;
      AddStringParam('requestXml',EncodeText(Batch));
      AddStringParam('practiceCode', PracticeCode);
      AddStringParam('countryCode', country);
      AddIntParam('xmlVersion', 1);

      CallMethod;

      Reply := DecodeText(FSOAPRequester.ReturnValue);
   Result := Reply > '';
end;

{$ENDIF}



function TWebNotesClient.SetDownloadStatus(const DataId, Status: string; var Reply: string): Boolean;
begin
 Result := False;
   Reply := '';
   Fprogress := 10;
   SetMethod('SetDownloadDataStatus');
   AppendCustomHeaders;
   AddStringParam('downloadDataId', DataId);
   AddStringParam('status', Status);
   AddStringParam('practiceCode', PracticeCode);
   AddStringParam('countryCode', country);
   AddIntParam('xmlVersion', 1);



{$IFDEF WebNotesLocal}
   Reply :=
'<?xml version="1.0" encoding="utf-8"?><ResponseType xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Success xmlns="http://banklink.co.nz/oct/schema">true</Success></ResponseType>';

{$ELSE}
   CallMethod;

   Reply := DecodeText(FSOAPRequester.ReturnValue);
{$ENDIF}

   Result := Reply > '';
end;

{$IFDEF WebNotesLocal}

function TWebNotesClient.DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
var lFile:TStringList;
begin
   Result := False;
      lFile := TStringList.Create;
      lFile.LoadFromFile(dataDir + 'Download.xml' );
      Reply := LFile.Text;
      lFile.Free;
   Result := Reply > '';
end;

{$ELSE}



function TWebNotesClient.DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
begin
   Result := False;
   Reply := '';
   Fprogress := 10;
   SetMethod('RequestDownloadData');
   AppendCustomHeaders;
   AddStringParam('companyCode', Company);
   AddStringParam('user', User);
   AddDateParam ('fromDate',Fromdate);
   AddDateParam ('toDate',Todate);
   AddStringParam('practiceCode', PracticeCode);
   AddStringParam('countryCode', country);
   AddIntParam('xmlVersion', 1);

   CallMethod;

   Reply := DecodeText(FSOAPRequester.ReturnValue);

   Result := Reply > '';
end;
{$ENDIF}


function TWebNotesClient.GetAvailableData(const Client: string;
  var Reply: string): Boolean;
begin
   Result := False;
   Reply := '';
   Fprogress := 10;
   SetMethod('GetAvailableData');
   AppendCustomHeaders;
   AddStringParam('companyCode', Client);
   AddStringParam('practiceCode', PracticeCode);
   AddStringParam('countryCode', country);

   AddIntParam('xmlVersion', 1);
{$IFDEF WebNotesLocal}
   Reply := format(
 '<?xml version="1.0" encoding="utf-8"?><AvailableDataResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
 ' xmlns="http://banklink.co.nz/oct/schema"><Success>true</Success><WaitSeconds>0</WaitSeconds><Items><Data CompanyCode="%s" FromDate="2007-07-03" ToDate="2007-07-30" Count="11" /></Items></AvailableDataResponse>',
  [Client]);

{$ELSE}
   CallMethod;

   Reply := DecodeText(FSOAPRequester.ReturnValue);
{$ENDIF}

   Result := Reply > '';
end;


{ EWebNotesClientError }

constructor EWebNotesClientError.Create(Msg: string; ErrorCode: integer);
begin
  inherited Create(Msg);
  FErrorCode := ErrorCode;

  if DebugMe then
     LogUtil.LogMsg(lmError,UnitName,Msg);
end;

function EWebNotesClientError.IsConnectionProblem: Boolean;
begin
   Result := true;
   if (ErrorCode in [100..102, 104,105,106,107,112,116,117,211..213, 135 ]) then
      exit; //IPPort Errors

   if (ErrorCode > 1000) then
      exit;  //TCP/IP and Port error

   Result := False;
end;

initialization
 DebugMe := DebugUnit(UnitName);
end.
