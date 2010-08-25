unit KGsfStream;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{*$DEFINE GSFSTREAMCACHE}

interface
uses SysUtils, Classes, KGsfImport, KGlibImport;

type
  TEnumOle2Open = (Ole2_Read, Ole2_Write);

  TMsOleType = (
    MsOleStorageT = 1,
    MsOleStreamT  = 2,
    MsOleRootT    = 5
  );
  TMsOlePos = guint32;

  TMsOleDirInfo = record
    Name: Widestring;
    OleType: TMsOleType;
    Size: TMsOlePos;
  end;

  TMsOleDirInfoArray = Array of TMsOleDirInfo;

  TStorageList = class(TList)
  protected
    Mode: TEnumOle2Open;
    constructor Create(const aMode: TEnumOle2Open);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

  TOle2Storage = class
  private
    FStorages: TStorageList;
    FMode: TEnumOle2Open;
    FOutStream: TStream;
    MainFile: pointer;

    function GetActiveStorage: pointer;
  published
    xmldummy: TXmlLoader; //This is to load libxml2...
  public
    constructor Create(const AFileName: string; const aMode: TEnumOle2Open; const aOutStream: TStream=nil);
    destructor Destroy;override;

    procedure GetDirectories(var DirInfo: TMsOleDirInfoArray);
    procedure CdUp;
    procedure CdDown(const Dir: Widestring; const CreateIfNeeded: boolean);

    property Mode: TEnumOle2Open read FMode;
    property ActiveStorage: pointer read GetActiveStorage;
  end;

{$IFDEF GSFSTREAMCACHE}
  TOle2Stream = class (TMemoryStream)
{$ELSE}
  TOle2Stream = class (TStream)
{$ENDIF}
  protected
    FStorage: TOle2Storage;
    FStream: Pointer;
  public
    constructor Create(const AStorage: TOle2Storage; const StreamName: Widestring);
    destructor Destroy; override;
{$IFNDEF GSFSTREAMCACHE}
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
{$ENDIF}
  end;


implementation
resourcestring
  ErrCantopenStream='Can''t open stream %s';
  ErrCantReadOutStream='Can''t read in an output stream';
  ErrCantWriteInStream='Can''t write in an input stream';
  ErrReadingStream='Error Reading Stream';

{ TOle2Storage }

procedure TOle2Storage.CdDown(const Dir: Widestring;
  const CreateIfNeeded: boolean);
var
  s:string;
begin
  s:=dir;
  if FMode=Ole2_Write then FStorages.Add(gsf_outfile_new_child(ActiveStorage, PChar(s),true))
  else FStorages.Add(gsf_infile_child_by_name(ActiveStorage, PChar(s)))
end;

procedure TOle2Storage.CdUp;
begin
  if FStorages.Count>0 then FStorages.Delete(FStorages.Count-1);
end;

constructor TOle2Storage.Create(const AFileName: string;
  const aMode: TEnumOle2Open; const aOutStream: TStream=nil);
var
  Err: PGError;
  MemBuff: pointer;
  BuffSize: int64;
  s:string;
begin
  //MADE: Save to streams.
  inherited Create;
  FOutStream:=aOutStream;
  Err:=nil;
  FStorages:= TStorageList.Create(aMode);

  if aMode= Ole2_Write then
  begin
    if FOutStream<>nil then
      MainFile:=gsf_output_memory_new
    else MainFile:=gsf_output_stdio_new(PCHAR(AFileName),@Err);

    if Err=nil then
    begin
      FStorages.Add(gsf_outfile_msole_new(MainFile));
    end;
  end else
  begin
    if FOutStream<>nil then
    begin
      BuffSize:=FOutStream.Size- FOutStream.Position;
      MemBuff:=g_malloc(BuffSize);
      FOutStream.Read( MemBuff^ , BuffSize);
      MainFile:=gsf_input_memory_new( MemBuff, BuffSize, true);
    end
    else MainFile:=gsf_input_stdio_new(PCHAR(AFileName),@Err);
    if Err=nil then
    begin
      FStorages.Add(gsf_infile_msole_new(MainFile, @Err));
    end;
  end;

  if Err<>nil then
  begin
    s:= Err^.message;
    g_error_free(Err);
    raise Exception.Create(s);
  end;
  FMode:=aMode;
end;

destructor TOle2Storage.Destroy;
begin
  FreeAndNil(FStorages);

  //After all has been flushed...
  if (FMode=Ole2_Write) and (FOutStream<>nil) and (MainFile<>nil) then
  begin
    FOutStream.WriteBuffer(gsf_output_memory_get_bytes(MainFile)^, gsf_output_size(MainFile));
  end;

   if (MainFile<>nil) and (FMode=Ole2_Write) and
   (not gsf_output_is_closed(MainFile)) then
     gsf_output_close(MainFile);

  if MainFile<>nil then g_object_unref(MainFile);
  inherited;
