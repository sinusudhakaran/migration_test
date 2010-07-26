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

unit dxSkinscxPCPainter;

{$I cxVer.inc}

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics,
  dxCore, cxGraphics, cxGeometry, cxControls, cxLookAndFeels, dxSkinsCore,
  cxLookAndFeelPainters, cxPCPainters, cxPC, dxSkinsLookAndFeelPainter,
  cxPCPaintersFactory;

const
  cxNullPCDistance: TcxPCDistance = (dw: 0; dh: 0);

type
  { TcxPCSkinPainter }

  TcxPCSkinIndents = (siFar, siNear, siSelectedDownGrow, siHorzGrow, siVertGrow,
    siDownGrow);

  TcxPCSkinPainter = class(TcxPCTabsPainter)
  private
    FFrameContentCache: TdxSkinElementCache;
    FWasDoubleBuffered: Boolean;
    function GetButtonHorz: TdxSkinElement;
    function GetButtonVert: TdxSkinElement;
    function GetFrameContent: TdxSkinElement;
    function GetHeader: TdxSkinElement;
    function GetIndentByIndex(AType: TcxPCSkinIndents): Integer;
    function GetNeedDrawTabBitmapBackground: Boolean;
    function GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
    function GetTabState(ATab: TcxTab): TdxSkinElementState;
    procedure InternalCorrectCustomTabRect(APosition: TcxTabPosition; var ARect: TRect);
    procedure InternalCorrectMainTabRect(APosition: TcxTabPosition; var ARect: TRect);
  protected
    function CalculateTabNormalWidth(Tab: TcxTab): Integer; override;
    procedure CorrectTabRect(TabVisibleIndex: Integer;
      var TabRectCorrection: TcxPCRectCorrection); override;
    procedure DrawNativeTabBackground(DC: HDC; ATab: TcxTabSheet); override;
    function GetClientRectOffset: TRect; override;
    function GetButtonWidth(Button: TcxPCNavigatorButton): Integer; override;
    function GetFreeSpaceColor: TColor; override;
    function GetNativeContentOffset: TRect; override;
    function GetTabClipRgn(ATabVisibleIndex: Integer): TcxRegion; override;
    function GetTabFocusRect(const ATabBounds: TRect): TRect; override;
    function GetTabsNormalDistance: TcxPCDistance; override;
    function GetTabsPosition(NavigatorButtons: TcxPCNavigatorButtons): TcxPCTabsPosition; override;
    function GetTextColor(ATabVisibleIndex: Integer): TColor; override;
    procedure InternalDrawText(ACanvas: TCanvas; const ACaption: string;
      ARect: TRect; ATabVisibleIndex: Integer); override;
    procedure InternalPaintFrame(ACanvas: TCanvas); override;
    function IsEnableHotTrack: Boolean; override;
    function IsNativePainting: Boolean; override;
    function IsSkinAvailable: Boolean;
    function NeedDisabledTextShadow: Boolean; override;

    procedure PaintButton(Button: TcxPCNavigatorButton; const ButtonRect: TRect); override;
    procedure PaintNativeTabBackground(DC: HDC; ATabVisibleIndex: Integer; const ABounds: TRect); override;
    procedure PaintTabsRegion; override;
    procedure PrepareTabBitmapBackground(ABitmap: TBitmap; const ARect: TRect; ATab: TcxTab); override;

    property ButtonHorz: TdxSkinElement read GetButtonHorz;
    property ButtonVert: TdxSkinElement read GetButtonVert;
    property FrameContent: TdxSkinElement read GetFrameContent;
    property FrameContentCache: TdxSkinElementCache read FFrameContentCache;
    property Header: TdxSkinElement read GetHeader;
    property Indents[AType: TcxPCSkinIndents]: Integer read GetIndentByIndex;
    property NeedDrawTabBitmapBackground: Boolean read GetNeedDrawTabBitmapBackground;
  public
    constructor Create(AParent: TcxCustomTabControl); override;
    destructor Destroy; override;
    function CalculateTabNormalHeight: Integer; override;
    class function GetStyleID: TcxPCStyleID; override;
    class function GetStyleName: TCaption; override;
    class function HasLookAndFeel(ALookAndFeel: TcxLookAndFeel): Boolean; override;
  end;

implementation

