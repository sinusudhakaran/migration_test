{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Common Editing Library            }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
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
{   LICENSED TO DISTRIBUTE THE COMMONEDITINGLIBRARY AND ALL          }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
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

unit cxInplaceContainer;

{$I cxVer.inc}

interface    

uses
  Classes, SysUtils,
  Windows, Messages,
{$IFDEF DELPHI6}
  Variants, Types,
{$ENDIF}
  Forms, Controls, StdCtrls, Graphics, cxVariants, cxClasses,
  cxControls, cxGraphics, cxStyles, cxContainer, cxEdit, cxTextEdit, cxData,
  cxCustomData, cxDataUtils, cxDataStorage, cxLookAndFeels, cxLookAndFeelPainters,
  cxEditDataRegisteredRepositoryItems, cxGeometry, cxLibraryConsts;

const
   ecs_Content    = 0;
   ecs_Background = 1;
   ecs_Inactive   = 2;
   ecs_Selection  = 3;

   ecs_EditContainerStylesMaxIndex = ecs_Content;
   ecs_EditingStylesMaxIndex = ecs_Selection;

// predefined hit codes
   echc_Empty        = 0;
   echc_IsMouseEvent = 1;

// viewinfo states
   cvis_IsDirty      = 1;
   cvis_StyleInvalid = 2;

   cxSizingMarkWidth = 1;
   cxScrollWidthDragInterval = 50;

