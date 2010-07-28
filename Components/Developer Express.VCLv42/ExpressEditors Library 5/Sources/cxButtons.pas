{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
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

unit cxButtons;

{$I cxVer.inc}

interface

uses
  Windows, Messages, dxThemeManager,
  Types, Classes, Controls, Graphics, StdCtrls, Forms, Menus, ImgList,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Buttons, cxControls,
  cxContainer, cxClasses;

const
  CM_DROPDOWNPOPUPMENU = WM_DX + 1;
  CM_CLOSEUPPOPUPMENU = WM_DX + 2;
  cxDropDownButtonWidth = 15;

type
  TcxCustomButton = class;
  TcxButtonKind = (cxbkStandard, cxbkDropDown, cxbkDropDownButton);
  TcxButtonAssignedColor = (cxbcDefault, cxbcDefaultText, cxbcDisabled, cxbcDisabledText,
    cxbcHot, cxbcHotText, cxbcNormal, cxbcNormalText, cxbcPressed, cxbcPressedText);
  TcxButtonAssignedColors = set of TcxButtonAssignedColor;
  TcxButtonGetDrawParamsEvent = procedure(Sender: TcxCustomButton;
    AState: TcxButtonState; var AColor: TColor; AFont: TFont) of object;

  { TcxButtonColors }

  TcxButtonColors = class(TPersistent)
  private
    FButton: TcxCustomButton;
    FAssignedColors: TcxButtonAssignedColors;
    FColors: array[TcxButtonAssignedColor] of TColor;
    function GetColor(const Index: Integer): TColor;
    function IsColorStored(const Index: Integer): Boolean;
    procedure SetAssignedColors(Value: TcxButtonAssignedColors);
    procedure SetColor(const Index: Integer; const Value: TColor);
    function ButtonStateToButtonAssignedColor(AState: TcxButtonState; AIsTextColor: Boolean): TcxButtonAssignedColor;
  protected
    function GetColorByState(const AState: TcxButtonState): TColor;
    function GetTextColorByState(const AState: TcxButtonState): TColor;
  public
    constructor Create(AOwner: TcxCustomButton);
    procedure Assign(Source: TPersistent); override;
  published
    property AssignedColors: TcxButtonAssignedColors read FAssignedColors write SetAssignedColors stored False;
    property Default: TColor index Ord(cxbcDefault) read GetColor write SetColor stored IsColorStored;
    property DefaultText: TColor index Ord(cxbcDefaultText) read GetColor write SetColor stored IsColorStored;
    property Normal: TColor index Ord(cxbcNormal) read GetColor write SetColor stored IsColorStored;
    property NormalText: TColor index Ord(cxbcNormalText) read GetColor write SetColor stored IsColorStored;
    property Hot: TColor index Ord(cxbcHot) read GetColor write SetColor stored IsColorStored;
    property HotText: TColor index Ord(cxbcHotText) read GetColor write SetColor stored IsColorStored;
    property Pressed: TColor index Ord(cxbcPressed) read GetColor write SetColor stored IsColorStored;
    property PressedText: TColor index Ord(cxbcPressedText) read GetColor write SetColor stored IsColorStored;
    property Disabled: TColor index Ord(cxbcDisabled) read GetColor write SetColor stored IsColorStored;
    property DisabledText: TColor index Ord(cxbcDisabledText) read GetColor write SetColor stored IsColorStored;
  end;

  { TcxGlyphList }

  TcxGlyphList = class(TcxImageList)
  private
    FUsed: TBits;
    FCount: Integer;
    function AllocateIndex(ABitmap: TBitmap): Integer;
  public
    constructor CreateSize(AWidth, AHeight: Integer);
    destructor Destroy; override;
    function Add(AImage, AMask: TBitmap): Integer; reintroduce;
    function AddMasked(AImage: TBitmap; AMaskColor: TColor): Integer; reintroduce;
    procedure Delete(AIndex: Integer);
    property Count: Integer read FCount;
  end;

  TcxImageInfo = class
  private
    FGlyph: TBitmap;
    FImages: TCustomImageList;
    FImageIndex: Integer;
    function GetOnChange: TNotifyEvent;
    procedure SetGlyph(Value: TBitmap);
    procedure SetImages(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);
    procedure SetOnChange(Value: TNotifyEvent);
  protected
    function GetImageSize: TSize;
    function IsImageAssigned: Boolean;
    procedure GlyphChanged;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
  public
    constructor Create;
    destructor Destroy; override;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
  end;

  { TcxButtonGlyph }

  TcxButtonGlyph = class
  private
    FGlyphList: TcxGlyphList;
    FIndexs: array[TButtonState] of Integer;
    FNumGlyphs: TNumGlyphs;
    FOnChange: TNotifyEvent;

    FImageInfo: TcxImageInfo;

    function GetGlyph: TBitmap;
    function GetImageList: TCustomImageList;
    function GetImageIndex: Integer;
    procedure SetGlyph(Value: TBitmap);
    procedure SetImageList(Value: TCustomImageList);
    procedure SetImageIndex(Value: Integer);

    function GetImageSize: TSize;
    function GetTransparentColor: TColor;
    procedure GlyphChanged(Sender: TObject);
    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure Invalidate;
    function CreateButtonGlyph(AState: TcxButtonState): Integer; virtual;
    procedure DrawButtonGlyph(ACanvas: TCanvas; const AGlyphPos: TPoint;
      AState: TcxButtonState);
    procedure DrawButtonText(ACanvas: TCanvas; const ACaption: TCaption;
      ATextBounds: TRect; AState: TcxButtonState; ABiDiFlags: LongInt;
      ANativeStyle: Boolean{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});
    procedure CalcButtonLayout(ACanvas: TCanvas; const AClient: TRect;
      const AOffset: TPoint; const ACaption: TCaption; ALayout: TButtonLayout;
      AMargin, ASpacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect;
      ABiDiFlags: LongInt{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});
  protected
    function CanWordWrapText{$IFDEF DELPHI7}(AWordWrap: Boolean){$ENDIF}: Boolean;
    function GetTextOffsets(ALayout: TButtonLayout): TRect; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Draw(ACanvas: TCanvas; const AClient: TRect; const AOffset: TPoint;
      const ACaption: TCaption; ALayout: TButtonLayout; AMargin, ASpacing: Integer;
      AState: TcxButtonState ; ABiDiFlags: LongInt;
      ANativeStyle: Boolean{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});

    property ImageInfo: TcxImageInfo read FImageInfo;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property ImageList: TCustomImageList read GetImageList write SetImageList;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;

    property NumGlyphs: TNumGlyphs read FNumGlyphs write SetNumGlyphs;
    property TransparentColor: TColor read GetTransparentColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TcxButtonGlyphClass = class of TcxButtonGlyph;

  { TcxButtonActionLink }

  TcxButtonActionLink = class(TButtonActionLink)
  private
    function GetClient: TcxCustomButton;
    property Client: TcxCustomButton read GetClient;
  protected
    procedure SetImageIndex(Value: Integer); override;
  public
    destructor Destroy; override;
  end;

  { TcxSpeedButtonOptions }

  TcxButton = class;

  TcxSpeedButtonOptions = class(TPersistent)
  private
    FAllowAllUp: Boolean;
    FCanBeFocused: Boolean;
    FGroupIndex: Integer;
    FFlat: Boolean;
    FLockCount: Integer;
    FOwner: TcxCustomButton;
    FTransparent: Boolean;
    function GetActive: Boolean;
    function GetButton: TcxCustomButton;
    function GetDown: Boolean;
    procedure SetAllowAllUp(AValue: Boolean);
    procedure SetCanBeFocused(AValue: Boolean);
    procedure SetDown(AValue: Boolean);
    procedure SetFlat(AValue: Boolean);
    procedure SetGroupIndex(AValue: Integer);
    procedure SetTransparent(AValue: Boolean);
    procedure UpdateGroup;
  protected
    function GetOwner: TPersistent; override;
    procedure UpdateGroupValues(const AGroupIndex: Integer; const ASpeedButtonOptions: TcxSpeedButtonOptions);
    property Button: TcxCustomButton read GetButton;
    property LockCount: Integer read FLockCount;
  public
    constructor Create(AOwner: TcxCustomButton); virtual;
    procedure Assign(Source: TPersistent); override;

    procedure BeginUpdate;
    procedure CancelUpdate;
    procedure EndUpdate;

    property Active: Boolean read GetActive;
  published
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property CanBeFocused: Boolean read FCanBeFocused write SetCanBeFocused default True;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Down: Boolean read GetDown write SetDown default False;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;

  { TcxCustomButton }

  TcxButtonInternalState = set of (bisDown, bisHot, bisPressed);

  TcxButtonDropDownMenuPopupEvent = procedure(Sender: TObject;
    var APopupMenu: TPopupMenu; var AHandled: Boolean) of object;

  TcxCustomButton = class({$IFDEF DELPHI12}TCustomButton{$ELSE}TButton{$ENDIF},
    IdxSkinSupport,
    IcxMouseTrackingCaller,
    IcxLookAndFeelContainer)
  private
    FAutoSize: Boolean;
    FInternalState: TcxButtonInternalState;
    FCanvas: TcxCanvas;
    FColors: TcxButtonColors;
    FControlCanvas: TControlCanvas;
    FDoPopup: Boolean;
    FDropDownMenu: TPopupMenu;
    FIsFocused: Boolean;
    FKind: TcxButtonKind;
    FLookAndFeel: TcxLookAndFeel;
    FIsPaintDefault: Boolean;
    FIsPaintPressed: Boolean;
    FPopupAlignment: TPopupAlignment;
    FPopupMenu: TComponent;
    FSpeedButtonOptions: TcxSpeedButtonOptions;
    FUseSystemPaint: Boolean; // deprecated

    // glyph support
    FGlyph: TcxButtonGlyph;
    FLayout: TButtonLayout;
    FMargin: Integer;
    FMenuVisible: Boolean;
    FSpacing: Integer;

    // events
    FOnDropDownMenuPopup: TcxButtonDropDownMenuPopupEvent;
    FOnGetDrawParams: TcxButtonGetDrawParamsEvent;

    procedure InitializeCanvasColors(AState: TcxButtonState; out AColor: TColor);
    // glyph support
    procedure SetGlyph(Value: TBitmap);
    function GetGlyph: TBitmap;
    function GetNumGlyphs: TNumGlyphs;
    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure GlyphChanged(Sender: TObject);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetMargin(Value: Integer);
    procedure DrawItem(const DrawItemStruct: TDrawItemStruct);
    procedure UpdateImageInfo;

    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure CMCloseupPopupMenu(var Message: TMessage); message CM_CLOSEUPPOPUPMENU;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMDropDownPopupMenu(var Message: TMessage); message CM_DROPDOWNPOPUPMENU;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CNSysKeyDown(var Message: TWMSysKeyDown); message CN_SYSKEYDOWN;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;

    procedure ExcludeDropDownButtonRect(var R: TRect);
    procedure DoDropDownMenu;
    function GetBorderRect(AState: TcxButtonState): TRect;
    function GetContentRect: TRect;
    function GetDropDownMenuAlignment(APopupPoint: TPoint;
      AEstimatedAlignment: TPopupAlignment): TPopupAlignment;
    function GetDropDownMenuPopupPoint(ADropDownMenu: TPopupMenu): TPoint;
    procedure InternalPaint;
    procedure InternalRecreateWindow;
    function IsColorsStored: Boolean;
    function CanHotTrack: Boolean;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);
    procedure SetButtonAutoSize(Value: Boolean);
    procedure SetColors(const Value: TcxButtonColors);
    procedure SetKind(const Value: TcxButtonKind);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure SetPopupMenu(Value: TComponent);

    // speed button support
    procedure CheckShowMenu(const P: TPoint);
    function GetButtonState: TcxButtonState;
    function GetAllowAllUp: Boolean;
    function GetCanBeFocused: Boolean;
    function GetDown: Boolean;
    function GetGroupIndex: Integer;
    function GetMenuButtonBounds: TRect;
    function GetSpeedButtonMode: Boolean;
    procedure SetAllowAllUp(AValue: Boolean);
    procedure SetCanBeFocused(AValue: Boolean);
    procedure SetDown(AValue: Boolean);
    procedure SetGroupIndex(AValue: Integer);
    procedure SetSpeedButtonOptions(AValue: TcxSpeedButtonOptions);
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    function GetPalette: HPALETTE; override;
    procedure SetButtonStyle(ADefault: Boolean); override;
    procedure DoContextPopup(MousePos: TPoint;
      var Handled: Boolean); override;
    function DoOnDropDownMenuPopup(var APopupMenu: TPopupMenu): Boolean; virtual;
    function DoShowPopupMenu(APopupMenu: TComponent;
      X, Y: Integer): Boolean; virtual;
    function GetGlyphClass: TcxButtonGlyphClass; virtual;
    function GetPainterClass: TcxCustomLookAndFeelPainterClass; virtual;
    function IsDesigning: Boolean;
    function StandardButton: Boolean; virtual;
    procedure UpdateSize;

    // Mouse Events
    procedure DblClick; override;
    procedure MouseEnter; dynamic;
    procedure MouseLeave; dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    //IcxMouseTrackingCaller
    procedure IcxMouseTrackingCaller.MouseLeave = MouseLeave;

    // IcxLookAndFeelContainer
    function GetLookAndFeel: TcxLookAndFeel;

    property AutoSize: Boolean read FAutoSize write SetButtonAutoSize default False;
    property Colors: TcxButtonColors read FColors write SetColors stored IsColorsStored;
    property DropDownMenu: TPopupMenu read FDropDownMenu write FDropDownMenu;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property InternalState: TcxButtonInternalState read FInternalState;
    property Kind: TcxButtonKind read FKind write SetKind default cxbkStandard;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs default 1;
    property PopupAlignment: TPopupAlignment read FPopupAlignment
      write FPopupAlignment default paLeft;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property UseSystemPaint: Boolean read FUseSystemPaint
      write FUseSystemPaint default False; // deprecated

    // speed button support
    property AllowAllUp: Boolean read GetAllowAllUp write SetAllowAllUp default False;
    property CanBeFocused: Boolean read GetCanBeFocused write SetCanBeFocused default True;
    property Down: Boolean read GetDown write SetDown default False;
    property GroupIndex: Integer read GetGroupIndex write SetGroupIndex default 0;
    property SpeedButtonMode: Boolean read GetSpeedButtonMode;
    property SpeedButtonOptions: TcxSpeedButtonOptions read FSpeedButtonOptions write SetSpeedButtonOptions;

    property OnDropDownMenuPopup: TcxButtonDropDownMenuPopupEvent
      read FOnDropDownMenuPopup write FOnDropDownMenuPopup;
    property OnGetDrawParams: TcxButtonGetDrawParamsEvent
      read FOnGetDrawParams write FOnGetDrawParams;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    function CanFocus: Boolean; override;
    function GetOptimalSize: TSize; virtual;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property PopupMenu: TComponent read FPopupMenu write SetPopupMenu;
  {$IFDEF DELPHI12}
    property DragCursor;
    property DragKind;
    property DragMode;
    property Font;
    property ParentFont;
    property WordWrap;
  {$ENDIF}
  end;

  { TcxButton }

  TcxButton = class(TcxCustomButton)
  published
    property Align;
