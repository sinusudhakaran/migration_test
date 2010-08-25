unit BiffStream;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    BIFF Stream Class

    Rev history:
    2004-02-03  Add: TBIFFStream.Size and TBIFFStream.Position added
    2008-03-04  Add: Read and write BIFF8 standard protected workbooks    

-----------------------------------------------------------------}

interface
{$I XLSFile.inc}

uses Classes, CFile, Streams, XLSProtect, XLSBase;

type
  {TBIFFRecord}
  TBIFFRecord = class
  protected
    FDataStream: TEasyStream;
  public
    RecNum: Integer;
    Size: Integer;
    constructor Create;
    destructor Destroy; override;
    property Data: TEasyStream read FDataStream;
  end;

  {TBIFFStream}
  TBIFFStream = class
  protected
    FCFileStream: TCFileStream;
    FBIFFRecord: TBIFFRecord;
    FBIFF8Encryption: Boolean;
    FBIFF8Digest: TMD5Digest;
    FBIFF8Key: TRC4Key;
    FBlockInProcess: Boolean;
    FBlockSize: Integer;
    FRawBlock: array[0..BIFF8_REKEY_BLOCK-1] of Byte;
    FCryptBlock: array[0..BIFF8_REKEY_BLOCK-1] of Byte;
    FMaskBlock: array[0..BIFF8_REKEY_BLOCK-1] of Byte;
    FBlockNum: Integer;
    FOffsetInBlock: Integer;
    function GetSize: Integer;
    function GetPosition: Integer;
    function ReadBlock: Boolean;
    procedure WriteBlock;
    procedure CryptBlock;
  public
    constructor Create(ACFileStream: TCFileStream);
    destructor Destroy; override;
    function ReadBIFFRecord: Boolean;
    procedure SetBIFF8Encryption(Digest: TMD5Digest);
    procedure SetBIFF8EncryptionForWrite(Digest: TMD5Digest);
    procedure WriteBIFFRecord;
    procedure WriteBIFFRecordFinal;
    procedure Reset;
    property BIFFRecord: TBIFFRecord read FBIFFRecord;
    property Size: Integer read GetSize;
    property Position: Integer read GetPosition;
  end;

implementation

{TBIFFRecord}
constructor TBIFFRecord.Create;
begin
  FDataStream:= TEasyStream.Create;
  RecNum:= 0;
  Size:= 0;
end;

destructor TBIFFRecord.Destroy;
begin
  FDataStream.Destroy;
  inherited;
end;

{TBIFFStream}
constructor TBIFFStream.Create(ACFileStream: TCFileStream);
begin
  FCFileStream:= ACFileStream;
  FBIFFRecord:= TBIFFRecord.Create;
  FBIFF8Encryption:= False;
  FBlockNum:= -1;
  FBlockSize:= SizeOf(FRawBlock);
  FOffsetInBlock:= 0;
  FBlockInProcess:= False;

  FillChar(FRawBlock[0], FBlockSize, 0);
  FillChar(FCryptBlock[0], FBlockSize, 0);
  FillChar(FMaskBlock[0], FBlockSize, 0);
end;

destructor TBIFFStream.Destroy;
begin
  FBIFFRecord.Destroy;
  inherited;
end;

function TBIFFStream.GetSize: Integer;
begin
  Result:= FCFileStream.Size;
end;

function TBIFFStream.GetPosition: Integer;
begin
  Result:= FCFileStream.Position;
end;

procedure TBIFFStream.SetBIFF8Encryption(Digest: TMD5Digest);
begin
  FBIFF8Digest:= Digest;
  FBIFF8Encryption:= True;
  { SetBIFF8Encryption called when a block reading already in progress. Crypt it here.}
  CryptBlock;
end;

procedure TBIFFStream.SetBIFF8EncryptionForWrite(Digest: TMD5Digest);
begin
  FBIFF8Digest:= Digest;
  FBIFF8Encryption:= True;
end;

function TBIFFStream.ReadBlock: Boolean;
begin
  FillChar(FRawBlock[0], SizeOf(FRawBlock), 0);
  Result:= FCFileStream.ReadBytes(@FRawBlock[0], SizeOf(FRawBlock));
  if not Result
    then Exit;

  FBlockNum:= FBlockNum + 1;
  FOffsetInBlock:= 0;
  if FBIFF8Encryption
    then CryptBlock;
end;

procedure TBIFFStream.WriteBlock;
var
  I: Integer;
begin
  FBlockNum:= FBlockNum + 1;

  if FBIFF8Encryption then
  begin
    { Crypt block }
    CryptBlock;
    
    { Write crypted block }
    for I:= 0 to SizeOf(FMaskBlock) - 1 do
      if (FMaskBlock[I] = 1) then
        FCryptBlock[I]:= FRawBlock[I];

    { Init next block }
    FOffsetInBlock:= 0;
    FCFileStream.WriteBytes(@FCryptBlock[0], FBlockSize);
    FillChar(FCryptBlock[0], FBlockSize, 0);
    FillChar(FMaskBlock[0], FBlockSize, 0);
  end
  else
    { Write raw block }
    FCFileStream.WriteBytes(@FRawBlock[0], FBlockSize);

  FillChar(FRawBlock[0], FBlockSize, 0);
