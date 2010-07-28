{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressFilterControl                                         }
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
unit cxFilterControl;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
{$IFDEF DELPHI6}
  Types,
  Variants,
{$ENDIF}
  Classes, SysUtils, Controls, Forms, Graphics, cxFilter, cxEdit,
  cxClasses, cxContainer, cxControls, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxDropDownEdit, Menus, cxTextEdit, StdCtrls,
  cxFilterControlUtils, cxDataStorage, cxFormats;

const
  cxFilterControlMaxDropDownRows = 12;

type
  IcxFilterControl = interface
  ['{B9890E09-5400-428D-8F72-1FF8FD15937C}']
    function GetCaption(Index: Integer): string;
    function GetCount: Integer;
    function GetCriteria: TcxFilterCriteria;
    function GetItemLink(Index: Integer): TObject;
    function GetItemLinkID(Index: Integer): Integer;
    function GetItemLinkName(Index: Integer): string;
    function GetFieldName(Index: Integer): string;
    function GetProperties(Index: Integer): TcxCustomEditProperties;
    function GetValueType(Index: Integer): TcxValueTypeClass;

    property Captions[Index: Integer]: string read GetCaption;
    property Count: Integer read GetCount;
    property Criteria: TcxFilterCriteria read GetCriteria;
    property ItemLinkNames[Index: Integer]: string read GetItemLinkName;
    property ItemLinkIDs[Index: Integer]: Integer read GetItemLinkID;
    property ItemLinks[Index: Integer]: TObject read GetItemLink;
    property FieldNames[Index: Integer]: string read GetFieldName;
    property Properties[Index: Integer]: TcxCustomEditProperties read GetProperties;
    property ValueTypes[Index: Integer]: TcxValueTypeClass read GetValueType;
  end;

  IcxFilterControlDialog = interface
  ['{D2369F8D-3B22-41A8-881E-B01BEB624B7D}']
    procedure SetDialogLinkComponent(ALink: TComponent);
  end;

  TcxFilterControlCriteria = class;
  TcxCustomFilterControl = class;
  TcxCustomFilterControlClass = class of TcxCustomFilterControl;
  TcxFilterControlViewInfo = class;
  TcxFilterControlViewInfoClass = class of TcxFilterControlViewInfo;

  { TcxFilterControlCriteriaItem }

  TcxFilterControlCriteriaItem = class(TcxFilterCriteriaItem)
  private
    function GetFilterControlCriteria: TcxFilterControlCriteria;
    function GetFilter: IcxFilterControl;
    function GetItemIndex: Integer;
    function ValidItem: Boolean;
  protected
    function GetDataValue(AData: TObject): Variant; override;
    function GetFieldCaption: string; override;
    function GetFieldName: string; override;
    function GetFilterOperatorClass: TcxFilterOperatorClass; override;
    property ItemIndex: Integer read GetItemIndex;
  public
    property Filter: IcxFilterControl read GetFilter;
    property Criteria: TcxFilterControlCriteria read GetFilterControlCriteria;
  end;

  { TcxFilterControlCriteria }

  TcxFilterControlCriteria = class(TcxFilterCriteria)
  private
    FControl: TcxCustomFilterControl;
  protected
    function GetIDByItemLink(AItemLink: TObject): Integer; override;
    function GetItemClass: TcxFilterCriteriaItemClass; override;
    function GetItemLinkByID(AID: Integer): TObject; override;
    //ver. 3
    function GetNameByItemLink(AItemLink: TObject): string; override;
    function GetItemLinkByName(const AName: string): TObject; override;

    property Control: TcxCustomFilterControl read FControl;
  public
    constructor Create(AOwner: TcxCustomFilterControl); virtual;
    procedure AssignEvents(Source: TPersistent); override;
  end;

  TcxFilterControlCriteriaClass = class of TcxFilterControlCriteria;

  TcxCustomRowViewInfo = class;
  TcxGroupViewInfo = class;
  TcxConditionViewInfo = class;

  TcxFilterControlHitTest = (fhtNone, fhtButton, fhtBoolOperator, fhtItem,
    fhtOperator, fhtValue, fhtAddCondition, fhtAddValue);

  TcxFilterControlHitTestInfo = record
    HitTest: TcxFilterControlHitTest;
    Mouse: TPoint;
    Shift: TShiftState;
    Row: TcxCustomRowViewInfo;
    ValueIndex: Integer;
  end;

  { TcxCustomRowViewInfo }

  TcxCustomRowViewInfo = class
  private
    FButtonText: string;
    FButtonRect: TRect;
    FButtonState: TcxButtonState;
    FControl: TcxCustomFilterControl;
    FCriteriaItem: TcxCustomFilterCriteriaItem;
    FLevel: Integer;
    FIndent: Integer;
    FParent: TcxCustomRowViewInfo;
    FRowRect: TRect;
    function GetCondition: TcxConditionViewInfo;
    function GetFocused: Boolean;
    function GetGroup: TcxGroupViewInfo;
    procedure GetInternal;
  protected
    function GetWidth: Integer; virtual;
    function IsLast: Boolean;
  public
    constructor Create(AControl: TcxCustomFilterControl;
      AParent: TcxCustomRowViewInfo;
      ACriteriaItem: TcxCustomFilterCriteriaItem); virtual;
    destructor Destroy; override;
    procedure Calc(const ARowRect: TRect); virtual;
    procedure GetHitTestInfo(const P: TPoint; var HitInfo: TcxFilterControlHitTestInfo); virtual;
    function Ready: Boolean; virtual;

    property ButtonRect: TRect read FButtonRect write FButtonRect;
    property ButtonState: TcxButtonState read FButtonState write FButtonState;
    property ButtonText: string read FButtonText write FButtonText;
    property Condition: TcxConditionViewInfo read GetCondition;
    property Control: TcxCustomFilterControl read FControl;
    property CriteriaItem: TcxCustomFilterCriteriaItem read FCriteriaItem;
    property Focused: Boolean read GetFocused;
    property Group: TcxGroupViewInfo read GetGroup;
    property Indent: Integer read FIndent;
    property Level: Integer read FLevel;
    property Parent: TcxCustomRowViewInfo read FParent;
    property RowRect: TRect read FRowRect write FRowRect;
    property Width: Integer read GetWidth;
  end;

  { TcxGroupViewInfo }

  TcxGroupViewInfo = class(TcxCustomRowViewInfo)
  private
    FBoolOperator: TcxFilterBoolOperatorKind;
    FBoolOperatorText: string;
    FBoolOperatorRect: TRect;
    FCaption: string;
    FCaptionRect: TRect;
    FRows: TList;
    function GetRow(Index: Integer): TcxCustomRowViewInfo;
    function GetRowCount: Integer;
    procedure SetRow(Index: Integer; const Value: TcxCustomRowViewInfo);
  protected
    function GetWidth: Integer; override;
  public
    constructor Create(AControl: TcxCustomFilterControl;
      AParent: TcxCustomRowViewInfo;
      ACriteriaItem: TcxCustomFilterCriteriaItem); override;
    destructor Destroy; override;
    procedure Add(ARow: TcxCustomRowViewInfo);
    procedure Remove(ARow: TcxCustomRowViewInfo);
    procedure Calc(const ARowRect: TRect); override;
    procedure GetHitTestInfo(const P: TPoint; var HitInfo: TcxFilterControlHitTestInfo); override;
    property BoolOperator: TcxFilterBoolOperatorKind read FBoolOperator write FBoolOperator;
    property BoolOperatorText: string read FBoolOperatorText write FBoolOperatorText;
    property BoolOperatorRect: TRect read FBoolOperatorRect;
    property Caption: string read FCaption write FCaption;
    property CaptionRect: TRect read FCaptionRect;
    property RowCount: Integer read GetRowCount;
    property Rows[Index: Integer]: TcxCustomRowViewInfo read GetRow write SetRow;
  end;

  { TcxValuesViewInfo }

  TcxValueInfo = class
  private
    FValue: TcxEditValue;
    FValueText: TCaption;
    FValueRect: TRect;
    FValueViewInfo: TcxCustomEditViewInfo;
    procedure SetValueViewInfo(const Value: TcxCustomEditViewInfo);
  public
    constructor Create;
    destructor Destroy; override;
    property Value: TcxEditValue read FValue write FValue;
    property ValueText: TCaption read FValueText write FValueText;
    property ValueRect: TRect read FValueRect write FValueRect;
    property ValueViewInfo: TcxCustomEditViewInfo
      read FValueViewInfo write SetValueViewInfo;
  end;

  { TcxValuesViewInfo }

  TcxValuesViewInfo = class
  private
    FAddButtonRect: TRect;
    FAddButtonState: TcxButtonState;
    FCondition: TcxConditionViewInfo;
    FList: TList;
    FSeparator: string;
    function GetControl: TcxCustomFilterControl;
    function GetValue(Index: Integer): TcxValueInfo;
    function GetWidth: Integer;
  protected
    function GetCount: Integer;
    procedure UpdateEditorStyle(AStyle: TcxCustomEditStyle; 
      AHightlited, AEnabled: Boolean);
  public
    constructor Create(ACondition: TcxConditionViewInfo);
    destructor Destroy; override;
    procedure AddValue;
    procedure Calc;
    procedure Clear;
    procedure GetHitTestInfo(const P: TPoint; var HitInfo: TcxFilterControlHitTestInfo); virtual;
    procedure RemoveValue(AIndex: Integer);
    property AddButtonRect: TRect read FAddButtonRect;
    property AddButtonState: TcxButtonState read FAddButtonState;
    property Condition: TcxConditionViewInfo read FCondition;
    property Control: TcxCustomFilterControl read GetControl;
    property Count: Integer read GetCount;
    property Separator: string read FSeparator;
    property Values[Index: Integer]: TcxValueInfo read GetValue; default;
    property Width: Integer read GetWidth;
  end;

  { TcxConditionViewInfo }

  TcxConditionViewInfo = class(TcxCustomRowViewInfo)
  private
    FOperator: TcxFilterControlOperator;
    FOperatorRect: TRect;
    FOperatorText: string;
    FItemIndex: Integer;
    FItemLink: TObject;
    FItemRect: TRect;
    FItemText: string;
    FEditorHelper: TcxCustomFilterEditHelperClass;
    FEditorProperties: TcxCustomEditProperties;
    FSupportedOperators: TcxFilterControlOperators;
    FValueType: TcxValueTypeClass;
    FValues: TcxValuesViewInfo;
  private
    function GetItemIndex: Integer;
  protected
    ValueEditorData: TcxCustomEditData;
    procedure AddValue;
    function GetWidth: Integer; override;
    function HasDisplayValues: Boolean; virtual;
    procedure InitValues(ASaveValue: Boolean);
    procedure InternalInit; virtual;
    procedure SetItem(AIndex: Integer);
    procedure ValidateConditions;
  public
    constructor Create(AControl: TcxCustomFilterControl;
      AParent: TcxCustomRowViewInfo;
      ACriteriaItem: TcxCustomFilterCriteriaItem); override;
    destructor Destroy; override;
    procedure Calc(const ARowRect: TRect); override;
    procedure GetHitTestInfo(const P: TPoint; var HitInfo: TcxFilterControlHitTestInfo); override;
    function GetProperties: TcxCustomEditProperties;
    function Ready: Boolean; override;
    property EditorHelper: TcxCustomFilterEditHelperClass read FEditorHelper;
    property EditorProperties: TcxCustomEditProperties read FEditorProperties;
    property ItemLink: TObject read FItemLink;
    property ItemIndex: Integer read FItemIndex;
    property ItemRect: TRect read FItemRect;
    property ItemText: string read FItemText write FItemText;
    property Operator: TcxFilterControlOperator read FOperator write FOperator;
    property OperatorRect: TRect read FOperatorRect;
    property OperatorText: string read FOperatorText write FOperatorText;
    property SupportedOperators: TcxFilterControlOperators read FSupportedOperators;
    property ValueType: TcxValueTypeClass read FValueType;
    property Values: TcxValuesViewInfo read FValues;
  end;

  { TcxCustomFilterControl }

  TFilterControlState = (fcsNormal, fcsSelectingAction, fcsSelectingItem,
    fcsSelectingBoolOperator, fcsSelectingCondition, fcsSelectingValue);

  TcxFilterControlFont = (fcfBoolOperator, fcfItem, fcfCondition, fcfValue);
  TcxActivateValueEditKind = (aveEnter, aveKey, aveMouse);

  TcxCustomFilterControl = class(TcxControl, IcxMouseTrackingCaller,
    IcxFormatControllerListener, IdxSkinSupport)
  private
    FActionMenu: TPopupMenu;
    FComboBox: TcxComboBox;
    FCriteria: TcxFilterControlCriteria;
    FFocusedInfo: TcxFilterControlHitTestInfo;
    FFonts: array[TcxFilterControlFont] of TFont;
    FHotTrack: TcxFilterControlHitTestInfo;
    FInplaceEditors: TcxInplaceEditList;
    FLeftOffset: Integer;
    FLockCount: Integer;
    FRoot: TcxCustomRowViewInfo;
    FRows: TList;
    FSortItems: Boolean;
    FState: TFilterControlState;
    FTextEditProperties: TcxTextEditProperties;
    FTopVisibleRow: Integer;

    FValueEditor: TcxCustomEdit;
    FValueEditorStyle: TcxCustomEditStyle;

    FViewInfo: TcxFilterControlViewInfo;
    FHotTrackOnUnfocused: Boolean;
    FNullString: string;
    FShowLevelLines: Boolean;
    FWantTabs: Boolean;
    FWasError: Boolean;
    FOnApplyFilter: TNotifyEvent;
    procedure CreateFonts;
    procedure DoFontChanged(Sender: TObject);
    function GetFont(Index: Integer): TFont;
    function IsFontStored(Index: Integer): Boolean;
    procedure SetFont(Index: Integer; const Value: TFont);

    function FocusedRowIndex: Integer;
    function GetRow(Index: Integer): TcxCustomRowViewInfo;
    function GetRowCount: Integer;
    function GetFocusedRow: TcxCustomRowViewInfo;

    procedure ComboBoxCloseUp(Sender: TObject);
    procedure ComboBoxExit(Sender: TObject);
    procedure ComboBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxPopup(Sender: TObject);
    procedure DoComboDropDown(const R: TRect; const AText: string);
    procedure SetFocusedRow(ARow: TcxCustomRowViewInfo);
    procedure PopupMenuClick(Sender: TObject);
    function IsNullStringStored: Boolean;
    procedure ProcessHitTest(AHitTest: TcxFilterControlHitTest; AByMouse: Boolean);
    procedure ReadData(AStream: TStream);
    procedure RecalcRows;
    procedure RefreshMenuCaptions;
    procedure SetLeftOffset(Value: Integer);
    procedure SetNullString(const Value: string);
    procedure SetTopVisibleRow(Value: Integer);
    procedure SetShowLevelLines(const Value: Boolean);
    procedure SetWantTabs(const Value: Boolean);
    procedure ValueEditorInit;
    // value editor events
    procedure ValueEditorAfterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ValueEditorExit(Sender: TObject);
    procedure ValueEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure WriteData(AStream: TStream);
  protected
    procedure CheckInplaceControlsColor; virtual;
    // overrided VCL
    procedure DefineProperties(Filer: TFiler); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetParent(AParent: TWinControl); override;
    // overrided cxControl
    procedure BoundsChanged; override;
    procedure DoLayoutChange; virtual;
    procedure FocusChanged; override;
    procedure FontChanged; override;
    function GetBorderSize: Integer; override;
    procedure InitControl; override;
    procedure InitScrollBarsParameters; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues); override;
    procedure MouseEnter(AControl: TControl); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    // work with rows
    procedure AddCondition(ARow: TcxCustomRowViewInfo);
    procedure AddGroup;
    procedure AddValue;
    procedure ClearRows;
    procedure Remove;
    procedure RemoveRow;
    procedure RemoveValue;
    // navigation
    procedure FocusNext(ATab: Boolean);
    procedure FocusPrev(ATab: Boolean);
    procedure FocusUp(ATab: Boolean);
    procedure FocusDown(ATab: Boolean);
    procedure RowNavigate(AElement: TcxFilterControlHitTest; ACellIndex: Integer = -1);
    procedure ValueEditorHide(AAccept: Boolean);

    procedure EnsureRowVisible;
    procedure RefreshProperties;

    procedure BuildFromCriteria; virtual;
    procedure BuildFromRows;

    procedure CreateInternalControls; virtual;
    procedure DestroyInternalControls; virtual;
    procedure DoApplyFilter; virtual;
    function GetDefaultProperties: TcxCustomEditProperties; virtual;
    function GetDefaultPropertiesViewInfo: TcxCustomEditViewInfo;
    function GetFilterControlCriteriaClass: TcxFilterControlCriteriaClass; virtual;
    function GetViewInfoClass: TcxFilterControlViewInfoClass; virtual;
    function HasFocus: Boolean;
    function HasHotTrack: Boolean;
    procedure FillFilterItemList(AStrings: TStrings); virtual;
    procedure FillConditionList(AStrings: TStrings); virtual;
    procedure ValidateConditions(var SupportedOperations: TcxFilterControlOperators); virtual;

    procedure CorrectOperatorClass(var AOperatorClass: TcxFilterOperatorClass); virtual;
    function GetFilterCaption: string; virtual;
    function GetFilterLink: IcxFilterControl; virtual;
    function GetFilterText: string; virtual;
    procedure SelectAction; virtual;
    procedure SelectBoolOperator; virtual;
    procedure SelectCondition; virtual;
    procedure SelectItem; virtual;
    procedure SelectValue(AActivateKind: TcxActivateValueEditKind; AKey: Char); virtual;

    // IcxMouseTrackingCaller
    procedure DoMouseLeave;
    procedure IcxMouseTrackingCaller.MouseLeave = DoMouseLeave;

    // IcxFormatContollerListener
    procedure FormatChanged;

    property Criteria: TcxFilterControlCriteria read FCriteria;
    property FilterLink: IcxFilterControl read GetFilterLink;
    property FocusedInfo: TcxFilterControlHitTestInfo read FFocusedInfo;
    property FocusedRow: TcxCustomRowViewInfo read GetFocusedRow write SetFocusedRow;
    property LeftOffset: Integer read FLeftOffset write SetLeftOffset;
    property NullString: string read FNullString write SetNullString stored IsNullStringStored;
    property RowCount: Integer read GetRowCount;
    property Rows[Index: Integer]: TcxCustomRowViewInfo read GetRow;
    property State: TFilterControlState read FState write FState;
    property TopVisibleRow: Integer read FTopVisibleRow write SetTopVisibleRow;
    property ViewInfo: TcxFilterControlViewInfo read FViewInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyFilter;
    procedure BeginUpdate;
    procedure Clear; virtual;
    procedure EndUpdate;
    function IsValid: Boolean; virtual;
    function HasItems: Boolean;
    procedure LayoutChanged;
    procedure Localize;
    // save & restore
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    // IdxLocalizerListener
    procedure TranslationChanged; override;

    // properties
    property Color default clBtnFace;
    property FilterCaption: string read GetFilterCaption;
    property FilterText: string read GetFilterText;
    property FontBoolOperator: TFont index fcfBoolOperator read GetFont write SetFont stored IsFontStored;
    property FontCondition: TFont index fcfCondition read GetFont write SetFont stored IsFontStored;
    property FontItem: TFont index fcfItem read GetFont write SetFont stored IsFontStored;
    property FontValue: TFont index fcfValue read GetFont write SetFont stored IsFontStored;
    property HotTrackOnUnfocused: Boolean read FHotTrackOnUnfocused write FHotTrackOnUnfocused default True;
    property LookAndFeel;
    property ParentColor default False;
    property ShowLevelLines: Boolean read FShowLevelLines write SetShowLevelLines default True;
    property SortItems: Boolean read FSortItems write FSortItems default False;
    property WantTabs: Boolean read FWantTabs write SetWantTabs default False;
    property OnApplyFilter: TNotifyEvent read FOnApplyFilter write FOnApplyFilter;
  end;

  { TcxFilterControlPainter }

  TcxFilterControlPainter = class
  private
    FControl: TcxCustomFilterControl;
    function GetCanvas: TcxCanvas;
    function GetPainter: TcxCustomLookAndFeelPainterClass;
    function GetViewInfo: TcxFilterControlViewInfo;
    procedure DrawGroup(ARow: TcxGroupViewInfo);
    procedure DrawCondition(ARow: TcxConditionViewInfo);
    procedure DrawValues(ARow: TcxConditionViewInfo);
  protected
    function GetContentColor: TColor; virtual;
    procedure DrawBorder;
    procedure DrawDotLine(const R: TRect);
    procedure DrawRow(ARow: TcxCustomRowViewInfo); virtual;
    procedure TextDraw(X, Y: Integer; const AText: string);
  public
    constructor Create(AOwner: TcxCustomFilterControl); virtual;
    property Canvas: TcxCanvas read GetCanvas;
    property ContentColor: TColor read GetContentColor;
    property Control: TcxCustomFilterControl read FControl;
    property Painter: TcxCustomLookAndFeelPainterClass read GetPainter;
    property ViewInfo: TcxFilterControlViewInfo read GetViewInfo;
  end;

  TcxFilterControlPainterClass = class of TcxFilterControlPainter;

  { TcxFilterControlViewInfo }

  TcxFilterControlViewInfo = class
  private
    FControl: TcxCustomFilterControl;
    FAddConditionRect: TRect;
    FAddConditionCaption: string;
    FBitmap: TBitmap;
    FBitmapCanvas: TcxCanvas;
    FButtonState: TcxButtonState;
    FFocusRect: TRect;
    FMaxRowWidth: Integer;
    FPainter: TcxFilterControlPainter;
    FRowHeight: Integer;
    FMinValueWidth: Integer;
    FEnabled: Boolean;
    procedure CalcButtonState;
    procedure CheckBitmap;
    function GetCanvas: TcxCanvas;
    function GetEditHeight: Integer;
  protected
    procedure CalcFocusRect; virtual;
    function GetPainterClass: TcxFilterControlPainterClass; virtual;
  public
    constructor Create(AOwner: TcxCustomFilterControl); virtual;
    destructor Destroy; override;
    procedure Calc;
    procedure GetHitTestInfo(AShift: TShiftState; const P: TPoint;
      var HitInfo: TcxFilterControlHitTestInfo); virtual;
    procedure Paint;
    procedure InvalidateRow(ARow: TcxCustomRowViewInfo);
    procedure Update;
    property AddConditionCaption: string read FAddConditionCaption;
    property AddConditionRect: TRect read FAddConditionRect;
    property ButtonState: TcxButtonState read FButtonState;
    property Canvas: TcxCanvas read GetCanvas;
    property Control: TcxCustomFilterControl read FControl;
    property Enabled: Boolean read FEnabled;
    property MaxRowWidth: Integer read FMaxRowWidth;
    property MinValueWidth: Integer read FMinValueWidth;
    property Painter: TcxFilterControlPainter read FPainter;
    property RowHeight: Integer read FRowHeight;
  end;

  { TcxFilterControl }

  TcxFilterControl = class(TcxCustomFilterControl, IcxFilterControlDialog)
  private
    FLinkComponent: TComponent;
  {$IFDEF CBUILDER6}
    function GetLinkComponent: TComponent;
  {$ENDIF}
    procedure SetLinkComponent(Value: TComponent);
  protected
    //IcxFilterControlDialog
    procedure IcxFilterControlDialog.SetDialogLinkComponent = SetLinkComponent;
    function GetFilterLink: IcxFilterControl; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public  
    procedure UpdateFilter;
  published
    property Align;
    property Anchors;
    property Color;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property FontBoolOperator;
    property FontCondition;
    property FontItem;
    property FontValue;
    property HelpContext;
  {$IFDEF DELPHI6}
    property HelpKeyword;
    property HelpType;
  {$ENDIF}
    property Hint;
    property HotTrackOnUnfocused;
  {$IFDEF CBUILDER6}
    property LinkComponent: TComponent read GetLinkComponent write SetLinkComponent;
  {$ELSE}
    property LinkComponent: TComponent read FLinkComponent write SetLinkComponent;
  {$ENDIF}
    property LookAndFeel;
    property NullString;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowLevelLines;
    property SortItems;
    property TabOrder;
    property TabStop;
    property Visible;
    property WantTabs;
    property OnApplyFilter;
    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

