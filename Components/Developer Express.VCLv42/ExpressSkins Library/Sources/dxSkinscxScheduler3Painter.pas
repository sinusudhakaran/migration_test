{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{           Copyright (c) 2006-2009 Developer Express Inc.           }
{                     ALL RIGHTS RESERVED                            }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSSKINS AND ALL ACCOMPANYING     }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.              }
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

unit dxSkinscxScheduler3Painter;

interface

uses
  Windows, SysUtils, Classes, cxSchedulerCustomResourceView, cxDateUtils,
  cxSchedulerCustomControls, dxSkinsCore, dxSkinsLookAndFeelPainter,
  cxLookAndFeels, cxLookAndFeelPainters, cxGraphics, Graphics, cxGeometry,
  cxSchedulerUtils, Math, cxScheduler, cxClasses;

type

  { TcxSchedulerSkinViewItemsPainter }

  TcxScheduler3SkinViewItemsPainter = class(TcxSchedulerExternalPainter)
  private
    procedure DrawCaption(ACanvas: TcxCanvas; const ATextAreaBounds: TRect;
      AAlignmentHorz: TAlignment; AAlignmentVert: TcxAlignmentVert;
      AMultiLine, AShowEndEllipsis: Boolean; const AText: string;
      AFont: TFont; ATextColor: TColor);
    procedure DrawClippedElement(ACanvas: TcxCanvas; AElement: TdxSkinElement;
      ABorders: TcxBorders; R: TRect);
    procedure InternalDrawShadow(ACanvas: TcxCanvas; const ARect, AVisibleRect: TRect);
    function IsSkinAvalaible: Boolean;
    function SkinInfo: TdxSkinLookAndFeelPainterInfo;
    // Headers
    procedure DrawHorizontalHeader(AViewInfo: TcxSchedulerDayHeaderCellViewInfo);
    procedure DrawVerticalHeader(AViewInfo: TcxSchedulerDayHeaderCellViewInfo);
  public
    procedure DoCustomDrawButton(AViewInfo: TcxSchedulerMoreEventsButtonViewInfo;
      var ADone: Boolean); override;
    procedure DoCustomDrawDayHeader(AViewInfo: TcxSchedulerDayHeaderCellViewInfo;
      var ADone: Boolean); override;
    //
    function NeedDrawSelection: Boolean; override;
    function DrawCurrentTimeFirst: Boolean; override;
    //
    procedure DrawAllDayArea(ACanvas: TcxCanvas; const ARect: TRect;
      ABorderColor: TColor; ABorders: TcxBorders; AViewParams: TcxViewParams;
      ASelected: Boolean; ATransparent: Boolean); override;
    procedure DrawCurrentTime(ACanvas: TcxCanvas; AColor: TColor; AStart: TDateTime;
      ABounds: TRect); override;
    procedure DrawEvent(AViewInfo: TcxSchedulerEventCellViewInfo); override;
    procedure DrawEventAsProgressText(AViewInfo: TcxSchedulerEventCellViewInfo;
      AContent: TRect; AProgressRect: TRect; const AText: string); override;
    procedure DrawTimeGridCurrentTime(ACanvas: TcxCanvas; AColor: TColor;
      const ATimeLineRect: TRect); override;
    procedure DrawTimeGridHeader(ACanvas: TcxCanvas; ABorderColor: TColor;
      AViewInfo: TcxSchedulerCustomViewInfoItem; ABorders: TcxBorders;
      ASelected: Boolean); override;
    procedure DrawTimeLine(ACanvas: TcxCanvas; const ARect: TRect;
      AViewParams: TcxViewParams; ABorders: TcxBorders;
      ABorderColor: TColor); override;
    procedure DrawTimeRulerBackground(ACanvas: TcxCanvas; const ARect: TRect;
      ABorders: TcxBorders; AViewParams: TcxViewParams; ATransparent: Boolean); override;
    procedure DrawShadow(ACanvas: TcxCanvas; const ARect, AVisibleRect: TRect;
      ABuffer: TBitmap); override;
    function MoreButtonSize(ASize: TSize): TSize; override;
  end;

implementation

uses Types;

type
  TcxCustomSchedulerAccess = class(TcxCustomScheduler);

