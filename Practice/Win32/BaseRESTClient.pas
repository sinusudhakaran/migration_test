unit BaseRESTClient;

interface

uses
  Classes,
  SysUtils,
  uLKJSON,
  StrUtils,
  ipshttps,
  LogUtil,
  Globals,
  Variants,
  DateUtils,
  ExtCtrls, // for timer
  Dialogs; // can be removed

type
  TOnAPIFinished = procedure(var AAPIResponse : string) of object;
  TOnAPIError = procedure(var AAPIError : string) of object;

  TResponseDataType = (rdtJSON, rdtHTML);

  {Class for the URL query strings . This is used inside THTTPParams}
  TUrlParams = class
  private
    FParams: TStringList;
    function GetParam(i : Integer):string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Name, Value: String);
    function FillParams(AUrl: String): String;
    function GetCount: Integer;
    procedure CopyParams(AParams: TUrlParams);

    property Param[i:Integer] : string read GetParam;
  end;

  {Token class}
  TAPIAuthTokens = class(TlkJsonObject)
  private
    FAccessToken : string;
    FTokenType : string;
    FRefreshToken : string;
    FExpiresIn : string;
    FScope : string;
    FWillExpireAt: TDateTime;
  public
    constructor Create; virtual;

    procedure Deserialize(aJson: String);
    function Serialize: String;

    function SaveTokens: Boolean;// Save tokens to practice database

    property AccessToken : string read FAccessToken write FAccessToken;
    property TokenType : string read FTokenType write FTokenType;
    property RefreshToken : string read FRefreshToken write FRefreshToken;
    property ExpiresIn : string read FExpiresIn write FExpiresIn;
    property Scope : string read FScope write FScope;
    property WillExpireAt: TDateTime read FWillExpireAt write FWillExpireAt;

    procedure CopyTokens(AToken : TAPIAuthTokens);
  end;

  {Class for the parameters for the API call, whenever you add a new parameter,
  initialize it in create and add it in copyparams function and modify SetHttpParameters of
  TBaseRestClient class}

  THTTPParams = class
  private
    FAuthorization: string;
    FRequestURLParams: TUrlParams;
    FRequestTokens: TAPIAuthTokens;
    FRequestHeader: string;
    FRequestContentType: string;
    FRequestURL: string;
    FRequestAccept: string;
    FRetryCount: Integer;
    FRetries: Integer;
    FPostData: string;
    FResponseDataType : TResponseDataType;
    FRequestUser : string;
    FRequestPassword : string;
    FAPIResponseWaitInterval: Integer;

    procedure SetRequestAccept(const Value: string);
    procedure SetRequestContentType(const Value: string);
    procedure SetRequestHeader(const Value: string);
  public
    property RequestURL : string read FRequestURL write FRequestURL;
    property RequestURLParams : TUrlParams read FRequestURLParams write FRequestURLParams;
    property RequestTokens : TAPIAuthTokens read FRequestTokens write FRequestTokens;
    property RequestContentType : string read FRequestContentType write SetRequestContentType;
    property RequestAccept : string read FRequestAccept write SetRequestAccept;
    property Authorization : string read FAuthorization write FAuthorization;
    property RequestHeader : string read FRequestHeader write SetRequestHeader;
    property PostData : string read FPostData write FPostData;
    property ResponseDataType : TResponseDataType read FResponseDataType write FResponseDataType;
    property RequestUser : string read FRequestUser write FRequestUser;
    property RequestPassword : string read FRequestPassword write FRequestPassword;

    property RetryCount : Integer read FRetryCount write FRetryCount;
    property Retries : Integer read FRetries write FRetries;
    property APIResponseWaitInterval : Integer read FAPIResponseWaitInterval write FAPIResponseWaitInterval;

    constructor Create;virtual;
    destructor Destroy;override;

    procedure CopyParams(AParams: THttpParams);
    function MakeUrl: String;
  end;

  {Class for the error object. Holds error code, Error message from API if any or
  the generic error message }
  TAPIError = class(TlkJSONobject)
  private
    FErrorCode : Integer;
    FErrorDescription : string;
    FErrorFromAPI: string;
  public
    constructor Create;virtual;
    procedure DeSerialize(AJson : string);
    function Serialize:string;
    procedure Clear;

    procedure Copy(AError : TAPIError);

    property ErrorCode : Integer read FErrorCode write FErrorCode;
    property ErrorDescription : string read FErrorDescription write FErrorDescription;
    property ErrorFromAPI : string read FErrorFromAPI write FErrorFromAPI;
  end;

  {Base class for the rest client, Does all the API calls and calls the finish and error events if anything has set}
  TBaseRESTClient = class
  private
    FSupportNumber : string;
    FResponseDataType : TResponseDataType;

    FLogMessageType : TMessageType;
    FLogMessage : string;

    FWaitAPIResponseTimer: TTimer;
    FAPIResponseWaitInterval : Integer;
    FAPIWaitTimeoutOccurred : Boolean;

    procedure SetAPIResponseWaitInterval(AValue : Integer);// in seconds
    procedure WaitAPITimerEvent(Sender : TObject);

    procedure LogActivity(AMessageType: TMessageType; AMessage:string);
    procedure SynchronizeLogActivity;

    procedure ProcessReceivedData(aTestData:string='');
    procedure SynchronizeFinishEvent;
    procedure SynchronizeErrorEvent;

    function ProcessErrorMessageFromAPI(aErrorMessage: string): string;
    function ReturnGenericErrorMessage(AErrorCode : integer ) : string;

    function GetSupportNumber: string;

    procedure SetError(ACheckForAPIResponse : Boolean; Code : Integer);
    procedure InitializeAPICall;
  protected
    FAPIError : TAPIError;
    FOwnerThread : TThread;
    FHttpRequester : TipsHTTPS;
    FHttpParams: THTTPParams;
    FReceivedData : string;

    // API events
    FOnAPIError: TOnAPIError;
    FOnAPIFinished: TOnAPIFinished;
    FDataTransferStarted : Boolean;

    {Start of the data transfer function, clear the storage list and make it
    ready for the data receives}
    procedure DoHttpStartTransfer(ASender    : TObject;
                                  ADirection : Integer); Virtual;

    {This procedure stores each set of data receives}
    procedure DoHttpTransfer(ASender           : TObject;
                             ADirection        : Integer;
                             ABytesTransferred : LongInt;
                             AText             : String); Virtual;

    {End of the data transfer function- This procedure process all data received}
    procedure DoHttpEndTransfer(ASender    : TObject;
                                ADirection : Integer); Virtual;

  public
    constructor Create(AOwnerThread : TThread);virtual;
    destructor Destroy;override;

    procedure SetHttpParameters(AHttpParams: THTTPParams);

    function DoHttpGet:Boolean;virtual;
    function DoHttpPost:Boolean;virtual;
    function DoHttpDelete:Boolean;virtual;

    property SupportNumber : string read GetSupportNumber;
    property ResponseDataType : TResponseDataType read FResponseDataType write FResponseDataType;

    // These are the events for the async calls, Use thread to do API calls, Finish/error events will be captured using below events
    property OnAPIFinished: TOnAPIFinished read FOnAPIFinished write FOnAPIFinished;
    property OnAPIError: TOnAPIError read FOnAPIError write FOnAPIError;
    property APIResponseWaitInterval : Integer read FAPIResponseWaitInterval write SetAPIResponseWaitInterval; // in seconds
  end;

  TRESTClient = class(TBaseRESTClient)
  public
    constructor Create(AOwnerThread : TThread);virtual;

    // Before call get/post/delete , set APIAuthTokens/ RequestContentType/RequestAccept
    function DoHttpGet(var AHTTPParams: THTTPParams; var AResponse: string;var AAPIError: string;AUseThread :Boolean):Boolean;overload;
    function DoHttpPost(var AHTTPParams: THTTPParams;var AResponse: string; var AAPIError: string;AUseThread :Boolean):Boolean;overload;
    function DoHttpDelete(var AHTTPParams : THTTPParams; var AResponse: string;var AAPIError: string;AUseThread :Boolean):Boolean;overload;
    function DoHttpPostFormData(var AHTTPParams : THTTPParams;AFormFields: TStrings; var AResponse: string; var AAPIError: string;AUseThread :Boolean):Boolean;
  end;

  //Thread to execute API request
  THttpRequesterThread = class(TThread)
  private
    FBaseRESTClient : TBaseRESTClient;
    FHTTPParams : THTTPParams;
    FHTTPMethod : string;
  public
    constructor Create(CreateSupended: Boolean;
        AHttpMethod: string;
        AHTTPParams: THTTPParams;
        AOnFinished:TOnAPIFinished; AOnError : TOnAPIError);reintroduce;

    procedure Execute;override;
  end;


