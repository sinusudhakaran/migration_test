{******************************************************************************}
{                                                                              }
{                               GmObjects.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmObjects;

interface

uses Windows, Graphics, GmClasses, GmResource, GmTypes, GmStream, Classes;

const

  // *** GmObject ID constants ***

  GM_TEXT_OBJECT_ID           = 0;
  GM_LINE_OBJECT_ID           = 1;
  GM_RECTANGLE_OBJECT_ID      = 2;
  GM_ELLIPSE_OBJECT_ID        = 3;
  GM_ROUNDRECT_OBJECT_ID      = 4;
  GM_ARC_ID                   = 5;
  GM_CHORD_ID                 = 6;
  GM_PIE_ID                   = 7;
  GM_PATH_OBJECT_ID           = 8;
  GM_REMOVE_CLIP_OBJECT_ID    = 9;
  GM_CLIPRECT_OBJECT_ID       = 10;
  GM_CLIPROUNDRECT_OBJECT_ID  = 11;
  GM_CLIPELLIPSE_OBJECT_ID    = 12;
  GM_GRAPHIC_OBJECT_ID        = 13;
  GM_TEXTBOX_OBJECT_ID        = 14;
  GM_POLYGON_OBJECT_ID        = 15;
  GM_POLYLINE_OBJECT_ID       = 16;
  GM_POLYBEZIER_OBJECT_ID     = 17;
  GM_POLYLINETO_OBJECT_ID     = 18;
  GM_POLYBEZIERTO_OBJECT_ID   = 19;

type
  //----------------------------------------------------------------------------

  // *** TGmOutlineShape ***

  TGmOutlineShape = class(TGmVisibleObject)
  private
    FPen: TGmPen;
    FSavePen: TGmPen;
    function GetPen: TGmPen;
    procedure PenChanged(Sender: TObject);
    procedure SetPen(Value: TGmPen);
  protected
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
    property Pen: TGmPen read GetPen write SetPen;
  public
    destructor Destroy; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmSolidShape ***

  TGmSolidShape = class(TGmOutlineShape)
  private
    FBrush: TGmBrush;
    FSaveBrush: TGmBrush;
    function GetBrush: TGmBrush;
    procedure BrushChanged(Sender: TObject);
    procedure SetBrush(Value: TGmBrush);
  protected
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
    property Brush: TGmBrush read GetBrush write SetBrush;
  public
    destructor Destroy; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBaseSolidShape ***

  TGmBaseSolidShape = class(TGmSolidShape)
  private
    FCoords: TGmRect;
    function GetCoords(Measurement: TGmMeasurement): TGmRect;
    function GetX(Measurement: TGmMeasurement): Extended;
    function GetY(Measurement: TGmMeasurement): Extended;
    function GetX2(Measurement: TGmMeasurement): Extended;
    function GetY2(Measurement: TGmMeasurement): Extended;
    procedure SetCoords(Measurement: TGmMeasurement; Value: TGmRect);
    procedure SetX(Measurement: TGmMeasurement; Value: Extended);
    procedure SetY(Measurement: TGmMeasurement; Value: Extended);
    procedure SetX2(Measurement: TGmMeasurement; Value: Extended);
    procedure SetY2(Measurement: TGmMeasurement; Value: Extended);
  protected
    function CoordsAsPixels(PpiX, PpiY: integer): TRect;
    property Coords[Measurement: TGmMeasurement]: TGmRect read GetCoords write SetCoords;
    property X[Measurement: TGmMeasurement]: Extended read GetX write SetX;
    property Y[Measurement: TGmMeasurement]: Extended read GetY write SetY;
    property X2[Measurement: TGmMeasurement]: Extended read GetX2 write SetX2;
    property Y2[Measurement: TGmMeasurement]: Extended read GetY2 write SetY2;
  public
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmSimpleSolidShape ***

  TGmSimpleSolidShape = class(TGmBaseSolidShape)
  protected
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
    property Coords;
  public
    property X;
    property Y;
    property X2;
    property Y2;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBaseTextObject ***

  TGmBaseTextObject = class(TGmBaseSolidShape)
  private
    FCaption: string;
    FClipRect: TGmRect;
    FFont: TGmFont;
    FSaveFont: TGmFont;
    function GetClipRect(Measurement: TGmMeasurement): TGmRect;
    function GetFont: TGmFont;
    procedure FontChanged(Sender: TObject);
    procedure SetCaption(Value: string);
    procedure SetClipRect(Measurement: TGmMeasurement; Value: TGmRect);
    procedure SetFont(Value: TGmFont);
  protected
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    destructor Destroy; override;
    property Caption: string read FCaption write SetCaption;
    property ClipRect[Measurement: TGmMeasurement]: TGmRect read GetClipRect write SetClipRect;
    property Brush;
    property Font: TGmFont read GetFont write SetFont;
    property Pen;
    property X;
    property Y;
  end;

  //----------------------------------------------------------------------------

  // *** TGmTextObject ***

  TGmTextObject = class(TGmBaseTextObject)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  public
    function BoundingRect(Data: TGmObjectDrawData): TGmRectPoints; override;
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmLineObject ***

  TGmLineObject = class(TGmSimpleSolidShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  public
    function BoundingRect(Data: TGmObjectDrawData): TGmRectPoints; override;
    property Coords;
    property Pen;
  end;

  //----------------------------------------------------------------------------

  // *** TGmGraphicObject ***

  TGmGraphicObject = class(TGmSimpleSolidShape)
  private
    FCopyMode: TCopyMode;
    FGraphic: TGraphic;
    FPrintPixelFormat: TPixelFormat;
    procedure SetGraphic(AGraphic: TGraphic);
  protected
    function GetObjectID: integer; override;
     procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
     procedure LoadFromValueList(Values: TGmValueList); override;
     procedure SaveToValueList(Values: TGmValueList); override;
  public
    constructor Create(AResourceTable: TGmResourceTable); override;
    property Coords;
    property CopyMode: TCopyMode read FCopyMode write FCopyMode;
    property Graphic: TGraphic read FGraphic write SetGraphic;
    property PrintPixelFormat: TPixelFormat read FPrintPixelFormat write FPrintPixelFormat default pf8bit;
  end;

  //----------------------------------------------------------------------------

  // *** TGmTextBoxObject ***

  TGmTextBoxObject = class(TGmBaseTextObject)
  private
    FAlignment: TAlignment;
    FClipText: Boolean;
    FPadding: Extended;
    FTextHeight: Extended;
    FVertAlignment: TGmVertAlignment;
    FWordBreak: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetClipText(Value: Boolean);
    procedure SetPadding(Value: Extended);
    procedure SetWordBreak(Value: Boolean);
    procedure SetVertAlignment(Value: TGmVertAlignment);
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    constructor Create(AResourceTable: TGmResourceTable); override;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ClipText: Boolean read FClipText write SetClipText default True;
    property Coords;
    property Padding: Extended read FPadding write SetPadding;
    property TextHeight: Extended read FTextHeight write FTextHeight;
    property VertAlignment: TGmVertAlignment read FVertAlignment write SetVertAlignment default gmTop;
    property WordBreak: Boolean read FWordBreak write SetWordBreak default True;
    property X2;
    property Y2;
  end;

  //----------------------------------------------------------------------------

  // *** TGmRectangleShape ***

  TGmRectangleShape = class(TGmSimpleSolidShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  public
    property Brush;
    property Coords;
    property Pen;
  end;

  //----------------------------------------------------------------------------

  // *** TGmEllipseShape ***

  TGmEllipseShape = class(TGmSimpleSolidShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  public
    property Brush;
    property Coords;
    property Pen;
  end;

  //----------------------------------------------------------------------------

  // *** TGmSemiComplexShape ***

  TGmSemiComplexShape = class(TGmSimpleSolidShape)
  private
    FX3: Extended;
    FY3: Extended;
    function GetX3(Measurement: TGmMeasurement): Extended;
    function GetY3(Measurement: TGmMeasurement): Extended;
    procedure SetX3(Measurement: TGmMeasurement; const Value: Extended);
    procedure SetY3(Measurement: TGmMeasurement; const Value: Extended);
  protected
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); override;
    property Brush;
    property Coords;
    property Pen;
    property X3[Measurement: TGmMeasurement]: Extended read GetX3 write SetX3;
    property Y3[Measurement: TGmMeasurement]: Extended read GetY3 write SetY3;
  end;

  //----------------------------------------------------------------------------

  // *** TGmRoundRectShape ***

  TGmRoundRectShape = class(TGmSemiComplexShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmComplexShape ***

  TGmComplexShape = class(TGmSemiComplexShape)
  private
    FX4: Extended;
    FY4: Extended;
    function GetCoords(index: TGmMeasurement): TGmComplexCoords;
    function GetX4(index: TGmMeasurement): Extended;
    function GetY4(index: TGmMeasurement): Extended;
    procedure SetCoords(index: TGmMeasurement; Value: TGmComplexCoords);
    procedure SetX4(index: TGmMeasurement; const Value: Extended);
    procedure SetY4(index: TGmMeasurement; const Value: Extended);
  protected
   procedure LoadFromValueList(Values: TGmValueList); override;
   procedure SaveToValueList(Values: TGmValueList); override;
    property Coords[Measurement: TGmMeasurement]: TGmComplexCoords read GetCoords write SetCoords;
  public
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); override;
    property X4[Measurement: TGmMeasurement]: Extended read GetX4 write SetX4;
    property Y4[Measurement: TGmMeasurement]: Extended read GetY4 write SetY4;
  end;

  //----------------------------------------------------------------------------

  // *** TGmArcShape ***

  TGmArcShape = class(TGmComplexShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmChordShape ***

  TGmChordShape = class(TGmComplexShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPieShape ***

  TGmPieShape = class(TGmComplexShape)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolyBaseObject ***

  TGmPolyBaseObject = class(TGmSolidShape)
  private
    FPoints: TGmPolyPoints;
    function GetPoints(Measurement: TGmMeasurement): TGmPolyPoints;
    procedure SetPoints(Measurement: TGmMeasurement; Value: TGmPolyPoints);
  protected
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); override;
    property Brush;
    property Pen;
    property Points[Measurement: TGmMeasurement]: TGmPolyPoints read GetPoints write SetPoints;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolygonObject ***

  TGmPolygonObject = class(TGmPolyBaseObject)
  protected
    function GetObjectID: integer; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolylineObject ***

  TGmPolylineObject = class(TGmPolyBaseObject)
  protected
    function GetObjectID: integer; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolyBezierObject ***

  TGmPolyBezierObject = class(TGmPolyBaseObject)
  protected
    function GetObjectID: integer; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolylineToObject ***

  TGmPolylineToObject = class(TGmPolyBaseObject)
  protected
    function GetObjectID: integer; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPolyBezierToObject ***

  TGmPolyBezierToObject = class(TGmPolyBaseObject)
  protected
    function GetObjectID: integer; override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPathObject ***

  TGmPathObject = class(TGmBaseObject)
  private
    FObjectType: TGmPathObjectType;
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    property ObjectType: TGmPathObjectType read FObjectType write FObjectType;
  end;

  //----------------------------------------------------------------------------

  // *** TGmRemoveClipObject ***

  TGmRemoveClipObject = class(TGmBaseObject)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBaseClipObject ***

  TGmBaseClipObject = class(TGmBaseObject)
  private
    FClipRect: TGmRect;
  protected
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    property ClipRect: TGmRect read FClipRect write FClipRect;
  end;

  //----------------------------------------------------------------------------
  // *** TGmClipEllipseObject ***

  TGmClipEllipseObject = class(TGmBaseClipObject)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmClipRectObject ***

  TGmClipRectObject = class(TGmBaseClipObject)
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmClipRoundRectObject ***

  TGmClipRoundRectObject = class(TGmClipRectObject)
  private
    FCorners: TGmPoint;
  protected
    function GetObjectID: integer; override;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); override;
    procedure LoadFromValueList(Values: TGmValueList); override;
    procedure SaveToValueList(Values: TGmValueList); override;
  public
    property CornerRadius: TGmPoint read FCorners write FCorners;
  end;

  //----------------------------------------------------------------------------

implementation

uses GmFuncs, GmConst, Jpeg, sysutils;

//------------------------------------------------------------------------------

// *** TGmOutlineShape ***

destructor TGmOutlineShape.Destroy;
begin
  if Assigned(FSavePen) then FSavePen.Free;
  inherited Destroy;
end;

function TGmOutlineShape.GetPen: TGmPen;
begin
  if not Assigned(FSavePen) then
    FSavePen := TGmPen.Create;
  FSavePen.OnChange := nil;
  FSavePen.Assign(FPen);
  FSavePen.OnChange := PenChanged;
  Result := FSavePen;
end;

procedure TGmOutlineShape.PenChanged(Sender: TObject);
begin
  ResourceTable.PenList.DeleteResource(FPen);
  FPen := ResourceTable.PenList.AddPen(FSavePen);
  FSavePen.Free;
  FSavePen := nil;
  Changed;
end;

procedure TGmOutlineShape.SetPen(Value: TGmPen);
begin
  if FPen = nil then
  begin
    FPen := Value;
    Exit;
  end;
  FSavePen := GetPen;
  FSavePen.Assign(Value);
  PenChanged(Self);
end;

procedure TGmOutlineShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  if Assigned(FPen) then FPen.AssignToCanvas(ACanvas, Data.PpiX);
end;


procedure TGmOutlineShape.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FPen     := ResourceTable.PenList.Pen[Values.ReadIntValue(C_P, -1)];
end;

procedure TGmOutlineShape.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  if Assigned(FPen) then
    Values.WriteIntValue(C_P, ResourceTable.PenList.IndexOf(FPen));
end;

//------------------------------------------------------------------------------

// *** TGmSolidShape ***

destructor TGmSolidShape.Destroy;
begin
  if Assigned(FSaveBrush) then FSaveBrush.Free;
  inherited Destroy;
end;

procedure TGmSolidShape.BrushChanged(Sender: TObject);
begin
  ResourceTable.BrushList.DeleteResource(FBrush);
  FBrush := ResourceTable.BrushList.AddBrush(FSaveBrush);
  FSaveBrush.Free;
  FSaveBrush := nil;
  Changed;
end;

function TGmSolidShape.GetBrush: TGmBrush;
begin
  if not Assigned(FSaveBrush) then
    FSaveBrush := TGmBrush.Create;
  FSaveBrush.OnChange := nil;
  FSaveBrush.Assign(FBrush);
  FSaveBrush.OnChange := BrushChanged;
  Result := FSaveBrush;
end;

procedure TGmSolidShape.SetBrush(Value: TGmBrush);
begin
  if FBrush = nil then
  begin
    FBrush := Value;
    Exit;
  end;
  FSaveBrush := GetBrush;
  FSaveBrush.Assign(Value);
  BrushChanged(Self);
end;

procedure TGmSolidShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  if Assigned(FBrush) then FBrush.AssignToCanvas(ACanvas);
end;

procedure TGmSolidShape.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FBrush   := ResourceTable.BrushList.Brush[Values.ReadIntValue(C_B, -1)];
end;

procedure TGmSolidShape.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  if Assigned(FBrush) then
    Values.WriteIntValue(C_B, ResourceTable.BrushList.IndexOf(FBrush));
end;

//------------------------------------------------------------------------------

// *** TGmBaseSolidShape ***

function TGmBaseSolidShape.GetX(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FCoords.Left, gmInches, Measurement);
end;

function TGmBaseSolidShape.GetY(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FCoords.Top, gmInches, Measurement);
end;

function TGmBaseSolidShape.GetX2(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FCoords.Right, gmInches, Measurement);
end;

function TGmBaseSolidShape.GetY2(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FCoords.Bottom, gmInches, Measurement);
end;

function TGmBaseSolidShape.GetCoords(Measurement: TGmMeasurement): TGmRect;
begin
  Result := ConvertGmRect(FCoords, gmInches, Measurement);
end;

procedure TGmBaseSolidShape.SetCoords(Measurement: TGmMeasurement; Value: TGmRect);
begin
  FCoords := ConvertGmRect(Value, Measurement, gmInches);
end;

procedure TGmBaseSolidShape.SetX(Measurement: TGmMeasurement; Value: Extended);
begin
  FCoords.Left := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmBaseSolidShape.SetY(Measurement: TGmMeasurement; Value: Extended);
begin
  FCoords.Top := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmBaseSolidShape.SetX2(Measurement: TGmMeasurement; Value: Extended);
begin
  FCoords.Right := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmBaseSolidShape.SetY2(Measurement: TGmMeasurement; Value: Extended);
begin
  FCoords.Bottom := ConvertValue(Value, Measurement, gmInches);
end;

function TGmBaseSolidShape.CoordsAsPixels(PpiX, PpiY: integer): TRect;
begin
  Result.Left   := Round(FCoords.Left * PpiX);
  Result.Top    := Round(FCoords.Top * PpiY);
  Result.Right  := Round(FCoords.Right * PpiX);
  Result.Bottom := Round(FCoords.Bottom * PpiY);
end;

procedure TGmBaseSolidShape.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
var
  InchOffsetX: Extended;
  InchOffsetY: Extended;
begin
  InchOffsetX := ConvertValue(x, Measurement, gmInches);
  InchOffsetY := ConvertValue(y, Measurement, gmInches);
  OffsetGmRect(FCoords, InchOffsetX, InchOffsetY);
  Changed;
end;

//------------------------------------------------------------------------------

// *** TGmSimpleSolidShape ***

procedure TGmSimpleSolidShape.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FCoords := Values.ReadGmRectValue(C_XY, GmRect(0,0,0,0));
end;

procedure TGmSimpleSolidShape.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteGmRectValue(C_XY, FCoords);
end;

//------------------------------------------------------------------------------

// *** TGmBaseTextObject ***

destructor TGmBaseTextObject.Destroy;
begin
  if Assigned(FSaveFont) then FSaveFont.Free;
  inherited;
end;

procedure TGmBaseTextObject.FontChanged(Sender: TObject);
begin
  ResourceTable.FontList.DeleteResource(FFont);
  FFont := ResourceTable.FontList.AddFont(FSaveFont);
  FSaveFont.Free;
  FSaveFont := nil;
  Changed;
end;

function TGmBaseTextObject.GetClipRect(Measurement: TGmMeasurement): TGmRect;
begin
  Result := ConvertGmRect(FClipRect, gmInches, Measurement);
end;

function TGmBaseTextObject.GetFont: TGmFont;
begin
  if not Assigned(FSaveFont) then
    FSaveFont := TGmFont.Create;
  FSaveFont.OnChange := nil;
  FSaveFont.Assign(FFont);
  FSaveFont.OnChange := FontChanged;
  Result := FSaveFont;
end;

procedure TGmBaseTextObject.SetCaption(Value: string);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  Changed;
end;

procedure TGmBaseTextObject.SetClipRect(Measurement: TGmMeasurement; Value: TGmRect);
var
  NewClipRect: TGmRect;
begin
  NewClipRect := ConvertGmRect(Value, Measurement, gmInches);
  if EqualGmRects(NewClipRect, FClipRect) then Exit;
  FClipRect := NewClipRect;
  Changed;
end;

procedure TGmBaseTextObject.SetFont(Value: TGmFont);
begin
  if FFont = nil then
  begin
    FFont := Value;
    Exit;
  end;
  FSaveFont := GetFont;
  FSaveFont.Assign(Value);
  FontChanged(Self);
end;

procedure TGmBaseTextObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  if Assigned(FFont) then
  begin
    ACanvas.Font.PixelsPerInch := Data.PpiX;
    FFont.AssignToCanvas(ACanvas);
  end;
end;

procedure TGmBaseTextObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FCaption        := Values.ReadStringValue(C_T, '');
  FClipRect       := Values.ReadGmRectValue(C_CR, GmRect(-1, -1, -1, -1));
  FCoords.TopLeft := Values.ReadGmPointValue(C_XY, GmPoint(0,0));
  FFont           := ResourceTable.FontList.Font[Values.ReadIntValue(C_F, -1)];
end;

procedure TGmBaseTextObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteStringValue(C_T, FCaption);
  Values.WriteGmRectValue(C_CR, FClipRect);
  Values.WriteGmPointValue(C_XY, FCoords.TopLeft);
  if Assigned(FFont) then
    Values.WriteIntValue(C_F, ResourceTable.FontList.IndexOf(FFont));
end;

//------------------------------------------------------------------------------

// *** TGmTextObject ***

function TGmTextObject.BoundingRect(Data: TGmObjectDrawData): TGmRectPoints;
var
  ARect: TRect;
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
  Rgn: HRGN;
  Ppi: integer;
begin
  Ppi := Data.PpiX;
  Mf := TMetafile.Create;
  Mfc := TMetafileCanvas.Create(Mf, 0);
  BeginPath(Mfc.Handle);

  try
    Mfc.Font.PixelsPerInch := Ppi;
    FBrush.AssignToCanvas(Mfc);
    FFont.AssignToCanvas(Mfc);
    Mfc.TextOut(Round(X[gmInches] * Ppi),
                Round(Y[gmInches] * Ppi),
                FCaption);
  finally
    EndPath(Mfc.Handle);
    Rgn := PathToRegion(Mfc.Handle);
    GetRgnBox(Rgn, ARect);
    DeleteObject(Rgn);
    Result := RectToGmRectPoints(ARect);
    Mfc.Free;
  end;
  Mf.Free;
end;

function TGmTextObject.GetObjectID: integer;
begin
  Result := GM_TEXT_OBJECT_ID;
end;

procedure TGmTextObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  TokenizedText: string;
  xy: TPoint;
  AClipRect: TRect;
  PClipRect: PRect;
begin
  inherited DrawToCanvas(ACanvas, Data);
  TokenizedText := Tokenize(FCaption, Data.Page, Data.NumPages,
    GlobalDateTokenFormat, GlobalTimeTokenFormat);

  xy.X := Round(X[gmInches] * Data.PpiX);
  xy.y := Round(Y[gmInches] * Data.PpiY);
  if not EqualGmRects(FClipRect, GmRect(-1, -1, -1, -1)) then
  begin
    AClipRect.Left   := Round(FClipRect.Left * Data.PpiX);
    AClipRect.Right  := Round(FClipRect.Right * Data.PpiX);
    AClipRect.Top    := Round(FClipRect.Top * Data.PpiY);
    AClipRect.Bottom := Round(FClipRect.Bottom * Data.PpiY);
    PClipRect := @AClipRect;
  end
  else
    PClipRect := nil;

  ExtTextOut(ACanvas.Handle, xy.X, xy.Y, ETO_CLIPPED, PClipRect, PChar(TokenizedText), Length(TokenizedText), nil)

  {if FFont.Angle <> 0 then
    ExtTextOut(ACanvas.Handle, xy.X, xy.Y, ETO_CLIPPED, PClipRect, PChar(TokenizedText), Length(TokenizedText), nil)
  else
    GmFontMapper.TextOut(ACanvas, xy.X, xy.Y, PClipRect, TokenizedText);}
end;

procedure TGmTextObject.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
begin
  Self.X[gmInches] := Self.X[gmInches] + ConvertValue(x, Measurement, gmInches);
  Self.Y[gmInches] := Self.Y[gmInches] + ConvertValue(y, Measurement, gmInches);
end;

//------------------------------------------------------------------------------

// *** TGmLineObject ***

function TGmLineObject.GetObjectID: integer;
begin
  Result := GM_LINE_OBJECT_ID;
end;

procedure TGmLineObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  ACanvas.MoveTo(Round(X[gmInches] * Data.PpiX), Round(Y[gmInches] * Data.PpiY));
  ACanvas.LineTo(Round(X2[gmInches] * Data.PpiX), Round(Y2[gmInches] * Data.PpiY));
end;

function TGmLineObject.BoundingRect(Data: TGmObjectDrawData): TGmRectPoints;
var
  ARect: TRect;
begin
  ARect := CoordsAsPixels(Data.PpiX, Data.PpiY);
  InflateRect(ARect, 3, 3);
  Result := RectToGmRectPoints(ARect);
end;
//------------------------------------------------------------------------------

// *** TGmGraphicObject ***

constructor TGmGraphicObject.Create(AResourceTable: TGmResourceTable);
begin
  inherited Create(AResourceTable);
  FCopyMode := cmSrcCopy;
  FPrintPixelFormat := pf8bit;
end;

function TGmGraphicObject.GetObjectID: integer;
begin
  Result := GM_GRAPHIC_OBJECT_ID;
end;

procedure TGmGraphicObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FCopyMode         := TCopyMode(Values.ReadIntValue(C_CM, Ord(cmSrcCopy)));
  FPrintPixelFormat := TPixelFormat(Values.ReadIntValue(C_PF, Ord(pf8bit)));
  FGraphic          := ResourceTable.GraphicList.Graphic[Values.ReadIntValue(C_G, -1)];
end;

procedure TGmGraphicObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteIntValue(C_CM, Ord(FCopyMode));
  Values.WriteIntValue(C_PF, Ord(FPrintPixelFormat));
  if Assigned(FGraphic) then
    Values.WriteIntValue(C_G, ResourceTable.GraphicList.IndexOf(FGraphic));
end;

procedure TGmGraphicObject.SetGraphic(AGraphic: TGraphic);

  function SupportedGraphic(AGraphic: TGraphic): Boolean;
  begin
    Result := (AGraphic is TBitmap) or
              (AGraphic is TMetafile) or
              (AGraphic is TJPEGImage);
  end;

var
  ABitmap: TBitmap;
  AJpeg: TJPEGImage;
begin
  if (AGraphic is TIcon) then
  begin
    IconToBitmap((AGraphic as TIcon), ABitmap);
    FGraphic := ResourceTable.GraphicList.AddGraphic(ABitmap);
    ABitmap.Free;
  end
  else
  if SupportedGraphic(AGraphic) then
  begin
    FGraphic := ResourceTable.GraphicList.AddGraphic(AGraphic)
  end
  else
  begin
    GraphicToJPeg(AGraphic, AJpeg);
    FGraphic := ResourceTable.GraphicList.AddGraphic(AJpeg);
    AJpeg.Free;
  end;
  if (FGraphic is TBitmap) then
    FPrintPixelFormat := (FGraphic as TBitmap).PixelFormat;
end;

procedure TGmGraphicObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ABitmap: TBitmap;
begin
  if FGraphic = nil then Exit;
  ACanvas.CopyMode := FCopyMode;
  if (Graphic is TBitmap) or (Graphic is TJpegImage) then
  begin
    ABitmap := TBitmap.Create;
    try
      ABitmap.Assign(Graphic);
      if IsPrinterCanvas(ACanvas) then
      begin
        ABitmap.PixelFormat := FPrintPixelFormat;
        PrintBitmap(ACanvas, CoordsAsPixels(Data.PpiX, Data.PpiY), ABitmap);
      end
      else
        ACanvas.StretchDraw(CoordsAsPixels(Data.PpiX, Data.PpiY), ABitmap);
    finally
      ABitmap.Free;
    end;
  end
  else
    ACanvas.StretchDraw(CoordsAsPixels(Data.PpiX, Data.PpiY), Graphic);
end;

//------------------------------------------------------------------------------

// *** TGmTextBoxObject ***

constructor TGmTextBoxObject.Create(AResourceTable: TGmResourceTable);
begin
  inherited Create(AResourceTable);
  FAlignment := taLeftJustify;
  FClipText := True;
  FVertAlignment := gmTop;
  FWordBreak := True;
end;

procedure TGmTextBoxObject.SetAlignment(Value: TAlignment);
begin
  if FAlignment = Value then Exit;
  FAlignment := Value;
  Changed;
end;

procedure TGmTextBoxObject.SetClipText(Value: Boolean);
begin
  if FClipText = Value then  Exit;
  FClipText := Value;
  Changed;
end;

procedure TGmTextBoxObject.SetPadding(Value: Extended);
begin
  if FPadding = Value then Exit;
  FPadding := Value;
  Changed;
end;

procedure TGmTextBoxObject.SetWordBreak(Value: Boolean);
begin
  if FWordBreak = Value then Exit;
  FWordBreak := Value;
  Changed;
end;

procedure TGmTextBoxObject.SetVertAlignment(Value: TGmVertAlignment);
begin
  if FVertAlignment = Value then Exit;
  FVertAlignment := Value;
  Changed;
end;

function TGmTextBoxObject.GetObjectID: integer;
begin
  Result := GM_TEXTBOX_OBJECT_ID;
end;

procedure TGmTextBoxObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FCoords.BottomRight := Values.ReadGmPointValue(C_XY2, GmPoint(0,0));
  FPadding            := Values.ReadExtValue(C_TP, 0);
  FTextHeight         := Values.ReadExtValue(C_TH, 0);
  FCaption            := Values.ReadStringValue(C_T, '');
  FAlignment          := TAlignment(Values.ReadIntValue(C_TA, Ord(taLeftJustify)));
  FVertAlignment      := TGmVertAlignment(Values.ReadIntValue(C_VA, Ord(gmTop)));
  FClipText           := Values.ReadBoolValue(C_CT, True);
  FWordBreak          := Values.ReadBoolValue(C_WB, True);
  FFont               := ResourceTable.FontList.Font[Values.ReadIntValue(C_F, -1)];
end;

procedure TGmTextBoxObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteGmPointValue(C_XY2, FCoords.BottomRight);
  Values.WriteExtValue(C_TP, FPadding);
  Values.WriteExtValue(C_TH, FTextHeight);
  Values.WriteStringValue(C_T, FCaption);
  if FAlignment <> taLeftJustify then Values.WriteIntValue(C_TA, Ord(FAlignment));
  if FVertAlignment <> gmTop then Values.WriteIntValue(C_VA, Ord(FVertAlignment));
  if FClipText <> True then Values.WriteBoolValue(C_CT, FClipText);
  if FWordBreak <> True then Values.WriteBoolValue(C_WB, FWordBreak);
  Values.WriteIntValue(C_F, ResourceTable.FontList.IndexOf(FFont));
end;

procedure TGmTextBoxObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  AsPixels: TRect;
  PaddingPixels: TPoint;
  TextHeightPixels: Integer;
  TextRect: TRect;
  PaddedRect: TRect;
  TokenizedText: string;
  AAlignment: Byte;
begin
  inherited DrawToCanvas(ACanvas, Data);
  TokenizedText := Tokenize(FCaption, Data.Page, Data.NumPages,
    GlobalDateTokenFormat, GlobalTimeTokenFormat);
  AsPixels := CoordsAsPixels(Data.PpiX, Data.PpiY);
  TextHeightPixels := Round(FTextHeight * Data.PpiY);
  TextRect := AsPixels;
  PaddedRect := TextRect;
  case FVertAlignment of
    gmMiddle: PaddedRect.Top := PaddedRect.Top + ((RectHeight(PaddedRect)- TextHeightPixels) div 2);
    gmBottom: PaddedRect.Top := (PaddedRect.Bottom - TextHeightPixels);
  end;
  PaddingPixels.X := Round(FPadding * Data.PpiX);
  PaddingPixels.Y := Round(FPadding * Data.PpiY);
  InflateRect(PaddedRect, 0-PaddingPixels.X, 0-PaddingPixels.Y);
  GmDrawRect(ACanvas, AsPixels);

  AAlignment := DT_LEFT;
  case FAlignment of
    taCenter: AAlignment := DT_CENTER;
    taRightJustify: AAlignment := DT_RIGHT;
  end;

  if not FWordBreak then
    DrawTextEx(ACanvas.Handle, PChar(TokenizedText), Length(TokenizedText), PaddedRect, DT_EXPANDTABS or AAlignment, nil)
  else
    DrawTextEx(ACanvas.Handle, PChar(TokenizedText), Length(TokenizedText), PaddedRect, DT_WORDBREAK or DT_EXPANDTABS	or AAlignment, nil)


  //GmFontMapper.WrapText := FWordBreak;
  //GmFontMapper.TextBox(ACanvas, PaddedRect, TokenizedText, FAlignment, Data.FastDraw);
end;

//------------------------------------------------------------------------------

// *** TGmRectangleShape ***

function TGmRectangleShape.GetObjectID: integer;
begin
  Result := GM_RECTANGLE_OBJECT_ID;
end;

procedure TGmRectangleShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  GmDrawRect(ACanvas, CoordsAsPixels(Data.PpiX, Data.PpiY));
end;

//------------------------------------------------------------------------------

// *** TGmEllipseShape ***

function TGmEllipseShape.GetObjectID: integer;
begin
  Result := GM_ELLIPSE_OBJECT_ID;
end;

procedure TGmEllipseShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  R: TRect;
begin
  inherited DrawToCanvas(ACanvas, Data);
  R := CoordsAsPixels(Data.PpiX, Data.PpiY);
  BeginPath(ACanvas.Handle);
  GmDrawEllipse(ACanvas, R.Left, R.Top, R.Right, R.Bottom);
  EndPath(ACanvas.Handle);
  StrokeAndFillPath(ACanvas.Handle);
end;

//------------------------------------------------------------------------------

// *** TGmSemiComplexShape ***

function TGmSemiComplexShape.GetX3(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FX3, gmInches, Measurement)
end;

function TGmSemiComplexShape.GetY3(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FY3, gmInches, Measurement)
end;

procedure TGmSemiComplexShape.SetX3(Measurement: TGmMeasurement; const Value: Extended);
var
  NewValue: Extended;
begin
  NewValue := ConvertValue(Value, Measurement, gmInches);
  if FX3 = NewValue then Exit;
  FX3 := NewValue;
  Changed;
end;

procedure TGmSemiComplexShape.SetY3(Measurement: TGmMeasurement; const Value: Extended);
var
  NewValue: Extended;
begin
  NewValue := ConvertValue(Value, Measurement, gmInches);
  if FY3 = NewValue then Exit;
  FY3 := NewValue;
  Changed;
end;

procedure TGmSemiComplexShape.LoadFromValueList(Values: TGmValueList);
var
  XY3: TGmPoint;
begin
  inherited LoadFromValueList(Values);
  XY3 := Values.ReadGmPointValue(C_XY3, GmPoint(0,0));
  FX3 := XY3.X;
  FY3 := XY3.Y;
end;

procedure TGmSemiComplexShape.SaveToValueList(Values: TGmValueList);
var
  XY3: TGmPoint;
begin
  inherited SaveToValueList(Values);
  XY3 := GmPoint(FX3, FY3);
  Values.WriteGmPointValue(C_XY3, XY3);
end;

procedure TGmSemiComplexShape.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
var
  InchOffsetX: Extended;
  InchOffsetY: Extended;
begin
  InchOffsetX := ConvertValue(x, Measurement, gmInches);
  InchOffsetY := ConvertValue(y, Measurement, gmInches);
  FX3 := FX3 + InchOffsetX;
  FY3 := FY3 + InchOffsetY;
  inherited OffsetObject(x, y, Measurement);
end;

//------------------------------------------------------------------------------

// *** TGmRoundRectShape ***

function TGmRoundRectShape.GetObjectID: integer;
begin
  Result := GM_ROUNDRECT_OBJECT_ID;
end;

procedure TGmRoundRectShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  R: TRect;
  C: TPoint;
begin
  inherited DrawToCanvas(ACanvas, Data);
  R := CoordsAsPixels(Data.PpiX, Data.PpiY);
  C.X := Round(X3[gmInches] * Data.PpiX);
  C.Y := Round(Y3[gmInches] * Data.PpiY);
  BeginPath(ACanvas.Handle);
  GmDrawRoundRect(ACanvas, R.Left, R.Top, R.Right, R.Bottom, C.X, C.Y);
  EndPath(ACanvas.Handle);
  StrokeAndFillPath(ACanvas.Handle);
end;

//------------------------------------------------------------------------------

// *** TGmComplexShape ***

function TGmComplexShape.GetCoords(index: TGmMeasurement): TGmComplexCoords;
begin
  Result.X  := X[index];
  Result.Y  := Y[index];
  Result.X2 := X2[index];
  Result.Y2 := Y2[index];
  Result.X3 := X3[index];
  Result.Y3 := Y3[index];
  Result.X4 := X4[index];
  Result.Y4 := Y4[index];
end;

function TGmComplexShape.GetX4(index: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FX4, gmInches, index);
end;

function TGmComplexShape.GetY4(index: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FY4, gmInches, index);
end;

procedure TGmComplexShape.SetCoords(index: TGmMeasurement; Value: TGmComplexCoords);
begin
  X[index]  := ConvertValue(Value.X, index, gmInches);
  Y[index]  := ConvertValue(Value.Y, index, gmInches);
  X2[index] := ConvertValue(Value.X2, index, gmInches);
  Y2[index] := ConvertValue(Value.Y2, index, gmInches);
  X3[index] := ConvertValue(Value.X3, index, gmInches);
  Y3[index] := ConvertValue(Value.Y3, index, gmInches);
  X4[index] := ConvertValue(Value.X4, index, gmInches);
  Y4[index] := ConvertValue(Value.Y4, index, gmInches);
end;

procedure TGmComplexShape.SetX4(index: TGmMeasurement; const Value: Extended);
var
  NewX4: Extended;
begin
  NewX4 := ConvertValue(Value, index, gmInches);
  if FX4 = NewX4 then Exit;
  FX4 := NewX4;
  Changed;
end;

procedure TGmComplexShape.SetY4(index: TGmMeasurement; const Value: Extended);
var
  NewY4: Extended;
begin
  NewY4 := ConvertValue(Value, index, gmInches);
  if FY4 = NewY4 then Exit;
  FY4 := NewY4;
  Changed;
end;

procedure TGmComplexShape.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
var
  InchOffsetX: Extended;
  InchOffsetY: Extended;
begin
  InchOffsetX := ConvertValue(x, Measurement, gmInches);
  InchOffsetY := ConvertValue(y, Measurement, gmInches);
  FX3 := FX3 + InchOffsetX;
  FY3 := FY3 + InchOffsetY;
  inherited OffsetObject(x, y, Measurement);
end;

procedure TGmComplexShape.LoadFromValueList(Values: TGmValueList);
var
  XY4: TGmPoint;
begin
  inherited LoadFromValueList(Values);
  XY4 := Values.ReadGmPointValue(C_XY3, GmPoint(0,0));
  FX4 := XY4.X;
  FY4 := XY4.Y;
end;

procedure TGmComplexShape.SaveToValueList(Values: TGmValueList);
var
  XY4: TGmPoint;
begin
  inherited SaveToValueList(Values);
  XY4 := GmPoint(FX4, FY4);
  Values.WriteGmPointValue(C_XY4, XY4);
end;

//------------------------------------------------------------------------------

// *** TGmArcShape ***

function TGmArcShape.GetObjectID: integer;
begin
  Result := GM_ARC_ID;
end;

procedure TGmArcShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ACoords: TGmComplexCoords;
begin
  inherited DrawToCanvas(ACanvas, Data);
  ACoords := Coords[gmInches];
  ACanvas.Arc(Round(ACoords.X  * Data.PpiX),
              Round(ACoords.Y  * Data.PpiY),
              Round(ACoords.X2 * Data.PpiX),
              Round(ACoords.Y2 * Data.PpiY),
              Round(ACoords.X3 * Data.PpiX),
              Round(ACoords.Y3 * Data.PpiY),
              Round(ACoords.X4 * Data.PpiX),
              Round(ACoords.Y4 * Data.PpiY));
end;

//------------------------------------------------------------------------------

// *** TGmChordShape ***

function TGmChordShape.GetObjectID: integer;
begin
  Result := GM_CHORD_ID;
end;

procedure TGmChordShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ACoords: TGmComplexCoords;
begin
  inherited DrawToCanvas(ACanvas, Data);
  ACoords := Coords[gmInches];
  ACanvas.Chord(Round(ACoords.X  * Data.PpiX),
                Round(ACoords.Y  * Data.PpiY),
                Round(ACoords.X2 * Data.PpiX),
                Round(ACoords.Y2 * Data.PpiY),
                Round(ACoords.X3 * Data.PpiX),
                Round(ACoords.Y3 * Data.PpiY),
                Round(ACoords.X4 * Data.PpiX),
                Round(ACoords.Y4 * Data.PpiY));
end;

//------------------------------------------------------------------------------

// *** TGmPieShape ***

function TGmPieShape.GetObjectID: integer;
begin
  Result := GM_PIE_ID;
end;

procedure TGmPieShape.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ACoords: TGmComplexCoords;
begin
  inherited DrawToCanvas(ACanvas, Data);
  ACoords := Coords[gmInches];
  ACanvas.Pie(Round(ACoords.X  * Data.PpiX),
              Round(ACoords.Y  * Data.PpiY),
              Round(ACoords.X2 * Data.PpiX),
              Round(ACoords.Y2 * Data.PpiY),
              Round(ACoords.X3 * Data.PpiX),
              Round(ACoords.Y3 * Data.PpiY),
              Round(ACoords.X4 * Data.PpiX),
              Round(ACoords.Y4 * Data.PpiY));
end;

//------------------------------------------------------------------------------

// *** TGmPolyBaseObject ***

function TGmPolyBaseObject.GetPoints(Measurement: TGmMeasurement): TGmPolyPoints;
begin
  Result := FPoints;
  ConvertGmPolyPoints(Result, gmInches, Measurement);
end;

procedure TGmPolyBaseObject.SetPoints(Measurement: TGmMeasurement; Value: TGmPolyPoints);
var
  NewPoints: TGmPolyPoints;
begin
  NewPoints := Value;
  ConvertGmPolyPoints(NewPoints, Measurement, gmInches);
  FPoints := NewPoints;
  Changed;
end;

procedure TGmPolyBaseObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
//type
//  PPoints = ^TPoints;
//  TPoints = array[0..0] of TPoint;
var
  PixelPoints: array of TPoint;
  ICount: integer;
begin
  inherited DrawToCanvas(ACanvas, Data);
  SetLength(PixelPoints, High(FPoints)+1);
  for ICount := 0 to High(FPoints) do
  begin
    PixelPoints[ICount].X := Round(FPoints[ICount].X * Data.PpiX);
    PixelPoints[ICount].Y := Round(FPoints[ICount].Y * Data.PpiY);
  end;
  GmDrawPolyShape(ObjectID, ACanvas, PixelPoints);
end;

procedure TGmPolyBaseObject.LoadFromValueList(Values: TGmValueList);
var
  ICount: integer;
  NumPoints: integer;
begin
  inherited LoadFromValueList(Values);
  NumPoints := Values.ReadIntValue(C_SZ, 0);
  SetLength(FPoints, NumPoints);
  for ICount := 0 to NumPoints-1 do
    FPoints[ICount] := Values.ReadGmPointValue(C_XY+IntToStr(ICount), GmPoint(0, 0));
end;

procedure TGmPolyBaseObject.SaveToValueList(Values: TGmValueList);
var
  ICount,
  NumPoints: integer;
begin
  inherited SaveToValueList(Values);
  NumPoints := High(FPoints)+1;
  Values.WriteIntValue(C_SZ, NumPoints);
  for ICount := 0 to NumPoints-1 do
  begin
    Values.WriteGmPointValue(C_XY+IntToStr(ICount), FPoints[ICount]);
  end;
end;

procedure TGmPolyBaseObject.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
var
  OffsetX: Extended;
  OffsetY: Extended;
  ICount: integer;
begin
  OffsetX := ConvertValue(x, Measurement, gmInches);
  OffsetY := ConvertValue(y, Measurement, gmInches);
  for ICount := 0 to High(FPoints) do
    OffsetGmPoint(FPoints[ICount], OffsetX, OffsetY);
end;

//------------------------------------------------------------------------------

// *** TGmPolygonObject ***

function TGmPolygonObject.GetObjectID: integer;
begin
  Result := GM_POLYGON_OBJECT_ID;
end;

//------------------------------------------------------------------------------

// *** TGmPolyline ***

function TGmPolylineObject.GetObjectID: integer;
begin
  Result := GM_POLYLINE_OBJECT_ID;
end;

//------------------------------------------------------------------------------

// *** TGmPolyBezierObject ***

function TGmPolyBezierObject.GetObjectID: integer;
begin
  Result := GM_POLYBEZIER_OBJECT_ID;
end;

//------------------------------------------------------------------------------

// *** TGmPolylineToObject ***

function TGmPolylineToObject.GetObjectID: integer;
begin
  Result := GM_POLYLINETO_OBJECT_ID;
end;

//------------------------------------------------------------------------------

// *** TGmPolyBezierToObject ***

function TGmPolyBezierToObject.GetObjectID: integer;
begin
  Result := GM_POLYBEZIERTO_OBJECT_ID;
end;

//------------------------------------------------------------------------------

// *** TGmPathObject ***

function TGmPathObject.GetObjectID: integer;
begin
  Result := GM_PATH_OBJECT_ID;
end;

procedure TGmPathObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FObjectType := TGmPathObjectType(Values.ReadIntValue(C_PT, Ord(gmEndPath)));
end;

procedure TGmPathObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteIntValue(C_PT, Ord(FObjectType));
end;

procedure TGmPathObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  inherited DrawToCanvas(ACanvas, Data);
  case FObjectType of
    gmBeginPath        : BeginPath(ACanvas.Handle);
    gmEndPath          : EndPath(ACanvas.Handle);
    gmFillPath         : FillPath(ACanvas.Handle);
    gmStrokePath       : StrokePath(ACanvas.Handle);
    gmStrokeAndFillPath: StrokeAndFillPath(ACanvas.Handle);
    gmCloseFigure      : CloseFigure(ACanvas.Handle);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmRemoveClipObject ***

function TGmRemoveClipObject.GetObjectID: integer;
begin
  Result := GM_REMOVE_CLIP_OBJECT_ID;
end;

procedure TGmRemoveClipObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  SelectClipRgn(ACanvas.Handle, 0);
end;

//------------------------------------------------------------------------------

// *** TGmBaseClipObject ***

procedure TGmBaseClipObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  Values.WriteGmRectValue(C_XY, FClipRect);
end;

procedure TGmBaseClipObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  FClipRect := Values.ReadGmRectValue(C_XY, GmRect(0, 0, 0, 0));
end;

//------------------------------------------------------------------------------

// *** TGmClipEllipseObject ***

function TGmClipEllipseObject.GetObjectID: integer;
begin
  Result := GM_CLIPELLIPSE_OBJECT_ID;
end;

procedure TGmClipEllipseObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ClipRgn: HRGN;
  ARect: TRect;
begin
  ARect.Left   := Round(FClipRect.Left * Data.PpiX);
  ARect.Top    := Round(FClipRect.Top * Data.PpiY);
  ARect.Right  := Round(FClipRect.Right * Data.PpiX);
  ARect.Bottom := Round(FClipRect.Bottom * Data.PpiY);
  BeginPath(ACanvas.Handle);
  GmDrawEllipse(ACanvas, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  EndPath(ACanvas.Handle);
  ClipRgn := PathToRegion(ACanvas.Handle);
  try
    SelectClipRgn(ACanvas.Handle, ClipRgn);
  finally
    DeleteObject(ClipRgn);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmClipRectObject ***

function TGmClipRectObject.GetObjectID: integer;
begin
  Result := GM_CLIPRECT_OBJECT_ID;
end;

procedure TGmClipRectObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ClipRgn: HRGN;
  ARect: TRect;
begin
  ARect.Left   := Round(FClipRect.Left * Data.PpiX);
  ARect.Top    := Round(FClipRect.Top * Data.PpiY);
  ARect.Right  := Round(FClipRect.Right * Data.PpiX);
  ARect.Bottom := Round(FClipRect.Bottom * Data.PpiY);
  BeginPath(ACanvas.Handle);
  GmDrawRect(ACanvas, ARect);
  EndPath(ACanvas.Handle);
  ClipRgn := PathToRegion(ACanvas.Handle);
  try
    SelectClipRgn(ACanvas.Handle, ClipRgn);
  finally
    DeleteObject(ClipRgn);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmClipRoundRectObject ***

function TGmClipRoundRectObject.GetObjectID: integer;
begin
  Result := GM_CLIPROUNDRECT_OBJECT_ID;
end;

procedure TGmClipRoundRectObject.LoadFromValueList(Values: TGmValueList);
begin
  inherited LoadFromValueList(Values);
  FCorners := Values.ReadGmPointValue(C_XY3, GmPoint(0,0));
end;

procedure TGmClipRoundRectObject.SaveToValueList(Values: TGmValueList);
begin
  inherited SaveToValueList(Values);
  Values.WriteGmPointValue(C_XY3, FCorners);
end;

procedure TGmClipRoundRectObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
var
  ClipRgn: HRGN;
  ARect: TRect;
  ACorners: TPoint;
begin
  ARect.Left   := Round(FClipRect.Left * Data.PpiX);
  ARect.Top    := Round(FClipRect.Top * Data.PpiY);
  ARect.Right  := Round(FClipRect.Right * Data.PpiX);
  ARect.Bottom := Round(FClipRect.Bottom * Data.PpiY);
  ACorners.X   := Round(FCorners.X * Data.PpiX);
  ACorners.Y   := Round(FCorners.Y * Data.PpiY);
  BeginPath(ACanvas.Handle);
  GmDrawRoundRect(ACanvas, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, ACorners.X, ACorners.Y);
  EndPath(ACanvas.Handle);
  ClipRgn := PathToRegion(ACanvas.Handle);
  try
    SelectClipRgn(ACanvas.Handle, ClipRgn);
  finally
    DeleteObject(ClipRgn);
  end;
end;

end.
