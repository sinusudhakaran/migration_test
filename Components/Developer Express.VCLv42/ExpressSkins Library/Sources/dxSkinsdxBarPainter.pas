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

unit dxSkinsdxBarPainter;

{$I cxVer.inc}

interface

uses
  Types, Windows, SysUtils, Classes, Controls, Graphics, Messages, cxLookAndFeels,
  cxLookAndFeelPainters, dxBar, dxSkinsLookAndFeelPainter,
  dxSkinsCore, cxGraphics, cxGeometry;

type
  {TdxBarSkinPainter}

  TdxBarSkinPainter = class(TdxBarPainter, IdxFadingPainterHelper)
  private
    FSkinPainter: TcxCustomLookAndFeelPainterClass;
    function GetBar(AIsVertical: Boolean): TdxSkinElement;
    function GetBarCustomize(AIsVertical: Boolean): TdxSkinElement;
    function GetBarDisabledTextColor: TdxSkinColor;
    function GetBarDrag(AIsVertical: Boolean): TdxSkinElement;
    function GetBarSeparator(AIsVertical: Boolean): TdxSkinElement;
    function GetDock: TdxSkinElement;
    function GetDockControlWindowButton: TdxSkinElement;
    function GetDockControlWindowButtonGlyph: TdxSkinElement;
    function GetFloatingBar: TdxSkinElement;
    function GetLinkBorderPainter: TdxSkinElement;
    function GetLinkSelected: TdxSkinElement;
    function GetMainMenu(AIsVertical: Boolean): TdxSkinElement;
    function GetMainMenuCustomize(AIsVertical: Boolean): TdxSkinElement;
    function GetMainMenuDrag: TdxSkinElement;
    function GetMainMenuLinkSelected: TdxSkinElement;
    function GetPopupMenu: TdxSkinElement;
    function GetPopupMenuCheck: TdxSkinElement;
    function GetPopupMenuExpandButton: TdxSkinElement;
    function GetPopupMenuLinkSelected: TdxSkinElement;
    function GetPopupMenuSeparator: TdxSkinElement;
    function GetPopupMenuSideStrip: TdxSkinElement;
    function GetPopupMenuSideStripNonRecent: TdxSkinElement;
    function GetPopupMenuSplitButton: TdxSkinElement;
    function GetPopupMenuSplitButton2: TdxSkinElement;
    function GetStatusBar: TdxSkinElement;
    function GetScreenTipItem: TdxSkinColor;
    function GetScreenTipSeparator: TdxSkinElement;
    function GetScreenTipTitleItem: TdxSkinColor;
    function GetScreenTipWindow: TdxSkinElement;
    function GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;

    function DrawSkinElement(AElement: TdxSkinElement; DC: HDC;
      const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal): Boolean;
    function DrawSkinElementContent(AElement: TdxSkinElement; DC: HDC;
      const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal): Boolean;
    function DrawSkinElementBorders(AElement: TdxSkinElement; DC: HDC;
      const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal): Boolean;

    function GetSkinElementSize(ASkinElement: TdxSkinElement): TSize;
    function GetSkinElementTextColorHot(ASkinElement: TdxSkinElement): TdxSkinColor;

    function GetBarElement(ABarControl: TCustomdxBarControl; AVertical: Boolean): TdxSkinElement; overload;
    function GetBarElement(ABarControl: TCustomdxBarControl): TdxSkinElement; overload;
    function GetBarMarkElement(AMainMenu, AVertical: Boolean): TdxSkinElement; 
    function GetTextColorElement(ABarControl: TCustomdxBarControl): TdxSkinElement;

    function IsBarElementSkinned(ABarControl: TCustomdxBarControl): Boolean;

    procedure DrawArrowButtonElement(AElement: TdxSkinElement; ACanvas: TcxCanvas;
      const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal);

    // Bar
    procedure DrawFloatingBarCaptionButton(DC: HDC; ARect: TRect; AContentType: Integer; AState: TdxBarMarkState);
    procedure InternalDrawDockedBarBackground(ABarControl: TdxBarControl; ACanvas: TcxCanvas; R: TRect; AClientArea: Boolean);

    // ButtonLikeControl
    function ButtonLikeControlGetState(const ADrawParams: TdxBarButtonLikeControlDrawParams): TdxSkinElementState;
    function ButtonLikeDrawArrowFadingElement(
      const ADrawParams: TdxBarButtonLikeControlDrawParams; var R: TRect): Boolean;
    function ButtonLikeDrawFadingElement(ABarItemControl: TdxBarItemControl;
      DC: HDC; const R: TRect; AIsSplit: Boolean): Boolean;
  protected
    // IdxFadingPainterHelper
    function BarMarkIsOpaque: Boolean;
    procedure DrawBarMarkState(ABarControl: TdxBarControl; DC: HDC; const R: TRect;
      AState: TdxBarMarkState);
    procedure DrawButtonBackground(const ADrawParams: TdxBarButtonLikeControlDrawParams);

    // Common
      // Attributes
    function GetDefaultEnabledTextColor(ABarItemControl: TdxBarItemControl;
      ASelected, AFlat: Boolean): TColor; override;
    procedure GetDisabledTextColors(ABarItemControl: TdxBarItemControl;
      ASelected, AFlat: Boolean; var AColor1, AColor2: TColor); override;
      // Conditions
    class function UseTextColorForItemArrow: Boolean; override;
      // Draw
    procedure DrawGlyphEmptyImage(ABarItemControl: TdxBarItemControl; DC: HDC;
      R: TRect; APaintType: TdxBarPaintType; ADown: Boolean); override;
    procedure DrawGlyphBorder(ABarItemControl: TdxBarItemControl; DC: HDC;
      ABrush: HBRUSH; NeedBorder: Boolean; R: TRect; PaintType: TdxBarPaintType;
      IsGlyphEmpty, Selected, Down, DrawDowned, ADroppedDown, IsSplit: Boolean); override;

    // Bar
      // Attributes
    function BarCaptionColor(ABarControl: TdxBarControl): COLORREF; override;
    class function NeedDoubleBuffer: Boolean; override;
      // Positions
    class procedure BarOffsetFloatingBarCaption(ABarControl: TdxBarControl;
      var X: Integer; var R: TRect); override;
      // Draw
    procedure BarDrawGrip(ABarControl: TdxBarControl; DC: HDC; R: TRect;
      AToolbarBrush: HBRUSH); override;
    procedure BarDrawMarkBackground(ABarControl: TdxBarControl; DC: HDC;
      ItemRect: TRect; AToolbarBrush: HBRUSH); override;

    // SubMenuControl
    procedure SubMenuControlDrawMarkSelection(ABarSubMenuControl: TdxBarSubMenuControl;
      ADC: HDC; const AMarkRect: TRect); override;

    // Hints
    function CreateHintViewInfo(ABarManager: TdxBarManager; AHintText: string;
      const AShortCut: string; AScreenTip: TdxBarScreenTip): TdxBarCustomHintViewInfo; override;

    property Bar[AIsVertical: Boolean]: TdxSkinElement read GetBar;
    property BarCustomize[AIsVertical: Boolean]: TdxSkinElement read GetBarCustomize;
    property BarDisabledTextColor: TdxSkinColor read GetBarDisabledTextColor;
    property BarDrag[AIsVertical: Boolean]: TdxSkinElement read GetBarDrag;
    property BarSeparator[AIsVertical: Boolean]: TdxSkinElement read GetBarSeparator;
    property Dock: TdxSkinElement read GetDock;
    property DockControlWindowButton: TdxSkinElement read GetDockControlWindowButton;
    property DockControlWindowButtonGlyph: TdxSkinElement read GetDockControlWindowButtonGlyph;
    property FloatingBar: TdxSkinElement read GetFloatingBar;
    property LinkBorderPainter: TdxSkinElement read GetLinkBorderPainter;
    property LinkSelected: TdxSkinElement read GetLinkSelected;
    property MainMenu[AIsVertical: Boolean]: TdxSkinElement read GetMainMenu;
    property MainMenuCustomize[AIsVertical: Boolean]: TdxSkinElement read GetMainMenuCustomize;
    property MainMenuDrag: TdxSkinElement read GetMainMenuDrag;
    property MainMenuLinkSelected: TdxSkinElement read GetMainMenuLinkSelected;
    property PopupMenu: TdxSkinElement read GetPopupMenu;
    property PopupMenuCheck: TdxSkinElement read GetPopupMenuCheck;
    property PopupMenuExpandButton: TdxSkinElement read GetPopupMenuExpandButton;
    property PopupMenuLinkSelected: TdxSkinElement read GetPopupMenuLinkSelected;
    property PopupMenuSeparator: TdxSkinElement read GetPopupMenuSeparator;
    property PopupMenuSideStrip: TdxSkinElement read GetPopupMenuSideStrip;
    property PopupMenuSideStripNonRecent: TdxSkinElement read GetPopupMenuSideStripNonRecent;
    property PopupMenuSplitButton: TdxSkinElement read GetPopupMenuSplitButton;
    property PopupMenuSplitButton2: TdxSkinElement read GetPopupMenuSplitButton2;
    property StatusBar: TdxSkinElement read GetStatusBar;
    property ScreenTipItem: TdxSkinColor read GetScreenTipItem;
    property ScreenTipSeparator: TdxSkinElement read GetScreenTipSeparator;
    property ScreenTipTitleItem: TdxSkinColor read GetScreenTipTitleItem;
    property ScreenTipWindow: TdxSkinElement read GetScreenTipWindow;
  public
    constructor Create(AData: Integer); override;

    // Common
      // Conditions
    class function IsFlatGlyphImage: Boolean; override;  
    class function IsFlatItemText: Boolean; override;
    function IsCustomSelectedTextColorExists(ABarItemControl: TdxBarItemControl): Boolean; override;
      // Sizes
    class function GetPopupWindowBorderWidth: Integer; override;
      // Draw
    procedure DrawItemBackgroundInSubMenu(const ADrawParams: TdxBarButtonLikeControlDrawParams; R: TRect); override;

    // BarManager
    function GripperSize(ABarControl: TdxBarControl): Integer; override;
    class function BorderSizeX: Integer; override;
    class function BorderSizeY: Integer; override;
    function FingersSize(ABarControl: TdxBarControl): Integer; override;
    class function SubMenuBeginGroupIndent: Integer; override;

    // Bar
      //Conditions
    class function BarCaptionTransparent: Boolean; override;
      // Sizes
    function BarBeginGroupSize: Integer; override;
    procedure BarBorderPaintSizes(ABarControl: TdxBarControl; var R: TRect); override;
    procedure BarBorderSizes(ABar: TdxBar; AStyle: TdxBarDockingStyle; var R: TRect); override;
    function BarMarkItemRect(ABarControl: TdxBarControl): TRect; override;
    function BarMarkRect(ABarControl: TdxBarControl): TRect; override;
    function MarkSizeX(ABarControl: TdxBarControl): Integer; override;
    function StatusBarBorderOffsets: TRect; override;
    class function StatusBarTopBorderSize: Integer; override;
    function StatusBarGripSize(ABarManager: TdxBarManager): TSize; override;
      // Draw
    procedure BarCaptionFillBackground(ABarControl: TdxBarControl; DC: HDC;
      R: TRect; AToolbarBrush: HBRUSH); override;
    procedure BarDrawBeginGroup(ABarControl: TCustomdxBarControl; DC: HDC;
      ABeginGroupRect: TRect; AToolbarBrush: HBRUSH; AHorz: Boolean); override;
    procedure BarDrawCloseButton(ABarControl: TdxBarControl; DC: HDC; R: TRect); override;
    procedure BarDrawDockedBarBorder(ABarControl: TdxBarControl; DC: HDC; R: TRect;
      AToolbarBrush: HBRUSH); override;
    procedure BarDrawFloatingBarBorder(ABarControl: TdxBarControl; DC: HDC;
      R, CR: TRect; AToolbarBrush: HBRUSH); override;
    procedure BarDrawFloatingBarCaption(ABarControl: TdxBarControl; DC: HDC;
      R, CR: TRect; AToolbarBrush: HBRUSH); override;
    procedure BarDrawMDIButton(ABarControl: TdxBarControl; AButton: TdxBarMDIButton;
      AState: Integer; DC: HDC; R: TRect); override;
    procedure BarDrawStatusBarBorder(ABarControl: TdxBarControl; DC: HDC;
      R: TRect; AToolbarBrush: HBRUSH); override;
    procedure BarMarkRectInvalidate(ABarControl: TdxBarControl); override;
    procedure StatusBarFillBackground(ABarControl: TdxBarControl; DC: HDC;
      ADestR, ASourceR, AWholeR: TRect; ABrush: HBRUSH; AColor: TColor); override;

    // DockControl
    procedure DockControlFillBackground(ADockControl: TdxDockControl;
      DC: HDC; ADestR, ASourceR, AWholeR: TRect; ABrush: HBRUSH; AColor: TColor); override;
    class function IsNativeBackground: Boolean; override;

    // CustomBar
      // Sizes
    class function BarDockedGetRowIndent: Integer; override;
    function ComboBoxArrowWidth(ABarControl: TCustomdxBarControl; cX: Integer): Integer; override;
      // Draw
    procedure BarDrawDockedBackground(ABarControl: TdxBarControl; DC: HDC;
      ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor); override;
    procedure BarDrawFloatingBackground(ABarControl: TCustomdxBarControl; DC: HDC;
      ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor); override;

    // DropDownListBox
    procedure DropDownListBoxDrawBorder(DC: HDC; AColor: TColor; ARect: TRect); override;

    // SubMenuControl
      // Conditions
    class function SubMenuControlHasBand: Boolean; override;
      // Sizes
    class function SubMenuControlArrowsOffset: Integer; override;
    function SubMenuControlBeginGroupRect(
      ABarSubMenuControl: TdxBarSubMenuControl; AControl: TdxBarItemControl;
      const AItemRect: TRect): TRect; override;
    function SubMenuControlBeginGroupSize: Integer; override;
    procedure SubMenuControlCalcDrawingConsts(ACanvas: TcxCanvas;
      ATextSize: Integer; out AMenuArrowWidth, AMarkSize: Integer); override;
    class function SubMenuControlDetachCaptionAreaSize(ABarSubMenuControl: TdxBarSubMenuControl): Integer; override;
    class procedure SubMenuControlOffsetDetachCaptionRect(ABarSubMenuControl: TdxBarSubMenuControl;
      var R: TRect); override;
      // Positions
    class function SubMenuControlGetItemTextIndent(const ADrawParams: TdxBarItemControlDrawParams): Integer; override;
      // Draw
    procedure SubMenuControlDrawBeginGroup(ABarSubMenuControl: TdxBarSubMenuControl;
      AControl: TdxBarItemControl; ACanvas: TcxCanvas; const ABeginGroupRect: TRect); override;
    procedure SubMenuControlDrawBorder(ABarSubMenuControl: TdxBarSubMenuControl;
      DC: HDC; R: TRect); override;
    procedure SubMenuControlDrawClientBorder(ABarSubMenuControl: TdxBarSubMenuControl;
      DC: HDC; const R: TRect; ABrush: HBRUSH); override;
    procedure SubMenuControlDrawBackground(ABarSubMenuControl: TdxBarSubMenuControl;
      ACanvas: TcxCanvas; ARect: TRect; ABrush: HBRUSH; AColor: TColor); override;
    procedure SubMenuControlDrawDetachCaption(ABarSubMenuControl: TdxBarSubMenuControl;
      DC: HDC; R: TRect); override;
    procedure SubMenuControlDrawMarkContent(ABarSubMenuControl: TdxBarSubMenuControl;
      DC: HDC; R: TRect; ASelected: Boolean); override;
    procedure SubMenuControlDrawSeparator(ACanvas: TcxCanvas; const ARect: TRect); override;
    procedure SubMenuControlDrawSeparatorBackground(ACanvas: TcxCanvas; const ARect: TRect);

    // Mark
      // Draw
    procedure BarDrawMark(ABarControl: TdxBarControl; DC: HDC; MarkR: TRect); override;
    procedure BarDrawMarkElements(ABarControl: TdxBarControl; DC: HDC;
      ItemRect: TRect); override;

    // QuickCustItem
        // Conditions
    class function IsQuickControlPopupOnRight: Boolean; override;

    // Button Control
      // Conditions
    function IsButtonControlArrowBackgroundOpaque(const ADrawParams: TdxBarButtonLikeControlDrawParams): Boolean; override;
    function IsButtonControlArrowDrawSelected(const ADrawParams: TdxBarButtonLikeControlDrawParams): Boolean; override;
    function IsDropDownRepaintNeeded: Boolean; override;
      // Sizes
    class procedure CorrectButtonControlDefaultHeight(var DefaultHeight: Integer); override;
    class procedure CorrectButtonControlDefaultWidth(var DefaultWidth: Integer); override;
      // Draw
    procedure DrawButtonControlArrowBackground(const ADrawParams: TdxBarButtonLikeControlDrawParams;
      var R1: TRect; ABrush: HBRUSH); override;

    // ColorCombo
      // Conditions
    function ColorComboHasCompleteFrame: Boolean; override;
      // Sizes
    function GetCustomColorButtonIndents(APaintType: TdxBarPaintType): TRect; override;
    function GetCustomColorButtonWidth(APaintType: TdxBarPaintType; const ARect: TRect): Integer; override;
      // Draw
    procedure ColorComboDrawCustomButton(const ADrawParams: TdxBarColorComboControlDrawParams; ARect: TRect); override;
    procedure ColorComboDrawCustomButtonAdjacentZone(const ADrawParams: TdxBarColorComboControlDrawParams; ARect: TRect); override;

    // EditControl
      // Conditions
    class function EditControlCaptionBackgroundIsOpaque(const ADrawParams: TdxBarEditLikeControlDrawParams): Boolean; override;
    class function EditControlCaptionRightIndentIsOpaque(const ADrawParams: TdxBarEditLikeControlDrawParams): Boolean; override;
      // Sizes
    class function EditControlBorderOffsets(APaintType: TdxBarPaintType): TRect; override;
      // Draw
    procedure EditControlDrawBackground(const ADrawParams: TdxBarEditLikeControlDrawParams); override;
    procedure EditControlDrawBorder(const ADrawParams: TdxBarEditLikeControlDrawParams; var ARect: TRect); override;
    procedure EditControlDrawSelectionFrame(const ADrawParams: TdxBarEditLikeControlDrawParams; const ARect: TRect); override;
      // Select EditControl indents
    class function EditControlCaptionAbsoluteLeftIndent(const ADrawParams: TdxBarEditLikeControlDrawParams): Integer; override;

    // CustomCombo
    class procedure CustomComboDrawItem(ABarCustomCombo: TdxBarCustomCombo;
      ACanvas: TCanvas; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState;
      AInteriorIsDrawing: Boolean); override;

    // ComboControl
      // Sizes
    class function ComboControlArrowOffset: Integer; override;
      // Draw
    procedure ComboControlDrawArrowButton(const ADrawParams: TdxBarEditLikeControlDrawParams; ARect: TRect; AInClientArea: Boolean); override;

    // DateNavigator
      // Conditions
    class function IsDateNavigatorFlat: Boolean; override;
      // Attributes
    function DateNavigatorHeaderColor: TColor; override;
      // Draw
    procedure DateNavigatorDrawButton(ABarItem: TdxBarItem;
      DC: HDC; R: TRect; const ACaption: string; APressed: Boolean); override;

    // InPlaceSubItemControl
      // Conditions
    function InPlaceSubItemControlIsArrowSelected(const ADrawParams: TdxBarInPlaceSubItemControlDrawParams): Boolean; override;
      // Draw
    procedure InPlaceSubItemControlDrawBackground(const ADrawParams: TdxBarInPlaceSubItemControlDrawParams; ARect: TRect); override;

    // SpinEditControl
      // Sizes
    function GetSpinEditButtonWidth(APaintType: TdxBarPaintType; const ARect: TRect): Integer; override;
    function GetSpinEditButtonIndents(APaintType: TdxBarPaintType): TRect; override;
      // Draw
    procedure SpinEditControlDrawButton(const ADrawParams: TdxBarSpinEditDrawParams; ARect: TRect; AButtonIndex: Integer); override;
    procedure SpinEditControlDrawButtonsAdjacentZone(const ADrawParams: TdxBarSpinEditDrawParams; const ARect: TRect); override;
      // Others
    procedure CalculateSpinEditParts(const ADrawParams: TdxBarSpinEditDrawParams;
      var AParts: array of TRect; const AItemRect: TRect); override;
    procedure SpinEditCorrectFrameRect(const ADrawParams: TdxBarItemControlDrawParams; var ARect: TRect); override;

    // ProgressControl
      // Sizes
    function ProgressControlBarHeight(ABarItemControl: TdxBarItemControl): Integer; override;
    class function ProgressControlIndent(const ADrawParams: TdxBarItemControlDrawParams): Integer; override;
      // Draw
    procedure ProgressControlDrawBackground(const ADrawParams: TdxBarItemControlDrawParams; var BarR: TRect); override;
    procedure ProgressControlFillContent(const ADrawParams: TdxBarItemControlDrawParams; const R: TRect; ABarBrush: HBRUSH); override;

    // StaticControl
      // Sizes
    function StaticControlGetBorderOffsets(AParent: TCustomdxBarControl; ABorderStyle: TdxBarStaticBorderStyle): TRect; override;
      // Draw
    procedure DrawStaticBackground(const ADrawParams: TdxBarStaticLikeControlDrawParams; ARect: TRect); override;
    procedure DrawStaticBorder(const ADrawParams: TdxBarStaticLikeControlDrawParams; var ARect: TRect); override;

    // Separator
      // Sizes
    function SubMenuGetSeparatorSize: Integer; override;
      // Draw
    procedure DrawSeparatorGlyphAndCaption(const ADrawParams: TdxBarSeparatorControlDrawParams; const ARect: TRect); override;

    // ScreenTips
      // Attributes
    function ScreenTipGetDescriptionTextColor: TColor; override;
    function ScreenTipGetTitleTextColor: TColor; override;
      // Size
    function ScreenTipGetFooterLineSize: Integer; override;
      // Draw
    procedure ScreenTipDrawBackground(ACanvas: TcxCanvas; ARect: TRect); override;
    procedure ScreenTipDrawFooterLine(ACanvas: TcxCanvas; const ARect: TRect); override;
  end;