const
  cxHeaderStateToButtonState: array[Boolean] of TcxButtonState =
    (cxbsNormal, cxbsHot);

{ TcxSchedulerSkinViewItemsPainter }

procedure TcxScheduler3SkinViewItemsPainter.DrawClippedElement(ACanvas: TcxCanvas;
  AElement: TdxSkinElement; ABorders: TcxBorders; R: TRect);
begin
  ACanvas.SaveClipRegion;
  ACanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
  try
    with AElement.Image.Margins.Rect do
    begin
      if not (bLeft in ABorders) then
        Dec(R.Left, Left);
      if not (bTop in ABorders) then
        Dec(R.Top, Top);
      if not (bRight in ABorders) then
        Inc(R.Right, Right);
      if not (bBottom in ABorders) then
        Inc(R.Bottom, Bottom);
    end;
    AElement.Draw(ACanvas.Handle, R);
  finally
    ACanvas.RestoreClipRegion;
  end;
end;

function TcxScheduler3SkinViewItemsPainter.IsSkinAvalaible: Boolean;
begin
  Result := Painter.InheritsFrom(TdxSkinLookAndFeelPainter);
end;

function TcxScheduler3SkinViewItemsPainter.SkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  GetExtendedStylePainters.GetPainterData(Painter, Result);
end;

function TcxScheduler3SkinViewItemsPainter.MoreButtonSize(ASize: TSize): TSize;
begin
  if IsSkinAvalaible and (SkinInfo.SchedulerMoreButton <> nil) then
    Result := SkinInfo.SchedulerMoreButton.Size
  else
    Result := ASize;
end;

procedure TcxScheduler3SkinViewItemsPainter.DoCustomDrawButton(
  AViewInfo: TcxSchedulerMoreEventsButtonViewInfo; var ADone: Boolean);
var
  AElement: TdxSkinElement;
begin
  inherited DoCustomDrawButton(AViewInfo, ADone);
  ADone := IsSkinAvalaible;
  if ADone then
  begin
    AElement := SkinInfo.SchedulerMoreButton;
    ADone := AElement <> nil;
    if ADone then
      with AViewInfo do
        AElement.Draw(Canvas.Handle, Bounds, Byte(IsDown));
  end;
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawCaption(ACanvas: TcxCanvas;
  const ATextAreaBounds: TRect; AAlignmentHorz: TAlignment;
  AAlignmentVert: TcxAlignmentVert; AMultiLine, AShowEndEllipsis: Boolean;
  const AText: string; AFont: TFont; ATextColor: TColor);
const
  AlignmentsHorz: array[TAlignment] of Integer =
    (cxAlignLeft, cxAlignRight, cxAlignHCenter);
  AlignmentsVert: array[TcxAlignmentVert] of Integer =
    (cxAlignTop, cxAlignBottom, cxAlignVCenter);
  MultiLines: array[Boolean] of Integer = (cxSingleLine, cxWordBreak);
  ShowEndEllipsises: array[Boolean] of Integer = (0, cxShowEndEllipsis);
begin
  with ACanvas do
    if AText <> '' then
    begin
      Brush.Style := bsClear;
      Font := AFont;
      Font.Color := ATextColor;
      DrawText(AText, ATextAreaBounds, AlignmentsHorz[AAlignmentHorz] or
        AlignmentsVert[AAlignmentVert] or MultiLines[AMultiLine] or
        ShowEndEllipsises[AShowEndEllipsis]);
    end;
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawHorizontalHeader(
  AViewInfo: TcxSchedulerDayHeaderCellViewInfo);
begin
  with AViewInfo do
  begin
    Painter.DrawHeader(Canvas, Bounds, TextRect, Neighbors, Borders,
      cxHeaderStateToButtonState[Selected], AlignHorz, AlignVert, MultiLine,
      ShowEndEllipsis, '', Font, TextColor, 0, nil);
    DrawCaption(Canvas, TextRect, AlignHorz, AlignVert, MultiLine,
      ShowEndEllipsis, DisplayText, Font, TextColor);
  end;
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawVerticalHeader(
  AViewInfo: TcxSchedulerDayHeaderCellViewInfo);
var
  ABitmap: TcxBitmap;
  R: TRect;
