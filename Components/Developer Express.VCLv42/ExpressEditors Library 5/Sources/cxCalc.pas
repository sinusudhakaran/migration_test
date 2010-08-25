
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

unit cxCalc;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, Clipbrd,
  cxClasses, cxControls, cxContainer, cxGraphics, cxDataStorage, cxDataUtils,
  cxButtons, cxEdit, cxDropDownEdit, cxEditConsts, cxFormats, cxLookAndFeelPainters,
  cxTextEdit, cxFilterControlUtils;

const
  cxMaxCalcPrecision     = cxEditDefaultPrecision;
  cxDefCalcPrecision     = cxMaxCalcPrecision;
  // Size
  cxMinCalcFontSize      = 8;
  cxCalcMinBoldFontSize  = 10;
  cxMinCalcBtnWidth      = 28;
  cxMinCalcBtnHeight     = 22;
  cxMinCalcLargeBtnWidth = Integer(Trunc(1.7*cxMinCalcBtnWidth));
  cxMinCalcXOfs          = 3;
  cxMinCalcYOfs          = 3;
  cxMinCalcWidth         = (cxMinCalcXOfs+cxMinCalcBtnWidth)*6+cxMinCalcXOfs*3+3;
  cxMinCalcHeight        = (cxMinCalcYOfs+cxMinCalcBtnHeight)*5+cxMinCalcYOfs+3;

type
  TcxCalcState = (csFirst, csValid, csError);

  TcxCalcButtonKind =
   (cbBack, cbCancel, cbClear,
    cbMC, cbMR, cbMS, cbMP,
    cbNum0, cbNum1, cbNum2, cbNum3, cbNum4, cbNum5, cbNum6, cbNum7, cbNum8, cbNum9,
    cbSign, cbDecimal,
    cbDiv, cbMul, cbSub, cbAdd,
    cbSqrt, cbPercent, cbRev, cbEqual, cbNone);

const
  BtnCaptions : array [cbBack..cbEqual] of string = ('Back', 'CE', 'C',
    'MC', 'MR', 'MS', 'M+',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '+/-', ',', '/', '*', '-', '+', 'sqrt', '%', '1/x', '=');

