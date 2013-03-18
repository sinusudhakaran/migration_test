//------------------------------------------------------------------------------
unit IPClientLocking;

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
  idGlobal,
  PracticeClientServer;

type
  //----------------------------------------------------------------------------
  TICLMessageEvent = procedure(aMethod : String; aMesssage : String) of object;

  //----------------------------------------------------------------------------
  TIPClientLocking = class
  private
    fICLMessageEvent : TICLMessageEvent;
    fUDPClient : TIdUDPClient;
    fTCPClient : TIdTCPClient;

    fAppVersion : string;
    fUDPPort : integer;
    fUDPBufferInitSize : integer;

    fDiscoveryTimeOut : dword;
    fUDPTimeOut : integer;
    fLockTimeOut : dword;
    fTCPTimeOut : integer;
    fProcessMessageDelay : dword;

    fServerTCPPort : integer;
    fServerIP : string;

    fRequestId : dword;

    fDebugMe : boolean;
    fGroupID : TGroupID;

    procedure ParseDelimited(const aStrLst : TStrings; const aSearchStr : string; const aDelimiter : string);
  protected
    function UDPBroadcast : boolean;

    function Request(aBuffer : TIdBytes): boolean;
    function Recieve(out aBuffer : TIdBytes): boolean;
    function LockingRequest(aRequestType: TLockRequestType; aLockType: word): boolean;
    function LockingRecieve(aRequestType: TLockRequestType; aLockType: word; aRequesID : dword): boolean;

    function GetLockTypeName(aLockRequestType : TLockRequestType) : string;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    Function Connect : Boolean;
    Function ManualConnect : boolean;
    Function Connected : Boolean;
    Procedure Disconnect;

    function RequestLock(aLockType: word) : boolean;
    function RequestUnLock(aLockType: word): boolean;
    function RequestAbandonLock(aLockType: word): boolean;
    function RequestLoginUser(aUserCode : TUserCode; aWorkstation : TWorkstation): boolean;

    function RecieveLock(aLockType: word; aRequestId : dword): boolean;
    function RecieveUnLock(aLockType: word; aRequestId : dword): boolean;
    function IncRequestID : dword;
    procedure setGroupID(aGroupid : string);

    property AppVersion : string read fAppVersion write fAppVersion;
    property UDPPort : integer read fUDPPort write fUDPPort;
    property UDPBufferInitSize : integer read fUDPBufferInitSize write fUDPBufferInitSize;

    property DiscoveryTimeOut : dword read fDiscoveryTimeOut write fDiscoveryTimeOut;
    property UDPTimeOut : integer read fUDPTimeOut write fUDPTimeOut;
    property LockTimeOut : dword read fLockTimeOut write fLockTimeOut;
    property TCPTimeOut : integer read fTCPTimeOut write fTCPTimeOut;

    property ServerIP : string read fServerIP write fServerIP;
    property ServerTCPPort : integer read fServerTCPPort write fServerTCPPort;

    property ProcessMessageDelay : dword read fProcessMessageDelay write fProcessMessageDelay;
    property ICLMessageEvent : TICLMessageEvent read fICLMessageEvent write fICLMessageEvent;
    property DebugMe : boolean read fDebugMe write fDebugMe;

    property RequestId : dword read fRequestId write fRequestId;
  end;

//----------------------------------------------------------------------------
implementation

uses
  SysUtils,
  Forms,
  IdExceptionCore,
  IdException,
  crc32,
  StackTracing;

const
  UnitName = 'IPCLIENTLOCKING';
  UDP_READ_SERVERNAME    = 0;
  UDP_READ_SERVERPORT    = 1;
  UDP_READ_SERVERVERSION = 2;
  UDP_READ_PACKET_COUNT  = 3;
  MAX_REQUEST_ID         = 1000000;

{ TIPClientLocking }
//------------------------------------------------------------------------------
procedure TIPClientLocking.ParseDelimited(const aStrLst : TStrings; const aSearchStr : string; const aDelimiter : string);
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

