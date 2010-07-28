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

unit cxEdit;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Forms, ComCtrls, Classes, Controls, Graphics, Menus, StdCtrls, SysUtils,
  cxClasses, cxContainer, cxControls, cxDataStorage, cxDataUtils,
  cxEditPaintUtils, cxGraphics, cxLookAndFeels, cxVariants, cxLookAndFeelPainters, dxCore;

type
  TcxBlobKind = (bkNone, bkBlob, bkGraphic, bkMemo, bkOle);
  TcxEditBorderStyle = (ebsNone, ebsSingle, ebsThick, ebsFlat, ebs3D,
    ebsUltraFlat, ebsOffice11);
  TcxEditButtonKind = (bkEllipsis, bkDown, bkGlyph, bkText);
  TcxEditButtonState = (ebsDisabled, ebsNormal, ebsPressed, ebsSelected);
  TcxEditButtonStyle = (btsDefault, bts3D, btsFlat, btsSimple, btsHotFlat,
    btsUltraFlat, btsOffice11);
  TcxEditButtonsViewStyle = (bvsNormal, bvsButtonsOnly, bvsButtonsAutoWidth);
  TcxEditButtonTransparency = (ebtNone, ebtInactive, ebtAlways, ebtHideInactive,
    ebtHideUnselected);
  TcxEditGradientDirection = dirLeft..dirDown;
  TcxEditPopupBorderStyle = (epbsDefault, epbsSingle, epbsFrame3D, epbsFlat);

  TcxEditStyleValue = TcxContainerStyleValue;
  TcxEditStyleValues = TcxContainerStyleValues;

  TcxEditHorzAlignment = TAlignment;
  TcxEditVertAlignment = (taTopJustify, taBottomJustify, taVCenter);

const
  cxEditDefaultPrecision = 15;
  cxEditDefaultUseLeftAlignmentOnEditing = True;
  cxEditDefaultHorzAlignment: TcxEditHorzAlignment = taLeftJustify;
  cxEditDefaultVertAlignment: TcxEditVertAlignment = taTopJustify;
  cxInplaceEditOffset = 1;

  ekDefault = 0;

  svBorderColor        = csvBorderColor;
  svBorderStyle        = csvBorderStyle;
  svColor              = csvColor;
  svEdges              = csvEdges;
  svFont               = csvFont;
  svHotTrack           = csvHotTrack;
  svShadow             = csvShadow;
  svTextColor          = csvTextColor;
  svTextStyle          = csvTextStyle;
  svTransparentBorder  = csvTransparentBorder;
  svButtonStyle        = cxContainerStyleValueCount;
  svButtonTransparency = cxContainerStyleValueCount + 1;
  svPopupBorderStyle   = cxContainerStyleValueCount + 2;
  svGradientButtons    = cxContainerStyleValueCount + 3;
  svGradient           = cxContainerStyleValueCount + 4;
  svGradientDirection  = cxContainerStyleValueCount + 5;

  cxEditStyleValueCount = cxContainerStyleValueCount + 6;

  cxEditStyleValueNameA: array[0..cxEditStyleValueCount - cxContainerStyleValueCount - 1] of string = (
    'ButtonStyle',
    'ButtonTransparency',
    'PopupBorderStyle',
    'GradientButtons',
    'Gradient',
    'GradientDirection'
  );

  EditContentDefaultOffsets: array [Boolean] of TRect = (
    (Left: 1; Top: 1; Right: 1; Bottom: 3),
    (Left: 1; Top: 1; Right: 1; Bottom: 1)
  );

  EditBtnState2ButtonState: array[TcxEditButtonState] of TcxButtonState =
      (cxbsDisabled, cxbsNormal, cxbsPressed, cxbsHot);

  ecpNone = -2;
  ecpControl = -1;
  ecpButton = 0;

type
  TcxEditDisplayFormatOption = (dfoSupports, dfoNoCurrencyValue);
  TcxEditDisplayFormatOptions = set of TcxEditDisplayFormatOption;
  TcxEditBackgroundPaintingStyle = (bpsSolid, bpsComboEdit, bpsComboListEdit);
  TcxEditEditingStyle = (esEdit, esEditList, esFixedList, esNoEdit);
  TcxEditPaintOption = (epoAllowZeroHeight, epoAutoHeight, epoHasExternalBorder,
    epoShowEndEllipsis, epoShowFocusRectWhenInplace);
  TcxEditPaintOptions = set of TcxEditPaintOption;
  TcxEditSpecialFeatures = set of (esfBlobEditValue, esfMinSize,
    esfNoContentPart);
  TcxEditSupportedOperation = (esoAlwaysHotTrack, esoAutoHeight, esoEditing,
    esoFiltering, esoHorzAlignment, esoHotTrack, esoIncSearch,
    esoShowingCaption, esoSorting, esoSortingByDisplayText, esoTransparency);
  TcxEditSupportedOperations = set of TcxEditSupportedOperation;
  TcxEditValue = Variant;
  PcxEditValue = ^TcxEditValue;
  TcxEditValidateEvent = procedure(Sender: TObject; var DisplayValue: TcxEditValue;
    var ErrorText: TCaption; var Error: Boolean) of object;
  TcxEditErrorKind = Integer;
  TcxCustomEdit = class;
  TcxCustomEditStyle = class;

  EcxEditError = class(EdxException);
  EcxEditValidationError = class(EcxEditError);

  { IcxCustomInnerEdit }

  IcxCustomInnerEdit = interface(IcxContainerInnerControl)
  ['{468D21B5-48AA-4077-8ED5-4C6112D460B1}']
    function CallDefWndProc(AMsg: UINT; WParam: WPARAM;
      LParam: LPARAM): LRESULT;
    function GetEditValue: TcxEditValue;
    function GetOnChange: TNotifyEvent;
    function GetReadOnly: Boolean;
    procedure LockBounds(ALock: Boolean);
    procedure SafelySetFocus;
    procedure SetEditValue(const Value: TcxEditValue);
    procedure SetParent(Value: TWinControl);
    procedure SetOnChange(Value: TNotifyEvent);
    procedure SetReadOnly(Value: Boolean);
    property EditValue: TcxEditValue read GetEditValue write SetEditValue;
    property Parent: TWinControl write SetParent;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
  end;

  IcxInnerEditHelper = interface
  ['{35667555-6DC8-40D5-B705-B08D5697C621}']
    function GetHelper: IcxCustomInnerEdit;
  end;

  TcxCustomEditProperties = class;
  TcxCustomEditPropertiesClass = class of TcxCustomEditProperties;
  TcxEditRepository = class;
  TcxEditRepositoryItem = class;

  { IcxEditRepositoryItemListener }

  IcxEditRepositoryItemListener = interface
    ['{4E27D642-022B-4CD2-AB96-64C7CF9B3299}']
    procedure ItemRemoved(Sender: TcxEditRepositoryItem);
    procedure PropertiesChanged(Sender: TcxEditRepositoryItem);
  end;

  { TcxEditRepositoryItem }

  TcxEditRepositoryItem = class(TComponent)
  private
    FListenerList: IInterfaceList;
    FProperties: TcxCustomEditProperties;
    FPropertiesEvents: TNotifyEvent;
    FRepository: TcxEditRepository;
    procedure SetProperties(Value: TcxCustomEditProperties);
    procedure SetRepository(Value: TcxEditRepository);
  protected
    procedure PropertiesChanged(Sender: TObject); virtual;
    procedure ReadState(Reader: TReader); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddListener(AListener: IcxEditRepositoryItemListener); virtual;
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; virtual;
    function GetBaseName: string; virtual;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure RemoveListener(AListener: IcxEditRepositoryItemListener); virtual;
    procedure SetParentComponent(AParent: TComponent); override;
    property Properties: TcxCustomEditProperties read FProperties
      write SetProperties;
    property Repository: TcxEditRepository read FRepository write SetRepository;
  published
    property PropertiesEvents: TNotifyEvent read FPropertiesEvents
      write FPropertiesEvents;
  end;

  TcxEditRepositoryItemClass = class of TcxEditRepositoryItem;

  IcxEditDefaultValuesProvider = interface
    ['{AE727882-6FDF-4E3A-AB35-E58AB28EFE7B}']
    function CanSetEditMode: Boolean;
    procedure ClearUsers;
    function DefaultAlignment: TAlignment;
    function DefaultBlobKind: TcxBlobKind;
    function DefaultCanModify: Boolean;
    function DefaultDisplayFormat: string;
    function DefaultEditFormat: string;
    function DefaultEditMask: string;
    function DefaultIsFloatValue: Boolean;
    function DefaultMaxLength: Integer;
    function DefaultMaxValue: Double;
    function DefaultMinValue: Double;
    function DefaultPrecision: Integer;
    function DefaultReadOnly: Boolean;
    function DefaultRequired: Boolean;
    function GetInstance: TObject;
    function IsDataStorage: Boolean;
    function IsBlob: Boolean;
    function IsCurrency: Boolean;
    function IsDataAvailable: Boolean;
    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean;
    function IsOnGetTextAssigned: Boolean;
    function IsOnSetTextAssigned: Boolean;
    function IsValidChar(AChar: Char): Boolean;
  end;

  { TcxEditRepository }

  TcxEditRepository = class(TComponent)
  private
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxEditRepositoryItem;
  protected
    procedure AddItem(AItem: TcxEditRepositoryItem);
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure RemoveItem(AItem: TcxEditRepositoryItem);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function CreateItem(ARepositoryItemClass: TcxEditRepositoryItemClass): TcxEditRepositoryItem; virtual;
    function CreateItemEx(ARepositoryItemClass: TcxEditRepositoryItemClass; AOwner: TComponent): TcxEditRepositoryItem; virtual;
    function ItemByName(ARepositoryItemName: string): TcxEditRepositoryItem;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TcxEditRepositoryItem read GetItem; default;
  end;

  { TcxEditButtonViewInfo }

  TcxEditButtonViewInfoData = record
    BackgroundColor: TColor;
    Caption: string;
    ContentAlignment: TAlignment;
    Default: Boolean;
    Gradient: Boolean;
    IsInplace: Boolean;
    Kind: TcxEditButtonKind;
    LeftAlignment: Boolean;
    Leftmost: Boolean;
    NativeStyle: Boolean;
    Rightmost: Boolean;
    State: TcxEditButtonState;
    Style: TcxEditButtonStyle;
    TextColor: TColor;
    Transparent: Boolean;
    VisibleCaption: string;
    BackgroundPartiallyTransparent: Boolean;
    ComboBoxStyle: Boolean;
    NativePart: Integer;
    NativeState: Integer;
  end;
  PcxEditButtonViewInfoData = ^TcxEditButtonViewInfoData;

  TcxEditButtonViewInfo = class(TPersistent)
  public
    Bounds: TRect;
    Data: TcxEditButtonViewInfoData;
    Glyph: TBitmap;
    HasBackground: Boolean;
    Index: Integer;
    Stretchable: Boolean;
    VisibleBounds: TRect;
    Width: Integer;
    procedure Assign(Source: TPersistent); override;
    function GetUpdateRegion(AViewInfo: TcxEditButtonViewInfo): TcxRegion; virtual;
    function Repaint(AControl: TWinControl; AViewInfo: TcxEditButtonViewInfo;
      const AEditPosition: TPoint): Boolean; virtual;
  end;

  TcxEditButtonViewInfoClass = class of TcxEditButtonViewInfo;

  { TcxEditButton }

  TcxEditButton = class(TCollectionItem)
  private
    FCaption: TCaption;
    FContentAlignment: TAlignment;
    FDefault: Boolean;
    FEnabled: Boolean;
    FGlyph: TBitmap;
    FHint: string;
    FKind: TcxEditButtonKind;
    FLeftAlignment: Boolean;
    FStretchable: Boolean;
    FTag: TcxTag;
    FTextColor: TColor;
    FVisible: Boolean;
    FVisibleCaption: TCaption;
    FWidth: Integer;
    function GetGlyph: TBitmap;
    procedure GlyphChanged(Sender: TObject);
    function IsTagStored: Boolean;
    procedure SetCaption(const Value: TCaption);
    procedure SetContentAlignment(Value: TAlignment);
    procedure SetDefault(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetGlyph(Value: TBitmap);
    procedure SetKind(Value: TcxEditButtonKind);
    procedure SetLeftAlignment(Value: Boolean);
    procedure SetStretchable(Value: Boolean);
    procedure SetTextColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
    procedure SetWidth(Value: Integer);
  protected
    property TextColor: TColor read FTextColor write SetTextColor default clBtnText; // TODO published
    property VisibleCaption: TCaption read FVisibleCaption;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property ContentAlignment: TAlignment read FContentAlignment
      write SetContentAlignment default taCenter;
    property Default: Boolean read FDefault write SetDefault default False;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property Hint: string read FHint write FHint;
    property Kind: TcxEditButtonKind read FKind write SetKind default bkDown;
    property LeftAlignment: Boolean read FLeftAlignment write SetLeftAlignment default False;
    property Stretchable: Boolean read FStretchable write SetStretchable default True;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  TcxEditButtonClass = class of TcxEditButton;

  { TcxEditButtons }

  TcxEditButtons = class(TCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TcxEditButton;
    function GetVisibleCount: Integer;
    procedure SetItem(Index: Integer; Value: TcxEditButton);
  protected
    class function GetButtonClass: TcxEditButtonClass; virtual;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AOwner: TPersistent; AButtonClass: TcxEditButtonClass); virtual;
    function Add: TcxEditButton;
    property Items[Index: Integer]: TcxEditButton read GetItem write SetItem; default;
    property VisibleCount: Integer read GetVisibleCount;
  end;

  TcxEditButtonsClass = class of TcxEditButtons;

  { TcxCustomEditViewInfo }

  TcxCustomEditViewInfo = class;
  TcxEditAlignment = class;

  TcxEditDrawBackgroundEvent = procedure(Sender: TcxCustomEditViewInfo;
    ACanvas: TcxCanvas; var AHandled: Boolean) of object;
  TcxEditDrawButtonEvent = procedure(Sender: TcxCustomEditViewInfo;
    ACanvas: TcxCanvas; AButtonVisibleIndex: Integer; var AHandled: Boolean) of object;
  TcxEditDrawButtonBackgroundEvent = procedure(Sender: TcxCustomEditViewInfo;
    ACanvas: TcxCanvas; const ARect: TRect; AButtonVisibleIndex: Integer;
    var AHandled: Boolean) of object;
  TcxEditDrawButtonBorderEvent = procedure(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
    out ABackgroundRect, AContentRect: TRect; var AHandled: Boolean) of object;
  TcxEditGetButtonStateEvent = procedure(Sender: TcxCustomEditViewInfo;
    AButtonVisibleIndex: Integer; var AState: TcxEditButtonState) of object;
  TcxEditPaintEvent = procedure(Sender: TcxCustomEditViewInfo; ACanvas: TcxCanvas) of object;

  TcxDrawBackgroundStyle = (dbsCustom, dbsCustomEdit, dbsNone, dbsSimpleFill, dbsSimpleParent, dbsThemeParent);
  TcxEditViewInfoState = (evsPaintButtons);
  TcxEditViewInfoStates = set of TcxEditViewInfoState;

  TcxCustomEditViewInfo = class(TcxContainerViewInfo)
  private
    FOnDrawBackground: TcxEditDrawBackgroundEvent;
    FOnDrawButton: TcxEditDrawButtonEvent;
    FOnDrawButtonBackground: TcxEditDrawButtonBackgroundEvent;
    FOnDrawButtonBorder: TcxEditDrawButtonBorderEvent;
    FOnGetButtonState: TcxEditGetButtonStateEvent;
    FOnPaint: TcxEditPaintEvent;
    function DoDrawBackground(ACanvas: TcxCanvas): Boolean;
    function DoDrawButton(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer): Boolean;
    function DoDrawButtonBackground(ACanvas: TcxCanvas; const ARect: TRect; AButtonVisibleIndex: Integer): Boolean;
    function DoDrawButtonBorder(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
      out ABackgroundRect, AContentRect: TRect): Boolean;
    function GetDrawBackgroundStyle: TcxDrawBackgroundStyle;
    function IsNativeBackground: Boolean;
    function IsTransparent: Boolean;

    function GetHintText(APart: Integer): string;
    function GetHintTextRect(const P: TPoint; APart: Integer): TRect;
  protected
    FEdit: TcxCustomEdit;
    FState: TcxEditViewInfoStates;
    function GetButtonViewInfoClass: TcxEditButtonViewInfoClass; virtual;
    procedure GetColorSettingsByPainter(out ABackground, ATextColor: TColor); virtual;
    function GetContainerBorderStyle: TcxContainerBorderStyle; override;
    function GetPart(const P: TPoint): Integer; virtual;
    function GetPartRect(APart: Integer): TRect; virtual;
    procedure InternalPaint(ACanvas: TcxCanvas); override;
    function IsRepaintOnStateChangingNeeded: Boolean; virtual;
    procedure DrawEditButton(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer); virtual;
    procedure SetOnDrawBackground(AValue: TcxEditDrawBackgroundEvent); virtual;

    procedure Draw3DButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawHotFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawNativeButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawSimpleButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawUltraFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
      AIsOffice11Style: Boolean; var ARect: TRect; var AContentRect: TRect; out APenColor, ABrushColor: TColor); virtual;

    procedure DrawButtonBorderByPainter(AButtonViewInfo: TcxEditButtonViewInfo; var ARect: TRect; out AContentRect: TRect;
      var APenColor, ABrushColor: TColor);
    procedure DrawNativeButtonBackground(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo; const ARect: TRect); virtual;
    procedure DrawUsualButtonBackground(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo; const ARect: TRect; ABrushColor: TColor); virtual;
  public
    BorderExtent: TRect;
    BorderStyle: TcxEditBorderStyle;
    ButtonsInfo: array of TcxEditButtonViewInfo;
    Calculated: Boolean;
    Data: Integer;
    EditProperties: TcxCustomEditProperties;
    Enabled: Boolean;
    Focused: Boolean;
    Font: TFont;
    HasBackground: Boolean;
    HasContentOffsets: Boolean;
    HasInnerEdit: Boolean;
    HasTextButtons: Boolean;
    HitTestInfo: Integer;
    HotState: TcxContainerHotState;
    InnerEditRect: TRect;
    IsButtonReallyPressed: Boolean;
    IsContainerInnerControl: Boolean;
    IsDBEditPaintCopyDrawing: Boolean;
    IsDesigning: Boolean;
    IsInplace: Boolean;
    IsSelected: Boolean;
    Left: Integer;
    PaintOptions: TcxEditPaintOptions;
    PopupBorderStyle: TcxEditPopupBorderStyle;
    PressedButton: Integer;
    SelectedButton: Integer;
    ShadowRect: TRect;
    TextColor: TColor;
    Top: Integer;
    Transparent: Boolean;
    WindowHandle: HWND;
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TObject); override;
    function GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion; override;
    procedure Offset(DX, DY: Integer); override;
    function DrawBackground(ACanvas: TcxCanvas): Boolean; overload;
    function DrawBackground(ACanvas: TcxCanvas; const APos: TPoint): Boolean; overload;
    procedure DrawButton(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer); virtual;
    procedure DrawButtons(ACanvas: TcxCanvas);
    procedure DrawEditBackground(ACanvas: TcxCanvas; ARect, AGlyphRect: TRect; AGlyphTransparent: Boolean);
    procedure DrawNativeStyleEditBackground(ACanvas: TcxCanvas; ADrawBackground: Boolean;
      ABackgroundStyle: TcxEditBackgroundPaintingStyle; ABackgroundBrush: TBrushHandle); virtual;
    function IsBackgroundTransparent: Boolean;

    procedure DrawButtonBackground(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
      const ARect: TRect; ABrushColor: TColor);
    procedure DrawButtonBorder(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
      var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor); virtual;
    procedure DrawButtonContent(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
      const AContentRect: TRect; APenColor, ABrushColor: TColor; ANeedOffsetContent: Boolean); virtual;

    function IsCustomBackground: Boolean;
    function IsCustomButton(AButtonVisibleIndex: Integer = 0): Boolean;
    function IsCustomButtonBackground(AButtonVisibleIndex: Integer = 0): Boolean;
    function IsCustomButtonBorder(AButtonVisibleIndex: Integer = 0): Boolean;
    function IsCustomDrawButton(AButtonVisibleIndex: Integer = 0): Boolean;

    function IsHotTrack: Boolean; overload; virtual;
    function IsHotTrack(P: TPoint): Boolean; overload; virtual;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint;
      out AText: TCaption; out AIsMultiLine: Boolean;
      out ATextRect: TRect): Boolean; overload; virtual;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint;
      const AVisibleBounds: TRect; out AText: TCaption;
      out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean; overload; virtual;
    procedure Paint(ACanvas: TcxCanvas); override;
    procedure PaintEx(ACanvas: TcxCanvas);
    procedure PrepareCanvasFont(ACanvas: TCanvas); virtual;
    function Repaint(AControl: TWinControl;
      AViewInfo: TcxContainerViewInfo = nil): Boolean; overload; virtual;
    function Repaint(AControl: TWinControl; const AInnerEditRect: TRect;
      AViewInfo: TcxContainerViewInfo = nil): Boolean; overload; virtual;
    procedure SetButtonCount(ACount: Integer);
    property Edit: TcxCustomEdit read FEdit;
    property OnDrawBackground: TcxEditDrawBackgroundEvent read FOnDrawBackground
      write SetOnDrawBackground;
    property OnDrawButton: TcxEditDrawButtonEvent read FOnDrawButton
      write FOnDrawButton;
    property OnDrawButtonBackground: TcxEditDrawButtonBackgroundEvent
      read FOnDrawButtonBackground write FOnDrawButtonBackground;
    property OnDrawButtonBorder: TcxEditDrawButtonBorderEvent
      read FOnDrawButtonBorder write FOnDrawButtonBorder;
    property OnGetButtonState: TcxEditGetButtonStateEvent
      read FOnGetButtonState write FOnGetButtonState;
    property OnPaint: TcxEditPaintEvent read FOnPaint write FOnPaint;
  end;

  { TcxCustomEditViewData }

  TcxInplaceEditPosition = record
    Item: TObject;
    RecordIndex: Integer;
  end;

  TcxInplaceEditParams = record
    MultiRowParent: Boolean;
    Position: TcxInplaceEditPosition;
  end;

  TcxEditSizeProperties = record
    Height: Integer;
    MaxLineCount: Integer;
    Width: Integer;
  end;
  PcxEditSizeProperties = ^TcxEditSizeProperties;

  TcxEditContentOption = (ecoShowFocusRectWhenInplace, ecoOffsetButtonContent);
  TcxEditContentOptions = set of TcxEditContentOption;

  TcxEditContentParams = record
    ExternalBorderBounds: TRect;
    Offsets: TRect;
    Options: TcxEditContentOptions;
    SizeCorrection: TSize;
  end;

  TcxCustomEditViewData = class;

  TcxEditGetDefaultButtonWidthEvent = procedure(Sender: TcxCustomEditViewData;
    AIndex: Integer; var ADefaultWidth: Integer) of object;
  TcxEditViewDataGetDisplayTextEvent = procedure(Sender: TcxCustomEditViewData;
    var AText: string) of object;

  TcxCustomEditViewData = class(TPersistent)
  private
    FData: TObject; // internal for OnGetDisplayText event
    FIsInplace: Boolean;
    FLeftSideLeftmostButtonIndex, FLeftSideRightmostButtonIndex: Integer;
    FRightSideLeftmostButtonIndex, FRightSideRightmostButtonIndex: Integer;
    FOnGetDefaultButtonWidth: TcxEditGetDefaultButtonWidthEvent;
    FOnGetDisplayText: TcxEditViewDataGetDisplayTextEvent;
    procedure DoGetButtonState(AViewInfo: TcxCustomEditViewInfo;
      AButtonVisibleIndex: Integer; var AState: TcxEditButtonState);
    function DoGetDefaultButtonWidth(AIndex: Integer): Integer;
    function GetPaintOptions: TcxEditPaintOptions;
    function GetStyle: TcxCustomEditStyle;
    procedure SetStyle(Value: TcxCustomEditStyle);
  protected
    FEdit: TcxCustomEdit;
    FProperties: TcxCustomEditProperties;
    FStyle: TcxCustomEditStyle;
    procedure CalculateButtonNativeInfo(AButtonViewInfo: TcxEditButtonViewInfo); virtual;
    procedure CalculateViewInfo(AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
    function CanPressButton(AViewInfo: TcxCustomEditViewInfo; AButtonVisibleIndex: Integer):
      Boolean; virtual;
    procedure CheckSizeConstraints(var AEditSize: TSize);
    procedure CorrectBorderStyle(var ABorderStyle: TcxEditBorderStyle);
    procedure DoOnGetDisplayText(var AText: string);
    function EditValueToDisplayText(AEditValue: TcxEditValue): string;
    function GetButtonsStyle: TcxEditButtonStyle;
    function GetCaptureButtonVisibleIndex: Integer;
    procedure GetColorSettings(AViewInfo: TcxCustomEditViewInfo; var FillColor, TextColor: TColor);
    function GetContainerState(const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): TcxContainerState; virtual;
    function GetEditContentDefaultOffsets: TRect; virtual;
    function GetEditNativeState(AViewInfo: TcxCustomEditViewInfo): Integer; virtual;
    function HasThickBorders: Boolean; virtual;
    procedure InitCacheData; virtual;
    procedure InitEditContentParams(var AParams: TcxEditContentParams); virtual;
    procedure Initialize; virtual;
    function InternalEditValueToDisplayText(AEditValue: TcxEditValue): string; virtual;
    function InternalFocused: Boolean;
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
      AViewInfo: TcxCustomEditViewInfo): TSize; virtual;
    function InternalGetEditContentSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; virtual;
    function IsButtonPressed(AViewInfo: TcxCustomEditViewInfo;
      AButtonVisibleIndex: Integer): Boolean; virtual;
  public
    AutoHeight: Boolean;
    Bounds: TRect;
    ButtonsOnlyStyle: Boolean;
    ButtonVisibleCount: Integer;
    ContainerState: TcxContainerState;
    ContentOffset: TRect;
    EditContentParams: TcxEditContentParams;
    Enabled: Boolean;
    Focused: Boolean;
    HorzAlignment: TcxEditHorzAlignment;
    HScrollBar: TcxControlScrollBar;
    InnerEdit: IcxCustomInnerEdit;
    InplaceEditParams: TcxInplaceEditParams;
    IsDesigning: Boolean;
    IsSelected: Boolean; // Row selected
    IsValueSource: Boolean;
    MaxLineCount: Integer;
    NativeStyle: Boolean;
    PaintOptions: TcxEditPaintOptions;
    PreviewMode: Boolean;
    Selected: Boolean;
    SelStart, SelLength: Integer;
    SelTextColor, SelBackgroundColor: TColor;
    VertAlignment: TcxEditVertAlignment;
    VScrollBar: TcxControlScrollBar;
    WindowHandle: HWND;
    constructor Create(AProperties: TcxCustomEditProperties; AStyle: TcxCustomEditStyle;
      AIsInplace: Boolean); reintroduce; virtual;
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); virtual;
    procedure CalculateButtonBounds(ACanvas: TcxCanvas; AViewInfo: TcxCustomEditViewInfo;
      AButtonVisibleIndex: Integer; var ButtonsRect: TRect); virtual;
    procedure CalculateButtonsViewInfo(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); virtual;
    procedure CalculateButtonViewInfo(ACanvas: TcxCanvas; AViewInfo: TcxCustomEditViewInfo;
      AButtonVisibleIndex: Integer; var ButtonsRect: TRect); virtual;
    procedure CalculateEx(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean);
    procedure CheckButtonsOnly(AViewInfo: TcxCustomEditViewInfo;
      APrevButtonsWidth, AButtonsWidth: Integer); virtual;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); virtual;
    function GetBorderColor: TColor; virtual;
    function GetBorderExtent: TRect; virtual;
    function GetBorderExtentByEdges(ABorderWidth: Integer): TRect; virtual;
    function GetBorderExtentByPainter: TRect; virtual;
    function GetBorderStyle: TcxEditBorderStyle; virtual;
    function GetButtonsExtent(ACanvas: TcxCanvas): TRect; virtual;
    function GetClientExtent(ACanvas: TcxCanvas;
      AViewInfo: TcxCustomEditViewInfo): TRect; virtual;
    function GetEditConstantPartSize(ACanvas: TcxCanvas;
      const AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
      AViewInfo: TcxCustomEditViewInfo = nil): TSize; virtual;
    function GetEditContentSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; virtual;
    function GetEditContentSizeCorrection: TSize; virtual;
    function GetEditSize(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AEditSizeProperties: TcxEditSizeProperties;
      AViewInfo: TcxCustomEditViewInfo = nil): TSize;
    function HasShadow: Boolean; virtual;
    function IgnoreButtonWhileStretching(
      AButtonVisibleIndex: Integer): Boolean; virtual;
    class function IsNativeStyle(ALookAndFeel: TcxLookAndFeel): Boolean; virtual;
    property Data: TObject read FData write FData;
    property Edit: TcxCustomEdit read FEdit write FEdit;
    property IsInplace: Boolean read FIsInplace;
    property Properties: TcxCustomEditProperties read FProperties;
    property Style: TcxCustomEditStyle read GetStyle write SetStyle;
    property OnGetDefaultButtonWidth: TcxEditGetDefaultButtonWidthEvent
      read FOnGetDefaultButtonWidth write FOnGetDefaultButtonWidth;
    property OnGetDisplayText: TcxEditViewDataGetDisplayTextEvent
      read FOnGetDisplayText write FOnGetDisplayText;
  end;

  TcxCustomEditViewDataClass = class of TcxCustomEditViewData;

  { TcxEditStyleController }

  TcxEditStyle = class;

  TcxEditStyleController = class(TcxStyleController)
  private
    function GetInternalStyle(AState: TcxContainerStateItem): TcxCustomEditStyle;
    function GetStyle: TcxEditStyle;
    function GetStyleDisabled: TcxEditStyle;
    function GetStyleFocused: TcxEditStyle;
    function GetStyleHot: TcxEditStyle;
    procedure SetInternalStyle(AState: TcxContainerStateItem; Value: TcxCustomEditStyle);
    procedure SetStyle(Value: TcxEditStyle);
    procedure SetStyleDisabled(Value: TcxEditStyle);
    procedure SetStyleFocused(Value: TcxEditStyle);
    procedure SetStyleHot(Value: TcxEditStyle);
  protected
    function GetStyleClass: TcxContainerStyleClass; override;
  public
    property Styles[AState: TcxContainerStateItem]: TcxCustomEditStyle
      read GetInternalStyle write SetInternalStyle;
  published
    property Style: TcxEditStyle read GetStyle write SetStyle;
    property StyleDisabled: TcxEditStyle read GetStyleDisabled
      write SetStyleDisabled;
    property StyleFocused: TcxEditStyle read GetStyleFocused
      write SetStyleFocused;
    property StyleHot: TcxEditStyle read GetStyleHot write SetStyleHot;
    property OnStyleChanged;
  end;

  { TcxCustomEditStyle }

  TcxCustomEditStyle = class(TcxContainerStyle)
  private
    FButtonStyle: TcxEditButtonStyle;
    FButtonTransparency: TcxEditButtonTransparency;
    FGradient: Boolean;
    FGradientButtons: Boolean;
    FGradientDirection: TcxEditGradientDirection;
    FPopupBorderStyle: TcxEditPopupBorderStyle;
    FPopupCloseButton: Boolean;

    function GetActiveStyleController: TcxEditStyleController;
    function GetAssignedValues: TcxEditStyleValues;
    function GetBaseStyle: TcxCustomEditStyle;
    function GetBorderStyle: TcxEditBorderStyle;
    function GetButtonStyle: TcxEditButtonStyle;
    function GetButtonTransparency: TcxEditButtonTransparency;
    function GetEdit: TcxCustomEdit;
    function GetGradient: Boolean;
    function GetGradientButtons: Boolean;
    function GetGradientDirection: TcxEditGradientDirection;
    function GetPopupBorderStyle: TcxEditPopupBorderStyle;
    function GetPopupCloseButton: Boolean;
    function GetStyleController: TcxEditStyleController;

    function InternalGetButtonStyle(var ButtonStyle: TcxEditButtonStyle): Boolean;
    function InternalGetButtonTransparency(var ButtonTransparency: TcxEditButtonTransparency): Boolean;
    function InternalGetGradient(var Gradient: Boolean): Boolean;
    function InternalGetGradientButtons(var GradientButtons: Boolean): Boolean;
    function InternalGetGradientDirection(var GradientDirection: TcxEditGradientDirection): Boolean;
    function InternalGetPopupBorderStyle(var PopupBorderStyle: TcxEditPopupBorderStyle): Boolean;

    function IsBorderStyleStored: Boolean;
    function IsButtonStyleStored: Boolean;
    function IsButtonTransparencyStored: Boolean;
    function IsGradientStored: Boolean;
    function IsGradientButtonsStored: Boolean;
    function IsGradientDirectionStored: Boolean;
    function IsPopupBorderStyleStored: Boolean;
    function IsStyleControllerStored: Boolean;

    procedure SetAssignedValues(Value: TcxEditStyleValues);
    procedure SetBorderStyle(Value: TcxEditBorderStyle);
    procedure SetButtonStyle(Value: TcxEditButtonStyle);
    procedure SetButtonTransparency(Value: TcxEditButtonTransparency);
    procedure SetGradient(Value: Boolean);
    procedure SetGradientButtons(Value: Boolean);
    procedure SetGradientDirection(Value: TcxEditGradientDirection);
    procedure SetPopupBorderStyle(Value: TcxEditPopupBorderStyle);
    procedure SetPopupCloseButton(Value: Boolean);
    procedure SetStyleController(Value: TcxEditStyleController);
  protected
    function GetDefaultStyleController: TcxStyleController; override;
    function InternalGetNotPublishedExtendedStyleValues: TcxEditStyleValues; override;
    function DefaultButtonStyle: TcxEditButtonStyle; virtual;
    function DefaultButtonTransparency: TcxEditButtonTransparency; virtual;
    function DefaultGradient: Boolean; virtual;
    function DefaultGradientButtons: Boolean; virtual;
    function DefaultGradientDirection: TcxEditGradientDirection; virtual;
    function DefaultPopupBorderStyle: TcxEditPopupBorderStyle; virtual;
    property PopupCloseButton: Boolean read GetPopupCloseButton
      write SetPopupCloseButton default True;
  public
    constructor Create(AOwner: TPersistent; ADirectAccessMode: Boolean;
      AParentStyle: TcxContainerStyle = nil;
      AState: TcxContainerStateItem = csNormal); override;
    procedure Assign(Source: TPersistent); override;
    function GetStyleValueCount: Integer; override;
    function GetStyleValueName(AStyleValue: TcxEditStyleValue;
      out StyleValueName: string): Boolean; override;
    function IsValueAssigned(AValue: TcxEditStyleValue): Boolean; override;
    procedure Init(AParams: TcxViewParams);
    property ActiveStyleController: TcxEditStyleController
      read GetActiveStyleController;
    property AssignedValues: TcxEditStyleValues read GetAssignedValues
      write SetAssignedValues stored False;
    property BaseStyle: TcxCustomEditStyle read GetBaseStyle;
    property BorderStyle: TcxEditBorderStyle read GetBorderStyle
      write SetBorderStyle stored IsBorderStyleStored;
    property ButtonStyle: TcxEditButtonStyle read GetButtonStyle
      write SetButtonStyle stored IsButtonStyleStored;
    property ButtonTransparency: TcxEditButtonTransparency read GetButtonTransparency
      write SetButtonTransparency stored IsButtonTransparencyStored;
    property Edit: TcxCustomEdit read GetEdit;
    property Gradient: Boolean read GetGradient write SetGradient
      stored IsGradientStored;
    property GradientButtons: Boolean read GetGradientButtons
      write SetGradientButtons stored IsGradientButtonsStored;
    property GradientDirection: TcxEditGradientDirection read GetGradientDirection
      write SetGradientDirection stored IsGradientDirectionStored;
    property PopupBorderStyle: TcxEditPopupBorderStyle read GetPopupBorderStyle
      write SetPopupBorderStyle stored IsPopupBorderStyleStored;
    property StyleController: TcxEditStyleController read GetStyleController
      write SetStyleController stored IsStyleControllerStored;
  end;

  TcxCustomEditStyleClass = class of TcxCustomEditStyle;

  { TcxEditStyle }

  TcxEditStyle = class(TcxCustomEditStyle)
  published
    property AssignedValues;
    property BorderColor;
    property BorderStyle;
    property ButtonStyle;
    property ButtonTransparency;
    property Color;
    property Edges;
    property Font;
    property Gradient;