const
  UnitName = 'BaseRESTClient';
  CRLF = #13#10;

var
  DebugMe : Boolean = False;

implementation

uses
  bkContactInformation,
  Forms;

function GetStringLength(AString : string):Integer;
begin
  Result := Length(Trim(AString));
end;

function URLEncode(const ASrc: String): String;
var
  i: Integer;
const
  UnsafeChars = ['*', '#', '%', '<', '>', ' ','[',']'];  {do not localize}
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(ASrc) do
  begin
    if (ASrc[i] in UnsafeChars) or (not (ord(ASrc[i])in [33..128])) then
    begin {do not localize}
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);  {do not localize}
    end
    else
    begin
      Result := Result + ASrc[i];
    end;
  end;
end;

{ TAPI_Token }

procedure TAPIAuthTokens.CopyTokens(AToken: TAPIAuthTokens);
begin
  if not Assigned(AToken) then
    Exit;
  Self.AccessToken := AToken.AccessToken;
  Self.RefreshToken := AToken.RefreshToken;
  Self.ExpiresIn := AToken.ExpiresIn;
  Self.Scope := AToken.Scope;
  Self.WillExpireAt := AToken.WillExpireAt;
end;

constructor TAPIAuthTokens.Create;
begin
  FAccessToken := '';
  FTokenType := '';
  FRefreshToken := '';
  FExpiresIn := '';
  FScope := '';
  FWillExpireAt := 0;
