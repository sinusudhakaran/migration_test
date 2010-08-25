
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

unit cxTextEdit;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Classes, Clipbrd, Controls, Forms, Graphics, Menus, StdCtrls, SysUtils, cxClasses,
  cxContainer, cxControls, cxDataUtils, cxEdit, cxDrawTextUtils, cxFormats,
  cxGraphics, cxVariants, cxFilterControlUtils;

const
  cxEditDefaultDropDownPageRowCount = 8;
  ekValueOutOfBounds = 1;

  WM_SPELLCHECKERAUTOCORRECT: Cardinal = WM_DX + 101;

type
  TcxEditEchoMode = (eemNormal, eemPassword);
  TcxEditScrollCause = (escKeyboard, escMouseWheel);
  TcxEditValueBound = (evbMin, evbMax);
  TcxTextEditViewStyle = (vsNormal, vsHideCursor, vsButtonsOnly, vsButtonsAutoWidth);
  TcxTextEditCustomDrawHandler = procedure(ACanvas: TcxCanvas; ARect: TRect) of object;

  TcxCustomTextEdit = class;

  IcxInnerTextEdit = interface(IcxCustomInnerEdit)
  ['{263EBB8D-1EA9-4CAC-8367-ADD74D2A9651}']
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
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    procedure SelectAll;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSelect(Value: Boolean);
    procedure SetCharCase(Value: TEditCharCase);
    procedure SetEchoMode(Value: TcxEditEchoMode);
    procedure SetHideSelection(Value: Boolean);
    procedure SetInternalUpdating(Value: Boolean);
    procedure SetImeMode(Value: TImeMode);
    procedure SetImeName(const Value: TImeName);
    procedure SetMaxLength(Value: Integer);
    procedure SetOEMConvert(Value: Boolean);
    procedure SetOnSelChange(Value: TNotifyEvent);
    procedure SetPasswordChar(Value: TCaptionChar);
    procedure SetSelLength(Value: Integer);
    procedure SetSelStart(Value: Integer);
    procedure SetSelText(Value: string);
  {$IFDEF DELPHI12}
    function GetTextHint: string;
    procedure SetTextHint(Value: string);
  {$ENDIF}
    property Alignment: TAlignment read GetAlignment write SetAlignment;
    property AutoSelect: Boolean read GetAutoSelect write SetAutoSelect;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase;
    property EchoMode: TcxEditEchoMode read GetEchoMode write SetEchoMode;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection;
    property ImeLastChar: Char read GetImeLastChar;
    property ImeMode: TImeMode read GetImeMode write SetImeMode;
    property ImeName: TImeName read GetImeName write SetImeName;
    property InternalUpdating: Boolean read GetInternalUpdating write SetInternalUpdating;
    property MaxLength: Integer read GetMaxLength write SetMaxLength;
    property MultiLine: Boolean read GetMultiLine;
    property OEMConvert: Boolean read GetOEMConvert write SetOEMConvert;
    property PasswordChar: TCaptionChar read GetPasswordChar write SetPasswordChar;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
  {$IFDEF DELPHI12}
    property TextHint: string read GetTextHint write SetTextHint;
  {$ENDIF}
    property OnSelChange: TNotifyEvent read GetOnSelChange write SetOnSelChange;
  end;

  { TcxCustomInnerTextEditHelper }

  TcxCustomInnerTextEdit = class;

  TcxCustomInnerTextEditHelper = class(TcxInterfacedPersistent,
    IcxContainerInnerControl, IcxCustomInnerEdit, IcxInnerTextEdit)
  private
    FAlignmentLock: Boolean;
    FEdit: TcxCustomInnerTextEdit;
    FSelLength: Integer;
    FSelStart: Integer;
    function GetUseLeftAlignmentOnEditing: Boolean;
  protected
    property Edit: TcxCustomInnerTextEdit read FEdit;
    property UseLeftAlignmentOnEditing: Boolean read GetUseLeftAlignmentOnEditing;
  public
    constructor Create(AEdit: TcxCustomInnerTextEdit); reintroduce; virtual;

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
    function GetIsInplace: Boolean;
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
    procedure SetInternalUpdating(Value: Boolean);
    procedure SetImeMode(Value: TImeMode);
    procedure SetImeName(const Value: TImeName);
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
  end;

  { TcxCustomInnerTextEdit }

  TcxCustomInnerTextEditPrevState = record
    IsPrevTextSaved: Boolean;
    PrevText: string;
    PrevSelLength, PrevSelStart: Integer;
  end;

  TcxCustomInnerTextEdit = class(TCustomEdit, IUnknown,
    IcxContainerInnerControl, IcxInnerEditHelper)
  private
    FAlignment: TAlignment;
    FEchoMode: TcxEditEchoMode;
    FDblClickLock: Boolean;
    FDblClickTimer: TcxTimer;
    FHelper: TcxCustomInnerTextEditHelper;
    FImeCharCount: Integer;
    FImeLastChar: Char;
    FInternalUpdating: Boolean;
    FIsCreating: Boolean;
    FLockBoundsCount: Integer;
    FPasswordChar: TCaptionChar;
    FRepaintOnGlass: Boolean;
    FOnSelChange: TNotifyEvent;
    procedure DblClickTimerHandle(Sender: TObject);
    function GetContainer: TcxCustomTextEdit;
    function GetCursorPos: Integer;
    function GetIsDestroying: Boolean;
    procedure InitializeDblClickTimer;
    procedure SetBasedAlignment;
    function NeedAdjustAlignment: Boolean;
    procedure UpdateEchoMode;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMIMEChar(var Message: TMessage); message WM_IME_CHAR;
    procedure WMIMEComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMUndo(var Message: TWMSize); message WM_UNDO;
  protected
    procedure AdjustAlignment; virtual;
    procedure Change; override; // for Delphi .NET
    procedure Click; override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    function GetBasedAlignment: TAlignment;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure AdjustMargins; virtual;
    procedure MouseEnter(AControl: TControl); dynamic;
    procedure MouseLeave(AControl: TControl); dynamic;
    procedure RecreateWnd; // for Delphi .NET

    // IcxContainerInnerControl
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;

    // IcxInnerEditHelper
    function GetHelper: IcxCustomInnerEdit;

    property Alignment: TAlignment read FAlignment;
    property Container: TcxCustomTextEdit read GetContainer;
    property CursorPos: Integer read GetCursorPos;
    property Helper: TcxCustomInnerTextEditHelper read FHelper;
    property IsDestroying: Boolean read GetIsDestroying;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CanFocus: Boolean; override;
    procedure DefaultHandler(var Message); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property AutoSelect;
    property CharCase;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ReadOnly;
    property OnChange;
    property OnSelChange: TNotifyEvent read FOnSelChange write FOnSelChange;
  end;

  { TcxTextEditPropertiesValues }

  TcxTextEditPropertiesValues = class(TcxCustomEditPropertiesValues)
  private
    FDisplayFormat: Boolean;
    FEditFormat: Boolean;
    FMaxLength: Boolean;
    function IsDisplayFormatStored: Boolean;
    function IsEditFormatStored: Boolean;
    procedure SetDisplayFormat(Value: Boolean);
    procedure SetEditFormat(Value: Boolean);
    procedure SetMaxLength(Value: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; override;
  published
    property DisplayFormat: Boolean read FDisplayFormat write SetDisplayFormat
      stored IsDisplayFormatStored;
    property EditFormat: Boolean read FEditFormat write SetEditFormat
      stored IsEditFormatStored;
    property MaxLength: Boolean read FMaxLength write SetMaxLength stored False;
    property MaxValue;
    property MinValue;
  end;

  { TcxCustomEditListBox }

  TcxCustomEditListBox = class(TcxCustomInnerListBox)
  private
    FHotTrack: Boolean;
    FOnSelectItem: TNotifyEvent;
    function GetEdit: TcxCustomTextEdit;
  {$IFNDEF DELPHI6}
    function GetItemIndex: Integer;
  {$ENDIF}
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  protected
    procedure Click; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    function GetItemData(Index: Integer): Longint; override;
    function NeedDrawFocusRect: Boolean; override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetItemData(Index: Integer;
      AData: Longint); override;
    function DoDrawItem(AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState): Boolean; virtual;
    procedure DoSelectItem;
    function GetDefaultItemHeight: Integer;
    function GetItem(Index: Integer): string; virtual;
    procedure InternalRecreateWindow;
    procedure RecreateWindow; virtual;
    procedure SetItemCount(Value: Integer);
    procedure SetItemIndex(const Value: Integer); {$IFDEF DELPHI6}override;{$ELSE}virtual;{$ENDIF}
    property Edit: TcxCustomTextEdit read GetEdit;
    property HotTrack: Boolean read FHotTrack write FHotTrack;
{$IFNDEF DELPHI6}
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
{$ENDIF}
    property OnSelectItem: TNotifyEvent read FOnSelectItem write FOnSelectItem;
  public
    constructor Create(AOwner: TComponent); override;
    function GetHeight(ARowCount: Integer; AMaxHeight: Integer): Integer; virtual;
    function GetItemHeight(AIndex: Integer = -1): Integer; virtual;
    function GetItemWidth(AIndex: Integer): Integer; virtual;
    function IsVisible: Boolean;
    procedure SetScrollWidth(Value: Integer);
  end;

  TcxCustomEditListBoxClass = class of TcxCustomEditListBox;

  { IcxTextEditLookupData }

  TcxEditLookupDataGoDirection = (egdBegin, egdEnd, egdNext, egdPrev, egdPageUp, egdPageDown);

  IcxTextEditLookupData = interface
  ['{F49C5F08-7758-4362-A360-1DF02354E708}']
    function CanResizeVisualArea(var NewSize: TSize;
      AMaxHeight: Integer = 0; AMaxWidth: Integer = 0): Boolean;
    procedure CloseUp;
    procedure Deinitialize;
    procedure DropDown;
    procedure DroppedDown(const AFindStr: string);
    function Find(const AText: string): Boolean;
    function GetActiveControl: TControl;
    function GetCurrentKey: TcxEditValue;
    function GetDisplayText(const AKey: TcxEditValue): string; overload;
    function GetOnCurrentKeyChanged: TNotifyEvent;
    function GetOnSelectItem: TNotifyEvent;
    function GetVisualAreaPreferredSize(AMaxHeight: Integer; AWidth: Integer = 0): TSize;
    procedure Go(ADirection: TcxEditLookupDataGoDirection; ACircular: Boolean);
    procedure Initialize(AVisualControlsParent: TWinControl);
    function IsEmpty: Boolean;
    function IsMouseOverList(const P: TPoint): Boolean;
    function Locate(var AText, ATail: string; ANext: Boolean): Boolean;
    procedure PositionVisualArea(const AClientRect: TRect);
    procedure PropertiesChanged;
    procedure SelectItem;
    procedure SetCurrentKey(const AKey: TcxEditValue);
    procedure SetOnCurrentKeyChanged(Value: TNotifyEvent);
    procedure SetOnSelectItem(Value: TNotifyEvent);
    procedure TextChanged;
    property ActiveControl: TControl read GetActiveControl;
    property CurrentKey: TcxEditValue read GetCurrentKey write SetCurrentKey;
    property OnCurrentKeyChanged: TNotifyEvent read GetOnCurrentKeyChanged write SetOnCurrentKeyChanged;
    property OnSelectItem: TNotifyEvent read GetOnSelectItem write SetOnSelectItem;
  end;

  { TcxCustomTextEditLookupData }

  TcxCustomTextEditProperties = class;

  TcxCustomTextEditLookupData = class(TcxInterfacedPersistent, IcxTextEditLookupData)
  private
    FCurrentKey: Integer;
    FItemIndex: Integer;
    FList: TcxCustomEditListBox;
    FOwner: TPersistent;
    FOnCurrentKeyChanged: TNotifyEvent;
    FOnSelectItem: TNotifyEvent;
    function GetEdit: TcxCustomTextEdit;
    function GetItems: TStrings;
    function GetActiveProperties: TcxCustomTextEditProperties;
    function IndexOf(const AText: string): Integer;
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
  protected
    function GetOwner: TPersistent; override;
    procedure DoCurrentKeyChanged;
    procedure DoSelectItem;
    function GetItem(Index: Integer): string; virtual;
    function GetItemCount: Integer; virtual;
    function GetListBoxClass: TcxCustomEditListBoxClass; virtual;
    procedure HandleSelectItem(Sender: TObject); virtual; // TODO test for CLX
    function InternalLocate(var AText, ATail: string; ANext, ASynchronizeWithText: Boolean):
      Boolean; virtual;
    procedure InternalSetItemIndex(Value: Integer);
    procedure ListChanged; virtual;
    procedure SetListItemIndex(Value: Integer);
    property Edit: TcxCustomTextEdit read GetEdit;
    property ItemIndex: Integer read FItemIndex write SetItemIndex stored False;
    property Items: TStrings read GetItems write SetItems;
    property List: TcxCustomEditListBox read FList;
    property ActiveProperties: TcxCustomTextEditProperties read GetActiveProperties;
  public
    constructor Create(AOwner: TPersistent); override;
    function CanResizeVisualArea(var NewSize: TSize;
      AMaxHeight: Integer = 0; AMaxWidth: Integer = 0): Boolean; virtual;
    procedure CloseUp;
    procedure Deinitialize;
    procedure DropDown; virtual;
    procedure DroppedDown(const AFindStr: string); virtual;
    function Find(const AText: string): Boolean; virtual;
    function GetActiveControl: TControl;
    function GetCurrentKey: TcxEditValue;
    function GetDisplayText(const AKey: TcxEditValue): string; overload;
    function GetOnCurrentKeyChanged: TNotifyEvent;
    function GetOnSelectItem: TNotifyEvent;
    function GetVisualAreaPreferredSize(AMaxHeight: Integer; AWidth: Integer = 0): TSize; virtual;
    procedure Go(ADirection: TcxEditLookupDataGoDirection; ACircular: Boolean);
    procedure Initialize(AVisualControlsParent: TWinControl); virtual;
    procedure InternalSetCurrentKey(Value: Integer);
    function IsEmpty: Boolean;
    function IsMouseOverList(const P: TPoint): Boolean;
    function Locate(var AText, ATail: string; ANext: Boolean): Boolean;
    procedure PositionVisualArea(const AClientRect: TRect); virtual;
    procedure PropertiesChanged; virtual;
    procedure SelectItem;
    procedure SetCurrentKey(const AKey: TcxEditValue);
    procedure SetOnCurrentKeyChanged(Value: TNotifyEvent);
    procedure SetOnSelectItem(Value: TNotifyEvent);
    procedure TextChanged; virtual;
    property ActiveControl: TControl read GetActiveControl;
    property CurrentKey: TcxEditValue read GetCurrentKey write SetCurrentKey;
    property OnCurrentKeyChanged: TNotifyEvent read GetOnCurrentKeyChanged write SetOnCurrentKeyChanged;
    property OnSelectItem: TNotifyEvent read GetOnSelectItem write SetOnSelectItem;
  end;

  { TcxCustomTextEditViewData }

  TcxCustomTextEditViewData = class(TcxCustomEditViewData)
  private
    FIsValueEditorWithValueFormatting: Boolean;
    function GetProperties: TcxCustomTextEditProperties;
    function InvertColor(AColor: TColor): TColor;
  protected
    procedure CalculateButtonNativeInfo(AButtonViewInfo: TcxEditButtonViewInfo); override;
    function GetIsEditClass: Boolean; virtual;
    function GetMaxLineCount: Integer; virtual;
    procedure InitCacheData; override;
    function InternalEditValueToDisplayText(AEditValue: TcxEditValue): string; override;
    function InternalGetEditContentSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;
    function IsComboBoxStyle: Boolean; virtual;
    procedure PrepareDrawTextFlags(ACanvas: TcxCanvas;
      AViewInfo: TcxCustomEditViewInfo); virtual;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); virtual;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    function GetClientExtent(ACanvas: TcxCanvas;
      AViewInfo: TcxCustomEditViewInfo): TRect; override;
    function GetDrawTextFlags: DWORD; virtual;
    function GetDrawTextOffset: TRect; virtual;
    procedure PrepareSelection(AViewInfo: TcxCustomEditViewInfo);
    property Properties: TcxCustomTextEditProperties read GetProperties;
  end;

  { TcxCustomTextEditViewInfo }

  TcxTextOutData = record
    ForceEndEllipsis: Boolean;
    Initialized: Boolean;
    RowCount: Integer;
    SelStart, SelLength: Integer;
    SelBackgroundColor, SelTextColor: TColor;
    TextParams: TcxTextParams;
    TextRect: TRect;
    TextRows: TcxTextRows;
  end;

  TcxCustomTextEditViewInfo = class(TcxCustomEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  public
    ComboBoxStyle: Boolean;
    CustomDrawHandler: TcxTextEditCustomDrawHandler;
    DrawSelectionBar: Boolean;
    DrawTextFlags: DWORD;
    EditingStyle: TcxEditEditingStyle;
    HasPopupWindow: Boolean;
    IsEditClass: Boolean;
    IsOwnerDrawing: Boolean;
    MaxLineCount: Integer;
    SelStart, SelLength: Integer;
    SelTextColor, SelBackgroundColor: TColor;
    Text: string;
    TextOutData: TcxTextOutData;
    TextRect: TRect;
    destructor Destroy; override;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint;
      const AVisibleBounds: TRect; out AText: TCaption;
      out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean; override;
    procedure Offset(DX, DY: Integer); override;
    procedure DrawText(ACanvas: TcxCanvas); virtual;
  {$IFDEF DELPHI10}
    function GetTextBaseLine: Integer; virtual;
  {$ENDIF}
  end;

{ TcxCustomTextEditProperties }

  TcxNewLookupDisplayTextEvent = procedure(Sender: TObject; const AText: TCaption) of object;
  TcxTextEditChars = set of AnsiChar;

  TcxCustomTextEditProperties = class(TcxCustomEditProperties, IcxFormatControllerListener)
  private
    FCharCase: TEditCharCase;
    FDisplayFormat: string;
    FEchoMode: TcxEditEchoMode;
    FEditFormat: string;
    FFixedListSelection: Boolean;
    FFormatChanging: Boolean;
    FHideCursor: Boolean;
    FHideSelection: Boolean;
    FImeMode: TImeMode;
    FImeName: TImeName;
    FImmediateUpdateText: Boolean;
    FIncrementalSearch: Boolean;
    FLookupItems: TStringList;
    FMaxLength: Integer;
    FMRUMode: Boolean;
    FOEMConvert: Boolean;
    FPasswordChar: TCaptionChar;
    FUseDisplayFormatWhenEditing: Boolean;
    FValidChars: TcxTextEditChars;
    FOnNewLookupDisplayText: TcxNewLookupDisplayTextEvent;
    function GetAssignedValues: TcxTextEditPropertiesValues;
    function GetDisplayFormat: string;
    function GetEditFormat: string;
    function GetInnerEditMaxLength: Integer;
    function GetLookupItems: TStrings;
    function GetLookupItemsSorted: Boolean;
    function GetMaxLength: Integer;
    function GetViewStyle: TcxTextEditViewStyle;
    function IsDisplayFormatStored: Boolean;
    function IsEditFormatStored: Boolean;
    function IsMaxLengthStored: Boolean;
    procedure LookupItemsChanged(Sender: TObject);
    procedure ReadIsDisplayFormatAssigned(Reader: TReader); // obsolete
    procedure SetAssignedValues(Value: TcxTextEditPropertiesValues);
    procedure SetDisplayFormat(const Value: string);
    procedure SetEchoMode(Value: TcxEditEchoMode);
    procedure SetEditFormat(const Value: string);
    procedure SetFixedListSelection(Value: Boolean);
    procedure SetHideCursor(Value: Boolean);
    procedure SetHideSelection(Value: Boolean);
    procedure SetImeMode(Value: TImeMode);
    procedure SetImeName(const Value: TImeName);
    procedure SetIncrementalSearch(Value: Boolean);
    procedure SetLookupItems(Value: TStrings);
    procedure SetLookupItemsSorted(Value: Boolean);
    procedure SetMaxLength(Value: Integer);
    procedure SetMRUMode(Value: Boolean);
    procedure SetOEMConvert(Value: Boolean);
    procedure SetPasswordChar(Value: TCaptionChar);
    procedure SetUseDisplayFormatWhenEditing(Value: Boolean);
    procedure SetViewStyle(Value: TcxTextEditViewStyle);
  protected
    procedure AlignmentChangedHandler(Sender: TObject); override;
    procedure BaseSetAlignment(Value: TcxEditAlignment); override;
    function CanValidate: Boolean; override;
    procedure DefineProperties(Filer: TFiler); override; // obsolete
    class function GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass; override;
    function GetDisplayFormatOptions: TcxEditDisplayFormatOptions; override;
    function GetValidateErrorText(AErrorKind: TcxEditErrorKind): string; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;

    // IcxFormatControllerListener
    procedure FormatChanged; virtual;

    function CanIncrementalSearch: Boolean;
    procedure CheckEditorValueBounds(var DisplayValue: TcxEditValue;
      var ErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit); virtual;
    function DefaultFocusedDisplayValue: TcxEditValue; virtual;
    function FindLookupText(const AText: string): Boolean; virtual;
    function GetDefaultDisplayFormat: string; virtual;
    function GetDefaultDisplayValue(const AEditValue: TcxEditValue; AEditFocused: Boolean): TcxEditValue;
    function GetDefaultMaxLength: Integer; virtual;
    function GetDropDownPageRowCount: Integer; virtual;
    function GetEditingStyle: TcxEditEditingStyle; virtual;
    class function GetLookupDataClass: TcxInterfacedPersistentClass; virtual;
    function HasDigitGrouping(AIsDisplayValueSynchronizing: Boolean): Boolean; virtual;
    function InternalGetEditFormat(out AIsCurrency, AIsOnGetTextAssigned: Boolean;
      AEdit: TcxCustomTextEdit = nil): string; virtual;
    function IsEditValueNumeric: Boolean; virtual;
    function IsLookupDataVisual: Boolean; virtual;
    function IsMultiLine: Boolean; virtual;
    function IsPopupKey(Key: Word; Shift: TShiftState): Boolean; virtual;
    function IsValueBoundDefined(ABound: TcxEditValueBound): Boolean; virtual;
    function IsValueBoundsDefined: Boolean; virtual;
    procedure LookupDataChanged(Sender: TObject); virtual;
    procedure MaxLengthChanged; virtual;
    procedure SetCharCase(Value: TEditCharCase); virtual;
    function UseLookupData: Boolean; virtual;
    property AssignedValues: TcxTextEditPropertiesValues read GetAssignedValues
      write SetAssignedValues;
    property EditingStyle: TcxEditEditingStyle read GetEditingStyle;
    property FixedListSelection: Boolean read FFixedListSelection
      write SetFixedListSelection default True;
    property FormatChanging: Boolean read FFormatChanging;
    property HideCursor: Boolean read FHideCursor write SetHideCursor
      stored False;
    property MRUMode: Boolean read FMRUMode write SetMRUMode default False;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; override;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean; override;
    function IsResetEditClass: Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure ValidateDisplayValue(var DisplayValue: TcxEditValue; var ErrorText: TCaption;
      var Error: Boolean; AEdit: TcxCustomEdit); override;
    procedure DisplayValueToDisplayText(var ADisplayValue: string); virtual;
    function IsDisplayValueValid(var DisplayValue: TcxEditValue; AEditFocused: Boolean): Boolean; virtual;
    procedure SetMinMaxValues(AMinValue, AMaxValue: Double);
    property ValidChars: TcxTextEditChars read FValidChars write FValidChars;
    // !!!
    property CharCase: TEditCharCase read FCharCase write SetCharCase default ecNormal;
    property DisplayFormat: string read GetDisplayFormat write SetDisplayFormat
       stored IsDisplayFormatStored;
    property EchoMode: TcxEditEchoMode read FEchoMode write SetEchoMode default eemNormal;
    property EditFormat: string read GetEditFormat write SetEditFormat
       stored IsEditFormatStored;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default True;
    property ImeMode: TImeMode read FImeMode write SetImeMode default imDontCare;
    property ImeName: TImeName read FImeName write SetImeName;
    property ImmediateUpdateText: Boolean read FImmediateUpdateText write FImmediateUpdateText default False;
    property IncrementalSearch: Boolean read FIncrementalSearch
      write SetIncrementalSearch default True;
    property LookupItems: TStrings read GetLookupItems write SetLookupItems;
    property LookupItemsSorted: Boolean read GetLookupItemsSorted write
      SetLookupItemsSorted default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength stored IsMaxLengthStored;
    property MaxValue;
    property MinValue;
    property OEMConvert: Boolean read FOEMConvert write SetOEMConvert default False;
    property PasswordChar: TCaptionChar read FPasswordChar write SetPasswordChar
      default #0;
    property UseDisplayFormatWhenEditing: Boolean
      read FUseDisplayFormatWhenEditing write SetUseDisplayFormatWhenEditing
      default False;
    property ViewStyle: TcxTextEditViewStyle read GetViewStyle write SetViewStyle default vsNormal;
    property OnNewLookupDisplayText: TcxNewLookupDisplayTextEvent read
      FOnNewLookupDisplayText write FOnNewLookupDisplayText;
  end;

  { TcxTextEditProperties }

  TcxTextEditProperties = class(TcxCustomTextEditProperties)
  published
    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property BeepOnError;
    property CharCase;
    property ClearKey;
    property EchoMode;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property IncrementalSearch;
    property LookupItems;
    property LookupItemsSorted;
    property MaxLength;
    property OEMConvert;
    property PasswordChar;
    property ReadOnly;
    property UseLeftAlignmentOnEditing;
    property ValidateOnEnter;
    property OnChange;
    property OnEditValueChanged;
    property OnNewLookupDisplayText;
    property OnValidate;
  end;

  { TcxCustomTextEdit }

  TcxCustomTextEdit = class(TcxCustomEdit, IcxFormatControllerListener)
  private
    FBeepOnEnter: Boolean;
    FDisableRefresh: Boolean;
    FFindSelection: Boolean;
    FInternalTextSetting: Boolean;
    FIsDisplayValueSynchronizing: Boolean;
    FLastFirstVisibleCharIndex: Integer;
    FLastSelLength: Integer;
    FLastSelPosition: Integer;
    FLookupItemsScrolling: Boolean;
    FText: TCaption;
  {$IFDEF CXTEST}
    FHideInnerEdit: Boolean;
    FShowInnerEdit: Boolean;
    FTesting: Boolean;
  {$ENDIF}
    function GetCursorPos: Integer;
    function GetEditingText: TCaption;
    function GetInnerTextEdit: IcxInnerTextEdit;
    function GetILookupData: IcxTextEditLookupData;
    function GetLookupData: TcxCustomTextEditLookupData;
    function GetProperties: TcxCustomTextEditProperties;
    function GetActiveProperties: TcxCustomTextEditProperties;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: TCaption;
    function GetViewInfo: TcxCustomTextEditViewInfo;
    procedure SetFindSelection(Value: Boolean);
    procedure SetItemObject(Value: TObject);
    procedure SetProperties(Value: TcxCustomTextEditProperties);
    procedure SetSelLength(Value: Integer);
    procedure SetSelStart(Value: Integer);
  {$IFDEF DELPHI12}
    function GetTextHint: string;
    procedure SetTextHint(Value: string);
  {$ENDIF}
  {$IFDEF CXTEST}
    procedure SetHideInnerEdit(Value: Boolean);
    procedure SetShowInnerEdit(Value: Boolean);
    procedure SetTesting(Value: Boolean);
  {$ENDIF}
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMGetText(var Message: TWMGetText); message WM_GETTEXT;
    procedure WMGetTextLength(var Message: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;
  protected
    FInnerEditPositionAdjusting: Boolean;
    FIsPopupWindowJustClosed: Boolean;
    FLookupData: TcxInterfacedPersistent;
    FLookupDataTextChangedLocked: Boolean;
    FIsChangeBySpellChecker: Boolean;
    procedure AdjustInnerEditPosition; override;
    function CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean; override;
    function CanKeyPressModifyEdit(Key: Char): Boolean; override;
    procedure ChangeHandler(Sender: TObject); override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEditKeyPress(var Key: Char); override;
    procedure DoExit; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
       MousePos: TPoint): Boolean; override;
    procedure FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties); override;
    function GetDisplayValue: string; override;
    function GetInnerControlBounds(const AInnerControlsRegion: TRect;
      AInnerControl: TControl): TcxContainerInnerControlBounds; override;
    function GetInnerEditClass: TControlClass; override;
    procedure Initialize; override;
    function InternalDoEditing: Boolean; override;
    function InternalGetEditingValue: TcxEditValue; override;
    procedure InternalSetDisplayValue(const Value: TcxEditValue); override;
    procedure InternalValidateDisplayValue(const ADisplayValue: TcxEditValue); override;
    function IsTextInputMode: Boolean; virtual;
    function IsValidChar(AChar: Char): Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure PropertiesChanged(Sender: TObject); override;
    function RefreshContainer(const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): Boolean; override;
    function SetDisplayText(const Value: string): Boolean; override;
    procedure SetInternalDisplayValue(Value: TcxEditValue); override;
    function WantNavigationKeys: Boolean; override;
    procedure LockedInnerEditWindowProc(var Message: TMessage); override;
    procedure UnlockInnerEditRepainting; override;
    procedure WndProc(var Message: TMessage); override;

    // IcxFormatControllerListener
    procedure FormatChanged; virtual;

    // SpellChecking
    procedure DoDrawMisspellings; virtual;
    procedure DoLayoutChanged; virtual;
    procedure DoSelectionChanged; virtual;
    procedure DoTextChanged; virtual;
    procedure InternalCheckSelection;
    procedure InternalSpellCheckerHandler(Message: TMessage); virtual;
    procedure RedrawMisspelledWords;
    procedure SpellCheckerSetSelText(const AValue: string; APost: Boolean = False); override;

    procedure AdjustInnerEdit; virtual;
    function CanChangeSelText(const Value: string; out ANewText: string;
      out ANewSelStart: Integer): Boolean; virtual;
    procedure CheckEditValue; virtual;
    procedure CheckEditorValueBounds; virtual;
    procedure DoOnNewLookupDisplayText(const AText: string); virtual;
    function GetInnerEditHeight: Integer; virtual;
    function GetItemIndex: Integer; virtual;
    function GetItemObject: TObject; virtual;
    function GetScrollLookupDataList(AScrollCause: TcxEditScrollCause): Boolean; virtual;
    procedure HandleSelectItem(Sender: TObject); virtual;
    function InternalGetText: string; virtual;
    function InternalSetText(const Value: string): Boolean; virtual;
    function ItemIndexToLookupKey(AItemIndex: Integer): TcxEditValue; virtual;
    procedure LockLookupDataTextChanged;
    function LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue; virtual;
    function LookupKeyToItemIndex(const AKey: TcxEditValue): Integer; virtual;
    function NeedResetInvalidTextWhenPropertiesChanged: Boolean; virtual;
    procedure ResetOnNewDisplayValue; virtual;
    procedure SelChange(Sender: TObject); virtual;
    procedure SetEditingText(const Value: TCaption); virtual;
    procedure SetItemIndex(Value: Integer); virtual;
    procedure SetSelText(const Value: TCaption); virtual;
    procedure SynchronizeDisplayValue; override;
    procedure SynchronizeEditValue; override;
    procedure UndoPerformed; virtual;
    procedure UnlockLookupDataTextChanged;
    procedure UpdateDrawValue; override;
    procedure UpdateDisplayValue; virtual;

    property BeepOnEnter: Boolean read FBeepOnEnter write FBeepOnEnter default True;
    property InnerTextEdit: IcxInnerTextEdit read GetInnerTextEdit;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex stored False;
    property ItemObject: TObject read GetItemObject write SetItemObject;
    property LookupData: TcxCustomTextEditLookupData read GetLookupData;
    property LookupItemsScrolling: Boolean read FLookupItemsScrolling write FLookupItemsScrolling;
    property ParentColor default False;
    property ViewInfo: TcxCustomTextEditViewInfo read GetViewInfo;
  {$IFDEF DELPHI12}
    property TextHint: string read GetTextHint write SetTextHint;
  {$ENDIF}
  {$IFDEF CXTEST}
    property HideInnerEdit: Boolean read FHideInnerEdit write SetHideInnerEdit; // for test
    property ShowInnerEdit: Boolean read FShowInnerEdit write SetShowInnerEdit; // for test
    property Testing: Boolean read FTesting write SetTesting; // for test
  {$ENDIF}
  public
  {$IFDEF CBUILDER10}
    constructor Create(AOwner: TComponent); override;
  {$ENDIF}
    destructor Destroy; override;
    procedure Activate(var AEditData: TcxCustomEditData); override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure CopyToClipboard; override;
    procedure CutToClipboard; override;
    function IsEditClass: Boolean; override;
    procedure PasteFromClipboard; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure SelectAll; override;
  {$IFDEF DELPHI10}
    function GetTextBaseLine: Integer; override;
    function HasTextBaseLine: Boolean; override;
  {$ENDIF}
    procedure ClearSelection; virtual;
    function DoInnerControlDefaultHandler(var Message: TMessage): Boolean; override;
    function IsChildWindow(AWnd: THandle): Boolean; override;
    procedure SetScrollBarsParameters(AIsScrolling: Boolean = False); override;
    procedure SetSelection(ASelStart: Integer; ASelLength: Integer);
    procedure Undo; virtual;
    property ActiveProperties: TcxCustomTextEditProperties read GetActiveProperties;
    property CursorPos: Integer read GetCursorPos;
    property EditingText: TCaption read GetEditingText write SetEditingText;
    property FindSelection: Boolean read FFindSelection write SetFindSelection;
    property ILookupData: IcxTextEditLookupData read GetILookupData;
    property Properties: TcxCustomTextEditProperties read GetProperties
      write SetProperties;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: TCaption read GetSelText write SetSelText;
    property Text;
  end;

  { TcxTextEdit }

  TcxTextEdit = class(TcxCustomTextEdit)
  private
    function GetActiveProperties: TcxTextEditProperties;
    function GetProperties: TcxTextEditProperties;
    procedure SetProperties(Value: TcxTextEditProperties);
  protected
    function SupportsSpelling: Boolean; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxTextEditProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxTextEditProperties read GetProperties write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Text;
  {$IFDEF DELPHI12}
    property TextHint;
  {$ENDIF}
    property Visible;
    property OnClick;
    property OnContextPopup;
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

  { TcxFilterTextEditHelper }

  TcxFilterTextEditHelper = class(TcxCustomFilterEditHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
    class procedure SetFilterValue(AEdit: TcxCustomEdit; AEditProperties: TcxCustomEditProperties;
      AValue: Variant); override;
  end;

procedure CheckCharsRegister(var AText: string; ACharCase: TEditCharCase);
function CheckTextEditState(ATextEdit: IcxInnerTextEdit; const APrevState:
  TcxCustomInnerTextEditPrevState): Boolean;
procedure DrawEditText(ACanvas: TcxCanvas; AViewInfo: TcxCustomTextEditViewInfo);
procedure DrawTextEdit(ACanvas: TcxCanvas; AViewInfo: TcxCustomTextEditViewInfo);
function GetTextEditContentSize(ACanvas: TcxCanvas; AViewData: TcxCustomEditViewData;
  const AText: string;  ADrawTextFlags: DWORD; const AEditSizeProperties: TcxEditSizeProperties;
  ALineCount: Integer = 0; ACorrectWidth: Boolean = True): TSize;
function GetTextEditDrawTextOffset(AViewData: TcxCustomEditViewData): TRect; overload;
function GetTextEditDrawTextOffset(AAlignment: TAlignment; AIsInplace: Boolean): TRect; overload; // deprecated
procedure InternalTextOut(ACanvas: TCanvas; AViewInfo: TcxCustomTextEditViewInfo;
  AText: PcxCaptionChar; var R: TRect; AFormat: TcxTextOutFormat; ASelStart,
  ASelLength: Integer; ASelBackgroundColor, ASelTextColor: TColor;
  AMaxLineCount: Integer = 0; ALeftIndent: Integer = 0; ARightIndent: Integer = 0);
procedure InsertThousandSeparator(var S: string);
function RemoveExponentialPart(var S: string): string;
procedure RemoveThousandSeparator(var S: string);
procedure SaveTextEditState(ATextEdit: IcxInnerTextEdit;
  ASaveText: Boolean;
  var APrevState: TcxCustomInnerTextEditPrevState);
procedure SeparateDigitGroups(AEdit: TcxCustomTextEdit);

implementation

uses
{$IFDEF DELPHI6}
  FMTBcd,
{$ENDIF}
  Types, cxGeometry, cxEditConsts, cxEditUtils, dxThemeConsts, dxThemeManager,
  cxDWMApi, dxCore;

type
  TCanvasAccess = class(TCanvas);
  TControlAccess = class(TControl);
  TWinControlAccess = class(TWinControl);
  //TcxEditDataBindingAccess = class(TcxEditDataBinding)

const
  WM_REDRAWMISSPELLINGS: Cardinal = WM_DX + 100;

procedure CalculateTextEditViewInfo(ACanvas: TcxCanvas; AViewData: TcxCustomTextEditViewData;
  AViewInfo: TcxCustomTextEditViewInfo; AIsMouseEvent: Boolean);
begin
  with AViewInfo do
  begin
    TextRect := ClientRect;
    ExtendRect(TextRect, AViewData.GetDrawTextOffset);
    if not IsInplace and (TextRect.Bottom - TextRect.Top < ACanvas.TextHeight('Zg')) then
    begin
      TextRect.Bottom := ACanvas.TextHeight('Zg') + TextRect.Top;
      if TextRect.Bottom > ClientRect.Bottom then
        TextRect.Bottom := ClientRect.Bottom;
    end;
  end;
end;

procedure CheckCharsRegister(var AText: string; ACharCase: TEditCharCase);
begin
  if ACharCase = ecUpperCase then
    AText := AnsiUpperCase(AText)
  else
    if ACharCase = ecLowerCase then
      AText := AnsiLowerCase(AText);
end;

function CheckTextEditState(ATextEdit: IcxInnerTextEdit; const APrevState:
  TcxCustomInnerTextEditPrevState): Boolean;
begin
  if not ATextEdit.Control.HandleAllocated then
    Result := True
  else
    with APrevState do
      Result := (PrevSelStart <> ATextEdit.SelStart) or
        (PrevSelLength <> ATextEdit.SelLength) or
        IsPrevTextSaved and not InternalCompareString(PrevText, ATextEdit.EditValue, False);
end;

procedure DrawEditText(ACanvas: TcxCanvas; AViewInfo: TcxCustomTextEditViewInfo);
var
  AText: PcxCaptionChar;
  ATextColor: TColor;
  R: TRect;
begin
  with AViewInfo do
  begin
    AText := PcxCaptionChar(Text);
{$IFNDEF NOFLICKER}
    if StrLen(AText) = 0 then
      Exit;
{$ENDIF}

    R := TextRect;
    if DrawSelectionBar then
      ATextColor := clHighlightText
    else
      ATextColor := TextColor;
    ACanvas.Font := Font;
    ACanvas.Font.Color := ATextColor;
    PrepareCanvasFont(ACanvas.Canvas);
    InternalTextOut(ACanvas.Canvas, AViewInfo, AText, R, DrawTextFlags,
      SelStart, SelLength, SelBackgroundColor, SelTextColor, MaxLineCount);
  end;
end;

procedure DrawTextEdit(ACanvas: TcxCanvas; AViewInfo: TcxCustomTextEditViewInfo);

  function GetBackgroundPaintingStyle: TcxEditBackgroundPaintingStyle;
  begin
    with AViewInfo do
      if ComboBoxStyle then
        if EditingStyle in [esFixedList, esNoEdit] then
          Result := bpsComboListEdit
        else
          Result := bpsComboEdit
      else
        Result := bpsSolid;
  end;

  procedure InternalDrawFocusRect(R: TRect);
  begin
    with AViewInfo, ACanvas do
      if not IsEditClass and Focused and not IsInplace and not HasPopupWindow then
      begin
        if DrawSelectionBar then
        begin
          Canvas.Font.Color := clHighlightText;
          Canvas.Brush.Color := clHighlight;
        end else
        begin
          Canvas.Font.Color := clBtnText;
          Canvas.Brush.Color := AViewInfo.BackgroundColor;
        end;
        TCanvasAccess(Canvas).RequiredState([csFontValid]);
        Canvas.DrawFocusRect(R);
      end;
  end;

var
  ARealTransparent: Boolean;
  R: TRect;
begin
  with AViewInfo, ACanvas do
  begin
    ARealTransparent := Transparent or DrawSelectionBar;
    DrawCustomEdit(ACanvas, AViewInfo, not ARealTransparent, GetBackgroundPaintingStyle);
    R := ClientRect;
    if not IsInplace then
    begin
      if ((NativeState = TC_NONE) or DrawSelectionBar) and not Transparent and
        (AViewInfo.EditingStyle <> esNoEdit) then
          FrameRect(R, BackgroundColor);
      InflateRect(R, -1, -1);
    end;
    if IsOwnerDrawing then
      CustomDrawHandler(ACanvas, R)
    else
    begin
      if DrawSelectionBar then
      begin
        Brush.Color := clHighlight;
        FillRect(R);
      end;
      if IsDBEditPaintCopyDrawing or not HasInnerEdit or not IsEditClass then
        AViewInfo.DrawText(ACanvas);
    end;
    InternalDrawFocusRect(R);
  end;
end;

function GetTextEditContentSize(ACanvas: TcxCanvas; AViewData: TcxCustomEditViewData;
  const AText: string; ADrawTextFlags: DWORD; const AEditSizeProperties: TcxEditSizeProperties;
  ALineCount: Integer = 0; ACorrectWidth: Boolean = True): TSize;

  function GetAutoHeightSize: TSize;
  var
    AAlignment: TcxEditAlignment;
    AFlags: DWORD;
    ARowCount: Integer;
    ATextParams: TcxTextParams;
    ATextRows: TcxTextRows;
    ASizeCorrection: TSize;
    AWidth: Integer;
    R: TRect;
  begin
    AAlignment := nil;
    if not AViewData.IsInplace and (AViewData is TcxCustomTextEditViewData) then
      with TcxCustomTextEditProperties(AViewData.Properties) do
        if (EditingStyle in [esFixedList, esNoEdit]) and
          not (not AViewData.IsInplace and TcxCustomTextEditViewData(AViewData).IsComboBoxStyle and
            AreVisualStylesMustBeUsed(AViewData.Style.LookAndFeel.NativeStyle, totEdit)) then
              AAlignment := Alignment;
    ACanvas.Font := AViewData.Style.GetVisibleFont;
    AFlags := ADrawTextFlags;
    ASizeCorrection := AViewData.GetEditContentSizeCorrection;
    AWidth := AEditSizeProperties.Width;

    if ALineCount > 0 then
    begin
      Result.cy := ACanvas.TextHeight('Zg') * ALineCount;
      Result.cx := AEditSizeProperties.Width;
    end
    else
    begin
      if AViewData.IsInplace then
        Dec(AWidth, 2);
      if AAlignment <> nil then
        Dec(AWidth);
      if AWidth <= 0 then
      begin
        Result.cx := 0;
        if (epoAllowZeroHeight in AViewData.PaintOptions) and (Length(AText) = 0) then
          Result.cy := 0
        else
          Result.cy := ACanvas.TextHeight('Zg');
      end
      else
      begin
        Result.cx := AEditSizeProperties.Width;
        if Length(AText) = 0 then
          if epoAllowZeroHeight in AViewData.PaintOptions then
            Result.cy := 0
          else
            Result.cy := ACanvas.TextHeight('Zg')
        else
        begin
          AFlags := AFlags or CXTO_CALCROWCOUNT;
          if AFlags and CXTO_SINGLELINE <> 0 then
            AFlags := AFlags and not CXTO_SINGLELINE or CXTO_WORDBREAK or
              CXTO_EDITCONTROL;
          AFlags := AFlags and not(CXTO_CENTER_VERTICALLY or CXTO_BOTTOM) or CXTO_TOP;
          R := Rect(0, 0, AWidth, MaxInt);
          ATextParams := cxCalcTextParams(ACanvas.Canvas, AFlags);
          cxMakeTextRows(ACanvas.Canvas, PChar(AText), Length(AText), R, ATextParams,
            ATextRows, ARowCount, AEditSizeProperties.MaxLineCount);
          Result.cy := ARowCount * ACanvas.TextHeight('Zg');
          cxResetTextRows(ATextRows);
        end;
      end;
    end;
    if Result.cy > 0 then
      Result.cy := Result.cy + ASizeCorrection.cy;
  end;

  function GetBestFitSize: TSize;
  var
    AAlignment: TcxEditAlignment;
    AFlags: DWORD;
    ARowCount: Integer;
    ATextParams: TcxTextParams;
    ATextRows: TcxTextRows;
    ATextFlags: Integer;
    ASizeCorrection: TSize;
    R: TRect;
  begin
    AAlignment := nil;
    if not AViewData.IsInplace and (AViewData is TcxCustomTextEditViewData) then
      with TcxCustomTextEditProperties(AViewData.Properties) do
        if (EditingStyle in [esFixedList, esNoEdit]) and
          not (not AViewData.IsInplace and TcxCustomTextEditViewData(AViewData).IsComboBoxStyle and
            AreVisualStylesMustBeUsed(AViewData.Style.LookAndFeel.NativeStyle, totEdit)) then
              AAlignment := Alignment;
    ACanvas.Font := AViewData.Style.GetVisibleFont;
    AFlags := ADrawTextFlags;
    ASizeCorrection := AViewData.GetEditContentSizeCorrection;

    if (AFlags and CXTO_SINGLELINE <> 0) and not ((epoAutoHeight in AViewData.PaintOptions) and
      (esoAutoHeight in AViewData.Properties.GetSupportedOperations)) then
    begin
      ATextFlags := cxTextOutFlagsToDrawTextFlags(AFlags);
      Result.cy := ACanvas.TextHeight('Zg');
      R := Rect(0, 0, MaxInt, 0);
      if Length(AText) = 0 then
        Result.cx := 0
      else
      begin
        ACanvas.TextExtent(AText, R, ATextFlags);
        Result.cx := R.Right - R.Left;
      end;
    end
    else
    begin
      if AFlags and CXTO_SINGLELINE <> 0 then
        AFlags := AFlags and not CXTO_SINGLELINE or
          CXTO_WORDBREAK or CXTO_EDITCONTROL;
      AFlags := AFlags or CXTO_CALCRECT;
      R := Rect(0, 0, MaxInt, MaxInt);

      ARowCount := ALineCount;
      if ARowCount = 0 then
        ARowCount := AEditSizeProperties.MaxLineCount;
      ATextParams := cxCalcTextParams(ACanvas.Canvas, AFlags);
      cxMakeTextRows(ACanvas.Canvas, PChar(AText), Length(AText), R, ATextParams, ATextRows, ARowCount, ARowCount);
      Result.cx := cxGetLongestTextRowWidth(ATextRows, ARowCount);
      cxResetTextRows(ATextRows);
      Result.cy := ACanvas.TextHeight('Zg');
      if ALineCount > 0 then
        Result.cy := Result.cy * ALineCount; 
    end;
    if AAlignment <> nil then
      Result.cx := Result.cx + 1;
    if ACorrectWidth then
      Result.cx := Result.cx + ASizeCorrection.cx;
    if Result.cy > 0 then
      Result.cy := Result.cy + ASizeCorrection.cy;
  end;

begin
  if AEditSizeProperties.Width >= 0 then
    Result := GetAutoHeightSize
  else
    Result := GetBestFitSize;
end;

function GetTextEditDrawTextOffset(AViewData: TcxCustomEditViewData): TRect;
begin
  Result := AViewData.EditContentParams.Offsets;
  if not AViewData.IsInplace and (AViewData is TcxCustomTextEditViewData) then
    with AViewData as TcxCustomTextEditViewData do
      if TcxCustomTextEditProperties(Properties).EditingStyle in [esFixedList, esNoEdit] then
      begin
        if AViewData.VertAlignment = taTopJustify then
        begin
          Inc(Result.Top);
          Dec(Result.Bottom);
        end;
        if AViewData.HorzAlignment = taRightJustify then
          Inc(Result.Right)
        else
          Inc(Result.Left);
      end;
end;

function GetTextEditDrawTextOffset(AAlignment: TAlignment; AIsInplace: Boolean): TRect; // deprecated
begin
  Result := EditContentDefaultOffsets[AIsInplace];
end;

procedure PrepareTextRows(ACanvas: TCanvas; var TextOutData: TcxTextOutData;
  AText: PcxCaptionChar; var R: TRect; AFormat: TcxTextOutFormat; ASelStart,
  ASelLength: Integer; ASelBackgroundColor, ASelTextColor: TColor;
  AMaxLineCount: Integer = 0; ALeftIndent: Integer = 0; ARightIndent: Integer = 0);

  procedure InternalPrepareTextRows;
  var
    ATextLength: Integer;
  begin
    TextOutData.RowCount := 0;
    cxResetTextRows(TextOutData.TextRows);
    ATextLength := StrLen(AText);
    if ATextLength = 0 then
      Exit;
    TextOutData.TextParams := cxCalcTextParams(ACanvas.Handle, AFormat);
    TextOutData.TextRect := cxPrepareRect(R, TextOutData.TextParams, ALeftIndent,
      ARightIndent);

    if not IsRectEmpty(TextOutData.TextRect) then
    begin
      TextOutData.ForceEndEllipsis := not cxMakeTextRows(ACanvas.Handle, AText,
        ATextLength, TextOutData.TextRect, TextOutData.TextParams,
        TextOutData.TextRows, TextOutData.RowCount, AMaxLineCount);
      if TextOutData.RowCount <> 0 then
      begin
        cxPlaceTextRows(ACanvas.Handle, TextOutData.TextRect, TextOutData.TextParams, TextOutData.TextRows, TextOutData.RowCount);
        if (ASelStart < 0) or (ASelStart >= ATextLength) then
          ASelLength := 0
        else
          if (ASelLength + ASelStart) > ATextLength then
            ASelLength := ATextLength - ASelStart;

        TextOutData.SelStart := ASelStart;
        TextOutData.SelLength := ASelLength;
        TextOutData.SelBackgroundColor := ASelBackgroundColor;
        TextOutData.SelTextColor := ASelTextColor;
      end;
    end;
  end;

begin
  TextOutData.Initialized := True;
  InternalPrepareTextRows;
end;

procedure InternalTextOut(ACanvas: TCanvas; AViewInfo: TcxCustomTextEditViewInfo;
  AText: PcxCaptionChar; var R: TRect; AFormat: TcxTextOutFormat; ASelStart,
  ASelLength: Integer; ASelBackgroundColor, ASelTextColor: TColor;
  AMaxLineCount: Integer = 0; ALeftIndent: Integer = 0; ARightIndent: Integer = 0);
begin
  if not AViewInfo.TextOutData.Initialized then
    PrepareTextRows(ACanvas, AViewInfo.TextOutData, AText, R, AFormat, ASelStart,
    ASelLength, ASelBackgroundColor, ASelTextColor, AMaxLineCount, ALeftIndent,
    ARightIndent);
  TCanvasAccess(ACanvas).RequiredState([csFontValid]);
  with AViewInfo.TextOutData do
    cxTextRowsOutHighlight(ACanvas.Handle, TextRect, TextParams, TextRows,
    RowCount, SelStart, SelLength, SelBackgroundColor, SelTextColor, ForceEndEllipsis);
end;

procedure PrepareTextEditDrawTextFlags(ACanvas: TcxCanvas; AViewData: TcxCustomTextEditViewData;
  AViewInfo: TcxCustomTextEditViewInfo);
var
  ADrawTextOffset: TRect;
  AFlags: DWORD;
  R: TRect;
  ATextHeight: Integer;
  ATextParams: TcxTextParams;
  ATextRows: TcxTextRows;
  ARowCount: Integer;
begin
  if AViewData.Style.GetVisibleFont = nil then
    Exit;
  ACanvas.Font := AViewData.Style.GetVisibleFont;
  with AViewInfo do
  begin
    DrawTextFlags := AViewData.GetDrawTextFlags;
    AFlags := DrawTextFlags and not CXTO_SINGLELINE or
      CXTO_WORDBREAK or CXTO_EDITCONTROL or CXTO_CALCROWCOUNT;
    R := Rect(0, 0, TextRect.Right - TextRect.Left, MaxInt);
    ADrawTextOffset := AViewData.GetDrawTextOffset;
    Inc(R.Right, ADrawTextOffset.Left + ADrawTextOffset.Right);
    Dec(R.Right, AViewData.GetEditContentSizeCorrection.cx);
    Dec(R.Right, AViewData.ContentOffset.Left + AViewData.ContentOffset.Right);
    if TcxCustomTextEditProperties(AViewData.Properties).Alignment.Horz = taRightJustify then
      Inc(R.Right);
    ATextParams := cxCalcTextParams(ACanvas.Canvas, AFlags);
// TODO optimize
    cxMakeTextRows(ACanvas.Canvas, PChar(Text), Length(Text), R, ATextParams, ATextRows, ARowCount,
      (TextRect.Bottom - TextRect.Top + ATextParams.RowHeight - 1) div ATextParams.RowHeight + 1);
    ATextHeight := ARowCount * ATextParams.RowHeight;
    if ARowCount > 1 then
    begin
      DrawTextFlags := DrawTextFlags and not CXTO_SINGLELINE or
        CXTO_WORDBREAK or CXTO_EDITCONTROL;
      if ATextHeight > TextRect.Bottom - TextRect.Top then
        DrawTextFlags := DrawTextFlags and not CXTO_BOTTOM
          and not CXTO_CENTER_VERTICALLY or CXTO_TOP;
    end;
    cxResetTextRows(ATextRows);
  end;
end;

procedure InsertThousandSeparator(var S: string);
var
  I, J: Integer;
  ACaption: string;
  APrefix, ASuffix: string;
begin
  APrefix := TrimRight(S);
  ASuffix := Copy(S, Length(APrefix) + 1, Length(S) - Length(APrefix));
  APrefix := TrimLeft(S);
  APrefix := Copy(S, 1, Length(S) - Length(APrefix));
  S := Trim(S);
  ACaption := RemoveExponentialPart(S);
  RemoveThousandSeparator(S);
  I := Pos(DecimalSeparator, S);
  if I = 0 then
    I := Length(S)
  else
    Dec(I);
  J := 0;
  while (I > 1) and cxIsDigitChar(S[I - 1]) do
  begin
    Inc(J);
    if J = 3 then
    begin
      Insert(ThousandSeparator, S, I);
      J := 0;
    end;
    Dec(I);
  end;
  S := APrefix + S + ACaption + ASuffix;
end;

function RemoveExponentialPart(var S: string): string;
var
  APos: Integer;
begin
  APos := Pos('E', UpperCase(S));
  if APos > 0 then
  begin
    Result := Copy(S, APos, Length(S) - APos + 1);
    Delete(S, APos, Length(S) - APos + 1);
  end
  else
    Result := '';
end;

procedure RemoveThousandSeparator(var S: string);
var
  APos: Integer;
begin
  repeat
    APos := Pos(ThousandSeparator, S);
    if APos <> 0 then
      Delete(S, APos, 1);
  until APos = 0;
end;

procedure SaveTextEditState(ATextEdit: IcxInnerTextEdit;
  ASaveText: Boolean;
  var APrevState: TcxCustomInnerTextEditPrevState);
begin
  with APrevState do
  begin
    IsPrevTextSaved := ASaveText;
    if ASaveText then
      PrevText := ATextEdit.EditValue;
    PrevSelStart := ATextEdit.SelStart;
    PrevSelLength := ATextEdit.SelLength;
  end;
end;

procedure SeparateDigitGroups(AEdit: TcxCustomTextEdit);

  function IsValidNumber(S: string): Boolean;
  var
    AValue: Extended;
  begin
    RemoveThousandSeparator(S);
    Result := (S <> '') and TextToFloat(PChar(S), AValue, fvExtended);
  end;

  function GetRealCaretPos: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to AEdit.SelStart do
      if AEdit.Text[I] <> ThousandSeparator then
        Inc(Result);
  end;

  procedure SetRealCaretPos(APrevCaretPos: Integer);
  var
    I: Integer;
    S: string;
  begin
    S := AEdit.Text;
    for I := 1 to Length(S) do
    begin
      if S[I] <> ThousandSeparator then
        Dec(APrevCaretPos);
      if APrevCaretPos = 0 then
      begin
        AEdit.SelStart := I;
        Break;
      end;
    end;
  end;

var
  ACaretPos: Integer;
  S: string;
begin
  S := AEdit.Text;
  InsertThousandSeparator(S);
  if IsValidNumber(S) then
  begin
    ACaretPos := GetRealCaretPos;
    AEdit.SetInternalDisplayValue(S);
    SetRealCaretPos(ACaretPos);
  end;
end;

{ TcxCustomInnerTextEditHelper }

constructor TcxCustomInnerTextEditHelper.Create(AEdit: TcxCustomInnerTextEdit);
begin
  inherited Create(nil);
  FEdit := AEdit;
  FAlignmentLock := False;
end;

// IcxContainerInnerControl
function TcxCustomInnerTextEditHelper.GetControlContainer: TcxContainer;
begin
  Result := Edit.Container;
end;

function TcxCustomInnerTextEditHelper.GetControl: TWinControl;
begin
  Result := Edit;
end;

// IcxCustomInnerEdit
function TcxCustomInnerTextEditHelper.CallDefWndProc(AMsg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := CallWindowProc(Edit.DefWndProc, Edit.Handle, AMsg, WParam, LParam);
end;

function TcxCustomInnerTextEditHelper.GetEditValue: TcxEditValue;
begin
  Result := (Edit.Text);
end;

function TcxCustomInnerTextEditHelper.GetOnChange: TNotifyEvent;
begin
  Result := Edit.OnChange;
end;

procedure TcxCustomInnerTextEditHelper.LockBounds(ALock: Boolean);
begin
  with Edit do
    if ALock then
      Inc(FLockBoundsCount)
    else
      if FLockBoundsCount > 0 then
        Dec(FLockBoundsCount);
end;

procedure TcxCustomInnerTextEditHelper.SafelySetFocus;
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

procedure TcxCustomInnerTextEditHelper.SetEditValue(const Value: TcxEditValue);
var
  ATextChanged: Boolean;
  AIsDesigning: Boolean;
begin
  with Edit do
  begin
    AIsDesigning := csDesigning in ComponentState;
    if AIsDesigning then
      ATextChanged := not InternalCompareString(Text, VarToStr(Value), True)
    else
      ATextChanged := False;
    Text := VarToStr(Value);
    if ATextChanged then
      Change;
  end;
end;

procedure TcxCustomInnerTextEditHelper.SetParent(Value: TWinControl);
begin
  Edit.Parent := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetOnChange(Value: TNotifyEvent);
begin
  Edit.OnChange := Value;
end;

// IcxInnerTextEdit
procedure TcxCustomInnerTextEditHelper.ClearSelection;
begin
  Edit.ClearSelection;
end;

procedure TcxCustomInnerTextEditHelper.CopyToClipboard;
begin
  Edit.CopyToClipboard;
end;

function TcxCustomInnerTextEditHelper.GetAlignment: TAlignment;
begin
  Result := Edit.FAlignment;
end;

function TcxCustomInnerTextEditHelper.GetAutoSelect: Boolean;
begin
  Result := Edit.AutoSelect;
end;

function TcxCustomInnerTextEditHelper.GetCharCase: TEditCharCase;
begin
  Result := Edit.CharCase;
end;

function TcxCustomInnerTextEditHelper.GetEchoMode: TcxEditEchoMode;
begin
  Result := Edit.FEchoMode;
end;

function TcxCustomInnerTextEditHelper.GetFirstVisibleCharIndex: Integer;
begin
  Result := LoWord(SendMessage(Edit.Handle, EM_CHARFROMPOS, 0, 0));
end;

function TcxCustomInnerTextEditHelper.GetHideSelection: Boolean;
begin
  Result := Edit.HideSelection;
end;

function TcxCustomInnerTextEditHelper.GetImeLastChar: Char;
begin
  if Edit.FImeCharCount = 2 then
    Result := Edit.FImeLastChar
  else
    Result := #0;
end;

function TcxCustomInnerTextEditHelper.GetImeMode: TImeMode;
begin
  Result := Edit.ImeMode;
end;

function TcxCustomInnerTextEditHelper.GetImeName: TImeName;
begin
  Result := Edit.ImeName;
end;

function TcxCustomInnerTextEditHelper.GetInternalUpdating: Boolean;
begin
  Result := Edit.FInternalUpdating;
end;

function TcxCustomInnerTextEditHelper.GetIsInplace: Boolean;
begin
  Result := Edit.Container.IsInplace;
end;

function TcxCustomInnerTextEditHelper.GetMaxLength: Integer;
begin
  Result := Edit.MaxLength;
end;

function TcxCustomInnerTextEditHelper.GetMultiLine: Boolean;
begin
  Result := False;
end;

function TcxCustomInnerTextEditHelper.GetPasswordChar: TCaptionChar;
begin
  Result := Edit.FPasswordChar;
end;

function TcxCustomInnerTextEditHelper.GetOEMConvert: Boolean;
begin
  Result := Edit.OEMConvert;
end;

function TcxCustomInnerTextEditHelper.GetOnSelChange: TNotifyEvent;
begin
  Result := Edit.OnSelChange;
end;

function TcxCustomInnerTextEditHelper.GetReadOnly: Boolean;
begin
  Result := Edit.ReadOnly;
end;

function TcxCustomInnerTextEditHelper.GetSelLength: Integer;
begin
  with Edit do
    if FImeCharCount > 0 then
      Result := Self.FSelLength
    else
      Result := SelLength;
end;

function TcxCustomInnerTextEditHelper.GetSelStart: Integer;
begin
  with Edit do
    if FImeCharCount > 0 then
      Result := Self.FSelStart
    else
      Result := SelStart;
end;

function TcxCustomInnerTextEditHelper.GetSelText: string;
begin
  Result := Edit.SelText;
end;

procedure TcxCustomInnerTextEditHelper.SelectAll;
begin
  with Edit do
    if HandleAllocated then
      SelectAll;
end;

procedure TcxCustomInnerTextEditHelper.SetAlignment(Value: TAlignment);
begin
  if FAlignmentLock then Exit;
  if GetUseLeftAlignmentOnEditing and GetIsInplace then
    Value := taLeftJustify;
  with Edit do
    if Value <> FAlignment then
    begin
      FAlignment := Value;
      FAlignmentLock := True;
      try
        RecreateWnd;
      finally
        FAlignmentLock := False;
      end;
    end;
end;

procedure TcxCustomInnerTextEditHelper.SetAutoSelect(Value: Boolean);
begin
  Edit.AutoSelect := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetCharCase(Value: TEditCharCase);
begin
  with Edit do
  begin
    CharCase := Value;
  end;
end;

procedure TcxCustomInnerTextEditHelper.SetEchoMode(Value: TcxEditEchoMode);
begin
  with Edit do
    if Value <> FEchoMode then
    begin
      FEchoMode := Value;
      UpdateEchoMode;
    end;
end;

procedure TcxCustomInnerTextEditHelper.SetHideSelection(Value: Boolean);
begin
  Edit.HideSelection := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetInternalUpdating(Value: Boolean);
begin
  Edit.FInternalUpdating := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetImeMode(Value: TImeMode);
begin
  Edit.ImeMode := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetImeName(const Value: TImeName);
begin
  Edit.ImeName := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetMaxLength(Value: Integer);
begin
  Edit.MaxLength := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetOEMConvert(Value: Boolean);
begin
  Edit.OEMConvert := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetOnSelChange(Value: TNotifyEvent);
begin
  Edit.OnSelChange := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetPasswordChar(Value: TCaptionChar);
begin
  with Edit do
    if Value <> FPasswordChar then
    begin
      FPasswordChar := Value;
      if FEchoMode = eemPassword then
        UpdateEchoMode;
    end;
end;

procedure TcxCustomInnerTextEditHelper.SetReadOnly(Value: Boolean);
begin
  Edit.ReadOnly := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetSelLength(Value: Integer);
begin
  with Edit do
    if HandleAllocated then
      if FImeCharCount > 0 then
        Self.FSelLength := Value
      else
        SelLength := Value;
end;

procedure TcxCustomInnerTextEditHelper.SetSelStart(Value: Integer);
begin
  with Edit do
  begin
    if not HandleAllocated then
      Exit;
    if FImeCharCount > 0 then
    begin
      Self.FSelStart := Value;
      Exit;
    end;
    SelStart := Value;
  end;
end;

procedure TcxCustomInnerTextEditHelper.SetSelText(Value: string);
begin
  Edit.SelText := Value;
end;

{$IFDEF DELPHI12}
function TcxCustomInnerTextEditHelper.GetTextHint: string;
begin
  Result := Edit.TextHint;
end;

procedure TcxCustomInnerTextEditHelper.SetTextHint(Value: string);
begin
  Edit.TextHint := Value;
end;
{$ENDIF}

function TcxCustomInnerTextEditHelper.GetUseLeftAlignmentOnEditing: Boolean;
begin
  Result := Edit.Container.ActiveProperties.UseLeftAlignmentOnEditing;
end;

{ TcxCustomInnerTextEdit }

constructor TcxCustomInnerTextEdit.Create(AOwner: TComponent);
begin
  FIsCreating := True;
  inherited Create(AOwner);
  InitializeDblClickTimer;
  FHelper := TcxCustomInnerTextEditHelper.Create(Self);
  ControlStyle := ControlStyle + [csDoubleClicks];
  ParentColor := True;
  ParentFont := False;
  FAlignment := cxEditDefaultHorzAlignment;
  FInternalUpdating := False;
  FEchoMode := eemNormal;
  UpdateEchoMode;
  FIsCreating := False;
end;

destructor TcxCustomInnerTextEdit.Destroy;
begin
  FreeAndNil(FHelper);
  FreeAndNil(FDblClickTimer);
  inherited Destroy;
end;

procedure TcxCustomInnerTextEdit.DragDrop(Source: TObject; X, Y: Integer);
begin
  Container.DragDrop(Source, Left + X, Top + Y);
end;

function TcxCustomInnerTextEdit.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.DataBinding.ExecuteAction(Action);
end;

function TcxCustomInnerTextEdit.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.DataBinding.UpdateAction(Action);
end;

function TcxCustomInnerTextEdit.CanFocus: Boolean;
begin
  Result := Container.CanFocus;
end;

procedure TcxCustomInnerTextEdit.DefaultHandler(var Message);
begin
  if not Container.InnerControlDefaultHandler(TMessage(Message)) then
    inherited DefaultHandler(Message);
end;

procedure TcxCustomInnerTextEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
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

procedure TcxCustomInnerTextEdit.AdjustAlignment;
begin
  if NeedAdjustAlignment then
  begin
    if Container.IsActiveControl then
    begin
      Helper.SetAlignment(taLeftJustify);
      Container.ShortRefreshContainer(False);
    end
    else
      SetBasedAlignment;
  end;
end;

// for Delphi .NET
procedure TcxCustomInnerTextEdit.Change;
begin
  inherited Change;
end;

procedure TcxCustomInnerTextEdit.Click;
begin
  inherited Click;
  Container.Click;
end;

procedure TcxCustomInnerTextEdit.CreateHandle;
begin
  Container.ClearSavedChildControlRegions;
  inherited CreateHandle;
end;

procedure TcxCustomInnerTextEdit.CreateParams(var Params: TCreateParams);
const
  AAlignmentMap: array[TAlignment] of DWORD = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or AAlignmentMap[Alignment];
    Style := Style and (not WS_BORDER);
    Style := Style and (not WS_DLGFRAME);
    Style := Style and (not WS_SIZEBOX);
    Style := Style and (not WS_THICKFRAME);
    Style := Style or ES_AUTOHSCROLL;
    ExStyle := ExStyle and (not WS_EX_CLIENTEDGE);
  end;
end;

procedure TcxCustomInnerTextEdit.CreateWindowHandle(const Params: TCreateParams);
var
  AParams: TCreateParams;
begin
  AParams := Params;
  AParams.Caption := '';
  inherited CreateWindowHandle(AParams);
  if HandleAllocated then
    CallWindowProc(DefWndProc, Handle, WM_SETTEXT, 0, Integer(WindowText));
end;

procedure TcxCustomInnerTextEdit.CreateWnd;
begin
  inherited CreateWnd;
  AdjustMargins;
end;

procedure TcxCustomInnerTextEdit.DblClick;
begin
  inherited DblClick;
  Container.DblClick;
end;

function TcxCustomInnerTextEdit.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
   MousePos: TPoint): Boolean;
begin
  Result := False;
end;

procedure TcxCustomInnerTextEdit.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Container.DragOver(Source, Left + X, Top + Y, State, Accept);
end;

function TcxCustomInnerTextEdit.GetBasedAlignment: TAlignment;
begin
  Result := Container.ActiveProperties.Alignment.Horz;
end;

procedure TcxCustomInnerTextEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FDblClickTimer.Enabled := False;
  FInternalUpdating := False;
  try
    Container.KeyDown(Key, Shift);
  finally
    if Key = 0 then
      FInternalUpdating := True;
  end;
  if Key <> 0 then
    inherited KeyDown(Key, Shift);
end;

procedure TcxCustomInnerTextEdit.KeyPress(var Key: Char);
var
  AKey: Word;
begin
  FInternalUpdating := False;
  try
    AKey := Word(Key);
    if (AKey = VK_TAB) then
      Key := #0;
    Container.KeyPress(Key);

    AKey := Word(Key);
    if (Container.IsInplace or Container.FIsPopupWindowJustClosed or
      (not Container.BeepOnEnter and (AKey = VK_RETURN))) and
      ((AKey = VK_RETURN) or (AKey = VK_ESCAPE)) then
    begin
      Key := #0;
      Container.FIsPopupWindowJustClosed := False;
    end;
  finally
    if Key = #0 then
      FInternalUpdating := True
  end;
  if Key <> #0 then
    inherited KeyPress(Key);
end;

procedure TcxCustomInnerTextEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FInternalUpdating := False;
  try
    if (Key = VK_TAB) then
      Key := 0;
    Container.KeyUp(Key, Shift);
  finally
    if Key = 0 then
      FInternalUpdating := True;
  end;
  if Key <> 0 then
    inherited KeyUp(Key, Shift);
end;

procedure TcxCustomInnerTextEdit.MouseDown(Button: TMouseButton;
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

procedure TcxCustomInnerTextEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Container.MouseMove(Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerTextEdit.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Container.MouseUp(Button, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerTextEdit.WndProc(var Message: TMessage);
begin
  if Container.InnerControlMenuHandler(Message) then
    Exit;
  case Message.Msg of
    WM_LBUTTONDOWN:
      if NeedAdjustAlignment and (FAlignment <> taLeftJustify) then
      begin
        ControlState := ControlState + [csLButtonDown];
        SetFocus;
        inherited WndProc(Message);
        FDblClickTimer.Enabled := True;
        FDblClickLock := True;
      end
      else
      begin
        if (Container.DragMode = dmAutomatic) and not Container.IsDesigning then
          Container.BeginAutoDrag
        else
        begin
          if FDblClickTimer.Enabled then
          begin
            Message.Msg := WM_LBUTTONDBLCLK;
            FDblClickTimer.Enabled := False;
            FDblClickTimer.Enabled := True;
          end;
          FDblClickLock := False;
          inherited WndProc(Message);
        end;
      end;
    WM_LBUTTONDBLCLK:
      begin
        if (Container.DragMode = dmAutomatic) and not Container.IsDesigning then
          Container.BeginAutoDrag
        else
        begin
          if not FDblClickTimer.Enabled then
            inherited WndProc(Message);
        end;
      end;
    WM_PAINT:
      begin
        if Container.OnGlass and IsCompositionEnabled then
        begin
          WMPaintWindowOnGlass(Handle);
          Message.Result := 0;
        end
        else
          inherited WndProc(Message);
      end;
    CN_CTLCOLOREDIT, CN_CTLCOLORSTATIC:
      begin
        inherited WndProc(Message);
        if not FRepaintOnGlass and Container.OnGlass and
          IsCompositionEnabled then
        begin
          FRepaintOnGlass := True;
          PostMessage(Handle, CM_BUFFEREDPAINTONGLASS, 0, 0);
        end;
      end;
    CM_BUFFEREDPAINTONGLASS:
      if FRepaintOnGlass then
      begin
        RepaintWindowOnGlass(Handle);
        FRepaintOnGlass := False;
      end;
  else
    inherited WndProc(Message);
  end;
end;

procedure TcxCustomInnerTextEdit.AdjustMargins;
begin
  SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN + EC_RIGHTMARGIN, 1 shl 16);
end;

procedure TcxCustomInnerTextEdit.MouseEnter(AControl: TControl);
begin
end;

procedure TcxCustomInnerTextEdit.MouseLeave(AControl: TControl);
begin
  Container.ShortRefreshContainer(True);
end;

// for Delphi .NET
procedure TcxCustomInnerTextEdit.RecreateWnd;
begin
  inherited RecreateWnd;
end;

// IcxContainerInnerControl
function TcxCustomInnerTextEdit.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxCustomInnerTextEdit.GetControlContainer: TcxContainer;
begin
  Result := Container;
end;

// IcxInnerEditHelper
function TcxCustomInnerTextEdit.GetHelper: IcxCustomInnerEdit;
begin
  Result := Helper;
end;

procedure TcxCustomInnerTextEdit.DblClickTimerHandle(Sender: TObject);
begin
  FDblClickTimer.Enabled := False;
end;

function TcxCustomInnerTextEdit.GetContainer: TcxCustomTextEdit;
begin
  Result := TcxCustomTextEdit(Owner);
end;

function TcxCustomInnerTextEdit.GetCursorPos: Integer;
var
  X: Integer;
  P: TPoint;
  I, I0, I1: Smallint;
  ATextLength: Integer;
begin
  ATextLength := Length(Text);
  GetCaretPos(P);
  I0 := 0;
  I1 := ATextLength - 1;
  repeat
    I := (I0 + I1) div 2;
    X := Smallint(SendMessage(Handle, EM_POSFROMCHAR, I, 0) and $FFFF);
    if X < P.X then
      I0 := I
    else
      I1 := I;
  until I1 - I0 < 2;
  if SendMessage(Handle, EM_POSFROMCHAR, I0, 0) and $FFFF = P.X then
    Result := I0
  else if SendMessage(Handle, EM_POSFROMCHAR, I1, 0) and $FFFF = P.X then
    Result := I1
  else
    Result := I1 + 1;
end;

function TcxCustomInnerTextEdit.GetIsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

procedure TcxCustomInnerTextEdit.InitializeDblClickTimer;
begin
  FreeAndNil(FDblClickTimer);
  FDblClickTimer := TcxTimer.Create(Self);
  with FDblClickTimer do
  begin
    Enabled := False;
    OnTimer := DblClickTimerHandle;
    Interval := GetDoubleClickTime;
  end;
end;

procedure TcxCustomInnerTextEdit.SetBasedAlignment;
begin
  Helper.SetAlignment(GetBasedAlignment);
  Container.ShortRefreshContainer(False);
end;

function TcxCustomInnerTextEdit.NeedAdjustAlignment: Boolean;
begin
  Result := Helper.UseLeftAlignmentOnEditing and (GetBasedAlignment <> taLeftJustify);
end;

procedure TcxCustomInnerTextEdit.UpdateEchoMode;
begin
  if FEchoMode = eemNormal then
    PasswordChar := #0
  else
    if FPasswordChar = #0 then
      PasswordChar := '*'
    else
      PasswordChar := FPasswordChar;
end;

procedure TcxCustomInnerTextEdit.WMChar(var Message: TWMChar);
var
  APrevState: TcxCustomInnerTextEditPrevState;
begin
  SaveTextEditState(Helper, True, APrevState);
  FInternalUpdating := False;
  inherited;
  if FImeCharCount > 0 then
  begin
    Dec(FImeCharCount);
    if (FImeCharCount = 0) and Container.FindSelection then
    begin
      SelStart := Helper.FSelStart;
      SelLength := Helper.FSelLength;
    end;
  end;
  Container.UnlockLookupDataTextChanged;
  if FInternalUpdating then
    Exit;
  if CheckTextEditState(Helper, APrevState) then
    Container.FindSelection := False;
end;

procedure TcxCustomInnerTextEdit.WMClear(var Message: TMessage);
begin
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

procedure TcxCustomInnerTextEdit.WMCut(var Message: TMessage);
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

procedure TcxCustomInnerTextEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TcxCustomInnerTextEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  with Message do
  begin
    Result := Result or DLGC_WANTCHARS;
    if Container.TabsNeeded and (GetKeyState(VK_CONTROL) >= 0) then
      Result := Result or DLGC_WANTTAB;
    if Container.IsInplace or Container.HasPopupWindow then
      Result := Result or DLGC_WANTALLKEYS;
  end;
end;

procedure TcxCustomInnerTextEdit.WMIMEChar(var Message: TMessage);
begin
  if (Message.WParam and $FF00) shr 8 <> 0 then
  begin
    FImeCharCount := 2;
    FImeLastChar := Char(Message.WParam and $FF);
  end
  else
    FImeCharCount := 1;

  Helper.FSelStart := SelStart;
  Helper.FSelLength := SelLength;
  inherited;
end;

procedure TcxCustomInnerTextEdit.WMIMEComposition(var Message: TMessage);
begin
  if Container.DoEditing then
    inherited;
end;

procedure TcxCustomInnerTextEdit.WMKeyDown(var Message: TWMKeyDown);
var
  AKey: Word;
  APrevState: TcxCustomInnerTextEditPrevState;
  AShiftState: TShiftState;
begin
  AShiftState := KeyDataToShiftState(Message.KeyData);
  if Container.HasPopupWindow and Container.ActiveProperties.IsPopupKey(Message.CharCode, AShiftState) then
    with Container.ILookupData do
      if ActiveControl is TWinControl then
      begin
        SendMessage(TWinControl(ActiveControl).Handle, WM_KEYDOWN, TMessage(Message).WParam, TMessage(Message).LParam);
        if Message.Result = 0 then
          Exit;
      end;

  SaveTextEditState(Helper, True, APrevState);
  FInternalUpdating := False;
  inherited;
  if (Message.CharCode = 0) or FInternalUpdating then
    Exit;
  if not CheckTextEditState(Helper, APrevState) then
  begin
    AKey := Message.CharCode;
    AShiftState := KeyDataToShiftState(Message.KeyData);
    Container.DoAfterKeyDown(AKey, AShiftState);
    Message.CharCode := AKey;
  end;
end;

procedure TcxCustomInnerTextEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not IsDestroying then
  begin
    FDblClickTimer.Enabled := False;
    SetBasedAlignment;
    Container.FocusChanged;
  end;
end;

procedure TcxCustomInnerTextEdit.WMNCPaint(var Message: TWMNCPaint);
begin
  Message.Result := 0;
  Exit;
end;

procedure TcxCustomInnerTextEdit.WMPaste(var Message: TMessage);
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

procedure TcxCustomInnerTextEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  if not IsDestroying then
    AdjustAlignment;
  inherited;
  if not IsDestroying then
  begin
    if Message.FocusedWnd <> Container.Handle then
      Container.FocusChanged;
  end;
end;

procedure TcxCustomInnerTextEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  AdjustMargins;
end;

procedure TcxCustomInnerTextEdit.WMUndo(var Message: TWMSize);
begin
  inherited;
  Container.UndoPerformed;
end;

procedure TcxCustomInnerTextEdit.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseEnter(Self)
  else
    MouseEnter(TControl(Message.lParam));
end;

procedure TcxCustomInnerTextEdit.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxCustomInnerTextEdit.EMSetSel(var Message: TMessage);
begin
  inherited;
  if Assigned(OnSelChange) then
    OnSelChange(Self);
end;

{ TcxTextEditPropertiesValues }

procedure TcxTextEditPropertiesValues.Assign(Source: TPersistent);
begin
  if Source is TcxTextEditPropertiesValues then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxTextEditPropertiesValues do
      begin
        Self.DisplayFormat := DisplayFormat;
        Self.EditFormat := EditFormat;
        Self.MaxLength := MaxLength;
      end;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxTextEditPropertiesValues.RestoreDefaults;
begin
  BeginUpdate;
  try
    inherited RestoreDefaults;
    DisplayFormat := False;
    EditFormat := False;
    MaxLength := False;
  finally
    EndUpdate;
  end;
end;

function TcxTextEditPropertiesValues.IsDisplayFormatStored: Boolean;
begin
  Result := DisplayFormat and
    (TcxCustomTextEditProperties(Properties).FDisplayFormat = '') and
    IsPropertiesPropertyVisible('DisplayFormat');
end;

function TcxTextEditPropertiesValues.IsEditFormatStored: Boolean;
begin
  Result := EditFormat and
    (TcxCustomTextEditProperties(Properties).FEditFormat = '') and
    IsPropertiesPropertyVisible('EditFormat');
end;

procedure TcxTextEditPropertiesValues.SetDisplayFormat(Value: Boolean);
begin
  if Value <> FDisplayFormat then
  begin
    FDisplayFormat := Value;
    Changed;
  end;
end;

procedure TcxTextEditPropertiesValues.SetEditFormat(Value: Boolean);
begin
  if Value <> FEditFormat then
  begin
    FEditFormat := Value;
    Changed;
  end;
end;

procedure TcxTextEditPropertiesValues.SetMaxLength(Value: Boolean);
begin
  if Value <> FMaxLength then
  begin
    FMaxLength := Value;
    TcxCustomTextEditProperties(Properties).MaxLengthChanged;
  end;
end;

{ TcxCustomEditListBox }

constructor TcxCustomEditListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHotTrack := True;
  BorderStyle := bsNone;
end;

function TcxCustomEditListBox.GetHeight(ARowCount: Integer; AMaxHeight: Integer): Integer;
begin
  Result := ARowCount * GetItemHeight;
end;

function TcxCustomEditListBox.GetItemHeight(AIndex: Integer = -1): Integer;
begin
  Result := GetDefaultItemHeight;
end;

function TcxCustomEditListBox.GetItemWidth(AIndex: Integer): Integer;
begin
  Canvas.Font.Assign(Font);
  Result := Canvas.TextWidth(GetItem(AIndex));
end;

function TcxCustomEditListBox.IsVisible: Boolean;
begin
  Result := HandleAllocated and IsWindowVisible(Handle);
end;

procedure TcxCustomEditListBox.SetScrollWidth(Value: Integer);
begin
  ScrollWidth := 0;
  ScrollWidth := Value;
end;

procedure TcxCustomEditListBox.Click;
begin
  inherited Click;
  DoSelectItem;
end;

function TcxCustomEditListBox.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
const
  AScrollDirectionMap: array [Boolean] of Integer = (SB_LINEDOWN, SB_LINEUP);
var
  I: Integer;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if Result then
    Exit;
  for I := 0 to Mouse.WheelScrollLines - 1 do
    Result := (SendMessage(Handle, WM_VScroll, AScrollDirectionMap[WheelDelta > 0], 0) = 0);
end;

procedure TcxCustomEditListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  AFlags: Longint;
  AText: string;
begin
  if DoDrawItem(Index, Rect, State) then
    Exit;
  Canvas.FillRect(Rect);
  if (Index >= 0) and (Index < Items.Count) then
  begin
    AFlags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    if not UseRightToLeftAlignment then
      Inc(Rect.Left, 2)
    else
      Dec(Rect.Right, 2);
    AText := GetItem(Index);
    DrawText(Canvas.Handle, PChar(AText), Length(AText), Rect, AFlags);
  end;
end;

function TcxCustomEditListBox.GetItemData(Index: Integer):
  Longint;
begin
  Result := 0;
end;

function TcxCustomEditListBox.NeedDrawFocusRect: Boolean;
begin
  Result := Edit.ActiveProperties.EditingStyle in [esFixedList, esNoEdit];
end;

procedure TcxCustomEditListBox.MeasureItem(Index: Integer; var Height: Integer);
begin
  Height := GetItemHeight;
end;

procedure TcxCustomEditListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  AItemIndex: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if (GetCaptureControl <> Self) and HotTrack then
  begin
    AItemIndex := ItemAtPos(Point(X, Y), False);
    if (AItemIndex <> -1) and (ItemIndex <> AItemIndex) then
      ItemIndex := AItemIndex;
  end;
end;

procedure TcxCustomEditListBox.SetItemData(Index: Integer;
  AData: Longint);
begin
end;

function TcxCustomEditListBox.DoDrawItem(AIndex: Integer; const ARect: TRect;
  AState: TOwnerDrawState): Boolean;
begin
  Result := False;
end;

procedure TcxCustomEditListBox.DoSelectItem;
begin
  SetExternalScrollBarsParameters;
  if Assigned(FOnSelectItem) then
    FOnSelectItem(Self);
end;

function TcxCustomEditListBox.GetDefaultItemHeight: Integer;
begin
  Canvas.Font := Font;
  Result := Canvas.TextHeight('Wg');
end;

function TcxCustomEditListBox.GetItem(Index: Integer): string;
begin
  Result := Items[Index];
end;

procedure TcxCustomEditListBox.InternalRecreateWindow;
begin
  RecreateWnd;
end;

procedure TcxCustomEditListBox.RecreateWindow;
begin
end;

procedure TcxCustomEditListBox.SetItemCount(Value: Integer);
var
  I: Integer;
begin
  with Items do
  begin
    if Value = Count then
      Exit;
    BeginUpdate;
    try
      if Value > Count then
        for I := 1 to Value - Count do
          Add('')
      else
        for I := 1 to Count - Value do
          Delete(Count - 1);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomEditListBox.SetItemIndex(const Value: Integer);
begin
{$IFDEF DELPHI6}
  inherited SetItemIndex(Value);
{$ELSE}
  inherited ItemIndex := Value;
{$ENDIF}
  DoSelectItem;
end;

procedure TcxCustomEditListBox.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

function TcxCustomEditListBox.GetEdit: TcxCustomTextEdit;
begin
  Result := TcxCustomTextEdit(TcxCustomPopupWindow(Owner).OwnerControl);
end;

{$IFNDEF DELPHI6}
function TcxCustomEditListBox.GetItemIndex: Integer;
begin
  Result := inherited ItemIndex;
end;
{$ENDIF}

{ TcxCustomTextEditLookupData }

constructor TcxCustomTextEditLookupData.Create(AOwner: TPersistent);
begin
  inherited Create(nil);
  FOwner:= AOwner;
  FCurrentKey := -1;
  FItemIndex := -1;
end;

function TcxCustomTextEditLookupData.CanResizeVisualArea(var NewSize: TSize;
  AMaxHeight: Integer = 0; AMaxWidth: Integer = 0): Boolean;
begin
  Result := True;
end;

procedure TcxCustomTextEditLookupData.CloseUp;
begin
  if not Edit.EditModeSetting then
    InternalSetItemIndex(FCurrentKey);
end;

procedure TcxCustomTextEditLookupData.Deinitialize;
begin
end;

procedure TcxCustomTextEditLookupData.DropDown;
begin
end;

procedure TcxCustomTextEditLookupData.DroppedDown(const AFindStr: string);
begin
end;

function TcxCustomTextEditLookupData.Find(const AText: string): Boolean;
begin
  Result := IndexOf(AText) <> -1;
end;

function TcxCustomTextEditLookupData.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxCustomTextEditLookupData.DoCurrentKeyChanged;
begin
  if Assigned(FOnCurrentKeyChanged) then
    FOnCurrentKeyChanged(Self);
end;

procedure TcxCustomTextEditLookupData.DoSelectItem;
begin
  if Assigned(FOnSelectItem) then
    FOnSelectItem(Self);
end;

function TcxCustomTextEditLookupData.GetItem(Index: Integer): string;
begin
  Result := ActiveProperties.FLookupItems[Index];
end;

function TcxCustomTextEditLookupData.GetItemCount: Integer;
begin
  Result := ActiveProperties.FLookupItems.Count;
end;

function TcxCustomTextEditLookupData.GetDisplayText(const AKey: TcxEditValue): string;
begin
  if (AKey < 0) or (AKey >= GetItemCount) then
    Result := ''
  else
    Result := GetItem(AKey);
end;

function TcxCustomTextEditLookupData.GetListBoxClass: TcxCustomEditListBoxClass;
begin
  Result := nil;
end;

procedure TcxCustomTextEditLookupData.HandleSelectItem(Sender: TObject);
begin
  FItemIndex := FList.ItemIndex;
end;

function TcxCustomTextEditLookupData.InternalLocate(var AText, ATail: string;
  ANext, ASynchronizeWithText: Boolean): Boolean;

  procedure CheckCurrentKey;
  var
    ACorrectCurrentKey: Boolean;
  begin
    case ActiveProperties.EditingStyle of
      esEditList:
        ACorrectCurrentKey := ASynchronizeWithText or (AText = '');
      esFixedList:
        ACorrectCurrentKey := ASynchronizeWithText;
      else
        ACorrectCurrentKey := True;
    end;
    if ACorrectCurrentKey then
      InternalSetCurrentKey(-1);
  end;

var
  AItem: string;
  AIStart, AItemIndex, I, L: Integer;
  S: string;
begin
  Result := False;
  if GetItemCount = 0 then
  begin
    CheckCurrentKey;
    Exit;
  end;

  if ASynchronizeWithText and ActiveProperties.MRUMode then
  begin
    AItemIndex := IndexOf(AText);
    if AItemIndex = -1 then
      InternalSetCurrentKey(-1)
    else
    begin
      Result := True;
      ATail := '';
      InternalSetCurrentKey(AItemIndex);
    end;
    Exit;
  end;

  if ANext then
    AIStart := ItemIndex
  else
    AIStart := -1;
  I := AIStart;
  L := Length(AText);
  repeat
    Inc(I);
    if (I = GetItemCount) or (I = AIStart) or (L = 0) then
      Break;

    AItem := GetItem(I);
    S := Copy(AItem, 1, L);

    if InternalCompareString(AText, S, False) then
    begin
      AText := S;
      ATail := Copy(AItem, L + 1, Length(AItem) - L);
      InternalSetCurrentKey(I);
      Result := True;
      Break;
    end;
  until Result;

  if not Result then
    CheckCurrentKey;
end;

function TcxCustomTextEditLookupData.GetVisualAreaPreferredSize(AMaxHeight: Integer;
  AWidth: Integer = 0): TSize;
begin
  Result := cxNullSize;
end;

procedure TcxCustomTextEditLookupData.Go(ADirection: TcxEditLookupDataGoDirection;
  ACircular: Boolean);
var
  ANewCurrentKey: Integer;
  AItemIndex: Integer;
begin
  if GetItemCount = 0 then
    Exit;
  ANewCurrentKey := 0;
  if ItemIndex = -1 then
    AItemIndex := CurrentKey
  else
    AItemIndex := ItemIndex;
  case ADirection of
    egdBegin:
      ANewCurrentKey := 0;
    egdEnd:
      ANewCurrentKey := GetItemCount - 1;
    egdPrev:
      begin
        ANewCurrentKey := AItemIndex - 1;
        if (ANewCurrentKey < 0) then
          if ACircular then
            ANewCurrentKey := GetItemCount - 1
          else
            ANewCurrentKey := AItemIndex;
      end;
    egdNext:
      begin
        ANewCurrentKey := AItemIndex + 1;
        if (ANewCurrentKey = GetItemCount) then
          if ACircular then
            ANewCurrentKey := 0
          else
            ANewCurrentKey := AItemIndex;
      end;
    egdPageUp:
      if AItemIndex = -1 then
        if ACircular then
          ANewCurrentKey := GetItemCount - 1
        else
          ANewCurrentKey := AItemIndex
      else
      begin
        ANewCurrentKey := AItemIndex - ActiveProperties.GetDropDownPageRowCount + 1;
        if (ANewCurrentKey < 0) then
          if ACircular then
            if AItemIndex = 0 then
              ANewCurrentKey := GetItemCount - 1
            else
              ANewCurrentKey := 0
          else
            ANewCurrentKey := 0;
      end;
    egdPageDown:
      begin
        if AItemIndex = -1 then
          ANewCurrentKey := AItemIndex + ActiveProperties.GetDropDownPageRowCount
        else
          ANewCurrentKey := AItemIndex + ActiveProperties.GetDropDownPageRowCount - 1;
        if (ANewCurrentKey >= GetItemCount) then
          if ACircular then
            if AItemIndex = GetItemCount - 1 then
              ANewCurrentKey := 0
            else
              ANewCurrentKey := GetItemCount - 1
          else
            ANewCurrentKey := GetItemCount - 1;
      end;
  end;
  if (FList = nil) or not FList.IsVisible or
    ActiveProperties.ImmediateUpdateText and Edit.DoEditing then
      CurrentKey := ANewCurrentKey
  else
    InternalSetItemIndex(ANewCurrentKey);
end;

procedure TcxCustomTextEditLookupData.Initialize(AVisualControlsParent: TWinControl);
begin
  if (FList = nil) and (GetListBoxClass <> nil) then
    FList := GetListBoxClass.Create(AVisualControlsParent);
  with FList do
  begin
    Color := Edit.ActiveStyle.Color;
    Font := Edit.ActiveStyle.GetVisibleFont;
    Canvas.Font := Font;
    Parent := AVisualControlsParent;
    OnSelectItem := HandleSelectItem;
    SetItemCount(GetItemCount);
    ItemIndex := FItemIndex;
    RecreateWindow;
  end;
  TextChanged;
end;

procedure TcxCustomTextEditLookupData.InternalSetCurrentKey(Value: Integer);
begin
  if (Value >= -1) and (Value < GetItemCount) then
  begin
    FCurrentKey := Value;
    InternalSetItemIndex(Value);
  end;
end;

function TcxCustomTextEditLookupData.IsEmpty: Boolean;
begin
  Result := GetItemCount = 0;
end;

function TcxCustomTextEditLookupData.IsMouseOverList(const P: TPoint): Boolean;
begin
  Result := PtInRect(FList.BoundsRect, FList.ScreenToClient(P));
end;

procedure TcxCustomTextEditLookupData.ListChanged;
begin
  if FList <> nil then
    FList.SetItemCount(GetItemCount);
end;

procedure TcxCustomTextEditLookupData.SetListItemIndex(Value: Integer);
begin
  FList.ItemIndex := Value;
end;

function TcxCustomTextEditLookupData.Locate(var AText, ATail: string;
  ANext: Boolean): Boolean;
begin
  Result := InternalLocate(AText, ATail, ANext, False);
end;

procedure TcxCustomTextEditLookupData.PositionVisualArea(const AClientRect: TRect);
begin
  with AClientRect do
  begin
    FList.SetBounds(Left, Top, Right - Left, Bottom - Top);
    if FList.HandleAllocated then
      FList.SetScrollWidth(FList.ScrollWidth);
  end;
end;

procedure TcxCustomTextEditLookupData.PropertiesChanged;
begin
  ListChanged;
end;

procedure TcxCustomTextEditLookupData.SelectItem;
var
  APrevCurrentKey: TcxEditValue;
begin
  if (FItemIndex = -1) or (CurrentKey <> FItemIndex) and not Edit.DoEditing then
    Exit;
  APrevCurrentKey := CurrentKey;
  CurrentKey := FItemIndex;
  if VarEqualsExact(APrevCurrentKey, CurrentKey) then
    DoSelectItem;
end;

function TcxCustomTextEditLookupData.GetActiveControl: TControl;
begin
  Result := FList;
end;

function TcxCustomTextEditLookupData.GetCurrentKey: TcxEditValue;
begin
  Result := FCurrentKey;
end;

function TcxCustomTextEditLookupData.GetOnCurrentKeyChanged: TNotifyEvent;
begin
  Result := FOnCurrentKeyChanged;
end;

function TcxCustomTextEditLookupData.GetOnSelectItem: TNotifyEvent;
begin
  Result := FOnSelectItem;
end;

function TcxCustomTextEditLookupData.GetEdit: TcxCustomTextEdit;
begin
  Result := TcxCustomTextEdit(FOwner);
end;

function TcxCustomTextEditLookupData.GetItems: TStrings;
begin
  Result := ActiveProperties.FLookupItems;
end;

function TcxCustomTextEditLookupData.GetActiveProperties: TcxCustomTextEditProperties;
begin
  Result := Edit.ActiveProperties;
end;

function TcxCustomTextEditLookupData.IndexOf(const AText: string): Integer;
var
  ACount, I: Integer;
begin
  Result := -1;
  ACount := GetItemCount;
  for I := 0 to ACount - 1 do
    if InternalCompareString(AText, GetItem(I), False) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxCustomTextEditLookupData.InternalSetItemIndex(Value: Integer);
begin
  if (Value < -1) or (Value >= GetItemCount) or (Value = FItemIndex) and (Value <> -1) then
    Exit;
  if (FList <> nil) and (GetItemCount > 0) then
  begin
    if Value = -1 then
      SetListItemIndex(0);
    SetListItemIndex(Value);
  end;
  FItemIndex := Value;
end;

procedure TcxCustomTextEditLookupData.SetCurrentKey(const AKey: TcxEditValue);
var
  APrevCurrentKey: TcxEditValue;
begin
  APrevCurrentKey := FCurrentKey;
  InternalSetCurrentKey(AKey);
  if Edit <> nil then
    Edit.LockLookupDataTextChanged;
  try
    if not VarEqualsExact(APrevCurrentKey, FCurrentKey) or ((AKey >= 0) and (AKey < GetItemCount) and not InternalCompareString(Edit.Text, GetItem(AKey), True)) then
      DoSelectItem;
  finally
    if Edit <> nil then
      Edit.UnlockLookupDataTextChanged;
  end;
end;

procedure TcxCustomTextEditLookupData.SetItemIndex(Value: Integer);
begin
  if (FList = nil) or not FList.IsVisible or ActiveProperties.ImmediateUpdateText then
    CurrentKey := Value
  else
    InternalSetItemIndex(Value);
end;

procedure TcxCustomTextEditLookupData.SetItems(Value: TStrings);
begin
  ActiveProperties.FLookupItems.Assign(Value);
end;

procedure TcxCustomTextEditLookupData.SetOnCurrentKeyChanged(Value: TNotifyEvent);
begin
  FOnCurrentKeyChanged := Value;
end;

procedure TcxCustomTextEditLookupData.SetOnSelectItem(Value: TNotifyEvent);
begin
  FOnSelectItem := Value;
end;

procedure TcxCustomTextEditLookupData.TextChanged;
var
  AText, ATail: string;
begin
  if Edit.EditModeSetting then
    Exit;
  AText := Edit.Text;
  if (ItemIndex >= GetItemCount) or
    not InternalCompareString(GetDisplayText(ItemIndex), AText, False) then
      InternalLocate(AText, ATail, False, True);
end;

{ TcxCustomTextEditViewData }

procedure TcxCustomTextEditViewData.Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  with AViewInfo as TcxCustomTextEditViewInfo do
  begin
    DrawSelectionBar := False;
    EditingStyle := Properties.EditingStyle;
    IsEditClass := GetIsEditClass;
    if Edit <> nil then
      TcxCustomTextEditViewInfo(AViewInfo).HasPopupWindow := Edit.HasPopupWindow
    else
      TcxCustomTextEditViewInfo(AViewInfo).HasPopupWindow := False;
    CalculateTextEditViewInfo(ACanvas, Self, TcxCustomTextEditViewInfo(AViewInfo), AIsMouseEvent);
    MaxLineCount := Self.GetMaxLineCount;
    TextOutData.Initialized := False;
  end;
  PrepareDrawTextFlags(ACanvas, AViewInfo);
end;

procedure TcxCustomTextEditViewData.DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
  AViewInfo: TcxCustomEditViewInfo);
begin
  with TcxCustomTextEditViewInfo(AViewInfo) do
  begin
    Text := ADisplayValue;
    Properties.DisplayValueToDisplayText(Text);
  end;
end;

procedure TcxCustomTextEditViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
  if PreviewMode then
    TcxCustomTextEditViewInfo(AViewInfo).Text := ''
  else
    TcxCustomTextEditViewInfo(AViewInfo).Text :=
      string(EditValueToDisplayText(AEditValue));
  PrepareSelection(AViewInfo);
end;

function TcxCustomTextEditViewData.GetClientExtent(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo): TRect;
begin
  Result := inherited GetClientExtent(ACanvas, AViewInfo);
  if not IsInplace and IsComboBoxStyle and
      AreVisualStylesMustBeUsed(Style.LookAndFeel.NativeStyle, totEdit) then
    Inc(Result.Right);
end;

function TcxCustomTextEditViewData.GetDrawTextFlags: DWORD;
const
  AHorzAlignmentFlags: array [TcxEditHorzAlignment] of DWORD = (
    CXTO_LEFT, CXTO_RIGHT, CXTO_CENTER_HORIZONTALLY
  );
  AVertAlignmentFlags: array [TcxEditVertAlignment] of DWORD = (
    CXTO_TOP, CXTO_BOTTOM, CXTO_CENTER_VERTICALLY
  );
begin
  Result := AHorzAlignmentFlags[HorzAlignment];
  Result := Result or AVertAlignmentFlags[VertAlignment];
  Result := Result or CXTO_SINGLELINE;
  Result := Result or CXTO_PREVENT_LEFT_EXCEED or CXTO_PREVENT_TOP_EXCEED;
end;

function TcxCustomTextEditViewData.GetDrawTextOffset: TRect;
begin
  Result := GetTextEditDrawTextOffset(Self);
end;

procedure TcxCustomTextEditViewData.PrepareSelection(AViewInfo: TcxCustomEditViewInfo);
var
  ACustomTextEditViewInfo: TcxCustomTextEditViewInfo;
begin
  ACustomTextEditViewInfo := TcxCustomTextEditViewInfo(AViewInfo);
  ACustomTextEditViewInfo.SelStart := SelStart;
  ACustomTextEditViewInfo.SelLength := SelLength;
  if SelLength = 0 then
    Exit;
  if SelBackgroundColor = clDefault then
  begin
    if SelTextColor = clDefault then
    begin
      if Style.Color = clHighlight then
      begin
        ACustomTextEditViewInfo.SelBackgroundColor := clBlack;
        ACustomTextEditViewInfo.SelTextColor := clWhite;
      end
      else
      begin
        ACustomTextEditViewInfo.SelBackgroundColor := clHighlight;
        ACustomTextEditViewInfo.SelTextColor := clHighlightText;
      end;
    end
    else
    begin
      ACustomTextEditViewInfo.SelTextColor := SelTextColor;
      ACustomTextEditViewInfo.SelBackgroundColor := InvertColor(SelTextColor);
    end;
  end
  else
  begin
    ACustomTextEditViewInfo.SelBackgroundColor := SelBackgroundColor;
    if SelTextColor = clDefault then
      ACustomTextEditViewInfo.SelTextColor := InvertColor(SelBackgroundColor)
    else
      ACustomTextEditViewInfo.SelTextColor := SelTextColor;
  end;
end;

procedure TcxCustomTextEditViewData.CalculateButtonNativeInfo(AButtonViewInfo: TcxEditButtonViewInfo);
begin
  inherited CalculateButtonNativeInfo(AButtonViewInfo);
  if NativeStyle and IsCompositionEnabled and not IsInplace and
    (Properties.EditingStyle = esFixedList) and
    AButtonViewInfo.Data.ComboBoxStyle and
    (AButtonViewInfo.Data.NativeState <> CBXS_DISABLED) then
    AButtonViewInfo.Data.NativeState := CBXS_NORMAL;
end;

function TcxCustomTextEditViewData.GetIsEditClass: Boolean;
begin
  Result := (Edit <> nil) and Edit.IsEditClass;
end;

function TcxCustomTextEditViewData.GetMaxLineCount: Integer;
begin
  Result := MaxLineCount;
end;

procedure TcxCustomTextEditViewData.InitCacheData;
begin
  inherited InitCacheData;
  FIsValueEditorWithValueFormatting := Properties.IsValueEditorWithValueFormatting;
end;

function TcxCustomTextEditViewData.InternalEditValueToDisplayText(
  AEditValue: TcxEditValue): string;
begin
  Result := '';
  try
    if FIsValueEditorWithValueFormatting then
      Result := VarToStr(AEditValue)
    else
      Result := Properties.GetDefaultDisplayValue(AEditValue, InternalFocused);
  finally
    Properties.DisplayValueToDisplayText(string(Result));
  end;
end;

function TcxCustomTextEditViewData.InternalGetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; const AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  AContentSize: TSize;
begin
  AContentSize := inherited InternalGetEditContentSize(ACanvas, AEditValue,
    AEditSizeProperties);
  Result := GetTextEditContentSize(ACanvas, Self,
    EditValueToDisplayText(AEditValue), GetDrawTextFlags, AEditSizeProperties);
  CheckSize(Result, AContentSize);
end;

function TcxCustomTextEditViewData.IsComboBoxStyle: Boolean;
begin
  Result := False;
end;

procedure TcxCustomTextEditViewData.PrepareDrawTextFlags(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo);
begin
  with TcxCustomTextEditViewInfo(AViewInfo) do
  begin
    if not Properties.IsMultiLine and (esoAutoHeight in Properties.GetSupportedOperations) and
        (epoAutoHeight in Self.PaintOptions) then
      PrepareTextEditDrawTextFlags(ACanvas, Self, TcxCustomTextEditViewInfo(AViewInfo))
    else
      DrawTextFlags := GetDrawTextFlags;
    if epoShowEndEllipsis in PaintOptions then
      DrawTextFlags := DrawTextFlags or CXTO_END_ELLIPSIS;
    ComboBoxStyle := IsComboBoxStyle;
  end;
end;

function TcxCustomTextEditViewData.GetProperties: TcxCustomTextEditProperties;
begin
  Result := TcxCustomTextEditProperties(FProperties);
end;

function TcxCustomTextEditViewData.InvertColor(AColor: TColor): TColor;
begin
  Result := ColorToRGB(AColor) xor $FFFFFF;
end;

{ TcxCustomTextEditViewInfo }

destructor TcxCustomTextEditViewInfo.Destroy;
begin
  cxResetTextRows(TextOutData.TextRows);
  inherited Destroy;
end;

function TcxCustomTextEditViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; const AVisibleBounds: TRect; out AText: TCaption;
  out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean;

  function GetRealVisibleBounds: TRect;
  begin
    Result := AVisibleBounds;
    if EqualRect(Result, cxEmptyRect) then
      Result := TextRect
    else
    begin
      OffsetRect(Result, -Left, -Top);
      IntersectRect(Result, TextRect, Result);
    end;
  end;

  function IsMultiLine(ATextFlags: DWORD): Boolean;
  begin
    Result := (ATextFlags and CXTO_SINGLELINE = 0) and (ATextFlags and CXTO_WORDBREAK <> 0);
  end;

  function GetCalcTextFlags: Integer;
  begin
    Result := DrawTextFlags and not (CXTO_CENTER_VERTICALLY or CXTO_BOTTOM or CXTO_SINGLELINE) or
      CXTO_CALCRECT;
  end;

  function IsTextNotFullyVisible(const ARealVisibleBounds: TRect): Boolean;
  var
    R: TRect;
  begin
    ACanvas.Font := Font;
    R := ARealVisibleBounds;
    cxTextOut(ACanvas.Canvas, Text, R, GetCalcTextFlags);
    Result := (R.Bottom > ARealVisibleBounds.Bottom) or (R.Right > ARealVisibleBounds.Right);
  end;

var
  ARealVisibleBounds: TRect;
begin
  ARealVisibleBounds := GetRealVisibleBounds;
  Result := PtInRect(ARealVisibleBounds, Point(P.X - Left, P.Y - Top)) and
    IsTextNotFullyVisible(ARealVisibleBounds);
  if Result then
  begin
    AIsMultiLine := IsMultiLine(DrawTextFlags);
    AText := Text;
    ATextRect := TextRect;
    OffsetRect(ATextRect, Left, Top);
  end
  else
    Result := inherited NeedShowHint(ACanvas, P, AVisibleBounds, AText, AIsMultiLine, ATextRect);
end;

procedure TcxCustomTextEditViewInfo.Offset(DX, DY: Integer);
var
  I: Integer;
begin
  inherited Offset(DX, DY);
  OffsetRect(TextRect, DX, DY);
  with TextOutData do
    if Initialized then
    begin
      OffsetRect(TextRect, DX, DY);
      for I := 0 to cxGetTextRowCount(TextRows) - 1 do
        with cxGetTextRow(TextRows, I)^ do
        begin
          TextOriginX := TextOriginX + DX;
          TextOriginY := TextOriginY + DY;
        end;
    end;
end;

procedure TcxCustomTextEditViewInfo.DrawText(ACanvas: TcxCanvas);
begin
  DrawEditText(ACanvas, Self);
end;

{$IFDEF DELPHI10}
function TcxCustomTextEditViewInfo.GetTextBaseLine: Integer;
var
  ACanvas: TcxScreenCanvas;
  ATextMetric: TTextMetric;
begin
  ACanvas := TcxScreenCanvas.Create;
  try
    ACanvas.Font := Font;
    GetTextMetrics(ACanvas.Handle, ATextMetric);
    case EditProperties.Alignment.Vert of
      taTopJustify:
        Result := TextRect.Top + ATextMetric.tmAscent + 1;
      taBottomJustify:
        Result := TextRect.Bottom - ATextMetric.tmDescent + 1;
    else
      Result := TextRect.Top + (TextRect.Bottom - TextRect.Top - ATextMetric.tmHeight) div 2 + ATextMetric.tmAscent + 1;
    end;
  finally
    ACanvas.Free;
  end;
end;
{$ENDIF}

procedure TcxCustomTextEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  DrawTextEdit(ACanvas, Self);
end;

{ TcxCustomTextEditProperties }

constructor TcxCustomTextEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FCharCase := ecNormal;
  FEchoMode := eemNormal;
  FFixedListSelection := True;
  FHideSelection := True;
  FImeMode := imDontCare;
  FIncrementalSearch := True;
  FLookupItems := TStringList.Create;
  FLookupItems.Duplicates := dupAccept;
  FLookupItems.OnChange := LookupItemsChanged;
  cxFormatController.AddListener(Self);
end;

destructor TcxCustomTextEditProperties.Destroy;
begin
  cxFormatController.RemoveListener(Self);
  FreeAndNil(FLookupItems);
  inherited Destroy;
end;

procedure TcxCustomTextEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomTextEditProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomTextEditProperties do
      begin
        Self.CharCase := CharCase;
        Self.EchoMode := EchoMode;
        Self.FixedListSelection := FixedListSelection;
        Self.HideCursor := HideCursor;
        Self.HideSelection := HideSelection;
        Self.ImmediateUpdateText := ImmediateUpdateText;
        Self.IncrementalSearch := IncrementalSearch;
        Self.MRUMode := MRUMode;
        Self.ValidChars := ValidChars;

        Self.LookupItemsSorted := False;
        Self.LookupItems.Assign(LookupItems);
        Self.LookupItemsSorted := LookupItemsSorted;

        Self.AssignedValues.DisplayFormat := False;
        if AssignedValues.DisplayFormat then
          Self.DisplayFormat := DisplayFormat;

        Self.AssignedValues.EditFormat := False;
        if AssignedValues.EditFormat then
          Self.EditFormat := EditFormat;

        Self.AssignedValues.MaxLength := False;
        if AssignedValues.MaxLength then
          Self.MaxLength := MaxLength;

        Self.OEMConvert := OEMConvert;
        Self.ImeMode := ImeMode;
        Self.ImeName := ImeName;
        Self.PasswordChar := PasswordChar;
        Self.UseDisplayFormatWhenEditing := UseDisplayFormatWhenEditing;
        Self.OnNewLookupDisplayText := OnNewLookupDisplayText;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomTextEditProperties.CanCompareEditValue: Boolean;
begin
  Result := True;
end;

function TcxCustomTextEditProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
var
  AText1, AText2: string;
begin
  AText1 := GetDisplayText(AEditValue1, True);
  AText2 := GetDisplayText(AEditValue2, True);
  Result := InternalCompareString(AText1, AText2, True);
end;

class function TcxCustomTextEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxTextEdit;
end;

function TcxCustomTextEditProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
var
  AText: string;
begin
  AText := '';
  try
    if IsValueEditorWithValueFormatting then
      AText := VarToStr(AEditValue)
    else
      AText := GetDefaultDisplayValue(AEditValue,
        not AIsInplace and not IsEditValueConversionDependOnFocused);
  finally
    DisplayValueToDisplayText(AText);
    Result := AText;
  end;
end;

function TcxCustomTextEditProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := inherited GetSupportedOperations + [esoAutoHeight, esoEditing,
    esoFiltering, esoHorzAlignment, esoIncSearch, esoSorting];
end;

class function TcxCustomTextEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomTextEditViewInfo;
end;

function TcxCustomTextEditProperties.IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := VarIsNull(EditValue) or not VarIsStr(EditValue) or
    IsDisplayValueValid(EditValue, AEditFocused);
end;

procedure TcxCustomTextEditProperties.PrepareDisplayValue(const AEditValue: TcxEditValue;
  var DisplayValue: TcxEditValue; AEditFocused: Boolean);

  procedure InternalPrepareDisplayValue(AValue: Variant);

  var
    AEditFormat: string;
    AIsCurrency, AIsOnGetTextAssigned: Boolean;
    S: string;
{$IFDEF DELPHI6}
    APrecision: Integer;
    V: TBcd;
{$ENDIF}
  begin
    if AEditFocused then
    begin
      AEditFormat := InternalGetEditFormat(AIsCurrency, AIsOnGetTextAssigned);

{$IFDEF DELPHI6}
      if IDefaultValuesProvider = nil then
        APrecision := cxEditDefaultPrecision
      else
        APrecision := IDefaultValuesProvider.DefaultPrecision;
{$ENDIF}

      if AIsCurrency then
{$IFDEF DELPHI6}
      begin
        DisplayValue := VarToStr(AValue);
        if TryStrToBcd(DisplayValue, V) then
          DisplayValue := BcdToStrF(V, ffFixed, APrecision, CurrencyDecimals);
      end
{$ELSE}
        DisplayValue := FloatToStrF(AValue, ffFixed, cxEditDefaultPrecision, CurrencyDecimals)
{$ENDIF}
      else
        if AEditFormat = '' then
        begin
{$IFDEF DELPHI6}
          S := VarToStr(AValue);
          if TryStrToBcd(S, V) then
            S := BcdToStrF(V, ffGeneral, APrecision, 0);
{$ELSE}
          S := FloatToStrF(AValue, ffGeneral, cxEditDefaultPrecision, 0);
{$ENDIF}
          if HasDigitGrouping(False) then
            InsertThousandSeparator(S);
          DisplayValue := S;
        end
        else
          DisplayValue := FormatFloat(AEditFormat, AValue);
    end
    else
      if DisplayFormat <> '' then
        DisplayValue := FormatFloat(DisplayFormat, AValue)
      else
        DisplayValue := VarToStr(AValue);
  end;

begin
  if IsEditValueNumeric then
  begin
    if VarIsSoftNull(AEditValue) then
      DisplayValue := ''
    else
      if not VarIsNumericEx(AEditValue) and not VarIsStr(AEditValue) then
        raise EConvertError.CreateFmt(cxGetResourceString(@cxSEditNumericValueConvertError), [])
      else
        InternalPrepareDisplayValue(AEditValue);
  end
  else
    if VarIsArray(AEditValue) then
      DisplayValue := ''
    else
      DisplayValue := VarToStr(AEditValue);
end;

procedure TcxCustomTextEditProperties.ValidateDisplayValue(var DisplayValue: TcxEditValue;
  var ErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit);
begin
  if IsEditValueNumeric and IsValueBoundsDefined then
    CheckEditorValueBounds(DisplayValue, ErrorText, Error, AEdit);
  inherited ValidateDisplayValue(DisplayValue, ErrorText, Error, AEdit);
end;

procedure TcxCustomTextEditProperties.DisplayValueToDisplayText(
  var ADisplayValue: string);

  function GetPasswordChar: TCaptionChar;
  begin
    if PasswordChar = #0 then
      Result := '*'
    else
      Result := PasswordChar;
  end;

begin
  if EchoMode <> eemNormal then
      ADisplayValue := StringOfChar(GetPasswordChar, Length(ADisplayValue))
  else
    if CharCase <> ecNormal then
      CheckCharsRegister(ADisplayValue, CharCase);
end;

function TcxCustomTextEditProperties.IsDisplayValueValid(var DisplayValue: TcxEditValue; AEditFocused: Boolean): Boolean;
var
  AText: string;
begin
  AText := VarToStr(DisplayValue);
  Result := not((AText <> '') and (EditingStyle in [esEditList, esFixedList]) and
    UseLookupData and not FindLookupText(AText));
  if Result then
  begin
    CheckCharsRegister(AText, CharCase);
    DisplayValue := AText;
  end;
end;

procedure TcxCustomTextEditProperties.SetMinMaxValues(AMinValue, AMaxValue: Double);
begin
  FillMinMaxValues(AMinValue, AMaxValue);
end;

procedure TcxCustomTextEditProperties.AlignmentChangedHandler(Sender: TObject);
begin
  BeginUpdate;
  try
    inherited AlignmentChangedHandler(Sender);
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomTextEditProperties.BaseSetAlignment(Value: TcxEditAlignment);
begin
  BeginUpdate;
  try
    inherited BaseSetAlignment(Value);
  finally
    EndUpdate;
  end;
end;

function TcxCustomTextEditProperties.CanValidate: Boolean;
begin
  Result := True;
end;

// obsolete
procedure TcxCustomTextEditProperties.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('IsDisplayFormatAssigned', ReadIsDisplayFormatAssigned,
    nil, False);
end;

class function TcxCustomTextEditProperties.GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass;
begin
  Result := TcxTextEditPropertiesValues;
end;

function TcxCustomTextEditProperties.GetDisplayFormatOptions: TcxEditDisplayFormatOptions;
begin
  Result := [dfoSupports];
end;

function TcxCustomTextEditProperties.GetValidateErrorText(AErrorKind: TcxEditErrorKind): string;
begin
  if AErrorKind = ekValueOutOfBounds then
    Result := cxGetResourceString(@cxSEditValueOutOfBounds)
  else
    Result := inherited GetValidateErrorText(AErrorKind);
end;

class function TcxCustomTextEditProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomTextEditViewData;
end;

function TcxCustomTextEditProperties.GetEditingStyle: TcxEditEditingStyle;
begin
  if FHideCursor then
    Result := esNoEdit
  else
    Result := esEdit;
end;

class function TcxCustomTextEditProperties.GetLookupDataClass: TcxInterfacedPersistentClass;
begin
  Result := TcxCustomTextEditLookupData;
end;

function TcxCustomTextEditProperties.HasDigitGrouping(
  AIsDisplayValueSynchronizing: Boolean): Boolean;
begin
  Result := False;
end;

function TcxCustomTextEditProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsText;
end;

function TcxCustomTextEditProperties.HasDisplayValue: Boolean;
begin
  Result := True;
end;

procedure TcxCustomTextEditProperties.FormatChanged;
begin
  FFormatChanging := True;
  try
    Changed;
  finally
    FFormatChanging := False;
  end;
end;

function TcxCustomTextEditProperties.IsResetEditClass: Boolean;
begin
  Result := EditingStyle <> esNoEdit;
end;

function TcxCustomTextEditProperties.CanIncrementalSearch: Boolean;
begin
  Result := (EditingStyle = esEdit) and IncrementalSearch or
    (EditingStyle in [esEditList, esFixedList])
end;

procedure TcxCustomTextEditProperties.CheckEditorValueBounds(var DisplayValue: TcxEditValue;
  var ErrorText: TCaption; var Error: Boolean; AEdit: TcxCustomEdit);
var
  AEditValue: TcxEditValue;
begin
  AEdit.PrepareEditValue(DisplayValue, AEditValue, AEdit.InternalFocused);
  if (VarIsNumericEx(AEditValue) or VarIsDate(AEditValue)) and
    (IsValueBoundDefined(evbMin) and (AEditValue < MinValue) or
    IsValueBoundDefined(evbMax) and (AEditValue > MaxValue)) then
  begin
    Error := True;
    ErrorText := GetValidateErrorText(ekValueOutOfBounds);
  end;
end;

function TcxCustomTextEditProperties.DefaultFocusedDisplayValue: TcxEditValue;
begin
  Result := '';
end;

function TcxCustomTextEditProperties.FindLookupText(const AText: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FLookupItems.Count - 1 do
    if InternalCompareString(AText, FLookupItems[I], False) then
    begin
      Result := True;
      Break;
    end;
end;

function TcxCustomTextEditProperties.GetDefaultDisplayFormat: string;
begin
  Result := '';
end;

function TcxCustomTextEditProperties.GetDefaultDisplayValue(const AEditValue: TcxEditValue;
  AEditFocused: Boolean): TcxEditValue;
var
  AValue: TcxEditValue;
begin
  AValue := AEditValue;
  if IsEditValueValid(AValue, AEditFocused) then
    PrepareDisplayValue(AValue, Result, AEditFocused)
  else
    if VarIsDate(AEditValue) then
      Result := DateTimeToStr(AEditValue)
    else
      Result := VarToStr(AEditValue)
end;

function TcxCustomTextEditProperties.GetDefaultMaxLength: Integer;
begin
  if IDefaultValuesProvider = nil then
    Result := 0
  else
    Result := IDefaultValuesProvider.DefaultMaxLength;
end;

function TcxCustomTextEditProperties.GetDropDownPageRowCount: Integer;
begin
  Result := cxEditDefaultDropDownPageRowCount;
end;

function TcxCustomTextEditProperties.InternalGetEditFormat(
  out AIsCurrency, AIsOnGetTextAssigned: Boolean;
  AEdit: TcxCustomTextEdit = nil): string;
begin
  AIsCurrency := False;
  AIsOnGetTextAssigned := False;
  Result := '';
  if AssignedValues.EditFormat then
    Result := FEditFormat
  else
  begin
    if not ((AEdit <> nil) and AEdit.IsInplace) and (IDefaultValuesProvider <> nil) and
      IDefaultValuesProvider.IsOnGetTextAssigned then
    begin
      AIsOnGetTextAssigned := True;
      Exit;
    end;
    if (IDefaultValuesProvider <> nil) and
        (IDefaultValuesProvider.DefaultEditFormat <> '') then
      Result := IDefaultValuesProvider.DefaultEditFormat
    else 
    begin
      if AssignedValues.DisplayFormat then
        Result := DisplayFormat
      else
        if (IDefaultValuesProvider <> nil) and (IDefaultValuesProvider.DefaultDisplayFormat <> '') then
          Result := IDefaultValuesProvider.DefaultDisplayFormat
        else
          if GetDefaultDisplayFormat <> '' then
            Result := GetDefaultDisplayFormat
          else
            if IDefaultValuesProvider <> nil then
              AIsCurrency := not(dfoNoCurrencyValue in DisplayFormatOptions) and
                IDefaultValuesProvider.IsCurrency;
      if not UseDisplayFormatWhenEditing then
        Result := '';
    end;
  end;
end;

function TcxCustomTextEditProperties.IsEditValueNumeric: Boolean;
begin
  Result := False;
end;

function TcxCustomTextEditProperties.IsLookupDataVisual: Boolean;
begin
  Result := False;
end;

function TcxCustomTextEditProperties.IsMultiLine: Boolean;
begin
  Result := False;
end;

function TcxCustomTextEditProperties.IsPopupKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
end;

function TcxCustomTextEditProperties.IsValueBoundDefined(
  ABound: TcxEditValueBound): Boolean;
begin
  if Integer(AssignedValues.MinValue) + Integer(AssignedValues.MaxValue) = 1 then
    Result := (ABound = evbMin) and AssignedValues.MinValue or
      (ABound = evbMax) and AssignedValues.MaxValue
  else
    Result := MinValue < MaxValue;
end;

function TcxCustomTextEditProperties.IsValueBoundsDefined: Boolean;
begin
  Result := IsValueBoundDefined(evbMin) or IsValueBoundDefined(evbMax);
end;

procedure TcxCustomTextEditProperties.LookupDataChanged(Sender: TObject);
begin
  Changed;
end;

procedure TcxCustomTextEditProperties.MaxLengthChanged;
begin
  Changed;
end;

procedure TcxCustomTextEditProperties.SetCharCase(Value: TEditCharCase);
begin
  if Value <> FCharCase then
  begin
    FCharCase := Value;
    Changed;
  end;
end;

function TcxCustomTextEditProperties.UseLookupData: Boolean;
begin
  Result := GetLookupDataClass <> nil;
end;

function TcxCustomTextEditProperties.GetAssignedValues: TcxTextEditPropertiesValues;
begin
  Result := TcxTextEditPropertiesValues(FAssignedValues);
end;

function TcxCustomTextEditProperties.GetDisplayFormat: string;
begin
  if AssignedValues.DisplayFormat then
    Result := FDisplayFormat
  else
    if (IDefaultValuesProvider = nil) or
        (IDefaultValuesProvider.DefaultDisplayFormat = '') then
      Result := GetDefaultDisplayFormat
    else
      Result := IDefaultValuesProvider.DefaultDisplayFormat;
end;

function TcxCustomTextEditProperties.GetEditFormat: string;
var
  A: Boolean;
begin
  Result := InternalGetEditFormat(A, A);
end;

function TcxCustomTextEditProperties.GetInnerEditMaxLength: Integer;
begin
  Result := GetMaxLength;
end;

function TcxCustomTextEditProperties.GetLookupItems: TStrings;
begin
  Result := FLookupItems;
end;

function TcxCustomTextEditProperties.GetLookupItemsSorted: Boolean;
begin
  Result := FLookupItems.Sorted;
end;

function TcxCustomTextEditProperties.GetMaxLength: Integer;
begin
  if AssignedValues.MaxLength then
    Result := FMaxLength
  else
    Result := GetDefaultMaxLength;
end;

function TcxCustomTextEditProperties.GetViewStyle: TcxTextEditViewStyle;
const
  AViewStyleMap: array[TcxEditButtonsViewStyle] of TcxTextEditViewStyle =
    (vsNormal, vsButtonsOnly, vsButtonsAutoWidth);
begin
  if ButtonsViewStyle <> bvsNormal then
    Result := AViewStyleMap[ButtonsViewStyle]
  else
    if HideCursor then
      Result := vsHideCursor
    else
      Result := vsNormal;
end;

function TcxCustomTextEditProperties.IsDisplayFormatStored: Boolean;
begin
  Result := AssignedValues.DisplayFormat;
end;

function TcxCustomTextEditProperties.IsEditFormatStored: Boolean;
begin
  Result := AssignedValues.EditFormat;
end;

function TcxCustomTextEditProperties.IsMaxLengthStored: Boolean;
begin
  Result := AssignedValues.MaxLength;
end;

procedure TcxCustomTextEditProperties.LookupItemsChanged(Sender: TObject);
begin
  Changed;
end;

procedure TcxCustomTextEditProperties.ReadIsDisplayFormatAssigned(Reader: TReader);
begin
  AssignedValues.DisplayFormat := Reader.ReadBoolean;
end;

procedure TcxCustomTextEditProperties.SetDisplayFormat(const Value: string);
begin
  if AssignedValues.DisplayFormat and (Value = FDisplayFormat) then
    Exit;

  AssignedValues.FDisplayFormat := True;
  FDisplayFormat := Value;
  Changed;
end;

// obsolete
procedure TcxCustomTextEditProperties.SetAssignedValues(
  Value: TcxTextEditPropertiesValues);
begin
  FAssignedValues.Assign(Value);
end;

procedure TcxCustomTextEditProperties.SetEchoMode(Value: TcxEditEchoMode);
begin
  if Value <> FEchoMode then
  begin
    FEchoMode := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetEditFormat(const Value: string);
begin
  if AssignedValues.EditFormat and (Value = FEditFormat) then
    Exit;

  AssignedValues.FEditFormat := True;
  FEditFormat := Value;
  Changed;
end;

procedure TcxCustomTextEditProperties.SetFixedListSelection(Value: Boolean);
begin
  if Value <> FFixedListSelection then
  begin
    FFixedListSelection := Value;
    if EditingStyle = esFixedList then
      Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetHideCursor(Value: Boolean);
begin
  if Value <> FHideCursor then
  begin
    FHideCursor := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetHideSelection(Value: Boolean);
begin
  if Value <> FHideSelection then
  begin
    FHideSelection := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetImeMode(Value: TImeMode);
begin
  if FImeMode <> Value then
  begin
    FImeMode := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetImeName(const Value: TImeName);
begin
  if FImeName <> Value then
  begin
    FImeName := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetIncrementalSearch(Value: Boolean);
begin
  if Value <> FIncrementalSearch then
  begin
    FIncrementalSearch := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetLookupItems(Value: TStrings);
begin
  FLookupItems.Assign(Value);
end;

procedure TcxCustomTextEditProperties.SetLookupItemsSorted(Value: Boolean);
begin
  FLookupItems.Sorted := Value;
end;

procedure TcxCustomTextEditProperties.SetMaxLength(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if AssignedValues.MaxLength and (Value = FMaxLength) then
    Exit;

  AssignedValues.FMaxLength := True;
  FMaxLength := Value;
  MaxLengthChanged;
end;

procedure TcxCustomTextEditProperties.SetMRUMode(Value: Boolean);
begin
  if Value <> FMRUMode then
  begin
    FMRUMode := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetOEMConvert(Value: Boolean);
begin
  if Value <> FOEMConvert then
  begin
    FOEMConvert := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetPasswordChar(Value: TCaptionChar);
begin
  if Value <> FPasswordChar then
  begin
    FPasswordChar := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetUseDisplayFormatWhenEditing(
  Value: Boolean);
begin
  if Value <> FUseDisplayFormatWhenEditing then
  begin
    FUseDisplayFormatWhenEditing := Value;
    Changed;
  end;
end;

procedure TcxCustomTextEditProperties.SetViewStyle(Value: TcxTextEditViewStyle);
const
  AButtonsViewStyleMap: array[TcxTextEditViewStyle] of TcxEditButtonsViewStyle =
    (bvsNormal, bvsNormal, bvsButtonsOnly, bvsButtonsAutoWidth);
begin
  if Value <> ViewStyle then
  begin
    BeginUpdate;
    try
      ButtonsViewStyle := AButtonsViewStyleMap[Value];
      HideCursor := Value <> vsNormal;
    finally
      EndUpdate;
    end;
  end;
end;

{ TcxCustomTextEdit }

{$IFDEF CBUILDER10}
constructor TcxCustomTextEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;
{$ENDIF}

destructor TcxCustomTextEdit.Destroy;
begin
  FText := Text;
  cxFormatController.RemoveListener(Self);
  FreeAndNil(FLookupData);
  inherited Destroy;
end;

procedure TcxCustomTextEdit.Activate(var AEditData: TcxCustomEditData);
begin
  inherited Activate(AEditData);
  if HandleAllocated then
  begin
    SelStart := 0;
    if ActiveProperties.AutoSelect then
      SelectAll;
  end;
end;

class function TcxCustomTextEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomTextEditProperties;
end;

procedure TcxCustomTextEdit.CopyToClipboard;
begin
  if ActiveProperties.EditingStyle in [esFixedList, esNoEdit] then
    SelectAll;
  if SelLength > 0 then
    InnerTextEdit.CopyToClipboard;
end;

procedure TcxCustomTextEdit.CutToClipboard;
var
  ANewSelStart: Integer;
  ANewText, S: string;
  APrevKeyboardAction: Boolean;
begin
  if SelLength = 0 then
    Exit;
  if Focused then
  begin
    APrevKeyboardAction := KeyboardAction;
    KeyboardAction := True;
    try
      S := '';
      if CanChangeSelText(S, ANewText, ANewSelStart) then
        InnerEdit.CallDefWndProc(WM_CUT, 0, 0);
    finally
      KeyboardAction := APrevKeyboardAction;
    end;
  end
  else
  begin
    InnerTextEdit.CopyToClipboard;
    SelText := '';
  end;
end;

function TcxCustomTextEdit.IsEditClass: Boolean;
begin
{$IFDEF CXTEST}
  if FHideInnerEdit or FShowInnerEdit then
  begin
    Result := not FHideInnerEdit and FShowInnerEdit;
    Exit;
  end;
{$ENDIF}
  Result := (ActiveProperties.EditingStyle in [esEdit, esEditList])
    and not PropertiesChangeLocked and not IsDesigning;
end;

procedure TcxCustomTextEdit.PasteFromClipboard;
var
  ANewSelStart: Integer;
  ANewText, S: string;
  APrevKeyboardAction: Boolean;
begin
  if Clipboard.HasFormat(CF_TEXT) then
    if Focused then
    begin
      APrevKeyboardAction := KeyboardAction;
      KeyboardAction := True;
      try
        S := Clipboard.AsText;
        if CanChangeSelText(S, ANewText, ANewSelStart) then
          InnerEdit.CallDefWndProc(WM_PASTE, 0, 0);
      finally
        KeyboardAction := APrevKeyboardAction;
      end;
    end
    else
      SelText := Clipboard.AsText;
end;

procedure TcxCustomTextEdit.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
begin
  EditValue := ADisplayValue;
end;

procedure TcxCustomTextEdit.SelectAll;
begin
  InnerTextEdit.SelectAll;
end;

{$IFDEF DELPHI10}
function TcxCustomTextEdit.GetTextBaseLine: Integer;
begin
  Result := ViewInfo.GetTextBaseLine;
end;

function TcxCustomTextEdit.HasTextBaseLine: Boolean;
begin
  Result := True;
end;
{$ENDIF}

procedure TcxCustomTextEdit.ClearSelection;
var
  APrevKeyboardAction: Boolean;
  APrevSelStart: Integer;
  AText: string;
begin
  if SelLength = 0 then
    Exit;
  APrevKeyboardAction := KeyboardAction;
  KeyboardAction := Focused or FIsChangeBySpellChecker;
  try
    AText := DisplayValue;
    Delete(AText, SelStart + 1, SelLength);
    APrevSelStart := SelStart;
    if SetDisplayText(AText) then
      SelStart := APrevSelStart;
  finally
    KeyboardAction := APrevKeyboardAction;
  end;
end;

function TcxCustomTextEdit.DoInnerControlDefaultHandler(var Message: TMessage): Boolean;
begin
  InternalSpellCheckerHandler(Message);
  Result := inherited DoInnerControlDefaultHandler(Message);
end;

function TcxCustomTextEdit.IsChildWindow(AWnd: THandle): Boolean;
begin
  Result := inherited IsChildWindow(AWnd) or
    (Assigned(dxISpellChecker) and dxISpellChecker.IsSpellCheckerDialogControl(AWnd));
end;

procedure TcxCustomTextEdit.SetScrollBarsParameters(AIsScrolling: Boolean = False);
begin
  inherited SetScrollBarsParameters(AIsScrolling);
  InternalCheckSelection;
end;

procedure TcxCustomTextEdit.SetSelection(ASelStart: Integer; ASelLength: Integer);
begin
  SelStart := ASelStart;
  SelLength := ASelLength;
end;

procedure TcxCustomTextEdit.Undo;
begin
  Reset;
end;

procedure TcxCustomTextEdit.AdjustInnerEditPosition;
var
  AInnerEditBounds: TRect;
  AInnerEditHeight, AInnerEditTop: Integer;
  R: TRect;
begin
  if (InnerTextEdit = nil) or FInnerEditPositionAdjusting then
    Exit;
  FInnerEditPositionAdjusting := True;
  try
    AInnerEditHeight := GetInnerEditHeight;
    AInnerEditTop := 0;
    R := ViewInfo.ClientRect;
    case TcxCustomTextEditProperties(ActiveProperties).Alignment.Vert of
      taTopJustify:
        AInnerEditTop := R.Top + ContentParams.Offsets.Top;
      taBottomJustify:
        AInnerEditTop := R.Bottom - AInnerEditHeight - ContentParams.Offsets.Bottom;
      taVCenter:
        AInnerEditTop := R.Top + ContentParams.Offsets.Top + (R.Bottom - R.Top - AInnerEditHeight - ContentParams.Offsets.Top - ContentParams.Offsets.Bottom) div 2;
    end;
    if AInnerEditTop < R.Top + ContentParams.Offsets.Top then
      AInnerEditTop := R.Top + ContentParams.Offsets.Top;
    with ContentParams.Offsets do
      AInnerEditBounds := Rect(R.Left + Left, AInnerEditTop,
        R.Right - R.Left + 1 - (Left + Right), AInnerEditHeight);
    with AInnerEditBounds do
      if not EqualRect(InnerEdit.Control.BoundsRect, Rect(Left, Top, Left + Right, Top + Bottom)) then
        InnerEdit.Control.SetBounds(Left, Top, Right, Bottom);
    if IsInplace then
    begin
      Inc(R.Top);
      Dec(R.Bottom);
    end;
    if not IsInplace and (ViewInfo.NativeState <> TC_NONE) and
      ViewInfo.ComboBoxStyle and (ActiveProperties.EditingStyle in [esEdit, esEditList]) then
    begin
      Dec(R.Right);
      Dec(R.Bottom);
    end;
    AlignControls(InnerEdit.Control, R);
  finally
    FInnerEditPositionAdjusting := False;
  end;
end;

function TcxCustomTextEdit.CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := inherited CanKeyDownModifyEdit(Key, Shift);
  Result := Result or (Key = VK_DELETE);
  if ActiveProperties.UseLookupData and not ILookupData.IsEmpty and
    GetScrollLookupDataList(escKeyboard) then
      case Key of
        VK_DOWN, VK_UP:
          Result := not(ssAlt in Shift) and not HasPopupWindow;
        VK_PRIOR, VK_NEXT:
          Result := not HasPopupWindow;
      end;
end;

function TcxCustomTextEdit.CanKeyPressModifyEdit(Key: Char): Boolean;
begin
  Result := (Key = #8) or (Key = #22) or (Key = #24) or IsTextChar(Key);
end;

procedure TcxCustomTextEdit.ChangeHandler(Sender: TObject);
begin
  LockChangeEvents(True);
  try
    inherited ChangeHandler(Sender);
    if not ViewInfo.IsEditClass then
      UpdateDrawValue;
    if Focused and ActiveProperties.IsEditValueNumeric and
      ActiveProperties.HasDigitGrouping(FIsDisplayValueSynchronizing) then
        SeparateDigitGroups(Self);
  finally
    LockChangeEvents(False);
  end;
end;

procedure TcxCustomTextEdit.DoEditKeyDown(var Key: Word; Shift: TShiftState);
var
  AEditingStyle: TcxEditEditingStyle;
  AFindSelection: Boolean;
  APrevCurrentKey: TcxEditValue;
  APrevKey: Word;
begin
  AEditingStyle := ActiveProperties.EditingStyle;
  if (AEditingStyle = esFixedList) and not IsSpecialKey(Key, Shift) then
    case Key of
      VK_LEFT, VK_RIGHT, VK_DELETE:
        begin
          FindSelection := False;
          DoAfterKeyDown(Key, Shift);
          Key := 0;
        end;
    end;

  InnerTextEdit.InternalUpdating := True;
  APrevKey := Key;
  AFindSelection := FindSelection;
  inherited DoEditKeyDown(Key, Shift);
  if (TranslateKey(APrevKey) = VK_RETURN) and AFindSelection then
    SelectAll;
  if Key = 0 then
    Exit;

  case Key of
    VK_LEFT, VK_RIGHT:
      begin
        if not(ssShift in Shift) and (SelLength > 0) then
        begin
          if Key = VK_RIGHT then
            SelStart := SelStart + SelLength
          else
            SelStart := SelStart;
          SelLength := 0;
          Key := 0;
        end;
        FindSelection := False;
      end;

    VK_DOWN, VK_UP, VK_PRIOR, VK_NEXT, VK_HOME, VK_END:
      begin
        if ((Key <> VK_HOME) and (Key <> VK_END) or (AEditingStyle = esFixedList)) and
          ActiveProperties.UseLookupData and GetScrollLookupDataList(escKeyboard) and
          not ILookupData.IsEmpty then
        begin
          LockChangeEvents(True);
          LookupItemsScrolling := True;
          try
            APrevCurrentKey := ILookupData.CurrentKey;
            LockClick(True);
            try
              case Key of
                VK_PRIOR:
                  if ssCtrl in Shift then
                    ILookupData.Go(egdBegin, False)
                  else
                    ILookupData.Go(egdPageUp, False);
                VK_NEXT:
                  if ssCtrl in Shift then
                    ILookupData.Go(egdEnd, False)
                  else
                    ILookupData.Go(egdPageDown, False);
                VK_UP:
                  ILookupData.Go(egdPrev, False);
                VK_DOWN:
                  ILookupData.Go(egdNext, False);
                VK_HOME:
                  ILookupData.Go(egdBegin, False);
                VK_END:
                  ILookupData.Go(egdEnd, False);
              end;
            finally
              LockClick(False);
            end;
            if not VarEqualsExact(APrevCurrentKey, ILookupData.CurrentKey) then
            begin
              DoClick;
              if CanPostEditValue and ActiveProperties.ImmediatePost and
                ValidateEdit(True) then
                  InternalPostEditValue;
            end;
            Key := 0;
          finally
            LookupItemsScrolling := False;
            LockChangeEvents(False);
          end;
        end;
        if (Key <> VK_HOME) and (Key <> VK_END) and not InnerTextEdit.MultiLine then
        begin
          if Key <> 0 then
            DoAfterKeyDown(Key, Shift);
          Key := 0;
        end;
      end;

    VK_DELETE:
      begin
        if AEditingStyle = esEditList then
        begin
          DoAfterKeyDown(Key, Shift);
          Key := 0;
        end
        else
          FindSelection := False;
      end;
  end;
  if (Key = VK_END) and (SelLength = 0) and (AEditingStyle <> esFixedList) then
    FindSelection := False;

  if Key <> 0 then
    InnerTextEdit.InternalUpdating := False;
end;

procedure TcxCustomTextEdit.DoEditKeyPress(var Key: Char);

  function FillFromList(var AFindText: string): Boolean;
  var
    ATail: string;
    L: Integer;
    S: string;
  begin
    S := AFindText;
    if InnerTextEdit.ImeLastChar <> #0 then
      S := S + InnerTextEdit.ImeLastChar;
    Result := ILookupData.Locate(S, ATail, False);
    if Result then
    begin
      AFindText := S;
      if InnerTextEdit.ImeLastChar <> #0 then
      begin
        L := Length(AFindText);
        Insert(Copy(AFindText, L, 1), ATail, 1);
        Delete(AFindText, L, 1);
      end;
    end;
    FFindSelection := Result;
    if AFindText = '' then
    begin
      if ActiveProperties.EditingStyle <> esFixedList then
        InternalSetDisplayValue('');
      FFindSelection := False;
    end;
    if Result then
    begin
      DataBinding.DisplayValue := AFindText + ATail;
      SelStart := Length(AFindText);
      SelLength := Length(ATail);
    end;
    UpdateDrawValue;
  end;

  function CanContinueIncrementalSearch: Boolean;
  begin
    Result := ActiveProperties.EditingStyle in [esEditList, esFixedList];
    if not Result then
      Result := (SelLength = 0) and (SelStart = Length(DisplayValue)) or
        FindSelection or (SelLength > 0);
  end;

var
  AEditingStyle: TcxEditEditingStyle;
  AFindText: string;
  AFound: Boolean;
  APrevCurrentKey: TcxEditValue;
  APrevFindSelection: Boolean;
begin
  InnerTextEdit.InternalUpdating := True;
  inherited DoEditKeyPress(Key);
  if Key = #0 then
    Exit;

  UnlockLookupDataTextChanged;
  KeyboardAction := True;
  AEditingStyle := ActiveProperties.EditingStyle;
  if AEditingStyle = esFixedList then
    case Key of
      #8:
        if not ActiveProperties.FixedListSelection then
        begin
          Key := #0;
          FindSelection := False;
        end;
    end;

  APrevCurrentKey := ILookupData.CurrentKey;
  APrevFindSelection := FindSelection;
  AFound := False;
  LockClick(True);
  try
    if Key = #8 then
    begin
        if ActiveProperties.UseLookupData and ActiveProperties.CanIncrementalSearch then
        begin
          if (AEditingStyle = esEditList) and (Length(DisplayValue) > 0) and not FindSelection then
          begin
            SelLength := Length(DisplayValue) - SelStart;
            FindSelection := True;
          end;
          if FindSelection then
          begin
            AFindText := Copy(DisplayValue, 1, Length(DisplayValue) - SelLength);
            SetLength(AFindText, Length(AFindText) - Length(AnsiLastChar(AFindText)));
            LockLookupDataTextChanged;
            AFound := FillFromList(AFindText);
          end;
          if AEditingStyle = esFixedList then
            Key := #0;
        end;
    end
    else
      if IsTextChar(Key) then
      begin
        if ActiveProperties.UseLookupData then
        begin
          if ActiveProperties.CanIncrementalSearch and CanContinueIncrementalSearch then
          begin
            LockLookupDataTextChanged;
            AFound := False;
            AFindText := DisplayValue;
            if SelLength > 0 then
              AFindText := Copy(AFindText, 1, SelStart) + Key
            else
              if AEditingStyle = esFixedList then
                if FindSelection then
                begin
                  AFindText := AFindText + Key;
                  AFound := FillFromList(AFindText);
                  if not AFound then
                    AFindText := Key;
                end
                else
                  AFindText := Key
              else
                Insert(Key, AFindText, SelStart + 1);
            if not AFound then
              AFound := FillFromList(AFindText);
            if (AEditingStyle = esFixedList) and not ActiveProperties.FixedListSelection and not AFound then
            begin
              AFindText := Key;
              AFound := FillFromList(AFindText);
            end;
          end;
          if (AEditingStyle in [esEditList, esFixedList]) and not AFound then
          begin
            Key := #0;
            if (AEditingStyle = esEditList) and (DisplayValue <> '') or
                (AEditingStyle = esFixedList) and ActiveProperties.FixedListSelection and APrevFindSelection then
              FindSelection := True;
          end;
        end;
      end;
  finally
    LockClick(False);
    KeyboardAction := False;
    if ActiveProperties.UseLookupData and not VarEqualsExact(APrevCurrentKey,
      ILookupData.CurrentKey) then
        DoClick;
  end;
  if AFound then
    Key := #0;
  if Key <> #0 then
    InnerTextEdit.InternalUpdating := False;
end;

procedure TcxCustomTextEdit.DoExit;
begin
  inherited DoExit;
  FindSelection := False;
end;

function TcxCustomTextEdit.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
   MousePos: TPoint): Boolean;
const
  AGoDirectionMap: array [Boolean] of TcxEditLookupDataGoDirection = (egdNext, egdPrev);
var
  APrevCurrentKey: TcxEditValue;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if Result then
    Exit;

  Result := GetScrollLookupDataList(escMouseWheel) and not HasPopupWindow and
    ActiveProperties.UseLookupData and not ILookupData.IsEmpty and HandleMouseWheel(Shift);
  if not(Result and DoEditing) then
    Exit;
    
  APrevCurrentKey := ILookupData.CurrentKey;
  LockChangeEvents(True);
  LookupItemsScrolling := True;
  try
    LockClick(True);
    try
      ILookupData.Go(AGoDirectionMap[WheelDelta > 0], False);
    finally
      LockClick(False);
      if not VarEqualsExact(APrevCurrentKey, ILookupData.CurrentKey) then
      begin
        DoClick;
        if CanPostEditValue and ActiveProperties.ImmediatePost and ValidateEdit(True) then
          InternalPostEditValue;
      end;
    end;
  finally
    LookupItemsScrolling := False;
    LockChangeEvents(False);
  end;
end;

procedure TcxCustomTextEdit.FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties);
begin
  if ViewInfo = nil then
    Exit;
  AEditSizeProperties := DefaultcxEditSizeProperties;
  AEditSizeProperties.MaxLineCount := 1;
end;

function TcxCustomTextEdit.GetInnerControlBounds(const AInnerControlsRegion: TRect;
  AInnerControl: TControl): TcxContainerInnerControlBounds;
begin
  if IsEditClass then
    Result := inherited GetInnerControlBounds(AInnerControlsRegion, AInnerControl)
  else
  begin
    Result.IsEmpty := False;
    Result.Rect := cxEmptyRect;
  end;
end;

function TcxCustomTextEdit.GetDisplayValue: string;
begin
  if InnerEdit = nil then
    Result := ''
  else
    Result := InnerEdit.EditValue;
end;

function TcxCustomTextEdit.GetInnerEditClass: TControlClass;
begin
  Result := TcxCustomInnerTextEdit;
end;

procedure TcxCustomTextEdit.Initialize;
var
  ALookupDataClass: TcxInterfacedPersistentClass;
begin
  inherited Initialize;
  FBeepOnEnter := True;
  FFindSelection := False;

  if InnerTextEdit <> nil then
  begin
    TControlAccess(InnerTextEdit.Control).Color := clWindow;
    InnerTextEdit.OnSelChange := SelChange;
  end;
  Width := 121;
  Height := 21;

  ALookupDataClass := Properties.GetLookupDataClass;
  if ALookupDataClass <> nil then
  begin
    FLookupData := ALookupDataClass.Create(Self);
    ILookupData.OnSelectItem := HandleSelectItem;
  end;

  cxFormatController.AddListener(Self);
end;

function TcxCustomTextEdit.InternalDoEditing: Boolean;
begin
  Result := ActiveProperties.EditingStyle <> esNoEdit;
end;

function TcxCustomTextEdit.InternalGetEditingValue: TcxEditValue;
begin
  Result := Text;
end;

procedure TcxCustomTextEdit.InternalSetDisplayValue(const Value: TcxEditValue);
begin
  DataBinding.DisplayValue := Value;
  if not KeyboardAction then
  begin
    ResetOnNewDisplayValue;
    SynchronizeEditValue;
    EditModified := False;
  end;
end;

procedure TcxCustomTextEdit.InternalValidateDisplayValue(const ADisplayValue: TcxEditValue);
//var
//  APrevFindSelection: Boolean;
begin
//  APrevFindSelection := FindSelection;
//  try
    if (ActiveProperties.EditingStyle = esEdit) and ActiveProperties.UseLookupData and
      not ILookupData.Find(ADisplayValue) then
        DoOnNewLookupDisplayText(ADisplayValue);
    inherited InternalValidateDisplayValue(ADisplayValue);
//  finally
//    FindSelection := APrevFindSelection;
//  end;
end;

function TcxCustomTextEdit.IsTextInputMode: Boolean;
begin
  with ActiveProperties do
    Result := (EchoMode = eemNormal) and CanModify; 
end; 

function TcxCustomTextEdit.IsValidChar(AChar: Char): Boolean;
begin
  Result := inherited IsValidChar(AChar) or
    (AnsiChar(AChar) in ActiveProperties.ValidChars);
end;

procedure TcxCustomTextEdit.KeyPress(var Key: Char);
begin
  if (Word(Key) = VK_ESCAPE) and IsEditValueResetting and
      FIsPopupWindowJustClosed and not HasPopupWindow then
    FIsPopupWindowJustClosed := False;
  inherited KeyPress(Key);
end;

procedure TcxCustomTextEdit.Loaded;
begin
  inherited Loaded;
  ShortRefreshContainer(False);
end;

procedure TcxCustomTextEdit.PropertiesChanged(Sender: TObject);
begin
  if InnerTextEdit <> nil then
    InnerTextEdit.Alignment := ActiveProperties.FAlignment.Horz;
  if ActiveProperties.UseLookupData then
    ILookupData.PropertiesChanged;
  if ActiveProperties.UseLookupData and not FLookupDataTextChangedLocked then
    ILookupData.TextChanged;
  if not PropertiesChangeLocked and not IsEditClass then
    UpdateDrawValue;

  if InnerTextEdit = nil then
    Exit;

  ImeMode := ActiveProperties.ImeMode;
  ImeName := ActiveProperties.ImeName;
  with InnerTextEdit do
  begin
    Alignment := ActiveProperties.Alignment.Horz;
    AutoSelect := ActiveProperties.AutoSelect and not IsInplace;
    CharCase := ActiveProperties.FCharCase;
    EchoMode := ActiveProperties.FEchoMode;
    HideSelection := ActiveProperties.FHideSelection;
    ImeMode := ActiveProperties.ImeMode;
    ImeName := ActiveProperties.ImeName;
    MaxLength := ActiveProperties.GetInnerEditMaxLength;
    OEMConvert := ActiveProperties.OEMConvert;
    PasswordChar := ActiveProperties.PasswordChar;
  end;

  CheckEditValue;
  if not IsPosting then
    UpdateDisplayValue;
  UpdateDrawValue;
  inherited PropertiesChanged(Sender);
  if InnerTextEdit <> nil then
    InnerTextEdit.Control.Invalidate;
end;

function TcxCustomTextEdit.RefreshContainer(const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AIsMouseEvent: Boolean): Boolean;
begin
  Result := False;
  if (not HandleAllocated) or (csDestroying in ComponentState) then Exit;
  Result := inherited RefreshContainer(P, Button, Shift, AIsMouseEvent);
  if Result then
    AdjustInnerEdit;
end;

function TcxCustomTextEdit.SetDisplayText(const Value: string): Boolean;
var
  ADisplayValue: TcxEditValue;
begin
  ADisplayValue := Value;
  Result := ActiveProperties.IsDisplayValueValid(ADisplayValue, InternalFocused);
  if Result then
    Result := not(KeyboardAction and not DoEditing);
  if Result then
    InternalSetDisplayValue(ADisplayValue);
end;

procedure TcxCustomTextEdit.SetInternalDisplayValue(Value: TcxEditValue);
begin
  if InnerEdit <> nil then
    InnerEdit.EditValue := Value;
end;

function TcxCustomTextEdit.WantNavigationKeys: Boolean;
begin
  Result := True;
end;

procedure TcxCustomTextEdit.LockedInnerEditWindowProc(var Message: TMessage);
begin
  if Message.Msg = WM_SETFOCUS then
  begin
    if InnerTextEdit.AutoSelect then
      SelectAll;
  end
  else
    inherited LockedInnerEditWindowProc(Message);
end;

procedure TcxCustomTextEdit.UnlockInnerEditRepainting;
var
  APrevAutoSelect: Boolean;
begin
  inherited UnlockInnerEditRepainting;
  APrevAutoSelect := InnerTextEdit.AutoSelect;
  InnerTextEdit.AutoSelect := False;
  SendMessage(InnerEdit.Control.Handle, WM_SETFOCUS, 0, 0);
  InnerTextEdit.AutoSelect := APrevAutoSelect;
end;

procedure TcxCustomTextEdit.WndProc(var Message: TMessage);
var
  ASaveHideSelection: Boolean;
begin
  if (Message.Msg = WM_SPELLCHECKERAUTOCORRECT) and (InnerControl <> nil) and
      InnerControl.HandleAllocated then
    with PdxSpellCheckerAutoCorrectWordRange(Message.LParam)^ do
    begin
      ASaveHideSelection := ActiveProperties.HideSelection;
      ActiveProperties.HideSelection := True;
      try
        Self.SelStart := SelStart;
        Self.SelLength := SelLength;
        SendMessageW(InnerControl.Handle, EM_REPLACESEL, 1, Longint(PWideChar(Replacement)));
        Self.SelStart := NewSelStart;
      finally
        ActiveProperties.HideSelection := ASaveHideSelection;
      end;
    end;
  inherited WndProc(Message);
end;

procedure TcxCustomTextEdit.FormatChanged;
begin
  ActiveProperties.Changed;
  SynchronizeDisplayValue;
end;

procedure TcxCustomTextEdit.AdjustInnerEdit;
var
  AFont: TFont;
begin
  if (InnerTextEdit = nil) or FIsCreating then
    Exit;
  InnerEdit.LockBounds(True);
  try
    with TControlAccess(InnerTextEdit.Control) do
    begin
      Color := ViewInfo.BackgroundColor;
      AFont := TFont.Create;
      try
        AFont.Assign(ActiveStyle.GetVisibleFont);
        AFont.Color := ViewInfo.TextColor;
        AssignFonts(Font, AFont);
      finally
        FreeAndNil(AFont);
      end;
    end;
  finally
    InnerEdit.LockBounds(False);
  end;
end;

function TcxCustomTextEdit.CanChangeSelText(const Value: string;
  out ANewText: string; out ANewSelStart: Integer): Boolean;
var
  ADisplayValue: TcxEditValue;
  AEditingStyle: TcxEditEditingStyle;
  AValue: string;
begin
  AValue := string(PChar(Value));
  Result := False;
  AEditingStyle := ActiveProperties.EditingStyle;
  if KeyboardAction and (AEditingStyle = esNoEdit) then
    Exit;
  if AEditingStyle in [esFixedList, esNoEdit] then
    SelectAll;
  if KeyboardAction and (AEditingStyle in [esEdit, esNoEdit]) and (ActiveProperties.MaxLength > 0) then
  begin
    ANewText := Copy(Text, 1, SelStart) + AValue;
    ANewSelStart := Length(WideString(ANewText));
    if ANewSelStart > ActiveProperties.MaxLength then
      ANewSelStart := ActiveProperties.MaxLength;
    ANewSelStart := Length(string(Copy(WideString(ANewText), 1, ANewSelStart)));
    if ANewSelStart < SelStart then
      Exit;

    ANewText := ANewText + Copy(Text, SelStart + SelLength + 1, Length(Text) - SelStart - SelLength);
    if Length(WideString(ANewText)) > ActiveProperties.MaxLength then
      ANewText := Copy(WideString(ANewText), 1, ActiveProperties.MaxLength);
  end else
  begin
    if ActiveProperties.EditingStyle <> esFixedList then
    begin
      ANewText := Text;
      ANewText := Copy(ANewText, 1, SelStart) + AValue +
        Copy(ANewText, SelStart + SelLength + 1, Length(ANewText) - SelLength - SelStart);
    end
    else
      ANewText := AValue;
    ANewSelStart := SelStart + Length(AValue);
  end;
  ADisplayValue := ANewText;
  Result := ActiveProperties.IsDisplayValueValid(ADisplayValue, InternalFocused) and
    not (KeyboardAction and not DoEditing);
  if Result then
    ANewText := VarToStr(ADisplayValue);
end;

procedure TcxCustomTextEdit.CheckEditValue;
begin
  if DataBinding.CanCheckEditorValue and ActiveProperties.IsEditValueNumeric and
    not PropertiesChangeLocked and ActiveProperties.IsValueBoundsDefined then
      CheckEditorValueBounds;
end;

procedure TcxCustomTextEdit.CheckEditorValueBounds;
begin
end;

procedure TcxCustomTextEdit.DoOnNewLookupDisplayText(const AText: string);
begin
  with Properties do
    if Assigned(OnNewLookupDisplayText) then
      OnNewLookupDisplayText(Self, AText);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnNewLookupDisplayText) then
        OnNewLookupDisplayText(Self, AText);
end;

procedure TcxCustomTextEdit.DoDrawMisspellings;
begin
  if Assigned(dxISpellChecker) then
    dxISpellChecker.DrawMisspellings(InnerControl);
end;

procedure TcxCustomTextEdit.DoSelectionChanged;
begin
  if Assigned(dxISpellChecker) then
    dxISpellChecker.SelectionChanged(InnerControl);
end;

procedure TcxCustomTextEdit.DoLayoutChanged;
begin
  FLastFirstVisibleCharIndex := InnerTextEdit.GetFirstVisibleCharIndex;
  if Assigned(dxISpellChecker) then
    dxISpellChecker.LayoutChanged(InnerControl);
end;

procedure TcxCustomTextEdit.DoTextChanged;
begin
  if Assigned(dxISpellChecker) then
    dxISpellChecker.TextChanged(InnerControl);
end;

procedure TcxCustomTextEdit.InternalCheckSelection;
begin
  if InnerControl.HandleAllocated then
  begin
    if FLastFirstVisibleCharIndex <> InnerTextEdit.GetFirstVisibleCharIndex then
      DoLayoutChanged
    else
      if (InnerTextEdit.SelStart <> FLastSelPosition) or
        (InnerTextEdit.SelLength <> FLastSelLength) then
      begin
        FLastSelPosition := InnerTextEdit.SelStart;
        FLastSelLength := InnerTextEdit.SelLength;
        DoSelectionChanged;
      end;
  end;
end;

procedure TcxCustomTextEdit.InternalSpellCheckerHandler(Message: TMessage);
begin
  case Message.Msg of
    WM_SETFOCUS:
      if Assigned(dxISpellChecker) then
        dxISpellChecker.CheckStart(InnerControl);
    WM_KILLFOCUS:
      if Assigned(dxISpellChecker) then
        dxISpellChecker.CheckFinish;
    WM_SETFONT, WM_SIZE:
      DoLayoutChanged;
    WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP, WM_KEYUP:
      InternalCheckSelection;
    CN_CTLCOLOREDIT:
      if not InnerTextEdit.MultiLine then
        RedrawMisspelledWords;
    WM_CTLCOLOREDIT:
      if InnerTextEdit.MultiLine then
        RedrawMisspelledWords;
    WM_PAINT:
      RedrawMisspelledWords;
    WM_UNDO, EM_UNDO:
      if Assigned(dxISpellChecker) then
        dxISpellChecker.Undo;
    else
      if Message.Msg = WM_REDRAWMISSPELLINGS then
        DoDrawMisspellings;
  end;
end;

procedure TcxCustomTextEdit.RedrawMisspelledWords;
begin
  if InnerControl.HandleAllocated then
    PostMessage(InnerControl.Handle, WM_REDRAWMISSPELLINGS, 0, 0);
end;

procedure TcxCustomTextEdit.SpellCheckerSetSelText(
  const AValue: string; APost: Boolean = False);
begin
  FIsChangeBySpellChecker := True;
  try
    SelText := AValue;
    if APost and not IsInplace and CanPostEditValue and not Focused then
    begin
      LockChangeEvents(True);
      try
        SpellCheckerSetValue(DisplayValue);
        InternalPostEditValue;
      finally
        LockChangeEvents(False);
      end;
    end;
    ModifiedAfterEnter := True;
  finally
    FIsChangeBySpellChecker := False;
  end;
end;

function TcxCustomTextEdit.GetInnerEditHeight: Integer;
begin
  Result := cxScreenCanvas.FontHeight(TControlAccess(InnerTextEdit.Control).Font)
end;

function TcxCustomTextEdit.GetItemIndex: Integer;
begin
  Result := LookupKeyToItemIndex(ILookupData.CurrentKey);
end;

function TcxCustomTextEdit.GetItemObject: TObject;
begin
  if ItemIndex <> -1 then
    Result := ActiveProperties.LookupItems.Objects[ItemIndex]
  else
    Result := nil;
end;

function TcxCustomTextEdit.GetScrollLookupDataList(AScrollCause: TcxEditScrollCause): Boolean;
begin
  Result := False;
end;

procedure TcxCustomTextEdit.HandleSelectItem(Sender: TObject);
var
  ANewEditValue: TcxEditValue;
  AEditValueChanged: Boolean;
begin
  ANewEditValue := LookupKeyToEditValue(ILookupData.CurrentKey);
  AEditValueChanged := not VarEqualsExact(EditValue, ANewEditValue);
  if AEditValueChanged and not DoEditing then
    Exit;
  SaveModified;
  LockLookupDataTextChanged;
  try
    InternalEditValue := ANewEditValue;
  finally
    UnlockLookupDataTextChanged;
    RestoreModified;
  end;
  if AEditValueChanged then
    ModifiedAfterEnter := True;
  SelectAll;
  ShortRefreshContainer(False);
end;

function TcxCustomTextEdit.InternalGetText: string;
begin
  Result := DisplayValue;
end;

function TcxCustomTextEdit.InternalSetText(const Value: string): Boolean;
begin
  Result := SetDisplayText(Value);
end;

function TcxCustomTextEdit.ItemIndexToLookupKey(AItemIndex: Integer): TcxEditValue;
begin
  Result := AItemIndex;
end;

procedure TcxCustomTextEdit.LockLookupDataTextChanged;
begin
  FLookupDataTextChangedLocked := True;
end;

function TcxCustomTextEdit.LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue;
var
  AText: string;
begin
  AText := ILookupData.GetDisplayText(AKey);
  PrepareEditValue(AText, Result, False);
end;

function TcxCustomTextEdit.LookupKeyToItemIndex(const AKey: TcxEditValue): Integer;
begin
  Result := AKey;
end;

function TcxCustomTextEdit.NeedResetInvalidTextWhenPropertiesChanged: Boolean;
begin
  Result := not IsInplace and not DataBinding.IDefaultValuesProvider.IsDataStorage;
end;

procedure TcxCustomTextEdit.ResetOnNewDisplayValue;
begin
  if ActiveProperties.UseLookupData then
    FindSelection := False;
end;

procedure TcxCustomTextEdit.SelChange(Sender: TObject);
begin
end;

procedure TcxCustomTextEdit.SetEditingText(const Value: TCaption);
begin
  if DoEditing then
  begin
    Text := Value;
    ModifiedAfterEnter := True;
  end;
end;

procedure TcxCustomTextEdit.SetItemIndex(Value: Integer);
var
  ANewEditValue: TcxEditValue;
  APrevItemIndex: Integer;
begin
  APrevItemIndex := ItemIndex;
  LockClick(True);
  try
    ILookupData.CurrentKey := ItemIndexToLookupKey(Value);
    ANewEditValue := LookupKeyToEditValue(ILookupData.CurrentKey);
    if not VarEqualsExact(EditValue, ANewEditValue) then
      EditValue := ANewEditValue;
  finally
    LockClick(False);
  end;
  if ItemIndex <> APrevItemIndex then
  begin
    EditModified := False;
    Click;
  end;
end;

procedure TcxCustomTextEdit.SynchronizeDisplayValue;
var
  ADisplayValue, AEditValue: TcxEditValue;
  AIsEditValueValid: Boolean;
begin
  if ActiveProperties.CanValidate then
  begin
    AEditValue := EditValue;
    AIsEditValueValid := ActiveProperties.IsEditValueValid(AEditValue, InternalFocused);
    if not AIsEditValueValid and not Focused then
      try
        if VarIsDate(EditValue) then
          ADisplayValue := DateTimeToStr(EditValue)
        else
          ADisplayValue := VarToStr(EditValue)
      except
        on EVariantError do
          ADisplayValue := '';
      end
    else
      if AIsEditValueValid then
        PrepareDisplayValue(AEditValue, ADisplayValue, InternalFocused)
      else
        ADisplayValue := ActiveProperties.DefaultFocusedDisplayValue;
  end
  else
    PrepareDisplayValue(EditValue, ADisplayValue, InternalFocused);
  SaveModified;
  FIsDisplayValueSynchronizing := True;
  try
    DataBinding.DisplayValue := ADisplayValue;
  finally
    FIsDisplayValueSynchronizing := False;
    RestoreModified;
    ResetOnNewDisplayValue;
    UpdateDrawValue;
  end;
end;

procedure TcxCustomTextEdit.SynchronizeEditValue;
var
  APrevEditValue: TcxEditValue;
  ACompareEditValue, AEditValueChanged: Boolean;
begin
  ACompareEditValue := ActiveProperties.CanCompareEditValue;
  if ACompareEditValue then
    APrevEditValue := EditValue
  else
    APrevEditValue := Null;
  PrepareEditValue(DisplayValue, FEditValue, InternalFocused);

  if ACompareEditValue then
    AEditValueChanged := not InternalVarEqualsExact(APrevEditValue, FEditValue)
  else
    AEditValueChanged := False;
  if KeyboardAction then
    ModifiedAfterEnter := True
  else
    EditModified := False;
  if AEditValueChanged then
  begin
    DoEditValueChanged;
    if not ActiveProperties.HasDisplayValue then
      DoChange;
  end;
end;

procedure TcxCustomTextEdit.UndoPerformed;
begin
end;

procedure TcxCustomTextEdit.UnlockLookupDataTextChanged;
begin
  FLookupDataTextChangedLocked := False;
end;

procedure TcxCustomTextEdit.UpdateDrawValue;

  procedure SetTextSelection;
  var
    AEditingStyle: TcxEditEditingStyle;
  begin
    AEditingStyle := ActiveProperties.EditingStyle;
    if AEditingStyle in [esFixedList, esNoEdit] then
      with ViewInfo do
        if (AEditingStyle = esNoEdit) or not FindSelection or not ActiveProperties.FixedListSelection then
          SelLength := 0
        else
        begin
          if DrawSelectionBar then
          begin
            SelStart := 0;
            SelLength := Length(Text) - Self.SelLength;
            SelBackgroundColor := clHighlightText;
            SelTextColor := clHighlight;
          end else
          begin
            SelStart := Self.SelStart;
            SelLength := Self.SelLength;
            SelBackgroundColor := clHighlight;
            SelTextColor := clHighlightText;
          end;
        end;
  end;

var
  AViewData: TcxCustomTextEditViewData;
begin
  AViewData := TcxCustomTextEditViewData(CreateViewData);
  try
    AViewData.DisplayValueToDrawValue(DisplayValue, ViewInfo);
  finally
    AViewData.Free;
  end;
  if HandleAllocated then
  begin
    CalculateViewInfo(False);
    SetTextSelection;
    InvalidateRect(Rect(0, 0, Width, Height), False);
  end;
end;

procedure TcxCustomTextEdit.UpdateDisplayValue;
var
  ADisplayValue: TcxEditValue;
begin
  if PropertiesChangeLocked then
    Exit;

  if ActiveProperties.EditingStyle in [esEditList, esFixedList] then
  begin
    if ModifiedAfterEnter and not IsEditValidated or NeedResetInvalidTextWhenPropertiesChanged then
    begin
      ADisplayValue := DisplayValue;
      if not ActiveProperties.IsDisplayValueValid(ADisplayValue, True) then
      begin
        SaveModified;
        DataBinding.DisplayValue := ActiveProperties.DefaultFocusedDisplayValue;
        RestoreModified;
        if not ModifiedAfterEnter then
          SynchronizeEditValue;
      end;
    end
    else
      SynchronizeDisplayValue;
  end
  else
    if not ModifiedAfterEnter then
      DataBinding.UpdateDisplayValue;
end;

function TcxCustomTextEdit.GetCursorPos: Integer;
begin
  if InnerTextEdit.Control is TcxCustomInnerTextEdit then
    Result := TcxCustomInnerTextEdit(InnerTextEdit.Control).CursorPos
  else
    Result := 0;
end;

function TcxCustomTextEdit.GetEditingText: TCaption;
begin
  Result := Text;
end;

function TcxCustomTextEdit.GetInnerTextEdit: IcxInnerTextEdit;
begin
  Result := InnerEdit as IcxInnerTextEdit;
end;

function TcxCustomTextEdit.GetILookupData: IcxTextEditLookupData;
begin
  Result := FLookupData as IcxTextEditLookupData;
end;

function TcxCustomTextEdit.GetLookupData: TcxCustomTextEditLookupData;
begin
  Result := TcxCustomTextEditLookupData(FLookupData);
end;

function TcxCustomTextEdit.GetProperties: TcxCustomTextEditProperties;
begin
  Result := TcxCustomTextEditProperties(FProperties);
end;

function TcxCustomTextEdit.GetActiveProperties: TcxCustomTextEditProperties;
begin
  Result := TcxCustomTextEditProperties(InternalGetActiveProperties);
end;

function TcxCustomTextEdit.GetSelLength: Integer;
var
  AEditingStyle: TcxEditEditingStyle;
begin
  AEditingStyle := ActiveProperties.EditingStyle;
  if (AEditingStyle = esFixedList) and not FindSelection or (AEditingStyle = esNoEdit) then
    Result := 0
  else
    Result := InnerTextEdit.SelLength;
end;

function TcxCustomTextEdit.GetSelStart: Integer;
var
  AEditingStyle: TcxEditEditingStyle;
begin
  AEditingStyle := ActiveProperties.EditingStyle;
  if (AEditingStyle = esFixedList) and not FindSelection or (AEditingStyle = esNoEdit) then
    Result := 0
  else
    Result := InnerTextEdit.SelStart;
end;

function TcxCustomTextEdit.GetSelText: TCaption;
var
  AEditingStyle: TcxEditEditingStyle;
begin
  AEditingStyle := ActiveProperties.EditingStyle;
  if (AEditingStyle = esFixedList) and not FindSelection or (AEditingStyle = esNoEdit) then
    Result := ''
  else
    Result := InnerTextEdit.SelText;
end;

function TcxCustomTextEdit.GetViewInfo: TcxCustomTextEditViewInfo;
begin
  Result := TcxCustomTextEditViewInfo(FViewInfo);
end;

procedure TcxCustomTextEdit.SetFindSelection(Value: Boolean);
begin
  if not HandleAllocated or (Value = FindSelection) or FDisableRefresh then
    Exit;
  FFindSelection := Value;
  CalculateViewInfo(False);
  UpdateDrawValue;
end;

procedure TcxCustomTextEdit.SetItemObject(Value: TObject);
begin
  ItemIndex := ActiveProperties.LookupItems.IndexOfObject(Value);
end;

procedure TcxCustomTextEdit.SetProperties(Value: TcxCustomTextEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomTextEdit.SetSelLength(Value: Integer);
begin
  if ActiveProperties.EditingStyle <> esNoEdit then
    InnerTextEdit.SelLength := Value;
end;

procedure TcxCustomTextEdit.SetSelStart(Value: Integer);
begin
  if ActiveProperties.EditingStyle <> esNoEdit then
    InnerTextEdit.SelStart := Value;
end;

{$IFDEF DELPHI12}
function TcxCustomTextEdit.GetTextHint: string;
begin
  Result := InnerTextEdit.TextHint;
end;

procedure TcxCustomTextEdit.SetTextHint(Value: string);
begin
  InnerTextEdit.TextHint := Value;
end;
{$ENDIF}

{$IFDEF CXTEST}
procedure TcxCustomTextEdit.SetHideInnerEdit(Value: Boolean);
begin
  if Value <> FHideInnerEdit then
  begin
    FHideInnerEdit := Value;
    PropertiesChanged(ActiveProperties);
  end;
end;

procedure TcxCustomTextEdit.SetShowInnerEdit(Value: Boolean);
begin
  if Value <> FShowInnerEdit then
  begin
    FShowInnerEdit := Value;
    PropertiesChanged(ActiveProperties);
  end;
end;

procedure TcxCustomTextEdit.SetTesting(Value: Boolean);
begin
  if Value <> FTesting then
  begin
    FTesting := Value;
    ShortRefreshContainer(False);
  end;
end;
{$ENDIF}

procedure TcxCustomTextEdit.SetSelText(const Value: TCaption);
var
  ANewSelStart: Integer;
  ANewText: string;
  APrevKeyboardAction: Boolean;
begin
  APrevKeyboardAction := KeyboardAction;
  KeyboardAction := Focused or FIsChangeBySpellChecker;
  try
    if CanChangeSelText(Value, ANewText, ANewSelStart) then
    begin
      InternalSetDisplayValue(ANewText);
      SelStart := ANewSelStart;
    end;
  finally
    KeyboardAction := APrevKeyboardAction;
  end;
end;

procedure TcxCustomTextEdit.WMClear(var Message: TMessage);
begin
  KeyboardAction := True;
  try
    if (not ActiveProperties.ReadOnly) and DataBinding.IsDataAvailable then
      ClearSelection;
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomTextEdit.WMCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    EN_CHANGE:
      DoTextChanged;
    EN_VSCROLL, EN_HSCROLL:
      DoLayoutChanged;
  end;
end;

procedure TcxCustomTextEdit.WMGetText(var Message: TWMGetText);
var
  S: string;
begin
  if Message.TextMax > 0 then
  begin
    if FProperties = nil then
      S := FText
    else
      S := InternalGetText;

    if Length(S) > Message.TextMax - 1 then
      SetLength(S, Message.TextMax - 1);
    StrLCopy(Message.Text, PChar(S), Message.TextMax - 1);
    Message.Result := Length(S);
  end
  else
    Message.Result := 0;
end;

procedure TcxCustomTextEdit.WMGetTextLength(var Message: TWMGetTextLength);
begin
  if FProperties = nil then
    Message.Result := Length(FText)
  else
    Message.Result := Length(InternalGetText);
end;

procedure TcxCustomTextEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  if HasInnerEdit and not IsInplace then
    InnerControl.HandleNeeded;
  inherited;
end;

procedure TcxCustomTextEdit.WMSetText(var Message: TWMSetText);
begin
  if FInternalTextSetting then
    inherited
  else
  begin
    Message.Result := 0;
    FInternalTextSetting := True;
    try
      if InternalSetText(string(Message.Text)) then
        Message.Result := 1;
    finally
      FInternalTextSetting := False;
    end;
  end;
end;

{ TcxTextEdit }

class function TcxTextEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxTextEditProperties;
end;

function TcxTextEdit.GetActiveProperties: TcxTextEditProperties;
begin
  Result := TcxTextEditProperties(InternalGetActiveProperties);
end;

function TcxTextEdit.GetProperties: TcxTextEditProperties;
begin
  Result := TcxTextEditProperties(FProperties);
end;

function TcxTextEdit.SupportsSpelling: Boolean;
begin
  Result := IsTextInputMode;
end;

procedure TcxTextEdit.SetProperties(Value: TcxTextEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterTextEditHelper }

class function TcxFilterTextEditHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxTextEdit;
end;

class procedure TcxFilterTextEditHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  with TcxCustomTextEditProperties(AProperties) do
  begin
    AutoSelect := True;
    HideSelection := True;
    ViewStyle := vsNormal;
  end;
end;  

class procedure TcxFilterTextEditHelper.SetFilterValue(AEdit: TcxCustomEdit;
  AEditProperties: TcxCustomEditProperties; AValue: Variant);
begin
  AEdit.EditValue := AValue;
end;

initialization
  WM_REDRAWMISSPELLINGS := RegisterWindowMessage('WM_REDRAWMISSPELLINGS');
  WM_SPELLCHECKERAUTOCORRECT := RegisterWindowMessage('WM_SPELLCHECKERAUTOCORRECT');
  GetRegisteredEditProperties.Register(TcxTextEditProperties, scxSEditRepositoryTextItem);
  FilterEditsController.Register(TcxTextEditProperties, TcxFilterTextEditHelper);

finalization
  FilterEditsController.Unregister(TcxTextEditProperties, TcxFilterTextEditHelper);

end.
