unit PracticeTCPClient;

interface

uses
  Classes,
  Windows,
  IdUDPServer,
  IdBaseComponent,
  IdComponent,
  IdUDPBase,
  IdUDPClient,
  IdSocketHandle,
  IdTCPConnection,
  IdTCPClient,
  IdIOHandler,
  IdIOHandlerStream,
  PracticeClientServer;

type
  TICLMessageEvent = procedure(aMethod : String; aMesssage : String) of object;

  TPracticeTCPClient = class
  private
    FICLMessageEvent : TICLMessageEvent;
    FUDPClient : TIdUDPClient;
    FTCPClient : TIdTCPClient;

    FAppVersion : string;
    FUDPPort : integer;
    FUDPBufferInitSize : integer;

    FDiscoveryTimeOut : dword;
    FUDPTimeOut : integer;
    FTCPTimeOut : integer;
    FProcessMessageDelay : dword;

    FDebugMe : boolean;
    FOnDisconnected: TNotifyEvent;
    
    FTCPReadTimeOut: DWord;
    FOnWaitingResponse: TNotifyEvent;

    function GetStartTime: DWord;
    function TimedOut(StartTime: DWord): Boolean;

    procedure ParseDelimited(const aStrLst : TStrings; const aSearchStr : string; const aDelimiter : string);

    procedure OnTCPDisconnected(Sender: TObject);
    procedure SetTCPReadTimeOut(const Value: DWord);
    function GetHost: String;
    function GetPort: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function DiscoverHost(out Host: String; out Port: Integer): Boolean;

    function Connect: Boolean; overload;
    function Connect(Host: String; Port: Integer): boolean; overload;

    function Reconnect: Boolean;

    function Connected : Boolean;
    procedure Disconnect;

    function SendRequest(RequestId: DWord; Request: TRequest): Boolean; overload;
    function SendRequest(RequestId: DWord; RequestType: TRequestType): Boolean; overload;
    
    function ReceiveResponse(out RequestId:  DWord; out Response: TResponse): Boolean;
    function ReceiveStream(Stream: TStream; Size: Integer): Boolean;

    property AppVersion : string read fAppVersion write fAppVersion;

    property UDPPort : integer read fUDPPort write fUDPPort;
    property UDPBufferInitSize : integer read fUDPBufferInitSize write fUDPBufferInitSize;

    property DiscoveryTimeOut : dword read fDiscoveryTimeOut write fDiscoveryTimeOut;

    property UDPTimeOut : integer read fUDPTimeOut write fUDPTimeOut;
    property TCPTimeOut : integer read fTCPTimeOut write fTCPTimeOut;

    property TCPReadTimeOut: DWord read FTCPReadTimeOut write SetTCPReadTimeOut;

    property ProcessMessageDelay : dword read fProcessMessageDelay write fProcessMessageDelay;

    property ICLMessageEvent : TICLMessageEvent read fICLMessageEvent write fICLMessageEvent;

    property DebugMe : boolean read fDebugMe write fDebugMe;

    property Port: Integer read GetPort;
    property Host: String read GetHost;

    property OnDisconnected: TNotifyEvent read FOnDisconnected write FOnDisconnected;
    property OnWaitingResponse: TNotifyEvent read FOnWaitingResponse write FOnWaitingResponse;
  end;

implementation

uses
  SysUtils,
  idGlobal,
  Forms,
  IdExceptionCore,
  IdException;

const
  UnitName = 'IPCLIENTLOCKING';
  UDP_READ_SERVERNAME    = 0;
  UDP_READ_SERVERPORT    = 1;
  UDP_READ_SERVERVERSION = 2;
  UDP_READ_PACKET_COUNT  = 3;
  MAX_LOCK_TOKEN         = 10000;

{ TPracticeTCPClient }
//------------------------------------------------------------------------------
procedure TPracticeTCPClient.ParseDelimited(const aStrLst : TStrings; const aSearchStr : string; const aDelimiter : string);
var
  DelPos : integer;
  CurTxt : string;
  SearchText : string;
  DelLen : integer;