function cxGetConditionText(AOperator: TcxFilterControlOperator): string;
function IsSupportFiltering(AClass: TcxCustomEditPropertiesClass): Boolean;

implementation

uses
  cxVariants, cxFilterConsts, cxFilterControlStrs, cxCustomData;

type
  TWinControlAccess = class(TWinControl);

const
  cxFilterControlFontColors: array[TcxFilterControlFont] of TColor = (clRed,
    clGreen, clMaroon, clBlue);

  EmptyRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

var
  cxBoolOperatorText: array[TcxFilterBoolOperatorKind] of string;
  cxConditionText: array[TcxFilterControlOperator] of string;
  HalftoneBrush: HBRUSH;

function cxGetConditionText(AOperator: TcxFilterControlOperator): string;
begin
  Result := cxConditionText[AOperator];
end;

function IsSupportFiltering(AClass: TcxCustomEditPropertiesClass): Boolean;
var
  Test: TcxCustomEditProperties;
begin
  Result := False;
  if AClass <> nil then
  begin
    Test := AClass.Create(nil);
    Result := esoFiltering in Test.GetSupportedOperations;
    Test.Free;
  end;
end;

function Max(A, B: Integer): Integer;
begin
  if A > B then Result := A else Result := B;
end;

function Min(A, B: Integer): Integer;
begin
  if A < B then Result := A else Result := B;
end;

