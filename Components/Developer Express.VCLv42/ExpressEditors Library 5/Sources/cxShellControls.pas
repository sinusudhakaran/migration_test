
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

unit cxShellControls;

{$I cxVer.inc}

interface

uses
  Windows, ActiveX, Classes, ComCtrls, CommCtrl, ComObj, Controls, Dialogs,
  Menus, Messages, ShellApi, ShlObj, SysUtils, cxShellCommon;

const
  cxShellNormalItemOverlayIndex = -1;
  cxShellSharedItemOverlayIndex = 0;
  cxShellShortcutItemOverlayIndex = 1;

type
  TcxCustomInnerShellListView = class;
  TcxCustomInnerShellTreeView = class;

  TcxListViewStyle=(lvsIcon, lvsSmallIcon, lvsList, lvsReport);
  // Custom listview styles added because D4 and D5 does not allow detect
  // the ViewStyle change. Also, we can add more styles to this component:
  // Tile/Thumbnails/Custom...

  TcxNavigationEvent = procedure (Sender:TcxCustomInnerShellListView;fqPidl:PItemIDList;
    FolderPath:WideString) of object;
  TcxShellAddFolderEvent = procedure(Sender: TObject; AFolder: TcxShellFolder;
    var ACanAdd: Boolean) of object;
  TcxShellChangeEvent = procedure(Sender: TObject; AEventID: DWORD;
    APIDL1, APIDL2: PItemIDList) of object;
  TcxShellCompareEvent = procedure(Sender: TObject;
    AItem1, AItem2: TcxShellFolder; {$IFDEF BCB}var{$ELSE}out{$ENDIF} ACompare: Integer) of object;

  TcxShellListViewProducer = class(TcxCustomItemProducer)
  private
    function GetListView: TcxCustomInnerShellListView;
  protected
    function AllowBackgroundProcessing: Boolean; override;
    function CanAddFolder(AFolder: TcxShellFolder): Boolean; override;
    function DoCompareItems(AItem1, AItem2: TcxShellFolder;
      out ACompare: Integer): Boolean; override;
    function GetEnumFlags: Cardinal; override;
    function GetItemsInfoGatherer: TcxShellItemsInfoGatherer; override;
    function GetShowToolTip: Boolean; override;
    property ListView: TcxCustomInnerShellListView read GetListView;
  public
    procedure NotifyUpdateItem(AItem: PcxRequestItem); override;
    procedure ProcessDetails(ShellFolder: IShellFolder; CharWidth: Integer); override;
  end;

  { TcxShellListRoot }

  TcxShellListRoot = class(TcxCustomShellRoot)
  protected
    procedure RootUpdated; override;
  end;

  TDropTargetType = (dttNone, dttOpenFolder, dttItem);

  IcxDropTarget = interface(IDropTarget)
  ['{F688E250-96A6-4222-AF9D-049EB6E7D05B}']
  end;

  { TcxShellListViewOptions }

  TcxShellListViewOptions = class(TcxShellOptions)
  private
    FAutoExecute: Boolean;
    FAutoNavigate: Boolean;
  public
    constructor Create(AOwner: TWinControl); override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoExecute: Boolean read FAutoExecute write FAutoExecute default True;
    property AutoNavigate: Boolean read FAutoNavigate write FAutoNavigate default True;
  end;

  IcxDataObject = interface(IDataObject)
  ['{9A9CDB78-150E-4469-A551-608EFF415145}']
  end;

  TcxShellChangeNotifierData = record
    Handle: THandle;
    PIDL: PItemIDList;
  end;

  { TcxCustomInnerShellListView }

  TcxCustomInnerShellListView = class(TCustomListView, IUnknown, IcxDropTarget)
  private
    FAfterNavigation: TcxNavigationEvent;
    FBeforeNavigation: TcxNavigationEvent;
    FComboBoxControl: TWinControl;
    FCurrentDropTarget: IcxDropTarget;
    FDragDropSettings: TcxDragDropSettings;
    FDraggedObject: IcxDataObject;
    FDropTargetItemIndex: Integer;
    FFirstUpdateItem: Integer;
    FInternalLargeImages: THandle;
    FInternalSmallImages: THandle;
    FItemProducer: TcxShellListViewProducer;
    FItemsInfoGatherer: TcxShellItemsInfoGatherer;
    FLastUpdateItem: Integer;
    FListViewStyle: TcxListViewStyle;
    FNotificationLock: Boolean;
    FOptions: TcxShellListViewOptions;
    FRoot: TcxShellListRoot;
    FRootChanged: TcxRootChangedEvent;
    FShellChangeNotifierData: TcxShellChangeNotifierData;
    FTreeViewControl: TWinControl;
    FOnAddFolder: TcxShellAddFolderEvent;
    FOnCompare: TcxShellCompareEvent;
    FOnShellChange: TcxShellChangeEvent;
    function GetFolder(AIndex: Integer): TcxShellFolder;
    function GetFolderCount: Integer;
    procedure RootSettingsChanged(Sender: TObject);
    procedure SetListViewStyle(const Value: TcxListViewStyle);
    procedure SetDropTargetItemIndex(Value: Integer);
    procedure DSMSynchronizeRoot(var Message: TMessage); message DSM_SYNCHRONIZEROOT;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    function OwnerDataFetch(Item: TListItem; Request: TItemRequest): Boolean; override;
    procedure DblClick; override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    function CanEdit(Item: TListItem): Boolean; override;
    procedure Loaded;override;
    procedure Edit(const Item: TLVItem); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DisplayContextMenu(const APos: TPoint);
    procedure DoProcessDefaultCommand(Item:TcxShellItemInfo); virtual;
    procedure DoProcessNavigation(Item:TcxShellItemInfo);
    procedure DoBeforeNavigation(fqPidl:PItemIDList);
    function DoAddFolder(AFolder: TcxShellFolder): Boolean;
    procedure DoAfterNavigation;
    function DoCompare(AItem1, AItem2: TcxShellFolder;
      out ACompare: Integer): Boolean; virtual;
    procedure CreateColumns;
    procedure CreateDropTarget;
    procedure CreateChangeNotification;
    procedure RemoveColumns;
    procedure RemoveDropTarget;
    procedure RemoveChangeNotification;
    procedure CheckUpdateItems;
    procedure DoBeginDrag;
    procedure DoNavigateTreeView;
    procedure GetDropTarget(pt:TPoint;out New:Boolean);
    procedure Navigate(APIDL: PItemIDList); virtual;
    function TryReleaseDropTarget:HResult;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure DsmSetCount(var Message:TMessage); message DSM_SETCOUNT;
    procedure DsmNotifyUpdateItem(var Message:TMessage); message DSM_NOTIFYUPDATE;
    procedure DsmNotifyUpdateContents(var Message:TMessage); message DSM_NOTIFYUPDATECONTENTS;
    procedure DsmShellChangeNotify(var Message:TMessage); message DSM_SHELLCHANGENOTIFY;
    property ComboBoxControl: TWinControl read FComboBoxControl write FComboBoxControl;
    property FirstUpdateItem:Integer read FFirstUpdateItem write FFirstUpdateItem;
    property LastUpdateItem:Integer read FLastUpdateItem write FLastUpdateItem;
    property ItemProducer:TcxShellListViewProducer read FItemProducer;
    property CurrentDropTarget:IcxDropTarget read FCurrentDropTarget write FCurrentDropTarget;
    property DropTargetItemIndex: Integer read FDropTargetItemIndex write SetDropTargetItemIndex;
    property DraggedObject:IcxDataObject read FDraggedObject write FDraggedObject;
    property TreeViewControl:TWinControl read FTreeViewControl write FTreeViewControl;
    // IcxDropTarget methods
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function IcxDropTarget.DragOver=IDropTargetDragOver;
    function IDropTargetDragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    property ItemsInfoGatherer: TcxShellItemsInfoGatherer read FItemsInfoGatherer;
    property OnAddFolder: TcxShellAddFolderEvent read FOnAddFolder
      write FOnAddFolder;
    property OnCompare: TcxShellCompareEvent read FOnCompare write FOnCompare;
    property OnShellChange: TcxShellChangeEvent read FOnShellChange write FOnShellChange;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure BrowseParent;
    procedure SetTreeView(ATreeView:TWinControl);
    procedure ProcessTreeViewNavigate(APIDL: PItemIDList);
    procedure Sort;
    procedure UpdateContent;
    property DragDropSettings: TcxDragDropSettings read FDragDropSettings write FDragDropSettings;
    property FolderCount: Integer read GetFolderCount;
    property Folders[AIndex: Integer]: TcxShellFolder read GetFolder;
    property ListViewStyle: TcxListViewStyle read FListViewStyle write SetListViewStyle;
    property Options: TcxShellListViewOptions read FOptions write FOptions;
    property Root: TcxShellListRoot read FRoot write FRoot;
    property AfterNavigation: TcxNavigationEvent read FAfterNavigation write FAfterNavigation;
    property BeforeNavigation: TcxNavigationEvent read FBeforeNavigation write FBeforeNavigation;
    property OnRootChanged: TcxRootChangedEvent read FRootChanged write FRootChanged;
  end;

  TcxShellTreeRoot = class(TcxCustomShellRoot)
  protected
    procedure RootUpdated; override;
  end;

  TcxShellTreeItemProducer = class(TcxCustomItemProducer)
  private
    FNode: TTreeNode;
    FOnDestroy: TNotifyEvent;
    function GetTreeView: TcxCustomInnerShellTreeView;
  protected
    function AllowBackgroundProcessing: Boolean; override;
    function CanAddFolder(AFolder: TcxShellFolder): Boolean; override;
    function GetEnumFlags:Cardinal; override;
    function GetItemsInfoGatherer: TcxShellItemsInfoGatherer; override;
    function GetShowToolTip: Boolean; override;
    property Node: TTreeNode read FNode write FNode;
    procedure InitializeItem(Item: TcxShellItemInfo); override;
    procedure CheckForSubitems(AItem: TcxShellItemInfo); override;
    property TreeView: TcxCustomInnerShellTreeView read GetTreeView;
  public
    constructor Create(AOwner: TWinControl); override;
    destructor Destroy; override;
    procedure SetItemsCount(Count: Integer); override;
    procedure NotifyUpdateItem(AItem: PcxRequestItem); override;
    procedure NotifyRemoveItem(Index: Integer); override;
    procedure NotifyAddItem(Index: Integer); override;
    procedure ProcessItems(AIFolder: IShellFolder; APIDL: PItemIDList;
      ANode: TTreeNode; cPreloadItems: Integer); reintroduce; overload;
    function CheckUpdates: Boolean;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

  PcxShellTreeItemProducer = ^TcxShellTreeItemProducer;

  { TcxShellTreeViewOptions }

  TcxShellTreeViewOptions = class(TcxShellOptions)
  end;

  TcxShellTreeViewStateData = record
    CurrentPath: PItemIDList;
    ExpandedNodeList: TList;
    TopItemIndex: Integer;
  end;

  TcxCustomInnerShellTreeView = class(TTreeView, IUnknown, IcxDropTarget)
  private
    FComboBoxControl: TWinControl;
    FContextPopupItemProducer: TcxShellTreeItemProducer;
    FCurrentDropTarget: IcxDropTarget;
    FDragDropSettings: TcxDragDropSettings;
    FDraggedObject: IcxDataObject;
    FInternalSmallImages:THandle;
    FIsChangeNotificationCreationLocked: Boolean;
    FIsUpdating: Boolean;
    FItemProducersList: TThreadList;
    FItemsInfoGatherer: TcxShellItemsInfoGatherer;
    FListView: TcxCustomInnerShellListView;
    FNavigation: Boolean;
    FOptions: TcxShellTreeViewOptions;
    FPrevTargetNode: TTreeNode;
    FRoot: TcxShellTreeRoot;
    FRootChanged: TcxRootChangedEvent;
    FShellChangeNotificationCreation: Boolean;
    FShellChangeNotifierData: TcxShellChangeNotifierData;
    FShowInfoTips: Boolean;
    FStateData: TcxShellTreeViewStateData;
    FOnAddFolder: TcxShellAddFolderEvent;
    FOnShellChange: TcxShellChangeEvent;
    procedure SetPrevTargetNode(const Value: TTreeNode);
    procedure ContextPopupItemProducerDestroyHandler(Sender: TObject);
    function GetFolder(AIndex: Integer): TcxShellFolder;
    function GetFolderCount: Integer;
    function GetNodeFromItem(const Item: TTVItem): TTreeNode;
    procedure RestoreTreeState;
    procedure SaveTreeState;
    procedure SetListView(Value: TcxCustomInnerShellListView);
    procedure RootSettingsChanged(Sender: TObject);
    procedure SetShowInfoTips(Value: Boolean);
    procedure ShowToolTipChanged(Sender: TObject);
    procedure DSMShellTreeChangeNotify(var Message: TMessage); message DSM_SHELLTREECHANGENOTIFY;
    procedure DSMShellTreeRestoreCurrentPath(var Message: TMessage);
      message DSM_SHELLTREERESTORECURRENTPATH;
    procedure DSMSynchronizeRoot(var Message: TMessage); message DSM_SYNCHRONIZEROOT;
    property CurrentDropTarget:IcxDropTarget read FCurrentDropTarget write FCurrentDropTarget;
    property DraggedObject:IcxDataObject read FDraggedObject write FDraggedObject;
    property ItemProducersList:TThreadList read FItemProducersList;
    property Navigation:Boolean read FNavigation write FNavigation;
    property PrevTargetNode:TTreeNode read FPrevTargetNode write SetPrevTargetNode;
  protected
    procedure AdjustControlParams;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Change(Node: TTreeNode); override;
    function CanEdit(Node: TTreeNode): Boolean; override;
    procedure Edit(const Item: TTVItem); override;
    function CanExpand(Node: TTreeNode): Boolean; override;
    procedure Delete(Node: TTreeNode); override;
    procedure CreateParams(var Params: TCreateParams); override;
    function IsLoading: Boolean; virtual;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    procedure CreateDropTarget;
    procedure RemoveDropTarget;
    procedure AddItemProducer(Producer:TcxShellTreeItemProducer);
    procedure RemoveItemProducer(Producer:TcxShellTreeItemProducer);
    procedure CreateChangeNotification(ANode: TTreeNode = nil);
    function DoAddFolder(AFolder: TcxShellFolder): Boolean;
    procedure DoBeginDrag;
    procedure DoNavigateListView;
    procedure DragDropSettingsChanged(Sender: TObject); virtual;
    function GetNodeByPIDL(APIDL: PItemIDList): TTreeNode;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure RemoveChangeNotification;
    function TryReleaseDropTarget:HResult;
    procedure GetDropTarget(out New:Boolean;pt:TPoint);
    procedure DsmSetCount(var Message:TMessage); message DSM_SETCOUNT;
    procedure DsmNotifyUpdateItem(var Message:TMessage); message DSM_NOTIFYUPDATE;
    procedure DsmNotifyRemoveItem(var Message:TMessage); message DSM_NOTIFYREMOVEITEM;
    procedure DsmNotifyAddItem(var Message:TMessage); message DSM_NOTIFYADDITEM;
    procedure DsmNotifyUpdateContents(var Message:TMessage); message DSM_NOTIFYUPDATECONTENTS;
    procedure DsmShellChangeNotify(var Message:TMessage); message DSM_SHELLCHANGENOTIFY;
    procedure DsmDoNavigate(var Message:TMessage); message DSM_DONAVIGATE;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    // IcxDropTarget methods
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function IcxDropTarget.DragOver=IDropTargetDragOver;
    function IDropTargetDragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    property ComboBoxControl: TWinControl read FComboBoxControl write FComboBoxControl;
    property ItemsInfoGatherer: TcxShellItemsInfoGatherer read FItemsInfoGatherer;
    property OnAddFolder: TcxShellAddFolderEvent read FOnAddFolder
      write FOnAddFolder;
    property OnShellChange: TcxShellChangeEvent read FOnShellChange write FOnShellChange;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure UpdateContent;
    procedure UpdateNode(ANode: TTreeNode; AFast: Boolean);
    property DragDropSettings:TcxDragDropSettings read FDragDropSettings write FDragDropSettings;
    property FolderCount: Integer read GetFolderCount;
    property Folders[AIndex: Integer]: TcxShellFolder read GetFolder;
    property ListView:TcxCustomInnerShellListView read FListView write SetListView;
    property Options: TcxShellTreeViewOptions read FOptions write FOptions;
    property Root:TcxShellTreeRoot read FRoot write FRoot;
    property ShowInfoTips: Boolean read FShowInfoTips write SetShowInfoTips default False;
    property OnRootChanged:TcxRootChangedEvent read FRootChanged write FRootChanged;
  end;