type
  TcxButtonInfo = record
    Kind : TcxCalcButtonKind;
    Text : string;
    FontColor : TColor;
    BtnRect : TRect;
    Down : Boolean;
    Grayed : Boolean;
  end;

  TCalcButtons = array [TcxCalcButtonKind] of TcxButtonInfo;

  { TcxCustomCalculator }

  TcxCalcButtonClick = procedure(Sender: TObject; var ButtonKind : TcxCalcButtonKind) of object;
  TcxCalcGetEditValue = procedure(Sender: TObject; var Value : String) of object;
  TcxCalcSetEditValue = procedure(Sender: TObject; const Value : String) of object;

  TcxCustomCalculator = class(TcxControl)
  private
    {calc style}
    FAutoFontSize : Boolean;
    FBeepOnError: Boolean;
    FBorderStyle : TBorderStyle;
    FFocusRectVisible : Boolean;
    {calc size}
    FCalcFontSize      : Integer;
    FCalcBtnWidth      : Integer;
    FCalcBtnHeight     : Integer;
    FCalcLargeBtnWidth : Integer;
    FCalcXOfs          : Integer;
    FCalcYOfs          : Integer;
    FCalcWidth         : Integer;
    FCalcHeight        : Integer;
    {math}
    FMemory : Extended;
    FOperator: TcxCalcButtonKind;
    FOperand: Extended;
    FPrecision: Byte;
    FStatus: TcxCalcState;
    {control}
    FButtons : TCalcButtons;
    FActiveButton : TcxCalcButtonKind;
    FDownButton : TcxCalcButtonKind;
    FPressedButton : TcxCalcButtonKind;
    FTracking: Boolean;
    // events
    FOnDisplayChange: TNotifyEvent;
    FOnButtonClick: TcxCalcButtonClick;
    FOnResult: TNotifyEvent;
    FOnHidePopup: TcxEditClosePopupEvent;

    function GetDisplay: Extended;
    procedure SetDisplay(Value: Extended);
    function GetMemory: Extended;

    procedure SetAutoFontSize(Value : Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetFocusRectVisible(Value : Boolean);

    procedure StopTracking;
    procedure TrackButton(X,Y: Integer);
    procedure InvalidateButton(ButtonKind : TcxCalcButtonKind);
    procedure DoButtonDown(ButtonKind : TcxCalcButtonKind);
    procedure DoButtonUp(ButtonKind : TcxCalcButtonKind);
    procedure Error;
    procedure CheckFirst;
    procedure Clear;
    procedure CalcSize(AWidth, AHeight : Integer);
    procedure UpdateMemoryButtons;
    procedure InvalidateMemoryButtons;
    procedure ResetOperands;
  protected
    IsPopupControl : Boolean;
    function GetPainter: TcxCustomLookAndFeelPainterClass; virtual;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FontChanged; override;
    procedure FocusChanged; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Resize; override;
    procedure SetEnabled( Value: Boolean); override;
    procedure CreateLayout;
    procedure ButtonClick(ButtonKind : TcxCalcButtonKind);
    // for link with EditControl
    function GetEditorValue: String; virtual;
    procedure SetEditorValue(const Value: String); virtual;
    procedure HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason); virtual;
    procedure LockChanges(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True); virtual;

    property Color default clBtnFace;
    property ParentColor default False;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsNone;

    property AutoFontSize : Boolean read FAutoFontSize write SetAutoFontSize
      default True;
    property BeepOnError: Boolean read FBeepOnError write FBeepOnError
      default True;
    property ShowFocusRect : Boolean
      read FFocusRectVisible write SetFocusRectVisible default True;

    property Precision: Byte read FPrecision write FPrecision
      default cxDefCalcPrecision;
    property EditorValue : string read GetEditorValue write SetEditorValue;

    property OnHidePopup: TcxEditClosePopupEvent read FOnHidePopup write FOnHidePopup;
    property OnDisplayChange: TNotifyEvent
      read FOnDisplayChange write FOnDisplayChange;
    property OnButtonClick: TcxCalcButtonClick
      read FOnButtonClick write FOnButtonClick;
    property OnResult: TNotifyEvent read FOnResult write FOnResult;
  public
    constructor Create(AOwner: TComponent); override;
    function GetButtonKindAt(X, Y : Integer) : TcxCalcButtonKind;
    function GetButtonKindChar(Ch : Char) : TcxCalcbuttonKind;
    function GetButtonKindKey(Key: Word; Shift: TShiftState) : TcxCalcbuttonKind;
    procedure CopyToClipboard;
    procedure PasteFromClipboard;
    property Memory: Extended read GetMemory;
    property Value: Extended read GetDisplay write SetDisplay;
  published
    property TabStop default True;
  end;

  { TcxPopupCalculator }

  TcxCustomCalcEdit = class;

  TcxPopupCalculator = class(TcxCustomCalculator)
  private
    FEdit: TcxCustomCalcEdit;
  protected
    function GetEditorValue: string; override;
    function GetPainter: TcxCustomLookAndFeelPainterClass; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure SetEditorValue(const Value: string); override;
    procedure LockChanges(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True); override;
    property Edit: TcxCustomCalcEdit read FEdit write FEdit;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Init; virtual;
  end;

  { TcxCalcEditPropertiesValues }

  TcxCalcEditPropertiesValues = class(TcxTextEditPropertiesValues)
  private
    FPrecision: Boolean;
    procedure SetPrecision(Value: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; override;
  published
    property Precision: Boolean read FPrecision write SetPrecision stored False;
  end;

  { TcxCustomCalcEditProperties }

  TcxCustomCalcEditProperties = class(TcxCustomPopupEditProperties)
  private
    FBeepOnError: Boolean;
    FPrecision: Byte;
    FQuickClose: Boolean;              
    FScientificFormat: Boolean;
    FUseThousandSeparator: Boolean;
    function GetAssignedValues: TcxCalcEditPropertiesValues;
    function GetPrecision: Byte;
    function IsPrecisionStored: Boolean;
    procedure SetAssignedValues(Value: TcxCalcEditPropertiesValues);
    procedure SetBeepOnError(Value: Boolean);
    procedure SetPrecision(Value: Byte);
    procedure SetQuickClose(Value: Boolean);
    procedure SetScientificFormat(Value: Boolean);
    procedure SetUseThousandSeparator(Value: Boolean);
  protected
    function GetAlwaysPostEditValue: Boolean; override;
    class function GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass; override;
    function HasDigitGrouping(AIsDisplayValueSynchronizing: Boolean): Boolean; override;
    function PopupWindowAcceptsAnySize: Boolean; override;
    function StrToFloatEx(S: string; var Value: Extended): Boolean;
    property AssignedValues: TcxCalcEditPropertiesValues read GetAssignedValues
      write SetAssignedValues;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    function IsDisplayValueValid(var DisplayValue: TcxEditValue;
      AEditFocused: Boolean): Boolean; override;
    function IsEditValueValid(var EditValue: TcxEditValue;
      AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure ValidateDisplayValue(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit); override;
    // !!!
    property BeepOnError: Boolean read FBeepOnError write SetBeepOnError
      default True;
    property ImmediateDropDown default False;
    property Precision: Byte read GetPrecision write SetPrecision
      stored IsPrecisionStored;
    property QuickClose: Boolean read FQuickClose write SetQuickClose
      default False;
    property ScientificFormat: Boolean read FScientificFormat
      write SetScientificFormat default False;
    property UseThousandSeparator: Boolean read FUseThousandSeparator
      write SetUseThousandSeparator default False;
  end;

  { TcxCalcEditProperties }

  TcxCalcEditProperties = class(TcxCustomCalcEditProperties)
  published
    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property BeepOnError;
    property ButtonGlyph;
    property ClearKey;
    property DisplayFormat;
    property ImeMode;
    property ImeName;
    property ImmediatePost;
    property Precision;
    property ReadOnly;
    property QuickClose;
    property ScientificFormat;
    property UseLeftAlignmentOnEditing;
    property UseThousandSeparator;
    property ValidateOnEnter;
    property OnChange;
    property OnCloseUp;
    property OnEditValueChanged;
    property OnInitPopup;
    property OnPopup;
    property OnValidate;
  end;

  { TcxCustomCalcEdit }

  TcxCustomCalcEdit = class(TcxCustomPopupEdit)
  private
    FCalculator: TcxPopupCalculator;
    function GetProperties: TcxCustomCalcEditProperties;
    function GetActiveProperties: TcxCustomCalcEditProperties;
    function GetValue: Extended;
    procedure SetProperties(Value: TcxCustomCalcEditProperties);
    procedure SetValue(const Value: Extended);
  protected
    // IcxFormatControllerListener
    procedure FormatChanged; override;

    function CanDropDown: Boolean; override;
    procedure CreatePopupWindow; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DoInitPopup; override;
    procedure Initialize; override;
    procedure InitializePopupWindow; override;
    function InternalGetEditingValue: TcxEditValue; override;
    function IsValidChar(Key: Char): Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure PopupWindowClosed(Sender: TObject); override;
    procedure PopupWindowShowed(Sender: TObject); override;
    procedure PropertiesChanged(Sender: TObject); override;
    function InternalPrepareEditValue(const ADisplayValue: string;
      out EditValue: TcxEditValue): Boolean;
    property Calculator: TcxPopupCalculator read FCalculator;
  public
    destructor Destroy; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure PasteFromClipboard; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    property ActiveProperties: TcxCustomCalcEditProperties
      read GetActiveProperties;
    property Properties: TcxCustomCalcEditProperties read GetProperties
      write SetProperties;
    property Value: Extended read GetValue write SetValue stored False;
  end;

  { TcxCalcEdit }

  TcxCalcEdit = class(TcxCustomCalcEdit)
  private
    function GetActiveProperties: TcxCalcEditProperties;
    function GetProperties: TcxCalcEditProperties;
    procedure SetProperties(Value: TcxCalcEditProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxCalcEditProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditValue;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxCalcEditProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop default True;
  {$IFDEF DELPHI12}
    property TextHint;
  {$ENDIF}
    property Value;
    property Visible;
    property OnClick;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property BiDiMode;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
  end;

  { TcxFilterCalcEditHelper }

  TcxFilterCalcEditHelper = class(TcxFilterDropDownEditHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Math, cxLookAndFeels, cxVariants, dxThemeManager, dxUxTheme, dxCore;

const
  ResultButtons    = [cbEqual, cbPercent];
  RepeatButtons    = [cbBack];
  OperationButtons = [cbAdd, cbSub, cbMul, cbDiv];
  BorderWidth = 4;

{TcxCustomCalculator}

constructor TcxCustomCalculator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {init size variables}
  FCalcFontSize      := cxMinCalcFontSize;
  FCalcBtnWidth      := cxMinCalcBtnWidth;
  FCalcBtnHeight     := cxMinCalcBtnHeight;
  FCalcLargeBtnWidth := cxMinCalcLargeBtnWidth;
  FCalcXOfs          := cxMinCalcXOfs;
  FCalcYOfs          := cxMinCalcYOfs;
  FCalcWidth         := cxMinCalcWidth;
  FCalcHeight        := cxMinCalcHeight;
  {default size}
  Width := FCalcWidth;
  Height := FCalcHeight;
  {style}
  ControlStyle := [csCaptureMouse, csOpaque];
  Color := clBtnFace;
  ParentColor := False;
  TabStop := True;
  FAutoFontSize := True;
  FBorderStyle := bsNone;
  FBeepOnError := True;
  FDownButton := cbNone;
  FActiveButton := cbNone;
  FPressedButton := cbNone;
  FFocusRectVisible := True;
  FOperator := cbEqual;
  FPrecision := cxDefCalcPrecision;
  Keys := [kAll, kArrows, kChars, kTab];
  CreateLayout;
end;

function TcxCustomCalculator.GetButtonKindAt(X, Y : Integer) : TcxCalcButtonKind;
var i : TcxCalcButtonKind;
begin
  Result := cbNone;
  for i := cbBack to cbEqual do
    if PtInRect(FButtons[i].BtnRect, Point(X, Y)) then
    begin
      Result := i;
      Exit;
    end;
end;

function TcxCustomCalculator.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := TcxStandardLookAndFeelPainter;
end;

procedure TcxCustomCalculator.Paint;
var
  i : TcxCalcButtonKind;
  State: TcxButtonState;
begin
  if not HandleAllocated then Exit;
    with Canvas do
    begin
      {Fill Background}
      Brush.Color := Self.Color;
      if IsPopupControl then
        GetPainter.DrawWindowContent(Self.Canvas, ClientRect)
      else
        GetPainter.DrawWindowContent(Self.Canvas, BoundsRect);
      {Draw buttons}
      Font := Self.Font;
      if AutoFontSize then
      begin
        Font.Size := FCalcFontSize;
        if Font.Size >= cxCalcMinBoldFontSize then
          Font.Style := [fsBold]
        else
          Font.Style := [];
      end;
      Brush.Color := Self.Color;
    end;

    for i := cbBack to cbEqual do
      with FButtons[i] do
      if RectVisible(Canvas.Handle, BtnRect) then
      begin
        if Grayed or not Enabled then State := cxbsDisabled
        else if Down then State := cxbsPressed
        else if (FActiveButton = i) and (FDownButton <> i) then State := cxbsHot
        else if IsFocused and (i = cbEqual) then State := cxbsDefault
        else State := cxbsNormal;
        with GetPainter, Canvas do
        begin
          DrawButton(Self.Canvas, BtnRect, '', State);
          Font.Color := FontColor;
          Brush.Style := bsClear;
          if State = cxbsPressed then
          begin
            OffsetRect(BtnRect, ButtonTextShift, ButtonTextShift);
            DrawText(Text, BtnRect, cxAlignHCenter or cxAlignVCenter or cxSingleLine or
              cxShowPrefix, State <> cxbsDisabled);
            OffsetRect(BtnRect, -ButtonTextShift, -ButtonTextShift);
          end
          else
            DrawText(Text, BtnRect, cxAlignHCenter or cxAlignVCenter or cxSingleLine or
              cxShowPrefix, State <> cxbsDisabled);
          Brush.Style := bsSolid;
        end;
        if FFocusRectVisible and IsFocused and (i = cbEqual) then
        begin
          InflateRect(BtnRect, -3, -3);
          Canvas.DrawFocusRect(BtnRect);
          InflateRect(BtnRect, 3, 3);
        end;
      end;
end;

procedure TcxCustomCalculator.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_TABSTOP or WS_CLIPCHILDREN;
    WindowClass.Style := WindowClass.Style and not CS_DBLCLKS;
    if IsPopupControl then
      Style := Style and not WS_BORDER
    else
      if FBorderStyle = bsSingle then
        if NewStyleControls and Ctl3D then
        begin
          Style := Style and not WS_BORDER;
          ExStyle := ExStyle or WS_EX_CLIENTEDGE;
        end
        else
          Style := Style or WS_BORDER;
  end;
end;

procedure TcxCustomCalculator.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var ButtonKind : TcxCalcButtonkind;
begin
  if not (csDesigning in ComponentState) and
      (CanFocus or (GetParentForm(Self) = nil)) and not IsPopupControl then
    SetFocus;

  ButtonKind := GetButtonKindAt(X, Y);
  if (Button = mbLeft) and (ButtonKind <> cbNone) and not FButtons[ButtonKind].Grayed then
  begin
    MouseCapture := True;
    FTracking := True;
    FDownButton := ButtonKind;
    TrackButton(X, Y);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TcxCustomCalculator.MouseMove(Shift: TShiftState; X, Y: Integer);
var OldButton : TcxCalcButtonKind;
begin
  if FTracking then
    TrackButton(X, Y)
  else
    if GetPainter.IsButtonHotTrack and Enabled and not Dragging then
    begin
      OldButton := FActiveButton;
      FActiveButton := GetButtonKindAt(X, Y);
      if FActiveButton <> OldButton then
      begin
        if not FButtons[OldButton].Grayed then
          InvalidateButton(OldButton);
        if not FButtons[FActiveButton].Grayed then
          InvalidateButton(FActiveButton);
      end;
    end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TcxCustomCalculator.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := (FDownButton <> cbNone) and FButtons[FDownButton].Down;
  StopTracking;
  if (Button = mbLeft) and WasPressed then
    ButtonClick(FDownButton);
  FDownButton := cbNone;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TcxCustomCalculator.KeyDown(var Key: Word; Shift: TShiftState);
var
  NewButton, OldButton : TcxCalcButtonKind;
begin
  inherited KeyDown(Key, Shift);
  OldButton := FPressedButton;
  NewButton := GetButtonKindKey(Key, Shift);
  if (NewButton <> cbNone) and (OldButton <> NewButton) then
  begin
    DoButtonUp(OldButton);
    FPressedButton := NewButton;
    DoButtonDown(FPressedButton);
  end;
end;

procedure TcxCustomCalculator.KeyPress(var Key: Char);
var
  NewButton, OldButton : TcxCalcButtonKind;
begin
  inherited KeyPress(Key);
  if (Key = ^V) then
    PasteFromClipboard
  else
    if (Key = ^C) then CopyToClipboard;

  OldButton := FPressedButton;
  NewButton := GetButtonKindChar(Key);
  if (NewButton <> cbNone) and (OldButton <> NewButton) then
  begin
    DoButtonUp(OldButton);
    FPressedButton := NewButton;
    DoButtonDown(FPressedButton);
  end;
  if FPressedButton in RepeatButtons {cbBack} then ButtonClick(FPressedButton);
end;

procedure TcxCustomCalculator.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  DoButtonUp(FPressedButton);
end;

procedure TcxCustomCalculator.Resize;
begin
  CalcSize(ClientWidth, ClientHeight);
  ClientWidth := FCalcWidth;
  ClientHeight := FCalcHeight;
  inherited;
end;

procedure TcxCustomCalculator.DoButtonDown(ButtonKind : TcxCalcButtonKind);
begin
  if ButtonKind <> cbNone then
  begin
    FButtons[ButtonKind].Down := True;
    InvalidateButton(ButtonKind);
    Update;
    if not (ButtonKind in RepeatButtons) {cbBack} then ButtonClick(ButtonKind);
  end;
end;

procedure TcxCustomCalculator.DoButtonUp(ButtonKind : TcxCalcButtonKind);
begin
  if ButtonKind <> cbNone then
  begin
    FButtons[ButtonKind].Down := False;
    InvalidateButton(ButtonKind);
    FPressedButton := cbNone;
    Update;
  end;
end;

function TcxCustomCalculator.GetEditorValue: String;
begin
  Result := '';
end;

procedure TcxCustomCalculator.SetEditorValue(const Value: String);
begin
end;

procedure TcxCustomCalculator.CreateLayout;
const
  BtnColors : array [cbBack..cbEqual] of TColor = (clMaroon, clMaroon, clMaroon,
    clRed, clRed, clRed, clRed,
    clBlue, clBlue, clBlue, clBlue, clBlue, clBlue, clBlue, clBlue, clBlue, clBlue,
    clBlue, clBlue,
    clRed, clRed, clRed, clRed,
    clNavy, clNavy, clNavy, clRed);
var i : TcxCalcButtonKind;
    X : Integer;
begin
  for i := cbBack to cbEqual do
  begin
    FButtons[i].Kind := i;
    FButtons[i].Text := BtnCaptions[i];
    if i = cbDecimal then FButtons[i].Text := SysUtils.DecimalSeparator
    else  FButtons[i].Text := BtnCaptions[i];
    FButtons[i].FontColor := BtnColors[i];
    FButtons[i].BtnRect := cxEmptyRect;
    FButtons[i].Down := False;
    FButtons[i].Grayed := False;
  end;
  {coord buttons}
  FButtons[cbMC].BtnRect := Rect(FCalcXOfs,
                                 (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                 FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*2);
  FButtons[cbMR].BtnRect := Rect(FCalcXOfs,
                                 (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                 FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*3);
  FButtons[cbMS].BtnRect := Rect(FCalcXOfs,
                                 (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                 FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*4);
  FButtons[cbMP].BtnRect := Rect(FCalcXOfs,
                                 (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                 FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  X := FCalcXOfs+FCalcBtnWidth + FCalcXOfs + 4;
  {7, 8, 9, /, sqrt}
  FButtons[cbNum7].BtnRect := Rect(X+FCalcXOfs,
                                   (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                   X+FCalcXOfs+FCalcBtnWidth,
                                   (FCalcYOfs+FCalcBtnHeight)*2);
  FButtons[cbNum8].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth),
                                   (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*2,
                                   (FCalcYOfs+FCalcBtnHeight)*2);
  FButtons[cbNum9].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*2,
                                   (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*3,
                                   (FCalcYOfs+FCalcBtnHeight)*2);
  FButtons[cbDiv].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*3,
                                   (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*4,
                                   (FCalcYOfs+FCalcBtnHeight)*2);
  FButtons[cbSqrt].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*4,
                                   (FCalcYOfs+FCalcBtnHeight)+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*5,
                                   (FCalcYOfs+FCalcBtnHeight)*2);

  {4, 5, 6, *, %}
  FButtons[cbNum4].BtnRect := Rect(X+FCalcXOfs,
                                  (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                   X+FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*3);
  FButtons[cbNum5].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth),
                                  (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*2,
                                 (FCalcYOfs+FCalcBtnHeight)*3);
  FButtons[cbNum6].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*2,
                                  (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*3,
                                 (FCalcYOfs+FCalcBtnHeight)*3);
  FButtons[cbMul].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*3,
                                  (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*4,
                                 (FCalcYOfs+FCalcBtnHeight)*3);
  FButtons[cbPercent].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*4,
                                  (FCalcYOfs+FCalcBtnHeight)*2+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*5,
                                 (FCalcYOfs+FCalcBtnHeight)*3);

  {1, 2, 3, -, 1/x}
  FButtons[cbNum1].BtnRect := Rect(X+FCalcXOfs,
                                  (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                   X+FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*4);
  FButtons[cbNum2].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth),
                                  (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*2,
                                 (FCalcYOfs+FCalcBtnHeight)*4);
  FButtons[cbNum3].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*2,
                                  (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*3,
                                 (FCalcYOfs+FCalcBtnHeight)*4);
  FButtons[cbSub].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*3,
                                  (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*4,
                                 (FCalcYOfs+FCalcBtnHeight)*4);
  FButtons[cbRev].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*4,
                                  (FCalcYOfs+FCalcBtnHeight)*3+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*5,
                                 (FCalcYOfs+FCalcBtnHeight)*4);

  {0, +/-, ., +, =}
  FButtons[cbNum0].BtnRect := Rect(X+FCalcXOfs,
                                  (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                   X+FCalcXOfs+FCalcBtnWidth,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  FButtons[cbSign].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth),
                                  (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*2,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  FButtons[cbDecimal].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*2,
                                  (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*3,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  FButtons[cbAdd].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*3,
                                  (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*4,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  FButtons[cbEqual].BtnRect := Rect(X+FCalcXOfs+(FCalcXOfs+FCalcBtnWidth)*4,
                                  (FCalcYOfs+FCalcBtnHeight)*4+FCalcYOfs,
                                   X+(FCalcXOfs+FCalcBtnWidth)*5,
                                 (FCalcYOfs+FCalcBtnHeight)*5);
  {C}
  FButtons[cbClear].BtnRect := FButtons[cbEqual].BtnRect;
  FButtons[cbClear].BtnRect.Left := FButtons[cbClear].BtnRect.Right - FCalcLargeBtnWidth;
  FButtons[cbClear].BtnRect.Top := FCalcYOfs;
  FButtons[cbClear].BtnRect.Bottom := FCalcYOfs + FCalcBtnHeight;
  {CE}
  FButtons[cbCancel].BtnRect := FButtons[cbClear].BtnRect;
  FButtons[cbCancel].BtnRect.Right := FButtons[cbClear].BtnRect.Left - FCalcYOfs;
  FButtons[cbCancel].BtnRect.Left := FButtons[cbCancel].BtnRect.Right - FCalcLargeBtnWidth;
  {Back}
  FButtons[cbBack].BtnRect := FButtons[cbCancel].BtnRect;
  FButtons[cbBack].BtnRect.Right := FButtons[cbBack].BtnRect.Left - FCalcYOfs;
  FButtons[cbBack].BtnRect.Left := FButtons[cbBack].BtnRect.Right - FCalcLargeBtnWidth;
  // ResetOperands;
  ResetOperands;
  // Update Memory display
  UpdateMemoryButtons;
end;

procedure TcxCustomCalculator.ResetOperands;
begin
  FOperator := cbEqual;
  FStatus := csFirst;
  FMemory := 0.0;
end;

procedure TcxCustomCalculator.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TcxCustomCalculator.SetFocusRectVisible(Value : Boolean);
begin
  if FFocusRectVisible <> Value then
  begin
    FFocusRectVisible := Value;
    Invalidate;
  end;
end;

procedure TcxCustomCalculator.CalcSize(AWidth, AHeight : Integer);
var
  h, NearHeight, d, dMin : Integer;

  function CalcHeight(ABtnHeight:Integer):Integer;
  var FYOfs : Integer;
  begin
    FYOfs := MulDiv(ABtnHeight, cxMinCalcYOfs, cxMinCalcBtnHeight);
    Result := (FYOfs + ABtnHeight) * 5 + FYOfs;
  end;

begin
  if AutoFontSize then
  begin
    h := MulDiv(AWidth, cxMinCalcHeight, cxMinCalcWidth);
    if AHeight > h then AHeight := h;
    {Calculate nearest FCalcHeight }
    h := cxMinCalcBtnHeight;
    NearHeight := h;
    dMin := AHeight;
    while True do
    begin
      d := abs(CalcHeight(h) - AHeight);
      if d < dMin then
      begin
        dMin := d;
        NearHeight := h;
      end
      else
        Break;
      inc(h);
    end;
  end
  else
    NearHeight := Canvas.FontHeight(Font) * 2;
  FCalcBtnHeight     := NearHeight;
  FCalcBtnWidth      := MulDiv(FCalcBtnHeight, cxMinCalcBtnWidth, cxMinCalcBtnHeight);
  FCalcYOfs          := MulDiv(FCalcBtnHeight, cxMinCalcYOfs, cxMinCalcBtnHeight);
  FCalcXOfs          := FCalcYOfs;
  FCalcLargeBtnWidth := MulDiv(FCalcBtnWidth, 17, 10);
  FCalcFontSize      := MulDiv(FCalcBtnHeight, cxMinCalcFontSize, cxMinCalcBtnHeight);
  FCalcHeight        := (FCalcYOfs+FCalcBtnHeight)*5+FCalcYOfs;
  FCalcWidth         := (FCalcXOfs+FCalcBtnWidth)*6+FCalcXOfs*2+4;
  // reCalc rect buttons
  CreateLayout;
end;

procedure TcxCustomCalculator.FontChanged;
begin
  if not (csLoading in ComponentState) then ParentFont := False;
  inherited FontChanged;
end;

procedure TcxCustomCalculator.FocusChanged;
begin
  inherited FocusChanged;
  InvalidateButton(cbEqual);
end;

procedure TcxCustomCalculator.SetEnabled( Value: Boolean);
begin
  inherited;
  Invalidate;
end;

procedure TcxCustomCalculator.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
    if FDownButton <> cbNone then
      FButtons[FDownButton].Down := False;
  end;
end;

procedure TcxCustomCalculator.TrackButton(X,Y: Integer);
var
  FlagRepaint : Boolean;
begin
  if FDownButton <> cbNone then
  begin
    FlagRepaint := (GetButtonKindAt(X, Y) = FDownButton) <> FButtons[FDownButton].Down;
    FButtons[FDownButton].Down := (GetButtonKindAt(X, Y) = FDownButton);
    if FlagRepaint then
      InvalidateButton(FDownButton);
  end;
end;

procedure TcxCustomCalculator.InvalidateButton(ButtonKind : TcxCalcButtonKind);
var
  R: TRect;
begin
  if ButtonKind <> cbNone then
  begin
    R := FButtons[ButtonKind].BtnRect;
    InvalidateRect(R, False);
  end;
end;

procedure TcxCustomCalculator.MouseLeave(AControl: TControl);
begin
  inherited;
  if GetPainter.IsButtonHotTrack and Enabled and
     not Dragging and (FActiveButton <> cbNone) then
  begin
    InvalidateButton(FActiveButton);
    FActiveButton := cbNone;
  end;
end;

function TcxCustomCalculator.GetButtonKindChar(Ch : Char) : TcxCalcbuttonKind;
begin
  case Ch of
    '0'..'9' : Result := TcxCalcbuttonKind(Ord(cbNum0)+Ord(Ch)-Ord('0'));
    '+' : Result := cbAdd;
    '-' : Result := cbSub;
    '*' : Result := cbMul;
    '/' : Result := cbDiv;
    '%' : Result := cbPercent;
    '=' : Result := cbEqual;
    #8 : Result := cbBack;
    '@' : Result := cbSqrt;
    '.', ',': Result := cbDecimal;
  else
    Result := cbNone;
  end;
end;

function TcxCustomCalculator.GetButtonKindKey(Key: Word; Shift: TShiftState) : TcxCalcbuttonKind;
begin
  Result := cbNone;
  case Key of
    VK_RETURN : Result := cbEqual;
    VK_ESCAPE : Result := cbClear;
    VK_F9 : Result := cbSign;
    VK_DELETE : Result := cbCancel;
    Ord('C'){VK_C} : if not (ssCtrl in Shift) then Result := cbClear;
    Ord('P'){VK_P} : if ssCtrl in Shift then Result := cbMP;
    Ord('L'){VK_L} : if ssCtrl in Shift then Result := cbMC;
    Ord('R'){VK_R} : if ssCtrl in Shift then Result := cbMR
                     else Result := cbRev;
    Ord('M'){VK_M} : if ssCtrl in Shift then Result := cbMS;
  end;
end;

procedure TcxCustomCalculator.CopyToClipboard;
begin
  Clipboard.AsText := GetEditorValue;
end;

procedure TcxCustomCalculator.PasteFromClipboard;
var
  S, S1 : String;
  i : Integer;
begin
  if Clipboard.HasFormat(CF_TEXT) then
    try
      S := Clipboard.AsText;
      S1 := '';
      repeat
        i := Pos(CurrencyString, S);
        if i > 0 then
        begin
          S1 := S1 + Copy(S, 1, i - 1);
          S := Copy(S, i + Length(CurrencyString), MaxInt);
        end
        else
          S1 := S1 + S;
      until i <= 0;
      SetDisplay(StrToFloat(Trim(S1)));
      FStatus := csValid;
    except
      SetDisplay(0.0);
    end;
end;

procedure TcxCustomCalculator.SetAutoFontSize(Value : Boolean);
begin
  if AutoFontSize <> Value then
  begin
    FAutoFontSize := Value;
    Font.OnChange(nil);
  end;
end;

// math routines
procedure TcxCustomCalculator.Error;
begin
  FStatus := csError;
  SetEditorValue(cxGetResourceString(@scxSCalcError));
  if FBeepOnError then MessageBeep(0);
//  if Assigned(FOnError) then FOnError(Self);
end;

procedure TcxCustomCalculator.CheckFirst;
begin
  if FStatus = csFirst then
  begin
    FStatus := csValid;
    SetEditorValue('0');
  end;
end;

procedure TcxCustomCalculator.Clear;
begin
  FStatus := csFirst;
  SetDisplay(0.0);
  FOperator := cbEqual;
end;

procedure TcxCustomCalculator.ButtonClick(ButtonKind : TcxCalcButtonKind);
var
  AValue : Extended;
  AOldEditorValue: string;
begin
  if Assigned(FOnButtonClick) then FOnButtonClick(Self, ButtonKind);
  if (FStatus = csError) and not (ButtonKind in [cbClear, cbCancel]) then
  begin
    Error;
    Exit;
  end;
  AOldEditorValue := EditorValue;
  LockChanges(True);
  try
    case ButtonKind of
      cbDecimal:
        begin
          CheckFirst;
          if Pos(DecimalSeparator, EditorValue) = 0 then
            SetEditorValue(EditorValue + DecimalSeparator);
        end;
      cbRev:
        if FStatus in [csValid, csFirst] then
        begin
          FStatus := csFirst;
          if FOperator in OperationButtons then
            FStatus := csValid;
          if GetDisplay = 0 then Error else SetDisplay(1.0 / GetDisplay);
        end;
      cbSqrt:
        if FStatus in [csValid, csFirst] then
        begin
          FStatus := csFirst;
          if FOperator in OperationButtons then
            FStatus := csValid;
          if GetDisplay < 0 then Error else SetDisplay(Sqrt(GetDisplay));
        end;
      cbNum0..cbNum9:
        begin
          CheckFirst;
          if EditorValue = '0' then SetEditorValue('');
          if Length(EditorValue) < Max(2, FPrecision) + Ord(Boolean(Pos('-', EditorValue))) then
            SetEditorValue(EditorValue + Char(Ord('0')+Byte(ButtonKind)-Byte(cbNum0)))
          else
            if FBeepOnError then MessageBeep(0);
        end;
      cbBack:
        begin
          CheckFirst;
          if (Length(EditorValue) = 1) or ((Length(EditorValue) = 2) and (EditorValue[1] = '-')) then
            SetEditorValue('0')
          else
            SetEditorValue(Copy(EditorValue, 1, Length(EditorValue) - 1));
        end;
      cbSign: SetDisplay(-GetDisplay);
      cbAdd, cbSub, cbMul, cbDiv, cbEqual, cbPercent :
        begin
          if FStatus = csValid then
          begin
            FStatus := csFirst;
            AValue := GetDisplay;
            if ButtonKind = cbPercent then
              case FOperator of
                cbAdd, cbSub : AValue := FOperand * AValue / 100.0;
                cbMul, cbDiv : AValue := AValue / 100.0;
              end;
            case FOperator of
              cbAdd : SetDisplay(FOperand + AValue);
              cbSub : SetDisplay(FOperand - AValue);
              cbMul : SetDisplay(FOperand * AValue);
              cbDiv : if AValue = 0 then Error else SetDisplay(FOperand / AValue);
            end;
          end;
          FOperator := ButtonKind;
          FOperand := GetDisplay;
          if (ButtonKind in ResultButtons) and Assigned(FOnResult) then FOnResult(Self);
        end;
      cbClear, cbCancel: Clear;
      cbMP:
        if FStatus in [csValid, csFirst] then
        begin
          FStatus := csFirst;
          FMemory := FMemory + GetDisplay;
          UpdateMemoryButtons;
          InvalidateMemoryButtons;
        end;
      cbMS:
        if FStatus in [csValid, csFirst] then
        begin
          FStatus := csFirst;
          FMemory := GetDisplay;
          UpdateMemoryButtons;
          InvalidateMemoryButtons;
        end;
      cbMR:
        if FStatus in [csValid, csFirst] then
        begin
          FStatus := csFirst;
          CheckFirst;
          SetDisplay(FMemory);
        end;
      cbMC:
        begin
          FMemory := 0.0;
          UpdateMemoryButtons;
          InvalidateMemoryButtons;
        end;
    end;
  finally
    LockChanges(False, AOldEditorValue <> EditorValue);
  end;
end;

procedure TcxCustomCalculator.UpdateMemoryButtons;
begin
  // Disable buttons
  if FMemory <> 0.0 then
  begin
    FButtons[cbMC].Grayed := False;
    FButtons[cbMR].Grayed := False;
  end
  else
  begin
    FButtons[cbMC].Grayed := True;
    FButtons[cbMR].Grayed := True;
  end;
end;

procedure TcxCustomCalculator.InvalidateMemoryButtons;
begin
  InvalidateButton(cbMC);
  InvalidateButton(cbMR);
end;

function TcxCustomCalculator.GetDisplay: Extended;
var
  S: string;
begin
  if FStatus = csError then
    Result := 0.0
  else
  begin
    S := Trim(GetEditorValue);
    if S = '' then S := '0';
    RemoveThousandSeparator(S);
    Result := StrToFloat(S);
  end;
end;

procedure TcxCustomCalculator.SetDisplay(Value: Extended);
var
  S: string;
begin
  S := FloatToStrF(Value, ffGeneral, Max(2, FPrecision), 0);
  if GetEditorValue <> S then
  begin
    SetEditorValue(S);
    if Assigned(FOnDisplayChange) then FOnDisplayChange(Self);
  end;
end;

function TcxCustomCalculator.GetMemory: Extended;
begin
  Result := FMemory;
end;

procedure TcxCustomCalculator.HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason);
begin
  if Assigned(FOnHidePopup) then FOnHidePopup(Self, AReason);
end;

procedure TcxCustomCalculator.LockChanges(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
begin
end;

{ TcxPopupCalculator }

constructor TcxPopupCalculator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  IsPopupControl := True;
end;

procedure TcxPopupCalculator.Init;
begin
  FPressedButton := cbNone;
end;

function TcxPopupCalculator.GetEditorValue: string;
begin
  Result := Edit.Text;
end;

function TcxPopupCalculator.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  if Edit.ViewInfo.Painter <> nil then
    Result := Edit.ViewInfo.Painter
  else
    Result := GetButtonPainterClass(Edit.PopupControlsLookAndFeel);
end;

procedure TcxPopupCalculator.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_ESCAPE: HidePopup(Self, crCancel);
    VK_INSERT:
      if (Shift = [ssShift]) then
        PasteFromClipboard
      else
        if (Shift = [ssCtrl]) then
          CopyToClipboard;
    VK_F4:
      if not (ssAlt in Shift) then
        HidePopup(Self, crClose);
    VK_UP, VK_DOWN:
      if Shift = [ssAlt] then
        HidePopup(Self, crClose);
    VK_TAB:
      Edit.DoEditKeyDown(Key, Shift);
    VK_RETURN:
      HidePopup(Self, crEnter);
  end;
end;

procedure TcxPopupCalculator.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key = '=') and FEdit.ActiveProperties.QuickClose then
    HidePopup(Self, crEnter);
end;

procedure TcxPopupCalculator.SetEditorValue(const Value: string);
begin
  if Edit.DoEditing then
  begin
    Edit.InnerEdit.EditValue := Value;
    Edit.ModifiedAfterEnter := True;
  end;
end;

procedure TcxPopupCalculator.LockChanges(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
begin
  inherited;
  Edit.LockChangeEvents(ALock, AInvokeChangedOnUnlock);
end;

{ TcxCalcEditPropertiesValues }

procedure TcxCalcEditPropertiesValues.Assign(Source: TPersistent);
begin
  if Source is TcxCalcEditPropertiesValues then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      Precision := TcxCalcEditPropertiesValues(Source).Precision;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxCalcEditPropertiesValues.RestoreDefaults;
begin
  BeginUpdate;
  try
    inherited RestoreDefaults;
    Precision := False;
  finally
    EndUpdate;
  end;
end;

procedure TcxCalcEditPropertiesValues.SetPrecision(Value: Boolean);
begin
  if Value <> FPrecision then
  begin
    FPrecision := Value;
    Changed;
  end;
end;

{ TcxCustomCalcEditProperties }

constructor TcxCustomCalcEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FBeepOnError := True;
  FPrecision := cxDefCalcPrecision;
//  MaxLength := cxDefCalcPrecision + 2;
  FQuickClose := False;
  PopupSizeable := False;
  ImmediateDropDown := False;
end;

function TcxCustomCalcEditProperties.GetAssignedValues: TcxCalcEditPropertiesValues;
begin
  Result := TcxCalcEditPropertiesValues(FAssignedValues);
end;

function TcxCustomCalcEditProperties.GetPrecision: Byte;
begin
  if AssignedValues.Precision then
    Result := FPrecision
  else
    if IDefaultValuesProvider <> nil then
      Result := IDefaultValuesProvider.DefaultPrecision
    else
      Result := cxDefCalcPrecision;
  if Result > cxMaxCalcPrecision then
    Result := cxMaxCalcPrecision;
end;

function TcxCustomCalcEditProperties.IsPrecisionStored: Boolean;
begin
  Result := AssignedValues.Precision;
end;

procedure TcxCustomCalcEditProperties.SetAssignedValues(
  Value: TcxCalcEditPropertiesValues);
begin
  FAssignedValues.Assign(Value);
end;

procedure TcxCustomCalcEditProperties.SetBeepOnError(Value: Boolean);
begin
  if Value <> FBeepOnError then
  begin
    FBeepOnError := Value;
    Changed;
  end;
end;

procedure TcxCustomCalcEditProperties.SetPrecision(Value: Byte);
begin
  if AssignedValues.Precision and (Value = FPrecision) then
    Exit;

  AssignedValues.FPrecision := True;
  FPrecision := Value;
  Changed;
end;

procedure TcxCustomCalcEditProperties.SetQuickClose(Value: Boolean);
begin
  if Value <> FQuickClose then
  begin
    FQuickClose := Value;
    Changed;
  end;
end;

procedure TcxCustomCalcEditProperties.SetScientificFormat(Value: Boolean);
begin
  if Value <> FScientificFormat then
  begin
    FScientificFormat := Value;
    Changed;
  end;
end;

procedure TcxCustomCalcEditProperties.SetUseThousandSeparator(Value: Boolean);
begin
  if Value <> FUseThousandSeparator then
  begin
    FUseThousandSeparator := Value;
    Changed;
  end;
end;

function TcxCustomCalcEditProperties.GetAlwaysPostEditValue: Boolean;
begin
  Result := True;
end;

class function TcxCustomCalcEditProperties.GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass;
begin
  Result := TcxCalcEditPropertiesValues;
end;

function TcxCustomCalcEditProperties.HasDigitGrouping(
  AIsDisplayValueSynchronizing: Boolean): Boolean;
begin
  Result := not ScientificFormat and UseThousandSeparator;
end;

function TcxCustomCalcEditProperties.PopupWindowAcceptsAnySize: Boolean;
begin
  Result := False;
end;

function TcxCustomCalcEditProperties.StrToFloatEx(S: string;
  var Value: Extended): Boolean;
var
  E: Extended;
  I: Integer;
begin
  // Ignore Thousand Separators
  for I := Length(S) downto 1 do
    if S[I] = ThousandSeparator then
      Delete(S, I, 1);
  if not TextToFloat(PChar(S), E, fvExtended) or
    ((E <> 0) and ((Abs(E) < MinDouble) or (Abs(E) > MaxDouble))) then
  begin
    Value := 0;
    Result := False;
  end
  else
    begin
      Value := E;
      Result := True;
    end;
end;

procedure TcxCustomCalcEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomCalcEditProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxCustomCalcEditProperties(Source) do
      begin
        Self.BeepOnError := BeepOnError;

        Self.AssignedValues.Precision := False;
        if AssignedValues.Precision then
          Self.Precision := Precision;

        Self.QuickClose := QuickClose;
        Self.ScientificFormat := ScientificFormat;
        Self.UseThousandSeparator := UseThousandSeparator;
      end;
    finally
      EndUpdate
    end
  end  
  else
    inherited Assign(Source);
end;

class function TcxCustomCalcEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxCalcEdit;
end;

function TcxCustomCalcEditProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  if not AEditFocused and not AssignedValues.DisplayFormat and
    (IDefaultValuesProvider <> nil) and
    IDefaultValuesProvider.IsDisplayFormatDefined(True) then
      Result := evsText
  else
    Result := evsValue;
end;

function TcxCustomCalcEditProperties.IsDisplayValueValid(
  var DisplayValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
//  if AEditFocused

  Result := True;
end;

function TcxCustomCalcEditProperties.IsEditValueValid(var EditValue: TcxEditValue;
  AEditFocused: Boolean): Boolean;
var
  AValue: Extended;
begin
  Result := VarIsNumericEx(EditValue) or VarIsSoftNull(EditValue);
  if not Result then
    Result := VarIsStr(EditValue) and
      TextToFloat(PChar(VarToStr(EditValue)), AValue, fvExtended);
end;

procedure TcxCustomCalcEditProperties.PrepareDisplayValue(
  const AEditValue: TcxEditValue; var DisplayValue: TcxEditValue;
  AEditFocused: Boolean);

  procedure RemoveInsignificantZeros(var S: string);
  var
    AExponentialPart: string;
    I: Integer;
  begin
    if Pos(DecimalSeparator, S) = 0 then
      Exit;
    AExponentialPart := RemoveExponentialPart(S);
    I := Length(S);
    while S[I] = '0' do
      Dec(I);
    Delete(S, I + 1, Length(S) - I);
    if S[Length(S)] = DecimalSeparator then
      Delete(S, Length(S), 1);
    S := S + AExponentialPart;
  end;

var
  AFormat: TFloatFormat;
  APrecision: Byte;
  S: string;
begin
  if VarIsSoftNull(AEditValue) then
    S := ''
  else
    if not AEditFocused and AssignedValues.DisplayFormat then
      S := FormatFloat(DisplayFormat, AEditValue)
    else
    begin
      if ScientificFormat then
        AFormat := ffExponent
      else
        AFormat := ffGeneral;
      APrecision := Precision;
      if APrecision = 0 then
        APrecision := cxDefCalcPrecision;
        
      S := FloatToStrF(AEditValue, AFormat, APrecision, 0);
      if UseThousandSeparator and not ScientificFormat then
        InsertThousandSeparator(S);
      if ScientificFormat then
        RemoveInsignificantZeros(S);
    end;
  DisplayValue := S;
end;

procedure TcxCustomCalcEditProperties.ValidateDisplayValue(
  var ADisplayValue: TcxEditValue; var AErrorText: TCaption;
  var Error: Boolean; AEdit: TcxCustomEdit);
begin
  Error := False;
  inherited ValidateDisplayValue(ADisplayValue, AErrorText, Error, AEdit);
end;

{ TcxCustomCalcEdit }

destructor TcxCustomCalcEdit.Destroy;
begin
  FreeAndNil(FCalculator);
  inherited Destroy;
end;

function TcxCustomCalcEdit.GetProperties: TcxCustomCalcEditProperties;
begin
  Result := TcxCustomCalcEditProperties(FProperties);
end;

function TcxCustomCalcEdit.GetActiveProperties: TcxCustomCalcEditProperties;
begin
  Result := TcxCustomCalcEditProperties(InternalGetActiveProperties);
end;

function TcxCustomCalcEdit.GetValue: Extended;
begin
  if VarIsNull(EditValue) or (VarIsStr(EditValue) and (EditValue = '')) then
    Result := 0
  else
    Result := EditValue;
end;

procedure TcxCustomCalcEdit.SetProperties(Value: TcxCustomCalcEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomCalcEdit.SetValue(const Value: Extended);
begin
  InternalEditValue := Value;
end;

procedure TcxCustomCalcEdit.FormatChanged;
begin
  DataBinding.UpdateDisplayValue;
end;

function TcxCustomCalcEdit.CanDropDown: Boolean;
begin
  Result := (not ActiveProperties.ReadOnly) and DataBinding.IsDataAvailable;
end;

procedure TcxCustomCalcEdit.CreatePopupWindow;
begin
  inherited CreatePopupWindow;
  PopupWindow.ModalMode := False;
end;

procedure TcxCustomCalcEdit.DoEnter;
begin
  SynchronizeDisplayValue;
  inherited;
end;

procedure TcxCustomCalcEdit.DoExit;
begin
  inherited;
  DataBinding.UpdateDisplayValue;
end;

procedure TcxCustomCalcEdit.DoInitPopup;
begin
  inherited DoInitPopup;
  ActiveProperties.PopupControl := FCalculator;
end;

procedure TcxCustomCalcEdit.Initialize;
begin
  inherited Initialize;
  Value := 0;
  FCalculator := TcxPopupCalculator.Create(Self);
  FCalculator.Parent := PopupWindow;
  FCalculator.Edit := Self;
  FCalculator.AutoFontSize := False;
  FCalculator.OnHidePopup := HidePopup;
  ActiveProperties.PopupControl := FCalculator;
end;

procedure TcxCustomCalcEdit.InitializePopupWindow;
begin
  inherited InitializePopupWindow;
  with Calculator do
  begin
    HandleNeeded;
    Font.Assign(Self.ActiveStyle.GetVisibleFont);
    FontChanged;
    Resize;
  end;
end;

function TcxCustomCalcEdit.InternalGetEditingValue: TcxEditValue;
begin
  PrepareEditValue(Text, Result, True);
end;

function TcxCustomCalcEdit.IsValidChar(Key: Char): Boolean;

  function NumDigits(const S: string): Byte;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to Length(S) do
      if (S[I] = 'e') or (S[I] = 'E') then
        Break
      else
        if dxCharInSet(S[I], ['0'..'9']) then
          Inc(Result);
  end;

var
  S: string;
  V: Extended;
  StartPos, StopPos: Integer;
begin
  Result := False;
  if not IsNumericChar(Key, ntExponent) then
    Exit;
  S := Text;
  StartPos := SelStart;
  StopPos := SelStart + SelLength;
  Delete(S, SelStart + 1, StopPos - StartPos);
  if (Key = '-') and (S = '') then
  begin
    Result := True;
    Exit;
  end;
  Insert(Key, S, StartPos + 1);
  Result := ActiveProperties.StrToFloatEx(S, V);
end;

procedure TcxCustomCalcEdit.KeyPress(var Key: Char);
begin
  if (Key = '.') or (Key = ',') then
    Key := DecimalSeparator;
  if IsTextChar(Key) and not IsValidChar(Key) then
  begin
    Key := #0;
    if ActiveProperties.BeepOnError then Beep;
  end;
  inherited KeyPress(Key);
end;

procedure TcxCustomCalcEdit.PopupWindowClosed(Sender: TObject);
begin
  if Text = cxGetResourceString(@scxSCalcError) then InternalEditValue := 0;
  if ActiveProperties.AutoSelect then SelectAll else SelStart := Length(Text);
  inherited PopupWindowClosed(Sender);
end;

procedure TcxCustomCalcEdit.PopupWindowShowed(Sender: TObject);
begin
  inherited PopupWindowShowed(Sender);
  FCalculator.Init;
end;

procedure TcxCustomCalcEdit.PropertiesChanged(Sender: TObject);
begin
  if (Sender <> nil) and ActiveProperties.FormatChanging then
    Exit;
  inherited PropertiesChanged(Sender);
  if not PropertiesChangeLocked then
  begin
    FCalculator.BeepOnError := ActiveProperties.BeepOnError;
    FCalculator.Precision := ActiveProperties.Precision;
    ActiveProperties.FChangedLocked := True;
    ActiveProperties.PopupControl := FCalculator;
    ActiveProperties.FChangedLocked := False;
  end;
end;

function TcxCustomCalcEdit.InternalPrepareEditValue(const ADisplayValue: string;
  out EditValue: TcxEditValue): Boolean;
var
  AValue: Extended;
  S: string;
begin
  Result := True;
  S := VarToStr(ADisplayValue);
  if not ActiveProperties.ScientificFormat and ActiveProperties.UseThousandSeparator then
    RemoveThousandSeparator(S);
  if Trim(S) = '' then
    EditValue := Null
  else
  begin
    Result := TextToFloat(PChar(S), AValue, fvExtended);
    if Result then
      EditValue := AValue
    else
      EditValue := Null;
  end;
end;

class function TcxCustomCalcEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomCalcEditProperties;
end;

procedure TcxCustomCalcEdit.PasteFromClipboard;
begin
  if DoEditing then
    Calculator.PasteFromClipboard;
end;

procedure TcxCustomCalcEdit.PrepareEditValue(
  const ADisplayValue: TcxEditValue; out EditValue: TcxEditValue;
  AEditFocused: Boolean);
begin
  InternalPrepareEditValue(ADisplayValue, EditValue);
end;

{ TcxCalcEdit }

class function TcxCalcEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCalcEditProperties;
end;

function TcxCalcEdit.GetActiveProperties: TcxCalcEditProperties;
begin
  Result := TcxCalcEditProperties(InternalGetActiveProperties);
end;

function TcxCalcEdit.GetProperties: TcxCalcEditProperties;
begin
  Result := TcxCalcEditProperties(FProperties);
end;

procedure TcxCalcEdit.SetProperties(Value: TcxCalcEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterCalcEditHelper }

class function TcxFilterCalcEditHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxCalcEdit;
end;

class function TcxFilterCalcEditHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoLess, fcoLessEqual, fcoGreater,
    fcoGreaterEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then
    Result := Result + [fcoBetween, fcoNotBetween, fcoInList, fcoNotInList];
end;

class procedure TcxFilterCalcEditHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  with TcxCustomCalcEditProperties(AProperties) do
    QuickClose := True;
end;

initialization
  GetRegisteredEditProperties.Register(TcxCalcEditProperties, scxSEditRepositoryCalcItem);
  FilterEditsController.Register(TcxCalcEditProperties, TcxFilterCalcEditHelper);

finalization
  FilterEditsController.Unregister(TcxCalcEditProperties, TcxFilterCalcEditHelper);

end.
