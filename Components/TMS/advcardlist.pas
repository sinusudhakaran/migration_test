{***************************************************************************}
{ TAdvCardList component                                                    }
{ for Delphi & C++Builder                                                   }
{ version 1.2                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2005 - 2007                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

{$I TMSDEFS.INC}

{$T-}

unit AdvCardList;

interface                                         

uses
  Classes, Controls, StdCtrls, ExtCtrls, ComCtrls, Windows, SysUtils, ExtDlgs,
  Dialogs, Math, Messages, Forms, Graphics, Buttons, Mask, ShellAPI
  {$IFDEF DELPHI6_LVL}
  , Variants
  {$ENDIF}
  {$IFDEF DELPHI7_LVL}
  , Themes
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 2; // Release nr.
  BLD_VER = 1; // Build nr.

  // version history
  // v1.0.2.0 : fixed issue with display condition handling
  // v1.0.2.1 : fixed issue with ItemList assign
  // v1.0.3.0 : improved handling of CancelEditing
  //          : change in sequence of code for OnCanEditCell to allow dynamic template changes
  //          : GotoSelectedAutomatic property added
  //          : Delayed card loading added
  //          : OnCardEdnEdit called when picture has been edited
  //          : Improved image drawing in isStretchedProp mode
  //          : Improved combo & datepicker edit control positioning
  // v1.1.0.0 : New: custom inplace editor interface
  //          : New: DirectEdit mode
  //          : New: Image support for card caption
  //          : New: OnCardRightClick event added
  //          : New: OnCardItemRightClick event added
  // v1.1.0.1 : Fixed: issue with multiselect
  //          : New: Ctrl-A to select all added
  // v1.1.0.2 : Fixed: double triggered MouseDown code on dbl-click
  // v1.1.0.3 : Fixed: issue with OnCardDblClick in TDBAdvCardList
  // v1.2.0.0 : New Style interface added
  //          : New Office 2007 Luna & Obsidian style added
  // v1.2.1.0 : New event OnCardUpdate added in TDBAdvCardList
  // v1.2.2.0 : New suppor for Office 2007 silver style added
  // v1.2.2.1 : Fixed : issue with default item show conditions 


resourcestring
  SResInvalidItemName = '''''%s'''' is not a valid item name';
  SResInvalidOperation = '''''%s'''' operation is not allowed';
  SResInvalidEditor = 'Can not assign %s editor for %s data type';
  SResDefAlphabet = 'abcdefghijklmnopqrstuvwxyz';
  SResDesignNoItemCaption = '[Item caption]';
  SResDesignNoItemDefValue = '[Item value]';
  SResTrue = 'True';
  SResFalse = 'False';

{$R AdvCardList.res}

type
  ECardTemplateError = class(Exception);
  ECardItemListError = class(Exception);

  { forward declarations }

  TAdvCardTemplateItem = class;
  TAdvCardTemplate = class;
  TAdvCard = class;
  TAdvCards = class;
  TCustomAdvCardList = class;
  TAdvCardList = class;

  { TAdvGradient }

  TAdvGradientDirection = (gdHorizontal, gdVertical);

  TAdvGradient = class(TPersistent)
  private
    FColor: TColor;
    FColorTo: TColor;
    FDirection: TAdvGradientDirection;
    FOnGradientChange: TNotifyEvent;
    procedure SetColor(Value: TColor);
    procedure SetColorTo(Value: TColor);
    procedure SetDirection(Value: TAdvGradientDirection);
    procedure DoGradientChange;
  protected
    property OnGradientChange: TNotifyEvent read FOnGradientChange write FOnGradientChange;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Draw(Canvas: TCanvas; const Rect: TRect); virtual;
  published
    property Color: TColor read FColor write SetColor default clWindow; // if clNone use clear brush
    property ColorTo: TColor read FColorTo write SetColorTo default clNone; // if clNone use solid Color
    property Direction: TAdvGradientDirection read FDirection write SetDirection default gdHorizontal;
  end;

  { TCardListEditLink }

  TCardListEditLink = class(TComponent)
  private
    FOnKeyDown: TKeyEvent;
  protected
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    function CreateControl: TWinControl; virtual; abstract;
    procedure SetProperties; virtual; abstract;
    procedure SetSelection(SelStart, SelLength: integer); virtual; abstract;
    procedure SetFocus; virtual; abstract;
    procedure ValueToControl(value: variant); virtual; abstract;
    function ControlToValue: variant; virtual; abstract;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
  end;

  { TAdvCardAppearance }

  TOnAppearanceChange = procedure(Sender: TObject; EnabledChanged: Boolean) of object;

  TAdvCardAppearance = class(TPersistent)
  private
    FUpdate: Boolean;
    FBevelInner: TBevelCut;
    FBevelOuter: TBevelCut;
    FBevelWidth: Integer;
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FMergedBorderWidth: Integer;
    FCaptionColor: TAdvGradient;
    FCaptionBorderColor: TColor;
    FCaptionBorderWidth: Integer;
    FCaptionFont: TFont;
    FColor: TAdvGradient;
    FEnabled: Boolean;
    FItemLabelFont: TFont;
    FItemEditFont: TFont;
    FReplaceLabelFont: Boolean;
    FReplaceEditFont: Boolean;
    FOnAppearanceChange: TOnAppearanceChange;
    procedure RecalcMergedBorder;
    procedure DoAppearanceChange(EnabledChanged: Boolean);
    procedure HandleFontChanges(Sender: TObject);
    procedure HandleGradientChanges(Sender: TObject);
    procedure SetBevelInner(Value: TBevelCut);
    procedure SetBevelOuter(Value: TBevelCut);
    procedure SetBevelWidth(Value: Integer);
    procedure SetBorderColor(Value: TColor);
    procedure SetBorderWidth(Value: Integer);
    procedure SetCaptionColor(Value: TAdvGradient);
    procedure SetCaptionBorderColor(Value: TColor);
    procedure SetCaptionBorderWidth(Value: Integer);
    procedure SetCaptionFont(Value: TFont);
    procedure SetColor(Value: TAdvGradient);
    procedure SetEnabled(Value: Boolean);
    procedure SetItemLabelFont(Value: TFont);
    procedure SetItemEditFont(Value: TFont);
    procedure SetReplaceLabelFont(Value: Boolean);
    procedure SetReplaceEditFont(Value: Boolean);
  protected
    property OnAppearanceChange: TOnAppearanceChange read FOnAppearanceChange write FOnAppearanceChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property MergedBorderWidth: Integer read FMergedBorderWidth;
  published
    property BevelInner: TBevelCut read FBevelInner write SetBevelInner default bvNone; // for panel-like appearance
    property BevelOuter: TBevelCut read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelWidth: Integer read FBevelWidth write SetBevelWidth default 1;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clNone;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property CaptionColor: TAdvGradient read FCaptionColor write SetCaptionColor;
    property CaptionBorderColor: TColor read FCaptionBorderColor write SetCaptionBorderColor default clNone;
    property CaptionBorderWidth: Integer read FCaptionBorderWidth write SetCaptionBorderWidth default 1;
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
    property Color: TAdvGradient read FColor write SetColor;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property ItemLabelFont: TFont read FItemLabelFont write SetItemLabelFont; // used for replacing all item label fonts in this appearance
    property ItemEditFont: TFont read FItemEditFont write SetItemEditFont; // used for replacing all item edit fonts in this appearance
    property ReplaceLabelFont: Boolean read FReplaceLabelFont write SetReplaceLabelFont default False; // if checked ItemLabelFont used for all items
    property ReplaceEditFont: Boolean read FReplaceEditFont write SetReplaceEditFont default False; // if checked ItemEditFont used for all items
  end;

  { TAdvCardTemplateItem }

  TAdvCardItemType = (itLabeledItem, itItem, itLabel);

  TItemAlignment = TAlignment;
  TItemLayout = TTextLayout;

  TAdvCardItemEditor = (ieText, ieNumber, ieFloat, ieBoolean, ieDropDownList,
    ieDropDownEdit, ieDate, ieTime, iePictureDialog, ieCustom);

  TAdvCardItemDataType = (idtString, idtFloat, idtInteger, idtBoolean, idtDate,
    idtTime, idtImage);

  TAdvCardItemURLType = (utNone, utLink, utHTTP, utHTTPS, utFTP, utMailto, utNNTP);

  TAdvCardBooleanHideCondition = (bhcAlwaysShow, bhcTrue, bhcFalse, bhcCustom);
  TAdvCardDateHideCondition = (dhcAlwaysShow, dhcNullDate, dhcNotNullDate, dhcCustom);
  TAdvCardFloatHideCondition = (fhcAlwaysShow, fhcNull, fhcNotNull, fhcCustom);
  TAdvCardIntegerHideCondition = (ihcAlwaysShow, ihcNull, ihcNotNull, ihcCustom);
  TAdvCardPictureHideCondition = (phcAlwaysShow, phcEmpty, phcNotEmpty, phcCustom);
  TAdvCardStringHideCondition = (shcAlwaysShow, shcEmpty, shcNotEmpty, shcCustom);

  TAdvCardImageSize = (isOriginal, isStretched, isStretchedProp);

  TAdvCardTemplateItem = class(TCollectionItem)
  private
    FUpdate: Boolean;
    FAutoSize: Boolean;
    FCaption: string;
    FCaptionAlignment: TItemAlignment;
    FCaptionColor: TColor;
    FCaptionFont: TFont;
    FCaptionLayout: TItemLayout;
    FCustomDraw: Boolean;
    FDataType: TAdvCardItemDataType;
    FDefaultValue: string;
    FImageSize: TAdvCardImageSize;
    FFormat: string;
    FValueAlignment: TItemAlignment;
    FValueColor: TColor;
    FValueFont: TFont;
    FValueLayout: TItemLayout;
    FEditColor: TColor;
    FHeight: Integer;
    FHideBooleanCondition: TAdvCardBooleanHideCondition;
    FHideDateCondition: TAdvCardDateHideCondition;
    FHideFloatCondition: TAdvCardFloatHideCondition;
    FHideIntegerCondition: TAdvCardIntegerHideCondition;
    FHidePictureCondition: TAdvCardPictureHideCondition;
    FHideStringCondition: TAdvCardStringHideCondition;
    FItemEditor: TAdvCardItemEditor;
    FItemType: TAdvCardItemType;
    FList: TStringList;
    FMask: string;
    FMaxHeight: Integer;
    FName: string;
    FPrefix: string;
    FReadOnly: Boolean;
    FShowHint: Boolean;
    FSuffix: string;
    FTag: Integer;
    FVisible: Boolean;
    FWordWrap: Boolean;
    FDirectEdit: Boolean;
    FTransparentImage: Boolean;
    FItemEditLink: TCardListEditLink;
    FOnTemplateItemChange: TNotifyEvent;
    FOnTemplateItemListChange: TNotifyEvent;
    FValueURLType: TAdvCardItemURLType;
    procedure CheckEditorType(Data: TAdvCardItemDataType;
      Editor: TAdvCardItemEditor);
    procedure DoTemplateItemChange;
    procedure DoTemplateItemDefValChange;
    procedure DoTemplateItemHideCondChange;
    procedure DoTemplateItemListChange;
    procedure DoTemplateItemLinkedPropChange(OldName: string);
    procedure HandleChildChange(Sender: TObject);
    procedure HandleListChange(Sender: TObject);
    // property methods
    procedure SetAutoSize(Value: Boolean);
    procedure SetCaption(Value: string);
    procedure SetCaptionAlignment(Value: TItemAlignment);
    procedure SetCaptionColor(Value: TColor);
    procedure SetCaptionLayout(Value: TItemLayout);
    procedure SetCustomDraw(Value: Boolean);
    procedure SetDataType(Value: TAdvCardItemDataType);
    procedure SetDefaultValue(Value: string);
    procedure SetImageSize(Value: TAdvCardImageSize);
    procedure SetFormat(Value: string);
    procedure SetValueAlignment(Value: TItemAlignment);
    procedure SetValueColor(Value: TColor);
    procedure SetValueLayout(Value: TItemLayout);
    procedure SetEditColor(Value: TColor);
    procedure SetHeight(Value: Integer);
    procedure SetHideBooleanCondition(Value: TAdvCardBooleanHideCondition);
    procedure SetHideDateCondition(Value: TAdvCardDateHideCondition);
    procedure SetHideFloatCondition(Value: TAdvCardFloatHideCondition);
    procedure SetHideIntegerCondition(Value: TAdvCardIntegerHideCondition);
    procedure SetHidePictureCondition(Value: TAdvCardPictureHideCondition);
    procedure SetHideStringCondition(Value: TAdvCardStringHideCondition);
    procedure SetItemEditor(Value: TAdvCardItemEditor);
    procedure SetItemType(Value: TAdvCardItemType);
    procedure SetList(Value: TStringList);
    procedure SetMask(Value: string);
    procedure SetMaxHeight(Value: Integer);
    procedure SetName(Value: string);
    procedure SetPrefix(Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetShowHint(Value: Boolean);
    procedure SetSuffix(Value: string);
    procedure SetVisible(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
    procedure SetCaptionFont(const Value: TFont);
    procedure SetValueFont(const Value: TFont);
    procedure SetValueURLType(const Value: TAdvCardItemURLType);
  protected
    function GetTemplate: TAdvCardTemplate;
    function GetCardList: TCustomAdvCardList;
    function GetDisplayName: string; override;
    procedure SetDisplayName(const Value: string); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignVisuals(Source: TPersistent); virtual;
    property CardList: TCustomAdvCardList read GetCardList;
    property CardTemplate: TAdvCardTemplate read GetTemplate;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize default True; // when true, item is autosizing based on textheight
    property Caption: string read FCaption write SetCaption;
    property CaptionAlignment: TItemAlignment read FCaptionAlignment write SetCaptionAlignment default taLeftJustify;
    property CaptionColor: TColor read FCaptionColor write SetCaptionColor default clNone; // background of caption; clear if clNone
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
    property CaptionLayout: TItemLayout read FCaptionLayout write SetCaptionLayout default tlCenter;
    property CustomDraw: Boolean read FCustomDraw write SetCustomDraw default False;
    property DataType: TAdvCardItemDataType read FDataType write SetDataType default idtString;
    property DefaultValue: string read FDefaultValue write SetDefaultValue; // default value for new card
    property DirectEdit: Boolean read FDirectEdit write FDirectEdit default false;
    property EditColor: TColor read FEditColor write SetEditColor default clWindow; // background of item value in edit mode (for controls)
    property Format: string read FFormat write SetFormat; // floating format string if datatype is a float
    property MaxHeight: Integer read FMaxHeight write SetMaxHeight default 66; // used when AutoSize is True for prevent infinite height growing
    property Height: Integer read FHeight write SetHeight default 22; // used when AutoSize is False
    property HideBooleanCondition: TAdvCardBooleanHideCondition read FHideBooleanCondition write SetHideBooleanCondition default bhcAlwaysShow; // work also if Visible = True
    property HideDateCondition: TAdvCardDateHideCondition read FHideDateCondition write SetHideDateCondition default dhcAlwaysShow;
    property HideFloatCondition: TAdvCardFloatHideCondition read FHideFloatCondition write SetHideFloatCondition default fhcAlwaysShow;
    property HideIntegerCondition: TAdvCardIntegerHideCondition read FHideIntegerCondition write SetHideIntegerCondition default ihcAlwaysShow;
    property HidePictureCondition: TAdvCardPictureHideCondition read FHidePictureCondition write SetHidePictureCondition default phcAlwaysShow;
    property HideStringCondition: TAdvCardStringHideCondition read FHideStringCondition write SetHideStringCondition default shcAlwaysShow;
    property ImageSize: TAdvCardImageSize read FImageSize write SetImageSize default isOriginal;
    property ItemEditLink: TCardListEditLink read FItemEditLink write FItemEditLink;
    property ItemEditor: TAdvCardItemEditor read FItemEditor write SetItemEditor stored True;
    property ItemType: TAdvCardItemType read FItemType write SetItemType default itLabeledItem;
    property List: TStringList read FList write SetList; // for DropDown
    property Mask: string read FMask write SetMask;
    property Name: string read FName write SetName; // Name of the item for object property editor
    property Prefix: string read FPrefix write SetPrefix; // prefix string for display only, on edit will be hided
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property ShowHint: Boolean read FShowHint write SetShowHint default False; // show special item hint
    property Suffix: string read FSuffix write SetSuffix; // suffic string for display only, on edit will be hided
    property Tag: Integer read FTag write FTag;
    property TransparentImage: boolean read FTransparentImage write FTransparentImage default True;
    property ValueAlignment: TItemAlignment read FValueAlignment write SetValueAlignment default taLeftJustify;
    property ValueColor: TColor read FValueColor write SetValueColor default clNone; // background of value; clear if clNone
    property ValueFont: TFont read FValueFont write SetValueFont;
    property ValueLayout: TItemLayout read FValueLayout write SetValueLayout default tlCenter;
    property ValueURLType: TAdvCardItemURLType read FValueURLType write SetValueURLType default utNone;
    property Visible: Boolean read FVisible write SetVisible default True; // for manual hiding of item

    property WordWrap: Boolean read FWordWrap write SetWordWrap default False; // when true, memo text is shown wordwrapped, otherwise with end ellipsis
    { events }
    property OnTemplateItemChange: TNotifyEvent read FOnTemplateItemChange write FOnTemplateItemChange;
    property OnTemplateItemListChange: TNotifyEvent read FOnTemplateItemListChange write FOnTemplateItemListChange;
  end;

  { TAdvCardTemplateItems }

  TAdvCardTemplateItems = class(TOwnedCollection)
  private
    FCardTemplate: TAdvCardTemplate;
    function GetItem(Index: Integer): TAdvCardTemplateItem;
    procedure SetCards(Value: TAdvCards);
    procedure SetItem(Index: Integer; Value: TAdvCardTemplateItem);
  protected
    FCards: TAdvCards;
    procedure SetItemName(AItem: TCollectionItem); override;
    procedure Update(Item: TCollectionItem); override;
    // for messages from TAdvCardTemplateItem
    procedure ItemChanged(Item: TAdvCardTemplateItem);
    procedure ItemHideCondChanged(Item: TAdvCardTemplateItem);
    procedure ItemListChanged(Item: TAdvCardTemplateItem);
    procedure ItemLinkedPropChanged(Item: TAdvCardTemplateItem; OldName: string);
  public
    constructor Create(CardTemplate: TAdvCardTemplate; ItemClass: TCollectionItemClass);
    function Add: TAdvCardTemplateItem;
    procedure Assign(Source: TPersistent); override;
    procedure Delete(Index: Integer);
    function GetItemByName(Name: string): TAdvCardTemplateItem;
    function Insert(Index: Integer): TAdvCardTemplateItem;
    property Cards: TAdvCards read FCards write SetCards;
    property CardTemplate: TAdvCardTemplate read FCardTemplate;
    property Items[Index: Integer]: TAdvCardTemplateItem read GetItem write SetItem; default;
  end;

  { TAdvCardTemplate }

  TCardTemplateItemsClass = class of TAdvCardTemplateItems;

  TTemplateItemEvent = procedure(Sender: TObject; Item: TAdvCardTemplateItem) of object;

  TAdvCardTemplate = class(TPersistent)
  private
    FCardList: TCustomAdvCardList;
    FItems: TAdvCardTemplateItems;
    FDefItems: TAdvCardTemplateItems;
    FDefaultItem: TAdvCardTemplateItem;
    FCardCaptionAlignment: TItemAlignment;
    FCardCaptionHeight: Integer;
    FCardWidth: Integer;
    FHorMargins: Integer;
    FIndent: Integer;
    FItemLabelWidth: Integer;
    FItemLabelRealWidth: Integer;
    FItemSpacing: Integer;
    FItemValueWidth: Integer;
    FVertMargins: Integer;
    FOnTemplateItemAdd: TTemplateItemEvent;
    FOnBeforTemplateItemDelete: TTemplateItemEvent;
    FOnCardTemplateChange: TNotifyEvent;
    procedure AdjustItemLabelWidth;
    procedure AdjustItemValueWidth;
    procedure DoCardTemplateChange;
    // property methods
    procedure SetCardCaptionAlignment(Value: TItemAlignment);
    procedure SetCardCaptionHeight(Value: Integer);
    procedure SetCardWidth(Value: Integer);
    procedure SetHorMargins(Value: Integer);
    procedure SetIndent(Value: Integer);
    procedure SetItemLabelWidth(Value: Integer);
    procedure SetItems(Value: TAdvCardTemplateItems);
    procedure SetItemSpacing(Value: Integer);
    procedure SetItemValueWidth(Value: Integer);
    procedure SetVertMargins(Value: Integer);
    procedure SetDefaultItem(const Value: TAdvCardTemplateItem);
  protected
    // for messages from TAdvCardTemplateItems
    function GetOwner: TPersistent; override;
    procedure BeforTemplateItemDelete(Item: TAdvCardTemplateItem);
    procedure TemplateItemAdd(Item: TAdvCardTemplateItem);
  public
    constructor Create(CardList: TCustomAdvCardList; TemplateItemsClass: TCardTemplateItemsClass;
      ItemClass: TCollectionItemClass);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property CardList: TCustomAdvCardList read FCardList;
    property ItemLabelRealWidth: Integer read FItemLabelRealWidth;
  published
    property CardCaptionAlignment: TItemAlignment read FCardCaptionAlignment write SetCardCaptionAlignment default taLeftJustify;
    property CardCaptionHeight: Integer read FCardCaptionHeight write SetCardCaptionHeight default 22;
    property CardWidth: Integer read FCardWidth write SetCardWidth default 200;
    property DefaultItem: TAdvCardTemplateItem read FDefaultItem write SetDefaultItem;
    property HorMargins: Integer read FHorMargins write SetHorMargins default 10; // left and right margins from border to keep for displaying items (ihm in figure)
    property Indent: Integer read FIndent write SetIndent default 5;
    property ItemLabelWidth: Integer read FItemLabelWidth write SetItemLabelWidth default 100; // if change ItemValueWidth recalculate
    property Items: TAdvCardTemplateItems read FItems write SetItems;
    property ItemSpacing: Integer read FItemSpacing write SetItemSpacing default 5; // spacing between two items
    property ItemValueWidth: Integer read FItemValueWidth write SetItemValueWidth stored False; // if change ItemLabelWidth recalculate
    property VertMargins: Integer read FVertMargins write SetVertMargins default 10; // top and bottom margins from border to keep for displaying items (ivm in figure)
    { events }
    property OnTemplateItemAdd: TTemplateItemEvent read FOnTemplateItemAdd write FOnTemplateItemAdd;
    property OnBeforTemplateItemDelete: TTemplateItemEvent read FOnBeforTemplateItemDelete write FOnBeforTemplateItemDelete;
    property OnCardTemplateChange: TNotifyEvent read FOnCardTemplateChange write FOnCardTemplateChange;
  end;

  { TAdvCardItem }

  TAdvCardItem = class(TCollectionItem)
  private
    FBoolean: Boolean;
    FHided: Boolean;
    FSelected: Boolean;
    FString: string;
    FInteger: Integer;
    FFloat: Double;
    FDate: TDateTime;
    FTime: TDateTime;
    FPicture: TPicture;
    procedure DoChangeValue;
    function GetBoolean: Boolean;
    function GetString: string;
    function GetFloat: Double;
    function GetInteger: Integer;
    function GetDate: TDateTime;
    function GetTime: TDateTime;
    procedure SetBoolean(Value: Boolean);
    procedure SetSelected(Value: Boolean);
    procedure SetString(Value: string);
    procedure SetFloat(Value: Double);
    procedure SetInteger(Value: Integer);
    procedure SetDate(Value: TDateTime);
    procedure SetTime(Value: TDateTime);
    procedure SetPicture(Value: TPicture);
    procedure PictureChange(Sender: TObject);
  protected
    DataType: TAdvCardItemDataType;
    Format: string;
    FName: string;
    FLabelClientRect,
    FLabelCardRect,
    FLabelListRect,
    FValueClientRect,
    FValueCardRect,
    FValueListRect,
    FUnitedListRect: TRect;
  public
    Hint: string; // specific item hint
    Obj: TObject; // to allow assignment of custom objects
    OwnsObject: Boolean; // when true, object is destroyed automatically when item is destroyed
    Tag: Integer;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property AsBoolean: Boolean read GetBoolean write SetBoolean;
    property AsString: string read GetString write SetString;
    property AsFloat: Double read GetFloat write SetFloat;
    property AsInteger: Integer read GetInteger write SetInteger;
    property AsDate: TDateTime read GetDate write SetDate;
    property AsTime: TDateTime read GetTime write SetTime;
    property Picture: TPicture read FPicture write SetPicture;
    property Hided: Boolean read FHided;
    property Name: string read FName;
    property Selected: Boolean read FSelected write SetSelected;
  end;

  { TAdvCardItemList }

  TAdvCardItemList = class(TCollection)
  private
    FCard: TAdvCard;
    function GetItem(Index: Integer): TAdvCardItem;
    procedure SetItem(Index: Integer; Value: TAdvCardItem);
  protected
    AllowListModification: Boolean;
  public
    constructor Create(ItemClass: TCollectionItemClass);
    destructor Destroy; override;
    function Add: TAdvCardItem;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate; override;
    procedure Clear; 
    procedure Delete(Index: Integer);
    procedure EndUpdate; override;
    function Insert(Index: Integer): TAdvCardItem;
    function GetItemByName(Name: string): TAdvCardItem;
    property Items[Index: Integer]: TAdvCardItem read GetItem write SetItem; default;
    property Card: TAdvCard read FCard; // owner card
  end;

  { TAdvCard }

  TAdvCard = class(TCollectionItem)
  private
    FAppearance: TAdvCardAppearance;
    FCaption: string;
    FColumn: Integer;
    FEditing: Boolean;
    FFiltered: Boolean;
    FHint: string;
    FItemList: TAdvCardItemList;
    FMouseOver: Boolean;
    FSelected: Boolean;
    FSelectedItem: Integer;
    FImageIndex: Integer;
    FTag: Integer;
    FVisible: Boolean;
    procedure DoCardChange;
    procedure DoSelectChanged(OldSelected: Integer);
    procedure SetCaption(Value: string);
    procedure SetSelected(Value: Boolean);
    procedure SetSelectedItem(Value: Integer);
    procedure SetVisible(Value: Boolean);
    procedure SetItemList(Value: TAdvCardItemList);
  protected
    FCaptionClientRect,
    FCaptionCardRect,
    FCaptionListRect,
    FClientRect,
    FListRect: TRect;
    FHeight: Integer;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Appearance: TAdvCardAppearance read FAppearance;
    property Caption: string read FCaption write SetCaption;
    property Column: Integer read FColumn;
    property Editing: Boolean read FEditing;
    property Filtered: Boolean read FFiltered;
    property ImageIndex: Integer read FImageIndex write FImageIndex default -1;
    property Selected: Boolean read FSelected write SetSelected;
    property SelectedItem: Integer read FSelectedItem write SetSelectedItem;
    property Hint: string read FHint write FHint; // full card hint
    property ItemList: TAdvCardItemList read FItemList write SetItemList;
    property Tag: Integer read FTag write FTag;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  { TAdvCards }

  TAdvCardEvent = procedure(Sender: TObject; Card: TAdvCard) of object;

  TAdvCardCompareEvent = procedure(Sender: TObject; CardA, CardB: TAdvCard; var res: Integer) of object;

  TAdvCards = class(TCollection)
  private
    FCardList: TCustomAdvCardList;
    FUpdateSelected: Boolean;
    FOnCardAdd: TAdvCardEvent;
    FOnBeforCardDelete: TAdvCardEvent;
    FOnCardChange: TAdvCardEvent;
    procedure ApplyAppearance(Card: TAdvCard);
    function GetItem(Index: Integer): TAdvCard;
    procedure SetItem(Index: Integer; Value: TAdvCard);
    procedure SetUpdateSelected(Value: Boolean);
  protected
    procedure CalcClientRects(Card: TAdvCard);
    procedure CardItemValueChanged(Card: TAdvCard; Item: TAdvCardItem);
    procedure CardTemplateItemOrderCountChanged;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(CardList: TCustomAdvCardList; ItemClass: TCollectionItemClass);
    function CheckItemShow(Card: TAdvCard; ItemIndex: Integer): Boolean;
    function Add: TAdvCard;
    procedure Clear; 
    procedure Delete(Index: Integer);
    function Insert(Index: Integer): TAdvCard;
    // set items equal to template items
    procedure UpdateCardItems(Card: TAdvCard);
    { properties }
    property Items[Index: Integer]: TAdvCard read GetItem write SetItem; default;
    property UpdateSelected: Boolean read FUpdateSelected write SetUpdateSelected;
    { events }
    property OnCardAdd: TAdvCardEvent read FOnCardAdd write FOnCardAdd;
    property OnBeforCardDelete: TAdvCardEvent read FOnBeforCardDelete write FOnBeforCardDelete;
    property OnCardChange: TAdvCardEvent read FOnCardChange write FOnCardChange;
  end;

  { TAdvCardSortSettings }

  TSortDirection = (sdAscending, sdDescending);
  TSortType = (stNone, stCaption, stItem, stCustom);

  TAdvCardSortSettings = class(TPersistent)
  private
    FSortDirection: TSortDirection;
    FSortIndex: Integer;
    FSortType: TSortType;
    FCaseSensitive: Boolean;
    FOnSortChange: TNotifyEvent;
    procedure DoSortSettingChange;
    procedure SetSortDirection(Value: TSortDirection);
    procedure SetSortIndex(Value: Integer);
    procedure SetSortType(const Value: TSortType);
  protected
    property OnSortChange: TNotifyEvent read FOnSortChange write FOnSortChange;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive default False;
    property SortDirection: TSortDirection read FSortDirection write SetSortDirection default sdAscending;
    property SortIndex: Integer read FSortIndex write SetSortIndex default 0; // card item to sort on
    property SortType: TSortType read FSortType write SetSortType default stNone;
  end;

  { TAdvCardFilterSettings }

  TAdvCardFilterSettings = class(TPersistent)
  private
    FFilterCondition: string;
    FFilterIndex: Integer;
    FOnFilterChange: TNotifyEvent;
    procedure DoFilterSettingsChange;
    procedure SetFilterCondition(Value: string);
    procedure SetFilterIndex(Value: Integer);
  protected
    property OnFilterChange: TNotifyEvent read FOnFilterChange write FOnFilterChange;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property FilterCondition: string read FFilterCondition write SetFilterCondition; // simple condition : if pos(filter, carditem[index]) = 1 then allow
    property FilterIndex: Integer read FFilterIndex write SetFilterIndex default 0; // card item to filter on
  end;

  { TAdvCardList }

  TAdvCardItemEvent = procedure(Sender: TObject; CardIndex: Integer; ItemIndex: Integer) of object;
  TAdvCardItemAllowEvent = procedure(Sender: TObject; CardIndex: Integer; ItemIndex: Integer; var Allow: Boolean) of object;
  TAdvCardCaptionGetDisplText = procedure(Sender: TObject; CardIndex: Integer; var Text: string) of object;
  TAdvCardItemGetDisplText = procedure(Sender: TObject; CardIndex, ItemIndex: Integer; var Text: string) of object;
  TAdvCardDrawCardItem = procedure(Sender: TObject; Card: TAdvCard; Item: TAdvCardItem; Canvas: TCanvas; Rect: TRect) of object;
  TAdvCardDrawCardItemProp = procedure(Sender: TObject; Card: TAdvCard; Item: TAdvCardItem; AFont: TFont; ABrush: TBrush) of object;
  TAdvCardColumnResizing = procedure(Sender: TObject; var NewSize: Integer) of object;
  TAdvCardDelayedLoad = procedure(Sender : TObject; Card: TAdvCard) of object;

  TAdvCardItemURLEvent = procedure(Sender: TObject; CardIndex: Integer; ItemIndex: Integer; URL: string; var Default: boolean) of object;

  TSortedCards = array of Integer;
  TFilteredCards = array of Integer;
  TInClientAreaCards = array of Integer;

  TCalcListRectsResult = (clrSkipped, clrFollowed, clrNextColumn);
  TControlType = (ctEdit, ctMemo, ctMaskEdit, ctCheckBox, ctComboBox, ctDateTimePicker,
    ctOpenPictureDialog, ctCustom);
  TDataChangedObject = (dcoCaption, dcoItem);

  TCustomAdvCardList = class(TCustomControl)
  private
    FScrolling : Boolean;
    // for editing and displaying
    FEdControl: TControl;
    FEdControlType: TControlType;
    FEdCardIndex: Integer;
    FEdItemIndex: Integer;
    FEdByMouse: Boolean;
    FDspBMPUnchecked: TBitmap;
    FDspBMPChecked: TBitmap;
    FOpenPictDialog: TOpenPictureDialog;
    FHoverCardIndex: Integer;
    FOverItemIndex: Integer;
    FViewedColumns: Integer;
    FSortedCards: TSortedCards;
    FInClientAreaCards: TInClientAreaCards;
    FCanvasLeft: Integer;
    FCanvasRight: Integer;
    FUpdateCount: Integer;
    FocusPen: HPEN;
    OldPen: TPen;
    FocusPenBrush: tagLOGBRUSH;
    // for column resizing
    FGridLineDragging: Boolean;
    FCursorOverGridLine: Boolean;
    FPressedAtX: Integer;
    FOldColumnWidth: Integer;
    FResizingColumn: Integer;
    FOldLeftTopCard: Integer;
    FSilentMouseMove: Boolean;
    // properties
    FAutoEdit: Boolean;
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FCardNormalAppearance: TAdvCardAppearance;
    FCardHoverAppearance: TAdvCardAppearance;
    FCards: TAdvCards;
    FCardSelectedAppearance: TAdvCardAppearance;
    FCardEditingAppearance: TAdvCardAppearance;
    FCardHorSpacing: Integer;
    FCardVertSpacing: Integer;
    FCheckBoxSize: Integer;
    FColor: TAdvGradient;
    FColumns: Integer;
    FColumnSizing: Boolean;
    FColumnWidth: Integer;
    FFiltered: Boolean;
    FFilterSettings: TAdvCardFilterSettings;
    FFocusColor: TColor;
    FGridLineColor: TColor;
    FGridLineWidth: Integer;
    FLeftCol: Integer;
    FMaxColumnWidth: Integer;
    FMinColumnWidth: Integer;
    FMultiSelect: Boolean;
    FPageCount: Integer;
    FReadOnly: Boolean;
    FSelectedCard: TAdvCard;
    FSelectedCount: Integer;
    FSelectedIndex: Integer;
    FShowGridLine: Boolean;
    FShowFocus: Boolean;
    FShowScrollBar: Boolean;
    FSorted: Boolean;
    FEditMode: Boolean;
    FImages: TImageList;
    FDblClick: boolean;

    FSortSettings: TAdvCardSortSettings;
    FGotoSelectedAutomatic: Boolean;
    FDelayedCardLoad: Boolean;
    DelayedCardLoadTimer : TTimer;
    { events }
    FOnCardStartEdit: TAdvCardItemAllowEvent; // StartEdit
    FOnCardEndEdit: TAdvCardItemEvent; // DoneEdit
    FOnCardCaptionGetDisplText: TAdvCardCaptionGetDisplText; // DrawCard
    FOnCardItemGetDisplText: TAdvCardItemGetDisplText; // DrawItemValue| allows virtual text or dynamic text modifications
    FOnCardCaptionClick: TAdvCardEvent; // Click
    FOnCardCaptionDblClick: TAdvCardEvent; // DblClick
    FOnCardClick: TAdvCardEvent; // Click
    FOnCardRightClick: TAdvCardEvent; 
    FOnCardCompare: TAdvCardCompareEvent; // Sort compare
    FOnCardDblClick: TAdvCardEvent; // DblClick
    FOnCardItemClick: TAdvCardItemEvent; // Click
    FOnCardItemRightClick: TAdvCardItemEvent;
    FOnColumnResizing: TAdvCardColumnResizing; // SetColumnWidth
    FOnDrawCardItem: TAdvCardDrawCardItem; // DrawCard| custom draw event
    FOnDrawCardItemProp: TAdvCardDrawCardItemProp; // DrawItemValue| queries draw properties
    FOnShowCardItem: TAdvCardItemAllowEvent;
    FOnCardItemURLClick: TAdvCardItemURLEvent;
    FOnDelayedCardLoad : TAdvCardDelayedLoad;
    FURLColor: TColor; // Cards.CheckItemShow
    function AddToClientAreaCards(Card: TAdvCard; FirstTime: Boolean): Boolean;
    procedure ConvertTypeAndDoneEdit;
    procedure ConvertTypeAndStartEdit(EditRect: TRect; CardIndex, ItemIndex: Integer; StartChar: Char);
    procedure CreateDesignCards;
    procedure ReCreateFocusPen;
    procedure DoCardListChange;
    procedure HandleControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HandleScrBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    function IsInClientArea(const Rect: TRect): Boolean;
    // property methods
    function GetCheckBoxRect(ValueListRect: TRect; Align: TItemAlignment; Layout: TItemLayout): TRect;
    function GetEditing: Boolean;
    function GetDelayedCardLoadTimerInterval: Integer;
    procedure SetDelayedCardLoadTimerInterval(Value: Integer);
    procedure SetMouseOverCard(CardIndex: Integer);
    procedure SetBorderColor(Value: TColor);
    procedure SetBorderWidth(Value: Integer);
    procedure SetCardNormalAppearance(Value: TAdvCardAppearance);
    procedure SetCardHoverAppearance(Value: TAdvCardAppearance);
    procedure SetCardSelectedAppearance(Value: TAdvCardAppearance);
    procedure SetCardEditingAppearance(Value: TAdvCardAppearance);
    procedure SetCardHorSpacing(Value: Integer);
    procedure SetCardTemplate(Value: TAdvCardTemplate);
    procedure SetCardVertSpacing(Value: Integer);
    procedure SetColor(Value: TAdvGradient);
    procedure SetColumnSizing(Value: Boolean);
    procedure SetColumnWidth(Value: Integer);
    procedure SetFiltered(Value: Boolean);
    procedure SetFilterSettings(Value: TAdvCardFilterSettings);
    procedure SetFocusColor(Value: TColor);
    procedure SetGridLineColor(Value: TColor);
    procedure SetGridLineWidth(Value: Integer);
    procedure SetLeftCol(Value: Integer);
    procedure SetMaxColumnWidth(Value: Integer);
    procedure SetMinColumnWidth(Value: Integer);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetPageCount(Value: Integer);
    procedure SetReadOnly(Value: Boolean);
    procedure SetSelectedIndex(Value: Integer);
    procedure SetShowGridLine(Value: Boolean);
    procedure SetShowFocus(Value: Boolean);
    procedure SetShowScrollBar(Value: Boolean);
    procedure SetSorted(Value: Boolean);
    procedure SetSortSettings(Value: TAdvCardSortSettings);
    procedure SetDelayedCardLoad(Value: Boolean);
    procedure DelayedCardLoadTimerOnTimer(Sender: TObject);
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetURLColor(const Value: TColor);
  protected
    FCardTemplate: TAdvCardTemplate;
    ScrollBar: TScrollBar;
    procedure LocateByChar(Key: Char); virtual;
    function JumpToCard(Offset: Integer; ToBegin, ToEnd: Boolean): Boolean; virtual;
    function JumpToItem(Offset: Integer; ToBegin, ToEnd: Boolean): Boolean; virtual;
    procedure UpdateScrollBar; virtual;
    procedure OnScroll(var ScrollPos: Integer; ScrollCode: TScrollCode); virtual;
    procedure CreateTemplate(Cards: TAdvCards); virtual;
    function CalcListRects(Card, AfterCard: TAdvCard; DoCheckScroll: Boolean): TCalcListRectsResult;
    procedure DataChanged(Card: TAdvCard; Item: TAdvCardItem; DataObject: TDataChangedObject); virtual;
    procedure SelectedChanged; virtual;
    procedure ColumnSized; virtual;
    procedure ShiftListRects(Value: Integer);
    function InValueRect(X: Integer; ACard: TAdvCard; ATemplate: TAdvCardTemplateItem; AItem: TAdvCardItem): boolean;
    procedure Click; override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;    
    procedure DrawItemCaption(Canvas: TCanvas; Card: TAdvCard; ItemIndex: Integer; Preview: Boolean); virtual;
    procedure DrawItemValue(Canvas: TCanvas; Card: TAdvCard; ItemIndex: Integer; Preview: Boolean); virtual;
    procedure DrawCard(Canvas: TCanvas; Card: TAdvCard; Preview: Boolean); virtual;
    procedure DoFilter(Filtered: Boolean); virtual;
    procedure UpdateCards(AClientRects, AListRects, ASort, AFilter: Boolean);
    procedure Paint; override;
    procedure PaintCard(CardIndex: Integer);
    procedure Resize; override;
    procedure DoSort(Sorted: Boolean); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    // for messages from TAdvCardAppearance
    procedure HandleAppearanceChange(Sender: TObject; EnabledChanged: Boolean);
    // for message from TAdvGradient
    procedure HandleColorChange(Sender: TObject);
    // for messages from TAdvCardTemplate
    procedure CardTemplateChanged; // global properties of CardTemplate
    procedure CardTemplateItemChanged(Item: TAdvCardTemplateItem);
    procedure CardTemplateItemHideCondChanged(Item: TAdvCardTemplateItem);
    procedure DefaultValueChanged(TItem: TAdvCardTemplateItem);
    // for messages from TAdvCards
    procedure CardChanged(Card: TAdvCard);
    procedure CardOrderCountChanged;
    // for message from TAdvCardSortSettings
    procedure HandleSortSettingsChange(Sender: TObject);
    // for message from TAdvCardFilterSettings
    procedure HandleFilterSettingsChange(Sender: TObject);
    //
    function GetVersionNr: Integer; virtual;
    procedure Filter;
    procedure Sort;
  public
    { properties }
    property CanvasRight: Integer read FCanvasRight;
    property Columns: Integer read FColumns; // nr. of columns; read only
    property Cards: TAdvCards read FCards;
    property LeftCol: Integer read FLeftCol write SetLeftCol; // sets the left column index in a scrolled cardlist (0..ColumnCount-1)
    property AutoEdit: Boolean read FAutoEdit write FAutoEdit default True;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clActiveBorder; // without border if clNone
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property CardEditingAppearance: TAdvCardAppearance read FCardEditingAppearance write SetCardEditingAppearance;
    property CardNormalAppearance: TAdvCardAppearance read FCardNormalAppearance write SetCardNormalAppearance;
    property CardSelectedAppearance: TAdvCardAppearance read FCardSelectedAppearance write SetCardSelectedAppearance;
    property CardHoverAppearance: TAdvCardAppearance read FCardHoverAppearance write SetCardHoverAppearance;
    property CardHorSpacing: Integer read FCardHorSpacing write SetCardHorSpacing default 20;
    property CardVertSpacing: Integer read FCardVertSpacing write SetCardVertSpacing default 20;
    property Color: TAdvGradient read FColor write SetColor; // background card list color
    property ColumnSizing: Boolean read FColumnSizing write SetColumnSizing default True; // ability to resize column width in realtime (if ShowGridLine = True)
    property ColumnWidth: Integer read FColumnWidth write SetColumnWidth default 240; // if changed card width recalculate and vice versa if card width changed then column width recalculate
    property DelayedCardLoad: Boolean read FDelayedCardLoad write SetDelayedCardLoad;
    property DelayedCardLoadInterval: Integer read GetDelayedCardLoadTimerInterval write SetDelayedCardLoadTimerInterval;
    property Filtered: Boolean read FFiltered write SetFiltered default False;
    property FilterSettings: TAdvCardFilterSettings read FFilterSettings write SetFilterSettings;
    property FocusColor: TColor read FFocusColor write SetFocusColor default clGray;
    property GotoSelectedAutomatic: Boolean read FGotoSelectedAutomatic write FGotoSelectedAutomatic default true;
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor default clBtnFace; // line between columns
    property GridLineWidth: Integer read FGridLineWidth write SetGridLineWidth default 3; // line between columns
    property Images: TImageList read FImages write FImages;
    property MaxColumnWidth: Integer read FMaxColumnWidth write SetMaxColumnWidth default 0;
    property MinColumnWidth: Integer read FMinColumnWidth write SetMinColumnWidth default 150;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False; // allow ctrl-click multi card selection
    property PageCount: Integer read FPageCount write SetPageCount default 4;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property ShowGridLine: Boolean read FShowGridLine write SetShowGridLine default True; // if False realtime resizing is prohibited
    property ShowFocus: Boolean read FShowFocus write SetShowFocus default True;
    property ShowScrollBar: Boolean read FShowScrollBar write SetShowScrollBar default True; // show scrollbar or not
    property Sorted: Boolean read FSorted write SetSorted default True;
    property SortSettings: TAdvCardSortSettings read FSortSettings write SetSortSettings;
    property URLColor: TColor read FURLColor write SetURLColor default clBlue;
    property Version: string read GetVersion write SetVersion;
    { events }
    property OnDelayedCardLoad: TAdvCardDelayedLoad read FOnDelayedCardLoad write FOnDelayedCardLoad;
    property OnCardStartEdit: TAdvCardItemAllowEvent read FOnCardStartEdit write FOnCardStartEdit;
    property OnCardEndEdit: TAdvCardItemEvent read FOnCardEndEdit write FOnCardEndEdit;
    property OnCardCaptionGetDisplText: TAdvCardCaptionGetDisplText read FOnCardCaptionGetDisplText write FOnCardCaptionGetDisplText;
    property OnCardItemGetDisplText: TAdvCardItemGetDisplText read FOnCardItemGetDisplText write FOnCardItemGetDisplText; // allows virtual text or dynamic text modifications
    property OnCardCaptionClick: TAdvCardEvent read FOnCardCaptionClick write FOnCardCaptionClick;
    property OnCardCaptionDblClick: TAdvCardEvent read FOnCardCaptionDblClick write FOnCardCaptionDblClick;
    property OnCardClick: TAdvCardEvent read FOnCardClick write FOnCardClick;
    property OnCardRightClick: TAdvCardEvent read FOnCardRightClick write FOnCardRightClick;
    property OnCardCompare: TAdvCardCompareEvent read FOnCardCompare write FOnCardCompare;
    property OnCardDblClick: TAdvCardEvent read FOnCardDblClick write FOnCardDblClick;
    property OnCardItemClick: TAdvCardItemEvent read FOnCardItemClick write FOnCardItemClick;
    property OnCardItemRightClick: TAdvCardItemEvent read FOnCardItemRightClick write FOnCardItemRightClick;
    property OnCardItemURLClick: TAdvCardItemURLEvent read FOnCardItemURLClick write FOnCardItemURLClick;
    property OnColumnResizing: TAdvCardColumnResizing read FOnColumnResizing write FOnColumnResizing;
    property OnDrawCardItem: TAdvCardDrawCardItem read FOnDrawCardItem write FOnDrawCardItem; // custom draw event
    property OnDrawCardItemProp: TAdvCardDrawCardItemProp read FOnDrawCardItemProp write FOnDrawCardItemProp; // queries draw properties
    property OnShowCardItem: TAdvCardItemAllowEvent read FOnShowCardItem write FOnShowCardItem;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function CardAtXY(x, y: Integer; OnlyViewed: Boolean): TAdvCard;
    property CardTemplate: TAdvCardTemplate read FCardTemplate write SetCardTemplate; // template of cards    
    function ItemAtXY(x, y: Integer; Card: TAdvCard): Integer;
    procedure DeSelectAll;
    procedure SelectAll;
    procedure SelectCard(CardIndex: Integer; Select: Boolean);
    function FindCard(BeginWith: string): TAdvCard; virtual;
    function IsCardCurrentlyDisplayed(Card: TAdvCard):Boolean;
    function GoToSelected: Boolean;
    // method called when custom editing should start
    procedure StartEdit(EditRect: TRect; CardIndex, ItemIndex: Integer; Value: Variant; StartChar: Char);
    // cancel edit mode without result saving
    procedure CancelEditing;
    // method called by custom editor to update after editing ends. Do call cancel editing and store result.
    procedure DoneEdit(Value: Variant);
    function VisibleCardCount: Integer;
    property VisibleColumns: Integer read FViewedColumns;
    property Editing: Boolean read GetEditing;
    property SelectedCard: TAdvCard read FSelectedCard;
    property SelectedCount: Integer read FSelectedCount;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex;
  end;

  { TAdvCardList }

  TAdvCardList = class(TCustomAdvCardList)
  public
    property Columns;
    property Cards;
    property LeftCol;
  published
    property Align;
    property Anchors;
    property Enabled;
    property TabOrder;
    property TabStop;
    property HelpContext;
    property DragKind;
    property DragCursor;
    property DragMode;
    property BiDiMode;
    property Constraints;
    property DockOrientation;
    property ShowHint;
    property Visible;
    property Left;
    property Top;
    property Width;
    property Height;
    property Cursor;
    property Hint;
    property PopupMenu;
    { TCustomAdvCardList }
    property AutoEdit;
    property BorderColor;
    property BorderWidth;
    property CardEditingAppearance;
    property CardNormalAppearance;
    property CardSelectedAppearance;
    property CardHoverAppearance;
    property CardHorSpacing;
    property CardTemplate;
    property CardVertSpacing;
    property Color;
    property ColumnSizing;
    property ColumnWidth;
    property DelayedCardLoad;
    property DelayedCardLoadInterval;
    property Filtered;
    property FilterSettings;
    property FocusColor;
    property GotoSelectedAutomatic;
    property GridLineColor;
    property GridLineWidth;
    property Images;
    property MaxColumnWidth;
    property MinColumnWidth;
    property MultiSelect;
    property PageCount;
    property ReadOnly;
    property ShowGridLine;
    property ShowFocus;
    property ShowScrollBar;
    property Sorted;
    property SortSettings;
    property URLColor;
    property Version;
    { events }
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnDockDrop;
    property OnDockOver;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    { TCustomAdvCardList }
    property OnDelayedCardLoad;
    property OnCardStartEdit;
    property OnCardEndEdit;
    property OnCardCaptionGetDisplText;
    property OnCardItemGetDisplText;
    property OnCardCaptionClick;
    property OnCardCaptionDblClick;
    property OnCardClick;
    property OnCardRightClick;
    property OnCardCompare;
    property OnCardDblClick;
    property OnCardItemClick;
    property OnCardItemRightClick;    
    property OnCardItemURLClick;
    property OnColumnResizing;
    property OnDrawCardItem;
    property OnDrawCardItemProp;
    property OnShowCardItem;
  end;

  { TAdvButton }

  TFontDirection = (fdHorizontal, fdVertical);

  TAdvButton = class(TSpeedButton)
  private
    FFont: HFONT;
    FBorderWidth: Integer;
    FCaption: string;
    FFontDirection: TFontDirection;
    procedure SetBorderWidth(Value: Integer);
    procedure SetCaption(Value: string);
    procedure SetFontDirection(Value: TFontDirection);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    procedure Paint; override;
    procedure ReCreateFont;
  public
    Symbols: string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 3;
    property FontDirection: TFontDirection read FFontDirection write SetFontDirection default fdHorizontal;
    property Caption: string read FCaption write SetCaption;
  end;

  { TAdvButtonsBar }

  TAdvButtonClickEvent = procedure(Sender: TObject; ButtonIndex: Integer; ButtonCaption: string) of object;

  TAdvBarAlignment = (baHorizontal, baVertical);
  TAdvBarButtonDirection = (bdHorizontal, bdVertical);

  TAdvButtonsBar = class(TCustomControl)
  private
    FButtons: array of TAdvButton;
    // properties
    FAlphabet: string;
    FBarAlignment: TAdvBarAlignment;
    FBorderWidth: Integer;
    FButBorderWidth: Integer;
    FButtonDirection: TAdvBarButtonDirection;
    FButtonGap: Integer;
    FButtonSize: Integer;
    FCardList: TCustomAdvCardList;
    FFlat: Boolean;
    FShowNumButton: Boolean;
    FOnButtonClick: TAdvButtonClickEvent;
    procedure SetAlphabet(Value: string);
    procedure SetBarAlignment(Value: TAdvBarAlignment);
    procedure SetBorderWidth(Value: Integer);
    procedure SetButBorderWidth(Value: Integer);
    procedure SetButtonDirection(Value: TAdvBarButtonDirection);
    procedure SetButtonGap(Value: Integer);
    procedure SetButtonSize(Value: Integer);
    procedure SetFlat(Value: Boolean);
    procedure SetShowNumButton(Value: Boolean);
    procedure Adjust;
    procedure HandleButtonClick(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ButtonCount: Integer;
  published
    property Align;
    property Anchors;
    property Color;
    property Font;
    property Enabled;
    property TabOrder;
    property TabStop;
    property HelpContext;
    property Constraints;
    property ShowHint;
    property Visible;
    property Left;
    property Top;
    property Width;
    property Height;
    property Cursor;
    property Hint;
    property PopupMenu;
    property Alphabet: string read FAlphabet write SetAlphabet;
    property BarAlignment: TAdvBarAlignment read FBarAlignment write SetBarAlignment default baVertical; // used to control the alignment of the bar
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 10; // set how wide is the border around the buttons
    property ButBorderWidth: Integer read FButBorderWidth write SetButBorderWidth default 3;
    property ButtonDirection: TAdvBarButtonDirection read FButtonDirection write SetButtonDirection default bdHorizontal;
    property ButtonGap: Integer read FButtonGap write SetButtonGap default 5; // distance between buttons
    property ButtonSize: Integer read FButtonSize write SetButtonSize default 25; // size of the button (height in vert. mode, width in horiz. Mode)
    property CardList: TCustomAdvCardList read FCardList write FCardList; // used to set the TAdvCardList component this buttons bar control
    property Flat: Boolean read FFlat write SetFlat default False;
    property ShowNumButton: Boolean read FShowNumButton write SetShowNumButton default True; // show or hide the "123" button in the first position of the bar
    { events }
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnEnter;
    property OnExit;
    property OnButtonClick: TAdvButtonClickEvent read FOnButtonClick write FOnButtonClick;
  end;

implementation

var
  SDesignNoItemCaption: string;
  SDesignNoItemDefValue: string;
  STrue: string;
  SFalse: string;

{$IFNDEF DELPHI5_LVL}
procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ENDIF}

//------------------//
//   TAdvGradient   //
//------------------//

constructor TAdvGradient.Create;
begin
  inherited;
  FColor := clWindow;
  FColorTo := clNone;
  FDirection := gdHorizontal;
end;

procedure TAdvGradient.Assign(Source: TPersistent);
begin
  if Source is TAdvGradient then
    with TAdvGradient(Source) do
    begin
      Self.FColor := Color;
      Self.FColorTo := ColorTo;
      Self.FDirection := Direction;
      Self.DoGradientChange;
    end else inherited;
end;

function ComposeColors(const Dest, Src: TColor; const Percent: Integer): TColor;
var
  r, g, b: Integer;
begin
  r := GetRValue(Src);
  g := GetGValue(Src);
  b := GetBValue(Src);
  Result := RGB(r + (GetRValue(Dest) - r) * Percent div 256,
    g + (GetGValue(Dest) - g) * Percent div 256,
    b + (GetBValue(Dest) - b) * Percent div 256);
end;

procedure TAdvGradient.Draw(Canvas: TCanvas; const Rect: TRect);
var
  n: Integer;
  RStep: Real;
  IStep, WH: Integer;
  CFrom, CTo: TColor;
begin
  if FColor = clNone then
    Exit
  else
    if FColorTo = clNone then
      with Canvas do
      begin
        Brush.Color := FColor;
        FillRect(Rect);
      end else
      with Canvas do
      begin
        CFrom := ColorToRGB(FColor);
        CTo := ColorToRGB(FColorTo);
        Brush.Style := bsSolid;
        if FDirection = gdHorizontal then
        begin
          WH := Rect.Bottom - Rect.Top;
          RStep := (Rect.Right - Rect.Left) / 256;
          IStep := Round(RStep);
        end else
        begin
          WH := Rect.Right - Rect.Left;
          RStep := (Rect.Bottom - Rect.Top) / 256;
          IStep := Round(RStep);
        end;
        for n := 0 to 254 do
        begin
          Brush.Color := ComposeColors(CTo, CFrom, n);
          if FDirection = gdHorizontal then
          begin
            FillRect(Bounds(Trunc(Rect.Left + n * RStep), Rect.Top,
              IStep + 1, WH));
          end else
          begin
            FillRect(Bounds(Rect.Left, Trunc(Rect.Top + n * RStep),
              WH, IStep + 1));
          end;
        end;
      end;
end;

procedure TAdvGradient.DoGradientChange;
begin
  if Assigned(FOnGradientChange) then FOnGradientChange(Self);
end;

procedure TAdvGradient.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    DoGradientChange;
  end;
end;

procedure TAdvGradient.SetColorTo(Value: TColor);
begin
  if FColorTo <> Value then
  begin
    FColorTo := Value;
    DoGradientChange;
  end;
end;

procedure TAdvGradient.SetDirection(Value: TAdvGradientDirection);
begin
  if FDirection <> Value then
  begin
    FDirection := Value;
    DoGradientChange;
  end;
end;

//------------------------//
//   TAdvCardAppearance   //
//------------------------//

constructor TAdvCardAppearance.Create;
begin
  inherited;
  FUpdate := True;
  FBevelInner := bvNone;
  FBevelOuter := bvRaised;
  FBevelWidth := 1;
  FBorderColor := clNone;
  FBorderWidth := 1;
  FCaptionColor := TAdvGradient.Create;
  FCaptionColor.OnGradientChange := HandleGradientChanges;
  FCaptionBorderColor := clNone;
  FCaptionBorderWidth := 1;
  FCaptionFont := TFont.Create;
  FCaptionFont.OnChange := HandleFontChanges;
  FColor := TAdvGradient.Create;
  FColor.OnGradientChange := HandleGradientChanges;
  FEnabled := True;
  FItemLabelFont := TFont.Create;
  FItemLabelFont.OnChange := HandleFontChanges;
  FItemEditFont := TFont.Create;
  FItemEditFont.OnChange := HandleFontChanges;
  FReplaceLabelFont := False;
  FReplaceEditFont := False;
end;

destructor TAdvCardAppearance.Destroy;
begin
  FreeAndNil(FCaptionColor);
  FreeAndNil(FCaptionFont);
  FreeAndNil(FColor);
  FreeAndNil(FItemLabelFont);
  FreeAndNil(FItemEditFont);
  inherited;
end;

procedure TAdvCardAppearance.Assign(Source: TPersistent);
begin
  if Source is TAdvCardAppearance then
    with TAdvCardAppearance(Source) do
    try
      Self.FUpdate := False;
      Self.FBevelInner := BevelInner;
      Self.FBevelOuter := BevelOuter;
      Self.FBevelWidth := BevelWidth;
      Self.FBorderColor := BorderColor;
      Self.FBorderWidth := BorderWidth;
      Self.FCaptionBorderColor := CaptionBorderColor;
      Self.FCaptionBorderWidth := CaptionBorderWidth;
      Self.FCaptionColor.Assign(CaptionColor);
      Self.FCaptionFont.Assign(CaptionFont);
      Self.FColor.Assign(Color);
      Self.FEnabled := Enabled;
      Self.FItemLabelFont.Assign(ItemLabelFont);
      Self.FItemEditFont.Assign(ItemEditFont);
      Self.FReplaceLabelFont := ReplaceLabelFont;
      Self.FReplaceEditFont := ReplaceEditFont;
    finally
      Self.FUpdate := True;
      Self.DoAppearanceChange(True);
    end else inherited;
end;

procedure TAdvCardAppearance.RecalcMergedBorder;
begin
  FMergedBorderWidth := 0;
  if FBevelInner <> bvNone then Inc(FMergedBorderWidth, FBevelWidth);
  if FBevelOuter <> bvNone then Inc(FMergedBorderWidth, FBevelWidth);
  Inc(FMergedBorderWidth, FBorderWidth);
end;

procedure TAdvCardAppearance.DoAppearanceChange(EnabledChanged: Boolean);
begin
  if FUpdate then
    if Assigned(FOnAppearanceChange) then FOnAppearanceChange(Self, EnabledChanged);
end;

procedure TAdvCardAppearance.HandleFontChanges(Sender: TObject);
begin
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.HandleGradientChanges(Sender: TObject);
begin
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetBevelInner(Value: TBevelCut);
begin
  if Value <> FBevelInner then
  begin
    FBevelInner := Value;
    RecalcMergedBorder;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetBevelOuter(Value: TBevelCut);
begin
  if Value <> FBevelOuter then
  begin
    FBevelOuter := Value;
    RecalcMergedBorder;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetBevelWidth(Value: Integer);
begin
  if Value <> FBevelWidth then
  begin
    FBevelWidth := Value;
    RecalcMergedBorder;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetCaptionColor(Value: TAdvGradient);
begin
  FCaptionColor.Assign(Value);
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetBorderColor(Value: TColor);
begin
  if Value <> FBorderColor then
  begin
    FBorderColor := Value;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetBorderWidth(Value: Integer);
begin
  if Value <> FBorderWidth then
  begin
    FBorderWidth := Value;
    RecalcMergedBorder;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetCaptionBorderColor(Value: TColor);
begin
  if Value <> FCaptionBorderColor then
  begin
    FCaptionBorderColor := Value;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetCaptionBorderWidth(Value: Integer);
begin
  if Value <> FCaptionBorderWidth then
  begin
    FCaptionBorderWidth := Value;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetCaptionFont(Value: TFont);
begin
  FCaptionFont.Assign(Value);
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetColor(Value: TAdvGradient);
begin
  FColor.Assign(Value);
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    DoAppearanceChange(True);
  end;
end;

procedure TAdvCardAppearance.SetItemLabelFont(Value: TFont);
begin
  FItemLabelFont.Assign(Value);
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetItemEditFont(Value: TFont);
begin
  FItemEditFont.Assign(Value);
  DoAppearanceChange(False);
end;

procedure TAdvCardAppearance.SetReplaceLabelFont(Value: Boolean);
begin
  if Value <> FReplaceLabelFont then
  begin
    FReplaceLabelFont := Value;
    DoAppearanceChange(False);
  end;
end;

procedure TAdvCardAppearance.SetReplaceEditFont(Value: Boolean);
begin
  if Value <> FReplaceEditFont then
  begin
    FReplaceEditFont := Value;
    DoAppearanceChange(False);
  end;
end;

//--------------------------//
//   TAdvCardTemplateItem   //
//--------------------------//

constructor TAdvCardTemplateItem.Create(Collection: TCollection);
var
  CardList: TCustomAdvCardList;
  Template: TAdvCardTemplate;
begin
  if Assigned(Collection) then
    Collection.BeginUpdate;

  inherited Create(Collection);
  FUpdate := True;
  FAutoSize := True;
  FCaption := FName;
  FCaptionAlignment := taLeftJustify;
  FCaptionColor := clNone;
  FCaptionLayout := tlCenter;
  FCustomDraw := False;
  FDataType := idtString;
  FDefaultValue := '';
  FImageSize := isOriginal;
  FValueAlignment := taLeftJustify;
  FValueFont := TFont.Create;
  FValueFont.OnChange := HandleChildChange;
  FFormat := '';
  FCaptionFont := TFont.Create;
  FCaptionFont.OnChange := HandleChildChange;
  FValueColor := clNone;
  FValueLayout := tlCenter;
  FEditColor := clWindow;
  FHeight := 22;
  FHideBooleanCondition := bhcAlwaysShow;
  FHideDateCondition := dhcAlwaysShow;
  FHideFloatCondition := fhcAlwaysShow;
  FHideIntegerCondition := ihcAlwaysShow;
  FHidePictureCondition := phcAlwaysShow;
  FHideStringCondition := shcAlwaysShow;
  FItemEditor := ieText;
  FItemType := itLabeledItem;
  FList := TStringList.Create;
  FList.OnChange := HandleListChange;
  FMaxHeight := 66;
  FPrefix := '';
  FReadOnly := False;
  FShowHint := False;
  FSuffix := '';
  FTag := 0;
  FVisible := True;
  FWordWrap := False;
  FTransparentImage := True;
  if Assigned(Collection) then
  begin
    CardList := GetCardList;
    if Assigned(CardList) and (csDesigning in CardList.ComponentState) and
        not (csLoading in CardList.ComponentState) then
        begin
          Template := GetTemplate;
          if Assigned(Template) and Assigned(Template.DefaultItem) then
             Self.AssignVisuals(Template.DefaultItem);
        end;
    Collection.EndUpdate;
  end;
end;

destructor TAdvCardTemplateItem.Destroy;
begin
  FreeAndNil(FValueFont);
  FreeAndNil(FCaptionFont);
  FreeAndNil(FList);
  inherited;
end;

procedure TAdvCardTemplateItem.Assign(Source: TPersistent);
var
  OldName: string;
begin
  if Source is TAdvCardTemplateItem then
    with TAdvCardTemplateItem(Source) do
    try
      Self.FUpdate := False;
      Self.FAutoSize := AutoSize;
      Self.FCaption := Caption;
      Self.FCaptionAlignment := CaptionAlignment;
      Self.FCaptionColor := CaptionColor;
      Self.FCaptionFont.Assign(CaptionFont);
      Self.FCaptionLayout := CaptionLayout;
      Self.FDataType := DataType;
      Self.FDefaultValue := DefaultValue;
      Self.FImageSize := ImageSize;
      Self.FFormat := Format;
      Self.FValueAlignment := ValueAlignment;
      Self.FValueColor := ValueColor;
      Self.FValueFont.Assign(ValueFont);
      Self.FValueLayout := ValueLayout;
      Self.FEditColor := EditColor;
      Self.FHeight := Height;
      Self.FHideBooleanCondition := HideBooleanCondition;
      Self.FHideDateCondition := HideDateCondition;
      Self.FHideFloatCondition := HideFloatCondition;
      Self.FHideIntegerCondition := HideIntegerCondition;
      Self.FHidePictureCondition := HidePictureCondition;
      Self.FHideStringCondition := HideStringCondition;
      Self.FItemEditor := ItemEditor;
      Self.FItemType := ItemType;
      Self.FList.Assign(List);
      Self.FMaxHeight := MaxHeight;
      OldName := Self.FName;
      //Self.FName := Name;
      Self.FPrefix := Prefix;
      Self.FReadOnly := ReadOnly;
      Self.FShowHint := ShowHint;
      Self.FSuffix := Suffix;
      Self.FTag := Tag;
      Self.FVisible := Visible;
      Self.FTransparentImage := TransparentImage;
      Self.FWordWrap := WordWrap;
    finally
      Self.FUpdate := True;
      Self.DoTemplateItemLinkedPropChange(OldName);
      Self.DoTemplateItemHideCondChange;
      Self.DoTemplateItemListChange;
      Self.DoTemplateItemChange;
    end else inherited;
end;

procedure TAdvCardTemplateItem.AssignVisuals(Source: TPersistent);
begin
  if Source is TAdvCardTemplateItem then
    with TAdvCardTemplateItem(Source) do
    try
      Self.FUpdate := False;
      Self.FCaptionAlignment := CaptionAlignment;
      Self.FCaptionColor := CaptionColor;
      Self.FCaptionFont.Assign(CaptionFont);
      Self.FCaptionLayout := CaptionLayout;
      Self.FValueAlignment := ValueAlignment;
      Self.FValueColor := ValueColor;
      Self.FValueFont.Assign(ValueFont);
      Self.FValueLayout := ValueLayout;
      Self.FEditColor := EditColor;
    finally
      Self.FUpdate := True;
      Self.DoTemplateItemChange;
    end else inherited;
end;


procedure TAdvCardTemplateItem.CheckEditorType(Data: TAdvCardItemDataType;
  Editor: TAdvCardItemEditor);
var
  S: String;

  procedure DoException(Dt: String);
  var
    Ed: String;
  begin
    case Editor of
    ieBoolean:          Ed := 'ieBoolean';
    ieDate:             Ed := 'ieDate';
    ieDropDownEdit:     Ed := 'ieDropDownEdit';
    ieDropDownList:     Ed := 'ieDropDownList';
    ieFloat:            Ed := 'ieFloat';
    ieNumber:           Ed := 'ieNumber';
    iePictureDialog:    Ed := 'iePictureDialog';
    ieText:             Ed := 'ieText';
    ieTime:             Ed := 'ieTime';
    end;
    if Assigned(Collection) and Assigned(TAdvCardTemplateItems(Collection).FCardTemplate)
      and Assigned(TAdvCardTemplateItems(Collection).FCardTemplate.FCardList) and
      (csLoading in TAdvCardTemplateItems(Collection).FCardTemplate.FCardList.ComponentState)
      then Exit;
    {$IFDEF DELPHI5_LVL}
    raise ECardTemplateError.CreateResFmt(@SResInvalidEditor, [Ed, Dt]);
    {$ENDIF}
  end;

begin
  case Data of
  idtBoolean:
    begin
      S := 'idtBoolean';
      case Editor of
      ieDate: DoException(S);
      ieDropDownEdit:;
      ieDropDownList:;
      ieFloat: DoException(S);
      ieNumber: DoException(S);
      iePictureDialog: DoException(S);
      ieText: DoException(S);
      ieTime: DoException(S);
      end;
    end;
  idtDate:
    begin
      S := 'idtDate';
      case Editor of
      ieBoolean: DoException(S);
      ieDropDownEdit:;
      ieDropDownList:;
      ieFloat: DoException(S);
      ieNumber: DoException(S);
      iePictureDialog: DoException(S);
      ieText:;
      ieTime: DoException(S);
      end;
    end;
  idtTime:
    begin
      S := 'idtTime';
      case Editor of
      ieBoolean: DoException(S);
      ieDate: DoException(S);
      ieDropDownEdit:;
      ieDropDownList:;
      ieFloat: DoException(S);
      ieNumber: DoException(S);
      iePictureDialog: DoException(S);
      ieText:;
      end;
    end;
  idtFloat:
    begin
      S := 'idtFloat';
      case Editor of
      ieBoolean: DoException(S);
      ieDate: DoException(S);
      ieDropDownEdit:;
      ieDropDownList:;
      ieNumber:;
      iePictureDialog: DoException(S);
      ieText:;
      ieTime: DoException(S);
      end;
    end;
  idtImage:
    begin
      S := 'idtImage';
      case Editor of
      ieBoolean: DoException(S);
      ieDate: DoException(S);
      ieDropDownEdit: DoException(S);
      ieDropDownList: DoException(S);
      ieFloat: DoException(S);
      ieNumber: DoException(S);
      ieText: DoException(S);
      ieTime: DoException(S);
      end;
    end;
  idtInteger:
    begin
      S := 'idtInteger';
      case Editor of
      ieBoolean: DoException(S);
      ieDate: DoException(S);
      ieDropDownEdit:;
      ieDropDownList:;
      ieFloat:;
      ieNumber:;
      iePictureDialog: DoException(S);
      ieText:;
      ieTime: DoException(S);
      end;
    end;
  idtString:
    begin
      S := 'idtString';
      case Editor of
      ieBoolean: DoException(S);
      iePictureDialog: DoException(S);
      end;
    end;
  end;
end;

procedure TAdvCardTemplateItem.DoTemplateItemChange;
begin
  if FUpdate then
  begin
    if Assigned(Collection) and (Collection is TAdvCardTemplateItems)
      then TAdvCardTemplateItems(Collection).ItemChanged(Self);
    if Assigned(FOnTemplateItemChange) then FOnTemplateItemChange(Self);
  end;
end;

procedure TAdvCardTemplateItem.DoTemplateItemDefValChange;
begin
  if Assigned(Collection) and Assigned(TAdvCardTemplateItems(Collection).FCardTemplate)
    and Assigned(TAdvCardTemplateItems(Collection).FCardTemplate.FCardList)
    then TAdvCardTemplateItems(Collection).FCardTemplate.FCardList.DefaultValueChanged(Self);
end;

procedure TAdvCardTemplateItem.DoTemplateItemHideCondChange;
begin
  if FUpdate then
  begin
    if Assigned(Collection) and (Collection is TAdvCardTemplateItems)
      then TAdvCardTemplateItems(Collection).ItemHideCondChanged(Self);
  end;
end;

procedure TAdvCardTemplateItem.DoTemplateItemListChange;
begin
  if FUpdate then
  begin
    if Assigned(Collection) and (Collection is TAdvCardTemplateItems)
      then TAdvCardTemplateItems(Collection).ItemListChanged(Self);
    if Assigned(FOnTemplateItemListChange) then FOnTemplateItemListChange(Self);
  end;
end;

procedure TAdvCardTemplateItem.DoTemplateItemLinkedPropChange(OldName: string);
begin
  if FUpdate then
  begin
    if Assigned(Collection) and (Collection is TAdvCardTemplateItems)
      then TAdvCardTemplateItems(Collection).ItemLinkedPropChanged(Self, OldName);
  end;
end;

procedure TAdvCardTemplateItem.HandleChildChange(Sender: TObject);
begin
  DoTemplateItemChange;
end;

procedure TAdvCardTemplateItem.HandleListChange(Sender: TObject);
begin
  DoTemplateItemListChange;
end;

function TAdvCardTemplateItem.GetTemplate: TAdvCardTemplate;
begin
  if Assigned(Collection) and (Collection is TAdvCardTemplateItems) then
    Result := TAdvCardTemplateItems(Collection).CardTemplate
  else
    Result := nil;
end;

function TAdvCardTemplateItem.GetCardList: TCustomAdvCardList;
var
  Template: TAdvCardTemplate;
begin
  Template := GetTemplate;
  if Assigned(Template) then
    Result := Template.CardList
  else
    Result := nil;
end;

function TAdvCardTemplateItem.GetDisplayName: string;
begin
  Result := FName;
end;

procedure TAdvCardTemplateItem.SetDisplayName(const Value: string);
begin
  if Value <> FName then
  begin
    FName := Value;
    inherited;
  end;
end;

procedure TAdvCardTemplateItem.SetCaptionAlignment(Value: TItemAlignment);
begin
  if Value <> FCaptionAlignment then
  begin
    FCaptionAlignment := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.Assign(Value);
end;

procedure TAdvCardTemplateItem.SetValueFont(const Value: TFont);
begin
  FValueFont.Assign(Value);
end;

procedure TAdvCardTemplateItem.SetValueURLType(
  const Value: TAdvCardItemURLType);
begin
  if (FValueURLType <> Value) then
  begin
    FValueURLType := Value;
    DoTemplateItemChange;
  end;  
end;

procedure TAdvCardTemplateItem.SetAutoSize(Value: Boolean);
begin
  if Value <> FAutoSize then
  begin
    FAutoSize := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetCaption(Value: string);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetCaptionColor(Value: TColor);
begin
  if Value <> FCaptionColor then
  begin
    FCaptionColor := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetCaptionLayout(Value: TItemLayout);
begin
  if Value <> FCaptionLayout then
  begin
    FCaptionLayout := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetCustomDraw(Value: Boolean);
begin
  if Value <> FCustomDraw then
  begin
    FCustomDraw := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetDataType(Value: TAdvCardItemDataType);
begin
  if Value <> FDataType then
  begin
    FDataType := Value;
    case Value of
    idtBoolean: FItemEditor := ieBoolean;
    idtDate: FItemEditor := ieDate;
    idtFloat: FItemEditor := ieFloat;
    idtImage: FItemEditor := iePictureDialog;
    idtInteger: FItemEditor := ieNumber;
    idtString: FItemEditor := ieText;
    idtTime: FItemEditor := ieTime;
    end;
    DoTemplateItemLinkedPropChange(FName);
    DoTemplateItemDefValChange;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetDefaultValue(Value: string);
begin
  if Value <> FDefaultValue then
  begin
    FDefaultValue := Value;
    DoTemplateItemDefValChange;
  end;
end;

procedure TAdvCardTemplateItem.SetFormat(Value: string);
begin
  if Value <> FFormat then
  begin
    FFormat := Value;
    DoTemplateItemLinkedPropChange(FName);
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetImageSize(Value: TAdvCardImageSize);
begin
  if Value <> FImageSize then
  begin
    FImageSize := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetValueAlignment(Value: TItemAlignment);
begin
  if Value <> FValueAlignment then
  begin
    FValueAlignment := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetValueColor(Value: TColor);
begin
  if Value <> FValueColor then
  begin
    FValueColor := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetValueLayout(Value: TItemLayout);
begin
  if Value <> FValueLayout then
  begin
    FValueLayout := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetEditColor(Value: TColor);
begin
  if Value <> FEditColor then
  begin
    FEditColor := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHeight(Value: Integer);
begin
  if Value <> FHeight then
  begin
    if (Value > FMaxHeight) and (FMaxHeight <> 0) then Value := FMaxHeight;
    if Value < 0 then Value := 0;
    FHeight := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHideBooleanCondition(Value: TAdvCardBooleanHideCondition);
begin
  if Value <> FHideBooleanCondition then
  begin
    FHideBooleanCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHideDateCondition(Value: TAdvCardDateHideCondition);
begin
  if Value <> FHideDateCondition then
  begin
    FHideDateCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHideFloatCondition(Value: TAdvCardFloatHideCondition);
begin
  if Value <> FHideFloatCondition then
  begin
    FHideFloatCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHideIntegerCondition(Value: TAdvCardIntegerHideCondition);
begin
  if Value <> FHideIntegerCondition then
  begin
    FHideIntegerCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHidePictureCondition(Value: TAdvCardPictureHideCondition);
begin
  if Value <> FHidePictureCondition then
  begin
    FHidePictureCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetHideStringCondition(Value: TAdvCardStringHideCondition);
begin
  if Value <> FHideStringCondition then
  begin
    FHideStringCondition := Value;
    DoTemplateItemHideCondChange;
  end;
end;

procedure TAdvCardTemplateItem.SetItemEditor(Value: TAdvCardItemEditor);
begin
  if Value <> FItemEditor then
  begin
    CheckEditorType(FDataType, Value);
    FItemEditor := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetItemType(Value: TAdvCardItemType);
begin
  if Value <> FItemType then
  begin
    FItemType := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetList(Value: TStringList);
begin
  FList.Assign(Value);
end;

procedure TAdvCardTemplateItem.SetMask(Value: string);
begin
  if Value <> FMask then
  begin
    FMask := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetMaxHeight(Value: Integer);
begin
  if Value <> FMaxHeight then
  begin
    if Value < 0 then Value := 0;
    FMaxHeight := Value;
    if (FHeight > FMaxHeight) and (FMaxHeight <> 0) then FHeight := FMaxHeight;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetName(Value: string);
var
  OldName: string;
begin
  if Value <> FName then
  begin
    {$IFDEF DELPHI5_LVL}
    if (Value = '') or (Assigned(Collection) and (Collection is TAdvCardTemplateItems) and
      (TAdvCardTemplateItems(Collection).GetItemByName(Value) <> nil))
      then raise ECardTemplateError.CreateResFmt(@SResInvalidItemName, [Value]);
    {$ENDIF} 

    OldName := FName;
    if FCaption = FName then
    begin
      FName := Value;
      if FCaption = '' then FCaption := Value else Caption := Value;
    end else FName := Value;
    if OldName <> '' then DoTemplateItemLinkedPropChange(OldName);
  end;
end;

procedure TAdvCardTemplateItem.SetPrefix(Value: string);
begin
  if Value <> FPrefix then
  begin
    FPrefix := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetReadOnly(Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetShowHint(Value: Boolean);
begin
  if Value <> FShowHint then
  begin
    FShowHint := Value;
  end;
end;

procedure TAdvCardTemplateItem.SetSuffix(Value: string);
begin
  if Value <> FSuffix then
  begin
    FSuffix := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    DoTemplateItemChange;
  end;
end;

procedure TAdvCardTemplateItem.SetWordWrap(Value: Boolean);
begin
  if Value <> FWordWrap then
  begin
    FWordWrap := Value;
    DoTemplateItemChange;
  end;
end;

//---------------------------//
//   TAdvCardTemplateItems   //
//---------------------------//

constructor TAdvCardTemplateItems.Create(CardTemplate: TAdvCardTemplate; ItemClass: TCollectionItemClass);
begin
  inherited Create(CardTemplate, ItemClass);
  FCardTemplate := CardTemplate;
end;

function TAdvCardTemplateItems.Add: TAdvCardTemplateItem;
begin
  Result := TAdvCardTemplateItem(inherited Add);
  if Assigned(FCardTemplate) then
    FCardTemplate.TemplateItemAdd(TAdvCardTemplateItem(Result));
end;

procedure TAdvCardTemplateItems.Assign(Source: TPersistent);
begin
  if (Source is TAdvCardTemplateItems) and Assigned(FCardTemplate) and
    Assigned(FCardTemplate.FCardList) then
  try
    FCardTemplate.FCardList.BeginUpdate;
    inherited;
  finally
    if Assigned(FCardTemplate.FCardList.Cards) then
      FCardTemplate.FCardList.Cards.UpdateCardItems(nil);
    FCardTemplate.FCardList.EndUpdate;
  end
  else
    inherited;
end;

procedure TAdvCardTemplateItems.Delete(Index: Integer);
begin
  if Assigned(FCardTemplate) then FCardTemplate.BeforTemplateItemDelete(GetItem(Index));
  {$IFDEF DELPHI5_LVL}
  inherited Delete(Index);
  {$ELSE}
  Items[Index].Free;
  {$ENDIF}
end;

function TAdvCardTemplateItems.GetItemByName(Name: string): TAdvCardTemplateItem;
var
  ItemN: Integer;
begin
  for ItemN := 0 to Count - 1 do
  begin
    Result := GetItem(ItemN);
    if Result.Name = Name then exit;
  end;
  Result := nil;
end;


function TAdvCardTemplateItems.Insert(Index: Integer): TAdvCardTemplateItem;
begin
  Result := TAdvCardTemplateItem(inherited Insert(Index));
  if Assigned(FCardTemplate) then FCardTemplate.TemplateItemAdd(TAdvCardTemplateItem(Result));
end;

function TAdvCardTemplateItems.GetItem(Index: Integer): TAdvCardTemplateItem;
begin
  Result := TAdvCardTemplateItem(inherited Items[Index]);
end;

procedure TAdvCardTemplateItems.SetCards(Value: TAdvCards);
begin
  FCards := Value;
  Update(nil);
end;

procedure TAdvCardTemplateItems.SetItem(Index: Integer; Value: TAdvCardTemplateItem);
begin
  inherited Items[Index] := Value;
end;

procedure TAdvCardTemplateItems.SetItemName(AItem: TCollectionItem);
var
  TName: string;
  N: Integer;
begin
  with TAdvCardTemplateItem(AItem) do
  begin
    if Name <> '' then exit;
    TName := Copy(ClassName, 2, Length(ClassName) - 1);
    N := ID;
    while GetItemByName(TName + IntToStr(N)) <> nil do inc(N);
    Name := TName + IntToStr(N);
  end;
end;

procedure TAdvCardTemplateItems.ItemChanged(Item: TAdvCardTemplateItem);
begin
  if Assigned(FCardTemplate) and Assigned(FCardTemplate.FCardList)
    then FCardTemplate.FCardList.CardTemplateItemChanged(Item);
end;

procedure TAdvCardTemplateItems.ItemHideCondChanged(Item: TAdvCardTemplateItem);
begin
  if Assigned(FCardTemplate) and Assigned(FCardTemplate.FCardList)
    then FCardTemplate.FCardList.CardTemplateItemHideCondChanged(Item);
end;

procedure TAdvCardTemplateItems.ItemListChanged(Item: TAdvCardTemplateItem);
begin
  if Assigned(FCardTemplate) and Assigned(FCardTemplate.FCardList)
    then FCardTemplate.FCardList.CardTemplateItemChanged(Item);
end;

procedure TAdvCardTemplateItems.ItemLinkedPropChanged(Item: TAdvCardTemplateItem; OldName: string);
var
  CardN: Integer;
  CardItem: TAdvCardItem;
begin
  if not Assigned(Cards) then exit;
  if Cards.Count = 0 then exit;
  for CardN := 0 to Cards.Count - 1 do
  begin
    CardItem := Cards.Items[CardN].ItemList.GetItemByName(OldName);
    if CardItem <> nil then
    begin
      CardItem.FName := Item.Name;
      CardItem.DataType := Item.DataType;
      CardItem.Format := Item.Format;
    end;
  end;
end;

procedure TAdvCardTemplateItems.Update(Item: TCollectionItem);
begin
  if Assigned(Cards) then Cards.CardTemplateItemOrderCountChanged;
end;

//----------------------//
//   TAdvCardTemplate   //
//----------------------//

constructor TAdvCardTemplate.Create(CardList: TCustomAdvCardList; TemplateItemsClass: TCardTemplateItemsClass;
  ItemClass: TCollectionItemClass);
begin
  inherited Create;
  FCardCaptionAlignment := taLeftJustify;
  FCardCaptionHeight := 22;
  FCardWidth := 200;
  FHorMargins := 10;
  FIndent := 5;
  FItemSpacing := 5;
  FVertMargins := 10;
  FItemLabelWidth := 100;
  AdjustItemValueWidth;
  FItems := TemplateItemsClass.Create(Self, ItemClass);
  FDefItems := TAdvCardTemplateItems.Create(nil, TAdvCardTemplateItem);
  FDefaultItem := FDefItems.Add;
  FCardList := CardList;
end;

destructor TAdvCardTemplate.Destroy;
begin
  FDefItems.Free;
  FCardList := nil;
  FItems.Free;
  inherited;
end;

procedure TAdvCardTemplate.SetDefaultItem(const Value: TAdvCardTemplateItem);
begin
  FDefaultItem.Assign(Value);
end;

procedure TAdvCardTemplate.Assign(Source: TPersistent);
begin
  if Source is TAdvCardTemplate then
    with TAdvCardTemplate(Source) do
    try
      if Assigned(Self.FCardList) then Self.FCardList.BeginUpdate;
      Self.FCardCaptionAlignment := CardCaptionAlignment;
      Self.FCardCaptionHeight := CardCaptionHeight;
      Self.FCardWidth := CardWidth;
      Self.FHorMargins := HorMargins;
      Self.FIndent := Indent;
      Self.FItemLabelWidth := ItemLabelWidth;
      Self.FItemLabelRealWidth := ItemLabelRealWidth;
      Self.FItemSpacing := ItemSpacing;
      Self.FItemValueWidth := ItemValueWidth;
      Self.FVertMargins := VertMargins;
      Self.FItems.Assign(Items);
    finally
      Self.DoCardTemplateChange;
      if Assigned(Self.FCardList) then Self.FCardList.EndUpdate;
    end else inherited;
end;

procedure TAdvCardTemplate.AdjustItemValueWidth;
var
  AllowWidth: Integer;
begin
  AllowWidth := FCardWidth - FHorMargins * 2 - FIndent;
  if AllowWidth < 0 then AllowWidth := 0;
  FItemLabelRealWidth := FItemLabelWidth;
  if FItemLabelRealWidth > AllowWidth then FItemLabelRealWidth := AllowWidth;
  FItemValueWidth := AllowWidth - FItemLabelRealWidth;
end;

procedure TAdvCardTemplate.AdjustItemLabelWidth;
var
  AllowWidth: Integer;
begin
  AllowWidth := FCardWidth - FHorMargins * 2 - FIndent;
  if AllowWidth < 0 then AllowWidth := 0;
  if FItemValueWidth > AllowWidth then FItemValueWidth := AllowWidth;
  FItemLabelWidth := AllowWidth - FItemValueWidth;
  FItemLabelRealWidth := FItemLabelWidth;
end;

procedure TAdvCardTemplate.DoCardTemplateChange;
begin
  if Assigned(FCardList) then
    FCardList.CardTemplateChanged;
  if Assigned(FOnCardTemplateChange) then
    FOnCardTemplateChange(Self);
end;

procedure TAdvCardTemplate.SetCardCaptionAlignment(Value: TItemAlignment);
begin
  if Value <> FCardCaptionAlignment then
  begin
    FCardCaptionAlignment := Value;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetCardCaptionHeight(Value: Integer);
begin
  if Value <> FCardCaptionHeight then
  begin
    FCardCaptionHeight := Value;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetCardWidth(Value: Integer);
begin
  if Value <> FCardWidth then
  begin
    FCardWidth := Value;
    AdjustItemValueWidth;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetHorMargins(Value: Integer);
begin
  if Value <> FHorMargins then
  begin
    FHorMargins := Value;
    AdjustItemValueWidth;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetIndent(Value: Integer);
begin
  if Value <> FIndent then
  begin
    FIndent := Value;
    AdjustItemValueWidth;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetItemLabelWidth(Value: Integer);
begin
  if (Value <> FItemLabelWidth) then
  begin
    FItemLabelWidth := Value;
    FItemLabelRealWidth := Value;
    AdjustItemValueWidth;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetItems(Value: TAdvCardTemplateItems);
begin
  FItems.Assign(Value);
  if Assigned(FCardList) and Assigned(FCardList.Cards)
    then FCardList.Cards.CardTemplateItemOrderCountChanged;
end;

procedure TAdvCardTemplate.SetItemSpacing(Value: Integer);
begin
  if Value <> FItemSpacing then
  begin
    FItemSpacing := Value;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetItemValueWidth(Value: Integer);
begin
  if Value <> FItemValueWidth then
  begin
    FItemValueWidth := Value;
    AdjustItemLabelWidth;
    DoCardTemplateChange;
  end;
end;

procedure TAdvCardTemplate.SetVertMargins(Value: Integer);
begin
  if Value <> FVertMargins then
  begin
    FVertMargins := Value;
    DoCardTemplateChange;
  end;
end;

function TAdvCardTemplate.GetOwner: TPersistent;
begin
  Result := FCardList;
end;

procedure TAdvCardTemplate.BeforTemplateItemDelete(Item: TAdvCardTemplateItem);
begin
  if Assigned(FOnBeforTemplateItemDelete) then FOnBeforTemplateItemDelete(Self, Item);
end;

procedure TAdvCardTemplate.TemplateItemAdd(Item: TAdvCardTemplateItem);
begin
  if Assigned(FOnTemplateItemAdd) then FOnTemplateItemAdd(Self, Item);
end;

//------------------//
//   TAdvCardItem   //
//------------------//

constructor TAdvCardItem.Create(Collection: TCollection);
begin
  if Assigned(Collection) then Collection.BeginUpdate;
  inherited Create(Collection);
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChange;
  FSelected := False;
  FHided := False;
  FBoolean := False;
  FString := '';
  FFloat := 0;
  FInteger := 0;
  FDate := 0;
  FTime := 0;
  Hint := '';
  Obj := nil;
  OwnsObject := False;
  Tag := 0;
  if Assigned(Collection) then Collection.EndUpdate;
end;

destructor TAdvCardItem.Destroy;
begin
  FPicture.Free;
  if OwnsObject and Assigned(Obj) then Obj.Free;
  inherited;
end;

procedure TAdvCardItem.Assign(Source: TPersistent);
begin
  if Source is TAdvCardItem then
    with TAdvCardItem(Source) do
    try
      case Self.DataType of
        idtString: Self.FString := AsString;
        idtFloat: Self.FFloat := AsFloat;
        idtInteger: Self.FInteger := AsInteger;
        idtBoolean: Self.FBoolean := AsBoolean;
        idtDate: Self.FDate := AsDate;
        idtTime: Self.FTime := AsTime;
        idtImage:
          try
            Self.FPicture.Assign(Picture);
          except
          end;
      end;
      Self.Hint := Hint;
      Self.Tag := Tag;
      if Assigned(Self.Obj) and Self.OwnsObject then FreeAndNil(Self.Obj);
      Self.Obj := Obj;
      Self.OwnsObject := OwnsObject;
    finally
      Self.DoChangeValue;
    end else inherited;
end;

procedure TAdvCardItem.DoChangeValue;
var
  Card: TAdvCard;
begin
  Card := TAdvCardItemList(Collection).Card;
  if Assigned(Card) and Assigned(Card.Collection) then
  begin
    TAdvCards(Card.Collection).CardItemValueChanged(Card, Self);
  end;
end;

function TAdvCardItem.GetBoolean: Boolean;
begin
  Result := False;
  case DataType of
    idtString:
      if (FString = '') or (UpperCase(FString) = UpperCase(SFalse))
        then Result := False else Result := True;
    idtFloat:
      if FFloat = 0 then Result := False else Result := True;
    idtInteger:
      if FInteger = 0 then Result := False else Result := True;
    idtBoolean:
      Result := FBoolean;
    idtDate: ;
    idtTime: ;
    idtImage: ;
  end;
end;

function TAdvCardItem.GetString: string;
begin
  Result := '';
  case DataType of
    idtString: Result := FString;
    idtFloat:
      try
        Result := FormatFloat(Format, FFloat);
      except
      end;
    idtInteger:
      try
        Result := IntToStr(FInteger);
      except
      end;
    idtBoolean:
      if FBoolean then Result := STrue else Result := SFalse;
    idtDate:
      try
        Result := DateToStr(FDate);
      except
      end;
    idtTime:
      try
        Result := TimeToStr(FTime);
      except
      end;
    idtImage: ;
  end;
end;

function TAdvCardItem.GetFloat: Double;
begin
  Result := 0;
  case DataType of
    idtString:
      try
        Result := StrToFloat(FString);
      except
      end;
    idtFloat:
      Result := FFloat;
    idtInteger:
      Result := FInteger;
    idtBoolean:
      if FBoolean then Result := 1 else Result := 0;
    idtDate: Result := FDate;
    idtTime: Result := FTime;
    idtImage: ;
  end;
end;

function TAdvCardItem.GetInteger: Integer;
begin
  Result := 0;
  case DataType of
    idtString:
      try
        Result := StrToInt(FString);
      except
      end;
    idtFloat:
      Result := Round(FFloat);
    idtInteger:
      Result := FInteger;
    idtBoolean:
      if FBoolean then Result := 1 else Result := 0;
    idtDate: Result := Round(FDate);
    idtTime: Result := Round(FTime);
    idtImage: ;
  end;
end;

function TAdvCardItem.GetDate: TDateTime;
begin
  Result := 0;
  case DataType of
    idtString:
      try
        Result := StrToDate(FString);
      except
      end;
    idtFloat:
      Result := FFloat;
    idtInteger:
      Result := FInteger;
    idtBoolean: ;
    idtDate: Result := FDate;
    idtTime: Result := FTime;
    idtImage: ;
  end;
end;

function TAdvCardItem.GetTime: TDateTime;
begin
  Result := 0;
  case DataType of
    idtString:
      try
        Result := StrToTime(FString);
      except
      end;
    idtFloat:
      Result := FFloat;
    idtInteger:
      Result := FInteger;
    idtBoolean: ;
    idtDate: Result := FDate;
    idtTime: Result := FTime;
    idtImage: ;
  end;
end;

procedure TAdvCardItem.SetBoolean(Value: Boolean);
begin
  case DataType of
    idtString:
      if Value then FString := STrue else FString := SFalse;
    idtFloat:
      if Value then FFloat := 1 else FFloat := 0;
    idtInteger:
      if Value then FInteger := 1 else FInteger := 0;
    idtBoolean:
      if Value <> FBoolean then FBoolean := Value else exit;
    idtDate: ;
    idtTime: ;
    idtImage: ;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetSelected(Value: Boolean);
begin
  if Value then
  begin
    if Assigned(Collection) and Assigned(TAdvCardItemList(Collection).Card) then
      TAdvCardItemList(Collection).Card.SetSelectedItem(Index);
  end
  else
    if Assigned(Collection) and Assigned(TAdvCardItemList(Collection).Card) then
      TAdvCardItemList(Collection).Card.SetSelectedItem(-1);
end;

procedure TAdvCardItem.SetString(Value: string);
var
  F: Double;
  I: Integer;
  B: Boolean;
  DT: TDateTime;
begin
  case DataType of
    idtString: if Value <> FString then FString := Value;
    idtFloat:
      try
        F := StrToFloat(Value);
        if F <> FFloat then FFloat := F;
      except
      end;
    idtInteger:
      try
        I := StrToInt(Value);
        if I <> FInteger then FInteger := I;
      except
      end;
    idtBoolean:
      begin
        if (Value = '') or (UpperCase(Value) = UpperCase(SFalse))
          then B := False else B := True;
        if B <> FBoolean then FBoolean := B;
      end;
    idtDate:
      try
        DT := StrToDate(Value);
        if DT <> FDate then FDate := DT;
      except
      end;
    idtTime:
      try
        DT := StrToTime(Value);
        if DT <> FTime then FTime := DT;
      except
      end;
    idtImage: Exit;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetFloat(Value: Double);
var
  S: String;
  I: Integer;
  B: Boolean;
begin
  case DataType of
    idtString:
      begin
        S := FloatToStr(Value);
        if S <> FString then FString := S else Exit;
      end;
    idtFloat:
      if Value <> FFloat then FFloat := Value else Exit;
    idtInteger:
      begin
        I := Round(Value);
        if I <> FInteger then FInteger := I else Exit;
      end;
    idtBoolean:
      begin
        if Value = 0 then B := False else B := True;
        if B <> FBoolean then FBoolean := B else Exit;
      end;
    idtDate:
      if Value <> FDate then FDate := Value else Exit;
    idtTime:
      if Value <> FTime then FTime := Value else Exit;
    idtImage: Exit;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetInteger(Value: Integer);
var
  S: String;
  B: Boolean;
begin
  case DataType of
    idtString:
      begin
        S := IntToStr(Value);
        if S <> FString then FString := S else Exit;
      end;
    idtFloat: if Value <> FFloat then FFloat := Value else Exit;
    idtInteger:
      if Value <> FInteger then FInteger := Value else Exit;
    idtBoolean:
      begin
        if Value = 0 then B := False else B := True;
        if B <> FBoolean then FBoolean := B else Exit;
      end;
    idtDate: if Value <> FDate then FDate := Value else Exit;
    idtTime: if Value <> FTime then FTime := Value else Exit;
    idtImage: Exit;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetDate(Value: TDateTime);
var
  S: String;
  I: Integer;
  B: Boolean;
begin
  case DataType of
    idtString:
      begin
        S := DateToStr(Value);
        if S <> FString then FString := S else Exit;
      end;
    idtFloat: if Value <> FFloat then FFloat := Value else Exit;
    idtInteger:
      begin
        I := Round(Value);
        if I <> FInteger then FInteger := I else Exit;
      end;
    idtBoolean:
      begin
        if Value = 0 then B := False else B := True;
        if B <> FBoolean then FBoolean := B else Exit;
      end;
    idtDate: if Value <> FDate then FDate := Value else Exit;
    idtTime: if Value <> FTime then FTime := Value;
    idtImage: Exit;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetTime(Value: TDateTime);
var
  S: String;
  I: Integer;
  B: Boolean;
begin
  case DataType of
    idtString:
      begin
        S := TimeToStr(Value);
        if S <> FString then FString := S else Exit;
      end;
    idtFloat: if Value <> FFloat then FFloat := Value else Exit;
    idtInteger:
      begin
        I := Round(Value);
        if I <> FInteger then FInteger := I else Exit;
      end;
    idtBoolean:
      begin
        if Value = 0 then B := False else B := True;
        if B <> FBoolean then FBoolean := B else Exit;
      end;
    idtDate: if Value <> FDate then FDate := Value else Exit;
    idtTime: if Value <> FTime then FTime := Value;
    idtImage: Exit;
  end;
  DoChangeValue;
end;

procedure TAdvCardItem.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
  DoChangeValue;
end;

procedure TAdvCardItem.PictureChange(Sender: TObject);
begin
  DoChangeValue;
end;

//----------------------//
//   TAdvCardItemList   //
//----------------------//

constructor TAdvCardItemList.Create(ItemClass: TCollectionItemClass);
begin
  inherited;
  AllowListModification := False;
end;

destructor TAdvCardItemList.Destroy;
begin
  AllowListModification := True;
  inherited;
end;

function TAdvCardItemList.GetItem(Index: Integer): TAdvCardItem;
begin
  Result := TAdvCardItem(inherited Items[Index]);
end;

procedure TAdvCardItemList.SetItem(Index: Integer; Value: TAdvCardItem);
begin
  inherited Items[Index] := Value;
end;

function TAdvCardItemList.Add: TAdvCardItem;
begin
  if AllowListModification
    then Result := TAdvCardItem(inherited Add)
  {$IFDEF DELPHI5_LVL}
  else
    raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['Add']);
  {$ENDIF}
end;

procedure TAdvCardItemList.Assign(Source: TPersistent);
var
  OldAllow: Boolean;
  ItemN, ToItemN: Integer;
begin
  OldAllow := AllowListModification;
  
  if (Source is TAdvCardItemList) then
  try
    AllowListModification := True;
    BeginUpdate;
    ToItemN := Count - 1;
    if ToItemN > TAdvCardItemList(Source).Count - 1 then
      ToItemN := TAdvCardItemList(Source).Count - 1;
    for ItemN := 0 to ToItemN do
    begin
      Items[ItemN].Assign(TAdvCardItemList(Source).Items[ItemN]);
    end;
  finally
    EndUpdate;
    AllowListModification := OldAllow;
  end
  else
    inherited;
end;

procedure TAdvCardItemList.BeginUpdate;
begin
  if AllowListModification
    then inherited
  {$IFDEF DELPHI5_LVL}
  else raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['BeginUpdate']);
  {$ENDIF}
end;

procedure TAdvCardItemList.Clear;
begin
  if AllowListModification then
    inherited
  {$IFDEF DELPHI5_LVL}
  else raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['Clear']);
  {$ENDIF}
end;

procedure TAdvCardItemList.Delete(Index: Integer);
begin
  if AllowListModification then
    inherited
  {$IFDEF DELPHI5_LVL}
  else
    raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['Delete']);
  {$ENDIF}
