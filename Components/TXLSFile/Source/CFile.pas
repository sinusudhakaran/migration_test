unit CFile;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Compound Files

    Rev history:
    2003-08-29   Add: Ability to create compound file in memory
    2003-12-09   Fix: All objects destroy corectly
    2004-01-18   Fix: Use MAX_PATH constant for file name buffer size
    2006-06-23   Add: Reading from TStream added
    2006-09-01   Add: FindItem compares names in upper case
    2008-04-15   Fix: CoTaskMemFree added for TStatStg.pwcsName
     
-----------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, ActiveX, XLSBase;

type
  TCFileItem = class
  protected
    FName: AnsiString;
  public
    property Name: AnsiString read FName write FName;
  end;

  {TCFileStream}
  TCFileStream = class(TCFileItem)
  protected
    FStream: IStream;
    function GetSize: Longint;
    function GetPosition: Longint;
    procedure SetPosition(const APosition: Longint);
  public
    constructor Create;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint;
    function ReadWord(Buff: Pointer): Boolean;
    function ReadDWord(Buff: Pointer): Boolean;
    function ReadBytes(Buff: Pointer; Size: Integer): Boolean;
    function Write(const Buffer; Count: Longint): Longint;
    function WriteByte(const B: Byte): Boolean;    
    function WriteWord(const W: Word): Boolean;
    function WriteDWord(const D: DWord): Boolean;
    function WriteBytes(Buff: Pointer; Size: Integer): Boolean;
    function Seek(Offset: Longint; Origin: Word): Longint;
    property Size: Longint read GetSize;
    property Position: Longint read GetPosition write SetPosition;
  end;

  {TCFileStorage}
  TCFileStorage = class(TCFileItem)
  protected
    FStorage: IStorage;
    FItems: TList;
    function GetCount: Integer;
    function GetItem(I: Integer): TCFileItem;
    procedure ClearItems;
  public
    constructor Create; dynamic;
    constructor CreateNew(const AName: AnsiString); dynamic;
    destructor Destroy; override;
    function AddNewStorage(AName: AnsiString): TCFileStorage;
    function AddNewStream(AName: AnsiString): TCFileStream;
    procedure FillFromIStorage(const AStorage: IStorage);
    function FindItem(const AName: AnsiString): TCFileItem;
    procedure Commit;
    property Count: Integer read GetCount;
    property Item[I: Integer]: TCFileItem read GetItem;
  end;

  {TCFileCreateMode}
  TCFileCreateMode = (cfCreateNew, cfCreateFromFile, cfCreateNewInMemory);

  {TCFile}
  TCFile = class
  protected
    FName: WideString;
    FRoot: TCFileStorage;
    FLockBytes: ILockBytes;
  public
    constructor Create(ACreateMode: TCFileCreateMode; const AFileName: WideString); dynamic;
    constructor CreateFromStream(const AStream: TStream); dynamic;
    destructor Destroy; override;
    procedure ReadLockBytesFromStream(const AStream: TStream);
    procedure SaveLockBytesToStream(const AStream: TStream);
    property Root: TCFileStorage read FRoot;
    property LockBytes: ILockBytes read FLockBytes;
    property Name: WideString read FName;
  end;

  {TCFileErrorCode}
  TCFileErrorCode = (
    ECFILE_CREATE_DOCFILE,
    ECFILE_CREATE_STREAM,
    ECFILE_CREATE_STORAGE,
    ECFILE_OPEN_DOCFILE,
    ECFILE_OPEN_STREAM,
    ECFILE_OPEN_STORAGE,
    ECFILE_STREAM_SETPOSITION,
    ECFILE_COMMIT_STORAGE
  );

  {ECFileError}
  ECFileError = class(Exception)
  private
    FErrorCode: TCFileErrorCode;
  public
    constructor Create(ACode: TCFileErrorCode);
    property ErrorCode: TCFileErrorCode read FErrorCode;
  end;

const
  CFileErrors: array [TCFileErrorCode] of AnsiString = (
  'Can not create a file',
  'Can not create a stream',
  'Can not create a storage',
  'Can not open a file (probably it is already opened or does not exist)',
  'Can not open a stream',
  'Can not open a storage',
  'Can not set stream position',
  'Can not commit a storage'
  );