begin
  DelLen := Length(aDelimiter) ;

  SearchText := aSearchStr + aDelimiter;

  aStrLst.BeginUpdate;

  aStrLst.Clear;
  try
    while Length(SearchText) > 0 do
    begin
      DelPos := Pos(aDelimiter, SearchText) ;

      CurTxt := Copy(SearchText, 0, DelPos-1) ;

      aStrLst.Add(CurTxt) ;

      SearchText := Copy(SearchText, DelPos+DelLen, MaxInt) ;
    end;
  finally
    aStrLst.EndUpdate;
  end;
end;

function TPracticeTCPClient.ReceiveResponse(out RequestId: DWord; out Response: TResponse): Boolean;
var
  Buffer: TBytes;
  BufferSize: Integer;
  Header: TResponseHeader;
  StartTime: DWord;
begin
  Result := False;

  RequestId := 0;

  StartTime := GetStartTime;

  repeat
    FTCPClient.IOHandler.CheckForDataOnSource(160);

    if not FTCPClient.IOHandler.InputBufferIsEmpty then
    begin
      BufferSize := Sizeof(Header);

      FTCPClient.IOHandler.ReadBytes(Buffer, BufferSize);

      BytesToRaw(Buffer, Header, BufferSize);

      if ValidateResponse(Header) then
      begin
        RequestId := Header.RequestId;
        
        Response := Header.Response;
    
        Result := True;
      end;
    end
    else
    begin
      if Assigned(FOnWaitingResponse) then
      begin
        FOnWaitingResponse(Self);
      end;
    end;
  until Result or TimedOut(StartTime);
end;

function TPracticeTCPClient.ReceiveStream(Stream: TStream; Size: Integer): Boolean;
var
  StartTime: DWord;
begin
  Result := False;

  StartTime := GetStartTime;

  repeat
    FTCPClient.IOHandler.CheckForDataOnSource(160);

    if not FTCPClient.IOHandler.InputBufferIsEmpty then
    begin
      FTCPClient.IOHandler.ReadStream(Stream, Size);

      Result := True;
    end
    else
    begin
      if Assigned(FOnWaitingResponse) then
      begin
        FOnWaitingResponse(Self);
      end;
    end;
  until Result or TimedOut(StartTime);
end;

function TPracticeTCPClient.Reconnect: Boolean;
begin
  if not FTCPClient.Connected then
  begin
    FTCPClient.Connect;

    if FTCPClient.Connected then
    begin
      FTCPClient.IOHandler.ReadTimeout := FTCPTimeOut;

      Result := True;
    end
    else
    begin
      Result := False;
    end;
  end
  else
  begin
    Result := True;
  end;
end;

function TPracticeTCPClient.SendRequest(RequestId: DWord; RequestType: TRequestType): Boolean;
var
  Request: TRequest;
begin
  Request.RequestType := RequestType;

  Result := SendRequest(RequestId, Request);
end;

procedure TPracticeTCPClient.SetTCPReadTimeOut(const Value: DWord);
begin
  FTCPReadTimeOut := Value;
end;

function TPracticeTCPClient.TimedOut(StartTime: DWord): Boolean;
begin
  Result := GetTickCount - StartTime > FTCPReadTimeOut;
end;

function TPracticeTCPClient.SendRequest(RequestId: DWord; Request: TRequest): Boolean;
var
  Header: TRequestHeader;
begin
  Header := PackageRequest(RequestId, Request);
  
  FTCPClient.IOHandler.Write(RawToBytes(Header, Sizeof(TRequestHeader)));

  Result := True;
end;

//------------------------------------------------------------------------------
function TPracticeTCPClient.DiscoverHost(out Host: String; out Port: Integer): boolean;
var
  BroadCastStr : string;
  Buffer : TIdBytes;
  PeerIP : String;
  PeerPort : integer;
  Res : Integer;
  CurrentTick : Dword;
  ProcessTick : Dword;
  BufferList : TStringList;
  RecievedStr : string;
  Msg : string;