//    property GradientButtons;
    property GradientDirection;
    property HotTrack;
    property LookAndFeel;
    property PopupBorderStyle;
    property Shadow;
    property StyleController;
    property TextColor;
    property TextStyle;
    property TransparentBorder;
  end;

  { TcxCustomEditPropertiesValues }

  TcxCustomEditPropertiesValues = class(TPersistent)
  private
    FOwner: TPersistent;
    FMaxValue: Boolean;
    FMinValue: Boolean;
    FReadOnly: Boolean;
    function GetProperties: TcxCustomEditProperties;
    procedure SetMaxValue(Value: Boolean);
    procedure SetMinValue(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
  protected
    function GetOwner: TPersistent; override;
    procedure Changed;
    function IsMaxValueStored: Boolean;
    function IsMinValueStored: Boolean;
    function IsPropertiesPropertyVisible(const APropertyName: string): Boolean;
    property MaxValue: Boolean read FMaxValue write SetMaxValue
      stored IsMaxValueStored;
    property MinValue: Boolean read FMinValue write SetMinValue
      stored IsMinValueStored;
    property Properties: TcxCustomEditProperties read GetProperties;
  public
    constructor Create(AOwner: TPersistent); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure RestoreDefaults; virtual;
  published
    property ReadOnly: Boolean read FReadOnly write SetReadOnly stored False;
  end;

  TcxCustomEditPropertiesValuesClass = class of TcxCustomEditPropertiesValues;

  { TcxCustomEditDefaultValuesProvider }

  TcxCustomEditDefaultValuesProvider = class(TcxInterfacedPersistent,
    IUnknown, IcxEditDefaultValuesProvider)
  public
    destructor Destroy; override;
    function CanSetEditMode: Boolean; virtual;
    procedure ClearUsers;
    function DefaultAlignment: TAlignment; virtual;
    function DefaultBlobKind: TcxBlobKind; virtual;
    function DefaultCanModify: Boolean; virtual;
    function DefaultDisplayFormat: string; virtual;
    function DefaultEditFormat: string; virtual;
    function DefaultEditMask: string; virtual;
    function DefaultIsFloatValue: Boolean; virtual;
    function DefaultMaxLength: Integer; virtual;
    function DefaultMaxValue: Double; virtual;
    function DefaultMinValue: Double; virtual;
    function DefaultPrecision: Integer; virtual;
    function DefaultReadOnly: Boolean; virtual;
    function DefaultRequired: Boolean; virtual;
    function GetInstance: TObject;
    function IsBlob: Boolean; virtual;
    function IsCurrency: Boolean; virtual;
    function IsDataAvailable: Boolean; virtual;
    function IsDataStorage: Boolean; virtual;
    function IsDisplayFormatDefined(AIsCurrencyValueAccepted: Boolean): Boolean; virtual;
    function IsOnGetTextAssigned: Boolean; virtual;
    function IsOnSetTextAssigned: Boolean; virtual;
    function IsValidChar(AChar: Char): Boolean; virtual;
  end;

  TcxCustomEditDefaultValuesProviderClass = class of TcxCustomEditDefaultValuesProvider;

  { TcxCustomEditProperties }

  TcxEditButtonClickEvent = procedure (Sender: TObject; AButtonIndex: Integer) of object;
  TcxEditEditingEvent = procedure(Sender: TObject; var CanEdit: Boolean) of object;
  TcxEditCloseUpReason = (crUnknown, crTab, crClose, crCancel, crEnter);
  TcxEditClosePopupEvent = procedure(Sender: TcxControl; AReason: TcxEditCloseUpReason) of object;

  TcxCustomEditProperties = class(TcxInterfacedPersistent)
  private
    FAutoSelect: Boolean;
    FBeepOnError: Boolean;
    FButtons: TcxEditButtons;
    FButtonsViewStyle: TcxEditButtonsViewStyle;
    FChangedOccurred: Boolean;
    FClearKey: TShortCut;
    FClickKey: TShortCut;
    FFreeNotificator: TcxFreeNotificator;
    FImmediatePost: Boolean;
    FInnerAlignment: TcxEditAlignment;
    FIsChangingCount: Integer;
    FMaxValue: Double;
    FMinValue: Double;
    FReadOnly: Boolean;
    FTransparent: Boolean;
    FUpdateCount: Integer;
    FUseLeftAlignmentOnEditing: Boolean;
    FUseMouseWheel: Boolean;
    FValidateOnEnter: Boolean;
    FOnButtonClick: TcxEditButtonClickEvent;
    FOnChange: TNotifyEvent;
    FOnClosePopup: TcxEditClosePopupEvent;
    FOnEditValueChanged: TNotifyEvent;
    FOnValidate: TcxEditValidateEvent;
    FOnPropertiesChanged: TNotifyEvent;
    function BaseGetAlignment: TcxEditAlignment;
    procedure DefaultValuesChanged(Sender: TObject);
    function GetIsChanging: Boolean;
    function GetReadOnly: Boolean;
    function IsAlignmentStored: Boolean;
    function IsUseLeftAlignmentOnEditingStored: Boolean;
    function IsReadOnlyStored: Boolean;
    procedure SetAssignedValues(Value: TcxCustomEditPropertiesValues);
    procedure SetAutoSelect(Value: Boolean);
    procedure SetButtons(Value: TcxEditButtons);
    procedure SetButtonsViewStyle(Value: TcxEditButtonsViewStyle);
    procedure SetUseLeftAlignmentOnEditing(Value: Boolean);
    procedure SetIDefaultValuesProvider(Value: IcxEditDefaultValuesProvider);
    procedure SetMaxValue(Value: Double);
    procedure SetMinValue(Value: Double);
    procedure SetReadOnly(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
  protected
    FAlignment: TcxEditAlignment;
    FAssignedValues: TcxCustomEditPropertiesValues;
    FChangedLocked: Boolean;
    FIDefaultValuesProvider: IcxEditDefaultValuesProvider;
    FOwner: TPersistent;
    procedure AlignmentChangedHandler(Sender: TObject); virtual;
    procedure BaseSetAlignment(Value: TcxEditAlignment); virtual;
    procedure ButtonsChanged(Sender: TObject); virtual;
    function CanModify: Boolean;
    function CanValidate: Boolean; virtual;
    function DefaultUseLeftAlignmentOnEditing: Boolean; virtual;
    procedure DefaultValuesProviderDestroyed; virtual;
    procedure DoValidate(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var AError: Boolean; AEdit: TcxCustomEdit;
      out AIsUserErrorDisplayValue: Boolean);
    procedure FillMinMaxValues(AMinValue, AMaxValue: Double);
    procedure FreeNotification(Sender: TComponent); virtual;
    class function GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass; virtual;
    function GetDefaultHorzAlignment: TAlignment; virtual;
    function GetDisplayFormatOptions: TcxEditDisplayFormatOptions; virtual;
    function GetMaxValue: Double; virtual;
    function GetMinValue: Double; virtual;
    function GetValidateErrorText(AErrorKind: TcxEditErrorKind): string; virtual;
    function GetValueEditorEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; virtual;
    class function GetViewDataClass: TcxCustomEditViewDataClass; virtual;
    function HasDisplayValue: Boolean; virtual;
    function InnerEditNeedsTabs: Boolean; virtual;
    function IsEditValueConversionDependOnFocused: Boolean; virtual;
    function IsMaxValueStored: Boolean;
    function IsMinValueStored: Boolean;
    property AssignedValues: TcxCustomEditPropertiesValues read FAssignedValues
      write SetAssignedValues;
    property ButtonsViewStyle: TcxEditButtonsViewStyle read FButtonsViewStyle
      write SetButtonsViewStyle default bvsNormal;
    property DisplayFormatOptions: TcxEditDisplayFormatOptions read GetDisplayFormatOptions;
    property FreeNotificator: TcxFreeNotificator read FFreeNotificator;
    property MaxValue: Double read GetMaxValue write SetMaxValue stored IsMaxValueStored;
    property MinValue: Double read GetMinValue write SetMinValue stored IsMinValueStored;
    property Transparent: Boolean read FTransparent write SetTransparent stored False; // deprecated
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; virtual;
    class function GetButtonsClass: TcxEditButtonsClass; virtual;
    class function GetContainerClass: TcxContainerClass; virtual;
    class function GetStyleClass: TcxCustomEditStyleClass; virtual;
    class function GetViewInfoClass: TcxContainerViewInfoClass; virtual;
    procedure BeginUpdate;
    procedure Changed; virtual;
    function ChangedLocked: Boolean;
    function CompareDisplayValues(
      const AEditValue1, AEditValue2: TcxEditValue): Boolean; virtual;
    function CreatePreviewProperties: TcxCustomEditProperties; virtual;
    function CreateViewData(AStyle: TcxCustomEditStyle;
      AIsInplace: Boolean; APreviewMode: Boolean = False): TcxCustomEditViewData; virtual;
    procedure DataChanged; virtual;
    procedure EndUpdate(AInvokeChanged: Boolean = True);
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; virtual;
    function GetEditConstantPartSize(ACanvas: TcxCanvas; AEditStyle: TcxCustomEditStyle;
      AIsInplace: Boolean; const AEditSizeProperties: TcxEditSizeProperties;
      var MinContentSize: TSize): TSize;
    function GetEditContentSize(ACanvas: TcxCanvas; AEditStyle: TcxCustomEditStyle;
      AIsInplace: Boolean;  const AEditValue: TcxEditValue; const AEditSizeProperties:
      TcxEditSizeProperties): TSize;
    function GetEditSize(ACanvas: TcxCanvas; AEditStyle: TcxCustomEditStyle;
      AIsInplace: Boolean; const AEditValue: TcxEditValue; AEditSizeProperties:
      TcxEditSizeProperties): TSize;
    function GetSpecialFeatures: TcxEditSpecialFeatures; virtual;
    function GetSupportedOperations: TcxEditSupportedOperations; virtual;
    function IsActivationKey(AKey: Char): Boolean; virtual;
    function IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean; virtual;
    function IsResetEditClass: Boolean; virtual;
    function IsValueEditorWithValueFormatting: Boolean;
    procedure LockUpdate(ALock: Boolean);
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean); virtual;
    procedure RestoreDefaults; virtual;
    procedure Update(AProperties: TcxCustomEditProperties); virtual;
    procedure ValidateDisplayValue(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var AError: Boolean;
      AEdit: TcxCustomEdit); virtual;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; virtual;
    property Buttons: TcxEditButtons read FButtons write SetButtons;
    property IDefaultValuesProvider: IcxEditDefaultValuesProvider
      read FIDefaultValuesProvider write SetIDefaultValuesProvider;
    property IsChanging: Boolean read GetIsChanging;
    property OnPropertiesChanged: TNotifyEvent read FOnPropertiesChanged write FOnPropertiesChanged;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly stored IsReadOnlyStored;
    property UseLeftAlignmentOnEditing: Boolean read FUseLeftAlignmentOnEditing
      write SetUseLeftAlignmentOnEditing stored IsUseLeftAlignmentOnEditingStored;
    property UseMouseWheel: Boolean read FUseMouseWheel write FUseMouseWheel default True;
    // !!!
    property Alignment: TcxEditAlignment read BaseGetAlignment
      write BaseSetAlignment stored IsAlignmentStored;
    property AutoSelect: Boolean read FAutoSelect write SetAutoSelect default True;
    property BeepOnError: Boolean read FBeepOnError write FBeepOnError default False;
    property ClearKey: TShortCut read FClearKey write FClearKey default 0;
    property ClickKey: TShortCut read FClickKey write FClickKey default VK_RETURN + scCtrl;
    property ImmediatePost: Boolean read FImmediatePost write FImmediatePost default False;
    property ValidateOnEnter: Boolean read FValidateOnEnter write FValidateOnEnter default False;
    property OnButtonClick: TcxEditButtonClickEvent read FOnButtonClick write FOnButtonClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClosePopup: TcxEditClosePopupEvent read FOnClosePopup write FOnClosePopup;
    property OnEditValueChanged: TNotifyEvent read FOnEditValueChanged write FOnEditValueChanged;
    property OnValidate: TcxEditValidateEvent read FOnValidate write FOnValidate;
  end;

  { TcxDataBinding }

  TcxDataBinding = class(TcxCustomDataBinding);

  { TcxEditDataBinding }

  TInterfacedObjectClass = class of TInterfacedObject;

  TcxEditDataBinding = class(TPersistent)
  private
    FIDefaultValuesProvider: TcxCustomEditDefaultValuesProvider;
    function GetIDefaultValuesProvider: IcxEditDefaultValuesProvider;
    function GetIsDataAvailable: Boolean;
  protected
    FEdit: TcxCustomEdit;
    procedure DefaultValuesChanged; virtual;
    function GetDisplayValue: TcxEditValue; virtual;
    function GetEditDataBindingInstance: TcxEditDataBinding;
    function GetEditing: Boolean; virtual;
    function GetModified: Boolean; virtual;
    function GetOwner: TPersistent; override;
    function GetStoredValue: TcxEditValue; virtual;
    function IsNull: Boolean; virtual;
    procedure Reset; virtual;
    procedure SetInternalDisplayValue(const Value: TcxEditValue);
    procedure SetDisplayValue(const Value: TcxEditValue); virtual;
    function SetEditMode: Boolean; virtual;
    procedure SetStoredValue(const Value: TcxEditValue); virtual;
    property Edit: TcxCustomEdit read FEdit;
  public
    constructor Create(AEdit: TcxCustomEdit); virtual;
    destructor Destroy; override;
    function CanCheckEditorValue: Boolean; virtual;
    function CanPostEditorValue: Boolean; virtual;
    function ExecuteAction(Action: TBasicAction): Boolean; virtual;
    class function GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass; virtual;
    procedure SetModified; virtual;
    function UpdateAction(Action: TBasicAction): Boolean; virtual;
    procedure UpdateDisplayValue; virtual;
    procedure UpdateNotConnectedDBEditDisplayValue; virtual;
    property DisplayValue: TcxEditValue read GetDisplayValue write SetDisplayValue;
    property Editing: Boolean read GetEditing;
    property IDefaultValuesProvider: IcxEditDefaultValuesProvider read GetIDefaultValuesProvider;
    property IsDataAvailable: Boolean read GetIsDataAvailable;
    property Modified: Boolean read GetModified;
    property StoredValue: TcxEditValue read GetStoredValue write SetStoredValue;
  end;

  TcxEditDataBindingClass = class of TcxEditDataBinding;

  { TcxCustomEdit }

  TcxEditModifiedState = record
    Modified: Boolean;
    ModifiedAfterEnter: Boolean;
  end;

  { TcxCustomEditData }

  TcxCustomEditData = class(TObject)
  private
    FCleared: Boolean;
    FEdit: TcxCustomEdit;
    FFreeNotificator: TcxFreeNotificator;
    procedure FreeNotification(AComponent: TComponent);
  protected
    property Cleared: Boolean read FCleared write FCleared;
  public
    constructor Create(AEdit: TcxCustomEdit); virtual;
    destructor Destroy; override;
    procedure Clear;
  end;

  TcxCustomEditDataClass = class of TcxCustomEditData;

  { TcxEditChangeEventsCatcher }

  TcxEditChangeEventsCatcher = class
  private
    FEdit: TcxCustomEdit;
    FLockCount: Integer;
    FOnChangeEvent: Boolean;
    FOnEditValueChangedEvent: Boolean;
  public
    property OnChangeEvent: Boolean read FOnChangeEvent write FOnChangeEvent;
    property OnEditValueChangedEvent: Boolean read FOnEditValueChangedEvent
      write FOnEditValueChangedEvent;
    constructor Create(AEdit: TcxCustomEdit);
    function IsLocked: Boolean;
    procedure Lock(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
  end;

  TcxCustomEdit = class(TcxContainer, IUnknown, IcxEditRepositoryItemListener,
    IdxSkinSupport, IdxSpellCheckerControl)
  private
    FAnchorX: Integer;
    FAnchorY: Integer;
    FAutoSize: Boolean;
    FCaptureButtonVisibleIndex: Integer;
    FChangeEventsCatcher: TcxEditChangeEventsCatcher;
    FClickLockCount: Integer;
    FDblClickTimer: TcxTimer;
    FEditData: TcxCustomEditData;
    FEditModeSetting: Boolean;
    FEditValueChangingLockCount: Integer;
    FFocused: Boolean;
    FHandleAllocating: Boolean;
    FInnerEdit: IcxCustomInnerEdit;
    FInnerEditDefWindowProc: Pointer;
    FIsBarControl: Boolean;
    FIsContentParamsInitialized: Boolean;
    FIsEditValidated: Boolean;
    FIsEditValidating: Boolean;
    FIsEditValueResetting: Boolean;
    FIsEscapeDown: Boolean;
    FIsFirstSetSize: Boolean;
    FIsJustCreated: Boolean;
    FIsInplace: Boolean;
    FIsPosting: Boolean;
    FKeyboardAction: Boolean;
    FLockValidate: Integer;
    FModified: Boolean;
    FModifiedAfterEnter: Boolean;
    FObjectInstance: Pointer;
    FPrevEditValue: TcxEditValue;
    FPrevModifiedList: array of TcxEditModifiedState;
    FPropertiesEvents: TNotifyEvent;
    FRepositoryItem: TcxEditRepositoryItem;
    FTransparent: Boolean;
    FUpdate: Boolean;
    FValidateErrorProcessing: Boolean;
    FOnAfterKeyDown: TKeyEvent;
    FOnEditing: TcxEditEditingEvent;
    FOnPostEditValue: TNotifyEvent;

    function CheckButtonShortCuts(AKey: Integer): Boolean;
    procedure DblClickTimerHandler(Sender: TObject);
    procedure DoClearEditData(AEditData: TcxCustomEditData);
    function GetActiveProperties: TcxCustomEditProperties;
    function GetEditActiveStyle: TcxCustomEditStyle;
    function GetHeight: Integer;
    function GetInternalStyle(AState: TcxContainerStateItem): TcxCustomEditStyle;
    function GetStyle: TcxEditStyle;
    function GetStyleDisabled: TcxEditStyle;
    function GetStyleFocused: TcxEditStyle;
    function GetStyleHot: TcxEditStyle;
    function GetViewInfo: TcxCustomEditViewInfo;
    procedure InitContentParams;
    procedure InternalCanResize(var ANewWidth, ANewHeight: Integer);
    function IsAutoWidth: Boolean;
    procedure ReadAnchorX(Reader: TReader);
    procedure ReadAnchorY(Reader: TReader);
    procedure ReadHeight(Reader: TReader);
    procedure ReadWidth(Reader: TReader);
    procedure SetDataBinding(Value: TcxEditDataBinding);
    procedure SetHeight(Value: Integer);
    procedure SetInternalStyle(AState: TcxContainerStateItem;
      Value: TcxCustomEditStyle);
    procedure SetModified(Value: Boolean);
    procedure SetModifiedAfterEnter(Value: Boolean);
    procedure SetModifiedAfterEnterValue(Value: Boolean);
    procedure SetProperties(Value: TcxCustomEditProperties);
    procedure SetRepositoryItem(Value: TcxEditRepositoryItem);
    procedure SetReplicatableFlag;
    procedure SetStyle(Value: TcxEditStyle);
    procedure SetStyleDisabled(Value: TcxEditStyle);
    procedure SetStyleFocused(Value: TcxEditStyle);
    procedure SetStyleHot(Value: TcxEditStyle);
    procedure SetTransparent(Value: Boolean);
    procedure WriteAnchorX(Writer: TWriter);
    procedure WriteAnchorY(Writer: TWriter);
    procedure WriteHeight(Writer: TWriter);
    procedure WriteWidth(Writer: TWriter);

    function GetHintText(APart: Integer): string;

    procedure WMCopy(var Message: TMessage); message WM_COPY;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
  protected
    FDataBinding: TcxEditDataBinding;
    FEditValue: TcxEditValue;
    FProperties: TcxCustomEditProperties;
    FSettingEditWindowRegion: Boolean;
    procedure CalculateAnchors; virtual;
    function CanContainerHandleTabs: Boolean; override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Click; override;
    procedure DblClick; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure FocusChanged; override;
    function GetBorderExtent: TRect; override;
    function GetEditStateColorKind: TcxEditStateColorKind; override;
    function GetStyleClass: TcxContainerStyleClass; override;
    function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function InternalGetNotPublishedStyleValues: TcxEditStyleValues; override;
    function IsTransparentBackground: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure ReadState(Reader: TReader); override;
    function RefreshContainer(const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): Boolean; override;
    procedure RequestAlign; override;
    procedure SetName(const Value: TComponentName); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetSize; override;
    procedure CreateHandle; override;
    function IsNativeStyle: Boolean; override;
    procedure SafeSelectionFocusInnerControl; override;
    procedure WndProc(var Message: TMessage); override;
    procedure AdjustInnerEditPosition; virtual;
    procedure AfterPosting; virtual;
    procedure BeforePosting; virtual;
    function ButtonVisibleIndexAt(const P: TPoint): Integer;
    procedure CalculateViewInfo(AIsMouseEvent: Boolean); reintroduce; overload;
    procedure CalculateViewInfo(P: TPoint; Button: TcxMouseButton;
      Shift: TShiftState; AIsMouseEvent: Boolean); reintroduce; overload;
    function CanAutoSize: Boolean; reintroduce; virtual;
    function CanAutoWidth: Boolean; virtual;
    function CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean; virtual;
    function CanKeyPressModifyEdit(Key: Char): Boolean; virtual;
    function CanModify: Boolean; virtual;
    procedure ChangeHandler(Sender: TObject); virtual;
    procedure CheckHandle;
    function CreateInnerEdit: IcxCustomInnerEdit; virtual;
    function CreateViewData: TcxCustomEditViewData; virtual;
    procedure DefaultButtonClick; virtual;
    procedure DisableValidate;
    procedure DoAfterKeyDown(var Key: Word; Shift: TShiftState);
    procedure DoAutoSizeChanged; virtual;
    procedure DoButtonClick(AButtonVisibleIndex: Integer); virtual;
    procedure DoButtonDown(AButtonVisibleIndex: Integer); virtual;
    procedure DoButtonUp(AButtonVisibleIndex: Integer); virtual;
    procedure DoChange; virtual;
    procedure DoClick;
    procedure DoClosePopup(AReason: TcxEditCloseUpReason);
    procedure DoEditValueChanged;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure DoEditKeyPress(var Key: Char); virtual;
    procedure DoEditKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure DoEditProcessTab(Shift: TShiftState); virtual;
    procedure DoFocusChanged; virtual;
    procedure DoHideEdit(AExit: Boolean);
    procedure DoOnValidate(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var AError: Boolean);
    procedure DoOnChange; virtual;
    procedure DoOnEditValueChanged; virtual;
    procedure DoPostEditValue;
    procedure DoShowEdit; virtual;
    procedure EditingChanged; virtual;
    procedure EnableValidate;
    procedure FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties); virtual;
    function GetClearValue: TcxEditValue; virtual;
    class function GetDataBindingClass: TcxEditDataBindingClass; reintroduce; virtual;
    function GetDefaultButtonVisibleIndex: Integer;
    function GetDisplayValue: string; virtual;
    function GetEditDataClass: TcxCustomEditDataClass; virtual;
    function GetEditingValue: TcxEditValue; virtual;
    function GetEditValue: TcxEditValue; virtual;
    function GetInnerEditClass: TControlClass; virtual;
    function HandleMouseWheel(Shift: TShiftState): Boolean;
    procedure HandleValidationError(const AErrorText: string;
      ACanAbortExecution: Boolean); virtual;
    function HasInnerEdit: Boolean;
    procedure Initialize; virtual;
    procedure InitializeEditData; virtual;
    procedure InitializeInnerEdit; virtual;
    procedure InitializeViewData(AViewData: TcxCustomEditViewData); virtual;
    function InternalDoEditing: Boolean; virtual;
    function InternalGetActiveProperties: TcxCustomEditProperties;
    function InternalGetEditingValue: TcxEditValue; virtual;
    procedure InternalPostEditValue(AValidateEdit: Boolean = False);
    procedure InternalPostValue;
    procedure InternalSetDisplayValue(const Value: TcxEditValue); virtual;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); virtual;
    procedure InternalValidateDisplayValue(const ADisplayValue: TcxEditValue); virtual;
    function IsActiveControl: Boolean; virtual;
    function IsButtonDC(ADC: THandle): Boolean; virtual;
    function IsClickEnabledDuringLoading: Boolean; virtual;
    function IsDBEdit: Boolean;
    function IsDBEditPaintCopyDrawing: Boolean; virtual;
    function IsEditorKey(Key: Word; Shift: TShiftState): Boolean; virtual;
    function IsEditValueStored: Boolean; virtual;
    function IsNativeBackground: Boolean; virtual;
    function IsOnChangeEventAssigned: Boolean;
    function IsOnEditValueChangedEventAssigned: Boolean;
    function IsOnValidateEventAssigned: Boolean;
    function IsResetEditClass: Boolean;
    function IsSpecialKey(Key: Word; Shift: TShiftState): Boolean;
    function IsTransparent: Boolean; virtual;
    function IsValidChar(AChar: Char): Boolean; virtual;
    function NeedsInvokeAfterKeyDown(AKey: Word; AShift: TShiftState): Boolean; virtual;
    procedure PaintCopyDraw; virtual;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); virtual;
    procedure ProcessViewInfoChanges(APrevViewInfo: TcxCustomEditViewInfo; AIsMouseDownUpEvent: Boolean); virtual;
    procedure PropertiesChanged(Sender: TObject); virtual;
    function PropertiesChangeLocked: Boolean;
    function RealReadOnly: Boolean; virtual;
    procedure RepositoryItemAssigned; virtual;
    procedure RepositoryItemAssigning; virtual;
    procedure ResetEditValue; virtual;
    procedure RestoreModified;
    procedure SaveModified;
    function SendActivationKey(Key: Char): Boolean; virtual;
    function SetDisplayText(const Value: string): Boolean; virtual;
    procedure SetEditAutoSize(Value: Boolean); virtual;
    procedure SetEditValue(const Value: TcxEditValue); virtual;
    procedure SetInternalEditValue(const Value: TcxEditValue); virtual;
    procedure SetInternalDisplayValue(Value: TcxEditValue); virtual;
    procedure SynchronizeDisplayValue; virtual;
    procedure SynchronizeEditValue; virtual;
    function TabsNeeded: Boolean; virtual;
    function UpdateContentOnFocusChanging: Boolean; virtual;
    procedure UpdateDrawValue; virtual;
    procedure UpdateInnerEditReadOnly;
    function ValidateKeyDown(var Key: Word; Shift: TShiftState): Boolean; virtual;
    function ValidateKeyPress(var Key: Char): Boolean; virtual;
    function WantNavigationKeys: Boolean; virtual;
    procedure LockedInnerEditWindowProc(var Message: TMessage); virtual;
    procedure LockInnerEditRepainting; virtual;
    procedure UnlockInnerEditRepainting; virtual;
    function UseAnchors: Boolean; virtual;
    function UseAnchorX: Boolean; virtual;
    function UseAnchorY: Boolean; virtual;

    // IcxEditRepositoryItemListener
    procedure IcxEditRepositoryItemListener.ItemRemoved = RepositoryItemListenerItemRemoved;
    procedure IcxEditRepositoryItemListener.PropertiesChanged = RepositoryItemListenerPropertiesChanged;
    procedure RepositoryItemListenerItemRemoved(Sender: TcxEditRepositoryItem);
    procedure RepositoryItemListenerPropertiesChanged(Sender: TcxEditRepositoryItem);

    //IdxSpellCheckerSupport
    procedure IdxSpellCheckerControl.SetValue = SpellCheckerSetValue;
    procedure IdxSpellCheckerControl.SetIsBarControl = SpellCheckerSetIsBarControl;
    procedure IdxSpellCheckerControl.SetSelText = SpellCheckerSetSelText;

    function SupportsSpelling: Boolean; virtual;
    procedure SpellCheckerSetIsBarControl(AValue: Boolean); virtual;
    procedure SpellCheckerSetSelText(const AValue: string; APost: Boolean = False); virtual;
    procedure SpellCheckerSetValue(const AValue: Variant); virtual;


    property ActiveStyle: TcxCustomEditStyle read GetEditActiveStyle;
    property AnchorX: Integer read FAnchorX;
    property AnchorY: Integer read FAnchorY;
    property AutoSize: Boolean read FAutoSize write SetEditAutoSize default True;
    property CaptureButtonVisibleIndex: Integer read FCaptureButtonVisibleIndex write
      FCaptureButtonVisibleIndex;
    property ChangeEventsCatcher: TcxEditChangeEventsCatcher read FChangeEventsCatcher;
    property DataBinding: TcxEditDataBinding read FDataBinding write SetDataBinding;
    property DisplayValue: string read GetDisplayValue;
    property EditData: TcxCustomEditData read FEditData;
    property EditModeSetting: Boolean read FEditModeSetting;
    property InnerEdit: IcxCustomInnerEdit read FInnerEdit;
    property IsEditValidated: Boolean read FIsEditValidated write FIsEditValidated;
    property IsEditValidating: Boolean read FIsEditValidating;

    property IsEditValueResetting: Boolean read FIsEditValueResetting;
    property KeyboardAction: Boolean read FKeyboardAction write FKeyboardAction;
    property PrevEditValue: TcxEditValue read FPrevEditValue write FPrevEditValue;
    property Properties: TcxCustomEditProperties read FProperties write SetProperties;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
  public
    ContentParams: TcxEditContentParams;
    InplaceParams: TcxInplaceEditParams;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; AIsInplace: Boolean); reintroduce; overload; virtual;
    destructor Destroy; override;
    procedure DefaultHandler(var Message); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure GetTabOrderList(List: TList); override;
    function IsInplace: Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure Activate(var AEditData: TcxCustomEditData); virtual;
    procedure ActivateByKey(Key: Char; var AEditData: TcxCustomEditData); virtual;
    procedure ActivateByMouse(Shift: TShiftState; X, Y: Integer;
      var AEditData: TcxCustomEditData); virtual;
    function AreChangeEventsLocked: Boolean;
    function CanPostEditValue: Boolean;
    procedure Clear; virtual;
    procedure CopyToClipboard; virtual;
    procedure CutToClipboard; virtual;
    function Deactivate: Boolean; virtual;
    function DoEditing: Boolean;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; virtual;
    function InternalFocused: Boolean;
    function IsChildWindow(AWnd: THandle): Boolean; virtual;
    function IsEditClass: Boolean; virtual;
    function IsRepositoryItemAcceptable(
      ARepositoryItem: TcxEditRepositoryItem): Boolean; virtual;
    procedure LockChangeEvents(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
    procedure LockClick(ALock: Boolean);
    procedure LockEditValueChanging(ALock: Boolean);
    procedure PasteFromClipboard; virtual;
    procedure PostEditValue;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); virtual;
    procedure Reset;
    procedure SelectAll; virtual;
    function ValidateEdit(ARaiseExceptionOnError: Boolean): Boolean;
  {$IFDEF DELPHI10}
    function GetTextBaseLine: Integer; virtual;
    function HasTextBaseLine: Boolean; virtual;
  {$ENDIF}
    property ActiveProperties: TcxCustomEditProperties read GetActiveProperties;
    property EditingValue: TcxEditValue read GetEditingValue;
    property EditModified: Boolean read FModified write SetModified;
    property EditValue: TcxEditValue read GetEditValue write SetEditValue stored
      IsEditValueStored;
    property InternalEditValue: TcxEditValue read GetEditValue
      write SetInternalEditValue stored False;
    property InternalProperties: TcxCustomEditProperties read FProperties;
    property IsPosting: Boolean read FIsPosting;
    property ModifiedAfterEnter: Boolean read FModifiedAfterEnter write SetModifiedAfterEnter;
    property Style: TcxEditStyle read GetStyle write SetStyle;
    property StyleDisabled: TcxEditStyle read GetStyleDisabled
      write SetStyleDisabled;
    property StyleFocused: TcxEditStyle read GetStyleFocused
      write SetStyleFocused;
    property StyleHot: TcxEditStyle read GetStyleHot write SetStyleHot;
    property Styles[AState: TcxContainerStateItem]: TcxCustomEditStyle
      read GetInternalStyle write SetInternalStyle;
    property TabStop default True;
    property ViewInfo: TcxCustomEditViewInfo read GetViewInfo;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
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
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

    property OnAfterKeyDown: TKeyEvent read FOnAfterKeyDown write FOnAfterKeyDown;
    property OnEditing: TcxEditEditingEvent read FOnEditing write FOnEditing;
    property OnPostEditValue: TNotifyEvent read FOnPostEditValue write FOnPostEditValue;
  published
    property Height: Integer read GetHeight write SetHeight stored False;
    property PropertiesEvents: TNotifyEvent read FPropertiesEvents write FPropertiesEvents;
    property RepositoryItem: TcxEditRepositoryItem read FRepositoryItem write SetRepositoryItem;
    property Width stored False;
    property OnFocusChanged;
  end;

  TcxCustomEditClass = class of TcxCustomEdit;

  { TcxEditAlignment }

  TcxEditAlignment = class(TPersistent)
  private
    FHorz: TcxEditHorzAlignment;
    FIsHorzAssigned: Boolean;
    FOwner: TPersistent;
    FVert: TcxEditVertAlignment;
    FOnChanged: TNotifyEvent;
    procedure SetHorz(const Value: TcxEditHorzAlignment);
    procedure SetVert(const Value: TcxEditVertAlignment);
  protected
    procedure DoChanged;
    function GetOwner: TPersistent; override;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  public
    constructor Create(AOwner: TPersistent); virtual;
    procedure Assign(Source: TPersistent); override;
    function IsHorzStored: Boolean;
    function IsVertStored: Boolean;
    procedure Reset;
  published
    property Horz: TcxEditHorzAlignment read FHorz write SetHorz stored IsHorzStored;
    property Vert: TcxEditVertAlignment read FVert write SetVert stored IsVertStored;
  end;

  TcxEditListItem = record
    Edit: TcxCustomEdit;
    Properties: TcxCustomEditProperties;
  end;

  { TcxInplaceEditList }

  TcxInplaceEditList = class
  private
    FItems: array of TcxEditListItem;
    FEditorOwner: TComponent;
    function CreateEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit;
    procedure DestroyItems;
    function FindItem(AProperties: TcxCustomEditProperties;
      ACanUseFreeEditors: Boolean): Integer; overload;
    function FindItem(APropertiesClass: TcxCustomEditPropertiesClass): Integer; overload;
    function GetCount: Integer;
    function GetEdit(AItemIndex: Integer): TcxCustomEdit; overload;
    procedure InitEdit(AEdit: TcxCustomEdit; AProperties: TcxCustomEditProperties);
    procedure RemoveItem(AIndex: Integer); overload;
  protected
    property Count: Integer read GetCount;
    property EditorOwner: TComponent read FEditorOwner;
  public
    constructor Create(AEditorOwner: TComponent); virtual;
    destructor Destroy; override;
    procedure DisconnectProperties(AProperties: TcxCustomEditProperties);
    function FindEdit(AProperties: TcxCustomEditProperties): TcxCustomEdit; overload;
    function FindEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit; overload;
    function GetEdit(AProperties: TcxCustomEditProperties): TcxCustomEdit; overload;
    function GetEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit; overload;
    procedure RemoveItem(AProperties: TcxCustomEditProperties); overload;
    procedure RemoveItem(APropertiesClass: TcxCustomEditPropertiesClass); overload;
  end;

  { TcxDefaultEditStyleController }

  TcxDefaultEditStyleController = class(TComponent)
  private
    function GetEmulateStandardControlDrawing: Boolean;
    function GetInternalStyle(AState: TcxContainerStateItem): TcxCustomEditStyle;
    function GetOnStyleChanged: TNotifyEvent;
    function GetStyle: TcxEditStyle;
    function GetStyleDisabled: TcxEditStyle;
    function GetStyleFocused: TcxEditStyle;
    function GetStyleHot: TcxEditStyle;
    procedure SetEmulateStandardControlDrawing(Value: Boolean);
    procedure SetInternalStyle(AState: TcxContainerStateItem;
      Value: TcxCustomEditStyle);
    procedure SetOnStyleChanged(Value: TNotifyEvent);
    procedure SetStyle(Value: TcxEditStyle);
    procedure SetStyleDisabled(Value: TcxEditStyle);
    procedure SetStyleFocused(Value: TcxEditStyle);
    procedure SetStyleHot(Value: TcxEditStyle);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RestoreStyles;
    property Styles[AState: TcxContainerStateItem]: TcxCustomEditStyle
      read GetInternalStyle write SetInternalStyle;
  published
    property EmulateStandardControlDrawing: Boolean
      read GetEmulateStandardControlDrawing
      write SetEmulateStandardControlDrawing default False;
    property Style: TcxEditStyle read GetStyle write SetStyle;
    property StyleDisabled: TcxEditStyle read GetStyleDisabled
      write SetStyleDisabled;
    property StyleFocused: TcxEditStyle read GetStyleFocused
      write SetStyleFocused;
    property StyleHot: TcxEditStyle read GetStyleHot write SetStyleHot;
    property OnStyleChanged: TNotifyEvent read GetOnStyleChanged
      write SetOnStyleChanged;
  end;

const
  DefaultcxEditSizeProperties: TcxEditSizeProperties =
    (Height: -1; MaxLineCount: 0; Width: -1);

function ButtonToShift(Button: TMouseButton): TShiftState;
procedure CheckSize(var Size: TSize; const ANewSize: TSize);
function cxButtonToShift(Button: TcxMouseButton): TShiftState;
function cxEditVarEquals(const V1, V2: Variant): Boolean;
function DefaultEditStyleController: TcxEditStyleController;
function EmulateStandardControlDrawing: Boolean;
function GetDefaultEditRepository: TcxEditRepository;
function GetEditPopupWindowControlsLookAndFeelKind(
  AEdit: TcxCustomEdit): TcxLookAndFeelKind;
