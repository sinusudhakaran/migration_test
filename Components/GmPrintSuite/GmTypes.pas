{******************************************************************************}
{                                                                              }
{                                 GmTypes.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmTypes;

interface

uses Classes, Forms, Windows, ExtCtrls, Controls, StdCtrls;

type
  TGmCustomComponent   = class(TComponent);
  TGmCustomPageControl = class(TScrollingWinControl);
  TGmCustomWinControl  = class(TWinControl);
  TGmCustomComboBox    = class(TCustomComboBox);

  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxListSize - 1] of integer;

  TGmCaptionAlign     = (gmLeft, gmCenter, gmRight);
  TGmCoordsRelative   = (gmFromPage, gmFromPrinterMargins, gmFromUserMargins, gmFromHeaderLine);
  TGmCursor           = (gmDefault, gmZoomIn, gmZoomOut);
  TGmDitherType       = (gmNone, gmCourse, gmFine, gmLineArt, gmGrayScale);
  TGmDragDrawing      = (gmDragNone, gmDragLine, gmDragEllipse, gmDragRectangle);
  TGmDuplexType       = (gmSimplex, gmHorzDuplex, gmVertDuplex);
  TGmGraphicType      = (gmJPeg, gmMetafile, gmBitmap);
  TGmGridStyle        = (gmNoGrid, gmDots, gmLines);
  TGmHighlightStyle   = (gmThinLine, gmThickLine, gmBackground);
  TGmMeasurement      = (gmUnits, gmPixels, gmMillimeters, gmCentimeters, gmInches, gmTwips);
  TGmMemoType         = (gmMemo, gmRichEdit);
  TGmArrangeObject    = (gmToFront, gmForward, gmBackword, gmToBack);
  TGmOrientation      = (gmPortrait, gmLandscape);
  TGmPagesPerSheet    = (gmOnePage, gmTwoPage, gmFourPage);
  TGmPathObjectType   = (gmBeginPath, gmEndPath, gmFillPath, gmStrokePath, gmStrokeAndFillPath, gmCloseFigure);
  TGmPrintColor       = (gmColor, gmMonochrome);
  TGmPrintQuality     = (gmDraft, gmLow, gmMedium, gmHigh);
  TGmPrinterRotation  = (gmRotate0, gmRotate90, gmRotate270);
  TGmRotateValue      = (gmRotateBy0, gmRotateBy90, gmRotateBy180, gmRotateBy270);
  TGmThumbNailLayout  = (gmThumbHorz, gmThumbVert, gmThumbGrid);
  TGmVertAlignment    = (gmTop, gmMiddle, gmBottom);
  TGmZoomStyle        = (gmFixedZoom, gmVariableZoom);

  // paper sizes...
  TGmPaperSize        = (A3,
                         A4,
                         A5,
                         A6,
                         B5,
                         C5,
                         Legal,
                         Letter,
                         Custom,
                         B4,
                         Envelope_09,
                         Envelope_10,
                         Envelope_11,
                         Envelope_12,
                         Envelope_14,
                         Tabloid,
                         Ledger,
                         Executive);

  TGmObjectDrawData = record
    Page: integer;
    PpiX,
    PpiY: integer;
    NumPages: integer;
    FastDraw: Boolean;
  end;

  PGmSize = ^TGmSize;
  TGmSize = packed record
    Width: Extended;
    Height: Extended;
  end;

  TGmPoint = packed record
    X: Extended;
    Y: Extended;
  end;

  PGmRect = ^TGmRect;
  TGmRect = packed record
    case Integer of
      0: (Left, Top, Right, Bottom: Extended);
      1: (TopLeft, BottomRight: TGmPoint);
  end;

  TGmRectPoints = packed record
    TopLeft: TPoint;
    TopRight: TPoint;
    BottomLeft: TPoint;
    BottomRight: TPoint;
  end;

  TGmComplexCoords = packed record
    X, Y, X2, Y2, X3, Y3, X4, Y4: Extended;
  end;

  TGmPolyPoints = array of TGmPoint;

  function GmComplexCoords(x, y, x2, y2, x3, y3, x4, y4: Extended): TGmComplexCoords;
  function GmPoint(x, y: Extended): TGmPoint;
  function GmRect(x, y, x2, y2: Extended): TGmRect;
  function GmRectPointsToRect(Value: TGmRectPoints): TRect;
  function GmRectToRect(ARect: TGmRect): TRect;
  function GmSize(AWidth, AHeight: Extended): TGmSize;
  function RectToGmRectPoints(Value: TRect): TGmRectPoints;
  procedure OffsetGmPoint(var APoint: TGmPoint; X, Y: Extended);
  procedure OffsetGmRect(var ARect: TGmRect; X, Y: Extended);
  function ScaleRect(ARect: TRect; Scale: Extended): TRect;
  function ScaleGmRect(ARect: TGmRect; Scale: Extended): TGmRect;