begin
  Result := false;

  BufferList := TStringList.Create;
  
  try
    // Send UDP Broad Cast
    BroadCastStr := DISCOVERY_REQUEST + DISCOVERY_DELIMITER + fAppVersion;

    fUDPClient.Broadcast(BroadCastStr, fUDPPort);

    SetLength(Buffer, fUDPBufferInitSize);

    CurrentTick := GetTickCount;
    ProcessTick := CurrentTick;

    repeat
      // Try Read Responce from Server
      Res := fUDPClient.ReceiveBuffer(Buffer, PeerIP, PeerPort, fUDPTimeOut);

      if Res > 0 then
      begin
        RecievedStr := BytesToString(Buffer);
        
        SetLength(RecievedStr, Res);

        BufferList.Clear;

        ParseDelimited(BufferList, RecievedStr, DISCOVERY_DELIMITER);

        if BufferList.Count = UDP_READ_PACKET_COUNT then
        begin
          if (BufferList.Strings[UDP_READ_SERVERNAME] = DISCOVERY_RESPONSE) and (BufferList.Strings[UDP_READ_SERVERVERSION] = APPVERSION) then
          begin
            Port := StrToInt(BufferList.Strings[UDP_READ_SERVERPORT]);
            Host := PeerIP;

            if DebugMe then
            begin
              Msg := 'Server Name - ' + DISCOVERY_RESPONSE +
                     ' ,Server Version - ' + APPVERSION +
                     ' ,Server IP - ' + Host +
                     ' ,Server Port - ' + BufferList.Strings[UDP_READ_SERVERPORT];

              if Assigned(fICLMessageEvent) then
              begin
                fICLMessageEvent('UDPBroadcast', Msg);
              end;
            end;

            Result := true;
          end;
        end;
      end;

      if (not Result) and (GetTickCount > ProcessTick + fProcessMessageDelay)  then
      begin
        ProcessTick := GetTickCount;
        
        Application.ProcessMessages;
      end;
    until (Result = true) or (GetTickCount > CurrentTick + FDiscoveryTimeOut);

    if not Result then
    begin
      Msg := 'Failed to Find Lock Server';

      if Assigned(fICLMessageEvent) then
      begin
        fICLMessageEvent('UDPBroadcast', Msg);
      end;

      raise Exception.Create(Msg);
    end
  finally
    FreeAndNil(BufferList);
  end;
end;

function TPracticeTCPClient.GetHost: String;
begin
  Result := FTCPClient.Host;
end;

function TPracticeTCPClient.GetPort: Integer;
begin
  Result := FTCPClient.Port;
end;

function TPracticeTCPClient.GetStartTime: DWord;
begin
  Result := GetTickCount;
end;

procedure TPracticeTCPClient.OnTCPDisconnected(Sender: TObject);
begin
  FTCPClient.IOHandler.InputBuffer.Clear;

  if Assigned(FOnDisconnected) then
  begin
    FOnDisconnected(Self);
  end;
end;

//------------------------------------------------------------------------------
constructor TPracticeTCPClient.Create;
begin
  DebugMe := false;

  FUDPClient := TIdUDPClient.Create(nil);
  FTCPClient := TIdTCPClient.Create(nil);

  FTCPClient.OnDisconnected := OnTCPDisconnected;

  // Defaults for properties
  FAppVersion        := 'NOT SET YET';

  FUDPPort           := 40;
  FUDPBufferInitSize := 1024;

  FDiscoveryTimeOut := 10000;
  FUDPTimeOut       := 100;
  FTCPTimeOut       := 100;

  FProcessMessageDelay := 250;

  FTCPReadTimeOut := 500;
end;

//------------------------------------------------------------------------------
destructor TPracticeTCPClient.Destroy;
begin
  FreeAndNil(FTCPClient);
  
  FreeAndNil(FUDPClient);

  inherited;
end;

//------------------------------------------------------------------------------
function TPracticeTCPClient.Connect: Boolean;
var
  Host: String;
  Port: Integer;
begin
  if DiscoverHost(Host, Port) then
  begin
    Result := Connect(Host, Port);
  end
  else
  begin
    Result := False;
  end;
end;

function TPracticeTCPClient.Connect(Host: String; Port: Integer): boolean;
begin
  if FTCPClient.Connected then
  begin
    Disconnect;
  end;

  FTCPClient.Host := Host;
  FTCPClient.Port := Port;

  Result := Reconnect;
end;

//------------------------------------------------------------------------------
function TPracticeTCPClient.Connected: Boolean;
begin
  Result := FTCPClient.Connected;
end;

//------------------------------------------------------------------------------
procedure TPracticeTCPClient.Disconnect;
begin
  FTCPClient.Disconnect;
end;
end.
