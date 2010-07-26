
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars common                                          }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
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

unit dxBarCommon;

{$I cxVer.inc}

interface                     

uses
  Windows, dxCommon, dxBar;

procedure dxBarPopupNCCalcSize(AHandle: HWND; var ARect: TRect;
  var Corner: TdxCorner; Combo: TdxBarItem; AllowResizing: Boolean); // obsolete
procedure dxBarPopupNCPaint(AHandle: HWND; AAllowResizing, AFlat,
  AMouseAboveCloseButton, ACloseButtonIsTracking: Boolean;
  var ACloseButtonRect, AGripRect: TRect; ACorner: TdxCorner);

implementation

uses
  Classes, cxGeometry, cxGraphics, cxControls, Math, Graphics, Types;

// TODO: !!! use PainterClass
// dxDropDownNCHeight ?

procedure DrawCloseButton(ACanvas: TcxCanvas; var ARect: TRect; ASelected, APressed, AFlat: Boolean;
  ACorner: TdxCorner);
const
  AOffset = 2;
  States: array[Boolean] of Longint = (0, DFCS_PUSHED);
var
  AButtonSize: Integer;

  procedure CalcBounds;
  begin
    AButtonSize := Min(GetSystemMetrics(SM_CXSIZE), cxRectHeight(ARect) - AOffset * 2);
    if not Odd(AButtonSize) then
      Dec(AButtonSize);

    if ACorner in [coTopLeft, coBottomLeft] then
      ARect.Left := ARect.Right - AButtonSize - AOffset * 2
    else
      ARect.Right := ARect.Left + AButtonSize + AOffset * 2;

    ARect := cxRectCenter(ARect, AButtonSize, AButtonSize);
    if ACorner in [coBottomLeft, coBottomRight] then
      OffsetRect(ARect, 0, 1);
  end;

begin
  CalcBounds;

  DrawFrameControl(ACanvas.Handle, ARect, DFC_CAPTION,
    DFCS_CAPTIONCLOSE or DFCS_FLAT or States[APressed and not AFlat]);

  if ASelected and not AFlat then
    ACanvas.DrawEdge(ARect, APressed, APressed)
  else
    ACanvas.FrameRect(ARect, clBtnFace);
  InflateRect(ARect, -1, -1);

  ACanvas.FrameRect(ARect, clBtnFace);
  InflateRect(ARect, 1, 1);
end;

{
TODO:?
function dxBarDropDownNCHeight: Integer;
begin
  Result := dxDropDownNCHeight;
end;}

procedure dxBarPopupNCCalcSize(AHandle: HWND; var ARect: TRect;
  var Corner: TdxCorner; Combo: TdxBarItem; AllowResizing: Boolean); // obsolete
var
  R: TRect;
  AControl: TdxBarWinControl;
begin
  InflateRect(ARect, -1, -1);
  if AllowResizing and
    (Combo.CurItemLink <> nil) and (Combo.CurItemLink.Control <> nil) then
  begin
    R := cxGetWindowRect(AHandle);
    AControl := TdxBarWinControl(Combo.CurItemLink.Control);
    MapWindowPoints(0, AControl.Parent.Handle, R, 2);
    Corner := GetCornerForRects(AControl.WindowRect, R);
    with ARect do
      if Corner in [coBottomLeft, coBottomRight] then
        Dec(Bottom, dxDropDownNCHeight)
      else
        Inc(Top, dxDropDownNCHeight);
  end;
end;

procedure dxBarPopupNCPaint(AHandle: HWND; AAllowResizing, AFlat,
  AMouseAboveCloseButton, ACloseButtonIsTracking: Boolean;
  var ACloseButtonRect, AGripRect: TRect; ACorner: TdxCorner);

var
  AWindowRect, AWindowBounds, ABandBounds: TRect;
  ABorderSize: Integer;
  ADC: HDC;

  procedure CalculateBounds;
  var
    AClientRect, AClientBounds: TRect;
  begin
    AWindowRect := cxGetWindowRect(AHandle);
    AClientRect := cxGetClientRect(AHandle);

    AWindowBounds := AWindowRect;
    OffsetRect(AWindowBounds, -AWindowRect.Left, -AWindowRect.Top);

    AClientBounds := AClientRect;
    MapWindowPoints(AHandle, 0, AClientBounds, 2);
    OffsetRect(AClientBounds, -AWindowRect.Left, -AWindowRect.Top);

    ABorderSize := AClientBounds.Left;

    ABandBounds := cxRectInflate(AWindowBounds, -ABorderSize, -ABorderSize);
    if ACorner in [coBottomLeft, coBottomRight] then
      ABandBounds.Top := AClientBounds.Bottom
    else
      ABandBounds.Bottom := AClientBounds.Top;
  end;

  function BorderColor: TColor;
  begin
    if AFlat then
      Result := clBtnShadow
    else
      Result := clWindowFrame;
  end;

  procedure DrawFrame;
  begin
    BarCanvas.FrameRect(AWindowBounds, BorderColor, ABorderSize);
  end;

  procedure DrawBand;
  begin
    if AAllowResizing then
    begin
      BarCanvas.SetClipRegion(TcxRegion.Create(ABandBounds), roSet);
      if ACorner in [coBottomLeft, coBottomRight] then
        BarCanvas.FrameRect(ABandBounds, BorderColor, ABorderSize, [bTop], True)
      else
        BarCanvas.FrameRect(ABandBounds, BorderColor, ABorderSize, [bBottom], True);

      AGripRect := ABandBounds;
      DrawSizeGrip(ADC, AGripRect, ACorner);
      BarCanvas.ExcludeClipRect(AGripRect);
      OffsetRect(AGripRect, AWindowRect.Left, AWindowRect.Top);

      ACloseButtonRect := ABandBounds;
      DrawCloseButton(BarCanvas, ACloseButtonRect, AMouseAboveCloseButton or ACloseButtonIsTracking,
        AMouseAboveCloseButton and ACloseButtonIsTracking, AFlat, ACorner);
      BarCanvas.ExcludeClipRect(ACloseButtonRect);
      OffsetRect(ACloseButtonRect, AWindowRect.Left, AWindowRect.Top);

      BarCanvas.FillRect(ABandBounds, clBtnFace);
    end
    else
    begin
      SetRectEmpty(ACloseButtonRect);
      SetRectEmpty(AGripRect);
    end;
  end;

begin
  ADC := GetWindowDC(AHandle);
  BarCanvas.BeginPaint(ADC);
  try
    CalculateBounds;
    DrawFrame;
    DrawBand;
  finally
    BarCanvas.EndPaint;
    ReleaseDC(AHandle, ADC);
  end;
end;

end.
