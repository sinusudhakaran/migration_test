{*********************************************************}
{* BUFFSTRM.PAS                                          *}
{* Copyright (c) Julian M Bucknall 1997                  *}
{* All rights reserved.                                  *}
{*********************************************************}
{* Buffered Handle and File Stream                       *}
{*********************************************************}

{Note: this unit is released as freeware. In other words, you are free
       to use this unit in your own applications, however I retain all
       copyright to the code. JMB}


{MJCH 19Mar98 Remove 16bit Windows Code}

unit BufFStrm;

interface

uses
  SysUtils,
  Classes;

type
  TbhsMemSize = integer;

type
  TbhsBufferedHandleStream = class(TStream)
    protected {private}
      bhsPage      : PByteArray; {buffer}
      bhsPageSize  : TbhsMemSize;{size of buffer (multiple of 1K)}
      bhsPageStart : Longint;    {start of buffer as offset in stream}
      bhsPosInPage : TbhsMemSize;{current position in buffer}
      bhsByteCount : TbhsMemSize;{count of valid bytes in buffer}
      bhsSize      : Longint;    {count of bytes in stream}
      bhsHandle    : integer;    {handle of file}
      bhsDirty     : boolean;    {whether the buffer is dirty or not}
      bhsMustFlush : boolean;    {whether to flush on disk write}
    protected
      procedure bhsReadBuffer;
      procedure bhsWriteBuffer;
    public
      constructor Create(aHandle : integer; aBufSize : TbhsMemSize);
        {-create the buffered handle stream}
      destructor Destroy; override;
        {-destroy the buffered handle stream}

      function Read(var Buffer; Count : Longint) : Longint; override;
        {-read from the stream into a buffer}
      function Write(const Buffer; Count : Longint) : Longint; override;
        {-write to the stream from a buffer}
      function Seek(Offset : Longint; Origin : Word) : Longint; override;
        {-seek to a particular point in the stream}
      procedure Commit;
        {-ensures that all buffered data is flushed to disk}

      procedure SetSize(NewSize : Longint); reintroduce;
        {-set the stream size}

      property MustFlush : boolean
         read bhsMustFlush write bhsMustFlush;
        {-Whether to flush the file handle after a write operation}
  end;

type
  TbfsBufferedFileStream = class(TbhsBufferedHandleStream)
    protected {private}
      bfsFileName : string;
    public
      constructor Create(const aFileName : string;
                               aOpenMode : word;
                               aBufSize : TbhsMemSize);
        {-create the buffered file stream}
      destructor Destroy; override;
        {-destroy the buffered file stream}

      property FileName : string
        {-the name of the file on disk}
         read bfsFileName;
  end;

implementation

uses
  Windows;


{===Helper routines==================================================}
procedure RaiseException(const S : string);
begin
  raise Exception.Create(S);
end;
{--------}
procedure FileFlush(aHandle : integer);
begin
  if not FlushFileBuffers(aHandle) then
    RaiseException('BUFFSTRM.FileFlush: flush failed')
end;
{--------}
procedure FileTruncate(aHandle : integer; aOffset : Longint);
var
  SeekResult : Longint;
begin
  SeekResult := FileSeek(aHandle, aOffset, 0);
  if (SeekResult = -1) then
    RaiseException('BUFFSTRM.FileTruncate: seek failed');
  if not SetEndOfFile(aHandle) then
    RaiseException('BUFFSTRM.FileTruncate: set end of file failed')
end;
{====================================================================}


{===TbhsBufferedHandleStream=========================================}
constructor TbhsBufferedHandleStream.Create(aHandle  : integer;
                                            aBufSize : TbhsMemSize);
var
  ActBufSize : Longint;