begin
  with AViewInfo do
  begin
    ABitmap := TcxBitmap.CreateSize(Bounds.Right - Bounds.Left,
      Bounds.Bottom - Bounds.Top);
    try
      ABitmap.cxCanvas.WindowOrg := Bounds.TopLeft;
      BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
        Canvas.Handle, Bounds.Left, Bounds.Top, SRCCOPY);
      ABitmap.Rotate(raPlus90, True);

      R := cxRect(0, 0, ABitmap.Width, ABitmap.Height);
      Painter.DrawHeader(ABitmap.cxCanvas, R, R, Neighbors, Borders, cxbsNormal,
        taCenter, vaCenter, False, False, '', Font, TextColor, Color, nil);

      if RotateText then
      begin
        ABitmap.Rotate(ra0, True);
        DrawCaption(ABitmap.cxCanvas, R, AlignHorz, AlignVert, MultiLine,
          ShowEndEllipsis, DisplayText, Font, TextColor);
        ABitmap.Rotate(raPlus90);
      end
      else
      begin
        ABitmap.Rotate(raPlus90, True);
        R.BottomRight := cxPoint(R.Bottom, R.Right);
        DrawCaption(ABitmap.cxCanvas, R, AlignHorz, AlignVert, MultiLine,
          ShowEndEllipsis, DisplayText, Font, TextColor);
      end;
      
      BitBlt(Canvas.Handle, Bounds.Left, Bounds.Top, ABitmap.Width, ABitmap.Height,
        ABitmap.Canvas.Handle, 0, 0, SRCCOPY);  
    finally
      ABitmap.Free;
    end;
  end;  
end;

procedure TcxScheduler3SkinViewItemsPainter.DoCustomDrawDayHeader(
  AViewInfo: TcxSchedulerDayHeaderCellViewInfo; var ADone: Boolean);
begin
  inherited DoCustomDrawDayHeader(AViewInfo, ADone);
  ADone := IsSkinAvalaible;
  if ADone then
    with AViewInfo do
      if RotateHeader or RotateText then
        DrawVerticalHeader(AViewInfo)
      else
        DrawHorizontalHeader(AViewInfo);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawAllDayArea(ACanvas: TcxCanvas;
  const ARect: TRect; ABorderColor: TColor; ABorders: TcxBorders;
  AViewParams: TcxViewParams; ASelected: Boolean; ATransparent: Boolean);  
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
begin
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerAllDayArea[ASelected];
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
      DrawClippedElement(ACanvas, AElement, ABorders, ARect);
  end
  else
    ADoCustomDraw := True;

  if ADoCustomDraw then
    inherited DrawAllDayArea(ACanvas, ARect, ABorderColor, ABorders, AViewParams,
      ASelected, ATransparent);
end;  

procedure TcxScheduler3SkinViewItemsPainter.DrawCurrentTime(ACanvas: TcxCanvas;
  AColor: TColor; AStart: TDateTime; ABounds: TRect);
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
  ANow: TDateTime;
  Y, I: Integer;
begin
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerCurrentTimeIndicator;
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
    begin
      ANow := TimeOf(Now) - TimeOf(AStart);
      if (ANow < 0) or (ANow >= HourToTime) then Exit;
      Y := Trunc(ABounds.Top + (ANow * cxRectHeight(ABounds)) / HourToTime);
      Dec(ABounds.Right);
      Inc(ABounds.Left, 5);
      with AElement.Image.Size do
        ABounds := cxRectSetTop(ABounds, Y - cy div 2, cy);
      for I := 0 to 1 do
        AElement.Draw(ACanvas.Handle, ABounds, I);
    end;
  end
  else
    ADoCustomDraw := True;

  if ADoCustomDraw then
    inherited DrawCurrentTime(ACanvas, AColor, AStart, ABounds);
end;

function TcxScheduler3SkinViewItemsPainter.NeedDrawSelection: Boolean;
begin
  Result := not IsSkinAvalaible;
end;

function TcxScheduler3SkinViewItemsPainter.DrawCurrentTimeFirst: Boolean;
begin
  Result := True;
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawEvent(
  AViewInfo: TcxSchedulerEventCellViewInfo);
const
  AShadowSize = 4;
  ASelectedFlags: array[Boolean] of TdxSkinElementState = (esNormal, esHot);
