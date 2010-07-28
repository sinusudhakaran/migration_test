
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxEditUtils;

{$I cxVer.inc}

interface

{.$DEFINE NOFLICKER}

uses
  Windows,
  dxThemeManager,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Classes, Controls, Forms, Graphics, ImgList, StdCtrls, SysUtils,
  cxContainer, cxControls, cxEdit, cxEditPaintUtils,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxScrollBar;

const
  cxEditButtonMaxBorderWidth = 2;
  cxEditMaxBorderWidth = cxContainerMaxBorderWidth;
  cxEditMaxCheckBoxBorderWidth = 2;
  cxEditShadowWidth = cxContainerShadowWidth;

type
  TcxEditCanvasHandle = HDC;

function CalculateEditDefaultButtonWidth(ACanvas: TcxCanvas; AViewInfo: TcxEditButtonViewInfo): Integer;
function cxEditGetBorderWidthBySkinPainter(ABorderStyle: TcxEditBorderStyle;
  ASkinPainter: TcxCustomLookAndFeelPainterClass): Integer;
procedure cxEditFillRect(ACanvas: TCanvas; const R: TRect; AColor: TColor); overload;
procedure cxEditFillRect(ACanvas: TcxCanvas; const R: TRect; AColor: TColor); overload;
procedure cxEditFillRect(ACanvasHandle: TcxEditCanvasHandle; const R: TRect;
  ABrush: TBrushHandle); overload;
function cxIsDigitChar(C: Char): Boolean;
function cxOffsetRect(var ARect: TRect; AOffset: TPoint): Boolean;
function cxTextOutFlagsToDrawTextFlags(AFlags: DWORD): Integer;
procedure DrawArrow(ACanvas: TcxCanvas; AArrowSize: Integer; AContentRect: TRect;
  AArrowDirection: TcxArrowDirection; AIsDoubleArrow: Boolean;
  AOffsetContent: Boolean; AColor: TColor);
procedure DrawButtonBorder(ACanvas: TcxCanvas; var ARect: TRect;
  ABorders: TcxBorders; AColor: TColor);
procedure DrawCustomEdit(ACanvas: TcxCanvas; AViewInfo: TcxCustomEditViewInfo;
  ADrawBackground: Boolean; ABackgroundStyle: TcxEditBackgroundPaintingStyle);
function DrawTextFlagsTocxTextOutFlags(AFlags: DWORD): Integer;
procedure DrawGlyph(ACanvas: TCanvas; X, Y: Integer; AGlyph: TBitmap;
  AEnabled: Boolean; ABrushColor: TColor = clNone; ABackgroundBitmap: TBitmap = nil); overload;
procedure DrawGlyph(ACanvas: TcxCanvas; X, Y: Integer; AGlyph: TBitmap;
  AEnabled: Boolean; ABrushColor: TColor = clNone; ABackgroundBitmap: TBitmap = nil); overload;
procedure DrawGlyph(ACanvas: TcxCanvas; AImageList: TCustomImageList;
  AImageIndex: TImageIndex;
  const AGlyphRect: TRect; ABrushColor: TColor; AEnabled: Boolean;
  ABackgroundBitmap: TBitmap = nil); overload;
function GetArrowSize(const AContentSize: TSize; AArrowDirection: TcxArrowDirection): TSize;
function GetEditButtonsContentVerticalOffset(ACanvas: TcxCanvas;
  AButtonsStyle: TcxEditButtonStyle; ANativeStyle: Boolean): Integer;
function GetHotTrackColor: TColor;
function GetNativeInnerTextEditContentHeightCorrection(
  AProperties: TcxCustomEditProperties; AIsInplace: Boolean): Integer;
function GetEditButtonRegion(ACanvas: TcxCanvas; AViewInfo: TcxEditButtonViewInfo): TcxRegion;
function GetEditBorderHighlightColor(AIsOffice11Style: Boolean): TColor;
function GetEditButtonHighlightColor(APressed: Boolean;
  AIsOffice11Style: Boolean): TColor;
function GetPainterClass(ANativeStyle: Boolean;
  ALookAndFeel: TcxLookAndFeelKind): TcxCustomLookAndFeelPainterClass;
procedure InternalFillRect(ACanvas: TcxCanvas; const AOuterRect, AInternalRect: TRect;
  ABrush: TBrushHandle);
