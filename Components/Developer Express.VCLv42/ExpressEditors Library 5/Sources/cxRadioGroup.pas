
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

unit cxRadioGroup;

{$I cxVer.inc}

interface

uses
   Windows,
  Messages,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Classes, Controls, Forms, Graphics, ImgList, StdCtrls, SysUtils, cxClasses,
  cxContainer, cxControls, cxDataStorage, cxEdit, cxGraphics, cxLookAndFeels,
  Menus, cxTextEdit, cxGroupBox, dxUxTheme, cxDropDownEdit, cxFilterControlUtils;

type
  TcxRadioButtonState = (rbsDisabled, rbsHot, rbsNormal, rbsPressed);
  TcxRadioGroupState = (rgsActive, rgsDisabled, rgsHot, rgsNormal);

  TcxCustomRadioGroup = class;
  TcxCustomRadioGroupProperties = class;

  { TcxRadioButton }

  TcxRadioButton = class(TRadioButton, IUnknown,
    IcxMouseTrackingCaller, IcxLookAndFeelContainer, IdxSkinSupport)
  private
    FButtonRect: TRect;
    FCanvas: TcxCanvas;
    FColumn: Integer;
    FControlCanvas: TControlCanvas;
    FLookAndFeel: TcxLookAndFeel;
    FPopupMenu: TComponent;
    FRow: Integer;
    FState: TcxRadioButtonState;
    FTransparent: Boolean;
  {$IFNDEF DELPHI7}
    FParentBackground: Boolean;
    FWordWrap: Boolean;
  {$ENDIF}
    function GetTextColor: TColor;
    procedure DrawItem(const DrawItemStruct: TDrawItemStruct);
    function IsDisabledTextColorAssigned: Boolean;
    function GetRadioButtonRect(const ARadioButtonSize: TSize;
      ANativeStyle: Boolean): TRect;
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure SetPopupMenu(Value: TComponent);
    procedure SetState(Value: TcxRadioButtonState);
    procedure SetTransparent(Value: Boolean);
  {$IFNDEF DELPHI7}
    procedure SetParentBackground(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
  {$ENDIF}
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
      message WM_WINDOWPOSCHANGED;
    procedure BMSetCheck(var Message: TMessage); message BM_SETCHECK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CNSysKeyDown(var Message: TWMSysKeyDown); message CN_SYSKEYDOWN;
  protected
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoEnter; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CorrectTextRect(var R: TRect; ANativeStyle: Boolean); virtual;
    procedure DoContextPopup(MousePos: TPoint;
      var Handled: Boolean); {$IFNDEF DELPHI5}virtual{$ELSE}override{$ENDIF};
    function DoShowPopupMenu(APopupMenu: TComponent;
      X, Y: Integer): Boolean; virtual;
    procedure DrawBackground; virtual;
    procedure DrawCaption(ACanvas: TcxCanvas; ANativeStyle: Boolean); virtual;
    procedure EnabledChanged; dynamic;
    procedure InternalPolyLine(const APoints: array of TPoint);
    function IsInplace: Boolean; virtual;
    function IsNativeBackground: Boolean; virtual;
    function IsNativeStyle: Boolean; virtual;
    function IsTransparent: Boolean; virtual;
    function IsTransparentBackground: Boolean; virtual;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); virtual;
    procedure MouseEnter(AControl: TControl); dynamic;
    procedure MouseLeave(AControl: TControl); dynamic;
    procedure Paint(ADrawOnlyFocusedState: Boolean); virtual;
    procedure ShortUpdateState;
    procedure UpdateState(Button: TcxMouseButton; Shift: TShiftState;
      const P: TPoint); virtual;

    // IcxMouseTrackingCaller
    procedure IcxMouseTrackingCaller.MouseLeave = MouseTrackingCallerMouseLeave;
    procedure MouseTrackingCallerMouseLeave;

    // IcxLookAndFeelContainer
    function GetLookAndFeel: TcxLookAndFeel;

    property Canvas: TcxCanvas read FCanvas;
    property Column: Integer read FColumn;
    property Row: Integer read FRow;
    property State: TcxRadioButtonState read FState write SetState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Focused: Boolean; override;
    procedure Invalidate; override;
  published
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property PopupMenu: TComponent read FPopupMenu write SetPopupMenu;
    property ParentBackground{$IFNDEF DELPHI7}: Boolean read FParentBackground write SetParentBackground{$ENDIF} default True;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  {$IFNDEF DELPHI7}
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  {$ENDIF}
  end;

  {  TcxRadioGroupButtonViewInfo  }

  TcxRadioGroupButtonViewInfo = class(TcxGroupBoxButtonViewInfo)
  public
    function GetGlyphRect(ACanvas: TcxCanvas; AGlyphSize: TSize; AAlignment: TLeftRight; AIsPaintCopy: Boolean): TRect; override;
  end;

  { TcxCustomRadioGroupViewInfo }

  TcxCustomRadioGroupViewInfo = class(TcxButtonGroupViewInfo)
  private
    function GetEdit: TcxCustomRadioGroup;
    function ThemeHandle: TdxTheme;
  protected
    procedure DrawButtonCaption(ACanvas: TcxCanvas;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect); override;
    procedure DrawButtonGlyph(ACanvas: TcxCanvas;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect); override;
    function GetButtonViewInfoClass: TcxEditButtonViewInfoClass; override;
    function IsButtonGlypthTransparent(AButtonViewInfo: TcxGroupBoxButtonViewInfo): Boolean; override;
  public
    ItemIndex: Integer;
    constructor Create; override;
    property Edit: TcxCustomRadioGroup read GetEdit;
  end;

  { TcxCustomRadioGroupViewData }

  TcxCustomRadioGroupViewData = class(TcxButtonGroupViewData)
  private
    function GetProperties: TcxCustomRadioGroupProperties;
  protected
    procedure GetEditMetrics(AAutoHeight: Boolean; ACanvas: TcxCanvas;
      out AMetrics: TcxEditMetrics); override;
    procedure CalculateButtonNativeState(AViewInfo: TcxCustomEditViewInfo;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo); override;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    property Properties: TcxCustomRadioGroupProperties read GetProperties;
  end;

  { TcxRadioGroupItem }

  TcxRadioGroupItem = class(TcxButtonGroupItem)
  private
    FValue: TcxEditValue;
    function IsValueStored: Boolean;
    procedure SetValue(const Value: TcxEditValue);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption;
    property Value: TcxEditValue read FValue write SetValue stored IsValueStored;
    property Tag;
  end;

  { TcxRadioGroupItems }

  TcxRadioGroupItems = class(TcxButtonGroupItems)
  private
    function GetItem(Index: Integer): TcxRadioGroupItem;
    procedure SetItem(Index: Integer; Value: TcxRadioGroupItem);
  public
    function Add: TcxRadioGroupItem;
    property Items[Index: Integer]: TcxRadioGroupItem
      read GetItem write SetItem; default;
  end;

  { TcxCustomRadioGroupProperties }

  TcxCustomRadioGroupProperties = class(TcxCustomButtonGroupProperties)
  private
    FDefaultCaption: WideString;
    FDefaultValue: TcxEditValue;
    function GetItems: TcxRadioGroupItems;
    function IsDefaultCaptionStored: Boolean;
    function IsDefaultValueStored: Boolean;
    procedure SetDefaultValue(const Value: TcxEditValue);
    procedure SetItems(Value: TcxRadioGroupItems);
  protected
    function CreateItems: TcxButtonGroupItems; override;
    function GetColumnCount: Integer; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; override;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetRadioGroupItemIndex(const AEditValue: TcxEditValue): Integer;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsResetEditClass: Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    // !!!
    property DefaultCaption: WideString read FDefaultCaption
      write FDefaultCaption stored IsDefaultCaptionStored;
    property DefaultValue: TcxEditValue read FDefaultValue write SetDefaultValue
      stored IsDefaultValueStored;
    property Items: TcxRadioGroupItems read GetItems write SetItems;
  end;

  { TcxRadioGroupProperties }

  TcxRadioGroupProperties = class(TcxCustomRadioGroupProperties)
  published
    property AssignedValues;
    property ClearKey;
    property Columns;
    property DefaultCaption;
    property DefaultValue;
    property ImmediatePost;
    property Items;
    property ReadOnly;
    property WordWrap;
    property OnChange;
    property OnEditValueChanged;
  end;

  { TcxCustomRadioGroupButton }

  TcxCustomRadioGroupButton = class(TcxRadioButton, IUnknown,
    IcxContainerInnerControl)
  private
    FFocusingByMouse: Boolean;
    FInternalSettingChecked: Boolean;
    FIsClickLocked: Boolean;
    function GetRadioGroup: TcxCustomRadioGroup;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure Click; override;
    procedure CorrectTextRect(var R: TRect; ANativeStyle: Boolean); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DrawBackground; override;
    function IsInplace: Boolean; override;
    function IsNativeBackground: Boolean; override;
    function IsNativeStyle: Boolean; override;
    function IsTransparent: Boolean; override;
    function IsTransparentBackground: Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure Paint(ADrawOnlyFocusedState: Boolean); override;
    procedure SetChecked(Value: Boolean); override;
    procedure WndProc(var Message: TMessage); override;

    // IcxContainerInnerControl
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;

    procedure InternalSetChecked(AValue: Boolean);

    property RadioGroup: TcxCustomRadioGroup read GetRadioGroup;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CanFocus: Boolean; override;
    procedure DefaultHandler(var Message); override;
  end;

  TcxCustomRadioGroupButtonClass = class of TcxCustomRadioGroupButton;

  { TcxCustomRadioGroup }

  TcxCustomRadioGroup = class(TcxCustomButtonGroup)
  private
    FLoadedItemIndex: Integer;
    FSkinsPaintCopy: Boolean;
    function GetCheckedIndex: Integer;
    function GetButton(Index: Integer): TcxCustomRadioGroupButton;
    function GetProperties: TcxCustomRadioGroupProperties;
    function GetActiveProperties: TcxCustomRadioGroupProperties;
    function GetItemIndex: Integer;
    function GetViewInfo: TcxCustomRadioGroupViewInfo;
    procedure SetItemIndex(Value: Integer);
    procedure SetProperties(Value: TcxCustomRadioGroupProperties);
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CursorChanged; override;
    function GetButtonDC(AButtonIndex: Integer): THandle; override;
    procedure Initialize; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    function IsContainerFocused: Boolean; override;
    function IsDBEditPaintCopyDrawing: Boolean; override;
    function IsInternalControl(AControl: TControl): Boolean; override;
    procedure SetDragMode(Value: TDragMode); override;
    procedure SetInternalValues(const AEditValue: TcxEditValue;
      AValidateEditValue, AFromButtonChecked: Boolean);
    procedure SynchronizeButtonsStyle; override;
    procedure ParentBackgroundChanged; override;
    procedure Resize; override;
    procedure SetDragKind(Value: TDragKind); override;
    procedure ArrangeButtons; override;
    function GetButtonInstance: TWinControl; override;
    procedure UpdateButtons; override;

    procedure AfterLoading;
    function IsLoading: Boolean;
    procedure Loaded; override;
    procedure Updated; override;

  {$IFNDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    procedure ButtonChecked(AButton: TcxCustomRadioGroupButton);

    property ViewInfo: TcxCustomRadioGroupViewInfo read GetViewInfo;
    property SkinsPaintCopy: Boolean read FSkinsPaintCopy write FSkinsPaintCopy;
  public
    procedure Activate(var AEditData: TcxCustomEditData); override;
    procedure Clear; override;
    procedure FlipChildren(AllLevels: Boolean); override;
  {$IFDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure GetTabOrderList(List: TList); override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure SetFocus; override;
    property ActiveProperties: TcxCustomRadioGroupProperties read GetActiveProperties;
    property Buttons[Index: Integer]: TcxCustomRadioGroupButton read GetButton;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property Properties: TcxCustomRadioGroupProperties read GetProperties
      write SetProperties;
    property Transparent;
  end;

  { TcxRadioGroup }

  TcxRadioGroup = class(TcxCustomRadioGroup)
  private
    function GetActiveProperties: TcxRadioGroupProperties;
    function GetProperties: TcxRadioGroupProperties;
    procedure SetProperties(Value: TcxRadioGroupProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxRadioGroupProperties read GetActiveProperties;
  published
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentBackground;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxRadioGroupProperties read GetProperties write SetProperties;
    property ItemIndex;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
  end;

  { TcxFilterRadioGroupHelper }

  TcxFilterRadioGroupHelper = class(TcxFilterComboBoxHelper)
  public
    class procedure GetFilterValue(AEdit: TcxCustomEdit;
      AEditProperties: TcxCustomEditProperties; var V: Variant; var S: TCaption); override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
    class procedure SetFilterValue(AEdit: TcxCustomEdit; AEditProperties: TcxCustomEditProperties;
      AValue: Variant); override;
    class function UseDisplayValue: Boolean; override;
  end;

implementation

uses
  Math, dxThemeConsts, dxThemeManager, cxVariants, cxLookAndFeelPainters,
  cxEditConsts, cxEditPaintUtils, cxEditUtils;

const
  AButtonStateMap: array [TcxRadioButtonState] of TcxButtonState =
    (cxbsDisabled, cxbsHot, cxbsNormal, cxbsPressed);

type
  TCanvasAccess = class(TCanvas);

function InternalGetShiftState: TShiftState;
var
  AKeyState: TKeyBoardState;
begin
  GetKeyboardState(AKeyState);
  Result := KeyboardStateToShiftState(AKeyState);
end;

{ TcxRadioButton }

constructor TcxRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDoubleClicks];
  FControlCanvas := TControlCanvas.Create;
  FControlCanvas.Control := Self;
  FCanvas := TcxCanvas.Create(TCanvas(FControlCanvas));
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := LookAndFeelChanged;
  FState := rbsNormal;
  ParentBackground := True;
  PrepareRadioButtonImageList;
end;

destructor TcxRadioButton.Destroy;
begin
  EndMouseTracking(Self);
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FCanvas);
  FreeAndNil(FControlCanvas);
  inherited Destroy;
end;

function TcxRadioButton.Focused: Boolean;
begin
  Result := not(csDesigning in ComponentState) and
    inherited Focused;
end;

procedure TcxRadioButton.Invalidate;
begin
  InternalInvalidateRect(Self, Rect(0, 0, Width, Height), False);
end;

procedure TcxRadioButton.DoEnter;
begin
  inherited DoEnter;
  if not Checked and not ClicksDisabled then
  begin
    ClicksDisabled := True;
    try
      Checked := True;
    finally
      ClicksDisabled := False;
      if not (csLoading in ComponentState) then
        Click;
    end;
  end;
end;

procedure TcxRadioButton.DrawCaption(ACanvas: TcxCanvas; ANativeStyle: Boolean);

  function GetDrawTextFlags: Integer;
  begin
    Result := cxAlignLeft or cxAlignVCenter or cxShowPrefix;
    if WordWrap then
      Result := Result or cxDontClip or cxWordBreak
    else
      Result := Result or cxSingleLine;
  end;

  procedure CheckFocusRect(var R: TRect);
  begin
    if IsInplace then
    begin
      R.Top := Max(R.Top, 1);
      R.Bottom := Min(R.Bottom, Height - 1);
      R.Right := Min(R.Right, Width);
    end
    else
    begin
      R.Left := Min(R.Left, 0);
      R.Top := Min(R.Top, 0);
      R.Right := Min(R.Right, Width);
      R.Bottom := Min(R.Bottom, Height);
      if (Alignment = taLeftJustify) and (R.Right > FButtonRect.Left) then
        R.Right := FButtonRect.Left;
    end;
  end;

var
  AFlags: Integer;
  R: TRect;
begin
  ACanvas.Font.Assign(Font);
  TCanvasAccess(ACanvas.Canvas).RequiredState([csFontValid]);
  ACanvas.Font.Color := GetTextColor;

  R := GetControlRect(Self);
  if Alignment = taRightJustify then
    R.Left := FButtonRect.Right
  else
    R.Right := FButtonRect.Left;
  ACanvas.Brush.Style := bsClear;
  CorrectTextRect(R, ANativeStyle);
  AFlags := GetDrawTextFlags;
  if IsNativeBackground then
    ACanvas.Canvas.Refresh;
  ACanvas.DrawText(Caption, R, AFlags, IsDisabledTextColorAssigned or
    Supports(Self, IcxContainerInnerControl) or ANativeStyle or Enabled);
  ACanvas.Brush.Style := bsSolid;
  if Focused and (Caption <> '') then
  begin
    ACanvas.TextExtent(Caption, R, AFlags);
    InflateRect(R, 1, 1);
    Inc(R.Bottom);
    if IsInplace then
      CheckFocusRect(R);
    ACanvas.Brush.Color := Color;
    ACanvas.Font.Color := Font.Color;
    TCanvasAccess(ACanvas.Canvas).RequiredState([csFontValid]);
    ACanvas.Canvas.DrawFocusRect(R);
  end;
end;

procedure TcxRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  UpdateState(ButtonTocxButton(Button), Shift, Point(X, Y));
end;

procedure TcxRadioButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  UpdateState(cxmbNone, Shift, Point(X, Y));
  BeginMouseTracking(Self, GetControlRect(Self), Self);
end;

procedure TcxRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  UpdateState(ButtonTocxButton(Button), Shift, Point(X, Y));
end;

procedure TcxRadioButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = PopupMenu) then
    PopupMenu := nil;