end;

procedure TAdvCardItemList.EndUpdate;
begin
  if AllowListModification then
    inherited
  {$IFDEF DELPHI5_LVL}
  else
    raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['EndUpdate']);
  {$ENDIF}
end;

function TAdvCardItemList.Insert(Index: Integer): TAdvCardItem;
begin
  if AllowListModification
    then Result := TAdvCardItem(inherited Insert(Index))
  {$IFDEF DELPHI5_LVL}
  else
    raise ECardItemListError.CreateResFmt(@SResInvalidOperation, ['Insert']);
  {$ENDIF}
end;

function TAdvCardItemList.GetItemByName(Name: string): TAdvCardItem;
var
  ItemN: Integer;
begin
  for ItemN := 0 to Count - 1 do
  begin
    Result := GetItem(ItemN);
    if Result.Name = Name then exit;
  end;
  Result := nil;
end;

//--------------//
//   TAdvCard   //
//--------------//

constructor TAdvCard.Create(Collection: TCollection);
begin
  if Assigned(Collection) then Collection.BeginUpdate;
  inherited Create(Collection);
  FItemList := TAdvCardItemList.Create(TAdvCardItem);
  FItemList.FCard := Self;
  FFiltered := True;
  FVisible := True;
  FMouseOver := False;
  FEditing := False;
  FSelected := False;
  FSelectedItem := -1;
  FImageIndex := -1;
  if Assigned(Collection) then
  begin
    TAdvCards(Collection).UpdateCardItems(Self);
    TAdvCards(Collection).CalcClientRects(Self);
    TAdvCards(Collection).ApplyAppearance(Self);
    Collection.EndUpdate;
  end;
