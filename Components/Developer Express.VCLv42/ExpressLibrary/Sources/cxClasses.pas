{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
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

unit cxClasses;

{$I cxVer.inc}

interface

uses
  Windows, Messages, ShellAPI, TypInfo, SysUtils, Classes, Forms, Contnrs, dxCore;

const
  dxBuildNumber = 42;
  WM_DX = WM_APP + 100;

  dxEndOfLine = #13#10;
  cxE_NOINTERFACE = HResult($80004002);

type
  TcxAlignmentVert = (vaTop, vaBottom, vaCenter);
  TcxTopBottom = vaTop..vaBottom;
  TcxCollectionOperation = (copAdd, copDelete, copChanged);
  TcxDirection = (dirNone, dirLeft, dirRight, dirUp, dirDown);
  TcxGetComponent = function(ACaller: TComponent; Index: Integer): TComponent;
  TcxGetCaptionForIntegerItemFunc = function(AItem: Integer): string;
  TcxPosition = (posNone, posLeft, posRight, posTop, posBottom);
  TdxSkinName = type string;

{$IFNDEF DELPHI5}
  TImageIndex = Integer;
{$ENDIF}

  TcxTag = Longint;

  TcxResourceStringID = Pointer;

  IcxDesignSelectionChanged = interface
  ['{66B3AA59-1EBD-4135-AB18-E980F9C970F3}']
    procedure DesignSelectionChanged(ASelection: TList);
  end;

  IcxDesignHelper = interface
  ['{4C78CC4F-699B-43BD-94AC-E3BD2233F7A1}']
    procedure AddSelectionChangedListener(AObject: TPersistent);
    function CanAddComponent(AOwner: TComponent): Boolean;
    function CanDeleteComponent(AOwner: TComponent; AComponent: TComponent): Boolean;
    procedure ChangeSelection(AOwner: TComponent; AObject: TPersistent);
    function IsObjectSelected(AOwner: TComponent; AObject: TPersistent): Boolean;
    procedure Modified;
    procedure RemoveSelectionChangedListener(AObject: TPersistent);
    procedure SelectObject(AOwner: TComponent; AObject: TPersistent; AClearSelection: Boolean = True;
      AActivateOwner: Boolean = True);
    procedure ShowComponentDefaultEventHandler(AComponent: TComponent);
    function UniqueName(const ABaseName: string): string;
    procedure UnselectObject(AOwner: TComponent; AObject: TPersistent);
  end;

  { TcxIUnknownObject }

  TcxIUnknownObject = class(TObject, IUnknown)
  protected
    // IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  { TcxInterfacedPersistent }

  TcxInterfacedPersistentClass = class of TcxInterfacedPersistent;

  TcxInterfacedPersistent = class({$IFDEF DELPHI6}TInterfacedPersistent{$ELSE}TPersistent, IUnknown{$ENDIF})
  private
    FOwner: TPersistent;
  {$IFNDEF DELPHI6}
    FOwnerInterface: IUnknown;
  {$ENDIF}
  protected
    function GetOwner: TPersistent; override;
  {$IFNDEF DELPHI6}
    { IUnknown }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
  {$ENDIF}
  public
    constructor Create(AOwner: TPersistent); virtual;
  {$IFNDEF DELPHI6}
    procedure AfterConstruction; override;
  {$ENDIF}
    property Owner: TPersistent read FOwner;
  end;

  { TcxOwnedPersistent }

  TcxOwnedPersistent = class(TPersistent)
  private
    FOwner: TPersistent;
  protected
    function GetOwner: TPersistent; override;
    property Owner: TPersistent read FOwner write FOwner;
  public
    constructor Create(AOwner: TPersistent); virtual;
  end;

  { TcxOwnedInterfacedPersistent }
  
  TcxOwnedInterfacedPersistent = class(TcxOwnedPersistent, IUnknown)
  protected
    // IUnknown
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
  end;

  { TcxComponent}

  TcxComponent = class(TComponent{$IFNDEF DELPHI6}, IUnknown{$ENDIF})
  private
    FFakeComponentLink1: TComponent;
    FFakeComponentLink2: TComponent;
    FFakeComponentLink3: TComponent;
    function GetFakeComponentLinkCount: Integer;
    function GetIsDesigning: Boolean;
    function GetIsDestroying: Boolean;
    procedure SetFakeComponentLink(Index: Integer; Value: TComponent);
  protected
    procedure GetFakeComponentLinks(AList: TList); virtual;
    procedure Loaded; override;
    procedure UpdateFakeLinks;
  public
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    property IsDesigning: Boolean read GetIsDesigning;
    property IsDestroying: Boolean read GetIsDestroying;
  published
    property FakeComponentLink1: TComponent read FFakeComponentLink1 write FFakeComponentLink1 stored False;
    property FakeComponentLink2: TComponent read FFakeComponentLink2 write FFakeComponentLink2 stored False;
    property FakeComponentLink3: TComponent read FFakeComponentLink3 write FFakeComponentLink3 stored False;
  end;

  { TcxInterfacedCollectionItem }

  TcxInterfacedCollectionItem = class(TCollectionItem, IUnknown)
  private
    FOwnerInterface: IUnknown;
  protected
    // IUnknown
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
  public
    procedure AfterConstruction; override;
  end;

  { TcxCollection }

  TcxCollection = class(TCollection)
  public
    procedure Assign(Source: TPersistent); override;
  {$IFNDEF DELPHI6}
    function Owner: TPersistent;
  {$ENDIF}
  end;

  { TcxOwnedInterfacedCollection }

  TcxCollectionNotifyEvent = procedure (Sender: TObject; AItem: TCollectionItem) of Object;

  TcxOwnedInterfacedCollection = class(TOwnedCollection, IUnknown)
  private
    FIsDestroying: Boolean;
    FOnChange: TcxCollectionNotifyEvent;
  protected
    procedure Update(Item: TCollectionItem); override;

    //  IUnknown
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    property IsDestroying: Boolean read FIsDestroying;
  public
    destructor Destroy; override;

    property OnChange: TcxCollectionNotifyEvent read FOnChange write FOnChange;
  end;

  { TcxObjectList }

  TcxObjectList = class(TList)
  private
    function GetItem(Index: Integer): TObject;
  public
    procedure Clear; override;
    property Items[Index: Integer]: TObject read GetItem; default;
  end;

  { TcxEventHandlerCollection }

  TcxEventHandler = procedure (Sender: TObject; const AEventArgs) of object;

  TcxEventHandlerCollection = class(TObject)
  private
    FEvents: array of TcxEventHandler;
    procedure Delete(AIndex: Integer);
    function IndexOf(AEvent: TcxEventHandler): Integer;
  public
    procedure Add(AEvent: TcxEventHandler);
    procedure CallEvents(Sender: TObject; const AEventArgs);
    procedure Remove(AEvent: TcxEventHandler);
  end;  

  { TcxRegisteredClassList }

  TcxRegisteredClassListItemData = class
    ItemClass: TClass;
    RegisteredClass: TClass;
  end;

  TcxRegisteredClassList = class
  private
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxRegisteredClassListItemData;
  protected
    function Find(AItemClass: TClass; var AIndex: Integer): Boolean; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function FindClass(AItemClass: TClass): TClass;
    procedure Register(AItemClass, ARegisteredClass: TClass); virtual;
    procedure Unregister(AItemClass, ARegisteredClass: TClass); virtual;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TcxRegisteredClassListItemData read GetItem; default;
  end;

  { TcxRegisteredClasses } // TODO: Name

  TcxRegisteredClasses = class
  private
    FItems: TStringList;
    FRegisterClasses: Boolean;
    FSorted: Boolean;
    function GetCount: Integer;
    function GetDescription(Index: Integer): string;
    function GetHint(Index: Integer): string;
    function GetItem(Index: Integer): TClass;
    procedure SetSorted(Value: Boolean);
  protected
    function CompareItems(AIndex1, AIndex2: Integer): Integer; virtual;
    procedure Sort; virtual;
  public
    constructor Create(ARegisterClasses: Boolean = False);
    destructor Destroy; override;
    procedure Clear;
    function FindByClassName(const AClassName: string): TClass;
    function FindByDescription(const ADescription: string): TClass;
    function GetDescriptionByClass(AClass: TClass): string;
    function GetHintByClass(AClass: TClass): string;
    function GetIndexByClass(AClass: TClass): Integer;
    procedure Register(AClass: TClass; const ADescription: string);
    procedure Unregister(AClass: TClass);
    property Count: Integer read GetCount;
    property Descriptions[Index: Integer]: string read GetDescription;
    property Hints[Index: Integer]: string read GetHint;
    property Items[Index: Integer]: TClass read GetItem; default;
    property RegisterClasses: Boolean read FRegisterClasses write FRegisterClasses;
    property Sorted: Boolean read FSorted write SetSorted; 
  end;

  { TcxAutoWidthObject }

  TcxAutoWidthItem = class
  public
    MinWidth: Integer;
    Width: Integer;
    Fixed: Boolean;
    AutoWidth: Integer;
    constructor Create;
  end;

  TcxAutoWidthObject = class
  private
    FAvailableWidth: Integer;
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxAutoWidthItem;
    function GetWidth: Integer;
  protected
    procedure Clear;
  public
    constructor Create(ACount: Integer);
    destructor Destroy; override;
    function AddItem: TcxAutoWidthItem;
    procedure Calculate;
    property AvailableWidth: Integer read FAvailableWidth write FAvailableWidth;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TcxAutoWidthItem read GetItem; default;
    property Width: Integer read GetWidth;
  end;

  { TcxAlignment }

  TcxAlignment = class(TPersistent)
  private
    FDefaultHorz: TAlignment;
    FDefaultVert: TcxAlignmentVert;
    FHorz: TAlignment;
    FIsHorzAssigned: Boolean;
    FIsVertAssigned: Boolean;
    FOwner: TPersistent;
    FUseAssignedValues: Boolean;
    FVert: TcxAlignmentVert;
    FOnChanged: TNotifyEvent;
    function IsHorzStored: Boolean;
    function IsVertStored: Boolean;
    procedure SetHorz(const Value: TAlignment);
    procedure SetVert(const Value: TcxAlignmentVert);
  protected
    procedure DoChanged;
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent; AUseAssignedValues: Boolean = False;
      ADefaultHorz: TAlignment = taLeftJustify;
      ADefaultVert: TcxAlignmentVert = vaTop); virtual;
    procedure Assign(Source: TPersistent); override;
    procedure Reset;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property Horz: TAlignment read FHorz write SetHorz stored IsHorzStored;
    property Vert: TcxAlignmentVert read FVert write SetVert stored IsVertStored;
  end;

  { Object Links }

  TcxObjectLink = class
    Ref: TObject;
  end;

  TcxObjectLinkController = class
  private
    FLinks: TList;
  public
    constructor Create;
    destructor Destroy; override;

    function AddLink(AObject: TObject): TcxObjectLink;
    procedure RemoveLink(ALink: TcxObjectLink);
    procedure ClearLinks(AObject: TObject);
  end;

  { TcxFreeNotificator }

  TcxFreeNotificationEvent = procedure(Sender: TComponent) of object;

  TcxFreeNotificator = class(TComponent)
  private
    FOnFreeNotification: TcxFreeNotificationEvent;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure AddSender(ASender: TComponent);
    procedure RemoveSender(ASender: TComponent);
    property OnFreeNotification: TcxFreeNotificationEvent read FOnFreeNotification write FOnFreeNotification;
  end;

  { MRU items support }

  TcxMRUItemClass = class of TcxMRUItem;

  TcxMRUItem = class
  public
    function Equals(AItem: TcxMRUItem): Boolean; {$IFDEF DELPHI12}reintroduce; {$ENDIF} virtual; abstract;
  end;

  TcxMRUItems = class
  private
    FItems: TList;
    FMaxCount: Integer;
    function GetCount: Integer;
    function GetItem(Index: Integer): TcxMRUItem;
    procedure SetCount(Value: Integer);
    procedure SetMaxCount(Value: Integer);
  protected
    procedure Delete(AIndex: Integer);
    procedure UpdateCount;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(AItem: TcxMRUItem);
    procedure ClearItems;
    function IndexOf(AItem: TcxMRUItem): Integer;

    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: TcxMRUItem read GetItem; default;
    property MaxCount: Integer read FMaxCount write SetMaxCount;
  end;

  { Open list }

  TcxOpenList = class(TList)
  private
    function GetItem(Index: Integer): TObject;
    procedure SetItem(Index: Integer; Value: TObject);
  public
    property Items[Index: Integer]: TObject read GetItem write SetItem; default;
  end;

  { TcxComponentCollectionItem }

  TcxComponentCollection = class;

  TcxComponentCollectionItem = class(TComponent)
  private
    FCollection: TcxComponentCollection;
    FID: Integer;
    procedure AddToCollection(ACollection: TcxComponentCollection);
    function GetIndex: Integer;
    procedure RemoveFromCollection(ACollection: TcxComponentCollection);
  protected
    procedure Changed(AAllItems: Boolean);
    function GetCollectionFromParent(AParent: TComponent): TcxComponentCollection; virtual; abstract;
    function GetDisplayName: string; virtual;
    procedure SetCollection(AValue: TcxComponentCollection); virtual;
    procedure SetIndex(AValue: Integer); virtual;
  public
    destructor Destroy; override;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    procedure SetParentComponent(Value: TComponent); override;

    property Collection: TcxComponentCollection read FCollection write SetCollection;
    property DisplayName: string read GetDisplayName;
    property ID: Integer read FID;
    property Index: Integer read GetIndex write SetIndex;
  end;

  TcxComponentCollectionItemClass = class of TcxComponentCollectionItem;

  { TcxComponentCollection }

  TcxComponentCollectionNotification = (ccnAdded, ccnChanged, ccnExtracting, ccnExtracted, ccnDeleting);
  TcxComponentCollectionChangeEvent = procedure(Sender: TObject;
    AItem: TcxComponentCollectionItem; AAction: TcxComponentCollectionNotification) of object;

  TcxComponentCollection = class(TPersistent)
  private
    FItemClass: TcxComponentCollectionItemClass;
    FItems: TList;
    FNextID: Integer;
    FParentComponent: TComponent;
    FUpdateCount: Integer;
    FOnChange: TcxComponentCollectionChangeEvent;
    function GetCount: Integer;
    procedure InsertItem(AItem: TcxComponentCollectionItem);
    procedure RemoveItem(AItem: TcxComponentCollectionItem);
  protected
    procedure Changed(AItem: TcxComponentCollectionItem = nil;
      AAction: TcxComponentCollectionNotification = ccnChanged);
    function GetItem(AIndex: Integer): TcxComponentCollectionItem;
    function GetOwner: TPersistent; override;
    procedure Notify(AItem: TcxComponentCollectionItem;
      AAction: TcxComponentCollectionNotification); virtual;
    procedure SetItem(AIndex: Integer; Value: TcxComponentCollectionItem);
    procedure SetItemName(AItem: TcxComponentCollectionItem); virtual;
    procedure Update(AItem: TcxComponentCollectionItem;
      AAction: TcxComponentCollectionNotification); virtual;

    property NextID: Integer read FNextID;
    property UpdateCount: Integer read FUpdateCount;
  public
    constructor Create(AParentComponent: TComponent; AItemClass: TcxComponentCollectionItemClass); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add: TcxComponentCollectionItem;
    procedure BeginUpdate; virtual;
    procedure Clear;
    procedure Delete(AIndex: Integer);
    procedure EndUpdate(AForceUpdate: Boolean = True); virtual;
    function FindItemByID(ID: Integer): TcxComponentCollectionItem;
    function Insert(AIndex: Integer): TcxComponentCollectionItem;
    procedure Remove(AItem: TcxComponentCollectionItem);

    property Count: Integer read GetCount;
    property ParentComponent: TComponent read FParentComponent;
    property Items[AIndex: Integer]: TcxComponentCollectionItem read GetItem write SetItem; default;
    property OnChange: TcxComponentCollectionChangeEvent read FOnChange write FOnChange;
  end;

  { TcxDialogMetricsInfo }

  IcxDialogMetricsInfoData = interface
    ['{DBFB3040-4677-4C9D-913C-45A1EE41E35A}']
    function GetInfoData: Pointer;
    function GetInfoDataSize: Integer;
    procedure SetInfoData(AData: Pointer);
  end;

  TcxDialogMetricsInfo = class
  private
    FClientHeight: Integer;
    FClientWidth: Integer;
    FData: Pointer;
    FDialogClass: TClass;
    FLeft: Integer;
    FTop: Integer;
    FMaximized: Boolean;
    procedure FreeCustomData;
  protected
    procedure Restore(AForm: TForm);
    procedure Store(AForm: TForm);
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    property ClientHeight: Integer read FClientHeight;
    property ClientWidth: Integer read FClientWidth;
    property Data: Pointer read FData;
    property DialogClass: TClass read FDialogClass;
    property Left: Integer read FLeft;
    property Maximized: Boolean read FMaximized;
    property Top: Integer read FTop;
  end;

  { TcxDialogsMetricsStore }

  TcxDialogsMetricsStore = class
  private
    FDefaultPosition: TPosition;
    FMetrics: TcxObjectList;
  protected
    function CreateMetrics(AForm: TForm): TcxDialogMetricsInfo;
    function FindMetrics(AForm: TForm): Integer;
    property Metrics: TcxObjectList read FMetrics;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure InitDialog(AForm: TForm);
    procedure StoreMetrics(AForm: TForm);

    property DefaultPosition: TPosition read FDefaultPosition write FDefaultPosition default poMainFormCenter;
  end;

  { TcxThread }

  TcxThread = class(TThread)
  private
    FException: Exception;
    procedure DoHandleException;
  protected
    procedure HandleException; virtual;
    procedure ResetException;
  end;

  { TcxComponentList }

  TcxComponentListNotifyEvent = procedure (Sender: TObject; AComponent: TComponent; AAction: TListNotification) of object;
  TcxComponentListChangeEvent = procedure (Sender: TObject; AComponent: TComponent; AAction: TcxComponentCollectionNotification) of object;

  TcxComponentList = class(TComponentList)
  private
    FUpdateCount: Integer;
    FOnComponentListChanged: TcxComponentListChangeEvent;
    FOnNotify: TcxComponentListNotifyEvent;
  protected
    procedure DoNotify(AItem: TComponent; AAction: TListNotification); virtual;
    function GetItemClass: TClass; virtual;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure Update(AItem: TComponent = nil; AAction: TcxComponentCollectionNotification = ccnChanged);
  public
    constructor Create; overload;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure CancelUpdate;
    procedure EndUpdate;
    property OnComponentListChanged: TcxComponentListChangeEvent read FOnComponentListChanged write FOnComponentListChanged;
    property OnNotify: TcxComponentListNotifyEvent read FOnNotify write FOnNotify;
  end;

  TcxNotifyProcedure = procedure(Sender: TObject);

