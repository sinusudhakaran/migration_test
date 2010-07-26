{******************************************************************************}
{                                                                              }
{                              GmCanvas.pas                                    }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmCanvas;

interface

uses Windows, Classes, Graphics, GmTypes, GmClasses, GmResource;

{$I GMPS.INC}

type
  TGmCanvas = class;

  TGmCustomGridPrint    = class(TGmComponent);
  TGmCustomLabelPrinter = class(TGmComponent);

  TGmCanvasWinControl   = class(TGmScrollingWinControl)
  private
    FCanvas: TGmCanvas;
  protected
    property Canvas: TGmCanvas read FCanvas write FCanvas;
  end;

  // *** TGmCanvasSavedValues ***

  TGmCanvasSavedValues = class(TPersistent)
  private
    FCoordsRelativeTo: TGmCoordsRelative;
    FBrush: TBrush;
    FFont: TFont;
    FPen: TPen;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // *** TGmCanvas ***

  TGmCanvas = class(TPersistent)
  private
    FAllowDrag: Boolean;
    FBrush: TBrush;
    FCoordsRelativeTo: TGmCoordsRelative;
    FCopyMode: TCopyMode;
    FDefaultAlignment: TAlignment;
    FDefaultVertAlignment: TGmVertAlignment;
    FFont: TFont;
    FFontAngle: Extended;
    FPen: TPen;
    FGmBrush: TGmBrush;
    FGmFont: TGmFont;
    FGmPen: TGmPen;
    FDefaultMeasurement: TGmMeasurement;
    FLastObject: TGmBaseObject;
    FPageList: TGmObjectList;
    FPenPos: TGmPoint;
    FPropertyStream: TStream;
    FResourceTable: TGmResourceTable;
    FExtentValue: TGmValueSize;
    FSavedValues: TGmCanvasSavedValues;
    FTextBoxPadding: TGmValue;
    FWordWrap: Boolean;
    function AddObjectToPage(AObject: TGmBaseObject): TGmBaseObject;
    function AsGmBrush: TGmBrush;
    function AsGmFont: TGmFont;
    function AsGmPen: TGmPen;
    function GetCompareImages: Boolean;
    function GetPenPos(Measurement: TGmMeasurement): TGmPoint;
    procedure SetBrush(Value: TBrush);
    procedure SetCompareImages(Value: Boolean);
    procedure SetFont(Value: TFont);
    procedure SetPen(Value: TPen);
    procedure SetTextBoxPadding(Value: TGmValue);
    function TextBoxHeightExt(AWidth, Padding: Extended; AText: string; Measurement: TGmMeasurement): Extended;
    procedure TextOutExt(X, Y, Angle: Extended; AClipRect: PGmRect; AText: string; Measurement: TGmMeasurement);
  public
    constructor Create(APageList: TGmObjectList);
    destructor Destroy; override;

    // functions...
    function GraphicExtent(AGraphic: TGraphic): TGmValueSize;
    function GraphicHeight(AGraphic: TGraphic): TGmValue;
    function GraphicWidth(AGraphic: TGraphic): TGmValue;

    function TextExtent(AText: string): TGmValueSize;
    function TextHeight(AText: string): TGmValue;
    function TextWidth(AText: string): TGmValue;
    function TextBoxHeight(AWidth: Extended; AText: string; Measurement: TGmMeasurement): Extended;

    // line methods...
    procedure Line(x, y, x2, y2: Extended; Measurement: TGmMeasurement);  {$IFDEF D4+} overload; {$ENDIF}
    procedure LineTo(x, y: Extended; Measurement: TGmMeasurement);        {$IFDEF D4+} overload; {$ENDIF}
    procedure MoveTo(x, y: Extended; Measurement: TGmMeasurement);        {$IFDEF D4+} overload; {$ENDIF}
    {$IFDEF D4+}
    procedure Line(x, y, x2, y2: Extended); overload;
    procedure LineTo(x, y: Extended); overload;
    procedure MoveTo(x, y: Extended); overload;
    {$ENDIF}

    // shape methods...
    procedure Ellipse(x, y, x2, y2: Extended; Measurement: TGmMeasurement);           {$IFDEF D4+} overload; {$ENDIF}
    procedure Rectangle(x, y, x2, y2: Extended; Measurement: TGmMeasurement);         {$IFDEF D4+} overload; {$ENDIF}
    procedure RoundRect(x, y, x2, y2, x3, y3: Extended; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    {$IFDEF D4+}
    procedure Ellipse(x, y, x2, y2: Extended); overload;
    procedure Rectangle(x, y, x2, y2: Extended); overload;
    procedure RoundRect(x, y, x2, y2, x3, y3: Extended); overload;
    {$ENDIF}

    // simple text methods...
    procedure FloatOut(x, y, Value: Extended; Format: string; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    procedure RotateOut(x, y, Angle: Extended; AText: string; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    procedure TextClipped(x, y: Extended; AText: string; AWidth: Extended; Alignment: TAlignment; Measurement: TGmMeasurement);
    procedure TextOut(x, y: Extended; AText: string; Measurement: TGmMeasurement);          {$IFDEF D4+} overload; {$ENDIF}
    procedure TextOutCenter(x, y: Extended; AText: string; Measurement: TGmMeasurement);    {$IFDEF D4+} overload; {$ENDIF}
    procedure TextOutRight(x, y: Extended; AText: string; Measurement: TGmMeasurement);     {$IFDEF D4+} overload; {$ENDIF}
    procedure TextRect(ARect: TGmRect; x, y: Extended; AText: string; Measurement: TGmMeasurement);
    {$IFDEF D4+}
    procedure FloatOut(x, y, Value: Extended; Format: string); overload;
    procedure RotateOut(x, y, Angle: Extended; AText: string); overload;
    procedure TextOut(x, y: Extended; AText: string); overload;
    //procedure TextOut(x, y: Extended; AClipRect: TGmRect; AText: string; Measurement: TGmMeasurement); overload;
    procedure TextOutCenter(x, y: Extended; AText: string); overload;
    procedure TextOutRight(x, y: Extended; AText: string); overload;
    {$ENDIF}

    // textbox methods...
    procedure TextBox(x, y, x2, y2: Extended; AText: string; Measurement: TGmMeasurement);  {$IFDEF D4+} overload; {$ENDIF}
    procedure TextBoxExt(x, y, x2, y2, Padding: Extended; AText: string;  Alignment: TAlignment;
      VertAlignment: TGmVertAlignment; Measurement: TGmMeasurement);
    {$IFDEF D4+}
    procedure TextBox(x, y, x2, y2: Extended; AText: string; Alignment: TAlignment; VertAlignment: TGmVertAlignment;
      Measurement: TGmMeasurement); overload;
    {$ENDIF}

    // complex shape methods...
    procedure Arc(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement);   {$IFDEF D4+} overload; {$ENDIF}
    procedure Chord(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    procedure Pie(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement);   {$IFDEF D4+} overload; {$ENDIF}
    {$IFDEF D4+}
    procedure Arc(x, y, x2, y2, x3, y3, x4, y4: Extended); overload;
    procedure Chord(x, y, x2, y2, x3, y3, x4, y4: Extended); overload;
    procedure Pie(x, y, x2, y2, x3, y3, x4, y4: Extended); overload;
    {$ENDIF}

    // graphics methods...
    procedure Draw(x, y: Extended; AGraphic: TGraphic; Scale: Extended; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    procedure StretchDraw(x, y, x2, y2: Extended; AGraphic: TGraphic; Measurement: TGmMeasurement);   {$IFDEF D4+} overload; {$ENDIF}
    {$IFDEF D4+}
    procedure Draw(x, y: Extended; AGraphic: TGraphic; const Scale: Extended = 1); overload;
    procedure StretchDraw(x, y, x2, y2: Extended; AGraphic: TGraphic); overload;
    {$ENDIF}

    // polygon/line methods...
    procedure Polygon(Points: array of TGmPoint; Measurement: TGmMeasurement);
    procedure Polyline(Points: array of TGmPoint; Measurement: TGmMeasurement);
    procedure PolyBezier(Points: array of TGmPoint; Measurement: TGmMeasurement);
    procedure PolylineTo(Points: array of TGmPoint; Measurement: TGmMeasurement);
    procedure PolyBezierTo(Points: array of TGmPoint; Measurement: TGmMeasurement);

    // path methods...
    procedure BeginPath;
    procedure EndPath;
    procedure FillPath;
    procedure StrokePath;
    procedure StrokeAndFillPath;
    procedure CloseFigure;

    // clipping methods...
    procedure SetClipEllipse(x, y, x2, y2: Extended; Measurement: TGmMeasurement);           {$IFDEF D4+} overload; {$ENDIF}
    procedure SetClipRect(x, y, x2, y2: Extended; Measurement: TGmMeasurement);              {$IFDEF D4+} overload; {$ENDIF}
    procedure SetClipRoundRect(x, y, x2, y2, x3, y3: Extended; Measurement: TGmMeasurement); {$IFDEF D4+} overload; {$ENDIF}
    procedure RemoveClipRgn;
    {$IFDEF D4+}
    procedure SetClipEllipse(x, y, x2, y2: Extended); overload;
    procedure SetClipRect(x, y, x2, y2: Extended); overload;
    procedure SetClipRoundRect(x, y, x2, y2, x3, y3: Extended); overload;
    {$ENDIF}

    // brush, font & pen methods...
    procedure SetBrushValues(AColor: TColor; AStyle: TBrushStyle);
    procedure SetFontHeight(AHeight: Extended; Measurement: TGmMeasurement);
    procedure SetFontValues(AName: string; ASize: integer; AColor: TColor; AStyle: TFontStyles);
    procedure SetPenValues(AWidth: integer; AColor: TColor; AStyle: TPenStyle);

    procedure LoadCanvasProperties;
    procedure SaveCanvasProperties;
    // properties...
    property AllowDrag: Boolean read FAllowDrag write FAllowDrag default True;
    property Brush: TBrush read FBrush write SetBrush;
    property CopyMode: TCopyMode read FCopyMode write FCopyMode default cmSrcCopy;
    property DefaultAlignment: TAlignment read FDefaultAlignment write FDefaultAlignment default taLeftJustify;
    property DefaultVertAlignment: TGmVertAlignment read FDefaultVertAlignment write FDefaultVertAlignment default gmTop;
    property Font: TFont read FFont write SetFont;
    property LastObject: TGmBaseObject read FLastObject;
    property Pen: TPen read FPen write SetPen;
    property PenPos[Measurement: TGmMeasurement]: TGmPoint read GetPenPos;
    property TextBoxPadding: TGmValue read FTextBoxPadding write SetTextBoxPadding;
    property WordWrap: Boolean read FWordWrap write FWordWrap default True;
  published
    property CompareGraphics: Boolean read GetCompareImages write SetCompareImages;
    property CoordsRelativeTo: TGmCoordsRelative read FCoordsRelativeTo write FCoordsRelativeTo default gmFromPage;
    property DefaultMeasurement: TGmMeasurement read FDefaultMeasurement write FDefaultMeasurement default gmMillimeters;
  end;

implementation

uses GmObjects, GmConst, GmFuncs, GmPageList, SysUtils;

//------------------------------------------------------------------------------

constructor TGmCanvasSavedValues.Create;
begin
  inherited Create;
  FBrush := TBrush.Create;
  FFont := TFont.Create;
  FPen := TPen.Create;
end;

destructor TGmCanvasSavedValues.Destroy;
begin
  FBrush.Free;
  FFont.Free;
  FPen.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

constructor TGmCanvas.Create(APageList: TGmObjectList);
begin
  inherited Create;
  FResourceTable := TGmPageList(APageList).ResourceTable;
  FBrush := TBrush.Create;
  FFont := TFont.Create;
  FPen := TPen.Create;
  FGmBrush := TGmBrush.Create;
  FGmFont := TGmFont.Create;
  FGmPen := TGmPen.Create;
  FExtentValue := TGmValueSize.Create;
  FPropertyStream := TMemoryStream.Create;
  FTextBoxPadding := TGmValue.Create;
  FSavedValues := TGmCanvasSavedValues.Create;
  FPageList := APageList;
  FAllowDrag := True;
  FFontAngle := 0;
  FBrush.Style := bsClear;
  FFont.Name := DEFAULT_FONT;
  FFont.Size := DEFAULT_FONT_SIZE;
  FCoordsRelativeTo := gmFromPage;
  FCopyMode := cmSrcCopy;
  FDefaultMeasurement := gmMillimeters;
  FWordWrap := True;
  FTextBoxPadding.AsMillimeters := 1;
  FDefaultAlignment := taLeftJustify;
  FDefaultVertAlignment := gmTop;
end;

destructor TGmCanvas.Destroy;
begin
  FGmBrush.Free;
  FBrush.Free;
  FGmFont.Free;
  FFont.Free;
  FPen.Free;
  FGmPen.Free;
  FExtentValue.Free;
  FPropertyStream.Free;
  FTextBoxPadding.Free;
  FSavedValues.Free;
  inherited Destroy;
end;

function TGmCanvas.GraphicExtent(AGraphic: TGraphic): TGmValueSize;
var
  AExtent: TGmValueSize;
begin
  AExtent := TGmValueSize.Create;
  try
    AExtent.Height.AsInches := GraphicHeight(AGraphic).AsInches;
    AExtent.Width.AsInches  := GraphicWidth(AGraphic).AsInches;
    FExtentValue.Assign(AExtent);
    Result := FExtentValue;
  finally
    AExtent.Free;
  end;
end;

function TGmCanvas.GraphicHeight(AGraphic: TGraphic): TGmValue;
begin
  Result := FExtentValue.Height;
  Result.AsInches := AGraphic.Height / 96;
end;

function TGmCanvas.GraphicWidth(AGraphic: TGraphic): TGmValue;
begin
  Result := FExtentValue.Width;
  Result.AsInches := AGraphic.Width / 96;
end;

function TGmCanvas.TextExtent(AText: string): TGmValueSize;
var
  InchSize: TGmSize;
begin
  Result := FExtentValue;
  InchSize := GmFuncs.TextExtent(AText, FFont);
  Result.Height.AsInches := InchSize.Height;
  Result.Width.AsInches := InchSize.Width;
end;

function TGmCanvas.TextHeight(AText: string): TGmValue;
begin
  Result := FExtentValue.Height;
  Result.AsInches := GmFuncs.TextExtent(AText, FFont).Height;
end;

function TGmCanvas.TextWidth(AText: string): TGmValue;
begin
  Result := FExtentValue.Width;
  Result.AsInches := GmFuncs.TextExtent(AText, FFont).Width;
end;

function TGmCanvas.TextBoxHeight(AWidth: Extended; AText: string; Measurement: TGmMeasurement): Extended;
var
  inchWidth: Extended;
begin
  inchWidth := ConvertValue(AWidth, Measurement, gmInches);
  Result := TextBoxHeightExt(inchWidth, FTextBoxPadding.AsGmValue[gmInches], AText, gmInches);
  Result := ConvertValue(Result, gmInches, Measurement);
end;

procedure TGmCanvas.Line(X, Y, X2, Y2: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmLineObject;
begin
  AObject := TGmLineObject.Create(FResourceTable);
  AObject.Pen := FResourceTable.PenList.AddPen(AsGmPen);
  AObject.Coords[gmInches]  := ConvertGmRect(GmRect(X, Y, X2, Y2), Measurement, gmInches);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.LineTo(x, y: Extended; Measurement: TGmMeasurement);
var
  EndPos: TGmPoint;
begin
  EndPos := ConvertGmPoint(GmPoint(x, y), Measurement, gmInches);
  Line(FPenPos.X, FPenPos.Y, EndPos.X, EndPos.Y, gmInches);
  FPenPos := EndPos;
end;

procedure TGmCanvas.MoveTo(x, y: Extended; Measurement: TGmMeasurement);
var
  NewPos: TGmPoint;
begin
  NewPos := GmPoint(x, y);
  FPenPos := ConvertGmPoint(NewPos, Measurement, gmInches);
end;

{$IFDEF D4+}

procedure TGmCanvas.Line(x, y, x2, y2: Extended);
begin
  Line(x, y, x2, y2, FDefaultMeasurement);
end;

procedure TGmCanvas.LineTo(x, y: Extended);
begin
  LineTo(x, y, FDefaultMeasurement);
end;

procedure TGmCanvas.MoveTo(x, y: Extended);
begin
  MoveTo(x, y, FDefaultMeasurement);
end;
  
{$ENDIF}

procedure TGmCanvas.Ellipse(x, y, x2, y2: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmEllipseShape;
begin
  AObject := TGmEllipseShape.Create(FResourceTable);
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  AObject.Coords[gmInches]  := ConvertGmRect(GmRect(X, Y, X2, Y2), Measurement, gmInches);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.Rectangle(x, y, x2, y2: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmRectangleShape;
begin
  AObject := TGmRectangleShape.Create(FResourceTable);
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  AObject.Coords[gmInches]  := ConvertGmRect(GmRect(X, Y, X2, Y2), Measurement, gmInches);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.RoundRect(x, y, x2, y2, x3, y3: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmRoundRectShape;
begin
  AObject := TGmRoundRectShape.Create(FResourceTable);
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  AObject.Coords[gmInches]  := ConvertGmRect(GmRect(X, Y, X2, Y2), Measurement, gmInches);
  AObject.X3[gmInches] := ConvertValue(x3, Measurement, gmInches);
  AObject.Y3[gmInches] := ConvertValue(y3, Measurement, gmInches);
  FLastObject := AddObjectToPage(AObject);
end;

{$IFDEF D4+}

procedure TGmCanvas.Ellipse(x, y, x2, y2: Extended);
begin
  Ellipse(x, y, x2, y2, FDefaultMeasurement);
end;

procedure TGmCanvas.Rectangle(x, y, x2, y2: Extended);
begin
  Rectangle(x, y, x2, y2, FDefaultMeasurement);
end;

procedure TGmCanvas.RoundRect(x, y, x2, y2, x3, y3: Extended);
begin
  RoundRect(x, y, x2, y2, x3, y3, FDefaultMeasurement);
end;

{$ENDIF}

function TGmCanvas.AddObjectToPage(AObject: TGmBaseObject): TGmBaseObject;
begin
  Result := TGmPageList(FPageList).AddObject(AObject, FCoordsRelativeTo);
  if (AObject is TGmVisibleObject) then
    (AObject as TGmVisibleObject).AllowDrag := FAllowDrag;
end;

function TGmCanvas.AsGmBrush: TGmBrush;
begin
  Result := FGmBrush;
  FGmBrush.Assign(FBrush);
end;

function TGmCanvas.AsGmFont: TGmFont;
begin
  Result := FGmFont;
  FGmFont.Assign(FFont);
  FGmFont.Angle := FFontAngle;
end;

function TGmCanvas.AsGmPen: TGmPen;
begin
  Result := FGmPen;
  FGmPen.Assign(FPen);
end;

function TGmCanvas.GetCompareImages: Boolean;
begin
  Result := FResourceTable.GraphicList.GraphicCompare;
end;

function TGmCanvas.GetPenPos(Measurement: TGmMeasurement): TGmPoint;
begin
  Result := ConvertGmPoint(FPenPos, gmInches, Measurement);
end;

procedure TGmCanvas.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TGmCanvas.SetCompareImages(Value: Boolean);
begin
  FResourceTable.GraphicList.GraphicCompare := Value;
end;

procedure TGmCanvas.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TGmCanvas.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TGmCanvas.SetTextBoxPadding(Value: TGmValue);
begin
  FTextBoxPadding.Assign(Value);
end;

function TGmCanvas.TextBoxHeightExt(AWidth, Padding: Extended; AText: string; Measurement: TGmMeasurement): Extended;
var
  CalcRect: TRect;
  AsPixels: integer;
  PaddInch: Extended;
  Ppi: integer;
begin
  Ppi := CALC_PPI;
  CalcRect.Left   := 0;
  CalcRect.Top    := 0;
  CalcRect.Right  := Round(ConvertValue(AWidth - (2 * Padding), Measurement, GmInches) * Ppi) ;
  PaddInch := ConvertValue(Padding, Measurement, gmInches);
  GmFontMapper.WrapText := FWordWrap;
  AsPixels := Round(GmFontMapper.TextBoxHeight(FFont, CalcRect, AText) * Ppi);
  Result := ConvertValue((AsPixels / Ppi)+(2*PaddInch), gmInches, Measurement);
end;

procedure TGmCanvas.TextOutExt(X, Y, Angle: Extended; AClipRect: PGmRect; AText: string; Measurement: TGmMeasurement);
var
  AObject: TGmTextObject;
begin
  AObject := TGmTextObject.Create(FResourceTable);
  AObject.X[Measurement] := X;
  AObject.Y[Measurement] := Y;
  AObject.Caption := AText;
  if AClipRect <> nil then
    AObject.ClipRect[Measurement] := AClipRect^
  else
    AObject.ClipRect[gmInches] := GmRect(-1, -1, -1, -1);
  FFontAngle := Angle;
  try
    AObject.Font  := FResourceTable.FontList.AddFont(AsGmFont);
  finally
    FFontAngle := 0;
  end;
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.FloatOut(x, y, Value: Extended; Format: string; Measurement: TGmMeasurement);
var
  AStrValue: string;
begin
  // draw a float value to the page with a specific format...
  AStrValue := FormatFloat(Format, Value);
  TextOutRight(x, y, AStrValue, Measurement);
end;

procedure TGmCanvas.RotateOut(X, Y, Angle: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextOutExt(X, Y, Angle, nil, AText, Measurement);
end;

procedure TGmCanvas.TextClipped(x, y: Extended; AText: string; AWidth: Extended; Alignment: TAlignment; Measurement: TGmMeasurement);
var
  tmpRect: TgmRect;
begin
  tmpRect.Top := y;
  tmpRect.Bottom := y + TextHeight(AText).AsGmValue[Measurement];
  if Alignment = taLeftJustify then
  begin
    tmpRect.Left := x;
    tmpRect.Right := x + AWidth;
  end
  else
  if Alignment = taRightJustify then
  begin
    tmpRect.Left := x - AWidth;
    tmpRect.Right := x;
    x := x - TextWidth(AText).AsGmValue[Measurement];
  end
  else
  begin
    x := x - (TextWidth(AText).AsGmValue[Measurement] / 2);
    tmpRect.Left := x + ((TextWidth(AText).AsGmValue[Measurement] - AWidth) / 2);
    tmpRect.Right := tmpRect.Left + AWidth;
  end;
  TextOutExt(x, y, 0, @tmpRect, AText, Measurement);
end;

procedure TGmCanvas.TextOut(X, Y: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextOutExt(X, Y, 0, nil, AText, Measurement);
end;

procedure TGmCanvas.TextOutCenter(x, y: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextOut(x-(TextWidth(AText).AsGmValue[Measurement] / 2), y, AText, Measurement);
end;

procedure TGmCanvas.TextOutRight(x, y: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextOut(x-TextWidth(AText).AsGmValue[Measurement], y, AText, Measurement);
end;

procedure TGmCanvas.TextRect(ARect: TGmRect; x, y: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextOutExt(x, y, 0, @ARect, AText, Measurement);
end;

{$IFDEF D4+}

procedure TGmCanvas.FloatOut(x, y, Value: Extended; Format: string);
begin
  FloatOut(x, y, Value, Format, FDefaultMeasurement);
end;

procedure TGmCanvas.RotateOut(x, y, Angle: Extended; AText: string);
begin
  RotateOut(x, y, Angle, AText, FDefaultMeasurement);
end;

procedure TGmCanvas.TextOut(x, y: Extended; AText: string);
begin
  TextOut(x, y, AText, FDefaultMeasurement);
end;

procedure TGmCanvas.TextOutCenter(x, y: Extended; AText: string);
begin
  TextOutCenter(x, y, AText, FDefaultMeasurement);
end;

procedure TGmCanvas.TextOutRight(x, y: Extended; AText: string);
begin
  TextOutRight(x, y, AText, FDefaultMeasurement);
end;

{$ENDIF}

procedure TGmCanvas.TextBox(x, y, x2, y2: Extended; AText: string; Measurement: TGmMeasurement);
begin
  TextBoxExt(x, y, x2, y2, FTextBoxPadding.AsGmValue[Measurement], AText,
    FDefaultAlignment, FDefaultVertAlignment, Measurement);
end;

procedure TGmCanvas.TextBoxExt(x, y, x2, y2, Padding: Extended; AText: string;
      Alignment: TAlignment; VertAlignment: TGmVertAlignment; Measurement: TGmMeasurement);
var
  ATextBox: TGmTextBoxObject;
  ATextHeight: Extended;
  PaddingInch: Extended;
begin
  // create a textbox object and set its values...
  ATextBox := TGmTextBoxObject.Create(FResourceTable);
  ATextBox.X[Measurement] := x;
  ATextBox.Y[Measurement] := y;
  ATextBox.X2[Measurement] := x2;

  PaddingInch := ConvertValue(Padding, Measurement, gmInches);

  if (Y2 = 0) or (VertAlignment <> gmTop) then
  begin
    ATextHeight := TextBoxHeightExt((ATextBox.X2[gmInches] - ATextBox.X[gmInches]),
                                    PaddingInch,
                                    AText,
                                    gmInches);
    if Y2 = 0 then
      ATextBox.Y2[gmInches] := ATextBox.Y[gmInches] + ATextHeight
    else
      ATextBox.Y2[Measurement] := y2;
  end
  else
  begin
    ATextBox.Y2[Measurement] := y2;
    ATextHeight := ATextBox.Y2[gmInches] - ATextBox.Y[gmInches];
  end;

  ATextBox.Padding := PaddingInch;
  ATextBox.TextHeight := ATextHeight;
  ATextBox.Alignment := Alignment;
  ATextBox.VertAlignment := VertAlignment;
  ATextBox.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  ATextBox.Font  := FResourceTable.FontList.AddFont(AsGmFont);
  ATextBox.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  ATextBox.Caption := AText;
  ATextBox.WordBreak := FWordWrap;
  FLastObject := AddObjectToPage(ATextBox);
end;

{$IFDEF D4+}

procedure TGmCanvas.TextBox(x, y, x2, y2: Extended; AText: string; Alignment: TAlignment; VertAlignment: TGmVertAlignment;
  Measurement: TGmMeasurement);
begin
  TextBoxExt(x, y, x2, y2, FTextBoxPadding.AsGmValue[Measurement], AText,
    Alignment, VertAlignment, Measurement);
end;

{$ENDIF}

procedure TGmCanvas.Arc(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmArcShape;
  ACoords: TGmComplexCoords;
begin
  AObject := TGmArcShape.Create(FResourceTable);
  ACoords := GmComplexCoords(x, y, x2, y2, x3, y3, x4, y4);
  AObject.Coords[Measurement] := ACoords;
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.Chord(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmChordShape;
  ACoords: TGmComplexCoords;
begin
  AObject := TGmChordShape.Create(FResourceTable);
  ACoords := GmComplexCoords(x, y, x2, y2, x3, y3, x4, y4);
  AObject.Coords[Measurement] := ACoords;
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.Pie(x, y, x2, y2, x3, y3, x4, y4: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmPieShape;
  ACoords: TGmComplexCoords;
begin
  AObject := TGmPieShape.Create(FResourceTable);
  ACoords := GmComplexCoords(x, y, x2, y2, x3, y3, x4, y4);
  AObject.Coords[Measurement] := ACoords;
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

{$IFDEF D4+}

procedure TGmCanvas.Arc(x, y, x2, y2, x3, y3, x4, y4: Extended);
begin
  Arc(x, y, x2, y2, x3, y3, x4, y4, FDefaultMeasurement);
end;

procedure TGmCanvas.Chord(x, y, x2, y2, x3, y3, x4, y4: Extended);
begin
  Chord(x, y, x2, y2, x3, y3, x4, y4, FDefaultMeasurement);
end;

procedure TGmCanvas.Pie(x, y, x2, y2, x3, y3, x4, y4: Extended);
begin
  Pie(x, y, x2, y2, x3, y3, x4, y4, FDefaultMeasurement);
end;

{$ENDIF}

procedure TGmCanvas.Draw(x, y: Extended; AGraphic: TGraphic; Scale: Extended; Measurement: TGmMeasurement);
var
  ARect: TGmRect;
  GraphicSize: TGmSize;
begin
  // Create an Graphic object and add it to the page objects list...
  GraphicSize.Height := GraphicExtent(AGraphic).Height.AsGmValue[Measurement];
  GraphicSize.Width  := GraphicExtent(AGraphic).Width.AsGmValue[Measurement];
  ARect.Left    := x;
  ARect.Top     := y;
  ARect.Right   := x + (GraphicSize.Width * Scale);
  ARect.Bottom  := y + (GraphicSize.Height * Scale);
  StretchDraw(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, AGraphic, Measurement);
end;

procedure TGmCanvas.StretchDraw(x, y, x2, y2: Extended; AGraphic: TGraphic; Measurement: TGmMeasurement);
var
  AObject: TGmGraphicObject;
begin                                   
  AObject := TGmGraphicObject.Create(FResourceTable);
  AObject.Graphic := AGraphic;
  AObject.CopyMode := FCopyMode;
  AObject.Coords[gmInches]  := ConvertGmRect(GmRect(X, Y, X2, Y2), Measurement, gmInches);
  FLastObject := AddObjectToPage(AObject);
end;

{$IFDEF D4+}

procedure TGmCanvas.Draw(x, y: Extended; AGraphic: TGraphic; const Scale: Extended = 1);
begin
  Draw(x, y, AGraphic, Scale, FDefaultMeasurement);
end;

procedure TGmCanvas.StretchDraw(x, y, x2, y2: Extended; AGraphic: TGraphic);
begin
  StretchDraw(x, y, x2, y2, AGraphic, FDefaultMeasurement);
end;

{$ENDIF}

procedure TGmCanvas.Polygon(Points: array of TGmPoint; Measurement: TGmMeasurement);
var
  AObject: TGmPolygonObject;
  APolyPoints: TGmPolyPoints;
begin
  ArrayToPolyPoints(Points, APolyPoints);
  AObject := TGmPolygonObject.Create(FResourceTable);
  AObject.Points[Measurement] := APolyPoints;
  AObject.Brush := FResourceTable.BrushList.AddBrush(AsGmBrush);
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.Polyline(Points: array of TGmPoint; Measurement: TGmMeasurement);
var
  AObject: TGmPolylineObject;
  APolyPoints: TGmPolyPoints;
begin
  ArrayToPolyPoints(Points, APolyPoints);
  AObject := TGmPolylineObject.Create(FResourceTable);
  AObject.Points[Measurement] := APolyPoints;
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.PolyBezier(Points: array of TGmPoint; Measurement: TGmMeasurement);
var
  AObject: TGmPolyBezierObject;
  APolyPoints: TGmPolyPoints;
begin
  ArrayToPolyPoints(Points, APolyPoints);
  AObject := TGmPolyBezierObject.Create(FResourceTable);
  AObject.Points[Measurement] := APolyPoints;
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.PolylineTo(Points: array of TGmPoint; Measurement: TGmMeasurement);
var
  AObject: TGmPolylineToObject;
  APolyPoints: TGmPolyPoints;
begin
  ArrayToPolyPoints(Points, APolyPoints);
  AObject := TGmPolylineToObject.Create(FResourceTable);
  AObject.Points[Measurement] := APolyPoints;
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.PolyBezierTo(Points: array of TGmPoint; Measurement: TGmMeasurement);
var
  AObject: TGmPolyBezierToObject;
  APolyPoints: TGmPolyPoints;
begin
  ArrayToPolyPoints(Points, APolyPoints);
  AObject := TGmPolyBezierToObject.Create(FResourceTable);
  AObject.Points[Measurement] := APolyPoints;
  AObject.Pen   := FResourceTable.PenList.AddPen(AsGmPen);
  FLastObject := AddObjectToPage(AObject);
end;

procedure TGmCanvas.BeginPath;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmBeginPath;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.EndPath;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmEndPath;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.FillPath;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmFillPath;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.StrokePath;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmStrokePath;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.StrokeAndFillPath;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmStrokeAndFillPath;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.CloseFigure;
var
  AObject: TGmPathObject;
begin
  AObject := TGmPathObject.Create(FResourceTable);
  AObject.ObjectType := gmCloseFigure;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.SetClipEllipse(x, y, x2, y2: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmClipEllipseObject;
  ARect: TGmRect;
begin
  AObject := TGmClipEllipseObject.Create(FResourceTable);
  ARect := GmRect(x, y, x2, y2);
  ARect := ConvertGmRect(ARect, Measurement, gmInches);
  AObject.ClipRect := ARect;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.SetClipRect(x, y, x2, y2: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmClipRectObject;
  ARect: TGmRect;
begin
  AObject := TGmClipRectObject.Create(FResourceTable);
  ARect := GmRect(x, y, x2, y2);
  ARect := ConvertGmRect(ARect, Measurement, gmInches);
  AObject.ClipRect := ARect;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.SetClipRoundRect(x, y, x2, y2, x3, y3: Extended; Measurement: TGmMeasurement);
var
  AObject: TGmClipRoundRectObject;
  ARect: TGmRect;
  ACorners: TGmPoint;
begin
  AObject := TGmClipRoundRectObject.Create(FResourceTable);
  ARect := GmRect(x, y, x2, y2);
  ACorners := GmPoint(x3, y3);
  ARect := ConvertGmRect(ARect, Measurement, gmInches);
  ACorners := ConvertGmPoint(ACorners, Measurement, gmInches);
  AObject.ClipRect := ARect;
  AObject.CornerRadius := ACorners;
  AddObjectToPage(AObject);
end;

procedure TGmCanvas.RemoveClipRgn;
var
  AObject: TGmRemoveClipObject;
begin
  AObject := TGmRemoveClipObject.Create(FResourceTable);
  AddObjectToPage(AObject);
end;

{$IFDEF D4+}

procedure TGmCanvas.SetClipEllipse(x, y, x2, y2: Extended);
begin
  SetClipEllipse(x, y, x2, y2, FDefaultMeasurement);
end;

procedure TGmCanvas.SetClipRect(x, y, x2, y2: Extended);
begin
  SetClipRect(x, y, x2, y2, FDefaultMeasurement);
end;

procedure TGmCanvas.SetClipRoundRect(x, y, x2, y2, x3, y3: Extended);
begin
  SetClipRoundRect(x, y, x2, y2, x3, y3, FDefaultMeasurement);
end;

{$ENDIF}

procedure TGmCanvas.SetBrushValues(AColor: TColor; AStyle: TBrushStyle);
begin
  FBrush.Color := AColor;
  FBrush.Style := AStyle;
end;

procedure TGmCanvas.SetFontHeight(AHeight: Extended; Measurement: TGmMeasurement);
var
  AsInches: Extended;
begin
  AsInches := ConvertValue(AHeight, Measurement, gmInches);
  FFont.Height := Round(AsInches * SCREEN_PPI);
end;

procedure TGmCanvas.SetFontValues(AName: string; ASize: integer; AColor: TColor; AStyle: TFontStyles);
begin
  if AName <> '' then FFont.Name := AName;
  FFont.Size := ASize;
  FFont.Color := AColor;
  FFont.Style := AStyle;
end;

procedure TGmCanvas.SetPenValues(AWidth: integer; AColor: TColor; AStyle: TPenStyle);
begin
  FPen.Width := AWidth;
  FPen.Color := AColor;
  FPen.Style := AStyle;
end;

procedure TGmCanvas.LoadCanvasProperties;
begin
  FCoordsRelativeTo := FSavedValues.FCoordsRelativeTo;
  FBrush.Assign(FSavedValues.FBrush);
  FFont.Assign(FSavedValues.FFont);
  FPen.Assign(FSavedValues.FPen);
end;

procedure TGmCanvas.SaveCanvasProperties;
begin
  FSavedValues.FCoordsRelativeTo := FCoordsRelativeTo;
  FSavedValues.FBrush.Assign(FBrush);
  FSavedValues.FFont.Assign(FFont);
  FSavedValues.FPen.Assign(FPen);
end;

end.