end;

procedure TAPIAuthTokens.Deserialize(aJson: String);
var
  JsonObject: TlkJSONbase;
begin
  JsonObject := TlkJSON.ParseText(aJson);

  if (JsonObject = nil) then
    Exit;

  try
    if Assigned( JsonObject.Field['access_token'] ) then
      FAccessToken := VarToStr( JsonObject.Field['access_token'].Value );
    if Assigned( JsonObject.Field['token_type'] ) then
      FTokenType := VarToStr( JsonObject.Field['token_type'].Value );
    if Assigned( JsonObject.Field['refresh_token'] ) then
      FRefreshToken := VarToStr( JsonObject.Field['refresh_token'].Value );
    if Assigned( JsonObject.Field['expires_in'] ) then
      FExpiresIn := VarToStr( JsonObject.Field['expires_in'].Value );
    if Assigned( JsonObject.Field['scope'] ) then
      FScope := VarToStr( JsonObject.Field['scope'].Value );

// Calculate when this token will expire//
    FWillExpireAt := Now + ( OneSecond * strToInt( FExpiresIn ) )
  finally
    JsonObject.Free;
  end;
end;

function TAPIAuthTokens.SaveTokens: Boolean;
begin

end;

function TAPIAuthTokens.Serialize: String;
begin

end;

{ TBaseRESTClient }
constructor TRESTClient.Create(AOwnerThread : TThread);
begin
  inherited Create(AOwnerThread) ;
end;


function TRESTClient.DoHttpDelete(var AHTTPParams : THTTPParams; var AResponse: string;var AAPIError: string;AUseThread :Boolean):Boolean;
var
  HttpRequesterThread : THttpRequesterThread;
begin
  Result := False;

  if not Assigned(AHTTPParams) then
  begin
    LogActivity(lmDebug, 'HTTP params are not defined');
    Exit;
  end;

  AAPIError := '';
  AResponse := '';

  if AUseThread then // Call thread to do get, events should be set prior to this call
    HttpRequesterThread := THttpRequesterThread.Create(False,'DELETE', AHTTPParams, FOnAPIFinished, FOnAPIError)
  else
  begin
    SetHttpParameters(AHTTPParams);
    
    Result := DoHttpPost; // call api

    if Result then
      AResponse := FReceivedData
    else
      AAPIError := FAPIError.Serialize;
  end;
end;

function TRESTClient.DoHttpGet(var AHTTPParams: THTTPParams;
  var AResponse: string; var AAPIError: string;AUseThread :Boolean):Boolean;
var
  HttpRequesterThread : THttpRequesterThread;
begin
  Result := False;

  if not Assigned(AHTTPParams) then
  begin
    LogActivity(lmDebug, 'HTTP params are not defined');
    Exit;
  end;

  AAPIError := '';
  AResponse := '';

  if AUseThread then // Call thread to do get, events should be set prior to this call
    HttpRequesterThread := THttpRequesterThread.Create(False, 'GET' , AHTTPParams, FOnAPIFinished, FOnAPIError)
  else
  begin
    SetHttpParameters(AHTTPParams);

    Result := DoHttpGet; // call api

    if Result then
      AResponse := FReceivedData
    else
      AAPIError := FAPIError.Serialize;
  end;
end;

function TRESTClient.DoHttpPost(var AHTTPParams: THTTPParams;var AResponse: string; var AAPIError: string;AUseThread :Boolean):Boolean;
var
  HttpRequesterThread : THttpRequesterThread;