end;

destructor TAdvCard.Destroy;
begin
  FreeAndNil(FItemList);
  inherited;
end;

procedure TAdvCard.Assign(Source: TPersistent);
var
  CardList: TCustomAdvCardList;
begin

  if Source is TAdvCard then
  begin
    CardList := nil;
    if Assigned(Collection) then
      CardList := TAdvCards(Collection).FCardList;
    with TAdvCard(Source) do
    try
      if Assigned(CardList) then
        CardList.BeginUpdate;
      Self.FCaption := Caption;
      Self.FHint := Hint;
      Self.FTag := Tag;
      Self.FVisible := Visible;
      Self.FItemList.Assign(ItemList);
    finally
      if Assigned(CardList) then CardList.EndUpdate;
    end;
  end else inherited;
end;

procedure TAdvCard.DoCardChange;
begin
  if Assigned(Collection) and Assigned(TAdvCards(Collection).FCardList) then
    TAdvCards(Collection).FCardList.CardChanged(Self);
end;

procedure TAdvCard.DoSelectChanged;
begin
  if Assigned(Collection) then
  begin
    if Assigned(TAdvCards(Collection).FCardList) then
    begin
      if TAdvCards(Collection).UpdateSelected then
        TAdvCards(Collection).FCardList.Invalidate;
        
      TAdvCards(Collection).FCardList.SelectedChanged;
    end;
  end;