type
  TcxDragSizingDirection = (dsdHorz, dsdVert);

  TcxGetEditPropertiesEvent = procedure(Sender: TObject; AData: Pointer;
    var AEditProperties: TcxCustomEditProperties) of object;
  TcxOnGetContentStyleEvent = procedure(Sender: TObject; AData: Pointer;
    out AStyle: TcxStyle) of object;

  TcxInplaceEditContainerClass = class of TcxCustomInplaceEditContainer;
  TcxCustomInplaceEditContainer = class;
  TcxItemDataBindingClass = class of TcxCustomItemDataBinding;

  TcxCustomControlDragAndDropObjectClass = class of TcxCustomControlDragAndDropObject;

  TcxEditingController = class;
  TcxEditingControllerClass = class of TcxEditingController;

  TcxCustomEditStyleClass = class of TcxCustomEditStyle;

  TcxCustomControlControllerClass = class of TcxCustomControlController;
  TcxCustomControlController = class;
  TcxControlDataController = class;
  TcxCustomControlPainter = class;
  TcxEditingControl = class;

  TcxHotTrackControllerClass = class of TcxHotTrackController;
  TcxCustomHitTestController = class;

  TcxEditItemShowEditButtons = (eisbDefault, eisbNever, eisbAlways);
  TcxEditingControlEditShowButtons = (ecsbAlways, ecsbFocused, ecsbNever);

  TcxCustomControlViewInfo = class;

  TcxCustomControlStyles = class;

  TcxCustomViewInfoItem = class;
  TcxEditCellViewInfo = class;
  TcxEditCellViewInfoClass = class of TcxEditCellViewInfo;

  TcxHitCode = type Int64;


  { TcxContainerItemDefaultValuesProvider }

  TcxContainerItemDefaultValuesProvider = class(TcxCustomEditDefaultValuesProvider)
    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean; override;
  end;

  { TcxCustomItemDataBinding }

  TcxCustomItemDataBinding = class(TcxOwnedPersistent)
  private
    FDefaultValuesProvider: TcxCustomEditDefaultValuesProvider;
    FData: Pointer;
    function GetDataController: TcxCustomDataController;
    function GetEditContainer: TcxCustomInplaceEditContainer;
  protected
    function DefaultRepositoryItem: TcxEditRepositoryItem; virtual;
    function GetDefaultCaption: string; virtual;
    function GetDefaultValuesProvider(AProperties: TcxCustomEditProperties): IcxEditDefaultValuesProvider; virtual;
    function GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass; virtual;
    function GetValueTypeClass: TcxValueTypeClass; virtual;
    procedure Init; virtual;
    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean;
    procedure ValueTypeClassChanged; virtual;
    property DataController: TcxCustomDataController read GetDataController;
    property DefaultValuesProvider: TcxCustomEditDefaultValuesProvider read FDefaultValuesProvider;
    property EditContainer: TcxCustomInplaceEditContainer read GetEditContainer;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    property Data: Pointer read FData write FData;
  end;

  { TcxItemDataBinding }

  TcxItemDataBinding = class(TcxCustomItemDataBinding)
  private
    FValueTypeClass: TcxValueTypeClass;
    function GetValueType: string;
    procedure SetValueType(const Value: string);
    procedure SetValueTypeClass(Value: TcxValueTypeClass);
  protected
    function GetValueTypeClass: TcxValueTypeClass; override;
    function IsValueTypeStored: Boolean; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    property ValueTypeClass: TcxValueTypeClass read GetValueTypeClass write SetValueTypeClass;
  published
    property ValueType: string read GetValueType write SetValueType stored IsValueTypeStored;
  end;

  { TcxControlDataController }

  TcxControlDataController = class(TcxDataController)
  private
    function GetControl: TcxEditingControl;
  protected
    procedure UpdateControl(AInfo: TcxUpdateControlInfo); override;
  public
    function GetItem(Index: Integer): TObject; override;
    function GetItemID(AItem: TObject): Integer; override;
    function GetItemValueSource(AItemIndex: Integer): TcxDataEditValueSource; override;
    procedure UpdateData; override;
    procedure UpdateItemIndexes; override;
  end;

  { TcxCustomEditContainerItemOptions }

  TcxCustomEditContainerItemOptionsClass = class of TcxCustomEditContainerItemOptions;

  TcxCustomEditContainerItemOptions = class(TcxOwnedPersistent)
  private
    FCustomizing: Boolean;
    FEditing: Boolean;
    FFiltering: Boolean;
    FFocusing: Boolean;
    FIncSearch: Boolean;
    FMoving: Boolean;
    FShowEditButtons: TcxEditItemShowEditButtons;
    FSorting: Boolean;
    FTabStop: Boolean; 
    function GetEditContainer: TcxCustomInplaceEditContainer;
    procedure SetEditing(Value: Boolean);
    procedure SetFiltering(Value: Boolean);
    procedure SetFocusing(Value: Boolean);
    procedure SetIncSearch(Value: Boolean);
    procedure SetShowEditButtons(Value: TcxEditItemShowEditButtons);
  protected
    procedure Changed; virtual;
    property EditContainer: TcxCustomInplaceEditContainer read GetEditContainer;
    property Moving: Boolean read FMoving write FMoving default True;
    property Customizing: Boolean read FCustomizing write FCustomizing default True;
    property Sorting: Boolean read FSorting write FSorting default True;
    property Editing: Boolean read FEditing write SetEditing default True;
    property Filtering: Boolean read FFiltering write SetFiltering default True;
    property Focusing: Boolean read FFocusing write SetFocusing default True;
    property IncSearch: Boolean read FIncSearch write SetIncSearch default True;
    property ShowEditButtons: TcxEditItemShowEditButtons read FShowEditButtons
      write SetShowEditButtons default eisbDefault;
    property TabStop: Boolean read FTabStop write FTabStop default True;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(AOwner: TPersistent); override;
  end;

  { TcxControlOptionsView }

  TcxControlOptionsViewClass = class of TcxControlOptionsView;

  TcxControlOptionsView = class(TcxOwnedPersistent)
  private
    FCellAutoHeight: Boolean;
    FCellEndEllipsis: Boolean;
    FCellTextMaxLineCount: Integer;
    FShowEditButtons: TcxEditingControlEditShowButtons;
    function GetEditingControl: TcxEditingControl;
    function GetScrollBars: TScrollStyle;
    procedure SetCellAutoHeight(const Value: Boolean);
    procedure SetCellEndEllipsis(const Value: Boolean);
    procedure SetCellTextMaxLineCount(const Value: Integer);
    procedure SetScrollBars(const Value: TScrollStyle);
    procedure SetShowEditButtons(const Value: TcxEditingControlEditShowButtons);
  protected
    procedure Changed; virtual;
    property EditingControl: TcxEditingControl read GetEditingControl;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
  published
    property CellAutoHeight: Boolean read FCellAutoHeight write SetCellAutoHeight default False;
    property CellEndEllipsis: Boolean read FCellEndEllipsis write SetCellEndEllipsis default False;
    property CellTextMaxLineCount: Integer read FCellTextMaxLineCount write SetCellTextMaxLineCount default 0;
    property ScrollBars: TScrollStyle read GetScrollBars write SetScrollBars default ssBoth;
    property ShowEditButtons: TcxEditingControlEditShowButtons read FShowEditButtons write SetShowEditButtons default ecsbNever;
  end;

  { TcxControlOptionsData }

  TcxControlOptionsDataClass = class of TcxControlOptionsData;

  TcxControlOptionsData = class(TcxOwnedPersistent)
  private
    FCancelOnExit: Boolean;
    FEditing: Boolean;
    function GetEditingControl: TcxEditingControl;
    procedure SetEditing(Value: Boolean);
  protected
    procedure Changed; virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    property EditingControl: TcxEditingControl read GetEditingControl;
  published
    property CancelOnExit: Boolean read FCancelOnExit write FCancelOnExit default True;
    property Editing: Boolean read FEditing write SetEditing default True;
  end;

  { TcxControlOptionsBehavior }

  TcxControlOptionsBehaviorClass = class of TcxControlOptionsBehavior;

  TcxControlOptionsBehavior = class(TcxOwnedPersistent)
  private
    FAlwaysShowEditor: Boolean;
    FCellHints: Boolean;
    FDragDropText: Boolean;
    FFocusCellOnCycle: Boolean;
    FFocusFirstCellOnNewRecord: Boolean;
    FGoToNextCellOnEnter: Boolean;
    FGoToNextCellOnTab: Boolean;
    FImmediateEditor: Boolean;
    FIncSearch: Boolean;
    FIncSearchItem: TcxCustomInplaceEditContainer;
    function GetEditingControl: TcxEditingControl;
    procedure SetAlwaysShowEditor(Value: Boolean);
    procedure SetCellHints(Value: Boolean);
    procedure SetFocusCellOnCycle(Value: Boolean);
    procedure SetFocusFirstCellOnNewRecord(Value: Boolean);
    procedure SetGoToNextCellOnEnter(Value: Boolean);
    procedure SetGoToNextCellOnTab(Value: Boolean);
    procedure SetImmediateEditor(Value: Boolean);
    procedure SetIncSearch(Value: Boolean);
    procedure SetIncSearchItem(Value: TcxCustomInplaceEditContainer);
  protected
    procedure Changed; virtual;
    property DragDropText: Boolean read FDragDropText write FDragDropText default False;  
    property EditingControl: TcxEditingControl read GetEditingControl;
    property FocusCellOnCycle: Boolean read FFocusCellOnCycle write SetFocusCellOnCycle default False;
    property FocusFirstCellOnNewRecord: Boolean read FFocusFirstCellOnNewRecord write SetFocusFirstCellOnNewRecord default False;
    property IncSearch: Boolean read FIncSearch write SetIncSearch default False;
    property IncSearchItem: TcxCustomInplaceEditContainer read FIncSearchItem write SetIncSearchItem;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
  published
    property AlwaysShowEditor: Boolean read FAlwaysShowEditor write SetAlwaysShowEditor default False;
    property CellHints: Boolean read FCellHints write SetCellHints default False;
    property GoToNextCellOnEnter: Boolean read FGoToNextCellOnEnter write SetGoToNextCellOnEnter default False;
    property GoToNextCellOnTab: Boolean read FGoToNextCellOnTab write SetGoToNextCellOnTab default False;
    property ImmediateEditor: Boolean read FImmediateEditor write SetImmediateEditor default True;
  end;

  { TcxEditContainerStyles }

  TcxEditContainerStylesClass = class of TcxEditContainerStyles;

  TcxEditContainerStyles = class(TcxStyles)
  private
    function GetContainer: TcxCustomInplaceEditContainer;
    function GetControl: TcxEditingControl;
    function GetControlStyles: TcxCustomControlStyles;
  protected
    procedure Changed(AIndex: Integer); override;
  public
    procedure Assign(Source: TPersistent); override;
    property Container: TcxCustomInplaceEditContainer read GetContainer;
    property Control: TcxEditingControl read GetControl;
    property ControlStyles: TcxCustomControlStyles read GetControlStyles;
  published
    property Content: TcxStyle index ecs_Content read GetValue write SetValue;
  end;

  { TcxCustomInplaceEditContainer }

  IcxEditorPropertiesContainer = interface
  ['{9F0CD5D9-A3D1-44B7-82DC-CAEAC1367C5D}']
    function GetProperties: TcxCustomEditProperties;
    function GetPropertiesClass: TcxCustomEditPropertiesClass;
    procedure SetPropertiesClass(Value: TcxCustomEditPropertiesClass);
  end;

  TcxCustomInplaceEditContainer = class(TComponent, IUnknown, IcxEditRepositoryItemListener, IcxEditorPropertiesContainer)
  private
    FData: Pointer;
    FEditData: TcxCustomEditData;
    FEditingControl: TcxEditingControl;
    FEditViewData: TcxCustomEditViewData;
    FEditValueSource: TcxDataEditValueSource;
    FItemIndex: Integer;
    FOptions: TcxCustomEditContainerItemOptions;
    FProperties: TcxCustomEditProperties;
    FPropertiesClass: TcxCustomEditPropertiesClass;
    FPropertiesEvents: TNotifyEvent;
    FPropertiesValue: TcxCustomEditProperties;
    FRepositoryItem: TcxEditRepositoryItem;
    FStyles: TcxEditContainerStyles;
    FOnGetEditProperties: TcxGetEditPropertiesEvent;
    FOnGetEditingProperties: TcxGetEditPropertiesEvent;
    procedure IcxEditRepositoryItemListener.PropertiesChanged = RepositoryItemPropertiesChanged;
    procedure IcxEditRepositoryItemListener.ItemRemoved = RepositoryItemRemoved;
    function GetDataController: TcxCustomDataController;
    function GetFocused: Boolean;
    function GetFocusedCellViewInfo: TcxEditCellViewInfo;
    function GetIncSearching: Boolean;
    function GetProperties: TcxCustomEditProperties;
    function GetPropertiesClass: TcxCustomEditPropertiesClass;
    function GetPropertiesClassName: string;
    function GetPropertiesValue: TcxCustomEditProperties;
    procedure SetDataBinding(Value: TcxCustomItemDataBinding);
    procedure SetFocused(Value: Boolean);
    procedure SetOptions(Value: TcxCustomEditContainerItemOptions);
    procedure SetProperties(Value: TcxCustomEditProperties);
    procedure SetPropertiesClass(Value: TcxCustomEditPropertiesClass);
    procedure SetPropertiesClassName(const Value: string);
    procedure SetRepositoryItem(Value: TcxEditRepositoryItem);
    procedure SetStyles(Value: TcxEditContainerStyles);
    procedure CreateProperties;
    procedure DestroyProperties;
    procedure RecreateProperties;
    procedure RepositoryItemPropertiesChanged(Sender: TcxEditRepositoryItem);
    procedure RepositoryItemRemoved(Sender: TcxEditRepositoryItem);
  protected
    FDataBinding: TcxCustomItemDataBinding;
    procedure CalculateEditViewInfo(const AValue: Variant;
      AEditViewInfo: TcxEditCellViewInfo; const APoint: TPoint); virtual;
    function CanEdit: Boolean; virtual;
    function CanFocus: Boolean; virtual;
    procedure CancelIncSearching;
    function CanInitEditing: Boolean; virtual;
    function CanIncSearch: Boolean; virtual;
    function CanTabStop: Boolean; virtual;
    procedure Changed; virtual;
    function CreateEditViewData(AProperties: TcxCustomEditProperties; AEditStyleData: Pointer): TcxCustomEditViewData; virtual;
    procedure DataChanged; virtual;
    procedure DoGetDisplayText(ARecordIndex: Integer; var AText: string); virtual;
    function DoGetEditProperties(AData: Pointer): TcxCustomEditProperties; virtual;
    procedure DoGetEditingProperties(AData: Pointer; var AProperties: TcxCustomEditProperties); virtual;
    function DoGetPropertiesFromEvent(AEvent: TcxGetEditPropertiesEvent; AData: Pointer;
      AProperties: TcxCustomEditProperties): TcxCustomEditProperties; virtual;
    procedure DoOnPropertiesChanged(Sender: TObject); virtual;
    procedure EditViewDataGetDisplayTextHandler(Sender: TcxCustomEditViewData; var AText: string); virtual;
    function GetControlCanvas: TcxCanvas; virtual;
    function GetController: TcxCustomControlController; virtual;
    function GetCurrentValue: Variant; virtual;
    function GetDataBindingClass: TcxItemDataBindingClass; virtual;
    function GetDefaultCaption: string; virtual;
    function GetDefaultEditProperties: TcxCustomEditProperties; virtual;
    function GetDisplayValue(AProperties: TcxCustomEditProperties; ARecordIndex: Integer): Variant; virtual;
    function GetEditDataValueTypeClass: TcxValueTypeClass; virtual;              // todo:
    function GetEditDefaultHeight(AFont: TFont): Integer; virtual;
    function GetEditHeight(AEditViewInfo: TcxEditCellViewInfo): Integer; virtual;
    function GetEditing: Boolean; virtual;
    function GetEditStyle(AData: Pointer): TcxCustomEditStyle; virtual;
    function GetEditValue: Variant; virtual;
    function GetEditWidth(AEditViewInfo: TcxEditCellViewInfo): Integer; virtual;
    function GetOptionsClass: TcxCustomEditContainerItemOptionsClass; virtual;
    function GetStylesClass: TcxEditContainerStylesClass; virtual;
    function GetValue(ARecordIndex: Integer): Variant; virtual;
    function GetValueCount: Integer; virtual;
    function HasDataTextHandler: Boolean; virtual;
    procedure InitEditViewInfo(AEditViewInfo: TcxEditCellViewInfo); virtual;
    procedure InitProperties(AProperties: TcxCustomEditProperties); virtual;
    procedure InternalPropertiesChanged;
    function IsDestroying: Boolean;
    function IsEditPartVisible: Boolean;
    procedure PropertiesChanged; virtual;
    procedure SetCurrentValue(const Value: Variant); virtual;
    procedure SetEditing(Value: Boolean); virtual;
    procedure SetEditingControl(Value: TcxEditingControl); virtual;
    procedure SetEditValue(const Value: Variant); virtual;
    procedure SetValue(ARecordIndex: Integer; const Value: Variant); virtual;
    property Controller: TcxCustomControlController read GetController;
    property DataBinding: TcxCustomItemDataBinding read FDataBinding write SetDataBinding;
    property DataController: TcxCustomDataController read GetDataController; // todo: should be protected
    property IncSearching: Boolean read GetIncSearching;
    property EditData: TcxCustomEditData read FEditData;
    property Editing: Boolean read GetEditing write SetEditing;
    property EditingControl: TcxEditingControl read FEditingControl write SetEditingControl;
    property EditValue: Variant read GetEditValue write SetEditValue;
    property EditValueSource: TcxDataEditValueSource read FEditValueSource;
    property EditViewData: TcxCustomEditViewData read FEditViewData;
    property Focused: Boolean read GetFocused write SetFocused;
    property FocusedCellViewInfo: TcxEditCellViewInfo read GetFocusedCellViewInfo;
    property Options: TcxCustomEditContainerItemOptions read FOptions write SetOptions;
    property PropertiesValue: TcxCustomEditProperties read GetPropertiesValue;
    property Value: Variant read GetCurrentValue write SetCurrentValue;
    property ValueCount: Integer read GetValueCount;
    property Values[ARecordIndex: Integer]: Variant read GetValue write SetValue;
    property OnGetEditProperties: TcxGetEditPropertiesEvent read FOnGetEditProperties write FOnGetEditProperties;
    property OnGetEditingProperties: TcxGetEditPropertiesEvent read FOnGetEditingProperties write FOnGetEditingProperties;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Data: Pointer read FData write FData;
    property ItemIndex: Integer read FItemIndex;
    property PropertiesClass: TcxCustomEditPropertiesClass read FPropertiesClass write SetPropertiesClass;
  published
    property PropertiesClassName: string read GetPropertiesClassName write SetPropertiesClassName;
    property Properties: TcxCustomEditProperties read GetProperties write SetProperties;
    property PropertiesEvents: TNotifyEvent read FPropertiesEvents write FPropertiesEvents;
    property RepositoryItem: TcxEditRepositoryItem read FRepositoryItem write SetRepositoryItem;
    property Styles: TcxEditContainerStyles read FStyles write SetStyles;
  end;

  { IcxHotTrackElement }

  IcxHotTrackElement = interface
  ['{E7171E58-276E-499B-9DDF-298D850883C9}']
    function GetOrigin: TPoint;
    function IsNeedHint(ACanvas: TcxCanvas; const P: TPoint;
      out AText: TCaption;
      out AIsMultiLine: Boolean;
      out ATextRect: TRect; var IsNeedOffsetHint: Boolean): Boolean;
    procedure UpdateHotTrackState(const APoint: TPoint);
  end;

  { TcxHotTrackController }

  TcxHotTrackController = class
  private
    FControl: TcxEditingControl;
    FShowHint: Boolean;
    procedure InternalHideHint(Sender: TObject);
    procedure InternalShowHint(Sender: TObject);
    procedure ResetTimer;
  protected
    Hint: TCaption;
    HintIsMultiLine: Boolean;
    HintTimer: TcxTimer;
    HintRect: TRect;
    HintVisible: Boolean;
    HintElement: TObject;
    HintWindow: THintWindow;
    PrevHitPoint: TPoint;
    PrevElement: TObject;
    function CanShowHint: Boolean;
    procedure CheckDestroyingElement(AElement: TObject);
    procedure CheckHintClass;
    procedure DoHideHint; virtual;
    procedure DoShowHint; virtual;
    function HintNeeded: Boolean;
    procedure InitTimer(AInterval: Integer; AEnabled: Boolean; const AHandler: TNotifyEvent);
  public
    constructor Create(AControl: TcxEditingControl); virtual;
    destructor Destroy; override;
    procedure CancelHint;
    procedure Clear;
    procedure SetHotElement(AElement: TObject; const APoint: TPoint);
    property Control: TcxEditingControl read FControl write FControl;
    property ShowHint: Boolean read FShowHint write FShowHint;
  end;

    { IcxDragSizing }

  IcxDragSizing = interface
  ['{5EA02F4E-E367-4E4D-A26D-000B5E5CD434}']
    function CanSizing(ADirection: TcxDragSizingDirection): Boolean;
    function GetSizingBoundsRect(ADirection: TcxDragSizingDirection): TRect;
    function GetSizingIncrement(ADirection: TcxDragSizingDirection): Integer;
    function IsDynamicUpdate: Boolean;
    procedure SetSizeDelta(ADirection: TcxDragSizingDirection; ADelta: Integer);
  end;

  { TcxSizingDragAndDropObject }

  TcxSizingDragAndDropObject = class(TcxDragAndDropObject)
  private
    FDelta: Integer;
    FDirection: TcxDragSizingDirection;
    FDragBounds: TRect;
    FDragPos: TPoint;
    FDynamicUpdate: Boolean;
    FStartPos: TPoint;
    FSizeDelta: Integer;
    function GetCanvas: TcxCanvas;
    function GetController: TcxCustomControlController;
    function GetDragCoord(APoint: TPoint): Integer;
    function GetDragItem: TObject;
    function GetDragSizing: IcxDragSizing;
    function GetIsSizingKind(Index: Integer): Boolean;
  protected
    procedure BeginDragAndDrop; override;
    procedure DirtyChanged; override;
    procedure DragAndDrop(const P: TPoint; var Accepted: Boolean); override;
    procedure EndDragAndDrop(Accepted: Boolean); override;
    function GetDragAndDropCursor(Accepted: Boolean): TCursor; override;
    function GetDragPos(const APoint: TPoint): TPoint; virtual;
    function GetImmediateStart: Boolean; override;
    function GetSizingMarkBounds: TRect; virtual;
    property StartPos: TPoint read FStartPos;
    property Controller: TcxCustomControlController read GetController;
    property Delta: Integer read FDelta;
    property DragCoord[Point: TPoint]: Integer read GetDragCoord;
    property DragPos: TPoint read FDragPos;
    property DragSizing: IcxDragSizing read GetDragSizing;
    property Direction: TcxDragSizingDirection read FDirection;
  public
    property Canvas: TcxCanvas read GetCanvas;
    property DragBounds: TRect read FDragBounds;
    property DragItem: TObject read GetDragItem;
    property DynamicUpdate: Boolean read FDynamicUpdate;
    property IsHorzSizing: Boolean index 0 read GetIsSizingKind;
    property IsVertSizing: Boolean index 1 read GetIsSizingKind;
    property SizeDelta: Integer read FSizeDelta;
  end;

  { TcxAutoScrollingObject }

  TcxAutoScrollingObject = class
  private
    FArea: TRect;
    FCode: TScrollCode;
    FIncrement: Integer;
    FKind: TScrollBarKind;
    FOwner: TObject;
    FTimer: TcxTimer;
  protected
    procedure DoScrollInspectingControl; virtual;
    function GetControl: TcxEditingControl; virtual;
    function GetScrollBar(AKind: TScrollBarKind): TcxControlScrollBar; virtual;
    procedure TimerHandler(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TObject); virtual;
    destructor Destroy; override;
    function Check(APos: TPoint): Boolean;
    procedure SetParams(const Area: TRect; AKind: TScrollBarKind;
      ACode: TScrollCode; AIncrement: Integer);
    procedure Stop;
    property Code: TScrollCode read FCode;
    property Control: TcxEditingControl read GetControl;
    property Increment: Integer read FIncrement;
    property Kind: TScrollBarKind read FKind;
    property Owner: TObject read FOwner;
    property Timer: TcxTimer read FTimer;
  end;

  { TcxDragDropAutoScrollingObject }

  TcxDragDropObjectAutoScrollingObject = class(TcxAutoScrollingObject)
  protected
    function GetControl: TcxEditingControl; override;
  end;

  { TcxControllerAutoScrollingObject }

  TcxControllerAutoScrollingObject = class(TcxAutoScrollingObject)
  private
    FBoundsMode: Boolean;
    FCheckHorz: Boolean;
    FCheckVert: Boolean;
    FDirections: TcxNeighbors;
  protected
    procedure DoScrollInspectingControl; override;
    function GetControl: TcxEditingControl; override;
  public
    function CheckBounds(APos: TPoint): Boolean;
    procedure SetBoundsParams(const AClientArea: TRect;
      ACheckHorz, ACheckVert: Boolean; AIncrement: Integer);
  end;

  TcxAutoScrollingObjectClass = class of TcxAutoScrollingObject;

  { TcxBaseDragAndDropObject }

  TcxBaseDragAndDropObject = class(TcxDragAndDropObject)
  private
    function GetEditingControl: TcxEditingControl;
  protected
    function GetDragAndDropCursor(Accepted: Boolean): TCursor; override;
    property EditingControl: TcxEditingControl read GetEditingControl;
  end;

  { TcxDragImage }
  
  TcxDragImage = class(cxControls.TcxDragImage)
  public
    property Image;
    property WindowCanvas;
  end;

  { TcxPlaceArrows }
  
  TcxPlaceArrows = class(TcxDragImage)
  private
    FBorderColor: TColor;
    FColor: TColor;
    FPrevRect: TRect;
    FPrevSide: TcxBorder;
    FWindowRegion: HRGN;
    procedure SetWindowRegion(ARegion: HRGN);
  protected
    function CreateArrowsRgns(const ARect: TRect; ASide: TcxBorder): HRGN;

    property BorderColor: TColor read FBorderColor;
    property Color: TColor read FColor;
    property WindowRegion: HRGN read FWindowRegion write SetWindowRegion;
  public
    constructor CreateArrows(AColor: TColor; ABorderColor: TColor = clDefault); virtual;
    function MoveTo(ARect: TRect; ASide: TcxBorder): Boolean;
  end;

  { TcxCustomControlDragAndDropObject }

  TcxCustomControlDragAndDropObject = class(TcxBaseDragAndDropObject)
  private
    FAutoScrollObjects: TList;
    FCanDrop: Boolean;
    FDragImage: TcxDragImage;
    FHotSpot: TPoint;
    FOrgOffset: TPoint;
    FPictureSize: TRect;
    function CheckScrolling(const P: TPoint): Boolean;
    function GetAutoScrollObject(Index: Integer): TcxAutoScrollingObject;
    function GetAutoScrollObjectCount: Integer;
    function GetCanvas: TcxCanvas;
    function GetHitTestController: TcxCustomHitTestController;
  protected
    procedure AddAutoScrollingObject(const ARect: TRect; AKind: TScrollBarKind;  ACode: TScrollCode);
    procedure BeginDragAndDrop; override;
    procedure DragAndDrop(const P: TPoint; var Accepted: Boolean); override;
    procedure DrawDragImage; virtual;
    procedure DrawImage(const APoint: TPoint);
    procedure EndDragAndDrop(Accepted: Boolean); override;
    function GetAcceptedRect: TRect; virtual;
    function GetAutoScrollingObjectClass: TcxAutoScrollingObjectClass; virtual;
    function GetDisplayRect: TRect; virtual;
    function GetDragAndDropCursor(Accepted: Boolean): TCursor; override;
    function GetHorzScrollInc: Integer; virtual;
    function GetVertScrollInc: Integer; virtual;
    procedure OwnerImageChanged; virtual;
    procedure OwnerImageChanging; virtual;
    procedure Paint; virtual;
    procedure StopScrolling;
    // screen image working
    property AcceptedRect: TRect read GetAcceptedRect;
    property AutoScrollObjectCount: Integer read GetAutoScrollObjectCount;
    property AutoScrollObjects[Index: Integer]: TcxAutoScrollingObject read GetAutoScrollObject;
    property Canvas: TcxCanvas read GetCanvas;
    property CanDrop: Boolean read FCanDrop;
    property DisplayRect: TRect read GetDisplayRect;
    property DragImage: TcxDragImage read FDragImage;
    property HitTestController: TcxCustomHitTestController read GetHitTestController;
    property HotSpot: TPoint read FHotSpot;
    property OrgOffset: TPoint read FOrgOffset;
    property PictureSize: TRect read FPictureSize;
  public
    constructor Create(AControl: TcxControl); override;
    destructor Destroy; override;
  end;

  { TcxDragImageHelper }

  TcxDragImageHelperClass = class of TcxDragImageHelper;

  TcxDragImageHelper = class
  private
    FDragControl: TcxEditingControl;
    FDragImageVisible: Boolean;
    FDragPos: TPoint;
    function GetImageRect: TRect;
    procedure SetDragImageVisible(Value: Boolean);
  protected
    DragImage: TcxDragImage;
    HotSpot: TPoint;
    DragPictureBounds: TRect;
    MousePos: TPoint;
    procedure DragAndDrop(const P: TPoint); virtual;
    function GetDisplayRect: TRect; virtual;
    procedure InitDragImage; virtual;
    // working with screen
    procedure DrawImage(const APoint: TPoint); virtual;
  public
    constructor Create(AControl: TcxEditingControl; ADragPos: TPoint); virtual;
    destructor Destroy; override;
    procedure Hide; virtual;
    procedure Show; virtual; 

    property DragControl: TcxEditingControl read FDragControl;
    property DragImageRect: TRect read GetImageRect;
    property DragImageVisible: Boolean read FDragImageVisible write SetDragImageVisible;
  end;

  { TcxCustomHitTestController }

  TcxHitTestControllerClass  = class of TcxCustomHitTestController;

  TcxCustomHitTestController = class
  private
    FController: TcxCustomControlController;
    FHitPoint: TPoint;
    FHitTestItem: TObject;
    FShift: TShiftState;
    function GetControl: TcxEditingControl;
    function GetCoordinate(AIndex: Integer): Integer;
    function GetEditCellViewInfo: TcxEditCellViewInfo;
    function GetHasCode(Mask: TcxHitCode): Boolean;
    function GetHotTrackController: TcxHotTrackController;
    function GetIsItemEditCell: Boolean;
    function GetIsMouseEvent: Boolean;
    function GetViewInfo: TcxCustomControlViewInfo;
    procedure SetCoordinate(AIndex: Integer; Value: Integer);
    procedure SetHasCode(ACode: TcxHitCode; AValue: Boolean);
    procedure SetHitPoint(const APoint: TPoint);
    procedure SetHitTestItem(AItem: TObject);
    procedure SetIsMouseEvent(Value: Boolean);
  protected
    FHitState: TcxHitCode;
    function AllowDesignMouseEvents(X, Y: Integer; AShift: TShiftState): Boolean; virtual;
    procedure ClearState;
    procedure DestroyingItem(AItem: TObject);
    procedure DoCalculate; virtual;
    function GetCurrentCursor: TCursor; virtual;
    procedure HitCodeChanged(APrevCode: Integer); virtual;
    procedure HitTestItemChanged(APrevHitTestItem: TObject); virtual;
    procedure RecalculateOnMouseEvent(X, Y: Integer; AShift: TShiftState);
    property Control: TcxEditingControl read GetControl;
    property Controller: TcxCustomControlController read FController;
    property HotTrackController: TcxHotTrackController read GetHotTrackController;
    property IsMouseEvent: Boolean read GetIsMouseEvent write SetIsMouseEvent;
    property Shift: TShiftState read FShift;
    property ViewInfo: TcxCustomControlViewInfo read GetViewInfo;
  public
    constructor Create(AOwner: TcxCustomControlController); virtual;
    destructor Destroy; override;
    procedure ReCalculate; overload;
    procedure ReCalculate(const APoint: TPoint); overload;
    property EditCellViewInfo: TcxEditCellViewInfo read GetEditCellViewInfo;
    property HitPoint: TPoint read FHitPoint write SetHitPoint;
    property HitX: Integer index 0 read GetCoordinate write SetCoordinate;
    property HitY: Integer index 1 read GetCoordinate write SetCoordinate;
    property HitState: TcxHitCode read FHitState;
    property HitCode[ACode: TcxHitCode]: Boolean read GetHasCode write SetHasCode;
    property HitTestItem: TObject read FHitTestItem write SetHitTestItem;
    property IsItemEditCell: Boolean read GetIsItemEditCell;
  end;

  { TcxCustomCellNavigator }

  TcxCustomCellNavigator = class
  private
    FController: TcxCustomControlController;
    FEatKeyPress: Boolean;
    FDownOnEnter: Boolean;
    FDownOnTab: Boolean;
    function GetDataController: TcxCustomDataController;
  protected
    RowCount: Integer;
    function SelectCell(AForward, ANextRow: Boolean;
      var ARowIndex, ACellIndex: Integer): TcxCustomInplaceEditContainer; virtual;

    procedure CalcNextRow(AForward: Boolean; var ARowIndex, ACellIndex: Integer); virtual;
    function GetCellContainer(ARowIndex, ACellIndex: Integer): TcxCustomInplaceEditContainer; virtual;
    function GetCount(ARowIndex: Integer): Integer; virtual;
    procedure Init(var ARowIndex, ACellIndex, ARowCount: Integer); virtual;
    function MayFocusedEmptyRow(ARowIndex: Integer): Boolean; virtual;
    procedure SetFocusCell(ARowIndex, ACellIndex: Integer; AShift: TShiftState); virtual;
    procedure DoKeyPress(var Key: Char); virtual;
    property DownOnEnter: Boolean read FDownOnEnter write FDownOnEnter;
    property DownOnTab: Boolean read FDownOnTab write FDownOnTab;
  public
    constructor Create(AController: TcxCustomControlController); virtual;
    procedure FocusNextCell(AForward, ANextRow: Boolean; AShift: TShiftState = []); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    procedure Refresh; virtual;
    property Count[ARowIndex: Integer]: Integer read GetCount;
    property Controller: TcxCustomControlController read FController;
    property DataController: TcxCustomDataController read GetDataController;
    property EatKeyPress: Boolean read FEatKeyPress write FEatKeyPress;
  end;

  TcxCustomCellNavigatorClass = class of TcxCustomCellNavigator;

  { TcxDesignSelectionHelper }

  TcxCustomDesignSelectionHelper = class
  private
    FControl: TcxEditingControl;
    function GetController: TcxCustomControlController;
  protected
    property Control: TcxEditingControl read FControl;
    property Controller: TcxCustomControlController read GetController;
  public
    constructor Create(AControl: TcxEditingControl); virtual;
    function IsObjectSelected(AObject: TPersistent): Boolean; virtual; abstract;
    procedure Select(AObject: TPersistent; AShift: TShiftState); virtual; abstract;
    procedure UnselectObject(AObject: TPersistent); virtual; abstract;
  end;

  TcxCustomDesignSelectionHelperClass = class of TcxCustomDesignSelectionHelper;

  { TcxCustomControlController }

  TcxCustomControlController = class
  private
    FAllowCheckEdit: Boolean;
    FBlockRecordKeyboardHandling: Boolean;
    FCheckEditNeeded: Boolean;
    FDisableCellsRefresh: Boolean;
    FDragCancel: Boolean;
    FDragItem: TObject;
    FEatKeyPress: Boolean;
    FEditingBeforeDrag: Boolean;
    FEditingController: TcxEditingController;
    FEditingControl: TcxEditingControl;
    FFocused: Boolean;
    FFocusedItem: TcxCustomInplaceEditContainer;
    FHitTestController: TcxCustomHitTestController;
    FHotTrackController: TcxHotTrackController;
    FIsDblClick: Boolean;
    FIsHandleTabStop: Boolean;
    FLockShowHint: Boolean;
    FNavigator: TcxCustomCellNavigator;
    FWasFocusedBeforeClick: Boolean;
    function GetDataController: TcxCustomDataController;
    function GetDesignSelectionHelper: TcxCustomDesignSelectionHelper;
    function GetEditingItem: TcxCustomInplaceEditContainer;
    function GetIsEditing: Boolean;
    function GetItemForIncSearching: TcxCustomInplaceEditContainer;
    procedure SetEditingItem(Value: TcxCustomInplaceEditContainer);
    procedure SetIncSearchingText(const Value: string);
  protected
    procedure MouseEnter; virtual;
    procedure MouseLeave; virtual;
    procedure DoCancelMode; virtual;

    procedure AfterPaint; virtual;
    procedure BeforeEditKeyDown(var Key: Word; var Shift: TShiftState); virtual;
    procedure BeforeMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure BeforePaint; virtual;
    procedure BeforeShowEdit; virtual;
    procedure BehaviorChanged; virtual;
    procedure CancelCheckEditPost;
    function CanFocusedRecordIndex(AIndex: Integer): Boolean; virtual;
    procedure CheckEdit; virtual;
    procedure DoEditDblClick(Sender: TObject); virtual;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoNextPage(AForward: Boolean; Shift: TShiftState); virtual;
    function GetEditingViewInfo: TcxEditCellViewInfo; virtual;
    function GetFocused: Boolean; virtual;
    function GetFocusedCellViewInfo(AEditContainer: TcxCustomInplaceEditContainer): TcxEditCellViewInfo; virtual;
    function GetFocusedRecordIndex: Integer; virtual;
    function GetResizeDirection: TcxDragSizingDirection; virtual;
    procedure FocusedItemChanged(APrevFocusedItem: TcxCustomInplaceEditContainer); virtual;
    procedure FocusedRecordChanged(APrevFocusedRecordIndex, AFocusedRecordIndex: Integer); virtual;
    function HasFocusedControls: Boolean; virtual;
    procedure HideHint; virtual;
    function IncSearchKeyDown(AKey: Word; AShift: TShiftState): Word; virtual;
    procedure InternalSetFocusedItem(Value: TcxCustomInplaceEditContainer);
    function IsImmediatePost: Boolean; virtual;
    function IsKeyForController(AKey: Word; AShift: TShiftState): Boolean; virtual;
    procedure PostCheckEdit;
    procedure PostShowEdit;
    procedure ProcessCheckEditPost;
    procedure RefreshFocusedCellViewInfo(AItem: TcxCustomInplaceEditContainer); virtual;
    procedure RefreshFocusedRecord; virtual;
    procedure SetFocused(Value: Boolean); virtual;
    procedure SetFocusedItem(Value: TcxCustomInplaceEditContainer); virtual;
    procedure SetFocusedRecordIndex(Value: Integer); virtual;
    // behavior options
    function GetAlwaysShowEditor: Boolean; virtual;
    function GetCancelEditingOnExit: Boolean; virtual;
    function GetFocusCellOnCycle: Boolean; virtual;
    function GetGoToNextCellOnEnter: Boolean; virtual;
    function GetGoToNextCellOnTab: Boolean; virtual;
    function GetImmediateEditor: Boolean; virtual;
    // drag'n'drop
    procedure BeforeStartDrag; virtual;
    function CanDrag(X, Y: Integer): Boolean; virtual;
    procedure DragDrop(Source: TObject; X, Y: Integer); virtual;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); virtual;
    procedure EndDrag(Target: TObject; X, Y: Integer); virtual;
    function GetDragAndDropObject: TcxCustomControlDragAndDropObject;
    function GetDragAndDropObjectClass: TcxDragAndDropObjectClass; virtual;
    function GetIsDragging: Boolean; virtual;
    function GetNavigatorClass: TcxCustomCellNavigatorClass; virtual;
    procedure StartDrag(var DragObject: TDragObject); virtual;
    // scrolling
    function GetMouseWheelScrollingKind: TcxMouseWheelScrollingKind; virtual;
    function IsPixelScrollBar(AKind: TScrollBarKind): Boolean; virtual;
    // focus
    procedure DoEnter; virtual;
    procedure DoExit; virtual;
    function MayFocus: Boolean; virtual;
    procedure FocusChanged; virtual;
    procedure RemoveFocus; virtual;
    procedure SetFocus; virtual;
    // incremental search
    procedure CancelIncSearching; virtual;
    function GetIncSearchingItem: TcxCustomInplaceEditContainer; virtual;
    function GetIncSearchingText: string; virtual;
    function GetIsIncSearching: Boolean; virtual;
    procedure SearchLocate(AItem: TcxCustomInplaceEditContainer; const Value: string); virtual;
    procedure SearchLocateNext(AItem: TcxCustomInplaceEditContainer; AForward: Boolean); virtual;
    procedure UpdateRecord(ARecordIndex: Integer); virtual;
    property AllowCheckEdit: Boolean read FAllowCheckEdit write FAllowCheckEdit;
    property BlockRecordKeyboardHandling: Boolean read FBlockRecordKeyboardHandling
      write FBlockRecordKeyboardHandling;
    property DesignSelectionHelper: TcxCustomDesignSelectionHelper read GetDesignSelectionHelper;
    property DisableCellsRefresh: Boolean read FDisableCellsRefresh write FDisableCellsRefresh;
    property DragAndDropObject: TcxCustomControlDragAndDropObject read GetDragAndDropObject;
    property DragCancel: Boolean read FDragCancel write FDragCancel;
    property DragItem: TObject read FDragItem write FDragItem;
    property EatKeyPress: Boolean read FEatKeyPress write FEatKeyPress;
    property EditingControl: TcxEditingControl read FEditingControl;
    property EditingController: TcxEditingController read FEditingController;
    property EditingItem: TcxCustomInplaceEditContainer read GetEditingItem write SetEditingItem;
    property EditingViewInfo: TcxEditCellViewInfo read GetEditingViewInfo;
    property HotTrackController: TcxHotTrackController read FHotTrackController;
    property HitTestController: TcxCustomHitTestController read FHitTestController;
    property IncSearchingText: string read GetIncSearchingText write SetIncSearchingText;
    property IncSearchingItem: TcxCustomInplaceEditContainer read GetIncSearchingItem;
    property IsHandleTabStop: Boolean read FIsHandleTabStop write FIsHandleTabStop;
    property IsDragging: Boolean read GetIsDragging;
    property IsIncSearching: Boolean read GetIsIncSearching;
    property ItemForIncSearching: TcxCustomInplaceEditContainer read GetItemForIncSearching;
    property LockShowHint: Boolean read FLockShowHint write FLockShowHint;
    property Navigator: TcxCustomCellNavigator read FNavigator;
    property WasFocusedBeforeClick: Boolean read FWasFocusedBeforeClick;
  public
    constructor Create(AOwner: TcxEditingControl); reintroduce; virtual;
    destructor Destroy; override;
    procedure Clear; virtual;
    procedure ControlFocusChanged; virtual;
    procedure DblClick; virtual;
    function GetCursor(X, Y: Integer): TCursor; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure Reset;
    procedure WndProc(var Message: TMessage); virtual;
    // drag'n'drop
    procedure BeginDragAndDrop; virtual;
    procedure DragAndDrop(const P: TPoint; var Accepted: Boolean); virtual;
    procedure EndDragAndDrop(Accepted: Boolean); virtual;
    function StartDragAndDrop(const P: TPoint): Boolean; virtual;
    // scrolling
    procedure InitScrollBarsParameters; virtual;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); virtual;
    procedure SetFocusedRecordItem(ARecordIndex: Integer;
      AItem: TcxCustomInplaceEditContainer); virtual;
    procedure SetScrollBarInfo(AScrollBarKind: TScrollBarKind;
      AMin, AMax, AStep, APage, APos: Integer; AAllowShow, AAllowHide: Boolean);

    procedure MakeFocusedItemVisible; virtual;
    procedure MakeFocusedRecordVisible; virtual;

    property DataController: TcxCustomDataController read GetDataController;
    property Focused: Boolean read GetFocused write SetFocused;
    property FocusedItem: TcxCustomInplaceEditContainer read FFocusedItem write SetFocusedItem;
    property FocusedRecordIndex: Integer read GetFocusedRecordIndex write SetFocusedRecordIndex;

    property IsDblClick: Boolean read FIsDblClick;
    property IsEditing: Boolean read GetIsEditing;
  end;

  { TcxEditingController }

  TcxEditingController = class
  private
    FController: TcxCustomControlController;
    FEdit: TcxCustomEdit;
    FEditHiding: Boolean;
    FEditingItem: TcxCustomInplaceEditContainer;
    FEditingItemSetting: Boolean;
    FEditList: TcxInplaceEditList;
    FEditPreparing: Boolean;
    FEditShowingTimer: TcxTimer;
    FEditShowingTimerItem: TcxCustomInplaceEditContainer;
    FEditUpdateNeeded: Boolean;
    FInitiatingEditing: Boolean;
    FIsEditPlaced: Boolean;
    FIsErrorOnEditExit: Boolean;
    FPrevEditOnChange: TNotifyEvent;
    FPrevEditOnEditValueChanged: TNotifyEvent;
    function GetEditingControl: TcxEditingControl;
    function GetEditingProperties: TcxCustomEditProperties;
    function GetIsDragging: Boolean;
    function GetIsEditing: Boolean;
    procedure SetEditingItem(Value: TcxCustomInplaceEditContainer);
    procedure EditShowingTimerHandler(Sender: TObject);
  protected
    procedure AfterViewInfoCalculate; virtual;
    procedure BeforeViewInfoCalculate; virtual;
    procedure CancelEditUpdatePost;
    function CanRemoveEditFocus: Boolean; virtual;
    function CanUpdateEditValue: Boolean; virtual;
    procedure CheckEditUpdatePost;
    procedure AssignEditEvents; virtual;
    procedure UnassignEditEvents; virtual;
    procedure DoUpdateEdit;
    function GetHideEditOnExit: Boolean; virtual;
    function GetHideEditOnFocusedRecordChange: Boolean; virtual;
    procedure HideInplaceEditor;
    procedure InitEdit; virtual;
    function PrepareEdit(AItem: TcxCustomInplaceEditContainer; AIsMouseEvent: Boolean): Boolean; virtual;
    procedure UpdateEdit;
    procedure UpdateEditValue;
    procedure UpdateValue;

    procedure EditAfterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure EditChanged(Sender: TObject); virtual;
    procedure EditDblClick(Sender: TObject); virtual;
    procedure EditEditing(Sender: TObject; var CanEdit: Boolean); virtual;
    procedure EditEnter(Sender: TObject); virtual;
    procedure EditExit(Sender: TObject); virtual;
    procedure EditFocusChanged(Sender: TObject); virtual;
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure EditKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure EditPostEditValue(Sender: TObject); virtual;
    procedure EditValueChanged(Sender: TObject); virtual;

    property Controller: TcxCustomControlController read FController;
    property EditingControl: TcxEditingControl read GetEditingControl;
    property EditHiding: Boolean read FEditHiding write FEditHiding;
    property EditingProperties: TcxCustomEditProperties read GetEditingProperties;
    property EditList: TcxInplaceEditList read FEditList;
    property EditUpdateNeeded: Boolean read FEditUpdateNeeded;
    property HideEditOnExit: Boolean read GetHideEditOnExit;
    property HideEditOnFocusedRecordChange: Boolean read GetHideEditOnFocusedRecordChange;
    property InitiatingEditing: Boolean read FInitiatingEditing;
    property IsEditPlaced: Boolean read FIsEditPlaced;
    property IsErrorOnEditExit: Boolean read FIsErrorOnEditExit write FIsErrorOnEditExit;
  public
    constructor Create(AController: TcxCustomControlController); virtual;
    destructor Destroy; override;
    procedure HideEdit(Accept: Boolean); virtual;
    procedure PostEditUpdate;
    procedure RemoveEdit(AProperties: TcxCustomEditProperties); virtual;
    procedure ShowEdit(AItem: TcxCustomInplaceEditContainer = nil); overload;
    procedure ShowEdit(AItem: TcxCustomInplaceEditContainer; Key: Char); overload;
    procedure ShowEdit(AItem: TcxCustomInplaceEditContainer; Shift: TShiftState; X, Y: Integer); overload;

    procedure StartEditShowingTimer(AItem: TcxCustomInplaceEditContainer);
    procedure StopEditShowingTimer;

    property Edit: TcxCustomEdit read FEdit;
    property EditingItem: TcxCustomInplaceEditContainer read FEditingItem write SetEditingItem;
    property IsDragging: Boolean read GetIsDragging;
    property IsEditing: Boolean read GetIsEditing;
  end;

  { TcxCustomControlViewInfo }

  TcxCustomControlViewInfo = class
  private
    FControl: TcxEditingControl;
    FClientRect: TRect;
    FDefaultEditHeight: Integer;
    FEditCellViewInfoList: TList;
    FPainter: TcxCustomControlPainter;
    FState: Integer;
    function GetLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
    function GetState(AMask: Integer): Boolean;
    procedure SetState(AMask: Integer; Value: Boolean);
    procedure UpdateSelectionParams;
  protected
    Brush: TBrush;
    SelectionBrush: TBrush;
    SelectionParams: TcxViewParams;
    function AddEditCellViewInfo(AViewInfoClass: TcxEditCellViewInfoClass;
      AEditContainer: TcxCustomInplaceEditContainer): TcxEditCellViewInfo;
    function CalculateDefaultEditHeight: Integer; virtual;
    procedure CalculateDefaultHeights; virtual;
    procedure ClearEditCellViewInfos;
    procedure CreatePainter; virtual;
    procedure DoCalculate; virtual;
    procedure RemoveEditCellViewInfo(AViewInfo: TcxEditCellViewInfo);
    procedure UpdateSelection; virtual;
    property IsDirty: Boolean index cvis_IsDirty read GetState write SetState;
    property State[AMask: Integer]: Boolean read GetState write SetState;
  public
    ViewParams: TcxViewParams;
    constructor Create(AOwner: TcxEditingControl); virtual;
    destructor Destroy; override;

    procedure Calculate;
    procedure Invalidate(ARecalculate: Boolean = False); virtual;
    property ClientRect: TRect read FClientRect;
    property Control: TcxEditingControl read FControl;
    property DefaultEditHeight: Integer read FDefaultEditHeight;
    property LookAndFeelPainter: TcxCustomLookAndFeelPainterClass read GetLookAndFeelPainter;
    property Painter: TcxCustomControlPainter read FPainter write FPainter;
  end;

  { TcxCustomControlCells }

  TcxCustomDrawCellEvent = procedure(ACanvas: TcxCanvas;
    ACell: TcxCustomViewInfoItem; var ADone: Boolean) of object;

  TcxCustomControlCells = class(TcxObjectList)
  private
    function GetItem(AIndex: Integer): TcxCustomViewInfoItem;
  public
    procedure BeforePaint;
    function CalculateHitTest(AHitTest: TcxCustomHitTestController): Boolean;
    procedure DeleteAll;
    procedure ExcludeFromClipping(ACanvas: TcxCanvas);
    procedure Paint(ACanvas: TcxCanvas; AHandler: TcxCustomDrawCellEvent); virtual;

    property Items[Index: Integer]: TcxCustomViewInfoItem read GetItem; default;
  end;

  TcxCustomControlViewInfoClass = class of TcxCustomControlViewInfo;

  { TcxCustomViewInfoItem }

  TcxCustomViewInfoItem = class
  private
    FHasClipping: Boolean;
    FOwner: TObject;
    FTransparent: Boolean;
    FVisibleInfoCalculated: Boolean;
    function GetBitmap: TBitmap;
    function GetControlViewInfo: TcxCustomControlViewInfo;
    function GetPainter: TcxCustomLookAndFeelPainterClass;
  protected
    ClipRect: TRect;
    ControlCanvas: TcxCanvas;
    DisplayRect: TRect;
    ItemViewParams: TcxViewParams;
    ItemVisible: Boolean;
    procedure AfterCustomDraw(ACanvas: TcxCanvas); virtual;
    procedure BeforeCustomDraw(ACanvas: TcxCanvas); virtual;
    procedure CheckClipping(const ADisplayRect, AAvailableRect: TRect); overload; virtual;
    procedure CheckClipping(const ADisplayRect: TRect); overload; virtual;
    procedure DoCalculate; virtual;
    procedure DoDraw(ACanvas: TcxCanvas); virtual;
    procedure DoHorzOffset(AShift: Integer); virtual;
    procedure DoVertOffset(AShift: Integer); virtual;
    function DrawBackgroundHandler(ACanvas: TcxCanvas; const ABounds: TRect): Boolean;
    function GetControl: TcxEditingControl; virtual;
    function GetHitTest(AHitTest: TcxCustomHitTestController): Boolean; virtual; 
    function IsTransparent: Boolean; virtual;
    function ExcludeFromPaint(ACanvas: TcxCanvas): Boolean;
    procedure UpdateEditRect;

    property Owner: TObject read FOwner;
    property ControlViewInfo: TcxCustomControlViewInfo read GetControlViewInfo;
  public
    constructor Create(AOwner: TObject); virtual;
    procedure Assign(Source: TcxCustomViewInfoItem); virtual;
    procedure CheckVisibleInfo;
    class function CustomDrawID: Integer; virtual;
    procedure Draw(ACanvas: TcxCanvas);
    procedure Invalidate(ARecalculate: Boolean = False);

    property Bitmap: TBitmap read GetBitmap;
    property BoundsRect: TRect read DisplayRect;
    property Control: TcxEditingControl read GetControl;
    property HasClipping: Boolean read FHasClipping;
    property Painter: TcxCustomLookAndFeelPainterClass read GetPainter;
    property LookAndFeelPainterClass: TcxCustomLookAndFeelPainterClass read GetPainter; // todo: deprecated, for backward capability only
    property Transparent: Boolean read FTransparent write FTransparent;
    property Visible: Boolean read ItemVisible;
    property VisibleRect: TRect read ClipRect;
    property ViewParams: TcxViewParams read ItemViewParams;
  end;

  { TcxEditCellViewInfo }

  TcxEditCellViewInfo = class(TcxCustomViewInfoItem, IUnknown, IcxHotTrackElement)
  private
    function GetTransparent: Boolean;
    procedure SetTransparent(Value: Boolean);
  protected
    CellEditRect: TRect;
    CellHeight: Integer;
    CellValue: Variant;
    CellContentRect: TRect;
    CellBorders: TcxBorders;
    IsViewDataCreated: Boolean;
    Properties: TcxCustomEditProperties;
    ViewInfo: TcxCustomEditViewInfo;
    ViewData: TcxCustomEditViewData;
    // IUnknown
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // IcxHotTrackElement
    function GetOrigin: TPoint;
    function IsNeedHint(ACanvas: TcxCanvas; const P: TPoint;
      out AText: TCaption;
      out AIsMultiLine: Boolean;
      out ATextRect: TRect; var IsNeedOffsetHint: Boolean): Boolean; virtual;
    procedure UpdateHotTrackState(const APoint: TPoint); virtual;
    function CalculateEditHeight: Integer;
    function CalculateEditWidth: Integer;
    function ChangedHeight(APrevHeight, ANewHeight: Integer): Boolean; virtual;
    procedure CheckClipping(const ADisplayRect, AAvailableRect: TRect); override;
    function ContentOffset: TRect; virtual;
    procedure DoCalculate; override;
    function GetButtonTransparency: TcxEditButtonTransparency; virtual;
    function GetControl: TcxEditingControl; override;
    function GetDisplayValue: Variant; virtual;
    function GetEditContainer: TcxCustomInplaceEditContainer; virtual;
    function GetEditViewParams: TcxViewParams; virtual;
    function GetFocused: Boolean; virtual;
    function GetInplaceEditPosition: TcxInplaceEditPosition;
    function GetMaxLineCount: Integer; virtual;
    function GetRecordIndex: Integer; virtual;
    function GetSelectedTextColor: Integer; virtual;
    function GetSelectedBKColor: Integer; virtual;
    function GetViewInfoData: Pointer; virtual;
    function IsAutoHeight: Boolean; virtual;
    function IsEndEllipsis: Boolean; virtual;
    function IsSupportedHotTrack: Boolean; virtual;
    procedure SetBounds(const ABounds: TRect; const ADisplayRect: TRect);
    property EditContainer: TcxCustomInplaceEditContainer read GetEditContainer;
    property EditRect: TRect read CellEditRect;
  public
    destructor Destroy; override;
    procedure Assign(Source: TcxCustomViewInfoItem); override;
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;

    function Refresh(ARecalculate: Boolean): Boolean; virtual;
    property Borders: TcxBorders read CellBorders;
    property ContentRect: TRect read CellContentRect;
    property DisplayValue: Variant read CellValue;
    property EditViewInfo: TcxCustomEditViewInfo read ViewInfo;
    property Focused: Boolean read GetFocused;
    property MaxLineCount: Integer read GetMaxLineCount;
    property RecordIndex: Integer read GetRecordIndex;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property BoundsRect;
    property Control;
    property ViewParams;
    property VisibleRect;
  end;

  { TcxCustomControlPainter }

  TcxCustomDrawViewInfoItemEvent = procedure(Sender: TObject; Canvas: TcxCanvas;
    AViewInfo: TcxCustomViewInfoItem; var ADone: Boolean) of object;

  TcxCustomControlPainter = class
  private
    FSaveViewParams: TcxViewParams;
    FBitmap: TBitmap;
    FBitmapCanvas: TcxCanvas;
    FBuffered: Boolean;
    FControl: TcxEditingControl;
    function GetPainter: TcxCustomLookAndFeelPainterClass;
    function GetViewInfo: TcxCustomControlViewInfo;
    procedure SetBuffered(Value: Boolean);
  protected
    FCanvas: TcxCanvas;
    procedure AfterCustomDraw(AViewInfo: TcxCustomViewInfoItem); overload; virtual;
    procedure BeforeCustomDraw(AViewInfo: TcxCustomViewInfoItem); overload; virtual;
    function DoCustomDraw(AViewInfoItem: TcxCustomViewInfoItem;
      AEvent: TcxCustomDrawViewInfoItemEvent): Boolean;
    procedure DoPaintEditCell(ACellViewInfo: TcxEditCellViewInfo; AIsExcludeRect: Boolean = True); virtual;
    procedure DoPaint; virtual;
  public
    constructor Create(AOwner: TcxEditingControl); virtual;
    destructor Destroy; override;
    procedure Paint;
    property Buffered: Boolean read FBuffered write SetBuffered;
    property Canvas: TcxCanvas read FCanvas;
    property Control: TcxEditingControl read FControl;
    property Painter: TcxCustomLookAndFeelPainterClass read GetPainter;
    property ViewInfo: TcxCustomControlViewInfo read GetViewInfo;
  end;

  TcxCustomControlPainterClass = class of TcxCustomControlPainter;

  { TcxCustomControlStyles }

  TcxCustomControlStylesClass = class of TcxCustomControlStyles;
                                          
  TcxCustomControlStyles = class(TcxStyles)
  private
    FDefaultStyle: TcxStyle;
    FOnGetContentStyle: TcxOnGetContentStyleEvent;
    function GetControl: TcxEditingControl;
    function GetPainter: TcxCustomLookAndFeelPainterClass;
  protected
    procedure Changed(AIndex: Integer); override;
    function GetDefaultStyle(Index: Integer; AData: Pointer): TcxStyle;
    procedure GetDefaultViewParams(Index: Integer; AData: TObject;
      out AParams: TcxViewParams); override;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function GetBackgroundParams: TcxViewParams;
    function GetSelectionParams: TcxViewParams;
    property Control: TcxEditingControl read GetControl;
    property LookAndFeelPainter: TcxCustomLookAndFeelPainterClass read GetPainter;
  published
    property Background: TcxStyle index ecs_Background read GetValue write SetValue;
    property Content: TcxStyle index ecs_Content read GetValue write SetValue;
    property Inactive: TcxStyle index ecs_Inactive read GetValue write SetValue;
    property Selection: TcxStyle index ecs_Selection read GetValue write SetValue;
    property OnGetContentStyle: TcxOnGetContentStyleEvent read FOnGetContentStyle write FOnGetContentStyle;
    property StyleSheet;
  end;

  { TcxEditingControl }

  IcxEditingControlOptions = interface
  ['{6A041541-53E2-413B-8377-0D249356B5DF}']
    function GetOptionsBehavior: TcxControlOptionsBehavior;
    function GetOptionsData: TcxControlOptionsData;
    function GetOptionsView: TcxControlOptionsView;
    property OptionsBehavior: TcxControlOptionsBehavior read GetOptionsBehavior;
    property OptionsData: TcxControlOptionsData read GetOptionsData;
    property OptionsView: TcxControlOptionsView read GetOptionsView;
  end;

  TcxecEditingEvent = procedure(Sender, AItem: TObject; var Allow: Boolean) of object;
  TcxecInitEditEvent = procedure(Sender, AItem: TObject; AEdit: TcxCustomEdit) of object;
  TcxecItemEvent = procedure(Sender: TObject; AItem: TcxCustomInplaceEditContainer) of object;

  TcxEditingControl = class(TcxControl, IcxMouseTrackingCaller)
  private
    FBrushCache: TcxBrushCache;
    FChangesCount: Integer;
    FContainerList: TList;
    FDesignSelectionHelper: TcxCustomDesignSelectionHelper;
    FDragHelper: TcxDragImageHelper;
    FDragPos: TPoint;
    FEditStyle: TcxCustomEditStyle;
    FIsLayoutChanged: Boolean;
    FStyles: TcxCustomControlStyles;
    FViewInfo: TcxCustomControlViewInfo;
    FOnCustomDrawCell: TcxCustomDrawViewInfoItemEvent;
    FOnEditChanged: TcxecItemEvent;
    FOnEdited: TcxecItemEvent;
    FOnEditing: TcxecEditingEvent;
    FOnEditValueChanged: TcxecItemEvent;
    FOnInitEdit: TcxecInitEditEvent;
    procedure IcxMouseTrackingCaller.MouseLeave = DoMouseLeave;
    function GetBufferedPaint: Boolean;
    function GetPainter: TcxCustomControlPainter;
    procedure DoMouseLeave;
    procedure SetBufferedPaint(Value: Boolean);
    procedure SetEditStyle(Value: TcxCustomEditStyle);
    procedure SetStyles(Value: TcxCustomControlStyles);
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SetCursor;
  protected
    FController: TcxCustomControlController;
    FDataController: TcxCustomDataController;
    FLockUpdate: Integer;
    procedure AfterLayoutChanged; virtual;
    procedure BeginAutoDrag; override;
    procedure BeforeUpdate; virtual;
    procedure CheckCreateDesignSelectionHelper; virtual; 
    procedure CreateSubClasses; virtual;
    procedure ControlUpdateData(AInfo: TcxUpdateControlInfo); virtual;
    procedure DataChanged; virtual;
    procedure DataLayoutChanged; virtual;
    procedure DestroyDesignSelectionHelper;
    procedure DestroySubClasses; virtual;
    procedure DoBeginUpdate; virtual;
    procedure DoEndUpdate; virtual;
    procedure DoEditChanged(AItem: TcxCustomInplaceEditContainer); virtual;
    procedure DoEdited(AItem: TcxCustomInplaceEditContainer); virtual;
    function DoEditing(AItem: TcxCustomInplaceEditContainer): Boolean; virtual;
    procedure DoEditValueChanged(AItem: TcxCustomInplaceEditContainer); virtual;
    procedure DoInitEdit(AItem: TcxCustomInplaceEditContainer; AEdit: TcxCustomEdit); virtual;
    procedure DoInplaceEditContainerItemAdded(AItem: TcxCustomInplaceEditContainer); virtual;
    procedure DoInplaceEditContainerItemRemoved(AItem: TcxCustomInplaceEditContainer); virtual;
    procedure DoLayoutChanged; virtual;
    //
    function GetControllerClass: TcxCustomControlControllerClass; virtual;    // TODO: need overriding
    function GetControlStylesClass: TcxCustomControlStylesClass; virtual;
    function GetDataControllerClass: TcxCustomDataControllerClass; virtual;
    function GetDragImageHelperClass: TcxDragImageHelperClass; virtual;
    function GetEditStyleClass: TcxCustomEditStyleClass; virtual;
    function GetEditingControllerClass: TcxEditingControllerClass; virtual;
    function GetHitTestControllerClass: TcxHitTestControllerClass; virtual;
    function GetHotTrackControllerClass: TcxHotTrackControllerClass; virtual;
    function GetViewInfoClass: TcxCustomControlViewInfoClass; virtual;
    function GetOptions: IcxEditingControlOptions; virtual;
    function GetPainterClass: TcxCustomControlPainterClass; virtual;
    function IsLocked: Boolean; virtual;
    procedure RecreateViewInfo; virtual;
    procedure SelectionChanged(AInfo: TcxSelectionChangedInfo); virtual;
    procedure UpdateIndexes;
    procedure UpdateViewStyles;
    procedure UpdateData; virtual;
    // VCL methods
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure DoExit; override;
    procedure DblClick; override;
    procedure FocusChanged; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseEnter(AControl: TControl); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;

    // cxControl's
    procedure AfterMouseDown(AButton: TMouseButton; X, Y: Integer); override;
    procedure BoundsChanged; override;
    function CanDrag(X, Y: Integer): Boolean; override;
    procedure DoCancelMode; override;
    procedure FontChanged; override;
    function GetCursor(X, Y: Integer): TCursor; override;
    function GetDesignHitTest(X, Y: Integer; Shift: TShiftState): Boolean; override;
    function GetIsFocused: Boolean; override;
    function GetMouseWheelScrollingKind: TcxMouseWheelScrollingKind; override;
    procedure InitControl; override;
    function IsPixelScrollBar(AKind: TScrollBarKind): Boolean; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    function MayFocus: Boolean; override;
    // drag'n'drop
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    function DragDropImageDisplayRect: TRect; virtual;
    procedure DrawDragDropImage(ADragBitmap: TBitmap; ACanvas: TcxCanvas); virtual;
    procedure FinishDragImages;
    function HasDragDropImages: Boolean; virtual;
    // scrollbars
    procedure InitScrollBarsParameters; override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;

    procedure DragAndDrop(const P: TPoint; var Accepted: Boolean); override;
    procedure EndDragAndDrop(Accepted: Boolean); override;
    function GetDragAndDropObjectClass: TcxDragAndDropObjectClass; override;
    function StartDragAndDrop(const P: TPoint): Boolean; override;

    property BrushCache: TcxBrushCache read FBrushCache;
    property ContainerList: TList read FContainerList;
    property Controller: TcxCustomControlController read FController;
    property ChangesCount: Integer read FChangesCount;
    property DragPos: TPoint read FDragPos write FDragPos;
    property DataController: TcxCustomDataController read FDataController;
    property DesignSelectionHelper: TcxCustomDesignSelectionHelper read FDesignSelectionHelper;
    property DragHelper: TcxDragImageHelper read FDragHelper;
    property EditStyle: TcxCustomEditStyle read FEditStyle write SetEditStyle;
    property IsLayoutChanged: Boolean read FIsLayoutChanged write FIsLayoutChanged;
    property Options: IcxEditingControlOptions read GetOptions;
    property Painter: TcxCustomControlPainter read GetPainter;
    property Styles: TcxCustomControlStyles read FStyles write SetStyles;
    property ViewInfo: TcxCustomControlViewInfo read FViewInfo write FViewInfo;
    property OnCustomDrawCell: TcxCustomDrawViewInfoItemEvent read FOnCustomDrawCell write FOnCustomDrawCell;
    property OnEditChanged: TcxecItemEvent read FOnEditChanged write FOnEditChanged;
    property OnEdited: TcxecItemEvent read FOnEdited write FOnEdited;
    property OnEditing: TcxecEditingEvent read FOnEditing write FOnEditing;
    property OnEditValueChanged: TcxecItemEvent read FOnEditValueChanged write FOnEditValueChanged;
    property OnInitEdit: TcxecInitEditEvent read FOnInitEdit write FOnInitEdit;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure BeginDragAndDrop; override;
    procedure CancelUpdate;
    procedure EndUpdate;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure LayoutChanged;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    property BufferedPaint: Boolean read GetBufferedPaint write SetBufferedPaint;
    property LockUpdate: Integer read FLockUpdate;
    property DragCursor default crDefault;
    property TabStop default True;
  published
    property BorderStyle default cxcbsDefault;
  end;

  { TcxExtEditingControl }

  TcxExtEditingControl = class(TcxEditingControl,  IcxEditingControlOptions)
  private
    FOptionsBehavior: TcxControlOptionsBehavior;
    FOptionsData: TcxControlOptionsData;
    FOptionsView: TcxControlOptionsView;
    // IcxEditingControlOptions
    function GetOptionsBehavior: TcxControlOptionsBehavior;
    function GetOptionsData: TcxControlOptionsData;
    function GetOptionsView: TcxControlOptionsView;

    procedure SetOptionsBehavior(Value: TcxControlOptionsBehavior);
    procedure SetOptionsData(Value: TcxControlOptionsData);
    procedure SetOptionsView(Value: TcxControlOptionsView);
  protected
    procedure CreateSubClasses; override;
    procedure DestroySubClasses; override;
    function GetOptions: IcxEditingControlOptions; override;
    function GetOptionsBehaviorClass: TcxControlOptionsBehaviorClass; virtual;
    function GetOptionsDataClass: TcxControlOptionsDataClass; virtual;
    function GetOptionsViewClass: TcxControlOptionsViewClass; virtual;
    property OptionsBehavior: TcxControlOptionsBehavior read GetOptionsBehavior write SetOptionsBehavior;
    property OptionsData: TcxControlOptionsData read GetOptionsData write SetOptionsData;
    property OptionsView: TcxControlOptionsView read GetOptionsView write SetOptionsView;
  end;

  { TcxValueTypeClassRepository }

  TcxValueTypeClassRepository = class
  private
    FList: TStringList;
    function GetCount: Integer;
    function GetValueTypeClass(AIndex: Integer): TcxValueTypeClass;
    function GetDescription(AIndex: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    function FindByClassType(ATypeClass: TcxValueTypeClass): string;
    function FindByDescription(const ADescription: string): TcxValueTypeClass;
    procedure RegisterValueTypeClass(const ADescription: string; ATypeClass: TcxValueTypeClass);
    procedure UnRegisterValueTypeClass(ATypeClass: TcxValueTypeClass);
    property Count: Integer read GetCount;
    property Description[AIndex: Integer]: string read GetDescription;
    property ValueTypeClass[AIndex: Integer]: TcxValueTypeClass read GetValueTypeClass;
  end;

function cxieValueTypeClassRepository: TcxValueTypeClassRepository;
procedure cxieRegisterValueTypeClass(const ADescription: string; ATypeClass: TcxValueTypeClass);
procedure cxieUnRegisterValueTypeClass(ATypeClass: TcxValueTypeClass);

procedure cxAssignEditStyle(AViewInfo: TcxEditCellViewInfo);
function cxPtInViewInfoItem(AItem: TcxCustomViewInfoItem; const APoint: TPoint): Boolean;
procedure cxStylesToViewParams(AMasterStyles: TcxCustomControlStyles; AIndex: Integer;
  AData: Pointer; const AStyles: array of TcxStyle; out AParams: TcxViewParams);

function cxInRange(Value: Integer; AMin, AMax: Integer): Boolean;
function cxRange(var Value: Integer; AMin, AMax: Integer): Boolean;
function cxSetValue(Condition: Boolean; ATrueValue, AFalseValue: Integer): Integer;

function cxConfirmMessageBox(const AText, ACaption: string): Boolean;
procedure cxAbstractError;

{$IFNDEF DELPHI5}
function Supports(const Instance: TObject; const IID: TGUID; out Intf): Boolean;
{$ENDIF}

const
  cxIntOffs: array[Boolean] of Integer = (-1, 1);
  cxDefaultEditSizeProp: TcxEditSizeProperties = (Height: -1; MaxLineCount: 0; Width: -1);
  cxDesignSelectionHelperClass: TcxCustomDesignSelectionHelperClass = nil;

implementation

uses
  dxCore;

type
  TControlAccess = class(TControl);
  THintWindowAccess = class(THintWindow);
  TcxCustomEditStyleAccess = class(TcxCustomEditStyle);
  TcxCustomEditViewDataAccess = class(TcxCustomEditViewData);
  TcxDragAndDropObjectAccess = class(TcxDragAndDropObject);

  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxInt div SizeOf(Integer) - 1] of Integer;

