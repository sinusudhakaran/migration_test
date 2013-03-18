unit PracticeClientServer;

interface

uses
  Windows, SysUtils;

const
  DISCOVERY_REQUEST = 'PRACTICE';
  DISCOVERY_RESPONSE = 'LOCKSERVER';
  DISCOVERY_DELIMITER = '|';
  PACKET_VERSION: Word = 1000;

type
  TIpAddress = array[0..14] of Char;
  TUserCode = array[0..7] of Char;
  TWorkstation = array[0..19] of Char;
  TGroupId = array[0..35] of Char;

  TRequestType = (rtLockRequest, rtLoggingRequest, rtStatisticsRequest, rtUserLogin, rtClearLockQueue, rtReleaseAllLocks, rtRemoveLock, rtDisconnectAllUsers, rtDisconnectUser, rtSettingsRequest);

  TResponseType = (rtLockResponse, rtLoggingResponse, rtStatisticsResponse, rtSettingsResponse, rtErrorResponse);

  TLockStatus = (lsWaiting, lsAquired, lsUnlocked, lsRemovedWaiting, lsNoLock, lsError, lsAquiredExisting);

  TLockRequestType = (ltLock, ltUnlock, ltAbandoned);

  TUserLoginCommand = record
    UserCode : TUserCode;
    Workstation : TWorkstation;
    GroupId: TGroupId;
  end;

  TLockCommand = record
    RequestType: TLockRequestType;
    LockType: DWORD;
    GroupId: TGroupId;
  end;

  TDisconnectUserCommand = record
    Identifier: ULongLong;
  end;

  TRemoveLockCommand = record
    Identifier: ULongLong;
  end;

  TLockResult = record
    LockStatus: TLockStatus;
    LockType: DWORD;
  end;

  TSettingsResult = record
    LoggingEnabled: Boolean;
  end;

  TRequest = record
    case RequestType: TRequestType of
      rtLockRequest: (LockCommand: TLockCommand);
      rtLoggingRequest: (LoggingEnabled: Boolean);
      rtUserLogin: (UserLoginCommand: TUserLoginCommand);
      rtRemoveLock: (RemoveLockCommand: TRemoveLockCommand);
      rtDisconnectUser: (DisconnectionUserCommand: TDisconnectUserCommand);
  end;

  TRequestHeader = record
    RequestId : DWord;
    Checksum: LongWord;
    Request: TRequest;
  end;

  TResponse = record
    case ResponseType: TResponseType of
      rtLockResponse: (LockResult: TLockResult);
      rtLoggingResponse: (Success: Boolean);
      rtStatisticsResponse: (ConnectionCount: Integer; LockQueueCount: Integer; StreamSize: Integer);
      rtErrorResponse: (ErrorCode: Integer);
      rtSettingsResponse: (SettingsResult: TSettingsResult);
  end;

  TResponseHeader = record
    RequestId : DWord;
    Checksum: LongWord;
    Response: TResponse;
  end;

  TConnectionInfo = record
    Identifier: ULongLong;
    IpAddress: TIpAddress;
    UserCode: TUserCode;
    WorkstationName: TWorkstation;
    GroupId: TGroupId;
  end;

  TLockInfo = record
    Identifier: ULongLong;
    LockToken: Word;
    IpAddress: TIpAddress;
    LockType: DWord;
    LockStatus: TLockStatus;
    TimeCreated: TDateTime;
    TimeAquired: TDateTime;
    GroupId: TGroupId;
  end;

function PackageRequest(RequestId: DWord; Request: TRequest): TRequestHeader;
function PackageResponse(RequestId: DWord; Response: TResponse): TResponseHeader;

function ValidateRequest(RequestHeader: TRequestHeader): Boolean;
function ValidateResponse(ResponseHeader: TResponseHeader): Boolean;

procedure StringToCharArray(const Value: String; var CharArray: array of Char);

function GetWorkstationName: String;

implementation

uses
  Crc32;

procedure StringToCharArray(const Value: String; var CharArray: array of Char);
begin
  FillChar(CharArray[0], Length(CharArray) * Sizeof(Char), #0);
  Move(Value[1], CharArray[0], Length(Value) * SizeOf(Char));
end;

function PackageRequest(RequestId: DWord; Request: TRequest): TRequestHeader;
begin
  Result.RequestId := RequestId;
  Result.Checksum := GetCRC_LW(Request, SizeOf(TRequest));
  Result.Request := Request;
end;

function PackageResponse(RequestId: DWord; Response: TResponse): TResponseHeader;
begin
  Result.RequestId := RequestId;
  Result.Checksum := GetCRC_LW(Response, SizeOf(TResponse));
  Result.Response := Response;
end;

function ValidateRequest(RequestHeader: TRequestHeader): Boolean;
begin
  Result := RequestHeader.Checksum = GetCRC_LW(RequestHeader.Request, SizeOf(TRequest));
end;

function ValidateResponse(ResponseHeader: TResponseHeader): Boolean;
begin
  Result := ResponseHeader.Checksum = GetCRC_LW(ResponseHeader.Response, SizeOf(TResponse));
end;

function GetWorkstationName: String;
var
  Size:Cardinal;
  Buffer: array[0..255] of AnsiChar;
begin
  Size := 256;
  
  if GetComputerName(Buffer, Size) then
  begin
    Result := Buffer
  end
  else
  begin
    Result := ''
  end;
end;
end.



