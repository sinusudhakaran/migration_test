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

unit dxSkinsdxStatusBarPainter;

interface

uses
  Windows, SysUtils, Classes, dxSkinsCore, cxLookAndFeels, dxSkinsLookAndFeelPainter, dxStatusBar,
  cxGraphics, Graphics, cxLookAndFeelPainters;

type

  { TdxStatusBarSkinPainter }

  TdxStatusBarSkinPainter = class(TdxStatusBarStandardPainter)
  protected
    class function CheckStatusBarRect(AFormStatusBar: TdxSkinElement; const R: TRect): TRect;
    class procedure DrawContainerControl(APanelStyle: TdxStatusBarContainerPanelStyle); override;
    class function GetSkinInfo(AStatusBar: TdxCustomStatusBar;
      out ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
    class function IsSkinAvailable(AStatusBar: TdxCustomStatusBar): Boolean;
    class function IsSizeGripInPanel(AStatusBar: TdxCustomStatusBar): Boolean; override;
  public
    class procedure AdjustTextColor(AStatusBar: TdxCustomStatusBar; var AColor: TColor;
      Active: Boolean); override;
    class function DrawSizeGripFirst: Boolean; override;
    class function SeparatorSize: Integer; override;
    class procedure DrawBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      var R: TRect); override;
    class procedure DrawClippedElement(AElement: TdxSkinElement; ACanvas: TcxCanvas;
      const ARect, AClipRegion: TRect; ARegionOperation: TcxRegionOperation = roSet);
    class procedure DrawEmptyPanel(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect); override;
    class procedure DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
      ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect); override;
    class procedure DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
      ACanvas: TcxCanvas; const R: TRect); override;
    class procedure DrawSizeGrip(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect; AOverlapped: Boolean); override;
    class procedure FillBackground(AStatusBar: TdxCustomStatusBar;
      APanel: TdxStatusBarPanel; ACanvas: TcxCanvas; const R: TRect); override;
  end;

implementation

uses
  Types, cxGeometry;

type
  TdxCustomStatusBarAccess = class(TdxCustomStatusBar);

{ TdxStatusBarSkinPainter }

class procedure TdxStatusBarSkinPainter.AdjustTextColor(AStatusBar: TdxCustomStatusBar;
  var AColor: TColor; Active: Boolean);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  inherited AdjustTextColor(AStatusBar, AColor, Active);
  if AColor = clWindowText then
    if GetSkinInfo(AStatusBar, ASkinInfo) then
    begin
      if Active then
      begin
        if ASkinInfo.FormStatusBar <> nil then
          AColor := ASkinInfo.FormStatusBar.TextColor;
      end
      else
        if ASkinInfo.BarDisabledTextColor <> nil then
          AColor := ASkinInfo.BarDisabledTextColor.Value;
    end;
end;

class function TdxStatusBarSkinPainter.CheckStatusBarRect(AFormStatusBar: TdxSkinElement;
  const R: TRect): TRect;
begin
  Result := R;
  if Assigned(AFormStatusBar) then
    with AFormStatusBar.ContentOffset do
    begin
      Dec(Result.Left, Left);
      Inc(Result.Right, Right);
      Inc(Result.Bottom, Bottom);
    end;
end;

class procedure TdxStatusBarSkinPainter.DrawContainerControl(APanelStyle: TdxStatusBarContainerPanelStyle);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R, AParentRect: TRect;
  ACanvas: TcxCanvas;
  AControl: TdxStatusBarContainerControl;
  AStatusBar: TdxCustomStatusBar;
begin
  AParentRect := APanelStyle.StatusBarControl.ClientBounds;
  AControl := APanelStyle.Container;
  AStatusBar := APanelStyle.StatusBarControl;
  ACanvas := AControl.Canvas;
  OffsetRect(AParentRect, -AControl.Left, -AControl.Top);
  R := AControl.ClientRect;

  if GetSkinInfo(AStatusBar, ASkinInfo) and (ASkinInfo.FormStatusBar <> nil) then
  begin
    DrawClippedElement(ASkinInfo.FormStatusBar, ACanvas,
      CheckStatusBarRect(ASkinInfo.FormStatusBar, AParentRect), R,
      roIntersect);
  end
  else
    inherited;
end;

class function TdxStatusBarSkinPainter.DrawSizeGripFirst: Boolean;
begin
  Result := False;
end;

class function TdxStatusBarSkinPainter.SeparatorSize: Integer;
begin
  Result := 1;
end;

class procedure TdxStatusBarSkinPainter.DrawBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
  var R: TRect);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  ABorderWidth: Integer;
  AStatusBarRect: TRect;
