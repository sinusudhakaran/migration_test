unit uNPSServer;

interface

uses
  Classes, SysUtils, uLKJSON, IdCoder, IdCoderMIME, StrUtils, uHttplib,
  uBaseNPSServer, ipshttps;

const
  ENDPOINT_NPS_IDENTIFY = '/api/v1/identify';
  ENDPOINT_NPS_GETSURVEY = '/api/v1/feedback/check';
  ENDPOINT_EVENT_TRACK = '/api/v1/track';
  ENDPOINT_FEEDBACK_RESPONSE = '/api/v1/messages';
  ENDPOINT_CONVERSATION_RESPONSE = '/api/v1/conversations/info?user_id={user_id}';

type
  TNPSServer = class(TBaseNPSServer)
  private
    fAuthenticationKey: String;

    fFeedbackURL: string;
    fHasFeedbackURL : boolean;
  protected
    procedure AddHeaders(Http: TipsHTTPS; EndPoint: String);override;
    procedure AddAuthenticationHeader(Http: TipsHTTPS; EndPoint: String);
    function Base64Encode( aString : string ) : string;
    function Base64Decode( aString : string ) : string;
  public
    constructor Create(AuthenticationKey, ServerBaseUrl: String); virtual;

    procedure SetNPSIdentity(Identity: TJsonObject);
    procedure GetNPSSurvey(UserId: String; Survey: TJsonObject);
    procedure setEventTrack( UserId: string; MessageContent : TJsonObject);
    procedure setFeedBackResponse(UserId : string; MessageContent : TJsonObject; Feedback : TJsonObject);

    property AuthenticationKey : string read fAuthenticationKey;
  end;

implementation
uses
  LogUtil;                                     
  
const
  unitname = 'uNPSServer';
  DebugAutoSave: Boolean = False;
  AutoSaveUnit = 'AutoSave';

var
  DebugMe : boolean = false;

type
  TJSONStringList = class(TlkJSONobject)
  public
    procedure Assign(List: TStrings);
  end;

{ TNPSServer }

procedure TNPSServer.AddAuthenticationHeader(Http: TipsHTTPS; EndPoint: String);
begin
  Http.AuthScheme := authBasic;
  Http.User       := fAuthenticationKey;
  Http.Password   := '';

  http.Authorization := 'Basic ' + Base64Encode(fAuthenticationKey + ':');
end;

procedure TNPSServer.AddHeaders(Http: TipsHTTPS; EndPoint: String);
begin
  AddAuthenticationHeader(Http, EndPoint);
end;

function TNPSServer.Base64Decode(aString: string): string;
begin
  result := '';
  result := IdCoder.DecodeString(TIdDecoderMIME, aString);
end;

function TNPSServer.Base64Encode(aString: string): string;
begin
  result := IdCoder.EncodeString(TIdEncoderMIME, aString);
end;

constructor TNPSServer.Create(AuthenticationKey, ServerBaseUrl: String);
begin
  fAuthenticationKey := AuthenticationKey;
  fServerBaseUrl := ServerBaseUrl;
  fHasFeedbackURL := false;

end;

procedure TNPSServer.GetNPSSurvey(UserId: String; Survey: TJsonObject);
var
  JsonObject: TDynamicJsonObject;
begin
  JsonObject := TDynamicJsonObject.Create;

  try
    JsonObject.Add('user_id', UserId);
    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,
        format( 'Before Http Post in TNPSServer.GetNPSSurvey(UserId= %s; Survey=%s) )',
        [ UserId, Survey.Serialize ] ) );

    Post(ENDPOINT_NPS_GETSURVEY, JsonObject, Survey);
    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,
        format( 'After Http Post in TNPSServer.GetNPSSurvey(UserId= %s; Survey=%s) )',
        [ UserId, Survey.Serialize ] ) );
  finally
    JsonObject.Free;
  end;
end;

procedure TNPSServer.setEventTrack(UserId: string; MessageContent: TJsonObject);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug,unitname,
      format( 'TNPSServer.setEventTrack(UserId= $s; MessageContent: TJsonObject = %s)',
      [ UserID, MessageContent.Serialize ] ) );

  Post(ENDPOINT_EVENT_TRACK, MessageContent);
end;

procedure TNPSServer.setFeedBackResponse(UserId: string;
  MessageContent: TJsonObject; Feedback : TJsonObject);
var
  URLParams : TURLParams;

begin
  URLParams := TURLParams.Create;
  try
    URLParams.Add('user_id', UserID);

    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,
        format( 'Before Http Get in TNPSServer.setFeedBackResponse(UserId= $s )',
        [ UserID ] ) );
    Get( ENDPOINT_CONVERSATION_RESPONSE, URLParams, FeedBack );
    if DebugMe then
      LogUtil.LogMsg(lmDebug,unitname,
        format( 'Before Http Get in TNPSServer.setFeedBackResponse(UserId= $s; Feedback: TJsonObject = %s)',
        [ UserID, Feedback.Serialize ] ) );

  finally
    freeAndNil( URLParams );
  end;
end;

procedure TNPSServer.SetNPSIdentity(Identity: TJsonObject);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug,unitname,
      format( 'Before Http Post in TNPSServer.SetNPSIdentity(Identity: TJsonObject = %s)',
      [ Identity.Serialize ] ) );
  Post(ENDPOINT_NPS_IDENTIFY, Identity);
end;

{ TJSONStrings }

procedure TJSONStringList.Assign(List: TStrings);
var
  Index: Integer;
begin
  for Index := 0 to List.Count - 1 do
  begin
    Self.Add(List.Names[Index], List.ValueFromIndex[Index]);
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
   DebugAutoSave := DebugUnit(AutoSaveUnit);
end.
