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

unit dxDockControlOfficeView;

{$I cxVer.inc}

interface

uses
  Menus, Windows, Graphics, Classes, Controls, ExtCtrls, Messages, Forms,
  dxDockControl, dxDockControlNETView;

type
  TdxDockControlOfficePainter = class(TdxDockControlNETPainter)
  protected
    class procedure CreateColors; override;
    class procedure RefreshColors; override;
    class procedure ReleaseColors; override;

    function GetBorderColor: TColor; override;
    function GetCaptionColor(IsActive: Boolean): TColor; override;
    function GetCaptionFontColor(IsActive: Boolean): TColor; override;
    function GetCaptionSignColor(IsActive, IsDown, IsHot: Boolean): TColor; override;
    function GetTabFontColor(IsActive: Boolean): TColor; override;
    function GetTabsScrollButtonsColor: TColor; override;
    function GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor; override;

    function NeedRedrawOnResize: Boolean; override;
  public
    // CustomDockControl
    procedure DrawBorder(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaptionButtonSelection(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot: Boolean); override;
    procedure DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawClient(ACanvas: TCanvas; ARect: TRect); override;
    // TabContainer
    procedure DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
      APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); override;
    // AutoHideContainer
    procedure DrawHideBar(ACanvas: TCanvas; ARect: TRect; APosition: TdxAutoHidePosition); override;
    procedure DrawHideBarButton(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); override;
  end;

implementation

uses
  dxDockConsts, dxOffice11;

{ TdxDockControlOfficePainter }

class procedure TdxDockControlOfficePainter.CreateColors;
begin
//  CreateOffice11Colors;
// is calling indirectly in cxLookAndFeels 
end;

class procedure TdxDockControlOfficePainter.RefreshColors;
begin
  RefreshOffice11Colors;
end;

class procedure TdxDockControlOfficePainter.ReleaseColors;
begin
//  ReleaseOffice11Colors;
// is calling indirectly in cxLookAndFeels 
end;

function TdxDockControlOfficePainter.GetBorderColor: TColor;
begin
  Result := dxOffice11BarFloatingBorderColor2;
end;

function TdxDockControlOfficePainter.GetCaptionColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := dxOffice11BarFloatingCaptionColor
  else Result := dxOffice11BarFloatingBorderColor2;
end;

function TdxDockControlOfficePainter.GetCaptionFontColor(IsActive: Boolean): TColor;
begin
  if IsActive then
    Result := dxOffice11BarFloatingCaptionTextColor1
  else Result := dxOffice11BarFloatingCaptionTextColor2;
end;

function TdxDockControlOfficePainter.GetCaptionSignColor(IsActive, IsDown, IsHot: Boolean): TColor;
begin
  Result := GetCaptionFontColor(IsActive and not (IsDown and IsHot) and not IsHot);
end;

function TdxDockControlOfficePainter.GetTabFontColor(IsActive: Boolean): TColor;
begin
  Result := GetFont.Color;
end;

function TdxDockControlOfficePainter.GetTabsScrollButtonsColor: TColor;
begin
  Result := dxOffice11ToolbarsColor2;
end;

function TdxDockControlOfficePainter.GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor;
begin
  Result := DarkColor(dxOffice11ToolbarsColor2);
end;

function TdxDockControlOfficePainter.NeedRedrawOnResize: Boolean;
begin
  Result := True;
end;

procedure TdxDockControlOfficePainter.DrawBorder(ACanvas: TCanvas; ARect: TRect);
var
  ABorderWidths: TRect;
