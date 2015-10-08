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
    fRaiseExceptions : boolean;

    constructor Create( aRaiseExceptions : boolean = false ); virtual;
    destructor Destroy; override;
    function Base64Encode( aString : string ) : string;
    function Base64Decode( aString : string ) : string;

    procedure SetDataTransferEvents( aHttp: TipsHTTPS );
    {Start of the data transfer function, clear the storage list and make it
    ready for the data receives}
    procedure StartDataTransfer(aSender: TObject; aDirection: Integer);
    {End of the data transfer function- This procedure process all data received}
    procedure EndDataTransfer(aSender: TObject; aDirection: Integer);
    {This procedure stores each set of data receives}
    procedure TransferData(aSender: TObject;
                            aDirection: Integer;
                            aBytesTransferred: LongInt;
                            aText: String);


    function MakeAddress(aBaseUrl, aEndPoint: String): string;
    procedure AddAuthHeaders( aAuthScheme: TAuthSchemes; aHttp: TipsHTTPS ); virtual;
    procedure AddHeaders( aHttp: TipsHTTPS ); virtual;

    function PostFormData(aAuthScheme: TAuthSchemes; aEndPoint: String;
               aFormFields: TStrings; var aResponseString : string;
               var aExceptString : string ) : boolean;
    function Post(aAuthScheme: TAuthSchemes; aEndpoint: String;
               aRequestObject: TJsonObject; var aExceptString : string;
               aResponseObject: TJsonObject = nil ) : boolean;
    function Get( aAuthScheme: TAuthSchemes; aEndPoint: String;
               aUrlParams: TUrlParams; aResponseObject: TJsonObject;
               var aRetriesLeft : integer; var aExceptString : string ) : boolean; overload;
    function Get( aAuthScheme: TAuthSchemes; aEndPoint: String;
               aUrlParams: TUrlParams; aResponseObject: TlkJSONobject;
               var aExceptString : string ) : boolean; overload;

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

function URLEncode(const aSrc: String): String;
var
  li: Integer;
const
  UnsafeChars = ['*', '#', '%', '<', '>', ' ','[',']'];  {do not localize}
begin
  Result := '';    {Do not Localize}
  for li := 1 to Length(aSrc) do
  begin
    if (aSrc[li] in UnsafeChars) or (not (ord(aSrc[li])in [33..128])) then
    begin {do not localize}
      Result := Result + '%' + IntToHex(Ord(aSrc[li]), 2);  {do not localize}
    end
    else
    begin
      Result := Result + aSrc[li];
    end;
  end;
end;

{ TBaseRESTServer }

procedure TBaseRESTServer.AddAuthHeaders(aAuthScheme: TAuthSchemes; aHttp: TipsHTTPS);
begin
  //
end;

procedure TBaseRESTServer.AddHeaders(aHttp: TipsHTTPS);
var
  li : integer;