implementation

uses
  Math, dxOffice11, dxBarSkinConsts, dxSkinsStrs;

type
  TdxBarAccess = class(TdxBar);
  TCustomdxBarControlAccess = class(TCustomdxBarControl);
  TdxBarControlAccess = class(TdxBarControl);
  TdxBarSubMenuControlAccess = class(TdxBarSubMenuControl);
  TdxBarItemControlAccess = class(TdxBarItemControl);
  TdxBarEditControlAccess = class(TdxBarEditControl);
  TdxBarDockControlAccess = class(TdxBarDockControl);

{TdxBarSkinPainter}

constructor TdxBarSkinPainter.Create(AData: Integer);
begin
  inherited Create(AData);
  FSkinPainter := TcxCustomLookAndFeelPainterClass(AData);
end;

class function TdxBarSkinPainter.IsFlatGlyphImage: Boolean;
begin
  Result := True;
end;

class function TdxBarSkinPainter.IsFlatItemText: Boolean;
begin
  Result := True;
end;

function TdxBarSkinPainter.IsCustomSelectedTextColorExists(ABarItemControl: TdxBarItemControl): Boolean;
begin
  Result := IsBarElementSkinned(ABarItemControl.Parent) and (GetSkinElementTextColorHot(GetTextColorElement(ABarItemControl.Parent)) <> nil);