begin
  ACanvas.Brush.Style := bsSolid;
  with ARect do
  begin
    ABorderWidths := GetBorderWidths;
    ACanvas.Brush.Color := dxOffice11BarFloatingBorderColor2;
    ACanvas.FillRect(Rect(Left, Top, Right, Top + ABorderWidths.Top));
    ACanvas.Brush.Color := dxOffice11BarFloatingBorderColor1;
    ACanvas.FillRect(Rect(Left, Bottom - ABorderWidths.Bottom, Right, Bottom));
    FillGradientRect(ACanvas.Handle, Rect(Left, Top, Left + ABorderWidths.Left, Bottom),
      dxOffice11BarFloatingBorderColor2, dxOffice11BarFloatingBorderColor1, False);
    FillGradientRect(ACanvas.Handle, Rect(Right - ABorderWidths.Right, Top, Left + Right, Bottom),
      dxOffice11BarFloatingBorderColor2, dxOffice11BarFloatingBorderColor1, False);
  end;
  if DockControl.AutoHide then
    DrawColorEdge(ACanvas, ARect, dxOffice11BarFloatingBorderColor1, etStandard, [epRect]);
end;

procedure TdxDockControlOfficePainter.DrawCaptionButtonSelection(
  ACanvas: TCanvas; ARect: TRect; IsActive, IsDown, IsHot: Boolean);
begin
  if IsDown and IsHot then
    FillGradientRect(ACanvas.Handle, ARect, dxOffice11SelectedDownColor1, dxOffice11SelectedDownColor2, False)
  else if IsHot then
    FillGradientRect(ACanvas.Handle, ARect, dxOffice11SelectedColor1, dxOffice11SelectedColor2, False);
  if (IsDown and IsHot) or IsHot then
    Office11FrameSelectedRect(ACanvas.Handle, ARect);
end;

procedure TdxDockControlOfficePainter.DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
var
  pts: array[0..2] of TPoint;
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  if DockControl.SideContainer is TdxVertContainerDockSite then
    if IsSwitched then
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Top + 2);
      pts[1] := Point(ARect.Left + 2, ARect.Top + 2);
    end
    else
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Bottom - 4);
      pts[1] := Point(ARect.Left + 2, ARect.Bottom - 4);
    end
  else
    if IsSwitched then
    begin
      pts[0] := Point(ARect.Left + 2, ARect.Top + 2);
      pts[1] := Point(ARect.Left + 2, ARect.Bottom - 4);
    end
    else
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Top + 2);
      pts[1] := Point(ARect.Right - 4, ARect.Bottom - 4);
    end;
  pts[2] := Point(ARect.Left + 5, ARect.Top + 5);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlOfficePainter.DrawClient(ACanvas: TCanvas; ARect: TRect);
begin
  FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor2, False);
end;

procedure TdxDockControlOfficePainter.DrawTabs(ACanvas: TCanvas; ARect,
  AActiveTabRect: TRect; APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
  ABorders: TdxEdgePositions;
begin
  FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor2, False);

  R := ARect;
  if APosition = tctpTop then
  begin
    R.Bottom := AActiveTabRect.Bottom;
    ABorders := [epBottom];
  end
  else
  begin
    R.Top := AActiveTabRect.Top;
    ABorders := [epTop];
  end;
  DrawColorEdge(ACanvas, R, dxOffice11SelectedBorderColor, etStandard, ABorders);

  if APosition = tctpTop then
  begin
    ARect.Top := AActiveTabRect.Bottom;
    ACanvas.Brush.Color := dxOffice11SelectedColor2;
  end
  else
  begin
    ARect.Bottom := AActiveTabRect.Top;
    ACanvas.Brush.Color := dxOffice11SelectedColor1;
  end;  
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlOfficePainter.DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
  ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition);
const
  TabBorders: array[TdxTabContainerTabsPosition] of TdxEdgePositions =
    ([epTopLeft, epRight], [epLeft, epBottomRight]);
var
  R: TRect;
begin
  if IsActive then
  begin
    FillGradientRect(ACanvas.Handle, ARect, dxOffice11SelectedColor1, dxOffice11SelectedColor2, False);
    DrawColorEdge(ACanvas, ARect, dxOffice11SelectedBorderColor, etStandard, TabBorders[APosition]);
  end
  else
  begin
    R := ARect;
    InflateRect(R, 1, -3);
    DrawColorEdge(ACanvas, R, dxOffice11BarSeparatorColor1, etStandard, [epRight]);
    OffsetRect(R, 1, 1);
    DrawColorEdge(ACanvas, R, dxOffice11BarSeparatorColor2, etStandard, [epRight]);
  end;
  DrawTabContent(ACanvas, AControl, ARect, IsActive, APosition);