implementation

uses
  Forms, ImgList, Math;

type
  TcxShellOptionsAccess = class(TcxShellOptions);

  PPItemIDList = ^PItemIDList;

procedure DoShellChange(Sender: TObject; AEvent: TcxShellChangeEvent;
  const Message: TMessage); forward;
function GetShellItemOverlayIndex(
  AItemData: TcxShellItemInfo): Integer; forward;
procedure RegisterShellChangeNotifier(ANotifierPIDL: PItemIDList; AWnd: HWND;
  ANotificationMsg: Cardinal; AWatchSubtree: Boolean;
  var ANotifierData: TcxShellChangeNotifierData); forward;
procedure UnregisterShellChangeNotifier(
  var ANotifierData: TcxShellChangeNotifierData); forward;

procedure DoShellChange(Sender: TObject; AEvent: TcxShellChangeEvent;
  const Message: TMessage);
begin
  if Assigned(AEvent) then
    AEvent(Sender, Message.LParam, PPItemIDList(Message.WParam)^,
      PPItemIDList(Message.WParam + SizeOf(Pointer))^);
end;

function GetShellItemOverlayIndex(AItemData: TcxShellItemInfo): Integer;
const
  SHGFI_OVERLAYINDEX = $40;
var
  AFileInfo: TShFileInfo;
  AFlags: Cardinal;
begin
  if GetComCtlVersion >= ComCtlVersionIE5 then
  begin
    AFlags := SHGFI_PIDL or SHGFI_ICON or SHGFI_OVERLAYINDEX;
    ZeroMemory(@AFileInfo, SizeOf(AFileInfo));
    SHGetFileInfo(PChar(AItemData.FullPIDL), 0, AFileInfo, SizeOf(AFileInfo), AFlags);
    DestroyIcon(AFileInfo.hIcon);
    Result := AFileInfo.iIcon;
    Result := (Result shr ((SizeOf(Result) - 1) * 8)) and $FF - 1;
  end
  else
  begin
    if AItemData.IsLink then
      Result := cxShellShortcutItemOverlayIndex
    else
      if AItemData.IsShare then
        Result := cxShellSharedItemOverlayIndex
      else
        Result := cxShellNormalItemOverlayIndex;
  end;
end;

procedure RegisterShellChangeNotifier(ANotifierPIDL: PItemIDList; AWnd: HWND;
  ANotificationMsg: Cardinal; AWatchSubtree: Boolean;
  var ANotifierData: TcxShellChangeNotifierData);
var
  AItems: PSHChangeNotifyEntry;
begin
  if EqualPIDLs(ANotifierData.PIDL, ANotifierPIDL) then
    Exit;
  UnregisterShellChangeNotifier(ANotifierData);
  ANotifierData.PIDL := GetPidlCopy(ANotifierPIDL);
  New(AItems);
  try
    AItems.pidlPath := ANotifierPIDL;
    AItems.bWatchSubtree := AWatchSubtree;
    ANotifierData.Handle := SHChangeNotifyRegister(AWnd,
      SHCNF_ACCEPT_INTERRUPTS or SHCNF_ACCEPT_NON_INTERRUPTS,
      SHCNE_RENAMEITEM or SHCNE_CREATE or SHCNE_DELETE or SHCNE_MKDIR or
      SHCNE_RMDIR or SHCNE_ATTRIBUTES or SHCNE_UPDATEDIR or SHCNE_UPDATEITEM or
      SHCNE_UPDATEIMAGE or SHCNE_RENAMEFOLDER, ANotificationMsg, 1, AItems);
  finally
    Dispose(AItems);
  end;
end;

procedure UnregisterShellChangeNotifier(
  var ANotifierData: TcxShellChangeNotifierData);
begin
  if ANotifierData.Handle <> 0 then
  begin
    SHChangeNotifyUnregister(ANotifierData.Handle);
    ANotifierData.Handle := 0;
    DisposePidl(ANotifierData.PIDL);
    ANotifierData.PIDL := nil;
  end;
end;

{ TcxShellListViewOptions }

constructor TcxShellListViewOptions.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);
  FAutoNavigate := True;
  FAutoExecute := True;
end;

procedure TcxShellListViewOptions.Assign(Source: TPersistent);
begin
  if Source is TcxShellListViewOptions then
  begin
    AutoExecute := TcxShellListViewOptions(Source).AutoExecute;
    AutoNavigate := TcxShellListViewOptions(Source).AutoNavigate;
  end;
  inherited Assign(Source);
end;

{ TcxCustomInnerShellListView }

constructor TcxCustomInnerShellListView.Create(AOwner: TComponent);
var
  AFileInfo: TShFileInfo;