// component dialogs metrics storage
function cxDialogsMetricsStore: TcxDialogsMetricsStore;

function cxAddObjectLink(AObject: TObject): TcxObjectLink;
procedure cxRemoveObjectLink(ALink: TcxObjectLink);
procedure cxClearObjectLinks(AObject: TObject);

procedure CallNotify(ANotifyEvent: TNotifyEvent; ASender: TObject);
function ClassInheritsFrom(AClass: TClass; const AParentClassName: string): Boolean;
procedure CopyList(ASource, ADestination: TList);
function EqualMethods(const AMethod1, AMethod2: TMethod): Boolean;
procedure FillStringsWithEnumTypeValues(AStrings: TStrings; ATypeInfo: PTypeInfo;
  AGetTypeItemCaption: TcxGetCaptionForIntegerItemFunc);
function GetPersistentOwner(APersistent: TPersistent): TPersistent;
function GetSubobjectName(AObject, ASubobject: TPersistent): string;
function GetValidName(AComponent: TComponent; const AName: string;
  AIsBaseName: Boolean = False): string;
function HexToByte(const AHex: string): Byte;
procedure RenameComponents(ACaller, AOwner: TComponent;
  ANewName, AOldName: TComponentName;
  AComponentCount: Integer; AGetComponent: TcxGetComponent);