procedure InternalPolyLine(ACanvas: TcxCanvas; const Points: array of TPoint;
  AColor: TColor; AOrtoDrawing: Boolean = False);
function IsShadowDrawingNeeded(AViewData: TcxCustomEditViewData): Boolean;
procedure RestoreCanvasFont(ACanvas: TcxCanvas; const ASavedLogFont: TLogFont);
procedure SaveCanvasFont(ACanvas: TcxCanvas; out ALogFont: TLogFont);
function VerifyBitmap(ABitmap: TBitmap): Boolean;
function VerifyImages(AImages: TCustomImageList): Boolean;

implementation

uses
  Messages, cxClasses, cxDrawTextUtils, dxOffice11, dxThemeConsts, dxUxTheme,
  cxGeometry, cxDWMApi, dxCore;

const
  cxEditButtonContentVerticalOffset: array [TcxEditButtonStyle] of Integer =
    (0, 4, 2, 2, 2, 2, 2);

procedure DrawArrow(ACanvas: TcxCanvas; AArrowSize: Integer; AContentRect: TRect;
  AArrowDirection: TcxArrowDirection; AIsDoubleArrow: Boolean;
  AOffsetContent: Boolean; AColor: TColor);
var
  AArrowBrush: TBrushHandle;
  AArrowRect: TRect;

  procedure InternalDrawArrow;
  var
    I: Integer;
    R: TRect;
  begin
    case AArrowDirection of
      adLeft:
        begin
          with AArrowRect do
            R := Rect(Left, Top + AArrowSize - 1, Left + 1, Top + AArrowSize);
          with R do
            for I := 1 to AArrowSize do
            begin
              cxEditFillRect(ACanvas.Handle, R, AArrowBrush);
              Inc(Left);
              Dec(Top);
              Inc(Right);
              Inc(Bottom);
            end;
          Inc(AArrowRect.Left, AArrowSize);
        end;
      adRight:
        begin
          with AArrowRect do
            R := Rect(Left, Top, Left + 1, Bottom);
          with R do
            for I := 1 to AArrowSize do
            begin
              cxEditFillRect(ACanvas.Handle, R, AArrowBrush);
              Inc(Left);
              Inc(Top);
              Inc(Right);
              Dec(Bottom);
            end;
          Inc(AArrowRect.Left, AArrowSize);
        end;
      adUp:
        begin
          with AArrowRect do
            R := Rect(Left + AArrowSize - 1, Top, Left + AArrowSize, Top + 1);
          with R do
            for I := 1 to AArrowSize do
            begin
              cxEditFillRect(ACanvas.Handle, R, AArrowBrush);
              Dec(Left);
              Inc(Top);
              Inc(Right);
              Inc(Bottom);
            end;
          Inc(AArrowRect.Top, AArrowSize);
        end;
      adDown:
        begin
          with AArrowRect do
            R := Rect(Left, Top, Right, Top + 1);
          with R do
            for I := 1 to AArrowSize do
            begin
              cxEditFillRect(ACanvas.Handle, R, AArrowBrush);
              Inc(Left);
              Inc(Top);
              Dec(Right);
              Inc(Bottom);
            end;
          Inc(AArrowRect.Top, AArrowSize);
        end;
    end;
  end;

var
  AArrowRectSize: TSize;
  I: Integer;
begin
  if AArrowDirection in [adLeft, adRight] then
  begin
    AArrowRectSize.cx := AArrowSize * (1 + Integer(AIsDoubleArrow));
    AArrowRectSize.cy := AArrowSize * 2 - 1;
  end
  else
  begin
    AArrowRectSize.cx := AArrowSize * 2 - 1;
    AArrowRectSize.cy := AArrowSize * (1 + Integer(AIsDoubleArrow));
  end;

  with AContentRect do
  begin
    AArrowRect.Left := Left + (Right - Left - AArrowRectSize.cx) div 2;
    AArrowRect.Top := Top + (Bottom - Top - AArrowRectSize.cy) div 2;
    if AOffsetContent then
    begin
      Inc(AArrowRect.Left);
      Inc(AArrowRect.Top);
    end;
    AArrowRect.Right := AArrowRect.Left + AArrowRectSize.cx;
    AArrowRect.Bottom := AArrowRect.Top + AArrowRectSize.cy;
  end;

  AArrowBrush := GetSolidBrush(ACanvas, AColor);
  for I := 0 to Integer(AIsDoubleArrow) do
    InternalDrawArrow;