function GetOwnerComponent(APersistent: TPersistent): TComponent;
function GetRegisteredEditProperties: TcxRegisteredClasses;
function GetStandaloneEventSender(AEdit: TcxCustomEdit): TObject;
function InternalVarEqualsExact(const V1, V2: Variant): Boolean;
function IsSpaceChar(C: AnsiChar): Boolean; overload;
function IsSpaceChar(C: WideChar): Boolean; overload;
procedure SendMouseEvent(AReceiver: TWinControl; AMessage: DWORD;
  AShift: TShiftState; const APoint: TPoint);
procedure SendKeyDown(AReceiver: TWinControl; Key: Word; Shift: TShiftState);
procedure SendKeyPress(AReceiver: TWinControl; Key: Char);
procedure SendKeyUp(AReceiver: TWinControl; Key: Word; Shift: TShiftState);
procedure SetStandardControlDrawingEmulationMode(AEmulate: Boolean);
procedure UniteRegions(ADestRgn, ASrcRgn: TcxRegion);

implementation

{$R cxEdit.res}
{$R cxScrollCursors.res}

uses
  TypInfo, cxDateUtils, cxEditConsts, cxEditUtils, cxFilterConsts, dxOffice11,
  dxThemeConsts, dxUxTheme, dxThemeManager, cxGeometry, cxDWMApi, Math, cxLibraryConsts;

const
  EditContentMaxTotalDefaultHorzOffset = 3;

type
  TControlAccess = class(TControl);
  TcxLookAndFeelAccess = class(TcxLookAndFeel);
  TWinControlAccess = class(TWinControl);

var
  FCreatedEditPropertiesList: TList;
  FDefaultEditRepository: TcxEditRepository;
  FDefaultEditStyleController: TcxEditStyleController;
  FDefaultEditStyleControllerCount: Integer;
  FEmulateStandardControlDrawing: Boolean;
  FInplaceEditLists: TList;
  FRegisteredEditProperties: TcxRegisteredClasses;

function ButtonToShift(Button: TMouseButton): TShiftState;
const
  AButtonMap: array[TMouseButton] of TShiftState = ([ssLeft], [ssRight], [ssMiddle]);
begin
  Result := AButtonMap[Button];
end;

procedure CheckSize(var Size: TSize; const ANewSize: TSize);
begin
  with ANewSize do
  begin
    if Size.cx < cx then
      Size.cx := cx;
    if Size.cy < cy then
      Size.cy := cy;
  end;
end;

procedure ClearPropertiesDestroyingListeners(AProperties: TcxCustomEditProperties);
var
  I: Integer;
begin
  if FInplaceEditLists <> nil then
    for I := 0 to FInplaceEditLists.Count - 1 do
      TcxInplaceEditList(FInplaceEditLists[I]).DisconnectProperties(AProperties);
end;

function cxButtonToShift(Button: TcxMouseButton): TShiftState;
const
  AButtonMap: array[TcxMouseButton] of TShiftState = ([], [ssLeft], [ssRight], [ssMiddle]);
begin
  Result := AButtonMap[Button];
end;

function cxEditVarEquals(const V1, V2: Variant): Boolean;

  function VarTypeEquals: Boolean;
  begin
    Result := VarIsNumericEx(V1) and VarIsNumericEx(V2) or (VarType(V1) = VarType(V2));
  end;

begin
  Result := VarTypeEquals and VarEqualsExact(V1, V2);
end;

procedure DrawComplexFrameEx(ACanvas: TcxCanvas; var ARect: TRect; ALeftTopColor, ARightBottomColor: TColor);
begin
  ACanvas.DrawComplexFrame(ARect, ALeftTopColor, ARightBottomColor);
  InflateRect(ARect, -1, -1);
end;

procedure FrameRectEx(ACanvas: TcxCanvas; var ARect: TRect; AColor: TColor);
begin
  ACanvas.FrameRect(ARect, AColor);
  InflateRect(ARect, -1, -1);
end;

function DefaultEditStyleController: TcxEditStyleController;
begin
  Result := FDefaultEditStyleController;
end;

function EmulateStandardControlDrawing: Boolean;
begin
  Result := FEmulateStandardControlDrawing;
end;

function GetDefaultEditRepository: TcxEditRepository;
begin
  if FDefaultEditRepository = nil then
    FDefaultEditRepository := TcxEditRepository.Create(nil);
  Result := FDefaultEditRepository;
end;

function GetEditPopupWindowControlsLookAndFeelKind(
  AEdit: TcxCustomEdit): TcxLookAndFeelKind;
const
  APopupControlLookAndFeelKindMap: array [TcxEditButtonStyle] of TcxLookAndFeelKind =
    (lfStandard, lfStandard, lfFlat, lfFlat, lfFlat,
    lfUltraFlat, lfOffice11);
begin
  with AEdit do
    if IsInplace then
      Result := Style.LookAndFeel.Kind
    else
      if Length(ViewInfo.ButtonsInfo) > 0 then
        Result := APopupControlLookAndFeelKindMap[ViewInfo.ButtonsInfo[0].Data.Style]
      else
        Result := lfStandard;
end;

function GetOwnerComponent(APersistent: TPersistent): TComponent;
begin
  while (APersistent <> nil) and not(APersistent is TComponent) do
    APersistent := GetPersistentOwner(APersistent);
  Result := TComponent(APersistent);
end;

function GetRegisteredEditProperties: TcxRegisteredClasses;
begin
  if FRegisteredEditProperties = nil then
  begin
    FRegisteredEditProperties := TcxRegisteredClasses.Create;
    FRegisteredEditProperties.Sorted := True;
  end;
  Result := FRegisteredEditProperties;
end;

function GetStandaloneEventSender(AEdit: TcxCustomEdit): TObject;
begin
  if not AEdit.IsInplace then
    Result := AEdit
  else
    Result := nil;
end;

function InternalVarEqualsExact(const V1, V2: Variant): Boolean;
begin
  Result := (VarType(V1) = VarType(V2)) and VarEqualsExact(V1, V2);
end;

function IsSpaceChar(C: AnsiChar): Boolean; overload;
begin
  Result := (C = ' ') or (C = #0) or (C = #9) or (C = #10) or (C = #12) or (C = #13);
end;

function IsSpaceChar(C: WideChar): Boolean; overload;
begin
  Result := (C = ' ') or (C = #0) or (C = #9) or (C = #10) or (C = #12) or (C = #13);
end;

function IsRegionEmpty(ARgn: TcxRegion): Boolean;
var
  R: TRect;
begin
  Result := GetRgnBox(ARgn.Handle, R) = NULLREGION;
end;

procedure SendMouseEvent(AReceiver: TWinControl; AMessage: DWORD;
  AShift: TShiftState; const APoint: TPoint);
begin
  SendMessage(AReceiver.Handle, AMessage, ShiftStateToKeys(AShift), MakeLParam(APoint.X, APoint.Y));
end;

procedure SendKeyEvent(AReceiver: TWinControl; AMessage: DWORD; AKey: Word; AShift: TShiftState);
begin
  SendMessage(AReceiver.Handle, AMessage, AKey, 0);
end;

procedure SendKeyDown(AReceiver: TWinControl; Key: Word; Shift: TShiftState);
begin
  SendKeyEvent(AReceiver, WM_KEYDOWN, Key, Shift);
end;

procedure SendKeyPress(AReceiver: TWinControl; Key: Char);
begin
  SendKeyEvent(AReceiver, WM_CHAR, Integer(Key), []);
end;

procedure SendKeyUp(AReceiver: TWinControl; Key: Word; Shift: TShiftState);
begin
  SendKeyEvent(AReceiver, WM_KEYUP, Key, Shift);
end;

procedure SetStandardControlDrawingEmulationMode(AEmulate: Boolean);
begin
  if AEmulate <> FEmulateStandardControlDrawing then
  begin
    FEmulateStandardControlDrawing := AEmulate;
    if RootLookAndFeel <> nil then
      TcxLookAndFeelAccess(RootLookAndFeel).NotifyChanged;
  end;
end;

procedure UniteRegions(ADestRgn, ASrcRgn: TcxRegion);
begin
  with ADestRgn do
    CombineRgn(Handle, Handle, ASrcRgn.Handle, RGN_OR);
end;

{ TcxEditRepositoryItem }

constructor TcxEditRepositoryItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FListenerList := TInterfaceList.Create;
  FProperties := GetEditPropertiesClass.Create(Self);
  FProperties.OnPropertiesChanged := PropertiesChanged;
end;

destructor TcxEditRepositoryItem.Destroy;

  procedure RemoveNotification;
  var
    I: Integer;
  begin
    for I := FListenerList.Count - 1 downto 0 do
      IcxEditRepositoryItemListener(FListenerList[I]).ItemRemoved(Self);
  end;

begin
  RemoveNotification;
  Repository := nil;
  FreeAndNil(FProperties);
  inherited Destroy;
end;

procedure TcxEditRepositoryItem.AddListener(AListener: IcxEditRepositoryItemListener);
begin
  if FListenerList.IndexOf(AListener) = -1 then
    FListenerList.Add(AListener);
end;

class function TcxEditRepositoryItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomEditProperties;
end;

function TcxEditRepositoryItem.GetBaseName: string;
const
  SSubStr = 'TcxEditRepository';
var
  I: Integer;
begin
  I := Pos(SSubStr, ClassName);
  if I > 0 then
    Result := Copy(ClassName, I + Length(SSubStr), Length(ClassName))
  else
    Result := '';
  Result := Repository.Name + Result;
end;

function TcxEditRepositoryItem.GetParentComponent: TComponent;
begin
  Result := Repository;
end;

function TcxEditRepositoryItem.HasParent: Boolean;
begin
  Result := Repository <> nil;
end;

procedure TcxEditRepositoryItem.RemoveListener(AListener: IcxEditRepositoryItemListener);
begin
  FListenerList.Remove(AListener);
end;

procedure TcxEditRepositoryItem.SetParentComponent(AParent: TComponent);
begin
  if not (csLoading in ComponentState) then
    Repository := AParent as TcxEditRepository;
end;

procedure TcxEditRepositoryItem.PropertiesChanged(Sender: TObject);
var
  I: Integer;
begin
  for I := FListenerList.Count - 1 downto 0 do
    IcxEditRepositoryItemListener(FListenerList[I]).PropertiesChanged(Self);
end;

procedure TcxEditRepositoryItem.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  Repository := TcxEditRepository(Reader.Parent);
end;

procedure TcxEditRepositoryItem.SetProperties(Value: TcxCustomEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxEditRepositoryItem.SetRepository(Value: TcxEditRepository);
begin
  if FRepository <> Value then
  begin
    if FRepository <> nil then
      FRepository.RemoveItem(Self);
    FRepository := Value;
    if Value <> nil then
      Value.AddItem(Self);
  end;
end;

{ TcxEditRepository }

constructor TcxEditRepository.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TList.Create;
end;

destructor TcxEditRepository.Destroy;
begin
  Clear;
  FItems.Free;
  FItems := nil;
  inherited Destroy;
end;

procedure TcxEditRepository.Clear;
begin
  while Count > 0 do
    Items[Count - 1].Free;
end;

function TcxEditRepository.CreateItem(ARepositoryItemClass: TcxEditRepositoryItemClass): TcxEditRepositoryItem;
begin
  Result := CreateItemEx(ARepositoryItemClass, Self);
end;

function TcxEditRepository.CreateItemEx(ARepositoryItemClass: TcxEditRepositoryItemClass;
  AOwner: TComponent): TcxEditRepositoryItem;
begin
  Result := ARepositoryItemClass.Create(AOwner);
  Result.Repository := Self;
end;

function TcxEditRepository.ItemByName(ARepositoryItemName: string): TcxEditRepositoryItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if AnsiCompareText(Items[I].Name, ARepositoryItemName) = 0 then
    begin
      Result := Items[I];
      Break;
    end;
end;

procedure TcxEditRepository.AddItem(AItem: TcxEditRepositoryItem);
var
  AIndex: Integer;
begin
  AIndex := FItems.IndexOf(AItem);
  if AIndex = -1 then
    FItems.Add(AItem);
end;

procedure TcxEditRepository.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  AItem: TcxEditRepositoryItem;
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    AItem := Items[I];
    if AItem.Owner = Root then
      Proc(AItem);
  end;
end;

procedure TcxEditRepository.RemoveItem(AItem: TcxEditRepositoryItem);
begin
  FItems.Remove(AItem);
end;

function TcxEditRepository.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxEditRepository.GetItem(Index: Integer): TcxEditRepositoryItem;
begin
  Result := TcxEditRepositoryItem(FItems[Index]);
end;

{ TcxEditButtonViewInfo }

procedure TcxEditButtonViewInfo.Assign(Source: TPersistent);
begin
  if Source is TcxEditButtonViewInfo then
    with Source as TcxEditButtonViewInfo do
    begin
      Self.Data.NativeState := Data.NativeState;
      Self.Data.BackgroundColor := Data.BackgroundColor;
      Self.Bounds := Bounds;
      Self.Data.Style := Data.Style;
      Self.Data.State := Data.State;
    end
  else
    inherited Assign(Source);
end;

function TcxEditButtonViewInfo.GetUpdateRegion(AViewInfo: TcxEditButtonViewInfo): TcxRegion;
var
  AEquals: Boolean;
begin
  with AViewInfo do
  begin
    AEquals := Self.Data.Style = Data.Style;
    AEquals := AEquals and (Self.Data.State = Data.State);
    AEquals := AEquals and (Self.Data.BackgroundColor = Data.BackgroundColor);
    AEquals := AEquals and (Self.Data.NativeState = Data.NativeState);
  end;
  if AEquals then
    Result := TcxRegion.Create
  else
    Result := TcxRegion.Create(Bounds);
end;

function TcxEditButtonViewInfo.Repaint(AControl: TWinControl;
  AViewInfo: TcxEditButtonViewInfo; const AEditPosition: TPoint): Boolean;
var
  R: TRect;
begin
  with AViewInfo do
  begin
    Result := Self.Data.Style <> Data.Style;
    Result := Result or (Self.Data.State <> Data.State);
    Result := Result or (Self.Data.BackgroundColor <> Data.BackgroundColor);
    Result := Result or (Self.Data.NativeState <> Data.NativeState);
  end;
  if Result then
  begin
    R := Bounds;
    OffsetRect(R, AEditPosition.X, AEditPosition.Y);
    InternalInvalidate(AControl.Handle, R, cxEmptyRect, HasBackground);
  end;
end;

{ TcxEditButton }

constructor TcxEditButton.Create(Collection: TCollection);
begin
  Collection.BeginUpdate;
  try
    inherited Create(Collection);
    FContentAlignment := taCenter;
    FEnabled := True;
    FKind := bkDown;
    FStretchable := True;
    FTextColor := clBtnText;
    FVisible := True;
  finally
    Collection.EndUpdate;
  end;
end;

destructor TcxEditButton.Destroy;
begin
  if FGlyph <> nil then
    FreeAndNil(FGlyph);
  inherited Destroy;
end;

procedure TcxEditButton.Assign(Source: TPersistent);
begin
  if Source is TcxEditButton then
  begin
    if Assigned(Collection) then Collection.BeginUpdate;
    try
      with Source as TcxEditButton do
      begin
        Self.Caption := Caption;
        Self.FVisibleCaption := FVisibleCaption;
        Self.ContentAlignment := ContentAlignment;
        Self.Default := Default;
        Self.Enabled := Enabled;
        Self.Glyph := Glyph;
        Self.Kind := Kind;
        Self.LeftAlignment := LeftAlignment;
        Self.Stretchable := Stretchable;
        Self.Tag := Tag;
        Self.TextColor := TextColor;
        Self.Visible := Visible;
        Self.Width := Width;
        Self.Hint := Hint;
      end
    finally
      if Assigned(Collection) then Collection.EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxEditButton.GetGlyph: TBitmap;
begin
  if FGlyph = nil then
    FGlyph := TBitmap.Create;
  FGlyph.OnChange := GlyphChanged;
  Result := FGlyph;
end;

procedure TcxEditButton.GlyphChanged(Sender: TObject);
begin
  Changed(False);
end;

function TcxEditButton.IsTagStored: Boolean;
begin
  Result := Tag <> 0;
end;

procedure TcxEditButton.SetCaption(const Value: TCaption);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    FVisibleCaption := RemoveAccelChars(FCaption);
    Changed(False);
  end;
end;

procedure TcxEditButton.SetContentAlignment(Value: TAlignment);
begin
  if Value <> FContentAlignment then
  begin
    FContentAlignment := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetDefault(Value: Boolean);
var
  I: Integer;
begin
  if FDefault <> Value then
  begin
    if Value and Assigned(Collection) and (Collection is TcxEditButtons) then
      with Collection as TcxEditButtons do
        for I := 0 to Count - 1 do
          Items[I].FDefault := False;
    FDefault := Value;
    Changed(True);
  end;
end;

procedure TcxEditButton.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetGlyph(Value: TBitmap);
begin
  if Value <> nil then
    Glyph.Assign(Value)
  else
    if FGlyph <> nil then
      FreeAndNil(FGlyph);
  Changed(False);
end;

procedure TcxEditButton.SetKind(Value: TcxEditButtonKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetLeftAlignment(Value: Boolean);
begin
  if FLeftAlignment <> Value then
  begin
    FLeftAlignment := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetStretchable(Value: Boolean);
begin
  if Value <> FStretchable then
  begin
    FStretchable := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetTextColor(Value: TColor);
begin
  if Value <> FTextColor then
  begin
    FTextColor := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;

procedure TcxEditButton.SetWidth(Value: Integer);
begin
  if (FWidth >= 0) and (FWidth <> Value) then
  begin
    FWidth := Value;
    Changed(False);
  end;
end;

{ TcxEditButtons }

constructor TcxEditButtons.Create(AOwner: TPersistent;
  AButtonClass: TcxEditButtonClass);
begin
  FOwner := AOwner;
  inherited Create(AButtonClass);
end;

function TcxEditButtons.Add: TcxEditButton;
begin
  Result := TcxEditButton(inherited Add);
end;

class function TcxEditButtons.GetButtonClass: TcxEditButtonClass;
begin
  Result := TcxEditButton;
end;

function TcxEditButtons.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxEditButtons.Update(Item: TCollectionItem);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TcxEditButtons.GetItem(Index: Integer): TcxEditButton;
begin
  Result := TcxEditButton(inherited GetItem(Index));
end;

function TcxEditButtons.GetVisibleCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Items[I].Visible then
      Inc(Result);
end;

procedure TcxEditButtons.SetItem(Index: Integer; Value: TcxEditButton);
begin
  inherited SetItem(Index, Value);
end;

{ TcxCustomEditViewInfo }

constructor TcxCustomEditViewInfo.Create;
begin
  inherited Create;
  PressedButton := -1;
  SelectedButton := -1;
end;

destructor TcxCustomEditViewInfo.Destroy;
begin
  SetButtonCount(0);
  inherited Destroy;
end;

procedure TcxCustomEditViewInfo.Assign(Source: TObject);
var
  I: Integer;
begin
  if Source is TcxCustomEditViewInfo then
    with Source as TcxCustomEditViewInfo do
    begin
      Self.BackgroundColor := BackgroundColor;
      Self.BorderColor := BorderColor;
      Self.BorderStyle := BorderStyle;
      Self.ContainerState := ContainerState;
      Self.NativeState := NativeState;
      Self.SetButtonCount(Length(ButtonsInfo));
      for I := 0 to Length(ButtonsInfo) - 1 do
        Self.ButtonsInfo[I].Assign(ButtonsInfo[I]);
      Self.PressedButton := PressedButton;
      Self.SelectedButton := SelectedButton;
    end;
  inherited Assign(Source);
end;

function TcxCustomEditViewInfo.GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion;
var
  I: Integer;
  AEquals: Boolean;
  ATempRgn: TcxRegion;
begin
  Result := inherited GetUpdateRegion(AViewInfo);
  if not(AViewInfo is TcxCustomEditViewInfo) then
    Exit;
  with TcxCustomEditViewInfo(AViewInfo) do
  begin
    AEquals := (Self.BorderColor = BorderColor) or (Self.BorderStyle = ebsNone);
    AEquals := AEquals and (Self.BorderStyle = BorderStyle);
    AEquals := AEquals and (Length(Self.ButtonsInfo) = Length(ButtonsInfo));
    AEquals := AEquals and (Self.NativeState = NativeState);
    if not AEquals then
    begin
      if not IsRectEmpty(Self.Bounds) then
      begin
        ATempRgn := TcxRegion.Create(Self.Bounds);
        UniteRegions(Result, ATempRgn);
        ATempRgn.Free;
      end;
      Exit;
    end;
    for I := 0 to Length(Self.ButtonsInfo) - 1 do
    begin
      ATempRgn := Self.ButtonsInfo[I].GetUpdateRegion(ButtonsInfo[I]);
      if not IsRegionEmpty(ATempRgn) then
        UniteRegions(Result, ATempRgn);
      ATempRgn.Free;
    end;
  end;
end;

procedure TcxCustomEditViewInfo.Offset(DX, DY: Integer);
var
  I: Integer;
begin
  inherited Offset(DX, DY);
  OffsetRect(InnerEditRect, DX, DY);
  OffsetRect(ShadowRect, DX, DY);
  for I := 0 to Length(ButtonsInfo) - 1 do
    with ButtonsInfo[I] do
    begin
      OffsetRect(Bounds, DX, DY);
      OffsetRect(VisibleBounds, DX, DY);
    end;
end;

function TcxCustomEditViewInfo.DrawBackground(ACanvas: TcxCanvas): Boolean;
begin
  Result := IsInplace and DoDrawBackground(ACanvas);
end;

function TcxCustomEditViewInfo.DrawBackground(ACanvas: TcxCanvas;
  const APos: TPoint): Boolean;
var
  APrevWindowOrg: TPoint;
begin
  APrevWindowOrg := ACanvas.WindowOrg;
  ACanvas.WindowOrg := Point(APrevWindowOrg.X + APos.X, APrevWindowOrg.Y + APos.Y);
  try
    Result := DrawBackground(ACanvas);
  finally
    ACanvas.WindowOrg := APrevWindowOrg;
  end;
end;

procedure TcxCustomEditViewInfo.DrawButton(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer);
var
  APrevClipRegion: TcxRegion;
  AButtonViewInfo: TcxEditButtonViewInfo;
begin
  AButtonViewInfo := ButtonsInfo[AButtonVisibleIndex];
  AButtonViewInfo.Data.BackgroundColor := BackgroundColor;
  if not IsRectEmpty(AButtonViewInfo.VisibleBounds) then
  begin
    APrevClipRegion := nil;
    try
      if (AButtonViewInfo.Bounds.Left < BorderRect.Left) or
        (AButtonViewInfo.Bounds.Right > BorderRect.Right) or
        (AButtonViewInfo.Bounds.Top < BorderRect.Top) or
        (AButtonViewInfo.Bounds.Bottom > BorderRect.Bottom) then
      begin
        APrevClipRegion := ACanvas.GetClipRegion;
        ACanvas.IntersectClipRect(AButtonViewInfo.VisibleBounds);
      end;
      if not DoDrawButton(ACanvas, AButtonVisibleIndex) then
        DrawEditButton(ACanvas, AButtonVisibleIndex);
    finally
      if APrevClipRegion <> nil then
        ACanvas.SetClipRegion(APrevClipRegion, roSet);
    end;
  end;
end;

procedure TcxCustomEditViewInfo.DrawButtons(ACanvas: TcxCanvas);
var
  I: Integer;
begin
  if (evsPaintButtons in FState) or ((Edit <> nil) and (Edit.IsButtonDC(ACanvas.Handle))) then
    Exit;
  Include(FState, evsPaintButtons);
  try
    for I := 0 to Length(ButtonsInfo) - 1 do
      DrawButton(ACanvas, I);
  finally
    Exclude(FState, evsPaintButtons)
  end;
end;

procedure TcxCustomEditViewInfo.DrawEditBackground(ACanvas: TcxCanvas; ARect, AGlyphRect: TRect; AGlyphTransparent: Boolean);
begin
  ACanvas.SaveDC;
  try
    if not AGlyphTransparent then
      ACanvas.SetClipRegion(TcxRegion.Create(AGlyphRect), roSubtract);
    case GetDrawBackgroundStyle of
      dbsSimpleParent: cxDrawTransparentControlBackground(Edit, ACanvas, ARect);
      dbsThemeParent: cxDrawThemeParentBackground(Edit, ACanvas, ARect);
      dbsCustomEdit: DrawCustomEdit(ACanvas, Self, True, bpsSolid);
      dbsCustom:
        begin
          ACanvas.SetClipRegion(TcxRegion.Create(ARect), roIntersect);
          DrawBackground(ACanvas);
        end;
      dbsSimpleFill: cxEditFillRect(ACanvas, ARect, BackgroundColor);
    end;
  finally
    ACanvas.RestoreDC;
  end;
end;

procedure TcxCustomEditViewInfo.DrawButtonBackground(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer; const ARect: TRect; ABrushColor: TColor);
begin
  if not DoDrawButtonBackground(ACanvas, ARect, AButtonVisibleIndex) then
    if ButtonsInfo[AButtonVisibleIndex].Data.NativeStyle then
      DrawNativeButtonBackground(ACanvas, ButtonsInfo[AButtonVisibleIndex], ARect)
    else
      DrawUsualButtonBackground(ACanvas, ButtonsInfo[AButtonVisibleIndex], ARect, ABrushColor);
end;

procedure TcxCustomEditViewInfo.DrawButtonBorderByPainter(
  AButtonViewInfo: TcxEditButtonViewInfo; var ARect: TRect; out AContentRect: TRect;
  var APenColor, ABrushColor: TColor);
const
  ButtonColorsMap: array[Boolean] of TColor = (clWindow, clBtnFace);
begin
  AContentRect := ARect;
  GetColorSettingsByPainter(ABrushColor, APenColor);
  if ABrushColor = clDefault then
  begin
    if Edit = nil then
      ABrushColor := ButtonColorsMap[AButtonViewInfo.Data.State = ebsDisabled]
    else
      ABrushColor := FEdit.ActiveStyle.Color;
  end;
  if APenColor = clDefault then
    APenColor := clBtnText;
end;

procedure TcxCustomEditViewInfo.DrawButtonBorder(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer; var ARect: TRect; out AContentRect: TRect;
  var APenColor, ABrushColor: TColor);
var
  AButtonStyle: TcxEditButtonStyle;
  AButtonViewInfo: TcxEditButtonViewInfo;
begin
  AButtonViewInfo := ButtonsInfo[AButtonVisibleIndex];
  if DoDrawButtonBorder(ACanvas, AButtonVisibleIndex, ARect, AContentRect) then
    Exit;
    
  if AButtonViewInfo.Data.NativeState <> TC_NONE then
    DrawNativeButtonBorder(ACanvas, AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor)
  else
    if Painter <> nil then
      DrawButtonBorderByPainter(AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor)
    else
    begin
      AButtonStyle := AButtonViewInfo.Data.Style;
      if (AButtonViewInfo.Data.State in [ebsPressed, ebsSelected]) and (AButtonStyle = btsSimple) then
        AButtonStyle := btsFlat;
      case AButtonStyle of
        bts3D:
          Draw3DButtonBorder(ACanvas, AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor);
        btsFlat:
          DrawFlatButtonBorder(ACanvas, AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor);
        btsSimple:
          DrawSimpleButtonBorder(ACanvas, AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor);
        btsHotFlat:
          DrawHotFlatButtonBorder(ACanvas, AButtonViewInfo, ARect, AContentRect, APenColor, ABrushColor);
        btsUltraFlat, btsOffice11:
          DrawUltraFlatButtonBorder(ACanvas, AButtonViewInfo, AButtonStyle = btsOffice11, ARect, AContentRect, APenColor, ABrushColor);
      end;
    end;
end;

procedure TcxCustomEditViewInfo.DrawButtonContent(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer; const AContentRect: TRect;
  APenColor, ABrushColor: TColor; ANeedOffsetContent: Boolean);
const
  EditBtnKind2EditBtnPainterKind: array [TcxEditButtonKind] of TcxEditBtnKind =
      (cxbkEllipsisBtn, cxbkComboBtn, cxbkEditorBtn, cxbkEditorBtn);

var
  AButtonViewInfo: TcxEditButtonViewInfo;

  procedure GetContentPosition(const AContentSize: TSize; out X, Y: Integer;
    AOffsetContent: Boolean);
  var
    AHorzSpace, AVertSpace: Integer;
  begin
    AHorzSpace := cxRectWidth(AContentRect) - AContentSize.cx;
    AVertSpace := cxRectHeight(AContentRect) - AContentSize.cy;
    X := AContentRect.Left + AHorzSpace div 2;
    Y := AContentRect.Top + AVertSpace div 2;
    if AOffsetContent then
    begin
      if X + AContentSize.cx < AContentRect.Right then
        Inc(X);
      if Y + AContentSize.cy < AContentRect.Bottom then
        Inc(Y);
    end;
  end;

  procedure DrawArrowButtonContent;

    procedure DrawArrow(const R: TRect; AColor: TColor);
    var
      ALookAndFeelPainter: TcxCustomLookAndFeelPainterClass; // for CLR
    begin
      ALookAndFeelPainter := TcxStandardLookAndFeelPainter;
      ALookAndFeelPainter.DrawArrow(ACanvas, R, adDown, AColor);
    end;

  var
    AButtonHeight, AButtonWidth: Integer;
    R: TRect;
  begin
    AButtonWidth := cxRectWidth(AButtonViewInfo.Bounds) - cxRectWidth(AContentRect);
    R := AContentRect;
    if not Odd(AButtonWidth) then
    begin
      Dec(R.Left, AButtonWidth div 2);
      Inc(R.Right, AButtonWidth div 2);
      if ANeedOffsetContent then
        OffsetRect(R, 1, 0);
    end
    else
      if not ANeedOffsetContent then
      begin
        Inc(R.Right, AButtonWidth div 2);
        Dec(R.Left, AButtonWidth - AButtonWidth div 2);
      end else
      begin
        Dec(R.Left, AButtonWidth div 2);
        Inc(R.Right, AButtonWidth - AButtonWidth div 2);
      end;
    if ANeedOffsetContent then
      OffsetRect(R, 0, 1);

    if IsInplace then
    begin
      AButtonHeight := AButtonViewInfo.Bounds.Bottom - AButtonViewInfo.Bounds.Top;
      Dec(AButtonHeight, AContentRect.Bottom - AContentRect.Top);
      if not Odd(AButtonHeight) then
      begin
        Dec(R.Top, AButtonHeight div 2);
        Inc(R.Bottom, AButtonHeight div 2);
      end
      else
        if not ANeedOffsetContent then
        begin
          Inc(R.Bottom, AButtonHeight div 2);
          Dec(R.Top, AButtonHeight - AButtonHeight div 2);
        end else
        begin
          Dec(R.Top, AButtonHeight div 2);
          Inc(R.Bottom, AButtonHeight - AButtonHeight div 2);
        end;
    end;

    if AButtonViewInfo.Data.State <> ebsDisabled then
      DrawArrow(R, APenColor)
    else
    begin
      DrawArrow(cxRectOffset(R, 1, 1), clBtnHighlight);
      DrawArrow(R, clBtnShadow);
    end;
  end;

  procedure DrawEllipsisButtonContent;

    procedure DrawEllipsis(X, Y, ASize: Integer; AColor: TColor);
    var
      ABrush: TBrushHandle;
    begin
      ABrush := GetSolidBrush(ACanvas, AColor);
      cxEditFillRect(ACanvas.Handle, Rect(X, Y, X + ASize, Y + ASize), ABrush);
      cxEditFillRect(ACanvas.Handle, Rect(X + ASize + 2, Y, X + ASize * 2 + 2, Y + ASize), ABrush);
      cxEditFillRect(ACanvas.Handle, Rect(X + ASize * 2 + 4, Y, X + ASize * 3 + 4, Y + ASize), ABrush);
    end;

  var
    X, Y: Integer;
    AContentSize: TSize;
  begin
    if AContentRect.Right - AContentRect.Left < 12 then
      AContentSize.cy := 1
    else
      AContentSize.cy := 2;
    AContentSize.cx := AContentSize.cy * 3 + 4;
    GetContentPosition(AContentSize, X, Y, ANeedOffsetContent);
    if AButtonViewInfo.Data.State <> ebsDisabled then
      DrawEllipsis(X, Y, AContentSize.cy, APenColor)
    else
    begin
      DrawEllipsis(X + 1, Y + 1, AContentSize.cy, clBtnHighlight);
      DrawEllipsis(X, Y, AContentSize.cy, clBtnShadow);
    end;
  end;

  procedure DrawGlyphButtonContent;
  var
    AGlyph: TBitmap;
    AContentSize: TSize;
    AGlyphPosition: TPoint;
  begin
    AGlyph := AButtonViewInfo.Glyph;
    if not VerifyBitmap(AGlyph) then
      Exit;

    AContentSize.cx := Min(cxRectWidth(AContentRect), AGlyph.Width);
    AContentSize.cy := Min(cxRectHeight(AContentRect), AGlyph.Height);
    GetContentPosition(AContentSize, AGlyphPosition.X, AGlyphPosition.Y, ANeedOffsetContent);

    DrawGlyph(ACanvas, AGlyphPosition.X, AGlyphPosition.Y, AGlyph, AButtonViewInfo.Data.State <> ebsDisabled, clNone);
  end;

  procedure DrawTextButtonContent;

    procedure DrawText(const R: TRect; AColor: TColor);
    begin
      ACanvas.Font.Color := AColor;
      ACanvas.DrawText(AButtonViewInfo.Data.Caption, R, cxAlignmentsHorz[AButtonViewInfo.Data.ContentAlignment] or
        cxAlignVCenter or cxSingleLine or cxShowPrefix or cxShowEndEllipsis);
    end;

  var
    R: TRect;
    AColor: TColor;
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font := Font;

    R := AContentRect;
    if not IsInplace then
      InflateRect(R, -1, -1)
    else
      InflateRect(R, -1, 0);
    Dec(R.Right);
    if AButtonViewInfo.Data.State = ebsDisabled then
    begin
      DrawText(cxRectOffset(R, 1, 1), clBtnHighlight);
      DrawText(R, clBtnShadow);
    end
    else
    begin
      if (AButtonViewInfo.Data.Style = btsHotFlat) and (AButtonViewInfo.Data.State in [ebsPressed, ebsSelected]) then
        AColor := APenColor
      else
        if AButtonViewInfo.Data.TextColor = clDefault then
          AColor := TextColor
        else
          AColor := AButtonViewInfo.Data.TextColor;

      if ANeedOffsetContent then
        OffsetRect(R, 1, 1);
      DrawText(R, AColor);
    end;
    ACanvas.Brush.Style := bsSolid;
  end;

var
  AKind: TcxEditBtnKind;

begin
  ACanvas.SaveState;
  try
    ACanvas.SetClipRegion(TcxRegion.Create(AContentRect), roIntersect);

    AButtonViewInfo := ButtonsInfo[AButtonVisibleIndex];
    if Painter <> nil then
    begin
      AKind := EditBtnKind2EditBtnPainterKind[AButtonViewInfo.Data.Kind];
      Painter.DrawEditorButton(ACanvas, AContentRect, AKind,
        EditBtnState2ButtonState[AButtonViewInfo.Data.State]);
      case AButtonViewInfo.Data.Kind of
        bkText:
          DrawTextButtonContent;
        bkGlyph:
          DrawGlyphButtonContent;
      end;
    end
    else
      case AButtonViewInfo.Data.Kind of
        bkDown:
          DrawArrowButtonContent;
        bkEllipsis:
          DrawEllipsisButtonContent;
        bkGlyph:
          DrawGlyphButtonContent;
        bkText:
          DrawTextButtonContent;
      end;
  finally
    ACanvas.RestoreState;
  end;
end;

procedure TcxCustomEditViewInfo.DrawNativeStyleEditBackground(ACanvas: TcxCanvas; ADrawBackground: Boolean;
  ABackgroundStyle: TcxEditBackgroundPaintingStyle; ABackgroundBrush: TBrushHandle);

  procedure CalculateNativeInfo(out AThemedObjectType: TdxThemedObjectType; out ANativePart: Integer; out ABoundsRect: TRect);
  begin
    ABoundsRect := Bounds;
    AThemedObjectType := totEdit;
    if IsCompositionEnabled then
    begin
      if ABackgroundStyle = bpsComboListEdit then
      begin
        AThemedObjectType := totButton;
        ANativePart := BP_PUSHBUTTON;
        ABoundsRect := cxRectInflate(ABoundsRect, 1, 1);
      end
      else
        ANativePart := EP_EDITBORDER_NOSCROLL
    end
    else
      ANativePart := EP_EDITTEXT;
  end;

  function GetContentRect(ATheme: TdxTheme; ANativePart: Integer; const ABoundsRect: TRect): TRect;
  begin
    case ABackgroundStyle of
      bpsSolid:
        if IsCompositionEnabled then
          Result := cxRectInflate(ABoundsRect, -2, -2)
        else
          GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, ANativePart,
            NativeState, ABoundsRect, Result);
      bpsComboEdit:
        begin
          Result := cxRectInflate(ABoundsRect, -(cxEditMaxBorderWidth + 1),
            -(cxEditMaxBorderWidth + 1));
          Result.Right := Result.Right - 1;
        end;
      bpsComboListEdit:
        if IsCompositionEnabled then
          Result := cxEmptyRect
        else
          Result := ClientRect;
    end;
  end;

  procedure DrawBorder(ATheme: TdxTheme; ANativePart: Integer; const ABoundsRect, AContentRect: TRect);
  begin
    ACanvas.SaveClipRegion;
    try
      ACanvas.ExcludeClipRect(AContentRect);
      if IsThemeBackgroundPartiallyTransparent(ATheme, ANativePart, NativeState) and (Edit <> nil) then
        cxDrawThemeParentBackground(Edit, ACanvas, ABoundsRect);
      DrawThemeBackground(ATheme, ACanvas.Handle, ANativePart, NativeState, ABoundsRect);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;

  procedure DrawBackground(const AContentRect: TRect);
  begin
    if ADrawBackground or IsInplace or (BorderStyle = ebsNone) then
      cxEditFillRect(ACanvas.Handle, AContentRect, ABackgroundBrush)
    else
      if ABackgroundStyle <> bpsComboListEdit then
        InternalFillRect(ACanvas, AContentRect, BorderRect, ABackgroundBrush);
  end;

var
  AContentRect: TRect;
  ATheme: TdxTheme;
  AThemedObjectType: TdxThemedObjectType;
  ABoundsRect: TRect;
  ANativePart: Integer;
begin
  if IsInplace or (BorderStyle = ebsNone) then
    AContentRect := Bounds
  else
  begin
    CalculateNativeInfo(AThemedObjectType, ANativePart, ABoundsRect);
    ATheme := OpenTheme(AThemedObjectType);
    AContentRect := GetContentRect(ATheme, ANativePart, ABoundsRect);

    DrawBorder(ATheme, ANativePart, ABoundsRect, AContentRect);
  end;

  if not Transparent then
    DrawBackground(AContentRect);
end;

function TcxCustomEditViewInfo.IsBackgroundTransparent: Boolean;
begin
  Result := not (GetDrawBackgroundStyle in [dbsCustomEdit, dbsSimpleFill]);
end;

function TcxCustomEditViewInfo.IsCustomBackground: Boolean;
begin
  Result := DrawBackground(nil);
end;

function TcxCustomEditViewInfo.IsCustomButton(AButtonVisibleIndex: Integer = 0): Boolean;
begin
  Result := DoDrawButton(nil, AButtonVisibleIndex);
end;

function TcxCustomEditViewInfo.IsCustomButtonBackground(AButtonVisibleIndex: Integer = 0): Boolean;
begin
  Result := DoDrawButtonBackground(nil, cxEmptyRect, AButtonVisibleIndex);
end;

function TcxCustomEditViewInfo.IsCustomButtonBorder(AButtonVisibleIndex: Integer = 0): Boolean;
var
  ARect: TRect;
begin
  Result := DoDrawButtonBorder(nil, AButtonVisibleIndex, ARect, ARect);
end;

function TcxCustomEditViewInfo.IsCustomDrawButton(AButtonVisibleIndex: Integer = 0): Boolean;
begin
  Result := IsCustomButtonBorder(AButtonVisibleIndex) or IsCustomButtonBackground(AButtonVisibleIndex) or IsCustomButton(AButtonVisibleIndex);
end;

function TcxCustomEditViewInfo.IsHotTrack: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(ButtonsInfo) - 1 do
    if ButtonsInfo[I].Data.State = ebsSelected then
    begin
      Result := True;
      Break;
    end;
end;

function TcxCustomEditViewInfo.IsHotTrack(P: TPoint): Boolean;
var
  I: Integer;
begin
  Result := False;
  Dec(P.X, Left);
  Dec(P.Y, Top);
  for I := 0 to Length(ButtonsInfo) - 1 do
    if PtInRect(ButtonsInfo[I].Bounds, P) then
    begin
      Result := True;
      Break;
    end;
end;

function TcxCustomEditViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; out AText: TCaption; out AIsMultiLine: Boolean;
  out ATextRect: TRect): Boolean;
begin
  Result := NeedShowHint(ACanvas, P, cxEmptyRect, AText, AIsMultiLine, ATextRect);
end;

function TcxCustomEditViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; const AVisibleBounds: TRect; out AText: TCaption;
  out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean;
var
  APart: Integer;
begin
  Result := False;
  APart := GetPart(P);
  if APart >= ecpButton then
  begin
    AText := GetShortHint(GetHintText(APart));
    AIsMultiLine := False;
    ATextRect := GetHintTextRect(P, APart);
    Result := Length(AText) > 0;
  end;
end;

procedure TcxCustomEditViewInfo.Paint(ACanvas: TcxCanvas);
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self, ACanvas);
  inherited;
end;

procedure TcxCustomEditViewInfo.PaintEx(ACanvas: TcxCanvas);
var
  P: TPoint;
  ACanvasHandle: HDC;
begin
  ACanvasHandle := ACanvas.Handle;
  GetWindowOrgEx(ACanvasHandle, P);
  Dec(P.X, Left);
  Dec(P.Y, Top);
  SetWindowOrgEx(ACanvasHandle, P.X, P.Y, @P);
  try
    Paint(ACanvas);
  finally
    SetWindowOrgEx(ACanvasHandle, P.X, P.Y, nil);
  end;
end;

procedure TcxCustomEditViewInfo.PrepareCanvasFont(ACanvas: TCanvas);
begin
end;

function TcxCustomEditViewInfo.Repaint(AControl: TWinControl;
  AViewInfo: TcxContainerViewInfo = nil): Boolean;
begin
  Result := Repaint(AControl, cxEmptyRect, AViewInfo);
end;

function TcxCustomEditViewInfo.Repaint(AControl: TWinControl;
  const AInnerEditRect: TRect; AViewInfo: TcxContainerViewInfo = nil): Boolean;

  procedure CheckRect(var R: TRect);
  begin
    with ClientRect do
    begin
      if R.Left < Left then R.Left := Left;
      if R.Top < Top then R.Top := Top;
      if R.Right > Right then R.Right := Right;
      if R.Bottom > Bottom then R.Bottom := Bottom;
    end;
  end;

  function GetInnerEditRect: TRect;
  begin
    Result := AInnerEditRect;
    CheckRect(Result);
  end;

  function RepaintButtons: Boolean;
  var
    I: Integer;
    AEditPosition: TPoint;
  begin
    Result := False;
    AEditPosition := Point(Left, Top);
    with TcxCustomEditViewInfo(AViewInfo) do
      for I := 0 to Length(Self.ButtonsInfo) - 1 do
        if Self.ButtonsInfo[I].Repaint(AControl, ButtonsInfo[I], AEditPosition) then
          Result := True;
  end;

var
  R, R1: TRect;
begin
  Result := AControl.HandleAllocated;
  if not Result then
    Exit;

  R := Bounds;
  OffsetRect(R, Left, Top);
  Result := AViewInfo <> nil;
  if not Result then
  begin
    InternalInvalidate(AControl.Handle, R, GetInnerEditRect, HasBackground);
    Exit;
  end;
  with TcxCustomEditViewInfo(AViewInfo) do
  begin
    while True do
    begin
      if (Self.NativeState <> NativeState) or
        (Self.BackgroundColor <> BackgroundColor) or
        (Self.ContainerState <> ContainerState) and Self.IsRepaintOnStateChangingNeeded then
      begin
        R1 := GetInnerEditRect;
        Break;
      end;
      if Length(Self.ButtonsInfo) <> Length(ButtonsInfo) then
      begin
        R1 := GetInnerEditRect;
        Break;
      end;
      if (Self.BorderColor <> BorderColor) and (Self.BorderStyle <> ebsNone) or
        (Self.BorderStyle <> BorderStyle) then
      begin
        R1 := Self.BorderRect;
        OffsetRect(R1, Self.Left, Self.Top);
        Break;
      end;
      Result := False;
      Break;
    end;
    if Result then
      if not IsRectEmpty(Self.Bounds) and not EqualRect(R, R1) then
        InternalInvalidate(AControl.Handle, R, R1, HasBackground);
    if (Length(Self.ButtonsInfo) = Length(ButtonsInfo)) and RepaintButtons then
      Result := True;
  end;
end;

procedure TcxCustomEditViewInfo.SetButtonCount(ACount: Integer);
var
  I: Integer;
  APrevLength: Integer;
begin
  APrevLength := Length(ButtonsInfo);
  if APrevLength <> ACount then
  begin
    if ACount < APrevLength then
    begin
      for I := Length(ButtonsInfo) - 1 downto ACount do
        ButtonsInfo[I].Free;
      SetLength(ButtonsInfo, ACount);
    end else
    begin
      SetLength(ButtonsInfo, ACount);
      for I := APrevLength to ACount - 1 do
        ButtonsInfo[I] := GetButtonViewInfoClass.Create;
    end;
  end;
end;

function TcxCustomEditViewInfo.GetButtonViewInfoClass: TcxEditButtonViewInfoClass;
begin
  Result := TcxEditButtonViewInfo;
end;

procedure TcxCustomEditViewInfo.GetColorSettingsByPainter(
  out ABackground, ATextColor: TColor);
begin
  ABackground := clDefault;
  ATextColor := clDefault;
  if not (IsInplace or (FEdit = nil)) then
    FEdit.GetColorSettingsByPainter(ABackground, ATextColor);
end;

function TcxCustomEditViewInfo.GetContainerBorderStyle: TcxContainerBorderStyle;
begin
  Result := TcxContainerBorderStyle(BorderStyle);
end;

function TcxCustomEditViewInfo.GetPart(const P: TPoint): Integer;
var
  I: Integer;
begin
  if PtInRect(BorderRect, P) then
    Result := ecpControl
  else
    Result := ecpNone;
  for I := Low(ButtonsInfo) to High(ButtonsInfo) do
    if ButtonsInfo[I].Data.State = ebsSelected then
    begin
      Result := ButtonsInfo[I].Index;
      Break;
    end;
end;

function TcxCustomEditViewInfo.GetPartRect(APart: Integer): TRect;
begin
  case APart of
    ecpNone:
      Result := cxNullRect;
    ecpControl:
      begin
        Result := BorderRect;
        if Length(ButtonsInfo) > 0 then
          Result.Right := ButtonsInfo[0].Bounds.Left;
      end;
    else
      if (APart >= ecpButton) and (APart < Length(ButtonsInfo)) then
        Result := ButtonsInfo[APart].Bounds
      else
        Result := cxNullRect;
  end;
end;

procedure TcxCustomEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  DrawCustomEdit(ACanvas, Self, True, bpsSolid);
end;

function TcxCustomEditViewInfo.IsRepaintOnStateChangingNeeded: Boolean;
begin
  Result := True;
end;

procedure TcxCustomEditViewInfo.DrawEditButton(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer);

  function NeedDoubleBuffered: Boolean;
  begin
    Result := (ButtonsInfo[AButtonVisibleIndex].Data.Kind = bkGlyph) and
      VerifyBitmap(ButtonsInfo[AButtonVisibleIndex].Glyph) or (Painter <> nil);
  end;

  function NeedOffsetContent: Boolean;
  begin
    Result := (ButtonsInfo[AButtonVisibleIndex].Data.State = ebsPressed) and
      ((Edit = nil) or (ecoOffsetButtonContent in Edit.ContentParams.Options)); // to support the solution in B782
  end;

var
  ABoundsRect, AContentRect, ABackgroundRect: TRect;
  APenColor, ABrushColor: TColor;

  ATempCanvas: TcxCanvas;
  ABackgroundBitmap: TBitmap;
begin
  APenColor := clBtnText;
  ABrushColor := 0;
  ABoundsRect := ButtonsInfo[AButtonVisibleIndex].Bounds;

  ATempCanvas := TcxCanvas.Create(nil);
  if NeedDoubleBuffered then
  begin
    ABackgroundBitmap := TBitmap.Create;
    ABackgroundBitmap.Width := cxRectWidth(ABoundsRect);
    ABackgroundBitmap.Height := cxRectHeight(ABoundsRect);

    ATempCanvas.Canvas := ABackgroundBitmap.Canvas;
    ATempCanvas.WindowOrg := ABoundsRect.TopLeft;
  end
  else
  begin
    ABackgroundBitmap := nil;
    ATempCanvas.Canvas := ACanvas.Canvas;
  end;

  try
    ABackgroundRect := ABoundsRect;
    DrawButtonBorder(ATempCanvas, AButtonVisibleIndex, ABackgroundRect, AContentRect, APenColor, ABrushColor);

    if not IsRectEmpty(ABackgroundRect) then
      DrawButtonBackground(ATempCanvas, AButtonVisibleIndex, ABackgroundRect, ABrushColor);
    if not IsRectEmpty(AContentRect) then
      DrawButtonContent(ATempCanvas, AButtonVisibleIndex, AContentRect, APenColor, ABrushColor, NeedOffsetContent);
  finally
    if ABackgroundBitmap <> nil then
    begin
      ATempCanvas.WindowOrg := cxNullPoint;
      ACanvas.Draw(ABoundsRect.Left, ABoundsRect.Top, ABackgroundBitmap);
      ABackgroundBitmap.Free;
    end;
    ATempCanvas.Free;
  end;
end;

procedure TcxCustomEditViewInfo.SetOnDrawBackground(AValue: TcxEditDrawBackgroundEvent);
begin
  FOnDrawBackground := AValue;
end;

procedure TcxCustomEditViewInfo.Draw3DButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor);
begin
  if not AButtonViewInfo.Data.Transparent then
    ABrushColor := clBtnFace
  else
    ABrushColor := AButtonViewInfo.Data.BackgroundColor;
  APenColor := clBtnText;

  if AButtonViewInfo.Data.State = ebsPressed then
  begin
    FrameRectEx(ACanvas, ARect, clBtnShadow);
    FrameRectEx(ACanvas, ARect, ABrushColor);
  end else
  begin
    DrawComplexFrameEx(ACanvas, ARect, cl3DLight, cl3DDkShadow);
    DrawComplexFrameEx(ACanvas, ARect, clBtnHighlight, clBtnShadow);
  end;

  AContentRect := ARect;