implementation
uses
  XLSStrUtil;

const
  NAME_BUFFER_SIZE = 100;
  DATA_BUFFER_SIZE = 100000;

{ECFileError}
constructor ECFileError.Create(ACode: TCFileErrorCode);
begin
  FErrorCode:= ACode;
  inherited Create(String(CFileErrors[ACode]));
end;

{TCFileStream}
constructor TCFileStream.Create;
begin
  FStream:= nil;
end;

destructor TCFileStream.Destroy;
begin
  FStream:= nil;
  inherited;
end;

function TCFileStream.Read(var Buffer; Count: Longint): Longint;
begin
  FStream.Read(@Buffer, Count, @Result);
end;

function TCFileStream.Write(const Buffer; Count: Longint): Longint;
begin
  FStream.Write(@Buffer, Count, @Result);
end;

function TCFileStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  NewPos: LargeInt;
begin
  FStream.Seek(Offset, Origin, NewPos);
  Result:= PLongint(@NewPos)^;
end;

function TCFileStream.GetSize: Longint;
var
  CurrentPos, EndPos: Longint;
begin
  {save current position}
  CurrentPos:= Self.Seek(0, STREAM_SEEK_CUR);
  {seek end of stream}
  EndPos:= Self.Seek(0, STREAM_SEEK_END);
  Result:= EndPos;
  {return to current position}
  Self.Seek(CurrentPos, STREAM_SEEK_SET);
end;

function TCFileStream.GetPosition: Longint;
begin
  Result:= Self.Seek(0, STREAM_SEEK_CUR);
end;

procedure TCFileStream.SetPosition(const APosition: Longint);
begin
  if Self.Seek(APosition, STREAM_SEEK_SET) <> APosition then
    raise ECFileError.Create(ECFILE_STREAM_SETPOSITION);
end;

function TCFileStream.WriteByte(const B: Byte): Boolean;
begin
  Result:= ( Self.Write(B, 1) = 1 );
end;

function TCFileStream.WriteWord(const W: Word): Boolean;
begin
  Result:= ( Self.Write(W, 2) = 2 );
end;

function TCFileStream.WriteDWord(const D: DWord): Boolean;
begin
  Result:= ( Self.Write(D, 4) = 4 );
end;

function TCFileStream.WriteBytes(Buff: Pointer; Size: Integer): Boolean;
begin
  if Assigned(Buff) then
    Result:= ( Self.Write(Buff^, Size) = Size )
  else
    Result:= false;
end;

function TCFileStream.ReadWord(Buff: Pointer): Boolean;
begin
  if Assigned(Buff) then
    Result:= ( Self.Read(Buff^, 2) = 2 )
  else
    Result:= false;
end;

function TCFileStream.ReadDWord(Buff: Pointer): Boolean;
begin
  if Assigned(Buff) then
    Result:= ( Self.Read(Buff^, 4) = 4 )
  else
    Result:= false;
end;

function TCFileStream.ReadBytes(Buff: Pointer; Size: Integer): Boolean;
begin
  if Assigned(Buff) then
    Result:= ( Self.Read(Buff^, Size) > 0 ) 
  else
    Result:= false;
end;

{TCFileStorage}
constructor TCFileStorage.Create;
begin
  FItems:= TList.Create;
end;

constructor TCFileStorage.CreateNew(const AName: AnsiString);
begin
  FStorage:= nil;
  FItems:= TList.Create;
  FName:= AName;
end;

procedure TCFileStorage.ClearItems;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    TCFileItem(FItems[I]).Destroy;

  FItems.Destroy;  
end;

destructor TCFileStorage.Destroy;
begin
  ClearItems;
  FStorage:= nil;
  inherited;
end;

