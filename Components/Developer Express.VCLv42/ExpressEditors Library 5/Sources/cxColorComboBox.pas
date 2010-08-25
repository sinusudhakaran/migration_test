
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

unit cxColorComboBox;

interface

{$I cxVer.inc}

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Windows, Messages, TypInfo, SysUtils, Classes, Controls, Graphics, StdCtrls,
  Forms, Dialogs, cxClasses, cxControls, cxContainer, cxGraphics,
  cxCustomData, cxDataStorage, cxDataUtils, cxVariants,
  cxEdit, cxTextEdit, cxEditUtils, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  cxExtEditConsts,  cxFilterControlUtils;

type
  TcxColorBoxAlign = (cbaLeft, cbaRight);
  TcxColorNamingConvention = (cxncNone, cxncDelphi, cxncHTML4, cxncX11);
  TcxColorPrepareList = (cxplNone, cxplDelphi, cxplHTML4, cxplX11, cxplX11Ordered);
  TcxColorValueFormat = (cxcvRGB, cxcvHexadecimal, cxcvInteger);
  TcxDefaultColorStyle = (cxdcClear, cxdcColor, cxdcHatched, cxdcText, cxdcCustom);
  TcxMRUColorAction = (mcaNone, mcaMoved, mcaAdded, mcaDeleted);

