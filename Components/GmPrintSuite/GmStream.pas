{******************************************************************************}
{                                                                              }
{                                GmStream.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmStream;

interface

uses Windows, GmTypes, Classes;

  type
    TGmReader = class;
    TGmWriter = class;

    TGmValueList = class(TStringList)
//    private
    public
      function ReadBoolValue(Name: string; Default: Boolean): Boolean;
      function ReadExtValue(Name: string; Default: Extended): Extended;
      function ReadGmPointValue(Name: string; Default: TGmPoint): TGmPoint;
      function ReadGmRectValue(Name: string; Default: TGmRect): TGmRect;
      function ReadIntValue(Name: string; Default: integer): integer;
      function ReadPointValue(Name: string; Default: TPoint): TPoint;
      function ReadStringValue(Name: string; Default: string): string;
      procedure WriteBoolValue(Name: string; Value: Boolean);
      procedure WriteExtValue(Name: string; Value: Extended);
      procedure WriteGmPointValue(Name: string; Value: TGmPoint);
      procedure WriteGmRectValue(Name: string; Value: TGmRect);
      procedure WriteIntValue(Name: string; Value: integer);
      procedure WritePointValue(Name: string; Value: TPoint);
      procedure WriteStringValue(Name: string; Value: string);
      // overridden methods...
      procedure LoadFromStream(Stream: TStream); override;
      procedure SaveToStream(Stream: TStream); override;
    end;

    TGmWriter = class(TObject)
    private
      FStream: TStream;
    public
      constructor Create(Stream: TStream);
      procedure WriteInteger(Value: integer);
      procedure WriteStream(Stream: TStream);
      procedure WriteString(Value: string);
      procedure WriteStringList(StringList: TStringList);
    end;

    TGmReader = class(TObject)
    private
      FStream: TStream;
    public
      constructor Create(Stream: TStream);
      function ReadInteger: integer;
      function ReadString: string;
      procedure ReadStringList(StringList: TStringList);
      procedure ReadStream(Stream: TStream);
    end;

implementation

uses SysUtils;

function StrToGmPoint(Value: string): TGmPoint;
var
  AStrings: TStringList;
begin
  AStrings := TStringList.Create;
  try
    AStrings.CommaText := Value;
    Result.X := StrToInt(AStrings[0]) / 1000;
    Result.Y := StrToInt(AStrings[1]) / 1000;
  finally
    AStrings.Free;
  end;
end;

function GmPointToStr(Value: TGmPoint): string;
var
  AStrings: TStringList;
begin
  AStrings := TStringList.Create;
  try
    AStrings.Add(IntToStr(Round(Value.X * 1000)));
    AStrings.Add(IntToStr(Round(Value.Y * 1000)));
    Result := AStrings.CommaText;
  finally
    AStrings.Free;
  end;
end;

function GmRectToString(Value: TGmRect): string;
var
  AStrings: TStringList;
begin
  AStrings := TStringList.Create;
  try
    AStrings.Add(IntToStr(Round(Value.Left * 1000)));
    AStrings.Add(IntToStr(Round(Value.Top * 1000)));
    AStrings.Add(IntToStr(Round(Value.Right * 1000)));
    AStrings.Add(IntToStr(Round(Value.Bottom * 1000)));
    Result := AStrings.CommaText;
  finally
    AStrings.Free;
  end;
end;

function StringToGmRect(Value: string): TGmRect;
var
  AStrings: TStringList;
begin
  Result := GmRect(0, 0, 0, 0);
  if Value = '' then Exit;
  AStrings := TStringList.Create;
  try
    AStrings.CommaText := Value;
    Result.Left   := StrToInt(AStrings[0]) / 1000;
    Result.Top    := StrToInt(AStrings[1]) / 1000;
    Result.Right  := StrToInt(AStrings[2]) / 1000;
    Result.Bottom := StrToInt(AStrings[3]) / 1000;
  finally
    AStrings.Free;
  end;
end;
//------------------------------------------------------------------------------

// *** TGmValueList ***

function TGmValueList.ReadBoolValue(Name: string; Default: Boolean): Boolean;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := Boolean(StrToInt(Values[Name]));
end;

function TGmValueList.ReadExtValue(Name: string; Default: Extended): Extended;
{$IFDEF D5+}
var
  ASettings: TFormatSettings;
begin
  ASettings.DecimalSeparator := '.';
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := StrToFloat(Values[Name], ASettings);
end;
{$ELSE}
var
  LastSeparator: Char;
begin
  LastSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Result := Default;
    if IndexOfName(Name) <> -1 then Result := StrToFloat(Values[Name]);
  finally
    DecimalSeparator := LastSeparator;
  end;
end;
{$ENDIF}

function TGmValueList.ReadGmPointValue(Name: string; Default: TGmPoint): TGmPoint;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := StrToGmPoint(Values[Name]);
end;

function TGmValueList.ReadGmRectValue(Name: string; Default: TGmRect): TGmRect;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := StringToGmRect(Values[Name]);
end;

function TGmValueList.ReadIntValue(Name: string; Default: integer): integer;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := StrToInt(Values[Name]);
end;

function TGmValueList.ReadPointValue(Name: string; Default: TPoint): TPoint;
var
  AGmPoint: TGmPoint;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
  begin
    AGmPoint := StrToGmPoint(Values[Name]);
    Result.X := Round(AGmPoint.X);
    Result.Y := Round(AGmPoint.Y);
  end;
end;

function TGmValueList.ReadStringValue(Name: string; Default: string): string;
begin
  Result := Default;
  if IndexOfName(Name) <> -1 then
    Result := Values[Name];
end;

procedure TGmValueList.WriteBoolValue(Name: string; Value: Boolean);
begin
  Values[Name] := IntToStr(Ord(Value));
end;

procedure TGmValueList.WriteExtValue(Name: string; Value: Extended);
{$IFDEF D5+}
var
  ASettings: TFormatSettings;
begin
  ASettings.DecimalSeparator := '.';
  Values[Name] := FormatFloat('0.000', Value, ASettings);
end;
{$ELSE}
var
  LastSeparator: Char;
begin
  LastSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Values[Name] := FormatFloat('0.000', Value);
  finally
    DecimalSeparator := LastSeparator;
  end;
end;
{$ENDIF}

procedure TGmValueList.WriteGmPointValue(Name: string; Value: TGmPoint);
begin
  Values[Name] := GmPointToStr(Value);
end;

procedure TGmValueList.WriteGmRectValue(Name: string; Value: TGmRect);
begin
  Values[Name] := GmRectToString(Value);
end;

procedure TGmValueList.WriteIntValue(Name: string; Value: integer);
begin
  Values[Name] := IntToStr(Value);
end;

procedure TGmValueList.WritePointValue(Name: string; Value: TPoint);
var
  AGmPoint: TGmPoint;
begin
  AGmPoint.X := Value.X;
  AGmPoint.Y := Value.Y;
  Values[Name] := GmPointToStr(AGmPoint);
end;

procedure TGmValueList.WriteStringValue(Name: string; Value: string);
begin
  Values[Name] := Value;
end;

procedure TGmValueList.LoadFromStream(Stream: TStream);
var
  Reader: TGmReader;
begin
  Reader := TGmReader.Create(Stream);
  try
    Reader.ReadStringList(Self);
  finally
    Reader.Free;
  end;
end;

procedure TGmValueList.SaveToStream(Stream: TStream);
var
  Writer: TGmWriter;
begin
  Writer := TGmWriter.Create(Stream);
  try
    Writer.WriteStringList(Self);
  finally
    Writer.Free;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmWriter ***

constructor TGmWriter.Create(Stream: TStream);
begin
  inherited Create;
  FStream := Stream;
end;

procedure TGmWriter.WriteInteger(Value: integer);
begin
  FStream.Write(Value, SizeOf(Value));
end;

procedure TGmWriter.WriteStream(Stream: TStream);
var
  StreamSize: integer;
begin
  StreamSize := Stream.Size;
  WriteInteger(StreamSize);
  Stream.Seek(0, soFromBeginning);
  FStream.CopyFrom(Stream, StreamSize);
end;

procedure TGmWriter.WriteString(Value: string);
var
  StringLength: integer;
begin
  StringLength := Length(Value);
  FStream.Write(StringLength, SizeOf(StringLength));
  FStream.Write(Value[1], StringLength);
end;

procedure TGmWriter.WriteStringList(StringList: TStringList);
var
  AStream: TMemoryStream;
  WriteList: TStringList;
begin
  WriteList := TStringList.Create;
  try
    WriteList.Assign(StringList);
    AStream := TMemoryStream.Create;
    try
      WriteList.SaveToStream(AStream);
      WriteStream(AStream);
    finally
      AStream.Free;
    end;
  finally
    WriteList.Free;
  end;
end;

//------------------------------------------------------------------------------

// *** TMurtReader ***

constructor TGmReader.Create(Stream: TStream);
begin
  inherited Create;
  FStream := Stream;
end;

function TGmReader.ReadInteger: integer;
begin
  FStream.Read(Result, SizeOf(Result));
end;

function TGmReader.ReadString: string;
var
  StringLength: integer;
begin
  FStream.Read(StringLength, SizeOf(StringLength));
  SetLength(Result, StringLength);
  FStream.Read(Result[1], StringLength);
end;

procedure TGmReader.ReadStringList(StringList: TStringList);
var
  AStream: TMemoryStream;
  ReadList: TStringList;
begin
  AStream := TMemoryStream.Create;
  try
    ReadStream(AStream);
    AStream.Seek(0, soFromBeginning);
    ReadList := TStringList.Create;
    try
      ReadList.LoadFromStream(AStream);
      StringList.Assign(ReadList);
    finally
      ReadList.Free;
    end;
  finally
    AStream.Free;
  end;
end;

procedure TGmReader.ReadStream(Stream: TStream);
var
  StreamSize: integer;
begin
  StreamSize := ReadInteger;
  if StreamSize = 0 then Exit;
  Stream.CopyFrom(FStream, StreamSize);
end;




end.
