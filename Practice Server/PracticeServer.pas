unit PracticeServer;

interface

uses
  Windows, Classes, SysUtils, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdContext,
  LockScheduler, PracticeClientServer, IdUDPBase, IdUDPServer, IdSocketHandle, IdGlobal, StrUtils,
  Contnrs, ConnectionManager, LogUtil, Common;

type
  TPracticeServer = class sealed
  private
    type
      TLockType = (
        ltNone                =  1,
        ltSystemLog           =  2,
        ltAdminSystem         =  3,
        ltStartupCheck        =  4,
        ltPracIni             =  5,
        ltPracLogo            =  6,
        ltClientToDoList      =  7,
        ltClientDetailsCache  =  8,
        ltClientNotes         =  9,
        ltPracHeaderFooterImg = 10,
        ltAdminOptions        = 11,
        ltUsageStatistics     = 12,
        ltScheduledReport     = 13,
        ltCustomDocument      = 14,
        ltCodingStats         = 15,
        ltWebNotesupdate      = 16,
        ltWebNotesdata        = 17,
        ltExchangeRates       = 18);

      TLockTypes = set of TLockType;

      TStringArray = array of String;
      
    const
      LOCKABLE_RANGE: TLockTypes = [ltSystemLog..ltExchangeRates];
      
  private
    FMaxConnections: Integer;
    FPort: Integer;
    FListenQueueSize: Integer;
    
    FLockScheduler: TLockScheduler;

    FLockServer: TIdTCPServer;
    FUDPListener: TIdUDPServer;
    FDiscoveryPort: Integer;
    FActive: Boolean;

    FConnectionManager: TConnectionManager;

    FFileLocksHeld: TLockTypes;

    FConnectionSection: TRTLCriticalSection;
    FLockSection: TRTLCriticalSection;
    FExecuteSection: TRTLCriticalSection;

    FLoggingEnabled: Boolean;

    function CheckForLockServer(out Host: String; out Port: Integer): Boolean;
    
    function GenerateUniqueID: ULongLong;

    procedure CollectStatistics(Dest: TStream; out ConnectionCount, LockQueueCount: Integer);

    procedure AddLogEntry(Context: TIdContext; GroupId: TGroupId; LockType: DWORD; LockToken: DWord; LogMessageType: TMessageType; LogText: String); overload;
    procedure AddLogEntry(Context: TIdContext; LogMessageType: TMessageType; LogText: String); overload;
    procedure AddLogEntry(IpAddress: String; LogMessageType: TMessageType; LogText: String); overload;
    procedure AddExceptionLogEntry(LogText: String);

    function LockPracticeFiles: Boolean;
    procedure UnlockPracticeFiles;

    function GetServerVersion: String;

    procedure OnUDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);

    procedure SendLockAquired(AquiredLock: TLockRecord);
    procedure SendLockResult(Context: TIdContext; LockStatus: TLockStatus; LockType: DWORD; RequestId: DWord);

    procedure OnClientConnect(Context: TIdContext);
    procedure OnClientDisconnect(Context: TIdContext);
    procedure OnClientExecute(Context: TIdContext);

    procedure ProcessLockCommand(Context: TIdContext; RequestId: DWord; LockCommand: TLockCommand);
    procedure ProcessStatisticsCommand(Context: TIdContext);
    procedure ProcessUserLogin(Context: TIdContext; UserLoginCommand: TUserLoginCommand);
    procedure ProcessReleaseAllLocks(Context: TIdContext);
    procedure ProcessClearLockQueue(Context: TIdContext);
    procedure ProcessDisconnectAllUsers(Context: TIdContext);
    procedure ProcessDisconnectUser(Context: TIdContext; DisconnectUserCommand: TDisconnectUserCommand);
    procedure ProcessRemoveLock(Constext: TIdContext; RemoveLockCommand: TRemoveLockCommand);
    procedure ProcessSettingsRequest(Context: TIdContext);

    procedure SetMaxConnections(const Value: Integer);
    procedure SetPort(const Value: Integer);
    procedure SetListenQueueSize(const Value: Integer);
    procedure SetDiscoveryPort(const Value: Integer);
    procedure SetLoggingEnabled(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    
    property Port: Integer read FPort write SetPort;
    property MaxConnections: Integer read FMaxConnections write SetMaxConnections;
    property ListenQueueSize: Integer read FListenQueueSize write SetListenQueueSize;
    property DiscoveryPort: Integer read FDiscoveryPort write SetDiscoveryPort;

    property LoggingEnabled: Boolean read FLoggingEnabled write SetLoggingEnabled;

    property Active: Boolean read FActive;
  end;

implementation

uses
  LockUtils, IdException, TypInfo, WinUtils, PracticeTCPClient;
  
{ TPracticeServer }

procedure TPracticeServer.AddLogEntry(Context: TIdContext; GroupId: TGroupId; LockType: DWORD; LockToken: DWord; LogMessageType: TMessageType; LogText: String);
begin
  if LoggingEnabled then
  begin
    LogUtil.LogMsg(LogMessageType, 'PracticeServer', Format('%s GroupId: %s LockType: %s RequestId: %s - %s', [Context.Binding.PeerIP, GroupId, IntToStr(LockType), IntToStr(LockToken), LogText]), 0, False);
  end;
end;

procedure TPracticeServer.AddLogEntry(Context: TIdContext; LogMessageType: TMessageType; LogText: String);
begin
  AddLogEntry(Context.Binding.PeerIP, LogMessageType, LogText);
end;

procedure TPracticeServer.AddExceptionLogEntry(LogText: String);
begin
  LogUtil.LogMsg(lmError, 'PracticeServer', Format('Exception - %s', [LogText]), 0, False);
end;

procedure TPracticeServer.AddLogEntry(IpAddress: String; LogMessageType: TMessageType; LogText: String);
begin
  if LoggingEnabled then
  begin
    LogUtil.LogMsg(LogMessageType, 'PracticeServer', Format('%s - %s', [IpAddress, LogText]), 0, False);
  end;
end;

function TPracticeServer.CheckForLockServer(out Host: String; out Port: Integer): Boolean;
var
  Client: TPracticeTCPClient;
begin
  Client := TPracticeTCPClient.Create;

  try
    Client.AppVersion := '1.0.0.0';
    Client.UDPPort := DiscoveryPort;

    try
      Result := Client.DiscoverHost(Host, Port);
    except
    end;
  finally
    Client.Free;
  end;
end;

procedure TPracticeServer.CollectStatistics(Dest: TStream; out ConnectionCount, LockQueueCount: Integer);
var
  Index: Integer;
  ConnectionRecord: TConnectionRecord;
  ConnectionInfo: TConnectionInfo;
  LockInfo: TLockInfo;
  LockRecord: TLockRecord;
begin
  EnterCriticalSection(FConnectionSection);

  try
    for Index := 0 to FConnectionManager.Count - 1 do
    begin
      ConnectionRecord := TConnectionRecord(FConnectionManager[Index]);

      ConnectionInfo.Identifier := ConnectionRecord.ID;

      StringToCharArray(ConnectionRecord.IPAddress, ConnectionInfo.IpAddress);

      StringToCharArray(ConnectionRecord.UserCode, ConnectionInfo.UserCode);
      StringToCharArray(ConnectionRecord.Workstation, ConnectionInfo.WorkstationName);

      ConnectionInfo.GroupId := ConnectionRecord.GroupId;

      Dest.Write(ConnectionInfo, SizeOf(TConnectionInfo));
    end;

    ConnectionCount := FConnectionManager.Count;
  finally
    LeaveCriticalSection(FConnectionSection);
  end;

  EnterCriticalSection(FLockSection);

  try
    LockQueueCount := 0;
    
    for Index := 0 to FLockScheduler.QueueCount - 1 do
    begin
      LockRecord := FLockScheduler.QueueRecord[Index];

      LockInfo.Identifier := LockRecord.ID;

      LockInfo.LockToken := LockRecord.Token;
      LockInfo.LockType := LockRecord.LockType;
      LockInfo.LockStatus := LockRecord.Status;

      StringToCharArray(LockRecord.IPAddress, LockInfo.IpAddress);

      LockInfo.TimeCreated := LockRecord.TimeCreated;
      LockInfo.TimeAquired := LockRecord.TimeAquired;

      LockInfo.GroupId := LockRecord.GroupId;

      Dest.Write(LockInfo, SizeOf(TLockInfo));
    end;

    LockQueueCount := FLockScheduler.QueueCount;
  finally
    LeaveCriticalSection(FLockSection);
  end;
end;

constructor TPracticeServer.Create;
begin
  InitializeCriticalSection(FLockSection);
  InitializeCriticalSection(FConnectionSection);
  InitializeCriticalSection(FExecuteSection);

  Randomize;

  FActive := False;
  
  FPort := 0;
  FMaxConnections := 0;
  FListenQueueSize := 15;

  FLoggingEnabled := False;
  
  FFileLocksHeld := [];

  FLockScheduler := TLockScheduler.Create;

  FConnectionManager := TConnectionManager.Create;
  
  FLockServer := TIdTCPServer.Create(nil);

  FLockServer.OnConnect := OnClientConnect;
  FLockServer.OnDisconnect := OnClientDisconnect;
  FLockServer.OnExecute := OnClientExecute;

  FUDPListener := TIdUDPServer.Create(nil);
  
  FUDPListener.BroadcastEnabled := True;
  FUDPListener.OnUDPRead := OnUDPRead;
end;

destructor TPracticeServer.Destroy;
begin
  if FActive then
  begin
    Stop;
  end;
  
  FUDPListener.Free;
  
  FLockServer.Free;

  FLockScheduler.Free;

  FConnectionManager.Free;

  DeleteCriticalSection(FLockSection);
  DeleteCriticalSection(FConnectionSection);
  DeleteCriticalSection(FExecuteSection);
  
  inherited;
end;

function TPracticeServer.GenerateUniqueID: ULongLong;
begin
  Result := GetTickCount + DWord(Random(1000000));
end;

function TPracticeServer.GetServerVersion: String;
begin
  Result := '1.0.0.0';
end;

function TPracticeServer.LockPracticeFiles: Boolean;
var
  LockType: TLockType;
begin
  for LockType in LOCKABLE_RANGE do
  begin
    if FileLocking.ObtainLock(Integer(LockType), 100000) then
    begin
      Include(FFileLocksHeld, LockType);
    end
    else
    begin
      Break;
    end;
  end;

  Result := FFileLocksHeld - LOCKABLE_RANGE = [];
end;

procedure TPracticeServer.OnClientConnect(Context: TIdContext);
begin
  EnterCriticalSection(FConnectionSection);

  try
    FConnectionManager.AddConnection(GenerateUniqueID, Context);

    AddLogEntry(Context, lmInfo, 'Connected');
  finally
    LeaveCriticalSection(FConnectionSection);
  end;
end;

procedure TPracticeServer.OnClientDisconnect(Context: TIdContext);
var
  ReleasedLocks: TReleasedLocks;
  AquiredLock: TLockRecord;
  Index: Integer;
begin
  EnterCriticalSection(FExecuteSection);

  try
    EnterCriticalSection(FConnectionSection);

    try
      AddLogEntry(Context, lmInfo, 'Disconnecting');

      EnterCriticalSection(FLockSection);

      try
        FLockScheduler.ReleaseAllLocks(Context, ReleasedLocks);

        for Index := 0 to Length(ReleasedLocks) - 1 do
        begin
          AddLogEntry(Context, ReleasedLocks[Index].GroupId, ReleasedLocks[Index].LockType, ReleasedLocks[Index].LockToken,  lmInfo, 'Released');

          if FLockScheduler.AquireReleasedLock(ReleasedLocks[Index].LockType, ReleasedLocks[Index].GroupId, AquiredLock) then
          begin
            SendLockAquired(AquiredLock);
          end;
        end;
      finally
        LeaveCriticalSection(FLockSection);
      end;

      FConnectionManager.RemoveConnection(Context);

      AddLogEntry(Context, lmInfo, 'Disconnected');
    finally
      LeaveCriticalSection(FConnectionSection);
    end;
  finally
    LeaveCriticalSection(FExecuteSection);
  end;
end;

procedure TPracticeServer.OnClientExecute(Context: TIdContext);
var
  RequestHeader: TRequestHeader;
  Buffer: TBytes;
begin
  Context.Connection.IOHandler.CheckForDataOnSource(160);

  if Context.Connection.IOHandler.InputBufferIsEmpty then Exit;

  try
    if Context.Connection.IOHandler.InputBuffer.Size >= SizeOf(TRequestHeader) then
    begin
      Context.Connection.IOHandler.ReadBytes(Buffer, SizeOf(TRequestHeader), True);

      BytesToRaw(Buffer, RequestHeader, SizeOf(TRequestHeader));

      if ValidateRequest(RequestHeader) then
      begin
        case RequestHeader.Request.RequestType of
          rtLockRequest:
          begin
            try
              ProcessLockCommand(Context, RequestHeader.RequestId, RequestHeader.Request.LockCommand);
            except
              on E:Exception do
              begin
                AddLogEntry(Context, lmError, 'ProcessLockCommand: ' + E.Message);

                if not (E is EIdConnClosedGracefully) then
                begin
                  Context.Connection.Disconnect;
                end;
              end;
            end;
          end;
          
          rtStatisticsRequest:
          begin
            try
              ProcessStatisticsCommand(Context);
            except
              on E:Exception do
              begin
                AddLogEntry(Context, lmError, 'Statistics: ' + E.Message);

                if not (E is EIdConnClosedGracefully) then
                begin
                  Context.Connection.Disconnect;
                end;
              end;
            end;
          end;
          
          rtLoggingRequest: LoggingEnabled := RequestHeader.Request.LoggingEnabled;
          rtUserLogin: ProcessUserLogin(Context, RequestHeader.Request.UserLoginCommand);
          rtReleaseAllLocks: ProcessReleaseAllLocks(Context);
          rtRemoveLock: ProcessRemoveLock(Context, RequestHeader.Request.RemoveLockCommand);
          rtClearLockQueue: ProcessClearLockQueue(Context);
          rtDisconnectAllUsers: ProcessDisconnectAllUsers(Context);
          rtDisconnectUser: ProcessDisconnectUser(Context, RequestHeader.Request.DisconnectionUserCommand);
          rtSettingsRequest: ProcessSettingsRequest(Context);
        end;
      end
      else
      begin
        AddLogEntry(Context, lmError, 'Invalid checksum on request packet');
      end;
    end;
  except
    on E:EIdConnClosedGracefully do
    begin
      AddLogEntry('', lmError, E.Message);
    end;

    on E:Exception do
    begin
      AddLogEntry('', lmError, E.Message);

      Context.Connection.Disconnect;
    end;
  end;
end;

procedure TPracticeServer.OnUDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);
var
  Buffer: TBytes;
  Result: AnsiString;
  ResponseStr: AnsiString;