end;

procedure TcxRadioButton.CreateHandle;
begin
  inherited CreateHandle;
  ShortUpdateState;
end;

procedure TcxRadioButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style and not BS_RADIOBUTTON or BS_OWNERDRAW;
end;

procedure TcxRadioButton.CorrectTextRect(var R: TRect; ANativeStyle: Boolean);

  function GetTextRectCorrection: TRect;
  const
    AInplaceTextRectCorrectionA: array [Boolean] of TRect = (
      (Left: 5; Top: 0; Right: 1; Bottom: 0),
      (Left: 3; Top: 0; Right: 0; Bottom: 0)
    );
    ATextRectCorrectionA: array [Boolean, TLeftRight] of TRect = (
     ((Left: 2; Top: -1; Right: 1; Bottom: 0),
      (Left: 5; Top: -1; Right: 0; Bottom: 0)),
     ((Left: 2; Top: -1; Right: 6; Bottom: 0),
      (Left: 5; Top: -1; Right: 2; Bottom: 0))
      );
    ANativeStyleTextRectCorrectionA: array [Boolean, TLeftRight] of TRect = (
     ((Left: 0; Top: -1; Right: 1; Bottom: 0),
      (Left: 3; Top: -1; Right: 0; Bottom: 0)),
     ((Left: 0; Top: -1; Right: 3; Bottom: 0),
      (Left: 3; Top: -1; Right: 0; Bottom: 0))
    );
  begin
    if IsInplace then
      Result := AInplaceTextRectCorrectionA[ANativeStyle]
    else
      if ANativeStyle then
      begin
        Result := ANativeStyleTextRectCorrectionA[WordWrap, Alignment];
        if EmulateStandardControlDrawing then
        begin
          Result.Top := 0;
          Result.Bottom := 0;
        end;
      end
      else
        Result := ATextRectCorrectionA[WordWrap, Alignment];
  end;