implementation

function GmComplexCoords(x, y, x2, y2, x3, y3, x4, y4: Extended): TGmComplexCoords;
begin
  Result.X := x;
  Result.Y := y;
  Result.X2 := x2;
  Result.Y2 := y2;
  Result.X3 := x3;
  Result.Y3 := y3;
  Result.X4 := x4;
  Result.Y4 := y4;
end;

function GmPoint(x, y: Extended): TGmPoint;
begin
  Result.X := x;
  Result.Y := y;
end;

function GmRect(x, y, x2, y2: Extended): TGmRect;
begin
  Result.Left := x;
  Result.Top  := y;
  Result.Right := x2;
  Result.Bottom := y2;
end;

function GmRectPointsToRect(Value: TGmRectPoints): TRect;
begin
  Result.Left    := Value.TopLeft.X;
  Result.Top     := Value.TopLeft.Y;
  Result.Right   := Value.BottomRight.X;
  Result.Bottom  := Value.BottomRight.Y;
end;

function GmRectToRect(ARect: TGmRect): TRect;
begin
  Result.Left   := Round(ARect.Left);
  Result.Top    := Round(ARect.Top);
  Result.Right  := Round(ARect.Right);
  Result.Bottom := Round(ARect.Bottom);
end;

function GmSize(AWidth, AHeight: Extended): TGmSize;
begin
  Result.Width := AWidth;
  Result.Height := AHeight;
end;

function RectToGmRectPoints(Value: TRect): TGmRectPoints;
begin
  Result.TopLeft := Value.TopLeft;
  Result.TopRight := Point(Value.Right, Value.Top);
  Result.BottomLeft := Point(Value.Left, Value.Bottom);
  Result.BottomRight := Value.BottomRight;
end;

procedure OffsetGmPoint(var APoint: TGmPoint; X, Y: Extended);
begin
  APoint.X := APoint.X + X;
  APoint.Y := APoint.Y + Y;
end;

procedure OffsetGmRect(var ARect: TGmRect; X, Y: Extended);
begin
  ARect.Left := ARect.Left + X;
  ARect.Top := ARect.Top + Y;
  ARect.Right := ARect.Right + X;
  ARect.Bottom := ARect.Bottom + Y;
end;

function ScaleRect(ARect: TRect; Scale: Extended): TRect;
begin
  Result.Left := Round(ARect.Left * Scale);
  Result.Top := Round(ARect.Top * Scale);
  Result.Right := Round(ARect.Right * Scale);
  Result.Bottom := Round(ARect.Bottom * Scale);
end;

function ScaleGmRect(ARect: TGmRect; Scale: Extended): TGmRect;
begin
  Result.Left := ARect.Left * Scale;
  Result.Top := ARect.Top * Scale;
  Result.Right := ARect.Right * Scale;
  Result.Bottom := ARect.Bottom * Scale;
end;

end.

