end;

procedure TcxCustomEditViewInfo.DrawFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor);
begin
  if not AButtonViewInfo.Data.Transparent then
    ABrushColor := clBtnFace
  else
    ABrushColor := AButtonViewInfo.Data.BackgroundColor;

  cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft], ABrushColor);
  if AButtonViewInfo.Data.State = ebsPressed then
    DrawComplexFrameEx(ACanvas, ARect, clBtnShadow, clBtnHighlight)
  else
    DrawComplexFrameEx(ACanvas, ARect, clBtnHighlight, clBtnShadow);
  cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bRight], ABrushColor);
  AContentRect := ARect;
end;

procedure TcxCustomEditViewInfo.DrawHotFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor);
const
  ABrushColorA: array [TcxEditButtonState] of TColor = (
    clBtnFace, clBtnFace, clBtnText, clBtnShadow
  );
begin
  with AButtonViewInfo do
  begin
    ABrushColor := ABrushColorA[Data.State];
    if Data.Transparent then
      ABrushColor := Data.BackgroundColor;

    APenColor := clBtnShadow;
    if (Data.LeftAlignment and Data.Rightmost) or (not Data.LeftAlignment and Data.Leftmost) then
      FrameRectEx(ACanvas, ARect, APenColor)
    else
      if Data.LeftAlignment then
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bBottom, bLeft, bTop], APenColor);
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bRight], ABrushColor);
      end
      else
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bTop, bRight, bBottom], APenColor);
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft], ABrushColor);
      end;

    if Data.State in [ebsPressed, ebsSelected] then
      if Data.Transparent and (Data.State = ebsSelected) then
        APenColor := clBtnShadow
      else
        APenColor := clWindow
    else
      APenColor := clBtnText;
    cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft, bRight], ABrushColor);
    AContentRect := ARect;
  end;
end;

procedure TcxCustomEditViewInfo.DrawNativeButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor);

  function GetThemeContentRect(AThemeObject: TdxThemedObjectType; APart: Integer): TRect;
  var
    ATheme: TdxTheme;
  begin
    ATheme := OpenTheme(AThemeObject);
    GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, APart,
      AButtonViewInfo.Data.NativeState, AButtonViewInfo.Bounds, Result);
  end;

  function GetContentRect: TRect;
  begin
    if IsCustomDrawButton then
      Result := ARect
    else
      if AButtonViewInfo.Data.ComboBoxStyle then
        Result := cxEmptyRect
      else
        Result := GetThemeContentRect(totButton, BP_PUSHBUTTON)
  end;

begin
  AContentRect := GetContentRect;
end;

procedure TcxCustomEditViewInfo.DrawSimpleButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  var ARect: TRect; out AContentRect: TRect; var APenColor, ABrushColor: TColor);
begin
  if not Transparent then
    ACanvas.FrameRect(ARect, AButtonViewInfo.Data.BackgroundColor);
  InflateRect(ARect, -1, -1);
  if not AButtonViewInfo.Data.Transparent then
    ABrushColor := clBtnFace
  else
    ABrushColor := AButtonViewInfo.Data.BackgroundColor;
  cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft, bRight], ABrushColor);
  AContentRect := ARect;
end;

procedure TcxCustomEditViewInfo.DrawUltraFlatButtonBorder(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo;
  AIsOffice11Style: Boolean; var ARect: TRect; var AContentRect: TRect; out APenColor, ABrushColor: TColor);
var
  ABackgroundRect: TRect;
  AHighlightColor: TColor;
begin
  if AButtonViewInfo.Data.Transparent then
    ABrushColor := AButtonViewInfo.Data.BackgroundColor
  else
    if AButtonViewInfo.Data.State = ebsDisabled then
      ABrushColor := clBtnFace
    else
      if AButtonViewInfo.Data.State = ebsNormal then
        if AIsOffice11Style then
          ABrushColor := dxOffice11DockColor1
        else
          ABrushColor := clBtnFace
      else
        ABrushColor := GetEditButtonHighlightColor(
          AButtonViewInfo.Data.State = ebsPressed, AIsOffice11Style);

  AHighlightColor := GetEditBorderHighlightColor(AIsOffice11Style);

  if (AButtonViewInfo.Data.State in [ebsDisabled, ebsNormal]) or
    not AButtonViewInfo.Data.IsInplace and (BorderStyle = ebsNone) or
    AButtonViewInfo.Data.IsInplace and not (epoHasExternalBorder in PaintOptions) then
  begin
      if not(AButtonViewInfo.Data.State in [ebsDisabled, ebsNormal]) then
        ACanvas.FrameRect(ARect, AHighlightColor)
      else
        if not Transparent then
          ACanvas.FrameRect(ARect, AButtonViewInfo.Data.BackgroundColor);
    InflateRect(ARect, -1, -1);
    ABackgroundRect := ARect;
    ExtendRect(ARect, Rect(1, 0, 1, 0));
  end
  else
  begin
    ABackgroundRect := ARect;
    if AButtonViewInfo.Data.LeftAlignment then
    begin
      if AButtonViewInfo.Data.Leftmost then
        Inc(ARect.Left)
      else
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft], AHighlightColor);
        Inc(ABackgroundRect.Left);
      end;
      if ARect.Right = BorderRect.Right then
        Dec(ARect.Right)
      else
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bRight], AHighlightColor);
        Dec(ABackgroundRect.Right);
      end;
    end
    else
    begin
      if AButtonViewInfo.Data.Rightmost then
        Dec(ARect.Right)
      else
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bRight], AHighlightColor);
        Dec(ABackgroundRect.Right);
      end;
      if ARect.Left = BorderRect.Left then
        Inc(ARect.Left)
      else
      begin
        cxEditUtils.DrawButtonBorder(ACanvas, ARect, [bLeft], AHighlightColor);
        Inc(ABackgroundRect.Left);
      end;
    end;
    InflateRect(ARect, -1, -1);
  end;

  AContentRect := ARect;
  ARect := ABackgroundRect;
end;

procedure TcxCustomEditViewInfo.DrawNativeButtonBackground(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo; const ARect: TRect);
var
  APart: Integer;
  AThemeObject: TdxThemedObjectType;
begin
  if AButtonViewInfo.Data.ComboBoxStyle then
  begin
    AThemeObject := totComboBox;
    if IsCompositionEnabled and not IsInplace then
      if AButtonViewInfo.Data.LeftAlignment then
        APart := CP_DROPDOWNBUTTONLEFT
      else
        APart := CP_DROPDOWNBUTTONRIGHT
    else
      APart := CP_DROPDOWNBUTTON;
  end
  else
  begin
    AThemeObject := totButton;
    APart := BP_PUSHBUTTON;
  end;
  DrawThemeBackground(OpenTheme(AThemeObject), ACanvas.Handle, APart, AButtonViewInfo.Data.NativeState, ARect);
end;

procedure TcxCustomEditViewInfo.DrawUsualButtonBackground(ACanvas: TcxCanvas; AButtonViewInfo: TcxEditButtonViewInfo; const ARect: TRect; ABrushColor: TColor);

  procedure GetBackgroundParams(out AGradientDrawing: Boolean;
    out AColor1, AColor2: TColor);
  begin
    AGradientDrawing := (AButtonViewInfo.Data.Style = btsOffice11) and
      AButtonViewInfo.Data.Gradient and not AButtonViewInfo.Data.Transparent and
      (AButtonViewInfo.Data.State <> ebsDisabled) and (Painter = nil);
    if AGradientDrawing then
      case AButtonViewInfo.Data.State of
        ebsNormal:
          begin
            AColor1 := dxOffice11ToolbarsColor1;
            AColor2 := dxOffice11ToolbarsColor2;
          end;
        ebsPressed:
          begin
            AColor1 := dxOffice11SelectedDownColor1;
            AColor2 := dxOffice11SelectedDownColor2;
          end;
        ebsSelected:
          begin
            AColor1 := dxOffice11SelectedColor1;
            AColor2 := dxOffice11SelectedColor2;
          end;
      end;
  end;

var
  AClipRgn: TcxRegion;
  AColor1, AColor2: TColor;
  AGradientDrawing: Boolean;
  R: TRect;
begin
  GetBackgroundParams(AGradientDrawing, AColor1, AColor2);
  if not AGradientDrawing then
    cxEditFillRect(ACanvas.Handle, ARect, GetSolidBrush(ACanvas, ABrushColor))
  else
  begin
    AClipRgn := ACanvas.GetClipRegion;
    try
      R := Rect(ARect.Left, BorderRect.Top, ARect.Right, BorderRect.Bottom);
      if AButtonViewInfo.Data.State = ebsNormal then
        ExtendRect(R, Rect(0, 1, 0, 1));
      ACanvas.SetClipRegion(TcxRegion.Create(ARect), roIntersect);
      FillGradientRect(ACanvas.Handle, R, AColor1, AColor2, False);
    finally
      ACanvas.SetClipRegion(AClipRgn, roSet);
    end;
  end;
end;

function TcxCustomEditViewInfo.DoDrawBackground(ACanvas: TcxCanvas): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawBackground) then
    FOnDrawBackground(Self, ACanvas, Result);
end;

function TcxCustomEditViewInfo.DoDrawButton(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawButton) then
    FOnDrawButton(Self, ACanvas, AButtonVisibleIndex, Result);
end;

function TcxCustomEditViewInfo.DoDrawButtonBackground(ACanvas: TcxCanvas;
  const ARect: TRect; AButtonVisibleIndex: Integer): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawButtonBackground) then
    FOnDrawButtonBackground(Self, ACanvas, ARect, AButtonVisibleIndex, Result);
end;

function TcxCustomEditViewInfo.DoDrawButtonBorder(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer;
  out ABackgroundRect, AContentRect: TRect): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawButtonBorder) then
    FOnDrawButtonBorder(Self, ACanvas, AButtonVisibleIndex, ABackgroundRect, AContentRect, Result);
end;

function TcxCustomEditViewInfo.GetDrawBackgroundStyle: TcxDrawBackgroundStyle;
begin
  Result := dbsSimpleFill;
  if IsInplace then
  begin
    if IsCustomBackground then
      Result := dbsCustom
    else
      if IsTransparent then
        Result := dbsNone
  end
  else
  begin
    if IsTransparent then
      Result := dbsSimpleParent
    else
      if IsNativeBackground then
        Result := dbsThemeParent
      else
        if not NativeStyle then
          Result := dbsCustomEdit;
  end;
end;

function TcxCustomEditViewInfo.IsNativeBackground: Boolean;
begin
  Result := (Edit <> nil) and TcxCustomEdit(Edit).IsNativeBackground;
end;

function TcxCustomEditViewInfo.IsTransparent: Boolean;
begin
  Result := Transparent or (Edit <> nil) and TcxCustomEdit(Edit).Transparent;
end;

function TcxCustomEditViewInfo.GetHintText(APart: Integer): string;
begin
  if (APart >= ecpButton) and (APart < EditProperties.Buttons.Count) then
    Result := EditProperties.Buttons[APart].Hint
  else
    Result := '';
end;

function TcxCustomEditViewInfo.GetHintTextRect(const P: TPoint;
  APart: Integer): TRect;
var
  AHintWindow: THintWindow;
begin
  AHintWindow := THintWindow.Create(nil);
  try
    Result := AHintWindow.CalcHintRect(Screen.Width, GetHintText(APart), nil);
    OffsetRect(Result, P.X, P.Y + cxGetCursorSize.cy);
  finally
    FreeAndNil(AHintWindow);
  end;
end;

{ TcxCustomEditViewData }

constructor TcxCustomEditViewData.Create(AProperties: TcxCustomEditProperties;
  AStyle: TcxCustomEditStyle; AIsInplace: Boolean);
begin
  inherited Create;
  FIsInplace := AIsInplace;
  FProperties := AProperties;
  FStyle := AStyle;
  Initialize;
  SelTextColor := clDefault;
  SelBackgroundColor := clDefault;
  InitCacheData;
end;

procedure TcxCustomEditViewData.Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);

  procedure CalculateContainerState;
  begin
    AViewInfo.ContainerState := GetContainerState(ABounds, P, Button, Shift, AIsMouseEvent);

    Selected := ContainerState * [csActive, csHotTrack] <> [];
    if IsDesigning or not Style.HotTrack or IsInplace then
      AViewInfo.HotState := chsNoHotTrack
    else
      if Selected then
        AViewInfo.HotState := chsSelected
      else
        AViewInfo.HotState := chsNormal;
    if Edit <> nil then
      Style := Edit.ActiveStyle;

    if not IsInplace and NativeStyle then
      AViewInfo.BorderStyle := Style.BaseStyle.BorderStyle
    else
      AViewInfo.BorderStyle := GetBorderStyle;
  end;

  procedure CalculatePopupBorderStyle;
  const
    ADefaultPopupBorderStyleMap: array [TcxEditBorderStyle] of TcxEditPopupBorderStyle =
      (epbsFlat, epbsSingle, epbsSingle, epbsFlat, epbsSingle, epbsSingle, epbsSingle);
    AInplaceDefaultPopupBorderStyleMap: array [TcxLookAndFeelKind] of TcxEditPopupBorderStyle =
      (epbsFlat, epbsFrame3D, epbsSingle, epbsSingle);
  begin
    AViewInfo.PopupBorderStyle := Style.PopupBorderStyle;
    if (AViewInfo.PopupBorderStyle = epbsDefault) and (Edit <> nil) then
      if IsInplace then
        AViewInfo.PopupBorderStyle := AInplaceDefaultPopupBorderStyleMap[Style.LookAndFeel.Kind]
      else
        if (AViewInfo.BorderStyle = ebsNone) and (Length(AViewInfo.ButtonsInfo) > 0) then
          AViewInfo.PopupBorderStyle := AInplaceDefaultPopupBorderStyleMap[GetEditPopupWindowControlsLookAndFeelKind(Edit)]
        else
          AViewInfo.PopupBorderStyle := ADefaultPopupBorderStyleMap[AViewInfo.BorderStyle];
  end;

var
  AClientExtent: TRect;
  AIContainerInnerControl: IcxContainerInnerControl;
  APrevBorderWidth: Integer;
begin
  Shift := Shift - [ssShift, ssAlt, ssCtrl];

  APrevBorderWidth := GetContainerBorderWidth(TcxContainerBorderStyle(AViewInfo.BorderStyle));
  CalculateContainerState;
  if not IsInplace and not NativeStyle and
    (GetContainerBorderWidth(TcxContainerBorderStyle(AViewInfo.BorderStyle)) < APrevBorderWidth) then
      CalculateContainerState;
  TcxContainerViewInfo(AViewInfo).BorderStyle := TcxContainerBorderStyle(AViewInfo.BorderStyle);
  ContainerState := AViewInfo.ContainerState;

  AViewInfo.EditProperties := Properties;
  if IsInplace then
    ButtonsOnlyStyle := (ABounds.Right <> MaxInt) and (Properties.ButtonsViewStyle <> bvsNormal)
  else
    ButtonsOnlyStyle := Properties.ButtonsViewStyle = bvsButtonsOnly;// (ABounds.Right <> MaxInt) and (Properties.ButtonsViewStyle <> bvsNormal);
  Bounds := ABounds;

  AViewInfo.Painter := Style.LookAndFeel.SkinPainter;
  AViewInfo.Bounds := Bounds;
  AViewInfo.Enabled := Enabled;
  AViewInfo.Focused := Focused;
  AViewInfo.HasBackground := (Edit <> nil) and Edit.HasBackground;
  AViewInfo.HasInnerEdit := (InnerEdit <> nil) and (InnerEdit.Control.Visible);
  AViewInfo.IsDBEditPaintCopyDrawing := (Edit <> nil) and Edit.IsDBEditPaintCopyDrawing;
  AViewInfo.IsContainerInnerControl := (Edit <> nil) and
    Supports(TObject(Edit), IcxContainerInnerControl, AIContainerInnerControl);
  AViewInfo.IsDesigning := IsDesigning;
  AViewInfo.IsInplace := IsInplace;
  AViewInfo.IsSelected := IsSelected;
  AViewInfo.PaintOptions := GetPaintOptions;
  AViewInfo.Edges := Style.Edges;

  if Style.DirectAccessMode then
    AViewInfo.Font := Style.Font
  else
    AViewInfo.Font := Style.GetVisibleFont;

  AViewInfo.Shadow := not IsInplace and HasShadow;
  AViewInfo.WindowHandle := WindowHandle;

  CalculateViewInfo(AViewInfo, AIsMouseEvent);

  CalculateButtonsViewInfo(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);

  AViewInfo.ClientRect := ABounds;
  AClientExtent := GetClientExtent(ACanvas, AViewInfo);
  ExtendRect(AViewInfo.ClientRect, AClientExtent);
  if InnerEdit <> nil then
    AViewInfo.InnerEditRect := InnerEdit.Control.BoundsRect
  else
    AViewInfo.InnerEditRect := AViewInfo.ClientRect;

  CalculatePopupBorderStyle;
end;

procedure TcxCustomEditViewData.CalculateButtonBounds(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo; AButtonVisibleIndex: Integer;
  var ButtonsRect: TRect);
var
  AButtonVisibleWidth, AButtonWidth: Integer;
begin
  with AViewInfo.ButtonsInfo[AButtonVisibleIndex] do
  begin
    if IsRectEmpty(ButtonsRect) then
    begin
      Bounds := cxEmptyRect;
      VisibleBounds := Bounds;
    end else
    begin
      Bounds.Top := ButtonsRect.Top;
      Bounds.Bottom := ButtonsRect.Bottom;
      AButtonWidth := CalculateEditDefaultButtonWidth(ACanvas, AViewInfo.ButtonsInfo[AButtonVisibleIndex]);
      if AButtonWidth > ButtonsRect.Right - ButtonsRect.Left then
        AButtonVisibleWidth := ButtonsRect.Right - ButtonsRect.Left
      else
        AButtonVisibleWidth := AButtonWidth;
      if Data.LeftAlignment then
      begin
        Bounds.Left := ButtonsRect.Left;
        Bounds.Right := Bounds.Left + AButtonWidth;
        VisibleBounds := Bounds;
        VisibleBounds.Right := VisibleBounds.Left + AButtonVisibleWidth;
        Inc(ButtonsRect.Left, AButtonVisibleWidth);
        if FLeftSideLeftmostButtonIndex = -1 then
          FLeftSideLeftmostButtonIndex := AButtonVisibleIndex;
        FLeftSideRightmostButtonIndex := AButtonVisibleIndex;
      end else
      begin
        Bounds.Right := ButtonsRect.Right;
        Bounds.Left := Bounds.Right - AButtonWidth;
        VisibleBounds := Bounds;
        VisibleBounds.Left := VisibleBounds.Right - AButtonVisibleWidth;
        Dec(ButtonsRect.Right, AButtonVisibleWidth);
        if FRightSideRightmostButtonIndex = -1 then
          FRightSideRightmostButtonIndex := AButtonVisibleIndex;
        FRightSideLeftmostButtonIndex := AButtonVisibleIndex;
      end;
    end;
  end;
end;

procedure TcxCustomEditViewData.CalculateButtonsViewInfo(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);

  procedure CalculateButtonViewInfos(AButtonsStyle: TcxEditButtonStyle);
  var
    AButton: TcxEditButton;
    AButtonIndex, AButtonVisibleIndex: Integer;
    AButtonsRect, APrevButtonsRect: TRect;
    AButtonViewInfo: TcxEditButtonViewInfo;
  begin
    AButtonsRect := ABounds;
    if IsInplace or not (AViewInfo.NativeStyle and AViewInfo.ButtonsInfo[0].Data.ComboBoxStyle and IsCompositionEnabled) then
      ExtendRect(AButtonsRect, GetButtonsExtent(ACanvas));
    APrevButtonsRect := AButtonsRect;

    AButtonVisibleIndex := Properties.Buttons.VisibleCount - 1;
    AViewInfo.HasTextButtons := False;
    for AButtonIndex := Properties.Buttons.Count - 1 downto 0 do
    begin
      AButton := Properties.Buttons[AButtonIndex];
      if AButton.Visible then
      begin
        if (AButton.Kind = bkText) and not AViewInfo.HasTextButtons then
        begin
          AViewInfo.HasTextButtons := True;
          ACanvas.Font := Style.GetVisibleFont;
          AViewInfo.PrepareCanvasFont(ACanvas.Canvas);
        end;

        AButtonViewInfo := AViewInfo.ButtonsInfo[AButtonVisibleIndex];
        AButtonViewInfo.Index := AButtonIndex;
        AButtonViewInfo.Data.Style := AButtonsStyle;
        CalculateButtonViewInfo(ACanvas, AViewInfo, AButtonVisibleIndex, AButtonsRect);
        Dec(AButtonVisibleIndex);
      end;
    end;

    CheckButtonsOnly(AViewInfo, APrevButtonsRect.Right - APrevButtonsRect.Left,
      AButtonsRect.Right - AButtonsRect.Left);
  end;

  procedure CalculateButtonStates(APrevPressedButton: Integer);
  var
    AButtonViewInfo: TcxEditButtonViewInfo;
    AButtonVisibleIndex: Integer;
    ACapturePressing: Boolean;
    AHoldPressing: Boolean;
    AIsButtonPressed: Boolean;
    AMouseButtonPressing: Boolean;
  begin
    for AButtonVisibleIndex := 0 to High(AViewInfo.ButtonsInfo) do
    begin
      AIsButtonPressed := IsButtonPressed(AViewInfo, AButtonVisibleIndex);
      AButtonViewInfo := AViewInfo.ButtonsInfo[AButtonVisibleIndex];
      with AButtonViewInfo do
      begin
        if not Enabled or not Properties.Buttons[Index].Enabled then
          Data.State := ebsDisabled
        else
          if AIsButtonPressed or (not IsDesigning and PtInRect(VisibleBounds, P)) then
          begin
            ACapturePressing := (Button = cxmbNone) and (ssLeft in Shift) and
              (Data.State = ebsNormal) and (GetCaptureButtonVisibleIndex =
              AButtonVisibleIndex);
            AMouseButtonPressing := (Button = cxmbLeft) and
              ((Shift = [ssLeft]) or (Shift = [ssLeft, ssDouble]));
            AHoldPressing := (Data.State = ebsPressed) and (Shift * [ssLeft] <> []);
            if AIsButtonPressed or AMouseButtonPressing or AHoldPressing or
                ACapturePressing then
              AViewInfo.IsButtonReallyPressed := True;
            if not AIsButtonPressed and (Shift = []) and not ACapturePressing then
            begin
              Data.State := ebsSelected;
              AViewInfo.SelectedButton := AButtonVisibleIndex;
            end
            else
              if (AIsButtonPressed or ACapturePressing and CanPressButton(AViewInfo, AButtonVisibleIndex) or ((Shift = [ssLeft]) or (Shift = [ssLeft, ssDouble])) and
                ((Button = cxmbLeft) and CanPressButton(AViewInfo, AButtonVisibleIndex) or
                (APrevPressedButton = AButtonVisibleIndex))) or AHoldPressing then
              begin
                Data.State := ebsPressed;
                AViewInfo.PressedButton := AButtonVisibleIndex;
              end
              else
                Data.State := ebsNormal;
          end
          else
            Data.State := ebsNormal;
        DoGetButtonState(AViewInfo, AButtonVisibleIndex, Data.State);
        CalculateButtonNativeInfo(AViewInfo.ButtonsInfo[AButtonVisibleIndex]);
      end;
    end;
  end;

  procedure CorrectButtonBounds;
  var
    AButtonsRect: TRect;
    I: Integer;
  begin
    AButtonsRect := ABounds;
    ExtendRect(AButtonsRect, GetButtonsExtent(ACanvas));
    if FLeftSideLeftmostButtonIndex <> -1 then
      AViewInfo.ButtonsInfo[FLeftSideLeftmostButtonIndex].Data.Leftmost := True;
    if (FLeftSideRightmostButtonIndex <> -1) and (not ButtonsOnlyStyle or (FRightSideLeftmostButtonIndex = -1)) then
      AViewInfo.ButtonsInfo[FLeftSideRightmostButtonIndex].Data.Rightmost := True;
    if (FRightSideLeftmostButtonIndex <> -1) and (not ButtonsOnlyStyle or (FLeftSideRightmostButtonIndex = -1)) then
      AViewInfo.ButtonsInfo[FRightSideLeftmostButtonIndex].Data.Leftmost := True;
    if FRightSideRightmostButtonIndex <> -1 then
      AViewInfo.ButtonsInfo[FRightSideRightmostButtonIndex].Data.Rightmost := True;
    if ButtonsOnlyStyle then
      for I := 0 to High(AViewInfo.ButtonsInfo) do
        AViewInfo.ButtonsInfo[I].Data.LeftAlignment := False;
  end;

