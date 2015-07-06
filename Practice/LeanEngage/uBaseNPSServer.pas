unit uBaseNPSServer;

interface

uses
  Classes, SysUtils, uLKJSON, StrUtils, uHttplib, ipshttps;

type
  TBaseNPSServer = class
  private
  protected
    fServerBaseUrl: string;
    procedure AddHeaders(Http: TipsHTTPS; EndPoint: String);virtual;
    function MakeAddress(BaseUrl, EndPoint: String): string;

    procedure AddCustomHeader(Http: TipsHTTPS; HeaderName, HeaderValue: String);
    procedure PostFormData(EndPoint: String; FormFields: TStrings; ResponseContent: TStream = nil);
    procedure Post(Endpoint: String; RequestObject: TJsonObject; ResponseObject: TJsonObject = nil);
    procedure Get(EndPoint: String; UrlParams: TUrlParams; ResponseContent: TJsonObject);overload;
    function Get(EndPoint: String; UrlParams: TUrlParams): TlkJSONobject;overload;
  public
    property ServerBaseUrl: string read fServerBaseUrl;
  end;

implementation

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

{ TBaseExoServer }

procedure TBaseNPSServer.AddCustomHeader(Http: TipsHTTPS; HeaderName,
  HeaderValue: String);
begin
end;

procedure TBaseNPSServer.AddHeaders(Http: TipsHTTPS; EndPoint: String);
begin

end;


function TBaseNPSServer.Get(EndPoint: String; UrlParams: TUrlParams): TlkJSONobject;
var
  HttpRequester: TipsHTTPS;
  aResponse: String;
  JSONObj: TlkJSONbase;
begin
  Result := nil;
  HttpRequester := TipsHTTPS.Create(nil);
  try
    aResponse := '';
    try
      AddHeaders(HttpRequester, EndPoint);

      HttpRequester.ContentType := 'application/x-www-form-urlencoded';
      HttpRequester.Accept := 'application/json';

      HttpRequester.Get(THttpLib.MakeUrl(fServerBaseUrl, EndPoint, UrlParams));
      aResponse := HttpRequester.TransferredData;

      JsonObj := TlkJSON.ParseText(aResponse);
      if JSONObj is TlkJSONobject then
        Result := TlkJSONobject(JSONObj)
      else
        JSONObj.Free;
    finally
    end;
  finally
    HttpRequester.Free;
  end;
end;

procedure TBaseNPSServer.Get(EndPoint: String; UrlParams: TUrlParams;
  ResponseContent: TJsonObject);
var
  HttpRequester: TipsHTTPS;
  aResponse: String;
begin
  HttpRequester := TipsHTTPS.Create(nil);

  try
    aResponse := '';

    try
      AddHeaders(HttpRequester, EndPoint);

      HttpRequester.ContentType := 'application/x-www-form-urlencoded';
      HttpRequester.Accept := 'application/json';

      HttpRequester.Get(THttpLib.MakeUrl(fServerBaseUrl, EndPoint, UrlParams));
      aResponse := HttpRequester.TransferredData;
      ResponseContent.Deserialize(aResponse);
    finally
    end;
  finally
    HttpRequester.Free;
  end;
end;


function TBaseNPSServer.MakeAddress(BaseUrl, EndPoint: String): String;
begin
  if (EndsStr('/', BaseUrl)) then
  begin
    BaseUrl := LeftStr(BaseUrl, Length(BaseUrl) -1);
  end;

  Result := BaseUrl + EndPoint;
end;

procedure TBaseNPSServer.Post(Endpoint: String; RequestObject,
  ResponseObject: TJsonObject);
var
  HttpRequester: TipsHTTPS;
  aResponse: String;
begin
  HttpRequester := TipsHTTPS.Create(nil);

  try
    AddHeaders(HttpRequester, EndPoint);

    HttpRequester.ContentType := 'application/json';
    HttpRequester.Accept := 'text/plain';

    aResponse := '';

    try
      HttpRequester.PostData := RequestObject.Serialize;

      HttpRequester.Post(THttpLib.MakeUrl(fServerBaseUrl, EndPoint));
      aResponse := HttpRequester.TransferredData;

      if ResponseObject <> nil then
      begin
        ResponseObject.Deserialize(aResponse);
      end;
    except
      on E: Exception do begin
        raise;
      end;
    end;

  finally
    HttpRequester.Free;
  end;
end;

procedure TBaseNPSServer.PostFormData(EndPoint: String; FormFields: TStrings;
  ResponseContent: TStream);
var
  HttpRequester: TipsHTTPS;
  aResponse : string;
  sFormData : string;
  Index: Integer;
begin
  HttpRequester := TipsHTTPS.Create(nil);

  try
    AddHeaders(HttpRequester, EndPoint);

    HttpRequester.ContentType := 'application/x-www-form-urlencoded';

    sFormData := '';
    try
      for Index := 0 to FormFields.Count - 1 do
      begin
        if Index + 1 < FormFields.Count then
        begin
          sFormData := URLEncode(FormFields[Index] + '&')
        end
        else
        begin
          sFormData := URLEncode(FormFields[Index]);
        end;
      end;

      HttpRequester.PostData := sFormData;
        HttpRequester.Post(MakeAddress(fServerBaseUrl, EndPoint));
        aResponse := HttpRequester.TransferredData;
    except
      on E: Exception do begin
        raise;
      end;
    end;
  finally
    HttpRequester.Free;
  end;
end;

end.
