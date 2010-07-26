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

unit dxSkinsdxDockControlPainter;

{$I cxVer.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, cxGraphics, dxDockControl,
  dxDockControlXPView, dxSkinsCore, dxSkinsLookAndFeelPainter, cxLookAndFeels,
  cxLookAndFeelPainters, Math, cxGeometry, dxDockControlOfficeView, dxSkinInfo,
  Types;

type

  { TdxDockControlSkinPainter }

  TdxDockControlSkinPainter = class(TdxDockControlXPPainter)
  private
    FButtonsCache: TdxSkinElementCache;
    FHideBarElementCache: array[TdxAutoHidePosition] of TdxSkinElementCache;
    FPanelsBackgroundCache: TdxSkinElementCacheList;
    procedure DrawClippedElement(ACanvas: TCanvas; const ARect, AClipRect: TRect;
      AElement: TdxSkinElement; AState: TdxSkinElementState = esNormal;
      AOperation: TcxRegionOperation = roSet);
  protected
    function DrawCaptionFirst: Boolean; override;
    function GetCaptionFontColor(IsActive: Boolean): TColor; override;
    function GetCaptionRect(const ARect: TRect; AIsVertical: Boolean): TRect; override;
    function GetElementState(IsActive, IsDown, IsHot, IsEnabled: Boolean): TdxSkinElementState;
    function GetHideBarButtonFontColor: TColor; override;
    function GetHideBarButtonFontColorEx(AActive: Boolean): TColor;
    function GetSkinLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
    function GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
    function GetTabFontColor(IsActive: Boolean): TColor; override;
    function InternalDrawCaptionButton(ACanvas: TCanvas; AGlyphIndex: Integer;
      ARect: TRect; AState: TdxSkinElementState): Boolean;
    function InternalDrawTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable, IsNextButton: Boolean): Boolean;
    procedure InternalDrawTabsLine(ACanvas: TCanvas; const ARect: TRect;
      ALine: TdxSkinElement; APosition: TdxTabContainerTabsPosition); 
    function IsWorkingControl(AControl: TdxCustomDockControl): Boolean;
  public
    constructor Create(ADockControl: TdxCustomDockControl); override;
    destructor Destroy; override;
    // Custom
    function CanVerticalCaption: Boolean; override;
    procedure DrawBorder(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect; IsActive,
      IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;IsActive,
      IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect; IsActive,
      IsDown, IsHot, IsSwitched: Boolean); override;
    procedure DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect); override;
    procedure DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); override;
    procedure DrawClient(ACanvas: TCanvas; ARect: TRect); override;
    function GetBorderWidths: TRect; override;
    function GetCaptionButtonSize: Integer; override;
    function GetCaptionHeight: Integer; override;
    function GetCaptionHorizInterval: Integer; override;
    // TabContainer
    procedure CorrectTabRect(var ATab: TRect; APosition: TdxTabContainerTabsPosition;
      AIsActive: Boolean); override;
    function DrawActiveTabLast: Boolean; override;
    procedure DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabContent(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
      APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsNextTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    procedure DrawTabsPrevTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); override;
    function GetTabHorizInterval: Integer; override;
    function GetTabHorizOffset: Integer; override;
    function GetTabsHeight: Integer; override;
    function GetTabVertInterval: Integer; override;
    function GetTabVertOffset: Integer; override;
    // AutoHideContainer
    procedure DrawHideBar(ACanvas: TCanvas; ARect: TRect; APosition: TdxAutoHidePosition); override;
    procedure DrawHideBarButton(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); override;
    procedure DrawHideBarButtonText(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); override;
    function IsHideBarButtonHotTrackSupports: Boolean; override;
  end;

implementation

{ TdxDockControlSkinPainter }

constructor TdxDockControlSkinPainter.Create(ADockControl: TdxCustomDockControl);
var
  ASide: TdxAutoHidePosition;
