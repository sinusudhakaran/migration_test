{******************************************************************************}
{                                                                              }
{                                GmFuncs.pas                                   }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmFuncs;

interface

uses Windows, SysUtils, Graphics, GmTypes, Jpeg;

  function ConvertValue(Value: Extended; UnitsFrom, UnitsTo: TGmMeasurement): Extended;
  function ConvertGmPoint(Value: TGmPoint; UnitsFrom, UnitsTo: TGmMeasurement): TGmPoint;
  function ConvertGmRect(Value: TGmRect; UnitsFrom, UnitsTo: TGmMeasurement): TGmRect;
  function ConvertGmSize(Value: TGmSize; UnitsFrom, UnitsTo: TGmMeasurement): TGmSize;
  function ConvertGmComplexCoords(Value: TGmComplexCoords; UnitsFrom, UnitsTo: TGmMeasurement): TGmComplexCoords;
  procedure ConvertGmPolyPoints(var Points: TGmPolyPoints; UnitsFrom, UnitsTo: TGmMeasurement);
  procedure ArrayToPolyPoints(Points: array of TGmPoint; var Result: TGmPolyPoints);
  function EqualPoints(Point1, Point2: TPoint): Boolean;
  function EqualGmPoints(Point1, Point2: TGmPoint): Boolean;
  function EqualGmRects(Rect1, Rect2: TGmRect): Boolean;
  function FontStyleToString(AStyle: TFontStyles): string;
  function FontStyleFromString(AString: string): TFontStyles;
  function GetFontHeightInch(Font: TFont): Extended;
  function GetPaperSizeInch(Value: TGmPaperSize): TGmSize;
  function InvertColor(Value: TColor): TColor;
  function IsEnvelope(Value: TGmPaperSize): Boolean;
  function IsPrinterCanvas(Canvas: TCanvas): Boolean;
  function MaxFloat(Value1, Value2: Extended): Extended;
  function MaxInt(Value1, Value2: integer): integer;
  function MinFloat(Value1, Value2: Extended): Extended;
  function MinInt(Value1, Value2: integer): integer;
  function GmRectHeight(ARect: TGmRect): Extended;
  function GmRectWidth(ARect: TGmRect): Extended;
  function RectHeight(ARect: TRect): integer;
  function RectWidth(ARect: TRect): integer;
  function PaperSizeToStr(APaperSize: TGmPaperSize): string;
  function ReplaceStringFields(Source, Field, InsertStr: string): string;
  function StrToPaperSize(Value: string): TGmPaperSize;
  function TextExtent(AText: string; AFont: TFont): TGmSize;
  function Tokenize(AText: string; APage, NumPages: integer; ADateFormat, ATimeFormat: string): string;
  procedure GmDrawRect(ACanvas: TCanvas; ARect: TRect);
  procedure GmDrawRoundRect(ACanvas: TCanvas; x, y, x2, y2, x3, y3: integer);
  procedure GmDrawEllipse(ACanvas: TCanvas; x,  y, x2, y2: integer);
  procedure GmDrawPolyShape(ObjID: integer; Canvas: TCanvas; const Points: array of TPoint);
  procedure PrintBitmap(Canvas: TCanvas; ARect: TRect; Bitmap: TBitmap);
  procedure SwapExtValues(var Value1: Extended; var Value2: Extended);
  procedure GraphicToJPeg(AGraphic: TGraphic; var AJpeg: TJPEGImage);
  procedure IconToBitmap(AIcon: TIcon; var ABitmap: TBitmap);
  function ReturnOSVersion: string;

implementation

uses GmConst, GmResource, Classes, TypInfo, GmObjects;

//------------------------------------------------------------------------------

function ReplaceStringFields(Source, Field, InsertStr: string): string;
var
  TokenPosition: integer;
begin
  Result := Source;
  while Pos(Field, Result) <> 0 do
  begin
    TokenPosition := Pos(Field, Result);
    Delete(Result, TokenPosition, Length(Field));
    Insert(InsertStr, Result, TokenPosition);
  end;
end;

//------------------------------------------------------------------------------

