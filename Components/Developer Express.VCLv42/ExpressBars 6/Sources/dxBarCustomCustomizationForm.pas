{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars Customization Form                              }
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

unit dxBarCustomCustomizationForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, Buttons, cxClasses, dxBar, ActnList,
  cxLookAndFeelPainters, ToolWin, ImgList, Contnrs, cxLookAndFeels;

var
  dxWM_LB_SYNCHRONIZE: Cardinal = WM_DX + 1;
  dxWM_LB_SYNCHRONIZESELECTION: Cardinal = WM_DX + 2;
  dxWM_LB_UPDATEEVENTS: Cardinal = WM_DX + 3;

const
  dxWM_LB_DEFERREDCALLSYNCHRONIZATION = WM_DX + 4;

type
  TdxBarCustomCustomizationForm = class;
  
  TdxBarPermissiveProc = function (Sender: TComponent): Boolean of object;

  { TdxBarCustomizationFormPainter }

  TdxBarCustomizationFormPainter = class(TObject)
  protected
    class function GetGlyphSize(AItem: TdxBarItem): TSize;
    class function GetIsGlyphItem(AItem: TdxBarItem): Boolean;
    class function GetIsNeedDrawSubItemArrow(AItem: TdxBarItem): Boolean;

    class procedure DrawCaption(ACanvas: TCanvas; var AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); virtual;
    class procedure DrawEditEdge(ACanvas: TCanvas; var AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); virtual;
    class procedure DrawEditContent(ACanvas: TCanvas; AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected, ADrawArrowButton: Boolean); virtual;
    class procedure InternalDrawCaption(ACanvas: TCanvas; var ATextRect: TRect;
      const AText: string; AItem: TdxCustomBarEdit; ASelected: Boolean); virtual;
    class procedure InternalDrawEditContent(ACanvas: TCanvas; AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); virtual;

    // ButtonOrSubItem
    class procedure CalcButtonOrSubItemRects(AItem: TdxBarItem; const R: TRect;
      out ASideStripRect, ATextRect, AArrowRect: TRect); virtual;
    class procedure DrawButtonOrSubItemArrowBackground(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; Selected: Boolean); virtual;
    class procedure DrawButtonOrSubItemBackground(ACanvas: TCanvas; AItem: TdxBarItem;
      const ABounds, ASideStripRect, AArrowRect: TRect; ASelected: Boolean); virtual;
    class procedure DrawButtonOrSubItemGlyph(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; ASelected: Boolean); virtual;
    class procedure DrawButtonOrSubItemText(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; const ACaption: string; Selected: Boolean);

    class procedure DrawSubItemArrow(ACanvas: TCanvas; X, Y: Integer; ASelected: Boolean); virtual;
  public
    class procedure DrawButtonOrSubItem(ACanvas: TCanvas; ARect: TRect;
      AItem: TdxBarItem; ACaption: string; Selected: Boolean); virtual;
    class procedure DrawCheckBox(ACanvas: TCanvas; R: TRect; AChecked, AEnabled: Boolean); virtual;
    class procedure DrawComboBoxButton(ACanvas: TCanvas; AItem: TdxBarItem;
      ARect: TRect; ASelected: Boolean); virtual;
    class procedure DrawEdit(ACanvas: TCanvas; ARect: TRect;
      AItem: TdxCustomBarEdit; Selected, ADrawArrowButton: Boolean); virtual;
    class procedure DrawFocusedRect(ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem); virtual;

    class function BrushColors(Selected: Boolean; AItem: TdxBarItem): TColor; virtual;
    class function FontColors(Selected: Boolean): TColor; virtual;
    class function GetButtonColor(AItem: TdxBarItem; ASelected: Boolean): Integer; virtual;
    class function SideStripColor(Selected: Boolean; AItem: TdxBarItem): TColor; virtual;

    class function GetBarButtonHeight: Integer; virtual;
    class function GetComboBoxButtonWidth: Integer; virtual;
  end;
  
  TdxBarCustomizationFormPainterClass = class of TdxBarCustomizationFormPainter;

  { TdxBarCustomizationFormStandardPainter }

  TdxBarCustomizationFormStandardPainter = class(TdxBarCustomizationFormPainter)
  public
    class procedure DrawFocusedRect(ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem); override;
  end;

  { TdxBarCustomizationFormFlatPainter }

  TdxBarCustomizationFormFlatPainter = class(TdxBarCustomizationFormPainter)
  protected
    class procedure DrawEditEdge(ACanvas: TCanvas; var AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure InternalDrawCaption(ACanvas: TCanvas; var ATextRect: TRect;
      const AText: string; AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure DrawButtonOrSubItemArrowBackground(ACanvas: TCanvas;
      R: TRect; AItem: TdxBarItem; Selected: Boolean); override;
    class procedure DrawButtonOrSubItemGlyph(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; ASelected: Boolean); override;
  public
    class function BrushColors(Selected: Boolean; AItem: TdxBarItem): TColor; override;
    class procedure DrawButtonOrSubItem(ACanvas: TCanvas; ARect: TRect;
      AItem: TdxBarItem; ACaption: string; Selected: Boolean); override;
    class procedure DrawComboBoxButton(ACanvas: TCanvas; AItem: TdxBarItem;
      ARect: TRect; ASelected: Boolean); override;
    class procedure DrawFocusedRect(ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem); override;
    class function FontColors(Selected: Boolean): TColor; override;
    class function SideStripColor(Selected: Boolean; AItem: TdxBarItem): TColor; override;
  end;

  { TdxBarCustomizationFormOffice11Painter }

  TdxBarCustomizationFormOffice11Painter = class(TdxBarCustomizationFormFlatPainter)
  protected
    class procedure DrawEditEdge(ACanvas: TCanvas; var AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure InternalDrawCaption(ACanvas: TCanvas; var ATextRect: TRect;
      const AText: string; AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure DrawButtonOrSubItemArrowBackground(ACanvas: TCanvas;
      R: TRect; AItem: TdxBarItem; Selected: Boolean); override;
    class procedure DrawButtonOrSubItemBackground(ACanvas: TCanvas;
      AItem: TdxBarItem; const ABounds, ASideStripRect, AArrowRect: TRect;
      ASelected: Boolean); override;
    class procedure DrawButtonOrSubItemGlyph(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; ASelected: Boolean); override;
  public
    class function BrushColors(Selected: Boolean; AItem: TdxBarItem): TColor; override;
    class procedure DrawButtonOrSubItem(ACanvas: TCanvas; ARect: TRect;
      AItem: TdxBarItem; ACaption: string; Selected: Boolean); override;
    class procedure DrawComboBoxButton(ACanvas: TCanvas; AItem: TdxBarItem;
      ARect: TRect; ASelected: Boolean); override;
    class function FontColors(Selected: Boolean): TColor; override;
    class function GetButtonColor(AItem: TdxBarItem; ASelected: Boolean): Integer; override;
  end;

  { TdxBarCustomizationFormXPPainter }

  TdxBarCustomizationFormXPPainter = class(TdxBarCustomizationFormPainter)
  protected
    class procedure DrawEditEdge(ACanvas: TCanvas; var AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure InternalDrawEditContent(ACanvas: TCanvas; AItemRect: TRect;
      AItem: TdxCustomBarEdit; ASelected: Boolean); override;
    class procedure DrawButtonOrSubItemArrowBackground(ACanvas: TCanvas;
      R: TRect; AItem: TdxBarItem; Selected: Boolean); override;
    class procedure DrawButtonOrSubItemGlyph(ACanvas: TCanvas; R: TRect;
      AItem: TdxBarItem; ASelected: Boolean); override;
  public
    class procedure DrawComboBoxButton(ACanvas: TCanvas; AItem: TdxBarItem;
      ARect: TRect; ASelected: Boolean); override;
    class procedure DrawFocusedRect(ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem); override;
    class function GetComboBoxButtonWidth: Integer; override;
  end;

  { TdxBarRunTimeSelectionController }

  TdxBarRunTimeSelectionController = class(TInterfacedObject, IdxBarDesigner)
  private
    FSelectionList: TcxComponentList;
    FOnSelectionChanged: TNotifyEvent;
    procedure AddSelection(AComponent: TComponent);
    procedure SelectionListNotify(Sender: TObject; AComponent: TComponent; AAction: TListNotification);
    procedure SelectionListChanged(Sender: TObject; AComponent: TComponent; AAction: TcxComponentCollectionNotification);
  public
    constructor Create;
    destructor Destroy; override;

    // IdxBarDesigner
    function CanDeleteComponent(AComponent: TComponent): Boolean;
    procedure GetSelection(AList: TList);
    function GetSelectionStatus(AComponent: TPersistent): TdxBarSelectionStatus;
    function IsComponentSelected(AComponent: TPersistent): Boolean;
    procedure SelectComponent(AComponent: TPersistent; ASelectionOperation: TdxBarSelectionOperation = soExclusive);
    procedure SetSelection(AList: TList);
    procedure ShowDefaultEventHandler(AItem: TdxBarItem);
    function UniqueName(const BaseName: string): string;

    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;

  { TdxBarCustomizationFormListBoxHelper }

  TdxBarCustomizationFormListBoxHelper = class(TObject)
  private
    FListBox: TListBox;
    FOldWndProc: TWndMethod;
    FOwner: TdxBarCustomCustomizationForm;
    function GetBarManager: TdxBarManager;
    function GetPainterClass: TdxBarCustomizationFormPainterClass;
  protected
    procedure WndProc(var Message: TMessage); virtual;
  public
    constructor Create(AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox); virtual;
    destructor Destroy; override;

    property BarManager: TdxBarManager read GetBarManager;
    property ListBox: TListBox read FListBox;
    property OldWndProc: TWndMethod read FOldWndProc;
    property Owner: TdxBarCustomCustomizationForm read FOwner;
    property PainterClass: TdxBarCustomizationFormPainterClass read GetPainterClass;
  end;

  { TdxBarCustomCustomizationForm }

  TdxBarCustomCustomizationForm = class(TForm)
    aAddItem: TAction;
    aClearItemList: TAction;
    aDeleteItem: TAction;
    aDeleteToolBar: TAction;
    alCustomize: TActionList;
    aMoveDownItem: TAction;
    aMoveUpItem: TAction;
    aNewToolBar: TAction;
    aRenameToolBar: TAction;
    aResetToolBar: TAction;
    aSubMenuEditor: TAction;
    BarManager1: TdxBarManager;
    CategoriesAdd: TdxBarButton;
    CategoriesDelete: TdxBarButton;
    CategoriesInsert: TdxBarButton;
    CategoriesItemsVisible: TdxBarCombo;
    CategoriesPopupMenu: TdxBarPopupMenu;
    CategoriesRename: TdxBarButton;
    CategoriesVisible: TdxBarButton;
    CommandsAdd: TdxBarButton;
    CommandsClear: TdxBarButton;
    CommandsDelete: TdxBarButton;
    CommandsMoveDown: TdxBarButton;
    CommandsMoveUp: TdxBarButton;
    CommandsPopupMenu: TdxBarPopupMenu;
    CommandsSubMenuEditor: TdxBarButton;
    imgGroups: TImageList;
    procedure aAddItemExecute(Sender: TObject);
    procedure aClearItemListExecute(Sender: TObject);
    procedure aDeleteItemExecute(Sender: TObject);
    procedure aDeleteToolBarExecute(Sender: TObject);
    procedure aMoveItemExecute(Sender: TObject);
    procedure aNewToolBarExecute(Sender: TObject);
    procedure aRenameToolBarExecute(Sender: TObject);
    procedure aResetToolBarExecute(Sender: TObject);
    procedure aSubMenuEditorExecute(Sender: TObject);
    procedure CategoriesAddClick(Sender: TObject);
    procedure CategoriesDeleteClick(Sender: TObject);
    procedure CategoriesInsertClick(Sender: TObject);
    procedure CategoriesItemsVisibleChange(Sender: TObject);
    procedure CategoriesPopupMenuPopup(Sender: TObject);
    procedure CategoriesRenameClick(Sender: TObject);
    procedure CategoriesVisibleClick(Sender: TObject);
    procedure CommandsAddClick(Sender: TObject);
    procedure CommandsClearClick(Sender: TObject);
    procedure CommandsDeleteClick(Sender: TObject);
    procedure CommandsMoveDownClick(Sender: TObject);
    procedure CommandsMoveUpClick(Sender: TObject);
    procedure CommandsPopupMenuPopup(Sender: TObject);
    procedure CommandsSubMenuEditorClick(Sender: TObject);
  private
    FAlreadySynchronous: TListBox;
    FBarListBoxHelper: TdxBarCustomizationFormListBoxHelper;
    FBarsOldChangeEvent: TcxComponentCollectionChangeEvent;
    FCategoryListBoxHelper: TdxBarCustomizationFormListBoxHelper;
    FDisabledWindows: TList;
    FItemsListBoxHelper: TdxBarCustomizationFormListBoxHelper;
    FItemsOldChangeEvent: TcxComponentListChangeEvent;
    FSelectionList: TcxComponentList;
    function CanDeleteSelectedCategory: Boolean;
    function CanDeleteSelectedCategoryCommands: Boolean;
    function GetIsLookAndFeelUsed: Boolean;
    function GetLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
    function GetSelectedBar: TdxBar;
    procedure FormCloseEvent(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroyEvent(Sender: TObject);
    procedure FormHideEvent(Sender: TObject);
    procedure FormShowEvent(Sender: TObject);

    procedure WMDeferredCallSynchronizationListBox(var Message: TMessage); message dxWM_LB_DEFERREDCALLSYNCHRONIZATION;
  protected
    procedure BarListToggleCheck(AIndex: Integer);
    procedure BarsChange(Sender: TObject; AItem: TcxComponentCollectionItem;  AAction: TcxComponentCollectionNotification);
    function CanDeleteBar(ABar: TComponent): Boolean;
    function CreateSelectionList: TcxComponentList;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DeleteSelectedObjects(AListBox: TListBox;  ADeleteProc: TNotifyEvent = nil; ASynchronizeDesigner: Boolean = True);
  {$IFDEF DELPHI9}
    procedure DestroyWindowHandle; override;
  {$ENDIF}
    procedure DoShowHelp; virtual;
    function GetBarItemsBackgroundColor: TColor; virtual;
    function GetBarList(Index: Integer): TdxBar; virtual;
    function GetBarListBox: TListBox; virtual; abstract;
    function GetCategoriesList: TListBox; virtual; abstract;
    function GetDisableParent(ABarManager: TdxBarManager; out AParent: TWinControl): Boolean;
    function GetEditBackgroundColor: TColor;
    function GetEditTextColor: TColor;
    function GetExclusiveObject(AListBox: TListBox): TObject;
    function GetItemsListBox: TListBox; virtual; abstract;
    function GetNextSelectedObject(AListBox: TListBox): TObject;
    function GetObjectFromListBox(AListBox: TListBox; AIndex: Integer): TObject;
    function GetPainterClass: TdxBarCustomizationFormPainterClass; virtual;
    function GetSelCount(AListBox: TListBox): Integer;
    procedure GetSelection(AListBox: TListBox; AList: TList);
    function GetVisibleItemsCount(AListBox: TListBox): Integer;
    procedure ItemsChange(Sender: TObject; AComponent: TComponent; AAction: TcxComponentCollectionNotification); virtual;
    function IsBarPredefined(ABar: TdxBar): Boolean;
    procedure MoveItems(AListBox: TListBox; ABarComponentList: TdxBarComponentList; ADirection: Integer);
    procedure SetSelection(AListBox: TListBox; AList: TList); overload;
    procedure SetSelection(AListBox: TListBox; AObject: TObject); overload;

    procedure DeferredCallSynchronizationListBox(AListBox: TListBox);
    procedure SynchronizeListBox(AListBox: TListBox; AChangedObject: TObject = nil; AAction: TcxComponentCollectionNotification = ccnChanged);
    procedure SynchronizeListBoxes; virtual; abstract;
    procedure SynchronizeListBoxSelection(AListBox: TListBox);
    procedure UpdateTopIndex(AListBox: TListBox);
    function PrepareMenuAnimationsComboBox(AComboBoxFont: TFont; AComboBoxStrings: TStrings): Integer;

    function GetItemList(Index: Integer): TdxBarItem;
    function GetSelectedItem: TdxBarItem;
    procedure MoveItem(Delta: Integer);

    procedure EnableWindows(AEnable: Boolean);
    procedure FreeSelectionList;
    procedure PrepareControls; virtual;
    procedure ReplaceByCheckableButton(const ACaption: string;
      ASource, AAdjustWithControl: TControl; APopupMenu: TdxBarPopupMenu);
    procedure RestoreOldEvents; virtual;
    procedure SelectBarManager;
    procedure SetNewWindowProc(AControl: TControl;
      ANewWindowProc: TWndMethod; out AOldWindowProc: TWndMethod);
    procedure ShowCategoryPopupMenu(const APoint: TPoint);

    procedure SynchronizeDesigner(ANewSelection: IdxBarSelectableItem); overload;
    procedure SynchronizeDesigner(AListBox: TListBox); overload;

    procedure UpdateCommonEvents(AListBox: TListBox;
      AAddAction, ADeleteAction, AMoveUpAction, AMoveDownAction: TAction;
      ADeletePermissiveProc: TdxBarPermissiveProc = nil);
    procedure UpdateItemDesciption(const AText: string); virtual;
    procedure UpdateItemsListEvents;
    procedure UpdateToolBarsEvents;

    procedure WMActivate(var Message: TMessage); message WM_ACTIVATE;
    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;

    property AlreadySynchronous: TListBox read FAlreadySynchronous;
    property BarItemsBackgroundColor: TColor read GetBarItemsBackgroundColor;
    property BarList[Index: Integer]: TdxBar read GetBarList;
    property BarListBox: TListBox read GetBarListBox;
    property BarListBoxHelper: TdxBarCustomizationFormListBoxHelper read FBarListBoxHelper;
    property CategoryListBoxHelper: TdxBarCustomizationFormListBoxHelper read FCategoryListBoxHelper;
    property EditBackgroundColor: TColor read GetEditBackgroundColor;
    property EditTextColor: TColor read GetEditTextColor;
    property IsLookAndFeelUsed: Boolean read GetIsLookAndFeelUsed;
    property ItemList[Index: Integer]: TdxBarItem read GetItemList;
    property ItemsListBox: TListBox read GetItemsListBox;
    property ItemsListBoxHelper: TdxBarCustomizationFormListBoxHelper read FItemsListBoxHelper;
    property SelectedItem: TdxBarItem read GetSelectedItem;
  public
    BarManager: TdxBarManager;
    constructor CreateEx(ABarManager: TdxBarManager); virtual;
    destructor Destroy; override;

    procedure BarManagerStyleChanged; virtual;
    procedure DesignSelectionChanged(Sender: TObject); virtual; abstract;
    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure SelectPage(APageIndex: Integer); virtual; abstract;
    procedure SwitchToItemsPage; virtual; abstract;
    procedure UpdateHelpButton; virtual; abstract;
    procedure UpdateOptions; virtual; abstract;
    procedure UpdateVisibility(const AWindowPos: TWindowPos);

    property CategoriesList: TListBox read GetCategoriesList;
    property LookAndFeelPainter: TcxCustomLookAndFeelPainterClass read GetLookAndFeelPainter;
    property PainterClass: TdxBarCustomizationFormPainterClass read GetPainterClass;
    property SelectedBar: TdxBar read GetSelectedBar;
    property SelectionList: TcxComponentList read FSelectionList;
  end;

  TdxBarCustomCustomizationFormClass = class of TdxBarCustomCustomizationForm;

var
  dxBarCustomizationFormClass: TdxBarCustomCustomizationFormClass;

function dxBarCustomizingForm: TdxBarCustomCustomizationForm;
function IsCustomizing: Boolean;
procedure dxBarCustomizing(ABarManager: TdxBarManager; AShow: Boolean);
procedure PrepareCustomizationFormFont(AForm: TCustomForm; ABarManager: TdxBarManager);

procedure HostBarManagerStyleChanged;
procedure UpdateHelpButton;
procedure UpdateBarManagerOptions;
implementation

uses
{$IFDEF DELPHI8}
  Types,
{$ENDIF}
  dxBarNameEd, dxBarPopupMenuEd, dxBarItemEd, dxBarStrs, dxBarAddGroupItemsEd,
  TypInfo, dxUxTheme, dxThemeManager, dxThemeConsts, dxOffice11, cxContainer,
  cxControls, cxGraphics, Math, cxGeometry, dxBarCustForm;

{$R *.dfm}

{ TCommandsListBox }

const
  dxBarButtonWidth = 23;
  dxBarButtonHeight = 22;
  dxBarComboBoxArrowWidth = 11;

  dxBarDefaultTextFlags = DT_NOCLIP or DT_NOPREFIX or DT_SINGLELINE or DT_LEFT or DT_VCENTER;

type
  TCustomdxBarContainerItemAccess = class(TCustomdxBarContainerItem);
  TdxBarAccess = class(TdxBar);
  TdxBarControlAccess = class(TdxBarControl);
  TdxBarItemAccess = class(TdxBarItem);
  TdxBarManagerAccess = class(TdxBarManager);
  TdxCustomBarEditAccess = class(TdxCustomBarEdit);

  { TdxBarCustomizationFormBarListHelper }

  TdxBarCustomizationFormBarListHelper = class(TdxBarCustomizationFormListBoxHelper)
  private
    procedure DoListClick(Sender: TObject);
    procedure DoListDrawItem(Control: TWinControl; Index: Integer; R: TRect;
      State: TOwnerDrawState);
    procedure DoListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox); override;
    function IsCheckBoxArea(X, Y: Integer): Boolean;
  end;

  { TdxBarCustomizationFormCategoryListHelper }

  TdxBarCustomizationFormCategoryListHelper = class(TdxBarCustomizationFormListBoxHelper)
  private
    FDraggingCategoryIndex: Integer;
    procedure DoListBoxClick(Sender: TObject);
    procedure DoListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DoListEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure DoListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox); override;
  end;

  { TdxBarCustomizationFormItemsListHelper }

  TdxBarCustomizationFormItemsListHelper = class(TdxBarCustomizationFormListBoxHelper)
  private
    procedure DoListClick(Sender: TObject);
    procedure DoListDblClick(Sender: TObject);
    procedure DoListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox); override;
  end;

var
  FCloseCustomizingFormFlag: Boolean;
  FdxBarCustomizingForm: TdxBarCustomCustomizationForm;

function dxBarCustomizingForm: TdxBarCustomCustomizationForm;
begin
  Result := FdxBarCustomizingForm;
end;

function IsCustomizing: Boolean;
begin
  Result := FdxBarCustomizingForm <> nil;
end;

procedure dxBarCustomizing(ABarManager: TdxBarManager; AShow: Boolean);

  procedure InvalidateUncustomizableToolbars;
  var
    ABar: TdxBar;
    I, J: Integer;
  begin
    for I := 0 to dxBarManagerList.Count - 1 do
      if dxBarManagerList[I] <> ABarManager then
        for J := 0 to dxBarManagerList[I].Bars.Count - 1 do
        begin
          ABar := dxBarManagerList[I].Bars[J];
          if ABar.Visible and (ABar.Control <> nil) and
            ABar.Control.HandleAllocated then
          begin
            TdxBarControlAccess(ABar.Control).UpdateDoubleBuffered;
            ABar.Control.Invalidate;
            SendMessage(ABar.Control.Handle, WM_NCPAINT, 1, 0);
          end;
        end;
  end;

  procedure DoShowCustomizationForm;
  begin
    if Assigned(ABarManager.OnShowCustomizingForm) then
      ABarManager.OnShowCustomizingForm(ABarManager);
  end;

  procedure DoHideCustomizationForm;
  begin
    if Assigned(ABarManager.OnHideCustomizingForm) then
      ABarManager.OnHideCustomizingForm(ABarManager);
  end;

begin
  if AShow then
  begin
    if FdxBarCustomizingForm <> nil then Exit;

    TdxBarManagerAccess(ABarManager).InternalUnmerge(nil, True);
    DoShowCustomizationForm;
    InvalidateUncustomizableToolbars;

    FdxBarCustomizingForm := dxBarCustomizationFormClass.CreateEx(ABarManager);
    FdxBarCustomizingForm.Show;
  end
  else
  begin
    if not FCloseCustomizingFormFlag then
      FreeAndNil(FdxBarCustomizingForm);
    dxBarSubMenuEditor.Free;

    DoHideCustomizationForm;
    InvalidateUncustomizableToolbars;
    TdxBarManagerAccess(ABarManager).RestoreMergeState;
  end;   
end;

procedure PrepareCustomizationFormFont(AForm: TCustomForm;
  ABarManager: TdxBarManager);
begin
  AForm.Font.Name := ABarManager.Font.Name;
  AForm.Font.Charset := ABarManager.Font.Charset;
end;

procedure HostBarManagerStyleChanged;
begin
  if IsCustomizing then
    FdxBarCustomizingForm.BarManagerStyleChanged;
end;

procedure UpdateHelpButton;
begin
  if IsCustomizing then
    FdxBarCustomizingForm.UpdateHelpButton;
end;

procedure UpdateBarManagerOptions;
begin
  if IsCustomizing then
    FdxBarCustomizingForm.UpdateOptions;
end;


type

  { TCheckableButton }

  TCheckableButton = class(TGraphicControl)
  private
    FDown: Boolean;
    FDropDownMenu: TdxBarPopupMenu;
    LButtonDown: Boolean;
    procedure SetDown(Value: Boolean);
    procedure SetDropDownMenu(Value: TdxBarPopupMenu);
    procedure DropDownMenuCloseup(Sender: TObject);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AdjustWithControl(AControl: TControl);
    
    property Down: Boolean read FDown write SetDown;
    property DropDownMenu: TdxBarPopupMenu read FDropDownMenu write SetDropDownMenu;
  end;

{ TCheckableButton }

constructor TCheckableButton.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csCaptureMouse];
end;

procedure TCheckableButton.AdjustWithControl(AControl: TControl);
var
  AAdjustment: Integer;
begin
  AAdjustment := AControl.BoundsRect.Right + 5 - Left;
  SetBounds(Left + AAdjustment, Top, Width - AAdjustment, Height);
end;

procedure TCheckableButton.SetDown(Value: Boolean);
begin
  if FDown <> Value then
  begin
    FDown := Value;
    Repaint;
    if FDown and (FDropDownMenu <> nil) then
      with ClientToScreen(Point(0, Height)) do
        FDropDownMenu.PopupEx(X, Y, 0, Height, True, nil);
  end;
end;

procedure TCheckableButton.SetDropDownMenu(Value: TdxBarPopupMenu);
begin
  if FDropDownMenu <> Value then
  begin
    FDropDownMenu := Value;
    FDropDownMenu.OnCloseup := DropDownMenuCloseup;
  end;
end;

procedure TCheckableButton.DropDownMenuCloseup(Sender: TObject);
var
  P: TPoint;
begin
  if FDown then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);
    LButtonDown := LeftButtonPressed and PtInRect(ClientRect, P);
    Down := False;
  end;
end;

procedure TCheckableButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TCheckableButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TCheckableButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if LButtonDown then
    LButtonDown := False
  else
    if Button = mbLeft then
      Down := True;
end;

procedure TCheckableButton.Paint;
const
  Borders: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
var
  R: TRect;
  P: TPoint;
begin
  with Canvas do
  begin
    R := ClientRect;
    GetCursorPos(P);
    P := ScreenToClient(P);
    if PtInRect(R, P) and GetParentForm(Self).Active or FDown then
      DrawEdge(Handle, R, Borders[FDown], BF_RECT);
    InflateRect(R, -1, -1);
    if FDown then OffsetRect(R, 1, 1);
    Brush.Style := bsClear;
    Font := Self.Font;
    Font.Color := clBtnText;
    cxDrawText(Handle, Caption, R, DT_CENTER or DT_NOCLIP or DT_SINGLELINE or DT_VCENTER);
    Brush.Style := bsSolid;
  end;
end;

{ TdxBarCustomizationFormPainter }

class function TdxBarCustomizationFormPainter.BrushColors(Selected: Boolean;
  AItem: TdxBarItem): TColor;
begin
  if Selected then
    Result := clHighlight
  else
    Result := clBtnFace;
end;

class function TdxBarCustomizationFormPainter.SideStripColor(
  Selected: Boolean; AItem: TdxBarItem): TColor;
begin
  Result := BrushColors(Selected, AItem);
end;

class procedure TdxBarCustomizationFormPainter.CalcButtonOrSubItemRects(
  AItem: TdxBarItem; const R: TRect; out ASideStripRect, ATextRect, AArrowRect: TRect);
begin
  ATextRect := R;
  AArrowRect := R;
  ASideStripRect := R;
  ASideStripRect.Right := ASideStripRect.Left + R.Bottom - R.Top;
  ATextRect.Left := ASideStripRect.Right + 1 + 4;
  if (AItem is TdxBarButton) and (TdxBarButton(AItem).ButtonStyle = bsDropDown) then
    Dec(ATextRect.Right, 4 + 9);
  AArrowRect.Left := ATextRect.Right;
end;

class procedure TdxBarCustomizationFormPainter.DrawButtonOrSubItem(ACanvas: TCanvas;
  ARect: TRect; AItem: TdxBarItem; ACaption: string; Selected: Boolean);
var
  ASideStripRect, ATextRect, AArrowRect: TRect;
begin
  CalcButtonOrSubItemRects(AItem, ARect, ASideStripRect, ATextRect, AArrowRect);
  DrawButtonOrSubItemBackground(ACanvas, AItem, ARect,
    ASideStripRect, AArrowRect, Selected);
  if GetIsGlyphItem(AItem) then
    DrawButtonOrSubItemGlyph(ACanvas, ASideStripRect, AItem, Selected);
  DrawButtonOrSubItemText(ACanvas, ATextRect, AItem, ACaption, Selected);
  if GetIsNeedDrawSubItemArrow(AItem) then
    DrawSubItemArrow(ACanvas, AArrowRect.Right - (4 + 5),
      AArrowRect.Top + (GetBarButtonHeight - 7) div 2, False);
end;

class procedure TdxBarCustomizationFormPainter.DrawButtonOrSubItemArrowBackground(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; Selected: Boolean);
begin
  if Selected then
  begin
    DrawEdge(ACanvas.Handle, R, BDR_RAISEDINNER, BF_RECT);
    InflateRect(R, -1, -1);
  end
  else
  begin
    Dec(R.Left);
    DrawEdge(ACanvas.Handle, R, EDGE_ETCHED, BF_LEFT);
    Inc(R.Left, 2);
  end;
  FillRectByColor(ACanvas.Handle, R, BrushColors(False, AItem));
end;

class procedure TdxBarCustomizationFormPainter.DrawButtonOrSubItemBackground(
  ACanvas: TCanvas; AItem: TdxBarItem;
  const ABounds, ASideStripRect, AArrowRect: TRect; ASelected: Boolean);
begin
  FillRectByColor(ACanvas.Handle, ABounds, BrushColors(ASelected, AItem));
  FillRectByColor(ACanvas.Handle, ASideStripRect, SideStripColor(
    ASelected and not GetIsGlyphItem(AItem), AItem));
  if (AItem is TdxBarButton) and (TdxBarButton(AItem).ButtonStyle = bsDropDown) then
    DrawButtonOrSubItemArrowBackground(ACanvas, AArrowRect, AItem, ASelected);
end;

class procedure TdxBarCustomizationFormPainter.DrawButtonOrSubItemGlyph(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; ASelected: Boolean);
begin
  if ASelected then
    DrawEdge(ACanvas.Handle, R, BDR_RAISEDINNER, BF_RECT);
  R := cxRectCenter(R, GetGlyphSize(AItem));
  TransparentDraw(ACanvas.Handle, 0, R, R, AItem.Glyph, AItem.GetCurImages,
    AItem.ImageIndex, AItem.BarManager.ImageListBkColor, True, False, False{Flat},
    ASelected, False, False, False{Shadow}, False{Faded},
    AItem.BarManager.ImageOptions.UseLeftBottomPixelAsTransparent);
end;

class procedure TdxBarCustomizationFormPainter.DrawButtonOrSubItemText(ACanvas: TCanvas;
  R: TRect; AItem: TdxBarItem; const ACaption: string; Selected: Boolean);
var
  AText: string;
begin
  ACanvas.Font.Color := FontColors(Selected);
  ACanvas.Brush.Style := bsClear;
  if (AItem is TCustomdxBarContainerItem) and
    TCustomdxBarContainerItemAccess(AItem).HideWhenRun
  then
    AText := '(' + ACaption + ')'
  else
    AText := ACaption;
  cxDrawText(ACanvas.Handle, AText, R, dxBarDefaultTextFlags);
end;

class procedure TdxBarCustomizationFormPainter.DrawCheckBox(ACanvas: TCanvas;
  R: TRect; AChecked, AEnabled: Boolean);
const
  CheckState: array[Boolean] of Integer = (0, DFCS_CHECKED);
  EnabledState: array[Boolean] of Integer = (DFCS_INACTIVE, 0);
begin
  InflateRect(R, -1, -1);
  DrawFrameControl(ACanvas.Handle, R, DFC_BUTTON,
    DFCS_BUTTONCHECK or CheckState[AChecked] or EnabledState[AEnabled]);
end;

class procedure TdxBarCustomizationFormPainter.DrawComboBoxButton(
  ACanvas: TCanvas; AItem: TdxBarItem; ARect: TRect; ASelected: Boolean);
begin
  with ACanvas do
  begin
    Inc(ARect.Left);
    if ASelected then
    begin
      DrawEdge(Handle, ARect, BDR_RAISEDINNER, BF_RECT);
      Pen.Color := BrushColors(False, AItem);
    end
    else
    begin
      Brush.Color := clBtnHighlight;
      FrameRect(ARect);
      Pen.Color := Brush.Color;
    end;
    MoveTo(ARect.Left - 1, ARect.Top);
    LineTo(ARect.Left - 1, ARect.Bottom);
    InflateRect(ARect, -1, -1);
    Brush.Color := BrushColors(False, AItem);
    FillRect(ARect);
    Pen.Color := clBtnText;
    InflateRect(ARect, 2, 0);
    DrawItemArrow(Handle, ARect, adDown, True, False, False{Flat});
  end;
end;

class procedure TdxBarCustomizationFormPainter.DrawEdit(ACanvas: TCanvas;
  ARect: TRect; AItem: TdxCustomBarEdit; Selected, ADrawArrowButton: Boolean);
begin
  DrawCaption(ACanvas, ARect, AItem, Selected);
  DrawEditEdge(ACanvas, ARect, AItem, Selected);
  DrawEditContent(ACanvas, ARect, AItem, Selected, ADrawArrowButton);
end;

class procedure TdxBarCustomizationFormPainter.DrawFocusedRect(ACanvas: TCanvas;
  ARect: TRect; AItem: TdxBarItem);
begin
  SetTextColor(ACanvas.Handle, ColorToRGB(FontColors(True)));
  SetBkColor(ACanvas.Handle, ColorToRGB(BrushColors(True, AItem)));
  Windows.DrawFocusRect(ACanvas.Handle, ARect);
end;

class procedure TdxBarCustomizationFormPainter.DrawCaption(ACanvas: TCanvas;
  var AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
var
  ATextRect: TRect;
  AText: string;
begin
  AText := GetTextOf(AItem.Caption);
  ATextRect := AItemRect;
  ATextRect.Right := ATextRect.Left + ACanvas.TextWidth(AText);
  InternalDrawCaption(ACanvas, ATextRect, AText, AItem, ASelected);
  AItemRect.Left := ATextRect.Right;
end;

class procedure TdxBarCustomizationFormPainter.DrawEditEdge(ACanvas: TCanvas;
  var AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
begin
  if ASelected then
    DrawEdge(ACanvas.Handle, AItemRect, BDR_SUNKENOUTER, BF_RECT)
  else
    ACanvas.FrameRect(AItemRect);
  InflateRect(AItemRect, -1, -1);
  ACanvas.FrameRect(AItemRect);
  InflateRect(AItemRect, -1, -1);
end;

class procedure TdxBarCustomizationFormPainter.DrawEditContent(ACanvas: TCanvas;
  AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected, ADrawArrowButton: Boolean);
begin
  if ADrawArrowButton then
  begin
    Dec(AItemRect.Right, GetComboBoxButtonWidth);
    DrawComboBoxButton(ACanvas, AItem,
      Rect(AItemRect.Right, AItemRect.Top, AItemRect.Right + GetComboBoxButtonWidth,
      AItemRect.Bottom), ASelected);
  end;
  InternalDrawEditContent(ACanvas, AItemRect, AItem, ASelected);
end;

class procedure TdxBarCustomizationFormPainter.DrawSubItemArrow(ACanvas: TCanvas;
  X, Y: Integer; ASelected: Boolean);
begin
  with ACanvas do
  begin
    if ASelected and IsHighContrastWhite then
      Pen.Color := clWhite
    else
      Pen.Color := Font.Color;
    Brush.Color := Pen.Color;
    Polygon([Point(X, Y), Point(X, Y + 6), Point(X + 3, Y + 3)]);
  end;
end;

class procedure TdxBarCustomizationFormPainter.InternalDrawCaption(ACanvas: TCanvas;
  var ATextRect: TRect; const AText: string; AItem: TdxCustomBarEdit; ASelected: Boolean);
const
  TextOffset = 2;
var
  ARect: TRect;
begin
  ARect := ATextRect;

  ACanvas.Brush.Color := BrushColors(ASelected, AItem);
  Inc(ARect.Right, TextOffset + 5);
  ACanvas.FillRect(ARect);

  Inc(ARect.Left, TextOffset);
  ACanvas.Font.Color := FontColors(ASelected);
  cxDrawText(ACanvas.Handle, AText, ARect, dxBarDefaultTextFlags);

  ATextRect.Right := ARect.Right;
end;

class procedure TdxBarCustomizationFormPainter.InternalDrawEditContent(ACanvas: TCanvas;
  AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
begin
  ACanvas.Font.Color := FontColors(False);
  TdxCustomBarEditAccess(AItem).DrawCustomizingImageContent(ACanvas, AItemRect, ASelected);
end;

class function TdxBarCustomizationFormPainter.FontColors(Selected: Boolean): TColor;
begin
  if Selected then
    Result := clHighlightText
  else
    Result := clBtnText;
end;

class function TdxBarCustomizationFormPainter.GetButtonColor(
  AItem: TdxBarItem; ASelected: Boolean): Integer;
begin
  Result := clBtnFace;
end;

class function TdxBarCustomizationFormPainter.GetBarButtonHeight: Integer;
begin
  Result := dxBarButtonHeight;
end;

class function TdxBarCustomizationFormPainter.GetComboBoxButtonWidth: Integer;
begin
  Result := dxBarComboBoxArrowWidth + 1;
end;

class function TdxBarCustomizationFormPainter.GetGlyphSize(AItem: TdxBarItem): TSize;
begin
  if AItem.Glyph.Empty then
    with AItem.GetCurImages do
      Result := cxSize(Width, Height)
  else
    with AItem.Glyph do
      Result := cxSize(Width, Height);
end;

class function TdxBarCustomizationFormPainter.GetIsGlyphItem(AItem: TdxBarItem): Boolean;
begin
  with TdxBarItemAccess(AItem) do
    Result := not Glyph.Empty or CurImageIndexLinked;
end;

class function TdxBarCustomizationFormPainter.GetIsNeedDrawSubItemArrow(AItem: TdxBarItem): Boolean;
begin
  Result :=
    (AItem is TdxBarButton) and (TdxBarButton(AItem).ButtonStyle = bsDropDown) or
    (AItem is TCustomdxBarSubItem) and not (AItem is TCustomdxBarContainerItem) or
    (AItem is TCustomdxBarContainerItem) and not TCustomdxBarContainerItemAccess(AItem).HideWhenRun;
end;

{ TdxBarCustomizationFormStandardPainter }

class procedure TdxBarCustomizationFormStandardPainter.DrawFocusedRect(ACanvas: TCanvas;
  ARect: TRect; AItem: TdxBarItem);
begin
  InflateRect(ARect, -2, -2);
  inherited DrawFocusedRect(ACanvas, ARect, AItem);
end;

{ TdxBarCustomizationFormFlatPainter }

class function TdxBarCustomizationFormFlatPainter.BrushColors(
  Selected: Boolean; AItem: TdxBarItem): TColor;
begin
  if Selected then
    Result := TdxBarManagerAccess(AItem.BarManager).FlatToolbarsSelColor
  else
    Result := clWindow;
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawButtonOrSubItem(
  ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem; ACaption: string;
  Selected: Boolean);
begin
  inherited DrawButtonOrSubItem(ACanvas, ARect, AItem, ACaption, Selected);
  if Selected then
    FrameFlatSelRect(ACanvas.Handle, ARect);
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawButtonOrSubItemArrowBackground(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; Selected: Boolean);
begin
  FillRectByColor(ACanvas.Handle, R, BrushColors(Selected, AItem));
  if Selected then
    FrameFlatSelRect(ACanvas.Handle, R)
  else
    Windows.FrameRect(ACanvas.Handle, R, GetSysColorBrush(COLOR_BTNSHADOW));
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawButtonOrSubItemGlyph(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; ASelected: Boolean);
begin
  ACanvas.Brush.Color := SideStripColor(ASelected, AItem);
  R := cxRectCenter(R, GetGlyphSize(AItem));
  TransparentDraw(ACanvas.Handle, ACanvas.Brush.Handle, R, R, AItem.Glyph,
    AItem.GetCurImages, AItem.ImageIndex, AItem.BarManager.ImageListBkColor,
    True, False, True{Flat}, ASelected, False, False, True{Shadow}, False{Faded},
    AItem.BarManager.ImageOptions.UseLeftBottomPixelAsTransparent);
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawComboBoxButton(
  ACanvas: TCanvas; AItem: TdxBarItem; ARect: TRect; ASelected: Boolean);
begin
  with ACanvas do
  begin
    Inc(ARect.Left);
    if ASelected then
    begin
      InflateRect(ARect, 1, 1);
      FrameFlatSelRect(Handle, ARect);
    end
    else
    begin
      Brush.Color := clBtnHighlight;
      FrameRect(ARect);
      Pen.Color := Brush.Color;
    end;
    if not ASelected then
    begin
      MoveTo(ARect.Left - 1, ARect.Top);
      LineTo(ARect.Left - 1, ARect.Bottom);
    end;
    InflateRect(ARect, -1, -1);
    if ASelected then
      Brush.Color := TdxBarManagerAccess(AItem.BarManager).FlatToolbarsSelColor
    else
      Brush.Color := BrushColors(False, AItem);
    FillRect(ARect);
    Pen.Color := clBtnText;
    if ASelected then
      InflateRect(ARect, -1, -1);
    InflateRect(ARect, 2, 0);
    DrawItemArrow(Handle, ARect, adDown, True, ASelected and IsHighContrastWhite, True{Flat});
  end;
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawFocusedRect(
  ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem);
begin
  // do nothing
end;

class function TdxBarCustomizationFormFlatPainter.FontColors(Selected: Boolean): TColor;
begin
  Result := clBtnText;
  if Selected and IsHighContrastWhite then
    Result := clBtnFace;
end;

class function TdxBarCustomizationFormFlatPainter.SideStripColor(
  Selected: Boolean; AItem: TdxBarItem): TColor;
begin
  Result := BrushColors(True, AItem);
end;

class procedure TdxBarCustomizationFormFlatPainter.DrawEditEdge(ACanvas: TCanvas;
  var AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
begin
  ACanvas.Brush.Color := BrushColors(False, AItem);
  if ASelected then
    FrameFlatSelRect(ACanvas.Handle, AItemRect)
  else
    Windows.FrameRect(ACanvas.Handle, AItemRect, GetSysColorBrush(COLOR_BTNSHADOW));
  InflateRect(AItemRect, -1, -1);
end;

class procedure TdxBarCustomizationFormFlatPainter.InternalDrawCaption(ACanvas: TCanvas;
  var ATextRect: TRect; const AText: string; AItem: TdxCustomBarEdit; ASelected: Boolean);
const
  ATextOffset = 5;
var
  ARect: TRect;
begin
  ARect := ATextRect;

  ACanvas.Brush.Color := BrushColors(ASelected, AItem);
  Inc(ARect.Right, 1 + ATextOffset + 5);
  ACanvas.FillRect(ARect);
  if ASelected then
  begin
    Inc(ARect.Right);
    FrameFlatSelRect(ACanvas.Handle, ARect);
    Dec(ARect.Right);
  end;

  Inc(ARect.Left, ATextOffset);
  ACanvas.Font.Color := FontColors(ASelected);
  cxDrawText(ACanvas.Handle, AText, ARect, dxBarDefaultTextFlags);

  ATextRect.Right := ARect.Right;
end;

{ TdxBarCustomizationFormOffice11Painter }

class function TdxBarCustomizationFormOffice11Painter.BrushColors(
  Selected: Boolean; AItem: TdxBarItem): TColor;
begin
  if Selected then
    Result := dxOffice11ToolbarSelectedColor
  else
    Result := dxOffice11MenuColor;
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawButtonOrSubItem(
  ACanvas: TCanvas; ARect: TRect; AItem: TdxBarItem; ACaption: string; Selected: Boolean);
begin
  inherited DrawButtonOrSubItem(ACanvas, ARect, AItem, ACaption, Selected);
  if Selected then
    Office11FrameSelectedRect(ACanvas.Handle, ARect);
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawButtonOrSubItemArrowBackground(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; Selected: Boolean);
begin
  if Selected then
    Office11FrameSelectedRect(ACanvas.Handle, R)
  else
    Windows.FrameRect(ACanvas.Handle, R, dxOffice11BarSeparatorBrush1);
  InflateRect(R, -1, -1);
  ACanvas.Brush.Color := BrushColors(Selected, AItem);
  ACanvas.FillRect(R);
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawButtonOrSubItemGlyph(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; ASelected: Boolean);
begin
  R := cxRectCenter(R, GetGlyphSize(AItem));
  TransparentDraw(ACanvas.Handle, 0, R, R, AItem.Glyph, AItem.GetCurImages,
    AItem.ImageIndex, AItem.BarManager.ImageListBkColor, True, False, False{Flat},
    ASelected, False, False, False{Shadow}, False{Faded},
    AItem.BarManager.ImageOptions.UseLeftBottomPixelAsTransparent);
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawButtonOrSubItemBackground(
  ACanvas: TCanvas; AItem: TdxBarItem; const ABounds, ASideStripRect, AArrowRect: TRect;
  ASelected: Boolean); 
begin
  ACanvas.Brush.Color := BrushColors(ASelected, AItem);
  ACanvas.FillRect(ABounds);
  if not ASelected then
    FillTubeGradientRect(ACanvas.Handle, ASideStripRect,
      dxOffice11MenuIndentColor1, dxOffice11MenuIndentColor2, True);
  if (AItem is TdxBarButton) and (TdxBarButton(AItem).ButtonStyle = bsDropDown) then
    DrawButtonOrSubItemArrowBackground(ACanvas, AArrowRect, AItem, ASelected);
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawComboBoxButton(
  ACanvas: TCanvas; AItem: TdxBarItem; ARect: TRect; ASelected: Boolean);
begin
  with ACanvas do
  begin
    Inc(ARect.Left);
    if ASelected then
    begin
      InflateRect(ARect, 1, 1);
      Office11FrameSelectedRect(Handle, ARect);
    end
    else
    begin
      Brush.Color := clWindow;
      FrameRect(ARect);
      Pen.Color := Brush.Color;
    end;
    if not ASelected then
    begin
      MoveTo(ARect.Left - 1, ARect.Top);
      LineTo(ARect.Left - 1, ARect.Bottom);
    end;
    InflateRect(ARect, -1, -1);
    if ASelected then
      Brush.Color := dxOffice11ToolbarSelectedColor
    else
      Brush.Color := dxOffice11OwnerControlDownedColor;
    FillRect(ARect);
    Pen.Color := clBtnText;
    if ASelected then
      InflateRect(ARect, -1, -1);
    InflateRect(ARect, 2, 0);
    DrawItemArrow(Handle, ARect, adDown, True, ASelected and IsHighContrastWhite, True{Flat});
  end;
end;

class function TdxBarCustomizationFormOffice11Painter.FontColors(
  Selected: Boolean): TColor;
begin
  Result := dxOffice11TextEnabledColor;
  if Selected and IsHighContrastWhite then
    Result := clBtnFace;
end;

class function TdxBarCustomizationFormOffice11Painter.GetButtonColor(
  AItem: TdxBarItem; ASelected: Boolean): Integer;
begin
  Result := dxOffice11OwnerControlDownedColor;
end;

class procedure TdxBarCustomizationFormOffice11Painter.DrawEditEdge(ACanvas: TCanvas;
  var AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
begin
  ACanvas.Brush.Color := BrushColors(False, AItem);
  if ASelected then
    Office11FrameSelectedRect(ACanvas.Handle, AItemRect)
  else
    Windows.FrameRect(ACanvas.Handle, AItemRect, dxOffice11OwnerControlDownedBrush);
  InflateRect(AItemRect, -1, -1);
end;

class procedure TdxBarCustomizationFormOffice11Painter.InternalDrawCaption(
  ACanvas: TCanvas; var ATextRect: TRect; const AText: string;
  AItem: TdxCustomBarEdit; ASelected: Boolean);
const
  TextOffset = 5;
var
  AIndent: Integer;
  ARect: TRect;
begin
  ARect := ATextRect;
  AIndent := TextOffset + cxRectHeight(ARect);

  Inc(ARect.Right, 1 + 5 + AIndent);
  ACanvas.Brush.Color := BrushColors(ASelected, AItem);
  ACanvas.FillRect(ARect);
  if not ASelected then
    FillTubeGradientRect(ACanvas.Handle,
      cxRectSetWidth(ARect, cxRectHeight(ARect)),
      dxOffice11MenuIndentColor1, dxOffice11MenuIndentColor2, True)
  else
  begin
    Inc(ARect.Right);
    Office11FrameSelectedRect(ACanvas.Handle, ARect);
    Dec(ARect.Right);
  end;
  Inc(ARect.Left, AIndent);
  ACanvas.Font.Color := FontColors(ASelected);
  cxDrawText(ACanvas.Handle, AText, ARect, dxBarDefaultTextFlags);
  ATextRect.Right := ARect.Right;
end;

{ TdxBarCustomizationFormXPPainter }

class procedure TdxBarCustomizationFormXPPainter.DrawButtonOrSubItemArrowBackground(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; Selected: Boolean);
begin
  ACanvas.Brush.Color := BrushColors(False, AItem);
  ACanvas.FillRect(R);
  DrawThemeBackground(OpenTheme(totToolBar), ACanvas.Handle, TP_BUTTON, TS_HOT, @R);
end;

class procedure TdxBarCustomizationFormXPPainter.DrawButtonOrSubItemGlyph(
  ACanvas: TCanvas; R: TRect; AItem: TdxBarItem; ASelected: Boolean);
begin
  if ASelected and (AItem is TdxBarButton) then
    DrawThemeBackground(OpenTheme(totToolBar), ACanvas.Handle, TP_BUTTON, TS_HOT, @R);
  R := cxRectCenter(R, GetGlyphSize(AItem));
  TransparentDraw(ACanvas.Handle, 0, R, R, AItem.Glyph, AItem.GetCurImages,
    AItem.ImageIndex, AItem.BarManager.ImageListBkColor, True, False, False{Flat},
    ASelected, False, False, False{Shadow}, False{Faded},
    AItem.BarManager.ImageOptions.UseLeftBottomPixelAsTransparent);
end;

class procedure TdxBarCustomizationFormXPPainter.DrawComboBoxButton(
  ACanvas: TCanvas; AItem: TdxBarItem; ARect: TRect; ASelected: Boolean);
begin
  DrawThemeBackground(OpenTheme(totComboBox), ACanvas.Handle,
    CP_DROPDOWNBUTTON, CBXS_NORMAL, @ARect);
end;

class procedure TdxBarCustomizationFormXPPainter.DrawFocusedRect(ACanvas: TCanvas;
  ARect: TRect; AItem: TdxBarItem);
var
  IsGlyph: Boolean;
begin
  with TdxBarItemAccess(AItem) do
    IsGlyph := not (AItem is TdxBarEdit) and (not Glyph.Empty or CurImageIndexLinked);
  if IsGlyph then
    Inc(ARect.Left, cxRectHeight(ARect) + 1);
  inherited DrawFocusedRect(ACanvas, ARect, AItem);
end;

class function TdxBarCustomizationFormXPPainter.GetComboBoxButtonWidth: Integer;
begin
  Result := dxBarComboBoxArrowWidth + 2;
end;

class procedure TdxBarCustomizationFormXPPainter.DrawEditEdge(ACanvas: TCanvas;
  var AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
begin
  ACanvas.FrameRect(AItemRect);
  InflateRect(AItemRect, -1, -1);
end;

class procedure TdxBarCustomizationFormXPPainter.InternalDrawEditContent(
  ACanvas: TCanvas; AItemRect: TRect; AItem: TdxCustomBarEdit; ASelected: Boolean);
var
  AClipRgn: HRGN;
  AClipRgnExists: Boolean;
begin
  InflateRect(AItemRect, -1, -1);
  inherited InternalDrawEditContent(ACanvas, AItemRect, AItem, ASelected);

  SaveClipRgn(ACanvas.Handle, AClipRgn, AClipRgnExists);
  with AItemRect do
    ExcludeClipRect(ACanvas.Handle, Left, Top, Right, Bottom);
  InflateRect(AItemRect, 1, 1);
  DrawThemeBackground(OpenTheme(totEdit), ACanvas.Handle, EP_EDITTEXT, ETS_NORMAL, AItemRect);
  RestoreClipRgn(ACanvas.Handle, AClipRgn, AClipRgnExists);
end;

{ TdxBarCustomCustomizationForm }

constructor TdxBarCustomCustomizationForm.CreateEx(ABarManager: TdxBarManager);

  procedure PrepareBarManager;
  var
    ARunTimeSelectionController: TdxBarRunTimeSelectionController;
  begin
    BarManager1.Font := BarManager.Font;
    if not BarManager.Designing then
    begin
      ARunTimeSelectionController := TdxBarRunTimeSelectionController.Create;
      ARunTimeSelectionController.OnSelectionChanged := DesignSelectionChanged;
      TdxBarManagerAccess(BarManager).FdxBarDesignHelper := ARunTimeSelectionController;
      if BarManager.Bars.Count > 0 then
        SynchronizeDesigner(BarManager.Bars[0]);
    end;
    FBarsOldChangeEvent := BarManager.Bars.OnChange;
    BarManager.Bars.OnChange := BarsChange;
    FItemsOldChangeEvent := TdxBarManagerAccess(BarManager).ItemList.OnComponentListChanged;
    TdxBarManagerAccess(BarManager).ItemList.OnComponentListChanged := ItemsChange;
  end;

  procedure PrepareLocalizations;
  begin
    Caption := cxGetResourceString(@dxSBAR_CAPTION);
    aNewToolBar.Caption := cxGetResourceString(@dxSBAR_TNEW);
    aRenameToolBar.Caption := cxGetResourceString(@dxSBAR_TRENAME);
    aDeleteToolBar.Caption := cxGetResourceString(@dxSBAR_TDELETE);
    aResetToolBar.Caption := cxGetResourceString(@dxSBAR_TRESET);

    CategoriesAdd.Caption := cxGetResourceString(@dxSBAR_ADDEX);
    CategoriesInsert.Caption := cxGetResourceString(@dxSBAR_INSERTEX);
    CategoriesRename.Caption := cxGetResourceString(@dxSBAR_RENAMEEX);
    CategoriesVisible.Caption := cxGetResourceString(@dxSBAR_VISIBLE);
    CategoriesDelete.Caption := cxGetResourceString(@dxSBAR_DELETE);

    CommandsAdd.Caption := cxGetResourceString(@dxSBAR_ADDEX);
    CommandsDelete.Caption := cxGetResourceString(@dxSBAR_DELETE);
    CommandsClear.Caption := cxGetResourceString(@dxSBAR_CLEAR);
    CommandsMoveUp.Caption := cxGetResourceString(@dxSBAR_MOVEUP);
    CommandsMoveDown.Caption := cxGetResourceString(@dxSBAR_MOVEDOWN);
    CommandsSubMenuEditor.Caption := cxGetResourceString(@dxSBAR_SUBMENUEDITOR);
  end;

begin
  BarManager := ABarManager;
  inherited Create(nil);
{$IFDEF DELPHI9}
  PopupMode := pmAuto;
{$ENDIF}
  FBarListBoxHelper := TdxBarCustomizationFormBarListHelper.Create(Self, BarListBox);
  FCategoryListBoxHelper := TdxBarCustomizationFormCategoryListHelper.Create(Self, CategoriesList);
  FItemsListBoxHelper := TdxBarCustomizationFormItemsListHelper.Create(Self, ItemsListBox); 
  PrepareCustomizationFormFont(Self, BarManager);
  OnClose := FormCloseEvent;
  OnDestroy := FormDestroyEvent;
  OnShow := FormShowEvent;
  OnHide := FormHideEvent;
  FSelectionList := CreateSelectionList;
  Constraints.MinHeight := Height;
  PrepareLocalizations;
  PrepareBarManager;
  PrepareControls;
  BarManagerStyleChanged;
end;

destructor TdxBarCustomCustomizationForm.Destroy;
begin
  FreeAndNil(FBarListBoxHelper);
  FreeAndNil(FCategoryListBoxHelper);
  FreeAndNil(FItemsListBoxHelper);
  if not BarManager.Designing then
    TdxBarManagerAccess(BarManager).FdxBarDesignHelper := nil;
  inherited Destroy;
end;

procedure TdxBarCustomCustomizationForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := WS_POPUP or WS_CLIPSIBLINGS or WS_SYSMENU or WS_CAPTION or WS_THICKFRAME;
  Params.ExStyle := WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE;
  Params.WindowClass.Style := CS_OWNDC or CS_SAVEBITS;
  Params.WndParent := BarManager.Owner.Handle;
end;

{$IFDEF DELPHI9}
procedure TdxBarCustomCustomizationForm.DestroyWindowHandle;
begin
  EnableWindows(True);
  inherited;
end;
{$ENDIF}

procedure TdxBarCustomCustomizationForm.DoShowHelp;
begin
  if not BarManager.Designing then
  begin
    TdxBarManagerAccess(BarManager).DoHelpButtonClick;
    if BarManager.HelpContext <> 0 then
      Application.HelpContext(BarManager.HelpContext);
  end;
end;

procedure TdxBarCustomCustomizationForm.BarManagerStyleChanged;
begin
  UpdateOptions;
  SynchronizeListBoxes;
  BarManager1.Style := BarManager.Style;
  BarManager1.LookAndFeel := BarManager.LookAndFeel;
  BarListBox.Color := EditBackgroundColor;
  BarListBox.Font.Color := EditTextColor;
  CategoriesList.Color := EditBackgroundColor;
  CategoriesList.Font.Color := EditTextColor;
  ItemsListBox.Color := BarItemsBackgroundColor;
end;

procedure TdxBarCustomCustomizationForm.MouseWheelHandler(var Message: TMessage);
var
  AControl: TWinControl;
  H: HWND;
  I, AScrollCode, AScrollLines: Integer;
  P: TPoint;
  R: TRect;
begin
  P := SmallPointToPoint(TWMMouseWheel(Message).Pos);
  H := WindowFromPoint(P);
  if H <> 0 then
  begin
    R := cxGetWindowRect(H);
    AControl := FindControl(H);
    if (AControl is TCustomListBox) and PtInRect(R, P) and
      not (ActiveControl is TCustomListBox) then
    begin
      if SmallInt(HIWORD(Message.wParam)) > 0 then
        AScrollCode := SB_LINEUP
      else
        AScrollCode := SB_LINEDOWN;
      AScrollLines := {$IFDEF DELPHI4}Mouse.WheelScrollLines{$ELSE}3{$ENDIF};
      for I := 0 to AScrollLines - 1 do
        SendMessage(AControl.Handle, WM_VSCROLL, AScrollCode, 0);
      Exit;
    end;
  end;
  inherited MouseWheelHandler(Message);
end;

function TdxBarCustomCustomizationForm.GetBarList(Index: Integer): TdxBar;
begin
  Result := TdxBar(GetObjectFromListBox(BarListBox, Index));
end;

procedure TdxBarCustomCustomizationForm.BarListToggleCheck(AIndex: Integer);
begin
  if Assigned(BarList[AIndex]) then
  begin
    if TdxBarAccess(BarList[AIndex]).CanClose then
      BarList[AIndex].Visible := not BarList[AIndex].Visible
    else
      MessageBeep(MB_OK);
  end;
end;

function TdxBarCustomCustomizationForm.GetIsLookAndFeelUsed: Boolean;
begin
  Result := BarManager1.Style = bmsUseLookAndFeel;
end;

function TdxBarCustomCustomizationForm.GetLookAndFeelPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := BarManager.LookAndFeel.Painter;
end;

function TdxBarCustomCustomizationForm.GetSelectedBar: TdxBar;
begin
  Result := TdxBar(GetExclusiveObject(BarListBox));
end;

procedure TdxBarCustomCustomizationForm.FormCloseEvent(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TdxBarCustomCustomizationForm.FormDestroyEvent(Sender: TObject);
begin
  FdxBarCustomizingForm := nil; //#DG
  RestoreOldEvents;
  if not FCloseCustomizingFormFlag then
  begin
    FCloseCustomizingFormFlag := True;
    BarManager.Customizing(False);
    FCloseCustomizingFormFlag := False;
  end;
  FreeSelectionList;
end;

procedure TdxBarCustomCustomizationForm.FormHideEvent(Sender: TObject);
begin
  EnableWindows(True);
end;

procedure TdxBarCustomCustomizationForm.FormShowEvent(Sender: TObject);
begin
  EnableWindows(False);
end;

procedure TdxBarCustomCustomizationForm.WMDeferredCallSynchronizationListBox(var Message: TMessage);
begin
  KillMessages(0, dxWM_LB_DEFERREDCALLSYNCHRONIZATION, dxWM_LB_DEFERREDCALLSYNCHRONIZATION, True);
  SynchronizeListBox(TListBox(Message.WParam));
end;

function TdxBarCustomCustomizationForm.CanDeleteBar(ABar: TComponent): Boolean;
var
  ASelectableItem: IdxBarSelectableItem;
begin
  Result := IsSelectableItem(ABar, ASelectableItem) and ASelectableItem.CanDelete;
end;

function TdxBarCustomCustomizationForm.CreateSelectionList: TcxComponentList;
begin
  Result := TcxComponentList.Create;
  (BarManager as IdxBarDesigner).GetSelection(Result);
end;

procedure TdxBarCustomCustomizationForm.EnableWindows(AEnable: Boolean);
var
  ADisabledParent: TWinControl;
  I: Integer;
begin
  if AEnable then
  begin
    for I := 0 to dxBarManagerList.Count - 1 do
      TdxBarManagerAccess(dxBarManagerList[I]).EnableFloatToolBars;
    cxContainer.EnableWindows(FDisabledWindows);
    FreeAndNil(FDisabledWindows);
  end
  else
  begin
    FDisabledWindows := TList.Create;
    for I := 0 to dxBarManagerList.Count - 1 do
      if GetDisableParent(dxBarManagerList[I], ADisabledParent) then
      begin
        if dxBarManagerList[I] <> BarManager then
          TdxBarManagerAccess(dxBarManagerList[I]).DisableFloatToolBars;
        DisableWindow(FDisabledWindows, ADisabledParent.Handle);
      end;
  end;
end;

procedure TdxBarCustomCustomizationForm.FreeSelectionList;
begin
  (BarManager as IdxBarDesigner).SetSelection(FSelectionList);
  FreeAndNil(FSelectionList);
end;

function TdxBarCustomCustomizationForm.IsBarPredefined(ABar: TdxBar): Boolean;
begin
  Result := not BarManager.Designing and ABar.IsPredefined;
end;

function TdxBarCustomCustomizationForm.GetDisableParent(
  ABarManager: TdxBarManager; out AParent: TWinControl): Boolean;
begin
{#DG - because can close master form}
  if ABarManager.Designing then
//#DG       ADisabledParent := ABarManager.Owner {#DG - because can close master form in D7}
    AParent := ABarManager.ParentForm
  else
    AParent := ABarManager.MasterForm;

  Result := (AParent <> Self) and (AParent <> nil) and AParent.HandleAllocated;
end;

function TdxBarCustomCustomizationForm.GetBarItemsBackgroundColor: TColor;
const
  ItemsColorMap: array[Boolean] of TColor = (clWindow, clBtnFace);
begin
  Result := ItemsColorMap[BarManager.GetPaintStyle <> bmsFlat];
end;

function TdxBarCustomCustomizationForm.GetEditBackgroundColor: TColor;
begin
  if IsLookAndFeelUsed then
    Result := LookAndFeelPainter.DefaultEditorBackgroundColor(False)
  else
    Result := clDefault;

  if Result = clDefault then
    Result := clWindow;
end;

function TdxBarCustomCustomizationForm.GetEditTextColor: TColor;
begin
  if IsLookAndFeelUsed then
    Result := LookAndFeelPainter.DefaultEditorTextColor(False)
  else
    Result := clDefault;

  if Result = clDefault then
    Result := clWindowText;
end;

function TdxBarCustomCustomizationForm.GetExclusiveObject(AListBox: TListBox): TObject;
var
  AIndex: Integer;
begin
  if AListBox.MultiSelect then
  begin
    if AListBox.SelCount = 1 then
      SendMessage(AListBox.Handle, LB_GETSELITEMS, 1, Integer(@AIndex))
    else
      AIndex := -1
  end
  else
    AIndex := AListBox.ItemIndex;

  Result := GetObjectFromListBox(AListBox, AIndex);
end;

function TdxBarCustomCustomizationForm.GetNextSelectedObject(AListBox: TListBox): TObject;
var
  I, ASelectedIndex: Integer;
begin
  ASelectedIndex := -1;
  for I := AListBox.ItemIndex + 1 to AListBox.Items.Count - 1 do
    if not AListBox.Selected[I] then
    begin
      ASelectedIndex := I;
      Break;
    end;

  if ASelectedIndex = -1 then
  begin
    for I := AListBox.ItemIndex - 1 downto 0 do
      if not AListBox.Selected[I] then
      begin
        ASelectedIndex := I;
        Break;
      end;
  end;
  
  Result := GetObjectFromListBox(AListBox, ASelectedIndex);
end;

function TdxBarCustomCustomizationForm.GetObjectFromListBox(
  AListBox: TListBox; AIndex: Integer): TObject;
begin
  if (AIndex >= 0) and (AIndex < AListBox.Items.Count) then
    Result := AListBox.Items.Objects[AIndex]
  else
    Result := nil;
end;

function TdxBarCustomCustomizationForm.GetPainterClass: TdxBarCustomizationFormPainterClass;
begin
  Result := TdxBarCustomizationFormStandardPainter;
  if BarManager.PainterClass = TdxBarXPPainter then
    Result := TdxBarCustomizationFormXPPainter;
  if BarManager.PainterClass = TdxBarOffice11Painter then
    Result := TdxBarCustomizationFormOffice11Painter;
  if BarManager.PainterClass = TdxBarFlatPainter then
    Result := TdxBarCustomizationFormFlatPainter;
end;

procedure TdxBarCustomCustomizationForm.GetSelection(AListBox: TListBox; AList: TList);
var
  I: Integer;
begin
  if Assigned(AListBox) then
  begin
    for I := 0 to AListBox.Items.Count - 1 do
      if AListBox.Selected[I] then
        AList.Add(AListBox.Items.Objects[I]);
  end;
end;

function TdxBarCustomCustomizationForm.PrepareMenuAnimationsComboBox(
  AComboBoxFont: TFont; AComboBoxStrings: TStrings): Integer;

  function CalcOptimalWidth(AComboBoxFont: TFont; AComboBoxStrings: TStrings): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to AComboBoxStrings.Count - 1 do
      Result := Max(Result, cxTextWidth(AComboBoxFont, AComboBoxStrings[I]));
    Inc(Result, 54);
  end;

begin
  AComboBoxStrings.BeginUpdate;
  try
    AComboBoxStrings.Clear;
    AComboBoxStrings.Add(cxGetResourceString(@dxSBAR_MENUANIM1));
    AComboBoxStrings.Add(cxGetResourceString(@dxSBAR_MENUANIM2));
    AComboBoxStrings.Add(cxGetResourceString(@dxSBAR_MENUANIM3));
    AComboBoxStrings.Add(cxGetResourceString(@dxSBAR_MENUANIM4));
    AComboBoxStrings.Add(cxGetResourceString(@dxSBAR_MENUANIM5));
  finally
    AComboBoxStrings.EndUpdate;
  end;
  Result := CalcOptimalWidth(AComboBoxFont, AComboBoxStrings);
end;

procedure TdxBarCustomCustomizationForm.PrepareControls;
begin
end;

procedure TdxBarCustomCustomizationForm.ReplaceByCheckableButton(
  const ACaption: string; ASource, AAdjustWithControl: TControl;
  APopupMenu: TdxBarPopupMenu);
var
  AButton: TCheckableButton;
begin
  if BarManager.Designing then
  begin
    AButton := TCheckableButton.Create(Self);
    AButton.Caption := ACaption;
    AButton.BoundsRect := ASource.BoundsRect;
    AButton.AdjustWithControl(AAdjustWithControl);
    AButton.DropDownMenu := APopupMenu;
    AButton.Parent := ASource.Parent;
  end;
  ASource.Free;
end;

procedure TdxBarCustomCustomizationForm.RestoreOldEvents;
begin
  BarManager.Bars.OnChange := FBarsOldChangeEvent;
  TdxBarManagerAccess(BarManager).ItemList.OnComponentListChanged := FItemsOldChangeEvent;
end;

procedure TdxBarCustomCustomizationForm.SelectBarManager;
begin
  if not TdxBarManagerAccess(BarManager).IsDestroying then
    (BarManager as IdxBarDesigner).SelectComponent(BarManager);
end;

procedure TdxBarCustomCustomizationForm.SetNewWindowProc(AControl: TControl;
  ANewWindowProc: TWndMethod; out AOldWindowProc: TWndMethod);
begin
  AOldWindowProc := AControl.WindowProc;
  AControl.WindowProc := ANewWindowProc;
end;

procedure TdxBarCustomCustomizationForm.ShowCategoryPopupMenu(const APoint: TPoint);
begin
  if BarManager.Designing then
    CategoriesPopupMenu.Popup(APoint.X, APoint.Y);
end;

procedure TdxBarCustomCustomizationForm.SynchronizeDesigner(AListBox: TListBox);
var
  ASelectedObjects: TObjectList;
begin
  FAlreadySynchronous := AListBox;
  try
    ASelectedObjects := TObjectList.Create(False);
    try
      GetSelection(AListBox, ASelectedObjects);
      if ASelectedObjects.Count > 0 then
        (BarManager as IdxBarDesigner).SetSelection(ASelectedObjects)
      else
        SelectBarManager;
    finally
      ASelectedObjects.Free;
    end;
  finally
    FAlreadySynchronous := nil;
  end;
end;

procedure TdxBarCustomCustomizationForm.UpdateCommonEvents(AListBox: TListBox;
  AAddAction, ADeleteAction, AMoveUpAction, AMoveDownAction: TAction;
  ADeletePermissiveProc: TdxBarPermissiveProc = nil);
var
  I: Integer;
  ASelectedObjects: TList;
  AMoveEnabled: Boolean;
begin
  ASelectedObjects := TList.Create;
  try
    GetSelection(AListBox, ASelectedObjects);

    if AAddAction <> nil then
      AAddAction.Enabled := TdxBarManagerAccess(BarManager).CanAddComponents;
      
    if ADeleteAction <> nil then
    begin
      ADeleteAction.Enabled := GetSelCount(AListBox) > 0;
      for I := 0 to ASelectedObjects.Count - 1 do
      begin
        ADeleteAction.Enabled := ADeleteAction.Enabled and
          (not Assigned(ADeletePermissiveProc) and IdxBarDesigner(BarManager).CanDeleteComponent(ASelectedObjects[I]) or
          Assigned(ADeletePermissiveProc) and ADeletePermissiveProc(ASelectedObjects[I]));
      end;
    end;

    if AMoveUpAction <> nil then
    begin
      AMoveEnabled := False;
      for I := 0 to ASelectedObjects.Count - 1 do
        if AListBox.Items.IndexOfObject(ASelectedObjects[I]) <> I then
        begin
          AMoveEnabled := True;
          Break;
        end;
      AMoveUpAction.Enabled := AMoveEnabled;
    end;

    if AMoveDownAction <> nil then
    begin
      AMoveEnabled := False;
      for I := 0 to ASelectedObjects.Count - 1 do
        if AListBox.Items.IndexOfObject(ASelectedObjects[I]) <>
          AListBox.Items.Count - ASelectedObjects.Count + I then
        begin
          AMoveEnabled := True;
          Break;
        end;
      AMoveDownAction.Enabled := AMoveEnabled;
    end;
  finally
    ASelectedObjects.Free;
  end;
end;

procedure TdxBarCustomCustomizationForm.UpdateItemDesciption(const AText: string);
begin
end;

procedure TdxBarCustomCustomizationForm.UpdateItemsListEvents;
begin
  aSubMenuEditor.Enabled := (SelectedItem is TdxBarSubItem) or (SelectedItem is TdxBarContainerItem);
  aClearItemList.Enabled := (ItemsListBox.Items.Count > 0) and CanDeleteSelectedCategoryCommands;
  UpdateCommonEvents(ItemsListBox, aAddItem, aDeleteItem, aMoveUpItem, aMoveDownItem);
  if SelectedItem = nil then
    UpdateItemDesciption('')
  else
    UpdateItemDesciption(SelectedItem.Description);
end;

procedure TdxBarCustomCustomizationForm.UpdateToolBarsEvents;
var
  ABar: TdxBar;
begin
  ABar := SelectedBar;
  aRenameToolBar.Enabled := (ABar <> nil) and not IsBarPredefined(ABar);
  aResetToolBar.Enabled := (ABar <> nil) and TdxBarAccess(ABar).CanReset;
  UpdateCommonEvents(BarListBoxHelper.ListBox, aNewToolBar, aDeleteToolBar, nil, nil, CanDeleteBar);
end;

procedure TdxBarCustomCustomizationForm.SynchronizeDesigner(ANewSelection: IdxBarSelectableItem);
begin
  if ANewSelection = nil then
    SelectBarManager
  else
    ANewSelection.SelectComponent;
end;

procedure TdxBarCustomCustomizationForm.UpdateVisibility(const AWindowPos: TWindowPos);
begin
  if AWindowPos.flags and SWP_SHOWWINDOW <> 0 then
    ShowWindow(Handle, SW_SHOW)
  else
    if AWindowPos.flags and SWP_HIDEWINDOW <> 0 then
      ShowWindow(Handle, SW_HIDE);
end;

procedure TdxBarCustomCustomizationForm.WMActivate(var Message: TMessage);
var
  AParentForm: TCustomForm;
begin
  inherited;

  if not (csDestroying in ComponentState) and not (bisFormActivating in TdxBarManagerAccess(BarManager).InternalState) then
  begin
    if BarManager.Designing then
      AParentForm := BarManager.ParentForm
    else
      AParentForm := BarManager.MasterForm;
    if //(Message.wParam <> WA_INACTIVE) and
      (HWND(Message.lParam) <> AParentForm.Handle) then
      SendMessage(AParentForm.Handle, Message.Msg, Message.wParam, Message.lParam);
    {#DG
    if (Message.wParam <> WA_INACTIVE) and not BarDesignController.IsCustomizedByPopup then
      PageControlChange(nil);
    }
  end;
end;

procedure TdxBarCustomCustomizationForm.WMNCHitTest(var Message: TMessage);
begin
  inherited;
  case Message.Result of
    HTLEFT, HTRIGHT:
      Message.Result := HTCLIENT;
    HTTOPLEFT, HTTOPRIGHT:
      Message.Result := HTTOP;
    HTBOTTOMLEFT, HTBOTTOMRIGHT:
      Message.Result := HTBOTTOM;
  end;
end;

procedure TdxBarCustomCustomizationForm.BarsChange(Sender: TObject;
  AItem: TcxComponentCollectionItem; AAction: TcxComponentCollectionNotification);
begin
  if Assigned(FBarsOldChangeEvent) then
    FBarsOldChangeEvent(Sender, AItem, AAction);
  SynchronizeListBox(BarListBoxHelper.ListBox, AItem, AAction);
end;

procedure TdxBarCustomCustomizationForm.DeleteSelectedObjects(
  AListBox: TListBox; ADeleteProc: TNotifyEvent = nil; ASynchronizeDesigner: Boolean = True);
var
  I: Integer;
  ASelectedObjects: TObjectList;
  ANextObject: TObject;
begin
  ANextObject := GetNextSelectedObject(AListBox);
  ASelectedObjects := TObjectList.Create(False);
  try
    GetSelection(AListBox, ASelectedObjects);
//#DG - it was attempt to resolve blinking  SetSelection(AListBox, ANextObject);
//#DG - to resolve blinking    SetSelection(AListBox, TObject(nil));
    AListBox.Items.BeginUpdate;
    try
      for I := ASelectedObjects.Count - 1 downto 0 do
        if not Assigned(ADeleteProc) then
          ASelectedObjects[I].Free
        else
          ADeleteProc(ASelectedObjects[I]);
    finally
      AListBox.Items.EndUpdate;
    end;
    SetSelection(AListBox, ANextObject); // must be after deleting, because deleting causes update of ListBox
    if ASynchronizeDesigner then
      SynchronizeDesigner(AListBox);
  finally
    ASelectedObjects.Free;
    TdxBarManagerAccess(BarManager).DesignerModified;
  end;
end;

function TdxBarCustomCustomizationForm.GetSelCount(AListBox: TListBox): Integer;
begin
  if AListBox.MultiSelect then
    Result := AListBox.SelCount
  else
    if AListBox.ItemIndex <> -1 then
      Result := 1
    else
      Result := 0;
end;

function TdxBarCustomCustomizationForm.GetVisibleItemsCount(AListBox: TListBox): Integer;
begin
  Result := AListBox.Height div AListBox.ItemHeight;
end;

procedure TdxBarCustomCustomizationForm.ItemsChange(Sender: TObject;
  AComponent: TComponent; AAction: TcxComponentCollectionNotification);
begin
  if Assigned(FItemsOldChangeEvent) then
    FItemsOldChangeEvent(Sender, AComponent, AAction);
  SynchronizeListBox(ItemsListBoxHelper.ListBox, AComponent, AAction);
end;

procedure TdxBarCustomCustomizationForm.MoveItems(AListBox: TListBox;
  ABarComponentList: TdxBarComponentList; ADirection: Integer);
const
  AMoveUp = -1;
  AMoveDown = 1;
var
  I, J, K: Integer;
  ASelectedItems: TList;
begin
  ASelectedItems := TList.Create;
  try
    GetSelection(AListBox, ASelectedItems);
    ABarComponentList.BeginUpdate;
    try
      K := 0;
      case ADirection of
      AMoveUp:
        for I := 0 to ASelectedItems.Count - 1 do
        begin
          J := ABarComponentList.IndexOf(ASelectedItems[I]);
          if I = 0 then
          begin
            K := J - 1;
            if K < 0 then
              K := 0;
            ABarComponentList.Move(J, K);
          end
          else
            ABarComponentList.Move(J, K + I);
        end;
      AMoveDown:
        for I := ASelectedItems.Count - 1 downto 0 do
        begin
          J := ABarComponentList.IndexOf(ASelectedItems[I]);
          if I = ASelectedItems.Count - 1 then
          begin
            K := J + 1;
            if K > ABarComponentList.Count - 1 then
              K := ABarComponentList.Count - 1;
            ABarComponentList.Move(J, K);
            Dec(K, ASelectedItems.Count - 1);
          end
          else
            ABarComponentList.Move(J, K + I);
        end;
      end;
    finally
      ABarComponentList.EndUpdate;
    end;
  finally
    ASelectedItems.Free;
  end;
  TdxBarManagerAccess(BarManager).DesignerModified;
end;

procedure TdxBarCustomCustomizationForm.SetSelection(AListBox: TListBox; AList: TList);
var
  I, AIndex: Integer;
begin
  AListBox.Items.BeginUpdate;
  try
    if AListBox.MultiSelect then
      for I := 0 to AListBox.Items.Count - 1 do
        AListBox.Selected[I] := AList.IndexOf(AListBox.Items.Objects[I]) <> -1
    else
    begin
      AIndex := -1;
      for I := 0 to AListBox.Items.Count - 1 do
        if AList.IndexOf(AListBox.Items.Objects[I]) <> -1 then
          AIndex := I;
      AListBox.ItemIndex := AIndex;
    end;
    UpdateTopIndex(AListBox);
  finally
    AListBox.Items.EndUpdate;
    if not AListBox.MultiSelect then
      SendMessage(AListBox.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TdxBarCustomCustomizationForm.SetSelection(AListBox: TListBox; AObject: TObject);
var
  ASelectedObjects: TList;
begin
  ASelectedObjects := TList.Create;
  try
    ASelectedObjects.Add(AObject);
    SetSelection(AListBox, ASelectedObjects);
  finally
    ASelectedObjects.Free;
  end;
end;

procedure TdxBarCustomCustomizationForm.DeferredCallSynchronizationListBox(AListBox: TListBox);
begin
  PostMessage(Handle, dxWM_LB_DEFERREDCALLSYNCHRONIZATION, Integer(AListBox), 0);
end;

procedure TdxBarCustomCustomizationForm.SynchronizeListBox(AListBox: TListBox;
  AChangedObject: TObject = nil; AAction: TcxComponentCollectionNotification = ccnChanged);
var
  AObjectIndex, APrevTopIndex: Integer;
  AIsSelected: Boolean;
begin
  if not TdxBarManagerAccess(BarManager).IsDestroying then
  begin
    AListBox.Items.BeginUpdate;
    try
      APrevTopIndex := AListBox.TopIndex;
      if (AAction = ccnChanged) and (AChangedObject <> nil) then
      begin
        AObjectIndex := AListBox.Items.IndexOfObject(AChangedObject);
        if AObjectIndex <> -1 then
        begin
          AIsSelected := AListBox.Selected[AObjectIndex];
          SendMessage(AListBox.Handle, dxWM_LB_SYNCHRONIZE, Integer(AChangedObject), AObjectIndex);
          if AListBox.MultiSelect then
            AListBox.Selected[AObjectIndex] := AIsSelected;
        end;
        SendMessage(AListBox.Handle, dxWM_LB_UPDATEEVENTS, 0, 0);
      end
      else
      begin
        AListBox.Items.Clear;
        SendMessage(AListBox.Handle, dxWM_LB_SYNCHRONIZE, 0, 0);
        SendMessage(AListBox.Handle, dxWM_LB_SYNCHRONIZESELECTION, 0, 0);
      end;
      AListBox.TopIndex := APrevTopIndex;
      UpdateTopIndex(AListBox);
    finally
      AListBox.Items.EndUpdate;
    end;
  end;
end;

procedure TdxBarCustomCustomizationForm.SynchronizeListBoxSelection(AListBox: TListBox);
var
  AList: TList;
begin
  if AlreadySynchronous <> AListBox then
  begin
    AList := TList.Create;
    try
      (BarManager as IdxBarDesigner).GetSelection(AList);
      SetSelection(AListBox, AList);
    finally
      AList.Free;
    end;
  end;
  SendMessage(AListBox.Handle, dxWM_LB_UPDATEEVENTS, 0, 0);
end;

procedure TdxBarCustomCustomizationForm.UpdateTopIndex(AListBox: TListBox);

  function GetAnchorIndex: Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to AListBox.Items.Count - 1 do
      if AListBox.Selected[I] then
      begin
        Result := I;
        Break;
      end;
  end;

var
  AAnchorIndex: Integer;
begin
  AAnchorIndex := GetAnchorIndex;
  if AAnchorIndex >= 0 then
  begin
    if AAnchorIndex < AListBox.TopIndex then
      AListBox.TopIndex := AAnchorIndex
    else
      if AAnchorIndex > (AListBox.TopIndex + GetVisibleItemsCount(AListBox) - 1) then
        AListBox.TopIndex := AAnchorIndex - (GetVisibleItemsCount(AListBox) - 1);
  end;
end;

{ TdxBarRuntimeSelectionController }

constructor TdxBarRunTimeSelectionController.Create;
begin
  inherited Create;
  FSelectionList := TcxComponentList.Create;
  FSelectionList.OnNotify := SelectionListNotify;
  FSelectionList.OnComponentListChanged := SelectionListChanged;
end;

destructor TdxBarRuntimeSelectionController.Destroy;
begin
  FreeAndNil(FSelectionList);
  inherited;
end;

function TdxBarRunTimeSelectionController.CanDeleteComponent(
  AComponent: TComponent): Boolean;
begin
  Result := True;
end;

procedure TdxBarRunTimeSelectionController.GetSelection(AList: TList);
var
  I: Integer;
begin
  for I := 0 to FSelectionList.Count - 1 do
    AList.Add(FSelectionList[I]);
end;

function TdxBarRunTimeSelectionController.GetSelectionStatus(
  AComponent: TPersistent): TdxBarSelectionStatus;
begin
  if IsComponentSelected(AComponent) then
    Result := ssActiveSelected
  else
    Result := ssUnselected;
end;

function TdxBarRunTimeSelectionController.IsComponentSelected(AComponent: TPersistent): Boolean;
begin
  Result := FSelectionList.IndexOf(TComponent(AComponent)) <> -1;
end;

procedure TdxBarRunTimeSelectionController.SelectComponent(
  AComponent: TPersistent; ASelectionOperation: TdxBarSelectionOperation = soExclusive);
begin
  case ASelectionOperation of
    soAdd, soExclusive:
      AddSelection(TComponent(AComponent));
  end;
end;

procedure TdxBarRunTimeSelectionController.SetSelection(AList: TList);
var
  I: Integer;
begin
  FSelectionList.BeginUpdate;
  try
    for I := 0 to AList.Count - 1 do
      AddSelection(AList[I]);
  finally
    FSelectionList.EndUpdate;
  end;
end;

procedure TdxBarRunTimeSelectionController.ShowDefaultEventHandler(AItem: TdxBarItem);
begin
  // do nothing
end;

function TdxBarRunTimeSelectionController.UniqueName(const BaseName: string): string;
begin
  Result := '';
end;

procedure TdxBarRunTimeSelectionController.AddSelection(AComponent: TComponent);
var
  I: Integer;
  ABaseClass: TComponentClass;
begin
  if FSelectionList.IndexOf(AComponent) = -1 then
  begin
    if AComponent is TdxBar then
      ABaseClass := TdxBar
    else
      ABaseClass := TdxBarItem;

    for I := FSelectionList.Count - 1 downto 0 do
      if FSelectionList[I].InheritsFrom(ABaseClass)  then
        FSelectionList.Delete(I);
    if AComponent <> nil then
      FSelectionList.Add(AComponent);
  end;
end;

procedure TdxBarRunTimeSelectionController.SelectionListNotify(Sender: TObject;
  AComponent: TComponent; AAction: TListNotification);
var
  ASelectableItem: IdxBarSelectableItem;
begin
  if IsSelectableItem(AComponent, ASelectableItem) then
    ASelectableItem.SelectionChanged;
end;

procedure TdxBarRunTimeSelectionController.SelectionListChanged(Sender: TObject;
  AComponent: TComponent; AAction: TcxComponentCollectionNotification);
begin
  if Assigned(OnSelectionChanged) then
    OnSelectionChanged(Self);
end;

{ TdxBarCustomizationFormListBoxHelper }

constructor TdxBarCustomizationFormListBoxHelper.Create(
  AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox);
begin
  FOwner := AOwner;
  FListBox := AListBox;
  FOldWndProc := ListBox.WindowProc;
  ListBox.WindowProc := WndProc;
end;

destructor TdxBarCustomizationFormListBoxHelper.Destroy;
begin
  ListBox.WindowProc := OldWndProc;
  inherited Destroy;
end;

function TdxBarCustomizationFormListBoxHelper.GetBarManager: TdxBarManager;
begin
  Result := Owner.BarManager;
end;

function TdxBarCustomizationFormListBoxHelper.GetPainterClass: TdxBarCustomizationFormPainterClass;
begin
  Result := Owner.PainterClass;
end;

procedure TdxBarCustomizationFormListBoxHelper.WndProc(var Message: TMessage);
begin
  FOldWndProc(Message);
end;

{ TdxBarCustomizationFormBarListHelper }

constructor TdxBarCustomizationFormBarListHelper.Create(
  AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox);
begin
  inherited Create(AOwner, AListBox);
  ListBox.OnClick := DoListClick;
  ListBox.OnDrawItem := DoListDrawItem;
  ListBox.OnMouseDown := DoListMouseDown;
  ListBox.OnKeyDown := DoListKeyDown;
  ListBox.ItemHeight := ListBox.Canvas.TextHeight('Zg') + 2;
  ListBox.MultiSelect := BarManager.Designing;
end;

function TdxBarCustomizationFormBarListHelper.IsCheckBoxArea(X, Y: Integer): Boolean;
var
  AIndex: Integer;
begin
  AIndex := ListBox.ItemAtPos(Point(X, Y), True);
  Result := (AIndex >= 0) and
    (X - ListBox.ItemRect(AIndex).Left < ListBox.ItemHeight);
end;

procedure TdxBarCustomizationFormBarListHelper.DoListClick(Sender: TObject);
begin
  Owner.SynchronizeDesigner(ListBox);
end;

procedure TdxBarCustomizationFormBarListHelper.DoListDrawItem(
  Control: TWinControl; Index: Integer; R: TRect; State: TOwnerDrawState);
var
  R1: TRect;
  AFlags: Integer;
begin
  if Owner.BarList[Index] = nil then //#DG ???
    Exit;
  R1 := R;
  R1.Right := R1.Left + cxRectHeight(R);
  ListBox.Canvas.FillRect(R);
  with TdxBarAccess(Owner.BarList[Index]) do
    PainterClass.DrawCheckBox(ListBox.Canvas, R1, Visible, CanClose);
  Inc(R.Left, cxRectHeight(R));
  if Index < ListBox.Items.Count then
  begin
    AFlags := ListBox.DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    if ListBox.UseRightToLeftAlignment then
      Dec(R.Right, 2)
    else
      Inc(R.Left, 2);
    cxDrawText(ListBox.Canvas.Handle, ListBox.Items[Index], R, AFlags);
  end;
end;

procedure TdxBarCustomizationFormBarListHelper.DoListMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if IsCheckBoxArea(X, Y) and (ssDouble in Shift) then
    Exit;
  if IsCheckBoxArea(X, Y) or (ssDouble in Shift) then
    Owner.BarListToggleCheck(ListBox.ItemAtPos(Point(X, Y), True));
end;

procedure TdxBarCustomizationFormBarListHelper.DoListKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_DELETE:
      Owner.aDeleteToolBar.Execute;
    VK_INSERT:
      Owner.aNewToolBar.Execute;
    VK_SPACE:
      Owner.BarListToggleCheck(ListBox.ItemIndex);
  end;
end;

procedure TdxBarCustomizationFormBarListHelper.WndProc(var Message: TMessage);

  procedure SynchronizeBarListBox(ABar: TdxBar; AIndex: Integer);
  var
    I: Integer;
  begin
    if Assigned(ABar) then
      ListBox.Items[AIndex] := ABar.Caption
    else
    begin
      ListBox.Clear;
      for I := 0 to BarManager.Bars.Count - 1 do
      begin
        ABar := BarManager.Bars[I];
        if BarManager.Designing or not ABar.Hidden then
          ListBox.Items.AddObject(ABar.Caption, ABar);
      end;
    end;
  end;

begin
  if Message.Msg = dxWM_LB_SYNCHRONIZE then
    SynchronizeBarListBox(TdxBar(Message.WParam), Message.LParam);
  if Message.Msg = dxWM_LB_SYNCHRONIZESELECTION then
    Owner.SynchronizeListBoxSelection(ListBox);
  if Message.Msg = dxWM_LB_UPDATEEVENTS then
    Owner.UpdateToolBarsEvents;
  inherited WndProc(Message);
end;

{ TdxBarCustomizationFormCategoryListHelper }

constructor TdxBarCustomizationFormCategoryListHelper.Create(
  AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox);
begin
  inherited Create(AOwner, AListBox);
  ListBox.OnClick := DoListBoxClick;
  ListBox.OnDragOver := DoListDragOver;
  ListBox.OnEndDrag := DoListEndDrag;
  ListBox.OnKeyDown := DoListKeyDown;
  ListBox.OnMouseDown := DoListMouseDown;
end;

procedure TdxBarCustomizationFormCategoryListHelper.DoListBoxClick(Sender: TObject);
begin
  Owner.SynchronizeListBox(Owner.ItemsListBox);
end;

procedure TdxBarCustomizationFormCategoryListHelper.DoListDragOver(
  Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  AItemIndex: Integer;
begin
  Accept := Source = Sender;
  if Accept then
  begin
    AItemIndex := ListBox.ItemAtPos(Point(X, Y), True);
    if AItemIndex > -1 then
    begin
      BarManager.Categories.Move(FDraggingCategoryIndex, AItemIndex);
      ListBox.Items.Move(FDraggingCategoryIndex, AItemIndex);
      ListBox.ItemIndex := AItemIndex;
      FDraggingCategoryIndex := AItemIndex;
    end;
  end;
end;

procedure TdxBarCustomizationFormCategoryListHelper.DoListEndDrag(
  Sender, Target: TObject; X, Y: Integer);
begin
  ListBox.DragMode := dmManual;
end;

procedure TdxBarCustomizationFormCategoryListHelper.DoListKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if BarManager.Designing and (Shift = [])then
    case Key of
      VK_INSERT:
        Owner.CategoriesInsertClick(nil);
      VK_DELETE:
        Owner.CategoriesDeleteClick(nil);
    end;
end;

procedure TdxBarCustomizationFormCategoryListHelper.DoListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ANewIndex: Integer;
begin
  case Button of
    mbLeft:
      if BarManager.Designing and (ListBox.ItemAtPos(Point(X, Y), True) > -1) then
      begin
        FDraggingCategoryIndex := ListBox.ItemIndex;
        ListBox.DragMode := dmAutomatic;
      end;

    mbRight:
      begin
        ListBox.SetFocus;
        ANewIndex := ListBox.ItemAtPos(Point(X, Y), True);
        if (ANewIndex <> -1) and (ANewIndex <> ListBox.ItemIndex) then
        begin
          ListBox.ItemIndex := ANewIndex;
          Owner.SynchronizeListBox(Owner.GetItemsListBox);
        end;
        Owner.ShowCategoryPopupMenu(ListBox.ClientToScreen(Point(X, Y)));
      end;
  end;
end;

procedure TdxBarCustomizationFormCategoryListHelper.WndProc(var Message: TMessage);

  procedure SynchronizeCategoryList;
  var
    I: Integer;
  begin
    for I := 0 to BarManager.Categories.Count - 1 do
      if BarManager.Designing or BarManager.CategoryVisible[I] then
        ListBox.Items.Add(BarManager.Categories[I]);
    if ListBox.Items.Count > 0 then
      ListBox.ItemIndex := 0;
  end;

begin
  if Message.Msg = dxWM_LB_SYNCHRONIZE then
    SynchronizeCategoryList;
  inherited WndProc(Message);
end;

{ TdxBarCustomizationFormItemsListHelper }

constructor TdxBarCustomizationFormItemsListHelper.Create(
  AOwner: TdxBarCustomCustomizationForm; AListBox: TListBox);
begin
  inherited Create(AOwner, AListBox);
  ListBox.ItemHeight := dxBarButtonHeight;
  ListBox.ControlStyle := ListBox.ControlStyle + [csOpaque] - [csCaptureMouse];
  ListBox.MultiSelect := BarManager.Designing;
  ListBox.ItemHeight := dxBarButtonHeight;
  ListBox.OnClick := DoListClick;
  ListBox.OnDblClick := DoListDblClick;
  ListBox.OnKeyDown := DoListKeyDown;
  ListBox.OnMouseDown := DoListMouseDown;
  ListBox.OnMouseUp := DoListMouseUp;
end;

procedure TdxBarCustomizationFormItemsListHelper.DoListClick(Sender: TObject);
begin
  Owner.SynchronizeDesigner(ListBox);
end;

procedure TdxBarCustomizationFormItemsListHelper.DoListDblClick(Sender: TObject);
begin
  if Assigned(Owner.SelectedItem) then
    TdxBarItemAccess(Owner.SelectedItem).ShowDefaultEventHandler;
end;

procedure TdxBarCustomizationFormItemsListHelper.DoListKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if BarManager.Designing then
    case Key of
      VK_INSERT:
        if Shift = [] then
          Owner.aAddItem.Execute;

      VK_DELETE:
        if Shift = [] then
          Owner.aDeleteItem.Execute;
          
      VK_UP:
        if Shift = [ssCtrl] then
        begin
          Owner.aMoveUpItem.Execute;
          Key := 0;
        end;
        
      VK_DOWN:
        if Shift = [ssCtrl] then
        begin
          Owner.aMoveDownItem.Execute;
          Key := 0;
        end;
    end;
end;

procedure TdxBarCustomizationFormItemsListHelper.DoListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  AIsDragging: Boolean;
begin
  AIsDragging := (Button = mbLeft) and Windows.DragDetect(ListBox.Handle, GetMouseCursorPos);
  if Button = mbRight then
  begin
    ListBox.SetFocus;
    Owner.SetSelection(ListBox, Owner.ItemList[ListBox.ItemAtPos(Point(X, Y), True)]);
  end;
  Owner.SynchronizeDesigner(ListBox);
  if AIsDragging and (Owner.SelectedItem <> nil) then
    TdxBarManagerAccess(BarManager).DragAndDrop(Owner.SelectedItem, nil);
end;

procedure TdxBarCustomizationFormItemsListHelper.DoListMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) and BarManager.Designing then
    Owner.CommandsPopupMenu.PopupFromCursorPos;
end;

procedure TdxBarCustomizationFormItemsListHelper.WndProc(var Message: TMessage);

  procedure SynchronizeItemList;
  var
    I, AIndex: Integer;
    AList: TList;
    AItem: TdxBarItem;
  begin
    AIndex := Owner.CategoriesList.ItemIndex;
    if AIndex > -1 then
    begin
      AItem := TdxBarItem(Message.WParam);
      if Assigned(AItem) then
        ListBox.Items[Message.LParam] := AItem.Caption
      else
      begin
        AList := TList.Create;
        try
          with TdxBarManagerAccess(BarManager) do
            GetItemsByCategory(GetCategoryRealIndex(AIndex), AList);
          for I := 0 to AList.Count - 1 do
          begin
            AItem := TdxBarItem(AList[I]);
            ListBox.Items.AddObject(AItem.Caption, AItem);
          end;
        finally
          AList.Free;
        end;
      end;
    end;
  end;

  procedure WMEraseBkGnd(var Message: TWMEraseBkGnd);
  var
    R: TRect;
  begin
    R := ListBox.ClientRect;        
    if ListBox.Items.Count <> 0 then
      R.Top := ListBox.ItemRect(ListBox.Items.Count - 1).Bottom;
    FillRect(Message.DC, R, ListBox.Brush.Handle);
    Message.Result := 1;
  end;

  procedure WMMouseActivate(var Message: TMessage);
  var
    AItemIndex: Integer;
  begin
    AItemIndex := ListBox.ItemAtPos(ListBox.ScreenToClient(Mouse.CursorPos), True);
    if AItemIndex > -1 then
      ListBox.ItemIndex := AItemIndex;
  end;

  procedure CNDrawItem(const ADrawStruct: TDrawItemStruct);
  begin
    if ListBox.Items.Count > 0 then
    begin
      if odFocused in TOwnerDrawState(LongRec(ADrawStruct.itemState).Lo) then
        DrawFocusRect(ADrawStruct.hDC, ADrawStruct.rcItem); // hide default draw focus rect
    end;
  end;

begin
  if Message.Msg = WM_ERASEBKGND then
    WMEraseBkGnd(TWMEraseBkGnd(Message))
  else
  begin
    inherited WndProc(Message);
    case Message.Msg of
      WM_MOUSEACTIVATE:
        WMMouseActivate(Message);
      CN_DRAWITEM:
        CNDrawItem(TWMDrawItem(Message).DrawItemStruct^);
      else
      begin
        if Message.Msg = dxWM_LB_SYNCHRONIZE then
          SynchronizeItemList;
        if Message.Msg = dxWM_LB_SYNCHRONIZESELECTION then
          Owner.SynchronizeListBoxSelection(ListBox);
        if Message.Msg = dxWM_LB_UPDATEEVENTS then
          Owner.UpdateItemsListEvents;
      end;
    end;
  end;
end;

procedure TdxBarCustomCustomizationForm.aNewToolBarExecute(Sender: TObject);
begin
//#DG  lbBarsList.Items.BeginUpdate; { #DG - because modal form erased items}
  try
    BarManager.AddToolBar(False, True);
  finally
//#DG    lbBarsList.Items.EndUpdate;
  end;
end;

procedure TdxBarCustomCustomizationForm.aRenameToolBarExecute(Sender: TObject);
begin
  BarManager.RenameToolBar(SelectedBar);
end;

procedure TdxBarCustomCustomizationForm.aDeleteToolBarExecute(Sender: TObject);
var
  AConfirmString: string;
begin
//#DG  BarManager.Bars.BeginUpdate; {#DG AV - when inside delete proc repaint listbox calls}
  try
    if GetSelCount(BarListBox) > 1 then
      AConfirmString := cxGetResourceString(@dxSBAR_WANTTODELETETOOLBARS)
    else
      AConfirmString := Format(cxGetResourceString(@dxSBAR_WANTTODELETETOOLBAR), [SelectedBar.Caption]);

    if dxBarMessageBox(AConfirmString, MB_ICONEXCLAMATION or MB_OKCANCEL) = ID_OK then
      DeleteSelectedObjects(BarListBox);
    SetZOrder(True);
  finally
//#DG    BarManager.Bars.EndUpdate;
  end;
end;

function TdxBarCustomCustomizationForm.GetItemList(Index: Integer): TdxBarItem;
begin
  Result := TdxBarItem(GetObjectFromListBox(ItemsListBox, Index));
end;

function TdxBarCustomCustomizationForm.GetSelectedItem: TdxBarItem;
begin
  Result := TdxBarItem(GetExclusiveObject(ItemsListBox));
end;

procedure TdxBarCustomCustomizationForm.MoveItem(Delta: Integer);
begin
  MoveItems(ItemsListBox, TdxBarManagerAccess(BarManager).ItemList, Delta);
  ItemsListBox.SetFocus;
end;

procedure TdxBarCustomCustomizationForm.aResetToolBarExecute(Sender: TObject);
begin
  BarManager.ResetToolBar(SelectedBar);
  SetZOrder(True);
end;

function TdxBarCustomCustomizationForm.CanDeleteSelectedCategory: Boolean;
begin
  Result := (CategoriesList.Items.Count > 1) and (CategoriesList.ItemIndex > -1) and
    CanDeleteSelectedCategoryCommands;
end;

function TdxBarCustomCustomizationForm.CanDeleteSelectedCategoryCommands: Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to ItemsListBox.Items.Count - 1 do
  begin
    Result := IdxBarDesigner(BarManager).CanDeleteComponent(ItemList[I]);
    if not Result then
      Break;
  end;
end;

procedure TdxBarCustomCustomizationForm.CategoriesDeleteClick(Sender: TObject);
var
  AItemIndex: Integer;
begin
  if CanDeleteSelectedCategory then
  begin
    AItemIndex := CategoriesList.ItemIndex;
    if dxBarMessageBox(Format(cxGetResourceString(@dxSBAR_WANTTODELETECATEGORY),
      [CategoriesList.Items[AItemIndex]]), MB_ICONEXCLAMATION or MB_OKCANCEL) = ID_OK then
    begin
      SelectBarManager;
      BarManager.Categories.Delete(AItemIndex);
      CategoriesList.Items.Delete(AItemIndex);
      if AItemIndex = CategoriesList.Items.Count then
        Dec(AItemIndex);
      CategoriesList.ItemIndex := AItemIndex;
      SynchronizeListBox(ItemsListBox);
      CategoriesList.SetFocus;
    end;
  end;
end;

procedure TdxBarCustomCustomizationForm.CategoriesAddClick(Sender: TObject);
var
  S: string;
begin
  S := '';
  if dxBarEditName(S, 1, 0, BarManager, nil) then
  begin
    BarManager.Categories.Add(S);
    CategoriesList.Items.Add(S);
    CategoriesList.ItemIndex := CategoriesList.Items.Count - 1;
    SynchronizeListBox(ItemsListBox);
    CategoriesList.SetFocus;
  end;
end;

procedure TdxBarCustomCustomizationForm.CategoriesInsertClick(Sender: TObject);
var
  S: string;
  AItemIndex: Integer;
begin
  AItemIndex := CategoriesList.ItemIndex;
  if AItemIndex > -1 then
  begin
    S := '';
    if dxBarEditName(S, 1, 1, BarManager, nil) then
    begin
      AItemIndex := CategoriesList.ItemIndex;
      BarManager.Categories.Insert(AItemIndex, S);
      CategoriesList.Items.Insert(AItemIndex, S);
      CategoriesList.ItemIndex := AItemIndex;
      SynchronizeListBox(ItemsListBox);
      CategoriesList.SetFocus;
    end;
  end;  
end;

procedure TdxBarCustomCustomizationForm.CategoriesRenameClick(Sender: TObject);
var
  S: string;
  AItemIndex: Integer;
begin
  AItemIndex := CategoriesList.ItemIndex;
  if AItemIndex > -1 then
  begin
    S := CategoriesList.Items[AItemIndex];
    if dxBarEditName(S, 1, 2, BarManager, nil) then
    begin
      BarManager.Categories[AItemIndex] := S;
      CategoriesList.Items[AItemIndex] := S;
      CategoriesList.ItemIndex := AItemIndex;
      CategoriesList.SetFocus;
    end;
  end
end;

procedure TdxBarCustomCustomizationForm.CategoriesVisibleClick(Sender: TObject);
begin
  BarManager.CategoryVisible[CategoriesList.ItemIndex] := TdxBarButton(Sender).Down;
  CategoriesList.SetFocus;
end;

procedure TdxBarCustomCustomizationForm.CategoriesItemsVisibleChange(Sender: TObject);
begin
  BarManager.CategoryItemsVisible[CategoriesList.ItemIndex] :=
    TdxBarItemVisible(TdxBarCombo(Sender).ItemIndex);
  CategoriesList.SetFocus;
end;

procedure TdxBarCustomCustomizationForm.CategoriesPopupMenuPopup(Sender: TObject);
begin
  CategoriesInsert.Enabled := CategoriesList.ItemIndex > -1;
  CategoriesRename.Enabled := CategoriesList.ItemIndex > -1;
  with CategoriesVisible do
  begin
    Enabled := CategoriesList.ItemIndex > -1;
    Down := Enabled and Self.BarManager.CategoryVisible[CategoriesList.ItemIndex];
  end;
  with CategoriesItemsVisible do
  begin
    Enabled := CategoriesVisible.Enabled;
    if Enabled then
      ItemIndex := Ord(Self.BarManager.CategoryItemsVisible[CategoriesList.ItemIndex]);
  end;
  CategoriesDelete.Enabled := CanDeleteSelectedCategory;
end;

procedure TdxBarCustomCustomizationForm.CommandsPopupMenuPopup(Sender: TObject);
begin
  CommandsAdd.Enabled := aAddItem.Enabled;
  CommandsDelete.Enabled := aDeleteItem.Enabled;
  CommandsClear.Enabled := aClearItemList.Enabled;
  CommandsMoveUp.Enabled := aMoveUpItem.Enabled;
  CommandsMoveDown.Enabled := aMoveDownItem.Enabled;
  CommandsSubMenuEditor.Enabled := aSubMenuEditor.Enabled;
end;

procedure TdxBarCustomCustomizationForm.CommandsAddClick(Sender: TObject);
begin
  aAddItem.Execute;
end;

procedure TdxBarCustomCustomizationForm.CommandsDeleteClick(Sender: TObject);
begin
  aDeleteItem.Execute;
end;

procedure TdxBarCustomCustomizationForm.CommandsClearClick(Sender: TObject);
begin
  aClearItemList.Execute;
end;

procedure TdxBarCustomCustomizationForm.CommandsMoveUpClick(Sender: TObject);
begin
  aMoveUpItem.Execute;
end;

procedure TdxBarCustomCustomizationForm.CommandsSubMenuEditorClick(Sender: TObject);
begin
  aSubMenuEditor.Execute;
end;

procedure TdxBarCustomCustomizationForm.CommandsMoveDownClick(Sender: TObject);
begin
  aMoveDownItem.Execute;
end;

procedure TdxBarCustomCustomizationForm.aAddItemExecute(Sender: TObject);
var
  AItem: TdxBarItem;
begin
  TdxBarManagerAccess(BarManager).ItemList.BeginUpdate;
  try
    AItem := dxBarItemAddEditor(BarManager, CategoriesList.ItemIndex);
    if AItem <> nil then
    begin
      SynchronizeDesigner(AItem);
      ItemsListBox.SetFocus;
    end;
  finally
    TdxBarManagerAccess(BarManager).ItemList.EndUpdate;
  end;
end;

procedure TdxBarCustomCustomizationForm.aDeleteItemExecute(Sender: TObject);
begin
  DeleteSelectedObjects(ItemsListBox);
  ItemsListBox.SetFocus;
end;

procedure TdxBarCustomCustomizationForm.aSubMenuEditorExecute(Sender: TObject);
var
  ASubItem: TCustomdxBarSubItem;
begin
  ItemsListBox.SetFocus;
  ASubItem := TCustomdxBarSubItem(ItemsListBox.Items.Objects[ItemsListBox.ItemIndex]);
  ShowdxBarSubMenuEditor(ASubItem.ItemLinks);
end;

procedure TdxBarCustomCustomizationForm.aClearItemListExecute(Sender: TObject);
begin
  if dxBarMessageBox(Format(cxGetResourceString(@dxSBAR_WANTTOCLEARCOMMANDS),
    [CategoriesList.Items[CategoriesList.ItemIndex]]),
    MB_ICONEXCLAMATION or MB_OKCANCEL) = ID_OK then
  begin
    ItemsListBox.Items.BeginUpdate;
    try
      SendMessage(ItemsListBox.Handle, LB_SETSEL, Integer(True), -1);
      DeleteSelectedObjects(ItemsListBox);
      ItemsListBox.SetFocus;
    finally
      ItemsListBox.Items.EndUpdate;
    end;
  end;     
end;

procedure TdxBarCustomCustomizationForm.aMoveItemExecute(Sender: TObject);
begin
  MoveItem(TAction(Sender).Tag);
end;

initialization
  dxBarCustomizationFormClass := TdxBarCustomizationForm;
  dxWM_LB_SYNCHRONIZE := RegisterWindowMessage('dxWM_LB_SYNCHRONIZE');
  dxWM_LB_SYNCHRONIZESELECTION := RegisterWindowMessage('dxWM_LB_SYNCHRONIZESELECTION');
  dxWM_LB_UPDATEEVENTS := RegisterWindowMessage('dxWM_LB_UPDATEEVENTS');

end.