begin
  try
    SetLength(Result, Length(AData));

    BytesToRaw(AData, Result[1], Length(AData));

    if LeftStr(Result, Pos(DISCOVERY_DELIMITER, Result) -1) = DISCOVERY_REQUEST then
    begin
      AddLogEntry(ABinding.PeerIP, lmInfo, Format('Discovery request received: %s', [Result]));

      ResponseStr := Format('%s|%s|%s', [DISCOVERY_RESPONSE, IntToStr(FPort), GetServerVersion]);
       
      Buffer := RawToBytes(ResponseStr[1], Length(ResponseStr));

      FUDPListener.SendBuffer(ABinding.PeerIP, ABinding.PeerPort, Buffer);
    end;
  except
  end;
end;

procedure TPracticeServer.ProcessClearLockQueue(Context: TIdContext);
begin
  EnterCriticalSection(FLockSection);

  try
    FLockScheduler.ClearQueue;
  finally
    LeaveCriticalSection(FLockSection);
  end;  
end;

procedure TPracticeServer.ProcessDisconnectAllUsers(Context: TIdContext);
var
  Connection: TConnectionRecord;
  Index: Integer;
begin
  EnterCriticalSection(FConnectionSection);

  try
    for Index := 0 to FConnectionManager.Count -1 do
    begin
      Connection := FConnectionManager.Connections[Index];

      if CompareText(Connection.UserCode, 'Console') <> 0 then
      begin
        Connection.Context.Connection.Disconnect;
      end;
    end;
  finally
    LeaveCriticalSection(FConnectionSection);
  end; 