end;

procedure TBIFFStream.CryptBlock;
begin
  BIFF8ProtectCryptBlock(@FRawBlock[0], @FCryptBlock[0], FBlockNum, FBIFF8Key, FBIFF8Digest);
end;

function TBIFFStream.ReadBIFFRecord: Boolean;
var
  BytesToRead, BytesRead: Integer;
  Buff: AnsiString;
  LBytesToRead: Integer;

  function ReadBuff(Crypted: Boolean): Boolean;
  begin
    Result:= False;
    Buff:= '';
    BytesRead:= 0;
    SetLength(Buff, BytesToRead);

    while (BytesRead < BytesToRead) do
    begin
      LBytesToRead:= BytesToRead - BytesRead;
      if (FOffsetInBlock + LBytesToRead > FBlockSize) then
        LBytesToRead:= FBlockSize - FOffsetInBlock;

      if (LBytesToRead > 0) then
        if Crypted then
          Move(FCryptBlock[FOffsetInBlock], Buff[BytesRead + 1], LBytesToRead)
        else
          Move(FRawBlock[FOffsetInBlock], Buff[BytesRead + 1], LBytesToRead);

      FOffsetInBlock:= FOffsetInBlock + LBytesToRead;
      BytesRead:= BytesRead + LBytesToRead;

      { Get next block }
      if (BytesRead < BytesToRead) then
      begin
        FBlockInProcess:= ReadBlock;
        if not FBlockInProcess then
          Exit;
      end;
    end;

    Result:= True;
  end;

begin
  Result:= False;

  if (not FBlockInProcess) or (FOffsetInBlock = FBlockSize) then
    FBlockInProcess:= ReadBlock;

  if not FBlockInProcess then
    Exit;

  { Read recnum }
  BytesToRead:= 2;
  if not ReadBuff(False) then
    Exit;
  Move(Buff[1], FBiffRecord.RecNum, BytesToRead);
  if (FBiffRecord.RecNum = 0) then Exit;

  { Read size }
  BytesToRead:= 2;
  if not ReadBuff(False) then
    Exit;
  Move(Buff[1], FBiffRecord.Size, BytesToRead);

  { Read data }
  BytesToRead:= FBiffRecord.Size;
  FBIFFRecord.Data.SetSize(FBiffRecord.Size);
  if (FBiffRecord.Size > 0) then
  begin
    if not ReadBuff(FBIFF8Encryption) then
      Exit;
    Move(Buff[1], FBIFFRecord.Data.Memory^, BytesToRead);
    FBIFFRecord.Data.Position:= 0;
  end;

  Result:= True; 
end;

procedure TBIFFStream.WriteBIFFRecord;
var
  BytesToWrite, LBytesToWrite, BytesWritten: Integer;
  Size: Word;
  Buff: AnsiString;

  procedure WriteBuff(Crypted: Boolean);
  begin
    BytesToWrite:= Length(Buff);
    BytesWritten:= 0;

    while ( BytesWritten < BytesToWrite) do
    begin
      LBytesToWrite:= BytesToWrite - BytesWritten;
      if (FOffsetInBlock + LBytesToWrite) > FBlockSize then
        LBytesToWrite:= FBlockSize - FOffsetInBlock;

      Move(Buff[BytesWritten + 1], FRawBlock[FOffsetInBlock], LBytesToWrite);
      if not Crypted then
        FillChar(FMaskBlock[FOffsetInBlock], LBytesToWrite, 1);

      BytesWritten:= BytesWritten + LBytesToWrite;
      FOffsetInBlock:= FOffsetInBlock + LBytesToWrite;

      { Next block }
      if (FOffsetInBlock = FBlockSize) or (BytesWritten < BytesToWrite) then
        WriteBlock;

    end;
  end;

begin
  SetLength(Buff, 2);
  Move(FBIFFRecord.RecNum, Buff[1], 2);
  WriteBuff(False);

  Size:= FBIFFRecord.Data.Size;
  Move(Size, Buff[1], 2);
  WriteBuff(False);

  if (Size > 0) then
  begin


    { Boundsheet record - do not encrypt 4 bytes }
    if (FBIFFRecord.RecNum = BIFF_BOUNDSHEET ) then
    begin
      SetLength(Buff, 4);
      Move(FBIFFRecord.Data.Memory^, Buff[1], 4);
      WriteBuff(False);

      SetLength(Buff, Size - 4);      
      Move((PAnsiChar(FBIFFRecord.Data.Memory) + 4)^, Buff[1], Size - 4);
      WriteBuff(FBIFF8Encryption);
    end
    else
    begin
      SetLength(Buff, Size);
      Move(FBIFFRecord.Data.Memory^, Buff[1], Size);
      WriteBuff(FBIFF8Encryption);
    end;
  end;
end;

procedure TBIFFStream.WriteBIFFRecordFinal;
begin
  { Flush last data block }
  if FOffsetInBlock > 0 then
    WriteBlock;
end;

procedure TBIFFStream.Reset;
begin
  FCFileStream.Position:= 0;
end;

end.