{$IFDEF DELPHI6}

uses
  Types, Math, dxSkinInfo;

{$ENDIF}

const
  TabPosition2cxBorder: array[TcxTabPosition] of TcxBorder = (
    bTop, bBottom, bLeft, bRight);

{ TcxPCSkinPainter }

constructor TcxPCSkinPainter.Create(AParent: TcxCustomTabControl);
begin
  inherited Create(AParent);
  FFrameContentCache := TdxSkinElementCache.Create;
  FWasDoubleBuffered := AParent.DoubleBuffered;
  AParent.DoubleBuffered := not IsWinVista;
end;

destructor TcxPCSkinPainter.Destroy;
begin
  ParentControl.DoubleBuffered := FWasDoubleBuffered;
  FFrameContentCache.Free;
  inherited Destroy;
end;

function TcxPCSkinPainter.CalculateTabNormalHeight: Integer;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
  APageControlHeader: TdxSkinElement;
begin
  APageControlHeader := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    APageControlHeader := ASkinPainterInfo.PageControlHeader;
  if APageControlHeader = nil then
    Result := inherited CalculateTabNormalHeight
  else
    with APageControlHeader.ContentOffset do
      Result := Top + Bottom + inherited CalculateTabNormalHeight - 2;
end;

class function TcxPCSkinPainter.GetStyleID: TcxPCStyleID;
begin
  Result := cxPCSkinStyle;
end;

class function TcxPCSkinPainter.GetStyleName: TCaption;
begin
  Result := 'Skin';
end;

class function TcxPCSkinPainter.HasLookAndFeel(ALookAndFeel: TcxLookAndFeel): Boolean;
begin
  Result := ALookAndFeel.SkinPainter <> nil;
end;

function TcxPCSkinPainter.CalculateTabNormalWidth(Tab: TcxTab): Integer;
var
  AIndex: Integer;
begin
  if Header = nil then
    Result := inherited CalculateTabNormalWidth(Tab)
  else
    with Header do
    begin
      Result := ContentOffset.Left + ContentOffset.Right;
      with ParentInfo do
        if TabWidth > 0 then
          Inc(Result, TabWidth)
        else
        begin
          AIndex := Tab.VisibleIndex;
          if IsAssignedImages and ((AIndex = -1) or IsTabHasImage(AIndex) or ParentInfo.Rotate) then
            Inc(Result, GetTabBaseImageSize.cx + 2 * ParentInfo.ImageBorder +
              GetImageTextDistance(AIndex));
          Inc(Result, TextSize(Tab, Tab.Caption).cx + 2);
        end;
    end;
end;

procedure TcxPCSkinPainter.InternalCorrectCustomTabRect(APosition: TcxTabPosition;
  var ARect: TRect);
begin
  case APosition of
    tpTop:
      ARect.Bottom := Indents[siDownGrow] + 1;
    tpBottom:
      ARect.Top := -Indents[siDownGrow] + 1;
    tpLeft:
      ARect.Right := Indents[siDownGrow] + 1;
    tpRight:
      ARect.Left := -Indents[siDownGrow] + 1;
  end;
end;

procedure TcxPCSkinPainter.InternalCorrectMainTabRect(APosition: TcxTabPosition;
  var ARect: TRect);
begin
  case APosition of
    tpTop:
      ARect := Rect(-Indents[siHorzGrow], -Indents[siVertGrow], Indents[siHorzGrow],
        Indents[siSelectedDownGrow]);
    tpBottom:
      ARect := Rect(-Indents[siHorzGrow], -Indents[siSelectedDownGrow],
        Indents[siHorzGrow], Indents[siVertGrow]);
    tpLeft:
      ARect := Rect(-Indents[siVertGrow], -Indents[siHorzGrow], Indents[siSelectedDownGrow],
        Indents[siHorzGrow]);
    tpRight:
      ARect := Rect(-Indents[siSelectedDownGrow], -Indents[siHorzGrow],
        Indents[siVertGrow], Indents[siHorzGrow]);
  end;
end;

procedure TcxPCSkinPainter.CorrectTabRect(TabVisibleIndex: Integer;
  var TabRectCorrection: TcxPCRectCorrection);
var
  ATab: TcxTab;
  ARect: TRect;