end;

procedure TPracticeServer.ProcessDisconnectUser(Context: TIdContext; DisconnectUserCommand: TDisconnectUserCommand);
var
  Index: Integer;
  Connection: TConnectionRecord;
begin
  EnterCriticalSection(FConnectionSection);

  try
    for Index := 0 to FConnectionManager.Count - 1 do
    begin
      if FConnectionManager.Connections[Index].ID = DisconnectUserCommand.Identifier then
      begin
        Connection := FConnectionManager.Connections[Index];

        Connection.Context.Connection.Disconnect;
        
        Break;
      end;
    end;
  finally
    LeaveCriticalSection(FConnectionSection);
  end;
end;

procedure TPracticeServer.ProcessLockCommand(Context: TIdContext; RequestId: DWord; LockCommand: TLockCommand);
var
  LockStatus: TLockStatus;
  UnlockStatus: TLockStatus;
  AquiredLock: TLockRecord;
begin
  EnterCriticalSection(FLockSection);

  try
    AddLogEntry(Context, lmInfo, 'Process Lock Command');
    
    if LockCommand.RequestType = ltLock then
    begin
      AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Requesting lock');

      LockStatus := FLockScheduler.RequestLock(GenerateUniqueID, RequestId, Context, LockCommand.LockType, LockCommand.GroupId);

      if LockStatus = lsAquired then
      begin
        SendLockResult(Context, lsAquired, LockCommand.LockType, RequestId);

        AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Aquired lock')
      end
      else
      if LockStatus = lsAquiredExisting then
      begin
        SendLockResult(Context, lsAquiredExisting, LockCommand.LockType, RequestId);

        AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Aquired existing lock')
      end
      else
      begin
        AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Waiting for lock');
      end;
    end
    else
    begin
      if LockCommand.RequestType = ltUnlock then
      begin
        AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Requesting release of lock');

        UnlockStatus := FLockScheduler.ReleaseLock(Context, LockCommand.LockType, LockCommand.GroupId);

        if UnlockStatus = lsUnlocked then
        begin
          SendLockResult(Context, lsUnlocked, LockCommand.LockType, RequestId);

          AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Released aquired lock');

          if FLockScheduler.AquireReleasedLock(LockCommand.LockType, LockCommand.GroupId, AquiredLock) then
          begin
            SendLockAquired(AquiredLock);
          end;
        end
        else
        begin
          if UnlockStatus = lsRemovedWaiting then
          begin
            SendLockResult(Context, lsRemovedWaiting, LockCommand.LockType, RequestId);

            AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Released waiting lock');
          end
          else
          begin
            SendLockResult(Context, lsNoLock, LockCommand.LockType, RequestId);

            AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Lock not found - no lock removed');
          end;
        end;
      end
      else
      begin
        AddLogEntry(Context, LockCommand.GroupId, LockCommand.LockType, RequestId, lmInfo, 'Requesting abandon lock');

        FLockScheduler.ReleaseLock(Context, LockCommand.LockType, LockCommand.GroupId);
      end;
    end;
  finally
    LeaveCriticalSection(FLockSection);
  end;