end;

procedure DrawButtonBorder(ACanvas: TcxCanvas; var ARect: TRect;
  ABorders: TcxBorders; AColor: TColor);
var
  AWorkRect: TRect;
begin
  AWorkRect := ARect;
  Dec(AWorkRect.Bottom, 1);
  Dec(AWorkRect.Right, 1);
  ACanvas.Pen.Color := AColor;

  if bLeft in ABorders then
  begin
    InternalPolyLine(ACanvas, [AWorkRect.TopLeft, Point(AWorkRect.Left, AWorkRect.Bottom)], AColor);
    Inc(ARect.Left);
  end;
  if bRight in ABorders then
  begin
    InternalPolyLine(ACanvas, [Point(AWorkRect.Right, AWorkRect.Top), AWorkRect.BottomRight], AColor);
    Dec(ARect.Right);
  end;
  if bTop in ABorders then
  begin
    InternalPolyLine(ACanvas, [AWorkRect.TopLeft, Point(AWorkRect.Right, AWorkRect.Top)], AColor);
    Inc(ARect.Top);
  end;
  if bBottom in ABorders then
  begin
    InternalPolyLine(ACanvas, [Point(AWorkRect.Left, AWorkRect.Bottom), AWorkRect.BottomRight], AColor);
    Dec(ARect.Bottom);
  end;
end;

procedure DrawGlyph(ACanvas: TCanvas; X, Y: Integer; AGlyph: TBitmap;
  AEnabled: Boolean; ABrushColor: TColor = clNone; ABackgroundBitmap: TBitmap = nil);

  procedure InternalDrawGlyphEnabled;
  var
    AGlyphDrawingBrush: TBrush;
    APrevBrushStyle: TBrushStyle;
    R: TRect;
  begin
    if ABackgroundBitmap = nil then
      AGlyphDrawingBrush := ACanvas.Brush
    else
      AGlyphDrawingBrush := ABackgroundBitmap.Canvas.Brush;
    APrevBrushStyle := AGlyphDrawingBrush.Style;

    with ACanvas do
    begin
      if (ABackgroundBitmap <> nil) or (ABrushColor = clNone) then
        AGlyphDrawingBrush.Style := bsClear
      else
        AGlyphDrawingBrush.Color := ABrushColor;
      if ABackgroundBitmap = nil then
        ACanvas.BrushCopy(Bounds(X, Y, AGlyph.Width, AGlyph.Height), AGlyph,
          Rect(0, 0, AGlyph.Width, AGlyph.Height), AGlyph.TransparentColor)
      else
      begin
        R := Rect(0, 0, AGlyph.Width, AGlyph.Height);
        ABackgroundBitmap.Canvas.BrushCopy(R, AGlyph, R, AGlyph.TransparentColor);
        ACanvas.Draw(X, Y, ABackgroundBitmap);
      end;
    end;

    AGlyphDrawingBrush.Style := APrevBrushStyle;
  end;

  procedure InternalDrawGlyphDisabled;
  var
    ABitmap: TBitmap;
    AImageList: TcxImageList;
  begin
    AImageList := TcxImageList.Create(nil);
    try
      AImageList.Width := AGlyph.Width;
      AImageList.Height := AGlyph.Height;
      ABitmap := nil;
      try
        if (ABackgroundBitmap = nil) and (ABrushColor <> clNone) then
        begin
          ABitmap := cxCreateBitmap(AImageList.Width, AImageList.Height, pfDevice);
          cxEditFillRect(ABitmap.Canvas.Handle, Rect(0, 0, ABitmap.Width, ABitmap.Height),
            GetSolidBrush(ABitmap.Canvas, ABrushColor));
        end;
        AImageList.AddMasked(AGlyph, AGlyph.TransparentColor);
        if ABitmap <> nil then
        begin
          AImageList.Draw(ABitmap.Canvas, 0, 0, 0, AEnabled);
          ACanvas.Draw(X, Y, ABitmap);
        end
        else
          if ABackgroundBitmap = nil then
            AImageList.Draw(ACanvas, X, Y, 0, AEnabled)
          else
          begin
            AImageList.Draw(ABackgroundBitmap.Canvas, 0, 0, 0, AEnabled);
            ACanvas.Draw(X, Y, ABackgroundBitmap);
          end;
      finally
        ABitmap.Free;
      end;
    finally
      AImageList.Free;
    end;
  end;