function ConvertValue(Value: Extended; UnitsFrom, UnitsTo: TGmMeasurement): Extended;
var
  AsInches: Extended;
begin
  // firstly convert to inches...
  Result := Value;
  if UnitsFrom = UnitsTo then Exit;
  AsInches := Value;
  case UnitsFrom of
    gmUnits      : AsInches := (Value/ 100) / MM_PER_INCH;
    gmMillimeters: AsInches := Value / MM_PER_INCH;
    gmCentimeters: AsInches := (Value * 10) / MM_PER_INCH;
    gmInches     : AsInches := Value;
    gmPixels     : AsInches := Value / SCREEN_PPI;
    gmTwips      : AsInches := Value / 1440;
  end;
  // now convert to the desired measurement...
  Result := AsInches;
  case UnitsTo of
    gmUnits      : Result := (AsInches * MM_PER_INCH) * 100;
    gmMillimeters: Result := AsInches * MM_PER_INCH;
    gmCentimeters: Result := (AsInches * MM_PER_INCH) / 10;
    gmInches     : Result := AsInches;
    gmPixels     : Result := AsInches * SCREEN_PPI;
    gmTwips      : Result := AsInches * 1440;
  end;
end;

function ConvertGmPoint(Value: TGmPoint; UnitsFrom, UnitsTo: TGmMeasurement): TGmPoint;
begin
  Result.X := ConvertValue(Value.X, UnitsFrom, UnitsTo);
  Result.Y := ConvertValue(Value.Y, UnitsFrom, UnitsTo);
end;

function ConvertGmRect(Value: TGmRect; UnitsFrom, UnitsTo: TGmMeasurement): TGmRect;
begin
  Result.Left   := ConvertValue(Value.Left,   UnitsFrom, UnitsTo);
  Result.Top    := ConvertValue(Value.Top,    UnitsFrom, UnitsTo);
  Result.Right  := ConvertValue(Value.Right,  UnitsFrom, UnitsTo);
  Result.Bottom := ConvertValue(Value.Bottom, UnitsFrom, UnitsTo);
end;

function ConvertGmSize(Value: TGmSize; UnitsFrom, UnitsTo: TGmMeasurement): TGmSize;
begin
  Result.Width  := ConvertValue(Value.Width, UnitsFrom, UnitsTo);
  Result.Height := ConvertValue(Value.Height, UnitsFrom, UnitsTo);
end;


function ConvertGmComplexCoords(Value: TGmComplexCoords; UnitsFrom, UnitsTo: TGmMeasurement): TGmComplexCoords;
begin
  Result.X  := ConvertValue(Value.X,  UnitsFrom, UnitsTo);
  Result.Y  := ConvertValue(Value.Y,  UnitsFrom, UnitsTo);
  Result.X2 := ConvertValue(Value.X2, UnitsFrom, UnitsTo);
  Result.Y2 := ConvertValue(Value.Y2, UnitsFrom, UnitsTo);
  Result.X3 := ConvertValue(Value.X3, UnitsFrom, UnitsTo);
  Result.Y3 := ConvertValue(Value.Y3, UnitsFrom, UnitsTo);
  Result.X4 := ConvertValue(Value.X4, UnitsFrom, UnitsTo);
  Result.Y4 := ConvertValue(Value.Y4, UnitsFrom, UnitsTo);
end;

procedure ConvertGmPolyPoints(var Points: TGmPolyPoints; UnitsFrom, UnitsTo: TGmMeasurement);
var
  ICount: integer;
begin
  for ICount := 0 to High(Points) do
  begin
    Points[ICount].X := ConvertValue(Points[ICount].X, UnitsFrom, UnitsTo);
    Points[ICount].Y := ConvertValue(Points[ICount].Y, UnitsFrom, UnitsTo);
  end;
end;

procedure ArrayToPolyPoints(Points: array of TGmPoint; var Result: TGmPolyPoints);
var
  ICount: integer;
begin
  SetLength(Result, High(Points)+1);
  for ICount := 0 to High(Points) do
    Result[ICount] := Points[ICount];
end;

function EqualPoints(Point1, Point2: TPoint): Boolean;
begin
  Result := (Point1.X = Point2.X) and (Point1.Y = Point2.Y);