function RoundDiv(I1, I2: Integer): Integer;
function Size(cx, cy: Longint): TSize;
procedure SwapIntegers(var I1, I2: Integer);
function GetRangeCenter(ABound1, ABound2: Integer): Integer;
function StreamsEqual(AStream1, AStream2: TMemoryStream): Boolean;
procedure OpenWebPage(const AWebAddress: string);
function GetCorrectPath(const S: string): string;

{$IFNDEF DELPHI6}
function IfThen(AValue: Boolean; ATrue: Integer; AFalse: Integer = 0): Integer;
function InRange(AValue, AMin, AMax: Integer): Boolean;
function Supports(const Instance: TObject; const IID: TGUID): Boolean; overload;
{$IFNDEF DELPHI5}
function Supports(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean; overload;
function Supports(Instance: TObject; const Intf: TGUID; out Inst): Boolean; overload;
procedure FreeAndNil(var Obj);
{$ENDIF}
{$ENDIF}

function cxGetLocaleInfo(ALocale, ALocaleType: Integer; const ADefaultValue: string): string;
function cxStrCharLength(const AStr: string; AIndex: Integer = 1): Integer;
function cxNextCharPos(const AStr: string; AIndex: Integer): Integer;
function cxPrevCharPos(const AStr: string; AIndex: Integer): Integer;

function cxGetResourceString(AResString: TcxResourceStringID): string; overload;
procedure cxSetResourceString(AResString: TcxResourceStringID; const Value: string);
function cxGetResourceString(const AResString: string): string; overload;{$IFDEF DELPHI6} deprecated;{$ENDIF}
function cxGetResourceStringNet(const AResString: string): string;{$IFDEF DELPHI6} deprecated;{$ENDIF}
procedure cxSetResourceStringNet(const AResString, Value: string);{$IFDEF DELPHI6} deprecated;{$ENDIF}
procedure cxClearResourceStrings;

function CreateUniqueName(AOwnerForm, AOwnerComponent, AComponent: TComponent;
  const APrefixName, ASuffixName: string): string;

function cxSign(const AValue: Double): Integer;

procedure SetHook(var AHook: HHook; AHookId: Integer; AHookProc: TFNHookProc);
procedure ReleaseHook(var AHook: HHOOK);

implementation

uses
  Math, Graphics, Controls;

type
  TPersistentAccess = class(TPersistent);

var
  FObjectLinkController: TcxObjectLinkController;
  FObjectLinkControllerRefCount: Integer;
  FDialogsMetrics: TcxDialogsMetricsStore;

function GetShortHint(const Hint: string): string;
var
  I: Integer;
begin
  I := AnsiPos('|', Hint);
  if I = 0 then
    Result := Hint else
    Result := Copy(Hint, 1, I - 1);
end;

function GetLongHint(const Hint: string): string;
var
  I: Integer;
begin
  I := AnsiPos('|', Hint);
  if I = 0 then
    Result := Hint else
    Result := Copy(Hint, I + 1, Maxint);
end;

{$IFNDEF DELPHI6}
function IfThen(AValue: Boolean; ATrue, AFalse: Integer): Integer;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function InRange(AValue, AMin, AMax: Integer): Boolean;
begin
  Result := (AValue <= AMax) and (AValue >= AMin);
end;

function Supports(const Instance: TObject; const IID: TGUID): Boolean;
var
  Temp: IUnknown;
begin
  Result := Supports(Instance, IID, Temp);
end;
{$IFNDEF DELPHI5}
function Supports(const Instance: IUnknown; const Intf: TGUID; out Inst): Boolean; overload;
begin
  Result := (Instance <> nil) and (Instance.QueryInterface(Intf, Inst) = 0);
end;

function Supports(Instance: TObject; const Intf: TGUID; out Inst): Boolean; overload;
var
  Unk: IUnknown;
begin
  Result := (Instance <> nil) and Instance.GetInterface(IUnknown, Unk) and
    Supports(Unk, Intf, Inst);
end;

procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ENDIF}
{$ENDIF}

function cxGetLocaleInfo(ALocale, ALocaleType: Integer; const ADefaultValue: string): string;
var
  ABuffer: string;
  ABufferSize: Integer;
begin
  ABufferSize := GetLocaleInfo(ALocale, ALocaleType, nil, 0);
  if ABufferSize = 0 then
    Result := ADefaultValue
  else
  begin
    SetLength(ABuffer, ABufferSize);
    GetLocaleInfo(ALocale, ALocaleType, PChar(ABuffer), ABufferSize);
    Result := Copy(ABuffer, 1, ABufferSize - 1)
  end;
end;

function GetPChar(const AStr: string; AIndex: Integer): PChar;
begin
  Result := PChar(AStr) + AIndex - 1;
end;

function cxStrCharLength(const AStr: string; AIndex: Integer = 1): Integer;
begin
  Result := Integer(CharNext(GetPChar(AStr, AIndex))) - Integer(GetPChar(AStr, AIndex));
end;

function cxNextCharPos(const AStr: string; AIndex: Integer): Integer;
begin
  Result := Integer(CharNext(GetPChar(AStr, AIndex))) - Integer(GetPChar(AStr, 1)) + 1;
end;

function cxPrevCharPos(const AStr: string; AIndex: Integer): Integer;
begin
  Result := Integer(CharPrev(GetPChar(AStr, 1), GetPChar(AStr, AIndex))) - Integer(GetPChar(AStr, 1)) + 1;
end;

{ TcxIUnknownObject }

function TcxIUnknownObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TcxIUnknownObject._AddRef: Integer;
begin
  Result := -1;
end;

function TcxIUnknownObject._Release: Integer;
begin
  Result := -1;
end;

{ TcxInterfacedPersistent }

constructor TcxInterfacedPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TcxInterfacedPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{$IFNDEF DELPHI6}

function TcxInterfacedPersistent._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function TcxInterfacedPersistent._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

function TcxInterfacedPersistent.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult($80004002);
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TcxInterfacedPersistent.AfterConstruction;
begin
  inherited;
  if GetOwner <> nil then
    GetOwner.GetInterface(IUnknown, FOwnerInterface);
end;
{$ENDIF}

{ TcxOwnedPersistent }

constructor TcxOwnedPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TcxOwnedPersistent.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{ TcxOwnedInterfacedPersistent }

function TcxOwnedInterfacedPersistent._AddRef: Integer;
begin
  Result := -1;
end;

function TcxOwnedInterfacedPersistent._Release: Integer;
begin
  Result := -1;
end;