end;

class function TdxBarSkinPainter.GetPopupWindowBorderWidth: Integer;
begin
  Result := 1;
end;

procedure TdxBarSkinPainter.DrawItemBackgroundInSubMenu(const ADrawParams: TdxBarButtonLikeControlDrawParams; R: TRect);
var
  ASkinElement: TdxSkinElement;
begin
  with ADrawParams do
  begin
    R := BarItemControl.ItemBounds;  // because quickcontrolitem draw before
    DrawBackground(BarItemControl, Canvas.Handle, R, 0, False);
    if DrawSelected then
    begin
      if IsDropDown and SplitDropDown then
      begin
        ASkinElement := PopupMenuSplitButton;
        Dec(R.Right, ArrowSize.cx);
      end
      else
        ASkinElement := PopupMenuLinkSelected;
      DrawSkinElement(ASkinElement, Canvas.Handle, R, 0, ButtonLikeControlGetState(ADrawParams));
    end;
  end;
end;

function TdxBarSkinPainter.GripperSize(ABarControl: TdxBarControl): Integer;
var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  if ABarControlAccess.IsMainMenu then
    Result := GetSkinElementSize(MainMenuDrag).cx
  else
    Result := GetSkinElementSize(BarDrag[ABarControlAccess.IsRealVertical]).cx;
end;

class function TdxBarSkinPainter.BorderSizeX: Integer;
begin
  Result := 2;
end;

class function TdxBarSkinPainter.BorderSizeY: Integer;
begin
  Result := 2;
end;

function TdxBarSkinPainter.FingersSize(ABarControl: TdxBarControl): Integer;
begin
  Result := GripperSize(ABarControl);
end;

class function TdxBarSkinPainter.SubMenuBeginGroupIndent: Integer;
begin
  Result := TdxBarFlatPainter.SubMenuBeginGroupIndent;
end;

class function TdxBarSkinPainter.BarCaptionTransparent: Boolean;
begin
  Result := True; // TdxBarXPPainter
end;

function TdxBarSkinPainter.BarBeginGroupSize: Integer;
begin
  Result := GetSkinElementSize(BarSeparator[False]).cx;
end;

procedure TdxBarSkinPainter.BarBorderPaintSizes(ABarControl: TdxBarControl; var R: TRect);
var
  ABarControlAccess: TdxBarControlAccess;
  ABarAccess: TdxBarAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  ABarAccess := TdxBarAccess(ABarControlAccess.Bar);
  BarBorderSizes(ABarAccess, ABarAccess.DockingStyle, R);
  if ABarControlAccess.CanMoving then
    if ABarControlAccess.Vertical then
      Inc(R.Top, FingersSize(ABarControlAccess))
    else
      Inc(R.Left, FingersSize(ABarControlAccess));
end;

procedure TdxBarSkinPainter.BarBorderSizes(ABar: TdxBar; AStyle: TdxBarDockingStyle; var R: TRect);
begin
  R := cxEmptyRect;
  if IsBarElementSkinned(ABar.Control) then
    R := GetBarElement(ABar.Control).ContentOffset.Rect;
end;

function TdxBarSkinPainter.BarMarkItemRect(ABarControl: TdxBarControl): TRect;
var
  ABarControlAccess: TdxBarControlAccess;
  ABarAccess: TdxBarAccess;
  ABorderOffsets: TRect;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  ABarAccess := TdxBarAccess(ABarControlAccess.Bar);

  Result := inherited BarMarkItemRect(ABarControl);
  ABorderOffsets := cxEmptyRect;

  if (ABarControlAccess.DockingStyle <> dsNone) and
    not ABarAccess.IsStatusBar then
  begin
    BarBorderSizes(ABarAccess, ABarAccess.DockingStyle, ABorderOffsets);
    if ABarControl.IsRealVertical then
    begin
      OffsetRect(Result, 0, ABorderOffsets.Bottom);
      Result := cxRectInflate(Result, ABorderOffsets.Left, 0, ABorderOffsets.Right, 0);
    end
    else
    begin
      OffsetRect(Result, ABorderOffsets.Right, 0);
      Result := cxRectInflate(Result, 0, ABorderOffsets.Top, 0, ABorderOffsets.Bottom);
    end;
  end;

  if ABarAccess.IsStatusBar then
  begin
    ABorderOffsets := StatusBarBorderOffsets;
    ABorderOffsets.Left := 0;
    Result := cxRectContent(Result, cxRectInvert(ABorderOffsets));
  end;
end;

function TdxBarSkinPainter.BarMarkRect(ABarControl: TdxBarControl): TRect;
var
  ABarControlAccess: TdxBarControlAccess;
  ABarAccess: TdxBarAccess;
  ABorderOffsets: TRect;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  ABarAccess := TdxBarAccess(ABarControlAccess.Bar);
  if ABarAccess.BorderStyle = bbsNone then
  begin
    Result := inherited BarMarkItemRect(ABarControl);
    if not ABarAccess.IsStatusBar then
    begin
      BarBorderSizes(ABarAccess, ABarAccess.DockingStyle, ABorderOffsets);
      if ABarControlAccess.Vertical then
        Inc(Result.Top, ABorderOffsets.Bottom)
      else
        Inc(Result.Left, ABorderOffsets.Right);
    end;
  end
  else
    Result := BarMarkItemRect(ABarControl);
end;

function TdxBarSkinPainter.MarkSizeX(ABarControl: TdxBarControl): Integer;
var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  Result := GetSkinElementSize(GetBarMarkElement(ABarControlAccess.IsMainMenu, False)).cx;
end;

function TdxBarSkinPainter.StatusBarBorderOffsets: TRect;
begin
  if StatusBar <> nil then
    Result := StatusBar.ContentOffset.Rect
  else
    Result := inherited StatusBarBorderOffsets;
end;

class function TdxBarSkinPainter.StatusBarTopBorderSize: Integer;
begin
  Result := 0;
end;

function TdxBarSkinPainter.StatusBarGripSize(ABarManager: TdxBarManager): TSize;
begin
  Result := FSkinPainter.SizeGripSize;
end;

procedure TdxBarSkinPainter.BarCaptionFillBackground(ABarControl: TdxBarControl; DC: HDC;
  R: TRect; AToolbarBrush: HBRUSH);
begin
  if FloatingBar <> nil then
    FillRectByColor(DC, R, FloatingBar.Color)
  else
    inherited;
end;

procedure TdxBarSkinPainter.BarDrawBeginGroup(ABarControl: TCustomdxBarControl;
  DC: HDC; ABeginGroupRect: TRect; AToolbarBrush: HBRUSH; AHorz: Boolean);
begin
  TdxBarControlAccess(ABarControl).FillBackground(DC, ABeginGroupRect, 0, clNone, True);
  DrawSkinElement(BarSeparator[AHorz], DC, ABeginGroupRect);
end;

procedure TdxBarSkinPainter.BarDrawCloseButton(ABarControl: TdxBarControl; DC: HDC; R: TRect);
begin
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
    BarCaptionFillBackground(ABarControl, BarCanvas.Handle, R, 0);
    DrawFloatingBarCaptionButton(BarCanvas.Handle, R, 2, TdxBarControlAccess(ABarControl).CloseButtonState);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxBarSkinPainter.BarDrawDockedBarBorder(ABarControl: TdxBarControl; DC: HDC; R: TRect;
  AToolbarBrush: HBRUSH);
var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(ABarControlAccess.ClientBounds), roSubtract);
    InternalDrawDockedBarBackground(ABarControl, BarCanvas, R, False);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxBarSkinPainter.BarDrawFloatingBarBorder(ABarControl: TdxBarControl; DC: HDC;
  R, CR: TRect; AToolbarBrush: HBRUSH);
var
  ABorderKind: TcxBorder;
begin
  if FloatingBar <> nil then
  begin
    for ABorderKind := Low(TcxBorder) to High(TcxBorder) do
      FloatingBar.Borders.Items[ABorderKind].Draw(DC, R);
    InflateRect(R, -1, -1);
    FrameRectByColor(DC, R, FloatingBar.Color);
  end
  else
    inherited;
end;

procedure TdxBarSkinPainter.BarDrawFloatingBarCaption(ABarControl: TdxBarControl; DC: HDC;
  R, CR: TRect; AToolbarBrush: HBRUSH);
begin
  if FloatingBar <> nil then
    AToolbarBrush := CreateSolidBrush(FloatingBar.Color)
  else
    AToolbarBrush := 0;
  inherited;
  DeleteObject(AToolbarBrush);
end;

procedure TdxBarSkinPainter.BarDrawMDIButton(ABarControl: TdxBarControl;
  AButton: TdxBarMDIButton; AState: Integer; DC: HDC; R: TRect);
