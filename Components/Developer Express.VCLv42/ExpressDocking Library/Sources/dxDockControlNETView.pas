{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressDocking                                              }
{                                                                   }
{       Copyright (c) 2002-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSDOCKING AND ALL ACCOMPANYING  }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.             }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxDockControlNETView;

{$I cxVer.inc}

interface

uses
  Menus, Windows, Graphics, Classes, Controls, ExtCtrls, Messages, Forms,
  dxDockControl, dxDockPanel;

type
  TdxDockControlNETPainter = class(TdxDockControlPainter)
  protected
    class procedure AssignDefaultFont(AManager: TdxDockingManager); override;

    function GetNETBackColor: TColor; virtual;
    function GetCaptionColor(IsActive: Boolean): TColor; override;
    function GetCaptionFontColor(IsActive: Boolean): TColor; override;
    function GetTabsColor: TColor; override;
    function GetTabColor(IsActive: Boolean): TColor; override;
    function GetTabFontColor(IsActive: Boolean): TColor; override;
    function GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor; override;
    function GetHideBarColor: TColor; override;
  public
    // CustomDockControl
    function CanVerticalCaption: Boolean; override;
    function GetCaptionHeight: Integer; override;
    function GetCaptionVertInterval: Integer; override;

    procedure DrawBorder(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawCaptionButtonSelection(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot: Boolean); override;
    procedure DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    // TabContainer
    function GetTabsHeight: Integer; override;
    function GetTabVertInterval: Integer; override;

    procedure DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
      APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsNextTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsPrevTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsButtonSelection(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    // AutoHideContainer
    function GetHideBarHeight: Integer; override;
    function GetHideBarWidth: Integer; override;

    procedure DrawHideBar(ACanvas: TCanvas; ARect: TRect; APosition: TdxAutoHidePosition); override;
    procedure DrawHideBarButton(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); override;
  end;

implementation

uses Math, dxDockConsts, cxGraphics;

{ TdxDockControlNETPainter }

class procedure TdxDockControlNETPainter.AssignDefaultFont(AManager: TdxDockingManager);
begin
  with AManager.Font do
  begin
    Charset := DEFAULT_CHARSET;
    Color := clBlack;
    Height := -11;
    Name := 'Tahoma';
    Pitch := fpDefault;
    Size := 8;
    Style := [];
  end;
end;

function TdxDockControlNETPainter.GetNETBackColor: TColor;
var
  r, g, b, m, d, md: Integer;
begin
  Result := ColorToRGB(GetColor);
  r := GetRValue(Result);
  g := GetGValue(Result);
  b := GetBValue(Result);
  m := Max(Max(r, g), b);
  d := $23;
  md := (255 - (m + d));
  if md > 0 then md := 0;
  Inc(r, d + md);
  Inc(g, d + md);
  Inc(b, d + md);
  Result := RGB(r, g, b);
end;

function TdxDockControlNETPainter.GetCaptionColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := clActiveCaption
  else Result := GetColor;
end;

function TdxDockControlNETPainter.GetCaptionFontColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := clCaptionText
  else Result := clBlack;
end;

function TdxDockControlNETPainter.GetTabsColor: TColor;
begin
  Result := GetNETBackColor;
end;

function TdxDockControlNETPainter.GetTabColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := GetColor
  else Result := GetNETBackColor;
end;

function TdxDockControlNETPainter.GetTabFontColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := GetFont.Color
  else
  begin
    Result := GetFont.Color;
    Result := LightColor(Result);
  end;
end;

function TdxDockControlNETPainter.GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor;
begin
  Result := DarkColor(GetColor);
end;

function TdxDockControlNETPainter.GetHideBarColor: TColor;
begin
  Result := GetNETBackColor;
end;

procedure TdxDockControlNETPainter.DrawBorder(ACanvas: TCanvas; ARect: TRect);
var
  ABorderWidths: TRect;
begin
  ACanvas.Brush.Color := ColorToRGB(GetBorderColor);
  ACanvas.Brush.Style := bsSolid;
  with ARect do
  begin
    ABorderWidths := GetBorderWidths;
    ACanvas.FillRect(Rect(Left, Top, Left + ABorderWidths.Left, Bottom));
    ACanvas.FillRect(Rect(Left, Bottom - ABorderWidths.Bottom, Right, Bottom));
    ACanvas.FillRect(Rect(Right - ABorderWidths.Right, Top, Left + Right, Bottom));
    ACanvas.FillRect(Rect(Left, Top, Right, Top + ABorderWidths.Top));
  end;
  if DockControl.AutoHide then
  begin
    DrawColorEdge(ACanvas, ARect, GetColor, etSunkenInner, [epTopLeft]);
    DrawColorEdge(ACanvas, ARect, GetColor, etRaisedInner, [epBottomRight]);
  end;
end;

procedure TdxDockControlNETPainter.DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean);
begin
  ACanvas.Brush.Style := bsSolid;
  if IsActive then
  begin
    ACanvas.Pen.Color := ColorToRGB(GetCaptionColor(IsActive));
    ACanvas.Brush.Color := ColorToRGB(GetCaptionColor(IsActive));
    ACanvas.FillRect(ARect);
  end
  else
  begin
    ACanvas.Brush.Color := ColorToRGB(GetCaptionColor(IsActive));
    ACanvas.FillRect(ARect);
    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Color := DarkColor(GetCaptionColor(IsActive));
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Width := 1;
    with ARect do
    begin
      ExcludeClipRect(ACanvas.Handle, Left, Top, Left + 1, Top + 1);
      ExcludeClipRect(ACanvas.Handle, Right - 1, Top, Right, Top + 1);
      ExcludeClipRect(ACanvas.Handle, Right - 1, Bottom - 1, Right, Bottom);
      ExcludeClipRect(ACanvas.Handle, Left, Bottom - 1, Left + 1, Bottom);
      ACanvas.Rectangle(Left, Top, Right, Bottom);
    end;
  end;
end;

procedure TdxDockControlNETPainter.DrawCaptionButtonSelection(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot: Boolean);
begin
  if IsDown and IsHot then
  begin
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etSunkenInner, [epTopLeft]);
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etSunkenOuter, [epBottomRight]);
  end
  else if IsHot then
  begin
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etRaisedOuter, [epTopLeft]);
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
  end;