end;

procedure TAdvCard.SetCaption(Value: string);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    if Assigned(Collection) and Assigned(TAdvCards(Collection).FCardList) then
    begin
      TAdvCards(Collection).FCardList.DataChanged(Self, nil, dcoCaption);
    end;
    DoCardChange;
  end;
end;

procedure TAdvCard.SetSelected(Value: Boolean);
var
  CardList: TCustomAdvCardList;
  OldSelected: Integer;
begin
  if Value <> FSelected then
  begin
    FSelected := Value;
    if Assigned(Collection)
      then CardList := TAdvCards(Collection).FCardList
    else CardList := nil;

    if Assigned(CardList) then OldSelected := CardList.SelectedIndex
      else OldSelected := -1;

    if Value then
    begin

      if Assigned(CardList) then
      begin
        // uncheck item in old selected card
        if Assigned(CardList.SelectedCard) then
          CardList.SelectedCard.FSelectedItem := -1;
        CardList.FSelectedIndex := Self.Index;
        CardList.FSelectedCard := Self;
        Inc(CardList.FSelectedCount);
        CardList.GoToSelected;
      end;

    end
    else
    begin
      FSelectedItem := -1;
      if Assigned(CardList) then
      begin
        if Assigned(CardList.SelectedCard) and (CardList.SelectedCard = Self) then
        begin
          CardList.FSelectedCard := nil;
          CardList.FSelectedIndex := -1;
        end;
        Dec(CardList.FSelectedCount);
      end;
    end;

    if Assigned(Collection) then
      TAdvCards(Collection).ApplyAppearance(Self);

    DoSelectChanged(OldSelected);
  end;
end;

procedure TAdvCard.SetSelectedItem(Value: Integer);
begin
  if Value <> FSelectedItem then
  begin
    // can not select item in unselected card
    if not FSelected then Exit;
    if (Value > FItemList.Count - 1) then Exit;
    if (FSelectedItem > 0) and (FSelectedItem < FItemList.Count) then
      FItemList[FSelectedItem].FSelected := False;
    FSelectedItem := Value;
    if (Value >= 0) then
      FItemList[Value].FSelected := True;
    // fix  
    DoSelectChanged(Index);
  end;
end;

procedure TAdvCard.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    DoCardChange;
  end;
end;

procedure TAdvCard.SetItemList(Value: TAdvCardItemList);
begin
  FItemList.Assign(Value);
end;

//---------------//
//   TAdvCards   //
//---------------//

constructor TAdvCards.Create(CardList: TCustomAdvCardList; ItemClass: TCollectionItemClass);
begin
  inherited Create(ItemClass);
  FCardList := CardList;
  UpdateSelected := True;
end;

procedure TAdvCards.ApplyAppearance(Card: TAdvCard);
var
  CardN: Integer;
begin
  if Card <> nil then
  begin
    if Card.FEditing and FCardList.CardEditingAppearance.Enabled
      then Card.FAppearance := FCardList.CardEditingAppearance else
      if Card.FSelected and FCardList.CardSelectedAppearance.Enabled
        then Card.FAppearance := FCardList.CardSelectedAppearance else
        if Card.FMouseOver and FCardList.CardHoverAppearance.Enabled
          then Card.FAppearance := FCardList.CardHoverAppearance else
          Card.FAppearance := FCardList.CardNormalAppearance;
  end
  else
  // for all cards
  begin
    for CardN := 0 to Count - 1 do
      if Items[CardN].Visible and Items[CardN].Filtered then
        ApplyAppearance(Items[CardN]);
  end;
end;

function TAdvCards.GetItem(Index: Integer): TAdvCard;
begin
  Result := TAdvCard(inherited Items[Index]);
end;

procedure TAdvCards.SetItem(Index: Integer; Value: TAdvCard);
begin
  inherited Items[Index] := Value;
end;

procedure TAdvCards.SetUpdateSelected(Value: Boolean);
begin
  if Value <> FUpdateSelected then
  begin
    FUpdateSelected := Value;
    if Value and Assigned(FCardList) then
      FCardList.Invalidate;
  end;
end;

procedure TAdvCards.Clear;
begin
  FCardList.FInClientAreaCards := nil;
  inherited Clear;
end;


procedure TAdvCards.UpdateCardItems(Card: TAdvCard);
var
  CardN, ItemN, ItemDif, TemplItemN: Integer;
  TemplItem: TAdvCardTemplateItem;
  CardItem: TAdvCardItem;
  OldAllow: Boolean;

  procedure AddItem(Card: TAdvCard; TItemIndex: Integer);
  var
    TItem: TAdvCardTemplateItem;
    CardItem: TAdvCardItem;
  begin
    TItem := FCardList.CardTemplate.Items[TItemIndex];
    CardItem := Card.FItemList.Add;
    CardItem.FName := TItem.Name;
    CardItem.DataType := TItem.DataType;
    CardItem.Format := TItem.Format;
    if (CardItem.DataType = idtImage) and (TItem.DefaultValue <> '') then
    begin
      try
        CardItem.Picture.LoadFromFile(TItem.DefaultValue);
      except
        on Exception do
        if Assigned(CardItem.Picture) then
          if Assigned(CardItem.Picture.Graphic) then CardItem.Picture.Graphic := nil;
      end;
    end else
    // destroy old image
    begin
      try
        if Assigned(CardItem.Picture.Graphic) and not CardItem.Picture.Graphic.Empty then
          CardItem.Picture.Graphic := nil;
      except
      end;
      if (TItem.DefaultValue <> '') then
        CardItem.AsString := TItem.DefaultValue;
    end;
  end;

  procedure InsertItem(Card: TAdvCard; TItemIndex, Index: Integer);
  var
    TItem: TAdvCardTemplateItem;
    CardItem: TAdvCardItem;
  begin
    TItem := FCardList.CardTemplate.Items[TItemIndex];
    CardItem := Card.FItemList.Insert(Index);
    CardItem.FName := TItem.Name;
    CardItem.DataType := TItem.DataType;
    CardItem.Format := TItem.Format;
    if (CardItem.DataType = idtImage) and (TItem.DefaultValue <> '') then
    begin
      try
        CardItem.Picture.LoadFromFile(TItem.DefaultValue);
      except
        on Exception do
          if Assigned(CardItem.Picture.Graphic) then CardItem.Picture.Graphic := nil;
      end;
    end else
    // destroy old image
    begin
      try
        if Assigned(CardItem.Picture.Graphic) and not CardItem.Picture.Graphic.Empty then
          CardItem.Picture.Graphic := nil;
      except
      end;
      if (TItem.DefaultValue <> '') then
        CardItem.AsString := TItem.DefaultValue;
    end;
  end;

begin
  if not Assigned(FCardList) or not Assigned(FCardList.CardTemplate) then exit;
  if Card <> nil then
  // Update Card
  begin
    FCardList.BeginUpdate;
    OldAllow := Card.ItemList.AllowListModification;
    Card.ItemList.AllowListModification := True;
    if FCardList.CardTemplate.Items.Count = 0 then
    // Clear items
    begin
      Card.FItemList.Clear;
    end else
      if Card.FItemList.Count = 0 then
    // Add all items
      begin
        for TemplItemN := 0 to FCardList.CardTemplate.Items.Count - 1 do AddItem(Card, TemplItemN);
      end else
    // Check all items
      begin
        ItemN := 0;
        while ItemN <= (Card.FItemList.Count - 1) do
        begin
        // Card has items more then CardTemplate
          if ItemN > (FCardList.CardTemplate.Items.Count - 1) then
          begin
            Card.FItemList.Delete(ItemN);
            Continue;
          end;
          if Card.FItemList[ItemN].Name <> FCardList.CardTemplate.Items[ItemN].Name then
        // Names not match -> Try to find item with the same name
          begin
            TemplItem := FCardList.CardTemplate.Items.GetItemByName(Card.FItemList[ItemN].Name);
          // item not found
            if TemplItem = nil then
            begin
              Card.FItemList.Delete(ItemN);
              Continue;
            end else
          // item found
            begin
            // In the existing range
              if TemplItem.Index <= (Card.FItemList.Count - 1) then
              begin
                Card.FItemList[ItemN].Index := TemplItem.Index;
                Continue;
              end else
            // Not enough items in card
              begin
                CardItem := Card.FItemList.GetItemByName(FCardList.CardTemplate.Items[ItemN].Name);
              // The template item exists in card
                if CardItem <> nil then
                begin
                  CardItem.Index := ItemN;
                  inc(ItemN);
                  Continue;
                end else
              // Need new card item
                begin
                  InsertItem(Card, ItemN, ItemN);
                  inc(ItemN);
                  Continue;
                end;
              end;
            end;
          end;
          inc(ItemN);
        end; {while}
      // are there more items in CardTemplate?
        ItemDif := FCardList.CardTemplate.Items.Count - Card.FItemList.Count;
        for ItemN := Card.FItemList.Count to Card.FItemList.Count - 1 + ItemDif do
          AddItem(Card, ItemN);
      end;
    FCardList.EndUpdate;
    Card.ItemList.AllowListModification := OldAllow;
  end else
  // Update all cards
  begin
    FCardList.BeginUpdate;
    for CardN := 0 to Count - 1 do UpdateCardItems(Items[CardN]);
    FCardList.EndUpdate;
  end; {Card = nil}
end;

procedure TAdvCards.CalcClientRects(Card: TAdvCard);
var
  CardN, ItemN, LabelHeight, ValueHeight,
    SumHeight, ResHeight, LabelWidth, ValueWidth, ValueIndent: Integer;
  TItem: TAdvCardTemplateItem;
  Item: TAdvCardItem;
  R: TRect;

  function GetItemCaptionHeight(ItemIndex: Integer): Integer;
  var
    TItem: TAdvCardTemplateItem;
    S: string;
  begin
    TItem := FCardList.CardTemplate.Items[ItemIndex];
    with FCardList.Canvas do
    begin
      Font.Assign(TItem.CaptionFont);
      S := TItem.Caption;
      if S = '' then S := 'A';
      Result := TextHeight(TItem.Caption);
    end;
  end;

  procedure GetItemValueRect(ItemIndex: Integer; var Rect: TRect);
  var
    TItem: TAdvCardTemplateItem;
    Item: TAdvCardItem;
    S: string;
    v : double;
    m : integer;

  begin
    TItem := FCardList.CardTemplate.Items[ItemIndex];
    Item := Card.ItemList[ItemIndex];
    case TItem.DataType of
      idtImage:
        if Assigned(Item.FPicture.Graphic) and not Item.FPicture.Graphic.Empty then
        begin
          Rect.Bottom := Item.FPicture.Height;

          if (TItem.ItemType = itLabeledItem) and (TItem.ImageSize = isStretchedProp) then
          begin
            m := self.FCardList.CardTemplate.ItemValueWidth;

            if (Item.FPicture.Width > 0) then
            begin
              v := m / Item.FPicture.Width;
              Rect.Bottom := Trunc(Item.FPicture.Height * v);
            end
            else
              Rect.Bottom := Item.FPicture.Height;
          end;
        end;
    else
      begin
        S := TItem.Prefix + Item.AsString + TItem.Suffix;
        if S = '' then S := 'A';
        FCardList.Canvas.Font.Assign(TItem.ValueFont);
        if TItem.WordWrap then
        begin
          DrawText(FCardList.Canvas.Handle, PCHAR(S), Length(S), Rect,
            DT_LEFT or DT_WORDBREAK or DT_TOP or DT_CALCRECT);
        end else
        begin
          Rect.Bottom := FCardList.Canvas.TextHeight(S);
        end;
      end;
    end; {case}
  end;

begin
  LabelWidth := 0;
  ValueWidth := 0;
  ValueIndent := 0;
  
  if Card <> nil then
  begin
    if not Card.FFiltered or not Card.FVisible then exit;
    // Card caption
    Card.FCaptionClientRect := Bounds(0, 0,
      FCardList.CardTemplate.CardWidth, FCardList.CardTemplate.CardCaptionHeight);
    Card.FCaptionCardRect := Card.FCaptionClientRect;
    SumHeight := FCardList.CardTemplate.CardCaptionHeight;
    // Items
    Inc(SumHeight, FCardList.CardTemplate.VertMargins);
    for ItemN := 0 to Card.ItemList.Count - 1 do
    begin
      TItem := FCardList.CardTemplate.Items[ItemN];
      Item := Card.ItemList[ItemN];
      if (not TItem.Visible) or Item.FHided then continue;

      case TItem.ItemType of
      itLabeledItem:
        begin
          LabelWidth := FCardList.CardTemplate.FItemLabelRealWidth;
          ValueWidth := FCardList.CardTemplate.ItemValueWidth;
          ValueIndent := FCardList.CardTemplate.Indent;
        end;
      itItem:
        begin
          LabelWidth := 0;
          ValueIndent := 0;
          ValueWidth := FCardList.CardTemplate.CardWidth - FCardList.CardTemplate.HorMargins * 2;
        end;
      itLabel:
        begin
          LabelWidth := FCardList.CardTemplate.CardWidth - FCardList.CardTemplate.HorMargins * 2;
          ValueWidth := 0;
          ValueIndent := 0;
        end;
      end;  

      if TItem.AutoSize then
      begin
        if TItem.ItemType in [itLabeledItem, itLabel] then
          LabelHeight := GetItemCaptionHeight(ItemN)
        else LabelHeight := 0;
        R := Bounds(0, 0, ValueWidth, TItem.Height);
        GetItemValueRect(ItemN, R);
        ValueHeight := R.Bottom - R.Top;
        ResHeight := Max(LabelHeight, ValueHeight);
      end else
      begin
        ResHeight := TItem.Height;
      end;
      if TItem.MaxHeight <> 0 then ResHeight := Min(ResHeight, TItem.MaxHeight);
      if ItemN <> 0 then Inc(SumHeight, FCardList.CardTemplate.FItemSpacing);
      // label
      Item.FLabelClientRect := Bounds(0, 0, LabelWidth, ResHeight);
      Item.FLabelCardRect := Bounds(FCardList.CardTemplate.HorMargins,
        SumHeight, LabelWidth, ResHeight);
      // value
      Item.FValueClientRect := Bounds(0, 0, ValueWidth, ResHeight);
      Item.FValueCardRect := Bounds(FCardList.CardTemplate.HorMargins +
        LabelWidth + ValueIndent, SumHeight, ValueWidth, ResHeight);
      Inc(SumHeight, ResHeight);
    end; {for ItemN}
    Inc(SumHeight, FCardList.CardTemplate.FVertMargins);
    Card.FClientRect := Bounds(0, 0, FCardList.CardTemplate.CardWidth, SumHeight);
    Card.FHeight := SumHeight;
  end else
  // all cards
  begin
    for CardN := 0 to Count - 1 do CalcClientRects(Items[CardN]);
  end;
end;

procedure TAdvCards.CardItemValueChanged(Card: TAdvCard; Item: TAdvCardItem);
begin
  CheckItemShow(Card, Item.Index);
  CalcClientRects(Card);
  if Assigned(FCardList) then
  begin
    FCardList.UpdateCards(False, True, True, True);
    FCardList.DataChanged(Card, Item, dcoItem);
  end;
end;

procedure TAdvCards.CardTemplateItemOrderCountChanged;
begin
  UpdateCardItems(nil);
  FCardList.UpdateCards(True, True, True, True);
end;

function TAdvCards.CheckItemShow(Card: TAdvCard; ItemIndex: Integer): Boolean;
var
  Allow: Boolean;
  CardN: Integer;
  Item: TAdvCardItem;