begin
  inherited Create;
  {save the handle}
  bhsHandle := aHandle;
  {round up the buffer size to a multiple of 1K and a maximum of 32K}
  ActBufSize := (Longint(aBufSize) + 1023) and $FFFFFC00;
  if (ActBufSize > 32 * 1024) then
    bhsPageSize := 32 * 1024
  else
    bhsPageSize := ActBufSize;
  {create the buffer}
  GetMem(bhsPage, bhsPageSize);
  {set the page/buffer variables to the start of the stream}
  bhsPosInPage := 0;
  bhsByteCount := 0;
  bhsPageStart := 0;
  bhsDirty := false;
  bhsSize := FileSeek(aHandle, 0, soFromEnd);
  if (bhsSize = -1) then
    RaiseException('TbhsBufferedHandleStream.Create: seek EOF failed');
end;
{--------}
destructor TbhsBufferedHandleStream.Destroy;
begin
  {destroy the buffer, if need be after writing it to disk}
  if (bhsPage <> nil) then begin
    Commit;
    FreeMem(bhsPage, bhsPageSize);
  end;
  {let our ancestor clean up}
  inherited Destroy;
end;
{--------}
procedure TbhsBufferedHandleStream.bhsReadBuffer;
var
  SeekResult : Longint;
begin
  SeekResult := FileSeek(bhsHandle, bhsPageStart, 0);
  if (SeekResult = -1) then
    RaiseException('TbhsBufferedHandleStream.bhsReadBuffer: seek failed');
  bhsByteCount := FileRead(bhsHandle, bhsPage^, bhsPageSize);
  if (bhsByteCount <= 0) then
    RaiseException('TbhsBufferedHandleStream.bhsReadBuffer: read failed');
end;
{--------}
procedure TbhsBufferedHandleStream.bhsWriteBuffer;
var
  SeekResult : Longint;
  BytesWrit  : Longint;
begin
  SeekResult := FileSeek(bhsHandle, bhsPageStart, 0);
  if (SeekResult = -1) then
    RaiseException('TbhsBufferedHandleStream.bhsWriteBuffer: seek failed');
  BytesWrit := FileWrite(bhsHandle, bhsPage^, bhsByteCount);
  if (BytesWrit <> bhsByteCount) then
    RaiseException('TbhsBufferedHandleStream.bhsWriteBuffer: write failed');
  if MustFlush then
    FileFlush(bhsHandle);
end;
{--------}
procedure TbhsBufferedHandleStream.Commit;
begin
  if bhsDirty then begin
    bhsWriteBuffer;
    bhsDirty := false;
    FileFlush(bhsHandle);  {mjch move this inside as was calling for readonly as well}
  end;
end;
{--------}
function TbhsBufferedHandleStream.Read(var Buffer; Count : Longint) : Longint;
var
  BufAsBytes  : TByteArray absolute Buffer;
  BufInx      : Longint;
  BytesToGo   : Longint;
  BytesToRead : integer;
