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

unit dxDockControlXPView;

{$I cxVer.inc}

interface

uses
  Menus, Windows, Graphics, Classes, Controls, ExtCtrls, Messages, Forms,
  dxDockControl;

type
  TdxDockControlXPPainter = class(TdxDockControlPainter)
  protected
    function NeedRedrawOnResize: Boolean; override;
  public
    // CustomDockControl
    function CanVerticalCaption: Boolean; override;
    function GetCaptionButtonSize: Integer; override;
    function GetCaptionHeight: Integer; override;

    procedure DrawBorder(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawClient(ACanvas: TCanvas; ARect: TRect); override;
    // TabContainer
    procedure DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
      APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsNextTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsPrevTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    // AutoHideContainer
    procedure DrawHideBar(ACanvas: TCanvas; ARect: TRect; APosition: TdxAutoHidePosition); override;
    procedure DrawHideBarButton(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); override;
  end;

implementation

uses
  dxUxTheme, dxThemeManager, dxThemeConsts, dxDockConsts, cxGraphics, cxGeometry;

function TdxDockControlXPPainter.CanVerticalCaption: Boolean;
begin
  if OpenTheme(totTab) <> 0 then Result := False
  else Result := inherited CanVerticalCaption;
end;

function TdxDockControlXPPainter.GetCaptionButtonSize: Integer;
begin
  if OpenTheme(totTab) <> 0 then Result := 14
  else Result := inherited GetCaptionButtonSize;
end;

function TdxDockControlXPPainter.GetCaptionHeight: Integer;
begin
  if OpenTheme(totTab) <> 0 then
  begin
    Result := 7 + GetFont.Size + 7;
    if Result < 2 + GetImageHeight + 2 then
      Result := 2 + GetImageHeight + 2;
  end
  else Result := inherited GetCaptionHeight;
end;

procedure TdxDockControlXPPainter.DrawBorder(ACanvas: TCanvas;
  ARect: TRect);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totToolBar);
  if ATheme <> 0 then
  begin
    if IsThemeBackgroundPartiallyTransparent(ATheme, TP_BUTTON, TS_HOT) then
      cxDrawTransparentControlBackground(DockControl, ACanvas, ARect);
    DrawThemeBackground(ATheme, ACanvas.Handle, TP_BUTTON, TS_HOT, ARect);
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean);
var
  ATheme: TdxTheme;
  AClipRgn: HRGN;
  AClipRgnExists: Boolean;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
  begin
    if IsActive then
    begin
      AClipRgn := CreateRectRgn(0, 0, 0, 0);
      try
        AClipRgnExists := GetClipRgn(ACanvas.Handle, AClipRgn) = 1;
        with ARect do
        begin
          ExcludeClipRect(ACanvas.Handle, Left, Top, Left + 2, Top + 2);
          ExcludeClipRect(ACanvas.Handle, Right - 2, Top, Right, Top + 2);
          ExcludeClipRect(ACanvas.Handle, Right - 2, Bottom - 2, Right, Bottom);
          ExcludeClipRect(ACanvas.Handle, Left, Bottom - 2, Left + 2, Bottom);
        end;
        DrawThemeBackground(OpenTheme(totExplorerBar), ACanvas.Handle, EBP_NORMALGROUPBACKGROUND, 0, ARect);
        if AClipRgnExists then
          SelectClipRgn(ACanvas.Handle, AClipRgn)
        else
          SelectClipRgn(ACanvas.Handle, 0);
      finally
        DeleteObject(AClipRgn);
      end;
    end
    else
      DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, ARect);
    DrawThemeBackground(OpenTheme(totButton), ACanvas.Handle, BP_GROUPBOX, 0, ARect);
  end
  else
    inherited;
end;

procedure TdxDockControlXPPainter.DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
    DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, ARect)
  else
    inherited;
end;

procedure TdxDockControlXPPainter.DrawCaptionCloseButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
var
  ATheme: TdxTheme;
  AState: Integer;