begin
  Result := False;

  if not Assigned(AHTTPParams) then
  begin
    LogActivity(lmDebug, 'HTTP params are not defined');
    Exit;
  end;

  AAPIError := '';
  AResponse := '';

  if AUseThread then // Call thread to do get, events should be set prior to this call
    HttpRequesterThread := THttpRequesterThread.Create(False,'POST', AHTTPParams, FOnAPIFinished, FOnAPIError)
  else
  begin
    SetHttpParameters(AHTTPParams);
    
    Result := DoHttpPost; // call api

    if Result then
      AResponse := FReceivedData
    else
      AAPIError := FAPIError.Serialize;
  end;
end;

function TRESTClient.DoHttpPostFormData(var AHTTPParams: THTTPParams; AFormFields: TStrings;
  var AResponse: string; var AAPIError: string;AUseThread :Boolean):Boolean;
var
  sFormData : string;
  Index: Integer;
begin
  sFormData := '';
  for Index := 0 to AFormFields.Count - 1 do
  begin
    if Index + 1 < AFormFields.Count then
      sFormData := URLEncode(AFormFields[Index] + '&')
    else
      sFormData := URLEncode(AFormFields[Index]);
  end;

  AHTTPParams.PostData := sFormData;
  Result := DoHttpPost(AHTTPParams,AResponse, AAPIError, AUseThread);
end;

{ TBaseRESTClient }

constructor TBaseRESTClient.Create(AOwnerThread: TThread);
begin
  //inherited;
  FHttpRequester := TipsHTTPS.Create(Nil);

  FWaitAPIResponseTimer:= TTimer.Create(Application);
  FWaitAPIResponseTimer.OnTimer := WaitAPITimerEvent;
  FWaitAPIResponseTimer.Enabled := False;
  
  FAPIError := TAPIError.Create;

  FOwnerThread := AOwnerThread;

  FHttpRequester.AuthScheme := authBasic;

  FHttpRequester.OnStartTransfer := DoHttpStartTransfer;
  FHttpRequester.OnTransfer := DoHttpTransfer;
  FHttpRequester.OnEndTransfer := DoHttpEndTransfer;
  
  FAPIResponseWaitInterval := 0;
end;

destructor TBaseRESTClient.Destroy;
begin
  if Assigned(FHttpRequester) then
  begin
    FHttpRequester.Connected := False;
    FreeAndNil(FHttpRequester);
  end;

  if Assigned(FAPIError) then
    FreeAndNil(FAPIError);
    
  if Assigned(FWaitAPIResponseTimer) then
    FreeAndNil(FWaitAPIResponseTimer);

  FOwnerThread := Nil;
    
  inherited;
end;

function TBaseRESTClient.DoHttpDelete: Boolean;
var
  ResponseJSON : TlkJSONbase;
begin
  Result := False;
  try
    FHttpRequester.HTTPMethod := 'DELETE';
    InitializeAPICall;
    
    FHttpRequester.Put(FHttpParams.MakeUrl);

    FWaitAPIResponseTimer.Enabled := False;

    //Wait til data gets transferred completely
    while (FDataTransferStarted) do
      ;

    if FAPIWaitTimeoutOccurred then
    begin
      SetError(False, -1); // -1 timer error
      Exit;
    end;

    Result := True;

    // No validation of received data at the moment, can add it later

    // Call finish event if all good and data received is a perfect JSON
    if Assigned(FOwnerThread) then
      FOwnerThread.Synchronize(FOwnerThread, SynchronizeFinishEvent);
  except
    on E: EipsHTTPS do
    begin
      SetError(True, E.Code);
    end;
    on E: Exception do
    begin
      SetError(False, 0);
    end;
  end;
end;

procedure TBaseRESTClient.DoHttpEndTransfer(ASender: TObject;
  ADirection: Integer);
begin
  ProcessReceivedData();
end;