//    property AutoSize;
    property CanBeFocused stored False;
    property GroupIndex stored False;
    property Down stored False;
    property AllowAllUp stored False;
    property Action;
    property Anchors;
    property BiDiMode;
    property Cancel;
    property Caption;
    property Colors;
    property Constraints;
    property Default;
    property DropDownMenu;
    property Enabled;
    property Glyph;
    property Kind;
    property Layout;
    property LookAndFeel;
    property Margin;
    property ModalResult;
    property NumGlyphs;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupAlignment;
    property PopupMenu;
    property ShowHint;
    property Spacing;
    property SpeedButtonOptions;
    property TabOrder;
    property TabStop;
    property UseSystemPaint; // deprecated
    property Visible;
    property OnDropDownMenuPopup;
    property OnEnter;
    property OnExit;
    property OnGetDrawParams;

  {$IFDEF DELPHI12}
    property DragCursor;
    property DragKind;
    property DragMode;
    property Font;
    property ParentFont;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  {$ENDIF}  
  end;

function GetButtonPainterClass(ALookAndFeel: TcxLookAndFeel): TcxCustomLookAndFeelPainterClass;

implementation

uses
  dxUxTheme, CommCtrl, dxThemeConsts,
  cxGeometry, SysUtils, Consts, Dialogs, ActnList, Math;

const
  cxBtnStdVertTextOffsetCorrection = -1;
  TextRectCorrection: TRect = (Left: 1; Top: 0; Right: 2; Bottom: 0);

function GetButtonPainterClass(ALookAndFeel: TcxLookAndFeel): TcxCustomLookAndFeelPainterClass;
begin
  if ALookAndFeel.SkinPainter <> nil then
    Result := ALookAndFeel.SkinPainter
  else
  begin
    Result := ALookAndFeel.Painter;
    if Result.LookAndFeelStyle = lfsOffice11 then
      if AreVisualStylesAvailable(totButton) then
        Result := TcxWinXPLookAndFeelPainter
      else
        Result := TcxStandardLookAndFeelPainter;
  end;
end;

{ TcxButtonColors }

constructor TcxButtonColors.Create(AOwner: TcxCustomButton);
var
  AState: TcxButtonAssignedColor;
begin
  inherited Create;
  FButton := AOwner;
  for AState := Low(AState) to High(AState) do
    FColors[AState] := clDefault;
end;

function TcxButtonColors.GetColor(const Index: Integer): TColor;
begin
  Result := FColors[TcxButtonAssignedColor(Index)];
end;

function TcxButtonColors.IsColorStored(const Index: Integer): Boolean;
begin
  Result := TcxButtonAssignedColor(Index) in FAssignedColors;
end;

procedure TcxButtonColors.SetAssignedColors(
  Value: TcxButtonAssignedColors);
var
  AState: TcxButtonAssignedColor;
begin
  if (FAssignedColors <> Value) and FButton.IsDesigning then
  begin
    for AState := Low(AState) to High(AState) do
      if not (AState in Value) then
        FColors[AState] := clDefault
      else
        if FColors[AState] = clDefault then Exclude(Value, AState);
    FAssignedColors := Value;
    FButton.Invalidate;
  end;