begin
  ExtendRect(R, GetTextRectCorrection);
end;

procedure TcxRadioButton.DoContextPopup(MousePos: TPoint;
  var Handled: Boolean);
var
  P: TPoint;
begin
{$IFDEF DELPHI5}
  inherited DoContextPopup(MousePos, Handled);
{$ENDIF}
  if not Handled then
  begin
    if (MousePos.X = -1) and (MousePos.Y = -1) then
      P := ClientToScreen(Point(0, 0))
    else
      P := ClientToScreen(MousePos);
    Handled := DoShowPopupMenu(PopupMenu, P.X, P.Y);
  end;
end;

function TcxRadioButton.DoShowPopupMenu(APopupMenu: TComponent;
  X, Y: Integer): Boolean;
begin
  Result := ShowPopupMenu(Self, APopupMenu, X, Y);
end;

procedure TcxRadioButton.DrawBackground;
begin
  if not IsTransparentBackground then
    cxEditFillRect(Canvas, GetControlRect(Self), Color);
end;

procedure TcxRadioButton.EnabledChanged;
begin
  ShortUpdateState;
  Invalidate;
end;

function TcxRadioButton.GetTextColor: TColor;
begin
  Result := clDefault;
  if Font.Color = clWindowText then
    Result := LookAndFeel.Painter.DefaultEditorTextColor(not Enabled);
  if Result = clDefault then
  begin
    if Enabled or Supports(Self, IcxContainerInnerControl) then
      Result := Font.Color
    else
      Result := clBtnShadow;
  end;
end;

procedure TcxRadioButton.InternalPolyLine(const APoints: array of TPoint);
begin
  Canvas.Polyline(APoints);
  with APoints[High(APoints)] do
    Canvas.Pixels[X, Y] := Canvas.Pen.Color;
end;

function TcxRadioButton.IsDisabledTextColorAssigned: Boolean;
begin
  Result := LookAndFeel.Painter.DefaultEditorTextColor(True) <> clDefault;
end;

function TcxRadioButton.IsInplace: Boolean;
begin
  Result := False;
end;

function TcxRadioButton.IsNativeBackground: Boolean;
begin
  Result := IsNativeStyle and ParentBackground and not IsInplace and
    not Transparent;
end;

function TcxRadioButton.IsNativeStyle: Boolean;
begin
  Result := AreVisualStylesMustBeUsed(LookAndFeel.NativeStyle, totButton);
end;

function TcxRadioButton.IsTransparent: Boolean;
begin
  Result := Transparent and not IsInplace;
end;

function TcxRadioButton.IsTransparentBackground: Boolean;
begin
  Result := IsNativeBackground or IsTransparent;
end;

procedure TcxRadioButton.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  Invalidate;
end;

procedure TcxRadioButton.MouseEnter(AControl: TControl);
begin
  ShortUpdateState;
  BeginMouseTracking(Self, GetControlRect(Self), Self);
end;

procedure TcxRadioButton.MouseLeave(AControl: TControl);
begin
  UpdateState(cxmbNone, [], Point(-1, -1));
  EndMouseTracking(Self);
end;

procedure TcxRadioButton.Paint(ADrawOnlyFocusedState: Boolean);

  function GetBackgroundColor: TColor;
  begin
    if IsTransparentBackground then
    begin
      if LookAndFeel.SkinPainter <> nil then
        Result := clNone
      else
        Result := clDefault;
    end else
      Result := Color;
  end;

  function GetNativeState: Integer;
  const
    ANativeStateMap: array [Boolean, TcxRadioButtonState] of Integer = (
      (RBS_UNCHECKEDDISABLED, RBS_UNCHECKEDHOT, RBS_UNCHECKEDNORMAL,
      RBS_UNCHECKEDPRESSED),
      (RBS_CHECKEDDISABLED, RBS_CHECKEDHOT, RBS_CHECKEDNORMAL,
      RBS_CHECKEDPRESSED)
    );
  begin
    Result := ANativeStateMap[Checked, FState];
  end;

var
  ARadioButtonSize: TSize;
  APainter: TcxCustomLookAndFeelPainterClass;
begin
  if not ADrawOnlyFocusedState then
  begin
    if IsTransparent then
      cxDrawTransparentControlBackground(Self, Canvas, GetControlRect(Self))
    else
      if IsNativeBackground then
        cxDrawThemeParentBackground(Self, Canvas, GetControlRect(Self));
    if IsNativeStyle then
      DrawBackground;
  end;

  APainter := LookAndFeel.GetAvailablePainter(totButton);
  ARadioButtonSize := APainter.RadioButtonSize;
  FButtonRect := GetRadioButtonRect(ARadioButtonSize, IsNativeStyle);

  APainter.DrawRadioButton(Canvas, FButtonRect.Left, FButtonRect.Top,
    AButtonStateMap[State], Checked, Focused, GetBackgroundColor,
    csDesigning in ComponentState);
  Canvas.ExcludeClipRect(FButtonRect);

  if not ADrawOnlyFocusedState and not IsNativeStyle then
    DrawBackground;

  DrawCaption(Canvas, IsNativeStyle);
end;

procedure TcxRadioButton.ShortUpdateState;
begin
  if not HandleAllocated then
    Exit;
  UpdateState(cxmbNone, InternalGetShiftState, ScreenToClient(InternalGetCursorPos));
end;

procedure TcxRadioButton.UpdateState(Button: TcxMouseButton; Shift: TShiftState;
  const P: TPoint);
