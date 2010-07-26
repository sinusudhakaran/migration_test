{ The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  The Original Code is DIMimeStreams.pas.

  The Initial Developer of the Original Code is Ralf Junker <delphi@zeitungsjunge.de>.

  All Rights Reserved. }

{ ---------------------------------------------------------------------------- }

{ @abstract(Wrapper function to Mime-encode and decode streams and files.)
  @Author(Ralf Junker <delphi@zeitungsjunge.de>) }

unit DIMimeStreams;

interface

{$I DI.inc}

uses
  Classes;

{ Mime-encodes a file and saves it as another file. }
procedure MimeEncodeFile(const InputFileName, OutputFileName: AnsiString);

{ Mime-encodes a file and saves it as another file. }
procedure MimeEncodeFileNoCRLF(const InputFileName, OutputFileName: AnsiString);

{ Mime-decodes a file and saves it as another file. }
procedure MimeDecodeFile(const InputFileName, OutputFileName: AnsiString);

{ @abstract(Mime-encodes a stream.)
  @Name encodes InputStream <b>with</b> inserting line breaks.
  Encoding starts at the InputStream's current position and continues until the end.
  Decoded output is written to OutputStream, again starting at the current position.
  When done, @Name will not reset either stream's positions,
  but leave InputStream at the last read position (i.e. the end) and
  OutputStream at the last write position (which can, but most not be the end).
  To encode the entire InputStream from beginning to end, make sure
  that its offset is positioned at the beginning of the stream. You can
  force this by issuing
  <P>@code(InputStream.Seek (0, soFromBeginning);)
  <P>before calling this function. }
procedure MimeEncodeStream(const InputStream: TStream; const OutputStream: TStream);

{ @abstract(Mime-encodes a stream.)
  @Name is just like @link(MimeEncodeStream), but does <B>not</B> insert line breaks. }
procedure MimeEncodeStreamNoCRLF(const InputStream: TStream; const OutputStream: TStream);

{ @abstract(Mime-decodes a stream.)
  @Name decodes InputStream starting at the current position
  up to the end and writes the result to OutputStream, again starting at
  the current position. When done, it will not reset either stream's positions,
  but leave InputStream at the last read position (i.e. the end) and
  OutputStream at the last write position (which can, but most not be the end).
  To decode the entire InputStream from beginning to end, make sure
  that its offset is positioned at the beginning of the stream. You can
  force this by issuing @code(Seek (0, soFromBeginning)) before calling this function. }
procedure MimeDecodeStream(const InputStream: TStream; const OutputStream: TStream);

implementation

uses
  SysUtils,

  DIMime;

const
  { The formula of @Name is explained by the needs of @link(MimeEncodeStream)
    and all other kinds of buffered Mime encodings (i.e. Files etc.).
    @link(MimeEncodeFullLines) only works if InputByteCount is a multiple of
    @link(MIME_DECODED_LINE_BREAK). For @link(MimeEncodeNoCRLF) InputByteCount
    must be a multiple of 3 if used repeatedly, like in
    @link(MimeEncodeStreamNoCRLF). In addition, a multiple of 4 makes sure
    memory is properly aligned. The last factor 4 just enlarges @Name to a
    reasonable value. }
  MIME_BUFFER_SIZE = MIME_DECODED_LINE_BREAK * 3 * 4 * 4;

  { ---------------------------------------------------------------------------- }
  { File Encoding & Decoding
  { ---------------------------------------------------------------------------- }

procedure MimeEncodeFile(const InputFileName, OutputFileName: AnsiString);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeEncodeStream(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

{ ---------- }

procedure MimeEncodeFileNoCRLF(const InputFileName, OutputFileName: AnsiString);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeEncodeStreamNoCRLF(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

{ ---------- }

procedure MimeDecodeFile(const InputFileName, OutputFileName: AnsiString);
var
  InputStream, OutputStream: TFileStream;
begin
  InputStream := TFileStream.Create(InputFileName, fmOpenRead or fmShareDenyWrite);
  try
    OutputStream := TFileStream.Create(OutputFileName, fmCreate);
    try
      MimeDecodeStream(InputStream, OutputStream);
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

{ ---------------------------------------------------------------------------- }
{ Stream Encoding & Decoding
{ ---------------------------------------------------------------------------- }

procedure MimeEncodeStream(const InputStream: TStream; const OutputStream: TStream);
var
  InputBuffer: array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: array[0..(MIME_BUFFER_SIZE + 2) div 3 * 4 + MIME_BUFFER_SIZE div MIME_DECODED_LINE_BREAK * 2 - 1] of Byte;
  BytesRead: Cardinal;
  IDelta, ODelta: Cardinal;
begin
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));

  while BytesRead = SizeOf(InputBuffer) do
    begin
      MimeEncodeFullLines(InputBuffer, SizeOf(InputBuffer), OutputBuffer);
      OutputStream.Write(OutputBuffer, SizeOf(OutputBuffer));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;

  MimeEncodeFullLines(InputBuffer, BytesRead, OutputBuffer);

  IDelta := BytesRead div MIME_DECODED_LINE_BREAK; // Number of lines processed.
  ODelta := IDelta * (MIME_ENCODED_LINE_BREAK + 2);
  IDelta := IDelta * MIME_DECODED_LINE_BREAK;
  MimeEncodeNoCRLF(Pointer(Cardinal(@InputBuffer) + IDelta)^, BytesRead - IDelta, Pointer(Cardinal(@OutputBuffer) + ODelta)^);

  OutputStream.Write(OutputBuffer, MimeEncodedSize(BytesRead));
end;

{ ---------- }

procedure MimeEncodeStreamNoCRLF(const InputStream: TStream; const OutputStream: TStream);
var
  InputBuffer: array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: array[0..((MIME_BUFFER_SIZE + 2) div 3) * 4 - 1] of Byte;
  BytesRead: Cardinal;
begin
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
  while BytesRead = SizeOf(InputBuffer) do
    begin
      MimeEncodeNoCRLF(InputBuffer, SizeOf(InputBuffer), OutputBuffer);
      OutputStream.Write(OutputBuffer, SizeOf(OutputBuffer));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;

  MimeEncodeNoCRLF(InputBuffer, BytesRead, OutputBuffer);
  OutputStream.Write(OutputBuffer, MimeEncodedSizeNoCRLF(BytesRead));
end;

{ ---------- }

procedure MimeDecodeStream(const InputStream: TStream; const OutputStream: TStream);
var
  ByteBuffer, ByteBufferSpace: Cardinal;
  InputBuffer: array[0..MIME_BUFFER_SIZE - 1] of Byte;
  OutputBuffer: array[0..(MIME_BUFFER_SIZE + 3) div 4 * 3 - 1] of Byte;
  BytesRead: Cardinal;
begin
  ByteBuffer := 0;
  ByteBufferSpace := 4;
  BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
  while BytesRead > 0 do
    begin
      OutputStream.Write(OutputBuffer, MimeDecodePartial(InputBuffer, BytesRead, OutputBuffer, ByteBuffer, ByteBufferSpace));
      BytesRead := InputStream.Read(InputBuffer, SizeOf(InputBuffer));
    end;
  OutputStream.Write(OutputBuffer, MimeDecodePartialEnd(OutputBuffer, ByteBuffer, ByteBufferSpace));
end;

end.