end;

procedure TcxButtonColors.SetColor(const Index: Integer;
  const Value: TColor);
begin
  if (Value = clNone) or (Value = clDefault) then
  begin
    FColors[TcxButtonAssignedColor(Index)] := clDefault;
    Exclude(FAssignedColors, TcxButtonAssignedColor(Index));
    FButton.Invalidate;
  end
  else if GetColor(Index) <> Value then
  begin
    FColors[TcxButtonAssignedColor(Index)] := Value;
    Include(FAssignedColors, TcxButtonAssignedColor(Index));
    FButton.Invalidate;
  end;
end;

function TcxButtonColors.ButtonStateToButtonAssignedColor(AState: TcxButtonState; AIsTextColor: Boolean): TcxButtonAssignedColor;
begin
  if AIsTextColor then
    Result := cxbcNormalText
  else
    Result := cxbcNormal;
  case AState of
    cxbsDefault:
      if AIsTextColor then
        Result := cxbcDefaultText
      else
        Result := cxbcDefault;
    cxbsHot:
      if AIsTextColor then
        Result := cxbcHotText
      else
        Result := cxbcHot;
    cxbsPressed:
      if AIsTextColor then
        Result := cxbcPressedText
      else
        Result := cxbcPressed;
    cxbsDisabled:
      if AIsTextColor then
        Result := cxbcDisabledText
      else
        Result := cxbcDisabled;
  end;
end;

function TcxButtonColors.GetColorByState(const AState: TcxButtonState): TColor;
var
  AButtonColor: TcxButtonAssignedColor;
begin
  AButtonColor := ButtonStateToButtonAssignedColor(AState, False);
  if AButtonColor in AssignedColors then
    Result := FColors[AButtonColor]
  else
    if AButtonColor = cxbcNormal then
      Result := FColors[cxbcDefault]
    else
      Result := FColors[cxbcNormal];
end;

function TcxButtonColors.GetTextColorByState(const AState: TcxButtonState): TColor;
var
  AButtonColor: TcxButtonAssignedColor;
begin
  AButtonColor := ButtonStateToButtonAssignedColor(AState, True);
  if AButtonColor in AssignedColors then
    Result := FColors[AButtonColor]
  else
    if AButtonColor = cxbcNormalText then
      Result := FColors[cxbcDefaultText]
    else
      Result := FColors[cxbcNormalText];
end;

procedure TcxButtonColors.Assign(Source: TPersistent);
begin
  if Source is TcxButtonColors then
    with TcxButtonColors(Source) do
    begin
      Self.FColors := FColors;
      Self.FAssignedColors := FAssignedColors;
      Self.FButton.Invalidate;
    end
    else
      inherited Assign(Source);
end;

{ TcxGlyphList }

constructor TcxGlyphList.CreateSize(AWidth, AHeight: Integer);
begin
  inherited CreateSize(AWidth, AHeight);
  FUsed := TBits.Create;
end;

destructor TcxGlyphList.Destroy;
begin
  FreeAndNil(FUsed);
  inherited Destroy;
end;

function TcxGlyphList.AllocateIndex(ABitmap: TBitmap): Integer;
begin
  Result := FUsed.OpenBit;
  if Result >= FUsed.Size then
  begin
    Result := inherited Add(ABitmap, nil);
    FUsed.Size := Result + 1;
  end;
  FUsed[Result] := True;
end;

function TcxGlyphList.Add(AImage, AMask: TBitmap): Integer;
begin
  Result := AllocateIndex(AImage);
  Replace(Result, AImage, AMask);
  Inc(FCount);
end;

function TcxGlyphList.AddMasked(AImage: TBitmap; AMaskColor: TColor): Integer;
begin
  Result := AllocateIndex(AImage);
  ReplaceMasked(Result, AImage, AMaskColor);
  Inc(FCount);
end;

procedure TcxGlyphList.Delete(AIndex: Integer);
begin
  if FUsed[AIndex] then
  begin
    Dec(FCount);
    FUsed[AIndex] := False;
  end;
end;

type
  { TcxGlyphCache }

  TcxGlyphCache = class
  private
    FGlyphLists: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetList(AWidth, AHeight: Integer): TcxGlyphList;
    procedure ReturnList(AList: TcxGlyphList);
    function Empty: Boolean;
  end;

{ TcxGlyphCache }

constructor TcxGlyphCache.Create;
begin
  inherited Create;
  FGlyphLists := TList.Create;
end;

destructor TcxGlyphCache.Destroy;
begin
  FreeAndNil(FGlyphLists);
  inherited Destroy;
end;

function TcxGlyphCache.GetList(AWidth, AHeight: Integer): TcxGlyphList;
var
  I: Integer;
begin
  for I := FGlyphLists.Count - 1 downto 0 do
  begin
    Result := TcxGlyphList(FGlyphLists[I]);
    with Result do
      if (AWidth = Width) and (AHeight = Height) then Exit;
  end;
  Result := TcxGlyphList.CreateSize(AWidth, AHeight);
  FGlyphLists.Add(Result);
end;

procedure TcxGlyphCache.ReturnList(AList: TcxGlyphList);
begin
  if AList = nil then Exit;
  if AList.Count = 0 then
  begin
    FGlyphLists.Remove(AList);
    AList.Free;
  end;
end;

function TcxGlyphCache.Empty: Boolean;
begin
  Result := FGlyphLists.Count = 0;
end;

var
  GlyphCache: TcxGlyphCache = nil;

{ TcxImageInfo }

constructor TcxImageInfo.Create;
begin
  inherited Create;
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := OnChange;
  FImageIndex := -1;
end;

destructor TcxImageInfo.Destroy;
begin
  FreeAndNil(FGlyph);
  inherited;
end;

function TcxImageInfo.GetImageSize: TSize;
begin
  if not IsImageAssigned then
    Result := cxNullSize
  else
    if IsGlyphAssigned(Glyph) then
    begin
      if (Glyph.Width = 0) or (Glyph.Height = 0) then
        Glyph.Handle; //HandleNeeded
      Result := Size(Glyph.Width, Glyph.Height)
    end
    else
      Result := Size(Images.Width, Images.Height);
end;

function TcxImageInfo.IsImageAssigned: Boolean;
begin
  Result := IsGlyphAssigned(Glyph) or cxGraphics.IsImageAssigned(Images, ImageIndex);
end;

procedure TcxImageInfo.GlyphChanged;
begin
  CallNotify(OnChange, nil);
end;

function TcxImageInfo.GetOnChange: TNotifyEvent;
begin
  Result := FGlyph.OnChange;
end;