end;

function EqualGmPoints(Point1, Point2: TGmPoint): Boolean;
begin
  Result := (Point1.X = Point2.X) and (Point1.Y = Point2.Y);
end;

function EqualGmRects(Rect1, Rect2: TGmRect): Boolean;
begin
  Result := EqualGmPoints(Rect1.TopLeft, Rect1.BottomRight) and
            EqualGmPoints(Rect2.TopLeft, Rect2.BottomRight);
end;

function FontStyleToString(AStyle: TFontStyles): string;
var
  AStrings: TStringList;
begin
  Result := '';
  AStrings := TStringList.Create;
  try
    if fsBold in AStyle then AStrings.Add('b');
    if fsItalic in AStyle then AStrings.Add('i');
    if fsUnderline in AStyle then AStrings.Add('u');
    Result := AStrings.CommaText;
  finally
    AStrings.Free;
  end;
end;

function FontStyleFromString(AString: string): TFontStyles;
var
  AStrings: TStringList;
begin
  AStrings := TStringList.Create;
  try
    Result := [];
    AStrings.CommaText := AString;
    if AStrings.IndexOf('b') <> -1 then Result := Result + [fsBold];
    if AStrings.IndexOf('i') <> -1 then Result := Result + [fsItalic];
    if AStrings.IndexOf('u') <> -1 then Result := Result + [fsUnderline];
  finally
    AStrings.Free;
  end;
end;

function GetFontHeightInch(Font: TFont): Extended;
var
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
  TextMetrics: TTextMetric;
begin
  //CriticalSection.Enter;
  try
    Mf := TMetafile.Create;
    try
      Mfc := TMetafileCanvas.Create(Mf, 0);
      try
        Mfc.Font.PixelsPerInch := 600;
        Mfc.Font.Assign(Font);
        GetTextMetrics(Mfc.Handle, TextMetrics);
        Result := TextMetrics.tmHeight / 600;
      finally
        Mfc.Free;
      end;
    finally
      Mf.Free;
    end;
  finally
  //  CriticalSection.Leave;
  end;
end;

function GetPaperSizeInch(Value: TGmPaperSize): TGmSize;

type
  TGmPaperSizeInfo = record
    Height: Extended;
    Width: Extended;
    Measurement: TGmMeasurement;
  end;

  function GmPaperSizeInfo(Width, Height: Extended; Measurement: TGmMeasurement): TGmPaperSizeInfo;
  begin
    Result.Height := Height;
    Result.Width := Width;
    Result.Measurement := Measurement;
  end;

var
  ASizeInfo: TGmPaperSizeInfo;
begin
  case Value of
    A3          : ASizeInfo := GmPaperSizeInfo(297,    420,    gmMillimeters);
    A4          : ASizeInfo := GmPaperSizeInfo(210,    297,    gmMillimeters);
    A5          : ASizeInfo := GmPaperSizeInfo(148.5,  210,    gmMillimeters);
    A6          : ASizeInfo := GmPaperSizeInfo(105,    148,    gmMillimeters);
    B4          : ASizeInfo := GmPaperSizeInfo(250,    354,    gmMillimeters);
    B5          : ASizeInfo := GmPaperSizeInfo(6.92,   9.84,   gmInches);
    C5          : ASizeInfo := GmPaperSizeInfo(6.38,   9.02,   gmInches);
    Envelope_09 : ASizeInfo := GmPaperSizeInfo(3.78,   8.78,   gmInches);
    Envelope_10 : ASizeInfo := GmPaperSizeInfo(4.18,   9.12,   gmInches);
    Envelope_11 : ASizeInfo := GmPaperSizeInfo(4.12,   10.38,  gmInches);
    Envelope_12 : ASizeInfo := GmPaperSizeInfo(12.44,  11,     gmInches);
    Envelope_14 : ASizeInfo := GmPaperSizeInfo(14.5,   11.12,  gmInches);
    Letter      : ASizeInfo := GmPaperSizeInfo(8.5,    11,     gmInches);
    Legal       : ASizeInfo := GmPaperSizeInfo(8.5,    14,     gmInches);
    Tabloid     : ASizeInfo := GmPaperSizeInfo(11,     17,     gmInches);
    Ledger      : ASizeInfo := GmPaperSizeInfo(17,     11,     gmInches);
    Executive   : ASizeInfo := GmPaperSizeInfo(7.14,   10.12,  gmInches);
  end;
  if ASizeInfo.Measurement <> gmInches then
  begin
    ASizeInfo.Width := ConvertValue(ASizeInfo.Width, ASizeInfo.Measurement, gmInches);
    ASizeInfo.Height := ConvertValue(ASizeInfo.Height, ASizeInfo.Measurement, gmInches);
  end;
  Result.Width := ASizeInfo.Width;
  Result.Height := ASizeInfo.Height;