begin
  Result := True;

  if Card <> nil then
  begin
    if not (Assigned(FCardList) and Assigned(FCardList.CardTemplate) and (ItemIndex < Card.ItemList.Count)) then
      Exit;

    Item := Card.ItemList[ItemIndex];

    case Item.DataType of
      idtString:
        case FCardList.CardTemplate.Items[ItemIndex].HideStringCondition of
          shcAlwaysShow, shcCustom:
            Allow := True;
          shcEmpty:
            Allow := Item.AsString <> '';
          shcNotEmpty:
            Allow := Item.AsString = '';
        end;
      idtFloat:
        case FCardList.CardTemplate.Items[ItemIndex].HideFloatCondition of
          fhcAlwaysShow, fhcCustom:
            Allow := True;
          fhcNull:
            Allow := Item.AsFloat <> 0;
          fhcNotNull:
            Allow := Item.AsFloat = 0;
        end;
      idtInteger:
        case FCardList.CardTemplate.Items[ItemIndex].HideIntegerCondition of
          ihcAlwaysShow, ihcCustom:
            Allow := True;
          ihcNull:
            Allow := Item.AsInteger <> 0;
          ihcNotNull:
            Allow := Item.AsInteger = 0;
        end;
      idtBoolean:
        case FCardList.CardTemplate.Items[ItemIndex].HideBooleanCondition of
          bhcAlwaysShow, bhcCustom:
            Allow := True;
          bhcFalse:
            Allow := Item.AsBoolean <> False;
          bhcTrue:
            Allow := Item.AsBoolean <> True;
        end;
      idtDate:
        case FCardList.CardTemplate.Items[ItemIndex].HideDateCondition of
          dhcAlwaysShow, dhcCustom:
            Allow := True;
          dhcNullDate:
            Allow := Item.AsDate <> 0;
          dhcNotNullDate:
            Allow := Item.AsDate = 0;
        end;
      idtTime:
        case FCardList.CardTemplate.Items[ItemIndex].HideDateCondition of
          dhcAlwaysShow, dhcCustom:
            Allow := True;
          dhcNullDate:
            Allow := Item.AsTime <> 0;
          dhcNotNullDate:
            Allow := Item.AsTime = 0;
        end;
      idtImage:
        case FCardList.CardTemplate.Items[ItemIndex].HidePictureCondition of
          phcAlwaysShow, phcCustom: Allow := True;
          phcEmpty: Allow := not (Assigned(Item.Picture.Graphic) and Item.Picture.Graphic.Empty);
          phcNotEmpty: Allow := (Assigned(Item.Picture.Graphic) and Item.Picture.Graphic.Empty);
        end;
    end;

    if Assigned(FCardList.FOnShowCardItem) then
      FCardList.FOnShowCardItem(FCardList, Card.Index, ItemIndex, Allow);

    if csDesigning in FCardList.ComponentState then
      Item.FHided := False
    else
      Item.FHided := not Allow;

    if Item.FHided and Item.Selected then
      Card.SelectedItem := -1;
    Result := Allow;
  end
  else
    // for all cards
    begin
      for CardN := 0 to Count - 1 do CheckItemShow(Items[CardN], ItemIndex);
    end;
end;

procedure TAdvCards.Update(Item: TCollectionItem);
begin
  FCardList.CardOrderCountChanged;
end;

function TAdvCards.Add: TAdvCard;
var
   i: integer;
begin
  Result := TAdvCard(inherited Add);

  // initialize default show condition
  for I := 0 to Result.ItemList.Count - 1 do
    CheckItemShow(Result,I);

  if Assigned(FOnCardAdd) then
    FOnCardAdd(Self, TAdvCard(Result));
end;

procedure TAdvCards.Delete(Index: Integer);
begin
  if Assigned(FOnBeforCardDelete) then FOnBeforCardDelete(Self, GetItem(Index));
  {$IFDEF DELPHI5_LVL}
  inherited Delete(Index);
  {$ELSE}
  Items[Index].Free;
  {$ENDIF}
end;

function TAdvCards.Insert(Index: Integer): TAdvCard;
begin
  Result := TAdvCard(inherited Insert(Index));
  if Assigned(FOnCardAdd) then FOnCardAdd(Self, TAdvCard(Result));
end;

//--------------------------//
//   TAdvCardSortSettings   //
//--------------------------//

constructor TAdvCardSortSettings.Create;
begin
  inherited;
  FSortDirection := sdAscending;
  FSortIndex := 0;
  FSortType := stNone;
  FCaseSensitive := False;
end;

procedure TAdvCardSortSettings.Assign(Source: TPersistent);
begin
  if Source is TAdvCardSortSettings then
    with Source as TAdvCardSortSettings do
    begin
      Self.FSortDirection := SortDirection;
      Self.FSortIndex := SortIndex;
      Self.DoSortSettingChange;
    end else inherited;
end;

procedure TAdvCardSortSettings.DoSortSettingChange;
begin
  if Assigned(FOnSortChange) then FOnSortChange(Self);
end;

procedure TAdvCardSortSettings.SetSortDirection(Value: TSortDirection);
begin
  if Value <> FSortDirection then
  begin
    FSortDirection := Value;
    DoSortSettingChange;
  end;
end;

procedure TAdvCardSortSettings.SetSortIndex(Value: Integer);
begin
  if Value <> FSortIndex then
  begin
    FSortIndex := Value;
    DoSortSettingChange;
  end;
end;

procedure TAdvCardSortSettings.SetSortType(const Value: TSortType);
begin
  if Value <> FSortType then
  begin
    FSortType := Value;
    DoSortSettingChange;
  end;  
end;

//----------------------------//
//   TAdvCardFilterSettings   //
//----------------------------//

constructor TAdvCardFilterSettings.Create;
begin
  inherited;
  FFilterIndex := 0;
  FFilterCondition := '';
end;

procedure TAdvCardFilterSettings.Assign(Source: TPersistent);
begin
  if Source is TAdvCardFilterSettings then
    with Source as TAdvCardFilterSettings do
    begin
      Self.FFilterIndex := FilterIndex;
      Self.FFilterCondition := FilterCondition;
      Self.DoFilterSettingsChange;
    end else inherited;
end;

procedure TAdvCardFilterSettings.DoFilterSettingsChange;
begin
  if Assigned(FOnFilterChange) then FOnFilterChange(Self);
end;

procedure TAdvCardFilterSettings.SetFilterCondition(Value: string);
begin
  if Value <> FFilterCondition then
  begin
    FFilterCondition := Value;
    DoFilterSettingsChange;
  end;
end;

procedure TAdvCardFilterSettings.SetFilterIndex(Value: Integer);
begin
  if Value <> FFilterIndex then
  begin
    FFilterIndex := Value;
    DoFilterSettingsChange;
  end;
end;

//------------------//
//   TAdvCardList   //
//------------------//

constructor TCustomAdvCardList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable]
{$IFDEF DELPHI7_LVL}
  - [csParentBackground]
{$ENDIF};
  ParentColor := False;
  ParentFont := False;
  ParentCtl3D := False;
  FAutoEdit := True;
  FEdControl := nil;
  FocusPen := 0;
  // Checkbox
  FDspBMPChecked := TBitmap.Create;
  FDspBMPChecked.LoadFromResourceName(HInstance, 'CHECKED');
  FDspBMPUnchecked := TBitmap.Create;
  FDspBMPUnchecked.LoadFromResourceName(HInstance, 'UNCHECKED');
  FCheckBoxSize := FDspBMPChecked.Height;
  //
  FEdByMouse := False;
  FUpdateCount := 0;
  FHoverCardIndex := -1;
  FOverItemIndex := -1;
  FViewedColumns := 0;
  FCursorOverGridLine := False;
  FGridLineDragging := False;
  FSortedCards := nil;
  FCanvasLeft := 0;
  FCanvasRight := 0;
  FBorderColor := $B99D7F;
  FBorderWidth := 1;

  FCardNormalAppearance := TAdvCardAppearance.Create;
  FCardNormalAppearance.OnAppearanceChange := HandleAppearanceChange;
  FCardNormalAppearance.CaptionColor.Color := clBtnFace;
  FCardNormalAppearance.CaptionColor.ColorTo := clNone;
  FCardNormalAppearance.CaptionFont.Color := clBlack;
  FCardNormalAppearance.CaptionFont.Style := [fsBold];  
  FCardNormalAppearance.BevelOuter := bvNone;
  FCardNormalAppearance.BorderColor := clNone;

  FCardHoverAppearance := TAdvCardAppearance.Create;
  FCardHoverAppearance.OnAppearanceChange := HandleAppearanceChange;

  FCardHoverAppearance.CaptionColor.Color := clBtnFace;
  FCardHoverAppearance.CaptionColor.ColorTo := clNone;
  FCardHoverAppearance.CaptionFont.Color := clBlack;
  FCardHoverAppearance.CaptionFont.Style := [fsBold];
  FCardHoverAppearance.BevelOuter := bvNone;
  FCardHoverAppearance.BorderColor := clSilver;

  FCardEditingAppearance := TAdvCardAppearance.Create;
  FCardEditingAppearance.OnAppearanceChange := HandleAppearanceChange;
  FCardEditingAppearance.CaptionColor.Color := clNavy;
  FCardEditingAppearance.CaptionColor.ColorTo := clNone;
  FCardEditingAppearance.CaptionFont.Color := clWhite;
  FCardEditingAppearance.CaptionFont.Style := [fsBold];
  FCardEditingAppearance.BevelOuter := bvNone;
  FCardEditingAppearance.BorderColor := clBtnFace;
  FCardEditingAppearance.Color.Color := clInfoBk;

  FCardSelectedAppearance := TAdvCardAppearance.Create;
  FCardSelectedAppearance.OnAppearanceChange := HandleAppearanceChange;
  FCardSelectedAppearance.CaptionColor.Color := clNavy;
  FCardSelectedAppearance.CaptionColor.ColorTo := clNone;
  FCardSelectedAppearance.CaptionFont.Color := clWhite;
  FCardSelectedAppearance.CaptionFont.Style := [fsBold];
  FCardSelectedAppearance.BevelOuter := bvNone;
  FCardSelectedAppearance.BorderColor := clBtnFace;
  FGotoSelectedAutomatic := True;
	
  FScrolling := False;
  FDelayedCardLoad := False;
  DelayedCardLoadTimer := TTimer.Create(self);
  DelayedCardLoadTimer.Enabled := False;
  DelayedCardLoadTimer.Interval := 100;
  DelayedCardLoadTimer.OnTimer := DelayedCardLoadTimerOnTimer;

  FCards := TAdvCards.Create(Self, TAdvCard);
  CreateTemplate(FCards);
  FCardHorSpacing := 20;
  FCardVertSpacing := 20;
  FColor := TAdvGradient.Create;
  FColor.OnGradientChange := HandleColorChange;
  FColumns := 0;
  FColumnSizing := True;
  FColumnWidth := 240;
  FFiltered := False;
  FFilterSettings := TAdvCardFilterSettings.Create;
  FFilterSettings.OnFilterChange := HandleFilterSettingsChange;
  FFocusColor := clGray;
  OldPen := TPen.Create;
  ReCreateFocusPen;
  FGridLineColor := clBtnFace;
  FGridLineWidth := 2;
  FLeftCol := 1;
  FMaxColumnWidth := 0;
  FMinColumnWidth := 150;
  FMultiSelect := False;
  FPageCount := 4;
  FReadOnly := False;
  FSelectedCard := nil;
  FSelectedCount := 0;
  FSelectedIndex := -1;
  FShowGridLine := True;
  FShowFocus := True;
  FShowScrollBar := True;
  FSorted := True;
  FSortSettings := TAdvCardSortSettings.Create;
  FSortSettings.OnSortChange := HandleSortSettingsChange;
  // Scroll bar
  ScrollBar := TScrollBar.Create(nil);
{$IFDEF DELPHI7_LVL}
  ScrollBar.ControlStyle := ScrollBar.ControlStyle - [csParentBackground];
{$ENDIF}
  ScrollBar.ParentShowHint := False;
  ScrollBar.ShowHint := False;
  ScrollBar.ParentCtl3D := False;
  ScrollBar.Parent := Self;
  ScrollBar.Name := 'ListHorScrollBar';
  ScrollBar.Min := 1;
  ScrollBar.PageSize := 1;
  ScrollBar.OnScroll := HandleScrBarScroll;
  ScrollBar.Align := alBottom;
  ScrollBar.Visible := False;
  //
  Width := 280;
  Height := 320;
  TabStop := False;
  FURLColor := clBlue;
  DoubleBuffered := False;
  CreateDesignCards;
end;

procedure TCustomAdvCardList.CreateWnd;
{
  function OnFrame: boolean;
  var
    wc: TWinControl;
  begin
    Result := false;
    wc := Parent;
    while Assigned(wc) do
    begin
      if (wc is TFrame) then
      begin
        Result := true;
        break;
      end;
      wc := wc.Parent;
    end;
  end;
}

begin
  inherited;
  if not (csLoading in ComponentState) and (csDesigning in ComponentState) then
  begin
    if Assigned(CardTemplate) and (CardTemplate.Items.Count = 0) then
      CardTemplate.Items.Add.Caption := 'DefaultItem';
  end;
end;

destructor TCustomAdvCardList.Destroy;
begin
  OldPen.Free;
  if FocusPen <> 0 then
    DeleteObject(FocusPen);
  FCardEditingAppearance.Free;
  FCardNormalAppearance.Free;
  FCardSelectedAppearance.Free;
  FCardHoverAppearance.Free;
  FCardTemplate.Items.FCards := nil;
  FCardTemplate.Free;
  Cards.Free;
  FColor.Free;
  FDspBMPChecked.Free;
  FDspBMPUnchecked.Free;
  FFilterSettings.Free;
  FSortSettings.Free;
  FSortedCards := nil;
  FInClientAreaCards := nil;
  ScrollBar.Free;
  DelayedCardLoadTimer.Free;
  DelayedCardLoadTimer := nil;
  inherited;
end;

procedure TCustomAdvCardList.CreateTemplate(Cards: TAdvCards);
begin
  FCardTemplate := TAdvCardTemplate.Create(Self, TAdvCardTemplateItems, TAdvCardTemplateItem);
  FCardTemplate.Items.FCards := Cards;
end;

procedure TCustomAdvCardList.Assign(Source: TPersistent);
begin
  if Source is TAdvCardList then
    with Source as TAdvCardList do
    try
      Self.BeginUpdate;
      Self.FInClientAreaCards := nil;
      Self.FSortedCards := nil;
      Self.FAutoEdit := AutoEdit;
      Self.FBorderColor := BorderColor;
      Self.FBorderWidth := BorderWidth;
      Self.FCardHorSpacing := CardHorSpacing;
      Self.FCardVertSpacing := CardVertSpacing;
      Self.FColumnSizing := ColumnSizing;
      Self.FColumnWidth := ColumnWidth;
      Self.FFiltered := Filtered;
      Self.FFocusColor := FocusColor;
      Self.FGridLineColor := GridLineColor;
      Self.FGridLineWidth := GridLineWidth;
      Self.FLeftCol := 0;
      Self.FColumns := 0;
      Self.FMaxColumnWidth := MaxColumnWidth;
      Self.FMinColumnWidth := MinColumnWidth;
      Self.FMultiSelect := MultiSelect;
      Self.FPageCount := PageCount;
      Self.FReadOnly := ReadOnly;
      Self.FSelectedCard := nil;
      Self.FSelectedCount := 0;
      Self.FSelectedIndex := -1;
      Self.FShowGridLine := ShowGridLine;
      Self.FShowFocus := ShowFocus;
      Self.FShowScrollBar := ShowScrollBar;
      Self.FSorted := Sorted;
    // objects
      Self.FColor.Assign(Color);
      Self.FCardNormalAppearance.Assign(CardNormalAppearance);
      Self.FCardHoverAppearance.Assign(CardHoverAppearance);
      Self.FCardSelectedAppearance.Assign(CardSelectedAppearance);
      Self.FCardEditingAppearance.Assign(CardEditingAppearance);
      Self.FCards.Clear;
      Self.FCardTemplate.Assign(CardTemplate);
      Self.FCards.Assign(Cards);
      Self.FSortSettings.Assign(SortSettings);
      Self.FFilterSettings.Assign(FilterSettings);
    finally
      Self.EndUpdate;
    end else inherited;
end;

procedure TCustomAdvCardList.BeginUpdate;
begin
  inc(FUpdateCount);
  DelayedCardLoadTimer.Enabled := False;
end;

procedure TCustomAdvCardList.EndUpdate;
begin
  dec(FUpdateCount);
  if FUpdateCount < 0 then FUpdateCount := 0;
  if FUpdateCount = 0 then
  begin
    UpdateCards(True, True, True, True);
    DelayedCardLoadTimer.Enabled := True;
  end;

end;

function TCustomAdvCardList.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn))) + '.' + IntToStr(Lo(Hiword(vn))) +
    '.' + IntToStr(Hi(Loword(vn))) + '.' + IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvCardList.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER, REL_VER), MakeWord(MIN_VER, MAJ_VER));
end;

procedure TCustomAdvCardList.SetVersion(const Value: string);
begin
  // readonly, do nothing
end;

procedure TCustomAdvCardList.SetURLColor(const Value: TColor);
begin
  FURLColor := Value;
  Invalidate;
end;

procedure TCustomAdvCardList.SetDelayedCardLoad(Value: Boolean);
begin
    FDelayedCardLoad := Value;
    DelayedCardLoadTimer.Enabled := Value;
end;

procedure TCustomAdvCardList.DelayedCardLoadTimerOnTimer(Sender: TObject);
var
  i : Integer;
begin
  if not FScrolling and Assigned(OnDelayedCardLoad) then
  begin //for all currently displayed cards
    for i := Low(FInClientAreaCards) to High(FInClientAreaCards) do
    begin
      //make sure the array did not change
      if (i >= Low(FInClientAreaCards)) and (i < High(FInClientAreaCards)) then
      begin
        OnDelayedCardLoad(Self,Cards.Items[FInClientAreaCards[i]]);
        Application.ProcessMessages
      end
      else
        break;
    end;
  end;
end;

procedure TCustomAdvCardList.SetDelayedCardLoadTimerInterval(Value: Integer);
begin
  if Assigned(DelayedCardLoadTimer) then
    DelayedCardLoadTimer.Interval := Value;
end;

function TCustomAdvCardList.GetDelayedCardLoadTimerInterval: Integer;
begin
  if Assigned(DelayedCardLoadTimer) then
    Result := DelayedCardLoadTimer.Interval
  else
    Result := 0;
end;

function TCustomAdvCardList.IsCardCurrentlyDisplayed(Card: TAdvCard): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Low(FInClientAreaCards) to High(FInClientAreaCards) do
    if FInClientAreaCards[i] = Card.Index then
    begin
      Result := True;
      Break;
    end;
end;


function TCustomAdvCardList.CardAtXY(x, y: Integer; OnlyViewed: Boolean): TAdvCard;
var
  n: Integer;

  function IsAt(Card: TAdvCard): Boolean;
  begin
    Result := Card.Visible and Card.Filtered and PtInRect(Card.FListRect, Point(x, y));
  end;

begin
  if OnlyViewed then
  begin
    for n := 0 to High(FInClientAreaCards) do
      if IsAt(Cards.Items[FInClientAreaCards[n]]) then
      begin
        Result := Cards.Items[FInClientAreaCards[n]];
        Exit;
      end;
  end else
  begin
    for n := 0 to Cards.Count - 1 do
      if IsAt(Cards.Items[n]) then
      begin
        Result := Cards.Items[n];
        exit;
      end;
  end;
  Result := nil;
end;

function TCustomAdvCardList.ItemAtXY(x, y: Integer; Card: TAdvCard): Integer;
var
  ItemN: Integer;
  Item: TAdvCardItem;
begin
  for ItemN := 0 to Card.ItemList.Count - 1 do
  begin
    Item := Card.ItemList[ItemN];
    if not Item.Hided and CardTemplate.Items[ItemN].Visible and
      PtInRect(Item.FUnitedListRect, Point(x, y)) then
    begin
      Result := ItemN;
      exit;
    end;
  end;
  Result := -1;
end;

procedure TCustomAdvCardList.Filter;
begin
  if csDesigning in ComponentState
    then DoFilter(False)
  else DoFilter(FFiltered);
  UpdateCards(False, True, False, False);
  if FGotoSelectedAutomatic then
    GoToSelected;
end;

procedure TCustomAdvCardList.SelectAll;
var
  CardN: Integer;
begin
  if FCards.Count > 0 then
  begin
    FCards.UpdateSelected := False;
    for CardN := 0 to FCards.Count - 1 do
      if FCards.Items[CardN].Filtered and FCards.Items[CardN].Visible
        then FCards.Items[CardN].Selected := True;
    FCards.UpdateSelected := True;
    Invalidate;
  end;
end;

procedure TCustomAdvCardList.DeselectAll;
var
  CardN: Integer;
  oldsel: Boolean;
begin
  FCards.UpdateSelected := False;
  for CardN := 0 to FCards.Count - 1 do
  begin
    oldsel := FCards.Items[CardN].Selected;
    FCards.Items[CardN].Selected := False;
    
    if not MultiSelect and oldsel then
      PaintCard(FCards.Items[CardN].Index);
  end;
  FSelectedIndex := -1;
  FSelectedCard := nil;
  FCards.UpdateSelected := True;
  if MultiSelect then
    Invalidate;
end;

procedure TCustomAdvCardList.Sort;
begin
  if csDesigning in ComponentState then
    DoSort(False)
  else
    DoSort(FSorted);
  UpdateCards(False, True, False, False);
  if FGotoSelectedAutomatic then
    GoToSelected;
end;

function TCustomAdvCardList.VisibleCardCount: Integer;
begin
  Result := Length(FInClientAreaCards);
end;

function TCustomAdvCardList.FindCard(BeginWith: string): TAdvCard;
var
  CardN: Integer;
  Card: TAdvCard;
  Str1, Str2: string;
begin
  Result := nil;
  for CardN := 0 to High(FSortedCards) do
  begin
    Card := Cards[FSortedCards[CardN]];
    if Card.Visible and Card.Filtered then
    begin
      if BeginWith = '' then
      begin
        Result := Card;
        Exit;
      end;
      if (Length(Card.Caption) > 0) then
      begin
        Str1 := Copy(BeginWith, 1, Length(BeginWith));
        Str2 := Copy(Card.Caption, 1, Length(Card.Caption));
        if AnsiStrLComp(AnsiStrUpper(PChar(Str1)), AnsiStrUpper(PChar(Str2)),
          Length(Str1)) = 0 then
        begin
          Result := Card;
          Exit;
        end;
      end;
    end;
  end; {for}
end;

function TCustomAdvCardList.GoToSelected: Boolean;
var
  OldLeftCol: Integer;
begin
  if Assigned(FSelectedCard) and (FSelectedCount = 1) and (FViewedColumns > 0) then
  begin
    OldLeftCol := FLeftCol;
    if (FSelectedCard.Column < FLeftCol)
      then LeftCol := FSelectedCard.Column
    else
    begin
      if (FSelectedCard.FCaptionListRect.Right > Width) then
      begin
        if (FSelectedCard.Column > FLeftCol + FViewedColumns - 1) then
          LeftCol := FSelectedCard.Column - FViewedColumns + 1;
      end
      else
      begin
        if (FSelectedCard.Column > FLeftCol + FViewedColumns) then
          LeftCol := FSelectedCard.Column - FViewedColumns + 1;
      end;
    end;    
    Result := OldLeftCol <> FLeftCol;
  end
  else
    Result := False;
end;

procedure TCustomAdvCardList.StartEdit(EditRect: TRect; CardIndex, ItemIndex: Integer; Value: Variant; StartChar: Char);
var
  TItem: TAdvCardTemplateItem;
  Pt: TPoint;
  Allow: Boolean;
  DDRect: TRect;
  h: Integer;