procedure TcxImageInfo.SetGlyph(Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

procedure TcxImageInfo.SetImages(Value: TCustomImageList);
begin
  if Images <> Value then
  begin
    FImages := Value;
    if not IsGlyphAssigned(Glyph) and (ImageIndex <> -1) then
      GlyphChanged;
  end;
end;

procedure TcxImageInfo.SetImageIndex(Value: Integer);
begin
  if ImageIndex <> Value then
  begin
    FImageIndex := Value;
    if not IsGlyphAssigned(Glyph) and (Images <> nil) then
      GlyphChanged;
  end;
end;

procedure TcxImageInfo.SetOnChange(Value: TNotifyEvent);
begin
  FGlyph.OnChange := Value;
end;

{ TcxButtonGlyph }

constructor TcxButtonGlyph.Create;
var
  I: TButtonState;
begin
  inherited Create;
  FImageInfo := TcxImageInfo.Create;
  FImageInfo.OnChange := GlyphChanged;
  FNumGlyphs := 1;
  for I := Low(I) to High(I) do
    FIndexs[I] := -1;
  if GlyphCache = nil then GlyphCache := TcxGlyphCache.Create;
end;

destructor TcxButtonGlyph.Destroy;
begin
  FreeAndNil(FImageInfo);
  Invalidate;
  if Assigned(GlyphCache) and GlyphCache.Empty then
    FreeAndNil(GlyphCache);
  inherited Destroy;
end;

procedure TcxButtonGlyph.Invalidate;
var
  I: TButtonState;
begin
  for I := Low(I) to High(I) do
  begin
    if FIndexs[I] <> -1 then FGlyphList.Delete(FIndexs[I]);
    FIndexs[I] := -1;
  end;
  GlyphCache.ReturnList(FGlyphList);
  FGlyphList := nil;
end;

function TcxButtonGlyph.GetImageSize: TSize;
begin
  Result := ImageInfo.GetImageSize;
  Result.cx := Result.cx div FNumGlyphs;
end;

function TcxButtonGlyph.GetTransparentColor: TColor;
begin
  Result := Glyph.TransparentColor;
end;

procedure TcxButtonGlyph.GlyphChanged(Sender: TObject);
begin
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TcxButtonGlyph.GetGlyph: TBitmap;
begin
  Result := ImageInfo.Glyph;
end;

function TcxButtonGlyph.GetImageList: TCustomImageList;
begin
  Result := ImageInfo.Images;
end;

function TcxButtonGlyph.GetImageIndex: Integer;
begin
  Result := ImageInfo.ImageIndex;
end;

procedure TcxButtonGlyph.SetGlyph(Value: TBitmap);
var
  ANumGlyphs: Integer;
begin
  ANumGlyphs := 1;
  ImageInfo.Glyph := Value;
  if (Value <> nil) and (Value.Height > 0) then
  begin
    if Value.Width mod Value.Height = 0 then
    begin
      ANumGlyphs := Value.Width div Value.Height;
      if ANumGlyphs > 4 then ANumGlyphs := 1;
    end;
  end;
  NumGlyphs := ANumGlyphs;
end;

procedure TcxButtonGlyph.SetImageList(Value: TCustomImageList);
begin
  ImageInfo.Images := Value;
end;

procedure TcxButtonGlyph.SetImageIndex(Value: Integer);
begin
  ImageInfo.ImageIndex := Value;
end;

procedure TcxButtonGlyph.SetNumGlyphs(Value: TNumGlyphs);
begin
  Value := Min(Max(Value, 1), 4);
  if Value <> FNumGlyphs then
  begin
    FNumGlyphs := Value;
    GlyphChanged(Glyph);
  end;
end;

function TcxButtonGlyph.CreateButtonGlyph(AState: TcxButtonState): Integer;

  function GetStandardButtonState(AState: TcxButtonState): TButtonState;
  const
    States: array[TcxButtonState] of TButtonState =
    //cxbsDefault, cxbsNormal, cxbsHot, cxbsPressed, cxbsDisabled;
      (bsUp, bsUp, bsUp, bsDown, bsDisabled);
  begin
    Result := States[AState];
    if (Result = bsDown) and (NumGlyphs < 3) then
      Result := bsUp;
  end;

  function GetGlyphList(AWidth, AHeight: Integer): TcxGlyphList;
  begin
    if FGlyphList = nil then
    begin
      if GlyphCache = nil then
        GlyphCache := TcxGlyphCache.Create;
      FGlyphList := GlyphCache.GetList(AWidth, AHeight);
    end;
    Result := FGlyphList;
  end;

  procedure InternalMakeImagesFromGlyph(AStandardButtonState: TButtonState; AImage, AMask: TBitmap; const AImageBounds: TRect);
  var
    ASrcPoint: TPoint;
    AOffset: Integer;
  begin
    AOffset := Ord(AStandardButtonState);
    if AOffset >= NumGlyphs then
      AOffset := 0;

    if (AStandardButtonState = bsDisabled) and (NumGlyphs = 1) then
      cxDrawImage(AImage.Canvas.Handle, AImageBounds, AImageBounds, Glyph, nil, -1, idmDisabled, False, 0, TransparentColor, False)
    else
    begin
      ASrcPoint := cxRectOffset(AImageBounds, AOffset * cxRectWidth(AImageBounds), 0).TopLeft;
      cxDrawBitmap(AImage.Canvas.Handle, Glyph, AImageBounds, ASrcPoint);
    end;
    if (NumGlyphs <> 1) or (AStandardButtonState <> bsDisabled) then
      AImage.TransparentColor := Glyph.TransparentColor;
    cxMakeMaskBitmap(AImage, AMask);
    Glyph.Dormant;
  end;

  procedure InternalMakeImagesFromImageList(AStandardButtonState: TButtonState; AImage, AMask: TBitmap; const AImageBounds: TRect);
  begin
    if AStandardButtonState = bsDisabled then
    begin
      cxDrawImage(AImage.Canvas.Handle, AImageBounds, AImageBounds, nil, ImageList, ImageIndex, idmDisabled);
      cxMakeMaskBitmap(AImage, AMask);
    end
    else
      TcxImageList.GetImageInfo(ImageList.Handle, ImageIndex, AImage, AMask);
  end;

  function InternalCreateButtonGlyph(AStandardButtonState: TButtonState; const AImageSize: TSize): Integer;
  var
    AImage, AMask: TBitmap;
    AImageBounds: TRect;
  begin
    AImage := TcxBitmap.CreateSize(AImageSize.cx, AImageSize.cy);
    AMask := cxCreateBitmap(AImageSize, pf1bit);
    try
      AImageBounds := cxRect(0, 0, AImageSize.cx, AImageSize.cy);
      if IsGlyphAssigned(Glyph) then
        InternalMakeImagesFromGlyph(AStandardButtonState, AImage, AMask, AImageBounds)
      else
        InternalMakeImagesFromImageList(AStandardButtonState, AImage, AMask, AImageBounds);
      FIndexs[AStandardButtonState] := GetGlyphList(AImageSize.cx, AImageSize.cy).Add(AImage, AMask);
      Result := FIndexs[AStandardButtonState];
    finally
      AMask.Free;
      AImage.Free;
    end;
  end;

  function GetGlyphIndex(AStandardButtonState: TButtonState): Integer;
  begin
    Result := FIndexs[AStandardButtonState];
    if (Result = -1) and ImageInfo.IsImageAssigned then
      Result := InternalCreateButtonGlyph(AStandardButtonState, GetImageSize)
  end;

begin
  Result := GetGlyphIndex(GetStandardButtonState(AState));
end;

procedure TcxButtonGlyph.DrawButtonGlyph(ACanvas: TCanvas; const AGlyphPos: TPoint;
  AState: TcxButtonState);
begin
  if not ImageInfo.IsImageAssigned then
    Exit;
  FGlyphList.Draw(ACanvas, AGlyphPos.X, AGlyphPos.Y, CreateButtonGlyph(AState));
end;

procedure TcxButtonGlyph.DrawButtonText(ACanvas: TCanvas; const ACaption: TCaption;
  ATextBounds: TRect; AState: TcxButtonState ; ABiDiFlags: LongInt;
  ANativeStyle: Boolean{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});

  procedure InternalDrawButtonText;
  var
    ADrawTextFlags: Integer;
  begin
    ADrawTextFlags := DT_CENTER or DT_VCENTER or ABiDiFlags;
    if CanWordWrapText{$IFDEF DELPHI7}(AWordWrap){$ENDIF} then
      ADrawTextFlags := ADrawTextFlags or DT_WORDBREAK;
    cxDrawText(ACanvas.Handle, ACaption, ATextBounds, ADrawTextFlags);
  end;

var
  ABrushStyle: TBrushStyle;
  AFontColor: TColor;
begin
  if Length(ACaption) = 0 then Exit;
  ABrushStyle := ACanvas.Brush.Style;
  try
    ACanvas.Brush.Style := bsClear;
    if AState = cxbsDisabled then
    begin
      OffsetRect(ATextBounds, 1, 1);
      AFontColor := ACanvas.Font.Color;
      ACanvas.Font.Color := clBtnHighlight;
      InternalDrawButtonText;
      OffsetRect(ATextBounds, -1, -1);
      ACanvas.Font.Color := AFontColor;
    end;
    InternalDrawButtonText;
  finally
    ACanvas.Brush.Style := ABrushStyle;
  end;
end;

procedure TcxButtonGlyph.CalcButtonLayout(ACanvas: TCanvas; const AClient: TRect;
  const AOffset: TPoint; const ACaption: TCaption; ALayout: TButtonLayout;
  AMargin, ASpacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect;
  ABiDiFlags: LongInt{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});

  procedure CheckLayout;
  begin
    if ABiDiFlags and DT_RIGHT = DT_RIGHT then
    begin
      if ALayout = blGlyphLeft then
        ALayout := blGlyphRight
      else
        if ALayout = blGlyphRight then
          ALayout := blGlyphLeft;
    end;
  end;

  function GetCaptionSize: TPoint;
  var
    ADrawTextFlags: Integer;
    ATextOffsets: TRect;
  begin
    if Length(ACaption) = 0 then
    begin
      TextBounds := cxNullRect;
      Result := cxNullPoint;
    end
    else
    begin
      TextBounds := Rect(0, 0, AClient.Right - AClient.Left, 0);
      ATextOffsets := GetTextOffsets(ALayout);
      ExtendRect(TextBounds, ATextOffsets);
      ADrawTextFlags := DT_CALCRECT or ABiDiFlags;
      if CanWordWrapText{$IFDEF DELPHI7}(AWordWrap){$ENDIF} then
        ADrawTextFlags := ADrawTextFlags or DT_WORDBREAK;
      cxDrawText(ACanvas.Handle, ACaption, TextBounds, ADrawTextFlags);
      with TextBounds do
        Result := Point(Right - Left, Bottom - Top);
      Inc(Result.X, ATextOffsets.Left + ATextOffsets.Right);
      Inc(Result.Y, ATextOffsets.Top + ATextOffsets.Bottom);
    end;
  end;

var
  ATextPos: TPoint;
  AGlyphSize: TSize;
  AClientSize, ATextSize: TPoint;
  ATotalSize: TPoint;
begin
  CheckLayout;
  ATextSize := GetCaptionSize;
  with AClient do
    AClientSize := Point(Right - Left, Bottom - Top);

(*  if FOriginal.Empty then
  begin
    GlyphPos := EmptyPoint;
    ATextPos.X := (AClientSize.X - ATextSize.X) div 2;
    ATextPos.Y := (AClientSize.Y - ATextSize.Y - 1) div 2;
    OffsetRect(TextBounds, ATextPos.X + AOffset.X, ATextPos.Y + AOffset.Y);
    Exit;
  end;*)

  AGlyphSize := GetImageSize;
  if ALayout in [blGlyphLeft, blGlyphRight] then
  begin
    GlyphPos.Y := (AClientSize.Y - AGlyphSize.cy) div 2;
    ATextPos.Y := (AClientSize.Y - ATextSize.Y +
      cxBtnStdVertTextOffsetCorrection) div 2;
  end
  else
  begin
    GlyphPos.X := (AClientSize.X - AGlyphSize.cx) div 2;
    ATextPos.X := (AClientSize.X - ATextSize.X) div 2;
  end;

  if (ATextSize.X = 0) or (AGlyphSize.cx = 0) then ASpacing := 0;

  if AMargin = -1 then
  begin
    if ASpacing = -1 then
    begin
      ATotalSize := Point(AGlyphSize.cx + ATextSize.X, AGlyphSize.cy + ATextSize.Y);
      if ALayout in [blGlyphLeft, blGlyphRight] then
        AMargin := (AClientSize.X - ATotalSize.X) div 3
      else
        AMargin := (AClientSize.Y - ATotalSize.Y) div 3;
      ASpacing := AMargin;
    end
    else
    begin
      ATotalSize := Point(AGlyphSize.cx + ASpacing + ATextSize.X, AGlyphSize.cy +
        ASpacing + ATextSize.Y);
      if ALayout in [blGlyphLeft, blGlyphRight] then
        AMargin := (AClientSize.X - ATotalSize.X) div 2
      else
        AMargin := (AClientSize.Y - ATotalSize.Y) div 2;
    end;
  end
  else
  begin
    if ASpacing = -1 then
    begin
      ATotalSize := Point(AClientSize.X - (AMargin + AGlyphSize.cx),
        AClientSize.Y - (AMargin + AGlyphSize.cy));
      if ALayout in [blGlyphLeft, blGlyphRight] then
        ASpacing := (ATotalSize.X - ATextSize.X) div 2
      else
        ASpacing := (ATotalSize.Y - ATextSize.Y) div 2;
    end;
  end;
  case ALayout of
    blGlyphLeft:
      begin
        GlyphPos.X := AMargin;
        ATextPos.X := GlyphPos.X + AGlyphSize.cx + ASpacing;
      end;
    blGlyphRight:
      begin
        GlyphPos.X := AClientSize.X - AMargin - AGlyphSize.cx;
        ATextPos.X := GlyphPos.X - ASpacing - ATextSize.X;
      end;
    blGlyphTop:
      begin
        GlyphPos.Y := AMargin;
        ATextPos.Y := GlyphPos.Y + AGlyphSize.cy + ASpacing;
      end;
    blGlyphBottom:
      begin
        GlyphPos.Y := AClientSize.Y - AMargin - AGlyphSize.cy;
        ATextPos.Y := GlyphPos.Y - ASpacing - ATextSize.Y;
      end;
  end;
  with GlyphPos do
  begin
    Inc(X, AClient.Left + AOffset.X);
    Inc(Y, AClient.Top + AOffset.Y);
  end;
  OffsetRect(TextBounds, AClient.Left + ATextPos.X + AOffset.X, AClient.Top + ATextPos.Y + AOffset.X);
end;

procedure TcxButtonGlyph.Draw(ACanvas: TCanvas; const AClient: TRect;
  const AOffset: TPoint; const ACaption: TCaption; ALayout: TButtonLayout;
  AMargin, ASpacing: Integer; AState: TcxButtonState;
  ABiDiFlags: LongInt; ANativeStyle: Boolean{$IFDEF DELPHI7}; AWordWrap: Boolean{$ENDIF});
var
  AGlyphPos: TPoint;
  ATextRect: TRect;
begin
  CalcButtonLayout(ACanvas, AClient, AOffset, ACaption, ALayout, AMargin,
    ASpacing, AGlyphPos, ATextRect, ABiDiFlags{$IFDEF DELPHI7}, AWordWrap{$ENDIF});
  DrawButtonGlyph(ACanvas, AGlyphPos, AState);
  DrawButtonText(ACanvas, ACaption, ATextRect, AState, ABiDiFlags,
    ANativeStyle{$IFDEF DELPHI7}, AWordWrap{$ENDIF});
end;

function TcxButtonGlyph.CanWordWrapText{$IFDEF DELPHI7}(AWordWrap: Boolean){$ENDIF}: Boolean;
begin
{$IFDEF DELPHI7}
  Result := AWordWrap and not ImageInfo.IsImageAssigned;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function TcxButtonGlyph.GetTextOffsets(ALayout: TButtonLayout): TRect;
begin
  if ImageInfo.IsImageAssigned then
    Result := cxNullRect
  else
    Result := TextRectCorrection;
end;

{ TcxButtonActionLink }

destructor TcxButtonActionLink.Destroy;
begin
  if not (csDestroying in Client.ComponentState) then
  begin
    Client.FGlyph.ImageList := nil;
    Client.FGlyph.ImageIndex := -1;
  end;
  inherited;
end;

procedure TcxButtonActionLink.SetImageIndex(Value: Integer);
begin
  inherited;
  Client.FGlyph.ImageIndex := Value;
end;

function TcxButtonActionLink.GetClient: TcxCustomButton;
begin
  Result := TcxButton(FClient);
end;

{ TcxSpeedButtonOptions }

constructor TcxSpeedButtonOptions.Create(AOwner: TcxCustomButton);
begin
  inherited Create;
  FOwner := AOwner;
  CanBeFocused := True;
  GroupIndex := 0;
end;

procedure TcxSpeedButtonOptions.Assign(Source: TPersistent);
begin
  if Source is TcxSpeedButtonOptions then
    with Source as TcxSpeedButtonOptions do
    begin
      Self.GroupIndex := GroupIndex;
      Self.AllowAllUp := AllowAllUp;
      Self.CanBeFocused := CanBeFocused;
      Self.Down := Down;
      Self.Flat := Flat;
      Self.Transparent := Transparent;
    end;
  inherited Assign(Source);
end;

procedure TcxSpeedButtonOptions.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxSpeedButtonOptions.CancelUpdate;
begin
  Dec(FLockCount);
end;

procedure TcxSpeedButtonOptions.EndUpdate;
begin
  Dec(FLockCount);
  UpdateGroup;
end;

function TcxSpeedButtonOptions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxSpeedButtonOptions.UpdateGroupValues(const AGroupIndex: Integer; const ASpeedButtonOptions: TcxSpeedButtonOptions);
begin
  BeginUpdate;
  try
    CanBeFocused := ASpeedButtonOptions.CanBeFocused;
    AllowAllUp := ASpeedButtonOptions.AllowAllUp;
    Flat := ASpeedButtonOptions.Flat;
    Transparent := ASpeedButtonOptions.Transparent;
    if ASpeedButtonOptions.Down and Down then
    begin
      Down := False;
      if (Button.Action is TCustomAction) then
        TCustomAction(Button.Action).Checked := False;
    end;
  finally
    CancelUpdate;
  end;
end;

function TcxSpeedButtonOptions.GetActive: Boolean;
begin
  Result := (FOwner <> nil) and ((FGroupIndex <> 0) or not FCanBeFocused);
end;

function TcxSpeedButtonOptions.GetButton: TcxCustomButton;
begin
  Result := FOwner;
end;

function TcxSpeedButtonOptions.GetDown: Boolean;
begin
  Result := Button.Down;
end;

procedure TcxSpeedButtonOptions.SetAllowAllUp(AValue: Boolean);
begin
  if AValue <> FAllowAllUp then
  begin
    FAllowAllUp := AValue;
    UpdateGroup;
  end;
end;

procedure TcxSpeedButtonOptions.SetCanBeFocused(AValue: Boolean);
begin
  if AValue <> FCanBeFocused then
  begin
    FCanBeFocused := AValue;
    UpdateGroup;
    Button.Repaint;
  end;
end;

procedure TcxSpeedButtonOptions.SetDown(AValue: Boolean);
begin
  if FGroupIndex = 0 then AValue := False;
  if AValue <> Down then
  begin
    if Down and not FAllowAllUp and (FGroupIndex <> 0) and (LockCount = 0) then Exit;
    if AValue then
      Include(Button.FInternalState, bisDown)
    else
      Exclude(Button.FInternalState, bisDown);
    if AValue then
      UpdateGroup;
    Button.Invalidate;
  end;
end;

procedure TcxSpeedButtonOptions.SetFlat(AValue: Boolean);
begin
  if FFlat <> AValue then
  begin
    FFlat := AValue;
    UpdateGroup;
    if Active then
      FOwner.Invalidate;
  end;
end;

procedure TcxSpeedButtonOptions.SetGroupIndex(AValue: Integer);
begin
  if AValue <> FGroupIndex then
  begin
    FGroupIndex := AValue;
    if FGroupIndex = 0 then
      Down := False
    else
      UpdateGroup;
  end;
end;

procedure TcxSpeedButtonOptions.SetTransparent(AValue: Boolean);
begin
  if FTransparent <> AValue then
  begin
    FTransparent := AValue;
    UpdateGroup;
    if Active then
      FOwner.Invalidate;
  end;
end;

procedure TcxSpeedButtonOptions.UpdateGroup;
var
  AMsg: TMessage;
begin
  if (LockCount = 0) and Active and (FGroupIndex <> 0) and (FOwner.Parent <> nil) then
  begin
    AMsg.Msg := CM_BUTTONPRESSED;
    AMsg.WParam := FGroupIndex;
    AMsg.LParam := Longint(FOwner);
    AMsg.Result := 0;
    FOwner.Parent.Broadcast(AMsg);
  end;
end;

{ TcxCustomButton }

constructor TcxCustomButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInternalState := [];
  FGlyph := GetGlyphClass.Create;
  FGlyph.OnChange := GlyphChanged;
  FColors := TcxButtonColors.Create(Self);
  FControlCanvas := TControlCanvas.Create;
  FControlCanvas.Control := Self;
  FCanvas := TcxCanvas.Create(TCanvas(FControlCanvas));
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := LookAndFeelChanged;
  FDoPopup := True;
  FKind := cxbkStandard;
  FLayout := blGlyphLeft;
  FPopupAlignment := paLeft;
  FSpacing := 4;
  FMargin := -1;
  FSpeedButtonOptions := TcxSpeedButtonOptions.Create(Self);
  DoubleBuffered := True;
  ControlStyle := ControlStyle + [csReflector, csOpaque];
end;

destructor TcxCustomButton.Destroy;
begin
  EndMouseTracking(Self);
  FreeAndNil(FSpeedButtonOptions);
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FColors);
  FreeAndNil(FGlyph);
  FreeAndNil(FCanvas);
  FreeAndNil(FControlCanvas);
  inherited Destroy;
