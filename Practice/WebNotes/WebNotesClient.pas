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
  SysUtils,
  WebClient,
  bkUrls;

{$M+}
type
  //----------------------------------------------------------------------------
  EWebNotesClientError = class(EWebSoapClientError)
  end;

  //----------------------------------------------------------------------------
  TWebNotesClient = class(TWebClient)
  private
    FCountry      : string;
    FPassWord     : string;
    FPracticeCode : string;
    FProgress     : double;
    FHidden       : boolean;

  protected
    procedure RaiseSoapError(ErrMessage : String; ErrCode : integer); override;

    procedure SetCountry(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetPracticeCode(const Value: string);
    procedure SetHidden(const Value: Boolean);

    procedure DoSoapConnectionStatus(Sender: TObject;
                                     const ConnectionEvent: String;
                                     StatusCode: Integer;
                                     const Description: String); Override;

    procedure DoSoapSSLServerAuthentication(Sender: TObject;
                                            CertEncoded: String;
                                            const CertSubject: String;
                                            const CertIssuer: String;
                                            const Status: String;
                                            var  Accept: Boolean); Override;

    procedure WaitForServerMessage(Message : String); override;
  public
    constructor Create; override;
    constructor CreateUsingIni(IniFileName: string);
    destructor Destroy; override;

    // Actual Web service calls
    function Upload(const Batch: string; var Reply: string ): Boolean;
    function DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
    function GetAvailableData(const Client: string; var Reply: string): Boolean;
    function SetDownloadStatus(const DataId, Status: string; var Reply: string): Boolean;

    property PassWord     : string  read FPassWord     write SetPassWord;
    property PracticeCode : string  read FPracticeCode write SetPracticeCode;
    property Country      : string  read FCountry      write SetCountry;
    property Hidden       : boolean read FHidden       write SetHidden;
  published

  end;

//------------------------------------------------------------------------------
procedure HandleWNException(e: Exception; UnitName, Action : string; Prompt: Boolean = true);

//------------------------------------------------------------------------------
implementation

uses
  bkConst,
  ErrorMoreFrm,
  progress,
  Globals,
  LogUtil,
  IniFiles,
  StrUtils,
  WebUtils;

const
  //UnitName = 'WebNotesService';
  //IniWebNotesSection = 'WebNotesService';
  UnitName = 'WebNotesClient';
  IniWebNotesSection = 'WebNotesService';
  DefaultWebNotesURL =  'https://www.banklinkonline.com/services/practiceintegrationfacade.svc';
  DefaultWebNotesMethodURI ='http://BankLink.WebNotes.Interfaces/IPracticeIntegrationFacade';

//------------------------------------------------------------------------------
procedure HandleWNException(e: Exception; UnitName, Action : string; Prompt: Boolean = true );
begin
  logutil.LogError(UnitName,format('%s Error:<%s>',[Action, e.Message] ));
  if not Prompt then
    Exit;

  if (e is EWebNotesClientError) and
    EWebNotesClientError(e).IsConnectionProblem then
  begin
    HelpfulErrorMsg(format(
      '%s failed'#13#13 +
      'Could not connect to %s'#13 +
      'Please check your internet'#13 +
      'or connection settings'#13#13 +
      'Error: %s',
      [Action, BankLinkLiveName, e.message]),0);

  end
  else
  begin
    HelpfulErrorMsg(format(
      '%s failed'#13#13 +
      '%s service response incorrect'#13'Please try again later'#13#13 +
      'Error: %s',
      [Action, BankLinkLiveName, e.message]),0);
  end;
end;

{ TWebNotesClient }
//------------------------------------------------------------------------------
procedure TWebNotesClient.RaiseSoapError(ErrMessage : String; ErrCode : integer);
begin
  raise EWebNotesClientError.Create(ErrMessage, ErrCode);
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.SetCountry(const Value: string);
begin
  FCountry := Value;
  AddSoapHeaderInfo('countrycode',FCountry);
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.SetPassWord(const Value: string);
begin
  FPassWord := Value;
  AddSoapHeaderInfo('password',FPassWord);
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.SetPracticeCode(const Value: string);
begin
  FPracticeCode := Value;
  AddSoapHeaderInfo('practicecode',FPracticeCode);
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.SetHidden(const Value: Boolean);
begin
  FHidden := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.DoSoapConnectionStatus(Sender: TObject;
                                                 const ConnectionEvent: String;
                                                 StatusCode: Integer;
                                                 const Description: String);
begin
  UpdateAppStatusLine2(Format('%s server %d',[ConnectionEvent, SoapURLIndex]));
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.DoSoapSSLServerAuthentication(Sender: TObject;
                                                        CertEncoded: String;
                                                        const CertSubject: String;
                                                        const CertIssuer: String;
                                                        const Status: String;
                                                        var  Accept: Boolean);
begin
  UpdateAppStatusLine2(Format('%s Authenticate %d',[Status, SoapURLIndex]));
end;

//------------------------------------------------------------------------------
procedure TWebNotesClient.WaitForServerMessage(Message : String);
begin
  if not Hidden then
  begin
    UpdateAppStatusPerc(FProgress);
    FProgress := FProgress + 30;
    UpdateAppStatusLine2(Message);
  end;
end;

//------------------------------------------------------------------------------
constructor TWebNotesClient.Create;
begin
  inherited Create;

  //other configuration settings
  SOAPRequester.Config('useragent=BankLinkPractice/5.0');
  SOAPRequester.Config('usewininet=true');
end;

//------------------------------------------------------------------------------
constructor TWebNotesClient.CreateUsingIni(IniFileName: string);
var
  IniFile: TIniFile;
  IniURL1, IniURL2: string;
  IniMethodURI: string;
begin
  Create;

  IniURL1 := '';
  IniURL2 := '';
  IniMethodURI := '';

  if FileExists(IniFileName) then
  begin
    IniFile := TIniFile.Create(IniFileName);
    try
      IniURL1 := IniFile.ReadString(IniWebNotesSection, 'URL', '');
      IniURL2 := IniFile.ReadString(IniWebNotesSection, 'URL2', '');
      IniMethodURI := IniFile.ReadString(IniWebNotesSection, 'MethodURI', '');

    finally
      FreeAndNil(IniFile);
    end;
  end;

  if IniURL1 <> '' then
    SoapURLList.Add(IniURL1)
  else
    SoapURLList.Add(TUrls.DefaultWebNotesURL);

  if IniURL2 <> '' then
    SoapURLList.Add(IniURL2);

  if IniMethodURI <> '' then
    SOAPRequester.MethodURI := IniMethodURI
  else
    SOAPRequester.MethodURI := TUrls.DefaultWebNotesMethodURI;

  SoapURLIndex := 0;
  SetSoapURL;
end;

//------------------------------------------------------------------------------
destructor TWebNotesClient.Destroy;
begin
  inherited;
end;

{$IFDEF WebNotesLocal}
//------------------------------------------------------------------------------
function TWebNotesClient.Upload(const Batch: string; var Reply: string ): Boolean;
var
  lFile:TStringList;
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
//------------------------------------------------------------------------------
function TWebNotesClient.Upload(const Batch: string; var Reply: string ): Boolean;
begin
  Result := False;

  Reply := '';
  Fprogress := 10;
  SetSoapMethod('UploadBatch');
  AppendSoapHeaderInfo;
  AddSoapStringParam('requestXml',EncodeText(Batch));
  AddSoapStringParam('practiceCode', PracticeCode);
  AddSoapStringParam('countryCode', country);
  AddSoapIntParam('xmlVersion', 1);

  CallSoapMethod;

  Reply := DecodeText(SOAPRequester.ReturnValue);
  Result := Reply > '';
end;
{$ENDIF}

//------------------------------------------------------------------------------
function TWebNotesClient.SetDownloadStatus(const DataId, Status: string; var Reply: string): Boolean;
begin
  Result := False;
  Reply := '';
  Fprogress := 10;
  SetSoapMethod('SetDownloadDataStatus');
  AppendSoapHeaderInfo;
  AddSoapStringParam('downloadDataId', DataId);
  AddSoapStringParam('status', Status);
  AddSoapStringParam('practiceCode', PracticeCode);
  AddSoapStringParam('countryCode', country);
  AddSoapIntParam('xmlVersion', 1);

  {$IFDEF WebNotesLocal}
    Reply :=
    '<?xml version="1.0" encoding="utf-8"?><ResponseType xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Success xmlns="http://banklink.co.nz/oct/schema">true</Success></ResponseType>';

  {$ELSE}
    CallSoapMethod;

    Reply := DecodeText(SOAPRequester.ReturnValue);
  {$ENDIF}

   Result := Reply > '';
end;

{$IFDEF WebNotesLocal}
//------------------------------------------------------------------------------
function TWebNotesClient.DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
var
  lFile:TStringList;
begin
  Result := False;

  lFile := TStringList.Create;
  lFile.LoadFromFile(dataDir + 'Download.xml' );
  Reply := LFile.Text;
  lFile.Free;

  Result := Reply > '';
end;

{$ELSE}

//------------------------------------------------------------------------------
function TWebNotesClient.DownloadData(const Company, user: string; FromDate, ToDate: TStDate;  var Reply: string): Boolean;
begin
  Result := False;
  Reply := '';
  Fprogress := 10;
  SetSoapMethod('RequestDownloadData');
  AppendSoapHeaderInfo;
  AddSoapStringParam('companyCode', Company);
  AddSoapStringParam('user', User);
  AddSoapDateParam ('fromDate',Fromdate);
  AddSoapDateParam ('toDate',Todate);
  AddSoapStringParam('practiceCode', PracticeCode);
  AddSoapStringParam('countryCode', country);
  AddSoapIntParam('xmlVersion', 1);

  CallSoapMethod;

  Reply := DecodeText(SOAPRequester.ReturnValue);

  Result := Reply > '';
end;
{$ENDIF}

//------------------------------------------------------------------------------
function TWebNotesClient.GetAvailableData(const Client: string;
  var Reply: string): Boolean;
begin
  Result := False;
  Reply := '';
  Fprogress := 10;
  SetSoapMethod('GetAvailableData');
  AppendSoapHeaderInfo;
  AddSoapStringParam('companyCode', Client);
  AddSoapStringParam('practiceCode', PracticeCode);
  AddSoapStringParam('countryCode', country);

  AddSoapIntParam('xmlVersion', 1);
  {$IFDEF WebNotesLocal}
    Reply := format(
      '<?xml version="1.0" encoding="utf-8"?><AvailableDataResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
      ' xmlns="http://banklink.co.nz/oct/schema"><Success>true</Success><WaitSeconds>0</WaitSeconds><Items><Data CompanyCode="%s" FromDate="2007-07-03" ToDate="2007-07-30" Count="11" /></Items></AvailableDataResponse>',
      [Client]);

  {$ELSE}
     CallSoapMethod;
     Reply := DecodeText(SOAPRequester.ReturnValue);
  {$ENDIF}

  Result := Reply > '';
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);
  WebClient.DebugMe := DebugMe;

end.