var
  ADone: Boolean;
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;

  function CheckRect(const ARect: TRect): TRect;
  begin
    if AViewInfo.Selected and (ASkinInfo.SchedulerAppointmentBorderSize <> nil) then
    begin
      with ASkinInfo.SchedulerAppointmentBorderSize do
      begin
        Result := Rect(ARect.Left, ARect.Top - Value, ARect.Right + Value,
          ARect.Bottom + Value);          
        if IsRectEmpty(AViewInfo.TimeLineRect) then
          Dec(Result.Left, Value)
        else
          Dec(Result.Left, cxTimeLineWidth);
      end;
    end
    else
      Result := ARect;
  end;

  procedure DrawLabeledEvent(ALabelColor: TColor; AMask: TdxSkinElement);
  const
    AImageIndexs: array[Boolean] of Integer = (1, 0);
  var
    ABitmap: TcxBitmap;
    AMaskBmp: TcxBitmap;
    ASourceBmp: TcxBitmap;
    R: TRect;
  begin
    if AMask = nil then Exit;
    R := AViewInfo.Bounds;
    OffsetRect(R, -R.Left, -R.Top);
    AMaskBmp := TcxBitmap.CreateSize(R);
    ASourceBmp := TcxBitmap.CreateSize(R);
    try
      ASourceBmp.Canvas.Brush.Color := ALabelColor;
      ASourceBmp.Canvas.FillRect(R);
      AMask.Draw(AMaskBmp.Canvas.Handle, R, AImageIndexs[IsRectEmpty(AViewInfo.TimeLineRect)]);           
      ABitmap := TcxBitmap.CreateSize(R);
      try
        ABitmap.PixelFormat := pf32bit;
        BitBlt(AMaskBmp.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
          AMaskBmp.Canvas.Handle, 0, 0, NOTSRCCOPY);
        BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
          AMaskBmp.Canvas.Handle, 0, 0, SRCCOPY);
        BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height,
          ASourceBmp.Canvas.Handle, 0, 0, SrcErase);
        BitBlt(AViewInfo.Canvas.Handle, AViewInfo.Bounds.Left, AViewInfo.Bounds.Top,
          ABitmap.Width, ABitmap.Height, AMaskBmp.Canvas.Handle, 0, 0, SrcAnd);
        BitBlt(AViewInfo.Canvas.Handle, AViewInfo.Bounds.Left, AViewInfo.Bounds.Top,
          ABitmap.Width, ABitmap.Height, ABitmap.Canvas.Handle, 0, 0, SrcInvert);
      finally
        ABitmap.Free;
      end;
    finally
      AMaskBmp.Free;
      ASourceBmp.Free;
    end;
  end;

  function GetSeparatorColor(ABorderColor: TdxSkinColor): TColor;
  begin
    Result := clDefault;
    if ABorderColor <> nil then
      Result := ABorderColor.Value;
    if (Result = clNone) or (Result = clDefault) then
      Result := AViewInfo.SeparatorColor;
  end;

  function GetDrawShadow: Boolean;
  begin
    with AViewInfo do
      Result := EventViewData.DrawShadows and (EventViewData.Bitmap <> nil) and
        not (Hidden or Selected) and AViewInfo.ShowTimeLine;
  end;

begin
  ASkinInfo := SkinInfo;
  ADone := ASkinInfo <> nil;
  if ADone then
  begin
    AElement := ASkinInfo.SchedulerAppointment[IsRectEmpty(AViewInfo.TimeLineRect)];
    ADone := (AElement <> nil);
    if ADone then
      with AViewInfo do
      begin
        Canvas.SaveClipRegion;
        try
          Canvas.SetClipRegion(TcxRegion.Create(EventViewData.VisibleRect), roSet);
          Canvas.ExcludeClipRect(TimeLineRect);
          if GetDrawShadow then
            InternalDrawShadow(Canvas, Bounds, EventViewData.VisibleRect);
          SeparatorColor := GetSeparatorColor(ASkinInfo.SchedulerAppointmentBorder);
          AElement.Draw(Canvas.Handle, CheckRect(Bounds), 0, ASelectedFlags[Selected]);
          if Event.LabelColor <> clDefault then
            DrawLabeledEvent(Event.LabelColor, ASkinInfo.SchedulerAppointmentMask);
          Transparent := True;
        finally
          Canvas.RestoreClipRegion;
        end;
      end;
  end;     
  if not ADone then
    inherited DrawEvent(AViewInfo);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawEventAsProgressText(
  AViewInfo: TcxSchedulerEventCellViewInfo; AContent: TRect; AProgressRect: TRect;
  const AText: string);