begin
  if GetSkinInfo(AStatusBar, ASkinInfo) and (ASkinInfo.FormStatusBar <> nil) then
  begin
    AStatusBarRect := AStatusBar.Bounds;
    DrawClippedElement(ASkinInfo.FormStatusBar, ACanvas,
      CheckStatusBarRect(ASkinInfo.FormStatusBar, AStatusBarRect), R,
      roIntersect);
    R := cxRectInflate(R, -1, -ASkinInfo.FormStatusBar.ContentOffset.Top, -1, -1);
    ABorderWidth := TdxCustomStatusBarAccess(AStatusBar).BorderWidth;
    R := cxRectInflate(R, -ABorderWidth, -ABorderWidth);
  end
  else
    inherited;
end;

class procedure TdxStatusBarSkinPainter.DrawClippedElement(AElement: TdxSkinElement;
  ACanvas: TcxCanvas; const ARect: TRect; const AClipRegion: TRect;
  ARegionOperation: TcxRegionOperation = roSet);
begin
  ACanvas.SaveClipRegion;
  try
    ACanvas.SetClipRegion(TcxRegion.Create(AClipRegion), ARegionOperation);
    AElement.Draw(ACanvas.Handle, ARect);
  finally
    ACanvas.RestoreClipRegion;
  end;
end;

class procedure TdxStatusBarSkinPainter.DrawEmptyPanel(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not GetSkinInfo(AStatusBar, ASkinInfo) or (ASkinInfo.FormStatusBar = nil) then
    inherited DrawEmptyPanel(AStatusBar, ACanvas, R)
  else
    DrawClippedElement(ASkinInfo.FormStatusBar, ACanvas,
      CheckStatusBarRect(ASkinInfo.FormStatusBar, AStatusBar.Bounds), R);
end;

class procedure TdxStatusBarSkinPainter.DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
  ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if (ABevel <> dxpbNone) and GetSkinInfo(AStatusBar, ASkinInfo) and
    (ASkinInfo.LinkBorderPainter <> nil) then
  begin
    ASkinInfo.LinkBorderPainter.Draw(ACanvas.Handle, R);
    R := cxRectContent(R, ASkinInfo.LinkBorderPainter.ContentOffset.Rect);
  end
  else
    inherited;
end;

class procedure TdxStatusBarSkinPainter.DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
begin
  if not IsSkinAvailable(AStatusBar) then
    inherited DrawPanelSeparator(AStatusBar, ACanvas, R);
end;

class procedure TdxStatusBarSkinPainter.DrawSizeGrip(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect; AOverlapped: Boolean);
var
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinInfo(AStatusBar, ASkinInfo) and (ASkinInfo.FormStatusBar <> nil) and
    (ASkinInfo.SizeGrip <> nil) then
  begin
    ARect := cxRectContent(R, ASkinInfo.FormStatusBar.ContentOffset.Rect);
    ARect.Left := ARect.Right - ASkinInfo.SizeGrip.Size.cx;
    ARect.Top := ARect.Bottom - ASkinInfo.SizeGrip.Size.cy;
    ASkinInfo.SizeGrip.Draw(ACanvas.Handle, ARect);
  end
  else
    inherited DrawSizeGrip(AStatusBar, ACanvas, R, AOverlapped);
end;

class procedure TdxStatusBarSkinPainter.FillBackground(
  AStatusBar: TdxCustomStatusBar; APanel: TdxStatusBarPanel; ACanvas: TcxCanvas;
  const R: TRect);
begin
  if not IsSkinAvailable(AStatusBar) then
    inherited;
end;

class function TdxStatusBarSkinPainter.GetSkinInfo(AStatusBar: TdxCustomStatusBar;
  out ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  with TdxCustomStatusBarAccess(AStatusBar) do
    Result := GetExtendedStylePainters.GetPainterData(LookAndFeel.SkinPainter,
      ASkinInfo);
end;

class function TdxStatusBarSkinPainter.IsSkinAvailable(
  AStatusBar: TdxCustomStatusBar): Boolean;
begin
  with TdxCustomStatusBarAccess(AStatusBar) do
    Result := LookAndFeel.SkinPainter <> nil;
end;

class function TdxStatusBarSkinPainter.IsSizeGripInPanel(AStatusBar: TdxCustomStatusBar): Boolean;
begin
  Result := not IsSkinAvailable(AStatusBar);
end;

initialization
  dxStatusBarSkinPainterClass := TdxStatusBarSkinPainter;

finalization
  dxStatusBarSkinPainterClass := nil;

end.