//------------------------------------------------------------------------------
function TIPClientLocking.UDPBroadcast : boolean;
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
  Try
    // Send UDP Broad Cast
    BroadCastStr := DISCOVERY_REQUEST + DISCOVERY_DELIMITER + fAppVersion;
    fUDPClient.Broadcast(BroadCastStr, fUDPPort);

    SetLength(Buffer, fUDPBufferInitSize);
    CurrentTick := GetTickCount;
    ProcessTick := CurrentTick;
    Repeat
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
          if (BufferList.Strings[UDP_READ_SERVERNAME] = DISCOVERY_RESPONSE) and
             (BufferList.Strings[UDP_READ_SERVERVERSION] = APPVERSION) then
          begin
            fServerTCPPort := StrToInt(BufferList.Strings[UDP_READ_SERVERPORT]);
            fServerIP := PeerIP;

            if DebugMe then
            begin
              Msg := 'Server Name - ' + DISCOVERY_RESPONSE +
                     ' ,Server Version - ' + APPVERSION +
                     ' ,Server IP - ' + fServerIP +
                     ' ,Server Port - ' + BufferList.Strings[UDP_READ_SERVERPORT];

              if Assigned(fICLMessageEvent) then
                fICLMessageEvent('UDPBroadcast', Msg);
            end;

            Result := true;
          end;
        end;
      end;

      if (not Result) and
         (GetTickCount > ProcessTick + fProcessMessageDelay)  then
      begin
        ProcessTick := GetTickCount;
        Application.ProcessMessages;
      end;

    Until (Result = true) or
          (GetTickCount > CurrentTick + fDiscoveryTimeOut);

    if not Result then
    begin
      Msg := 'Failed to Find Lock Server';
      if Assigned(fICLMessageEvent) then
        fICLMessageEvent('UDPBroadcast', Msg);

      Raise Exception.Create(Msg);
    end;

  finally
    FreeAndNil(BufferList);
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.Request(aBuffer : TIdBytes): boolean;
begin
  Result := false;

  try
    if fTCPClient.Connected then
    begin
      fTCPClient.IOHandler.Write(aBuffer);
      Result := true;
    end
    else
      Raise Exception.Create('Error Disconnected');
  except
    on E : EIdConnClosedGracefully do
      Exit;
    on E : Exception do
    begin
      if Assigned(fICLMessageEvent) then
        fICLMessageEvent('WriteToServer', E.Message);
      Raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.Recieve(out aBuffer: TIdBytes): boolean;
var
  BufferSize : integer;
begin
  Result := false;

  try
    if fTCPClient.Connected then
    begin
      if FTCPClient.IOHandler.InputBufferIsEmpty then
        Exit;

      BufferSize := FTCPClient.IOHandler.InputBuffer.Size;
      SetLength(aBuffer, BufferSize);

      fTCPClient.IOHandler.ReadBytes(aBuffer, length(aBuffer), false);
      Result := true;
    end
    else
      Raise Exception.Create('Error Disconnected');
  except
    on E : EIdReadTimeout do
    begin
      if DebugMe then
        if Assigned(fICLMessageEvent) then
          fICLMessageEvent('ReadFromServer', E.Message);
      Raise;
    end;

    on E : Exception do
    begin
      if Assigned(fICLMessageEvent) then
        fICLMessageEvent('ReadFromServer', E.Message);
      Raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.LockingRequest(aRequestType: TLockRequestType; aLockType: word): boolean;
var
  RequestHeader : TRequestHeader;
  OutBuffer : TIdBytes;
  Msg : string;
begin
  Result := false;
  if not Connected then
    ManualConnect;

  if Connected then
  begin
    RequestHeader.Request.RequestType := rtLockRequest;
    RequestHeader.Request.LockCommand.RequestType := aRequestType;
    RequestHeader.Request.LockCommand.LockType    := aLockType;
    RequestHeader.Request.LockCommand.GroupId     := fGroupID;

    RequestHeader.Checksum := GetCRC_LW(RequestHeader.Request, Sizeof(RequestHeader.Request));
    RequestHeader.RequestId := IncRequestID;

    OutBuffer := RawToBytes(RequestHeader , Sizeof(RequestHeader));
    Result := Request(OutBuffer);

    if DebugMe then
    begin
      Msg := 'Request - ' + GetLockTypeName(aRequestType) +
             ' ,Request ID - ' + inttostr(RequestID) +
             ' ,Request Lock Type - ' + inttostr(aLockType);

      if Assigned(fICLMessageEvent) then
        fICLMessageEvent('WriteToServer', Msg);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.LockingRecieve(aRequestType: TLockRequestType; aLockType: word; aRequesID : dword): boolean;