end;

procedure TdxDockControlNETPainter.DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));

  ACanvas.MoveTo(ARect.Left + 3, ARect.Top + 3);
  ACanvas.LineTo(ARect.Right - 3 + 1, ARect.Bottom - 3 + 1);
  ACanvas.MoveTo(ARect.Right - 3, ARect.Top + 3);
  ACanvas.LineTo(ARect.Left + 3 - 1, ARect.Bottom - 3 + 1);
end;

procedure TdxDockControlNETPainter.DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  if IsSwitched then
  begin
    ACanvas.Rectangle(ARect.Left + 3, ARect.Top + 3, ARect.Right - 2, ARect.Bottom - 4);
    ACanvas.MoveTo(ARect.Left + 3, ARect.Top + 2);
    ACanvas.LineTo(ARect.Left + 3, ARect.Bottom - 3);
    ACanvas.MoveTo(ARect.Left + 3, ARect.Bottom - 6);
    ACanvas.LineTo(ARect.Right - 3, ARect.Bottom - 6);
    ACanvas.MoveTo(ARect.Left + 1, ARect.Top + 5);
    ACanvas.LineTo(ARect.Left + 3, ARect.Top + 5);
  end
  else
  begin
    ACanvas.Rectangle(ARect.Left + 4, ARect.Top + 2, ARect.Right - 3, ARect.Bottom - 3);
    ACanvas.MoveTo(ARect.Left + 3, ARect.Bottom - 4);
    ACanvas.LineTo(ARect.Right - 2, ARect.Bottom - 4);
    ACanvas.MoveTo(ARect.Right - 5, ARect.Top + 2);
    ACanvas.LineTo(ARect.Right - 5, ARect.Bottom - 3);
    ACanvas.MoveTo(ARect.Left + 6, ARect.Bottom - 3);
    ACanvas.LineTo(ARect.Left + 6, ARect.Bottom - 1);
  end;