begin
  if IsSkinAvailable then
  begin
    ARect := cxNullRect;
    ATab := ParentInfo.VisibleTabs[TabVisibleIndex];
    if ATab.IsMainTab then
      InternalCorrectMainTabRect(ATab.PaintingPosition, ARect)
    else
      InternalCorrectCustomTabRect(ATab.PaintingPosition, ARect);
    TabRectCorrection := TcxPCRectCorrection(ARect);
  end
  else
    inherited CorrectTabRect(TabVisibleIndex, TabRectCorrection);
end;

procedure TcxPCSkinPainter.DrawNativeTabBackground(DC: HDC; ATab: TcxTabSheet);
var
  AFrameContent: TdxSkinElement;
  R: TRect;
begin
  AFrameContent := FrameContent;
  if AFrameContent = nil then
    inherited DrawNativeTabBackground(DC, ATab)
  else
  begin
    R := GetDisplayRect;
    OffsetRect(R, -ATab.Left, -ATab.Top);
    AFrameContent.Draw(DC, R);
  end;
end;

function TcxPCSkinPainter.GetClientRectOffset: TRect;
begin
  Result := inherited GetDisplayRectOffset;
  if FrameContent <> nil then
    with RotateRectBack(GetNativeContentOffset, ParentInfo.TabPosition) do
    begin
      Inc(Result.Left, Left);
      Inc(Result.Top, Top);
      Inc(Result.Right, Right);
      Inc(Result.Bottom, Bottom);
    end;
end;

function TcxPCSkinPainter.GetButtonWidth(Button: TcxPCNavigatorButton): Integer;
begin
  Result := 0;
  if ButtonHorz <> nil then
    Result := ButtonHorz.Image.Size.cx;
  if Result = 0 then
    Result := inherited GetButtonWidth(Button);
end;

function TcxPCSkinPainter.GetFreeSpaceColor: TColor;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinPainterData(ASkinInfo) and (ASkinInfo.ContentColor <> nil)  then
    Result := ASkinInfo.ContentColor.Value
  else
    Result := inherited GetFreeSpaceColor;  
end;

function TcxPCSkinPainter.GetNativeContentOffset: TRect;
begin
  Result := cxNullRect;
  // todo: need correct skin info
  if FrameContent <> nil then
    with FrameContent.Image.Margins{ContentOffset}.Rect do
      Result := Rect(Left + 1, Top + 1, Right + 1, Bottom + 1);
end;

function TcxPCSkinPainter.GetTabClipRgn(ATabVisibleIndex: Integer): TcxRegion;
begin
  Result := TcxRegion.Create(ParentInfo.VisibleTabs[ATabVisibleIndex].FullRect);
  if ParentInfo.NavigatorButtons <> [] then
    Result.Combine(TcxRegion.Create(ButtonsRect), roSubtract);
end;

function TcxPCSkinPainter.GetTabFocusRect(const ATabBounds: TRect): TRect;
begin
  if Header = nil then
    Result := inherited GetTabFocusRect(ATabBounds)
  else
  begin
    Result := cxRectContent(ATabBounds, Header.ContentOffset.Rect);
    Dec(Result.Bottom, Indents[siSelectedDownGrow]);
    InflateRect(Result, 1, 1);
  end;
end;

function TcxPCSkinPainter.GetTabsNormalDistance: TcxPCDistance;
begin
  Result := cxNullPCDistance;
  if not ParentInfo.Rotate then
    Result.dh := Indents[siVertGrow]
  else
    Result.dw := Indents[siVertGrow];
end;

function TcxPCSkinPainter.GetTabsPosition(
  NavigatorButtons: TcxPCNavigatorButtons): TcxPCTabsPosition;