begin
  if AEnabled then
    InternalDrawGlyphEnabled
  else
    InternalDrawGlyphDisabled;
end;

procedure DrawGlyph(ACanvas: TcxCanvas; X, Y: Integer; AGlyph: TBitmap;
  AEnabled: Boolean; ABrushColor: TColor = clNone; ABackgroundBitmap: TBitmap = nil);
begin
  DrawGlyph(ACanvas.Canvas, X, Y, AGlyph, AEnabled, ABrushColor, ABackgroundBitmap);
end;

procedure DrawGlyph(ACanvas: TcxCanvas; AImageList: TCustomImageList;
  AImageIndex: TImageIndex;
  const AGlyphRect: TRect; ABrushColor: TColor; AEnabled: Boolean;
  ABackgroundBitmap: TBitmap = nil);
var
  ABitmap: TBitmap;
begin
  ABitmap := nil;
  try
    if ABackgroundBitmap = nil then
    begin
      ABitmap := TBitmap.Create;
      ABitmap.Width := AImageList.Width;
      ABitmap.Height := AImageList.Height;
      with ABitmap.Canvas do
        cxEditFillRect(Handle, Rect(0, 0, ABitmap.Width, ABitmap.Height),
          GetSolidBrush(ABitmap.Canvas, ABrushColor));
    end;
    if ABackgroundBitmap <> nil then
    begin
      AImageList.Draw(ABackgroundBitmap.Canvas, 0, 0, AImageIndex, AEnabled); // ??? itMask TODO
      ACanvas.Draw(AGlyphRect.Left, AGlyphRect.Top, ABackgroundBitmap);
    end else
    begin
      AImageList.Draw(ABitmap.Canvas, 0, 0, AImageIndex, AEnabled); // ??? itMask TODO
      ACanvas.Draw(AGlyphRect.Left, AGlyphRect.Top, ABitmap);
    end;
  finally
    if ABitmap <> nil then
      ABitmap.Free;
  end;
end;

function GetPainterClass(ANativeStyle: Boolean;
  ALookAndFeel: TcxLookAndFeelKind): TcxCustomLookAndFeelPainterClass;
const
  APainterMap: array[TcxLookAndFeelKind] of TcxCustomLookAndFeelPainterClass = (
    TcxFlatLookAndFeelPainter, TcxStandardLookAndFeelPainter,
    TcxUltraFlatLookAndFeelPainter, TcxOffice11LookAndFeelPainter
  );
begin
  if ANativeStyle and AreVisualStylesAvailable then
    Result := TcxWinXPLookAndFeelPainter
  else
    Result := APainterMap[ALookAndFeel];
end;

procedure InternalPolyLine(ACanvas: TcxCanvas; const Points: array of TPoint;
  AColor: TColor; AOrtoDrawing: Boolean = False);
var
  I: Integer;
  P1, P2: TPoint;
  ABrush: TBrushHandle;
begin
  with ACanvas do
    if AOrtoDrawing then
    begin
      ABrush := GetSolidBrush(AColor);
      for I := 0 to Length(Points) - 2 do
      begin
        P1 := Points[I];
        P2 := Points[I + 1];
        if P1.X = P2.X then
        begin
          Inc(P2.X);
          if P1.Y > P2.Y then
          begin
            Inc(P1.Y);
            Inc(P2.Y);
          end;
        end
        else
        begin
          Inc(P2.Y);
          if P1.X > P2.X then
          begin
            Inc(P1.X);
            Inc(P2.X);
          end;
        end;
        cxEditFillRect(ACanvas.Handle, Rect(P1.X, P1.Y, P2.X, P2.Y), ABrush);
      end;
      with Points[High(Points)] do
        cxEditFillRect(ACanvas.Handle, Rect(X, Y, X + 1, Y + 1), ABrush);
    end
    else
    begin
      Pen.Color := AColor;
      Polyline(Points);
      with Points[High(Points)] do
        Pixels[X, Y] := AColor;
    end;
