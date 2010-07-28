
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

unit cxFontNameComboBox;

interface

{$I cxVer.inc}

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Windows, Classes, Controls, Dialogs, Forms, Graphics, Messages, Printers,
  SysUtils, cxClasses, cxContainer, cxControls, cxGraphics, cxButtons,
  cxDataStorage, cxVariants,
  cxEdit, cxTextEdit, cxDropDownEdit, cxEditUtils, cxExtEditConsts, cxExtEditUtils,
  cxImageComboBox, cxLookAndFeels, cxMaskEdit, cxFilterControlUtils;

const
  SYMBOL_FONTTYPE = 256;
  FIXEDPITCH_FONTTYPE = 512;

type
  TcxFontType = (cxftTTF, cxftRaster, cxftDevice, cxftFixed, cxftSymbol);
  TcxFontTypes = set of TcxFontType;
  TcxShowFontIconType = (ftiShowInCombo, ftiShowInList);
  TcxShowFontIconTypes = set of TcxShowFontIconType;
  TcxMRUFontNameAction = (mfaInvalidFontName, mfaNone, mfaMoved, mfaAdded, mfaDeleted);
  TcxFontPreviewType = (cxfpFontName, cxfpCustom, cxfpFullAlphabet);
  TcxDeleteMRUFontEvent = procedure(Sender: TObject; const DeletedMRUFontName: string) of object;

  { TcxMRUFontNameItem }

  TcxMRUFontNameItem = class(TCollectionItem)
  private
    FFontName: TFontName;
    FTag: TcxTag;
    function IsTagStored: Boolean;
    procedure SetFontName(const Value: TFontName);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property FontName: TFontName read FFontName write SetFontName;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
  end;

  { TcxMRUFontNameItems }

  TcxMRUFontNameItems = class(TOwnedCollection)
  private
    function GetItems(Index: Integer): TcxMRUFontNameItem;
    procedure SetItems(Index: Integer; const Value: TcxMRUFontNameItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    function Add: TcxMRUFontNameItem;
    function Insert(Index: Integer): TcxMRUFontNameItem;
    function AddMRUFontName(const AFontName: TFontName): TcxMRUFontNameItem; virtual;
    function InsertMRUFontName(Index: Integer; const AFontName: TFontName): TcxMRUFontNameItem; virtual;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
    destructor Destroy; override;
  {$IFNDEF DELPHI6}
    function Owner: TPersistent;
  {$ENDIF}
    property Items[Index: Integer]: TcxMRUFontNameItem read GetItems write SetItems; default;
    function FindFontName(const AFontName: TFontName): TcxMRUFontNameItem; virtual;
  end;

  { TcxFontLoader }
  
  TcxFontLoader = class(TThread)
  private
    FFontTypes: TcxFontTypes;
    procedure DoCompleteEvent;
    procedure DoDestroyEvent;
  protected
    procedure Execute; override;
  public
    OnCompleteThread: TNotifyEvent;
    OnDestroyThread: TNotifyEvent;
    FontList: TStringList;
    constructor Create(const AFontTypes: TcxFontTypes); virtual;
    destructor Destroy; override;
  end;

  TcxFontButtonType = (cxfbtBold, cxfbtItalic, cxfbtUnderline, cxfbtStrikeOut);
  TcxFontButtonClickEvent = procedure(Sender: TObject; ButtonType: TcxFontButtonType) of Object;

  { TcxFontPreview }

  TcxFontPreview = class(TPersistent)
  private
    FOwner: TPersistent;
    FUpdateCount: Integer;
    FOnChanged: TNotifyEvent;
    FFontStyle: TFontStyles;
    FModified: Boolean;
    FIsDestroying: Boolean;
    FVisible: Boolean;
    FPreviewType: TcxFontPreviewType;
    FPreviewText: TCaption;
    FAlignment: TAlignment;
    FShowEndEllipsis: Boolean;
    FColor: TColor;
    FWordWrap: Boolean;
    FShowButtons: Boolean;
    FOnButtonClick: TcxFontButtonClickEvent;
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsDestroying: Boolean;
    procedure SetFontStyle(Value: TFontStyles);
    procedure SetVisible(Value: Boolean);
    procedure SetPreviewType(Value: TcxFontPreviewType);
    procedure SetPreviewText(Value: TCaption);
    procedure SetAlignment(Value: TAlignment);
    procedure SetShowEndEllipsis(Value: Boolean);
    procedure SetColor(Value: TColor);
    procedure SetWordWrap(Value: Boolean);
    procedure SetShowButtons(Value: Boolean);
  protected
    function GetOwner: TPersistent; override;
    procedure Changed; virtual;
  public
    constructor Create(AOwner: TPersistent); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle default [];
    property Visible: Boolean read FVisible write SetVisible default True;
    property PreviewType: TcxFontPreviewType read FPreviewType write SetPreviewType default cxfpFontName;
    property PreviewText: TCaption read FPreviewText write SetPreviewText;
    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property ShowButtons: Boolean read FShowButtons write SetShowButtons default True;
    property ShowEndEllipsis: Boolean read FShowEndEllipsis write SetShowEndEllipsis default True;
    property Color: TColor read FColor write SetColor default clWindow;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property OnButtonClick: TcxFontButtonClickEvent read FOnButtonClick write FOnButtonClick;
  end;

  { TcxFontPanelButton }

  TcxFontPanelButton = class(TcxButton)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  { TFontPreviewPanel }

  TFontPreviewPanel = class(TCustomControl)
  private
    FLocked: Boolean;
    FcxCanvas: TcxCanvas;
    FFontStyle: TFontStyles;
    FAlignment: TAlignment;
    FShowEndEllipsis: Boolean;
    FEdges: TcxBorders;
    FBorderColor: TColor;
    FFontName: string;
    FWordWrap: Boolean;
    FShowButtons: Boolean;
    FLookAndFeel: TcxLookAndFeel;
    FBoldButton: TcxFontPanelButton;
    FItalicButton: TcxFontPanelButton;
    FUnderLineButton: TcxFontPanelButton;
    FStrikeOutButton: TcxFontPanelButton;
    procedure SetLocked(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetShowEndEllipsis(Value: Boolean);
    procedure SetEdges(Value: TcxBorders);
    procedure SetFontName(Value: string);
    procedure SetFontStyle(Value: TFontStyles);
    procedure SetWordWrap(Value: Boolean);
    procedure SetShowButtons(Value: Boolean);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    function GetTextFlag(const AStartFlag: Longint): Longint;
    procedure CreateButtons;
    procedure SetFontStyleButtonsState;
    procedure FontButtonsClickHandler(Sender: TObject);
  protected
    FontPreview: TcxFontPreview;
    procedure Paint; override;
    procedure CalculateFont(const ARect: TRect); virtual;
    function CalculateFontStyle: TFontStyles; virtual;
    property cxCanvas: TcxCanvas read FcxCanvas write FcxCanvas;
    property Locked: Boolean read FLocked write SetLocked default False;
  public
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property Color default clWindow;
    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property ShowEndEllipsis: Boolean read FShowEndEllipsis write SetShowEndEllipsis default True;
    property Edges: TcxBorders read FEdges write SetEdges default [bLeft, bTop, bRight, bBottom];
    property FontStyle: TFontStyles read FFontStyle write SetFontStyle default [];
    property FontName: string read FFontName write SetFontName;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property ShowButtons: Boolean read FShowButtons write SetShowButtons default True;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RealignButtons;
  end;

  { TcxCustomFontNameComboBoxViewInfo }
  
  TcxCustomFontNameComboBoxViewInfo = class(TcxCustomTextEditViewInfo)
  private
    FCurrentIndex: Integer;
    FIsTrueTypeFont: Boolean;
    ImageRect: TRect;
    FShowFontTypeIcon: TcxShowFontIconTypes;
  protected
    SaveClient: TRect;
    property IsTrueTypeFont: Boolean read FIsTrueTypeFont write FIsTrueTypeFont;
    property ShowFontTypeIcon: TcxShowFontIconTypes read FShowFontTypeIcon write FShowFontTypeIcon;
  public
    procedure Paint(ACanvas: TcxCanvas); override;
    procedure Offset(DX, DY: Integer); override;
  end;

  { TcxCustomFontNameComboBoxViewData }

  TcxCustomFontNameComboBoxProperties = class;

  TcxCustomFontNameComboBoxViewData = class(TcxCustomDropDownEditViewData)
  private
    function GetProperties: TcxCustomFontNameComboBoxProperties;
  protected
    function IsComboBoxStyle: Boolean; override;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
      const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean); override;
    procedure DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    function GetEditContentSize(ACanvas: TcxCanvas;
      const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;
    property Properties: TcxCustomFontNameComboBoxProperties
      read GetProperties;
  end;

  { TcxFontNameComboBoxListBox }

  TcxCustomFontNameComboBox = class;

  TcxFontNameComboBoxListBox = class(TcxCustomComboBoxListBox)
  private
    function GetEdit: TcxCustomFontNameComboBox;
    function IsSymbolFontType(AItemIndex: Integer): Boolean;
  protected
    function GetItem(Index: Integer): string; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    property Edit: TcxCustomFontNameComboBox read GetEdit;
  public
    function GetItemHeight(AIndex: Integer = -1): Integer; override;
    function GetItemWidth(AIndex: Integer): Integer; override;
  end;

  { TcxFontNameComboBoxLookupData }
  
  TcxFontNameComboBoxLookupData = class(TcxComboBoxLookupData)
  private
    FPanel: TFontPreviewPanel;
    function GetFontName: string;
    function GetPreviewText: string;
  protected
    function GetListBoxClass: TcxCustomEditListBoxClass; override;
    procedure HandleSelectItem(Sender: TObject); override;
    procedure InternalChangeCurrentMRUFontNamePosition; virtual;
  public
    destructor Destroy; override;
    function CanResizeVisualArea(var NewSize: TSize;
      AMaxHeight: Integer = 0; AMaxWidth: Integer = 0): Boolean; override;
    function GetVisualAreaPreferredSize(AMaxHeight: Integer; AWidth: Integer = 0): TSize; override;
    procedure Initialize(AVisualControlsParent: TWinControl); override;
    procedure PositionVisualArea(const AClientRect: TRect); override;
  end;

  { TcxCustomFontNameComboBoxProperties }

  TcxCustomFontNameComboBoxProperties = class(TcxCustomComboBoxProperties)
  private
    FFontLoader: TcxFontLoader;
    FFontPreview: TcxFontPreview;
    FFontTypes: TcxFontTypes;
    FLoadFontComplete: Boolean;
    FMaxMRUFonts: Byte;
    FMRUFontNames: TcxMRUFontNameItems;
    FShowFontTypeIcon: TcxShowFontIconTypes;
    FUseOwnFont: Boolean;
    FOnAddedMRUFont: TNotifyEvent;
    FOnDeletedMRUFont: TcxDeleteMRUFontEvent;
    FOnInternalLoadFontComplete: TNotifyEvent;
    FOnLoadFontComplete: TNotifyEvent;
    FOnMovedMRUFont: TNotifyEvent;
    function GetFontItems: TStrings;
    function GetFontTypes: TcxFontTypes;
    function GetUseOwnFont: Boolean;
    procedure SetMaxMRUFonts(Value: Byte);
    procedure SetFontTypes(Value: TcxFontTypes);
    procedure SetUseOwnFont(Value: Boolean);
    procedure SetShowFontTypeIcon(Value: TcxShowFontIconTypes);
    function FindItemByValue(const AEditValue: TcxEditValue): Integer;
    procedure DeleteOverMRUFonts;
    procedure FontLoaderCompleteHandler(Sender: TObject);
    procedure FontLoaderDestroyHandler(Sender: TObject);
    function GetItemTypes(Index: Integer): TcxFontTypes;
    procedure SetFontPreview(Value: TcxFontPreview);
    procedure ShutDownFontLoader;
  protected
    function FindLookupText(const AText: string): Boolean; override;
    class function GetLookupDataClass: TcxInterfacedPersistentClass; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function AddMRUFontName(
      const AFontName: TFontName): TcxMRUFontNameAction; virtual;
    function DelMRUFontName(
      const AFontName: TFontName): TcxMRUFontNameAction; virtual;
    property ItemTypes[Index: Integer]: TcxFontTypes read GetItemTypes;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    procedure GetFontNameComboBoxDisplayValue(const AEditValue: TcxEditValue;
      out AItemIndex: Integer; out AText: string);
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    property LoadFontComplete: Boolean read FLoadFontComplete;
    procedure LoadFontNames; virtual;
    procedure Update(AProperties: TcxCustomEditProperties); override;
    property FontItems: TStrings read GetFontItems;
    property MRUFontNames: TcxMRUFontNameItems read FMRUFontNames;
    // !!!
    property FontPreview: TcxFontPreview read FFontPreview write SetFontPreview;
    property FontTypes: TcxFontTypes read GetFontTypes write SetFontTypes
      default [cxftTTF, cxftRaster, cxftDevice, cxftFixed, cxftSymbol];
    property MaxMRUFonts: Byte read FMaxMRUFonts write SetMaxMRUFonts
      default 10;
    property ShowFontTypeIcon: TcxShowFontIconTypes read FShowFontTypeIcon
      write SetShowFontTypeIcon default [ftiShowInCombo, ftiShowInList];
    property UseOwnFont: Boolean read GetUseOwnFont write SetUseOwnFont
      default False;
    property OnAddedMRUFont: TNotifyEvent read FOnAddedMRUFont
      write FOnAddedMRUFont;
    property OnDeletedMRUFont: TcxDeleteMRUFontEvent read FOnDeletedMRUFont
      write FOnDeletedMRUFont;
    property OnLoadFontComplete: TNotifyEvent read FOnLoadFontComplete
      write FOnLoadFontComplete;
    property OnMovedMRUFont: TNotifyEvent read FOnMovedMRUFont
      write FOnMovedMRUFont;
  end;

  { TcxFontNameComboBoxProperties }

  TcxFontNameComboBoxProperties = class(TcxCustomFontNameComboBoxProperties)
  published
    property Alignment;
    property AssignedValues;
    property BeepOnError;
    property ButtonGlyph;
    property CharCase;
    property ClearKey;
    property DropDownAutoWidth;
    property DropDownRows;
    property DropDownSizeable;
    property DropDownWidth;
    property FontPreview;
    property FontTypes;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property ImmediateDropDown;
    property ImmediatePost;
    property ImmediateUpdateText;
    property ItemHeight;
    property MaxMRUFonts;
    property OEMConvert;
    property PopupAlignment;
    property PostPopupValueOnTab;
    property ReadOnly;
    property ShowFontTypeIcon;
    property UseOwnFont;
    property ValidateOnEnter;
    property OnAddedMRUFont;
    property OnChange;
    property OnCloseUp;
    property OnDeletedMRUFont;
    property OnDrawItem;
    property OnEditValueChanged;
    property OnInitPopup;
    property OnLoadFontComplete;
    property OnMeasureItem;
    property OnMovedMRUFont;
    property OnNewLookupDisplayText;
    property OnPopup;
    property OnValidate;
  end;

  { TcxCustomFontNameComboBoxInnerEdit }

  TcxCustomFontNameComboBoxInnerEdit = class(TcxCustomComboBoxInnerEdit);

  { TcxCustomFontNameComboBox }

  TcxCustomFontNameComboBox = class(TcxCustomComboBox)
  private
    FDontCheckModifiedWhenUpdatingMRUList: Boolean;
    FFontNameQueue: string;
    FNeedsUpdateMRUList: Boolean;
    function GetFontName: string;
    procedure SetFontName(Value: string);
    function GetLookupData: TcxFontNameComboBoxLookupData;
    function GetProperties: TcxCustomFontNameComboBoxProperties;
    function GetActiveProperties: TcxCustomFontNameComboBoxProperties;
    procedure SetProperties(Value: TcxCustomFontNameComboBoxProperties);
    procedure InternalLoadFontCompleteHandler(Sender: TObject);
    procedure UpdateMRUList;
  protected
    procedure AfterPosting; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    function GetInnerEditClass: TControlClass; override;
    function GetPopupWindowClientPreferredSize: TSize; override;
    procedure Initialize; override;
    procedure InitializePopupWindow; override;
    procedure CloseUp(AReason: TcxEditCloseUpReason); override;
    procedure SetItemIndex(Value: Integer); override;
    property LookupData: TcxFontNameComboBoxLookupData read GetLookupData;
  public
  {$IFDEF CBUILDER10}
    constructor Create(AOwner: TComponent); override;
  {$ENDIF}
    function Deactivate: Boolean; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    function AddMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
    function DelMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
    property ActiveProperties: TcxCustomFontNameComboBoxProperties
      read GetActiveProperties;
    property FontName: string read GetFontName write SetFontName;
    property Properties: TcxCustomFontNameComboBoxProperties read GetProperties
      write SetProperties;
  end;

  { TcxFontNameComboBox }

  TcxFontNameComboBox = class(TcxCustomFontNameComboBox)
  private
    function GetActiveProperties: TcxFontNameComboBoxProperties;
    function GetProperties: TcxFontNameComboBoxProperties;
    procedure SetProperties(Value: TcxFontNameComboBoxProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxFontNameComboBoxProperties
      read GetActiveProperties;
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
    property Properties: TcxFontNameComboBoxProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Text;
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

  { TcxFilterFontNameComboBoxHelper }

  TcxFilterFontNameComboBoxHelper = class(TcxFilterComboBoxHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
  end;

var
  FTrueTypeFontBitmap, FNonTrueTypeFontBitmap : TBitmap;

procedure GetFontSizes(const AFontName: string; AFontSizes: TStrings);
function GetFontTypes(const AFontName: string): TcxFontTypes;
function RealFontTypeToCxTypes(const AFontType: Integer): TcxFontTypes;

implementation

uses 
{$IFDEF DELPHI6}  
  Types,
{$ENDIF}
  cxListBox;

{$R cxFontNameComboBox.res}

type
  TCanvasAccess = class(TCanvas);

const
  DropDownListTextOffset = 2;
  NUM_SIZES = 16;
  caiFontSizes: array[0 .. NUM_SIZES - 1] of Integer =
    (8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48, 72);
  cxFontPreviewPanelDefaultHeight = 38;
  IconBorderWidth = 4;
  IconTextOffset = 2;
  ItemSymbolFontExampleOffset = 4;

var
  FFontList: TStringList;
  FFontSizes: TStrings;
  vbFtt : Boolean;

function RealFontTypeToCxTypes(const AFontType: Integer): TcxFontTypes;
begin
  Result := [];
  if (AFontType and TRUETYPE_FONTTYPE) <> 0 then
    Result := Result + [cxftTTF];
  if (AFontType and RASTER_FONTTYPE) <> 0 then
    Result := Result + [cxftRaster];
  if (AFontType and DEVICE_FONTTYPE) <> 0 then
    Result := Result + [cxftDevice];
  if (AFontType and FIXEDPITCH_FONTTYPE) <> 0 then
    Result := Result + [cxftFixed];
  if (AFontType and SYMBOL_FONTTYPE) <> 0 then
    Result := Result + [cxftSymbol];
end;

function IsValidFontCondition(AFontTypes: TcxFontTypes;
  const ALogFont: TLogFont; AFontType: Integer): Boolean;
begin
  Result :=
    ((cxftTTF in AFontTypes) and (AFontType and TRUETYPE_FONTTYPE = TRUETYPE_FONTTYPE)) or
    ((cxftDevice in AFontTypes) and (AFontType and DEVICE_FONTTYPE = DEVICE_FONTTYPE)) or
    ((cxftRaster in AFontTypes) and (AFontType and RASTER_FONTTYPE = RASTER_FONTTYPE)) or
    ((cxftFixed in AFontTypes) and (ALogFont.lfPitchAndFamily and FIXED_PITCH = FIXED_PITCH)) or
    ((cxftSymbol in AFontTypes) and (ALogFont.lfCharSet = SYMBOL_CHARSET));
end;

function EnumFontsProc(var ALogFont: TLogFont; var ATextMetric: TTextMetric;
  AFontType: DWORD; AData: LPARAM): Integer; stdcall;
begin
  if ALogFont.lfCharSet = SYMBOL_CHARSET then
    AFontType := AFontType or SYMBOL_FONTTYPE;
  if ALogFont.lfPitchAndFamily = FIXED_PITCH then
    AFontType := AFontType or FIXEDPITCH_FONTTYPE;
  FFontList.AddObject(ALogFont.lfFaceName, TObject(Integer(AFontType)));
  Result := 0;
end;

function EnumFontsProc2(AFontLoader: TcxFontLoader; const ALogFont: TLogFont;
  AFontType: DWORD): Integer;
var
  AFaceName: string;
begin
  AFaceName := ALogFont.lfFaceName;
  if (AFontLoader.FontList.IndexOf(AFaceName) = -1) and
    IsValidFontCondition(AFontLoader.FFontTypes, ALogFont, AFontType) then
  begin
    if ALogFont.lfCharSet = SYMBOL_CHARSET then
      AFontType := AFontType or SYMBOL_FONTTYPE;
    if ALogFont.lfPitchAndFamily = FIXED_PITCH then
      AFontType := AFontType or FIXEDPITCH_FONTTYPE;
    AFontLoader.FontList.AddObject(AFaceName, TObject(Integer(AFontType)));
  end;
  if AFontLoader.Terminated then
    Result := 0
  else
    Result := 1;
end;

function EnumFontsProc1(var ALogFont: TLogFont;
  var ATextMetric: TTextMetric; AFontType: DWORD;
  AData: LPARAM): Integer; stdcall;
begin
  Result := EnumFontsProc2(TcxFontLoader(AData), ALogFont, AFontType);
end;

procedure InitLogFont(var ALogFont: TLogFont; const AFontName: string);
begin
  FillChar(ALogFont, SizeOf(ALogFont), 0);
  StrPCopy(ALogFont.lfFaceName, AFontName);
  ALogFont.lfCharset := DEFAULT_CHARSET;
end;

function GetFontTypes(const AFontName: string): TcxFontTypes;

  procedure EnumFonts;
  var
    ADC: HDC;
    ALogFont: TLogFont;
  begin
    ADC := GetDC(0);
    try
      InitLogFont(ALogFont, AFontName);
      EnumFontFamiliesEx(ADC, ALogFont, @EnumFontsProc, 0, 0);
    finally
      ReleaseDC(0, ADC);
    end;
  end;

begin
  FFontList := TStringList.Create;
  try
    Result := [];
    EnumFonts;
    if FFontList.Count > 0 then
      Result := RealFontTypeToCxTypes(Integer(FFontList.Objects[0]));
  finally
    FFontList.Free;
  end;
end;

function SetFontSizes(var ALogFont: TLogFont; var ATextMetric: TTextMetric;
  AFontType: DWORD; AData: LPARAM): Integer; stdcall;
var
  S: string;
begin
  S := IntToStr(((ATextMetric.tmHeight - ATextMetric.tmInternalLeading) * 72 +
    ATextMetric.tmDigitizedAspectX div 2) div ATextMetric.tmDigitizedAspectY);
  if FFontSizes.IndexOf(S) = -1 then
    FFontSizes.Add(S);
  Result := 1;
end;

function SetFTypeFlag(var ALogFont: TLogFont; var ATextMetric: TTextMetric;
  AFontType: DWORD; AData: LPARAM): Integer; stdcall;
begin
  vbFtt := (ATextMetric.tmPitchAndFamily and TMPF_TRUETYPE) = TMPF_TRUETYPE;
  Result := 0;
end;

procedure GetFontSizes(const AFontName: string; AFontSizes: TStrings);

  function IsTrueTypeFont(ADC: HDC; var ALogFont: TLogFont): Boolean;
  begin
    EnumFontFamiliesEx(ADC, ALogFont, @SetFTypeFlag, 0, 0);
    Result := vbFtt;
  end;

var
  ADC: HDC;
  ALogFont: TLogFont;
  I: Integer;
begin
  ADC := GetDC(0);
  try
    InitLogFont(ALogFont, AFontName);
    FFontSizes := AFontSizes;
    FFontSizes.Clear;
    if IsTrueTypeFont(ADC, ALogFont) then
      for I := 0 to NUM_SIZES - 1 do
        AFontSizes.Add(Format('%d',[caiFontSizes[I]]))
    else
      EnumFontFamiliesEx(ADC, ALogFont, @SetFontSizes, 0, 0);
  finally
    ReleaseDC(0, ADC);
  end;
end;

{ TcxFontLoader }

constructor TcxFontLoader.Create(const AFontTypes: TcxFontTypes);
begin
  FFontTypes := AFontTypes;
  FontList := TStringList.Create;
  inherited Create(True);
  FreeOnTerminate := True;
end;

destructor TcxFontLoader.Destroy;
begin
  Synchronize(DoCompleteEvent);
  if Assigned(FontList) then
    FreeAndNil(FontList);
  Synchronize(DoDestroyEvent);
  inherited Destroy;
end;

procedure TcxFontLoader.DoCompleteEvent;
begin
  if Assigned(OnCompleteThread) then OnCompleteThread(Self);
end;

procedure TcxFontLoader.DoDestroyEvent;
begin
  if Assigned(OnDestroyThread) then OnDestroyThread(Self);
end;

procedure TcxFontLoader.Execute;

  procedure EnumFonts;
  var
    ADC: HDC;
    ALogFont: TLogFont;
  begin
    ADC := GetDC(0);
    try
      InitLogFont(ALogFont, '');
      EnumFontFamiliesEx(ADC, ALogFont, @EnumFontsProc1, LPARAM(Self), 0);
    finally
      ReleaseDC(0, ADC);
    end;
  end;

begin
  try
    FontList.BeginUpdate;
    FontList.Clear;
    EnumFonts;
    TStringList(FontList).Sort;
  finally
    FontList.EndUpdate;
  end;
end;

{ TcxFontPreview }

constructor TcxFontPreview.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FUpdateCount := 0;
  FModified := False;
  FFontStyle := [];
  FVisible := True;
  FPreviewType := cxfpFontName;
  FPreviewText := '';
  FAlignment := taCenter;
  FShowEndEllipsis := True;
  FColor := clWindow;
  FWordWrap := False;
  FShowButtons := True;
end;

destructor TcxFontPreview.Destroy;
begin
  FIsDestroying := True;
  inherited Destroy;
end;

procedure TcxFontPreview.Assign(Source: TPersistent);
begin
  if Source is TcxFontPreview then
  begin
    BeginUpdate;
    try
      with Source as TcxFontPreview do
      begin
        Self.Visible := Visible;
        Self.FontStyle := FontStyle;
        Self.PreviewType := PreviewType;
        Self.PreviewText := PreviewText;
        Self.Alignment := Alignment;
        Self.ShowEndEllipsis := ShowEndEllipsis;
        Self.Color := Color;
        Self.WordWrap := WordWrap;
        Self.ShowButtons := ShowButtons;
        Self.OnButtonClick := OnButtonClick;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxFontPreview.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxFontPreview.Changed;
begin
  if FUpdateCount = 0 then
  begin
    if Assigned(FOnChanged) and not IsDestroying then
      FOnChanged(Self);
    FModified := False;
  end
  else
    FModified := True;
end;

procedure TcxFontPreview.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TcxFontPreview.EndUpdate;
begin
  if FUpdateCount <> 0 then
  begin
    Dec(FUpdateCount);
    if FModified then Changed;
  end;
end;

function TcxFontPreview.IsDestroying: Boolean;
begin
  Result := FIsDestroying;
end;

procedure TcxFontPreview.SetFontStyle(Value: TFontStyles);
begin
  if FFontStyle <> Value then
  begin
    FFontStyle := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetPreviewType(Value: TcxFontPreviewType);
begin
  if FPreviewType <> Value then
  begin
    FPreviewType := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetPreviewText(Value: TCaption);
begin
  if FPreviewText <> Value then
  begin
    FPreviewText := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetShowEndEllipsis(Value: Boolean);
begin
  if FShowEndEllipsis <> Value then
  begin
    FShowEndEllipsis := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetWordWrap(Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

procedure TcxFontPreview.SetShowButtons(Value: Boolean);
begin
  if FShowButtons <> Value then
  begin
    FShowButtons := Value;
    Changed;
  end;
end;
{ TcxFontPreview }

{ TcxFontPanelButton }
procedure TcxFontPanelButton.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONUP: Dispatch(Message);
  end;
end;

{ TFontPreviewPanel }

constructor TFontPreviewPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  Width := 100;
  Height := 40;
  FAlignment := taCenter;
  FShowEndEllipsis := True;
  FShowButtons := True;
  FEdges := [bLeft, bTop, bRight, bBottom];
  FBorderColor := clWindowFrame;
  FWordWrap := False;
  FFontStyle := [];
  Color := clWindow;
  UseDockManager := True;
  FcxCanvas := TcxCanvas.Create(Canvas);
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  CreateButtons;
end;

destructor TFontPreviewPanel.Destroy;
begin
  FreeAndNil(FStrikeOutButton);
  FreeAndNil(FUnderLineButton);
  FreeAndNil(FItalicButton);
  FreeAndNil(FBoldButton);
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FcxCanvas);
  inherited;
end;

procedure TFontPreviewPanel.CreateButtons;

  procedure InitButton(AButton: TcxFontPanelButton; const AButtonSize: TSize);
  begin
    AButton.Font.Name := 'Arial';
    AButton.Font.Size := 8;
    AButton.Height := AButtonSize.cx;
    AButton.LookAndFeel.MasterLookAndFeel := LookAndFeel;
    AButton.UseSystemPaint := True;
    AButton.Width := AButtonSize.cy;
    AButton.Parent := Self;
    AButton.OnClick := FontButtonsClickHandler;
  end;

var
  AButtonSize: TSize;
begin
  FBoldButton := TcxFontPanelButton.Create(Self);

  FBoldButton.Font.Name := 'Arial';
  FBoldButton.Font.Size := 8;
  AButtonSize.cx := NonCanvasTextWidth(FBoldButton.Font, 'B') + 8;
  AButtonSize.cy := NonCanvasTextHeight(FBoldButton.Font) + 2;

  FBoldButton.Caption := 'B';
  FBoldButton.Tag := 0;
  InitButton(FBoldButton, AButtonSize);

  FItalicButton := TcxFontPanelButton.Create(Self);
  FItalicButton.Caption := 'I';
  FItalicButton.Tag := 1;
  InitButton(FItalicButton, AButtonSize);

  FUnderLineButton := TcxFontPanelButton.Create(Self);
  FUnderLineButton.Caption := 'U';
  FUnderLineButton.Tag := 2;
  InitButton(FUnderLineButton, AButtonSize);

  FStrikeOutButton := TcxFontPanelButton.Create(Self);
  FStrikeOutButton.Caption := 'S';
  FStrikeOutButton.Tag := 3;
  InitButton(FStrikeOutButton, AButtonSize);
end;

procedure TFontPreviewPanel.RealignButtons;
begin
  FBoldButton.Visible := ShowButtons;
  FItalicButton.Visible := ShowButtons;
  FUnderLineButton.Visible := ShowButtons;
  FStrikeOutButton.Visible := ShowButtons;
  if ShowButtons = True then
  begin
    FBoldButton.Top := Height - FBoldButton.Height - 2;
    FItalicButton.Top := FBoldButton.Top;
    FUnderLineButton.Top := FBoldButton.Top;
    FStrikeOutButton.Top := FBoldButton.Top;

    FStrikeOutButton.Left := Width - FStrikeOutButton.Width - 1;
    FUnderLineButton.Left := FStrikeOutButton.Left - FUnderLineButton.Width - 1;
    FItalicButton.Left := FUnderLineButton.Left - FItalicButton.Width - 1;
    FBoldButton.Left := FItalicButton.Left - FBoldButton.Width - 1;
  end;
end;

procedure TFontPreviewPanel.SetFontStyleButtonsState;
begin
  if (fsBold in FFontStyle) then
  begin
    FBoldButton.Colors.Normal := GetLightSelColor;
    FBoldButton.Font.Style := [fsBold];
  end
  else
  begin
    FBoldButton.Colors.Normal := clDefault;
    FBoldButton.Font.Style := [];
  end;
  if (fsItalic in FFontStyle) then
  begin
    FItalicButton.Colors.Normal := GetLightSelColor;
    FItalicButton.Font.Style := [fsBold];
  end
  else
  begin
    FItalicButton.Colors.Normal := clDefault;
    FItalicButton.Font.Style := [];
  end;
  if (fsUnderLine in FFontStyle) then
  begin
    FUnderLineButton.Colors.Normal := GetLightSelColor;
    FUnderLineButton.Font.Style := [fsBold];
  end
  else
  begin
    FUnderLineButton.Colors.Normal := clDefault;
    FUnderLineButton.Font.Style := [];
  end;
  if (fsStrikeOut in FFontStyle) then
  begin
    FStrikeOutButton.Colors.Normal := GetLightSelColor;
    FStrikeOutButton.Font.Style := [fsBold];
  end
  else
  begin
    FStrikeOutButton.Colors.Normal := clDefault;
    FStrikeOutButton.Font.Style := [];
  end;
end;

procedure TFontPreviewPanel.Paint;
var
  FRect: TRect;
begin
  FRect := GetClientRect;
  with cxCanvas do
  begin
    Brush.Color := Color;
    FillRect(FRect);
    DrawComplexFrame(FRect, FBorderColor, FBorderColor, FEdges);
    InflateRect(FRect, -2, -2);
    Brush.Style := bsClear;
    CalculateFont(FRect);
    cxDrawText(Canvas.Handle, Caption, FRect, GetTextFlag(DT_NOPREFIX));
  end;
end;

procedure TFontPreviewPanel.CalculateFont(const ARect: TRect);
var
  FTextRect: TRect;
begin
  if FontName = '' then
    Canvas.Font.Name := 'Arial'
  else
    Canvas.Font.Name := FontName;
  Canvas.Font.Size := 8;
  Canvas.Font.Style := CalculateFontStyle;
  if Trim(Caption) = '' then Exit;
  FTextRect := Rect(ARect.Left, ARect.Top, ARect.Right - 1, ARect.Top + 1);
  while (RectHeight(FTextRect) <= RectHeight(ARect)) and
        (RectWidth(FTextRect) <= RectWidth(ARect)) do
  begin
    DrawText(Canvas.Handle, PChar(Caption),
      Length(Caption), FTextRect, GetTextFlag(DT_CALCRECT or DT_NOPREFIX));
    if (RectHeight(FTextRect) <= RectHeight(ARect)) and
      (RectWidth(FTextRect) <= RectWidth(ARect)) then
        Canvas.Font.Size := Canvas.Font.Size + 1
    else
      if Canvas.Font.Size > 8 then
        Canvas.Font.Size := Canvas.Font.Size - 1;
  end;
end;

function TFontPreviewPanel.GetTextFlag(const AStartFlag: Longint): Longint;
const
  ShowEndEllipsisArray: array[Boolean] of Integer = (0, DT_END_ELLIPSIS);
  WordWrapArray: array[Boolean] of Integer = (0, DT_WORDBREAK);
begin
  Result := AStartFlag or SystemAlignmentsHorz[Alignment] or DT_VCENTER or
    ShowEndEllipsisArray[ShowEndEllipsis] or WordWrapArray[WordWrap];
end;

function TFontPreviewPanel.CalculateFontStyle: TFontStyles;
begin
  Result := FFontStyle;
end;

procedure TFontPreviewPanel.FontButtonsClickHandler(Sender: TObject);
begin
  case (TComponent(Sender).Tag) of
    0: if (fsBold in FFontStyle) then
         FFontStyle := FFontStyle - [fsBold]
       else
         FFontStyle := FFontStyle + [fsBold];
    1: if (fsItalic in FFontStyle) then
         FFontStyle := FFontStyle - [fsItalic]
       else
         FFontStyle := FFontStyle + [fsItalic];
    2: if (fsUnderLine in FFontStyle) then
         FFontStyle := FFontStyle - [fsUnderLine]
       else
         FFontStyle := FFontStyle + [fsUnderLine];
    3: if (fsStrikeOut in FFontStyle) then
         FFontStyle := FFontStyle - [fsStrikeOut]
       else
         FFontStyle := FFontStyle + [fsStrikeOut];
  end;

  FontPreview.FontStyle := FFontStyle;
  if Assigned(FontPreview.OnButtonClick) then
    FontPreview.OnButtonClick(Self, TcxFontButtonType((Sender as TComponent).Tag));

  if TcxFontPanelButton(Sender).Colors.Normal <> clDefault then
  begin
    TcxFontPanelButton(Sender).Colors.Normal := clDefault;
    TcxFontPanelButton(Sender).Font.Style := [];
  end else
  begin
    TcxFontPanelButton(Sender).Colors.Normal := GetLightSelColor;
    TcxFontPanelButton(Sender).Font.Style := [fsBold];
  end;

  Invalidate;
end;

procedure TFontPreviewPanel.SetLocked(Value: Boolean);
begin
  FLocked := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetShowEndEllipsis(Value: Boolean);
begin
  FShowEndEllipsis := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetEdges(Value: TcxBorders);
begin
  FEdges := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetFontName(Value: string);
begin
  FFontName := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetFontStyle(Value: TFontStyles);
begin
  FFontStyle := Value;
  SetFontStyleButtonsState;
end;

procedure TFontPreviewPanel.SetWordWrap(Value: Boolean);
begin
  FWordWrap := Value;
  if FLocked = False then Invalidate;
end;

procedure TFontPreviewPanel.SetShowButtons(Value: Boolean);
begin
  if FShowButtons <> Value then
  begin
    FShowButtons := Value;
    RealignButtons;
  end;
end;

procedure TFontPreviewPanel.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
  RealignButtons;
end;

{ TcxMRUFontNameItem }

procedure TcxMRUFontNameItem.Assign(Source: TPersistent);
begin
  if Source is TcxMRUFontNameItem then
  begin
    FontName := TcxMRUFontNameItem(Source).FontName;
    Tag := TcxMRUFontNameItem(Source).Tag;
  end
  else
    inherited Assign(Source);
end;

function TcxMRUFontNameItem.IsTagStored: Boolean;
begin
  Result := FTag <> 0;
end;

procedure TcxMRUFontNameItem.SetFontName(const Value: TFontName);
begin
  if FFontName <> Value then
  begin
    FFontName := Value;
    Changed(True);
  end;
end;

{ TcxMRUFontNameItems }

constructor TcxMRUFontNameItems.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, ItemClass);
end;

destructor TcxMRUFontNameItems.Destroy;
begin
  inherited Destroy;
end;

function TcxMRUFontNameItems.GetItems(Index: Integer): TcxMRUFontNameItem;
begin
  Result := TcxMRUFontNameItem(inherited Items[Index]);
end;

procedure TcxMRUFontNameItems.SetItems(Index: Integer; const Value: TcxMRUFontNameItem);
begin
  inherited Items[Index] := Value;
end;

procedure TcxMRUFontNameItems.Update(Item: TCollectionItem);
begin
  TcxCustomFontNameComboBoxProperties(Owner).Changed;
end;

{$IFNDEF DELPHI6}
function TcxMRUFontNameItems.Owner: TPersistent;
begin
  Result := GetOwner;
end;
{$ENDIF}

function TcxMRUFontNameItems.Add: TcxMRUFontNameItem;
begin
  Result := TcxMRUFontNameItem(inherited Add);
end;

function TcxMRUFontNameItems.Insert(Index: Integer): TcxMRUFontNameItem;
begin
  Result := TcxMRUFontNameItem(inherited Insert(Index));
end;

procedure TcxMRUFontNameItems.Move(CurIndex, NewIndex: Integer);
var
  FNewFontNameItem, FOldFontNameItem: TcxMRUFontNameItem;
begin
  if CurIndex = NewIndex then Exit;
  FOldFontNameItem := Items[CurIndex];
  FNewFontNameItem := Insert(NewIndex);
  FNewFontNameItem.Assign(FOldFontNameItem);
  FOldFontNameItem.Free;
end;

function TcxMRUFontNameItems.AddMRUFontName(const AFontName: TFontName): TcxMRUFontNameItem;
begin
  Result := nil;
  if (AFontName = '') or (FindFontName(AFontName) <> nil) then Exit;
  Result := Add;
  Result.FontName := AFontName;
end;

function TcxMRUFontNameItems.InsertMRUFontName(Index: Integer;const AFontName: TFontName): TcxMRUFontNameItem;
begin
  Result := nil;
  if (AFontName = '') or (FindFontName(AFontName) <> nil) then Exit;
  Result := Insert(Index);
  Result.FontName := AFontName;
end;

function TcxMRUFontNameItems.FindFontName(const AFontName: TFontName): TcxMRUFontNameItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Items[I].FontName = AFontName then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

{ TcxCustomFontNameComboBoxViewInfo }
procedure TcxCustomFontNameComboBoxViewInfo.Paint(ACanvas: TcxCanvas);
var
  ACurrentBitmap: TBitmap;
begin
  inherited Paint(ACanvas);
  if (FCurrentIndex <> -1) and (ftiShowInCombo in ShowFontTypeIcon) then
  begin
    if IsTrueTypeFont then
      ACurrentBitmap := FTrueTypeFontBitmap
    else
      ACurrentBitmap := FNonTrueTypeFontBitmap;
    if ACurrentBitmap <> nil then
      DrawGlyph(ACanvas, ImageRect.Left, ImageRect.Top,
        ACurrentBitmap, Enabled);
  end;
end;

procedure TcxCustomFontNameComboBoxViewInfo.Offset(DX, DY: Integer);
begin
  inherited;
  OffsetRect(ImageRect, DX, DY);
end;

{ TcxCustomFontNameComboBoxViewData }

procedure TcxCustomFontNameComboBoxViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);

  function GetIconOffset(AClientRect: TRect): TPoint;
  begin
    Result.Y := (RectHeight(AClientRect) - FTrueTypeFontBitmap.Height) div 2;
    if IsInplace then
      Result.X := IconBorderWidth - cxInplaceEditOffset
    else
      Result.X := IconBorderWidth;
  end;

  procedure CalculateImageRect(AViewInfo: TcxCustomFontNameComboBoxViewInfo);
  begin
    AViewInfo.ImageRect := AViewInfo.ClientRect;
    if FTrueTypeFontBitmap = nil then
      Exit;
    AViewInfo.ImageRect.Right :=
      AViewInfo.ImageRect.Left + FTrueTypeFontBitmap.Width;
    AViewInfo.ImageRect.Bottom :=
      AViewInfo.ImageRect.Top + FTrueTypeFontBitmap.Height;
    cxOffsetRect(AViewInfo.ImageRect,
      GetIconOffset(AViewInfo.ClientRect));
  end;

var
  AEditViewInfo: TcxCustomFontNameComboBoxViewInfo;
begin
  if IsRectEmpty(ABounds) then
  begin
    inherited;
    Exit;
  end;
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  if (ABounds.Right = MaxInt) or (ABounds.Bottom = MaxInt) then Exit;

  AEditViewInfo := TcxCustomFontNameComboBoxViewInfo(AViewInfo);
  AEditViewInfo.ShowFontTypeIcon := Properties.ShowFontTypeIcon;

  if (ftiShowInCombo in AEditViewInfo.ShowFontTypeIcon) then
  begin
    CalculateImageRect(AEditViewInfo);
    AEditViewInfo.TextRect.Left := AEditViewInfo.ImageRect.Right +
      IconBorderWidth + IconTextOffset;
  end;

  if not IsInplace then
    AEditViewInfo.DrawSelectionBar := False;
end;

procedure TcxCustomFontNameComboBoxViewData.DisplayValueToDrawValue(
  const ADisplayValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  AViewInfoAccess: TcxCustomFontNameComboBoxViewInfo;
begin
  AViewInfoAccess := TcxCustomFontNameComboBoxViewInfo(AViewInfo);
  Properties.GetFontNameComboBoxDisplayValue(ADisplayValue,
    AViewInfoAccess.FCurrentIndex, AViewInfoAccess.Text);
  if PreviewMode then
    AViewInfoAccess.Text := '';
  if AViewInfoAccess.FCurrentIndex <> -1 then
    AViewInfoAccess.IsTrueTypeFont :=
      (cxftTTF in Properties.ItemTypes[AViewInfoAccess.FCurrentIndex]);
end;

procedure TcxCustomFontNameComboBoxViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
  PrepareSelection(AViewInfo);
  DisplayValueToDrawValue(AEditValue, AViewInfo);
  DoOnGetDisplayText(string(TcxCustomTextEditViewInfo(AViewInfo).Text));
end;

function TcxCustomFontNameComboBoxViewData.GetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue;
  const AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  FItemIndex: Integer;
begin
  Result := inherited GetEditContentSize(ACanvas, AEditValue, AEditSizeProperties);
  FItemIndex := Properties.FindItemByValue(AEditValue);
  if (FItemIndex >= 0) and (ftiShowInCombo in Properties.ShowFontTypeIcon) then
    Result.cx := Result.cx + FTrueTypeFontBitmap.Width + 4;
end;

function TcxCustomFontNameComboBoxViewData.IsComboBoxStyle: Boolean;
begin
  Result := True;
end;

function TcxCustomFontNameComboBoxViewData.GetProperties: TcxCustomFontNameComboBoxProperties;
begin
  Result := TcxCustomFontNameComboBoxProperties(FProperties);
end;

{ TcxFontNameComboBoxListBox }

function TcxFontNameComboBoxListBox.GetItemHeight(AIndex: Integer = -1): Integer;
begin
  with Edit.ActiveProperties do
  begin
    if ItemHeight > 0 then
      Result := ItemHeight
    else
    begin
      Result := inherited GetItemHeight;
      if UseOwnFont then
        Inc(Result, 4)
      else
        if Result <= FTrueTypeFontBitmap.Height then
          Result := FTrueTypeFontBitmap.Height + 4;
    end;
    if (AIndex >= 0) and Edit.IsOnMeasureItemEventAssigned then
      Edit.DoOnMeasureItem(AIndex, Canvas, Result);
    if AIndex = (FMRUFontNames.Count - 1) then
      Inc(Result, MRUDelimiterWidth);
  end;
end;

function TcxFontNameComboBoxListBox.GetItemWidth(AIndex: Integer): Integer;
var
  AFontName, ACanvasFontName: string;
  ACanvasFontCharSet: TFontCharSet;
begin
  if Edit.ActiveProperties.UseOwnFont then
  begin
    Canvas.Font.Assign(Font);
    ACanvasFontName := Canvas.Font.Name;
    ACanvasFontCharSet := Canvas.Font.Charset;
    try
      Result := 0;
      AFontName := GetItem(AIndex);
      if IsSymbolFontType(AIndex) then
      begin
        Canvas.Font.Name := 'Arial';
        Result := Canvas.TextWidth(AFontName);
        Inc(Result, ItemSymbolFontExampleOffset);
        Canvas.Font.Charset := SYMBOL_CHARSET;
      end;
      Canvas.Font.Name := AFontName;
      Inc(Result, Canvas.TextWidth(AFontName));
    finally
      Canvas.Font.Name := ACanvasFontName;
      Canvas.Font.Charset := ACanvasFontCharSet;
    end;
  end
  else
    Result := inherited GetItemWidth(AIndex);
end;

function TcxFontNameComboBoxListBox.GetItem(Index: Integer): string;
begin
  Result := Edit.ActiveProperties.LookupItems[Index];
end;

procedure TcxFontNameComboBoxListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  AItemIndex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button <> mbLeft then
    Exit;
  AItemIndex := ItemAtPos(Point(X, Y), True);
  if AItemIndex <> -1 then
  begin
    SetCaptureControl(nil);
    ItemIndex := AItemIndex;
    Edit.CloseUp(crEnter);
  end;
end;

procedure TcxFontNameComboBoxListBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);

  procedure DrawItemText;
  var
    AFlags: Longint;
    AFontBitmap: TBitmap;
    AText: string;
    ATextRect: TRect;
  begin
    ATextRect := Rect;
    if Index = Edit.ActiveProperties.FMRUFontNames.Count - 1 then
      Dec(ATextRect.Bottom, MRUDelimiterWidth);

    if cxftTTF in Edit.ActiveProperties.ItemTypes[Index] then
      AFontBitmap := FTrueTypeFontBitmap
    else
      AFontBitmap := FNonTrueTypeFontBitmap;
    if (ftiShowInList in Edit.ActiveProperties.ShowFontTypeIcon) and (AFontBitmap <> nil) then
    begin
      Canvas.Draw(ATextRect.Left + IconBorderWidth, ATextRect.Top +
        (ATextRect.Bottom - ATextRect.Top - AFontBitmap.Height) div 2, AFontBitmap);
      Inc(ATextRect.Left, AFontBitmap.Width + IconBorderWidth * 2 + IconTextOffset);
    end
    else
      Inc(ATextRect.Left, DropDownListTextOffset);

    AText := GetItem(Index);
    if Edit.ActiveProperties.UseOwnFont then
      Canvas.Font.Name := AText;
    AFlags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_LEFT or DT_NOPREFIX or DT_VCENTER);
    Canvas.Brush.Style := bsClear;
    if Edit.ActiveProperties.UseOwnFont and IsSymbolFontType(Index) then
    begin
      Canvas.Font.Name := 'Arial';
      DrawText(Canvas.Handle, PChar(AText), Length(AText),
        ATextRect, AFlags);
      Inc(ATextRect.Left, Canvas.TextWidth(AText) + ItemSymbolFontExampleOffset);
      Canvas.Font.Name := AText;
      Canvas.Font.Charset := SYMBOL_CHARSET;
      AFlags := AFlags and not DT_END_ELLIPSIS;
    end;
    DrawText(Canvas.Handle, PChar(AText), Length(AText),
      ATextRect, AFlags);
    Canvas.Brush.Style := bsSolid;
  end;

begin
  SaveCanvasParametersForFocusRect;
  try
    if DoDrawItem(Index, Rect, State) then
      Exit;
    Canvas.FillRect(Rect);
    DrawItemText;
    if Index = Edit.ActiveProperties.FMRUFontNames.Count - 1 then
      DrawMRUDelimiter(Canvas.Canvas, Rect, odSelected in State);
  finally
    RestoreCanvasParametersForFocusRect;
  end;
end;

function TcxFontNameComboBoxListBox.GetEdit: TcxCustomFontNameComboBox;
begin
  Result := TcxCustomFontNameComboBox(inherited Edit);
end;

function TcxFontNameComboBoxListBox.IsSymbolFontType(AItemIndex: Integer): Boolean;
begin
  Result := Integer(Edit.ActiveProperties.Items.Objects[AItemIndex]) and SYMBOL_FONTTYPE <> 0;
end;

{ TcxFontNameComboBoxLookupData }

destructor TcxFontNameComboBoxLookupData.Destroy;
begin
  FPanel := nil;
  inherited Destroy;
end;

function TcxFontNameComboBoxLookupData.CanResizeVisualArea(var NewSize: TSize;
  AMaxHeight: Integer = 0; AMaxWidth: Integer = 0): Boolean;
var
  AFontPreviewPanelHeight: Integer;
begin
  if TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview.Visible then
    AFontPreviewPanelHeight := cxFontPreviewPanelDefaultHeight
  else
    AFontPreviewPanelHeight := 0;
  Result := (AMaxHeight = 0) or (AMaxHeight > AFontPreviewPanelHeight);
  if Result then
  begin
    if AMaxHeight > 0 then
      Dec(AMaxHeight, AFontPreviewPanelHeight);
    NewSize.cy := NewSize.cy - AFontPreviewPanelHeight;
    Result := inherited CanResizeVisualArea(NewSize, AMaxHeight);
    NewSize.cy := NewSize.cy + AFontPreviewPanelHeight;
  end;
end;

function TcxFontNameComboBoxLookupData.GetVisualAreaPreferredSize(AMaxHeight: Integer; AWidth: Integer = 0): TSize;
var
  AScrollWidth, AWidthDelta: Integer;
begin
  Result := inherited GetVisualAreaPreferredSize(AMaxHeight, AWidth);
  if TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview.Visible then
    Result.cy := Result.cy + cxFontPreviewPanelDefaultHeight;
  if (ftiShowInCombo in  TcxCustomFontNameComboBoxProperties(ActiveProperties).ShowFontTypeIcon) then
    AWidthDelta := FTrueTypeFontBitmap.Width + IconBorderWidth * 2 + IconTextOffset
  else
    AWidthDelta := DropDownListTextOffset;
  AScrollWidth := List.ScrollWidth;
  List.ScrollWidth := 0;
  List.ScrollWidth := AScrollWidth + AWidthDelta;
  Result.cx := Result.cx + AWidthDelta;
end;

procedure TcxFontNameComboBoxLookupData.Initialize(AVisualControlsParent: TWinControl);
begin
  inherited Initialize(AVisualControlsParent);
  if TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview.Visible and
    Assigned(AVisualControlsParent) and AVisualControlsParent.HandleAllocated then
  begin
    if not Assigned(FPanel) then
    begin
      FPanel := TFontPreviewPanel.Create(AVisualControlsParent);
      FPanel.FontPreview := TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview;
      FPanel.LookAndFeel.MasterLookAndFeel := TcxCustomFontNameComboBox(Edit).PopupControlsLookAndFeel;
    end;

    FPanel.Locked := True;
    try
      FPanel.Edges := [bBottom];
      FPanel.Caption := GetPreviewText;
      FPanel.FontName := GetFontName;
      FPanel.Height := cxFontPreviewPanelDefaultHeight;
      with TcxCustomFontNameComboBoxProperties(ActiveProperties) do
      begin
        FPanel.FontStyle := FontPreview.FontStyle;
        FPanel.Color := FontPreview.Color;
        FPanel.ShowEndEllipsis := FontPreview.ShowEndEllipsis and
          (FontPreview.PreviewType <> cxfpFontName);
        FPanel.Alignment := FontPreview.Alignment;
        FPanel.WordWrap := FontPreview.WordWrap and (FontPreview.PreviewType <> cxfpFontName);
        FPanel.ShowButtons := FontPreview.ShowButtons;
      end;
      FPanel.Parent := AVisualControlsParent;
      FPanel.Visible := True;
    finally
      FPanel.Locked := False;
    end;
  end
  else
    if Assigned(FPanel) then FPanel.Visible := False;
end;

procedure TcxFontNameComboBoxLookupData.PositionVisualArea(const AClientRect: TRect);
var
  R: TRect;
begin
  inherited PositionVisualArea(AClientRect);
  R := AClientRect;
  if TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview.Visible and
    Assigned(FPanel) and FPanel.HandleAllocated then
  begin
    FPanel.SetBounds(R.Left, R.Top, R.Right - R.Left,
      cxFontPreviewPanelDefaultHeight);
    FPanel.RealignButtons;
    Inc(R.Top, FPanel.Height);
  end;
  List.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
end;

function TcxFontNameComboBoxLookupData.GetListBoxClass: TcxCustomEditListBoxClass;
begin
  Result := TcxFontNameComboBoxListBox;
end;

procedure TcxFontNameComboBoxLookupData.HandleSelectItem(Sender: TObject);
begin
  inherited HandleSelectItem(Sender);
  if Assigned(FPanel) and FPanel.HandleAllocated then
  begin
    FPanel.Locked := True;
    try
      if ItemIndex >= 0 then
        FPanel.FontName := GetFontName;
      with TcxCustomFontNameComboBoxProperties(ActiveProperties) do
        if FontPreview.PreviewType <> cxfpFullAlphabet then
          FPanel.Caption := GetPreviewText;
    finally
      FPanel.Locked := False;
    end;
  end;
end;

procedure TcxFontNameComboBoxLookupData.InternalChangeCurrentMRUFontNamePosition;
var
  FIndex: Integer;
begin
  if ItemIndex > (TcxCustomFontNameComboBoxProperties(ActiveProperties).FMRUFontNames.Count - 1) then
  begin
    FIndex := Items.IndexOf(Items[ItemIndex]);
    if FIndex >= 0 then
      InternalSetCurrentKey(FIndex);
  end;
end;

function TcxFontNameComboBoxLookupData.GetPreviewText: string;
begin
  with TcxCustomFontNameComboBoxProperties(ActiveProperties) do
    case FontPreview.PreviewType of
      cxfpCustom: Result := TcxCustomFontNameComboBoxProperties(ActiveProperties).FontPreview.PreviewText;
      cxfpFullAlphabet: Result := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 1234567890';
      else
        Result := GetFontName;
    end;
end;

function TcxFontNameComboBoxLookupData.GetFontName: string;
begin
  if ItemIndex = -1 then
    Result := ''
  else
    Result := Items[ItemIndex];
end;

{ TcxCustomFontNameComboBoxProperties }

constructor TcxCustomFontNameComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  DropDownListStyle := lsFixedList;
  FMaxMRUFonts := 10;
  FFontTypes := [cxftTTF, cxftRaster, cxftDevice, cxftFixed, cxftSymbol];
  FUseOwnFont := False;
  FShowFontTypeIcon := [ftiShowInCombo, ftiShowInList];
  FMRUFontNames := TcxMRUFontNameItems.Create(Self, TcxMRUFontNameItem);
  FFontPreview := TcxFontPreview.Create(Self);
  FLoadFontComplete := True;
  LoadFontNames;
end;

destructor TcxCustomFontNameComboBoxProperties.Destroy;
begin
  FreeAndNil(FFontPreview);
  FreeAndNil(FMRUFontNames);
  ShutDownFontLoader;
  inherited;
end;

procedure TcxCustomFontNameComboBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomFontNameComboBoxProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomFontNameComboBoxProperties do
      begin
        Self.UseOwnFont := UseOwnFont;
        Self.FontTypes := FontTypes;
        Self.ShowFontTypeIcon := ShowFontTypeIcon;
        Self.FontPreview := FontPreview;
        Self.MaxMRUFonts := MaxMRUFonts;
        Self.OnAddedMRUFont := OnAddedMRUFont;
        Self.OnMovedMRUFont := OnMovedMRUFont;
        Self.OnDeletedMRUFont := OnDeletedMRUFont;
        Self.OnLoadFontComplete := OnLoadFontComplete;
        Self.MRUFontNames.Assign(MRUFontNames);
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomFontNameComboBoxProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
var
  AItemIndex1, AItemIndex2: Integer;
  AText1, AText2: string;
begin
  GetFontNameComboBoxDisplayValue(AEditValue1, AItemIndex1, AText1);
  GetFontNameComboBoxDisplayValue(AEditValue2, AItemIndex2, AText2);
  Result := AItemIndex1 = AItemIndex2;
end;

class function TcxCustomFontNameComboBoxProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxFontNameComboBox;
end;

procedure TcxCustomFontNameComboBoxProperties.GetFontNameComboBoxDisplayValue(
  const AEditValue: TcxEditValue; out AItemIndex: Integer; out AText: string);
begin
  if not LoadFontComplete then
  begin
    AItemIndex := -1;
    AText := cxGetResourceString(@scxLoadingFonts);
  end
  else
  begin
    AItemIndex := FindItemByValue(AEditValue);
    if AItemIndex = -1 then
      AText := ''
    else
      AText := Items[AItemIndex];
  end;
  CheckCharsRegister(AText, CharCase);
end;

function TcxCustomFontNameComboBoxProperties.FindLookupText(
  const AText: string): Boolean;
begin
  Result := not LoadFontComplete or inherited FindLookupText(AText);
end;

class function TcxCustomFontNameComboBoxProperties.GetLookupDataClass: TcxInterfacedPersistentClass;
begin
  Result := TcxFontNameComboBoxLookupData;
end;

class function TcxCustomFontNameComboBoxProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomFontNameComboBoxViewData;
end;

class function TcxCustomFontNameComboBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomFontNameComboBoxViewInfo;
end;

procedure TcxCustomFontNameComboBoxProperties.ShutDownFontLoader;
begin
  if Assigned(FFontLoader) then
  begin
    FFontLoader.OnCompleteThread := nil;
    FFontLoader.OnDestroyThread := nil;
    FFontLoader.Terminate;
    FFontLoader := nil;
  end;
end;

function TcxCustomFontNameComboBoxProperties.GetFontItems: TStrings;
begin
  Result := Items;
end;

function TcxCustomFontNameComboBoxProperties.GetFontTypes: TcxFontTypes;
begin
  Result := FFontTypes;
end;

procedure TcxCustomFontNameComboBoxProperties.SetFontTypes(Value: TcxFontTypes);
begin
  if FFontTypes <> Value then begin
    FFontTypes := Value;
    FMRUFontNames.Clear;
    LoadFontNames;
    Changed;
  end;
end;

procedure TcxCustomFontNameComboBoxProperties.SetMaxMRUFonts(Value: Byte);
var
  FOldMaxMRUFonts: Byte;
begin
  if FMaxMRUFonts <> Value then
  begin
    FOldMaxMRUFonts := FMaxMRUFonts;
    FMaxMRUFonts := Value;
    if FOldMaxMRUFonts > Value then
    begin
      DeleteOverMRUFonts;
      Changed;
    end;
  end;
end;

function TcxCustomFontNameComboBoxProperties.GetUseOwnFont: Boolean;
begin
  Result := FUseOwnFont;
end;

procedure TcxCustomFontNameComboBoxProperties.SetUseOwnFont(Value: Boolean);
begin
  if FUseOwnFont <> Value
  then begin
    FUseOwnFont := Value;
    Changed;
  end;
end;

procedure TcxCustomFontNameComboBoxProperties.SetShowFontTypeIcon(Value: TcxShowFontIconTypes);
begin
  if FShowFontTypeIcon <> Value then
  begin
    FShowFontTypeIcon := Value;
    Changed;
  end;
end;

function TcxCustomFontNameComboBoxProperties.FindItemByValue(const AEditValue: TcxEditValue): Integer;
begin
  if not LoadFontComplete then
    Result := -1
  else
    if IsVarEmpty(AEditValue) then
      Result := -1
    else
      Result := Items.IndexOf(VarToStr(AEditValue));
end;

function TcxCustomFontNameComboBoxProperties.GetItemTypes(Index: Integer): TcxFontTypes;
begin
  Result := RealFontTypeToCxTypes(Integer(Items.Objects[Index]));
end;

procedure TcxCustomFontNameComboBoxProperties.SetFontPreview(Value: TcxFontPreview);
begin
  FontPreview.Assign(Value);
  Changed;
end;

procedure TcxCustomFontNameComboBoxProperties.LoadFontNames;
begin
  { Prepare to ShutDown FontLoader}
  if (not FLoadFontComplete) or (Assigned(FFontLoader)) then
  begin
    if Assigned(FFontLoader) then FFontLoader.OnCompleteThread := nil;
    ShutDownFontLoader;
  end;
  FLoadFontComplete := False;
  FFontLoader := TcxFontLoader.Create(FFontTypes);
  FFontLoader.OnCompleteThread := FontLoaderCompleteHandler;
  FFontLoader.OnDestroyThread := FontLoaderDestroyHandler;
  FFontLoader.Resume;
end;

procedure TcxCustomFontNameComboBoxProperties.Update(AProperties: TcxCustomEditProperties);
begin
  if (AProperties is TcxCustomFontNameComboBoxProperties) and
    FLoadFontComplete then
      with TcxCustomFontNameComboBoxProperties(AProperties) do
      begin
        Items.Assign(Self.Items);
        MRUFontNames.Assign(Self.MRUFontNames);
      end;
end;

procedure TcxCustomFontNameComboBoxProperties.FontLoaderCompleteHandler(Sender: TObject);
begin
  Items.BeginUpdate;
  try
    Items.Clear;
    if Assigned(Sender) then Items.Assign((Sender as TcxFontLoader).FontList);
  finally
    Items.EndUpdate;
  end;
  FLoadFontComplete := True;
  if Assigned(FOnInternalLoadFontComplete) then FOnInternalLoadFontComplete(Self);
  if Assigned(OnLoadFontComplete) then OnLoadFontComplete(Self);
  Changed;
end;

procedure TcxCustomFontNameComboBoxProperties.FontLoaderDestroyHandler(Sender: TObject);
begin
  FFontLoader.OnCompleteThread := nil;
  FFontLoader.OnDestroyThread := nil;
  FFontLoader := nil;
  FLoadFontComplete := True;
end;

function TcxCustomFontNameComboBoxProperties.AddMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
var
  FIndex: Integer;
begin
  Result := mfaNone;
  if MaxMRUFonts = 0 then Exit;
  Result := mfaInvalidFontName;
  FIndex := Items.IndexOf(AFontName);
  if FIndex < 0 then Exit;
  {If this font exists in MRU list, do not add, only move to first position}
  if FMRUFontNames.FindFontName(AFontName) <> nil then
  begin
    if (FIndex > 0) and (FIndex < FMRUFontNames.Count) then
    begin
      Result := mfaMoved;
      Items.Move(FIndex, 0);
      FMRUFontNames.Move(FIndex, 0);
      if Assigned(OnMovedMRUFont) then
        OnMovedMRUFont(Self);
    end
    else
      Result := mfaNone;
  end
  else
    Result := mfaAdded;
  if Result = mfaAdded then
  begin
    FMRUFontNames.InsertMRUFontName(0, AFontName);
    Items.InsertObject(0, AFontName, Items.Objects[FIndex]);
    DeleteOverMRUFonts;
    if Assigned(OnAddedMRUFont) then
      OnAddedMRUFont(Self);
  end;
end;

function TcxCustomFontNameComboBoxProperties.DelMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
var
  FIndex: Integer;
begin
  Result := mfaInvalidFontName;
  {Check for right Font name}
  FIndex := Items.IndexOf(AFontName);
  if FIndex < 0 then Exit;
  if FMRUFontNames.FindFontName(AFontName) <> nil then
  begin
{$IFDEF DELPHI5}
    FMRUFontNames.Delete(FIndex);
{$ELSE}
    TcxMRUFontNameItem(FMRUFontNames.Items[FIndex]).Free;
{$ENDIF}
    Items.Delete(FIndex);
    Result := mfaDeleted;
    if Assigned(OnDeletedMRUFont) then
      OnDeletedMRUFont(Self, AFontName);
  end;
end;

procedure TcxCustomFontNameComboBoxProperties.DeleteOverMRUFonts;
var
  I: Integer;
  FDeletedFontName: string;
begin
  BeginUpdate;
  try
    for I := FMRUFontNames.Count - 1 downto 0 do
    begin
      if I >= FMaxMRUFonts then
      begin
{$IFDEF DELPHI5}
        FMRUFontNames.Delete(I);
{$ELSE}
        TcxMRUFontNameItem(FMRUFontNames.Items[I]).Free;
{$ENDIF}
        FDeletedFontName := Items[I];
        Items.Delete(I);
        if Assigned(OnDeletedMRUFont) then
          OnDeletedMRUFont(Self, FDeletedFontName);
      end
      else Break;
    end;
  finally
    EndUpdate;
  end;
end;

{ TcxCustomFontNameComboBox }

{$IFDEF CBUILDER10}
constructor TcxCustomFontNameComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;
{$ENDIF}

function TcxCustomFontNameComboBox.Deactivate: Boolean;
begin
  Result := inherited Deactivate;
  UpdateMRUList;
end;

class function TcxCustomFontNameComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomFontNameComboBoxProperties;
end;

function TcxCustomFontNameComboBox.GetInnerEditClass: TControlClass;
begin
  Result := TcxCustomFontNameComboBoxInnerEdit;
end;

function TcxCustomFontNameComboBox.GetPopupWindowClientPreferredSize: TSize;
begin
  Result := inherited GetPopupWindowClientPreferredSize;
end;

procedure TcxCustomFontNameComboBox.Initialize;
begin
  inherited Initialize;
  FFontNameQueue := '';
  ControlStyle := ControlStyle - [csClickEvents];
  TcxCustomFontNameComboBoxProperties(FProperties).FOnInternalLoadFontComplete :=
    InternalLoadFontCompleteHandler;
end;

procedure TcxCustomFontNameComboBox.InitializePopupWindow;
begin
  inherited InitializePopupWindow;
  PopupWindow.SysPanelStyle := ActiveProperties.PopupSizeable;
end;

procedure TcxCustomFontNameComboBox.CloseUp(AReason: TcxEditCloseUpReason);
begin
  FNeedsUpdateMRUList := FNeedsUpdateMRUList or (AReason in [crTab, crEnter, crClose]);
  try
    inherited CloseUp(AReason);
  finally
    UpdateMRUList;
  end;
end;

procedure TcxCustomFontNameComboBox.SetItemIndex(Value: Integer);
begin
  if ActiveProperties.LoadFontComplete then
    inherited SetItemIndex(Value);
end;

function TcxCustomFontNameComboBox.AddMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
begin
  Result := ActiveProperties.AddMRUFontName(AFontName);
end;

function TcxCustomFontNameComboBox.DelMRUFontName(const AFontName: TFontName): TcxMRUFontNameAction;
begin
  Result := ActiveProperties.DelMRUFontName(AFontName);
end;

function TcxCustomFontNameComboBox.GetProperties: TcxCustomFontNameComboBoxProperties;
begin
  Result := TcxCustomFontNameComboBoxProperties(FProperties);
end;

function TcxCustomFontNameComboBox.GetActiveProperties: TcxCustomFontNameComboBoxProperties;
begin
  Result := TcxCustomFontNameComboBoxProperties(InternalGetActiveProperties);
end;

function TcxCustomFontNameComboBox.GetFontName: string;
begin
  Result := FFontNameQueue;
  if (Result = '') and (ItemIndex <> -1) then
    Result := ActiveProperties.Items[ItemIndex];
end;

procedure TcxCustomFontNameComboBox.SetFontName(Value: string);
begin
  if Value = '' then
  begin
    FFontNameQueue := '';
    ItemIndex := -1;
  end
  else
  begin
    if not ActiveProperties.LoadFontComplete then
      FFontNameQueue := Value
    else
      ItemIndex := ActiveProperties.Items.IndexOf(Value);
  end;
end;

function TcxCustomFontNameComboBox.GetLookupData: TcxFontNameComboBoxLookupData;
begin
  Result := TcxFontNameComboBoxLookupData(FLookupData);
end;

procedure TcxCustomFontNameComboBox.SetProperties(Value: TcxCustomFontNameComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomFontNameComboBox.InternalLoadFontCompleteHandler(Sender: TObject);
var
  FLocalFontName: string;
begin
  if FFontNameQueue <> '' then
  begin
    SetFontName(FFontNameQueue);
    FFontNameQueue := '';
  end
  else
  begin
    if IsVarEmpty(FEditValue) then
      FLocalFontName := ''
    else
      FLocalFontName := VarToStr(FEditValue);
    LookupData.InternalSetCurrentKey(ActiveProperties.Items.IndexOf(FLocalFontName));
  end;
end;

procedure TcxCustomFontNameComboBox.UpdateMRUList;
var
  AFontName: TFontName;
  AFontNameIndex: Integer;
begin
  try
    if FNeedsUpdateMRUList and (FDontCheckModifiedWhenUpdatingMRUList or ModifiedAfterEnter) then
    begin
      AFontNameIndex := ActiveProperties.Items.IndexOf(Text);
      if AFontNameIndex = -1 then
        AFontName := Text
      else
        AFontName := ActiveProperties.Items[AFontNameIndex];
      if AddMRUFontName(AFontName) in [mfaNone, mfaMoved] then
        LookupData.InternalChangeCurrentMRUFontNamePosition;
    end;
  finally
    FDontCheckModifiedWhenUpdatingMRUList := False;
    FNeedsUpdateMRUList := False;
  end;
end;
  
procedure TcxCustomFontNameComboBox.AfterPosting;
begin
  inherited AfterPosting;
  if IsInplace and FNeedsUpdateMRUList then
    FDontCheckModifiedWhenUpdatingMRUList := True;
end;

procedure TcxCustomFontNameComboBox.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
begin
  if IsDestroying then
    Exit;
  inherited;
end;

{ TcxFontNameComboBox }

class function TcxFontNameComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxFontNameComboBoxProperties;
end;

function TcxFontNameComboBox.GetActiveProperties: TcxFontNameComboBoxProperties;
begin
  Result := TcxFontNameComboBoxProperties(InternalGetActiveProperties);
end;

function TcxFontNameComboBox.GetProperties: TcxFontNameComboBoxProperties;
begin
  Result := TcxFontNameComboBoxProperties(FProperties);
end;

procedure TcxFontNameComboBox.SetProperties(
  Value: TcxFontNameComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterFontNameComboBoxHelper }

class function TcxFilterFontNameComboBoxHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxFontNameComboBox;
end;

class function TcxFilterFontNameComboBoxHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties; AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then
    Result := Result + [fcoInList, fcoNotInList];
end;

initialization
  GetRegisteredEditProperties.Register(TcxFontNameComboBoxProperties, scxSEditRepositoryFontNameComboBoxItem);
  FTrueTypeFontBitmap := TBitmap.Create;
  FTrueTypeFontBitmap.LoadFromResourceName(HInstance, 'CXFONTCOMBO_TTF');
  FTrueTypeFontBitmap.Transparent := True;
  FNonTrueTypeFontBitmap := TBitmap.Create;
  FNonTrueTypeFontBitmap.LoadFromResourceName(HInstance, 'CXFONTCOMBO_NONTTF');
  FNonTrueTypeFontBitmap.Transparent := True;
  FilterEditsController.Register(TcxFontNameComboBoxProperties, TcxFilterFontNameComboBoxHelper);

finalization
  FilterEditsController.Unregister(TcxFontNameComboBoxProperties, TcxFilterFontNameComboBoxHelper);
  GetRegisteredEditProperties.Unregister(TcxFontNameComboBoxProperties);
  FreeAndNil(FNonTrueTypeFontBitmap);
  FreeAndNil(FTrueTypeFontBitmap);

end.