begin
  if not Enabled then
    State := rbsDisabled
  else
    if (csDesigning in ComponentState) then
      State := rbsNormal
    else
      if GetCaptureControl = Self then // VCL only
        if PtInRect(GetControlRect(Self), P) then
          State := rbsPressed
        else
          State := rbsHot
      else
        if PtInRect(GetControlRect(Self), P) then
        begin
            if Shift = [] then
              State := rbsHot
            else
              State := rbsNormal
        end
        else
          State := rbsNormal;
end;

// IcxMouseTrackingCaller
procedure TcxRadioButton.MouseTrackingCallerMouseLeave;
begin
  MouseLeave(nil);
end;

// IcxLookAndFeelContainer
function TcxRadioButton.GetLookAndFeel: TcxLookAndFeel;
begin
  Result := LookAndFeel;
end;

procedure TcxRadioButton.DrawItem(const DrawItemStruct: TDrawItemStruct);
begin
  FCanvas.Canvas.Handle := DrawItemStruct.hDC;
  Paint(DrawItemStruct.itemAction = ODA_FOCUS); // SC bug B19151
  FCanvas.Canvas.Handle := 0;
end;

function TcxRadioButton.GetRadioButtonRect(const ARadioButtonSize: TSize;
    ANativeStyle: Boolean): TRect;
begin
  Result.Top := (Height - ARadioButtonSize.cy) div 2;
  Result.Bottom := Result.Top + ARadioButtonSize.cy;
  if Alignment = taRightJustify then
  begin
    if ANativeStyle then
      Result.Left := 0
    else
      if IsInplace then
        Result.Left := 0
      else
        Result.Left := 1;
    Result.Right := Result.Left + ARadioButtonSize.cx;
  end else
  begin
    Result.Right := Width;
    Result.Left := Result.Right - ARadioButtonSize.cx;
  end;
end;

procedure TcxRadioButton.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

procedure TcxRadioButton.SetPopupMenu(Value: TComponent);
var
  AIPopupMenu: IcxPopupMenu;
begin
  if (Value <> nil) and not((Value is TPopupMenu) or
    Supports(Value, IcxPopupMenu, AIPopupMenu)) then
      Value := nil;
  if FPopupMenu <> Value then
  begin
    {$IFDEF DELPHI5}
    if FPopupMenu <> nil then
      FPopupMenu.RemoveFreeNotification(Self);
    {$ENDIF}  
    FPopupMenu := Value;
    if FPopupMenu <> nil then
      FPopupMenu.FreeNotification(Self);
  end;
end;

procedure TcxRadioButton.SetState(Value: TcxRadioButtonState);
var
  R: TRect;
begin
  if Value <> FState then
  begin
    FState := Value;
    R := FButtonRect;
    InflateRect(R, 1, 1);
    InternalInvalidateRect(Self, R, False);
  end;
end;

procedure TcxRadioButton.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

{$IFNDEF DELPHI7}
procedure TcxRadioButton.SetParentBackground(Value: Boolean);
begin
  if Value <> FParentBackground then
  begin
    FParentBackground := Value;
    Invalidate;
  end;
end;

procedure TcxRadioButton.SetWordWrap(Value: Boolean);
begin
  if Value <> FWordWrap then
  begin
    FWordWrap := Value;
    Invalidate;
  end;
end;
{$ENDIF}

procedure TcxRadioButton.WMContextMenu(var Message: TWMContextMenu);
var
  AHandled: Boolean;
  P, P1: TPoint;
begin
  if Message.Result <> 0 then
    Exit;
  if csDesigning in ComponentState then
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

procedure TcxRadioButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TcxRadioButton.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  if not (csDestroying in ComponentState) and IsTransparentBackground then
    Invalidate;
end;

procedure TcxRadioButton.BMSetCheck(var Message: TMessage);
begin
  inherited;
  InternalInvalidateRect(Self, FButtonRect, False);
end;

procedure TcxRadioButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  EnabledChanged;
end;

procedure TcxRadioButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseEnter(Self)
  else
    MouseEnter(TControl(Message.lParam));
end;

procedure TcxRadioButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxRadioButton.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TcxRadioButton.CNDrawItem(var Message: TWMDrawItem);
begin
  if not (csDestroying in ComponentState) then
    DrawItem(Message.DrawItemStruct^);
end;

procedure TcxRadioButton.CNKeyDown(var Message: TWMKeyDown);
begin
  if IsPopupMenuShortCut(PopupMenu, Message) then
    Message.Result := 1
  else
    inherited;
end;

procedure TcxRadioButton.CNMeasureItem(var Message: TWMMeasureItem);
var
  ATempVar: TMeasureItemStruct;
begin
  ATempVar := Message.MeasureItemStruct^;
  ATempVar.itemWidth := Width;
  ATempVar.itemHeight := Height;
  Message.MeasureItemStruct^ := ATempVar;
end;

procedure TcxRadioButton.CNSysKeyDown(var Message: TWMSysKeyDown);
begin
  if IsPopupMenuShortCut(PopupMenu, Message) then
    Message.Result := 1
  else
    inherited;
end;

{  TcxRadioGroupButtonViewInfo  }

function TcxRadioGroupButtonViewInfo.GetGlyphRect(ACanvas: TcxCanvas;
  AGlyphSize: TSize; AAlignment: TLeftRight; AIsPaintCopy: Boolean): TRect;

  procedure CorrectRadioRect(var ACheckRect: TRect);
  begin
    if AIsPaintCopy and not Data.NativeStyle then
      OffsetRect(ACheckRect, 1, 0);
  end;

begin
  Result := inherited GetGlyphRect(ACanvas, AGlyphSize, AAlignment, AIsPaintCopy);
  CorrectRadioRect(Result);
end;

{ TcxCustomRadioGroupViewInfo }

constructor TcxCustomRadioGroupViewInfo.Create;
begin
  inherited Create;
  PrepareRadioButtonImageList;
end;

procedure TcxCustomRadioGroupViewInfo.DrawButtonCaption(ACanvas: TcxCanvas;
  AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect);

  procedure CorrectTextRect(var R: TRect);
  const
    ANativeStyleTextRectCorrection: TRect = (Left: 3; Top: -1; Right: 0; Bottom: -1);
    ATextRectCorrection: TRect = (Left: 5; Top: 0; Right: 1; Bottom: 0);
  begin
    if AButtonViewInfo.Data.NativeStyle then
      ExtendRect(R, ANativeStyleTextRectCorrection)
    else
      ExtendRect(R, ATextRectCorrection);
    if (Edit <> nil) and Edit.IsDBEditPaintCopyDrawing then
      OffsetRect(R, 0, -1);
  end;

var
  R: TRect;
begin
  ACanvas.Font := Font;
  ACanvas.Font.Color := TextColor;
  PrepareCanvasFont(ACanvas.Canvas);
  R := AButtonViewInfo.Bounds;
  if Alignment = taRightJustify then
    R.Left := AGlyphRect.Right
  else
    R.Right := AGlyphRect.Left;
  ACanvas.Brush.Style := bsClear;
  CorrectTextRect(R);
  ACanvas.DrawText(AButtonViewInfo.Caption, R, DrawTextFlags);
  ACanvas.Brush.Style := bsSolid;
  if not IsInplace and Focused then
  begin
    ACanvas.TextExtent(AButtonViewInfo.Caption, R, DrawTextFlags);
    InflateRect(R, 1, 1);
    Inc(R.Bottom);
    ACanvas.Brush.Color := BackgroundColor;
    TCanvasAccess(ACanvas.Canvas).RequiredState([csFontValid]);
    ACanvas.Canvas.DrawFocusRect(R);
  end;
end;

procedure TcxCustomRadioGroupViewInfo.DrawButtonGlyph(ACanvas: TcxCanvas;
  AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect);
const
  ALookAndFeelKindMap: array [TcxEditButtonStyle] of TcxLookAndFeelKind =
    (lfStandard, lfStandard, lfFlat, lfStandard, lfStandard,
    lfUltraFlat, lfOffice11);
  AButtonStateMap: array [TcxEditButtonState] of TcxButtonState =
    (cxbsDisabled, cxbsNormal, cxbsPressed, cxbsHot);
var
  APrevClipRegion: TcxRegion;
  ABackgroundColor: TColor;
  APainter: TcxCustomLookAndFeelPainterClass;