function TcxOwnedInterfacedPersistent.QueryInterface(
  const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := cxE_NOINTERFACE;
end;

{ TcxComponent }

destructor TcxComponent.Destroy;
begin
  cxClearObjectLinks(Self);
  inherited Destroy;
end;

procedure TcxComponent.Loaded;
begin
  inherited Loaded;
  UpdateFakeLinks;
end;

procedure TcxComponent.BeforeDestruction;
begin
  if not IsDestroying then Destroying;
end;

procedure TcxComponent.GetFakeComponentLinks(AList: TList);
begin
end;

procedure TcxComponent.UpdateFakeLinks;
var
  I: Integer;
  AList: TList;
begin
  if not IsDesigning or IsDestroying or (Owner = nil) then Exit;
  AList := TList.Create;
  try
    GetFakeComponentLinks(AList);
    for I := 0 to GetFakeComponentLinkCount - 1 do
      if I < AList.Count then
        SetFakeComponentLink(I, TComponent(AList[I]))
      else
        SetFakeComponentLink(I, nil);
  finally
    AList.Free;
  end;
end;

function TcxComponent.GetFakeComponentLinkCount: Integer;
begin
  Result := 3;
end;

function TcxComponent.GetIsDesigning: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

function TcxComponent.GetIsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

procedure TcxComponent.SetFakeComponentLink(Index: Integer; Value: TComponent);
begin
  case Index of
    0: FFakeComponentLink1 := Value;
    1: FFakeComponentLink2 := Value;
    2: FFakeComponentLink3 := Value;
  end;
end;

{ TcxInterfacedCollectionItem }

procedure TcxInterfacedCollectionItem.AfterConstruction;
begin
  inherited AfterConstruction;
  if GetOwner <> nil then
    GetOwner.GetInterface(IUnknown, FOwnerInterface);
end;

function TcxInterfacedCollectionItem._AddRef: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._AddRef
  else
    Result := -1;
end;

function TcxInterfacedCollectionItem._Release: Integer;
begin
  if FOwnerInterface <> nil then
    Result := FOwnerInterface._Release
  else
    Result := -1;
end;

function TcxInterfacedCollectionItem.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := cxE_NOINTERFACE;
end;

{ TcxCollection }

procedure TcxCollection.Assign(Source: TPersistent);
var
  I: Integer;
  AItem: TCollectionItem;
begin
  if Source is TCollection then
  begin
    if (Count = 0) and (TCollection(Source).Count = 0) then Exit;
    BeginUpdate;
    try
      for I := 0 to TCollection(Source).Count - 1 do
      begin
        if I > Count - 1 then
          AItem := Add
        else
          AItem := Items[I];
        AItem.Assign(TCollection(Source).Items[I]);
      end;
      for I := Count - 1 downto TCollection(Source).Count do
        Delete(I);
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

{$IFNDEF DELPHI6}
function TcxCollection.Owner: TPersistent;
begin
  Result := GetOwner;
end;
{$ENDIF}

{ TcxOwnedInterfacedCollection }

destructor TcxOwnedInterfacedCollection.Destroy;
begin
  FIsDestroying := True;
  inherited;
end;

procedure TcxOwnedInterfacedCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if not IsDestroying and Assigned(OnChange) then
    OnChange(Self, Item);
end;

function TcxOwnedInterfacedCollection.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TcxOwnedInterfacedCollection._AddRef: Integer;
begin
  Result := -1;
end;

function TcxOwnedInterfacedCollection._Release: Integer;
begin
  Result := -1;
end;

{ TcxObjectList }

procedure TcxObjectList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited Clear;
end;

function TcxObjectList.GetItem(Index: Integer): TObject;
begin
  Result := inherited Items[Index];
end;

{ TcxEventHandlerCollection }

procedure TcxEventHandlerCollection.Add(AEvent: TcxEventHandler);
var
  ALength: Integer;
begin
  if IndexOf(AEvent) <> -1 then Exit;
  ALength := Length(FEvents);
  SetLength(FEvents, ALength + 1);
  FEvents[ALength] := AEvent;
end;

procedure TcxEventHandlerCollection.CallEvents(Sender: TObject; const AEventArgs);
var
  I: Integer;
begin
  for I := Low(FEvents) to High(FEvents) do
    FEvents[I](Sender, AEventArgs);
end;

procedure TcxEventHandlerCollection.Delete(AIndex: Integer);
var
  ALength, I: Integer;
begin
  ALength := Length(FEvents);
  if (AIndex < 0) or (AIndex >= ALength) then Exit;
  for I := AIndex to ALength - 2 do
    FEvents[I] := FEvents[I + 1];
  SetLength(FEvents, ALength - 1);
end;

function TcxEventHandlerCollection.IndexOf(AEvent: TcxEventHandler): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(FEvents) to High(FEvents) do
    if EqualMethods(TMethod(AEvent), TMethod(FEvents[I])) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxEventHandlerCollection.Remove(AEvent: TcxEventHandler);
begin
  Delete(IndexOf(AEvent));
end;

{ TcxRegisteredClassList }

constructor TcxRegisteredClassList.Create;
begin
  inherited Create;
  FItems := TList.Create;
end;

destructor TcxRegisteredClassList.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TcxRegisteredClassList.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    TcxRegisteredClassListItemData(FItems[I]).Free;
  FItems.Clear;
end;

function TcxRegisteredClassList.FindClass(AItemClass: TClass): TClass;
var
  AIndex: Integer;
begin
  if Find(AItemClass, AIndex) then
    Result := Items[AIndex].RegisteredClass
  else
    Result := nil;
end;

procedure TcxRegisteredClassList.Register(AItemClass, ARegisteredClass: TClass);
var
  AIndex: Integer;
  AData: TcxRegisteredClassListItemData;
begin
  AIndex := -1;
  AData := TcxRegisteredClassListItemData.Create;
  AData.ItemClass := AItemClass;
  AData.RegisteredClass := ARegisteredClass;
  if Find(AItemClass, AIndex) then
    FItems.Insert(AIndex + 1, AData)
  else
    if AIndex <> -1 then
      FItems.Insert(AIndex, AData)
    else
      FItems.Add(AData);
end;

procedure TcxRegisteredClassList.Unregister(AItemClass, ARegisteredClass: TClass);
var
  I: Integer;
  AData: TcxRegisteredClassListItemData;
begin
  for I := FItems.Count - 1 downto 0 do
  begin
    AData := Items[I];
    if (AData.ItemClass = AItemClass) and (AData.RegisteredClass = ARegisteredClass) then
    begin
      AData.Free;
      FItems.Delete(I);
    end;
  end;
end;

function TcxRegisteredClassList.Find(AItemClass: TClass; var AIndex: Integer): Boolean;
var
  I: Integer;
  AData: TcxRegisteredClassListItemData;
begin
  Result := False;
  for I := FItems.Count - 1 downto 0 do
  begin
    AData := Items[I];
    if AItemClass.InheritsFrom(AData.ItemClass) then
    begin
      AIndex := I;
      Result := True;
      Break;
    end
    else
      if AData.ItemClass.InheritsFrom(AItemClass) then
        AIndex := I;
  end;
end;

function TcxRegisteredClassList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxRegisteredClassList.GetItem(Index: Integer): TcxRegisteredClassListItemData;
begin
  Result := TcxRegisteredClassListItemData(FItems[Index]);
end;

{ TcxRegisteredClasses }

type
  TcxRegisteredClassesStringList = class(TStringList)
  public
    Owner: TcxRegisteredClasses;
  end;

constructor TcxRegisteredClasses.Create(ARegisterClasses: Boolean = False);
begin
  inherited Create;
  FRegisterClasses := ARegisterClasses;
  FItems := TcxRegisteredClassesStringList.Create;
  TcxRegisteredClassesStringList(FItems).Owner := Self;
end;

destructor TcxRegisteredClasses.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

function TcxRegisteredClasses.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxRegisteredClasses.GetDescription(Index: Integer): string;
begin
  Result := GetShortHint(FItems[Index]);
end;

function TcxRegisteredClasses.GetHint(Index: Integer): string;
begin
  Result := GetLongHint(FItems[Index]);
end;

function TcxRegisteredClasses.GetItem(Index: Integer): TClass;
begin
  Result := TClass(FItems.Objects[Index]);
end;

procedure TcxRegisteredClasses.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    FSorted := Value;
    if FSorted then Sort;
  end;
end;

function TcxRegisteredClasses.CompareItems(AIndex1, AIndex2: Integer): Integer;
begin
  Result := AnsiCompareText(Descriptions[AIndex1], Descriptions[AIndex2]);
end;

function SortClasses(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := TcxRegisteredClassesStringList(List).Owner.CompareItems(Index1, Index2);
end;

procedure TcxRegisteredClasses.Sort;
begin
  FItems.CustomSort(SortClasses);
end;

procedure TcxRegisteredClasses.Clear;
begin
  FItems.Clear;
end;

function TcxRegisteredClasses.FindByClassName(const AClassName: string): TClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Items[I].ClassName = AClassName then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TcxRegisteredClasses.FindByDescription(const ADescription: string): TClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Descriptions[I] = ADescription then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TcxRegisteredClasses.GetDescriptionByClass(AClass: TClass): string;
var
  AIndex: Integer;
begin
  AIndex := GetIndexByClass(AClass);
  if AIndex = -1 then
    Result := ''
  else
    Result := Descriptions[AIndex];
end;

function TcxRegisteredClasses.GetHintByClass(AClass: TClass): string;
var
  AIndex: Integer;
begin
  AIndex := GetIndexByClass(AClass);
  if AIndex = -1 then
    Result := ''
  else
    Result := Hints[AIndex];
end;

function TcxRegisteredClasses.GetIndexByClass(AClass: TClass): Integer;
begin
  Result := FItems.IndexOfObject(TObject(AClass));
end;

procedure TcxRegisteredClasses.Register(AClass: TClass; const ADescription: string);
begin
  if GetIndexByClass(AClass) = -1 then
  begin
    FItems.AddObject(ADescription, TObject(AClass));
    if FSorted then Sort;
    if FRegisterClasses then RegisterClass(TPersistentClass(AClass));
  end;
end;

procedure TcxRegisteredClasses.Unregister(AClass: TClass);
var
  I: Integer;
begin
  I := GetIndexByClass(AClass);
  if I <> -1 then
    FItems.Delete(I);
end;

{ TcxAutoWidthItem }

constructor TcxAutoWidthItem.Create;
begin
  inherited;
  AutoWidth := -1;
end;

{ TcxAutoWidthObject }

constructor TcxAutoWidthObject.Create(ACount: Integer);
begin
  inherited Create;
  FItems := TList.Create;
  FItems.Capacity := ACount;
end;

destructor TcxAutoWidthObject.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TcxAutoWidthObject.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxAutoWidthObject.GetItem(Index: Integer): TcxAutoWidthItem;
begin
  Result := TcxAutoWidthItem(FItems[Index]);
end;

function TcxAutoWidthObject.GetWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, Items[I].Width);
end;

procedure TcxAutoWidthObject.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do Items[I].Free;
end;

function TcxAutoWidthObject.AddItem: TcxAutoWidthItem;
begin
  Result := TcxAutoWidthItem.Create;
  FItems.Add(Result);
end;

procedure TcxAutoWidthObject.Calculate;
var
  AAvailableWidth, AWidth, ANewAvailableWidth, ANewWidth, AOffset, I,
    AItemAutoWidth: Integer;
  AAssignAllWidths, AItemWithMinWidthFound: Boolean;

  procedure RemoveItemFromCalculation(AItem: TcxAutoWidthItem);
  begin
    with AItem do
    begin
      Dec(ANewAvailableWidth, AutoWidth);
      Dec(ANewWidth, Width);
    end;
  end;

  procedure ProcessFixedItems;
  var
    I: Integer;

    procedure ProcessItem(AItem: TcxAutoWidthItem);
    begin
      with AItem do
        if Fixed then
        begin
          AutoWidth := Width;
          RemoveItemFromCalculation(AItem);
        end;
    end;

  begin
    for I := 0 to Count - 1 do ProcessItem(Items[I]);
  end;

  {procedure ProcessFixedColumns;
  var
    AFixedIndex, I: Integer;
  begin
    if not (gcsColumnSizing in GridDefinition.Controller.State) then Exit;
    AFixedIndex :=
      (GridDefinition.Controller.DragAndDropObject as TcxGridColumnHeaderSizingObject).Column.VisibleIndex;
    if AFixedIndex = Count - 1 then Exit;
    for I := 0 to Count - 1 do
      if I <= AFixedIndex then
      begin
        AColumnWidth := Items[I].CalculateWidth;
        Items[I].Width := AColumnWidth;
        Dec(AAvailableWidth, AColumnWidth);
        Dec(AWidth, AColumnWidth);
      end;
  end;}

  procedure ProcessItem(AItem: TcxAutoWidthItem);

    function CalculateItemAutoWidth: Integer;
    begin
      Result :=
        MulDiv(AOffset + AItem.Width, AAvailableWidth, AWidth) -
        MulDiv(AOffset, AAvailableWidth, AWidth);
    end;

  begin
    AItemAutoWidth := CalculateItemAutoWidth;
    if AAssignAllWidths then
      AItem.AutoWidth := AItemAutoWidth
    else
      if AItemAutoWidth <= AItem.MinWidth then
      begin
        AItem.AutoWidth := AItem.MinWidth;
        RemoveItemFromCalculation(AItem);
        AItemWithMinWidthFound := True;
      end;
    Inc(AOffset, AItem.Width);
  end;

begin
  AAvailableWidth := FAvailableWidth;
  AWidth := Width;

  ANewAvailableWidth := AAvailableWidth;
  ANewWidth := AWidth;
  ProcessFixedItems;
  AAssignAllWidths := False;
  repeat
    AAvailableWidth := ANewAvailableWidth;
    AWidth := ANewWidth;
    AOffset := 0;
    AItemWithMinWidthFound := False;

    for I := 0 to Count - 1 do
      if Items[I].AutoWidth = -1 then ProcessItem(Items[I]);

    if not AItemWithMinWidthFound then
      AAssignAllWidths := not AAssignAllWidths;
  until (ANewWidth = 0) or not AItemWithMinWidthFound and not AAssignAllWidths;
end;

{ TcxAlignment }

constructor TcxAlignment.Create(AOwner: TPersistent; AUseAssignedValues: Boolean = False;
  ADefaultHorz: TAlignment = taLeftJustify; ADefaultVert: TcxAlignmentVert = vaTop);
begin
  inherited Create;
  FOwner := AOwner;
  FUseAssignedValues := AUseAssignedValues;
  FDefaultHorz := ADefaultHorz;
  FDefaultVert := ADefaultVert;
  FHorz := FDefaultHorz;
  FVert := FDefaultVert;
end;

procedure TcxAlignment.Assign(Source: TPersistent);
var
  AChanged: Boolean;
begin
  if Source is TcxAlignment then
    with Source as TcxAlignment do
    begin
      AChanged := Self.FHorz <> FHorz;
      Self.FHorz := FHorz;
      AChanged := AChanged or (Self.FVert <> FVert);
      Self.FVert := FVert;
      Self.FIsHorzAssigned := FIsHorzAssigned;
      Self.FIsVertAssigned := FIsVertAssigned;
      if AChanged then
        Self.DoChanged;
    end
  else
    inherited Assign(Source);
end;

procedure TcxAlignment.Reset;
var
  AChanged: Boolean;
begin
  FIsHorzAssigned := False;
  FIsVertAssigned := False;
  AChanged := FHorz <> FDefaultHorz;
  FHorz := FDefaultHorz;
  AChanged := AChanged or (FVert <> FDefaultVert);
  FVert := FDefaultVert;
  if AChanged then
    DoChanged;
end;

procedure TcxAlignment.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

function TcxAlignment.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TcxAlignment.IsHorzStored: Boolean;
begin
  if FUseAssignedValues then
    Result := FIsHorzAssigned
  else
    Result := FHorz <> FDefaultHorz;
end;

function TcxAlignment.IsVertStored: Boolean;
begin
  if FUseAssignedValues then
    Result := FIsVertAssigned
  else
    Result := FVert <> FDefaultVert;
end;

procedure TcxAlignment.SetHorz(const Value: TAlignment);
begin
  FIsHorzAssigned := True;
  if Value <> FHorz then
  begin
    FHorz := Value;
    DoChanged;
  end;
end;

procedure TcxAlignment.SetVert(const Value: TcxAlignmentVert);
begin
  FIsVertAssigned := True;
  if Value <> FVert then
  begin
    FVert := Value;
    DoChanged;
  end;
end;

{ TcxObjectLinkController }

constructor TcxObjectLinkController.Create;
begin
  inherited Create;
  FLinks := TList.Create;
end;

destructor TcxObjectLinkController.Destroy;
begin
  FreeAndNil(FLinks);
  inherited Destroy;
end;

function TcxObjectLinkController.AddLink(AObject: TObject): TcxObjectLink;
begin
  Result := TcxObjectLink.Create;
  Result.Ref := AObject;
  FLinks.Add(Result);
end;

procedure TcxObjectLinkController.RemoveLink(ALink: TcxObjectLink);
begin
  if ALink.Ref <> nil then
    FLinks.Remove(ALink);
  ALink.Free;
end;

procedure TcxObjectLinkController.ClearLinks(AObject: TObject);
var
  I: Integer;
  ALink: TcxObjectLink;
begin
  for I := FLinks.Count - 1 downto 0 do
  begin
    ALink := TcxObjectLink(FLinks[I]);
    if ALink.Ref = AObject then
    begin
      ALink.Ref := nil;
      FLinks.Delete(I);
    end;
  end;
end;

{ TcxFreeNotificator }

procedure TcxFreeNotificator.AddSender(ASender: TComponent);
begin
  if ASender <> nil then
    ASender.FreeNotification(Self);
end;

procedure TcxFreeNotificator.RemoveSender(ASender: TComponent);
begin
{$IFDEF DELPHI5}
  if ASender <> nil then
    ASender.RemoveFreeNotification(Self);
{$ENDIF}
end;

procedure TcxFreeNotificator.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and Assigned(FOnFreeNotification) then
    FOnFreeNotification(AComponent);
end;

procedure AddObjectLinkControllerRefCount;
begin
  Inc(FObjectLinkControllerRefCount);
  if FObjectLinkController = nil then
    FObjectLinkController := TcxObjectLinkController.Create;
end;

procedure ReleaseObjectLinkControllerRefCount;
begin
  Dec(FObjectLinkControllerRefCount);
  if FObjectLinkControllerRefCount = 0 then
    FreeAndNil(FObjectLinkController);
end;

function cxAddObjectLink(AObject: TObject): TcxObjectLink;
begin
  if AObject <> nil then
  begin
    AddObjectLinkControllerRefCount;
    Result := FObjectLinkController.AddLink(AObject);
  end
  else
    Result := nil;
end;

procedure cxRemoveObjectLink(ALink: TcxObjectLink);
begin
  if ALink <> nil then
  begin
    FObjectLinkController.RemoveLink(ALink);
    ReleaseObjectLinkControllerRefCount;
  end;
end;

procedure cxClearObjectLinks(AObject: TObject);
begin
  if FObjectLinkController <> nil then
    FObjectLinkController.ClearLinks(AObject);
end;

{ TcxMRUItems }

constructor TcxMRUItems.Create;
begin
  inherited Create;
  FItems := TList.Create;
end;

destructor TcxMRUItems.Destroy;
begin
  ClearItems;
  FItems.Free;
  inherited;
end;

function TcxMRUItems.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TcxMRUItems.GetItem(Index: Integer): TcxMRUItem;
begin
  Result := TcxMRUItem(FItems[Index]);
end;

procedure TcxMRUItems.SetCount(Value: Integer);
var
  I: Integer;
begin
  if Value < Count then
    for I := Count - 1 downto Value do
      Delete(I);
end;

procedure TcxMRUItems.SetMaxCount(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if FMaxCount <> Value then
  begin
    FMaxCount := Value;
    UpdateCount;
  end;
end;

procedure TcxMRUItems.Delete(AIndex: Integer);
begin
  Items[AIndex].Free;
  FItems.Delete(AIndex);
end;

procedure TcxMRUItems.UpdateCount;
begin
  if MaxCount <> 0 then Count := MaxCount;
end;

procedure TcxMRUItems.Add(AItem: TcxMRUItem);
var
  AIndex: Integer;
begin
  AIndex := IndexOf(AItem);
  if AIndex = -1 then
  begin
    FItems.Insert(0, AItem);
    UpdateCount;
  end
  else
  begin
    FItems.Move(AIndex, 0);
    AItem.Free;
  end;
end;

procedure TcxMRUItems.ClearItems;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Delete(I);
end;

function TcxMRUItems.IndexOf(AItem: TcxMRUItem): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result].Equals(AItem) then Exit;
  Result := -1;
end;

{ TcxOpenList }

function TcxOpenList.GetItem(Index: Integer): TObject;
begin
  Result := TObject(inherited Items[Index]);
end;

procedure TcxOpenList.SetItem(Index: Integer; Value: TObject);
begin
  Count := Max(Count, 1 + Index);
  inherited Items[Index] := Value;
end;

{ TcxComponentCollectionItem }

destructor TcxComponentCollectionItem.Destroy;
begin
  SetCollection(nil);
  inherited Destroy;
end;

procedure TcxComponentCollectionItem.Changed(AAllItems: Boolean);
begin
  if not (csDestroying in ComponentState) and (Collection <> nil) then
    if AAllItems then
      Collection.Changed
    else
      Collection.Changed(Self);
end;

function TcxComponentCollectionItem.GetDisplayName: string;
begin
  Result := Name;
end;

function TcxComponentCollectionItem.GetParentComponent: TComponent;
begin
  if Collection <> nil then
    Result := Collection.ParentComponent
  else
    Result := inherited GetParentComponent;
end;

function TcxComponentCollectionItem.HasParent: Boolean;
begin
  Result := GetParentComponent <> nil;
end;

procedure TcxComponentCollectionItem.SetParentComponent(Value: TComponent);
begin
  Collection := GetCollectionFromParent(Value);
end;

procedure TcxComponentCollectionItem.SetCollection(AValue: TcxComponentCollection);
begin
  if Collection <> AValue then
  begin
    RemoveFromCollection(Collection);
    AddToCollection(AValue);
  end;
end;

procedure TcxComponentCollectionItem.SetIndex(AValue: Integer);
var
  ACurIndex: Integer;
begin
  ACurIndex := GetIndex;
  if (ACurIndex >= 0) and (ACurIndex <> AValue) then
  begin
    Collection.FItems.Move(ACurIndex, AValue);
    Changed(True);
  end;
end;

procedure TcxComponentCollectionItem.AddToCollection(ACollection: TcxComponentCollection);
begin
  if ACollection <> nil then
    ACollection.InsertItem(Self);
end;

function TcxComponentCollectionItem.GetIndex: Integer;
begin
  if Collection <> nil then
    Result := Collection.FItems.IndexOf(Self)
  else
    Result := -1;
end;

procedure TcxComponentCollectionItem.RemoveFromCollection(ACollection: TcxComponentCollection);
begin
  if ACollection <> nil then
    ACollection.RemoveItem(Self);
end;

{ TcxComponentCollection }

constructor TcxComponentCollection.Create(AParentComponent: TComponent; AItemClass: TcxComponentCollectionItemClass);
begin
  inherited Create;
  FParentComponent := AParentComponent;
  FItemClass := AItemClass;
  FItems := TList.Create;
end;

destructor TcxComponentCollection.Destroy;
begin
  FUpdateCount := 1;
  if FItems <> nil then
    Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TcxComponentCollection.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TcxComponentCollection then
  begin
    BeginUpdate;
    try
      Clear;
      for I := 0 to TcxComponentCollection(Source).Count - 1 do
        Add.Assign(TcxComponentCollection(Source).Items[I]);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TcxComponentCollection.Add: TcxComponentCollectionItem;
begin
  Result := FItemClass.Create(ParentComponent.Owner);
  Result.SetParentComponent(ParentComponent);
  SetItemName(Result);
end;

procedure TcxComponentCollection.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TcxComponentCollection.Clear;
begin
  if FItems.Count = 0 then Exit;
  BeginUpdate;
  try
    while FItems.Count > 0 do
      TObject(FItems.Last).Free;
  finally
    EndUpdate;
  end;
end;

procedure TcxComponentCollection.Delete(AIndex: Integer);
begin
  Notify(Items[AIndex], ccnDeleting);
  Items[AIndex].Free;
end;

procedure TcxComponentCollection.EndUpdate(AForceUpdate: Boolean = True);
begin
  Dec(FUpdateCount);
  if AForceUpdate then
    Changed;
end;

function TcxComponentCollection.FindItemByID(ID: Integer): TcxComponentCollectionItem;
var
  I: Integer;
begin
  for I := 0 to FItems.Count-1 do
  begin
    Result := Items[I];
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;

function TcxComponentCollection.Insert(AIndex: Integer): TcxComponentCollectionItem;
begin
  Result := Add;
  Result.Index := AIndex;
end;

procedure TcxComponentCollection.Remove(AItem: TcxComponentCollectionItem);
var
  AIndex: Integer;
begin
  AIndex := FItems.IndexOf(AItem);
  if AIndex > -1 then
    Delete(AIndex);
end;

procedure TcxComponentCollection.InsertItem(AItem: TcxComponentCollectionItem);
begin
  if not (AItem is FItemClass) then
    Exit;
  FItems.Add(AItem);
  AItem.FCollection := Self;
  AItem.FID := FNextID;
  Inc(FNextID);
  Notify(AItem, ccnAdded);
  Changed(AItem, ccnAdded);
end;

procedure TcxComponentCollection.RemoveItem(AItem: TcxComponentCollectionItem);
begin
  Notify(AItem, ccnExtracting);
  FItems.Remove(AItem);
  AItem.FCollection := nil;
  Notify(AItem, ccnExtracted);
  Changed(AItem, ccnExtracted);
end;

procedure TcxComponentCollection.Changed(AItem: TcxComponentCollectionItem = nil;
  AAction: TcxComponentCollectionNotification = ccnChanged);
begin
  if FUpdateCount = 0 then
    Update(AItem, AAction);
end;

function TcxComponentCollection.GetItem(AIndex: Integer): TcxComponentCollectionItem;
begin
  Result := TcxComponentCollectionItem(FItems[AIndex]);
end;

function TcxComponentCollection.GetOwner: TPersistent;
begin
  Result := ParentComponent;
end;

procedure TcxComponentCollection.Notify(AItem: TcxComponentCollectionItem;
  AAction: TcxComponentCollectionNotification);
begin
end;

procedure TcxComponentCollection.SetItem(AIndex: Integer; Value: TcxComponentCollectionItem);
begin
  Items[AIndex].Assign(Value);
end;

procedure TcxComponentCollection.SetItemName(AItem: TcxComponentCollectionItem);
begin

end;

procedure TcxComponentCollection.Update(AItem: TcxComponentCollectionItem;
  AAction: TcxComponentCollectionNotification);
begin
  if Assigned(OnChange) then
    OnChange(Self, AItem, AAction);
end;

function TcxComponentCollection.GetCount: Integer;
begin
  Result := FItems.Count;
end;

{ functions }

procedure CallNotify(ANotifyEvent: TNotifyEvent; ASender: TObject);
begin
  if Assigned(ANotifyEvent) then
    ANotifyEvent(ASender);
end;

function ClassInheritsFrom(AClass: TClass; const AParentClassName: string): Boolean;
var
  AParentClass: TClass;
begin
  AParentClass := AClass;
  repeat
    Result := AParentClass.ClassName = AParentClassName;
    if Result then Break;
    AParentClass := AParentClass.ClassParent;
  until AParentClass = nil;
end;

procedure CopyList(ASource, ADestination: TList);
begin
  ADestination.Count := ASource.Count;
  Move(ASource.List^, ADestination.List^, ASource.Count * SizeOf(Pointer));
end;

function EqualMethods(const AMethod1, AMethod2: TMethod): Boolean;
begin
  Result := (AMethod1.Code = AMethod2.Code) and (AMethod1.Data = AMethod2.Data);
end;

procedure FillStringsWithEnumTypeValues(AStrings: TStrings; ATypeInfo: PTypeInfo;
  AGetTypeItemCaption: TcxGetCaptionForIntegerItemFunc);
var
  ATypeData: PTypeData;
  I: Integer;
  S: string;
begin
  ATypeData := GetTypeData(ATypeInfo);
  AStrings.BeginUpdate;
  try
    for I := ATypeData.MinValue to ATypeData.MaxValue do
    begin
      S := AGetTypeItemCaption(I);
      if S <> '' then
        AStrings.AddObject(S, TObject(I));
    end;
  finally
    AStrings.EndUpdate;
  end;
end;

function GetPersistentOwner(APersistent: TPersistent): TPersistent;
begin
  Result := TPersistentAccess(APersistent).GetOwner;
end;

function GetSubobjectName(AObject, ASubobject: TPersistent): string;
var
  APropList: PPropList;
  I: Integer;
begin
  Result := '';
  I := GetPropList(AObject.ClassInfo, [tkClass], nil);
  GetMem(APropList, I * SizeOf(PPropInfo));
  GetPropList(AObject.ClassInfo, [tkClass], APropList);
  try
    for I := 0 to I - 1 do
      if APropList[I].PropType^ = ASubobject.ClassInfo then
      begin
        Result := dxShortStringToString(APropList[I].Name);
        Break;
      end;
  finally
    FreeMem(APropList);
  end;
end;

function GetValidName(AComponent: TComponent; const AName: string;
  AIsBaseName: Boolean = False): string;
var
  AOwner: TComponent;
  I: Integer;

  function GetNextName: string;
  begin
    Result := AName + IntToStr(I);
    Inc(I);
  end;

begin
  Result := AName;
  AOwner := AComponent.Owner;
  if AOwner = nil then Exit;
  I := 1;
  if AIsBaseName then Result := GetNextName;
  while AOwner.FindComponent(Result) <> nil do
    Result := GetNextName;
end;

function HexToByte(const AHex: string): Byte;

  function CharToByte(C: Char): Byte;
  begin
    if C <= '9' then
      Result := Ord(C) - Ord('0')
    else
      Result := 10 + Ord(Upcase(C)) - Ord('A');
  end;

begin
  Result := 16 * CharToByte(AHex[1]) + CharToByte(AHex[2]);
end;

procedure RenameComponents(ACaller, AOwner: TComponent;
  ANewName, AOldName: TComponentName;
  AComponentCount: Integer; AGetComponent: TcxGetComponent);
var
  I: Integer;
  AComponent: TComponent;
  AComponentName, ANamePrefix: TComponentName;
begin
  // Components introduced in an ancestor will be renamed by IDE.
  // We cannot rename components introduced in a successor because
  // IDE will not refresh source code in a successor.
  if csAncestor in ACaller.ComponentState then Exit;
  for I := 0 to AComponentCount - 1 do
  begin
    AComponent := AGetComponent(ACaller, I);
    if (AComponent.Owner = AOwner) {and not (csAncestor in AComponent.ComponentState)} then
    begin
      AComponentName := AComponent.Name;
      if Length(AComponentName) > Length(AOldName) then
      begin
        ANamePrefix := Copy(AComponentName, 1, Length(AOldName));
        if CompareText(AOldName, ANamePrefix) = 0 then
        begin
          Delete(AComponentName, 1, Length(AOldName));
          Insert(ANewName, AComponentName, 1);
          try
            AComponent.Name := AComponentName;
          except
            on EComponentError do { Ignore rename errors };
          end;
        end;
      end;
    end;
  end;
end;

function RoundDiv(I1, I2: Integer): Integer;
begin
  Result := I1 div I2 + Ord(I1 mod I2 <> 0);
end;

function Size(cx, cy: Longint): TSize;
begin
  Result.cx := cx;
  Result.cy := cy;
end;

procedure SwapIntegers(var I1, I2: Integer);
var
  I: Integer;
begin
  I := I1;
  I1 := I2;
  I2 := I;
end;

function GetRangeCenter(ABound1, ABound2: Integer): Integer;
begin
  if ABound1 + ABound2 > 0 then
    Result := (ABound1 + ABound2) div 2
  else
    Result := (ABound1 + ABound2 - 1) div 2;
end;

function StreamsEqual(AStream1, AStream2: TMemoryStream): Boolean;
begin
  Result := (AStream1.Size = AStream2.Size) and
    CompareMem(AStream1.Memory, AStream2.Memory, AStream1.Size);
end;

procedure OpenWebPage(const AWebAddress: string);
begin
  ShellExecute(0, 'OPEN', PChar(string(AWebAddress)), nil, nil, SW_SHOWMAXIMIZED);
end;

function GetCorrectPath(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(Result) do
    if Result[I] = '/' then
      Result[I] := {$IFDEF DELPHI6}PathDelim{$ELSE}'\'{$ENDIF};
end;

type
  TcxResourceStringsModificationMode = (rmmByResStringValue, rmmByResStringID, rmmUndefined);

  TcxResOriginalStrings = class(TStringList)
  public
  {$IFNDEF DELPHI6}
    function IndexOf(const S: string): Integer; override;
  {$ELSE}
    constructor Create;
  {$ENDIF}
  end;

{$IFNDEF DELPHI6}
function TcxResOriginalStrings.IndexOf(const S: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if AnsiCompareStr(Get(I), S) = 0 then
    begin
      Result := I;
      Break;
    end;
end;
{$ELSE}
constructor TcxResOriginalStrings.Create;
begin
  inherited Create;
  CaseSensitive := True;
end;
{$ENDIF}

var
  FResOriginalStrings: TcxResOriginalStrings;
  FResStrings: TStringList;
  FResStringsModificationMode: TcxResourceStringsModificationMode = rmmUndefined;

procedure CreateResStringLists(
  AResStringsModificationMode: TcxResourceStringsModificationMode);
begin
  if AResStringsModificationMode = rmmUndefined then
    raise EdxException.Create('');
  if (FResStringsModificationMode <> rmmUndefined) and
    (AResStringsModificationMode <> FResStringsModificationMode) then
      raise EdxException.Create('You cannot mix cxSetResourceString and cxSetResourceStringNet calls');

  if FResStringsModificationMode = rmmUndefined then
  begin
    FResStringsModificationMode := AResStringsModificationMode;
    FResOriginalStrings := TcxResOriginalStrings.Create;
    FResStrings := TStringList.Create;
  end;
end;

procedure DestroyResStringLists;
begin
  FResStringsModificationMode := rmmUndefined;
  FreeAndNil(FResOriginalStrings);
  FreeAndNil(FResStrings);
end;

function GetResOriginalStringIndex(AResString: TcxResourceStringID): Integer;
begin
  case FResStringsModificationMode of
    rmmByResStringValue:
      Result := FResOriginalStrings.IndexOf(LoadResString(AResString));
    rmmByResStringID:
      Result := FResOriginalStrings.IndexOfObject(TObject(AResString));
  else
    Result := -1;
  end;
end;

function cxGetResourceString(AResString: TcxResourceStringID): string;
var
  AIndex: Integer;
begin
  AIndex := GetResOriginalStringIndex(AResString);
  if AIndex <> -1 then
    Result := FResStrings[AIndex]
  else
    Result := LoadResString(AResString);
end;

procedure cxSetResourceString(AResString: TcxResourceStringID;
  const Value: string);
var
  AIndex: Integer;
begin
  CreateResStringLists(rmmByResStringID);
  AIndex := GetResOriginalStringIndex(AResString);
  if AIndex <> -1 then
    FResStrings[AIndex] := Value
  else
  begin
    FResOriginalStrings.AddObject(LoadResString(AResString), TObject(AResString));
    FResStrings.Add(Value);
  end;
end;

function cxGetResourceString(const AResString: string): string;{$IFDEF DELPHI6} deprecated;{$ENDIF}
begin
  Result := cxGetResourceStringNet(AResString);
end;

function cxGetResourceStringNet(const AResString: string): string;{$IFDEF DELPHI6} deprecated;{$ENDIF}
var
  AIndex: Integer;
begin
  Result := AResString;
  if FResOriginalStrings <> nil then
  begin
    AIndex := FResOriginalStrings.IndexOf(AResString);
    if AIndex <> -1 then
      Result := FResStrings[AIndex];
  end
end;

procedure cxSetResourceStringNet(const AResString, Value: string);{$IFDEF DELPHI6} deprecated;{$ENDIF}
var
  AIndex: Integer;
begin
  CreateResStringLists(rmmByResStringValue);
  AIndex := FResOriginalStrings.IndexOf(AResString);
  if AIndex <> -1 then
    FResStrings[AIndex] := Value
  else
  begin
    FResOriginalStrings.Add(AResString);
    FResStrings.Add(Value);
  end;
end;

procedure cxClearResourceStrings;
begin
  if FResStrings <> nil then
    FResStrings.Clear;
  if FResOriginalStrings <> nil then
    FResOriginalStrings.Clear;
end;

function CreateUniqueName(AOwnerForm, AOwnerComponent, AComponent: TComponent;
  const APrefixName, ASuffixName: string): string;
var
  I, J: Integer;

  function GenerateName(AOwnerComponent: TComponent;
    const AClassName, APrefixName, ASuffixName: string; ANumber: Integer): string;
  var
    S: string;

    procedure CheckName(var AName: string);
    var
      I: Integer;
    begin
      I := 1;
      while I <= Length(AName) do
        if dxCharInSet(AName[I], ['A'..'Z','a'..'z','_','0'..'9']) then
          Inc(I)
        else
          if dxCharInSet(AName[I], LeadBytes) then
            Delete(AName, I, 2)
          else
            Delete(AName, I, 1);
    end;

  begin
    S := ASuffixName;
    CheckName(S);
    if ((S = '') or dxCharInSet(S[1], ['0'..'9'])) and (AClassName <> '') then
      if (APrefixName <> '') and
        (CompareText(APrefixName, Copy(AClassName, 1, Length(APrefixName))) = 0) then
        S := Copy(AClassName, Length(APrefixName) + 1, Length(AClassName)) + S
      else
      begin
        S := AClassName + S;
        if S[1] = 'T' then Delete(S, 1, 1);
      end;
    if AOwnerComponent <> nil then
      Result := AOwnerComponent.Name + S
    else
      Result := S;
    if ANumber > 0 then
      Result := Result + IntToStr(ANumber);
  end;

  function IsUnique(const AName: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    with AOwnerForm do
      for I := 0 to ComponentCount - 1 do
        if (Components[I] <> AComponent) and
          (CompareText(Components[I].Name, AName) = 0) then
        begin
          Result := False;
          Break;
        end;
  end;

begin
  if ASuffixName <> '' then
    J := 0
  else
    J := 1;
  for I := J to MaxInt do
  begin
    Result := GenerateName(AOwnerComponent, AComponent.ClassName,
      APrefixName, ASuffixName, I);
    if IsUnique(Result) then
      Break;
  end;
end;

function cxSign(const AValue: Double): Integer;
begin
  Result := IfThen(AValue >= 0, 1, -1);
end;

procedure SetHook(var AHook: HHook; AHookId: Integer; AHookProc: TFNHookProc);
begin
  Assert(AHook = 0);
  AHook := SetWindowsHookEx(AHookId, AHookProc, 0, GetCurrentThreadId);
end;

procedure ReleaseHook(var AHook: HHOOK);
begin
  if AHook <> 0 then
  begin
    UnhookWindowsHookEx(AHook);
    AHook := 0;
  end;
end;

{ TcxDialogMetricsInfo }

constructor TcxDialogMetricsInfo.Create(AForm: TForm);
begin
  Store(AForm);
end;

destructor TcxDialogMetricsInfo.Destroy;
begin
  FreeCustomData;
  inherited Destroy;
end;

procedure TcxDialogMetricsInfo.Restore(AForm: TForm);
var
  AIntf: IcxDialogMetricsInfoData;
begin
  if FMaximized then
  begin
    ShowWindow(AForm.Handle, WS_MAXIMIZE);
    AForm.WindowState := wsMaximized;
  end
  else
  begin
    AForm.Left := FLeft;
    AForm.Top := FTop;
    if AForm.BorderStyle in [bsSizeable, bsSizeToolWin] then
    begin
      AForm.ClientHeight := FClientHeight;
      AForm.ClientWidth := FClientWidth;
    end;
  end;
  if Supports(TObject(AForm), IcxDialogMetricsInfoData, AIntf) and (FData <> nil) then
    AIntf.SetInfoData(FData);
end;

procedure TcxDialogMetricsInfo.Store(AForm: TForm);
var
  AIntf: IcxDialogMetricsInfoData;
begin
  FDialogClass := AForm.ClassType;
  FLeft := AForm.Left;
  FTop := AForm.Top;
  FClientHeight := AForm.ClientHeight;
  FClientWidth := AForm.ClientWidth;
  FMaximized := AForm.WindowState = wsMaximized;
  FreeCustomData;
  if Supports(TObject(AForm), IcxDialogMetricsInfoData, AIntf) and (AIntf.GetInfoDataSize > 0) then
  begin
    GetMem(FData, AIntf.GetInfoDataSize);
    Move(AIntf.GetInfoData^, FData^, AIntf.GetInfoDataSize);
  end;
end;

procedure TcxDialogMetricsInfo.FreeCustomData;
begin
  if FData <> nil then
  begin
    FreeMem(FData);
    FData := nil;
  end;
end;

{ TcxThread }

procedure TcxThread.DoHandleException;
begin
  if FException is Exception then
    Application.ShowException(FException)
  else
    SysUtils.ShowException(FException, nil);
end;

procedure TcxThread.HandleException;
begin
  FException := Exception(ExceptObject);
  try
    // Don't show EAbort messages
    if not (FException is EAbort) then
      Synchronize(DoHandleException);
  finally
    ResetException;
  end;
end;

procedure TcxThread.ResetException;
begin
  FException := nil;
end;

{ TcxComponentList }

constructor TcxComponentList.Create;
begin
  inherited Create(False);
end;

destructor TcxComponentList.Destroy;
begin
  FUpdateCount := 1;
  inherited Destroy;
end;

procedure TcxComponentList.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TcxComponentList.CancelUpdate;
begin
  Dec(FUpdateCount);
end;

procedure TcxComponentList.EndUpdate;
begin
  Dec(FUpdateCount);
  Update;
end;

procedure TcxComponentList.DoNotify(AItem: TComponent; AAction: TListNotification);

  function ConvertNotificaton(ANotification: TListNotification): TcxComponentCollectionNotification;
  begin
    case ANotification of
      lnAdded: Result := ccnAdded;
      lnExtracted: Result := ccnExtracted;
    else {lnDeleted}
      Result := ccnDeleting;
    end;
  end;

begin
  inherited Notify(AItem, AAction);
  if Assigned(OnNotify) then
    OnNotify(Self, AItem, AAction);
  Update(AItem, ConvertNotificaton(AAction));
end;

function TcxComponentList.GetItemClass: TClass;
begin
  Result := TComponent;
end;

procedure TcxComponentList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if TObject(Ptr) is GetItemClass then
    DoNotify(Ptr, Action)
  else
    if Action = lnAdded then
      Extract(Ptr);
end;

procedure TcxComponentList.Update(AItem: TComponent = nil;
  AAction: TcxComponentCollectionNotification = ccnChanged);
begin
  if (FUpdateCount = 0) and Assigned(OnComponentListChanged) then
    OnComponentListChanged(Self, AItem, AAction);
end;

{ TcxDialogsMetricsStore }

constructor TcxDialogsMetricsStore.Create;
begin
  inherited;
  FMetrics := TcxObjectList.Create;
  FDefaultPosition := poMainFormCenter;
end;

destructor TcxDialogsMetricsStore.Destroy;
begin
  FMetrics.Free;
  inherited Destroy;
end;

procedure TcxDialogsMetricsStore.InitDialog(AForm: TForm);
begin
  if FindMetrics(AForm) >= 0 then
  begin
    AForm.Position := poDesigned;
    TcxDialogMetricsInfo(FMetrics[FindMetrics(AForm)]).Restore(AForm)
  end
  else
  begin
    AForm.Position := DefaultPosition;
    FMetrics.Add(CreateMetrics(AForm));
  end;
end;

procedure TcxDialogsMetricsStore.StoreMetrics(AForm: TForm);
begin
  if FindMetrics(AForm) >= 0 then
    TcxDialogMetricsInfo(FMetrics[FindMetrics(AForm)]).Store(AForm)
end;

function TcxDialogsMetricsStore.CreateMetrics(
  AForm: TForm): TcxDialogMetricsInfo;
begin
  Result := TcxDialogMetricsInfo.Create(AForm);
end;

function TcxDialogsMetricsStore.FindMetrics(
  AForm: TForm): Integer;
begin
  Result := FMetrics.Count - 1;
  while Result >= 0 do
  begin
    if TcxDialogMetricsInfo(FMetrics[Result]).DialogClass = AForm.ClassType then
      Break;
    Dec(Result);
  end;
end;

function cxDialogsMetricsStore: TcxDialogsMetricsStore;
begin
  if FDialogsMetrics = nil then
    FDialogsMetrics := TcxDialogsMetricsStore.Create;
  Result := FDialogsMetrics;
end;

initialization
{$IFDEF DELPHI6}
  StartClassGroup(TControl);
  GroupDescendentsWith(TcxComponent, TControl);
{$ENDIF}

finalization
  FreeAndNil(FDialogsMetrics);
  DestroyResStringLists;

end.