var
  AddX: Integer;
  NormalTabsRectCorrection: TRect;

  procedure DoHardCalculation;
  var
    AButtonsWidth: Integer;
    ATabsContainerOffset: TRect;
  begin
    AButtonsWidth := CalculateButtonsRegionWidth(NavigatorButtons);
    if AButtonsWidth <> 0 then
      Inc(AButtonsWidth);
    ATabsContainerOffset := cxEmptyRect;
    if ParentInfo.IsTabsContainer then
      ATabsContainerOffset := GetTabsContainerOffsets;

    NormalTabsRectCorrection := RotateRect(Rect(0, Indents[siVertGrow] + ATabsContainerOffset.Top, 0, 0), ParentInfo.TabPosition);
    ExtendRect(Result.ExtendedTabsRect, RotateRect(Rect(0, ATabsContainerOffset.Top, 0, 0), ParentInfo.TabPosition));
    with ParentInfo do
    begin
      if TabPosition in [tpTop, tpBottom] then
      begin
        if MultiLine or (NavigatorButtons = []) then
        begin
          Result.ExtendedTabsRect.Left := ATabsContainerOffset.Left + Indents[siNear];
          Result.ExtendedTabsRect.Right := Width - ATabsContainerOffset.Left - Indents[siFar];
        end
        else
        begin
          if NavigatorPosition in [npLeftTop, npLeftBottom] then
          begin
            Result.ExtendedTabsRect.Left := AButtonsWidth;
            Result.ExtendedTabsRect.Right := Width - ATabsContainerOffset.Left - Indents[siFar];
          end
          else
          begin
            Result.ExtendedTabsRect.Left := ATabsContainerOffset.Left + Indents[siNear];
            Result.ExtendedTabsRect.Right := Width - AButtonsWidth;
          end;
        end;
        Result.NormalTabsRect.Left := Result.ExtendedTabsRect.Left + AddX;
        Result.NormalTabsRect.Right := Result.ExtendedTabsRect.Right - AddX;
        Result.NormalRowWidth := Result.NormalTabsRect.Right - Result.NormalTabsRect.Left;
      end
      else
      begin
        if MultiLine or (NavigatorButtons = []) then
        begin
          Result.ExtendedTabsRect.Top := ATabsContainerOffset.Left + Indents[siNear];
          Result.ExtendedTabsRect.Bottom := Height - ATabsContainerOffset.Left - Indents[siFar];
        end
        else
        begin
          if NavigatorPosition in [npLeftTop, npRightTop] then
          begin
            Result.ExtendedTabsRect.Top := AButtonsWidth;
            Result.ExtendedTabsRect.Bottom := Height - ATabsContainerOffset.Left - Indents[siFar];
          end
          else
          begin
            Result.ExtendedTabsRect.Top := ATabsContainerOffset.Left + Indents[siNear];
            Result.ExtendedTabsRect.Bottom := Height - AButtonsWidth;
          end;
        end;
        Result.NormalTabsRect.Top := Result.ExtendedTabsRect.Top + AddX;
        Result.NormalTabsRect.Bottom := Result.ExtendedTabsRect.Bottom - AddX;
        Result.NormalRowWidth := Result.NormalTabsRect.Bottom - Result.NormalTabsRect.Top;
      end;
    end;
  end;

begin
  if IsSkinAvailable then
  begin
    AddX := Indents[siHorzGrow];
    with Result do
    begin
      ExtendedTabsRect := Rect(0, 0, ParentControl.Width, ParentControl.Height);
      NormalTabsRect := ExtendedTabsRect;
      DoHardCalculation;
      cxGraphics.ExtendRect(NormalTabsRect, NormalTabsRectCorrection);
      ExtendedTopOrLeftTabsRectBottomOrRightBorderOffset := 0;
      ExtendedBottomOrRightTabsRectTopOrLeftBorderOffset := 0;
      if ParentInfo.TabPosition in [tpTop, tpLeft] then
        ExtendedTopOrLeftTabsRectBottomOrRightBorderOffset := 1
      else
        ExtendedBottomOrRightTabsRectTopOrLeftBorderOffset := -1;
      MinDistanceBetweenTopOrLeftAndBottomOrRightExtendedTabsRects := 0;
    end;
    CalculateButtonsRegion(NavigatorButtons);
  end
  else
    Result := inherited GetTabsPosition(NavigatorButtons);
end;

function TcxPCSkinPainter.GetTextColor(ATabVisibleIndex: Integer): TColor;
var
  ASkinColor: TdxSkinColor;
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
  ATab: TcxTab;
