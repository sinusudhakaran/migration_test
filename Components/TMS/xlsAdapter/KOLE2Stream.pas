unit KOLE2Stream;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses SysUtils, Classes, KOLE2Import;

type
  TEnumOle2Open = (Ole2_Read, Ole2_Write);

  TMsOleDirInfo = record
    Name: Widestring;
    OleType: TMsOleType;
    Size: TMsOlePos;
  end;

  TMsOleDirInfoArray = Array of TMsOleDirInfo;

  TOle2Storage = class
  private
    Ffs: PMsOle;
    FMode: TEnumOle2Open;
    FPath: Widestring;
  public
    constructor Create(const AFileName: string; const aMode: TEnumOle2Open);
    destructor Destroy;override;

    procedure GetDirectories(var DirInfo: TMsOleDirInfoArray);
    procedure CdUp;
    procedure CdDown(const Dir: Widestring; const CreateIfNeeded: boolean);

    property Fs: PMsOle read Ffs;
    property Mode: TEnumOle2Open read FMode;
    property Path: Widestring read FPath write FPath;
  end;

  TOle2Stream = class (TStream)
  protected
    FStorage: TOle2Storage;
    FStream: PMsOleStream;
  public
    constructor Create(const AStorage: TOle2Storage; const StreamName: Widestring);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

  procedure OLE2Check(const Err: TMsOleErr);
implementation

resourcestring
  ErrLibOle2='Error in OLE file: ERR_%s';
  Txt_OLE_ERR_OK='OK';
  Txt_OLE_ERR_EXIST='EXIST';
  Txt_OLE_ERR_INVALID='INVALID';
  Txt_OLE_ERR_FORMAT='FORMAT';
  Txt_OLE_ERR_PERM='PERMISSIONS';
  Txt_OLE_ERR_MEM,='MEMORY';
  Txt_OLE_ERR_SPACE='SPACE';
  Txt_OLE_ERR_NOTEMPTY)='NOT EMPTY';
  Txt_OLE_ERR_BADARG='BAD ARGUMENT';

  TxtUndefined='UNDEFINED';

const
  ArrayErrTxt: array[TMsOleErr] of string= (
	Txt_OLE_ERR_OK,
	Txt_OLE_ERR_EXIST,
	Txt_OLE_ERR_INVALID,
	Txt_OLE_ERR_FORMAT,
	Txt_OLE_ERR_PERM,
	Txt_OLE_ERR_MEM,
	Txt_OLE_ERR_SPACE,
	Txt_OLE_ERR_NOTEMPTY,
	Txt_OLE_ERR_BADARG
  );

{ TOle2Storage }
procedure TOle2Storage.CdDown(const Dir: Widestring; const CreateIfNeeded: boolean);
begin
  //CreateIfNeeded not used with libole2
  if (Length(Path)>0) and (Path[Length(Path)]=PathDelim) then Path:=Path+Dir
    else Path:=Path+PathDelim+Dir;

end;

procedure TOle2Storage.CdUp;
begin
  Path:=copy(Path, 1, LastDelimiter(PathDelim,Path)-1);
  if Path='' then Path:=PathDelim;
end;

constructor TOle2Storage.Create(const AFileName: string; const aMode: TEnumOle2Open);
begin
  inherited Create;
  if aMode= Ole2_Write then OLE2Check(ms_ole_create(@Ffs, PCHAR(AFileName)))
  else
  if aMode= Ole2_Read then OLE2Check(ms_ole_open(@Ffs, PCHAR(AFileName)));

  Path:=PathDelim;
  FMode:=aMode;
end;

destructor TOle2Storage.Destroy;
begin
  if Ffs<>nil then ms_ole_destroy(@Ffs);
  inherited;
end;

procedure TOle2Storage.GetDirectories(var DirInfo: TMsOleDirInfoArray);
var
  DirStats: TMsOleStat;
  nPath: string;
  Names: PPChar;
  NamesArray: PPointerArray;
  i: integer;
begin
  nPath:=Path;
  OLE2Check(ms_ole_directory(@Names, Ffs, PCHAR(nPath)));
  NamesArray:=PPointerArray(Names);
  try
    SetLength(DirInfo,0);
    while NamesArray[Length(DirInfo)]<>nil do
    begin
      SetLength(DirInfo,Length(DirInfo)+1);
      DirInfo[Length(DirInfo)-1].Name:=PChar(NamesArray[Length(DirInfo)-1]);
      OLE2Check(ms_ole_stat(@(DirStats), Ffs, PCHAR(nPath), NamesArray[Length(DirInfo)-1]));
      DirInfo[Length(DirInfo)-1].OleType:=DirStats.OleType;
      DirInfo[Length(DirInfo)-1].Size:=DirStats.Size;
    end;
  finally
    i:=0;
    while NamesArray[i]<>nil do
    begin
      FreeMemory(NamesArray[i]);
      inc(i);
    end;
    FreeMemory(Names);
  end; //finally

end;


{ TOle2Stream }

constructor TOle2Stream.Create(const AStorage: TOle2Storage; const StreamName: Widestring);
var
  m:Char;
  nPath, nStreamName: string;
begin
  inherited Create;
  FStorage:= AStorage;
  nPath:=FStorage.Path;nStreamName:=StreamName;
  if Fstorage.Mode=Ole2_Read then m:= 'r' else m:='w';
  OLE2Check(ms_ole_stream_open(@FStream, FStorage.Fs, PCHAR(nPath), PCHAR(nStreamName), m));
end;

destructor TOle2Stream.Destroy;
begin
  if FStream<> nil then ms_ole_stream_close(@FStream);
  inherited;
end;

function TOle2Stream.Read(var Buffer; Count: Longint): Longint;
begin
  if FStream=nil then begin; Result:=0; exit; end;
  if FStream.read_copy( FStream, @Buffer, Count)<>0 then     //Here 0 is NIL = error
    Result := Count else Result := 0;
end;

function TOle2Stream.Write(const Buffer; Count: Longint): Longint;
begin
  if FStream=nil then begin; Result:=0; exit; end;
  if FStream.write( FStream, @Buffer, Count)<>0 then
    Result := Count else Result := 0;
end;

function TOle2Stream.Seek(Offset: Longint; Origin: Word): Longint;
var
  oleType: TMsOleSeek;
begin
  if FStream=nil then begin; Result:=-1; exit; end;
  case Origin of
    soFromBeginning: oleType:=MsOleSeekSet;
    soFromCurrent  : oleType:=MsOleSeekCur;
    soFromEnd      : oleType:=MsOleSeekEnd;
    else begin; Result:=-1; exit; end;
  end; //case

  Result:= FStream.lseek( FStream, Offset, oleType);
end;

procedure OLE2Check(const Err: TMsOleErr);
begin
  case Err of
	MS_OLE_ERR_OK: exit;
        
	MS_OLE_ERR_EXIST,
	MS_OLE_ERR_INVALID,
	MS_OLE_ERR_FORMAT,
	MS_OLE_ERR_PERM,
	MS_OLE_ERR_MEM,
	MS_OLE_ERR_SPACE,
	MS_OLE_ERR_NOTEMPTY,
	MS_OLE_ERR_BADARG: raise Exception.CreateFmt(ErrLibOle2, [ArrayErrTxt[Err]]);
        else raise Exception.CreateFmt(ErrLibOle2, [TxtUndefined]);
  end; //case;
end;



end.