var
  ResponseHeader : TResponseHeader;
  InBuffer : TIdBytes;
  Status : string;
  Msg : string;
  Request : string;
begin
  Result := Recieve(InBuffer);

  if Result then
  begin
    case aRequestType of
      ltlock : Request := 'Lock';
      ltUnlock : Request := 'UnLock';
      ltAbandoned : Request := 'Abandoned';
    end;

    BytesToRaw(InBuffer, ResponseHeader, Sizeof(ResponseHeader));

    if not ValidateResponse(ResponseHeader) then
      Raise Exception.Create('Recieve - ' + Request + ', Checksum Error.');

    Result := ((aRequestType = ltlock) and
              (ResponseHeader.Response.LockResult.LockStatus in [lsAquired, lsAquiredExisting])) or
              (aRequestType = ltUnlock);

    if DebugMe then
    begin
      case ResponseHeader.Response.LockResult.LockStatus of
        lsWaiting  : Status := 'Waiting';
        lsAquired  : Status := 'Aquired';
        lsUnlocked : Status := 'Unlocked';
        lsRemovedWaiting : Status := 'Removed Waiting';
        lsNoLock   : Status := 'NoLock';
        lsError    : Status := 'Error';
        lsAquiredExisting : Status := 'Aquired Existing';
      end;

      if ResponseHeader.Response.LockResult.LockStatus in
        [lsNoLock, lsError, lsAquiredExisting] then
      begin
        if Assigned(fICLMessageEvent) then
          fICLMessageEvent('LockingRecieve', 'Error , Lock Status : ' + Status +
                           ' ,Client Request ID - ' + inttostr(RequestID) +
                           ' ,Server Request ID - ' + inttostr(ResponseHeader.RequestID) +
                           ' ,Lock Type - ' + inttostr(ResponseHeader.Response.LockResult.LockType));

        GetAndLogStackTrace(UnitName, 'LockingRecieve');
      end;

      if (aLockType <> ResponseHeader.Response.LockResult.LockType) or
         (RequestID <> ResponseHeader.RequestID) then
      begin
        Msg := 'Error Request Read - ' + Request +
               ' ,Client Request ID - ' + inttostr(RequestID) +
               ' ,Server Request ID - ' + inttostr(ResponseHeader.RequestID) +
               ' ,Request Lock Type - ' + inttostr(aLockType) +
               ' ,Result Lock Type - ' + inttostr(ResponseHeader.Response.LockResult.LockType) +
               ' ,LockStatus - ' + Status;
        if Assigned(fICLMessageEvent) then
          fICLMessageEvent('ReadFromServer', Msg);
      end
      else
      begin
        Msg := 'Request Read - ' + Request +
               ' ,Client Request ID - ' + inttostr(RequestID) +
               ' ,Server Request ID - ' + inttostr(ResponseHeader.RequestID) +
               ' ,Lock Type - ' + inttostr(ResponseHeader.Response.LockResult.LockType) +
               ' ,LockStatus - ' + Status;
        if Assigned(fICLMessageEvent) then
          fICLMessageEvent('ReadFromServer', Msg);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.GetLockTypeName(aLockRequestType : TLockRequestType): string;
begin
  case aLockRequestType of
    ltlock : Result := 'Lock';
    ltUnlock : Result := 'UnLock';
    ltAbandoned : Result := 'Abandoned';
  else
    Result := '';
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.IncRequestID : Dword;
begin
  fRequestID := fRequestID + 1;

  if fRequestID > MAX_REQUEST_ID then
    fRequestID := 1;

  Result := fRequestID;