begin
  ATab := ParentInfo.VisibleTabs[ATabVisibleIndex];
  ASkinColor := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
  begin
    if not ATab.Enabled then
      ASkinColor := ASkinPainterInfo.TabTextColorDisabled
    else
      if ATab.IsMainTab then
        ASkinColor := ASkinPainterInfo.TabTextColorActive
      else
        if ATab.HotTrack then
          ASkinColor := ASkinPainterInfo.TabTextColorHot
        else
          ASkinColor := ASkinPainterInfo.TabTextColor;
  end;
  if ASkinColor = nil then
    Result := inherited GetTextColor(ATabVisibleIndex)
  else
    Result := ASkinColor.Value;
end;

procedure TcxPCSkinPainter.InternalDrawText(ACanvas: TCanvas; const ACaption: string;
  ARect: TRect; ATabVisibleIndex: Integer);
begin
  ACanvas.Font.Color := GetTextColor(ATabVisibleIndex);
  cxDrawText(ACanvas.Handle, ACaption, ARect, DT_SINGLELINE or DT_END_ELLIPSIS);
end;

procedure TcxPCSkinPainter.InternalPaintFrame(ACanvas: TCanvas);
var
  AFrameContent: TdxSkinElement;
  ARect, R: TRect;
begin
  ARect := GetDisplayRect;
  if IsRectEmpty(ARect) then Exit;
  R := GetNativeContentOffset;
  if ARect.Right - ARect.Left < R.Left + R.Right then
    ARect.Right := ARect.Left + R.Left + R.Right;
  if ARect.Bottom - ARect.Top < R.Top + R.Bottom then
    ARect.Bottom := ARect.Top + R.Top + R.Bottom;
  cxDrawThemeParentBackground(ParentControl, ACanvas, ParentControl.ClientRect);
  AFrameContent := FrameContent;
  if AFrameContent = nil then
    inherited InternalPaintFrame(ACanvas)
  else
  begin
    if ParentInfo.IsTabsContainer then
      with GetNativeContentOffset do
      begin
        if ParentInfo.TabPosition in [tpTop, tpBottom] then
          InflateRect(ARect, Max(Left, Right), 0)
        else
          InflateRect(ARect, 0, Max(Top, Bottom));
      end;
    if AFrameContent.Image.GradientBeginColor = clNone then
      FrameContentCache.DrawEx(ACanvas.Handle, AFrameContent, ARect)
    else
      AFrameContent.Draw(ACanvas.Handle, ARect);
    if ACanvas.Handle = ParentInfo.Canvas.Handle then
      Windows.ExcludeClipRect(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right,
        ARect.Bottom);
  end;
end;

function TcxPCSkinPainter.IsEnableHotTrack: Boolean;
begin
  Result := True;
end;

function TcxPCSkinPainter.IsNativePainting: Boolean;
begin
  if IsSkinAvailable then
    Result := True
  else
    Result := inherited IsNativePainting;   
end;

function TcxPCSkinPainter.IsSkinAvailable: Boolean;
begin
  Result := ParentControl.LookAndFeel.SkinPainter <> nil;
end;

function TcxPCSkinPainter.NeedDisabledTextShadow: Boolean;
begin
  Result := False;
end;

procedure TcxPCSkinPainter.PaintButton(Button: TcxPCNavigatorButton;
  const ButtonRect: TRect);
const
  AButtonKindVert: array[TcxPCNavigatorButton] of Integer = (2, 1, 3, 0);
  AButtonKindHorz: array[TcxPCNavigatorButton] of Integer = (1, 2, 3, 0);
  AButtonStates: array[TcxPCNavigatorButtonState] of TdxSkinElementState = (
    esNormal, esPressed, esHot, esDisabled);
begin
  if (ButtonHorz <> nil) and (ButtonVert <> nil) then
  with ParentInfo do
  begin
    cxDrawThemeParentBackground(ParentControl, ParentInfo.Canvas, ButtonRect);
    if ParentInfo.TabPosition in [tpTop, tpBottom] then
      ButtonHorz.Draw(Canvas.Handle, ButtonRect,
        AButtonKindHorz[Button], AButtonStates[NavigatorButtonsState[Button]])
    else
      ButtonVert.Draw(Canvas.Handle, ButtonRect, AButtonKindVert[Button],
        AButtonStates[NavigatorButtonsState[Button]])
  end
  else
    inherited PaintButton(Button, ButtonRect)
end;

procedure TcxPCSkinPainter.PaintNativeTabBackground(DC: HDC;
  ATabVisibleIndex: Integer; const ABounds: TRect);
