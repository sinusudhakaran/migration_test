
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

unit cxShellCommon;

{$I cxVer.inc}

interface

uses
{$IFNDEF DELPHI6}
  Mask,
{$ELSE}
  MaskUtils,
{$ENDIF}
  Windows, ActiveX, Classes, ComObj, Controls, Dialogs, Forms, Math, Messages,
  ShellApi, ShlObj, SyncObjs, SysUtils;

resourcestring
  SShellDefaultNameStr = 'Name';
  SShellDefaultSizeStr = 'Size';
  SShellDefaultTypeStr = 'Type';
  SShellDefaultModifiedStr = 'Modified';

const
  cxShellObjectInternalAbsoluteVirtualPathPrefix = '::{9C211B58-E6F1-456A-9F22-7B3B418A7BB1}';
  cxShellObjectInternalRelativeVirtualPathPrefix = '::{63BE9ADB-E4B5-4623-96AA-57440B4EF5A8}';
  cxShellObjectInternalVirtualPathPrefixLength = 40;

  cxSFGAO_GHOSTED = $00008000; // Error in ShlObj.pas 

  {$IFNDEF DELPHI6}
  SID_IShellFolder2  = '{93F2F68C-1D1B-11D3-A30E-00C04F79ABD1}';
  SID_IEnumExtraSearch   = '{0E700BE1-9DB6-11D1-A1CE-00C04FD75D13}';
  SID_IShellDetails      = '{000214EC-0000-0000-C000-000000000046}';

  {IShellFolder2.GetDefaultColumnState Values}
  SHCOLSTATE_TYPE_STR     = $00000001;
  SHCOLSTATE_TYPE_INT     = $00000002;
  SHCOLSTATE_TYPE_DATE    = $00000003;
  SHCOLSTATE_TYPEMASK     = $0000000F;
  SHCOLSTATE_ONBYDEFAULT  = $00000010;   // should on by default in details view
  SHCOLSTATE_SLOW         = $00000020;   // will be slow to compute; do on a background thread
  SHCOLSTATE_EXTENDED     = $00000040;   // provided by a handler; not the folder
  SHCOLSTATE_SECONDARYUI  = $00000080;   // not displayed in context menu; but listed in the "More..." dialog
  SHCOLSTATE_HIDDEN       = $00000100;   // not displayed in the UI

  {$EXTERNALSYM IID_IShellDetails}
  IID_IShellDetails: TGUID = (
    D1:$000214EC; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  {$ENDIF}

// Interface declarations, that missed in D4 and D5 versions

{$IFDEF BCB}
(*$HPPEMIT '#include <OleIdl.h>'*)
  {$IFNDEF DELPHI6}
(*$HPPEMIT '#if !defined(NO_WIN32_LEAN_AND_MEAN)'*)
(*$HPPEMIT 'typedef struct _STRRET'*)
(*$HPPEMIT '{'*)
(*$HPPEMIT '  UINT uType;'*)
(*$HPPEMIT '  union'*)
(*$HPPEMIT '  {'*)
(*$HPPEMIT '    LPWSTR pOleStr;'*)
(*$HPPEMIT '    LPSTR pStr;'*)
(*$HPPEMIT '    UINT uOffset;'*)
(*$HPPEMIT '    char cStr[MAX_PATH];'*)
(*$HPPEMIT '  } DUMMYUNIONNAME;'*)
(*$HPPEMIT '} STRRET, *LPSTRRET;'*)
(*$HPPEMIT '#endif'*)
  {$ENDIF}
{$ENDIF}

{$IFNDEF DELPHI6}
type
  {$EXTERNALSYM PExtraSearch}
  PExtraSearch = ^TExtraSearch;
  {$EXTERNALSYM tagExtraSearch}
  tagExtraSearch = record
    guidSearch: TGUID;
    wszFriendlyName,
    wszMenuText: array[0..79] of WideChar;
    wszHelpText: array[0..MAX_PATH] of WideChar;
    wszUrl: array[0..2047] of WideChar;
    wszIcon,
    wszGreyIcon,
    wszClrIcon: array[0..MAX_PATH+10] of WideChar;
  end;
  {$EXTERNALSYM TExtraSearch}
  TExtraSearch = tagExtraSearch;

  {$EXTERNALSYM IEnumExtraSearch}
  IEnumExtraSearch = interface
    [SID_IEnumExtraSearch]
    function Next(celt: ULONG; out rgelt: PExtraSearch;
      out pceltFetched: ULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppEnum: IEnumExtraSearch): HResult; stdcall;
  end;

  {$EXTERNALSYM PShColumnID}
  PShColumnID = ^TShColumnID;
  {$EXTERNALSYM SHCOLUMNID}
  SHCOLUMNID = record
    fmtid: TGUID;
    pid: DWORD;
  end;
  {$EXTERNALSYM TShColumnID}
  TShColumnID = SHCOLUMNID;

 { IShellDetails is supported on Win9x and NT4; for >= NT5 use IShellFolder2 }
  _SHELLDETAILS = record
    fmt,
    cxChar: Integer;
    str: STRRET;
  end;
  {$EXTERNALSYM SHELLDETAILS}
  SHELLDETAILS = _SHELLDETAILS;
  TShellDetails = _SHELLDETAILS;
  PShellDetails = ^TShellDetails;

  IShellDetails = interface
    [SID_IShellDetails]
    function GetDetailsOf(pidl: PItemIDList; iColumn: UINT;
      var pDetails: TShellDetails): HResult; stdcall;
    function ColumnClick(iColumn: UINT): HResult; stdcall;
  end;

  {$EXTERNALSYM IShellFolder2}
  IShellFolder2 = interface(IShellFolder)
    [SID_IShellFolder2]
    function GetDefaultSearchGUID(out pguid: TGUID): HResult; stdcall;
    function EnumSearches(out ppEnum: IEnumExtraSearch): HResult; stdcall;
    function GetDefaultColumn(dwRes: DWORD; var pSort: ULONG;
      var pDisplay: ULONG): HResult; stdcall;
    function GetDefaultColumnState(iColumn: UINT; var pcsFlags: DWORD): HResult; stdcall;
    function GetDetailsEx(pidl: PItemIDList; const pscid: SHCOLUMNID;
      pv: POleVariant): HResult; stdcall;
    function GetDetailsOf(pidl: PItemIDList; iColumn: UINT;
      var psd: TShellDetails): HResult; stdcall;
    function MapNameToSCID(pwszName: LPCWSTR; var pscid: TShColumnID): HResult; stdcall;
  end;
{$ENDIF}

// cxShell common classes
type
  ITEMIDLISTARRAY=array [0..MaxInt div SizeOf(PItemIDList) - 1] of PItemIDList;
  PITEMIDLISTARRAY=^ITEMIDLISTARRAY;

  TcxBrowseFolder=(bfCustomPath, bfAltStartup, bfBitBucket,
           bfCommonDesktopDirectory, bfCommonDocuments,
           bfCommonFavorites, bfCommonPrograms,
           bfCommonStartMenu, bfCommonStartup, bfCommonTemplates, bfControls,
           bfDesktop, bfDesktopDirectory, bfDrives, bfPrinters,
           bfFavorites, bfFonts, bfHistory, bfMyMusic,
           bfMyPictures, bfNetHood, bfProfile, bfProgramFiles, bfPrograms,
           bfRecent, bfStartMenu, bfStartUp, bfTemplates);

  TcxDropEffect=(deCopy, deMove, deLink);
  TcxDropEffectSet=set of TcxDropEffect;

  TcxCustomItemProducer=class;

  IcxDropSource = interface(IDropSource)
  ['{FCCB8EC5-ABB4-4256-B34C-25E3805EA046}']
  end;

  TcxDropSource=class(TInterfacedObject, IcxDropSource)
  private
    FOwner: TWinControl;
  protected
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
  public
    constructor Create(AOwner:TWinControl);virtual;
    property Owner:TWinControl read FOwner;
  end;

  { TcxShellOptions }

  TcxShellOptions=class(TPersistent)
  private
    FContextMenus: Boolean;
    FOwner: TWinControl;
    FShowFolders: Boolean;
    FShowToolTip: Boolean;
    FShowNonFolders: Boolean;
    FShowHidden: Boolean;
    FTrackShellChanges: Boolean;
    FOnShowToolTipChanged: TNotifyEvent;
    procedure SetShowFolders(Value: Boolean);
    procedure SetShowHidden(Value: Boolean);
    procedure SetShowNonFolders(Value: Boolean);
    procedure SetShowToolTip(Value: Boolean);
    procedure NotifyUpdateContents;
  protected
    property OnShowToolTipChanged: TNotifyEvent read FOnShowToolTipChanged
      write FOnShowToolTipChanged;
  public
    constructor Create(AOwner: TWinControl); virtual;
    procedure Assign(Source: TPersistent); override;
    function GetEnumFlags:Cardinal;
    property Owner:TWinControl read FOwner;
  published
    property ShowFolders:Boolean read FShowFolders write SetShowFolders default True;
    property ShowNonFolders:Boolean read FShowNonFolders write SetShowNonFolders default True;
    property ShowHidden:Boolean read FShowHidden write SetShowHidden default False;
    property ContextMenus:Boolean read FContextMenus write FContextMenus default True;
    property TrackShellChanges:Boolean read FTrackShellChanges write FTrackShellChanges default True;
    property ShowToolTip: Boolean read FShowToolTip write SetShowToolTip default True;
  end;

  TcxDetailItem=record
    Text:String;
    Width:Integer;
    Alignment:TAlignment;
    ID:Integer;
  end;

  TcxRequestItem = record
    ItemIndex: Integer;
    ItemProducer: TcxCustomItemProducer;
    Priority: Boolean;
  end;

  PcxRequestItem=^TcxRequestItem;

  PcxDetailItem=^TcxDetailItem;

  TcxShellDetails=class
  private
    FItems: TList;
    function GetItems(Index: Integer): PcxDetailItem;
    function GetCount: Integer;
  protected
    property Items:TList read FItems;
  public
    constructor Create;
    destructor Destroy;override;
    procedure ProcessDetails(ACharWidth: Integer; AShellFolder: IShellFolder;
      AFileSystem: Boolean);
    procedure Clear;
    function Add:PcxDetailItem;
    procedure Remove(Item:PcxDetailItem);
    property Item[Index:Integer]:PcxDetailItem read GetItems;default;
    property Count:Integer read GetCount;
  end;

  { TcxShellFolder }

  TcxShellFolderAttribute = (sfaGhosted, sfaHidden, sfaIsSlow, sfaLink,
    sfaReadOnly, sfaShare);
  TcxShellFolderAttributes = set of TcxShellFolderAttribute;

  TcxShellFolderCapability = (sfcCanCopy, sfcCanDelete, sfcCanLink, sfcCanMove,
    sfcCanRename, sfcDropTarget, sfcHasPropSheet);
  TcxShellFolderCapabilities = set of TcxShellFolderCapability;

  TcxShellFolderProperty = (sfpBrowsable, sfpCompressed, sfpEncrypted,
    sfpNewContent, sfpNonEnumerated, sfpRemovable);
  TcxShellFolderProperties = set of TcxShellFolderProperty;

  TcxShellFolderStorageCapability = (sfscFileSysAncestor, sfscFileSystem,
    sfscFolder, sfscLink, sfscReadOnly, sfscStorage, sfscStorageAncestor,
    sfscStream);
  TcxShellFolderStorageCapabilities = set of TcxShellFolderStorageCapability;

  TcxShellFolder = class
  private
    FAbsolutePIDL: PItemIDList;
    FParentShellFolder: IShellFolder;
    FRelativePIDL: PItemIDList;
    function GetAttributes: TcxShellFolderAttributes;
    function GetCapabilities: TcxShellFolderCapabilities;
    function GetDisplayName: string;
    function GetIsFolder: Boolean;
    function GetPathName: string;
    function GetProperties: TcxShellFolderProperties;
    function GetShellAttributes(ARequestedAttributes: LongWord): LongWord;
    function GetShellFolder: IShellFolder;
    function GetStorageCapabilities: TcxShellFolderStorageCapabilities;
    function GetSubFolders: Boolean;
    function HasShellAttribute(AAttribute: LongWord): Boolean; overload;
    function HasShellAttribute(AAttributes, AAttribute: LongWord): Boolean; overload;
    function InternalGetDisplayName(AFolder: IShellFolder; APIDL: PItemIDList;
      ANameType: DWORD): string;
  public
    constructor Create(AAbsolutePIDL: PItemIDList);
    destructor Destroy; override;

    property Attributes: TcxShellFolderAttributes read GetAttributes;
    property Capabilities: TcxShellFolderCapabilities read GetCapabilities;
    property IsFolder: Boolean read GetIsFolder;
    property Properties: TcxShellFolderProperties read GetProperties;
    property StorageCapabilities: TcxShellFolderStorageCapabilities
      read GetStorageCapabilities;
    property SubFolders: Boolean read GetSubFolders;

    property AbsolutePIDL: PItemIDList read FAbsolutePIDL;
    property DisplayName: string read GetDisplayName;
    property ParentShellFolder: IShellFolder read FParentShellFolder;
    property PathName: string read GetPathName;
    property RelativePIDL: PItemIDList read FRelativePIDL;
    property ShellFolder: IShellFolder read GetShellFolder;
  end;

  TcxCustomShellRoot=class(TPersistent)
  private
    FAttributes: Cardinal;
    FBrowseFolder: TcxBrowseFolder;
    FCustomPath: WideString;
    FFolder: TcxShellFolder;
    FIsRootChecking: Boolean;
    FOwner: TPersistent;
    FParentWindow: HWND;
    FPidl: PItemIDList;
    FRootChangingCount: Integer;
    FShellFolder: IShellFolder;
    FUpdating: Boolean;
    FValid: Boolean;
    FOnSettingsChanged: TNotifyEvent;
    procedure SetBrowseFolder(Value: TcxBrowseFolder);
    procedure SetCustomPath(const Value: WideString);
    procedure SetPidl(const Value: PItemIDList);
    function GetCurrentPath: WideString;
    procedure UpdateFolder;
  protected
    procedure CheckRoot; virtual;
    procedure DoSettingsChanged;
    procedure RootUpdated; virtual;
    property Owner: TPersistent read FOwner;
    property ParentWindow: HWND read FParentWindow;
  public
    constructor Create(AOwner: TPersistent; AParentWindow: HWND); virtual;
    destructor Destroy;override;
    procedure Assign(Source: TPersistent); override;
    procedure Update(ARoot: TcxCustomShellRoot);
    property Attributes:Cardinal read FAttributes;
    property CurrentPath:WideString read GetCurrentPath;
    property Folder: TcxShellFolder read FFolder;
    property IsValid:Boolean read FValid;
    property Pidl:PItemIDList read FPidl write SetPidl;
    property ShellFolder:IShellFolder read FShellFolder;
    property OnSettingsChanged: TNotifyEvent read FOnSettingsChanged
      write FOnSettingsChanged;
  published
    property BrowseFolder:TcxBrowseFolder read FBrowseFolder
      write SetBrowseFolder default bfDesktop;
    property CustomPath:WideString read FCustomPath write SetCustomPath;
  end;

  TcxRootChangedEvent=procedure (Sender:TObject; Root:TcxCustomShellRoot) of object;

  TcxShellItemInfo=class
  private
    FCanRename: Boolean;
    FDetails: TStrings;
    FFolder: TcxShellFolder;
    FFullPIDL: PItemIDList;
    FHasSubfolder: Boolean;
    FIconIndex: Integer;
    FInfoTip: WideString;
    FInitialized: Boolean;
    FIsDropTarget: Boolean;
    FIsFilesystem: Boolean;
    FIsFolder: Boolean;
    FIsGhosted: Boolean;
    FIsLink: Boolean;
    FIsRemovable: Boolean;
    FIsShare: Boolean;
    FItemProducer: TcxCustomItemProducer;
    FName: WideString;
    FOpenIconIndex: Integer;
    Fpidl: PItemIDList;
    FUpdated: Boolean;
    FUpdating: Boolean;
  protected
    property Updating:Boolean read FUpdating write FUpdating;
  public
    constructor Create(AItemProducer: TcxCustomItemProducer;
      AParentIFolder: IShellFolder; AParentPIDL, APIDL: PItemIDList;
      AFast: Boolean); virtual;
    destructor Destroy;override;
    procedure CheckUpdate(ShellFolder:IShellFolder;FolderPidl:PItemIDList;Fast:Boolean);
    procedure CheckInitialize(AIFolder: IShellFolder; APIDL: PItemIDList);
    procedure FetchDetails(wnd:HWND;ShellFolder:IShellFolder;DetailsMap:TcxShellDetails);
    procedure CheckSubitems(AParentIFolder: IShellFolder;
      AEnumSettings: Cardinal);
    procedure SetNewPidl(pFolder:IShellFolder;FolderPidl,apidl:PItemIDList);
    property CanRename:Boolean read FCanRename;
    property Details:TStrings read FDetails;
    property Folder: TcxShellFolder read FFolder;
    property FullPIDL: PItemIDList read FFullPIDL;
    property HasSubfolder:Boolean read FHasSubfolder;
    property IconIndex:Integer read FIconIndex;
    property InfoTip:WideString read FInfoTip;
    property Initialized:Boolean read FInitialized;
    property IsDropTarget:Boolean read FIsDropTarget;
    property IsFilesystem:Boolean read FIsFilesystem;
    property IsFolder:Boolean read FIsFolder;
    property IsGhosted:Boolean read FIsGhosted;
    property IsLink:Boolean read FIsLink;
    property IsRemovable:Boolean read FIsRemovable;
    property IsShare:Boolean read FIsShare;
    property ItemProducer: TcxCustomItemProducer read FItemProducer;
    property Name:WideString read FName;
    property OpenIconIndex:Integer read FOpenIconIndex;
    property pidl:PItemIDList read Fpidl;
    property Updated:Boolean read FUpdated write FUpdated;
  end;

  PcxShellItemInfo = TcxShellItemInfo;

  { TcxShellItemsInfoGatherer }

  TcxShellItemsInfoGatherer = class
  private
    FFetchQueue: TList;
    FFetchStoppedEvent: THandle;
    FFetchThread: THandle;
    FIsFetchQueueClearing: Boolean;
    FOwner: TWinControl;
    FStopFetchCount: Integer;
    FStopFetchEvent: THandle;
    FTerminateFetchThreadEvent: THandle;
    procedure CreateFetchThread;
    function CreateRequestItem(AItemProducer: TcxCustomItemProducer;
      AIndex: Integer; APriority: Boolean): PcxRequestItem;
    function GetFetchQueueItemIndex(AFetchQueue: TList;
      AItemProducer: TcxCustomItemProducer; AIndex: Integer): Integer;
    function GetIsFetchStopping: Boolean;
    function GetIsFetchThreadTerminating: Boolean;
    procedure FetchResumed;
    procedure FetchStopped;
    procedure InternalCloseHandle(var AHandle: THandle);
    procedure TerminateFetchThread;
    property FetchQueue: TList read FFetchQueue;
    property IsFetchStopping: Boolean read GetIsFetchStopping;
    property IsFetchThreadTerminating: Boolean read GetIsFetchThreadTerminating;
  protected
    procedure DestroyFetchThread;
  public
    constructor Create(AOwner: TWinControl);
    destructor Destroy; override;
    procedure ClearFetchQueue(AItemProducer: TcxCustomItemProducer);
    procedure RequestItemInfo(AItemProducer: TcxCustomItemProducer;
      AIndex: Integer; APriority: Boolean);
    procedure ResumeFetch;
    procedure StopFetch;
  end;

  TcxCustomItemProducer=class
  private
    FDetails: TcxShellDetails;
    FFolderPidl: PItemIDList;
    FItems: TList;
    FItemsLock: TMultiReadExclusiveWriteSynchronizer;
    FOwner: TWinControl;
    FShellFolder: IShellFolder;
  protected
    function AllowBackgroundProcessing: Boolean; virtual; abstract;
    function CanAddFolder(AFolder: TcxShellFolder): Boolean; virtual;
    function DoCompareItems(AItem1, AItem2: TcxShellFolder;
      out ACompare: Integer): Boolean; virtual;
    procedure DoSort; virtual;
    procedure FetchItems(cPreloadItems:Integer);
    function GetEnumFlags:Cardinal;virtual;abstract;
    function GetItemsInfoGatherer: TcxShellItemsInfoGatherer; virtual; abstract;
    function GetShowToolTip:Boolean;virtual;abstract;
    procedure InitializeItem(Item:TcxShellItemInfo);virtual;
    procedure CheckForSubitems(AItem: TcxShellItemInfo); virtual;
    procedure ClearFetchQueue;
    property ItemsLock:TMultiReadExclusiveWriteSynchronizer read FItemsLock;
    property ShellFolder:IShellFolder read FShellFolder;
    property FolderPidl:PItemIDList read FFolderPidl write FFolderPidl;
    property Owner:TWinControl read FOwner;
  public
    constructor Create(AOwner:TWinControl);virtual;
    destructor Destroy;override;
    procedure ProcessItems(AIFolder: IShellFolder; AFolderPIDL: PItemIDList;
      cPreloadItems: Integer); virtual;
    procedure ProcessDetails(ShellFolder:IShellFolder;CharWidth:Integer);virtual;
    procedure FetchRequest(AIndex: Integer; APriority: Boolean = False);
    procedure ClearItems;
    procedure LockRead;
    procedure LockWrite;
    procedure UnlockRead;
    procedure UnlockWrite;
    procedure RequestItemsInfo;
    procedure SetItemsCount(Count:Integer);virtual;
    procedure NotifyUpdateItem(AItem: PcxRequestItem); virtual; abstract;
    procedure NotifyRemoveItem(Index:Integer);virtual;
    procedure NotifyAddItem(Index:Integer);virtual;
    procedure DoGetInfoTip(Handle:HWND;ItemIndex: Integer; InfoTip: PChar; cch:Integer);
    function GetItemByPidl(apidl:PItemIDList):TcxShellItemInfo;
    function GetItemIndexByPidl(apidl:PItemIDList):Integer;
    procedure Sort;
    property Details:TcxShellDetails read FDetails;
    property Items:TList read FItems;
    property ItemsInfoGatherer: TcxShellItemsInfoGatherer read GetItemsInfoGatherer;
  end;

  TcxDragDropSettings = class(TPersistent)
  private
    FAllowDragObjects: Boolean;
    FDefaultDropEffect: TcxDropEffect;
    FDropEffect: TcxDropEffectSet;
    FScroll: Boolean;
    FOnChange: TNotifyEvent;
    function GetDefaultDropEffectAPI: Integer;
    function GetDropEffectAPI: DWORD;
    procedure SetAllowDragObjects(Value: Boolean);
  protected
    procedure Changed;
  public
    property DropEffectAPI: DWORD read GetDropEffectApi;
    property DefaultDropEffectAPI: Integer read GetDefaultDropEffectAPI;
    constructor Create;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property AllowDragObjects: Boolean read FAllowDragObjects
      write SetAllowDragObjects default True;
    property DefaultDropEffect: TcxDropEffect read FDefaultDropEffect
      write FDefaultDropEffect default deMove;
    property DropEffect: TcxDropEffectSet read FDropEffect write FDropEffect
      default [deCopy, deMove, deLink];
    property Scroll: Boolean read FScroll write FScroll stored False; // deprecated
  end;

  TShChangeNotifyEntry = packed record
    pidlPath: PItemIDList;
    bWatchSubtree: BOOL;
  end;

  DWORDITEMID=record
    cb: SHORT;
    dwItem1: DWORD;
    dwItem2: DWORD;
  end;

  PDWORDITEMID=^DWORDITEMID;

  PShChangeNotifyEntry = ^TShChangeNotifyEntry;

function GetDesktopIShellFolder: IShellFolder;
function GetTextFromStrRet(var AStrRet: TStrRet; APIDL: PitemIDList): WideString;
function GetShellDetails(pFolder:IShellFolder;pidl:PItemIDList;out sd:IShellDetails):Hresult;
function HasSubItems(AParentIFolder: IShellFolder; AFullPIDL: PItemIDList;
  AEnumSettings: Cardinal): Boolean;
function cxFileTimeToDateTime(fTime:FILETIME):TDateTime;
function cxMalloc: IMalloc;
procedure DisplayContextMenu(AWnd: HWND; AIFolder: IShellFolder;
  AItemPIDLList: TList; const APos: TPoint);

{ Pidl Tools}

function GetPidlItemsCount(pidl:PItemIDList):Integer;
function GetPidlSize(pidl:PItemIDList):Integer;
function GetNextItemID(pidl:PItemIDList):PItemIDList;
function GetPidlCopy(pidl:PItemIDList):PItemIDList;
function GetLastPidlItem(pidl:PItemIDList):PItemIDList;
function GetPidlName(APIDL: PItemIDList): WideString;
function ConcatenatePidls(pidl1,pidl2:PItemIDList):PItemIDList;
procedure DisposePidl(pidl:PItemIDList);
function GetPidlParent(pidl:PItemIDList):PItemIDList;
function CreateEmptyPidl:PItemIDList;
function CreatePidlListFromList(List:TList):PItemIDList;
function ExtractParticularPidl(pidl:PItemIDList):PItemIDList;
function EqualPIDLs(APIDL1, APIDL2: PItemIDList): Boolean;
function IsSubPath(APIDL1, APIDL2: PItemIDList): Boolean;

{ Unicode Tools }

procedure StrPLCopyW(Dest:PWideChar;Source:WideString;MaxLen:Cardinal);
function StrPasW(Source:PWideChar):WideString;
function StrLenW(Source:PWideChar):Cardinal;
function UpperCaseW(Source:WideString):WideString;
function LowerCaseW(Source:WideString):WideString;

procedure CheckShellRoot(ARoot: TcxCustomShellRoot);
function GetShellItemDisplayName(AIFolder: IShellFolder;
  APIDL: PItemIDList; ACheckIsFolder: Boolean): WideString;

const
  DSM_SETCOUNT=CM_BASE+315;
  DSM_NOTIFYUPDATE=CM_BASE+316;
  DSM_NOTIFYREMOVEITEM=CM_BASE+318;
  DSM_NOTIFYADDITEM=CM_BASE+319;
  DSM_NOTIFYUPDATECONTENTS=CM_BASE+320;
  DSM_SHELLCHANGENOTIFY=CM_BASE+321;
  DSM_DONAVIGATE=CM_BASE+322;
  DSM_SYNCHRONIZEROOT=CM_BASE+323;
  DSM_SHELLTREECHANGENOTIFY=CM_BASE+324;
  DSM_SHELLTREERESTORECURRENTPATH=CM_BASE+325;

  PRELOAD_ITEMS_COUNT=10;

  SHCNF_ACCEPT_INTERRUPTS =     $1;
  SHCNF_ACCEPT_NON_INTERRUPTS = $2;
  SHCNF_NO_PROXY =              $8000;

var
  SHChangeNotifyRegister:function (hwnd:HWND;dwFlags:DWORD;wEventMask:DWORD;
           uMsg:UINT;cItems:DWORD;lpItems:PShChangeNotifyEntry):Cardinal;stdcall;
  SHChangeNotifyUnregister:function (hNotify:Cardinal):Boolean;stdcall;

implementation

uses
  cxContainer, cxControls, cxEdit, dxUxTheme, dxCore;

const
  ShellLibraryName = 'shell32.dll';
{$IFNDEF DELPHI6}
  PathDelim  = '\';
  cxIID_IShellFolder2: TGUID = (
    D1:$93F2F68C; D2:$1D1B; D3:$11D3; D4:($A3,$0E,$00,$C0,$4F,$79,$AB,$D1));
{$ENDIF}
  SFGAO_ENCRYPTED       = $00002000;
  SFGAO_ISSLOW          = $00004000;
  SFGAO_STORAGE         = $00000008;
  SFGAO_STORAGEANCESTOR = $00800000;
  SFGAO_STORAGECAPMASK  = $70C50008;
  SFGAO_STREAM          = $00400000;

type
  TcxContextMenuMessageWindow = class(TcxMessageWindow)
  private
    FContextMenu: IContextMenu2;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    property ContextMenu: IContextMenu2 read FContextMenu write FContextMenu;
  end;

  TSHGetPathFromIDList = function(APIDL: PItemIDList; APath: PChar): BOOL; stdcall;
  TSHGetPathFromIDListW = function(APIDL: PItemIDList; APath: PWideChar): BOOL; stdcall;

{$IFDEF DELPHI6}
  cxIShellFolder2 = interface(IShellFolder2)
    ['{93F2F68C-1D1B-11D3-A30E-00C04F79ABD1}']
  end;
{$ENDIF}

var
  FSysFileIconIndex: Integer = -1;
  FSysFolderIconIndex: Integer = -1;
  FSysFolderOpenIconIndex: Integer = -1;
  cxSHGetFolderLocation:function (wnd:HWND;nFolder:Integer;hToken:THandle;
             dwReserwed:DWORD;var ppidl:PItemIDList):HResult;stdcall;
  cxSHGetPathFromIDList: TSHGetPathFromIDList = nil;
  cxSHGetPathFromIDListW: TSHGetPathFromIDListW = nil;
  ShellLibrary: HMODULE = 0;
  FcxMalloc: IMalloc;
  FShellItemsInfoGatherers: TList;

(*function GetShellItemDisplayName(AIFolder: IShellFolder;
  APIDL: PItemIDList; ACheckIsFolder: Boolean): WideString;
var
  AAttributes, AFlags: Cardinal;
  AIsFolder: Boolean;
  AStrRet: TStrRet;
begin
  Result := '';

  if ACheckIsFolder then
  begin
    AAttributes := SFGAO_FOLDER;
    if not Succeeded(AIFolder.GetAttributesOf(1, APIDL, AAttributes)) then
      Exit;
    AIsFolder := AAttributes and SFGAO_FOLDER <> 0;
  end
  else
    AIsFolder := False;

  AFlags := SHGDN_INFOLDER;
  if AIsFolder then
    AFlags := AFlags or SHGDN_FORPARSING;

  if not Succeeded(AIFolder.GetDisplayNameOf(APIDL, AFlags, AStrRet)) then
    Exit;
  Result := GetTextFromStrRet(AStrRet, APIDL);
  if AIsFolder and (Length(Result) > 2) then
    if (Result[1] = ':') and (Result[2] = ':') or
      (Result[1] = '\') and (Result[2] = '\') then
    begin
      AIFolder.GetDisplayNameOf(APIDL, SHGDN_INFOLDER, AStrRet);
      Result := GetTextFromStrRet(AStrRet, APIDL);
    end;
end;*)

procedure CheckShellRoot(ARoot: TcxCustomShellRoot);
begin
  if ARoot.ShellFolder = nil then
    ARoot.CheckRoot;
end;

function GetShellItemDisplayName(AIFolder: IShellFolder;
  APIDL: PItemIDList; ACheckIsFolder: Boolean): WideString;
var
  AStrRet: TStrRet;
begin
  if Succeeded(AIFolder.GetDisplayNameOf(APIDL, SHGDN_INFOLDER, AStrRet)) then
    Result := GetTextFromStrRet(AStrRet, APIDL)
  else
    Result := '';
end;

function HasSubItems(AParentIFolder: IShellFolder; AFullPIDL: PItemIDList;
  AEnumSettings: Cardinal): Boolean;

  function HasAttributes(AAttributes: UINT): Boolean;
  var
    ATempAttributes: UINT;
    ATempPIDL: PItemIDList;
  begin
    ATempAttributes := AAttributes;
    ATempPIDL := GetLastPidlItem(AFullPIDL);
    AParentIFolder.GetAttributesOf(1, ATempPIDL, ATempAttributes);
    Result := ATempAttributes and AAttributes = AAttributes;
  end;

  function CheckLocalFolder(out AHasSubItems: Boolean): Boolean;
  var
    AAttributes, AParsedCharCount: ULONG;
    ADesktopIFolder: IShellFolder;
    AFileSearchAttributes: Integer;
    ATempPIDL: PItemIDList;
    ASearchRec: TSearchRec;
    S: WideString;
  begin
    Result := False;
    S := GetPidlName(AFullPIDL);
    if (S = '')(* or (Pos('\\', S) = 1)*) then
      Exit;
    SHGetDesktopFolder(ADesktopIFolder);
    AAttributes := 0;
    ADesktopIFolder.ParseDisplayName(0, nil, PWideChar(S),
      AParsedCharCount, ATempPIDL, AAttributes);
    if ATempPIDL = nil then
      Exit;
    try
      Result := True;
      AHasSubItems := False;

      AFileSearchAttributes := faReadOnly or faSysFile or faArchive;
      if AEnumSettings and SHCONTF_FOLDERS <> 0 then
        AFileSearchAttributes := AFileSearchAttributes or faDirectory;
      if AEnumSettings and SHCONTF_INCLUDEHIDDEN <> 0 then
        AFileSearchAttributes := AFileSearchAttributes or faHidden;

      if S[Length(S)] = PathDelim then
        Delete(S, Length(S), 1);
      if FindFirst(S + PathDelim + '*.*', AFileSearchAttributes, ASearchRec) = 0 then
      begin
        repeat
          if (ASearchRec.Name = '.') or (ASearchRec.Name = '..') then
          begin
            if FindNext(ASearchRec) <> 0 then
              Break;
          end
          else
          begin
            AHasSubItems := True;
            Break;
          end;
        until False;
        FindClose(ASearchRec);
      end;
    finally
      DisposePidl(ATempPIDL);
    end;
  end;

var
  ATempIFolder: IShellFolder;
  ATempPIDL: PItemIDList;
  AIEnum: IEnumIDList;
  AFetchedItemCount: Cardinal;
begin
  Result := HasAttributes(SFGAO_FOLDER);
  if not Result then
    Exit;
//  if (AEnumSettings and SHCONTF_NONFOLDERS = 0) and AFast then
  if AEnumSettings and SHCONTF_NONFOLDERS = 0 then
    Result := HasAttributes(SFGAO_HASSUBFOLDER)
  else
  begin
    if CheckLocalFolder(Result) then
      Exit;
    Result := False;
    if Succeeded(AParentIFolder.BindToObject(GetLastPidlItem(AFullPIDL), nil, IID_IShellFolder,
      ATempIFolder)) then
        if ATempIFolder <> nil then
          if Succeeded(ATempIFolder.EnumObjects(0, AEnumSettings, AIEnum)) and Assigned(AIEnum) then
            if AIEnum.Next(1, ATempPIDL, AFetchedItemCount) = S_OK then
            try
              Result := AFetchedItemCount = 1;
            finally
              DisposePidl(ATempPIDL);
            end;
  end;
end;

function GetDesktopIShellFolder: IShellFolder;
begin
  OleCheck(SHGetDesktopFolder(Result));
end;

function GetTextFromStrRet(var AStrRet: TStrRet; APIDL: PitemIDList): WideString;
var
  P: PChar;
  ATmp: PChar;
begin
  case AStrRet.uType of
    STRRET_CSTR:
      begin
        ATmp := PChar(dxAnsiStringToString(AStrRet.cStr));
        SetString(Result, ATmp, lstrlen(ATmp));
      end;
    STRRET_OFFSET:
      begin
        P := @APIDL.mkid.abID;
        Inc(P, AStrRet.uOffset - SizeOf(APIDL.mkid.cb));
        SetString(Result, P, APIDL.mkid.cb - AStrRet.uOffset);
      end;
    STRRET_WSTR:
      begin
        Result := StrPasW(AStrRet.pOleStr);
        cxMalloc.Free(AStrRet.pOleStr);
      end;
  end;
end;

function GetShellDetails(pFolder:IShellFolder;pidl:PItemIDList;out sd:IShellDetails):Hresult;
begin
  try
    Result := pFolder.QueryInterface(IID_IShellDetails, sd);
    if Result = S_OK then
       Exit;
    Result:=pFolder.GetUIObjectOf(0,0,pidl,IID_IShellDetails,nil,sd);
    if Result = S_OK then
       Exit;
    Result:=pFolder.CreateViewObject(0,IID_IShellDetails,sd);
    if Result = S_OK then
       Exit;
    Result:=pFolder.GetUIObjectOf(0,Integer(pidl<>nil)(*1*),pidl,IID_IShellDetails,nil,sd);
  finally
    if sd = nil then
      Result := E_NOINTERFACE;
  end;
end;

function cxFileTimeToDateTime(fTime:FILETIME):TDateTime;
var
  LocalTime:TFileTime;
  Age:Integer;
begin
  FileTimeToLocalFileTime(FTime,LocalTime);
  if FileTimeToDosDateTime(LocalTime,LongRec(Age).Hi,LongRec(Age).Lo) then
     Result:=FileDateToDateTime(Age)
  else
     Result:=-1;
end;

function cxMalloc: IMalloc;
begin
  if FcxMalloc = nil then
    SHGetMalloc(FcxMalloc);
  Result := FcxMalloc;
end;

procedure TcxContextMenuMessageWindow.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_INITMENUPOPUP:
      begin
        ContextMenu.HandleMenuMsg(Message.Msg, Message.wParam, Message.lParam);
        Message.Result := 0;
      end;
    WM_DRAWITEM, WM_MEASUREITEM:
      begin
        ContextMenu.HandleMenuMsg(Message.Msg, Message.wParam, Message.lParam);
        Message.Result := 1;
      end;
    else
      inherited WndProc(Message);
  end;
end;

function CreateCallbackWnd(AContextMenu: IContextMenu2): TcxContextMenuMessageWindow;
begin
  Result := TcxContextMenuMessageWindow.Create;
  Result.ContextMenu := AContextMenu;
end;

procedure DisplayContextMenu(AWnd: HWND; AIFolder: IShellFolder;
  AItemPIDLList: TList; const APos: TPoint);
var
  ACallbackWnd: TcxContextMenuMessageWindow;
  ACmd: Longbool;
  AContextMenu: IContextMenu;
  AContextMenu2: IContextMenu2;
  AInvokeCommandInfo: TCMInvokeCommandInfo;
  AMenu: HMENU;
  APIDLList: PItemIDList;
begin
  if (AIFolder = nil) or (AItemPIDLList.Count = 0) then
    Exit;
  APIDLList := CreatePidlListFromList(AItemPIDLList);
  try
    if Failed(AIFolder.GetUIObjectOf(AWnd, AItemPIDLList.Count,
      PItemIDList(APIDLList^), IID_IContextMenu, nil, AContextMenu)) then
        Exit;
    AMenu := CreatePopupMenu;
    ACallbackWnd := nil;
    if AMenu <> 0 then
    try
      if Failed(AContextMenu.QueryContextMenu(AMenu, 0, 1, $7FFF, CMF_NORMAL)) then
        Exit;
      if Succeeded(AContextMenu.QueryInterface(IID_IContextMenu2, AContextMenu2)) then
        ACallbackWnd := CreateCallbackWnd(AContextMenu2);
      if ACallbackWnd <> nil then
        ACmd := TrackPopupMenu(AMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or
          TPM_RIGHTBUTTON or TPM_RETURNCMD, APos.X, APos.Y, 0, ACallbackWnd.Handle, nil)
      else
        ACmd := TrackPopupMenu(AMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or
          TPM_RIGHTBUTTON or TPM_RETURNCMD, APos.X, APos.Y, 0, AWnd, nil);
      if ACmd then
      begin
        ZeroMemory(@AInvokeCommandInfo, SizeOf(AInvokeCommandInfo));
        AInvokeCommandInfo.cbSize := SizeOf(AInvokeCommandInfo);
        AInvokeCommandInfo.hwnd := AWnd;
        AInvokeCommandInfo.lpVerb := MakeIntResourceA(Longint(ACmd) - 1);
        AInvokeCommandInfo.nShow := SW_SHOWNORMAL;
        AContextMenu.InvokeCommand(AInvokeCommandInfo);
      end;
    finally
      DestroyMenu(AMenu);
      FreeAndNil(ACallbackWnd);
    end;
  finally
    DisposePidl(APIDLList);
  end;
end;

function SysFileIconIndex: Integer;
var
  AFileInfo: TSHFileInfo;
begin
  if FSysFileIconIndex = -1 then
  begin
    SHGetFileInfo('C:\CXDUMMYFILE.TXT', FILE_ATTRIBUTE_NORMAL, AFileInfo,
      SizeOf(AFileInfo), SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
    FSysFileIconIndex := AFileInfo.iIcon;
  end;
  Result := FSysFileIconIndex;
end;

function SysFolderIconIndex: Integer;
var
  AFileInfo: TSHFileInfo;
begin
  if FSysFolderIconIndex = -1 then
  begin
    SHGetFileInfo('C:\CXDUMMYFOLDER', FILE_ATTRIBUTE_DIRECTORY, AFileInfo,
      SizeOf(AFileInfo), SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
    FSysFolderIconIndex := AFileInfo.iIcon;
  end;
  Result := FSysFolderIconIndex;
end;

function SysFolderOpenIconIndex: Integer;
var
  AFileInfo: TSHFileInfo;
begin
  if FSysFolderOpenIconIndex = -1 then
  begin
    SHGetFileInfo('C:\CXDUMMYFOLDER', FILE_ATTRIBUTE_DIRECTORY, AFileInfo,
      SizeOf(AFileInfo), SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES or SHGFI_OPENICON);
    FSysFolderOpenIconIndex := AFileInfo.iIcon;
  end;
  Result := FSysFolderOpenIconIndex;
end;

{ Unicode Tools }

function UpperCaseW(Source:WideString):WideString;
begin
  Result:=AnsiUpperCase(Source);
end;

function LowerCaseW(Source:WideString):WideString;
begin
  Result:=AnsiLowerCase(Source);
end;

function StrLenW(Source: PWideChar): Cardinal;
asm
  MOV     EDX, EDI
  MOV     EDI, EAX
  MOV     ECX, 0FFFFFFFFH
  XOR     AX, AX
  REPNE   SCASW
  MOV     EAX, 0FFFFFFFEH
  SUB     EAX, ECX
  MOV     EDI, EDX
end;

function StrPasW(Source:PWideChar):WideString;
var
  StringLength:Cardinal;
begin
  StringLength:=StrLenW(Source);
  SetLength(Result,StringLength);
  CopyMemory(Pointer(Result),Source,StringLength*2);
end;

procedure StrPLCopyW(Dest:PWideChar;Source:WideString;MaxLen:Cardinal);
begin 
  lstrcpynw(Dest,PWideChar(Source),MaxLen);
end;

{ PidlTools}

function GetPidlParent(pidl:PItemIDList):PItemIDList;
var
  SourceSize:Integer;
  PrevPidl:PItemIDList;
  InitialPidl:PItemIDList;
  TempPidl:PItemIDList;
begin
  Result:=nil;
  SourceSize:=0;
  InitialPidl:=pidl;
  PrevPidl:=nil;
  if pidl<>nil then
  begin
    while pidl.mkid.cb<>0 do
    begin
      Inc(SourceSize,pidl.mkid.cb);
      PrevPidl:=pidl;
      pidl:=GetNextItemID(pidl);
    end;
    if SourceSize>0 then
       Dec(SourceSize,PrevPidl.mkid.cb);
    Result:=cxMalloc.Alloc(SourceSize+SizeOf(SHITEMID));
    CopyMemory(Result,InitialPidl,SourceSize);
    TempPidl:=Pointer(Integer(Result)+SourceSize);
    TempPidl.mkid.cb:=0;
    TempPidl.mkid.abID[0]:=0;
  end;
end;

function CreateEmptyPidl:PItemIDList;
begin
  Result:=cxMalloc.Alloc(SizeOf(ITEMIDLIST));
  Result.mkid.cb:=0;
  Result.mkid.abID[0]:=0;
end;

function CreatePidlListFromList(List:TList):PItemIDList;
var
  i:Integer;
  tempResult:PITEMIDLISTARRAY;
begin
  Result:=nil;
  if List=nil then
     Exit;
  tempResult:=cxMalloc.Alloc(List.Count*SizeOf(ITEMIDLIST));
  for i:=0 to List.Count-1 do
      tempResult[i]:=List[i];
  Result:=Pointer(tempResult);
end;

function ExtractParticularPidl(pidl:PItemIDList):PItemIDList;
var
  temp:PItemIDList;
begin
  Result:=nil;
  if (pidl<>nil) and (pidl.mkid.cb<>0) then
  begin
    Result:=cxMalloc.Alloc(pidl.mkid.cb+SizeOf(SHITEMID));
    CopyMemory(Result,pidl,pidl.mkid.cb+SizeOf(SHITEMID));
  end;
  temp:=GetNextItemID(Result);
  temp.mkid.cb:=0;
  temp.mkid.abID[0]:=0;
end;

function EqualPIDLs(APIDL1, APIDL2: PItemIDList): Boolean;
var
  L1, L2: Integer;
begin
  Result := APIDL1 = APIDL2;
  if not Result then
    if (APIDL1 = nil) or (APIDL2 = nil) then
      Exit
    else
    begin
      L1 := GetPidlSize(APIDL1);
      L2 := GetPidlSize(APIDL2);
      Result := (L1 = L2) and CompareMem(APIDL1, APIDL2, L1);
    end;
end;

function IsSubPath(APIDL1, APIDL2: PItemIDList): Boolean; // TODO
var
  L1, L2: Integer;
begin
  L1 := GetPidlSize(APIDL1);
  L2 := GetPidlSize(APIDL2);
  Result := (L1 = 0) or (L2 >= L1) and CompareMem(APIDL1, APIDL2, L1);
end;

function ConcatenatePidls(pidl1,pidl2:PItemIDList):PItemIDList;
var
  cb1,cb2:Integer;
begin
  if (pidl1=nil) and (pidl2=nil) then
      Result:=nil
  else
  if pidl1=nil then
     Result:=GetPidlCopy(pidl2)
  else
  if pidl2=nil then
     Result:=GetPidlCopy(pidl1)
  else
  begin
    cb1:=GetPidlSize(pidl1);
    cb2:=GetPidlSize(pidl2)+SizeOf(SHITEMID);
    Result:=cxMalloc.Alloc(cb1+cb2);
    if Result<>nil then
    begin
      CopyMemory(Result,pidl1,cb1);
      CopyMemory(Pointer(Integer(Result)+cb1),pidl2,cb2);
    end;
  end;
end;

function GetPidlName(APIDL: PItemIDList): WideString;
var
  P: PChar;
  PW: PWideChar;
begin
  Result := '';
  if APIDL = nil then
    Exit;
  if not Assigned(cxSHGetPathFromIDListW) then
  begin
    GetMem(P, MAX_PATH + 1);
    try
      cxSHGetPathFromIDList(APIDL, P);
      Result := StrPas(P);
    finally
      FreeMem(P);
    end;
  end
  else
  begin
    GetMem(PW, (MAX_PATH + 1) * 2);
    try
      cxSHGetPathFromIDListW(APIDL, PW);
      Result := StrPasW(PW);
    finally
      FreeMem(PW);
    end;
  end;
end;

function GetLastPidlItem(pidl:PItemIDList):PItemIDList;
var
  TempPidl:PItemIDList;
begin
  Result:=pidl;
  if pidl<>nil then
  begin
    TempPidl:=pidl;
    while TempPidl.mkid.cb<>0 do
    begin
      Result:=TempPidl;
      TempPidl:=GetNextItemID(TempPidl);
    end;
  end;
end;

procedure DisposePidl(pidl:PItemIDList);
begin
  if pidl<>nil then
     cxMalloc.Free(pidl);
end;

function GetPidlCopy(pidl:PItemIDList):PItemIDList;
var
  Size:Integer;
begin
  Result:=nil;
  if pidl<>nil then
  begin
    Size:=GetPidlSize(pidl)+SizeOf(SHITEMID);
    Result:=cxMalloc.Alloc(Size);
    CopyMemory(Result,pidl,Size);
  end;
end;

function GetPidlItemsCount(pidl:PItemIDList):Integer;
begin
  Result:=0;
  if pidl<>nil then
  begin
    while pidl.mkid.cb<>0 do
    begin
      Inc(Result);
      pidl:=GetNextItemID(pidl);
      if Result>MAX_PATH then
      begin
        Result:=-1;
        Break;
      end;
    end;
  end;
end;

function GetPidlSize(pidl:PItemIDList):Integer;
begin
  Result:=0;
  while (pidl<>nil) and (pidl.mkid.cb<>0) do
  begin
    Inc(Result,pidl.mkid.cb);
    pidl:=GetNextItemID(pidl);
  end;
end;

function GetNextItemID(pidl:PItemIDList):PItemIDList;
begin
  Result:=nil;
  if (pidl<>nil) and (pidl.mkid.cb<>0) then
     Result:=PItemIDLIst(Integer(pidl)+pidl.mkid.cb);
end;

function cxShellItemsInfoGathererFetchThreadFunction(
  AItemsInfoGatherer: TcxShellItemsInfoGatherer): Integer; stdcall;

  function CanProcessFetchQueueItems: Boolean;
  begin
    Result := not AItemsInfoGatherer.IsFetchThreadTerminating and
      not AItemsInfoGatherer.IsFetchStopping;
  end;

  procedure ProcessFetchQueueItem(AItem: PcxRequestItem);
  var
    AItemData: TcxShellItemInfo;
    AItemProducer: TcxCustomItemProducer;
  begin
    AItemProducer := AItem^.ItemProducer;
    AItemProducer.LockRead;
    try
      if AItem^.ItemIndex >= AItemProducer.Items.Count then
        Exit;
      AItemData := AItemProducer.Items[AItem^.ItemIndex];
      AItemData.CheckUpdate(AItemProducer.ShellFolder,
        AItemProducer.FolderPidl, False);
      AItemProducer.CheckForSubItems(AItemData);
      AItemData.Updated := True;
    finally
      AItem^.ItemProducer.UnlockRead;
    end;
    AItemProducer.NotifyUpdateItem(AItem);
  end;

  procedure ProcessFetchQueueItems;
  var
    AFetchQueue: TList;
  begin
    AFetchQueue := AItemsInfoGatherer.FetchQueue;
    while AFetchQueue.Count <> 0 do
    begin
      ProcessFetchQueueItem(PcxRequestItem(AFetchQueue[0]));
      Dispose(AFetchQueue[0]);
      AFetchQueue.Delete(0);
      if not CanProcessFetchQueueItems then
        Break;
    end;
  end;

const
  cxShellItemsInfoGathererSleepPause = 10;
begin
  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  try
    repeat
      if CanProcessFetchQueueItems then
      begin
        AItemsInfoGatherer.FetchResumed;
        if AItemsInfoGatherer.FetchQueue.Count <> 0 then
          ProcessFetchQueueItems;
      end;
      if AItemsInfoGatherer.IsFetchThreadTerminating then
        Break;
      if AItemsInfoGatherer.IsFetchStopping then
        AItemsInfoGatherer.FetchStopped;
      Sleep(cxShellItemsInfoGathererSleepPause);
    until False;
    Result := 0;
  finally
    CoUninitialize;
  end;
end;

procedure RegisterShellItemsInfoGatherer(AGatherer: TcxShellItemsInfoGatherer);
begin
  if FShellItemsInfoGatherers = nil then
    FShellItemsInfoGatherers := TList.Create;
  FShellItemsInfoGatherers.Add(AGatherer);
end;

procedure UnregisterShellItemsInfoGatherer(AGatherer: TcxShellItemsInfoGatherer);
begin
  FShellItemsInfoGatherers.Remove(AGatherer);
  if FShellItemsInfoGatherers.Count = 0 then
    FreeAndNil(FShellItemsInfoGatherers);
end;

{ TcxCustomShellRoot }

procedure TcxCustomShellRoot.CheckRoot;
const
  ACSIDLs: array[TcxBrowseFolder] of Integer = (
    $00, $07, $0A, $19, $2E, $1F, $17, $16, $18, $2D,
    $03, $00, $10, $11, $04, $06, $14, $22, $0D, $27,
    $12, $28, $26, $02, $08, $0B, $07, $15
  );
var
  ABrowseFolder: TcxBrowseFolder;
  ACSIDL: Integer;
  ADesktopFolder: IShellFolder;
  AParsedCharCount, AAttributes: Cardinal;
  ATempCustomPath: PWideChar;
  ATempPIDL: PItemIDList;
begin
  if FIsRootChecking then
    Exit;

  ADesktopFolder := GetDesktopIShellFolder;
  ATempPIDL := nil;
  FValid := False;
  FShellFolder := nil;
  if FPidl <> nil then
  begin
    DisposePidl(FPidl);
    FPidl := nil;
  end;

  ABrowseFolder := BrowseFolder;
  if (ABrowseFolder = bfCustomPath) and (CustomPath = '') then
    ABrowseFolder := bfDesktop;

  FIsRootChecking := True;
  try
    try
      if ABrowseFolder = bfCustomPath then
      begin
        ATempCustomPath := StringToOleStr(CustomPath);
        OleCheck(ADesktopFolder.ParseDisplayName(ParentWindow, nil,
          ATempCustomPath, AParsedCharCount, ATempPIDL, AAttributes));
      end
      else
      begin
        ACSIDL := ACSIDLs[ABrowseFolder];
        if Win32MajorVersion < 5 then
          OleCheck(SHGetSpecialFolderLocation(ParentWindow, ACSIDL, ATempPIDL))
        else
          OleCheck(cxSHGetFolderLocation(ParentWindow, ACSIDL, 0, 0, ATempPIDL));
      end;
    except
      on E: Exception do
        if FRootChangingCount > 0 then
          raise EcxEditError.Create(E.Message)
        else
        begin
          RootUpdated;
          Exit;
        end;
    end;
    if ABrowseFolder = bfDesktop then
    begin
      FShellFolder := ADesktopFolder;
      FPidl := GetPidlCopy(ATempPIDL);
      FValid := True;
      FAttributes := SFGAO_FILESYSTEM;
      RootUpdated;
    end
    else
      Pidl := ATempPIDL;
  finally
    FIsRootChecking := False;
    if ATempPIDL <> nil then
      DisposePidl(ATempPIDL);
  end;
end;

procedure TcxCustomShellRoot.DoSettingsChanged;
begin
  if not FUpdating and Assigned(FOnSettingsChanged) then
    FOnSettingsChanged(Self);
end;

procedure TcxCustomShellRoot.RootUpdated;
begin
  UpdateFolder;
end;

procedure TcxCustomShellRoot.SetPidl(const Value: PItemIDList);
var
  DesktopFolder:IShellFolder;
  pFolder:IShellFolder;
begin
  if Value = nil then
     Exit;
  if FPidl<>nil then
  begin
    DisposePidl(FPidl);
    FPidl:=nil;
    FValid:=False;
    FAttributes:=0;
  end;
  if Failed(SHGetDesktopFolder(DesktopFolder)) then
     Exit;
  if Succeeded(DesktopFolder.BindToObject(Value,nil,IID_IShellFolder, pFolder)) then
  begin
    FShellFolder:=pFolder;
    FPidl:=GetPidlCopy(Value);
    FValid:=True;
    FAttributes:=0;
    if Failed(DesktopFolder.GetAttributesOf(1,FPidl,FAttributes)) then
       FAttributes:=0;
  end
  else
  begin
    FShellFolder:=DesktopFolder;
    FPidl:=GetPidlCopy(Value);
    FValid:=True;
    FAttributes:=SFGAO_FILESYSTEM;
  end;
  RootUpdated;
end;

constructor TcxCustomShellRoot.Create(AOwner: TPersistent; AParentWindow: HWND);
begin
  inherited Create;
  FOwner := AOwner;
  FParentWindow := AParentWindow;
  FBrowseFolder := bfDesktop;
  FCustomPath := '';
  FShellFolder := nil;
  FPidl := nil;
end;

destructor TcxCustomShellRoot.Destroy;
begin
  FreeAndNil(FFolder);
  FShellFolder := nil;
  DisposePidl(FPidl);
  inherited;
end;

procedure TcxCustomShellRoot.Assign(Source: TPersistent);
var
  APrevBrowseFolder: TcxBrowseFolder;
  APrevCustomPath: WideString;
begin
  if Source is TcxCustomShellRoot then
  begin
    APrevBrowseFolder := FBrowseFolder;
    APrevCustomPath := FCustomPath;
    try
      FBrowseFolder := TcxCustomShellRoot(Source).FBrowseFolder;
      FCustomPath := TcxCustomShellRoot(Source).FCustomPath;
      Inc(Self.FRootChangingCount);
      try
        CheckRoot;
      finally
        Dec(FRootChangingCount);
      end;
      DoSettingsChanged;
    except
      FBrowseFolder := APrevBrowseFolder;
      FCustomPath := APrevCustomPath;
      CheckRoot;
      raise;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomShellRoot.Update(ARoot: TcxCustomShellRoot);
begin
  if FUpdating then
    Exit;
  FUpdating := True;
  try
    Assign(ARoot);
  finally
    FUpdating := False;
  end;
end;

procedure TcxCustomShellRoot.SetBrowseFolder(Value: TcxBrowseFolder);
var
  APrevBrowseFolder: TcxBrowseFolder;
begin
  APrevBrowseFolder := FBrowseFolder;
  try
    Inc(FRootChangingCount);
    try
      if FBrowseFolder <> Value then
      begin
        FBrowseFolder := Value;
        CheckRoot;
      end
      else
        if Pidl = nil then
          CheckRoot;
    finally
      Dec(FRootChangingCount);
    end;
    DoSettingsChanged;
  except
    FBrowseFolder := APrevBrowseFolder;
    CheckRoot;
    raise;
  end;
end;

procedure TcxCustomShellRoot.SetCustomPath(const Value: WideString);
var
  APrevCustomPath: WideString;
begin
  APrevCustomPath := FCustomPath;
  try
    FCustomPath := Value;
    Inc(FRootChangingCount);
    try
      if BrowseFolder = bfCustomPath then
        CheckRoot;
    finally
      Dec(FRootChangingCount);
    end;
    DoSettingsChanged;
  except
    FCustomPath := APrevCustomPath;
    CheckRoot;
    raise;
  end;
end;

function TcxCustomShellRoot.GetCurrentPath: WideString;
var
  Desktop:IShellFolder;
  StrName:TStrRet;
begin
  Result:='';
  if Pidl<>nil then
  begin
    if Failed(SHGetDesktopFolder(Desktop)) then
       Exit;
    if Succeeded(Desktop.GetDisplayNameOf(Pidl,SHGDN_NORMAL or SHGDN_FORPARSING,StrName)) then
       Result:=GetTextFromStrRet(StrName,Pidl);
  end;
end;

procedure TcxCustomShellRoot.UpdateFolder;
begin
  FreeAndNil(FFolder);
  FFolder := TcxShellFolder.Create(PIDL);
end;

{ TcxCustomItemProducer }

procedure TcxCustomItemProducer.ClearItems;

  (*function HasItems: Boolean;
  begin
    LockRead;
    try
      Result := Items.Count <> 0;
    finally
      UnlockRead;
    end;
  end;*)

var
  I: Integer;
begin
  //if HasItems then
  begin
    ClearFetchQueue;
    for I := 0 to Items.Count - 1 do
      TcxShellItemInfo(Items[I]).Free;
    Items.Clear;
  end;
  FShellFolder := nil;
  if FFolderPidl <> nil then
  begin
    DisposePidl(FFolderPidl);
    FFolderPidl := nil;
  end;
end;

constructor TcxCustomItemProducer.Create(AOwner: TWinControl);
begin
  inherited Create;
  FOwner := AOwner;
  FDetails := TcxShellDetails.Create;
  FItems := TList.Create;
  FItemsLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TcxCustomItemProducer.RequestItemsInfo;
var
  I: Integer;
begin
  ItemsInfoGatherer.StopFetch;
  try
    for I := 0 to Items.Count - 1 do
      if not TcxShellItemInfo(Items[I]).Updated then
        FetchRequest(I, False);
  finally
    ItemsInfoGatherer.ResumeFetch;
  end;
end;

destructor TcxCustomItemProducer.Destroy;
begin
  ClearItems;
  FreeAndNil(FDetails);
  FreeAndNil(FItems);
  FreeAndNil(FItemsLock);
  inherited Destroy;
end;

procedure TcxCustomItemProducer.LockRead;
begin
  ItemsLock.BeginRead;
end;

procedure TcxCustomItemProducer.LockWrite;
begin
  ItemsLock.BeginWrite;
end;

procedure TcxCustomItemProducer.ProcessItems(AIFolder: IShellFolder;
  AFolderPIDL: PItemIDList; cPreloadItems: Integer);
begin
  if FFolderPidl <> nil then
  begin
    DisposePidl(FFolderPidl);
    FFolderPidl := nil;
  end;
  FShellFolder := AIFolder;
  FFolderPidl := GetPidlCopy(AFolderPIDL);
  ProcessDetails(ShellFolder, cPreloadItems);
  FetchItems(cPreloadItems);
  if AllowBackgroundProcessing then
    RequestItemsInfo;
end;

procedure TcxCustomItemProducer.SetItemsCount(Count: Integer);
begin
  if Owner.HandleAllocated then
     SendMessage(Owner.Handle,DSM_SETCOUNT,Count,0);
end;

procedure TcxCustomItemProducer.UnlockRead;
begin
  ItemsLock.EndRead;
end;

procedure TcxCustomItemProducer.UnlockWrite;
begin
  ItemsLock.EndWrite;
end;

procedure TcxCustomItemProducer.NotifyRemoveItem(Index: Integer);
begin
  if Owner.HandleAllocated then
     SendMessage(Owner.Handle,DSM_NOTIFYREMOVEITEM,Index,0);
end;

procedure TcxCustomItemProducer.NotifyAddItem(Index: Integer);
begin
  if Owner.HandleAllocated then
     SendMessage(Owner.Handle,DSM_NOTIFYADDITEM,Index,0);
end;

procedure TcxCustomItemProducer.InitializeItem(Item:TcxShellItemInfo);
begin
  // Do nothing by default
end;

function TcxCustomItemProducer.CanAddFolder(AFolder: TcxShellFolder): Boolean;
begin
  Result := True;
end;

function TcxCustomItemProducer.DoCompareItems(AItem1, AItem2: TcxShellFolder;
  out ACompare: Integer): Boolean;
begin
  Result := False;
end;

procedure TcxCustomItemProducer.DoSort;

  function ShellSortFunction(Item1, Item2: Pointer): Integer;
  const
    R: array[Boolean] of Byte = (0, 1);
  var
    AItemInfo1, AItemInfo2: TcxShellItemInfo;
  begin
    AItemInfo1 := TcxShellItemInfo(Item1);
    AItemInfo2 := TcxShellItemInfo(Item2);
    if not AItemInfo1.ItemProducer.DoCompareItems(AItemInfo1.Folder, AItemInfo2.Folder, Result) then
    begin
      Result := R[AItemInfo2.IsFolder] - R[AItemInfo1.IsFolder];
      if Result = 0 then
        Result := SmallInt(AItemInfo1.ItemProducer.ShellFolder.CompareIDs(0, AItemInfo1.pidl, AItemInfo2.pidl));
    end;
  end;

begin
  Items.Sort(@ShellSortFunction);
end;

procedure TcxCustomItemProducer.FetchItems(cPreloadItems:Integer);
const
  R: array[Boolean] of Byte = (0, 1);
var
  pEnum:IEnumIDList;
  currentCelt:Cardinal;
  rPidl:PItemIDList;
  Item:TcxShellItemInfo;
  Res:HRESULT;
  SaveCursor:TCursor;
  PreloadInfo:Integer;

begin
  if Succeeded(ShellFolder.EnumObjects(Owner.ParentWindow, GetEnumFlags, pEnum)) and
    Assigned(pEnum) then
  begin
    currentCelt:=1;
    PreloadInfo:=cPreloadItems;
    LockWrite;
    SaveCursor:=Screen.Cursor;
    try
      try
        Screen.Cursor:=crHourGlass;
        repeat
          Res:=pEnum.Next(currentCelt,rPidl,currentCelt);
          if Res=E_INVALIDARG then
          begin
            currentCelt:=1;
            Res:=pEnum.Next(currentCelt,rPidl,currentCelt);
          end;
          if Failed(Res) or (Res=S_FALSE) then
             Break;
          if (currentCelt=0) or (rPidl=nil) then
             Break;
          try
            Item:=TcxShellItemInfo.Create(Self, ShellFolder, FFolderPidl, rPidl, False);
            if (Item.Name = '') or not CanAddFolder(Item.Folder) then
            begin
              Item.Free;
              Continue;
            end;
            if PreloadInfo>0 then
            begin
              Item.CheckUpdate(ShellFolder,FolderPidl,False);
              Dec(PreloadInfo);
            end
            else
              InitializeItem(Item);
            Items.Add(Item);
          finally
            DisposePidl(rPidl);
          end;
        until(Res=S_FALSE);
        Sort;
      finally
        UnlockWrite;
      end;
    finally
      Screen.Cursor:=SaveCursor;
    end;
  end;
  SetItemsCount(Items.Count);
end;

procedure TcxCustomItemProducer.ProcessDetails(ShellFolder: IShellFolder;
  CharWidth: Integer);
var
  DesktopFolder:IShellFolder;
  Attr:Cardinal;
  tempPidl:PitemIDList;
begin
  if Failed(SHGetDesktopFolder(DesktopFolder)) then
     Exit;
  Attr:=0;
  tempPidl:=GetPidlCopy(FolderPidl);
  try
    if Failed(DesktopFolder.GetAttributesOf(1,tempPidl,Attr)) then
       Attr:=0;
    Details.ProcessDetails(CharWidth,ShellFolder,(Attr and SFGAO_FILESYSTEM)=SFGAO_FILESYSTEM);
  finally
    DisposePidl(tempPidl);
  end;
end;

procedure TcxCustomItemProducer.DoGetInfoTip(Handle:HWND;ItemIndex: Integer;
  InfoTip: PChar; cch: Integer);
var
  ATempShellItem: TcxShellItemInfo;
  ATempPidl: PItemIDList;
  AQueryInfo: IQueryInfo;
  AInfoStr: PWideChar;
{$IFNDEF DELPHI12}ADefaultChar: Char;{$ENDIF}
begin
  if GetShowToolTip then
  begin
    if ItemIndex > Items.Count - 1 then
       Exit;
    ATempShellItem := Items[ItemIndex];
    ATempPidl := GetPidlCopy(ATempShellItem.pidl);
    try
      if Succeeded(ShellFolder.GetUIObjectOf(Handle, 1, ATempPidl, IQueryInfo, nil, AQueryInfo)) and
        Succeeded(AQueryInfo.GetInfoTip(0, AInfoStr)) and (AInfoStr <> nil) then
      begin
      {$IFDEF DELPHI12}
        StrLCopy(InfoTip, AInfoStr, cch);
      {$ELSE}
        ADefaultChar := #$7F;
        cch := WideCharToMultiByte(0, 0, AInfoStr, -1, nil, 0, @ADefaultChar, nil);
        WideCharToMultiByte(0, 0, AInfoStr, -1, InfoTip, cch, @ADefaultChar, nil);
        StrPLCopy(InfoTip, StringReplace(InfoTip, ADefaultChar, '', [rfReplaceAll]), cch);
      {$ENDIF}
        cxMalloc.Free(AInfoStr);
      end;
    finally
      DisposePidl(ATempPidl);
    end;
  end
  else
    StrPLCopy(InfoTip, '', cch);
end;

function TcxCustomItemProducer.GetItemByPidl(
  apidl: PItemIDList): TcxShellItemInfo;
var
  i:Integer;
  tempItem:TcxShellItemInfo;
begin
  Result:=nil;
  LockRead;
  try
    for i:=0 to Items.Count-1 do
    begin
      tempItem:=Items[i];
      if SmallInt(ShellFolder.CompareIDs(0,tempItem.pidl,apidl))=0 then
      begin
        Result:=tempItem;
        Break;
      end;
    end;
  finally
    UnlockRead;
  end;
end;

function TcxCustomItemProducer.GetItemIndexByPidl(
  apidl: PItemIDList): Integer;
var
  i:Integer;
  tempItem:TcxShellItemInfo;
begin
  Result:=-1;
  LockRead;
  try
    for i:=0 to Items.Count-1 do
    begin
      tempItem:=Items[i];
      if SmallInt(ShellFolder.CompareIDs(0,tempItem.pidl,apidl))=0 then
      begin
        Result:=i;
        Break;
      end;
    end;
  finally
    UnlockRead;
  end;
end;

procedure TcxCustomItemProducer.Sort;
begin
  LockWrite;
  try
    DoSort;
  finally
    UnlockWrite;
  end;
end;

procedure TcxCustomItemProducer.FetchRequest(AIndex: Integer;
  APriority: Boolean = False);
begin
  ItemsInfoGatherer.RequestItemInfo(Self, AIndex, APriority);
end;

procedure TcxCustomItemProducer.ClearFetchQueue;
begin
  ItemsInfoGatherer.ClearFetchQueue(Self);
end;

procedure TcxCustomItemProducer.CheckForSubitems(AItem: TcxShellItemInfo);
begin
end;

{ TcxShellItemsInfoGatherer }

constructor TcxShellItemsInfoGatherer.Create(AOwner: TWinControl);
begin
  inherited Create;
  FOwner := AOwner;
  FFetchQueue := TList.Create;
  CreateFetchThread;
  RegisterShellItemsInfoGatherer(Self);
end;

destructor TcxShellItemsInfoGatherer.Destroy;
begin
  UnregisterShellItemsInfoGatherer(Self);
  DestroyFetchThread;
  FreeAndNil(FFetchQueue);
  inherited Destroy;
end;

procedure TcxShellItemsInfoGatherer.ClearFetchQueue(
  AItemProducer: TcxCustomItemProducer);

  procedure InternalClearFetchQueue;
  var
    AItem: PcxRequestItem;
    I: Integer;
  begin
    I := 0;
    while I < FetchQueue.Count do
    begin
      AItem := FetchQueue[I];
      if (AItemProducer = nil) or (AItem.ItemProducer = AItemProducer) then
      begin
        FetchQueue.Remove(AItem);
        Dispose(AItem);
      end
      else
        Inc(I);
    end;
  end;

begin
  if FIsFetchQueueClearing then
    Exit;
  FIsFetchQueueClearing := True;
  StopFetch;
  try
    InternalClearFetchQueue;
  finally
    FIsFetchQueueClearing := False;
    ResumeFetch;
  end;
end;

procedure TcxShellItemsInfoGatherer.RequestItemInfo(
  AItemProducer: TcxCustomItemProducer; AIndex: Integer; APriority: Boolean);
var
  AItemIndex: Integer;
begin
  StopFetch;
  try
    AItemIndex := GetFetchQueueItemIndex(FetchQueue, AItemProducer, AIndex);
    if AItemIndex = -1 then
    begin
      if APriority then
        FetchQueue.Insert(0, CreateRequestItem(AItemProducer, AIndex, True))
      else
        FetchQueue.Add(CreateRequestItem(AItemProducer, AIndex, False));
    end
    else
      if APriority then
        FetchQueue.Move(AItemIndex, 0);
  finally
    ResumeFetch;
  end;
end;

procedure TcxShellItemsInfoGatherer.ResumeFetch;
begin
  if FStopFetchCount > 0 then
  begin
    Dec(FStopFetchCount);
    if FStopFetchCount = 0 then
      ResetEvent(FStopFetchEvent);
  end;
end;

procedure TcxShellItemsInfoGatherer.StopFetch;
begin
  Inc(FStopFetchCount);
  if FStopFetchCount = 1 then
  begin
    SetEvent(FStopFetchEvent);
    WaitForSingleObject(FFetchStoppedEvent, INFINITE);
  end;
end;

procedure TcxShellItemsInfoGatherer.DestroyFetchThread;
begin
  TerminateFetchThread;
  InternalCloseHandle(FFetchThread);
  InternalCloseHandle(FFetchStoppedEvent);
  InternalCloseHandle(FStopFetchEvent);
  InternalCloseHandle(FTerminateFetchThreadEvent);
end;

procedure TcxShellItemsInfoGatherer.CreateFetchThread;
var
  AFetchThreadID: DWORD;
begin
  FFetchStoppedEvent := CreateEvent(nil, True, False, nil);
  FStopFetchEvent := CreateEvent(nil, True, False, nil);
  FTerminateFetchThreadEvent := CreateEvent(nil, True, False, nil);
  FFetchThread := CreateThread(nil, 0,
    @cxShellItemsInfoGathererFetchThreadFunction, Self, 0, AFetchThreadID);
end;

function TcxShellItemsInfoGatherer.CreateRequestItem(
  AItemProducer: TcxCustomItemProducer; AIndex: Integer;
  APriority: Boolean): PcxRequestItem;
begin
  New(Result);
  Result.ItemIndex := AIndex;
  Result.ItemProducer := AItemProducer;
  Result.Priority := APriority;
end;

function TcxShellItemsInfoGatherer.GetFetchQueueItemIndex(
  AFetchQueue: TList; AItemProducer: TcxCustomItemProducer;
  AIndex: Integer): Integer;
var
  APItem: PcxRequestItem;
  I: Integer;
begin
  Result := -1;
  for I := 0 to AFetchQueue.Count - 1 do
  begin
    APItem := AFetchQueue[I];
    if (APItem.ItemIndex = AIndex) and (APItem.ItemProducer = AItemProducer) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TcxShellItemsInfoGatherer.GetIsFetchStopping: Boolean;
begin
  Result := WaitForSingleObject(FStopFetchEvent, 0) = WAIT_OBJECT_0;
end;

function TcxShellItemsInfoGatherer.GetIsFetchThreadTerminating: Boolean;
begin
  Result := WaitForSingleObject(FTerminateFetchThreadEvent, 0) = WAIT_OBJECT_0;
end;

procedure TcxShellItemsInfoGatherer.FetchResumed;
begin
  ResetEvent(FFetchStoppedEvent);
end;

procedure TcxShellItemsInfoGatherer.FetchStopped;
begin
  SetEvent(FFetchStoppedEvent);
end;

procedure TcxShellItemsInfoGatherer.InternalCloseHandle(var AHandle: THandle);
begin
  CloseHandle(AHandle);
  AHandle := 0;
end;

procedure TcxShellItemsInfoGatherer.TerminateFetchThread;
begin
  SetEvent(FTerminateFetchThreadEvent);
  WaitForSingleObject(FFetchThread, INFINITE);
end;

{ TcxShellFolder }

constructor TcxShellFolder.Create(AAbsolutePIDL: PItemIDList);
var
  AParentPIDL: PItemIDList;
begin
  inherited Create;
  FAbsolutePIDL := AAbsolutePIDL;
  if GetPIDLItemsCount(FAbsolutePIDL) <= 1 then
  begin
    FParentShellFolder := GetDesktopIShellFolder;
    FRelativePIDL := GetPIDLCopy(FAbsolutePIDL);
  end
  else
  begin
    AParentPIDL := GetPIDLParent(FAbsolutePIDL);
    try
      GetDesktopIShellFolder.BindToObject(AParentPIDL, nil, IID_IShellFolder,
        FParentShellFolder);
    finally
      DisposePidl(AParentPIDL);
    end;
    FRelativePIDL := GetPIDLCopy(GetLastPIDLItem(FAbsolutePIDL));
  end;
end;

destructor TcxShellFolder.Destroy;
begin
  DisposePIDL(FRelativePIDL);
  inherited Destroy;
end;

function TcxShellFolder.GetAttributes: TcxShellFolderAttributes;

  procedure CheckAttribute(AShellAttributes, AAttributeShellAttribute: LongWord;
    AAttribute: TcxShellFolderAttribute);
  begin
    if HasShellAttribute(AShellAttributes, AAttributeShellAttribute) then
      Include(Result, AAttribute);
  end;

var
  AShellAttributes: LongWord;
begin
  AShellAttributes := GetShellAttributes(SFGAO_DISPLAYATTRMASK);
  Result := [];
  CheckAttribute(AShellAttributes, cxSFGAO_GHOSTED, sfaGhosted);
  CheckAttribute(AShellAttributes, SFGAO_HIDDEN, sfaHidden);
  CheckAttribute(AShellAttributes, SFGAO_ISSLOW, sfaIsSlow);
  CheckAttribute(AShellAttributes, SFGAO_LINK, sfaLink);
  CheckAttribute(AShellAttributes, SFGAO_READONLY, sfaReadOnly);
  CheckAttribute(AShellAttributes, SFGAO_SHARE, sfaShare);
end;

function TcxShellFolder.GetCapabilities: TcxShellFolderCapabilities;

  procedure CheckCapability(AShellAttributes, ACapabilityShellAttribute: LongWord;
    ACapability: TcxShellFolderCapability);
  begin
    if HasShellAttribute(AShellAttributes, ACapabilityShellAttribute) then
      Include(Result, ACapability);
  end;

var
  AShellAttributes: LongWord;
begin
  AShellAttributes := GetShellAttributes(SFGAO_CAPABILITYMASK);
  Result := [];
  CheckCapability(AShellAttributes, SFGAO_CANCOPY, sfcCanCopy);
  CheckCapability(AShellAttributes, SFGAO_CANDELETE, sfcCanDelete);
  CheckCapability(AShellAttributes, SFGAO_CANLINK, sfcCanLink);
  CheckCapability(AShellAttributes, SFGAO_CANMOVE, sfcCanMove);
  CheckCapability(AShellAttributes, SFGAO_CANRENAME, sfcCanRename);
  CheckCapability(AShellAttributes, SFGAO_DROPTARGET, sfcDropTarget);
  CheckCapability(AShellAttributes, SFGAO_HASPROPSHEET, sfcHasPropSheet);
end;

function TcxShellFolder.GetDisplayName: string;
begin
  Result := InternalGetDisplayName(ParentShellFolder, RelativePIDL, SHGDN_INFOLDER);
end;

function TcxShellFolder.GetIsFolder: Boolean;
begin
  Result := HasShellAttribute(SFGAO_FOLDER);
end;

function TcxShellFolder.GetPathName: string;

  function GetDisplayName(ANameType: DWORD): string;
  begin
    Result := InternalGetDisplayName(GetDesktopIShellFolder, AbsolutePIDL, ANameType);
  end;

begin
  Result := InternalGetDisplayName(GetDesktopIShellFolder, AbsolutePIDL, SHGDN_FORPARSING);
  if Pos('::{', Result) = 1 then
    Result := InternalGetDisplayName(GetDesktopIShellFolder, AbsolutePIDL, SHGDN_NORMAL);
end;

function TcxShellFolder.GetProperties: TcxShellFolderProperties;

  procedure CheckProperty(AShellAttributes, APropertyShellAttribute: LongWord;
    AProperty: TcxShellFolderProperty);
  begin
    if HasShellAttribute(AShellAttributes, APropertyShellAttribute) then
      Include(Result, AProperty);
  end;

var
  AShellAttributes: LongWord;
begin
  AShellAttributes := GetShellAttributes(SFGAO_BROWSABLE or SFGAO_COMPRESSED or
    SFGAO_ENCRYPTED or SFGAO_NEWCONTENT or SFGAO_NONENUMERATED or SFGAO_REMOVABLE);
  Result := [];
  CheckProperty(AShellAttributes, SFGAO_BROWSABLE, sfpBrowsable);
  CheckProperty(AShellAttributes, SFGAO_COMPRESSED, sfpCompressed);
  CheckProperty(AShellAttributes, SFGAO_ENCRYPTED, sfpEncrypted);
  CheckProperty(AShellAttributes, SFGAO_NEWCONTENT, sfpNewContent);
  CheckProperty(AShellAttributes, SFGAO_NONENUMERATED, sfpNonEnumerated);
  CheckProperty(AShellAttributes, SFGAO_REMOVABLE, sfpRemovable);
end;

function TcxShellFolder.GetShellAttributes(ARequestedAttributes: LongWord): LongWord;
begin
  ParentShellFolder.GetAttributesOf(1, FRelativePIDL, ARequestedAttributes);
  Result := ARequestedAttributes;
end;

function TcxShellFolder.GetShellFolder: IShellFolder;
begin
  if GetPIDLItemsCount(AbsolutePIDL) = 0 then
    Result := GetDesktopIShellFolder
  else
    GetDesktopIShellFolder.BindToObject(AbsolutePIDL, nil, IID_IShellFolder, Result);
end;

function TcxShellFolder.GetStorageCapabilities: TcxShellFolderStorageCapabilities;

  procedure CheckStorageCapability(AShellAttributes, AStorageCapabilityShellAttribute: LongWord;
    AStorageCapability: TcxShellFolderStorageCapability);
  begin
    if HasShellAttribute(AShellAttributes, AStorageCapabilityShellAttribute) then
      Include(Result, AStorageCapability);
  end;

var
  AShellAttributes: LongWord;
begin
  AShellAttributes := GetShellAttributes(SFGAO_STORAGECAPMASK);
  Result := [];
  CheckStorageCapability(AShellAttributes, SFGAO_FILESYSANCESTOR, sfscFileSysAncestor);
  CheckStorageCapability(AShellAttributes, SFGAO_FILESYSTEM, sfscFileSystem);
  CheckStorageCapability(AShellAttributes, SFGAO_FOLDER, sfscFolder);
  CheckStorageCapability(AShellAttributes, SFGAO_LINK, sfscLink);
  CheckStorageCapability(AShellAttributes, SFGAO_READONLY, sfscReadOnly);
  CheckStorageCapability(AShellAttributes, SFGAO_STORAGE, sfscStorage);
  CheckStorageCapability(AShellAttributes, SFGAO_STORAGEANCESTOR, sfscStorageAncestor);
  CheckStorageCapability(AShellAttributes, SFGAO_STREAM, sfscStream);
end;

function TcxShellFolder.GetSubFolders: Boolean;
begin
  Result := HasShellAttribute(SFGAO_HASSUBFOLDER);
end;

function TcxShellFolder.HasShellAttribute(AAttribute: LongWord): Boolean;
begin
  Result := HasShellAttribute(GetShellAttributes(AAttribute), AAttribute);
end;

function TcxShellFolder.HasShellAttribute(AAttributes, AAttribute: LongWord): Boolean;
begin
  Result := AAttributes and AAttribute <> 0;
end;

function TcxShellFolder.InternalGetDisplayName(AFolder: IShellFolder;
  APIDL: PItemIDList; ANameType: DWORD): string;
var
  AStrRet: TStrRet;
begin
  AFolder.GetDisplayNameOf(APIDL, ANameType, AStrRet);
  Result := GetTextFromStrRet(AStrRet, APIDL);
end;

{ TcxShellItemInfo }

procedure TcxShellItemInfo.CheckInitialize(AIFolder: IShellFolder;
  APIDL: PItemIDList);
var
  AAttributes: Cardinal;
begin
  if Initialized then
    Exit;

  AAttributes := SFGAO_FOLDER;
  if Succeeded(AIFolder.GetAttributesOf(1, APIDL, AAttributes)) then
    FIsFolder := AAttributes and SFGAO_FOLDER <> 0
  else
  begin
    FIsFolder := False;
    FIsFilesystem := False;
    FIsDropTarget := True;
    FCanRename := True;
  end;
  if IsFolder then
    FHasSubfolder := True
  else
    FHasSubfolder := False;
  FName := GetShellItemDisplayName(AIFolder, APIDL, IsFolder);
  if IsFolder then
  begin
    FIconIndex := sysFolderIconIndex;
    FOpenIconIndex := sysFolderOpenIconIndex;
  end
  else
  begin
    FIconIndex := sysFileIconIndex;
    FOpenIconIndex := sysFileIconIndex;
  end;
  FInitialized := True;
end;

{ TcxShellItemInfo }

procedure TcxShellItemInfo.CheckSubitems(AParentIFolder: IShellFolder;
  AEnumSettings: Cardinal);
begin
  FHasSubfolder := HasSubItems(AParentIFolder, FFullPIDL, AEnumSettings);
end;

procedure TcxShellItemInfo.CheckUpdate(ShellFolder: IShellFolder;
                  FolderPidl:PItemIDList;Fast:Boolean);
var
  attr:Cardinal;
  FileInfo:TShFileInfo;
  fqPidl:PItemIDList;
  Flags:Cardinal;
  pszName:PChar;
  tempPidl:PItemIDList;
begin
  if Updated or Updating then
     Exit;
  Updating:=True;
  try
    Assert(pidl<>nil,'Item object not initialized');
    if pidl=nil then
       Exit;
    fqPidl:=ConcatenatePidls(FolderPidl,pidl);
    try
      attr:=0;
      tempPidl:=pidl;
      CheckInitialize(ShellFolder,tempPidl);
      if Fast then
      begin
        if not IsFolder then
        begin
          GetMem(pszName,MAX_PATH);
          try
            StrPLCopy(pszName,Name,MAX_PATH);
            SHGetFileInfo(pszName,FILE_ATTRIBUTE_NORMAL,FileInfo,SizeOf(TShFileInfo),
                                      SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
            FIconIndex:=FileInfo.iIcon;
            SHGetFileInfo(pszName,FILE_ATTRIBUTE_NORMAL,FileInfo,SizeOf(TShFileInfo),
                                      SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES or
                                      SHGFI_OPENICON);
            FOpenIconIndex:=FileInfo.iIcon;
          finally
            FreeMem(pszName);
          end;
        end
        else
        begin
          Flags:=SHGFI_PIDL or SHGFI_SYSICONINDEX;
          SHGetFileInfo(PChar(fqPidl),0,FileInfo,SizeOf(FileInfo),Flags);
          FIconIndex:=FileInfo.iIcon;
        end;
      end
      else
      begin
         // Processing attributes
         if Succeeded(ShellFolder.GetAttributesOf(1,TempPidl,attr)) then
            FIsFilesystem:=(attr and SFGAO_FILESYSTEM)=SFGAO_FILESYSTEM;
         attr:=SFGAO_HIDDEN or SFGAO_SHARE or SFGAO_LINK or SFGAO_REMOVABLE;
         if Succeeded(ShellFolder.GetAttributesOf(1,TempPidl,attr)) then
         begin
           FIsGhosted:=(attr and SFGAO_HIDDEN)=SFGAO_HIDDEN;
           FIsShare:=(attr and SFGAO_SHARE)=SFGAO_SHARE;
           FIsLink:=(attr and SFGAO_LINK)=SFGAO_LINK;
           FIsRemovable:=(attr and SFGAO_REMOVABLE)=SFGAO_REMOVABLE;
         end;
         attr:=SFGAO_CAPABILITYMASK;
         if Succeeded(ShellFolder.GetAttributesOf(1,TempPidl,attr)) then
         begin
           FIsDropTarget:=(attr and SFGAO_DROPTARGET)=SFGAO_DROPTARGET;
           FCanRename:=(attr and SFGAO_CANRENAME)=SFGAO_CANRENAME;
         end;
         // Processing icons
         Flags:=SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_TYPENAME;
         SHGetFileInfo(PChar(fqPidl),0,FileInfo,SizeOf(FileInfo),Flags);
         FIconIndex:=FileInfo.iIcon;
         if FIsFolder then
            SHGetFileInfo(PChar(fqPidl),0,FileInfo,SizeOf(FileInfo),Flags or SHGFI_OPENICON);
         FOpenIconIndex:=FileInfo.iIcon;
         Updated:=True;
      end;
    finally
      DisposePidl(fqPidl);
    end;
  finally
    Updating:=False;
  end;
end;

constructor TcxShellItemInfo.Create(AItemProducer: TcxCustomItemProducer;
  AParentIFolder: IShellFolder; AParentPIDL, APIDL: PItemIDList;
  AFast: Boolean);
var
  AWithoutAV: Boolean;
begin
  inherited Create;
  FItemProducer := AItemProducer;
  // the following code required to get rid of bug, that occasionally appeared
  // on Windows XP. The pidl received from thr shell, anothed memory block
  // allocated internally, but occasionally appeared exception thad CopyMemory
  // can't be performed
  FDetails := TStringList.Create;
  repeat
    try
      FPIDL := GetPidlCopy(APIDL);
      AWithoutAV := True;
    except
      AWithoutAV := False;
    end;
  until AWithoutAV;
  if not AFast then
    CheckInitialize(AParentIFolder, APIDL)
  else
  begin
    FName := ' ';
    FIconIndex := sysFileIconIndex;
    FOpenIconIndex := sysFileIconIndex;
  end;
  FInfoTip := '';
  FUpdated := False;
  FUpdating := False;
  FFullPIDL := ConcatenatePidls(AParentPIDL, APIDL);
  FFolder := TcxShellFolder.Create(FFullPIDL);
end;

destructor TcxShellItemInfo.Destroy;
begin
  FreeAndNil(FFolder);
  DisposePidl(FFullPIDL);
  DisposePidl(Fpidl);
  FreeAndNil(FDetails);
  inherited;
end;

procedure TcxShellItemInfo.FetchDetails(wnd:HWND;ShellFolder: IShellFolder;DetailsMap:TcxShellDetails);

  function FormatSizeStr(AStr: string): string;
  begin
    Result := FormatMaskText('!### ### ### KB;0;*', AStr);
  end;

  function GetFileTypeInfo(const AFilename: string): string;
  begin
    Result := GetRegStringValue(GetRegStringValue(ExtractFileExt(AFileName), ''), '');
  end;

var
  AColumnDetails: TShellDetails;
  AFileInfo: TWIN32FindData;
  AFileSize: record
    case integer of
      0:(l,h:cardinal);
      1:(c:int64);
    end;
  AFindFileHandle: THandle;
  APDetailItem: PcxDetailItem;
  AShellDetails: IShellDetails;
  AShellFolder2: IShellFolder2;
  AStrPath: TStrRet;
  ATempName: PChar;
  I: Integer;
begin
  // Processing details
  Details.Clear;
  if Succeeded(ShellFolder.QueryInterface({$IFNDEF DELPHI6}cxIID_IShellFolder2{$ELSE}cxIShellFolder2{$ENDIF}, AShellFolder2)) then
  begin
    for I := 0 to DetailsMap.Count - 1 do
    begin
      APDetailItem := DetailsMap[I];
      if APDetailItem.ID = 0 then
        Continue; // Name column already exists
      if AShellFolder2.GetDetailsOf(pidl, APDetailItem.ID, AColumnDetails) = S_OK then
        Details.Add(GetTextFromStrRet(AColumnDetails.str, pidl))
      else
        Details.Add('');
    end;
  end
  else
    if Succeeded(GetShellDetails(ShellFolder, pidl, AShellDetails)) then
    begin
      for I := 0 to DetailsMap.Count - 1 do
      begin
        APDetailItem := DetailsMap[I];
        if APDetailItem.ID = 0 then
           Continue; // Name column already exists
        if AShellDetails.GetDetailsOf(pidl, APDetailItem.ID, AColumnDetails) = S_OK then
          Details.Add(GetTextFromStrRet(AColumnDetails.str, pidl))
        else
          Details.Add('');
      end;
    end
    else
      if IsFilesystem then
      begin
        if Failed(ShellFolder.GetDisplayNameOf(pidl, SHGDN_NORMAL or SHGDN_FORPARSING, AStrPath)) then
          Exit;
        GetMem(ATempName, MAX_PATH);
        try
          StrPLCopy(ATempName, GetTextFromStrRet(AStrPath, pidl), MAX_PATH);
          AFindFileHandle := FindFirstFile(ATempName, AFileInfo);
          if AFindFileHandle <> INVALID_HANDLE_VALUE then
          try
            AFileSize.h := AFileInfo.nFileSizeHigh;
            AFileSize.l := AFileInfo.nFileSizeLow;
            Details.Add(FormatSizeStr(IntToStr(Ceil(AFileSize.c/1024))));
            Details.Add(GetFileTypeInfo(AFileInfo.cFileName));
            Details.Add(DateTimeToStr(cxFileTimeToDateTime(AFileInfo.ftLastWriteTime)));
          finally
            Windows.FindClose(AFindFileHandle);
          end;
        finally
          FreeMem(ATempName);
        end;
      end;
end;

procedure TcxShellItemInfo.SetNewPidl(pFolder:IShellFolder;FolderPidl,apidl: PItemIDList);
begin
  if apidl=nil then
     Exit;
  if Fpidl<>nil then
     DisposePidl(FPidl);
  FPidl:=GetPidlCopy(apidl);
  Updated:=False;
  CheckUpdate(pFolder,FolderPidl,False);
end;

{ TcxShellOptions }

constructor TcxShellOptions.Create(AOwner:TWinControl);
begin
  inherited Create;
  FOwner:=AOwner;
  FContextMenus:=True;
  FShowFolders:=True;
  FShowNonFolders:=True;
  FShowHidden:=False;
  FShowToolTip := True;
  FTrackShellChanges:=True;
end;

procedure TcxShellOptions.Assign(Source: TPersistent);
begin
  if Source is TcxShellOptions then
    with TcxShellOptions(Source) do
    begin
      Self.FContextMenus := FContextMenus;
      Self.FShowFolders := FShowFolders;
      Self.FShowHidden := FShowHidden;
      Self.FShowNonFolders := FShowNonFolders;
      Self.ShowToolTip := ShowToolTip;
      Self.FTrackShellChanges := FTrackShellChanges;
      NotifyUpdateContents;
    end
  else
    inherited Assign(Source);
end;

function TcxShellOptions.GetEnumFlags: Cardinal;
begin
  if ShowFolders then
     Result:=SHCONTF_FOLDERS
  else
     Result:=0;
  if ShowNonFolders then
     Result:=Result or SHCONTF_NONFOLDERS;
  if ShowHidden then
     Result:=Result or SHCONTF_INCLUDEHIDDEN;
end;

procedure TcxShellOptions.NotifyUpdateContents;
begin
  if Owner.HandleAllocated then
     SendMessage(Owner.Handle,DSM_NOTIFYUPDATECONTENTS,0,0);
end;

procedure TcxShellOptions.SetShowFolders(Value: Boolean);
begin
  FShowFolders := Value;
  NotifyUpdateContents;
end;

procedure TcxShellOptions.SetShowHidden(Value: Boolean);
begin
  FShowHidden := Value;
  NotifyUpdateContents;
end;

procedure TcxShellOptions.SetShowNonFolders(Value: Boolean);
begin
  FShowNonFolders := Value;
  NotifyUpdateContents;
end;

procedure TcxShellOptions.SetShowToolTip(Value: Boolean);
begin
  if Value <> FShowToolTip then
  begin
    FShowToolTip := Value;
    if Assigned(FOnShowToolTipChanged) then
      FOnShowToolTipChanged(Self);
  end;
end;

{ TcxShellDetails }

function TcxShellDetails.Add: PcxDetailItem;
begin
  New(Result);
  Items.Add(Result);
end;

procedure TcxShellDetails.Clear;
var
  di:PcxDetailItem;
begin
  while Items.Count<>0 do
  begin
    di:=Items.Last;
    Items.Remove(di);
    Dispose(di);
  end;
end;

constructor TcxShellDetails.Create;
begin
  inherited Create;
  FItems:=TList.Create;
end;

destructor TcxShellDetails.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
end;

function TcxShellDetails.GetCount: Integer;
begin
  Result:=Items.Count;
end;

function TcxShellDetails.GetItems(Index: Integer): PcxDetailItem;
begin
  Result:=Items[Index];
end;

procedure TcxShellDetails.ProcessDetails(ACharWidth: Integer;
  AShellFolder: IShellFolder; AFileSystem: Boolean);
const
  AAlignment: array[0..2] of TAlignment = (taLeftJustify, taRightJustify, taCenter);
var
  AColumnDetails: TShellDetails;
  AColumnFlags: Cardinal;
  AColumnIndex: Integer;
  SD: IShellDetails;
  SF2: IShellFolder2;

  procedure SetItemInfo(AItem: PcxDetailItem; AText: string; AWidth:Integer;
    AAlignment: TAlignment; AID:Integer);
  begin
    AItem.Text := AText;
    AItem.Width := AWidth * ACharWidth;
    AItem.Alignment := AAlignment;
    AItem.ID := AID;
  end;

  procedure AddItem(ADetails: TShellDetails; AIndex: Integer);
  var
    ANewColumn: PcxDetailItem;
  begin
    ANewColumn := Add;
    SetItemInfo(ANewColumn, GetTextFromStrRet(ADetails.str, nil),
      ADetails.cxChar, AAlignment[ADetails.fmt], AIndex);
  end;

var
  ADefaultColumns: Boolean;
begin
  ZeroMemory(@AColumnDetails, SizeOf(AColumnDetails));
  AColumnIndex := 0;
  Clear;
  if Succeeded(AShellFolder.QueryInterface({$IFNDEF DELPHI6}cxIID_IShellFolder2{$ELSE}cxIShellFolder2{$ENDIF}, SF2)) then
  begin
    ADefaultColumns := False;
    while SF2.GetDetailsOf(nil, AColumnIndex, AColumnDetails) = S_OK do
    begin
      Inc(AColumnIndex);
      if Succeeded(SF2.GetDefaultColumnState(AColumnIndex - 1, AColumnFlags)) then
      begin
        ADefaultColumns := ADefaultColumns or (AColumnFlags and SHCOLSTATE_ONBYDEFAULT = SHCOLSTATE_ONBYDEFAULT);
        if not IsWinXPOrLater and ADefaultColumns and
          (AColumnFlags and SHCOLSTATE_ONBYDEFAULT <> SHCOLSTATE_ONBYDEFAULT) then
            Break;
        if (AColumnFlags and SHCOLSTATE_ONBYDEFAULT <> SHCOLSTATE_ONBYDEFAULT) or
          (AColumnFlags and SHCOLSTATE_HIDDEN = SHCOLSTATE_HIDDEN) then
            Continue;
      end;
      AddItem(AColumnDetails, AColumnIndex - 1);
    end;
  end
  else
    if GetShellDetails(AShellFolder, nil, SD) = S_OK then
    begin
      while SD.GetDetailsOf(nil, AColumnIndex, AColumnDetails) = S_OK do
      begin
        AddItem(AColumnDetails, AColumnIndex);
        Inc(AColumnIndex);
      end;
    end
    else
    begin // Processing creating columns manually (for Win95/98)
      SetItemInfo(Add, SShellDefaultNameStr, 25, taLeftJustify, 0);
      if AFileSystem then
      begin
        SetItemInfo(Add, SShellDefaultSizeStr, 10, taRightJustify, 1);
        SetItemInfo(Add, SShellDefaultTypeStr, 10, taLeftJustify, 2);
        SetItemInfo(Add, SShellDefaultModifiedStr, 14, taLeftJustify, 3);
      end;
    end;
end;

procedure TcxShellDetails.Remove(Item: PcxDetailItem);
begin
  Items.Remove(Item);
  Dispose(Item);
end;

{ TcxDropTarget }

constructor TcxDropSource.Create(AOwner: TWinControl);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TcxDropSource.GiveFeedback(dwEffect: Integer): HResult;
begin
  Result:=DRAGDROP_S_USEDEFAULTCURSORS;
end;

function TcxDropSource.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: Integer): HResult;
begin
  if fEscapePressed then
     Result:=DRAGDROP_S_CANCEL
  else
  if ((grfKeyState and MK_LBUTTON)<>MK_LBUTTON) and
     ((grfKeyState and MK_RBUTTON)<>MK_RBUTTON) then
     Result:=DRAGDROP_S_DROP
  else
     Result:=S_OK;
end;

{ TcxDragDropSettings }

constructor TcxDragDropSettings.Create;
begin
  inherited Create;
  FAllowDragObjects := True;
  FDefaultDropEffect := deMove;
  FDropEffect := [deMove, deCopy, deLink];
end;

procedure TcxDragDropSettings.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TcxDragDropSettings.GetDefaultDropEffectAPI: Integer;
begin
  case DefaultDropEffect of
    deCopy:
      Result := DROPEFFECT_COPY;
    deMove:
      Result := DROPEFFECT_MOVE;
    deLink:
      Result := DROPEFFECT_LINK;
  else
    Result := DROPEFFECT_NONE;
  end;
end;

function TcxDragDropSettings.GetDropEffectAPI: DWORD;
begin
  Result := 0;
  if deCopy in DropEffect then
    Result := Result or DROPEFFECT_COPY;
  if deMove in DropEffect then
    Result := Result or DROPEFFECT_MOVE;
  if deLink in DropEffect then
    Result := Result or DROPEFFECT_LINK;
end;

procedure TcxDragDropSettings.SetAllowDragObjects(Value: Boolean);
begin
  if Value <> FAllowDragObjects then
  begin
    FAllowDragObjects := Value;
    Changed;
  end;
end;

procedure cxShellInitialize;
begin
  OleInitialize(nil);
  ShellLibrary := LoadLibrary(ShellLibraryName);
  cxSHGetFolderLocation := GetProcAddress(ShellLibrary, 'SHGetFolderLocation');
  SHChangeNotifyRegister := GetProcAddress(ShellLibrary,PChar(2));
  SHChangeNotifyUnregister := GetProcAddress(ShellLibrary,PChar(4));
  cxSHGetPathFromIDList := GetProcAddress(ShellLibrary, 'SHGetPathFromIDListA');
  cxSHGetPathFromIDListW := GetProcAddress(ShellLibrary, 'SHGetPathFromIDListW');
end;

procedure cxShellUninitialize;
var
  I: Integer;
begin
  if FShellItemsInfoGatherers <> nil then
    for I := 0 to FShellItemsInfoGatherers.Count - 1 do
      TcxShellItemsInfoGatherer(FShellItemsInfoGatherers[I]).DestroyFetchThread;

  FcxMalloc := nil;
  if ShellLibrary <> 0 then
    FreeLibrary(ShellLibrary);
  OleUninitialize;
end;

initialization
  cxShellInitialize;

finalization
  cxShellUninitialize;

end.