begin
  inherited Create(ADockControl);
  FPanelsBackgroundCache := TdxSkinElementCacheList.Create;
  FButtonsCache := TdxSkinElementCache.Create;
  for ASide := Low(TdxAutoHidePosition) to High(TdxAutoHidePosition) do
    FHideBarElementCache[ASide] := TdxSkinElementCache.Create;
end;

destructor TdxDockControlSkinPainter.Destroy;
var
  ASide: TdxAutoHidePosition;
begin
  FreeAndNil(FButtonsCache);
  FreeAndNil(FPanelsBackgroundCache);
  for ASide := Low(TdxAutoHidePosition) to High(TdxAutoHidePosition) do
    FHideBarElementCache[ASide].Free;
  inherited Destroy;
end;

function TdxDockControlSkinPainter.CanVerticalCaption: Boolean;
begin
  Result := False;
end;

procedure TdxDockControlSkinPainter.CorrectTabRect(var ATab: TRect;
  APosition: TdxTabContainerTabsPosition; AIsActive: Boolean);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not GetSkinPainterData(ASkinInfo) then
    inherited CorrectTabRect(ATab, APosition, AIsActive)
  else
  begin
    if AIsActive then
    begin
      InflateRect(ATab, ASkinInfo.DockControlIndents[1], 0);
      if APosition = tctpTop then
        Dec(ATab.Top, ASkinInfo.DockControlIndents[2])
      else
        Inc(ATab.Bottom, ASkinInfo.DockControlIndents[2]);
    end;
    if APosition = tctpTop then
      Inc(ATab.Bottom, ASkinInfo.DockControlIndents[0] - 1)
    else
      Dec(ATab.Top, ASkinInfo.DockControlIndents[0] + 1);
  end;
end;

procedure TdxDockControlSkinPainter.DrawBorder(ACanvas: TCanvas; ARect: TRect);
var
  ABorder: TdxSkinElement;
  ACaption: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  ABorder := nil;
  ACaption := nil;
  if GetSkinPainterData(ASkinInfo) then
  begin
    ABorder := ASkinInfo.DockControlBorder;
    ACaption := ASkinInfo.DockControlCaption;
  end;

  if (ABorder = nil) or (ACaption = nil) then
    inherited DrawBorder(ACanvas, ARect)
  else
  begin
    FPanelsBackgroundCache.DrawElement(ACanvas.Handle, ABorder, ARect);
    DrawClippedElement(ACanvas, cxRectSetHeight(ARect, ACaption.Size.cy),
      cxRectSetHeight(ARect, GetBorderWidths.Top), ACaption);
  end;
end;

procedure TdxDockControlSkinPainter.DrawCaption(ACanvas: TCanvas; ARect: TRect;
  IsActive: Boolean);
const
  AStates: array[Boolean] of TdxSkinElementState = (esNormal, esActive);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R: TRect;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlCaption;
  if AElement = nil then
    inherited DrawCaption(ACanvas, ARect, IsActive)
  else
  begin
    R := ARect;
    Dec(R.Top, GetBorderWidths.Top);
    DrawClippedElement(ACanvas, R, ARect, AElement, AStates[IsActive]);
  end;  
end;

procedure TdxDockControlSkinPainter.DrawCaptionCloseButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  if not InternalDrawCaptionButton(ACanvas, 2, ARect,
    GetElementState(IsActive, IsDown, IsHot, True))
  then
    inherited DrawCaptionCloseButton(ACanvas, ARect, IsActive, IsDown, IsHot,
      IsSwitched);
end;

procedure TdxDockControlSkinPainter.DrawCaptionHideButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
const
  AGlyphMap: array[Boolean] of Integer = (3, 4);
begin
  if not InternalDrawCaptionButton(ACanvas, AGlyphMap[IsSwitched], ARect,
    GetElementState(IsActive, IsDown, IsHot, True))
  then
    inherited DrawCaptionHideButton(ACanvas, ARect, IsActive, IsDown, IsHot,
      IsSwitched);