end;

function VerifyBitmap(ABitmap: TBitmap): Boolean;
begin
  with ABitmap do
    Result := (ABitmap <> nil) and (not Empty) and (Width > 0) and (Height > 0);
end;

function VerifyImages(AImages: TCustomImageList): Boolean;
begin
  with AImages do
    Result := (AImages <> nil) and (Width > 0) and (Height > 0);
end;

function CalculateEditDefaultButtonWidth(ACanvas: TcxCanvas; AViewInfo: TcxEditButtonViewInfo): Integer;

  function GetEditButtonTotalBorderExtent: Integer;
  var
    ATheme: TdxTheme;
    R, CR: TRect;
  begin
    with AViewInfo do
      if Data.NativeStyle then
      begin
        R := Rect(0, 0, 100, 100);
        if Data.ComboBoxStyle then
        begin
          ATheme := OpenTheme(totComboBox);
          GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, CP_DROPDOWNBUTTON,
            CBXS_NORMAL, R, CR);
        end else
        begin
          ATheme := OpenTheme(totButton);
          GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, BP_PUSHBUTTON,
            PBS_NORMAL, R, CR);
        end;
        Result := CR.Left + (R.Right - R.Left - CR.Right);
      end
      else
        Result := cxEditButtonMaxBorderWidth * 2;
  end;

var
  AButtonTotalBorderExtent: Integer;
  ACaptionWidth: Integer;
begin
  with AViewInfo do
  begin
    if Data.NativeStyle then
      if Data.ComboBoxStyle then
        Data.NativeStyle := AreVisualStylesMustBeUsed(Data.NativeStyle, totComboBox)
      else
        Data.NativeStyle := AreVisualStylesMustBeUsed(Data.NativeStyle, totButton);
    AButtonTotalBorderExtent := GetEditButtonTotalBorderExtent;
    if Width > 0 then
      if Width < AButtonTotalBorderExtent then
        Result := AButtonTotalBorderExtent
      else
        Result := Width
    else
      if (Data.Kind = bkGlyph) and VerifyBitmap(Glyph) then
        Result := Glyph.Width + GetEditButtonTotalBorderExtent
      else
      begin
        if Data.Kind = bkText then
          ACaptionWidth := ACanvas.TextWidth(Data.VisibleCaption) + AButtonTotalBorderExtent + 2 + 1
        else
          ACaptionWidth := 0;
        Result := GetSystemMetrics(SM_CYHSCROLL);
        if ACaptionWidth > Result then
          Result := ACaptionWidth;
      end;
  end;
end;

function cxEditGetBorderWidthBySkinPainter(ABorderStyle: TcxEditBorderStyle;
  ASkinPainter: TcxCustomLookAndFeelPainterClass): Integer;
const
  SkinBordersWidth: array [Boolean] of Integer = (1, cxContainerMaxBorderWidth);
begin
  if ASkinPainter = nil then
    Result := GetContainerBorderWidth(TcxContainerBorderStyle(ABorderStyle))
  else
    Result := SkinBordersWidth[ABorderStyle = ebsThick];
end;

procedure cxEditFillRect(ACanvas: TCanvas; const R: TRect; AColor: TColor);
begin
  Windows.FillRect(ACanvas.Handle, R, GetSolidBrush(AColor));
end;

procedure cxEditFillRect(ACanvas: TcxCanvas; const R: TRect; AColor: TColor);
begin
  Windows.FillRect(ACanvas.Handle, R, GetSolidBrush(AColor));
end;

procedure cxEditFillRect(ACanvasHandle: TcxEditCanvasHandle; const R: TRect;
  ABrush: TBrushHandle);
begin
  Windows.FillRect(ACanvasHandle, R, ABrush);
end;

function cxIsDigitChar(C: Char): Boolean;
begin
  Result := dxCharInSet(C, ['0'..'9']);
end;

function cxOffsetRect(var ARect: TRect; AOffset: TPoint): Boolean;
begin
  Result := OffsetRect(ARect, AOffset.X, AOffset.Y);
end;

procedure ConvertFlag(AInputFlags: DWORD; var AOutputFlags: Integer;
  AInputFlag: DWORD; AOutputFlag: Integer);