const
  SkinElementIndexMap: array[TdxBarMDIButton] of Integer = (7, 0, 2); 

  function GetSkinElementState: TdxSkinElementState;
  begin
    case AState of
      DXBAR_HOT:
        Result := esHot;
      DXBAR_PRESSED:
        Result := esPressed;
    else
      Result := esNormal;
    end;
  end;

begin
  TdxBarControlAccess(ABarControl).FillBackground(DC, R, 0, clNone, True);
  if GetSkinElementState in [esHot, esPressed] then
    DrawSkinElement(LinkSelected, DC, R, 0, GetSkinElementState);
  DrawSkinElement(DockControlWindowButtonGlyph, DC, R, SkinElementIndexMap[AButton]);
end;

procedure TdxBarSkinPainter.BarDrawStatusBarBorder(ABarControl: TdxBarControl; DC: HDC;
  R: TRect; AToolbarBrush: HBRUSH);
begin
  DrawSkinElementBorders(StatusBar, DC, R);
end;

procedure TdxBarSkinPainter.BarMarkRectInvalidate(ABarControl: TdxBarControl);
begin
  inherited;
  if TdxBarControlAccess(ABarControl).DockingStyle <> dsNone then       // TdxOffice11Painter
    SendMessage(ABarControl.Handle, WM_NCPAINT, 0, 0);
end;

procedure TdxBarSkinPainter.StatusBarFillBackground(ABarControl: TdxBarControl; DC: HDC;
  ADestR, ASourceR, AWholeR: TRect; ABrush: HBRUSH; AColor: TColor);
begin
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(ADestR), roIntersect);
    OffsetRect(AWholeR, -(ASourceR.Left - ADestR.Left), -(ASourceR.Top - ADestR.Top));
    BarFillParentBackground(ABarControl, BarCanvas.Handle, AWholeR, AWholeR, 0, clNone);
    DrawSkinElement(StatusBar, BarCanvas.Handle, AWholeR);
  finally
    BarCanvas.EndPaint;
  end;  
end;

procedure TdxBarSkinPainter.DockControlFillBackground(ADockControl: TdxDockControl;
  DC: HDC; ADestR, ASourceR, AWholeR: TRect; ABrush: HBRUSH; AColor: TColor);

  procedure FillBackgroundTempBitmap(ABitmap: TBitmap);
  begin
    ABitmap.Width := cxRectWidth(AWholeR);
    ABitmap.Height := cxRectHeight(AWholeR);
    DrawSkinElement(Dock, ABitmap.Canvas.Handle, AWholeR);
  end;

var
  ADockControlAccess: TdxBarDockControlAccess;
begin
  ADockControlAccess := TdxBarDockControlAccess(ADockControl);
  if ADockControlAccess.BackgroundTempBitmap.Empty then
    FillBackgroundTempBitmap(ADockControlAccess.BackgroundTempBitmap);
  cxBitBlt(DC, ADockControlAccess.BackgroundTempBitmap.Canvas.Handle, ADestR, ASourceR.TopLeft, SRCCOPY);
end;

class function TdxBarSkinPainter.IsNativeBackground: Boolean;
begin
  Result := True; // TdxBarXPPainter
end;

class function TdxBarSkinPainter.BarDockedGetRowIndent: Integer;
begin
  Result := 1
end;

function TdxBarSkinPainter.ComboBoxArrowWidth(ABarControl: TCustomdxBarControl; cX: Integer): Integer;
begin
  Result := cX + 11;
end;

procedure TdxBarSkinPainter.BarDrawDockedBackground(ABarControl: TdxBarControl; DC: HDC;
  ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor);
var
  AWholeR: TRect;
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  if (ABarControlAccess.Bar.BorderStyle = bbsNone) or
    ABarControlAccess.IsBackgroundBitmap then
    inherited
  else
  begin
    BarCanvas.BeginPaint(DC);
    try
      BarCanvas.SetClipRegion(TcxRegion.Create(ADestR), roIntersect);
      AWholeR := Rect(0, 0, ABarControl.Width, ABarControl.Height);
      OffsetRect(AWholeR, -(ASourceR.Left - ADestR.Left), -(ASourceR.Top - ADestR.Top));
      InternalDrawDockedBarBackground(ABarControl, BarCanvas, AWholeR, not cxRectIsEqual(ASourceR, ADestR));
    finally
      BarCanvas.EndPaint;
    end;
  end;
end;

procedure TdxBarSkinPainter.BarDrawFloatingBackground(
  ABarControl: TCustomdxBarControl; DC: HDC; ADestR, ASourceR: TRect;
  ABrush: HBRUSH; AColor: TColor);
begin
  if TdxBarControlAccess(ABarControl).IsBackgroundBitmap then
    inherited
  else
  begin
    BarCanvas.BeginPaint(DC);
    try
      BarCanvas.SetClipRegion(TcxRegion.Create(ADestR), roIntersect);
      DrawSkinElement(FloatingBar, BarCanvas.Handle, ABarControl.ClientRect);
    finally
      BarCanvas.EndPaint;
    end;
  end;
end;

procedure TdxBarSkinPainter.DropDownListBoxDrawBorder(DC: HDC; AColor: TColor; ARect: TRect);
begin
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.FrameRect(ARect, FSkinPainter.GetContainerBorderColor(False));
  finally
    BarCanvas.EndPaint;
  end;
end;

class function TdxBarSkinPainter.SubMenuControlHasBand: Boolean;
begin
  Result := True;
end;

class function TdxBarSkinPainter.SubMenuControlArrowsOffset: Integer;
begin
  Result := 1;  // TdxBarXPPainter
end;

function TdxBarSkinPainter.SubMenuControlBeginGroupRect(
  ABarSubMenuControl: TdxBarSubMenuControl; AControl: TdxBarItemControl;
  const AItemRect: TRect): TRect;
begin
  Result := AItemRect;
  Result.Bottom := Result.Top;
  Dec(Result.Top, TdxBarSubMenuControlAccess(ABarSubMenuControl).BeginGroupSize);  // TdxBarXPPainter
end;

function TdxBarSkinPainter.SubMenuControlBeginGroupSize: Integer;
begin
  Result := GetSkinElementSize(PopupMenuSeparator).cy;
end;

procedure TdxBarSkinPainter.SubMenuControlCalcDrawingConsts(ACanvas: TcxCanvas;
  ATextSize: Integer; out AMenuArrowWidth, AMarkSize: Integer);
begin
  inherited; 
  if PopupMenuExpandButton <> nil then
    AMarkSize := GetSkinElementSize(PopupMenuExpandButton).cy;
end;

class function TdxBarSkinPainter.SubMenuControlDetachCaptionAreaSize(ABarSubMenuControl: TdxBarSubMenuControl): Integer;
begin
  Result := TdxBarSubMenuControlAccess(ABarSubMenuControl).DetachCaptionSize + 1;// TdxBarXPPainter
end;

class procedure TdxBarSkinPainter.SubMenuControlOffsetDetachCaptionRect(ABarSubMenuControl: TdxBarSubMenuControl;
  var R: TRect);
begin
  InflateRect(R, -2, -2);// TdxBarXPPainter
end;

class function TdxBarSkinPainter.SubMenuControlGetItemTextIndent(const ADrawParams: TdxBarItemControlDrawParams): Integer;
begin
  Result := TdxBarFlatPainter.SubMenuControlGetItemTextIndent(ADrawParams);
end;

procedure TdxBarSkinPainter.SubMenuControlDrawBeginGroup(ABarSubMenuControl: TdxBarSubMenuControl;
  AControl: TdxBarItemControl; ACanvas: TcxCanvas; const ABeginGroupRect: TRect);
var
  ARect: TRect;
begin
  with ABeginGroupRect do
    ARect := cxRect(Left + SubMenuBeginGroupIndent + TdxBarItemControlAccess(AControl).TextAreaOffset,
      Bottom - SubMenuGetSeparatorSize,
      Right,
      Bottom);
  DrawBackground(AControl, ACanvas.Handle, ABeginGroupRect, 0, False);
  DrawSkinElement(PopupMenuSeparator, ACanvas.Handle, ARect);
end;

procedure TdxBarSkinPainter.SubMenuControlDrawBorder(ABarSubMenuControl: TdxBarSubMenuControl;
  DC: HDC; R: TRect);
var
  AContentRect: TRect;
  ABarSubmenuControlAccess: TdxBarSubMenuControlAccess;
begin
  ABarSubmenuControlAccess := TdxBarSubMenuControlAccess(ABarSubMenuControl);
  BarCanvas.BeginPaint(DC);
  try
    AContentRect := cxRectOffset(ABarSubmenuControlAccess.ContentRect, ABarSubmenuControlAccess.GetClientOffset.TopLeft);
    BarCanvas.ExcludeClipRect(AContentRect);
    DrawSkinElement(PopupMenu, DC, R);
    SubMenuControlDrawDetachCaption(ABarSubMenuControl, DC, ABarSubmenuControlAccess.DetachCaptionRect);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxBarSkinPainter.SubMenuControlDrawClientBorder(ABarSubMenuControl: TdxBarSubMenuControl;
  DC: HDC; const R: TRect; ABrush: HBRUSH);
begin
  // do nothing
end;

procedure TdxBarSkinPainter.SubMenuControlDrawBackground(ABarSubMenuControl: TdxBarSubMenuControl;
  ACanvas: TcxCanvas; ARect: TRect; ABrush: HBRUSH; AColor: TColor);
var
  ASubMenuControlAccess: TdxBarSubMenuControlAccess;
  ASideStripElement: TdxSkinElement;
  AContentRect, ABarRect, ABandRect, ASeparatorRect: TRect;
begin
  if not TdxBarSubMenuControlAccess(ABarSubMenuControl).GetBackgroundBitmap.Empty then
    inherited
  else
  begin
    ASubMenuControlAccess := TdxBarSubMenuControlAccess(ABarSubMenuControl);
    AContentRect := ASubMenuControlAccess.ContentRect;

    ABarRect := ASubMenuControlAccess.BarRect;

    ABandRect := Rect(ABarRect.Right, AContentRect.Top,
      ABarRect.Right + ASubMenuControlAccess.BandSize + ASubMenuControlAccess.GetIndent2, AContentRect.Bottom);

    ASeparatorRect := Rect(ABandRect.Right, AContentRect.Top,
      ABandRect.Right + 2, AContentRect.Bottom);   //  dxBar.MenuSeparatorSize = 2

    ABandRect.Right := ABandRect.Right + cxRectWidth(ASeparatorRect);

    if ASubMenuControlAccess.NonRecent then
      ASideStripElement := PopupMenuSideStripNonRecent
    else
      ASideStripElement := PopupMenuSideStrip;

    DrawSkinElement(PopupMenu, ACanvas.Handle, cxRectInflate(ASubMenuControlAccess.ContentRect,
      SubMenuControlBorderSize, SubMenuControlBorderSize));
    DrawSkinElement(ASideStripElement, ACanvas.Handle, ABandRect);
  end;