begin
  ATheme := OpenTheme(totWindow);
  if ATheme <> 0 then
  begin
    if IsDown and IsHot then
      AState := CBS_PUSHED
    else if IsHot then
      AState := CBS_HOT
    else AState := CBS_NORMAL;
    DrawThemeBackground(ATheme, ACanvas.Handle, WP_SMALLCLOSEBUTTON, AState, ARect)
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawCaptionHideButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
var
  ABitmap, ARotatedBitmap: TcxCustomBitmap;
  ATheme: TdxTheme;
  AState: Integer;
begin
  ATheme := OpenTheme(totExplorerBar);
  if ATheme <> 0 then
  begin
    if IsDown and IsHot then
      AState := EBHP_PRESSED
    else
      if IsHot then
        AState := EBHP_HOT
      else
        AState := EBHP_NORMAL;

    ABitmap := TcxCustomBitmap.CreateSize(16, 16, pf32bit);
    try
      DrawThemeBackground(ATheme, ABitmap.Canvas.Handle, EBP_HEADERPIN, AState, ABitmap.ClientRect);
      if not IsSwitched then
        ABitmap.Rotate(raPlus90);
      ARotatedBitmap := TcxCustomBitmap.CreateSize(cxRectInflate(ARect, -1, -1), pf24bit);
      try
        StretchBlt(ARotatedBitmap.Canvas.Handle, 0, 0, ARotatedBitmap.Width, ARotatedBitmap.Height,
          ABitmap.Canvas.Handle, 0, 0, ABitmap.Width, ABitmap.Height, SRCCOPY);
        ARotatedBitmap.Transparent := True;
        ACanvas.Draw(ARect.Left + 1, ARect.Top + 1, ARotatedBitmap);
      finally
        ARotatedBitmap.Free;
      end;
    finally
      ABitmap.Free;
    end;
  end
  else
    inherited;
end;

procedure TdxDockControlXPPainter.DrawCaptionMaximizeButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
var
  ATheme: TdxTheme;
  APart, AState: Integer;
begin
  ATheme := OpenTheme(totWindow);
  if ATheme <> 0 then
  begin
    if IsSwitched then
    begin
      APart := WP_RESTOREBUTTON;
      if IsDown and IsHot then
        AState := RBS_PUSHED
      else if IsHot then
        AState := RBS_HOT
      else AState := RBS_NORMAL;
    end
    else
    begin
      APart := WP_MAXBUTTON;
      if IsDown and IsHot then
        AState := MAXBS_PUSHED
      else if IsHot then
        AState := MAXBS_HOT
      else AState := MAXBS_NORMAL;
    end;
    DrawThemeBackground(ATheme, ACanvas.Handle, APart, AState, ARect)
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawClient(ACanvas: TCanvas; ARect: TRect);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
      DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, ARect)
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawCaptionText(ACanvas: TCanvas;
  ARect: TRect; IsActive: Boolean);
var
  R: TRect;