end;

function InvertColor(Value: TColor): TColor;
var
  rgb_: TColorref;

  function Inv(b: Byte): Byte;
  begin
    if b > 128 then
      Result:= 0
    else
      result:= 255;
  end;
begin
  rgb_ := ColorToRgb(Value);
  rgb_ := RGB( Inv(GetRValue( rgb_ )),
               Inv(GetGValue( rgb_ )),
               Inv(GetBValue( rgb_ )));
  Result := rgb_;
end;

function IsEnvelope(Value: TGmPaperSize): Boolean;
begin
  Result := Value in [B4,
                      B5,
                      C5,Envelope_09,
                      Envelope_10,
                      Envelope_11,
                      Envelope_12,
                      Envelope_14];
end;

function IsPrinterCanvas(Canvas: TCanvas): Boolean;
begin
  Result := Canvas.ClassName = 'TPrinterCanvas';
end;

function MaxFloat(Value1, Value2: Extended): Extended;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function MaxInt(Value1, Value2: integer): integer;
begin
  if Value1 > Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function MinFloat(Value1, Value2: Extended): Extended;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function MinInt(Value1, Value2: integer): integer;
begin
  if Value1 < Value2 then
    Result := Value1
  else
    Result := Value2;
end;

function GmRectHeight(ARect: TGmRect): Extended;
begin
  Result := ARect.Bottom - ARect.Top;
end;

function GmRectWidth(ARect: TGmRect): Extended;
begin
  Result := ARect.Right - ARect.Left;
end;

{function GmRectToString(ARect: TGmRect): string;
begin

end

function GmRectFromString(Value: string): TGmRect;
                                                        }
function RectHeight(ARect: TRect): integer;
begin
  Result := ARect.Bottom - ARect.Top;
end;

function RectWidth(ARect: TRect): integer;
begin
  Result := ARect.Right - ARect.Left;
end;

function PaperSizeToStr(APaperSize: TGmPaperSize): string;
begin
  Result := GetEnumName(Typeinfo(TGmPaperSize ), Ord(APaperSize));
end;

function StrToPaperSize(Value: string): TGmPaperSize;
var
  APaperSize: TGmPaperSize;
begin
  Result := Custom;
  for APaperSize := Low(TGmPaperSize) to High(TGmPaperSize) do
  begin
    if PaperSizeToStr(APaperSize) = Value then
    begin
      Result := APaperSize;
      Exit;
    end;
  end;
end;

procedure GmDrawRect(ACanvas: TCanvas; ARect: TRect);
begin
  ACanvas.Lock;
  try
    ACanvas.Polygon([Point(ARect.Left, ARect.Top),
                     Point(ARect.Right, ARect.Top),
                     Point(ARect.Right, ARect.Bottom),
                     Point(ARect.Left, ARect.Bottom),
                     Point(ARect.Left, ARect.Top),
                     Point(ARect.Right, ARect.Top)]);
  finally
    ACanvas.Unlock;
  end;
end;

procedure GmDrawRoundRect(ACanvas: TCanvas; x, y, x2, y2, x3, y3: integer);
var
  AHeight: integer;
  AWidth: integer;
  NodeLengthX: integer;
  NodeLengthY: integer;
