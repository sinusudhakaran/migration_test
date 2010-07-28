
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

unit cxMemo;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Classes, Controls, Forms, Graphics, Menus, StdCtrls, SysUtils, cxClasses,
  cxContainer, cxControls, cxDataStorage, cxDataUtils, cxEdit, cxDrawTextUtils,
  cxGraphics, cxLookAndFeels, cxTextEdit, cxFilterControlUtils;

type
  { IcxInnerMemo }

  IcxInnerMemo = interface(IcxInnerTextEdit)
  ['{9D0DFE35-58DC-4C0C-9C98-65C5AAD757C9}']
    function GetCaretPos: TPoint;
    function GetLines: TStrings;
    function GetScrollBars: TScrollStyle;
    function GetWantReturns: Boolean;
    function GetWantTabs: Boolean;
    function GetWordWrap: Boolean;
    procedure SetCaretPos(const Value: TPoint);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetWantReturns(Value: Boolean);
    procedure SetWantTabs(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
    property CaretPos: TPoint read GetCaretPos write SetCaretPos;
    property Lines: TStrings read GetLines;
    property ScrollBars: TScrollStyle read GetScrollBars write SetScrollBars;
    property WantReturns: Boolean read GetWantReturns write SetWantReturns;
    property WantTabs: Boolean read GetWantTabs write SetWantTabs;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap; 
  end;

  { TcxCustomTextEditViewInfo }

  TcxCustomMemoViewInfo = class(TcxCustomTextEditViewInfo)
  public
    procedure DrawText(ACanvas: TcxCanvas); override;
  end;

  { TcxCustomMemoViewData }

  TcxCustomMemoProperties = class;

  TcxCustomMemoViewData = class(TcxCustomTextEditViewData)
  private
    function GetProperties: TcxCustomMemoProperties;
  protected
    function GetMaxLineCount: Integer; override;
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
      AViewInfo: TcxCustomEditViewInfo): TSize; override;
    function InternalGetEditContentSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;
  public
    function GetDrawTextFlags: DWORD; override;
    function GetDrawTextOffset: TRect; override;
    function GetEditContentSizeCorrection: TSize; override;
    property Properties: TcxCustomMemoProperties read GetProperties;
  end;

  { TcxCustomMemoProperties }

  TcxCustomInnerMemo = class;

  TcxCustomMemoProperties = class(TcxCustomTextEditProperties)
  private
    FScrollBars: TScrollStyle;
    FVisibleLineCount: Integer;
    FWantReturns: Boolean;
    FWantTabs: Boolean;
    FWordWrap: Boolean;
    function GetAlignment: TAlignment;
    function IsAlignmentStored: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetVisibleLineCount(Value: Integer);
    procedure SetWantReturns(Value: Boolean);
    procedure SetWantTabs(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
  protected
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function InnerEditNeedsTabs: Boolean; override;
    function IsMultiLine: Boolean; override;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    // !!!
    property Alignment: TAlignment read GetAlignment write SetAlignment stored IsAlignmentStored;
    property AutoSelect default False;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars default ssNone;
    property VisibleLineCount: Integer read FVisibleLineCount write SetVisibleLineCount default 0;
    property WantReturns: Boolean read FWantReturns write SetWantReturns default True;
    property WantTabs: Boolean read FWantTabs write SetWantTabs default False;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default True;
  end;

  { TcxMemoProperties }

  TcxMemoProperties = class(TcxCustomMemoProperties)
  published
    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property CharCase;
    property ClearKey;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ReadOnly;
    property ScrollBars;
    property VisibleLineCount;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnChange;
    property OnEditValueChanged;
    property OnValidate;
  end;

  { TcxCustomMemo }

  TcxCustomMemo = class(TcxCustomTextEdit)
  private
    FCanCreateScrollBars: Boolean;
    FInternalAction: Boolean;
    FOldScrollPos: Integer;
    FScrollBarsCalculating: Boolean;
    function GetActiveProperties: TcxCustomMemoProperties;
    function GetCaretPos: TPoint;
    function GetLines: TStrings;
    function GetInnerMemo: IcxInnerMemo;
    function GetProperties: TcxCustomMemoProperties;
    procedure SetCaretPos(const Value: TPoint);
    procedure SetLines(Value: TStrings);
    procedure SetProperties(Value: TcxCustomMemoProperties);
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
  protected
    procedure AdjustInnerEdit; override;
    procedure AdjustInnerEditPosition; override;
    function CanAutoSize: Boolean; override;
    function CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean; override;
    function CanScrollLineWithoutScrollBars(ADirection: TcxDirection): Boolean; override;
    procedure ChangeHandler(Sender: TObject); override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure EnabledChanged; override;
    procedure FontChanged; override;
    function GetInnerEditClass: TControlClass; override;
    procedure Initialize; override;
    procedure InitializeViewData(AViewData: TcxCustomEditViewData); override;
    function SupportsSpelling: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function NeedsScrollBars: Boolean; override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure ReadState(Reader: TReader); override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    function SendActivationKey(Key: Char): Boolean; override;
    procedure SetSelText(const Value: TCaption); override;
    function TabsNeeded: Boolean; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    function CanMemoKeyModifyEdit(Key: Word; Shift: TShiftState;
      AIsKeyPress: Boolean): Boolean; virtual;
    procedure InternalSynchronizeEditValue;
    property InnerMemo: IcxInnerMemo read GetInnerMemo;
    property ScrollBarsCalculating: Boolean read FScrollBarsCalculating;
  public
    procedure ClearSelection; override;
    procedure CutToClipboard; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    function IsEditClass: Boolean; override;
    property ActiveProperties: TcxCustomMemoProperties read GetActiveProperties;
    property CaretPos: TPoint read GetCaretPos write SetCaretPos;
    property Lines: TStrings read GetLines write SetLines;
    property Properties: TcxCustomMemoProperties read GetProperties
      write SetProperties;
  end;

  { TcxMemo }

  TcxMemo = class(TcxCustomMemo)
  private
    function GetActiveProperties: TcxMemoProperties;
    function GetProperties: TcxMemoProperties;
    procedure SetProperties(Value: TcxMemoProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxMemoProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property Lines;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxMemoProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  { TcxFilterMemoHelper }

  TcxFilterMemoHelper = class(TcxFilterTextEditHelper)
  public
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
  end;

  { TcxCustomInnerMemoHelper }

  TcxCustomInnerMemoHelper = class(TcxInterfacedPersistent,
    IcxContainerInnerControl, IcxCustomInnerEdit, IcxInnerTextEdit,
    IcxInnerMemo)
  private
    FEdit: TcxCustomInnerMemo;
  protected
    property Edit: TcxCustomInnerMemo read FEdit;
  public
    constructor Create(AEdit: TcxCustomInnerMemo); reintroduce; virtual;

    // IcxContainerInnerControl
    function GetControlContainer: TcxContainer;
    function GetControl: TWinControl;

    // IcxCustomInnerEdit
    function CallDefWndProc(AMsg: UINT; WParam: WPARAM;
      LParam: LPARAM): LRESULT;
    function GetEditValue: TcxEditValue;
    function GetOnChange: TNotifyEvent;
    procedure LockBounds(ALock: Boolean);
    procedure SafelySetFocus;
    procedure SetEditValue(const Value: TcxEditValue);
    procedure SetParent(Value: TWinControl);
    procedure SetOnChange(Value: TNotifyEvent);

    // IcxInnerTextEdit
    procedure ClearSelection;
    procedure CopyToClipboard;
    function GetAlignment: TAlignment;
    function GetAutoSelect: Boolean;
    function GetCharCase: TEditCharCase;
    function GetEchoMode: TcxEditEchoMode;
    function GetFirstVisibleCharIndex: Integer;
    function GetHideSelection: Boolean;
    function GetImeLastChar: Char;
    function GetImeMode: TImeMode;
    function GetImeName: TImeName;
    function GetInternalUpdating: Boolean;
    function GetMaxLength: Integer;
    function GetMultiLine: Boolean;
    function GetOEMConvert: Boolean;
    function GetOnSelChange: TNotifyEvent;
    function GetPasswordChar: TCaptionChar;
    function GetReadOnly: Boolean;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    procedure SelectAll;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSelect(Value: Boolean);
    procedure SetCharCase(Value: TEditCharCase);
    procedure SetEchoMode(Value: TcxEditEchoMode);
    procedure SetHideSelection(Value: Boolean);
    procedure SetImeMode(Value: TImeMode);
    procedure SetImeName(const Value: TImeName);
    procedure SetInternalUpdating(Value: Boolean);
    procedure SetMaxLength(Value: Integer);
    procedure SetOEMConvert(Value: Boolean);
    procedure SetOnSelChange(Value: TNotifyEvent);
    procedure SetPasswordChar(Value: TCaptionChar);
    procedure SetReadOnly(Value: Boolean);
    procedure SetSelLength(Value: Integer);
    procedure SetSelStart(Value: Integer);
    procedure SetSelText(Value: string);
  {$IFDEF DELPHI12}
    function GetTextHint: string;
    procedure SetTextHint(Value: string);
  {$ENDIF}

    // IcxInnerMemo
    function GetCaretPos: TPoint;
    function GetLines: TStrings;
    function GetScrollBars: TScrollStyle;
    function GetWantReturns: Boolean;
    function GetWantTabs: Boolean;
    function GetWordWrap: Boolean;
    procedure SetCaretPos(const Value: TPoint);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetWantReturns(Value: Boolean);
    procedure SetWantTabs(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
  end;

  { TcxCustomInnerMemo }

  TcxMultiLineEditCharPosition = packed record
    Line, Col: Integer;
  end;

  TcxInnerMemoSelectionState = packed record
    CursorPosition: TcxMultiLineEditCharPosition;
    SelectionStart: TcxMultiLineEditCharPosition;
    SelectionEnd: TcxMultiLineEditCharPosition;
  end;

  TcxCustomInnerMemo = class(TMemo, IUnknown,
    IcxContainerInnerControl, IcxInnerEditHelper)
  private
    FAutoSelect: Boolean;
    FEchoMode: TcxEditEchoMode;
    FEscapePressed: Boolean;
    FHelper: TcxCustomInnerMemoHelper;
    FInternalTextSettingCount: Integer;
    FInternalUpdating: Boolean;
    FIsCreating: Boolean;
    FLockBoundsCount: Integer;
    FOnSelChange: TNotifyEvent;

    procedure BeginInternalTextSetting;
    procedure EndInternalTextSetting;
    function IsInternalTextSetting: Boolean;

    function GetContainer: TcxCustomMemo;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure EMReplaceSel(var Message: TMessage); message EM_REPLACESEL;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMIMEComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  protected
    procedure Click; override;
    procedure DblClick; override;
    procedure DoEnter; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;

    // IcxContainerInnerControl
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;

    // IcxInnerEditHelper
    function GetHelper: IcxCustomInnerEdit;

    property AutoSelect: Boolean read FAutoSelect write FAutoSelect default False;
    property Container: TcxCustomMemo read GetContainer;
    property Helper: TcxCustomInnerMemoHelper read FHelper;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CanFocus: Boolean; override;
    procedure DefaultHandler(var Message); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property CharCase;
    property OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;
  end;

procedure ExtractFirstLine(var AText: WideString; AMaxLength: Integer = 0);
procedure SetMemoCaretPos(AMemo: TCustomMemo; const Value: TPoint);

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Clipbrd, cxEditConsts, cxEditUtils, cxScrollBar;

type
  TWinControlAccess = class(TWinControl);

const
  cxMemoMaxDisplayTextLength = 250;

procedure CorrectLineBreaks(var S: string);
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while I < L do
    if (S[I] = #10) and (S[I + 1] = #13) then
    begin
      S[I] := #13;
      Inc(I);
      S[I] := #10;
      Inc(I);
      Insert(#13#10, S, I);
      Inc(I, 2);
    end
    else
    begin
      if (S[I] = #13) and (S[I + 1] = #10) then
        Inc(I);
      Inc(I);
    end;
end;

procedure DrawMemo(ACanvas: TcxCanvas; AViewInfo: TcxCustomMemoViewInfo);
var
  AText: PcxCaptionChar;
begin
  with AViewInfo do
  begin
    AText := PcxCaptionChar(Text);
    if Length(AText) = 0 then
      Exit;
    ACanvas.Font := Font;
    ACanvas.Font.Color := TextColor;
    InternalTextOut(ACanvas.Canvas, AViewInfo, AText, TextRect, DrawTextFlags,
      SelStart, SelLength, SelBackgroundColor, SelTextColor, MaxLineCount);
  end;
end;

procedure ExtractFirstLine(var AText: WideString; AMaxLength: Integer = 0);
var
  ALength, I: Integer;
begin
  ALength := Length(AText);
  if (AMaxLength > 0) and (ALength > AMaxLength) then
    ALength := AMaxLength;
  for I := 1 to ALength do
    if (AText[I] = #10) or (AText[I] = #13) then
    begin
      SetLength(AText, I - 1);
      Break;
    end;
  if Length(AText) > ALength then
    SetLength(AText, ALength);
end;

procedure SetMemoCaretPos(AMemo: TCustomMemo; const Value: TPoint);
var
  ACharIdx: Integer;
begin
  ACharIdx := SendMessage(AMemo.Handle, EM_LINEINDEX, Value.Y, 0) + Value.X;
  SendMessage(AMemo.Handle, EM_SETSEL, ACharIdx, ACharIdx);
end;

{ TcxCustomMemoViewInfo }

procedure TcxCustomMemoViewInfo.DrawText(ACanvas: TcxCanvas);
begin
  DrawMemo(ACanvas, Self);
end;

{ TcxCustomMemoViewData }

function TcxCustomMemoViewData.GetDrawTextFlags: DWORD;
const
  AAlignmentFlagMap: array [TAlignment] of DWORD = (CXTO_LEFT,
    CXTO_RIGHT, CXTO_CENTER_HORIZONTALLY);
begin
  Result := Integer(CXTO_EDITCONTROL);
  with Properties do
    if not (ScrollBars in [ssHorizontal, ssBoth]) and WordWrap then
      Result := Result or CXTO_WORDBREAK or CXTO_CHARBREAK;
  Result := Result or AAlignmentFlagMap[Properties.Alignment];
  Result := Result or CXTO_PREVENT_LEFT_EXCEED or CXTO_EXPANDTABS;
end;

function TcxCustomMemoViewData.GetDrawTextOffset: TRect;
begin
  Result := EditContentDefaultOffsets[IsInplace];
end;

function TcxCustomMemoViewData.GetEditContentSizeCorrection: TSize;
begin
  with GetDrawTextOffset do
    Result := Size(Left + Right, Top + Bottom);
end;

function TcxCustomMemoViewData.GetMaxLineCount: Integer;
begin
  if Properties.VisibleLineCount > 0 then
    Result := Properties.VisibleLineCount
  else
    Result := inherited GetMaxLineCount;
end;

function TcxCustomMemoViewData.InternalGetEditConstantPartSize(
  ACanvas: TcxCanvas; AIsInplace: Boolean;
  AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
  AViewInfo: TcxCustomEditViewInfo): TSize;
var
  AContentHeight: Integer;
begin
  Result := inherited InternalGetEditConstantPartSize(ACanvas, AIsInplace,
    AEditSizeProperties, MinContentSize, AViewInfo);
  if (Edit <> nil) and (Properties.ScrollBars in [ssHorizontal, ssBoth]) then
    Result.cy := Result.cy + GetScrollBarSize.cy;
  if Properties.VisibleLineCount > 0 then
  begin
    ACanvas.Font := Style.GetVisibleFont;
    AContentHeight := ACanvas.TextHeight('Zg') * Properties.VisibleLineCount +
      GetEditContentSizeCorrection.cy;
    if MinContentSize.cy < AContentHeight then
      MinContentSize.cy := AContentHeight;
  end;
end;

function TcxCustomMemoViewData.InternalGetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; const AEditSizeProperties: TcxEditSizeProperties): TSize;
begin
  Result := GetTextEditContentSize(ACanvas, Self, EditValueToDisplayText(AEditValue),
    GetDrawTextFlags, AEditSizeProperties, Properties.VisibleLineCount);
end;

function TcxCustomMemoViewData.GetProperties: TcxCustomMemoProperties;
begin
  Result := TcxCustomMemoProperties(FProperties);
end;

{ TcxCustomMemoProperties }

constructor TcxCustomMemoProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  inherited Alignment.Vert := taTopJustify;
  AutoSelect := False;
  FScrollBars := ssNone;
  FWantReturns := True;
  FWordWrap := True;
end;

procedure TcxCustomMemoProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomMemoProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomMemoProperties do
      begin
        Self.ScrollBars := ScrollBars;
        Self.VisibleLineCount := VisibleLineCount;
        Self.WantReturns := WantReturns;
        Self.WantTabs := WantTabs;
        Self.WordWrap := WordWrap;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

class function TcxCustomMemoProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxMemo;
end;

function TcxCustomMemoProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
begin
  Result := inherited GetDisplayText(AEditValue);
  if AFullText then
    Exit;
  ExtractFirstLine(Result, cxMemoMaxDisplayTextLength);
end;

class function TcxCustomMemoProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomMemoViewInfo;
end;

function TcxCustomMemoProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  if (IDefaultValuesProvider <> nil) and IDefaultValuesProvider.IsBlob then
    Result := evsValue
  else
    Result := evsText;
end;

class function TcxCustomMemoProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomMemoViewData;
end;

function TcxCustomMemoProperties.InnerEditNeedsTabs: Boolean;
begin
  Result := WantTabs;
end;

function TcxCustomMemoProperties.IsMultiLine: Boolean;
begin
  Result := True;
end;

function TcxCustomMemoProperties.GetAlignment: TAlignment;
begin
  Result := inherited Alignment.Horz;
end;

function TcxCustomMemoProperties.IsAlignmentStored: Boolean;
begin
  Result := inherited Alignment.IsHorzStored;
end;

procedure TcxCustomMemoProperties.SetAlignment(Value: TAlignment);
begin
  inherited Alignment.Horz := Value;
end;

procedure TcxCustomMemoProperties.SetScrollBars(Value: TScrollStyle);
begin
  if Value <> FScrollBars then
  begin
    FScrollBars := Value;
    Changed;
  end;
end;

procedure TcxCustomMemoProperties.SetVisibleLineCount(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if Value <> FVisibleLineCount then
  begin
    FVisibleLineCount := Value;
    Changed;
  end;
end;

procedure TcxCustomMemoProperties.SetWantReturns(Value: Boolean);
begin
  if Value <> FWantReturns then
  begin
    FWantReturns := Value;
    Changed;
  end;
end;

procedure TcxCustomMemoProperties.SetWantTabs(Value: Boolean);
begin
  if Value <> FWantTabs then
  begin
    FWantTabs := Value;
    Changed;
  end;
end;

procedure TcxCustomMemoProperties.SetWordWrap(Value: Boolean);
begin
  if Value <> FWordWrap then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

{ TcxCustomMemo }

procedure TcxCustomMemo.ClearSelection;
var
  APrevKeyboardAction: Boolean;
begin
  if SelLength = 0 then
    Exit;
  if Focused and not DoEditing then
    Exit;
  APrevKeyboardAction := KeyboardAction;
  KeyboardAction := Focused;
  try
    FInternalAction := True;
    try
      InnerMemo.ClearSelection;
    finally
      FInternalAction := False;
    end;
    InternalSynchronizeEditValue;
  finally
    KeyboardAction := APrevKeyboardAction;
  end;
end;

procedure TcxCustomMemo.CutToClipboard;
begin
  if SelLength = 0 then
    Exit;
  InnerTextEdit.CopyToClipboard;
  ClearSelection;
end;

class function TcxCustomMemo.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomMemoProperties;
end;

function TcxCustomMemo.IsEditClass: Boolean;
begin
  Result := True;
end;

procedure TcxCustomMemo.AdjustInnerEdit;
var
  AFont: TFont;
  AInnerControl: TWinControlAccess;
begin
  if (InnerControl = nil) or FIsCreating then
    Exit;
  AInnerControl := TWinControlAccess(InnerControl);
  InnerEdit.LockBounds(True);
  try
    AInnerControl.Color := ViewInfo.BackgroundColor;
    AFont := TFont.Create;
    try
      AFont.Assign(ActiveStyle.GetVisibleFont);
      AFont.Color := ViewInfo.TextColor;
      AssignFonts(AInnerControl.Font, AFont);
    finally
      FreeAndNil(AFont);
    end;
  finally
    InnerEdit.LockBounds(False);
  end;
end;

procedure TcxCustomMemo.AdjustInnerEditPosition;
var
  AInnerEditBounds: TRect;
  R: TRect;
begin
  if (InnerTextEdit = nil) or FInnerEditPositionAdjusting then
    Exit;
  FInnerEditPositionAdjusting := True;
  try
    R := ViewInfo.ClientRect;
    AInnerEditBounds := Rect(R.Left - cxContainerMaxBorderWidth, R.Top - cxContainerMaxBorderWidth,
      R.Right - R.Left + cxContainerMaxBorderWidth * 2, R.Bottom - R.Top + cxContainerMaxBorderWidth * 2);
    with AInnerEditBounds do
      if not EqualRect(InnerEdit.Control.BoundsRect, Rect(Left, Top, Left + Right, Top + Bottom)) then
        InnerEdit.Control.SetBounds(Left, Top, Right, Bottom);
    AlignControls(InnerEdit.Control, R);
  finally
    FInnerEditPositionAdjusting := False;
  end;
end;

function TcxCustomMemo.CanAutoSize: Boolean;
begin
  Result := not IsInplace and (ActiveProperties.VisibleLineCount > 0);
end;

function TcxCustomMemo.CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := inherited CanKeyDownModifyEdit(Key, Shift) or
    CanMemoKeyModifyEdit(Key, Shift, False);
end;

function TcxCustomMemo.CanScrollLineWithoutScrollBars(
  ADirection: TcxDirection): Boolean;
begin
  Result := ADirection in [dirUp, dirDown];
end;

procedure TcxCustomMemo.ChangeHandler(Sender: TObject);
begin
  inherited ChangeHandler(Sender);
  UpdateScrollBarsParameters;
end;

procedure TcxCustomMemo.DoEditKeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited DoEditKeyDown(Key, Shift);
  if Key = 0 then
    Exit;

  if ((Char(Key) = 'a') or (Char(Key) = 'A')) and (ssCtrl in Shift) and
    (Shift * [ssAlt, ssShift] = []) and (Lines.Count > 0) then
  begin
    if InnerControl is TCustomEdit then
      TCustomEdit(InnerControl).SelectAll;
    DoAfterKeyDown(Key, Shift);
    Key := 0;
  end;
end;

procedure TcxCustomMemo.EnabledChanged;
begin
  inherited;
  SetScrollBarsParameters;
end;

procedure TcxCustomMemo.FontChanged;
begin
  inherited FontChanged;
  SetScrollBarsParameters;
end;

function TcxCustomMemo.GetInnerEditClass: TControlClass;
begin
  Result := TcxCustomInnerMemo;
end;

procedure TcxCustomMemo.Initialize;
begin
  inherited Initialize;
  Width := 185;
  Height := 89;
  FOldScrollPos := 0;
end;

procedure TcxCustomMemo.InitializeViewData(AViewData: TcxCustomEditViewData);
begin
  inherited InitializeViewData(AViewData);
  AViewData.HScrollBar := nil;
  AViewData.VScrollBar := nil;
end;

function TcxCustomMemo.SupportsSpelling: Boolean;
begin
  Result := IsTextInputMode; 
end;

procedure TcxCustomMemo.KeyDown(var Key: Word; Shift: TShiftState);
var
  AKey: Word;
begin
  AKey := TranslateKey(Key);
  if IsInplace and (AKey = VK_RETURN) and ((ssCtrl in Shift) and not ActiveProperties.WantReturns or
      not (ssCtrl in Shift) and ActiveProperties.WantReturns) then
    DoEditKeyDown(Key, Shift)
  else
    inherited KeyDown(Key, Shift);
end;

function TcxCustomMemo.NeedsScrollBars: Boolean;
begin
  Result := FCanCreateScrollBars and (ActiveProperties <> nil) and
    (ActiveProperties.ScrollBars <> ssNone);
end;

procedure TcxCustomMemo.PropertiesChanged(Sender: TObject);
begin
  if PropertiesChangeLocked then
    Exit;
  if InnerMemo.ScrollBars <> ActiveProperties.ScrollBars then
  begin
    FCanCreateScrollBars := True;
    CheckNeedsScrollBars;
    InnerMemo.ScrollBars := ActiveProperties.ScrollBars;
    if HandleAllocated then
      RecreateWnd;
    if InnerControl.HandleAllocated then
      TWinControlAccess(InnerControl).RecreateWnd;
  end;
  InnerMemo.WantReturns := ActiveProperties.WantReturns;
  InnerMemo.WantTabs := ActiveProperties.WantTabs;
  InnerMemo.WordWrap := ActiveProperties.WordWrap;
  inherited PropertiesChanged(Sender);
end;

procedure TcxCustomMemo.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if Lines.Count > 0 then
    PrepareEditValue(Text, FEditValue, InternalFocused);
end;

procedure TcxCustomMemo.Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
  var AScrollPos: Integer);
const
  ALineCounts: array[Boolean] of Integer = (-1, 1);
begin
  if AScrollBarKind = sbHorizontal then
  begin
    InnerMemo.CallDefWndProc(WM_HSCROLL,
      Word(AScrollCode) + Word(AScrollPos) shl 16, HScrollBar.Handle);
    AScrollPos := GetScrollPos(InnerControl.Handle, SB_HORZ);
  end
  else
  begin
    if AScrollCode in [scLineDown, scLineUp] then
      SendMessage(InnerControl.Handle, EM_LINESCROLL, 0,
        ALineCounts[AScrollCode = scLineDown])
    else
      InnerMemo.CallDefWndProc(WM_VSCROLL,
        Word(AScrollCode) + Word(AScrollPos) shl 16, VScrollBar.Handle);
    AScrollPos := GetScrollPos(InnerControl.Handle, SB_VERT);
  end;
  if (AScrollCode = scTrack) and (FOldScrollPos <> AScrollPos) then
  begin
    DoLayoutChanged;
    InnerControl.Invalidate;
  end;
  FOldScrollPos := AScrollPos;
  SetScrollBarsParameters;
end;

function TcxCustomMemo.SendActivationKey(Key: Char): Boolean;
begin
  Result := not(TranslateKey(Word(Key)) = VK_RETURN);
end;

procedure TcxCustomMemo.SetSelText(const Value: TCaption);
var
  ANewValue: string;
  ANewValueLength: Integer;
  APrevKeyboardAction: Boolean;
begin
  ANewValue := Value;
  if Focused and (ActiveProperties.MaxLength > 0) and
    (Length(WideString(Copy(Text, 1, SelStart) + Value)) > ActiveProperties.MaxLength) then
  begin
    ANewValueLength := ActiveProperties.MaxLength - Length(WideString(Copy(Text, 1, SelStart)));
    if ANewValueLength <= 0 then
      Exit;
    ANewValue := Copy(WideString(Value), 1, ANewValueLength);
  end;
  if (Focused or FIsChangeBySpellChecker) and not DoEditing then
    Exit;
  APrevKeyboardAction := KeyboardAction;
  KeyboardAction := Focused or FIsChangeBySpellChecker;
  try
    InnerTextEdit.SelText := ANewValue;
    InternalSynchronizeEditValue;
  finally
    KeyboardAction := APrevKeyboardAction;
  end;
end;

function TcxCustomMemo.TabsNeeded: Boolean;
begin
  Result := inherited TabsNeeded or ActiveProperties.WantTabs;
end;

procedure TcxCustomMemo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
  begin
    style := style and not CS_VREDRAW;
    if (ActiveProperties.ScrollBars in [ssHorizontal, ssBoth]) or not ActiveProperties.WordWrap then
      style := style and not CS_HREDRAW;
  end;
end;

procedure TcxCustomMemo.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_NCCALCSIZE,
    WM_WINDOWPOSCHANGED,
    CM_WININICHANGE:
      UpdateScrollBarsParameters;
  end;
end;

function TcxCustomMemo.CanMemoKeyModifyEdit(Key: Word; Shift: TShiftState;
  AIsKeyPress: Boolean): Boolean;
var
  ATranslatedKey: Word;
begin
  ATranslatedKey := TranslateKey(Key);
  Result := (ATranslatedKey = VK_RETURN) and (ActiveProperties.WantReturns or
    (ssCtrl in Shift));
  Result := Result or (ATranslatedKey = VK_TAB) and
    (ActiveProperties.WantTabs or AIsKeyPress);
end;

procedure TcxCustomMemo.InternalSynchronizeEditValue;
begin
  if not KeyboardAction then
  begin
    ResetOnNewDisplayValue;
    SynchronizeEditValue;
    EditModified := False;
  end;
end;

function TcxCustomMemo.GetActiveProperties: TcxCustomMemoProperties;
begin
  Result := TcxCustomMemoProperties(InternalGetActiveProperties);
end;

function TcxCustomMemo.GetCaretPos: TPoint;
begin
  Result := InnerMemo.CaretPos;
end;

function TcxCustomMemo.GetLines: TStrings;
begin
  Result := InnerMemo.Lines;
end;

function TcxCustomMemo.GetInnerMemo: IcxInnerMemo;
begin
  Result := InnerEdit as IcxInnerMemo;
end;

function TcxCustomMemo.GetProperties: TcxCustomMemoProperties;
begin
  Result := TcxCustomMemoProperties(FProperties);
end;

procedure TcxCustomMemo.SetCaretPos(const Value: TPoint);
begin
  InnerMemo.CaretPos := Value;
end;

procedure TcxCustomMemo.SetLines(Value: TStrings);
begin
  InnerMemo.Lines.Assign(Value);
end;

procedure TcxCustomMemo.SetProperties(Value: TcxCustomMemoProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomMemo.WMCommand(var Message: TWMCommand);
begin
  inherited;
  if (Message.NotifyCode = EN_VSCROLL) or (Message.NotifyCode = EN_HSCROLL) then
    SetScrollBarsParameters;
end;

{ TcxMemo }

class function TcxMemo.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMemoProperties;
end;

function TcxMemo.GetActiveProperties: TcxMemoProperties;
begin
  Result := TcxMemoProperties(InternalGetActiveProperties);
end;

function TcxMemo.GetProperties: TcxMemoProperties;
begin
  Result := TcxMemoProperties(FProperties);
end;

procedure TcxMemo.SetProperties(Value: TcxMemoProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterMemoHelper }

class function TcxFilterMemoHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoLike, fcoNotLike, fcoBlanks, fcoNonBlanks];
end;

{ TcxCustomInnerMemoHelper }

constructor TcxCustomInnerMemoHelper.Create(AEdit: TcxCustomInnerMemo);
begin
  inherited Create(nil);
  FEdit := AEdit;
end;

{ IcxContainerInnerControl }
function TcxCustomInnerMemoHelper.GetControlContainer: TcxContainer;
begin
  Result := Edit.Container;
end;

function TcxCustomInnerMemoHelper.GetControl: TWinControl;
begin
  Result := Edit;
end;

{ IcxCustomInnerEdit }
function TcxCustomInnerMemoHelper.CallDefWndProc(AMsg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := CallWindowProc(Edit.DefWndProc, Edit.Handle, AMsg, WParam, LParam);
end;

function TcxCustomInnerMemoHelper.GetEditValue: TcxEditValue;
begin
  Result := Edit.Lines.Text;
end;

function TcxCustomInnerMemoHelper.GetOnChange: TNotifyEvent;
begin
  Result := Edit.OnChange;
end;

procedure TcxCustomInnerMemoHelper.LockBounds(ALock: Boolean);
begin
  with Edit do
    if ALock then
      Inc(FLockBoundsCount)
    else
      if FLockBoundsCount > 0 then
        Dec(FLockBoundsCount);
end;

procedure TcxCustomInnerMemoHelper.SafelySetFocus;
var
  APrevAutoSelect: Boolean;
begin
  with Edit do
  begin
    APrevAutoSelect := AutoSelect;
    AutoSelect := False;
    SetFocus;
    AutoSelect := APrevAutoSelect;
  end;
end;

procedure TcxCustomInnerMemoHelper.SetEditValue(const Value: TcxEditValue);
begin
  with Edit do
    if HandleAllocated then
    begin
      Container.LockChangeEvents(True);
      BeginInternalTextSetting;
      try
        if Container.IsInplace and WordWrap then
          Lines.Clear;
        Lines.Text := VarToStr(Value);
      finally
        EndInternalTextSetting;
        Container.ChangeEventsCatcher.OnEditValueChangedEvent := False;
        Container.LockChangeEvents(False);
      end;
    end
    else
      Text := VarToStr(Value);
end;

procedure TcxCustomInnerMemoHelper.SetParent(Value: TWinControl);
begin
  Edit.Parent := Value;
end;

procedure TcxCustomInnerMemoHelper.SetOnChange(Value: TNotifyEvent);
begin
  Edit.OnChange := Value;
end;

// IcxInnerTextEdit
procedure TcxCustomInnerMemoHelper.ClearSelection;
begin
  Edit.ClearSelection;
end;

procedure TcxCustomInnerMemoHelper.CopyToClipboard;
begin
  Edit.CopyToClipboard;
end;

function TcxCustomInnerMemoHelper.GetAlignment: TAlignment;
begin
  Result := Edit.Alignment;
end;

function TcxCustomInnerMemoHelper.GetAutoSelect: Boolean;
begin
  Result := Edit.AutoSelect;
end;

function TcxCustomInnerMemoHelper.GetCharCase: TEditCharCase;
begin
  Result := Edit.CharCase;
end;

function TcxCustomInnerMemoHelper.GetEchoMode: TcxEditEchoMode;
begin
  Result := eemNormal;
end;

function TcxCustomInnerMemoHelper.GetFirstVisibleCharIndex: Integer;
begin
  Result := LoWord(SendMessage(Edit.Handle, EM_CHARFROMPOS, 0, 0));
end;

function TcxCustomInnerMemoHelper.GetHideSelection: Boolean;
begin
  Result := Edit.HideSelection;
end;

function TcxCustomInnerMemoHelper.GetImeLastChar: Char;
begin
  Result := #0;
end;

function TcxCustomInnerMemoHelper.GetImeMode: TImeMode;
begin
  Result := Edit.ImeMode;
end;

function TcxCustomInnerMemoHelper.GetImeName: TImeName;
begin
  Result := Edit.ImeName;
end;

function TcxCustomInnerMemoHelper.GetInternalUpdating: Boolean;
begin
  Result := Edit.FInternalUpdating;
end;

function TcxCustomInnerMemoHelper.GetMaxLength: Integer;
begin
  Result := Edit.MaxLength;
end;

function TcxCustomInnerMemoHelper.GetMultiLine: Boolean;
begin
  Result := True;
end;

function TcxCustomInnerMemoHelper.GetOEMConvert: Boolean;
begin
  Result := Edit.OEMConvert;
end;

function TcxCustomInnerMemoHelper.GetOnSelChange: TNotifyEvent;
begin
  Result := Edit.OnSelChange;
end;

function TcxCustomInnerMemoHelper.GetPasswordChar: TCaptionChar;
begin
  Result := #0;
end;

function TcxCustomInnerMemoHelper.GetReadOnly: Boolean;
begin
  Result := Edit.ReadOnly;
end;

function TcxCustomInnerMemoHelper.GetSelLength: Integer;
begin
  Result := Edit.SelLength;
end;

function TcxCustomInnerMemoHelper.GetSelStart: Integer;
begin
  Result := Edit.SelStart;
end;

function TcxCustomInnerMemoHelper.GetSelText: string;
begin
  Result := Edit.SelText;
end;

procedure TcxCustomInnerMemoHelper.SelectAll;
begin
  with Edit do
    if HandleAllocated then
      SelectAll;
end;

procedure TcxCustomInnerMemoHelper.SetAlignment(Value: TAlignment);
begin
  with Edit do
  begin
    Alignment := Value;
  end;
end;

procedure TcxCustomInnerMemoHelper.SetAutoSelect(Value: Boolean);
begin
  Edit.AutoSelect := Value;
end;

procedure TcxCustomInnerMemoHelper.SetCharCase(Value: TEditCharCase);
begin
  Edit.CharCase := Value;
end;

procedure TcxCustomInnerMemoHelper.SetEchoMode(Value: TcxEditEchoMode);
begin
end;

procedure TcxCustomInnerMemoHelper.SetHideSelection(Value: Boolean);
begin
  Edit.HideSelection := Value;
end;

procedure TcxCustomInnerMemoHelper.SetImeMode(Value: TImeMode);
begin
  Edit.ImeMode := Value;
end;

procedure TcxCustomInnerMemoHelper.SetImeName(const Value: TImeName);
begin
  Edit.ImeName := Value;
end;

procedure TcxCustomInnerMemoHelper.SetInternalUpdating(Value: Boolean);
begin
  Edit.FInternalUpdating := Value;
end;

procedure TcxCustomInnerMemoHelper.SetMaxLength(Value: Integer);
begin
  Edit.MaxLength := Value;
end;

procedure TcxCustomInnerMemoHelper.SetOEMConvert(Value: Boolean);
begin
  Edit.OEMConvert := Value;
end;

procedure TcxCustomInnerMemoHelper.SetOnSelChange(Value: TNotifyEvent);
begin
  Edit.OnSelChange := Value;
end;

procedure TcxCustomInnerMemoHelper.SetPasswordChar(Value: TCaptionChar);
begin
end;

procedure TcxCustomInnerMemoHelper.SetReadOnly(Value: Boolean);
begin
  Edit.ReadOnly := Value;
end;

procedure TcxCustomInnerMemoHelper.SetSelLength(Value: Integer);
begin
  Edit.SelLength := Value;
end;

procedure TcxCustomInnerMemoHelper.SetSelStart(Value: Integer);
begin
  with Edit do
  begin
    SelStart := Value;
  end;
end;

procedure TcxCustomInnerMemoHelper.SetSelText(Value: string);
begin
  Edit.SelText := Value;
end;

{$IFDEF DELPHI12}
function TcxCustomInnerMemoHelper.GetTextHint: string;
begin
  Result := Edit.TextHint;
end;

procedure TcxCustomInnerMemoHelper.SetTextHint(Value: string);
begin
  Edit.TextHint := Value;
end;
{$ENDIF}

// IcxInnerMemo
function TcxCustomInnerMemoHelper.GetCaretPos: TPoint;
begin
  Result := Edit.CaretPos;
end;

function TcxCustomInnerMemoHelper.GetLines: TStrings;
begin
  Result := Edit.Lines;
end;

function TcxCustomInnerMemoHelper.GetScrollBars: TScrollStyle;
begin
  Result := Edit.ScrollBars;
end;

function TcxCustomInnerMemoHelper.GetWantReturns: Boolean;
begin
  Result := Edit.WantReturns;
end;

function TcxCustomInnerMemoHelper.GetWantTabs: Boolean;
begin
  Result := Edit.WantTabs;
end;

function TcxCustomInnerMemoHelper.GetWordWrap: Boolean;
begin
  Result := Edit.WordWrap;
end;

procedure TcxCustomInnerMemoHelper.SetCaretPos(const Value: TPoint);
begin
  SetMemoCaretPos(Edit, Value);
end;

procedure TcxCustomInnerMemoHelper.SetScrollBars(Value: TScrollStyle);
begin
  Edit.ScrollBars := Value;
end;

procedure TcxCustomInnerMemoHelper.SetWantReturns(Value: Boolean);
begin
  Edit.WantReturns := Value;
end;

procedure TcxCustomInnerMemoHelper.SetWantTabs(Value: Boolean);
begin
  Edit.WantTabs := Value;
end;

procedure TcxCustomInnerMemoHelper.SetWordWrap(Value: Boolean);
begin
  Edit.WordWrap := Value;
end;

{ TcxCustomInnerMemo }

constructor TcxCustomInnerMemo.Create(AOwner: TComponent);
begin
  FIsCreating := True;
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
    Cursor := crIBeam;
  ParentColor := True;
  ParentFont := True;
  FEchoMode := eemNormal;
  FHelper := TcxCustomInnerMemoHelper.Create(Self);
  FInternalUpdating := False;
  FIsCreating := False;
end;

destructor TcxCustomInnerMemo.Destroy;
begin
  FreeAndNil(FHelper);
  inherited Destroy;
end;

procedure TcxCustomInnerMemo.DragDrop(Source: TObject; X, Y: Integer);
begin
  Container.DragDrop(Source, Left + X, Top + Y);
end;

function TcxCustomInnerMemo.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.DataBinding.ExecuteAction(Action);
end;

function TcxCustomInnerMemo.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.DataBinding.UpdateAction(Action);
end;

function TcxCustomInnerMemo.CanFocus: Boolean;
begin
  Result := Container.CanFocus;
end;

procedure TcxCustomInnerMemo.DefaultHandler(var Message);
begin
  if not Container.InnerControlDefaultHandler(TMessage(Message)) then
    inherited DefaultHandler(Message);
end;

procedure TcxCustomInnerMemo.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if not FIsCreating and (FLockBoundsCount = 0) then
  begin
    Container.LockAlignControls(True);
    try
      inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    finally
      Container.LockAlignControls(False);
    end;
  end;
end;

procedure TcxCustomInnerMemo.Click;
begin
  inherited Click;
  Container.Click;
end;

procedure TcxCustomInnerMemo.DblClick;
begin
  inherited DblClick;
  Container.DblClick;
end;

procedure TcxCustomInnerMemo.DoEnter;
begin
  inherited DoEnter;
  if FAutoSelect then
    SelectAll
end;

procedure TcxCustomInnerMemo.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Container.DragOver(Source, Left + X, Top + Y, State, Accept);
end;

procedure TcxCustomInnerMemo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FInternalUpdating := False;
  Container.KeyDown(Key, Shift);
  if Key = 0 then
    FInternalUpdating := True
  else
    inherited KeyDown(Key, Shift);
end;

procedure TcxCustomInnerMemo.KeyPress(var Key: Char);
begin
  FInternalUpdating := False;
//  if not WantTabs and ((Key = Char(VK_TAB))) then
//    Key := #0;
  Container.KeyPress(Key);
  if Key = #0 then
    FInternalUpdating := True
  else
    inherited KeyPress(Key);
end;

procedure TcxCustomInnerMemo.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FInternalUpdating := False;
  if not WantTabs and ((Key = VK_TAB)) then
    Key := 0;
  Container.KeyUp(Key, Shift);
  if Key = 0 then
    FInternalUpdating := True
  else
    inherited KeyUp(Key, Shift);
end;

procedure TcxCustomInnerMemo.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  with Container do
  begin
    InnerControlMouseDown := True;
    try
      MouseDown(Button, Shift, X + Self.Left, Y + Self.Top);
    finally
      InnerControlMouseDown := False;
    end;
  end;
end;

procedure TcxCustomInnerMemo.MouseLeave(AControl: TControl);
begin
  Container.ShortRefreshContainer(True);
end;

procedure TcxCustomInnerMemo.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Container.MouseMove(Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerMemo.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Container.MouseUp(Button, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerMemo.CreateHandle;
begin
  Container.ClearSavedChildControlRegions;
  inherited CreateHandle;
end;

procedure TcxCustomInnerMemo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
  begin
    style := style and not CS_VREDRAW;
    if (ScrollBars in [ssHorizontal, ssBoth]) or not WordWrap then
      style := style and not CS_HREDRAW;
  end;
end;

procedure TcxCustomInnerMemo.CreateWindowHandle(const Params: TCreateParams);
begin
  BeginInternalTextSetting;
  try
    inherited CreateWindowHandle(Params); // do not handle WM_SETTEXT from inherited CreateWindowHandle
  finally
    EndInternalTextSetting;
  end;
  Lines.Text := Text;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerMemo.WndProc(var Message: TMessage);
begin
  if Container.InnerControlMenuHandler(Message) then
    Exit;
  if ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) and
    (Container.DragMode = dmAutomatic) and not Container.IsDesigning then
      Container.BeginAutoDrag
  else
    inherited WndProc(Message);
end;

// IcxContainerInnerControl
function TcxCustomInnerMemo.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxCustomInnerMemo.GetControlContainer: TcxContainer;
begin
  Result := Container;
end;

// IcxInnerEditHelper
function TcxCustomInnerMemo.GetHelper: IcxCustomInnerEdit;
begin
  Result := Helper;
end;

procedure TcxCustomInnerMemo.BeginInternalTextSetting;
begin
  Inc(FInternalTextSettingCount);
end;

procedure TcxCustomInnerMemo.EndInternalTextSetting;
begin
  Dec(FInternalTextSettingCount);
end;

function TcxCustomInnerMemo.IsInternalTextSetting: Boolean;
begin
  Result := FInternalTextSettingCount > 0;
end;

function TcxCustomInnerMemo.GetContainer: TcxCustomMemo;
begin
  Result := TcxCustomMemo(Owner);
end;

procedure TcxCustomInnerMemo.WMClear(var Message: TMessage);
begin
  if Container.FInternalAction then
    inherited
  else
    if not ReadOnly then
      with Container do
      begin
        KeyboardAction := True;
        try
          ClearSelection;
        finally
          KeyboardAction := False;
        end;
      end;
end;

procedure TcxCustomInnerMemo.WMCut(var Message: TMessage);
begin
  with Container do
  begin
    KeyboardAction := True;
    try
      if not Self.ReadOnly then
        CutToClipboard
      else
        CopyToClipboard;
    finally
      KeyboardAction := False;
    end;
  end;
end;

procedure TcxCustomInnerMemo.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if Container.TabsNeeded and (GetKeyState(VK_CONTROL) >= 0) then
    Message.Result := Message.Result or DLGC_WANTTAB;
  if FEscapePressed then
    Message.Result := Message.Result and not DLGC_WANTALLKEYS;
end;

procedure TcxCustomInnerMemo.WMKeyDown(var Message: TWMKeyDown);
var
  AKey: Word;
  APrevState: TcxCustomInnerTextEditPrevState;
  AShiftState: TShiftState;
begin
  SaveTextEditState(Helper, True, APrevState);
  FInternalUpdating := False;
  inherited;
  Container.UpdateScrollBarsParameters;
  if FInternalUpdating then
    Exit;

  AShiftState := KeyDataToShiftState(Message.KeyData);
  if not CheckTextEditState(Helper, APrevState) and (Message.CharCode <> 0) and
    (Message.CharCode <> VK_UP) and (Message.CharCode <> VK_DOWN) then
  begin
    AShiftState := KeyDataToShiftState(Message.KeyData);
    AKey := Message.CharCode;
    Container.DoAfterKeyDown(AKey, AShiftState);
    Message.CharCode := AKey;
  end;
end;

procedure TcxCustomInnerMemo.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) then
    Container.FocusChanged;
end;

procedure TcxCustomInnerMemo.WMNCPaint(var Message: TWMNCPaint);

  function GetScrollBarRect(AScrollBarKind: TScrollBarKind): TRect;
  const
    AScrollBarObjects: array [TScrollBarKind] of Longword = (OBJID_HSCROLL, OBJID_VSCROLL);
  var
    AScrollBarInfo: TcxScrollBarInfo;
    AScrollBarState: DWORD;
  begin
    Result := cxEmptyRect;
    if (csDestroying in ComponentState) or not HandleAllocated then
      Exit;
    if not cxGetScrollBarInfo(Handle, Integer(AScrollBarObjects[AScrollBarKind]),
        AScrollBarInfo) then
      Exit;
    AScrollBarState := AScrollBarInfo.rgstate[0];
    if AScrollBarState and (STATE_SYSTEM_INVISIBLE or STATE_SYSTEM_OFFSCREEN) <> 0 then
      Exit;
    with AScrollBarInfo.rcScrollBar do
    begin
      Result.TopLeft := ScreenToClient(TopLeft);
      Result.Right := Result.Left + Right - Left;
      Result.Bottom := Result.Top + Bottom - Top;
    end;
    OffsetRect(Result, cxContainerMaxBorderWidth, cxContainerMaxBorderWidth);
  end;

  function GetSizeGripRect: TRect;
  var
    RH, RV: TRect;
  begin
    Result := cxEmptyRect;
    RH := GetScrollBarRect(sbHorizontal);
    if IsRectEmpty(RH) then
      Exit;
    RV := GetScrollBarRect(sbVertical);
    if IsRectEmpty(RV) then
      Exit;
    Result := Rect(RV.Left, RH.Top, RV.Right, RH.Bottom);
  end;

  procedure FillSizeGrip;
  var
    ABrush: HBRUSH;
    ADC: HDC;
    R: TRect;
  begin
    if ScrollBars <> ssBoth then
      Exit;
    R := GetSizeGripRect;
    if not IsRectEmpty(R) then
    begin
      ABrush := 0;
      ADC := GetWindowDC(Handle);
      try
        with Container.LookAndFeel do
          ABrush := CreateSolidBrush(ColorToRGB(Painter.DefaultSizeGripAreaColor));
        FillRect(ADC, R, ABrush);
      finally
        if ABrush <> 0 then
          DeleteObject(ABrush);
        ReleaseDC(Handle, ADC);
      end;
    end;
  end;

var
  A: Integer;
begin
  if not UsecxScrollBars then
  begin
    inherited;
    Exit;
  end;
  A := GetWindowLong(Handle, GWL_STYLE);
  A := A and not(WS_HSCROLL or WS_VSCROLL);
  SetWindowLong(Handle, GWL_STYLE, A);
  inherited;
  A := GetWindowLong(Handle, GWL_STYLE);
  if ScrollBars in [ssHorizontal, ssBoth] then
    A := A or WS_HSCROLL;
  if ScrollBars in [ssVertical, ssBoth] then
    A := A or WS_VSCROLL;
  SetWindowLong(Handle, GWL_STYLE, A);
  FillSizeGrip;
end;

procedure TcxCustomInnerMemo.WMPaste(var Message: TMessage);
begin
  if not ReadOnly then
    with Container do
    begin
      KeyboardAction := True;
      try
        PasteFromClipboard;
      finally
        KeyboardAction := False;
      end;
    end;
end;

procedure TcxCustomInnerMemo.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) and (Message.FocusedWnd <> Container.Handle) then
    Container.FocusChanged;
end;

procedure TcxCustomInnerMemo.WMSetFont(var Message: TWMSetFont);
begin
  inherited;
  if (*Container.IsInplace and *)NewStyleControls then
    SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN, 0);
end;

procedure TcxCustomInnerMemo.WMSetText(var Message: TWMSetText);
begin
  inherited;
  if IsInternalTextSetting then
    Exit;
  BeginInternalTextSetting;
  try
    Container.InternalEditValue := string(Message.Text);
  finally
    EndInternalTextSetting;
  end;
end;

procedure TcxCustomInnerMemo.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  Container.SetScrollBarsParameters;
  inherited;
end;

procedure TcxCustomInnerMemo.WMWindowPosChanging(var Message: TWMWindowPosChanging);
begin
  inherited;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerMemo.EMReplaceSel(var Message: TMessage);
var
  APrevLParam: Integer;
  S: string;
begin
  S := PChar(Message.LParam);
  CorrectLineBreaks(S);

  APrevLParam := Message.LParam;
  Message.LParam := Integer(PChar(S));
  try
    inherited;
    Container.SynchronizeEditValue;
  finally
    Message.LParam := APrevLParam;
  end;
end;

procedure TcxCustomInnerMemo.EMSetSel(var Message: TMessage);
begin
  inherited;
  if Assigned(OnSelChange) then
    OnSelChange(Self);
end;

procedure TcxCustomInnerMemo.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxCustomInnerMemo.CNKeyDown(var Message: TWMKeyDown);
begin
  if Message.CharCode = VK_ESCAPE then
    FEscapePressed := True;
  try
    inherited;
  finally
    FEscapePressed := False;
  end;
end;

procedure TcxCustomInnerMemo.WMIMEComposition(var Message: TMessage);
begin
  if Container.DoEditing then
    inherited;
end;

initialization
  GetRegisteredEditProperties.Register(TcxMemoProperties, scxSEditRepositoryMemoItem);
  FilterEditsController.Register(TcxMemoProperties, TcxFilterMemoHelper);

finalization
  FilterEditsController.Unregister(TcxMemoProperties, TcxFilterMemoHelper);
  
end.