function WidthOf(const R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function HeightOf(const R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;
procedure CenterRectVert(const ABounds: TRect; var R: TRect);
var
  H1, H2: Integer;
begin
  H1 := HeightOf(ABounds);
  H2 := HeightOf(R);
  OffsetRect(R, 0, (ABounds.Top - R.Top) + (H1 - H2) div 2);
end;

function cxStrFromBoolOperator(ABoolOperator: TcxFilterBoolOperatorKind): string;
begin
  case ABoolOperator of
    fboAnd: Result := cxGetResourceString(@cxSFilterBoolOperatorAnd);
    fboOr: Result := cxGetResourceString(@cxSFilterBoolOperatorOr);
    fboNotAnd: Result := cxGetResourceString(@cxSFilterBoolOperatorNotAnd);
    fboNotOr: Result := cxGetResourceString(@cxSFilterBoolOperatorNotOr);
  else
    Result := '';
  end;
end;

{ TcxFilterControlCriteriaItem }

function TcxFilterControlCriteriaItem.GetDataValue(
  AData: TObject): Variant;
begin
  Result := Null;
end;

function TcxFilterControlCriteriaItem.GetFieldCaption: string;
begin
  if ValidItem then
    Result := Filter.Captions[ItemIndex]
  else
    Result := '';
end;

function TcxFilterControlCriteriaItem.GetFieldName: string;
begin
  if ValidItem then
    Result := Filter.FieldNames[ItemIndex]
  else
    Result := '';
end;

function TcxFilterControlCriteriaItem.GetFilterOperatorClass: TcxFilterOperatorClass;
begin
  Result := inherited GetFilterOperatorClass;
  Criteria.Control.CorrectOperatorClass(Result);
end;

function TcxFilterControlCriteriaItem.GetFilter: IcxFilterControl;
begin
  if (Criteria <> nil) and (Criteria.Control <> nil) then
    Result := Criteria.Control.FilterLink
  else
    Result := nil;
end;

function TcxFilterControlCriteriaItem.GetItemIndex: Integer;
var
  I: Integer;
  AFilter: IcxFilterControl;
begin
  Result := -1;
  AFilter := Filter;
  if AFilter <> nil then
  begin
    for I := 0 to AFilter.Count - 1 do
      if AFilter.ItemLinks[I] = ItemLink then
      begin
        Result := I;
        break;
      end;
  end;
end;

function TcxFilterControlCriteriaItem.ValidItem: Boolean;
begin
  Result := (Filter <> nil) and (ItemIndex >= 0) and (ItemIndex < Filter.Count);
end;

function TcxFilterControlCriteriaItem.GetFilterControlCriteria: TcxFilterControlCriteria;
begin
  Result := TcxFilterControlCriteria(inherited Criteria);
end;

{ TcxFilterControlCriteria }

constructor TcxFilterControlCriteria.Create(
  AOwner: TcxCustomFilterControl);
begin
  inherited Create;
  FControl := AOwner;
  //ver 3
  Version := cxDataFilterVersion;
end;

procedure TcxFilterControlCriteria.AssignEvents(Source: TPersistent);
begin
//don't assign events
end;

function TcxFilterControlCriteria.GetIDByItemLink(
  AItemLink: TObject): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Control.FilterLink.Count - 1 do
    if Control.FilterLink.ItemLinks[I] = AItemLink then
    begin
      Result := Control.FilterLink.ItemLinkIDs[I];
      Break;
    end;
end;

function TcxFilterControlCriteria.GetItemClass: TcxFilterCriteriaItemClass;
begin
  Result := TcxFilterControlCriteriaItem;
end;

function TcxFilterControlCriteria.GetItemLinkByID(AID: Integer): TObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Control.FilterLink.Count - 1 do
    if Control.FilterLink.ItemLinkIDs[I] = AID then
    begin
      Result := Control.FilterLink.ItemLinks[I];
      Break;
    end;
end;

function TcxFilterControlCriteria.GetNameByItemLink(AItemLink: TObject): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Control.FilterLink.Count - 1 do
    if Control.FilterLink.ItemLinks[I] = AItemLink then
    begin
      Result := Control.FilterLink.ItemLinkNames[I];
      Break;
    end;
end;

function TcxFilterControlCriteria.GetItemLinkByName(const AName: string): TObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Control.FilterLink.Count - 1 do
    if SameText(Control.FilterLink.ItemLinkNames[I], AName) then
    begin
      Result := Control.FilterLink.ItemLinks[I];
      Break;
    end;
end;

{ TcxCustomRowViewInfo }

constructor TcxCustomRowViewInfo.Create(AControl: TcxCustomFilterControl;
  AParent: TcxCustomRowViewInfo; ACriteriaItem: TcxCustomFilterCriteriaItem);
begin
  inherited Create;
  FControl := AControl;
  FParent := AParent;
  FCriteriaItem := ACriteriaItem;
  FButtonState := cxbsNormal;
  if AParent <> nil then AParent.Group.Add(Self);
end;

destructor TcxCustomRowViewInfo.Destroy;
begin
  if Parent <> nil then Parent.Group.Remove(Self);
  inherited Destroy;
end;

procedure TcxCustomRowViewInfo.Calc(const ARowRect: TRect);
var
  AWidth: Integer;
begin
  FRowRect := ARowRect;
  GetInternal;
  with Control do
  begin
    Canvas.Font.Assign(Font);
    if FRoot = Self then
      AWidth := Canvas.TextWidth(FButtonText + '00')
    else
      AWidth := Canvas.TextWidth('0') * Length(FButtonText);
    FButtonRect := Classes.Bounds(ARowRect.Left + 4 + Indent, 0, AWidth,
      HeightOf(ARowRect) - 4);
    if not ViewInfo.Enabled then
      FButtonState := cxbsDisabled
    else
      if (FocusedRow = Self) and (FFocusedInfo.HitTest = fhtButton) then
        FButtonState := cxbsDefault
      else
        if HasHotTrack and (FHotTrack.Row = Self) and (FHotTrack.HitTest = fhtButton) then
          FButtonState := cxbsHot
        else
          FButtonState := cxbsNormal;
  end;
  CenterRectVert(FRowRect, FButtonRect);
end;

procedure TcxCustomRowViewInfo.GetHitTestInfo(const P: TPoint;
  var HitInfo: TcxFilterControlHitTestInfo);
begin
  if PtInRect(ButtonRect, P) then
    HitInfo.HitTest := fhtButton
end;

function TcxCustomRowViewInfo.Ready: Boolean;
begin
  Result := True;
end;

function TcxCustomRowViewInfo.GetWidth: Integer;
begin
  Result := FIndent + WidthOf(FButtonRect) + 5;
end;

function TcxCustomRowViewInfo.IsLast: Boolean;
begin
  Result := (FParent = nil) or
   (FParent.Group.GetRow(FParent.Group.GetRowCount - 1) = Self);
end;

function TcxCustomRowViewInfo.GetCondition: TcxConditionViewInfo;
begin
  Result := Self as TcxConditionViewInfo;
end;

function TcxCustomRowViewInfo.GetFocused: Boolean;
begin
  Result := Control.FocusedRow = Self;
end;

function TcxCustomRowViewInfo.GetGroup: TcxGroupViewInfo;
begin
  Result := Self as TcxGroupViewInfo;
end;

procedure TcxCustomRowViewInfo.GetInternal;
var
  AParent: TcxCustomRowViewInfo;
begin
  FLevel := 0;
  AParent := Parent;
  if AParent <> nil then
  begin
    FButtonText := '...';
    while AParent <> nil do
    begin
      AParent := AParent.Parent;
      Inc(FLevel);
    end
  end
  else FButtonText := cxGetResourceString(@cxSFilterRootButtonCaption);
  FIndent := FLevel * HeightOf(RowRect);
end;

{ TcxGroupViewInfo }

constructor TcxGroupViewInfo.Create(AControl: TcxCustomFilterControl;
  AParent: TcxCustomRowViewInfo; ACriteriaItem: TcxCustomFilterCriteriaItem);
begin
  inherited;
  FRows := TList.Create;
  FCaption := cxGetResourceString(@cxSFilterGroupCaption);
  if ACriteriaItem <> nil then
    FBoolOperator := TcxFilterCriteriaItemList(ACriteriaItem).BoolOperatorKind
  else
    FBoolOperator := fboAnd;
end;

destructor TcxGroupViewInfo.Destroy;
begin
  while RowCount > 0 do Rows[0].Free;
  FreeAndNil(FRows);
  inherited Destroy;
end;

procedure TcxGroupViewInfo.Add(ARow: TcxCustomRowViewInfo);
begin
  FRows.Add(ARow);
end;

procedure TcxGroupViewInfo.Remove(ARow: TcxCustomRowViewInfo);
begin
  FRows.Remove(ARow);
end;

procedure TcxGroupViewInfo.Calc(const ARowRect: TRect);
var
  ASize: TSize;
begin
  inherited Calc(ARowRect);
  with Control.Canvas do
  begin
    Font.Assign(Control.FontBoolOperator);
    FBoolOperatorText := cxBoolOperatorText[BoolOperator];
    ASize := TextExtent(FBoolOperatorText);
    FBoolOperatorRect := Bounds(ButtonRect.Right + 8, 0, ASize.cx + 2, ASize.cy + 2);
    CenterRectVert(FRowRect, FBoolOperatorRect);
    Font.Assign(Control.Font);
    ASize := TextExtent(FCaption);
    FCaptionRect := Bounds(FBoolOperatorRect.Right + 8, 0, ASize.cx + 2, ASize.cy + 2);
    CenterRectVert(FRowRect, FCaptionRect);
  end;
end;

procedure TcxGroupViewInfo.GetHitTestInfo(const P: TPoint;
  var HitInfo: TcxFilterControlHitTestInfo);
begin
  inherited;
  if HitInfo.HitTest = fhtNone then
    if PtInRect(FBoolOperatorRect, P) then HitInfo.HitTest := fhtBoolOperator;
end;

function TcxGroupViewInfo.GetWidth: Integer;
begin
  Result := inherited GetWidth + WidthOf(FBoolOperatorRect) +
    WidthOf(FCaptionRect) + 16;
end;

function TcxGroupViewInfo.GetRow(Index: Integer): TcxCustomRowViewInfo;
begin
  Result := TcxCustomRowViewInfo(FRows[Index]);
end;

function TcxGroupViewInfo.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

procedure TcxGroupViewInfo.SetRow(Index: Integer;
  const Value: TcxCustomRowViewInfo);
begin
  FRows[Index] := Value;
end;

{ TcxValueInfo }

constructor TcxValueInfo.Create;
begin
  inherited Create;
  FValue := Null;
  FValueText := '';
  FValueRect := EmptyRect;
end;

destructor TcxValueInfo.Destroy;
begin
  FreeAndNil(FValueViewInfo);
  inherited Destroy;
end;

procedure TcxValueInfo.SetValueViewInfo(
  const Value: TcxCustomEditViewInfo);
begin
  FValueViewInfo.Free;
  FValueViewInfo := Value;
end;

{ TcxValuesViewInfo }

constructor TcxValuesViewInfo.Create(ACondition: TcxConditionViewInfo);
begin
  inherited Create;
  FCondition := ACondition;
  FList := TList.Create;
end;

destructor TcxValuesViewInfo.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TcxValuesViewInfo.AddValue;
var
  V: TcxValueInfo;
begin
  V := TcxValueInfo.Create;
  V.ValueViewInfo :=
    TcxCustomEditViewInfo(Condition.GetProperties.GetViewInfoClass.Create);
  FList.Add(V);
end;

procedure TcxValuesViewInfo.Calc;
const
  AButtonTransparency: array[Boolean] of TcxEditButtonTransparency =
    (ebtHideInactive, ebtNone);
var
  AHightlited, AHotTrack, AUseDisplayValue: Boolean;
  AProperties: TcxCustomEditProperties;
  AProvider: IcxEditDefaultValuesProvider;
  ASize: TSize;
  ASizeProperties: TcxEditSizeProperties;
  ATopLeft, AMouse: TPoint;
  AValue: TcxEditValue;
  AViewData: TcxCustomEditViewData;
  I, AExtraSize: Integer;
begin
  if not Condition.HasDisplayValues then
  begin
    for I := 0 to Count - 1 do Values[I].FValueRect := EmptyRect;
    Exit;
  end
  else
  begin
    ATopLeft := Point(Condition.OperatorRect.Right + 8, 0);
    if Condition.Operator in [fcoBetween, fcoNotBetween] then
      FSeparator := cxGetResourceString(@cxSFilterAndCaption)
    else
      if Condition.Operator in [fcoInList, fcoNotInList] then
      begin
        Control.Canvas.Font.Assign(Control.FontValue);
        Inc(ATopLeft.X, Control.Canvas.TextWidth('('));
        FSeparator := ', ';
      end;
  end;
  AHotTrack := Control.HasHotTrack;
  AUseDisplayValue := (Condition.EditorHelper <> nil) and
    (Condition.EditorHelper.UseDisplayValue);
  for I := 0 to Count - 1 do
  with Values[I] do
  begin
    if VarIsNull(Value) then
    begin
      AProperties := Control.GetDefaultProperties;
      AValue := Control.NullString;
    end
    else
    begin
      AProperties := Condition.EditorProperties;
      if AUseDisplayValue then AValue := ValueText else AValue := Value;
    end;
    with AProperties do
    begin
      LockUpdate(True);
      AProvider := IDefaultValuesProvider;
      IDefaultValuesProvider := nil;
    end;
    try
      ValueViewInfo := TcxCustomEditViewInfo(AProperties.GetViewInfoClass.Create);
      with AProperties, Control do
      begin
        AHightlited := AHotTrack and
          (((FHotTrack.Row = Condition) and (FHotTrack.HitTest = fhtValue) and
           (FHotTrack.ValueIndex = I) and (State = fcsNormal)) or
          (HasFocus and (FocusedRow = Condition) and
           (FFocusedInfo.HitTest = fhtValue) and (FFocusedInfo.ValueIndex = I)));
        UpdateEditorStyle(FValueEditorStyle, AHightlited, ViewInfo.Enabled);
        AViewData := CreateViewData(FValueEditorStyle, True);
        AViewData.Enabled := ViewInfo.Enabled;
        try
          // calculate ValueRect
          FValueRect.TopLeft := ATopLeft;
          ASizeProperties.MaxLineCount := 1;
          ASizeProperties.Width := -1;
          ASizeProperties.Height := -1;
          ASize := AViewData.GetEditSize(Canvas, AValue, ASizeProperties);
          if AHightlited and (ASize.cx < ViewInfo.MinValueWidth) then
            ASize.cx := ViewInfo.MinValueWidth;
          with FValueRect do
          begin
            Right := Left + ASize.cx;
            Bottom := Top + ASize.cy;
          end;
          CenterRectVert(Condition.RowRect, FValueRect);
          // calculate
          if not FilterEditsController.FindHelper(AProperties.ClassType).EditPropertiesHasButtons then
            AViewData.ButtonVisibleCount := 0;
          AViewData.EditValueToDrawValue(Canvas, AValue, ValueViewInfo);
          AViewData.Calculate(Canvas, ValueRect, AMouse, cxmbNone, [],
            ValueViewInfo, True);
        finally
          FreeAndNil(AViewData);
        end;
        AExtraSize := 4;
        if Condition.Operator in [fcoBetween, fcoNotBetween, fcoInList, fcoNotInList] then
        begin
          Canvas.Font.Assign(FontValue);
          Inc(AExtraSize, Canvas.TextWidth(FSeparator) + 4);
        end;
        Inc(ATopLeft.X, WidthOf(ValueRect) + AExtraSize);
      end;
    finally
      with AProperties do
      begin
        IDefaultValuesProvider := AProvider;
        LockUpdate(False);
      end;
    end;
  end;
  if Condition.Operator in [fcoInList, fcoNotInList] then
  begin
    Control.Canvas.Font.Assign(Control.FontValue);
    FAddButtonRect := Bounds(Values[Count - 1].ValueRect.Right +
      Control.Canvas.TextWidth(')0'), 0, Control.Canvas.TextWidth('000'),
      HeightOf(Condition.RowRect) - 4);
    CenterRectVert(Condition.RowRect, FAddButtonRect);
    // get ButtonState
    if not Control.ViewInfo.Enabled then
      FAddButtonState := cxbsDisabled
    else
      with Control.FFocusedInfo do
        if (Row = Condition) and (HitTest = fhtAddValue) then
          FAddButtonState := cxbsDefault
        else
          with Control.FHotTrack do
            if AHotTrack and (Row = Condition) and (HitTest = fhtAddValue) then
              FAddButtonState := cxbsHot
            else
              FAddButtonState := cxbsNormal
  end
  else
    FAddButtonRect := EmptyRect;
end;

procedure TcxValuesViewInfo.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    Values[I].Free;
  FList.Clear;
end;

procedure TcxValuesViewInfo.GetHitTestInfo(const P: TPoint;
  var HitInfo: TcxFilterControlHitTestInfo);
var
  I: Integer;
begin
  if PtInRect(AddButtonRect, P) then
    HitInfo.HitTest := fhtAddValue
  else
    for I := 0 to Count - 1 do
      if PtInRect(Values[I].ValueRect, P) then
      begin
        HitInfo.HitTest := fhtValue;
        HitInfo.ValueIndex := I;
        break;
      end;
end;

procedure TcxValuesViewInfo.RemoveValue(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;
  Values[AIndex].Free;
  FList.Delete(AIndex);
end;

function TcxValuesViewInfo.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TcxValuesViewInfo.UpdateEditorStyle(AStyle: TcxCustomEditStyle;
  AHightlited, AEnabled: Boolean);
const
  ButtonTransparency: array[Boolean] of TcxEditButtonTransparency =
    (ebtHideInactive, ebtNone);
begin
  if AEnabled then
    AStyle.StyleData.FontColor := Control.FontValue.Color
  else
    AStyle.StyleData.FontColor := clBtnShadow;
  AStyle.ButtonTransparency := ButtonTransparency[AHightlited];
  if AHightlited then
    AStyle.Color := clWindow
  else
    AStyle.Color := Control.ViewInfo.Painter.ContentColor;
end;

function TcxValuesViewInfo.GetControl: TcxCustomFilterControl;
begin
  Result := Condition.Control;
end;

function TcxValuesViewInfo.GetValue(Index: Integer): TcxValueInfo;
begin
  Result := TcxValueInfo(FList[Index]);
end;

function TcxValuesViewInfo.GetWidth: Integer;
begin
  with Condition do
    case Operator of
      fcoBetween, fcoNotBetween:
        Result := Values[Count - 1].ValueRect.Right - OperatorRect.Right;
      fcoInList, fcoNotInList:
        Result := FAddButtonRect.Right - OperatorRect.Right;
      else
        if HasDisplayValues then
          Result := Values[Count - 1].ValueRect.Right - OperatorRect.Right
        else
          Result := 0;
    end;
end;

{ TcxConditionViewInfo }

constructor TcxConditionViewInfo.Create(AControl: TcxCustomFilterControl;
  AParent: TcxCustomRowViewInfo; ACriteriaItem: TcxCustomFilterCriteriaItem);
var
  I, J: Integer;
  S: string;
begin
  inherited Create(AControl, AParent, ACriteriaItem);
  FValues := TcxValuesViewInfo.Create(Self);
  if ACriteriaItem <> nil then
  begin
    FItemLink := TcxFilterCriteriaItem(ACriteriaItem).ItemLink;
    FItemIndex := GetItemIndex;
    with Control do
    begin
      if HasItems and (FItemIndex >= 0) and (FItemIndex < FilterLink.Count) then
        FItemText := FilterLink.Captions[FItemIndex]
      else
        FilterControlError(cxGetResourceString(@cxSFilterErrorBuilding));
    end;
    with TcxFilterCriteriaItem(ACriteriaItem) do
    begin
      FOperator := GetFilterControlOperator(OperatorKind, ValueIsNull(Value));
      case FOperator of
        fcoBetween, fcoNotBetween, fcoInList, fcoNotInList:
          begin
            S := DisplayValue;
            J := 1;
            for I := VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do
            begin
              FValues.AddValue;
              FValues[I].Value := Value[I];
              FValues[I].ValueText := ExtractFilterDisplayValue(S, J);
            end;
          end;
        else
        begin
          FValues.AddValue;
          FValues[0].Value := Value;
          FValues[0].ValueText := DisplayValue;
        end;
      end;
    end;
    InternalInit;
  end
  else
  begin
    FItemIndex := -1;
    SetItem(-1);
  end;
end;

destructor TcxConditionViewInfo.Destroy;
begin
  FreeAndNil(FValues);
  FreeAndNil(FEditorProperties);
  FreeAndNil(ValueEditorData);
  inherited Destroy;
end;

procedure TcxConditionViewInfo.Calc(const ARowRect: TRect);
var
  ASize: TSize;
begin
  inherited Calc(ARowRect);
  with Control.Canvas do
  begin
    Font.Assign(Control.FontItem);
    ASize := TextExtent(FItemText);
    FItemRect := Bounds(ButtonRect.Right + 8, 0, ASize.cx + 2, ASize.cy + 2);
    CenterRectVert(FRowRect, FItemRect);
    Font.Assign(Control.FontCondition);
    FOperatorText := cxConditionText[Operator];
    ASize := TextExtent(FOperatorText);
    FOperatorRect := Bounds(FItemRect.Right + 8, 0, ASize.cx + 2, ASize.cy + 2);
    CenterRectVert(FRowRect, FOperatorRect);
    if HasDisplayValues then Values.Calc;
  end;
end;

procedure TcxConditionViewInfo.GetHitTestInfo(const P: TPoint;
  var HitInfo: TcxFilterControlHitTestInfo);
begin
  inherited;
  if HitInfo.HitTest = fhtNone then
    if PtInRect(FItemRect, P) then
      HitInfo.HitTest := fhtItem
    else
      if PtInRect(FOperatorRect, P) then
        HitInfo.HitTest := fhtOperator
      else
        Values.GetHitTestInfo(P, HitInfo);
end;

function TcxConditionViewInfo.GetProperties: TcxCustomEditProperties;
begin
  with Control do
  begin
    if HasItems and (ItemIndex >= 0) and (ItemIndex < FilterLink.Count) then
      Result := FilterLink.Properties[ItemIndex]
    else
      Result := GetDefaultProperties;
    if Result = nil then Result := GetDefaultProperties;
  end;
end;

function TcxConditionViewInfo.Ready: Boolean;
begin
  Result := (FItemText <> '') and (FOperatorText <> '');
end;

procedure TcxConditionViewInfo.AddValue;
begin
  Values.AddValue;
  Control.LayoutChanged;
end;

function TcxConditionViewInfo.GetWidth: Integer;
begin
  Result := inherited GetWidth + WidthOf(FItemRect) + WidthOf(FOperatorRect) +
    Values.Width + 8 * 2;
end;

function TcxConditionViewInfo.HasDisplayValues: Boolean;
begin
  Result := not (Operator in [fcoBlanks, fcoNonBlanks, fcoYesterday, fcoToday, fcoTomorrow,
    fcoLast7Days, fcoLastWeek, fcoLast14Days, fcoLastTwoWeeks, fcoLast30Days, fcoLastMonth, fcoLastYear, fcoInPast,
    fcoThisWeek, fcoThisMonth, fcoThisYear,
    fcoNext7Days, fcoNextWeek, fcoNext14Days, fcoNextTwoWeeks, fcoNext30Days, fcoNextMonth, fcoNextYear, fcoInFuture]);
end;

procedure TcxConditionViewInfo.InitValues(ASaveValue: Boolean);
begin
  if ASaveValue and HasDisplayValues then
  begin
    case Operator of
      fcoBetween, fcoNotBetween:
        begin
          while Values.Count > 2 do Values.RemoveValue(2);
          if Values.Count < 2 then Values.AddValue;
        end;
      fcoInList, fcoNotInList:;
      else
      begin
        while Values.Count > 1 do Values.RemoveValue(1);
        if Values.Count < 1 then Values.AddValue;
      end;
    end;
  end
  else
  begin
    Values.Clear;
    Values.AddValue;
    if Operator in [fcoBetween, fcoNotBetween] then Values.AddValue;
  end;
end;

procedure TcxConditionViewInfo.InternalInit;
var
  AEditClass: TcxCustomEditClass;
  AProperties: TcxCustomEditProperties;
begin
  FreeAndNil(ValueEditorData);
  FreeAndNil(FEditorProperties);
  AProperties := GetProperties;
  with Control do
  begin
    FEditorHelper := FilterEditsController.FindHelper(AProperties.ClassType);
    if FEditorHelper = nil then
      FEditorHelper := TcxFilterTextEditHelper;
    AEditClass := FEditorHelper.GetFilterEditClass;
    if AEditClass <> nil then
      FEditorProperties := AEditClass.GetPropertiesClass.Create(nil)
    else
      FEditorProperties := TcxCustomEditPropertiesClass(AProperties.ClassType).Create(nil);
    FEditorHelper.InitializeProperties(FEditorProperties, AProperties, True);
    FValueType := FilterLink.ValueTypes[FItemIndex];
    FSupportedOperators := FEditorHelper.GetSupportedFilterOperators(AProperties, FValueType, True);
  end;
  ValidateConditions;
end;

procedure TcxConditionViewInfo.SetItem(AIndex: Integer);
var
  AOperator: TcxFilterControlOperator;
  I: Integer;
  L: TStringList;
begin
  with Control, Control.FilterLink do
  begin
    if (AIndex >= 0) and (AIndex = ItemIndex) then Exit;
    if AIndex < 0 then
    begin
      AIndex := 0;
      if FSortItems then
      begin
        L := TStringList.Create;
        try
          L.BeginUpdate;
          for I := 0 to Count - 1 do
            L.AddObject(Captions[I], TObject(I));
          L.Sort;
          L.EndUpdate;
          if L.Count > 0 then AIndex := Integer(L.Objects[0]);
        finally
          L.Free;
        end;
      end;
    end;
    FItemIndex := AIndex;
    FItemLink  := ItemLinks[AIndex];
    FItemText  := Captions[AIndex];
    InternalInit;
    if fcoLike in FSupportedOperators then
      FOperator := fcoLike
    else
      for AOperator := Low(TcxFilterControlOperator) to High(TcxFilterControlOperator) do
        if AOperator in FSupportedOperators then
        begin
          FOperator := AOperator;
          break;
        end;
    InitValues(False);
    Values.Calc;
    if FValueEditor <> nil then
      FInplaceEditors.RemoveItem(FValueEditor.ActiveProperties);
  end;
end;

procedure TcxConditionViewInfo.ValidateConditions;
begin
  Control.ValidateConditions(FSupportedOperators);
end;

function TcxConditionViewInfo.GetItemIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  with Control do
    for I := 0 to FilterLink.Count - 1 do
      if FilterLink.ItemLinks[I] = FItemLink then
      begin
        Result := I;
        break;
      end;
end;

{ TcxCustomFilterControl }

constructor TcxCustomFilterControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  WantTabs := False;
  FCriteria := GetFilterControlCriteriaClass.Create(Self);
  FRoot := TcxGroupViewInfo.Create(Self, nil, FCriteria.Root);
  FRows := TList.Create;
  FRows.Add(FRoot);
  FViewInfo := GetViewInfoClass.Create(Self);
  CreateFonts;
  CreateInternalControls;
  CheckInplaceControlsColor;
  UpdateBoundsRect(Rect(0, 0, 300, 200));
  FFocusedInfo.Row := FRoot;
  FFocusedInfo.HitTest := fhtBoolOperator;
  FHotTrackOnUnfocused := True;
  FNullString := cxGetResourceString(@cxSFilterControlNullString);
  FShowLevelLines := True;
  cxFormatController.AddListener(Self);
  ParentColor := False;
  Color := clBtnFace;
end;

destructor TcxCustomFilterControl.Destroy;
var
  AFont: TcxFilterControlFont;
begin
  cxFormatController.RemoveListener(Self);
  EndMouseTracking(Self);
  DestroyInternalControls;
  FreeAndNil(FCriteria);
  FreeAndNil(FViewInfo);
  FreeAndNil(FRows);
  FreeAndNil(FRoot);
  for AFont := fcfBoolOperator to fcfValue do FreeAndNil(FFonts[AFont]);
  inherited Destroy;
end;

procedure TcxCustomFilterControl.ApplyFilter;
begin
  DoApplyFilter;
end;

procedure TcxCustomFilterControl.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxCustomFilterControl.Clear;
begin
  ValueEditorHide(False);
  BeginUpdate;
  try
    ClearRows;
    FCriteria.Clear;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomFilterControl.EndUpdate;
begin
  Dec(FLockCount);
  LayoutChanged;
end;

function TcxCustomFilterControl.IsValid: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to RowCount - 1 do
    if not Rows[I].Ready then
    begin
      Result := False;
      break;
    end;
end;

function TcxCustomFilterControl.HasItems: Boolean;
begin
  Result := (FilterLink <> nil) and (FilterLink.Count > 0);
end;

procedure TcxCustomFilterControl.LayoutChanged;
begin
  if (FLockCount <> 0) or IsDestroying or IsLoading or not HandleAllocated or
    ((FComboBox <> nil) and FComboBox.DroppedDown) then Exit;
  Inc(FLockCount);
  try
    DoLayoutChange;
  finally
    Dec(FLockCount);
  end;
end;

procedure TcxCustomFilterControl.Localize;
var
  AOperator: TcxFilterControlOperator;
  ABoolOperator: TcxFilterBoolOperatorKind;
begin
  RefreshMenuCaptions;
  FRoot.Group.Caption := cxGetResourceString(@cxSFilterRootGroupCaption);
  FViewInfo.FAddConditionCaption := cxGetResourceString(@cxSFilterFooterAddCondition);
  for AOperator := Low(AOperator) to High(AOperator) do
    cxConditionText[AOperator] := GetFilterControlOperatorText(AOperator);
  for ABoolOperator := fboAnd to fboNotOr do
    cxBoolOperatorText[ABoolOperator] := cxStrFromBoolOperator(ABoolOperator);
  FNullString := cxGetResourceString(@cxSFilterControlNullString);
  LayoutChanged;
end;

procedure TcxCustomFilterControl.LoadFromFile(const AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmOpenRead);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TcxCustomFilterControl.LoadFromStream(AStream: TStream);
begin
  if not HasItems then
    FilterControlError(cxGetResourceString(@cxSFilterErrorBuilding));
  Clear;
  ReadData(AStream);
  BuildFromCriteria;
end;

procedure TcxCustomFilterControl.SaveToFile(const AFileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TcxCustomFilterControl.TranslationChanged;
begin
  Localize;
end;

procedure TcxCustomFilterControl.SaveToStream(AStream: TStream);
begin
  BuildFromRows;
  WriteData(AStream);
end;

procedure TcxCustomFilterControl.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
//TODO design-time editor ??  
//  Filer.DefineBinaryProperty('FilterCriteria', ReadData, WriteData, FCriteria.Root.Count > 0);
end;

procedure TcxCustomFilterControl.Loaded;
begin
  inherited Loaded;
  LayoutChanged;
end;

procedure TcxCustomFilterControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_LEFT: FocusPrev(False);
    VK_RIGHT: FocusNext(False);
    VK_TAB:
      begin
        if ssCtrl in Shift then
           TWinControlAccess(Parent).SelectNext(Self, not (ssShift in Shift), True)
        else
          if Shift = [] then
            FocusNext(True)
          else
            if ssShift in Shift then FocusPrev(True);
        Key := 0;
      end;
    VK_UP: FocusUp(False);
    VK_DOWN: FocusDown(False);
    VK_DELETE: if ssCtrl in Shift then Remove;
    VK_INSERT: if Shift = [] then AddCondition(FocusedRow);
  end;
end;

procedure TcxCustomFilterControl.KeyPress(var Key: Char);
begin
  inherited;
  if (Key = #13) or (Key = ' ') then
    ProcessHitTest(FFocusedInfo.HitTest, False)
  else
    if (Key <> #27) and (FFocusedInfo.HitTest = fhtValue) then
      SelectValue(aveKey, Key);
end;

procedure TcxCustomFilterControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FWasError or not HasItems then Exit;
  ViewInfo.GetHitTestInfo(Shift, Point(X, Y), FHotTrack);
  if (FHotTrack.HitTest <> fhtNone) and (FState = fcsNormal) and (Button = mbLeft) then
  begin
    FFocusedInfo := FHotTrack;
    EnsureRowVisible;
    ProcessHitTest(FHotTrack.HitTest, True);
  end;
end;

procedure TcxCustomFilterControl.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  Cursors: array[Boolean] of TCursor = (crDefault, crHandPoint);
  NonHot = [fhtNone, fhtBoolOperator, fhtItem, fhtOperator];
var
  APrevHotTrack: TcxFilterControlHitTestInfo;

  function SameRow: Boolean;
  begin
    Result := APrevHotTrack.Row = FHotTrack.Row;
  end;

  function SameHitTest: Boolean;
  begin
    Result := (APrevHotTrack.HitTest = FHotTrack.HitTest) and
      (APrevHotTrack.ValueIndex = FHotTrack.ValueIndex);
  end;

begin
  inherited MouseMove(Shift, X, Y);
  BeginMouseTracking(Self, Bounds, Self);
  APrevHotTrack := FHotTrack;
  ViewInfo.GetHitTestInfo(Shift, Point(X, Y), FHotTrack);
  Cursor := Cursors[HasHotTrack and (FHotTrack.HitTest <> fhtNone)];
  if (APrevHotTrack.HitTest in NonHot) and (FHotTrack.HitTest in NonHot) then Exit;
  if SameRow then
    if SameHitTest then Exit else ViewInfo.InvalidateRow(FHotTrack.Row)
  else
  begin
    if not (APrevHotTrack.HitTest in NonHot) then
      ViewInfo.InvalidateRow(APrevHotTrack.Row);
    if not (FHotTrack.HitTest in NonHot) then
      ViewInfo.InvalidateRow(FHotTrack.Row);
  end;
  ViewInfo.Update;
end;

procedure TcxCustomFilterControl.Paint;
begin
  ViewInfo.Paint;
end;

procedure TcxCustomFilterControl.SetEnabled(Value: Boolean);
begin
  inherited;
  LayoutChanged;
end;

procedure TcxCustomFilterControl.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  LayoutChanged;
end;

procedure TcxCustomFilterControl.BoundsChanged;
begin
  inherited BoundsChanged;
  if HandleAllocated then
    LayoutChanged;
end;

procedure TcxCustomFilterControl.DoLayoutChange;

  procedure CheckVertical;
  begin
    while (TopVisibleRow > 0) and
      (ClientBounds.Bottom - ViewInfo.AddConditionRect.Bottom >= ViewInfo.RowHeight + 2) do
    begin
      Dec(FTopVisibleRow);
      ViewInfo.Calc;
    end;
  end;

  procedure CheckHorizontal;
  var
    ADelta: Integer;
  begin
    ADelta := ClientBounds.Right - (ViewInfo.MaxRowWidth - LeftOffset) - 2;
    if (LeftOffset > 0) and (ADelta > 0) then
    begin
      FLeftOffset := Max(0, FLeftOffset - ADelta);
      ViewInfo.Calc;
    end;
  end;

begin
  ViewInfo.Calc;
  CheckVertical;
  CheckHorizontal;
  UpdateScrollBars;
  Invalidate;
end;

procedure TcxCustomFilterControl.FocusChanged;
begin
  inherited FocusChanged;
  ViewInfo.GetHitTestInfo([], ScreenToClient(GetMouseCursorPos), FHotTrack);
  LayoutChanged;
end;

procedure TcxCustomFilterControl.FontChanged;
var
  AFont: TcxFilterControlFont;
begin
  inherited;
  if not IsLoading or (csReading in ComponentState) or IsDesigning then
  begin
    BeginUpdate;
    try
      for AFont := fcfBoolOperator to fcfValue do
      begin
        FFonts[AFont].Name := Font.Name;
        FFonts[AFont].Height := Font.Height;
        FFonts[AFont].Charset := Font.Charset;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

function TcxCustomFilterControl.GetBorderSize: Integer;
begin
  Result := LookAndFeel.Painter.BorderSize;
end;

procedure TcxCustomFilterControl.InitControl;
begin
  inherited;
  FComboBox.Parent := Self;
  Localize;
end;

procedure TcxCustomFilterControl.InitScrollBarsParameters;
var
  APageSize: Integer;
begin
  if ViewInfo.RowHeight = 0 then Exit;
  APageSize := HeightOf(ClientBounds) div ViewInfo.RowHeight;
  SetScrollBarInfo(sbVertical, 0, RowCount - 1, 1, APageSize - 1, TopVisibleRow, True, True);
  SetScrollBarInfo(sbHorizontal, 0, ViewInfo.MaxRowWidth, 1,
    WidthOf(ClientBounds), FLeftOffset, True, True);
end;

procedure TcxCustomFilterControl.LookAndFeelChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  inherited;
  LayoutChanged;
  CheckInplaceControlsColor;
end;

procedure TcxCustomFilterControl.MouseEnter(AControl: TControl);
begin
  inherited MouseEnter(AControl);
  BeginMouseTracking(Self, Bounds, Self);
end;

procedure TcxCustomFilterControl.MouseLeave(AControl: TControl);
begin
  inherited MouseLeave(AControl);
  EndMouseTracking(Self);
  FHotTrack.HitTest := fhtNone;
  LayoutChanged;
end;

procedure TcxCustomFilterControl.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);

  procedure ScrollVertical;
  begin
    case AScrollCode of
      scLineUp:
        TopVisibleRow := TopVisibleRow - 1;
      scLineDown:
        TopVisibleRow := TopVisibleRow + 1;
      scTrack:
        TopVisibleRow := AScrollPos;
      scPageUp:
        TopVisibleRow := TopVisibleRow - VScrollBar.PageSize;
      scPageDown:
        TopVisibleRow := TopVisibleRow + VScrollBar.PageSize;
    end;
    AScrollPos := TopVisibleRow;
  end;

  procedure ScrollHorizontal;
  begin
    case AScrollCode of
      scLineUp:
        LeftOffset := LeftOffset - 8;
      scLineDown:
        LeftOffset := LeftOffset + 8;
      scTrack:
        LeftOffset := AScrollPos;
      scPageUp:
        LeftOffset := LeftOffset - HScrollBar.PageSize;
      scPageDown:
        LeftOffset := LeftOffset + HScrollBar.PageSize;
    end;
    AScrollPos := LeftOffset;
  end;

begin
  if AScrollBarKind = sbVertical then
    ScrollVertical
  else
    ScrollHorizontal;
end;

procedure TcxCustomFilterControl.AddCondition(ARow: TcxCustomRowViewInfo);
var
  ARowParent: TcxCustomRowViewInfo;
begin
  if not HasItems then Exit;
  if ARow <> nil then ARowParent := ARow else ARowParent := Rows[RowCount - 1];
  while not (ARowParent is TcxGroupViewInfo) do
    ARowParent := ARowParent.Parent;
  with FFocusedInfo do
    Row := TcxConditionViewInfo.Create(Self, ARowParent, nil);
  RecalcRows;
  FFocusedInfo.HitTest := fhtAddCondition; // make sure last button visible
  ViewInfo.Calc;
  UpdateScrollBars;
  EnsureRowVisible;
  FFocusedInfo.HitTest := fhtItem;
  ViewInfo.CalcFocusRect;
  Invalidate;
end;

procedure TcxCustomFilterControl.AddGroup;
var
  AGroup: TcxGroupViewInfo;
  ARowParent: TcxCustomRowViewInfo;
begin
  if not HasItems then Exit;
  ARowParent := FocusedRow;
  while not (ARowParent is TcxGroupViewInfo) do
    ARowParent := ARowParent.Parent;
  AGroup := TcxGroupViewInfo.Create(Self, ARowParent, nil);
  RecalcRows;
  AddCondition(AGroup);
end;

procedure TcxCustomFilterControl.AddValue;
begin
  if not HasItems then Exit;
  FocusedRow.Condition.Values.AddValue;
  FFocusedInfo.HitTest := fhtValue;
  FFocusedInfo.ValueIndex := FocusedRow.Condition.Values.Count - 1;
  ViewInfo.Calc;
  FLeftOffset := Max((ViewInfo.MaxRowWidth + 2) - ClientBounds.Right, 0);
  LayoutChanged;
end;

procedure TcxCustomFilterControl.ClearRows;
begin
  BeginUpdate;
  try
    with FRoot.Group do
    begin
      while RowCount > 0 do Rows[0].Free;
      FRows.Clear;
    end;
    FRows.Clear;
    FRows.Add(FRoot);
    FFocusedInfo.Row := FRoot;
    FRoot.Group.BoolOperator := fboAnd;
    FFocusedInfo.HitTest := fhtBoolOperator;
    FTopVisibleRow := 0;
    FLeftOffset := 0;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomFilterControl.Remove;
begin
  if (FFocusedInfo.HitTest = fhtValue) and
     (FocusedRow.Condition.Operator in [fcoInList, fcoNotInList]) and
     (FocusedRow.Condition.Values.Count > 1) then
    RemoveValue
  else
    RemoveRow;
end;

procedure TcxCustomFilterControl.RemoveRow;
var
  ARow: TcxCustomRowViewInfo;
begin
  if FocusedRow = FRoot then Exit;
  ARow := FocusedRow;
  // remove Group if last child
  while (ARow.Parent <> FRoot) and (ARow.Parent.Group.RowCount = 1) do
    ARow := ARow.Parent;
  FFocusedInfo.Row := Rows[FRows.IndexOf(ARow) - 1];
  FreeAndNil(ARow);
  if FocusedRow is TcxGroupViewInfo then
    FFocusedInfo.HitTest := fhtBoolOperator
  else
    FFocusedInfo.HitTest := fhtItem;
  FHotTrack.Row := nil;
  RecalcRows;
  ViewInfo.Calc;
  UpdateScrollBars;
  EnsureRowVisible;
end;

procedure TcxCustomFilterControl.RemoveValue;
begin
  FocusedRow.Condition.Values.RemoveValue(FFocusedInfo.ValueIndex);
  if FFocusedInfo.ValueIndex > 0 then Dec(FFocusedInfo.ValueIndex);
  ViewInfo.Calc;
  UpdateScrollBars;
  EnsureRowVisible;
end;

// navigation
procedure TcxCustomFilterControl.FocusDown(ATab: Boolean);
begin
  if FocusedRow <> Rows[RowCount - 1] then
    if ATab then
    begin
      FFocusedInfo.Row := Rows[FocusedRowIndex + 1];
      RowNavigate(fhtButton);
    end
    else
      FocusedRow := Rows[FocusedRowIndex + 1]
  else
    RowNavigate(fhtAddCondition);
end;

procedure TcxCustomFilterControl.FocusNext(ATab: Boolean);
begin
  case FFocusedInfo.HitTest of
    fhtAddCondition: if not ATab then FocusedRow := Rows[RowCount - 1];
    fhtAddValue, fhtBoolOperator:
      if ATab then FocusDown(ATab);
    fhtButton:
      if FocusedRow is TcxGroupViewInfo then
        RowNavigate(fhtBoolOperator)
      else
        RowNavigate(fhtItem);
    fhtOperator:
      if FocusedRow.Condition.HasDisplayValues then
      begin
        FFocusedInfo.ValueIndex := 0;
        RowNavigate(fhtValue);
      end
      else
        if ATab then FocusDown(ATab);
    fhtItem: RowNavigate(fhtOperator);
    fhtValue:
      begin
        if (FocusedRow.Condition.Values.Count - 1) > FFocusedInfo.ValueIndex then
        begin
          Inc(FFocusedInfo.ValueIndex);
          RowNavigate(fhtValue);
        end
        else
          if FocusedRow.Condition.Operator in [fcoInList, fcoNotInList] then
            RowNavigate(fhtAddValue)
          else
            if ATab then FocusDown(ATab);
      end;
  end;
end;

procedure TcxCustomFilterControl.FocusPrev(ATab: Boolean);
begin
  case FFocusedInfo.HitTest of
    fhtAddCondition: FocusUp(ATab);
    fhtButton: if ATab then FocusUp(ATab);
    fhtOperator: RowNavigate(fhtItem);
    fhtItem, fhtBoolOperator: RowNavigate(fhtButton);
    fhtValue:
      begin
        if FFocusedInfo.ValueIndex > 0 then
        begin
          Dec(FFocusedInfo.ValueIndex);
          RowNavigate(fhtValue);
        end
        else RowNavigate(fhtOperator);
      end;
    fhtAddValue: RowNavigate(fhtValue);
  end;
end;

procedure TcxCustomFilterControl.FocusUp(ATab: Boolean);

  procedure Select(ARow: TcxCustomRowViewInfo);
  const
    HitItem: array[Boolean] of TcxFilterControlHitTest = (fhtValue, fhtAddValue);
  begin
    if ATab then
    begin
      FFocusedInfo.Row := ARow;
      if FocusedRow is TcxGroupViewInfo then
        RowNavigate(fhtBoolOperator)
      else
        with FocusedRow.Condition do
          if HasDisplayValues then
          begin
            FFocusedInfo.ValueIndex := Values.Count - 1;
            RowNavigate(HitItem[Operator in [fcoInList, fcoNotInList]]);
          end
          else RowNavigate(fhtOperator)
    end
    else FocusedRow := ARow;
  end;

begin
  if FFocusedInfo.HitTest = fhtAddCondition then
    Select(Rows[RowCount - 1])
  else
    if FocusedRow <> FRoot then
      Select(Rows[FocusedRowIndex - 1]);
end;

procedure TcxCustomFilterControl.RowNavigate(AElement: TcxFilterControlHitTest; ACellIndex: Integer = -1);
begin
  FFocusedInfo.HitTest := AElement;
  if (FocusedRow is TcxConditionViewInfo) and (ACellIndex >= 0) and
      (ACellIndex < TcxConditionViewInfo(FocusedRow).Values.Count) then
    FFocusedInfo.ValueIndex := ACellIndex;
  ViewInfo.Calc;
  EnsureRowVisible;
end;

procedure TcxCustomFilterControl.ValueEditorHide(AAccept: Boolean);
var
  V: Variant;
  S: TCaption;
begin
  FWasError := False;
  State := fcsNormal;
  if FValueEditor = nil then Exit;
  if AAccept then
  begin
    if not FValueEditor.Deactivate then raise EAbort.Create('');
    with FocusedRow.Condition, Values[FFocusedInfo.ValueIndex] do
    begin
      EditorHelper.GetFilterValue(FValueEditor, GetProperties, V, S);
      try
        FilterControlValidateValue(FValueEditor, V, Operator, ValueType, EditorHelper);
      except
        FWasError := True;
        raise
      end;
      FValue := V;
      FValueText := S;
    end;
  end;
  if FValueEditor.Focused and Focused then
  begin
    FValueEditor.EditModified := False;
    FValueEditor.OnFocusChanged := nil;
  end;
  FValueEditor.Parent := nil;
  FValueEditor := nil;
  EnsureRowVisible;
end;

procedure TcxCustomFilterControl.EnsureRowVisible;

  function GetFocusedRect: TRect;
  begin
    with FFocusedInfo do
      case HitTest of
        fhtButton:
          begin
            Result := Row.ButtonRect;
            if Row = FRoot then Dec(Result.Left, 4);
          end;
        fhtBoolOperator: Result := Row.Group.BoolOperatorRect;
        fhtItem: Result := Row.Condition.ItemRect;
        fhtOperator: Result := Row.Condition.OperatorRect;
        fhtValue: Result := Row.Condition.Values[ValueIndex].ValueRect;
        fhtAddCondition: Result := ViewInfo.AddConditionRect;
        fhtAddValue: Result := Row.Condition.Values.AddButtonRect;
      else
        Result := EmptyRect;
      end;
  end;

var
  AIndex, ALeft, ABottom: Integer;
  R: TRect;
begin
  AIndex := FocusedRowIndex;
  if AIndex < TopVisibleRow then
    FTopVisibleRow := AIndex
  else
  begin
    if FFocusedInfo.HitTest = fhtAddCondition then
      ABottom := ViewInfo.AddConditionRect.Bottom
    else
      ABottom := FocusedRow.RowRect.Bottom;
    while (ABottom > ClientBounds.Bottom) and (FTopVisibleRow < RowCount) do
    begin
      Dec(ABottom, ViewInfo.RowHeight);
      Inc(FTopVisibleRow);
    end;
  end;
  R := GetFocusedRect;
  ALeft := R.Left;
  if R.Right >= ClientBounds.Right then OffsetRect(R, ClientBounds.Right - R.Right - 2, 0);
  if R.Left < ClientBounds.Left then OffsetRect(R, ClientBounds.Left - R.Left, 0);
  Inc(FLeftOffset, ALeft - R.Left);
  ViewInfo.Calc;
  UpdateScrollBars;
  Invalidate;
end;

procedure TcxCustomFilterControl.BuildFromCriteria;

  procedure Build(ACriteriaList: TcxFilterCriteriaItemList; ARow: TcxCustomRowViewInfo);
  var
    I: Integer;
  begin
    with ACriteriaList do
    begin
      ARow.Group.BoolOperator := BoolOperatorKind;
      for I := 0 to Count - 1 do
        if Items[I].IsItemList then
          Build(TcxFilterCriteriaItemList(Items[I]),
            TcxGroupViewInfo.Create(Self, ARow, Items[I]))
        else
          TcxConditionViewInfo.Create(Self, ARow, Items[I]);
    end;
  end;

begin
  BeginUpdate;
  try
    ClearRows;
    Build(FCriteria.Root, FRoot);
    RecalcRows;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomFilterControl.BuildFromRows;

  function GetValueString(AValueInfo: TcxValueInfo; ASoftNull: Boolean = False): string;
  begin
    if VarIsNull(AValueInfo.Value) or
      (ASoftNull and VarIsStr(AValueInfo.Value) and (AValueInfo.Value = '')) then
        Result := cxGetResourceString(@cxSFilterBlankCaption)
    else
      Result := AValueInfo.ValueText;
  end;

  procedure AddCondition(ACriteriaList: TcxFilterCriteriaItemList; ACondition: TcxConditionViewInfo);
  var
    I: Integer;
    AValue: Variant;
    AText: string;
  begin
    with ACondition do
      case Operator of
        fcoEqual, fcoNotEqual:
          ACriteriaList.AddItem(ItemLink, GetFilterOperatorKind(Operator),
            Values[0].Value, GetValueString(Values[0]));
        fcoBetween, fcoNotBetween:
          begin
            // sort between
            if VarCompare(Values[0].Value, Values[1].Value) < 0 then
            begin
              AValue := VarBetweenArrayCreate(Values[0].Value, Values[1].Value);
              AText := GetValueString(Values[0]) + ';' + GetValueString(Values[1]);
            end
            else
            begin
              AValue := VarBetweenArrayCreate(Values[1].Value, Values[0].Value);
              AText := GetValueString(Values[1]) + ';' + GetValueString(Values[0]);
            end;
            ACriteriaList.AddItem(ItemLink, GetFilterOperatorKind(Operator), AValue, AText);
          end;
        fcoInList, fcoNotInList:
          begin
            AValue := VarListArrayCreate(Values[0].Value);
            AText := GetValueString(Values[0]);
            for I := 1 to Values.Count - 1 do
            begin
              VarListArrayAddValue(AValue, Values[I].Value);
              AText := AText + ';' + GetValueString(Values[I]);
            end;
            ACriteriaList.AddItem(ItemLink, GetFilterOperatorKind(Operator), AValue, AText);
          end;
        fcoBlanks, fcoNonBlanks:
          ACriteriaList.AddItem(ItemLink, GetFilterOperatorKind(Operator),
            Values[0].Value, cxGetResourceString(@cxSFilterBlankCaption));
        else
          ACriteriaList.AddItem(ItemLink, GetFilterOperatorKind(Operator),
            Values[0].Value, GetValueString(Values[0], True));
      end;
  end;

  procedure Build(ACriteriaList: TcxFilterCriteriaItemList; ARow: TcxCustomRowViewInfo);
  var
    I: Integer;
  begin
    if ARow is TcxGroupViewInfo then
    begin
      ACriteriaList.BoolOperatorKind := ARow.Group.BoolOperator;
      for I := 0 to ARow.Group.RowCount - 1 do
        if ARow.Group.Rows[I] is TcxGroupViewInfo then
          Build(ACriteriaList.AddItemList(fboAnd), ARow.Group.Rows[I])
        else
          AddCondition(ACriteriaList, ARow.Group.Rows[I].Condition);
    end
    else
      AddCondition(ACriteriaList, ARow.Condition);
  end;

begin
  ValueEditorHide(True);
  if not IsValid then Exit;
  with FCriteria do
  begin
    BeginUpdate;
    try
      Clear;
      Build(Root, Self.FRoot);
      Prepare;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomFilterControl.CheckInplaceControlsColor;
begin
  FComboBox.Style.Color := ViewInfo.Painter.ContentColor;
end;

procedure TcxCustomFilterControl.CreateInternalControls;

  function NewMenuItem(ATag: Integer): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    with Result do
    begin
      if ATag <> 2 then ImageIndex := ATag;
      Tag := ATag;
      OnClick := PopupMenuClick;
    end;
  end;

  procedure CreateComboBox;
  begin
    FComboBox := TcxComboBox.Create(nil, True);
    with FComboBox do
    begin
      Style.LookAndFeel.MasterLookAndFeel := Self.LookAndFeel;
      Visible := False;
      ParentColor := True;
      OnExit := ComboBoxExit;
      OnKeyPress := ComboBoxKeyPress;
      OnKeyDown := ComboBoxKeyDown;
    end;
    with FComboBox.Properties do
    begin
      Buttons[0].Visible := False;
      DropDownListStyle := lsFixedList;
      OnPopup := ComboBoxPopup;
      OnCloseUp := ComboBoxCloseUp;
    end;
  end;

var
  I: Integer;
begin
  CreateComboBox;
  // style for Values
  FValueEditorStyle := TcxCustomEditStyle.Create(Self, True);
  with FValueEditorStyle do
  begin
    Font := FontValue;
    LookAndFeel.MasterLookAndFeel := Self.LookAndFeel;
    ButtonTransparency := ebtHideUnselected;
  end;
  // action menu
  FActionMenu := TPopupMenu.Create(Self);
  for I := 0 to 3 do
    FActionMenu.Items.Add(NewMenuItem(I));
  // editors pool
  FInplaceEditors := TcxInplaceEditList.Create(Self);
  FTextEditProperties := TcxTextEditProperties.Create(nil);
end;

procedure TcxCustomFilterControl.DestroyInternalControls;
begin
  FreeAndNil(FInplaceEditors);
  FreeAndNil(FValueEditorStyle);
  FreeAndNil(FTextEditProperties);
  FreeAndNil(FActionMenu);
  FreeAndNil(FComboBox);
end;

procedure TcxCustomFilterControl.DoApplyFilter;
var
  ANeedSynchronize: Boolean;
begin
  if (FilterLink <> nil) and (FilterLink.Criteria <> nil) then
  begin
    BuildFromRows;
    ANeedSynchronize := FCriteria <> FilterLink.Criteria;
    FilterLink.Criteria.BeginUpdate;
    try
      if ANeedSynchronize then
        FilterLink.Criteria.AssignItems(FCriteria);
      if Assigned(FOnApplyFilter) then FOnApplyFilter(Self);
    finally
      FilterLink.Criteria.EndUpdate;
      if ANeedSynchronize then
        FCriteria.Assign(FilterLink.Criteria);
      BuildFromCriteria;
    end;  
  end;
end;

function TcxCustomFilterControl.GetDefaultProperties: TcxCustomEditProperties;
begin
  Result := FTextEditProperties;
end;

function TcxCustomFilterControl.GetDefaultPropertiesViewInfo: TcxCustomEditViewInfo;
begin
  Result := TcxCustomEditViewInfo(GetDefaultProperties.GetViewInfoClass.Create);
end;

function TcxCustomFilterControl.GetFilterControlCriteriaClass: TcxFilterControlCriteriaClass;
begin
  Result := TcxFilterControlCriteria;
end;

function TcxCustomFilterControl.GetViewInfoClass: TcxFilterControlViewInfoClass;
begin
  Result := TcxFilterControlViewInfo;
end;

function TcxCustomFilterControl.HasFocus: Boolean;
begin
  Result := IsFocused or ((FValueEditor <> nil) and FValueEditor.IsFocused);
end;

function TcxCustomFilterControl.HasHotTrack: Boolean;
begin
  Result := Enabled and (FHotTrackOnUnfocused or HasFocus) and HasItems;
end;

procedure TcxCustomFilterControl.RefreshProperties;
var
  I: Integer;
  ARow: TcxCustomRowViewInfo;
begin
  if RowCount = 0 then Exit;
  for I := 0 to RowCount - 1 do
  begin
    ARow := GetRow(I);
    if ARow is TcxConditionViewInfo then
      ARow.Condition.InternalInit;
  end;
  LayoutChanged;
end;

procedure TcxCustomFilterControl.FillFilterItemList(AStrings: TStrings);
var
  I: Integer;
  AProperties: TcxCustomEditProperties;
begin
  if (AStrings = nil) or not HasItems then Exit;
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    with FilterLink do
      for I := 0 to Count - 1 do
      begin
        AProperties := Properties[I];
        if (AProperties <> nil) and (esoFiltering in AProperties.GetSupportedOperations) then
          AStrings.AddObject(Captions[I], TObject(I));
      end;
  finally
    AStrings.EndUpdate;
  end;
end;

procedure TcxCustomFilterControl.FillConditionList(AStrings: TStrings);
var
  AOperator: TcxFilterControlOperator;
begin
  if (AStrings = nil) or not HasItems then Exit;
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    FocusedRow.Condition.ValidateConditions;
    for AOperator := Low(AOperator) to High(AOperator) do
      if AOperator in FocusedRow.Condition.SupportedOperators then
        AStrings.AddObject(cxConditionText[AOperator], TObject(AOperator));
  finally
    AStrings.EndUpdate;
  end;
end;

procedure TcxCustomFilterControl.ValidateConditions(
  var SupportedOperations: TcxFilterControlOperators);
begin
  if not FCriteria.SupportedLike then
    SupportedOperations := SupportedOperations - [fcoLike, fcoNotLike];
end;

procedure TcxCustomFilterControl.CorrectOperatorClass(
  var AOperatorClass: TcxFilterOperatorClass);
begin
end;

function TcxCustomFilterControl.GetFilterCaption: string;
begin
  BuildFromRows;
  Result := FCriteria.FilterCaption
end;

function TcxCustomFilterControl.GetFilterLink: IcxFilterControl;
begin
  Result := nil;
end;

function TcxCustomFilterControl.GetFilterText: string;
begin
  BuildFromRows;
  Result := FCriteria.FilterText
end;

procedure TcxCustomFilterControl.SelectAction;
var
  P: TPoint;
begin
  if not HasItems then Exit;
  with FocusedRow.ButtonRect do
    P := ClientToScreen(Point(Left, Bottom));
  FState := fcsSelectingAction;
  if FocusedRow <> FRoot then
  begin
    FActionMenu.Items[2].Visible := True;
    FActionMenu.Items[3].Visible := True;
    FActionMenu.Items[3].Caption := cxGetResourceString(@cxSFilterRemoveRow);
  end
  else
  begin
    FActionMenu.Items[2].Visible := FRoot.Group.RowCount > 0;
    FActionMenu.Items[3].Visible := FRoot.Group.RowCount > 0;
    FActionMenu.Items[3].Caption := cxGetResourceString(@cxSFilterClearAll);
  end;
  FActionMenu.Popup(P.X, P.Y);
  FState := fcsNormal;
end;

procedure TcxCustomFilterControl.SelectBoolOperator;
var
  ABoolOperator: TcxFilterBoolOperatorKind;
begin
  if not HasItems then Exit;
  State := fcsSelectingBoolOperator;
  with FComboBox do
  begin
    Properties.Items.Clear;
    Properties.Sorted := False;
    Style.Font.Assign(FontBoolOperator);
    for ABoolOperator := fboAnd to fboNotOr do
      Properties.Items.AddObject(cxBoolOperatorText[ABoolOperator], TObject(ABoolOperator));
    with FocusedRow.Group do
      DoComboDropDown(BoolOperatorRect, BoolOperatorText);
  end;
end;

procedure TcxCustomFilterControl.SelectCondition;
begin
  if not HasItems then Exit;
  State := fcsSelectingCondition;
  with FComboBox do
  begin
    Style.Font.Assign(FontCondition);//
    Properties.Sorted := False;
    FillConditionList(Properties.Items);
    with FocusedRow.Condition do
      DoComboDropDown(OperatorRect, OperatorText);
  end;
end;

procedure TcxCustomFilterControl.SelectItem;
begin
  if not HasItems then Exit;
  with FComboBox do
  begin
    Style.Font.Assign(FontItem);
    State := fcsSelectingItem;
    FillFilterItemList(Properties.Items);
    Properties.Sorted := FSortItems;
    with FocusedRow.Condition do
      DoComboDropDown(ItemRect, ItemText);
  end;
end;

procedure TcxCustomFilterControl.SelectValue(
  AActivateKind: TcxActivateValueEditKind; AKey: Char);
begin
  if not HasItems then Exit;
  EnsureRowVisible;
  ValueEditorInit;
  with FValueEditor do
  begin
    SendToBack;
    case AActivateKind of
      aveMouse:
        with FocusedRow.Condition do
          ActivateByMouse(FFocusedInfo.Shift, FFocusedInfo.Mouse.X, FFocusedInfo.Mouse.Y, ValueEditorData);
      aveKey:
        with FocusedRow.Condition do
          ActivateByKey(AKey, ValueEditorData);
    else
      with FocusedRow.Condition do
        Activate(ValueEditorData);
    end;
  end;
end;

// IcxMouseTrackingCaller
procedure TcxCustomFilterControl.DoMouseLeave;
begin
  MouseLeave(nil);
end;

// IcxFormatContollerListener
procedure TcxCustomFilterControl.FormatChanged;
begin
  LayoutChanged;
end;

procedure TcxCustomFilterControl.CreateFonts;
var
  AFont: TcxFilterControlFont;
begin
  for AFont := fcfBoolOperator to fcfValue do
  begin
    FFonts[AFont] := TFont.Create;
    FFonts[AFont].Color := cxFilterControlFontColors[AFont];
    if AFont <> fcfValue then
      FFonts[AFont].Style := [fsUnderline];
    FFonts[AFont].OnChange := DoFontChanged;
  end;
end;

procedure TcxCustomFilterControl.DoFontChanged(Sender: TObject);
begin
  LayoutChanged;
end;

function TcxCustomFilterControl.GetFont(Index: Integer): TFont;
begin
  Result := FFonts[TcxFilterControlFont(Index)];
end;

function TcxCustomFilterControl.IsFontStored(Index: Integer): Boolean;
const
  Styles: array[Boolean] of TFontStyles = ([fsUnderline], []);
begin
  with FFonts[TcxFilterControlFont(Index)] do
  begin
    Result := (CompareText(Name, Font.Name) <> 0) or (Height <> Font.Height) or
      (Color <> cxFilterControlFontColors[TcxFilterControlFont(Index)]) or
      (Charset <> Font.Charset) or (Style <> Styles[Index = Integer(fcfValue)]);
  end;
end;

procedure TcxCustomFilterControl.SetFont(Index: Integer;
  const Value: TFont);
begin
  FFonts[TcxFilterControlFont(Index)].Assign(Value);
end;

function TcxCustomFilterControl.FocusedRowIndex: Integer;
begin
  Result := FRows.IndexOf(FFocusedInfo.Row);
  if Result < 0 then Result := 0;
end;

function TcxCustomFilterControl.GetRow(Index: Integer): TcxCustomRowViewInfo;
begin
  Result := TcxCustomRowViewInfo(FRows[Index]);
end;

function TcxCustomFilterControl.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function TcxCustomFilterControl.GetFocusedRow: TcxCustomRowViewInfo;
begin
  Result := FFocusedInfo.Row;
end;

procedure TcxCustomFilterControl.ComboBoxCloseUp(Sender: TObject);
begin
  if not FComboBox.EditModified then Exit;
  with FocusedRow do
    case State of
      fcsSelectingBoolOperator:
        with FComboBox do
          Group.BoolOperator :=
            TcxFilterBoolOperatorKind(Properties.Items.Objects[ItemIndex]);
      fcsSelectingItem:
        with FComboBox do
        begin
          Condition.SetItem(Integer(Properties.Items.Objects[ItemIndex]));
          FFocusedInfo.HitTest := fhtOperator;
          with Condition do
          if (fcoLike in SupportedOperators) and (ValueType <> nil) and ValueType.IsString then
            Condition.Operator := fcoLike;
        end;
      fcsSelectingCondition:
        begin
          with FComboBox do
            Condition.Operator :=
              TcxFilterControlOperator(Properties.Items.Objects[ItemIndex]);
          Condition.InitValues(True);
          if Condition.HasDisplayValues then
          begin
            FFocusedInfo.HitTest := fhtValue;
            FFocusedInfo.ValueIndex := 0;
          end;
        end;
    end;
  FComboBox.Visible := False;
  State := fcsNormal;
  ViewInfo.Calc;
  EnsureRowVisible;
  SetFocus;
end;

procedure TcxCustomFilterControl.ComboBoxExit(Sender: TObject);
begin
  //TODO
  FComboBox.Visible := False;
  State := fcsNormal;
end;

procedure TcxCustomFilterControl.ComboBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 32 then Key := 13;
end;

procedure TcxCustomFilterControl.ComboBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then Key := #0;
end;

procedure TcxCustomFilterControl.ComboBoxPopup(Sender: TObject);
begin
  TcxComboBoxListBox(FComboBox.ILookupData.ActiveControl).Font.Style := [];
end;

procedure TcxCustomFilterControl.DoComboDropDown(const R: TRect; const AText: string);
begin
  with FComboBox do
  begin
    Visible := True;
    with R do
      SetBounds(Left, Top, Right - Left, Bottom - Top);
    Properties.DropDownRows := Min(cxFilterControlMaxDropDownRows,
      Properties.Items.Count);
    EditValue := AText;
    DroppedDown := True;
  end;
end;

procedure TcxCustomFilterControl.SetFocusedRow(ARow: TcxCustomRowViewInfo);
begin
  FFocusedInfo.Row := ARow;
  if ARow is TcxGroupViewInfo then
    RowNavigate(fhtBoolOperator)
  else
    RowNavigate(fhtItem);
end;

procedure TcxCustomFilterControl.PopupMenuClick(Sender: TObject);
begin
  case Integer(TMenuItem(Sender).Tag) of
    0: AddCondition(FocusedRow);
    1: AddGroup;
    3: if FocusedRow <> FRoot then RemoveRow else Clear;
  end;
end;

function TcxCustomFilterControl.IsNullStringStored: Boolean;
begin
  Result := FNullString <> cxGetResourceString(@cxSFilterControlNullString);
end;

procedure TcxCustomFilterControl.ProcessHitTest(
  AHitTest: TcxFilterControlHitTest; AByMouse: Boolean);
begin
  case AHitTest of
    fhtAddCondition: AddCondition(nil); // add last
    fhtAddValue: AddValue;
    fhtBoolOperator: SelectBoolOperator;
    fhtButton: SelectAction;
    fhtItem: SelectItem;
    fhtOperator: SelectCondition;
    fhtValue:
      if AByMouse then
        SelectValue(aveMouse, #0)
      else
        SelectValue(aveEnter, #0);
  end
end;

procedure TcxCustomFilterControl.ReadData(AStream: TStream);
begin
  FCriteria.ReadData(AStream);
end;

procedure TcxCustomFilterControl.RecalcRows;

   procedure FillRows(ARow: TcxCustomRowViewInfo);
   var
     I: Integer;
   begin
     FRows.Add(ARow);
     if ARow is TcxGroupViewInfo then
       for I := 0 to ARow.Group.RowCount - 1 do
         FillRows(ARow.Group.Rows[I])
   end;

begin
  FRows.Clear;
  FillRows(FRoot);
end;

procedure TcxCustomFilterControl.RefreshMenuCaptions;
begin
  with FActionMenu do
  begin
    Items[0].Caption := cxGetResourceString(@cxSFilterAddCondition);
    Items[1].Caption := cxGetResourceString(@cxSFilterAddGroup);
    Items[2].Caption := '-';
  end;
end;

procedure TcxCustomFilterControl.SetLeftOffset(Value: Integer);
begin
  Value := Min(Value, ViewInfo.MaxRowWidth - WidthOf(ClientBounds) + 1);
  if Value < 0 then Value := 0;
  if FLeftOffset <> Value then
  begin
    FLeftOffset := Value;
    LayoutChanged;
  end;
end;

procedure TcxCustomFilterControl.SetNullString(const Value: string);
begin
  if FNullString <> Value then
  begin
    FNullString := Value;
    LayoutChanged;
  end;
end;

procedure TcxCustomFilterControl.SetTopVisibleRow(Value: Integer);
begin
  Value := Min(Value, RowCount - HeightOf(ClientBounds) div ViewInfo.RowHeight + 1);
  if Value < 0 then Value := 0;
  if FTopVisibleRow <> Value then
  begin
    FTopVisibleRow := Value;
    LayoutChanged;
  end;
end;

procedure TcxCustomFilterControl.SetShowLevelLines(const Value: Boolean);
begin
  if FShowLevelLines <> Value then
  begin
    FShowLevelLines := Value;
    Invalidate;
  end;
end;

procedure TcxCustomFilterControl.SetWantTabs(const Value: Boolean);
begin
  FWantTabs := Value;
  if Value then
    Keys := [kAll, kArrows, kChars, kTab]
  else
    Keys := [kAll, kArrows, kChars];
end;

procedure TcxCustomFilterControl.ValueEditorInit;

  procedure SetValidChars;
  var
    AWildcardChars: set of AnsiChar;
  begin
    AWildcardChars := [AnsiChar(FCriteria.UnderscoreWildcard), AnsiChar(FCriteria.PercentWildcard)];
    if FValueEditor is TcxCustomTextEdit then
      if FocusedRow.Condition.Operator in [fcoLike, fcoNotLike] then
        with TcxCustomTextEditProperties(FValueEditor.ActiveProperties) do
          ValidChars := ValidChars + AWildcardChars
  end;

var
  AProperties: TcxCustomEditProperties;
  AIndex: Integer;
begin
  State := fcsSelectingValue;
  AIndex := FFocusedInfo.ValueIndex;
  with FocusedRow.Condition do
  begin
    AProperties := GetProperties;
    FValueEditor := EditorHelper.GetFilterEdit(AProperties, FInplaceEditors);
    EditorHelper.SetFilterValue(FValueEditor, AProperties, Values[AIndex].Value);
  end;
  SetValidChars;
  with FValueEditor do
  begin
    Parent := Self;
    Style.Assign(FValueEditorStyle);
    Style.Color := clWindow;
    with FocusedRow.Condition.Values[AIndex].ValueRect do
      SetBounds(Left, Top, Right - Left, Bottom - Top);
    OnAfterKeyDown := ValueEditorAfterKeyDown;
    OnExit := ValueEditorExit;
    OnKeyDown := ValueEditorKeyDown;
  end;
end;

procedure TcxCustomFilterControl.ValueEditorAfterKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) or (Key = VK_DOWN) then
  try
    ValueEditorHide(True);
    SetFocus;
    KeyDown(Key, Shift);
    Key := 0;
  except
    FValueEditor.SetFocus;
    raise;
  end;
end;

procedure TcxCustomFilterControl.ValueEditorExit(Sender: TObject);
begin
  try
    ValueEditorHide(True);
  except
    FValueEditor.SetFocus;
    raise;
  end;
end;

procedure TcxCustomFilterControl.ValueEditorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        ValueEditorHide(True);
        SetFocus;
        Key := 0;
      end;
    VK_TAB:
      if FWantTabs then
      begin
        ValueEditorHide(True);
        SetFocus;
        if ssShift in Shift then FocusPrev(True) else FocusNext(True);
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        if FValueEditor <> nil then
          Key := 0;
        ValueEditorHide(False);
        SetFocus;
      end;
    VK_DELETE:
      if Shift = [ssCtrl] then
      begin
        ValueEditorHide(False);
        SetFocus;
        Remove;
        Key := 0;
      end;
  end;
end;

procedure TcxCustomFilterControl.WriteData(AStream: TStream);
begin
  FCriteria.WriteData(AStream);
end;

{ TcxFilterControlPainter }

constructor TcxFilterControlPainter.Create(AOwner: TcxCustomFilterControl);
begin
  inherited Create;
  FControl := AOwner;
end;

function TcxFilterControlPainter.GetContentColor: TColor;
begin
  Result := clDefault;
  if Control.LookAndFeel.SkinPainter <> nil then
    Result := Control.LookAndFeel.SkinPainter.DefaultContentColor;
  if Result = clDefault then
    Result := Control.Color;
end;

procedure TcxFilterControlPainter.DrawBorder;
begin
  Painter.DrawBorder(Canvas, Control.Bounds);
end;

procedure TcxFilterControlPainter.DrawDotLine(const R: TRect);
var
  APrevBkColor, APrevTextColor: TColorRef;
begin
  APrevBkColor := GetBkColor(Canvas.Canvas.Handle);
  APrevTextColor := GetTextColor(Canvas.Canvas.Handle);
  SetBkColor(Canvas.Canvas.Handle, ColorToRGB(cl3DDkShadow));
  SetTextColor(Canvas.Canvas.Handle, ColorToRGB(ContentColor));
  Windows.FillRect(Canvas.Canvas.Handle, R, HalftoneBrush);
  SetBkColor(Canvas.Canvas.Handle, APrevBkColor);
  SetTextColor(Canvas.Canvas.Handle, APrevTextColor);
end;

procedure TcxFilterControlPainter.DrawGroup(ARow: TcxGroupViewInfo);
begin
  with ARow, Canvas.Canvas do
  begin
    Brush.Style := bsClear;
    if Caption <> '' then
      TextDraw(CaptionRect.Left, CaptionRect.Top + 1, Caption);
    Font.Assign(Control.FontBoolOperator);
    if BoolOperatorText <> '' then
      TextDraw(BoolOperatorRect.Left + 1, BoolOperatorRect.Top + 1, BoolOperatorText);
  end;
end;

procedure TcxFilterControlPainter.DrawCondition(ARow: TcxConditionViewInfo);
begin
  with ARow, Canvas.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Assign(Control.FontItem);
    if ItemText <> '' then
      TextDraw(ItemRect.Left + 1, ItemRect.Top + 1, ItemText);
    Font.Assign(Control.FontCondition);
    if OperatorText <> '' then
      TextDraw(OperatorRect.Left + 1, OperatorRect.Top + 1, OperatorText);
  end;
  DrawValues(ARow);
end;

procedure TcxFilterControlPainter.DrawValues(ARow: TcxConditionViewInfo);
var
  I: Integer;
begin
  with ARow do
  begin
    if not Condition.HasDisplayValues then Exit;
    for I := 0 to Values.Count - 1 do
      Values[I].ValueViewInfo.Paint(Self.Canvas);
    if Operator in [fcoBetween, fcoNotBetween] then
    begin
      Canvas.Font.Assign(Control.FontCondition);
      Canvas.Brush.Color := ContentColor;
      for I := 1 to Values.Count - 1 do
        with Values[I - 1] do
          TextDraw(ValueRect.Right + 4, ValueRect.Top + 1, Values.Separator);
    end
    else if Operator in [fcoInList, fcoNotInList] then
    begin
      Canvas.Font.Assign(Control.FontValue);
      Canvas.Brush.Color := ContentColor;
      for I := 1 to Values.Count - 1 do
        with Values[I - 1] do
          TextDraw(ValueRect.Right + 2, ValueRect.Top + 1, Values.Separator);
      with OperatorRect do TextDraw(Right + 4, Top, '(');
      with Values[Values.Count - 1].ValueRect do TextDraw(Right + 3, Top + 1, ')');
      Painter.DrawButton(Canvas, Values.AddButtonRect, '+', Values.AddButtonState);
    end;
  end;
end;

procedure TcxFilterControlPainter.DrawRow(ARow: TcxCustomRowViewInfo);
var
  ALeft, H: Integer;
  AParent: TcxCustomRowViewInfo;
begin
  with Canvas, ARow do
  begin
    Brush.Color := ContentColor;
    FillRect(ARow.RowRect);
    Font.Assign(Control.Font);
    Painter.DrawButton(Self.Canvas, ButtonRect, ButtonText, ButtonState);
    if ARow is TcxGroupViewInfo then
      DrawGroup(Group)
    else
      DrawCondition(Condition);
    // draw level's lines if need
    if Control.ShowLevelLines and (Level > 0) then
    begin
      Brush.Style := bsSolid;
      Brush.Color := clGray;
      ALeft := Parent.ButtonRect.Left + WidthOf({Parent.}ButtonRect) div 2;
      H := HeightOf(RowRect) div 2;
      DrawDotLine(Bounds(ALeft, RowRect.Top, 1, H));
      if not IsLast then DrawDotLine(Bounds(ALeft, RowRect.Top + H, 1, H + 1));
      Inc(H, RowRect.Top);
      DrawDotLine(Rect(ALeft, H, ButtonRect.Left - 3, H + 1));
      AParent := Parent;
      while AParent <> nil do
      begin
        if not AParent.IsLast then
        begin
          ALeft := AParent.Parent.ButtonRect.Left + WidthOf(ButtonRect) div 2;
          DrawDotLine(Rect(ALeft, RowRect.Top, ALeft + 1, RowRect.Bottom));
        end;
        AParent := AParent.Parent;
      end;
    end;
  end;
end;

procedure TcxFilterControlPainter.TextDraw(X, Y: Integer; const AText: string);
begin
  with Canvas.Canvas do
  begin
    if not ViewInfo.Enabled then
    begin
      Brush.Style := bsClear;
      Font.Color := clBtnHighlight;
      TextOut(X + 1, Y + 1, AText);
      Font.Color := clBtnShadow;
    end;
    TextOut(X, Y, AText);
  end;
end;

function TcxFilterControlPainter.GetCanvas: TcxCanvas;
begin
  Result := ViewInfo.Canvas;
end;

function TcxFilterControlPainter.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := FControl.LookAndFeel.Painter;
end;

function TcxFilterControlPainter.GetViewInfo: TcxFilterControlViewInfo;
begin
  Result := FControl.FViewInfo;
end;

{ TcxFilterControlViewInfo }

constructor TcxFilterControlViewInfo.Create(
  AOwner: TcxCustomFilterControl);
begin
  inherited Create;
  FControl := AOwner;
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pfDevice;
  FBitmapCanvas := TcxCanvas.Create(FBitmap.Canvas);
  FPainter := GetPainterClass.Create(AOwner);
  FButtonState := cxbsNormal;
end;

destructor TcxFilterControlViewInfo.Destroy;
begin
  FreeAndNil(FPainter);
  FreeAndNil(FBitmapCanvas);
  FreeAndNil(FBitmap);
  inherited Destroy;
end;

procedure TcxFilterControlViewInfo.Calc;
var
  I, AIndent: Integer;
  J: TcxFilterControlFont;
  R: TRect;
  ASize: TSize;
begin
  CheckBitmap;
  with Control do
  begin
    FEnabled := HasItems and Enabled;
    FRowHeight := Self.Canvas.FontHeight(Font);
    FMinValueWidth := Self.Canvas.TextWidth('0') * 12;
    for J := fcfBoolOperator to fcfCondition do
      FRowHeight := Max(FRowHeight, Self.Canvas.FontHeight(FFonts[J]));
    FRowHeight := MulDiv(Max(FRowHeight, GetEditHeight), 3, 2);
    with ClientBounds do
      R := Rect(Left - LeftOffset, Top, Right, Top + FRowHeight);
    OffsetRect(R, 0, - TopVisibleRow * FRowHeight);
    FMaxRowWidth := 0;
    for I := 0 to RowCount - 1 do
      with Rows[I] do
      begin
        Calc(R);
        FMaxRowWidth := Max(FMaxRowWidth, Width);
        OffsetRect(R, 0, FRowHeight);
      end;
    AIndent := Rows[RowCount - 1].Indent + 4;
    Inc(R.Left, AIndent);
    Self.Canvas.Font.Assign(Font);
    ASize := Self.Canvas.TextExtent(FAddConditionCaption + '00');
    FAddConditionRect := Classes.Bounds(R.Left, 0, ASize.cx, HeightOf(R) - 4);
    CenterRectVert(R, FAddConditionRect);
    FMaxRowWidth := Max(FMaxRowWidth, WidthOf(FAddConditionRect) + AIndent);
  end;
  CalcButtonState;
  CalcFocusRect;
end;

procedure TcxFilterControlViewInfo.GetHitTestInfo(AShift: TShiftState;
  const P: TPoint; var HitInfo: TcxFilterControlHitTestInfo);
var
  I: Integer;
begin
  with Control do
  begin
    HitInfo.HitTest := fhtNone;
    HitInfo.Mouse := P;
    HitInfo.Row := FocusedRow;
    if HitInfo.Row = nil then HitInfo.Row := FRoot;
    HitInfo.Shift := AShift;
    HitInfo.ValueIndex := -1;
    if not PtInRect(ClientBounds, P) then Exit;
    if PtInRect(AddConditionRect, P) then
      HitInfo.HitTest := fhtAddCondition
    else
      for I := TopVisibleRow to RowCount - 1 do
        if PtInRect(Rows[I].RowRect, P) then
        begin
          HitInfo.Row := Rows[I];
          Rows[I].GetHitTestInfo(P, HitInfo);
          break;
        end;
  end;
end;

procedure TcxFilterControlViewInfo.Paint;

  function IsFocused: Boolean;
  begin
    Result := Control.IsFocused or
      (Control.FComboBox.IsFocused) or
      ((Control.FValueEditor <> nil) and Control.FValueEditor.IsFocused);
  end;

var
  I: Integer;
  R: TRect;
begin
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := Painter.ContentColor;
    FillRect(Control.ClientBounds);
  end;
  for I := Control.TopVisibleRow to Control.RowCount - 1 do
    with Control.Rows[I] do
    begin
      if Canvas.RectVisible(RowRect) then
        Painter.DrawRow(Control.Rows[I]);
      if RowRect.Top > Control.ClientBounds.Bottom then break;
    end;
  with Canvas do
  begin
    Brush.Color := Painter.ContentColor;
    Brush.Style := bsSolid;
    Font.Assign(Control.Font);
    Painter.Painter.DrawButton(Self.Canvas, FAddConditionRect, FAddConditionCaption, FButtonState);
    if not IsRectEmpty(FFocusRect) and IsFocused then
      DrawFocusRect(FFocusRect);
  end;
  R := Bounds(0, 0, FBitmap.Width, FBitmap.Height);
  Painter.DrawBorder;
  BitBlt(Control.Canvas.Handle, 0, 0, FBitmap.Width, FBitmap.Height,
    Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TcxFilterControlViewInfo.InvalidateRow(ARow: TcxCustomRowViewInfo);
begin
  if ARow <> nil then
  begin
    ARow.Calc(ARow.RowRect);
    Control.InvalidateRect(ARow.RowRect, False);
  end;
end;

procedure TcxFilterControlViewInfo.Update;
var
  AState: TcxButtonState;
begin
  AState := FButtonState;
  CalcButtonState;
  CalcFocusRect;
  if AState <> FButtonState then Control.InvalidateRect(FAddConditionRect, True);
end;

procedure TcxFilterControlViewInfo.CalcFocusRect;
begin
  if not Control.HasItems then
  begin
    FFocusRect := Control.ClientBounds;
    InflateRect(FFocusRect, -2, -2);
  end
  else
    with Control.FFocusedInfo do
    begin
      FFocusRect := EmptyRect;
      case HitTest of
        fhtBoolOperator: FFocusRect := Row.Group.BoolOperatorRect;
        fhtItem: FFocusRect := Row.Condition.ItemRect;
        fhtOperator: FFocusRect := Row.Condition.OperatorRect;
        fhtValue: FFocusRect := Row.Condition.Values[ValueIndex].ValueRect;
      end;
      if HitTest in [fhtBoolOperator, fhtItem, fhtOperator, fhtValue] then
        InflateRect(FFocusRect, 1, 1);
    end;
end;

function TcxFilterControlViewInfo.GetPainterClass: TcxFilterControlPainterClass;
begin
  Result := TcxFilterControlPainter;
end;

procedure TcxFilterControlViewInfo.CalcButtonState;
begin
  with Control do
    if not FEnabled then
      FButtonState := cxbsDisabled
    else
      if FFocusedInfo.HitTest = fhtAddCondition then
        FButtonState := cxbsDefault
      else
        if HasHotTrack and (FHotTrack.HitTest = fhtAddCondition) then
          FButtonState := cxbsHot
        else
          FButtonState := cxbsNormal;
end;

procedure TcxFilterControlViewInfo.CheckBitmap;
begin
  FBitmap.Height := Control.Height; // only if needed
  FBitmap.Width := Control.Width;   // only if needed
end;

function TcxFilterControlViewInfo.GetCanvas: TcxCanvas;
begin
  Result := FBitmapCanvas;
end;

function TcxFilterControlViewInfo.GetEditHeight: Integer;
var
  AEditSizeProperties: TcxEditSizeProperties;
begin
  AEditSizeProperties.MaxLineCount := 1;
  AEditSizeProperties.Width := 10;
  AEditSizeProperties.Height := -1;
  Canvas.Font.Assign(Control.FontValue);
  with Control do
    Result := FTextEditProperties.GetEditSize(Canvas, FValueEditorStyle,
      True, 'Yy', AEditSizeProperties).cy;
end;

{ TcxFilterControl }

procedure TcxFilterControl.UpdateFilter;
begin
  if (FilterLink <> nil) and (FilterLink.Criteria <> nil) then
  begin
    if FCriteria <> FilterLink.Criteria then
      FCriteria.Assign(FilterLink.Criteria);
    BuildFromCriteria;
  end
  else Clear;
end;

function TcxFilterControl.GetFilterLink: IcxFilterControl;
begin
  if FLinkComponent <> nil then
    Supports(TObject(FLinkComponent), IcxFilterControl, Result)
  else
    Result := nil;
end;

procedure TcxFilterControl.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FLinkComponent) then
    LinkComponent := nil
end;

{$IFDEF CBUILDER6}
function TcxFilterControl.GetLinkComponent: TComponent;
begin
  Result := FLinkComponent;
end;
{$ENDIF}

procedure TcxFilterControl.SetLinkComponent(Value: TComponent);
begin
  if (Value <> nil) and not Supports(Value, IcxFilterControl) then
    Value := nil;
  if FLinkComponent <> Value then
  begin
    {$IFDEF DELPHI5}
    if FLinkComponent <> nil then
      FLinkComponent.RemoveFreeNotification(Self);
    {$ENDIF}
    FLinkComponent := Value;
    if FLinkComponent <> nil then
      FLinkComponent.FreeNotification(Self);
    UpdateFilter;
  end;
end;

procedure CreateHalftoneBrush;
var
  X, Y: Integer;
  DC: HDC;
  Pattern: HBITMAP;
begin
  Pattern := CreateBitmap(8, 8, 1, 1, nil);
  DC := CreateCompatibleDC(0);
  Pattern := SelectObject(DC, Pattern);
  FillRect(DC, Rect(0, 0, 8, 8), GetStockObject(WHITE_BRUSH));
  for Y := 0 to 7 do
    for X := 0 to 7 do
      if (Y mod 2) = (X mod 2) then SetPixel(DC, X, Y, 0);
  Pattern := SelectObject(DC, Pattern);
  DeleteDC(DC);
  HalftoneBrush := CreatePatternBrush(Pattern);
  DeleteObject(Pattern);
end;

initialization
  CreateHalftoneBrush;

finalization
  if HalftoneBrush <> 0 then DeleteObject(HalftoneBrush);

end.