begin
  APrevClipRegion := ACanvas.GetClipRegion;
  try
    ACanvas.IntersectClipRect(AButtonViewInfo.Bounds);
    if AButtonViewInfo.Data.NativeStyle then
      DrawThemeBackground(ThemeHandle, ACanvas.Handle, BP_RADIOBUTTON,
        AButtonViewInfo.Data.NativeState, AGlyphRect)
    else
    begin
      if IsBackgroundTransparent {and (Painter = nil)} then
        ABackgroundColor := clDefault
      else
        ABackgroundColor := BackgroundColor;
      if Painter = nil then
        APainter := GetPainterClass(False, ALookAndFeelKindMap[AButtonViewInfo.Data.Style])
      else
        APainter := Painter;
      APainter.DrawRadioButton(ACanvas, AGlyphRect.Left, AGlyphRect.Top,
        AButtonStateMap[AButtonViewInfo.Data.State],
        ItemIndex = AButtonViewInfo.Index, False, ABackgroundColor, IsDesigning);
    end;
  finally
    ACanvas.SetClipRegion(APrevClipRegion, roSet);
  end;
end;

function TcxCustomRadioGroupViewInfo.GetButtonViewInfoClass: TcxEditButtonViewInfoClass;
begin
  Result := TcxRadioGroupButtonViewInfo;
end;

function TcxCustomRadioGroupViewInfo.IsButtonGlypthTransparent(AButtonViewInfo: TcxGroupBoxButtonViewInfo): Boolean;
begin
  Result := IsBackgroundTransparent or
    AButtonViewInfo.Data.NativeStyle and
      IsThemeBackgroundPartiallyTransparent(ThemeHandle, BP_RADIOBUTTON, AButtonViewInfo.Data.NativeState);
end;

function TcxCustomRadioGroupViewInfo.GetEdit: TcxCustomRadioGroup;
begin
  Result := TcxCustomRadioGroup(FEdit);
end;

function TcxCustomRadioGroupViewInfo.ThemeHandle: TdxTheme;
begin
  Result := OpenTheme(totButton);
end;

{ TcxCustomRadioGroupViewData }

procedure TcxCustomRadioGroupViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
begin
  with TcxCustomRadioGroupViewInfo(AViewInfo) do
    Alignment := taRightJustify;
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  TcxCustomRadioGroupViewInfo(AViewInfo).GlyphSize :=
    Style.LookAndFeel.GetAvailablePainter(totButton).RadioButtonSize;
  AViewInfo.BackgroundColor := Style.Color;
end;

procedure TcxCustomRadioGroupViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
  if PreviewMode then
    TcxCustomRadioGroupViewInfo(AViewInfo).ItemIndex := 0
  else
    TcxCustomRadioGroupViewInfo(AViewInfo).ItemIndex :=
      Properties.GetRadioGroupItemIndex(AEditValue);
  if epoAutoHeight in PaintOptions then
    Include(AViewInfo.PaintOptions, epoAutoHeight);
end;

procedure TcxCustomRadioGroupViewData.GetEditMetrics(AAutoHeight: Boolean;
  ACanvas: TcxCanvas; out AMetrics: TcxEditMetrics);
const
  AColumnWidthCorrectionA: array [Boolean] of Integer = (7, 5);
  AAutoHeightColumnWidthCorrectionA: array [Boolean] of Integer = (3, 1);
var
  ANativeStyle: Boolean;
begin
  AMetrics.ClientLeftBoundCorrection := 6 - 5 * Integer(IsInplace);
  AMetrics.ClientWidthCorrection := 4 * Integer(IsInplace) - 6;
  AMetrics.ColumnOffset := 0;
  if ACanvas = nil then
    Exit;

  ANativeStyle := IsButtonNativeStyle(Style.LookAndFeel);
  AMetrics.ButtonSize := Style.LookAndFeel.GetAvailablePainter(totButton).RadioButtonSize;
  AMetrics.ColumnWidthCorrection := AColumnWidthCorrectionA[ANativeStyle];
  AMetrics.AutoHeightColumnWidthCorrection :=
    AAutoHeightColumnWidthCorrectionA[ANativeStyle];
  AMetrics.WidthCorrection := 6 - 5 * Integer(IsInplace);
  AMetrics.AutoHeightWidthCorrection := Integer(IsInplace) - 6;
end;

procedure TcxCustomRadioGroupViewData.CalculateButtonNativeState(AViewInfo: TcxCustomEditViewInfo;
  AButtonViewInfo: TcxGroupBoxButtonViewInfo);
const
  AButtonStateMap: array [Boolean, TcxEditButtonState] of Integer = (
    (RBS_UNCHECKEDDISABLED, RBS_UNCHECKEDNORMAL, RBS_UNCHECKEDPRESSED, RBS_UNCHECKEDHOT),
    (RBS_CHECKEDDISABLED, RBS_CHECKEDNORMAL, RBS_CHECKEDPRESSED, RBS_CHECKEDHOT)
  );
var
  ATheme: TdxTheme;
begin
  with AButtonViewInfo do
  begin
    if not Data.NativeStyle then
      Exit;
    Data.NativePart := BP_RADIOBUTTON;
    Data.NativeState := AButtonStateMap[Index = TcxCustomRadioGroupViewInfo(AViewInfo).ItemIndex, Data.State];
    ATheme := OpenTheme(totButton);
    Data.BackgroundPartiallyTransparent := IsThemeBackgroundPartiallyTransparent(ATheme,
      Data.NativePart, Data.NativeState);
  end;
end;

function TcxCustomRadioGroupViewData.GetProperties: TcxCustomRadioGroupProperties;
begin
  Result := TcxCustomRadioGroupProperties(FProperties);
end;

{ TcxRadioGroupItem }

constructor TcxRadioGroupItem.Create(Collection: TCollection);
begin
  FValue := Null;
  inherited Create(Collection);
end;

procedure TcxRadioGroupItem.Assign(Source: TPersistent);
begin
  if Source is TcxRadioGroupItem then
    Value := TcxRadioGroupItem(Source).Value;
  inherited Assign(Source);
end;

function TcxRadioGroupItem.IsValueStored: Boolean;
begin
  Result := not VarIsNull(FValue);
end;

procedure TcxRadioGroupItem.SetValue(const Value: TcxEditValue);
begin
  if not InternalVarEqualsExact(Value, FValue) then
  begin
    FValue := Value;
    if Assigned(Collection) then
      TcxRadioGroupItems(Collection).InternalNotify(Self, -1, copChanged);
  end;
end;

{ TcxRadioGroupItems }

function TcxRadioGroupItems.Add: TcxRadioGroupItem;
begin
  Result := TcxRadioGroupItem(inherited Add);
end;

function TcxRadioGroupItems.GetItem(Index: Integer): TcxRadioGroupItem;
begin
  Result := TcxRadioGroupItem(inherited Items[Index]);
end;

procedure TcxRadioGroupItems.SetItem(Index: Integer; Value: TcxRadioGroupItem);
begin
  inherited Items[Index] := Value;
end;

{ TcxCustomRadioGroupProperties }

constructor TcxCustomRadioGroupProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FDefaultCaption := cxGetResourceString(@cxSRadioGroupDefaultCaption);
  FDefaultValue := Null;
end;

procedure TcxCustomRadioGroupProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomRadioGroupProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomRadioGroupProperties do
      begin
        Self.DefaultCaption := DefaultCaption;
        Self.DefaultValue := DefaultValue;
        Self.WordWrap := WordWrap;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomRadioGroupProperties.CanCompareEditValue: Boolean;
begin
  Result := True;
end;

function TcxCustomRadioGroupProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
begin
  Result := GetRadioGroupItemIndex(AEditValue1) = GetRadioGroupItemIndex(AEditValue2);
end;

class function TcxCustomRadioGroupProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxRadioGroup;
end;

function TcxCustomRadioGroupProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
var
  AItemIndex: Integer;
begin
  AItemIndex := GetRadioGroupItemIndex(AEditValue);
  if AItemIndex = -1 then
    Result := FDefaultCaption
  else
    Result := Items[AItemIndex].Caption;
end;

function TcxCustomRadioGroupProperties.GetRadioGroupItemIndex(
  const AEditValue: TcxEditValue): Integer;
var
  I: Integer;
  AIsNull: Boolean;
  AItem: TcxRadioGroupItem;