begin
  if Header = nil then
    inherited PaintNativeTabBackground(DC, ATabVisibleIndex, ABounds)
  else
    Header.Draw(DC, ABounds, 0, GetTabState(ParentInfo.VisibleTabs[ATabVisibleIndex]));
end;

procedure TcxPCSkinPainter.PaintTabsRegion;
var
  I: Integer;
  FirstIndex, LastIndex: Integer;
  MainTabVisibleIndex: Integer;
begin
  if IsSkinAvailable then
  begin
    MainTabVisibleIndex := ParentInfo.MainTabVisibleIndex;
    InitializeVisibleTabRange(ParentControl, FirstIndex, LastIndex);
    for I := FirstIndex to LastIndex do
      if I <> MainTabVisibleIndex then
        PaintTab(I);
    if MainTabVisibleIndex <> -1 then
      if ParentInfo.VisibleTabs[MainTabVisibleIndex].RealVisible then
        PaintTab(MainTabVisibleIndex);
  end
  else
    inherited PaintTabsRegion;
end;

procedure TcxPCSkinPainter.PrepareTabBitmapBackground(ABitmap: TBitmap; 
  const ARect: TRect; ATab: TcxTab);
const
  HorzRotationAngle: array[Boolean] of TcxRotationAngle = (raPlus90, raMinus90);
var
  R: TRect;
begin
  inherited PrepareTabBitmapBackground(ABitmap, ARect, ATab);
  if (FrameContent <> nil) and NeedDrawTabBitmapBackground then
  begin
    R := GetDisplayRect;
    OffsetRect(R, -ATab.FullRect.Left, -ATab.FullRect.Top);
    if ATab.IsMainTab then
    begin
      case ATab.PaintingPosition of
        tpBottom:
          OffsetRect(R, 0, 1);
        tpRight:
          OffsetRect(R, 1, 0);
      end;
    end;
    case ATab.PaintingPosition of
      tpLeft, tpRight:
        ParentControl.Canvas.RotateBitmap(ABitmap,
          HorzRotationAngle[ATab.PaintingPosition = tpRight]);
      tpBottom:
        ParentControl.Canvas.RotateBitmap(ABitmap, ra180);
    end;
    FrameContent.Draw(ABitmap.Canvas.Handle, R);
    case ATab.PaintingPosition of
      tpLeft, tpRight:
        ParentControl.Canvas.RotateBitmap(ABitmap,
          HorzRotationAngle[ATab.PaintingPosition <> tpRight]);
      tpBottom:
        ParentControl.Canvas.RotateBitmap(ABitmap, ra180);
    end;
  end;
end;

function TcxPCSkinPainter.GetButtonHorz: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PageControlButtonHorz;
end;

function TcxPCSkinPainter.GetButtonVert: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PageControlButtonVert;
end;

function TcxPCSkinPainter.GetFrameContent: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if ParentInfo.HideTabs then
    begin
      if ParentInfo.ShowFrame then
        Result := ASkinPainterInfo.GroupBoxElements[cxgpCenter]
      else
        Result := ASkinPainterInfo.FormContent;
    end
    else
      Result := ASkinPainterInfo.PageControlPane;
end;

function TcxPCSkinPainter.GetHeader: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PageControlHeader;
end;

function TcxPCSkinPainter.GetIndentByIndex(AType: TcxPCSkinIndents): Integer;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := 0;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PageControlIndents[Integer(AType)];
end;

function TcxPCSkinPainter.GetNeedDrawTabBitmapBackground: Boolean;
begin
  Result := {(Indents[siDownGrow] > 1) and} (Header <> nil) and Header.IsAlphaUsed;
end;

function TcxPCSkinPainter.GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(
    ParentControl.LookAndFeel.SkinPainter, AData);
end;

function TcxPCSkinPainter.GetTabState(ATab: TcxTab): TdxSkinElementState;
begin
  if not ATab.Enabled then
    Result := esDisabled
  else
    if ATab.IsMainTab then
      Result := esPressed
    else
      if ATab.HotTrack or ATab.Highlighted then
        Result := esHot
      else
        Result := esNormal;
end;

initialization
  RegisterPCPainterClass(TcxPCSkinPainter);

finalization
  UnregisterPCPainterClass(TcxPCSkinPainter);

end.