end;

procedure TdxBarSkinPainter.SubMenuControlDrawDetachCaption(ABarSubMenuControl: TdxBarSubMenuControl;
  DC: HDC; R: TRect);
begin
  DrawSkinElement(PopupMenuSeparator, DC, R);
end;

procedure TdxBarSkinPainter.SubMenuControlDrawMarkContent(ABarSubMenuControl: TdxBarSubMenuControl;
  DC: HDC; R: TRect; ASelected: Boolean);
begin
  DrawSkinElement(PopupMenuExpandButton, DC, R);
end;

procedure TdxBarSkinPainter.SubMenuControlDrawSeparator(
  ACanvas: TcxCanvas; const ARect: TRect);
begin
  if PopupMenuSeparator = nil then
    inherited SubMenuControlDrawSeparator(ACanvas, ARect)
  else
  begin
    if PopupMenuSeparator.IsAlphaUsed then
      SubMenuControlDrawSeparatorBackground(ACanvas, ARect);
    DrawSkinElement(PopupMenuSeparator, ACanvas.Handle, ARect);
  end;
end;

procedure TdxBarSkinPainter.SubMenuControlDrawSeparatorBackground(
  ACanvas: TcxCanvas; const ARect: TRect);
var
  R: TRect;
  APopupElement: TdxSkinElement;
begin
  APopupElement := PopupMenu;
  if APopupElement <> nil then
  begin
    ACanvas.SaveClipRegion;
    try
      ACanvas.SetClipRegion(TcxRegion.Create(ARect), roIntersect);
      with APopupElement.Image.Margins.Rect do
        R := Rect(ARect.Left - Max(Left, APopupElement.Borders.Left.Thin),
          ARect.Top - Max(Top, APopupElement.Borders.Top.Thin),
          ARect.Right + Max(Right, APopupElement.Borders.Right.Thin),
          ARect.Bottom + Max(Bottom, APopupElement.Borders.Bottom.Thin));
      DrawSkinElementContent(APopupElement, ACanvas.Handle, R);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;
end;

procedure TdxBarSkinPainter.BarDrawMark(ABarControl: TdxBarControl; DC: HDC; MarkR: TRect);
begin
  BarCanvas.BeginPaint(DC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(MarkR), roIntersect);
    BarCaptionFillBackground(ABarControl, BarCanvas.Handle, MarkR, 0);
    DrawFloatingBarCaptionButton(BarCanvas.Handle, MarkR, 6, TdxBarControlAccess(ABarControl).MarkState);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxBarSkinPainter.BarDrawMarkElements(ABarControl: TdxBarControl;
  DC: HDC; ItemRect: TRect);
begin
  // todo
end;

class function TdxBarSkinPainter.IsQuickControlPopupOnRight: Boolean;
begin
  Result := True; // TdxBarXPPainter
end;

function TdxBarSkinPainter.IsButtonControlArrowBackgroundOpaque(const ADrawParams: TdxBarButtonLikeControlDrawParams): Boolean;
begin
  Result := False;
end;

function TdxBarSkinPainter.IsButtonControlArrowDrawSelected(const ADrawParams: TdxBarButtonLikeControlDrawParams): Boolean;
begin
  Result := False;
end;

function TdxBarSkinPainter.IsDropDownRepaintNeeded: Boolean;
begin
  Result := False;
end;

class procedure TdxBarSkinPainter.CorrectButtonControlDefaultHeight(var DefaultHeight: Integer);
begin
  Inc(DefaultHeight, 5);
end;

class procedure TdxBarSkinPainter.CorrectButtonControlDefaultWidth(var DefaultWidth: Integer);
begin
  Inc(DefaultWidth, 9);
end;

procedure TdxBarSkinPainter.DrawButtonControlArrowBackground(
  const ADrawParams: TdxBarButtonLikeControlDrawParams;
  var R1: TRect; ABrush: HBRUSH);
var
  ASkinElement: TdxSkinElement;
begin
  if not ButtonLikeDrawArrowFadingElement(ADrawParams, R1) then
  begin
    inherited DrawButtonControlArrowBackground(ADrawParams, R1, ABrush);
    if ((ADrawParams.PaintType = ptMenu) or not ADrawParams.DroppedDown) and
        (ADrawParams.DrawSelected or (ADrawParams.PaintType <> ptMenu) and
        ADrawParams.Downed)
    then
    begin
      if ADrawParams.PaintType = ptMenu then
        ASkinElement := PopupMenuSplitButton2
      else
        ASkinElement := LinkSelected;
      DrawArrowButtonElement(ASkinElement, ADrawParams.Canvas, R1, 0,
        ButtonLikeControlGetState(ADrawParams));
    end;
  end;
end;

function TdxBarSkinPainter.ColorComboHasCompleteFrame: Boolean;
begin
  Result := True;
end;

function TdxBarSkinPainter.GetCustomColorButtonIndents(APaintType: TdxBarPaintType): TRect;
begin
  Result := EditControlBorderOffsets(APaintType);
  Result.Left := 0;
end;

function TdxBarSkinPainter.GetCustomColorButtonWidth(APaintType: TdxBarPaintType; const ARect: TRect): Integer;
begin
  Result := 17;
end;

procedure TdxBarSkinPainter.ColorComboDrawCustomButton(const ADrawParams: TdxBarColorComboControlDrawParams; ARect: TRect);

  function GetState: TcxButtonState;
  begin
    with ADrawParams do
      if not Enabled then
        Result := cxbsDisabled
      else
        if IsPressed then
          Result := cxbsPressed
        else
          if DrawSelected then
            Result := cxbsHot
          else
            Result := cxbsNormal;
  end;

begin
  FSkinPainter.DrawEditorButton(ADrawParams.Canvas, ARect, cxbkEllipsisBtn, GetState);
end;

procedure TdxBarSkinPainter.ColorComboDrawCustomButtonAdjacentZone(const ADrawParams: TdxBarColorComboControlDrawParams; ARect: TRect);
begin
  FillRectByColor(ADrawParams.Canvas.Handle, cxRectContent(ARect, GetCustomColorButtonIndents(ADrawParams.PaintType)), EditGetBkColor(ADrawParams));
end;

class function TdxBarSkinPainter.EditControlCaptionBackgroundIsOpaque(const ADrawParams: TdxBarEditLikeControlDrawParams): Boolean;
begin
  Result := False;
end;

class function TdxBarSkinPainter.EditControlCaptionRightIndentIsOpaque(const ADrawParams: TdxBarEditLikeControlDrawParams): Boolean;
begin
  Result := EditControlCaptionBackgroundIsOpaque(ADrawParams);
end;

class function TdxBarSkinPainter.EditControlBorderOffsets(APaintType: TdxBarPaintType): TRect;
begin
  if APaintType = ptMenu then
    Result := Rect(1, 4, 4, 4)
  else
    Result := dxBarFlatPainter.EditControlBorderOffsets(APaintType);
end;

procedure TdxBarSkinPainter.EditControlDrawBackground(const ADrawParams: TdxBarEditLikeControlDrawParams);
begin
  with ADrawParams do
  begin
    Canvas.SaveClipRegion;
    Canvas.ExcludeClipRect(EditControlGetContentRect(PaintType, TdxBarEditControlAccess(BarEditControl).GetEditRect));
    DrawBackground(BarEditControl, Canvas.Handle, BarEditControl.ItemBounds, 0, False);
    Canvas.RestoreClipRegion;
  end;
end;

procedure TdxBarSkinPainter.EditControlDrawBorder(const ADrawParams: TdxBarEditLikeControlDrawParams; var ARect: TRect);
begin
  with ADrawParams do
  begin
    ARect := cxRectContent(ARect, EditControlBorderOffsets(PaintType));                     // TODO cxProgress: TdxBarItemControlAccess(BarEditControl).CanSelect
    if not IsTransparent or (IsTransparent and DrawSelected and not (PaintType = ptMenu)) then
      FrameRectByColor(Canvas.Handle, cxRectInflate(ARect, 1, 1), FSkinPainter.GetContainerBorderColor(DrawSelected and (PaintType <> ptMenu)));
  end;
end;

procedure TdxBarSkinPainter.EditControlDrawSelectionFrame(const ADrawParams: TdxBarEditLikeControlDrawParams; const ARect: TRect);
const
  State: array [Boolean] of TdxSkinElementState = (esDisabled, esHot);
var
  AExcludedRect: TRect;
begin
  with ADrawParams do
  begin
    Canvas.SaveClipRegion;
    AExcludedRect := EditControlGetContentRect(PaintType, TdxBarEditControlAccess(BarEditControl).GetEditRect);
    if IsTransparent and DrawSelected and (PaintType = ptMenu) then
      InflateRect(AExcludedRect, 1, 1);
    Canvas.ExcludeClipRect(AExcludedRect);
    try
      DrawSkinElement(PopupMenuLinkSelected, Canvas.Handle, ARect, 0, State[Enabled]);
    finally
      Canvas.RestoreClipRegion;
    end;
  end;
end;

class function TdxBarSkinPainter.EditControlCaptionAbsoluteLeftIndent(const ADrawParams: TdxBarEditLikeControlDrawParams): Integer;
begin
  Result := TdxBarOffice11Painter.EditControlCaptionAbsoluteLeftIndent(ADrawParams);
end;

class procedure TdxBarSkinPainter.CustomComboDrawItem(ABarCustomCombo: TdxBarCustomCombo;
  ACanvas: TCanvas; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState;
  AInteriorIsDrawing: Boolean);
begin
  TdxBarFlatPainter.CustomComboDrawItem(ABarCustomCombo, ACanvas, AIndex, ARect, AState, AInteriorIsDrawing);
end;

class function TdxBarSkinPainter.ComboControlArrowOffset: Integer;
begin
  Result := 0; // TdxBarXPPainter
end;

procedure TdxBarSkinPainter.ComboControlDrawArrowButton(const ADrawParams: TdxBarEditLikeControlDrawParams; ARect: TRect; AInClientArea: Boolean);

  function GetState: TcxButtonState;
  begin
    with ADrawParams do
      if not Enabled then
        Result := cxbsDisabled
      else
        if DroppedDown then
          Result := cxbsPressed
        else
          if DrawSelected then
            Result := cxbsHot
          else
            Result := cxbsNormal;
  end;
begin
  FillRectByColor(ADrawParams.Canvas.Handle, ARect, EditGetBkColor(ADrawParams));
  FSkinPainter.DrawEditorButton(ADrawParams.Canvas, ARect, cxbkComboBtn, GetState);
end;

class function TdxBarSkinPainter.IsDateNavigatorFlat: Boolean;
begin
  Result := True;
end;