begin
  Result := -1;
  for I := 0 to Items.Count - 1 do
  begin
    AItem := Items[I];
    AIsNull := VarIsNull(AItem.Value);
    if AIsNull and InternalCompareString(AItem.Caption, VarToStr(AEditValue), True) or
      not AIsNull and VarEqualsExact(AEditValue, AItem.Value) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TcxCustomRadioGroupProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := inherited GetSupportedOperations + [esoHorzAlignment, esoSortingByDisplayText];
end;

class function TcxCustomRadioGroupProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomRadioGroupViewInfo;
end;

function TcxCustomRadioGroupProperties.IsResetEditClass: Boolean;
begin
  Result := True;
end;

procedure TcxCustomRadioGroupProperties.PrepareDisplayValue(const AEditValue:
  TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean);
begin
  DisplayValue := GetRadioGroupItemIndex(AEditValue);
end;

function TcxCustomRadioGroupProperties.CreateItems: TcxButtonGroupItems;
begin
  Result := TcxRadioGroupItems.Create(Self, TcxRadioGroupItem);
end;

function TcxCustomRadioGroupProperties.GetColumnCount: Integer;
begin
  Result := Columns;
  if Result > Items.Count then
    Result := Items.Count;
  if Result = 0 then
    Result := 1;
end;

class function TcxCustomRadioGroupProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomRadioGroupViewData;
end;

function TcxCustomRadioGroupProperties.HasDisplayValue: Boolean;
begin
  Result := True;
end;

function TcxCustomRadioGroupProperties.GetItems: TcxRadioGroupItems;
begin
  Result := TcxRadioGroupItems(inherited Items);
end;

function TcxCustomRadioGroupProperties.IsDefaultCaptionStored: Boolean;
begin
  Result := not InternalCompareString(FDefaultCaption,
    cxGetResourceString(@cxSRadioGroupDefaultCaption), True);
end;

function TcxCustomRadioGroupProperties.IsDefaultValueStored: Boolean;
begin
  Result := not VarIsNull(FDefaultValue);
end;

procedure TcxCustomRadioGroupProperties.SetDefaultValue(const Value: TcxEditValue);
begin
  if not InternalVarEqualsExact(Value, FDefaultValue) then
  begin
    FDefaultValue := Value;
    Changed;
  end;
end;

procedure TcxCustomRadioGroupProperties.SetItems(Value: TcxRadioGroupItems);
begin
  inherited Items.Assign(Value);
end;

{ TcxCustomRadioGroupButton }

constructor TcxCustomRadioGroupButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with TcxCustomRadioGroup(AOwner) do
  begin
    InternalButtons.Add(Self);
    Self.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  end;
end;

destructor TcxCustomRadioGroupButton.Destroy;
begin
  RadioGroup.InternalButtons.Remove(Self);
  inherited Destroy;
end;

function TcxCustomRadioGroupButton.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    RadioGroup.DataBinding.ExecuteAction(Action);
end;

function TcxCustomRadioGroupButton.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    RadioGroup.DataBinding.UpdateAction(Action);
end;

function TcxCustomRadioGroupButton.CanFocus: Boolean;
begin
  Result := RadioGroup.CanFocus;
end;

procedure TcxCustomRadioGroupButton.DefaultHandler(var Message);
begin
  if not RadioGroup.InnerControlDefaultHandler(TMessage(Message)) then
    inherited DefaultHandler(Message);
end;

procedure TcxCustomRadioGroupButton.Click;
begin
  inherited Click;
  with RadioGroup do
    if not IsLoading then
      RadioGroup.Click;
end;

procedure TcxCustomRadioGroupButton.CorrectTextRect(var R: TRect; ANativeStyle: Boolean);
begin
  inherited CorrectTextRect(R, ANativeStyle);
end;

procedure TcxCustomRadioGroupButton.DoEnter;
begin
  with RadioGroup do
  begin
    ShortRefreshContainer(False);
    if not Checked and not IsInplace and not FFocusingByMouse and DoEditing then
      Checked := True;
  end;
end;

procedure TcxCustomRadioGroupButton.DoExit;
begin
  inherited DoExit;
  RadioGroup.ShortRefreshContainer(False);
end;

procedure TcxCustomRadioGroupButton.DrawBackground;
var
  APrevWindowOrg: TPoint;
begin
  if RadioGroup.ViewInfo.IsCustomBackground then
  begin
    OffsetWindowOrgEx(Canvas.Handle, Left, Top, APrevWindowOrg);
    try
      RadioGroup.ViewInfo.DrawBackground(Canvas);
    finally
      SetWindowOrgEx(Canvas.Handle, APrevWindowOrg.X, APrevWindowOrg.Y, nil);
    end;
  end
  else
    if not IsTransparentBackground then
      inherited DrawBackground;
end;

function TcxCustomRadioGroupButton.IsInplace: Boolean;
begin
  Result := RadioGroup.IsInplace;
end;

function TcxCustomRadioGroupButton.IsNativeBackground: Boolean;
begin
  Result := RadioGroup.IsNativeBackground;
end;

function TcxCustomRadioGroupButton.IsNativeStyle: Boolean;
begin
  Result := RadioGroup.IsButtonNativeStyle;
end;

function TcxCustomRadioGroupButton.IsTransparent: Boolean;
begin
  Result := RadioGroup.IsTransparent;
end;

function TcxCustomRadioGroupButton.IsTransparentBackground: Boolean;
begin
  Result := inherited IsTransparentBackground or RadioGroup.ViewInfo.IsCustomBackground;
end;

procedure TcxCustomRadioGroupButton.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if ((Key = #8) or (Key = ' ')) and not RadioGroup.CanModify then
    Key := #0;
end;

procedure TcxCustomRadioGroupButton.Paint(ADrawOnlyFocusedState: Boolean);

  procedure SetSkinsPaintCopy(AValue: Boolean);
  begin
    if RadioGroup <> nil then
      RadioGroup.SkinsPaintCopy := AValue;
  end;

  function DrawByPainter(APainter: TcxCustomLookAndFeelPainterClass): Boolean;
  var
    ABitmap: TcxBitmap;
    ARadioButtonSize: TSize;
  begin
    Result := APainter <> nil;
    if Result then
    begin
      with ClientRect do
        ABitmap := TcxBitmap.CreateSize(Right - Left, Bottom - Top);
      ABitmap.PixelFormat := pf32bit;
      try
        SetSkinsPaintCopy(True);
        try
          cxDrawTransparentControlBackground(Self, ABitmap.cxCanvas, ClientRect);
        finally
          SetSkinsPaintCopy(False);
        end;
        ARadioButtonSize := APainter.RadioButtonSize;
        FButtonRect := GetRadioButtonRect(ARadioButtonSize, IsNativeStyle);

        with FButtonRect do
          APainter.DrawRadioButton(ABitmap.cxCanvas, Left, Top, AButtonStateMap[State],
            Checked, Focused, clNone, csDesigning in ComponentState);

        DrawCaption(ABitmap.cxCanvas, IsNativeStyle);
        Canvas.Draw(0, 0, ABitmap);
      finally
        ABitmap.Free;
      end;
    end;  
  end;

begin
  if not DrawByPainter(LookAndFeel.SkinPainter) then
    inherited Paint(ADrawOnlyFocusedState);
end;    

procedure TcxCustomRadioGroupButton.SetChecked(Value: Boolean);
begin
  if Value = Checked then
    Exit;
  ClicksDisabled := True;
  try
    inherited SetChecked(Value);
  finally
    ClicksDisabled := False;
  end;
  if Value and not FInternalSettingChecked then
    RadioGroup.ButtonChecked(Self);
end;

procedure TcxCustomRadioGroupButton.WndProc(var Message: TMessage);
begin
  if RadioGroup.InnerControlMenuHandler(Message) then
    Exit;
  if ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) and
    (RadioGroup.DragMode = dmAutomatic) and not RadioGroup.IsDesigning then
      RadioGroup.BeginAutoDrag
  else
  begin
    if Message.Msg = WM_LBUTTONDOWN then
      FFocusingByMouse := True;
    inherited WndProc(Message);
    if Message.Msg = WM_LBUTTONDOWN then
      FFocusingByMouse := False;
  end;
end;

// IcxContainerInnerControl
function TcxCustomRadioGroupButton.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxCustomRadioGroupButton.GetControlContainer: TcxContainer;
begin
  Result := RadioGroup;
end;

procedure TcxCustomRadioGroupButton.InternalSetChecked(AValue: Boolean);
begin
  if FInternalSettingChecked then
    Exit;
  FInternalSettingChecked := True;
  try
    Checked := AValue;
  finally
    FInternalSettingChecked := False;
  end;
end;

function TcxCustomRadioGroupButton.GetRadioGroup: TcxCustomRadioGroup;
begin
  Result := TcxCustomRadioGroup(Owner);
end;

procedure TcxCustomRadioGroupButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if RadioGroup.TabsNeeded and (GetKeyState(VK_CONTROL) >= 0) then
    Message.Result := Message.Result or DLGC_WANTTAB;
  if RadioGroup.IsInplace then
    Message.Result := Message.Result or DLGC_WANTARROWS;
end;

procedure TcxCustomRadioGroupButton.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) and (Message.FocusedWnd <> RadioGroup.Handle) then
    RadioGroup.FocusChanged;
