{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars components                                      }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }     
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxRibbonGallery;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Messages, SysUtils, Graphics, Controls, StdCtrls, Contnrs,
  ImgList, ActnList, Forms,
  dxCore, cxClasses, cxGraphics, cxGeometry, cxScrollBar, dxBar,
  cxAccessibility, dxBarAccessibility, dxRibbon, dxRibbonForm, cxControls,
  cxLookAndFeelPainters, dxRibbonSkins;

const
  dxRibbonGalleryDefaultColumnCount = 5;
  dxRibbonGalleryGroupItemIndent = 3;
  dxRibbonGalleryMinColumnCount = 2;

type
  TdxRibbonDropDownGallery = class;
  TdxRibbonDropDownGalleryControl = class;
  TdxRibbonGalleryControl = class;
  TdxRibbonGalleryControlViewInfo = class;
  TdxRibbonGalleryFilter = class;
  TdxRibbonGalleryFilterCategory = class;
  TdxRibbonGalleryFilterMenuControl = class;
  TdxRibbonGalleryGroup = class;
  TdxRibbonGalleryGroupItemActionLink = class;
  TdxRibbonGalleryGroupItemActionLinkClass = class of TdxRibbonGalleryGroupItemActionLink;
  TdxRibbonGalleryGroupItemViewInfo = class;
  TdxRibbonGalleryGroupOptions = class;
  TdxRibbonGalleryGroupViewInfo = class;
  TdxRibbonGalleryItem = class;
  TdxRibbonGalleryScrollBar = class;
  TdxRibbonOnSubMenuGalleryControlViewInfo = class;

  TdxRibbonDropDownGalleryNavigationDirection = (dgndNone, dgndUp, dgndDown);
  TdxRibbonGalleryVisibilityState = (gbsIndefinite, gbsFalse, gbsTrue);
  TdxRibbonGalleryGroupItemTextKind = (itkNone, itkCaption, itkCaptionAndDescription);
  TdxRibbonGalleryImagePosition = (gipLeft, gipRight, gipTop,
    gipBottom);
  TdxRibbonGalleryItemSelectionMode = (gsmNone, gsmSingle, gsmMultiple, gsmSingleInGroup);
  TdxRibbonGallerySubMenuResizing = (gsrNone, gsrHeight, gsrWidthAndHeight);

  { TcxItemSize }

  TcxItemSize = class(TcxSize)
  private
    FAssigned: Boolean;
    FParent: TcxItemSize;
    procedure SetAssigned(const Value: Boolean);
  protected
    procedure DoChange; override;
    function GetValue(Index: Integer): Integer; override;
    function IsSizeStored(Index: Integer): Boolean; override;
    procedure SetSize(const Value: TSize); override;

    property Assigned: Boolean read FAssigned write SetAssigned;
    property Parent: TcxItemSize read FParent write FParent;
  end;

  { TdxRibbonGalleryItemPullHighlighting }

  TdxRibbonGalleryItemPullHighlightingDirection = (gphdStartToFinish, gphdFinishToStart);

  TdxRibbonGalleryItemPullHighlighting = class(TPersistent)
  private
    FActive: Boolean;
    FIsAssigned: Boolean;
    FDirection: TdxRibbonGalleryItemPullHighlightingDirection;
    FParent: TdxRibbonGalleryItemPullHighlighting;
    FOnChange: TNotifyEvent;
    function GetActive: Boolean;
    function GetDirection: TdxRibbonGalleryItemPullHighlightingDirection;
    procedure SetActive(Value: Boolean);
    procedure SetIsAssigned(Value: Boolean);
    procedure SetDirection(Value: TdxRibbonGalleryItemPullHighlightingDirection);
  protected
    procedure DoChange;
    function IsActiveStored: Boolean; virtual;
    function IsDirectionStored: Boolean; virtual;

    property IsAssigned: Boolean read FIsAssigned write SetIsAssigned;
    property Parent: TdxRibbonGalleryItemPullHighlighting read FParent write FParent;
  public
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Active: Boolean read GetActive write SetActive stored IsActiveStored;
    property Direction: TdxRibbonGalleryItemPullHighlightingDirection read GetDirection
      write SetDirection stored IsDirectionStored;
  end;

  { TdxRibbonGalleryCustomOptions }

  TdxRibbonGalleryCustomOptions = class(TPersistent)
  private
    FImages: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FItemImagePosition: TdxRibbonGalleryImagePosition;
    FItemImageSize: TcxItemSize;
    FItemSize: TcxItemSize;
    FItemTextKind: TdxRibbonGalleryGroupItemTextKind;
    FOwner: TdxRibbonGalleryItem;
    FItemPullHighlighting: TdxRibbonGalleryItemPullHighlighting;
    FSpaceAfterGroupHeader: Integer;
    FSpaceBetweenItemCaptionAndDescription: Integer;
    FSpaceBetweenItemImageAndText: Integer;
    FSpaceBetweenItemsHorizontally: Integer;
    FSpaceBetweenItemsVertically: Integer;
    procedure ReadSpaceBetweenItemsProperty(Reader: TReader);
    procedure SetItemImageSize(Value: TcxItemSize);
    procedure SetItemPullHighlighting(Value: TdxRibbonGalleryItemPullHighlighting);
    procedure SetItemSize(Value: TcxItemSize);
    procedure WriteSpaceBetweenItemsProperty(Writer: TWriter);
  protected
    procedure Changed; virtual;
    procedure CheckIntRange(var Value: Integer);
    procedure CheckItemsSpaceRange(var Value: Integer);
    procedure DefineProperties(Filer: TFiler); override;

    function GetItemImagePosition: TdxRibbonGalleryImagePosition; virtual;
    function GetItemTextKind: TdxRibbonGalleryGroupItemTextKind; virtual;
    function GetRemoveHorizontalItemPadding: Boolean; virtual;
    function GetRemoveVerticalItemPadding: Boolean; virtual;
    function GetSpaceAfterGroupHeader: Integer; virtual;
    function GetSpaceBetweenItemCaptionAndDescription: Integer; virtual;
    function GetSpaceBetweenItemImageAndText: Integer; virtual;
    function GetSpaceBetweenItems: Integer; virtual;
    function GetSpaceBetweenItemsHorizontally: Integer; virtual;
    function GetSpaceBetweenItemsVertically: Integer; virtual;

    function IsItemImagePositionStored: Boolean; virtual;
    function IsItemImageSizeStored: Boolean; virtual;
    function IsItemSizeStored: Boolean; virtual;
    function IsItemTextKindStored: Boolean; virtual;
    function IsItemPullHighlightingStored: Boolean; virtual;
    function IsSpaceAfterGroupHeaderStored: Boolean; virtual;
    function IsSpaceBetweenItemCaptionAndDescriptionStored: Boolean; virtual;
    function IsSpaceBetweenItemImageAndTextStored: Boolean; virtual;
    function IsSpaceBetweenItemsHorizontallyStored: Boolean; virtual;
    function IsSpaceBetweenItemsVerticallyStored: Boolean; virtual;
    procedure ItemImageSizeChange(Sender: TObject); virtual;
    procedure ItemPullHighlightingChange(Sender: TObject); virtual;
    procedure ItemSizeChange(Sender: TObject); virtual;

    procedure SetImages(Value: TCustomImageList); virtual;
    procedure SetItemImagePosition(Value: TdxRibbonGalleryImagePosition); virtual;
    procedure SetItemTextKind(Value: TdxRibbonGalleryGroupItemTextKind); virtual;
    procedure SetSpaceAfterGroupHeader(Value: Integer); virtual;
    procedure SetSpaceBetweenItemCaptionAndDescription(Value: Integer); virtual;
    procedure SetSpaceBetweenItemImageAndText(Value: Integer); virtual;
    procedure SetSpaceBetweenItems(Value: Integer); virtual;
    procedure SetSpaceBetweenItemsHorizontally(Value: Integer); virtual;
    procedure SetSpaceBetweenItemsVertically(Value: Integer); virtual;

    property ImageChangeLink: TChangeLink read FImageChangeLink;
    property Owner: TdxRibbonGalleryItem read FOwner;
    property RemoveHorizontalItemPadding: Boolean read GetRemoveHorizontalItemPadding;
    property RemoveVerticalItemPadding: Boolean read GetRemoveVerticalItemPadding;
  public
    constructor Create(AOwner: TdxRibbonGalleryItem);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property Images: TCustomImageList read FImages write SetImages;
    property ItemImagePosition: TdxRibbonGalleryImagePosition
      read GetItemImagePosition write SetItemImagePosition stored IsItemImagePositionStored;
    property ItemImageSize: TcxItemSize
      read FItemImageSize write SetItemImageSize stored IsItemImageSizeStored;
    property ItemTextKind: TdxRibbonGalleryGroupItemTextKind
      read GetItemTextKind write SetItemTextKind stored IsItemTextKindStored;
    property ItemSize: TcxItemSize
      read FItemSize write SetItemSize stored IsItemSizeStored;
    property ItemPullHighlighting: TdxRibbonGalleryItemPullHighlighting read FItemPullHighlighting
      write SetItemPullHighlighting stored IsItemPullHighlightingStored;
    property SpaceAfterGroupHeader: Integer
      read GetSpaceAfterGroupHeader write SetSpaceAfterGroupHeader stored IsSpaceAfterGroupHeaderStored;
    property SpaceBetweenItemCaptionAndDescription: Integer
      read GetSpaceBetweenItemCaptionAndDescription write SetSpaceBetweenItemCaptionAndDescription stored IsSpaceBetweenItemCaptionAndDescriptionStored;
    property SpaceBetweenItemImageAndText: Integer
      read GetSpaceBetweenItemImageAndText write SetSpaceBetweenItemImageAndText stored IsSpaceBetweenItemImageAndTextStored;
    property SpaceBetweenItems: Integer read GetSpaceBetweenItems write SetSpaceBetweenItems;
    property SpaceBetweenItemsHorizontally: Integer
      read GetSpaceBetweenItemsHorizontally write SetSpaceBetweenItemsHorizontally stored IsSpaceBetweenItemsHorizontallyStored;
    property SpaceBetweenItemsVertically: Integer
      read GetSpaceBetweenItemsVertically write SetSpaceBetweenItemsVertically stored IsSpaceBetweenItemsVerticallyStored;
  end;

  { TdxRibbonGalleryGroupOptions }

  TdxRibbonGalleryGroupOptionsAssignedValue = (
    avItemImagePosition, avItemImageSize, avItemSize, avItemTextKind,
    avItemPullHighlighting, avSpaceAfterGroupHeader,
    avSpaceBetweenItemCaptionAndDescription, avSpaceBetweenItemImageAndText,
    avSpaceBetweenItems,
    avSpaceBetweenItemsHorizontally, avSpaceBetweenItemsVertically);
  TdxRibbonGalleryGroupOptionsAssignedValues = set of TdxRibbonGalleryGroupOptionsAssignedValue;

  TdxRibbonGalleryGroupOptions = class(TdxRibbonGalleryCustomOptions)
  private
    FAssignedValues: TdxRibbonGalleryGroupOptionsAssignedValues;
    FParentOptions: TdxRibbonGalleryCustomOptions;
    procedure SetAssignedValues(
      const Value: TdxRibbonGalleryGroupOptionsAssignedValues);
  protected
    function GetItemImagePosition: TdxRibbonGalleryImagePosition; override;
    function GetItemTextKind: TdxRibbonGalleryGroupItemTextKind; override;
    function GetSpaceAfterGroupHeader: Integer; override;
    function GetSpaceBetweenItemCaptionAndDescription: Integer; override;
    function GetSpaceBetweenItemImageAndText: Integer; override;
    function GetSpaceBetweenItemsHorizontally: Integer; override;
    function GetSpaceBetweenItemsVertically: Integer; override;

    function IsSpaceAfterGroupHeaderStored: Boolean; override;
    function IsSpaceBetweenItemCaptionAndDescriptionStored: Boolean; override;
    function IsSpaceBetweenItemImageAndTextStored: Boolean; override;
    function IsSpaceBetweenItemsHorizontallyStored: Boolean; override;
    function IsSpaceBetweenItemsVerticallyStored: Boolean; override;
    function IsItemImagePositionStored: Boolean; override;
    function IsItemImageSizeStored: Boolean; override;
    function IsItemTextKindStored: Boolean; override;
    function IsItemSizeStored: Boolean; override;
    function IsItemPullHighlightingStored: Boolean; override;
    procedure ItemImageSizeChange(Sender: TObject); override;
    procedure ItemSizeChange(Sender: TObject); override;
    procedure ItemPullHighlightingChange(Sender: TObject); override;

    procedure SetItemImagePosition(Value: TdxRibbonGalleryImagePosition); override;
    procedure SetItemTextKind(Value: TdxRibbonGalleryGroupItemTextKind); override;
    procedure SetSpaceAfterGroupHeader(Value: Integer); override;
    procedure SetSpaceBetweenItemCaptionAndDescription(Value: Integer); override;
    procedure SetSpaceBetweenItemImageAndText(Value: Integer); override;
    procedure SetSpaceBetweenItemsHorizontally(Value: Integer); override;
    procedure SetSpaceBetweenItemsVertically(Value: Integer); override;

    property ParentOptions: TdxRibbonGalleryCustomOptions read FParentOptions;
  public
    constructor Create(AOwner: TdxRibbonGalleryItem;
      AParentOptions: TdxRibbonGalleryCustomOptions; AGroup: TdxRibbonGalleryGroup);
  published
    property AssignedValues: TdxRibbonGalleryGroupOptionsAssignedValues
      read FAssignedValues write SetAssignedValues default [];
    property Images;
    property ItemImagePosition;
    property ItemImageSize;
    property ItemTextKind;
    property ItemSize;
    property ItemPullHighlighting;
    property SpaceAfterGroupHeader;
    property SpaceBetweenItemCaptionAndDescription;
    property SpaceBetweenItemImageAndText;
    property SpaceBetweenItemsHorizontally;
    property SpaceBetweenItemsVertically;
  end;

  { TdxRibbonGalleryOptions }

  TdxRibbonGalleryOptions = class(TdxRibbonGalleryCustomOptions)
  private
    FCanCollapse: Boolean;
    FCollapsed: Boolean;
    FColumnCount: Integer;
    FEqualItemSizeInAllGroups: Boolean;
    FItemAllowDeselect: Boolean;
    FItemSelectionMode: TdxRibbonGalleryItemSelectionMode;
    FMinColumnCount: Integer;
    FRowCount: Integer;
    FShowScrollbar: Boolean; // deprecated
    FSpaceBetweenGroups: Integer;
    FSpaceBetweenItemsAndBorder: Integer;
    FSubMenuResizing: TdxRibbonGallerySubMenuResizing;
    procedure SetCanCollapse(Value: Boolean);
    procedure SetCollapsed(Value: Boolean);
    procedure SetColumnCount(Value: Integer);
    procedure SetSpaceBetweenGroups(Value: Integer);
    procedure SetEqualItemSizeInAllGroups(Value: Boolean);
    procedure SetItemSelectionMode(Value: TdxRibbonGalleryItemSelectionMode);
    procedure SetMinColumnCount(Value: Integer);
    procedure SetRowCount(Value: Integer);
    procedure SetSpaceBetweenItemsAndBorder(Value: Integer);
  public
    constructor Create(AOwner: TdxRibbonGalleryItem);
    procedure Assign(Source: TPersistent); override;
  published
    property CanCollapse: Boolean read FCanCollapse write SetCanCollapse default True;
    property Collapsed: Boolean read FCollapsed write SetCollapsed default False;
    property ColumnCount: Integer read FColumnCount write SetColumnCount
      default dxRibbonGalleryDefaultColumnCount;
    property EqualItemSizeInAllGroups: Boolean read FEqualItemSizeInAllGroups
      write SetEqualItemSizeInAllGroups default True;
    property Images;
    property ItemAllowDeselect: Boolean read FItemAllowDeselect
      write FItemAllowDeselect default False;
    property ItemImagePosition;
    property ItemImageSize;
    property ItemSelectionMode: TdxRibbonGalleryItemSelectionMode
      read FItemSelectionMode write SetItemSelectionMode default gsmSingle;
    property ItemSize;
    property ItemPullHighlighting;
    property ItemTextKind;
    property MinColumnCount: Integer read FMinColumnCount
      write SetMinColumnCount default dxRibbonGalleryMinColumnCount;
    property RowCount: Integer read FRowCount write SetRowCount default 0;
    property ShowScrollbar: Boolean read FShowScrollbar write FShowScrollbar stored False; // deprecated
    property SpaceAfterGroupHeader;
    property SpaceBetweenGroups: Integer read FSpaceBetweenGroups
      write SetSpaceBetweenGroups default 0;
    property SpaceBetweenItemCaptionAndDescription;
    property SpaceBetweenItemImageAndText;
    property SpaceBetweenItemsHorizontally;
    property SpaceBetweenItemsVertically;
    property SpaceBetweenItemsAndBorder: Integer read FSpaceBetweenItemsAndBorder
      write SetSpaceBetweenItemsAndBorder default 1;
    property SubMenuResizing: TdxRibbonGallerySubMenuResizing read FSubMenuResizing
      write FSubMenuResizing default gsrWidthAndHeight;
  end;

  { TdxRibbonGalleryGroupHeader }

  TdxRibbonGalleryGroupHeader = class(TPersistent)
  private
    FAlignment: TAlignment;
    FCaption: string;
    FOwner: TdxRibbonGalleryGroup;
    FVisible: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetCaption(const Value: string);
    procedure SetVisible(Value: Boolean);
  protected
    procedure Changed;
  public
    constructor Create(AOwner: TdxRibbonGalleryGroup);
    procedure Assign(Source: TPersistent); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Caption: string read FCaption write SetCaption;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  { TdxRibbonGalleryGroupItem }

  TdxRibbonGalleryGroupItem = class(TCollectionItem)
  private
    FActionLink: TdxRibbonGalleryGroupItemActionLink;
    FCaption: string;
    FDescription: string;
    FGlyph: TBitmap;
    FImageIndex: TImageIndex;
    FSelected: Boolean;
    FTag: TcxTag;
    FOnClick: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseUp: TMouseEvent;
    procedure DoActionChange(Sender: TObject);
    function GetAction: TBasicAction;
    function GetGalleryItem: TdxRibbonGalleryItem;
    function GetGroup: TdxRibbonGalleryGroup;
    function GetSelected: Boolean;
    function GetSelectionMode: TdxRibbonGalleryItemSelectionMode;
    procedure GlyphChanged(Sender: TObject);
    function IsCaptionStored: Boolean;
    function IsDesigning: Boolean;
    function IsImageIndexStored: Boolean;
    function IsOnClickStored: Boolean;
    function IsSelectedStored: Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    procedure SetAction(Value: TBasicAction);
    procedure SetCaption(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetGlyph(Value: TBitmap);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetSelected(Value: Boolean);
  protected
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); dynamic;
    procedure DoClick; dynamic;
    procedure DrawImage(DC: HDC; const ARect: TRect);
    function GetActionLinkClass: TdxRibbonGalleryGroupItemActionLinkClass; dynamic;
    function GetImageSize: TSize;
    function IsImageAssigned: Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); dynamic;
    property GalleryItem: TdxRibbonGalleryItem read GetGalleryItem;
    property LoadedSelected: Boolean read FSelected write FSelected;
    property SelectionMode: TdxRibbonGalleryItemSelectionMode read GetSelectionMode;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Group: TdxRibbonGalleryGroup read GetGroup;
  published
    property Action: TBasicAction read GetAction write SetAction;
    property Caption: string read FCaption write SetCaption stored IsCaptionStored;
    property Description: string read FDescription write SetDescription;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex
      stored IsImageIndexStored default -1;
    property Selected: Boolean read GetSelected write SetSelected
      stored IsSelectedStored default False;
    property Tag: TcxTag read FTag write FTag default 0;
    property OnClick: TNotifyEvent read FOnClick write FOnClick stored IsOnClickStored;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

  { TdxRibbonGalleryGroupItems }

  TdxRibbonGalleryGroupItems = class(TCollection)
  private
    FGroup: TdxRibbonGalleryGroup;
    function GetItem(Index: Integer): TdxRibbonGalleryGroupItem;
    procedure SetItem(Index: Integer; Value: TdxRibbonGalleryGroupItem);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

    property Group: TdxRibbonGalleryGroup read FGroup;
  public
    constructor Create(AGroup: TdxRibbonGalleryGroup); virtual;
    function Add: TdxRibbonGalleryGroupItem;
    function Insert(Index: Integer): TdxRibbonGalleryGroupItem;
    property Items[Index: Integer]: TdxRibbonGalleryGroupItem read GetItem write SetItem; default;
  end;

  { TdxRibbonGalleryGroup }

  TdxRibbonGalleryGroup = class(TCollectionItem)
  private
    FHeader: TdxRibbonGalleryGroupHeader;
    FItems: TdxRibbonGalleryGroupItems;
    FOptions: TdxRibbonGalleryGroupOptions;
    FVisible: Boolean;
    function GetGalleryItem: TdxRibbonGalleryItem;
    function GetImages: TCustomImageList;
    procedure ImagesChange(Sender: Tobject);
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    procedure NotifyItems(AComponent: TComponent; Operation: TOperation);
    procedure SetHeader(Value: TdxRibbonGalleryGroupHeader);
    procedure SetItems(Value: TdxRibbonGalleryGroupItems);
    procedure SetOptions(Value: TdxRibbonGalleryGroupOptions);
    procedure SetVisible(Value: Boolean);
  protected
    property Images: TCustomImageList read GetImages;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property GalleryItem: TdxRibbonGalleryItem read GetGalleryItem;
  published
    property Header: TdxRibbonGalleryGroupHeader read FHeader write SetHeader;
    property Items: TdxRibbonGalleryGroupItems read FItems write SetItems;
    property Options: TdxRibbonGalleryGroupOptions read FOptions write SetOptions;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  { TdxRibbonGalleryGroups }

  TdxRibbonGalleryGroups = class(TCollection)
  private
    FGalleryItem: TdxRibbonGalleryItem;
    function GetItem(Index: Integer): TdxRibbonGalleryGroup;
    procedure RemoveFromFilter(AItem: TCollectionItem);
    procedure SetItem(Index: Integer; Value: TdxRibbonGalleryGroup);
  protected
    function GetOwner: TPersistent; override;
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
    property GalleryItem: TdxRibbonGalleryItem read FGalleryItem;
  public
    constructor Create(AGalleryItem: TdxRibbonGalleryItem); virtual;
    function Add: TdxRibbonGalleryGroup;
    function Insert(Index: Integer): TdxRibbonGalleryGroup;
    property Items[Index: Integer]: TdxRibbonGalleryGroup read GetItem write SetItem; default;
  end;

  { TdxRibbonGalleryFilterCategoryGroups }

  TdxRibbonGalleryFilterCategoryGroups = class(TList)
  private
    FFilterCategory: TdxRibbonGalleryFilterCategory;
    function CanAddGroup(AGroup: TdxRibbonGalleryGroup): Boolean;
    function GetItem(Index: Integer): TdxRibbonGalleryGroup;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create(AFilterCategory: TdxRibbonGalleryFilterCategory);
    procedure Assign(ASource: TdxRibbonGalleryFilterCategoryGroups);
    function Add(AGroup: TdxRibbonGalleryGroup): Integer;
    procedure Insert(AIndex: Integer; AGroup: TdxRibbonGalleryGroup);
    property FilterCategory: TdxRibbonGalleryFilterCategory read FFilterCategory;
    property Items[Index: Integer]: TdxRibbonGalleryGroup read GetItem; default;
  end;

  { TdxRibbonGalleryFilterCategory }

  TdxRibbonGalleryFilterCategory = class(TCollectionItem)
  private
    FCaption: string;
    FGroups: TdxRibbonGalleryFilterCategoryGroups;
    function GetGalleryItem: TdxRibbonGalleryItem;
    procedure ReadCategoryGroups(AReader: TReader);
    procedure WriteCategoryGroups(AWriter: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property GalleryItem: TdxRibbonGalleryItem read GetGalleryItem;
  published
    property Caption: string read FCaption write FCaption;
    property Groups: TdxRibbonGalleryFilterCategoryGroups read FGroups stored False;
  end;

  { TdxRibbonGalleryFilterCategories }

  TdxRibbonGalleryFilterCategories = class(TCollection)
  private
    FGalleryFilter: TdxRibbonGalleryFilter;
    function GetItem(Index: Integer): TdxRibbonGalleryFilterCategory;
    procedure SetItem(Index: Integer; Value: TdxRibbonGalleryFilterCategory);
  protected
    procedure DeleteGroup(AGroup: TdxRibbonGalleryGroup);
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

    property GalleryFilter: TdxRibbonGalleryFilter read FGalleryFilter;
  public
    constructor Create(AGalleryFilter: TdxRibbonGalleryFilter);
    function Add: TdxRibbonGalleryFilterCategory;
    property Items[Index: Integer]: TdxRibbonGalleryFilterCategory read GetItem
      write SetItem; default;
  end;

  { TdxRibbonGalleryFilter }

  TdxRibbonGalleryFilter = class(TPersistent)
  private
    FActiveCategoryIndex: Integer;
    FCaption: string;
    FCategories: TdxRibbonGalleryFilterCategories;
    FGalleryItem: TdxRibbonGalleryItem;
    FLoadedActiveCategoryIndex: Integer;
    FVisible: Boolean;
    procedure SetActiveCategoryIndex(Value: Integer);
    procedure SetCaption(const Value: string);
    procedure SetCategories(Value: TdxRibbonGalleryFilterCategories);
  protected
    procedure CategoriesChanged;
    function GetOwner: TPersistent; override;
    procedure Loaded;
    property GalleryItem: TdxRibbonGalleryItem read FGalleryItem;
  public
    constructor Create(AGalleryItem: TdxRibbonGalleryItem);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function IsGroupFiltered(AGroup: TdxRibbonGalleryGroup): Boolean;
  published
    property ActiveCategoryIndex: Integer read FActiveCategoryIndex
      write SetActiveCategoryIndex default -1;
    property Caption: string read FCaption write SetCaption;
    property Categories: TdxRibbonGalleryFilterCategories read FCategories
      write SetCategories;
    property Visible: Boolean read FVisible write FVisible default False;
  end;

  { TdxRibbonGalleryItem }

  TdxRibbonGalleryFilterChangedEvent = procedure(
    Sender: TdxRibbonGalleryItem) of object;
  TdxRibbonGalleryGroupItemClickEvent = procedure(Sender: TdxRibbonGalleryItem;
    AItem: TdxRibbonGalleryGroupItem) of object;
  TdxRibbonGalleryHotTrackedItemChangedEvent = procedure(
    APrevHotTrackedGroupItem, ANewHotTrackedGroupItem: TdxRibbonGalleryGroupItem) of object;

  TdxRibbonGalleryInitFilterMenuEvent = procedure(Sender: TdxRibbonGalleryItem;
    AItemLinks: TdxBarItemLinks) of object;

  TdxRibbonGalleryItem = class(TCustomdxBarSubItem)
  private
    FDefaultTextColor: TColor;
    FDefaultTextColorDetermined: Boolean;
    FDropDownGallery: TdxRibbonDropDownGallery;
    FFilterChangedLockCount: Integer;
    FGalleryFilter: TdxRibbonGalleryFilter;
    FGalleryGroups: TdxRibbonGalleryGroups;
    FGalleryOptions: TdxRibbonGalleryOptions;
    FIsClone: Boolean;
    FLockGroupItemClickEventsCount: Integer;
    FRecalculatingOnFilterChanged: Boolean;
    FSelectedGroupItem: TdxRibbonGalleryGroupItem;
    FSelectedTextColor: TColor;
    FSelectedTextColorDetermined: Boolean;
    FOnFilterChanged: TdxRibbonGalleryFilterChangedEvent;
    FOnGroupItemClick: TdxRibbonGalleryGroupItemClickEvent;
    FOnHotTrackedItemChanged: TdxRibbonGalleryHotTrackedItemChangedEvent;
    FOnInitFilterMenu: TdxRibbonGalleryInitFilterMenuEvent;
    procedure NotifyGroups(AComponent: TComponent; Operation: TOperation);
    procedure SetDropDownGallery(Value: TdxRibbonDropDownGallery);
    procedure SetGalleryFilter(Value: TdxRibbonGalleryFilter);
    procedure SetGalleryGroups(Value: TdxRibbonGalleryGroups);
    procedure SetGalleryOptions(Value: TdxRibbonGalleryOptions);
    procedure SetSelectedGroupItem(Value: TdxRibbonGalleryGroupItem);
  protected
    FClickedGroupItem: TdxRibbonGalleryGroupItem;
    function AreGroupItemClickEventsLocked: Boolean;
    function CanBePlacedOn(AParentKind: TdxBarItemControlParentKind;
      AToolbar: TdxBar; out AErrorText: string): Boolean; override;
    function CreateCloneForDropDownGallery: TdxRibbonGalleryItem; virtual;
    procedure DoCloseUp; override;
    procedure DoFilterChanged;
    procedure DoGroupItemClick(AItem: TdxRibbonGalleryGroupItem); virtual;
    procedure DoHotTrackedItemChanged(APrevHotTrackedGroupItem,
      ANewHotTrackedGroupItem: TdxRibbonGalleryGroupItem); virtual;
    procedure DoInitFilterMenu(AItemLinks: TdxBarItemLinks);
    procedure DoPopup; override;
    procedure FilterCaptionChanged;
    procedure FilterChanged;
    procedure GalleryChanged;
    function GetFilterCaption: string;
    function GetImages: TCustomImageList;
    class function GetNewCaption: string; override;
    procedure GroupVisibleChanged;
    procedure ImagesChange(Sender: TObject);
    function InternalCanMergeWith(AItem: TdxBarItem): Boolean; override;
    function IsFilterVisible: Boolean;
    procedure Loaded; override;
    procedure LockFilterChanged(ALock: Boolean);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure RemoveGroupItem(AItem: TdxRibbonGalleryGroupItem);
    procedure UpdateEx(AParentKinds: TdxBarKinds = dxBarKindAny); override;

    property DefaultTextColor: TColor read FDefaultTextColor;
    property IsClone: Boolean read FIsClone;
    property RecalculatingOnFilterChanged: Boolean read FRecalculatingOnFilterChanged;
    property SelectedTextColor: TColor read FSelectedTextColor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoClick; override;
    function GetAddMessageName: string; override;
    function IsGroupVisible(AGroupIndex: Integer;
      AIgnoreVisibleProperty: Boolean = False): Boolean;
    procedure LockGroupItemClickEvents(ALock: Boolean);
    procedure ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem);
    property SelectedGroupItem: TdxRibbonGalleryGroupItem
      read FSelectedGroupItem write SetSelectedGroupItem;
  published
    property DropDownGallery: TdxRibbonDropDownGallery read FDropDownGallery write SetDropDownGallery;
    property ItemLinks;
    property ItemOptions;
    property GalleryGroups: TdxRibbonGalleryGroups read FGalleryGroups write SetGalleryGroups;
    property GalleryFilter: TdxRibbonGalleryFilter read FGalleryFilter write SetGalleryFilter;
    property GalleryOptions: TdxRibbonGalleryOptions read FGalleryOptions write SetGalleryOptions;
    property OnCloseUp;
    property OnFilterChanged: TdxRibbonGalleryFilterChangedEvent
      read FOnFilterChanged write FOnFilterChanged;
    property OnGroupItemClick: TdxRibbonGalleryGroupItemClickEvent read FOnGroupItemClick write FOnGroupItemClick;
    property OnHotTrackedItemChanged: TdxRibbonGalleryHotTrackedItemChangedEvent read FOnHotTrackedItemChanged write FOnHotTrackedItemChanged;
    property OnInitFilterMenu: TdxRibbonGalleryInitFilterMenuEvent
      read FOnInitFilterMenu write FOnInitFilterMenu;
    property OnPopup;
  end;

  { TdxRibbonGalleryController }

  TdxRibbonGalleryController = class
  private
    FGroupItemHotTrackEnabled: Boolean;
    FHintItem: TdxRibbonGalleryGroupItem;
    FKeyboardHotGroupItem: TdxRibbonGalleryGroupItem;
    FLastCommandFromKeyboard: Boolean;
    FMouseDownGroupItem: TdxRibbonGalleryGroupItem;
    procedure UnsetDownedFromGroupItem(AGroupItem: TdxRibbonGalleryGroupItem);
    function GetFirstGroupItem: TdxRibbonGalleryGroupItem;
    function GetGalleryItem: TdxRibbonGalleryItem;
    function GetGroupCount: Integer;
    function GetKeyboardHotGroupItem: TdxRibbonGalleryGroupItem;
    function GetViewInfo: TdxRibbonGalleryControlViewInfo;
    procedure GroupItemMouseMove(AGroupItem: TdxRibbonGalleryGroupItem;
      Shift: TShiftState; X, Y: Integer);
    procedure ProcessHotTrack(AGroupItem: TdxRibbonGalleryGroupItem);
    procedure SetHotGroupItem(const Value: TdxRibbonGalleryGroupItem);
  protected
    FOwner: TdxRibbonGalleryControl;

    procedure CancelHint;
    function GetGroupItem(AGroupIndex, AIndex: Integer): TdxRibbonGalleryGroupItem;
    procedure HotTrackItem(AItem: TdxRibbonGalleryGroupItem);
    procedure SetHintItem(AItem: TdxRibbonGalleryGroupItem);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseLeave; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;

    property GalleryItem: TdxRibbonGalleryItem read GetGalleryItem;
    property GroupCount: Integer read GetGroupCount;
    property GroupItemHotTrackEnabled: Boolean read FGroupItemHotTrackEnabled write FGroupItemHotTrackEnabled;
  public
    constructor Create(AOwner: TdxRibbonGalleryControl); virtual;
    property KeyboardHotGroupItem: TdxRibbonGalleryGroupItem
      read GetKeyboardHotGroupItem write FKeyboardHotGroupItem;
    property ViewInfo: TdxRibbonGalleryControlViewInfo read GetViewInfo;
  end;

  { TdxRibbonOnSubMenuGalleryController }

  TdxRibbonOnSubMenuGalleryController = class(TdxRibbonGalleryController)
  private
    FFilterMenuControl: TdxRibbonGalleryFilterMenuControl;
    FTempEventHandler: TNotifyEvent;
    procedure CheckFilterMenuHotTrack;
    procedure FilterMenuButtonClick(Sender: TObject);
    procedure FilterMenuCategoryButtonClick(Sender: TObject);
    procedure FilterMenuGroupButtonClick(Sender: TObject);
    function GetFirstGroupItem: TdxRibbonGalleryGroupItem;
    function GetGalleryWidth: Integer;
    function GetLastGroupItem: TdxRibbonGalleryGroupItem;
    function GetViewInfo: TdxRibbonOnSubMenuGalleryControlViewInfo;
    procedure HideFilterMenu;
    procedure InitFilterMenu(AItemLinks: TdxBarItemLinks);
    function IsFilterMenuInternalButton(AItem: TdxBarItem): Boolean;
    procedure ShowFilterMenu;
  protected
    procedure FilterMenuControlDestroyed;
    procedure HotTrackFirstGroupItem;
    procedure HotTrackLastGroupItem;
    function IsFilterMenuShowed: Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Navigation(ADirection: TcxAccessibilityNavigationDirection);
    procedure PageDown;
    procedure PageUp;
    procedure Tabulation;
  public
    property ViewInfo: TdxRibbonOnSubMenuGalleryControlViewInfo read GetViewInfo;
  end;

  { TdxRibbonGalleryFilterMenuControl }

  TdxRibbonGalleryFilterMenuControl = class(TdxBarInternalSubMenuControl)
  private
    FGalleryControl: TdxRibbonGalleryControl;
    FGalleryControlLink: TcxObjectLink;
  protected
    function GetBehaviorOptions: TdxBarBehaviorOptions; override;
    function GetPainter: TdxBarPainter; override;
    procedure ProcessMouseDownMessageForMeaningParent(AWnd: HWND; AMsg: UINT;
      const AMousePos: TPoint); override;
    property GalleryControl: TdxRibbonGalleryControl read FGalleryControl;
  public
    constructor Create(AGalleryControl: TdxRibbonGalleryControl); reintroduce;
    destructor Destroy; override;
  end;

  { TdxRibbonGalleryControl }

  TdxRibbonGalleryControl = class(TdxBarSubItemControl)
  private
    FCollapsed: Boolean;
    FController: TdxRibbonGalleryController;
    FDropDownGalleryItem: TdxRibbonGalleryItem;
    FHintBounds: TRect;
    FHintItem: TdxRibbonGalleryGroupItem;
    FIsClickOnItemsArea: Boolean;
    FIsClosingUpSubMenuControl: Boolean;
    FIsCollapsedAssigned: Boolean;
    FIsCreatingSubMenuControl: Boolean;
    FIsDroppingDown: Boolean;
    FIsNeedScrollBarLock: Boolean;
    FScrollBar: TdxRibbonGalleryScrollBar;
    FSizeChanged: Boolean;
    FLockCalcParts: Boolean;
    procedure DoScrollBarDropDown(Sender: TObject);
    procedure DrawInvalid(const ABounds: TRect);
    function GetCollapsed: Boolean;
    function GetItem: TdxRibbonGalleryItem;
    function GetViewInfo: TdxRibbonGalleryControlViewInfo;
    procedure ObtainTextColors;
    procedure SetCollapsed(Value: Boolean);
  protected
    //hints
    function DoHint(var ANeedDeactivate: Boolean; out AHintText: string; out AShortCut: string): Boolean; override;
    function GetHintPosition(const ACursorPos: TPoint; AHeight: Integer): TPoint; override;
    procedure UpdateHint(AHintItem: TdxRibbonGalleryGroupItem; const ABounds: TRect);

    function CalcDefaultWidth: Integer; virtual;
    function CalcMinHeight: Integer; virtual;
    procedure CalcParts; override;
    function CanClicked: Boolean; override;
    procedure ControlUnclick(ByMouse: Boolean); override;
    function CreateController: TdxRibbonGalleryController; virtual;
    procedure DoCloseUp(AHadSubMenuControl: Boolean); override;
    procedure DoDropDown(AByMouse: Boolean); override;
    procedure DropDown(AByMouse: Boolean); override;
    procedure EnabledChanged; override;
    function GetClientHeight: Integer;
    function GetClientWidth: Integer;
    function GetDefaultHeightInSubMenu: Integer; override;
    function GetDefaultWidthInSubMenu: Integer; override;
    //function GetMinWidth: Integer; override;
    function GetMouseWheelStep: Integer;
    procedure GetSubMenuControlPositionParams(out P: TPoint;
      out AOwnerWidth, AOwnerHeight: Integer); override;
    function InternalGetDefaultWidth: Integer; override;
    procedure Changed;
    function WantsKey(Key: Word): Boolean; override;

    procedure CalcDrawParams(AFull: Boolean = True); override;
    procedure ControlActivate(Immediately: Boolean); override;
    procedure ControlClick(AByMouse: Boolean; AKey: Char = #0); override;
    procedure CreateSubMenuControl; override;
    procedure DoCreateSubMenuControl; override;
    procedure DoPaint(ARect: TRect; PaintType: TdxBarPaintType); override;
    procedure FilterCaptionChanged;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetGroups: TdxRibbonGalleryGroups;
    function GetSubMenuControl: TdxBarSubMenuControl; override;
    function GetViewInfoClass: TdxBarItemControlViewInfoClass; override;
    function GetVisibleGroupCount: Integer;
    function HasSubMenu: Boolean; override;
    function IsDestroyOnClick: Boolean; override;
    function IsEnabledScrollBar: Boolean;
    function IsHiddenForCustomization: Boolean; override;
    function IsNeedScrollBar: Boolean; virtual;
    function IsValidPainter: Boolean;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure DoScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure DoScrollBarMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ScrollBarSetup;
    procedure SetScrollBarPosition(APosition: Integer); virtual;

    property Collapsed: Boolean read GetCollapsed write SetCollapsed;
    property Controller: TdxRibbonGalleryController read FController;
    property LockCalcParts: Boolean read FLockCalcParts write FLockCalcParts;
    property ScrollBar: TdxRibbonGalleryScrollBar read FScrollBar;
    property SizeChanged: Boolean read FSizeChanged write FSizeChanged;
  public
    constructor Create(AItemLink: TdxBarItemLink); override;
    destructor Destroy; override;
    procedure ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem);

    property ClientHeight: Integer read GetClientHeight;
    property ClientWidth: Integer read GetClientWidth;
    property Item: TdxRibbonGalleryItem read GetItem;
    property ViewInfo: TdxRibbonGalleryControlViewInfo read GetViewInfo;
  end;

  { TdxRibbonGalleryGroupElementViewInfo }

  TdxRibbonGalleryGroupElementViewInfo = class
  private
    FBounds: TRect;
    FOwner: TdxRibbonGalleryGroupViewInfo;
  protected
    function GetCaption: string; virtual; abstract;
    function GetFont: TFont; virtual;
    function GetGalleryItemControl: TdxRibbonGalleryControl;
    function GetTextFlags(AnAlignment: TAlignment): Integer;
  public
    constructor Create(AOwner: TdxRibbonGalleryGroupViewInfo);
    procedure Calculate(const ABounds: TRect); virtual;
    procedure Paint(ACanvas: TcxCanvas); virtual;

    property Bounds: TRect read FBounds;
    property Caption: string read GetCaption;
    property Font: TFont read GetFont;
    property Owner: TdxRibbonGalleryGroupViewInfo read FOwner;
  end;

  { TdxRibbonGalleryGroupHeaderViewInfo }

  TdxRibbonGalleryGroupHeaderViewInfo = class(TdxRibbonGalleryGroupElementViewInfo)
  private
    FTextBounds: TRect;
    function IsVisible: Boolean;
  protected
    function GetCaption: string; override;
    function GetHeight(AWidth: Integer; AWithSpaceAfterHeader: Boolean): Integer;
    function GetTextBounds: TRect; virtual;
  public
    procedure Calculate(const ABounds: TRect); override;
    procedure Paint(ACanvas: TcxCanvas); override;
    property TextBounds: TRect read FTextBounds;
  end;

  { TdxRibbonGalleryGroupItemViewInfo }

  TdxRibbonGalleryGroupItemViewInfo = class(TdxRibbonGalleryGroupElementViewInfo)
  private
    FCaptionBounds: TRect;
    FCaptionVisibilityState: TdxRibbonGalleryVisibilityState;
    FCaptionWidth: Integer;
    FChanged: Boolean;
    FDescriptionBounds: TRect;
    FDescriptionLines: TStrings;
    FDescriptionRowCount: Integer;
    FDescriptionSize: TSize;
    FDescriptionVisibilityState: TdxRibbonGalleryVisibilityState;
    FGroupItem: TdxRibbonGalleryGroupItem;
    FImageBounds: TRect;
    FPredefinedItemSize: TSize;
    procedure CheckCaptionFontStyle(AFont: TFont);
    function GetDescriptionLenght: Integer;
    function GetDescriptionRect: TRect;
    function GetDowned: Boolean;
    function GetHotGroupItem: TdxRibbonGalleryGroupItem;
    function GetHorizontalImageIndent: Integer;
    function GetImagePlace: TSize;
    function GetIsItemPullHighlighting: Boolean;
    function GetItemSize: TSize;
    function GetOptions: TdxRibbonGalleryGroupOptions;
    function GetPainter: TdxBarSkinnedPainter;
    function GetRectConsiderBounds(const ARect: TRect): TRect;
    function GetSelected: Boolean;
    function GetVerticalImageIndent: Integer;
    function IsCaptionVisible: Boolean;
    function IsDescriptionVisible: Boolean;
    function IsImageVisible: Boolean;
    function IsInplaceGallery: Boolean;
    function IsMergeItemsImages: Boolean;
    function IsThisGroupItem(AGroupItem: TdxRibbonGalleryGroupItem): Boolean;
    function ItemHeightWithoutImage(var ADescriptionRect: TRect): Integer;
    function ItemWidthWithoutImage(var ADescriptionRect: TRect): Integer;
    procedure ValidateDescriptionStrings(ACanvas: TcxCanvas);
  protected
    procedure DrawItemText(ACanvas: TcxCanvas); virtual;
    function GetCaption: string; override;
    function GetCaptionHeight: Integer; virtual;
    function GetCaptionWidth: Integer; virtual;
    function GetDescription: string; virtual;
    function GetDescriptionHeight(var ADescriptionRect: TRect): Integer; virtual;
    function GetDescriptionWidth(var ADescriptionRect: TRect): Integer; virtual;
    function GetHotTracked: Boolean;
    function GetSpaceBetweenItemCaptionAndDescription: Integer; virtual;
    function GetSpaceBetweenItemImageAndText: Integer; virtual;
    function GetImageSize: TSize; virtual;
    function GetUnsizedImageSize: TSize; virtual;

    function GetCaptionBounds: TRect; virtual;
    function GetDescriptionBounds: TRect; virtual;
    function GetImageBounds: TRect; virtual;
    function GetTextLeft: Integer; virtual;
    function GetTextRight: Integer; virtual;
    function GetTextTop: Integer; virtual;
    function IsBoldCaption: Boolean; virtual;

    procedure ResetCachedValues;
    procedure SetPredefinedItemSize(const AValue: TSize);

    property HorizontalImageIndent: Integer read GetHorizontalImageIndent;
    property HotGroupItem: TdxRibbonGalleryGroupItem read GetHotGroupItem;
    property IsItemPullHighlighting: Boolean read GetIsItemPullHighlighting;
    property ItemSize: TSize read GetItemSize;
    property Options: TdxRibbonGalleryGroupOptions read GetOptions;
    property Painter: TdxBarSkinnedPainter read GetPainter;
    property VerticalImageIndent: Integer read GetVerticalImageIndent;
  public
    constructor Create(AOwner: TdxRibbonGalleryGroupViewInfo; AGroupItem: TdxRibbonGalleryGroupItem);
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); override;
    procedure Paint(ACanvas: TcxCanvas); override;
    property Description: string read GetDescription;
    property GroupItem: TdxRibbonGalleryGroupItem read FGroupItem;
  end;

  { TdxRibbonGalleryGroupViewInfo }

  TdxRibbonGalleryGroupRepaintPart = (ggrpAll, ggrpBefore, ggrpAfter, ggrpBetween);

  TdxRibbonGalleryGroupViewInfo = class
  private
    FBounds: TRect;
    FGroup: TdxRibbonGalleryGroup;
    FHeader: TdxRibbonGalleryGroupHeaderViewInfo;
    FItems: TcxObjectList;
    FItemSize: TSize;
    FOwner: TdxRibbonGalleryControlViewInfo;
    function GetFirstItemInGroupRow(ARowIndex, AColumnCount: Integer): Integer;
    function GetFont: TFont;
    function GetItem(Index: Integer): TdxRibbonGalleryGroupItemViewInfo;
    function GetItemCount: Integer;
    function GetItemSize: TSize;
    function GetOptions: TdxRibbonGalleryGroupOptions;
    function GetPainter: TdxBarSkinnedPainter;
  protected
    function CalculateItemSize(const APredefinedItemSize: TSize): TSize;
    procedure ClearItems;
    procedure CreateGroupItem(AItemIndex: Integer; const ABounds: TRect);
    function GetColumnCount(AWidth: Integer): Integer; virtual;
    function GetColumnCountInRow(ARow: Integer; AGroupWidth: Integer): Integer; virtual;
    function GetColumnLeft(AColumnIndex: Integer; AGroupLeft: Integer): Integer; virtual;
    function GetColumnWidth: Integer;
    function GetGroupWidth: Integer;
    function GetHeaderBounds(AGroupBounds: TRect): TRect;
    function GetItemColumn(AIndex: Integer; AGroupWidth: Integer): Integer;
    function GetItemIndex(ARow, AColumn: Integer; AGroupWidth: Integer): Integer;
    function GetItemRow(AGroupItemIndex: Integer; AGroupWidth: Integer): Integer;
    function GetLastItemInGroupRow(ARowIndex, AColumnCount: Integer): Integer;
    function GetRowCount(AGroupWidth: Integer): Integer;
    function GetRowHeight: Integer;
    function GetRowTop(ARowIndex: Integer; AGroupTop: Integer; AGroupWidth: Integer): Integer; virtual;
    function GetSpaceBetweenItems(IsAflat: Boolean): Integer;
    procedure RepaintChainOfItems(AnItemIndex: Integer; IsHotTrack: Boolean;
      ACanvas: TcxCanvas; APart: TdxRibbonGalleryGroupRepaintPart = ggrpAll;
      AnItemIndex2: Integer = 0);
    procedure SetBounds(const ABounds: TRect);

    property Font: TFont read GetFont;
    property Options: TdxRibbonGalleryGroupOptions read GetOptions;
    property Painter: TdxBarSkinnedPainter read GetPainter;
  public
    constructor Create(AOwner: TdxRibbonGalleryControlViewInfo;
      AGroup: TdxRibbonGalleryGroup; const AItemSize: TSize);
    destructor Destroy; override;
    procedure Calculate(AGroupTop, AGroupBottom: Integer; const AControlClientRect: TRect);
    function GetHeight(AWidth: Integer): Integer;
    procedure Paint(ACanvas: TcxCanvas);
    property Bounds: TRect read FBounds;
    property Group: TdxRibbonGalleryGroup read FGroup;
    property Header: TdxRibbonGalleryGroupHeaderViewInfo read FHeader;
    property ItemCount: Integer read GetItemCount;
    property Items[Index: Integer]: TdxRibbonGalleryGroupItemViewInfo read GetItem;
    property ItemSize: TSize read FItemSize;
    property Owner: TdxRibbonGalleryControlViewInfo read FOwner;
  end;

  { TdxRibbonGalleryControlViewInfo }

  TdxRibbonGalleryControlViewInfo = class(TdxBarItemControlViewInfo)
  private
    FDontDisplayHotTrackedGroupItem: Integer;
    FDontDisplayGroupHeaderWhenHotTrackingGroupItem: Integer;
    FDownedGroupItem: TdxRibbonGalleryGroupItem;
    FGlobalItemSize: TSize;
    FGroupItemStoredSizes: array of TSize;
    FHotGroupItem: TdxRibbonGalleryGroupItem;
    FLayoutOffset: Integer;

    function GetGroupCount: Integer;
    function GetGroups(Index: Integer): TdxRibbonGalleryGroupViewInfo;
    function GetGroupItemSize(AGroupIndex: Integer): TSize;

    procedure CalculateGlobalItemSize;
    function GetControl: TdxRibbonGalleryControl;
    function GetGalleryBounds: TRect;
    function GetGalleryItem: TdxRibbonGalleryItem;
    function GetGalleryOptions: TdxRibbonGalleryOptions;
    function GetGallerySize: TSize;
    function GetPainter: TdxBarSkinnedPainter;
    function GetScrollBarBounds: TRect;
    function GetScrollBarWidth: Integer;

    procedure DrawGroupItem(const AGroupItem: TdxRibbonGalleryGroupItem);
    procedure RepaintChainOfGroups(ANewItem, AOldItem: TdxRibbonGalleryGroupItem);
  protected
    FGroups: TcxObjectList;
    procedure DisplayGroupItem(AGroupItem: TdxRibbonGalleryGroupItem); virtual;
    procedure DrawBackground(const R: TRect); virtual; abstract;
    procedure DrawSelectedGroupItem(ASelectedGroupItem, AOldSelectedGroupItem: TdxRibbonGalleryGroupItem);
    procedure GalleryChanged;
    function GetAbsoluteGroupTop(AGroupIndex: Integer;
      AWidth: Integer): Integer;
    function GetControlBounds: TRect; virtual;
    function GetGalleryHeight(AWidth: Integer): Integer; virtual;
    function GetGalleryMargins: TRect; virtual; abstract;
    function GetGroupItemCount(ALastGroupIndex: Integer): Integer;
    function GetHeight(AWidth: Integer): Integer; virtual;
    function GetLayoutWidth(AColumnCount: Integer; out AGroupItemWidthIsNull: Boolean): Integer; virtual; abstract;
    function GetMaxGroupItemSize: TSize; virtual;
    function GetGroupItem(X, Y: Integer): TdxRibbonGalleryGroupItem;
    function GetGroupItemStoredSize(AGroupIndex: Integer): TSize;
    function GetGroupItemViewInfo(AGroupItem: TdxRibbonGalleryGroupItem): TdxRibbonGalleryGroupItemViewInfo;
    function GetLeftLayoutIndent: Integer; virtual;
    function GetMinSize: TSize; virtual; abstract;
    function GetNextButtonEnabled: Boolean;
    function GetPreviousButtonEnabled: Boolean;
    function GetRightLayoutIndent: Integer; virtual;
    function GetVisibleGroupIndex(AStartGroupIndex: Integer; AIncreaseIndex: Boolean): Integer;
    function GetVisibleNotEmptyGroupIndex(AStartGroupIndex: Integer; AIncreaseIndex: Boolean): Integer;
    function InternalGetScrollBarWidth: Integer; virtual; abstract;
    function IsGroupHeaderVisible: Boolean; virtual;
    function IsGroupItemAtThisPlace(X, Y: Integer): Boolean;
    function IsInRibbon: Boolean; virtual;
    procedure RemoveGroupItem(AItem: TdxRibbonGalleryGroupItem);
    procedure Changed; virtual;
    procedure SetDownedGroupItem(const Value: TdxRibbonGalleryGroupItem);
    procedure SetGroupItemStoredSize(const Value: TSize; AGroupIndex: Integer);
    procedure SetHotGroupItem(Value: TdxRibbonGalleryGroupItem);
    procedure ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem); virtual;

    property DontDisplayHotTrackedGroupItem: Integer read FDontDisplayHotTrackedGroupItem write FDontDisplayHotTrackedGroupItem;
    property DontDisplayGroupHeaderWhenHotTrackingGroupItem: Integer read FDontDisplayGroupHeaderWhenHotTrackingGroupItem write FDontDisplayGroupHeaderWhenHotTrackingGroupItem;
    property DownedGroupItem: TdxRibbonGalleryGroupItem read FDownedGroupItem;
    property GalleryBounds: TRect read GetGalleryBounds;
    property GalleryItem: TdxRibbonGalleryItem read GetGalleryItem;
    property GalleryOptions: TdxRibbonGalleryOptions read GetGalleryOptions;
    property GallerySize: TSize read GetGallerySize;
    property GlobalItemSize: TSize read FGlobalItemSize;
    property HotGroupItem: TdxRibbonGalleryGroupItem read FHotGroupItem write SetHotGroupItem;
    property LayoutOffset: Integer read FLayoutOffset;
    property Painter: TdxBarSkinnedPainter read GetPainter;
    property ScrollBarWidth: Integer read GetScrollBarWidth;
  public
    constructor Create(AControl: TdxBarItemControl); override;
    destructor Destroy; override;
    procedure Calculate(ALayoutOffset: Integer; AScrollCode: TScrollCode); virtual;
    function IsCollapsed: Boolean; virtual; abstract;
    procedure Paint;
    property Control: TdxRibbonGalleryControl read GetControl;
    property GroupCount: Integer read GetGroupCount;
    property Groups[Index: Integer]: TdxRibbonGalleryGroupViewInfo read GetGroups;
    property ScrollBarBounds: TRect read GetScrollBarBounds;
  end;

  { TdxInRibbonGalleryControlViewInfo }

  TdxInRibbonGalleryControlViewInfo = class(TdxRibbonGalleryControlViewInfo,
    IdxBarMultiColumnItemControlViewInfo)
  private
    FCollapsed: Boolean;
    FColumnCount: Integer;
    FControlHeight: Integer;
    FIsScrolling: Boolean;
    FRowCount: Integer;
    FScrollingBreak: Boolean;
    FScrollingRowCounter: Integer;
    FShowGroupItem: TdxRibbonGalleryGroupItem;
    FTopVisibleRow: Integer;
    FWidthForColumnCountInfos: array of TdxBarItemCachedWidthInfo;
    procedure FillGroupItemList(AFirstVisibleRow, ALastVisibleRow, AColumnCount: Integer; AList: TObjectList);
    function GetControlHeight: Integer;
    function GetVisibleRowCount: Integer;

    // IdxBarMultiColumnItemControlViewInfo
    function CanCollapse: Boolean;
    function GetCollapsed: Boolean;
    function GetColumnCount: Integer;
    function GetMaxColumnCount: Integer;
    function GetRowIndex(AGroupItemIndex, AColumnCount: Integer): Integer;
    function GetMinColumnCount: Integer;
    function GetSpaceBetweenItems(IsAflat: Boolean): Integer;
    function GetWidthForColumnCount(AColumnCount: Integer): Integer;
    function IsScrollingPossible(ARowDelta: Integer): Boolean;
    procedure ScrollingRowCounterRelease;
    procedure SetCollapsed(Value: Boolean);
    procedure SetColumnCount(Value: Integer);
    procedure SetScrollingRowCounter(Value: Integer);
  protected
    procedure BoundsCalculated; override;
    procedure CalculateLayout(ALayoutOffset, AColumnCount: Integer; AGroupItemsList: TObjectList);
    function CorrectGroupItemSize(const AGroupItemSize: TSize): TSize;
    procedure DoScrolling(ARowDelta: Integer);
    procedure DrawBackground(const R: TRect); override;
    function GetControlMargins: TRect; virtual;
    function GetGalleryMargins: TRect; override;
    function GetLayoutWidth(AColumnCount: Integer; out AGroupItemWidthIsNull: Boolean): Integer; override;
    function GetMaxGroupItemSize: TSize; override;
    function GetBottomLayoutIndent: Integer;
    function GetLeftLayoutIndent: Integer; override;
    function GetRightLayoutIndent: Integer; override;
    function GetTopLayoutIndent: Integer;
    function InternalGetScrollBarWidth: Integer; override;
    function IsInRibbon: Boolean; override;
    procedure ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem); override;
    property ControlHeight: Integer read GetControlHeight;
  public
    procedure Calculate(ALayoutOffset: Integer; AScrollCode: TScrollCode); override;
    function IsCollapsed: Boolean; override;
    procedure ResetCachedValues; override;
    property TopVisibleRow: Integer read FTopVisibleRow;
  end;

  { TdxRibbonOnSubMenuGalleryControlViewInfo }

  TdxRibbonOnSubMenuGalleryControlViewInfo = class(TdxRibbonGalleryControlViewInfo)
  private
    FFilterBandContentRect: TRect;
    FFilterBandHotTrack: Boolean;
    FFilterBandRect: TRect;
    FGroupItemDescriptionRectCache: TObjectList;
    procedure CalculateFilterBand;
    procedure DrawFilterBand;
    procedure DrawFilterCaption;
    function GetBottomSeparatorHeight: Integer;
    function GetFilterBandHeight: Integer;
    function GetHeightByRowCount(AWidth: Integer): Integer;
    function GetSpaceBetweenItems(AGroupIndex: Integer; IsAflat: Boolean): Integer;
    procedure InitializeGroupItemDescriptionRectCache;
    function NeedsDrawBottomSeparator: Boolean;
  protected
    procedure DisplayGroupItem(AGroupItem: TdxRibbonGalleryGroupItem); override;
    procedure DrawBackground(const R: TRect); override;
    function GetControlBounds: TRect; override;
    function GetGalleryHeight(AWidth: Integer): Integer; override;
    function GetGalleryMargins: TRect; override;
    function GetGroupItemDescriptionRect(AGroupIndex, AnItemIndex: Integer): TRect;
    function GetHeight(AWidth: Integer): Integer; override;
    function GetLayoutWidth(AColumnCount: Integer; out AGroupItemWidthIsNull: Boolean): Integer; override;
    procedure GroupItemYRange(const AGroupItem: TdxRibbonGalleryGroupItem;
      var ATop, ABottom: Integer);
    function GetMinSize: TSize; override;
    function InternalGetScrollBarWidth: Integer; override;
    procedure Changed; override;
    procedure SetGroupItemDescriptionRect(AGroupIndex, AnItemIndex: Integer; ARect: TRect);
  public
    destructor Destroy; override;
    procedure Calculate(ALayoutOffset: Integer; AScrollCode: TScrollCode); override;
    procedure GetFilterMenuShowingParams(out APosition: TPoint;
      out AOwnerHeight: Integer);
    function IsCollapsed: Boolean; override;
    function IsPtInFilterBandHotTrackArea(const P: TPoint): Boolean;
    procedure RepaintFilterBand;
    procedure SetFilterBandHotTrack(AValue: Boolean);
  end;

  { TdxRibbonGalleryControlAccessibilityHelper }

  TdxRibbonGalleryControlAccessibilityHelper = class(TdxBarSubItemControlAccessibilityHelper)
  private
    function GetControl: TdxRibbonGalleryControl;
    function GetOnSubMenuController: TdxRibbonOnSubMenuGalleryController;
  protected
    // IdxBarAccessibilityHelper
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    function IsNavigationKey(AKey: Word): Boolean; override;

    procedure GetKeyTipData(AKeyTipsData: TList); override;
    procedure GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo); override;
    procedure OnSubMenuHotTrack(
      ANavigationDirection: TdxRibbonDropDownGalleryNavigationDirection);
    function ShowDropDownWindow: Boolean; override;

    property Control: TdxRibbonGalleryControl read GetControl;
    property OnSubMenuController: TdxRibbonOnSubMenuGalleryController
      read GetOnSubMenuController;
  end;

  { TdxRibbonDropDownGalleryControlAccessibilityHelper }

  TdxRibbonDropDownGalleryControlAccessibilityHelper = class(TdxBarSubMenuControlAccessibilityHelper)
  private
    function GetBarControl: TdxRibbonDropDownGalleryControl;
    function GetInternalGalleryItemControlAccessibilityHelper: TdxRibbonGalleryControlAccessibilityHelper;
  protected
    // IdxBarAccessibilityHelper
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    function IsNavigationKey(AKey: Word): Boolean; override;

    procedure HandleVertNavigationKey(AUpKey, AFocusItemControl: Boolean); override;
    property BarControl: TdxRibbonDropDownGalleryControl read GetBarControl;
    property InternalGalleryItemControlAccessibilityHelper: TdxRibbonGalleryControlAccessibilityHelper
      read GetInternalGalleryItemControlAccessibilityHelper;
  end;

  { TdxRibbonGalleryScrollBarViewInfo }

  TdxRibbonGalleryScrollBarViewInfo = class(TcxScrollBarViewInfo)
  private
    FDropDownButtonRect: TRect;
  protected
    procedure CalculateRects; override;
  public
    property DropDownButtonRect: TRect read FDropDownButtonRect;
  end;

  { TdxRibbonGalleryScrollBar }

  TdxRibbonGalleryScrollBar = class(TcxScrollBar)
  private
    FGalleryControl: TdxRibbonGalleryControl;
    FIsDropDownButtonPressed: Boolean;
    FOnDropDown: TNotifyEvent;
    procedure DoDropDown;
    function GetButtonSkinState(AState: TcxButtonState): Integer;
    function GetPainter: TdxBarSkinnedPainter;
    function GetViewInfo: TdxRibbonGalleryScrollBarViewInfo;
    function IsButtonEnabled(AButtonKind: TdxInRibbonGalleryScrollBarButtonKind): Boolean;
    function IsDropDownButtonUnderMouse: Boolean;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
  protected
    procedure DoPaint(ACanvas: TcxCanvas); override;
    procedure DrawScrollBarPart(ACanvas: TcxCanvas; const R: TRect;
      APart: TcxScrollBarPart; AState: TcxButtonState); override;
    function GetViewInfoClass: TcxScrollBarViewInfoClass; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    property GalleryControl: TdxRibbonGalleryControl read FGalleryControl;
    property Painter: TdxBarSkinnedPainter read GetPainter;
    property ViewInfo: TdxRibbonGalleryScrollBarViewInfo read GetViewInfo;
  public
    constructor Create(AGalleryControl: TdxRibbonGalleryControl); reintroduce;
    function IsDropDownStyle: Boolean;
    property IsDropDownButtonPressed: Boolean read FIsDropDownButtonPressed;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
  end;

  { TdxRibbonDropDownGallery }

  TdxRibbonDropDownGallery = class(TdxRibbonPopupMenu)
  private
    FGalleryItem: TdxRibbonGalleryItem;
    procedure SetGalleryItem(Value: TdxRibbonGalleryItem);
  protected
    function CreateBarControl: TCustomdxBarControl; override;
    function GetControlClass: TCustomdxBarControlClass; override;
    function HasValidGalleryItem: Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    destructor Destroy; override;
  published
    property GalleryItem: TdxRibbonGalleryItem read FGalleryItem
      write SetGalleryItem;
  end;

  { TdxRibbonDropDownGalleryGalleryItemItemLinks }

  TdxRibbonDropDownGalleryGalleryItemItemLinks = class(TdxBarSubMenuControlItemLinks)
  public
    function CanContainItem(AItem: TdxBarItem; out AErrorText: string): Boolean; override;
  end;

  { TdxRibbonDropDownGalleryControlPainter }

  TdxRibbonDropDownGalleryControlPainter = class(TdxRibbonBarPainter)
  protected
    function HasSizingBand(AGalleryControl: TdxRibbonDropDownGalleryControl): Boolean;
  public
    function GetSizingBandHeight(
      AGalleryControl: TdxRibbonDropDownGalleryControl): Integer; virtual;
    function PtInSizingArea(AGalleryControl: TdxRibbonDropDownGalleryControl;
      const P: TPoint): Boolean; virtual;
    procedure SubMenuControlDrawBorder(ABarSubMenuControl: TdxBarSubMenuControl;
      DC: HDC; R: TRect); override;
  end;

  { TdxRibbonDropDownGalleryControl }

  TdxDropDownGalleryResizingState = (grsNone, grsTop, grsTopRight, grsBottom,
    grsBottomRight);

  TdxRibbonDropDownGalleryControl = class(TdxRibbonPopupMenuControl)
  private
    FGalleryItem: TdxRibbonGalleryItem;
    FGalleryItemItemLinks: TdxRibbonDropDownGalleryGalleryItemItemLinks;
    FHeight: Integer;
    FHitTest: Integer;
    FInternalPainter: TdxRibbonDropDownGalleryControlPainter;
    FIsResizingAssigned: Boolean;
    FMouseResizingDelta: TPoint;
    FMouseWheelStep: Integer;
    FResizingState: TdxDropDownGalleryResizingState;
    FResizing: TdxRibbonGallerySubMenuResizing;
    FUseInternalSizeValue: Boolean;
    procedure DoResizing;
    function GetInternalGalleryItemControl: TdxRibbonGalleryControl;
    function GetInternalPainter: TdxRibbonDropDownGalleryControlPainter;
    function GetMouseWheelStep: Integer;
    function GetResizing: TdxRibbonGallerySubMenuResizing;
    function HitTestToResizingState: TdxDropDownGalleryResizingState;
    function IsHitTestResizing: Boolean;
    function IsResizing: Boolean;
    procedure SetResizing(Value: TdxRibbonGallerySubMenuResizing);
    procedure StartResizing;
    procedure StopResizing;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SetCursor;
  protected
    procedure CalcColumnItemRects(ATopIndex: Integer;
      out ALastItemBottom: Integer); override;
    function ChangeSizeByChildItemControl(out ASize: TSize): Boolean; override;
    procedure CreateWnd; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DoNCPaint(DC: HDC; const ARect: TRect); override;
    function DoFindLinkWithAccel(AKey: Word; AShift: TShiftState; ACurrentLink: TdxBarItemLink): TdxBarItemLink; override;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetClientOffset(
      AIncludeDetachCaption: Boolean = True): TRect; override;
    function GetItemsPaneSize: TSize; override;
    function GetMinSize: TSize; virtual;
    function GetViewInfoClass: TCustomdxBarControlViewInfoClass; override;
    function IsControlExists(ABarItemControl: TdxBarItemControl): Boolean; override;
    function IsSizingBandAtBottom: Boolean;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function MustFitInWorkAreaWidth: Boolean; override;
    function NeedsMouseWheel: Boolean; override;
    function NeedsSelectFirstItemOnDropDownByKey: Boolean; override;
    procedure Resize; override;
    procedure UpdateItem(AControl: TdxBarItemControl); override;
    property GalleryItem: TdxRibbonGalleryItem read FGalleryItem write FGalleryItem;
    property InternalGalleryItemControl: TdxRibbonGalleryControl
      read GetInternalGalleryItemControl;
    property InternalPainter: TdxRibbonDropDownGalleryControlPainter
      read GetInternalPainter;
    property Resizing: TdxRibbonGallerySubMenuResizing read GetResizing
      write SetResizing;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

  { TdxRibbonDropDownGalleryControlViewInfo }

  TdxRibbonDropDownGalleryControlViewInfo = class(TdxBarSubMenuControlViewInfo)
  private
    function GetBarControl: TdxRibbonDropDownGalleryControl;
  public
    procedure Calculate; override;
    property BarControl: TdxRibbonDropDownGalleryControl read GetBarControl;
  end;

  { TdxRibbonGalleryGroupItemActionLink }

  TdxRibbonGalleryGroupItemActionLink = class(TActionLink)
  protected
    FClient: TdxRibbonGalleryGroupItem;
    procedure AssignClient(AClient: TObject); override;
    function IsCaptionLinked: Boolean; override;
    function IsCheckedLinked: Boolean; override;
    function IsImageIndexLinked: Boolean; override;
    function IsOnExecuteLinked: Boolean; override;
    procedure SetCaption(const Value: string); override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetImageIndex(Value: Integer); override;
    procedure SetOnExecute(Value: TNotifyEvent); override;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Math, cxContainer, dxBarSkinConsts, dxBarStrs, dxOffice11;

const
  DropDownInflateX = 3;
  DropDownInflateY = 3;
  DropDownOffsetX = 1;
  DropDownOffsetY = 1;

  FilterArrowOffset = 1;
  FilterArrowSize = 4;
  FilterBandOffset = 1;
  FilterMenuLeftBoundCorrection = 1;
  GroupHeaderCaptionOffset = 11;

  FilterCaptionDelimiter = ',';

type
  TRelativeLineLocation = (rllBefore, rllInside, rllAfter);

  TCollectionItemAccess = class(TCollectionItem);
  TCustomdxBarControlAccess = class(TCustomdxBarControl);
  TcxSizeAccess = class(TcxSize);
  TdxBarItemControlAccess = class(TdxBarItemControl);
  TdxBarItemLinkAccess = class(TdxBarItemLink);
  TdxBarItemLinksAccess = class(TdxBarItemLinks);
  TdxBarManagerAccess = class(TdxBarManager);
  TdxBarPainterAccess = class(TdxBarPainter);
  TdxBarSkinnedPainterAccess = class(TdxBarSkinnedPainter);

var
  FDontShowFilterMenuOnMouseDown: Boolean;

function AreLinesIntersected(ABegin1, AEnd1, ABegin2, AEnd2: Integer): Boolean;

  function IsPointOnLine(ABegin, AEnd, APoint: Integer): Boolean;
  begin
    Result := (ABegin <= APoint) and (APoint <= AEnd);
  end;

begin
  Result := (IsPointOnLine(ABegin1, AEnd1, ABegin2)) or
            (IsPointOnLine(ABegin1, AEnd1, AEnd2)) or
            (IsPointOnLine(ABegin2, AEnd2, ABegin1));
end;

function AreLinesIntersectedStrictly(ABegin1, AEnd1, ABegin2,
  AEnd2: Integer): Boolean;

  function IsPointOnLine(ABegin, AEnd, APoint: Integer): Boolean;
  begin
    Result := (ABegin < APoint) and (APoint < AEnd)
  end;

begin
  Result := (IsPointOnLine(ABegin1, AEnd1, ABegin2)) or
            (IsPointOnLine(ABegin1, AEnd1, AEnd2)) or
            (IsPointOnLine(ABegin2, AEnd2, ABegin1)) or
            (IsPointOnLine(ABegin2, AEnd2, AEnd1)) or
            (ABegin1 = ABegin2) and (AEnd1 = AEnd2) or
            (ABegin1 = AEnd2) and (AEnd1 = ABegin2);
end;

function GetGroupViewInfo(AGalleryGroups: TdxRibbonGalleryGroups;
  AGalleryControlViewInfo: TdxRibbonGalleryControlViewInfo;
  AGroupIndex: Integer;
  out DestroyAfterUse: Boolean): TdxRibbonGalleryGroupViewInfo;
var
  I: Integer;
begin
  Result := nil;
  DestroyAfterUse := False;
  if (AGalleryControlViewInfo.GalleryItem.IsGroupVisible(AGroupIndex)) and
    (0 <= AGroupIndex) and (AGroupIndex < AGalleryGroups.Count) then
  begin
    for I := 0 to AGalleryControlViewInfo.GroupCount - 1 do
      if AGalleryControlViewInfo.Groups[I].Group.Index = AGroupIndex then
      begin
        Result := AGalleryControlViewInfo.Groups[I];
        Break;
      end;
    if Result = nil then
    begin
      Result := TdxRibbonGalleryGroupViewInfo.Create(AGalleryControlViewInfo,
        AGalleryGroups[AGroupIndex], cxNullSize);
      DestroyAfterUse := True;
    end;
  end;
end;

function GetOuterGroupItem(AItem1,
  AItem2: TdxRibbonGalleryGroupItem;
  ADirection: TdxRibbonGalleryItemPullHighlightingDirection): TdxRibbonGalleryGroupItem;
begin
  Result := nil;
  if AItem1 <> nil then
  begin
    if AItem2 <> nil then
    begin
      if AItem1.Group.Index > AItem2.Group.Index then
        Result := AItem1
      else
        if AItem1.Group.Index < AItem2.Group.Index then
          Result := AItem2
        else
        begin
          if AItem1.Index > AItem2.Index then
            Result := AItem1
          else
            Result := AItem2;
        end;
    end
    else
      Result := AItem1;
  end
  else
    if AItem2 <> nil then
      Result := AItem2;
  if (ADirection = gphdFinishToStart) and (AItem1 <> nil) and (AItem2 <> nil) then
  begin
    if Result = AItem1 then
      Result := AItem2
    else
      Result := AItem1;
  end;
end;

function GetItemPullHighlightingIdentifier(AGroupItem: TdxRibbonGalleryGroupItem): Integer;
var
  AGeneralItemPullHighlighting: TdxRibbonGalleryItemPullHighlighting;
  AGroup: TdxRibbonGalleryGroup;
begin
  AGroup := AGroupItem.Group;
  AGeneralItemPullHighlighting := AGroup.GalleryItem.GalleryOptions.ItemPullHighlighting;
  if (AGroup.Options.ItemPullHighlighting.Active = AGeneralItemPullHighlighting.Active) and
    (AGroup.Options.ItemPullHighlighting.Direction = AGeneralItemPullHighlighting.Direction) then
    Result := -1
  else
    Result := AGroup.Index;
end;

function IsFirstLineShorterOrEqualThanSecond(ABegin1, AEnd1, ABegin2,
  AEnd2: Integer): Boolean;
begin
  Result := AEnd1 - ABegin1 <= AEnd2 - ABegin2;
end;

function RelativeLocationOfLines(ShortLineBegin, ShortLineEnd, LongLineBegin,
  LongLineEnd: Integer): TRelativeLineLocation;
begin
  if (ShortLineBegin < LongLineBegin) then
    Result := rllBefore
  else
    if (LongLineEnd < ShortLineEnd) then
      Result := rllAfter
    else
      Result := rllInside;
end;

function CanUseSize(const ASize: TSize): Boolean;
begin
  Result := (ASize.cx > 0) and (ASize.cy > 0);
end;

{ TcxItemSize }

procedure TcxItemSize.DoChange;
begin
  Assigned := True;
  inherited;
end;

function TcxItemSize.GetValue(Index: Integer): Integer;
begin
  if (Parent = nil) or Assigned then
    Result := inherited GetValue(Index)
  else
    Result := Parent.GetValue(Index);
end;

function TcxItemSize.IsSizeStored(Index: Integer): Boolean;
begin
  Result := ((Parent = nil) or Assigned) and inherited IsSizeStored(Index);
end;

procedure TcxItemSize.SetAssigned(const Value: Boolean);
begin
  FAssigned := Value;
  if not Value then
    PSize(Data)^ := cxNullSize;
end;

procedure TcxItemSize.SetSize(const Value: TSize);
begin
  Assigned := True;
  inherited SetSize(Value);
end;

{ TdxRibbonGalleryItemPullHighlighting }

procedure TdxRibbonGalleryItemPullHighlighting.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryItemPullHighlighting then
  begin
    Active := TdxRibbonGalleryItemPullHighlighting(Source).Active;
    Direction := TdxRibbonGalleryItemPullHighlighting(Source).Direction;
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonGalleryItemPullHighlighting.DoChange;
begin
  IsAssigned := True;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TdxRibbonGalleryItemPullHighlighting.IsActiveStored: Boolean;
begin
  Result := ((Parent = nil) or IsAssigned) and FActive;
end;

function TdxRibbonGalleryItemPullHighlighting.IsDirectionStored: Boolean;
begin
  Result := ((Parent = nil) or IsAssigned) and (FDirection <> gphdStartToFinish);
end;

function TdxRibbonGalleryItemPullHighlighting.GetActive: Boolean;
begin
  if (Parent = nil) or IsAssigned then
    Result := FActive
  else
    Result := Parent.GetActive;
end;

function TdxRibbonGalleryItemPullHighlighting.GetDirection: TdxRibbonGalleryItemPullHighlightingDirection;
begin
  if (Parent = nil) or IsAssigned then
    Result := FDirection
  else
    Result := Parent.GetDirection;
end;

procedure TdxRibbonGalleryItemPullHighlighting.SetActive(Value: Boolean);
begin
  FActive := Value;
  DoChange;
end;

procedure TdxRibbonGalleryItemPullHighlighting.SetIsAssigned(Value: Boolean);
begin
  FIsAssigned := Value;
  if not Value then
  begin
    if Parent = nil then
    begin
      FActive := False;
      FDirection := gphdStartToFinish;
    end
    else
    begin
      FActive := Parent.Active;
      FDirection := Parent.Direction;
    end;
  end;
end;

procedure TdxRibbonGalleryItemPullHighlighting.SetDirection(
  Value: TdxRibbonGalleryItemPullHighlightingDirection);
begin
  FDirection := Value;
  DoChange;
end;

{ TdxRibbonGalleryCustomOptions }

constructor TdxRibbonGalleryCustomOptions.Create(AOwner: TdxRibbonGalleryItem);
begin
  inherited Create;
  FOwner := AOwner;

  FImageChangeLink := TChangeLink.Create;
  FItemImageSize := TcxItemSize.Create(Self);
  FItemImageSize.OnChange := ItemImageSizeChange;
  FItemSize := TcxItemSize.Create(Self);
  FItemSize.OnChange := ItemSizeChange;
  FItemTextKind := itkCaption;
  FItemPullHighlighting := TdxRibbonGalleryItemPullHighlighting.Create;
  FItemPullHighlighting.OnChange := ItemPullHighlightingChange;
end;

destructor TdxRibbonGalleryCustomOptions.Destroy;
begin
  Images := nil;
  FreeAndNil(FImageChangeLink);
  FreeAndNil(FItemImageSize);
  FreeAndNil(FItemSize);
  FreeAndNil(FItemPullHighlighting);
  inherited Destroy;
end;

procedure TdxRibbonGalleryCustomOptions.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryCustomOptions then
  begin
    Images := TdxRibbonGalleryCustomOptions(Source).Images;
    ItemImagePosition := TdxRibbonGalleryCustomOptions(Source).ItemImagePosition;
    ItemImageSize := TdxRibbonGalleryCustomOptions(Source).ItemImageSize;
    ItemTextKind := TdxRibbonGalleryCustomOptions(Source).ItemTextKind;
    ItemSize := TdxRibbonGalleryCustomOptions(Source).ItemSize;
    ItemPullHighlighting := TdxRibbonGalleryOptions(Source).ItemPullHighlighting;
    SpaceAfterGroupHeader := TdxRibbonGalleryCustomOptions(Source).SpaceAfterGroupHeader;
    SpaceBetweenItemsHorizontally := TdxRibbonGalleryCustomOptions(Source).SpaceBetweenItemsHorizontally;
    SpaceBetweenItemsVertically := TdxRibbonGalleryCustomOptions(Source).SpaceBetweenItemsVertically;
    SpaceBetweenItemCaptionAndDescription := TdxRibbonGalleryCustomOptions(Source).SpaceBetweenItemCaptionAndDescription;
    SpaceBetweenItemImageAndText := TdxRibbonGalleryCustomOptions(Source).SpaceBetweenItemImageAndText;
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonGalleryCustomOptions.Changed;
begin
  FOwner.GalleryChanged;
end;

procedure TdxRibbonGalleryCustomOptions.CheckIntRange(var Value: Integer);
begin
  Value := Max(0, Value);
end;

procedure TdxRibbonGalleryCustomOptions.CheckItemsSpaceRange(var Value: Integer);
begin
  Value := Max(-1, Value);
end;

procedure TdxRibbonGalleryCustomOptions.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('SpaceBetweenItems', ReadSpaceBetweenItemsProperty,
    WriteSpaceBetweenItemsProperty, False); // AS17522
end;

function TdxRibbonGalleryCustomOptions.GetSpaceAfterGroupHeader: Integer;
begin
  Result := FSpaceAfterGroupHeader;
end;

function TdxRibbonGalleryCustomOptions.GetSpaceBetweenItemCaptionAndDescription: Integer;
begin
  Result := FSpaceBetweenItemCaptionAndDescription;
end;

function TdxRibbonGalleryCustomOptions.GetSpaceBetweenItemImageAndText: Integer;
begin
  Result := FSpaceBetweenItemImageAndText;
end;

function TdxRibbonGalleryCustomOptions.GetSpaceBetweenItems: Integer;
begin
  Result := SpaceBetweenItemsHorizontally;
end;

function TdxRibbonGalleryCustomOptions.GetSpaceBetweenItemsHorizontally: Integer;
begin
  Result := FSpaceBetweenItemsHorizontally;
end;

function TdxRibbonGalleryCustomOptions.GetSpaceBetweenItemsVertically: Integer;
begin
  Result := FSpaceBetweenItemsVertically;
end;

function TdxRibbonGalleryCustomOptions.GetItemImagePosition: TdxRibbonGalleryImagePosition;
begin
  Result := FItemImagePosition;
end;

function TdxRibbonGalleryCustomOptions.GetItemTextKind: TdxRibbonGalleryGroupItemTextKind;
begin
  Result := FItemTextKind;
end;

function TdxRibbonGalleryCustomOptions.GetRemoveHorizontalItemPadding: Boolean;
begin
  Result := SpaceBetweenItemsHorizontally = -1;
end;

function TdxRibbonGalleryCustomOptions.GetRemoveVerticalItemPadding: Boolean;
begin
  Result := SpaceBetweenItemsVertically = -1;
end;

function TdxRibbonGalleryCustomOptions.IsItemImagePositionStored: Boolean;
begin
  Result := FItemImagePosition <> gipLeft;
end;

function TdxRibbonGalleryCustomOptions.IsItemImageSizeStored: Boolean;
begin
  Result := (FItemImageSize.Width <> 0) or (FItemImageSize.Height <> 0);
end;

function TdxRibbonGalleryCustomOptions.IsItemSizeStored: Boolean;
begin
  Result := (FItemSize.Width <> 0) or (FItemSize.Height <> 0);
end;

function TdxRibbonGalleryCustomOptions.IsItemTextKindStored: Boolean;
begin
  Result := FItemTextKind <> itkCaption;
end;

function TdxRibbonGalleryCustomOptions.IsItemPullHighlightingStored: Boolean;
begin
  Result := (FItemPullHighlighting.Active <> False) or
    (FItemPullHighlighting.Direction <> gphdStartToFinish);
end;

function TdxRibbonGalleryCustomOptions.IsSpaceAfterGroupHeaderStored: Boolean;
begin
  Result := FSpaceAfterGroupHeader <> 0;
end;

function TdxRibbonGalleryCustomOptions.IsSpaceBetweenItemCaptionAndDescriptionStored: Boolean;
begin
  Result := FSpaceBetweenItemCaptionAndDescription <> 0;
end;

function TdxRibbonGalleryCustomOptions.IsSpaceBetweenItemImageAndTextStored: Boolean;
begin
  Result := FSpaceBetweenItemImageAndText <> 0;
end;

function TdxRibbonGalleryCustomOptions.IsSpaceBetweenItemsHorizontallyStored: Boolean;
begin
  Result := FSpaceBetweenItemsHorizontally <> 0;
end;

function TdxRibbonGalleryCustomOptions.IsSpaceBetweenItemsVerticallyStored: Boolean;
begin
  Result := FSpaceBetweenItemsVertically <> 0;
end;

procedure TdxRibbonGalleryCustomOptions.ItemImageSizeChange(Sender: TObject);
begin
  Changed;
end;

procedure TdxRibbonGalleryCustomOptions.ItemPullHighlightingChange(Sender: TObject);
begin
  Changed;
end;

procedure TdxRibbonGalleryCustomOptions.ItemSizeChange(Sender: TObject);
begin
  Changed;
end;

procedure TdxRibbonGalleryCustomOptions.SetImages(Value: TCustomImageList);
begin
  if FImages <> Value then
  begin
    if FImages <> nil then
    begin
      FImages.UnRegisterChanges(FImageChangeLink);
      FImages.RemoveFreeNotification(FOwner);
    end;
    FImages := Value;
    if Images <> nil then
    begin
      Images.RegisterChanges(FImageChangeLink);
      Images.FreeNotification(FOwner);
    end;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetItemImagePosition(
  Value: TdxRibbonGalleryImagePosition);
begin
  if FItemImagePosition <> Value then
  begin
    FItemImagePosition := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetItemTextKind(Value: TdxRibbonGalleryGroupItemTextKind);
begin
  if FItemTextKind <> Value then
  begin
    FItemTextKind := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceAfterGroupHeader(
  Value: Integer);
begin
  CheckIntRange(Value);
  if FSpaceAfterGroupHeader <> Value then
  begin
    FSpaceAfterGroupHeader := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceBetweenItemCaptionAndDescription(
  Value: Integer);
begin
  CheckIntRange(Value);
  if FSpaceBetweenItemCaptionAndDescription <> Value then
  begin
    FSpaceBetweenItemCaptionAndDescription := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceBetweenItemImageAndText(
  Value: Integer);
begin
  CheckIntRange(Value);
  if FSpaceBetweenItemImageAndText <> Value then
  begin
    FSpaceBetweenItemImageAndText := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceBetweenItems(
  Value: Integer);
begin
  CheckItemsSpaceRange(Value);
  if (SpaceBetweenItemsHorizontally <> Value) or
    (SpaceBetweenItemsVertically <> Value) then
  begin
    SpaceBetweenItemsHorizontally := Value;
    SpaceBetweenItemsVertically := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceBetweenItemsHorizontally(
  Value: Integer);
begin
  CheckItemsSpaceRange(Value);
  if FSpaceBetweenItemsHorizontally <> Value then
  begin
    FSpaceBetweenItemsHorizontally := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.SetSpaceBetweenItemsVertically(
  Value: Integer);
begin
  CheckItemsSpaceRange(Value);
  if FSpaceBetweenItemsVertically <> Value then
  begin
    FSpaceBetweenItemsVertically := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryCustomOptions.ReadSpaceBetweenItemsProperty(
  Reader: TReader);
var
  ASpaceBetweenItems: Integer;
begin
  ASpaceBetweenItems := Reader.ReadInteger;
  SpaceBetweenItemsHorizontally := ASpaceBetweenItems;
  SpaceBetweenItemsVertically := ASpaceBetweenItems;
end;

procedure TdxRibbonGalleryCustomOptions.SetItemImageSize(Value: TcxItemSize);
begin
  FItemImageSize.Assign(Value);
end;

procedure TdxRibbonGalleryCustomOptions.SetItemPullHighlighting(
  Value: TdxRibbonGalleryItemPullHighlighting);
begin
  FItemPullHighlighting.Assign(Value);
end;

procedure TdxRibbonGalleryCustomOptions.SetItemSize(Value: TcxItemSize);
begin
  FItemSize.Assign(Value);
end;

procedure TdxRibbonGalleryCustomOptions.WriteSpaceBetweenItemsProperty(
  Writer: TWriter);
begin
// do nothing
end;

{ TdxRibbonGalleryGroupOptions }

constructor TdxRibbonGalleryGroupOptions.Create(AOwner: TdxRibbonGalleryItem;
  AParentOptions: TdxRibbonGalleryCustomOptions; AGroup: TdxRibbonGalleryGroup);
begin
  inherited Create(AOwner);
  FParentOptions := AParentOptions;
  FAssignedValues := [];
  ImageChangeLink.OnChange := AGroup.ImagesChange;
  FItemSize.Parent := AParentOptions.ItemSize;
  FItemImageSize.Parent := AParentOptions.ItemImageSize;
  FItemPullHighlighting.Parent := AParentOptions.ItemPullHighlighting;
end;

function TdxRibbonGalleryGroupOptions.GetItemImagePosition: TdxRibbonGalleryImagePosition;
begin
  if IsItemImagePositionStored then
    Result := inherited GetItemImagePosition
  else
    Result := ParentOptions.GetItemImagePosition;
end;

function TdxRibbonGalleryGroupOptions.GetItemTextKind: TdxRibbonGalleryGroupItemTextKind;
begin
  if IsItemTextKindStored then
    Result := inherited GetItemTextKind
  else
    Result := ParentOptions.GetItemTextKind;
end;

function TdxRibbonGalleryGroupOptions.GetSpaceAfterGroupHeader: Integer;
begin
  if IsSpaceAfterGroupHeaderStored then
    Result := inherited GetSpaceAfterGroupHeader
  else
    Result := ParentOptions.GetSpaceAfterGroupHeader;
end;

function TdxRibbonGalleryGroupOptions.GetSpaceBetweenItemCaptionAndDescription: Integer;
begin
  if IsSpaceBetweenItemCaptionAndDescriptionStored then
    Result := inherited GetSpaceBetweenItemCaptionAndDescription
  else
    Result := ParentOptions.GetSpaceBetweenItemCaptionAndDescription;
end;

function TdxRibbonGalleryGroupOptions.GetSpaceBetweenItemImageAndText: Integer;
begin
  if IsSpaceBetweenItemImageAndTextStored then
    Result := inherited GetSpaceBetweenItemImageAndText
  else
    Result := ParentOptions.GetSpaceBetweenItemImageAndText;
end;

function TdxRibbonGalleryGroupOptions.GetSpaceBetweenItemsHorizontally: Integer;
begin
  if IsSpaceBetweenItemsHorizontallyStored then
    Result := inherited GetSpaceBetweenItemsHorizontally
  else
    Result := ParentOptions.GetSpaceBetweenItemsHorizontally;
end;

function TdxRibbonGalleryGroupOptions.GetSpaceBetweenItemsVertically: Integer;
begin
  if IsSpaceBetweenItemsVerticallyStored then
    Result := inherited GetSpaceBetweenItemsVertically
  else
    Result := ParentOptions.GetSpaceBetweenItemsVertically;
end;

function TdxRibbonGalleryGroupOptions.IsItemImagePositionStored: Boolean;
begin
  Result := avItemImagePosition in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsItemImageSizeStored: Boolean;
begin
  Result := avItemImageSize in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsItemSizeStored: Boolean;
begin
  Result := avItemSize in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsItemPullHighlightingStored: Boolean;
begin
  Result := avItemPullHighlighting in FAssignedValues;
end;

procedure TdxRibbonGalleryGroupOptions.ItemImageSizeChange(Sender: TObject);
begin
  Include(FAssignedValues, avItemImageSize);
  inherited ItemImageSizeChange(Sender);
end;

procedure TdxRibbonGalleryGroupOptions.ItemSizeChange(Sender: TObject);
begin
  Include(FAssignedValues, avItemSize);
  inherited ItemSizeChange(Sender);
end;

procedure TdxRibbonGalleryGroupOptions.ItemPullHighlightingChange(Sender: TObject);
begin
  Include(FAssignedValues, avItemPullHighlighting);
  inherited ItemPullHighlightingChange(Sender);
end;

function TdxRibbonGalleryGroupOptions.IsItemTextKindStored: Boolean;
begin
  Result := avItemTextKind in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsSpaceAfterGroupHeaderStored: Boolean;
begin
  Result := avSpaceAfterGroupHeader in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsSpaceBetweenItemCaptionAndDescriptionStored: Boolean;
begin
  Result := avSpaceBetweenItemCaptionAndDescription in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsSpaceBetweenItemImageAndTextStored: Boolean;
begin
  Result := avSpaceBetweenItemImageAndText in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsSpaceBetweenItemsHorizontallyStored: Boolean;
begin
  Result := avSpaceBetweenItemsHorizontally in FAssignedValues;
end;

function TdxRibbonGalleryGroupOptions.IsSpaceBetweenItemsVerticallyStored: Boolean;
begin
  Result := avSpaceBetweenItemsVertically in FAssignedValues;
end;

procedure TdxRibbonGalleryGroupOptions.SetAssignedValues(
  const Value: TdxRibbonGalleryGroupOptionsAssignedValues);
begin
  if FAssignedValues <> Value then
  begin
    FAssignedValues := Value;
    ItemSize.Assigned := avItemSize in FAssignedValues;
    ItemImageSize.Assigned := avItemImageSize in FAssignedValues;
    ItemPullHighlighting.IsAssigned := avItemPullHighlighting in FAssignedValues;
    Changed;
  end;
end;

procedure TdxRibbonGalleryGroupOptions.SetItemImagePosition(
  Value: TdxRibbonGalleryImagePosition);
begin
  Include(FAssignedValues, avItemImagePosition);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetItemTextKind(
  Value: TdxRibbonGalleryGroupItemTextKind);
begin
  Include(FAssignedValues, avItemTextKind);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetSpaceAfterGroupHeader(Value: Integer);
begin
  Include(FAssignedValues, avSpaceAfterGroupHeader);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetSpaceBetweenItemCaptionAndDescription(
  Value: Integer);
begin
  Include(FAssignedValues, avSpaceBetweenItemCaptionAndDescription);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetSpaceBetweenItemImageAndText(
  Value: Integer);
begin
  Include(FAssignedValues, avSpaceBetweenItemImageAndText);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetSpaceBetweenItemsHorizontally(Value: Integer);
begin
  Include(FAssignedValues, avSpaceBetweenItemsHorizontally);
  inherited;
end;

procedure TdxRibbonGalleryGroupOptions.SetSpaceBetweenItemsVertically(Value: Integer);
begin
  Include(FAssignedValues, avSpaceBetweenItemsVertically);
  inherited;
end;

{ TdxRibbonGalleryOptions }

constructor TdxRibbonGalleryOptions.Create(AOwner: TdxRibbonGalleryItem);
begin
  inherited Create(AOwner);
  FCanCollapse := True;
  FColumnCount := dxRibbonGalleryDefaultColumnCount;
  FEqualItemSizeInAllGroups := True;
  ImageChangeLink.OnChange := AOwner.ImagesChange;
  FItemSelectionMode := gsmSingle;
  FMinColumnCount := dxRibbonGalleryMinColumnCount;
  //FShowScrollbar := True; deprecated
  FSpaceBetweenItemsAndBorder := 1;
  FSubMenuResizing := gsrWidthAndHeight;
end;

procedure TdxRibbonGalleryOptions.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TdxRibbonGalleryOptions then
  begin
    CanCollapse := TdxRibbonGalleryOptions(Source).CanCollapse;
    Collapsed := TdxRibbonGalleryOptions(Source).Collapsed;
    ColumnCount := TdxRibbonGalleryOptions(Source).ColumnCount;
    EqualItemSizeInAllGroups := TdxRibbonGalleryOptions(Source).EqualItemSizeInAllGroups;
    ItemAllowDeselect := TdxRibbonGalleryOptions(Source).ItemAllowDeselect;
    ItemSelectionMode := TdxRibbonGalleryOptions(Source).ItemSelectionMode;
    MinColumnCount := TdxRibbonGalleryOptions(Source).MinColumnCount;
    RowCount := TdxRibbonGalleryOptions(Source).RowCount;
    //ShowScrollBar := TdxRibbonGalleryOptions(Source).ShowScrollbar; deprecated
    SpaceBetweenGroups := TdxRibbonGalleryOptions(Source).SpaceBetweenGroups;
    SpaceBetweenItemsAndBorder := TdxRibbonGalleryOptions(Source).SpaceBetweenItemsAndBorder;
    SubMenuResizing := TdxRibbonGalleryOptions(Source).SubMenuResizing;
  end;
end;

procedure TdxRibbonGalleryOptions.SetCanCollapse(Value: Boolean);
begin
  if Value <> FCanCollapse then
  begin
    FCanCollapse := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetCollapsed(Value: Boolean);
begin
  if Value <> FCollapsed then
  begin
    FCollapsed := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetColumnCount(Value: Integer);
begin
  if Value <> FColumnCount then
  begin
    FColumnCount := Max(Value, 1);
    MinColumnCount := Min(MinColumnCount, FColumnCount);
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetSpaceBetweenGroups(Value: Integer);
begin
  if Value <> FSpaceBetweenGroups then
  begin
    FSpaceBetweenGroups := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetEqualItemSizeInAllGroups(Value: Boolean);
begin
  if Value <> FEqualItemSizeInAllGroups then
  begin
    FEqualItemSizeInAllGroups := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetItemSelectionMode(
  Value: TdxRibbonGalleryItemSelectionMode);
var
  I, J: Integer;
begin
  if Owner.IsLoading then
    FItemSelectionMode := Value
  else
    if Value <> FItemSelectionMode then
    begin
      Owner.LockGroupItemClickEvents(True);
      try
        case FItemSelectionMode of
          gsmSingle:
            Owner.SelectedGroupItem := nil;
        else
          if Value in [gsmSingle, gsmSingleInGroup] then
            for I := 0 to Owner.GalleryGroups.Count - 1 do
              for J := 0 to Owner.GalleryGroups[I].Items.Count - 1 do
                Owner.GalleryGroups[I].Items[J].Selected := False;
        end;
      finally
        Owner.LockGroupItemClickEvents(False);
      end;
      FItemSelectionMode := Value;
    end;
end;

procedure TdxRibbonGalleryOptions.SetMinColumnCount(Value: Integer);
begin
  if Value <> FMinColumnCount then
  begin
    FMinColumnCount := Max(Value, 1);
    ColumnCount := Max(FMinColumnCount, ColumnCount);
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetRowCount(Value: Integer);
begin
  if Value <> FRowCount then
  begin
    FRowCount := Max(Value, 0);
    Changed;
  end;
end;

procedure TdxRibbonGalleryOptions.SetSpaceBetweenItemsAndBorder(
  Value: Integer);
begin
  CheckIntRange(Value);
  if FSpaceBetweenItemsAndBorder <> Value then
  begin
    FSpaceBetweenItemsAndBorder := Value;
    Changed;
  end;
end;

{ TdxRibbonGalleryGroupHeader }

constructor TdxRibbonGalleryGroupHeader.Create(
  AOwner: TdxRibbonGalleryGroup);
begin
  inherited Create;
  FOwner := AOwner;
  FAlignment := taLeftJustify;
  FVisible := False;
end;

procedure TdxRibbonGalleryGroupHeader.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryGroupHeader then
  begin
    Alignment := TdxRibbonGalleryGroupHeader(Source).Alignment;
    Caption := TdxRibbonGalleryGroupHeader(Source).Caption;
    Visible := TdxRibbonGalleryGroupHeader(Source).Visible;
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonGalleryGroupHeader.Changed;
begin
  FOwner.Changed(True);
end;

procedure TdxRibbonGalleryGroupHeader.SetAlignment(
  Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryGroupHeader.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TdxRibbonGalleryGroupHeader.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

{ TdxRibbonGalleryGroupItem }

constructor TdxRibbonGalleryGroupItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := GlyphChanged;
  FImageIndex := -1;
end;

destructor TdxRibbonGalleryGroupItem.Destroy;
begin
  GalleryItem.RemoveGroupItem(Self);
  FreeAndNil(FActionLink);
  FreeAndNil(FGlyph);
  inherited Destroy;
end;

procedure TdxRibbonGalleryGroupItem.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryGroupItem then
  begin
    Action := TdxRibbonGalleryGroupItem(Source).Action;
    Caption := TdxRibbonGalleryGroupItem(Source).Caption;
    Description := TdxRibbonGalleryGroupItem(Source).Description;
    Glyph := TdxRibbonGalleryGroupItem(Source).Glyph;
    ImageIndex := TdxRibbonGalleryGroupItem(Source).ImageIndex;
    Selected := TdxRibbonGalleryGroupItem(Source).Selected;
    Tag := TdxRibbonGalleryGroupItem(Source).Tag;
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonGalleryGroupItem.ActionChange(Sender: TObject;
  CheckDefaults: Boolean);
begin
  if Action is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if not CheckDefaults or (Self.Caption = '') then
        Self.Caption := Caption;
      if not CheckDefaults or (Self.Selected = False) then
        Self.Selected := Checked;
      if not CheckDefaults or (Self.ImageIndex = -1) then
        Self.ImageIndex := ImageIndex;
      if not CheckDefaults or not Assigned(Self.OnClick) then
        Self.OnClick := OnExecute;
    end;
end;

procedure TdxRibbonGalleryGroupItem.DoClick;
begin
  if GalleryItem.AreGroupItemClickEventsLocked then Exit;
  if Assigned(FOnClick) and ((Action = nil) or (@FOnClick <> @Action.OnExecute)) then
    FOnClick(Self)
  else
    if not IsDesigning and (FActionLink <> nil) then
      FActionLink.Execute{$IFDEF DELPHI6}(GalleryItem){$ENDIF};
end;

procedure TdxRibbonGalleryGroupItem.DrawImage(DC: HDC; const ARect: TRect);
begin
  cxDrawImage(DC, ARect, ARect, Glyph, Group.Images,
    ImageIndex, idmNormal, GalleryItem.BarManager.ImageOptions.SmoothGlyphs);
end;

function TdxRibbonGalleryGroupItem.GetActionLinkClass: TdxRibbonGalleryGroupItemActionLinkClass;
begin
  Result := TdxRibbonGalleryGroupItemActionLink;
end;

function TdxRibbonGalleryGroupItem.GetImageSize: TSize;
var
  AImages: TCustomImageList;
begin
  Result := cxNullSize;
  if IsGlyphAssigned(Glyph) then
  begin
    Result.cx := Glyph.Width;
    Result.cy := Glyph.Height;
  end
  else
  begin
    AImages := Group.Images;
    if AImages <> nil then
    begin
      Result.cx := Group.Images.Width;
      Result.cy := Group.Images.Height;
    end
  end;
end;

function TdxRibbonGalleryGroupItem.IsImageAssigned: Boolean;
begin
  Result := IsGlyphAssigned(Glyph) or
    cxGraphics.IsImageAssigned(Group.Images, ImageIndex);
end;

procedure TdxRibbonGalleryGroupItem.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TdxRibbonGalleryGroupItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

procedure TdxRibbonGalleryGroupItem.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TdxRibbonGalleryGroupItem.DoActionChange(Sender: TObject);
begin
  if Sender = Action then ActionChange(Sender, False);
end;

function TdxRibbonGalleryGroupItem.GetAction: TBasicAction;
begin
  if FActionLink = nil then
    Result := nil
  else
    Result := FActionLink.Action;
end;

function TdxRibbonGalleryGroupItem.GetGalleryItem: TdxRibbonGalleryItem;
begin
  Result := Group.GalleryItem;
end;

function TdxRibbonGalleryGroupItem.GetGroup: TdxRibbonGalleryGroup;
begin
  if Collection <> nil then
    Result := TdxRibbonGalleryGroupItems(Collection).Group
  else
    Result := nil;
end;

function TdxRibbonGalleryGroupItem.GetSelected: Boolean;
begin
  case SelectionMode of
    gsmNone, gsmMultiple, gsmSingleInGroup:
      Result := FSelected;
    gsmSingle:
      Result := GalleryItem.SelectedGroupItem = Self;
  else
    Result := False;
  end;
end;

function TdxRibbonGalleryGroupItem.GetSelectionMode: TdxRibbonGalleryItemSelectionMode;
begin
  Result := GalleryItem.GalleryOptions.ItemSelectionMode;
end;

procedure TdxRibbonGalleryGroupItem.GlyphChanged(Sender: TObject);
begin
  Changed(True);
end;

function TdxRibbonGalleryGroupItem.IsCaptionStored: Boolean;
begin
  Result := (FActionLink = nil) or not FActionLink.IsCaptionLinked;
end;

function TdxRibbonGalleryGroupItem.IsDesigning: Boolean;
begin
  Result := csDesigning in GalleryItem.ComponentState;
end;

function TdxRibbonGalleryGroupItem.IsImageIndexStored: Boolean;
begin
  Result := (FActionLink = nil) or not FActionLink.IsImageIndexLinked;
end;

function TdxRibbonGalleryGroupItem.IsOnClickStored: Boolean;
begin
  Result := (FActionLink = nil) or not FActionLink.IsOnExecuteLinked;
end;

function TdxRibbonGalleryGroupItem.IsSelectedStored: Boolean;
begin
  Result := (FActionLink = nil) or not FActionLink.IsCheckedLinked;
end;

procedure TdxRibbonGalleryGroupItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = Action) then
    Action := nil;
end;

procedure TdxRibbonGalleryGroupItem.SetAction(Value: TBasicAction);
begin
  if Action <> Value then
    if Value = nil then
      FreeAndNil(FActionLink)
    else
    begin
      if csLoading in Value.ComponentState then
        TdxBarManagerAccess(GalleryItem.BarManager).LockDesignerModified(True);
      try
        if FActionLink = nil then
          FActionLink := GetActionLinkClass.Create(Self);
        FActionLink.Action := Value;
        FActionLink.OnChange := DoActionChange;
        ActionChange(Value, csLoading in Value.ComponentState);
        Value.FreeNotification(GalleryItem);
      finally
        if csLoading in Value.ComponentState then
          TdxBarManagerAccess(GalleryItem.BarManager).LockDesignerModified(
            False, False);
      end;
    end;
end;

procedure TdxRibbonGalleryGroupItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Changed(True);
  end;
end;

procedure TdxRibbonGalleryGroupItem.SetDescription(const Value: string);
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    Changed(True);
  end;
end;

procedure TdxRibbonGalleryGroupItem.SetGlyph(Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

procedure TdxRibbonGalleryGroupItem.SetImageIndex(Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Changed(True);
  end;
end;

procedure TdxRibbonGalleryGroupItem.SetSelected(Value: Boolean);

  procedure DeselectItemsInGroup;
  var
    I: Integer;
  begin
    if Selected then
      for I := 0 to Group.Items.Count - 1 do
        if Group.Items[I].Selected and (Group.Items[I] <> Self) then
          Group.Items[I].Selected := False;
  end;

begin
  if GalleryItem.IsLoading then
    FSelected := Value
  else
    case SelectionMode of
      gsmSingle:
        if Value then
          GalleryItem.SelectedGroupItem := Self
        else
          if Selected then
            GalleryItem.SelectedGroupItem := nil;
    else
      if Value <> FSelected then
      begin
        FSelected := Value;
        if SelectionMode in [gsmMultiple, gsmSingleInGroup] then
        begin
          DoClick;
          if SelectionMode = gsmSingleInGroup then
            DeselectItemsInGroup;
          GalleryItem.DoGroupItemClick(Self);
        end;
        GalleryItem.Update;
      end;
    end;
end;

{ TdxRibbonGalleryGroupItems }

constructor TdxRibbonGalleryGroupItems.Create(AGroup: TdxRibbonGalleryGroup);
begin
  inherited Create(TdxRibbonGalleryGroupItem);
  FGroup := AGroup;
end;

function TdxRibbonGalleryGroupItems.Add: TdxRibbonGalleryGroupItem;
begin
  Result := TdxRibbonGalleryGroupItem(inherited Add);
end;

function TdxRibbonGalleryGroupItems.Insert(Index: Integer): TdxRibbonGalleryGroupItem;
begin
  Result := TdxRibbonGalleryGroupItem(inherited Insert(Index));
end;

function TdxRibbonGalleryGroupItems.GetOwner: TPersistent;
begin
  Result := FGroup;
end;

procedure TdxRibbonGalleryGroupItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FGroup.Changed(True);
end;

function TdxRibbonGalleryGroupItems.GetItem(
  Index: Integer): TdxRibbonGalleryGroupItem;
begin
  Result := TdxRibbonGalleryGroupItem(inherited GetItem(Index));
end;

procedure TdxRibbonGalleryGroupItems.SetItem(Index: Integer;
  Value: TdxRibbonGalleryGroupItem);
begin
  inherited SetItem(Index, Value);
end;

{ TdxRibbonGalleryGroup }

constructor TdxRibbonGalleryGroup.Create(Collection: TCollection);
var
  AGalleryItem: TdxRibbonGalleryItem;
begin
  if Collection <> nil then
    Collection.BeginUpdate;
  try
    inherited Create(Collection);
    FHeader := TdxRibbonGalleryGroupHeader.Create(Self);
    FItems := TdxRibbonGalleryGroupItems.Create(Self);
    AGalleryItem := TdxRibbonGalleryItem(TdxRibbonGalleryGroups(Collection).GetOwner);
    FOptions := TdxRibbonGalleryGroupOptions.Create(AGalleryItem,
      AGalleryItem.GalleryOptions, Self);
    FVisible := True;
  finally
    if Collection <> nil then
      Collection.EndUpdate;
  end;
end;

destructor TdxRibbonGalleryGroup.Destroy;
begin
  FreeAndNil(FHeader);
  FreeAndNil(FItems);
  FreeAndNil(FOptions);
  inherited Destroy;
end;

procedure TdxRibbonGalleryGroup.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryGroup then
  begin
    Header := TdxRibbonGalleryGroup(Source).Header;
    Items := TdxRibbonGalleryGroup(Source).Items;
    Options := TdxRibbonGalleryGroup(Source).Options;
    Visible := TdxRibbonGalleryGroup(Source).Visible;
  end
  else
    inherited Assign(Source);
end;

function TdxRibbonGalleryGroup.GetGalleryItem: TdxRibbonGalleryItem;
begin
  Result := TdxRibbonGalleryGroups(Collection).FGalleryItem;
end;

function TdxRibbonGalleryGroup.GetImages: TCustomImageList;
begin
  Result := Options.Images;
  if Result = nil then
    Result := GalleryItem.GetImages;
end;

procedure TdxRibbonGalleryGroup.ImagesChange(Sender: Tobject);
begin
  Changed(True);
end;

procedure TdxRibbonGalleryGroup.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if Operation = opRemove then
    if AComponent = Options.Images then
      Options.Images := nil;
  NotifyItems(AComponent, Operation);
end;

procedure TdxRibbonGalleryGroup.NotifyItems(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  if (Items <> nil) then
    for I := 0 to Items.Count - 1 do
      Items[I].Notification(AComponent, Operation);
end;

procedure TdxRibbonGalleryGroup.SetHeader(Value: TdxRibbonGalleryGroupHeader);
begin
  FHeader.Assign(Value);
end;

procedure TdxRibbonGalleryGroup.SetItems(Value: TdxRibbonGalleryGroupItems);
begin
  FItems.Assign(Value);
end;

procedure TdxRibbonGalleryGroup.SetOptions(Value: TdxRibbonGalleryGroupOptions);
begin
  FOptions.Assign(Value);
end;

procedure TdxRibbonGalleryGroup.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if (Collection <> nil) and (TdxRibbonGalleryGroups(Collection).UpdateCount = 0) then
      GalleryItem.GroupVisibleChanged;
  end;
end;

{ TdxRibbonGalleryGroups }

constructor TdxRibbonGalleryGroups.Create(AGalleryItem: TdxRibbonGalleryItem);
begin
  inherited Create(TdxRibbonGalleryGroup);
  FGalleryItem := AGalleryItem;
end;

function TdxRibbonGalleryGroups.Add: TdxRibbonGalleryGroup;
begin
  Result := TdxRibbonGalleryGroup(inherited Add);
end;

function TdxRibbonGalleryGroups.Insert(Index: Integer): TdxRibbonGalleryGroup;
begin
  Result := TdxRibbonGalleryGroup(inherited Insert(Index));
end;

function TdxRibbonGalleryGroups.GetOwner: TPersistent;
begin
  Result := GalleryItem;
end;

procedure TdxRibbonGalleryGroups.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  if (Action = cnExtracting) and not (csDestroying in GalleryItem.ComponentState) then
    RemoveFromFilter(Item);
  inherited Notify(Item, Action);
end;

procedure TdxRibbonGalleryGroups.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  GalleryItem.GalleryChanged;
end;

function TdxRibbonGalleryGroups.GetItem(Index: Integer): TdxRibbonGalleryGroup;
begin
  Result := TdxRibbonGalleryGroup(inherited GetItem(Index));
end;

procedure TdxRibbonGalleryGroups.RemoveFromFilter(AItem: TCollectionItem);
begin
  if AItem <> nil then
    GalleryItem.GalleryFilter.Categories.DeleteGroup(TdxRibbonGalleryGroup(AItem));
end;

procedure TdxRibbonGalleryGroups.SetItem(Index: Integer;
  Value: TdxRibbonGalleryGroup);
begin
  inherited SetItem(Index, Value);
end;

{ TdxRibbonGalleryFilterCategoryGroups }

constructor TdxRibbonGalleryFilterCategoryGroups.Create(
  AFilterCategory: TdxRibbonGalleryFilterCategory);
begin
  inherited Create;
  FFilterCategory := AFilterCategory;
end;

procedure TdxRibbonGalleryFilterCategoryGroups.Assign(
  ASource: TdxRibbonGalleryFilterCategoryGroups);
var
  I: Integer;
begin
  if FilterCategory.GalleryItem.GalleryGroups.Count <>
    ASource.FilterCategory.GalleryItem.GalleryGroups.Count then
      raise EdxException.Create('');
  Clear;
  for I := 0 to ASource.Count - 1 do
    Add(FilterCategory.GalleryItem.GalleryGroups[ASource[I].Index]);
end;

function TdxRibbonGalleryFilterCategoryGroups.Add(AGroup: TdxRibbonGalleryGroup): Integer;
begin
  if CanAddGroup(AGroup) then
    Result := inherited Add(AGroup)
  else
    Result := -1;
end;

procedure TdxRibbonGalleryFilterCategoryGroups.Insert(AIndex: Integer;
  AGroup: TdxRibbonGalleryGroup);
begin
  if CanAddGroup(AGroup) then
    inherited Insert(AIndex, AGroup);
end;

procedure TdxRibbonGalleryFilterCategoryGroups.Notify(Ptr: Pointer;
  Action: TListNotification);
begin
  inherited Notify(Ptr, Action);
  if Action in [lnAdded, lnDeleted] then
    FilterCategory.Changed(False);
end;

function TdxRibbonGalleryFilterCategoryGroups.CanAddGroup(
  AGroup: TdxRibbonGalleryGroup): Boolean;

  function IsGroupValid: Boolean;
  begin
    Result := (AGroup <> nil) and (AGroup.GalleryItem = FilterCategory.GalleryItem);
  end;

begin
  Result := IsGroupValid and (IndexOf(AGroup) = -1);
end;

function TdxRibbonGalleryFilterCategoryGroups.GetItem(
  Index: Integer): TdxRibbonGalleryGroup;
begin
  Result := TdxRibbonGalleryGroup(inherited Items[Index]);
end;

{ TdxRibbonGalleryFilterCategory }

constructor TdxRibbonGalleryFilterCategory.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FGroups := TdxRibbonGalleryFilterCategoryGroups.Create(Self);
end;

destructor TdxRibbonGalleryFilterCategory.Destroy;
begin
  FreeAndNil(FGroups);
  inherited Destroy;
end;

procedure TdxRibbonGalleryFilterCategory.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryFilterCategory then
  begin
    Caption := TdxRibbonGalleryFilterCategory(Source).Caption;
    Groups.Assign(TdxRibbonGalleryFilterCategory(Source).Groups);
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonGalleryFilterCategory.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('CategoryGroups', ReadCategoryGroups, WriteCategoryGroups,
    FGroups.Count > 0);
end;

function TdxRibbonGalleryFilterCategory.GetGalleryItem: TdxRibbonGalleryItem;
begin
  Result := TdxRibbonGalleryFilterCategories(Collection).GalleryFilter.GalleryItem;
end;

procedure TdxRibbonGalleryFilterCategory.ReadCategoryGroups(AReader: TReader);
var
  AIndex: Integer;
begin
  Groups.Clear;
  AReader.ReadListBegin;
  while not AReader.EndOfList do
  begin
    AIndex := AReader.ReadInteger;
    if (AIndex >= 0) and (AIndex < GalleryItem.GalleryGroups.Count) and
      (Groups.IndexOf(GalleryItem.GalleryGroups[AIndex]) = -1) then
      Groups.Add(GalleryItem.GalleryGroups[AIndex]);
  end;
  AReader.ReadListEnd;
end;

procedure TdxRibbonGalleryFilterCategory.WriteCategoryGroups(AWriter: TWriter);
var
  I, J, AIndex: Integer;
begin
  AWriter.WriteListBegin;
  for I := 0 to Groups.Count - 1 do
  begin
    AIndex := -1;
    for J := 0 to GalleryItem.GalleryGroups.Count - 1 do
      if Groups[I] = GalleryItem.GalleryGroups[J] then
      begin
        AIndex := J;
        Break;
      end;
    if AIndex <> -1 then
      AWriter.WriteInteger(AIndex);
  end;
  AWriter.WriteListEnd;
end;

{ TdxRibbonGalleryFilterCategories }

constructor TdxRibbonGalleryFilterCategories.Create(
  AGalleryFilter: TdxRibbonGalleryFilter);
begin
  inherited Create(TdxRibbonGalleryFilterCategory);
  FGalleryFilter := AGalleryFilter;
end;

function TdxRibbonGalleryFilterCategories.Add: TdxRibbonGalleryFilterCategory;
begin
  Result := TdxRibbonGalleryFilterCategory(inherited Add);
end;

procedure TdxRibbonGalleryFilterCategories.DeleteGroup(
  AGroup: TdxRibbonGalleryGroup);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Groups.Remove(AGroup);
end;

function TdxRibbonGalleryFilterCategories.GetOwner: TPersistent;
begin
  Result := FGalleryFilter;
end;

procedure TdxRibbonGalleryFilterCategories.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  FGalleryFilter.CategoriesChanged;
end;

function TdxRibbonGalleryFilterCategories.GetItem(
  Index: Integer): TdxRibbonGalleryFilterCategory;
begin
  Result := TdxRibbonGalleryFilterCategory(inherited GetItem(Index));
end;

procedure TdxRibbonGalleryFilterCategories.SetItem(Index: Integer;
  Value: TdxRibbonGalleryFilterCategory);
begin
  inherited SetItem(Index, Value);
end;

{ TdxRibbonGalleryFilter }

constructor TdxRibbonGalleryFilter.Create(AGalleryItem: TdxRibbonGalleryItem);
begin
  inherited Create;
  FGalleryItem := AGalleryItem;
  FActiveCategoryIndex := -1;
  FCategories := TdxRibbonGalleryFilterCategories.Create(Self);
  FLoadedActiveCategoryIndex := -1;
end;

destructor TdxRibbonGalleryFilter.Destroy;
begin
  FreeAndNil(FCategories);
  inherited Destroy;
end;

procedure TdxRibbonGalleryFilter.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonGalleryFilter then
  begin
    Caption := TdxRibbonGalleryFilter(Source).Caption;
    Categories := TdxRibbonGalleryFilter(Source).Categories;
    ActiveCategoryIndex := TdxRibbonGalleryFilter(Source).ActiveCategoryIndex; // must be after Categories
    Visible := TdxRibbonGalleryFilter(Source).Visible;
  end
  else
    inherited Assign(Source);
end;

function TdxRibbonGalleryFilter.IsGroupFiltered(
  AGroup: TdxRibbonGalleryGroup): Boolean;
begin
  Result := (ActiveCategoryIndex <> -1) and
    (Categories[ActiveCategoryIndex].Groups.IndexOf(AGroup) = -1);
end;

procedure TdxRibbonGalleryFilter.CategoriesChanged;
begin
  if ActiveCategoryIndex >= Categories.Count then
    ActiveCategoryIndex := -1
  else
    if ActiveCategoryIndex <> -1 then
      GalleryItem.FilterChanged;
end;

function TdxRibbonGalleryFilter.GetOwner: TPersistent;
begin
  Result := GalleryItem;
end;

procedure TdxRibbonGalleryFilter.Loaded;
begin
  ActiveCategoryIndex := FLoadedActiveCategoryIndex;
end;

procedure TdxRibbonGalleryFilter.SetActiveCategoryIndex(Value: Integer);
begin
  if GalleryItem.IsLoading then
  begin
    FLoadedActiveCategoryIndex := Value;
    Exit;
  end;
  if Value < 0 then
    Value := -1
  else
    if Value >= Categories.Count then
      Exit;
  if FActiveCategoryIndex <> Value then
  begin
    FActiveCategoryIndex := Value;
    GalleryItem.FilterChanged;
  end;
end;

procedure TdxRibbonGalleryFilter.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    if Visible then
      GalleryItem.FilterCaptionChanged;
  end;
end;

procedure TdxRibbonGalleryFilter.SetCategories(
  Value: TdxRibbonGalleryFilterCategories);
begin
  FCategories.Assign(Value);
end;

{ TdxRibbonGalleryItem }

constructor TdxRibbonGalleryItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGalleryFilter := TdxRibbonGalleryFilter.Create(Self);
  FGalleryGroups := TdxRibbonGalleryGroups.Create(Self);
  FGalleryOptions := TdxRibbonGalleryOptions.Create(Self);
end;

destructor TdxRibbonGalleryItem.Destroy;
begin
  DropDownGallery := nil;
  FreeAndNil(FGalleryFilter);
  FreeAndNil(FGalleryGroups);
  FreeAndNil(FGalleryOptions);
  inherited Destroy;
end;

procedure TdxRibbonGalleryItem.DoClick;

  procedure ClickWithoutSelection;
  begin
    FClickedGroupItem.DoClick;
    DoGroupItemClick(FClickedGroupItem);
  end;

begin
  if ClickItemLink = nil then
  begin
    inherited DoClick;
    Exit;
  end;

  if FClickedGroupItem <> nil then
  begin
    if FClickedGroupItem.Group.Options.ItemPullHighlighting.Active then
      ClickWithoutSelection
    else
      case GalleryOptions.ItemSelectionMode of
        gsmNone:
          ClickWithoutSelection;
        gsmSingle:
          begin
            if FClickedGroupItem <> SelectedGroupItem then
              SelectedGroupItem := FClickedGroupItem
            else
              if GalleryOptions.ItemAllowDeselect then
                SelectedGroupItem := nil
              else
                ClickWithoutSelection;
          end;
        gsmMultiple, gsmSingleInGroup:
          FClickedGroupItem.Selected := not FClickedGroupItem.Selected;
      end;
  end;
end;

function TdxRibbonGalleryItem.GetAddMessageName: string;
begin
  Result := cxGetResourceString(@dxSBAR_ADDGALLERYNAME);
end;

function TdxRibbonGalleryItem.IsGroupVisible(AGroupIndex: Integer;
  AIgnoreVisibleProperty: Boolean = False): Boolean;
begin
  Result := (AIgnoreVisibleProperty or GalleryGroups[AGroupIndex].Visible) and
    ((GalleryGroups[AGroupIndex].Items.Count > 0) or GalleryGroups[AGroupIndex].Header.Visible) and
    not GalleryFilter.IsGroupFiltered(GalleryGroups[AGroupIndex]);
end;

function TdxRibbonGalleryItem.AreGroupItemClickEventsLocked: Boolean;
begin
  Result := FLockGroupItemClickEventsCount <> 0;
end;

function TdxRibbonGalleryItem.CanBePlacedOn(
  AParentKind: TdxBarItemControlParentKind; AToolbar: TdxBar;
  out AErrorText: string): Boolean;
begin
  Result := (AParentKind = pkSubItemOrPopupMenu) or (TdxBarManagerAccess(BarManager).IsInitializing or
    GetBarControlClass(AToolbar).InheritsFrom(TdxRibbonCustomBarControl));
  if not Result then
    AErrorText := cxGetResourceString(@dxSBAR_CANTPLACERIBBONGALLERY);
end;

function TdxRibbonGalleryItem.CreateCloneForDropDownGallery: TdxRibbonGalleryItem;
begin
  Result := TdxRibbonGalleryItem(TdxBarItemClass(ClassType).Create(BarManager));
  Result.FIsClone := True;
  Result.GalleryOptions.ItemSelectionMode := gsmNone;
  Result.GalleryGroups := GalleryGroups;
  Result.GalleryFilter := GalleryFilter; // must be after Result.GalleryGroups := GalleryGroups
  Result.GalleryOptions := GalleryOptions;
end;

procedure TdxRibbonGalleryItem.DoCloseUp;
begin
  inherited DoCloseUp;
  if DropDownGallery <> nil then
    DropDownGallery.DoCloseUp;
end;

procedure TdxRibbonGalleryItem.DoFilterChanged;
begin
  if Assigned(OnFilterChanged) then
    OnFilterChanged(Self);
end;

procedure TdxRibbonGalleryItem.DoGroupItemClick(AItem: TdxRibbonGalleryGroupItem);
begin
  if Assigned(FOnGroupItemClick) and not AreGroupItemClickEventsLocked then
    FOnGroupItemClick(Self, AItem);
end;

procedure TdxRibbonGalleryItem.DoHotTrackedItemChanged(APrevHotTrackedGroupItem,
  ANewHotTrackedGroupItem: TdxRibbonGalleryGroupItem);
begin
  if Assigned(FOnHotTrackedItemChanged) then
    FOnHotTrackedItemChanged(APrevHotTrackedGroupItem, ANewHotTrackedGroupItem);
end;

procedure TdxRibbonGalleryItem.DoInitFilterMenu(AItemLinks: TdxBarItemLinks);
begin
  if Assigned(OnInitFilterMenu) then
    OnInitFilterMenu(Self, AItemLinks);
end;

procedure TdxRibbonGalleryItem.DoPopup;
begin
  inherited DoPopup;
  if DropDownGallery <> nil then
    DropDownGallery.DoPopup;
end;

procedure TdxRibbonGalleryItem.FilterCaptionChanged;
var
  I: Integer;
begin
  for I := 0 to LinkCount - 1 do
    if Links[I].Control <> nil then
      TdxRibbonGalleryControl(Links[I].Control).FilterCaptionChanged;
end;

procedure TdxRibbonGalleryItem.FilterChanged;
var
  I: Integer;
begin
  FRecalculatingOnFilterChanged := True;
  try
    if FFilterChangedLockCount = 0 then
      for I := 0 to LinkCount - 1 do
        if Links[I].Control <> nil then
        begin
          Links[I].Control.ViewInfo.ResetCachedValues;
          TCustomdxBarControlAccess(Links[I].Control.Parent).RepaintBarEx(False);
        end;
  finally
    FRecalculatingOnFilterChanged := False;
  end;
end;

procedure TdxRibbonGalleryItem.GalleryChanged;

  procedure ResetControlCachedValues;
  var
    I: Integer;
  begin
    for I := 0 to LinkCount - 1 do
      if Links[I].Control <> nil then
        TdxRibbonGalleryControl(Links[I].Control).Changed;
  end;

begin
  ResetControlCachedValues;
  UpdateEx;
end;

function TdxRibbonGalleryItem.GetFilterCaption: string;
var
  I: Integer;
begin
  if GalleryFilter.Caption <> '' then
    Result := GalleryFilter.Caption
  else
  begin
    Result := '';
    if GalleryFilter.Categories.Count = 0 then
    begin
      for I := 0 to GalleryGroups.Count - 1 do
        if IsGroupVisible(I) then
        begin
          if Result <> '' then
            Result := Result + FilterCaptionDelimiter;
          Result := Result + GalleryGroups[I].Header.Caption;
        end
    end
    else
      if GalleryFilter.ActiveCategoryIndex <> -1 then
        Result := GalleryFilter.Categories[GalleryFilter.ActiveCategoryIndex].Caption;
    if Result = '' then
      Result := cxGetResourceString(@dxSBAR_GALLERYEMPTYFILTERCAPTION);
  end;
end;

function TdxRibbonGalleryItem.GetImages: TCustomImageList;
begin
  Result := GalleryOptions.Images;
  if Result = nil then
    Result := BarManager.ImageOptions.Images;
end;

class function TdxRibbonGalleryItem.GetNewCaption: string;
begin
  Result := cxGetResourceString(@dxSBAR_NEWRIBBONGALLERYITEMCAPTION);
end;

procedure TdxRibbonGalleryItem.GroupVisibleChanged;
begin
  FilterChanged;
end;

procedure TdxRibbonGalleryItem.ImagesChange(Sender: TObject);
begin
  GalleryChanged;
end;

function TdxRibbonGalleryItem.InternalCanMergeWith(AItem: TdxBarItem): Boolean;
begin
  Result := False;
end;

function TdxRibbonGalleryItem.IsFilterVisible: Boolean;

  function HasVisibleGroups: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to GalleryGroups.Count - 1 do
      if IsGroupVisible(I, True) then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  Result := GalleryFilter.Visible and
    ((GalleryFilter.Categories.Count > 0) or HasVisibleGroups);
end;

procedure TdxRibbonGalleryItem.Loaded;

  function GetSelectedGroupItem: TdxRibbonGalleryGroupItem;
  var
    I, J: Integer;
  begin
    Result := nil;
    for I := 0 to GalleryGroups.Count - 1 do
      for J := 0 to GalleryGroups[I].Items.Count - 1 do
        if GalleryGroups[I].Items[J].LoadedSelected then
        begin
          Result := GalleryGroups[I].Items[J];
          Result.LoadedSelected := False;
          Break;
        end;
  end;

begin
  inherited Loaded;
  if GalleryOptions.ItemSelectionMode = gsmSingle then
  begin
    LockGroupItemClickEvents(True);
    try
      SelectedGroupItem := GetSelectedGroupItem;
    finally
      LockGroupItemClickEvents(False);
    end;
  end;
  GalleryFilter.Loaded;
end;

procedure TdxRibbonGalleryItem.LockFilterChanged(ALock: Boolean);
begin
  if ALock then
    Inc(FFilterChangedLockCount)
  else
  begin
    if FFilterChangedLockCount = 0 then
      raise EdxException.Create('');
    Dec(FFilterChangedLockCount);
    if FFilterChangedLockCount = 0 then
      FilterChanged;
  end;
end;

procedure TdxRibbonGalleryItem.LockGroupItemClickEvents(ALock: Boolean);
begin
  if ALock then
    Inc(FLockGroupItemClickEventsCount)
  else
    if FLockGroupItemClickEventsCount > 0 then
      Dec(FLockGroupItemClickEventsCount)
    else
      raise EdxException.Create('');
end;

procedure TdxRibbonGalleryItem.ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem);
var
  I: Integer;
begin
  for I := 0 to LinkCount - 1 do
    if (Links[I].Control <> nil) and
      (Links[I].Control.ViewInfo is TdxInRibbonGalleryControlViewInfo) then
      TdxInRibbonGalleryControlViewInfo(Links[I].Control.ViewInfo).ShowGroupItem(
        AGroupItem);
end;

procedure TdxRibbonGalleryItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if AComponent <> Self then
  begin
    if Operation = opRemove then
      if AComponent = DropDownGallery then
        DropDownGallery := nil
      else
        if AComponent = GalleryOptions.Images then
          GalleryOptions.Images := nil;
    NotifyGroups(AComponent, Operation);
  end;
end;

procedure TdxRibbonGalleryItem.RemoveGroupItem(AItem: TdxRibbonGalleryGroupItem);
var
  I: Integer;
begin
  if FSelectedGroupItem = AItem then
    FSelectedGroupItem := nil;
  for I := 0 to LinkCount - 1 do
    if Links[I].Control <> nil then
      TdxRibbonGalleryControl(Links[I].Control).ViewInfo.RemoveGroupItem(AItem);
end;

procedure TdxRibbonGalleryItem.UpdateEx(AParentKinds: TdxBarKinds = dxBarKindAny);
var
  I: Integer;
begin
  Exclude(AParentKinds, bkSubMenu);
  inherited UpdateEx(AParentKinds);
  for I := 0 to LinkCount - 1 do
    if Links[I].Control <> nil then
      with Links[I].Control do
        if Parent.Kind = bkSubMenu then
          Links[I].Control.Repaint;
end;

procedure TdxRibbonGalleryItem.NotifyGroups(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  if (GalleryGroups <> nil) then
    for I := 0 to GalleryGroups.Count - 1 do
      GalleryGroups[I].Notification(AComponent, Operation);
end;

procedure TdxRibbonGalleryItem.SetDropDownGallery(Value: TdxRibbonDropDownGallery);
begin
  if Value <> FDropDownGallery then
  begin
    if FDropDownGallery <> nil then
      FDropDownGallery.RemoveFreeNotification(Self);
    FDropDownGallery := Value;
    if FDropDownGallery <> nil then
      FDropDownGallery.FreeNotification(Self);
  end;
end;

procedure TdxRibbonGalleryItem.SetGalleryFilter(Value: TdxRibbonGalleryFilter);
begin
  FGalleryFilter.Assign(Value);
end;

procedure TdxRibbonGalleryItem.SetGalleryGroups(Value: TdxRibbonGalleryGroups);
begin
  FGalleryGroups.Assign(Value);
end;

procedure TdxRibbonGalleryItem.SetGalleryOptions(Value: TdxRibbonGalleryOptions);
begin
  FGalleryOptions.Assign(Value);
end;

procedure TdxRibbonGalleryItem.SetSelectedGroupItem(
  Value: TdxRibbonGalleryGroupItem);
var
  APrevSelectedGroupItem: TdxRibbonGalleryGroupItem;
begin
  if (GalleryOptions.ItemSelectionMode = gsmSingle) and
    (FSelectedGroupItem <> Value) then
  begin
    APrevSelectedGroupItem := FSelectedGroupItem;
    FSelectedGroupItem := Value;
    if APrevSelectedGroupItem <> nil then
      APrevSelectedGroupItem.DoClick;
    if FSelectedGroupItem <> nil then
      FSelectedGroupItem.DoClick;
    DoGroupItemClick(FSelectedGroupItem);
    Update;
  end;
end;

{ TdxRibbonGalleryController }

constructor TdxRibbonGalleryController.Create(
  AOwner: TdxRibbonGalleryControl);
begin
  inherited Create;
  FOwner := AOwner;

  FGroupItemHotTrackEnabled := True;
end;

procedure TdxRibbonGalleryController.CancelHint;
begin
  FOwner.UpdateHint(nil, cxEmptyRect);
end;

function TdxRibbonGalleryController.GetGroupItem(AGroupIndex, AIndex: Integer): TdxRibbonGalleryGroupItem;
var
  AGroup: TdxRibbonGalleryGroup;
begin
  Result := nil;
  if InRange(AGroupIndex, 0, GroupCount - 1) then
  begin
    AGroup := FOwner.GetGroups[AGroupIndex];
    if InRange(AIndex, 0, AGroup.Items.Count - 1) then
      Result := AGroup.Items[AIndex];
  end;
end;

procedure TdxRibbonGalleryController.HotTrackItem(
  AItem: TdxRibbonGalleryGroupItem);
begin
  FKeyboardHotGroupItem := AItem;
  SetHotGroupItem(FKeyboardHotGroupItem);
end;

procedure TdxRibbonGalleryController.SetHintItem(AItem: TdxRibbonGalleryGroupItem);
var
  R: TRect;
  AGroupItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
begin
  if FHintItem <> AItem then
  begin
    FHintItem := AItem;
    AGroupItemViewInfo := ViewInfo.GetGroupItemViewInfo(FHintItem);
    if AGroupItemViewInfo <> nil then
      R := AGroupItemViewInfo.Bounds
    else
      R := cxEmptyRect;
    FOwner.UpdateHint(AItem, R);
  end;
end;

procedure TdxRibbonGalleryController.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  function GetIsItemPullHighlighting(AGroupItem: TdxRibbonGalleryGroupItem): Boolean;
  begin
    Result := AGroupItem.Group.Options.ItemPullHighlighting.Active;
  end;

  procedure GroupItemMouseDown(AGroupItem: TdxRibbonGalleryGroupItem;
    X, Y: Integer);
  var
    AGroupItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
  begin
    FMouseDownGroupItem := AGroupItem;
    if AGroupItem = nil then Exit;
    AGroupItemViewInfo := ViewInfo.GetGroupItemViewInfo(AGroupItem);
    AGroupItem.MouseDown(Button, Shift, X - AGroupItemViewInfo.Bounds.Left,
      Y - AGroupItemViewInfo.Bounds.Top);
  end;

var
  AGroupItem: TdxRibbonGalleryGroupItem;
begin
  CancelHint;
  AGroupItem := ViewInfo.GetGroupItem(X, Y);
  GroupItemMouseDown(AGroupItem, X, Y);
  FGroupItemHotTrackEnabled := AGroupItem <> nil;
  if FGroupItemHotTrackEnabled and not GetIsItemPullHighlighting(AGroupItem) then
    GetViewInfo.SetDownedGroupItem(AGroupItem);
end;

procedure TdxRibbonGalleryController.MouseLeave;
begin
  SetHotGroupItem(nil);
  SetHintItem(nil);
end;

procedure TdxRibbonGalleryController.MouseMove(Shift: TShiftState;
  X, Y: Integer);
var
  AGroupItem: TdxRibbonGalleryGroupItem;
begin
  AGroupItem := ViewInfo.GetGroupItem(X, Y);
  GroupItemMouseMove(AGroupItem, Shift, X, Y);
  ProcessHotTrack(AGroupItem);
end;

procedure TdxRibbonGalleryController.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  procedure GroupItemMouseUp(AGroupItem: TdxRibbonGalleryGroupItem;
    X, Y: Integer);
  var
    AGroupItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
  begin
    if AGroupItem = nil then Exit;
    AGroupItemViewInfo := ViewInfo.GetGroupItemViewInfo(AGroupItem);
    AGroupItem.MouseUp(Button, Shift, X - AGroupItemViewInfo.Bounds.Left,
      Y - AGroupItemViewInfo.Bounds.Top);
  end;

var
  AViewInfo: TdxRibbonGalleryControlViewInfo;
begin
  GroupItemMouseUp(FMouseDownGroupItem, X, Y);
  if FGroupItemHotTrackEnabled then
  begin
    AViewInfo := ViewInfo;
    if AViewInfo.IsGroupItemAtThisPlace(X, Y) then
      AViewInfo.SetDownedGroupItem(nil);
  end;
  FGroupItemHotTrackEnabled := True;
end;

procedure TdxRibbonGalleryController.UnsetDownedFromGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem);
begin
  if (ViewInfo.DownedGroupItem <> AGroupItem) and
    (ViewInfo.DownedGroupItem <> nil) then
  begin
    ViewInfo.SetDownedGroupItem(nil);
  end;
end;

function TdxRibbonGalleryController.GetFirstGroupItem: TdxRibbonGalleryGroupItem;
var
  AGroupIndex: Integer;
begin
  AGroupIndex := ViewInfo.GetVisibleNotEmptyGroupIndex(0, True);
  if AGroupIndex <> -1 then
    Result := FOwner.GetGroups[AGroupIndex].Items[0]
  else
    Result := nil;
end;

function TdxRibbonGalleryController.GetGalleryItem: TdxRibbonGalleryItem;
begin
  Result := TdxRibbonGalleryItem(FOwner.Item);
end;

function TdxRibbonGalleryController.GetGroupCount: Integer;
begin
  Result := FOwner.GetGroups.Count;
end;

function TdxRibbonGalleryController.GetKeyboardHotGroupItem: TdxRibbonGalleryGroupItem;
var
  ADestroyAfterUse: Boolean;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
begin
  Result := nil;
  if (FKeyboardHotGroupItem <> nil) then
  begin
    AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups,
      ViewInfo, FKeyboardHotGroupItem.Group.Index, ADestroyAfterUse);
    try
      if (AGroupViewInfo <> nil) then
        Result := FKeyboardHotGroupItem;
    finally
      if ADestroyAfterUse then
        AGroupViewInfo.Free;
    end;
  end;
end;

function TdxRibbonGalleryController.GetViewInfo: TdxRibbonGalleryControlViewInfo;
begin
  Result := FOwner.ViewInfo;
end;

procedure TdxRibbonGalleryController.GroupItemMouseMove(AGroupItem: TdxRibbonGalleryGroupItem;
  Shift: TShiftState; X, Y: Integer);
var
  AGroupItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
begin
  if AGroupItem = nil then Exit;
  AGroupItemViewInfo := ViewInfo.GetGroupItemViewInfo(AGroupItem);
  AGroupItem.MouseMove(Shift, X - AGroupItemViewInfo.Bounds.Left,
    Y - AGroupItemViewInfo.Bounds.Top);
end;

procedure TdxRibbonGalleryController.ProcessHotTrack(
  AGroupItem: TdxRibbonGalleryGroupItem);
begin
  if FGroupItemHotTrackEnabled then
  begin
    ViewInfo.DontDisplayHotTrackedGroupItem :=
      ViewInfo.DontDisplayHotTrackedGroupItem + 1;
    try
      SetHintItem(AGroupItem);
      if (AGroupItem <> nil) or
        not (FKeyboardHotGroupItem <> nil) or
        not FLastCommandFromKeyboard then
      begin
        FLastCommandFromKeyboard := False;
        SetHotGroupItem(AGroupItem);
      end;
    finally
      ViewInfo.DontDisplayHotTrackedGroupItem :=
        ViewInfo.DontDisplayHotTrackedGroupItem - 1;
    end;
  end;
end;

procedure TdxRibbonGalleryController.SetHotGroupItem(
  const Value: TdxRibbonGalleryGroupItem);
begin
  if Value <> ViewInfo.HotGroupItem then
  begin
    ViewInfo.HotGroupItem := Value;
    if Value <> nil then
      FKeyboardHotGroupItem := Value;
    UnsetDownedFromGroupItem(Value);
  end;
end;

{ TdxRibbonOnSubMenuGalleryController }

procedure TdxRibbonOnSubMenuGalleryController.Navigation(
  ADirection: TcxAccessibilityNavigationDirection);

type
  TXRange = record
    Left: Integer;
    Right: Integer;
  end;

  procedure TransferToAnotherGroup(var AGroupIndex: Integer;
    const AColumnRange: TXRange; ADownDirection: Boolean;
    var ARow, AColumn: Integer);
  var
    AColumnCountInRow: Integer;
    AColumnFind: Boolean;
    ACurrentColumnIndex, ACurrentRowIndex: Integer;
    AColumnLeft, AColumnRight: Integer;
    ACurrentColumnIntersected, APreviousColumnIntersected: Boolean;
    ADestroyAfterUse: Boolean;
    AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    ANextRow, ANextGroup: Boolean;
  begin
    if AGroupIndex >= GroupCount then
      if TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).First <> nil then
        Exit
      else
        AGroupIndex := 0;
    if AGroupIndex < 0 then
      if TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).Last <> nil then
        Exit
      else
        AGroupIndex := GroupCount - 1;

    AColumnFind := False;
    ACurrentColumnIndex := 0;
    ACurrentRowIndex := 0;
    if GalleryItem.IsGroupVisible(AGroupIndex) and
      (FOwner.GetGroups[AGroupIndex].Items.Count > 0) then
    begin
      AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, ViewInfo,
        AGroupIndex, ADestroyAfterUse);
      {if ADestroyAfterUse then
        AGroupViewInfo.SetBounds(ViewInfo.GalleryBounds);}

      if not ADownDirection then
        ACurrentRowIndex := AGroupViewInfo.GetRowCount(GetGalleryWidth) - 1;

      ANextGroup := False;
      repeat
        ANextRow := False;
        AColumnCountInRow := AGroupViewInfo.GetColumnCountInRow(ACurrentRowIndex,
          GetGalleryWidth);
        ACurrentColumnIndex := 0;
        APreviousColumnIntersected := False;
        repeat
          AColumnLeft := AGroupViewInfo.GetColumnLeft(ACurrentColumnIndex,
            ViewInfo.GalleryBounds.Left);
          AColumnRight := AColumnLeft + AGroupViewInfo.ItemSize.cx;
          ACurrentColumnIntersected := AreLinesIntersectedStrictly(AColumnLeft, AColumnRight,
            AColumnRange.Left, AColumnRange.Right);
          if ADownDirection then
            AColumnFind := ACurrentColumnIntersected
          else
          begin
            AColumnFind := APreviousColumnIntersected and
              (not ACurrentColumnIntersected);
            if AColumnFind then
              Dec(ACurrentColumnIndex);
            if (ACurrentColumnIndex = AColumnCountInRow - 1) and
              ACurrentColumnIntersected then
              AColumnFind := True;
            APreviousColumnIntersected := ACurrentColumnIntersected;
          end;
          if not AColumnFind then
          begin
            ANextRow := ACurrentColumnIndex = AColumnCountInRow - 1;
            Inc(ACurrentColumnIndex);
          end;
        until AColumnFind or ANextRow;

        if not AColumnFind then
        begin
          if ADownDirection then
          begin
            Inc(ACurrentRowIndex);
            ANextGroup := ACurrentRowIndex >
              AGroupViewInfo.GetRowCount(GetGalleryWidth) - 1;
          end
          else
          begin
            Dec(ACurrentRowIndex);
            ANextGroup := ACurrentRowIndex < 0;
          end;
        end;
      until AColumnFind or ANextGroup;

      if ADestroyAfterUse then
        AGroupViewInfo.Free;
    end;

    if AColumnFind then
    begin
      AColumn := ACurrentColumnIndex;
      ARow := ACurrentRowIndex;
    end
    else
    begin
      if ADownDirection then
        Inc(AGroupIndex)
      else
        Dec(AGroupIndex);
      TransferToAnotherGroup(AGroupIndex, AColumnRange, ADownDirection, ARow,
        AColumn);
    end;
  end;

  function GetColumnRange(AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    AColumn: Integer): TXRange;
  begin
    Result.Left := AGroupViewInfo.GetColumnLeft(AColumn,
      ViewInfo.GalleryBounds.Left);
    Result.Right := Result.Left + AGroupViewInfo.ItemSize.cx;
  end;

  procedure DownDirection(AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    var AGroupIndex: Integer; var ARow, AColumn: Integer);
  var
    ARange: TXRange;
  begin
    if (ARow < AGroupViewInfo.GetRowCount(GetGalleryWidth) - 1) and
      (AColumn <= AGroupViewInfo.GetColumnCountInRow(ARow + 1,
      GetGalleryWidth) - 1) then
      Inc(ARow)
    else
    begin
      ARange := GetColumnRange(AGroupViewInfo, AColumn);
      Inc(AGroupIndex);
      TransferToAnotherGroup(AGroupIndex, ARange, True, ARow, AColumn);
    end;
  end;

  procedure LeftDirection(AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    var ARow, AColumn: Integer);
  begin
    if AColumn > 0 then
      Dec(AColumn)
    else
      AColumn := AGroupViewInfo.GetColumnCountInRow(ARow,
        GetGalleryWidth) - 1;
  end;

  procedure RightDirection(AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    var ARow, AColumn: Integer);
  begin
    if AColumn < AGroupViewInfo.GetColumnCountInRow(ARow,
      GetGalleryWidth) - 1 then
      Inc(AColumn)
    else
      AColumn := 0;
  end;

  procedure UpDirection(AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    var AGroupIndex: Integer; var ARow, AColumn: Integer);
  var
    ARange: TXRange;
  begin
    if ARow > 0 then
      Dec(ARow)
    else
    begin
      ARange := GetColumnRange(AGroupViewInfo, AColumn);
      Dec(AGroupIndex);
      TransferToAnotherGroup(AGroupIndex, ARange, False, ARow, AColumn);
    end;
  end;

var
  ADestroyAfterUse: Boolean;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  AGroupIndex: Integer;
  AGroupItemColumn: Integer;
  AGroupItemRow: Integer;
  AHotGroupItem: TdxRibbonGalleryGroupItem;
  AKeyboardHotGroupItem: TdxRibbonGalleryGroupItem;
begin
  AKeyboardHotGroupItem := KeyboardHotGroupItem;
  if AKeyboardHotGroupItem <> nil then
  begin
    AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, ViewInfo,
      AKeyboardHotGroupItem.Group.Index, ADestroyAfterUse);
    try
      {if ADestroyAfterUse then
        AGroupViewInfo.SetBounds(ViewInfo.GalleryBounds);}
      AGroupIndex := AKeyboardHotGroupItem.Group.Index;
      AGroupItemRow := AGroupViewInfo.GetItemRow(AKeyboardHotGroupItem.Index,
        GetGalleryWidth);
      AGroupItemColumn := AGroupViewInfo.GetItemColumn(
        AKeyboardHotGroupItem.Index, GetGalleryWidth);
      AHotGroupItem := AKeyboardHotGroupItem;
      case ADirection of
        andLeft: LeftDirection(AGroupViewInfo, AGroupItemRow, AGroupItemColumn);
        andUp: UpDirection(AGroupViewInfo, AGroupIndex, AGroupItemRow, AGroupItemColumn);
        andRight: RightDirection(AGroupViewInfo, AGroupItemRow, AGroupItemColumn);
        andDown: DownDirection(AGroupViewInfo, AGroupIndex, AGroupItemRow, AGroupItemColumn);
      end;

      if not InRange(AGroupIndex, 0, GroupCount - 1) then
      begin
        if AGroupIndex < 0 then
          BarNavigationController.ChangeSelectedObject(False, TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).Last.Control.IAccessibilityHelper)
        else
          BarNavigationController.ChangeSelectedObject(False, TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).First.Control.IAccessibilityHelper);
        AHotGroupItem := nil;
      end
      else
      begin
        if AHotGroupItem.Group.Index <> AGroupIndex then
        begin
          if ADestroyAfterUse then
            FreeAndNil(AGroupViewInfo);
          AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, ViewInfo,
            AGroupIndex, ADestroyAfterUse);
        end;
        AHotGroupItem := GetGroupItem(AGroupIndex, AGroupViewInfo.GetItemIndex(
          AGroupItemRow, AGroupItemColumn, GetGalleryWidth));
      end;
    finally
      if ADestroyAfterUse then
        FreeAndNil(AGroupViewInfo);
    end;
  end
  else
    AHotGroupItem := GetFirstGroupItem;

  SetHotGroupItem(AHotGroupItem);
  FLastCommandFromKeyboard := True;
end;

procedure TdxRibbonOnSubMenuGalleryController.FilterMenuControlDestroyed;
begin
  FFilterMenuControl := nil;
end;

procedure TdxRibbonOnSubMenuGalleryController.HotTrackFirstGroupItem;
begin
  HotTrackItem(GetFirstGroupItem);
end;

procedure TdxRibbonOnSubMenuGalleryController.HotTrackLastGroupItem;
begin
  HotTrackItem(GetLastGroupItem);
end;

function TdxRibbonOnSubMenuGalleryController.IsFilterMenuShowed: Boolean;
begin
  Result := FFilterMenuControl <> nil;
end;

procedure TdxRibbonOnSubMenuGalleryController.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FDontShowFilterMenuOnMouseDown then
    FDontShowFilterMenuOnMouseDown := False
  else
    if (Button = mbLeft) and GalleryItem.IsFilterVisible and
      ViewInfo.IsPtInFilterBandHotTrackArea(Point(X, Y)) then
      begin
        ShowFilterMenu;
        GroupItemHotTrackEnabled := True;
      end;
  CheckFilterMenuHotTrack;
end;

procedure TdxRibbonOnSubMenuGalleryController.MouseLeave;
begin
  inherited MouseLeave;
  if GalleryItem.IsFilterVisible then
    ViewInfo.SetFilterBandHotTrack(False);
end;

procedure TdxRibbonOnSubMenuGalleryController.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if GalleryItem.IsFilterVisible then
    CheckFilterMenuHotTrack;
end;

procedure TdxRibbonOnSubMenuGalleryController.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  CheckFilterMenuHotTrack;
end;

procedure TdxRibbonOnSubMenuGalleryController.PageDown;
var
  AHotTrackedGroupItemBottom, AHotTrackedGroupItemTop: Integer;
  ACurrentGroupItemBottom, ACurrentGroupItemTop, AWidth: Integer;
  ACurrentGroupItem, AHotGroupItem, ARequiredGroupItem: TdxRibbonGalleryGroupItem;
  AGroupIndex, AGroupRowIndex: Integer;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse, AItemIsObtained: Boolean;
  AViewInfo: TdxRibbonGalleryControlViewInfo;
begin
  AViewInfo := ViewInfo;
  AHotGroupItem := AViewInfo.HotGroupItem;
  if AHotGroupItem = nil then
    if GalleryItem.SelectedGroupItem <> nil then
      AHotGroupItem := GalleryItem.SelectedGroupItem
    else
      AHotGroupItem := GetFirstGroupItem;
  if AHotGroupItem = nil then
    Exit;

  AWidth := AViewInfo.GallerySize.cx;
  ViewInfo.GroupItemYRange(AHotGroupItem,
    AHotTrackedGroupItemTop, AHotTrackedGroupItemBottom);
  AGroupIndex := AHotGroupItem.Group.Index;
  AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, AViewInfo, AGroupIndex,
    ADestroyAfterUse);
  try
    AGroupRowIndex := AGroupViewInfo.GetItemRow(AHotGroupItem.Index, AWidth);
    ACurrentGroupItem := GetGroupItem(AGroupIndex,
      AGroupViewInfo.GetItemIndex(AGroupRowIndex,
      AGroupViewInfo.GetColumnCountInRow(AGroupRowIndex, AWidth) - 1, AWidth));
  finally
    if ADestroyAfterUse then
      AGroupViewInfo.Free;
  end;
  ARequiredGroupItem := ACurrentGroupItem;
  AItemIsObtained := False;
  AGroupIndex := ACurrentGroupItem.Group.Index;
  repeat
    AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, AViewInfo,
      AGroupIndex, ADestroyAfterUse);
    if AGroupViewInfo <> nil then
      try
        repeat
          ACurrentGroupItem := GetGroupItem(AGroupIndex,
            AGroupViewInfo.GetItemIndex(
              AGroupRowIndex, AGroupViewInfo.GetColumnCountInRow(AGroupRowIndex,
                AWidth) - 1, AWidth));
          ViewInfo.GroupItemYRange(ACurrentGroupItem,
            ACurrentGroupItemTop, ACurrentGroupItemBottom);
          if (ACurrentGroupItemBottom - AHotTrackedGroupItemBottom) <
            AViewInfo.GallerySize.cy then
            ARequiredGroupItem := ACurrentGroupItem
          else
            AItemIsObtained := True;
          Inc(AGroupRowIndex);
        until (AGroupRowIndex > AGroupViewInfo.GetRowCount(AWidth) - 1) or
          AItemIsObtained;
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;
    Inc(AGroupIndex);
    AGroupRowIndex := 0;
  until AItemIsObtained or (AGroupIndex > GroupCount - 1);
  if AItemIsObtained then
    SetHotGroupItem(ARequiredGroupItem)
  else
    HotTrackLastGroupItem;
end;

procedure TdxRibbonOnSubMenuGalleryController.PageUp;
var
  AHotTrackedGroupItemBottom, AHotTrackedGroupItemTop: Integer;
  ACurrentGroupItemBottom, ACurrentGroupItemTop: Integer;
  ACurrentGroupItem, ARequiredGroupItem, AHotGroupItem: TdxRibbonGalleryGroupItem;
  AWidth, AGroupIndex, AGroupRowIndex: Integer;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse, AItemIsObtained: Boolean;
  AViewInfo: TdxRibbonGalleryControlViewInfo;
begin
  AViewInfo := ViewInfo;
  AHotGroupItem := AViewInfo.HotGroupItem;
  if AHotGroupItem = nil then
    if GalleryItem.SelectedGroupItem <> nil then
      AHotGroupItem := GalleryItem.SelectedGroupItem
    else
      AHotGroupItem := GetFirstGroupItem;
  if AHotGroupItem = nil then
    Exit;

  AWidth := AViewInfo.GallerySize.cx;
  ViewInfo.GroupItemYRange(AHotGroupItem,
    AHotTrackedGroupItemTop, AHotTrackedGroupItemBottom);
  AGroupIndex := AHotGroupItem.Group.Index;
  AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, AViewInfo, AGroupIndex, ADestroyAfterUse);
  try
    AGroupRowIndex := AGroupViewInfo.GetItemRow(AHotGroupItem.Index, AWidth);
    ACurrentGroupItem := GetGroupItem(AGroupIndex,
      AGroupViewInfo.GetItemIndex(AGroupRowIndex, 0, AWidth));
  finally
    if ADestroyAfterUse then
      AGroupViewInfo.Free;
  end;
  ARequiredGroupItem := ACurrentGroupItem;
  AItemIsObtained := False;
  repeat
    AGroupViewInfo := GetGroupViewInfo(FOwner.GetGroups, ViewInfo,
      AGroupIndex, ADestroyAfterUse);
    if AGroupViewInfo <> nil then
      try
        if AGroupRowIndex = -1 then
          AGroupRowIndex := AGroupViewInfo.GetRowCount(AWidth) - 1;
        repeat
          ACurrentGroupItem := GetGroupItem(AGroupIndex,
            AGroupViewInfo.GetItemIndex(AGroupRowIndex, 0, AWidth));
          ViewInfo.GroupItemYRange(ACurrentGroupItem,
            ACurrentGroupItemTop, ACurrentGroupItemBottom);
          if (AHotTrackedGroupItemTop - ACurrentGroupItemTop) <
            AViewInfo.GallerySize.cy then
            ARequiredGroupItem := ACurrentGroupItem
          else
            AItemIsObtained := True;
          Dec(AGroupRowIndex);
        until (AGroupRowIndex < 0) or AItemIsObtained;
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;
    Dec(AGroupIndex);
    AGroupRowIndex := -1;
  until AItemIsObtained or (AGroupIndex < 0);
  if AItemIsObtained then
  begin
    AViewInfo.DontDisplayGroupHeaderWhenHotTrackingGroupItem :=
      AViewInfo.DontDisplayGroupHeaderWhenHotTrackingGroupItem + 1;
    try
      SetHotGroupItem(ARequiredGroupItem)
    finally
      AViewInfo.DontDisplayGroupHeaderWhenHotTrackingGroupItem :=
        AViewInfo.DontDisplayGroupHeaderWhenHotTrackingGroupItem - 1;
    end;
  end
  else
    HotTrackFirstGroupItem;
end;

procedure TdxRibbonOnSubMenuGalleryController.Tabulation;
var
  AGroupIndex: Integer;
  AGroupItem: TdxRibbonGalleryGroupItem;
begin
  AGroupItem := KeyboardHotGroupItem;
  if AGroupItem <> nil then
  begin
    if GetKeyState(VK_SHIFT) and 128 <> 128 then
    begin
      if AGroupItem.Index < AGroupItem.Group.Items.Count - 1 then
        AGroupItem := AGroupItem.Group.Items[AGroupItem.Index + 1]
      else
      begin
        AGroupIndex := -1;
        if AGroupItem.Group.Index < FOwner.GetGroups.Count - 1 then
          AGroupIndex := ViewInfo.GetVisibleNotEmptyGroupIndex(
            AGroupItem.Group.Index + 1, True);
        if AGroupIndex = -1 then
          if TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).First <> nil then
          begin
            BarNavigationController.ChangeSelectedObject(True,
              TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).First.Control.IAccessibilityHelper);
            AGroupItem := nil;
          end
          else
            AGroupIndex := ViewInfo.GetVisibleNotEmptyGroupIndex(0, True);
        if AGroupIndex <> -1 then
          AGroupItem := FOwner.GetGroups[AGroupIndex].Items[0];
      end;
    end
    else
      if AGroupItem.Index > 0 then
        AGroupItem := AGroupItem.Group.Items[AGroupItem.Index - 1]
      else
      begin
        AGroupIndex := -1;
        if AGroupItem.Group.Index > 0 then
          AGroupIndex := ViewInfo.GetVisibleNotEmptyGroupIndex(
            AGroupItem.Group.Index - 1, False);
        if AGroupIndex = -1 then
          if TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).Last <> nil then
          begin
            BarNavigationController.ChangeSelectedObject(True,
              TdxBarItemLinksAccess(FOwner.Parent.ItemLinks).Last.Control.IAccessibilityHelper);
            AGroupItem := nil;
          end
          else
            AGroupIndex := ViewInfo.GetVisibleNotEmptyGroupIndex(
              FOwner.GetGroups.Count - 1, False);
        if AGroupIndex <> -1 then
        begin
          AGroupItem := FOwner.GetGroups[AGroupIndex].Items[FOwner.GetGroups[AGroupIndex].Items.Count - 1];
        end;
      end;
  end
  else
    AGroupItem := GetFirstGroupItem;
  SetHotGroupItem(AGroupItem);
end;

procedure TdxRibbonOnSubMenuGalleryController.CheckFilterMenuHotTrack;
begin
  ViewInfo.SetFilterBandHotTrack((ActiveBarControl = FOwner.Parent) and not (ssLeft in InternalGetShiftState) and
    ViewInfo.IsPtInFilterBandHotTrackArea(FOwner.Parent.ScreenToClient(GetMouseCursorPos)));
end;

procedure TdxRibbonOnSubMenuGalleryController.FilterMenuButtonClick(Sender: TObject);
begin
  if GalleryItem.GalleryFilter.Categories.Count = 0 then
    FilterMenuGroupButtonClick(Sender)
  else
    FilterMenuCategoryButtonClick(Sender);
end;

procedure TdxRibbonOnSubMenuGalleryController.FilterMenuCategoryButtonClick(
  Sender: TObject);
var
  AItem: TdxBarItem;
  ANewActiveCategoryIndex, I: Integer;
begin
  ANewActiveCategoryIndex := TdxBarButton(Sender).Tag;

  for I := 0 to FFilterMenuControl.ItemLinks.VisibleItemCount - 1 do
  begin
    AItem := FFilterMenuControl.ItemLinks.VisibleItems[I].Item;
    if IsFilterMenuInternalButton(AItem) and (AItem.Tag >= 0) then
      TdxBarButton(AItem).Down := AItem.Tag = ANewActiveCategoryIndex;
  end;

  if GalleryItem.GalleryFilter.ActiveCategoryIndex <> ANewActiveCategoryIndex then
  begin
    GalleryItem.GalleryFilter.ActiveCategoryIndex := ANewActiveCategoryIndex;
    GalleryItem.DoFilterChanged;
    ViewInfo.RepaintFilterBand;
  end;

  HideFilterMenu;
end;

procedure TdxRibbonOnSubMenuGalleryController.FilterMenuGroupButtonClick(
  Sender: TObject);
var
  AButton: TdxBarButton;
  AIsFilterChanged, AShowAllGroups: Boolean;
  AItem: TdxBarItem;
  I: Integer;
begin
  AButton := TdxBarButton(Sender);
  if AButton.Tag >= 0 then
  begin
    GalleryItem.GalleryGroups[AButton.Tag].Visible := AButton.Down;
    AIsFilterChanged := True;
  end
  else
  begin
    AIsFilterChanged := False;
    AShowAllGroups := AButton.Tag = -1;
    GalleryItem.LockFilterChanged(True);
    try
      for I := 0 to FFilterMenuControl.ItemLinks.VisibleItemCount - 1 do
      begin
        AItem := FFilterMenuControl.ItemLinks.VisibleItems[I].Item;
        if IsFilterMenuInternalButton(AItem) and (AItem.Tag >= 0) and
          (TdxBarButton(AItem).Down <> AShowAllGroups) then
        begin
          TdxBarButton(AItem).Down := AShowAllGroups;
          GalleryItem.GalleryGroups[AItem.Tag].Visible := AShowAllGroups;
          AIsFilterChanged := True;
        end;
      end;
    finally
      GalleryItem.LockFilterChanged(False);
    end;
  end;
  if AIsFilterChanged then
  begin
    GalleryItem.DoFilterChanged;
    ViewInfo.RepaintFilterBand;
  end;
end;

function TdxRibbonOnSubMenuGalleryController.GetFirstGroupItem: TdxRibbonGalleryGroupItem;
var
  AGroup: TdxRibbonGalleryGroup;
  I: Integer;
begin
  Result := nil;
  for I := 0 to GalleryItem.GalleryGroups.Count - 1 do
    if GalleryItem.IsGroupVisible(I) then
    begin
      AGroup := GalleryItem.GalleryGroups[I];
      if AGroup.Items.Count <> 0 then
      begin
        Result := AGroup.Items[0];
        Break;
      end;
    end;
end;

function TdxRibbonOnSubMenuGalleryController.GetGalleryWidth: Integer;
begin
  Result := ViewInfo.GallerySize.cx;
end;

function TdxRibbonOnSubMenuGalleryController.GetLastGroupItem: TdxRibbonGalleryGroupItem;
var
  AGroup: TdxRibbonGalleryGroup;
  I: Integer;
begin
  Result := nil;
  for I := GalleryItem.GalleryGroups.Count - 1 downto 0 do
    if GalleryItem.IsGroupVisible(I) then
    begin
      AGroup := GalleryItem.GalleryGroups[I];
      if AGroup.Items.Count <> 0 then
      begin
        Result := AGroup.Items[AGroup.Items.Count - 1];
        Break;
      end;
    end;
end;

function TdxRibbonOnSubMenuGalleryController.GetViewInfo: TdxRibbonOnSubMenuGalleryControlViewInfo;
begin
  Result := TdxRibbonOnSubMenuGalleryControlViewInfo(FOwner.ViewInfo);
end;

procedure TdxRibbonOnSubMenuGalleryController.HideFilterMenu;
begin
  FFilterMenuControl.Hide;
  CheckFilterMenuHotTrack;
end;

procedure TdxRibbonOnSubMenuGalleryController.InitFilterMenu(
  AItemLinks: TdxBarItemLinks);

  procedure AddButton(const ACaption: string; AIsCheckable, AIsDown: Boolean;
    ATag: Longint; ABeginGroup: Boolean);
  var
    AButton: TdxBarButton;
  begin
    AButton := TdxBarButton(BarDesignController.AddInternalItem(AItemLinks,
      TdxBarButton, ACaption, FilterMenuButtonClick).Item);
    AButton.CloseSubMenuOnClick := False;
    if AIsCheckable then
    begin
      AButton.ButtonStyle := bsChecked;
      AButton.Down := AIsDown;
    end;
    AButton.Tag := ATag;
    AButton.Links[0].BeginGroup := ABeginGroup;
  end;

var
  I: Integer;
begin
  BarDesignController.ClearInternalItems;
  if GalleryItem.GalleryFilter.Categories.Count = 0 then
  begin
    for I := 0 to GalleryItem.GalleryGroups.Count - 1 do
      if GalleryItem.IsGroupVisible(I, True) then
        AddButton(GalleryItem.GalleryGroups[I].Header.Caption, True,
          GalleryItem.GalleryGroups[I].Visible, I, False);
    AddButton(cxGetResourceString(@dxSBAR_SHOWALLGALLERYGROUPS), False, False, -1, True);
    AddButton(cxGetResourceString(@dxSBAR_HIDEALLGALLERYGROUPS), False, False, -2, False);
  end
  else
  begin
    for I := 0 to GalleryItem.GalleryFilter.Categories.Count - 1 do
      AddButton(GalleryItem.GalleryFilter.Categories[I].Caption, True,
        I = GalleryItem.GalleryFilter.ActiveCategoryIndex, I, False);
    AddButton(cxGetResourceString(@dxSBAR_CLEARGALLERYFILTER), False, False, -1, True);
  end;

  GalleryItem.DoInitFilterMenu(AItemLinks);
end;

function TdxRibbonOnSubMenuGalleryController.IsFilterMenuInternalButton(
  AItem: TdxBarItem): Boolean;
begin
  FTempEventHandler := FilterMenuButtonClick;
  Result := Assigned(AItem.OnClick) and
    EqualMethods(TMethod(AItem.OnClick), TMethod(FTempEventHandler));
end;

procedure TdxRibbonOnSubMenuGalleryController.ShowFilterMenu;
var
  AOwnerHeight: Integer;
  P: TPoint;
begin
  FFilterMenuControl := TdxRibbonGalleryFilterMenuControl.Create(FOwner);
  FFilterMenuControl.FParentWnd := FOwner.Parent.Handle;
  FFilterMenuControl.ParentBar := FOwner.Parent;
  FFilterMenuControl.OwnerControl := FOwner.Parent;
  InitFilterMenu(FFilterMenuControl.ItemLinks);
  ViewInfo.GetFilterMenuShowingParams(P, AOwnerHeight);
  FFilterMenuControl.OwnerHeight := AOwnerHeight;
  FFilterMenuControl.Left := P.X;
  FFilterMenuControl.Top := P.Y;
  FFilterMenuControl.Show;
end;

{ TdxRibbonGalleryFilterMenuControl }

constructor TdxRibbonGalleryFilterMenuControl.Create(
  AGalleryControl: TdxRibbonGalleryControl);
begin
  inherited Create(AGalleryControl.BarManager);
  FGalleryControl := AGalleryControl;
  FGalleryControlLink := cxAddObjectLink(AGalleryControl);
end;

destructor TdxRibbonGalleryFilterMenuControl.Destroy;
begin
  if (FGalleryControlLink.Ref <> nil) and (FGalleryControl.Controller <> nil) then
    TdxRibbonOnSubMenuGalleryController(GalleryControl.Controller).FilterMenuControlDestroyed;
  cxRemoveObjectLink(FGalleryControlLink);
  inherited Destroy;
end;

function TdxRibbonGalleryFilterMenuControl.GetBehaviorOptions: TdxBarBehaviorOptions;
begin
  Result := inherited GetBehaviorOptions - [bboItemCustomizePopup];
end;

function TdxRibbonGalleryFilterMenuControl.GetPainter: TdxBarPainter;
begin
  Result := GalleryControl.Painter;
end;

procedure TdxRibbonGalleryFilterMenuControl.ProcessMouseDownMessageForMeaningParent(
  AWnd: HWND; AMsg: UINT; const AMousePos: TPoint);
begin
  inherited ProcessMouseDownMessageForMeaningParent(AWnd, AMsg, AMousePos);
  TdxRibbonOnSubMenuGalleryController(GalleryControl.Controller).HideFilterMenu;
  if TdxRibbonOnSubMenuGalleryControlViewInfo(GalleryControl.ViewInfo).IsPtInFilterBandHotTrackArea(
    RealOwnerControl.ScreenToClient(AMousePos)) then
      FDontShowFilterMenuOnMouseDown := True;
end;

{ TdxRibbonGalleryControl }

constructor TdxRibbonGalleryControl.Create(AItemLink: TdxBarItemLink);
begin
  inherited Create(AItemLink);
  FController := CreateController;
  FScrollBar := TdxRibbonGalleryScrollBar.Create(Self);
  FScrollBar.Visible := False;
  FScrollBar.Parent := Parent;
  FScrollBar.SmallChange := 3;
  FScrollBar.OnDropDown := DoScrollBarDropDown;
  FScrollBar.OnMouseMove := DoScrollBarMouseMove;
  FScrollBar.OnScroll := DoScrollBarScroll;
end;

destructor TdxRibbonGalleryControl.Destroy;
begin
  FreeAndNil(FScrollBar);
  FreeAndNil(FController);
  inherited Destroy;
end;

procedure TdxRibbonGalleryControl.ShowGroupItem(AGroupItem: TdxRibbonGalleryGroupItem);
begin
  ViewInfo.ShowGroupItem(AGroupItem);
end;

function TdxRibbonGalleryControl.DoHint(var ANeedDeactivate: Boolean;
  out AHintText: string; out AShortCut: string): Boolean;
begin
  AHintText := '';
  AShortCut := '';
  ANeedDeactivate := False;
  Result := FHintItem <> nil;
  if Result then
    AHintText := FHintItem.Caption;
end;

function TdxRibbonGalleryControl.GetHintPosition(const ACursorPos: TPoint;
  AHeight: Integer): TPoint;
begin
  Result := inherited GetHintPosition(ACursorPos, AHeight);
  if ViewInfo.IsInRibbon then
    Result.X := Parent.ClientToScreen(FHintBounds.TopLeft).X
  else
  begin
    Result := GetMouseCursorPos;
    Inc(Result.Y, 20);
  end;
end;

procedure TdxRibbonGalleryControl.UpdateHint(AHintItem: TdxRibbonGalleryGroupItem;
  const ABounds: TRect);
begin
  FHintItem := AHintItem;
  FHintBounds := ABounds;
  if FHintItem <> nil then
    BarManager.ActivateHint(True, '', Self)
  else
    BarManager.ActivateHint(False, '');
end;

function TdxRibbonGalleryControl.CalcDefaultWidth: Integer;

  function GetColumnCount: Integer;
  begin
    if Parent.Kind = bkBarControl then
      Result := (ViewInfo as IdxBarMultiColumnItemControlViewInfo).GetColumnCount
    else
      Result := Item.GalleryOptions.ColumnCount;
  end;

const
  MinWidth = 100;
var
  AScrollbarAndIndents: Integer;
  AGroupItemWidthIsNull: Boolean;
begin
  if GetVisibleGroupCount > 0 then
  begin
    ViewInfo.CalculateGlobalItemSize;
    Result := ViewInfo.GetLayoutWidth(GetColumnCount, AGroupItemWidthIsNull);
    AScrollbarAndIndents := ViewInfo.GetScrollBarWidth +
      ViewInfo.GetLeftLayoutIndent +
      ViewInfo.GetRightLayoutIndent; //TODO: duplicated with TdxRibbonGalleryGroupViewInfo.GetColumnLeft
    if (Result = 0) or AGroupItemWidthIsNull then
      Result := MinWidth - AScrollbarAndIndents;
    Result := Result + AScrollbarAndIndents;
    Result := Result +
      Max(0, ViewInfo.GetGalleryMargins.Left) +
      Max(0, ViewInfo.GetGalleryMargins.Right);
  end
  else
    Result := MinWidth;//TODO: GetMinWidth
  Result := Min(Result,
    Screen.Width - 2 * Painter.SubMenuControlNCBorderSize);
end;

function TdxRibbonGalleryControl.CalcMinHeight: Integer;
var
  AItemHeight, ARowHeight, AHeaderHeight: Integer;
  ADestroyAfterUse: Boolean;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  I: Integer;
begin
  if GetGroups.Count > 0 then
  begin
    ARowHeight := 0;
    AHeaderHeight := 0;
    for I := 0 to GetGroups.Count - 1 do
      if Item.IsGroupVisible(I) then
      begin
        AGroupViewInfo := GetGroupViewInfo(GetGroups, ViewInfo, I,
          ADestroyAfterUse);
        try
          AItemHeight := AGroupViewInfo.GetRowHeight -
            AGroupViewInfo.GetSpaceBetweenItems(False);
          ARowHeight := Max(ARowHeight, AItemHeight);
          AHeaderHeight := Max(AHeaderHeight,
            AGroupViewInfo.Header.GetHeight(ViewInfo.GallerySize.cx, True));
        finally
          if ADestroyAfterUse then
            AGroupViewInfo.Free;
        end;
        if Item.GalleryOptions.EqualItemSizeInAllGroups then Break;
      end;
    Result := AHeaderHeight + ARowHeight;
  end
  else
    Result := 0;
end;

procedure TdxRibbonGalleryControl.CalcParts;
begin
  inherited CalcParts;
  if not FLockCalcParts then
  begin
    ScrollBarSetup;
    if not Collapsed then
      ViewInfo.Calculate(FScrollBar.Position, scPosition);
  end;
end;

function TdxRibbonGalleryControl.CanClicked: Boolean;
begin
  Result := not Collapsed and not FIsDroppingDown;
end;

procedure TdxRibbonGalleryControl.ControlUnclick(ByMouse: Boolean);
var
  AInRibbonGalleryControlLink: TcxObjectLink;
  AItem: TdxRibbonGalleryItem;
  AGalleryControl: TdxRibbonGalleryControl;
begin
  if not Collapsed and (Parent.Kind <> bkBarControl) and
    (Parent.ParentBar <> nil) and (Parent.ParentBar.Kind = bkBarControl) and
    TdxBarItemControlAccess(TdxRibbonDropDownGalleryControl(Parent).ParentItemControl).IsExpandable then
      AInRibbonGalleryControlLink := cxAddObjectLink(TdxRibbonDropDownGalleryControl(Parent).ParentItemControl)
  else
    AInRibbonGalleryControlLink := nil;
  try
    AItem := Item;
    if ByMouse then
    begin
      with Parent.ScreenToClient(GetMouseCursorPos) do
        Item.FClickedGroupItem := ViewInfo.GetGroupItem(X, Y);
      if Item.FClickedGroupItem = nil then
      begin
        inherited ControlUnclick(ByMouse);
        Exit;
      end;
    end
    else
    begin
      {if Controller.KeyboardHotGroupItem = nil then
        raise EdxException.Create('');}
      Item.FClickedGroupItem := Controller.KeyboardHotGroupItem;
    end;
    inherited ControlUnclick(ByMouse);
    if (AInRibbonGalleryControlLink <> nil) and (AInRibbonGalleryControlLink.Ref <> nil) then
    begin
      AGalleryControl := TdxRibbonGalleryControl(AInRibbonGalleryControlLink.Ref);
      if (AGalleryControl.Item = AItem) then
        AGalleryControl.ViewInfo.ShowGroupItem(AItem.FClickedGroupItem);
    end;
  finally
    cxRemoveObjectLink(AInRibbonGalleryControlLink);
  end;
end;

function TdxRibbonGalleryControl.CreateController: TdxRibbonGalleryController;
begin
  case Parent.Kind of
    bkBarControl: Result := TdxRibbonGalleryController.Create(Self);
    bkSubMenu: Result := TdxRibbonOnSubMenuGalleryController.Create(Self);
  else
    raise EdxException.Create('');
  end;
end;

procedure TdxRibbonGalleryControl.DoCloseUp(AHadSubMenuControl: Boolean);
begin
  FIsClosingUpSubMenuControl := True;
  try
    inherited DoCloseUp(AHadSubMenuControl);
    Item.ItemLinks.BarControl := nil;
  finally
    FIsClosingUpSubMenuControl := False;
  end;
end;

procedure TdxRibbonGalleryControl.DoDropDown(AByMouse: Boolean);
begin
  inherited DoDropDown(AByMouse);
  if IsDroppedDown then
    Controller.GroupItemHotTrackEnabled := True;
end;

procedure TdxRibbonGalleryControl.DropDown(AByMouse: Boolean);
begin
  Controller.KeyboardHotGroupItem := nil;
  FIsDroppingDown := True;
  try
    inherited DropDown(AByMouse);
  finally
    FIsDroppingDown := False;
  end;
end;

procedure TdxRibbonGalleryControl.EnabledChanged;
begin
  inherited EnabledChanged;
  ScrollBarSetup;
end;

function TdxRibbonGalleryControl.GetClientHeight: Integer;
begin
  Result := Max(0, ViewInfo.GallerySize.cy);
end;

function TdxRibbonGalleryControl.GetClientWidth: Integer;
begin
  Result := Max(0, ViewInfo.GallerySize.cx);
end;

function TdxRibbonGalleryControl.GetDefaultHeightInSubMenu: Integer;
begin
  if Collapsed then
    Result := inherited GetDefaultHeightInSubMenu
  else
    Result := ViewInfo.GetHeight(
      GetDefaultWidthInSubMenu) + Max(0, ViewInfo.GetGalleryMargins.Top) +
      Max(0, ViewInfo.GetGalleryMargins.Bottom);
end;

function TdxRibbonGalleryControl.GetDefaultWidthInSubMenu: Integer;
begin
  if Collapsed then
    Result := inherited GetDefaultWidthInSubMenu
  else
    Result := CalcDefaultWidth;
end;

{function TdxRibbonGalleryControl.GetMinWidth: Integer; //TODO: dropdoun is use this for default width
begin
  Result := 100;
end;}

function TdxRibbonGalleryControl.GetMouseWheelStep: Integer;
const
  WheelRowCount = 3;
var
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  I, AGroupCount, AHeightSum: Integer;
  ADestroyAfterUse: Boolean;
begin
  Result := 0;
  AGroupCount := 0;
  AHeightSum := 0;
  for I := 0 to GetGroups.Count - 1 do
    if Item.IsGroupVisible(I) then
    begin
      AGroupViewInfo := GetGroupViewInfo(GetGroups, ViewInfo, I,
        ADestroyAfterUse);
      try
        Inc(AGroupCount);
        AHeightSum := AHeightSum + AGroupViewInfo.GetRowHeight;
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;
    end;
  if AGroupCount <> 0 then
    Result := MulDiv(AHeightSum, WheelRowCount, AGroupCount);
end;

procedure TdxRibbonGalleryControl.GetSubMenuControlPositionParams(out P: TPoint;
  out AOwnerWidth, AOwnerHeight: Integer);
begin
  if not Collapsed and ScrollBar.IsDropDownStyle and not Parent.IsCustomizing then
  begin
    P := Parent.ClientToScreen(cxPointOffset(
      ViewInfo.GalleryBounds.TopLeft, -DropDownOffsetX, -DropDownOffsetY));
    AOwnerWidth := 0;
    AOwnerHeight := 1;
  end
  else
    inherited GetSubMenuControlPositionParams(P, AOwnerWidth, AOwnerHeight);
end;

function TdxRibbonGalleryControl.InternalGetDefaultWidth: Integer;
begin
  if Collapsed then
    Result := inherited InternalGetDefaultWidth
  else
    Result := CalcDefaultWidth;
end;

procedure TdxRibbonGalleryControl.Changed;
begin
  ViewInfo.Changed;
end;

function TdxRibbonGalleryControl.WantsKey(Key: Word): Boolean;
begin
  Result := inherited WantsKey(Key) and
    not ((Key = VK_RETURN) and not Collapsed and (Parent.Kind <> bkBarControl));
end;

procedure TdxRibbonGalleryControl.CalcDrawParams(AFull: Boolean = True);
begin
  inherited CalcDrawParams(AFull);
  if Collapsed then
    Exit;
  if AFull then
  begin
    FDrawParams.ShortCut := '';
    FDrawParams.PaintType := TCustomdxBarControlAccess(Parent).GetPaintType;
    FDrawParams.Enabled := Enabled;
    FDrawParams.SelectedByKey := False;
  end;
  FDrawParams.Canvas := Canvas;
end;

procedure TdxRibbonGalleryControl.ControlActivate(Immediately: Boolean);

  function CanActivateControl: Boolean;
  begin
    Result := not Parent.IsCustomizing or
      not (Immediately and not Collapsed and (Parent.Kind = bkBarControl) and
      not ScrollBar.IsDropDownButtonPressed);
  end;

begin
  if CanActivateControl then
    inherited ControlActivate(Immediately);
end;

procedure TdxRibbonGalleryControl.ControlClick(AByMouse: Boolean; AKey: Char = #0);
var
  R: TRect;
begin
  if AByMouse and not Collapsed and (Parent.Kind = bkBarControl) then
  begin
    R := cxGetWindowRect(ScrollBar);
    FIsClickOnItemsArea := not PtInRect(R, InternalGetCursorPos);
  end;
  try
    inherited ControlClick(AByMouse, AKey);
  finally
    FIsClickOnItemsArea := False;
  end;
end;

procedure TdxRibbonGalleryControl.CreateSubMenuControl;

  function CreateCloneForDropDownGallery(AGalleryItem: TdxRibbonGalleryItem): TdxRibbonGalleryItem;
  begin
    if Parent.IsCustomizing then
    begin
      FreeAndNil(FDropDownGalleryItem);
      TdxBarManagerAccess(BarManager).ItemList.BeginUpdate;
      try
        FDropDownGalleryItem := AGalleryItem.CreateCloneForDropDownGallery;
        Result := FDropDownGalleryItem;
        BarDesignController.RemoveItemFromBarManagerList(FDropDownGalleryItem);
      finally
        TdxBarManagerAccess(BarManager).ItemList.CancelUpdate;
      end;
    end
    else
      Result := AGalleryItem;
  end;

var
  ASubMenuGalleryItem: TdxRibbonGalleryItem;
  ASubMenuControl: TCustomdxBarControl;
begin
  ASubMenuControl := TdxRibbonDropDownGalleryControl.Create(BarManager);
  Item.ItemLinks.BarControl := ASubMenuControl;
  if (Item.DropDownGallery <> nil) and Item.DropDownGallery.HasValidGalleryItem then
  begin
    ASubMenuControl.ItemLinks := Item.DropDownGallery.ItemLinks;
    ASubMenuControl.ItemLinks.BarControl := ASubMenuControl;
    ASubMenuGalleryItem := Item.DropDownGallery.GalleryItem;
  end
  else
  begin
    ASubMenuControl.ItemLinks := Item.ItemLinks;
    ASubMenuGalleryItem := CreateCloneForDropDownGallery(Item);
  end;
  TdxRibbonDropDownGalleryControl(ASubMenuControl).GalleryItem := ASubMenuGalleryItem;
end;

procedure TdxRibbonGalleryControl.DoCreateSubMenuControl;
begin
  FIsCreatingSubMenuControl := True;
  try
    inherited DoCreateSubMenuControl;
  finally
    FIsCreatingSubMenuControl := False;
  end;
end;

procedure TdxRibbonGalleryControl.DoPaint(ARect: TRect;
  PaintType: TdxBarPaintType);
begin
  ObtainTextColors;
  if not IsValidPainter then
  begin
    DrawInvalid(ARect);
    Exit;
  end;
  if Collapsed then
  begin
    inherited DoPaint(ARect, PaintType);
    Exit;
  end;
  ViewInfo.Paint;
  with ViewInfo.ScrollBarBounds do
    FScrollBar.SetBounds(Left, Top, Right - Left, Bottom - Top);
  ShowWindow(FScrollBar.Handle, SW_SHOW);
  FScrollBar.Invalidate;
end;

procedure TdxRibbonGalleryControl.FilterCaptionChanged;
begin
  if (Parent.Kind <> bkBarControl) and Item.IsFilterVisible then
    TdxRibbonOnSubMenuGalleryControlViewInfo(ViewInfo).RepaintFilterBand; 
end;

function TdxRibbonGalleryControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonGalleryControlAccessibilityHelper;
end;

function TdxRibbonGalleryControl.GetGroups: TdxRibbonGalleryGroups;
begin
  Result := TdxRibbonGalleryItem(Item).GalleryGroups;
end;

function TdxRibbonGalleryControl.GetSubMenuControl: TdxBarSubMenuControl;
begin
  Result := inherited GetSubMenuControl;
  if (Parent.Kind = bkBarControl) and
    (Result <> nil) and (Result.ParentItemControl <> Self) and
    not FIsCreatingSubMenuControl and not FIsClosingUpSubMenuControl then
    Result := nil;
end;

function TdxRibbonGalleryControl.GetViewInfoClass: TdxBarItemControlViewInfoClass;
begin
  case Parent.Kind of
    bkBarControl: Result := TdxInRibbonGalleryControlViewInfo;
    bkSubMenu: Result := TdxRibbonOnSubMenuGalleryControlViewInfo;
  else
    raise EdxException.Create('');
  end;
end;

function TdxRibbonGalleryControl.GetVisibleGroupCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetGroups.Count - 1 do
    if Item.IsGroupVisible(I) then
      Inc(Result);
end;

function TdxRibbonGalleryControl.HasSubMenu: Boolean;
begin
  if not IsValidPainter then
  begin
    Result := False;
    Exit;
  end;
  Result := Collapsed or (Parent.Kind = bkBarControl) and
    (Parent.IsCustomizing or not FIsClickOnItemsArea);
end;

function TdxRibbonGalleryControl.IsDestroyOnClick: Boolean;
begin
  if not Collapsed and (Parent.Kind <> bkBarControl) and
    TdxRibbonOnSubMenuGalleryControlViewInfo(ViewInfo).IsPtInFilterBandHotTrackArea(
      Parent.ScreenToClient(GetMouseCursorPos)) then
        Result := False
  else
    Result := CanClicked;
end;

function TdxRibbonGalleryControl.IsEnabledScrollBar: Boolean;
begin
  Result := Enabled and (ScrollBar.IsDropDownStyle or
    (ViewInfo.GetGalleryHeight(ClientWidth) > ClientHeight) and
    not Item.RecalculatingOnFilterChanged);
end;

function TdxRibbonGalleryControl.IsHiddenForCustomization: Boolean;
begin
  Result := Item.IsClone;
end;

function TdxRibbonGalleryControl.IsNeedScrollBar: Boolean;
begin
  if not FIsNeedScrollBarLock then
  begin
    FIsNeedScrollBarLock := True;
    try
      Result := not Collapsed and ((Parent.Kind = bkBarControl) or
        (Item.GalleryOptions.SubMenuResizing in [gsrHeight, gsrWidthAndHeight]) or
        IsEnabledScrollBar);
    finally
      FIsNeedScrollBarLock := False;
    end;
  end
  else
    Result := False;
end;

function TdxRibbonGalleryControl.IsValidPainter: Boolean;
begin
  Result := (Parent <> nil) and (Painter is TdxBarSkinnedPainter);
end;

procedure TdxRibbonGalleryControl.MouseLeave;
begin
  inherited MouseLeave;
  if not Collapsed then
    Controller.MouseLeave;
end;

procedure TdxRibbonGalleryControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Collapsed then
    Controller.MouseDown(Button, Shift, X, Y);
end;

procedure TdxRibbonGalleryControl.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if not Collapsed then
    Controller.MouseMove(Shift, X, Y);
end;

procedure TdxRibbonGalleryControl.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if not Collapsed then
    Controller.MouseUp(Button, Shift, X, Y);
end;

procedure TdxRibbonGalleryControl.DoScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);

  function CanHandleScrollCode: Boolean;
  begin
    Result := not (ScrollBar.IsDropDownStyle and (
        (ScrollCode = scLineUp) and not ViewInfo.GetPreviousButtonEnabled or
        (ScrollCode = scLineDown) and not ViewInfo.GetNextButtonEnabled or
        (ScrollCode = scEndScroll)));
  end;

begin
  if not CanHandleScrollCode then
    Exit;
  ScrollPos := Min(ScrollPos, ViewInfo.GetGalleryHeight(ClientWidth) -
    ClientHeight);
  ViewInfo.Calculate(ScrollPos, ScrollCode);
  ScrollBarSetup;
  Repaint;
end;

procedure TdxRibbonGalleryControl.DoScrollBarMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  TCustomdxBarControlAccess(Parent).MouseMove(Shift, FScrollBar.Left + X,
    FScrollBar.Top + Y);
end;

procedure TdxRibbonGalleryControl.ScrollBarSetup;
var
  AGalleryHeight, ALargeChange: Integer;
begin
  FScrollBar.Visible := IsNeedScrollBar;
  if Collapsed then
  begin
    ShowWindow(FScrollBar.Handle, SW_HIDE);
    Exit;
  end;
  ALargeChange := 1;
  AGalleryHeight := ViewInfo.GetGalleryHeight(ClientWidth);
  if AGalleryHeight > ClientHeight then
  begin
    FScrollBar.SetScrollParams(0, Max(0, AGalleryHeight - 1),
      ViewInfo.LayoutOffset, Max(0, ClientHeight));
    if (ClientHeight > 1) then
      ALargeChange := ClientHeight;
  end
  else                                          
    FScrollBar.SetScrollParams(0, 1, 0, 0);
  FScrollBar.LargeChange := ALargeChange;
  ScrollBar.Enabled := IsEnabledScrollBar;
end;

procedure TdxRibbonGalleryControl.SetScrollBarPosition(APosition: Integer);
var
  AScrollCode: TScrollCode;
begin
  if (FScrollBar.Enabled) and (FScrollBar.Position <> APosition) then
  begin
    if FScrollBar.Position > APosition then
      AScrollCode := scLineUp
    else
      AScrollCode := scLineDown;
    FScrollBar.Position := APosition;
    DoScrollBarScroll(FScrollBar, AScrollCode, APosition);
  end;
end;

procedure TdxRibbonGalleryControl.DoScrollBarDropDown(Sender: TObject);
begin
  if Parent.IsCustomizing then
  begin
    BarNavigationController.ChangeSelectedObject(True, IAccessibilityHelper);
    DropDown(True);
  end
  else
    SendMessage(Parent.Handle, WM_LBUTTONDOWN, ShiftStateToKeys(InternalGetShiftState),
      MakeLParam(ScrollBar.Left, ScrollBar.Top));
end;

procedure TdxRibbonGalleryControl.DrawInvalid(const ABounds: TRect);
begin
  Canvas.Pen.Color := clRed;
  Canvas.SetBrushColor(clWhite);
  Canvas.Brush.Style := bsSolid;
  Canvas.Canvas.Rectangle(ABounds.Left, ABounds.Top, ABounds.Right, ABounds.Bottom);
  Canvas.Canvas.MoveTo(ABounds.Left, ABounds.Top);
  Canvas.Canvas.LineTo(ABounds.Right, ABounds.Bottom - 1);
  Canvas.Canvas.MoveTo(ABounds.Right - 1, ABounds.Top);
  Canvas.Canvas.LineTo(ABounds.Left, ABounds.Bottom - 1);
  Canvas.Brush.Style := bsClear;
  Canvas.DrawText(Item.Caption, ABounds, cxAlignCenter);
  Canvas.Brush.Style := bsSolid;
end;

function TdxRibbonGalleryControl.GetCollapsed: Boolean;
begin
  if not IsValidPainter or (ViewInfo <> nil) and
    (TCustomdxBarControlAccess(Parent).GetItemControlDefaultViewLevel(Self) <> ivlDefault) then
  begin
    Result := True;
    Exit;
  end;

  if FIsCollapsedAssigned then
    Result := FCollapsed
  else
    Result := (ViewInfo <> nil) and ViewInfo.IsCollapsed;
end;

function TdxRibbonGalleryControl.GetItem: TdxRibbonGalleryItem;
begin
  Result := TdxRibbonGalleryItem(ItemLink.Item);
end;

function TdxRibbonGalleryControl.GetViewInfo: TdxRibbonGalleryControlViewInfo;
begin
  Result := TdxRibbonGalleryControlViewInfo(FViewInfo);
end;

procedure TdxRibbonGalleryControl.ObtainTextColors;
var
  AColor1: TColor;
begin
  if (Self.DrawParams.HotPartIndex = icpControl) then
  begin
    if not Item.FSelectedTextColorDetermined then
      Painter.GetTextColors(Self, True, False, True, AColor1,
        Item.FSelectedTextColor);
    Item.FSelectedTextColorDetermined := True;
  end
  else
    if not Item.FDefaultTextColorDetermined then
    begin
      if (Self.DrawParams.HotPartIndex <> icpControl) then
        Painter.GetTextColors(Self, True, False, True, AColor1,
          Item.FDefaultTextColor)
      else
        Item.FDefaultTextColor := 0;
      Item.FDefaultTextColorDetermined := True;
    end;
end;

procedure TdxRibbonGalleryControl.SetCollapsed(Value: Boolean);
begin
  FIsCollapsedAssigned := True;
  FCollapsed := Value;
end;

{ TdxRibbonGalleryGroupElementViewInfo }

constructor TdxRibbonGalleryGroupElementViewInfo.Create(
  AOwner: TdxRibbonGalleryGroupViewInfo);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TdxRibbonGalleryGroupElementViewInfo.Calculate(
  const ABounds: TRect);
begin
  FBounds := ABounds;
end;

procedure TdxRibbonGalleryGroupElementViewInfo.Paint(ACanvas: TcxCanvas);
begin
end;

function TdxRibbonGalleryGroupElementViewInfo.GetFont: TFont;
begin
  Result := Owner.Font;
end;

function TdxRibbonGalleryGroupElementViewInfo.GetGalleryItemControl: TdxRibbonGalleryControl;
begin
  Result := Owner.Owner.Control;
end;

function TdxRibbonGalleryGroupElementViewInfo.GetTextFlags(
  AnAlignment: TAlignment): Integer;
begin
  Result := cxSingleLine or cxAlignVCenter or cxAlignmentsHorz[AnAlignment];
end;

{ TdxRibbonGalleryGroupHeaderViewInfo }

procedure TdxRibbonGalleryGroupHeaderViewInfo.Calculate(
  const ABounds: TRect);
begin
  inherited Calculate(ABounds);
  FTextBounds := GetTextBounds;
end;

procedure TdxRibbonGalleryGroupHeaderViewInfo.Paint(ACanvas: TcxCanvas);
begin
  if IsVisible then
  begin
    ACanvas.Font := GetFont;
    ACanvas.Font.Color := Owner.Painter.Skin.GetPartColor(DXBAR_GALLERYGROUPHEADERTEXT);
    ACanvas.Font.Style := [fsBold];
    ACanvas.Brush.Style := bsClear;
    Owner.Painter.Skin.DrawBackground(ACanvas.Handle, Bounds, DXBAR_GALLERYGROUPHEADERBACKGROUND);
    ACanvas.DrawText(Caption, cxRectInflate(Bounds, -GroupHeaderCaptionOffset, 0),
      GetTextFlags(Owner.Group.Header.Alignment));
    ACanvas.Brush.Style := bsSolid;
  end;
end;

function TdxRibbonGalleryGroupHeaderViewInfo.GetCaption: string;
begin
  Result := Owner.Group.Header.Caption;
end;

function TdxRibbonGalleryGroupHeaderViewInfo.GetHeight(AWidth: Integer;
  AWithSpaceAfterHeader: Boolean): Integer;
begin
  if Owner.Group.Header.Visible and (AWidth <> 0) and
    (Screen.PixelsPerInch <> 0) then
    Result := Round(MulDiv(cxTextHeight(GetFont), 3, 2) *
      96 / Screen.PixelsPerInch) +
      IfThen(AWithSpaceAfterHeader, Owner.Options.GetSpaceAfterGroupHeader)
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupHeaderViewInfo.GetTextBounds: TRect;
begin
  Result := Bounds;
end;

function TdxRibbonGalleryGroupHeaderViewInfo.IsVisible: Boolean;
begin
  Result := Owner.Group.Header.Visible and Owner.Owner.IsGroupHeaderVisible and
    not IsRectEmpty(Bounds);
end;

{ TdxRibbonGalleryGroupItemViewInfo }

constructor TdxRibbonGalleryGroupItemViewInfo.Create(
  AOwner: TdxRibbonGalleryGroupViewInfo;
  AGroupItem: TdxRibbonGalleryGroupItem);
begin
  inherited Create(AOwner);
  FDescriptionLines := TStringList.Create;
  FGroupItem := AGroupItem;
  FDescriptionRowCount := IfThen(GetDescriptionLenght > GetCaptionWidth, 2, 1);
  ResetCachedValues;
end;

destructor TdxRibbonGalleryGroupItemViewInfo.Destroy;
begin
  FDescriptionLines.Free;
  inherited Destroy;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.Calculate(const ABounds: TRect);
begin
  inherited Calculate(ABounds);
  FCaptionBounds := GetRectConsiderBounds(GetCaptionBounds);
  FDescriptionBounds := GetRectConsiderBounds(GetDescriptionBounds);
  FImageBounds := GetImageBounds;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.Paint(ACanvas: TcxCanvas);

  procedure DrawBackground;
  begin
    if GetDowned then
      Painter.Skin.DrawBackground(ACanvas.Canvas.Handle, Bounds,
        DXBAR_SMALLBUTTON, DXBAR_Pressed)
    else
      if GetHotTracked then
      begin
        if GetSelected then
          Painter.Skin.DrawBackground(ACanvas.Canvas.Handle, Bounds,
            DXBAR_SMALLBUTTON, DXBAR_HOTCHECK)
        else
          Painter.Skin.DrawBackground(ACanvas.Canvas.Handle, Bounds,
            DXBAR_SMALLBUTTON, DXBAR_ACTIVE);
      end
      else
      begin
        if GetSelected then
          Painter.Skin.DrawBackground(ACanvas.Canvas.Handle, Bounds,
            DXBAR_SMALLBUTTON, DXBAR_CHECKED)
        else
          Owner.Owner.DrawBackground(Bounds);
      end;
  end;

  procedure DrawSelectionRect(ARect: TRect; AState: Integer);
  var
    ABrushStyle: TBrushStyle;
    APenColor: TColor;
  begin
    ABrushStyle := ACanvas.Brush.Style;
    ACanvas.Brush.Style := bsClear;
    APenColor := ACanvas.Pen.Color;
    try
      ACanvas.Pen.Color := Owner.Painter.Skin.GetPartColor(
        DXBAR_GALLERYGROUPITEM_OUTERBORDER, AState);
      ARect := FImageBounds;
      ACanvas.Canvas.Rectangle(ARect);
      ACanvas.Pen.Color := Owner.Painter.Skin.GetPartColor(
        DXBAR_GALLERYGROUPITEM_INNERBORDER, AState);
      ARect := cxRectInflate(ARect, -1, -1);
      ACanvas.Canvas.Rectangle(ARect);
    finally
      ACanvas.Brush.Style := ABrushStyle;
      ACanvas.Pen.Color := APenColor;
    end;
  end;

  procedure DrawSelection;
  var
    AState: Integer;
  begin
    if IsImageVisible then
    begin
      if GetHotTracked then
      begin
        if GetSelected then
          AState := DXBAR_HOTCHECK
        else
          AState := DXBAR_HOT;
        DrawSelectionRect(FImageBounds, AState);
      end
      else
        if GetSelected then
        begin
          AState := DXBAR_CHECKED;
          DrawSelectionRect(FImageBounds, AState);
        end;
    end;
  end;

begin
  if not IsMergeItemsImages then
    DrawBackground
  else
    Owner.Owner.DrawBackground(Bounds);

  ACanvas.SaveState;
  try
    GroupItem.DrawImage(ACanvas.Canvas.Handle, FImageBounds);
    DrawItemText(ACanvas);
  finally
    ACanvas.Brush.Style := bsSolid;
    ACanvas.RestoreState;
  end;

  if IsMergeItemsImages then
    DrawSelection;
  FChanged := False;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.DrawItemText(ACanvas: TcxCanvas);

  function GetTextAlignmentFlags: UINT;
  begin
    if Options.GetItemImagePosition in [gipLeft, gipRight] then
      Result := cxAlignLeft
    else
      Result := cxAlignHCenter;
    if FDescriptionRowCount = 1 then
      Result := cxSingleLine or cxAlignVCenter or Result;
  end;

  procedure DrawDescription(ACanvas: TcxCanvas; ATextAlignmentFlags: UINT);
  var
    ARect: TRect;
    ALineHeight, I: Integer;
  begin
    ALineHeight := ACanvas.TextHeight('Wg');
    ARect := FDescriptionBounds;
    for I := 0 to FDescriptionLines.Count - 1 do
    begin
      ACanvas.DrawText(FDescriptionLines[I], ARect, ATextAlignmentFlags);
      OffsetRect(ARect, 0, ALineHeight);
    end;
  end;

var
  ADescriptionVisible: Boolean;
  ATextAlignmentFlags: UINT;
begin
  ADescriptionVisible := IsDescriptionVisible;
  ACanvas.Font := Font;
  if GroupItem.Selected then
    ACanvas.Font.Color := Owner.Owner.GalleryItem.SelectedTextColor
  else
    ACanvas.Font.Color := Owner.Owner.GalleryItem.DefaultTextColor;
  ACanvas.Brush.Style := bsClear;
  ATextAlignmentFlags := GetTextAlignmentFlags;
  if IsCaptionVisible then
  begin
    CheckCaptionFontStyle(ACanvas.Font);
    ACanvas.DrawText(Caption, FCaptionBounds, GetTextAlignmentFlags);
  end;
  if ADescriptionVisible then
  begin
    ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
    ValidateDescriptionStrings(ACanvas);
    DrawDescription(ACanvas, ATextAlignmentFlags);
  end;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetCaption: string;
begin
  Result := GroupItem.Caption;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetCaptionHeight: Integer;
begin
  if IsCaptionVisible then
    Result := cxTextHeight(Font)
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetCaptionWidth: Integer;
var
  AFont: TFont;
begin
  if IsCaptionVisible then
  begin
    if FCaptionWidth = 0 then
    begin
      AFont := TFont.Create;
      try
        AFont.Assign(Font);
        CheckCaptionFontStyle(AFont);
        Result := cxTextWidth(AFont, GroupItem.Caption);
      finally
        AFont.Free;
      end;
      FCaptionWidth := Result;
    end
    else
      Result := FCaptionWidth;
  end
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescription: string;
begin
  Result := GroupItem.Description;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescriptionHeight(
  var ADescriptionRect: TRect): Integer;
begin
  if IsDescriptionVisible then
  begin
    if FDescriptionSize.cy = 0 then
    begin
      if cxRectIsNull(ADescriptionRect) then
        ADescriptionRect := GetDescriptionRect;
      Result := ADescriptionRect.Bottom - ADescriptionRect.Top;
      FDescriptionSize.cy := Result;
    end
    else
      Result := FDescriptionSize.cy;
  end
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescriptionWidth(
  var ADescriptionRect: TRect): Integer;
begin
  if IsDescriptionVisible then
  begin
    if FDescriptionSize.cx = 0 then
    begin
      if cxRectIsNull(ADescriptionRect) then
        ADescriptionRect := GetDescriptionRect;
      Result := ADescriptionRect.Right - ADescriptionRect.Left;
      FDescriptionSize.cx := Result;
    end
    else
      Result := FDescriptionSize.cx;
  end
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetHotTracked: Boolean;

  function GetGeneralItemPullHighlighting: TdxRibbonGalleryItemPullHighlighting;
  begin
    Result := Owner.Owner.GalleryOptions.ItemPullHighlighting;
  end;

  function AgreeWithGeneralItemPullHighlighting: Boolean;
  begin
    Result := (Options.ItemPullHighlighting.Active = GetGeneralItemPullHighlighting.Active) and
      (Options.ItemPullHighlighting.Direction = GetGeneralItemPullHighlighting.Direction);
  end;

  function GetIsInHotTrackChain: Boolean;
  begin
    Result := ((GetOuterGroupItem(GroupItem, HotGroupItem,
      Options.ItemPullHighlighting.Direction) <> GroupItem) or
      (GroupItem = HotGroupItem)) and (GetItemPullHighlightingIdentifier(GroupItem) =
      GetItemPullHighlightingIdentifier(HotGroupItem)) and
      (GetGeneralItemPullHighlighting.Active and AgreeWithGeneralItemPullHighlighting or
      not GetGeneralItemPullHighlighting.Active and Options.ItemPullHighlighting.Active );
  end;

begin
  if not IsItemPullHighlighting then
    Result := IsThisGroupItem(HotGroupItem)
  else
    Result := (HotGroupItem <> nil) and GetIsInHotTrackChain;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetSpaceBetweenItemCaptionAndDescription: Integer;
begin
  if IsCaptionVisible and IsDescriptionVisible then
    Result := Options.GetSpaceBetweenItemCaptionAndDescription +
      dxRibbonGalleryGroupItemIndent
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetSpaceBetweenItemImageAndText: Integer;
begin
  if IsCaptionVisible and CanUseSize(GetUnsizedImageSize) then
    Result := Options.GetSpaceBetweenItemImageAndText + dxRibbonGalleryGroupItemIndent
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetImageSize: TSize;

  procedure FitToItemHeight(var AImageSize: TSize);
  var
    ANewImageHeight: Integer;
  begin
    if FPredefinedItemSize.cy <> 0 then
    begin
      ANewImageHeight := FPredefinedItemSize.cy -
        2 * VerticalImageIndent;
      if AImageSize.cy > ANewImageHeight then
      begin
        AImageSize.cx := MulDiv(AImageSize.cx, ANewImageHeight, AImageSize.cy);
        AImageSize.cy := ANewImageHeight;
      end;
    end;
  end;

  procedure InscribeImage(var AImageSize: TSize);
  var
    APlaceSize: TSize;
    AFactor: Double;
  begin
    if (Bounds.Right - Bounds.Left > 0) and
      (Bounds.Bottom - Bounds.Top > 0) then
    begin
      APlaceSize := GetImagePlace;
      if (AImageSize.cx = 0) or (AImageSize.cy = 0) then
        AImageSize := cxNullSize
      else
      begin
        if (APlaceSize.cx < AImageSize.cx) or (APlaceSize.cy < AImageSize.cy) then
        begin
          if APlaceSize.cx / AImageSize.cx < APlaceSize.cy / AImageSize.cy then
            AFactor := APlaceSize.cx / AImageSize.cx
          else
            AFactor := APlaceSize.cy / AImageSize.cy;
          AImageSize.cx := Round(AImageSize.cx * AFactor);
          AImageSize.cy := Round(AImageSize.cy * AFactor);
        end;
      end;
    end
    else
      FitToItemHeight(AImageSize);
  end;

begin
  Result := GetUnsizedImageSize;
  InscribeImage(Result);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetUnsizedImageSize: TSize;
begin
  Result := Owner.Group.Options.ItemImageSize.Size;
  if not CanUseSize(Result) and IsImageVisible then
    Result := FGroupItem.GetImageSize;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetCaptionBounds: TRect;
begin
  Result.Left := GetTextLeft;
  Result.Top := GetTextTop;
  Result.Right := GetTextRight;
  Result.Bottom := Result.Top + GetCaptionHeight;
  if not (IsImageVisible or IsDescriptionVisible) then
    Result := cxRectCenter(Bounds, cxSize(Result.Right - Result.Left,
      Result.Bottom - Result.Top));
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescriptionBounds: TRect;
var
  ATempRect: TRect;
begin
  Result.Left := GetTextLeft;
  Result.Top := GetTextTop + GetCaptionHeight +
    GetSpaceBetweenItemCaptionAndDescription;
  Result.Right := GetTextRight;
  ATempRect := cxNullRect;
  Result.Bottom := Result.Top + GetDescriptionHeight(ATempRect);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetImageBounds: TRect;
begin
  if not IsCaptionVisible then
    Result := cxRectCenter(Bounds, GetImageSize)
  else
  begin
    case Options.GetItemImagePosition of 
      gipLeft:
        begin
          Result.Left := Bounds.Left + HorizontalImageIndent;
          Result.Top := Bounds.Top + VerticalImageIndent;
          Result.Right := Result.Left + GetImageSize.cx;
          Result.Bottom := Bounds.Bottom - VerticalImageIndent;
        end;
      gipTop:
        begin
          Result.Left := Bounds.Left + HorizontalImageIndent;
          Result.Top := Bounds.Top + VerticalImageIndent;
          Result.Right := Bounds.Right - HorizontalImageIndent;
          Result.Bottom := Result.Top + GetImageSize.cy;
        end;
      gipRight:
        begin
          Result.Right := Bounds.Right - HorizontalImageIndent;
          Result.Top := Bounds.Top + VerticalImageIndent;
          Result.Left := Result.Right - GetImageSize.cx;
          Result.Bottom := Bounds.Bottom - VerticalImageIndent;
        end;
    else
      Result.Bottom := Bounds.Bottom - VerticalImageIndent;
      Result.Left := Bounds.Left + HorizontalImageIndent;
      Result.Right := Bounds.Right - HorizontalImageIndent;
      Result.Top := Result.Bottom - GetImageSize.cy;
    end;
    Result := cxRectCenter(Result, GetImageSize);
  end;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetTextLeft: Integer;
begin
  Result := Bounds.Left;
  if Options.GetItemImagePosition = gipLeft then
    Result := Result +
      IfThen(CanUseSize(GetImageSize), GetImageSize.cx +
      Options.GetSpaceBetweenItemImageAndText +
      dxRibbonGalleryGroupItemIndent) +
      dxRibbonGalleryGroupItemIndent
  else
    Result := Result + dxRibbonGalleryGroupItemIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetTextRight: Integer;
begin
  Result := Bounds.Right;
  if Options.GetItemImagePosition = gipRight then
    Result := Result -
      IfThen(CanUseSize(GetImageSize), GetImageSize.cx +
      Options.GetSpaceBetweenItemImageAndText +
      dxRibbonGalleryGroupItemIndent) -
      dxRibbonGalleryGroupItemIndent
  else
    Result := Result - dxRibbonGalleryGroupItemIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetTextTop: Integer;
begin
  Result := Bounds.Top;
  if Options.GetItemImagePosition = gipTop then 
    Result := Result +
      IfThen(CanUseSize(GetImageSize), GetImageSize.cy +
      Options.GetSpaceBetweenItemImageAndText +
      dxRibbonGalleryGroupItemIndent) +
      dxRibbonGalleryGroupItemIndent
  else
    Result := Result + dxRibbonGalleryGroupItemIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsBoldCaption: Boolean;
begin
  Result := not IsInplaceGallery and
    (Owner.Group.Options.ItemTextKind in [itkCaptionAndDescription]);
end;

procedure TdxRibbonGalleryGroupItemViewInfo.ResetCachedValues;
begin
  FCaptionVisibilityState := gbsIndefinite;
  FDescriptionVisibilityState := gbsIndefinite;
  FChanged := True;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.SetPredefinedItemSize(
  const AValue: TSize);
begin
  FPredefinedItemSize := AValue;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.CheckCaptionFontStyle(AFont: TFont);
begin
  if IsBoldCaption then
    AFont.Style := AFont.Style + [fsBold];
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescriptionLenght: Integer;
begin
  Result := cxTextWidth(GetFont, GroupItem.Description);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDescriptionRect: TRect;
begin
  if not IsInplaceGallery then
    Result := TdxRibbonOnSubMenuGalleryControlViewInfo(Owner.Owner).GetGroupItemDescriptionRect(
      GroupItem.Group.Index, GroupItem.Index)
  else
    Result := cxNullRect;
  if cxRectIsNull(Result) then
  begin
    GetGalleryItemControl.Canvas.SaveState;
    try
      GetGalleryItemControl.Canvas.Font := Font;
      Result := cxGetTextRect(GetGalleryItemControl.Canvas.Handle, Description,
        FDescriptionRowCount);
    finally
      GetGalleryItemControl.Canvas.RestoreState;
    end;
    if not IsInplaceGallery then
      TdxRibbonOnSubMenuGalleryControlViewInfo(Owner.Owner).SetGroupItemDescriptionRect(
      GroupItem.Group.Index, GroupItem.Index, Result);
  end;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetDowned: Boolean;
begin
  Result := IsThisGroupItem(Owner.Owner.DownedGroupItem);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetHotGroupItem: TdxRibbonGalleryGroupItem;
begin
  Result := Owner.Owner.HotGroupItem;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetHorizontalImageIndent: Integer;
begin
  if Options.RemoveHorizontalItemPadding then
    Result := 0
  else
    Result := dxRibbonGalleryGroupItemIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetImagePlace: TSize;
var
  AWidth, AHeight: Integer;
  ATempRect: TRect;
begin
  ATempRect := cxNullRect;
  AWidth := Bounds.Right - Bounds.Left;
  AHeight := Bounds.Bottom - Bounds.Top;
  case Options.GetItemImagePosition of
    gipTop, gipBottom:
      begin
        Result.cx := AWidth - 2 * HorizontalImageIndent;
        Result.cy := AHeight - ItemHeightWithoutImage(ATempRect);
      end;
  else
    Result.cx := AWidth - ItemWidthWithoutImage(ATempRect);
    Result.cy := AHeight - 2 * VerticalImageIndent;
  end;
  Result.cx := Max(0, Result.cx);
  Result.cy := Max(0, Result.cy);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetIsItemPullHighlighting: Boolean;
begin
  Result := Owner.Group.Options.ItemPullHighlighting.Active and
    not Owner.Owner.IsInRibbon;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetItemSize: TSize;
var
  AWidth, AHeight: Integer;
  AImageSize: TSize;
  ADescriptionRect: TRect;
begin
  ADescriptionRect := cxNullRect;
  AImageSize := GetImageSize;
  case Options.GetItemImagePosition of
    gipTop, gipBottom:
      begin
        AWidth := Max(Max(GetCaptionWidth, GetDescriptionWidth(ADescriptionRect)),
          AImageSize.cx) + 2 * HorizontalImageIndent;
        AHeight := AImageSize.cy + ItemHeightWithoutImage(ADescriptionRect);
      end;
  else
    AWidth := AImageSize.cx + ItemWidthWithoutImage(ADescriptionRect);
    AHeight := Max(AImageSize.cy, GetCaptionHeight +
      GetDescriptionHeight(ADescriptionRect) +
      GetSpaceBetweenItemCaptionAndDescription) + 2 * VerticalImageIndent;
  end;
  Result.cx := AWidth;
  Result.cy := AHeight;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetOptions: TdxRibbonGalleryGroupOptions;
begin
  Result := Owner.Group.Options;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetPainter: TdxBarSkinnedPainter;
begin
  Result := TdxBarSkinnedPainter(Owner.Owner.Control.Painter);
end;

function TdxRibbonGalleryGroupItemViewInfo.GetRectConsiderBounds(
  const ARect: TRect): TRect;
begin
  if cxRectContain(Bounds, ARect) then
    Result := ARect
  else
    Result := cxNullRect;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetSelected: Boolean;
begin
  Result := GroupItem.Selected;
end;

function TdxRibbonGalleryGroupItemViewInfo.GetVerticalImageIndent: Integer;
begin
  if Options.RemoveVerticalItemPadding then
    Result := 0
  else
    Result := dxRibbonGalleryGroupItemIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsCaptionVisible: Boolean;
begin
  if FCaptionVisibilityState = gbsIndefinite then
  begin
    Result := (not IsInplaceGallery or not IsImageVisible) and
      (Owner.Group.Options.ItemTextKind in [itkCaption, itkCaptionAndDescription]) and
      (Caption <> '') and (not IsMergeItemsImages or not IsImageVisible);
    if Result then
      FCaptionVisibilityState := gbsTrue
    else
      FCaptionVisibilityState := gbsFalse;
  end
  else
    Result := FCaptionVisibilityState = gbsTrue;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsDescriptionVisible: Boolean;
begin
  if FDescriptionVisibilityState = gbsIndefinite then
  begin
    Result := not IsInplaceGallery and
      (Owner.Group.Options.ItemTextKind in [itkCaptionAndDescription]) and
      (Description <> '') and (Caption <> '') and not IsMergeItemsImages;
    if Result then
      FDescriptionVisibilityState := gbsTrue
    else
      FDescriptionVisibilityState := gbsFalse;
  end
  else
    Result := FDescriptionVisibilityState = gbsTrue;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsImageVisible: Boolean;
begin
  Result := GroupItem.IsImageAssigned;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsInplaceGallery: Boolean;
begin
  Result := Owner.Owner.IsInRibbon;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsMergeItemsImages: Boolean;
begin
  Result := (Options.RemoveHorizontalItemPadding or
    Options.RemoveVerticalItemPadding) and IsImageVisible;
end;

function TdxRibbonGalleryGroupItemViewInfo.IsThisGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem): Boolean;
begin
  Result := (AGroupItem = GroupItem) and (AGroupItem <> nil);
end;

function TdxRibbonGalleryGroupItemViewInfo.ItemHeightWithoutImage(
  var ADescriptionRect: TRect): Integer;
begin
  Result := GetCaptionHeight + GetDescriptionHeight(ADescriptionRect) +
    GetSpaceBetweenItemCaptionAndDescription + GetSpaceBetweenItemImageAndText +
    2 * VerticalImageIndent;
end;

function TdxRibbonGalleryGroupItemViewInfo.ItemWidthWithoutImage(
  var ADescriptionRect: TRect): Integer;
begin
  Result := Max(GetCaptionWidth, GetDescriptionWidth(ADescriptionRect)) +
    GetSpaceBetweenItemImageAndText + 2 * HorizontalImageIndent;
end;

procedure TdxRibbonGalleryGroupItemViewInfo.ValidateDescriptionStrings(
  ACanvas: TcxCanvas);
begin
  if FChanged then
  begin
    FDescriptionLines.Clear;
    cxGetTextLines(Description, ACanvas, FDescriptionBounds, FDescriptionLines);
  end;
end;

{ TdxRibbonGalleryGroupViewInfo }

constructor TdxRibbonGalleryGroupViewInfo.Create(
  AOwner: TdxRibbonGalleryControlViewInfo;
  AGroup: TdxRibbonGalleryGroup; const AItemSize: TSize);
begin
  inherited Create;
  FGroup := AGroup;
  FOwner := AOwner;
  FHeader := TdxRibbonGalleryGroupHeaderViewInfo.Create(Self);
  FItems := TcxObjectList.Create;

  if CanUseSize(AItemSize) then
    FItemSize := AItemSize
  else
    if CanUseSize(Owner.GlobalItemSize) then
      FItemSize := Owner.GlobalItemSize
    else
      if CanUseSize(Group.Options.ItemSize.Size) then
        FItemSize := Group.Options.ItemSize.Size
      else
        FItemSize := GetItemSize;
end;

destructor TdxRibbonGalleryGroupViewInfo.Destroy;
begin
  FreeAndNil(FItems);
  FreeandNil(FHeader);
  inherited Destroy;
end;

procedure TdxRibbonGalleryGroupViewInfo.Calculate(AGroupTop,
  AGroupBottom: Integer; const AControlClientRect: TRect);
var
  ARowIndex, ARowTop, ARowHeight, AColumnCount, ARowCount,
    AItemIndex, AColumnIndex, AColumnLeft, AGroupWidth: Integer;
begin
  FBounds := Rect(AControlClientRect.Left, AGroupTop, AControlClientRect.Right,
    AGroupBottom);
  Header.Calculate(GetHeaderBounds(Bounds));

  ClearItems;
  ARowIndex := 0;
  ARowHeight := GetRowHeight;
  AGroupWidth := GetGroupWidth;
  AColumnCount := GetColumnCount(AGroupWidth);
  ARowCount := GetRowCount(AGroupWidth);
  while ARowIndex <= ARowCount - 1 do
  begin
    ARowTop := GetRowTop(ARowIndex, AGroupTop, AGroupWidth);
    if AreLinesIntersectedStrictly(ARowTop, ARowTop + ARowHeight,
      AControlClientRect.Top, AControlClientRect.Bottom) then
    begin
      AColumnIndex := 0;
      for AItemIndex := GetFirstItemInGroupRow(ARowIndex, AColumnCount) to
        GetLastItemInGroupRow(ARowIndex, AColumnCount) do
      begin
        AColumnLeft := GetColumnLeft(AColumnIndex, Bounds.Left);
        CreateGroupItem(AItemIndex, Rect(AColumnLeft, ARowTop,
          AColumnLeft + FItemSize.cx, ARowTop + FItemSize.cy));
        Inc(AColumnIndex);
      end;
    end;
    Inc(ARowIndex);
  end;
end;

function TdxRibbonGalleryGroupViewInfo.GetHeight(AWidth: Integer): Integer;
var
  ARowCount: Integer;
begin
  ARowCount := GetRowCount(AWidth);
  Result := Header.GetHeight(AWidth, True) + ARowCount * GetRowHeight -
    IfThen(ARowCount > 0, GetSpaceBetweenItems(False));
end;

procedure TdxRibbonGalleryGroupViewInfo.Paint(ACanvas: TcxCanvas);
var
  I: Integer;
begin
  Header.Paint(ACanvas);
  for I := 0 to ItemCount - 1 do
    Items[I].Paint(ACanvas);
end;

function TdxRibbonGalleryGroupViewInfo.CalculateItemSize(
  const APredefinedItemSize: TSize): TSize;
var
  AItem: TdxRibbonGalleryGroupItemViewInfo;
  AItemSize: TSize;
  I: Integer;
  ASetItemSize: Boolean;
begin
  ASetItemSize := CanUseSize(APredefinedItemSize);
  Result := cxNullSize;
  for I := 0 to Group.Items.Count - 1 do
  begin
    AItem := TdxRibbonGalleryGroupItemViewInfo.Create(Self, Group.Items[I]);
    try
      if ASetItemSize then
        AItem.SetPredefinedItemSize(APredefinedItemSize);
      AItemSize := AItem.ItemSize;
    finally
      AItem.Free;
    end;
    Result.cx := Max(Result.cx, AItemSize.cx);
    Result.cy := Max(Result.cy, AItemSize.cy);
  end;
end;

procedure TdxRibbonGalleryGroupViewInfo.ClearItems;
begin
  FItems.Clear;
end;

procedure TdxRibbonGalleryGroupViewInfo.CreateGroupItem(AItemIndex: Integer;
  const ABounds: TRect);
var
  AGroupItem: TdxRibbonGalleryGroupItem;
  AGroupItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
begin
  AGroupItem := FGroup.Items.Items[AItemIndex];
  AGroupItemViewInfo := TdxRibbonGalleryGroupItemViewInfo.Create(Self,
    AGroupItem);
  AGroupItemViewInfo.Calculate(ABounds);
  FItems.Add(AGroupItemViewInfo);
end;

function TdxRibbonGalleryGroupViewInfo.GetColumnLeft(
  AColumnIndex: Integer; AGroupLeft: Integer): Integer;
begin
  Result := AGroupLeft + Owner.GetLeftLayoutIndent +
    (FItemSize.cx + GetSpaceBetweenItems(True)) * AColumnIndex;
end;

function TdxRibbonGalleryGroupViewInfo.GetColumnCount(AWidth: Integer): Integer;
var
  ADenominator: Integer;
begin
  ADenominator := FItemSize.cx + GetSpaceBetweenItems(True);
  if ADenominator <> 0 then
    Result := (AWidth - (Owner.GetLeftLayoutIndent + Owner.GetRightLayoutIndent) +
      GetSpaceBetweenItems(True)) div ADenominator
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupViewInfo.GetColumnCountInRow(
  ARow: Integer; AGroupWidth: Integer): Integer;
var
  AGroupColumnCount: Integer;
begin
  AGroupColumnCount := GetColumnCount(AGroupWidth);
  if AGroupColumnCount <> 0 then
  begin
    if (ARow + 1) * AGroupColumnCount > Group.Items.Count then
      Result := Group.Items.Count mod AGroupColumnCount
    else
      Result := AGroupColumnCount;
  end
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupViewInfo.GetColumnWidth: Integer;
begin
  Result := FItemSize.cx + GetSpaceBetweenItems(True);
end;

function TdxRibbonGalleryGroupViewInfo.GetGroupWidth: Integer;
begin
  Result := FBounds.Right - FBounds.Left;
end;

function TdxRibbonGalleryGroupViewInfo.GetHeaderBounds(AGroupBounds: TRect): TRect;
begin
  Result := AGroupBounds;
  Result.Bottom := Result.Top + Header.GetHeight(
    AGroupBounds.Right - AGroupBounds.Left, False);
end;

function TdxRibbonGalleryGroupViewInfo.GetItemColumn(
  AIndex: Integer; AGroupWidth: Integer): Integer;
var
  AColumnCount: Integer;
begin
  AColumnCount := GetColumnCount(AGroupWidth);
  if AColumnCount <> 0 then
    Result := AIndex mod AColumnCount
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupViewInfo.GetItemIndex(ARow,
  AColumn: Integer; AGroupWidth: Integer): Integer;
begin
  Result := ARow * GetColumnCount(AGroupWidth) + AColumn;
end;

function TdxRibbonGalleryGroupViewInfo.GetItemRow(
  AGroupItemIndex: Integer; AGroupWidth: Integer): Integer;
var
  AColumnCount: Integer;
begin
  AColumnCount := GetColumnCount(AGroupWidth);
  if AColumnCount <> 0 then
    Result := AGroupItemIndex div AColumnCount
  else
    Result := 0;
end;

function TdxRibbonGalleryGroupViewInfo.GetLastItemInGroupRow(ARowIndex,
  AColumnCount: Integer): Integer;
var
  AGroupItemCount: Integer;
begin
  Result := GetFirstItemInGroupRow(ARowIndex, AColumnCount) + AColumnCount - 1;
  AGroupItemCount := FGroup.Items.Count;
  if Result > AGroupItemCount - 1 then
    Result := AGroupItemCount - 1;
end;

function TdxRibbonGalleryGroupViewInfo.GetRowCount(
  AGroupWidth: Integer): Integer;

  function CalcRowCount(AColumnCount: Integer): Integer;
  var
    AGroupItemCount: Integer;
  begin
    AGroupItemCount := FGroup.Items.Count;
    if AColumnCount <> 0 then
      Result := Ceil(AGroupItemCount / AColumnCount)
    else
      Result := 0;
  end;

begin
  Result := CalcRowCount(GetColumnCount(AGroupWidth));
end;

function TdxRibbonGalleryGroupViewInfo.GetRowHeight: Integer;
begin
  Result := FItemSize.cy + GetSpaceBetweenItems(False);
end;

function TdxRibbonGalleryGroupViewInfo.GetRowTop(ARowIndex: Integer;
  AGroupTop: Integer; AGroupWidth: Integer): Integer;
begin
  Result := AGroupTop + Header.GetHeight(AGroupWidth, True) +
    GetRowHeight * ARowIndex;
end;

function TdxRibbonGalleryGroupViewInfo.GetSpaceBetweenItems(
  IsAflat: Boolean): Integer;
begin
  if (Options.RemoveHorizontalItemPadding and IsAflat) or
    (Options.RemoveVerticalItemPadding and not IsAflat) then
    Result := 0
  else
    if Owner.IsInRibbon then
    begin
      if IsAflat then
        Result := Owner.GalleryItem.GalleryOptions.SpaceBetweenItemsHorizontally
      else
        Result := Owner.GalleryItem.GalleryOptions.SpaceBetweenItemsVertically;
    end
    else
    begin
      if IsAflat then
        Result := Options.SpaceBetweenItemsHorizontally
      else
        Result := Options.SpaceBetweenItemsVertically;
    end;
end;

procedure TdxRibbonGalleryGroupViewInfo.RepaintChainOfItems(
  AnItemIndex: Integer; IsHotTrack: Boolean; ACanvas: TcxCanvas;
  APart: TdxRibbonGalleryGroupRepaintPart = ggrpAll; AnItemIndex2: Integer = 0);

  function GetGroupItemViewInfoIndex(AGroupItemIndex: Integer): Integer;
  var
    I: Integer;
    AFound, IsIndexGreater: Boolean;
  begin
    Result := -1;
    AFound := False;
    IsIndexGreater := False;
    I := 0;
    while (I < ItemCount) and not AFound do
    begin
      if Items[I].GroupItem.Index = AGroupItemIndex then
      begin
        Result := I;
        AFound := True;
      end;
      IsIndexGreater := Items[I].GroupItem.Index < AGroupItemIndex;
      Inc(I);
    end;
    if Result = -1 then
      if IsIndexGreater then
        Result := ItemCount - 1
      else
        Result := 0;
  end;

var
  I, AFinish: Integer;
begin
  case APart of
    ggrpBefore:
      begin
        I := 0;
        AFinish := AnItemIndex;
      end;
    ggrpAfter:
      begin
        I := AnItemIndex;
        AFinish := ItemCount - 1;
      end;
    ggrpBetween:
      begin
        I := AnItemIndex;
        AFinish := AnItemIndex2;
      end;
  else
    I := 0;
    AFinish := ItemCount - 1;
  end;
  if APart in [ggrpAfter, ggrpBetween] then
    I := GetGroupItemViewInfoIndex(I);
  if APart in [ggrpBefore, ggrpBetween] then
    AFinish := GetGroupItemViewInfoIndex(AFinish);
  if AFinish < FItems.Count then
  while I <= AFinish do
  begin
    Items[I].Paint(ACanvas);
    Inc(I);
  end;
end;

procedure TdxRibbonGalleryGroupViewInfo.SetBounds(const ABounds: TRect);
begin
  FBounds := ABounds;
end;

function TdxRibbonGalleryGroupViewInfo.GetFirstItemInGroupRow(ARowIndex,
  AColumnCount: Integer): Integer;
begin
  Result := ARowIndex * AColumnCount;
end;

function TdxRibbonGalleryGroupViewInfo.GetFont: TFont;
begin
  Result := Owner.Control.Parent.Font;
end;

function TdxRibbonGalleryGroupViewInfo.GetItem(
  Index: Integer): TdxRibbonGalleryGroupItemViewInfo;
begin
  Result := TdxRibbonGalleryGroupItemViewInfo(FItems[Index]);
end;

function TdxRibbonGalleryGroupViewInfo.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

function TdxRibbonGalleryGroupViewInfo.GetItemSize: TSize;
var
  AStoredItemSize: TSize;
begin
  AStoredItemSize := Owner.GetGroupItemStoredSize(FGroup.Index);
  if CanUseSize(AStoredItemSize) then
    Result := AStoredItemSize
  else
  begin
    Result := CalculateItemSize(cxNullSize);
    Owner.SetGroupItemStoredSize(Result, FGroup.Index);
  end;
end;

function TdxRibbonGalleryGroupViewInfo.GetOptions: TdxRibbonGalleryGroupOptions;
begin
  Result := Group.Options;
end;

function TdxRibbonGalleryGroupViewInfo.GetPainter: TdxBarSkinnedPainter;
begin
  Result := TdxBarSkinnedPainter(Owner.Control.Painter);
end;

{ TdxRibbonGalleryControlViewInfo }

constructor TdxRibbonGalleryControlViewInfo.Create(
  AControl: TdxBarItemControl);
begin
  inherited Create(AControl);
  FGroups := TcxObjectList.Create;
  FDownedGroupItem := nil;
  FHotGroupItem := nil;
  GalleryChanged;
end;

destructor TdxRibbonGalleryControlViewInfo.Destroy;
begin
  FreeAndNil(FGroups);
  inherited Destroy;
end;

procedure TdxRibbonGalleryControlViewInfo.Calculate(ALayoutOffset: Integer;
  AScrollCode: TScrollCode);
begin
  CalculateGlobalItemSize;
end;

procedure TdxRibbonGalleryControlViewInfo.Paint;

  function GetInRibbonGalleryState: Integer;
  begin
    Result := TdxBarSkinnedPainterAccess(Painter).GetPartState(
      Control.DrawParams, icpControl);
  end;

var
  I: Integer;
begin
  DrawBackground(GetControlBounds);
  Control.Canvas.SaveClipRegion;
  try
    Control.Canvas.SetClipRegion(TcxRegion.Create(GalleryBounds), roIntersect);
    for I := 0 to GroupCount - 1 do
      Groups[I].Paint(Control.Canvas);
  finally
    Control.Canvas.RestoreClipRegion;
  end;
end;

procedure TdxRibbonGalleryControlViewInfo.DisplayGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem);
begin
// do nothing
end;

procedure TdxRibbonGalleryControlViewInfo.DrawSelectedGroupItem(
  ASelectedGroupItem, AOldSelectedGroupItem: TdxRibbonGalleryGroupItem);
begin
  Control.Canvas.SaveState;
  try
    DrawGroupItem(AOldSelectedGroupItem);
    DrawGroupItem(ASelectedGroupItem);
  finally
    Control.Canvas.RestoreState;
  end;
end;

procedure TdxRibbonGalleryControlViewInfo.GalleryChanged;
var
  AGroupCount: Integer;
  I: Integer;
begin
  AGroupCount := Control.GetGroups.Count;
  SetLength(FGroupItemStoredSizes, AGroupCount);
  for I := 0 to AGroupCount - 1 do
    FGroupItemStoredSizes[I] := cxNullSize;
end;

function TdxRibbonGalleryControlViewInfo.GetAbsoluteGroupTop(
  AGroupIndex: Integer; AWidth: Integer): Integer;
var
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse: Boolean;
  I: Integer;
begin
  Result := 0;
  for I := 0 to AGroupIndex - 1 do
    if GalleryItem.IsGroupVisible(I) then
    begin
      AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self, I,
        ADestroyAfterUse);
      try
        Result := Result + AGroupViewInfo.GetHeight(AWidth) +
          IfThen(AWidth > 0, GalleryOptions.SpaceBetweenGroups);
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;
    end;
end;

function TdxRibbonGalleryControlViewInfo.GetControlBounds: TRect;
begin
  Result := Bounds;
end;

function TdxRibbonGalleryControlViewInfo.GetGalleryBounds: TRect;
var
  AMargins: TRect;
begin
  Result := GetControlBounds;
  AMargins := GetGalleryMargins;
  Result := cxRectInflate(Result, -AMargins.Left, -AMargins.Top,
    -(AMargins.Right + GetScrollBarWidth), -AMargins.Bottom);
end;

function TdxRibbonGalleryControlViewInfo.GetGalleryHeight(
  AWidth: Integer): Integer;
begin
  Result := 1;
end;

function TdxRibbonGalleryControlViewInfo.GetGroupItemCount(
  ALastGroupIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ALastGroupIndex do
    if GalleryItem.IsGroupVisible(I) then
      Result := Result + Control.GetGroups[I].Items.Count;
end;

function TdxRibbonGalleryControlViewInfo.GetHeight(AWidth: Integer): Integer;
begin
  Result := 0;
end;

function TdxRibbonGalleryControlViewInfo.GetMaxGroupItemSize: TSize;
var
  I: Integer;
  AGroupItemSize: TSize;
begin
  if CanUseSize(GlobalItemSize) then
    Result := GlobalItemSize
  else
  begin
    Result := cxNullSize;
    for I := 0 to Control.GetGroups.Count - 1 do
    begin
      AGroupItemSize := GetGroupItemSize(I);
      Result.cx := Max(Result.cx, AGroupItemSize.cx);
      Result.cy := Max(Result.cy, AGroupItemSize.cy);
    end;
  end;
end;

function TdxRibbonGalleryControlViewInfo.GetGroupItem(
  X, Y: Integer): TdxRibbonGalleryGroupItem;
var
  I, J: Integer;
  AGroupItemFound: Boolean;
begin
  Result := nil;
  AGroupItemFound := False;
  I := 0;
  while (I < GroupCount) and not AGroupItemFound do
  begin
    if cxRectPtIn(Groups[I].Bounds, X, Y) then
    begin
      J := 0;
      while (J < Groups[I].ItemCount) and not AGroupItemFound do
      begin
        if cxRectPtIn(Groups[I].Items[J].Bounds, X, Y) then
        begin
          Result := Groups[I].Items[J].GroupItem;
          AGroupItemFound := True;
        end;
        Inc(J);
      end;
    end;
    Inc(I);
  end;
end;

function TdxRibbonGalleryControlViewInfo.GetGroupItemStoredSize(
  AGroupIndex: Integer): TSize;
begin
  if AGroupIndex < Length(FGroupItemStoredSizes) then
    Result := FGroupItemStoredSizes[AGroupIndex]
  else
    Result := cxNullSize;
end;

function TdxRibbonGalleryControlViewInfo.GetGroupItemViewInfo(
  AGroupItem: TdxRibbonGalleryGroupItem): TdxRibbonGalleryGroupItemViewInfo;

  function GetGroupViewInfo(AGroup: TdxRibbonGalleryGroup): TdxRibbonGalleryGroupViewInfo;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to GroupCount - 1 do
      if Groups[I].Group = AGroup then
      begin
        Result := Groups[I];
        Break;
      end;
  end;

var
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  I: Integer;
begin
  Result := nil;
  if AGroupItem = nil then Exit;
  AGroupViewInfo := GetGroupViewInfo(GalleryItem.GalleryGroups[AGroupItem.Group.Index]);
  if AGroupViewInfo <> nil then
    for I := 0 to AGroupViewInfo.ItemCount - 1 do
      if AGroupViewInfo.Items[I].GroupItem = AGroupItem then
      begin
        Result := AGroupViewInfo.Items[I];
        Break;
      end;
end;

function TdxRibbonGalleryControlViewInfo.GetLeftLayoutIndent: Integer;
begin
  Result := Max(1, GalleryOptions.SpaceBetweenItemsAndBorder) - 1; 
end;

function TdxRibbonGalleryControlViewInfo.GetNextButtonEnabled: Boolean;
var
  ALastGroupIndex: Integer;
  ALastGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
begin
  if GroupCount <> 0 then
  begin
    ALastGroupIndex := GetVisibleNotEmptyGroupIndex(
      Control.GetGroups.Count - 1, False);
    ALastGroupViewInfo := Groups[GroupCount - 1];
    Result := (ALastGroupIndex <> ALastGroupViewInfo.Group.Index) or
      (Control.GetGroups[ALastGroupIndex].Items.Count - 1 <>
      ALastGroupViewInfo.Items[ALastGroupViewInfo.ItemCount - 1].GroupItem.Index) or
      not cxRectContain(GalleryBounds,
      ALastGroupViewInfo.Items[ALastGroupViewInfo.ItemCount - 1].Bounds);
  end
  else
    Result := False;
end;

function TdxRibbonGalleryControlViewInfo.GetPreviousButtonEnabled: Boolean;
var
  AFirstGroupIndex: Integer;
begin
  if GroupCount <> 0 then
  begin
    AFirstGroupIndex := GetVisibleNotEmptyGroupIndex(0, True);
    Result := (Groups[0].Group.Index <> AFirstGroupIndex) or
      (Groups[0].Items[0].GroupItem.Index <> 0) or
      not cxRectContain(GalleryBounds, Groups[0].Items[0].Bounds);
  end
  else
    Result := False;
end;

function TdxRibbonGalleryControlViewInfo.GetRightLayoutIndent: Integer; //TODO rename
begin
  Result := GalleryOptions.SpaceBetweenItemsAndBorder;
end;

function TdxRibbonGalleryControlViewInfo.GetVisibleGroupIndex(
  AStartGroupIndex: Integer; AIncreaseIndex: Boolean): Integer;
begin
  Result := AStartGroupIndex;
  if AIncreaseIndex then
  begin
    while (Result < Control.GetGroups.Count) and
     (not GalleryItem.IsGroupVisible(Result)) do
      Inc(Result);
    if Result >= Control.GetGroups.Count then
      Result := -1;
  end
  else
  begin
    while (Result >= 0) and (not GalleryItem.IsGroupVisible(Result)) do
      Dec(Result);
  end;
end;

function TdxRibbonGalleryControlViewInfo.GetVisibleNotEmptyGroupIndex(
  AStartGroupIndex: Integer; AIncreaseIndex: Boolean): Integer;
var
  AExit: Boolean;
begin
  AExit := False;
  repeat
    Result := GetVisibleGroupIndex(AStartGroupIndex, AIncreaseIndex);
    if Result <> -1 then
    begin
      if Control.GetGroups[Result].Items.Count > 0 then
        AExit := True
      else
      begin
        AStartGroupIndex := Result;
        if AIncreaseIndex then
          Inc(AStartGroupIndex)
        else
          Dec(AStartGroupIndex);
        if (AStartGroupIndex < 0) or
          (AStartGroupIndex > Control.GetGroups.Count - 1) then
        begin
          Result := -1;
          AExit := True;
        end;
      end;
    end
    else
      AExit := True;
  until AExit;
end;

function TdxRibbonGalleryControlViewInfo.IsGroupHeaderVisible: Boolean;
begin
  Result := not IsInRibbon;
end;

function TdxRibbonGalleryControlViewInfo.IsGroupItemAtThisPlace(
  X, Y: Integer): Boolean;
begin
  Result := GetGroupItem(X, Y) <> nil;
end;

function TdxRibbonGalleryControlViewInfo.IsInRibbon: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonGalleryControlViewInfo.RemoveGroupItem(
  AItem: TdxRibbonGalleryGroupItem);
begin
  if HotGroupItem = AItem then
    FHotGroupItem := nil;
  if DownedGroupItem = AItem then
    FDownedGroupItem := nil;
end;

procedure TdxRibbonGalleryControlViewInfo.Changed;
begin
  FGroups.Clear;
end;

procedure TdxRibbonGalleryControlViewInfo.SetDownedGroupItem(
  const Value: TdxRibbonGalleryGroupItem);
var
  AGroupItem: TdxRibbonGalleryGroupItem;
begin
  if FDownedGroupItem <> Value then
  begin
    AGroupItem := FDownedGroupItem;
    FDownedGroupItem := Value;
    if Value = nil then
      DrawGroupItem(AGroupItem)
    else
    begin
      DrawGroupItem(Value);
      if HotGroupItem <> Value then
        Control.Controller.SetHotGroupItem(Value);
    end;
  end;
end;

procedure TdxRibbonGalleryControlViewInfo.SetGroupItemStoredSize(const Value: TSize;
  AGroupIndex: Integer);
begin
  if AGroupIndex < Length(FGroupItemStoredSizes) then
    FGroupItemStoredSizes[AGroupIndex] := Value;
end;

procedure TdxRibbonGalleryControlViewInfo.SetHotGroupItem(
  Value: TdxRibbonGalleryGroupItem);

  function HasGroupItemPullHighlighting(AGroupItem: TdxRibbonGalleryGroupItem): Boolean;
  begin
    Result := (AGroupItem <> nil) and
      AGroupItem.Group.Options.ItemPullHighlighting.Active;
  end;

  procedure DoSetHotGroupItem(Value: TdxRibbonGalleryGroupItem);
  var
    AOldHotGroupItem: TdxRibbonGalleryGroupItem;
  begin
    Control.Canvas.SaveState;
    try
      AOldHotGroupItem := FHotGroupItem;
      FHotGroupItem := Value;
      DisplayGroupItem(FHotGroupItem);

      if Control.ViewInfo.IsInRibbon then
      begin
        DrawGroupItem(AOldHotGroupItem);
        DrawGroupItem(FHotGroupItem);
      end
      else
        if HasGroupItemPullHighlighting(AOldHotGroupItem) and
          HasGroupItemPullHighlighting(FHotGroupItem) then
        begin
          if GetItemPullHighlightingIdentifier(AOldHotGroupItem) =
            GetItemPullHighlightingIdentifier(FHotGroupItem) then
            RepaintChainOfGroups(FHotGroupItem, AOldHotGroupItem)
          else
          begin
            RepaintChainOfGroups(FHotGroupItem, nil);
            RepaintChainOfGroups(nil, AOldHotGroupItem);
          end;
        end
        else
        begin
          if HasGroupItemPullHighlighting(FHotGroupItem) then
            RepaintChainOfGroups(FHotGroupItem, nil)
          else
            DrawGroupItem(FHotGroupItem);
          if HasGroupItemPullHighlighting(AOldHotGroupItem) then
            RepaintChainOfGroups(nil, AOldHotGroupItem)
          else
            DrawGroupItem(AOldHotGroupItem);
        end;

      GalleryItem.DoHotTrackedItemChanged(AOldHotGroupItem, FHotGroupItem);
    finally
      Control.Canvas.RestoreState;
    end;
  end;

var
  ADestroyAfterUse: Boolean;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
begin
  if Value <> nil then
  begin
    AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self,
      Value.Group.Index, ADestroyAfterUse);
    try
      if AGroupViewInfo <> nil then
        DoSetHotGroupItem(Value);
    finally
      if ADestroyAfterUse then
        AGroupViewInfo.Free;
    end;
  end
  else
    DoSetHotGroupItem(Value);
end;

procedure TdxRibbonGalleryControlViewInfo.ShowGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem);
begin
  //do nothing
end;

function TdxRibbonGalleryControlViewInfo.GetGroupCount: Integer;
begin
  Result := FGroups.Count;
end;

function TdxRibbonGalleryControlViewInfo.GetGroups(
  Index: Integer): TdxRibbonGalleryGroupViewInfo;
begin
  Result := TdxRibbonGalleryGroupViewInfo(FGroups[Index]);
end;

function TdxRibbonGalleryControlViewInfo.GetGroupItemSize(
  AGroupIndex: Integer): TSize;
var
  ADestroyAfterUse: Boolean;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
begin
  if GalleryItem.IsGroupVisible(AGroupIndex) then
  begin
    AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self, AGroupIndex,
      ADestroyAfterUse);
    try
      Result := AGroupViewInfo.ItemSize;
    finally
      if ADestroyAfterUse then
        AGroupViewInfo.Free;
    end;
  end
  else
    Result := cxNullSize;
end;

procedure TdxRibbonGalleryControlViewInfo.CalculateGlobalItemSize;
begin
  if (GalleryOptions.EqualItemSizeInAllGroups) or
    (Control.Parent.Kind in [bkBarControl]) then
    FGlobalItemSize := GetMaxGroupItemSize;
end;

function TdxRibbonGalleryControlViewInfo.GetControl: TdxRibbonGalleryControl;
begin
  Result := TdxRibbonGalleryControl(FControl);
end;

function TdxRibbonGalleryControlViewInfo.GetGalleryItem: TdxRibbonGalleryItem;
begin
  if Control <> nil then
    Result := TdxRibbonGalleryItem(Control.Item)
  else
    Result := nil;
end;

function TdxRibbonGalleryControlViewInfo.GetGalleryOptions: TdxRibbonGalleryOptions;
begin
  Result := GalleryItem.GalleryOptions;
end;

function TdxRibbonGalleryControlViewInfo.GetGallerySize: TSize;
var
  ARect: TRect;
begin
  ARect := GetGalleryBounds;
  Result.cx := ARect.Right - ARect.Left;
  Result.cy := ARect.Bottom - ARect.Top;
end;

function TdxRibbonGalleryControlViewInfo.GetPainter: TdxBarSkinnedPainter;
begin
  Result := TdxBarSkinnedPainter(Control.Painter);
end;

function TdxRibbonGalleryControlViewInfo.GetScrollBarBounds: TRect;
var
  AGalleryBounds: TRect;
begin
  Result := Bounds;
  Result.Left := Result.Right - GetScrollBarWidth;
  AGalleryBounds := GalleryBounds;
  Result.Top := AGalleryBounds.Top;
  Result.Bottom := AGalleryBounds.Bottom;
end;

function TdxRibbonGalleryControlViewInfo.GetScrollBarWidth: Integer;
begin
  if Control.IsNeedScrollBar then
    Result := InternalGetScrollBarWidth
  else
    Result := 0;
end;

procedure TdxRibbonGalleryControlViewInfo.DrawGroupItem(
  const AGroupItem: TdxRibbonGalleryGroupItem);
var
  AItemViewInfo: TdxRibbonGalleryGroupItemViewInfo;
begin
  if AGroupItem <> nil then
  begin
    Control.Canvas.SaveClipRegion;
    try
      Control.Canvas.SetClipRegion(TcxRegion.Create(GalleryBounds), roSet);
      AItemViewInfo := GetGroupItemViewInfo(AGroupItem);
      if AItemViewInfo <> nil then
        AItemViewInfo.Paint(Control.Canvas);
    finally
      Control.Canvas.RestoreClipRegion;
    end;
  end;
end;

procedure TdxRibbonGalleryControlViewInfo.RepaintChainOfGroups(
  ANewItem, AOldItem: TdxRibbonGalleryGroupItem);

  function IsGroupPullDirectionAgreeWithGeneral(AnItem: TdxRibbonGalleryGroupItem): Boolean;
  begin
    Result := (AnItem = nil) or (AnItem.Group.Options.ItemPullHighlighting.Direction =
      GalleryOptions.ItemPullHighlighting.Direction);
  end;

  function UsePullDirectionOfGroup(out ADirection: TdxRibbonGalleryItemPullHighlightingDirection): Boolean;
  begin
    if not IsGroupPullDirectionAgreeWithGeneral(ANewItem) or
      not IsGroupPullDirectionAgreeWithGeneral(AOldItem) then
    begin
      Result := True;
      if ANewItem <> nil then
        ADirection := ANewItem.Group.Options.ItemPullHighlighting.Direction
      else
        ADirection := AOldItem.Group.Options.ItemPullHighlighting.Direction;
    end
    else
      Result := False;
  end;

  function GetDirection: TdxRibbonGalleryItemPullHighlightingDirection;
  begin
    if not UsePullDirectionOfGroup(Result) then
      Result := GalleryOptions.ItemPullHighlighting.Direction;
  end;

  function IsStartToFinishDirection: Boolean;
  begin
    Result := GetDirection = gphdStartToFinish;
  end;

  procedure DoRepaintChain(AStartGroupIndex, AStartGroupItemIndex,
    AEndGroupIndex, AEndGroupItemIndex: Integer; IsHotTrack: Boolean);

    function GetGroupRepaintPart(AStartGroupIndex, AStartGroupItemIndex,
      AEndGroupIndex, AEndGroupItemIndex, ACurrentGroupIndex: Integer;
      out AnItemIndex, AnItemIndex2: Integer): TdxRibbonGalleryGroupRepaintPart;
    begin
      if ACurrentGroupIndex = GetVisibleGroupIndex(AStartGroupIndex, True) then
      begin
        AnItemIndex := AStartGroupItemIndex;
        if ACurrentGroupIndex = AEndGroupIndex then
        begin
          Result := ggrpBetween;
          AnItemIndex2 := AEndGroupItemIndex;
        end
        else
          if IsStartToFinishDirection and
            (ACurrentGroupIndex = GetVisibleGroupIndex(0, True)) then
            Result := ggrpAll
          else
            Result := ggrpAfter;
      end
      else
        if ACurrentGroupIndex = AEndGroupIndex then
        begin
          if not IsStartToFinishDirection and
            (ACurrentGroupIndex = GetVisibleGroupIndex(GalleryItem.GalleryGroups.Count - 1, False)) then
            Result := ggrpAll
          else
          begin
            Result := ggrpBefore;
            AnItemIndex := AEndGroupItemIndex;
          end;
        end
        else
        begin
          Result := ggrpAll;
          AnItemIndex := 0;
        end;
    end;

  var
    AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
    AnItemIndex, AnItemIndex2, I: Integer;
    APart: TdxRibbonGalleryGroupRepaintPart;
    DestroyAfterUse: Boolean;
  begin
    Control.Canvas.SaveClipRegion;
    try
      Control.Canvas.SetClipRegion(TcxRegion.Create(GalleryBounds), roSet);
      I := AStartGroupIndex;
      while I <= AEndGroupIndex do
      begin
        AGroupViewInfo := GetGroupViewInfo(GalleryItem.GalleryGroups, Self, I,
          DestroyAfterUse);
        if AGroupViewInfo <> nil then
        begin
          if not DestroyAfterUse then
          begin
            APart := GetGroupRepaintPart(AStartGroupIndex, AStartGroupItemIndex,
              AEndGroupIndex, AEndGroupItemIndex, I, AnItemIndex, AnItemIndex2);
            AGroupViewInfo.RepaintChainOfItems(AnItemIndex, IsHotTrack, Control.Canvas,
              APart, AnItemIndex2);
          end
          else
            AGroupViewInfo.Free;
        end;
        Inc(I);
      end;
    finally
      Control.Canvas.RestoreClipRegion;
    end;
  end;

  procedure ReturnRange(ANewItem, AOldItem: TdxRibbonGalleryGroupItem;
    out AStartGroupItem, AEndGroupItem: TdxRibbonGalleryGroupItem;
    out IsHotTrack: Boolean);
  var
    AnOuterGroupItem: TdxRibbonGalleryGroupItem;
  begin
    AnOuterGroupItem := GetOuterGroupItem(ANewItem, AOldItem, GetDirection);
    IsHotTrack := AnOuterGroupItem = ANewItem;
    if IsHotTrack xor not IsStartToFinishDirection then
    begin
      AStartGroupItem := AOldItem;
      AEndGroupItem := ANewItem;
    end
    else
    begin
      AStartGroupItem := ANewItem;
      AEndGroupItem := AOldItem;
    end;
  end;

  procedure ReturnRangeStart(AStartGroupItem: TdxRibbonGalleryGroupItem;
    IsHotTrack: Boolean; out AStartGroupIndex, AStartGroupItemIndex: Integer);
  begin
    if AStartGroupItem <> nil then
    begin
      AStartGroupIndex := AStartGroupItem.Group.Index;
      AStartGroupItemIndex := AStartGroupItem.Index;
      if not IsHotTrack and IsStartToFinishDirection then
        begin
          Inc(AStartGroupItemIndex);
          if AStartGroupItemIndex > AStartGroupItem.Group.Items.Count - 1 then
          begin
            AStartGroupItemIndex := 0;
            Inc(AStartGroupIndex);
            AStartGroupIndex := GetVisibleGroupIndex(AStartGroupIndex, True);
          end;
        end;
    end
    else
    begin
      AStartGroupIndex := 0;
      AStartGroupItemIndex := 0;
    end;
  end;

  procedure ReturnRangeEnd(AEndGroupItem: TdxRibbonGalleryGroupItem;
    IsHotTrack: Boolean; out AEndGroupIndex, AEndGroupItemIndex: Integer);
  begin
    if AEndGroupItem <> nil then
    begin
      AEndGroupIndex := AEndGroupItem.Group.Index;
      AEndGroupItemIndex := AEndGroupItem.Index;
      if not IsHotTrack and not IsStartToFinishDirection then
        begin
          Dec(AEndGroupItemIndex);
          if AEndGroupItemIndex < 0 then
          begin
            Dec(AEndGroupIndex);
            AEndGroupIndex := GetVisibleGroupIndex(AEndGroupIndex, False);
            AEndGroupItemIndex := GalleryItem.GalleryGroups[AEndGroupIndex].Items.Count - 1;
          end;
        end;
    end
    else
    begin
      if IsStartToFinishDirection then
      begin
        AEndGroupIndex := 0;
        AEndGroupItemIndex := 0;
      end
      else
      begin
        AEndGroupIndex := GetVisibleGroupIndex(
          GalleryItem.GalleryGroups[GalleryItem.GalleryGroups.Count - 1].Index, False);
        AEndGroupItemIndex := GalleryItem.GalleryGroups[AEndGroupIndex].Items.Count - 1;
      end;
    end;
  end;

var
  IsHotTrack: Boolean;
  AStartGroupItem, AEndGroupItem: TdxRibbonGalleryGroupItem;
  AStartGroupIndex, AEndGroupIndex, AStartGroupItemIndex, AEndGroupItemIndex: Integer;
begin
  if (ANewItem <> nil) or (AOldItem <> nil) then
  begin
    ReturnRange(ANewItem, AOldItem, AStartGroupItem,
      AEndGroupItem, IsHotTrack);
    ReturnRangeStart(AStartGroupItem, IsHotTrack, AStartGroupIndex,
      AStartGroupItemIndex);
    ReturnRangeEnd(AEndGroupItem, IsHotTrack, AEndGroupIndex,
      AEndGroupItemIndex);
    DoRepaintChain(AStartGroupIndex, AStartGroupItemIndex,
      AEndGroupIndex, AEndGroupItemIndex, IsHotTrack);
  end;
end;

{ TdxInRibbonGalleryControlViewInfo }

procedure TdxInRibbonGalleryControlViewInfo.Calculate(
  ALayoutOffset: Integer; AScrollCode: TScrollCode);

  procedure ShowGivenGroupItem;
  var
    AGroupItem: TdxRibbonGalleryGroupItem;
  begin
    if FShowGroupItem <> nil then
    begin
      AGroupItem := FShowGroupItem;
      FShowGroupItem := nil;
      ShowGroupItem(AGroupItem);
    end;
  end;

var
  ARowDelta: Integer;
begin
  inherited Calculate(ALayoutOffset, AScrollCode);
  if Control.GetGroups.Count = 0 then
    Exit;
  case AScrollCode of
    scLineUp: ARowDelta := -1;
    scLineDown: ARowDelta := 1;
  else
    ARowDelta := 0;
  end;
  if FIsScrolling then
    SetScrollingRowCounter(ARowDelta)
  else
    DoScrolling(ARowDelta);
  ShowGivenGroupItem;
end;

function TdxInRibbonGalleryControlViewInfo.IsCollapsed: Boolean;
begin
  Result := GetCollapsed;
end;

procedure TdxInRibbonGalleryControlViewInfo.ResetCachedValues;
var
  I: Integer;
begin
  inherited ResetCachedValues;
  SetLength(FWidthForColumnCountInfos, GetMaxColumnCount - GetMinColumnCount + 1);
  for I := 0 to High(FWidthForColumnCountInfos) do
    FWidthForColumnCountInfos[I].Calculated := False;
  FControlHeight := 0;
end;

procedure TdxInRibbonGalleryControlViewInfo.BoundsCalculated;
begin
  inherited BoundsCalculated;
  if not Control.Collapsed then
    with GetControlMargins do
      Self.SetBounds(cxRectInflate(Self.Bounds, -Left, -Top, -Right, -Bottom));
end;

procedure TdxInRibbonGalleryControlViewInfo.CalculateLayout(ALayoutOffset,
  AColumnCount: Integer; AGroupItemsList: TObjectList);
var
  ARowTop, AColumnIndex: Integer;
  I: Integer;
  ACurrentGroupIndex, AItemGroupIndex: Integer;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  AGroupItemBounds: TRect;
  ABounds: TRect;
begin
  FGroups.Clear;
  AGroupViewInfo := nil;
  ACurrentGroupIndex := -1;
  AColumnIndex := 0;
  ARowTop := ALayoutOffset;
  ABounds := GalleryBounds;
  for I := 0 to AGroupItemsList.Count - 1 do
  begin
    AItemGroupIndex := TdxRibbonGalleryGroup(TdxRibbonGalleryGroupItems(TCollectionItemAccess(
      AGroupItemsList.Items[I]).GetOwner).GetOwner).Index;
    if ACurrentGroupIndex <> AItemGroupIndex then
    begin
      ACurrentGroupIndex := AItemGroupIndex;
      AGroupViewInfo := TdxRibbonGalleryGroupViewInfo.Create(Self,
        Control.GetGroups[AItemGroupIndex], cxNullSize);
      AGroupViewInfo.SetBounds(ABounds);
      FGroups.Add(AGroupViewInfo);
    end;
    AGroupItemBounds.Top := ARowTop + ABounds.Top;
    AGroupItemBounds.Bottom := AGroupItemBounds.Top + AGroupViewInfo.ItemSize.cy;
    AGroupItemBounds.Left := AGroupViewInfo.GetColumnLeft(AColumnIndex, Bounds.Left);
    AGroupItemBounds.Right := AGroupItemBounds.Left + AGroupViewInfo.ItemSize.cx;
    AGroupViewInfo.CreateGroupItem(
      TdxRibbonGalleryGroupItem(AGroupItemsList.Items[I]).Index, AGroupItemBounds);
    Inc(AColumnIndex);
    if AColumnIndex = AColumnCount then
    begin
      AColumnIndex := 0;
      ARowTop := ARowTop + AGroupViewInfo.GetRowHeight;
    end;
  end;
end;

function TdxInRibbonGalleryControlViewInfo.CorrectGroupItemSize(
  const AGroupItemSize: TSize): TSize;
var
  I: Integer;
  ASize: TSize;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse: Boolean;
begin
  Result := cxNullSize;
  for I := 0 to Control.GetGroups.Count - 1 do
    if GalleryItem.IsGroupVisible(I) then
    begin
      AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self, I,
        ADestroyAfterUse);
      try
        ASize := AGroupViewInfo.CalculateItemSize(AGroupItemSize);
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;
      if Result.cx < ASize.cx then
        Result.cx := ASize.cx;
      if Result.cy < ASize.cy then
        Result.cy := ASize.cy;
    end;
end;

procedure TdxInRibbonGalleryControlViewInfo.DoScrolling(ARowDelta: Integer);

  procedure DrawStep(ALayoutOffset: Integer; AColumnCount: Integer;
    AGroupItemsList: TObjectList);
  begin
    CalculateLayout(GetTopLayoutIndent + ALayoutOffset, AColumnCount, AGroupItemsList);
    cxInvalidateRect(Control.Parent.Handle, GalleryBounds, False);
    Control.Parent.Update;
  end;

  procedure Waiting;
  var
    ATickCount: Cardinal;
  begin
    ATickCount := GetTickCount;
    while Abs(GetTickCount - ATickCount) < 10 do
      //Application.ProcessMessages; //TODO: correct scrolling
  end;

var
  AColumnCount: Integer;
  ARowHeight: Integer;
  AVisibleRowCount, ALastRowIndex, AGroupItemCount: Integer;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse: Boolean;
  ANewTopVisibleRow: Integer;
  AFirstVisibleRow, ALastVisibleRow: Integer;
  AGroupItemsList: TObjectList;
  ALayoutOffset: Integer;
  AnAdditionalVisibleRowCount: Integer;
begin
  if Control.GetVisibleGroupCount <> 0 then
  begin
    FIsScrolling := True;
    try
      AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self,
        GetVisibleGroupIndex(0, True), ADestroyAfterUse);
      try
        AColumnCount := AGroupViewInfo.GetColumnCount(Control.ClientWidth);
        ARowHeight := AGroupViewInfo.GetRowHeight;
      finally
        if ADestroyAfterUse then
          AGroupViewInfo.Free;
      end;

      AVisibleRowCount := GetVisibleRowCount;
      AGroupItemCount := GetGroupItemCount(Control.GetGroups.Count - 1);
      ALastRowIndex := GetRowIndex(AGroupItemCount - 1, AColumnCount);
      if ALastRowIndex < FTopVisibleRow + AVisibleRowCount - 1 then
        FTopVisibleRow := Max(0, ALastRowIndex - AVisibleRowCount + 1);
      if (AColumnCount > 0) and IsScrollingPossible(ARowDelta) then
        repeat
          if ARowDelta < 0 then
          begin
            ANewTopVisibleRow := Max(FTopVisibleRow - 1, 0);
            AnAdditionalVisibleRowCount := 1;
          end
          else
            if ARowDelta > 0 then
            begin
              ANewTopVisibleRow := Min(FTopVisibleRow + 1,
                Ceil(AGroupItemCount / AColumnCount));
              AnAdditionalVisibleRowCount := 1;
            end
            else
            begin
              ANewTopVisibleRow := FTopVisibleRow;
              AnAdditionalVisibleRowCount := 0;
            end;
          AFirstVisibleRow := Min(ANewTopVisibleRow, FTopVisibleRow);
          ALastVisibleRow := AFirstVisibleRow + (AVisibleRowCount - 1) +
            AnAdditionalVisibleRowCount;

          AGroupItemsList := TObjectList.Create(False);
          try
            FillGroupItemList(AFirstVisibleRow, ALastVisibleRow, AColumnCount,
              AGroupItemsList);

            if ARowDelta < 0 then
            begin
              for ALayoutOffset := -ARowHeight div 3 to 0 do
              begin
                DrawStep(ALayoutOffset * 3, AColumnCount, AGroupItemsList);
                Waiting;
              end;
            end
            else
              if ARowDelta > 0 then
              begin
                for ALayoutOffset := 0 downto -ARowHeight div 3 do
                begin
                  DrawStep(ALayoutOffset * 3, AColumnCount, AGroupItemsList);
                  Waiting;
                end;
              end;
            FillGroupItemList(ANewTopVisibleRow,
              ANewTopVisibleRow + (AVisibleRowCount - 1), AColumnCount, AGroupItemsList);
            CalculateLayout(1 + GetTopLayoutIndent, AColumnCount, AGroupItemsList);
          finally
            AGroupItemsList.Free;
          end;

          FTopVisibleRow := ANewTopVisibleRow;
          if ARowDelta > 0 then
            Dec(ARowDelta)
          else
            if ARowDelta < 0 then
              Inc(ARowDelta);
        until (ARowDelta = 0) or not IsScrollingPossible(ARowDelta) or
          FScrollingBreak;
    finally
      FScrollingBreak := False;
      FIsScrolling := False;
    end;
  end
  else
    FGroups.Clear;
  ScrollingRowCounterRelease;
end;

procedure TdxInRibbonGalleryControlViewInfo.DrawBackground(const R: TRect);

  function GetInRibbonGalleryState: Integer;
  begin
    Result := TdxBarSkinnedPainterAccess(Painter).GetPartState(
      Control.DrawParams, icpControl);
  end;

begin
  Control.Canvas.SaveClipRegion;
  try
    Control.Canvas.IntersectClipRect(R);
    Painter.Skin.DrawBackground(Control.Canvas.Handle, GalleryBounds,
     DXBAR_INRIBBONGALLERY, GetInRibbonGalleryState);
  finally
    Control.Canvas.RestoreClipRegion;
  end;
end;

function TdxInRibbonGalleryControlViewInfo.GetControlMargins: TRect;
begin
  Result := Rect(0, 3, 0, 3);
end;

function TdxInRibbonGalleryControlViewInfo.GetGalleryMargins: TRect;
begin
  Result := Rect(0, 0, -Ord(Control.IsNeedScrollBar), 0);
end;

function TdxInRibbonGalleryControlViewInfo.GetLayoutWidth(
  AColumnCount: Integer; out AGroupItemWidthIsNull: Boolean): Integer;
begin
  Result := AColumnCount * GetMaxGroupItemSize.cx +
    (AColumnCount - 1) * GetSpaceBetweenItems(True);
  AGroupItemWidthIsNull := GetMaxGroupItemSize.cx = 0;
end;

function TdxInRibbonGalleryControlViewInfo.GetMaxGroupItemSize: TSize;
const
  AMargin = 1;
var
  AHeight, ARowCount, ADenominator, AIndent: Integer;
begin
  if CanUseSize(GlobalItemSize) then
    Result := GlobalItemSize
  else
  begin
    Result := inherited GetMaxGroupItemSize;
    AHeight := GallerySize.cy;
    if AHeight <= 0 then
      AHeight := ControlHeight;
    ADenominator := Result.cy + GetSpaceBetweenItems(False);
    if (AHeight > 0) and (ADenominator <> 0) then
    begin
      AIndent := 2 * AMargin + GetTopLayoutIndent + GetBottomLayoutIndent;
      ARowCount := Max(1, (AHeight - AIndent) div ADenominator);
      Result.cy := (AHeight - GetSpaceBetweenItems(False) *
        (ARowCount - 1) - AIndent) div ARowCount;
      Result.cx := CorrectGroupItemSize(Result).cx;
    end
    else
      ARowCount := 1;
    FRowCount := ARowCount;
  end;
end;

function TdxInRibbonGalleryControlViewInfo.GetBottomLayoutIndent: Integer;
begin
  Result := GalleryOptions.SpaceBetweenItemsAndBorder;
end;

function TdxInRibbonGalleryControlViewInfo.GetLeftLayoutIndent: Integer;
begin
  Result := 1 + GalleryOptions.SpaceBetweenItemsAndBorder;
end;

function TdxInRibbonGalleryControlViewInfo.GetRightLayoutIndent: Integer;
begin
  Result := GalleryOptions.SpaceBetweenItemsAndBorder;
end;

function TdxInRibbonGalleryControlViewInfo.GetTopLayoutIndent: Integer;
begin
  Result := GalleryOptions.SpaceBetweenItemsAndBorder;
end;

function TdxInRibbonGalleryControlViewInfo.InternalGetScrollBarWidth: Integer;
begin
  with GetGalleryMargins do
    Result := (Self.ControlHeight - (Top + Bottom)) div 4;
end;

function TdxInRibbonGalleryControlViewInfo.IsInRibbon: Boolean;
begin
  Result := True;
end;

procedure TdxInRibbonGalleryControlViewInfo.ShowGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem);
var
  AGlobalIndex: Integer;
begin
  if (AGroupItem <> nil) and not Control.Collapsed and (FRowCount > 0) then
  begin
    AGlobalIndex := GetGroupItemCount(AGroupItem.Group.Index - 1) +
      AGroupItem.Index;
    FTopVisibleRow := Max(0, GetRowIndex(AGlobalIndex, GetColumnCount) -
      GetVisibleRowCount + 1);
    DoScrolling(0);
    GetGalleryItem.Update;
  end
  else
    FShowGroupItem := AGroupItem; 
end;

procedure TdxInRibbonGalleryControlViewInfo.FillGroupItemList(AFirstVisibleRow,
  ALastVisibleRow, AColumnCount: Integer; AList: TObjectList);

  function GetGroupItemsCount(AGroupIndex: Integer): Integer;
  begin
    Result := IfThen(GalleryItem.IsGroupVisible(AGroupIndex),
      Control.GetGroups[AGroupIndex].Items.Count);
  end;

var
  I, J, ACurrentGroupItem, AFirstGroupItem, ALastGroupItem: Integer;
begin
  AFirstGroupItem := AFirstVisibleRow * AColumnCount;
  ALastGroupItem := (ALastVisibleRow + 1) * AColumnCount - 1;
  ACurrentGroupItem := 0;
  I := 0;
  while (I <= Control.GetGroups.Count - 1) and
    (ACurrentGroupItem + GetGroupItemsCount(I) <= AFirstGroupItem) do
  begin
    ACurrentGroupItem := ACurrentGroupItem + GetGroupItemsCount(I);
    Inc(I);
  end;
  AList.Clear;
  AList.Capacity := ALastGroupItem - AFirstGroupItem + 1;
  J := AFirstGroupItem - ACurrentGroupItem;
  ACurrentGroupItem := AFirstGroupItem;
  while (ACurrentGroupItem <= ALastGroupItem) and
    (I < Control.GetGroups.Count) do
  begin
    while GalleryItem.IsGroupVisible(I) and
      (J < Control.GetGroups[I].Items.Count) and
      (ACurrentGroupItem <= ALastGroupItem) do
    begin
      AList.Add(Control.GetGroups[I].Items[J]);
      Inc(J);
      Inc(ACurrentGroupItem);
    end;
    Inc(I);
    J := 0;
  end;
end;

function TdxInRibbonGalleryControlViewInfo.GetControlHeight: Integer;
begin
  if FControlHeight = 0 then
  begin
    FControlHeight := TdxRibbonBarPainter(Painter).GetGroupRowHeight(
      Control.BarManager.ImageOptions.GlyphSize, Control.Parent.Font) * dxRibbonGroupRowCount;
    with GetControlMargins do
      Dec(FControlHeight, Top + Bottom);
  end;
  Result := FControlHeight;
end;

function TdxInRibbonGalleryControlViewInfo.GetVisibleRowCount: Integer;
begin
  if FRowCount = 0 then
    raise EdxException.Create('');
  Result := FRowCount;
end;

// IdxBarMultiColumnItemControlViewInfo
function TdxInRibbonGalleryControlViewInfo.CanCollapse: Boolean;
begin
  Result := GalleryOptions.CanCollapse;
end;

function TdxInRibbonGalleryControlViewInfo.GetCollapsed: Boolean;
begin
  Result := FCollapsed or GalleryOptions.Collapsed;
end;

function TdxInRibbonGalleryControlViewInfo.GetColumnCount: Integer;
begin
  Result := FColumnCount;
end;

function TdxInRibbonGalleryControlViewInfo.GetMaxColumnCount: Integer;
begin
  Result := GalleryOptions.ColumnCount;
end;

function TdxInRibbonGalleryControlViewInfo.GetRowIndex(AGroupItemIndex,
  AColumnCount: Integer): Integer;
begin
  if AColumnCount <> 0 then
    Result := AGroupItemIndex div AColumnCount
  else
    Result := 0;
end;

function TdxInRibbonGalleryControlViewInfo.GetMinColumnCount: Integer;
begin
  Result := GalleryOptions.MinColumnCount;
end;

function TdxInRibbonGalleryControlViewInfo.GetSpaceBetweenItems(
  IsAflat: Boolean): Integer;
begin
  if (GalleryOptions.RemoveHorizontalItemPadding and IsAflat) or
    (GalleryOptions.RemoveVerticalItemPadding and not IsAflat) then
    Result := 0
  else
    Result := GalleryOptions.SpaceBetweenItems;
end;

function TdxInRibbonGalleryControlViewInfo.GetWidthForColumnCount(
  AColumnCount: Integer): Integer;
begin
  if FWidthForColumnCountInfos[AColumnCount - GetMinColumnCount].Calculated then
    Result := FWidthForColumnCountInfos[AColumnCount - GetMinColumnCount].Width
  else
  begin
    Result := Control.GetDefaultWidthInSubMenu;
    with FWidthForColumnCountInfos[AColumnCount - GetMinColumnCount] do
    begin
      Width := Result;
      Calculated := True;
    end;
  end;
end;

function TdxInRibbonGalleryControlViewInfo.IsScrollingPossible(
  ARowDelta: Integer): Boolean;
begin
  Result := (ARowDelta < 0) and GetPreviousButtonEnabled or
    (ARowDelta > 0) and GetNextButtonEnabled or (ARowDelta = 0);
end;

procedure TdxInRibbonGalleryControlViewInfo.ScrollingRowCounterRelease;
var
  AScrollingRowCounter: Integer;
begin
  if FScrollingRowCounter <> 0 then
  begin
    AScrollingRowCounter := FScrollingRowCounter;
    FScrollingRowCounter := 0;
    DoScrolling(AScrollingRowCounter);
  end;
end;

procedure TdxInRibbonGalleryControlViewInfo.SetCollapsed(Value: Boolean);
begin
  FCollapsed := Value;
end;

procedure TdxInRibbonGalleryControlViewInfo.SetColumnCount(Value: Integer);
begin
  FColumnCount := Value;
end;

procedure TdxInRibbonGalleryControlViewInfo.SetScrollingRowCounter(
  Value: Integer);
begin
  if Value <> 0 then
    if (FScrollingRowCounter = 0) or
      ((Value > 0) xor (FScrollingRowCounter > 0)) then
    begin
      FScrollingRowCounter := Value;
      FScrollingBreak := True;
    end
    else
      FScrollingRowCounter := FScrollingRowCounter + Value;
end;

{ TdxRibbonOnSubMenuGalleryControlViewInfo }

destructor TdxRibbonOnSubMenuGalleryControlViewInfo.Destroy;
begin
  FGroupItemDescriptionRectCache.Free;
  inherited Destroy;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.Calculate(
  ALayoutOffset: Integer; AScrollCode: TScrollCode);
var
  I, AMode, ACurrentGroupTop, AGroupBottom, AGalleryVisibleHeight: Integer;
  AGalleryBounds: TRect;
  AGallerySize: TSize;
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  AIsIntersected: Boolean;
begin
  inherited Calculate(ALayoutOffset, AScrollCode);
  AGalleryBounds := GalleryBounds;
  AGallerySize := GallerySize;
  FLayoutOffset := ALayoutOffset;

  if Control.SizeChanged then
  begin
    if (GalleryItem.SelectedGroupItem <> nil) and
      GalleryItem.IsGroupVisible(GalleryItem.SelectedGroupItem.Group.Index) then
      DisplayGroupItem(GalleryItem.SelectedGroupItem)
    else
    begin
      AGalleryVisibleHeight := AGallerySize.cy;
      if -FLayoutOffset + GetGalleryHeight(AGallerySize.cx) <
        AGalleryVisibleHeight then
        Control.SetScrollBarPosition(Max(0, GetGalleryHeight(AGallerySize.cx) -
          AGalleryVisibleHeight));
    end;
  end;

  FGroups.Clear;
  AMode := 0;
  I := 0;
  ACurrentGroupTop := -FLayoutOffset + AGalleryBounds.Top;
  while (AMode <> 2) and (I < Control.GetGroups.Count) do
  begin
    if GalleryItem.IsGroupVisible(I) then
    begin
      AGroupViewInfo := TdxRibbonGalleryGroupViewInfo.Create(Self,
        Control.GetGroups[I], cxNullSize);
      AGroupBottom := ACurrentGroupTop +
        AGroupViewInfo.GetHeight(AGallerySize.cx) +
        GalleryOptions.SpaceBetweenGroups;
      AIsIntersected := AreLinesIntersectedStrictly(ACurrentGroupTop,
        AGroupBottom, AGalleryBounds.Top, AGalleryBounds.Bottom);
      if (AMode = 0) and AIsIntersected or
         (AMode = 1) and not AIsIntersected then
        Inc(AMode);
      if AMode = 1 then
      begin
        AGroupViewInfo.Calculate(ACurrentGroupTop, AGroupBottom, AGalleryBounds);
        FGroups.Add(AGroupViewInfo);
      end
      else
        AGroupViewInfo.Free;
      ACurrentGroupTop := AGroupBottom;
    end;
    Inc(I);
  end;

  CalculateFilterBand;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.GetFilterMenuShowingParams(
  out APosition: TPoint; out AOwnerHeight: Integer);
begin
  APosition := Point(FFilterBandContentRect.Left + GroupHeaderCaptionOffset div 2 +
    FilterMenuLeftBoundCorrection, FFilterBandRect.Bottom);
  APosition := Control.Parent.ClientToScreen(APosition);
  AOwnerHeight := cxRectHeight(FFilterBandRect);
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.IsCollapsed: Boolean;
begin
  Result := True;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.IsPtInFilterBandHotTrackArea(
  const P: TPoint): Boolean;
begin
  Result := PtInRect(FFilterBandRect, P);
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.RepaintFilterBand;
begin
  DrawFilterBand;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.SetFilterBandHotTrack(
  AValue: Boolean);
begin
  if FFilterBandHotTrack <> AValue  then
  begin
    FFilterBandHotTrack := AValue;
    DrawFilterBand;
  end;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.DisplayGroupItem(
  AGroupItem: TdxRibbonGalleryGroupItem);

  function DisplayGroupHeaderIfPossible(AGroupItemBottom,
    AGroupIndex: Integer): Boolean;
  var
    AGroupTop: Integer;
  begin
    if FDontDisplayGroupHeaderWhenHotTrackingGroupItem = 0 then
    begin
      AGroupTop := GetAbsoluteGroupTop(AGroupIndex, GallerySize.cx);
      if IsFirstLineShorterOrEqualThanSecond(AGroupTop, AGroupItemBottom,
        GalleryBounds.Top, GalleryBounds.Bottom) and
        (AGroupTop - FLayoutOffset < 0) then
      begin
        Control.SetScrollBarPosition(AGroupTop);
        Result := True;
      end
      else
        Result := False;
    end
    else
      Result := False;
  end;

  procedure MoveLayoutDown(AGroupItemTop, AGroupItemBottom,
    AGroupIndex: Integer);
  begin
    if not DisplayGroupHeaderIfPossible(AGroupItemBottom, AGroupIndex) then
      Control.SetScrollBarPosition(AGroupItemTop);
  end;

  procedure MoveLayoutUp(AGroupItemBottom, AGroupIndex: Integer);
  begin
    if not DisplayGroupHeaderIfPossible(AGroupItemBottom, AGroupIndex) then
      Control.SetScrollBarPosition(AGroupItemBottom - GallerySize.cy);
  end;

var
  AGroupItemTop, AGroupItemBottom: Integer;
  AnAbsoluteGroupItemTop, AnAbsoluteGroupItemBottom: Integer;
begin
  if (AGroupItem <> nil) and (FDontDisplayHotTrackedGroupItem = 0) then
  begin
    GroupItemYRange(AGroupItem, AGroupItemTop, AGroupItemBottom);
    AnAbsoluteGroupItemTop := AGroupItemTop + Control.FScrollBar.Position;
    AnAbsoluteGroupItemBottom := AGroupItemBottom + Control.FScrollBar.Position;
    case RelativeLocationOfLines(AGroupItemTop, AGroupItemBottom,
      GalleryBounds.Top, GalleryBounds.Bottom) of
      rllBefore: MoveLayoutDown(AnAbsoluteGroupItemTop,
        AnAbsoluteGroupItemBottom, AGroupItem.Group.Index);
      rllInside: DisplayGroupHeaderIfPossible(AnAbsoluteGroupItemBottom,
        AGroupItem.Group.Index);
      rllAfter: MoveLayoutUp(AnAbsoluteGroupItemBottom,
        AGroupItem.Group.Index);
    end;
  end;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.DrawBackground(const R: TRect);

  function GetInRibbonGalleryState: Integer;
  begin
    Result := TdxBarSkinnedPainterAccess(Painter).GetPartState(
      Control.DrawParams, icpControl);
  end;

var
  ARect: TRect;
begin
  Control.Canvas.SaveClipRegion;
  try
    Control.Canvas.IntersectClipRect(R);
    Painter.Skin.DrawBackground(Control.Canvas.Handle, GalleryBounds,
      DXBAR_DROPDOWNGALLERY, DXBAR_NORMAL);
    DrawFilterBand;
    if NeedsDrawBottomSeparator then
    begin
      ARect := Bounds;
      ARect.Top := ARect.Bottom - GetBottomSeparatorHeight;
      Painter.SubMenuControlDrawSeparator(Control.Canvas, ARect);
    end;
  finally
    Control.Canvas.RestoreClipRegion;
  end;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetControlBounds: TRect;
begin
  Result := Control.ItemBounds;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetGalleryHeight(
  AWidth: Integer): Integer;
begin
  Result := GetAbsoluteGroupTop(Control.GetGroups.Count, AWidth) -
    GalleryOptions.SpaceBetweenGroups;
  if GalleryOptions.RemoveVerticalItemPadding then
    Inc(Result);
  Result := Max(0, Result);
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetGalleryMargins: TRect;
begin
  Result := cxNullRect;
  if GalleryItem.IsFilterVisible then
    Inc(Result.Top, GetFilterBandHeight + FilterBandOffset);
  if NeedsDrawBottomSeparator then
    Inc(Result.Bottom, GetBottomSeparatorHeight);
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetGroupItemDescriptionRect(
  AGroupIndex, AnItemIndex: Integer): TRect;
begin
  if FGroupItemDescriptionRectCache <> nil then
    Result := TcxRect(TObjectList(
      FGroupItemDescriptionRectCache[AGroupIndex]).Items[AnItemIndex]).Rect
  else
    Result := cxNullRect;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetHeight(
  AWidth: Integer): Integer;
begin
  if GalleryOptions.RowCount = 0 then
    Result := GetGalleryHeight(AWidth)
  else
    Result := GetHeightByRowCount(AWidth);
  Result := Max(Result, Control.CalcMinHeight);
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetLayoutWidth(
  AColumnCount: Integer; out AGroupItemWidthIsNull: Boolean): Integer;
var
  I: Integer;
begin
  Result := 0;
  AGroupItemWidthIsNull := True;
  for I := 0 to Control.GetGroups.Count - 1 do
  begin
    Result := Max(Result, GetGroupItemSize(I).cx * AColumnCount +
      GetSpaceBetweenItems(I, True) * (AColumnCount - 1));
    if AGroupItemWidthIsNull and (GetGroupItemSize(I).cx <> 0) then
      AGroupItemWidthIsNull := False;
  end;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.GroupItemYRange(
  const AGroupItem: TdxRibbonGalleryGroupItem; var ATop, ABottom: Integer);
var
  AGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse: Boolean;
  AGallerySize: TSize;
begin
  AGallerySize := GallerySize;
  ATop := -FLayoutOffset +
    GetAbsoluteGroupTop(AGroupItem.Group.Index, AGallerySize.cx);
  AGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self,
    AGroupItem.Group.Index, ADestroyAfterUse);
  try
    {if ADestroyAfterUse then
      AGroupViewInfo.SetBounds(GalleryBounds);}
    ATop := AGroupViewInfo.GetRowTop(AGroupViewInfo.GetItemRow(
      AGroupItem.Index, AGallerySize.cx), ATop, AGallerySize.cx);
    ABottom := ATop + AGroupViewInfo.FItemSize.cy;
  finally
    if ADestroyAfterUse then
      AGroupViewInfo.Free;
  end;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetMinSize: TSize;
begin
  Result.cx := Control.CalcDefaultWidth + GetGalleryMargins.Left +
    GetGalleryMargins.Right;
  if GroupCount <> 0 then
    Result.cy := Control.CalcMinHeight + GetGalleryMargins.Top +
      GetGalleryMargins.Bottom
  else
    Result.cy := 0;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.InternalGetScrollBarWidth: Integer;
begin
  Result := GetScrollBarSize.cx;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.Changed;
begin
  inherited Changed;
  InitializeGroupItemDescriptionRectCache;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.SetGroupItemDescriptionRect(
  AGroupIndex, AnItemIndex: Integer; ARect: TRect);
begin
  if FGroupItemDescriptionRectCache = nil then
    InitializeGroupItemDescriptionRectCache;
  TcxRect(TObjectList(FGroupItemDescriptionRectCache[AGroupIndex]).Items[AnItemIndex]).Rect :=
    ARect;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.CalculateFilterBand;
begin
  if GalleryItem.IsFilterVisible then
  begin
    FFilterBandRect := cxRectSetHeight(GetControlBounds, GetFilterBandHeight);
    FFilterBandContentRect := FFilterBandRect;
    ExtendRect(FFilterBandContentRect,
      Painter.Skin.GetContentOffsets(DXBAR_GALLERYFILTERBAND));
  end;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.DrawFilterBand;
begin
  if GalleryItem.IsFilterVisible then
  begin
    FillRectByColor(Control.Canvas.Handle,
      cxRectInflate(FFilterBandRect, 0, 0, 0, FilterBandOffset),
      Painter.Skin.GetPartColor(DXBAR_DROPDOWNBORDER_INNERLINE));
    Painter.Skin.DrawBackground(Control.Canvas.Handle, FFilterBandRect,
      DXBAR_GALLERYFILTERBAND);
    DrawFilterCaption;
  end;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.DrawFilterCaption;

  function GetDrawTextFlags: Integer;
  begin
    Result := cxSingleLine or cxAlignLeft or cxAlignTop or cxShowEndEllipsis;
  end;

  function GetFilterArrowWidth: Integer;
  begin
    Result := FilterArrowSize * 2 - 1;
  end;

  function GetFilterSkinState: Integer;
  begin
    if FFilterBandHotTrack and not TdxRibbonOnSubMenuGalleryController(Control.Controller).IsFilterMenuShowed then
      Result := DXBAR_HOT
    else
      Result := DXBAR_NORMAL;
  end;

var
  AArrowRect, ACaptionRect: TRect;
  AArrowOffset: Integer;
  ACanvas: TcxCanvas;
  ACaption: string;
  P: TcxArrowPoints;
begin
  ACanvas := Control.Canvas;
  ACanvas.Font.Color := Painter.Skin.GetPartColor(DXBAR_GALLERYFILTERBANDTEXT, GetFilterSkinState);
  AArrowOffset := ACanvas.TextWidth(' ') + FilterArrowOffset;
  ACaption := GalleryItem.GetFilterCaption;

  ACaptionRect := FFilterBandContentRect;
  InflateRect(ACaptionRect, -GroupHeaderCaptionOffset, 0);
  Dec(ACaptionRect.Right, GetFilterArrowWidth + AArrowOffset);
  ACanvas.TextExtent(ACaption, ACaptionRect, GetDrawTextFlags);
  ACanvas.Brush.Style := bsClear;
  ACanvas.DrawText(ACaption, ACaptionRect, GetDrawTextFlags);
  ACanvas.Brush.Style := bsSolid;

  AArrowRect := cxRectBounds(ACaptionRect.Right + AArrowOffset,
    FFilterBandContentRect.Top + (cxRectHeight(FFilterBandContentRect) - FilterArrowSize) div 2,
    GetFilterArrowWidth, FilterArrowSize);
  TcxCustomLookAndFeelPainter.CalculateArrowPoints(AArrowRect, P, adDown, False, FilterArrowSize);
  with ACanvas do
  begin
    Brush.Style := bsSolid;
    SetBrushColor(ACanvas.Font.Color);
    Pen.Color := ACanvas.Font.Color;
    Polygon(P);
  end;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetBottomSeparatorHeight: Integer;
begin
  Result := Painter.SubMenuGetSeparatorSize;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetFilterBandHeight: Integer;
begin
  Result := cxTextHeight(Control.Parent.Font);
  with Painter.Skin.GetContentOffsets(DXBAR_GALLERYFILTERBAND) do
    Inc(Result, Top + Bottom);
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetHeightByRowCount(
  AWidth: Integer): Integer;
var
  ARowCount, ACurrentRow, ACurrentGroupIndex, AGroupRowCount: Integer;
  ACurrentGroupViewInfo: TdxRibbonGalleryGroupViewInfo;
  ADestroyAfterUse: Boolean;
  AGalleryOptions: TdxRibbonGalleryOptions;
begin
  Result := 0;
  ACurrentRow := 0;
  ACurrentGroupIndex := 0;
  AGalleryOptions := GalleryOptions;
  ARowCount := AGalleryOptions.RowCount;
  while (ACurrentRow < ARowCount) and (ACurrentGroupIndex > -1) and
    (ACurrentGroupIndex < Control.GetGroups.Count) do
  begin
    if Result <> 0 then
      Inc(Result, AGalleryOptions.SpaceBetweenGroups);
    ACurrentGroupIndex := GetVisibleGroupIndex(ACurrentGroupIndex, True);
    if ACurrentGroupIndex <> -1 then
    begin
      ACurrentGroupViewInfo := GetGroupViewInfo(Control.GetGroups, Self,
        ACurrentGroupIndex, ADestroyAfterUse);
      try
        Inc(Result, ACurrentGroupViewInfo.Header.GetHeight(AWidth, True));
        AGroupRowCount := Min(ACurrentGroupViewInfo.GetRowCount(AWidth),
          ARowCount - ACurrentRow);
        Inc(Result, Max(0, AGroupRowCount * ACurrentGroupViewInfo.GetRowHeight -
          ACurrentGroupViewInfo.GetSpaceBetweenItems(False)));
        Inc(ACurrentRow, AGroupRowCount);
        Inc(ACurrentGroupIndex);
      finally
        if ADestroyAfterUse then
          ACurrentGroupViewInfo.Free;
      end;
    end;
  end;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.GetSpaceBetweenItems(
  AGroupIndex: Integer; IsAflat: Boolean): Integer;
begin
  if (Control.GetGroups[AGroupIndex].Options.RemoveHorizontalItemPadding and
    IsAflat) or
    (Control.GetGroups[AGroupIndex].Options.RemoveVerticalItemPadding and
    not IsAflat) then
    Result := 0
  else
    Result := Control.GetGroups[AGroupIndex].Options.SpaceBetweenItems;
end;

procedure TdxRibbonOnSubMenuGalleryControlViewInfo.InitializeGroupItemDescriptionRectCache;
var
  I, J: Integer;
  AObjectList: TObjectList;
begin
  if GalleryOptions.ItemTextKind <> itkCaptionAndDescription then
    Exit;
  FGroupItemDescriptionRectCache.Free;
  FGroupItemDescriptionRectCache := TObjectList.Create;
  FGroupItemDescriptionRectCache.Capacity := GalleryItem.GalleryGroups.Count;
  for I := 0 to GalleryItem.GalleryGroups.Count - 1 do
  begin
    AObjectList := TObjectList.Create;
    FGroupItemDescriptionRectCache.Add(AObjectList);
    AObjectList.Capacity := GalleryItem.GalleryGroups[I].Items.Count;
    for J := 0 to GalleryItem.GalleryGroups[I].Items.Count - 1 do
      AObjectList.Add(TcxRect.Create(Self));
  end;
end;

function TdxRibbonOnSubMenuGalleryControlViewInfo.NeedsDrawBottomSeparator: Boolean;
begin
  Result := Control.Parent.ItemLinks.VisibleItemCount <> 0; //TODO
end;

{ TdxRibbonGalleryControlAccessibilityHelper }

function TdxRibbonGalleryControlAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;
begin
  Result := False;

  if not Control.Collapsed then
    if Control.Parent.Kind = bkBarControl then
    begin
      Result := AKey in [VK_RETURN, VK_SPACE, VK_UP, VK_DOWN];
      if Result then
        Control.DropDown(False);
    end
    else
    begin
      Result := True;
      case AKey of
        VK_DOWN: OnSubMenuController.Navigation(andDown);
        VK_LEFT: OnSubMenuController.Navigation(andLeft);
        VK_RIGHT: OnSubMenuController.Navigation(andRight);
        VK_UP: OnSubMenuController.Navigation(andUp);
        VK_TAB: OnSubMenuController.Tabulation;
        VK_PRIOR: OnSubMenuController.PageUp;
        VK_NEXT: OnSubMenuController.PageDown;
        VK_HOME: OnSubMenuController.HotTrackFirstGroupItem;
        VK_END: OnSubMenuController.HotTrackLastGroupItem;
      end;
    end;

  if not Result then
    Result := inherited HandleNavigationKey(AKey);
end;

function TdxRibbonGalleryControlAccessibilityHelper.IsNavigationKey(
  AKey: Word): Boolean;
begin
  Result := inherited IsNavigationKey(AKey);
  if not Control.Collapsed then
  begin
    if Control.Parent.Kind = bkBarControl then
      Result := Result or (AKey in [VK_RETURN, VK_SPACE, VK_UP, VK_DOWN])
    else
      Result := Result or (AKey in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_TAB,
        VK_PRIOR, VK_NEXT, VK_HOME, VK_END]);
  end;
end;

procedure TdxRibbonGalleryControlAccessibilityHelper.GetKeyTipData(
  AKeyTipsData: TList);
begin
  if not (not Control.Collapsed and (Control.Parent.Kind = bkSubMenu)) then
    inherited GetKeyTipData(AKeyTipsData);
end;

procedure TdxRibbonGalleryControlAccessibilityHelper.GetKeyTipInfo(
  out AKeyTipInfo: TdxBarKeyTipInfo);
var
  R: TRect;
begin
  inherited GetKeyTipInfo(AKeyTipInfo);
  if not Control.Collapsed and (Control.Parent.Kind = bkBarControl) then
  begin
    R := Control.ViewInfo.ScrollBarBounds;
    OffsetRect(R, Control.Parent.ClientOrigin.X, 0);
    AKeyTipInfo.BasePoint.X := cxRectCenter(R).X;
    AKeyTipInfo.HorzAlign := taRightJustify;
  end;
end;

procedure TdxRibbonGalleryControlAccessibilityHelper.OnSubMenuHotTrack(
  ANavigationDirection: TdxRibbonDropDownGalleryNavigationDirection);
begin
  case ANavigationDirection of
    dgndNone:
      if Control.Item.SelectedGroupItem <> nil then
        OnSubMenuController.HotTrackItem(Control.Item.SelectedGroupItem)
      else
        OnSubMenuController.HotTrackFirstGroupItem;
    dgndUp:
      OnSubMenuController.HotTrackLastGroupItem;
    dgndDown:
      OnSubMenuController.HotTrackFirstGroupItem;
  end;
end;

function TdxRibbonGalleryControlAccessibilityHelper.ShowDropDownWindow: Boolean;
begin
  TdxRibbonGalleryControl(ItemControl).DropDown(False);
  Result := ItemControl.IsDroppedDown;
end;

function TdxRibbonGalleryControlAccessibilityHelper.GetControl: TdxRibbonGalleryControl;
begin
  Result := TdxRibbonGalleryControl(FOwnerObject);
end;

function TdxRibbonGalleryControlAccessibilityHelper.GetOnSubMenuController: TdxRibbonOnSubMenuGalleryController;
begin
  if Control.Parent.Kind = bkBarControl then
    raise EdxException.Create('');
  Result := TdxRibbonOnSubMenuGalleryController(Control.Controller);
end;

{ TdxRibbonDropDownGalleryControlAccessibilityHelper }

// IdxBarAccessibilityHelper
function TdxRibbonDropDownGalleryControlAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;

  procedure HandleKeyUp;
  begin
    TdxBarItemLinksAccess(ItemLinks).Last.Control.IAccessibilityHelper.Select(AKey = VK_TAB);
  end;

  procedure HandleKeyDown;
  begin
    InternalGalleryItemControlAccessibilityHelper.Select(False);
    InternalGalleryItemControlAccessibilityHelper.OnSubMenuHotTrack(dgndNone);
  end;

begin
  if BarControl.SelectedControl = nil then
  begin
    Result := True;
    case AKey of
      VK_LEFT, VK_UP:
        if TdxBarItemLinksAccess(ItemLinks).Last = nil then
          HandleKeyDown
        else
          HandleKeyUp;
      VK_RIGHT:
        HandleKeyDown;
      VK_DOWN, VK_PRIOR:
        HandleKeyDown;
      VK_TAB:
        if ssShift in InternalGetShiftState then
          HandleKeyUp
        else
          HandleKeyDown;
      VK_NEXT:
        begin
          InternalGalleryItemControlAccessibilityHelper.Select(False);
          TdxRibbonOnSubMenuGalleryController(BarControl.InternalGalleryItemControl.Controller).PageDown;
        end;
    end;
  end
  else
    Result := inherited HandleNavigationKey(AKey);
end;

function TdxRibbonDropDownGalleryControlAccessibilityHelper.IsNavigationKey(
  AKey: Word): Boolean;
begin
  Result := inherited IsNavigationKey(AKey);
  if BarControl.SelectedControl = nil then
    Result := Result or (AKey in [VK_PRIOR, VK_NEXT]);
end;

procedure TdxRibbonDropDownGalleryControlAccessibilityHelper.HandleVertNavigationKey(
  AUpKey, AFocusItemControl: Boolean);
begin
  if AUpKey and (BarControl.SelectedLink = TdxBarItemLinksAccess(ItemLinks).First) or
    not AUpKey and (BarControl.SelectedLink = TdxBarItemLinksAccess(ItemLinks).Last) then
  begin
    BarNavigationController.ChangeSelectedObject(AFocusItemControl,
      BarControl.InternalGalleryItemControl.IAccessibilityHelper);
    if AUpKey then
      InternalGalleryItemControlAccessibilityHelper.OnSubMenuHotTrack(dgndUp)
    else
      InternalGalleryItemControlAccessibilityHelper.OnSubMenuHotTrack(dgndDown);
  end
  else
    inherited HandleVertNavigationKey(AUpKey, AFocusItemControl);
end;

function TdxRibbonDropDownGalleryControlAccessibilityHelper.GetBarControl: TdxRibbonDropDownGalleryControl;
begin
  Result := TdxRibbonDropDownGalleryControl(FOwnerObject);
end;

function TdxRibbonDropDownGalleryControlAccessibilityHelper.GetInternalGalleryItemControlAccessibilityHelper: TdxRibbonGalleryControlAccessibilityHelper;
begin
  Result := TdxRibbonGalleryControlAccessibilityHelper(
    BarControl.InternalGalleryItemControl.IAccessibilityHelper.GetHelper);
end;

{ TdxRibbonGalleryScrollBarViewInfo }

procedure TdxRibbonGalleryScrollBarViewInfo.CalculateRects;
var
  AArrowButtonHeight: Integer;
begin
  if not TdxRibbonGalleryScrollBar(ScrollBar).IsDropDownStyle then
  begin
    inherited CalculateRects;
    Exit;
  end;
  AArrowButtonHeight := ScrollBar.Height div 3;
  FTopLeftArrowRect := Bounds(0, 0, ScrollBar.Width, AArrowButtonHeight);
  FBottomRightArrowRect := Bounds(0, FTopLeftArrowRect.Bottom, ScrollBar.Width,
    AArrowButtonHeight);
  CalculateThumbnailRect;
  FDropDownButtonRect := Rect(0, FBottomRightArrowRect.Bottom, ScrollBar.Width,
    ScrollBar.Height);
end;

{ TdxRibbonGalleryScrollBar }

constructor TdxRibbonGalleryScrollBar.Create(
  AGalleryControl: TdxRibbonGalleryControl);
var
  ASkinName: string;
begin
  inherited Create(nil);
  Kind := sbVertical;
  FGalleryControl := AGalleryControl;

  if Painter <> nil then
    ASkinName := Painter.Skin.GetName
  else
    ASkinName := '';
  LookAndFeel.SkinName := ASkinName;
  LookAndFeel.NativeStyle := ASkinName = '';

  UnlimitedTracking := True;
end;

function TdxRibbonGalleryScrollBar.IsDropDownStyle: Boolean;
begin
  Result := (Parent <> nil) and (TCustomdxBarControl(Parent).Kind = bkBarControl);
end;

procedure TdxRibbonGalleryScrollBar.DoPaint(ACanvas: TcxCanvas);
var
  ADropDownButtonState: TcxButtonState;
  R: TRect;
begin
  inherited DoPaint(ACanvas);
  if IsDropDownStyle then
  begin
    if not Enabled then
      ADropDownButtonState := cxbsDisabled
    else if ((BarNavigationController.SelectedObject <> nil) and
      (BarNavigationController.SelectedObject.GetHelper = GalleryControl.IAccessibilityHelper.GetHelper) or
      IsDropDownButtonUnderMouse) and not GalleryControl.IsDroppedDown and
      not (FState.HotPart in [sbpLineUp, sbpLineDown]) then
        ADropDownButtonState := cxbsHot
    else
      ADropDownButtonState := cxbsNormal;
    Painter.Skin.DrawBackground(ACanvas.Handle, ViewInfo.DropDownButtonRect,
      DXBAR_INRIBBONGALLERYSCROLLBAR_DROPDOWNBUTTON, GetButtonSkinState(ADropDownButtonState));
  end;
  if (GalleryControl <> nil) and TdxBarItemLinkAccess(GalleryControl.ItemLink).IsComponentSelected then
  begin
    R := ClientRect;
    Dec(R.Left, 2);
    if BarDesignController.NeedDefaultSelection(GalleryControl.ItemLink) then
      dxBarFrameRect(ACanvas.Handle, R, COLOR_WINDOWTEXT)
    else
      dxBarFocusRect(ACanvas.Handle, R);
  end;
end;

procedure TdxRibbonGalleryScrollBar.DrawScrollBarPart(ACanvas: TcxCanvas;
  const R: TRect; APart: TcxScrollBarPart; AState: TcxButtonState);

  function GetButtonKind: TdxInRibbonGalleryScrollBarButtonKind;
  begin
    if APart = sbpLineUp then
      Result := gsbkLineUp
    else
      Result := gsbkLineDown;
  end;

  function GetButtonSkinPart: Integer;
  begin
    case APart of
      sbpLineUp:   Result := DXBAR_INRIBBONGALLERYSCROLLBAR_LINEUPBUTTON;
      sbpLineDown: Result := DXBAR_INRIBBONGALLERYSCROLLBAR_LINEDOWNBUTTON;
    else
      Result := 0;
    end;
  end;

begin
  if IsDropDownStyle then
  begin
    if GetButtonSkinPart = 0 then
      Exit;//raise EdxException.Create('');
    if not IsButtonEnabled(GetButtonKind) then
      AState := cxbsDisabled;

    Painter.Skin.DrawBackground(ACanvas.Handle, R, GetButtonSkinPart,
      GetButtonSkinState(AState));
  end
  else
    inherited DrawScrollBarPart(ACanvas, R, APart, AState);
end;

function TdxRibbonGalleryScrollBar.GetViewInfoClass: TcxScrollBarViewInfoClass;
begin
  Result := TdxRibbonGalleryScrollBarViewInfo;
end;

procedure TdxRibbonGalleryScrollBar.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not IsDropDownButtonUnderMouse then
    TCustomdxBarControlAccess(GalleryControl.Parent).SetKeySelectedItem(nil);
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and IsDropDownButtonUnderMouse then
  begin
    FIsDropDownButtonPressed := True;
    Repaint;
    DoDropDown;
  end;
end;

procedure TdxRibbonGalleryScrollBar.DoDropDown;
begin
  if Assigned(OnDropDown) then
    OnDropDown(Self);
end;

function TdxRibbonGalleryScrollBar.GetButtonSkinState(
  AState: TcxButtonState): Integer;
begin
  case AState of
    cxbsNormal:   Result := DXBAR_NORMAL;
    cxbsHot:      Result := DXBAR_HOT;
    cxbsPressed:  Result := DXBAR_PRESSED;
    cxbsDisabled: Result := DXBAR_DISABLED;
  else
    raise EdxException.Create('')
  end;
end;

function TdxRibbonGalleryScrollBar.GetPainter: TdxBarSkinnedPainter;
begin
  if GalleryControl.IsValidPainter then
    Result := TdxBarSkinnedPainter(GalleryControl.Painter)
  else
    Result := nil;
end;

function TdxRibbonGalleryScrollBar.GetViewInfo: TdxRibbonGalleryScrollBarViewInfo;
begin
  Result := TdxRibbonGalleryScrollBarViewInfo(FViewInfo);
end;

function TdxRibbonGalleryScrollBar.IsButtonEnabled(
  AButtonKind: TdxInRibbonGalleryScrollBarButtonKind): Boolean;
begin
  Result := Enabled;
  if Result then
    case AButtonKind of
      gsbkLineUp:
        Result := GalleryControl.ViewInfo.GetPreviousButtonEnabled;
      gsbkLineDown:
        Result := GalleryControl.ViewInfo.GetNextButtonEnabled;
    end;
end;

function TdxRibbonGalleryScrollBar.IsDropDownButtonUnderMouse: Boolean;
var
  R: TRect;
begin
  Result := HandleAllocated and (WindowFromPoint(GetMouseCursorPos) = Handle);
  if Result then
  begin
    R := ViewInfo.DropDownButtonRect;
    MapWindowRect(Handle, 0, R);
    Result := PtInRect(R, GetMouseCursorPos);
  end;
end;

procedure TdxRibbonGalleryScrollBar.WMCaptureChanged(
  var Message: TMessage);
begin
  inherited;
  FIsDropDownButtonPressed := False;
end;

procedure TdxRibbonGalleryScrollBar.WMNCDestroy(
  var Message: TWMNCDestroy);
begin
  inherited;
  FIsDropDownButtonPressed := False;
end;

{ TdxRibbonDropDownGallery }

destructor TdxRibbonDropDownGallery.Destroy;
begin
  GalleryItem := nil;
  inherited Destroy;
end;

function TdxRibbonDropDownGallery.CreateBarControl: TCustomdxBarControl;
begin
  Result := inherited CreateBarControl;
  if HasValidGalleryItem then
    TdxRibbonDropDownGalleryControl(Result).GalleryItem := GalleryItem;
end;

function TdxRibbonDropDownGallery.GetControlClass: TCustomdxBarControlClass;
begin
  if HasValidGalleryItem then
    Result := TdxRibbonDropDownGalleryControl
  else
    Result := inherited GetControlClass;
end;

function TdxRibbonDropDownGallery.HasValidGalleryItem: Boolean;
begin
  Result := (GalleryItem <> nil) and (Ribbon <> nil) and
    (GalleryItem.BarManager = Ribbon.BarManager);
end;

procedure TdxRibbonDropDownGallery.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = GalleryItem) then
    GalleryItem := nil;
end;

procedure TdxRibbonDropDownGallery.SetGalleryItem(
  Value: TdxRibbonGalleryItem);
begin
  if Value <> FGalleryItem then
  begin
    if FGalleryItem <> nil then
      FGalleryItem.RemoveFreeNotification(Self);
    FGalleryItem := Value;
    if FGalleryItem <> nil then
      FGalleryItem.FreeNotification(Self);
  end;
end;

{ TdxRibbonDropDownGalleryGalleryItemItemLinks }

function TdxRibbonDropDownGalleryGalleryItemItemLinks.CanContainItem(
  AItem: TdxBarItem; out AErrorText: string): Boolean;
begin
  Result := True;
end;

{ TdxRibbonDropDownGalleryControlPainter }

function TdxRibbonDropDownGalleryControlPainter.GetSizingBandHeight(
  AGalleryControl: TdxRibbonDropDownGalleryControl): Integer;
var
  AButtonHeight: Integer;
begin
  Result := 0;
  if HasSizingBand(AGalleryControl) then
  begin
    AButtonHeight := GetGroupRowHeight(AGalleryControl.BarManager.ImageOptions.GlyphSize,
      AGalleryControl.Font);
    case AGalleryControl.Resizing of
      gsrHeight:
        Result := (AButtonHeight * 6 + 100) div 29;
      gsrWidthAndHeight:
        Result := (AButtonHeight * 9 + 121) div 29;
    end;
  end;
end;

function TdxRibbonDropDownGalleryControlPainter.PtInSizingArea(
  AGalleryControl: TdxRibbonDropDownGalleryControl; const P: TPoint): Boolean;
var
  AOffsetX: Integer;
  R: TRect;
begin
  Result := False;
  if AGalleryControl.IsSizingBandAtBottom then
  begin
    case AGalleryControl.Resizing of
      gsrHeight:
        begin
          R := Rect(0, 0, AGalleryControl.Width, AGalleryControl.Height);
          R.Top := R.Bottom - (GetSizingBandHeight(AGalleryControl) + SubMenuControlNCBorderSize);
          Result := PtInRect(R, P);
        end;
      gsrWidthAndHeight:
        begin
          AOffsetX := P.X - (AGalleryControl.Width - GetSizingBandHeight(AGalleryControl));
          Result := (AOffsetX >= 0) and (P.Y < AGalleryControl.Height) and
            (AGalleryControl.Height - 1 - P.Y <= AOffsetX);
        end;
    end;
  end
  else
  begin
    case AGalleryControl.Resizing of
      gsrHeight:
        begin
          R := Rect(0, 0, AGalleryControl.Width, AGalleryControl.Height);
          R.Bottom := R.Top + (GetSizingBandHeight(AGalleryControl) + SubMenuControlNCBorderSize);
          Result := PtInRect(R, P);
        end;
      gsrWidthAndHeight:
        begin
          AOffsetX := P.X - (AGalleryControl.Width - GetSizingBandHeight(AGalleryControl) - 1);
          Result := (AOffsetX >= 0) and (P.Y >= 0) and (P.Y <= AOffsetX);
        end;
    end;
  end;
end;

procedure TdxRibbonDropDownGalleryControlPainter.SubMenuControlDrawBorder(
  ABarSubMenuControl: TdxBarSubMenuControl; DC: HDC; R: TRect);
const
  ASizeGripParts: array[Boolean] of Integer =
    (DXBAR_DROPDOWNGALLERY_TOPSIZEGRIP, DXBAR_DROPDOWNGALLERY_BOTTOMSIZEGRIP);
  ASizingBandParts: array[Boolean] of Integer =
    (DXBAR_DROPDOWNGALLERY_TOPSIZINGBAND, DXBAR_DROPDOWNGALLERY_BOTTOMSIZINGBAND);
  AVerticalSizeGripParts: array[Boolean] of Integer =
    (DXBAR_DROPDOWNGALLERY_TOPVERTICALSIZEGRIP, DXBAR_DROPDOWNGALLERY_BOTTOMVERTICALSIZEGRIP);
var
  ABorderSize: Integer;
  AIsSizingBandAtBottom: Boolean;
begin
  inherited SubMenuControlDrawBorder(ABarSubMenuControl, DC, R);
  if HasSizingBand(TdxRibbonDropDownGalleryControl(ABarSubMenuControl)) then
  begin
    AIsSizingBandAtBottom := TdxRibbonDropDownGalleryControl(ABarSubMenuControl).IsSizingBandAtBottom;
    ABorderSize := SubMenuControlNCBorderSize;
    InflateRect(R, -ABorderSize, -ABorderSize);
    if AIsSizingBandAtBottom then
      R.Top := R.Bottom - GetSizingBandHeight(TdxRibbonDropDownGalleryControl(ABarSubMenuControl))
    else
      R.Bottom := R.Top + GetSizingBandHeight(TdxRibbonDropDownGalleryControl(ABarSubMenuControl));
    Skin.DrawBackground(DC, R, ASizingBandParts[AIsSizingBandAtBottom]);
    case TdxRibbonDropDownGalleryControl(ABarSubMenuControl).Resizing of
      gsrHeight:
        Skin.DrawBackground(DC, R, AVerticalSizeGripParts[AIsSizingBandAtBottom]);
      gsrWidthAndHeight:
        Skin.DrawBackground(DC, R, ASizeGripParts[AIsSizingBandAtBottom]);
    end;
  end;
end;

function TdxRibbonDropDownGalleryControlPainter.HasSizingBand(
  AGalleryControl: TdxRibbonDropDownGalleryControl): Boolean;
begin
  Result := AGalleryControl.Resizing <> gsrNone;
end;

{ TdxRibbonDropDownGalleryControl }

constructor TdxRibbonDropDownGalleryControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
end;

destructor TdxRibbonDropDownGalleryControl.Destroy;
begin
  FreeAndNil(FGalleryItemItemLinks);
  FreeAndNil(FInternalPainter);
  inherited Destroy;
end;

procedure TdxRibbonDropDownGalleryControl.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  FHeight := AHeight;
  FUseInternalSizeValue := True;
  try
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  finally
    FUseInternalSizeValue := False;
  end;
end;

procedure TdxRibbonDropDownGalleryControl.CalcColumnItemRects(
  ATopIndex: Integer; out ALastItemBottom: Integer);
var
  AGalleryHeight, I: Integer;
begin
  inherited CalcColumnItemRects(ATopIndex, ALastItemBottom);
  if ItemLinks.VisibleItemCount > 0 then
  begin
    for I := 0 to ItemLinks.Count - 1 do
      ItemLinks[I].ItemRect := cxRectOffset(ItemLinks[I].ItemRect, 0,
        VisibleItemsRect.Bottom - ALastItemBottom);
    AGalleryHeight := VisibleItemsRect.Bottom - ALastItemBottom;
  end
  else
    AGalleryHeight := cxRectHeight(VisibleItemsRect);
  FGalleryItemItemLinks[0].ItemRect := cxRectSetHeight(VisibleItemsRect, AGalleryHeight);
  InternalGalleryItemControl.SizeChanged := False;
end;

function TdxRibbonDropDownGalleryControl.ChangeSizeByChildItemControl(
  out ASize: TSize): Boolean;
begin
  Result := False;
  ASize := cxNullSize;
  if InternalGalleryItemControl.Item.GalleryOptions.FSubMenuResizing = gsrNone then
  begin
    InternalGalleryItemControl.LockCalcParts := True;
    try
      CalcControlsPositions;
    finally
      InternalGalleryItemControl.LockCalcParts := False;
    end;
    if (InternalGalleryItemControl.GetDefaultWidthInSubMenu > Width) and
      (Screen.Width >
      Width + InternalGalleryItemControl.ViewInfo.GetScrollBarWidth) then
    begin
      ASize.cx := Width + InternalGalleryItemControl.ViewInfo.GetScrollBarWidth;
      ASize.cy := Height;
      Result := True;
    end;
  end;
end;

procedure TdxRibbonDropDownGalleryControl.CreateWnd;
begin
  if FGalleryItemItemLinks = nil then
    FGalleryItemItemLinks := TdxRibbonDropDownGalleryGalleryItemItemLinks.Create(
      BarManager, TdxBarItemLinksAccess(ItemLinks).LinksOwner);
  FGalleryItemItemLinks.Internal := True;
  FGalleryItemItemLinks.BarControl := Self;
  FGalleryItemItemLinks.Add.Item := GalleryItem;
  FGalleryItemItemLinks[0].CreateControl;
  InternalGalleryItemControl.Collapsed := False;
  inherited CreateWnd;
end;

function TdxRibbonDropDownGalleryControl.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  InternalGalleryItemControl.SetScrollBarPosition(
    InternalGalleryItemControl.ScrollBar.Position + GetMouseWheelStep);
end;

function TdxRibbonDropDownGalleryControl.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
  InternalGalleryItemControl.SetScrollBarPosition(
    InternalGalleryItemControl.ScrollBar.Position - GetMouseWheelStep);
end;

procedure TdxRibbonDropDownGalleryControl.DoNCPaint(DC: HDC; const ARect: TRect);
begin
  InternalPainter.SubMenuControlDrawBorder(Self, DC, ARect);
end;

function TdxRibbonDropDownGalleryControl.DoFindLinkWithAccel(AKey: Word;
  AShift: TShiftState; ACurrentLink: TdxBarItemLink): TdxBarItemLink;
begin
  if (ACurrentLink <> nil) and (ACurrentLink.Control <> nil) and
    (ACurrentLink.Control = InternalGalleryItemControl) then
    Result := nil
  else
    Result := inherited DoFindLinkWithAccel(AKey, AShift, ACurrentLink);
end;

function TdxRibbonDropDownGalleryControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonDropDownGalleryControlAccessibilityHelper;
end;

function TdxRibbonDropDownGalleryControl.GetClientOffset(
  AIncludeDetachCaption: Boolean = True): TRect;
begin
  Result := inherited GetClientOffset(AIncludeDetachCaption);
  if Resizing <> gsrNone then
    if IsSizingBandAtBottom then
      Inc(Result.Bottom, InternalPainter.GetSizingBandHeight(Self))
    else
      Inc(Result.Top, InternalPainter.GetSizingBandHeight(Self))
end;

function TdxRibbonDropDownGalleryControl.GetItemsPaneSize: TSize;
begin
  Result := inherited GetItemsPaneSize;
  Result.cx := Max(Result.cx, InternalGalleryItemControl.Width);
  Inc(Result.cy, InternalGalleryItemControl.Height);
end;

function TdxRibbonDropDownGalleryControl.GetMinSize: TSize;
var
  I: Integer;
  AItemsHeight: Integer;
  AClientOffset: TRect;
begin
  Result := InternalGalleryItemControl.ViewInfo.GetMinSize;
  AItemsHeight := 0;
  for I := 0 to ItemLinks.VisibleItemCount - 1 do
    AItemsHeight := AItemsHeight + ItemLinks[I].ItemRect.Bottom -
      ItemLinks[I].ItemRect.Top;
  AClientOffset := GetClientOffset;
  Result.cx := Result.cx + AClientOffset.Left + AClientOffset.Right;
  Result.cy := Result.cy + AItemsHeight + AClientOffset.Top +
    AClientOffset.Bottom;
end;

function TdxRibbonDropDownGalleryControl.GetViewInfoClass: TCustomdxBarControlViewInfoClass;
begin
  Result := TdxRibbonDropDownGalleryControlViewInfo;
end;

function TdxRibbonDropDownGalleryControl.IsControlExists(
  ABarItemControl: TdxBarItemControl): Boolean;
begin
  Result := (ABarItemControl = InternalGalleryItemControl) or
    inherited IsControlExists(ABarItemControl);
end;

function TdxRibbonDropDownGalleryControl.IsSizingBandAtBottom: Boolean;
begin
  Result := Top + IfThen(FUseInternalSizeValue, FHeight, Height) > OnShowTop;
end;

procedure TdxRibbonDropDownGalleryControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if IsResizing then
    DoResizing
  else
    inherited;
end;

function TdxRibbonDropDownGalleryControl.MustFitInWorkAreaWidth: Boolean;
begin
  Result := True;
end;

function TdxRibbonDropDownGalleryControl.NeedsMouseWheel: Boolean;
begin
  Result := (SelectedControl = InternalGalleryItemControl) and
    InternalGalleryItemControl.IsNeedScrollBar;
end;

function TdxRibbonDropDownGalleryControl.NeedsSelectFirstItemOnDropDownByKey: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonDropDownGalleryControl.Resize;
begin
  InternalGalleryItemControl.SizeChanged := True;
end;

procedure TdxRibbonDropDownGalleryControl.UpdateItem(AControl: TdxBarItemControl);
begin
  cxInvalidateRect(Handle, GetItemRect(AControl), False);
end;

procedure TdxRibbonDropDownGalleryControl.DoResizing;

  procedure SetSize(const ARect: TRect; DontChangeOrigin: Boolean);
  var
    AMinSize: TSize;
    AFlags: Cardinal;
    ANewRect: TRect;
  begin
    ANewRect := ARect;
    AMinSize := GetMinSize;
    if ANewRect.Right - ANewRect.Left < AMinSize.cx then
      ANewRect.Right := ANewRect.Left + AMinSize.cx;
    if ANewRect.Bottom - ANewRect.Top < AMinSize.cy then
      if DontChangeOrigin then
        ANewRect.Bottom := ANewRect.Top + AMinSize.cy
      else
        ANewRect.Top := ANewRect.Bottom - AMinSize.cy;
    AFlags := SWP_NOZORDER or SWP_NOACTIVATE;
    if DontChangeOrigin then
      AFlags := SWP_NOMOVE or AFlags;
    SetWindowPos(Handle, 0, ANewRect.Left, ANewRect.Top,
      ANewRect.Right - ANewRect.Left, ANewRect.Bottom - ANewRect.Top, AFlags);
  end;

var
  R: TRect;
  P: TPoint;
begin
  R := WindowRect;
  P := GetMouseCursorPos;
  case FResizingState of
    grsBottom: SetSize(Rect(R.Left, R.Top, R.Right,
                 P.Y + FMouseResizingDelta.Y), True);
    grsBottomRight: SetSize(Rect(R.Left, R.Top, P.X + FMouseResizingDelta.X,
                      P.Y + FMouseResizingDelta.Y), True);
    grsTop: SetSize(Rect(R.Left, P.Y + FMouseResizingDelta.Y, R.Right,
              R.Bottom), False);
    grsTopRight: SetSize(Rect(R.Left, P.Y + FMouseResizingDelta.Y,
                   P.X + FMouseResizingDelta.X, R.Bottom), False);
  end;
  UpdateWindow(Handle);

end;

function TdxRibbonDropDownGalleryControl.GetInternalGalleryItemControl: TdxRibbonGalleryControl;
begin
  Result := TdxRibbonGalleryControl(FGalleryItemItemLinks[0].Control);
end;

function TdxRibbonDropDownGalleryControl.GetInternalPainter: TdxRibbonDropDownGalleryControlPainter;
begin
  if FInternalPainter = nil then
    FInternalPainter := TdxRibbonDropDownGalleryControlPainter.Create(
      Integer(TdxRibbonBarPainter(Painter).SkinnedObject));
  Result := FInternalPainter;
end;

function TdxRibbonDropDownGalleryControl.GetMouseWheelStep: Integer;
begin
  Result := IfThen(FMouseWheelStep = 0,
    InternalGalleryItemControl.GetMouseWheelStep, FMouseWheelStep);
end;

function TdxRibbonDropDownGalleryControl.GetResizing: TdxRibbonGallerySubMenuResizing;
begin
  if FIsResizingAssigned then
    Result := FResizing
  else
    Result := GalleryItem.GalleryOptions.SubMenuResizing;
end;

function TdxRibbonDropDownGalleryControl.HitTestToResizingState: TdxDropDownGalleryResizingState;
begin
  case FHitTest of
    HTTOP: Result := grsTop;
    HTTOPRIGHT: Result := grsTopRight;
    HTBOTTOM: Result := grsBottom;
    HTBOTTOMRIGHT: Result := grsBottomRight;
  else
    Result := grsNone;
  end;
end;

function TdxRibbonDropDownGalleryControl.IsHitTestResizing: Boolean;
begin
  Result := FHitTest <> HTNOWHERE;
end;

function TdxRibbonDropDownGalleryControl.IsResizing: Boolean;
begin
  Result := FResizingState <> grsNone;
end;

procedure TdxRibbonDropDownGalleryControl.SetResizing(
  Value: TdxRibbonGallerySubMenuResizing);
begin
  FIsResizingAssigned := True;
  FResizing := Value;
end;

procedure TdxRibbonDropDownGalleryControl.StartResizing;
var
  R: TRect;
  P: TPoint;
begin
  R := WindowRect;
  P := GetMouseCursorPos;
  case FHitTest of
    HTTOP, HTTOPRIGHT:
      begin
        FMouseResizingDelta.X := R.Right - P.X;
        FMouseResizingDelta.Y := R.Top - P.Y;
      end;
    HTBOTTOM, HTBOTTOMRIGHT:
      begin
        FMouseResizingDelta.X := R.Right - P.X;
        FMouseResizingDelta.Y := R.Bottom - P.Y;
      end;
  end;
  FResizingState := HitTestToResizingState;
  SetCapture(Handle);
end;

procedure TdxRibbonDropDownGalleryControl.StopResizing;
begin
  FResizingState := grsNone;
  ReleaseCapture;
end;

procedure TdxRibbonDropDownGalleryControl.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  S: TSize;
begin
  with Message.MinMaxInfo^, Constraints do
  begin
    S := GetMinSize;
    with ptMinTrackSize do
    begin
      X := S.cx;
      Y := S.cy;
    end;
  end;
  inherited;
end;

procedure TdxRibbonDropDownGalleryControl.WMNCHitTest(var Message: TWMNCHitTest);
const
  ANCHitTestConsts: array[Boolean, gsrHeight..gsrWidthAndHeight] of Longint = (
    (HTTOP, HTTOPRIGHT),
    (HTBOTTOM, HTBOTTOMRIGHT)
  );
begin
  inherited;
  if (Resizing <> gsrNone) and InternalPainter.PtInSizingArea(Self,
    cxPointOffset(SmallPointToPoint(Message.Pos), -Left, -Top)) then
    FHitTest := ANCHitTestConsts[IsSizingBandAtBottom, Resizing]
  else
    FHitTest := HTNOWHERE;
  Message.result := HTCLIENT;
end;

procedure TdxRibbonDropDownGalleryControl.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if IsHitTestResizing then
    StartResizing
  else
    inherited;
end;

procedure TdxRibbonDropDownGalleryControl.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if IsResizing then
    StopResizing
  else
    inherited;
end;

procedure TdxRibbonDropDownGalleryControl.WMSetCursor(var Message: TWMSetCursor);
begin
  case FHitTest of
    HTTOP, HTTOPRIGHT, HTBOTTOM, HTBOTTOMRIGHT:
      Message.HitTest := FHitTest;
  end;
  inherited;
end;

{ TdxRibbonDropDownGalleryControlViewInfo }

procedure TdxRibbonDropDownGalleryControlViewInfo.Calculate;
var
  AGalleryItemControl: TdxRibbonGalleryControl;
begin
  inherited Calculate;
  AGalleryItemControl := BarControl.InternalGalleryItemControl;
  AddItemControlViewInfo(AGalleryItemControl.ViewInfo);
  IdxBarItemControlViewInfo(AGalleryItemControl.ViewInfo).SetBounds(
    BarControl.GetItemRect(AGalleryItemControl));
end;

function TdxRibbonDropDownGalleryControlViewInfo.GetBarControl: TdxRibbonDropDownGalleryControl;
begin
  Result := TdxRibbonDropDownGalleryControl(FBarControl);
end;

{ TdxRibbonGalleryGroupItemActionLink }

procedure TdxRibbonGalleryGroupItemActionLink.AssignClient(AClient: TObject);
begin
  FClient := AClient as TdxRibbonGalleryGroupItem;
end;

function TdxRibbonGalleryGroupItemActionLink.IsCaptionLinked: Boolean;
begin
  Result := inherited IsCaptionLinked and
    (FClient.Caption = (Action as TCustomAction).Caption);
end;

function TdxRibbonGalleryGroupItemActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and
    (FClient.Selected = (Action as TCustomAction).Checked);
end;

function TdxRibbonGalleryGroupItemActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked and
    (FClient.ImageIndex = (Action as TCustomAction).ImageIndex);
end;

function TdxRibbonGalleryGroupItemActionLink.IsOnExecuteLinked: Boolean;
begin
  Result := inherited IsOnExecuteLinked and
    (@FClient.OnClick = @Action.OnExecute);
end;

procedure TdxRibbonGalleryGroupItemActionLink.SetCaption(const Value: string);
begin
  if IsCaptionLinked then FClient.Caption := Value;
end;

procedure TdxRibbonGalleryGroupItemActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then FClient.Selected := Value;
end;

procedure TdxRibbonGalleryGroupItemActionLink.SetImageIndex(Value: Integer);
begin
  if IsImageIndexLinked then FClient.ImageIndex := Value;
end;

procedure TdxRibbonGalleryGroupItemActionLink.SetOnExecute(Value: TNotifyEvent);
begin
  if IsOnExecuteLinked then FClient.OnClick := Value;
end;

initialization
  RegisterClasses([TdxRibbonDropDownGallery]);
  dxBarRegisterItem(TdxRibbonGalleryItem, TdxRibbonGalleryControl, True);

finalization
  dxBarUnregisterItem(TdxRibbonGalleryItem);
end.
