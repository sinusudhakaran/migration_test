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
  ENDPOINT_CONVERSATION_RESPONSE = '/api/v1/conversations/';

type
  TNPSServer = class(TBaseNPSServer)
  private
    fAuthenticationKey: String;
//    fServerBaseUrl: string;
//DN - Probably Redundant code      FCompanyName: String;
//DN - Probably Redundant code      FDbVersion: String;
//DN - Probably Redundant code      FStaffName: String;
//DN - Probably Redundant code      FSqlVersion: String;
  protected
    procedure AddHeaders(Http: TipsHTTPS; EndPoint: String);override;
    procedure AddAuthenticationHeader(Http: TipsHTTPS; EndPoint: String);
    function Base64Encode( aString : string ) : string;
    function Base64Decode( aString : string ) : string;
  public
    constructor Create(AuthenticationKey, ServerBaseUrl
      (*//DN - Probably Redundant code  , CompanyName*): String); virtual;

    procedure SetNPSIdentity(Identity: TJsonObject);
    procedure GetNPSSurvey(UserId: String; Survey: TJsonObject);
    procedure setEventTrack( UserId: string; MessageContent : TJsonObject);
    procedure setFeedBackResponse(UserId : string; MessageContent : TJsonObject);

    property AuthenticationKey : string read fAuthenticationKey;
//DN - Probably Redundant code      property DbVersion: String read FDbVersion write FDbVersion;
//DN - Probably Redundant code      property SqlVersion: String read FSqlVersion write FSqlVersion;
//DN - Probably Redundant code      property StaffName: String read FStaffName write FStaffName;
  end;

implementation

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

constructor TNPSServer.Create(AuthenticationKey, ServerBaseUrl
              (*DN - Probably Redundant code  , CompanyName *): String);
begin
  fAuthenticationKey := AuthenticationKey;
  fServerBaseUrl := ServerBaseUrl;
//DN - Probably Redundant code    FCompanyName := CompanyName;
end;

procedure TNPSServer.GetNPSSurvey(UserId: String; Survey: TJsonObject);
var
  JsonObject: TDynamicJsonObject;
begin
  JsonObject := TDynamicJsonObject.Create;

  try
    JsonObject.Add('user_id', UserId);

    Post(ENDPOINT_NPS_GETSURVEY, JsonObject, Survey);
  finally
    JsonObject.Free;
  end;
end;

procedure TNPSServer.setEventTrack(UserId: string; MessageContent: TJsonObject);
begin
  Post(ENDPOINT_EVENT_TRACK, MessageContent);
end;

procedure TNPSServer.setFeedBackResponse(UserId: string;
  MessageContent: TJsonObject);
begin
//  Post(ENDPOINT_FEEDBACK_RESPONSE, MessageContent);
/////////;//  Get( ENDPOINT_CONVERSATION_RESPONSE, 
end;

procedure TNPSServer.SetNPSIdentity(Identity: TJsonObject);
begin
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

end.