end;

procedure TcxCustomRadioGroupButton.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) and (Message.FocusedWnd <> RadioGroup.Handle) then
    RadioGroup.FocusChanged;
end;

procedure TcxCustomRadioGroupButton.CNCommand(var Message: TWMCommand);
begin
  if FIsClickLocked then
    Exit;
  FIsClickLocked := True;
  try
    try
      with RadioGroup do
        if ((Message.NotifyCode = BN_CLICKED) or (Message.NotifyCode = BN_DOUBLECLICKED)) and
          (Checked or CanModify and DoEditing) then
            inherited;
    except
      Application.HandleException(Self);
    end;
  finally
    FIsClickLocked := False;
  end;
end;

{ TcxCustomRadioGroup }

procedure TcxCustomRadioGroup.Activate(var AEditData: TcxCustomEditData);
var
  ACheckedButtonIndex: Integer;
begin
  inherited Activate(AEditData);
  if InternalButtons.Count = 0 then
    Exit;
  ACheckedButtonIndex := ItemIndex;
  if ACheckedButtonIndex = -1 then
    ACheckedButtonIndex := 0;
  if Buttons[ACheckedButtonIndex].CanFocus then
    Buttons[ACheckedButtonIndex].SetFocus;
end;

procedure TcxCustomRadioGroup.Clear;
begin
  ItemIndex := -1;
end;

procedure TcxCustomRadioGroup.FlipChildren(AllLevels: Boolean);
begin
end;

class function TcxCustomRadioGroup.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomRadioGroupProperties;
end;

procedure TcxCustomRadioGroup.GetTabOrderList(List: TList);
var
  I: Integer;
begin
  inherited GetTabOrderList(List);
  List.Remove(Self);
  if (TabStop or Focused) and (ItemIndex <> -1) then
    for I := 0 to InternalButtons.Count - 1 do
      if Buttons[I].Enabled then
        List.Add(Buttons[I]);
end;

procedure TcxCustomRadioGroup.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
begin
  if ADisplayValue = -1 then
    EditValue := ActiveProperties.DefaultValue
  else
  begin
    EditValue := ActiveProperties.Items[ADisplayValue].Value;
    if VarIsNull(EditValue) then
      EditValue := ActiveProperties.Items[ADisplayValue].Caption;
  end;
end;

procedure TcxCustomRadioGroup.SetFocus;
var
  ACheckedIndex: Integer;
begin
  ACheckedIndex := GetCheckedIndex;
  if (ACheckedIndex <> -1) and Buttons[ACheckedIndex].CanFocus then
    Buttons[ACheckedIndex].SetFocus
  else
    inherited SetFocus;
end;

procedure TcxCustomRadioGroup.CursorChanged;
var
  I: Integer;
begin
  inherited CursorChanged;
  for I := 0 to InternalButtons.Count - 1 do
    Buttons[I].Cursor := Cursor;
end;

function TcxCustomRadioGroup.GetButtonDC(AButtonIndex: Integer): THandle;
begin
  Result := Buttons[AButtonIndex].Canvas.Handle;
end;

procedure TcxCustomRadioGroup.Initialize;
begin
  inherited Initialize;
  {$IFDEF DELPHI7}
  ControlStyle := ControlStyle * [csParentBackground];
  {$ELSE}
  ControlStyle := [];
  {$ENDIF}
  ControlStyle := ControlStyle + [csCaptureMouse, csClickEvents, csSetCaption,
    csDoubleClicks, csReplicatable];

  FLoadedItemIndex := -1;
  Width := 185;
  Height := 105;
end;

procedure TcxCustomRadioGroup.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
begin
  SetInternalValues(Value, AValidateEditValue, False);
end;

function TcxCustomRadioGroup.IsContainerFocused: Boolean;
var
  AIsButtonFocused: Boolean;
  I: Integer;
begin
  AIsButtonFocused := False;
  for I := 0 to ActiveProperties.Items.Count - 1 do
    if Buttons[I].Focused then
    begin
      AIsButtonFocused := True;
      Break;
    end;
  if AIsButtonFocused then
    Result := False
  else
    Result := inherited Focused;
end;

function TcxCustomRadioGroup.IsDBEditPaintCopyDrawing: Boolean;
begin
  Result := not FSkinsPaintCopy and inherited IsDBEditPaintCopyDrawing;
end;

function TcxCustomRadioGroup.IsInternalControl(AControl: TControl): Boolean;
var
  I: Integer;
begin
  Result := AControl <> nil;
  if Result then
  begin
    Result := inherited IsInternalControl(AControl);
    if not Result then
      for I := 0 to InternalButtons.Count - 1 do
        if AControl = InternalButtons[I] then
        begin
          Result := True;
          Exit;
        end;
  end;
end;

procedure TcxCustomRadioGroup.SetDragMode(Value: TDragMode);
var
  I: Integer;
begin
  inherited SetDragMode(Value);
  for I := 0 to InternalButtons.Count - 1 do
    Buttons[I].DragMode := Value;
end;

procedure TcxCustomRadioGroup.SetInternalValues(const AEditValue: TcxEditValue;
  AValidateEditValue, AFromButtonChecked: Boolean);

  procedure FocusButton(AIndex: Integer);
  begin
    if Focused and (GetFocus <> Handle) then
      Buttons[AIndex].SetFocus;
  end;

  procedure SetButtonCheck(AItemIndex: Integer);
  begin
    if AFromButtonChecked then
      FocusButton(AItemIndex)
    else
    begin
      if AItemIndex < 0 then
        Buttons[ItemIndex].InternalSetChecked(False)
      else
      begin
        Buttons[AItemIndex].InternalSetChecked(True);
        FocusButton(AItemIndex);
      end;
      if IsLoading or IsDesigning then
        FLoadedItemIndex := AItemIndex;
    end;
  end;

var
  AItemIndex: Integer;
begin
  LockChangeEvents(True);
  try
    inherited InternalSetEditValue(AEditValue, AValidateEditValue);
    AItemIndex := ActiveProperties.GetRadioGroupItemIndex(AEditValue);
    if AFromButtonChecked or (GetCheckedIndex <> AItemIndex) then
    begin
      SetButtonCheck(AItemIndex);
      DoClick;
      DoChange;
    end
    else
      if not KeyboardAction then
        EditModified := False;
  finally
    LockChangeEvents(False);
  end;
  ShortRefreshContainer(False);
end;

procedure TcxCustomRadioGroup.SynchronizeButtonsStyle;
const
  AButtonLookAndFeelKinds: array [TcxEditButtonStyle] of TcxLookAndFeelKind =
    (lfStandard, lfStandard, lfFlat, lfStandard, lfStandard,
    lfUltraFlat, lfOffice11);
var
  I: Integer;
begin
  inherited SynchronizeButtonsStyle;
  if Length(ViewInfo.ButtonsInfo) > 0 then
    for I := 0 to InternalButtons.Count - 1 do
    begin
      Buttons[I].LookAndFeel.Kind := AButtonLookAndFeelKinds[ViewInfo.ButtonsInfo[0].Data.Style];
      if not Buttons[I].Enabled then
        Buttons[I].Font.Color := StyleDisabled.GetVisibleFont.Color;
      Buttons[I].Transparent := Transparent; // Repaint buttons
    end;
end;