function TdxBarSkinPainter.DateNavigatorHeaderColor: TColor;
begin
  if FloatingBar <> nil then
    Result := FloatingBar.Color
  else
    Result := inherited DateNavigatorHeaderColor;
end;

procedure TdxBarSkinPainter.DateNavigatorDrawButton(ABarItem: TdxBarItem;
  DC: HDC; R: TRect; const ACaption: string; APressed: Boolean);
const
  State: array [Boolean] of TcxButtonState = (cxbsNormal, cxbsPressed);
begin
  BarCanvas.BeginPaint(DC);
  try
    FillRect(BarCanvas.Handle, R, GetSysColorBrush(COLOR_WINDOW));
    FSkinPainter.DrawButton(BarCanvas, R, ACaption, State[APressed]);
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxBarSkinPainter.InPlaceSubItemControlIsArrowSelected(const ADrawParams: TdxBarInPlaceSubItemControlDrawParams): Boolean;
begin
  Result := False;
end;

procedure TdxBarSkinPainter.InPlaceSubItemControlDrawBackground(const ADrawParams: TdxBarInPlaceSubItemControlDrawParams; ARect: TRect);
begin
  if ADrawParams.DrawSelected then
    DrawItemBackgroundInSubMenu(ADrawParams, ARect)
  else
  begin
    DrawBackground(ADrawParams.BarItemControl, ADrawParams.Canvas.Handle, ARect, 0, False);
    DrawSkinElementContent(PopupMenuSideStrip, ADrawParams.Canvas.Handle, ARect);
  end;
end;

function TdxBarSkinPainter.GetSpinEditButtonWidth(APaintType: TdxBarPaintType; const ARect: TRect): Integer;
begin
  Result := 17;
end;

function TdxBarSkinPainter.GetSpinEditButtonIndents(APaintType: TdxBarPaintType): TRect;
begin
  Result := EditControlBorderOffsets(APaintType);
  Result.Left := 0;
end;

procedure TdxBarSkinPainter.SpinEditControlDrawButton(const ADrawParams: TdxBarSpinEditDrawParams; ARect: TRect; AButtonIndex: Integer);
const
  ButtonKind: array [Boolean] of TcxEditBtnKind = (cxbkSpinDownBtn, cxbkSpinUpBtn);
begin
  FSkinPainter.DrawEditorButton(ADrawParams.Canvas, ARect, ButtonKind[AButtonIndex = secButtonUp],
    GetSpinEditButtonState(ADrawParams, AButtonIndex));
end;

procedure TdxBarSkinPainter.SpinEditControlDrawButtonsAdjacentZone(const ADrawParams: TdxBarSpinEditDrawParams; const ARect: TRect);
begin
  FillRectByColor(ADrawParams.Canvas.Handle, cxRectContent(ARect, GetSpinEditButtonIndents(ADrawParams.PaintType)), EditGetBkColor(ADrawParams));
end;

procedure TdxBarSkinPainter.CalculateSpinEditParts(const ADrawParams: TdxBarSpinEditDrawParams;
  var AParts: array of TRect; const AItemRect: TRect);
begin
  inherited;
  AParts[ecpEdit].Right := AParts[secButtonUp].Left;
end;

procedure TdxBarSkinPainter.SpinEditCorrectFrameRect(const ADrawParams: TdxBarItemControlDrawParams; var ARect: TRect);
begin
  // do nothing
end;

function TdxBarSkinPainter.ProgressControlBarHeight(ABarItemControl: TdxBarItemControl): Integer;
begin
  Result := 24;
end;

class function TdxBarSkinPainter.ProgressControlIndent(const ADrawParams: TdxBarItemControlDrawParams): Integer;
begin
  Result := TdxBarOffice11Painter.ProgressControlIndent(ADrawParams);
end;

procedure TdxBarSkinPainter.ProgressControlDrawBackground(const ADrawParams: TdxBarItemControlDrawParams; var BarR: TRect);
begin
  DrawBackground(ADrawParams.BarItemControl, ADrawParams.Canvas.Handle, BarR, 0, False);
  FSkinPainter.DrawProgressBarBorder(ADrawParams.Canvas, BarR, ADrawParams.PaintType = ptVert);
  BarR := cxRectContent(BarR, FSkinPainter.ProgressBarBorderSize(ADrawParams.PaintType = ptVert));
end;

procedure TdxBarSkinPainter.ProgressControlFillContent(const ADrawParams: TdxBarItemControlDrawParams; const R: TRect; ABarBrush: HBRUSH);
begin
  FSkinPainter.DrawProgressBarChunk(ADrawParams.Canvas, R, ADrawParams.PaintType = ptVert);
end;

function TdxBarSkinPainter.StaticControlGetBorderOffsets(AParent: TCustomdxBarControl; ABorderStyle: TdxBarStaticBorderStyle): TRect;
begin
  if (LinkBorderPainter <> nil) and TCustomdxBarControlAccess(AParent).IsStatusBar then
    Result := LinkBorderPainter.ContentOffset.Rect
  else
    Result := inherited StaticControlGetBorderOffsets(AParent, ABorderStyle);
end;

procedure TdxBarSkinPainter.DrawStaticBackground(const ADrawParams: TdxBarStaticLikeControlDrawParams; ARect: TRect);
begin
  inherited;
  with ADrawParams do
    if (LinkBorderPainter <> nil) and TCustomdxBarControlAccess(BarStaticControl.Parent).IsStatusBar then
      DrawSkinElementContent(LinkBorderPainter, Canvas.Handle, ARect);
end;

procedure TdxBarSkinPainter.DrawStaticBorder(const ADrawParams: TdxBarStaticLikeControlDrawParams; var ARect: TRect);
var
  AContentRect: TRect;
begin
  with ADrawParams do
    if not cxRectIsNull(BorderOffsets) and (LinkBorderPainter <> nil) and TCustomdxBarControlAccess(BarStaticControl.Parent).IsStatusBar then
    begin
      Canvas.SaveClipRegion;
      try
        AContentRect := cxRectContent(ARect, BorderOffsets);
        Canvas.ExcludeClipRect(AContentRect);
        DrawBackground(BarStaticControl, Canvas.Handle, ARect, 0, False);
        DrawSkinElement(LinkBorderPainter, Canvas.Handle, ARect);
        ARect := AContentRect;
      finally
        Canvas.RestoreClipRegion;
      end;
    end
    else
      inherited;
end;

function TdxBarSkinPainter.SubMenuGetSeparatorSize: Integer;
begin
  Result := GetSkinElementSize(PopupMenuSeparator).cy;
end;

procedure TdxBarSkinPainter.DrawSeparatorGlyphAndCaption(const ADrawParams: TdxBarSeparatorControlDrawParams; const ARect: TRect);
var
  ACaptionRect: TRect;
begin
  with ADrawParams do
  begin
    DrawBackground(BarStaticControl, Canvas.Handle, ARect, 0, False);
    DrawSkinElement(FloatingBar, Canvas.Handle, ARect);
    ACaptionRect := ARect;
    ACaptionRect.Left := ACaptionRect.Left +
      SeparatorControlGetIndents(ADrawParams, cpText).Left;
    Dec(ACaptionRect.Bottom, SubMenuGetSeparatorSize);
    if not IsTop then
      Inc(ACaptionRect.Top, SubMenuGetSeparatorSize);    
    DrawItemText(BarItemControl, Canvas.Handle, Caption, ACaptionRect,
      SystemAlignmentsHorz[Alignment], Enabled, False, PaintType = ptVert, True,
      False);
  end;
end;

function TdxBarSkinPainter.ScreenTipGetDescriptionTextColor: TColor;
begin
  if ScreenTipItem <> nil then
    Result := ScreenTipItem.Value
  else
    Result := inherited ScreenTipGetDescriptionTextColor;
end;

function TdxBarSkinPainter.ScreenTipGetTitleTextColor: TColor;
begin
  if ScreenTipTitleItem <> nil then
    Result := ScreenTipTitleItem.Value
  else
    Result := inherited ScreenTipGetTitleTextColor;
end;

function TdxBarSkinPainter.ScreenTipGetFooterLineSize: Integer;
begin
  if ScreenTipSeparator <> nil then
    Result := ScreenTipSeparator.Size.cy
  else
    Result := inherited ScreenTipGetFooterLineSize;
end;

procedure TdxBarSkinPainter.ScreenTipDrawBackground(ACanvas: TcxCanvas; ARect: TRect);
begin
  DrawSkinElement(ScreenTipWindow, ACanvas.Handle, ARect);
end;

procedure TdxBarSkinPainter.ScreenTipDrawFooterLine(ACanvas: TcxCanvas; const ARect: TRect);
begin
  DrawSkinElement(ScreenTipSeparator, ACanvas.Handle, ARect);
end;

function TdxBarSkinPainter.GetDefaultEnabledTextColor(ABarItemControl: TdxBarItemControl;
  ASelected, AFlat: Boolean): TColor;
var
  ATextColorElement: TdxSkinElement;
begin
  ATextColorElement := GetTextColorElement(ABarItemControl.Parent);
  if IsBarElementSkinned(ABarItemControl.Parent) and (ATextColorElement <> nil) then
    if ASelected and (GetSkinElementTextColorHot(ATextColorElement) <> nil) then
      Result := GetSkinElementTextColorHot(ATextColorElement).Value
    else
      Result := ATextColorElement.TextColor
  else
    Result := inherited GetDefaultEnabledTextColor(ABarItemControl, ASelected, AFlat);
end;

procedure TdxBarSkinPainter.GetDisabledTextColors(ABarItemControl: TdxBarItemControl;
  ASelected, AFlat: Boolean; var AColor1, AColor2: TColor);
begin
  if BarDisabledTextColor <> nil then
  begin
    AColor1 := BarDisabledTextColor.Value;
    AColor2 := AColor1;
  end
  else
    inherited;
end;

class function TdxBarSkinPainter.UseTextColorForItemArrow: Boolean;
begin
  Result := True;
end;

function TdxBarSkinPainter.BarMarkIsOpaque: Boolean;
begin
  Result := True;
end;

procedure TdxBarSkinPainter.DrawBarMarkState(ABarControl: TdxBarControl;
  DC: HDC; const R: TRect; AState: TdxBarMarkState);
const
  StatesMap: array [Boolean] of TdxSkinElementState = (esNormal, esHot);
var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  BarFillParentBackground(ABarControl, DC, R, R, 0, clNone);
  DrawSkinElement(GetBarMarkElement(ABarControlAccess.IsMainMenu,
    ABarControlAccess.Vertical), DC, R, 0, StatesMap[AState <> msNone]);
end;

procedure TdxBarSkinPainter.DrawButtonBackground(
  const ADrawParams: TdxBarButtonLikeControlDrawParams);
var
  R: TRect;