var
  APrevPressedButton: Integer;
begin
  if ButtonVisibleCount = 0 then
  begin
    AViewInfo.SetButtonCount(ButtonVisibleCount);
    Exit;
  end;
  if not(csActive in ContainerState) then
    if (Style.ButtonTransparency = ebtHideInactive) or
      (not(csHotTrack in ContainerState) and (Style.ButtonTransparency = ebtHideUnselected)) then
    begin
      AViewInfo.SetButtonCount(0);
      Exit;
    end;
  AViewInfo.SetButtonCount(ButtonVisibleCount);
  AViewInfo.IsButtonReallyPressed := False;
  if AIsMouseEvent then
    APrevPressedButton := AViewInfo.PressedButton
  else
    APrevPressedButton := -1;
  AViewInfo.PressedButton := -1;
  AViewInfo.SelectedButton := -1;

  FLeftSideLeftmostButtonIndex := -1;
  FLeftSideRightmostButtonIndex := -1;
  FRightSideLeftmostButtonIndex := -1;
  FRightSideRightmostButtonIndex := -1;

  CalculateButtonViewInfos(GetButtonsStyle);
  CalculateButtonStates(APrevPressedButton);
  CorrectButtonBounds;
end;

procedure TcxCustomEditViewData.CalculateButtonViewInfo(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo; AButtonVisibleIndex: Integer; var ButtonsRect: TRect);

  function GetButtonWidth(AButton: TcxEditButton): Integer;
  begin
    Result := AButton.Width;
    if Result = 0 then
      Result := DoGetDefaultButtonWidth(AButton.Index);
  end;

var
  AButton: TcxEditButton;
begin
  with AViewInfo.ButtonsInfo[AButtonVisibleIndex] do
  begin
    AButton := Properties.Buttons[Index];
    Data.ComboBoxStyle := (Length(AViewInfo.ButtonsInfo) = 1) and
      (AButton.Kind = bkDown);
    Data.Kind := AButton.Kind;
    if Data.Kind = bkText then
    begin
      Data.Caption := AButton.Caption;
      if AViewInfo.Painter <> nil then
        Data.TextColor := AViewInfo.Painter.EditButtonTextColor
      else
        Data.TextColor := AButton.TextColor;
      Data.VisibleCaption := AButton.FVisibleCaption;
    end;
    Data.ContentAlignment := AButton.ContentAlignment;
    Data.Default := AButton.Default;
    Glyph := AButton.Glyph;
    HasBackground := AViewInfo.HasBackground;
    Data.Gradient := Self.Style.GradientButtons;
    Data.IsInplace := Self.IsInplace;
    Data.LeftAlignment := AButton.LeftAlignment;
    Data.Leftmost := False;
    Data.Rightmost := False;
    Data.NativeStyle := AViewInfo.NativeStyle;
    Stretchable := AButton.Stretchable;
    Width := GetButtonWidth(AButton);
    Data.Transparent := (Self.Style.ButtonTransparency = ebtAlways) or
      ((Self.Style.ButtonTransparency = ebtInactive) and not Selected);
    Data.BackgroundColor := AViewInfo.BackgroundColor;
    CalculateButtonBounds(ACanvas, AViewInfo, AButtonVisibleIndex, ButtonsRect);
  end;
end;

procedure TcxCustomEditViewData.CalculateEx(ACanvas: TcxCanvas; const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  ANewBounds: TRect;
  ANewP: TPoint;
begin
  AViewInfo.Left := ABounds.Left;
  AViewInfo.Top := ABounds.Top;
  ANewBounds := ABounds;
  OffsetRect(ANewBounds, -ABounds.Left, -ABounds.Top);
  ANewP := Point(P.X - ABounds.Left, P.Y - ABounds.Top);
  Calculate(ACanvas, ANewBounds, ANewP, Button, Shift, AViewInfo, AIsMouseEvent);
end;

procedure TcxCustomEditViewData.CheckButtonsOnly(
  AViewInfo: TcxCustomEditViewInfo; APrevButtonsWidth, AButtonsWidth: Integer);
var
  AVisibleButtonCount: Integer;

  procedure FindStretchableButtons(out AStretchableButtonCount,
    AStretchableButtonsTotalWidth: Integer; out AAllButtonsAreStretchable: Boolean);
  var
    I: Integer;
  begin
    AStretchableButtonCount := 0;
    AStretchableButtonsTotalWidth := 0;
    for I := 0 to AVisibleButtonCount - 1 do
      with AViewInfo.ButtonsInfo[I] do
        if Stretchable and not IgnoreButtonWhileStretching(I) then
        begin
          Inc(AStretchableButtonCount);
          Inc(AStretchableButtonsTotalWidth, Bounds.Right - Bounds.Left);
        end;
    AAllButtonsAreStretchable := AStretchableButtonCount = 0;
    if AAllButtonsAreStretchable then
    begin
      AStretchableButtonCount := AVisibleButtonCount;
      AStretchableButtonsTotalWidth := APrevButtonsWidth - AButtonsWidth;
    end;
  end;

  procedure StretchButton(AButtonVisibleIndex: Integer;
    AButtonViewInfo: TcxEditButtonViewInfo; AButtonWidthCorrection: Integer);
  var
    J: Integer;
  begin
    if AButtonViewInfo.Data.LeftAlignment then
    begin
      for J := 0 to High(AViewInfo.ButtonsInfo) do
        with AViewInfo.ButtonsInfo[J] do
          if Data.LeftAlignment and (Bounds.Left >= AButtonViewInfo.Bounds.Right) then
          begin
            Inc(Bounds.Left, AButtonWidthCorrection);
            Inc(Bounds.Right, AButtonWidthCorrection);
            VisibleBounds := Bounds;
          end;
      with AButtonViewInfo do
      begin
        Inc(Bounds.Right, AButtonWidthCorrection);
        VisibleBounds.Right := Bounds.Right;
      end;
    end
    else
    begin
      for J := 0 to High(AViewInfo.ButtonsInfo) do
        with AViewInfo.ButtonsInfo[J] do
          if not Data.LeftAlignment and (Bounds.Right <= AButtonViewInfo.Bounds.Left) then
          begin
            Dec(Bounds.Left, AButtonWidthCorrection);
            Dec(Bounds.Right, AButtonWidthCorrection);
            VisibleBounds := Bounds;
          end;
      with AButtonViewInfo do
      begin
        Dec(Bounds.Left, AButtonWidthCorrection);
        VisibleBounds.Left := Bounds.Left;
      end;
    end;
  end;

var
  AAllButtonsAreStretchable: Boolean;
  AButtonViewInfo: TcxEditButtonViewInfo;
  AFirstStretchableButtonWidthCorrection, AButtonWidthCorrection: Integer;
  AStretchableButtonCount, AStretchableButtonsTotalWidth: Integer;
  I: Integer;
begin
  if not ButtonsOnlyStyle or (AButtonsWidth <= 0) then
    Exit;
  AVisibleButtonCount := Length(AViewInfo.ButtonsInfo);
  FindStretchableButtons(AStretchableButtonCount, AStretchableButtonsTotalWidth,
    AAllButtonsAreStretchable);
  AFirstStretchableButtonWidthCorrection := AButtonsWidth;
  for I := AVisibleButtonCount - 1 downto 0 do
  begin
    AButtonViewInfo := AViewInfo.ButtonsInfo[I];
    if not AAllButtonsAreStretchable and (not AButtonViewInfo.Stretchable or IgnoreButtonWhileStretching(I)) then
      Continue;
    Dec(AStretchableButtonCount);
    if AStretchableButtonCount = 0 then
      AButtonWidthCorrection := AFirstStretchableButtonWidthCorrection
    else
    begin
      with AButtonViewInfo.Bounds do
        AButtonWidthCorrection := AButtonsWidth * (Right - Left) div AStretchableButtonsTotalWidth;
      Dec(AFirstStretchableButtonWidthCorrection, AButtonWidthCorrection);
    end;
    StretchButton(I, AButtonViewInfo, AButtonWidthCorrection);
  end;
end;

procedure TcxCustomEditViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
begin
end;

function TcxCustomEditViewData.GetBorderColor: TColor;
var
  AIsHighlightBorder: Boolean;
begin
  AIsHighlightBorder := (csActive in ContainerState) or
    (csHotTrack in ContainerState) and Style.HotTrack;
  if Style.LookAndFeel.SkinPainter <> nil then
    Result := Style.LookAndFeel.SkinPainter.GetContainerBorderColor(AIsHighlightBorder)
  else
    if Style.BorderStyle in [ebsUltraFlat, ebsOffice11] then
    begin
       AIsHighlightBorder := AIsHighlightBorder or IsDesigning and Enabled;
      if AIsHighlightBorder then
        Result := GetEditBorderHighlightColor(Style.BorderStyle = ebsOffice11)
      else
        Result := clBtnShadow;
    end
    else
      Result := Style.BorderColor;
end;

function TcxCustomEditViewData.GetBorderExtent: TRect;
var
  ANativeStyle: Boolean;
  AStyle: TcxCustomEditStyle;
begin
  if IsInplace then
    Result := ContentOffset
  else
  begin
    AStyle := Style;
    ANativeStyle := IsNativeStyle(AStyle.LookAndFeel);
    if AStyle.LookAndFeel.SkinPainter <> nil then
      Result := GetBorderExtentByPainter
    else
      if AStyle.TransparentBorder then
        Result := cxContainerDefaultBorderExtent
      else
        if not AStyle.HasBorder or ANativeStyle and (AStyle.BaseStyle.BorderStyle = ebsNone) then
          Result := cxEmptyRect
        else
          if ANativeStyle then
            Result := cxContainerDefaultBorderExtent
          else
            Result := GetBorderExtentByEdges(GetContainerBorderWidth(
              TcxContainerBorderStyle(GetBorderStyle)));
              
      if HasShadow then
      begin
        Inc(Result.Right, cxEditShadowWidth);
        Inc(Result.Bottom, cxEditShadowWidth);
      end;
  end;
end;

function TcxCustomEditViewData.GetBorderExtentByEdges(ABorderWidth: Integer): TRect;
begin
  Result := cxEmptyRect;
  if bLeft in Style.Edges then
    Result.Left := ABorderWidth;
  if bTop in Style.Edges then
    Result.Top := ABorderWidth;
  if bRight in Style.Edges then
    Result.Right := ABorderWidth;
  if bBottom in Style.Edges then
    Result.Bottom := ABorderWidth;
end;

function TcxCustomEditViewData.GetBorderExtentByPainter: TRect;

  function HasNoBorders(AStyle: TcxCustomEditStyle): Boolean;
  begin
    Result := not AStyle.HasBorder or
      ((AStyle.BorderStyle = ebsNone) and not AStyle.TransparentBorder); 
  end;

var
  ABorderStyle: TcxEditBorderStyle;
begin                      
  if HasNoBorders(Style) then
    Result := cxEmptyRect
  else
  begin
    if HasThickBorders then
      ABorderStyle := ebsThick
    else
      ABorderStyle := GetBorderStyle;
    Result := GetBorderExtentByEdges(
      cxEditGetBorderWidthBySkinPainter(ABorderStyle, Style.LookAndFeel.SkinPainter));
  end;
end;

function TcxCustomEditViewData.GetBorderStyle: TcxEditBorderStyle;
begin
  if IsInplace then
    Result := ebsNone
  else
  begin
    Result := Style.BorderStyle;
    CorrectBorderStyle(Result);
  end;
end;

function TcxCustomEditViewData.GetButtonsExtent(ACanvas: TcxCanvas): TRect;
var
  ATheme: TdxTheme;
  R, CR: TRect;
begin
  if IsInplace then
    Result := ContentOffset
  else
    if NativeStyle then
    begin
      if not Style.TransparentBorder and (Style.BaseStyle.BorderStyle = ebsNone) then
        Result := cxEmptyRect
      else
        if (Style.BaseStyle.BorderStyle = ebsNone) then
          Result := cxContainerDefaultBorderExtent
        else
        begin
          R := Rect(0, 0, 100, 100);
          ATheme := OpenTheme(totEdit);
          GetThemeBackgroundContentRect(ATheme, ACanvas.Handle, EP_EDITTEXT,
            ETS_NORMAL, R, CR);
          Result := CR;
          Result.Right := R.Right - CR.Right;
          Result.Bottom := R.Bottom - CR.Bottom;
        end;
    end
    else
      Result := GetBorderExtent;
end;

function TcxCustomEditViewData.GetClientExtent(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo): TRect;
var
  I: Integer;
begin
  Result := GetBorderExtent;
  if (Properties.ButtonsViewStyle <> bvsNormal) and (Length(AViewInfo.ButtonsInfo) > 0) then
    with GetButtonsExtent(ACanvas) do
    begin
      Result.Left := Left;
      Result.Right := Right;
    end;

  if HScrollBar <> nil then
    Inc(Result.Bottom, HScrollBar.Height);
  if VScrollBar <> nil then
    Inc(Result.Right, VScrollBar.Width);

  for I := 0 to Length(AViewInfo.ButtonsInfo) - 1 do
    with AViewInfo.ButtonsInfo[I] do
      if Data.LeftAlignment then
      begin
        if Bounds.Right - AViewInfo.Bounds.Left > Result.Left then
          Result.Left := Bounds.Right - AViewInfo.Bounds.Left
      end else
      begin
        if AViewInfo.Bounds.Right - Bounds.Left > Result.Right then
          Result.Right := AViewInfo.Bounds.Right - Bounds.Left;
      end;
end;

function TcxCustomEditViewData.GetEditConstantPartSize(ACanvas: TcxCanvas;
  const AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
  AViewInfo: TcxCustomEditViewInfo = nil): TSize;
var
  ATempViewInfo: TcxCustomEditViewInfo;
begin
  if AViewInfo = nil then
    ATempViewInfo := TcxCustomEditViewInfo(Properties.GetViewInfoClass.Create)
  else
    ATempViewInfo := AViewInfo;
  try
    if AViewInfo = nil then
      Calculate(ACanvas, Rect(0, 0, MaxInt, MaxInt), Point(-1, -1), cxmbNone,
        [], ATempViewInfo, False);
    Result := InternalGetEditConstantPartSize(ACanvas, IsInplace,
      AEditSizeProperties, MinContentSize, ATempViewInfo);
  finally
    if AViewInfo = nil then
      FreeAndNil(ATempViewInfo);
  end;
end;

function TcxCustomEditViewData.GetEditContentSize(ACanvas: TcxCanvas; const AEditValue:
  TcxEditValue; const AEditSizeProperties: TcxEditSizeProperties): TSize;
begin
  if Properties.ButtonsViewStyle <> bvsNormal then
  begin
    Result.cx := 0;
    ACanvas.Font := Style.GetVisibleFont;
    Result.cy := ACanvas.TextHeight('Zg') + Self.GetEditContentSizeCorrection.cy;
  end
  else
    Result := InternalGetEditContentSize(ACanvas, AEditValue, AEditSizeProperties);
end;

function TcxCustomEditViewData.GetEditContentSizeCorrection: TSize;
begin
  with EditContentParams do
  begin
    Result.cx := Offsets.Left + Offsets.Right + SizeCorrection.cx;
    Result.cy := Offsets.Top + Offsets.Bottom + SizeCorrection.cy;
  end;
end;

function TcxCustomEditViewData.GetEditSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AEditSizeProperties: TcxEditSizeProperties;
  AViewInfo: TcxCustomEditViewInfo = nil): TSize;
var
  AContentSize, AMinContentSize: TSize;
  ATooNarrowEdit: Boolean;
  APrevWidth: Integer;
begin
  Result := GetEditConstantPartSize(ACanvas, AEditSizeProperties,
    AMinContentSize, AViewInfo);
  ATooNarrowEdit := False;
  with AEditSizeProperties do
  begin
    APrevWidth := Width;
    if Width >= 0 then
    begin
      Width := Width - Result.cx;
      ATooNarrowEdit := Width < 0;
      if ATooNarrowEdit then
        Width := 0;
    end;
  end;
  AContentSize := GetEditContentSize(ACanvas, AEditValue, AEditSizeProperties);
  CheckSize(AContentSize, AMinContentSize);
  if ATooNarrowEdit then
    Result.cx := APrevWidth
  else
    Result.cx := Result.cx + AContentSize.cx;
  Result.cy := Result.cy + AContentSize.cy;
  if not IsInplace and (Edit <> nil) then
    CheckSizeConstraints(Result);
end;

function TcxCustomEditViewData.HasShadow: Boolean;
begin
  Result := IsShadowDrawingNeeded(Self);
end;

function TcxCustomEditViewData.IgnoreButtonWhileStretching(
  AButtonVisibleIndex: Integer): Boolean;
begin
  Result := False;
end;

class function TcxCustomEditViewData.IsNativeStyle(ALookAndFeel: TcxLookAndFeel): Boolean;
begin
  Result := AreVisualStylesMustBeUsed(ALookAndFeel.NativeStyle, totEdit);
end;

procedure TcxCustomEditViewData.CalculateButtonNativeInfo(AButtonViewInfo: TcxEditButtonViewInfo);
const
  ButtonStateA: array [Boolean, TcxEditButtonState] of Integer = (
    (PBS_DISABLED, PBS_NORMAL, PBS_PRESSED, PBS_HOT),
    (CBXS_DISABLED, CBXS_NORMAL, CBXS_PRESSED, CBXS_HOT)
  );
var
  ATheme: TdxTheme;
begin
  ATheme := 0;
  with AButtonViewInfo do
  begin
    Data.NativePart := TC_NONE;
    if Data.NativeStyle then
    begin
      if Data.ComboBoxStyle then
        ATheme := OpenTheme(totComboBox)
      else
        ATheme := OpenTheme(totButton);
      if ATheme <> 0 then
        if Data.ComboBoxStyle then
          if IsCompositionEnabled and not IsInplace then
            if Data.LeftAlignment then
              Data.NativePart := CP_DROPDOWNBUTTONLEFT
            else
              Data.NativePart := CP_DROPDOWNBUTTONRIGHT
          else
            Data.NativePart := CP_DROPDOWNBUTTON
        else
          Data.NativePart := BP_PUSHBUTTON;
    end;

    if Data.NativePart = TC_NONE then
    begin
      Data.BackgroundPartiallyTransparent := False;
      Data.NativeState := TC_NONE;
    end
    else
    begin
      Data.BackgroundPartiallyTransparent := IsThemeBackgroundPartiallyTransparent(ATheme,
        Data.NativePart, Data.NativeState);
      Data.NativeState := ButtonStateA[Data.ComboBoxStyle, Data.State];
    end;
  end;
end;

procedure TcxCustomEditViewData.CalculateViewInfo(AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  ABackgroundColor: TColor;
begin
  AViewInfo.NativeStyle := NativeStyle;
  if AViewInfo.NativeStyle then
    AViewInfo.NativeState := GetEditNativeState(AViewInfo)
  else
    AViewInfo.NativeState := TC_NONE;

  AViewInfo.BorderExtent := GetBorderExtent;
  AViewInfo.BorderRect := AViewInfo.Bounds;
  ExtendRect(AViewInfo.BorderRect, AViewInfo.BorderExtent);
  AViewInfo.ShadowRect := AViewInfo.BorderRect;

  AViewInfo.HasContentOffsets :=
    (Int64(ContentOffset.TopLeft) <> 0) or (Int64(ContentOffset.BottomRight) <> 0);

  if not IsInplace then
    AViewInfo.BorderColor := GetBorderColor;
  GetColorSettings(AViewInfo, ABackgroundColor, AViewInfo.TextColor);
  AViewInfo.BackgroundColor := ABackgroundColor;
end;

function TcxCustomEditViewData.CanPressButton(AViewInfo: TcxCustomEditViewInfo;
  AButtonVisibleIndex: Integer): Boolean;
begin
  Result := True;
end;

procedure TcxCustomEditViewData.CheckSizeConstraints(var AEditSize: TSize);
begin
  with Edit.Constraints do
  begin
    if (MaxHeight <> 0) and (AEditSize.cy > MaxHeight) then
      AEditSize.cy := MaxHeight;
    if (MinHeight <> 0) and (AEditSize.cy < MinHeight) then
      AEditSize.cy := MinHeight;
    if (MaxWidth <> 0) and (AEditSize.cx > MaxWidth) then
      AEditSize.cx := MaxWidth;
    if (MinWidth <> 0) and (AEditSize.cx < MinWidth) then
      AEditSize.cx := MinWidth;
  end;
end;

procedure TcxCustomEditViewData.DoOnGetDisplayText(var AText: string);
begin
  if Assigned(FOnGetDisplayText) then
    FOnGetDisplayText(Self, AText);
end;

procedure TcxCustomEditViewData.CorrectBorderStyle(var ABorderStyle: TcxEditBorderStyle);
begin
  if ABorderStyle in [ebsUltraFlat, ebsOffice11] then
    ABorderStyle := ebsSingle;
end;

function TcxCustomEditViewData.EditValueToDisplayText(AEditValue: TcxEditValue): string;
begin
  Result := InternalEditValueToDisplayText(AEditValue);
  DoOnGetDisplayText(Result);
end;

function TcxCustomEditViewData.GetButtonsStyle: TcxEditButtonStyle;

  function GetDefaultButtonStyle: TcxEditButtonStyle;
  const
    AButtonStyles: array[TcxEditBorderStyle] of TcxEditButtonStyle =
      (btsSimple, btsHotFlat, bts3D, btsFlat, bts3D, btsUltraFlat, btsOffice11);
    AInplaceButtonStyles: array[TcxLookAndFeelKind] of TcxEditButtonStyle =
      (btsFlat, bts3D, btsUltraFlat, btsOffice11);
  begin
    if IsInplace or (Style.BorderStyle = ebsNone) and not Style.HotTrack then
      Result := AInplaceButtonStyles[Style.LookAndFeel.Kind]
    else
      Result := AButtonStyles[Style.BorderStyle];
  end;

begin
  Result := Style.ButtonStyle;
  if Result = btsDefault then
    Result := GetDefaultButtonStyle;
end;

function TcxCustomEditViewData.GetCaptureButtonVisibleIndex: Integer;
begin
  Result := -1;
  if Edit <> nil then
    Result := Edit.FCaptureButtonVisibleIndex;
end;

procedure TcxCustomEditViewData.GetColorSettings(AViewInfo: TcxCustomEditViewInfo;
  var FillColor, TextColor: TColor);
const
  ANativePart: array [Boolean] of Integer = (EP_EDITTEXT, EP_BACKGROUND);
var
  AColor: COLORREF;
begin
  AViewInfo.GetColorSettingsByPainter(FillColor, TextColor);
  if TextColor = clDefault then
    TextColor := Style.TextColor;
  if (Edit <> nil) and Edit.DefaultParentColor then
    FillColor := Style.Color
  else
    if FillColor = clDefault then
    begin
      if AViewInfo.NativeStyle and not Enabled and not Style.IsValueAssigned(svColor) then
  //    if AViewInfo.NativeStyle and (AViewInfo.NativeState in [ETS_DISABLED, ETS_READONLY]) and
  //      not Style.IsValueAssigned(svColor) then
      begin
        GetThemeColor(OpenTheme(totEdit), ANativePart[IsCompositionEnabled],
          AViewInfo.NativeState, TMT_FILLCOLOR, AColor);
        FillColor := AColor;
      end
      else
        FillColor := Style.Color;
    end;
end;

function TcxCustomEditViewData.GetContainerState(const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AIsMouseEvent: Boolean): TcxContainerState;

  function GetEditVisibleBounds: TRect;
  begin
    if Edit <> nil then
      Result := Edit.GetVisibleBounds
    else
    begin
      Result := ABounds;
      ExtendRect(Result, ContentOffset);
    end;
  end;

begin
  if Enabled then
    if IsDesigning then
      Result := [csNormal]
    else
    begin
      if Focused then
        Result := [csActive]
      else
        Result := [csNormal];
      if PtInRect(GetEditVisibleBounds, P) and
        ((Shift = []) or (Edit <> nil) and (GetCaptureControl = Edit)) then
          Include(Result, csHotTrack);
    end
  else
    Result := [csDisabled];
end;

function TcxCustomEditViewData.GetEditContentDefaultOffsets: TRect;
begin
  Result := EditContentDefaultOffsets[IsInplace];
end;

procedure TcxCustomEditViewData.InitEditContentParams(
  var AParams: TcxEditContentParams);
begin
  AParams.Offsets := GetEditContentDefaultOffsets;
  with AParams.Offsets do
    AParams.SizeCorrection.cx := EditContentMaxTotalDefaultHorzOffset - (Left + Right);
  if not NativeStyle then
    AParams.SizeCorrection.cy := 0
  else
    AParams.SizeCorrection.cy :=
      GetNativeInnerTextEditContentHeightCorrection(Properties, IsInplace);
  AParams.ExternalBorderBounds := cxEmptyRect;
  AParams.Options := [ecoOffsetButtonContent];
end;

function TcxCustomEditViewData.GetEditNativeState(AViewInfo: TcxCustomEditViewInfo): Integer;
begin
  if not Enabled then
    Result := ETS_DISABLED
  else if Properties.ReadOnly then
    Result := ETS_READONLY
  else if Focused then
    if IsCompositionEnabled then
      Result := ETS_SELECTED
    else
      Result := ETS_FOCUSED
  else if csHotTrack in ContainerState then
    Result := ETS_HOT
  else
    Result := ETS_NORMAL;
end;

function TcxCustomEditViewData.HasThickBorders: Boolean; 
begin
  if Edit = nil then
    Result := FStyle.BorderStyle = ebsThick
  else
    Result := (Edit.Style.BorderStyle = ebsThick) or
      (Edit.StyleDisabled.BorderStyle = ebsThick) or
      (Edit.StyleFocused.BorderStyle = ebsThick) or
      (Edit.StyleHot.BorderStyle = ebsThick);
end;

procedure TcxCustomEditViewData.InitCacheData;
begin
  ButtonVisibleCount := Properties.Buttons.VisibleCount;
  IsValueSource := Properties.GetEditValueSource(False) = evsValue;
  with Properties.Alignment do
  begin
    HorzAlignment := Horz;
    VertAlignment := Vert;
  end;
  NativeStyle := IsNativeStyle(Style.LookAndFeel);
  InitEditContentParams(EditContentParams);
end;

procedure TcxCustomEditViewData.Initialize;
begin
  ContentOffset := cxEmptyRect;
  Enabled := True;
end;

function TcxCustomEditViewData.InternalEditValueToDisplayText(
  AEditValue: TcxEditValue): string;
begin
  Result := '';
end;

function TcxCustomEditViewData.InternalFocused: Boolean;
begin
  if Edit <> nil then
    Result := Edit.InternalFocused
  else
    Result := Focused;
end;

function TcxCustomEditViewData.InternalGetEditConstantPartSize(ACanvas: TcxCanvas;
  AIsInplace: Boolean; AEditSizeProperties: TcxEditSizeProperties;
  var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo): TSize;
var
  AButton: TcxEditButton;
  AButtonCaptionHeight, AMaxButtonContentHeight, I: Integer;
begin
  MinContentSize := cxNullSize;
  with AViewInfo.ClientRect do
  begin
    Result.cx := Left - AViewInfo.Bounds.Left + (AViewInfo.Bounds.Right - Right);
    Result.cy := Top - AViewInfo.Bounds.Top + (AViewInfo.Bounds.Bottom - Bottom);
  end;

  AMaxButtonContentHeight := 0;
  if IsInplace then
    for I := 0 to Properties.Buttons.Count - 1 do
    begin
      AButton := Properties.Buttons[I];
      if AButton.Visible and (AButton.Kind = bkText) then
      begin
        ACanvas.Font := Style.GetVisibleFont;
        AViewInfo.PrepareCanvasFont(ACanvas.Canvas);
        Break;
      end;
    end;
  for I := 0 to Properties.Buttons.Count - 1 do
  begin
    AButton := Properties.Buttons[I];
    if not AButton.Visible then
      Continue;
    if (AButton.Kind = bkGlyph) and VerifyBitmap(AButton.Glyph) then
      if AButton.Glyph.Height > AMaxButtonContentHeight then
        AMaxButtonContentHeight := AButton.Glyph.Height;
    if IsInplace and (AButton.Kind = bkText) and (Length(AButton.VisibleCaption) > 0) then
    begin
      AButtonCaptionHeight := ACanvas.TextHeight(AButton.VisibleCaption);
      if AButtonCaptionHeight > AMaxButtonContentHeight then
        AMaxButtonContentHeight := AButtonCaptionHeight;
    end;
  end;
  if AMaxButtonContentHeight > 0 then
  begin
    if Style.LookAndFeel.SkinPainter = nil then
      with GetButtonsExtent(ACanvas) do
        Inc(AMaxButtonContentHeight, Top + Bottom);

    Inc(AMaxButtonContentHeight, GetEditButtonsContentVerticalOffset(ACanvas,
      GetButtonsStyle, AViewInfo.NativeStyle));
    MinContentSize.cy := AMaxButtonContentHeight - Result.cy;
    if MinContentSize.cy < 0 then
      MinContentSize.cy := 0;
  end;
end;

function TcxCustomEditViewData.InternalGetEditContentSize(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; const AEditSizeProperties: TcxEditSizeProperties): TSize;
begin
  Result := cxNullSize;
end;

function TcxCustomEditViewData.IsButtonPressed(AViewInfo: TcxCustomEditViewInfo;
  AButtonVisibleIndex: Integer): Boolean;
begin
  Result := False;
end;

procedure TcxCustomEditViewData.DoGetButtonState(AViewInfo: TcxCustomEditViewInfo;
  AButtonVisibleIndex: Integer; var AState: TcxEditButtonState);
begin
  if Assigned(AViewInfo.FOnGetButtonState) then
    AViewInfo.FOnGetButtonState(AViewInfo, AButtonVisibleIndex, AState);
end;

function TcxCustomEditViewData.DoGetDefaultButtonWidth(AIndex: Integer): Integer;
begin
  Result := 0;
  if Assigned(FOnGetDefaultButtonWidth) then
    FOnGetDefaultButtonWidth(Self, AIndex, Result);
end;

function TcxCustomEditViewData.GetPaintOptions: TcxEditPaintOptions;
begin
  Result := PaintOptions;
  if not IsRectEmpty(EditContentParams.ExternalBorderBounds) then
    Include(Result, epoHasExternalBorder);
  if ecoShowFocusRectWhenInplace in EditContentParams.Options then
    Include(Result, epoShowFocusRectWhenInplace);
end;

function TcxCustomEditViewData.GetStyle: TcxCustomEditStyle;
begin
  Result := TcxCustomEditStyle(FStyle);
end;

procedure TcxCustomEditViewData.SetStyle(Value: TcxCustomEditStyle);
begin
  FStyle := Value;
end;

{ TcxEditStyleController }

function TcxEditStyleController.GetStyleClass: TcxContainerStyleClass;
begin
  Result := TcxEditStyle;
end;

function TcxEditStyleController.GetInternalStyle(AState: TcxContainerStateItem): TcxCustomEditStyle;
begin
  Result := TcxCustomEditStyle(FStyles[AState]);
end;

function TcxEditStyleController.GetStyle: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles[csNormal]);
end;

function TcxEditStyleController.GetStyleDisabled: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles[csDisabled]);
end;

function TcxEditStyleController.GetStyleFocused: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles[csActive]);
end;

function TcxEditStyleController.GetStyleHot: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles[csHotTrack]);
end;

procedure TcxEditStyleController.SetInternalStyle(AState: TcxContainerStateItem;
  Value: TcxCustomEditStyle);
begin
  FStyles[AState] := Value;
end;

procedure TcxEditStyleController.SetStyle(Value: TcxEditStyle);
begin
  FStyles[csNormal] := Value;
end;

procedure TcxEditStyleController.SetStyleDisabled(Value: TcxEditStyle);
begin
  FStyles[csDisabled] := Value;
end;

procedure TcxEditStyleController.SetStyleFocused(Value: TcxEditStyle);
begin
  FStyles[csActive] := Value;
end;

procedure TcxEditStyleController.SetStyleHot(Value: TcxEditStyle);
begin
  FStyles[csHotTrack] := Value;
end;

{ TcxCustomEditStyle }

constructor TcxCustomEditStyle.Create(AOwner: TPersistent;
  ADirectAccessMode: Boolean; AParentStyle: TcxContainerStyle = nil;
  AState: TcxContainerStateItem = csNormal);
begin
  inherited Create(AOwner, ADirectAccessMode, AParentStyle, AState);
  FPopupCloseButton := True;
end;

procedure TcxCustomEditStyle.Assign(Source: TPersistent);
begin
  if Source is TcxCustomEditStyle then
  begin
    BeginUpdate;
    try
      with Source as TcxCustomEditStyle do
      begin
        Self.FButtonStyle := FButtonStyle;
        Self.FButtonTransparency := FButtonTransparency;
        Self.FGradient := FGradient;
        Self.FGradientButtons := FGradientButtons;
        Self.FGradientDirection := FGradientDirection;
        Self.FPopupBorderStyle := FPopupBorderStyle;
        Self.FPopupCloseButton := FPopupCloseButton;
      end;
      inherited Assign(Source);
    finally
      Changed;
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomEditStyle.GetStyleValueCount: Integer;
begin
  Result := cxEditStyleValueCount;
end;

function TcxCustomEditStyle.GetStyleValueName(AStyleValue: TcxEditStyleValue;
  out StyleValueName: string): Boolean;
begin
  Result := inherited GetStyleValueName(AStyleValue, StyleValueName);
  if not Result then
  begin
    Result := AStyleValue < cxEditStyleValueCount;
    if Result then
      StyleValueName := cxEditStyleValueNameA[AStyleValue - cxContainerStyleValueCount];
  end;
end;

function TcxCustomEditStyle.IsValueAssigned(AValue: TcxEditStyleValue): Boolean;
var
  AButtonStyle: TcxEditButtonStyle;
  AButtonTransparency: TcxEditButtonTransparency;
  AGradientDirection: TcxEditGradientDirection;
  APopupBorderStyle: TcxEditPopupBorderStyle;
  ATempBool: Boolean;
begin
  case AValue of
    svButtonStyle:
      Result := InternalGetButtonStyle(AButtonStyle);
    svButtonTransparency:
      Result := InternalGetButtonTransparency(AButtonTransparency);
    svGradient:
      Result := InternalGetGradient(ATempBool);
    svGradientButtons:
      Result := InternalGetGradientButtons(ATempBool);
    svGradientDirection:
      Result := InternalGetGradientDirection(AGradientDirection);
    svPopupBorderStyle:
      Result := InternalGetPopupBorderStyle(APopupBorderStyle);
    else
      Result := inherited IsValueAssigned(AValue);
  end;
end;

procedure TcxCustomEditStyle.Init(AParams: TcxViewParams);
begin
  BeginUpdate;
  try
    Color := AParams.Color;
    Font := AParams.Font;
    TextColor := AParams.TextColor;
  finally
    EndUpdate;
  end;
end;

function TcxCustomEditStyle.GetAssignedValues: TcxEditStyleValues;
begin
  Result := TcxEditStyleValues(inherited AssignedValues);
end;

function TcxCustomEditStyle.GetBaseStyle: TcxCustomEditStyle;
begin
  Result := TcxCustomEditStyle(inherited BaseStyle);
end;

function TcxCustomEditStyle.GetDefaultStyleController: TcxStyleController;
var
  AEdit: TcxCustomEdit;
begin
  Result := nil;
  if not DirectAccessMode then
  begin
    AEdit := Edit;
    if not((AEdit <> nil) and AEdit.IsInplace) then
      Result := DefaultEditStyleController;
  end;
end;

function TcxCustomEditStyle.InternalGetNotPublishedExtendedStyleValues: TcxEditStyleValues;
begin
  Result := [svButtonTransparency, svEdges, svFont, svGradient,
    svGradientButtons, svGradientDirection, svHotTrack, svPopupBorderStyle,
    svShadow, svTransparentBorder];
end;

function TcxCustomEditStyle.DefaultButtonStyle: TcxEditButtonStyle;
begin
  if IsBaseStyle then
    Result := btsDefault
  else
    Result := TcxCustomEditStyle(ParentStyle).ButtonStyle;
end;

function TcxCustomEditStyle.DefaultButtonTransparency: TcxEditButtonTransparency;
begin
  if IsBaseStyle then
    Result := ebtNone
  else
    Result := TcxCustomEditStyle(ParentStyle).ButtonTransparency;
end;

function TcxCustomEditStyle.DefaultGradient: Boolean;
begin
  if IsBaseStyle then
    Result := False
  else
    Result := TcxCustomEditStyle(ParentStyle).Gradient;
end;

function TcxCustomEditStyle.DefaultGradientButtons: Boolean;
begin
  if IsBaseStyle then
    Result := False
  else
    Result := TcxCustomEditStyle(ParentStyle).GradientButtons;
