unit WOLE2Stream;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

//  This is the windows unit for reading OLE-2 files.
// Uses IStream and IStorage

interface
uses Windows, SysUtils, Classes, ActiveX, ComObj, XlsMessages;

const
  OptionsReadStorage = STGM_DIRECT or STGM_SHARE_EXCLUSIVE or STGM_READ; //Storages should be opened in EXCLUSIVE MODE
  OptionsReadRoot = STGM_DIRECT or STGM_PRIORITY or STGM_READ;
  OptionsWrite = STGM_DIRECT or STGM_SHARE_EXCLUSIVE or STGM_WRITE;
  OptionsStreamWrite = STGM_DIRECT  or STGM_WRITE or STGM_SHARE_EXCLUSIVE or STGM_CREATE;
  OptionsStreamRead = STGM_DIRECT  or STGM_READ or STGM_SHARE_EXCLUSIVE;

  MsOleStreamT= STGTY_STREAM;
  MsOleStorageT= STGTY_STORAGE;

type
  TEnumOle2Open = (Ole2_Read, Ole2_Write);

  TMsOleDirInfo= record
    Name: WideString;
    OleType: integer;
    Size: int64;
  end;

  TIStorageArray= array of IStorage;

  TMsOleDirInfoArray = Array of TMsOleDirInfo;

  TOle2Storage = class
  private
    FMode: TEnumOle2Open;
    FStorage: IStorage;
    StorageList: TIStorageArray;

    SizeWritten: int64;

    FLockBytes: ILockBytes;
    HLockBytes: THandle;
    FStream: TStream;
  public
    constructor Create(const AFileName: string; const aMode: TEnumOle2Open; const aStream: TStream=nil);
    destructor Destroy;override;

    procedure GetDirectories(var DirInfo: TMsOleDirInfoArray);
    procedure CdUp;
    procedure CdDown(const Dir: Widestring; const CreateIfNeeded: boolean);

    property Storage: IStorage read FStorage;
    property Mode: TEnumOle2Open read FMode;

    procedure Commit;
    procedure CheckCommit(const Count: int64);
  end;

  //We avoid inheriting from TOLEStram so there are no issues with including axctrls and clx
  TOle2Stream = class (TStream)
  protected
    FStorage: TOle2Storage;
    FStream: IStream;
  public
    constructor Create(const AStorage: TOle2Storage; const StreamName: Widestring);
    function Write(const Buffer; Count: Longint): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

implementation

{ TOle2Storage }
procedure TOle2Storage.CdDown(const Dir: Widestring; const CreateIfNeeded: boolean);
begin
  SetLength(StorageList, Length(StorageList)+1);
  StorageList[Length(StorageList)-1]:=FStorage;
  if (FMode= Ole2_Write) then
    OleCheck(StorageList[Length(StorageList)-1].CreateStorage(PWideChar(Dir), OptionsWrite, 0, 0, FStorage))
  else
    OleCheck(StorageList[Length(StorageList)-1].OpenStorage(PWideChar(Dir), nil, OptionsReadStorage, nil, 0, FStorage));
end;
procedure TOle2Storage.CdUp;
begin
  FStorage:=StorageList[Length(StorageList)-1];
  SetLength(StorageList, Length(StorageList)-1);
end;

procedure TOle2Storage.CheckCommit(const Count: int64);
begin
  inc(SizeWritten, Count);
  if SizeWritten> 1024*1024 then
  begin
    Commit;
    Dec(SizeWritten, 1024* 1024);
  end;
end;

procedure TOle2Storage.Commit;
begin
  if FMode=Ole2_write then
    OleCheck(FStorage.Commit(STGC_DEFAULT));
end;

constructor TOle2Storage.Create(const AFileName: string; const aMode: TEnumOle2Open; const aStream: TStream=nil);
var
  WideFileName: Widestring;
  PLockBytes: pointer;