end;

procedure TPracticeServer.ProcessReleaseAllLocks(Context: TIdContext);
var
  Index: Integer;
  LockRecord: TLockRecord;
  LockType: DWord;
  AquiredLock: TLockRecord;
  GroupId: TGroupID;
begin
  EnterCriticalSection(FLockSection);

  try
    Index := 0;

    while (Index < FLockScheduler.QueueCount) and (FLockScheduler.QueueCount > 0) do
    begin
      LockRecord := FLockScheduler.QueueRecord[Index];

      if LockRecord.Status = lsAquired then
      begin
        LockType := LockRecord.LockType;
        GroupId := LockRecord.GroupId;
        
        FLockScheduler.ReleaseLock(LockRecord.Context, LockType, LockRecord.GroupId);

        if FLockScheduler.AquireReleasedLock(LockType, GroupId, AquiredLock) then
        begin
          SendLockAquired(AquiredLock);         
        end;
      end
      else
      begin
        Inc(Index);
      end;
    end;
  finally
    LeaveCriticalSection(FLockSection);
  end; 
end;

procedure TPracticeServer.ProcessRemoveLock(Constext: TIdContext; RemoveLockCommand: TRemoveLockCommand);
var
  Index: Integer;
  LockRecord: TLockRecord;
  AquiredLock: TLockRecord;
  LockType: DWord;
  GroupId: TGroupId;
