unit CRCFileUtils;
//------------------------------------------------------------------------------
{
   Title:       CRC File Utils

   Description: Utility routines for checking and embeding crc values in files

   Remarks:

   Author:      Matthew Hopkins  Jul 2001

   Updated 03/12/2001 Steve to work on ReadOnly files so we can check in the
          sample clients from the CD.
           18/12/2001 Steve to make sure we have enough inforrmation to diagnose
          errors.
}
//------------------------------------------------------------------------------

interface
uses
  Classes,
  SysUtils;

type
  ECRCFileOpen = class(Exception);
  ECRCCheckFailed = class(Exception);

function CalculateCRC( Const FileName : String ): LongWord; overload;
function CalculateCRC( Const aStream : TStream ): LongWord; overload;

procedure CheckEmbeddedCRC( Const FileName : String ); overload;
procedure CheckEmbeddedCRC( Stream : TStream ); overload;

procedure EmbedCRC( const FileName : string ); overload;
procedure EmbedCRC( Stream : TStream ); overload;

//******************************************************************************
implementation
uses
   Windows,
   crc32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function CalculateCRC( Const FileName : String ): LongWord;

Const
  ChunkSize = 8192;
  SCRCFOpenError = 'CRCFileUtils.CalculateCRC: Error %d opening file %s';
var
  NumRead  : Integer;
  CRC      : LongWord;
  Source   : Integer; { Handle }
  Buffer   : Pointer;
Begin
  CRC := 0;
  GetMem( Buffer, ChunkSize );
  Try
    Source := FileOpen( FileName, fmOpenRead or fmShareDenyWrite);
    If Source < 0 Then Raise ECRCFileOpen.CreateFmt( SCRCFOpenError, [ Windows.GetLastError, FileName ] );
    Try
      Repeat
        NumRead := FileRead( Source, Buffer^, ChunkSize );
        If NumRead > 0 Then UpdateCRC( CRC, Buffer^, NumRead );
      Until NumRead < ChunkSize;
    Finally
      FileClose(Source)
    End;
  Finally
    FreeMem( Buffer, ChunkSize );
  end;
  Result := CRC;
end;



function CalculateCRC( Const aStream : TStream ): LongWord;
Const
  ChunkSize = 8192;
var
  Buffer  : Pointer;
  CRCInfo : ^LongInt absolute Buffer;
  NumRead : Integer;
  CRC     : LongWord;
begin
  CRC := 0;
  GetMem( Buffer, ChunkSize );
  try
    aStream.Position := 0;
    NumRead := aStream.Read( Buffer^, ChunkSize );
    CRCInfo^ := 0;
    if NumRead > 0 then UpdateCRC( CRC, Buffer^, NumRead );
    repeat
      NumRead := aStream.Read( Buffer^, ChunkSize );
      if NumRead > 0 then UpdateCRC( CRC, Buffer^, NumRead );
    until NumRead < ChunkSize;
  finally
    FreeMem( Buffer, ChunkSize );
  end;
  result := CRC;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CheckEmbeddedCRC( Const FileName : String );

Const
  ChunkSize = 8192;
  SCRCFOpenError = 'CRCFileUtils.CheckEmbeddedCRC: Error %d opening file %s';
  SCRCError      = 'CRCFileUtils.CheckEmbeddedCRC: Invalid CRC in %s, Old CRC = %d, New CRC = %d';
var
  Buffer     : Pointer;
  CRCInfo    : ^LongWord Absolute Buffer;
  Source     : Integer; { Handle }
  NumRead    : Integer; // Also LastError
  OldCRC     : LongWord;
  NewCRC     : LongWord;

  function OpenFailed : Boolean;
  var lc : integer;
  begin
     Result := true;
     lc := 0;
     repeat
       Source := FileOpen( FileName, fmOpenRead );
       if Source < 0 then begin
          NumRead := windows.GetLastError;
          if NumRead = ERROR_SHARING_VIOLATION then begin
             // Wait for explorer
             // See Case 5498
             inc (lc);
             if Lc > 5  then exit;
             sleep(20);
          end; // else, just fail
       end else result := false;
     until not Result;
  end;