begin
  inherited Create(AOwner);
  FDragDropSettings := TcxDragDropSettings.Create;
  FDropTargetItemIndex := -1;
  FFirstUpdateItem := -1;
  FInternalLargeImages := SHGetFileInfo('C:\', 0, AFileInfo, SizeOf(AFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_LARGEICON);
  FInternalSmallImages := SHGetFileInfo('C:\', 0, AFileInfo, SizeOf(AFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  FItemProducer := TcxShellListViewProducer.Create(Self);
  FItemsInfoGatherer := TcxShellItemsInfoGatherer.Create(Self);
  FLastUpdateItem := -1;
  FOptions := TcxShellListViewOptions.Create(Self);
  FRoot := TcxShellListRoot.Create(Self, 0);
  FRoot.OnSettingsChanged := RootSettingsChanged;
  DoubleBuffered := True;
  DragMode := dmManual;
  HideSelection := False;
  OwnerData := True;
end;

destructor TcxCustomInnerShellListView.Destroy;
begin
  RemoveChangeNotification;
  FreeAndNil(FDragDropSettings);
  FreeAndNil(FItemProducer);
  FreeAndNil(FItemsInfoGatherer);
  FreeAndNil(FOptions);
  FreeAndNil(FRoot);
  inherited Destroy;
end;

procedure TcxCustomInnerShellListView.BrowseParent;
var
  APIDL: PItemIDList;
begin
  APIDL := GetPidlParent(ItemProducer.FolderPidl);
  try
    Navigate(APIDL);
  finally
    DisposePidl(APIDL);
  end;
end;

function TcxCustomInnerShellListView.CanEdit(Item: TListItem): Boolean;
begin
  Result := True;
  if Item = nil then
     Exit;
  if Item.Index > ItemProducer.Items.Count - 1 then
  begin
    Result := False;
    Exit;
  end;
  Result := TcxShellItemInfo(ItemProducer.Items[Item.Index]).CanRename;
end;

procedure TcxCustomInnerShellListView.CheckUpdateItems;
begin
  ItemProducer.ClearItems;
  if IsWindow(WindowHandle) then
  begin
    if not Root.IsValid then
      Items.Clear
    else
      if ItemProducer.Items.Count = 0 then
        ItemProducer.ProcessItems(Root.ShellFolder, Root.Pidl,
          PRELOAD_ITEMS_COUNT);
    CreateChangeNotification;
    Refresh;
  end;
end;

procedure TcxCustomInnerShellListView.CNNotify(var Message: TWMNotify);

  function GetOverlayIndex: Integer;
  var
    AItemData: TcxShellItemInfo;
  begin
    AItemData := ItemProducer.Items[PLVDispInfo(Message.NMHdr)^.item.iItem];
    AItemData.CheckUpdate(ItemProducer.ShellFolder, ItemProducer.FolderPidl, False);
    Result := GetShellItemOverlayIndex(AItemData);
  end;

begin
  if csDestroying in ComponentState then
    Exit;
  case Message.NMHdr^.code of
    LVN_BEGINDRAG, LVN_BEGINRDRAG:
      begin
        if not DragDropSettings.AllowDragObjects then
        begin
          inherited;
          Exit;
        end;
        if SelCount <= 0 then
          Exit;
        DoBeginDrag;
      end;
    LVN_GETINFOTIP:
      ItemProducer.DoGetInfoTip(Handle, PNMLVGetInfoTip(Message.NMHdr)^.iItem,
        PNMLVGetInfoTip(Message.NMHdr)^.pszText,
        PNMLVGetInfoTip(Message.NMHdr)^.cchTextMax);
    LVN_GETDISPINFO:
      begin
        inherited;
        with PLVDispInfo(Message.NMHdr)^.item do
          if (mask and LVIF_IMAGE <> 0) and (iSubItem = 0) then
            if (iItem >= 0) and (iItem < ItemProducer.Items.Count) then
            begin
              state := IndexToOverlayMask(GetOverlayIndex + 1);
              stateMask := ILD_OVERLAYMASK;
              mask := mask or LVIF_STATE;
            end;
      end;
    else
      inherited;
  end;
end;

procedure TcxCustomInnerShellListView.CreateChangeNotification;
begin
  if not Options.TrackShellChanges then
    RemoveChangeNotification
  else
    RegisterShellChangeNotifier(ItemProducer.FolderPidl, Handle,
      DSM_SHELLCHANGENOTIFY, False, FShellChangeNotifierData);
end;

procedure TcxCustomInnerShellListView.CreateColumns;
var
  i: Integer;
  Column: TListColumn;
begin
  if ListViewStyle <> lvsReport then
     Exit;
  Columns.BeginUpdate;
  try
    Columns.Clear;
    for i := 0 to ItemProducer.Details.Count - 1 do
    begin
      Column := Columns.Add;
      Column.Caption := ItemProducer.Details[i].Text;
      Column.Alignment := ItemProducer.Details[i].Alignment;
      Column.Width := ItemProducer.Details[i].Width;
    end;
  finally
    Columns.EndUpdate;
  end;
end;

procedure TcxCustomInnerShellListView.CreateDropTarget;
var
  AIDropTarget: IcxDropTarget;
begin
  GetInterface(IcxDropTarget, AIDropTarget);
  RegisterDragDrop(Handle,IDropTarget(AIDropTarget));
end;

procedure TcxCustomInnerShellListView.CreateWnd;
begin
  inherited CreateWnd;
  if HandleAllocated then
  begin
    if FInternalSmallImages <> 0 then
      SendMessage(Handle, LVM_SETIMAGELIST, LVSIL_SMALL, LParam(FInternalSmallImages));
    if FInternalLargeImages <> 0 then
      SendMessage(Handle, LVM_SETIMAGELIST, LVSIL_NORMAL, LParam(FInternalLargeImages));
    CreateDropTarget;
    if Root.Pidl = nil then
      Root.CheckRoot
    else
      CheckUpdateItems;
  end;
end;

procedure TcxCustomInnerShellListView.DblClick;
var
  AItem: TcxShellItemInfo;
begin
  if not Options.AutoNavigate or (Selected = nil) then
     Exit;
  ItemProducer.LockRead;
  try
    AItem := ItemProducer.Items[Selected.Index];
    if AItem.IsFolder then
      DoProcessNavigation(AItem)
    else
      if Options.AutoExecute then
        DoProcessDefaultCommand(AItem);
  finally
    ItemProducer.UnlockRead;
  end;
end;

procedure TcxCustomInnerShellListView.DestroyWnd;
begin
  RemoveChangeNotification;
  RemoveColumns;
  RemoveDropTarget;
  inherited DestroyWnd;
end;

function TcxCustomInnerShellListView.DoAddFolder(AFolder: TcxShellFolder): Boolean;
begin
  Result := True;
  if Assigned(FOnAddFolder) then
    FOnAddFolder(Self, AFolder, Result);
end;

procedure TcxCustomInnerShellListView.DoAfterNavigation;
begin
  if Assigned(AfterNavigation) then
     AfterNavigation(Self, Root.Pidl, Root.CurrentPath);
end;

function TcxCustomInnerShellListView.DoCompare(AItem1, AItem2: TcxShellFolder;
  out ACompare: Integer): Boolean;
begin
  Result := Assigned(FOnCompare);
  if Result then
    FOnCompare(Self, AItem1, AItem2, ACompare);
end;

procedure TcxCustomInnerShellListView.DoBeforeNavigation(fqPidl: PItemIDList);
var
  Desktop: IShellFolder;
  tempPath: WideString;
  StrName: TStrRet;
begin
  if Failed(SHGetDesktopFolder(Desktop)) then
     Exit;
  if Succeeded(Desktop.GetDisplayNameOf(fqPidl, SHGDN_NORMAL or SHGDN_FORPARSING, StrName)) then
     tempPath := GetTextFromStrRet(StrName, fqPidl)
  else
     tempPath := '';
  if Assigned(BeforeNavigation) then
     BeforeNavigation(Self, fqPidl, tempPath);
end;

procedure TcxCustomInnerShellListView.DoBeginDrag;
var
  i: Integer;
  tempList: TList;
  pidlList: PItemIDList;
  pDataObject: IDataObject;
  pDropSource: IcxDropSource;
  dwEffect: Integer;
  Item: TListItem;
begin
  tempList := TList.Create;
  try
    Item := Selected;
    while Item <> nil do
    begin
      tempList.Add(GetPidlCopy(TcxShellItemInfo(ItemProducer.Items[Item.Index]).pidl));
      Item := GetNextItem(Item,sdAll,[isSelected]);
    end;
    pidlList := CreatePidlListFromList(tempList);
    try
      if Failed(ItemProducer.ShellFolder.GetUIObjectOf(Handle, SelCount, PItemIDList(pidlList^), IDataObject, nil, Pointer(pDataObject))) then
         Exit;
      pDropSource := TcxDropSource.Create(Self);
      dwEffect := DragDropSettings.DropEffectAPI;
      DoDragDrop(pDataObject, pDropSource, dwEffect, dwEffect);
    finally
      DisposePidl(pidlList);
    end;
  finally
    try
      for i := 0 to tempList.Count - 1 do
          DisposePidl(tempList[i]);
    finally
      FreeAndNil(tempList);
    end;
  end;
end;

procedure TcxCustomInnerShellListView.DoContextPopup(MousePos: TPoint;
  var Handled: Boolean);
begin
  if Options.ContextMenus and (SelCount > 0) then
  begin
    Handled := True;
    ItemProducer.LockRead;
    try
      DisplayContextMenu(ClientToScreen(MousePos));
    finally
      ItemProducer.UnlockRead;
    end;
  end
  else
    inherited DoContextPopup(MousePos, Handled);
end;

procedure TcxCustomInnerShellListView.DoProcessDefaultCommand(
  Item: TcxShellItemInfo);
var
  fqPidl: PItemIDList;
  lpExecInfo: PShellExecuteInfo;
begin
  fqPidl := ConcatenatePidls(ItemProducer.FolderPidl,Item.pidl);
  try
    New(lpExecInfo);
    try
      ZeroMemory(lpExecInfo, SizeOf(TShellExecuteInfo));
      lpExecInfo.cbSize := SizeOf(TShellExecuteInfo);
      lpExecInfo.fMask := SEE_MASK_INVOKEIDLIST;
      lpExecInfo.Wnd := Handle;
      lpExecInfo.lpIDList := fqPidl;
      lpExecInfo.nShow := SW_SHOW;
      ShellExecuteEx(lpExecInfo);
    finally
      Dispose(lpExecInfo);
    end;
  finally
    DisposePidl(fqPidl);
  end;
end;

procedure TcxCustomInnerShellListView.DoProcessNavigation(
  Item: TcxShellItemInfo);
var
  APIDL: PItemIDList;
begin
  if not Item.IsFolder then
    Exit;
  APIDL := ConcatenatePidls(ItemProducer.FolderPidl, Item.pidl);
  try
    Navigate(APIDL);
  finally
    DisposePidl(APIDL);
  end;
end;

function TcxCustomInnerShellListView.DragEnter(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  new: Boolean;
begin
  DraggedObject := IcxDataObject(dataObj);
  GetDropTarget(pt, new);
  dwEffect := DragDropSettings.DefaultDropEffectAPI;
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
    Result := CurrentDropTarget.DragEnter(dataObj, grfKeyState, pt, dwEffect)
end;

function TcxCustomInnerShellListView.DragLeave: HResult;
begin
  DraggedObject := nil;
  Result := TryReleaseDropTarget;
end;

function TcxCustomInnerShellListView.IDropTargetDragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
var
  New: Boolean;
begin
  GetDropTarget(pt, new);
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
  begin
    if New then
       Result := CurrentDropTarget.DragEnter(DraggedObject, grfKeyState, pt, dwEffect)
    else
       Result := S_OK;
    if Succeeded(Result) then
       Result := CurrentDropTarget.DragOver(grfKeyState, pt, dwEffect);
  end;
end;

function TcxCustomInnerShellListView.Drop(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  New: Boolean;
begin
  GetDropTarget(pt, new);
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
  begin
    if New then
       Result := CurrentDropTarget.DragEnter(dataObj, grfKeyState, pt, dwEffect)
    else
       Result := S_OK;
    if Succeeded(Result) then
       Result := CurrentDropTarget.Drop(dataObj, grfKeyState, pt, dwEffect);
  end;
  DraggedObject := nil;
  TryReleaseDropTarget;
end;

procedure TcxCustomInnerShellListView.DsmNotifyUpdateContents(
  var Message: TMessage);
begin
  if not (csLoading in ComponentState) then
     CheckUpdateItems;
end;

procedure TcxCustomInnerShellListView.DsmNotifyUpdateItem(
  var Message: TMessage);
begin
  UpdateItems(Message.WParam, Message.WParam);
end;

procedure TcxCustomInnerShellListView.DsmSetCount(var Message: TMessage);
begin
  Items.Count := Message.WParam;
  ItemFocused := nil;
  Selected := nil;
end;

procedure TcxCustomInnerShellListView.DsmShellChangeNotify(
  var Message: TMessage);
begin
  if FNotificationLock then
     Exit;
  FNotificationLock := True;
  try
    CheckUpdateItems;
  finally
    FNotificationLock := False;
  end;
  DoShellChange(Self, OnShellChange, Message);
end;

procedure TcxCustomInnerShellListView.Edit(const Item: TLVItem);
var
  tempItem: TcxShellItemInfo;
  NewName: WideString;
  pidlOut: PItemIDList;
begin
  inherited;
  if (ItemProducer.Items.Count - 1) < Item.iItem then
     Exit;
  tempItem := ItemProducer.Items[Item.iItem];
  NewName := StrPas(Item.pszText);
  ItemProducer.ShellFolder.SetNameOf(Handle, tempItem.pidl, PWideChar(NewName),
                SHGDN_INFOLDER or SHGDN_FORPARSING, pidlOut);
  try
    tempItem.SetNewPidl(ItemProducer.ShellFolder, ItemProducer.FolderPidl, pidlOut);
  finally
    DisposePidl(pidlOut);
  end;
end;

procedure TcxCustomInnerShellListView.KeyDown(var Key: Word;
  Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not IsEditing then
    case Key of
      VK_RETURN:
        DblClick;
      VK_BACK:
        if Options.AutoNavigate then
          BrowseParent;
      VK_F5:
        UpdateContent;
    end;
end;

procedure TcxCustomInnerShellListView.DisplayContextMenu(const APos: TPoint);

  function GetItemPIDLList: TList;
  var
    AItem: TListItem;
    AItemPIDL: PItemIDList;
  begin
    Result := TList.Create;
    AItem := Selected;
    while AItem <> nil do
    begin
      AItemPIDL := TcxShellItemInfo(ItemProducer.Items[AItem.Index]).pidl;
      if AItemPIDL <> nil then
        Result.Add(GetPidlCopy(AItemPIDL));
      AItem := GetNextItem(AItem, sdAll, [isSelected]);
    end;
  end;

var
  AItemPIDLList: TList;
  I: Integer;
begin
  if SelCount = 0 then
    Exit;

  AItemPIDLList := GetItemPIDLList;
  try
    cxShellCommon.DisplayContextMenu(Handle, ItemProducer.ShellFolder,
      AItemPIDLList, APos);
  finally
    for I := 0 to AItemPIDLList.Count - 1 do
      DisposePidl(AItemPIDLList[I]);
    AItemPIDLList.Free;
  end;
end;

procedure TcxCustomInnerShellListView.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Root.RootUpdated;
end;

procedure TcxCustomInnerShellListView.GetDropTarget(pt: TPoint;
  out New: Boolean);

  function GetDropTargetItemIndex: Integer;
  var
    AItem: TListItem;
    P: TPoint;
  begin
    Result := -1;
    P := ScreenToClient(pt);
    AItem := GetItemAt(P.X, P.Y);
    if AItem <> nil then
      Result := AItem.Index;
  end;

var
  AItemIndex: Integer;
  tempDropTarget: IcxDropTarget;
  tempPidl: PItemIDList;
begin
  AItemIndex := GetDropTargetItemIndex;
  if AItemIndex = -1 then
  begin // There are no items selected, so drop target is current opened folder
    if (DropTargetItemIndex = -1) and (CurrentDropTarget <> nil) then
    begin
      New := False;
      Exit;
    end;
    TryReleaseDropTarget;
    New := True;
    if Failed(ItemProducer.ShellFolder.CreateViewObject(Handle,IDropTarget, tempDropTarget)) then
       Exit;
    CurrentDropTarget := tempDropTarget;
  end
  else
  begin // Use one of Items as Drop Target
    if AItemIndex = DropTargetItemIndex then
    begin
      New := False;
      Exit;
    end;
    TryReleaseDropTarget;
    New := True;
    tempPidl := GetPidlCopy(TcxShellItemInfo(ItemProducer.Items[AItemIndex]).pidl);
    try
      if Failed(ItemProducer.ShellFolder.GetUIObjectOf(Handle, 1, tempPidl, IDropTarget, nil, tempDropTarget)) then
         Exit;
    finally
      DisposePidl(tempPidl);
    end;
    CurrentDropTarget := tempDropTarget;
    DropTargetItemIndex := AItemIndex;
  end;
end;

procedure TcxCustomInnerShellListView.Navigate(APIDL: PItemIDList);
begin
  if EqualPIDLs(APIDL, ItemProducer.FolderPidl) then
    Exit;
  Items.BeginUpdate;
  try
    DoBeforeNavigation(APIDL);
    Root.Pidl := APIDL;
    DoNavigateTreeView;
    DoAfterNavigation;
  finally
    Items.EndUpdate;
  end;
end;

function TcxCustomInnerShellListView.OwnerDataFetch(Item: TListItem;
  Request: TItemRequest): Boolean;
var
  ShellItem: TcxShellItemInfo;
  i: Integer;
begin
  Result := True;
  ItemProducer.LockRead;
  try
    if Item.Index >= ItemProducer.Items.Count then
       Exit;
    ShellItem := ItemProducer.Items[Item.Index];
    ShellItem.CheckUpdate(ItemProducer.ShellFolder, ItemProducer.FolderPidl, False);
    Item.Caption := ShellItem.Name;
    Item.ImageIndex := ShellItem.IconIndex;
    if ListViewStyle = lvsReport then
    begin
      if ShellItem.Details.Count = 0 then
         ShellItem.FetchDetails(Handle, ItemProducer.ShellFolder, ItemProducer.Details);
      for i := 0 to ShellItem.Details.Count - 1 do
          Item.SubItems.Add(ShellItem.Details[i]);
    end;
    Item.Cut := ShellItem.IsGhosted;
    if not ShellItem.Updated then
      ItemProducer.FetchRequest(Item.Index, True);
  finally
    ItemProducer.UnlockRead;
  end;
  Result := inherited OwnerDataFetch(Item, Request);
end;

procedure TcxCustomInnerShellListView.RemoveChangeNotification;
begin
  UnregisterShellChangeNotifier(FShellChangeNotifierData);
end;

procedure TcxCustomInnerShellListView.RemoveColumns;
begin
  Columns.Clear;
end;

procedure TcxCustomInnerShellListView.RemoveDropTarget;
begin
  RevokeDragDrop(Handle);
end;

procedure TcxCustomInnerShellListView.SetDropTargetItemIndex(Value: Integer);
begin
  if FDropTargetItemIndex <> -1 then
    Items[FDropTargetItemIndex].DropTarget := False;
  FDropTargetItemIndex := Value;
  if FDropTargetItemIndex <> -1 then
    Items[FDropTargetItemIndex].DropTarget := True;
end;

procedure TcxCustomInnerShellListView.DSMSynchronizeRoot(var Message: TMessage);
begin
  if not((Parent <> nil) and (csLoading in Parent.ComponentState)) then
    Root.Update(TcxCustomShellRoot(Message.WParam));
end;

function TcxCustomInnerShellListView.GetFolder(AIndex: Integer): TcxShellFolder;
begin
  Result := TcxShellItemInfo(ItemProducer.Items[AIndex]).Folder;
end;

function TcxCustomInnerShellListView.GetFolderCount: Integer;
begin
  Result := Items.Count;
end;

procedure TcxCustomInnerShellListView.RootSettingsChanged(Sender: TObject);
begin
  if (Parent <> nil) and (csLoading in Parent.ComponentState) then
    Exit;
  if (FTreeViewControl <> nil) and FTreeViewControl.HandleAllocated then
    SendMessage(FTreeViewControl.Handle, DSM_SYNCHRONIZEROOT, Integer(Root), 0);
  if (FComboBoxControl <> nil) and FComboBoxControl.HandleAllocated then
    SendMessage(FComboBoxControl.Handle, DSM_SYNCHRONIZEROOT, Integer(Root), 0);
end;

procedure TcxCustomInnerShellListView.SetListViewStyle(
  const Value: TcxListViewStyle);
begin
  if FListViewStyle <> Value then
  begin
    FListViewStyle := Value;
    case FListViewStyle of
      lvsIcon:          ViewStyle:=vsIcon;
      lvsSmallIcon:     ViewStyle:=vsSmallIcon;
      lvsList:          ViewStyle:=vsList;
      lvsReport:        ViewStyle:=vsReport;
    end;
    CheckUpdateItems;
  end;
end;

function TcxCustomInnerShellListView.TryReleaseDropTarget:HResult;
begin
  Result := S_OK;
  if CurrentDropTarget <> nil then
     Result := CurrentDropTarget.DragLeave;
  CurrentDropTarget := nil;
  DropTargetItemIndex := -1;
end;

procedure TcxCustomInnerShellListView.SetTreeView(ATreeView: TWinControl);
begin
  TreeViewControl := ATreeView;
end;

var
  NavigationLock: Boolean;

procedure TcxCustomInnerShellListView.DoNavigateTreeView;
var
  tempPidl: PItemIDList;
begin
  if NavigationLock or (not Assigned(TreeViewControl) and not Assigned(ComboBoxControl)) then
     Exit;

  tempPidl:=GetPidlCopy(Root.Pidl);
  try
    if Assigned(TreeViewControl) and (TreeViewControl.Parent <> nil) then
    begin
      TreeViewControl.HandleNeeded;
      SendMessage(TreeViewControl.Handle,DSM_DONAVIGATE,WPARAM(tempPidl),0);
    end;
    if Assigned(ComboBoxControl) and (ComboBoxControl.Parent <> nil) then
    begin
      ComboBoxControl.HandleNeeded;
      SendMessage(ComboBoxControl.Handle,DSM_DONAVIGATE,WPARAM(tempPidl),0);
    end;
  finally
    DisposePidl(tempPidl);
  end;
end;

procedure TcxCustomInnerShellListView.ProcessTreeViewNavigate(
  APIDL: PItemIDList);

  function IsFolder(APIDL: PItemIDList): Boolean;
  const
    SHGFI_ATTR_SPECIFIED = $20000;
  var
    ASHFileInfo: TSHFileInfo;
  begin
    ASHFileInfo.dwAttributes := SFGAO_FOLDER;
    SHGetFileInfo(Pointer(APIDL), 0, ASHFileInfo, SizeOf(ASHFileInfo),
      SHGFI_PIDL or SHGFI_ATTR_SPECIFIED or SHGFI_ATTRIBUTES);
    Result := ASHFileInfo.dwAttributes and SFGAO_FOLDER <> 0;
  end;

begin
  NavigationLock := True;
  try
    if IsFolder(APIDL) and not EqualPIDLs(APIDL, Root.Pidl) then
      Root.Pidl := APIDL;
  finally
    NavigationLock := False;
  end;
end;

procedure TcxCustomInnerShellListView.Sort;
begin
  ItemProducer.Sort;
end;

procedure TcxCustomInnerShellListView.UpdateContent;
var
  AItemIndex: Integer;
  ASelectedItemPID: PItemIDList;
begin
  ASelectedItemPID := nil;
  try
    if not MultiSelect and (Selected <> nil) then
      ASelectedItemPID := GetPidlCopy(
        TcxShellItemInfo(ItemProducer.Items[Selected.Index]).pidl);
    CheckUpdateItems;
    if ASelectedItemPID <> nil then
    begin
      AItemIndex := ItemProducer.GetItemIndexByPidl(ASelectedItemPID);
      if (AItemIndex >= 0) and (AItemIndex < Items.Count) then
        Items[AItemIndex].Selected := True;
    end;
  finally
    DisposePidl(ASelectedItemPID);
  end;
end;

{ TcxShellListRoot }

procedure TcxShellListRoot.RootUpdated;
begin
  inherited RootUpdated;
  (Owner as TcxCustomInnerShellListView).CheckUpdateItems;
  if Assigned(TcxCustomInnerShellListView(Owner).OnRootChanged) then
     TcxCustomInnerShellListView(Owner).OnRootChanged(Owner, Self);
end;

{ TcxShellListViewProducer }

function TcxShellListViewProducer.AllowBackgroundProcessing: Boolean;
begin
  Result := True;
end;

function TcxShellListViewProducer.CanAddFolder(AFolder: TcxShellFolder): Boolean;
begin
  Result := ListView.DoAddFolder(AFolder);
end;

function TcxShellListViewProducer.DoCompareItems(AItem1, AItem2: TcxShellFolder;
  out ACompare: Integer): Boolean;
begin
  Result := ListView.DoCompare(AItem1, AItem2, ACompare);
end;

function TcxShellListViewProducer.GetEnumFlags: Cardinal;
begin
  Result := ListView.Options.GetEnumFlags;
end;

function TcxShellListViewProducer.GetItemsInfoGatherer: TcxShellItemsInfoGatherer;
begin
  Result := ListView.ItemsInfoGatherer;
end;

function TcxShellListViewProducer.GetShowToolTip: Boolean;
begin
  Result := ListView.Options.ShowToolTip;
end;

function TcxShellListViewProducer.GetListView: TcxCustomInnerShellListView;
begin
  Result := TcxCustomInnerShellListView(Owner);
end;

procedure TcxShellListViewProducer.NotifyUpdateItem(AItem: PcxRequestItem);
begin
  if AItem.Priority and Owner.HandleAllocated and (AItem.ItemIndex >= 0) and
    (AItem.ItemIndex < Items.Count) then
      PostMessage(Owner.Handle, DSM_NOTIFYUPDATE, AItem.ItemIndex, 0);
end;

procedure TcxShellListViewProducer.ProcessDetails(ShellFolder: IShellFolder;
  CharWidth: Integer);
begin
  inherited ProcessDetails(ShellFolder, ListView.StringWidth('X'));
  ListView.CreateColumns;
end;

{ TcxShellTreeRoot }

procedure TcxShellTreeRoot.RootUpdated;
begin
  inherited RootUpdated;
//  TcxCustomInnerShellTreeView(Owner).ItemsInfoGatherer.ClearFetchQueue(nil);
  TcxCustomInnerShellTreeView(Owner).Items.Clear;
  TcxCustomInnerShellTreeView(Owner).UpdateNode(nil, False);
  if Assigned(TcxCustomInnerShellTreeView(Owner).OnRootChanged) then
     TcxCustomInnerShellTreeView(Owner).OnRootChanged(Owner, Self);
end;

{ TcxCustomInnerShellTreeView }

procedure TcxCustomInnerShellTreeView.AddItemProducer(
  Producer: TcxShellTreeItemProducer);
var
  tempList: TList;
begin
  tempList := ItemProducersList.LockList;
  try
    tempList.Add(Producer);
  finally
    ItemProducersList.UnlockList;
  end;
end;

function TcxCustomInnerShellTreeView.CanEdit(Node: TTreeNode): Boolean;
var
  ItemProducer:TcxShellTreeItemProducer;
begin
  Result := False;
  if Node.Parent = nil then
     Exit;
  ItemProducer := TcxShellTreeItemProducer(Node.Parent.Data);
  ItemProducer.LockRead;
  try
    if (ItemProducer.Items.Count - 1) < Node.Index then
       Exit;
    Result := TcxShellItemInfo(ItemProducer.Items[Node.Index]).CanRename;
    Result := Result and inherited CanEdit(Node);
  finally
    ItemProducer.UnlockRead;
  end;
end;

function TcxCustomInnerShellTreeView.CanExpand(Node: TTreeNode): Boolean;
var
  ItemProducer: TcxShellTreeItemProducer;
  processingPidl: PItemIDList;
  processingFolder: IShellFolder;
 begin
  Result := True;
  if Node.GetFirstChild = nil then
  begin
    if Node.Parent <> nil then
    begin
      ItemProducer := TcxShellTreeItemProducer(Node.Parent.Data);
      Result := TcxShellItemInfo(ItemProducer.Items[Node.Index]).IsFolder;
      Node.HasChildren := Result;
      if not Result then
         Exit;
      if (ItemProducer.Items.Count-1) < Node.Index then
      begin
        Result := False;
        Exit;
      end;
      if Failed(ItemProducer.ShellFolder.BindToObject(TcxShellItemInfo(ItemProducer.
            Items[Node.Index]).pidl, nil, IID_IShellFolder, processingFolder)) then
      begin
        Result := False;
        Exit;
      end;
      processingPidl := ConcatenatePidls(ItemProducer.FolderPidl,
                           TcxShellItemInfo(ItemProducer.Items[Node.Index]).pidl);
    end
    else
    begin
      processingFolder := Root.ShellFolder;
      processingPidl := GetPidlCopy(Root.Pidl);
    end;
    try
      ItemProducer := TcxShellTreeItemProducer(Node.Data);
      ItemProducer.ProcessItems(processingFolder, processingPidl, Node, 0);
    finally
      DisposePidl(processingPidl);
    end;
  end;
  Result := Result and inherited CanExpand(Node);
end;

procedure TcxCustomInnerShellTreeView.CNNotify(var Message: TWMNotify);
var
  tempNode: TTreeNode;
  ItemProducer: TcxShellTreeItemProducer;
begin
  if (Message.NMHdr^.code = TVN_BEGINDRAG) or
     (Message.NMHdr^.code = TVN_BEGINRDRAG) then
  begin
    with PNMTreeView(Message.NMHdr)^ do
      Selected := GetNodeFromItem(ItemNew);
    DoBeginDrag;
  end
  else
  if Message.NMHdr^.code = TVN_GETINFOTIP then
  begin
     tempNode := Items.GetNode(PNMTVGetInfoTip(Message.NMHdr)^.hItem);
     if (tempNode <> nil) and (tempNode.Parent <> nil) then
     begin
       ItemProducer := TcxShellTreeItemProducer(tempNode.Parent.Data);
       ItemProducer.DoGetInfoTip(Handle,tempNode.Index,
              PNMTVGetInfoTip(Message.NMHdr)^.pszText,
              PNMTVGetInfoTip(Message.NMHdr)^.cchTextMax);
     end;
  end
  else
    inherited;
end;

constructor TcxCustomInnerShellTreeView.Create(AOwner: TComponent);
var
  FileInfo: TShFileInfo;
begin
  inherited;
  FItemsInfoGatherer := TcxShellItemsInfoGatherer.Create(Self);
  FRoot:=TcxShellTreeRoot.Create(Self, 0);
  FRoot.OnSettingsChanged := RootSettingsChanged;
  FDragDropSettings := TcxDragDropSettings.Create;
  FDragDropSettings.OnChange := DragDropSettingsChanged;
  FOptions := TcxShellTreeViewOptions.Create(Self);
  TcxShellOptionsAccess(FOptions).OnShowToolTipChanged := ShowToolTipChanged;
  FItemProducersList := TThreadList.Create;
  FInternalSmallImages := SHGetFileInfo('C:\', 0, FileInfo, SizeOf(FileInfo),
                                        SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  CurrentDropTarget := nil;
  PrevTargetNode := nil;
  DraggedObject := nil;
  DoubleBuffered := True;
  DragMode := dmAutomatic;
  RightClickSelect := True;
end;

procedure TcxCustomInnerShellTreeView.CreateDropTarget;
var
  AIDropTarget: IcxDropTarget;
begin
  GetInterface(IcxDropTarget, AIDropTarget);
  RegisterDragDrop(Handle,IDropTarget(AIDropTarget));
end;

procedure TcxCustomInnerShellTreeView.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if ShowInfoTips then
    Params.Style := (Params.Style or TVS_INFOTIP) and not TVS_NOTOOLTIPS;
end;

function TcxCustomInnerShellTreeView.IsLoading: Boolean;
begin
  Result := csLoading in ComponentState;
end;

procedure TcxCustomInnerShellTreeView.AdjustControlParams;
var
  AStyle: Longint;
begin
  if HandleAllocated then
  begin
    AStyle := GetWindowLong(Handle, GWL_STYLE) and not(TVS_INFOTIP) or TVS_NOTOOLTIPS;
    if ShowInfoTips or Options.ShowToolTip then
      AStyle := AStyle and not TVS_NOTOOLTIPS;
    if ShowInfoTips then
      AStyle := AStyle or TVS_INFOTIP;
    SetWindowLong(Handle, GWL_STYLE, AStyle);
  end;
end;

procedure TcxCustomInnerShellTreeView.CreateWnd;
begin
  inherited;
  if HandleAllocated then
  begin
    if FInternalSmallImages <> 0 then
       SendMessage(Handle, TVM_SETIMAGELIST, TVSIL_NORMAL, LParam(FInternalSmallImages));
    if not IsLoading and (Root.Pidl = nil) then
       Root.CheckRoot;
    UpdateNode(nil, False);
    CreateDropTarget;
  end;
end;

procedure TcxCustomInnerShellTreeView.Delete(Node: TTreeNode);
var
  ItemProducer: TcxShellTreeItemProducer;
begin
  ItemProducer := TcxShellTreeItemProducer(Node.Data);
  if ItemProducer <> nil then
  begin
    ItemProducer.Free;
    Node.Data := nil;
  end;
  inherited;
end;

destructor TcxCustomInnerShellTreeView.Destroy;
var
  AList: TList;
  I: Integer;
begin
  if FListView <> nil then
    FListView.SetTreeView(nil);

  RemoveChangeNotification;

  AList := FItemProducersList.LockList;
  try
    for I := 0 to AList.Count - 1 do
      TcxShellTreeItemProducer(AList[I]).ClearFetchQueue;
  finally
    FItemProducersList.UnlockList;
  end;

  Items.Clear;
  FreeAndNil(FItemProducersList);
  FreeAndNil(FOptions);
  FreeAndNil(FDragDropSettings);
  FreeAndNil(FRoot);
  FreeAndNil(FItemsInfoGatherer);
  inherited Destroy;
end;

procedure TcxCustomInnerShellTreeView.UpdateContent;
begin
  if HandleAllocated then
  begin
    if Root.ShellFolder = nil then
      Root.CheckRoot;
    SendMessage(Handle, DSM_SHELLTREECHANGENOTIFY, WPARAM(Root.Pidl), 0);
  end;
end;

procedure TcxCustomInnerShellTreeView.DestroyWnd;
begin
  RemoveChangeNotification;
  RemoveDropTarget;
  CreateWndRestores := False;
  inherited;
end;

procedure TcxCustomInnerShellTreeView.DoBeginDrag;
var
  ItemProducer: TcxShellTreeItemProducer;
  tempPidl: PItemIDList;
  pDataObject: IDataObject;
  pDropSource: IcxDropSource;
  dwEffect: Integer;
begin
  if Selected.Parent = nil then
     Exit;
  ItemProducer := TcxShellTreeItemProducer(Selected.Parent.Data);
  ItemProducer.LockRead;
  try
    if (ItemProducer.Items.Count-1) < Selected.Index then
       Exit;
    tempPidl:=GetPidlCopy(TcxShellItemInfo(ItemProducer.Items[Selected.Index]).pidl);
    try
      if Failed(ItemProducer.ShellFolder.GetUIObjectOf(Handle, 1, tempPidl, IDataObject, nil, pDataObject)) then
         Exit;
      pDropSource := TcxDropSource.Create(Self);
      dwEffect := DragDropSettings.DropEffectAPI;
      DoDragDrop(pDataObject, pDropSource, dwEffect, dwEffect);
      if not TcxShellTreeItemProducer(Selected.Parent.Data).CheckUpdates then
         UpdateNode(Selected.Parent, False);
    finally
      DisposePidl(tempPidl);
    end;
  finally
    ItemProducer.UnlockRead;
  end;
end;

procedure TcxCustomInnerShellTreeView.DoContextPopup(MousePos: TPoint;
  var Handled: Boolean);
var
  AItem: TcxShellItemInfo;
  AItemPIDLList: TList;
  ANode: TTreeNode;
begin
  try
    ANode := GetNodeAt(MousePos.X, MousePos.Y);
    if not Options.ContextMenus or (ANode = nil) then
    begin
      inherited DoContextPopup(MousePos, Handled);
      Exit;
    end;
    Handled := True;
    if ANode.Parent = nil then
      Exit;

    FContextPopupItemProducer := TcxShellTreeItemProducer(ANode.Parent.Data);
    FContextPopupItemProducer.OnDestroy := ContextPopupItemProducerDestroyHandler;
    FContextPopupItemProducer.LockRead;
    try
      CreateChangeNotification(ANode);
      AItem := FContextPopupItemProducer.Items[ANode.Index];
      FIsChangeNotificationCreationLocked := True;
      if AItem.pidl <> nil then
      begin
        AItemPIDLList := TList.Create;
        try
          AItemPIDLList.Add(GetPidlCopy(AItem.pidl));
          cxShellCommon.DisplayContextMenu(Handle, FContextPopupItemProducer.ShellFolder,
            AItemPIDLList, ClientToScreen(MousePos));
        finally
          DisposePidl(AItemPIDLList[0]);
          AItemPIDLList.Free;
        end;
      end;
    finally
      if FContextPopupItemProducer <> nil then
        FContextPopupItemProducer.UnlockRead;
    end;
  finally
    FIsChangeNotificationCreationLocked := False;
    if FContextPopupItemProducer <> nil then
    begin
      FContextPopupItemProducer.OnDestroy := nil;
      FContextPopupItemProducer := nil;
    end;
  end;
end;

function TcxCustomInnerShellTreeView.DragEnter(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  New: Boolean;
begin
  DraggedObject := IcxDataObject(dataObj);
  GetDropTarget(new, pt);
  dwEffect := DragDropSettings.DefaultDropEffectAPI;
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
    Result := CurrentDropTarget.DragEnter(dataObj, grfKeyState, pt, dwEffect)
end;

function TcxCustomInnerShellTreeView.DragLeave: HResult;
begin
  DraggedObject := nil;
  Result := TryReleaseDropTarget;
end;

function TcxCustomInnerShellTreeView.IDropTargetDragOver(grfKeyState: Integer; pt: TPoint;
  var dwEffect: Integer): HResult;
var
  New: Boolean;
begin
  GetDropTarget(new, pt);
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
  begin
    if New then
       Result := CurrentDropTarget.DragEnter(DraggedObject, grfKeyState, pt, dwEffect)
    else
       Result := S_OK;
    if Succeeded(Result) then
       Result := CurrentDropTarget.DragOver(grfKeyState, pt, dwEffect);
  end;
end;

function TcxCustomInnerShellTreeView.Drop(const dataObj: IDataObject;
  grfKeyState: Integer; pt: TPoint; var dwEffect: Integer): HResult;
var
  New: Boolean;
begin
  GetDropTarget(new, pt);
  if CurrentDropTarget = nil then
  begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_OK;
  end
  else
  begin
    if New then
       Result := CurrentDropTarget.DragEnter(dataObj, grfKeyState, pt, dwEffect)
    else
       Result := S_OK;
    if Succeeded(Result) then
       Result := CurrentDropTarget.Drop(dataObj, grfKeyState, pt, dwEffect);
  end;
  PostMessage(Handle, DSM_SHELLCHANGENOTIFY, WPARAM(PrevTargetNode.Data), 0);
  TryReleaseDropTarget;
end;

procedure TcxCustomInnerShellTreeView.DsmNotifyAddItem(var Message: TMessage);
var
  Node, NewNode: TTreeNode;
  ItemProducer: TcxShellTreeItemProducer;
  tempShellItem: TcxShellItemInfo;
begin
  Node := TTreeNode(Message.LParam);
  ItemProducer := TcxShellTreeItemProducer(Node.Data);
  ItemProducer.LockRead;
  try
    tempShellItem := ItemProducer.Items[Message.WParam];
    NewNode := Items.AddChild(Node, tempShellItem.Name);
    NewNode.Data := TcxShellTreeItemProducer.Create(Self);
    NewNode.ImageIndex := tempShellItem.IconIndex;
    NewNode.SelectedIndex := tempShellItem.OpenIconIndex;
    NewNode.HasChildren := tempShellItem.HasSubfolder;
  finally
    ItemProducer.UnlockRead;
  end;
end;

procedure TcxCustomInnerShellTreeView.DsmNotifyRemoveItem(
  var Message: TMessage);
var
  Node: TTreeNode;
begin
  Node := TTreeNode(Message.LParam);
  if Message.WParam < Node.Count then
     Node.Item[Message.WParam].Delete;
end;

procedure TcxCustomInnerShellTreeView.DsmNotifyUpdateContents(
  var Message: TMessage);
begin
  if not (csLoading in ComponentState) then
     UpdateNode(nil, False);
end;

procedure TcxCustomInnerShellTreeView.DsmNotifyUpdateItem(
  var Message: TMessage);

  function GetChildNode(ANode: TTreeNode; AIndex: Integer): TTreeNode;
  begin
    Result := ANode.getFirstChild;
    while (Result <> nil) and (AIndex > 0) do
    begin
      Result := ANode.GetNextChild(Result);
      Dec(AIndex);
    end;
  end;

var
  AItem: TcxShellItemInfo;
  AItemProducer: TcxShellTreeItemProducer;
  ANode, ATempNode: TTreeNode;
begin
  ANode := TTreeNode(Message.LParam);
  if ANode.getFirstChild = nil then
    Exit;
  ATempNode := GetChildNode(ANode, Message.WParam);
  if ATempNode = nil then
    Exit;

  AItemProducer := TcxShellTreeItemProducer(ANode.Data);
  AItemProducer.LockRead;
  try
    AItem := AItemProducer.Items[Message.WParam];
    ATempNode.ImageIndex := AItem.IconIndex;
    ATempNode.SelectedIndex := AItem.OpenIconIndex;
    ATempNode.Text := AItem.Name;
    ATempNode.HasChildren := AItem.HasSubfolder;
    ATempNode.Cut := AItem.IsGhosted;
    ATempNode.OverlayIndex := GetShellItemOverlayIndex(AItem);
  finally
    AItemProducer.UnlockRead;
  end;
end;

procedure TcxCustomInnerShellTreeView.DsmSetCount(var Message: TMessage);
var
  Node: TTreeNode;
  ItemProducer: TcxShellTreeItemProducer;
  i: Integer;
  NewNode: TTreeNode;
  tempShellItem: TcxShellItemInfo;
begin
  Node := TTreeNode(Message.LParam);
  if Message.WParam = 0 then
  begin
    Node.DeleteChildren;
    Node.HasChildren := False;
    Exit;
  end;
  ItemProducer := TcxShellTreeItemProducer(Node.Data);
  ItemProducer.LockRead;
  try
    Items.BeginUpdate;
    try
      for i := 0 to ItemProducer.Items.Count-1 do
      begin
        tempShellItem := ItemProducer.Items[i];
        if not tempShellItem.Updated then
           ItemProducer.FetchRequest(i, False);
        NewNode := Items.AddChild(Node, tempShellItem.Name);
        NewNode.Data := TcxShellTreeItemProducer.Create(Self);
        NewNode.ImageIndex := tempShellItem.IconIndex;
        NewNode.SelectedIndex := tempShellItem.OpenIconIndex;
        NewNode.HasChildren := tempShellItem.HasSubfolder;
        NewNode.Cut := tempShellItem.IsGhosted;
        NewNode.OverlayIndex := GetShellItemOverlayIndex(tempShellItem);
      end;
    finally
      Items.EndUpdate;
    end;
    if Node.GetFirstChild = nil then
       Node.HasChildren := False;
  finally
    ItemProducer.UnlockRead;
  end;
end;

procedure TcxCustomInnerShellTreeView.DsmShellChangeNotify(
  var Message: TMessage);
begin
  Sleep(100);
  if not TcxShellTreeItemProducer(Message.WParam).CheckUpdates then
    UpdateNode(PrevTargetNode, False);
end;

procedure TcxCustomInnerShellTreeView.Edit(const Item: TTVItem);
var
  AItemInfo: TcxShellItemInfo;
  AItemProducer: TcxShellTreeItemProducer;
  ANode: TTreeNode;
  APIDL: PItemIDList;
  APrevNodeText: string;
begin
  ANode := GetNodeFromItem(Item);
  APrevNodeText := '';
  if ANode <> nil then
    APrevNodeText := ANode.Text;
  inherited Edit(Item);
  if (Item.pszText = nil) or (ANode = nil) or (ANode.Parent = nil) then
    Exit;
  AItemProducer := TcxShellTreeItemProducer(ANode.Parent.Data);
  AItemInfo := AItemProducer.Items[ANode.Index];
  RemoveChangeNotification;
  if AItemProducer.ShellFolder.SetNameOf(Handle, AItemInfo.pidl, PWideChar(WideString(ANode.Text)),
    SHGDN_INFOLDER or SHGDN_FORPARSING, APIDL) = S_OK then
    try
      AItemInfo.SetNewPidl(AItemProducer.ShellFolder, AItemProducer.FolderPidl, APIDL);
      UpdateNode(ANode, True);
    finally
      DisposePidl(APIDL);
    end
  else
    ANode.Text := APrevNodeText;
end;

procedure TcxCustomInnerShellTreeView.GetDropTarget(out New: Boolean; pt: TPoint);
var
  Node: TTreeNode;
  cpt: TPoint;
  ItemProducer: TcxShellTreeItemProducer;
  tempDropTarget: IcxDropTarget;
  tempShellItem: TcxShellItemInfo;
  tempPidl: PItemIDList;
  Res: HRESULT;
  tempShellFolder: IShellFolder;
begin
  cpt := ScreenToClient(pt);
  Node := GetNodeAt(cpt.X, cpt.Y);
  if Node = nil then
  begin
    TryReleaseDropTarget;
    Exit;
  end;
  if (Node = PrevTargetNode) and (CurrentDropTarget <> nil) then
  begin
    New := False;
    Exit;
  end;
  TryReleaseDropTarget;
  New := True;
  if Node.Parent = nil then
  begin // Root object selected
    ItemProducer := TcxShellTreeItemProducer(Node.Data);
    if ItemProducer.ShellFolder = nil then
       Exit;
    Res:=ItemProducer.ShellFolder.CreateViewObject(Handle, IDropTarget, tempDropTarget);
    if Failed(Res) then
       Exit;
  end
  else
  begin // Non-root object selected
    ItemProducer := TcxShellTreeItemProducer(Node.Parent.Data);
    tempShellItem := ItemProducer.Items[Node.Index];
    tempPidl := GetPidlCopy(tempShellItem.pidl);
    try
      if tempShellItem.IsFolder then
      begin
        if Failed(ItemProducer.ShellFolder.BindToObject(tempPidl, nil, IID_IShellFolder, tempShellFolder)) then
           Exit;
        if Failed(tempShellFolder.CreateViewObject(Handle, IDropTarget, tempDropTarget)) then
           Exit;
      end
      else
      begin
        Res := ItemProducer.ShellFolder.GetUIObjectOf(Handle, 1, tempPidl, IDropTarget, nil, tempDropTarget);
        if Failed(Res) then
           Exit;
      end;
    finally
      DisposePidl(tempPidl);
    end;
  end;

  PrevTargetNode := Node;
  CurrentDropTarget := tempDropTarget;
end;

procedure TcxCustomInnerShellTreeView.ContextPopupItemProducerDestroyHandler(
  Sender: TObject);
begin
  FContextPopupItemProducer.UnlockRead;
  FContextPopupItemProducer.OnDestroy := nil;
  FContextPopupItemProducer := nil;
end;

function TcxCustomInnerShellTreeView.GetFolder(AIndex: Integer): TcxShellFolder;
var
  ANode: TTreeNode;
begin
  ANode := Items[AIndex];
  if ANode.Parent = nil then
    Result := Root.Folder
  else
    Result := TcxShellItemInfo(TcxShellTreeItemProducer(ANode.Parent.Data).Items[ANode.Index]).Folder;
end;

function TcxCustomInnerShellTreeView.GetFolderCount: Integer;
begin
  Result := Items.Count;
end;

function TcxCustomInnerShellTreeView.GetNodeFromItem(
  const Item: TTVItem): TTreeNode;
begin
  Result := nil;
  if Items <> nil then
    with Item do
      if (state and TVIF_PARAM) <> 0 then
        Result := Pointer(lParam)
      else
        Result := Items.GetNode(hItem);
end;

procedure TcxCustomInnerShellTreeView.RestoreTreeState;

  procedure RestoreExpandedNodes;

    procedure ExpandNode(APIDL: PItemIDList);
    var
      ANode: TTreeNode;
    begin
      if Root.ShellFolder = nil then
        Root.CheckRoot;
      if APIDL = nil then
        APIDL := Root.Pidl;
      ANode := GetNodeByPIDL(APIDL);
      if ANode <> nil then
        ANode.Expand(False);
    end;

    procedure DestroyExpandedNodeList;
    var
      I: Integer;
    begin
      if FStateData.ExpandedNodeList = nil then
        Exit;
      for I := 0 to FStateData.ExpandedNodeList.Count - 1 do
        DisposePidl(PItemIDList(FStateData.ExpandedNodeList[I]));
      FreeAndNil(FStateData.ExpandedNodeList);
    end;

  var
    I: Integer;
  begin
    try
      for I := 0 to FStateData.ExpandedNodeList.Count - 1 do
        ExpandNode(PItemIDList(FStateData.ExpandedNodeList[I]));
    finally
      DestroyExpandedNodeList;
    end;
  end;

  procedure RestoreTopItemIndex;
  begin
    if (FStateData.TopItemIndex >= 0) and (FStateData.TopItemIndex < Items.Count) then
      TopItem := Items[FStateData.TopItemIndex];
  end;

  procedure RestoreCurrentPath;
  var
    ACurrentPath, ATempPIDL: PItemIDList;
  begin
    if FStateData.CurrentPath = nil then
      Exit;
    ACurrentPath := GetPidlCopy(FStateData.CurrentPath);
    try
      repeat
        if GetNodeByPIDL(ACurrentPath) <> nil then
        begin
          PostMessage(Handle, DSM_SHELLTREERESTORECURRENTPATH,
            WPARAM(GetPidlCopy(ACurrentPath)), 0);
          Break;
        end;
        ATempPIDL := ACurrentPath;
        ACurrentPath := GetPidlParent(ACurrentPath);
        DisposePidl(ATempPIDL);
      until False;
    finally
      DisposePidl(ACurrentPath);
    end;
  end;

begin
  try
    RestoreExpandedNodes;
    RestoreTopItemIndex;
    RestoreCurrentPath;
  finally
    DisposePidl(FStateData.CurrentPath);
    FStateData.CurrentPath := nil;
  end;
end;

procedure TcxCustomInnerShellTreeView.SaveTreeState;

  procedure SaveTopItemIndex;
  begin
    if TopItem <> nil then
      FStateData.TopItemIndex := TopItem.AbsoluteIndex
    else
      FStateData.TopItemIndex := -1;
  end;

  procedure SaveExpandedNodes;

    procedure SaveExpandedNode(ANode: TTreeNode);
    var
      AParentItemProducer: TcxShellTreeItemProducer;
    begin
      if ANode.Parent = nil then
        FStateData.ExpandedNodeList.Add(nil)
      else
      begin
        AParentItemProducer := TcxShellTreeItemProducer(ANode.Parent.Data);
        FStateData.ExpandedNodeList.Add(GetPidlCopy(
          TcxShellItemInfo(AParentItemProducer.Items[ANode.Index]).FullPIDL));
      end;
    end;

  var
    ANode: TTreeNode;
  begin
    FStateData.ExpandedNodeList := TList.Create;
    ANode := Items.GetFirstNode;
    while ANode <> nil do
    begin
      if ANode.Expanded then
        SaveExpandedNode(ANode);
      ANode := ANode.GetNext;
    end;
  end;

  procedure SaveCurrentPath;
  begin
    if Selected <> nil then
    begin
      if Selected.Parent = nil then
        FStateData.CurrentPath := Root.Pidl
      else
        FStateData.CurrentPath := TcxShellItemInfo(TcxShellTreeItemProducer(
          Selected.Parent.Data).Items[Selected.Index]).FullPIDL;
      FStateData.CurrentPath := GetPidlCopy(FStateData.CurrentPath);
    end
    else
      FStateData.CurrentPath := nil;
  end;

begin
  SaveTopItemIndex;
  SaveExpandedNodes;
  SaveCurrentPath;
end;

procedure TcxCustomInnerShellTreeView.Loaded;
begin
  if Root.Pidl = nil then
    Root.CheckRoot;
  UpdateNode(nil, False);
end;

procedure TcxCustomInnerShellTreeView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
    if AComponent = FListView then
      FListView := nil
end;

procedure TcxCustomInnerShellTreeView.RemoveDropTarget;
begin
  RevokeDragDrop(Handle);
end;

procedure TcxCustomInnerShellTreeView.RemoveItemProducer(
  Producer: TcxShellTreeItemProducer);
var
  tempList: TList;
begin
  tempList := ItemProducersList.LockList;
  try
    tempList.Remove(Producer);
  finally
    ItemProducersList.UnlockList;
  end;
end;

procedure TcxCustomInnerShellTreeView.CreateChangeNotification(
  ANode: TTreeNode = nil);

  function GetShellChangeNotifierPIDL: PItemIDList;
  begin
    if Root.ShellFolder = nil then
      Root.CheckRoot;
    if ANode = nil then
      if Selected = nil then
        ANode := Items[0]
      else
        ANode := Selected;
    if ANode.Parent = nil then
      Result := Root.Pidl
    else
      Result := TcxShellItemInfo(TcxShellTreeItemProducer(
        ANode.Parent.Data).Items[ANode.Index]).FullPIDL;
  end;

begin
  if FIsChangeNotificationCreationLocked then
    Exit;
  FShellChangeNotificationCreation := True;
  try
    if not Options.TrackShellChanges or (Items.Count = 0) then
      RemoveChangeNotification
    else
      RegisterShellChangeNotifier(GetShellChangeNotifierPIDL, Handle,
        DSM_SHELLTREECHANGENOTIFY, True, FShellChangeNotifierData);
  finally
    FShellChangeNotificationCreation := False;
  end;
end;

function TcxCustomInnerShellTreeView.DoAddFolder(AFolder: TcxShellFolder): Boolean;
begin
  Result := True;
  if Assigned(FOnAddFolder) then
    FOnAddFolder(Self, AFolder, Result);
end;

procedure TcxCustomInnerShellTreeView.SetPrevTargetNode(const Value: TTreeNode);
begin
  if FPrevTargetNode <> nil then
     FPrevTargetNode.DropTarget := False;
  FPrevTargetNode := Value;
  if FPrevTargetNode <> nil then
     FPrevTargetNode.DropTarget := True;
end;

function TcxCustomInnerShellTreeView.TryReleaseDropTarget: HResult;
begin
  Result := S_OK;
  if CurrentDropTarget <> nil then
     Result := CurrentDropTarget.DragLeave;
  CurrentDropTarget := nil;
  PrevTargetNode := nil;
end;

(*procedure TcxCustomInnerShellTreeView.UpdateNode(ANode: TTreeNode);
var
  uNode:TTreeNode;
begin
  if csLoading in ComponentState then
     Exit;
  uNode:=nil;
  if IsWindow(Handle) and Root.IsValid then
  begin
    if ANode=nil then
    begin
      if (Items.Count > 0) and (Items[0].Data <> nil) then
        Items.Clear;
      if Items.Count=0 then
        uNode:=Items.AddFirst(nil,'')
      else
        uNode:=Items[0];
      uNode.Data:=TcxShellTreeItemProducer.Create(Self);
    end
    else
       uNode:=ANode;
    uNode.HasChildren:=True;
  end;
  if uNode<>nil then
     CanExpand(uNode);
end;*)

procedure TcxCustomInnerShellTreeView.UpdateNode(ANode: TTreeNode;
  AFast: Boolean);
var
  AFullPIDL: PITemIDList;
  AParentItemProducer: TcxShellTreeItemProducer;
  ATempNode: TTreeNode;
begin
  if csLoading in ComponentState then
    Exit;
  if IsWindow(WindowHandle) and Root.IsValid then
  begin
    if ANode = nil then
    begin
      if (Items.Count > 0) and (Items[0].Data <> nil) then
        Items.Clear;
      if Items.Count = 0 then
        ATempNode := Items.AddFirst(nil, '')
      else
        ATempNode := Items[0];
      ATempNode.Data := TcxShellTreeItemProducer.Create(Self);
    end
    else
      ATempNode := ANode;
    if not AFast or (ATempNode.Parent = nil) then
      ATempNode.HasChildren := True
    else
    begin
      AParentItemProducer := TcxShellTreeItemProducer(ATempNode.Parent.Data);
      AFullPIDL := ConcatenatePidls(AParentItemProducer.FolderPidl,
        TcxShellItemInfo(AParentItemProducer.Items[ATempNode.Index]).pidl);
      TcxShellTreeItemProducer(ATempNode.Data).FolderPidl := AFullPIDL;
      ATempNode.HasChildren := HasSubItems(AParentItemProducer.ShellFolder,
        AFullPIDL, AParentItemProducer.GetEnumFlags);
    end;
    if not AFast or (ATempNode.Parent = nil) then
      CanExpand(ATempNode);
    CreateChangeNotification;
  end;
end;

procedure TcxCustomInnerShellTreeView.SetListView(
  Value: TcxCustomInnerShellListView);
begin
  if FListView = Value then
    Exit;
  if FListView <> nil then
  begin
    FListView.SetTreeView(nil);
    FListView.RemoveFreeNotification(Self);
  end;
  FListView := Value;
  if FListView <> nil then
  begin
    FListView.FreeNotification(Self);
    FListView.SetTreeView(Self);
  end;
  DoNavigateListView;
end;

procedure TcxCustomInnerShellTreeView.RootSettingsChanged(Sender: TObject);
begin
  if (Parent <> nil) and (csLoading in Parent.ComponentState) then
    Exit;
  if (FListView <> nil) and FListView.HandleAllocated then
    SendMessage(FListView.Handle, DSM_SYNCHRONIZEROOT, Integer(Root), 0);
  if (FComboBoxControl <> nil) and FComboBoxControl.HandleAllocated then
    SendMessage(FComboBoxControl.Handle, DSM_SYNCHRONIZEROOT, Integer(Root), 0);
end;

procedure TcxCustomInnerShellTreeView.SetShowInfoTips(Value: Boolean);
begin
  if Value <> FShowInfoTips then
  begin
    FShowInfoTips := Value;
    AdjustControlParams;
  end;
end;

procedure TcxCustomInnerShellTreeView.ShowToolTipChanged(Sender: TObject);
begin
  ToolTips := Options.ShowToolTip;
  AdjustControlParams;
end;

procedure TcxCustomInnerShellTreeView.DSMShellTreeChangeNotify(var Message: TMessage);

  function NeedProcessMessage: Boolean; // TODO more detailed selection
  begin
    Result := (Message.LParam <> SHCNE_UPDATEITEM) or
      (GetNodeByPIDL(PPItemIDList(Message.WParam)^) <> nil);
  end;

begin
  if FShellChangeNotificationCreation or FIsUpdating or not NeedProcessMessage then
    Exit;
  try
    if DraggedObject <> nil then
      Exit;

    Items.BeginUpdate;
    FIsUpdating := True;
    try
      SendMessage(Parent.Handle, WM_SETREDRAW, 0, 0);
      try
        SaveTreeState;
        try
          Items.Clear;
          UpdateNode(nil, False);
        finally
          RestoreTreeState;
        end;
      finally
        SendMessage(Parent.Handle, WM_SETREDRAW, 1, 0);
        Parent.Update;
      end;
    finally
      FIsUpdating := False;
      Items.EndUpdate;
    end;
  finally
    DoShellChange(Self, OnShellChange, Message);
  end;
end;

procedure TcxCustomInnerShellTreeView.DSMShellTreeRestoreCurrentPath(var Message: TMessage);
var
  APrevAutoExpand: Boolean;
begin
  if FIsChangeNotificationCreationLocked then
    PostMessage(Handle, DSM_SHELLTREERESTORECURRENTPATH, Message.WPARAM, 0)
  else
    try
      APrevAutoExpand := AutoExpand;
      AutoExpand := False;
      try
        SendMessage(Handle, DSM_DONAVIGATE, Message.WPARAM, 0);
        DoNavigateListView;
      finally
        AutoExpand := APrevAutoExpand;
      end;
    finally
      DisposePidl(PItemIDList(Message.WPARAM));
    end;
end;

procedure TcxCustomInnerShellTreeView.DSMSynchronizeRoot(var Message: TMessage);
begin
  if not((Parent <> nil) and (csLoading in Parent.ComponentState)) then
    Root.Update(TcxCustomShellRoot(Message.WParam));
end;

procedure TcxCustomInnerShellTreeView.DoNavigateListView;
var
  ATempPIDL: PItemIDList;
begin
  if (Items.Count = 0) or (not Assigned(ListView) and not Assigned(ComboBoxControl)) then
    Exit;

  if Selected <> nil then
    ATempPIDL := TcxShellTreeItemProducer(Selected.Data).FolderPidl
  else
    ATempPIDL := TcxShellTreeItemProducer(Items[0].Data).FolderPidl;
  if Assigned(ListView) then
    ListView.ProcessTreeViewNavigate(ATempPIDL);

  if Assigned(ComboBoxControl) and (ComboBoxControl.Parent <> nil) then
  begin
    ComboBoxControl.HandleNeeded;
    SendMessage(ComboBoxControl.Handle, DSM_DONAVIGATE, Integer(ATempPIDL), 0);
  end;
end;

procedure TcxCustomInnerShellTreeView.DragDropSettingsChanged(Sender: TObject);
begin
  if DragDropSettings.AllowDragObjects then
    DragMode := dmAutomatic
  else
    DragMode := dmManual;
end;

function TcxCustomInnerShellTreeView.GetNodeByPIDL(APIDL: PItemIDList): TTreeNode;
var
  AItemIndex, I: Integer;
  APID: PItemIDList;
begin
  Result := nil;
  if APIDL = nil then
    Exit;

  if Root.ShellFolder = nil then
    Root.CheckRoot;
  if EqualPIDLs(Root.Pidl, APIDL) then
  begin
    Result := Items[0];
    Exit;
  end;

  if not IsSubPath(Root.Pidl, APIDL) then
    Exit;

  for I := 0 to GetPidlItemsCount(Root.Pidl) - 1 do
    APIDL := GetNextItemID(APIDL);
  Result := Items[0];
  for I := 0 to GetPidlItemsCount(APIDL) - 1 do
  begin
    APID := ExtractParticularPidl(APIDL);
    if APID = nil then
      Break;
    try
      AItemIndex := TcxShellTreeItemProducer(Result.Data).GetItemIndexByPidl(APID);
      if (AItemIndex = -1) or (AItemIndex >= Result.Count) then
      begin
        Result := nil;
        Break;
      end;
      Result := Result.Item[AItemIndex];
      APIDL := GetNextItemID(APIDL);
    finally
      DisposePidl(APID);
    end;
  end;
end;

procedure TcxCustomInnerShellTreeView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = VK_F5 then
    UpdateContent;
end;

procedure TcxCustomInnerShellTreeView.RemoveChangeNotification;
begin
  UnregisterShellChangeNotifier(FShellChangeNotifierData);
end;

procedure TcxCustomInnerShellTreeView.Change(Node: TTreeNode);
begin
  inherited Change(Node);
  UpdateNode(Selected, not Navigation);
  if not Navigation then
    DoNavigateListView;
end;

procedure TcxCustomInnerShellTreeView.DsmDoNavigate(var Message: TMessage);
var
  srcPidl: PItemIDList;
  destPidl: PItemIDList;
  pFolder: IShellFolder;
  partDstPidl: PItemIDList;
  i: Integer;
  tempProducer: TcxShellTreeItemProducer;
  tempIndex: Integer;
begin
  Navigation := True;
  Items.BeginUpdate;
  try
    if Failed(SHGetDesktopFolder(pFolder)) then
       Exit;
    srcPidl := Root.Pidl;
    destPidl := PItemIDList(Message.WParam);
    if GetPidlItemsCount(srcPidl) > GetPidlItemsCount(destPidl) then
    begin
      Root.Pidl := destPidl;
      Items[0].Selected := True;
      Exit;
    end;
    for i := 0 to GetPidlItemsCount(srcPidl) - 1 do
        DestPidl := GetNextItemID(DestPidl);
    Selected := Items[0];
    for i := 0 to GetPidlItemsCount(destPidl) - 1 do
    begin
      tempProducer := Selected.Data;
      partDstPidl := ExtractParticularPidl(destPidl);
      destPidl := GetNextItemID(destPidl);
      if partDstPidl = nil then
         Break;
      try
        tempIndex := tempProducer.GetItemIndexByPidl(partDstPidl);
        if tempIndex = -1 then
           Break;
        Selected := Selected.Item[tempIndex];
      finally
        DisposePidl(partDstPidl);
      end;
    end;
  finally
    Items.EndUpdate;
    Navigation := False;
  end;

  if Selected <> nil then
    SendMessage(Handle, TVM_ENSUREVISIBLE, 0, LPARAM(Selected.ItemId));
end;

{ TcxShellTreeItemProducer }

function TcxShellTreeItemProducer.GetItemsInfoGatherer: TcxShellItemsInfoGatherer;
begin
  Result := TreeView.ItemsInfoGatherer;
end;

procedure TcxShellTreeItemProducer.CheckForSubitems(
  AItem: TcxShellItemInfo);
begin
  inherited CheckForSubitems(AItem);
  if (AItem <> nil) and (not AItem.IsRemovable) then
    AItem.CheckSubitems(ShellFolder, GetEnumFlags);
end;

function TcxShellTreeItemProducer.CheckUpdates:Boolean;
const
  R: array[Boolean] of Byte = (0, 1);
var
  pEnum: IEnumIDList;
  currentCelt: Cardinal;
  rPidl: PItemIDList;
  Item: TcxShellItemInfo;
  Res: HRESULT;
  SaveCursor: TCursor;
  tempList: TList;

  function ShellSortFunction(Item1, Item2: Pointer): Integer;
  var
    AItemInfo1, AItemInfo2: TcxShellItemInfo;
  begin
    Result := 0;
    if (Item1 = nil) or (Item2 = nil) then
       Exit;
    AItemInfo1 := TcxShellItemInfo(Item1);
    AItemInfo2 := TcxShellItemInfo(Item2);
    Result := R[AItemInfo2.IsFolder] - R[AItemInfo1.IsFolder];
    if Result = 0 then
      Result := Smallint(TcxShellTreeItemProducer(
        AItemInfo1.ItemProducer).ShellFolder.CompareIDs(0, AItemInfo1.pidl, AItemInfo2.pidl));
  end;

  procedure MergeItems(Existent,New:TList);
  var
    i, j: Integer;
    exstItem: TcxShellItemInfo;
    newItem: TcxShellItemInfo;
    found: Boolean;
  begin
    i := 0;
    while (i < Existent.Count) do
    begin
      exstItem := Existent[i];
      found := False;
      for j := 0 to New.Count-1 do
      begin
        newItem := New[j];
        if Smallint(ShellFolder.CompareIDs(0, exstItem.pidl, newItem.pidl)) = 0 then
        begin
          exstItem.Free;
          Existent[i] := newItem;
          New.Remove(newItem);
          found := True;
          Break;
        end;
      end;
      if not found then
      begin
        NotifyRemoveItem(i);
        Existent.Remove(exstItem);
        exstItem.Free;
      end
      else
        Inc(i);
    end;
    for i := 0 to New.Count - 1 do
      if CanAddFolder(TcxShellItemInfo(New[i]).Folder) then
      begin
        Existent.Add(New[i]);
        exstItem := Existent[Existent.Count - 1];
        exstItem.CheckUpdate(ShellFolder, FolderPidl, False);
        NotifyAddItem(Existent.Count - 1);
      end
      else
        TcxShellItemInfo(New[i]).Free;
  end;

begin
  Result := False;
  if ShellFolder = nil then
     Exit;
  if Failed(ShellFolder.EnumObjects(Owner.ParentWindow, GetEnumFlags, pEnum)) or
    not Assigned(pEnum) then
      Exit;
  currentCelt := 1;
  tempList := TList.Create;
  SaveCursor := Owner.Cursor;
  try
    Owner.Cursor := crHourGlass;
    repeat
      Res := pEnum.Next(currentCelt, rPidl, currentCelt);
      try
        if Res = E_INVALIDARG then
        begin
          currentCelt := 1;
          Res := pEnum.Next(currentCelt, rPidl, currentCelt);
        end;
        if Failed(Res) or (Res = S_FALSE) then
           Break;
        if currentCelt = 0 then
           Break;
        Item := TcxShellItemInfo.Create(Self, ShellFolder, FolderPidl, rPidl, False);
        if Item.Name = '' then
        begin
          Item.Free;
          Continue;
        end;
        tempList.Add(Item);
      finally
        DisposePidl(rPidl);
      end;
    until(Res = S_FALSE);
    tempList.Sort(@ShellSortFunction);
    LockWrite;
    try
      MergeItems(Items, tempList);
    finally
      UnlockWrite;
    end;
  finally
    Owner.Cursor := SaveCursor;
    FreeAndNil(tempList);
  end;
  Result := True;
end;

constructor TcxShellTreeItemProducer.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);
  TreeView.AddItemProducer(Self);
end;

destructor TcxShellTreeItemProducer.Destroy;
begin
  if Assigned(FOnDestroy) then
    FOnDestroy(Self);
  TreeView.RemoveItemProducer(Self);
  inherited Destroy;
end;

function TcxShellTreeItemProducer.AllowBackgroundProcessing: Boolean;
begin
  Result:= not TreeView.Navigation;
end;

function TcxShellTreeItemProducer.CanAddFolder(AFolder: TcxShellFolder): Boolean;
begin
  Result := TreeView.DoAddFolder(AFolder);
end;

function TcxShellTreeItemProducer.GetEnumFlags: Cardinal;
begin
  Result := TreeView.Options.GetEnumFlags;
end;

function TcxShellTreeItemProducer.GetShowToolTip: Boolean;
begin
  Result := TreeView.ShowInfoTips;
end;

procedure TcxShellTreeItemProducer.InitializeItem(Item: TcxShellItemInfo);
begin
  inherited;
  Item.CheckUpdate(ShellFolder, FolderPidl, False);
  CheckForSubitems(Item);
end;

procedure TcxShellTreeItemProducer.NotifyAddItem(Index: Integer);
begin
  if (Owner.HandleAllocated) and (Node <> nil) then
     SendMessage(Owner.Handle, DSM_NOTIFYADDITEM, Index, Integer(Node));
end;

procedure TcxShellTreeItemProducer.NotifyRemoveItem(Index: Integer);
begin
  if (Owner.HandleAllocated) and (Node <> nil) then
     SendMessage(Owner.Handle, DSM_NOTIFYREMOVEITEM, Index, Integer(Node));
end;

procedure TcxShellTreeItemProducer.NotifyUpdateItem(AItem: PcxRequestItem);
begin
  if (Owner.HandleAllocated) and (Node <> nil) then
    PostMessage(Owner.Handle, DSM_NOTIFYUPDATE, AItem.ItemIndex, Integer(Node));
end;

procedure TcxShellTreeItemProducer.ProcessItems(AIFolder: IShellFolder;
  APIDL: PItemIDList; ANode: TTreeNode; cPreloadItems: Integer);

  function SetNodeText: Boolean;
  var
    ATempPIDL: PItemIDList;
  begin
    Result := ANode.Parent <> nil;
    if not Result then
      Exit;
    ATempPIDL := GetLastPidlItem(APIDL);
    Node.Text := GetShellItemDisplayName(
      TcxShellTreeItemProducer(Node.Parent.Data).ShellFolder, ATempPIDL, True);
  end;

var
  AFileInfo: TShFileInfo;
begin
  Node := ANode;
  SHGetFileInfo(PChar(APIDL), 0, AFileInfo, SizeOf(AFileInfo),
    SHGFI_PIDL or SHGFI_DISPLAYNAME or SHGFI_SYSICONINDEX);
  if not SetNodeText then
    Node.Text := StrPas(AFileInfo.szDisplayName);
  ANode.ImageIndex := AFileInfo.iIcon;
  SHGetFileInfo(PChar(APIDL), 0, AFileInfo, SizeOf(AFileInfo),
    SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_OPENICON);
  Node.SelectedIndex := AFileInfo.iIcon;
  ProcessItems(AIFolder, APIDL, cPreloadItems);
end;

procedure TcxShellTreeItemProducer.SetItemsCount(Count: Integer);
begin
  if (Owner.HandleAllocated) and (Node <> nil) then
     SendMessage(Owner.Handle, DSM_SETCOUNT, Count, Integer(Node));
end;

function TcxShellTreeItemProducer.GetTreeView: TcxCustomInnerShellTreeView;
begin
  Result := TcxCustomInnerShellTreeView(Owner);
end;

initialization
  NavigationLock := False;

end.