end;

procedure TcxCustomButton.InitializeCanvasColors(AState: TcxButtonState; out AColor: TColor);
begin
  FCanvas.Font.Assign(Font);
  AColor := FColors.GetColorByState(AState);

  if FColors.GetTextColorByState(AState) = clDefault then
    FCanvas.Font.Color := GetPainterClass.ButtonSymbolColor(AState, FCanvas.Font.Color)
  else
    FCanvas.Font.Color := FColors.GetTextColorByState(AState);
end;

procedure TcxCustomButton.SetGlyph(Value: TBitmap);
begin
  FGlyph.Glyph := Value;
end;

function TcxCustomButton.GetGlyph: TBitmap;
begin
  Result := FGlyph.Glyph;
end;

procedure TcxCustomButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TcxCustomButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

function TcxCustomButton.GetNumGlyphs: TNumGlyphs;
begin
  Result := FGlyph.NumGlyphs;
end;

procedure TcxCustomButton.SetNumGlyphs(Value: TNumGlyphs);
begin
  FGlyph.NumGlyphs := Value;
end;

procedure TcxCustomButton.SetSpacing(Value: Integer);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TcxCustomButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= - 1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

procedure TcxCustomButton.DoContextPopup(MousePos: TPoint;
  var Handled: Boolean);