end;

function TOle2Storage.GetActiveStorage: pointer;
begin
  if FStorages.Count>0 then Result:= FStorages[FStorages.Count-1] else Result:=nil;
end;

procedure TOle2Storage.GetDirectories(var DirInfo: TMsOleDirInfoArray);
var
  i: integer;
  NewS: pointer;
begin
  SetLength(DirInfo,0);
  if (FMode<>Ole2_Read) or (FStorages.Count=0) then exit;
  i:=gsf_infile_num_children(ActiveStorage);
  if i<0 then exit;
  SetLength(DirInfo, i);
  for i:=0 to Length(DirInfo)-1 do
  begin
    DirInfo[i].Name:=gsf_infile_name_by_index(ActiveStorage, i);
    DirInfo[i].Size:=gsf_input_size(ActiveStorage);

    NewS:=gsf_infile_child_by_index(ActiveStorage, i);
    try
      if gsf_infile_num_children(NewS)>=0 then
        DirInfo[i].OleType:=MsOleStorageT else DirInfo[i].OleType:=MsOleStreamT;
    finally
      g_object_unref(NewS);
    end; //finally
  end;
end;

{ TStorageList }

constructor TStorageList.Create(const aMode: TEnumOle2Open);
begin
  inherited Create;
  Mode:=aMode;
end;

procedure TStorageList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then if Ptr<>nil then
  begin
    if (Mode=Ole2_Write) and (not gsf_output_is_closed(Ptr))then
      gsf_output_close(Ptr);
    g_object_unref(Ptr);
  end;

  inherited;
end;

{ TOle2Stream }

constructor TOle2Stream.Create(const AStorage: TOle2Storage;
  const StreamName: Widestring);
var
  s: string;
begin
  inherited Create;
  s:= StreamName;
  FStorage:= AStorage;
  if FStorage.FMode= Ole2_Write then
    FStream:=gsf_outfile_new_child(FStorage.ActiveStorage, PChar(s), false)
  else
    FStream:=gsf_infile_child_by_name(FStorage.ActiveStorage, PChar(s));

  if FStream=nil then raise Exception.CreateFmt(ErrCantOpenStream,[s]);

{$IFDEF GSFSTREAMCACHE}
  if FStorage.FMode=Ole2_Read then
  begin
    Self.Size:= gsf_input_size(FStream);
    if not gsf_input_Read(FStream, Self.Size, Self.Memory) then Raise Exception.Create(ErrReadingStream);
    Self.Position:=0;
  end;
{$ENDIF}
end;

destructor TOle2Stream.Destroy;
begin
  if FStream<>nil then
  begin
    if Fstorage.FMode=Ole2_Write then
    begin
{$IFDEF GSFSTREAMCACHE}
      Self.Position:=0;
      gsf_output_write(FStream, Self.Size, Self.Memory);
{$ENDIF}
      if not gsf_output_is_closed(FStream) then
        gsf_output_close(FStream);
    end;
    g_object_unref(FStream);
  end;
  inherited;
end;

{$IFNDEF GSFSTREAMCACHE}
function TOle2Stream.Read(var Buffer; Count: Integer): Longint;
var
  ok: boolean;
begin
  if FStorage.FMode= Ole2_Write then raise Exception.Create(ErrCantReadOutStream);
  ok:=gsf_input_read(FStream, Count, @Buffer);
  if not ok then Result:=0 else Result:=Count;

end;

function TOle2Stream.Seek(Offset: Integer; Origin: Word): Longint;
var
  ok: gboolean;
  Whence: GSeekType;
begin
  case Origin of
    soFromBeginning: Whence:=G_SEEK_SET;
    soFromCurrent  : Whence:=G_SEEK_CUR;
    soFromEnd      : Whence:=G_SEEK_END;
    else begin; Result:=-1; exit; end;
  end; //case

  if FStorage.FMode= Ole2_Write then
  begin
    ok:=gsf_output_seek(FStream, Offset, Whence);
    if not ok then Result:=-1 else Result:=gsf_output_tell(FStream);
  end else
  begin
    ok:=gsf_input_seek(FStream, Offset, Whence);
    if  ok then Result:=-1 else Result:=gsf_input_tell(FStream); //This works the other way around!!!!! it is "if ok" !!
  end;
end;

function TOle2Stream.Write(const Buffer; Count: Integer): Longint;
var
  ok: boolean;
begin
  if FStorage.FMode= Ole2_Read then raise Exception.Create(ErrCantWriteInStream);
  ok:=gsf_output_write(FStream, Count, @Buffer);
  if not ok then Result:=0 else Result:=Count;
end;
{$ENDIF}

initialization
  gsf_init;
finalization
  gsf_shutdown;
end.