procedure TCFileStorage.FillFromIStorage(const AStorage: IStorage);
var
  Enum: IEnumStatStg;
  StatStg: TStatStg;

  procedure ProcessStatStg(const StatStg: TStatStg);
  var
    NewStorage: TCFileStorage;
    NewStream: TCFileStream;
    Stg: IStorage;
    Stm: IStream;
  begin
    case StatStg.dwType of
      STGTY_STORAGE:
        begin
          NewStorage:= TCFileStorage.Create;
          NewStorage.FName:= AnsiString(StatStg.pwcsName);
          if FStorage.OpenStorage(StatStg.pwcsName, nil,
            STGM_READ or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
            nil, 0, Stg) <> S_OK then
              raise ECFileError.Create(ECFILE_OPEN_STORAGE);

          FItems.Add(Pointer(NewStorage));
          NewStorage.FillFromIStorage(Stg);
        end;
      STGTY_STREAM :
        begin
          NewStream:= TCFileStream.Create;
          NewStream.FName:= AnsiString(StatStg.pwcsName);
          if FStorage.OpenStream(StatStg.pwcsName, nil,
            STGM_READ or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
            0, Stm) <> S_OK then
              raise ECFileError.Create(ECFILE_OPEN_STREAM);
          NewStream.FStream:= Stm;
          FItems.Add(Pointer(NewStream));          
        end;
    end;
  end;

begin
  ClearItems;
  FItems:= TList.Create;
  FStorage:= AStorage;

  FStorage.EnumElements(0, nil, 0, Enum);
  if not Assigned(Enum) then
    Exit;

  try
    Enum.Reset;
    while Enum.Next(1, StatStg, nil) = S_OK do
    begin
      ProcessStatStg(StatStg);
      { Free allocated name }
      if Assigned(StatStg.pwcsName) then
        CoTaskMemFree(StatStg.pwcsName);
    end;
  finally
    Enum:= nil;
  end;
end;

function TCFileStorage.GetCount: Integer;
begin
  Result:= FItems.Count;
end;

function TCFileStorage.GetItem(I: Integer): TCFileItem;
begin
  Result:= TCFileItem(FItems[I]);
end;

function TCFileStorage.AddNewStorage(AName: AnsiString): TCFileStorage;
var
  W: array [0..NAME_BUFFER_SIZE - 1] of WideChar;
  NewStorage: IStorage;
begin
  FillChar(W, NAME_BUFFER_SIZE * SizeOf(WideChar) , 0);
  MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, @AName[1], Length(AName), @W[0], NAME_BUFFER_SIZE);

  if Self.FStorage.CreateStorage(W,
      STGM_READWRITE or STGM_CREATE or
      STGM_SHARE_EXCLUSIVE or STGM_DIRECT, 0, 0, NewStorage) <> S_OK then
    raise ECFileError.Create(ECFILE_CREATE_STORAGE);

  Result:= TCFileStorage.Create;
  Result.FStorage:= NewStorage;

  FItems.Add(Pointer(Result));
end;

function TCFileStorage.AddNewStream(AName: AnsiString): TCFileStream;
var
  W: array [0..NAME_BUFFER_SIZE - 1] of WideChar;
  NewStream: IStream;
begin
  FillChar(W, NAME_BUFFER_SIZE * SizeOf(WideChar) , 0);
  MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, @AName[1], Length(AName), @W[0], NAME_BUFFER_SIZE);

  if Self.FStorage.CreateStream(W,
      STGM_READWRITE or STGM_SHARE_EXCLUSIVE or
      STGM_DIRECT, 0, 0, NewStream) <> S_OK then
    raise ECFileError.Create(ECFILE_CREATE_STREAM);

  Result:= TCFileStream.Create;
  Result.FStream:= NewStream;
  
  FItems.Add(Pointer(Result));
end;

function TCFileStorage.FindItem(const AName: AnsiString): TCFileItem;
var
  I: Integer;
  S: AnsiString;
begin
  Result:= nil;
  for I:= 0 to FItems.Count - 1 do
  begin
    S:= TCFileItem(FItems[I]).Name;
    if (AnsiStringUpperCase(S) = AnsiStringUpperCase(AName)) then
    begin
      Result:= TCFileItem(FItems[I]);
      break;
    end;
  end;  
end;

procedure TCFileStorage.Commit;
begin
  if Assigned(FStorage) then
   if FStorage.Commit(STGC_DEFAULT) <> S_OK then
      raise ECFileError.Create(ECFILE_COMMIT_STORAGE);
end;

{TCFile}
constructor TCFile.Create(ACreateMode: TCFileCreateMode; const AFileName: WideString);
var
  W: array [0..MAX_PATH - 1] of WideChar;
  Stg: IStorage;