end;

procedure TdxDockControlNETPainter.DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := (ARect.Right - ARect.Left) div 16 + 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  if IsSwitched then
  begin
    ACanvas.Rectangle(ARect.Left + 5, ARect.Top + 2, ARect.Right - 1, ARect.Bottom - 4);
    ACanvas.Rectangle(ARect.Left + 2, ARect.Top + 5, ARect.Right - 4, ARect.Bottom - 1);
  end
  else ACanvas.Rectangle(ARect.Left + 3, ARect.Top + 3, ARect.Right - 2, ARect.Bottom - 2);
end;

procedure TdxDockControlNETPainter.DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean);
begin
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := GetFont;
  ACanvas.Font.Color := ColorToRGB(GetCaptionFontColor(IsActive));
  cxDrawText(ACanvas.Handle, DockControl.Caption, ARect,
    DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
end;

procedure TdxDockControlNETPainter.DrawHideBar(ACanvas: TCanvas; ARect: TRect;
  APosition: TdxAutoHidePosition);
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := GetHideBarColor;
  ACanvas.FillRect(ARect);
  ACanvas.Brush.Color := ColorToRGB(GetHideBarButtonColor);
  case APosition of
    ahpLeft: ARect.Right := ARect.Left + GetHideBarVertInterval;
    ahpTop: ARect.Bottom := ARect.Top + GetHideBarVertInterval;
    ahpRight: ARect.Left := ARect.Right - GetHideBarVertInterval;
    ahpBottom: ARect.Top := ARect.Bottom - GetHideBarVertInterval;
  end;
  ACanvas.FillRect(ARect);
  with ARect do ExcludeClipRect(ACanvas.Handle, Left, Top, Right, Bottom);
end;

procedure TdxDockControlNETPainter.DrawHideBarButton(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
const
  Edges: array[TdxAutoHidePosition] of TdxEdgePositions = ([epTop, epBottomRight],
    [epLeft, epBottomRight], [epTopLeft, epBottom], [epTopLeft, epRight], []);
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetHideBarButtonColor);
  ACanvas.FillRect(ARect);
  DrawColorEdge(ACanvas, ARect, GetHideBarButtonColor, etFlat, Edges[APosition]);
  DrawHideBarButtonContent(ACanvas, AControl, ARect, APosition);
end;

procedure TdxDockControlNETPainter.DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
  ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
begin
  if IsActive then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := ColorToRGB(GetColor);
    ACanvas.FillRect(ARect);
    if APosition = tctpTop then
      DrawColorEdge(ACanvas, ARect, GetTabColor(IsActive), etRaisedOuter, [epTopLeft, epRight])
    else DrawColorEdge(ACanvas, ARect, GetTabColor(IsActive), etRaisedOuter, [epLeft, epBottomRight]);
  end
  else
  begin
    R := ARect;
    InflateRect(R, 1, -3);
    DrawColorEdge(ACanvas, R, GetTabColor(IsActive), etRaisedInner, [epRight]);
  end;
  DrawTabContent(ACanvas, AControl, ARect, IsActive, APosition);
end;

procedure TdxDockControlNETPainter.DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
  APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetTabsColor);
  ACanvas.FillRect(ARect);

  R := ARect;
  if APosition = tctpTop then
  begin
    R.Bottom := AActiveTabRect.Bottom;
    DrawColorEdge(ACanvas, R, GetTabColor(True), etSunkenOuter, [epBottom]);
  end
  else
  begin
    R.Top := AActiveTabRect.Top;
    DrawColorEdge(ACanvas, R, GetTabColor(True), etSunkenOuter, [epTop]);
  end;

  if APosition = tctpTop then
    ARect.Top := AActiveTabRect.Bottom
  else ARect.Bottom := AActiveTabRect.Top;
  ACanvas.Brush.Color := ColorToRGB(GetTabColor(True));
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlNETPainter.DrawTabsNextTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  pts: array[0..2] of TPoint;
begin
  DrawTabsButtonSelection(ACanvas, ARect, IsDown, IsHot, IsEnable, APosition);

  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := GetTabsScrollButtonsSignColor(IsEnable);
  if IsEnable then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := GetTabsScrollButtonsSignColor(IsEnable);
  end
  else ACanvas.Brush.Style := bsClear;

  InflateRect(ARect, -1, -1);
  pts[0] := Point(ARect.Left + 4, ARect.Top + 2);
  pts[1] := Point(ARect.Left + 4, ARect.Bottom - 4);
  pts[2] := Point(ARect.Right - 6, ARect.Top + 6);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlNETPainter.DrawTabsPrevTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  pts: array[0..2] of TPoint;
