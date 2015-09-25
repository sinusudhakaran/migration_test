unit uBaseRESTServer;

interface

uses
  Classes, SysUtils, uLKJSON, StrUtils, uHttplib, ipshttps;

type
  TAuthSchemes =
    (
       asBasic,
       asOAuth
    );

  TBaseRESTServer = class
  private
  protected
    fServerBaseUrl: string;
    fHeaders : tStringlist;
//    fTransferredJSON : TStringlist;
    fTransferredJSONData : string;
    FProcessingData : Boolean;

    constructor Create; virtual;
    destructor Destroy; override;
    function Base64Encode( aString : string ) : string;
    function Base64Decode( aString : string ) : string;

    procedure SetDataTransferEvents( Http: TipsHTTPS );
    {Start of the data transfer function, clear the storage list and make it
    ready for the data receives}
    procedure StartDataTransfer(Sender: TObject;Direction: Integer);
    {End of the data transfer function- This procedure process all data received}
    procedure EndDataTransfer(Sender: TObject;Direction: Integer);
    {This procedure stores each set of data receives}
    procedure TransferData(Sender: TObject;
                            Direction: Integer;
                            BytesTransferred: LongInt;
                            Text: String);


    function MakeAddress(BaseUrl, EndPoint: String): string;
    procedure AddAuthHeaders( AuthScheme: TAuthSchemes; Http: TipsHTTPS ); virtual;
    procedure AddHeaders( Http: TipsHTTPS ); virtual;

    procedure PostFormData(AuthScheme: TAuthSchemes; EndPoint: String; FormFields: TStrings; ResponseContent: TStream = nil);
    procedure Post(AuthScheme: TAuthSchemes; Endpoint: String; RequestObject: TJsonObject; ResponseObject: TJsonObject = nil);
    procedure Get(AuthScheme: TAuthSchemes; EndPoint: String; UrlParams: TUrlParams; ResponseContent: TJsonObject; RetryCount : integer; var Retries : integer);overload;
    function Get(AuthScheme: TAuthSchemes; EndPoint: String; UrlParams: TUrlParams): TlkJSONobject;overload;

    function GetHeader(aName : string) : string;
    procedure SetHeader(aName, aValue : string);
  public
    procedure ClearHeaders;
    property ServerBaseUrl: string read fServerBaseUrl;
    property ProcessingData : Boolean read FProcessingData write FProcessingData;
    property Header [Idx : string] : string read GetHeader write SetHeader;
  end;

implementation
uses
  idCoder,
  idCoderMIME;

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

{ TBaseRESTServer }

procedure TBaseRESTServer.AddAuthHeaders(AuthScheme: TAuthSchemes; Http: TipsHTTPS);
begin
  //
end;

procedure TBaseRESTServer.AddHeaders(Http: TipsHTTPS);
var
  li : integer;
begin
  inherited;
  Http.OtherHeaders := '';
  for li := 0 to fHeaders.Count - 1 do begin
    Http.OtherHeaders := format('%s: %s'#13#10,
      [ fHeaders.Names[ li ], fHeaders.Values[ fHeaders.Names[ li ] ] ] );
  end;
end;

function TBaseRESTServer.Base64Decode(aString: string): string;
begin
  result := '';
  result := IdCoder.DecodeString(TIdDecoderMIME, aString);
end;

function TBaseRESTServer.Base64Encode(aString: string): string;
begin
  result := '';
  result := IdCoder.EncodeString(TIdEncoderMIME, aString);
end;

procedure TBaseRESTServer.ClearHeaders;
begin
  if assigned( fHeaders ) then
    fHeaders.Clear;
end;

constructor TBaseRESTServer.Create;
begin
  inherited;

  fHeaders := tStringlist.Create;
  fHeaders.NameValueSeparator := ':';

  fTransferredJSONData := '';
//  fTransferredJSON := TStringlist.Create;
//  fTransferredJSON.Clear;
end;

destructor TBaseRESTServer.Destroy;
begin
//  freeAndNil( fTransferredJSON );
  freeAndNil( fHeaders );

  inherited;
end;


function TBaseRESTServer.Get(AuthScheme: TAuthSchemes; EndPoint: String; UrlParams: TUrlParams): TlkJSONobject;
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
      SetDataTransferEvents( HttpRequester );

      AddAuthHeaders( AuthScheme, HttpRequester );
      AddHeaders( HttpRequester );

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

function TBaseRESTServer.GetHeader(aName: string): string;
begin
  result := '';
  if assigned( fHeaders ) then
    result := fHeaders.Values[ aName ];