end;

//------------------------------------------------------------------------------
constructor TIPClientLocking.Create;
begin
  DebugMe := false;

  fUDPClient := TIdUDPClient.Create(nil);
  fTCPClient := TIdTCPClient.Create(nil);

  fRequestID := 0;

  // Defaults for properties
  fAppVersion        := 'NOT SET YET';
  fUDPPort           := 4323;
  fUDPBufferInitSize := 1024;

  fDiscoveryTimeOut := 10000;
  fUDPTimeOut       := 100;

  fLockTimeOut      := 10000;
  fTCPTimeOut       := 100;

  fProcessMessageDelay := 250;
end;

//------------------------------------------------------------------------------
destructor TIPClientLocking.Destroy;
begin
  FreeAndNil(fTCPClient);
  FreeAndNil(fUDPClient);

  inherited;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.Connect: Boolean;
begin
  Result := false;
  if UDPBroadcast then
    Result := ManualConnect;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.ManualConnect: boolean;
begin
  if fTCPClient.Connected then
  begin
    Result := true;
    Exit;
  end;

  Result := false;
  fTCPClient.Host := fServerIP;
  fTCPClient.Port := fServerTCPPort;

  fTCPClient.Connect;

  if fTCPClient.Connected then
  begin
    fTCPClient.IOHandler.ReadTimeout := fTCPTimeOut;
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.Connected: Boolean;
begin
  Result := fTCPClient.Connected;
end;

//------------------------------------------------------------------------------
procedure TIPClientLocking.Disconnect;
begin
  fTCPClient.Disconnect;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RequestLock(aLockType: word): boolean;
begin
  Result := LockingRequest(ltLock, aLockType);
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RequestUnLock(aLockType: word): boolean;
begin
  Result := LockingRequest(ltUnLock, aLockType);
end;

//------------------------------------------------------------------------------
procedure TIPClientLocking.setGroupID(aGroupid: string);
var
  Index: Integer;
begin
  FillChar(fGroupID, Length(fGroupID), #0);

  for Index := 1 to Length(aGroupid) do
  begin
    if Index < Length(fGroupID) then
    begin
      fGroupID[Index -1] := aGroupid[Index];
    end
    else
    begin
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RequestAbandonLock(aLockType: word): boolean;
begin
  Result := LockingRequest(ltAbandoned, aLockType);
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RequestLoginUser(aUserCode: TUserCode;
                                           aWorkstation: TWorkstation): boolean;
var
  RequestHeader : TRequestHeader;
  OutBuffer : TIdBytes;
  Msg : string;
begin
  Result := false;
  if not Connected then
    ManualConnect;

  if Connected then
  begin

    RequestHeader.Request.RequestType := rtUserLogin;
    RequestHeader.Request.UserLoginCommand.UserCode    := aUserCode;
    RequestHeader.Request.UserLoginCommand.Workstation := aWorkstation;
    RequestHeader.Request.UserLoginCommand.GroupID     := fGroupID;

    RequestHeader.Checksum := GetCRC_LW(RequestHeader.Request, Sizeof(RequestHeader.Request));
    RequestHeader.RequestId := IncRequestID;

    OutBuffer := RawToBytes(RequestHeader , Sizeof(RequestHeader));
    Result := Request(OutBuffer);

    if DebugMe then
    begin
      Msg := 'Request - Login User' +
             ' ,Request ID - ' + inttostr(RequestID) +
             ' ,User Code - ' + aUserCode +
             ' ,Workstation - ' + aWorkstation;

      if Assigned(fICLMessageEvent) then
        fICLMessageEvent('WriteToServer', Msg);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RecieveLock(aLockType: word; aRequestId : dword): boolean;
begin
  Result := LockingRecieve(ltLock, aLockType, aRequestId);
end;

//------------------------------------------------------------------------------
function TIPClientLocking.RecieveUnLock(aLockType: word; aRequestId : dword): boolean;
begin
  Result := LockingRecieve(ltUnLock, aLockType, aRequestId);
end;

end.