begin
  if AInputFlags and AInputFlag <> 0 then
    AOutputFlags := AOutputFlags or AOutputFlag;
end;

function cxTextOutFlagsToDrawTextFlags(AFlags: DWORD): Integer;
begin
  Result := 0;
  ConvertFlag(AFlags, Result, CXTO_LEFT, cxAlignLeft);
  ConvertFlag(AFlags, Result, CXTO_CENTER_HORIZONTALLY, cxAlignHCenter);
  ConvertFlag(AFlags, Result, CXTO_RIGHT, cxAlignRight);
  ConvertFlag(AFlags, Result, CXTO_TOP, cxAlignTop);
  ConvertFlag(AFlags, Result, CXTO_CENTER_VERTICALLY, cxAlignVCenter);
  ConvertFlag(AFlags, Result, CXTO_BOTTOM, cxAlignBottom);
  ConvertFlag(AFlags, Result, CXTO_SINGLELINE, cxSingleLine);
  ConvertFlag(AFlags, Result, CXTO_WORDBREAK, cxWordBreak);
end;

function DrawTextFlagsTocxTextOutFlags(AFlags: DWORD): Integer;
begin
  Result := 0;
  ConvertFlag(AFlags, Result, cxAlignLeft, CXTO_LEFT);
  ConvertFlag(AFlags, Result, cxAlignHCenter, CXTO_CENTER_HORIZONTALLY);
  ConvertFlag(AFlags, Result, cxAlignRight, CXTO_RIGHT);
  ConvertFlag(AFlags, Result, cxAlignTop, CXTO_TOP);
  ConvertFlag(AFlags, Result, cxAlignVCenter, CXTO_CENTER_VERTICALLY);
  ConvertFlag(AFlags, Result, cxAlignBottom, CXTO_BOTTOM);
  ConvertFlag(AFlags, Result, cxSingleLine, CXTO_SINGLELINE);
  ConvertFlag(AFlags, Result, cxWordBreak, CXTO_WORDBREAK);
end;

procedure InternalFillRect(ACanvas: TcxCanvas; const AOuterRect, AInternalRect: TRect;
  ABrush: TBrushHandle);
begin
  if IsRectEmpty(AOuterRect) or EqualRect(AOuterRect, AInternalRect) then
    Exit;
  if IsRectEmpty(AInternalRect) then
    cxEditFillRect(ACanvas.Handle, AOuterRect, ABrush)
  else
  begin
    cxEditFillRect(ACanvas.Handle, Rect(AOuterRect.Left, AOuterRect.Top,
      AInternalRect.Left, AOuterRect.Bottom), ABrush);
    cxEditFillRect(ACanvas.Handle, Rect(AInternalRect.Left, AOuterRect.Top,
      AInternalRect.Right, AInternalRect.Top), ABrush);
    cxEditFillRect(ACanvas.Handle, Rect(AInternalRect.Right, AOuterRect.Top,
      AOuterRect.Right, AOuterRect.Bottom), ABrush);
    cxEditFillRect(ACanvas.Handle, Rect(AInternalRect.Left, AInternalRect.Bottom,
      AInternalRect.Right, AOuterRect.Bottom), ABrush);
  end;
end;