var
  P: TPoint;
begin
  inherited DoContextPopup(MousePos, Handled);
  if not Handled then
  begin
    if (MousePos.X = -1) and (MousePos.Y = -1) then
      P := ClientToScreen(Point(0, 0))
    else
      P := ClientToScreen(MousePos);
    Handled := DoShowPopupMenu(PopupMenu, P.X, P.Y);
  end;
end;

function TcxCustomButton.DoOnDropDownMenuPopup(var APopupMenu: TPopupMenu): Boolean;
begin
  Result := False;
  if Assigned(FOnDropDownMenuPopup) then
    FOnDropDownMenuPopup(Self, APopupMenu, Result);
end;

function TcxCustomButton.DoShowPopupMenu(APopupMenu: TComponent;
  X, Y: Integer): Boolean;
begin
  Result := ShowPopupMenu(Self, APopupMenu, X, Y);
end;

function TcxCustomButton.GetGlyphClass: TcxButtonGlyphClass;
begin
  Result := TcxButtonGlyph;
end;

function TcxCustomButton.GetPainterClass: TcxCustomLookAndFeelPainterClass;
begin
  Result := GetButtonPainterClass(LookAndFeel);
end;

function TcxCustomButton.IsDesigning: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

function TcxCustomButton.StandardButton: Boolean;
begin
  Result := False;
end;

procedure TcxCustomButton.UpdateSize;
var
  ASize: TSize;
begin
  if AutoSize then
  begin
    if csLoading in ComponentState then
      ASize := GetOptimalSize
    else
      ASize := Size(0, 0);
    SetBounds(Self.Left, Self.Top, ASize.cx, ASize.cy);
  end;
end;

// IcxLookAndFeelContainer
function TcxCustomButton.GetLookAndFeel: TcxLookAndFeel;
begin
  Result := LookAndFeel;
end;

procedure TcxCustomButton.Click;
begin
  if (bisPressed in InternalState) and CanBeFocused then
    SetDown(not Down);
  if FKind = cxbkStandard then
    inherited Click
  else
  begin
    if (FKind = cxbkDropDown) and not FMenuVisible then
      DoDropDownMenu
    else
      inherited Click;
  end;
end;

function TcxCustomButton.CanFocus: Boolean;
begin
  Result := inherited CanFocus and (CanBeFocused or IsDesigning);
end;

function TcxCustomButton.GetOptimalSize: TSize;
var
  ACanvas: TcxScreenCanvas;
  ACaption: TCaption;
begin
  ACanvas := TcxScreenCanvas.Create;
  try
    ACanvas.Font := Font;
    ACaption := RemoveAccelChars(Caption);
    if ACaption = '' then
      ACaption := ' ';
    Result.cx := ACanvas.TextWidth(ACaption) + ACanvas.TextWidth('R') * 3;
    Result.cy := MulDiv(ACanvas.TextHeight('Wg'), 14, 8);
  finally
    ACanvas.Free;
  end;
end;

function TcxCustomButton.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action);
  UpdateImageInfo;
end;

procedure TcxCustomButton.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  if UseSystemPaint then
    InternalRecreateWindow
  else
    Invalidate;
end;

procedure TcxCustomButton.SetButtonAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then
  begin
    FAutoSize := Value;
    UpdateSize;
  end;
end;

procedure TcxCustomButton.SetColors(const Value: TcxButtonColors);
begin
  FColors.Assign(Value);
end;