var
  ValueTypeClassRepository: TcxValueTypeClassRepository;
  cxDragControl: TcxEditingControl;
  cxDragPrevHook: HHook;
  
const
  cxInvisibleCoordinate = 30000;

procedure cxAbstractError;
begin
  RunError(210);
end;

{$IFNDEF DELPHI5}
function Supports(const Instance: TObject; const IID: TGUID; out Intf): Boolean;
begin
  Result := (Instance <> nil) and Instance.GetInterface(IID, Intf);
end;
{$ENDIF}

procedure cxAssignEditStyle(AViewInfo: TcxEditCellViewInfo);
var
  AStyle: TcxCustomEditStyleAccess;
begin
  AStyle := TcxCustomEditStyleAccess(AViewInfo.Control.EditStyle);
  with AViewInfo do
  begin
    AStyle.FAssignedValues := AStyle.FAssignedValues - [svFont] + [svColor, svButtonTransparency];
    if ViewParams.Font = nil then
      AStyle.StyleData.Font := GetEditViewParams.Font
    else
      AStyle.StyleData.Font := ViewParams.Font;
    AStyle.StyleData.Color := ViewParams.Color;
    AStyle.StyleData.FontColor := ViewParams.TextColor;
    AStyle.ButtonTransparency := GetButtonTransparency;
    AStyle.Changed;
    ViewInfo.Transparent := IsTransparent;
  end;
end;

function MouseMsgHookProcForDragDrop(Code: Integer;
  WParam, LParam: Longint): Longint stdcall;
begin
  Result := CallNextHookEx(cxDragPrevHook, Code, WParam, LParam);
  if (cxDragControl <> nil) then
  begin
    case WParam of
      WM_MOUSEMOVE:
      begin
        with cxDragControl do
          if Dragging then
            DragHelper.DragAndDrop(PMouseHookStruct(LParam).Pt);
      end;
      WM_LBUTTONUP, WM_RBUTTONUP:
        cxDragControl.FinishDragImages;
    end;
  end;
end;

procedure cxInstallMouseHookForDragControl(AControl: TcxEditingControl);
begin
  cxDragControl := AControl;
  cxDragPrevHook := SetWindowsHookEx(WH_MOUSE,
    @MouseMsgHookProcForDragDrop, 0, GetCurrentThreadID);
end;

procedure cxResetMouseHookForDragControl;
begin
  try
    if cxDragPrevHook <> 0 then
      UnhookWindowsHookEx(cxDragPrevHook);
  finally
    cxDragControl := nil;
    cxDragPrevHook := 0;
  end;
end;

{ TcxCustomItemDataBinding }

constructor TcxCustomItemDataBinding.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FDefaultValuesProvider := GetDefaultValuesProviderClass.Create(Self);
end;

destructor TcxCustomItemDataBinding.Destroy;
begin
  FreeAndNil(FDefaultValuesProvider);
  inherited Destroy;
end;

function TcxCustomItemDataBinding.DefaultRepositoryItem: TcxEditRepositoryItem;
begin
  Result := GetDefaultEditDataRepositoryItems.GetItem(GetValueTypeClass);
end;

function TcxCustomItemDataBinding.GetDefaultCaption: string;
begin
  Result := '';
end;

function TcxCustomItemDataBinding.GetDefaultValuesProvider(
  AProperties: TcxCustomEditProperties): IcxEditDefaultValuesProvider;
begin
  Result := DefaultValuesProvider;
end;

function TcxCustomItemDataBinding.GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass;
begin
  Result := TcxContainerItemDefaultValuesProvider;
end;

function TcxCustomItemDataBinding.GetValueTypeClass: TcxValueTypeClass;
begin
  Result := TcxStringValueType;
end;

procedure TcxCustomItemDataBinding.Init;
begin
end;

function TcxCustomItemDataBinding.IsDisplayFormatDefined(
  AIsCurrencyValueAccepted: Boolean): Boolean;
begin
  Result :=
    DataController.IsDisplayFormatDefined(EditContainer.ItemIndex, not AIsCurrencyValueAccepted) or
    EditContainer.HasDataTextHandler;
end;

procedure TcxCustomItemDataBinding.ValueTypeClassChanged;
begin
  DataController.ChangeValueTypeClass(EditContainer.ItemIndex, GetValueTypeClass);
  EditContainer.InternalPropertiesChanged;
end;

function TcxCustomItemDataBinding.GetDataController: TcxCustomDataController;
begin
  Result := EditContainer.EditingControl.DataController;
end;

function TcxCustomItemDataBinding.GetEditContainer: TcxCustomInplaceEditContainer;
begin
  Result := TcxCustomInplaceEditContainer(GetOwner);
end;

{ TcxItemDataBinding }

procedure TcxItemDataBinding.Assign(Source: TPersistent);
begin
  if Source is TcxItemDataBinding then
  begin
    ValueType := TcxItemDataBinding(Source).ValueType;
    ValueTypeClass := TcxItemDataBinding(Source).ValueTypeClass;
  end;
end;

function TcxItemDataBinding.GetValueTypeClass: TcxValueTypeClass;
begin
  if FValueTypeClass = nil then
    Result := inherited GetValueTypeClass
  else
    Result := FValueTypeClass;
end;

function TcxItemDataBinding.IsValueTypeStored: Boolean;
begin
  Result := FValueTypeClass <> inherited GetValueTypeClass;
end;

function TcxItemDataBinding.GetValueType: string;
begin
  Result := ValueTypeClassRepository.FindByClassType(ValueTypeClass);
end;

procedure TcxItemDataBinding.SetValueType(const Value: string);
var
  ATypeClass: TcxValueTypeClass;
begin
  ATypeClass := ValueTypeClassRepository.FindByDescription(Value);
  if ATypeClass <> nil then
    ValueTypeClass := ATypeClass;
end;

procedure TcxItemDataBinding.SetValueTypeClass(Value: TcxValueTypeClass);
begin
  if ValueTypeClass <> Value then
  begin
    FValueTypeClass := Value;
    ValueTypeClassChanged;
  end;
end;

{ TcxControlDataController }

procedure TcxControlDataController.UpdateData;
begin
  GetControl.UpdateData;
end;

procedure TcxControlDataController.UpdateItemIndexes;
begin
  GetControl.UpdateIndexes;
  inherited UpdateItemIndexes;
end;

function TcxControlDataController.GetItem(Index: Integer): TObject;
begin
  Result := GetControl.FContainerList[Index];
end;

function TcxControlDataController.GetItemID(AItem: TObject): Integer;
begin
  if AItem is TcxCustomInplaceEditContainer then
    Result := TcxCustomInplaceEditContainer(AItem).ItemIndex
  else
    Result := -1;
end;

function TcxControlDataController.GetItemValueSource(
  AItemIndex: Integer): TcxDataEditValueSource;
begin
  with TcxCustomInplaceEditContainer(GetControl.FContainerList[AItemIndex]) do 
    Result := PropertiesValue.GetEditValueSource(True);
end;

procedure TcxControlDataController.UpdateControl(AInfo: TcxUpdateControlInfo);
begin
  GetControl.ControlUpdateData(AInfo);
end;

function TcxControlDataController.GetControl: TcxEditingControl;
begin
  Result := TcxEditingControl(GetOwner);
end;

{ TcxContainerItemDefaultValuesProvider }

function TcxContainerItemDefaultValuesProvider.IsDisplayFormatDefined(
 AIsCurrencyValueAccepted: Boolean): Boolean;
begin
  Result := False; 
end;

{ TcxCustomEditContainerItemOptions }

constructor TcxCustomEditContainerItemOptions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FMoving := True;
  FCustomizing := True;
  FSorting := True;
  FEditing := True;
  FFiltering := True;
  FFocusing := True;
  FIncSearch := True;
  FShowEditButtons := eisbDefault;
  FTabStop := True;
end;

procedure TcxCustomEditContainerItemOptions.Assign(AOwner: TPersistent);
begin
  if AOwner is TcxCustomEditContainerItemOptions then
    with TcxCustomEditContainerItemOptions(AOwner) do
    begin
      Self.Customizing := Customizing;
      Self.Editing := Editing;
      Self.Filtering := Filtering;
      Self.Focusing := Focusing;
      Self.IncSearch := IncSearch;
      Self.Moving := Moving;
      Self.ShowEditButtons := ShowEditButtons;
      Self.Sorting := Sorting;
      Self.TabStop := TabStop;
    end;
end;

procedure TcxCustomEditContainerItemOptions.Changed;
begin
  EditContainer.Changed;
end;

function TcxCustomEditContainerItemOptions.GetEditContainer: TcxCustomInplaceEditContainer;
begin
  Result := TcxCustomInplaceEditContainer(GetOwner);
end;

procedure TcxCustomEditContainerItemOptions.SetEditing(Value: Boolean);
begin
  if FEditing <> Value then
  begin
    FEditing := Value;
    if not Value then EditContainer.Editing := False;
  end;
end;

procedure TcxCustomEditContainerItemOptions.SetFiltering(Value: Boolean);
begin
  if FFiltering <> Value then
  begin
    FFiltering := Value;
    Changed;
  end;
end;

procedure TcxCustomEditContainerItemOptions.SetFocusing(Value: Boolean);
begin
  if FFocusing <> Value then
  begin
    FFocusing := Value;
    if not Value then EditContainer.Focused := False;
  end;
end;

procedure TcxCustomEditContainerItemOptions.SetIncSearch(Value: Boolean);
begin
  if FIncSearch <> Value then
  begin
    if not Value and EditContainer.IncSearching then
      EditContainer.CancelIncSearching;
    FIncSearch := Value;
  end;
end;

procedure TcxCustomEditContainerItemOptions.SetShowEditButtons(
  Value: TcxEditItemShowEditButtons);
begin
  if Value <> FShowEditButtons then
  begin
    FShowEditButtons := Value;
    Changed;
  end;
end;

{ TcxControlOptionsView }

constructor TcxControlOptionsView.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FShowEditButtons := ecsbNever;
end;

procedure TcxControlOptionsView.Assign(Source: TPersistent);
begin
  if Source is TcxControlOptionsView then
    with TcxControlOptionsView(Source) do
    begin
      Self.CellAutoHeight := CellAutoHeight;
      Self.CellEndEllipsis := CellEndEllipsis;
      Self.CellTextMaxLineCount := CellTextMaxLineCount;
      Self.ScrollBars := ScrollBars;
      Self.ShowEditButtons := ShowEditButtons;
    end
end;

procedure TcxControlOptionsView.Changed;
begin
  EditingControl.LayoutChanged; 
end;

function TcxControlOptionsView.GetEditingControl: TcxEditingControl;
begin
  Result := TcxEditingControl(GetOwner);
end;

function TcxControlOptionsView.GetScrollBars: TScrollStyle;
begin
  Result := EditingControl.ScrollBars;
end;

procedure TcxControlOptionsView.SetCellAutoHeight(const Value: Boolean);
begin
  if FCellAutoHeight <> Value then
  begin
    FCellAutoHeight := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsView.SetCellEndEllipsis(const Value: Boolean);
begin
  if FCellEndEllipsis <> Value then
  begin
    FCellEndEllipsis := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsView.SetCellTextMaxLineCount(
  const Value: Integer);
begin
  if FCellTextMaxLineCount <> Value then
  begin
    FCellTextMaxLineCount := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsView.SetScrollBars(const Value: TScrollStyle);
begin
  EditingControl.ScrollBars := Value;
end;

procedure TcxControlOptionsView.SetShowEditButtons(
  const Value: TcxEditingControlEditShowButtons);
begin
  if FShowEditButtons <> Value then
  begin
    FShowEditButtons := Value;
    Changed;
  end;
end;

{ TcxControlOptionsData }

constructor TcxControlOptionsData.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FCancelOnExit := True;
  FEditing := True;
end;

procedure TcxControlOptionsData.Assign(Source: TPersistent);
begin
  if Source is TcxControlOptionsData then
    with TcxControlOptionsData(Source) do
    begin
      Self.CancelOnExit := CancelOnExit;
      Self.Editing := Editing;
    end
end;

procedure TcxControlOptionsData.Changed;
begin
end;

function TcxControlOptionsData.GetEditingControl: TcxEditingControl;
begin
  Result := TcxEditingControl(GetOwner)
end;

procedure TcxControlOptionsData.SetEditing(Value: Boolean);
begin
  if FEditing <> Value then
  begin
    FEditing := Value;
    if not Value then
      EditingControl.Controller.EditingItem := nil;
    Changed;
  end;
end;

{ TcxControlOptionsBehavior }

constructor TcxControlOptionsBehavior.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FImmediateEditor := True;
end;

procedure TcxControlOptionsBehavior.Assign(Source: TPersistent);
begin
  if Source is TcxControlOptionsBehavior then
    with TcxControlOptionsBehavior(Source) do
    begin
      Self.AlwaysShowEditor := AlwaysShowEditor;
      Self.CellHints := CellHints;
      Self.FocusCellOnCycle := FocusCellOnCycle;
      Self.FocusFirstCellOnNewRecord := FocusFirstCellOnNewRecord;
      Self.GoToNextCellOnEnter := GoToNextCellOnEnter;
      Self.GoToNextCellOnTab := GoToNextCellOnTab;
      Self.ImmediateEditor := ImmediateEditor;
    end
end;

procedure TcxControlOptionsBehavior.Changed;
begin
  if EditingControl.Controller <> nil then
    EditingControl.Controller.BehaviorChanged;
end;

function TcxControlOptionsBehavior.GetEditingControl: TcxEditingControl;
begin
  Result := TcxEditingControl(GetOwner);
end;

procedure TcxControlOptionsBehavior.SetAlwaysShowEditor(Value: Boolean);
begin
  if FAlwaysShowEditor <> Value then
  begin
    FAlwaysShowEditor := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetCellHints(Value: Boolean);
begin
  if FCellHints <> Value then
  begin
    FCellHints := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetFocusCellOnCycle(Value: Boolean);
begin
  if FFocusCellOnCycle <> Value then
  begin
    FFocusCellOnCycle := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetFocusFirstCellOnNewRecord(
  Value: Boolean);
begin
  if FFocusFirstCellOnNewRecord <> Value then
  begin
    FFocusFirstCellOnNewRecord := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetGoToNextCellOnEnter(Value: Boolean);
begin
  if FGoToNextCellOnEnter <> Value then
  begin
    FGoToNextCellOnEnter := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetGoToNextCellOnTab(Value: Boolean);
begin
  if FGoToNextCellOnTab <> Value then
  begin
    FGoToNextCellOnTab := Value;
    with EditingControl do
      if Value then
        Keys := Keys + [kTab]
      else
        Keys := Keys - [kTab];
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetImmediateEditor(Value: Boolean);
begin
  if FImmediateEditor <> Value then
  begin
    FImmediateEditor := Value;
    Changed;
  end;
end;

procedure TcxControlOptionsBehavior.SetIncSearch(Value: Boolean);
begin
  if Value <> FIncSearch then
  begin
    FIncSearch := Value;
    if not Value then
      EditingControl.Controller.CancelIncSearching;
  end;
end;

procedure TcxControlOptionsBehavior.SetIncSearchItem(Value: TcxCustomInplaceEditContainer);
begin
  if Value <> FIncSearchItem then
  begin
    FIncSearchItem := Value;
    EditingControl.Controller.CancelIncSearching;
  end;
end;

{ TcxEditContainerStyles }

procedure TcxEditContainerStyles.Assign(Source: TPersistent);
begin
  if Source is TcxEditContainerStyles then
    Content := TcxEditContainerStyles(Source).Content;
  inherited Assign(Source);
end;

procedure TcxEditContainerStyles.Changed(AIndex: Integer);
begin
  inherited Changed(AIndex);
  Control.UpdateViewStyles;
end;

function TcxEditContainerStyles.GetContainer: TcxCustomInplaceEditContainer;
begin
  Result := TcxCustomInplaceEditContainer(GetOwner);
end;

function TcxEditContainerStyles.GetControl: TcxEditingControl;
begin
  Result := Container.EditingControl;
end;

function TcxEditContainerStyles.GetControlStyles: TcxCustomControlStyles;
begin
  Result := Control.Styles;
end;

{ TcxCustomInplaceEditContainer }

constructor TcxCustomInplaceEditContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataBinding := GetDataBindingClass.Create(Self);
  FOptions := GetOptionsClass.Create(Self);
  FStyles := GetStylesClass.Create(Self);
end;

destructor TcxCustomInplaceEditContainer.Destroy;
begin
  if not EditingControl.IsDestroying and EditingControl.IsDesigning and
    (Controller.DesignSelectionHelper <> nil) then
      Controller.DesignSelectionHelper.UnselectObject(Self);
  RepositoryItem := nil;
  EditingControl := nil;
  FOptions.Free;
  FDataBinding.Free;
  FStyles.Free;
  DestroyProperties;
  inherited Destroy;
end;

procedure TcxCustomInplaceEditContainer.Assign(Source: TPersistent);
begin
  if Source is TcxCustomInplaceEditContainer then
    with TcxCustomInplaceEditContainer(Source) do
    begin
      Self.DataBinding := DataBinding;
      Self.PropertiesClassName := PropertiesClassName;
      Self.Properties := Properties;
      Self.RepositoryItem := RepositoryItem;
      Self.Styles := Styles;
      Self.OnGetEditProperties := OnGetEditProperties;
    end
end;

procedure TcxCustomInplaceEditContainer.CalculateEditViewInfo(
  const AValue: Variant; AEditViewInfo: TcxEditCellViewInfo; const APoint: TPoint);
var
  ACanvas: TcxCanvas;
begin
  ACanvas := GetControlCanvas;
  cxAssignEditStyle(AEditViewInfo);
  with AEditViewInfo do
  begin
    if IncSearching and (Controller.IncSearchingItem  = Self) and
      (Controller.FocusedRecordIndex = RecordIndex) then
      with ViewData do
      begin
        SelTextColor := GetSelectedTextColor;
        SelBackgroundColor := GetSelectedBKColor;
        SelStart := 0;
        SelLength := Length(Controller.IncSearchingText);
      end
    else
      ViewData.SelLength := 0;
    ViewData.MaxLineCount := AEditViewInfo.MaxLineCount;
    ViewData.EditValueToDrawValue(ACanvas, AValue, ViewInfo);
    ViewData.ContentOffset := ContentOffset;
    ViewData.CalculateEx(ACanvas, ContentRect, APoint, cxmbNone, [], ViewInfo, False);
  end;
end;

function TcxCustomInplaceEditContainer.CanEdit: Boolean;
begin
  Result := CanFocus and EditingControl.Options.OptionsData.Editing and
    FOptions.Editing and (dceoShowEdit in DataController.EditOperations) and
    (DataController.RecordCount > 0);
end;

function TcxCustomInplaceEditContainer.CanFocus: Boolean;
begin
  Result := Options.FFocusing;
end;

procedure TcxCustomInplaceEditContainer.CancelIncSearching;
begin
  Controller.CancelIncSearching;
end;

function TcxCustomInplaceEditContainer.CanInitEditing: Boolean;
begin
  Result := DataController.CanInitEditing(ItemIndex);
end;

function TcxCustomInplaceEditContainer.CanIncSearch: Boolean;
begin
  Result := (esoIncSearch in FPropertiesValue.GetSupportedOperations) and
    EditingControl.Options.OptionsBehavior.IncSearch and Options.IncSearch;
end;

function TcxCustomInplaceEditContainer.CanTabStop: Boolean;
begin
  Result := Options.TabStop;
end;

procedure TcxCustomInplaceEditContainer.Changed;
begin
  if EditingControl <> nil then
    EditingControl.UpdateViewStyles;
end;

function TcxCustomInplaceEditContainer.CreateEditViewData(
  AProperties: TcxCustomEditProperties; AEditStyleData: Pointer): TcxCustomEditViewData;
begin
  Result := AProperties.CreateViewData(GetEditStyle(AEditStyleData), True);
  Result.OnGetDisplayText := EditViewDataGetDisplayTextHandler;
end;

procedure TcxCustomInplaceEditContainer.DataChanged;
begin
  FDataBinding.Init;
  InternalPropertiesChanged;
end;

procedure TcxCustomInplaceEditContainer.DoGetDisplayText(
  ARecordIndex: Integer; var AText: string);
begin
end;

function TcxCustomInplaceEditContainer.DoGetEditProperties(
  AData: Pointer): TcxCustomEditProperties;
begin
  Result :=
    DoGetPropertiesFromEvent(FOnGetEditProperties, AData, FPropertiesValue);
end;

procedure TcxCustomInplaceEditContainer.DoGetEditingProperties(AData: Pointer;
  var AProperties: TcxCustomEditProperties);
begin
  AProperties :=
    DoGetPropertiesFromEvent(FOnGetEditingProperties, AData, AProperties);
end;

function TcxCustomInplaceEditContainer.DoGetPropertiesFromEvent(
  AEvent: TcxGetEditPropertiesEvent; AData: Pointer;
  AProperties: TcxCustomEditProperties): TcxCustomEditProperties;
begin
  Result := AProperties;
  if Assigned(AEvent) then
  begin
    AEvent(Self, AData, Result);
    if Result = nil then
      Result := AProperties;
  end;
  InitProperties(Result);
end;

procedure TcxCustomInplaceEditContainer.DoOnPropertiesChanged(Sender: TObject);
begin
  InternalPropertiesChanged;
end;

procedure TcxCustomInplaceEditContainer.EditViewDataGetDisplayTextHandler(
  Sender: TcxCustomEditViewData; var AText: string);
begin
  if Sender <> nil then
    DoGetDisplayText(Sender.InplaceEditParams.Position.RecordIndex, AText);
end;

function TcxCustomInplaceEditContainer.GetDefaultEditProperties: TcxCustomEditProperties;
begin
  if FRepositoryItem <> nil then
    Result := FRepositoryItem.Properties
  else
    if FProperties <> nil then
      Result := FProperties
    else
      Result := DataBinding.DefaultRepositoryItem.Properties;
end;

function TcxCustomInplaceEditContainer.GetControlCanvas: TcxCanvas;
begin
  if (EditingControl <> nil) and EditingControl.HandleAllocated then
    Result := EditingControl.Canvas
  else
    Result := cxScreenCanvas;
end;

function TcxCustomInplaceEditContainer.GetController: TcxCustomControlController;
begin
  Result := EditingControl.Controller;
end;

function TcxCustomInplaceEditContainer.GetCurrentValue: Variant;
begin
  with DataController do
    Result := Values[FocusedRecordIndex, ItemIndex];
end;

function TcxCustomInplaceEditContainer.GetDataBindingClass: TcxItemDataBindingClass;
begin
  Result := TcxItemDataBinding;
end;

function TcxCustomInplaceEditContainer.GetDefaultCaption: string;
begin
  Result := DataBinding.GetDefaultCaption;
end;

function TcxCustomInplaceEditContainer.GetDisplayValue(
  AProperties: TcxCustomEditProperties; ARecordIndex: Integer): Variant;
begin
  if AProperties.GetEditValueSource(False) = evsValue then
    Result := Values[ARecordIndex]
  else
    Result := DataController.DisplayTexts[ARecordIndex, ItemIndex];
end;

function TcxCustomInplaceEditContainer.GetEditDataValueTypeClass: TcxValueTypeClass;
begin
  Result := FDataBinding.GetValueTypeClass;
end;

function TcxCustomInplaceEditContainer.GetEditDefaultHeight(AFont: TFont): Integer;
var
  ASizeProp: TcxEditSizeProperties;
begin
  ASizeProp := cxDefaultEditSizeProp;
  EditViewData.Style.Font := AFont;
  if AFont = nil then
    EditViewData.Style.Font := EditingControl.Font;
  EditViewData.ContentOffset := cxNullRect;
  Result := EditViewData.GetEditSize(GetControlCanvas, Null, ASizeProp).cy;
end;

function TcxCustomInplaceEditContainer.GetEditHeight(
  AEditViewInfo: TcxEditCellViewInfo): Integer;
var
  ASizeProp: TcxEditSizeProperties;
begin
  ASizeProp := cxDefaultEditSizeProp;
  with AEditViewInfo do
  begin
    ViewData.Style.Font := ViewParams.Font;
    if ViewParams.Font = nil then
      EditViewData.Style.Font := EditingControl.Font;
    ViewData.ContentOffset := ContentOffset;
    ASizeProp.Width := cxRectWidth(ContentRect);
    ASizeProp.MaxLineCount := MaxLineCount;
    Result := ViewData.GetEditSize(GetControlCanvas, DisplayValue, ASizeProp).cy;
    Inc(Result, Byte(bBottom in Borders));
    Inc(Result, Byte(bTop in Borders));
  end;
end;

function TcxCustomInplaceEditContainer.GetEditWidth(
  AEditViewInfo: TcxEditCellViewInfo): Integer;
var
  ASizeProp: TcxEditSizeProperties;
begin
  ASizeProp := cxDefaultEditSizeProp;
  with AEditViewInfo do
  begin
    ViewData.Style.Font := ViewParams.Font;
    ViewData.ContentOffset := ContentOffset;
    ASizeProp.MaxLineCount := MaxLineCount;
    Result := ViewData.GetEditSize(GetControlCanvas, DisplayValue, ASizeProp).cx;
  end;
end;

function TcxCustomInplaceEditContainer.GetOptionsClass: TcxCustomEditContainerItemOptionsClass;
begin
  Result := TcxCustomEditContainerItemOptions;
end;

function TcxCustomInplaceEditContainer.GetStylesClass: TcxEditContainerStylesClass;
begin
  Result := TcxEditContainerStyles;
end;

function TcxCustomInplaceEditContainer.GetValue(ARecordIndex: Integer): Variant;
begin
  Result := DataController.Values[ARecordIndex, ItemIndex];
end;

function TcxCustomInplaceEditContainer.GetValueCount: Integer;
begin
  if FEditingControl <> nil then
    Result := DataController.RecordCount
  else
    Result := 0;
end;

function TcxCustomInplaceEditContainer.HasDataTextHandler: Boolean;
begin
  Result := False;
end;

function TcxCustomInplaceEditContainer.GetEditing: Boolean;
begin
  Result := Controller.EditingItem = Self;
end;

function TcxCustomInplaceEditContainer.GetEditStyle(AData: Pointer): TcxCustomEditStyle;
begin
  Result := EditingControl.EditStyle
end;

function TcxCustomInplaceEditContainer.GetEditValue: Variant;
begin
  if Editing then
  begin
    if DataController.RecordCount = 0 then
      Result := Null
    else
      Result := DataController.GetEditValue(ItemIndex, FEditValueSource);
  end
  else
    Result := Unassigned;
end;

procedure TcxCustomInplaceEditContainer.PropertiesChanged;
begin
  Changed;
end;

procedure TcxCustomInplaceEditContainer.SetCurrentValue(const Value: Variant);
begin
  with DataController do
    Values[FocusedRecordIndex, ItemIndex] := Value;
end;

procedure TcxCustomInplaceEditContainer.SetEditing(Value: Boolean);
begin
  if Value then
    Controller.EditingItem := Self
  else
    if Editing then
      Controller.EditingItem := nil;
end;

procedure TcxCustomInplaceEditContainer.SetEditingControl(
  Value: TcxEditingControl);
begin
  if FEditingControl <> Value then
  begin
    if Value <> nil then
      Value.ViewInfo.State[cvis_StyleInvalid] := True;
    if FEditingControl <> nil then
      FEditingControl.DoInplaceEditContainerItemRemoved(Self);
    FEditingControl := Value;
    if FEditingControl <> nil then
    begin
      FEditingControl.BeginUpdate;
      try
        FEditingControl.DoInplaceEditContainerItemAdded(Self);
        DataBinding.ValueTypeClassChanged;
      finally
        FEditingControl.CancelUpdate;
        InternalPropertiesChanged;
      end; 
    end;
  end;
end;

procedure TcxCustomInplaceEditContainer.SetEditValue(const Value: Variant);
begin
  if Editing then
    DataController.SetEditValue(ItemIndex, Value, FEditValueSource);
end;

procedure TcxCustomInplaceEditContainer.SetValue(
  ARecordIndex: Integer; const Value: Variant);
begin
  DataController.Values[ARecordIndex, ItemIndex] := Value;
end;

function TcxCustomInplaceEditContainer.GetDataController: TcxCustomDataController;
begin
  Result := FEditingControl.DataController;
end;

function TcxCustomInplaceEditContainer.GetFocused: Boolean;
begin
  Result := Controller.FocusedItem = Self;
end;

function TcxCustomInplaceEditContainer.GetFocusedCellViewInfo: TcxEditCellViewInfo;
begin
  Result := Controller.GetFocusedCellViewInfo(Self);
end;

function TcxCustomInplaceEditContainer.GetIncSearching: Boolean;
begin
  Result := Controller.IncSearchingItem = Self;
end;

function TcxCustomInplaceEditContainer.GetProperties: TcxCustomEditProperties;
begin
  Result := FProperties; 
end;

function TcxCustomInplaceEditContainer.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := FPropertiesClass;
end;

function TcxCustomInplaceEditContainer.GetPropertiesClassName: string;
begin
  if FProperties = nil then
    Result := ''
  else
    Result := FProperties.ClassName;
end;

function TcxCustomInplaceEditContainer.GetPropertiesValue: TcxCustomEditProperties;
begin
  Result := FPropertiesValue;
  Result.LockUpdate(True);
  if FDataBinding = nil then
    Result.IDefaultValuesProvider := nil
  else
    Result.IDefaultValuesProvider := FDataBinding.DefaultValuesProvider;
  Result.LockUpdate(False);
end;