Begin
  NewCRC   := 0;
  GetMem( Buffer, ChunkSize );
  Try
    if OpenFailed  then Raise ECRCFileOpen.CreateFmt( SCRCFOpenError, [ numread, FileName ] );
    Try
      NumRead  := FileRead( Source, Buffer^, ChunkSize );
      OldCRC   := CRCInfo^;
      CRCInfo^ := 0;
      If NumRead > 0 Then UpdateCRC( NewCRC, Buffer^, NumRead );
      Repeat
        NumRead := FileRead( Source, Buffer^, ChunkSize );
        If NumRead > 0 Then UpdateCRC( NewCRC, Buffer^, NumRead );
      Until NumRead < ChunkSize;
      if not ( OldCRC = NewCRC ) then
        Raise ECRCCheckFailed.CreateFmt( SCRCError, [ FileName, OldCRC, NewCRC ] );
    Finally
       FileClose(Source)
    End;
  Finally
    FreeMem( Buffer, ChunkSize );
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure EmbedCRC( Const FileName : String );
Const
  ChunkSize = 8192;
  SCRCFOpenError = 'CRCFileUtils.EmbedCRC: Error %d opening file %s';
var
  Buffer     : Pointer;
  CRCInfo    : ^LongWord Absolute Buffer;
  Source     : Integer; { Handle }
  NumRead    : Integer;
  CRC        : LongWord;
Begin
  CRC := 0;
  GetMem( Buffer, ChunkSize );
  Try
    Source := FileOpen( FileName, fmOpenReadWrite );
    If Source < 0 Then Raise ECRCFileOpen.CreateFmt( SCRCFOpenError, [ Windows.GetLastError, FileName ] );
    Try
      NumRead := FileRead( Source, Buffer^, ChunkSize );
      CRCInfo^ := 0;
      If NumRead > 0 Then UpdateCRC( CRC, Buffer^, NumRead );
      Repeat
        NumRead := FileRead( Source, Buffer^, ChunkSize );
        If NumRead > 0 Then UpdateCRC( CRC, Buffer^, NumRead );
      Until NumRead < ChunkSize;
      FileSeek( Source, 0, 0 ); // Go to the start of the file.
      FileWrite( Source, CRC, Sizeof( CRC ) );
    Finally
      FileClose(Source)
    End;
  Finally
    FreeMem( Buffer, ChunkSize );
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckEmbeddedCRC( Stream : TStream );
const
  ChunkSize = 8192;
  SCRCError = 'CRCFileUtils.CheckEmbeddedCRC: Invalid CRC in Stream, Old CRC = %d, New CRC = %d';
var
  Buffer : Pointer;
  CRCInfo : ^LongInt absolute Buffer;
  NumRead : Integer;
  OldCRC  : integer;
  NewCRC  : integer;
begin
  NewCRC := 0;
  GetMem( Buffer, ChunkSize );
  try
    Stream.Position := 0;
    NumRead := Stream.Read( Buffer^, ChunkSize );
    OldCRC := CRCInfo^;
    CRCInfo^ := 0;
    if NumRead > 0 then UpdateCRC( NewCRC, Buffer^, NumRead );
    repeat
      NumRead := Stream.Read( Buffer^, ChunkSize );
      if NumRead > 0 then UpdateCRC( NewCRC, Buffer^, NumRead );
    until NumRead < ChunkSize;
    if not ( OldCRC = NewCRC ) then
      raise ECRCCheckFailed.CreateFmt( SCRCError, [ OldCRC, NewCRC ] );
  finally
    FreeMem( Buffer, ChunkSize );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure EmbedCRC( Stream : TStream ); Overload;
const
  ChunkSize = 8192;
var
  Buffer  : Pointer;
  CRCInfo : ^LongInt absolute Buffer;
  NumRead : Integer;
  CRC     : LongInt;
begin
  CRC := 0;
  GetMem( Buffer, ChunkSize );
  try
    Stream.Position := 0;
    NumRead := Stream.Read( Buffer^, ChunkSize );
    CRCInfo^ := 0;
    if NumRead > 0 then UpdateCRC( CRC, Buffer^, NumRead );
    repeat
      NumRead := Stream.Read( Buffer^, ChunkSize );
      if NumRead > 0 then UpdateCRC( CRC, Buffer^, NumRead );
    until NumRead < ChunkSize;
    Stream.Position := 0;
    Stream.Write( CRC, Sizeof( CRC ) );
  finally
    FreeMem( Buffer, ChunkSize );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