begin
  with ADrawParams do
  begin
    R := BarItemControl.ItemBounds;
    if SplitDropDown and IsDropDown then
      Dec(R.Right, cxRectWidth(
        TdxBarItemControlAccess(BarItemControl).FParts[bcpDropButton]));
    DrawGlyphBorder(BarItemControl, Canvas.Handle, 0, False, R, PaintType,
      not (cpIcon in ViewStructure), DrawSelected, Downed, DrawDowned,
      DroppedDown, SplitDropDown and IsDropDown);
    if SplitDropDown and IsDropDown then
      DrawSplitControlArrow(ADrawParams, BarItemControl.ItemBounds);
  end;
end;

procedure TdxBarSkinPainter.DrawGlyphEmptyImage(ABarItemControl: TdxBarItemControl;
  DC: HDC; R: TRect; APaintType: TdxBarPaintType; ADown: Boolean);
begin
  if (APaintType = ptMenu) and ADown and (PopupMenuCheck <> nil) then
    DrawSkinElement(PopupMenuCheck, DC,
      cxRectCenter(R, cxSize(PopupMenuCheck.Size.cx, PopupMenuCheck.Size.cy)), 0)
  else
    inherited;
end;

procedure TdxBarSkinPainter.DrawGlyphBorder(ABarItemControl: TdxBarItemControl;
  DC: HDC; ABrush: HBRUSH; NeedBorder: Boolean; R: TRect; PaintType: TdxBarPaintType;
  IsGlyphEmpty, Selected, Down, DrawDowned, ADroppedDown, IsSplit: Boolean);

  function GetState: TdxSkinElementState;
  const
    DownStates: array[Boolean] of TdxSkinElementState = (esHotCheck, esCheckPressed);
    DrawDownStates: array[Boolean] of TdxSkinElementState = (esHot, esPressed);
  begin
    if not Selected then
      Result := esChecked
    else
      if Down then
        Result := DownStates[DrawDowned]
      else
        Result := DrawDownStates[DrawDowned and not ADroppedDown];
  end;

begin
  if PaintType = ptMenu then
  begin
    if not IsGlyphEmpty and Down then
      DrawSkinElement(PopupMenuCheck, DC, cxRectInflate(R, -2, -2), 1);
  end
  else
    if not ButtonLikeDrawFadingElement(ABarItemControl, DC, R, IsSplit) then
    begin
      DrawBackground(ABarItemControl, DC, R, ABrush, False);
      if Selected or Down then
      begin
        if TdxBarItemControlAccess(ABarItemControl).IsMenuItem then
          DrawSkinElement(MainMenuLinkSelected, DC, R, 0, GetState)
        else
          DrawSkinElement(LinkSelected, DC, R, 0, GetState)
      end;
    end;
end;

function TdxBarSkinPainter.BarCaptionColor(ABarControl: TdxBarControl): COLORREF;
begin
  if FloatingBar <> nil then
    Result := FloatingBar.TextColor
  else
    Result := inherited BarCaptionColor(ABarControl);
end;

class function TdxBarSkinPainter.NeedDoubleBuffer: Boolean;
begin
  Result := True;
end;

class procedure TdxBarSkinPainter.BarOffsetFloatingBarCaption(ABarControl: TdxBarControl;
  var X: Integer; var R: TRect);
begin
  Inc(X, 2);
  R.Right := TdxBarControlAccess(ABarControl).MarkNCRect.Left;//  TdxBarXPPainter
end;

procedure TdxBarSkinPainter.BarDrawGrip(ABarControl: TdxBarControl; DC: HDC; R: TRect;
  AToolbarBrush: HBRUSH);
begin
  BarCanvas.BeginPaint(DC);
  try
    FSkinPainter.DrawSizeGrip(BarCanvas, R, clNone);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxBarSkinPainter.BarDrawMarkBackground(ABarControl: TdxBarControl;
  DC: HDC; ItemRect: TRect; AToolbarBrush: HBRUSH);
begin
  DrawBarMarkState(ABarControl, DC, ItemRect, TdxBarControlAccess(ABarControl).MarkState);
end;

procedure TdxBarSkinPainter.SubMenuControlDrawMarkSelection(ABarSubMenuControl: TdxBarSubMenuControl;
  ADC: HDC; const AMarkRect: TRect);
begin
  DrawSkinElement(PopupMenuLinkSelected, ADC, AMarkRect);
end;

function TdxBarSkinPainter.CreateHintViewInfo(ABarManager: TdxBarManager; AHintText: string; const AShortCut: string;
  AScreenTip: TdxBarScreenTip): TdxBarCustomHintViewInfo;
begin
  Result := dxBarCreateScreenTipViewInfo(ABarManager, AHintText, AShortCut, AScreenTip, Self);
end;