end;

function TcxCustomEditStyle.DefaultGradientDirection: TcxEditGradientDirection;
begin
  if IsBaseStyle then
    Result := dirDown
  else
    Result := TcxCustomEditStyle(ParentStyle).GradientDirection;
end;

function TcxCustomEditStyle.DefaultPopupBorderStyle: TcxEditPopupBorderStyle;
begin
  if IsBaseStyle then
    Result := epbsDefault
  else
    Result := TcxCustomEditStyle(ParentStyle).PopupBorderStyle;
end;

function TcxCustomEditStyle.GetActiveStyleController: TcxEditStyleController;
begin
  Result := TcxEditStyleController(inherited ActiveStyleController);
end;

function TcxCustomEditStyle.GetBorderStyle: TcxEditBorderStyle;
begin
  Result := TcxEditBorderStyle(inherited BorderStyle);
end;

function TcxCustomEditStyle.GetButtonStyle: TcxEditButtonStyle;
begin
  if DirectAccessMode then
    if svButtonStyle in FAssignedValues then
      Result := FButtonStyle
    else
      Result := DefaultButtonStyle
  else
    if not InternalGetButtonStyle(Result) then
      Result := DefaultButtonStyle;
end;

function TcxCustomEditStyle.GetButtonTransparency: TcxEditButtonTransparency;
begin
  if DirectAccessMode then
    if svButtonTransparency in FAssignedValues then
      Result := FButtonTransparency
    else
      Result := DefaultButtonTransparency
  else
    if not InternalGetButtonTransparency(Result) then
      Result := DefaultButtonTransparency;
end;

function TcxCustomEditStyle.GetEdit: TcxCustomEdit;
var
  AOwner: TPersistent;
begin
  AOwner := GetOwner;
  if AOwner is TcxCustomEdit then
    Result := TcxCustomEdit(AOwner)
  else
    Result := nil;
end;

function TcxCustomEditStyle.GetGradient: Boolean;
begin
  if DirectAccessMode then
    if svGradient in FAssignedValues then
      Result := FGradient
    else
      Result := DefaultGradient
  else
    if not InternalGetGradient(Result) then
      Result := DefaultGradient;
end;

function TcxCustomEditStyle.GetGradientButtons: Boolean;
begin
  if DirectAccessMode then
    if svGradientButtons in FAssignedValues then
      Result := FGradientButtons
    else
      Result := DefaultGradientButtons
  else
    if not InternalGetGradientButtons(Result) then
      Result := DefaultGradientButtons;
end;

function TcxCustomEditStyle.GetGradientDirection: TcxEditGradientDirection;
begin
  if DirectAccessMode then
    if svGradientDirection in FAssignedValues then
      Result := FGradientDirection
    else
      Result := DefaultGradientDirection
  else
    if not InternalGetGradientDirection(Result) then
      Result := DefaultGradientDirection;
end;

function TcxCustomEditStyle.GetPopupBorderStyle: TcxEditPopupBorderStyle;
begin
  if DirectAccessMode then
    if svPopupBorderStyle in FAssignedValues then
      Result := FPopupBorderStyle
    else
      Result := DefaultPopupBorderStyle
  else
    if not InternalGetPopupBorderStyle(Result) then
      Result := DefaultPopupBorderStyle;
end;

function TcxCustomEditStyle.GetStyleController: TcxEditStyleController;
begin
  Result := TcxEditStyleController(BaseGetStyleController);
end;

function TcxCustomEditStyle.GetPopupCloseButton: Boolean;
begin
  if IsBaseStyle then
    Result := FPopupCloseButton
  else
    Result := TcxCustomEditStyle(ParentStyle).PopupCloseButton;
end;

function TcxCustomEditStyle.InternalGetButtonStyle(var ButtonStyle: TcxEditButtonStyle): Boolean;
begin
  Result := svButtonStyle in FAssignedValues;
  if Result then
    ButtonStyle := FButtonStyle
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetButtonStyle(ButtonStyle);
end;

function TcxCustomEditStyle.InternalGetButtonTransparency(var ButtonTransparency: TcxEditButtonTransparency): Boolean;
begin
  Result := svButtonTransparency in FAssignedValues;
  if Result then
    ButtonTransparency := FButtonTransparency
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetButtonTransparency(ButtonTransparency);
end;

function TcxCustomEditStyle.InternalGetGradient(var Gradient: Boolean): Boolean;
begin
  Result := svGradient in FAssignedValues;
  if Result then
    Gradient := FGradient
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetGradient(Gradient);
end;

function TcxCustomEditStyle.InternalGetGradientButtons(var GradientButtons: Boolean): Boolean;
begin
  Result := svGradientButtons in FAssignedValues;
  if Result then
    GradientButtons := FGradientButtons
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetGradientButtons(GradientButtons);
end;

function TcxCustomEditStyle.InternalGetGradientDirection(
  var GradientDirection: TcxEditGradientDirection): Boolean;
begin
  Result := svGradientDirection in FAssignedValues;
  if Result then
    GradientDirection := FGradientDirection
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetGradientDirection(GradientDirection);
end;

function TcxCustomEditStyle.InternalGetPopupBorderStyle(var PopupBorderStyle:
  TcxEditPopupBorderStyle): Boolean;
begin
  Result := svPopupBorderStyle in FAssignedValues;
  if Result then
    PopupBorderStyle := FPopupBorderStyle
  else
    if ActiveStyleController <> nil then
      Result := ActiveStyleController.Styles[TcxContainerStateItem(State)].InternalGetPopupBorderStyle(PopupBorderStyle);
end;

function TcxCustomEditStyle.IsBorderStyleStored: Boolean;
begin
  Result := (svBorderStyle in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('BorderStyle', State <> csNormal));
end;

function TcxCustomEditStyle.IsButtonStyleStored: Boolean;
begin
  Result := (svButtonStyle in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('ButtonStyle', State <> csNormal));
end;

function TcxCustomEditStyle.IsButtonTransparencyStored: Boolean;
begin
  Result := (svButtonTransparency in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('ButtonTransparency', State <> csNormal));
end;

function TcxCustomEditStyle.IsGradientStored: Boolean;
begin
  Result := (svGradient in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('Gradient', State <> csNormal));
end;

function TcxCustomEditStyle.IsGradientButtonsStored: Boolean;
begin
  Result := (svGradientButtons in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('GradientButtons', State <> csNormal));
end;

function TcxCustomEditStyle.IsGradientDirectionStored: Boolean;
begin
  Result := (svGradientDirection in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('GradientDirection', State <> csNormal));
end;

function TcxCustomEditStyle.IsPopupBorderStyleStored: Boolean;
begin
  Result := (svPopupBorderStyle in FAssignedValues) and ((Edit = nil) or
    Edit.IsStylePropertyPublished('PopupBorderStyle', State <> csNormal));
end;

function TcxCustomEditStyle.IsStyleControllerStored: Boolean;
begin
  Result := State = csNormal;
end;

procedure TcxCustomEditStyle.SetAssignedValues(Value: TcxEditStyleValues);
begin
  inherited AssignedValues := Value;
end;

procedure TcxCustomEditStyle.SetBorderStyle(Value: TcxEditBorderStyle);
begin
  inherited BorderStyle := TcxContainerBorderStyle(Value);
end;

procedure TcxCustomEditStyle.SetButtonStyle(Value: TcxEditButtonStyle);
begin
  if (svButtonStyle in FAssignedValues) and (Value = FButtonStyle) then
    Exit;
  FButtonStyle := Value;
  Include(FAssignedValues, svButtonStyle);
  Changed;
end;

procedure TcxCustomEditStyle.SetButtonTransparency(Value: TcxEditButtonTransparency);
begin
  if IsBaseStyle then
  begin
    if (svButtonTransparency in FAssignedValues) and (Value = FButtonTransparency) then
      Exit;
    FButtonTransparency := Value;
    Include(FAssignedValues, svButtonTransparency);
    Changed;
  end
  else
    TcxCustomEditStyle(ParentStyle).ButtonTransparency := Value;
end;

procedure TcxCustomEditStyle.SetGradient(Value: Boolean);
begin
  if IsBaseStyle then
  begin
    if (svGradient in FAssignedValues) and (Value = FGradient) then
      Exit;
    FGradient := Value;
    Include(FAssignedValues, svGradient);
    Changed;
  end
  else
    TcxCustomEditStyle(ParentStyle).Gradient := Value;
end;

procedure TcxCustomEditStyle.SetGradientButtons(Value: Boolean);
begin
  if IsBaseStyle then
  begin
    if (svGradientButtons in FAssignedValues) and (Value = FGradientButtons) then
      Exit;
    FGradientButtons := Value;
    Include(FAssignedValues, svGradientButtons);
    Changed;
  end
  else
    TcxCustomEditStyle(ParentStyle).GradientButtons := Value;
end;

procedure TcxCustomEditStyle.SetGradientDirection(Value: TcxEditGradientDirection);
begin
  if IsBaseStyle then
  begin
    if (svGradientDirection in FAssignedValues) and (Value = FGradientDirection) then
      Exit;
    FGradientDirection := Value;
    Include(FAssignedValues, svGradientDirection);
    Changed;
  end
  else
    TcxCustomEditStyle(ParentStyle).GradientDirection := Value;
end;

procedure TcxCustomEditStyle.SetPopupBorderStyle(Value: TcxEditPopupBorderStyle);
begin
  if IsBaseStyle then
  begin
    if (svPopupBorderStyle in FAssignedValues) and (Value = FPopupBorderStyle) then
      Exit;
    FPopupBorderStyle := Value;
    Include(FAssignedValues, svPopupBorderStyle);
    Changed;
  end
  else
    TcxCustomEditStyle(ParentStyle).PopupBorderStyle := Value;
end;

procedure TcxCustomEditStyle.SetPopupCloseButton(Value: Boolean);
begin
  if IsBaseStyle then
  begin
    if Value <> FPopupCloseButton then
    begin
      FPopupCloseButton := Value;
      Changed;
    end;
  end
  else
    TcxCustomEditStyle(ParentStyle).PopupCloseButton := Value;
end;

procedure TcxCustomEditStyle.SetStyleController(Value: TcxEditStyleController);
begin
  BaseSetStyleController(Value);
end;

{ TcxCustomEditPropertiesValues }

constructor TcxCustomEditPropertiesValues.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TcxCustomEditPropertiesValues.Assign(Source: TPersistent);
begin
  if Source is TcxCustomEditPropertiesValues then
  begin
    BeginUpdate;
    try
      with Source as TcxCustomEditPropertiesValues do
      begin
        Self.MaxValue := MaxValue;
        Self.MinValue := MinValue;
        Self.ReadOnly := ReadOnly;
      end;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomEditPropertiesValues.BeginUpdate;
begin
  Properties.BeginUpdate;
end;

procedure TcxCustomEditPropertiesValues.EndUpdate;
begin
  Properties.EndUpdate;
end;

procedure TcxCustomEditPropertiesValues.RestoreDefaults;
begin
  BeginUpdate;
  try
    MaxValue := False;
    MinValue := False;
    ReadOnly := False;
  finally
    EndUpdate;
  end;
end;

function TcxCustomEditPropertiesValues.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxCustomEditPropertiesValues.Changed;
begin
  Properties.Changed;
end;

function TcxCustomEditPropertiesValues.IsMaxValueStored: Boolean;
begin
  Result := MaxValue and
    (TcxCustomEditProperties(Properties).MaxValue = 0{TcxCustomEditProperties(Properties).GetDefaultMaxValue}) and
    IsPropertiesPropertyVisible('MaxValue');
end;

function TcxCustomEditPropertiesValues.IsMinValueStored: Boolean;
begin
  Result := MinValue and
    (TcxCustomEditProperties(Properties).MinValue = 0{TcxCustomEditProperties(Properties).GetDefaultMinValue}) and
    IsPropertiesPropertyVisible('MinValue');
end;

function TcxCustomEditPropertiesValues.IsPropertiesPropertyVisible(
  const APropertyName: string): Boolean;
begin
  Result := TypInfo.GetPropInfo(Properties, APropertyName) <> nil;
end;

function TcxCustomEditPropertiesValues.GetProperties: TcxCustomEditProperties;
begin
  Result := TcxCustomEditProperties(FOwner);
end;

procedure TcxCustomEditPropertiesValues.SetMaxValue(Value: Boolean);
begin
  if Value <> FMaxValue then
  begin
    FMaxValue := Value;
    Changed;
  end;
end;

procedure TcxCustomEditPropertiesValues.SetMinValue(Value: Boolean);
begin
  if Value <> FMinValue then
  begin
    FMinValue := Value;
    Changed;
  end;
end;