begin
  AHeight := RectHeight(Rect(x, y, x2, y2));
  AWidth := RectWidth(Rect(x, y, x2, y2));
  NodeLengthX := Round(x3 / 4)-1;
  NodeLengthY := Round(y3 / 4)-1;
  x3 := x3 div 2;
  y3 := y3 div 2;
  if X3 > AWidth then X3 := AWidth;
  if Y3 > AHeight then Y3 := AHeight;
  ACanvas.Lock;
  try
    ACanvas.MoveTo(x + x3, y);
    ACanvas.PolyBezierTo([Point(x + NodeLengthX, y), Point(x, y+NodeLengthY), Point(x, y+Y3)]);
    ACanvas.LineTo(x, y2-y3);
    ACanvas.PolyBezierTo([Point(x, y2-NodeLengthY), Point(x+NodeLengthX, Y2), Point(X+x3, Y2)]);
    ACanvas.LineTo(x2-x3, y2);
    ACanvas.PolyBezierTo([Point(x2-NodeLengthX, y2), Point(x2, y2-NodeLengthY), Point(x2, y2-y3)]);
    ACanvas.LineTo(x2, y+y3);
    ACanvas.PolyBezierTo([Point(x2, y+NodeLengthY), Point(x2-NodeLengthX, y), Point(x2-x3, y)]);
    ACanvas.LineTo(x+x3, y);
  finally
    ACanvas.Unlock;
  end;
end;

procedure GmDrawEllipse(ACanvas: TCanvas; x,  y, x2, y2: integer);
var
  AHeight: integer;
  AWidth: integer;
  RadiusX: integer;
  RadiusY: integer;
  NodeX: integer;
  NodeY: integer;
begin
  AHeight := RectHeight(Rect(x, y, x2, y2));
  AWidth := RectWidth(Rect(x, y, x2, y2));
  RadiusX := AWidth div 2;
  RadiusY := AHeight div 2;
  NodeX := Round(AWidth / 4.45);
  NodeY := Round(AHeight / 4.45);
  ACanvas.MoveTo(x + RadiusX, y);
  ACanvas.PolyBezierTo([Point(x + NodeX, y), Point(x, y+NodeY), Point(x, y+RadiusY)]);
  ACanvas.PolyBezierTo([Point(x, y2-NodeY), Point(x+NodeX, Y2), Point(x+RadiusX, y2)]);
  ACanvas.PolyBezierTo([Point(x2-NodeX, y2), Point(x2, y2-NodeY), Point(x2, y2-RadiusY)]);
  ACanvas.PolyBezierTo([Point(x2, y+NodeY), Point(x2-NodeX, y), Point(x2-RadiusX, y)]);
end;

procedure GmDrawPolyShape(ObjID: integer; Canvas: TCanvas; const Points: array of TPoint);
type
  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;
begin
  case ObjID of
    GM_POLYGON_OBJECT_ID     : Windows.Polygon(Canvas.Handle, PPoints(@Points)^, High(Points) + 1);
    GM_POLYLINE_OBJECT_ID    : Windows.PolyLine(Canvas.Handle, PPoints(@Points)^, High(Points) + 1);
    GM_POLYBEZIER_OBJECT_ID  : Windows.PolyBezier(Canvas.Handle, PPoints(@Points)^, High(Points) + 1);
    GM_POLYLINETO_OBJECT_ID  : Windows.PolyLineTo(Canvas.Handle, PPoints(@Points)^, High(Points) + 1);
    GM_POLYBEZIERTO_OBJECT_ID: Windows.PolyBezierTo(Canvas.Handle, PPoints(@Points)^, High(Points) + 1);
  end;
end;

procedure PrintBitmap(Canvas: TCanvas; ARect: TRect; Bitmap: TBitmap);
var
  BitmapHeader: pBitmapInfo;
  BitmapImage : POINTER;
  HeaderSize : DWORD; // Use DWORD for D3-D5 compatibility
  ImageSize : DWORD;
  CM : LongInt;