begin
  EnterCriticalSection(FLockSection);

  try
    LockRecord := nil;
    
    for Index := 0 to FLockScheduler.QueueCount - 1 do
    begin
      if FLockScheduler.QueueRecord[Index].ID = RemoveLockCommand.Identifier then
      begin
        LockRecord := FLockScheduler.QueueRecord[Index];

        Break;
      end;
    end;

    if LockRecord <> nil then
    begin
      LockType := LockRecord.LockType;
      GroupId := LockRecord.GroupId;
      
      if FLockScheduler.ReleaseLock(LockRecord) = lsUnlocked then
      begin
        if FLockScheduler.AquireReleasedLock(LockType, GroupId, AquiredLock) then
        begin
          SendLockAquired(AquiredLock);
        end; 
      end;
    end;
  finally
    LeaveCriticalSection(FLockSection);
  end;
end;

procedure TPracticeServer.ProcessSettingsRequest(Context: TIdContext);
var
  Response: TResponse;
  ResponseHeader: TResponseHeader;
begin
  Response.ResponseType := rtSettingsResponse;
  Response.SettingsResult.LoggingEnabled := LoggingEnabled;

  ResponseHeader := PackageResponse(0, Response);

  Context.Connection.IOHandler.Write(RawToBytes(ResponseHeader, SizeOf(TResponseHeader)));