procedure TcxCustomEditPropertiesValues.SetReadOnly(Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
    Changed;
  end;
end;

{ TcxCustomEditDefaultValuesProvider }

destructor TcxCustomEditDefaultValuesProvider.Destroy;
begin
  ClearUsers;
  inherited Destroy;
end;

function TcxCustomEditDefaultValuesProvider.CanSetEditMode: Boolean;
begin
  Result := True;
end;

procedure TcxCustomEditDefaultValuesProvider.ClearUsers;
var
  I: Integer;
begin
  if FCreatedEditPropertiesList <> nil then
    for I := 0 to FCreatedEditPropertiesList.Count - 1 do
      with TcxCustomEditProperties(FCreatedEditPropertiesList[I]) do
        if (IDefaultValuesProvider <> nil) and (IDefaultValuesProvider.GetInstance = Self) then
          DefaultValuesProviderDestroyed;
end;

function TcxCustomEditDefaultValuesProvider.DefaultAlignment: TAlignment;
begin
  Result := cxEditDefaultHorzAlignment;
end;

function TcxCustomEditDefaultValuesProvider.DefaultBlobKind: TcxBlobKind;
begin
  Result := bkMemo;
end;

function TcxCustomEditDefaultValuesProvider.DefaultCanModify: Boolean;
begin
  Result := True;
end;

function TcxCustomEditDefaultValuesProvider.DefaultDisplayFormat: string;
begin
  Result := '';
end;

function TcxCustomEditDefaultValuesProvider.DefaultEditFormat: string;
begin
  Result := '';
end;

function TcxCustomEditDefaultValuesProvider.DefaultEditMask: string;
begin
  Result := '';
end;

function TcxCustomEditDefaultValuesProvider.DefaultIsFloatValue: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.DefaultMaxLength: Integer;
begin
  Result := 0;
end;

function TcxCustomEditDefaultValuesProvider.DefaultMaxValue: Double;
begin
  Result := 0;
end;

function TcxCustomEditDefaultValuesProvider.DefaultMinValue: Double;
begin
  Result := 0;
end;

function TcxCustomEditDefaultValuesProvider.DefaultPrecision: Integer;
begin
  Result := cxEditDefaultPrecision;
end;

function TcxCustomEditDefaultValuesProvider.DefaultReadOnly: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.DefaultRequired: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.GetInstance: TObject;
begin
  Result := Self;
end;

function TcxCustomEditDefaultValuesProvider.IsBlob: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsCurrency: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsDataAvailable: Boolean;
begin
  Result := True;
end;

function TcxCustomEditDefaultValuesProvider.IsDataStorage: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsDisplayFormatDefined(
  AIsCurrencyValueAccepted: Boolean): Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsOnGetTextAssigned: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsOnSetTextAssigned: Boolean;
begin
  Result := False;
end;

function TcxCustomEditDefaultValuesProvider.IsValidChar(AChar: Char): Boolean;
begin
  Result := True;
end;

{ TcxCustomEditProperties }

constructor TcxCustomEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FCreatedEditPropertiesList.Add(Self);
  FOwner := AOwner;
  FFreeNotificator := TcxFreeNotificator.Create(nil);
  FFreeNotificator.OnFreeNotification := FreeNotification;
  FAlignment := TcxEditAlignment.Create(Self);
  FAlignment.OnChanged := AlignmentChangedHandler;
  FAssignedValues := GetAssignedValuesClass.Create(Self);
  FAutoSelect := True;
  FButtons := GetButtonsClass.Create(Self, GetButtonsClass.GetButtonClass);
  FButtons.OnChange := ButtonsChanged;
  FButtonsViewStyle := bvsNormal;
  FClickKey := VK_RETURN + scCtrl;
  FUseLeftAlignmentOnEditing := DefaultUseLeftAlignmentOnEditing;
  FUseMouseWheel := True;
  FInnerAlignment := TcxEditAlignment.Create(Self);
  FUpdateCount := 0;
end;

destructor TcxCustomEditProperties.Destroy;
begin
  ClearPropertiesDestroyingListeners(Self);
  FIDefaultValuesProvider := nil;
  FreeAndNil(FButtons);
  FreeAndNil(FInnerAlignment);
  FreeAndNil(FAssignedValues);
  FreeAndNil(FAlignment);
  FreeAndNil(FFreeNotificator);
  if FCreatedEditPropertiesList <> nil then
    FCreatedEditPropertiesList.Remove(Self);
  inherited Destroy;
end;

procedure TcxCustomEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomEditProperties then
  begin
    BeginUpdate;
    try
      with Source as TcxCustomEditProperties do
      begin
        Self.AutoSelect := AutoSelect;
        Self.Buttons.Assign(Buttons);
        Self.ButtonsViewStyle := ButtonsViewStyle;
        Self.BeepOnError := BeepOnError;
        Self.ClearKey := ClearKey;
        Self.ClickKey := ClickKey;
        Self.FUseLeftAlignmentOnEditing := FUseLeftAlignmentOnEditing;
        Self.FIDefaultValuesProvider := FIDefaultValuesProvider;
        Self.Alignment := Alignment;

        Self.AssignedValues.MaxValue := False;
        if AssignedValues.MaxValue then
          Self.MaxValue := MaxValue;

        Self.AssignedValues.MinValue := False;
        if AssignedValues.MinValue then
          Self.MinValue := MinValue;

        Self.AssignedValues.ReadOnly := False;
        if AssignedValues.ReadOnly then
          Self.ReadOnly := ReadOnly;

        Self.ImmediatePost := ImmediatePost;
        Self.Transparent := Transparent;
        Self.UseMouseWheel := UseMouseWheel;
        Self.ValidateOnEnter := ValidateOnEnter;

        Self.OnButtonClick := OnButtonClick;
        Self.OnChange := OnChange;
        Self.OnEditValueChanged := OnEditValueChanged;
        Self.OnValidate := OnValidate;
      end
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomEditProperties.CanCompareEditValue: Boolean;
begin
  Result := False;
end;

class function TcxCustomEditProperties.GetButtonsClass: TcxEditButtonsClass;
begin
  Result := TcxEditButtons;
end;

class function TcxCustomEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxCustomEdit;
end;

class function TcxCustomEditProperties.GetStyleClass: TcxCustomEditStyleClass;
begin
  Result := TcxEditStyle;
end;

class function TcxCustomEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomEditViewInfo;
end;

procedure TcxCustomEditProperties.BeginUpdate;
begin
  if FUpdateCount = 0 then
    FChangedOccurred := False;
  Inc(FUpdateCount);
end;

procedure TcxCustomEditProperties.Changed;

  function CanFireEvent: Boolean;
  begin
    Result := not ChangedLocked and not((GetOwner is TComponent) and
      (csDestroying in TComponent(GetOwner).ComponentState));
  end;

begin
  if not CanFireEvent then
    FChangedOccurred := True
  else
    if Assigned(FOnPropertiesChanged) then
    begin
      Inc(FIsChangingCount);
      try
        FOnPropertiesChanged(Self);
      finally
        Dec(FIsChangingCount);
      end;
    end;
end;

function TcxCustomEditProperties.ChangedLocked: Boolean;
begin
  Result := FChangedLocked or (FUpdateCount > 0);
end;

function TcxCustomEditProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
var
  ADisplayValue1, ADisplayValue2: TcxEditValue;
begin
  PrepareDisplayValue(AEditValue1, ADisplayValue1, False);
  PrepareDisplayValue(AEditValue2, ADisplayValue2, False);
  Result := ADisplayValue1 = ADisplayValue2;
end;

function TcxCustomEditProperties.CreatePreviewProperties: TcxCustomEditProperties;
begin
  Result := TcxCustomEditPropertiesClass(ClassType).Create(nil);
end;

function TcxCustomEditProperties.CreateViewData(AStyle: TcxCustomEditStyle;
  AIsInplace: Boolean; APreviewMode: Boolean = False): TcxCustomEditViewData;
begin
  Result := TcxCustomEditViewDataClass(GetViewDataClass).Create(Self, AStyle, AIsInplace);
  Result.PreviewMode := APreviewMode;
end;

procedure TcxCustomEditProperties.DataChanged;
begin
end;

procedure TcxCustomEditProperties.EndUpdate(AInvokeChanged: Boolean = True);
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if (FUpdateCount = 0) and AInvokeChanged and FChangedOccurred then
      Changed;
  end;
end;

function TcxCustomEditProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
begin
  Result := '';
end;

function TcxCustomEditProperties.GetEditConstantPartSize(ACanvas: TcxCanvas;
  AEditStyle: TcxCustomEditStyle; AIsInplace: Boolean;
  const AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize): TSize;
var
  AViewData: TcxCustomEditViewData;
begin
  AViewData := TcxCustomEditViewData(CreateViewData(AEditStyle, AIsInplace));
  try
    Result := AViewData.GetEditConstantPartSize(ACanvas, AEditSizeProperties,
      MinContentSize);
  finally
    FreeAndNil(AViewData);
  end;
end;

function TcxCustomEditProperties.GetEditContentSize(ACanvas: TcxCanvas;
  AEditStyle: TcxCustomEditStyle; AIsInplace: Boolean;  const AEditValue: TcxEditValue;
  const AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  AViewData: TcxCustomEditViewData;
begin
  AViewData := TcxCustomEditViewData(CreateViewData(AEditStyle, AIsInplace));
  try
    Result := AViewData.GetEditContentSize(ACanvas, AEditValue, AEditSizeProperties);
  finally
    FreeAndNil(AViewData);
  end;
end;

function TcxCustomEditProperties.GetEditSize(ACanvas: TcxCanvas;
  AEditStyle: TcxCustomEditStyle; AIsInplace: Boolean; const AEditValue: TcxEditValue;
  AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  AViewData: TcxCustomEditViewData;
begin
  AViewData := TcxCustomEditViewData(CreateViewData(AEditStyle, AIsInplace));
  try
    Result := AViewData.GetEditSize(ACanvas, AEditValue, AEditSizeProperties);
  finally
    FreeAndNil(AViewData);
  end;
end;

function TcxCustomEditProperties.GetSpecialFeatures: TcxEditSpecialFeatures;
begin
  Result := [];
end;

function TcxCustomEditProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  if Buttons.Count > 0 then
    Result := [esoHotTrack]
  else
    Result := [];
end;

function TcxCustomEditProperties.IsActivationKey(AKey: Char): Boolean;
begin
  Result := False;
end;

function TcxCustomEditProperties.IsEditValueValid(var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := True;
end;

procedure TcxCustomEditProperties.RestoreDefaults;
begin
  FInnerAlignment.Reset;
  BeginUpdate;
  try
    AssignedValues.RestoreDefaults;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomEditProperties.Update(AProperties: TcxCustomEditProperties);
begin
end;

procedure TcxCustomEditProperties.ValidateDisplayValue(
  var ADisplayValue: TcxEditValue; var AErrorText: TCaption;
  var AError: Boolean; AEdit: TcxCustomEdit);
var
  AIsUserErrorDisplayValue: Boolean;
begin
  if not CanValidate then
    Exit;
  if AErrorText = '' then
    AErrorText := GetValidateErrorText(ekDefault);
  DoValidate(ADisplayValue, AErrorText, AError, AEdit, AIsUserErrorDisplayValue);
end;

procedure TcxCustomEditProperties.AlignmentChangedHandler(Sender: TObject);
begin
  FInnerAlignment.Assign(FAlignment);
  Changed;
end;

procedure TcxCustomEditProperties.BaseSetAlignment(Value: TcxEditAlignment);
begin
  FInnerAlignment.Assign(Value);
  Changed;
end;

procedure TcxCustomEditProperties.ButtonsChanged(Sender: TObject);
begin
  Changed;
end;

function TcxCustomEditProperties.CanModify: Boolean;
begin
  Result := AssignedValues.ReadOnly and not FReadOnly;
  if not Result then
  begin
    Result := not ReadOnly;
    if Result and (IDefaultValuesProvider <> nil) then
      Result := IDefaultValuesProvider.DefaultCanModify and
        IDefaultValuesProvider.CanSetEditMode;
  end;
end;

function TcxCustomEditProperties.CanValidate: Boolean;
begin
  Result := False;
end;

procedure TcxCustomEditProperties.FillMinMaxValues(AMinValue, AMaxValue: Double);
begin
  if AssignedValues.MaxValue and (AMaxValue = FMaxValue) and
      AssignedValues.MinValue and (AMinValue = FMinValue) then
    Exit;

  AssignedValues.FMaxValue := True;
  FMaxValue := AMaxValue;
  AssignedValues.FMinValue := True;
  FMinValue := AMinValue;
  Changed;
end;

class function TcxCustomEditProperties.GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass;
begin
  Result := TcxCustomEditPropertiesValues;
end;

function TcxCustomEditProperties.GetDefaultHorzAlignment: TAlignment;
begin
  if IDefaultValuesProvider <> nil then
    Result := IDefaultValuesProvider.DefaultAlignment
  else
    Result := FAlignment.Horz;
end;

function TcxCustomEditProperties.GetDisplayFormatOptions: TcxEditDisplayFormatOptions;
begin
  Result := [];
end;

function TcxCustomEditProperties.GetMaxValue: Double;
begin
  if AssignedValues.MaxValue then
    Result := FMaxValue
  else
    if IDefaultValuesProvider = nil then
      Result := 0
    else
      Result := IDefaultValuesProvider.DefaultMaxValue;
end;

function TcxCustomEditProperties.GetMinValue: Double;
begin
  if AssignedValues.MinValue then
    Result := FMinValue
  else
    if IDefaultValuesProvider = nil then
      Result := 0
    else
      Result := IDefaultValuesProvider.DefaultMinValue;
end;

function TcxCustomEditProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsValue;
end;

function TcxCustomEditProperties.GetValidateErrorText(AErrorKind: TcxEditErrorKind): string;
begin
  Result := cxGetResourceString(@cxSEditValidateErrorText);
end;

function TcxCustomEditProperties.GetValueEditorEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := evsValue;
  if not AEditFocused and (dfoSupports in DisplayFormatOptions) and (IDefaultValuesProvider <> nil) and
      IDefaultValuesProvider.IsDisplayFormatDefined(not(dfoNoCurrencyValue in DisplayFormatOptions)) then
    Result := evsText;
end;

class function TcxCustomEditProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomEditViewData;
end;

function TcxCustomEditProperties.HasDisplayValue: Boolean;
begin
  Result := False;
end;

function TcxCustomEditProperties.InnerEditNeedsTabs: Boolean;
begin
  Result := False;
end;

function TcxCustomEditProperties.IsEditValueConversionDependOnFocused: Boolean;
begin
  Result := True;
end;

function TcxCustomEditProperties.IsMaxValueStored: Boolean;
begin
  Result := AssignedValues.MaxValue;
end;

function TcxCustomEditProperties.IsMinValueStored: Boolean;
begin
  Result := AssignedValues.MinValue;
end;

function TcxCustomEditProperties.IsResetEditClass: Boolean;
begin
  Result := False;
end;

function TcxCustomEditProperties.IsValueEditorWithValueFormatting: Boolean;
begin
  Result := (dfoSupports in DisplayFormatOptions) and (GetEditValueSource(True) = evsValue) and
    (GetEditValueSource(False) = evsText) and (IDefaultValuesProvider <> nil) and
    IDefaultValuesProvider.IsDisplayFormatDefined(not(dfoNoCurrencyValue in DisplayFormatOptions));
end;

procedure TcxCustomEditProperties.LockUpdate(ALock: Boolean);
begin
  FChangedLocked := ALock;
end;

procedure TcxCustomEditProperties.PrepareDisplayValue(const AEditValue: TcxEditValue;
  var DisplayValue: TcxEditValue; AEditFocused: Boolean);
begin
  DisplayValue := AEditValue;
end;

function TcxCustomEditProperties.DefaultUseLeftAlignmentOnEditing: Boolean;
begin
  Result := cxEditDefaultUseLeftAlignmentOnEditing;
end;

procedure TcxCustomEditProperties.DefaultValuesProviderDestroyed;
begin
  FIDefaultValuesProvider := nil;
end;

procedure TcxCustomEditProperties.DoValidate(var ADisplayValue: TcxEditValue;
  var AErrorText: TCaption; var AError: Boolean; AEdit: TcxCustomEdit;
  out AIsUserErrorDisplayValue: Boolean);
var
  APrevDisplayValue: TcxEditValue;
begin
  AIsUserErrorDisplayValue := False;
  if AEdit.IsOnValidateEventAssigned then
  begin
    APrevDisplayValue := ADisplayValue;
    AEdit.DoOnValidate(ADisplayValue, AErrorText, AError);
    if AError then
    begin
      AIsUserErrorDisplayValue := not InternalCompareString(APrevDisplayValue,
        ADisplayValue, True);
      if not AIsUserErrorDisplayValue then
        ADisplayValue := AEdit.DisplayValue;
    end;
  end;
end;

procedure TcxCustomEditProperties.FreeNotification(Sender: TComponent);
begin
end;

function TcxCustomEditProperties.BaseGetAlignment: TcxEditAlignment;
var
  AOwnerComponent: TComponent;
begin
  FAlignment.OnChanged := nil;
  FAlignment.Assign(FInnerAlignment);
  Result := FAlignment;
  if IsAlignmentStored then
  begin
    AOwnerComponent := GetOwnerComponent(Self);
    if (AOwnerComponent <> nil) and (csWriting in AOwnerComponent.ComponentState) then
      Exit;
  end;

  if not FInnerAlignment.IsHorzStored then
    Result.FHorz := GetDefaultHorzAlignment;
  FAlignment.OnChanged := AlignmentChangedHandler;
end;

procedure TcxCustomEditProperties.DefaultValuesChanged(Sender: TObject);
begin
  Changed;
end;

function TcxCustomEditProperties.GetIsChanging: Boolean;
begin
  Result := FIsChangingCount > 0;
end;

function TcxCustomEditProperties.GetReadOnly: Boolean;
begin
  if AssignedValues.ReadOnly then
    Result := FReadOnly
  else
    if IDefaultValuesProvider = nil then
      Result := False
    else
      Result := IDefaultValuesProvider.DefaultReadOnly;
end;

function TcxCustomEditProperties.IsAlignmentStored: Boolean;
begin
  with FInnerAlignment do
    Result := IsHorzStored or IsVertStored;
end;

function TcxCustomEditProperties.IsUseLeftAlignmentOnEditingStored: Boolean;
begin
  Result := FUseLeftAlignmentOnEditing <> DefaultUseLeftAlignmentOnEditing;
end;

function TcxCustomEditProperties.IsReadOnlyStored: Boolean;
begin
  Result := AssignedValues.ReadOnly;
end;

procedure TcxCustomEditProperties.SetAssignedValues(
  Value: TcxCustomEditPropertiesValues);
begin
  FAssignedValues.Assign(Value);
end;

procedure TcxCustomEditProperties.SetAutoSelect(Value: Boolean);
begin
  if Value <> FAutoSelect then
  begin
    FAutoSelect := Value;
    Changed;
  end;
end;

procedure TcxCustomEditProperties.SetButtons(Value: TcxEditButtons);
begin
  FButtons.Assign(Value);
end;

procedure TcxCustomEditProperties.SetButtonsViewStyle(Value: TcxEditButtonsViewStyle);
begin
  if Value <> FButtonsViewStyle then
  begin
    FButtonsViewStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomEditProperties.SetUseLeftAlignmentOnEditing(Value: Boolean);
begin
  if Value <> FUseLeftAlignmentOnEditing then
  begin
    FUseLeftAlignmentOnEditing := Value;
    Changed;
  end;
end;

procedure TcxCustomEditProperties.SetIDefaultValuesProvider(Value: IcxEditDefaultValuesProvider);
begin
  FIDefaultValuesProvider := Value;
  if FOwner is TcxCustomEdit then
    DefaultValuesChanged(nil);
end;

procedure TcxCustomEditProperties.SetMaxValue(Value: Double);
begin
  if AssignedValues.MaxValue and (Value = FMaxValue) then
    Exit;

  AssignedValues.FMaxValue := True;
  FMaxValue := Value;
  Changed;
end;

procedure TcxCustomEditProperties.SetMinValue(Value: Double);
begin
  if AssignedValues.MinValue and (Value = FMinValue) then
    Exit;

  AssignedValues.FMinValue := True;
  FMinValue := Value;
  Changed;
end;

procedure TcxCustomEditProperties.SetReadOnly(Value: Boolean);
begin
  if AssignedValues.ReadOnly and (Value = FReadOnly) then
    Exit;
  AssignedValues.FReadOnly := True;
  FReadOnly := Value;
  Changed;
end;

procedure TcxCustomEditProperties.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    Changed;
  end;
end;

{ TcxEditDataBinding }

constructor TcxEditDataBinding.Create(AEdit: TcxCustomEdit);
begin
  inherited Create;
  FEdit := AEdit;
  FIDefaultValuesProvider := GetDefaultValuesProviderClass.Create(nil);
end;

destructor TcxEditDataBinding.Destroy;
begin
  FreeAndNil(FIDefaultValuesProvider);
  inherited Destroy;
end;

function TcxEditDataBinding.CanCheckEditorValue: Boolean;
begin
  Result := Edit.IsDesigning or not Edit.ModifiedAfterEnter;
end;

function TcxEditDataBinding.CanPostEditorValue: Boolean;
begin
  Result := Modified;
end;

function TcxEditDataBinding.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := False;
end;

class function TcxEditDataBinding.GetDefaultValuesProviderClass: TcxCustomEditDefaultValuesProviderClass;
begin
  Result := TcxCustomEditDefaultValuesProvider;
end;

procedure TcxEditDataBinding.SetModified;
begin
  if Edit.Focused then
    Edit.ModifiedAfterEnter := True; 
end;

function TcxEditDataBinding.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := False;
end;

procedure TcxEditDataBinding.UpdateDisplayValue;
begin
  Edit.SynchronizeDisplayValue;
end;

procedure TcxEditDataBinding.UpdateNotConnectedDBEditDisplayValue;
begin
end;

procedure TcxEditDataBinding.DefaultValuesChanged;
var
  AProperties: TcxCustomEditProperties;
begin
  AProperties := Edit.ActiveProperties;
  if Edit.RepositoryItem = nil then
    AProperties.DefaultValuesChanged(nil)
  else
  begin
    AProperties.BeginUpdate;
    try
      AProperties.DefaultValuesChanged(nil);
    finally
      AProperties.EndUpdate(False);
    end;
    Edit.PropertiesChanged(AProperties);
  end;
end;

function TcxEditDataBinding.GetDisplayValue: TcxEditValue;
begin
  Result := Edit.DisplayValue;
end;

function TcxEditDataBinding.GetEditDataBindingInstance: TcxEditDataBinding;
begin
  Result := Self;
end;

function TcxEditDataBinding.GetEditing: Boolean;
begin
  Result := Edit.ModifiedAfterEnter;
end;

function TcxEditDataBinding.GetModified: Boolean;
begin
  Result := Edit.ModifiedAfterEnter;
end;

function TcxEditDataBinding.GetOwner: TPersistent;
begin
  Result := FEdit;
end;

function TcxEditDataBinding.GetStoredValue: TcxEditValue;
begin
  Result := Edit.EditValue;
end;

function TcxEditDataBinding.IsNull: Boolean;
begin
  Result := False;
end;

procedure TcxEditDataBinding.Reset;
begin
  Edit.ResetEditValue;
end;

procedure TcxEditDataBinding.SetInternalDisplayValue(const Value: TcxEditValue);
begin
  Edit.SetInternalDisplayValue(Value);
end;

procedure TcxEditDataBinding.SetDisplayValue(const Value: TcxEditValue);
begin
  SetInternalDisplayValue(Value);
end;

function TcxEditDataBinding.SetEditMode: Boolean;
begin
  Edit.ModifiedAfterEnter := True;
  Result := True;
end;

procedure TcxEditDataBinding.SetStoredValue(const Value: TcxEditValue);
begin
end;

function TcxEditDataBinding.GetIDefaultValuesProvider: IcxEditDefaultValuesProvider;
begin
  Result := FIDefaultValuesProvider as IcxEditDefaultValuesProvider;
end;

function TcxEditDataBinding.GetIsDataAvailable: Boolean;
begin
  Result := IDefaultValuesProvider.IsDataAvailable;
end;

{ TcxCustomEditData }

constructor TcxCustomEditData.Create(AEdit: TcxCustomEdit);
begin
  inherited Create;
  FEdit := AEdit;
  FFreeNotificator := TcxFreeNotificator.Create(nil);
  FFreeNotificator.OnFreeNotification := FreeNotification;
  FFreeNotificator.AddSender(AEdit);
  Clear;
end;

destructor TcxCustomEditData.Destroy;
begin
  FFreeNotificator.Free;
  inherited Destroy;
end;

procedure TcxCustomEditData.Clear;
begin
  FCleared := True;
  if FEdit <> nil then
    FEdit.DoClearEditData(Self);
end;

procedure TcxCustomEditData.FreeNotification(AComponent: TComponent);
begin
  if AComponent = FEdit then
    FEdit := nil;
end;

{ TcxEditChangeEventsCatcher }

constructor TcxEditChangeEventsCatcher.Create(AEdit: TcxCustomEdit);
begin
  inherited Create;
  FEdit := AEdit;
end;

function TcxEditChangeEventsCatcher.IsLocked: Boolean;
begin
  Result := FLockCount > 0;
end;

procedure TcxEditChangeEventsCatcher.Lock(ALock: Boolean;
  AInvokeChangedOnUnlock: Boolean = True);
begin
  if ALock then
  begin
    if FLockCount = 0 then
    begin
      FOnChangeEvent := False;
      FOnEditValueChangedEvent := False;
    end;
    Inc(FLockCount);
  end
  else
    if FLockCount > 0 then
    begin
      Dec(FLockCount);
      if AInvokeChangedOnUnlock and (FLockCount = 0) and
        not(FEdit.IsLoading or FEdit.IsDestroying) then
      begin
        if OnChangeEvent and FEdit.IsOnChangeEventAssigned then
          FEdit.DoOnChange;
        if OnEditValueChangedEvent and FEdit.IsOnEditValueChangedEventAssigned then
          FEdit.DoOnEditValueChanged;
      end;
    end;
end;

{ TcxCustomEdit }

constructor TcxCustomEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAnchorX := MaxInt;
  FAnchorY := MaxInt;
  FIsCreating := True;
  Initialize;
  FIsCreating := False;
  if HandleAllocated then
    ShortRefreshContainer(False);
end;

constructor TcxCustomEdit.Create(AOwner: TComponent; AIsInplace: Boolean);
begin
  FIsInplace := AIsInplace;
  Create(AOwner);
end;

destructor TcxCustomEdit.Destroy;
begin
  if Assigned(dxISpellChecker) then
    dxISpellChecker.CheckFinish;
  FreeAndNil(FDblClickTimer);
  if FRepositoryItem <> nil then
    FRepositoryItem.RemoveListener(Self);
  if HasInnerEdit then
    FInnerEdit := nil;

  Properties.OnPropertiesChanged := nil;
  if not FIsInplace then
    Properties.IDefaultValuesProvider := nil;
  FreeAndNil(FDataBinding);

  FPrevModifiedList := nil;
  FreeAndNil(FProperties);
  FreeAndNil(FChangeEventsCatcher);
  inherited Destroy;
end;

procedure TcxCustomEdit.DefaultHandler(var Message);
var
  AMessage: TMessage;
begin
  AMessage := TMessage(Message);
  if not (IsInplace and (AMessage.Msg = WM_CONTEXTMENU)) then
    inherited;
end;

function TcxCustomEdit.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or FDataBinding.ExecuteAction(Action);
end;

procedure TcxCustomEdit.GetTabOrderList(List: TList);
begin
  inherited GetTabOrderList(List);
  if IsInplace and Visible then
    List.Remove(Parent);
end;

function TcxCustomEdit.IsInplace: Boolean;
begin
  Result := FIsInplace;
end;

function TcxCustomEdit.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or FDataBinding.UpdateAction(Action);
end;

procedure TcxCustomEdit.Activate(var AEditData: TcxCustomEditData);
begin
  if (AEditData = nil) and (GetEditDataClass <> nil) then
    AEditData := GetEditDataClass.Create(Self);
  FEditData := AEditData;
  DoClearEditData(FEditData);
  Visible := True;
  if HandleAllocated and CanFocus then
  begin
    SetFocus;
    if ActiveProperties.AutoSelect then
      SelectAll;
  end;
  SynchronizeDisplayValue;
  EditModified := False;
  InplaceParams.MultiRowParent := True;
end;

procedure TcxCustomEdit.ActivateByKey(Key: Char; var AEditData: TcxCustomEditData);
begin
  LockInnerEditRepainting;
  try
    Activate(AEditData);
    if SendActivationKey(Key) then
      SendKeyPress(Self, Key);
  finally
    UnlockInnerEditRepainting;
  end;
end;

procedure TcxCustomEdit.ActivateByMouse(Shift: TShiftState; X, Y: Integer;
  var AEditData: TcxCustomEditData);
var
  P: TPoint;
begin
  Activate(AEditData);
  P := Parent.ClientToScreen(Point(X, Y));
  P := ScreenToClient(P);
  if ssLeft in Shift then
  begin
    SendMouseEvent(Self, WM_MOUSEMOVE, [], P);
    SendMouseEvent(Self, WM_LBUTTONDOWN, Shift, P);
    if (GetCaptureControl = Self) and not(ssLeft in InternalGetShiftState) then
      SetCaptureControl(nil);
  end
  else
    SendMouseEvent(Self, WM_LBUTTONUP, Shift, P);
  FDblClickTimer.Enabled := True;
end;

function TcxCustomEdit.AreChangeEventsLocked: Boolean;
begin
  Result := ChangeEventsCatcher.IsLocked;
end;

function TcxCustomEdit.CanPostEditValue: Boolean;
begin
  Result := not IsDesigning and DataBinding.CanPostEditorValue;
end;

procedure TcxCustomEdit.Clear;
begin
  EditValue := GetClearValue;
end;

procedure TcxCustomEdit.CopyToClipboard;
begin
end;

procedure TcxCustomEdit.CutToClipboard;
begin
end;

function TcxCustomEdit.Deactivate: Boolean;

  procedure ForceConvertingDisplayValueToEditValue;
  begin
    KeyboardAction := False;
  end;

begin
  FDblClickTimer.Enabled := False;
  Result := False;
  try
    ForceConvertingDisplayValueToEditValue;
    Result := ValidateEdit(True);
  finally
    if Result then
    begin
      SynchronizeDisplayValue;
      IsEditValidated := True;
    end;
  end;
end;

function TcxCustomEdit.DoEditing: Boolean;

  procedure DoOnEditing;
  begin
    if Assigned(FOnEditing) then
      FOnEditing(Self, Result);
  end;

  procedure StandaloneDoEditing;
  begin
    if not DataBinding.Editing then
    begin
      DoOnEditing;
      if Result then
      begin
        LockEditValueChanging(True);
        try
          Result := DataBinding.SetEditMode;
        finally
          LockEditValueChanging(False);
        end;
      end;
    end
    else
    begin
      DoOnEditing;
      if Result then
        DataBinding.SetModified;
    end;
  end;

  procedure InplaceDoEditing;
  begin
    LockEditValueChanging(True);
    try
      DoOnEditing;
    finally
      LockEditValueChanging(False);
    end;
  end;

begin
  Result := InternalDoEditing;
  if not Result then
    Exit;
  if DataBinding.Modified then
  begin
    Result := True;
    Exit;
  end;
  Result := CanModify;
  if not Result then
    Exit;

  FEditModeSetting := True;
  try
    if IsInplace then
      InplaceDoEditing
    else
      StandaloneDoEditing;
  finally
    FEditModeSetting := False;
  end;
end;

class function TcxCustomEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomEditProperties;
end;

procedure TcxCustomEdit.PasteFromClipboard;
begin
end;

procedure TcxCustomEdit.PostEditValue;
begin
  if CanPostEditValue then
    InternalPostEditValue(True)
  else
    if Focused then
      InternalPostValue;
end;

procedure TcxCustomEdit.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
begin
end;

procedure TcxCustomEdit.Reset;
begin
  DataBinding.Reset;
end;

procedure TcxCustomEdit.SelectAll;
begin
end;

function TcxCustomEdit.ValidateEdit(ARaiseExceptionOnError: Boolean): Boolean;
var
  ADisplayValue: TcxEditValue;
  AError: Boolean;
  AErrorText: TCaption;
begin
  if not (FModifiedAfterEnter and not FIsEditValidated and (FLockValidate = 0)) then
  begin
    Result := True;
    Exit;
  end;

  FIsEditValidating := True;
  try
    ADisplayValue := DisplayValue;
    AError := False;
    if ActiveProperties.CanValidate then
      ActiveProperties.ValidateDisplayValue(ADisplayValue, AErrorText, AError, Self);
    Result := not AError;
    if AError then
      try
        if ARaiseExceptionOnError then
        begin
          HandleValidationError(AErrorText, True);
          Application.ProcessMessages;
        end;
      finally
        if not InternalCompareString(ADisplayValue, DisplayValue, True) then
        begin
          SetInternalDisplayValue(ADisplayValue);
          if Visible then
          begin
            SelectAll;
            if not IsEditClass then
              UpdateDrawValue;
          end;
        end;
      end
    else
    begin
      if FKeyboardAction and not DoEditing then
        Exit;
      InternalValidateDisplayValue(ADisplayValue);
      if not IsInplace and not Focused then
        ModifiedAfterEnter := False;
      FIsEditValidated := True;
    end;
  finally
    FIsEditValidating := False;
  end;
end;

{$IFDEF DELPHI10}
function TcxCustomEdit.GetTextBaseLine: Integer;
begin
  Result := 0;
end;

function TcxCustomEdit.HasTextBaseLine: Boolean;
begin
  Result := False;
end;
{$ENDIF}

procedure TcxCustomEdit.CalculateAnchors;
begin
  if [csLoading, csReading] * ComponentState <> [] then
    Exit;
  if UseAnchorX then
  begin
    if ActiveProperties.Alignment.Horz = taCenter then
      FAnchorX := Left + Width div 2 + Integer(Width div 2 <> Width / 2)
    else
      FAnchorX := Left + Width;
  end;

  if UseAnchorY then
  begin
    if ActiveProperties.Alignment.Vert = taVCenter then
      FAnchorY := Top + Height div 2 + Integer(Height div 2 <> Height / 2)
    else
      FAnchorY := Top + Height;
  end;
end;

function TcxCustomEdit.CanContainerHandleTabs: Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanResize(NewWidth, NewHeight);
  if Result and not IsLoading then
    InternalCanResize(NewWidth, NewHeight);
end;

procedure TcxCustomEdit.Click;
begin
  if not IsDestroying and (FClickLockCount = 0) and
    (not IsLoading or IsClickEnabledDuringLoading) then
      inherited Click;
end;

procedure TcxCustomEdit.DblClick;
var
  P: TPoint;
  AButton: TMouseButton;
  AShiftState: TShiftState;
begin
  P := ScreenToClient(InternalGetCursorPos);
  if ButtonVisibleIndexAt(P) <> -1 then
  begin
    AButton := mbLeft;
    AShiftState := InternalGetShiftState;
    AShiftState := AShiftState + ButtonToShift(AButton);
    MouseDown(AButton, AShiftState, P.X, P.Y);
    Click;
  end
  else
    inherited DblClick;
end;

procedure TcxCustomEdit.DefineProperties(Filer: TFiler);

  function HasHeight: Boolean;
  begin
    Result := (Filer.Ancestor = nil) or (TcxCustomEdit(Filer.Ancestor).Height <> Height);
  end;

  function HasWidth: Boolean;
  begin
    Result := (Filer.Ancestor = nil) or (TcxCustomEdit(Filer.Ancestor).Width <> Width);
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Height', ReadHeight, WriteHeight, not CanAutoSize and HasHeight);
  Filer.DefineProperty('Width', ReadWidth, WriteWidth,
    not (CanAutoSize and CanAutoWidth) and HasWidth);
  Filer.DefineProperty('AnchorX', ReadAnchorX, WriteAnchorX, UseAnchorX);
  Filer.DefineProperty('AnchorY', ReadAnchorY, WriteAnchorY, UseAnchorY);
end;

procedure TcxCustomEdit.DoEnter;
begin
  if not IsDestroying then
  begin
    if not FValidateErrorProcessing then
      DoShowEdit;
    ShortRefreshContainer(False);
    if Assigned(dxISpellChecker) then
      dxISpellChecker.CheckStart(InnerControl);
  end;
end;

procedure TcxCustomEdit.DoExit;
var
  APrevKeyboardAction: Boolean;
begin
  APrevKeyboardAction := KeyboardAction;
  KeyboardAction := False;
  try
    if Assigned(dxISpellChecker) then
      dxISpellChecker.CheckFinish;
    DoHideEdit(True);
  finally
    KeyboardAction := APrevKeyboardAction;
  end;
end;

procedure TcxCustomEdit.FocusChanged;
var
  AFocused: Boolean;
begin
  if IsDestroying or FValidateErrorProcessing then
    Exit;
  AFocused := Focused and Application.Active;
  if FFocused = AFocused then
    Exit;
  FFocused := not FFocused;
  inherited FocusChanged;
  DoFocusChanged;
end;

function TcxCustomEdit.GetBorderExtent: TRect;
begin
  Result.Left := ViewInfo.ShadowRect.Left - ViewInfo.Bounds.Left;
  Result.Right := ViewInfo.Bounds.Right - ViewInfo.ShadowRect.Right;
  Result.Top := ViewInfo.ShadowRect.Top - ViewInfo.Bounds.Top;
  Result.Bottom := ViewInfo.Bounds.Bottom - ViewInfo.ShadowRect.Bottom;
end;

function TcxCustomEdit.GetEditStateColorKind: TcxEditStateColorKind;
begin
  Result := inherited GetEditStateColorKind;
  if (Result <> esckDisabled) and Properties.ReadOnly then
    Result := esckReadOnly;
end;

function TcxCustomEdit.GetStyleClass: TcxContainerStyleClass;
begin
  Result := GetPropertiesClass.GetStyleClass;
end;

function TcxCustomEdit.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomEditPropertiesClass(GetPropertiesClass).GetViewInfoClass;
end;

function TcxCustomEdit.InternalGetNotPublishedStyleValues:
  TcxEditStyleValues;
begin
  Result := [svButtonStyle, svButtonTransparency, svGradient, svGradientButtons,
    svGradientDirection, svPopupBorderStyle];
end;

function TcxCustomEdit.IsTransparentBackground: Boolean;
begin
  Result := IsNativeBackground or IsTransparent;
end;

procedure TcxCustomEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FIsEditValueResetting := False;
  FIsEscapeDown := Key = VK_ESCAPE;
  try
    if not IsEditorKey(Key, Shift) then
      inherited KeyDown(Key, Shift);
    if Key <> 0 then
      DoEditKeyDown(Key, Shift);
    if (Key <> 0) and NeedsInvokeAfterKeyDown(Key, Shift) then
      DoAfterKeyDown(Key, Shift);
  finally
    FIsEscapeDown := False;
  end;
end;

procedure TcxCustomEdit.KeyPress(var Key: Char);
begin
  if (Word(Key) = VK_ESCAPE) and FIsEditValueResetting then
  begin
    FIsEditValueResetting := False;
    Key := #0;
    Exit;
  end;

  inherited KeyPress(Key);
  if Key <> #0 then
    DoEditKeyPress(Key);
  if (Key <> #0) and Assigned(dxISpellChecker) then
    dxISpellChecker.KeyPress(Key);
end;

procedure TcxCustomEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if Key <> 0 then
    DoEditKeyUp(Key, Shift);
end;

procedure TcxCustomEdit.Loaded;
begin
  FIsFirstSetSize := True;
  inherited Loaded;
  LockChangeEvents(True);
  LockClick(True);
  try
    DataBinding.UpdateNotConnectedDBEditDisplayValue;
    ShortRefreshContainer(False);
//    SetSize;
    if FRepositoryItem = nil then
      Properties.OnPropertiesChanged := PropertiesChanged;
    PropertiesChanged(ActiveProperties);
    ViewInfo.Shadow := False;
    ContainerStyleChanged(FStyles.Style); // TODO remove
  finally
    LockClick(False);
    LockChangeEvents(False, False);
  end;
end;

procedure TcxCustomEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  AMouseMessages: array[TMouseButton] of UINT =
    (WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN);
var
  AButtonVisibleIndex: Integer;
  AControl: TWinControl;
  P: TPoint;
begin
  if (Button = mbLeft) and FDblClickTimer.Enabled then
  begin
    FDblClickTimer.Enabled := False;
    if ButtonVisibleIndexAt(ScreenToClient(InternalGetCursorPos)) = -1 then
      DblClick;
  end;

  inherited MouseDown(Button, Shift, X, Y);
  P := InternalGetCursorPos;
  if HandleAllocated and (WindowFromPoint(P) = Handle) then
  begin
    AControl := FindControl(WindowFromPoint(P));
    if (AControl <> nil) and (AControl <> Self) then
    begin
      P := AControl.ScreenToClient(P);
      CallWindowProc(TWinControlAccess(AControl).DefWndProc, AControl.Handle,
        AMouseMessages[Button], ShiftStateToKeys(InternalGetShiftState),
        MakeLong(P.X, P.Y));
    end;
  end;

  if (Button = mbLeft) and (GetCaptureControl = Self) then
  begin
    AButtonVisibleIndex := ButtonVisibleIndexAt(Point(X, Y));
    if (AButtonVisibleIndex <> -1) and
        (ViewInfo.ButtonsInfo[AButtonVisibleIndex].Data.State = ebsPressed) then
      FCaptureButtonVisibleIndex := AButtonVisibleIndex;
  end;
end;

procedure TcxCustomEdit.MouseLeave(AControl: TControl);
//var
//  I: Integer;
begin
  inherited MouseLeave(AControl);
//  for I := 0 to Length(ViewInfo.ButtonsInfo) - 1 do
//    with ViewInfo.ButtonsInfo[I] do
//      if Data.State = ebsSelected then
//      begin
//        Data.State := ebsNormal;
//        InvalidateRect(Bounds, HasBackground);
//      end;
end;

procedure TcxCustomEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FRepositoryItem) then
    RepositoryItem := nil;
end;

procedure TcxCustomEdit.Paint;
begin
  if IsDBEditPaintCopyDrawing then
    PaintCopyDraw
  else
  begin
    CheckIsViewInfoCalculated;
    ViewInfo.Paint(Canvas);
  end;
end;

procedure TcxCustomEdit.ReadState(Reader: TReader);
begin
  TcxCustomEditProperties(FProperties).OnPropertiesChanged := nil;
  inherited ReadState(Reader);
end;

function TcxCustomEdit.RefreshContainer(const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AIsMouseEvent: Boolean): Boolean;
var
  AViewInfo: TcxCustomEditViewInfo;
  R: TRect;
  AViewInfoChanged: Boolean;
begin
  Result := False;
  if not HandleAllocated or FIsCreating or (csDestroyingHandle in ControlState) or IsDestroying then
    Exit;
  IsViewInfoCalculated := True;

  if (FCaptureButtonVisibleIndex <> -1) and (GetCaptureControl <> Self) then
    FCaptureButtonVisibleIndex := -1;

  AViewInfo := nil;
  try
    if AIsMouseEvent then
    begin
      AViewInfo := TcxCustomEditViewInfo(TcxCustomEditProperties(Properties).GetViewInfoClass.Create);
      AViewInfo.Assign(ViewInfo);
    end;

    CalculateViewInfo(P, Button, Shift, AIsMouseEvent);

    if HasInnerEdit and IsEditClass then
      R := InnerEdit.Control.BoundsRect
    else
      R := cxEmptyRect;
    AViewInfoChanged := ViewInfo.Repaint(Self, R, AViewInfo);
    if (AViewInfo <> nil) and not AViewInfoChanged then
      Exit;

// TODO Incorrect CheckBox height calculation when assigning glyph
//    ViewInfo.Calculated := True;
//    try
      SetSize;
//    finally
//      ViewInfo.Calculated := False;
//    end;

    if HandleAllocated then
    begin
      FSettingEditWindowRegion := True;
      SetShadowRegion;
      FSettingEditWindowRegion := False;
    end;

    if (AViewInfo <> nil) and AViewInfoChanged then
      ProcessViewInfoChanges(AViewInfo, Button <> cxmbNone);
  finally
    FreeAndNil(AViewInfo);
  end;

  Result := True;
end;

procedure TcxCustomEdit.RequestAlign;
begin
  inherited RequestAlign;
  ShortRefreshContainer(False);
end;

procedure TcxCustomEdit.SetName(const Value: TComponentName);
begin
  inherited SetName(Value);
  DataBinding.UpdateNotConnectedDBEditDisplayValue;
end;

procedure TcxCustomEdit.SetParent(AParent: TWinControl);
begin
  if FIsJustCreated and (AParent <> nil) then
  begin
    FIsJustCreated := False;
    DataBinding.UpdateNotConnectedDBEditDisplayValue;
    PropertiesChanged(Properties);
    DataBinding.UpdateDisplayValue;
  end;
  inherited SetParent(AParent);
end;

procedure TcxCustomEdit.SetSize;

  procedure CalculateLeftTop(var ALeft, ATop: Integer; ANewWidth, ANewHeight: Integer);
  begin
    ALeft := Left;
    ATop := Top;
    if UseAnchors and IsAutoWidth then
    begin
      if not FIsFirstSetSize then
        CalculateAnchors;
      FIsFirstSetSize := False;
      if UseAnchorX and (AnchorX <> MaxInt) then
      begin
        if ActiveProperties.Alignment.Horz = taCenter then
          ALeft := AnchorX - ANewWidth div 2 - Integer((ANewWidth div 2) <> (ANewWidth / 2))
        else
          ALeft := AnchorX - ANewWidth;
      end;
      if UseAnchorY and (AnchorY <> MaxInt) then
      begin
        if ActiveProperties.Alignment.Vert = taVCenter then
          ATop := AnchorY - ANewHeight div 2 - Integer((ANewHeight div 2) <> (ANewHeight / 2))
        else
          ATop := AnchorY - ANewHeight;
      end;
    end;
  end;

var
  ANewHeight, ANewWidth: Integer;
  ALeft, ATop: Integer;
begin
  if not HandleAllocated or IsDestroying then
    Exit;
  ANewWidth := Width;
  ANewHeight := Height;
  InternalCanResize(ANewWidth, ANewHeight);
  CalculateLeftTop(ALeft, ATop, ANewWidth, ANewHeight);
  SetBounds(ALeft, ATop, ANewWidth, ANewHeight);
  if InnerEdit <> nil then
    AdjustInnerEditPosition;
end;

procedure TcxCustomEdit.CreateHandle;
begin
  inherited CreateHandle;
  if HasInnerEdit and inherited Focused then
    InnerEdit.SafelySetFocus;
end;

function TcxCustomEdit.IsNativeStyle: Boolean;
begin
  Result := Properties.GetViewDataClass.IsNativeStyle(Style.LookAndFeel);
end;

procedure TcxCustomEdit.SafeSelectionFocusInnerControl;
begin
  InnerEdit.SafelySetFocus;
end;

procedure TcxCustomEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_NCCALCSIZE:
      if FSettingEditWindowRegion then
      begin
        Message.Result := 0;
        Exit;
      end;
  end;
  inherited WndProc(Message);
end;

procedure TcxCustomEdit.AdjustInnerEditPosition;
var
  R: TRect;
begin
  if not HasInnerEdit then
    Exit;
  R := ViewInfo.ClientRect;
  with R do
    InnerEdit.Control.SetBounds(Left, Top, Right - Left, Bottom - Top);
  AlignControls(InnerEdit.Control, R);
end;

procedure TcxCustomEdit.AfterPosting;
begin
  FIsPosting := False;
end;

procedure TcxCustomEdit.BeforePosting;
begin
  FIsPosting := True;
end;

function TcxCustomEdit.ButtonVisibleIndexAt(const P: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  with ViewInfo do
    for I := 0 to Length(ButtonsInfo) - 1 do
      if PtInRect(ButtonsInfo[I].Bounds, P) then
      begin
        Result := I;
        Break;
      end;
end;

procedure TcxCustomEdit.CalculateViewInfo(AIsMouseEvent: Boolean);
var
  P: TPoint;
begin
  P := ScreenToClient(InternalGetCursorPos);
  CalculateViewInfo(P, cxmbNone, InternalGetShiftState, False);
end;

procedure TcxCustomEdit.CalculateViewInfo(P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AIsMouseEvent: Boolean);
var
  AViewData: TcxCustomEditViewData;
begin
  AViewData := TcxCustomEditViewData(CreateViewData);
  try
    AViewData.Calculate(Canvas, GetControlRect(Self), P, Button, Shift,
      ViewInfo, AIsMouseEvent);
  finally
    FreeAndNil(AViewData);
  end;
end;

function TcxCustomEdit.CanAutoSize: Boolean;
begin
  Result := not IsInplace and AutoSize;
end;

function TcxCustomEdit.CanAutoWidth: Boolean;
begin
  Result := ActiveProperties.ButtonsViewStyle = bvsButtonsAutoWidth;
end;

function TcxCustomEdit.CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.CanKeyPressModifyEdit(Key: Char): Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.CanModify: Boolean;
begin
  if IsInplace then
    Result := ActiveProperties.CanModify
  else
    with ActiveProperties do
    begin
      Result := AssignedValues.ReadOnly and not FReadOnly;
      if not Result then
      begin
        Result := not AssignedValues.ReadOnly or not FReadOnly;
        Result := Result and DataBinding.IDefaultValuesProvider.DefaultCanModify and
          DataBinding.IDefaultValuesProvider.CanSetEditMode;
      end;
    end;
end;

procedure TcxCustomEdit.ChangeHandler(Sender: TObject);
begin
  if Focused then
    ModifiedAfterEnter := True
  else
    if not ActiveProperties.IsChanging then
      DataBinding.SetModified;
  DoChange;
end;

procedure TcxCustomEdit.CheckHandle;
begin
  if HandleAllocated then
    Exit;
  if not(FHandleAllocating or IsDestroying) then
  begin
    FHandleAllocating := True;
    try
      if CanAllocateHandle(Self) then
        HandleNeeded;
    finally
      FHandleAllocating := False;
    end;
  end;
end;

function TcxCustomEdit.CreateInnerEdit: IcxCustomInnerEdit;
var
  AIInnerEditHelper: IcxInnerEditHelper;
  AInnerEdit: TControl;
  AInnerEditClass: TControlClass;
begin
  AInnerEditClass := GetInnerEditClass;
  if AInnerEditClass <> nil then
  begin
    AInnerEdit := AInnerEditClass.Create(Self);
    if Supports(AInnerEdit, IcxInnerEditHelper, AIInnerEditHelper) then
      Result := AIInnerEditHelper.GetHelper
    else
      Supports(AInnerEdit, IcxCustomInnerEdit, Result)
  end
  else
    Result := nil;
end;

function TcxCustomEdit.CreateViewData: TcxCustomEditViewData;
begin
  Result := ActiveProperties.CreateViewData(ActiveStyle, IsInplace);
  if FIsContentParamsInitialized and IsInplace then
    Result.EditContentParams := ContentParams;
  if PropertiesChangeLocked then
    Result.Edit := nil
  else
    Result.Edit := Self;
  if HandleAllocated then
    Result.WindowHandle := Handle
  else
    Result.WindowHandle := 0;
  InitializeViewData(Result);
end;

procedure TcxCustomEdit.DefaultButtonClick;
begin
  if GetDefaultButtonVisibleIndex <> -1 then
    DoButtonClick(GetDefaultButtonVisibleIndex);
end;

procedure TcxCustomEdit.DisableValidate;
begin
  Inc(FLockValidate);
end;

procedure TcxCustomEdit.DoAfterKeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnAfterKeyDown) then
    FOnAfterKeyDown(Self, Key, Shift);
end;

procedure TcxCustomEdit.DoAutoSizeChanged;
begin
end;

procedure TcxCustomEdit.DoButtonClick(AButtonVisibleIndex: Integer);
begin
  with Properties do
    if Assigned(FOnButtonClick) then
      FOnButtonClick(Self, ViewInfo.ButtonsInfo[AButtonVisibleIndex].Index);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(FOnButtonClick) then
        FOnButtonClick(Self, ViewInfo.ButtonsInfo[AButtonVisibleIndex].Index);
end;

procedure TcxCustomEdit.DoButtonDown(AButtonVisibleIndex: Integer);
begin
end;

procedure TcxCustomEdit.DoButtonUp(AButtonVisibleIndex: Integer);
begin
end;

procedure TcxCustomEdit.DoChange;
begin
  if IsLoading or IsDestroying then
    Exit;
  if IsOnChangeEventAssigned then
    if AreChangeEventsLocked then
      FChangeEventsCatcher.OnChangeEvent := True
    else
    begin
      if IsInplace then
      begin
        SaveModified;
        FModified := True;
        SetModifiedAfterEnterValue(True);
      end;
      try
        DoOnChange;
      finally
        if IsInplace then
          RestoreModified;
      end;
    end;
  if not ActiveProperties.HasDisplayValue and not ActiveProperties.CanCompareEditValue then
    DoEditValueChanged;
end;

procedure TcxCustomEdit.DoClick;
begin
  ModifiedAfterEnter := True;
  if FClickLockCount = 0 then
    Click;
end;

procedure TcxCustomEdit.DoClosePopup(AReason: TcxEditCloseUpReason);
begin
  with Properties do
    if Assigned(OnClosePopup) then
      OnClosePopup(Self, AReason);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnClosePopup) then
        OnClosePopup(Self, AReason);
end;

procedure TcxCustomEdit.DoEditValueChanged;
begin
  if IsLoading or IsDestroying then
    Exit;
  if IsOnEditValueChangedEventAssigned then
    if AreChangeEventsLocked then
      FChangeEventsCatcher.OnEditValueChangedEvent := True
    else
    begin
      if IsInplace then
      begin
        SaveModified;
        FModified := True;
        SetModifiedAfterEnterValue(True);
      end;
      try
        DoOnEditValueChanged;
      finally
        if IsInplace then
          RestoreModified;
      end;
    end;
end;

procedure TcxCustomEdit.DoEditKeyDown(var Key: Word; Shift: TShiftState);

  procedure CheckClearKey(AShortCut: TShortCut);
  begin
    if AShortCut = ActiveProperties.ClearKey then
    begin
      LockChangeEvents(True);
      KeyboardAction := True;
      try
        InternalEditValue := GetClearValue;
        IsEditValidated := True;
      finally
        KeyboardAction := False;
        LockChangeEvents(False);
      end;
      Key := 0;
    end;
  end;

  procedure CheckClickKey(AShortCut: TShortCut);
  begin
    if (GetDefaultButtonVisibleIndex <> -1) and (AShortCut = ActiveProperties.ClickKey) then
    begin
      KillMessages(Handle, WM_CHAR, WM_CHAR, False);
      DefaultButtonClick;
      Key := 0;
    end;
  end;

var
  AShortCut: TShortCut;
begin
  if Key = 0 then
    Exit;
  AShortCut := ShortCut(Key, Shift);

  CheckClearKey(AShortCut);
  if Key = 0 then
    Exit;

  CheckClickKey(AShortCut);
  if Key = 0 then
    Exit;

  if not ValidateKeyDown(Key, Shift) then
  begin
    DoAfterKeyDown(Key, Shift);
    Key := 0;
    Exit;
  end;

  case Key of
    VK_ESCAPE:
      begin
        if FModifiedAfterEnter and IsResetEditClass then
        begin
          LockChangeEvents(True);
          try
            DataBinding.Reset;
            EditModified := True;
          finally
            LockChangeEvents(False);
          end;
          FIsEditValueResetting := True;
          Key := 0;
        end;
      end;
    VK_TAB:
      if Focused and (Shift * [ssAlt, ssCtrl] = []) and not ActiveProperties.InnerEditNeedsTabs then
      begin
        DoEditProcessTab(Shift);
        DoAfterKeyDown(Key, Shift);
        if Key = 0 then
          Exit;
        Key := 0;
        if GetParentForm(Self) <> nil then
          TWinControlAccess(GetParentForm(Self)).SelectNext(GetParentForm(Self).ActiveControl,
            not(ssShift in Shift), True);
        if HandleAllocated and HasInnerEdit and (GetFocus = Handle) then
          InnerEdit.SafelySetFocus;
      end;
    VK_RETURN:
      if ActiveProperties.ValidateOnEnter then
      begin
        Key := 0;
        LockChangeEvents(True);
        try
          if ValidateEdit(True) and CanPostEditValue then
            InternalPostEditValue;
        finally
          LockChangeEvents(False);
        end;
      end;
  end;

  if not WantNavigationKeys then
    case Key of
      VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
        begin
          DoAfterKeyDown(Key, Shift);
          Key := 0;
        end;
    end;
end;

procedure TcxCustomEdit.DoEditKeyPress(var Key: Char);
begin
  ValidateKeyPress(Key);
end;

procedure TcxCustomEdit.DoEditKeyUp(var Key: Word; Shift: TShiftState);
begin
end;

procedure TcxCustomEdit.DoEditProcessTab(Shift: TShiftState);
begin
end;

procedure TcxCustomEdit.DoFocusChanged;

  function NeedValidate: Boolean;
  var
    AParentForm: TCustomForm;
  begin
    AParentForm := GetParentForm(Self);
    Result := (AParentForm <> nil) and not AParentForm.Visible and
      (fsModal in AParentForm.FormState) and not (AParentForm.ModalResult in [mrNone, mrCancel]);
  end;

begin
  UpdateDrawValue;
  if NeedValidate then
    ValidateEdit(False);
end;

procedure TcxCustomEdit.DoHideEdit(AExit: Boolean);
begin
  if IsDestroying or FValidateErrorProcessing then
    Exit;
  SaveModified;
  try
    LockChangeEvents(True);
    try
      if not ValidateEdit(True) then
        Exit;
      if not IsInplace and CanPostEditValue then
        InternalPostEditValue;
    finally
      LockChangeEvents(False);
    end;
    if UpdateContentOnFocusChanging then
      DataBinding.UpdateDisplayValue;
    UpdateDrawValue;
    ShortRefreshContainer(False);
    RestoreModified;
    try
      if AExit then
        inherited DoExit;
    finally
      ModifiedAfterEnter := False;
      SaveModified;
    end;
  finally
    RestoreModified;
  end;
end;

procedure TcxCustomEdit.DoOnValidate(var ADisplayValue: TcxEditValue;
  var AErrorText: TCaption; var AError: Boolean);
begin
  with Properties do
    if Assigned(OnValidate) then
      OnValidate(Self, ADisplayValue, AErrorText, AError);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnValidate) then
        OnValidate(Self, ADisplayValue, AErrorText, AError);
end;

procedure TcxCustomEdit.DoOnChange;
begin
  with Properties do
    if Assigned(OnChange) then
      OnChange(Self);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnChange) then
        OnChange(Self);
end;

procedure TcxCustomEdit.DoOnEditValueChanged;
begin
  with Properties do
    if Assigned(OnEditValueChanged) then
      OnEditValueChanged(Self);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnEditValueChanged) then
        OnEditValueChanged(Self);
end;

procedure TcxCustomEdit.DoPostEditValue;
begin
  if Assigned(FOnPostEditValue) then
    FOnPostEditValue(Self);
end;

procedure TcxCustomEdit.DoShowEdit;
begin
  SaveModified;
  try
    inherited DoEnter;
    if UpdateContentOnFocusChanging then
      DataBinding.UpdateDisplayValue;
    if ActiveProperties.IsResetEditClass then
      PrevEditValue := EditValue;
    if UpdateContentOnFocusChanging then
      SynchronizeDisplayValue;
  finally
    RestoreModified;
    SetModifiedAfterEnterValue(False);
  end;
end;

procedure TcxCustomEdit.EditingChanged;
begin
end;

procedure TcxCustomEdit.EnableValidate;
begin
  Dec(FLockValidate);
end;

procedure TcxCustomEdit.FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties);
begin
  AEditSizeProperties := DefaultcxEditSizeProperties;
  AEditSizeProperties.MaxLineCount := 1;
  if IsAutoWidth then
    AEditSizeProperties.Width := MaxInt
  else
    AEditSizeProperties.Width := Width;
end;

function TcxCustomEdit.GetClearValue: TcxEditValue;
begin
  Result := Null;
end;

class function TcxCustomEdit.GetDataBindingClass: TcxEditDataBindingClass;
begin
  Result := TcxEditDataBinding;
end;

function TcxCustomEdit.GetDefaultButtonVisibleIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(ViewInfo.ButtonsInfo) - 1 do
    if ViewInfo.ButtonsInfo[I].Data.Default then
    begin
      Result := I;
      Break;
    end;
end;

function TcxCustomEdit.GetDisplayValue: string;
begin
  Result := '';
end;

function TcxCustomEdit.GetEditDataClass: TcxCustomEditDataClass;
begin
  Result := nil;
end;

function TcxCustomEdit.GetEditingValue: TcxEditValue;
begin
  if Focused and not IsEditValidated and ModifiedAfterEnter then
    Result := InternalGetEditingValue
  else
    Result := EditValue;
end;

function TcxCustomEdit.GetInnerEditClass: TControlClass;
begin
  Result := nil;
end;

function TcxCustomEdit.HandleMouseWheel(Shift: TShiftState): Boolean;
begin
  Result := not IsInplace or ActiveProperties.UseMouseWheel or ([ssCtrl] * Shift <> []);
end;

procedure TcxCustomEdit.HandleValidationError(const AErrorText: string;
  ACanAbortExecution: Boolean);
var
  AControl: TWinControl;
begin
  if not CanFocus then
    IsEditValidated := True
  else
    if Visible then
    begin
      if not Focused then
      begin
        if HasInnerEdit then
          AControl := InnerEdit.Control
        else
          AControl := Self;
        FValidateErrorProcessing := True;
        try
          AControl.SetFocus;
        finally
          FValidateErrorProcessing := False;
        end;
      end;
      SelectAll;
    end;
  if ActiveProperties.BeepOnError then
    Beep;
  if AErrorText <> '' then
    raise EcxEditValidationError.Create(AErrorText)
  else
    if ACanAbortExecution then
      Abort;
