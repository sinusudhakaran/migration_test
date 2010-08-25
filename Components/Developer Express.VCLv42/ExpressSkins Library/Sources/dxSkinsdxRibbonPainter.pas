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

unit dxSkinsdxRibbonPainter;

interface

uses
  Windows, Classes, SysUtils, dxSkinsCore, dxSkinsLookAndFeelPainter, Graphics,
  dxRibbonSkins, dxBarSkin, cxLookAndFeels, cxLookAndFeelPainters, cxGraphics,
  cxClasses, dxBarSkinConsts, cxGeometry, dxRibbon, dxBar, Math, cxDWMApi,
  Forms, dxSkinInfo, dxGDIPlusAPI, dxGDIPlusClasses;

const
  QATLeftDefaultOffset = 15;
  QATOffsetDelta = 10;
  QATRightDefaultOffset = 12;

type

  { TdxSkinRibbonPainter }

  TdxSkinRibbonPainter = class(TdxBlackRibbonSkin)
  private
    FLookAndFeel: TcxLookAndFeel;
    function GetBorderBounds(ASide: TcxBorder; const ABorders: TRect;
      const AData: TdxRibbonFormData): TRect;
    function GetBorderSize: Integer;
    function GetBorderSkinElement(ASide: TcxBorder; AIsRectangular: Boolean;
      ASkinInfo: TdxSkinLookAndFeelPainterInfo): TdxSkinElement;
    function GetCustomizeButtonOutsizeQAT(AHasAppButton: Boolean): Boolean;
    function GetQATLeftOffset: Integer;
    function GetSkinData(var ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
    function GetStatusBarElement(AIsLeft, AIsRectangular: Boolean): TdxSkinElement;
    function IsSkinAvailable: Boolean;
    procedure DrawClippedElement(DC: HDC; const R: TRect; const ASource: TRect;
      AElement: TdxSkinElement; AState: TdxSkinElementState = esNormal;
      AIntersect: Boolean = False; AImageIndex: Integer = 0);
    procedure InternalDrawEditButton(DC: HDC; const R: TRect; AState: Integer;
      AButtonKind: TcxEditBtnKind);
    procedure InternalDrawStatusBarBottomPart(DC: HDC; R: TRect; AIsLeft: Boolean;
      AIsActive: Boolean);
    function InternalDrawStatusBarPart(DC: HDC; const R: TRect; AIsRaised: Boolean;
      AIsRectangular: Boolean; AActive: Boolean; AIsLeft: Boolean): Boolean;
    // SkinName
    procedure SetInternalSkinName(const ASkinName: string);
  protected
    function GetName: string; override;
    procedure DrawFormBorder(DC: HDC; ASide: TcxBorder; ACaptionHeight: Integer;
      const AData: TdxRibbonFormData; const ABorders: TRect; AElement: TdxSkinElement);

    property BorderSize: Integer read GetBorderSize;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel;
  public
    constructor Create(const ASkinName: string); virtual;
    destructor Destroy; override;  
    //  Application
    procedure DrawApplicationButton(DC: HDC; const R: TRect;
      AState: TdxApplicationButtonState); override;
    procedure DrawApplicationMenuBorder(DC: HDC; const R: TRect); override;
    procedure DrawApplicationMenuButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawApplicationMenuContentFooter(DC: HDC; const R: TRect); override;
    procedure DrawApplicationMenuContentHeader(DC: HDC; const R: TRect); override;
    // Button Group
    procedure DrawButtonGroup(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawButtonGroupBorderLeft(DC: HDC; const R: TRect); override;
    procedure DrawButtonGroupBorderRight(DC: HDC; const R: TRect); override;
    procedure DrawButtonGroupBorderMiddle(DC: HDC; const R: TRect;
      AState: Integer); override;
    // CollapsedToolbar
    procedure DrawCollapsedToolbarBackground(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawCollapsedToolbarGlyphBackground(DC: HDC; const R: TRect; AState: Integer); override;
    // EditButton
    procedure DrawEditArrowButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawEditEllipsisButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawEditSpinDownButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawEditSpinUpButton(DC: HDC; const R: TRect; AState: Integer); override;
    // Custom controls
    procedure DrawProgressDiscreteBand(DC: HDC; const R: TRect); override;
    procedure DrawProgressSolidBand(DC: HDC; const R: TRect); override;
    procedure DrawProgressSubstrate(DC: HDC; const R: TRect); override;
    // DropDown Gallery
    procedure DrawDropDownBorder(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryBackground(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryBottomSizeGrip(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryBottomSizingBand(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryBottomVerticalSizeGrip(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryTopSizingBand(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryTopSizeGrip(DC: HDC; const R: TRect); override;
    procedure DrawDropDownGalleryTopVerticalSizeGrip(DC: HDC; const R: TRect); override;
    procedure DrawGalleryFilterBandBackground(DC: HDC; const R: TRect); override;
    procedure DrawGalleryGroupHeaderBackground(DC: HDC; const R: TRect); override;
    procedure DrawInRibbonGalleryBackground(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawInRibbonGalleryScrollBarButton(DC: HDC; const R: TRect;
      AButtonKind: TdxInRibbonGalleryScrollBarButtonKind; AState: Integer); override;
    // Form
    procedure DrawFormBorders(DC: HDC; const ABordersWidth: TRect;
      ACaptionHeight: Integer; const AData: TdxRibbonFormData); override;
    procedure DrawFormBorderIcon(DC: HDC; const R: TRect;
      AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState); override;
    procedure DrawFormCaption(DC: HDC; const R: TRect;
      const AData: TdxRibbonFormData); override;
    procedure DrawFormStatusBarPart(DC: HDC; const R: TRect; AIsLeft: Boolean;
      AIsActive: Boolean; AIsRaised: Boolean; AIsRectangular: Boolean); override;
    procedure DrawHelpButton(DC: HDC; const R: TRect; AState: TdxBorderIconState); override;
    // Others
    procedure DrawArrowDown(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawGroupScrollButton(DC: HDC; const R: TRect; ALeft: Boolean; AState: Integer); override;
    procedure DrawMarkArrow(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawMDIButton(DC: HDC; const R: TRect; AButton: TdxBarMDIButton;
      AState: TdxBorderIconState); override;
    procedure DrawMDIButtonGlyph(DC: HDC; const R: TRect;
      AButton: TdxBarMDIButton; AState: TdxBorderIconState); override;
    procedure DrawRibbonBackground(DC: HDC; const R: TRect); override;
    procedure DrawRibbonClientTopArea(DC: HDC; const R: TRect); override;
    procedure DrawScreenTip(DC: HDC; const R: TRect); override;
    // Large buttons
    procedure DrawLargeButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawLargeButtonDropButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawLargeButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer); override;
    // Launch
    procedure DrawLaunchButtonBackground(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawLaunchButtonDefaultGlyph(DC: HDC; const R: TRect; AState: Integer); override;
    // Menus
    procedure DrawMenuCheck(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawMenuCheckMark(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawMenuContent(DC: HDC; const R: TRect); override;
    procedure DrawMenuGlyph(DC: HDC; const R: TRect); override;
    procedure DrawMenuScrollArea(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawMenuSeparatorHorz(DC: HDC; const R: TRect); override;
    procedure DrawMenuSeparatorVert(DC: HDC; const R: TRect); override;
    // Small buttons
    procedure DrawSmallButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawSmallButtonDropButton(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawSmallButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer); override;
    // Status Bar
    procedure DrawStatusBar(DC: HDC; const R: TRect); override;
    procedure DrawStatusBarGripBackground(DC: HDC; const R: TRect); override;
    procedure DrawStatusBarPanel(DC: HDC; const Bounds, R: TRect; AIsLowered: Boolean); override;
    procedure DrawStatusBarPanelSeparator(DC: HDC; const R: TRect); override;
    procedure DrawStatusBarToolbarSeparator(DC: HDC; const R: TRect); override;
    // Tabs
    procedure DrawTab(DC: HDC; const R: TRect; AState: TdxRibbonTabState); override;
    procedure DrawTabGroupBackground(DC: HDC; const R: TRect; AState: Integer); override;
    procedure DrawTabGroupHeaderBackground(DC: HDC; const R: TRect;
      AState: Integer); override;
    procedure DrawTabGroupsArea(DC: HDC; const R: TRect); override;
    procedure DrawTabScrollButton(DC: HDC; const R: TRect; ALeft: Boolean;
      AState: Integer); override;
    procedure DrawTabSeparator(DC: HDC; const R: TRect; Alpha: Byte); override;
    procedure DrawRibbonBottomBorder(DC: HDC; const R: TRect); override;
    // QuickAccess
    procedure DrawQuickAccessToolbar(DC: HDC; const R: TRect;
      ABellow, ANonClientDraw, AHasApplicationButton, AIsActive, ADontUseAero: Boolean); override;
    procedure DrawQuickAccessToolbarDefaultGlyph(DC: HDC; const R: TRect); override;
    procedure DrawQuickAccessToolbarGroupButton(DC: HDC; const R: TRect;
      ABellow: Boolean; ANonClientDraw: Boolean; AIsActive: Boolean;
      AState: Integer); override;
    procedure DrawQuickAccessToolbarPopup(DC: HDC; const R: TRect); override;
    //
    procedure CorrectApplicationMenuButtonGlyphBounds(var R: TRect); override;
    function GetApplicationMenuGlyphSize: TSize; override;
    function GetCaptionFontSize(ACurrentFontSize: Integer): Integer; override;
    function GetMenuSeparatorSize: Integer; override;
    function GetPartColor(APart: Integer; AState: Integer = 0): TColor; override;
    function GetPartContentOffsets(APart: Integer): TRect; override;
    function GetQuickAccessToolbarLeftIndent(AHasApplicationButton: Boolean;
      AUseAeroGlass: Boolean): Integer; override;
    function GetQuickAccessToolbarMarkButtonOffset(AHasApplicationButton: Boolean;
      ABelow: Boolean): Integer; override;
    function GetQuickAccessToolbarOverrideWidth(AHasApplicationButton: Boolean;
      AUseAeroGlass: Boolean): Integer; override;
    function GetQuickAccessToolbarRightIndent(AHasApplicationButton: Boolean): Integer; override;
    function GetSkinName: string; override;
    function GetStatusBarSeparatorSize: Integer; override;
    function GetWindowBordersWidth(AHasStatusBar: Boolean): TRect; override;
    function HasGroupTransparency: Boolean; override;
    function NeedDrawGroupScrollArrow: Boolean; override;

    property SkinName: string read GetSkinName write SetInternalSkinName;
  end;

  { TdxSkinsRibbonCacheManager }

  TdxSkinsRibbonCacheManager = class(TObject)
  private
    FFormBordersCache: array[TcxBorder] of TdxSkinElementCache;
    FFormCaptionCache: TdxSkinElementCache;
    FSmallButtonsCache: TdxSkinElementCache;
    FTabGroupBackground: TdxSkinElementCacheList;
    FTabGroupsAreaCache: TdxSkinElementCache;
    function GetFormBordersCache(ASide: TcxBorder): TdxSkinElementCache;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    // Properties
    property FormBordersCache[ASide: TcxBorder]: TdxSkinElementCache read GetFormBordersCache;
    property FormCaptionCache: TdxSkinElementCache read FFormCaptionCache;
    property SmallButtonsCache: TdxSkinElementCache read FSmallButtonsCache;
    property TabGroupBackground: TdxSkinElementCacheList read FTabGroupBackground;
    property TabGroupsAreaCache: TdxSkinElementCache read FTabGroupsAreaCache;
  end;

  { TdxSkinsRibbonPainterManager }

  TdxSkinsRibbonPainterManager = class(TcxIUnknownObject, IcxLookAndFeelPainterListener)
  protected
    procedure FreePaintersList;
    procedure InitializePaintersList;
    procedure PainterChanged(APainter: TcxCustomLookAndFeelPainterClass);
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

implementation

const
  RibbonFormBorderStates: array[Boolean] of TdxSkinElementState = (
    esActiveDisabled, esActive);

var
  SkinsRibbonCacheManager: TdxSkinsRibbonCacheManager;
  SkinsRibbonPainterManager: TdxSkinsRibbonPainterManager;

function SkinElementStateByRibbonState(AState: Integer): TdxSkinElementState;
const
  StateMap: array[0..8] of TdxSkinElementState = (
    esNormal, esDisabled, esHot, esActive, esPressed, esChecked,
    esChecked, esHotCheck, esActiveDisabled);
begin
  if (Low(StateMap) <= AState) and (High(StateMap) >= AState) then
    Result := StateMap[AState]
  else
    Result := esNormal;
end;

function SkinElementCheckState(AElement: TdxSkinElement;
  AState: TdxSkinElementState): TdxSkinElementState;
begin
  Result := AState;
  if not (AState in AElement.Image.States) then
    case AState of
      esActive, esHotCheck:
        Result := esHot;
      esChecked, esCheckPressed:
        Result := esPressed;
      esActiveDisabled:
        Result := esDisabled;
    end;
end;

{ TdxSkinRibbonPainter }

constructor TdxSkinRibbonPainter.Create(const ASkinName: string);
begin
  FLookAndFeel := TcxLookAndFeel.Create(nil);
  FLookAndFeel.NativeStyle := False;
  FLookAndFeel.SkinName := ASkinName;
  inherited Create;
end;

destructor TdxSkinRibbonPainter.Destroy;
begin
  FreeAndNil(FLookAndFeel);
  inherited Destroy;
end;

function TdxSkinRibbonPainter.GetName: string;
begin
  Result := GetSkinName;
end;

procedure TdxSkinRibbonPainter.SetInternalSkinName(const ASkinName: string);
begin
  FLookAndFeel.SkinName := ASkinName;
end;

function TdxSkinRibbonPainter.GetSkinData(
  var ASkinInfo: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(LookAndFeel.SkinPainter, ASkinInfo);
end;

function TdxSkinRibbonPainter.GetStatusBarElement(
  AIsLeft, AIsRectangular: Boolean): TdxSkinElement;
const
  ABorders: array[Boolean] of TcxBorder = (bRight, bLeft);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinData(ASkinInfo) then
    if not AIsRectangular then
      Result := ASkinInfo.RibbonStatusBarBackground
    else
      Result := ASkinInfo.FormFrames[True, ABorders[AIsLeft]];
end;

function TdxSkinRibbonPainter.GetBorderBounds(ASide: TcxBorder; const ABorders: TRect;
  const AData: TdxRibbonFormData): TRect;
begin
  Result := AData.Bounds;
  if ASide in [bLeft, bRight] then
  begin
    Result.Top := ABorders.Top;
    if ASide = bLeft then
      Result.Right := Result.Left + ABorders.Left
    else
      Result.Left := Result.Right - ABorders.Right;
  end
  else
    if ASide = bTop then
      Result.Bottom := ABorders.Top
    else
      Result := Rect(Result.Left + 4, Result.Bottom - ABorders.Bottom,
        Result.Right - 4, Result.Bottom);
end;

function TdxSkinRibbonPainter.GetBorderSize: Integer;
begin
  Result := 4;
end;

function TdxSkinRibbonPainter.GetBorderSkinElement(ASide: TcxBorder;
  AIsRectangular: Boolean; ASkinInfo: TdxSkinLookAndFeelPainterInfo): TdxSkinElement;
begin
  case ASide of
    bLeft:
      Result := ASkinInfo.RibbonFormLeft[AIsRectangular];
    bTop:
      Result := ASkinInfo.RibbonFormCaption;
    bRight:
      Result := ASkinInfo.RibbonFormRight[AIsRectangular];
    bBottom:
      Result := ASkinInfo.RibbonFormBottom[AIsRectangular];
    else
      Result := nil;
  end;
end;

function TdxSkinRibbonPainter.GetCustomizeButtonOutsizeQAT(AHasAppButton: Boolean): Boolean;
var
  AProperty: TdxSkinBooleanProperty;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := False;
  if GetSkinData(ASkinInfo) then
  begin
    AProperty := ASkinInfo.RibbonQATCustomizeButtonOutsizeQAT[AHasAppButton];
    if AProperty <> nil then
      Result := AProperty.Value;
  end;
end;

function TdxSkinRibbonPainter.GetQATLeftOffset: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := 0;
  if GetSkinData(ASkinInfo) then
    with ASkinInfo do
      Result := RibbonIndents[0] + RibbonIndents[1] + QATOffsetDelta;
end;

function TdxSkinRibbonPainter.IsSkinAvailable: Boolean;
begin
  Result := LookAndFeel.SkinPainter <> nil;
end;

procedure TdxSkinRibbonPainter.DrawApplicationButton(DC: HDC; const R: TRect;
  AState: TdxApplicationButtonState);
const
  dxApplicationButtonStateToElementState: array[TdxApplicationButtonState] of
    TdxSkinElementState = (esNormal, esHot, esPressed);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonApplicationButton;

  if AElement = nil then
    inherited DrawApplicationButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, dxApplicationButtonStateToElementState[AState]);
end;

procedure TdxSkinRibbonPainter.DrawApplicationMenuBorder(DC: HDC; const R: TRect);
var
  AFooter: TdxSkinElement;
  AHeader: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AFooter := nil;
  AHeader := nil;
  if GetSkinData(ASkinInfo) then
  begin
    AFooter := ASkinInfo.RibbonApplicationMenuBorders[True];
    AHeader := ASkinInfo.RibbonApplicationMenuBorders[False];
  end;

  if (AFooter = nil) or (AHeader = nil) then
    inherited DrawApplicationMenuBorder(DC, R)
  else
  begin
    ARect := R;
    Dec(ARect.Bottom, AFooter.Size.cy);
    AHeader.Draw(DC, ARect);

    ARect.Top := ARect.Bottom;
    ARect.Bottom := R.Bottom;
    AFooter.Draw(DC, ARect);
  end;
end;

procedure TdxSkinRibbonPainter.DrawApplicationMenuButton(DC: HDC; const R: TRect; AState: Integer);
const
  ButtonState: array [Boolean] of TdxSkinElementState = (esNormal, esHot);
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  AButton: TdxSkinElement;
begin
  if GetSkinData(ASkinInfo) then
    AButton := ASkinInfo.ButtonElements
  else
    AButton := nil;

  if AButton = nil then
    inherited DrawApplicationMenuButton(DC, R, AState)
  else
    AButton.Draw(DC, R, 0, ButtonState[AState = DXBAR_HOT]);
end;

procedure TdxSkinRibbonPainter.DrawApplicationMenuContentFooter(DC: HDC;
  const R: TRect);
var
  AFooter: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AFooter := nil;
  if GetSkinData(ASkinInfo) then
    AFooter := ASkinInfo.RibbonApplicationMenuBorders[True];

  if AFooter = nil then
    inherited DrawApplicationMenuContentFooter(DC, R)
  else
  begin
    ARect := R;
    InflateRect(ARect, 3, 0);
    Inc(ARect.Bottom, 3);
    AFooter.Draw(DC, ARect);
  end;
end;

procedure TdxSkinRibbonPainter.DrawApplicationMenuContentHeader(DC: HDC;
  const R: TRect);
var
  AHeader: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AHeader := nil;
  if GetSkinData(ASkinInfo) then
    AHeader := ASkinInfo.RibbonApplicationMenuBorders[False];

  if AHeader = nil then
    inherited DrawApplicationMenuContentHeader(DC, R)
  else
  begin
    ARect := R;
    InflateRect(ARect, 3, 0);
    Dec(ARect.Top, 3);
    with AHeader.Image.Margins do
      Inc(ARect.Bottom, Bottom);
    DrawClippedElement(DC, R, ARect, AHeader);
  end;
end;

procedure TdxSkinRibbonPainter.DrawButtonGroup(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ABackground: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  ABackground := nil;
  if GetSkinData(ASkinInfo) then
  begin
    AElement := ASkinInfo.RibbonButtonGroupButton;
    ABackground := ASkinInfo.RibbonButtonGroup;
  end;

  if (AElement = nil) or (ABackground = nil) then
    inherited DrawButtonGroup(DC, R, AState)
  else
  begin
    ARect := R;
    with ABackground.Image.Margins.Rect do
      DrawClippedElement(DC, R, Rect(R.Left - Left, R.Top, R.Right + Right, R.Bottom),
        ABackground);
    with ABackground.ContentOffset do
    begin
      Inc(ARect.Top, Top);
      Dec(ARect.Bottom, Bottom);
    end;
    AElement.Draw(DC, ARect, 0, SkinElementStateByRibbonState(AState));
  end;
end;

procedure TdxSkinRibbonPainter.DrawButtonGroupBorderLeft(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonButtonGroup
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawButtonGroupBorderLeft(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawButtonGroupBorderRight(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonButtonGroup
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawButtonGroupBorderLeft(DC, R)
  else
    if not IsRectEmpty(R) then
    begin
      ARect := R;
      ARect.Left := ARect.Right - Trunc(AElement.Size.cx * AElement.Image.Margins.Right / cxRectWidth(ARect));
      DrawClippedElement(DC, R, ARect, AElement);
    end;
end;

procedure TdxSkinRibbonPainter.DrawButtonGroupBorderMiddle(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonButtonGroupSeparator
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawButtonGroupBorderMiddle(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementStateByRibbonState(AState));    
end;

procedure TdxSkinRibbonPainter.DrawCollapsedToolbarBackground(DC: HDC;
  const R: TRect; AState: Integer);
var
  ACollapsedToolBar: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    ACollapsedToolBar := ASkinInfo.RibbonCollapsedToolBarBackground
  else
    ACollapsedToolBar := nil;

  if ACollapsedToolBar <> nil then
    ACollapsedToolBar.Draw(DC, R, 0, SkinElementStateByRibbonState(AState))
  else
    inherited DrawCollapsedToolbarBackground(DC, R, AState);
end;

procedure TdxSkinRibbonPainter.DrawCollapsedToolbarGlyphBackground(DC: HDC;
  const R: TRect; AState: Integer);
var
  ACollapsedToolBarGlyph: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    ACollapsedToolBarGlyph := ASkinInfo.RibbonCollapsedToolBarGlyphBackground
  else
    ACollapsedToolBarGlyph := nil;

  if ACollapsedToolBarGlyph <> nil then
    ACollapsedToolBarGlyph.Draw(DC, R)
  else
    inherited DrawCollapsedToolbarGlyphBackground(DC, R, AState);
end;

procedure TdxSkinRibbonPainter.DrawEditArrowButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawEditButton(DC, R, AState, cxbkComboBtn);
end;

procedure TdxSkinRibbonPainter.DrawEditEllipsisButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawEditButton(DC, R, AState, cxbkEllipsisBtn);
end;

procedure TdxSkinRibbonPainter.DrawEditSpinDownButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawEditButton(DC, R, AState, cxbkSpinDownBtn);
end;

procedure TdxSkinRibbonPainter.DrawEditSpinUpButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawEditButton(DC, R, AState, cxbkSpinUpBtn);
end;

procedure TdxSkinRibbonPainter.DrawProgressDiscreteBand(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;

  function CheckRect(const R: TRect): TRect;
  begin
    Result := R;
    if ASkinInfo.ProgressBarElements[False, False] <> nil then
    begin
      InflateRect(Result, 0, 2);
      with ASkinInfo.ProgressBarElements[False, False].ContentOffset.Rect do
      begin
        Inc(Result.Top, Top);
        Dec(Result.Bottom, Bottom);
      end;
    end;
  end;

begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.ProgressBarElements[True, False]
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawProgressDiscreteBand(DC, R)
  else
  begin
    ARect := CheckRect(R);
    with AElement.Image.Margins.Rect do
    begin
      Dec(ARect.Left, Left);
      Inc(ARect.Right, Right);
    end;
    DrawClippedElement(DC, R, ARect, AElement);
  end;      
end;

procedure TdxSkinRibbonPainter.DrawProgressSolidBand(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.ProgressBarElements[True, False]
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawProgressDiscreteBand(DC, R)
  else
  begin
    ARect := R;
    if ASkinInfo.ProgressBarElements[False, False] <> nil then
    begin
      InflateRect(ARect, 2, 2);
      with ASkinInfo.ProgressBarElements[False, False].ContentOffset.Rect do
      begin
        Inc(ARect.Left, Left);
        Inc(ARect.Top, Top);
        Dec(ARect.Bottom, Bottom);
        Dec(ARect.Right, Right);
      end;
    end;
    DrawClippedElement(DC, R, ARect, AElement);
  end;
end;

procedure TdxSkinRibbonPainter.DrawProgressSubstrate(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.ProgressBarElements[False, False]
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawProgressSubstrate(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawDropDownBorder(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenu;

  if AElement = nil then
    inherited DrawDropDownBorder(DC, R)
  else
    AElement.Draw(DC, R);
end;                          

procedure TdxSkinRibbonPainter.DrawDropDownGalleryBackground(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGalleryBackground
  else
    AElement := nil;
    
  if AElement = nil then
    inherited DrawDropDownGalleryBackground(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryBottomSizeGrip(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizeGrips
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryBottomSizeGrip(DC, R)
  else
  begin
    ARect := cxRectInflate(R, 0, -3, -2, -1);
    ARect.Left := ARect.Right - cxRectHeight(ARect);
    AElement.Draw(DC, ARect, 1);
  end;
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryBottomSizingBand(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizingPanel
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryBottomSizingBand(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryBottomVerticalSizeGrip(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizeGrips
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryBottomVerticalSizeGrip(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryTopSizingBand(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizingPanel
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryTopSizingBand(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryTopSizeGrip(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizeGrips
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryTopSizingBand(DC, R)
  else
  begin
    ARect := cxRectInflate(R, 0, -3, -2, -1);
    ARect.Left := ARect.Right - cxRectHeight(ARect);
    AElement.Draw(DC, ARect, 2);
  end;
end;

procedure TdxSkinRibbonPainter.DrawDropDownGalleryTopVerticalSizeGrip(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGallerySizeGrips
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawDropDownGalleryTopVerticalSizeGrip(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawGalleryFilterBandBackground(DC: HDC;
  const R: TRect);
begin
  DrawDropDownGalleryBottomSizingBand(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawGalleryGroupHeaderBackground(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGalleryGroupCaption
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawGalleryGroupHeaderBackground(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawInRibbonGalleryBackground(DC: HDC;
  const R: TRect; AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGalleryPane
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawInRibbonGalleryBackground(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementStateByRibbonState(AState));
end;

procedure TdxSkinRibbonPainter.DrawInRibbonGalleryScrollBarButton(DC: HDC;
  const R: TRect; AButtonKind: TdxInRibbonGalleryScrollBarButtonKind;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
  begin
    case AButtonKind of
      gsbkLineUp:
        AElement := ASkinInfo.RibbonGalleryButtonUp;
      gsbkLineDown:
        AElement := ASkinInfo.RibbonGalleryButtonDown;
      gsbkDropDown:
        AElement := ASkinInfo.RibbonGalleryButtonDropDown;
    end;
  end;

  if AElement = nil then
    inherited DrawInRibbonGalleryScrollBarButton(DC, R, AButtonKind, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementStateByRibbonState(AState));
end;

procedure TdxSkinRibbonPainter.DrawArrowDown(DC: HDC; const R: TRect;
  AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esDisabled, esHot,
    esActive, esNormal, esNormal, esNormal, esNormal, esNormal);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonButtonArrow;

  if AElement = nil then
    inherited DrawArrowDown(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, StateMap[AState]);
end;                          

procedure TdxSkinRibbonPainter.DrawClippedElement(DC: HDC; const R: TRect;
  const ASource: TRect; AElement: TdxSkinElement;
  AState: TdxSkinElementState = esNormal; AIntersect: Boolean = False;
  AImageIndex: Integer = 0);
const
  ARegionOperations: array[Boolean] of TcxRegionOperation = (roSet, roIntersect);
begin
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(R), ARegionOperations[AIntersect]);
    AElement.Draw(BarCanvas.Handle, ASource, AImageIndex, AState);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxSkinRibbonPainter.InternalDrawEditButton(DC: HDC; const R: TRect;
  AState: Integer; AButtonKind: TcxEditBtnKind);
const
  ButtonState: array [DXBAR_NORMAL..DXBAR_ACTIVEDISABLED] of TcxButtonState = (
    cxbsNormal, cxbsDisabled, cxbsHot, cxbsNormal, cxbsPressed, cxbsPressed,
    cxbsDefault, cxbsDefault, cxbsDisabled);
begin
  if IsSkinAvailable then
  begin
    BarCanvas.BeginPaint(DC);
    try
      LookAndFeel.SkinPainter.DrawEditorButton(BarCanvas, R, AButtonKind,
        ButtonState[AState]);
    finally
      BarCanvas.EndPaint;
    end;
  end
  else
    DrawEditButton(DC, R, AState);
end;

procedure TdxSkinRibbonPainter.InternalDrawStatusBarBottomPart(DC: HDC;
  R: TRect; AIsLeft: Boolean; AIsActive: Boolean);
const
  AState: array[Boolean] of TdxSkinElementState = (esActiveDisabled, esActive);
var
  AElement: TdxSkinElement;
  AMinSize: Integer;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.FormFrames[True, bBottom]
  else
    AElement := nil;
    
  if Assigned(AElement) then
  begin
    R.Top := Max(R.Bottom - AElement.Size.cy, R.Top);
    ARect := R;
    with AElement.Image.Margins do
    begin
      AMinSize := Max(Left + Right, AElement.MinSize.Width);
      if AIsLeft then
        ARect.Right := Max(ARect.Left + AMinSize, ARect.Right + Right)
      else
        ARect.Left := Min(ARect.Right - AMinSize, ARect.Left - Left);
    end;
    DrawClippedElement(DC, R, ARect, AElement, AState[AIsActive]);
  end;
end;

function TdxSkinRibbonPainter.InternalDrawStatusBarPart(DC: HDC; const R: TRect;
  AIsRaised: Boolean; AIsRectangular: Boolean; AActive: Boolean;
  AIsLeft: Boolean): Boolean;
const
  AIndexMap: array[Boolean] of Integer = (0, 1);
  AState: array[Boolean] of TdxSkinElementState = (esActiveDisabled, esActive);
var
  AMinSize: Integer;
  AElement: TdxSkinElement;
  ARect: TRect;
begin
  AElement := GetStatusBarElement(AIsLeft, AIsRectangular);
  Result := Assigned(AElement);
  if Result then
  begin
    ARect := R;
    with AElement.Image.Margins do
    begin
      AMinSize := Max(Left + Right, AElement.MinSize.Width);
      if AIsLeft then
        ARect.Right := Max(ARect.Left + AMinSize, ARect.Right + Right)
      else
        ARect.Left := Min(ARect.Right - AMinSize, ARect.Left - Left);
    end;    
    DrawClippedElement(DC, R, ARect, AElement, AState[AActive], False, AIndexMap[AIsRaised]);
    if AIsRectangular then
      InternalDrawStatusBarBottomPart(DC, R, AIsLeft, AActive);
  end;
end;

procedure TdxSkinRibbonPainter.DrawFormBorders(DC: HDC; const ABordersWidth: TRect;
  ACaptionHeight: Integer; const AData: TdxRibbonFormData);

  procedure DrawBottomAngles(ALeft, ARight: TdxSkinElement);
  var
    ALeftRect: TRect;
    ARightRect: TRect;
    R: TRect;
  begin
    R := AData.Bounds;
    R.Top := R.Bottom - ABordersWidth.Bottom;
    ALeftRect := R;
    ALeftRect.Right := ALeftRect.Left + 4;
    ARightRect := R;
    ARightRect.Left := ARightRect.Right - 4;

    R := ALeftRect;
    Dec(R.Top, ALeft.Size.cy);
    DrawClippedElement(DC, ALeftRect, R, ALeft, esNormal, False, Byte(not AData.Active));
    R := ARightRect;
    Dec(R.Top, ARight.Size.cy);
    DrawClippedElement(DC, ARightRect, R, ARight, esNormal, False, Byte(not AData.Active));
  end;

var
  ADialogFrame: Boolean;
  ASide: TcxBorder;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
  begin
    BarCanvas.BeginPaint(DC);
    BarCanvas.SaveClipRegion;
    try
      ADialogFrame := IsRectangularFormBottom(AData);
      BarCanvas.ExcludeClipRect(cxRectContent(AData.Bounds, ABordersWidth));
      for ASide := Low(TcxBorder) to High(TcxBorder) do
      begin
        if (ASide = bTop) and (ACaptionHeight = 0) then
          Continue; 
        DrawFormBorder(DC, ASide, ACaptionHeight, AData, ABordersWidth,
          GetBorderSkinElement(ASide, ADialogFrame, ASkinInfo));
      end;
      if ABordersWidth.Bottom > 1 then
        DrawBottomAngles(
          GetBorderSkinElement(bLeft, ADialogFrame, ASkinInfo),
          GetBorderSkinElement(bRight, ADialogFrame, ASkinInfo));
    finally
      BarCanvas.RestoreClipRegion;
      BarCanvas.EndPaint;
    end;
  end
  else
    inherited DrawFormBorders(DC, ABordersWidth, ACaptionHeight, AData);
end;

procedure TdxSkinRibbonPainter.DrawFormBorder(DC: HDC; ASide: TcxBorder;
  ACaptionHeight: Integer; const AData: TdxRibbonFormData; const ABorders: TRect;
  AElement: TdxSkinElement);
var
  R: TRect;
begin
  if Assigned(AElement) then
  begin
    R := ABorders;
    Inc(R.Top, ACaptionHeight);
    R := GetBorderBounds(ASide, R, AData);
    SkinsRibbonCacheManager.FormBordersCache[ASide].DrawEx(DC, AElement, R,
      RibbonFormBorderStates[AData.Active], Integer(not AData.Active));
  end;
end;

procedure TdxSkinRibbonPainter.DrawFormBorderIcon(DC: HDC; const R: TRect;
  AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
const
  RibbonIconsToSkinFormIcons: array[TdxBorderDrawIcon] of TdxSkinFormIcon =
    (sfiMinimize, sfiMaximize, sfiRestore, sfiClose, sfiHelp);
  RibbonIconStateToSkinElementState: array[TdxBorderIconState] of TdxSkinElementState =
    (esNormal, esHot, esPressed, esActive, esHot);                  
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.FormIcons[True, RibbonIconsToSkinFormIcons[AIcon]];
  if AElement = nil then
    inherited DrawFormBorderIcon(DC, R, AIcon, AState)
  else
    AElement.Draw(DC, cxRectInflate(R, -1, -1), 0, RibbonIconStateToSkinElementState[AState]);
end;

procedure TdxSkinRibbonPainter.DrawFormCaption(DC: HDC; const R: TRect;
  const AData: TdxRibbonFormData);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonFormCaption;

  if AElement = nil then
    inherited DrawFormCaption(DC, R, AData)
  else
    SkinsRibbonCacheManager.FormCaptionCache.DrawEx(DC, AElement, R,
      esNormal, Byte(not AData.Active));
end;

procedure TdxSkinRibbonPainter.DrawFormStatusBarPart(DC: HDC; const R: TRect;
  AIsLeft: Boolean; AIsActive: Boolean; AIsRaised: Boolean;
  AIsRectangular: Boolean); 
begin
  if not InternalDrawStatusBarPart(DC, R, AIsRaised, AIsRectangular, AIsActive, AIsLeft) then
    inherited DrawFormStatusBarPart(DC, R, AIsLeft, AIsActive, AIsRaised, AIsRectangular);
end;

procedure TdxSkinRibbonPainter.DrawLargeButton(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonLargeButton;

  if AElement = nil then
    inherited DrawLargeButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementCheckState(AElement,
      SkinElementStateByRibbonState(AState)));
end;

procedure TdxSkinRibbonPainter.DrawLargeButtonDropButton(DC: HDC; const R: TRect;
  AState: Integer); 
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esNormal, esHot,
    esActive, esPressed, esPressed, esActive, esHot, esActiveDisabled);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonLargeSplitButtonBottom;

  if AElement = nil then
    inherited DrawLargeButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, StateMap[AState]);
end;

procedure TdxSkinRibbonPainter.DrawLargeButtonGlyphBackground(DC: HDC;
  const R: TRect; AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esNormal, esHot,
    esActive, esPressed, esDroppedDown, esActive, esHot, esActiveDisabled);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonLargeSplitButtonTop;

  if AElement = nil then
    inherited DrawLargeButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, StateMap[AState]);
end;

procedure TdxSkinRibbonPainter.DrawLaunchButtonBackground(DC: HDC; const R: TRect;
  AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esNormal, esHot,
    esHot, esPressed, esNormal, esNormal, esNormal, esNormal);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  ARect: TRect;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTabPanelGroupButton;

  if AElement = nil then
    inherited DrawLaunchButtonBackground(DC, R, AState)
  else
  begin
    ARect := R;
    OffsetRect(ARect, 0, 1);
    InflateRect(ARect, -1, -1);
    AElement.Draw(DC, ARect, 0, StateMap[AState]);
  end;          
end;

procedure TdxSkinRibbonPainter.DrawLaunchButtonDefaultGlyph(DC: HDC; const R: TRect;
  AState: Integer);
begin
  if not IsSkinAvailable then
    inherited DrawLaunchButtonDefaultGlyph(DC, R, AState);
end;

procedure TdxSkinRibbonPainter.DrawHelpButton(DC: HDC; const R: TRect;
  AState: TdxBorderIconState);
const
  AStateMap: array [TdxBorderIconState] of Integer =
    (DXBAR_NORMAL, DXBAR_HOT, DXBAR_PRESSED, DXBAR_NORMAL, DXBAR_NORMAL);
begin
  if IsSkinAvailable then
    DrawSmallButton(DC, R, AStateMap[AState])
  else         
    inherited DrawHelpButton(DC, R, AState);  
end;

procedure TdxSkinRibbonPainter.DrawGroupScrollButton(DC: HDC; const R: TRect;
  ALeft: Boolean; AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonGroupScroll[ALeft]
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawGroupScrollButton(DC, R, ALeft, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementStateByRibbonState(AState));
end;

procedure TdxSkinRibbonPainter.DrawMarkArrow(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonQuickToolbarGlyph
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawMarkArrow(DC, R, AState)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawMDIButton(DC: HDC; const R: TRect;
  AButton: TdxBarMDIButton; AState: TdxBorderIconState);
const
  RibbonIconsToSkinFormIcons: array[TdxBarMDIButton] of TdxSkinFormIcon =
    (sfiMinimize, sfiRestore, sfiClose);
  RibbonIconStateToSkinElementState: array[TdxBorderIconState] of TdxSkinElementState =
    (esNormal, esHot, esPressed, esActive, esHot);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  ARect: TRect;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.FormIcons[True, RibbonIconsToSkinFormIcons[AButton]];
  if AElement = nil then
    inherited DrawMDIButton(DC, R, AButton, AState)
  else
  begin
    ARect := R;
    InflateRect(ARect, -1, -1);
    AElement.Draw(DC, ARect, 0, RibbonIconStateToSkinElementState[AState]);
  end;
end;

procedure TdxSkinRibbonPainter.DrawMDIButtonGlyph(DC: HDC; const R: TRect;
  AButton: TdxBarMDIButton; AState: TdxBorderIconState);
begin
end;

procedure TdxSkinRibbonPainter.DrawMenuCheck(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenuCheck;

  if AElement = nil then
    inherited DrawMenuCheck(DC, R, AState)
  else
    AElement.Draw(DC, R, 1);
end;

procedure TdxSkinRibbonPainter.DrawMenuCheckMark(DC: HDC; const R: TRect;
  AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenuCheck;

  if AElement = nil then
    inherited DrawMenuCheckMark(DC, R, AState)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawMenuContent(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenu
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawMenuContent(DC, R)
  else
  begin
    BarCanvas.BeginPaint(DC);
    try
      BarCanvas.FillRect(R, AElement.Color);
    finally
      BarCanvas.EndPaint;
    end;
  end;
end;

procedure TdxSkinRibbonPainter.DrawMenuGlyph(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R1: TRect;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenuSideStrip
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawMenuGlyph(DC, R)
  else
  begin
    R1 := R;
    Inc(R1.Right, Max(2, AElement.Image.Margins.Right));
    DrawClippedElement(DC, R, R1, AElement);
  end;
end;

procedure TdxSkinRibbonPainter.DrawMenuScrollArea(DC: HDC; const R: TRect;
  AState: Integer);
begin
  if not IsSkinAvailable then
    inherited DrawMenuScrollArea(DC, R, AState)
end;

procedure TdxSkinRibbonPainter.DrawMenuSeparatorHorz(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenuSeparator
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawMenuSeparatorHorz(DC, R)
  else
  begin
    if AElement.IsAlphaUsed then
      DrawMenuContent(DC, R);
    AElement.Draw(DC, R);
  end;
end;

procedure TdxSkinRibbonPainter.DrawMenuSeparatorVert(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R1: TRect;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.PopupMenuSideStrip
  else
    AElement := nil;
    
  if AElement = nil then
    inherited DrawMenuGlyph(DC, R)
  else
  begin
    R1 := R;
    R1.Left := R.Right - Max(2, AElement.Size.cx);
    DrawClippedElement(DC, R, R1, AElement);
  end;
end;

procedure TdxSkinRibbonPainter.DrawRibbonBackground(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
  R1: TRect;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonHeaderBackground
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawRibbonBackground(DC, R)
  else
  begin
    R1 := R;
    if AElement.IsAlphaUsed then
      Inc(R1.Bottom, AElement.Image.Margins.Bottom);
    DrawClippedElement(DC, R, R1, AElement, esNormal, True);
  end;
end;

procedure TdxSkinRibbonPainter.DrawRibbonClientTopArea(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonFormCaption;

  if AElement = nil then
    inherited DrawRibbonClientTopArea(DC, R)
  else
    with AElement.Image.Margins.Rect do
      DrawClippedElement(DC, R, Rect(R.Left - Left, R.Top, R.Right + Right,
        R.Bottom), AElement, esNormal, True);
end;

procedure TdxSkinRibbonPainter.DrawScreenTip(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.ScreenTipWindow;

  if AElement = nil then
    inherited DrawScreenTip(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawSmallButton(DC: HDC; const R: TRect;
  AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esDisabled, esHot,
    esHot, esPressed, esChecked, esChecked, esHotCheck, esActiveDisabled);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonSmallButton;

  if AElement = nil then
    inherited DrawSmallButton(DC, R, AState)
  else
    SkinsRibbonCacheManager.SmallButtonsCache.DrawEx(DC, AElement, R, StateMap[AState]);
end;

procedure TdxSkinRibbonPainter.DrawSmallButtonDropButton(DC: HDC; const R: TRect;
  AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esNormal, esHot,
    esActive, esPressed, esFocused, esActive, esHot, esNormal);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonSplitButtonRight;

  if AElement = nil then
    inherited DrawSmallButtonDropButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, StateMap[AState]);
end;

procedure TdxSkinRibbonPainter.DrawSmallButtonGlyphBackground(DC: HDC;
  const R: TRect; AState: Integer);
const
  StateMap: array[0..8] of TdxSkinElementState = (esNormal, esNormal, esHot,
    esActive, esPressed, esFocused, esActive, esHot, esNormal);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonSplitButtonLeft;

  if AElement = nil then
    inherited DrawSmallButtonDropButton(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, StateMap[AState]);
end;

procedure TdxSkinRibbonPainter.DrawStatusBar(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarBackground
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawStatusBar(DC, R)
  else
    DrawClippedElement(DC, R, cxRectInflate(R, BorderSize, 0), AElement, esNormal, True);
end;

procedure TdxSkinRibbonPainter.DrawStatusBarGripBackground(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;

  procedure DrawBackground;
  var
    ARect: TRect;
  begin
    ARect := R;
    with AElement.Image.Margins do
    begin
      Dec(ARect.Left, Left);
      Inc(ARect.Right, Right);
    end;
    DrawClippedElement(DC, R, ARect, AElement, esNormal, False, 1);
  end;

  procedure DrawContent(ASizeGrip: TdxSkinElement);
  var
    ARect: TRect;
  begin
    if ASizeGrip = nil then Exit;
    ARect := R;
    with AElement.ContentOffset do
    begin
      Inc(ARect.Left, Left);
      Inc(ARect.Top, Top);
      Dec(ARect.Right, Right);
      Dec(ARect.Bottom, Bottom);
    end;
    ASizeGrip.Draw(DC, ARect);
  end;

begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarBackground;

  if AElement = nil then
    inherited DrawStatusBarGripBackground(DC, R)
  else
  begin
    DrawBackground;
    DrawContent(ASkinInfo.SizeGrip);
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
  end;
end;

procedure TdxSkinRibbonPainter.DrawStatusBarPanel(DC: HDC; const Bounds, R: TRect;
  AIsLowered: Boolean);
var
  ABitmap: TcxBitmap;
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarBackground
  else
    AElement := nil;
    
  if AElement = nil then
    inherited DrawStatusBarPanel(DC, Bounds, R, AIsLowered)
  else
  begin
    ABitmap := TcxBitmap.CreateSize(Bounds, pf32bit);
    try
      ARect := ABitmap.ClientRect;
      Dec(ARect.Left, Bounds.Left + BorderSize);
      ARect.Right := Max(ABitmap.Width, ARect.Left + AElement.Size.cx) + BorderSize;  
      AElement.Draw(ABitmap.Canvas.Handle, ARect, Integer(not AIsLowered));
      cxBitBlt(DC, ABitmap.Canvas.Handle, R, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;
  end;
end;

procedure TdxSkinRibbonPainter.DrawStatusBarPanelSeparator(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarSeparator
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawStatusBarPanelSeparator(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawStatusBarToolbarSeparator(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarSeparator;

  if AElement = nil then
    inherited DrawStatusBarToolbarSeparator(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawTab(DC: HDC; const R: TRect;
  AState: TdxRibbonTabState);
const
  ATabStatesMap: array[TdxRibbonTabState] of TdxSkinElementState =
    (esNormal, esHot, esActive, esFocused, esFocused);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTab;

  if AElement = nil then
    inherited DrawTab(DC, R, AState)
  else
  begin
    ARect := R;
    Inc(ARect.Top, 2);
    InflateRect(ARect, -1, 0);
    AElement.Draw(DC, ARect, 0, ATabStatesMap[AState]);
  end;
end;

procedure TdxSkinRibbonPainter.DrawTabGroupBackground(DC: HDC; const R: TRect;
  AState: Integer);
const
  AStateMap: array[Boolean] of TdxSkinElementState = (esNormal, esHot);  
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTabGroup;

  if AElement = nil then
    inherited DrawTabGroupBackground(DC, R, AState)
  else
    SkinsRibbonCacheManager.TabGroupBackground.DrawElement(DC, AElement,
      R, AStateMap[AState = DXBAR_HOT]);
end;

procedure TdxSkinRibbonPainter.DrawTabGroupHeaderBackground(DC: HDC; const R: TRect;
  AState: Integer);
const
  AStateMap: array[Boolean] of TdxSkinElementState = (esNormal, esHot);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTabGroupHeader;

  if AElement = nil then
    inherited DrawTabGroupHeaderBackground(DC, R, AState)
  else
    AElement.Draw(DC, R, 0, AStateMap[AState = DXBAR_HOT]);
end;

procedure TdxSkinRibbonPainter.DrawTabGroupsArea(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTabPanel;
  if AElement = nil then
    inherited DrawTabGroupsArea(DC, R)
  else
  begin
    ARect := R;
    if ASkinInfo.RibbonIndents[2] <> 0 then
      ARect.Top := ARect.Top - ASkinInfo.RibbonIndents[2] + 1;
    SkinsRibbonCacheManager.TabGroupsAreaCache.DrawEx(DC, AElement, ARect);
  end;
end;

procedure TdxSkinRibbonPainter.DrawTabScrollButton(DC: HDC; const R: TRect;
  ALeft: Boolean; AState: Integer);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonSmallButton
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawTabScrollButton(DC, R, ALeft, AState)
  else
    AElement.Draw(DC, R, 0, SkinElementStateByRibbonState(AState));
end;

procedure TdxSkinRibbonPainter.DrawTabSeparator(DC: HDC; const R: TRect;
  Alpha: Byte);
begin
  if not IsSkinAvailable then
    inherited DrawTabSeparator(DC, R, Alpha);
end;

procedure TdxSkinRibbonPainter.DrawRibbonBottomBorder(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonTabPanel
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawRibbonBottomBorder(DC, R)
  else
  begin
    ARect := R;
    with AElement.Image.Margins do
    begin
      Dec(ARect.Left, Left);
      Inc(ARect.Right, Right);
    end;
    ARect.Bottom := ARect.Top + AElement.Size.cy;
    DrawClippedElement(DC, R, ARect, AElement);
  end;
end;

procedure TdxSkinRibbonPainter.DrawQuickAccessToolbar(DC: HDC; const R: TRect;
  ABellow, ANonClientDraw, AHasApplicationButton, AIsActive, ADontUseAero: Boolean);

  function IsAeroBackgroundUsed: Boolean;
  begin
    Result := ANonClientDraw and IsCompositionEnabled and not (ADontUseAero or ABellow);
  end;

  function ValidateQATRect(const R: TRect; AParent: TdxSkinElement): TRect;
  var
    ARightIndent: Integer;
  begin
    Result := R;
    if not ABellow then
    begin
      if AParent = nil then
        ARightIndent := 0
      else
        with AParent.ContentOffset.Rect do
        begin
          ARightIndent := GetQuickAccessToolbarRightIndent(AHasApplicationButton);
          Result := cxRectInflate(R, 0, -Top, 0, -Bottom);
        end;

      if GetCustomizeButtonOutsizeQAT(AHasApplicationButton) then
      begin
        Dec(ARightIndent, QATRightDefaultOffset);
        Dec(ARightIndent, GetQuickAccessToolbarMarkButtonOffset(AHasApplicationButton, ABellow));
      end;
      Inc(Result.Right, ARightIndent);
    end;
  end;

var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    if ABellow then
      AElement := ASkinInfo.RibbonQuickToolbarBelow
    else
      AElement := ASkinInfo.RibbonQuickToolbar[AHasApplicationButton];

  if (AElement = nil) or IsAeroBackgroundUsed then
    inherited DrawQuickAccessToolbar(DC, R, ABellow, ANonClientDraw,
      AHasApplicationButton, AIsActive, ADontUseAero)
  else
    AElement.Draw(DC, ValidateQATRect(R, ASkinInfo.RibbonFormCaption));
end;

procedure TdxSkinRibbonPainter.DrawQuickAccessToolbarDefaultGlyph(DC: HDC;
  const R: TRect);
var
  AElement: TdxSkinElement;  
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonQuickToolbarButtonGlyph
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawQuickAccessToolbarDefaultGlyph(DC, R)
  else  
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.DrawQuickAccessToolbarGroupButton(DC: HDC;
  const R: TRect; ABellow: Boolean; ANonClientDraw: Boolean; AIsActive: Boolean;
  AState: Integer);
var
  ABackground: TdxSkinElement;
  AElement: TdxSkinElement;
  ARect: TRect;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
  begin
    ABackground := ASkinInfo.RibbonButtonGroup;
    AElement := ASkinInfo.RibbonButtonGroupButton;
  end
  else
  begin
    AElement := nil;
    ABackground := nil;
  end;

  if (AElement = nil) or (ABackground = nil) then
    inherited DrawQuickAccessToolbarGroupButton(DC, R, ABellow, ANonClientDraw,
      AIsActive, AState)
  else
  begin
    ARect := R;
    ABackground.Draw(DC, R);
    with ABackground.ContentOffset.Rect do
    begin
      Inc(ARect.Top, Top);
      Inc(ARect.Left, Left);
      Dec(ARect.Right, Right);
      Dec(ARect.Bottom, Bottom);
    end;
    AElement.Draw(DC, ARect, 0, SkinElementStateByRibbonState(AState));
  end;
end;

procedure TdxSkinRibbonPainter.DrawQuickAccessToolbarPopup(DC: HDC; const R: TRect);
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonQuickToolbarDropDown
  else
    AElement := nil;

  if AElement = nil then
    inherited DrawQuickAccessToolbarPopup(DC, R)
  else
    AElement.Draw(DC, R);
end;

procedure TdxSkinRibbonPainter.CorrectApplicationMenuButtonGlyphBounds(var R: TRect);
begin
  if not IsSkinAvailable then
    inherited CorrectApplicationMenuButtonGlyphBounds(R);
end;

function TdxSkinRibbonPainter.GetApplicationMenuGlyphSize: TSize;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonApplicationButton
  else
    AElement := nil;

  if AElement = nil then
    Result := inherited GetApplicationMenuGlyphSize
  else
    Result := AElement.Size;
end;

function TdxSkinRibbonPainter.GetCaptionFontSize(ACurrentFontSize: Integer): Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := inherited GetCaptionFontSize(ACurrentFontSize);
  if GetSkinData(ASkinInfo) and (ASkinInfo.RibbonCaptionFontDelta <> nil) then
    Inc(Result, ASkinInfo.RibbonCaptionFontDelta.Value);
end;

function TdxSkinRibbonPainter.GetMenuSeparatorSize: Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) and Assigned(ASkinInfo.PopupMenuSeparator) then
    Result := ASkinInfo.PopupMenuSeparator.Size.cy
  else
    Result := inherited GetMenuSeparatorSize;
end;

function TdxSkinRibbonPainter.GetPartColor(APart: Integer;
  AState: Integer = 0): TColor;

  function GetPropertyColor(AColor: TdxSkinColor): TColor;
  begin
    if AColor = nil then
      Result := clDefault
    else
      Result := AColor.Value;
  end;

var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := clDefault;
  if GetSkinData(ASkinInfo) then
    case APart of
      DXBAR_MENUEXTRAPANE:
        Result := GetPropertyColor(ASkinInfo.RibbonExtraPaneColor);

      DXBAR_SEPARATOR_BACKGROUND, DXBAR_EDIT_BACKGROUND:
        Result := GetPropertyColor(ASkinInfo.ContentColor);

      DXBAR_ITEMTEXT:
        Result := ASkinInfo.RibbonButtonText[AState = DXBAR_DISABLED];

      DXBAR_MENUITEMTEXT:
        if AState = DXBAR_DISABLED then
          Result := GetPropertyColor(ASkinInfo.BarDisabledTextColor)
        else
          if ASkinInfo.PopupMenu <> nil then
          Result := ASkinInfo.PopupMenu.TextColor;

      DXBAR_EDIT_BORDER:
        if AState = DXBAR_ACTIVE then
          Result := GetPropertyColor(ASkinInfo.ContainerHighlightBorderColor)
        else
          Result := GetPropertyColor(ASkinInfo.ContainerBorderColor);

      DXBAR_SCREENTIP_FOOTERLINE,
      DXBAR_APPLICATIONMENUCONTENTINNERBORDER:
        Result := GetPropertyColor(ASkinInfo.ContainerBorderColor);

      DXBAR_APPLICATIONMENUCONTENTOUTERBORDER,
      DXBAR_APPLICATIONMENUCONTENTSIDES, rfspRibbonForm:
        if ASkinInfo.FormContent <> nil then
          Result := ASkinInfo.FormContent.Color;

      rspTabHeaderText:
        Result := ASkinInfo.RibbonTabText[AState = DXBAR_ACTIVE];

      rspFormCaptionText:
        Result := ASkinInfo.RibbonCaptionText[AState = DXBAR_NORMAL];

      rspDocumentNameText:
        Result := ASkinInfo.RibbonDocumentNameTextColor[AState = DXBAR_NORMAL];

      rspTabGroupText:
        if ASkinInfo.RibbonSmallButton <> nil then
          Result := ASkinInfo.RibbonSmallButton.TextColor;

      rspTabGroupHeaderText:
        if ASkinInfo.RibbonTabGroupHeader <> nil then
          Result := ASkinInfo.RibbonTabGroupHeader.TextColor;

      rspStatusBarText:
        case AState of
          DXBAR_NORMAL:
            Result := ASkinInfo.RibbonStatusBarText;
          DXBAR_HOT:
            Result := ASkinInfo.RibbonStatusBarTextHot;
          DXBAR_DISABLED:
            Result := ASkinInfo.RibbonStatusBarTextDisabled;
        end;        

      DXBAR_GALLERYGROUPHEADERTEXT, DXBAR_GALLERYFILTERBANDTEXT:
        if ASkinInfo.RibbonGalleryGroupCaption <> nil then
          Result := ASkinInfo.RibbonGalleryGroupCaption.TextColor;
    end;
  if Result = clDefault then
    Result := inherited GetPartColor(APart, AState);
end;

function TdxSkinRibbonPainter.GetPartContentOffsets(APart: Integer): TRect;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  AElement := nil;
  if GetSkinData(ASkinInfo) then
    if APart = DXBAR_GALLERYFILTERBAND then
      AElement := ASkinInfo.RibbonGallerySizingPanel;
  if AElement <> nil then
    Result := AElement.Image.Margins.Rect
  else
    Result := inherited GetPartContentOffsets(APart);
end;

function TdxSkinRibbonPainter.GetQuickAccessToolbarLeftIndent(
  AHasApplicationButton: Boolean; AUseAeroGlass: Boolean): Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not AUseAeroGlass and AHasApplicationButton and GetSkinData(ASkinInfo) then
  begin
    Result := -QATLeftDefaultOffset;
    if ASkinInfo.RibbonQuickToolbar[True] <> nil then
      Inc(Result, ASkinInfo.RibbonQuickToolbar[True].ContentOffset.Left);
    Inc(Result, GetQATLeftOffset);
  end
  else
    Result := inherited GetQuickAccessToolbarLeftIndent(AHasApplicationButton,
      AUseAeroGlass);
end;

function TdxSkinRibbonPainter.GetQuickAccessToolbarMarkButtonOffset(
  AHasApplicationButton: Boolean; ABelow: Boolean): Integer;
var
  AOffsetProperty: TdxSkinIntegerProperty;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AOffsetProperty := ASkinInfo.RibbonQATIndentBeforeCustomizeButton[AHasApplicationButton]
  else
    AOffsetProperty := nil;

  if ABelow or (AOffsetProperty = nil) then
    Result := inherited GetQuickAccessToolbarMarkButtonOffset(AHasApplicationButton, ABelow)
  else
    begin
      Result := AOffsetProperty.Value;
      if GetCustomizeButtonOutsizeQAT(AHasApplicationButton) then
        Inc(Result, GetQuickAccessToolbarRightIndent(AHasApplicationButton));
    end;
end;

function TdxSkinRibbonPainter.GetQuickAccessToolbarOverrideWidth(
  AHasApplicationButton: Boolean; AUseAeroGlass: Boolean): Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if not AUseAeroGlass and AHasApplicationButton and GetSkinData(ASkinInfo) then
  begin
    with ASkinInfo do
      Result := GetQuickAccessToolbarLeftIndent(True, AUseAeroGlass) + QATLeftDefaultOffset;
    Dec(Result, GetQATLeftOffset);
  end
  else
    Result := inherited GetQuickAccessToolbarOverrideWidth(AHasApplicationButton,
      AUseAeroGlass);
end;

function TdxSkinRibbonPainter.GetQuickAccessToolbarRightIndent(
  AHasApplicationButton: Boolean): Integer;
var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) and (ASkinInfo.RibbonQuickToolbar[AHasApplicationButton] <> nil) then
    Result := ASkinInfo.RibbonQuickToolbar[AHasApplicationButton].ContentOffset.Right
  else
    Result := inherited GetQuickAccessToolbarRightIndent(AHasApplicationButton);
end;

function TdxSkinRibbonPainter.GetSkinName: string;
begin
  Result := FLookAndFeel.SkinName;
end;

function TdxSkinRibbonPainter.GetStatusBarSeparatorSize: Integer;
var
  AElement: TdxSkinElement;
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;
begin
  if GetSkinData(ASkinInfo) then
    AElement := ASkinInfo.RibbonStatusBarSeparator
  else
    AElement := nil;

  if AElement = nil then
    Result := inherited GetStatusBarSeparatorSize
  else
  begin
    Result := AElement.MinSize.Width;
    if Result = 0 then
      Result := AElement.Image.Size.cx;
    if Result = 0 then
      Result := inherited GetStatusBarSeparatorSize;
  end;
end;

function TdxSkinRibbonPainter.GetWindowBordersWidth(AHasStatusBar: Boolean): TRect;

  function GetElementSizes(AElement: TdxSkinElement): TSize;
  begin
    if AElement = nil then
      Result := cxNullSize
    else
      Result := AElement.Size;
  end;

var
  ASkinInfo: TdxSkinLookAndFeelPainterInfo;  
begin
  if GetSkinData(ASkinInfo) then
  begin
    Result := Rect(GetElementSizes(GetBorderSkinElement(bLeft, False, ASkinInfo)).cx,
      0, GetElementSizes(GetBorderSkinElement(bRight, False, ASkinInfo)).cx, 0);
    if AHasStatusBar then
      Result.Bottom := 1
    else
      Result.Bottom := GetElementSizes(GetBorderSkinElement(bBottom, False, ASkinInfo)).cy;
  end
  else
    Result := inherited GetWindowBordersWidth(AHasStatusBar);
end;

function TdxSkinRibbonPainter.HasGroupTransparency: Boolean;
begin
  Result := True;
end;

function TdxSkinRibbonPainter.NeedDrawGroupScrollArrow: Boolean;
begin
  Result := False;
end;

{ TdxSkinsRibbonCacheManager }

constructor TdxSkinsRibbonCacheManager.Create;
var
  ASide: TcxBorder;
begin
  FSmallButtonsCache := TdxSkinElementCache.Create;
  FFormCaptionCache := TdxSkinElementCache.Create;
  FTabGroupBackground := TdxSkinElementCacheList.Create;
  FTabGroupsAreaCache := TdxSkinElementCache.Create;
  for ASide := Low(TcxBorder) to High(TcxBorder) do
    FFormBordersCache[ASide] := TdxSkinElementCache.Create;
end;

destructor TdxSkinsRibbonCacheManager.Destroy;
var
  ASide: TcxBorder;
begin
  FreeAndNil(FFormCaptionCache);
  FreeAndNil(FTabGroupBackground);
  FreeAndNil(FTabGroupsAreaCache);
  FreeAndNil(FSmallButtonsCache);
  for ASide := Low(TcxBorder) to High(TcxBorder) do
    FreeAndNil(FFormBordersCache[ASide]);
end;

function TdxSkinsRibbonCacheManager.GetFormBordersCache(
  ASide: TcxBorder): TdxSkinElementCache;
begin
  Result := FFormBordersCache[ASide];
end;

{ TdxSkinsRibbonPainterManager }

constructor TdxSkinsRibbonPainterManager.Create;
begin
  GetExtendedStylePainters.AddListener(Self);
  InitializePaintersList;
end;

destructor TdxSkinsRibbonPainterManager.Destroy;
begin
  GetExtendedStylePainters.RemoveListener(Self);
  FreePaintersList;  
  inherited Destroy;
end;

procedure TdxSkinsRibbonPainterManager.FreePaintersList;
var
  I: Integer;
  ASkin: TdxCustomBarSkin;
begin
  for I := SkinManager.SkinCount - 1 downto 0 do
  begin
    ASkin := SkinManager.Skins[I];
    if ASkin is TdxSkinRibbonPainter then
      SkinManager.RemoveSkin(ASkin);
  end;    
end;

procedure TdxSkinsRibbonPainterManager.InitializePaintersList;
var
  I: Integer;
  AExtendedPainters: TcxExtendedStylePainters;
begin
  AExtendedPainters := GetExtendedStylePainters;
  if AExtendedPainters <> nil then
    for I := 0 to AExtendedPainters.Count - 1 do
      if SkinManager.SkinByName(AExtendedPainters.Names[I]) = nil then
        SkinManager.AddSkin(TdxSkinRibbonPainter.Create(AExtendedPainters.Names[I]));
end;

procedure TdxSkinsRibbonPainterManager.PainterChanged(
  APainter: TcxCustomLookAndFeelPainterClass);
var
  AName: string;
  ASkin: TdxCustomBarSkin;
  I: Integer;
begin
  if GetExtendedStylePainters.GetNameByPainter(APainter, AName) then
  begin
    if SkinManager.SkinByName(AName) = nil then
      SkinManager.AddSkin(TdxSkinRibbonPainter.Create(AName))
  end
  else
    for I := SkinManager.SkinCount - 1 downto 0 do
    begin
      ASkin := SkinManager.Skins[I];
      if (ASkin is TdxSkinRibbonPainter) and (TdxSkinRibbonPainter(ASkin).SkinName = '') then
        SkinManager.RemoveSkin(ASkin);
    end;
end;

procedure RegisterPainterManager;
begin
  SkinsRibbonCacheManager := TdxSkinsRibbonCacheManager.Create;
  SkinsRibbonPainterManager := TdxSkinsRibbonPainterManager.Create;
end;

procedure UnregisterPainterManager;
begin
  FreeAndNil(SkinsRibbonPainterManager);
  FreeAndNil(SkinsRibbonCacheManager);
end;

initialization
  dxUnitsLoader.AddUnit(@RegisterPainterManager, @UnregisterPainterManager);

finalization
  dxUnitsLoader.RemoveUnit(@UnregisterPainterManager);

end.