procedure DrawCustomEdit(ACanvas: TcxCanvas; AViewInfo: TcxCustomEditViewInfo;
  ADrawBackground: Boolean; ABackgroundStyle: TcxEditBackgroundPaintingStyle);

  procedure FillEditBorderRect(ABackgroundBrush: TBrushHandle);
  begin
    if not AViewInfo.Transparent then
      cxEditFillRect(ACanvas.Handle, AViewInfo.BorderRect, ABackgroundBrush);
  end;

  procedure FillContentOffsetRegion(ABackgroundBrush: TBrushHandle);
  begin
    with AViewInfo do
    begin
      if Transparent or not AViewInfo.HasContentOffsets then
        Exit;
      cxEditFillRect(ACanvas.Handle, Rect(Bounds.Left, Bounds.Top, BorderRect.Left,
        Bounds.Bottom), ABackgroundBrush);
      cxEditFillRect(ACanvas.Handle, Rect(BorderRect.Left, Bounds.Top,
        BorderRect.Right, BorderRect.Top), ABackgroundBrush);
      cxEditFillRect(ACanvas.Handle, Rect(BorderRect.Left, BorderRect.Bottom,
        BorderRect.Right, Bounds.Bottom), ABackgroundBrush);
      cxEditFillRect(ACanvas.Handle, Rect(BorderRect.Right, Bounds.Top,
        Bounds.Right, Bounds.Bottom), ABackgroundBrush);
    end;
  end;

  procedure DrawEditBordersBySkinPainter(const R1: TRect; ABorderWidth: Integer;
    APainter: TcxCustomLookAndFeelPainterClass);
  begin
    with AViewInfo do
    begin
      if BorderStyle <> ebsNone then
        ACanvas.FrameRect(R1, BorderColor, ABorderWidth);
    end;
  end;

  procedure DrawUsualEditBorders(const R: TRect; ABorderWidth: Integer);
  var
    R1: TRect;
  begin
    with AViewInfo do
    begin
      R1 := R;
      if AViewInfo.Painter <> nil then
        DrawEditBordersBySkinPainter(R, ABorderWidth, Painter)
      else
        case AViewInfo.BorderStyle of
          ebsSingle, ebsThick:
            ACanvas.FrameRect(R1, BorderColor, ABorderWidth);
          ebsFlat:
            begin
              ACanvas.DrawEdge(R1, True, True, Edges);
              InflateRect(R1, -1, -1);
              ACanvas.FrameRect(R1, clBtnFace);
            end;
          ebs3D:
            begin
              ACanvas.DrawEdge(R1, True, True, Edges);
              InflateRect(R1, -1, -1);
              ACanvas.DrawComplexFrame(R1, cl3DDkShadow, cl3DLight, Edges);
            end;
        end;
    end;
  end;

  procedure DrawUsualEditBackground(ABackgroundBrush: TBrushHandle);
  var
    R: TRect;
    ABorderWidth: Integer;
  begin
    with AViewInfo do
    begin
      R := BorderRect;
      ABorderWidth := cxEditGetBorderWidthBySkinPainter(BorderStyle, Painter);
      Dec(R.Left, ABorderWidth);
      Dec(R.Top, ABorderWidth);
      if bRight in Edges then Inc(R.Right, ABorderWidth);
      if bBottom in Edges then Inc(R.Bottom, ABorderWidth);
      if Shadow then
        DrawContainerShadow(ACanvas, R);
      if not(bRight in Edges) then Inc(R.Right, ABorderWidth);
      if not(bBottom in Edges) then Inc(R.Bottom, ABorderWidth);
      DrawUsualEditBorders(R, ABorderWidth);
      if IsInplace then
      begin
        if not Transparent then
          if ADrawBackground then
            cxEditFillRect(ACanvas.Handle, Bounds, ABackgroundBrush)
          else
            FillContentOffsetRegion(ABackgroundBrush);
      end
      else
        if ADrawBackground then
          FillEditBorderRect(ABackgroundBrush);
    end;
  end;

  procedure DrawEditBackground(ABackgroundBrush: TBrushHandle);
  begin
    if not AViewInfo.DrawBackground(ACanvas) then
      if AViewInfo.NativeStyle then
        AViewInfo.DrawNativeStyleEditBackground(ACanvas, ADrawBackground,
          ABackgroundStyle, ABackgroundBrush)
      else
        DrawUsualEditBackground(ABackgroundBrush);
  end;

var
  AVisibleButtonsCount: Integer;
  I: Integer;
  ASavedDC: Integer;
begin
  AVisibleButtonsCount := Length(AViewInfo.ButtonsInfo);
  ASavedDC := 0;
  if (AVisibleButtonsCount > 0) and not AViewInfo.ButtonsInfo[0].Data.BackgroundPartiallyTransparent then
  begin
    ASavedDC := SaveDC(ACanvas.Handle);
    for I := 0 to AVisibleButtonsCount - 1 do
      ACanvas.ExcludeClipRect(AViewInfo.ButtonsInfo[I].VisibleBounds);
  end;
  DrawEditBackground(GetSolidBrush(ACanvas, AViewInfo.BackgroundColor));

  if ASavedDC <> 0 then
    RestoreDC(ACanvas.Handle, ASavedDC);
  AViewInfo.DrawButtons(ACanvas);
end;