end;

function TcxCustomEdit.HasInnerEdit: Boolean;
begin
  Result := Assigned(InnerEdit);
end;

procedure TcxCustomEdit.Initialize;

  procedure CreateDblClickTimer;
  begin
    FDblClickTimer := TcxTimer.Create(nil);
    with FDblClickTimer do
    begin
      Enabled := False;
      Interval := GetDblClickInterval;
      OnTimer := DblClickTimerHandler;
    end;
  end;

begin
  FChangeEventsCatcher := TcxEditChangeEventsCatcher.Create(Self);
  FProperties := GetPropertiesClass.Create(Self);
  InitContentParams;

  ControlStyle := ControlStyle + [csSetCaption, csCaptureMouse];
  TabStop := True;

  FInnerEdit := CreateInnerEdit;
  if HasInnerEdit then
  begin
    InitializeInnerEdit;
    InnerControl := FInnerEdit.Control;
  end;
  SetReplicatableFlag;

  FDataBinding := GetDataBindingClass.Create(Self);

  FAutoSize := not IsInplace;
  FCaptureButtonVisibleIndex := -1;
  FEditValue := Null;
  FLockValidate := 0;
  FUpdate := False;

  Properties.OnPropertiesChanged := PropertiesChanged;

  if IsInplace then
  begin
    Keys := Keys + [kAll, kArrows];
    if GetInnerEditClass = nil then
      Keys := Keys + [kTab];
  end;
  CreateDblClickTimer;
  if not IsInplace then
    Properties.FIDefaultValuesProvider := FDataBinding.IDefaultValuesProvider;

  ViewInfo.FEdit := Self;
  FIsJustCreated := True;
end;

procedure TcxCustomEdit.InitializeEditData;
begin
end;

procedure TcxCustomEdit.InitializeInnerEdit;
begin
  InnerEdit.Parent := Self;
  if ActiveProperties.HasDisplayValue then
    InnerEdit.OnChange := ChangeHandler;
  TControlAccess(InnerEdit.Control).ParentShowHint := False;
end;

procedure TcxCustomEdit.InitializeViewData(AViewData: TcxCustomEditViewData);
begin
  AViewData.Enabled := Enabled;
  AViewData.Focused := Focused;
  if HScrollBarVisible then
    AViewData.HScrollBar := HScrollBar
  else
    AViewData.HScrollBar := nil;
  AViewData.InnerEdit := InnerEdit;
  AViewData.IsDesigning := IsDesigning;
  if VScrollBarVisible then
    AViewData.VScrollBar := VScrollBar
  else
    AViewData.VScrollBar := nil;
end;

function TcxCustomEdit.InternalDoEditing: Boolean;
begin
  Result := True;
end;

function TcxCustomEdit.InternalFocused: Boolean;
begin
  Result := not ActiveProperties.IsEditValueConversionDependOnFocused or Focused;
end;

function TcxCustomEdit.IsChildWindow(AWnd: THandle): Boolean;
begin
  Result := cxContainer.IsChildWindow(Self, AWnd);
end;

function TcxCustomEdit.IsEditClass: Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.IsRepositoryItemAcceptable(
  ARepositoryItem: TcxEditRepositoryItem): Boolean;
begin
  Result := (ARepositoryItem = nil) or
    ARepositoryItem.Properties.InheritsFrom(GetPropertiesClass);
end;

procedure TcxCustomEdit.LockChangeEvents(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
begin
  ChangeEventsCatcher.Lock(ALock, AInvokeChangedOnUnlock);
end;

procedure TcxCustomEdit.LockClick(ALock: Boolean);
begin
  if ALock then
    Inc(FClickLockCount)
  else
    if FClickLockCount > 0 then
      Dec(FClickLockCount);
end;

procedure TcxCustomEdit.LockEditValueChanging(ALock: Boolean);
begin
  if ALock then
    Inc(FEditValueChangingLockCount)
  else
    if FEditValueChangingLockCount > 0 then
      Dec(FEditValueChangingLockCount);
end;

function TcxCustomEdit.InternalGetActiveProperties: TcxCustomEditProperties;
begin
  if FRepositoryItem = nil then
    Result := FProperties
  else
  begin
    Result := FRepositoryItem.Properties;
    Result.FIDefaultValuesProvider := DataBinding.IDefaultValuesProvider;
  end;
end;

function TcxCustomEdit.InternalGetEditingValue: TcxEditValue;
begin
  Result := EditValue;
end;

procedure TcxCustomEdit.InternalPostEditValue(AValidateEdit: Boolean = False);
var
  APrevKeyboardAction: Boolean;
begin
  if AValidateEdit then
  begin
    APrevKeyboardAction := KeyboardAction;
    KeyboardAction := False;
    try
      if not ValidateEdit(True) then
        Exit;
    finally
      KeyboardAction := APrevKeyboardAction;
    end;
  end;

  try
    BeforePosting;
    try
      if IsInplace then
      begin
        DoPostEditValue;
        EditModified := False;
      end
      else
        if DataBinding.Modified then
          DataBinding.StoredValue := EditValue;
    finally
      AfterPosting;
    end;
  except
    if not IsInplace then
    begin
      HandleValidationError('', False);
      raise;
    end;
  end;
end;

procedure TcxCustomEdit.InternalPostValue;
begin
  if DoEditing then
  begin
    ModifiedAfterEnter := True;
    try
      IsEditValidated := True;
      InternalPostEditValue(False);
    finally
      ModifiedAfterEnter := False;
    end;
  end;
end;

procedure TcxCustomEdit.InternalSetDisplayValue(const Value: TcxEditValue);
begin
end;

procedure TcxCustomEdit.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
var
  AEditValueChanged: Boolean;
begin
  if FKeyboardAction and not DoEditing then
    Exit;
  AEditValueChanged := False;
  if ActiveProperties.CanCompareEditValue then
    AEditValueChanged := not cxEditVarEquals(Value, FEditValue);
  FEditValue := Value;
  SynchronizeDisplayValue;
  if FKeyboardAction then
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

procedure TcxCustomEdit.InternalValidateDisplayValue(const ADisplayValue: TcxEditValue);
begin
  SaveModified;
  InternalSetDisplayValue(ADisplayValue);
  RestoreModified;
end;

function TcxCustomEdit.IsActiveControl: Boolean;
var
  AParentForm: TCustomForm;
begin
  Result := Focused;
  if Result then
    Exit;
  AParentForm := GetParentForm(Self);
  if AParentForm <> nil then
  begin
    Result := AParentForm.ActiveControl = Self;
    Result := Result or HasInnerEdit and (AParentForm.ActiveControl = InnerEdit.Control);
  end;
end;

function TcxCustomEdit.IsButtonDC(ADC: THandle): Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.IsClickEnabledDuringLoading: Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.IsDBEdit: Boolean;
begin
  Result := DataBinding.IDefaultValuesProvider.IsDataStorage;
end;

function TcxCustomEdit.IsDBEditPaintCopyDrawing: Boolean;
begin
  Result := IsDBEdit and (csPaintCopy in ControlState);
end;

function TcxCustomEdit.IsEditorKey(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := (GetDefaultButtonVisibleIndex <> -1) and
    (ShortCut(Key, Shift) = ActiveProperties.ClickKey);
end;

function TcxCustomEdit.IsEditValueStored: Boolean;
begin
  Result := not VarIsNull(EditValue);
end;

function TcxCustomEdit.IsNativeBackground: Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.IsOnChangeEventAssigned: Boolean;
begin
  Result := Assigned(Properties.OnChange) or
    Assigned(ActiveProperties.OnChange);
end;

function TcxCustomEdit.IsOnEditValueChangedEventAssigned: Boolean;
begin
  Result := Assigned(Properties.OnEditValueChanged) or
    Assigned(ActiveProperties.OnEditValueChanged);
end;

function TcxCustomEdit.IsOnValidateEventAssigned: Boolean;
begin
  Result := Assigned(Properties.OnValidate) or
    Assigned(ActiveProperties.OnValidate);
end;

function TcxCustomEdit.IsResetEditClass: Boolean;
begin
  Result := IsDBEdit or ActiveProperties.IsResetEditClass;
end;

function TcxCustomEdit.IsSpecialKey(Key: Word; Shift: TShiftState): Boolean;
var
  AShortCut: TShortCut;
begin
  AShortCut := ShortCut(Key, Shift);
  Result := (ShortCut(Key, Shift) = ActiveProperties.ClearKey) or
    (GetDefaultButtonVisibleIndex <> -1) and (AShortCut = ActiveProperties.ClickKey);
end;

function TcxCustomEdit.IsTransparent: Boolean;
begin
  Result := not IsInplace and Transparent;
end;

function TcxCustomEdit.IsValidChar(AChar: Char): Boolean;
begin
  with ActiveProperties do
    Result := (IDefaultValuesProvider = nil) or
      IDefaultValuesProvider.IsValidChar(AChar) or
      IDefaultValuesProvider.IsOnSetTextAssigned;
end;

function TcxCustomEdit.NeedsInvokeAfterKeyDown(AKey: Word;
  AShift: TShiftState): Boolean;
begin
  Result := False;
end;

procedure TcxCustomEdit.PaintCopyDraw;
var
  AViewInfo: TcxCustomEditViewInfo;
  AViewData: TcxCustomEditViewData;
begin
  SetVisibleBoundsClipRect;
  AViewInfo := TcxCustomEditViewInfo(Properties.GetViewInfoClass.Create);
  AViewInfo.FEdit := Self;
  AViewData := TcxCustomEditViewData(CreateViewData);
  AViewData.EditValueToDrawValue(Canvas, DataBinding.StoredValue, AViewInfo);
  AViewData.Calculate(Canvas, GetControlRect(Self), Point(-1, -1), cxmbNone,
    [], AViewInfo, False);
  AViewInfo.Paint(Canvas);
  FreeAndNil(AViewInfo);
  FreeAndNil(AViewData);
  Canvas.ExcludeClipRect(GetControlRect(Self));
end;

procedure TcxCustomEdit.PrepareDisplayValue(const AEditValue: TcxEditValue;
  var DisplayValue: TcxEditValue; AEditFocused: Boolean);
begin
  ActiveProperties.PrepareDisplayValue(AEditValue, DisplayValue, AEditFocused);
end;

procedure TcxCustomEdit.ProcessViewInfoChanges(APrevViewInfo: TcxCustomEditViewInfo; AIsMouseDownUpEvent: Boolean);
begin
  if (APrevViewInfo.PressedButton <> ViewInfo.PressedButton) or
    (APrevViewInfo.SelectedButton <> ViewInfo.SelectedButton) then
  begin
    if APrevViewInfo.PressedButton <> -1 then
      if APrevViewInfo.PressedButton = ViewInfo.SelectedButton then
      begin
        DoButtonUp(APrevViewInfo.PressedButton);
        DoButtonClick(APrevViewInfo.PressedButton);
      end
      else
        DoButtonUp(APrevViewInfo.PressedButton);
    if (ViewInfo.PressedButton <> -1) and (APrevViewInfo.PressedButton = -1) then
      DoButtonDown(ViewInfo.PressedButton);
  end;
end;

procedure TcxCustomEdit.PropertiesChanged(Sender: TObject);
begin
  FIsEditValidated := False;
  UpdateInnerEditReadOnly;
  if ModifiedAfterEnter and RealReadOnly then
    ModifiedAfterEnter := False;
  if ActiveProperties.Transparent then
    Transparent := True;
  CalculateAnchors;
  ShortRefreshContainer(False);
end;

function TcxCustomEdit.PropertiesChangeLocked: Boolean;
begin
  Result := not IsDestroying;
  if Result then
    Result := (GetInnerEditClass = nil) or (InnerEdit <> nil);
  Result := not Result;
end;

function TcxCustomEdit.RealReadOnly: Boolean;
begin
  Result := ActiveProperties.ReadOnly or not DataBinding.IsDataAvailable;
end;

procedure TcxCustomEdit.RepositoryItemAssigned;
begin
end;

procedure TcxCustomEdit.RepositoryItemAssigning;
begin
end;

procedure TcxCustomEdit.ResetEditValue;
begin
  if FModifiedAfterEnter and ActiveProperties.IsResetEditClass then
  begin
    LockChangeEvents(True);
    try
      SetModifiedAfterEnterValue(False);
      if IsDBEdit then
        InternalEditValue := DataBinding.StoredValue
      else
        InternalEditValue := FPrevEditValue;
      EditModified := True;
      SelectAll;
      if ActiveProperties.ImmediatePost and CanPostEditValue then
        InternalPostEditValue;
    finally
      LockChangeEvents(False);
    end;
  end;
end;

procedure TcxCustomEdit.RestoreModified;
begin
  with FPrevModifiedList[Length(FPrevModifiedList) - 1] do
  begin
    FModified := Modified;
    SetModifiedAfterEnterValue(ModifiedAfterEnter);
  end;
  SetLength(FPrevModifiedList, Length(FPrevModifiedList) - 1);
end;

procedure TcxCustomEdit.SaveModified;
begin
  SetLength(FPrevModifiedList, Length(FPrevModifiedList) + 1);
  with FPrevModifiedList[Length(FPrevModifiedList) - 1] do
  begin
    Modified := FModified;
    ModifiedAfterEnter := FModifiedAfterEnter;
  end;
end;

function TcxCustomEdit.SendActivationKey(Key: Char): Boolean;
begin
  Result := True;
end;

function TcxCustomEdit.SetDisplayText(const Value: string): Boolean;
begin
  Result := False;
end;

procedure TcxCustomEdit.SetEditAutoSize(Value: Boolean);
begin
  if (Value <> FAutoSize) and not IsInplace then
  begin
    FAutoSize := Value;
    DoAutoSizeChanged;
    if Value then
    begin
      CheckHandle;
      SetSize;
      ShortRefreshContainer(False);
    end;
  end;
end;

procedure TcxCustomEdit.SetInternalDisplayValue(Value: TcxEditValue);
begin
end;

procedure TcxCustomEdit.SetEditValue(const Value: TcxEditValue);
begin
  if FEditValueChangingLockCount > 0 then
    Exit;
  LockClick(True);
  try
    if not(FKeyboardAction and not DoEditing) then
      InternalSetEditValue(Value, True);
  finally
    LockClick(False);
  end;
end;

procedure TcxCustomEdit.SetInternalEditValue(const Value: TcxEditValue);
begin
  if FEditValueChangingLockCount > 0 then
    Exit;
  if not(FKeyboardAction and not DoEditing) then
    InternalSetEditValue(Value, True);
end;

procedure TcxCustomEdit.SynchronizeDisplayValue;
begin
end;

procedure TcxCustomEdit.SynchronizeEditValue;
begin
end;

function TcxCustomEdit.TabsNeeded: Boolean;
begin
  Result := IsInplace;
end;

function TcxCustomEdit.UpdateContentOnFocusChanging: Boolean;
begin
  Result := True;
end;

procedure TcxCustomEdit.UpdateDrawValue;
begin
end;

procedure TcxCustomEdit.UpdateInnerEditReadOnly;
begin
  if not PropertiesChangeLocked and (InnerEdit <> nil) then
    InnerEdit.ReadOnly := RealReadOnly;
end;

function TcxCustomEdit.ValidateKeyDown(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := not(not DataBinding.Modified and CanKeyDownModifyEdit(Key, Shift) and
    not DoEditing);
end;

function TcxCustomEdit.ValidateKeyPress(var Key: Char): Boolean;
begin
  if IsTextChar(Key) and not IsValidChar(Key) then
  begin
    Key := #0;
    Beep;
  end
  else
    if not DataBinding.Modified and CanKeyPressModifyEdit(Key) then
      if not DoEditing then
        Key := #0
      else
        Key := Key;
  Result := Key <> #0;
end;

function TcxCustomEdit.WantNavigationKeys: Boolean;
begin
  Result := False;
end;

procedure TcxCustomEdit.LockedInnerEditWindowProc(var Message: TMessage);
begin
  with Message do
    Result := CallWindowProc(FInnerEditDefWindowProc, Handle, Msg, WParam, LParam);
end;

procedure TcxCustomEdit.LockInnerEditRepainting;
begin
  if not HasInnerEdit then
    Exit;
  FObjectInstance := MakeObjectInstance(LockedInnerEditWindowProc);
  FInnerEditDefWindowProc := Pointer(GetWindowLong(InnerEdit.Control.Handle, GWL_WNDPROC));
  SetWindowLong(InnerEdit.Control.Handle, GWL_WNDPROC,
    Integer(FObjectInstance));
end;

procedure TcxCustomEdit.UnlockInnerEditRepainting;
begin
  if not HasInnerEdit then
    Exit;
  SetWindowLong(InnerEdit.Control.Handle, GWL_WNDPROC, Integer(FInnerEditDefWindowProc));
  FreeObjectInstance(FObjectInstance);
end;

function TcxCustomEdit.UseAnchors: Boolean;
begin
  Result := UseAnchorX or UseAnchorY;
end;

function TcxCustomEdit.UseAnchorX: Boolean;
begin
  Result := False;
end;

function TcxCustomEdit.UseAnchorY: Boolean;
begin
  Result := False;
end;

// IcxEditRepositoryItemListener
procedure TcxCustomEdit.RepositoryItemListenerItemRemoved(Sender: TcxEditRepositoryItem);
begin
  FRepositoryItem := nil;
end;

procedure TcxCustomEdit.RepositoryItemListenerPropertiesChanged(Sender: TcxEditRepositoryItem);
begin
  if ComponentState * [csLoading, csDestroying] = [] then
    PropertiesChanged(Sender.Properties);
end;

//IdxSpellCheckerSetEditValue

function TcxCustomEdit.SupportsSpelling: Boolean;
begin
  Result := False;
end;

procedure TcxCustomEdit.SpellCheckerSetIsBarControl(AValue: Boolean);
begin
  FIsBarControl := AValue;
end;

procedure TcxCustomEdit.SpellCheckerSetSelText(const AValue: string; APost: Boolean = False);
begin
end;

procedure TcxCustomEdit.SpellCheckerSetValue(const AValue: Variant);
begin
  InternalSetEditValue(AValue, False);
end;

function TcxCustomEdit.GetEditValue: TcxEditValue;
begin
  Result := FEditValue;
end;

function TcxCustomEdit.CheckButtonShortCuts(AKey: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ViewInfo.ButtonsInfo) do
    with ViewInfo.ButtonsInfo[I] do
      if (Data.State <> ebsDisabled) and IsAccel(AKey, Data.Caption) then
      begin
        Result := True;
        DoButtonClick(I);
        Break;
      end;
end;

procedure TcxCustomEdit.DblClickTimerHandler(Sender: TObject);
begin
  FDblClickTimer.Enabled := False;
end;

procedure TcxCustomEdit.DoClearEditData(AEditData: TcxCustomEditData);
begin
  if (FEditData = AEditData) and (FEditData <> nil) and FEditData.Cleared then
  begin
    InitializeEditData;
    FEditData.Cleared := False;
  end;
end;

function TcxCustomEdit.GetActiveProperties: TcxCustomEditProperties;
begin
  Result := TcxCustomEditProperties(InternalGetActiveProperties);
end;

function TcxCustomEdit.GetEditActiveStyle: TcxCustomEditStyle;
begin
  Result := TcxCustomEditStyle(inherited ActiveStyle);
end;

function TcxCustomEdit.GetHeight: Integer;
begin
  CheckHandle;
  Result := inherited Height;
end;

function TcxCustomEdit.GetInternalStyle(AState: TcxContainerStateItem): TcxCustomEditStyle;
begin
  Result := TcxCustomEditStyle(FStyles[AState]);
end;

function TcxCustomEdit.GetStyle: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles.Style);
end;

function TcxCustomEdit.GetStyleDisabled: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles.StyleDisabled);
end;

function TcxCustomEdit.GetStyleFocused: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles.StyleFocused);
end;

function TcxCustomEdit.GetStyleHot: TcxEditStyle;
begin
  Result := TcxEditStyle(FStyles.StyleHot);
end;

function TcxCustomEdit.GetViewInfo: TcxCustomEditViewInfo;
begin
  Result := TcxCustomEditViewInfo(FViewInfo);
end;

procedure TcxCustomEdit.InitContentParams;
var
  AViewData: TcxCustomEditViewData;
begin
  AViewData := CreateViewData;
  try
    AViewData.InitEditContentParams(ContentParams);
    FIsContentParamsInitialized := True;
  finally
    FreeAndNil(AViewData);
  end;
end;

procedure TcxCustomEdit.InternalCanResize(var ANewWidth, ANewHeight: Integer);
var
  AEditSizeProperties: TcxEditSizeProperties;
  ASize: TSize;
  AViewData: TcxCustomEditViewData;
begin
  if CanAutoSize then
  begin
    FillSizeProperties(AEditSizeProperties);
    AViewData := TcxCustomEditViewData(CreateViewData);
    try
      ASize := AViewData.GetEditSize(cxScreenCanvas, EditValue, AEditSizeProperties);
    finally
      FreeAndNil(AViewData);
    end;

    if IsAutoWidth then
      ANewWidth := ASize.cx;
    if not (Align in [alLeft, alRight, alClient{$IFDEF DELPHI6}, alCustom{$ENDIF}]) then
      ANewHeight := ASize.cy;
  end;
end;

function TcxCustomEdit.IsAutoWidth: Boolean;
begin
  Result := CanAutoSize and CanAutoWidth and
    not (Align in [alTop, alBottom, alClient{$IFDEF DELPHI6}, alCustom{$ENDIF}]);
end;

procedure TcxCustomEdit.ReadAnchorX(Reader: TReader);
begin
  FAnchorX := Reader.ReadInteger;
  SetSize;
end;

procedure TcxCustomEdit.ReadAnchorY(Reader: TReader);
begin
  FAnchorY := Reader.ReadInteger;
  SetSize;
end;

procedure TcxCustomEdit.ReadHeight(Reader: TReader);
begin
  Height := Reader.ReadInteger;
end;

procedure TcxCustomEdit.ReadWidth(Reader: TReader);
begin
  Width := Reader.ReadInteger;
end;

procedure TcxCustomEdit.SetDataBinding(Value: TcxEditDataBinding);
begin
  FDataBinding.Assign(Value.GetEditDataBindingInstance);
end;

procedure TcxCustomEdit.SetHeight(Value: Integer);
begin
  inherited Height := Value;
end;

procedure TcxCustomEdit.SetInternalStyle(AState: TcxContainerStateItem;
  Value: TcxCustomEditStyle);
begin
  FStyles[AState] := Value;
end;

procedure TcxCustomEdit.SetModified(Value: Boolean);
begin
  FModified := Value;
  if not Value then
    SetModifiedAfterEnterValue(False);
end;

procedure TcxCustomEdit.SetModifiedAfterEnter(Value: Boolean);
begin
  SetModifiedAfterEnterValue(Value);
  if Value then
  begin
    FIsEditValidated := False;
    FModified := True;
  end;
end;

procedure TcxCustomEdit.SetModifiedAfterEnterValue(Value: Boolean);
begin
  FModifiedAfterEnter := Value;
end;

procedure TcxCustomEdit.SetProperties(Value: TcxCustomEditProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomEdit.SetRepositoryItem(Value: TcxEditRepositoryItem);
begin
  if Value = FRepositoryItem then
    Exit;
  if not IsRepositoryItemAcceptable(Value) then
    raise EcxEditError.Create(cxGetResourceString(@cxSEditInvalidRepositoryItem));
  RepositoryItemAssigning;
  if FRepositoryItem <> nil then
    FRepositoryItem.RemoveListener(Self);

  FRepositoryItem := Value;
  if FRepositoryItem <> nil then
    FRepositoryItem.AddListener(Self);
  if FRepositoryItem = nil then
  begin
    if ComponentState * [csLoading, csDestroying] = [] then
      Properties.OnPropertiesChanged := PropertiesChanged;
    Properties.IDefaultValuesProvider := DataBinding.IDefaultValuesProvider;
  end
  else
  begin
    FProperties.FIDefaultValuesProvider := nil;
    RepositoryItemListenerPropertiesChanged(FRepositoryItem);
    TcxCustomEditProperties(FProperties).OnPropertiesChanged := nil;
  end;
  RepositoryItemAssigned;
end;

procedure TcxCustomEdit.SetReplicatableFlag;

  procedure SetControlReplicatable(AControl: TControl);
  begin
    AControl.ControlStyle := AControl.ControlStyle + [csReplicatable];
  end;

  procedure SetReplicatable(AControl: TControl);
  var
    I: Integer;
  begin
    SetControlReplicatable(AControl);
    if AControl is TWinControl then
      for I := 0 to TWinControl(AControl).ControlCount - 1 do
        SetReplicatable(TWinControl(AControl).Controls[I]);
  end;

begin
  SetReplicatable(Self);
  if NeedsScrollBars then
  begin
    SetControlReplicatable(HScrollBar);
    SetControlReplicatable(VScrollBar);
    SetControlReplicatable(SizeGrip);
  end;
end;

procedure TcxCustomEdit.SetStyle(Value: TcxEditStyle);
begin
  FStyles.Style := Value;
end;

procedure TcxCustomEdit.SetStyleDisabled(Value: TcxEditStyle);
begin
  FStyles.StyleDisabled := Value;
end;

procedure TcxCustomEdit.SetStyleFocused(Value: TcxEditStyle);
begin
  FStyles.StyleFocused := Value;
end;

procedure TcxCustomEdit.SetStyleHot(Value: TcxEditStyle);
begin
  FStyles.StyleHot := Value;
end;

procedure TcxCustomEdit.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
    else
      ControlStyle := ControlStyle + [csOpaque];
    ShortRefreshContainer(False);
  end;
end;

procedure TcxCustomEdit.WriteAnchorX(Writer: TWriter);
begin
  CalculateAnchors;
  Writer.WriteInteger(AnchorX);
end;

procedure TcxCustomEdit.WriteAnchorY(Writer: TWriter);
begin
  CalculateAnchors;
  Writer.WriteInteger(AnchorY);
end;

procedure TcxCustomEdit.WriteHeight(Writer: TWriter);
begin
  Writer.WriteInteger(Height);
end;

procedure TcxCustomEdit.WriteWidth(Writer: TWriter);
begin
  Writer.WriteInteger(Width);
end;

function TcxCustomEdit.GetHintText(APart: Integer): string;
begin
  Result := ViewInfo.GetHintText(APart);
  if (Length(Result) = 0) and ShowHint then
    Result := Hint;
end;

procedure TcxCustomEdit.WMCopy(var Message: TMessage);
begin
  CopyToClipboard;
end;

procedure TcxCustomEdit.WMCut(var Message: TMessage);
begin
  KeyboardAction := True;
  try
    if (not ActiveProperties.ReadOnly) and DataBinding.IsDataAvailable then
      CutToClipboard
    else
      CopyToClipboard;
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomEdit.CMHintShow(var Message: TCMHintShow);
var
  APart: Integer;
begin
  with Message.HintInfo^ do
  begin
    APart := ViewInfo.GetPart(CursorPos);
    if APart <> ecpNone then
    begin
      HintStr := GetShortHint(GetHintText(APart));
      CursorRect := ViewInfo.GetPartRect(APart);
    end
    else
      Message.Result := -1;
  end;
end;

procedure TcxCustomEdit.WMPaste(var Message: TMessage);
begin
  if (not ActiveProperties.ReadOnly) and DataBinding.IsDataAvailable then
  begin
    KeyboardAction := True;
    try
      PasteFromClipboard;
    finally
      KeyboardAction := False;
    end;
  end;
end;

procedure TcxCustomEdit.CMDialogChar(var Message: TCMDialogChar);
begin
  if CheckButtonShortCuts(Message.CharCode) then
    Message.Result := 1
  else
    inherited;
end;

procedure TcxCustomEdit.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
    SetSize;
end;

{ TcxEditAlignment }

constructor TcxEditAlignment.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FHorz := cxEditDefaultHorzAlignment;
  FVert := cxEditDefaultVertAlignment;
end;

procedure TcxEditAlignment.Assign(Source: TPersistent);
begin
  if Source is TcxEditAlignment then
    with Source as TcxEditAlignment do
    begin
      Self.FVert := FVert;
      Self.FHorz := FHorz;
      Self.FIsHorzAssigned := FIsHorzAssigned;
      Self.DoChanged;
    end
  else
    inherited Assign(Source);
end;

function TcxEditAlignment.IsHorzStored: Boolean;
begin
  Result := FIsHorzAssigned;
end;

function TcxEditAlignment.IsVertStored: Boolean;
begin
  Result := Vert <> cxEditDefaultVertAlignment;
end;

procedure TcxEditAlignment.Reset;
begin
  FIsHorzAssigned := False;
  DoChanged;
end;

procedure TcxEditAlignment.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

function TcxEditAlignment.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TcxEditAlignment.SetHorz(const Value: TcxEditHorzAlignment);
begin
  if FIsHorzAssigned and (Value = FHorz) then
    Exit;
  FIsHorzAssigned := True;
  FHorz := Value;
  DoChanged;
end;

procedure TcxEditAlignment.SetVert(const Value: TcxEditVertAlignment);
begin
  if Value <> FVert then
  begin
    FVert := Value;
    DoChanged;
  end;
end;

{ TcxInplaceEditList }

constructor TcxInplaceEditList.Create(AEditorOwner: TComponent);
begin
  inherited Create;
  if FInplaceEditLists = nil then
    FInplaceEditLists := TList.Create;
  FInplaceEditLists.Add(Self);
  FEditorOwner := AEditorOwner;
end;

destructor TcxInplaceEditList.Destroy;
begin
  FInplaceEditLists.Remove(Self);
  if FInplaceEditLists.Count = 0 then
    FreeAndNil(FInplaceEditLists);
  DestroyItems;
  inherited Destroy;
end;

procedure TcxInplaceEditList.DisconnectProperties(
  AProperties: TcxCustomEditProperties);
var
  AItemIndex: Integer;
begin
  AItemIndex := FindItem(AProperties, False);
  if AItemIndex <> -1 then
    FItems[AItemIndex].Properties := nil;
end;

function TcxInplaceEditList.FindEdit(AProperties: TcxCustomEditProperties): TcxCustomEdit;
begin
  Result := GetEdit(FindItem(AProperties, True));
end;

function TcxInplaceEditList.FindEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit;
begin
  Result := GetEdit(FindItem(APropertiesClass));
end;

function TcxInplaceEditList.GetEdit(AProperties: TcxCustomEditProperties): TcxCustomEdit;
begin
  Result := FindEdit(AProperties);
  if Result = nil then
  begin
    Result := CreateEdit(TcxCustomEditPropertiesClass(AProperties.ClassType));
    SetLength(FItems, Count + 1);
    with FItems[Count - 1] do
    begin
      Edit := Result;
      Properties := AProperties;
    end;
  end;
  InitEdit(Result, AProperties);
end;

function TcxInplaceEditList.GetEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit;
begin
  Result := FindEdit(APropertiesClass);
  if Result = nil then
  begin
    Result := CreateEdit(APropertiesClass);
    SetLength(FItems, Count + 1);
    with FItems[Count - 1] do
    begin
      Edit := Result;
      Properties := nil;
    end;
  end;
end;

procedure TcxInplaceEditList.RemoveItem(AProperties: TcxCustomEditProperties);
begin
  RemoveItem(FindItem(AProperties, False));
end;

procedure TcxInplaceEditList.RemoveItem(APropertiesClass: TcxCustomEditPropertiesClass);
var
  AItemIndex: Integer;
begin
  repeat
    AItemIndex := FindItem(APropertiesClass);
    RemoveItem(AItemIndex);
  until AItemIndex = -1;
end;

function TcxInplaceEditList.CreateEdit(APropertiesClass: TcxCustomEditPropertiesClass): TcxCustomEdit;
begin
  Result := TcxCustomEditClass(APropertiesClass.GetContainerClass).Create(EditorOwner, True);
  Result.Visible := False;
end;

procedure TcxInplaceEditList.DestroyItems;
begin
  while Count <> 0 do
    RemoveItem(0);
end;

function TcxInplaceEditList.FindItem(AProperties: TcxCustomEditProperties;
  ACanUseFreeEditors: Boolean): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if FItems[I].Properties = AProperties then
    begin
      Result := I;
      Break;
    end;
  if (Result = -1) and ACanUseFreeEditors then
  begin
    Result := FindItem(TcxCustomEditPropertiesClass(AProperties.ClassType));
    if Result <> -1 then
      FItems[Result].Properties := AProperties;
  end;
end;

function TcxInplaceEditList.FindItem(APropertiesClass: TcxCustomEditPropertiesClass): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if (FItems[I].Properties = nil) and (FItems[I].Edit.ClassType = APropertiesClass.GetContainerClass) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxInplaceEditList.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TcxInplaceEditList.GetEdit(AItemIndex: Integer): TcxCustomEdit;
begin
  if AItemIndex <> -1 then
    Result := FItems[AItemIndex].Edit
  else
    Result := nil;
end;

procedure TcxInplaceEditList.InitEdit(AEdit: TcxCustomEdit;
  AProperties: TcxCustomEditProperties);
begin
  AEdit.LockChangeEvents(True);
  try
    AEdit.Properties := AProperties;
  finally
    AEdit.LockChangeEvents(False, False);
  end;
end;

procedure TcxInplaceEditList.RemoveItem(AIndex: Integer);
begin
  if AIndex <> -1 then
  begin
    FItems[AIndex].Edit.Parent := nil;
    FItems[AIndex].Edit.Free;
    if AIndex < Count - 1 then
      Move(FItems[AIndex + 1], FItems[AIndex], SizeOf(TcxEditListItem) * (Count - AIndex - 1));
    SetLength(FItems, Length(FItems) - 1);
  end;
end;

{ TcxDefaultEditStyleController }

constructor TcxDefaultEditStyleController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Inc(FDefaultEditStyleControllerCount);
end;

destructor TcxDefaultEditStyleController.Destroy;

  procedure ResetDefaultEditStyleController;
  begin
    if DefaultEditStyleController <> nil then
    begin
      DefaultEditStyleController.RestoreStyles;
      DefaultEditStyleController.OnStyleChanged := nil;
    end;
  end;

begin
  Dec(FDefaultEditStyleControllerCount);
  if FDefaultEditStyleControllerCount = 0 then
    ResetDefaultEditStyleController;
  inherited Destroy;
end;

procedure TcxDefaultEditStyleController.RestoreStyles;
begin
  DefaultEditStyleController.RestoreStyles;
end;

function TcxDefaultEditStyleController.GetEmulateStandardControlDrawing: Boolean;
begin
  Result := cxEdit.EmulateStandardControlDrawing;
end;

function TcxDefaultEditStyleController.GetInternalStyle(
  AState: TcxContainerStateItem): TcxCustomEditStyle;
begin
  Result := DefaultEditStyleController.Styles[AState];
end;

function TcxDefaultEditStyleController.GetOnStyleChanged: TNotifyEvent;
begin
  Result := DefaultEditStyleController.OnStyleChanged;
end;

function TcxDefaultEditStyleController.GetStyle: TcxEditStyle;
begin
  Result := DefaultEditStyleController.Style;
end;

function TcxDefaultEditStyleController.GetStyleDisabled: TcxEditStyle;
begin
  Result := DefaultEditStyleController.StyleDisabled;
end;

function TcxDefaultEditStyleController.GetStyleFocused: TcxEditStyle;
begin
  Result := DefaultEditStyleController.StyleFocused;
end;

function TcxDefaultEditStyleController.GetStyleHot: TcxEditStyle;
begin
  Result := DefaultEditStyleController.StyleHot;
end;

procedure TcxDefaultEditStyleController.SetEmulateStandardControlDrawing(
  Value: Boolean);
begin
  SetStandardControlDrawingEmulationMode(Value);
end;

procedure TcxDefaultEditStyleController.SetInternalStyle(
  AState: TcxContainerStateItem; Value: TcxCustomEditStyle);
begin
  DefaultEditStyleController.Styles[AState] := Value;
end;

procedure TcxDefaultEditStyleController.SetOnStyleChanged(Value: TNotifyEvent);
begin
  DefaultEditStyleController.OnStyleChanged := Value;
end;

procedure TcxDefaultEditStyleController.SetStyle(Value: TcxEditStyle);
begin
  DefaultEditStyleController.Style := Value;
end;

procedure TcxDefaultEditStyleController.SetStyleDisabled(Value: TcxEditStyle);
begin
  DefaultEditStyleController.StyleDisabled := Value;
end;

procedure TcxDefaultEditStyleController.SetStyleFocused(Value: TcxEditStyle);
begin
  DefaultEditStyleController.StyleFocused := Value;
end;

procedure TcxDefaultEditStyleController.SetStyleHot(Value: TcxEditStyle);
begin
  DefaultEditStyleController.StyleHot := Value;
end;

initialization
  Screen.Cursors[crcxEditMouseWheel] := LoadCursor(HInstance, 'CXEDIT_MOUSEWHEEL');
  FDefaultEditStyleController := TcxEditStyleController.Create(nil);
  cxContainerDefaultStyleController := FDefaultEditStyleController;
  FCreatedEditPropertiesList := TList.Create;
  cxFilterConsts.cxFilterGetResourceStringFunc := cxGetResourceString;

finalization
  FreeAndNil(FRegisteredEditProperties);
  FreeAndNil(FDefaultEditRepository);
  FreeAndNil(FCreatedEditPropertiesList);
  cxContainerDefaultStyleController := nil;
  FreeAndNil(FDefaultEditStyleController);

end.