function TBaseRESTClient.DoHttpGet: Boolean;
var
  Response : TlkJSONbase;
  StopRepeating : Boolean;
  ResponseJSON : TlkJSONbase;

  procedure SetError(ACheckForAPIResponse : Boolean; Code : Integer);
  begin
    FAPIError.ErrorCode := Code;
    FAPIError.ErrorFromAPI := ''; // Error message from API
    FAPIError.ErrorDescription := ''; // General error message

    if ACheckForAPIResponse and (Code =  151) then // Special, 151 has API response
    begin
      //Get API response once again in case we missed the response
      FReceivedData := FHttpRequester.TransferredData;
      FAPIError.ErrorFromAPI := ProcessErrorMessageFromAPI(FReceivedData);
    end
    else
      FAPIError.ErrorDescription := ReturnGenericErrorMessage(Code);

    // Sets the error code and description to the error object
    FHTTPParams.Retries := FHTTPParams.Retries + 1;
    {By default StopRepeating is false and loop continues, when retries = count, StopRepeating is set to True so that
    loop stops and calls the error event}
    if not ((FHTTPParams.RetryCount > 0) and (FHTTPParams.Retries < FHTTPParams.RetryCount)) then
    begin
      StopRepeating := True;

      if Assigned(FOwnerThread) then
        FOwnerThread.Synchronize(FOwnerThread, SynchronizeErrorEvent);
    end;
  end;
begin
  Result := False;
  StopRepeating := False;

  FHttpRequester.HTTPMethod := 'GET';

  while not StopRepeating do
  begin
    try
      InitializeAPICall;

      FHttpRequester.Get(FHttpParams.MakeUrl);

      FWaitAPIResponseTimer.Enabled := False; // disable once you get the response back

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      if FAPIWaitTimeoutOccurred then
      begin
        SetError(False, -1); // -1 timer error
        Continue; // since StopRepeating set to true, loop exits with result = false
      end;

      StopRepeating := True;


      if FResponseDataType = rdtJSON then  // if it's json, validate basic JSON
      begin
        try
          ResponseJSON := TlkJSON.ParseText(FReceivedData);
        except
          SetError(False, -2); // -2 invalid data from API
          Continue;
        end;

        if not Assigned(ResponseJSON) then
        begin
          SetError(False, -2); // -2 invalid data from API
          Continue;
        end;
      end;

      Result := True;
      
      // Call finish event if all good and data received is a perfect JSON
      if Assigned(FOwnerThread) then
        FOwnerThread.Synchronize(FOwnerThread, SynchronizeFinishEvent);
    except
      on E: EipsHTTPS do
      begin
        FWaitAPIResponseTimer.Enabled := False; // disable once you get the response back
        SetError(True, E.Code);
      end;
      on E: Exception do
      begin
        FWaitAPIResponseTimer.Enabled := False; // disable once you get the response back
        SetError(False, 0);
      end;
    end;
  end;

end;

function TBaseRESTClient.DoHttpPost: Boolean;
var
  ResponseJSON : TlkJSONbase;
begin
  Result := False;
  FHttpRequester.HTTPMethod := 'POST';
  try
    InitializeAPICall;
    
    FHttpRequester.Post(FHttpParams.MakeUrl);

    FWaitAPIResponseTimer.Enabled := False;

    //Wait til data gets transferred completely
    while (FDataTransferStarted) do
      ;
      
    if FAPIWaitTimeoutOccurred then
    begin
      SetError(False, -1); // -1 timer error
      Exit;
    end;

    Result := True;
    // No validation after post, can be done in the calling place

    // Call finish event if all good and data received is a perfect JSON
    if Assigned(FOwnerThread) then
      FOwnerThread.Synchronize(FOwnerThread, SynchronizeFinishEvent);
  except
    on E: EipsHTTPS do
    begin
      SetError(True, E.Code);
    end;
    on E: Exception do
    begin
      SetError(False, 0);
    end;
  end;
end;

procedure TBaseRESTClient.DoHttpStartTransfer(ASender: TObject;
  ADirection: Integer);
begin
  FReceivedData := '';
  FDataTransferStarted := True;
  FAPIError.Clear;
end;

procedure TBaseRESTClient.DoHttpTransfer(ASender: TObject; ADirection,
  ABytesTransferred: Integer; AText: String);
begin
  FReceivedData := FReceivedData + AText;
end;

function TBaseRESTClient.GetSupportNumber: string;
begin
  FSupportNumber := '';
  try
    if Assigned(AdminSystem) then
      FSupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ]
    else if Assigned(MyClient) then
        FSupportNumber := TContactInformation.SupportPhoneNo[ MyClient.clFields.clCountry ];
  finally
    Result := FSupportNumber;
  end;
end;

procedure TBaseRESTClient.InitializeAPICall;
begin
  FAPIError.Clear;
  FReceivedData := '';
  FDataTransferStarted := True;
  FAPIWaitTimeoutOccurred := False;
  
  if FAPIResponseWaitInterval > 0 then
    FWaitAPIResponseTimer.Enabled := True;  
end;

procedure TBaseRESTClient.LogActivity(AMessageType: TMessageType;
  AMessage: string);