begin
  if Bitmap.Empty then Exit;
  CM := SRCCOPY;
  case Canvas.CopyMode of
    cmBlackness:  CM := BLACKNESS;
    cmDstInvert:  CM := DSTINVERT;
    cmMergeCopy:  CM := MERGECOPY;
    cmMergePaint: CM := MERGEPAINT;
    cmNotSrcCopy: CM := NOTSRCCOPY;
    cmNotSrcErase:CM := NOTSRCERASE;
    cmPatCopy:    CM := PATCOPY;
    cmPatInvert:  CM := PATINVERT;
    cmPatPaint:   CM := PATPAINT;
    cmSrcAnd:     CM := SRCAND;
    cmSrcCopy:    CM := SRCCOPY;
    cmSrcErase:   CM := SRCERASE;
    cmSrcInvert:  CM := SRCINVERT;
    cmSrcPaint:   CM := SRCPAINT;
    cmWhiteness:  CM := WHITENESS;
  end;

  GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
  GetMem(BitmapHeader, HeaderSize);
  GetMem(BitmapImage, ImageSize);
  GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
  try
    StretchDIBits(Canvas.Handle,
                  ARect.Left, ARect.Top,
                  ARect.Right - ARect.Left,
                  ARect.Bottom - ARect.Top,
                  0, 0,
                  Bitmap.Width, Bitmap.Height,
                  BitmapImage,
                  TBitmapInfo(BitmapHeader^),
                  DIB_RGB_COLORS,
                  CM);
  finally
    FreeMem(BitmapHeader);
    FreeMem(BitmapImage);
  end;
end;

function TextExtent(AText: string; AFont: TFont): TGmSize;
var
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
  AExtent: TSize;
begin
  //CriticalSection.Enter;
  try
    Mf := TMetafile.Create;
    try
      Mfc := TMetafileCanvas.Create(Mf, 0);
      try
        Mfc.Font.PixelsPerInch := 600;
        Mfc.Font.Assign(AFont);
        AExtent := Mfc.TextExtent(AText);
        Result.Width := AExtent.cx / 600;
        Result.Height := AExtent.cy / 600;
      finally
        Mfc.Free;
      end;
    finally
      Mf.Free;
    end;
  finally
  //  CriticalSection.Leave;
  end;
end;

function Tokenize(AText: string; APage, NumPages: integer; ADateFormat, ATimeFormat: string): string;
begin
  Result := AText;
  Result := ReplaceStringFields(Result, '{DATE}', FormatDateTime(ADateFormat,Date));
  Result := ReplaceStringFields(Result, '{TIME}', FormatDateTime(ATimeFormat,Time));
  Result := ReplaceStringFields(Result, '{PAGE}', IntToStr(APage));
  Result := ReplaceStringFields(Result, '{NUMPAGES}', IntToStr(NumPages));
end;

procedure SwapExtValues(var Value1: Extended; var Value2: Extended);
var
  TempVal: Extended;
begin
  TempVal := Value1;
  Value1 := Value2;
  Value2 := TempVal;
end;

procedure GraphicToJPeg(AGraphic: TGraphic; var AJpeg: TJPEGImage);
begin
  AJpeg := TJPEGImage.Create;
  AJpeg.Assign(AGraphic);
end;

procedure IconToBitmap(AIcon: TIcon; var ABitmap: TBitmap);
begin
  ABitmap := TBitmap.Create;
  ABitmap.Width := AIcon.Width;
  ABitmap.Height := AIcon.Height;
  ABitmap.Canvas.Draw(0, 0, AIcon);
end;

function ReturnOSVersion: string;
var
  VI: TOSVersionInfo;
begin
  VI.dwOSVersionInfoSize := SizeOf(VI);
  GetVersionEx(VI);
  with VI do
  begin
    case dwPlatformID of
      VER_PLATFORM_WIN32S: Result := 'Windows 3.1x running Win32s';
      VER_PLATFORM_WIN32_WINDOWS:
      if VI.dwMajorVersion >= 4 then
        if VI.dwMinorVersion >= 90 then Result := 'Windows ME'
          else
            Result := 'Windows 98'
        else
          Result := 'Windows 95';
      VER_PLATFORM_WIN32_NT:
      if VI.dwMajorVersion > 4 then
        if VI.dwMinorVersion >= 1 then Result := 'Windows XP'
        else
          Result := 'Windows 2000'
      else Result := 'Windows NT';
    end;
  end;
end;

end.