begin
  DrawTabsButtonSelection(ACanvas, ARect, IsDown, IsHot, IsEnable, APosition);

  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := GetTabsScrollButtonsSignColor(IsEnable);
  if IsEnable then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := GetTabsScrollButtonsSignColor(IsEnable);
  end
  else ACanvas.Brush.Style := bsClear;

  InflateRect(ARect, -1, -1);
  pts[0] := Point(ARect.Right - 6, ARect.Top + 2);
  pts[1] := Point(ARect.Right - 6, ARect.Bottom - 4);
  pts[2] := Point(ARect.Left + 4, ARect.Top + 6);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlNETPainter.DrawTabsButtonSelection(ACanvas: TCanvas; ARect: TRect;
  IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
begin
  if IsDown and IsHot and IsEnable then
  begin
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etSunkenOuter, [epTopLeft]);
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etSunkenOuter, [epBottomRight]);
  end
  else if IsHot and IsEnable then
  begin
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etRaisedOuter, [epTopLeft]);
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etRaisedOuter, [epBottomRight]);
  end;
end;

function TdxDockControlNETPainter.CanVerticalCaption: Boolean;
begin
  Result := False;
end;

function TdxDockControlNETPainter.GetCaptionHeight: Integer;
begin
  Result := 5 + GetFont.Size + 5;
end;

function TdxDockControlNETPainter.GetCaptionVertInterval: Integer;
begin
  Result := 4;
end;

function TdxDockControlNETPainter.GetTabsHeight: Integer;
begin
  Result := 8 + GetFont.Size + 8;
  if Result < 2 * GetTabVertInterval + 2 + GetImageHeight + 2 + 2 * GetTabVertInterval then
    Result := 2 * GetTabVertInterval + 2 + GetImageHeight + 2 + 2 * GetTabVertInterval;
end;

function TdxDockControlNETPainter.GetTabVertInterval: Integer;
begin
  Result := 1;
end;

function TdxDockControlNETPainter.GetHideBarHeight: Integer;
begin
  Result := 8 + GetFont.Size + 8;
  if Result < GetHideBarVertInterval + 2 + GetImageHeight + 2 + GetHideBarVertInterval then
    Result := GetHideBarVertInterval + 2 + GetImageHeight + 2 + GetHideBarVertInterval;
end;

function TdxDockControlNETPainter.GetHideBarWidth: Integer;
begin
  Result := 8 + GetFont.Size + 8;
  if Result < GetHideBarVertInterval + 2 + GetImageWidth + 2 + GetHideBarVertInterval then
    Result := GetHideBarVertInterval + 2 + GetImageWidth + 2 + GetHideBarVertInterval;
end;

end.