function TdxBarSkinPainter.GetBar(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if AIsVertical then
      Result := ASkinPainterInfo.BarVertical
    else
      Result := ASkinPainterInfo.Bar;
end;

function TdxBarSkinPainter.GetBarCustomize(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if AIsVertical then
      Result := ASkinPainterInfo.BarCustomizeVertical
    else
      Result := ASkinPainterInfo.BarCustomize;
end;

function TdxBarSkinPainter.GetBarDisabledTextColor: TdxSkinColor;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.BarDisabledTextColor;
end;

function TdxBarSkinPainter.GetBarDrag(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if AIsVertical then
      Result := ASkinPainterInfo.BarDragVertical
    else
      Result := ASkinPainterInfo.BarDrag;
end;

function TdxBarSkinPainter.GetBarSeparator(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if AIsVertical then
      Result := ASkinPainterInfo.BarVerticalSeparator
    else
      Result := ASkinPainterInfo.BarSeparator;
end;

function TdxBarSkinPainter.GetDock: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.Dock;
end;

function  TdxBarSkinPainter.GetDockControlWindowButton: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.DockControlWindowButton;
end;

function  TdxBarSkinPainter.GetDockControlWindowButtonGlyph: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.DockControlWindowButtonGlyphs;
end;

function TdxBarSkinPainter.GetFloatingBar: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.FloatingBar;
end;

function TdxBarSkinPainter.GetLinkBorderPainter: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.LinkBorderPainter;
end;

function TdxBarSkinPainter.GetLinkSelected: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.LinkSelected;
end;

function TdxBarSkinPainter.GetMainMenu(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    if AIsVertical then
      Result := ASkinPainterInfo.MainMenuVertical
    else
      Result := ASkinPainterInfo.MainMenu;
end;

function TdxBarSkinPainter.GetMainMenuCustomize(AIsVertical: Boolean): TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
  begin
    if not AIsVertical then
      Result := ASkinPainterInfo.MainMenuCustomize;
    if Result = nil then
      Result := BarCustomize[AIsVertical];
  end;
end;

function TdxBarSkinPainter.GetMainMenuDrag: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.MainMenuDrag;
end;

function TdxBarSkinPainter.GetMainMenuLinkSelected: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.MainMenuLinkSelected;
end;

function TdxBarSkinPainter.GetPopupMenu: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenu;
end;

function TdxBarSkinPainter.GetPopupMenuCheck: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuCheck;
end;

function TdxBarSkinPainter.GetPopupMenuExpandButton: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuExpandButton;
end;

function TdxBarSkinPainter.GetPopupMenuLinkSelected: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuLinkSelected;
end;

function TdxBarSkinPainter.GetPopupMenuSeparator: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuSeparator;
end;

function TdxBarSkinPainter.GetPopupMenuSideStrip: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuSideStrip;
end;

function TdxBarSkinPainter.GetPopupMenuSideStripNonRecent: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuSideStripNonRecent;
end;

function TdxBarSkinPainter.GetPopupMenuSplitButton: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuSplitButton;
end;

function TdxBarSkinPainter.GetPopupMenuSplitButton2: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.PopupMenuSplitButton2;
end;

function TdxBarSkinPainter.GetStatusBar: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.FormStatusBar;
end;

function TdxBarSkinPainter.GetScreenTipItem: TdxSkinColor;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.ScreenTipItem;
end;

function TdxBarSkinPainter.GetScreenTipSeparator: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.ScreenTipSeparator;
end;

function TdxBarSkinPainter.GetScreenTipTitleItem: TdxSkinColor;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.ScreenTipTitleItem;
end;

function TdxBarSkinPainter.GetScreenTipWindow: TdxSkinElement;
var
  ASkinPainterInfo: TdxSkinLookAndFeelPainterInfo;
begin
  Result := nil;
  if GetSkinPainterData(ASkinPainterInfo) then
    Result := ASkinPainterInfo.ScreenTipWindow;
end;

function TdxBarSkinPainter.GetSkinPainterData(var AData: TdxSkinLookAndFeelPainterInfo): Boolean;
begin
  Result := GetExtendedStylePainters.GetPainterData(FSkinPainter, AData);
end;

function TdxBarSkinPainter.DrawSkinElement(AElement: TdxSkinElement; DC: HDC;
  const ARect: TRect; AImageIndex: Integer; AState: TdxSkinElementState): Boolean;
begin
  Result := AElement <> nil;
  if Result then
    AElement.Draw(DC, ARect, Min(AImageIndex, AElement.ImageCount), AState);
end;

function TdxBarSkinPainter.DrawSkinElementContent(AElement: TdxSkinElement; DC: HDC;
  const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal): Boolean;
begin
  BarCanvas.BeginPaint(DC);
  try
    Result := AElement <> nil;
    if Result then
    begin
      BarCanvas.SetClipRegion(TcxRegion.Create(ARect), roIntersect);
      Result := DrawSkinElement(AElement, BarCanvas.Handle,
        cxRectContent(ARect, cxRectInvert(AElement.ContentOffset.Rect)),
        AImageIndex, AState);
    end;
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxBarSkinPainter.DrawSkinElementBorders(AElement: TdxSkinElement; DC: HDC;
  const ARect: TRect; AImageIndex: Integer = 0; AState: TdxSkinElementState = esNormal): Boolean;
begin
  BarCanvas.BeginPaint(DC);
  try
    Result := AElement <> nil;
    if Result then
    begin
      BarCanvas.ExcludeClipRect(cxRectContent(ARect, AElement.ContentOffset.Rect));
      Result := DrawSkinElement(AElement, BarCanvas.Handle, ARect, AImageIndex, AState);
    end;
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxBarSkinPainter.GetSkinElementTextColorHot(ASkinElement: TdxSkinElement): TdxSkinColor;
begin
  if ASkinElement <> nil then
    Result := TdxSkinColor(ASkinElement.GetPropertyByName(sdxTextColorHot))
  else
    Result := nil;
end;

function TdxBarSkinPainter.GetSkinElementSize(ASkinElement: TdxSkinElement): TSize;
begin
  Result := cxNullSize;
  if ASkinElement <> nil then
    if ASkinElement.MinSize.IsEmpty then
      Result := ASkinElement.Size
    else
      Result := ASkinElement.MinSize.Size;
end;

function TdxBarSkinPainter.GetBarElement(ABarControl: TCustomdxBarControl; AVertical: Boolean): TdxSkinElement;
var
  ACustomBarControlAccess: TCustomdxBarControlAccess;
begin
  ACustomBarControlAccess := TCustomdxBarControlAccess(ABarControl);
  if ACustomBarControlAccess.Kind = bkSubMenu then
    Result := PopupMenu
  else
  begin
    if ACustomBarControlAccess.IsMainMenu then
      Result := MainMenu[AVertical]
    else
      if ACustomBarControlAccess.IsStatusBar then
        Result := StatusBar
      else
        Result := Bar[AVertical];
  end;
end;

function TdxBarSkinPainter.GetBarElement(ABarControl: TCustomdxBarControl): TdxSkinElement;
var
  ACustomBarControlAccess: TCustomdxBarControlAccess;
begin
  ACustomBarControlAccess := TCustomdxBarControlAccess(ABarControl);
  Result := GetBarElement(ABarControl, ACustomBarControlAccess.IsRealVertical);
end;

function TdxBarSkinPainter.GetBarMarkElement(AMainMenu, AVertical: Boolean): TdxSkinElement;
begin
  if AMainMenu then
    Result := MainMenuCustomize[AVertical]
  else
    Result := BarCustomize[AVertical];
end;

function TdxBarSkinPainter.GetTextColorElement(ABarControl: TCustomdxBarControl): TdxSkinElement;
begin
  Result := GetBarElement(ABarControl, False);
  if (Result = Bar[False]) and (ABarControl is TdxBarControl) and
    (TdxBarControlAccess(ABarControl).Bar.BorderStyle = bbsNone) then
    Result := Dock;
end;

function TdxBarSkinPainter.IsBarElementSkinned(ABarControl: TCustomdxBarControl): Boolean;
begin
  Result := GetBarElement(ABarControl) <> nil;
end;

procedure TdxBarSkinPainter.DrawArrowButtonElement(AElement: TdxSkinElement;
  ACanvas: TcxCanvas; const ARect: TRect; AImageIndex: Integer = 0;
  AState: TdxSkinElementState = esNormal);
var
  R: TRect;
begin
  if AElement <> nil then
  begin
    R := ARect;
    if cxRectWidth(ARect) < (AElement.Image.Margins.Left + AElement.Image.Margins.Right) then
      R.Left := ARect.Left + cxRectWidth(ARect) - AElement.Image.Margins.Rect.Left - AElement.Image.Margins.Right;
    ACanvas.SaveClipRegion;
    try
      ACanvas.SetClipRegion(TcxRegion.Create(ARect), roIntersect);
      DrawSkinElement(AElement, ACanvas.Handle, R, 0, AState);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;
end;

procedure TdxBarSkinPainter.DrawFloatingBarCaptionButton(DC: HDC; ARect: TRect; AContentType: Integer; AState: TdxBarMarkState);
const
  MarkState2SkinState: array [TdxBarMarkState] of TdxSkinElementState = (esActive, esHot, esPressed);
begin
  DrawSkinElement(DockControlWindowButton, DC, ARect, 0, MarkState2SkinState[AState]);
  DrawSkinElement(DockControlWindowButtonGlyph, DC, ARect, AContentType);
end;

procedure TdxBarSkinPainter.InternalDrawDockedBarBackground(
  ABarControl: TdxBarControl; ACanvas: TcxCanvas; R: TRect; AClientArea: Boolean);

  function GetBarElementRect(ABarControlAccess: TdxBarControlAccess;
    const ARect: TRect): TRect;
  begin
    Result := ARect;
    if ABarControlAccess.Vertical then
    begin
      if ABarControlAccess.CanMoving then
        Inc(Result.Top, GripperSize(ABarControl));
      if ABarControlAccess.MarkExists then
        Dec(Result.Bottom, cxRectHeight(BarMarkItemRect(ABarControlAccess)));
    end
    else
    begin
      if ABarControlAccess.CanMoving then
        Inc(Result.Left, GripperSize(ABarControl));
      if ABarControlAccess.MarkExists then
        Dec(Result.Right, cxRectWidth(BarMarkItemRect(ABarControlAccess)));
    end;
  end;

  function GetBarDragRect(ABarControlAccess: TdxBarControlAccess; const R: TRect): TRect;
  begin
    Result := R;
    if ABarControlAccess.Vertical then
      Result.Bottom := Result.Top + GripperSize(ABarControlAccess)
    else
      Result.Right := Result.Left + GripperSize(ABarControlAccess);
  end;

  procedure DrawBarElement(ABarControlAccess: TdxBarControlAccess;
    ACanvas: TcxCanvas; const ARect: TRect);
  var
    ABarRect: TRect;
  begin
    ABarRect := GetBarElementRect(ABarControlAccess, ARect);
    BarFillParentBackground(ABarControl, ACanvas.Handle, ABarRect, ABarRect, 0, clNone);
    DrawSkinElement(GetBarElement(ABarControlAccess), ACanvas.Handle, ABarRect);
  end;

  procedure DrawMarkElementNCPart(ABarControlAccess: TdxBarControlAccess;
    ACanvas: TcxCanvas; const ARect: TRect);
  var
    ANCMarkRect: TRect;
  begin
    ANCMarkRect := cxRectOffset(BarMarkItemRect(ABarControlAccess), ABarControlAccess.NCOffset);
    ANCMarkRect := cxRectOffset(ANCMarkRect, cxPointInvert(ARect.TopLeft));
    BarDrawMarks(ABarControlAccess, ACanvas, ANCMarkRect, 0);
  end;

  procedure DrawBarDragElement(ABarControlAccess: TdxBarControlAccess;
    ACanvas: TcxCanvas; const R: TRect);
  var
    ABitmap: TcxBitmap;
  begin
    BarFillParentBackground(ABarControl, ACanvas.Handle, R, R, 0, clNone);
    if not ABarControlAccess.IsMainMenu then
      DrawSkinElement(BarDrag[ABarControlAccess.IsRealVertical], ACanvas.Handle, R)
    else
      if not ABarControlAccess.Vertical then
        DrawSkinElement(MainMenuDrag, ACanvas.Handle, R)
      else
      begin
        ABitmap := TcxBitmap.CreateSize(cxRectRotate(R), pf32bit);
        try
          DrawSkinElement(MainMenuDrag, ABitmap.Canvas.Handle, ABitmap.ClientRect);
          ACanvas.RotateBitmap(ABitmap, raMinus90);
          cxBitBlt(ACanvas.Handle, ABitmap.Canvas.Handle, R, cxNullPoint, SRCCOPY);                    
        finally
          ABitmap.Free;
        end;
      end;
  end;

  procedure FillBackgroundTempBitmap(ABarControlAccess: TdxBarControlAccess;
    const AWholeR: TRect);
  var
    ABitmap: TBitmap;
    ABitmapRect: TRect;
  begin
    ABitmap := ABarControlAccess.BackgroundTempBitmap;
    ABitmap.Width := cxRectWidth(AWholeR);
    ABitmap.Height := cxRectHeight(AWholeR);
    ABitmapRect := cxRectOffset(AWholeR, cxPointInvert(AWholeR.TopLeft));

    BarCanvas.BeginPaint(ABitmap.Canvas);
    try
      DrawBarElement(ABarControlAccess, BarCanvas, ABitmapRect);
      if not AClientArea then
      begin
        if ABarControlAccess.MarkExists then
          DrawMarkElementNCPart(ABarControlAccess, BarCanvas, AWholeR);
        if ABarControlAccess.CanMoving then
          DrawBarDragElement(ABarControlAccess, BarCanvas,
            GetBarDragRect(ABarControlAccess, ABitmapRect));
      end;
    finally
      BarCanvas.EndPaint;
    end;
  end;

var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ABarControl);
  FillBackgroundTempBitmap(ABarControlAccess, R);
  cxBitBlt(ACanvas.Handle, ABarControlAccess.BackgroundTempBitmap.Canvas.Handle,
    R, cxNullPoint, SRCCOPY);
end;

function TdxBarSkinPainter.ButtonLikeControlGetState(
  const ADrawParams: TdxBarButtonLikeControlDrawParams): TdxSkinElementState;
const
  MenuStatesMap: array[Boolean] of TdxSkinElementState =
    (esDisabled, esHot);
  SelectedStatesMap: array[Boolean, Boolean] of TdxSkinElementState =
    ((esHot, esPressed), (esHotCheck, esCheckPressed));
begin
  with ADrawParams do
    if PaintType = ptMenu then
      Result := MenuStatesMap[Enabled]
    else
      if DrawSelected then
        Result := SelectedStatesMap[Downed, IsPressed]
      else
        Result := esChecked;
end;

function TdxBarSkinPainter.ButtonLikeDrawArrowFadingElement(
  const ADrawParams: TdxBarButtonLikeControlDrawParams; var R: TRect): Boolean;
var
  ABarItem: TdxBarItemControlAccess;
  R1: TRect;
begin
  ABarItem := TdxBarItemControlAccess(ADrawParams.BarItemControl);
  Result := ABarItem.FadingElementData <> nil;
  if Result then
  begin
    if IsFlatItemText and (ADrawParams.PaintType <> ptMenu) then
      Dec(R.Left);
    ADrawParams.Canvas.SaveClipRegion;
    try
      R1 := R;
      R1.Left := R1.Right - cxRectWidth(ADrawParams.BarItemControl.ItemBounds);
      ADrawParams.Canvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
      ABarItem.FadingElementData.DrawImage(ADrawParams.Canvas.Handle, R1);
    finally
      ADrawParams.Canvas.RestoreClipRegion;
    end;
  end;
end;

function TdxBarSkinPainter.ButtonLikeDrawFadingElement(
  ABarItemControl: TdxBarItemControl; DC: HDC; const R: TRect;
  AIsSplit: Boolean): Boolean;
var
  ABarItem: TdxBarItemControlAccess;
  R1: TRect;
begin
  ABarItem := TdxBarItemControlAccess(ABarItemControl);
  Result := ABarItem.FadingElementData <> nil;
  if not Result then
    Exit;

  if not AIsSplit then
    ABarItem.FadingElementData.DrawImage(DC, R)
  else
  begin
    BarCanvas.BeginPaint(DC);
    try
      R1 := R;
      Inc(R1.Right, cxRectWidth(ABarItem.FParts[bcpDropButton]));
      BarCanvas.SaveClipRegion;
      try
        BarCanvas.SetClipRegion(TcxRegion.Create(R), roIntersect);
        ABarItem.FadingElementData.DrawImage(BarCanvas.Handle, R1);
      finally
        BarCanvas.RestoreClipRegion;
      end;
    finally
      BarCanvas.EndPaint;
    end;
  end;
end;

initialization
  dxBarSkinPainterClass := TdxBarSkinPainter;

finalization
  dxBarSkinPainterClass := TdxBarStandardPainter;

end.