begin
  {$IFOPT R+}
      {$DEFINE RANGECHECKSON}
  {$ELSE}
      {$UNDEF RANGECHECKSON}
  {$ENDIF}

  {$R-} // Disable Range Checking so we can let Count exceed 32767

  {reading is complicated by the fact we can only read in chunks of
   bhsPageSize: we need to partition out the overall read into a
   read from part of the buffer, zero or more reads from complete
   buffers and then a possible read from part of a buffer}

  {calculate the actual number of bytes we can read - this depends on
   the current position and size of the stream as well as the number
   of bytes requested}
  BytesToGo := Count;
  if (bhsSize < (bhsPageStart + bhsPosInPage + Count)) then
    BytesToGo := bhsSize - (bhsPageStart + bhsPosInPage);
  if (BytesToGo <= 0) then begin
    Result := 0;
    Exit;
  end;
  {remember to return the result of our calculation}
  Result := BytesToGo;

  {initialise the byte index for the caller's buffer}
  BufInx := 0;
  {is there anything in the buffer? if not, go read something from
   the file on disk}
  if (bhsByteCount = 0) then
    bhsReadBuffer;
  {calculate the number of bytes we can read prior to the loop}
  BytesToRead := bhsByteCount - bhsPosInPage;
  if (BytesToRead > BytesToGo) then
    BytesToRead := BytesToGo;
  {copy from the stream buffer to the caller's buffer}
  Move(bhsPage^[bhsPosInPage], BufAsBytes[BufInx], BytesToRead);
  {calculate the number of bytes still to read}
  dec(BytesToGo, BytesToRead);

  {while we have bytes to read, read them}
  while (BytesToGo > 0) do begin
    {advance the byte index for the caller's buffer}
    inc(BufInx, BytesToRead);
    {as we've exhausted this buffer-full, advance to the next, check
     to see whether we need to write the buffer out first}
    if bhsDirty then begin
      bhsWriteBuffer;
      bhsDirty := false;
    end;
    inc(bhsPageStart, bhsPageSize);
    bhsPosInPage := 0;
    bhsReadBuffer;
    {calculate the number of bytes we can read in this cycle}
    BytesToRead := bhsByteCount;
    if (BytesToRead > BytesToGo) then
      BytesToRead := BytesToGo;
    {copy from the stream buffer to the caller's buffer}
    Move(bhsPage^, BufAsBytes[BufInx], BytesToRead);
    {calculate the number of bytes still to read}
    dec(BytesToGo, BytesToRead);
  end;
  {remember our new position}
  inc(bhsPosInPage, BytesToRead);
  if (bhsPosInPage = bhsPageSize) then begin
    inc(bhsPageStart, bhsPageSize);
    bhsPosInPage := 0;
    bhsByteCount := 0;
  end;

  {$IFDEF RANGECHECKSON}
      {$R+}
  {$ELSE}
      {$R-}
  {$ENDIF}
end;
{--------}
function TbhsBufferedHandleStream.Seek(Offset : Longint;
                                       Origin : Word) : Longint;
var
  NewPageStart : Longint;
  NewPos       : Longint;
begin
  {calculate the new position}
  case Origin of
    soFromBeginning : NewPos := Offset;
    soFromCurrent   : NewPos := bhsPageStart + bhsPosInPage + Offset;
    soFromEnd       : NewPos := bhsSize + Offset;
  else
    NewPos := 0;
    RaiseException('TbhsBufferedHandleStream.Seek: invalid origin');
  end;
  if (NewPos < 0) or (NewPos > bhsSize) then
    RaiseException('TbhsBufferedHandleStream.Seek: invalid new position');
  {calculate which page of the file we need to be at}
  NewPageStart := NewPos and not(pred(longint(bhsPageSize)));
  {if the new page is different than the old, mark the buffer as being
   ready to be replenished, and if need be write out any dirty data}
  if (NewPageStart <> bhsPageStart) then begin
    if bhsDirty then begin
      bhsWriteBuffer;
      bhsDirty := false;
    end;
    bhsPageStart := NewPageStart;
    bhsByteCount := 0;
  end;
  {save the new position}
  bhsPosInPage := NewPos - NewPageStart;
  Result := NewPos;
end;
{--------}
procedure TbhsBufferedHandleStream.SetSize(NewSize : Longint);
begin
  {save the new size and alter the position if required}
  bhsSize := NewSize;
  if ((bhsPageStart + bhsPosInPage) > NewSize) then
    Seek(0, soFromEnd);
  {now truncate/extend the file handle}
  FileTruncate(bhsHandle, NewSize);
end;
{--------}
function TbhsBufferedHandleStream.Write(const Buffer; Count : Longint) : Longint;
var
  BufAsBytes  : TByteArray absolute Buffer;
  BufInx      : Longint;
  BytesToGo   : Longint;
  BytesToWrite: integer;
begin
  {$IFOPT R+}
      {$DEFINE RANGECHECKSON}
  {$ELSE}
      {$UNDEF RANGECHECKSON}
  {$ENDIF}

  {$R-} // Disable Range Checking so we can let Count exceed 32767
  {writing is complicated by the fact we write in chunks of
   bhsPageSize: we need to partition out the overall write into a
   write from part of the buffer, zero or more writes from complete
   buffers and then a possible write from part of a buffer}

  {when we write to this stream we always assume that we can write the
   requested number of bytes: if we can't (eg, the disk is full) we'll
   get an exception somewhere eventually}
  BytesToGo := Count;
  {remember to return the result of our calculation}
  Result := BytesToGo;

  {initialise the byte index for the caller's buffer}
  BufInx := 0;
  {is there anything in the buffer? if not, go try read a block from
   the file on disk - we might be overwriting existing data rather
   than appending data to the end of the stream}
  if (bhsByteCount = 0) and (bhsSize > bhsPageStart) then
    bhsReadBuffer;
  {calculate the number of bytes we can write prior to the loop}
  BytesToWrite := bhsPageSize - bhsPosInPage;
  if (BytesToWrite > BytesToGo) then
    BytesToWrite := BytesToGo;
  {copy from the caller's buffer to the stream buffer}
  Move(BufAsBytes[BufInx], bhsPage^[bhsPosInPage], BytesToWrite);
  {mark the stream buffer as requiring a save to disk, note that this
   will suffice for the rest of the routine as well: no inner routine
   will turn off the dirty flag}
  bhsDirty := true;
  {calculate the number of bytes still to write}
  dec(BytesToGo, BytesToWrite);

  {while we have bytes to write, write them}
  while (BytesToGo > 0) do begin
    {advance the byte index for the caller's buffer}
    inc(BufInx, BytesToWrite);
    {as we've filled this buffer, write it out to disk and advance to
     the next buffer, reading it if required}
    bhsByteCount := bhsPageSize;
    bhsWriteBuffer;
    inc(bhsPageStart, bhsPageSize);
    bhsPosInPage := 0;
    bhsByteCount := 0;
    if (bhsSize > bhsPageStart) then
      bhsReadBuffer;
    {calculate the number of bytes we can write in this cycle}
    BytesToWrite := bhsPageSize;
    if (BytesToWrite > BytesToGo) then
      BytesToWrite := BytesToGo;
    {copy from the caller's buffer to the stream buffer}
    Move(BufAsBytes[BufInx], bhsPage^, BytesToWrite);
    {calculate the number of bytes still to write}
    dec(BytesToGo, BytesToWrite);
  end;
  {remember our new position}
  inc(bhsPosInPage, BytesToWrite);
  {make sure the count of valid bytes is correct}
  if (bhsByteCount < bhsPosInPage) then
    bhsByteCount := bhsPosInPage;
  {make sure the stream size is correct}
  if (bhsSize < (bhsPageStart + bhsByteCount)) then
    bhsSize := bhsPageStart + bhsByteCount;
  {if we're at the end of the buffer, write it out and advance to the
   start of the next page}
  if (bhsPosInPage = bhsPageSize) then begin
    bhsWriteBuffer;
    bhsDirty := false;
    inc(bhsPageStart, bhsPageSize);
    bhsPosInPage := 0;
    bhsByteCount := 0;
  end;
  {$IFDEF RANGECHECKSON}
      {$R+}
  {$ELSE}
      {$R-}
  {$ENDIF}
end;
{====================================================================}


{===TbfsBufferedFileStream===========================================}
constructor TbfsBufferedFileStream.Create(const aFileName : string;
                                                aOpenMode : word;
                                                aBufSize : TbhsMemSize);
var
  Handle : THandle;
begin
  if (aOpenMode = fmCreate) then begin
    Handle := FileCreate(aFileName);
    if (Handle <= 0) then
      RaiseException('TbfsBufferedFileStream.Create: cannot create file');
  end
  else begin
    Handle := FileOpen(aFileName, aOpenMode);
    if (Handle <= 0) then
      RaiseException('TbfsBufferedFileStream.Create: cannot open file');
  end;
  inherited Create(Handle, aBufSize);
  bfsFileName := ExpandFileName(aFileName);
end;
{--------}
destructor TbfsBufferedFileStream.Destroy;
begin
  inherited Destroy;
  if (bhsHandle > 0) then
    FileClose(bhsHandle);
end;
{====================================================================}

end.