end;

procedure TdxDockControlSkinPainter.DrawCaptionMaximizeButton(ACanvas: TCanvas;
  ARect: TRect; IsActive, IsDown, IsHot, IsSwitched: Boolean);
const
  AGlyphs: array[Boolean] of Integer = (1, 0);  
begin
  if not InternalDrawCaptionButton(ACanvas, AGlyphs[IsSwitched], ARect,
    GetElementState(IsActive, IsDown, IsHot, True))
  then
    inherited DrawCaptionMaximizeButton(ACanvas, ARect, IsActive, IsDown, IsHot,
      IsSwitched);
end;

procedure TdxDockControlSkinPainter.DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not GetSkinPainterData(ASkinInfo) then
    inherited DrawCaptionSeparator(ACanvas, ARect);
end;

procedure TdxDockControlSkinPainter.DrawCaptionText(ACanvas: TCanvas; ARect: TRect;
  IsActive: Boolean);
var
  R: TRect;  
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
end;

procedure TdxDockControlSkinPainter.DrawClient(ACanvas: TCanvas; ARect: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.GroupBoxClient
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawClient(ACanvas, ARect)
  else
    AElement.Draw(ACanvas.Handle, ARect);
end;

function TdxDockControlSkinPainter.GetBorderWidths: TRect;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlBorder
  else
    AElement := nil;
    
  if AElement = nil then
    Result := inherited GetBorderWidths
  else
    Result := AElement.ContentOffset.Rect;
end;

function TdxDockControlSkinPainter.GetCaptionButtonSize: Integer;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlWindowButton;
  if AElement = nil then
    Result := inherited GetCaptionButtonSize
  else
    Result := AElement.Size.cy;
end;

function TdxDockControlSkinPainter.GetCaptionHeight: Integer;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlCaption
  else
    AElement := nil;       
  if (AElement = nil) or AElement.Image.Empty then
    Result := inherited GetCaptionButtonSize
  else
    with GetBorderWidths do
      Result := AElement.Size.cy - (Top + Bottom);
end;

function TdxDockControlSkinPainter.GetCaptionHorizInterval: Integer;
begin
  Result := 2;
end;

procedure TdxDockControlSkinPainter.DrawHideBar(ACanvas: TCanvas; ARect: TRect;
  APosition: TdxAutoHidePosition);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    case APosition of
      ahpTop, ahpUndefined:
        AElement := ASkinInfo.DockControlHideBar;
      ahpLeft:
        AElement := ASkinInfo.DockControlHideBarLeft;
      ahpRight:
        AElement := ASkinInfo.DockControlHideBarRight;
      ahpBottom:
        AElement := ASkinInfo.DockControlHideBarBottom;
    end;

  if AElement = nil then
    inherited DrawHideBar(ACanvas, ARect, APosition)
  else
  begin
    FHideBarElementCache[APosition].CheckCacheState(AElement, ARect);
    FHideBarElementCache[APosition].Draw(ACanvas.Handle, ARect);
  end;
end;

procedure TdxDockControlSkinPainter.DrawHideBarButton(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);

  procedure RotateBitmap(ABitmap: TcxBitmap; AReverse: Boolean);
  const
    RotationHorMap: array[Boolean] of TcxRotationAngle = (raPlus90, raMinus90);
  begin
    case APosition of
      ahpLeft:
        ABitmap.Rotate(RotationHorMap[not AReverse]);
      ahpRight:
        ABitmap.Rotate(RotationHorMap[AReverse]);
      ahpTop:
        ABitmap.Rotate(ra0, True);
    end;
  end;

  function CreateHideBarButtonBuffer(R: TRect): TcxBitmap;
  var
    ATemp: Integer;
  begin
    OffsetRect(R, -R.Left, -R.Top);
    if APosition in [ahpLeft, ahpRight] then
    begin
      ATemp := R.Right;
      R.Right := R.Left + (R.Bottom - R.Top);
      R.Bottom := R.Top + (ATemp - R.Left);
    end;
    Result := TcxBitmap.CreateSize(R, pf32bit);
  end;

var
  ABitmap: TcxBitmap;
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlHideBarButtons;
  if AElement = nil then
    inherited DrawHideBarButton(ACanvas, AControl, ARect, APosition)
  else
  begin
    ABitmap := CreateHideBarButtonBuffer(ARect);
    try
      RotateBitmap(ABitmap, False);
      cxBitBlt(ABitmap.Canvas.Handle, ACanvas.Handle, ABitmap.ClientRect,
        ARect.TopLeft, SRCCOPY);
      RotateBitmap(ABitmap, True);
      AElement.Draw(ABitmap.Canvas.Handle, ABitmap.ClientRect,
        Integer(IsWorkingControl(AControl)));
      RotateBitmap(ABitmap, False);
      cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, ARect, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;   
    DrawHideBarButtonContent(ACanvas, AControl, ARect, APosition);
  end;
end;

procedure TdxDockControlSkinPainter.DrawHideBarButtonText(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);

  procedure DrawButtonText(ACanvas: TCanvas; R: TRect; AControl: TdxCustomDockControl);
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font := GetHideBarButtonFont;
    ACanvas.Font.Color := GetHideBarButtonFontColorEx(IsWorkingControl(AControl));
    cxDrawText(ACanvas.Handle, AControl.Caption, R,
      DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
  end;

var
  ABitmap: TcxBitmap;
begin
  InflateRect(ARect, -4, -4);
  case APosition of
    ahpTop, ahpBottom:
      DrawButtonText(ACanvas, ARect, AControl);

    ahpRight, ahpLeft:
      begin
        ABitmap := TcxBitmap.CreateSize(ARect, pf32bit);
        try
          cxBitBlt(ABitmap.Canvas.Handle, ACanvas.Handle,
            ABitmap.ClientRect, ARect.TopLeft, SRCCOPY);
          ABitmap.Rotate(raPlus90);
          DrawButtonText(ABitmap.Canvas, ABitmap.ClientRect, AControl);
          ABitmap.Rotate(raMinus90);
          ACanvas.Draw(ARect.Left, ARect.Top, ABitmap);
        finally
          ABitmap.Free;
        end;
      end;
  end;
end;

function TdxDockControlSkinPainter.IsHideBarButtonHotTrackSupports: Boolean;
begin
  Result := True;
end;

function TdxDockControlSkinPainter.DrawActiveTabLast: Boolean;
begin
  Result := True;
end;

procedure TdxDockControlSkinPainter.DrawTab(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; IsActive: Boolean;
  APosition: TdxTabContainerTabsPosition);
const
  AStates: array[Boolean] of TdxSkinElementState = (esNormal, esPressed);
var
  ABitmap: TcxBitmap;
  ABitmapCanvas: TcxCanvas;
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlTabHeader;

  if AElement = nil then
    inherited DrawTab(ACanvas, AControl, ARect, IsActive, APosition)
  else
  begin
    ABitmap := TcxBitmap.CreateSize(ARect, pf32bit);
    try
      cxBitBlt(ABitmap.Canvas.Handle, ACanvas.Handle, ABitmap.ClientRect,
        ARect.TopLeft, SRCCOPY);
      ABitmapCanvas := TcxCanvas.Create(ACanvas);
      try
        if APosition = tctpBottom then
          ABitmapCanvas.RotateBitmap(ABitmap, ra0, True);
        AElement.Draw(ABitmap.Canvas.Handle,
          Rect(0, 0, ABitmap.Width, ABitmap.Height), 0, AStates[IsActive]);
        if APosition = tctpBottom then
          ABitmapCanvas.RotateBitmap(ABitmap, ra0, True);
      finally
        ABitmapCanvas.Free;
      end;
      cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, ARect, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;
    ARect := cxRectContent(ARect, AElement.ContentOffset.Rect);
    if APosition = tctpBottom then
      Inc(ARect.Top, ASkinInfo.DockControlIndents[0]);
    DrawTabContent(ACanvas, AControl, ARect, IsActive, APosition);
  end;
end;

procedure TdxDockControlSkinPainter.DrawTabContent(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; IsActive: Boolean;
  APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
begin
  if IsValidImageIndex(AControl.ImageIndex) then
  begin
    R.Left := ARect.Left;
    R.Top := ARect.Top + (ARect.Bottom - ARect.Top - GetImageHeight) div 2;
    R.Right := R.Left + GetImageWidth;
    R.Bottom := R.Top + GetImageHeight;
    if RectInRect(R, ARect) then
    begin
      DrawImage(ACanvas, AControl.Images, AControl.ImageIndex, R);
      ARect.Left := R.Right + GetTabHorizInterval;
    end;
  end;

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := GetTabFont(IsActive);
  ACanvas.Font.Color := ColorToRGB(GetTabFontColor(IsActive));
  cxDrawText(ACanvas.Handle, AControl.Caption, ARect,
    DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_END_ELLIPSIS);
end;

procedure TdxDockControlSkinPainter.DrawTabs(ACanvas: TCanvas;
  ARect, AActiveTabRect: TRect; APosition: TdxTabContainerTabsPosition);

  function CalcLineRect(const ATabsRect: TRect; ALine: TdxSkinElement): TRect;
  begin
    Result := ATabsRect;
    if APosition = tctpBottom then
    begin
      Result.Bottom := Result.Top + 1;
      Dec(Result.Top, Max(0, ALine.Size.cy - 1));
    end
    else
    begin
      Result.Top := Result.Bottom - 1;
      Inc(Result.Bottom, Max(0, ALine.Size.cy - 1));
    end;
  end;

var
  AElement: TdxSkinElement;
  ALine: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not IsRectEmpty(ARect) then
  begin
    AElement := nil;
    ALine := nil;
    if GetSkinPainterData(ASkinInfo) then
    begin
      AElement := ASkinInfo.DockControlTabHeaderBackground;
      ALine := ASkinInfo.DockControlTabHeaderLine;
    end;
    if AElement = nil then
      inherited DrawTabs(ACanvas, ARect, AActiveTabRect, APosition)
    else
    begin
      AElement.Draw(ACanvas.Handle, ARect);
      ARect := CalcLineRect(ARect, ALine);
      InternalDrawTabsLine(ACanvas, ARect, ALine, APosition);
      with AActiveTabRect do
      begin
        ExcludeClipRect(ACanvas.Handle, ARect.Left, ARect.Top, Left, ARect.Bottom);
        ExcludeClipRect(ACanvas.Handle, Right, ARect.Top, ARect.Right, ARect.Bottom);
      end;
    end;
  end;
end;

procedure TdxDockControlSkinPainter.InternalDrawTabsLine(ACanvas: TCanvas;
  const ARect: TRect; ALine: TdxSkinElement; APosition: TdxTabContainerTabsPosition);
var
  ABitmap: TcxBitmap;
begin
  if APosition = tctpTop then
    ALine.Draw(ACanvas.Handle, ARect)
  else
  begin
    ABitmap := TcxBitmap.CreateSize(ARect, pf32bit);
    try
      ALine.Draw(ABitmap.Canvas.Handle, ABitmap.ClientRect);
      ABitmap.Rotate(ra0, True);
      cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, ARect, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;
  end;
end;

function TdxDockControlSkinPainter.IsWorkingControl(
  AControl: TdxCustomDockControl): Boolean;
begin
  Result := AControl = AControl.AutoHideHostSite.WorkingControl;
end;

procedure TdxDockControlSkinPainter.DrawTabsNextTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean;
  APosition: TdxTabContainerTabsPosition);
begin
  if not InternalDrawTabButton(ACanvas, ARect, IsDown, IsHot, IsEnable, True) then
    inherited DrawTabsNextTabButton(ACanvas, ARect, IsDown, IsHot, IsEnable,
      APosition);
end;

procedure TdxDockControlSkinPainter.DrawTabsPrevTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
begin
  if not InternalDrawTabButton(ACanvas, ARect, IsDown, IsHot, IsEnable, False) then
    inherited DrawTabsNextTabButton(ACanvas, ARect, IsDown, IsHot, IsEnable,
      APosition);
end;

function TdxDockControlSkinPainter.GetCaptionFontColor(IsActive: Boolean): TColor;
var
  AColor: TColor;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AColor := clDefault;
  if GetSkinPainterData(ASkinInfo) then
  begin
    if not IsActive then
      AColor := ASkinInfo.DockControlCaptionNonFocusedTextColor
    else
      if ASkinInfo.DockControlCaption <> nil then
        AColor := ASkinInfo.DockControlCaption.TextColor;
  end;
        
  if AColor = clDefault then
    Result := inherited GetCaptionFontColor(IsActive)
  else
    Result := AColor;
end;

function TdxDockControlSkinPainter.GetCaptionRect(const ARect: TRect;
  AIsVertical: Boolean): TRect;
var
  ABorders: TRect;
  ACaptionButtonSize: Integer;
  ACaptionHeight: Integer;
begin
  ABorders := GetBorderWidths;
  Result := inherited GetCaptionRect(ARect, AIsVertical);
  Dec(Result.Left, ABorders.Left);
  Inc(Result.Right, ABorders.Right);
  ACaptionButtonSize := GetCaptionButtonSize;
  ACaptionHeight := Max(GetCaptionHeight, ACaptionButtonSize + 4);
  Result.Bottom := Result.Top + ACaptionHeight +
    Integer(Odd(ACaptionHeight + ACaptionButtonSize));
end;

function TdxDockControlSkinPainter.GetElementState(
  IsActive, IsDown, IsHot, IsEnabled: Boolean): TdxSkinElementState;
begin
  if not IsEnabled then
    Result := esDisabled
  else
    if IsDown then
      Result := esPressed
    else
      if IsHot then
        Result := esHot
      else
        if IsActive then
          Result := esActive
        else
          Result := esNormal;
end;

function TdxDockControlSkinPainter.GetHideBarButtonFontColor: TColor;
begin
  Result := GetHideBarButtonFontColorEx(False);
end;

function TdxDockControlSkinPainter.GetHideBarButtonFontColorEx(AActive: Boolean): TColor;
var
  AColor: TdxSkinColor;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    AColor := ASkinInfo.DockControlHideBarTextColor[AActive]
  else
    AColor := nil;
    
  if AColor = nil then
    Result := inherited GetHideBarButtonFontColor
  else
    Result := AColor.Value;
end;

function TdxDockControlSkinPainter.GetTabFontColor(IsActive: Boolean): TColor;
var
  AColor: TdxSkinColor;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    AColor := ASkinInfo.DockControlTabTextColor[IsActive]
  else
    AColor := nil;

  if AColor = nil then
    Result := inherited GetTabFontColor(IsActive)
  else
    Result := AColor.Value;
end;

function TdxDockControlSkinPainter.GetTabHorizInterval: Integer;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlTabHeader;
  if (AElement = nil) then
    Result := inherited GetTabHorizInterval
  else
    Result := AElement.ContentOffset.Left;
end;

function TdxDockControlSkinPainter.GetTabHorizOffset: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited GetTabHorizOffset;
  if GetSkinPainterData(ASkinInfo) then
    Inc(Result, ASkinInfo.DockControlIndents[1]);
end;

function TdxDockControlSkinPainter.GetTabsHeight: Integer;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElement := ASkinInfo.DockControlTabHeader;
  if (AElement = nil) then
    Result := inherited GetTabsHeight
  else
    with AElement.ContentOffset do
      Result := Top + Bottom + Max(GetImageHeight + 4, GetFont.Size + 10);
end;

function TdxDockControlSkinPainter.GetTabVertInterval: Integer;
begin
  Result := 0;
end;

function TdxDockControlSkinPainter.GetTabVertOffset: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) then
    Result := ASkinInfo.DockControlIndents[2]
  else
    Result := inherited GetTabVertOffset;
end;

function TdxDockControlSkinPainter.GetSkinLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
var
  I: Integer;
begin
  Result := nil;
  with DockControl.Controller do
    for I := 0 to DockManagerCount - 1 do
    begin
      Result := DockManagers[I].LookAndFeel.SkinPainter;
      if Result <> nil then Break;
    end;
end;

function TdxDockControlSkinPainter.GetSkinPainterData(
  var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(GetSkinLookAndFeelPainter,
    AData);
end;

function TdxDockControlSkinPainter.DrawCaptionFirst: Boolean;
begin
  Result := True;
end;

procedure TdxDockControlSkinPainter.DrawClippedElement(ACanvas: TCanvas;
  const ARect, AClipRect: TRect; AElement: TdxSkinElement;
  AState: TdxSkinElementState = esNormal;
  AOperation: TcxRegionOperation = roSet);
var
  ATempCanvas: TcxCanvas;
begin
  ATempCanvas := TcxCanvas.Create(ACanvas);
  try
    ATempCanvas.SaveClipRegion;
    try
      ATempCanvas.SetClipRegion(TcxRegion.Create(AClipRect), AOperation);
      AElement.Draw(ACanvas.Handle, ARect, 0, AState);
    finally
      ATempCanvas.RestoreClipRegion;
    end;                               
  finally
    ATempCanvas.Free;
  end;
end;

function TdxDockControlSkinPainter.InternalDrawCaptionButton(ACanvas: TCanvas;
  AGlyphIndex: Integer; ARect: TRect; AState: TdxSkinElementState): Boolean;
var
  AElement: TdxSkinElement;
  AGlyph: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  AGlyph := nil;
  if GetSkinPainterData(ASkinInfo) then
  begin
    AElement := ASkinInfo.DockControlWindowButton;
    AGlyph := ASkinInfo.DockControlWindowButtonGlyphs;
  end;                             
  Result := (AElement <> nil) and (AGlyph <> nil);
  if Result then
  begin
    FButtonsCache.CheckCacheState(AElement, ARect, AState);
    FButtonsCache.Draw(ACanvas.Handle, ARect);
    AGlyph.Draw(ACanvas.Handle, cxRectContent(ARect, AElement.ContentOffset.Rect),
      AGlyphIndex, AState);
  end;
end;

function TdxDockControlSkinPainter.InternalDrawTabButton(ACanvas: TCanvas;
  ARect: TRect; IsDown, IsHot, IsEnable, IsNextButton: Boolean): Boolean;
const
  AScrollPart: array[Boolean] of TcxScrollBarPart = (sbpLineUp, sbpLineDown);
var
  AElementInfo: TdxSkinScrollInfo;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElementInfo := nil;
  if GetSkinPainterData(ASkinInfo) then
    AElementInfo := ASkinInfo.ScrollBar_Elements[True, AScrollPart[IsNextButton]];
  Result := (AElementInfo <> nil) and (AElementInfo.Element <> nil);
  if Result then
  begin
    with AElementInfo do
      Element.Draw(ACanvas.Handle, ARect, ImageIndex,
        GetElementState(False, IsDown, IsHot, IsEnable));
  end;
end;

initialization
  CustomSkinPainterClass := TdxDockControlSkinPainter;

finalization
  CustomSkinPainterClass := nil;

end.
