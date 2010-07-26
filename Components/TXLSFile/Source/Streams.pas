unit Streams;

{-----------------------------------------------------------------
    SM Software, 2000-2008
    
    Streams
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, SysUtils, Unicode, XLSBase;

type
  TEasyStream = class(TMemoryStream)
  public
    function ReadByte(var B: Byte): Boolean;
    function ReadWord(var W: Word): Boolean;
    function ReadDWord(var D: Longword): Boolean;
    function ReadInt(var I: Integer): Boolean;
    function ReadBytes(Buff: Pointer; Size: Integer): Boolean;
    function ReadString(var S: AnsiString; Size: Integer): Boolean;
    procedure SkipBytes(Size: Integer);

    function ReadableSize: Integer;

    function WriteByte(const B: Byte): Integer;
    function WriteWord(const W: Word): Integer;
    function WriteDWord(const D: Longword): Integer;
    function WriteBytes(Buff: Pointer; Size: integer): Integer;
  end;

implementation

{ TEasyStream }
function TEasyStream.ReadByte(var B: Byte): Boolean;
begin
  result:= (Read(B, 1) = 1);
end;

function TEasyStream.ReadWord(var W: Word): Boolean;
begin
  result:= (Read(W, 2) = 2);
end;

function TEasyStream.ReadDWord(var D: Longword): Boolean;
begin
  result:= (Read(D, 4) = 4);
end;

function TEasyStream.ReadInt(var I: Integer): Boolean;
begin
  result:= (Read(I, 4) = 4);
end;

function TEasyStream.ReadBytes(Buff: Pointer; Size: integer): Boolean;
begin
  result:= (Read(Buff^, Size) = Size);
end;

function TEasyStream.ReadString(var S: AnsiString; Size: Integer): Boolean;
begin
  if Self.ReadableSize >= Size then
  begin
    SetLength(S, Size);
    result:= ReadBytes(@S[1], Size);
  end
  else
    result:= False;
end;

procedure TEasyStream.SkipBytes(Size: Integer);
begin
  Seek(Size, soFromCurrent);
end;

function TEasyStream.WriteByte(const B: Byte): Integer;
begin
  result:= Self.Write(B, 1);
end;

function TEasyStream.WriteWord(const W: Word): Integer;
begin
  result:= Self.Write(W, 2);
end;

function TEasyStream.WriteDWord(const D: Longword): Integer;
begin
  result:= Self.Write(D, 4);
end;

function TEasyStream.WriteBytes(Buff: Pointer; Size: integer): Integer;
begin
  result:= Self.Write(Buff^, Size);
end;

function TEasyStream.ReadableSize: Integer;
begin
  Result:= Self.Size - Self.Position;
end;

end.