procedure TcxCustomRadioGroup.Resize;
begin
  inherited Resize;
  if IsDesigning and IsNativeBackground then
    InvalidateRect(GetControlRect(Self), True);
end;

procedure TcxCustomRadioGroup.ParentBackgroundChanged;
var
  I: Integer;
begin
  for I := 0 to InternalButtons.Count - 1 do
    Buttons[I].ParentBackground := ParentBackground;
end;

procedure TcxCustomRadioGroup.SetDragKind(Value: TDragKind);
var
  I: Integer;
begin
  inherited SetDragKind(Value);
  for I := 0 to InternalButtons.Count - 1 do
    Buttons[I].DragKind := Value;
end;

procedure TcxCustomRadioGroup.ArrangeButtons;
var
  AButtonViewInfo: TcxGroupBoxButtonViewInfo;
  I: Integer;
begin
  inherited ArrangeButtons;
  for I := 0 to InternalButtons.Count - 1 do
  begin
    AButtonViewInfo := TcxGroupBoxButtonViewInfo(ViewInfo.ButtonsInfo[I]);
    Buttons[I].FColumn := AButtonViewInfo.Column;
    Buttons[I].FRow := AButtonViewInfo.Row;
  end;
end;

function TcxCustomRadioGroup.GetButtonInstance: TWinControl;
begin
  Result := TcxCustomRadioGroupButton.Create(Self);
end;

procedure TcxCustomRadioGroup.UpdateButtons;
var
  I: Integer;
  AItemIndex: Integer;
begin
  AItemIndex := ItemIndex;
  inherited UpdateButtons;
  if IsLoading then
    Exit;
  if GetCheckedIndex <> AItemIndex then
    ItemIndex := AItemIndex;

  for I := 0 to InternalButtons.Count - 1 do
  begin
    Buttons[I].Caption := ActiveProperties.Items[I].Caption;
    Buttons[I].WordWrap := ActiveProperties.WordWrap;
  end;
end;

procedure TcxCustomRadioGroup.AfterLoading;
begin
  LockChangeEvents(True);
  LockClick(True);
  try
    if not IsDBEdit then
      FEditValue := ActiveProperties.DefaultValue;
    ItemIndex := FLoadedItemIndex;
  finally
    LockClick(False);
    LockChangeEvents(False, False);
  end;
  UpdateButtons;
end;

function TcxCustomRadioGroup.IsLoading: Boolean;
begin
  Result := [csReading, csLoading, csUpdating] * ComponentState <> [];
end;

procedure TcxCustomRadioGroup.Loaded;
begin
  inherited;
  AfterLoading;
end;

procedure TcxCustomRadioGroup.Updated;
begin
  inherited;
  AfterLoading;
end;

procedure TcxCustomRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TcxCustomRadioGroup.ButtonChecked(AButton: TcxCustomRadioGroupButton);
var
  AEditValue: TcxEditValue;
begin
  LockChangeEvents(True);
  try
    KeyboardAction := Focused;
    try
      if not IsLoading then
      begin
        PrepareEditValue(InternalButtons.IndexOf(AButton), AEditValue, InternalFocused);
        SetInternalValues(AEditValue, True, True);
      end;
    finally
      KeyboardAction := False;
    end;
    if Focused and ActiveProperties.ImmediatePost and CanPostEditValue and ValidateEdit(True) then
      InternalPostEditValue;
  finally
    LockChangeEvents(False);
  end;
end;

function TcxCustomRadioGroup.GetCheckedIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to InternalButtons.Count - 1 do
    if Buttons[I].Checked then
    begin
      Result := I;
      Break;
    end;
end;

function TcxCustomRadioGroup.GetButton(Index: Integer): TcxCustomRadioGroupButton;
begin
  Result := TcxCustomRadioGroupButton(InternalButtons[Index]);
end;

function TcxCustomRadioGroup.GetProperties: TcxCustomRadioGroupProperties;
begin
  Result := TcxCustomRadioGroupProperties(FProperties);
end;

function TcxCustomRadioGroup.GetActiveProperties: TcxCustomRadioGroupProperties;
begin
  Result := TcxCustomRadioGroupProperties(InternalGetActiveProperties);
end;

function TcxCustomRadioGroup.GetItemIndex: Integer;
begin
  if IsLoading or IsDesigning then
    Result := FLoadedItemIndex
  else
    Result := GetCheckedIndex;
end;

function TcxCustomRadioGroup.GetViewInfo: TcxCustomRadioGroupViewInfo;
begin
  Result := TcxCustomRadioGroupViewInfo(FViewInfo);
end;

procedure TcxCustomRadioGroup.SetItemIndex(Value: Integer);

  procedure InternalUpdateValues;
  var
    AEditValue: TcxEditValue;
  begin
    if Value < -1 then
      Value := -1
    else
      if Value >= InternalButtons.Count then
        Value := InternalButtons.Count - 1;

    PrepareEditValue(Value, AEditValue, InternalFocused);
    SetInternalValues(AEditValue, True, False);
  end;

begin
  if not IsLoading then
    InternalUpdateValues;
  if IsLoading or IsDesigning then
    FLoadedItemIndex := Value;
end;

procedure TcxCustomRadioGroup.SetProperties(Value: TcxCustomRadioGroupProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomRadioGroup.CMDialogChar(var Message: TCMDialogChar);
begin
  if IsAccel(Message.CharCode, Caption) and CanFocus then
  begin
    SelectFirst;
    Message.Result := 1;
  end
  else
    inherited;
end;

procedure TcxCustomRadioGroup.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  ShortRefreshContainer(False);
end;

{ TcxRadioGroup }

class function TcxRadioGroup.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxRadioGroupProperties;
end;

function TcxRadioGroup.GetActiveProperties: TcxRadioGroupProperties;
begin
  Result := TcxRadioGroupProperties(InternalGetActiveProperties);
end;

function TcxRadioGroup.GetProperties: TcxRadioGroupProperties;
begin
  Result := TcxRadioGroupProperties(FProperties);
end;

procedure TcxRadioGroup.SetProperties(Value: TcxRadioGroupProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterRadioGroupHelper }

class procedure TcxFilterRadioGroupHelper.GetFilterValue(
  AEdit: TcxCustomEdit; AEditProperties: TcxCustomEditProperties;
  var V: Variant; var S: TCaption);
var
  AItemIndex: Integer;
begin
  AItemIndex := TcxComboBox(AEdit).ItemIndex;
  with TcxCustomRadioGroupProperties(AEditProperties) do
  begin
    if AItemIndex = -1 then
    begin
      V := DefaultValue;
      S := DefaultCaption;
    end
    else
    begin
      V := Items[AItemIndex].Value;
      S := Items[AItemIndex].Caption;
    end;
  end;
end;

class function TcxFilterRadioGroupHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then Result := Result + [fcoInList, fcoNotInList];
end;

class procedure TcxFilterRadioGroupHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
var
  ARadioGroupProperties: TcxCustomRadioGroupProperties;
  I: Integer;
begin
  ARadioGroupProperties := TcxCustomRadioGroupProperties(AEditProperties);
  with TcxComboBoxProperties(AProperties).Items do
  begin
    Clear;
    for I := 0 to ARadioGroupProperties.Items.Count - 1 do
      Add(ARadioGroupProperties.Items[I].Caption);
  end;
  TcxComboBoxProperties(AProperties).DropDownListStyle := lsFixedList;
  TcxComboBoxProperties(AProperties).IDefaultValuesProvider := nil;
  ClearPropertiesEvents(AProperties);
end;

class procedure TcxFilterRadioGroupHelper.SetFilterValue(
  AEdit: TcxCustomEdit; AEditProperties: TcxCustomEditProperties;
  AValue: Variant);
var
  V: TcxEditValue;
begin
  AEditProperties.PrepareDisplayValue(AValue, V, AEdit.Focused);
  TcxComboBox(AEdit).ItemIndex := V;
end;

class function TcxFilterRadioGroupHelper.UseDisplayValue: Boolean;
begin
  Result := True;
end;

initialization
  GetRegisteredEditProperties.Register(TcxRadioGroupProperties, scxSEditRepositoryRadioGroupItem);
  FilterEditsController.Register(TcxRadioGroupProperties, TcxFilterRadioGroupHelper);

finalization
  FilterEditsController.Unregister(TcxRadioGroupProperties, TcxFilterRadioGroupHelper);

end.