begin
  FEditMode := true;
  // Edit mode?

  if (StartChar <> #0) then
    Value := '' + StartChar;

  if Assigned(FEdControl) then
  begin
    // this item?
    if (FEdCardIndex = CardIndex) and (FEdItemIndex = ItemIndex) then Exit else
    begin
      ConvertTypeAndDoneEdit;
      StartEdit(EditRect, CardIndex, ItemIndex, Value, StartChar);
      Exit;
    end;
  end;

  TItem := CardTemplate.Items[ItemIndex];
  if FReadOnly or TItem.ReadOnly then
    Exit;

  Allow := True;

  if Assigned(FOnCardStartEdit) then
    FOnCardStartEdit(Self, CardIndex, ItemIndex, Allow);

  if not Allow then
    Exit;

  DDRect := EditRect;

  // when edit rectangle is too small for combo & datepicker, adapt ...
  if ((DDRect.Bottom - DDRect.Top) < 21) and (TItem.ItemEditor in [ieDropDownList,ieDropDownEdit]) then
  begin
    h := 21 - (DDRect.Bottom - DDRect.Top);
    DDRect.Top := DDRect.Top - (h div 2);
    DDRect.Bottom := DDRect.Bottom + (h div 2);
  end;

  FEdCardIndex := CardIndex;
  FEdItemIndex := ItemIndex;
  case TItem.ItemEditor of
  ieText:
    begin
      { Memo }
      if TItem.WordWrap then
      begin
        FEdControl := TMemo.Create(nil);
        FEdControlType := ctMemo;
        Cards[CardIndex].FEditing := True;
        Cards.ApplyAppearance(Cards[CardIndex]);
        with FEdControl as TMemo do
        begin
          SetBounds(EditRect.Left, EditRect.Top, EditRect.Right - EditRect.Left,
            EditRect.Bottom - EditRect.Top);
          Ctl3D := False;
          BorderStyle := bsNone;
          if TItem.EditColor <> clNone then
            Color := TItem.EditColor;

          if Cards[CardIndex].FAppearance.ReplaceEditFont
            then Font.Assign(Cards[CardIndex].FAppearance.FItemEditFont)
            else Font.Assign(TItem.ValueFont);
          Alignment := TItem.ValueAlignment;
          WordWrap := True;
          Text := Value;
          OnKeyDown := HandleControlKeyDown;
        end;
      end
      else
      { Edit }
      begin
        FEdControl := TEdit.Create(nil);
        FEdControlType := ctEdit;
        Cards[CardIndex].FEditing := True;
        Cards.ApplyAppearance(Cards[CardIndex]);
        with FEdControl as TEdit do
        begin
          AutoSize := False;
          SetBounds(EditRect.Left, EditRect.Top, EditRect.Right - EditRect.Left,
            EditRect.Bottom - EditRect.Top);
          Ctl3D := False;
          BorderStyle := bsNone;
          if TItem.EditColor <> clNone then
            Color := TItem.EditColor;
          if Cards[CardIndex].FAppearance.ReplaceEditFont then
            Font.Assign(Cards[CardIndex].FAppearance.FItemEditFont)
          else
            Font.Assign(TItem.ValueFont);
            
          Text := Value;
          OnKeyDown := HandleControlKeyDown;
        end;
      end;
    end;
  ieBoolean:
    if TItem.ItemEditor = ieBoolean then
    begin
      FEdControlType := ctCheckBox;

      if FEdByMouse then
      begin
        GetCursorPos(Pt);
        Pt := ScreenToClient(Pt);
        Allow := PtInRect(GetCheckBoxRect(
          Cards[CardIndex].ItemList[ItemIndex].FValueListRect,
          TItem.ValueAlignment, TItem.ValueLayout), Pt);
      end;

      if Allow then
        DoneEdit(not Cards[CardIndex].ItemList[ItemIndex].AsBoolean)
      else
        CancelEditing;
      Exit;
    end; {ieBoolean}
  ieDropDownlist, ieDropDownEdit:
    begin
      FEdControl := TComboBox.Create(nil);
      FEdControlType := ctComboBox;
      Cards[CardIndex].FEditing := True;
      Cards.ApplyAppearance(Cards[CardIndex]);
      with FEdControl as TComboBox do
      begin
        SetBounds(DDRect.Left, DDRect.Top, DDRect.Right - DDRect.Left,
          DDRect.Bottom - DDRect.Top);
        if TItem.EditColor <> clNone then
          Color := TItem.EditColor;
        Font.Assign(TItem.ValueFont);
        if TItem.ItemEditor = ieDropDownList
          then Style := csDropDownList
        else Style := csDropDown;
        OnKeyDown := HandleControlKeyDown;
      end;
    end; {ieDropDown}
  ieDate, ieTime:
    begin
      FEdControl := TDateTimePicker.Create(nil);
      FEdControlType := ctDateTimePicker;
      Cards[CardIndex].FEditing := True;
      Cards.ApplyAppearance(Cards[CardIndex]);
      with FEdControl as TDateTimePicker do
      begin
        SetBounds(DDRect.Left, DDRect.Top, DDRect.Right - DDRect.Left,
          DDRect.Bottom - DDRect.Top);
        if TItem.ItemEditor = ieTime then
        begin
          Kind := dtkTime;
          Time := Value;
        end else
        begin
          Kind := dtkDate;
          Date := Value;
        end;
        OnKeyDown := HandleControlKeyDown;
      end;
    end; {ieDateTime}
  ieCustom:
    begin
      if Assigned(TItem.ItemEditLink) then
      begin
        FEdControl := TItem.ItemEditLink.CreateControl;
        FEdControlType := ctCustom;
        Cards[CardIndex].FEditing := True;
        Cards.ApplyAppearance(Cards[CardIndex]);        

        FEdControl.SetBounds(DDRect.Left, DDRect.Top, DDRect.Right - DDRect.Left,
          DDRect.Bottom - DDRect.Top);
        TItem.ItemEditLink.ValueToControl(Value);
        TItem.ItemEditLink.OnKeyDown := HandleControlKeyDown;
        TItem.ItemEditLink.SetProperties;
      end;
    end;
  iePictureDialog:
    begin
      try
        FEdControlType := ctOpenPictureDialog;
        Cards[CardIndex].FEditing := True;
        Cards.ApplyAppearance(Cards[CardIndex]);
        Invalidate;
        FOpenPictDialog := TOpenPictureDialog.Create(Self);
        if FOpenPictDialog.Execute then
        begin
          Cards[CardIndex].ItemList[ItemIndex].Picture.LoadFromFile(FOpenPictDialog.FileName);
          if Assigned(FOnCardEndEdit) then
            FOnCardEndEdit(Self, CardIndex, ItemIndex);
        end;
      finally
        Cards[CardIndex].FEditing := False;
        Cards.ApplyAppearance(Cards[CardIndex]);
        if Assigned(FOpenPictDialog) then FreeAndNil(FOpenPictDialog);
      end;
    end; {iePictureDialog}
  ieNumber, ieFloat:
    begin
      FEdControl := TMaskEdit.Create(nil);
      FEdControlType := ctMaskEdit;
      Cards[CardIndex].FEditing := True;
      Cards.ApplyAppearance(Cards[CardIndex]);
      Invalidate;
      with FEdControl as TMaskEdit do
      begin
        AutoSize := False;
        SetBounds(EditRect.Left, EditRect.Top, EditRect.Right - EditRect.Left,
          EditRect.Bottom - EditRect.Top);
        Ctl3D := False;
        BorderStyle := bsNone;
        OnKeyDown := HandleControlKeyDown;
      end;
    end; {ieNumber, ieFloat}
  end;



  if Assigned(FEdControl) then
  begin
    DoubleBuffered := True;
    FEdControl.Parent := Self;
    case FEdControlType of
      ctEdit:
        begin
          TEdit(FEdControl).SetFocus;
          if StartChar <> #0 then
          begin
            TEdit(FEdControl).SelStart := 1;
            TEdit(FEdControl).SelLength := 0;
          end;
        end;
      ctMemo: TMemo(FEdControl).SetFocus;
      ctMaskEdit:
        with TMaskEdit(FEdControl) do
        begin
          if TItem.EditColor <> clNone then
            Color := TItem.EditColor;
          if Cards[CardIndex].FAppearance.ReplaceEditFont then
            Font.Assign(Cards[CardIndex].FAppearance.FItemEditFont)
          else
            Font.Assign(TItem.ValueFont);
          EditMask := String(TItem.Mask);
          Text := Value;
          SetFocus;
        end;
      ctCustom:
        begin
          TItem.ItemEditLink.SetFocus;
          if StartChar <> #0 then
            TItem.ItemEditLink.SetSelection(1,0);
        end;
      ctComboBox:
        with TComboBox(FEdControl) do
        begin
          Items.Assign(TItem.List);
          if Style = csDropDownList then
            ItemIndex := Items.IndexOf(Value)
          else
            Text := Value;
          SetFocus;

          if StartChar <> #0 then
          begin
            SelStart := 1;
            SelLength := 0;
          end;
        end;
      ctDateTimePicker:
        with TDateTimePicker(FEdControl) do
        begin
          if TItem.EditColor <> clNone then
            Color := TItem.EditColor;
          if Cards[CardIndex].FAppearance.ReplaceEditFont then
            Font.Assign(Cards[CardIndex].FAppearance.FItemEditFont)
          else
            Font.Assign(TItem.ValueFont);
          SetFocus;
        end;
    end; {case}
  end;

  Invalidate;
  DoubleBuffered := False;
end;

procedure TCustomAdvCardList.CancelEditing;
begin
  FEditMode := false;

  if Assigned(FEdControl) then
  begin
    DoubleBuffered := True;
    RemoveControl(FEdControl);
    FreeAndNil(FEdControl);
    if FEdCardIndex < Cards.Count then
    begin
      Cards[FEdCardIndex].FEditing := False;
      Cards.ApplyAppearance(Cards[FEdCardIndex]);
    end;
    DoubleBuffered := False;
    if Enabled and Visible then
    begin
      if not (csDestroying in Parent.ComponentState) then
        SetFocus;
    end;
  end;
end;

procedure TCustomAdvCardList.DoneEdit(Value: Variant);
begin
  case VarType(Value) and varTypeMask of
    varDate:
      if CardTemplate.Items[FEdItemIndex].DataType = idtTime then
        Cards[FEdCardIndex].ItemList[FEdItemIndex].AsTime := Value
      else
        Cards[FEdCardIndex].ItemList[FEdItemIndex].AsDate := Value;
    varBoolean:
      Cards[FEdCardIndex].ItemList[FEdItemIndex].AsBoolean := Value;
    varInteger:
      Cards[FEdCardIndex].ItemList[FEdItemIndex].AsInteger := Value;
    varDouble:
      Cards[FEdCardIndex].ItemList[FEdItemIndex].AsFloat := Value;
  else
    Cards[FEdCardIndex].ItemList[FEdItemIndex].AsString := Value;
  end;

  CancelEditing;

  if Assigned(FOnCardEndEdit) then
    FOnCardEndEdit(Self, FEdCardIndex, FEdItemIndex);

  Invalidate;
end;

procedure TCustomAdvCardList.UpdateCards(AClientRects, AListRects, ASort, AFilter: Boolean);
begin
  CancelEditing;
  if FUpdateCount > 0 then
    Exit;

  if ASort then
    if csDesigning in ComponentState then DoSort(False) else DoSort(FSorted);

  if AFilter then
    if csDesigning in ComponentState then DoFilter(False) else DoFilter(FFiltered);

  if AClientRects then Cards.CalcClientRects(nil);
  if AListRects then CalcListRects(nil, nil, True);
  if ASort or AFilter then
  begin
    if FGotoSelectedAutomatic then
    begin
      if not GoToSelected then
        Invalidate;
    end
    else
      Invalidate;
    end;
end;

function TCustomAdvCardList.AddToClientAreaCards(Card: TAdvCard; FirstTime: Boolean): Boolean;
begin
  if FirstTime then
    FInClientAreaCards := nil;
    
  if IsInClientArea(Card.FListRect) then
  begin
    SetLength(FInClientAreaCards, Length(FInClientAreaCards) + 1);
    FInClientAreaCards[High(FInClientAreaCards)] := Card.Index;
    Result := True;
  end else Result := False;
end;

procedure TCustomAdvCardList.ConvertTypeAndStartEdit(EditRect: TRect; CardIndex, ItemIndex: Integer; StartChar: Char);
begin
  case FCardTemplate.Items[ItemIndex].DataType of
    idtString, idtInteger, idtFloat:
      StartEdit(EditRect, CardIndex, ItemIndex, Cards[CardIndex].ItemList[ItemIndex].AsString, StartChar);
    idtBoolean: StartEdit(EditRect, CardIndex, ItemIndex, Cards[CardIndex].ItemList[ItemIndex].AsBoolean, StartChar);
    idtTime: StartEdit(EditRect, CardIndex, ItemIndex, Cards[CardIndex].ItemList[ItemIndex].AsTime, StartChar);
    idtDate: StartEdit(EditRect, CardIndex, ItemIndex, Cards[CardIndex].ItemList[ItemIndex].AsDate, StartChar);
    idtImage: StartEdit(EditRect, CardIndex, ItemIndex, '', StartChar);
  end;
end;

procedure TCustomAdvCardList.ConvertTypeAndDoneEdit;
begin
  if Assigned(FEdControl) then
  begin
    case FEdControlType of
    ctEdit: DoneEdit(TEdit(FEdControl).Text);
    ctMemo: DoneEdit(TMemo(FEdControl).Text);
    ctMaskEdit: DoneEdit(TMaskEdit(FEdControl).Text);
    ctCheckBox: DoneEdit(TCheckBox(FEdControl).Checked);
    ctComboBox: DoneEdit(TComboBox(FEdControl).Text);
    ctCustom: DoneEdit(CardTemplate.Items[FEdItemIndex].ItemEditLink.ControlToValue);
    ctDateTimePicker:
      if CardTemplate.Items[FEdItemIndex].DataType = idtTime then
        DoneEdit(VarAsType(TDateTimePicker(FEdControl).Time, varDate))
      else
        DoneEdit(VarAsType(TDateTimePicker(FEdControl).Date, varDate));
    end;
  end;
end;

procedure TCustomAdvCardList.UpdateScrollBar;
var
  OldVis, Need: Boolean;
begin
  if (csDesigning in ComponentState) then
    Exit;
  OldVis := ScrollBar.Visible;
  Need := FCanvasRight - FCanvasLeft > Width;
  ScrollBar.Visible := FShowScrollBar and Need;
  if FColumns > 0 then
    ScrollBar.Max := FColumns;
  if FLeftCol <= ScrollBar.Max then
    ScrollBar.Position := FLeftCol;
  if OldVis <> ScrollBar.Visible then
    CalcListRects(nil, nil, False);
end;

procedure TCustomAdvCardList.OnScroll(var ScrollPos: Integer; ScrollCode: TScrollCode);
begin
  if FLeftCol <> ScrollPos then
  begin
    LeftCol := ScrollPos;
  end;
end;

procedure TCustomAdvCardList.DefaultValueChanged(TItem: TAdvCardTemplateItem);
var
  CardN: Integer;
  Item: TAdvCardItem;
begin
  if (csDesigning in ComponentState) and Assigned(Cards) then
    for CardN := 0 to Cards.Count - 1 do
    begin
      if Assigned(Cards[CardN].ItemList) then
        if TItem.Index < Cards[CardN].ItemList.Count then
        begin
          Item := Cards[CardN].ItemList[TItem.Index];
          case Item.DataType of
            idtImage:
              try
                Item.Picture.LoadFromFile(TItem.DefaultValue);
              except
                on Exception do
                  if Assigned(Item.Picture.Graphic) then Item.Picture.Graphic := nil;
              end;
          else
            Item.AsString := TItem.DefaultValue;
          end;
        end;
    end;
end;

procedure TCustomAdvCardList.DoCardListChange;
begin
  UpdateCards(False, True, False, False);
end;

procedure TCustomAdvCardList.HandleControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  OldControl: TControl;
  OldCard, OldItem: Integer;
begin
  OldControl := FEdControl;
  OldCard := FEdCardIndex;
  OldItem := FEdItemIndex;
  KeyDown(Key, Shift);
  if (OldControl <> FEdControl) or (OldCard <> FEdCardIndex) or
    (OldItem <> FEdItemIndex) then Abort;
end;

procedure TCustomAdvCardList.HandleScrBarScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  if ScrollCode = scEndScroll then
    FScrolling := false
  else
    FScrolling := true;
  OnScroll(ScrollPos, ScrollCode);
end;

function TCustomAdvCardList.IsInClientArea(const Rect: TRect): Boolean;
begin
  Result := (Rect.Left < Width) and (Rect.Right > 0);
end;

function TCustomAdvCardList.GetEditing: Boolean;
begin
  Result := Assigned(FEdControl);
end;

procedure TCustomAdvCardList.SetMouseOverCard(CardIndex: Integer);
begin
  // remove state from prev. hover card
  if (FHoverCardIndex >= 0) and (FHoverCardIndex < Cards.Count) then
  begin
    Cards.Items[FHoverCardIndex].FMouseOver := False;
    Cards.ApplyAppearance(Cards.Items[FHoverCardIndex]);
  end;
  // set state to the new card
  if (CardIndex >= 0) and (CardIndex < Cards.Count) then
  begin
    FHoverCardIndex := CardIndex;
    Cards.Items[CardIndex].FMouseOver := True;
    Cards.ApplyAppearance(Cards.Items[CardIndex]);
  end else FHoverCardIndex := -1;
end;

procedure TCustomAdvCardList.SetBorderColor(Value: TColor);
begin
  if Value <> FBorderColor then
  begin
    FBorderColor := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetBorderWidth(Value: Integer);
begin
  if Value <> FBorderWidth then
  begin
    FBorderWidth := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetCardNormalAppearance(Value: TAdvCardAppearance);
begin
  FCardNormalAppearance.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetCardHoverAppearance(Value: TAdvCardAppearance);
begin
  FCardHoverAppearance.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetCardSelectedAppearance(Value: TAdvCardAppearance);
begin
  FCardSelectedAppearance.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetCardEditingAppearance(Value: TAdvCardAppearance);
begin
  FCardEditingAppearance.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetCardHorSpacing(Value: Integer);
begin
  if Value <> FCardHorSpacing then
  begin
    FCardHorSpacing := Value;
    FColumnWidth := FCardTemplate.CardWidth + FCardHorSpacing * 2;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetCardTemplate(Value: TAdvCardTemplate);
begin
  FCardTemplate.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetCardVertSpacing(Value: Integer);
begin
  if Value <> FCardVertSpacing then
  begin
    FCardVertSpacing := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetColor(Value: TAdvGradient);
begin
  FColor.Assign(Value);
  DoCardListChange;
end;

procedure TCustomAdvCardList.SetColumnSizing(Value: Boolean);
begin
  if Value <> FColumnSizing then
  begin
    FColumnSizing := Value;
  end;
end;

procedure TCustomAdvCardList.SetColumnWidth(Value: Integer);

  procedure CheckConstraints;
  begin
    if (FMinColumnWidth <> 0) and (Value < FMinColumnWidth) then Value := FMinColumnWidth
    else if (FMaxColumnWidth <> 0) and (Value > FMaxColumnWidth) then Value := FMaxColumnWidth
    else if (Value - FCardHorSpacing * 2) < 0 then Value := FCardHorSpacing * 2;
  end;

begin
  if Value <> FColumnWidth then
  begin
    CheckConstraints;
    if Assigned(FOnColumnResizing) then FOnColumnResizing(Self, Value);
    CheckConstraints;
    FColumnWidth := Value;
    FCardTemplate.CardWidth := FColumnWidth - FCardHorSpacing * 2;
  end;
end;

procedure TCustomAdvCardList.SetFiltered(Value: Boolean);
begin
  if Value <> FFiltered then
  begin
    FFiltered := Value;
    Filter;
  end;
end;

procedure TCustomAdvCardList.SetFilterSettings(Value: TAdvCardFilterSettings);
begin
  FFilterSettings.Assign(Value);
  Filter;
end;

procedure TCustomAdvCardList.SetFocusColor(Value: TColor);
begin
  if Value <> FFocusColor then
  begin
    FFocusColor := Value;
    ReCreateFocusPen;
    Invalidate;
  end;
end;

procedure TCustomAdvCardList.SetGridLineColor(Value: TColor);
begin
  if Value <> FGridLineColor then
  begin
    FGridLineColor := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetGridLineWidth(Value: Integer);
begin
  if Value <> FGridLineWidth then
  begin
    FGridLineWidth := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetLeftCol(Value: Integer);
begin
  if Value <> FLeftCol then
  begin
    if Value < 1 then
      Value := 1;
    if Value > FColumns then
      Value := FColumns;
    ShiftListRects((FLeftCol - Value) * FColumnWidth);
    FLeftCol := Value;
    if (FColumns - FLeftCol + 1) * FColumnWidth <= Width then
      FViewedColumns := FColumns - FLeftCol + 1
    else
      FViewedColumns := Width div FColumnWidth;
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TCustomAdvCardList.SetMaxColumnWidth(Value: Integer);
begin
  if Value <> FMaxColumnWidth then
  begin
    if Value <> 0 then
    begin
      if (FMinColumnWidth <> 0) and (Value < FMinColumnWidth) then Value := FMinColumnWidth;
      if Value < FCardHorSpacing * 2 then Value := FCardHorSpacing * 2;
      if (FMinColumnWidth <> 0) and (FMinColumnWidth > Value) then FMinColumnWidth := Value;
      FMaxColumnWidth := Value;
      if FColumnWidth > Value then ColumnWidth := Value;
    end else FMaxColumnWidth := Value;
  end;
end;

procedure TCustomAdvCardList.SetMinColumnWidth(Value: Integer);
begin
  if Value <> FMinColumnWidth then
  begin
    if Value <> 0 then
    begin
      if (FMaxColumnWidth <> 0) and (Value > FMaxColumnWidth) then Value := FMaxColumnWidth;
      if Value < FCardHorSpacing * 2 then Value := FCardHorSpacing * 2;
      if (FMaxColumnWidth <> 0) and (FMaxColumnWidth < Value) then FMaxColumnWidth := Value;
      FMinColumnWidth := Value;
      if FColumnWidth < Value then ColumnWidth := Value;
    end else FMinColumnWidth := Value;
  end;
end;

procedure TCustomAdvCardList.SetMultiSelect(Value: Boolean);
begin
  if Value <> FMultiSelect then
  begin
    FMultiSelect := Value;
    if not Value then DeSelectAll;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetPageCount(Value: Integer);
begin
  if Value <> FPageCount then
  begin
    if Value <= 0 then Value := 1;
    FPageCount := Value;
  end;
end;

procedure TCustomAdvCardList.SetReadOnly(Value: Boolean);
begin
  if Value <> FReadOnly then
  begin
    FReadOnly := Value;
  end;
end;

procedure TCustomAdvCardList.SetSelectedIndex(Value: Integer);
begin
  if Value <> FSelectedIndex then
  begin
    if (Value < 0) or (Value > Cards.Count - 1) or (Cards.Count = 0) then
    begin
      FSelectedIndex := -1;
      FSelectedCard := nil;
      Exit;
    end;
    DeselectAll;
    FSelectedIndex := Value;

    Cards.Items[FSelectedIndex].Selected := True;
  end;
end;

procedure TCustomAdvCardList.SetShowGridLine(Value: Boolean);
begin
  if Value <> FShowGridLine then
  begin
    FShowGridLine := Value;
    DoCardListChange;
  end;
end;

procedure TCustomAdvCardList.SetShowFocus(Value: Boolean);
begin
  if Value <> FShowFocus then
  begin
    FShowFocus := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvCardList.SetShowScrollBar(Value: Boolean);
begin
  if Value <> FShowScrollBar then
  begin
    FShowScrollBar := Value;
    UpdateScrollBar;
  end;
end;

procedure TCustomAdvCardList.SetSorted(Value: Boolean);
begin
  if Value <> FSorted then
  begin
    FSorted := Value;
    Sort;
  end;
end;

procedure TCustomAdvCardList.SetSortSettings(Value: TAdvCardSortSettings);
begin
  FSortSettings.Assign(Value);
  Sort;
end;

procedure TCustomAdvCardList.CMHintShow(var Message: TMessage);
var
  PHI: PHintInfo;
begin
  PHI := TCMHintShow(Message).HintInfo;
  if FHoverCardIndex > -1 then
  begin
    // -2 - caption
    // -1 - no item (space between items)
    // >= 0 - item
    if (FOverItemIndex > -1) then
    begin
      if CardTemplate.Items[FOverItemIndex].ShowHint then
        PHI^.HintStr := Cards[FHoverCardIndex].ItemList[FOverItemIndex].Hint
    end else
      if FOverItemIndex = -2 then PHI^.HintStr := Cards[FHoverCardIndex].Hint;
  end;
end;

procedure TCustomAdvCardList.CMMouseLeave(var Message: TMessage);
begin
  if FHoverCardIndex <> -1 then
  begin
    SetMouseOverCard(-1);
    Invalidate;
  end;
  
  if not FGridLineDragging then
  begin
    FCursorOverGridLine := False;
    Screen.Cursor := crDefault;
  end;

  inherited;
end;

procedure TCustomAdvCardList.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS;
end;

procedure TCustomAdvCardList.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
//  if Assigned(FEdControl) and (FEdControl is TWinControl) then
//    TWinControl(FEdControl).SetFocus;

  // if no card is selected, make sure to select the first one
  if (Cards.Count > 0) and (SelectedIndex < 0) then
  begin
    SelectedIndex := 0;
    if (Cards[0].ItemList.Count > 0) and (Cards[0].SelectedItem < 0) then
      Cards[0].SelectedItem := 0;
  end;
  Invalidate;
end;

procedure TCustomAdvCardList.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TCustomAdvCardList.SelectCard(CardIndex: Integer; Select: Boolean);
begin
  if (Cards.Count > 0) and (CardIndex >= 0) and (CardIndex < Cards.Count) then
  begin
    Cards.Items[CardIndex].Selected := Select;
  end;
end;

function TCustomAdvCardList.CalcListRects(Card, AfterCard: TAdvCard; DoCheckScroll: Boolean): TCalcListRectsResult;
var
  FromX, FromY, ItemN, PrevN,
    OldLeftTopCard, n: Integer;
  OldFocus: Boolean;
  Res: TCalcListRectsResult;
  TItem: TAdvCardTemplateItem;
  Item: TAdvCardItem;

  procedure CardRectToListRect(CardRect: TRect; var ListRect: TRect);
  begin
    ListRect := Bounds(Card.FListRect.Left + CardRect.Left,
      Card.FListRect.Top + CardRect.Top,
      CardRect.Right - CardRect.Left,
      CardRect.Bottom - CardRect.Top);
  end;

begin
{$IFDEF DELPHI7_LVL}
  OldFocus := false;
{$ENDIF}  
  Result := clrSkipped;

  if Card <> nil then
  begin
    if not Card.FFiltered or not Card.FVisible then
      Exit;

    if AfterCard <> nil then
    begin
      FromX := AfterCard.FListRect.Left;
      FromY := AfterCard.FListRect.Bottom + FCardVertSpacing;
    end
    else
    begin
      FromX := FCanvasLeft + FCardHorSpacing;
      FromY := FCardVertSpacing;
    end;

    if ScrollBar.Visible then
      n := ScrollBar.Height + 2 else n := 0;

    if (FromY + (Card.FClientRect.Bottom - Card.FClientRect.Top) >= Height - n) and
      (AfterCard <> nil) then
    // wrap
    begin
      Card.FListRect := Bounds(FromX + CardTemplate.CardWidth + FCardHorSpacing * 2,
        FCardVertSpacing, CardTemplate.CardWidth, Card.FHeight);
      Result := clrNextColumn;
    end else
    // continue the column
    begin
      Card.FListRect := Bounds(FromX, FromY, CardTemplate.CardWidth, Card.FHeight);
      Result := clrFollowed;
    end;

    CardRectToListRect(Card.FCaptionCardRect, Card.FCaptionListRect);

    for ItemN := 0 to Card.ItemList.Count - 1 do
    begin
      TItem := FCardTemplate.Items[ItemN];
      Item := Card.ItemList[ItemN];
      if (not TItem.Visible) or Item.FHided then continue;
      CardRectToListRect(Item.FLabelCardRect, Item.FLabelListRect);
      CardRectToListRect(Item.FValueCardRect, Item.FValueListRect);
      Item.FUnitedListRect := Item.FLabelListRect;
      Item.FUnitedListRect.Right := Item.FValueListRect.Right;
    end;
  end
  else
  // card = nil - loop for all cards
  begin
    ConvertTypeAndDoneEdit;
    SetMouseOverCard(-1);
    FColumns := 0;
    FViewedColumns := 0;
    FCanvasRight := 0;
    FCanvasLeft := 0;
    if FGridLineDragging then
      OldLeftTopCard := FOldLeftTopCard
    else
      if Length(FInClientAreaCards) > 0 then
        OldLeftTopCard := FInClientAreaCards[0]
      else
        if FSelectedIndex >= 0 then
          OldLeftTopCard := FSelectedIndex
        else
          OldLeftTopCard := 0;
          
    FInClientAreaCards := nil;
    if Cards.Count = 0 then
      Exit;

    PrevN := -1;
    // find first card for displaying
    for n := 0 to High(FSortedCards) do
      if CalcListRects(Cards.Items[FSortedCards[n]], nil, False) <> clrSkipped then
      begin
        PrevN := n;
        FColumns := 1;
        Cards.Items[FSortedCards[n]].FColumn := FColumns;
        Inc(FCanvasRight, FColumnWidth);
        AddToClientAreaCards(Cards.Items[FSortedCards[n]], True);
        break;
      end;
    // found and not last card
    if (PrevN <> -1) and (PrevN < High(FSortedCards)) then
      for n := PrevN + 1 to High(FSortedCards) do
      begin
        Res := CalcListRects(Cards.Items[FSortedCards[n]], Cards.Items[FSortedCards[PrevN]], False);
        if Res <> clrSkipped then
        begin
          PrevN := n;
          if Res = clrNextColumn then
          begin
            Inc(FColumns);
            Inc(FCanvasRight, FColumnWidth);
          end;
          Cards.Items[FSortedCards[n]].FColumn := FColumns;
          AddToClientAreaCards(Cards.Items[FSortedCards[n]], False);
        end;
      end; {for n}
    if FColumns <= (Width div FColumnWidth) then
    begin
      FLeftCol := 1;
      Dec(FCanvasRight, FCanvasLeft);
      FCanvasLeft := 0;
      FViewedColumns := FColumns;
      UpdateScrollBar;
    end else
    begin
      ShiftListRects(-(Cards[OldLeftTopCard].FListRect.Left - FCardHorSpacing));
      FLeftCol := Cards[OldLeftTopCard].FColumn;
{$IFDEF DELPHI7_LVL}
      if not ThemeServices.ThemesEnabled then
{$ENDIF}
      begin
        OldFocus := ScrollBar.Focused;
        if OldFocus then ScrollBar.Enabled := False;
      end;
      if (FColumns - FLeftCol + 1) * FColumnWidth <= Width
        then FViewedColumns := FColumns - FLeftCol + 1
      else FViewedColumns := Width div FColumnWidth;
{$IFDEF DELPHI7_LVL}
      if not ThemeServices.ThemesEnabled then
{$ENDIF}
        if OldFocus then
        begin
          ScrollBar.Enabled := True;
          if ScrollBar.Visible then ScrollBar.SetFocus;
        end;
      if DoCheckScroll then UpdateScrollBar;
    end;
  end;
end;

procedure TCustomAdvCardList.DataChanged(Card: TAdvCard; Item: TAdvCardItem; DataObject: TDataChangedObject);
begin
  // do nothing. For DB version overriding
end;

procedure TCustomAdvCardList.SelectedChanged;
begin
  // do nothing. For DB version overriding
end;

procedure TCustomAdvCardList.ColumnSized;
begin
  // do nothing. For DB version overriding
end;

procedure TCustomAdvCardList.ShiftListRects(Value: Integer);
var
  n, ItemN: Integer;
  Card: TAdvCard;
  Item: TAdvCardItem;

  procedure ShiftRect(var R: TRect);
  begin
    Inc(R.Left, Value);
    Inc(R.Right, Value);
  end;

begin
  if Value <> 0 then
  begin
    ConvertTypeAndDoneEdit;
    SetMouseOverCard(-1);
    if FCanvasLeft + Value > 0 then Value := -FCanvasLeft;
    if FCanvasRight + Value < 0 then Value := -FCanvasRight;
    Inc(FCanvasLeft, Value);
    Inc(FCanvasRight, Value);
    for n := 0 to high(FSortedCards) do
    begin
      Card := Cards.Items[FSortedCards[n]];
      if Card.FFiltered and Card.FVisible then
      begin
        ShiftRect(Card.FCaptionListRect);
        for ItemN := 0 to Card.ItemList.Count - 1 do
        begin
          Item := Card.ItemList[ItemN];
          if not FCardTemplate.Items[ItemN].Visible or
            Item.FHided then continue;
          ShiftRect(Item.FLabelListRect);
          ShiftRect(Item.FValueListRect);
          Item.FUnitedListRect := Item.FLabelListRect;
          Item.FUnitedListRect.Right := Item.FValueListRect.Right;
        end;
        ShiftRect(Card.FListRect);
        AddToClientAreaCards(Card, n = 0);
      end;
    end;
  end;
end;

procedure TCustomAdvCardList.Click;
var
  OldCard, Card: TAdvCard;
  OldItemN, ItemN, OldVColumn, X, Y, i: Integer;
  Pt: TPoint;
  R: TRect;
  Default, DoDblClick: boolean;
  url: string;
  CardItemID: Integer;

begin
  if FGridLineDragging then
    Exit;

  GetCursorPos(Pt);
  Pt := ScreenToClient(Pt);
  X := Pt.x;
  Y := Pt.y;
  Card := CardAtXY(X, Y, True);

  ItemN := -1;

  if Assigned(Card) then
  begin
    CardItemID := Card.ID;

    if Assigned(FOnCardClick) then
      FOnCardClick(Self, Card);

    if PtInRect(Card.FCaptionListRect, Pt) then
    begin
      if Assigned(FOnCardCaptionClick) then
        FOnCardCaptionClick(Self, Card);
    end                              
    else
    begin
      ItemN := ItemAtXY(X, Y, Card);
      if ItemN >= 0 then
      begin

        if (CardTemplate.Items[ItemN].ValueURLType <> utNone) and
           (Card.ItemList[ItemN].AsString <> '') and
           (InValueRect(X, Card, CardTemplate.Items[ItemN], Card.ItemList[ItemN])) then
        begin
          Default := true;

          try
            if Assigned(OnCardItemURLClick) then
              OnCardItemURLClick(Self, Card.Index, ItemN, Card.ItemList[ItemN].AsString, Default);
          except
            Exit;
          end;

          if Default then
          begin
            case CardTemplate.Items[ItemN].ValueURLType of
            utHTTP: url := 'http://' + Card.ItemList[ItemN].AsString;
            utHTTPS: url := 'https://' + Card.ItemList[ItemN].AsString;
            utFTP: url := 'ftp://' + Card.ItemList[ItemN].AsString;
            utMailTo: url := 'mailto:' + Card.ItemList[ItemN].AsString;
            utNNTP: url := 'ftp://' + Card.ItemList[ItemN].AsString;
            utLink: url := Card.ItemList[ItemN].AsString;
            end;

            ShellExecute(0,'open',pchar(url),nil,nil, SW_NORMAL);
          end;
        end;

        if Assigned(FOnCardItemClick) then
          FOnCardItemClick(Self, Card.Index, ItemN);
      end;
    end;

    // Card selecting
    if FMultiSelect and ((GetKeyState(VK_CONTROL) < 0) or (GetKeyState(VK_SHIFT) < 0))  then
    begin
      CancelEditing;

      if GetKeyState(VK_CONTROL) < 0 then //handle ctrl selection
        SelectCard(Card.Index, not Card.Selected)
      else
      if GetKeyState(VK_SHIFT) < 0 then //handle shift select
      begin
        OldCard := FSelectedCard;
        if OldCard.Index <= Card.Index then //if shift selecting up
        begin
          for i := OldCard.Index + 1 to Card.Index do //add one as to not change old card selection
            SelectCard(i, not Cards[i].Selected);
        end
        else
        begin
          for i:=Card.Index to OldCard.Index-1 do //substract one as to not change old card selection
            SelectCard(i, not Cards[i].Selected);
        end
      end;

      //SelectCard(Card.Index, not Card.Selected);
    end
    else
    // Single select
    begin
      OldCard := FSelectedCard;
      if Assigned(OldCard) then
        OldItemN := OldCard.SelectedItem
      else
        OldItemN := -1;
        
      Cards.UpdateSelected := False;

      if ItemN >= 0 then
      begin
        if Assigned(OldCard) and (OldCard.FEditing) and
          not ((OldCard = Card) and (ItemN = OldItemN)) and (OldItemN >= 0) then
          begin
            ConvertTypeAndDoneEdit;
            Card := CardAtXY(X, Y, True);
          end;
      end else
      // not item but card
      if Assigned(OldCard) and OldCard.FEditing then
      begin
        ConvertTypeAndDoneEdit;
        Card := SelectedCard;
      end;

      DoDblClick := (Card = OldCard) and (ItemN = OldItemN) and (ItemN >= 0);

      DeselectAll;

      ItemN := ItemAtXY(X, Y, Card);

      // select clicked and scroll if part view
      OldVColumn := Card.Column - FLeftCol;
      Pt := Point(X - Card.FListRect.Left, Y - Card.FListRect.Top);

      Card.Selected := True;

      // PaintCard(Card.Index);

      // after selecting pointer may be wrong (DB Version)
      Card := SelectedCard;
      if Card.Column - FLeftCol <> OldVColumn then
      begin
        Pt.x := Pt.x + Card.FListRect.Left;
        Pt.y := Pt.y + Card.FListRect.Top;
        Pt := ClientToScreen(Pt);
        //SetCursorPos(Pt.x, Pt.y);
      end;

      if ItemN >= 0 then
      begin
        // image edit on DblClick
        if FAutoEdit and (CardTemplate.Items[ItemN].DataType <> idtImage) then
        begin
          FEdByMouse := True;
          R := Card.ItemList[ItemN].FValueListRect;
          ConvertTypeAndStartEdit(R, Card.Index, ItemN, #0);
        end;
        // item maybe hided after edit
        if Assigned(Cards.FindItemID(CardItemID)) then
          if not Card.ItemList[ItemN].Hided then
            Card.SelectedItem := ItemN;
      end else

      Cards.UpdateSelected := True;

      if DoDblClick then
        DblClick;
        
    end;
  end { if Assigned(Card) }
  else
    if Assigned(FSelectedCard) then
    begin
      if FSelectedCard.FEditing then ConvertTypeAndDoneEdit;
      FSelectedCard.SelectedItem := -1;
    end;

  inherited;
end;

procedure TCustomAdvCardList.DblClick;
var
  Pt: TPoint;
  Card: TAdvCard;
  ItemN: Integer;
begin
  FDblClick := true;
  GetCursorPos(Pt);
  Pt := ScreenToClient(Pt);
  Card := CardAtXY(Pt.x, Pt.y, True);

  if Assigned(Card) then
  begin
    ItemN := ItemAtXY(Pt.x, Pt.y, Card);

    if Assigned(FOnCardDblClick) then
      FOnCardDblClick(Self, Card);

    if PtInRect(Card.FCaptionListRect, Pt) then
    begin
      if Assigned(FOnCardCaptionDblClick) then
        FOnCardCaptionDblClick(Self, Card);
    end
    else
    begin
      if (ItemN >= 0) and ((CardTemplate.Items[ItemN].DataType = idtImage) or
        not FAutoEdit) then
      begin
        FEdByMouse := True;
        ConvertTypeAndStartEdit(Card.ItemList[ItemN].FValueListRect, Card.Index, ItemN, #0);
      end;
    end;
  end;
  inherited;
end;

procedure TCustomAdvCardList.DrawItemCaption(Canvas: TCanvas; Card: TAdvCard; ItemIndex: Integer; Preview: Boolean);
var
  S: string;
  R: TRect;
  TItem: TAdvCardTemplateItem;
  DrawFlags: Cardinal;
begin
  TItem := CardTemplate.Items[ItemIndex];

  S := TItem.Caption;
  if (S = '') and (csDesigning in ComponentState) then S := SDesignNoItemCaption;
  R := Card.ItemList[ItemIndex].FLabelListRect;

  If Preview then
    OffsetRect(R, -Card.FListRect.Left + Card.Appearance.MergedBorderWidth,
                  -Card.FListRect.Top + Card.Appearance.MergedBorderWidth);

  if Card.FAppearance.ReplaceLabelFont
    then Canvas.Font.Assign(Card.FAppearance.ItemLabelFont)
  else Canvas.Font.Assign(TItem.FCaptionFont);
  Canvas.Brush.Color := TItem.FCaptionColor;
  if Canvas.Brush.Color <> clNone then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(R);
  end;
  Canvas.Brush.Style := bsClear;
  DrawFlags := DT_SINGLELINE;

  case TItem.CaptionAlignment of
    taLeftJustify: DrawFlags := DrawFlags or DT_LEFT;
    taRightJustify: DrawFlags := DrawFlags or DT_RIGHT;
    taCenter: DrawFlags := DrawFlags or DT_CENTER;
  end;

  case TItem.CaptionLayout of
    tlTop: DrawFlags := DrawFlags or DT_TOP;
    tlBottom: DrawFlags := DrawFlags or DT_BOTTOM;
    tlCenter: DrawFlags := DrawFlags or DT_VCENTER;
  end;

  DrawFlags := DrawFlags or DT_END_ELLIPSIS;

  DrawText(Canvas.Handle, PCHAR(S), Length(S), R, DrawFlags);
end;

procedure TCustomAdvCardList.DrawItemValue(Canvas: TCanvas; Card: TAdvCard; ItemIndex: Integer; Preview: boolean);
var
  BMP: Graphics.TBitmap;
  S: string;
  R, DestR, SrcR: TRect;
  DrawFlags: Cardinal;
  X, Y, NewWidth, NewHeight: Integer;
  TItem: TAdvCardTemplateItem;
  Item: TAdvCardItem;

begin
  X := 0;
  Y := 0;

  if Card.Editing and (Card.SelectedItem = ItemIndex) and
    (Card.ItemList[ItemIndex].DataType <> idtImage) then exit;

  R := Card.ItemList[ItemIndex].FValueListRect;

  If Preview then
    OffsetRect(R, -Card.FListRect.Left + Card.Appearance.MergedBorderWidth,
                  -Card.FListRect.Top + Card.Appearance.MergedBorderWidth);

  TItem := CardTemplate.Items[ItemIndex];
  Item := Card.ItemList[ItemIndex];

  if (TItem.DataType = idtBoolean) and Assigned(FDspBMPChecked) and
    Assigned(FDspBMPUnchecked) then
  begin
    R := GetCheckBoxRect(R, TItem.ValueAlignment, TItem.FValueLayout);
    if R.Left + FCheckBoxSize <= Item.FValueListRect.Right then
      if Item.AsBoolean then
        Canvas.Draw(R.Left, R.Top, FDspBMPChecked)
      else
        Canvas.Draw(R.Left, R.Top, FDspBMPUnchecked);
  end {idtBoolean}
  else
    if (TItem.DataType = idtImage) then
    begin
      if (Assigned(Item.FPicture.Graphic) and not Item.FPicture.Graphic.Empty) then
        case TItem.ImageSize of
          isOriginal:
            begin
              case TItem.ValueAlignment of
                taLeftJustify: X := R.Left;
                taRightJustify: X := R.Right - Item.FPicture.Width;
                taCenter: X := R.Left + ((R.Right - R.Left) - Item.FPicture.Width) div 2;
              end;

              case TItem.ValueLayout of
                tlBottom: Y := R.Bottom - Item.FPicture.Height;
                tlTop: Y := R.Top;
                tlCenter: Y := R.Top + ((R.Bottom - R.Top) - Item.FPicture.Height) div 2;
              end;

        // need for clipping
              if (X < R.Left) or (Y < R.Top) or (X + Item.FPicture.Width > R.Right) or
                (Y + Item.FPicture.Height > R.Bottom) then
              begin
                try
                  if (X < R.Left) or (X + Item.FPicture.Width > R.Right) then
                  begin
                    DestR.Left := R.Left;
                    DestR.Right := R.Right;
                    SrcR.Left := R.Left - X;
                    SrcR.Right := SrcR.Left + (R.Right - R.Left);
                  end else
                  begin
                    DestR.Left := X;
                    DestR.Right := X + Item.FPicture.Width;
                    SrcR.Left := 0;
                    SrcR.Right := Item.FPicture.Width;
                  end;

                  if (Y < R.Top) or (Y + Item.FPicture.Height > R.Bottom) then
                  begin
                    DestR.Top := R.Top;
                    DestR.Bottom := R.Bottom;
                    SrcR.Top := R.Top - Y;
                    SrcR.Bottom := SrcR.Top + (R.Bottom - R.Top);
                  end else
                  begin
                    DestR.Top := Y;
                    DestR.Bottom := Y + Item.FPicture.Height;
                    SrcR.Top := 0;
                    SrcR.Bottom := Item.FPicture.Height;
                  end;

                  BMP := TBitmap.Create;
                  BMP.Width := SrcR.Right - SrcR.Left;
                  BMP.Height := SrcR.Bottom - SrcR.Top;
                  BMP.Canvas.StretchDraw(SrcR,Item.FPicture.Graphic);

                  if TItem.TransparentImage then
                  begin
                    BMP.TransparentMode := tmAuto;
                    BMP.Transparent := true;
                  end;  

                  Canvas.Draw(DestR.Left, DestR.Top, BMP);
                  //Canvas.CopyRect(DestR, BMP.Canvas, SrcR);
                finally
                  if Assigned(BMP) then FreeAndNil(BMP);
                end;
              end
               else Canvas.Draw(X, Y, Item.FPicture.Graphic);
            end;
          isStretched:
      // TIcon can not be stretched. Force.
            if Item.FPicture.Graphic is TIcon then
            try
              BMP := TBitmap.Create;
              BMP.Width := Item.FPicture.Width;
              BMP.Height := Item.FPicture.Height;
              BMP.Canvas.Draw(0, 0, Item.FPicture.Graphic);
              Canvas.CopyRect(R, BMP.Canvas, Bounds(0, 0, BMP.Width, BMP.Height));
            finally
              if Assigned(BMP) then FreeAndNil(BMP);
            end else Canvas.StretchDraw(R, Item.FPicture.Graphic);
          isStretchedProp:
            begin
              NewWidth := R.Right - R.Left;

              if Item.FPicture.Width <> 0 then
                NewHeight := Round(Item.FPicture.Height * ((NewWidth) / Item.FPicture.Width))
              else
                NewHeight := Item.FPicture.Height;

              if NewHeight > R.Bottom - R.Top then
              begin
                NewHeight := R.Bottom - R.Top;
                if Item.FPicture.Height <> 0 then
                  NewWidth := Round(Item.FPicture.Width * (NewHeight / Item.FPicture.Height));

                Y := R.Top;
                case TItem.ValueAlignment of
                  taLeftJustify: X := R.Left;
                  taRightJustify: X := R.Right - NewWidth;
                  taCenter: X := R.Left + (R.Right - R.Left - NewWidth) div 2;
                end;
              end else
              begin
                X := R.Left;
                case TItem.ValueLayout of
                  tlBottom: Y := R.Bottom - NewHeight;
                  tlTop: Y := R.Top;
                  tlCenter: Y := R.Top + (R.Bottom - R.Top - NewHeight) div 2;
                end;
              end;
        // TIcon can not be stretched. Force.
              if Item.FPicture.Graphic is TIcon then
              try
                BMP := TBitmap.Create;
                BMP.Width := Item.FPicture.Width;
                BMP.Height := Item.FPicture.Height;
                BMP.Canvas.Draw(0, 0, Item.FPicture.Graphic);
                Canvas.CopyRect(Bounds(X, Y, NewWidth, NewHeight), BMP.Canvas, Bounds(0, 0, BMP.Width, BMP.Height));
              finally
                if Assigned(BMP) then FreeAndNil(BMP);
              end
              else
              begin
                try
                  BMP := TBitmap.Create;
                  BMP.Width := NewWidth;
                  BMP.Height := NewHeight;
                  BMP.Canvas.StretchDraw(Bounds(0, 0, NewWidth, NewHeight), Item.FPicture.Graphic);
                  if TItem.TransparentImage then
                  begin
                    BMP.TransparentMode := tmAuto;
                    BMP.Transparent := true;
                  end;
                  Canvas.Draw(X,Y, BMP);
                finally
                  if Assigned(BMP) then FreeAndNil(BMP);
                end;
                //Canvas.StretchDraw(Bounds(X, Y, NewWidth, NewHeight), Item.FPicture.Graphic);
              end;
            end;
        end; {case TItem.ImageSize}
    end else
  // convert rest types to String
    begin
      S := Item.AsString;
      if (S = '') and (csDesigning in ComponentState) then
        S := SDesignNoItemDefValue;

      S := TItem.Prefix + S + TItem.Suffix;

      if Assigned(FOnCardItemGetDisplText) then
        FOnCardItemGetDisplText(Self, Card.Index, ItemIndex, S);

      if Card.FAppearance.ReplaceEditFont and Card.Editing and not TItem.ReadOnly then
        Canvas.Font.Assign(Card.FAppearance.FItemEditFont)
      else
      begin
        Canvas.Font.Assign(TItem.FValueFont);
        if TItem.ValueURLType <> utNone then
        begin
          Canvas.Font.Color := URLColor;
          Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
        end;
      end;
        
      Canvas.Brush.Color := TItem.FValueColor;
      if Canvas.Brush.Color <> clNone then
      begin
        Canvas.Brush.Style := bsSolid;
        Canvas.FillRect(R);
      end;
      Canvas.Brush.Style := bsClear;

      if TItem.FWordWrap then
        DrawFlags := DT_WORDBREAK
      else
        DrawFlags := DT_SINGLELINE;

      case TItem.ValueAlignment of
        taLeftJustify: DrawFlags := DrawFlags or DT_LEFT;
        taRightJustify: DrawFlags := DrawFlags or DT_RIGHT;
        taCenter: DrawFlags := DrawFlags or DT_CENTER;
      end;

      case TItem.ValueLayout of
        tlTop: DrawFlags := DrawFlags or DT_TOP;
        tlBottom: DrawFlags := DrawFlags or DT_BOTTOM;
        tlCenter: DrawFlags := DrawFlags or DT_VCENTER;
      end;

      if Assigned(FOnDrawCardItemProp) then FOnDrawCardItemProp(Self, Card,
        Item, Canvas.Font, Canvas.Brush);

      DrawFlags := DrawFlags or DT_END_ELLIPSIS;  

      DrawText(Canvas.Handle, PCHAR(S), Length(S), R, DrawFlags);
    end;
end;

procedure TCustomAdvCardList.DrawCard(Canvas: TCanvas; Card: TAdvCard; Preview: Boolean);
var
  S: string;
  ItemN, n, delta: Integer;
  R: TRect;
  DrawFlags: Cardinal;
  TopColor, BottomColor: TColor;
  OffsX, OffsY, BordWidth: Integer;

  procedure AdjustColors(Bevel: TBevelCut);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  if not Card.FFiltered or not Card.FVisible or not Assigned(Card.FAppearance) then
    Exit;

  R := Card.FListRect;

  if Preview then
  begin
    BordWidth := Card.Appearance.MergedBorderWidth;
    OffsX := -R.Left + BordWidth;
    OffsY := -R.Top + BordWidth;
  end
  else
  begin
    OffsX := 0;
    OffsY := 0;
  end;

  if Preview then
    OffsetRect(R, OffsX, OffsY);

  // background
  Card.FAppearance.Color.Draw(Canvas, R);

  R := Card.FCaptionListRect;
  if Preview then
    OffsetRect(R, OffsX, OffsY);

  // caption
  Card.FAppearance.CaptionColor.Draw(Canvas, R);

  Canvas.Font.Assign(Card.FAppearance.CaptionFont);
  Canvas.Brush.Style := bsClear;
  S := Card.Caption;

  if Assigned(FOnCardCaptionGetDisplText) then
    FOnCardCaptionGetDisplText(Self, Card.Index, S);

  R := Card.FCaptionListRect;

  if Preview then
    OffsetRect(R, OffsX, OffsY);

  Inc(R.Left, Card.FAppearance.CaptionBorderWidth + 2);
  Dec(R.Right, Card.FAppearance.CaptionBorderWidth + 2);
  DrawFlags := DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;

  case CardTemplate.CardCaptionAlignment of
    taLeftJustify: DrawFlags := DrawFlags or DT_LEFT;
    taRightJustify: DrawFlags := DrawFlags or DT_RIGHT;
    taCenter: DrawFlags := DrawFlags or DT_CENTER;
  end;

  if Assigned(Images) and (Card.ImageIndex >= 0) then
  begin
    // center vertically...
    delta := CardTemplate.CardCaptionHeight - Images.Height;

    if delta > 0 then
      delta := delta div 2
    else
      delta := 0;

    Images.Draw(Canvas, R.Left, R.Top + delta, Card.ImageIndex);

    R.Left := R.Left + Images.Width + 2;
  end;

  DrawText(Canvas.Handle, PCHAR(S), Length(S), R, DrawFlags);

  // card border
  R := Card.FListRect;

  if Preview then
    OffsetRect(R, OffsX, OffsY);

  n := 0;

  if Card.FAppearance.BevelOuter <> bvNone then
    Inc(n, Card.FAppearance.FBevelWidth);

  Inc(n, Card.FAppearance.BorderWidth);

  if Card.FAppearance.BevelInner <> bvNone then
    Inc(n, Card.FAppearance.FBevelWidth);
  InflateRect(R, n, n);
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;

  if Card.FAppearance.BevelOuter <> bvNone then
  begin
    AdjustColors(Card.FAppearance.BevelOuter);
    Frame3D(Canvas, R, TopColor, BottomColor, Card.FAppearance.FBevelWidth);
  end;

  if Card.FAppearance.BorderColor <> clNone then
  begin
    Frame3D(Canvas, R, Card.FAppearance.BorderColor,
      Card.FAppearance.BorderColor, Card.FAppearance.BorderWidth);
  end;

  if Card.FAppearance.BevelInner <> bvNone then
  begin
    AdjustColors(Card.FAppearance.BevelInner);
    Frame3D(Canvas, R, TopColor, BottomColor, Card.FAppearance.BevelWidth);
  end;
  // caption border
  if Card.FAppearance.CaptionBorderColor <> clNone then
  begin
    Canvas.Pen.Color := Card.FAppearance.CaptionBorderColor;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psSolid;
    Canvas.Brush.Style := bsClear;
    R := Card.FCaptionListRect;
    if Preview then
      OffsetRect(R, OffsX, OffsY);

    for n := 0 to Card.FAppearance.CaptionBorderWidth - 1 do
      Canvas.Rectangle(R.Left + n, R.Top + n, R.Right - n, R.Bottom - n);
  end;

  // draw all items
  for ItemN := 0 to Card.ItemList.Count - 1 do
  begin
    if CardTemplate.Items[ItemN].Visible and not Card.ItemList[ItemN].FHided then
    begin
      if CardTemplate.Items[ItemN].CustomDraw and
        not (csDesigning in ComponentState) then
      begin
        if Assigned(FOnDrawCardItem) then
          FOnDrawCardItem(Self, Card, Card.ItemList[ItemN], Canvas,
            Card.ItemList[ItemN].FUnitedListRect);
      end else
      begin
        DrawItemCaption(Canvas, Card, ItemN, Preview);
        DrawItemValue(Canvas, Card, ItemN, Preview);
      end;
    end;
  end;  

  // draw focus rect
  ItemN := -1;
  if (csDesigning in ComponentState) then
  begin
    for n := 0 to CardTemplate.Items.Count - 1 do
      if CardTemplate.Items[n].Visible then
      begin
        ItemN := n;
        break;
      end;
  end
  else
  if (Card.ItemList.Count > 0) and
      FShowFocus and
     (Card.SelectedItem >= 0) and
     (Card.SelectedItem < Card.ItemList.Count) then ItemN := Card.SelectedItem;

  if ItemN >= 0 then
  begin
    R := Card.ItemList[ItemN].FLabelListRect;
    
    if Preview then
      OffsetRect(R, OffsX, OffsY);

    R.Left := Card.FListRect.Left + 1 + OffsX;
    R.Right := Card.FListRect.Right - 1 + OffsY;
    Dec(R.Top);
    Inc(R.Bottom);
    Canvas.Brush.Style := bsClear;
    OldPen.Assign(Canvas.Pen);
    SelectObject(Canvas.Handle, FocusPen);
    if (GetFocus = self.Handle) or (Editing) then
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
    SelectObject(Canvas.Handle, OldPen.Handle);
  end;
end;

procedure TCustomAdvCardList.DoFilter(Filtered: Boolean);
var
  CardN: Integer;
begin
  if Filtered then
  begin
    if (FFilterSettings.FilterIndex >= CardTemplate.Items.Count) or
      (FFilterSettings.FilterIndex < 0) then
    begin
      DoFilter(False);
      exit;
    end;
    // lock updates
    inc(FUpdateCount);
    for CardN := 0 to Cards.Count - 1 do
    begin
      Cards[CardN].FFiltered := Pos(AnsiUpperCase(FFilterSettings.FilterCondition),
        AnsiUpperCase(Cards[CardN].ItemList[FFilterSettings.FilterIndex].AsString)) > 0;
      Cards.CalcClientRects(Cards[CardN]);
      if not Cards[CardN].FFiltered and Cards[CardN].Selected then
        Cards[CardN].Selected := False;
    end;
    dec(FUpdateCount);
  end else
  // all are filtered
    for CardN := 0 to Cards.Count - 1 do
    begin
      Cards.Items[CardN].FFiltered := True;
      Cards.CalcClientRects(Cards[CardN]);
    end;
end;

procedure TCustomAdvCardList.CreateDesignCards;
const
  AppNames: array[0..3] of string = ('Normal',
    'Hover',
    'Selected',
    'Editing');
var
  CardN: Integer;

begin
  // Create 4 cards for each appearance designtime drawing
  if csDesigning in ComponentState then
  begin
    for CardN := 0 to 3 do
      with Cards.Add as TAdvCard do
      begin
        case CardN of
          0: FAppearance := FCardNormalAppearance;
          1: FAppearance := FCardHoverAppearance;
          2: FAppearance := FCardSelectedAppearance;
          3: FAppearance := FCardEditingAppearance;
        end;
        Caption := AppNames[CardN];
      end;
  end;
end;

procedure TCustomAdvCardList.ReCreateFocusPen;
begin
  if FocusPen <> 0 then DeleteObject(FocusPen);
  FocusPenBrush.lbColor := FFocusColor;
  FocusPenBrush.lbStyle := BS_SOLID;
  FocusPen := ExtCreatePen(PS_COSMETIC or PS_ALTERNATE, 1, FocusPenBrush, 0, nil);
end;

procedure TCustomAdvCardList.Paint;
var
  n, x: Integer;
  R: TRect;
  BMP: TBitMap;
  DrawCanvas: TCanvas;
begin
  inherited;

  R := ClientRect;
  if ScrollBar.Visible then
    Dec(R.Bottom, ScrollBar.Height);

  BMP := nil;
  
  if not DoubleBuffered then
  begin
    BMP := TBitMap.Create;
    BMP.Width := Width;
    BMP.Height := R.Bottom + 1;
    DrawCanvas := BMP.Canvas;
  end else
    DrawCanvas := Canvas;

  with DrawCanvas do
  begin
    // background
    FColor.Draw(DrawCanvas, R);
    // draw cards
    for n := 0 to High(FInClientAreaCards) do
      DrawCard(DrawCanvas, Cards.Items[FInClientAreaCards[n]], False);
    // column grid
    if FShowGridLine and (FGridLineWidth > 0) then
    begin
      Pen.Width := FGridLineWidth;
      Pen.Color := FGridLineColor;
      Pen.Style := psSolid;
      for n := 1 to FColumns do
      begin
        x := FCanvasLeft + FColumnWidth * n;
        if x < 0 then continue;
        if x > ClientWidth then break;
        MoveTo(x, FBorderWidth);
        LineTo(x, R.Bottom);
      end;
    end;
    // border
    if FBorderWidth > 0 then
    begin
      Pen.Color := FBorderColor;
      Pen.Width := 1;
      Pen.Style := psSolid;
      Brush.Style := bsClear;
      for n := 0 to FBorderWidth - 1 do
        Rectangle(n, n, R.Right - n, R.Bottom - n);
    end;
  end;

  if not DoubleBuffered then
  begin
    if Editing then ExcludeClipRect(Canvas.Handle, FEdControl.Left, FEdControl.Top,
      FEdControl.Left + FEdControl.Width, FEdControl.Top + FEdControl.Height);
    Canvas.Draw(0, 0, BMP);
    BMP.Free;
  end;
end;

procedure TCustomAdvCardList.Resize;
var
  OldFocus: Boolean;
begin
{$IFDEF DELPHI7_LVL}
  OldFocus := false;
  if not ThemeServices.ThemesEnabled then
{$ENDIF}
  begin
    OldFocus := ScrollBar.Focused;
    if OldFocus then ScrollBar.Enabled := False;
  end;
  inherited;
  CalcListRects(nil, nil, True);
  if FGotoSelectedAutomatic then
    GoToSelected;
  Invalidate;
{$IFDEF DELPHI7_LVL}
  if not ThemeServices.ThemesEnabled then
{$ENDIF}
    if OldFocus then
    begin
      ScrollBar.Enabled := True;
      if ScrollBar.Visible then ScrollBar.SetFocus;
    end;
end;

procedure TCustomAdvCardList.DoSort(Sorted: Boolean);
var
  CardN, Card2N: Integer;
  ItemIndex: Integer;
  TItem: TAdvCardTemplateItem;
  Item1, Item2: TAdvCardItem;
  Res: Integer; // -1  less, 0 equal, 1 more

  procedure Exchange(N1, N2: Integer);
  var
    I: Integer;
  begin
    I := FSortedCards[N1];
    FSortedCards[N1] := FSortedCards[N2];
    FSortedCards[N2] := I;
  end;

begin
  SetLength(FSortedCards, Cards.Count);

  if Sorted then
  begin
    DoSort(False);
    Res := 0;
    TItem := nil;

    ItemIndex := FSortSettings.SortIndex;

    if (FSortSettings.SortType = stNone) then
      Exit;

    if (FSortSettings.SortType = stItem) and ((ItemIndex < 0) or (ItemIndex >= CardTemplate.Items.Count)) then
      Exit;

    if (FSortSettings.SortType = stItem) then
    begin
      TItem := CardTemplate.Items[ItemIndex];

      if TItem.DataType = idtImage then
        Exit;
    end;
      
    for CardN := 0 to Cards.Count - 2 do
      for Card2N := CardN + 1 to Cards.Count - 1 do
      begin

        case FSortSettings.SortType of
        stCaption:
          begin
            if FSortSettings.CaseSensitive then
              Res := AnsiCompareStr(Cards[FSortedCards[Card2N]].Caption , Cards[FSortedCards[CardN]].Caption)
            else
              Res := AnsiCompareText(Cards[FSortedCards[Card2N]].Caption , Cards[FSortedCards[CardN]].Caption);
          end;
        stCustom:
          begin
            if Assigned(FOnCardCompare) then
              FOnCardCompare(self,Cards[FSortedCards[Card2N]],Cards[FSortedCards[CardN]], res);
          end;
        stItem:
          begin
            Item1 := Cards[FSortedCards[CardN]].ItemList[ItemIndex];
            Item2 := Cards[FSortedCards[Card2N]].ItemList[ItemIndex];

            case TItem.DataType of
              idtBoolean:
                if Item2.AsBoolean > Item1.AsBoolean then Res := 1 else
                  if Item2.AsBoolean = Item1.AsBoolean then Res := 0 else
                    Res := -1;
              idtDate:
                if Int(Item2.AsDate) > Int(Item1.AsDate) then Res := 1 else
                  if Int(Item2.AsDate) = Int(Item1.AsDate) then Res := 0 else
                    Res := -1;
              idtFloat:
                if Item2.AsFloat > Item1.AsFloat then Res := 1 else
                  if Item2.AsFloat = Item1.AsFloat then Res := 0 else
                    Res := -1;
              idtInteger:
                if Item2.AsInteger > Item1.AsInteger then Res := 1 else
                  if Item2.AsInteger = Item1.AsInteger then Res := 0 else
                    Res := -1;
              idtString:
                 if FSortSettings.CaseSensitive then
                   Res := AnsiCompareStr(Item2.AsString, Item1.AsString)
                 else
                   Res := AnsiCompareText(Item2.AsString, Item1.AsString);
              idtTime:
                if Frac(Item2.AsDate) > Frac(Item1.AsDate) then Res := 1 else
                  if Frac(Item2.AsDate) = Frac(Item1.AsDate) then Res := 0 else
                    Res := -1;
            end;
          end;
        end;

        case FSortSettings.SortDirection of
          sdAscending: if Res < 0 then Exchange(CardN, Card2N);
          sdDescending: if Res > 0 then Exchange(CardN, Card2N);
        end;
      end; {for}
  end
  else
    // unsorted
    for CardN := 0 to Cards.Count - 1 do FSortedCards[CardN] := CardN;
end;

function TCustomAdvCardList.JumpToCard(Offset: Integer; ToBegin, ToEnd: Boolean): Boolean;
var
  n, n2: Integer;
begin
  Result := False;

  if ToBegin then
  begin
    for n := 0 to high(FSortedCards) do
      if Cards[FSortedCards[n]].Filtered and Cards[FSortedCards[n]].Visible then
      begin
        if FSelectedIndex = FSortedCards[n] then
          Exit;
        SetSelectedIndex(FSortedCards[n]);
        Result := True;
        break;
      end
  end {ToBegin} else
    if ToEnd then
    begin
      for n := high(FSortedCards) downto 0 do
        if Cards[FSortedCards[n]].Filtered and Cards[FSortedCards[n]].Visible then
        begin
          if FSelectedIndex = FSortedCards[n] then
            Exit;
          SetSelectedIndex(FSortedCards[n]);
          Result := True;
          break;
        end
    end {ToEnd} else
      for n := 0 to high(FSortedCards) do
        if FSortedCards[n] = FSelectedIndex then
        begin
          if (n + offset >= high(FSortedCards)) and (FSelectedIndex <> high(FSortedCards)) then
          begin
            Result := JumpToCard(0, False, True);
            Exit;
          end;
          if (n + offset <= 0) and (FSelectedIndex <> 0) then
          begin
            Result := JumpToCard(0, True, False);
            Exit;
          end;

          n2 := n + (Abs(Offset) div Offset);
          Offset := Abs(Offset);
          while ((n2 > n) and (n2 <= high(FSortedCards))) or ((n2 < n) and (n2 >= 0)) do
          begin
            if Cards[FSortedCards[n2]].Filtered and Cards[FSortedCards[n2]].Visible then
            begin
              dec(Offset);
              if Offset = 0 then
              begin
                SetSelectedIndex(FSortedCards[n2]);
                Result := True;
                break;
              end;
            end;
            if n2 < n then dec(n2) else inc(n2);
          end;
          break;
        end; {if FSortedCards[n] = FSelectedIndex}
end;

function TCustomAdvCardList.JumpToItem(Offset: Integer; ToBegin, ToEnd: Boolean): Boolean;
var
  n, n2: Integer;
begin
  Result := False;
  if ToBegin then
  begin
    for n := 0 to Cards[FSelectedIndex].ItemList.Count - 1 do
      if CardTemplate.Items[n].Visible and not Cards[FSelectedIndex].ItemList[n].Hided then
      begin
        Cards[FSelectedIndex].SelectedItem := n;
        Result := True;
        break;
      end
  end {ToBegin} else
    if ToEnd then
    begin
      for n := Cards[FSelectedIndex].ItemList.Count - 1 downto 0 do
        if CardTemplate.Items[n].Visible and not Cards[FSelectedIndex].ItemList[n].Hided then
        begin
          Cards[FSelectedIndex].SelectedItem := n;
          Result := True;
          break;
        end
    end {ToEnd} else {By offset}
    begin
      n := Cards[FSelectedIndex].SelectedItem;
      if (offset = 0) or ((offset < 0) and (n = 0)) or
        ((offset > 0) and (n = Cards[FSelectedIndex].ItemList.Count - 1)) then exit;
      if n + offset >= Cards[FSelectedIndex].ItemList.Count - 1 then
      begin
        Result := JumpToItem(0, False, True);
        exit;
      end;
      if n + offset <= 0 then
      begin
        Result := JumpToItem(0, True, False);
        exit;
      end;
      n2 := n + (Abs(Offset) div Offset);
      Offset := Abs(Offset);
      while ((n2 > n) and (n2 <= Cards[FSelectedIndex].ItemList.Count - 1)) or ((n2 < n) and (n2 >= 0)) do
      begin
        if CardTemplate.Items[n2].Visible and not Cards[FSelectedIndex].ItemList[n2].Hided then
        begin
          dec(Offset);
          if Offset = 0 then
          begin
            Cards[FSelectedIndex].SelectedItem := n2;
            Result := True;
            break;
          end;
        end;
        if n2 < n then dec(n2) else inc(n2);
      end; {while}
    end;
end;

procedure TCustomAdvCardList.Notification(AComponent: TComponent;
  AOperation: TOperation);
var
  i: Integer;
begin
  inherited;
  if not (csDestroying in ComponentState) then
  begin
    if (AOperation = opRemove) then
    begin
      if (AComponent = FImages) then
        FImages := nil;

      for i := 1 to CardTemplate.Items.Count do
      begin
        if (CardTemplate.Items[i - 1].ItemEditLink = AComponent) then
          CardTemplate.Items[i - 1].ItemEditLink := nil;
      end;
    end;
  end;
end;


procedure TCustomAdvCardList.KeyDown(var Key: Word; Shift: TShiftState);
var
  ItemN: Integer;
  OldSelectedItem: Integer;
begin
  case Key of
    $41: //handle ctrl-a select all when multiselect active
      begin
        if (ssCtrl in Shift) and MultiSelect then
          SelectAll;
      end;
    VK_ESCAPE:
      begin
        if Editing then
          CancelEditing
        else
          if FSelectedIndex >= 0 then
            Cards[FSelectedIndex].SelectedItem := -1;
        Invalidate;
      end;
    VK_UP:
      if not (Editing and ((FEdControlType = ctComboBox)
        or (FEdControlType = ctMemo)
        or (FEdControlType = ctDateTimePicker))) then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            ConvertTypeAndDoneEdit;
            if not JumpToItem(-1, False, False) then
              if JumpToCard(-1, False, False) then JumpToItem(0, False, True);
          end else
      // No, only card
          begin
            JumpToCard(-1, False, False);
          end;
        end;
    VK_DOWN:
      if not (Editing and ((FEdControlType = ctComboBox)
        or (FEdControlType = ctMemo)
        or (FEdControlType = ctDateTimePicker))) then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            ConvertTypeAndDoneEdit;
            if not JumpToItem(1, False, False) then
              if JumpToCard(1, False, False) then JumpToItem(0, True, False);
          end else
      // No, only card
          begin
            JumpToCard(1, False, False);
          end;
        end;
    VK_RIGHT:
      if not Editing then
        if FSelectedIndex >= 0 then
        begin
          OldSelectedItem := FSelectedCard.SelectedItem;
          if JumpToCard(1, False, False) then SelectedCard.SelectedItem := OldSelectedItem;
        end else JumpToCard(1, False, False);
    VK_LEFT:
      if not Editing then
        if FSelectedIndex >= 0 then
        begin
          OldSelectedItem := FSelectedCard.SelectedItem;
          if JumpToCard(-1, False, False) then SelectedCard.SelectedItem := OldSelectedItem;
        end else JumpToCard(-1, False, False);
    VK_PRIOR: {PageUp}
      if not (Editing and (FEdControlType = ctMemo)) then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            ConvertTypeAndDoneEdit;
            if not JumpToItem(-FPageCount, False, False) then
              if JumpToCard(-1, False, False) then JumpToItem(0, False, True);
          end else
      // No, only card
          begin
            JumpToCard(-FPageCount, False, False);
          end;
        end;
    VK_NEXT: {PageDown}
      if not (Editing and (FEdControlType = ctMemo)) then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            ConvertTypeAndDoneEdit;
            if not JumpToItem(FPageCount, False, False) then
              if JumpToCard(1, False, False) then JumpToItem(0, True, False);
          end else
      // No, only card
          begin
            JumpToCard(FPageCount, False, False);
          end;
        end;
    VK_HOME:
      if not Editing then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            if Cards[FSelectedIndex].SelectedItem <> 0 then
            begin
              ConvertTypeAndDoneEdit;
              Cards[FSelectedIndex].SelectedItem := 0;
            end;
          end else
      // No, only card
          begin
            JumpToCard(0, True, False);
          end;
        end;
    VK_END:
      if not Editing then
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            if Cards[FSelectedIndex].SelectedItem <> Cards[FSelectedIndex].ItemList.Count - 1 then
            begin
              ConvertTypeAndDoneEdit;
              Cards[FSelectedIndex].SelectedItem := Cards[FSelectedIndex].ItemList.Count - 1;
            end;
          end else
      // No, only card
          begin
            JumpToCard(0, False, True);
          end;
        end;
    VK_RETURN:
      if Editing and not ((FEdControlType = ctMemo) and (Shift = [])) then
        ConvertTypeAndDoneEdit
      else
        if FSelectedIndex >= 0 then
        begin
      // Is item selected?
          if Cards[FSelectedIndex].SelectedItem >= 0 then
          begin
            ItemN := Cards[FSelectedIndex].SelectedItem;
            FEdByMouse := False;
            ConvertTypeAndStartEdit(Cards[FSelectedIndex].ItemList[ItemN].FValueListRect,
              FSelectedIndex, ItemN, #0);
          end else JumpToItem(0, True, False);
        end;
  end; {case}
  inherited;
end;

procedure TCustomAdvCardList.LocateByChar(Key: Char);
var
  CardN, FromCardN: Integer;
  Item: TAdvCardItem;

  function FindMatch(FromCardN, ToCardN: Integer): Boolean;
  var
    ItemN, CardN, FromItemN: Integer;
  begin
    Result := False;
    for CardN := FromCardN to ToCardN do
    begin
      if Cards[FSortedCards[CardN]].Visible and
        Cards[FSortedCards[CardN]].Filtered then
      begin

        // search in caption
        if CardN <> FromCardN then
          if (Cards[FSortedCards[CardN]].Caption <> '') and
            (Pos(AnsiUpperCase(Key),
            AnsiUpperCase(Cards[FSortedCards[CardN]].Caption)) = 1) then
          begin
            SelectedIndex := FSortedCards[CardN];
            Result := True;
            Exit;
          end;

        // search in items
        FromItemN := Cards[FSortedCards[CardN]].SelectedItem + 1;
        for ItemN := FromItemN to Cards[FSortedCards[CardN]].ItemList.Count - 1 do
        begin
          Item := Cards[FSortedCards[CardN]].ItemList[ItemN];
          if not Item.Hided and CardTemplate.Items[ItemN].Visible and
            (Pos(AnsiUpperCase(Key), AnsiUpperCase(Item.AsString)) = 1) then
          begin
            SelectedIndex := FSortedCards[CardN];
            SelectedCard.SelectedItem := ItemN;
            Result := True;
            Exit;
          end;
        end;
      end;
    end;
  end;

begin
  if Cards.Count = 0 then Exit;
  FromCardN := 0;
  if not Editing then
  begin
    // find first card for searching
    for CardN := 0 to high(FSortedCards) do
      if Cards[FSortedCards[CardN]].Visible and
        Cards[FSortedCards[CardN]].Filtered then
        if (FSelectedIndex >= 0) then
        begin
          if (FSortedCards[CardN] = FSelectedIndex) then
          begin
            FromCardN := CardN;
            break;
          end;
        end else
        begin
          FromCardN := CardN;
          break;
        end;
    // search from first card to the end
    if not FindMatch(FromCardN, High(FSortedCards)) then
      FindMatch(0, FromCardN - 1);
  end; {if not Editing}
end;

procedure TCustomAdvCardList.KeyPress(var Key: Char);
var
  ItemN: Integer;
  DirEdit: Boolean;
begin
  inherited;

  DirEdit := false;

  if not Editing and (FSelectedIndex >= 0) then
    if Cards[FSelectedIndex].SelectedItem >= 0 then
    begin
      ItemN := Cards[FSelectedIndex].SelectedItem;
      DirEdit := CardTemplate.Items[ItemN].DirectEdit;
    end;


  if not DirEdit then
    LocateByChar(Key)
  else
    if (Key in ['a'..'z','A'..'Z','0'..'9']) then
    begin
      if not Editing and (FSelectedIndex >= 0) then
      begin
        if Cards[FSelectedIndex].SelectedItem >= 0 then
        begin
          ItemN := Cards[FSelectedIndex].SelectedItem;
          FEdByMouse := False;
          ConvertTypeAndStartEdit(Cards[FSelectedIndex].ItemList[ItemN].FValueListRect,
            FSelectedIndex, ItemN, Key);
         end;
      end;
    end;
end;

function TCustomAdvCardList.GetCheckBoxRect(ValueListRect: TRect;
  Align: TItemAlignment; Layout: TItemLayout): TRect;
begin
  case Layout of
    tlTop: Result.Top := ValueListRect.Top;
    tlBottom: Result.Top := ValueListRect.Bottom - FCheckBoxSize;
    tlCenter: Result.Top := ValueListRect.Top + (ValueListRect.Bottom - ValueListRect.Top - FCheckBoxSize) div 2;
  end;
  Result.Bottom := Result.Top + FCheckBoxSize;

  case Align of
    taLeftJustify: Result.Left := ValueListRect.Left;
    taRightJustify: Result.Left := ValueListRect.Right - FCheckBoxSize;
    taCenter: Result.Left := ValueListRect.Left + (ValueListRect.Right - ValueListRect.Left - FCheckBoxSize) div 2;
  end;
  Result.Right := Result.Left + FCheckBoxSize;
end;

procedure TCustomAdvCardList.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Card: TAdvCard;
  ItemN: Integer;
begin
  inherited;

  if FDblCLick then
  begin
    FDblClick := false;
    Exit;
  end;

  if (Button = mbRight) then
  begin
    Card := CardAtXY(X, Y, True);
    if Assigned(Card) then
    begin
      if Assigned(OnCardRightClick) then
        OnCardRightClick(Self, Card);

      ItemN := ItemAtXY(X, Y, Card);
      if ItemN >= 0 then
      begin
        if Assigned(OnCardItemRightClick) then
          OnCardItemRightClick(Self, Card.Index, ItemN);
      end;
    end;
  end;

  if not Focused and Enabled then
    SetFocus;

  // column sizing
  if FCursorOverGridLine then
  begin
    FPressedAtX := X;
    FOldColumnWidth := FColumnWidth;
    FOldLeftTopCard := FInClientAreaCards[0];
    FSilentMouseMove := False;
    FGridLineDragging := True;
  end;


end;

procedure TCustomAdvCardList.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
begin
  inherited;
  // column sizing
  if FGridLineDragging then
  begin
    if FResizingColumn > FViewedColumns then FResizingColumn := FViewedColumns;
    Pt := ClientToScreen(Point(FResizingColumn * FColumnWidth, Y));
    SetCursorPos(Pt.x, Pt.y);
    FGridLineDragging := False;
    ColumnSized;
  end;
end;

function TCustomAdvCardList.InValueRect(X: Integer; ACard: TAdvCard; ATemplate: TAdvCardTemplateItem; AItem: TAdvCardItem): boolean;
var
  R: TRect;
begin
  R := AItem.FValueListRect;
  R.Right := R.Left + Canvas.TextWidth(AItem.AsString);
  Result := (X > R.Left) and (X < R.Right);
end;

procedure TCustomAdvCardList.PaintCard(CardIndex: Integer);
var
  bmp: TBitmap;
  R: TRect;
  ClHeight: Integer;
  BordWidth: Integer;
begin
  bmp := TBitmap.Create;

  R := Cards.Items[CardIndex].FListRect;
  BordWidth := Cards.Items[CardIndex].Appearance.MergedBorderWidth;
  InflateRect(R, BordWidth, BordWidth);

  bmp.Width := R.Right - R.Left;
  bmp.Height := R.Bottom - R.Top;

  if ScrollBar.Visible and (bmp.Height + R.Top > Height - ScrollBar.Height) then
    bmp.Height := Height - ScrollBar.Height - R.Top;

  ClHeight := Height;
  if ScrollBar.Visible then
  begin
    dec(ClHeight, ScrollBar.Height + FBorderWidth - 2);
  end;

  try
    Color.Draw(bmp.Canvas, Bounds(-R.Left, -R.Top,
      Width, ClHeight));
    DrawCard(bmp.Canvas, Cards.Items[CardIndex], True);
    Canvas.Draw(R.Left, R.Top, bmp);
  finally
    bmp.Free;
  end;
end;

procedure TCustomAdvCardList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  n: Integer;
  Pt: TPoint;
  Card: TAdvCard;
  ItemN: Integer;
  OldIdx: integer;

begin
  inherited;

  // column sizing
  if FGridLineDragging then
  begin
    if FSilentMouseMove then
    begin
      FSilentMouseMove := False;
      Exit;
    end;
    ColumnWidth := FOldColumnWidth - (FPressedAtX - X);
    Pt := ClientToScreen(Point(FResizingColumn * ColumnWidth, Y));
    FSilentMouseMove := True;
    FPressedAtX := FPressedAtX - (X - ScreenToClient(Pt).x);
    SetCursorPos(Pt.x, Pt.y);
    Exit;
  end;

  // apply hover appearance                      {needed for URL's}
  if not FEditMode and (ShowHint or FCardHoverAppearance.Enabled or (1>0)) then
  begin
    Card := CardAtXY(X, Y, True);

    if Card <> nil then
    // card found - set hover appearance or show hint
    begin
      ItemN := ItemAtXY(X, Y, Card);

      if (ItemN >= 0) then
      begin
        if (CardTemplate.Items[ItemN].ValueURLType <> utNone) and
           (Card.ItemList[ItemN].AsString <> '') and
           (InValueRect(X, Card, CardTemplate.Items[ItemN], Card.ItemList[ItemN])) then
        begin
          Cursor := crHandPoint;
        end
        else
          if (Cursor <> crDefault) then
            Cursor := crDefault;
      end
      else
        if (Cursor <> crDefault) then
          Cursor := crDefault;

      // mouse over new card
      if (FHoverCardIndex <> Card.Index) then
      begin
        if FCardHoverAppearance.Enabled then
        begin
          oldidx := FHoverCardIndex;

          SetMouseOverCard(Card.Index);

          if oldidx >= 0 then
            PaintCard(oldidx);

          PaintCard(Card.Index);
          //Invalidate;
        end;
//        else
          FHoverCardIndex := Card.Index;

        if ShowHint then
        begin
          FOverItemIndex := ItemN;
          GetCursorPos(Pt);
          //DoubleBuffered := True;
	  {$IFDEF DELPHI5_LVL}
          Application.ActivateHint(Pt);
	  {$ENDIF}
          //DoubleBuffered := False;
        end;
      end
      else
        // the same card
        if ShowHint then
        begin
          ItemN := ItemAtXY(X, Y, Card);

          if (ItemN = -1) and PtInRect(Card.FCaptionListRect, Point(X, Y)) then
            ItemN := -2;
          if (ItemN <> FOverItemIndex) then
          begin
            FOverItemIndex := ItemN;
            GetCursorPos(Pt);
            //DoubleBuffered := True;
	    {$IFDEF DELPHI5_LVL}
            Application.ActivateHint(Pt);
	    {$ENDIF}
            //DoubleBuffered := False;
          end
          else
            FOverItemIndex := ItemN;
        end; {ShowHint}

      FCursorOverGridLine := False;

      if Screen.Cursor = crHSplit then
        Screen.Cursor := crDefault;
      Exit;
    end {Card <> nil}
    else
    // card not found - unset hover appearance for prev. card
    begin
      if FHoverCardIndex >= 0 then
      begin
        if FCardHoverAppearance.Enabled then
        begin
          SetMouseOverCard(FHoverCardIndex);
        end
        else
          FHoverCardIndex := -1;

        FOverItemIndex := -1;
        if ShowHint then
        begin
          //DoubleBuffered := True;
          Application.CancelHint;
        end;
        //Invalidate;
        //DoubleBuffered := False;
      end;
    end;
  end;

  // cursor over grid line?
  FCursorOverGridLine := False;
  if FColumnSizing and FShowGridLine then
  begin
    for n := 1 to FViewedColumns do
    begin
      if (X >= FColumnWidth * n - FGridLineWidth div 2) and
        (X <= FColumnWidth * n + FGridLineWidth div 2) then
      begin
        Screen.Cursor := crHSplit;
        FResizingColumn := n;
        FCursorOverGridLine := True;
        break;
      end;
    end;
  end;
  
  if not FCursorOverGridLine then
    Screen.Cursor := crDefault;
end;

procedure TCustomAdvCardList.HandleAppearanceChange(Sender: TObject; EnabledChanged: Boolean);
begin
  if (Sender = FCardNormalAppearance) and
    not TAdvCardAppearance(Sender).Enabled then TAdvCardAppearance(Sender).FEnabled := True;
  if not (csDesigning in ComponentState) and EnabledChanged then Cards.ApplyAppearance(nil);
  Invalidate;
end;

procedure TCustomAdvCardList.HandleColorChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomAdvCardList.CardTemplateChanged;
begin
  FColumnWidth := FCardTemplate.CardWidth + FCardHorSpacing * 2;
  UpdateCards(True, True, False, False);
  Invalidate;
end;

procedure TCustomAdvCardList.CardTemplateItemChanged(Item: TAdvCardTemplateItem);
begin
  if not (csDesigning in ComponentState) then
    if (FSelectedIndex >= 0) and (Cards[FSelectedIndex].SelectedItem = Item.Index) then
    begin
      Cards.FUpdateSelected := False;
      Cards[FSelectedIndex].SelectedItem := -1;
      Cards.FUpdateSelected := True;
    end;
  UpdateCards(True, True, False, False);
  Invalidate;  
end;

procedure TCustomAdvCardList.CardTemplateItemHideCondChanged(Item: TAdvCardTemplateItem);
begin
  if Assigned(Cards) then
    Cards.CheckItemShow(nil, Item.Index);
  UpdateCards(True, True, False, False);
end;

procedure TCustomAdvCardList.CardChanged(Card: TAdvCard);
begin
  UpdateCards(False, True, False, False);
end;

procedure TCustomAdvCardList.CardOrderCountChanged;
var
  CardN: Integer;
begin
  FSelectedCount := 0;
  for CardN := 0 to Cards.Count - 1 do
    if Cards[CardN].Selected then Inc(FSelectedCount);
  if FSelectedIndex > Cards.Count - 1 then
  begin
    FSelectedIndex := -1;
    FSelectedCard := nil;
  end;
  UpdateCards(False, True, True, True);
end;

procedure TCustomAdvCardList.HandleSortSettingsChange(Sender: TObject);
begin
  Sort;
end;

procedure TCustomAdvCardList.HandleFilterSettingsChange(Sender: TObject);
begin
  Filter;
end;

//----------------//
//   TAdvButton   //
//----------------//

constructor TAdvButton.Create(AOwner: TComponent);
begin
  inherited;
  inherited Caption := '';
  FFontDirection := fdHorizontal;
  ReCreateFont;
end;

destructor TAdvButton.Destroy;
begin
  if FFont <> 0 then DeleteObject(FFont);
  inherited;
end;

procedure TAdvButton.SetBorderWidth(Value: Integer);
begin
  if Value <> FBorderWidth then
  begin
    FBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TAdvButton.SetCaption(Value: string);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    Invalidate;
  end;
end;

procedure TAdvButton.SetFontDirection(Value: TFontDirection);
begin
  if Value <> FFontDirection then
  begin
    FFontDirection := Value;
    ReCreateFont;
    Invalidate;
  end;
end;

procedure TAdvButton.CMFontChanged(var Message: TMessage);
begin
  ReCreateFont;
  Invalidate;
end;

procedure TAdvButton.Paint;
var
  Rect: TRect;
begin
  inherited;
  Rect := ClientRect;
  InflateRect(Rect, -FBorderWidth, -FBorderWidth);
  with Canvas do
  begin
    SelectObject(Handle, FFont);
    Font.Color := Self.Font.Color;
    Brush.Style := bsClear;
    case FFontDirection of
      fdHorizontal:
        DrawText(Handle, PCHAR(FCaption), Length(FCaption), Rect,
          DT_CENTER or DT_VCENTER or DT_SINGLELINE);
      fdVertical:
        TextOut(Rect.Left + ((Rect.Right - Rect.Left) - Abs(Font.Height)) div 2,
          Rect.Top + ((Rect.Bottom - Rect.Top) + Abs(TextWidth(FCaption))) div 2,
          FCaption);
    end;
  end;
end;

procedure TAdvButton.ReCreateFont;
var
  It, Ul, So: Cardinal;
  FW, Angle: Integer;
begin
  if FFont <> 0 then DeleteObject(FFont);
  if fsItalic in Font.Style then It := 1 else It := 0;
  if fsUnderLine in Font.Style then Ul := 1 else Ul := 0;
  if fsStrikeOut in Font.Style then So := 1 else So := 0;
  if fsBold in Font.Style then FW := FW_BOLD else FW := FW_DONTCARE;
  if FFontDirection = fdHorizontal then Angle := 0 else Angle := 900;
  FFont := CreateFont(Font.Height, 0, Angle, Angle, FW, It, Ul, So, Font.Charset,
    OUT_CHARACTER_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
    CARDINAL(Font.Pitch), PCHAR(Font.Name));
end;

//--------------------//
//   TAdvButtonsBar   //
//--------------------//

constructor TAdvButtonsBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable]
{$IFDEF DELPHI7_LVL}
  - [csParentBackground]
{$ENDIF};
  FAlphabet := LoadResString(@SResDefAlphabet);
  FBarAlignment := baVertical;
  FBorderWidth := 10;
  FButBorderWidth := 3;
  FButtonDirection := bdHorizontal;
  FButtonGap := 5;
  FButtonSize := 25;
  FFlat := False;
  FShowNumButton := True;
  Width := 40 + FBorderWidth;
  Height := 200;
  Adjust;
end;

destructor TAdvButtonsBar.Destroy;
begin
  FButtons := nil;
  inherited;
end;

function TAdvButtonsBar.ButtonCount: Integer;
begin
  Result := Length(FButtons);
end;

procedure TAdvButtonsBar.Adjust;
var
  ButCount, ButN,
    ButHeight, ButWidth,
    CurrX, CurrY, FirstChar, CharCount: Integer;
  SymbPerBut: Real;
  DoShorter: Boolean;
begin
  // Remove all buttons
  ButCount := 0;
  ButHeight := 0;
  ButWidth := 0;
   
  for ButN := 0 to High(FButtons) do
    if Assigned(FButtons[ButN]) then
    begin
      RemoveControl(FButtons[ButN]);
      FreeAndNil(FButtons[ButN]);
    end;
  FButtons := nil;
  if (Length(FAlphabet) <= 0) and not FShowNumButton then exit; // no need for buttons
  // calc button count
  case FBarAlignment of
    baHorizontal:
      begin
        ButCount := (Width - (FBorderWidth div 2)) div (FButtonSize + FButtonGap);
        ButWidth := FButtonSize;
        ButHeight := Height - FBorderWidth;
      end;
    baVertical:
      begin
        ButCount := (Height - (FBorderWidth div 2)) div (FButtonSize + FButtonGap);
        ButWidth := Width - FBorderWidth;
        ButHeight := FButtonSize;
      end;
  end;
  if ButCount < 1 then exit; // not enough space
  if FShowNumButton and (ButCount > 1)
    then SymbPerBut := Length(FAlphabet) / (ButCount - 1)
  else SymbPerBut := Length(FAlphabet) / ButCount;
  if SymbPerBut < 1 then
  begin
    ButCount := Length(FAlphabet);
    SymbPerBut := 1;
    if FShowNumButton then Inc(ButCount);
  end;
  if ButCount > 0 then
  begin
    CurrX := FBorderWidth div 2;
    CurrY := CurrX;
    FirstChar := 1;
    SetLength(FButtons, ButCount);
    for ButN := 0 to High(FButtons) do
    begin
      FButtons[ButN] := TAdvButton.Create(Self);
      FButtons[ButN].Parent := Self;
      FButtons[ButN].FontDirection := TFontDirection(FButtonDirection);
      FButtons[ButN].Flat := FFlat;
      FButtons[ButN].BorderWidth := FButBorderWidth;
      FButtons[ButN].OnClick := HandleButtonClick;
      // Bounds of button
      case FBarAlignment of
        baHorizontal:
          begin
            FButtons[ButN].SetBounds(CurrX, CurrY, ButWidth, ButHeight);
            Inc(CurrX, ButWidth + FButtonGap);
          end;
        baVertical:
          begin
            FButtons[ButN].SetBounds(CurrX, CurrY, ButWidth, ButHeight);
            Inc(CurrY, ButHeight + FButtonGap);
          end;
      end; {case}
      // Button content
      if (ButN = 0) and FShowNumButton then
      begin
        FButtons[ButN].Symbols := '';
        FButtons[ButN].Caption := '123';
        FButtons[ButN].Tag := 1;
        Continue;
      end;
      if FShowNumButton
        then CharCount := Round(ButN * SymbPerBut - FirstChar) + 1
      else CharCount := Round((ButN + 1) * SymbPerBut - FirstChar) + 1;
      if CharCount < 1 then CharCount := 1;
      if ButN = High(FButtons) then CharCount := Length(FAlphabet) - FirstChar + 1;
      FButtons[ButN].Symbols := Copy(FAlphabet, FirstChar, CharCount);
      DoShorter := False;
      if Parent <> nil then
      begin
        Canvas.Font.Assign(Font);
        case FButtonDirection of
          bdHorizontal:
            DoShorter := Canvas.TextWidth(FButtons[ButN].Symbols) >
              FButtons[ButN].Width - FButBorderWidth * 2;
          bdVertical:
            DoShorter := Canvas.TextWidth(FButtons[ButN].Symbols) >
              FButtons[ButN].Height - FButBorderWidth * 2;
        end;
      end;
      if DoShorter and (Length(FButtons[ButN].Symbols) > 2)
        then
        FButtons[ButN].Caption := FButtons[ButN].Symbols[1] + '-' +
          FButtons[ButN].Symbols[Length(FButtons[ButN].Symbols) - 1]
      else
        FButtons[ButN].Caption := FButtons[ButN].Symbols;
      FButtons[ButN].Tag := ButN + 1;
      Inc(FirstChar, CharCount);
    end; {for}
  end; {ButCount > 0}
end;

procedure TAdvButtonsBar.HandleButtonClick(Sender: TObject);
var
  Card: TAdvCard;
  SymbN: Integer;
begin
  if not (csDesigning in ComponentState) then
  begin
    if Assigned(FCardList) then
    begin
      if TAdvButton(Sender).Symbols <> '' then
        for SymbN := 1 to Length(TAdvButton(Sender).Symbols) do
        begin
          Card := FCardList.FindCard(TAdvButton(Sender).Symbols[SymbN]);
          if Card <> nil then
          begin
            FCardList.SelectedIndex := Card.Index;
            Break;
          end;
        end else
      begin
        Card := FCardList.FindCard('');
        if Card <> nil then
        begin
          FCardList.SelectedIndex := Card.Index;
        end;
      end;
    end;
    if Assigned(FOnButtonClick) then FOnButtonClick(Self, TAdvButton(Sender).Tag,
        TAdvButton(Sender).Symbols);
  end;
end;

procedure TAdvButtonsBar.SetAlphabet(Value: string);
begin
  if Value <> FAlphabet then
  begin
    FAlphabet := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetBarAlignment(Value: TAdvBarAlignment);
begin
  if Value <> FBarAlignment then
  begin
    FBarAlignment := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetButBorderWidth(Value: Integer);
var
  ButN: Integer;
begin
  if Value <> FButBorderWidth then
  begin
    FButBorderWidth := Value;
    for ButN := 0 to High(FButtons) do FButtons[ButN].BorderWidth := Value;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetBorderWidth(Value: Integer);
begin
  if Value <> FBorderWidth then
  begin
    FBorderWidth := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetButtonDirection(Value: TAdvBarButtonDirection);
begin
  if Value <> FButtonDirection then
  begin
    FButtonDirection := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetButtonGap(Value: Integer);
begin
  if Value <> FButtonGap then
  begin
    FButtonGap := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetButtonSize(Value: Integer);
begin
  if Value <> FButtonSize then
  begin
    FButtonSize := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.SetFlat(Value: Boolean);
var
  ButN: Integer;
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    for ButN := 0 to High(FButtons) do FButtons[ButN].Flat := Value;
  end;
end;

procedure TAdvButtonsBar.SetShowNumButton(Value: Boolean);
begin
  if Value <> FShowNumButton then
  begin
    FShowNumButton := Value;
    Adjust;
    Invalidate;
  end;
end;

procedure TAdvButtonsBar.Paint;
begin
  inherited;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(ClientRect);
  end;
end;

procedure TAdvButtonsBar.Resize;
begin
  Adjust;
  inherited;
end;



{ TCardListEditLink }

procedure TCardListEditLink.ControlKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key in [VK_UP, VK_DOWN]) then
    Exit;
  if Assigned(OnKeyDown) then
    OnKeyDown(Sender, Key, Shift);
end;

initialization
  SDesignNoItemCaption := LoadResString(@SResDesignNoItemCaption);
  SDesignNoItemDefValue := LoadResString(@SResDesignNoItemDefValue);
  STrue := LoadResString(@SResTrue);
  SFalse := LoadResString(@SResFalse);

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}

end.