procedure TcxCustomButton.SetKind(const Value: TcxButtonKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    InternalRecreateWindow;
  end
end;

procedure TcxCustomButton.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

procedure TcxCustomButton.SetPopupMenu(Value: TComponent);
var
  AIPopupMenu: IcxPopupMenu;
begin
  if (Value <> nil) and not((Value is TPopupMenu) or
    Supports(Value, IcxPopupMenu, AIPopupMenu)) then
      Value := nil;
  if FPopupMenu <> Value then
  begin
    if FPopupMenu <> nil then
      FPopupMenu.RemoveFreeNotification(Self);
    FPopupMenu := Value;
    if FPopupMenu <> nil then
      FPopupMenu.FreeNotification(Self);
  end;
end;

procedure TcxCustomButton.CheckShowMenu(const P: TPoint);
begin
  if FKind = cxbkDropDownButton then
  begin
    if PtInRect(GetMenuButtonBounds, P) then DoDropDownMenu
  end
  else
    DoDropDownMenu;
end;

function TcxCustomButton.GetButtonState: TcxButtonState;
begin
  if not Enabled then Result := cxbsDisabled
  else if FIsPaintPressed then Result := cxbsPressed
  else if ((bisHot in InternalState) or FMenuVisible) and CanHotTrack then Result := cxbsHot
  else if FIsPaintDefault then Result := cxbsDefault
  else Result := cxbsNormal;
end;

function TcxCustomButton.GetDown: Boolean;
begin
  Result := bisDown in InternalState;
end;

function TcxCustomButton.GetMenuButtonBounds: TRect;
begin
  Result := cxNullRect;
  if Kind = cxbkStandard then Exit;
  Result := ClientRect;
  if Kind = cxbkDropDownButton then
    Result.Left := Result.Right - cxDropDownButtonWidth;
end;

function TcxCustomButton.GetAllowAllUp: Boolean;
begin
  Result := FSpeedButtonOptions.AllowAllUp;
end;

function TcxCustomButton.GetCanBeFocused: Boolean;
begin
  Result := (SpeedButtonOptions <> nil) and SpeedButtonOptions.CanBeFocused;
end;

function TcxCustomButton.GetGroupIndex: Integer;
begin
  Result := FSpeedButtonOptions.GroupIndex;
end;

function TcxCustomButton.GetSpeedButtonMode: Boolean;
begin
  Result := not CanBeFocused or (GroupIndex <> 0);
end;

procedure TcxCustomButton.SetAllowAllUp(AValue: Boolean);
begin
  FSpeedButtonOptions.AllowAllUp := AValue;
end;

procedure TcxCustomButton.SetCanBeFocused(AValue: Boolean);
begin
  FSpeedButtonOptions.CanBeFocused := AValue;
end;

procedure TcxCustomButton.SetDown(AValue: Boolean);
begin
  FSpeedButtonOptions.Down := AValue;
end;

procedure TcxCustomButton.SetGroupIndex(AValue: Integer);
begin
  FSpeedButtonOptions.GroupIndex := AValue;
end;

procedure TcxCustomButton.SetSpeedButtonOptions(AValue: TcxSpeedButtonOptions);
begin
  SpeedButtonOptions.Assign(AValue);
end;

procedure TcxCustomButton.WndProc(var Message: TMessage);
begin
  if SpeedButtonMode and not IsDesigning then
  begin
    if (Message.Msg = WM_KEYUP) and (Message.WParam = VK_SPACE) then
      SetDown(not Down);
    if not CanBeFocused then
      case Message.Msg of
        WM_LBUTTONDOWN:
          begin
            with Message do
              MouseDown(mbLeft, KeysToShiftState(WParam), LParamHi, LParamLo);
            Exit;
          end;
        WM_LBUTTONDBLCLK:
          begin
            DblClick;
            Exit;
          end;
      end;
  end;
  inherited WndProc(Message);
end;

procedure TcxCustomButton.ExcludeDropDownButtonRect(var R: TRect);
begin
  if Kind = cxbkDropDownButton then
    R.Right := R.Right - cxDropDownButtonWidth + 2;
end;

procedure TcxCustomButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateSize;
end;

procedure TcxCustomButton.DoDropDownMenu;
begin
  PostMessage(Handle, CM_DROPDOWNPOPUPMENU, 0, 0);
end;

function TcxCustomButton.GetBorderRect(AState: TcxButtonState): TRect;
var
  ABorderSize: Integer;
begin
  Result := ClientRect;
  ABorderSize := GetPainterClass.ButtonBorderSize(AState);
  InflateRect(Result, -ABorderSize, -ABorderSize);
  ExcludeDropDownButtonRect(Result);
end;

function TcxCustomButton.GetContentRect: TRect;
begin
  Result := GetBorderRect(cxbsDefault)
end;

function TcxCustomButton.GetDropDownMenuAlignment(APopupPoint: TPoint;
  AEstimatedAlignment: TPopupAlignment): TPopupAlignment;
var
  ADesktopWorkArea: TRect;
begin
  Result := AEstimatedAlignment;
  ADesktopWorkArea := GetDesktopWorkArea(APopupPoint);
  if APopupPoint.X <= ADesktopWorkArea.Left then
    Result := paRight
  else
    if APopupPoint.X >= ADesktopWorkArea.Right then
      Result := paLeft;
end;

function TcxCustomButton.GetDropDownMenuPopupPoint(ADropDownMenu: TPopupMenu): TPoint;
var
  H: Integer;
begin
    Result := Point(0, Height);
    case FPopupAlignment of
      paLeft:
        Result.X := 0;
      paRight:
        Result.X := Width;
      paCenter:
        Result.X := Width shr 1;
    end;
    Result := ClientToScreen(Result);
    H := GetPopupMenuHeight(ADropDownMenu);
    if Result.Y + H > GetDesktopWorkArea(Result).Bottom then
      Dec(Result.Y, Height + H + 2);
end;

procedure TcxCustomButton.InternalPaint;

  procedure InternalDrawButton(R: TRect; AState: TcxButtonState; AColor: TColor; AIsMenuButton: Boolean = False);

    procedure AdjustMenuButtonRect;
    begin
      if AIsMenuButton then
        Dec(R.Left, GetPainterClass.ButtonBorderSize(AState));
    end;

  var
    ADrawBorder: Boolean;
  begin
    if (SpeedButtonOptions.Flat or SpeedButtonOptions.Transparent) and
      not CanBeFocused and not Assigned(LookAndFeel.SkinPainter) then
    begin
      ADrawBorder := (not SpeedButtonOptions.Flat or (csDesigning in ComponentState) or ((AState <> cxbsDisabled) and
        ((bisHot in InternalState) or (AState <> cxbsNormal)))) and
        not (LookAndFeel.NativeStyle or (LookAndFeel.Kind = lfOffice11));
      if ADrawBorder then
      begin
        AdjustMenuButtonRect;
        GetPainterClass.DrawButtonBorder(FCanvas, R, AState);
        InflateRect(R, -GetPainterClass.ButtonBorderSize(AState), -GetPainterClass.ButtonBorderSize(AState));
      end;
      FCanvas.SaveClipRegion;
      try
        FCanvas.SetClipRegion(TcxRegion.Create(R), roSet);
        if not SpeedButtonOptions.Transparent or ((AState <> cxbsDisabled) and
          (not (bisHot in InternalState) and (AState <> cxbsNormal)) or
          ((bisHot in InternalState) and GetPainterClass.IsButtonHotTrack)) then
            GetPainterClass.DrawButton(FCanvas, R, '', AState, False, AColor, FCanvas.Font.Color, {$IFDEF DELPHI7} WordWrap,{$ELSE} False,{$ENDIF} True)
        else
          cxDrawTransparentControlBackground(Self, FCanvas, ClientRect);
      finally
        FCanvas.RestoreClipRegion;
      end;
    end
    else
      begin
        AdjustMenuButtonRect;
        GetPainterClass.DrawButton(FCanvas, R, '', AState, True, AColor, FCanvas.Font.Color{$IFDEF DELPHI7}, WordWrap{$ENDIF});
      end;
  end;

var
  AColor: TColor;
  AOffset: TPoint;
  AShift: Integer;
  AState: TcxButtonState;
  AButtonMenuState: TcxButtonState;
  ATempRect, R: TRect;
  ATheme: TdxTheme;
begin
  if StandardButton then
    Exit;
  R := ClientRect;
  if GetPainterClass = TcxWinXPLookAndFeelPainter then
  begin
    ATheme := OpenTheme(totButton);
    if (ATheme <> TC_NONE) and IsThemeBackgroundPartiallyTransparent(ATheme, BP_PUSHBUTTON, PBS_NORMAL) then
      cxDrawThemeParentBackground(Self, FCanvas, R);
  end
  else
    if LookAndFeel.SkinPainter <> nil then
      cxDrawTransparentControlBackground(Self, FCanvas, R);

  case FKind of
    cxbkDropDownButton:
      begin
        ATempRect := Rect(R.Right - cxDropDownButtonWidth, R.Top, R.Right, R.Bottom);
        ExcludeDropDownButtonRect(R);
      end;
  end;

  AState := GetButtonState;
  InitializeCanvasColors(AState, AColor);

  if Assigned(FOnGetDrawParams) then
    FOnGetDrawParams(Self, AState, AColor, FCanvas.Font);
  InternalDrawButton(R, AState, AColor);

  AShift := GetPainterClass.ButtonTextShift;
  if (AState = cxbsPressed) and (AShift <> 0) then
    AOffset := Point(AShift, AShift)
  else
    AOffset := cxNullPoint;

  FCanvas.SaveClipRegion;
  try
    FCanvas.SetClipRegion(TcxRegion.Create(GetBorderRect(AState)), roSet);
    UpdateImageInfo;
    FGlyph.Draw(FControlCanvas, GetContentRect, AOffset, Caption, FLayout,
      FMargin, FSpacing, AState, DrawTextBiDiModeFlags(0),
      GetPainterClass = TcxWinXPLookAndFeelPainter{$IFDEF DELPHI7}, WordWrap{$ENDIF});
  finally
    FCanvas.RestoreClipRegion;
  end;

  if FKind = cxbkDropDownButton then
  begin
    AButtonMenuState := AState;
    if FMenuVisible then
      AButtonMenuState := cxbsPressed
    else
      if (AButtonMenuState = cxbsPressed) then
        if FIsFocused then
          AButtonMenuState := cxbsHot
        else
          AButtonMenuState := cxbsNormal;
    InternalDrawButton(ATempRect, AButtonMenuState, AColor, True);
    GetPainterClass.DrawScrollBarArrow(FCanvas, ATempRect, AButtonMenuState, adDown);
  end;

  if CanFocus then
    if Focused and not FMenuVisible then
      FCanvas.DrawFocusRect(GetPainterClass.ButtonFocusRect(FCanvas, R));
end;

procedure TcxCustomButton.InternalRecreateWindow;
begin
  RecreateWnd;
end;

function TcxCustomButton.IsColorsStored: Boolean;
begin
  Result := FColors.AssignedColors <> [];
end;

function TcxCustomButton.CanHotTrack: Boolean;
begin
  Result := not StandardButton and GetPainterClass.IsButtonHotTrack and Enabled;
end;

procedure TcxCustomButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  UpdateImageInfo;
end;

function TcxCustomButton.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  if AutoSize then
    with GetOptimalSize do
    begin
      NewWidth := cx;
      NewHeight := cy;
    end;
  Result := inherited CanResize(NewWidth, NewHeight);
end;

function TcxCustomButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TcxButtonActionLink;
end;

procedure TcxCustomButton.DblClick;
begin
  if not CanBeFocused then
    SetCapture(Handle);
  if GroupIndex <> 0 then
    inherited DblClick;
  Include(FInternalState, bisPressed);
  Invalidate;
end;

procedure TcxCustomButton.MouseEnter;
begin
  BeginMouseTracking(Self, Rect(0, 0, Width, Height), Self);
  Include(FInternalState, bisHot);
  if Enabled then
    Repaint;
end;

procedure TcxCustomButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FKind = cxbkDropDownButton then
    if (Key in [VK_UP, VK_DOWN]) and
      ((ssAlt in Shift) or (ssShift in Shift)) then
    begin
      if not FMenuVisible then DoDropDownMenu;
      Key := 0;
      Exit
    end;
  inherited;
end;

procedure TcxCustomButton.MouseLeave;
begin
  EndMouseTracking(Self);
  Exclude(FInternalState, bisHot);
  Invalidate;
end;

procedure TcxCustomButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not CanBeFocused then
    SetCapture(Handle);
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) then
  begin
    Include(FInternalState, bisPressed);
    if Kind <> cxbkStandard then
      CheckShowMenu(Point(X, Y));
    Invalidate;
  end;