end;

procedure TBaseRESTServer.Get(AuthScheme: TAuthSchemes; EndPoint: String; UrlParams: TUrlParams;
  ResponseContent: TJsonObject; RetryCount : integer; var Retries : integer);
var
  HttpRequester: TipsHTTPS;
  aResponse: String;
begin
  HttpRequester := TipsHTTPS.Create(nil);

  try
    aResponse := '';

    try
      SetDataTransferEvents( HttpRequester );

      AddAuthHeaders( AuthScheme, HttpRequester );
      AddHeaders( HttpRequester );

      HttpRequester.Get(THttpLib.MakeUrl(fServerBaseUrl, EndPoint, UrlParams));
      if not ProcessingData then
        aResponse := fTransferredJSONData;
//       aResponse := HttpRequester.TransferredData;
      if assigned( ResponseContent ) then
        ResponseContent.Deserialize(aResponse);
    except
      on E: Exception do begin
        // Do Nothing, suppress the error
        aResponse := E.Message;
        inc( Retries );
        if Retries < RetryCount then
          Get( AuthScheme, EndPoint, UrlParams, ResponseContent, RetryCount, Retries );
      end;
    end;
  finally
    HttpRequester.Free;
  end;
end;


function TBaseRESTServer.MakeAddress(BaseUrl, EndPoint: String): String;
begin
  if (EndsStr('/', BaseUrl)) then
  begin
    BaseUrl := LeftStr(BaseUrl, Length(BaseUrl) -1);
  end;

  Result := BaseUrl + EndPoint;
end;

procedure TBaseRESTServer.Post(AuthScheme: TAuthSchemes; Endpoint: String; RequestObject,
  ResponseObject: TJsonObject);
var
  HttpRequester: TipsHTTPS;
  TempS,
  aResponse: String;
  i : integer;
begin
  HttpRequester := TipsHTTPS.Create(nil);

  try
    SetDataTransferEvents( HttpRequester );

    AddAuthHeaders( AuthScheme, HttpRequester );
    AddHeaders( HttpRequester );


    aResponse := '';

    try
      if assigned( RequestObject ) then
        HttpRequester.PostData := RequestObject.Serialize;

      HttpRequester.Post(THttpLib.MakeUrl(fServerBaseUrl, EndPoint));

      if not ProcessingData then
        aResponse := fTransferredJSONData;

      if ResponseObject <> nil then
      begin
        ResponseObject.Deserialize(aResponse);
      end;
    except
      on E: Exception do begin
//        raise; Swallow the exception
        aResponse := e.Message;
      end;
    end;

  finally
    HttpRequester.Free;
  end;
end;

procedure TBaseRESTServer.PostFormData(AuthScheme: TAuthSchemes; EndPoint: String; FormFields: TStrings;
  ResponseContent: TStream);
var
  HttpRequester: TipsHTTPS;
  aResponse : string;
  sFormData : string;
  Index: Integer;
begin
  HttpRequester := TipsHTTPS.Create(nil);
  try
    SetDataTransferEvents( HttpRequester );

    AddAuthHeaders( AuthScheme, HttpRequester );
    AddHeaders( HttpRequester );

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
//        aResponse := HttpRequester.TransferredData;
      if not ProcessingData then
        aResponse := fTransferredJSONData;

    except
      on E: Exception do begin
//        raise; Swallow the exception
      end;
    end;
  finally
    HttpRequester.Free;
  end;
end;

procedure TBaseRESTServer.SetDataTransferEvents(Http: TipsHTTPS);
begin
  HTTP.OnStartTransfer := StartDataTransfer;
  HTTP.OnEndTransfer := EndDataTransfer;
  HTTP.OnTransfer := TransferData;
end;

procedure TBaseRESTServer.SetHeader(aName, aValue: string);
begin
  if assigned( fHeaders ) then
    fHeaders.Values[ aName ] := aValue;
end;

procedure TBaseRESTServer.EndDataTransfer(Sender: TObject; Direction: Integer);
begin
  fProcessingData := false;
end;

procedure TBaseRESTServer.StartDataTransfer(Sender: TObject; Direction: Integer);
begin
//  fTransferredJSON.Clear;
  fProcessingData := True;
  fTransferredJSONData := '';
end;

procedure TBaseRESTServer.TransferData(Sender: TObject; Direction,
  BytesTransferred: Integer; Text: String);
begin
  fTransferredJSONData := fTransferredJSONData + Text;
end;

end.