type
  { TcxColorComboBoxItem }

  TcxColorComboBoxItem = class(TCollectionItem)
  private
    FColor: TColor;
    FDescription: TCaption;
    FIsCustomColor: Boolean;
    FTag: TcxTag;
    function GetDescription: TCaption;
    function IsTagStored: Boolean;
    procedure SetColor(const Value: TColor);
    procedure SetDescription(const Value: TCaption);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property IsCustomColor: Boolean read FIsCustomColor;
  published
    property Color: TColor read FColor write SetColor;
    property Description: TCaption read GetDescription write SetDescription;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
  end;

  { TcxColorComboBoxItems }

  TcxCustomColorComboBoxProperties = class;  

  TcxColorComboBoxItems = class(TOwnedCollection)
  private
    FOnUpdate: TNotifyEvent;
    function GetItems(Index: Integer): TcxColorComboBoxItem;
    procedure SetItems(Index: Integer; const Value: TcxColorComboBoxItem);
  protected
    procedure Update(Item: TCollectionItem); override;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  public
    function Owner: TcxCustomColorComboBoxProperties;
    property Items[Index: Integer]: TcxColorComboBoxItem read GetItems write SetItems; default;
    function FindColorItem(const AColor: TColor): TcxColorComboBoxItem; virtual;
    function GetIndexByColor(AColor: TColor): Integer;
    function GetColorByIndex(AIndex: Integer; ADefaultColor: TColor): TColor;
    function AddColor(const AColor: TColor;
      const ADescription: string): TcxColorComboBoxItem; virtual;
    function InsertColor(Index: Integer; const AColor: TColor;
      const ADescription: string): TcxColorComboBoxItem; virtual;
    function Add: TcxColorComboBoxItem;
    function Insert(Index: Integer): TcxColorComboBoxItem;
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    procedure ClearCustom; virtual;    
    procedure ClearNonCustom; virtual;
  end;

  { TcxCustomColorComboBoxViewInfo }

  TcxCustomColorComboBoxViewInfo = class(TcxCustomTextEditViewInfo)
  private
    FBkColor: TColor;
    FColorBoxWidth: Integer;
    FColorBoxAlign: TcxColorBoxAlign;
    FColorBoxRect: TRect;
    FColorBoxFrameColor: TColor;
    FColorBoxColor: TColor;
    FShowDescriptions: Boolean;
    FDefaultColorStyle: TcxDefaultColorStyle;
    FFoundItem: Boolean;
  public
    property BkColor: TColor read FBkColor write FBkColor;
    property ColorBoxWidth: Integer read FColorBoxWidth write FColorBoxWidth;
    property ColorBoxAlign: TcxColorBoxAlign read FColorBoxAlign write FColorBoxAlign;
    property ColorBoxFrameColor: TColor read FColorBoxFrameColor write FColorBoxFrameColor;
    property ColorBoxColor: TColor read FColorBoxColor write FColorBoxColor;
    property ColorBoxRect: TRect read FColorBoxRect write FColorBoxRect;
    property DefaultColorStyle: TcxDefaultColorStyle read FDefaultColorStyle write FDefaultColorStyle;
    property ShowDescriptions: Boolean read FShowDescriptions write FShowDescriptions;
    property FoundItem: Boolean read FFoundItem write FFoundItem;
    procedure Paint(ACanvas: TcxCanvas); override;
    procedure Offset(DX, DY: Integer); override;
  end;

  { TcxCustomColorComboBoxViewData }

  TcxCustomColorComboBoxViewData = class(TcxCustomDropDownEditViewData)
  private
    function GetProperties: TcxCustomColorComboBoxProperties;
  protected
    procedure CalculateViewInfoProperties(AViewInfo: TcxCustomEditViewInfo); virtual;
    function InternalEditValueToDisplayText(AEditValue: TcxEditValue): string; override;
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
      AViewInfo: TcxCustomEditViewInfo): TSize; override;
    function IsComboBoxStyle: Boolean; override;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
      const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean); override;
    procedure DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    property Properties: TcxCustomColorComboBoxProperties read GetProperties;
  end;

  { TcxColorComboBoxListBox }

  TcxCustomColorComboBox = class;

  TcxCustomColorComboBoxListBox = class(TcxCustomComboBoxListBox)
  private
    function GetEdit: TcxCustomColorComboBox;
  protected
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    function GetItemHeight(AIndex: Integer = -1): Integer; override;
    property Edit: TcxCustomColorComboBox read GetEdit;
  end;

  { TcxColorComboBoxLookupData }
  
  TcxColorComboBoxLookupData = class(TcxComboBoxLookupData)
  protected
    function GetListBoxClass: TcxCustomEditListBoxClass; override;
    function GetItem(Index: Integer): string; override;
    function GetItemCount: Integer; override;
    function InternalChangeCurrentMRUColorPosition(const AColor: TColor): Integer; virtual;
  public
    function GetVisualAreaPreferredSize(AMaxHeight: Integer;
      AWidth: Integer = 0): TSize; override;
    procedure TextChanged; override;
  end;

  TcxColorComboStyle = (cxccsComboList, cxccsComboEdit);
  TcxColorDialogType = (cxcdtDefault, cxcdtCustom);
  TcxSelectCustomColorEvent = procedure(Sender: TObject; var AColor: TColor;
    var AColorDescription: string; var AddToList: Boolean) of object;
  TcxNamingConventionEvent = procedure(Sender: TObject; const AColor: TColor;
    var AColorDescription: string) of object;
  TcxChangeItemIndexEvent = procedure(Sender: TObject; const AIndex: Integer) of object;
  TcxGetDefaultColorEvent = procedure(Sender: TObject; var AColor: TColor) of object;

  { TcxCustomColorComboBoxProperties }
  
  TcxCustomColorComboBoxProperties = class(TcxCustomComboBoxProperties)
  private
    FAllowSelectColor: Boolean;
    FColorComboStyle: TcxColorComboStyle;
    FColorBoxAlign: TcxColorBoxAlign;
    FColorBoxFrameColor: TColor;
    FColorBoxWidth: Integer;
    FColorDialogType: TcxColorDialogType;
    FColorValueFormat: TcxColorValueFormat;    
    FDefaultColor: TColor;
    FDefaultDescription: string;
    FDefaultColorStyle: TcxDefaultColorStyle;

    FItems: TcxColorComboBoxItems;
    FCustomColors: TcxColorComboBoxItems;
    FMRUColors: TcxColorComboBoxItems;

    FMaxMRUColors: Byte;
    FNamingConvention: TcxColorNamingConvention;
    FShowDescriptions: Boolean;
    FOnNamingConvention: TcxNamingConventionEvent;
    FOnSelectCustomColor: TcxSelectCustomColorEvent;
    FOnAddedMRUColor: TNotifyEvent;
    FOnDeletedMRUColor: TNotifyEvent;
    FOnGetDefaultColor: TcxGetDefaultColorEvent;
    FOnLoadColorList: TNotifyEvent;
    FInternalUpdate: Boolean;
    FPrepareList: TcxColorPrepareList;
    function ColorItemByIndex(AIndex: Integer): TcxColorComboBoxItem;
    procedure DeleteOverMRUColors;
    function DoConvertNaming(AIndex: Integer): string;
    function GetItems: TcxColorComboBoxItems;
    procedure InternalGetColorComboBoxDisplayValue(AItemIndex: Integer;
      const AEditValue: TcxEditValue; out AColor: TColor;
      out ADescription: string; out AColorFound: Boolean);
    procedure InternalPrepareColorList(APrepareList: TcxColorPrepareList); overload;
    procedure InternalPrepareColorList(AColorValues: array of TColor;
      AColorNames: array of string); overload;
    function IsDefaultDescriptionStored: Boolean;
    procedure ReadCustomColors(Reader: TReader);
    procedure ReadPrepareInfo(Reader: TReader);
    procedure SetAllowSelectColor(Value: Boolean);
    procedure SetColorBoxAlign(Value: TcxColorBoxAlign);
    procedure SetColorBoxFrameColor(Value: TColor);
    procedure SetColorBoxWidth(Value: Integer);
    procedure SetColorComboStyle(Value: TcxColorComboStyle);
    procedure SetColorValueFormat(Value: TcxColorValueFormat);
    procedure SetDefaultColor(Value: TColor);
    procedure SetDefaultDescription(Value: string);
    procedure SetDefaultColorStyle(Value: TcxDefaultColorStyle);

    procedure SetCustomColors(Value: TcxColorComboBoxItems);
    procedure SetItems(const Value: TcxColorComboBoxItems);
    procedure SetMaxMRUColors(Value: Byte);

    procedure SetNamingConvention(Value: TcxColorNamingConvention);
    procedure SetPrepareList(Value: TcxColorPrepareList);
    procedure SetShowDescriptions(const Value: Boolean);
    procedure SynchronizeCustomColors;
    procedure CustomColorChanged(ASender: TObject);
    procedure ValidateMRUColors;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function ShowColorBox(AColorFound: Boolean): Boolean;
    class function GetLookupDataClass: TcxInterfacedPersistentClass; override;
    class function GetPopupWindowClass: TcxCustomEditPopupWindowClass; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
    function IsEditValueNumeric: Boolean; override;

    function GetColorByIndex(AIndex: Integer): TColor;
    function GetIndexByColor(AColor: TColor): Integer;
    function GetDescriptionByIndex(AIndex: Integer): string;
    function IndexByValue(const AValue: TcxEditValue): Integer;
    function IsDisplayValueNumeric: Boolean; virtual;

    function AddMRUColor(const AColor: TColor): TcxMRUColorAction; virtual;
    function DelMRUColor(const AColor: TColor): TcxMRUColorAction; virtual;
    procedure ClearMRUColors; virtual;
    procedure DoGetDefaultColor(var AColor: TColor); virtual;
    procedure TranslateValues(const AEditValue: TcxEditValue;
      var AColor: TColor; var ADescription: string; ANeedDescription: Boolean = False);
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Changed; override;
    function CompareDisplayValues(const AEditValue1, AEditValue2: TcxEditValue): Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    function IsDisplayValueValid(var DisplayValue: TcxEditValue; AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    function GetDisplayText(const AEditValue: TcxEditValue; AFullText:
      Boolean = False; AIsInplace: Boolean = True): WideString; override;
    procedure Update(AProperties: TcxCustomEditProperties); override;
    procedure GetColorComboBoxDisplayValue(const AEditValue: TcxEditValue;
      out AColor: TColor; out ADescription: string; out AColorFound: Boolean);

    procedure PrepareColorList(APrepareList: TcxColorPrepareList; ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareDelphiColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareHTML4ColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareX11ColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareX11OrderedColorList(const ASaveCustom, ASaveMRU: Boolean);
    // !!!
    property AllowSelectColor: Boolean read FAllowSelectColor
      write SetAllowSelectColor default False;
    property ColorBoxAlign: TcxColorBoxAlign read FColorBoxAlign
      write SetColorBoxAlign default cbaLeft;
    property ColorBoxFrameColor: TColor read FColorBoxFrameColor
      write SetColorBoxFrameColor default clBtnShadow;
    property ColorBoxWidth: Integer read FColorBoxWidth write SetColorBoxWidth
      default 30;
    property ColorComboStyle: TcxColorComboStyle read FColorComboStyle
      write SetColorComboStyle default cxccsComboEdit;
    property ColorDialogType: TcxColorDialogType read FColorDialogType
      write FColorDialogType default cxcdtDefault;
    property ColorValueFormat: TcxColorValueFormat read FColorValueFormat
      write SetColorValueFormat default cxcvRGB;
    property DefaultColor: TColor read FDefaultColor write SetDefaultColor
      default clWindow;
    property DefaultColorStyle: TcxDefaultColorStyle read FDefaultColorStyle
      write SetDefaultColorStyle default cxdcColor;
    property DefaultDescription: string read FDefaultDescription
      write SetDefaultDescription stored IsDefaultDescriptionStored;

    property CustomColors: TcxColorComboBoxItems read FCustomColors write SetCustomColors;
    property Items: TcxColorComboBoxItems read GetItems write SetItems;
    property MaxMRUColors: Byte read FMaxMRUColors write SetMaxMRUColors
      default 10;
    property MRUColors: TcxColorComboBoxItems read FMRUColors write FMRUColors;
    
    property NamingConvention: TcxColorNamingConvention read FNamingConvention
      write SetNamingConvention default cxncDelphi;
    property PrepareList: TcxColorPrepareList read FPrepareList
      write SetPrepareList default cxplDelphi;
    property ShowDescriptions: Boolean read FShowDescriptions
      write SetShowDescriptions default True;
    property OnAddedMRUColor: TNotifyEvent read FOnAddedMRUColor
      write FOnAddedMRUColor;
    property OnDeletedMRUColor: TNotifyEvent read FOnDeletedMRUColor
      write FOnDeletedMRUColor;
    property OnGetDefaultColor: TcxGetDefaultColorEvent read FOnGetDefaultColor
      write FOnGetDefaultColor;
    property OnNamingConvention: TcxNamingConventionEvent
      read FOnNamingConvention write FOnNamingConvention;
    property OnSelectCustomColor: TcxSelectCustomColorEvent
      read FOnSelectCustomColor write FOnSelectCustomColor;
  end;

  { TcxColorComboBoxProperties }

  TcxColorComboBoxProperties = class(TcxCustomColorComboBoxProperties)
  published
    property Alignment;
    property AllowSelectColor;
    property AssignedValues;
    property BeepOnError;
    property ButtonGlyph;
    property CharCase;
    property ClearKey;
    property ColorBoxAlign;
    property ColorBoxFrameColor;
    property ColorBoxWidth;
    property ColorComboStyle;
    property ColorDialogType;
    property ColorValueFormat;
    property CustomColors;
    property DefaultColor;
    property DefaultColorStyle;
    property DefaultDescription;
    property DropDownAutoWidth;
    property DropDownRows;
    property DropDownSizeable;
    property DropDownWidth;
    property ImeMode;
    property ImeName;
    property ImmediateDropDown;
    property ImmediatePost;
    property ImmediateUpdateText;
    property MaxMRUColors;
    property NamingConvention;
    property OEMConvert;
    property PopupAlignment;
    property PostPopupValueOnTab;
    property PrepareList;
    property ReadOnly;
    property Revertable;
    property ShowDescriptions;
    property ValidateOnEnter;
    property OnAddedMRUColor;
    property OnChange;
    property OnCloseUp;
    property OnDeletedMRUColor;
    property OnEditValueChanged;
    property OnGetDefaultColor;
    property OnInitPopup;
    property OnNamingConvention;
    property OnNewLookupDisplayText;
    property OnPopup;
    property OnSelectCustomColor;
  end;

  { TcxCustomColorComboBoxInnerEdit }

  TcxCustomColorComboBoxInnerEdit = class(TcxCustomComboBoxInnerEdit);

  { TcxColorComboBoxPopupWindow }

  TcxColorComboBoxPopupWindow = class(TcxComboBoxPopupWindow)
  public
    property ViewInfo;
    property SysPanelStyle;
  end;

  { TcxCustomColorComboBox }

  TcxCustomColorComboBox = class(TcxCustomComboBox)
  private
    FColorDialog: TColorDialog;
    FDontCheckModifiedWhenUpdatingMRUList: Boolean;
    FIsDialogShowed: Boolean;
    FNeedsUpdateMRUList: Boolean;
    FPropertiesUpdate: Boolean;
    function GetColorDialog: TColorDialog;
    function GetColorValue: TColor;
    function IsColorValueStored: Boolean;
    procedure SetColorValue(Value: TColor);
    function GetLookupData: TcxColorComboBoxLookupData;
    function GetProperties: TcxCustomColorComboBoxProperties;
    function GetActiveProperties: TcxCustomColorComboBoxProperties;
    procedure SetProperties(Value: TcxCustomColorComboBoxProperties);
    procedure PropertiesLoadColorListHandler(Sender: TObject);
    procedure UpdateMRUList;
    procedure FlushEditValue;
  protected
    procedure AfterPosting; override;
    procedure ContainerStyleChanged(Sender: TObject); override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure DblClick; override;
    procedure DoButtonClick(AButtonVisibleIndex: Integer); override;
    function GetDisplayValue: string; override;
    function GetEditingValue: TcxEditValue; override;
    function GetInnerEditClass: TControlClass; override;
    procedure Initialize; override;
    procedure InitializePopupWindow; override;
    function IsValidChar(AChar: Char): Boolean; override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    function LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    procedure SynchronizeDisplayValue; override;
    procedure CloseUp(AReason: TcxEditCloseUpReason); override;
    procedure DoSelectCustomColor(Sender: TObject); virtual;
    procedure FixMRUPosition(AColor: TColor); virtual;
    procedure ClearEditValue; virtual;
    procedure DoOnSelectCustomColor(var AColor: TColor;
      var AColorDescription: string; var AddToList: Boolean);
    property ColorValue: TColor read GetColorValue write SetColorValue
      stored IsColorValueStored;
    property ColorDialog: TColorDialog read GetColorDialog;
    property LookupData: TcxColorComboBoxLookupData read GetLookupData;
  public
    destructor Destroy; override;

    function Deactivate: Boolean; override;
    function Focused: Boolean; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    function IsChildWindow(AWnd: THandle): Boolean; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;

    function AddMRUColor(const AColor: TColor): TcxMRUColorAction;
    function DelMRUColor(const AColor: TColor): TcxMRUColorAction;

    procedure PrepareColorList(APrepareList: TcxColorPrepareList; ASaveCustom, ASaveMRU: Boolean);    
    procedure PrepareDelphiColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareHTML4ColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareX11ColorList(const ASaveCustom, ASaveMRU: Boolean);
    procedure PrepareX11OrderedColorList(const ASaveCustom, ASaveMRU: Boolean);

    property ActiveProperties: TcxCustomColorComboBoxProperties
      read GetActiveProperties;
    property Properties: TcxCustomColorComboBoxProperties read GetProperties
      write SetProperties;
  end;

  { TcxColorComboBox }

  TcxColorComboBox = class(TcxCustomColorComboBox)
  private
    function GetActiveProperties: TcxColorComboBoxProperties;
    function GetProperties: TcxColorComboBoxProperties;
    procedure SetProperties(Value: TcxColorComboBoxProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxColorComboBoxProperties
      read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property ColorValue;
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
    property Properties: TcxColorComboBoxProperties read GetProperties
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

  { TcxFilterColorComboBoxHelper }

  TcxFilterColorComboBoxHelper = class(TcxFilterComboBoxHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties; AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

implementation

uses
  cxExtEditUtils, dxThemeConsts, dxThemeManager, dxUxTheme;

type
  TCanvasAccess = class(TCanvas);

function ConvertColorName(AColor: TColor; ADescription: string;
  const ANamingConvention: TcxColorNamingConvention;
  const AColorValueFormat: TcxColorValueFormat): string;

  function ConvertUnknowColor: string;
  var
    RGB: Cardinal;
  begin
    RGB := ColorToRGB(AColor);
    case AColorValueFormat of
      cxcvRGB:
        Result := Format('%d.%d.%d', [GetRValue(RGB), GetGValue(RGB), GetBValue(RGB)]);
      cxcvHexadecimal:
        Result := Format('%s%.2x%.2x%.2x', [HexDisplayPrefix, GetRValue(RGB), GetGValue(RGB), GetBValue(RGB)]);
      else
        Result := IntToStr(AColor);
    end;
  end;

  function GetColorName(AColorValues: array of TColor; AColorNames: array of string): string;
  var
    I: Integer;
  begin
    for I := Low(AColorValues) to High(AColorValues) do
      if AColorValues[I] = AColor then
      begin
        Result := AColorNames[I];
        Exit;
      end;
    Result := ConvertUnknowColor;
  end;

begin
  case ANamingConvention of
    cxncNone: Result := ADescription;
    cxncDelphi: Result := GetColorName(cxDelphiColorValues, cxDelphiColorNames);
    cxncHTML4: Result := GetColorName(cxHTML4ColorValues, cxHTML4ColorNames);
    cxncX11: Result := GetColorName(cxX11ColorValues, cxX11ColorNames);
  end;
end;

procedure DrawColorBox(ACanvas: TcxCanvas;ARect: TRect; const AFrameColor,
  ABoxColor, ABkColor: TColor; const DefaultColorStyle: TcxDefaultColorStyle);
var
  FRectangle: TRect;
begin
  if (ARect.Left <> ARect.Right) and (ARect.Bottom <> ARect.Top) then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := ABkColor;
    ACanvas.FrameRect(ARect);
    InflateRect(ARect, -1, -1);
    ACanvas.Brush.Color := AFrameColor;
    ACanvas.FrameRect(ARect);
    InflateRect(ARect, -1, -1);
    case DefaultColorStyle of
      cxdcClear:
      begin
        ACanvas.Brush.Color := ABkColor;
        ACanvas.FillRect(ARect);
      end;
      cxdcColor, cxdcCustom, cxdcText:
      begin
        ACanvas.Brush.Color := ABoxColor;
        ACanvas.FillRect(ARect);
      end;
      cxdcHatched: begin
        ACanvas.Brush.Color := ABkColor;
        ACanvas.FillRect(ARect);
        ACanvas.Pen.Color := ABkColor;
        ACanvas.Brush.Color := ABoxColor;
        ACanvas.Brush.Style := bsDiagCross;
        FRectangle := ARect;
        InflateRect(FRectangle, 1, 1);
{$IFDEF DELPHI5}
        ACanvas.Canvas.Rectangle(FRectangle);
{$ELSE}
        ACanvas.Canvas.Rectangle(FRectangle.Left, FRectangle.Top, FRectangle.Right, FRectangle.Bottom);
{$ENDIF}
        ACanvas.Pen.Color := AFrameColor;
        ACanvas.Polyline([Point(ARect.Left -1 , ARect.Top - 1), Point(ARect.Right, ARect.Top - 1),
          Point(ARect.Right, ARect.Bottom), Point(ARect.Left - 1, ARect.Bottom),
          Point(ARect.Left - 1, ARect.Top - 1)]);
      end;
    end;
    ACanvas.Brush.Style := bsSolid;
  end;
end;

{ TcxColorComboBoxItem }

constructor TcxColorComboBoxItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FIsCustomColor := True;
  FDescription := '';
end;

procedure TcxColorComboBoxItem.Assign(Source: TPersistent);
begin
  if Source is TcxColorComboBoxItem then
    with TcxColorComboBoxItem(Source) do
    begin
      Self.Color := Color;
      Self.Description := Description;
      Self.FIsCustomColor := IsCustomColor;
      Self.Tag := Tag;
    end
  else
    inherited Assign(Source);
end;

procedure TcxColorComboBoxItem.SetDescription(const Value: TCaption);
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    Changed(False);
  end;
end;

function TcxColorComboBoxItem.GetDescription: TCaption;
begin
  Result := FDescription;
end;

function TcxColorComboBoxItem.IsTagStored: Boolean;
begin
  Result := FTag <> 0;
end;

procedure TcxColorComboBoxItem.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Changed(False);
  end;
end;

{ TcxColorComboBoxItems }

function TcxColorComboBoxItems.GetItems(Index: Integer): TcxColorComboBoxItem;
begin
  Result := TcxColorComboBoxItem(inherited Items[Index]);
end;

procedure TcxColorComboBoxItems.SetItems(Index: Integer;const Value: TcxColorComboBoxItem);
begin
  inherited Items[Index] := Value;
end;

procedure TcxColorComboBoxItems.Update(Item: TCollectionItem);
begin
  if Assigned(OnUpdate) then
    OnUpdate(Item);
  if Owner <> nil then
    Owner.Changed;
end;

function TcxColorComboBoxItems.Owner: TcxCustomColorComboBoxProperties;
begin
  if GetOwner is TcxCustomColorComboBoxProperties then
    Result := TcxCustomColorComboBoxProperties(GetOwner)
  else
    Result := nil;
end;

function TcxColorComboBoxItems.FindColorItem(const AColor: TColor): TcxColorComboBoxItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Items[I].Color = AColor then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TcxColorComboBoxItems.GetIndexByColor(AColor: TColor): Integer;
var
  I : Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Items[I].Color = AColor then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TcxColorComboBoxItems.GetColorByIndex(AIndex: Integer;
  ADefaultColor: TColor): TColor;
begin
  Result := ADefaultColor;
  if (AIndex >= 0) and (AIndex <= (Count - 1)) then
    Result := Items[AIndex].Color;
end;

function TcxColorComboBoxItems.Add: TcxColorComboBoxItem;
begin
  Result := TcxColorComboBoxItem(inherited Add);
end;

function TcxColorComboBoxItems.Insert(Index: Integer): TcxColorComboBoxItem;
begin
  Result := TcxColorComboBoxItem(inherited Insert(Index));
end;

function TcxColorComboBoxItems.AddColor(const AColor: TColor;
  const ADescription: string): TcxColorComboBoxItem;
begin
  Result := nil;
  if (FindColorItem(AColor) <> nil) then Exit;
  Result := Add;
  Result.Color := AColor;
  Result.Description := ADescription;
end;

function TcxColorComboBoxItems.InsertColor(Index: Integer; const AColor: TColor;
  const ADescription: string): TcxColorComboBoxItem;
begin
  Result := nil;
  if (FindColorItem(AColor) <> nil) then Exit;
  Result := Insert(Index);
  Result.Color := AColor;
  Result.Description := ADescription;
end;

procedure TcxColorComboBoxItems.Move(CurIndex, NewIndex: Integer);
var
  FNewColorItem, FOldColorItem: TcxColorComboBoxItem;
begin
  if CurIndex = NewIndex then Exit;
  FOldColorItem := Items[CurIndex];
  FNewColorItem := Insert(NewIndex);
  FNewColorItem.Assign(FOldColorItem);
  FOldColorItem.Free;
end;

procedure TcxColorComboBoxItems.ClearCustom;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if Items[I].IsCustomColor then
      Delete(I);
end;

procedure TcxColorComboBoxItems.ClearNonCustom;
var
  I: Integer;
begin
  for I := (Count - 1) downto 0 do
    if not Items[I].IsCustomColor then
      Delete(I);
end;

{ TcxCustomColorComboBoxViewInfo }

procedure TcxCustomColorComboBoxViewInfo.Paint(ACanvas: TcxCanvas);
var
  FRealDefaultColorStyle: TcxDefaultColorStyle;
begin
  inherited Paint(ACanvas);
  if not FoundItem and (DefaultColorStyle = cxdcText) then
    Exit;

  FRealDefaultColorStyle := DefaultColorStyle;
  if (DefaultColorStyle <> cxdcText) and FoundItem then
    FRealDefaultColorStyle := cxdcColor;
  DrawColorBox(ACanvas, ColorBoxRect, ColorBoxFrameColor, ColorBoxColor,
    BkColor, FRealDefaultColorStyle);

  if not IsInplace and not ShowDescriptions and Focused and not HasPopupWindow then
  begin
    ACanvas.Font.Color := clBtnText;
    ACanvas.Brush.Color := BackgroundColor;
    TCanvasAccess(ACanvas.Canvas).RequiredState([csFontValid]);
    ACanvas.Canvas.DrawFocusRect(ClientRect);
  end;
end;

procedure TcxCustomColorComboBoxViewInfo.Offset(DX, DY: Integer);
begin
  inherited Offset(DX, DY);
  OffsetRect(FColorBoxRect, DX, DY);
end;

{ TcxCustomColorComboBoxViewData }

procedure TcxCustomColorComboBoxViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  R: TRect;
  FViewInfo: TcxCustomColorComboBoxViewInfo;
begin
  if IsRectEmpty(ABounds) then begin
    inherited;
    Exit;
  end;
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  if (ABounds.Right = MaxInt) or (ABounds.Bottom = MaxInt) then Exit;

  FViewInfo := TcxCustomColorComboBoxViewInfo(AViewInfo);
  CalculateViewInfoProperties(FViewInfo);
  R := FViewInfo.ClientRect;
  FViewInfo.FColorBoxRect := R;
  if (FViewInfo.DefaultColorStyle = cxdcText) and not FViewInfo.FoundItem then
    FViewInfo.FColorBoxRect.Right := FViewInfo.FColorBoxRect.Left
  else
  begin
    if FViewInfo.ShowDescriptions then
    begin
      if FViewInfo.ColorBoxAlign = cbaLeft then
      begin
        FViewInfo.FColorBoxRect.Right := FViewInfo.FColorBoxRect.Left + FViewInfo.ColorBoxWidth ;
        R.Left := FViewInfo.FColorBoxRect.Right;
      end
      else
      begin
        FViewInfo.FColorBoxRect.Left := FViewInfo.FColorBoxRect.Right - FViewInfo.ColorBoxWidth ;
        R.Right := FViewInfo.FColorBoxRect.Left;
      end;
    end;
  end;
  FViewInfo.ClientRect := R;
  if not IsInplace then
    InflateRect(R, -2, -2)
  else
    InflateRect(R, -2, -1);
  FViewInfo.TextRect := R;
  if not FViewInfo.ShowDescriptions then FViewInfo.Text := '';
  if not IsInplace then FViewInfo.DrawSelectionBar := False;
end;

procedure TcxCustomColorComboBoxViewData.CalculateViewInfoProperties(AViewInfo: TcxCustomEditViewInfo);
var
  AProperties: TcxCustomColorComboBoxProperties;
begin
  AProperties := TcxCustomColorComboBoxProperties(Properties);
  with TcxCustomColorComboBoxViewInfo(AViewInfo) do
  begin
    BkColor := BackgroundColor;
    ColorBoxAlign := AProperties.ColorBoxAlign;
    ColorBoxWidth := AProperties.ColorBoxWidth;
    ColorBoxFrameColor := AProperties.ColorBoxFrameColor;
    ShowDescriptions := AProperties.ShowDescriptions;
    DefaultColorStyle := AProperties.DefaultColorStyle;
    if (DefaultColorStyle = cxdcCustom) and (not FoundItem) then
      AProperties.DoGetDefaultColor(FColorBoxColor);
  end;
end;

function TcxCustomColorComboBoxViewData.InternalEditValueToDisplayText(
  AEditValue: TcxEditValue): string;
var
  AColor: TColor;
  AColorFound: Boolean;
  ADisplayText: string;
begin
  Properties.GetColorComboBoxDisplayValue(AEditValue, AColor, ADisplayText,
    AColorFound);
  Result := ADisplayText;
end;

function TcxCustomColorComboBoxViewData.InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
  AEditSizeProperties: TcxEditSizeProperties; var MinContentSize: TSize;
  AViewInfo: TcxCustomEditViewInfo): TSize;
begin
  Result := inherited InternalGetEditConstantPartSize(ACanvas, AIsInplace,
    AEditSizeProperties, MinContentSize, AViewInfo);
  if TcxCustomColorComboBoxProperties(Properties).ShowDescriptions then
    Result.cx := Result.cx + TcxCustomColorComboBoxProperties(Properties).ColorBoxWidth + 6;
end;

function TcxCustomColorComboBoxViewData.IsComboBoxStyle: Boolean;
begin
  Result := True;
end;

function TcxCustomColorComboBoxViewData.GetProperties: TcxCustomColorComboBoxProperties;
begin
  Result := TcxCustomColorComboBoxProperties(FProperties);
end;

procedure TcxCustomColorComboBoxViewData.DisplayValueToDrawValue(const ADisplayValue: TcxEditValue;
  AViewInfo: TcxCustomEditViewInfo);
var
  AViewInfoAccess: TcxCustomColorComboBoxViewInfo;
begin
  if (Edit = nil) or IsVarEmpty(ADisplayValue) then
    Exit;
  AViewInfoAccess := TcxCustomColorComboBoxViewInfo(AViewInfo);
  Properties.InternalGetColorComboBoxDisplayValue(
    TcxCustomColorComboBox(Edit).ILookupData.CurrentKey, Edit.EditValue,
    AViewInfoAccess.FColorBoxColor, AViewInfoAccess.Text,
    AViewInfoAccess.FFoundItem);
end;

procedure TcxCustomColorComboBoxViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  AColorComboViewInfo: TcxCustomColorComboBoxViewInfo;
begin
  AColorComboViewInfo := TcxCustomColorComboBoxViewInfo(AViewInfo);
  Properties.GetColorComboBoxDisplayValue(AEditValue,
    AColorComboViewInfo.FColorBoxColor, AColorComboViewInfo.Text,
    AColorComboViewInfo.FFoundItem);
  if PreviewMode then
    AColorComboViewInfo.Text := '';
  DoOnGetDisplayText(string(AColorComboViewInfo.Text));
end;

{ TcxCustomColorComboBoxListBox }

function TcxCustomColorComboBoxListBox.GetItemHeight(AIndex: Integer = -1): Integer;
begin
  with Edit.ActiveProperties do
  begin
    if ItemHeight > 0 then
      Result := ItemHeight
    else
    begin
      Result := inherited GetItemHeight;
      if Result < 16 then
        Result := 16;
    end;
    if (AIndex >= 0) and Edit.IsOnMeasureItemEventAssigned then
      Edit.DoOnMeasureItem(AIndex, Canvas, Result);
    if AIndex = FMRUColors.Count - 1 then
      Inc(Result, MRUDelimiterWidth);
  end;
end;

procedure TcxCustomColorComboBoxListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  AColorBoxRect, ATextRect: TRect;
  AFlags: Longint;
begin
  SaveCanvasParametersForFocusRect;
  try
    if DoDrawItem(Index, Rect, State) then
      Exit;

    Canvas.FillRect(Rect);
    AColorBoxRect := Rect;
    if Index = Edit.ActiveProperties.MRUColors.Count - 1 then
      Dec(AColorBoxRect.Bottom, MRUDelimiterWidth);
    ATextRect := AColorBoxRect;
    if Edit.ActiveProperties.ShowDescriptions then
    begin
      AFlags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_LEFT or DT_NOPREFIX);
      if Edit.ActiveProperties.ColorBoxAlign = cbaRight then
      begin
        Dec(ATextRect.Right, Edit.ActiveProperties.ColorBoxWidth);
        AColorBoxRect.Left := ATextRect.Right;
      end
      else
      begin
        Inc(ATextRect.Left, Edit.ActiveProperties.ColorBoxWidth);
        AColorBoxRect.Right := ATextRect.Left;
      end;
      Canvas.DrawText(GetItem(Index), ATextRect, AFlags);
    end
    else
      ATextRect.Left := AColorBoxRect.Right;
    DrawColorBox(Canvas, AColorBoxRect, Edit.ActiveProperties.ColorBoxFrameColor,
      Edit.ActiveProperties.GetColorByIndex(Index), Canvas.Brush.Color, cxdcColor);
    if Index = Edit.ActiveProperties.FMRUColors.Count - 1 then
      DrawMRUDelimiter(Canvas.Canvas, Rect, odSelected in State);
  finally
    RestoreCanvasParametersForFocusRect;
  end;
end;

procedure TcxCustomColorComboBoxListBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button <> mbLeft then Exit;
  SetCaptureControl(nil);
  Edit.CloseUp(crEnter);
end;

function TcxCustomColorComboBoxListBox.GetEdit: TcxCustomColorComboBox;
begin
  Result := TcxCustomColorComboBox(inherited Edit);
end;

{ TcxColorComboBoxLookupData }

function TcxColorComboBoxLookupData.GetListBoxClass: TcxCustomEditListBoxClass;
begin
  Result := TcxCustomColorComboBoxListBox;
end;

function TcxColorComboBoxLookupData.GetItem(Index: Integer): string;
begin
  with TcxCustomColorComboBoxProperties(ActiveProperties) do
    Result := GetDescriptionByIndex(Index);
end;

function TcxColorComboBoxLookupData.GetItemCount: Integer;
begin
  with TcxCustomColorComboBoxProperties(ActiveProperties) do
    Result := MRUColors.Count + Items.Count;
end;

function TcxColorComboBoxLookupData.GetVisualAreaPreferredSize(
  AMaxHeight: Integer; AWidth: Integer = 0): TSize;
var
  AScrollWidth: Integer;
begin
  Result := inherited GetVisualAreaPreferredSize(AMaxHeight, AWidth);
  Result.cx := Result.cx +
    TcxCustomColorComboBoxProperties(ActiveProperties).ColorBoxWidth;
  AScrollWidth := List.ScrollWidth;
  Inc(AScrollWidth,
    TcxCustomColorComboBoxProperties(ActiveProperties).ColorBoxWidth);
  List.ScrollWidth := 0;
  List.ScrollWidth := AScrollWidth;
end;

procedure TcxColorComboBoxLookupData.TextChanged;
begin
  if not TcxCustomColorComboBox(Edit).EditModeSetting then
    with TcxCustomColorComboBoxProperties(ActiveProperties) do
      InternalSetCurrentKey(IndexByValue(Edit.EditValue));
end;

function TcxColorComboBoxLookupData.InternalChangeCurrentMRUColorPosition(
  const AColor: TColor): Integer;
var
  FIndex: Integer;
begin
  Result := ItemIndex;
  with TcxCustomColorComboBoxProperties(ActiveProperties) do
    if ItemIndex >= (FMRUColors.Count - 1) then
    begin
      FIndex := FMRUColors.GetIndexByColor(AColor);
      if FIndex >= 0 then
      begin
        Result := FIndex;
        InternalSetCurrentKey(FIndex);
      end;
    end;
end;
{ TcxColorComboBoxLookupData }

{ TcxCustomColorComboBoxProperties }

constructor TcxCustomColorComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FItems := TcxColorComboBoxItems.Create(Self, TcxColorComboBoxItem);
  FCustomColors := TcxColorComboBoxItems.Create(Self, TcxColorComboBoxItem);
  FCustomColors.OnUpdate := CustomColorChanged;
  FMRUColors := TcxColorComboBoxItems.Create(Self, TcxColorComboBoxItem);

  DropDownListStyle := lsFixedList;
  FInternalUpdate := False;
  FColorBoxAlign := cbaLeft;
  FColorBoxWidth := 30;
  FColorBoxFrameColor := clBtnShadow;
  FColorDialogType := cxcdtDefault;
  FShowDescriptions := True;
  FDefaultColor := clWindow;
  FDefaultDescription := cxGetResourceString(@cxSColorComboBoxDefaultDescription);
  FDefaultColorStyle := cxdcColor;
  FAllowSelectColor := False;
  FColorComboStyle := cxccsComboEdit;
  FNamingConvention := cxncDelphi;
  FColorValueFormat := cxcvRGB;
  FMaxMRUColors := 10;
  PrepareList := cxplDelphi;
  Buttons.Add;
  GlyphButtonIndex := 1;
  Buttons[1].Kind := bkEllipsis;
  Buttons[1].Default := False;
  Buttons[1].Visible := False;
end;

destructor TcxCustomColorComboBoxProperties.Destroy;
begin
  FreeAndNil(FMRUColors);
  FreeAndNil(FCustomColors);
  FreeAndNil(FItems);
  inherited;
end;

procedure TcxCustomColorComboBoxProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomColorComboBoxProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomColorComboBoxProperties do
      begin
        Self.ColorBoxWidth := ColorBoxWidth;
        Self.ColorBoxAlign := ColorBoxAlign;
        Self.ColorBoxFrameColor := ColorBoxFrameColor;
        Self.ColorDialogType := ColorDialogType;
        Self.DefaultColor := DefaultColor;
        Self.DefaultDescription := DefaultDescription;
        Self.DefaultColorStyle := DefaultColorStyle;
        Self.ShowDescriptions := ShowDescriptions;
        Self.AllowSelectColor := AllowSelectColor;
        Self.ColorComboStyle := ColorComboStyle;
        Self.MaxMRUColors := MaxMRUColors;
        Self.NamingConvention := NamingConvention;
        Self.PrepareList := PrepareList;
        Self.ColorValueFormat := ColorValueFormat;
        Self.OnSelectCustomColor := OnSelectCustomColor;
        Self.OnNamingConvention := OnNamingConvention;
        Self.OnGetDefaultColor := OnGetDefaultColor;
        Self.OnAddedMRUColor := OnAddedMRUColor;
        Self.OnDeletedMRUColor := OnDeletedMRUColor;
        Self.CustomColors := CustomColors;
        Self.Items := Items;
        Self.MRUColors.Assign(MRUColors);
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomColorComboBoxProperties.Changed;
begin
  if FInternalUpdate then Exit;
  inherited;
end;

function TcxCustomColorComboBoxProperties.CompareDisplayValues(
  const AEditValue1, AEditValue2: TcxEditValue): Boolean;
var
  AColor1, AColor2: TColor;
  AColorFound1, AColorFound2: Boolean;
  ADescription1, ADescription2: string;
begin
  GetColorComboBoxDisplayValue(AEditValue1, AColor1, ADescription1, AColorFound1);
  GetColorComboBoxDisplayValue(AEditValue2, AColor2, ADescription2, AColorFound2);

  Result := ShowColorBox(AColorFound1) = ShowColorBox(AColorFound2);
  if Result then
    if ShowColorBox(AColorFound1) then
      Result := (AColor1 = AColor2) and (not ShowDescriptions or InternalCompareString(ADescription1, ADescription2, True))
    else
      Result := not ShowDescriptions or InternalCompareString(ADescription1, ADescription2, True);
//  Result := (AColorFound1 = AColorFound2) and (not AColorFound1 or
//    (AColor1 = AColor2) and (not ShowDescriptions or InternalCompareString(ADescription1, ADescription2, True)));
end;

class function TcxCustomColorComboBoxProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxColorComboBox;
end;

class function TcxCustomColorComboBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomColorComboBoxViewInfo;
end;

function TcxCustomColorComboBoxProperties.GetEditValueSource(AEditFocused: Boolean):
  TcxDataEditValueSource;
begin
  Result := evsValue;
end;

function TcxCustomColorComboBoxProperties.IsDisplayValueValid(
  var DisplayValue: TcxEditValue; AEditFocused: Boolean): Boolean;
begin
  Result := True;
end;

procedure TcxCustomColorComboBoxProperties.PrepareDisplayValue(
  const AEditValue: TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean);
var
  FValue: TColor;
  FValueText: string;
begin
  TranslateValues(AEditValue, FValue, FValueText);
  DisplayValue := FValueText;
end;

function TcxCustomColorComboBoxProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoEditing, esoFiltering, esoHorzAlignment, esoSorting,
    esoSortingByDisplayText];
  if Buttons.Count > 0 then
    Include(Result, esoHotTrack);
  if ShowDescriptions then
    Include(Result, esoIncSearch);
end;

function TcxCustomColorComboBoxProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
var
  AColor: TColor;
  ADescription: string;
begin
  TranslateValues(AEditValue, AColor, ADescription, True);
  Result := ADescription;
end;

procedure TcxCustomColorComboBoxProperties.Update(AProperties: TcxCustomEditProperties);
begin
  if AProperties is TcxCustomColorComboBoxProperties then
    with TcxCustomColorComboBoxProperties(AProperties) do
    begin
      Items.Assign(Self.Items);
      MRUColors.Assign(Self.MRUColors);
    end;
end;

procedure TcxCustomColorComboBoxProperties.GetColorComboBoxDisplayValue(
  const AEditValue: TcxEditValue; out AColor: TColor;
  out ADescription: string; out AColorFound: Boolean);
begin
  InternalGetColorComboBoxDisplayValue(IndexByValue(AEditValue), AEditValue,
    AColor, ADescription, AColorFound);
end;

procedure TcxCustomColorComboBoxProperties.PrepareColorList(
  APrepareList: TcxColorPrepareList; ASaveCustom, ASaveMRU: Boolean);
begin
  LockUpdate(True);
  try
    if not ASaveCustom then
      Items.Clear
    else
      Items.ClearNonCustom;
    if not ASaveMRU then
      ClearMRUColors;
    InternalPrepareColorList(APrepareList);
    if ASaveMRU then
      ValidateMRUColors;
    SynchronizeCustomColors;
    if Assigned(FOnLoadColorList) then
      FOnLoadColorList(Self);
  finally
    LockUpdate(False);
  end;
end;

procedure TcxCustomColorComboBoxProperties.PrepareDelphiColorList(
  const ASaveCustom, ASaveMRU: Boolean);
begin
  PrepareColorList(cxplDelphi, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBoxProperties.PrepareHTML4ColorList(
  const ASaveCustom, ASaveMRU: Boolean);
begin
  PrepareColorList(cxplHTML4, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBoxProperties.PrepareX11ColorList(
  const ASaveCustom, ASaveMRU: Boolean);
begin
  PrepareColorList(cxplX11, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBoxProperties.PrepareX11OrderedColorList(
  const ASaveCustom, ASaveMRU: Boolean);
begin
  PrepareColorList(cxplX11Ordered, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBoxProperties.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty('Items', ReadCustomColors, nil, False);
  Filer.DefineProperty('PrepareInfo', ReadPrepareInfo, nil, False);
end;

function TcxCustomColorComboBoxProperties.ShowColorBox(AColorFound: Boolean): Boolean;
begin
  Result := not (not AColorFound and (DefaultColorStyle = cxdcText));
end;

class function TcxCustomColorComboBoxProperties.GetLookupDataClass: TcxInterfacedPersistentClass;
begin
  Result := TcxColorComboBoxLookupData;
end;

class function TcxCustomColorComboBoxProperties.GetPopupWindowClass: TcxCustomEditPopupWindowClass;
begin
  Result := TcxColorComboBoxPopupWindow;
end;

class function TcxCustomColorComboBoxProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomColorComboBoxViewData;
end;

function TcxCustomColorComboBoxProperties.HasDisplayValue: Boolean;
begin
  Result := False;
end;

function TcxCustomColorComboBoxProperties.IsEditValueNumeric: Boolean;
begin
  Result := True;
end;

function TcxCustomColorComboBoxProperties.GetColorByIndex(AIndex: Integer): TColor;
begin
  if AIndex <= (MRUColors.Count - 1) then
    Result := MRUColors.GetColorByIndex(AIndex, DefaultColor)
  else
    Result := Items.GetColorByIndex(AIndex - MRUColors.Count, DefaultColor);
end;

function TcxCustomColorComboBoxProperties.GetIndexByColor(AColor: TColor): Integer;
begin
  Result := MRUColors.GetIndexByColor(AColor);
  if Result = -1 then
  begin
    Result := Items.GetIndexByColor(AColor);
    if Result <> -1 then
      Result := Result + MRUColors.Count;
  end;
end;

function TcxCustomColorComboBoxProperties.GetDescriptionByIndex(AIndex: Integer): string;
begin
  if not ShowDescriptions then
    Result := ''
  else
  begin
    if AIndex = -1 then
      Result := DefaultDescription
    else
      Result := DoConvertNaming(AIndex);
  end;
end;

function TcxCustomColorComboBoxProperties.IndexByValue(const AValue: TcxEditValue): Integer;
var
  AColor: TColor;
  AIsValueValid: Boolean;
  I: Integer;
begin
  Result := -1;
  if IsVarEmpty(AValue) then
    Exit;
  AIsValueValid := cxStrToColor(VarToStr(AValue), AColor);
  if not AIsValueValid then
    Exit;
  for I := 0 to MRUColors.Count - 1 do
    if AColor = MRUColors[I].Color then
    begin
      Result := I;
      Break;
    end;
  if Result = -1 then
    for I := 0 to Items.Count - 1 do
      if AColor = Items[I].Color then
      begin
        Result := I + MRUColors.Count;
        Break;
      end;
end;

function TcxCustomColorComboBoxProperties.IsDisplayValueNumeric: Boolean;
begin
  Result := False;
end;

function TcxCustomColorComboBoxProperties.AddMRUColor(const AColor: TColor): TcxMRUColorAction;
var
  FIndex: Integer;
begin
  Result := mcaNone;
  if MaxMRUColors = 0 then Exit;
  FIndex := FMRUColors.GetIndexByColor(AColor);
  if FIndex <> -1 then
  begin
    if (FIndex > 0) and (FIndex < FMRUColors.Count) then
    begin
      Result := mcaMoved;
      FMRUColors.Move(FIndex, 0);
      if Assigned(FOnAddedMRUColor) then FOnAddedMRUColor(Self);
    end
    else
      Result := mcaNone;
  end
  else
    Result := mcaAdded;
  if Result = mcaAdded then
  begin
    FIndex := Items.GetIndexByColor(AColor);
    if FIndex > -1 then
    begin
      FInternalUpdate := True;
      try
        FMRUColors.InsertColor(0, AColor, Items[FIndex].Description);
        DeleteOverMRUColors;
      finally
        FInternalUpdate := False;
      end;
      if Assigned(FOnAddedMRUColor) then FOnAddedMRUColor(Self);
    end
    else
      Result := mcaNone;
  end;
end;

function TcxCustomColorComboBoxProperties.DelMRUColor(const AColor: TColor): TcxMRUColorAction;
var
  FIndex: Integer;
begin
  Result := mcaNone;
  {Check for right Color}
  FIndex := Items.GetIndexByColor(AColor);
  if FIndex < 0 then Exit;
  if FMRUColors.FindColorItem(AColor) <> nil then
  begin
{$IFDEF DELPHI5}
    FMRUColors.Delete(FIndex);
{$ELSE}
    TcxColorComboBoxItem(FMRUColors.Items[FIndex]).Free;
{$ENDIF}
    Result := mcaDeleted;
    if Assigned(FOnDeletedMRUColor) then FOnDeletedMRUColor(Self);
  end;
end;

procedure TcxCustomColorComboBoxProperties.ClearMRUColors;
begin
  FMRUColors.Clear;
  Changed;
end;

procedure TcxCustomColorComboBoxProperties.DoGetDefaultColor(var AColor: TColor);
begin
  if Assigned(FOnGetDefaultColor) then FOnGetDefaultColor(Self, AColor);
end;

procedure TcxCustomColorComboBoxProperties.TranslateValues(const AEditValue: TcxEditValue;
  var AColor: TColor; var ADescription: string; ANeedDescription: Boolean = False);
var
  FFoundIndex: Integer;
  FValid: Boolean;
  S: string;
begin
  FFoundIndex := IndexByValue(AEditValue);
  if ((FFoundIndex <> -1) and (not ANeedDescription or ShowDescriptions) or
    ((FFoundIndex = -1) and (ColorComboStyle = cxccsComboList))) and
    not IsVarEmpty(AEditValue) then
      ADescription := GetDescriptionByIndex(FFoundIndex)
  else
  begin
    FValid := cxStrToColor(VarToStr(AEditValue), AColor);
    if FValid then
    begin
      S := ConvertColorName(AColor, '', NamingConvention, ColorValueFormat);
      if Assigned(OnNamingConvention) then
        OnNamingConvention(Self, AColor, S);
      ADescription := S;
    end
    else
    begin
      AColor := DefaultColor;
      ADescription := DefaultDescription;
    end;
  end;
end;

function TcxCustomColorComboBoxProperties.ColorItemByIndex(AIndex: Integer): TcxColorComboBoxItem;
begin
  if AIndex = -1 then
    Result := nil
  else
  begin
    if AIndex <= (MRUColors.Count - 1) then
      Result := MRUColors.Items[AIndex]
    else
      Result := Items[AIndex - MRUColors.Count];
  end;
end;

procedure TcxCustomColorComboBoxProperties.DeleteOverMRUColors;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := FMRUColors.Count - 1 downto 0 do
    begin
      if I >= FMaxMRUColors then
      begin
        FMRUColors.Delete(I);
        if Assigned(FOnDeletedMRUColor) then FOnDeletedMRUColor(Self);
      end
      else
        Break;
    end;
  finally
    EndUpdate;
  end;
end;

function TcxCustomColorComboBoxProperties.DoConvertNaming(AIndex: Integer): string;
var
  FItem: TcxColorComboBoxItem;
begin
  FItem := ColorItemByIndex(AIndex);
  if FItem = nil then
    Result := ''
  else
    Result := ConvertColorName(FItem.Color, FItem.Description,
      NamingConvention, ColorValueFormat);
  if Assigned(OnNamingConvention) then
  begin
    if FItem = nil then
      OnNamingConvention(Self, DefaultColor, Result)
    else
      OnNamingConvention(Self, FItem.Color, Result);
  end;
end;

function TcxCustomColorComboBoxProperties.GetItems: TcxColorComboBoxItems;
begin
  Result := FItems;
end;

procedure TcxCustomColorComboBoxProperties.InternalGetColorComboBoxDisplayValue(
  AItemIndex: Integer; const AEditValue: TcxEditValue; out AColor: TColor;
  out ADescription: string; out AColorFound: Boolean);
begin
  AColorFound := AItemIndex <> -1;
  ADescription := GetDescriptionByIndex(AItemIndex);
  if not AColorFound and (ColorComboStyle = cxccsComboList) and
    not IsVarEmpty(AEditValue) then
      AColor := DefaultColor
  else
  begin
    if AItemIndex <> -1 then
      AColor := GetColorByIndex(AItemIndex)
    else
      TranslateValues(AEditValue, AColor, ADescription);
  end;
end;

procedure TcxCustomColorComboBoxProperties.InternalPrepareColorList(APrepareList: TcxColorPrepareList);
begin
  case APrepareList of
    cxplDelphi: InternalPrepareColorList(cxDelphiColorValues, cxDelphiColorNames);
    cxplHTML4: InternalPrepareColorList(cxHTML4ColorValues, cxHTML4ColorNames);
    cxplX11: InternalPrepareColorList(cxX11ColorValues, cxX11ColorNames);
    cxplX11Ordered: InternalPrepareColorList(cxX11OrderedColorValues, cxX11OrderedColorNames);
  end;
end;

procedure TcxCustomColorComboBoxProperties.InternalPrepareColorList(
  AColorValues: array of TColor; AColorNames: array of string);
var
  I: Integer;
  AItem: TcxColorComboBoxItem;
begin
  Items.BeginUpdate;
  try
    for I:= Low(AColorValues) to High(AColorValues) do
    begin
      AItem := Items.AddColor(AColorValues[I], AColorNames[I]);
      if AItem <> nil then
        AItem.FIsCustomColor := False;
    end;
  finally
    Items.EndUpdate;
  end;
end;

function TcxCustomColorComboBoxProperties.IsDefaultDescriptionStored: Boolean;
begin
  Result := DefaultDescription <>
    cxGetResourceString(@cxSColorComboBoxDefaultDescription);
end;

procedure TcxCustomColorComboBoxProperties.ReadCustomColors(Reader: TReader);
begin
  Reader.ReadValue;
  Reader.ReadCollection(FCustomColors);
end;

procedure TcxCustomColorComboBoxProperties.ReadPrepareInfo(Reader: TReader);
begin
  Reader.ReadString;
end;

procedure TcxCustomColorComboBoxProperties.SetAllowSelectColor(Value: Boolean);
begin
  if FAllowSelectColor <> Value then
  try
    FAllowSelectColor := Value;
    BeginUpdate;
    Buttons[1].Visible := Value;
    if Value then
      GlyphButtonIndex := 1
    else
      GlyphButtonIndex := 0;
  finally
    EndUpdate;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetColorBoxAlign(Value : TcxColorBoxAlign);
begin
  if FColorBoxAlign <> Value then
  begin
    FColorBoxAlign := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetColorBoxFrameColor(Value: TColor);
begin
  if FColorBoxFrameColor <> Value then
  begin
    FColorBoxFrameColor := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetColorBoxWidth(Value: Integer);
begin
  if FColorBoxWidth <> Value then
  begin
    if Value < 0 then Value := 0;
    FColorBoxWidth := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetColorComboStyle(Value: TcxColorComboStyle);
begin
  if FColorComboStyle <> Value then
  begin
    FColorComboStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetColorValueFormat(Value: TcxColorValueFormat);
begin
  if FColorValueFormat <> Value then
  begin
    FColorValueFormat := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetDefaultColor(Value: TColor);
begin
  if FDefaultColor <> Value then
  begin
    FDefaultColor := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetDefaultDescription(Value: string);
begin
  if FDefaultDescription <> Value then
  begin
    FDefaultDescription := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetDefaultColorStyle(Value: TcxDefaultColorStyle);
begin
  if FDefaultColorStyle <> Value then
  begin
    FDefaultColorStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetCustomColors(Value: TcxColorComboBoxItems);
begin
  FCustomColors.Assign(Value);
end;

procedure TcxCustomColorComboBoxProperties.SetItems(const Value: TcxColorComboBoxItems);
begin
  FItems.Assign(Value);
end;

procedure TcxCustomColorComboBoxProperties.SetMaxMRUColors(Value: Byte);
var
  FOldMaxMRUColors: Byte;
begin
  if FMaxMRUColors <> Value then
  begin
    FOldMaxMRUColors := FMaxMRUColors;
    FMaxMRUColors := Value;
    if FOldMaxMRUColors > Value then
      DeleteOverMRUColors;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetNamingConvention(Value: TcxColorNamingConvention);
begin
  if FNamingConvention <> Value then
  begin
    FNamingConvention := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetPrepareList(Value: TcxColorPrepareList);
begin
  if FPrepareList <> Value then
  begin
    FPrepareList := Value;
    PrepareColorList(FPrepareList, True, True);
  end;
end;

procedure TcxCustomColorComboBoxProperties.SetShowDescriptions(const Value: Boolean);
begin
  if FShowDescriptions <> Value then
  begin
    FShowDescriptions := Value;
    Changed;
  end;
end;

procedure TcxCustomColorComboBoxProperties.SynchronizeCustomColors;
var
  I: Integer;
begin
  Items.BeginUpdate;
  try
    Items.ClearCustom;
    for I := CustomColors.Count - 1 downto 0 do
      Items.InsertColor(0, CustomColors[I].Color, CustomColors[I].Description);
  finally
    Items.EndUpdate;
  end;
end;

procedure TcxCustomColorComboBoxProperties.CustomColorChanged(ASender: TObject);
begin
  SynchronizeCustomColors;
end;

procedure TcxCustomColorComboBoxProperties.ValidateMRUColors;
var
  I: Integer;
begin
  for I := (MRUColors.Count - 1) downto 0 do
    if Items.GetIndexByColor(MRUColors[I].Color) = -1 then
      MRUColors.Delete(I);
end;

{ TcxCustomColorComboBox }

destructor TcxCustomColorComboBox.Destroy;
begin
  FreeAndNil(FColorDialog);
  inherited Destroy;
end;

function TcxCustomColorComboBox.Deactivate: Boolean;
begin
  Result := inherited Deactivate;
  UpdateMRUList;
end;

function TcxCustomColorComboBox.Focused: Boolean;
begin
  Result := FIsDialogShowed or inherited Focused;
end;

class function TcxCustomColorComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomColorComboBoxProperties;
end;

function TcxCustomColorComboBox.IsChildWindow(AWnd: THandle): Boolean;
begin
  Result := inherited IsChildWindow(AWnd) or
    (FIsDialogShowed and ((ColorDialog.Handle = HWND(AWnd)) or (IsChild(ColorDialog.Handle, AWnd))));
end;

procedure TcxCustomColorComboBox.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
begin
  EditValue := LookupKeyToEditValue(ILookupData.CurrentKey);
end;

procedure TcxCustomColorComboBox.AfterPosting;
begin
  inherited AfterPosting;
  if IsInplace and FNeedsUpdateMRUList then
    FDontCheckModifiedWhenUpdatingMRUList := True;
end;

procedure TcxCustomColorComboBox.ContainerStyleChanged(Sender: TObject);
begin
  inherited ContainerStyleChanged(Sender);
end;

procedure TcxCustomColorComboBox.PropertiesChanged(Sender: TObject);
begin
  if FPropertiesUpdate then Exit;
  FPropertiesUpdate := True;
  try
    with ActiveProperties do
      if AllowSelectColor then
        if ButtonGlyph.Empty then
          Buttons[1].Kind := bkEllipsis
        else
          Buttons[1].Kind := bkGlyph
      else
        if ButtonGlyph.Empty then
          Buttons[0].Kind := bkDown
        else
          Buttons[0].Kind := bkGlyph;
    inherited PropertiesChanged(Sender);
  finally
    FPropertiesUpdate := False;
  end;
end;

function TcxCustomColorComboBox.GetColorDialog: TColorDialog;
begin
  if FColorDialog = nil then
    FColorDialog := TColorDialog.Create(Self);
  Result := FColorDialog;
end;

function TcxCustomColorComboBox.GetColorValue: TColor;
begin
  Result := TcxCustomColorComboBoxViewInfo(ViewInfo).ColorBoxColor;
end;

function TcxCustomColorComboBox.IsColorValueStored: Boolean;
begin
  Result := ColorValue <> ActiveProperties.DefaultColor;
end;

procedure TcxCustomColorComboBox.SetColorValue(Value: TColor);
begin
  if ColorValue <> Value then
  begin
    LockClick(True);
    try
      InternalEditValue := Value;
    finally
      LockClick(False);
    end;
  end;
end;

procedure TcxCustomColorComboBox.DblClick;
begin
  inherited DblClick;
end;

procedure TcxCustomColorComboBox.DoButtonClick(AButtonVisibleIndex: Integer);
begin
  if AButtonVisibleIndex = 1 then
    DoSelectCustomColor(Self);
end;

procedure TcxCustomColorComboBox.DoSelectCustomColor(Sender: TObject);
var
  AColorProvided: TColor;
  AColorDescription: string;
  AAddToList: Boolean;
  AIndex: Integer;
begin
  AColorProvided := clNone;
  AColorDescription := '';
  AAddToList := True;

  if ActiveProperties.ColorDialogType = cxcdtDefault then
  begin
    try
      FIsDialogShowed := True;
      ColorDialog.Color := ColorValue;
      if ColorDialog.Execute then
        AColorProvided := ColorDialog.Color
      else
      begin
        DoClosePopup(crCancel);
        Exit;
      end;
    finally
      FIsDialogShowed := False;
    end;
  end;

  DoOnSelectCustomColor(AColorProvided, AColorDescription, AAddToList);

  AIndex := ActiveProperties.GetIndexByColor(AColorProvided);
  if AAddToList and (AIndex = -1) then
  begin
    ActiveProperties.CustomColors.AddColor(AColorProvided, AColorDescription);
    ActiveProperties.AddMRUColor(AColorProvided);
  end
  else
    ItemIndex := AIndex;

  FixMRUPosition(AColorProvided);

  if DoEditing and AAddToList then
  begin
    ColorValue := AColorProvided;
    if ActiveProperties.MRUColors.Count > 0 then
      ItemIndex := ActiveProperties.MRUColors.GetIndexByColor(AColorProvided);
    ModifiedAfterEnter := True;
    InternalPostEditValue;
  end;
  DoClosePopup(crEnter);  
end;

function TcxCustomColorComboBox.GetDisplayValue: string;
begin
  if IsDestroying then
    Result := ''
  else
    Result := ViewInfo.Text;
end;

function TcxCustomColorComboBox.GetEditingValue: TcxEditValue;
begin
  Result := EditValue;
end;

function TcxCustomColorComboBox.GetInnerEditClass: TControlClass;
begin
  Result := TcxCustomColorComboBoxInnerEdit;
end;

procedure TcxCustomColorComboBox.Initialize;
begin
  inherited Initialize;
  FIsDialogShowed := False;
  FPropertiesUpdate := False;
  ControlStyle := ControlStyle - [csClickEvents];
  ActiveProperties.FOnLoadColorList := PropertiesLoadColorListHandler;
end;

procedure TcxCustomColorComboBox.InitializePopupWindow;
begin
  inherited InitializePopupWindow;
  TcxColorComboBoxPopupWindow(PopupWindow).SysPanelStyle :=
    ActiveProperties.PopupSizeable;
end;

procedure TcxCustomColorComboBox.ClearEditValue;
begin
  InternalEditValue := Null;
  ModifiedAfterEnter := True;
  SynchronizeDisplayValue;
  if ActiveProperties.ImmediatePost and CanPostEditValue then
    InternalPostEditValue;
end;

procedure TcxCustomColorComboBox.DoOnSelectCustomColor(var AColor: TColor;
  var AColorDescription: string; var AddToList: Boolean);
begin
  with Properties do
    if Assigned(OnSelectCustomColor) then
      OnSelectCustomColor(Self, AColor, AColorDescription, AddToList);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnSelectCustomColor) then
        OnSelectCustomColor(Self, AColor, AColorDescription, AddToList);
end;

procedure TcxCustomColorComboBox.DoEditKeyDown(var Key: Word; Shift: TShiftState);
var
  AKey: Word;
begin
  AKey := TranslateKey(Key);
  if (AKey = VK_DELETE) and DoEditing then
    ClearEditValue
  else
    inherited DoEditKeyDown(Key, Shift);
end;

function TcxCustomColorComboBox.IsValidChar(AChar: Char): Boolean;
begin
  Result := IsTextChar(AChar);
end;

function TcxCustomColorComboBox.GetProperties: TcxCustomColorComboBoxProperties;
begin
  Result := TcxCustomColorComboBoxProperties(FProperties);
end;

function TcxCustomColorComboBox.GetActiveProperties: TcxCustomColorComboBoxProperties;
begin
  Result := TcxCustomColorComboBoxProperties(InternalGetActiveProperties);
end;

function TcxCustomColorComboBox.GetLookupData: TcxColorComboBoxLookupData;
begin
  Result := TcxColorComboBoxLookupData(FLookupData);
end;

procedure TcxCustomColorComboBox.SetProperties(
  Value: TcxCustomColorComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

function TcxCustomColorComboBox.AddMRUColor(const AColor: TColor): TcxMRUColorAction;
begin
  Result := ActiveProperties.AddMRUColor(AColor);
end;

function TcxCustomColorComboBox.DelMRUColor(const AColor: TColor): TcxMRUColorAction;
begin
  Result := ActiveProperties.DelMRUColor(AColor);
end;

function TcxCustomColorComboBox.LookupKeyToEditValue(const AKey: TcxEditValue): TcxEditValue;
begin
  if not VarEqualsExact(AKey, -1) then
    Result := ActiveProperties.GetColorByIndex(AKey)
  else
    Result := Null;
end;

procedure TcxCustomColorComboBox.SynchronizeDisplayValue;
begin
  inherited;
  ILookupData.TextChanged;
  ResetOnNewDisplayValue;
  UpdateDrawValue;
end;

procedure TcxCustomColorComboBox.CloseUp(AReason: TcxEditCloseUpReason);
begin
  FNeedsUpdateMRUList := FNeedsUpdateMRUList or (AReason in [crTab, crEnter, crClose]);
  try
    inherited CloseUp(AReason);
  finally
    UpdateMRUList;
  end;
end;

procedure TcxCustomColorComboBox.FixMRUPosition(AColor: TColor);
var
  FMRUColorAction: TcxMRUColorAction;
begin
  FMRUColorAction := AddMRUColor(AColor);
  if (FMRUColorAction = mcaAdded) or
     (FMRUColorAction = mcaMoved) then
    ItemIndex := LookupData.InternalChangeCurrentMRUColorPosition(AColor);
end;

procedure TcxCustomColorComboBox.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
begin
  if IsDestroying then Exit;
  inherited InternalSetEditValue(Value, AValidateEditValue);
end;

procedure TcxCustomColorComboBox.PropertiesLoadColorListHandler(Sender: TObject);
begin
  if not IsLoading then
    FlushEditValue;
end;

procedure TcxCustomColorComboBox.UpdateMRUList;
begin
  try
    if FNeedsUpdateMRUList and (FDontCheckModifiedWhenUpdatingMRUList or ModifiedAfterEnter) then
      FixMRUPosition(ActiveProperties.GetColorByIndex(ILookupData.CurrentKey));
  finally
    FDontCheckModifiedWhenUpdatingMRUList := False;
    FNeedsUpdateMRUList := False;
  end;
end;

procedure TcxCustomColorComboBox.FlushEditValue;
begin
  ItemIndex := -1;
  if DoEditing then
    ClearEditValue;
  InternalPostEditValue;
end;

procedure TcxCustomColorComboBox.PrepareColorList(
  APrepareList: TcxColorPrepareList; ASaveCustom, ASaveMRU: Boolean);
var
  FBeforeLoadColor: TColor;
  FNewIndex: Integer;
begin
  FBeforeLoadColor := ColorValue;

  ActiveProperties.FOnLoadColorList := nil;
  ActiveProperties.PrepareColorList(APrepareList, ASaveCustom, ASaveMRU);
  ActiveProperties.FOnLoadColorList := PropertiesLoadColorListHandler;
  FNewIndex := ActiveProperties.Items.GetIndexByColor(FBeforeLoadColor);
  if FNewIndex = -1 then
    FlushEditValue
  else
  begin
    FEditValue := FBeforeLoadColor;
    InternalSetEditValue(FBeforeLoadColor, False);
  end;
end;

procedure TcxCustomColorComboBox.PrepareDelphiColorList(
  const ASaveCustom, ASaveMRU: Boolean);
begin
  PrepareColorList(cxplDelphi, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBox.PrepareHTML4ColorList(const ASaveCustom,
  ASaveMRU: Boolean);
begin
  PrepareColorList(cxplHTML4, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBox.PrepareX11ColorList(const ASaveCustom,
  ASaveMRU: Boolean);
begin
  PrepareColorList(cxplX11, ASaveCustom, ASaveMRU);
end;

procedure TcxCustomColorComboBox.PrepareX11OrderedColorList(const ASaveCustom,
  ASaveMRU: Boolean);
begin
  PrepareColorList(cxplX11Ordered, ASaveCustom, ASaveMRU);
end;

{ TcxColorComboBox }

class function TcxColorComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxColorComboBoxProperties;
end;

function TcxColorComboBox.GetActiveProperties: TcxColorComboBoxProperties;
begin
  Result := TcxColorComboBoxProperties(InternalGetActiveProperties);
end;

function TcxColorComboBox.GetProperties: TcxColorComboBoxProperties;
begin
  Result := TcxColorComboBoxProperties(FProperties);
end;

procedure TcxColorComboBox.SetProperties(Value: TcxColorComboBoxProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterColorComboBoxHelper }

class function TcxFilterColorComboBoxHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxColorComboBox;
end;

class function TcxFilterColorComboBoxHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties; AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then
    Result := Result + [fcoInList, fcoNotInList];
end;

class procedure TcxFilterColorComboBoxHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  TcxCustomColorComboBoxProperties(AProperties).DropDownListStyle := lsFixedList;
end;

initialization
  GetRegisteredEditProperties.Register(TcxColorComboBoxProperties,
    scxSEditRepositoryColorComboBoxItem);
  FilterEditsController.Register(TcxColorComboBoxProperties,
    TcxFilterColorComboBoxHelper);

finalization
  FilterEditsController.Unregister(TcxColorComboBoxProperties,
    TcxFilterColorComboBoxHelper);
  GetRegisteredEditProperties.Unregister(TcxColorComboBoxProperties);

end.