begin
  FillChar(W[0], SizeOf(W), 0);

  FName:= AFileName;
  if Length(FName) > 0 then
    Move(FName[1], W[0], Length(FName) * 2);

  FRoot:= TCFileStorage.Create;
  FRoot.FName:= 'Root Entry';

  FLockBytes:= nil;

  case ACreateMode of
    cfCreateNew:
      begin
        if StgCreateDocfile(
          @W,
          STGM_READWRITE or STGM_CREATE or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
          0,
          Stg
          ) <> S_OK then
          raise ECFileError.Create(ECFILE_CREATE_DOCFILE);

        FRoot.FStorage:= Stg;
      end;
    cfCreateNewInMemory:
      begin
        { create ILockBytes bytes array in memory }
        if CreateILockBytesOnHGlobal(0, True, FLockBytes) <> S_OK then
          raise ECFileError.Create(ECFILE_CREATE_DOCFILE);

        { create Docfile on ILockBytes }
        if StgCreateDocfileOnILockBytes(
          FLockBytes,
          STGM_READWRITE or STGM_CREATE or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
          0,
          Stg
          ) <> S_OK then
          raise ECFileError.Create(ECFILE_CREATE_DOCFILE);

        FRoot.FStorage:= Stg;
      end;
    cfCreateFromFile:
      begin
        if StgOpenStorage(
          @W,
          nil,
          STGM_READ or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
          nil,
          0,
          Stg
          ) <> S_OK then
          raise ECFileError.Create(ECFILE_OPEN_DOCFILE);

        {read data from storage}
        FRoot.FillFromIStorage(Stg);

        Stg:= nil;
      end;
  end;
end;

constructor TCFile.CreateFromStream(const AStream: TStream);
var
  Stg: IStorage;
begin
  FLockBytes:= nil;
  FRoot:= TCFileStorage.Create;
  FRoot.FName:= 'Root Entry';

  { create ILockBytes bytes array in memory }
  if CreateILockBytesOnHGlobal(0, True, FLockBytes) <> S_OK then
    raise ECFileError.Create(ECFILE_CREATE_DOCFILE);

  {Read data to LockBytes}
  ReadLockBytesFromStream(AStream);

  { open storage }
  if StgOpenStorageOnILockBytes(
       FLockBytes,
       nil,
       STGM_READ or STGM_SHARE_EXCLUSIVE or STGM_DIRECT,
       nil,
       0,
       Stg
     ) <> S_OK then
    raise ECFileError.Create(ECFILE_CREATE_DOCFILE);

  {read data from storage}
  FRoot.FillFromIStorage(Stg);
end;

destructor TCFile.Destroy;
begin
  FRoot.Destroy;
  FLockBytes:= nil;
  inherited;
end;

procedure TCFile.ReadLockBytesFromStream(const AStream: TStream);
var
  Offset, BytesRead, BytesWrite: Longint;
  Buff: AnsiString;
begin
  if Assigned(LockBytes) then
  begin
    Offset:= 0;
    AStream.Position:= 0;
    SetLength(Buff, DATA_BUFFER_SIZE);
    repeat
      { read data from stream }
      BytesRead:= AStream.Read(Buff[1], Length(Buff));

      { save to LockBytes }
      if BytesRead > 0 then
        LockBytes.WriteAt(Offset, @Buff[1], Length(Buff), @BytesWrite);

      Offset:= Offset + BytesRead;
    until BytesRead <= 0;

    LockBytes.Flush;
    SetLength(Buff, 0);
  end;
end;

procedure TCFile.SaveLockBytesToStream(const AStream: TStream);
var
  Offset, BytesRead: Longint;
  Buff: AnsiString;
begin
  if Assigned(LockBytes) then
  begin
    { Prepare data for saving to stream - commit the compound file }
    LockBytes.Flush;
    FRoot.Commit;
    Offset:= 0;
    SetLength(Buff, DATA_BUFFER_SIZE);
    repeat
      { read data from ILockBytes }
      LockBytes.ReadAt(Offset, @Buff[1], Length(Buff), @BytesRead);

      { save to stream }
      if BytesRead > 0 then
        AStream.WriteBuffer(Buff[1], BytesRead);

      Offset:= Offset + BytesRead;
    until BytesRead <= 0;

    SetLength(Buff, 0);
  end;
end;

end.