function GetArrowSize(const AContentSize: TSize; AArrowDirection: TcxArrowDirection): TSize;
var
  AMinContentSize: Integer;
  ATempVar: Longint;
begin
  AMinContentSize := AContentSize.cx;
  if AMinContentSize > AContentSize.cy then
    AMinContentSize := AContentSize.cy;

  Result.cx := (AMinContentSize - 1) div 2;
  if not Odd(Result.cx) then
    Result.cx := Result.cx + 1;
  Result.cy := Result.cx div 2 + 1;
  if AArrowDirection in [adLeft, adRight] then
  begin
    ATempVar := Result.cx;
    Result.cx := Result.cy;
    Result.cy := ATempVar;
  end;
end;

function GetEditButtonsContentVerticalOffset(ACanvas: TcxCanvas;
  AButtonsStyle: TcxEditButtonStyle; ANativeStyle: Boolean): Integer;
var
  ATheme: TdxTheme;
  CR, R: TRect;
begin
  if ANativeStyle then
  begin
    R := Rect(0, 0, 100, 100);
    ATheme := OpenTheme(totButton);
    GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, BP_PUSHBUTTON,
      PBS_NORMAL, R, CR);
    Result := CR.Top + R.Bottom - CR.Bottom;
  end
  else
    Result := cxEditButtonContentVerticalOffset[AButtonsStyle];
end;

function GetHotTrackColor: TColor;
begin
  Result := GetSysColor(COLOR_HOTLIGHT);
end;

function GetNativeInnerTextEditContentHeightCorrection(
  AProperties: TcxCustomEditProperties; AIsInplace: Boolean): Integer;
begin
  Result := Integer(AIsInplace and (AProperties.Buttons.Count > 0));
end;

function GetEditButtonRegion(ACanvas: TcxCanvas; AViewInfo: TcxEditButtonViewInfo): TcxRegion;
var
  ATheme: TdxTheme;
  ARgn1, ARgn2: HRGN;
begin
  with AViewInfo do
    if Data.NativeState <> TC_NONE then
    begin
      if Data.ComboBoxStyle then
      begin
        ATheme := OpenTheme(totComboBox);
        GetThemeBackgroundRegion(ATheme, ACanvas.Handle, CP_DROPDOWNBUTTON,
          Data.NativeState, @Bounds, ARgn1);
      end else
      begin
        ATheme := OpenTheme(totButton);
        GetThemeBackgroundRegion(ATheme, ACanvas.Handle, Data.NativePart,
          Data.NativeState, @Bounds, ARgn1);
      end;
      ARgn2 := CreateRectRgnIndirect(Bounds);
      CombineRgn(ARgn1, ARgn1, ARgn2, RGN_AND);
      DeleteObject(ARgn2);
      Result := TcxRegion.Create(ARgn1);
    end
    else
      Result := TcxRegion.Create(Bounds);
end;

function GetEditBorderHighlightColor(
  AIsOffice11Style: Boolean): TColor;
begin
  if AIsOffice11Style then
    Result := dxOffice11SelectedBorderColor
  else
    Result := clHighlight;
end;

function GetEditButtonHighlightColor(APressed: Boolean;
  AIsOffice11Style: Boolean): TColor;
var
  APainterClass: TcxCustomLookAndFeelPainterClass;
begin
  if AIsOffice11Style then
    APainterClass := TcxOffice11LookAndFeelPainter
  else
    APainterClass := TcxUltraFlatLookAndFeelPainter;
  if APressed then
    Result := APainterClass.ButtonColor(cxbsPressed)
  else
    Result := APainterClass.ButtonColor(cxbsHot);
end;

function IsShadowDrawingNeeded(AViewData: TcxCustomEditViewData): Boolean;
begin
  Result := AViewData.Style.Shadow and not AViewData.IsNativeStyle(AViewData.Style.LookAndFeel);
end;

procedure RestoreCanvasFont(ACanvas: TcxCanvas; const ASavedLogFont: TLogFont);
begin
  ACanvas.Font.Handle := CreateFontIndirect(ASavedLogFont);
end;

procedure SaveCanvasFont(ACanvas: TcxCanvas; out ALogFont: TLogFont);
begin
  cxGetFontData(ACanvas.Font.Handle, ALogFont);
end;

end.