procedure TcxCustomInplaceEditContainer.SetDataBinding(Value: TcxCustomItemDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxCustomInplaceEditContainer.SetFocused(Value: Boolean);
begin
  if Value then
    Controller.FocusedItem := Self
  else
    if Focused then
      // TODO:
{      if not Controller.FocusNextItem(VisibleIndex, True, True, False) then
        Controller.FocusedItem := nil;}
end;

procedure TcxCustomInplaceEditContainer.SetOptions(
  Value: TcxCustomEditContainerItemOptions);
begin
  FOptions.Assign(Value);
end;

procedure TcxCustomInplaceEditContainer.SetProperties(
  Value: TcxCustomEditProperties);
begin
  if (FProperties <> nil) and (Value <> nil) then
    FProperties.Assign(Value);
end;

procedure TcxCustomInplaceEditContainer.SetPropertiesClass(
  Value: TcxCustomEditPropertiesClass);
begin
  if FPropertiesClass <> Value then
  begin
    FPropertiesClass := Value;
    RecreateProperties;
  end;
end;

procedure TcxCustomInplaceEditContainer.SetPropertiesClassName(
  const Value: string);
begin
  if PropertiesClassName <> Value then
  begin
    with GetRegisteredEditProperties do
      PropertiesClass := TcxCustomEditPropertiesClass(FindByClassName(Value));
  end;
end;

procedure TcxCustomInplaceEditContainer.SetRepositoryItem(
  Value: TcxEditRepositoryItem);
begin
  if FRepositoryItem <> Value then
  begin
    if FRepositoryItem <> nil then
    begin
      FRepositoryItem.RemoveListener(Self);
      Controller.EditingController.RemoveEdit(FRepositoryItem.Properties);
    end;
    FRepositoryItem := Value;
    if FRepositoryItem <> nil then
      FRepositoryItem.AddListener(Self);
    InternalPropertiesChanged;
  end;
end;

procedure TcxCustomInplaceEditContainer.SetStyles(
  Value: TcxEditContainerStyles);
begin
  FStyles.Assign(Value);
end;

procedure TcxCustomInplaceEditContainer.CreateProperties;
begin
  if FPropertiesClass <> nil then
    FProperties := FPropertiesClass.Create(Self);
  InternalPropertiesChanged;
end;

procedure TcxCustomInplaceEditContainer.DestroyProperties;
begin
  FreeAndNil(FEditData);
  FreeAndNil(FEditViewData);
  FreeAndNil(FProperties);
end;

procedure TcxCustomInplaceEditContainer.InitEditViewInfo(
  AEditViewInfo: TcxEditCellViewInfo);

  procedure CheckOption(IsSetValue: Boolean; Value: TcxEditPaintOption);
  begin
    if IsSetValue then
      Include(AEditViewInfo.ViewData.PaintOptions, Value)
    else
      Exclude(AEditViewInfo.ViewData.PaintOptions, Value);
  end;

var
  AProp: TcxCustomEditProperties;
begin
  with AEditViewInfo do
  begin
    AProp := Properties;
    Properties := DoGetEditProperties(GetViewInfoData);
    CellValue := GetDisplayValue;
    ItemViewParams := GetEditViewParams;
    if (AProp = nil) or (AProp <> Properties) then
    begin
      try
        if IsViewDataCreated then
          FreeAndNil(ViewData);
        FreeAndNil(ViewInfo);
      finally
        if Properties = FPropertiesValue then
          ViewData := EditViewData
        else
          ViewData := CreateEditViewData(Properties, GetViewInfoData);
        IsViewDataCreated := ViewData <> EditViewData;
        ViewInfo := TcxCustomEditViewInfo(Properties.GetViewInfoClass.Create);
        if not IsViewDataCreated then
          TcxCustomEditViewDataAccess(ViewData).InitCacheData;
      end;
    end
    else
      if not IsViewDataCreated then ViewData := EditViewData;
    CheckOption(IsAutoHeight, epoAutoHeight);
    CheckOption(IsEndEllipsis, epoShowEndEllipsis);
    ViewData.InplaceEditParams.Position.RecordIndex := RecordIndex;
    ViewData.InplaceEditParams.Position.Item := Self;
  end;
end;

procedure TcxCustomInplaceEditContainer.InitProperties(
  AProperties: TcxCustomEditProperties);
begin
  with AProperties do
  begin
    LockUpdate(True);
    try
      IDefaultValuesProvider := DataBinding.GetDefaultValuesProvider(AProperties);
    finally
      LockUpdate(False);
    end;
  end;
end;

procedure TcxCustomInplaceEditContainer.InternalPropertiesChanged;
begin
  if IsDestroying then Exit;
  if not Controller.IsEditing and not Controller.FEditingController.FEditHiding then
    FreeAndNil(FEditData);
  FreeAndNil(FEditViewData);
  FPropertiesValue := GetDefaultEditProperties;
  InitProperties(FPropertiesValue);
  if EditingControl <> nil then
    FEditViewData := CreateEditViewData(FPropertiesValue, nil);
  with FPropertiesValue do
  begin
    if not Assigned(OnPropertiesChanged) then
      OnPropertiesChanged := DoOnPropertiesChanged;
  end;
  PropertiesChanged;
end;

function TcxCustomInplaceEditContainer.IsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

function TcxCustomInplaceEditContainer.IsEditPartVisible: Boolean;
begin
  Result := (FocusedCellViewInfo <> nil) and
    not IsRectEmpty(FocusedCellViewInfo.VisibleRect); 
end;

procedure TcxCustomInplaceEditContainer.RecreateProperties;
begin
  DestroyProperties;
  CreateProperties;
end;

procedure TcxCustomInplaceEditContainer.RepositoryItemPropertiesChanged(
  Sender: TcxEditRepositoryItem);
begin
  DoOnPropertiesChanged(Sender);
end;

procedure TcxCustomInplaceEditContainer.RepositoryItemRemoved(Sender: TcxEditRepositoryItem);
begin
  RepositoryItem := nil;
end;

{ TcxHotTrackController }

constructor TcxHotTrackController.Create(AControl: TcxEditingControl);
begin
  FControl := AControl;
  HintTimer := TcxTimer.Create(nil);
  HintWindow := HintWindowClass.Create(nil);
  HintWindow.Color := Application.HintColor;
  ResetTimer;
end;

destructor TcxHotTrackController.Destroy;
begin
  HintWindow.Free;
  HintTimer.Free;
  inherited Destroy;
end;

procedure TcxHotTrackController.CancelHint;
begin
  InternalHideHint(HintTimer);
end;

procedure TcxHotTrackController.Clear;
begin
  PrevHitPoint := cxInvalidPoint;
  PrevElement := nil;
end;

procedure TcxHotTrackController.SetHotElement(AElement: TObject;
  const APoint: TPoint);

  procedure CalculateHotState(AObject: TObject; const P: TPoint);
  var
    AIntf: IcxHotTrackElement;
  begin
    if Supports(AObject, IcxHotTrackElement, AIntf) then
      AIntf.UpdateHotTrackState(P);
  end;

begin
  if Control.IsLocked then
    Clear
  else
    try
      if AElement <> PrevElement then
      begin
        HintElement := PrevElement;
        CalculateHotState(PrevElement, cxInvalidPoint);
        CalculateHotState(AElement, APoint);
      end
      else
        if Int64(PrevHitPoint) <> Int64(APoint) then
          CalculateHotState(AElement, APoint);
    finally
      PrevHitPoint := APoint;
      PrevElement := AElement;
      if AElement <> HintElement then CancelHint;
      if HintNeeded then InternalShowHint(Self);
    end;
end;

type
  TCustomFormAccess = class(TCustomForm);

function TcxHotTrackController.CanShowHint: Boolean;    
var
  AForm: TCustomForm;
begin
  Result := FShowHint and not Control.Controller.LockShowHint;
  if Result then
  begin
    AForm := GetParentForm(Control);
    Result := ((AForm = nil) or AForm.Active or
     (TCustomFormAccess(AForm).FormStyle = fsMDIForm) and Application.Active) and
     not Control.IsDesigning and not Control.Dragging and
     (Control.DragAndDropState = ddsNone) and
     not ((Control.Controller.GetEditingViewInfo = PrevElement) and
       Control.Controller.IsEditing);
  end;
end;

procedure TcxHotTrackController.CheckDestroyingElement(AElement: TObject);
begin
  if (AElement = PrevElement) or (AElement = HintElement) then
  begin
    if AElement = PrevElement then
      PrevElement := nil;
    if AElement = HintElement then
    begin
      CancelHint;
      HintElement := nil;
    end;
    SetHotElement(nil, cxInvalidPoint);
  end;
end;

procedure TcxHotTrackController.CheckHintClass;
begin
  if HintWindow.ClassType <> HintWindowClass then
  begin
    HintWindow.Free;
    HintWindow := HintWindowClass.Create(nil);
  end;
end;

procedure TcxHotTrackController.DoHideHint;
begin
end;

procedure TcxHotTrackController.DoShowHint;
begin
end;

function TcxHotTrackController.HintNeeded: Boolean;
var
  P: TPoint;
  AIntf: IcxHotTrackElement;
  AIsNeedOffsetHint: Boolean;
begin
  Result := Supports(PrevElement, IcxHotTrackElement, AIntf) and CanShowHint;
  if Result then
  begin
    CheckHintClass;
    AIsNeedOffsetHint := False;
    P := cxPoint(PrevHitPoint.X, PrevHitPoint.Y);
    Result := AIntf.IsNeedHint(cxScreenCanvas, P, Hint, HintIsMultiLine,
      HintRect, AIsNeedOffsetHint);
    if Result then
    begin
      P := Control.ClientToScreen(AIntf.GetOrigin);
      if AIsNeedOffsetHint then Inc(P.Y, cxGetCursorSize.cy);
      THintWindowAccess(HintWindow).Canvas.Font.Assign(cxScreenCanvas.Font);
      if PrevElement is TcxEditCellViewInfo then
      begin
        Dec(P.X);
        Dec(P.Y);
      end;
      HintRect := cxRectOffset(HintWindow.CalcHintRect(Screen.Width, Hint, nil), P.X, P.Y);
    end;
  end;
end;

procedure TcxHotTrackController.InitTimer(
  AInterval: Integer; AEnabled: Boolean; const AHandler: TNotifyEvent);
begin
  with HintTimer do
  begin
    Enabled := False;
    Interval := AInterval;
    OnTimer := AHandler;
    Enabled :=  AEnabled;
  end;
end;

procedure TcxHotTrackController.InternalHideHint(Sender: TObject);
begin
  if HintVisible then
  try
    DoHideHint;
  finally
    HintVisible := False;
    ShowWindow(HintWindow.Handle, SW_HIDE); //MUST USE ShowWindow - WIN32 BUG
    ResetTimer;
  end;
end;

procedure TcxHotTrackController.InternalShowHint(Sender: TObject);
begin
  if not HintVisible and (HintElement <> PrevElement) then
  begin
    DoShowHint;
    HintElement := PrevElement;
    HintVisible := True;
    HintWindow.ActivateHint(HintRect, Hint);
    InitTimer(Application.HintHidePause, (Application.HintHidePause > 0), InternalHideHint);
  end;
end;

procedure TcxHotTrackController.ResetTimer;
begin
  InitTimer(Application.HintPause, False, InternalShowHint);
end;

{ TcxEditingController }

constructor TcxEditingController.Create(AController: TcxCustomControlController);
begin
  inherited Create;
  FController := AController;
  FEditList := TcxInplaceEditList.Create(Controller.EditingControl);
end;

destructor TcxEditingController.Destroy;
begin
  StopEditShowingTimer;
  FEditList.Free;
  inherited Destroy;
end;

function TcxEditingController.GetEditingControl: TcxEditingControl;
begin
  Result := FController.EditingControl;
end;

function TcxEditingController.GetEditingProperties: TcxCustomEditProperties;
begin
  if IsEditing and not EditingControl.IsDestroying then
    with Controller.EditingViewInfo do
    begin
      Result := EditContainer.DoGetEditProperties(GetViewInfoData);
      EditContainer.DoGetEditingProperties(GetViewInfoData, Result);
    end
  else
    Result := nil;
end;

function TcxEditingController.GetIsDragging: Boolean;
begin
  with EditingControl do
    Result := Dragging or (DragAndDropState = ddsInProcess);
end;

function TcxEditingController.GetIsEditing: Boolean;
begin
  Result := FEditingItem <> nil;
end;

procedure TcxEditingController.SetEditingItem(Value: TcxCustomInplaceEditContainer);
begin
  if FEditingItem <> Value then
  begin
    if FEditingItemSetting then Exit;
    FEditingItemSetting := True;
    try
      if Value <> nil then
      begin
        if not Value.CanEdit or not EditingControl.DoEditing(Value) then Exit;
        Value.Focused := True;
      end;
      HideEdit(False);
      FEditingItem := Value;
      if IsEditing then
        try
          ShowEdit(Value);
          if not FEditPreparing and (FEdit = nil) then
            FEditingItem := nil;
        except
          FEditingItem := nil;
          raise;
        end;
    finally
      FEditingItemSetting := False;
    end;
  end;
end;

procedure TcxEditingController.EditShowingTimerHandler(Sender: TObject);
begin
  StopEditShowingTimer;
  FEditShowingTimerItem.Editing := True;
  Controller.FEditingBeforeDrag := Controller.IsEditing;
end;

procedure TcxEditingController.AfterViewInfoCalculate;
begin
  if IsEditing and (not FIsEditPlaced or FEditingItem.IsEditPartVisible) then
  begin
    CancelEditUpdatePost;
    FEdit.Left := cxInvisibleCoordinate;
  end;
end;

procedure TcxEditingController.BeforeViewInfoCalculate;
begin
  FIsEditPlaced := False;
end;

procedure TcxEditingController.CancelEditUpdatePost;
begin
  FEditUpdateNeeded := False;
end;

function TcxEditingController.CanRemoveEditFocus: Boolean;
begin
  Result := not (IsEditing and FEdit.IsFocused and not FEditHiding);
end;

function TcxEditingController.CanUpdateEditValue: Boolean;
begin
  Result := IsEditing and not FEditHiding and not FInitiatingEditing and
    not FEdit.IsPosting;
end;

procedure TcxEditingController.CheckEditUpdatePost;
begin
  if FEditUpdateNeeded then DoUpdateEdit;
end;

procedure TcxEditingController.AssignEditEvents;
begin
  with FEdit do
  begin
    OnAfterKeyDown := EditAfterKeyDown;
    OnEditing := EditEditing;
    OnPostEditValue := EditPostEditValue;
    OnExit := EditExit;
    OnDblClick := EditDblClick;
    OnFocusChanged := EditFocusChanged;
    OnKeyDown := EditKeyDown;
    OnKeyPress := EditKeyPress;
    OnKeyUp := EditKeyUp;
    InternalProperties.OnChange := EditChanged;
    InternalProperties.OnEditValueChanged := EditValueChanged;
  end;
end;

procedure TcxEditingController.UnassignEditEvents;
begin
  with FEdit do
  begin
    OnAfterKeyDown := nil;
    OnEditing := nil;
    OnPostEditValue := nil;
    OnExit := nil;
    OnDblClick := nil;
    OnFocusChanged := nil;
    OnKeyDown := nil;
    OnKeyPress := nil;
    OnKeyUp := nil;
    InternalProperties.OnChange := FPrevEditOnChange;
    InternalProperties.OnEditValueChanged := FPrevEditOnEditValueChanged;
  end;
end;

procedure TcxEditingController.DoUpdateEdit;
var
  AEditViewInfo: TcxEditCellViewInfo;
begin
  CancelEditUpdatePost;
  if IsEditing and (FEdit <> nil) then
  begin
    with Controller do
    begin
      BeforeShowEdit;
      AEditViewInfo := GetFocusedCellViewInfo(FFocusedItem);
    end; 
    if (AEditViewInfo = nil) or
      not AEditViewInfo.Visible or cxRectIsEmpty(AEditViewInfo.EditRect) then
       FEdit.Left := cxInvisibleCoordinate
    else
      begin
        if FEditPreparing then
        begin
          AEditViewInfo.Refresh(False);
          cxAssignEditStyle(AEditViewInfo);
          FEdit.Style.Assign(EditingControl.EditStyle);
        end;
        FEdit.BoundsRect := AEditViewInfo.EditRect;
        FEdit.Visible := True;
      end;
  end;
end;

function TcxEditingController.GetHideEditOnExit: Boolean;
begin
  Result := not Controller.GetAlwaysShowEditor or Controller.EditingControl.IsFocused;
end;

function TcxEditingController.GetHideEditOnFocusedRecordChange: Boolean;
begin
//TODO
  Result := not FController.GetAlwaysShowEditor or
    (FEditingItem <> nil) and Assigned(FEditingItem.OnGetEditProperties) {or FEditingItem.ShowButtons(False)} or
//  (esoAlwaysHotTrack in FEditingItem.FocusedCellViewInfo.Properties.GetSupportedOperations)) or  // TODO: HitTestController
    Assigned(EditingControl.OnEditing) or Assigned(EditingControl.OnInitEdit);
end;

procedure TcxEditingController.HideInplaceEditor;
begin
  if FEdit <> nil then
  begin
    UnassignEditEvents;
    FEdit.EditModified := False;
    FController.AllowCheckEdit := False;
    try
      FController.SetFocus;
    finally
      FController.AllowCheckEdit := True;
    end;
    FEdit.Visible := False;
    FEdit := nil;
  end;
end;

procedure TcxEditingController.InitEdit;
begin
  with FEdit.InternalProperties do
  begin
    FPrevEditOnChange := OnChange;
    FPrevEditOnEditValueChanged := OnEditValueChanged;
    OnChange := nil;
    OnEditValueChanged := nil;
  end;
  FEdit.InplaceParams.Position := FEditingItem.FocusedCellViewInfo.GetInplaceEditPosition;
  UpdateEdit;
  UpdateEditValue;
  AssignEditEvents;
  EditingControl.DoInitEdit(FEditingItem, FEdit);
end;

function TcxEditingController.PrepareEdit(AItem: TcxCustomInplaceEditContainer;
  AIsMouseEvent: Boolean): Boolean;
var
  AEditCellViewInfo: TcxEditCellViewInfo;
begin
  Result := False;
  Controller.CancelCheckEditPost;
  if FEditPreparing or FEditHiding or (AItem = nil) or IsDragging then Exit;
  if AItem.Editing and not FEditingItemSetting then
  begin
    Result := (FEdit <> nil) and (FController.EditingControl.Focused and
      not FEdit.IsFocused or AIsMouseEvent);
    Exit;
  end;
  FEditPreparing := True;
  try
    Result := FController.EditingControl.Focused;
    if not Result then Exit;
    Controller.BeforeShowEdit;
    AEditCellViewInfo := Controller.GetFocusedCellViewInfo(AItem);
    AItem.Editing := AEditCellViewInfo <> nil;
    Result := AItem.Editing;
    if not Result then Exit;
    try
      AItem.FEditValueSource := EditingProperties.GetEditValueSource(True);
      FEdit := FEditList.GetEdit(EditingProperties);
      FEdit.Visible := False;
      FEdit.Parent := nil;
      FEdit.Parent := EditingControl;
    except
      AItem.Editing := False;
      Result := False;
      raise;
    end;
    FEditingItem.FocusedCellViewInfo.Invalidate;
    InitEdit;
  finally
    FEditPreparing := False;
  end;
end;

procedure TcxEditingController.UpdateEdit;
begin
  if (FEdit = nil) or (FEditingItem.FocusedCellViewInfo = nil) then Exit;
  if FEditPreparing then
    DoUpdateEdit
  else
    PostEditUpdate;
  FIsEditPlaced := True;
end;

procedure TcxEditingController.UpdateEditValue;
begin
  if CanUpdateEditValue then
  begin
    FEdit.LockChangeEvents(True);
    try
      FEdit.EditValue := EditingItem.EditValue;
    finally
      FEdit.LockChangeEvents(False, False);
    end;
    FEdit.SelectAll;
  end;
end;

procedure TcxEditingController.UpdateValue;
begin
  if IsEditing and FEdit.EditModified then
  begin
    FEdit.ValidateEdit(True);
    FEditingItem.EditValue := FEdit.EditValue;
    if FEdit <> nil then
      FEdit.ModifiedAfterEnter := False;
  end;
end;

procedure TcxEditingController.EditAfterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FController.IsKeyForController(Key, Shift) then
    FController.KeyDown(Key, Shift);
end;

procedure TcxEditingController.EditChanged(Sender: TObject);
begin
  if Assigned(FPrevEditOnChange) then FPrevEditOnChange(Sender);
  EditingControl.DoEditChanged(FEditingItem);
end;

procedure TcxEditingController.EditDblClick(Sender: TObject);
begin
  Controller.DoEditDblClick(Sender);
end;

procedure TcxEditingController.EditEditing(Sender: TObject; var CanEdit: Boolean);
begin
  FInitiatingEditing := True;
  try
    CanEdit := (EditingItem <> nil) and EditingItem.CanInitEditing;
  finally
    FInitiatingEditing := False;
  end;
end;

procedure TcxEditingController.EditEnter(Sender: TObject);
begin
  if not Controller.Focused then
  begin
    Controller.Focused := True;
    Controller.ControlFocusChanged;
  end;
end;

procedure TcxEditingController.EditExit(Sender: TObject);
begin
  if HideEditOnExit then
  try
    HideEdit(not FController.GetCancelEditingOnExit);
  except
    if IsEditing then
    begin
      FEdit.SetFocus;
      FIsErrorOnEditExit := True;
    end;
    raise;                                               
  end;
  FController.EditingControl.FocusChanged;
end;

procedure TcxEditingController.EditFocusChanged(Sender: TObject);
begin
  Controller.FFocused := EditingControl.IsFocused or
    (IsEditing and (Edit <> nil) and Edit.Focused);
  Controller.EditingControl.ViewInfo.UpdateSelection;
end;

procedure TcxEditingController.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  AModified: Boolean;
begin
  if Assigned(EditingControl.OnKeyDown) then
    EditingControl.OnKeyDown(EditingControl, Key, Shift);
  with FController do
  begin
    BeforeEditKeyDown(Key, Shift);
    if not EditingControl.IsScrollingContent and IsKeyForController(Key, Shift) then
      FController.MakeFocusedItemVisible;
  end;
  case Key of
    VK_RETURN:
      begin
        HideEdit(True);
        if FController.GetGoToNextCellOnEnter then
        begin
          FController.BlockRecordKeyboardHandling := True;
          try
            FController.KeyDown(Key, Shift);
          finally
            FController.BlockRecordKeyboardHandling := False;
          end;
          ShowEdit;
        end
        else
          FController.CheckEdit;
        Key := 0;
      end;
    VK_ESCAPE:
      begin
        AModified := FEdit.EditModified;
        HideEdit(False);
        FController.CheckEdit;
        if AModified then Key := 0;
      end;
    VK_DELETE:
      if Shift = [ssCtrl] then
      begin
        FController.KeyDown(Key, Shift);
        Key := 0;
      end;
  end;
end;

procedure TcxEditingController.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(EditingControl.OnKeyPress) then
    EditingControl.OnKeyPress(EditingControl, Key);
  if Key = #27 then Key := #0;
  FController.MakeFocusedItemVisible;
end;

procedure TcxEditingController.EditKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Assigned(EditingControl.OnKeyUp) then
    EditingControl.OnKeyUp(EditingControl, Key, Shift);
end;

procedure TcxEditingController.EditPostEditValue(Sender: TObject);
begin
  UpdateValue;
end;

procedure TcxEditingController.EditValueChanged(Sender: TObject);
begin
  if Assigned(FPrevEditOnEditValueChanged) then FPrevEditOnEditValueChanged(Sender);
  EditingControl.DoEditValueChanged(FEditingItem);
end;

procedure TcxEditingController.HideEdit(Accept: Boolean);
var
  AEditViewInfo: TcxEditCellViewInfo;
  AItem: TcxCustomInplaceEditContainer;
begin
  FController.CancelCheckEditPost;
  CancelEditUpdatePost;
  StopEditShowingTimer;
  if FEditHiding or not IsEditing or EditingControl.IsDestroying then Exit;
  FEditHiding := True;
  try
    if Accept then
    begin
      if not FEdit.Deactivate then raise EAbort.Create('');
      EditingControl.DataController.PostEditingData;
      if FController.IsImmediatePost then
        EditingControl.DataController.Post;
      if FEditingItem = nil then Exit;
      AEditViewInfo := FEditingItem.FocusedCellViewInfo;
      if AEditViewInfo <> nil then
        FEdit.InternalProperties.Update(AEditViewInfo.Properties);
    end;
    AItem := EditingItem;
    if not EditingControl.IsDestroying then
      EditingControl.DoEdited(AItem);
    EditingItem := nil;
    Controller.RefreshFocusedCellViewInfo(AItem);
    HideInplaceEditor;
    FIsErrorOnEditExit := False;
  finally
    FEditHiding := False;
  end;
end;

procedure TcxEditingController.PostEditUpdate;
begin
  FEditUpdateNeeded := True;
end;

procedure TcxEditingController.RemoveEdit(AProperties: TcxCustomEditProperties);
begin
  if EditingProperties = AProperties then
    EditingItem := nil;
  FEditList.RemoveItem(AProperties);
end;

procedure TcxEditingController.ShowEdit(AItem: TcxCustomInplaceEditContainer = nil);
begin
  if AItem = nil then AItem := FController.FocusedItem;
  if PrepareEdit(AItem, False) then
    FEdit.Activate(AItem.FEditData);
end;

procedure TcxEditingController.ShowEdit(AItem: TcxCustomInplaceEditContainer; Key: Char);
begin
  if PrepareEdit(AItem, False) then
    FEdit.ActivateByKey(Key, AItem.FEditData);
end;

procedure TcxEditingController.ShowEdit(AItem: TcxCustomInplaceEditContainer;
  Shift: TShiftState; X, Y: Integer);
begin
  if PrepareEdit(AItem, True) then
    FEdit.ActivateByMouse(Shift, X, Y, AItem.FEditData);
end;

procedure TcxEditingController.StartEditShowingTimer(AItem: TcxCustomInplaceEditContainer);
begin
  StopEditShowingTimer;
  FEditShowingTimerItem := AItem;
  FEditShowingTimer := TcxTimer.Create(nil);
  with FEditShowingTimer do
  begin
    Interval := GetDblClickInterval;
    OnTimer := EditShowingTimerHandler;
  end;
end;

procedure TcxEditingController.StopEditShowingTimer;
begin
  FreeAndNil(FEditShowingTimer);
end;

{ TcxSizingDragAndDropObject }

procedure TcxSizingDragAndDropObject.BeginDragAndDrop;
begin
  if (DragItem = nil) or (DragSizing = nil) then
    raise EAbort.Create('');
  FDirection := Controller.GetResizeDirection;
  FDragBounds := DragSizing.GetSizingBoundsRect(FDirection);
  FSizeDelta := DragSizing.GetSizingIncrement(FDirection);
  FStartPos := CurMousePos;
  FDragPos := GetDragPos(CurMousePos);
  FDynamicUpdate := DragSizing.IsDynamicUpdate;
  inherited BeginDragAndDrop;
end;

procedure TcxSizingDragAndDropObject.DirtyChanged;
begin
  if not DynamicUpdate and cxRectIntersect(GetSizingMarkBounds, Control.ClientBounds) then
    Canvas.InvertRect(GetSizingMarkBounds);
  inherited DirtyChanged;
end;

procedure TcxSizingDragAndDropObject.DragAndDrop(
  const P: TPoint; var Accepted: Boolean);
var
  ADragPos: TPoint;
begin
  ADragPos := GetDragPos(P);
  with FDragBounds do
    if (DragCoord[P] < DragCoord[TopLeft]) or (DragCoord[P] > DragCoord[BottomRight]) then Exit;
  if not DynamicUpdate then
    FDelta := Round((DragCoord[P] - DragCoord[StartPos]) / SizeDelta)
  else
    FDelta := Trunc((DragCoord[P] - DragCoord[StartPos]) / SizeDelta);
  if (FDelta = 0) and (DragCoord[ADragPos] = DragCoord[DragPos]) then Exit;
  Dirty := True;
  FDragPos := ADragPos;
  if DynamicUpdate then
  begin
     DragSizing.SetSizeDelta(Direction, Delta);
     FStartPos := P;
  end;
  inherited DragAndDrop(P, Accepted);
end;

procedure TcxSizingDragAndDropObject.EndDragAndDrop(Accepted: Boolean);
begin
  inherited EndDragAndDrop(Accepted);
  if not DynamicUpdate and (Delta <> 0) and not Controller.FDragCancel then
    DragSizing.SetSizeDelta(Direction, Delta);
end;

function TcxSizingDragAndDropObject.GetDragAndDropCursor(
  Accepted: Boolean): TCursor;
begin
  if IsHorzSizing then
    Result := crHSplit
  else
    Result := crVSplit;
end;

function TcxSizingDragAndDropObject.GetDragCoord(APoint: TPoint): Integer;
begin
  if IsHorzSizing then
    Result := APoint.X
  else
    Result := APoint.Y;
end;

function TcxSizingDragAndDropObject.GetDragPos(const APoint: TPoint): TPoint;
begin
  Result := FStartPos;
  with Result do
  begin
    if IsHorzSizing then
      Inc(X, Round((DragCoord[APoint] - X) / SizeDelta) * SizeDelta)
    else
      Inc(Y, Round((DragCoord[APoint] - Y) / SizeDelta) * SizeDelta);
  end;
end;

function TcxSizingDragAndDropObject.GetImmediateStart: Boolean;
begin
  Result := True;
end;

function TcxSizingDragAndDropObject.GetSizingMarkBounds: TRect;
begin
  if IsHorzSizing then
    Result := cxRectSetLeft(FDragBounds,
      DragPos.X - cxSizingMarkWidth div 1, cxSizingMarkWidth)
  else
    Result := cxRectSetTop(FDragBounds,
      DragPos.Y - cxSizingMarkWidth div 1, cxSizingMarkWidth);
end;

function TcxSizingDragAndDropObject.GetCanvas: TcxCanvas;
begin
  Result := TcxEditingControl(Control).Canvas;
end;

function TcxSizingDragAndDropObject.GetController: TcxCustomControlController;
begin
  Result := TcxEditingControl(Control).Controller;
end;

function TcxSizingDragAndDropObject.GetDragItem: TObject;
begin
  Result := Controller.DragItem;
end;

function TcxSizingDragAndDropObject.GetDragSizing: IcxDragSizing;
begin
  Supports(DragItem, IcxDragSizing, Result);
end;

function TcxSizingDragAndDropObject.GetIsSizingKind(Index: Integer): Boolean;
begin
  Result := TcxDragSizingDirection(Index) = FDirection;
end;

{ TcxAutoScrollingObject }

constructor TcxAutoScrollingObject.Create(AOwner: TObject);
begin
  FOwner := AOwner;
  FTimer := TcxTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := cxScrollWidthDragInterval;
  FTimer.OnTimer := TimerHandler;
end;

destructor TcxAutoScrollingObject.Destroy;
begin
  FTimer.Enabled := False;
  FTimer.Free;
  inherited Destroy;
end;

function TcxAutoScrollingObject.Check(APos: TPoint): Boolean;
begin
  Result := cxRectPtIn(FArea, APos);
  FTimer.Enabled := Result;
end;

procedure TcxAutoScrollingObject.SetParams(
  const Area: TRect; AKind: TScrollBarKind; ACode: TScrollCode; AIncrement: Integer);
begin
  FArea := Area;
  FCode := ACode;
  FKind := AKind;
  if ACode = scLineUp then
    AIncrement := -AIncrement;
  FIncrement := AIncrement;
end;

procedure TcxAutoScrollingObject.Stop;
begin
  FTimer.Enabled := False;
end;

procedure TcxAutoScrollingObject.DoScrollInspectingControl;
var
  AMin, AMax, APos, ANewPos: Integer;
begin
  with GetScrollBar(FKind) do
  begin
    AMin := Min;
    AMax := Max - PageSize + 1;
    APos := Position;
    ANewPos := APos + FIncrement;
    if ANewPos < AMin then ANewPos := AMin
    else
      if ANewPos > AMax then ANewPos := AMax;
  end;
  if GetScrollBar(FKind).Visible and (ANewPos <> APos) then
    Control.Controller.Scroll(FKind, FCode, ANewPos);
end;

function TcxAutoScrollingObject.GetScrollBar(AKind: TScrollBarKind): TcxControlScrollBar;
begin
  with Control do
    if AKind = sbHorizontal then Result := HScrollBar else Result := VScrollBar;
end;

procedure TcxAutoScrollingObject.TimerHandler(Sender: TObject);
begin
  DoScrollInspectingControl;
end;

function TcxAutoScrollingObject.GetControl: TcxEditingControl;
begin
  Result := nil;
end;

{ TcxDragDropAutoScrollingObject }

function TcxDragDropObjectAutoScrollingObject.GetControl: TcxEditingControl;
begin
  Result := TcxEditingControl(TcxDragAndDropObjectAccess(FOwner).Control);
end;

{ TcxControllerAutoScrollingObject }

function TcxControllerAutoScrollingObject.CheckBounds(APos: TPoint): Boolean;
begin
  FDirections := [];
  Result := not cxRectPtIn(FArea, APos);
  if Result then
  begin
    if FCheckHorz then
      if APos.X <= FArea.Left then
        Include(FDirections, nLeft)
      else
        if APos.X >= FArea.Right then
          Include(FDirections, nRight);
    if FCheckVert then
      if APos.Y <= FArea.Top then
        Include(FDirections, nTop)
      else
        if APos.Y >= FArea.Bottom then
          Include(FDirections, nBottom);
    Result := Result and (FDirections <> []);
  end;
  FTimer.Enabled := Result;
end;

procedure TcxControllerAutoScrollingObject.SetBoundsParams(
  const AClientArea: TRect; ACheckHorz, ACheckVert: Boolean; AIncrement: Integer);
begin
  FArea := AClientArea;
  FCheckHorz := ACheckHorz;
  FCheckVert := ACheckVert;
  FIncrement := AIncrement;
  FBoundsMode := True;
end;

procedure TcxControllerAutoScrollingObject.DoScrollInspectingControl;

  procedure CheckDirection(ADir: TcxNeighbor);
  const
    Kinds: array[Boolean] of TScrollBarKind = (sbVertical, sbHorizontal);
    Codes: array[Boolean] of TScrollCode = (scLineDown, scLineUp);
  var
    AMin, AMax, APos, ANewPos: Integer;
    AKind: TScrollBarKind;
    ACode: TScrollCode;
  begin
    AKind := Kinds[ADir in [nLeft, nRight]];
    with GetScrollBar(AKind) do
    begin
      if Visible then
      begin
        AMin := Min;
        AMax := Max - PageSize + 1;
        APos := Position;
        ACode := Codes[ADir in [nLeft, nTop]];
        if ACode = scLineDown then
          ANewPos := APos + FIncrement
        else
          ANewPos := APos - FIncrement;
        if ANewPos < AMin then ANewPos := AMin
        else
          if ANewPos > AMax then ANewPos := AMax;
        if ANewPos <> APos then
          Control.Controller.Scroll(AKind, ACode, ANewPos);
      end;
    end;
  end;

var
  I: TcxNeighbor;
begin
  if not FBoundsMode then
    inherited DoScrollInspectingControl
  else
    for I := nLeft to nBottom do
      if I in FDirections then
        CheckDirection(I);
end;

function TcxControllerAutoScrollingObject.GetControl: TcxEditingControl;
begin
  Result := TcxCustomControlController(FOwner).EditingControl;
end;

{ TcxPlaceArrows }

constructor TcxPlaceArrows.CreateArrows(
  AColor: TColor; ABorderColor: TColor = clDefault);
begin
  inherited Create();
  FBorderColor := ABorderColor;
  FColor := AColor;
{$IFDEF DELPHI6}
  AlphaBlend := False;
{$ENDIF}
end;

function TcxPlaceArrows.MoveTo(ARect: TRect; ASide: TcxBorder): Boolean;
var
  R: TRect;
  ARgn: HRGN;
begin
  HandleNeeded;
  Result := not EqualRect(ARect, FPrevRect) or (ASide <> FPrevSide) or not Visible;
  if Result then
  begin
    Hide;
    FPrevRect := ARect;
    FPrevSide := ASide;
    ARgn := CreateArrowsRgns(ARect, ASide);
    GetRgnBox(ARgn, R);
    SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    OffsetRect(ARect, -R.Left, -R.Top);
    OffsetRgn(ARgn, -R.Left, -R.Top);
    cxDrawArrows(Canvas.Canvas, ARect, ASide, Color, BorderColor);
    WindowRegion := ARgn;
    Show;
  end;
end;

function TcxPlaceArrows.CreateArrowsRgns(const ARect: TRect; ASide: TcxBorder): HRGN;
var
  ArrowRgns: array[0..1, 0..6, 0..1] of Integer;
  BaseLine: array[0..1, 0..1] of Integer;
  I, J, K: Integer;
  ArrowRgn: HRGN;
const
  BaseRgns: array[0..3, 0..6, 0..1] of Integer =
  (((0, 0), (-5, -6), (-2, -6), (-2, -9), (3, -9), (3, -6), (6, -6)),
   ((0, -1), (6, 6), (3, 6), (3, 9), (-2, 9), (-2, 6), (-6, 6)),
   ((0, 0), (-6, -6), (-6, -2), (-9, -2), (-9, 3), (-6, 3), (-6, 6)),
   ((0, 0), (6, 6), (6, 3), (9, 3), (9, -2), (6, -2), (6, -6)));
begin
  with ARect do
  begin
    BaseLine[0, 0] := Left;
    BaseLine[0, 1] := Top;
    BaseLine[1, 0] := Right;
    BaseLine[1, 1] := Bottom;
  end;
  if ASide in [bLeft, bBottom] then
  begin
    BaseLine[Byte(ASide = bLeft), 0] := ARect.Left;
    BaseLine[Byte(ASide = bLeft), 1] := ARect.Bottom;
  end
  else
  begin
    BaseLine[Byte(ASide = bTop), 0] := ARect.Right;
    BaseLine[Byte(ASide = bTop), 1] := ARect.Top;
  end;
  Move(BaseRgns[Byte(ASide in [bTop, bBottom]) shl 1], ArrowRgns, SizeOf(ArrowRgns));
  for I := 0 to 1 do
    for J := 0 to 6 do
      for K := 0 to 1 do
        Inc(ArrowRgns[I, J, K], BaseLine[I, K]);
  Result := CreateRectRgn(0, 0, 0, 0);
  for I := 0 to 1 do
  begin
    ArrowRgn := CreatePolygonRgn(ArrowRgns[I], Length(ArrowRgns[I]), ALTERNATE);
    CombineRgn(Result, Result, ArrowRgn, RGN_OR);
    DeleteObject(ArrowRgn);
  end;
end;

procedure TcxPlaceArrows.SetWindowRegion(ARegion: HRGN);
begin
  if FWindowRegion <> 0 then
    DeleteObject(FWindowRegion);
  FWindowRegion := ARegion;
  if ARegion <> 0 then
    SetWindowRgn(Handle, ARegion, False);
end;

{ TcxBaseDragAndDropObject }

function TcxBaseDragAndDropObject.GetDragAndDropCursor(
  Accepted: Boolean): TCursor;
begin
  if Accepted then
    Result := EditingControl.DragCursor
  else
    Result := crNoDrop;
end;

function TcxBaseDragAndDropObject.GetEditingControl: TcxEditingControl;
begin
  Result := TcxEditingControl(Control);
end;

{ TcxCustomControlDragAndDropObject }

constructor TcxCustomControlDragAndDropObject.Create(AControl: TcxControl);
begin
  inherited Create(AControl);
  FAutoScrollObjects := TList.Create;
end;

destructor TcxCustomControlDragAndDropObject.Destroy;
var
  I: Integer;
begin
  for I := 0 to FAutoScrollObjects.Count - 1 do
    TObject(FAutoScrollObjects.List^[I]).Free;
  FAutoScrollObjects.Free;
  FDragImage.Free;
  inherited Destroy;
end;

procedure TcxCustomControlDragAndDropObject.AddAutoScrollingObject(
  const ARect: TRect; AKind: TScrollBarKind;  ACode: TScrollCode);
var
  AObj: TcxAutoScrollingObject;
begin
  AObj := GetAutoScrollingObjectClass.Create(Self);
  if AKind = sbHorizontal then
    AObj.SetParams(ARect, AKind, ACode, GetHorzScrollInc)
  else
    AObj.SetParams(ARect, AKind, ACode, GetVertScrollInc);
  FAutoScrollObjects.Add(AObj);
end;

procedure TcxCustomControlDragAndDropObject.BeginDragAndDrop;
begin
  inherited BeginDragAndDrop;
  DrawDragImage;
end;

procedure TcxCustomControlDragAndDropObject.DragAndDrop(const P: TPoint;
  var Accepted: Boolean);
var
  R: TRect;
begin
  inherited DragAndDrop(P, Accepted);
  R := cxRectOffset(PictureSize, [OrgOffset, HotSpot, CurMousePos]);
  DrawImage(R.TopLeft);
//lcm
  if not CheckScrolling(P) then;
//    Accepted := cxRectPtIn(GetAcceptedRect, P);
  FCanDrop := Accepted;
end;

procedure TcxCustomControlDragAndDropObject.DrawDragImage;
var
  AOrg: TRect;
  ASaveCanvas: TcxCanvas;
begin
  AOrg := DisplayRect;
  with AOrg do
    FPictureSize := Rect(0, 0, Right - Left, Bottom - Top);

  FDragImage := TcxDragImage.Create;
  FDragImage.SetBounds(0, 0, FPictureSize.Right, FPictureSize.Bottom);

  FHotSpot.X := AOrg.Left - CurMousePos.X;
  FHotSpot.Y := AOrg.Top - CurMousePos.Y;
  cxSetCanvasOrg(FDragImage.Canvas.Canvas, AOrg);

  FOrgOffset := Control.ClientToScreen(FOrgOffset);
  ASaveCanvas := TcxEditingControl(Control).Painter.FCanvas;
  TcxEditingControl(Control).Painter.FCanvas := FDragImage.Canvas;
  try
    Paint;
  finally
    TcxEditingControl(Control).Painter.FCanvas := ASaveCanvas;
    cxSetCanvasOrg(FDragImage.Canvas.Canvas, AOrg);
  end;
end;

procedure TcxCustomControlDragAndDropObject.DrawImage(
  const APoint: TPoint);
begin
  DragImage.MoveTo(APoint);
  DragImage.Show;
end;

procedure TcxCustomControlDragAndDropObject.EndDragAndDrop(
  Accepted: Boolean);
begin
  StopScrolling;
  inherited EndDragAndDrop(Accepted);
end;

function TcxCustomControlDragAndDropObject.GetAcceptedRect: TRect;
begin
  Result := cxNullRect;
end;

function TcxCustomControlDragAndDropObject.GetAutoScrollingObjectClass: TcxAutoScrollingObjectClass;
begin
  Result := TcxDragDropObjectAutoScrollingObject;
end;

function TcxCustomControlDragAndDropObject.GetDisplayRect: TRect;
begin
  cxAbstractError;
end;

function TcxCustomControlDragAndDropObject.GetDragAndDropCursor(
  Accepted: Boolean): TCursor;
const
  DragCursors: array[Boolean] of TCursor = (crcxNoDrop, crDefault);
begin
  Result := DragCursors[Accepted];
end;

function TcxCustomControlDragAndDropObject.GetHorzScrollInc: Integer;
begin
  Result := 1;
end;

function TcxCustomControlDragAndDropObject.GetVertScrollInc: Integer;
begin
  Result := 1;
end;

procedure TcxCustomControlDragAndDropObject.OwnerImageChanged;
begin
  DrawImage(cxPointOffset(cxPointOffset(CurMousePos, FOrgOffset), HotSpot));
end;

procedure TcxCustomControlDragAndDropObject.OwnerImageChanging;
begin
end;

procedure TcxCustomControlDragAndDropObject.Paint;
begin
  cxAbstractError;
end;

procedure TcxCustomControlDragAndDropObject.StopScrolling;
var
  I: Integer;
begin
  for I := 0 to AutoScrollObjectCount - 1 do
    AutoScrollObjects[I].Stop;
end;

function TcxCustomControlDragAndDropObject.CheckScrolling(
  const P: TPoint): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AutoScrollObjectCount - 1 do
    Result := Result or AutoScrollObjects[I].Check(P);
end;

function TcxCustomControlDragAndDropObject.GetAutoScrollObject(
  Index: Integer): TcxAutoScrollingObject;
begin
  Result := TcxAutoScrollingObject(FAutoScrollObjects[Index]);
end;

function TcxCustomControlDragAndDropObject.GetAutoScrollObjectCount: Integer;
begin
  Result := FAutoScrollObjects.Count;
end;

function TcxCustomControlDragAndDropObject.GetCanvas: TcxCanvas;
begin
  Result := TcxEditingControl(Control).Painter.FCanvas;
end;

function TcxCustomControlDragAndDropObject.GetHitTestController: TcxCustomHitTestController;
begin
  Result := TcxEditingControl(Control).Controller.HitTestController;
end;

constructor TcxDragImageHelper.Create(AControl: TcxEditingControl;
  ADragPos: TPoint);
begin
  FDragControl := AControl;
  FDragPos := ADragPos;
  InitDragImage;
end;

destructor TcxDragImageHelper.Destroy;
begin
  if DragImageVisible then Hide;
  FreeAndNil(DragImage);
  inherited Destroy;
end;

procedure TcxDragImageHelper.Hide;
begin
  FDragImageVisible := False;
  DragImage.Hide;
end;

procedure TcxDragImageHelper.Show;
begin
  FDragImageVisible := True;
  DrawImage(MousePos);
  DragImage.Show;
end;

procedure TcxDragImageHelper.DragAndDrop(const P: TPoint);
var
  R: TRect;
begin
  R := cxRectOffset(DragPictureBounds, [HotSpot, P]);
  MousePos := R.TopLeft;
  DrawImage(MousePos);
end;

function TcxDragImageHelper.GetDisplayRect: TRect;
begin
  Result := DragControl.DragDropImageDisplayRect;
end;

procedure TcxDragImageHelper.InitDragImage;
begin
  DragPictureBounds := GetDisplayRect;
  HotSpot := DragPictureBounds.TopLeft;
  DragPictureBounds := cxRectOffset(DragPictureBounds, cxPointInvert(HotSpot));
  with FDragPos do
    HotSpot := cxPoint(HotSpot.X - X,  HotSpot.Y - Y);
  DragImage := TcxDragImage.Create;
  with cxRectSize(DragPictureBounds) do
    DragImage.SetBounds(0, 0, Cx, Cy);
  DragControl.DrawDragDropImage(DragImage.Image, DragImage.Canvas);
end;

procedure TcxDragImageHelper.DrawImage(
  const APoint: TPoint);
begin
  DragImage.MoveTo(APoint);
  if not DragImage.Visible then
    DragImage.Show;
end;

function TcxDragImageHelper.GetImageRect: TRect;
begin
  Result := cxRectOffset(DragPictureBounds, MousePos)
end;

procedure TcxDragImageHelper.SetDragImageVisible(Value: Boolean);
begin
  if Value <> FDragImageVisible then
  begin
    FDragImageVisible := Value;
    if Value then
      Show
    else
      Hide;
  end;
end;

{ TcxCustomHitTestController }

constructor TcxCustomHitTestController.Create(AOwner: TcxCustomControlController);
begin
  FController := AOwner;
  FHitPoint := cxInvalidPoint;
end;

destructor TcxCustomHitTestController.Destroy;
begin
end;

procedure TcxCustomHitTestController.ReCalculate;
begin
  Recalculate(FHitPoint);
end;

procedure TcxCustomHitTestController.ReCalculate(const APoint: TPoint);
begin
  ClearState;
  if Control.IsLocked then Exit;
  FHitPoint := APoint;
  if ViewInfo.IsDirty then ViewInfo.Calculate;
  DoCalculate;
end;

function TcxCustomHitTestController.AllowDesignMouseEvents(
  X, Y: Integer; AShift: TShiftState): Boolean;
begin
  RecalculateOnMouseEvent(X, Y, AShift);
  Result := False;
end;

procedure TcxCustomHitTestController.ClearState;
begin
  FHitState := FHitState and echc_IsMouseEvent;
end;

procedure TcxCustomHitTestController.DestroyingItem(AItem: TObject);
begin
  if FHitTestItem = AItem then
  begin
    FHitTestItem := nil;
    ClearState;
    Controller.HotTrackController.CheckDestroyingElement(AItem);
  end;
end;

procedure TcxCustomHitTestController.DoCalculate;
var
  I: Integer;
  AItem: TcxEditCellViewInfo;
begin
  with ViewInfo do
    for I := 0 to FEditCellViewInfoList.Count - 1 do
    begin
      AItem := FEditCellViewInfoList.List^[I];
      if AItem.Visible and cxRectPtIn(AItem.ClipRect, HitPoint) then
      begin
        HitTestItem := AItem;
        Exit;
      end;
    end;
  HitTestItem := nil;
end;

function TcxCustomHitTestController.GetCurrentCursor: TCursor;
begin
  Result := crDefault;
end;

procedure TcxCustomHitTestController.HitCodeChanged(APrevCode: Integer);
begin
end;

procedure TcxCustomHitTestController.HitTestItemChanged(APrevHitTestItem: TObject);
begin
end;

procedure TcxCustomHitTestController.RecalculateOnMouseEvent(X, Y: Integer; AShift: TShiftState);
begin
  FShift := AShift;
  IsMouseEvent := True;
  try
    ReCalculate(cxPoint(X, Y));
  finally
    IsMouseEvent := False;
  end;
end;

function TcxCustomHitTestController.GetControl: TcxEditingControl;
begin
  Result := Controller.EditingControl;
end;

function TcxCustomHitTestController.GetCoordinate(AIndex: Integer): Integer;
begin
  Result := PIntArray(@FHitPoint)^[AIndex];
end;

function TcxCustomHitTestController.GetEditCellViewInfo: TcxEditCellViewInfo;
begin
  if IsItemEditCell then
    Result := TcxEditCellViewInfo(FHitTestItem)
  else
    Result := nil;
end;

function TcxCustomHitTestController.GetHasCode(Mask: TcxHitCode): Boolean;
begin
  Result := FHitState and Mask <> 0;
end;

function TcxCustomHitTestController.GetHotTrackController: TcxHotTrackController;
begin
  Result := FController.HotTrackController;
end;

function TcxCustomHitTestController.GetIsItemEditCell: Boolean;
begin
  Result := FHitTestItem is TcxEditCellViewInfo;
end;

function TcxCustomHitTestController.GetIsMouseEvent: Boolean;
begin
  Result := FHitState and echc_IsMouseEvent <> 0; 
end;

function TcxCustomHitTestController.GetViewInfo: TcxCustomControlViewInfo;
begin
  Result := Control.ViewInfo;
end;

procedure TcxCustomHitTestController.SetCoordinate(AIndex: Integer; Value: Integer);
begin
  PIntArray(@FHitPoint)^[AIndex] := Value;
  Recalculate;
end;

procedure TcxCustomHitTestController.SetHasCode(ACode: TcxHitCode; AValue: Boolean);
var
  APrevState: TcxHitCode;
begin
  if (FHitState and ACode <> 0) <> AValue then
  begin
    APrevState := FHitState; 
    if AValue then
      FHitState := FHitState or ACode
    else
      FHitState := FHitState and not ACode;
    HitCodeChanged(APrevState);
  end;
end;

procedure TcxCustomHitTestController.SetHitPoint(const APoint: TPoint);
begin
  Recalculate(APoint);
end;

procedure TcxCustomHitTestController.SetHitTestItem(AItem: TObject);
var
  APrevItem: TObject;
begin
  APrevItem := FHitTestItem;
  FHitTestItem := AItem;
  if IsMouseEvent then
    with Controller.HotTrackController do
    begin
      ShowHint := Self.Control.Options.OptionsBehavior.CellHints;
      SetHotElement(AItem, HitPoint);
    end;
  if APrevItem <> AItem then
    HitTestItemChanged(APrevItem);
end;

procedure TcxCustomHitTestController.SetIsMouseEvent(Value: Boolean);
begin
  if Value then
    FHitState := FHitState or echc_IsMouseEvent
  else
    FHitState := FHitState and not echc_IsMouseEvent;
end;

{ TcxCustomCellNavigator }

constructor TcxCustomCellNavigator.Create(AController: TcxCustomControlController);
begin
  FController := AController;
end;

procedure TcxCustomCellNavigator.FocusNextCell(AForward, ANextRow: Boolean;
  AShift: TShiftState = []);
var
  APrevRowIndex, APrevCellIndex, ARowIndex, ACellIndex: Integer;

  function IsValidCellIndex(ACount: Integer): Boolean;
  begin
    Result := cxInRange(ACellIndex, 0, ACount - 1) or
      (MayFocusedEmptyRow(ARowIndex) and (ACount = 0));
  end;

begin
  Init(APrevRowIndex, APrevCellIndex, RowCount);
  ARowIndex := APrevRowIndex;
  ACellIndex := APrevCellIndex;
  if ANextRow then
    CalcNextRow(AForward, ARowIndex, ACellIndex)
  else
    ACellIndex := APrevCellIndex + cxIntOffs[AForward];
  SelectCell(AForward, ANextRow, ARowIndex, ACellIndex);
  if not IsValidCellIndex(Count[ARowIndex]) then
  begin
    ACellIndex := APrevCellIndex;
    ARowIndex := APrevRowIndex;
  end;
  if (ARowIndex <> APrevRowIndex) or (ACellIndex <> APrevCellIndex) then
    SetFocusCell(ARowIndex, ACellIndex, AShift);
end;

procedure TcxCustomCellNavigator.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT, VK_RIGHT:
      begin
        FocusNextCell(Key = VK_RIGHT, False, Shift);
        Key := 0;
      end;
    VK_TAB:
      begin
        FocusNextCell(not (ssShift in Shift), DownOnTab, Shift);
        Key := 0;
      end;
    VK_RETURN, VK_F2:
      if (Controller.FocusedItem <> nil) and (Shift = []) then
      begin
        Controller.FocusedItem.Editing := True;
        if Controller.FocusedItem.Editing then
          Key := 0;
      end;
    VK_UP, VK_DOWN:
      begin
        FocusNextCell(Key = VK_DOWN, True, Shift);
        Key := 0;
      end;
  end;             
end;

procedure TcxCustomCellNavigator.KeyPress(var Key: Char);
begin
  if IsEditStartChar(Key) and (Controller.FocusedItem <> nil) then
  begin
    Controller.EditingController.ShowEdit(Controller.FocusedItem, Key);
    Key := #0;
  end;
end;

procedure TcxCustomCellNavigator.Refresh;
begin
  // todo: msn !!! need synchronize focused cell and row
  {Init(ARowIndex, ACellIndex, ARowCount);
  SetFocusCell(ARowIndex, ACellIndex);}
end;

function TcxCustomCellNavigator.SelectCell(AForward, ANextRow: Boolean;
  var ARowIndex, ACellIndex: Integer): TcxCustomInplaceEditContainer;
var
  ACurRow, ACurCell, ARow: Integer;
  AItemFound: Boolean;
begin
  Result := nil;
  ACurRow := ARowIndex;
  ACurCell := ACellIndex;
  repeat
    AItemFound := False;
    while not AItemFound do
    begin
      Result := GetCellContainer(ACurRow, ACurCell);
      AItemFound := (Result = nil) or Result.CanFocus and Result.CanTabStop;
      if not AItemFound then Inc(ACurCell, cxIntOffs[AForward]);
    end;
    if Result = nil then
    begin
      ACurCell := ACellIndex;
      ARow := ACurRow;
      if Controller.GetFocusCellOnCycle and not ANextRow then
        CalcNextRow(AForward, ACurRow, ACurCell);
      if (ARow <> ACurRow) and not ((Count[ACurRow] = 0) and MayFocusedEmptyRow(ACurRow)) then
        ACurCell := cxSetValue(AForward, 0, Count[ACurRow] - 1)
      else
        break;
    end
    else
      if MayFocusedEmptyRow(ARowIndex) then break;
  until Result <> nil;
  ARowIndex := ACurRow;
  ACellIndex := ACurCell;
end;

procedure TcxCustomCellNavigator.CalcNextRow(AForward: Boolean;
  var ARowIndex, ACellIndex: Integer);
begin
  cxAbstractError;
end;

function TcxCustomCellNavigator.GetCellContainer(
  ARowIndex, ACellIndex: Integer): TcxCustomInplaceEditContainer;
begin
  Result := nil;
  cxAbstractError;
end;

function TcxCustomCellNavigator.GetCount(ARowIndex: Integer): Integer;
begin
  Result := -1;
  cxAbstractError;
end;

procedure TcxCustomCellNavigator.Init(
  var ARowIndex, ACellIndex, ARowCount: Integer);
begin
  cxAbstractError;
end;

function TcxCustomCellNavigator.MayFocusedEmptyRow(ARowIndex: Integer): Boolean;
begin
  Result := False
end;

procedure TcxCustomCellNavigator.SetFocusCell(
  ARowIndex, ACellIndex: Integer; AShift: TShiftState);
begin
  cxAbstractError;
end;

procedure TcxCustomCellNavigator.DoKeyPress(var Key: Char);
begin
  if FEatKeyPress then
    FEatKeyPress := False
  else
    KeyPress(Key);
end;

function TcxCustomCellNavigator.GetDataController: TcxCustomDataController;
begin
  Result := FController.DataController;
end;

{ TcxCustomDesignSelectionHelper }

constructor TcxCustomDesignSelectionHelper.Create(AControl: TcxEditingControl);
begin
  inherited Create;
  FControl := AControl;
end;

function TcxCustomDesignSelectionHelper.GetController: TcxCustomControlController;
begin
  Result := FControl.Controller;
end;

{ TcxCustomControlController }

constructor TcxCustomControlController.Create(AOwner: TcxEditingControl);
begin
  inherited Create;
  FEditingControl := AOwner;
  FAllowCheckEdit := True;
  with EditingControl do
  begin
    FEditingController := GetEditingControllerClass.Create(Self);
    FHitTestController := GetHitTestControllerClass.Create(Self);
    FHotTrackController := GetHotTrackControllerClass.Create(FEditingControl);
  end;
  FNavigator := GetNavigatorClass.Create(Self);
end;

destructor TcxCustomControlController.Destroy;
begin
  FNavigator.Free;
  FEditingController.Free;
  FHotTrackController.Free;
  FHitTestController.Free;
  inherited Destroy;
end;

procedure TcxCustomControlController.Clear;
begin
  HitTestController.ClearState;
  HotTrackController.Clear;
end;

procedure TcxCustomControlController.DblClick;
begin
end;

function TcxCustomControlController.GetCursor(X, Y: Integer): TCursor;
begin
  Result := crDefault;
end;

procedure TcxCustomControlController.KeyDown(var Key: Word;
  Shift: TShiftState);
begin
  if not BlockRecordKeyboardHandling then
  begin
    if IsIncSearching then Key := IncSearchKeyDown(Key, Shift);
     FNavigator.KeyDown(Key, Shift);
  end;
  case Key of
    VK_ESCAPE:
      EditingControl.DataController.Cancel;
    VK_RETURN:
      if GetGoToNextCellOnEnter and ((Shift = []) or (Shift = [ssShift])) then
        Navigator.FocusNextCell(Shift = [], Navigator.DownOnEnter, Shift);
    VK_TAB:
      if GetGoToNextCellOnTab and ((Shift = []) or (Shift = [ssShift])) then
      begin
        Navigator.FocusNextCell(Shift = [], Navigator.DownOnTab, Shift);
        Key := 0;
      end;
    VK_PRIOR, VK_NEXT:
      DoNextPage(Key = VK_NEXT, Shift);
  end;
end;

procedure TcxCustomControlController.KeyPress(var Key: Char);
begin
  if FEatKeyPress then
  begin
    FEatKeyPress := False;
    Exit;
  end;
  if IsIncSearchStartChar(Key) and
    (ItemForIncSearching <> nil) and ItemForIncSearching.CanIncSearch and
    (DataController.EditState * [dceInsert, dceEdit] = []) then
  begin
    if Key <> #8 then
      IncSearchingText := IncSearchingText + Key;
    Key := #0;
  end;
  FNavigator.DoKeyPress(Key);
end;

procedure TcxCustomControlController.KeyUp(var Key: Word; Shift: TShiftState);
begin
end;

procedure TcxCustomControlController.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TcxCustomControlController.MouseMove(
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TcxCustomControlController.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TcxCustomControlController.Reset;
begin
  EditingController.PostEditUpdate;
  FHitTestController.ClearState;
  FHitTestController.FHitTestItem := nil;
  FHotTrackController.Clear;
end;

procedure TcxCustomControlController.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_IME_STARTCOMPOSITION:
      EditingController.ShowEdit;
  end;
end;

// drag'n'drop
procedure TcxCustomControlController.BeginDragAndDrop;
begin
  EditingController.HideEdit(True);
end;

procedure TcxCustomControlController.DragAndDrop(const P: TPoint; var Accepted: Boolean);
begin
end;

procedure TcxCustomControlController.EndDragAndDrop(Accepted: Boolean);
begin
  if EditingControl.DragAndDropState = ddsNone then
    CheckEdit;
end;

function TcxCustomControlController.StartDragAndDrop(
  const P: TPoint): Boolean;
begin
  Result := False;
end;

procedure TcxCustomControlController.MouseEnter;
begin
  HitTestController.ReCalculate;
end;

procedure TcxCustomControlController.MouseLeave;
begin
  HideHint;
  HitTestController.IsMouseEvent := True;
  HitTestController.HitTestItem := nil;
  HitTestController.IsMouseEvent := False;
end;

procedure TcxCustomControlController.DoCancelMode;
begin
  FocusChanged;
end;

procedure TcxCustomControlController.AfterPaint;
begin
  with EditingControl do
  begin
    if DragAndDropState = ddsInProcess then
      if DragAndDropObject is TcxCustomControlDragAndDropObject then
        TcxCustomControlDragAndDropObject(DragAndDropObject).OwnerImageChanged;
  end;
  ProcessCheckEditPost;  
end;

procedure TcxCustomControlController.BeforeEditKeyDown(var Key: Word;
  var Shift: TShiftState);
begin
end;

procedure TcxCustomControlController.BeforeMouseDown(
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FEditingBeforeDrag := IsEditing;
end;

procedure TcxCustomControlController.BeforePaint;
begin
  with EditingControl do
  begin
    EditingController.CheckEditUpdatePost;
    if DragAndDropState = ddsInProcess then
      if DragAndDropObject is TcxCustomControlDragAndDropObject then
        TcxCustomControlDragAndDropObject(DragAndDropObject).OwnerImageChanging;
  end;
end;

procedure TcxCustomControlController.BeforeShowEdit;
begin
end;

procedure TcxCustomControlController.BehaviorChanged;
begin
  EditingControl.ViewInfo.UpdateSelection;
end;

procedure TcxCustomControlController.CancelCheckEditPost;
begin
  FCheckEditNeeded := False;
end;

function TcxCustomControlController.CanFocusedRecordIndex(
  AIndex: Integer): Boolean;
begin
  Result := True;
end;

procedure TcxCustomControlController.CancelIncSearching;
var
  AItem: TcxCustomInplaceEditContainer;
begin
  AItem := ItemForIncSearching;
  DataController.Search.Cancel;
  if (AItem <> nil) and (AItem.FocusedCellViewInfo <> nil) then
    AItem.FocusedCellViewInfo.Refresh(True);
end;

function TcxCustomControlController.GetIncSearchingItem: TcxCustomInplaceEditContainer;
begin
  if IsIncSearching then
    Result := TcxCustomInplaceEditContainer(EditingControl.ContainerList[DataController.Search.ItemIndex])
  else
    Result := nil;
end;

function TcxCustomControlController.GetIncSearchingText: string;
begin
  Result := DataController.Search.SearchText;
end;

function TcxCustomControlController.GetIsIncSearching: Boolean;
begin
  Result := DataController.Search.Searching
end;

procedure TcxCustomControlController.SearchLocate(
  AItem: TcxCustomInplaceEditContainer; const Value: string);
begin
   DataController.Search.Locate(AItem.ItemIndex, Value);
end;

procedure TcxCustomControlController.SearchLocateNext(
  AItem: TcxCustomInplaceEditContainer; AForward: Boolean);
begin
  DataController.Search.LocateNext(AForward);
end;

procedure TcxCustomControlController.UpdateRecord(ARecordIndex: Integer);
begin
  EditingController.UpdateEditValue;
end;

procedure TcxCustomControlController.CheckEdit;
begin
  CancelCheckEditPost;
  if FAllowCheckEdit and GetAlwaysShowEditor then
    FEditingController.ShowEdit;
end;

procedure TcxCustomControlController.DoEditDblClick(Sender: TObject);
begin
  EditingControl.DblClick;
end;

procedure TcxCustomControlController.DoMouseDown(
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  APrevFocusedRecord: Integer;
  APrevFocusedItem: TcxCustomInplaceEditContainer;
  APrevEditViewInfo, AEditViewInfo: TcxEditCellViewInfo;
  AButtonClick: Boolean;

  procedure DoShowEdit;
  begin
    if Button <> mbLeft then Exit; 
    with FEditingController, AEditViewInfo do
    begin
      if AButtonClick then
        ShowEdit(EditContainer, Shift, X, Y)
      else
        ShowEdit(EditContainer, [], -1, -1)
    end;
  end;

begin
  APrevFocusedRecord := FocusedRecordIndex;
  APrevFocusedItem := FocusedItem;
  FIsDblClick := ssDouble in Shift;
  FWasFocusedBeforeClick := False;
  EditingController.StopEditShowingTimer;
  with HitTestController do
  begin
    AButtonClick := HitTestController.IsItemEditCell and
      EditCellViewInfo.ViewInfo.IsHotTrack(Point(X, Y)) {and (EditingControl.DragMode = dmManual)};
    if AButtonClick then
      APrevEditViewInfo := EditCellViewInfo
    else
      APrevEditViewInfo := nil;
  end;
  MouseDown(Button, Shift, X, Y);
  HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
  if (Button <> mbMiddle) and HitTestController.IsItemEditCell then
  begin
    AEditViewInfo := HitTestController.EditCellViewInfo;
    SetFocusedRecordItem(AEditViewInfo.RecordIndex, AEditViewInfo.EditContainer);
    HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
    if HitTestController.IsItemEditCell then
    begin
      AEditViewInfo := HitTestController.EditCellViewInfo;
      if GetImmediateEditor then
        DoShowEdit
      else
      begin
        if AButtonClick and (AEditViewInfo = APrevEditViewInfo) then
          DoShowEdit
        else
        begin
          FWasFocusedBeforeClick := (APrevFocusedRecord = FocusedRecordIndex) and
            (APrevFocusedItem = FocusedItem) and (FocusedItem <> nil);
          if not FWasFocusedBeforeClick  and (FocusedItem <> nil) then
            FocusedItem.CancelIncSearching;
        end;
      end;
    end;
  end;
end;

procedure TcxCustomControlController.DoMouseMove(
  Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
  HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
end;

procedure TcxCustomControlController.DoMouseUp(
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
  if WasFocusedBeforeClick then
  begin
    with HitTestController do
      if not IsEditing and not IsDblClick and IsItemEditCell and (Button = mbLeft) then
        FEditingController.StartEditShowingTimer(EditCellViewInfo.EditContainer);
  end;
  HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
  with HitTestController do
    if not IsEditing and not IsDblClick and IsItemEditCell and GetImmediateEditor then
    begin
       FEditingController.StopEditShowingTimer;
       if Button = mbLeft then
         FEditingController.ShowEdit(EditCellViewInfo.EditContainer)
    end
end;

procedure TcxCustomControlController.DoNextPage(AForward: Boolean; Shift: TShiftState);
begin
end;

function TcxCustomControlController.GetEditingViewInfo: TcxEditCellViewInfo;
begin
  Result := GetFocusedCellViewInfo(EditingItem);
end;

function TcxCustomControlController.GetFocused: Boolean;
begin
  Result := FFocused;
end;

function TcxCustomControlController.GetFocusedCellViewInfo(
 AEditContainer: TcxCustomInplaceEditContainer): TcxEditCellViewInfo;
begin
  Result := nil;
  cxAbstractError;
end;

function TcxCustomControlController.GetFocusedRecordIndex: Integer;
begin
  Result := EditingControl.DataController.GetFocusedRecordIndex;
end;

function TcxCustomControlController.GetResizeDirection: TcxDragSizingDirection;
begin
  Result := dsdHorz;
end;

procedure TcxCustomControlController.FocusedItemChanged(
  APrevFocusedItem: TcxCustomInplaceEditContainer);

  procedure RefreshCells(APrevViewInfo, ACurViewInfo: TcxEditCellViewInfo);
  begin
     if (APrevViewInfo = ACurViewInfo) or DisableCellsRefresh then Exit;
     if APrevViewInfo <> nil then
       APrevViewInfo.Refresh(False);
     if ACurViewInfo <> nil then
       ACurViewInfo.Refresh(False); 
  end;

begin
  if EditingControl.ComponentState * [csLoading, csDestroying] <> [] then Exit;
  CancelIncSearching;
  MakeFocusedItemVisible;
  RefreshCells(GetFocusedCellViewInfo(APrevFocusedItem),
    GetFocusedCellViewInfo(FocusedItem));
  Navigator.Refresh;
end;

procedure TcxCustomControlController.FocusedRecordChanged(
  APrevFocusedRecordIndex, AFocusedRecordIndex: Integer);
begin
  with EditingController do 
    if HideEditOnFocusedRecordChange then HideEdit(True);
  CheckEdit;
  EditingController.UpdateEditValue;
end;

function TcxCustomControlController.HasFocusedControls: Boolean;
begin
  with FEditingController do
    Result := (Edit <> nil) and Edit.IsFocused;
end;

procedure TcxCustomControlController.HideHint;
begin
  HotTrackController.CancelHint;
end;

function TcxCustomControlController.IncSearchKeyDown(AKey: Word; AShift: TShiftState): Word;
begin
  if ItemForIncSearching = nil then
  begin
    Result := AKey;
    Exit;
  end
  else
    Result := 0;
  case AKey of
    VK_ESCAPE:
      ItemForIncSearching.CancelIncSearching;
    VK_BACK:
      IncSearchingText := Copy(IncSearchingText, 1, Length(IncSearchingText) - 1);
    VK_UP, VK_DOWN:
      if AShift = [ssCtrl] then
        SearchLocateNext(ItemForIncSearching, AKey = VK_DOWN)
      else
        Result := AKey;
  else
    Result := AKey;
  end;
end;

procedure TcxCustomControlController.InternalSetFocusedItem(
  Value: TcxCustomInplaceEditContainer);
begin
  FFocusedItem := Value;
end;

function TcxCustomControlController.IsImmediatePost: Boolean;
begin
  Result := False;
end;

function TcxCustomControlController.IsKeyForController(
  AKey: Word; AShift: TShiftState): Boolean;
begin
  Result := ((AKey = VK_TAB) and GetGoToNextCellOnTab) or
    (AKey = VK_UP) or (AKey = VK_DOWN) or (AKey = VK_PRIOR) or (AKey = VK_NEXT) or
      (AKey = VK_INSERT) or (AKey = VK_ESCAPE) or (AKey = VK_LEFT) or (AKey = VK_RIGHT);
end;

procedure TcxCustomControlController.PostCheckEdit;
begin
  if FAllowCheckEdit then FCheckEditNeeded := True;
end;

procedure TcxCustomControlController.ProcessCheckEditPost;
begin
  if FCheckEditNeeded then CheckEdit;
end;

procedure TcxCustomControlController.PostShowEdit;
begin
  with EditingControl.Options.OptionsBehavior do
  begin
    if not IsEditing and (ImmediateEditor or AlwaysShowEditor) and
      (EditingControl.DragAndDropState = ddsNone) then
      if HitTestController.IsItemEditCell then PostCheckEdit;
  end;
end;

procedure TcxCustomControlController.RefreshFocusedCellViewInfo(
  AItem: TcxCustomInplaceEditContainer);
var
  ACellViewInfo: TcxEditCellViewInfo;
begin
  if DisableCellsRefresh then Exit;
  ACellViewInfo := GetFocusedCellViewInfo(AItem);
  if (ACellViewInfo <> nil) and (ACellViewInfo.Refresh(True)) then
    EditingControl.LayoutChanged;
end;

procedure TcxCustomControlController.RefreshFocusedRecord;
var
  I: Integer;
  ANeedUpdate: Boolean;
  ACellViewInfo: TcxEditCellViewInfo;
begin
  with EditingControl do
  begin
    Inc(FLockUpdate);
    ANeedUpdate := False;
    try
      for I := 0 to FContainerList.Count - 1 do
        with TcxCustomInplaceEditContainer(FContainerList.List^[I]) do
        begin
          ACellViewInfo := FocusedCellViewInfo;
          ANeedUpdate := ANeedUpdate or ((ACellViewInfo <> nil) and ACellViewInfo.Refresh(True));
        end;
    finally
      Dec(FLockUpdate);
      if ANeedUpdate and not IsLocked then
      begin
        BeforeUpdate;
        LayoutChanged;
      end;
    end;
  end;
end;

procedure TcxCustomControlController.SetFocused(Value: Boolean);
begin
  FFocused := Value;
end;

procedure TcxCustomControlController.SetFocusedItem(
  Value: TcxCustomInplaceEditContainer);
var
  APrevFocusedItem: TcxCustomInplaceEditContainer;
begin
  if IsEditing then EditingController.HideEdit(True);
  if (Value <> nil) and not Value.CanFocus then Exit;
  if FFocusedItem <> Value then
  begin
    APrevFocusedItem := FFocusedItem;
    if (FFocusedItem <> nil) and not FEditingController.FEditingItemSetting then
      FEditingController.HideEdit(True);
    FFocusedItem := Value;
    FocusedItemChanged(APrevFocusedItem);
  end
  else
    if Assigned(Value) then
      MakeFocusedItemVisible;
  CheckEdit;
end;

procedure TcxCustomControlController.SetFocusedRecordIndex(
  Value: Integer);
var
  AIndexesAreEqual: Boolean;
begin
  with DataController do
  begin
    if cxInRange(Value, 0, RecordCount - 1) and
      not (CanFocusedRecordIndex(Value) and ChangeFocusedRowIndex(Value)) then Exit;
  end;
  AIndexesAreEqual := FocusedRecordIndex = Value;
  if AIndexesAreEqual then MakeFocusedRecordVisible;
end;

function TcxCustomControlController.GetAlwaysShowEditor: Boolean;
begin
  Result := EditingControl.Options.OptionsBehavior.AlwaysShowEditor;
end;

function TcxCustomControlController.GetCancelEditingOnExit: Boolean;
begin
  with EditingControl do
    Result := Options.OptionsData.CancelOnExit and
     (DataController.EditState * [dceInsert, dceChanging, dceModified] = [dceInsert]);
end;

function TcxCustomControlController.GetFocusCellOnCycle: Boolean;
begin
  Result := EditingControl.Options.OptionsBehavior.FocusCellOnCycle;
end;

function TcxCustomControlController.GetGoToNextCellOnEnter: Boolean;
begin
  Result := EditingControl.Options.OptionsBehavior.GoToNextCellOnEnter;
end;

function TcxCustomControlController.GetGoToNextCellOnTab: Boolean;
begin
  Result := EditingControl.Options.OptionsBehavior.GoToNextCellOnTab;
end;

function TcxCustomControlController.GetImmediateEditor: Boolean;
begin
  with EditingControl.Options.OptionsBehavior do 
    Result := (ImmediateEditor or AlwaysShowEditor) and (EditingControl.DragMode = dmManual);
end;

procedure TcxCustomControlController.BeforeStartDrag;
begin
end;

function TcxCustomControlController.CanDrag(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TcxCustomControlController.DragDrop(Source: TObject; X, Y: Integer);
begin
end;

procedure TcxCustomControlController.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  EditingController.HideEdit(True);
end;

procedure TcxCustomControlController.EndDrag(Target: TObject; X, Y: Integer);
begin
  HitTestController.ReCalculate(Point(X, Y));
  if FEditingBeforeDrag or
    EditingControl.Options.OptionsBehavior.AlwaysShowEditor then
      EditingController.ShowEdit;
end;

function TcxCustomControlController.GetDragAndDropObject: TcxCustomControlDragAndDropObject;
begin
  Result := EditingControl.DragAndDropObject as TcxCustomControlDragAndDropObject;
end;

function TcxCustomControlController.GetDragAndDropObjectClass: TcxDragAndDropObjectClass;
begin
  Result := nil;
end;

function TcxCustomControlController.GetIsDragging: Boolean;
begin
  Result := False;
end;

function TcxCustomControlController.GetNavigatorClass: TcxCustomCellNavigatorClass;
begin
  Result := TcxCustomCellNavigator;
end;

procedure TcxCustomControlController.StartDrag(var DragObject: TDragObject);
begin
end;

function TcxCustomControlController.GetMouseWheelScrollingKind: TcxMouseWheelScrollingKind;
begin
  Result := mwskNone;
end;

function TcxCustomControlController.IsPixelScrollBar(
  AKind: TScrollBarKind): Boolean;
begin
  Result := False;
end;

procedure TcxCustomControlController.InitScrollBarsParameters;
begin
end;

procedure TcxCustomControlController.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);
begin
end;

procedure TcxCustomControlController.SetFocusedRecordItem(
  ARecordIndex: Integer; AItem: TcxCustomInplaceEditContainer);
begin
  EditingController.HideEdit(True);
  AllowCheckEdit := False;
  try
    DisableCellsRefresh := (FocusedRecordIndex = ARecordIndex);
    FocusedRecordIndex := ARecordIndex;
    DisableCellsRefresh := DisableCellsRefresh and (FocusedItem = AItem);
    FocusedItem := AItem;
  finally
    AllowCheckEdit := True;
    CheckEdit;
    DisableCellsRefresh := False;
  end;
end;

procedure TcxCustomControlController.SetScrollBarInfo(
  AScrollBarKind: TScrollBarKind; AMin, AMax, AStep, APage, APos: Integer;
  AAllowShow, AAllowHide: Boolean);
begin
  EditingControl.SetScrollBarInfo(AScrollBarKind, AMin,
    AMax, AStep, APage, APos, AAllowShow, AAllowHide);
end;

procedure TcxCustomControlController.MakeFocusedItemVisible;
begin
  cxAbstractError;
end;

procedure TcxCustomControlController.MakeFocusedRecordVisible;
begin
  cxAbstractError;
end;

procedure TcxCustomControlController.FocusChanged;
var
  AFocused: Boolean;
begin
  AFocused := EditingControl.IsFocused;
  with EditingController do
  begin
    AFocused := AFocused or (IsEditing and (Edit <> nil) and Edit.Focused);
    if AFocused then
    begin
      CheckEdit;
      if IsEditing and (Edit <> nil) and GetAlwaysShowEditor and not Edit.Focused and Edit.CanFocus then
        Edit.SetFocus
      else
        if (Edit <> nil) and not Edit.Focused and not GetAlwaysShowEditor then
          HideEdit(True)
        else
          if GetAlwaysShowEditor and not IsEditing and GetImmediateEditor then ShowEdit;
    end;
  end;
  if FFocused <> AFocused then
  begin
    FFocused := AFocused;
    ControlFocusChanged;
  end;
end;

procedure TcxCustomControlController.DoEnter;
begin
end;

procedure TcxCustomControlController.DoExit;
begin
  if GetCancelEditingOnExit then
    EditingControl.DataController.Cancel
  else
  begin
    EditingControl.DataController.PostEditingData;
    if IsImmediatePost then
      EditingControl.DataController.Post;
  end;
end;

function TcxCustomControlController.MayFocus: Boolean;
begin
  Result := not EditingControl.IsFocused or not IsEditing or
    not GetAlwaysShowEditor and FEditingController.Edit.ValidateEdit(True);
end;

procedure TcxCustomControlController.RemoveFocus;
begin
end;

procedure TcxCustomControlController.SetFocus;
begin
  if not FEditingController.CanRemoveEditFocus then Exit;
  with EditingControl do
    if CanFocusEx and IsFocused then SetFocus;
  PostCheckEdit;
end;
                                                                 
procedure TcxCustomControlController.ControlFocusChanged;
begin
  with EditingController do 
    if not Self.Focused and HideEditOnExit then HideEdit(True);
  EditingControl.ViewInfo.UpdateSelection;
end;

function TcxCustomControlController.GetDataController: TcxCustomDataController;
begin
  Result := EditingControl.DataController;
end;

function TcxCustomControlController.GetDesignSelectionHelper: TcxCustomDesignSelectionHelper;
begin
  Result := EditingControl.DesignSelectionHelper;
end;

function TcxCustomControlController.GetEditingItem: TcxCustomInplaceEditContainer;
begin
  Result := FEditingController.EditingItem;
end;

function TcxCustomControlController.GetIsEditing: Boolean;
begin
  Result := FEditingController.IsEditing;
end;

procedure TcxCustomControlController.SetEditingItem(
  Value: TcxCustomInplaceEditContainer);
begin
  FEditingController.EditingItem := Value;
end;

function TcxCustomControlController.GetItemForIncSearching: TcxCustomInplaceEditContainer;
begin
  Result := nil;
  if EditingControl.Options.OptionsBehavior.IncSearch then
    Result := EditingControl.Options.OptionsBehavior.IncSearchItem;
  if Result = nil then
    Result := FocusedItem;
end;

procedure TcxCustomControlController.SetIncSearchingText(const Value: string);
var
  AItem: TcxCustomInplaceEditContainer;

  function GetItemIndex: Integer;
  begin
    AItem := nil;
    if IsIncSearching then
      AItem := IncSearchingItem
    else
      AItem := ItemForIncSearching;
    if AItem <> nil then
      Result := AItem.ItemIndex
    else
      Result := -1;
  end;

begin
  if (IncSearchingText = Value) or (GetItemIndex = -1) then Exit;
  if Value = '' then
    CancelIncSearching
  else
    SearchLocate(AItem, Value);
  if (ItemForIncSearching <> nil) and (ItemForIncSearching.FocusedCellViewInfo <> nil) then
    ItemForIncSearching.FocusedCellViewInfo.Invalidate(True);
end;

{ TcxCustomControlViewInfo }

constructor TcxCustomControlViewInfo.Create(AOwner: TcxEditingControl);
begin
  FControl := AOwner;
  FState := FState or cvis_StyleInvalid;
  CreatePainter;
  FEditCellViewInfoList := TList.Create;
  FEditCellViewInfoList.Capacity := 1024;
  Brush := TBrush.Create;
  SelectionBrush := TBrush.Create;
end;

destructor TcxCustomControlViewInfo.Destroy;
begin
  with FControl do
    if Assigned(FController) then FController.Reset;
  FPainter.Free;
  FEditCellViewInfoList.Free;
  Brush.Free;
  SelectionBrush.Free;
  inherited Destroy;
end;

procedure TcxCustomControlViewInfo.Calculate;
begin
  with Control.FBrushCache do
  begin
    BeginUpdate;
    try
      if State[cvis_StyleInvalid] then
      begin
        State[cvis_StyleInvalid] := False;
        CalculateDefaultHeights;
        ViewParams := Control.Styles.GetBackgroundParams;
        Brush.Color := ViewParams.Color;
        UpdateSelectionParams;
        Control.Invalidate;
      end;
      FClientRect := Control.ClientBounds;
      DoCalculate;
      IsDirty := False;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TcxCustomControlViewInfo.Invalidate(ARecalculate: Boolean = False);
begin
  if ARecalculate then
    Control.LayoutChanged
  else
    Control.InvalidateRect(ClientRect, False);
end;

function TcxCustomControlViewInfo.AddEditCellViewInfo(
  AViewInfoClass: TcxEditCellViewInfoClass;
  AEditContainer: TcxCustomInplaceEditContainer): TcxEditCellViewInfo;
begin
  Result := AViewInfoClass.Create(AEditContainer);
  FEditCellViewInfoList.Add(Result);
  IsDirty := True;
end;

function TcxCustomControlViewInfo.CalculateDefaultEditHeight: Integer;
begin
  Result := -1;
  cxAbstractError;
end;

procedure TcxCustomControlViewInfo.CalculateDefaultHeights;
begin
  FDefaultEditHeight := CalculateDefaultEditHeight;
end;

procedure TcxCustomControlViewInfo.ClearEditCellViewInfos;
var
  I: Integer;
begin
  for I := 0 to FEditCellViewInfoList.Count - 1 do
    TcxEditCellViewInfo(FEditCellViewInfoList.List^[I]).Free;
  FEditCellViewInfoList.Clear;
  IsDirty := True;
end;

procedure TcxCustomControlViewInfo.CreatePainter;
begin
  FPainter := Control.GetPainterClass.Create(Control);
end;

procedure TcxCustomControlViewInfo.DoCalculate;
var
  I: Integer;
begin
  for I := 0 to FEditCellViewInfoList.Count - 1 do
    with TcxEditCellViewInfo(FEditCellViewInfoList.List^[I]) do
      if Visible then DoCalculate;
end;

procedure TcxCustomControlViewInfo.RemoveEditCellViewInfo(
  AViewInfo: TcxEditCellViewInfo);
begin
  FEditCellViewInfoList.Remove(AViewInfo);
  AViewInfo.Free;
  IsDirty := True;
end;

procedure TcxCustomControlViewInfo.UpdateSelection;
begin
  UpdateSelectionParams;
end;

function TcxCustomControlViewInfo.GetLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := FPainter.Painter;
end;

function TcxCustomControlViewInfo.GetState(AMask: Integer): Boolean;
begin
  Result := FState and AMask = AMask;
end;

procedure TcxCustomControlViewInfo.SetState(AMask: Integer; Value: Boolean);
begin
  if Value then
    FState := FState or AMask
  else
    FState := FState and not AMask;
end;

procedure TcxCustomControlViewInfo.UpdateSelectionParams;
begin
  SelectionParams := Control.Styles.GetSelectionParams;
  SelectionBrush.Color := SelectionParams.Color;
end;

{ TcxCustomControlCells }

procedure TcxCustomControlCells.BeforePaint;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].CheckVisibleInfo;
end;

function TcxCustomControlCells.CalculateHitTest(
  AHitTest: TcxCustomHitTestController): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    Result := Items[I].GetHitTest(AHitTest);
    if Result then Exit;
  end;
end;

procedure TcxCustomControlCells.DeleteAll;
begin
  SetCount(0);
end;

procedure TcxCustomControlCells.ExcludeFromClipping(ACanvas: TcxCanvas);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].ExcludeFromPaint(ACanvas);
end;

procedure TcxCustomControlCells.Paint(ACanvas: TcxCanvas;
  AHandler: TcxCustomDrawCellEvent);

  procedure DoDrawItem(AItem: TcxCustomViewInfoItem);
  var
    ADone: Boolean;
  begin
    AItem.BeforeCustomDraw(ACanvas);
    AHandler(ACanvas, AItem, ADone);
    AItem.AfterCustomDraw(ACanvas);
    if not ADone then
      AItem.Draw(ACanvas);
  end;

var
  I: Integer;
  AClipRgn: TcxRegion;
  AItem: TcxCustomViewInfoItem;
begin
  for I := 0 to Count - 1 do
  begin
    AItem := Items[I];
    AItem.CheckVisibleInfo;
    if (AItem.Visible and RectVisible(ACanvas.Handle, AItem.ClipRect)) then
      if AItem.HasClipping then
      begin
        AClipRgn := ACanvas.GetClipRegion;
        ACanvas.IntersectClipRect(AItem.ClipRect);
        DoDrawItem(AItem);
        ACanvas.SetClipRegion(AClipRgn, roSet);
      end
      else
        DoDrawItem(AItem);
  end;
end;

function TcxCustomControlCells.GetItem(AIndex: Integer): TcxCustomViewInfoItem;
begin
  Result := TcxCustomViewInfoItem(List^[AIndex]);
end;

{ TcxCustomViewInfoItem }

constructor TcxCustomViewInfoItem.Create(AOwner: TObject);
begin
  FOwner := AOwner;
end;

procedure TcxCustomViewInfoItem.Assign(Source: TcxCustomViewInfoItem);
begin
  DisplayRect := Source.DisplayRect;
  ClipRect := Source.ClipRect;
  ItemVisible := Source.ItemVisible;
  ItemViewParams := Source.ItemViewParams;
end;

procedure TcxCustomViewInfoItem.CheckVisibleInfo;
begin
  if Visible and not FVisibleInfoCalculated then
  begin
    DoCalculate;
    FVisibleInfoCalculated := True;
  end;
end;

class function TcxCustomViewInfoItem.CustomDrawID: Integer;
begin
  Result := 0;
end;

procedure TcxCustomViewInfoItem.Draw(ACanvas: TcxCanvas);
var
  FPrevCanvas: TcxCanvas;
begin
  FPrevCanvas := ControlCanvas;
  try
    ControlCanvas := ACanvas;
    DoDraw(ControlCanvas);
  finally
    ControlCanvas := FPrevCanvas;
  end;
end;

procedure TcxCustomViewInfoItem.Invalidate(ARecalculate: Boolean = False);
begin
  if ARecalculate then
    DoCalculate;
  if Visible then
    Control.InvalidateRect(VisibleRect, False);
end;

procedure TcxCustomViewInfoItem.CheckClipping(
  const ADisplayRect: TRect);
begin
  CheckClipping(ADisplayRect, ControlViewInfo.FClientRect);
end;

procedure TcxCustomViewInfoItem.DoCalculate;
begin
  cxAbstractError;
end;

procedure TcxCustomViewInfoItem.DoDraw(ACanvas: TcxCanvas);
begin
  if not Transparent then
    ACanvas.FillRect(ClipRect, ViewParams);
end;

procedure TcxCustomViewInfoItem.DoHorzOffset(AShift: Integer);
begin
  cxAbstractError;
end;

procedure TcxCustomViewInfoItem.DoVertOffset(AShift: Integer);
begin
  cxAbstractError;
end;

function TcxCustomViewInfoItem.DrawBackgroundHandler(
  ACanvas: TcxCanvas; const ABounds: TRect): Boolean;
begin
  Result := (Bitmap <> nil) and not Bitmap.Empty;
  if Result and not Transparent then
    ACanvas.FillRect(ABounds, Bitmap)
  else
    Result := Transparent;
end;

function TcxCustomViewInfoItem.ExcludeFromPaint(
  ACanvas: TcxCanvas): Boolean;
begin
  Result := Visible;
  if Result then
    ACanvas.ExcludeClipRect(ClipRect);
end;

function TcxCustomViewInfoItem.GetControl: TcxEditingControl;
begin
  Result := nil;
  cxAbstractError;
end;

function TcxCustomViewInfoItem.GetHitTest(
  AHitTest: TcxCustomHitTestController): Boolean;
begin
  Result := False;
end;

function TcxCustomViewInfoItem.IsTransparent: Boolean;
begin
  with ItemViewParams do
    Result := (Bitmap <> nil) and not Bitmap.Empty;
end;

procedure TcxCustomViewInfoItem.UpdateEditRect;
begin
  CheckClipping(DisplayRect);
end;

procedure TcxCustomViewInfoItem.AfterCustomDraw(ACanvas: TcxCanvas);
begin
  ItemViewParams.Color := ACanvas.Brush.Color;
  ItemViewParams.TextColor := ACanvas.Font.Color;
end;

procedure TcxCustomViewInfoItem.BeforeCustomDraw(ACanvas: TcxCanvas);
begin
  ACanvas.SetParams(ViewParams);
end;

procedure TcxCustomViewInfoItem.CheckClipping(
  const ADisplayRect, AAvailableRect: TRect);
begin
  DisplayRect := ADisplayRect;
  ItemVisible := cxRectIntersect(ClipRect, AAvailableRect, DisplayRect);
  FHasClipping := not cxRectIsEqual(ClipRect, DisplayRect);
end;

function TcxCustomViewInfoItem.GetBitmap: TBitmap;
begin
  Result := ViewParams.Bitmap;
end;

function TcxCustomViewInfoItem.GetControlViewInfo: TcxCustomControlViewInfo;
begin
  Result := Control.ViewInfo;
end;

function TcxCustomViewInfoItem.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := Control.LookAndFeelPainter;
end;

{ TcxEditCellViewInfo }

destructor TcxEditCellViewInfo.Destroy;
begin
  if (EditContainer <> nil) and not EditContainer.IsDestroying then
    Control.Controller.HitTestController.DestroyingItem(Self);
  ViewInfo.Free;
  if IsViewDataCreated then ViewData.Free;
  inherited Destroy;
end;

procedure TcxEditCellViewInfo.Assign(Source: TcxCustomViewInfoItem);
begin
  if Source is TcxCustomViewInfoItem then
  begin
    CellEditRect := TcxEditCellViewInfo(Source).CellEditRect;
    CellContentRect := TcxEditCellViewInfo(Source).CellContentRect;
    CellBorders := TcxEditCellViewInfo(Source).CellBorders;
  end;
  inherited Assign(Source);
end;

function TcxEditCellViewInfo.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := 0 else Result := cxE_NOINTERFACE;
end;

function TcxEditCellViewInfo.Refresh(ARecalculate: Boolean): Boolean;
begin
  Result := False;
  if EditContainer = nil then Exit; 
  if ARecalculate then
  begin
    if IsAutoHeight then
      Result := ChangedHeight(CellHeight, CalculateEditHeight);
    if not Result then DoCalculate;
  end
  else
    if ViewInfo <> nil then
    begin
      ItemViewParams := GetEditViewParams;
      ViewInfo.TextColor := ItemViewParams.TextColor;
      ViewInfo.Font := ItemViewParams.Font;
      ViewInfo.BackgroundColor := ItemViewParams.Color;
      ViewInfo.Transparent := IsTransparent;
    end;
  if not Result then Invalidate;
end;

function TcxEditCellViewInfo._AddRef: Integer;
begin
  Result := -1;
end;

function TcxEditCellViewInfo._Release: Integer;
begin
  Result := -1;
end;

function TcxEditCellViewInfo.GetOrigin: TPoint;
begin
  Result := cxPoint(ViewInfo.Left, ViewInfo.Top);
end;

function TcxEditCellViewInfo.IsNeedHint(ACanvas: TcxCanvas; const P: TPoint;
  out AText: TCaption;
  out AIsMultiLine: Boolean;
  out ATextRect: TRect; var IsNeedOffsetHint: Boolean): Boolean;
begin
  Result := Visible and
    ViewInfo.NeedShowHint(ACanvas, P, GetControl.ClientBounds,
    AText, AIsMultiLine, ATextRect);
  IsNeedOffsetHint := False;  
end;

procedure TcxEditCellViewInfo.UpdateHotTrackState(const APoint: TPoint);
var
  ATempViewInfo: TcxCustomEditViewInfo;
begin
  if not IsSupportedHotTrack then Exit;
  ATempViewInfo := TcxCustomEditViewInfo(Properties.GetViewInfoClass.Create);
  try
    ATempViewInfo.Assign(ViewInfo);
    cxAssignEditStyle(Self);
    ViewData.ContentOffset := ContentOffset;
    ViewData.CalculateEx(EditContainer.GetControlCanvas, ContentRect,
      APoint, cxmbNone, [], ViewInfo, False);
    if (EditContainer <> nil) and (EditContainer.EditingControl.DragAndDropState = ddsNone) then
      ViewInfo.Repaint(Control, ATempViewInfo);
  finally
    ATempViewInfo.Free;
  end;
end;

function TcxEditCellViewInfo.CalculateEditHeight: Integer;
begin
  if IsAutoHeight then
  begin
    with EditContainer do
    begin
      InitEditViewInfo(Self);
      Result := GetEditHeight(Self);
    end;
  end
  else
    Result := ControlViewInfo.DefaultEditHeight;
end;

function TcxEditCellViewInfo.CalculateEditWidth: Integer;
begin
  Result := EditContainer.GetEditHeight(Self);
end;

function TcxEditCellViewInfo.ChangedHeight(APrevHeight, ANewHeight: Integer): Boolean;
begin
  Result := APrevHeight <> ANewHeight;
  CellHeight := ANewHeight; 
end;

procedure TcxEditCellViewInfo.CheckClipping(
  const ADisplayRect, AAvailableRect: TRect);
begin
  inherited CheckClipping(ADisplayRect, AAvailableRect);
  CellContentRect := DisplayRect;
  if CellBorders = [] then
    with ContentOffset do
      CellEditRect := cxRectInflate(VisibleRect, -Left, -Top, -Right, -Bottom)
  else
  begin
    with CellContentRect do
    begin
      Inc(Left, Byte(bLeft in CellBorders));
      Inc(Top, Byte(bTop in CellBorders));
      Dec(Right, Byte(bRight in CellBorders));
      Dec(Bottom, Byte(bBottom in CellBorders));
    end;
    if cxRectIntersect(CellEditRect, VisibleRect, CellContentRect) then
      with ContentOffset do
        CellEditRect := cxRectInflate(CellEditRect, -Left, -Top, -Right, -Bottom);
  end;
end;

function TcxEditCellViewInfo.ContentOffset: TRect;
begin
  Result := cxSimpleRect;
end;

procedure TcxEditCellViewInfo.DoCalculate;
begin
  with EditContainer do
  begin
    if not IsAutoHeight then
      InitEditViewInfo(Self)
    else
    begin
      ViewData.InplaceEditParams.Position.RecordIndex := RecordIndex;
      ViewData.InplaceEditParams.Position.Item := Self;
    end; 
    CalculateEditViewInfo(CellValue, Self, cxInvalidPoint);
  end;
end;

function TcxEditCellViewInfo.GetButtonTransparency: TcxEditButtonTransparency;
var
  B1: TcxEditingControlEditShowButtons;
  B2: TcxEditItemShowEditButtons;
begin
  B1 := Control.Options.OptionsView.ShowEditButtons;
  B2 := EditContainer.Options.ShowEditButtons;
  if (B2 = eisbAlways) or (B2 = eisbDefault) and
   ((B1 = ecsbAlways) or (B1 = ecsbFocused) and Focused) then
    Result := ebtNone
  else
    Result := ebtHideInactive;
end;

function TcxEditCellViewInfo.GetControl: TcxEditingControl;
begin
  if EditContainer = nil then
    Result := nil
  else
    Result := EditContainer.EditingControl;
end;

function TcxEditCellViewInfo.GetDisplayValue: Variant;
begin
  with EditContainer.DataController do
  begin
    if (RecordIndex >= 0) and (RecordIndex < RecordCount) then
      Result := EditContainer.GetDisplayValue(Properties, RecordIndex)
    else
      Result := Null
  end;
end;

function TcxEditCellViewInfo.GetEditContainer: TcxCustomInplaceEditContainer;
begin
  Result := TcxCustomInplaceEditContainer(Owner);
end;

function TcxEditCellViewInfo.GetEditViewParams: TcxViewParams;
begin
  Result := Control.Styles.GetBackgroundParams;
end;

function TcxEditCellViewInfo.GetFocused: Boolean;
begin
  with EditContainer do
    Result := (FocusedCellViewInfo = Self) and (DataController.FocusedRecordIndex = RecordIndex);
end;

function TcxEditCellViewInfo.GetInplaceEditPosition: TcxInplaceEditPosition;
begin
  Result.Item := EditContainer;
  Result.RecordIndex := RecordIndex;
end;

function TcxEditCellViewInfo.GetMaxLineCount: Integer;
begin
  Result := Control.Options.OptionsView.CellTextMaxLineCount;
end;

function TcxEditCellViewInfo.GetRecordIndex: Integer;
begin
  Result := 0;
end;

function TcxEditCellViewInfo.GetSelectedTextColor: Integer;
begin
  Result := $FFFFFF xor ColorToRgb(ViewParams.TextColor);
end;

function TcxEditCellViewInfo.GetSelectedBKColor: Integer;
begin
  Result := $FFFFFF xor ColorToRgb(ViewParams.Color);
end;

function TcxEditCellViewInfo.GetViewInfoData: Pointer;
begin
  Result := Pointer(RecordIndex);
end;

function TcxEditCellViewInfo.IsAutoHeight: Boolean;
begin
  Result := Control.Options.OptionsView.CellAutoHeight;
end;

function TcxEditCellViewInfo.IsEndEllipsis: Boolean;
begin
  Result := Control.Options.OptionsView.CellEndEllipsis;
end;

function TcxEditCellViewInfo.IsSupportedHotTrack: Boolean;
begin
  Result := not Control.IsDesigning and
    (esoHotTrack in Properties.GetSupportedOperations) and
    ViewData.Style.LookAndFeel.Painter.IsButtonHotTrack;
end;

procedure TcxEditCellViewInfo.SetBounds(const ABounds: TRect; const ADisplayRect: TRect);
begin
  CheckClipping(ABounds, ADisplayRect);
  DoCalculate;
end;

function TcxEditCellViewInfo.GetTransparent: Boolean;
begin
  Result := ViewInfo.Transparent;
end;

procedure TcxEditCellViewInfo.SetTransparent(Value: Boolean);
begin
  ViewInfo.Transparent := Value;
end;

{ TcxCustomControlPainter }

constructor TcxCustomControlPainter.Create(
  AOwner: TcxEditingControl);
begin
  FControl := AOwner;
  FCanvas := FControl.Canvas;
end;

destructor TcxCustomControlPainter.Destroy;
begin
  FBitmap.Free;
  FBitmapCanvas.Free;
  inherited Destroy;
end;

procedure TcxCustomControlPainter.Paint;
var
  ACanvas: TcxCanvas;
begin
  ACanvas := FCanvas;
  if not Canvas.RectVisible(ViewInfo.ClientRect) then Exit;
  try
    if Buffered then
    begin
      FBitmap.Width := FControl.Width;
      FBitmap.Height := FControl.Height;
      if not Control.IsLayoutChanged then
        FBitmapCanvas.SetClipRegion(FCanvas.GetClipRegion, roSet)
      else
      begin
        FBitmapCanvas.SetClipRegion(TcxRegion.Create(ViewInfo.ClientRect), roSet);
        Control.IsLayoutChanged := False;
      end;
      FCanvas := FBitmapCanvas;
    end;
    DoPaint;
  finally
    FCanvas := ACanvas;
    if Buffered then
      Canvas.Draw(0, 0, FBitmap);
  end;
end;

procedure TcxCustomControlPainter.AfterCustomDraw(
  AViewInfo: TcxCustomViewInfoItem);
begin
  AViewInfo.ItemViewParams := FSaveViewParams;
  // synchronize EditViewInfo with ViewParams
  if AViewInfo is TcxEditCellViewInfo then
    with TcxEditCellViewInfo(AViewInfo).EditViewInfo do
    begin
      Font := FSaveViewParams.Font;
      TextColor := FSaveViewParams.TextColor;
      BackgroundColor := FSaveViewParams.Color;
    end;
end;

procedure TcxCustomControlPainter.BeforeCustomDraw(AViewInfo: TcxCustomViewInfoItem);
begin
  with AViewInfo do
  begin
    FSaveViewParams := ItemViewParams;
    cxApplyViewParams(Canvas, ItemViewParams);
    ItemViewParams.Font := Canvas.Font;
  end;
  if AViewInfo is TcxEditCellViewInfo then
    TcxEditCellViewInfo(AViewInfo).EditViewInfo.Font :=
      AViewInfo.ItemViewParams.Font;
end;

function TcxCustomControlPainter.DoCustomDraw(
 AViewInfoItem: TcxCustomViewInfoItem; AEvent: TcxCustomDrawViewInfoItemEvent): Boolean;
begin
  if (AViewInfoItem <> nil) and AViewInfoItem.Visible
    and Canvas.RectVisible(AViewInfoItem.VisibleRect) then
  begin
    Result := False;
    if Assigned(AEvent) then
    begin
//      BeforeCustomDraw(AViewInfoItem);
      AEvent(Control, Canvas, AViewInfoItem, Result);
//      AfterCustomDraw(AViewInfoItem);
    end;
  end
  else
    Result := True;
end;

procedure TcxCustomControlPainter.DoPaintEditCell(
  ACellViewInfo: TcxEditCellViewInfo; AIsExcludeRect: Boolean = True);
begin
  if not DoCustomDraw(ACellViewInfo, Control.OnCustomDrawCell) then
    ACellViewInfo.ViewInfo.PaintEx(Canvas);
  if AIsExcludeRect then
    Canvas.ExcludeClipRect(ACellViewInfo.ClipRect);
end;

procedure TcxCustomControlPainter.DoPaint;
begin
  with ViewInfo do
  begin
    FCanvas.Brush.Assign(Brush);
    FCanvas.FillRect(ClientRect);
  end;
end;

function TcxCustomControlPainter.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := Control.LookAndFeelPainter;
end;

function TcxCustomControlPainter.GetViewInfo: TcxCustomControlViewInfo;
begin
  Result := Control.FViewInfo;
end;

procedure TcxCustomControlPainter.SetBuffered(Value: Boolean);
begin
  if Value <> FBuffered then
  begin
    FBuffered := Value;
    if not Value then
    begin
      FreeAndNil(FBitmap);
      FreeAndNil(FBitmapCanvas);
    end
    else
    begin
      FBitmap := TBitmap.Create;
      FBitmapCanvas := TcxCanvas.Create(FBitmap.Canvas);
    end;
    if ViewInfo <> nil then
      ViewInfo.Invalidate;
  end;
end;

{ TcxCustomControlStyles }
constructor TcxCustomControlStyles.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FDefaultStyle := TcxStyle.Create(nil);
end;

destructor TcxCustomControlStyles.Destroy;
begin
  FDefaultStyle.Free;
  inherited Destroy;
end;

procedure TcxCustomControlStyles.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TcxCustomControlStyles then
  begin
    for I := ecs_Content to ecs_Selection do
      SetValue(I, TcxCustomControlStyles(Source).GetValue(I));
  end;
  inherited Assign(Source);
  Changed(ecs_Content);
end;

function TcxCustomControlStyles.GetBackgroundParams: TcxViewParams;
begin
  GetViewParams(ecs_Background, nil, nil, Result);
end;

function TcxCustomControlStyles.GetSelectionParams: TcxViewParams;
const
  AStyleIndexes: array[Boolean] of Integer = (ecs_Inactive, ecs_Selection);
begin
  GetViewParams(AStyleIndexes[Control.Controller.Focused or Control.IsFocused], nil, nil, Result);
end;

procedure TcxCustomControlStyles.Changed(AIndex: Integer);
begin
  inherited Changed(AIndex);
  if GetOwner is TcxEditingControl then
    Control.UpdateViewStyles;
end;

function TcxCustomControlStyles.GetDefaultStyle(Index: Integer; AData: Pointer): TcxStyle;
var
  AParams: TcxViewParams;
begin
  GetDefaultViewParams(Index, AData, AParams);
  with FDefaultStyle do
  begin
    Color := AParams.Color;
    Font :=  AParams.Font;
    TextColor := AParams.TextColor;
    // todo: enumeration names equal cxStyles. and cxEditors
    AssignedValues := [cxStyles.svColor, cxStyles.svFont, cxStyles.svTextColor];
  end;
  Result := FDefaultStyle;
end;

procedure TcxCustomControlStyles.GetDefaultViewParams(
 Index: Integer; AData: TObject; out AParams: TcxViewParams);
begin
  inherited GetDefaultViewParams(Index, AData, AParams);
  with AParams, LookAndFeelPainter do
  begin
    Bitmap := nil;
    Font := Control.Font;
    case Index of
      ecs_Background, ecs_Content:
        begin
          Color := DefaultContentColor;
          TextColor := DefaultContentTextColor;
        end;
      ecs_Selection:
        begin
          Color := DefaultSelectionColor;
          TextColor := DefaultSelectionTextColor;
        end;
      ecs_Inactive:
        begin
          Color := DefaultInactiveColor;
          TextColor := DefaultInactiveTextColor;
        end;
    else
      inherited GetDefaultViewParams(Index, AData, AParams);
    end;
  end;
end;

function TcxCustomControlStyles.GetControl: TcxEditingControl;
begin
  Result := TcxEditingControl(GetOwner);
end;

function TcxCustomControlStyles.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := Control.LookAndFeelPainter;
end;

{ TcxEditingControl }

constructor TcxEditingControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FContainerList := TList.Create;
  CreateSubClasses;
  Keys := [kArrows, kChars];
  BorderStyle := cxcbsDefault;
  DragCursor := crDefault; 
end;

destructor TcxEditingControl.Destroy;
begin
  DestroyDesignSelectionHelper;
  EndMouseTracking(Self);
  DestroySubClasses;
  FreeAndNil(FContainerList);
  inherited Destroy;
end;

procedure TcxEditingControl.BeginUpdate;
begin
  DoBeginUpdate;
end;

procedure TcxEditingControl.BeginDragAndDrop;
begin
  Controller.BeginDragAndDrop;
  inherited;
end;

procedure TcxEditingControl.CancelUpdate;
begin
  DataController.EndUpdate;
  Dec(FLockUpdate);
end;

procedure TcxEditingControl.EndUpdate;
begin
  DoEndUpdate;
end;

function TcxEditingControl.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    DataController.ExecuteAction(Action);
end;

procedure TcxEditingControl.DragDrop(Source: TObject; X, Y: Integer);
begin
  Controller.DragDrop(Source, X, Y);
  inherited DragDrop(Source, X, Y);
end;

procedure TcxEditingControl.LayoutChanged;
begin
  if ViewInfo <> nil then ViewInfo.IsDirty := True;
  if IsLocked then Exit;
  Inc(FChangesCount);
  Controller.Reset;
  BeginUpdate;
  try
    DoLayoutChanged;
  finally
    ViewInfo.IsDirty := False;
    CancelUpdate;
    SetInternalControlsBounds;  //TODO: need validation scrollbars visible
    UpdateScrollBars;
    Dec(FChangesCount);
    if FChangesCount = 0 then
    begin
      Controller.HitTestController.ReCalculate;
      Controller.EditingController.PostEditUpdate;
      FIsLayoutChanged := True;
      AfterLayoutChanged;
      Invalidate;
    end;
  end;
end;

function TcxEditingControl.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    DataController.UpdateAction(Action);
end;

procedure TcxEditingControl.AfterLayoutChanged;
begin
end;

procedure TcxEditingControl.BeginAutoDrag;
begin
  Controller.HideHint;
  if Controller.IsEditing then
    Controller.EditingController.HideEdit(True);
//  ControlState := ControlState - [csLButtonDown];
  BeginDrag(False, Mouse.DragThreshold);
//  ControlState := ControlState + [csLButtonDown];
end;

procedure TcxEditingControl.BeforeUpdate;
begin
end;

procedure TcxEditingControl.CheckCreateDesignSelectionHelper;
begin
  if (FDesignSelectionHelper = nil) and (cxDesignSelectionHelperClass <> nil) and IsDesigning then
    FDesignSelectionHelper := cxDesignSelectionHelperClass.Create(Self);
end;

procedure TcxEditingControl.CreateSubClasses;
begin
  FStyles := GetControlStylesClass.Create(Self);
  FBrushCache := TcxBrushCache.Create;
  FEditStyle := GetEditStyleClass.Create(nil, True);
  FEditStyle.LookAndFeel.MasterLookAndFeel := LookAndFeel;
  FController := GetControllerClass.Create(Self);
  FDataController := GetDataControllerClass.Create(Self);
  RecreateViewInfo;
end;

procedure TcxEditingControl.ControlUpdateData(AInfo: TcxUpdateControlInfo);
begin
  if AInfo is TcxDataChangedInfo then
    DataChanged
  else
    if AInfo is TcxLayoutChangedInfo then
      DataLayoutChanged
    else
      if AInfo is TcxFocusedRecordChangedInfo then
        with TcxFocusedRecordChangedInfo(AInfo) do
        begin
          // need use row index instead of record index
          Controller.FocusedRecordChanged(PrevFocusedRowIndex, FocusedRowIndex);
          Controller.Navigator.Refresh;
        end
      else
        if AInfo is TcxSelectionChangedInfo then
          SelectionChanged(TcxSelectionChangedInfo(AInfo))
        else
          if AInfo is TcxUpdateRecordInfo then
            Controller.UpdateRecord(TcxUpdateRecordInfo(AInfo).RecordIndex);
end;

procedure TcxEditingControl.DataChanged;
var
  I: Integer;
begin
  Inc(FLockUpdate);
  try
    for I := 0 to FContainerList.Count - 1 do
      TcxCustomInplaceEditContainer(FContainerList.List^[I]).DataChanged;
  finally
    Dec(FLockUpdate);
    if not IsLocked then Controller.RefreshFocusedRecord;
  end;
end;

procedure TcxEditingControl.DataLayoutChanged;
begin
  Controller.EditingController.UpdateEditValue;
  Controller.RefreshFocusedRecord;
end;

procedure TcxEditingControl.DestroyDesignSelectionHelper;
begin
  FreeAndNil(FDesignSelectionHelper);
end;

procedure TcxEditingControl.DestroySubClasses;
begin
  FreeAndNil(FViewInfo);
  FreeAndNil(FBrushCache);
  FreeAndNil(FController);
  FreeAndNil(FEditStyle);
  FreeAndNil(FDataController);
  FreeAndNil(FStyles);
end;

procedure TcxEditingControl.DoBeginUpdate;
begin
  Inc(FLockUpdate);
  DataController.BeginUpdate;
end;

procedure TcxEditingControl.DoEndUpdate;
begin
  DataController.EndUpdate;
  Dec(FLockUpdate);
  if FLockUpdate = 0 then BeforeUpdate;
  LayoutChanged;
end;

procedure TcxEditingControl.DoEditChanged(
  AItem: TcxCustomInplaceEditContainer);
begin
  if Assigned(FOnEditChanged) then FOnEditChanged(Self, AItem);
end;

procedure TcxEditingControl.DoEdited(
  AItem: TcxCustomInplaceEditContainer);
begin
  if Assigned(FOnEdited) then FOnEdited(Self, AItem);
end;

function TcxEditingControl.DoEditing(
  AItem: TcxCustomInplaceEditContainer): Boolean;
begin
  Result := True;
  if Assigned(FOnEditing) then
    FOnEditing(Self, AItem, Result);
end;

procedure TcxEditingControl.DoEditValueChanged(
  AItem: TcxCustomInplaceEditContainer);
begin
  if Assigned(FOnEditValueChanged) then FOnEditValueChanged(Self, AItem);
end;

procedure TcxEditingControl.DoInitEdit(
  AItem: TcxCustomInplaceEditContainer; AEdit: TcxCustomEdit);
begin
  if Assigned(FOnInitEdit) then FOnInitEdit(Self, AItem, AEdit);
end;

procedure TcxEditingControl.DoInplaceEditContainerItemAdded(
  AItem: TcxCustomInplaceEditContainer);
begin
  try
    with DataController do
    begin
      FContainerList.Add(AItem);
      UpdateIndexes;
      AddItem(AItem);
    end;
  finally
    LayoutChanged;
  end;
end;

procedure TcxEditingControl.DoInplaceEditContainerItemRemoved(
  AItem: TcxCustomInplaceEditContainer);
begin
  try
    FContainerList.Remove(AItem);
    DataController.RemoveItem(AItem);
    UpdateIndexes;
  finally
    LayoutChanged;
  end;
end;

procedure TcxEditingControl.DoLayoutChanged;
begin
  ViewInfo.Calculate;
end;

function TcxEditingControl.GetControllerClass: TcxCustomControlControllerClass;
begin
  Result := TcxCustomControlController;
end;

function TcxEditingControl.GetControlStylesClass: TcxCustomControlStylesClass;
begin
  Result := TcxCustomControlStyles;
end;

function TcxEditingControl.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TcxControlDataController;
end;

function TcxEditingControl.GetDragImageHelperClass: TcxDragImageHelperClass;
begin
  Result := TcxDragImageHelper;
end;

function TcxEditingControl.GetEditStyleClass: TcxCustomEditStyleClass;
begin
  Result := TcxEditStyle;
end;

function TcxEditingControl.GetEditingControllerClass: TcxEditingControllerClass;
begin
  Result := TcxEditingController;
end;

function TcxEditingControl.GetHitTestControllerClass: TcxHitTestControllerClass;
begin
  Result := TcxCustomHitTestController;
end;

function TcxEditingControl.GetHotTrackControllerClass: TcxHotTrackControllerClass;
begin
  Result := TcxHotTrackController;
end;

function TcxEditingControl.GetViewInfoClass: TcxCustomControlViewInfoClass;
begin
  Result := TcxCustomControlViewInfo;
end;

function TcxEditingControl.GetOptions: IcxEditingControlOptions;
begin
  cxAbstractError;
end;

function TcxEditingControl.GetPainterClass: TcxCustomControlPainterClass;
begin
  Result := TcxCustomControlPainter;
end;

function TcxEditingControl.IsLocked: Boolean;
begin
  Result := (FLockUpdate <> 0) or IsLoading or IsDestroying or not HandleAllocated;
end;

procedure TcxEditingControl.RecreateViewInfo;
begin
  if Controller <> nil then
  begin
    Controller.EditingController.EditingItem := nil;
    Controller.Clear;
    FreeAndNil(FViewInfo);
    FViewInfo := GetViewInfoClass.Create(Self);
  end
  else
  begin
    FreeAndNil(FViewInfo);
    FViewInfo := GetViewInfoClass.Create(Self);
  end;  
end;

procedure TcxEditingControl.SelectionChanged(AInfo: TcxSelectionChangedInfo);
begin
end;

procedure TcxEditingControl.UpdateIndexes;
var
  I: Integer;
begin
  for I := 0 to FContainerList.Count - 1 do
    TcxCustomInplaceEditContainer(FContainerList.List^[I]).FItemIndex := I;
end;

procedure TcxEditingControl.UpdateViewStyles;
begin
  if ViewInfo <> nil then
    ViewInfo.State[cvis_StyleInvalid] := True;
  LayoutChanged;
end;

procedure TcxEditingControl.UpdateData;
begin
  Controller.EditingController.UpdateValue;
end;

procedure TcxEditingControl.AlignControls(AControl: TControl; var Rect: TRect);
begin
  if not (AControl is TcxCustomEdit) then
    inherited AlignControls(AControl, Rect);
end;

procedure TcxEditingControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TcxEditingControl.CreateWnd;
begin
  DestroyDesignSelectionHelper;
  inherited CreateWnd;
  CheckCreateDesignSelectionHelper;
end;

procedure TcxEditingControl.DestroyWnd;
begin
  DestroyDesignSelectionHelper;
  inherited DestroyWnd;
end;

procedure TcxEditingControl.DoExit;
begin
  if Controller <> nil then
    Controller.DoExit;
  inherited DoExit;
end;

procedure TcxEditingControl.DblClick;
begin
  Controller.DblClick;
  inherited DblClick;
end;

procedure TcxEditingControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Controller.FDragCancel := Key = VK_ESCAPE;
  try
    inherited KeyDown(Key, Shift);
    Controller.KeyDown(Key, Shift);
  finally
    Controller.FDragCancel := False;
  end;
end;

procedure TcxEditingControl.FocusChanged;
begin
  inherited FocusChanged;
  if not IsDestroying then 
    Controller.FocusChanged;
end;

procedure TcxEditingControl.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  Controller.KeyPress(Key);
end;

procedure TcxEditingControl.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  Controller.KeyUp(Key, Shift);
end;

procedure TcxEditingControl.Loaded;
begin
  inherited Loaded;
  DataController.Loaded;
  LayoutChanged;
  CheckCreateDesignSelectionHelper;
end;

procedure TcxEditingControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Controller do
  begin
    HideHint;
    LockShowHint := True;
    BeforeMouseDown(Button, Shift, X, Y);
    inherited MouseDown(Button, Shift, X, Y);
    HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
    if not EditingController.IsErrorOnEditExit then
      DoMouseDown(Button, Shift, X, Y);
  end;
end;

procedure TcxEditingControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Controller.HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
  if DragAndDropState = ddsNone then //???
    Controller.DoMouseMove(Shift, X, Y);
end;

procedure TcxEditingControl.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Controller.LockShowHint := False;
  Controller.HitTestController.RecalculateOnMouseEvent(X, Y, Shift);
  if DragAndDropState = ddsNone then
  begin
    Controller.DoMouseUp(Button, Shift, X, Y);
    inherited MouseUp(Button, Shift, X, Y);
  end
  else
  begin
    inherited MouseUp(Button, Shift, X, Y);
    Controller.DoMouseUp(Button, Shift, X, Y);
  end;
  Controller.PostShowEdit;
end;

procedure TcxEditingControl.MouseEnter(AControl: TControl);
begin
  inherited MouseEnter(AControl);
  BeginMouseTracking(Self, Bounds, Self);
  Controller.MouseEnter;
end;

procedure TcxEditingControl.MouseLeave(AControl: TControl);
begin
  EndMouseTracking(Self);
  Controller.MouseLeave;
  inherited MouseLeave(AControl);
end;

procedure TcxEditingControl.Paint;
begin
  Controller.BeforePaint;
  try
    inherited Paint;
    Painter.Paint;
  finally
    Controller.AfterPaint;
  end;
end;

procedure TcxEditingControl.WndProc(var Message: TMessage);
begin
  if Controller <> nil then
    Controller.WndProc(Message);
  inherited WndProc(Message);
end;

procedure TcxEditingControl.AfterMouseDown(AButton: TMouseButton;
  X, Y: Integer);
begin
  FDragPos := cxPoint(X, Y);
  inherited AfterMouseDown(AButton, X, Y);
end;

procedure TcxEditingControl.BoundsChanged;
begin
  LayoutChanged;
  inherited BoundsChanged;
end;

function TcxEditingControl.CanDrag(X, Y: Integer): Boolean;
begin
  if Controller <> nil then
    Result := Controller.CanDrag(X, Y) 
  else
    Result := False;
end;

procedure TcxEditingControl.DoCancelMode;
begin
  inherited DoCancelMode;
  Controller.DoCancelMode;
end;

procedure TcxEditingControl.FontChanged;
begin
  inherited FontChanged;
  UpdateViewStyles;
end;

function TcxEditingControl.GetCursor(X, Y: Integer): TCursor;
begin
  Result := Controller.GetCursor(X, Y);
  if Result = crDefault then
    Result := inherited GetCursor(X, Y);
end;

function TcxEditingControl.GetDesignHitTest(
  X, Y: Integer; Shift: TShiftState): Boolean;
begin
  Result := Controller.HitTestController.AllowDesignMouseEvents(X, Y, Shift);
end;

function TcxEditingControl.GetIsFocused: Boolean;
begin
  Result := inherited GetIsFocused or Controller.HasFocusedControls;
end;

function TcxEditingControl.GetMouseWheelScrollingKind: TcxMouseWheelScrollingKind;
begin
  Result := inherited GetMouseWheelScrollingKind;
  if Result = mwskNone then
    Result := Controller.GetMouseWheelScrollingKind;
end;

procedure TcxEditingControl.InitControl;
begin
  inherited InitControl;
  LayoutChanged;
end;

function TcxEditingControl.IsPixelScrollBar(AKind: TScrollBarKind): Boolean;
begin
  Result := Controller.IsPixelScrollBar(AKind);
end;

procedure TcxEditingControl.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
var
  I: Integer;
  AIsEditing: Boolean;
begin
  AIsEditing := (Controller <> nil) and Controller.IsEditing;
  if AIsEditing then
    Controller.EditingController.HideEdit(True);
  inherited LookAndFeelChanged(Sender, AChangedValues);
  BeginUpdate;
  try
    for I := 0 to FContainerList.Count - 1 do
      TcxCustomInplaceEditContainer(FContainerList[I]).InternalPropertiesChanged;
  finally
    UpdateViewStyles;
    EndUpdate;
    if AIsEditing then
      Controller.EditingController.ShowEdit;
  end;
end;

function TcxEditingControl.MayFocus: Boolean;
begin
  Result := inherited MayFocus;
  if Controller <> nil then
    Result := Result and Controller.MayFocus;
end;

// drag'n'drop
procedure TcxEditingControl.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  Controller.EndDrag(Target, X, Y);
  inherited DoEndDrag(Target, X, Y);
  Controller.LockShowHint := False;
  Controller.PostShowEdit;
  FinishDragImages;
  FDragPos := cxNullPoint;
end;

procedure TcxEditingControl.DoStartDrag(var DragObject: TDragObject);
begin
  Controller.HitTestController.HitPoint := FDragPos;
  Controller.BeforeStartDrag;
  inherited DoStartDrag(DragObject);
  Controller.StartDrag(DragObject);
  FinishDragImages;
  if HasDragDropImages then
  begin
    FDragHelper := GetDragImageHelperClass.Create(Self, FDragPos);
    cxInstallMouseHookForDragControl(Self);
  end;
end;

procedure TcxEditingControl.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited DragOver(Source, X, Y, State, Accept);
  Controller.DragOver(Source, X, Y, State, Accept);
end;

function TcxEditingControl.DragDropImageDisplayRect: TRect;
begin
  Result := cxNullRect;
end;

procedure TcxEditingControl.DrawDragDropImage(
  ADragBitmap: TBitmap; ACanvas: TcxCanvas);
begin
end;

procedure TcxEditingControl.FinishDragImages;
begin
  if FDragHelper <> nil then
  begin
    cxResetMouseHookForDragControl;
    FreeAndNil(FDragHelper);
  end;
end;

function TcxEditingControl.HasDragDropImages: Boolean;
begin
  Result := Options.OptionsBehavior.DragDropText;
end;

// scrollbars
procedure TcxEditingControl.InitScrollBarsParameters;
begin
  if Controller <> nil then
    Controller.InitScrollBarsParameters;
end;

procedure TcxEditingControl.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);
begin
  Controller.EditingController.PostEditUpdate;
  Controller.Scroll(AScrollBarKind, AScrollCode, AScrollPos);
end;

procedure TcxEditingControl.DragAndDrop(const P: TPoint;
  var Accepted: Boolean);
begin
  inherited DragAndDrop(P, Accepted);
  Controller.DragAndDrop(P, Accepted);
end;

procedure TcxEditingControl.EndDragAndDrop(Accepted: Boolean);
begin
  inherited EndDragAndDrop(Accepted);
  Controller.EndDragAndDrop(Accepted);
  FDragPos := cxNullPoint;
end;

function TcxEditingControl.GetDragAndDropObjectClass: TcxDragAndDropObjectClass;
begin
  Result := Controller.GetDragAndDropObjectClass;
end;

function TcxEditingControl.StartDragAndDrop(const P: TPoint): Boolean;
begin
  Result := Controller.StartDragAndDrop(P);
  if Result then
    Controller.HideHint;
end;

function TcxEditingControl.GetBufferedPaint: Boolean;
begin
  Result := GetPainter.Buffered;
end;

function TcxEditingControl.GetPainter: TcxCustomControlPainter;
begin
  Result := ViewInfo.FPainter;
end;

procedure TcxEditingControl.DoMouseLeave;
begin
  MouseLeave(Self);
end;

procedure TcxEditingControl.SetBufferedPaint(Value: Boolean);
begin
  Painter.Buffered := Value;
end;

procedure TcxEditingControl.SetEditStyle(Value: TcxCustomEditStyle);
begin
  FEditStyle.Assign(Value);
end;

procedure TcxEditingControl.SetStyles(Value: TcxCustomControlStyles);
begin
  FStyles.Assign(Value);
end;

procedure TcxEditingControl.WMCancelMode(var Message: TWMCancelMode);
begin
  Controller.FDragCancel := True;
  try
    inherited;
  finally
    Controller.FDragCancel := False;
  end;
end;

procedure TcxEditingControl.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  with Controller.HitTestController do
  begin
    if IsDesigning and (DragAndDropState = ddsNone) and
       AllowDesignMouseEvents(P.X, P.Y, [ssLeft]) then
         SetCursor(Screen.Cursors[GetCurrentCursor])
    else
      inherited;
  end;
end;

{ TcxExtEditingControl }

procedure TcxExtEditingControl.CreateSubClasses;
begin
  FOptionsBehavior := GetOptionsBehaviorClass.Create(Self);
  FOptionsData := GetOptionsDataClass.Create(Self);
  FOptionsView := GetOptionsViewClass.Create(Self);
  inherited CreateSubClasses;
end;

procedure TcxExtEditingControl.DestroySubClasses;
begin
  inherited DestroySubClasses;
  FOptionsBehavior.Free;
  FOptionsData.Free;
  FOptionsView.Free;
end;

function TcxExtEditingControl.GetOptions: IcxEditingControlOptions;
begin
  Result := Self;
end;

function TcxExtEditingControl.GetOptionsBehaviorClass: TcxControlOptionsBehaviorClass;
begin
  Result := TcxControlOptionsBehavior;
end;

function TcxExtEditingControl.GetOptionsDataClass: TcxControlOptionsDataClass;
begin
  Result := TcxControlOptionsData;
end;

function TcxExtEditingControl.GetOptionsViewClass: TcxControlOptionsViewClass;
begin
  Result := TcxControlOptionsView;
end;

function TcxExtEditingControl.GetOptionsBehavior: TcxControlOptionsBehavior;
begin
  Result := FOptionsBehavior;
end;

function TcxExtEditingControl.GetOptionsData: TcxControlOptionsData;
begin
  Result := FOptionsData;
end;

function TcxExtEditingControl.GetOptionsView: TcxControlOptionsView;
begin
  Result := FOptionsView;
end;

procedure TcxExtEditingControl.SetOptionsBehavior(
  Value: TcxControlOptionsBehavior);
begin
  FOptionsBehavior.Assign(Value);
end;

procedure TcxExtEditingControl.SetOptionsData(
  Value: TcxControlOptionsData);
begin
  FOptionsData.Assign(Value);
end;

procedure TcxExtEditingControl.SetOptionsView(
  Value: TcxControlOptionsView);
begin
  FOptionsView.Assign(Value);
end;

{ TcxValueTypeClassRepository }

constructor TcxValueTypeClassRepository.Create;
begin
  FList := TStringList.Create;
end;

destructor TcxValueTypeClassRepository.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TcxValueTypeClassRepository.FindByClassType(ATypeClass: TcxValueTypeClass): string;
var
  I: Integer;
begin
  I := FList.IndexOfObject(TObject(ATypeClass));
  if I >= 0 then
    Result := FList[I]
  else
    Result := '';
end;

function TcxValueTypeClassRepository.FindByDescription(const ADescription: string): TcxValueTypeClass;
var
  I: Integer;
begin
  I := FList.IndexOf(ADescription);
  if I >= 0 then
    Result := TcxValueTypeClass(FList.Objects[I])
  else
    Result := nil;
end;

procedure TcxValueTypeClassRepository.RegisterValueTypeClass(const ADescription: string; ATypeClass: TcxValueTypeClass);
begin
  if FList.IndexOfObject(TObject(ATypeClass)) < 0 then
    FList.AddObject(ADescription, TObject(ATypeClass));
end;

procedure TcxValueTypeClassRepository.UnRegisterValueTypeClass(ATypeClass: TcxValueTypeClass);
var
  I: Integer;
begin
  I := FList.IndexOfObject(TObject(ATypeClass));
  if I >= 0 then FList.Delete(I);
end;

function TcxValueTypeClassRepository.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TcxValueTypeClassRepository.GetValueTypeClass(AIndex: Integer): TcxValueTypeClass;
begin
  Result := TcxValueTypeClass(FList.Objects[AIndex]);
end;

function TcxValueTypeClassRepository.GetDescription(AIndex: Integer): string;
begin
  Result := FList[AIndex];
end;

function cxieValueTypeClassRepository: TcxValueTypeClassRepository;
begin
  Result := ValueTypeClassRepository;
end;

procedure cxieRegisterValueTypeClass(
  const ADescription: string; ATypeClass: TcxValueTypeClass);
begin
  ValueTypeClassRepository.RegisterValueTypeClass(ADescription, ATypeClass);
end;

procedure cxieUnRegisterValueTypeClass(ATypeClass: TcxValueTypeClass);
begin
  ValueTypeClassRepository.UnRegisterValueTypeClass(ATypeClass);
end;

function cxPtInViewInfoItem(AItem: TcxCustomViewInfoItem; const APoint: TPoint): Boolean;
begin
  Result := (AItem <> nil) and AItem.Visible and cxRectPtIn(AItem.ClipRect, APoint);
end;

procedure RegisterDefaultValueTypeClasses;
begin
  cxieRegisterValueTypeClass('Boolean', TcxBooleanValueType);
  cxieRegisterValueTypeClass('String', TcxStringValueType);
  cxieRegisterValueTypeClass('Integer', TcxIntegerValueType);
  cxieRegisterValueTypeClass('Currency', TcxCurrencyValueType);
  cxieRegisterValueTypeClass('Float', TcxFloatValueType);
  cxieRegisterValueTypeClass('DateTime', TcxDateTimeValueType);
  cxieRegisterValueTypeClass('Variant', TcxVariantValueType);
end;

procedure cxStylesToViewParams(AMasterStyles: TcxCustomControlStyles; AIndex: Integer;
  AData: Pointer; const AStyles: array of TcxStyle; out AParams: TcxViewParams);
var
  I: Integer;
  IsColorAssigned, IsFontAssigned, IsFontColorAssigned, IsBitmapAssigned: Boolean;

  function NeedValueAssign(var AFlag: Boolean; IsValueAssigned: Boolean): Boolean;
  begin
    Result := not AFlag and IsValueAssigned;
    if Result then AFlag := True;
  end;

  function AssignStyle(AStyle: TcxStyle): Boolean;
  begin
    Result := False;
    if not Assigned(AStyle) or (csDestroying in AStyle.ComponentState) then Exit;
    with AStyle do
    begin
      if NeedValueAssign(IsColorAssigned, cxStyles.svColor in AssignedValues) then
        AParams.Color := Color;
      if NeedValueAssign(IsFontAssigned, cxStyles.svFont in AssignedValues) then
        AParams.Font := Font;
      if NeedValueAssign(IsFontColorAssigned, cxStyles.svTextColor in AssignedValues) then
        AParams.TextColor := TextColor;
      if NeedValueAssign(IsBitmapAssigned, cxStyles.svBitmap in AssignedValues) then
        AParams.Bitmap := Bitmap;
    end;
    Result := IsFontColorAssigned and IsFontAssigned and IsColorAssigned and IsBitmapAssigned;
  end;

  procedure AssignDefaultViewParams;
  var
    ADefParams: TcxViewParams;
  begin
    AMasterStyles.GetDefaultViewParams(AIndex, AData, ADefParams);
    if not IsColorAssigned then
      AParams.Color := ADefParams.Color;
    if not IsFontAssigned  then
      AParams.Font := ADefParams.Font;
    if not IsFontColorAssigned then
      AParams.TextColor := ADefParams.TextColor;
    if not IsBitmapAssigned then
      AParams.Bitmap := ADefParams.Bitmap;
  end;

begin
  IsColorAssigned := False;
  IsFontAssigned := False;
  IsFontColorAssigned := False;
  IsBitmapAssigned := False; 
  FillChar(AParams, SizeOf(AParams), 0);
  for I := Low(AStyles) to High(AStyles) do
    if AssignStyle(AStyles[I]) then Exit;
  AssignDefaultViewParams;
end;

function cxInRange(Value: Integer; AMin, AMax: Integer): Boolean;
begin
  Result := (Value >= AMin) and (Value <= AMax);
end;

function cxRange(var Value: Integer; AMin, AMax: Integer): Boolean;
begin
  Result := (Value >= AMin) and (Value <= AMax);
  if not Result then
  begin
    if Value < AMin then
      Value := AMin
    else
      Value := AMax
  end;
end;

function cxSetValue(Condition: Boolean; ATrueValue, AFalseValue: Integer): Integer;
begin
  if Condition then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function cxConfirmMessageBox(const AText, ACaption: string): Boolean;
begin
  Result := Application.MessageBox(PChar(AText), PChar(ACaption),
    MB_ICONQUESTION or MB_OKCANCEL) = ID_OK
end;

initialization
  ValueTypeClassRepository := TcxValueTypeClassRepository.Create;
  RegisterDefaultValueTypeClasses;

finalization
  cxResetMouseHookForDragControl;
  FreeAndNil(ValueTypeClassRepository);

end.