end;

procedure TPracticeServer.ProcessStatisticsCommand(Context: TIdContext);
var
  Statistics: TMemoryStream;
  ResponseHeader: TResponseHeader;
  Response: TResponse;
  ConnectionCount: Integer;
  QueueCount: Integer;
begin
  Statistics := TMemoryStream.Create;

  try
    ConnectionCount := 0;
    QueueCount := 0;

    CollectStatistics(Statistics, ConnectionCount, QueueCount);

    Statistics.Position := 0;

    Response.ResponseType := rtStatisticsResponse;

    Response.ConnectionCount := ConnectionCount;
    Response.LockQueueCount := QueueCount;
    Response.StreamSize := Statistics.Size;

    ResponseHeader := PackageResponse(0, Response);

    Context.Connection.IOHandler.Write(RawToBytes(ResponseHeader, SizeOf(TResponseHeader)));

    Context.Connection.IOHandler.Write(Statistics);
  finally
    Statistics.Free;
  end;
end;

procedure TPracticeServer.ProcessUserLogin(Context: TIdContext; UserLoginCommand: TUserLoginCommand);
var
  Connection: TConnectionRecord;
begin
  EnterCriticalSection(FConnectionSection);

  try
    Connection := FConnectionManager.FindConnection(Context);

    if Connection <> nil then
    begin
      Connection.UserCode := UserLoginCommand.UserCode;
      Connection.Workstation := UserLoginCommand.Workstation;
      Connection.GroupId := UserLoginCommand.GroupId;
    end;
  finally
    LeaveCriticalSection(FConnectionSection);
  end;