begin
  if OpenTheme(totTab) <> 0 then
  begin
    if IsValidImageIndex(DockControl.ImageIndex) then
    begin
      R.Left := ARect.Left + 2 * GetCaptionHorizInterval;
      R.Top := ARect.Top + (ARect.Bottom - ARect.Top - GetImageHeight) div 2;
      R.Right := R.Left + GetImageWidth;
      R.Bottom := R.Top + GetImageHeight;
      if RectInRect(R, ARect) then
      begin
        DrawImage(ACanvas, DockControl.Images, DockControl.ImageIndex, R);
        ARect.Left := R.Right + 2 * GetCaptionHorizInterval;
      end;
    end;

    ACanvas.Brush.Style := bsClear;
    ACanvas.Font := GetFont;
    ACanvas.Font.Color := GetCaptionFontColor(IsActive);
    cxDrawText(ACanvas.Handle, DockControl.Caption, ARect,
      DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawHideBar(ACanvas: TCanvas; ARect: TRect;
  APosition: TdxAutoHidePosition);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
    DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, ARect)
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawHideBarButton(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
var
  R: TRect;
  ABitmap: TcxCustomBitmap;
  ATheme: TdxTheme;
  Temp: Integer;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
  begin
    R := ARect;
    OffsetRect(R, -R.Left, -R.Top);
    if APosition in [ahpLeft, ahpRight] then
    begin
      Temp := R.Right;
      R.Right := R.Left + (R.Bottom - R.Top);
      R.Bottom := R.Top + (Temp - R.Left);
    end;

    ABitmap := TcxCustomBitmap.CreateSize(R, pf32bit);
    try
      DrawThemeBackground(ATheme, ABitmap.Canvas.Handle, TABP_TOPTABITEM, TTIS_NORMAL, R);
      case APosition of
        ahpTop: ABitmap.Rotate(ra180);
        ahpLeft: ABitmap.Rotate(raMinus90);
        ahpRight: ABitmap.Rotate(raPlus90);
      end;
      cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, ARect, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;
    DrawHideBarButtonContent(ACanvas, AControl, ARect, APosition);
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
  ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
  ABitmap: TcxCustomBitmap;
  ATheme: TdxTheme;
  AState: Integer;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
  begin
    if IsActive then
      AState := TTIS_SELECTED
    else
      AState := TTIS_NORMAL;

    R := ARect;
    if not IsActive then
      if APosition = tctpTop then
        Dec(R.Bottom, 2)
      else
        Inc(R.Top, 2);

    ABitmap := TcxCustomBitmap.CreateSize(R, pf32bit);
    try
      DrawThemeBackground(ATheme, ABitmap.Canvas.Handle, TABP_TOPTABITEM, AState, ABitmap.ClientRect);
      if APosition = tctpBottom then
        ABitmap.Rotate(ra180);
      cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, R, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;

    DrawTabContent(ACanvas, AControl, ARect, IsActive, APosition);
  end
  else
    inherited;
end;

procedure TdxDockControlXPPainter.DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
  APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totTab);
  if ATheme <> 0 then
  begin
    DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, ARect);

    R := ARect;
    Inc(R.Right, 2);
    if APosition = tctpTop then
      R.Top := AActiveTabRect.Bottom - 2
    else R.Bottom := AActiveTabRect.Top + 4;
    DrawThemeBackground(ATheme, ACanvas.Handle, TABP_PANE, 0, R);
    if APosition = tctpTop then
      R.Top := AActiveTabRect.Bottom + 1
    else R.Bottom := AActiveTabRect.Top - 1;
    DrawThemeBackground(ATheme, ACanvas.Handle, TABP_BODY, 0, R);
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawTabsNextTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  ATheme: TdxTheme;
  AState: Integer;
begin
  ATheme := OpenTheme(totScrollBar);
  if ATheme <> 0 then
  begin
    if not IsEnable then
      AState := ABS_RIGHTDISABLED
    else if IsDown and IsHot then
      AState := ABS_RIGHTPRESSED
    else if IsHot then
      AState := ABS_RIGHTHOT
    else AState := ABS_RIGHTNORMAL;
    DrawThemeBackground(ATheme, ACanvas.Handle, SBP_ARROWBTN, AState, ARect);
  end
  else inherited;
end;

procedure TdxDockControlXPPainter.DrawTabsPrevTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  ATheme: TdxTheme;
  AState: Integer;
begin
  ATheme := OpenTheme(totScrollBar);
  if ATheme <> 0 then
  begin
    if not IsEnable then
      AState := ABS_LEFTDISABLED
    else if IsDown and IsHot then
      AState := ABS_LEFTPRESSED
    else if IsHot then
      AState := ABS_LEFTHOT
    else AState := ABS_LEFTNORMAL;
    DrawThemeBackground(ATheme, ACanvas.Handle, SBP_ARROWBTN, AState, ARect);
  end
  else inherited;
end;

function TdxDockControlXPPainter.NeedRedrawOnResize: Boolean;
begin
  Result := True;
end;

end.