end;

procedure TcxCustomButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if not (bisHot in InternalState) and PtInRect(ClientRect, Point(X, Y)) then
    MouseEnter;
end;

procedure TcxCustomButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  AExecuteClick: Boolean;
begin
  AExecuteClick := not CanBeFocused and (Button = mbLeft) and
    ([bisPressed, bisHot] * InternalState = [bisPressed, bisHot]);
  Exclude(FInternalState, bisPressed);
  if AExecuteClick then
    SetDown(not Down);
  inherited MouseUp(Button, Shift, X, Y);
  if AExecuteClick then
    Click;
  Invalidate;
  if not CanBeFocused and (GetCapture = Handle) then
    ReleaseCapture;
end;

procedure TcxCustomButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDropDownMenu then
      FDropDownMenu := nil
    else
      if AComponent = PopupMenu then
        PopupMenu := nil;
  end;
end;

procedure TcxCustomButton.DrawItem(const DrawItemStruct: TDrawItemStruct);
begin
  FCanvas.Canvas.Handle := DrawItemStruct.hDC;
  with DrawItemStruct do
  begin
    FIsPaintPressed := (itemState and ODS_SELECTED <> 0) or
      (SpeedButtonMode and (Down or FMenuVisible or ([bisPressed, bisHot] * InternalState = [bisPressed, bisHot])));
    FIsPaintDefault := ((itemState and ODS_FOCUS <> 0) or (Default and IsDesigning) or FIsFocused) and CanBeFocused;
  end;
  InternalPaint;
  FCanvas.Canvas.Handle := 0;
end;

procedure TcxCustomButton.UpdateImageInfo;

  function GetImageList: TCustomImageList;
  begin
    if (Action is TCustomAction) and (TCustomAction(Action).ActionList <> nil) then
      Result := TCustomAction(Action).ActionList.Images
    else
      Result := nil;
  end;

  function GetImageIndex: Integer;
  begin
    if Action is TCustomAction then
      Result := TCustomAction(Action).ImageIndex
    else
      Result := -1;
  end;

begin
  FGlyph.ImageList := GetImageList;
  FGlyph.ImageIndex := GetImageIndex;
end;

procedure TcxCustomButton.WMCaptureChanged(var Message: TMessage);
var
  P: TPoint;
begin
  inherited;
  if not IsDesigning then
  begin
    GetCursorPos(P);
    if WindowFromPoint(P) <> Handle then
    begin
      Exclude(FInternalState, bisHot);
      Exclude(FInternalState, bisPressed);
      Invalidate;
    end;
  end;
end;

procedure TcxCustomButton.WMContextMenu(var Message: TWMContextMenu);
var
  AHandled: Boolean;
  P, P1: TPoint;
begin
  if Message.Result <> 0 then
    Exit;
  if IsDesigning then
  begin
    inherited;
    Exit;
  end;

  P := SmallPointToPoint(Message.Pos);
  if (P.X = -1) and (P.Y = -1) then
    P1 := P
  else
  begin
    P1 := ScreenToClient(P);
    if not PtInRect(ClientRect, P1) then
    begin
      inherited;
      Exit;
    end;
  end;

  AHandled := False;
  DoContextPopup(P1, AHandled);
  Message.Result := Ord(AHandled);
  if not AHandled then
    inherited;
end;

procedure TcxCustomButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
{$IFNDEF DELPHI7}
  if (csDestroying in ComponentState) or StandardButton or
    (GetPainterClass = TcxWinXPLookAndFeelPainter) then
      inherited
  else
{$ENDIF}
    Message.Result := 1;
end;

procedure TcxCustomButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  Perform(WM_LBUTTONDOWN, Message.Keys,
    LPARAM(Word(Message.XPos) or (Word(Message.YPos) shr 16)));
end;

procedure TcxCustomButton.WMLButtonDown(var Message: TWMLButtonDown);
var
  R: TRect;
begin
  if FKind = cxbkDropDownButton then
  begin
    R := ClientRect;
    R.Left := R.Right - cxDropDownButtonWidth;
  end;
  inherited;
end;

procedure TcxCustomButton.CMCloseupPopupMenu(var Message: TMessage);
begin
  Exclude(FInternalState, bisPressed);
  FMenuVisible := False;
  Repaint;
end;

procedure TcxCustomButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if IsAccel(Message.CharCode, Caption) and inherited CanFocus then
  begin
    Click;
    Message.Result := 1;
  end
  else
    inherited;
end;

procedure TcxCustomButton.CMDropDownPopupMenu(var Message: TMessage);
var
  P: TPoint;
  APopupAlignment: TPopupAlignment;
  APopupMenu: TPopupMenu;
begin
  if (Kind <> cxbkStandard) then
  begin
    APopupMenu := FDropDownMenu;
    if DoOnDropDownMenuPopup(APopupMenu) or (APopupMenu = nil) then
      Exit;
    FMenuVisible := True;
    Repaint;
    P := GetDropDownMenuPopupPoint(APopupMenu);
    APopupAlignment := APopupMenu.Alignment;
    try
      APopupMenu.Alignment := GetDropDownMenuAlignment(P, FPopupAlignment);
      APopupMenu.PopupComponent := Self;
      APopupMenu.Popup(P.X, P.Y);
    finally
      APopupMenu.Alignment := APopupAlignment;
    end;
    PostMessage(Handle, CM_CLOSEUPPOPUPMENU, 0, 0);
  end;
end;

procedure TcxCustomButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateSize;
  Invalidate;
end;

procedure TcxCustomButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not Enabled then
    Exclude(FInternalState, bisHot);
  Invalidate;
end;

procedure TcxCustomButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
{$IFDEF DELPHI7}
  if IsDesigning then Exit;
{$ENDIF}
  MouseEnter;
end;

procedure TcxCustomButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
{$IFDEF DELPHI7}
  if IsDesigning then Exit;
{$ENDIF}
  MouseLeave;
end;

procedure TcxCustomButton.CNDrawItem(var Message: TWMDrawItem);
begin
  if not(csDestroying in ComponentState) then
    DrawItem(Message.DrawItemStruct^);
end;

procedure TcxCustomButton.CNKeyDown(var Message: TWMKeyDown);
begin
  if IsPopupMenuShortCut(PopupMenu, Message) then
    Message.Result := 1
  else
    inherited;
end;

procedure TcxCustomButton.CNMeasureItem(var Message: TWMMeasureItem);
var
  ATempVar: TMeasureItemStruct;
begin
  ATempVar := Message.MeasureItemStruct^;
  ATempVar.itemWidth := Width;
  ATempVar.itemHeight := Height;
  Message.MeasureItemStruct^ := ATempVar;
end;

procedure TcxCustomButton.CNSysKeyDown(var Message: TWMSysKeyDown);
begin
  if IsPopupMenuShortCut(PopupMenu, Message) then
    Message.Result := 1
  else
    inherited;
end;

procedure TcxCustomButton.CMButtonPressed(var Message: TMessage);
var
  ASender: TcxButton;
begin
  if SpeedButtonMode then
  begin
    if (Message.WParam = GroupIndex) and (GroupIndex <> 0) and
      (TObject(Message.LParam) is TcxCustomButton) then
    begin
      ASender := TcxButton(Message.LParam);
      if ASender <> Self then
      begin
        SpeedButtonOptions.UpdateGroupValues(GroupIndex, ASender.SpeedButtonOptions);
        Invalidate;
      end;
    end;
  end;
end;

procedure TcxCustomButton.CreateHandle;
var
  AState: TcxButtonState;
begin
  if Enabled then
    AState := cxbsNormal
  else
    AState := cxbsDisabled;
  inherited CreateHandle;
  FGlyph.CreateButtonGlyph(AState);
end;

procedure TcxCustomButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not StandardButton then
    with Params do Style := Style or BS_OWNERDRAW;
end;

procedure TcxCustomButton.DestroyWindowHandle;
begin
  if FMenuVisible then
    SendMessage(Handle, CM_CLOSEUPPOPUPMENU, 0, 0);
  inherited DestroyWindowHandle;
end;

function TcxCustomButton.GetPalette: HPALETTE;
begin
  Result := Glyph.Palette;
end;

procedure TcxCustomButton.SetButtonStyle(ADefault: Boolean);
begin
  if StandardButton then
    inherited SetButtonStyle(ADefault)
  else
    if ADefault <> FIsFocused then
    begin
      FIsFocused := ADefault;
      Refresh;
    end;
end;

end.