end;

procedure TPracticeServer.SendLockAquired(AquiredLock: TLockRecord);
begin
  SendLockResult(AquiredLock.Context, lsAquired, AquiredLock.LockType, AquiredLock.Token);

  AddLogEntry(AquiredLock.Context, AquiredLock.GroupId, AquiredLock.LockType, AquiredLock.Token,  lmInfo, 'Aquired');
end;

procedure TPracticeServer.SendLockResult(Context: TIdContext; LockStatus: TLockStatus; LockType: DWORD; RequestId: DWord);
var
  Response: TResponse;
  ResponseHeader: TResponseHeader;
  Buffer: TBytes;
begin
  Response.ResponseType := rtLockResponse;
  Response.LockResult.LockStatus := LockStatus;
  Response.LockResult.LockType := LockType;

  ResponseHeader := PackageResponse(RequestId, Response);

  Buffer := RawToBytes(ResponseHeader, SizeOf(TResponseHeader));

  Context.Connection.IOHandler.Write(Buffer);
end;

procedure TPracticeServer.SetDiscoveryPort(const Value: Integer);
begin
  FDiscoveryPort := Value;
end;

procedure TPracticeServer.SetListenQueueSize(const Value: Integer);
begin
  FListenQueueSize := Value;
end;

procedure TPracticeServer.SetLoggingEnabled(const Value: Boolean);
begin
  FLoggingEnabled := Value;
end;

procedure TPracticeServer.SetMaxConnections(const Value: Integer);
begin
  FMaxConnections := Value;
end;

procedure TPracticeServer.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

procedure TPracticeServer.Start;
var
  Host: String;
  Port: Integer;
begin
  if not FActive then
  begin
    InitLocking;
    
    LockPracticeFiles;

    try
      if not CheckForLockServer(Host, Port) then
      begin
        FUDPListener.DefaultPort := FDiscoveryPort;

        FUDPListener.Active := True;

        FLockServer.DefaultPort := FPort;
        FLockServer.MaxConnections := FMaxConnections;
        FLockServer.ListenQueue := FListenQueueSize;
  
        FLockServer.Active := True;

        FActive := True;
      end
      else
      begin
        raise Exception.Create(Format('A lock server running on %s is using the same discovery port as this one.  Please stop the other lock server or change the discovery port.',[Host, IntToStr(Port)]));
      end;
    except
      on E:Exception do
      begin
        AddExceptionLogEntry(E.Message);
        
        UnlockPracticeFiles;

        raise;
      end;
    end;
  end;
end;

procedure TPracticeServer.Stop;
begin
  if FActive then
  begin
    LogUtil.LogMsg(lmInfo, 'PracticeServer', 'Lock Queue Count: ' + IntToStr(FLockScheduler.QueueCount), 0, False);
     
    FUDPListener.Active := False;
    FLockServer.Active := False;

    FLockScheduler.ClearQueue;

    UnlockPracticeFiles;

    FConnectionManager.Clear;
    
    FActive := False;
  end;
end;

procedure TPracticeServer.UnlockPracticeFiles;
var
  LockType: TLockType;
begin
  for LockType in FFileLocksHeld do
  begin
    if FileLocking.ReleaseLock(Integer(LockType)) then
    begin
      Exclude(FFileLocksHeld, LockType);
    end;
  end;
end;

end.