begin
  if IsSkinAvalaible then
    cxDrawText(AViewInfo.Canvas.Handle, AText, AContent,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE)
  else
    inherited DrawEventAsProgressText(AViewInfo, AContent, AProgressRect, AText);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawTimeGridCurrentTime(
  ACanvas: TcxCanvas; AColor: TColor; const ATimeLineRect: TRect);
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
begin
  ADoCustomDraw := True;
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerTimeGridCurrentTimeIndicator;
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
      AElement.Draw(ACanvas.Handle, ATimeLineRect);
  end;
  if ADoCustomDraw then
    inherited DrawTimeGridCurrentTime(ACanvas, AColor, ATimeLineRect);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawTimeGridHeader(ACanvas: TcxCanvas;
  ABorderColor: TColor; AViewInfo: TcxSchedulerCustomViewInfoItem;
  ABorders: TcxBorders; ASelected: Boolean);
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
begin
  ADoCustomDraw := True;
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerTimeGridHeader[ASelected];
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
      with AViewInfo do
        DrawClippedElement(ACanvas, AElement, ABorders, Bounds);
  end;
  if ADoCustomDraw then                    
    inherited DrawTimeGridHeader(ACanvas, ABorderColor, AViewInfo, ABorders,
      ASelected);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawTimeLine(ACanvas: TcxCanvas;
  const ARect: TRect; AViewParams: TcxViewParams; ABorders: TcxBorders;
  ABorderColor: TColor);
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
begin
  ADoCustomDraw := True;
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerTimeLine;
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
      DrawClippedElement(ACanvas, AElement, ABorders, ARect);
  end;
  if ADoCustomDraw then
    inherited DrawTimeLine(ACanvas, ARect, AViewParams, ABorders, ABorderColor); 
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawTimeRulerBackground(
  ACanvas: TcxCanvas; const ARect: TRect; ABorders: TcxBorders;
  AViewParams: TcxViewParams; ATransparent: Boolean);
var
  ADoCustomDraw: Boolean;
  AElement: TdxSkinElement;
begin
  ADoCustomDraw := True;
  if IsSkinAvalaible then
  begin
    AElement := SkinInfo.SchedulerTimeRuler;
    ADoCustomDraw := AElement = nil;
    if not ADoCustomDraw then
      DrawClippedElement(ACanvas, AElement, ABorders, ARect);
  end;
  if ADoCustomDraw then
    inherited DrawTimeRulerBackground(ACanvas, ARect, ABorders, AViewParams,
      ATransparent);
end;

procedure TcxScheduler3SkinViewItemsPainter.DrawShadow(ACanvas: TcxCanvas;
  const ARect, AVisibleRect: TRect; ABuffer: TBitmap);
begin
  if not IsSkinAvalaible then
    inherited DrawShadow(ACanvas, ARect, AVisibleRect, ABuffer);
end;

procedure TcxScheduler3SkinViewItemsPainter.InternalDrawShadow(ACanvas: TcxCanvas;
  const ARect, AVisibleRect: TRect);
const
  ShadowSize = 4;

  procedure DrawShadowLine(const AShadow: TdxSkinElement; const ARect: TRect);
  begin
    if AShadow <> nil then
      AShadow.Draw(ACanvas.Handle, ARect);
  end;

begin
  DrawShadowLine(SkinInfo.SchedulerAppointmentShadow[False],
    Rect(ARect.Left + ShadowSize, ARect.Bottom - ShadowSize,
      ARect.Right + ShadowSize, ARect.Bottom + ShadowSize));
  DrawShadowLine(SkinInfo.SchedulerAppointmentShadow[True],
    Rect(ARect.Right - ShadowSize, ARect.Top + ShadowSize,
      ARect.Right + ShadowSize, ARect.Bottom - ShadowSize));
end;

initialization
  ExternalPainterClass := TcxScheduler3SkinViewItemsPainter;

finalization
  ExternalPainterClass := TcxSchedulerExternalPainter;

end.