end;

procedure TdxDockControlOfficePainter.DrawHideBar(ACanvas: TCanvas;
  ARect: TRect; APosition: TdxAutoHidePosition);
begin
  case APosition of
    ahpLeft: begin
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor2, dxOffice11ToolbarsColor2, True);
      ARect.Right := ARect.Left + GetHideBarVertInterval;
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11DockColor1, dxOffice11DockColor1, True);
    end;
    ahpTop: begin
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor2, dxOffice11ToolbarsColor1, True);
      ARect.Bottom := ARect.Top + GetHideBarVertInterval;
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11DockColor1, dxOffice11DockColor2, True);
    end;
    ahpRight: begin
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor1, True);
      ARect.Left := ARect.Right - GetHideBarVertInterval;
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11DockColor2, dxOffice11DockColor2, True);
    end;
    ahpBottom: begin
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11ToolbarsColor2, dxOffice11ToolbarsColor1, True);
      ARect.Top := ARect.Bottom - GetHideBarVertInterval;
      FillGradientRect(ACanvas.Handle, ARect, dxOffice11DockColor1, dxOffice11DockColor2, True);
    end;
  end;
  with ARect do ExcludeClipRect(ACanvas.Handle, Left, Top, Right, Bottom);
end;

type
  TdxTabContainerDockSiteAccess = class(TdxTabContainerDockSite);

procedure TdxDockControlOfficePainter.DrawHideBarButton(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
const
  Edges: array[TdxAutoHidePosition] of TdxEdgePositions = ([epTop, epBottomRight],
    [epLeft, epBottomRight], [epTopLeft, epBottom], [epTopLeft, epRight], []);
var
  I: Integer;
  R: TRect;
begin
  R := ARect;
  if AControl is TdxTabContainerDockSite then
  begin
    for I := 0 to TdxTabContainerDockSiteAccess(AControl).ActiveChildIndex - 1 do
    begin
      if not TdxTabContainerDockSiteAccess(AControl).IsValidChild(AControl.Children[I]) then continue;
      if not (APosition in [ahpLeft, ahpRight]) then
        R.Left := R.Left + (GetDefaultImageWidth + 2 * GetHideBarHorizInterval)
      else R.Top := R.Top + (GetDefaultImageHeight + 2 * GetHideBarHorizInterval);
    end;
    for I := AControl.ChildCount - 1 downto TdxTabContainerDockSiteAccess(AControl).ActiveChildIndex + 1 do
    begin
      if not TdxTabContainerDockSiteAccess(AControl).IsValidChild(AControl.Children[I]) then continue;
      if not (APosition in [ahpLeft, ahpRight]) then
        R.Right := R.Right - (GetDefaultImageWidth + 2 * GetHideBarHorizInterval)
      else R.Bottom := R.Bottom - (GetDefaultImageHeight + 2 * GetHideBarHorizInterval);
    end;
  end;
  case APosition of
    ahpLeft:
      FillGradientRect(ACanvas.Handle, R, dxOffice11DownedSelectedColor, dxOffice11DownedColor, True);
    ahpTop:
      FillGradientRect(ACanvas.Handle, R, dxOffice11DownedSelectedColor, dxOffice11DownedColor, False);
    ahpRight:
      FillGradientRect(ACanvas.Handle, R, dxOffice11DownedColor, dxOffice11DownedSelectedColor, True);
    ahpBottom:
      FillGradientRect(ACanvas.Handle, R, dxOffice11DownedColor, dxOffice11DownedSelectedColor, False);
  end;
  DrawColorEdge(ACanvas, ARect, dxOffice11SelectedBorderColor, etStandard, Edges[APosition]);
  DrawHideBarButtonContent(ACanvas, AControl, ARect, APosition);
end;

end.