begin
  inherited;
  aHttp.OtherHeaders := '';
  for li := 0 to fHeaders.Count - 1 do begin
    aHttp.OtherHeaders := format('%s: %s'#13#10,
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

constructor TBaseRESTServer.Create( aRaiseExceptions : boolean = false );
begin
  inherited Create;

  fHeaders := tStringlist.Create;
  fHeaders.NameValueSeparator := ':';

  fTransferredJSONData := '';

  fRaiseExceptions := aRaiseExceptions;

//  fTransferredJSON := TStringlist.Create;
//  fTransferredJSON.Clear;
end;

destructor TBaseRESTServer.Destroy;
begin
//  freeAndNil( fTransferredJSON );
  freeAndNil( fHeaders );

  inherited;
end;


function TBaseRESTServer.Get(aAuthScheme: TAuthSchemes; aEndPoint: String;
           aUrlParams: TUrlParams; aResponseObject: TlkJSONobject;
           var aExceptString : string) : boolean;
var
  loHttpRequester: TipsHTTPS;
  lsResponse: String;
  loJSON: TlkJSONbase;
begin
  Result := false;
  aResponseObject := nil;
  loHttpRequester := TipsHTTPS.Create(nil);
  try
    lsResponse := '';
    try
      SetDataTransferEvents( loHttpRequester );

      AddAuthHeaders( aAuthScheme, loHttpRequester );
      AddHeaders( loHttpRequester );

      loHttpRequester.Get(THttpLib.MakeUrl(fServerBaseUrl, aEndPoint, aUrlParams));
      lsResponse := loHttpRequester.TransferredData;

      loJSON := TlkJSON.ParseText(lsResponse);
      if loJSON is TlkJSONobject then
        aResponseObject := TlkJSONobject(loJSON)
      else
        loJSON.Free;
      Result := true;   
    except
      on E: Exception do begin
      // Swallow the exception

        aExceptString := e.Message; // Send back exception message
        Result := false;
        if fRaiseExceptions then
          raise; // Raise if becessary
      end;
    end;
  finally
    loHttpRequester.Free;
  end;
end;

function TBaseRESTServer.GetHeader(aName: string): string;
begin
  result := '';
  if assigned( fHeaders ) then
    result := fHeaders.Values[ aName ];
end;

function TBaseRESTServer.Get(aAuthScheme: TAuthSchemes; aEndPoint: String;
            aUrlParams: TUrlParams; aResponseObject: TJsonObject;
            var aRetriesLeft : integer; var aExceptString : string ) : boolean;
var
  loHttpRequester: TipsHTTPS;
  lsResponse: String;
begin
  result := false;
  loHttpRequester := TipsHTTPS.Create(nil);

  try
    lsResponse := '';

    try
      SetDataTransferEvents( loHttpRequester );

      AddAuthHeaders( aAuthScheme, loHttpRequester );
      AddHeaders( loHttpRequester );

      loHttpRequester.Get(THttpLib.MakeUrl(fServerBaseUrl, aEndPoint, aUrlParams));
      if not ProcessingData then
        lsResponse := fTransferredJSONData;

      if assigned( aResponseObject ) then
        aResponseObject.Deserialize(lsResponse);
      result := true;  
    except
      on E: Exception do begin
        // Do Nothing, suppress the exception
        result := false;
        aExceptString := E.Message; // Send back the Exception message
        if not fRaiseExceptions then begin // If not allow exceptions then retry "Retries" times
          dec( aRetriesLeft );
          if aRetriesLeft > 0 then
            result := Get( aAuthScheme, aEndPoint, aUrlParams, aResponseObject, aRetriesLeft, aExceptString );
        end
        else
          raise; // Else raise exception if necessary   
      end;
    end;
  finally
    loHttpRequester.Free;
  end;
end;


function TBaseRESTServer.MakeAddress(aBaseUrl, aEndPoint: String): String;
begin
  if (EndsStr('/', aBaseUrl)) then
  begin
    aBaseUrl := LeftStr(aBaseUrl, Length(aBaseUrl) -1);
  end;

  Result := aBaseUrl + aEndPoint;
end;

function TBaseRESTServer.Post(aAuthScheme: TAuthSchemes; aEndpoint: String;
           aRequestObject: TJsonObject; var aExceptString : string;
           aResponseObject: TJsonObject = nil ) : boolean;
var
  loHttpRequester: TipsHTTPS;
  lsResponse: String;
begin
  result := false;
  loHttpRequester := TipsHTTPS.Create(nil);

  try
    SetDataTransferEvents( loHttpRequester );

    AddAuthHeaders( aAuthScheme, loHttpRequester );
    AddHeaders( loHttpRequester );


    lsResponse := '';

    try
      if assigned( aRequestObject ) then
        loHttpRequester.PostData := aRequestObject.Serialize;

      loHttpRequester.Post(THttpLib.MakeUrl(fServerBaseUrl, aEndpoint));

      if not ProcessingData then
        lsResponse := fTransferredJSONData;

      if aResponseObject <> nil then
      begin
        aResponseObject.Deserialize(lsResponse);
      end;
      result := true;
    except
      on E: Exception do begin
      // Swallow the exception

        result := false;
        aExceptString := e.Message;
        if fRaiseExceptions then
          raise; // Raise if becessary
      end;
    end;

  finally
    loHttpRequester.Free;
  end;
end;

function TBaseRESTServer.PostFormData(aAuthScheme: TAuthSchemes; aEndPoint: String;
           aFormFields: TStrings; var aResponseString : string;
           var aExceptString : string ) : boolean;
var
  loHttpRequester: TipsHTTPS;
  lsFormData : string;
  li: Integer;
begin
  result := false;
  
  loHttpRequester := TipsHTTPS.Create(nil);
  try
    SetDataTransferEvents( loHttpRequester );

    AddAuthHeaders( aAuthScheme, loHttpRequester );
    AddHeaders( loHttpRequester );

    lsFormData := '';
    try
      for li := 0 to aFormFields.Count - 1 do
      begin
        if li + 1 < aFormFields.Count then
        begin
          lsFormData := URLEncode(aFormFields[li] + '&')
        end
        else
        begin
          lsFormData := URLEncode(aFormFields[li]);
        end;
      end;

      loHttpRequester.PostData := lsFormData;

      loHttpRequester.Post(MakeAddress(fServerBaseUrl, aEndPoint));

      if not ProcessingData then
        aResponseString := fTransferredJSONData;

      result := true;
    except
      on E: Exception do begin
//      Swallow the exception
        result := false;
        aExceptString := E.Message;

        if fRaiseExceptions then
          raise;
      end;
    end;
  finally
    loHttpRequester.Free;
  end;
end;

procedure TBaseRESTServer.SetDataTransferEvents(aHttp: TipsHTTPS);
begin
  aHttp.OnStartTransfer := StartDataTransfer;
  aHttp.OnEndTransfer := EndDataTransfer;
  aHttp.OnTransfer := TransferData;
end;

procedure TBaseRESTServer.SetHeader(aName, aValue: string);
begin
  if assigned( fHeaders ) then
    fHeaders.Values[ aName ] := aValue;
end;

procedure TBaseRESTServer.EndDataTransfer(aSender: TObject; aDirection: Integer);
begin
  fProcessingData := false;
end;

procedure TBaseRESTServer.StartDataTransfer(aSender: TObject; aDirection: Integer);
begin
//  fTransferredJSON.Clear;
  fProcessingData := True;
  fTransferredJSONData := '';
end;

procedure TBaseRESTServer.TransferData(aSender: TObject; aDirection,
  aBytesTransferred: Integer; aText: String);
begin
  fTransferredJSONData := fTransferredJSONData + aText;
end;

end.