begin
  FLogMessageType := AMessageType;
  FLogMessage := AMessage;

  if Assigned(FOwnerThread) then
    FOwnerThread.Synchronize(FOwnerThread, SynchronizeLogActivity)
  else
    SynchronizeLogActivity;
end;

function TBaseRESTClient.ProcessErrorMessageFromAPI(
  aErrorMessage: string): string;
var
  sErrors : string;
  ErrorJSON : TlkJSONbase;
begin
  Result := '';

  try
    ErrorJSON := TlkJSON.ParseText(aErrorMessage);
  except
    FAPIError.ErrorCode := 0;
    FAPIError.ErrorDescription := 'Invalid data is received from API';
    Exit;
  end;

  if not Assigned(ErrorJSON) then
    Exit;

  if Assigned(ErrorJSON.Field['error']) then
    Result := '[' + VarToStr(ErrorJSON.Field['error'].Value) + ']';
  if Assigned(ErrorJSON.Field['error_description']) then
    Result := Result +  #13#10 + VarToStr(ErrorJSON.Field['error_description'].Value);
  if Assigned(ErrorJSON.Field['message']) then
    Result := Result +  VarToStr(ErrorJSON.Field['message'].Value) + ': ';

  if Assigned(ErrorJSON.Field['errors']) then
  begin
    sErrors := StringReplace(TlkJSON.GenerateText(ErrorJSON.Field['errors']), '{',' ', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '}','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '[','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, ']','', [rfReplaceAll, rfIgnoreCase]);
    sErrors := StringReplace(sErrors, '"','', [rfReplaceAll, rfIgnoreCase]);
    Result := Result + sErrors;
  end;
end;

procedure TBaseRESTClient.ProcessReceivedData(aTestData: string);
begin
  {$IFDEF BK_UNITTESTINGON}
    if Trim(aTestData) <> '' then
      FReceivedData := aTestData;
  {$ENDIF}

  FDataTransferStarted := False;
end;

function TBaseRESTClient.ReturnGenericErrorMessage(AErrorCode: integer): string;
begin
  case AErrorCode of
    -1 : Result := 'API wait timeout occurred';
    -2 : Result := 'Invalid data received from API';
    // HTTP Errors
    118, 143, 151..153, 155, 156, 301, 302, // and
    // IPPort Errors
    100..102, 104, 106, 107, 112, 116, 117, 135, 211..213,
    1105, 1117, 1119, 1120 :
    begin
      Result := Format( 'Could not connect to the service, ' +
                  'please try again later, if problem persists ' +
                  'contact support (%s)', [ SupportNumber ] );
    end;

    // SSL Errors
    270..276, 280..284, //and
    // Http Access Denied error
    10013 :
    begin
      Result := Format( 'Could not authenticate with the server, ' +
                  'please contact support (%s)', [ SupportNumber ] );
    end;

    // TCP/IP Errors
    10004, 10009, 10014, 10022, 10024, 10035..10071, 10091..10093, 11001..11004 :
    begin
      Result := Format( 'We had trouble connecting you, ' +
                  'please try again later, if problem persists ' +
                  'contact support (%s)', [ SupportNumber ] );
    end
    else
      Result := Format( 'An unexpected error occured, ErrorCode=%d, ' +
                  'please try again later, if problem persists ' +
                  'contact support (%s)', [ AErrorCode, SupportNumber ] );
  end;
end;

procedure TBaseRESTClient.SetAPIResponseWaitInterval(AValue: Integer);
begin  // Value in seconds
  FAPIResponseWaitInterval := AValue;
  FWaitAPIResponseTimer.Interval := FAPIResponseWaitInterval * 1000;
end;

procedure TBaseRESTClient.SetError(ACheckForAPIResponse: Boolean; // No repeat just sent error back
  Code: Integer);
begin
  FWaitAPIResponseTimer.Enabled := False;
  
  FAPIError.ErrorCode := Code;
  FAPIError.ErrorFromAPI := ''; // Error message from API
  FAPIError.ErrorDescription := ''; // General error message

  if ACheckForAPIResponse and (Code =  151) then // Special, 151 has API response
  begin
    //Get API response once again in case we missed the response
    FReceivedData := FHttpRequester.TransferredData;
    FAPIError.ErrorFromAPI := ProcessErrorMessageFromAPI(FReceivedData);
  end
  else
    FAPIError.ErrorDescription := ReturnGenericErrorMessage(Code);

  if Assigned(FOwnerThread) then
    FOwnerThread.Synchronize(FOwnerThread, SynchronizeErrorEvent);
end;

procedure TBaseRESTClient.SetHttpParameters(AHttpParams: THTTPParams);
begin
  FHttpParams := AHttpParams;

  FHttpRequester.Accept := FHTTPParams.RequestAccept;
  FHttpRequester.ContentType := FHTTPParams.RequestContentType;
  FHttpRequester.Authorization := FHTTPParams.Authorization;
  FHttpRequester.PostData := FHTTPParams.PostData;
  FHttpRequester.OtherHeaders := FHTTPParams.RequestHeader;
  FHttpRequester.User := FHttpParams.RequestUser;
  FHttpRequester.Password := FHttpParams.RequestPassword;

  APIResponseWaitInterval := FHttpParams.APIResponseWaitInterval;
  FResponseDataType := FHttpParams.ResponseDataType;
end;

procedure TBaseRESTClient.SynchronizeErrorEvent;
var
  ErrorStr : string;
begin
  ErrorStr := FAPIError.Serialize;
  if Assigned(FOnAPIError) and (Trim(ErrorStr) <> '') then
    FOnAPIError(ErrorStr);
end;

procedure TBaseRESTClient.SynchronizeFinishEvent;
begin
  if Assigned(FOnAPIFinished) then
    FOnAPIFinished(FReceivedData);
end;

procedure TBaseRESTClient.SynchronizeLogActivity;
begin
  if (FLogMessageType = lmDebug) then
  begin
    if DebugMe then
      LogUtil.LogMsg(FLogMessageType, UnitName, FLogMessage);
  end
  else
    LogUtil.LogMsg(FLogMessageType, UnitName, FLogMessage);
end;

procedure TBaseRESTClient.WaitAPITimerEvent(Sender: TObject);
begin
  FWaitAPIResponseTimer.Enabled := False;
  FAPIWaitTimeoutOccurred := True;
  
  FDataTransferStarted := False; // To stop data transfer
end;

{ TAPIError }

procedure TAPIError.Clear;
begin
  FErrorCode := 0;
  FErrorDescription := '';
end;

procedure TAPIError.Copy(AError: TAPIError);
begin
  if Assigned(AError) then
  begin
    FErrorCode := AError.ErrorCode;
    FErrorDescription := AError.ErrorDescription;
    FErrorFromAPI := AError.ErrorFromAPI;
  end;
end;

constructor TAPIError.Create;
begin
  FErrorCode := 0;
  FErrorDescription := '';
  FErrorFromAPI := '';
end;

procedure TAPIError.DeSerialize(AJson: string);
var
  JsonObject: TlkJSONbase;
  Feedback: TlkJSONbase;
begin
  JsonObject := TlkJSON.ParseText(AJson);

  if not Assigned(JsonObject) then
    Exit;

  try
    if Assigned( JsonObject.Field['Error_Code'] ) then
      FErrorCode := StrToIntDef(VarToStr( JsonObject.Field['Error_Code'].Value),0);
    if Assigned( JsonObject.Field['Error_From_API'] ) then
      FErrorFromAPI := VarToStr( JsonObject.Field['Error_From_API'].Value );
    if Assigned( JsonObject.Field['Error_Description'] ) then
      FErrorDescription := VarToStr( JsonObject.Field['Error_Description'].Value );
  finally
    JsonObject.Free;
  end;
end;

function TAPIError.Serialize: string;
var
  Error : TlkJSONobject;
begin
  Error := TlkJSONobject.Create();
  try
    Error.Add('Error_Code', FErrorCode);
    Error.Add('Error_From_API', FErrorFromAPI);
    Error.Add('Error_Description', FErrorDescription);

    Result := TlkJSON.GenerateText(Error);
  finally
    freeAndNil(Error);
  end;
end;

{ TUrlParams }

procedure TUrlParams.Add(Name, Value: String);
begin
  FParams.Add( Name + '=' + Value);
end;

procedure TUrlParams.CopyParams(AParams: TUrlParams);
var
  i : Integer;
begin
  if not Assigned(AParams) then
    Exit;

  FParams.Clear;
  for i := 0 to  AParams.GetCount-1 do
    FParams.Add(AParams.Param[i]);
end;

constructor TUrlParams.Create;
begin
  FParams := TStringList.Create;
end;

destructor TUrlParams.Destroy;
begin
  if Assigned(FParams) then
  begin
    FParams.Clear;
    FreeAndNil(FParams);
  end;
  inherited;
end;

function TUrlParams.FillParams(AUrl: String): String;
var
  Index: Integer;
begin
  for Index := 0 to FParams.Count - 1 do
  begin
    if Index = 0 then
      AUrl := AUrl + '?'
    else if Index > 0 then
      AUrl := AUrl + '&';

    AUrl := AUrl + FParams.Strings[Index];
  end;
  Result := AUrl;
end;

function TUrlParams.GetCount: Integer;
begin
  Result := 0;
  if Assigned(FParams) then  
    Result := FParams.Count;
end;

function TUrlParams.GetParam(i: Integer): string;
begin
  Result := '';
  if i < FParams.Count then
    Result := FParams.Strings[i];
end;

{ THTTPParams }

procedure THTTPParams.CopyParams(AParams: THttpParams);
begin
  if not Assigned(AParams) then
    Exit;

  Self.Authorization := AParams.Authorization;
  Self.RequestURL := AParams.RequestURL;
  Self.RequestContentType := AParams.RequestContentType;
  Self.RequestAccept := AParams.RequestAccept;
  Self.RequestHeader := AParams.RequestHeader;
  Self.RetryCount := AParams.RetryCount;
  Self.Retries := AParams.Retries;
  Self.PostData := AParams.PostData;
  Self.APIResponseWaitInterval := AParams.APIResponseWaitInterval;
  
  Self.RequestURLParams.CopyParams(AParams.RequestURLParams);
  Self.RequestTokens.CopyTokens(AParams.RequestTokens);
  Self.ResponseDataType :=  AParams.ResponseDataType;

  Self.RequestUser := AParams.RequestUser;
  Self.RequestPassword := AParams.RequestPassword;
end;

constructor THTTPParams.Create;
begin
  FRequestURLParams := TUrlParams.Create;
  FRequestTokens := TAPIAuthTokens.Create;

  FAuthorization := '';
  FRequestHeader := '';
  FRequestContentType := 'application/x-www-form-urlencoded';
  FRequestAccept := 'application/json';
  FRequestURL := '';
  FResponseDataType := rdtJSON;
  FRequestUser := '';
  FRequestPassword := '';
  
  FRetryCount := 0;
  FRetries := 0;
  FAPIResponseWaitInterval := 0;
end;

destructor THTTPParams.Destroy;
begin
  if Assigned(FRequestURLParams) then
    FreeAndNil(FRequestURLParams);
  if Assigned(FRequestTokens) then
    FreeAndNil(FRequestTokens);

  inherited;
end;

function THTTPParams.MakeUrl: String;
begin
  if GetStringLength(RequestURL) = 0 then
  begin
    Result := '';
    Exit;
  end;

  Result := RequestURL;
  if Assigned(RequestURLParams) then
    Result := RequestURLParams.FillParams(RequestURL);
end;

procedure THTTPParams.SetRequestAccept(const Value: string);
begin
  FRequestAccept := Value;
end;

procedure THTTPParams.SetRequestContentType(const Value: string);
begin
  FRequestContentType := Value;
end;

procedure THTTPParams.SetRequestHeader(const Value: string);
begin
  FRequestHeader := Value;
end;

{ THttpRequesterThread }

constructor THttpRequesterThread.Create(CreateSupended: Boolean;
  AHttpMethod: string;
  AHTTPParams: THTTPParams; AOnFinished: TOnAPIFinished; AOnError: TOnAPIError);
begin
  if ((not Assigned(AHTTPParams)) or (not Assigned(AOnFinished)) or (not Assigned(AOnError))) then
    Terminate;

  FHTTPParams := THTTPParams.Create;
  FBaseRESTClient := TBaseRESTClient.Create(Self);

  FHTTPParams.CopyParams(AHTTPParams);
  FHTTPMethod := AHttpMethod;

  FBaseRESTClient.SetHttpParameters(FHTTPParams);// Assign parameters to the ipworks object

  FBaseRESTClient.OnAPIFinished := AOnFinished;
  FBaseRESTClient.OnAPIError := AOnError;

  FreeOnTerminate := True;

  inherited Create(CreateSupended); // Calls Execute directly since CreateSuspended is False
end;

procedure THttpRequesterThread.Execute;
begin
  inherited;

  while (not Terminated) do
  begin
    if Assigned(FBaseRESTClient) then
    begin
      if FHTTPMethod = 'GET' then
        FBaseRESTClient.DoHttpGet
      else if FHTTPMethod = 'POST' then
        FBaseRESTClient.DoHttpPost
      else if FHTTPMethod = 'DELETE' then
        FBaseRESTClient.DoHttpDelete;

      FreeAndNil(FHTTPParams);
      FreeAndNil(FBaseRESTClient);
    end;

    Terminate;
  end;
  Self := Nil;
end;

initialization
   DebugMe := DebugUnit(UnitName);

end.