begin
  inherited Create;
  FStream:=aStream;
  if FStream<>nil then
  begin
    if aMode= Ole2_Write then
    begin
      OleCheck(CreateILockBytesOnHGlobal (0, True, FLockBytes));
      OleCheck(StgCreateDocfileOnILockBytes (FLockBytes, OptionsStreamWrite, 0, FStorage));
    end
    else if aMode= Ole2_Read then
    begin
      HLockBytes:=GlobalAlloc(GMEM_MOVEABLE	, aStream.Size);
      try
        PLockBytes:=GlobalLock(HLockBytes);
        try
          aStream.Position:=0;
          aStream.Read(PLockBytes^, aStream.Size);
        finally
          GlobalUnlock(HLockBytes);
        end; //finally
        OleCheck(CreateILockBytesOnHGlobal (HLockBytes , False, FLockBytes)); //It is not that I don't trust windows... but I prefer to do the cleanup myself. Seting second parameter to true should automatically releas mem, but memproof reports it as a leak.
      except
        GlobalFree(HLockBytes);
        HLockBytes:=0;
        raise;
      end; //except
       OleCheck(StgOpenStorageOnILockBytes (FLockBytes, nil, OptionsStreamRead, nil, 0, FStorage));
    end;
  end else
  begin
    WideFileName:=AFileName;
    if aMode= Ole2_Write then
      OleCheck(StgCreateDocfile(PWideChar(WideFileName), OptionsWrite, 0, FStorage))

    else if aMode= Ole2_Read then
    begin
      if StgIsStorageFile(PWideChar(WideFileName)) <> S_OK then
        raise Exception.CreateFmt(ErrFileIsNotXLS, [WideFileName]);

      OleCheck(StgOpenStorage(PWideChar(WideFileName), nil, OptionsReadRoot, nil, 0, FStorage));
    end;
  end;
  FMode:=aMode;
  SetLength(StorageList,0);
end;

destructor TOle2Storage.Destroy;
var
  DataHandle: HGlobal;
  Buffer: Pointer;
begin
  try
    if HLockBytes<>0 then GlobalFree(HLockBytes); //See comment above on why I release this here
    HLockBytes:=0;
    if FMode=Ole2_write then
    begin
      OleCheck(FStorage.Commit(STGC_DEFAULT));

      if FLockBytes<>nil then  //file streams are closed automatically
      begin
        OleCheck(GetHGlobalFromILockBytes(FLockBytes, DataHandle));
        Buffer := GlobalLock(DataHandle);
        try
          FStream.WriteBuffer(Buffer^, GlobalSize(DataHandle));
        finally
          GlobalUnlock(DataHandle);
        end;
      end;
    end;
  finally
    inherited;
  end; //finally
end;

procedure TOle2Storage.GetDirectories(var DirInfo: TMsOleDirInfoArray);
var
  Enum: IEnumStatStg;
  NumFetched: integer;
  StatStg: TStatStg;
  Malloc: IMalloc;

begin
  SetLength(DirInfo, 0);
  OleCheck(CoGetMalloc(1, Malloc));
  if FStorage.EnumElements(0, nil, 0, Enum) <> S_OK then
  begin
    FStorage.Stat(StatStg, 0);
    try
      raise Exception.CreateFmt(ErrCantReadFile, [StatStg.pwcsName]);
    finally
      Malloc.Free(StatStg.pwcsName);
    end; //finally
  end;

  while Enum.Next(1, StatStg, @NumFetched) = S_OK do
  begin
    try
      SetLength(DirInfo, Length(DirInfo)+1);
      DirInfo[Length(DirInfo)-1].Name:= StatStg.pwcsName;
      DirInfo[Length(DirInfo)-1].OleType:= StatStg.dwType;
      DirInfo[Length(DirInfo)-1].Size:= StatStg.cbSize;
    finally
       Malloc.Free(StatStg.pwcsName);
    end; //finally
  end; //while
end;

{ TOle2Stream }

constructor TOle2Stream.Create(const AStorage: TOle2Storage; const StreamName: Widestring);
var
  aStream: IStream;
  r: HResult;
begin
  if AStorage.Mode=Ole2_Read then
  begin
    r:=AStorage.Storage.OpenStream( PWideChar(StreamName), nil, OptionsReadStorage, 0, aStream);
    if r=-2147287038 then raise Exception.Create(ErrExcelInvalid);   //To avoid "%1 not found" error.
    OleCheck(r);
  end
  else
    OleCheck(AStorage.Storage.CreateStream( PWideChar(StreamName), OptionsWrite, 0, 0, aStream));

  inherited Create;
  FStream:=aStream;
  FStorage:= AStorage;
end;


function TOle2Stream.Read(var Buffer; Count: Integer): Longint;
begin
  //This is a fix for W98 raising an error when Count=0 and Buffer=nil.
  if Count=0 then
      Result:=0
  else OleCheck(FStream.Read(@Buffer, Count, @Result));
end;

function TOle2Stream.Write(const Buffer; Count: Integer): Longint;
begin
  OleCheck(FStream.Write(@Buffer, Count, @Result));
  if FStorage<>nil then FStorage.CheckCommit(Count);
end;

function TOle2Stream.Seek(Offset: Longint; Origin: Word): Longint;
var
  Pos: Largeint;
begin
  OleCheck(FStream.Seek(Offset, Origin, Pos));
  Result := Longint(Pos);
end;


end.
